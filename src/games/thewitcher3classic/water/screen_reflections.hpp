/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <embed/0xF3C10002.h>
#include <embed/0xF3C70000.h>
#include <embed/0xF3C70001.h>
#include <embed/0xF3C70002.h>
#include "../temporal/context.hpp"
#include "settings.hpp"
#include "../graphics_profile.hpp"

namespace witcher3classic::water {
using Microsoft::WRL::ComPtr;
// Private SSR resources: never resize pooled game textures. The original chain
// stays current for padding, live comparisons and failure/toggle fallback.
class ScreenReflections {
  struct Image {
    ComPtr<ID3D11Texture2D> texture;
    ComPtr<ID3D11ShaderResourceView> view;
    ComPtr<ID3D11RenderTargetView> target;
    ComPtr<ID3D11UnorderedAccessView> output;
    bool Create(ID3D11Device* device,UINT width,UINT height,DXGI_FORMAT format,bool mips=false) {
      *this={};
      D3D11_TEXTURE2D_DESC d{width,height,mips?0u:1u,1,format,{1,0},D3D11_USAGE_DEFAULT,
          D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_RENDER_TARGET|D3D11_BIND_UNORDERED_ACCESS,
          0,mips?D3D11_RESOURCE_MISC_GENERATE_MIPS:0u};
      D3D11_UNORDERED_ACCESS_VIEW_DESC u{};u.Format=format;u.ViewDimension=D3D11_UAV_DIMENSION_TEXTURE2D;
      D3D11_RENDER_TARGET_VIEW_DESC r{};r.Format=format;r.ViewDimension=D3D11_RTV_DIMENSION_TEXTURE2D;
      return SUCCEEDED(device->CreateTexture2D(&d,nullptr,&texture))
          && SUCCEEDED(device->CreateShaderResourceView(texture.Get(),nullptr,&view))
          && SUCCEEDED(device->CreateRenderTargetView(texture.Get(),&r,&target))
          && SUCCEEDED(device->CreateUnorderedAccessView(texture.Get(),&u,&output));
    }
  };
  ComPtr<ID3D11Device> device_;
  ComPtr<ID3DDeviceContextState> isolated_;
  ComPtr<ID3D11VertexShader> vertex_;
  ComPtr<ID3D11PixelShader> trace_;
  ComPtr<ID3D11ComputeShader> prepare_,filter_;
  ComPtr<ID3D11RasterizerState> raster_;
  ComPtr<ID3D11SamplerState> linear_;
  ComPtr<ID3D11Buffer> controls_,input_parameters_,current_frame_,previous_frame_,composite_size_;
  ComPtr<ID3D11ShaderResourceView> input_parameters_view_,current_frame_view_,previous_frame_view_;
  Image input_,emission_,raw_,guide_;
  std::array<Image,2> history_;
  Image history_guide_;
  ComPtr<ID3D11Texture2D> opaque_depth_;
  ComPtr<ID3D11ShaderResourceView> opaque_view_;
  ComPtr<ID3D11ShaderResourceView> saved_scene_;
  ComPtr<ID3D11Buffer> saved_size_;
  UINT width_=0,height_=0,render_width_=0,render_height_=0,ping_=0;
  float stride_=1.f;
  float native_width_=0.f,native_height_=0.f;
  bool full_=false,stable_=false,bound_=false;
  UINT saved_size_offset_=0,saved_size_count_=0;
  uint64_t prepared_=UINT64_MAX,traced_=UINT64_MAX,filtered_=UINT64_MAX;

