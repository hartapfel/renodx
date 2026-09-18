/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <windows.h>
#include <d3d11.h>
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
#include "../dlaa_protocol.hpp"
#include "../dlaa_handles.hpp"
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
struct Texture {
  ComPtr<ID3D11Texture2D> texture;
  ComPtr<ID3D11ShaderResourceView> srv;
  ComPtr<ID3D11UnorderedAccessView> uav;
};
Texture WorkingTexture(ID3D11Device* device, UINT width, UINT height, DXGI_FORMAT format) {
  D3D11_TEXTURE2D_DESC desc{};
  desc.Width = width; desc.Height = height;
  desc.MipLevels = desc.ArraySize = desc.SampleDesc.Count = 1;
  desc.Format = format;
  desc.BindFlags = D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_UNORDERED_ACCESS;
  Texture result;
  Check(device->CreateTexture2D(&desc, nullptr, &result.texture), Stage::shared_textures);
  Check(device->CreateShaderResourceView(result.texture.Get(), nullptr, &result.srv), Stage::shared_textures);
  Check(device->CreateUnorderedAccessView(result.texture.Get(), nullptr, &result.uav), Stage::shared_textures);
  return result;
}
// Release the feature before its device, including on any failed API call.
struct Ngx {
  ID3D11Device* device = nullptr;
  NVSDK_NGX_Parameter* parameters = nullptr;
  NVSDK_NGX_Handle* feature = nullptr;
  ~Ngx() {
    if (feature) NVSDK_NGX_D3D11_ReleaseFeature(feature);
    if (parameters) NVSDK_NGX_D3D11_DestroyParameters(parameters);
    if (device) NVSDK_NGX_D3D11_Shutdown1(device);
  }
};
void Run(Packet* packet, HANDLE request, HANDLE reply, HANDLE parent, std::ofstream* log) {
  if (packet->magic != kMagic || packet->version != kProtocol || !packet->width || !packet->height
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
  std::array<ComPtr<ID3D11Texture2D>, 4> shared;
  const uint64_t handles[] = {packet->color, packet->motion, packet->depth, packet->output};
  for (unsigned i = 0; i < shared.size(); ++i) {
    Check(device->OpenSharedResource(reinterpret_cast<HANDLE>(handles[i]), IID_PPV_ARGS(&shared[i])), Stage::shared_textures);
    D3D11_TEXTURE2D_DESC desc;
    shared[i]->GetDesc(&desc);
    if (desc.Width != width || desc.Height != height || desc.SampleDesc.Count != 1 || desc.MipLevels != 1
        || desc.ArraySize != 1 || desc.Format != (i == 2 ? DXGI_FORMAT_R32_FLOAT : DXGI_FORMAT_R16G16B16A16_FLOAT))
      throw Failure{Stage::shared_textures, ERROR_INVALID_DATA};
  }
  std::array<ComPtr<ID3D11ShaderResourceView>, 2> inputs;
  for (unsigned i = 0; i < inputs.size(); ++i)
    Check(device->CreateShaderResourceView(shared[i].Get(), nullptr, &inputs[i]), Stage::shared_textures);
  auto color = WorkingTexture(device.Get(), width, height, DXGI_FORMAT_R16G16B16A16_FLOAT);
  auto motion = WorkingTexture(device.Get(), width, height, DXGI_FORMAT_R16G16_FLOAT);
  auto responsive = WorkingTexture(device.Get(), width, height, DXGI_FORMAT_R8_UNORM);
  auto output = WorkingTexture(device.Get(), width, height, DXGI_FORMAT_R16G16B16A16_FLOAT);
  ComPtr<ID3D11ComputeShader> prepare;
  Check(device->CreateComputeShader(dlaa_prepare, sizeof(dlaa_prepare), nullptr, &prepare), Stage::shader);
  ComPtr<ID3D11Query> complete;
  const D3D11_QUERY_DESC query_desc{D3D11_QUERY_EVENT, 0};
  Check(device->CreateQuery(&query_desc, &complete), Stage::gpu_wait);
  wchar_t executable[32768];
  if (!GetModuleFileNameW(nullptr, executable, ARRAYSIZE(executable))) throw Failure{Stage::ngx_init, GetLastError()};
  const auto directory = std::filesystem::path(executable).parent_path().wstring();
  const wchar_t* paths[] = {directory.c_str()};
  NVSDK_NGX_FeatureCommonInfo info{};
  info.PathListInfo.Path = paths; info.PathListInfo.Length = 1;
  Ngx ngx;
  CheckNgx(NVSDK_NGX_D3D11_Init_with_ProjectID("3ad1c215-850f-4111-bcf4-5b7a4364600e", NVSDK_NGX_ENGINE_TYPE_CUSTOM,
           "1.0", directory.c_str(), device.Get(), &info, NVSDK_NGX_Version_API), Stage::ngx_init);
  ngx.device = device.Get();
  CheckNgx(NVSDK_NGX_D3D11_GetCapabilityParameters(&ngx.parameters), Stage::ngx_capability);
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
  CheckNgx(NGX_D3D11_CREATE_DLSS_EXT(context.Get(), &ngx.feature, ngx.parameters, &create), Stage::ngx_create);
  *log << "DLAA ready " << width << 'x' << height << ", protocol " << kProtocol << std::endl;
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
    ID3D11ShaderResourceView* srvs[] = {inputs[0].Get(), inputs[1].Get()};
    ID3D11UnorderedAccessView* uavs[] = {color.uav.Get(), motion.uav.Get(), responsive.uav.Get()};
    context->CSSetShader(prepare.Get(), nullptr, 0);
    context->CSSetShaderResources(0, 2, srvs);
    context->CSSetUnorderedAccessViews(0, 3, uavs, nullptr);
    context->Dispatch((width + 7) / 8, (height + 7) / 8, 1);
    ID3D11ShaderResourceView* null_srvs[2]{};
    ID3D11UnorderedAccessView* null_uavs[3]{};
    context->CSSetShaderResources(0, 2, null_srvs);
    context->CSSetUnorderedAccessViews(0, 3, null_uavs, nullptr);
    NVSDK_NGX_D3D11_DLSS_Eval_Params eval{};
    eval.Feature.pInColor = color.texture.Get(); eval.Feature.pInOutput = output.texture.Get();
    eval.pInDepth = shared[2].Get(); eval.pInMotionVectors = motion.texture.Get();
    eval.pInBiasCurrentColorMask = responsive.texture.Get();
    eval.InJitterOffsetX = frame.jitter_x; eval.InJitterOffsetY = frame.jitter_y;
    eval.InMVScaleX = float(width); eval.InMVScaleY = float(height);
    eval.InRenderSubrectDimensions.Width = width; eval.InRenderSubrectDimensions.Height = height;
    eval.InPreExposure = eval.InExposureScale = 1.f;
    eval.InReset = frame.reset || !last_frame || frame.id != last_frame + 1;
    eval.InFrameTimeDeltaInMsec = std::clamp(frame.time_ms, 1.f, 250.f);
    CheckNgx(NGX_D3D11_EVALUATE_DLSS_EXT(context.Get(), ngx.feature, ngx.parameters, &eval), Stage::evaluate);
    // This dedicated context has no game state to preserve. Clear NGX bindings
    // before reusing shared resources or binding our preparation shader again.
    context->ClearState();
    context->CopyResource(shared[3].Get(), output.texture.Get());
    context->End(complete.Get()); context->Flush();
    const ULONGLONG deadline = GetTickCount64() + 2000;
    for (;;) {
      const HRESULT result = context->GetData(complete.Get(), nullptr, 0, 0);
      Check(result, Stage::gpu_wait);
      if (result == S_OK) break;
      if (GetTickCount64() >= deadline) throw Failure{Stage::gpu_wait, WAIT_TIMEOUT};
      if (WaitForSingleObject(parent, 0) == WAIT_OBJECT_0) return;
      SwitchToThread();
    }
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
