/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11.h>
#include <d3dcompiler.h>
#include <wrl/client.h>
#include <array>
#include <cassert>
#include <cmath>
#include <cstring>
#include <fstream>
#include <iostream>
#include <string_view>
#include <vector>
#include <embed/0xF3C60003.h>
#include "../clouds/fast_noise.hpp"
using Microsoft::WRL::ComPtr;
int main(int argc,char** argv) {
  constexpr UINT W=128,H=128;
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1 &&std::string_view(argv[1])=="--hardware"?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&context)));
  ComPtr<ID3D11ComputeShader> shader;
  if(argc>2) {
    if(std::string(argv[2]).ends_with(".hlsl")) {
      ComPtr<ID3DBlob> code,errors;
      const std::wstring path(argv[2],argv[2]+std::strlen(argv[2]));
      const auto result=D3DCompileFromFile(path.c_str(),nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,
          "main","cs_5_0",D3DCOMPILE_ENABLE_STRICTNESS|D3DCOMPILE_OPTIMIZATION_LEVEL3,0,&code,&errors);
      if(errors)std::cerr<<static_cast<const char*>(errors->GetBufferPointer());
      assert(SUCCEEDED(result));
      assert(SUCCEEDED(device->CreateComputeShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&shader)));
    } else {
      std::ifstream file(argv[2],std::ios::binary);assert(file);
      const std::vector<char> code{std::istreambuf_iterator<char>(file),{}};
      assert(SUCCEEDED(device->CreateComputeShader(code.data(),code.size(),nullptr,&shader)));
    }
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
  // The same FAST sequence as production, over an exposure-scaled gradient.
  // Measure noise rejection without tolerating brightness or hue drift.
  previous=frame;buffer(3,previous.data(),sizeof(previous));
  for(float scale:{.001f,1.f,9000.f}) {
    signal(0,scale);context->UpdateSubresource(textures[1].Get(),0,nullptr,pixels.data(),W*16,0);
    double input_error=0,output_error=0,bias=0;unsigned samples=0;
    for(unsigned n=0;n<96;++n) {
      for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
        const UINT i=(y*W+x)*4;
        const float reference=scale*(.8f+.4f*x/W);
        const float random=(witcher3classic::clouds::fast_noise[(n%32)*128*128+y*128+x]+.5f)/256.f;
        pixels[i]=reference*(1.f+.2f*(random-.5f));pixels[i+1]=pixels[i]*.5f;pixels[i+2]=pixels[i]*.25f;pixels[i+3]=.2f;
      }
      run();
      if(n>=32)for(UINT y=2;y<H-2;++y)for(UINT x=2;x<W-2;++x) {
        const UINT i=(y*W+x)*4;const double reference=scale*(.8f+.4f*x/W);
        input_error+=std::pow((pixels[i]-reference)/reference,2);
        output_error+=std::pow((actual[i]-reference)/reference,2);
        bias+=(actual[i]-reference)/reference;++samples;
        assert(std::abs(actual[i+1]/actual[i]-.5f)<1.e-5f &&std::abs(actual[i+2]/actual[i]-.25f)<1.e-5f);
        assert(std::abs(actual[i+3]-.2f)<1.e-5f);
      }
    }
    const double reduction=std::sqrt(output_error/input_error);
    std::cout<<"FAST gradient scale="<<scale<<" RMS ratio="<<reduction<<" relative mean bias="<<bias/samples<<std::endl;
    assert(reduction<.35 &&std::abs(bias/samples)<.002);
  }
  // Bright sky through thin cloud gaps exposes stochastic transmission, even
  // when the cloud's own RGB is smooth. Test that signal separately from RGB.
  signal(0,1.f);context->UpdateSubresource(textures[1].Get(),0,nullptr,pixels.data(),W*16,0);
  double transmission_input=0,transmission_output=0,transmission_bias=0;unsigned transmission_samples=0;
  for(unsigned n=0;n<96;++n) {
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
      const UINT i=(y*W+x)*4;
      const float reference=.2f+.6f*x/W;
      const float random=(witcher3classic::clouds::fast_noise[(n%32)*128*128+y*128+x]+.5f)/256.f;
      pixels[i]=1.f;pixels[i+1]=.5f;pixels[i+2]=.25f;pixels[i+3]=reference+.3f*(random-.5f);
    }
    run();
    if(n>=32)for(UINT y=2;y<H-2;++y)for(UINT x=2;x<W-2;++x) {
      const UINT i=(y*W+x)*4;const double reference=.2+.6*x/W;
      transmission_input+=std::pow(pixels[i+3]-reference,2);
      transmission_output+=std::pow(actual[i+3]-reference,2);
      transmission_bias+=actual[i+3]-reference;++transmission_samples;
      assert(actual[i+3]>=0.f &&actual[i+3]<=1.f &&std::abs(actual[i]-1.f)<1.e-5f);
    }
  }
  std::cout<<"Bright-gap transmission RMS ratio="<<std::sqrt(transmission_output/transmission_input)
      <<" absolute mean bias="<<transmission_bias/transmission_samples<<std::endl;
  assert(std::sqrt(transmission_output/transmission_input)<.35 &&std::abs(transmission_bias/transmission_samples)<.002);
  context->CopyResource(read.Get(),textures[5].Get());
  D3D11_MAPPED_SUBRESOURCE motion_map{};assert(SUCCEEDED(context->Map(read.Get(),0,D3D11_MAP_READ,0,&motion_map)));
  unsigned confident=0;
  for(UINT y=2;y<H-2;++y)for(UINT x=2;x<W-2;++x) {
    const auto* p=reinterpret_cast<const float*>(static_cast<const char*>(motion_map.pData)+y*motion_map.RowPitch)+x*4;
    assert(std::abs(p[2]-(1.f-actual[(y*W+x)*4+3]))<1.e-5f);
    confident+=p[3]>.9f;
  }
  context->Unmap(read.Get(),0);
  assert(confident>(W-4)*(H-4)*9/10);
  std::cout<<"PASS resolved transparency and variance-aware upscaler confidence\n";
  // Advected thin-gap detail must remain sharp while its noisy estimates
  // converge. Use the same subpixel camera transform as the RGB detail check.
  previous[15][0]=.5f/W;buffer(3,previous.data(),sizeof(previous));
  double gap_error=0;unsigned gap_samples=0;
  for(unsigned n=0;n<96;++n) {
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
      const UINT i=(y*W+x)*4;
      const float reference=.5f+.3f*std::cos(6.28318530718f*.08f*(x+.5f+n*.25f));
      const float random=(witcher3classic::clouds::fast_noise[(n%32)*128*128+y*128+x]+.5f)/256.f;
      pixels[i+3]=reference+.16f*(random-.5f);
    }
    run();
    if(n>=32)for(UINT y=2;y<H-2;++y)for(UINT x=12;x<W-12;++x) {
      const double reference=.5+.3*std::cos(6.28318530718*.08*(x+.5+n*.25));
      gap_error+=std::pow(actual[(y*W+x)*4+3]-reference,2);++gap_samples;
    }
  }
  std::cout<<"Moving thin-gap absolute transmission RMS="<<std::sqrt(gap_error/gap_samples)<<std::endl;
  assert(std::sqrt(gap_error/gap_samples)<.035);
  previous=frame;buffer(3,previous.data(),sizeof(previous));
  // A newly clear gap / newly opaque region must replace history immediately.
  for(float transmission:{1.f,0.f}) {
    for(UINT i=0;i<W*H;++i)pixels[i*4+3]=transmission;
    run();
    for(UINT i=0;i<W*H;++i)assert(std::abs(actual[i*4+3]-transmission)<1.e-6f);
  }
  // Reprojection cuts must not drag the accumulated cloud into the new view.
  previous[0][0]=200.f;buffer(3,previous.data(),sizeof(previous));signal(0,17.f);run();
  for(UINT i=0;i<actual.size();++i)assert(std::abs(actual[i]-pixels[i])<1.e-5f);
  std::cout<<"PASS analytic moving-detail reconstruction, no HDR/opacity overshoot, constant HDR energy and finite output\n";
}
