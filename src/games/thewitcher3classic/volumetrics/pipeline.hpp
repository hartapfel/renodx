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
                ID3D11SamplerState* native_shadow_sampler = nullptr, ID3D11ShaderResourceView* interiors = nullptr) {
    if (!frame || !lighting || !shadow || parameters.grid[0]<1 || parameters.grid[1]<1
        || parameters.grid[2]<1 || parameters.grid[3]<=parameters.options[1]) return false;
    if (!Initialize(context)) return false;
    const UINT width=UINT(parameters.grid[0]), height=UINT(parameters.grid[1]), slices=UINT(parameters.grid[2]);
    if (width>512 || height>512 || slices>256) return false;
    if (!cells_.Ensure(device_.Get(),width,height,slices)
        || !volume_.Ensure(device_.Get(),width,height,slices+1)) return false;
    temporal::ContextScope restore(context,state_.Get());
    context->UpdateSubresource(constants_.Get(),0,nullptr,&parameters,0,0);
    ID3D11UnorderedAccessView* parameter_output=parameter_output_.Get();
    context->CSSetUnorderedAccessViews(1,1,&parameter_output,nullptr);
    ID3D11Buffer* buffers[]={frame,lighting,constants_.Get()};
    context->CSSetConstantBuffers(0,3,buffers);
    ID3D11SamplerState* samplers[]={native_shadow_sampler ? native_shadow_sampler : shadow_sampler_.Get(),wrap_sampler_.Get(),linear_sampler_.Get()};
    context->CSSetSamplers(0,3,samplers);
    ID3D11ShaderResourceView* inputs[]={shadow,cloud,terrain,interiors};
    context->CSSetShaderResources(0,4,inputs);
    ID3D11UnorderedAccessView* output=cells_.output.Get();
    context->CSSetUnorderedAccessViews(0,1,&output,nullptr);
    context->CSSetShader(scatter_.Get(),nullptr,0);
    context->Dispatch((width+3)/4,(height+3)/4,(slices+3)/4);
    output=nullptr;
    context->CSSetUnorderedAccessViews(0,1,&output,nullptr);
    inputs[0]=cells_.view.Get(); inputs[1]=inputs[2]=inputs[3]=nullptr;
    context->CSSetShaderResources(0,4,inputs);
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
    bound_=true;
    return true;
  }
  void Restore(ID3D11DeviceContext1* context) {
    if (!bound_) return;
    ID3D11ShaderResourceView* views[]={saved_[0].Get(),saved_[1].Get()};
    auto* sampler=saved_sampler_.Get();
    if (vertex_) { context->VSSetShaderResources(116,2,views); context->VSSetSamplers(11,1,&sampler); }
    else { context->PSSetShaderResources(116,2,views); context->PSSetSamplers(11,1,&sampler); }
    saved_[0].Reset(); saved_[1].Reset(); saved_sampler_.Reset(); bound_=false;
  }
 private:
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
