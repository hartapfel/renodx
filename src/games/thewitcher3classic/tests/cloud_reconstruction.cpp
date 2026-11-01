/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11.h>
#include <wrl/client.h>
#include <array>
#include <cassert>
#include <cmath>
#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>
#include <embed/0xF3C60003.h>
using Microsoft::WRL::ComPtr;
int main(int argc,char** argv) {
  constexpr UINT W=64,H=8;
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&context)));
  ComPtr<ID3D11ComputeShader> shader;
  if(argc>2) {
    std::ifstream file(argv[2],std::ios::binary);assert(file);
    const std::vector<char> code{std::istreambuf_iterator<char>(file),{}};
    assert(SUCCEEDED(device->CreateComputeShader(code.data(),code.size(),nullptr,&shader)));
  } else assert(SUCCEEDED(device->CreateComputeShader(__0xF3C60003.data(),__0xF3C60003.size(),nullptr,&shader)));
  std::array<std::array<float,4>,269> frame{},previous{};
  frame[1]={1,0,0,0};frame[2]={0,1,0,0};frame[3]={0,0,1,0};frame[4]={0,0,0,1};
  frame[13]={1,0,0,0};frame[14]={0,1,0,0};frame[15]={0,0,1,1};frame[16]={0,0,-.2f,0};
  frame[17]={1,0,0,0};frame[18]={0,1,0,0};frame[20]={0,0,1,1};
  previous=frame;previous[15][0]=.5f/W; // quarter-texel reprojection
  std::array<std::array<float,4>,5> parameters{};parameters[0]={W,H,W,H};parameters[1][3]=1;
  auto buffer=[&](UINT slot,const void* data,UINT bytes) {
    D3D11_BUFFER_DESC desc{bytes,D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
    D3D11_SUBRESOURCE_DATA initial{data};ComPtr<ID3D11Buffer> result;
    assert(SUCCEEDED(device->CreateBuffer(&desc,&initial,&result)));context->CSSetConstantBuffers(slot,1,result.GetAddressOf());
  };
  buffer(0,frame.data(),sizeof(frame));buffer(3,previous.data(),sizeof(previous));buffer(2,parameters.data(),sizeof(parameters));
  std::array<float,4> clock{};buffer(5,clock.data(),sizeof(clock));buffer(6,clock.data(),sizeof(clock));
  std::array<ComPtr<ID3D11Texture2D>,6> textures;
  std::array<ComPtr<ID3D11ShaderResourceView>,3> views;
  std::array<ComPtr<ID3D11UnorderedAccessView>,3> outputs;
  for(UINT i=0;i<textures.size();++i) {
    D3D11_TEXTURE2D_DESC desc{W,H,1,1,i==2 ||i==4?DXGI_FORMAT_R32_FLOAT:DXGI_FORMAT_R32G32B32A32_FLOAT,
        {1,0},D3D11_USAGE_DEFAULT,UINT(i<3?D3D11_BIND_SHADER_RESOURCE:D3D11_BIND_UNORDERED_ACCESS)};
    assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&textures[i])));
    if(i<3)assert(SUCCEEDED(device->CreateShaderResourceView(textures[i].Get(),nullptr,&views[i])));
    else assert(SUCCEEDED(device->CreateUnorderedAccessView(textures[i].Get(),nullptr,&outputs[i-3])));
  }
  std::array<float,W*H> depth;depth.fill(1000);
  context->UpdateSubresource(textures[2].Get(),0,nullptr,depth.data(),W*4,0);
  D3D11_SAMPLER_DESC sampler{};sampler.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;
  sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;sampler.MaxLOD=D3D11_FLOAT32_MAX;
  ComPtr<ID3D11SamplerState> linear;assert(SUCCEEDED(device->CreateSamplerState(&sampler,&linear)));
  context->CSSetSamplers(1,1,linear.GetAddressOf());context->CSSetShader(shader.Get(),nullptr,0);
  D3D11_TEXTURE2D_DESC desc{};textures[3]->GetDesc(&desc);desc.Usage=D3D11_USAGE_STAGING;
  desc.BindFlags=0;desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  ComPtr<ID3D11Texture2D> read;assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&read)));
  std::vector<float> pixels(W*H*4),actual(pixels.size());
  auto signal=[&](float phase,float constant=0.f) {
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
      const float value=constant>0?constant:20.f+8.f*std::cos(6.28318530718f*.2f*(x+.5f+phase));
      const UINT i=(y*W+x)*4;pixels[i]=value;pixels[i+1]=value*.5f;pixels[i+2]=value*.25f;pixels[i+3]=.2f;
    }
  };
  auto run=[&] {
    context->UpdateSubresource(textures[0].Get(),0,nullptr,pixels.data(),W*16,0);
    ID3D11ShaderResourceView* inputs[]{views[0].Get(),views[2].Get(),views[1].Get(),views[2].Get()};
    context->CSSetShaderResources(3,4,inputs);
    ID3D11UnorderedAccessView* out[]{outputs[0].Get(),outputs[1].Get(),outputs[2].Get()};
    context->CSSetUnorderedAccessViews(0,3,out,nullptr);context->Dispatch(W/8,H/8,1);
    ID3D11UnorderedAccessView* empty[3]{};context->CSSetUnorderedAccessViews(0,3,empty,nullptr);
    ID3D11ShaderResourceView* clear[4]{};context->CSSetShaderResources(3,4,clear);
    context->CopyResource(textures[1].Get(),textures[3].Get());context->CopyResource(read.Get(),textures[3].Get());
    D3D11_MAPPED_SUBRESOURCE mapped{};assert(SUCCEEDED(context->Map(read.Get(),0,D3D11_MAP_READ,0,&mapped)));
    for(UINT y=0;y<H;++y)std::memcpy(actual.data()+y*W*4,static_cast<const char*>(mapped.pData)+y*mapped.RowPitch,W*16);
    context->Unmap(read.Get(),0);
    for(float value:actual)assert(std::isfinite(value));
  };
  signal(0);context->UpdateSubresource(textures[1].Get(),0,nullptr,pixels.data(),W*16,0);
  double error=0;unsigned compared=0;
  for(unsigned n=1;n<=32;++n) {
    signal(n*.25f);run();
    if(n>16)for(UINT y=1;y<H-1;++y)for(UINT x=12;x<W-12;++x) {
      const UINT i=(y*W+x)*4;error+=std::pow((actual[i]-pixels[i])/8.,2);++compared;
      assert(actual[i]>=11.99f &&actual[i]<=28.01f &&std::abs(actual[i+3]-.2f)<1.e-5f);
    }
  }
  const double rms=std::sqrt(error/compared);
  std::cout<<"Subpixel cloud detail, 32 reprojections: relative RMS="<<rms<<std::endl;
  assert(rms<.08);
  signal(0,9000);context->UpdateSubresource(textures[1].Get(),0,nullptr,pixels.data(),W*16,0);run();
  for(UINT i=0;i<actual.size();++i)assert(std::abs(actual[i]-pixels[i])<.01f);
  std::cout<<"PASS analytic moving-detail reconstruction, no HDR/opacity overshoot, constant HDR energy and finite output\n";
}
