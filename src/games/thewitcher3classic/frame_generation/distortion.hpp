/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <span>
#include <cstdint>
#include "../temporal/context.hpp"

namespace witcher3classic::frame_generation {
class Distortion {
 public:
  Microsoft::WRL::ComPtr<ID3D11Texture2D> texture;
  uint64_t version = 0;
  bool Update(ID3D11DeviceContext1* context, UINT width, UINT height, float intensity,
              std::span<const uint8_t> vertex, std::span<const uint8_t> pixel) {
    if (texture && width_ == width && height_ == height && intensity_ == intensity) return true;
    Microsoft::WRL::ComPtr<ID3D11Device> device;
    context->GetDevice(&device);
    if (!state_) {
      const D3D11_BUFFER_DESC desc{16, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
      if (FAILED(temporal::CreateIsolatedState(device.Get(), &state_))
          || FAILED(device->CreateVertexShader(vertex.data(), vertex.size(), nullptr, &vertex_))
          || FAILED(device->CreatePixelShader(pixel.data(), pixel.size(), nullptr, &pixel_))
          || FAILED(device->CreateBuffer(&desc, nullptr, &constants_))) { state_.Reset(); return false; }
    }
    if (!texture || width_ != width || height_ != height) {
      target_.Reset(); texture.Reset();
      const D3D11_TEXTURE2D_DESC desc{(width+1)/2, (height+1)/2, 1, 1, DXGI_FORMAT_R16G16B16A16_FLOAT,
                                    {1,0}, D3D11_USAGE_DEFAULT, D3D11_BIND_RENDER_TARGET};
      if (FAILED(device->CreateTexture2D(&desc, nullptr, &texture))
          || FAILED(device->CreateRenderTargetView(texture.Get(), nullptr, &target_))) { texture.Reset(); return false; }
    }
    temporal::ContextScope scope(context, state_.Get());
    const float values[] = {float(width), float(height), intensity, 0};
    context->UpdateSubresource(constants_.Get(), 0, nullptr, values, 0, 0);
    ID3D11Buffer* constants = constants_.Get();
    context->PSSetConstantBuffers(0, 1, &constants);
    context->VSSetShader(vertex_.Get(), nullptr, 0);
    context->PSSetShader(pixel_.Get(), nullptr, 0);
    ID3D11RenderTargetView* target = target_.Get();
    context->OMSetRenderTargets(1, &target, nullptr);
    const D3D11_VIEWPORT viewport{0, 0, float((width+1)/2), float((height+1)/2), 0, 1};
    context->RSSetViewports(1, &viewport);
    context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    context->Draw(3, 0);
    width_ = width; height_ = height; intensity_ = intensity; ++version;
    return true;
  }
 private:
  Microsoft::WRL::ComPtr<ID3DDeviceContextState> state_;
  Microsoft::WRL::ComPtr<ID3D11VertexShader> vertex_;
  Microsoft::WRL::ComPtr<ID3D11PixelShader> pixel_;
  Microsoft::WRL::ComPtr<ID3D11Buffer> constants_;
  Microsoft::WRL::ComPtr<ID3D11RenderTargetView> target_;
  UINT width_ = 0, height_ = 0;
  float intensity_ = -1;
};
}  // namespace witcher3classic::frame_generation
