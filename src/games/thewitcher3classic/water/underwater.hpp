/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include "caustics_config.h"
#include <embed/0xF3C50001.h>
#include <embed/0xF3C50002.h>
#include <embed/0xF3C50003.h>
#include <embed/0xF3C50004.h>
#include "../temporal/context.hpp"
namespace witcher3classic::water {
using Microsoft::WRL::ComPtr;
// GPU-only water optics preparation. CPU work is resource validation and a fixed
// number of submissions. No frame readback, worker-thread simulation or geometry
// replay. Indirect work is zero when the GPU classifies the camera above water.
class Underwater {
 public:
  struct Controls { std::array<float,4> medium{.03f,.5f,1,0},quality{2,1,0,0}; };
  uint64_t captured_frame=UINT64_MAX,prepared_frame=UINT64_MAX;
  bool Capture(ID3D11DeviceContext1* context,uint64_t frame_id) {
    if(!Initialize(context))return false;
    captured_frame=UINT64_MAX;
    std::array<ComPtr<ID3D11Buffer>,4> buffers;
    constexpr UINT slots[]={0,4,5,12};
    constexpr UINT minimum[]={15*16,51*16,16,269*16};
    for(size_t i=0;i<buffers.size();++i) {
      UINT offset=0,count=0;
      context->PSGetConstantBuffers1(slots[i],1,&buffers[i],&offset,&count);
      if(!buffers[i] ||offset!=0)return false;
      D3D11_BUFFER_DESC desc{};buffers[i]->GetDesc(&desc);
      if(desc.ByteWidth<minimum[i] || desc.ByteWidth%16)return false;
    }
    std::array<ComPtr<ID3D11ShaderResourceView>,4> textures;
    context->VSGetShaderResources(2,1,&textures[0]);
    context->PSGetShaderResources(5,1,&textures[1]);
    context->PSGetShaderResources(4,1,&textures[2]);
    context->PSGetShaderResources(17,1,&textures[3]);
    for(size_t i=0;i<textures.size();++i) {
      if(!textures[i])return false;
      D3D11_SHADER_RESOURCE_VIEW_DESC desc{};textures[i]->GetDesc(&desc);
      if(desc.ViewDimension!=((i==0 ||i==2)?D3D11_SRV_DIMENSION_TEXTURE2DARRAY:D3D11_SRV_DIMENSION_TEXTURE2D))return false;
    }
    for(size_t i=0;i<buffers.size();++i)
      if(!native_[i].Capture(context,device_.Get(),buffers[i].Get()))return false;
    native_textures_=textures;captured_frame=frame_id;return true;
  }
  bool Prepare(ID3D11DeviceContext1* context,ID3D11Buffer* frame,ID3D11Buffer* lighting,
               ID3D11ShaderResourceView* shadows,uint64_t frame_id,const Controls& controls) {
    prepared_frame=UINT64_MAX;
    if(captured_frame==UINT64_MAX ||captured_frame+1!=frame_id ||!frame ||!lighting ||!shadows ||!Initialize(context))return false;
    D3D11_BUFFER_DESC desc{};frame->GetDesc(&desc);if(desc.ByteWidth!=269*16)return false;
    lighting->GetDesc(&desc);if(desc.ByteWidth<49*16 ||!light_.Capture(context,device_.Get(),lighting)
        ||!frame_.Capture(context,device_.Get(),frame))return false;
    D3D11_SHADER_RESOURCE_VIEW_DESC shadow_desc{};shadows->GetDesc(&shadow_desc);
    if(shadow_desc.ViewDimension!=D3D11_SRV_DIMENSION_TEXTURE2DARRAY)return false;
    shadow_=shadows;
    temporal::ContextScope scope(context,isolated_.Get());
    context->UpdateSubresource(controls_.Get(),0,nullptr,&controls,0,0);
    ID3D11Buffer* constants[]={frame,lighting,controls_.Get()};
    context->CSSetConstantBuffers(0,3,constants);
    auto sources=Views();sources[2]=nullptr;sources[0]=nullptr;sources[3]=native_[3].view.Get();
    context->CSSetShaderResources(86,UINT(sources.size()),sources.data());
    ID3D11SamplerState* samplers[]={linear_.Get(),wrap_.Get()};
    context->CSSetSamplers(13,2,samplers);
    ID3D11UnorderedAccessView* outputs[]={state_.output.Get(),arguments_output_.Get()};
    context->CSSetUnorderedAccessViews(0,2,outputs,nullptr);
    context->CSSetShader(classify_.Get(),nullptr,0);context->Dispatch(1,1,1);
    outputs[0]=outputs[1]=nullptr;context->CSSetUnorderedAccessViews(0,2,outputs,nullptr);
    context->CSSetShaderResources(88,1,state_.view.GetAddressOf());
    outputs[0]=photons_.output.Get();context->CSSetUnorderedAccessViews(0,1,outputs,nullptr);
    context->CSSetShader(refract_.Get(),nullptr,0);context->DispatchIndirect(arguments_.Get(),0);
    outputs[0]=nullptr;context->CSSetUnorderedAccessViews(0,1,outputs,nullptr);
    std::array<ID3D11ShaderResourceView*,13> clear{};context->CSSetShaderResources(86,UINT(clear.size()),clear.data());
    const float black[4]={};context->ClearRenderTargetView(caustics_target_.Get(),black);
    context->OMSetRenderTargets(1,caustics_target_.GetAddressOf(),nullptr);
    context->OMSetBlendState(additive_.Get(),nullptr,UINT_MAX);
    context->RSSetState(raster_.Get());
    D3D11_VIEWPORT viewport{0,0,CLASSIC_CAUSTIC_ATLAS,CLASSIC_CAUSTIC_ATLAS,0,1};context->RSSetViewports(1,&viewport);
    context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    context->VSSetShaderResources(86,1,photons_.view.GetAddressOf());
    context->VSSetShaderResources(88,1,state_.view.GetAddressOf());
    context->VSSetShader(project_.Get(),nullptr,0);context->PSSetShader(accumulate_.Get(),nullptr,0);
    context->DrawInstancedIndirect(arguments_.Get(),12);
    prepared_frame=frame_id;return true;
  }
  bool Bind(ID3D11DeviceContext1* context,uint64_t frame_id,bool compute=false,bool composite=false) {
    if(bound_ ||prepared_frame!=frame_id)return false;
    compute_=compute;
    auto views=Views();
    if(compute) {
      context->CSGetShaderResources(86,UINT(saved_.size()),saved_.data());
      context->CSSetShaderResources(86,UINT(views.size()),views.data());
    } else {
      context->PSGetShaderResources(86,UINT(saved_.size()),saved_.data());
      context->PSSetShaderResources(86,UINT(views.size()),views.data());
      if(composite) {
        context->PSGetSamplers(12,1,&saved_shadow_sampler_);
        context->PSSetSamplers(12,1,shadow_sampler_.GetAddressOf());
        shadow_sampler_bound_=true;
      }
    }
    bound_=true;return true;
  }
  void Restore(ID3D11DeviceContext1* context) {
    if(!bound_)return;
    if(shadow_sampler_bound_) {
      auto* sampler=saved_shadow_sampler_.Get();context->PSSetSamplers(12,1,&sampler);
      saved_shadow_sampler_.Reset();shadow_sampler_bound_=false;
    }
    if(compute_) {
      context->CSSetShaderResources(86,UINT(saved_.size()),saved_.data());
    } else {
      context->PSSetShaderResources(86,UINT(saved_.size()),saved_.data());
    }
    for(auto*& view:saved_) {if(view)view->Release();view=nullptr;}
    bound_=false;
  }
  ID3D11ShaderResourceView* StateView() const {return state_.view.Get();}
  ID3D11ShaderResourceView* CausticsView() const {return caustics_view_.Get();}
 private:
  struct Buffer {
    ComPtr<ID3D11Buffer> buffer;
    ComPtr<ID3D11ShaderResourceView> view;
    ComPtr<ID3D11UnorderedAccessView> output;
    UINT bytes=0;
    bool Ensure(ID3D11Device* device,UINT size,bool writable=false) {
      if(buffer &&bytes==size)return true;
      buffer.Reset();view.Reset();output.Reset();
      D3D11_BUFFER_DESC desc{size,D3D11_USAGE_DEFAULT,
          UINT(D3D11_BIND_SHADER_RESOURCE|(writable?D3D11_BIND_UNORDERED_ACCESS:0)),0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
      if(FAILED(device->CreateBuffer(&desc,nullptr,&buffer))
          ||FAILED(device->CreateShaderResourceView(buffer.Get(),nullptr,&view))
          ||(writable &&FAILED(device->CreateUnorderedAccessView(buffer.Get(),nullptr,&output)))) {buffer.Reset();return false;}
      bytes=size;return true;
    }
    bool Capture(ID3D11DeviceContext1* context,ID3D11Device* device,ID3D11Buffer* source) {
      D3D11_BUFFER_DESC desc{};source->GetDesc(&desc);
      if(!Ensure(device,desc.ByteWidth))return false;
      context->CopyResource(buffer.Get(),source);return true;
    }
  };
  std::array<ID3D11ShaderResourceView*,13> Views() const {
    return {photons_.view.Get(),native_[2].view.Get(),state_.view.Get(),frame_.view.Get(),
        native_[1].view.Get(),native_textures_[0].Get(),native_textures_[1].Get(),native_textures_[2].Get(),native_textures_[3].Get(),
        light_.view.Get(),shadow_.Get(),caustics_view_.Get(),native_[0].view.Get()};
  }
  bool Initialize(ID3D11DeviceContext1* context) {
    if(isolated_)return true;
    context->GetDevice(&device_);
    if(FAILED(device_->CreateComputeShader(__0xF3C50001.data(),__0xF3C50001.size(),nullptr,&classify_))
        ||FAILED(device_->CreateComputeShader(__0xF3C50002.data(),__0xF3C50002.size(),nullptr,&refract_))
        ||FAILED(device_->CreateVertexShader(__0xF3C50003.data(),__0xF3C50003.size(),nullptr,&project_))
        ||FAILED(device_->CreatePixelShader(__0xF3C50004.data(),__0xF3C50004.size(),nullptr,&accumulate_)))return false;
    if(!state_.Ensure(device_.Get(),8*16,true) ||!photons_.Ensure(device_.Get(),CLASSIC_CAUSTIC_VERTICES*CLASSIC_CAUSTIC_VERTICES*4*16,true))return false;
    D3D11_BUFFER_DESC bd{sizeof(Controls),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
    if(FAILED(device_->CreateBuffer(&bd,nullptr,&controls_)))return false;
    bd={28,D3D11_USAGE_DEFAULT,D3D11_BIND_UNORDERED_ACCESS,0,D3D11_RESOURCE_MISC_DRAWINDIRECT_ARGS|D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS,0};
    if(FAILED(device_->CreateBuffer(&bd,nullptr,&arguments_)))return false;
    D3D11_UNORDERED_ACCESS_VIEW_DESC ud{};ud.Format=DXGI_FORMAT_R32_TYPELESS;ud.ViewDimension=D3D11_UAV_DIMENSION_BUFFER;
    ud.Buffer.NumElements=7;ud.Buffer.Flags=D3D11_BUFFER_UAV_FLAG_RAW;
    if(FAILED(device_->CreateUnorderedAccessView(arguments_.Get(),&ud,&arguments_output_)))return false;
    D3D11_TEXTURE2D_DESC td{CLASSIC_CAUSTIC_ATLAS,CLASSIC_CAUSTIC_ATLAS,1,1,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_RENDER_TARGET};
    if(FAILED(device_->CreateTexture2D(&td,nullptr,&caustics_))
        ||FAILED(device_->CreateShaderResourceView(caustics_.Get(),nullptr,&caustics_view_))
        ||FAILED(device_->CreateRenderTargetView(caustics_.Get(),nullptr,&caustics_target_)))return false;
    D3D11_BLEND_DESC blend{};auto& rt=blend.RenderTarget[0];
    rt.BlendEnable=TRUE;rt.SrcBlend=rt.DestBlend=rt.SrcBlendAlpha=rt.DestBlendAlpha=D3D11_BLEND_ONE;
    rt.BlendOp=rt.BlendOpAlpha=D3D11_BLEND_OP_ADD;rt.RenderTargetWriteMask=D3D11_COLOR_WRITE_ENABLE_ALL;
    if(FAILED(device_->CreateBlendState(&blend,&additive_)))return false;
    D3D11_RASTERIZER_DESC raster{};raster.FillMode=D3D11_FILL_SOLID;raster.CullMode=D3D11_CULL_NONE;raster.DepthClipEnable=TRUE;
    if(FAILED(device_->CreateRasterizerState(&raster,&raster_)))return false;
    D3D11_SAMPLER_DESC sampler=CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
    sampler.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;
    if(FAILED(device_->CreateSamplerState(&sampler,&linear_)))return false;
    sampler.AddressU=sampler.AddressV=D3D11_TEXTURE_ADDRESS_WRAP;
    if(FAILED(device_->CreateSamplerState(&sampler,&wrap_)))return false;
    sampler.AddressU=sampler.AddressV=D3D11_TEXTURE_ADDRESS_CLAMP;
    sampler.Filter=D3D11_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT;
    sampler.ComparisonFunc=D3D11_COMPARISON_LESS_EQUAL;
    if(FAILED(device_->CreateSamplerState(&sampler,&shadow_sampler_)))return false;
    return SUCCEEDED(temporal::CreateIsolatedState(device_.Get(),&isolated_));
  }
  ComPtr<ID3D11Device> device_;
  ComPtr<ID3DDeviceContextState> isolated_;
  std::array<Buffer,4> native_;
  Buffer state_,photons_,light_,frame_;
  std::array<ComPtr<ID3D11ShaderResourceView>,4> native_textures_;
  ComPtr<ID3D11ShaderResourceView> shadow_,caustics_view_;
  ComPtr<ID3D11Texture2D> caustics_;
  ComPtr<ID3D11RenderTargetView> caustics_target_;
  ComPtr<ID3D11Buffer> controls_,arguments_;
  ComPtr<ID3D11UnorderedAccessView> arguments_output_;
  ComPtr<ID3D11ComputeShader> classify_,refract_;
  ComPtr<ID3D11VertexShader> project_;
  ComPtr<ID3D11PixelShader> accumulate_;
  ComPtr<ID3D11BlendState> additive_;
  ComPtr<ID3D11RasterizerState> raster_;
  ComPtr<ID3D11SamplerState> linear_,wrap_;
  ComPtr<ID3D11SamplerState> shadow_sampler_,saved_shadow_sampler_;
  std::array<ID3D11ShaderResourceView*,13> saved_{};
  bool bound_=false,compute_=false;
  bool shadow_sampler_bound_=false;
};
} // namespace witcher3classic::water