  bool Initialize(ID3D11DeviceContext1* context) {
    if(isolated_)return true;
    context->GetDevice(&device_);
    D3D11_BUFFER_DESC cb{48,D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
    D3D11_SAMPLER_DESC s{};s.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    s.AddressU=s.AddressV=s.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;s.MaxLOD=D3D11_FLOAT32_MAX;
    D3D11_RASTERIZER_DESC r=CD3D11_RASTERIZER_DESC(D3D11_DEFAULT);r.CullMode=D3D11_CULL_NONE;
    if(FAILED(device_->CreateComputeShader(__0xF3C70000.data(),__0xF3C70000.size(),nullptr,&prepare_))
        ||FAILED(device_->CreateComputeShader(__0xF3C70002.data(),__0xF3C70002.size(),nullptr,&filter_))
        ||FAILED(device_->CreatePixelShader(__0xF3C70001.data(),__0xF3C70001.size(),nullptr,&trace_))
        ||FAILED(device_->CreateVertexShader(__0xF3C10002.data(),__0xF3C10002.size(),nullptr,&vertex_))
        ||FAILED(device_->CreateSamplerState(&s,&linear_))
        ||FAILED(device_->CreateRasterizerState(&r,&raster_))
        ||FAILED(device_->CreateBuffer(&cb,nullptr,&controls_)))return false;
    cb.ByteWidth=16;
    if(FAILED(device_->CreateBuffer(&cb,nullptr,&composite_size_)))return false;
    D3D11_BUFFER_DESC b{4304,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
    if(FAILED(device_->CreateBuffer(&b,nullptr,&current_frame_))
        ||FAILED(device_->CreateBuffer(&b,nullptr,&previous_frame_))
        ||FAILED(device_->CreateShaderResourceView(current_frame_.Get(),nullptr,&current_frame_view_))
        ||FAILED(device_->CreateShaderResourceView(previous_frame_.Get(),nullptr,&previous_frame_view_)))return false;
    b.ByteWidth=16;
    return SUCCEEDED(device_->CreateBuffer(&b,nullptr,&input_parameters_))
        &&SUCCEEDED(device_->CreateShaderResourceView(input_parameters_.Get(),nullptr,&input_parameters_view_))
        &&SUCCEEDED(temporal::CreateIsolatedState(device_.Get(),&isolated_));
  }

 public:
  static bool Enabled() {return ssr_quality!=0.f || ssr_stabilization!=0.f;}
  void Restore(ID3D11DeviceContext1* context) {
    if(!bound_)return;
    context->PSSetShaderResources(0,1,saved_scene_.GetAddressOf());
    context->PSSetConstantBuffers1(3,1,saved_size_.GetAddressOf(),&saved_size_offset_,&saved_size_count_);
    saved_scene_.Reset();saved_size_.Reset();bound_=false;
  }
  void Invalidate() {prepared_=traced_=filtered_=UINT64_MAX;}
  // Called before water writes depth. current render dimensions come from the
  // submitted primary view, not the output-sized allocation used by DLSS.
  bool Prepare(ID3D11DeviceContext1* context,UINT render_width,UINT render_height,
               uint64_t frame,bool late_emission_bound) {
    if(!Enabled()) {Invalidate();return false;}
    if(prepared_==frame ||!render_width ||!render_height ||!Initialize(context))return false;
    profiling::Scope profile(context, "Water SSR preparation", render_width, render_height);
    prepared_=traced_=UINT64_MAX;
    D3D11_VIEWPORT vp{};UINT count=1;context->RSGetViewports(&count,&vp);
    if(count!=1 ||vp.TopLeftX ||vp.TopLeftY ||vp.Width<1 ||vp.Height<1)return false;
    const bool full=ssr_quality!=0.f,stable=ssr_stabilization!=0.f;
    const UINT divisor=ssr_quality>=1.5f?1u:2u;
    const UINT width=full?(render_width+divisor-1)/divisor:UINT(vp.Width);
    const UINT height=full?(render_height+divisor-1)/divisor:UINT(vp.Height);
    if(width>8192 ||height>8192 ||width>render_width ||height>render_height)return false;
    ComPtr<ID3D11Buffer> cb3,frame_buffer;
    UINT offset=0,n=0;context->PSGetConstantBuffers1(12,1,&frame_buffer,&offset,&n);
    if(!frame_buffer ||offset)return false;
    D3D11_BUFFER_DESC b{};frame_buffer->GetDesc(&b);if(b.ByteWidth!=4304)return false;
    context->PSGetConstantBuffers1(3,1,&cb3,&offset,&n);if(!cb3 ||offset)return false;
    std::array<ComPtr<ID3D11ShaderResourceView>,7> old;
    if(late_emission_bound)for(UINT i=0;i<7;++i)context->PSGetShaderResources(108+i,1,&old[i]);
    ComPtr<ID3D11ShaderResourceView> scene,depth;
    context->PSGetShaderResources(0,1,&scene);context->PSGetShaderResources(1,1,&depth);
    if(!scene ||!depth)return false;
    D3D11_SHADER_RESOURCE_VIEW_DESC scene_view{};scene->GetDesc(&scene_view);
    if(scene_view.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2D ||scene_view.Texture2D.MostDetailedMip
        ||(scene_view.Format!=DXGI_FORMAT_R16G16B16A16_FLOAT
          &&scene_view.Format!=DXGI_FORMAT_R32G32B32A32_FLOAT &&scene_view.Format!=DXGI_FORMAT_R11G11B10_FLOAT))return false;
    ComPtr<ID3D11Resource> scene_resource;ComPtr<ID3D11Texture2D> scene_texture;
    scene->GetResource(&scene_resource);if(FAILED(scene_resource.As(&scene_texture)))return false;
    D3D11_TEXTURE2D_DESC scene_desc{};scene_texture->GetDesc(&scene_desc);
    if(scene_desc.SampleDesc.Count!=1 ||scene_desc.ArraySize!=1
        ||render_width>scene_desc.Width ||render_height>scene_desc.Height)return false;
    D3D11_SHADER_RESOURCE_VIEW_DESC dv{};depth->GetDesc(&dv);
    ComPtr<ID3D11Resource> resource;ComPtr<ID3D11Texture2D> texture;
    depth->GetResource(&resource);if(FAILED(resource.As(&texture)))return false;
    D3D11_TEXTURE2D_DESC d{},prior{};texture->GetDesc(&d);
    if(d.SampleDesc.Count!=1 ||d.ArraySize!=1 ||d.MipLevels!=1
        ||dv.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2D ||dv.Texture2D.MostDetailedMip
        ||render_width>d.Width ||render_height>d.Height)return false;
    if(opaque_depth_)opaque_depth_->GetDesc(&prior);
    if(full && (!opaque_depth_ ||prior.Width!=d.Width ||prior.Height!=d.Height ||prior.Format!=d.Format)) {
      opaque_depth_.Reset();opaque_view_.Reset();
      d.Usage=D3D11_USAGE_DEFAULT;d.BindFlags=D3D11_BIND_SHADER_RESOURCE;d.CPUAccessFlags=d.MiscFlags=0;
      if(FAILED(device_->CreateTexture2D(&d,nullptr,&opaque_depth_))
          ||FAILED(device_->CreateShaderResourceView(opaque_depth_.Get(),&dv,&opaque_view_)))return false;
    }
    if(width_!=width ||height_!=height ||render_width_!=render_width ||render_height_!=render_height
        ||full_!=full ||!history_[1].view) {
      Invalidate();width_=height_=0;
      if(!input_.Create(device_.Get(),width,height,DXGI_FORMAT_R16G16B16A16_FLOAT)
          ||!emission_.Create(device_.Get(),width,height,DXGI_FORMAT_R32_FLOAT)
          ||!raw_.Create(device_.Get(),width,height,DXGI_FORMAT_R16G16B16A16_FLOAT)
          ||!guide_.Create(device_.Get(),width,height,DXGI_FORMAT_R32G32_FLOAT)
          ||!history_guide_.Create(device_.Get(),width,height,DXGI_FORMAT_R32G32_FLOAT))return false;
      for(UINT i=0;i<2;++i)
        if(!history_[i].Create(device_.Get(),width,height,DXGI_FORMAT_R16G16B16A16_FLOAT,true))return false;
      width_=width;height_=height;render_width_=render_width;render_height_=render_height;full_=full;
    }
    if(stable_!=stable)filtered_=UINT64_MAX;
    stable_=stable;stride_=std::max(1.f,float(width)/vp.Width);
    native_width_=vp.Width;native_height_=vp.Height;
    context->CopyResource(current_frame_.Get(),frame_buffer.Get());
    if(full)context->CopyResource(opaque_depth_.Get(),texture.Get());
    temporal::ContextScope scope(context,isolated_.Get());
    const std::array<float,12> controls{float(width),float(height),float(render_width),float(render_height)};
    context->UpdateSubresource(controls_.Get(),0,nullptr,controls.data(),0,0);
    const std::array<float,4> parameters{float(render_width),float(render_height),0,0};
    context->UpdateSubresource(input_parameters_.Get(),0,nullptr,parameters.data(),0,0);
    ID3D11ShaderResourceView* sources[]={depth.Get(),old[1].Get(),old[2].Get(),old[3].Get(),
        current_frame_view_.Get(),late_emission_bound?old[5].Get():input_parameters_view_.Get(),old[6].Get()};
    context->CSSetShaderResources(0,1,scene.GetAddressOf());context->CSSetShaderResources(108,7,sources);
    context->CSSetSamplers(12,1,linear_.GetAddressOf());
    context->CSSetConstantBuffers(3,1,cb3.GetAddressOf());context->CSSetConstantBuffers(4,1,controls_.GetAddressOf());
    ID3D11UnorderedAccessView* outputs[]={input_.output.Get(),emission_.output.Get()};
    context->CSSetUnorderedAccessViews(0,2,outputs,nullptr);context->CSSetShader(prepare_.Get(),nullptr,0);
    context->Dispatch((width+7)/8,(height+7)/8,1);prepared_=frame;return true;
  }

  bool Trace(ID3D11DeviceContext1* context,uint64_t frame) {
    if(!Enabled() ||prepared_!=frame ||traced_==frame)return false;
    std::array<ComPtr<ID3D11ShaderResourceView>,24> views;
    for(UINT i=0;i<views.size();++i)context->PSGetShaderResources(i,1,&views[i]);
    if(!views[0] ||!views[2] ||!views[4] ||!views[5] ||!views[23])return false;
    std::array<ComPtr<ID3D11SamplerState>,12> samplers;
    for(UINT i: {0u,1u,11u})context->PSGetSamplers(i,1,&samplers[i]);
    ComPtr<ID3D11Buffer> cb3,cb12;UINT offset=0,n=0;
    context->PSGetConstantBuffers1(3,1,&cb3,&offset,&n);if(!cb3 ||offset)return false;
    context->PSGetConstantBuffers1(12,1,&cb12,&offset,&n);if(!cb12 ||offset)return false;
    D3D11_BUFFER_DESC b{};cb3->GetDesc(&b);if(b.ByteWidth<208)return false;
    auto* depth=full_?opaque_view_.Get():views[2].Get();
    ComPtr<ID3D11Resource> resource;ComPtr<ID3D11Texture2D> texture;depth->GetResource(&resource);
    if(FAILED(resource.As(&texture)))return false;
    D3D11_TEXTURE2D_DESC d{};texture->GetDesc(&d);
    temporal::ContextScope scope(context,isolated_.Get());
    const std::array<float,12> controls{float(width_),float(height_),float(render_width_),float(render_height_),
        float(full_?render_width_:width_)/d.Width,float(full_?render_height_:height_)/d.Height,stride_,full_?1.f:0.f};
    context->UpdateSubresource(controls_.Get(),0,nullptr,controls.data(),0,0);
    ID3D11ShaderResourceView* sources[24]{};
    for(UINT i=0;i<views.size();++i)sources[i]=views[i].Get();
    sources[1]=input_.view.Get();sources[2]=depth;sources[3]=nullptr;
    context->PSSetShaderResources(0,24,sources);context->PSSetShaderResources(114,1,emission_.view.GetAddressOf());
    for(UINT i:{0u,1u,11u})context->PSSetSamplers(i,1,samplers[i].GetAddressOf());
    context->PSSetConstantBuffers(3,1,cb3.GetAddressOf());context->PSSetConstantBuffers(4,1,controls_.GetAddressOf());
    context->PSSetConstantBuffers(12,1,cb12.GetAddressOf());
    ID3D11RenderTargetView* targets[]={raw_.target.Get(),guide_.target.Get()};
    context->OMSetRenderTargets(2,targets,nullptr);context->RSSetState(raster_.Get());
    const D3D11_VIEWPORT viewport{0,0,float(width_),float(height_),0,1};context->RSSetViewports(1,&viewport);
    context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    context->VSSetShader(vertex_.Get(),nullptr,0);context->PSSetShader(trace_.Get(),nullptr,0);
    {
      profiling::Scope profile(context, "Water SSR trace", width_, height_);
      context->Draw(3,0);
    }
    traced_=frame;return true;
  }

  bool Composite(ID3D11DeviceContext1* context,uint64_t frame) {
    if(!Enabled() ||traced_!=frame ||filtered_==frame ||bound_)return false;
    profiling::Scope profile(context, "Water SSR history and mips", width_, height_);
    ComPtr<ID3D11Buffer> native_size;context->PSGetConstantBuffers(3,1,&native_size);
    ComPtr<ID3D11ShaderResourceView> padding;context->PSGetShaderResources(0,1,&padding);
    if(!native_size ||!padding)return false;
    ComPtr<ID3D11Resource> resource;ComPtr<ID3D11Texture2D> texture;padding->GetResource(&resource);
    if(FAILED(resource.As(&texture)))return false;
    D3D11_TEXTURE2D_DESC d{};texture->GetDesc(&d);
    // Native SSR is quarter resolution in each dimension. Use the active
    // viewport rather than reading constants back or assuming pool==viewport.
    const UINT next=ping_^1;
    {
      temporal::ContextScope scope(context,isolated_.Get());
      const std::array<float,12> controls{float(width_),float(height_),float(render_width_),float(render_height_),
          filtered_!=UINT64_MAX &&filtered_+1==frame?1.f:0.f,stable_?1.f:0.f,native_width_/d.Width,native_height_/d.Height};
      context->UpdateSubresource(controls_.Get(),0,nullptr,controls.data(),0,0);
      context->CSSetConstantBuffers(0,1,controls_.GetAddressOf());
      ID3D11ShaderResourceView* sources[]={raw_.view.Get(),guide_.view.Get(),history_[ping_].view.Get(),
          history_guide_.view.Get(),current_frame_view_.Get(),previous_frame_view_.Get(),padding.Get()};
      context->CSSetShaderResources(0,7,sources);context->CSSetSamplers(0,1,linear_.GetAddressOf());
      context->CSSetUnorderedAccessViews(0,1,history_[next].output.GetAddressOf(),nullptr);
      context->CSSetShader(filter_.Get(),nullptr,0);context->Dispatch((width_+7)/8,(height_+7)/8,1);
      ID3D11UnorderedAccessView* clear=nullptr;context->CSSetUnorderedAccessViews(0,1,&clear,nullptr);
      context->GenerateMips(history_[next].view.Get());
      // Trace and history need only current/previous guides. Exchange their
      // ownership after filtering instead of a full-image copy and third guide.
      std::swap(history_guide_,guide_);
      context->CopyResource(previous_frame_.Get(),current_frame_.Get());
    }
    ping_=next;filtered_=frame;
    const std::array<float,4> size{float(width_),float(height_),float(width_),float(height_)};
    context->UpdateSubresource(composite_size_.Get(),0,nullptr,size.data(),0,0);
    context->PSGetShaderResources(0,1,&saved_scene_);
    context->PSGetConstantBuffers1(3,1,&saved_size_,&saved_size_offset_,&saved_size_count_);
    context->PSSetShaderResources(0,1,history_[ping_].view.GetAddressOf());
    context->PSSetConstantBuffers(3,1,composite_size_.GetAddressOf());bound_=true;return true;
  }
};
}  // namespace witcher3classic::water
