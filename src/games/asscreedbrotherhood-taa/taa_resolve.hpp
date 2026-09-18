/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <array>
#include <cstring>
#include <d3d9.h>
#include <wrl/client.h>
#include <embed/shaders.h>
#include "./taa_camera.hpp"
#include "./taa_capture.hpp"

namespace acbrotherhood::taa {
using Microsoft::WRL::ComPtr;

// Accept the original SDR scene or a format selected by another addon. TAA
// never changes the game's resource descriptions or presentation color space.
inline bool IsSceneFormat(D3DFORMAT format) {
  return format == D3DFMT_A16B16G16R16F || format == D3DFMT_A8R8G8B8 || format == D3DFMT_X8R8G8B8
         || format == D3DFMT_A8B8G8R8 || format == D3DFMT_X8B8G8R8;
}

struct ResolveResources {
  std::array<ComPtr<IDirect3DTexture9>, 2> history;
  std::array<ComPtr<IDirect3DTexture9>, 2> sample_count;
  ComPtr<IDirect3DPixelShader9> shader;
  ComPtr<IDirect3DPixelShader9> motion_preview_shader;
  ComPtr<IDirect3DPixelShader9> rcas_shader;
  ComPtr<IDirect3DVertexBuffer9> vertices;
  ComPtr<IDirect3DBaseTexture9> original_scene;
  DWORD original_srgb = FALSE;
  D3DFORMAT source_format = D3DFMT_UNKNOWN;
  UINT width = 0, height = 0;
  unsigned index = 0;
  bool valid = false;
  bool failed = false;
  bool capture_succeeded = false;
  bool rcas_failed = false;
};

// Render directly in native DX9: no extra DX9/DX11 shared-texture transfers.
// Caller restores the original LUT sampler after its draw with RestoreScene.
inline bool Resolve(IDirect3DDevice9* native, ResolveResources* resources,
                    IDirect3DTexture9* scene, IDirect3DTexture9* depth,
                    const Matrix& reprojection, UINT width, UINT height,
                    const std::array<float, 2>& jitter, const std::array<float, 2>& previous_jitter,
                    bool pair_valid, unsigned mode, IDirect3DTexture9* object_motion = nullptr,
                    unsigned preview_confidence = 0, bool capture_inputs = false, const Matrix* sky_reprojection = nullptr,
                    bool native_msaa = false, float rcas_strength = 0.f) {
  resources->capture_succeeded = false;
  if (resources->failed) return false;
  if (resources->width != width || resources->height != height) *resources = {};
  if (!resources->shader) {
    // At 4K RGBA16F history + R16F counts consume 158.2 MiB. Reject extreme sizes in
    // this 32-bit prototype rather than attempting an unbounded allocation.
    if (uint64_t(width) * height * 20 > 160ull * 1024 * 1024
        || FAILED(native->CreatePixelShader(reinterpret_cast<const DWORD*>(__taa_resolve.data()), &resources->shader))) {
      resources->failed = true;
      return false;
    }
    for (auto& texture : resources->history) {
      if (FAILED(native->CreateTexture(width, height, 1, D3DUSAGE_RENDERTARGET, D3DFMT_A16B16G16R16F,
                                       D3DPOOL_DEFAULT, &texture, nullptr))) {
        *resources = {};
        resources->failed = true;
        return false;
      }
    }
    for (auto& texture : resources->sample_count) {
      if (FAILED(native->CreateTexture(width, height, 1, D3DUSAGE_RENDERTARGET, D3DFMT_R16F,
                                       D3DPOOL_DEFAULT, &texture, nullptr))) {
        *resources = {};
        resources->failed = true;
        return false;
      }
    }
    struct Vertex { float x, y, z, w, u, v; };
    const Vertex quad[] = {{-.5f, -.5f, 0, 1, 0, 0}, {width - .5f, -.5f, 0, 1, 1, 0},
                           {-.5f, height - .5f, 0, 1, 0, 1}, {width - .5f, height - .5f, 0, 1, 1, 1}};
    void* mapped = nullptr;
    if (FAILED(native->CreateVertexBuffer(sizeof(quad), D3DUSAGE_WRITEONLY, D3DFVF_XYZRHW | D3DFVF_TEX1,
                                          D3DPOOL_DEFAULT, &resources->vertices, nullptr))
        || FAILED(resources->vertices->Lock(0, sizeof(quad), &mapped, 0))) {
      *resources = {};
      resources->failed = true;
      return false;
    }
    std::memcpy(mapped, quad, sizeof(quad));
    resources->vertices->Unlock();
    resources->width = width;
    resources->height = height;
  }
  ComPtr<IDirect3DStateBlock9> state;
  std::array<ComPtr<IDirect3DSurface9>, 4> targets;
  ComPtr<IDirect3DSurface9> depth_surface, output, count_output;
  D3DVIEWPORT9 viewport;
  D3DCAPS9 caps;
  DWORD source_srgb = FALSE;
  D3DSURFACE_DESC source_desc;
  if (FAILED(scene->GetLevelDesc(0, &source_desc))
      || FAILED(native->GetSamplerState(0, D3DSAMP_SRGBTEXTURE, &source_srgb))
      || FAILED(native->GetDeviceCaps(&caps)) || caps.NumSimultaneousRTs < 2
      || !(caps.PrimitiveMiscCaps & D3DPMISCCAPS_MRTINDEPENDENTBITDEPTHS)
      || FAILED(native->CreateStateBlock(D3DSBT_ALL, &state))
      || FAILED(state->Capture()) || FAILED(native->GetViewport(&viewport))
      || FAILED(resources->history[resources->index]->GetSurfaceLevel(0, &output))
      || FAILED(resources->sample_count[resources->index]->GetSurfaceLevel(0, &count_output))) return false;
  if (resources->source_format != source_desc.Format || resources->original_srgb != source_srgb) resources->valid = false;
  resources->source_format = source_desc.Format;
  for (unsigned i = 0; i < caps.NumSimultaneousRTs && i < targets.size(); ++i) native->GetRenderTarget(i, &targets[i]);
  native->GetDepthStencilSurface(&depth_surface);
  native->SetDepthStencilSurface(nullptr);
  for (unsigned i = 1; i < caps.NumSimultaneousRTs && i < targets.size(); ++i) native->SetRenderTarget(i, nullptr);
  HRESULT status = native->SetRenderTarget(0, output.Get());
  if (SUCCEEDED(status)) status = native->SetRenderTarget(1, count_output.Get());
  const D3DVIEWPORT9 resolve_viewport = {0, 0, width, height, 0.f, 1.f};
  native->SetViewport(&resolve_viewport);
  native->SetVertexShader(nullptr);
  native->SetPixelShader(resources->shader.Get());
  native->SetFVF(D3DFVF_XYZRHW | D3DFVF_TEX1);
  native->SetStreamSource(0, resources->vertices.Get(), 0, 6 * sizeof(float));
  native->SetStreamSourceFreq(0, 1);
  native->SetRenderState(D3DRS_ZENABLE, FALSE);
  native->SetRenderState(D3DRS_ZWRITEENABLE, FALSE);
  native->SetRenderState(D3DRS_STENCILENABLE, FALSE);
  native->SetRenderState(D3DRS_ALPHABLENDENABLE, FALSE);
  native->SetRenderState(D3DRS_ALPHATESTENABLE, FALSE);
  native->SetRenderState(D3DRS_SCISSORTESTENABLE, FALSE);
  native->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
  native->SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
  native->SetRenderState(D3DRS_FOGENABLE, FALSE);
  native->SetRenderState(D3DRS_LIGHTING, FALSE);
  native->SetRenderState(D3DRS_CLIPPLANEENABLE, 0);
  native->SetRenderState(D3DRS_SRGBWRITEENABLE, FALSE);
  native->SetRenderState(D3DRS_COLORWRITEENABLE, 15);
  native->SetRenderState(D3DRS_COLORWRITEENABLE1, D3DCOLORWRITEENABLE_RED);
  native->SetTexture(0, scene);
  native->SetTexture(1, depth);
  native->SetTexture(2, resources->history[1 - resources->index].Get());
  native->SetTexture(3, resources->history[1 - resources->index].Get());
  native->SetTexture(4, resources->sample_count[1 - resources->index].Get());
  native->SetTexture(5, object_motion);
  for (unsigned i = 0; i < 6; ++i) {
    native->SetSamplerState(i, D3DSAMP_MINFILTER, i == 0 || i == 2 ? D3DTEXF_LINEAR : D3DTEXF_POINT);
    native->SetSamplerState(i, D3DSAMP_MAGFILTER, i == 0 || i == 2 ? D3DTEXF_LINEAR : D3DTEXF_POINT);
    native->SetSamplerState(i, D3DSAMP_MIPFILTER, D3DTEXF_NONE);
    native->SetSamplerState(i, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
    native->SetSamplerState(i, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
    native->SetSamplerState(i, D3DSAMP_SRGBTEXTURE, i == 0 ? source_srgb : FALSE);
  }
  native->SetPixelShaderConstantF(0, &reprojection.m[0][0], 4);
  native->SetPixelShaderConstantF(6, sky_reprojection ? &sky_reprojection->m[0][0] : &reprojection.m[0][0], 4);
  bool stationary_camera = true;
  for (unsigned row = 0; row < 4; ++row)
    for (unsigned column = 0; column < 4; ++column)
      stationary_camera = stationary_camera && std::abs(reprojection.m[row][column] - (row == column ? 1.f : 0.f)) < 1.e-6f;
  const float info[8] = {1.f / width, 1.f / height, jitter[0], jitter[1], object_motion ? (stationary_camera ? 2.f : 1.f) : 0.f,
                         source_srgb && source_desc.Format != D3DFMT_A16B16G16R16F ? 1.f : 0.f,
                         pair_valid && (mode != 1 || resources->valid) ? (native_msaa ? 2.f : 1.f) : 0.f, float(mode)};
  native->SetPixelShaderConstantF(4, info, 2);
  if (SUCCEEDED(status)) status = native->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2);
  if (SUCCEEDED(status) && mode == 1 && capture_inputs)
    resources->capture_succeeded = CaptureResolve(native, {
        scene, depth, resources->history[1 - resources->index].Get(),
        resources->sample_count[1 - resources->index].Get(), object_motion,
        resources->history[resources->index].Get(), resources->sample_count[resources->index].Get()});
  bool display_processed = false;
  if (SUCCEEDED(status) && mode == 1 && (preview_confidence || rcas_strength > 0.f)) {
    if (preview_confidence >= 3 && !resources->motion_preview_shader)
      native->CreatePixelShader(reinterpret_cast<const DWORD*>(__taa_motion_preview.data()), &resources->motion_preview_shader);
    if (!preview_confidence && !resources->rcas_shader && !resources->rcas_failed)
      resources->rcas_failed = FAILED(native->CreatePixelShader(reinterpret_cast<const DWORD*>(__taa_rcas.data()), &resources->rcas_shader));
    // Previous history is dead after the resolve. Reuse it as display scratch;
    // next frame writes over it while reading the untouched current history.
    // Unbind every alias before changing targets. Counts remain untouched too.
    native->SetTexture(2, nullptr);
    native->SetTexture(3, nullptr);
    native->SetTexture(4, nullptr);
    native->SetRenderTarget(1, nullptr);
    ComPtr<IDirect3DSurface9> display_output;
    if (SUCCEEDED(resources->history[1 - resources->index]->GetSurfaceLevel(0, &display_output))
        && SUCCEEDED(native->SetRenderTarget(0, display_output.Get()))) {
      if (preview_confidence) {
        // Diagnostics read the same unsharpened inputs used by TAA.
        const float preview_info[4] = {info[4], info[5], info[6], float(4 + preview_confidence)};
        if (SUCCEEDED(native->SetTexture(4, resources->sample_count[resources->index].Get()))
            && (preview_confidence < 3 || (resources->motion_preview_shader
                && SUCCEEDED(native->SetPixelShader(resources->motion_preview_shader.Get()))))
            && SUCCEEDED(native->SetPixelShaderConstantF(5, preview_info, 1)))
          display_processed = SUCCEEDED(native->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2));
      } else if (resources->rcas_shader) {
        // Sharpen completed TAA, never the history used by subsequent frames.
        // Reuse the dead previous history: no additional full-resolution RT.
        const float sharpening_info[4] = {info[0], info[1], rcas_strength, info[5]};
        if (SUCCEEDED(native->SetTexture(0, resources->history[resources->index].Get()))
            && SUCCEEDED(native->SetSamplerState(0, D3DSAMP_SRGBTEXTURE, FALSE))
            && SUCCEEDED(native->SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_POINT))
            && SUCCEEDED(native->SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_POINT))
            && SUCCEEDED(native->SetPixelShader(resources->rcas_shader.Get()))
            && SUCCEEDED(native->SetPixelShaderConstantF(0, sharpening_info, 1)))
          display_processed = SUCCEEDED(native->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2));
      }
    }
  }
  // State blocks do not capture render targets or the depth-stencil surface.
  for (unsigned i = 0; i < caps.NumSimultaneousRTs && i < targets.size(); ++i) native->SetRenderTarget(i, targets[i].Get());
  native->SetDepthStencilSurface(depth_surface.Get());
  const HRESULT restored = state->Apply();
  native->SetViewport(&viewport);
  if (FAILED(status) || FAILED(restored)) {
    resources->valid = false;
    return false;
  }
  resources->original_scene = scene;
  resources->original_srgb = source_srgb;
  // Resolve has already sampled the original texture with the native transfer
  // function. FP16 history must not be decoded again by the LUT sampler.
  if (FAILED(native->SetTexture(0, resources->history[display_processed ? 1 - resources->index : resources->index].Get()))
      || FAILED(native->SetSamplerState(0, D3DSAMP_SRGBTEXTURE, FALSE))) {
    native->SetTexture(0, scene);
    native->SetSamplerState(0, D3DSAMP_SRGBTEXTURE, source_srgb);
    resources->original_scene.Reset();
    resources->valid = false;
    return false;
  }
  resources->index = 1 - resources->index;
  resources->valid = mode == 1;
  return true;
}

inline void RestoreScene(IDirect3DDevice9* native, ResolveResources* resources) {
  if (resources->original_scene) {
    native->SetTexture(0, resources->original_scene.Get());
    native->SetSamplerState(0, D3DSAMP_SRGBTEXTURE, resources->original_srgb);
    resources->original_scene.Reset();
  }
}
}  // namespace acbrotherhood::taa
