/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <d3d11.h>
#include <wrl/client.h>
#include <cassert>
#include <span>
#include <vector>

// Capture vertex outputs without rasterization. This compares deformation and
// native varyings even when a synthetic mesh is outside the camera frustum.
inline std::vector<float> VertexOutputs(ID3D11Device* device, ID3D11DeviceContext* context,
                                       std::span<const uint8_t> code,
                                       std::span<const D3D11_SO_DECLARATION_ENTRY> outputs,
                                       UINT vertex_count = 3) {
  using Microsoft::WRL::ComPtr;
  UINT stride = 0;
  for (const auto& output : outputs) stride += output.ComponentCount * sizeof(float);
  ComPtr<ID3D11VertexShader> vertex;
  ComPtr<ID3D11GeometryShader> stream;
  assert(SUCCEEDED(device->CreateVertexShader(code.data(), code.size(), nullptr, &vertex)));
  assert(SUCCEEDED(device->CreateGeometryShaderWithStreamOutput(code.data(), code.size(), outputs.data(), UINT(outputs.size()), &stride, 1, D3D11_SO_NO_RASTERIZED_STREAM, nullptr, &stream)));
  ComPtr<ID3D11Buffer> buffer, staging;
  D3D11_BUFFER_DESC desc{stride * vertex_count, D3D11_USAGE_DEFAULT, D3D11_BIND_STREAM_OUTPUT};
  assert(SUCCEEDED(device->CreateBuffer(&desc, nullptr, &buffer)));
  desc.Usage = D3D11_USAGE_STAGING;
  desc.BindFlags = 0;
  desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
  assert(SUCCEEDED(device->CreateBuffer(&desc, nullptr, &staging)));
  auto* target = buffer.Get();
  const UINT offset = 0;
  context->VSSetShader(vertex.Get(), nullptr, 0);
  context->GSSetShader(stream.Get(), nullptr, 0);
  context->PSSetShader(nullptr, nullptr, 0);
  context->SOSetTargets(1, &target, &offset);
  context->Draw(vertex_count, 0);
  context->SOSetTargets(0, nullptr, nullptr);
  context->GSSetShader(nullptr, nullptr, 0);
  context->CopyResource(staging.Get(), buffer.Get());
  D3D11_MAPPED_SUBRESOURCE mapped;
  assert(SUCCEEDED(context->Map(staging.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
  const auto* data = static_cast<const float*>(mapped.pData);
  std::vector<float> result(data, data + stride * vertex_count / sizeof(float));
  context->Unmap(staging.Get(), 0);
  return result;
}
