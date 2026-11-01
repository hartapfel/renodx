/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <cmath>
#include <unordered_map>
#include <d3d11.h>
#include <wrl/client.h>

namespace witcher3classic::temporal {
// Only the current material draw gets an adjusted s0. The engine's samplers
// remain immutable; shadow, UI and postprocessing bindings retain native LODs.
class TextureMipBias {
  template<class T> using ComPtr = Microsoft::WRL::ComPtr<T>;
  struct Variant {
    ComPtr<ID3D11SamplerState> native, adjusted;
    D3D11_SAMPLER_DESC desc{};
    float offset = 0.f;
  };
  std::unordered_map<ID3D11SamplerState*,Variant> variants_;
  ComPtr<ID3D11SamplerState> saved_;
  ID3D11SamplerState* bound_ = nullptr;
 public:
  bool Bind(ID3D11DeviceContext* context,float offset) {
    if(saved_ || !std::isfinite(offset) || offset>=0.f)return false;
    ComPtr<ID3D11SamplerState> native;context->PSGetSamplers(0,1,&native);
    if(!native)return false;
    auto& variant=variants_[native.Get()];
    if(!variant.native) {variant.native=native;native->GetDesc(&variant.desc);}
    if(D3D11_DECODE_IS_COMPARISON_FILTER(variant.desc.Filter) || variant.desc.MaxLOD<=variant.desc.MinLOD)return false;
    if(!variant.adjusted || variant.offset!=offset) {
      auto desc=variant.desc;
      desc.MipLODBias=std::clamp(desc.MipLODBias+offset,D3D11_MIP_LOD_BIAS_MIN,D3D11_MIP_LOD_BIAS_MAX);
      if(desc.MipLODBias==variant.desc.MipLODBias)return false;
      ComPtr<ID3D11Device> device;context->GetDevice(&device);
      variant.adjusted.Reset();
      if(FAILED(device->CreateSamplerState(&desc,&variant.adjusted)))return false;
      variant.offset=offset;
    }
    saved_=native;bound_=variant.adjusted.Get();context->PSSetSamplers(0,1,variant.adjusted.GetAddressOf());return true;
  }
  void Restore(ID3D11DeviceContext* context) {
    if(!saved_)return;
    // A skipped draw or another addon may already have changed the binding.
    // Do not overwrite a newer engine sampler at the next draw boundary.
    ComPtr<ID3D11SamplerState> current;context->PSGetSamplers(0,1,&current);
    if(current.Get()==bound_)context->PSSetSamplers(0,1,saved_.GetAddressOf());
    saved_.Reset();bound_=nullptr;
  }
};
}  // namespace witcher3classic::temporal
