/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11.h>
#include <d3dcompiler.h>
#include <wrl/client.h>
#include <array>
#include <cassert>
#include <cmath>
#include <cstring>
#include <iostream>
using Microsoft::WRL::ComPtr;
int main(int argc,char**) {
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&context)));
  const char* source=R"(
#include "common.hlsli"
RWStructuredBuffer<float4> output:register(u0);
[numthreads(8,1,1)] void main(uint id:SV_DispatchThreadID) {
  float3 p=float3(-6000.f+id*1500.f,0,1700);
  output[id]=float4(CloudWeather(p),CloudDensity(p,3u,0),CloudDensity(p,0u,0),CloudDensity(p,1u,0));
  if(id==0) {
    output[8]=float4(CloudInterval(0,float3(0,0,1)),ClassicWaterAmbient(asuint(frame[38].w)),ClassicFogBrightness(asuint(frame[38].w)));
    float3 base=float3(-4500,0,CloudBase-10.f);
    output[9]=float4(CloudDensity(base,3u,0),CloudDensity(base,0u,0),CloudDensity(base,1u,0),
        CloudDensity(float3(base.xy,CloudMinimum()-1.f),3u,0));
  }
})";
  ComPtr<ID3DBlob> code,errors;
  HRESULT compiled=D3DCompile(source,std::strlen(source),"src/games/thewitcher3classic/clouds/material_fixture.hlsl",nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,
      "main","cs_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&code,&errors);
  if(errors)std::cerr<<static_cast<const char*>(errors->GetBufferPointer());assert(SUCCEEDED(compiled));
  ComPtr<ID3D11ComputeShader> shader;
  assert(SUCCEEDED(device->CreateComputeShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&shader)));
  std::array<std::array<float,4>,269> frame{};frame[66][0]=5;
  std::array<std::array<float,4>,5> parameters{};parameters[2]={1,1,1,1};
  parameters[3]={1,1,1,.5f};parameters[4]={1,1,16,64};
  D3D11_BUFFER_DESC bd{sizeof(frame),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
  ComPtr<ID3D11Buffer> frame_buffer,parameters_buffer,output,read;
  assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&frame_buffer)));
  bd.ByteWidth=sizeof(parameters);assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&parameters_buffer)));
  D3D11_SUBRESOURCE_DATA initial{};
  bd={160,D3D11_USAGE_DEFAULT,D3D11_BIND_UNORDERED_ACCESS,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
  assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&output)));
  ComPtr<ID3D11UnorderedAccessView> uav;assert(SUCCEEDED(device->CreateUnorderedAccessView(output.Get(),nullptr,&uav)));
  bd={160,D3D11_USAGE_STAGING,0,D3D11_CPU_ACCESS_READ};assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&read)));
  std::array<float,64> weather{};for(unsigned i=0;i<64;++i)weather[i]=i%8<4?0.f:1.f;
  D3D11_TEXTURE2D_DESC td{8,8,1,1,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  initial={weather.data(),32};ComPtr<ID3D11Texture2D> weather_texture;
  ComPtr<ID3D11ShaderResourceView> weather_view,noise_view;
  assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&weather_texture)));
  D3D11_SHADER_RESOURCE_VIEW_DESC array_view{};array_view.Format=td.Format;array_view.ViewDimension=D3D11_SRV_DIMENSION_TEXTURE2DARRAY;
  array_view.Texture2DArray.MipLevels=1;array_view.Texture2DArray.ArraySize=1;
  assert(SUCCEEDED(device->CreateShaderResourceView(weather_texture.Get(),&array_view,&weather_view)));
  std::array<float,4> noise{.8f,.8f,.6f,.65f};ComPtr<ID3D11Texture3D> noise_texture;
  D3D11_TEXTURE3D_DESC volume{1,1,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  initial={noise.data(),16,16};assert(SUCCEEDED(device->CreateTexture3D(&volume,&initial,&noise_texture)));
  assert(SUCCEEDED(device->CreateShaderResourceView(noise_texture.Get(),nullptr,&noise_view)));
  D3D11_SAMPLER_DESC sampler_desc{};sampler_desc.Filter=D3D11_FILTER_MIN_MAG_MIP_POINT;
  sampler_desc.AddressU=sampler_desc.AddressV=sampler_desc.AddressW=D3D11_TEXTURE_ADDRESS_WRAP;
  sampler_desc.MaxLOD=D3D11_FLOAT32_MAX;ComPtr<ID3D11SamplerState> sampler;
  assert(SUCCEEDED(device->CreateSamplerState(&sampler_desc,&sampler)));
  context->CSSetShader(shader.Get(),nullptr,0);context->CSSetSamplers(0,1,sampler.GetAddressOf());
  ID3D11ShaderResourceView* inputs[]{noise_view.Get(),weather_view.Get()};context->CSSetShaderResources(0,2,inputs);
  context->CSSetConstantBuffers(0,1,frame_buffer.GetAddressOf());context->CSSetConstantBuffers(2,1,parameters_buffer.GetAddressOf());
  auto run=[&] {
    context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    context->UpdateSubresource(parameters_buffer.Get(),0,nullptr,parameters.data(),0,0);
    context->CSSetUnorderedAccessViews(0,1,uav.GetAddressOf(),nullptr);context->Dispatch(1,1,1);
    ID3D11UnorderedAccessView* empty=nullptr;context->CSSetUnorderedAccessViews(0,1,&empty,nullptr);
    context->CopyResource(read.Get(),output.Get());D3D11_MAPPED_SUBRESOURCE mapped{};
    assert(SUCCEEDED(context->Map(read.Get(),0,D3D11_MAP_READ,0,&mapped)));
    std::array<std::array<float,4>,10> result{};std::memcpy(result.data(),mapped.pData,160);context->Unmap(read.Get(),0);
    for(auto row:result)for(float v:row)assert(std::isfinite(v));return result;
  };
  auto neutral=run();assert(neutral[0][0]==0 &&neutral[1][0]==1 &&neutral[1][1]>0);
  for(unsigned i=0;i<8;++i)assert(neutral[i][1]<=neutral[i][3] &&neutral[i][3]<=neutral[i][2]);
  assert(neutral[9][0]>0 &&neutral[9][0]<=neutral[9][2] &&neutral[9][2]<=neutral[9][1] &&neutral[9][3]==0);
  for(float size:{.25f,2.f,4.f}) {
    parameters[2][2]=size;auto changed=run();
    for(unsigned i=0;i<8;++i)assert(changed[i][0]==neutral[i][0]);
    assert(changed[8][0]==neutral[8][0] &&changed[8][1]==neutral[8][1]);
  }
  parameters[2][2]=1;parameters[2][1]=2;auto dense=run();
  for(unsigned i=0;i<8;++i)assert(std::abs(dense[i][1]-2*neutral[i][1])<1.e-6f);
  parameters[2][1]=0;auto clear=run();for(unsigned i=0;i<8;++i)assert(clear[i][1]==0);
  parameters[2][1]=1;parameters[2][0]=0;clear=run();for(unsigned i=0;i<8;++i)assert(clear[i][0]==0 &&clear[i][1]==0);
  parameters[2][0]=1;parameters[2][3]=2;auto thick=run();
  assert(std::abs(thick[8][0]-neutral[8][0])<.1f &&thick[8][0]<1200
      &&std::abs(thick[8][1]-3600)<.1f);parameters[2][3]=1;
  // The reported scene uses 200% detail, 50% detail size and a 150% layer.
  // Verify bounded density and optical scaling at those settings as well.
  parameters[3]={1,2,.5f,1};parameters[2][3]=1.5f;
  auto detailed=run();
  for(unsigned i=0;i<8;++i)assert(detailed[i][1]>=0 &&detailed[i][1]<=detailed[i][3]+1.e-6f &&detailed[i][3]<=detailed[i][2]+1.e-6f);
  parameters[2][1]=4;auto detailed_dense=run();
  for(unsigned i=0;i<8;++i)assert(std::abs(detailed_dense[i][1]-4*detailed[i][1])<1.e-6f);
  assert(detailed_dense[9][3]==0);
  parameters[2]={1,1,1,1};parameters[3]={1,1,1,.5f};
  uint32_t tag=0xdc000000u|2047u;std::memcpy(&frame[38][3],&tag,4);
  auto night=run();assert(night[8][2]==1 &&night[8][3]==0);
  tag=0xdc000000u|(511u<<12);std::memcpy(&frame[38][3],&tag,4);
  night=run();assert(night[8][2]==0 &&night[8][3]==1);
  std::cout<<"PASS cloud weather/size isolation, density/coverage/thickness, hanging-base bounds, reported detail settings and independent night tags\n";
}
