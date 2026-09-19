/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <windows.h>
#include <d3d9.h>
#include <wrl/client.h>
#include <array>
#include <algorithm>
#include <atomic>
#include <cstring>
#include <filesystem>
#include <memory>
#include <string>
#include <vector>
#include <embed/shaders.h>
#include "./dlaa_protocol.hpp"
#include "./dlaa_handles.hpp"
#include "./presentation_client.hpp"
#include "./taa_camera.hpp"

namespace acbrotherhood::dlaa {
using Microsoft::WRL::ComPtr;
inline HMODULE addon_module = nullptr;
inline std::atomic<uint64_t> next_generation = 0;
inline float render_preset = 0.f;  // Parsed NGX value; 0 leaves the DLL's choice untouched.
enum class Status { idle, starting, active, msaa, diagnostic, failed };
inline std::atomic<Status> status = Status::idle;
inline std::atomic<uint32_t> error_code = 0, error_stage = 0;
inline const char* StatusText() {
  switch (status.load()) {
    case Status::starting: return "DLAA is starting; using TAA temporarily.";
    case Status::active: return "DLAA active at native resolution (DX12).";
    case Status::msaa: return "Using TAA: turn native MSAA Off to use DLAA.";
    case Status::diagnostic: return "Using TAA for this diagnostic view.";
    case Status::failed:
      if (error_code == ERROR_FILE_NOT_FOUND || error_code == ERROR_PATH_NOT_FOUND)
        return "Using TAA: the DX12 helper executable or folder is missing. Check the installation and Windows Security protection history. Restore only verified files, then retry DX12 output and DLAA.";
      return "Using TAA: DLAA could not start or stopped. Check the helper installation, NVIDIA RTX driver and helper log. Select TAA, then DLAA to retry.";
    default: return "DLAA requires an NVIDIA RTX GPU and the unified DX12 helper folder beside the addon.";
  }
}
struct Failure { Stage stage; uint32_t code; };
inline void Check(HRESULT result, Stage stage) {
  if (FAILED(result)) throw Failure{stage, uint32_t(result)};
}

// State blocks omit RT/DS bindings. Always restore these even if IPC or a GPU
// call fails; only a fully completed image may replace the game's LUT input.
struct SavedDraw {
  IDirect3DDevice9* device;
  ComPtr<IDirect3DStateBlock9> state;
  std::array<ComPtr<IDirect3DSurface9>, 4> targets;
  ComPtr<IDirect3DSurface9> depth;
  D3DVIEWPORT9 viewport{};
  unsigned count = 0;
  explicit SavedDraw(IDirect3DDevice9* native) : device(native) {
    D3DCAPS9 caps{};
    Check(device->GetDeviceCaps(&caps), Stage::device);
    if (caps.NumSimultaneousRTs < 3 || !(caps.PrimitiveMiscCaps & D3DPMISCCAPS_MRTINDEPENDENTBITDEPTHS))
      throw Failure{Stage::device, ERROR_NOT_SUPPORTED};
    Check(device->CreateStateBlock(D3DSBT_ALL, &state), Stage::device);
    Check(state->Capture(), Stage::device);
    Check(device->GetViewport(&viewport), Stage::device);
    count = (std::min)(unsigned(targets.size()), unsigned(caps.NumSimultaneousRTs));
    for (unsigned i = 0; i < count; ++i) device->GetRenderTarget(i, &targets[i]);
    device->GetDepthStencilSurface(&depth);
  }
  ~SavedDraw() {
    device->SetDepthStencilSurface(nullptr);
    for (unsigned i = 1; i < count; ++i) device->SetRenderTarget(i, nullptr);
    for (unsigned i = 0; i < count; ++i) device->SetRenderTarget(i, targets[i].Get());
    device->SetDepthStencilSurface(depth.Get());
    state->Apply();
    device->SetViewport(&viewport);
  }
};

struct State {
  std::array<ComPtr<IDirect3DTexture9>, 4> textures;
  std::array<ComPtr<IDirect3DSurface9>, 4> surfaces;
  ComPtr<IDirect3DVertexBuffer9> vertices;
  ComPtr<IDirect3DPixelShader9> inputs, output, rcas;
  ComPtr<IDirect3DQuery9> complete;
  ComPtr<IDirect3DBaseTexture9> original_scene;
  DWORD original_srgb = FALSE;
  D3DFORMAT source_format = D3DFMT_UNKNOWN;
  UINT width = 0, height = 0;
  uint32_t preset = uint32_t(render_preset);
  bool failed = false, ready = false;
  ULONGLONG started = 0, previous_time = 0;
  uint64_t previous_frame = 0;
  Packet storage;
  Packet* packet = &storage;
  std::weak_ptr<presentation::Client> owner;
  ~State() { Stop(); }
  void Stop() {
    const std::lock_guard lock(presentation::mutex);
    if (auto client = owner.lock(); client && !client->failed && client->packet) {
      try { client->Dlaa(packet, true); } catch (...) {}
    }
    owner.reset(); ready = false;
  }
  void Fail(Stage stage, uint32_t code) {
    // Never write a command into a packet still owned by an in-flight worker.
    ready = false;
    Stop();
    textures = {}; surfaces = {}; vertices.Reset(); inputs.Reset(); output.Reset(); rcas.Reset(); complete.Reset();
    failed = true;
    error_stage = uint32_t(stage); error_code = code; status = Status::failed;
  }
  void RestoreScene(IDirect3DDevice9* device) {
    if (!original_scene) return;
    device->SetTexture(0, original_scene.Get());
    device->SetSamplerState(0, D3DSAMP_SRGBTEXTURE, original_srgb);
    original_scene.Reset();
  }

