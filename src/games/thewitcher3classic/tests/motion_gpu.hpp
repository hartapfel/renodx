/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11.h>
#include <d3d11shader.h>
#include <wrl/client.h>
#include <array>
#include <cassert>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <span>
#include <vector>
#include "../../../utils/float16.hpp"

using Microsoft::WRL::ComPtr;

bool SameColor(float native, float replacement) {
  if (std::isnan(native)) return std::isnan(replacement);
  if (std::isinf(native)) return native == replacement;
  return std::isfinite(replacement) && std::abs(native - replacement) < .002f;
}

std::vector<uint8_t> Read(const std::filesystem::path& path) {
  std::ifstream file(path, std::ios::binary);
  assert(file);
  return {std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>()};
}
ComPtr<ID3D11Buffer> Buffer(ID3D11Device* device, const void* data, UINT bytes, UINT flags, UINT stride = 0) {
  ComPtr<ID3D11Buffer> result;
  const D3D11_BUFFER_DESC desc{bytes, D3D11_USAGE_DEFAULT, flags, 0, stride ? UINT(D3D11_RESOURCE_MISC_BUFFER_STRUCTURED) : 0u, stride};
  const D3D11_SUBRESOURCE_DATA initial{data};
  assert(SUCCEEDED(device->CreateBuffer(&desc, data ? &initial : nullptr, &result)));
  return result;
}
void BindMaterialInputs(ID3D11DeviceContext* context, std::span<const uint8_t> code,
                        ID3D11ShaderResourceView* texture, ID3D11ShaderResourceView* array,
                        ID3D11ShaderResourceView* cube = nullptr, ID3D11ShaderResourceView* cubes = nullptr) {
  using Reflect = HRESULT(WINAPI*)(const void*, SIZE_T, REFIID, void**);
  static const auto reflect = reinterpret_cast<Reflect>(GetProcAddress(LoadLibraryW(L"d3dcompiler_47.dll"), "D3DReflect"));
  assert(reflect);
  ComPtr<ID3D11ShaderReflection> reflection;
  assert(SUCCEEDED(reflect(code.data(), code.size(), __uuidof(ID3D11ShaderReflection), &reflection)));
  D3D11_SHADER_DESC shader;
  assert(SUCCEEDED(reflection->GetDesc(&shader)));
  for (UINT index = 0; index < shader.BoundResources; ++index) {
    D3D11_SHADER_INPUT_BIND_DESC input;
    assert(SUCCEEDED(reflection->GetResourceBindingDesc(index, &input)));
    if (input.Type != D3D_SIT_TEXTURE) continue;
    ID3D11ShaderResourceView* view = nullptr;
    switch (input.Dimension) {
      case D3D_SRV_DIMENSION_TEXTURE2D:        view = texture; break;
      case D3D_SRV_DIMENSION_TEXTURE2DARRAY:   view = array; break;
      case D3D_SRV_DIMENSION_TEXTURECUBE:      view = cube; break;
      case D3D_SRV_DIMENSION_TEXTURECUBEARRAY: view = cubes; break;
      default:                                 assert(false);
    }
    assert(view);
    for (UINT slot = input.BindPoint; slot < input.BindPoint + input.BindCount; ++slot) context->PSSetShaderResources(slot, 1, &view);
  }
}
std::array<float, 4> Pixel(ID3D11DeviceContext* context, ID3D11Resource* resource) {
  ComPtr<ID3D11Texture2D> source;
  assert(SUCCEEDED(resource->QueryInterface(IID_PPV_ARGS(&source))));
  D3D11_TEXTURE2D_DESC desc;
  source->GetDesc(&desc);
  const auto format = desc.Format;
  desc.Usage = D3D11_USAGE_STAGING;
  desc.BindFlags = desc.MiscFlags = 0;
  desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
  ComPtr<ID3D11Device> device;
  context->GetDevice(&device);
  ComPtr<ID3D11Texture2D> staging;
  assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &staging)));
  context->CopyResource(staging.Get(), source.Get());
  D3D11_MAPPED_SUBRESOURCE mapped;
  assert(SUCCEEDED(context->Map(staging.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
  const auto* row = static_cast<const uint8_t*>(mapped.pData) + desc.Height / 2 * mapped.RowPitch;
  std::array<float, 4> result = {};
  if (format == DXGI_FORMAT_R32_FLOAT)
    result[0] = reinterpret_cast<const float*>(row)[desc.Width / 2];
  else if (format == DXGI_FORMAT_R8_UNORM)
    result[0] = row[desc.Width / 2] / 255.f;
  else {
    const UINT channels = format == DXGI_FORMAT_R16G16_FLOAT ? 2 : 4;
    const auto* values = reinterpret_cast<const uint16_t*>(row) + desc.Width / 2 * channels;
    for (UINT i = 0; i < channels; ++i) result[i] = renodx::utils::float16::Decode(values[i]);
  }
  context->Unmap(staging.Get(), 0);
  return result;
}
