/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3dcompiler.h>
#include <cassert>
#include <cmath>
#include <cstring>
#include <iostream>
#include <filesystem>
#include <fstream>
#include <vector>
#include "../water/pipeline.hpp"
using Microsoft::WRL::ComPtr;
int main(int argc,char**) {
  witcher3classic::water::clarity=1.f; // Fixed reference medium, independent of UI defaults.
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> base;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&base)));
  ComPtr<ID3D11DeviceContext1> context; assert(SUCCEEDED(base.As(&context)));
  std::array<std::array<float,4>,269> frame{};
  frame[0]={0,0,10,0}; frame[1]={1,0,0,0};frame[2]={0,1,0,0};frame[3]={0,0,-1,0};frame[4]={0,0,10,1};
  frame[13]={1,0,0,0};frame[14]={0,1,0,0};frame[15]={0,0,1,1};frame[16]={0,0,-.2f,0};
  frame[21]={-5,5,1,1};frame[22]={-1,1,.2f,5000};
  frame[210]={2.f/64,0,0,0};frame[211]={0,-2.f/4,0,0};
  frame[212]={0,0,50,5};frame[213]={-1.f+1.f/64,1.f-1.f/4,-1,0};
  frame[40]={1000,2000,4000,0}; // Poison atmospheric source: it is not water ambient.
  D3D11_BUFFER_DESC bd{sizeof(frame),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
  D3D11_SUBRESOURCE_DATA initial{frame.data()};ComPtr<ID3D11Buffer> constants;
  assert(SUCCEEDED(device->CreateBuffer(&bd,&initial,&constants)));
  std::vector<float> pool(128*8*4,1000.f);
  for(UINT y=0;y<4;++y)for(UINT x=0;x<64;++x)for(UINT c=0;c<4;++c)pool[(y*128+x)*4+c]=float(2*(c+1));
  D3D11_TEXTURE2D_DESC td{128,8,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  D3D11_SUBRESOURCE_DATA pixels{pool.data(),128*16};
  ComPtr<ID3D11Texture2D> source;ComPtr<ID3D11ShaderResourceView> source_view;
  assert(SUCCEEDED(device->CreateTexture2D(&td,&pixels,&source)));
  assert(SUCCEEDED(device->CreateShaderResourceView(source.Get(),nullptr,&source_view)));
  witcher3classic::water::Pipeline water;
  assert(water.Capture(context.Get(),source_view.Get(),constants.Get(),64,4,1));
  assert(!water.Bind(context.Get(),2));
  ID3D11ShaderResourceView* sentinel[]={source_view.Get(),source_view.Get(),source_view.Get()};
  context->PSSetShaderResources(113,3,sentinel);
  assert(water.Bind(context.Get(),1));
  assert(!water.Bind(context.Get(),1));
  // Copy formats, active-rectangle isolation, frame CB -> structured SRV, and
  // binding lifetime are exercised through the real production pipeline.
  ComPtr<ID3D11ShaderResourceView> frame_view,scene_view;
  context->PSGetShaderResources(113,1,&frame_view);context->PSGetShaderResources(114,1,&scene_view);
  ComPtr<ID3D11Resource> resource;frame_view->GetResource(&resource);
  D3D11_BUFFER_DESC read_bd{sizeof(frame),D3D11_USAGE_STAGING,0,D3D11_CPU_ACCESS_READ};
  ComPtr<ID3D11Buffer> read_frame;assert(SUCCEEDED(device->CreateBuffer(&read_bd,nullptr,&read_frame)));
  context->CopyResource(read_frame.Get(),resource.Get());
  D3D11_MAPPED_SUBRESOURCE mapped{};assert(SUCCEEDED(context->Map(read_frame.Get(),0,D3D11_MAP_READ,0,&mapped)));
  assert(std::memcmp(mapped.pData,frame.data(),sizeof(frame))==0);context->Unmap(read_frame.Get(),0);
  scene_view->GetResource(&resource);ComPtr<ID3D11Texture2D> scene;assert(SUCCEEDED(resource.As(&scene)));
  scene->GetDesc(&td);assert(td.Width==64 && td.Height==4);
  td.BindFlags=D3D11_BIND_RENDER_TARGET;
  ComPtr<ID3D11Texture2D> output,readback;assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&output)));
  ComPtr<ID3D11RenderTargetView> target;assert(SUCCEEDED(device->CreateRenderTargetView(output.Get(),nullptr,&target)));
  context->OMSetRenderTargets(1,target.GetAddressOf(),nullptr);
  td.BindFlags=0;td.Usage=D3D11_USAGE_STAGING;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&readback)));
  td.BindFlags=D3D11_BIND_SHADER_RESOURCE;td.Usage=D3D11_USAGE_DEFAULT;td.CPUAccessFlags=0;
  pool.assign(64*4*4,.2f/12.f);pixels={pool.data(),64*16};ComPtr<ID3D11Texture2D> depth;ComPtr<ID3D11ShaderResourceView> depth_view;
  assert(SUCCEEDED(device->CreateTexture2D(&td,&pixels,&depth)));
  assert(SUCCEEDED(device->CreateShaderResourceView(depth.Get(),nullptr,&depth_view)));
  context->PSSetShaderResources(15,1,depth_view.GetAddressOf());
  const char* vs_text="float4 main(uint id:SV_VertexID):SV_Position {float2 uv=float2((id<<1)&2,id&2);return float4(uv*float2(2,-2)+float2(-1,1),0,1);}";
  ComPtr<ID3DBlob> vs_code,ps_code,trace_code,atmosphere_code,errors;
  assert(SUCCEEDED(D3DCompile(vs_text,strlen(vs_text),nullptr,nullptr,nullptr,"main","vs_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&vs_code,&errors)));
  const auto working_directory=std::filesystem::current_path();
  std::filesystem::current_path("src/games/thewitcher3classic/water");
  HRESULT compiled=D3DCompileFromFile(L"../tests/water_test.hlsl",nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,"main","ps_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&ps_code,&errors);
  HRESULT trace_compiled=D3DCompileFromFile(L"../tests/water_test.hlsl",nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,"trace","ps_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&trace_code,&errors);
  if(errors)std::cerr<<static_cast<const char*>(errors->GetBufferPointer());assert(SUCCEEDED(trace_compiled));
  assert(SUCCEEDED(D3DCompileFromFile(L"../tests/water_test.hlsl",nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,"atmosphere","ps_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&atmosphere_code,&errors)));
  std::filesystem::current_path(working_directory);
  if(errors)std::cerr<<static_cast<const char*>(errors->GetBufferPointer());assert(SUCCEEDED(compiled));
  ComPtr<ID3D11VertexShader> vs;ComPtr<ID3D11PixelShader> ps;
  assert(SUCCEEDED(device->CreateVertexShader(vs_code->GetBufferPointer(),vs_code->GetBufferSize(),nullptr,&vs)));
  assert(SUCCEEDED(device->CreatePixelShader(ps_code->GetBufferPointer(),ps_code->GetBufferSize(),nullptr,&ps)));
  context->VSSetShader(vs.Get(),nullptr,0);context->PSSetShader(ps.Get(),nullptr,0);
  context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  D3D11_VIEWPORT viewport{0,0,64,4,0,1};context->RSSetViewports(1,&viewport);
  context->Draw(3,0);context->CopyResource(readback.Get(),output.Get());
  assert(SUCCEEDED(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped)));
  const double f0=std::pow((1.-1.333)/(1.+1.333),2.);
  for(UINT y=0;y<4;++y)for(UINT x=0;x<64;++x) {
    const float* value=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)+x*4;
    for(UINT c=0;c<4;++c)assert(std::isfinite(value[c]));
    double t=double(x)/63.,distance=t*20.;
    if(y==0) {
      double ct=std::sqrt(1.-(1.-t*t)/(1.333*1.333));
      double f=.5*(std::pow((t-1.333*ct)/(t+1.333*ct),2)+std::pow((1.333*t-ct)/(1.333*t+ct),2));
      assert(std::abs(value[0]-f)<2.e-5);
      for(UINT c=1;c<4;++c)assert(std::abs(value[c]-std::exp(-.1*c*distance))<2.e-5);
    } else if(y==1) {
      assert(std::abs(value[0]-distance)<2.e-5);
      assert(std::abs(value[1]+std::expm1(-.000001*distance)/.000001)<2.e-5);
      assert(std::abs(value[2]+std::expm1(-.3*distance)/.3)<2.e-5);
    } else if(y==2) { assert(value[0]>=0 && value[0]<100); }
    else {
      const double extinction[]={.3594+.0007+.5,.0654+.0014+.5,.011+.0033+.5};
      for(UINT c=0;c<3;++c) {
        double transmission=std::exp(-extinction[c]*2.);
        double scattering[]={.5007,.5014,.5033};
        double ambient=x>=32 ? .25*double(c+1) : 0.;
        double expected=(1.-f0)*(double(2*(c+1))*transmission
            +ambient*scattering[c]*(1.-transmission)/extinction[c])*.75+double(c+1)*.25;
        if(std::abs(value[c]-expected)>=.0001)std::cerr<<"Water composition x="<<x<<" c="<<c<<": "<<value[c]<<" != "<<expected<<'\n';
        assert(std::abs(value[c]-expected)<.0001);
      }
      assert(std::abs(value[3]-f0*.75)<.00001);
    }
  }
  context->Unmap(readback.Get(),0);
  water.Restore(context.Get());
  for(UINT slot=113;slot<=115;++slot){ComPtr<ID3D11ShaderResourceView> restored;context->PSGetShaderResources(slot,1,&restored);assert(restored.Get()==source_view.Get());}
  assert(!water.Capture(context.Get(),source_view.Get(),constants.Get(),129,4,2));
  assert(!water.Bind(context.Get(),2));
  assert(water.Capture(context.Get(),source_view.Get(),constants.Get(),31,3,3));
  assert(water.Bind(context.Get(),3));water.Restore(context.Get());
  ComPtr<ID3D11PixelShader> trace;
  assert(SUCCEEDED(device->CreatePixelShader(trace_code->GetBufferPointer(),trace_code->GetBufferSize(),nullptr,&trace)));
  context->PSSetShader(trace.Get(),nullptr,0);
  // Independent analytic plane hits, foreground/empty/far rejection, offscreen
  // and constant-view-Z fallbacks. Test the actual production depth traversal.
  const float cases[][6]={
      {0,0,-1,12,2,1}, {.6f,0,-.8f,12,2.5f,1},
      {0,0,-1,8,0,1}, {0,0,-1,0,0,0}, {0,0,-1,100,13.81551f,1},
      {10,0,-1,12,2,1}, {1,0,0,12,2,1}};
  for(UINT test=0;test<std::size(cases);++test) {
    frame[50]={cases[test][0],cases[test][1],cases[test][2],0};
    context->UpdateSubresource(constants.Get(),0,nullptr,frame.data(),0,0);
    assert(water.Capture(context.Get(),source_view.Get(),constants.Get(),64,4,10+test));
    assert(water.Bind(context.Get(),10+test));
    pool.assign(64*4*4,cases[test][3]>0 ? .2f/cases[test][3] : 0.f);
    context->UpdateSubresource(depth.Get(),0,nullptr,pool.data(),64*16,0);
    context->Draw(3,0);context->CopyResource(readback.Get(),output.Get());
    assert(SUCCEEDED(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped)));
    for(UINT y=0;y<4;++y)for(UINT x=0;x<64;++x) {
      const float* value=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)+x*4;
      for(UINT c=0;c<4;++c)assert(std::isfinite(value[c]));
      for(UINT c=0;c<3;++c) {
        double expected=cases[test][5]>0 ? double(2*(c+1))*std::exp(-.5*cases[test][4]) : 0.;
        if(std::abs(value[c]-expected)>.0003) {std::cerr<<"Trace case "<<test<<": "<<value[c]<<" != "<<expected<<'\n';assert(false);}
      }
      if(cases[test][5]>0)assert(std::abs(value[3]-cases[test][4])<.0001);
    }
    context->Unmap(readback.Get(),0);water.Restore(context.Get());
  }
  ComPtr<ID3D11PixelShader> atmosphere;
  assert(SUCCEEDED(device->CreatePixelShader(atmosphere_code->GetBufferPointer(),atmosphere_code->GetBufferSize(),nullptr,&atmosphere)));
  context->PSSetShader(atmosphere.Get(),nullptr,0);
  context->Draw(3,0);context->CopyResource(readback.Get(),output.Get());
  assert(SUCCEEDED(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped)));
  for(UINT y=0;y<4;++y)for(UINT x=0;x<64;++x) {
    const float* value=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)+x*4;
    for(UINT c=0;c<3;++c) {
      const double directions[]={y>=2 ? .000001 : .392,y>=2 ? -.000001 : -.3,0};
      double column=0,height=-50.+150.*x/63.,falloff=.0233;
      if(y>=1) {height+=2188.528427;falloff=.00223805698;}
      if(y>=3) {height+=1.e7;falloff=1.e-7;}
      for(UINT sample=0;sample<10000;++sample)
        column+=.1/(1.+std::max(0.,height+directions[c]*(sample+.5)*.1)*falloff);
      assert(std::abs(value[c]-std::exp(-.004*column))<2.e-5);
    }
    assert(value[3]==1.f);
  }
  context->Unmap(readback.Get(),0);
  // Execute the production metadata loads with deliberately distinct world-
  // bounds and atlas-UV rows. The native DXBC loads row 0 then integer row 1;
  // a decompiled 1.40129846e-045 float incorrectly converts back to row 0.
  std::ifstream water_source("src/games/thewitcher3classic/volumetrics/0x28D7BDFE.ps_5_0.hlsl");
  assert(water_source);
  const std::string water_text{std::istreambuf_iterator<char>(water_source), {}};
  const auto metadata_begin=water_text.find("r9.yzw =",water_text.find("if (r4.w != 0)"));
  const auto metadata_end=water_text.find("t4.GetDimensions",metadata_begin);
  assert(metadata_begin!=std::string::npos && metadata_end!=std::string::npos);
  const std::string metadata_shader=
      "Texture2D<float4> t17:register(t17);"
      "float4 main(float4 p:SV_Position):SV_Target {"
      "float4 r9=float4((uint)p.x,0,0,0),r10,r11;"
      +water_text.substr(metadata_begin,metadata_end-metadata_begin)+"return r11-r10;}";
  ComPtr<ID3DBlob> metadata_code;
  assert(SUCCEEDED(D3DCompile(metadata_shader.data(),metadata_shader.size(),nullptr,nullptr,nullptr,
      "main","ps_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&metadata_code,&errors)));
  ComPtr<ID3D11PixelShader> metadata_ps;
  assert(SUCCEEDED(device->CreatePixelShader(metadata_code->GetBufferPointer(),metadata_code->GetBufferSize(),nullptr,&metadata_ps)));
  pool.resize(64*4*4);
  for(UINT y=0;y<4;++y)for(UINT x=0;x<64;++x)for(UINT c=0;c<4;++c)
    pool[(y*64+x)*4+c]=float(y*100+x*(y+1)+c*y);
  context->UpdateSubresource(depth.Get(),0,nullptr,pool.data(),64*16,0);
  context->PSSetShaderResources(17,1,depth_view.GetAddressOf());
  context->PSSetShader(metadata_ps.Get(),nullptr,0);
  context->Draw(3,0);context->CopyResource(readback.Get(),output.Get());
  assert(SUCCEEDED(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped)));
  for(UINT x=0;x<64;++x)for(UINT c=0;c<4;++c)
    assert(static_cast<const float*>(mapped.pData)[x*4+c]==float(100+x+c));
  context->Unmap(readback.Get(),0);
  std::cout<<"PASS production water metadata loads select distinct world-bounds/atlas-UV rows across 64 tiles\n";
  std::cout<<"PASS local-fog light transmittance against 10000-step numerical quadrature, including horizontal/downward light and vacuum\n";
  std::cout<<"PASS perspective-correct refraction plane hits, foreground/empty/far rejection and screen-edge/parallel-ray fallbacks\n";
  std::cout<<"PASS water Fresnel, Beer-Lambert, scattering, finite GGX, fog-once composition, poisoned pool isolation, frame copy, stale-frame rejection, binding restoration and resize\n";
}
