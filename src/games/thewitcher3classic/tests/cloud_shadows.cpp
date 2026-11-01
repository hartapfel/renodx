/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3dcompiler.h>
#include <cassert>
#include <cmath>
#include <cstring>
#include <iostream>
#include <thread>
#include <vector>
#include "cloud_shader_baseline.hpp"
#include "../clouds/runtime.hpp"
#include "../../../utils/float16.hpp"
using Microsoft::WRL::ComPtr;
int main(int argc,char** argv) {
  witcher3classic::clouds::coverage=witcher3classic::clouds::density=1.f;
  witcher3classic::clouds::size=witcher3classic::clouds::thickness=1.f;
  const bool benchmark=argc>2 &&std::string_view(argv[2])=="--benchmark";
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> base;ComPtr<ID3D11DeviceContext1> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&base)));
  assert(SUCCEEDED(base.As(&context)));
  std::array<std::array<float,4>,269> frame{};
  frame[0]={10,10,100,1};frame[66]={5,0,0,0};frame[68]={0,1,0,0};
  std::array<std::array<float,4>,2> light{{{.2f,.4f,.8944272f,1},{20,15,10,0}}};
  D3D11_BUFFER_DESC bd{sizeof(frame),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
  D3D11_SUBRESOURCE_DATA data{frame.data()};ComPtr<ID3D11Buffer> frame_buffer,light_buffer;
  assert(SUCCEEDED(device->CreateBuffer(&bd,&data,&frame_buffer)));
  bd.ByteWidth=sizeof(light);data.pSysMem=light.data();assert(SUCCEEDED(device->CreateBuffer(&bd,&data,&light_buffer)));
  std::array<float,64> scene_clock{};ComPtr<ID3D11Buffer> clock_buffer;
  bd.ByteWidth=sizeof(scene_clock);data.pSysMem=scene_clock.data();
  assert(SUCCEEDED(device->CreateBuffer(&bd,&data,&clock_buffer)));
  context->PSSetConstantBuffers(0,1,clock_buffer.GetAddressOf());
  std::array<float,64> weather_pixels{};
  D3D11_TEXTURE2D_DESC td{8,8,1,2,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  D3D11_SUBRESOURCE_DATA layers[2]{{weather_pixels.data(),32},{weather_pixels.data(),32}};
  ComPtr<ID3D11Texture2D> weather;ComPtr<ID3D11ShaderResourceView> weather_view;
  assert(SUCCEEDED(device->CreateTexture2D(&td,layers,&weather)));
  assert(SUCCEEDED(device->CreateShaderResourceView(weather.Get(),nullptr,&weather_view)));
  context->VSSetConstantBuffers(13,1,frame_buffer.GetAddressOf());
  context->PSSetConstantBuffers(13,1,light_buffer.GetAddressOf());
  witcher3classic::clouds::DeviceData runtime;
  runtime.context=context;
  auto& pipeline=runtime.pipeline;
  uint64_t serial=0;
  auto generate=[&](float coverage,float quality,bool enabled=true) {
    weather_pixels.fill(coverage);
    for(UINT layer=0;layer<2;++layer)context->UpdateSubresource(weather.Get(),layer,nullptr,weather_pixels.data(),32,0);
    context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
    context->UpdateSubresource(clock_buffer.Get(),0,nullptr,scene_clock.data(),0,0);
    assert(pipeline.PrepareShadow(context.Get(),frame_buffer.Get(),light_buffer.Get(),weather_view.Get(),++serial,quality,enabled));
    ComPtr<ID3D11Buffer> restored;context->VSGetConstantBuffers(13,1,&restored);assert(restored==frame_buffer);
    restored.Reset();context->PSGetConstantBuffers(13,1,&restored);assert(restored==light_buffer);
    auto views=pipeline.ShadowViews();ComPtr<ID3D11Resource> resource;ComPtr<ID3D11Texture2D> texture,read;
    views[0]->GetResource(&resource);assert(SUCCEEDED(resource.As(&texture)));
    texture->GetDesc(&td);td.Usage=D3D11_USAGE_STAGING;td.BindFlags=0;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
    assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&read)));
    context->CopyResource(read.Get(),texture.Get());D3D11_MAPPED_SUBRESOURCE mapped{};
    assert(SUCCEEDED(context->Map(read.Get(),0,D3D11_MAP_READ,0,&mapped)));
    std::vector<float> transmission(td.Width*td.Height);
    for(UINT y=0;y<td.Height;++y)for(UINT x=0;x<td.Width;++x) {
      float t=renodx::utils::float16::Decode(reinterpret_cast<const uint16_t*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)[x]);
      assert(std::isfinite(t) &&t>=0.f &&t<=1.f);transmission[y*td.Width+x]=t;
    }
    context->Unmap(read.Get(),0);return transmission;
  };
  for(float quality:{0.f,1.f,2.f,3.f}) {
    auto clear=generate(0,quality);for(float t:clear)assert(t==1.f);
  }
  auto cloudy=generate(.7f,1);UINT shadows=0;for(float t:cloudy)if(t<.8f)++shadows;
  if(argc>3 &&std::string_view(argv[2])=="--dump-defaults") {
    std::ofstream dump(std::string(argv[3])+"-shadow.bin",std::ios::binary);
    dump.write(reinterpret_cast<const char*>(cloudy.data()),cloudy.size()*sizeof(float));
  }
  assert(shadows>cloudy.size()/20);
  // Sub-texel camera movement cannot move a world-anchored shadow grid.
  frame[0][0]+=.1f;auto still=generate(.7f,1);assert(cloudy==still);
  frame[67][0]+=10.f;auto wind=generate(.7f,1);float difference=0;
  for(UINT i=0;i<wind.size();++i)difference+=std::abs(wind[i]-still[i]);assert(difference>1.f);
