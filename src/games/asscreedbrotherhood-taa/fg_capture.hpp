/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <memory>
#include <mutex>
#include <fstream>
#include <iomanip>
#include "./dlaa.hpp"
#include "./fg_protocol.hpp"

namespace acbrotherhood::frame_generation {
using Microsoft::WRL::ComPtr;
inline float generation_enabled = 0.f; // Setting index = generated frames; 0 Off, 1..5 = 2x..6x.
inline std::atomic<Status> generation_status = Status::off;
inline std::atomic<uint32_t> generation_error = 0, presented_count = 0;
inline std::atomic<uint32_t> generation_max = 0, generation_configured = 0, last_confirmed_count = 0;
inline std::atomic<bool> reflex_active = false;
inline uint32_t RequestedFrames() {
  return std::isfinite(generation_enabled) ? uint32_t(std::clamp(generation_enabled, 0.f, 5.f)) : 0u;
}
inline bool NeedsInputs() { return RequestedFrames() != 0; }
inline std::atomic<bool> output_enabled = false;
inline std::atomic<uint64_t> next_id = 0;
inline std::atomic<uint32_t> received_flags = 0, error = 0;
inline std::atomic<bool> dump_requested = false;
inline std::atomic<int> dump_status = 0;
struct Capture;
inline std::mutex capture_mutex;
inline std::weak_ptr<Capture> current;

// Private DX9Ex shared buffers only. No format changes to game resources.
struct Capture {
  Inputs inputs;
  std::array<ComPtr<IDirect3DTexture9>, 4> textures;
  std::array<ComPtr<IDirect3DSurface9>, 4> surfaces;
  ComPtr<IDirect3DSurface9> scene_target;
  ComPtr<IDirect3DTexture9> scene_copy;
  bool ui_valid = false;
  ComPtr<IDirect3DVertexBuffer9> vertices;
  ComPtr<IDirect3DPixelShader9> shader, copy;
  ComPtr<IDirect3DQuery9> complete;
  uint64_t consumed = 0;
  LARGE_INTEGER previous_time{}, frequency{};
  bool failed = false;
  uint32_t hudless_stage = 0, observed_format = 0;

  // Explicit developer readback, never part of the normal transport path.
  bool Dump() {
    wchar_t executable[32768]{};
    const DWORD length = GetModuleFileNameW(nullptr, executable, DWORD(std::size(executable)));
    if (!length || length >= std::size(executable)) return false;
    const auto directory = std::filesystem::path(executable).parent_path() / L"renodx-dev" / L"fg-capture"
        / (std::to_wstring(GetCurrentProcessId()) + L"-" + std::to_wstring(inputs.id));
    std::error_code filesystem_error;
    if (!std::filesystem::create_directories(directory, filesystem_error) || filesystem_error) return false;
    std::ofstream manifest(directory / "capture.txt");
    manifest << "version 1\nframe " << inputs.id << "\nsize " << inputs.width << ' ' << inputs.height
             << "\nflags " << inputs.flags << "\nreset " << inputs.reset << "\njitter " << inputs.jitter[0] << ' ' << inputs.jitter[1]
             << "\nmotion previous_minus_current_uv_unjittered\ndepth d3d_z_over_w_near_0_far_1\n"
             << "hudless native_working_color_before_hdr_output_encoding\n" << std::setprecision(9);
    manifest << "camera"; for (float v : inputs.current_camera) manifest << ' ' << v;
    manifest << "\nprevious_camera"; for (float v : inputs.previous_camera) manifest << ' ' << v;
    manifest << "\nclip_to_previous"; for (float v : inputs.clip_to_previous) manifest << ' ' << v;
    manifest << '\n';
    ComPtr<IDirect3DDevice9> device;
    if (FAILED(textures[0]->GetDevice(&device))) return false;
    constexpr const char* names[] = {"motion_rgba16f.bin", "depth_r32f.bin", "hudless_rgba16f.bin"};
    for (unsigned i = 0; i < ((inputs.flags & hudless) ? 3u : 2u); ++i) {
      ComPtr<IDirect3DSurface9> staging;
      if (FAILED(device->CreateOffscreenPlainSurface(inputs.width, inputs.height,
          (i == 1 || i == 3) ? D3DFMT_R32F : D3DFMT_A16B16G16R16F, D3DPOOL_SYSTEMMEM, &staging, nullptr))
          || FAILED(device->GetRenderTargetData(surfaces[i].Get(), staging.Get()))) return false;
      std::ofstream file(directory / names[i], std::ios::binary);
      D3DLOCKED_RECT lock{};
      if (!file || FAILED(staging->LockRect(&lock, nullptr, D3DLOCK_READONLY))) return false;
      for (unsigned y = 0; y < inputs.height && file; ++y)
        file.write(static_cast<const char*>(lock.pBits) + size_t(y) * lock.Pitch, size_t(inputs.width) * (i == 1 ? 4 : 8));
      staging->UnlockRect();
      file.close(); if (!file) return false;
      manifest << names[i] << '\n';
    }
    manifest << "complete\n"; manifest.close();
    return bool(manifest);
  }