  void Start(IDirect3DDevice9* device, UINT render_width, UINT render_height, const std::filesystem::path& directory) {
    width = render_width; height = render_height;
    if (!width || !height || uint64_t(width) * height > 8388608)
      throw Failure{Stage::shared_textures, uint32_t(E_OUTOFMEMORY)};
    const auto executable = directory / L"renodx-asscreedbrotherhood-dx12.exe";
    if (GetFileAttributesW(executable.c_str()) == INVALID_FILE_ATTRIBUTES)
      throw Failure{Stage::protocol, GetLastError()};
    packet->generation = ++next_generation;
    packet->width = width; packet->height = height;
    packet->render_preset = preset;
    D3DDEVICE_CREATION_PARAMETERS creation{};
    ComPtr<IDirect3D9> d3d;
    ComPtr<IDirect3D9Ex> d3d_ex;
    Check(device->GetCreationParameters(&creation), Stage::device);
    Check(device->GetDirect3D(&d3d), Stage::device);
    Check(d3d.As(&d3d_ex), Stage::device);
    LUID luid{};
    Check(d3d_ex->GetAdapterLUID(creation.AdapterOrdinal, &luid), Stage::device);
    packet->adapter_low = luid.LowPart; packet->adapter_high = luid.HighPart;
    uint64_t* handles[] = {&packet->color, &packet->motion, &packet->depth, &packet->output};
    for (unsigned i = 0; i < textures.size(); ++i) {
      HANDLE shared = nullptr;  // Legacy GPU handle: do not CloseHandle.
      Check(device->CreateTexture(width, height, 1, D3DUSAGE_RENDERTARGET,
                                  i == 2 ? D3DFMT_R32F : D3DFMT_A16B16G16R16F,
                                  D3DPOOL_DEFAULT, &textures[i], &shared), Stage::shared_textures);
      if (!shared) throw Failure{Stage::shared_textures, ERROR_NOT_SUPPORTED};
      *handles[i] = uintptr_t(shared);
      Check(textures[i]->GetSurfaceLevel(0, &surfaces[i]), Stage::shared_textures);
    }
    Check(device->CreatePixelShader(reinterpret_cast<const DWORD*>(__dlaa_inputs.data()), &inputs), Stage::shader);
    Check(device->CreatePixelShader(reinterpret_cast<const DWORD*>(__dlaa_output.data()), &output), Stage::shader);
    Check(device->CreatePixelShader(reinterpret_cast<const DWORD*>(__taa_rcas.data()), &rcas), Stage::shader);
    Check(device->CreateQuery(D3DQUERYTYPE_EVENT, &complete), Stage::gpu_wait);
    const float quad[][6] = {{-.5f, -.5f, 0, 1, 0, 0}, {width - .5f, -.5f, 0, 1, 1, 0},
                             {-.5f, height - .5f, 0, 1, 0, 1}, {width - .5f, height - .5f, 0, 1, 1, 1}};
    Check(device->CreateVertexBuffer(sizeof(quad), D3DUSAGE_WRITEONLY, D3DFVF_XYZRHW | D3DFVF_TEX1,
                                     D3DPOOL_DEFAULT, &vertices, nullptr), Stage::device);
    void* mapped = nullptr;
    Check(vertices->Lock(0, sizeof(quad), &mapped, 0), Stage::device);
    std::memcpy(mapped, quad, sizeof(quad));
    Check(vertices->Unlock(), Stage::device);

    started = GetTickCount64();
    status = Status::starting; error_code = 0; error_stage = 0;
  }

