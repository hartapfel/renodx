/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <array>
#include "../temporal/context.hpp"
#include "settings.hpp"
namespace witcher3classic::water {
using Microsoft::WRL::ComPtr;
// Preserve lit opaque color BEFORE atmospheric fog. Reusing the later refraction
// copy would integrate air to the river bed, then water, then air again. A single
// GPU copy per rendered frame avoids inverse-fog division and all CPU readbacks.
class Pipeline {
 public:
  uint64_t captured_frame = UINT64_MAX;
  ID3D11ShaderResourceView* FrameView() const { return frame_view_.Get(); }
  UINT Width() const { return width_; }
  UINT Height() const { return height_; }
  bool Capture(ID3D11DeviceContext1* context, ID3D11ShaderResourceView* source,
               ID3D11Buffer* frame, UINT width, UINT height, uint64_t frame_id) {
    if (captured_frame==frame_id) return true;
    captured_frame=UINT64_MAX;
    if (!source || !frame || width<1 || height<1) return false;
    D3D11_SHADER_RESOURCE_VIEW_DESC view_desc; source->GetDesc(&view_desc);
    if (view_desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2D || view_desc.Texture2D.MostDetailedMip!=0) return false;
    ComPtr<ID3D11Resource> resource; source->GetResource(&resource);
    ComPtr<ID3D11Texture2D> texture;
    if (FAILED(resource.As(&texture))) return false;
    D3D11_TEXTURE2D_DESC desc; texture->GetDesc(&desc);
    D3D11_BUFFER_DESC frame_desc; frame->GetDesc(&frame_desc);
    if (desc.SampleDesc.Count!=1 || desc.ArraySize!=1 || width>desc.Width || height>desc.Height
        || frame_desc.ByteWidth!=4304
        || (desc.Format!=DXGI_FORMAT_R16G16B16A16_FLOAT && desc.Format!=DXGI_FORMAT_R32G32B32A32_FLOAT)) return false;
    ComPtr<ID3D11Device> device; context->GetDevice(&device);
    if (!scene_ || width_!=width || height_!=height || format_!=desc.Format) {
      scene_.Reset(); scene_view_.Reset();
      desc.Width=width; desc.Height=height; desc.MipLevels=1;
      desc.Usage=D3D11_USAGE_DEFAULT; desc.BindFlags=D3D11_BIND_SHADER_RESOURCE;
      desc.CPUAccessFlags=desc.MiscFlags=0;
      if (FAILED(device->CreateTexture2D(&desc,nullptr,&scene_))
          || FAILED(device->CreateShaderResourceView(scene_.Get(),nullptr,&scene_view_))) { scene_.Reset(); return false; }
      width_=width; height_=height; format_=desc.Format;
    }
    if (!frame_view_) {
      frame_.Reset(); parameters_.Reset(); parameter_view_.Reset(); sampler_.Reset();
      D3D11_BUFFER_DESC buffer{};
      buffer.ByteWidth=4304; buffer.BindFlags=D3D11_BIND_SHADER_RESOURCE;
      buffer.MiscFlags=D3D11_RESOURCE_MISC_BUFFER_STRUCTURED; buffer.StructureByteStride=16;
      if (FAILED(device->CreateBuffer(&buffer,nullptr,&frame_))) return false;
      buffer.ByteWidth=16;
      if (FAILED(device->CreateBuffer(&buffer,nullptr,&parameters_))
          || FAILED(device->CreateShaderResourceView(parameters_.Get(),nullptr,&parameter_view_))) return false;
      D3D11_SAMPLER_DESC sampler{};
      sampler.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;
      sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;
      sampler.MaxLOD=D3D11_FLOAT32_MAX;
      if (FAILED(device->CreateSamplerState(&sampler,&sampler_))
          || FAILED(device->CreateShaderResourceView(frame_.Get(),nullptr,&frame_view_))) return false;
    }
    const D3D11_BOX box{0,0,0,width,height,1};
    context->CopySubresourceRegion(scene_.Get(),0,0,0,0,texture.Get(),0,&box);
    context->CopyResource(frame_.Get(),frame);
    const std::array<float,4> parameters{float(width),float(height),std::clamp(underwater_density,0.f,4.f),1.f};
    context->UpdateSubresource(parameters_.Get(),0,nullptr,parameters.data(),0,0);
    captured_frame=frame_id;
    return true;
  }
  bool Bind(ID3D11DeviceContext1* context,uint64_t frame_id) {
    if (bound_ || captured_frame!=frame_id || !frame_view_) return false;
    context->PSGetShaderResources(113,3,saved_.data());
    context->PSGetSamplers(12,1,&saved_sampler_);
    ID3D11ShaderResourceView* views[]={frame_view_.Get(),scene_view_.Get(),parameter_view_.Get()};
    context->PSSetShaderResources(113,3,views);
    context->PSSetSamplers(12,1,sampler_.GetAddressOf());
    bound_=true;
    return true;
  }
  void Restore(ID3D11DeviceContext1* context) {
    if (!bound_) return;
    context->PSSetShaderResources(113,3,saved_.data());
    context->PSSetSamplers(12,1,saved_sampler_.GetAddressOf());
    for (auto*& view:saved_) { if (view) view->Release(); view=nullptr; }
    saved_sampler_.Reset(); bound_=false;
  }
 private:
  UINT width_=0,height_=0;
  DXGI_FORMAT format_=DXGI_FORMAT_UNKNOWN;
  bool bound_=false;
  ComPtr<ID3D11Texture2D> scene_;
  ComPtr<ID3D11Buffer> frame_,parameters_;
  ComPtr<ID3D11ShaderResourceView> frame_view_,scene_view_,parameter_view_;
  ComPtr<ID3D11SamplerState> sampler_,saved_sampler_;
  std::array<ID3D11ShaderResourceView*,3> saved_{};
};
}  // namespace witcher3classic::water
