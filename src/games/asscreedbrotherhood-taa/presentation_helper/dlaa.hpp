/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d12sdklayers.h>
#include "../dlaa_protocol.hpp"
#include "./streamline.hpp"
#include "dlaa_prepare.h"

namespace acbrotherhood::dlaa {
using Microsoft::WRL::ComPtr;
struct Failure {
  Stage stage;
  uint32_t code;
};
inline void Check(HRESULT result, Stage stage) {
  if (FAILED(result)) throw Failure{stage, uint32_t(result)};
}
inline void CheckSl(sl::Result result, Stage stage) {
  if (result != sl::Result::eOk) throw Failure{stage, uint32_t(result)};
}
struct Gpu {
  ComPtr<ID3D12Device> device;  // Borrowed presenter device/queue, never created here.
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
    D3D12_RESOURCE_BARRIER barrier{};
    barrier.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
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
        SIZE_T size = 0;
        diagnostics->GetMessage(i, nullptr, &size);
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
  desc.Width = width;
  desc.Height = height;
  desc.MipLevels = desc.DepthOrArraySize = desc.SampleDesc.Count = 1;
  desc.Format = format;
  desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
  D3D12_HEAP_PROPERTIES heap{};
  heap.Type = D3D12_HEAP_TYPE_DEFAULT;
  ComPtr<ID3D12Resource> result;
  Check(device->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_NONE, &desc, D3D12_RESOURCE_STATE_UNORDERED_ACCESS,
                                        nullptr, IID_PPV_ARGS(&result)),
        Stage::shared_textures);
  return result;
}

