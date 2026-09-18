/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <windows.h>
#include <d3d11_4.h>
#include <d3d12.h>
#include <d3d12sdklayers.h>
#include <dxgi1_2.h>
#include <wrl/client.h>
#include <nvsdk_ngx.h>
#include <nvsdk_ngx_helpers.h>
#include <array>
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <string>
#include <vector>
#include "../dlaa_protocol.hpp"
#include "../dlaa_handles.hpp"
#include "../presentation_helper/fg_import.hpp"
#include "prepare.h"

using namespace acbrotherhood::dlaa;
using Microsoft::WRL::ComPtr;
namespace {
struct Failure { Stage stage; uint32_t code; };
void Check(HRESULT result, Stage stage) {
  if (FAILED(result)) throw Failure{stage, uint32_t(result)};
}
void CheckNgx(NVSDK_NGX_Result result, Stage stage) {
  if (NVSDK_NGX_FAILED(result)) throw Failure{stage, uint32_t(result)};
}
// The DX11 context only transports legacy DX9 shared images. Preparation and
// NGX evaluation execute on this DX12 queue; this helper has no swapchain.
struct Gpu {
  ComPtr<ID3D12Device> device;
  ComPtr<ID3D12CommandQueue> queue;
  ComPtr<ID3D12CommandAllocator> allocator;
  ComPtr<ID3D12GraphicsCommandList> commands;
  ComPtr<ID3D12Fence> fence;
  ComPtr<ID3D11Fence> fence11;
  ComPtr<ID3D12InfoQueue> diagnostics;
  Handle complete{CreateEventW(nullptr, FALSE, FALSE, nullptr)};
  HANDLE parent = nullptr;
  uint64_t sequence = 0;
  void Barrier(ID3D12Resource* resource, D3D12_RESOURCE_STATES before, D3D12_RESOURCE_STATES after) {
    D3D12_RESOURCE_BARRIER barrier{}; barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    barrier.Transition = {resource, D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, before, after};
    commands->ResourceBarrier(1, &barrier);
  }
  void Submit() {
    Check(commands->Close(), Stage::evaluate);
    ID3D12CommandList* lists[] = {commands.Get()};
    queue->ExecuteCommandLists(1, lists);
    Check(queue->Signal(fence.Get(), ++sequence), Stage::gpu_wait);
  }
  void Wait() {
    Check(fence->SetEventOnCompletion(sequence, complete.value), Stage::gpu_wait);
    const HANDLE waits[] = {complete.value, parent};
    if (WaitForMultipleObjects(2, waits, FALSE, 2000) != WAIT_OBJECT_0)
      throw Failure{Stage::gpu_wait, WAIT_TIMEOUT};
    Check(device->GetDeviceRemovedReason(), Stage::gpu_wait);
    if (diagnostics) {
      for (UINT64 i = 0; i < diagnostics->GetNumStoredMessages(); ++i) {
        SIZE_T size = 0; diagnostics->GetMessage(i, nullptr, &size);
        std::vector<uint8_t> bytes(size);
        auto* message = reinterpret_cast<D3D12_MESSAGE*>(bytes.data());
        Check(diagnostics->GetMessage(i, message, &size), Stage::gpu_wait);
        if (message->Severity <= D3D12_MESSAGE_SEVERITY_ERROR)
          throw Failure{Stage::gpu_wait, uint32_t(E_FAIL)};
      }
      diagnostics->ClearStoredMessages();
    }
  }
};
ComPtr<ID3D12Resource> WorkingTexture(ID3D12Device* device, UINT width, UINT height, DXGI_FORMAT format) {
  D3D12_RESOURCE_DESC desc{};
  desc.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D;
  desc.Width = width; desc.Height = height;
  desc.MipLevels = desc.DepthOrArraySize = desc.SampleDesc.Count = 1;
  desc.Format = format;
  desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
  D3D12_HEAP_PROPERTIES heap{}; heap.Type = D3D12_HEAP_TYPE_DEFAULT;
  ComPtr<ID3D12Resource> result;
  Check(device->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc, D3D12_RESOURCE_STATE_UNORDERED_ACCESS,
                                        nullptr, IID_PPV_ARGS(&result)), Stage::shared_textures);
  return result;
}
// Release the feature before its device, including on any failed API call.
struct Ngx {
  Gpu* gpu = nullptr;
  NVSDK_NGX_Parameter* parameters = nullptr;
  NVSDK_NGX_Handle* feature = nullptr;
  ~Ngx() {
    if (gpu) {
      // Complete submitted work before releasing NGX and its tagged images,
      // including an exception after submission but before normal IPC reply.
      try {
        gpu->Wait();
        Check(gpu->queue->Signal(gpu->fence.Get(), ++gpu->sequence), Stage::gpu_wait);
        gpu->Wait();
      } catch (...) {}
    }
    if (feature) NVSDK_NGX_D3D12_ReleaseFeature(feature);
    if (parameters) NVSDK_NGX_D3D12_DestroyParameters(parameters);
    if (gpu) NVSDK_NGX_D3D12_Shutdown1(gpu->device.Get());
  }
};
void Run(Packet* packet, HANDLE request, HANDLE reply, HANDLE parent, std::ofstream* log) {
  if (packet->magic != kMagic || packet->version != kProtocol)
    throw Failure{Stage::protocol, ERROR_REVISION_MISMATCH};
  if (!packet->width || !packet->height
      || packet->width > 8192 || packet->height > 8192 || uint64_t(packet->width) * packet->height > 8388608
      || std::find(kRenderPresets.begin(), kRenderPresets.end(), packet->render_preset) == kRenderPresets.end())
    throw Failure{Stage::protocol, ERROR_INVALID_DATA};
  const UINT width = packet->width, height = packet->height;
  ComPtr<IDXGIFactory1> factory;
  Check(CreateDXGIFactory1(IID_PPV_ARGS(&factory)), Stage::device);
  ComPtr<IDXGIAdapter1> adapter;
  for (UINT index = 0;; ++index) {
    Check(factory->EnumAdapters1(index, &adapter), Stage::device);
    DXGI_ADAPTER_DESC1 desc;
    Check(adapter->GetDesc1(&desc), Stage::device);
    if (desc.AdapterLuid.LowPart == packet->adapter_low && desc.AdapterLuid.HighPart == packet->adapter_high) {
      if (desc.VendorId != 0x10de) throw Failure{Stage::device, ERROR_NOT_SUPPORTED};
      break;
    }
    adapter.Reset();
  }
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> context;
  const D3D_FEATURE_LEVEL requested[] = {D3D_FEATURE_LEVEL_11_0};
  Check(D3D11CreateDevice(adapter.Get(), D3D_DRIVER_TYPE_UNKNOWN, nullptr, 0, requested, 1,
                         D3D11_SDK_VERSION, &device, nullptr, &context), Stage::device);
  ComPtr<ID3D11Device5> bridge;
  ComPtr<ID3D11DeviceContext4> copies;
  Check(device.As(&bridge), Stage::device); Check(context.As(&copies), Stage::device);
  Gpu gpu; gpu.parent = parent;
  if (!gpu.complete.value) throw Failure{Stage::gpu_wait, GetLastError()};
  wchar_t validation[2]{};
  const bool validate = GetEnvironmentVariableW(L"RENODX_DLAA_VALIDATE", validation, 2) == 1 && validation[0] == L'1';
  if (validate) {
    ComPtr<ID3D12Debug> debug;
    Check(D3D12GetDebugInterface(IID_PPV_ARGS(&debug)), Stage::device);
    debug->EnableDebugLayer();
  }
  Check(D3D12CreateDevice(adapter.Get(), D3D_FEATURE_LEVEL_11_0, IID_PPV_ARGS(&gpu.device)), Stage::device);
  if (validate) Check(gpu.device.As(&gpu.diagnostics), Stage::device);
  D3D12_COMMAND_QUEUE_DESC queue_desc{}; queue_desc.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;
  Check(gpu.device->CreateCommandQueue(&queue_desc, IID_PPV_ARGS(&gpu.queue)), Stage::device);
  Check(gpu.device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&gpu.allocator)), Stage::device);
  Check(gpu.device->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, gpu.allocator.Get(), nullptr,
                                    IID_PPV_ARGS(&gpu.commands)), Stage::device);
  Check(gpu.device->CreateFence(0, D3D12_FENCE_FLAG_SHARED, IID_PPV_ARGS(&gpu.fence)), Stage::gpu_wait);
  Handle shared_fence;
  Check(gpu.device->CreateSharedHandle(gpu.fence.Get(), nullptr, GENERIC_ALL, nullptr, &shared_fence.value), Stage::gpu_wait);
  Check(bridge->OpenSharedFence(shared_fence.value, IID_PPV_ARGS(&gpu.fence11)), Stage::gpu_wait);
  std::array<acbrotherhood::frame_generation::ImportedImage, 4> shared;
  const uint64_t handles[] = {packet->color, packet->motion, packet->depth, packet->output};
  for (unsigned i = 0; i < shared.size(); ++i) {
    try {
      shared[i].Open(bridge.Get(), gpu.device.Get(), handles[i], width, height,
          i == 2 ? DXGI_FORMAT_R32_FLOAT : DXGI_FORMAT_R16G16B16A16_FLOAT, false);
    } catch (const acbrotherhood::presentation::Failure& failure) {
      throw Failure{Stage::shared_textures, failure.code};
    }
  }
  auto color = WorkingTexture(gpu.device.Get(), width, height, DXGI_FORMAT_R16G16B16A16_FLOAT);
  auto motion = WorkingTexture(gpu.device.Get(), width, height, DXGI_FORMAT_R16G16_FLOAT);
  auto responsive = WorkingTexture(gpu.device.Get(), width, height, DXGI_FORMAT_R8_UNORM);
  auto output = WorkingTexture(gpu.device.Get(), width, height, DXGI_FORMAT_R16G16B16A16_FLOAT);
  const D3D12_DESCRIPTOR_RANGE ranges[] = {{D3D12_DESCRIPTOR_RANGE_TYPE_SRV, 2, 0, 0, 0},
                                         {D3D12_DESCRIPTOR_RANGE_TYPE_UAV, 3, 0, 0, 2}};
  D3D12_ROOT_PARAMETER root_parameter{}; root_parameter.ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
  root_parameter.DescriptorTable = {2, ranges};
  D3D12_ROOT_SIGNATURE_DESC root_desc{1, &root_parameter, 0, nullptr, D3D12_ROOT_SIGNATURE_FLAG_NONE};
  ComPtr<ID3DBlob> serialized, errors;
  Check(D3D12SerializeRootSignature(&root_desc, D3D_ROOT_SIGNATURE_VERSION_1, &serialized, &errors), Stage::shader);
  ComPtr<ID3D12RootSignature> root;
  Check(gpu.device->CreateRootSignature(0, serialized->GetBufferPointer(), serialized->GetBufferSize(), IID_PPV_ARGS(&root)), Stage::shader);
  D3D12_COMPUTE_PIPELINE_STATE_DESC pso_desc{};
  pso_desc.pRootSignature = root.Get(); pso_desc.CS = {dlaa_prepare, sizeof(dlaa_prepare)};
  ComPtr<ID3D12PipelineState> prepare;
  Check(gpu.device->CreateComputePipelineState(&pso_desc, IID_PPV_ARGS(&prepare)), Stage::shader);
  D3D12_DESCRIPTOR_HEAP_DESC heap_desc{D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV, 5, D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE, 0};
  ComPtr<ID3D12DescriptorHeap> descriptors;
  Check(gpu.device->CreateDescriptorHeap(&heap_desc, IID_PPV_ARGS(&descriptors)), Stage::shader);
  auto descriptor = descriptors->GetCPUDescriptorHandleForHeapStart();
  const UINT stride = gpu.device->GetDescriptorHandleIncrementSize(heap_desc.Type);
  for (unsigned i = 0; i < 2; ++i) {
    D3D12_SHADER_RESOURCE_VIEW_DESC view{}; view.Format = DXGI_FORMAT_R16G16B16A16_FLOAT;
    view.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D; view.Texture2D.MipLevels = 1;
    view.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
    gpu.device->CreateShaderResourceView(shared[i].texture.Get(), &view, descriptor);
    descriptor.ptr += stride;
  }
  for (auto* resource : {color.Get(), motion.Get(), responsive.Get()}) {
    D3D12_UNORDERED_ACCESS_VIEW_DESC view{}; view.Format = resource->GetDesc().Format;
    view.ViewDimension = D3D12_UAV_DIMENSION_TEXTURE2D;
    gpu.device->CreateUnorderedAccessView(resource, nullptr, &view, descriptor);
    descriptor.ptr += stride;
  }
  wchar_t executable[32768];
  if (!GetModuleFileNameW(nullptr, executable, ARRAYSIZE(executable))) throw Failure{Stage::ngx_init, GetLastError()};
  const auto directory = std::filesystem::path(executable).parent_path().wstring();
  const wchar_t* paths[] = {directory.c_str()};
  NVSDK_NGX_FeatureCommonInfo info{};
  info.PathListInfo.Path = paths; info.PathListInfo.Length = 1;
  Ngx ngx;
  CheckNgx(NVSDK_NGX_D3D12_Init_with_ProjectID("3ad1c215-850f-4111-bcf4-5b7a4364600e", NVSDK_NGX_ENGINE_TYPE_CUSTOM,
           "1.0", directory.c_str(), gpu.device.Get(), &info, NVSDK_NGX_Version_API), Stage::ngx_init);
  ngx.gpu = &gpu;
  CheckNgx(NVSDK_NGX_D3D12_GetCapabilityParameters(&ngx.parameters), Stage::ngx_capability);
  int available = 0;
  CheckNgx(ngx.parameters->Get(NVSDK_NGX_Parameter_SuperSampling_Available, &available), Stage::ngx_capability);
  if (!available) throw Failure{Stage::ngx_capability, ERROR_NOT_SUPPORTED};
  NVSDK_NGX_DLSS_Create_Params create{};
  create.Feature.InWidth = create.Feature.InTargetWidth = width;
  create.Feature.InHeight = create.Feature.InTargetHeight = height;
  create.Feature.InPerfQualityValue = NVSDK_NGX_PerfQuality_Value_DLAA;
  // Undilated current-to-previous vectors at render resolution. Jitter is
  // supplied separately; clip depth is ordinary near=0, far=1.
  create.InFeatureCreateFlags = NVSDK_NGX_DLSS_Feature_Flags_IsHDR
                               | NVSDK_NGX_DLSS_Feature_Flags_AutoExposure | NVSDK_NGX_DLSS_Feature_Flags_MVLowRes;
  // Default deliberately leaves the hint unset. Each selection gets a fresh
  // helper/parameter block, including when returning from an explicit preset.
  // Runtime/driver overrides may still take precedence over this request.
  if (packet->render_preset != 0)
    ngx.parameters->Set(NVSDK_NGX_Parameter_DLSS_Hint_Render_Preset_DLAA, packet->render_preset);
  *log << "DLAA requested preset " << packet->render_preset
       << (packet->render_preset == 0 ? " (DLL default; no hint)" : " (NGX hint)") << std::endl;
  CheckNgx(NGX_D3D12_CREATE_DLSS_EXT(gpu.commands.Get(), 1, 1, &ngx.feature, ngx.parameters, &create), Stage::ngx_create);
  gpu.Submit(); gpu.Wait();
  *log << "DLAA ready " << width << 'x' << height << ", protocol " << kProtocol << ", backend D3D12" << std::endl;
  packet->backend = 12;
  packet->state = WorkerState::ready;
  MemoryBarrier(); SetEvent(reply);
  uint64_t last_frame = 0;
  const HANDLE waits[] = {request, parent};
  for (;;) {
    if (WaitForMultipleObjects(2, waits, FALSE, INFINITE) != WAIT_OBJECT_0) break;
    MemoryBarrier();
    if (packet->command == Command::stop) break;
    const Frame frame = packet->frame;
    if (frame.id <= last_frame || !std::isfinite(frame.jitter_x) || !std::isfinite(frame.jitter_y)
        || std::abs(frame.jitter_x) > .5f || std::abs(frame.jitter_y) > .5f || !std::isfinite(frame.time_ms))
      throw Failure{Stage::protocol, ERROR_INVALID_DATA};
    // DX9 completed its input writes before requesting this frame. Copy legacy
    // shared images into DX12-compatible resources, then hand off via a fence.
    for (unsigned i = 0; i < 3; ++i) copies->CopyResource(shared[i].bridge.Get(), shared[i].source.Get());
    Check(copies->Signal(gpu.fence11.Get(), ++gpu.sequence), Stage::gpu_wait);
    copies->Flush();
    Check(gpu.queue->Wait(gpu.fence.Get(), gpu.sequence), Stage::gpu_wait);
    Check(gpu.allocator->Reset(), Stage::evaluate);
    Check(gpu.commands->Reset(gpu.allocator.Get(), prepare.Get()), Stage::evaluate);
    for (unsigned i = 0; i < 3; ++i)
      gpu.Barrier(shared[i].texture.Get(), D3D12_RESOURCE_STATE_COMMON, D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE);
    ID3D12DescriptorHeap* heaps[] = {descriptors.Get()};
    gpu.commands->SetDescriptorHeaps(1, heaps);
    gpu.commands->SetComputeRootSignature(root.Get());
    gpu.commands->SetComputeRootDescriptorTable(0, descriptors->GetGPUDescriptorHandleForHeapStart());
    gpu.commands->Dispatch((width + 7) / 8, (height + 7) / 8, 1);
    for (auto* resource : {color.Get(), motion.Get(), responsive.Get()})
      gpu.Barrier(resource, D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE);
    NVSDK_NGX_D3D12_DLSS_Eval_Params eval{};
    eval.Feature.pInColor = color.Get(); eval.Feature.pInOutput = output.Get();
    eval.pInDepth = shared[2].texture.Get(); eval.pInMotionVectors = motion.Get();
    eval.pInBiasCurrentColorMask = responsive.Get();
    eval.InJitterOffsetX = frame.jitter_x; eval.InJitterOffsetY = frame.jitter_y;
    eval.InMVScaleX = float(width); eval.InMVScaleY = float(height);
    eval.InRenderSubrectDimensions.Width = width; eval.InRenderSubrectDimensions.Height = height;
    eval.InPreExposure = eval.InExposureScale = 1.f;
    eval.InReset = frame.reset || !last_frame || frame.id != last_frame + 1;
    eval.InFrameTimeDeltaInMsec = std::clamp(frame.time_ms, 1.f, 250.f);
    CheckNgx(NGX_D3D12_EVALUATE_DLSS_EXT(gpu.commands.Get(), ngx.feature, ngx.parameters, &eval), Stage::evaluate);
    for (auto* resource : {color.Get(), motion.Get(), responsive.Get()})
      gpu.Barrier(resource, D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    for (unsigned i = 0; i < 3; ++i)
      gpu.Barrier(shared[i].texture.Get(), D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE, D3D12_RESOURCE_STATE_COMMON);
    gpu.Barrier(output.Get(), D3D12_RESOURCE_STATE_UNORDERED_ACCESS, D3D12_RESOURCE_STATE_COPY_SOURCE);
    gpu.Barrier(shared[3].texture.Get(), D3D12_RESOURCE_STATE_COMMON, D3D12_RESOURCE_STATE_COPY_DEST);
    gpu.commands->CopyResource(shared[3].texture.Get(), output.Get());
    gpu.Barrier(shared[3].texture.Get(), D3D12_RESOURCE_STATE_COPY_DEST, D3D12_RESOURCE_STATE_COMMON);
    gpu.Barrier(output.Get(), D3D12_RESOURCE_STATE_COPY_SOURCE, D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
    gpu.Submit();
    Check(copies->Wait(gpu.fence11.Get(), gpu.sequence), Stage::gpu_wait);
    copies->CopyResource(shared[3].source.Get(), shared[3].bridge.Get());
    Check(copies->Signal(gpu.fence11.Get(), ++gpu.sequence), Stage::gpu_wait);
    copies->Flush();
    // Acknowledge only after the final DX11 -> DX9 shared output write, so the
    // game cannot sample unfinished DLAA output or overwrite a live NGX input.
    gpu.Wait();
    last_frame = frame.id;
    packet->completed_id = frame.id;
    packet->state = WorkerState::complete;
    MemoryBarrier(); SetEvent(reply);
  }
  *log << "DLAA shutdown after frame " << last_frame << std::endl;
}
}  // namespace

