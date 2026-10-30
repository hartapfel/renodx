/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <d3d11.h>
#include <d3dcompiler.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <vector>
#include "../darker_nights.hpp"
using Microsoft::WRL::ComPtr;
namespace fs = std::filesystem;
fs::path root;
void Check(HRESULT hr) {
  if (FAILED(hr)) throw std::runtime_error(std::to_string(hr));
}
std::vector<char> Read(const fs::path& p) {
  std::ifstream f(p, std::ios::binary);
  if (!f) throw std::runtime_error(p.string());
  return {std::istreambuf_iterator<char>(f), {}};
}
ComPtr<ID3DBlob> Compiled(const fs::path& path) {
  // Exercise the exact FXC output embedded by the Release addon target.
  const auto bytes = Read(fs::path("build/thewitcher3classic.include/embed") / (path.stem().stem().string() + ".cso"));
  ComPtr<ID3DBlob> code;
  Check(D3DCreateBlob(bytes.size(), &code));
  std::memcpy(code->GetBufferPointer(), bytes.data(), bytes.size());
  return code;
}
std::vector<float> Constants(const char* name) {
  auto bytes = Read(root / name);
  std::vector<float> values(bytes.size() / sizeof(float));
  std::memcpy(values.data(), bytes.data(), bytes.size());
  return values;
}
float Difference(const std::vector<float>& a, const std::vector<float>& b) {
  if (a.size() != b.size()) throw std::runtime_error("Size mismatch");
  float error = 0;
  for (size_t i = 0; i < a.size(); ++i) {
    if (!std::isfinite(a[i]) || !std::isfinite(b[i])) throw std::runtime_error("Nonfinite output");
    error = std::max(error, std::abs(a[i] - b[i]));
  }
  return error;
}
int main(int argc, char** argv) {
  try {
    if (argc < 3) return 2;
    root = argv[1];
    ComPtr<ID3D11Device> dev;
    ComPtr<ID3D11DeviceContext> ctx;
    Check(D3D11CreateDevice(nullptr, std::find(argv + 2, argv + argc, std::string("--hardware")) != argv + argc
        ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &dev, nullptr, &ctx));
    const UINT W = 64, H = 64;
    ComPtr<ID3DBlob> vsBlob;
    ComPtr<ID3D11VertexShader> vs;
    ctx->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    D3D11_RASTERIZER_DESC rd = {};
    rd.FillMode = D3D11_FILL_SOLID;
    rd.CullMode = D3D11_CULL_NONE;
    rd.DepthClipEnable = TRUE;
    ComPtr<ID3D11RasterizerState> rs;
    Check(dev->CreateRasterizerState(&rd, &rs));
    ctx->RSSetState(rs.Get());
    D3D11_VIEWPORT vp = {0, 0, float(W), float(H), 0, 1};
    ctx->RSSetViewports(1, &vp);
    D3D11_TEXTURE2D_DESC td = {};
    td.Width = W;
    td.Height = H;
    td.MipLevels = td.ArraySize = td.SampleDesc.Count = 1;
    td.Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
    td.BindFlags = D3D11_BIND_RENDER_TARGET;
    ComPtr<ID3D11Texture2D> out, staging;
    Check(dev->CreateTexture2D(&td, nullptr, &out));
    ComPtr<ID3D11RenderTargetView> rt;
    Check(dev->CreateRenderTargetView(out.Get(), nullptr, &rt));
    ctx->OMSetRenderTargets(1, rt.GetAddressOf(), nullptr);
    td.BindFlags = 0;
    td.Usage = D3D11_USAGE_STAGING;
    td.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    Check(dev->CreateTexture2D(&td, nullptr, &staging));
    auto buffer = [&](UINT slot, const std::vector<float>& values) {D3D11_BUFFER_DESC d={};d.ByteWidth=UINT((values.size()*4+15)&~15);d.BindFlags=D3D11_BIND_CONSTANT_BUFFER;std::vector<float> padded(d.ByteWidth/4);std::copy(values.begin(),values.end(),padded.begin());D3D11_SUBRESOURCE_DATA data={padded.data()};ComPtr<ID3D11Buffer>b;Check(dev->CreateBuffer(&d,&data,&b));ctx->PSSetConstantBuffers(slot,1,b.GetAddressOf()); };
    auto texture = [&](UINT slot, UINT w, UINT h, const std::vector<float>& pixels) {D3D11_TEXTURE2D_DESC d={};d.Width=w;d.Height=h;d.MipLevels=d.ArraySize=d.SampleDesc.Count=1;d.Format=DXGI_FORMAT_R32G32B32A32_FLOAT;d.BindFlags=D3D11_BIND_SHADER_RESOURCE;D3D11_SUBRESOURCE_DATA data={pixels.data(),w*16};ComPtr<ID3D11Texture2D>t;Check(dev->CreateTexture2D(&d,&data,&t));ComPtr<ID3D11ShaderResourceView>s;Check(dev->CreateShaderResourceView(t.Get(),nullptr,&s));ctx->PSSetShaderResources(slot,1,s.GetAddressOf()); };
    D3D11_SAMPLER_DESC sd = {};
    sd.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sd.AddressU = sd.AddressV = sd.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    sd.MaxLOD = D3D11_FLOAT32_MAX;
    ComPtr<ID3D11SamplerState> sampler;
    Check(dev->CreateSamplerState(&sd, &sampler));
    for (UINT slot = 0; slot < 3; slot++) ctx->PSSetSamplers(slot, 1, sampler.GetAddressOf());
    auto render = [&](const void* data, size_t bytes) {ComPtr<ID3D11PixelShader>ps;Check(dev->CreatePixelShader(data,bytes,nullptr,&ps));ctx->PSSetShader(ps.Get(),nullptr,0);ctx->Draw(3,0);ctx->CopyResource(staging.Get(),out.Get());D3D11_MAPPED_SUBRESOURCE m;Check(ctx->Map(staging.Get(),0,D3D11_MAP_READ,0,&m));std::vector<float> values(W*H*4);for(UINT y=0;y<H;y++)memcpy(values.data()+y*W*4,static_cast<char*>(m.pData)+y*m.RowPitch,W*16);ctx->Unmap(staging.Get(),0);return values; };
    for (unsigned kind=0;kind<6;++kind) {
      const bool is_cloud = kind < 2 || kind >= 4;
      const char* name=kind==0?"cloud1":kind==1?"cloud2":kind==4?"cloud3":kind==5?"cloud4":"stars";
      const char* hash=kind==0?"0x22D1E925":kind==1?"0x6F0FF708":kind==2?"0xBC930752":kind==3?"0xF12E637D":kind==4?"0xC6178ADC":"0xF4B551EC";
      auto frame=Constants((std::string(name)+"-cb12.bin").c_str());
      auto global=Constants((std::string(name)+"-cb0.bin").c_str());
      auto camera=Constants((std::string(name)+"-cb1.bin").c_str());
      global[9*4+3]=0;buffer(0,global);buffer(1,camera);
      ComPtr<ID3D11Buffer> camera_buffer;ctx->PSGetConstantBuffers(1,1,&camera_buffer);ctx->VSSetConstantBuffers(1,1,camera_buffer.GetAddressOf());
      frame[184*4+3]=0;
      // Use explicit daytime-independent direct/probe colors to exercise HDR.
      global[9*4]=.5f;global[9*4+1]=.3f;global[9*4+2]=.8f;buffer(0,global);
      for(unsigned row:{233u,234u,235u,236u,266u})if(row*4+2<frame.size()) {frame[row*4]=2;frame[row*4+1]=4;frame[row*4+2]=8;}
      if(is_cloud) {
        auto material = Constants((std::string(name)+"-cb4.bin").c_str());
        if(kind==4) {material[7*4]=0;material[8*4]=1000;material[9*4]=1;material[6*4]=1;material[12*4]=1;}
        if(kind==5) {material[3*4]=2;material[11*4]=1;material[14*4]=1;material[15*4]=1;}
        buffer(4,material);
        frame[21*4]=0;frame[21*4+1]=.00001f;
        frame[22*4]=0;frame[22*4+1]=1;
        if(kind==0) {buffer(2,Constants("cloud1-cb2.bin"));frame[237*4]=frame[237*4+1]=frame[237*4+2]=1.f;}
        for(unsigned slot:{0u,1u,2u,3u,15u})texture(slot,1,1,{.7f,.6f,.8f,.75f});
        ctx->PSSetSamplers(15,1,sampler.GetAddressOf());
      } else {
        std::array<float,4> pixel{.6f,.7f,.8f,1};
        std::array<D3D11_SUBRESOURCE_DATA,6> faces;for(auto& face:faces)face={pixel.data(),16,0};
        D3D11_TEXTURE2D_DESC d{1,1,1,6,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_TEXTURECUBE};
        ComPtr<ID3D11Texture2D> cube;ComPtr<ID3D11ShaderResourceView> view;Check(dev->CreateTexture2D(&d,faces.data(),&cube));Check(dev->CreateShaderResourceView(cube.Get(),nullptr,&view));ctx->PSSetShaderResources(0,1,view.GetAddressOf());ctx->PSSetShaderResources(1,1,view.GetAddressOf());
      }
      const char* vertex=(kind==0 || kind==4) ? R"(
cbuffer Camera:register(b1){float4 c[9];}
struct V{float4 a:TEXCOORD0;float4 b:TEXCOORD1;float4 d:TEXCOORD2;float4 e:TEXCOORD3;float4 f:TEXCOORD4;float3 g:TEXCOORD5;float4 p:SV_Position;};
V main(uint id:SV_VertexID){V v;float2 uv=float2((id<<1)&2,id&2);float3 w=c[8].xyz+float3(uv*100+300,600);v.p=float4(uv*float2(2,-2)+float2(-1,1),0,1);v.a=float4(.2,.3,.4,.25);v.b=float4(uv,100,w.x);v.d=float4(0,0,0,1);v.e=float4(0,1,0,w.y);v.f=float4(0,0,1,w.z);v.g=float3(1,0,0);return v;})" : kind==1 ? R"(
cbuffer Camera:register(b1){float4 c[9];}
struct V{float4 a:TEXCOORD0;float4 b:TEXCOORD1;float4 d:TEXCOORD2;float3 e:TEXCOORD3;float4 p:SV_Position;};
V main(uint id:SV_VertexID){V v;float2 uv=float2((id<<1)&2,id&2);v.p=float4(uv*float2(2,-2)+float2(-1,1),0,1);v.a=float4(0,uv,100);v.b=float4(.2,.3,.4,.25);v.d=float4(0,0,0,1);v.e=c[8].xyz+float3(uv*100+300,600);return v;})" : R"(
cbuffer Frame:register(b12){float4 f[206];}
struct V{float4 a:TEXCOORD0;float4 b:TEXCOORD1;float4 p:SV_Position;};
V main(uint id:SV_VertexID){V v;float2 uv=float2((id<<1)&2,id&2);v.p=float4(uv*float2(2,-2)+float2(-1,1),0,1);float3 w=f[0].xyz+float3(uv*500+50,300);v.a=float4(uv,w.xy);v.b=float4(w,w.z);return v;})";
      const char* primary_sky=R"(cbuffer Frame:register(b12){float4 f[206];}
struct V{float4 a:TEXCOORD0;float3 b:TEXCOORD1;float4 p:SV_Position;};
V main(uint id:SV_VertexID){V v;float2 uv=float2((id<<1)&2,id&2);v.p=float4(uv*float2(2,-2)+float2(-1,1),0,1);v.a=float4(uv,1,1);v.b=f[0].xyz+float3(uv*500+50,300);return v;})";
      if(kind==2)vertex=primary_sky;
      if(kind==5)vertex=R"(cbuffer Camera:register(b1){float4 c[9];}
struct V{float4 a:TEXCOORD0;float4 b:TEXCOORD1;float3 d:TEXCOORD2;float4 p:SV_Position;};
V main(uint id:SV_VertexID){V v;float2 uv=float2((id<<1)&2,id&2);v.p=float4(uv*float2(2,-2)+float2(-1,1),0,1);v.a=float4(.4,uv,.5);v.b=float4(uv,0,10000);v.d=c[8].xyz+float3(2000,uv*500+100);return v;})";
      vsBlob.Reset();Check(D3DCompile(vertex,strlen(vertex),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&vsBlob,nullptr));vs.Reset();Check(dev->CreateVertexShader(vsBlob->GetBufferPointer(),vsBlob->GetBufferSize(),nullptr,&vs));ctx->VSSetShader(vs.Get(),nullptr,0);
      auto bind_frame=[&]{buffer(12,frame);ComPtr<ID3D11Buffer>b;ctx->PSGetConstantBuffers(12,1,&b);ctx->VSSetConstantBuffers(12,1,b.GetAddressOf());};
      const auto original=Read(fs::path(argv[2])/(std::string(hash)+".ps_5_0.cso"));
      const auto production=Compiled(std::string(hash)+".ps_5_0.hlsl");
      bind_frame();auto native=render(original.data(),original.size());auto neutral=render(production->GetBufferPointer(),production->GetBufferSize());
      const float baseline=Difference(native,neutral);if(baseline>.0002f)throw std::runtime_error("Cloud/sky baseline differs from native DXBC");
      std::vector<std::vector<float>> results;
      for(float gain:{0.f,1.f,2.f}) {
        auto adjusted=frame;witcher3classic::night::ApplyCommon(adjusted.data(),{.schedule=witcher3classic::night::NightSchedule(),.clouds=is_cloud?gain:1.f,.stars=!is_cloud?gain:1.f},0.f);
        buffer(12,adjusted);results.push_back(render(production->GetBufferPointer(),production->GetBufferSize()));
      }
      double delta=0;float peak=0;
      for(size_t i=0;i<neutral.size();++i) {
        if(i%4==3) {if(results[0][i]!=neutral[i]||results[2][i]!=neutral[i])throw std::runtime_error("Cloud/star slider changes alpha");continue;}
        delta+=std::abs(results[1][i]-results[0][i]);peak=std::max(peak,results[2][i]);
        if(std::abs(results[2][i]-(2*results[1][i]-results[0][i]))>.0005f*std::max(1.f,std::abs(results[2][i])))throw std::runtime_error("Cloud/star brightness loses linear HDR or fog baseline");
      }
      if(delta<.01)throw std::runtime_error("Cloud/star fixture has no visible lighting contribution");
      if(is_cloud) for(float gain:{3.f,4.f,8.f}) {
        auto adjusted=frame;
        witcher3classic::night::ApplyCommon(adjusted.data(),{.schedule=witcher3classic::night::NightSchedule(),.clouds=gain},0.f);
        buffer(12,adjusted);
        const auto normalized=render(production->GetBufferPointer(),production->GetBufferSize());
        const float encoded=std::round(gain*511.f)/511.f;
        for(size_t i=0;i<normalized.size();++i) {
          const float expected=i%4==3?neutral[i]:results[0][i]+encoded*(results[1][i]-results[0][i]);
          if(std::abs(normalized[i]-expected)>.0007f*std::max(1.f,std::abs(expected)))
            throw std::runtime_error("Regional cloud normalization loses HDR linearity or alpha");
        }
      }

      auto independent=frame;witcher3classic::night::ApplyCommon(independent.data(),{.schedule=witcher3classic::night::NightSchedule(),.clouds=!is_cloud?0.f:1.f,.stars=is_cloud?0.f:1.f},0.f);buffer(12,independent);
      if(Difference(neutral,render(production->GetBufferPointer(),production->GetBufferSize()))>.0001f)throw std::runtime_error("Cloud/star sliders are coupled");
      std::cout<<"PASS "<<hash<<" original DXBC max error="<<baseline<<", independent 0/100/200%, alpha preserved, peak="<<peak<<'\n';
      if(!is_cloud)for(float range:{1.f,4096.f}) {
        // Current live weather with the other night colors already zero:
        // c194 remains the separate native sky height/horizon haze term.
        auto haze_frame=Constants(kind==2?"height-haze-cb12.bin":"haze-cb12.bin");haze_frame[184*4+3]=0;
        for(unsigned channel=0;channel<3;++channel)haze_frame[194*4+channel]*=range;
        std::vector<std::vector<float>> haze_results;
        for(float gain:{0.f,1.f,2.f}) {
          auto adjusted=haze_frame;
          witcher3classic::night::ApplyCommon(adjusted.data(),{.schedule=witcher3classic::night::NightSchedule(),.sky_haze=gain},0.f);
          buffer(12,adjusted);
          auto actual=render(production->GetBufferPointer(),production->GetBufferSize());
          // In F12E637D only, c238/c267 feed a final additive background glow.
          // Scale those colours in the original bytecode as an independent
          // reference, rather than altering their cloud consumers globally.
          if(kind==3)for(unsigned row:{238u,267u})for(unsigned channel=0;channel<3;++channel)adjusted[row*4+channel]*=gain;
          buffer(12,adjusted);
          auto expected=render(original.data(),original.size());
          if(Difference(expected,actual)>.0002f*range)throw std::runtime_error("Sky haze differs from native weather/color blending");
          haze_results.push_back(std::move(actual));
        }
        double haze_delta=0;
        for(size_t i=0;i<neutral.size();++i) {
          if(i%4==3) {if(haze_results[0][i]!=haze_results[1][i]||haze_results[2][i]!=haze_results[1][i])throw std::runtime_error("Sky haze changes alpha");continue;}
          haze_delta+=std::abs(haze_results[1][i]-haze_results[0][i]);
          if(std::abs(haze_results[2][i]-(2*haze_results[1][i]-haze_results[0][i]))>.0001f*range)throw std::runtime_error("Sky haze scales unrelated sky terms or loses HDR");
        }
        if(haze_delta<.01)throw std::runtime_error("Sky haze fixture does not expose the leftover native haze");
        std::cout<<"PASS "<<hash<<" live sky haze 0/100/200%, native weather profile/alpha, range="<<range<<'\n';
        if(kind==3) {
          auto zero=haze_frame;
          witcher3classic::night::ApplyCommon(zero.data(),{.schedule=witcher3classic::night::NightSchedule(),
              .fog=0.f,.haze=0.f,.sky=0.f,.sky_haze=0.f,.clouds=0.f,.stars=0.f},0.f);
          buffer(12,zero);
          const auto black=render(production->GetBufferPointer(),production->GetBufferSize());
          for(size_t i=0;i<black.size();++i)if(i%4!=3 && black[i]!=0.f)throw std::runtime_error("Toussaint sky retains light with all sky controls zero");
          std::cout<<"PASS Toussaint sky, horizon glow, fog and stars all zero: black RGB with native alpha\n";
        }
      }

    }
    return 0;
  } catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}
}