  bool Resolve(IDirect3DDevice9* device, IDirect3DTexture9* scene, IDirect3DTexture9* depth,
               IDirect3DTexture9* object, const taa::Matrix& reprojection, const taa::Matrix& sky,
               const std::array<float, 2>& jitter, uint64_t frame, bool pair_valid,
               bool preview, float sharpening, const taa::Matrix& camera) {
    if (failed) return false;
    try {
      const std::lock_guard lock(presentation::mutex);
      const auto client = presentation::active_client.lock();
      if (!client || client->failed || !client->packet
          || client->packet->width != width || client->packet->height != height) {
        ready = false; status = Status::starting;
        if (GetTickCount64() - started > 30000) throw Failure{Stage::protocol, ERROR_NOT_READY};
        return false;
      }
      const bool new_session = owner.lock() != client;
      owner = client;
      started = GetTickCount64();
      D3DSURFACE_DESC desc{};
      DWORD srgb = FALSE;
      Check(scene->GetLevelDesc(0, &desc), Stage::device);
      Check(device->GetSamplerState(0, D3DSAMP_SRGBTEXTURE, &srgb), Stage::device);
      const bool linear = srgb && desc.Format != D3DFMT_A16B16G16R16F;
      const bool reset = new_session || !pair_valid || !previous_frame || frame != previous_frame + 1
                         || source_format != desc.Format || original_srgb != srgb;
      unsigned display = 0;
      {
        SavedDraw saved(device);
        Check(device->SetDepthStencilSurface(nullptr), Stage::device);
        for (unsigned i = 1; i < saved.count; ++i) Check(device->SetRenderTarget(i, nullptr), Stage::device);
        for (unsigned i = 0; i < 3; ++i) Check(device->SetRenderTarget(i, surfaces[i].Get()), Stage::device);
        const D3DVIEWPORT9 viewport{0, 0, width, height, 0.f, 1.f};
        Check(device->SetViewport(&viewport), Stage::device);
        Check(device->SetVertexShader(nullptr), Stage::device);
        Check(device->SetFVF(D3DFVF_XYZRHW | D3DFVF_TEX1), Stage::device);
        Check(device->SetStreamSource(0, vertices.Get(), 0, 6 * sizeof(float)), Stage::device);
        Check(device->SetStreamSourceFreq(0, 1), Stage::device);
        for (auto state : {D3DRS_ZENABLE, D3DRS_ZWRITEENABLE, D3DRS_STENCILENABLE, D3DRS_ALPHABLENDENABLE,
                           D3DRS_ALPHATESTENABLE, D3DRS_SCISSORTESTENABLE, D3DRS_FOGENABLE, D3DRS_LIGHTING,
                           D3DRS_CLIPPLANEENABLE, D3DRS_SRGBWRITEENABLE})
          Check(device->SetRenderState(state, FALSE), Stage::device);
        Check(device->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE), Stage::device);
        Check(device->SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID), Stage::device);
        for (auto state : {D3DRS_COLORWRITEENABLE, D3DRS_COLORWRITEENABLE1, D3DRS_COLORWRITEENABLE2})
          Check(device->SetRenderState(state, 15), Stage::device);
        for (unsigned i = 0; i < 3; ++i) {
          Check(device->SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_POINT), Stage::device);
          Check(device->SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_POINT), Stage::device);
          Check(device->SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_NONE), Stage::device);
          Check(device->SetSamplerState(i, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP), Stage::device);
          Check(device->SetSamplerState(i, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP), Stage::device);
          Check(device->SetSamplerState(i, D3DSAMP_SRGBTEXTURE, i == 0 ? srgb : FALSE), Stage::device);
        }
        Check(device->SetTexture(0, scene), Stage::device);
        Check(device->SetTexture(1, depth), Stage::device);
        Check(device->SetTexture(2, object), Stage::device);
        Check(device->SetPixelShader(inputs.Get()), Stage::shader);
        Check(device->SetPixelShaderConstantF(0, &reprojection.m[0][0], 4), Stage::shader);
        Check(device->SetPixelShaderConstantF(6, &sky.m[0][0], 4), Stage::shader);
        const float input_constants[] = {1.f / width, 1.f / height, jitter[0], jitter[1],
                                         object ? 1.f : 0.f, linear ? 1.f : 0.f, pair_valid ? 1.f : 0.f, 0.f};
        Check(device->SetPixelShaderConstantF(4, input_constants, 2), Stage::shader);
        Check(device->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2), Stage::shader);
        Check(complete->Issue(D3DISSUE_END), Stage::gpu_wait);
        const ULONGLONG deadline = GetTickCount64() + 2000;
        for (;;) {
          const HRESULT result = complete->GetData(nullptr, 0, D3DGETDATA_FLUSH);
          Check(result, Stage::gpu_wait);
          if (result == S_OK) break;
          if (GetTickCount64() >= deadline) throw Failure{Stage::gpu_wait, WAIT_TIMEOUT};
          SwitchToThread();
        }
        const ULONGLONG now = GetTickCount64();
        packet->frame = {frame, jitter[0], jitter[1], previous_time ? float(now - previous_time) : 16.666667f, reset ? 1u : 0u};
        std::memcpy(packet->current_camera, &camera.m[0][0], sizeof(packet->current_camera));
        // Camera cut/warm-up uses identity reprojection, as history is reset.
        if (pair_valid) std::memcpy(packet->clip_to_previous, &reprojection.m[0][0], sizeof(packet->clip_to_previous));
        else {
          std::fill(std::begin(packet->clip_to_previous), std::end(packet->clip_to_previous), 0.f);
          for (unsigned i = 0; i < 4; ++i) packet->clip_to_previous[i * 5] = 1.f;
        }
        try { client->Dlaa(packet); }
        catch (const presentation::Failure& failure) { throw Failure{Stage::protocol, failure.code}; }
        if (packet->state == WorkerState::failed) throw Failure{packet->stage, packet->error};
        if (packet->state != WorkerState::complete || packet->completed_id != frame)
          throw Failure{Stage::protocol, ERROR_INVALID_DATA};
        ready = true;
        previous_time = now;
        // The helper has finished reading input color; reuse it as output
        // conversion scratch, then reuse helper output for optional RCAS.
        for (unsigned i = 1; i < saved.count; ++i) Check(device->SetRenderTarget(i, nullptr), Stage::device);
        Check(device->SetTexture(0, textures[3].Get()), Stage::device);
        Check(device->SetTexture(1, scene), Stage::device);
        Check(device->SetTexture(2, textures[1].Get()), Stage::device);
        Check(device->SetSamplerState(0, D3DSAMP_SRGBTEXTURE, FALSE), Stage::device);
        Check(device->SetSamplerState(1, D3DSAMP_SRGBTEXTURE, srgb), Stage::device);
        Check(device->SetSamplerState(1, D3DSAMP_MINFILTER, D3DTEXF_LINEAR), Stage::device);
        Check(device->SetSamplerState(1, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR), Stage::device);
        Check(device->SetPixelShader(output.Get()), Stage::shader);
        Check(device->SetPixelShaderConstantF(0, input_constants, 1), Stage::shader);
        const float output_constants[] = {linear ? 1.f : 0.f, preview ? 1.f : 0.f, 0.f, 0.f};
        Check(device->SetPixelShaderConstantF(1, output_constants, 1), Stage::shader);
        Check(device->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2), Stage::shader);
        if (sharpening > 0.f && !preview) {
          Check(device->SetTexture(0, nullptr), Stage::device);
          Check(device->SetRenderTarget(0, surfaces[3].Get()), Stage::device);
          Check(device->SetTexture(0, textures[0].Get()), Stage::device);
          Check(device->SetPixelShader(rcas.Get()), Stage::shader);
          const float sharpening_constants[] = {1.f / width, 1.f / height, sharpening, linear ? 1.f : 0.f};
          Check(device->SetPixelShaderConstantF(0, sharpening_constants, 1), Stage::shader);
          Check(device->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2), Stage::shader);
          display = 3;
        }
      }
      original_scene = scene; original_srgb = srgb; source_format = desc.Format;
      Check(device->SetTexture(0, textures[display].Get()), Stage::device);
      Check(device->SetSamplerState(0, D3DSAMP_SRGBTEXTURE, FALSE), Stage::device);
      previous_frame = frame;
      status = Status::active;
      return true;
    } catch (const Failure& error) {
      RestoreScene(device);
      Fail(error.stage, error.code);
      return false;
    }
  }
};