  void ConfigureDraw(IDirect3DDevice9* device, const dlaa::SavedDraw& saved, unsigned target) {
    dlaa::Check(device->SetDepthStencilSurface(nullptr), dlaa::Stage::device);
    for (unsigned i = 1; i < saved.count; ++i) device->SetRenderTarget(i, nullptr);
    dlaa::Check(device->SetRenderTarget(0, surfaces[target].Get()), dlaa::Stage::device);
    if (target == 0) dlaa::Check(device->SetRenderTarget(1, surfaces[1].Get()), dlaa::Stage::device);
    const D3DVIEWPORT9 viewport{0,0,inputs.width,inputs.height,0.f,1.f};
    device->SetViewport(&viewport);
    device->SetVertexShader(nullptr);
    device->SetFVF(D3DFVF_XYZRHW | D3DFVF_TEX1);
    device->SetStreamSource(0, vertices.Get(), 0, 6 * sizeof(float));
    device->SetStreamSourceFreq(0, 1);
    for (auto state : {D3DRS_ZENABLE,D3DRS_ZWRITEENABLE,D3DRS_STENCILENABLE,D3DRS_ALPHABLENDENABLE,
                       D3DRS_ALPHATESTENABLE,D3DRS_SCISSORTESTENABLE,D3DRS_FOGENABLE,D3DRS_LIGHTING,
                       D3DRS_CLIPPLANEENABLE,D3DRS_SRGBWRITEENABLE}) device->SetRenderState(state, FALSE);
    device->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
    device->SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
    device->SetRenderState(D3DRS_COLORWRITEENABLE, 15);
    device->SetRenderState(D3DRS_COLORWRITEENABLE1, 15);
    for (unsigned i = 0; i < 2; ++i) {
      device->SetSamplerState(i, D3DSAMP_MINFILTER, D3DTEXF_POINT);
      device->SetSamplerState(i, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
      device->SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
      device->SetSamplerState(i, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
      device->SetSamplerState(i, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
      device->SetSamplerState(i, D3DSAMP_SRGBTEXTURE, FALSE);
    }
  }

  void Prepare(IDirect3DDevice9* device, IDirect3DTexture9* depth, IDirect3DTexture9* object,
               UINT width, UINT height, const taa::Matrix& camera, const taa::Matrix& previous,
               const taa::Matrix& reprojection, const taa::Matrix& sky,
               const std::array<float, 2>& jitter, bool continuous) {
    inputs.flags = 0;
    hudless_stage = 0; ui_valid = false; scene_target.Reset();
    if (failed) return;
    try {
      if (!shader) {
        if (!width || !height || uint64_t(width) * height > 8388608)
          throw dlaa::Failure{dlaa::Stage::shared_textures, ERROR_NOT_SUPPORTED};
        inputs.generation = ++next_id;
        QueryPerformanceFrequency(&frequency);
        inputs.width = width; inputs.height = height;
        D3DDEVICE_CREATION_PARAMETERS creation{};
        dlaa::Check(device->GetCreationParameters(&creation), dlaa::Stage::device);
        inputs.window = uintptr_t(creation.hFocusWindow);
        for (unsigned i = 0; i < 4; ++i) {
          HANDLE shared = nullptr;
          dlaa::Check(device->CreateTexture(width, height, 1, D3DUSAGE_RENDERTARGET,
              (i == 1 || i == 3) ? D3DFMT_R32F : D3DFMT_A16B16G16R16F, D3DPOOL_DEFAULT, &textures[i], &shared), dlaa::Stage::shared_textures);
          if (!shared) throw dlaa::Failure{dlaa::Stage::shared_textures, ERROR_NOT_SUPPORTED};
          inputs.textures[i] = uintptr_t(shared);
          dlaa::Check(textures[i]->GetSurfaceLevel(0, &surfaces[i]), dlaa::Stage::device);
        }
        dlaa::Check(device->CreatePixelShader(reinterpret_cast<const DWORD*>(__fg_inputs.data()), &shader), dlaa::Stage::shader);
        dlaa::Check(device->CreatePixelShader(reinterpret_cast<const DWORD*>(__fg_copy.data()), &copy), dlaa::Stage::shader);
        dlaa::Check(device->CreateQuery(D3DQUERYTYPE_EVENT, &complete), dlaa::Stage::device);
        const float quad[][6] = {{-.5f,-.5f,0,1,0,0},{width-.5f,-.5f,0,1,1,0},
                                 {-.5f,height-.5f,0,1,0,1},{width-.5f,height-.5f,0,1,1,1}};
        dlaa::Check(device->CreateVertexBuffer(sizeof(quad), D3DUSAGE_WRITEONLY, D3DFVF_XYZRHW | D3DFVF_TEX1,
                                              D3DPOOL_DEFAULT, &vertices, nullptr), dlaa::Stage::device);
        void* mapped = nullptr;
        dlaa::Check(vertices->Lock(0, sizeof(quad), &mapped, 0), dlaa::Stage::device);
        std::memcpy(mapped, quad, sizeof(quad));
        dlaa::Check(vertices->Unlock(), dlaa::Stage::device);
      }
      dlaa::SavedDraw saved(device);
      ConfigureDraw(device, saved, 0);
      device->SetTexture(0, depth); device->SetTexture(1, object);
      device->SetPixelShader(shader.Get());
      device->SetPixelShaderConstantF(0, &reprojection.m[0][0], 4);
      device->SetPixelShaderConstantF(6, &sky.m[0][0], 4);
      const float constants[] = {1.f/width,1.f/height,jitter[0],jitter[1],object?1.f:0.f,0.f,continuous?1.f:0.f,0.f};
      device->SetPixelShaderConstantF(4, constants, 2);
      dlaa::Check(device->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2), dlaa::Stage::shader);
      dlaa::Check(complete->Issue(D3DISSUE_END), dlaa::Stage::gpu_wait);
      inputs.id = ++next_id;
      inputs.reset = !continuous;
      inputs.jitter[0] = jitter[0]; inputs.jitter[1] = jitter[1];
      LARGE_INTEGER now;
      QueryPerformanceCounter(&now);
      inputs.delta_ms = previous_time.QuadPart
          ? float(double(now.QuadPart - previous_time.QuadPart) * 1000.0 / double(frequency.QuadPart))
          : 16.666667f;
      previous_time = now;
      std::memcpy(inputs.current_camera, &camera, sizeof(camera));
      std::memcpy(inputs.previous_camera, &previous, sizeof(previous));
      std::memcpy(inputs.clip_to_previous, &reprojection, sizeof(reprojection));
      inputs.flags = motion_depth;
      error = 0;
    } catch (const dlaa::Failure& failure) {
      failed = true; inputs.flags = 0; error = failure.code;
    }
  }

  // Called after the verified final scene composite, before any HUD draw.
  void CaptureHudless(IDirect3DDevice9* device) {
    if (!(inputs.flags & motion_depth) || (inputs.flags & hudless) || failed) return;
    hudless_stage = 1;
    ComPtr<IDirect3DSurface9> source;
    D3DSURFACE_DESC desc{};
    D3DVIEWPORT9 viewport{};
    if (FAILED(device->GetRenderTarget(0, &source)) || FAILED(source->GetDesc(&desc)) || FAILED(device->GetViewport(&viewport))) return;
    observed_format = desc.Format;
    hudless_stage = 2;
    if (desc.Width != inputs.width || desc.Height != inputs.height
        || (desc.Format != D3DFMT_A16B16G16R16F && desc.Format != D3DFMT_A8R8G8B8 && desc.Format != D3DFMT_X8R8G8B8)
        || desc.MultiSampleType != D3DMULTISAMPLE_NONE
        || viewport.X || viewport.Y || viewport.Width != inputs.width || viewport.Height != inputs.height) return;
    try {
      ComPtr<IDirect3DTexture9> texture;
      if (FAILED(source->GetContainer(IID_PPV_ARGS(&texture)))) {
        // Standalone SDR can target the native backbuffer, which has no texture
        // container. Copy its code values without replacing/upgrading it.
        D3DSURFACE_DESC previous{};
        if (scene_copy) scene_copy->GetLevelDesc(0, &previous);
        if (!scene_copy || previous.Width != desc.Width || previous.Height != desc.Height || previous.Format != desc.Format) {
          scene_copy.Reset();
          dlaa::Check(device->CreateTexture(desc.Width, desc.Height, 1, D3DUSAGE_RENDERTARGET,
              desc.Format, D3DPOOL_DEFAULT, &scene_copy, nullptr), dlaa::Stage::shared_textures);
        }
        ComPtr<IDirect3DSurface9> destination;
        dlaa::Check(scene_copy->GetSurfaceLevel(0, &destination), dlaa::Stage::device);
        // D3D9 StretchRect is outside BeginScene/EndScene. Use the native
        // device so the temporary boundary does not emit game-frame markers.
        const bool restart_scene = SUCCEEDED(device->EndScene());
        const HRESULT copied = device->StretchRect(source.Get(), nullptr, destination.Get(), nullptr, D3DTEXF_NONE);
        if (restart_scene) dlaa::Check(device->BeginScene(), dlaa::Stage::device);
        dlaa::Check(copied, dlaa::Stage::shared_textures);
        texture = scene_copy;
      }
      dlaa::SavedDraw saved(device);
      ConfigureDraw(device, saved, 2);
      device->SetTexture(0, texture.Get()); device->SetTexture(1, nullptr);
      device->SetPixelShader(copy.Get());
      dlaa::Check(device->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2), dlaa::Stage::shader);
      dlaa::Check(complete->Issue(D3DISSUE_END), dlaa::Stage::gpu_wait);
      scene_target = source;
      // Separate transmittance target: original game RGB/alpha are untouched.
      ConfigureDraw(device, saved, 3);
      dlaa::Check(device->Clear(0, nullptr, D3DCLEAR_TARGET, 0xFFFFFFFF, 1.f, 0), dlaa::Stage::device);
      ui_valid = true;
      inputs.flags |= hudless | ui_alpha;
      hudless_stage = 3;
    } catch (const dlaa::Failure& failure) { error = failure.code; }
  }

  // Accumulate coverage using original shader alpha without changing game RGB.
  template <typename Draw>
  void AccumulateUi(IDirect3DDevice9* device, Draw&& draw) {
    try {
      dlaa::SavedDraw saved(device);
      device->SetDepthStencilSurface(nullptr);
      for (unsigned i = 1; i < saved.count; ++i) device->SetRenderTarget(i, nullptr);
      dlaa::Check(device->SetRenderTarget(0, surfaces[3].Get()), dlaa::Stage::device);
      device->SetViewport(&saved.viewport);
      device->SetRenderState(D3DRS_COLORWRITEENABLE, D3DCOLORWRITEENABLE_RED);
      device->SetRenderState(D3DRS_SEPARATEALPHABLENDENABLE, FALSE);
      device->SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ZERO);
      device->SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
      device->SetRenderState(D3DRS_SRGBWRITEENABLE, FALSE);
      draw();
    } catch (...) { ui_valid = false; }
  }

  bool Acquire(HWND window) {
    if (!inputs.flags || consumed == inputs.id || inputs.window != uintptr_t(window)) return false;
    consumed = inputs.id; // A frame is never resubmitted, including failures.
    if (!ui_valid) inputs.flags &= ~ui_alpha;
    ui_valid = false;
    ComPtr<IDirect3DDevice9> device;
    if (FAILED(textures[0]->GetDevice(&device)) || FAILED(complete->Issue(D3DISSUE_END))) return false;
    const ULONGLONG deadline = GetTickCount64() + 2000;
    HRESULT result = complete->GetData(nullptr, 0, D3DGETDATA_FLUSH);
    for (;;) {
      if (result == S_OK) {
        if (dump_requested.exchange(false)) {
          try { dump_status = Dump() ? 1 : -1; } catch (...) { dump_status = -1; }
        }
        return true;
      }
      if (FAILED(result) || GetTickCount64() >= deadline) {
        error = FAILED(result) ? uint32_t(result) : WAIT_TIMEOUT;
        return false;
      }
      SwitchToThread();
      result = complete->GetData(nullptr, 0, 0);
    }
  }
};
}
