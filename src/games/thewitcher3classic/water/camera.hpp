/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <embed/0xF3C50005.h>
#include <cstdint>
#include <array>
#include <algorithm>
#include <span>
#include "../temporal/context.hpp"

namespace witcher3classic::water {
class Camera {
  template<class T> using ComPtr = Microsoft::WRL::ComPtr<T>;
 public:
  uint64_t applied_frame = UINT64_MAX;
  ComPtr<ID3D11ShaderResourceView> saved_scene;
  void Restore(ID3D11DeviceContext1* context) {
    if (!saved_scene) return;
    auto* source = saved_scene.Get();
    context->PSSetShaderResources(0, 1, &source);
    saved_scene.Reset();
  }
  ID3D11ShaderResourceView* Run(ID3D11DeviceContext1* context, ID3D11ShaderResourceView* scene,
      ID3D11ShaderResourceView* water_state, UINT width, UINT height, uint64_t frame,
      std::span<const uint8_t> vertex, const std::array<float,2>& effects) {
    if (!scene || !water_state || applied_frame == frame || !width || !height) return nullptr;
    ComPtr<ID3D11Resource> source;
    ComPtr<ID3D11Texture2D> texture;
    scene->GetResource(&source);
    if (FAILED(source.As(&texture))) return nullptr;
    D3D11_TEXTURE2D_DESC desc{}; texture->GetDesc(&desc);
    D3D11_SHADER_RESOURCE_VIEW_DESC view_desc{}; scene->GetDesc(&view_desc);
    if (desc.SampleDesc.Count != 1 || width > desc.Width || height > desc.Height
        || view_desc.ViewDimension != D3D11_SRV_DIMENSION_TEXTURE2D
        || view_desc.Texture2D.MostDetailedMip != 0) return nullptr;
    ComPtr<ID3D11Device> device; context->GetDevice(&device);
    if (!state_) {
      const D3D11_BUFFER_DESC constants{32, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER};
      D3D11_SAMPLER_DESC sampler{};
      sampler.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
      sampler.AddressU = sampler.AddressV = sampler.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
      sampler.MaxLOD = D3D11_FLOAT32_MAX;
      if (FAILED(temporal::CreateIsolatedState(device.Get(), &state_))
          || FAILED(device->CreateVertexShader(vertex.data(), vertex.size(), nullptr, &vertex_))
          || FAILED(device->CreatePixelShader(__0xF3C50005.data(), __0xF3C50005.size(), nullptr, &pixel_))
          || FAILED(device->CreateBuffer(&constants, nullptr, &constants_))
          || FAILED(device->CreateSamplerState(&sampler, &sampler_))) {
        state_.Reset(); return nullptr;
      }
    }
    if (!views_[1] || allocation_width_ != desc.Width || allocation_height_ != desc.Height) {
      for (UINT i=0;i<2;++i) {views_[i].Reset();targets_[i].Reset();textures_[i].Reset();}
      const D3D11_TEXTURE2D_DESC output{desc.Width, desc.Height, 1, 1, DXGI_FORMAT_R16G16B16A16_FLOAT,
          {1,0}, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_RENDER_TARGET};
      for (UINT i=0;i<2;++i) {
        if (FAILED(device->CreateTexture2D(&output, nullptr, &textures_[i]))
            || FAILED(device->CreateShaderResourceView(textures_[i].Get(), nullptr, &views_[i]))
            || FAILED(device->CreateRenderTargetView(textures_[i].Get(), nullptr, &targets_[i]))) {
          views_[1].Reset(); return nullptr;
        }
      }
      allocation_width_ = desc.Width; allocation_height_ = desc.Height;
    }
    temporal::ContextScope restore(context, state_.Get());
    float values[]{float(width), float(height), float(desc.Width), float(desc.Height),
        std::clamp(effects[0],0.f,1.f),std::clamp(effects[1],0.f,1.f),0,0};
    auto* constants = constants_.Get(); auto* sampler = sampler_.Get();
    context->PSSetConstantBuffers(0, 1, &constants);
    context->PSSetSamplers(0, 1, &sampler);
    context->PSSetShaderResources(88, 1, &water_state);
    context->VSSetShader(vertex_.Get(), nullptr, 0);
    context->PSSetShader(pixel_.Get(), nullptr, 0);
    const D3D11_VIEWPORT viewport{0,0,float(width),float(height),0,1};
    context->RSSetViewports(1, &viewport);
    context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    // Horizontal blur + RGB separation, then vertical blur.
    // Each pass is spatial only and leaves the green-channel image unwarped.
    for (UINT i=0;i<2;++i) {
      values[6]=float(i);
      context->UpdateSubresource(constants_.Get(),0,nullptr,values,0,0);
      auto* target=targets_[i].Get();
      context->OMSetRenderTargets(1,&target,nullptr);
      auto* input=i==0?scene:views_[0].Get();
      context->PSSetShaderResources(0,1,&input);
      context->Draw(3,0);
    }
    applied_frame = frame;
    return views_[1].Get();
  }
 private:
  ComPtr<ID3DDeviceContextState> state_;
  ComPtr<ID3D11VertexShader> vertex_;
  ComPtr<ID3D11PixelShader> pixel_;
  ComPtr<ID3D11Buffer> constants_;
  ComPtr<ID3D11SamplerState> sampler_;
  std::array<ComPtr<ID3D11Texture2D>,2> textures_;
  std::array<ComPtr<ID3D11ShaderResourceView>,2> views_;
  std::array<ComPtr<ID3D11RenderTargetView>,2> targets_;
  UINT allocation_width_ = 0, allocation_height_ = 0;
};
}  // namespace witcher3classic::water