inline bool Resolve(IDirect3DDevice9* device, std::unique_ptr<State>* state, IDirect3DTexture9* scene,
                     IDirect3DTexture9* depth, IDirect3DTexture9* object, const taa::Matrix& reprojection,
                     const taa::Matrix& sky, UINT width, UINT height, const std::array<float, 2>& jitter,
                     uint64_t frame, bool pair_valid, bool preview, float sharpening, const taa::Matrix& camera) {
  if (*state && ((*state)->width != width || (*state)->height != height
                 || (*state)->preset != uint32_t(render_preset))) state->reset();
  if (!*state) {
    *state = std::make_unique<State>();
    try {
      std::wstring module_path(32768, L'\0');
      if (!GetModuleFileNameW(addon_module, module_path.data(), DWORD(module_path.size()))) throw Failure{Stage::protocol, GetLastError()};
      (*state)->Start(device, width, height, std::filesystem::path(module_path.c_str()).parent_path() / L"renodx-asscreedbrotherhood-dx12");
    } catch (const Failure& error) { (*state)->Fail(error.stage, error.code); }
      catch (...) { (*state)->Fail(Stage::protocol, E_OUTOFMEMORY); }
  }
  return (*state)->Resolve(device, scene, depth, object, reprojection, sky, jitter, frame, pair_valid, preview, sharpening, camera);
}
}  // namespace acbrotherhood::dlaa
