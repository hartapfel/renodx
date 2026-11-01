/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11.h>
#include <d3dcompiler.h>
#include <wrl/client.h>
#include <array>
#include <algorithm>
#include <vector>
#include <cassert>
#include <cmath>
#include <cstring>
#include <iostream>
using Microsoft::WRL::ComPtr;
int main(int argc,char**) {
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&context)));
  ComPtr<ID3DBlob> code,errors;
  HRESULT compiled=D3DCompileFromFile(L"src/games/thewitcher3classic/clouds/0xF3C60007.cs_5_0.hlsl",nullptr,
      D3D_COMPILE_STANDARD_FILE_INCLUDE,"main","cs_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&code,&errors);
  if(errors)std::cerr<<static_cast<const char*>(errors->GetBufferPointer());assert(SUCCEEDED(compiled));
  ComPtr<ID3D11ComputeShader> shader;
  assert(SUCCEEDED(device->CreateComputeShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&shader)));
  std::array<std::array<float,4>,269> frame{};frame[66]={5,0,0,0};frame[68]={0,1,0,0};
  auto old_frame=frame;
  std::array<std::array<float,4>,5> parameters{};
  D3D11_BUFFER_DESC bd{sizeof(frame),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
  ComPtr<ID3D11Buffer> current,previous,settings;
  assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&current)));
  assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&previous)));
  bd.ByteWidth=sizeof(parameters);assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&settings)));
  D3D11_TEXTURE2D_DESC desc{64,64,1,2,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  ComPtr<ID3D11Texture2D> source,history,output,read;
  assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&source)));
  desc={128,128,1,1,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_UNORDERED_ACCESS};
  assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&history)));
  assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&output)));
  desc.Usage=D3D11_USAGE_STAGING;desc.BindFlags=0;desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&read)));
  D3D11_SHADER_RESOURCE_VIEW_DESC srv{};srv.Format=DXGI_FORMAT_R32_FLOAT;srv.ViewDimension=D3D11_SRV_DIMENSION_TEXTURE2DARRAY;
  srv.Texture2DArray.MipLevels=1;srv.Texture2DArray.ArraySize=2;
  ComPtr<ID3D11ShaderResourceView> source_view,history_view;
  assert(SUCCEEDED(device->CreateShaderResourceView(source.Get(),&srv,&source_view)));
  srv.Texture2DArray.ArraySize=1;assert(SUCCEEDED(device->CreateShaderResourceView(history.Get(),&srv,&history_view)));
  D3D11_UNORDERED_ACCESS_VIEW_DESC uav{};uav.Format=DXGI_FORMAT_R32_FLOAT;uav.ViewDimension=D3D11_UAV_DIMENSION_TEXTURE2DARRAY;
  uav.Texture2DArray.ArraySize=1;ComPtr<ID3D11UnorderedAccessView> output_view;
  assert(SUCCEEDED(device->CreateUnorderedAccessView(output.Get(),&uav,&output_view)));
  D3D11_SAMPLER_DESC sampler{};sampler.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;
  sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D11_TEXTURE_ADDRESS_WRAP;sampler.MaxLOD=D3D11_FLOAT32_MAX;
  ComPtr<ID3D11SamplerState> wrap;assert(SUCCEEDED(device->CreateSamplerState(&sampler,&wrap)));
  context->CSSetShader(shader.Get(),nullptr,0);context->CSSetSamplers(0,1,wrap.GetAddressOf());
  context->CSSetConstantBuffers(0,1,current.GetAddressOf());context->CSSetConstantBuffers(2,1,settings.GetAddressOf());
  context->CSSetConstantBuffers(3,1,previous.GetAddressOf());
  context->CSSetShaderResources(1,1,source_view.GetAddressOf());context->CSSetShaderResources(3,1,history_view.GetAddressOf());
  auto run=[&] {
    context->UpdateSubresource(current.Get(),0,nullptr,frame.data(),0,0);
    context->UpdateSubresource(previous.Get(),0,nullptr,old_frame.data(),0,0);
    context->UpdateSubresource(settings.Get(),0,nullptr,parameters.data(),0,0);
    context->CSSetUnorderedAccessViews(0,1,output_view.GetAddressOf(),nullptr);context->Dispatch(16,16,1);
    ID3D11UnorderedAccessView* empty=nullptr;context->CSSetUnorderedAccessViews(0,1,&empty,nullptr);
    context->CopyResource(read.Get(),output.Get());D3D11_MAPPED_SUBRESOURCE mapped{};
    assert(SUCCEEDED(context->Map(read.Get(),0,D3D11_MAP_READ,0,&mapped)));
    std::vector<float> values(128*128);
    for(unsigned y=0;y<128;++y)std::memcpy(values.data()+y*128,static_cast<const char*>(mapped.pData)+y*mapped.RowPitch,512);
    context->Unmap(read.Get(),0);for(float v:values)assert(std::isfinite(v)&&v>=0&&v<=1);return values;
  };
  std::array<float,64*64> pixels{};
  for(float value:{0.f,.35f,1.f}) {
    pixels.fill(value);for(unsigned layer=0;layer<2;++layer)context->UpdateSubresource(source.Get(),layer,nullptr,pixels.data(),256,0);
    for(float actual:run())assert(std::abs(actual-value)<1.e-6f);
  }
  pixels.fill(0);context->UpdateSubresource(source.Get(),0,nullptr,pixels.data(),256,0);
  pixels.fill(1);context->UpdateSubresource(source.Get(),1,nullptr,pixels.data(),256,0);
  frame[66][3]=.37f;for(float v:run())assert(std::abs(v-.37f)<1.e-6f);frame[66][3]=0;
  for(unsigned y=0;y<64;++y)for(unsigned x=0;x<64;++x)pixels[y*64+x]=x<32?0.f:1.f;
  context->UpdateSubresource(source.Get(),0,nullptr,pixels.data(),256,0);
  auto edge=run();double mean=0;float maximum_jump=0;
  for(unsigned i=0;i<edge.size();++i) {
    mean+=edge[i];if(i%128)maximum_jump=std::max(maximum_jump,std::abs(edge[i]-edge[i-1]));
  }
  assert(std::abs(mean/edge.size()-.5)<1.e-6 &&maximum_jump<.15f &&maximum_jump>.01f);
  context->UpdateSubresource(history.Get(),0,nullptr,edge.data(),512,0);parameters[1]={0,0,0,1};
  frame[67][0]=.05f;auto wind=run();
  for(unsigned i=0;i<edge.size();++i)assert(std::abs(wind[i]-edge[i])<2.e-6f);
  frame[67][0]=200.f;auto reset=run();double reset_mean=0,shift=0;
  for(unsigned i=0;i<edge.size();++i){reset_mean+=reset[i];shift+=std::abs(reset[i]-edge[i]);}
  assert(std::abs(reset_mean/edge.size()-.5)<1.e-6 &&shift>100);
  frame[67][0]=0;frame[66][0]=10;auto resized=run();
  for(unsigned y=0;y<128;++y)for(unsigned x=0;x<64;++x)
    assert(std::abs(resized[y*128+x]-resized[y*128+x+64])<2.e-6f);
  frame=old_frame;
  // Closed-form transition: clear -> opaque and opaque -> clear, including
  // equivalent elapsed time divided into different frame intervals.
  std::vector<float> old(128*128,0.f);parameters[1]={.2f,0,0,1};
  pixels.fill(1);context->UpdateSubresource(source.Get(),0,nullptr,pixels.data(),256,0);
  for(unsigned n=1;n<=8;++n) {
    context->UpdateSubresource(history.Get(),0,nullptr,old.data(),512,0);old=run();
    for(float v:old)assert(std::abs(v-(1.f-std::pow(.8f,float(n))))<2.e-6f);
  }
  pixels.fill(0);context->UpdateSubresource(source.Get(),0,nullptr,pixels.data(),256,0);
  for(unsigned n=1;n<=8;++n) {
    context->UpdateSubresource(history.Get(),0,nullptr,old.data(),512,0);old=run();
    for(float v:old)assert(std::abs(v-(1.f-std::pow(.8f,8.f))*std::pow(.8f,float(n)))<2.e-6f);
  }
  old.assign(old.size(),0);context->UpdateSubresource(history.Get(),0,nullptr,old.data(),512,0);
  pixels.fill(1);context->UpdateSubresource(source.Get(),0,nullptr,pixels.data(),256,0);
  parameters[1][0]=1.f-std::pow(.8f,8.f);for(float v:run())assert(std::abs(v-(1.f-std::pow(.8f,8.f)))<2.e-6f);
  parameters[1][3]=0;for(float v:run())assert(v==1.f);
  std::cout<<"PASS weather blend, constant/mean preservation, sharp-edge filtering, wind/scale/origin reprojection, bounded smooth in/out fades, frame-rate-independent decay and history reset\n";
}