#ifndef CLASSIC_CLOUD_BASELINE
  scene_clock[0]=120.f;auto evolved=generate(.7f,1);difference=0;
  for(UINT i=0;i<evolved.size();++i)difference+=std::abs(evolved[i]-wind[i]);assert(difference>1.f);
  assert(evolved==generate(.7f,1));scene_clock[0]=0;
#endif
  // Exercise the actual production lookup at different heights on the same
  // light ray, outside the map, with native fallback and with shadows disabled.
  const char* shader=R"(
#include "src/games/thewitcher3classic/clouds/shadow_inputs.hlsli"
cbuffer Points:register(b0) {float4 locations[4];}
RWStructuredBuffer<float> output:register(u0);
[numthreads(4,1,1)] void main(uint id:SV_DispatchThreadID) {
  output[id]=ClassicCloudShadow(locations[id].xyz,.73f);
})";
  ComPtr<ID3DBlob> code,errors;
  HRESULT compile=D3DCompile(shader,std::strlen(shader),nullptr,nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,
      "main","cs_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&code,&errors);
  if(FAILED(compile) &&errors)std::cerr<<static_cast<const char*>(errors->GetBufferPointer());assert(SUCCEEDED(compile));
  ComPtr<ID3D11ComputeShader> sample;assert(SUCCEEDED(device->CreateComputeShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&sample)));
  std::array<std::array<float,4>,4> points{{{0,0,0,0},{80,160,357.77088f,0},{1000000,0,0,0},{-300,500,200,0}}};
  bd={64,D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};data={points.data()};ComPtr<ID3D11Buffer> point_buffer,output,read;
  assert(SUCCEEDED(device->CreateBuffer(&bd,&data,&point_buffer)));
  bd={16,D3D11_USAGE_DEFAULT,D3D11_BIND_UNORDERED_ACCESS,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,4};
  assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&output)));
  ComPtr<ID3D11UnorderedAccessView> output_view;assert(SUCCEEDED(device->CreateUnorderedAccessView(output.Get(),nullptr,&output_view)));
  bd={16,D3D11_USAGE_STAGING,0,D3D11_CPU_ACCESS_READ};assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&read)));
  auto lookup=[&](bool bind=true) {
    auto views=pipeline.ShadowViews();if(!bind)views={};
    context->CSSetShaderResources(126,2,views.data());context->CSSetShader(sample.Get(),nullptr,0);
    context->CSSetConstantBuffers(0,1,point_buffer.GetAddressOf());context->CSSetUnorderedAccessViews(0,1,output_view.GetAddressOf(),nullptr);
    context->Dispatch(1,1,1);ID3D11UnorderedAccessView* empty=nullptr;context->CSSetUnorderedAccessViews(0,1,&empty,nullptr);
    context->CopyResource(read.Get(),output.Get());D3D11_MAPPED_SUBRESOURCE mapped{};
    assert(SUCCEEDED(context->Map(read.Get(),0,D3D11_MAP_READ,0,&mapped)));
    std::array<float,4> result{};std::memcpy(result.data(),mapped.pData,16);context->Unmap(read.Get(),0);
    ID3D11ShaderResourceView* clear[2]{};context->CSSetShaderResources(126,2,clear);return result;
  };
  auto sampled=lookup();assert(std::abs(sampled[0]-sampled[1])<.0001f &&sampled[2]==1.f);
  sampled=lookup(false);for(float t:sampled)assert(t==.73f);
  generate(1,1,false);sampled=lookup();for(float t:sampled)assert(t==1.f);
  // Moon/sun shadows remain available below the native 0.25 elevation cutoff.
  light[0]={.9967949f,0,.08f,1};auto low=generate(1,0);float total=0;for(float t:low)total+=t;
  assert(total<float(low.size())*.8f);
  light[0]={1,0,-.1f,1};generate(1,0);sampled=lookup();for(float t:sampled)assert(t==.73f);
  {
    // Persistent reserved inputs restore all native stages, including preserving
    // a binding installed by a later owner before the frame ends.
    auto owned=pipeline.ShadowViews();
    for(UINT stage=0;stage<3;++stage) {
      runtime.saved_shadow[stage][0]=weather_view;
      if(stage==0)context->PSSetShaderResources(126,2,owned.data());
      else if(stage==1)context->VSSetShaderResources(126,2,owned.data());
      else context->CSSetShaderResources(126,2,owned.data());
    }
    context->CSSetShaderResources(126,1,&owned[1]);runtime.shadow_bound=true;runtime.RestoreShadows();
    ComPtr<ID3D11ShaderResourceView> restored;
    context->PSGetShaderResources(126,1,&restored);assert(restored==weather_view);
    restored.Reset();context->VSGetShaderResources(126,1,&restored);assert(restored==weather_view);
    restored.Reset();context->CSGetShaderResources(126,1,&restored);assert(restored.Get()==owned[1]);
    restored.Reset();context->CSGetShaderResources(127,1,&restored);assert(!restored);
    ID3D11ShaderResourceView* clear[2]{};
    context->PSSetShaderResources(126,2,clear);context->VSSetShaderResources(126,2,clear);context->CSSetShaderResources(126,2,clear);
  }
