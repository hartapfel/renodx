/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include "../temporal/context.hpp"
#include "particle_depth.hpp"
namespace witcher3classic::water {
using Microsoft::WRL::ComPtr;
// Feed late transparent effects to NEXT frame's existing SSR input, as BlitzFX
// does. Particle depth supplements its opaque intersections without a second
// trace, geometry replay or extra fullscreen pass.
class Reflections {
  ParticleDepth particles_;
  ComPtr<ID3D11Texture2D> trace_depth_;
  ComPtr<ID3D11RenderTargetView> trace_target_;
  ComPtr<ID3D11ShaderResourceView> trace_view_,saved_trace_;
  std::array<ID3D11RenderTargetView*,8> saved_targets_{};
  ComPtr<ID3D11DepthStencilView> saved_target_depth_;
  struct InputBlend { ComPtr<ID3D11BlendState> source,capture; };
  std::unordered_map<ID3D11BlendState*,InputBlend> input_blends_;
  ComPtr<ID3D11BlendState> saved_blend_;
  float blend_factor_[4]{};
  UINT sample_mask_=0;
  uint64_t trace_frame_=UINT64_MAX;
  bool trace_bound_=false;
  ComPtr<ID3D11Texture2D> color_,depth_;
  ComPtr<ID3D11ShaderResourceView> color_view_,depth_view_,frame_view_,parameter_view_;
  ComPtr<ID3D11Buffer> frame_,parameters_;
  ComPtr<ID3D11SamplerState> sampler_,saved_sampler_;
  ComPtr<ID3D11ShaderResourceView> current_depth_;
  std::array<ID3D11ShaderResourceView*,7> saved_{};
  UINT width_=0,height_=0;
  DXGI_FORMAT color_format_=DXGI_FORMAT_UNKNOWN,depth_format_=DXGI_FORMAT_UNKNOWN;
  uint64_t captured_=UINT64_MAX,requested_=UINT64_MAX,depth_frame_=UINT64_MAX;
  bool bound_=false;
 public:
  void Invalidate() { captured_=requested_=depth_frame_=trace_frame_=UINT64_MAX;particles_.Invalidate(); }
  bool BindParticle(ID3D11DeviceContext1* context,uint64_t id) {
    return requested_==id && captured_!=id && particles_.Bind(context,id);
  }
  bool BindTrace(ID3D11DeviceContext1* context,uint64_t id) {
    if(trace_bound_ || trace_frame_!=id || !trace_view_)return false;
    context->PSGetShaderResources(114,1,&saved_trace_);
    context->PSSetShaderResources(114,1,trace_view_.GetAddressOf());trace_bound_=true;return true;
  }
  bool Bind(ID3D11DeviceContext1* context,ID3D11ShaderResourceView* current_frame,
            UINT width,UINT height,uint64_t id) {
    if(bound_ || !current_frame || !width || !height)return false;
    if(requested_==id)return false;
    requested_=id;
    if(width_!=width || height_!=height) {captured_=depth_frame_=UINT64_MAX;particles_.Invalidate();depth_.Reset();depth_view_.Reset();}
    width_=width;height_=height;
    context->PSGetShaderResources(1,1,&current_depth_);
    if(!current_depth_)return false;
    ComPtr<ID3D11Device> device;context->GetDevice(&device);
    if(!parameter_view_) {
      parameters_.Reset();frame_.Reset();frame_view_.Reset();sampler_.Reset();
      D3D11_BUFFER_DESC d{16,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
      if(FAILED(device->CreateBuffer(&d,nullptr,&parameters_))
          || FAILED(device->CreateShaderResourceView(parameters_.Get(),nullptr,&parameter_view_)))return false;
      d.ByteWidth=4304;
      if(FAILED(device->CreateBuffer(&d,nullptr,&frame_))
          || FAILED(device->CreateShaderResourceView(frame_.Get(),nullptr,&frame_view_))) {parameter_view_.Reset();return false;}
      D3D11_SAMPLER_DESC s{};s.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;
      s.AddressU=s.AddressV=s.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;s.MaxLOD=D3D11_FLOAT32_MAX;
      if(FAILED(device->CreateSamplerState(&s,&sampler_))) {parameter_view_.Reset();return false;}
    }
    const bool valid=captured_!=UINT64_MAX && captured_+1==id && depth_frame_==captured_ && color_view_ && depth_view_;
    context->OMGetRenderTargets(8,saved_targets_.data(),&saved_target_depth_);
    context->OMGetBlendState(&saved_blend_,blend_factor_,&sample_mask_);
    ComPtr<ID3D11Resource> target_resource;ComPtr<ID3D11Texture2D> target_texture;
    if(saved_targets_[0])saved_targets_[0]->GetResource(&target_resource);
    // Keep the original trace (and its single depth fetch) in frames with no
    // captured emission. The extra target is only needed while an effect exists.
    bool output_valid=valid && particles_.frame==captured_ && target_resource
        && SUCCEEDED(target_resource.As(&target_texture));
    for(UINT i=1;i<8;++i)output_valid=output_valid && !saved_targets_[i];
    D3D11_TEXTURE2D_DESC target_desc{},old{};
    if(output_valid) {
      target_texture->GetDesc(&target_desc);if(trace_depth_)trace_depth_->GetDesc(&old);
      output_valid=target_desc.SampleDesc.Count==1 && target_desc.ArraySize==1;
      if(output_valid && (!trace_depth_ || target_desc.Width!=old.Width || target_desc.Height!=old.Height)) {
        trace_depth_.Reset();trace_target_.Reset();trace_view_.Reset();
        target_desc.Format=DXGI_FORMAT_R32_FLOAT;target_desc.MipLevels=1;
        target_desc.BindFlags=D3D11_BIND_RENDER_TARGET|D3D11_BIND_SHADER_RESOURCE;
        target_desc.Usage=D3D11_USAGE_DEFAULT;target_desc.CPUAccessFlags=target_desc.MiscFlags=0;
        output_valid=SUCCEEDED(device->CreateTexture2D(&target_desc,nullptr,&trace_depth_))
            && SUCCEEDED(device->CreateRenderTargetView(trace_depth_.Get(),nullptr,&trace_target_))
            && SUCCEEDED(device->CreateShaderResourceView(trace_depth_.Get(),nullptr,&trace_view_));
        if(!output_valid)trace_depth_.Reset();
      }
    }
    if(output_valid) {
      auto& blend=input_blends_[saved_blend_.Get()];blend.source=saved_blend_;
      if(!blend.capture) {
        D3D11_BLEND_DESC desc=CD3D11_BLEND_DESC(D3D11_DEFAULT);
        if(saved_blend_)saved_blend_->GetDesc(&desc);
        if(!desc.IndependentBlendEnable)for(UINT i=1;i<8;++i)desc.RenderTarget[i]=desc.RenderTarget[0];
        desc.IndependentBlendEnable=TRUE;desc.RenderTarget[1]=CD3D11_BLEND_DESC(D3D11_DEFAULT).RenderTarget[0];
        output_valid=SUCCEEDED(device->CreateBlendState(&desc,&blend.capture));
      }
      if(output_valid) {
        auto targets=saved_targets_;targets[1]=trace_target_.Get();context->OMSetRenderTargets(2,targets.data(),saved_target_depth_.Get());
        context->OMSetBlendState(blend.capture.Get(),blend_factor_,sample_mask_);
      }
    }
    trace_frame_=output_valid?id:UINT64_MAX;
    const std::array<float,4> values{float(width),float(height),valid?1.f:0.f,valid && particles_.frame==captured_?1.f:0.f};
    context->UpdateSubresource(parameters_.Get(),0,nullptr,values.data(),0,0);
    context->PSGetShaderResources(108,7,saved_.data());context->PSGetSamplers(12,1,&saved_sampler_);
    ID3D11ShaderResourceView* views[]={current_depth_.Get(),depth_view_.Get(),color_view_.Get(),frame_view_.Get(),current_frame,parameter_view_.Get(),particles_.View()};
    context->PSSetShaderResources(108,7,views);context->PSSetSamplers(12,1,sampler_.GetAddressOf());bound_=true;
    return true;
  }
  void Restore(ID3D11DeviceContext1* context,bool capture_depth=false) {
    particles_.Restore(context);
    if(trace_bound_) {context->PSSetShaderResources(114,1,saved_trace_.GetAddressOf());saved_trace_.Reset();trace_bound_=false;}
    if(!bound_)return;
    context->OMSetRenderTargets(8,saved_targets_.data(),saved_target_depth_.Get());
    context->OMSetBlendState(saved_blend_.Get(),blend_factor_,sample_mask_);saved_blend_.Reset();
    for(auto*& target:saved_targets_) {if(target)target->Release();target=nullptr;}saved_target_depth_.Reset();
    context->PSSetShaderResources(108,7,saved_.data());context->PSSetSamplers(12,1,saved_sampler_.GetAddressOf());
    for(auto*& view:saved_) {if(view)view->Release();view=nullptr;}saved_sampler_.Reset();bound_=false;
    if(!capture_depth) {current_depth_.Reset();return;}
    // AFTER the SSR input draw, BEFORE water modifies depth. The old depth was
    // consumed by the draw, so one reusable history texture suffices.
    depth_frame_=UINT64_MAX;
    ComPtr<ID3D11Resource> resource;ComPtr<ID3D11Texture2D> texture;
    current_depth_->GetResource(&resource);
    D3D11_SHADER_RESOURCE_VIEW_DESC view_desc;current_depth_->GetDesc(&view_desc);
    current_depth_.Reset();
    if(FAILED(resource.As(&texture)) || view_desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2D
        || view_desc.Texture2D.MostDetailedMip!=0)return;
    D3D11_TEXTURE2D_DESC d;texture->GetDesc(&d);
    if(d.SampleDesc.Count!=1 || d.ArraySize!=1 || d.MipLevels!=1 || width_>d.Width || height_>d.Height)return;
    D3D11_TEXTURE2D_DESC old{};if(depth_)depth_->GetDesc(&old);
    if(!depth_ || depth_format_!=d.Format || old.Width!=d.Width || old.Height!=d.Height) {
      depth_.Reset();depth_view_.Reset();depth_format_=d.Format;
      // D3D11 depth-stencil sources may only be copied as whole subresources.
      // Keep the allocation extent even with a smaller DLSS render viewport.
      d.Usage=D3D11_USAGE_DEFAULT;
      d.BindFlags=D3D11_BIND_SHADER_RESOURCE;d.CPUAccessFlags=d.MiscFlags=0;view_desc.Texture2D.MipLevels=1;
      ComPtr<ID3D11Device> device;context->GetDevice(&device);
      if(FAILED(device->CreateTexture2D(&d,nullptr,&depth_))
          || FAILED(device->CreateShaderResourceView(depth_.Get(),&view_desc,&depth_view_))) {depth_.Reset();return;}
    }
    context->CopyResource(depth_.Get(),texture.Get());depth_frame_=requested_;
  }
  bool Capture(ID3D11DeviceContext1* context,ID3D11ShaderResourceView* source,
               ID3D11ShaderResourceView* current_frame,uint64_t id) {
    if(requested_!=id || depth_frame_!=id || captured_==id || !source || !current_frame || !frame_)return false;
    captured_=UINT64_MAX;
    ComPtr<ID3D11Resource> resource,frame_resource;ComPtr<ID3D11Texture2D> texture;
    source->GetResource(&resource);current_frame->GetResource(&frame_resource);
    if(FAILED(resource.As(&texture)))return false;
    D3D11_TEXTURE2D_DESC d;texture->GetDesc(&d);
    D3D11_SHADER_RESOURCE_VIEW_DESC view_desc;source->GetDesc(&view_desc);
    if(view_desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2D || view_desc.Texture2D.MostDetailedMip!=0
        || d.SampleDesc.Count!=1 || d.ArraySize!=1 || width_>d.Width || height_>d.Height
        || (d.Format!=DXGI_FORMAT_R11G11B10_FLOAT && d.Format!=DXGI_FORMAT_R16G16B16A16_FLOAT
            && d.Format!=DXGI_FORMAT_R32G32B32A32_FLOAT))return false;
    D3D11_TEXTURE2D_DESC old{};if(color_)color_->GetDesc(&old);
    if(!color_ || color_format_!=d.Format || old.Width!=width_ || old.Height!=height_) {
      color_.Reset();color_view_.Reset();color_format_=d.Format;
      d.Width=width_;d.Height=height_;d.MipLevels=1;d.Usage=D3D11_USAGE_DEFAULT;
      d.BindFlags=D3D11_BIND_SHADER_RESOURCE;d.CPUAccessFlags=d.MiscFlags=0;
      ComPtr<ID3D11Device> device;context->GetDevice(&device);
      if(FAILED(device->CreateTexture2D(&d,nullptr,&color_))
          || FAILED(device->CreateShaderResourceView(color_.Get(),nullptr,&color_view_))) {color_.Reset();return false;}
    }
    const D3D11_BOX box{0,0,0,width_,height_,1};
    context->CopySubresourceRegion(color_.Get(),0,0,0,0,texture.Get(),0,&box);
    context->CopyResource(frame_.Get(),frame_resource.Get());captured_=id;return true;
  }
};
}  // namespace witcher3classic::water