// One feature on the presenter's device/queue. Separate viewport tags keep
// pre-LUT DLAA inputs distinct from the later output-encoded FG inputs.
struct Dlaa {
  Gpu gpu;
  frame_generation::Streamline* streamline = nullptr;
  const sl::ViewportHandle viewport{1};
  bool feature_configured = false;
  uint64_t generation = 0, last_frame = 0;
  uint32_t width = 0, height = 0, preset = 0;
  std::array<frame_generation::ImportedImage, 4> shared;
  ComPtr<ID3D12Resource> color, motion, responsive, output;
  ComPtr<ID3D12RootSignature> root;
  ComPtr<ID3D12PipelineState> prepare;
  ComPtr<ID3D12DescriptorHeap> descriptors;
  ComPtr<ID3D11DeviceContext4> copies;
  ~Dlaa() {
    // Even a failed evaluation may have submitted work. Feature resources and
    // all imports outlive completion; shutdown of Streamline belongs to presenter.
    try {
      if (gpu.fence) gpu.Wait();
    } catch (...) {
    }
    if (feature_configured) {
      sl::DLSSOptions off{};
      streamline->dlaa_options(viewport, off);
      streamline->free_resources(sl::kFeatureDLSS, viewport);
    }
  }
  void Start(const Packet* packet, ID3D12Device* device, ID3D12CommandQueue* queue,
             ID3D11Device5* bridge, ID3D11DeviceContext4* context, HANDLE parent,
             frame_generation::Streamline* owner, bool validation) {
    if (packet->magic != kMagic || packet->version != kProtocol || !packet->generation
        || !packet->width || !packet->height || uint64_t(packet->width) * packet->height > 8388608
        || std::find(kRenderPresets.begin(), kRenderPresets.end(), packet->render_preset) == kRenderPresets.end())
      throw Failure{Stage::protocol, ERROR_INVALID_DATA};
    streamline = owner;
    if (!owner->dlaa_ready) throw Failure{Stage::ngx_capability, owner->dlaa_error ? owner->dlaa_error : ERROR_NOT_SUPPORTED};
    width = packet->width;
    height = packet->height;
    preset = packet->render_preset;
    generation = packet->generation;
    gpu.device = device;
    gpu.queue = queue;
    gpu.parent = parent;
    copies = context;
    if (!gpu.complete.value) throw Failure{Stage::gpu_wait, GetLastError()};
    if (validation) device->QueryInterface(IID_PPV_ARGS(&gpu.diagnostics));
    Check(gpu.device->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&gpu.allocator)), Stage::device);
    Check(gpu.device->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, gpu.allocator.Get(), nullptr,
                                        IID_PPV_ARGS(&gpu.commands)),
          Stage::device);
    Check(gpu.device->CreateFence(0, D3D12_FENCE_FLAG_SHARED, IID_PPV_ARGS(&gpu.fence)), Stage::gpu_wait);
    Handle shared_fence;
    Check(gpu.device->CreateSharedHandle(gpu.fence.Get(), nullptr, GENERIC_ALL, nullptr, &shared_fence.value), Stage::gpu_wait);
    Check(bridge->OpenSharedFence(shared_fence.value, IID_PPV_ARGS(&gpu.fence11)), Stage::gpu_wait);
    const uint64_t handles[] = {packet->color, packet->motion, packet->depth, packet->output};
    for (unsigned i = 0; i < shared.size(); ++i) {
      try {
        shared[i].Open(bridge, gpu.device.Get(), handles[i], width, height,
                       i == 2 ? DXGI_FORMAT_R32_FLOAT : DXGI_FORMAT_R16G16B16A16_FLOAT, false);
      } catch (const acbrotherhood::presentation::Failure& failure) {
        throw Failure{Stage::shared_textures, failure.code};
      }
    }
    color = WorkingTexture(gpu.device.Get(), width, height, DXGI_FORMAT_R16G16B16A16_FLOAT);
    motion = WorkingTexture(gpu.device.Get(), width, height, DXGI_FORMAT_R16G16_FLOAT);
    responsive = WorkingTexture(gpu.device.Get(), width, height, DXGI_FORMAT_R8_UNORM);
    output = WorkingTexture(gpu.device.Get(), width, height, DXGI_FORMAT_R16G16B16A16_FLOAT);
    const D3D12_DESCRIPTOR_RANGE ranges[] = {{D3D12_DESCRIPTOR_RANGE_TYPE_SRV, 2, 0, 0, 0},
                                             {D3D12_DESCRIPTOR_RANGE_TYPE_UAV, 3, 0, 0, 2}};
    D3D12_ROOT_PARAMETER root_parameter{};
    root_parameter.ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
    root_parameter.DescriptorTable = {2, ranges};
    D3D12_ROOT_SIGNATURE_DESC root_desc{1, &root_parameter, 0, nullptr, D3D12_ROOT_SIGNATURE_FLAG_NONE};
    ComPtr<ID3DBlob> serialized, errors;
    Check(D3D12SerializeRootSignature(&root_desc, D3D_ROOT_SIGNATURE_VERSION_1, &serialized, &errors), Stage::shader);
    Check(gpu.device->CreateRootSignature(0, serialized->GetBufferPointer(), serialized->GetBufferSize(), IID_PPV_ARGS(&root)), Stage::shader);
    D3D12_COMPUTE_PIPELINE_STATE_DESC pso_desc{};
    pso_desc.pRootSignature = root.Get();
    pso_desc.CS = {dlaa_prepare, sizeof(dlaa_prepare)};
    Check(gpu.device->CreateComputePipelineState(&pso_desc, IID_PPV_ARGS(&prepare)), Stage::shader);
    D3D12_DESCRIPTOR_HEAP_DESC heap_desc{D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV, 5, D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE, 0};
    Check(gpu.device->CreateDescriptorHeap(&heap_desc, IID_PPV_ARGS(&descriptors)), Stage::shader);
    auto descriptor = descriptors->GetCPUDescriptorHandleForHeapStart();
    const UINT stride = gpu.device->GetDescriptorHandleIncrementSize(heap_desc.Type);
    for (unsigned i = 0; i < 2; ++i) {
      D3D12_SHADER_RESOURCE_VIEW_DESC view{};
      view.Format = DXGI_FORMAT_R16G16B16A16_FLOAT;
      view.ViewDimension = D3D12_SRV_DIMENSION_TEXTURE2D;
      view.Texture2D.MipLevels = 1;
      view.Shader4ComponentMapping = D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING;
      gpu.device->CreateShaderResourceView(shared[i].texture.Get(), &view, descriptor);
      descriptor.ptr += stride;
    }
    for (auto* resource : {color.Get(), motion.Get(), responsive.Get()}) {
      D3D12_UNORDERED_ACCESS_VIEW_DESC view{};
      view.Format = resource->GetDesc().Format;
      view.ViewDimension = D3D12_UAV_DIMENSION_TEXTURE2D;
      gpu.device->CreateUnorderedAccessView(resource, nullptr, &view, descriptor);
      descriptor.ptr += stride;
    }

    sl::DLSSOptions options{};
    options.mode = sl::DLSSMode::eDLAA;
    options.outputWidth = width;
    options.outputHeight = height;
    options.colorBuffersHDR = sl::eTrue;
    options.useAutoExposure = sl::eTrue;
    options.dlaaPreset = sl::DLSSPreset(preset);
    CheckSl(streamline->dlaa_options(viewport, options), Stage::ngx_create);
    feature_configured = true;
    gpu.Submit();
    gpu.Wait();
  }
  void Evaluate(Packet* packet) {
    const Frame frame = packet->frame;
    if (frame.id <= last_frame || !std::isfinite(frame.jitter_x) || !std::isfinite(frame.jitter_y)
        || std::abs(frame.jitter_x) > .5f || std::abs(frame.jitter_y) > .5f || !std::isfinite(frame.time_ms)
        || !streamline->token) throw Failure{Stage::protocol, ERROR_INVALID_DATA};
    frame_generation::Inputs camera;
    camera.width = width;
    camera.height = height;
    camera.jitter[0] = frame.jitter_x;
    camera.jitter[1] = frame.jitter_y;
    camera.reset = frame.reset || !last_frame || frame.id != last_frame + 1;
    std::memcpy(camera.current_camera, packet->current_camera, sizeof(camera.current_camera));
    std::memcpy(camera.clip_to_previous, packet->clip_to_previous, sizeof(camera.clip_to_previous));
    sl::Constants constants{};
    if (!frame_generation::CameraConstants(camera, &constants)) throw Failure{Stage::evaluate, ERROR_INVALID_DATA};
    CheckSl(streamline->set_constants(constants, *streamline->token, viewport), Stage::evaluate);
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

    sl::Extent extent{0, 0, width, height};
    sl::Resource input_color{sl::ResourceType::eTex2d, color.Get(), D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE};
    sl::Resource input_motion{sl::ResourceType::eTex2d, motion.Get(), D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE};
    sl::Resource input_depth{sl::ResourceType::eTex2d, shared[2].texture.Get(), D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE};
    sl::Resource input_bias{sl::ResourceType::eTex2d, responsive.Get(), D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE};
    sl::Resource output_color{sl::ResourceType::eTex2d, output.Get(), D3D12_RESOURCE_STATE_UNORDERED_ACCESS};
    const sl::ResourceTag tags[] = {
        {&input_color, sl::kBufferTypeScalingInputColor, sl::ResourceLifecycle::eOnlyValidNow, &extent},
        {&output_color, sl::kBufferTypeScalingOutputColor, sl::ResourceLifecycle::eOnlyValidNow, &extent},
        {&input_motion, sl::kBufferTypeMotionVectors, sl::ResourceLifecycle::eOnlyValidNow, &extent},
        {&input_depth, sl::kBufferTypeDepth, sl::ResourceLifecycle::eOnlyValidNow, &extent},
        {&input_bias, sl::kBufferTypeBiasCurrentColorHint, sl::ResourceLifecycle::eOnlyValidNow, &extent}};
    CheckSl(streamline->set_tags(*streamline->token, viewport, tags, 5, gpu.commands.Get()), Stage::evaluate);
    const sl::BaseStructure* inputs[] = {&viewport};
    CheckSl(streamline->evaluate(sl::kFeatureDLSS, *streamline->token, inputs, 1, gpu.commands.Get()), Stage::evaluate);
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
    packet->backend = 12;
    packet->stage = Stage::none;
    packet->error = 0;
    packet->state = WorkerState::complete;
  }
};
}  // namespace acbrotherhood::dlaa
