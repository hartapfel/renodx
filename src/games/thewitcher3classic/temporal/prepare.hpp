/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include <cstdint>
#include <span>
#include <wrl/client.h>
#include "./context.hpp"

namespace witcher3classic::temporal {
class Prepare {
 public:
  // Color FP16, raw depth FP32, normalized motion RG16, responsiveness R8.
  std::array<Microsoft::WRL::ComPtr<ID3D11Texture2D>, 4> textures;
  std::array<Microsoft::WRL::ComPtr<ID3D11ShaderResourceView>, 4> views;
  HRESULT error = S_OK;

  bool Initialize(ID3D11Device* device, std::span<const uint8_t> compute,
                  std::span<const uint8_t> vertex, std::span<const uint8_t> pixel, std::span<const uint8_t> debug = {}) {
    error = CreateIsolatedState(device, &isolated_);
    if (FAILED(error)) return false;
    error = device->CreateComputeShader(compute.data(), compute.size(), nullptr, &prepare_);
    if (FAILED(error)) return false;
    error = device->CreateVertexShader(vertex.data(), vertex.size(), nullptr, &vertex_);
    if (FAILED(error)) return false;
    error = device->CreatePixelShader(pixel.data(), pixel.size(), nullptr, &pixel_);
    if (SUCCEEDED(error) && !debug.empty()) error = device->CreatePixelShader(debug.data(), debug.size(), nullptr, &debug_);
    if (SUCCEEDED(error) && !debug.empty()) {
      const D3D11_BUFFER_DESC desc{32, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
      error = device->CreateBuffer(&desc, nullptr, &debug_constants_);
    }
    return SUCCEEDED(error);
  }

  bool Run(ID3D11DeviceContext1* context, ID3D11ShaderResourceView* scene, ID3D11ShaderResourceView* depth,
           ID3D11ShaderResourceView* objects, ID3D11Buffer* camera, ID3D11Buffer* frame, uint32_t width, uint32_t height,
           ID3D11ShaderResourceView* object_depth = nullptr) {
    if (!prepare_ || !scene || !depth || !camera || !frame || !width || !height
        || width > 8192 || height > 8192 || uint64_t{width} * height > 8388608) return false;
    if (width_ != width || height_ != height) {
      for (auto& view : views) view.Reset();
      for (auto& uav : uavs_) uav.Reset();
      for (auto& texture : textures) texture.Reset();
      constexpr DXGI_FORMAT formats[] = {DXGI_FORMAT_R16G16B16A16_FLOAT, DXGI_FORMAT_R32_FLOAT, DXGI_FORMAT_R16G16_FLOAT, DXGI_FORMAT_R8_UNORM};
      Microsoft::WRL::ComPtr<ID3D11Device> device;
      context->GetDevice(&device);
      for (size_t i = 0; i < textures.size(); ++i) {
        const D3D11_TEXTURE2D_DESC desc{width, height, 1, 1, formats[i], {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_UNORDERED_ACCESS};
        error = device->CreateTexture2D(&desc, nullptr, &textures[i]);
        if (FAILED(error)) return false;
        error = device->CreateShaderResourceView(textures[i].Get(), nullptr, &views[i]);
        if (FAILED(error)) return false;
        error = device->CreateUnorderedAccessView(textures[i].Get(), nullptr, &uavs_[i]);
        if (FAILED(error)) return false;
      }
      width_ = width; height_ = height;
    }
    ContextScope restore(context, isolated_.Get());
    ID3D11ShaderResourceView* inputs[] = {scene, depth, objects, object_depth};
    ID3D11UnorderedAccessView* outputs[] = {uavs_[0].Get(), uavs_[1].Get(), uavs_[2].Get(), uavs_[3].Get()};
    context->CSSetShader(prepare_.Get(), nullptr, 0);
    context->CSSetShaderResources(0, 4, inputs);
    context->CSSetConstantBuffers(10, 1, &camera);
    context->CSSetConstantBuffers(12, 1, &frame);
    context->CSSetUnorderedAccessViews(0, 4, outputs, nullptr);
    context->Dispatch((width + 7) / 8, (height + 7) / 8, 1);
    return true;
  }

  bool Blit(ID3D11DeviceContext1* context, ID3D11ShaderResourceView* resolved, ID3D11RenderTargetView* target,
            uint32_t width, uint32_t height, ID3D11ShaderResourceView* debug_depth = nullptr, bool debug_vectors = false, uint32_t debug_view = 0) {
    if (!vertex_ || !pixel_ || !resolved || !target || !width || !height) return false;
    ContextScope restore(context, isolated_.Get());
    context->VSSetShader(vertex_.Get(), nullptr, 0);
    if (debug_vectors && debug_view == 0) debug_view = 1;
    if (debug_view || debug_depth) {
      if (!debug_constants_) return false;
      const uint32_t constants[] = {debug_view, width, height, 0, width_, height_, 0, 0};
      context->UpdateSubresource(debug_constants_.Get(), 0, nullptr, constants, 0, 0);
      ID3D11Buffer* buffer = debug_constants_.Get();
      context->PSSetConstantBuffers(0, 1, &buffer);
    }
    if ((debug_view || debug_depth) && !debug_) return false;
    context->PSSetShader((debug_view || debug_depth) ? debug_.Get() : pixel_.Get(), nullptr, 0);
    context->PSSetShaderResources(0, 1, &resolved);
    context->PSSetShaderResources(1, 1, &debug_depth);
    context->OMSetRenderTargets(1, &target, nullptr);
    const D3D11_VIEWPORT viewport{0, 0, float(width), float(height), 0, 1};
    context->RSSetViewports(1, &viewport);
    context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    context->Draw(3, 0);
    return true;
  }

 private:
  Microsoft::WRL::ComPtr<ID3DDeviceContextState> isolated_;
  Microsoft::WRL::ComPtr<ID3D11ComputeShader> prepare_;
  Microsoft::WRL::ComPtr<ID3D11VertexShader> vertex_;
  Microsoft::WRL::ComPtr<ID3D11PixelShader> pixel_, debug_;
  std::array<Microsoft::WRL::ComPtr<ID3D11UnorderedAccessView>, 4> uavs_;
  Microsoft::WRL::ComPtr<ID3D11Buffer> debug_constants_;
  uint32_t width_ = 0, height_ = 0;
};
}  // namespace witcher3classic::temporal