#ifndef CLASSIC_CLOUD_BASELINE
  {
    using witcher3classic::clouds::coverage;
    using witcher3classic::clouds::density;
    using witcher3classic::clouds::size;
    using witcher3classic::clouds::thickness;
    light[0]={.2f,.4f,.8944272f,1};
    auto neutral=generate(.7f,1);
    density=2.f;auto dense=generate(.7f,1);float change=0;
    for(UINT i=0;i<dense.size();++i) {assert(dense[i]<=neutral[i]+.001f);change+=neutral[i]-dense[i];}
    assert(change>1.f);density=1.f;
    coverage=1.5f;auto covered=generate(.7f,1);change=0;
    for(UINT i=0;i<covered.size();++i) {assert(covered[i]<=neutral[i]+.001f);change+=neutral[i]-covered[i];}
    assert(change>1.f);coverage=1.f;
    size=2.f;auto large=generate(.7f,1);change=0;
    for(UINT i=0;i<large.size();++i)change+=std::abs(large[i]-neutral[i]);assert(change>1.f);size=1.f;
    thickness=2.f;auto thick=generate(.7f,1);change=0;
    for(UINT i=0;i<thick.size();++i)change+=std::abs(thick[i]-neutral[i]);assert(change>1.f);thickness=1.f;
    coverage=0.f;auto empty=generate(1,1);for(float t:empty)assert(t==1.f);coverage=1.f;
    density=0.f;empty=generate(1,1);for(float t:empty)assert(t==1.f);density=1.f;
    coverage=2.f;auto override=generate(0,1);change=0;for(float t:override)change+=1.f-t;assert(change>1.f);coverage=1.f;
    for(float quality:{4.f,5.f,1.f})generate(.7f,quality);
    std::cout<<"PASS shared appearance controls, zero cloud shadows, coverage override and higher-quality shadow maps\n";
  }
#endif
  if(benchmark) {
    light[0]={.2f,.4f,.8944272f,1};
    context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
    ComPtr<ID3D11Query> disjoint,start,end;D3D11_QUERY_DESC q{D3D11_QUERY_TIMESTAMP_DISJOINT};
    assert(SUCCEEDED(device->CreateQuery(&q,&disjoint)));q.Query=D3D11_QUERY_TIMESTAMP;
    assert(SUCCEEDED(device->CreateQuery(&q,&start)));assert(SUCCEEDED(device->CreateQuery(&q,&end)));
    for(float coverage:{0.f,.7f,1.f})for(float quality:{0.f,1.f,2.f,3.f,4.f,5.f}) {
      generate(coverage,quality);
      context->Begin(disjoint.Get());context->End(start.Get());
      for(UINT i=0;i<12;++i)assert(pipeline.PrepareShadow(context.Get(),frame_buffer.Get(),light_buffer.Get(),weather_view.Get(),++serial,quality,true));
      context->End(end.Get());context->End(disjoint.Get());D3D11_QUERY_DATA_TIMESTAMP_DISJOINT time{};
      while(context->GetData(disjoint.Get(),&time,sizeof(time),0)==S_FALSE)std::this_thread::yield();
      UINT64 first=0,last=0;assert(!time.Disjoint &&time.Frequency);
      assert(context->GetData(start.Get(),&first,8,0)==S_OK);assert(context->GetData(end.Get(),&last,8,0)==S_OK);
      std::cout<<"Shadow GPU weather="<<coverage<<" quality="<<quality<<" "<<double(last-first)*1000./time.Frequency/12.<<" ms\n";
    }
  }
  std::cout<<"PASS cloud shadow transmission bounds, clear weather, wind animation, stable world grid, elevated receivers, edge fade, low sun/moon, toggle, native fallback and b13 state\n";
}
