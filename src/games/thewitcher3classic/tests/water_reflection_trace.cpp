/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11.h>
#include <d3dcompiler.h>
#include <wrl/client.h>
#include <array>
#include <vector>
#include <fstream>
#include <iostream>
#include <cassert>
#include <cmath>
#include <cstring>
#include <algorithm>
using Microsoft::WRL::ComPtr;
std::vector<char> Read(const char* path) {
  std::ifstream f(path,std::ios::binary);assert(f);return {std::istreambuf_iterator<char>(f),{}};
}
int main(int argc,char**) {
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> ctx;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&ctx)));
  constexpr UINT W=64,H=64;
  auto native=Read("tmp/witcher3classic-investigation/volumetrics-20261027/particle-originals/0x47CC9FA1.ps_5_0.cso");
  ComPtr<ID3D11PixelShader> original,modified;ComPtr<ID3DBlob> code,error;
  assert(SUCCEEDED(device->CreatePixelShader(native.data(),native.size(),nullptr,&original)));
  auto result=D3DCompileFromFile(L"src/games/thewitcher3classic/water/0x47CC9FA1.ps_5_0.hlsl",nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,
      "main","ps_5_0",D3DCOMPILE_ENABLE_STRICTNESS|D3DCOMPILE_OPTIMIZATION_LEVEL3,0,&code,&error);
  if(error)std::cerr<<static_cast<const char*>(error->GetBufferPointer());assert(SUCCEEDED(result));
  assert(SUCCEEDED(device->CreatePixelShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&modified)));
  const char* vs_text="float4 main(uint id:SV_VertexID):SV_Position{float2 uv=float2((id<<1)&2,id&2);return float4(uv*float2(2,-2)+float2(-1,1),.5,1);}";
  code.Reset();assert(SUCCEEDED(D3DCompile(vs_text,strlen(vs_text),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&code,nullptr)));
  ComPtr<ID3D11VertexShader> vs;assert(SUCCEEDED(device->CreateVertexShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&vs)));
  ctx->VSSetShader(vs.Get(),nullptr,0);ctx->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  D3D11_VIEWPORT viewport{0,0,W,H,0,1};ctx->RSSetViewports(1,&viewport);
  D3D11_RASTERIZER_DESC raster=CD3D11_RASTERIZER_DESC(D3D11_DEFAULT);raster.CullMode=D3D11_CULL_NONE;
  ComPtr<ID3D11RasterizerState> rs;assert(SUCCEEDED(device->CreateRasterizerState(&raster,&rs)));ctx->RSSetState(rs.Get());
  std::array<float,210*4> frame{};std::array<float,13*4> params{};
  auto bytes=Read("tmp/witcher3classic-investigation/volumetrics-20261027/trace-cb12.bin");memcpy(frame.data(),bytes.data(),sizeof(frame));
  bytes=Read("tmp/witcher3classic-investigation/volumetrics-20261027/trace-cb3.bin");memcpy(params.data(),bytes.data(),sizeof(params));
  for(UINT c=0;c<4;++c)params[c]=64;
  params[20]=params[21]=64;params[22]=params[23]=1.f/64;
  for(UINT c=32;c<36;++c)params[c]=1;
  ComPtr<ID3D11Buffer> frame_buffer,param_buffer;
  D3D11_BUFFER_DESC bd{sizeof(frame),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};D3D11_SUBRESOURCE_DATA initial{frame.data()};
  assert(SUCCEEDED(device->CreateBuffer(&bd,&initial,&frame_buffer)));ctx->PSSetConstantBuffers(12,1,frame_buffer.GetAddressOf());
  bd.ByteWidth=sizeof(params);initial.pSysMem=params.data();assert(SUCCEEDED(device->CreateBuffer(&bd,&initial,&param_buffer)));
  ctx->PSSetConstantBuffers(3,1,param_buffer.GetAddressOf());
  D3D11_SAMPLER_DESC sd{};sd.Filter=D3D11_FILTER_MIN_MAG_MIP_POINT;sd.AddressU=sd.AddressV=sd.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;sd.MaxLOD=D3D11_FLOAT32_MAX;
  ComPtr<ID3D11SamplerState> point;assert(SUCCEEDED(device->CreateSamplerState(&sd,&point)));
  for(UINT slot:{0u,1u,11u})ctx->PSSetSamplers(slot,1,point.GetAddressOf());
  std::array<ComPtr<ID3D11Texture2D>,7> textures;std::array<ComPtr<ID3D11ShaderResourceView>,7> views;
  std::array<std::vector<std::array<float,4>>,7> pixels;
  for(UINT t=0;t<7;++t) {
    pixels[t].resize(W*H);
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
      float raw=.005f+float((x*13+y*7)%23)*.00015f;
      float nx=(x+.5f)/W*2-1,ny=1-(y+.5f)/H*2;
      float a_z=frame[206*4+2]*nx+frame[207*4+2]*ny+frame[209*4+2];
      float a_w=frame[206*4+3]*nx+frame[207*4+3]*ny+frame[209*4+3];
      float water_height=frame[2]-1.5f;
      float water_raw=(water_height*a_w-a_z)/(frame[208*4+2]-water_height*frame[208*4+3]);
      if(t==0)pixels[t][y*W+x]={.5f,.5f,float(x%2),water_raw>0.f && water_raw<1.f ? 1.f:0.f};
      else if(t==2)pixels[t][y*W+x]={raw,raw,raw,raw};
      else if(t==4)pixels[t][y*W+x]={std::clamp(water_raw,0.f,1.f),0,0,0};
      else pixels[t][y*W+x]={float((x*3+y*5)%29),float((x*7+y*11)%31),float((x+y*13)%37),1};
    }
    D3D11_TEXTURE2D_DESC td{W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    initial={pixels[t].data(),W*16};assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&textures[t])));
    assert(SUCCEEDED(device->CreateShaderResourceView(textures[t].Get(),nullptr,&views[t])));
    ctx->PSSetShaderResources(t==6?23:t,1,views[t].GetAddressOf());
  }
  ctx->PSSetShaderResources(114,1,views[2].GetAddressOf());
  std::array<ComPtr<ID3D11Texture2D>,2> outputs;std::array<ComPtr<ID3D11RenderTargetView>,2> targets;
  D3D11_TEXTURE2D_DESC td{W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_RENDER_TARGET};
  for(UINT i=0;i<2;++i) {assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&outputs[i])));assert(SUCCEEDED(device->CreateRenderTargetView(outputs[i].Get(),nullptr,&targets[i])));}
  ID3D11RenderTargetView* rt[]={targets[0].Get(),targets[1].Get()};ctx->OMSetRenderTargets(2,rt,nullptr);
  td.Usage=D3D11_USAGE_STAGING;td.BindFlags=0;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  ComPtr<ID3D11Texture2D> staging;assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&staging)));
  auto render=[&](ID3D11PixelShader* ps) {
    ctx->PSSetShader(ps,nullptr,0);ctx->Draw(3,0);std::vector<float> result(W*H*8);
    for(UINT i=0;i<2;++i) {ctx->CopyResource(staging.Get(),outputs[i].Get());D3D11_MAPPED_SUBRESOURCE map;
      assert(SUCCEEDED(ctx->Map(staging.Get(),0,D3D11_MAP_READ,0,&map)));
      for(UINT y=0;y<H;++y)memcpy(result.data()+i*W*H*4+y*W*4,static_cast<const char*>(map.pData)+y*map.RowPitch,W*16);
      ctx->Unmap(staging.Get(),0);}
    return result;
  };
  float max_error=0;size_t nonzero=0;
  for(UINT scenario=0;scenario<4;++scenario) {
    for(UINT i=0;i<W*H;++i)pixels[0][i][2]=float(scenario%2);
    ctx->UpdateSubresource(textures[0].Get(),0,nullptr,pixels[0].data(),W*16,0);
    if(scenario>=2) {sd.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;point.Reset();assert(SUCCEEDED(device->CreateSamplerState(&sd,&point)));for(UINT slot:{0u,1u,11u})ctx->PSSetSamplers(slot,1,point.GetAddressOf());}
    const auto a=render(original.Get()),b=render(modified.Get());
    for(size_t i=0;i<a.size();++i) {assert(std::isfinite(a[i]) && std::isfinite(b[i]));max_error=std::max(max_error,std::abs(a[i]-b[i]));if(a[i]!=0)++nonzero;}
  }
  std::cout<<"Native trace equivalence max error="<<max_error<<" nonzero="<<nonzero<<std::endl;assert(max_error<.001f && nonzero>1000);
  // A near transparent plane must alter the ray hits, while t2 still supplies
  // the original surface origin. Black non-water pixels remain untouched.
  const auto before=render(modified.Get());
  ctx->PSSetShaderResources(114,1,views[4].GetAddressOf());
  size_t changed=0;
  for(float depth:{.001f,.005f,.01f,.025f,.05f,.1f,.25f,.5f}) {
    for(auto& p:pixels[4])p[0]=depth;
    ctx->UpdateSubresource(textures[4].Get(),0,nullptr,pixels[4].data(),W*16,0);
    const auto after=render(modified.Get());
    for(UINT i=0;i<W*H;++i)for(UINT c=0;c<3;++c) {if(std::abs(before[i*4+c]-after[i*4+c])>.01f)++changed;if(pixels[0][i][3]==0)assert(after[i*4+c]==0);}
  }
  std::cout<<"Transparent intersection depth changed "<<changed<<" channels; native mask preserved"<<std::endl;assert(changed>10);
}
