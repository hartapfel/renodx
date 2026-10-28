/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include <unordered_map>
#include "../temporal/context.hpp"
namespace witcher3classic::water {
using Microsoft::WRL::ComPtr;
// An extra scalar target on the original emissive draws. The native depth,
// color, blend and shader coverage remain unchanged. Reused by next frame SSR.
class ParticleDepth {
  ComPtr<ID3D11Texture2D> texture_;
  ComPtr<ID3D11RenderTargetView> target_;
  ComPtr<ID3D11ShaderResourceView> view_;
  struct Blend { ComPtr<ID3D11BlendState> source, capture; };
  std::unordered_map<ID3D11BlendState*, Blend> blends_;
  std::array<ID3D11RenderTargetView*,8> saved_targets_{};
  ComPtr<ID3D11DepthStencilView> saved_depth_;
  ComPtr<ID3D11BlendState> saved_blend_;
  float factors_[4]{};
  UINT sample_mask_=0;
  bool bound_=false;
 public:
  uint64_t frame=UINT64_MAX;
  ID3D11ShaderResourceView* View() const { return view_.Get(); }
  void Invalidate() { frame=UINT64_MAX; }
  bool Bind(ID3D11DeviceContext1* context,uint64_t id) {
    if(bound_)return false;
    context->OMGetRenderTargets(8,saved_targets_.data(),&saved_depth_);
    context->OMGetBlendState(&saved_blend_,factors_,&sample_mask_);bound_=true;
    if(!saved_targets_[0] || saved_targets_[4] || saved_targets_[5] || saved_targets_[6] || saved_targets_[7]) {Restore(context);return false;}
    ComPtr<ID3D11Resource> resource;ComPtr<ID3D11Texture2D> source;
    saved_targets_[0]->GetResource(&resource);
    if(FAILED(resource.As(&source))) {Restore(context);return false;}
    D3D11_TEXTURE2D_DESC desc{},old{};source->GetDesc(&desc);
    if(desc.SampleDesc.Count!=1 || desc.ArraySize!=1) {Restore(context);return false;}
    D3D11_BLEND_DESC blend=CD3D11_BLEND_DESC(D3D11_DEFAULT);
    if(saved_blend_)saved_blend_->GetDesc(&blend);
    const auto& native=blend.RenderTarget[0];
    if(!native.BlendEnable || native.SrcBlend!=D3D11_BLEND_ONE
        || (native.DestBlend!=D3D11_BLEND_ONE && native.DestBlend!=D3D11_BLEND_INV_SRC_ALPHA)
        || native.BlendOp!=D3D11_BLEND_OP_ADD) {Restore(context);return false;}
    ComPtr<ID3D11Device> device;context->GetDevice(&device);
    if(texture_)texture_->GetDesc(&old);
    if(!texture_ || desc.Width!=old.Width || desc.Height!=old.Height) {
      texture_.Reset();target_.Reset();view_.Reset();frame=UINT64_MAX;
      desc.MipLevels=1;desc.Format=DXGI_FORMAT_R16_FLOAT;desc.Usage=D3D11_USAGE_DEFAULT;
      desc.BindFlags=D3D11_BIND_RENDER_TARGET|D3D11_BIND_SHADER_RESOURCE;desc.CPUAccessFlags=desc.MiscFlags=0;
      if(FAILED(device->CreateTexture2D(&desc,nullptr,&texture_))
          || FAILED(device->CreateRenderTargetView(texture_.Get(),nullptr,&target_))
          || FAILED(device->CreateShaderResourceView(texture_.Get(),nullptr,&view_))) {texture_.Reset();Restore(context);return false;}
    }
    auto& cached=blends_[saved_blend_.Get()];cached.source=saved_blend_;
    if(!cached.capture) {
      if(!blend.IndependentBlendEnable)for(UINT i=1;i<8;++i)blend.RenderTarget[i]=blend.RenderTarget[0];
      blend.IndependentBlendEnable=TRUE;
      auto& extra=blend.RenderTarget[4];extra=CD3D11_BLEND_DESC(D3D11_DEFAULT).RenderTarget[0];
      extra.BlendEnable=TRUE;extra.SrcBlend=extra.DestBlend=D3D11_BLEND_ONE;
      extra.BlendOp=D3D11_BLEND_OP_MIN;extra.RenderTargetWriteMask=D3D11_COLOR_WRITE_ENABLE_RED;
      if(FAILED(device->CreateBlendState(&blend,&cached.capture))) {Restore(context);return false;}
    }
    if(frame!=id) {const float empty[4]={65504,65504,65504,65504};context->ClearRenderTargetView(target_.Get(),empty);frame=id;}
    auto targets=saved_targets_;targets[4]=target_.Get();
    context->OMSetRenderTargets(5,targets.data(),saved_depth_.Get());
    context->OMSetBlendState(cached.capture.Get(),factors_,sample_mask_);return true;
  }
  void Restore(ID3D11DeviceContext1* context) {
    if(!bound_)return;
    context->OMSetRenderTargets(8,saved_targets_.data(),saved_depth_.Get());
    context->OMSetBlendState(saved_blend_.Get(),factors_,sample_mask_);
    for(auto*& target:saved_targets_) {if(target)target->Release();target=nullptr;}
    saved_depth_.Reset();saved_blend_.Reset();bound_=false;
  }
};
} // namespace witcher3classic::water