int wmain(int argc, wchar_t** argv) {
  // All four handles are inherited through an explicit STARTUPINFOEX allowlist.
  // No named global IPC or unrelated game handles are exposed to the helper.
  if (argc != 5) return 1;
  std::array<Handle, 4> handles;
  for (unsigned i = 0; i < handles.size(); ++i) {
    wchar_t* end = nullptr;
    const auto value = std::wcstoull(argv[i + 1], &end, 10);
    if (!value || !end || *end) return 1;
    handles[i].value = reinterpret_cast<HANDLE>(value);
  }
  auto* packet = static_cast<Packet*>(MapViewOfFile(handles[0].value, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(Packet)));
  if (!packet) return 1;
  std::ofstream log("renodx-dlaa-helper.log", std::ios::trunc);
  int exit_code = 0;
  try { Run(packet, handles[1].value, handles[2].value, handles[3].value, &log); }
  catch (const Failure& error) {
    packet->stage = error.stage; packet->error = error.code;
    packet->state = WorkerState::failed;
    MemoryBarrier(); SetEvent(handles[2].value);
    log << "Failure stage=" << uint32_t(error.stage) << " code=0x" << std::hex << error.code << std::endl;
    exit_code = 1;
  } catch (...) {
    packet->stage = Stage::protocol; packet->error = ERROR_UNHANDLED_EXCEPTION;
    packet->state = WorkerState::failed;
    MemoryBarrier(); SetEvent(handles[2].value);
    exit_code = 1;
  }
  UnmapViewOfFile(packet);
  return exit_code;
}
