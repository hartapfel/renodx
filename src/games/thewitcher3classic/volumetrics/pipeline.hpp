/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <embed/0xF3C30001.h>
#include <embed/0xF3C30002.h>
#include <array>
#include <algorithm>
#include "../temporal/context.hpp"
#include "settings.hpp"
namespace witcher3classic::volumetrics {
using Microsoft::WRL::ComPtr;
struct Parameters {
  std::array<float,4> grid{}, medium{}, options{}, sampling{};
  std::array<float,4> sky{1.f,1.f,0.f,0.f};
};
struct LocalLightInputs {
  ID3D11ShaderResourceView* tiles = nullptr;
  ID3D11ShaderResourceView* atlas = nullptr;
  ID3D11ShaderResourceView* cubes = nullptr;
  ID3D11SamplerState* sampler = nullptr;
};
class Pipeline {
 public:
  HRESULT error = S_OK;
  uint64_t generated_frame = UINT64_MAX;
  // Public input contract also used by the GPU regression fixture. No CPU
  // readbacks, scene geometry replay or per-object allocation is involved.
  bool Generate(ID3D11DeviceContext1* context, ID3D11Buffer* frame, ID3D11Buffer* lighting,
                ID3D11ShaderResourceView* shadow, ID3D11ShaderResourceView* cloud,
                ID3D11ShaderResourceView* terrain, const Parameters& parameters, uint64_t frame_id,
                ID3D11SamplerState* native_shadow_sampler = nullptr, ID3D11ShaderResourceView* interiors = nullptr,
                const LocalLightInputs& local_lights = {}) {
    if (!frame || !lighting || !shadow || parameters.grid[0]<1 || parameters.grid[1]<1
        || parameters.grid[2]<1 || parameters.grid[3]<=parameters.options[1]) return false;
    if (!Initialize(context)) return false;
    ray_ready_=false;
    if(parameters.sky[2]>.5f && ray_frame_.Capture(context,device_.Get(),frame,269*16)
        && ray_lighting_.Capture(context,device_.Get(),lighting,2362*16)) {
      ray_sources_={local_lights.tiles,ray_frame_.view.Get(),ray_lighting_.view.Get(),shadow,
          local_lights.atlas,local_lights.cubes,cloud,terrain,interiors};
      ray_ready_=true;
    }
    if(!ray_ready_)for(auto& view:ray_sources_)view.Reset();
    Parameters effective=parameters;
    effective.sky[2]=ray_ready_?1.f:0.f;
    if(ray_ready_)effective.grid={1,1,1,parameters.grid[3]};
    const UINT width=UINT(effective.grid[0]), height=UINT(effective.grid[1]), slices=UINT(effective.grid[2]);
    if (width>512 || height>512 || slices>256) return false;
    if (!cells_.Ensure(device_.Get(),width,height,slices)
        || !volume_.Ensure(device_.Get(),width,height,slices+1)) return false;
    temporal::ContextScope restore(context,state_.Get());
    context->UpdateSubresource(constants_.Get(),0,nullptr,&effective,0,0);
    ID3D11UnorderedAccessView* parameter_output=parameter_output_.Get();
    context->CSSetUnorderedAccessViews(1,1,&parameter_output,nullptr);
    ID3D11Buffer* buffers[]={frame,lighting,constants_.Get()};
    context->CSSetConstantBuffers(0,3,buffers);
    ID3D11SamplerState* samplers[]={native_shadow_sampler ? native_shadow_sampler : shadow_sampler_.Get(),wrap_sampler_.Get(),linear_sampler_.Get(),
        local_lights.sampler ? local_lights.sampler : linear_sampler_.Get()};
    context->CSSetSamplers(0,4,samplers);
    ID3D11ShaderResourceView* inputs[]={shadow,cloud,terrain,interiors,local_lights.tiles,local_lights.atlas,local_lights.cubes};
    context->CSSetShaderResources(0,7,inputs);
    ID3D11UnorderedAccessView* output=cells_.output.Get();
    context->CSSetUnorderedAccessViews(0,1,&output,nullptr);
    context->CSSetShader(scatter_.Get(),nullptr,0);
    context->Dispatch((width+3)/4,(height+3)/4,(slices+3)/4);
    output=nullptr;
    context->CSSetUnorderedAccessViews(0,1,&output,nullptr);
    inputs[0]=cells_.view.Get();
    std::fill(std::begin(inputs)+1,std::end(inputs),nullptr);
    context->CSSetShaderResources(0,7,inputs);
    output=volume_.output.Get();
    context->CSSetUnorderedAccessViews(0,1,&output,nullptr);
    context->CSSetShader(integrate_.Get(),nullptr,0);
    context->Dispatch((width+7)/8,(height+7)/8,1);
    generated_frame=frame_id;
    return true;
  }
  ID3D11ShaderResourceView* View() const { return volume_.view.Get(); }
  ID3D11ShaderResourceView* ParametersView() const { return parameter_view_.Get(); }
  bool Bind(ID3D11DeviceContext1* context, bool vertex, uint64_t frame_id) {
    if (bound_ || generated_frame!=frame_id || !volume_.view) return false;
    vertex_=vertex;
    if (vertex) {
      context->VSGetShaderResources(116,1,&saved_[0]);
      context->VSGetShaderResources(117,1,&saved_[1]);
      context->VSGetSamplers(11,1,&saved_sampler_);
    } else {
      context->PSGetShaderResources(116,1,&saved_[0]);
      context->PSGetShaderResources(117,1,&saved_[1]);
      context->PSGetSamplers(11,1,&saved_sampler_);
    }
    ID3D11ShaderResourceView* views[]={volume_.view.Get(),parameter_view_.Get()};
    auto* sampler=linear_sampler_.Get();
    if (vertex) { context->VSSetShaderResources(116,2,views); context->VSSetSamplers(11,1,&sampler); }
    else { context->PSSetShaderResources(116,2,views); context->PSSetSamplers(11,1,&sampler); }
    if(!vertex &&ray_ready_) {
      std::array<ID3D11ShaderResourceView*,9> previous{},sources{};
      context->PSGetShaderResources(99,UINT(previous.size()),previous.data());
      for(size_t i=0;i<previous.size();++i) { saved_ray_[i].Attach(previous[i]);sources[i]=ray_sources_[i].Get(); }
      context->PSSetShaderResources(99,UINT(sources.size()),sources.data());
      ray_bound_=true;
    }
    bound_=true;
    return true;
  }
  void Restore(ID3D11DeviceContext1* context) {
    if (!bound_) return;
    if(ray_bound_) {
      std::array<ID3D11ShaderResourceView*,9> previous{};
      for(size_t i=0;i<previous.size();++i) {previous[i]=saved_ray_[i].Get();}
      context->PSSetShaderResources(99,UINT(previous.size()),previous.data());
      for(auto& view:saved_ray_)view.Reset();ray_bound_=false;
    }
    ID3D11ShaderResourceView* views[]={saved_[0].Get(),saved_[1].Get()};
    auto* sampler=saved_sampler_.Get();
    if (vertex_) { context->VSSetShaderResources(116,2,views); context->VSSetSamplers(11,1,&sampler); }
    else { context->PSSetShaderResources(116,2,views); context->PSSetSamplers(11,1,&sampler); }
    saved_[0].Reset(); saved_[1].Reset(); saved_sampler_.Reset(); bound_=false;
  }
 private:
  struct Snapshot {
    ComPtr<ID3D11Buffer> buffer;
    ComPtr<ID3D11ShaderResourceView> view;
    UINT bytes=0;
    bool Capture(ID3D11DeviceContext1* context,ID3D11Device* device,ID3D11Buffer* source,UINT minimum_bytes) {
      D3D11_BUFFER_DESC original{};source->GetDesc(&original);
      if(original.ByteWidth%16 ||original.ByteWidth<minimum_bytes)return false;
      if(!buffer ||bytes!=original.ByteWidth) {
        buffer.Reset();view.Reset();
        D3D11_BUFFER_DESC desc{original.ByteWidth,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
        if(FAILED(device->CreateBuffer(&desc,nullptr,&buffer))
            ||FAILED(device->CreateShaderResourceView(buffer.Get(),nullptr,&view))) {buffer.Reset();return false;}
        bytes=original.ByteWidth;
      }
      context->CopyResource(buffer.Get(),source);return true;
    }
  } ray_frame_,ray_lighting_;
  bool ray_ready_=false,ray_bound_=false;
  std::array<ComPtr<ID3D11ShaderResourceView>,9> ray_sources_,saved_ray_;
  struct Volume {
    UINT width=0,height=0,depth=0;
    ComPtr<ID3D11Texture3D> texture;
    ComPtr<ID3D11ShaderResourceView> view;
    ComPtr<ID3D11UnorderedAccessView> output;
    bool Ensure(ID3D11Device* device,UINT w,UINT h,UINT d) {
      if (texture && width==w && height==h && depth==d) return true;
      texture.Reset(); view.Reset(); output.Reset();
      const D3D11_TEXTURE3D_DESC desc{w,h,d,1,DXGI_FORMAT_R16G16B16A16_FLOAT,D3D11_USAGE_DEFAULT,
                                     D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_UNORDERED_ACCESS};
      if (FAILED(device->CreateTexture3D(&desc,nullptr,&texture))
          || FAILED(device->CreateShaderResourceView(texture.Get(),nullptr,&view))
          || FAILED(device->CreateUnorderedAccessView(texture.Get(),nullptr,&output))) { texture.Reset(); return false; }
      width=w; height=h; depth=d; return true;
    }
  } cells_,volume_;
  bool Initialize(ID3D11DeviceContext1* context) {
    if (state_) return true;
    context->GetDevice(&device_);
    if (FAILED(error=device_->CreateComputeShader(__0xF3C30001.data(),__0xF3C30001.size(),nullptr,&scatter_))
        || FAILED(error=device_->CreateComputeShader(__0xF3C30002.data(),__0xF3C30002.size(),nullptr,&integrate_))) return false;
    D3D11_BUFFER_DESC desc{sizeof(Parameters),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
    if (FAILED(error=device_->CreateBuffer(&desc,nullptr,&constants_))) return false;
    desc.ByteWidth=22*16;
    desc.BindFlags=D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_UNORDERED_ACCESS; desc.MiscFlags=D3D11_RESOURCE_MISC_BUFFER_STRUCTURED; desc.StructureByteStride=16;
    if (FAILED(error=device_->CreateBuffer(&desc,nullptr,&parameters_))
        || FAILED(error=device_->CreateShaderResourceView(parameters_.Get(),nullptr,&parameter_view_))
        || FAILED(error=device_->CreateUnorderedAccessView(parameters_.Get(),nullptr,&parameter_output_))) return false;
    D3D11_SAMPLER_DESC sampler=CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
    sampler.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;
    if (FAILED(error=device_->CreateSamplerState(&sampler,&linear_sampler_))) return false;
    sampler.AddressU=sampler.AddressV=D3D11_TEXTURE_ADDRESS_WRAP;
    if (FAILED(error=device_->CreateSamplerState(&sampler,&wrap_sampler_))) return false;
    sampler.AddressU=sampler.AddressV=D3D11_TEXTURE_ADDRESS_CLAMP;
    sampler.Filter=D3D11_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT;
    sampler.ComparisonFunc=D3D11_COMPARISON_LESS_EQUAL;
    if (FAILED(error=device_->CreateSamplerState(&sampler,&shadow_sampler_))) return false;
    return SUCCEEDED(error=temporal::CreateIsolatedState(device_.Get(),&state_));
  }
  bool bound_=false,vertex_=false;
  ComPtr<ID3D11Device> device_;
  ComPtr<ID3DDeviceContextState> state_;
  ComPtr<ID3D11ComputeShader> scatter_,integrate_;
  ComPtr<ID3D11Buffer> constants_,parameters_;
  ComPtr<ID3D11ShaderResourceView> parameter_view_,saved_[2];
  ComPtr<ID3D11UnorderedAccessView> parameter_output_;
  ComPtr<ID3D11SamplerState> shadow_sampler_,wrap_sampler_,linear_sampler_,saved_sampler_;
};
}  // namespace witcher3classic::volumetrics
