/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <array>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <vector>
#include <d3d9.h>
#include <wrl/client.h>

namespace acbrotherhood::taa {

// Explicit, one-shot diagnostic. Read surfaces sequentially so only one
// full-size system-memory staging surface exists at a time. Never run in the
// normal capture/timing path: GPU readback and disk writes deliberately stall.
inline bool CaptureResolve(IDirect3DDevice9* native,
                           const std::array<IDirect3DTexture9*, 7>& textures) {
  wchar_t executable[32768] = {};
  const DWORD length = GetModuleFileNameW(nullptr, executable, DWORD(std::size(executable)));
  if (length == 0 || length >= std::size(executable)) return false;
  LARGE_INTEGER timestamp = {};
  if (!QueryPerformanceCounter(&timestamp)) return false;
  const auto directory = std::filesystem::path(executable).parent_path() / L"renodx-dev" / L"taa-capture"
                         / (std::to_wstring(GetCurrentProcessId()) + L"-" + std::to_wstring(timestamp.QuadPart));
  std::error_code error;
  if (!std::filesystem::create_directories(directory, error) || error) return false;
  std::ofstream manifest(directory / "capture.txt");
  if (!manifest) return false;
  Microsoft::WRL::ComPtr<IDirect3DPixelShader9> shader;
  UINT shader_size = 0;
  if (FAILED(native->GetPixelShader(&shader)) || !shader
      || FAILED(shader->GetFunction(nullptr, &shader_size)) || shader_size == 0) return false;
  std::vector<char> shader_code(shader_size);
  if (FAILED(shader->GetFunction(shader_code.data(), &shader_size))) return false;
  std::ofstream shader_file(directory / "resolve.cso", std::ios::binary);
  shader_file.write(shader_code.data(), shader_size);
  shader_file.close();
  if (!shader_file) return false;
  float constants[40] = {};
  DWORD source_srgb = 0;
  if (FAILED(native->GetPixelShaderConstantF(0, constants, 10))
      || FAILED(native->GetSamplerState(0, D3DSAMP_SRGBTEXTURE, &source_srgb))) return false;
  manifest << "version 2\nsource_srgb " << source_srgb << "\nconstants" << std::setprecision(9);
  for (float value : constants) manifest << ' ' << value;
  manifest << '\n';
  constexpr std::array<const char*, 7> names = {
      "scene", "depth", "history", "count", "motion", "output", "output_count"};
  for (unsigned i = 0; i < textures.size(); ++i) {
    if (!textures[i]) {
      manifest << names[i] << " absent\n";
      continue;
    }
    D3DSURFACE_DESC desc = {};
    Microsoft::WRL::ComPtr<IDirect3DSurface9> source, staging;
    if (FAILED(textures[i]->GetLevelDesc(0, &desc))
        || FAILED(textures[i]->GetSurfaceLevel(0, &source))) return false;
    unsigned bytes_per_pixel = 0;
    switch (desc.Format) {
      case D3DFMT_A16B16G16R16F: bytes_per_pixel = 8; break;
      case D3DFMT_R16F: bytes_per_pixel = 2; break;
      case D3DFMT_R32F:
      case D3DFMT_A8R8G8B8:
      case D3DFMT_X8R8G8B8:
      case D3DFMT_A8B8G8R8:
      case D3DFMT_X8B8G8R8: bytes_per_pixel = 4; break;
      default: return false;
    }
    if (FAILED(native->CreateOffscreenPlainSurface(desc.Width, desc.Height, desc.Format,
                                                  D3DPOOL_SYSTEMMEM, &staging, nullptr))
        || FAILED(native->GetRenderTargetData(source.Get(), staging.Get()))) return false;
    std::ofstream file(directory / (std::string(names[i]) + ".bin"), std::ios::binary);
    if (!file) return false;
    D3DLOCKED_RECT lock = {};
    if (FAILED(staging->LockRect(&lock, nullptr, D3DLOCK_READONLY))) return false;
    for (unsigned y = 0; y < desc.Height && file; ++y)
      file.write(static_cast<const char*>(lock.pBits) + size_t(y) * lock.Pitch,
                 size_t(desc.Width) * bytes_per_pixel);
    staging->UnlockRect();
    file.close();
    if (!file) return false;
    manifest << names[i] << ' ' << desc.Width << ' ' << desc.Height << ' '
             << unsigned(desc.Format) << ' ' << bytes_per_pixel << '\n';
  }
  manifest << "complete\n";
  manifest.close();
  return bool(manifest);
}
}  // namespace acbrotherhood::taa
