/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <atomic>
#include <filesystem>
#include <fstream>
#include <span>
#include <vector>
#include "../temporal/context.hpp"

namespace witcher3classic::frame_generation::diagnostics {
inline std::atomic<unsigned> remaining = 0;
inline std::atomic<const char*> status = "";

// Explicit developer capture only. No allocation, filesystem polling, GPU
// readback or synchronization on ordinary frames. Captures are not benchmarks.
inline void Capture(ID3D11DeviceContext1* context, std::span<ID3D11Texture2D* const> textures,
                    const void* constants, size_t constants_size) {
  if (!remaining.load()) return;
  using Microsoft::WRL::ComPtr;
  static std::filesystem::path directory;
  try {
    if (remaining.load() == 2) {
      wchar_t executable[32768]{};
      if (!GetModuleFileNameW(nullptr, executable, UINT(std::size(executable)))) throw std::runtime_error("executable");
      directory = std::filesystem::path(executable).parent_path() / L"renodx-frame-generation-logs"
                  / (L"inputs-" + std::to_wstring(GetTickCount64()));
      std::filesystem::create_directories(directory);
    }
    const auto prefix = std::to_string(2 - remaining.load());
    std::ofstream metadata(directory / (prefix + "-constants.bin"), std::ios::binary);
    metadata.write(static_cast<const char*>(constants), constants_size);
    if (!metadata) throw std::runtime_error("constants");
    ComPtr<ID3D11Device> device;
    context->GetDevice(&device);
    std::vector<ComPtr<ID3D11Texture2D>> staging(textures.size());
    for (size_t i = 0; i < textures.size(); ++i) {
      if (!textures[i]) continue; // Optional lens field is absent when CA is off.
      D3D11_TEXTURE2D_DESC desc{};
      textures[i]->GetDesc(&desc);
      desc.Usage = D3D11_USAGE_STAGING;
      desc.BindFlags = desc.MiscFlags = 0;
      desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
      if (FAILED(device->CreateTexture2D(&desc, nullptr, &staging[i]))) throw std::runtime_error("staging");
      context->CopyResource(staging[i].Get(), textures[i]);
    }
    for (size_t i = 0; i < staging.size(); ++i) {
      if (!staging[i]) continue;
      D3D11_TEXTURE2D_DESC desc{};
      staging[i]->GetDesc(&desc);
      D3D11_MAPPED_SUBRESOURCE mapped{};
      if (FAILED(context->Map(staging[i].Get(), 0, D3D11_MAP_READ, 0, &mapped))) throw std::runtime_error("map");
      // Header: width, height, DXGI_FORMAT, row pitch, followed by pitched rows.
      // A failed file write still unmaps the GPU resource before reporting it.
      std::ofstream output(directory / (prefix + "-" + std::to_string(i) + ".bin"), std::ios::binary);
      const uint32_t header[] = {desc.Width, desc.Height, uint32_t(desc.Format), mapped.RowPitch};
      output.write(reinterpret_cast<const char*>(header), sizeof(header));
      output.write(static_cast<const char*>(mapped.pData), size_t(mapped.RowPitch) * desc.Height);
      context->Unmap(staging[i].Get(), 0);
      if (!output) throw std::runtime_error("texture file");
    }
    status = remaining.fetch_sub(1) == 1 ? "Saved two FG input frames in renodx-frame-generation-logs" : "Capturing second frame";
  } catch (const std::exception&) {
    remaining = 0;
    status = "FG input capture failed";
  }
}
}  // namespace witcher3classic::frame_generation::diagnostics
