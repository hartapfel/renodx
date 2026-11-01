/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3dcompiler.h>
#include <cassert>
#include <array>
#include <vector>
#include <cstring>
#include <iostream>
#include <chrono>
#include "../temporal/texture_mip_bias.hpp"
using Microsoft::WRL::ComPtr;
int main(int argc,char**) {
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&context)));
  witcher3classic::temporal::TextureMipBias bias;
  D3D11_SAMPLER_DESC desc{};desc.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;
  desc.AddressU=desc.AddressV=desc.AddressW=D3D11_TEXTURE_ADDRESS_WRAP;desc.MaxLOD=D3D11_FLOAT32_MAX;desc.MipLODBias=.25f;
  ComPtr<ID3D11SamplerState> native;assert(SUCCEEDED(device->CreateSamplerState(&desc,&native)));
  context->PSSetSamplers(0,1,native.GetAddressOf());context->PSSetSamplers(1,1,native.GetAddressOf());
  context->VSSetSamplers(0,1,native.GetAddressOf());context->CSSetSamplers(0,1,native.GetAddressOf());
  for(float offset:{-1.f,-1.5849625f,-2.f,-2.5849625f,-1.f}) {
    assert(bias.Bind(context.Get(),offset));assert(!bias.Bind(context.Get(),offset));
    ComPtr<ID3D11SamplerState> selected;context->PSGetSamplers(0,1,&selected);D3D11_SAMPLER_DESC actual{};selected->GetDesc(&actual);
    assert(std::abs(actual.MipLODBias-(.25f+offset))<1.e-6f);
    assert(actual.Filter==desc.Filter && actual.AddressU==desc.AddressU &&actual.MinLOD==desc.MinLOD &&actual.MaxLOD==desc.MaxLOD);
    selected.Reset();context->PSGetSamplers(1,1,&selected);assert(selected.Get()==native.Get());
    selected.Reset();context->VSGetSamplers(0,1,&selected);assert(selected.Get()==native.Get());
    selected.Reset();context->CSGetSamplers(0,1,&selected);assert(selected.Get()==native.Get());
    bias.Restore(context.Get());selected.Reset();context->PSGetSamplers(0,1,&selected);assert(selected.Get()==native.Get());
    native->GetDesc(&actual);assert(actual.MipLODBias==.25f);
  }
  assert(!bias.Bind(context.Get(),0.f));assert(!bias.Bind(context.Get(),1.f));
  auto protected_desc=desc;protected_desc.Filter=D3D11_FILTER_COMPARISON_MIN_MAG_MIP_LINEAR;protected_desc.ComparisonFunc=D3D11_COMPARISON_LESS;
  ComPtr<ID3D11SamplerState> protected_sampler;assert(SUCCEEDED(device->CreateSamplerState(&protected_desc,&protected_sampler)));
  context->PSSetSamplers(0,1,protected_sampler.GetAddressOf());assert(!bias.Bind(context.Get(),-2.f));
  context->PSSetSamplers(0,1,native.GetAddressOf());assert(bias.Bind(context.Get(),-2.f));
  context->PSSetSamplers(0,1,protected_sampler.GetAddressOf());bias.Restore(context.Get());
  ComPtr<ID3D11SamplerState> newer;context->PSGetSamplers(0,1,&newer);assert(newer.Get()==protected_sampler.Get());
  auto anisotropic=desc;anisotropic.Filter=D3D11_FILTER_ANISOTROPIC;anisotropic.MaxAnisotropy=16;anisotropic.MipLODBias=-.75f;
  ComPtr<ID3D11SamplerState> anisotropic_sampler;assert(SUCCEEDED(device->CreateSamplerState(&anisotropic,&anisotropic_sampler)));
  context->PSSetSamplers(0,1,anisotropic_sampler.GetAddressOf());assert(bias.Bind(context.Get(),-2.f));
  newer.Reset();context->PSGetSamplers(0,1,&newer);D3D11_SAMPLER_DESC corrected_desc{};newer->GetDesc(&corrected_desc);
  assert(corrected_desc.Filter==D3D11_FILTER_ANISOTROPIC && corrected_desc.MaxAnisotropy==16 &&corrected_desc.MipLODBias==-2.75f);
  bias.Restore(context.Get());
  protected_desc=desc;protected_desc.MaxLOD=0.f;protected_sampler.Reset();assert(SUCCEEDED(device->CreateSamplerState(&protected_desc,&protected_sampler)));
  context->PSSetSamplers(0,1,protected_sampler.GetAddressOf());assert(!bias.Bind(context.Get(),-2.f));
  context->PSSetSamplers(0,1,native.GetAddressOf());
  // Each mip has a known HDR color. Actual GPU sampling must move from mip
  // 3.25 to 1.25 at Performance, then return exactly when the draw ends.
  const char* vs_text="float4 main(uint id:SV_VertexID):SV_Position{return float4(float2((id<<1)&2,id&2)*float2(2,-2)+float2(-1,1),0,1);}";
  const char* ps_text="Texture2D<float4> T:register(t0);SamplerState S:register(s0);float4 main(float4 p:SV_Position):SV_Target{return T.Sample(S,p.xy/16.f);}";
  ComPtr<ID3DBlob> code;ComPtr<ID3D11VertexShader> vs;ComPtr<ID3D11PixelShader> ps;
  assert(SUCCEEDED(D3DCompile(vs_text,strlen(vs_text),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&code,nullptr)));
  assert(SUCCEEDED(device->CreateVertexShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&vs)));code.Reset();
  assert(SUCCEEDED(D3DCompile(ps_text,strlen(ps_text),nullptr,nullptr,nullptr,"main","ps_5_0",0,0,&code,nullptr)));
  assert(SUCCEEDED(device->CreatePixelShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&ps)));
  std::array<std::vector<std::array<float,4>>,8> pixels;std::array<D3D11_SUBRESOURCE_DATA,8> initial;
  for(UINT level=0;level<8;++level) {
    pixels[level].resize((128u>>level)*(128u>>level),{1.f+float(level),8,16,1});
    initial[level]={pixels[level].data(),(128u>>level)*16};
  }
  D3D11_TEXTURE2D_DESC td{128,128,8,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  ComPtr<ID3D11Texture2D> texture,target,staging;ComPtr<ID3D11ShaderResourceView> view;ComPtr<ID3D11RenderTargetView> rtv;
  assert(SUCCEEDED(device->CreateTexture2D(&td,initial.data(),&texture)));assert(SUCCEEDED(device->CreateShaderResourceView(texture.Get(),nullptr,&view)));
  td.Width=td.Height=16;td.MipLevels=1;td.BindFlags=D3D11_BIND_RENDER_TARGET;
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&target)));assert(SUCCEEDED(device->CreateRenderTargetView(target.Get(),nullptr,&rtv)));
  td.Usage=D3D11_USAGE_STAGING;td.BindFlags=0;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&staging)));
  const D3D11_VIEWPORT viewport{0,0,16,16,0,1};context->RSSetViewports(1,&viewport);
  context->OMSetRenderTargets(1,rtv.GetAddressOf(),nullptr);context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  context->VSSetShader(vs.Get(),nullptr,0);context->PSSetShader(ps.Get(),nullptr,0);context->PSSetShaderResources(0,1,view.GetAddressOf());
  auto sample=[&] {
    context->Draw(3,0);context->CopyResource(staging.Get(),target.Get());D3D11_MAPPED_SUBRESOURCE map;
    assert(SUCCEEDED(context->Map(staging.Get(),0,D3D11_MAP_READ,0,&map)));
    const auto* color=reinterpret_cast<const float*>(static_cast<const char*>(map.pData)+8*map.RowPitch)+8*4;
    const std::array<float,4> result{color[0],color[1],color[2],color[3]};context->Unmap(staging.Get(),0);return result;
  };
  const auto original=sample();assert(std::abs(original[0]-4.25f)<.01f);
  assert(bias.Bind(context.Get(),-2.f));const auto corrected=sample();bias.Restore(context.Get());
  assert(std::abs(corrected[0]-2.25f)<.01f && corrected[1]==8.f &&corrected[2]==16.f &&corrected[3]==1.f);
  assert(sample()==original);
  const auto start=std::chrono::steady_clock::now();
  for(UINT i=0;i<10000;++i){assert(bias.Bind(context.Get(),-2.f));bias.Restore(context.Get());}
  std::cout<<"Cached sampler scope CPU: "<<std::chrono::duration<double,std::micro>(std::chrono::steady_clock::now()-start).count()/10000<<" us/draw\n";
  std::cout<<"PASS additive quality bias, immutable samplers, comparison/fixed-LOD exclusion, exact restoration and actual HDR mip sampling\n";
}
