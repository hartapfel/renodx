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
#include <thread>
#include <chrono>
#include "../volumetrics/pipeline.hpp"
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
    if (argc < 2) return 2;
    root = argv[1];
    ComPtr<ID3D11Device> dev;
    ComPtr<ID3D11DeviceContext> ctx;
    Check(D3D11CreateDevice(nullptr, std::find(argv + 2, argv + argc, std::string("--hardware")) != argv + argc
        ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &dev, nullptr, &ctx));
    const bool benchmark=std::find(argv+2,argv+argc,std::string("--benchmark"))!=argv+argc;
    const bool per_pixel=std::find(argv+2,argv+argc,std::string("--pixel"))!=argv+argc;
    if(benchmark) {
      ComPtr<IDXGIDevice> dxgi;Check(dev.As(&dxgi));ComPtr<IDXGIAdapter> adapter;Check(dxgi->GetAdapter(&adapter));DXGI_ADAPTER_DESC description{};Check(adapter->GetDesc(&description));
      std::wcout<<L"GPU timing adapter: "<<description.Description<<L'\n';
    }
    const UINT W = benchmark?2560:64, H = benchmark?1440:64;
    const char* vsText = "struct V {float4 p:SV_Position;float2 uv:TEXCOORD0;float2 vignette:TEXCOORD2;}; V main(uint id:SV_VertexID){V v;v.uv=float2((id<<1)&2,id&2);v.p=float4(v.uv*float2(2,-2)+float2(-1,1),0,1);v.vignette=v.uv;return v;}";
    ComPtr<ID3DBlob> vsBlob;
    Check(D3DCompile(vsText, strlen(vsText), nullptr, nullptr, nullptr, "main", "vs_5_0", 0, 0, &vsBlob, nullptr));
    ComPtr<ID3D11VertexShader> vs;
    Check(dev->CreateVertexShader(vsBlob->GetBufferPointer(), vsBlob->GetBufferSize(), nullptr, &vs));
    ctx->VSSetShader(vs.Get(), nullptr, 0);
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
    auto time_draws = [&] {
      ComPtr<ID3D11Query> disjoint,begin,end;
      D3D11_QUERY_DESC query{D3D11_QUERY_TIMESTAMP_DISJOINT,0};Check(dev->CreateQuery(&query,&disjoint));
      query.Query=D3D11_QUERY_TIMESTAMP;Check(dev->CreateQuery(&query,&begin));Check(dev->CreateQuery(&query,&end));
      ctx->Draw(3,0);ctx->Begin(disjoint.Get());ctx->End(begin.Get());
      constexpr int iterations=32;
      for(int iteration=0;iteration<iterations;++iteration)ctx->Draw(3,0);
      ctx->End(end.Get());ctx->End(disjoint.Get());ctx->Flush();
      D3D11_QUERY_DATA_TIMESTAMP_DISJOINT timing{};
      for(int attempt=0;ctx->GetData(disjoint.Get(),&timing,sizeof(timing),D3D11_ASYNC_GETDATA_DONOTFLUSH)==S_FALSE;++attempt) {
        if(attempt>=10000)throw std::runtime_error("Benchmark query timeout");
        std::this_thread::sleep_for(std::chrono::milliseconds(1));
      }
      UINT64 start=0,stop=0;Check(ctx->GetData(begin.Get(),&start,sizeof(start),0));Check(ctx->GetData(end.Get(),&stop,sizeof(stop),0));
      if(timing.Disjoint||!timing.Frequency)throw std::runtime_error("Disjoint GPU benchmark");
      return double(stop-start)*1000./timing.Frequency/iterations;
    };

    auto frame=Constants("cb12.bin"), controls=Constants("cb3.bin");
    for(int k=0;k<4;++k) {
      const float x=frame[210*4+k],y=frame[211*4+k];
      frame[210*4+k]*=frame[23*4]/W;frame[211*4+k]*=frame[23*4+1]/H;
      // Native Load coordinates are integer pixels. Keep the camera ray at
      // the resized pixel center, rather than retaining the capture's offset.
      frame[213*4+k]+=.5f*(frame[210*4+k]-x+frame[211*4+k]-y);
    }
    frame[23*4]=W;frame[23*4+1]=H;frame[23*4+2]=1.f/W;frame[23*4+3]=1.f/H;
    buffer(12,frame);buffer(3,controls);
    std::vector<float> depth(W*H*4), scene(W*H*4), mask(W*H*4);
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
      size_t i=(y*W+x)*4;
      depth[i]=x==0?0.f:std::pow(10.f,-4.f+4.f*float(x)/W);
      scene[i]=-1.f+16.f*float(x)/W;scene[i+1]=4.f;scene[i+2]=12.f;scene[i+3]=1.f;
      mask[i]=float(y)/H;
    }
    texture(0,W,H,depth);texture(1,W,H,scene);texture(2,W,H,mask);
    const auto original=Read(root/"native-fog.cso");
    const auto code=Compiled("0xC8C78997.ps_5_0.hlsl");
    if(std::find(argv+2,argv+argc,std::string("--pixel-local"))!=argv+argc) {
      frame.assign(269*4,0);controls.assign(8,0);
      frame[17*4]=1;frame[18*4+1]=1;frame[20*4+2]=frame[20*4+3]=1;
      frame[22*4]=-1;frame[22*4+1]=1;frame[22*4+2]=.2f;
      frame[23*4]=W;frame[23*4+1]=H;frame[23*4+2]=1.f/W;frame[23*4+3]=1.f/H;
      frame[24*4]=float((W+15)/16);frame[42*4]=1;frame[42*4+1]=-10000;frame[42*4+2]=1000;frame[42*4+3]=1;
      frame[43*4]=.002f;frame[48*4]=1;frame[48*4+1]=-1;frame[48*4+2]=1;
      controls[1]=controls[2]=controls[3]=controls[4]=1;buffer(3,controls);
      std::fill(depth.begin(),depth.end(),.5f);std::fill(scene.begin(),scene.end(),0);std::fill(mask.begin(),mask.end(),1);
      texture(0,W,H,depth);texture(1,W,H,scene);texture(2,W,H,mask);
      std::vector<float> lights(3323*4);
      UINT count=1;std::memcpy(&lights[57*4],&count,4);
      lights[58*4+2]=10;lights[58*4+3]=6;lights[61*4]=100;lights[61*4+1]=40;lights[61*4+2]=10;lights[63*4]=.25f;
      buffer(13,lights);ComPtr<ID3D11Buffer> lighting;ctx->PSGetConstantBuffers(13,1,&lighting);
      std::vector<UINT> indices(((W+15)/16)*((H+15)/16)*256,256);
      for(size_t i=0;i<indices.size();i+=256)indices[i]=0;
      D3D11_BUFFER_DESC list_desc{UINT(indices.size()*4),D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS};
      D3D11_SUBRESOURCE_DATA list_data{indices.data()};ComPtr<ID3D11Buffer> list;Check(dev->CreateBuffer(&list_desc,&list_data,&list));
      D3D11_SHADER_RESOURCE_VIEW_DESC list_desc_view{};list_desc_view.Format=DXGI_FORMAT_R32_TYPELESS;list_desc_view.ViewDimension=D3D11_SRV_DIMENSION_BUFFEREX;
      list_desc_view.BufferEx.NumElements=UINT(indices.size());list_desc_view.BufferEx.Flags=D3D11_BUFFEREX_SRV_FLAG_RAW;
      ComPtr<ID3D11ShaderResourceView> list_view;Check(dev->CreateShaderResourceView(list.Get(),&list_desc_view,&list_view));
      const float white=1;std::array<D3D11_SUBRESOURCE_DATA,4> shadow_data;
      for(auto& layer:shadow_data)layer={&white,4,0};
      const D3D11_TEXTURE2D_DESC shadow_desc{1,1,1,4,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
      ComPtr<ID3D11Texture2D> shadow;ComPtr<ID3D11ShaderResourceView> shadow_view;
      Check(dev->CreateTexture2D(&shadow_desc,shadow_data.data(),&shadow));Check(dev->CreateShaderResourceView(shadow.Get(),nullptr,&shadow_view));
      const float cube_depth=.5f;
      std::array<D3D11_SUBRESOURCE_DATA,6> cube_data;
      for(auto& face:cube_data)face={&cube_depth,4,0};
      const D3D11_TEXTURE2D_DESC cube_desc{1,1,1,6,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_TEXTURECUBE};
      ComPtr<ID3D11Texture2D> cube;ComPtr<ID3D11ShaderResourceView> cube_view;
      Check(dev->CreateTexture2D(&cube_desc,cube_data.data(),&cube));
      D3D11_SHADER_RESOURCE_VIEW_DESC cube_srv{};cube_srv.Format=DXGI_FORMAT_R32_FLOAT;cube_srv.ViewDimension=D3D11_SRV_DIMENSION_TEXTURECUBEARRAY;cube_srv.TextureCubeArray.NumCubes=1;cube_srv.TextureCubeArray.MipLevels=1;
      Check(dev->CreateShaderResourceView(cube.Get(),&cube_srv,&cube_view));
      ComPtr<ID3D11DeviceContext1> context;Check(ctx.As(&context));witcher3classic::volumetrics::Pipeline pipeline;
      const witcher3classic::volumetrics::Parameters parameters{{64,64,256,1000},{1,0,0,0},{0,.1f,0,0},{1.f/W,1.f/H,4,1},{1,1,1,4}};
      uint64_t id=0;
      for(bool shadowed:{false,true})for(float plane:{40.f,2.f}) {
        lights[60*4+3]=shadowed?1.f:0.f;lights[64*4]=shadowed?1.f:0.f;
        ctx->UpdateSubresource(lighting.Get(),0,nullptr,lights.data(),0,0);
        frame[210*4]=2*plane/W;frame[211*4+1]=-2*plane/H;
        frame[213*4]=-plane+plane/W;frame[213*4+1]=plane-plane/H;frame[213*4+2]=plane;frame[213*4+3]=1;
        buffer(12,frame);ComPtr<ID3D11Buffer> constants;ctx->PSGetConstantBuffers(12,1,&constants);
        std::array<ID3D11ShaderResourceView*,9> previous;previous.fill(shadow_view.Get());
        ctx->PSSetShaderResources(99,UINT(previous.size()),previous.data());
        if(!pipeline.Generate(context.Get(),constants.Get(),lighting.Get(),shadow_view.Get(),nullptr,nullptr,parameters,++id,nullptr,nullptr,{list_view.Get(),nullptr,cube_view.Get()})
            ||!pipeline.Bind(context.Get(),false,id))throw std::runtime_error("Per-pixel local setup failed");
        // Native constant buffers can be reused by subsequent material draws.
        // The fog must keep the captured light list instead of aliasing b13.
        std::vector<float> cleared(lights.size());ctx->UpdateSubresource(lighting.Get(),0,nullptr,cleared.data(),0,0);
        auto actual=render(code->GetBufferPointer(),code->GetBufferSize());pipeline.Restore(context.Get());
        if(benchmark) {
          if(!pipeline.Bind(context.Get(),false,id))throw std::runtime_error("Per-pixel timing bind failed");
          std::cout<<"Per-pixel local light 2560x1440 RGBA32F, "<<(shadowed?"shadowed":"unshadowed")<<", surface "<<plane<<" m: "<<time_draws()<<" ms\n";
          pipeline.Restore(context.Get());continue;
        }
        std::array<ID3D11ShaderResourceView*,9> restored{};ctx->PSGetShaderResources(99,UINT(restored.size()),restored.data());
        for(auto* view:restored) {bool match=view==shadow_view.Get();if(view)view->Release();if(!match)throw std::runtime_error("Per-pixel private input restoration failed");}
        if(plane==2) {
          for(size_t i=0;i<actual.size();i+=4)for(int c=0;c<3;++c)if(actual[i+c]!=0)throw std::runtime_error("Per-pixel light leaks behind the surface");
        } else {
          double maximum=0,mean=0;size_t compared=0;
          for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
            double rx=2.*(x+.5)/W-1,ry=1.-2.*(y+.5)/H,norm=std::sqrt(1+rx*rx+ry*ry);
            double direction[3]={rx/norm,ry/norm,1/norm};double reference=0;
            constexpr int samples=4096;double length=plane*norm-.2,step=length/samples;
            for(int i=0;i<samples;++i) {
              double t=.2+(i+.5)*step;double delta[3]={-direction[0]*t,-direction[1]*t,10-direction[2]*t};
              double d2=delta[0]*delta[0]+delta[1]*delta[1]+delta[2]*delta[2];if(d2>=36)continue;
              double attenuation=std::pow(1-std::pow(d2/36,2),2)/(1+.25*d2);
              double visibility=shadowed?std::exp(std::min(0.,100*(.5-.99*std::sqrt(d2)/6))):1;
              reference+=100*attenuation*visibility*std::exp(-.002*std::sqrt(d2))/(4*3.141592653589793)*.002*std::exp(-.002*(t-.2))*step;
            }
            double error=std::abs(actual[(y*W+x)*4]-reference);maximum=std::max(maximum,error);mean+=error;++compared;
          }
          std::cout<<"Per-pixel "<<(shadowed?"shadowed ":"")<<"point light versus 4096-step scalar reference: max="<<maximum<<", mean="<<mean/compared<<'\n';
          if(maximum>.004 ||mean/compared>.0005)throw std::runtime_error("Per-pixel local integration error");
        }
      }
      if(!benchmark) {
        // Unsupported/short native lighting buffers must keep the full volume
        // fallback, rather than publishing a per-pixel flag with a 1x1 grid.
        buffer(13,std::vector<float>(44*4));ctx->PSGetConstantBuffers(13,1,&lighting);
        ComPtr<ID3D11Buffer> constants;ctx->PSGetConstantBuffers(12,1,&constants);
        if(!pipeline.Generate(context.Get(),constants.Get(),lighting.Get(),shadow_view.Get(),nullptr,nullptr,parameters,++id))
          throw std::runtime_error("Per-pixel unsupported-input fallback failed");
        ComPtr<ID3D11Resource> resource;pipeline.View()->GetResource(&resource);
        ComPtr<ID3D11Texture3D> fallback;Check(resource.As(&fallback));D3D11_TEXTURE3D_DESC fallback_desc{};fallback->GetDesc(&fallback_desc);
        if(fallback_desc.Width!=64 ||fallback_desc.Height!=64 ||fallback_desc.Depth!=257)
          throw std::runtime_error("Unsupported per-pixel inputs retained the tiny parameter-only volume");
      }
      std::cout<<"PASS per-pixel point transport, fragment-depth bounds, cached-input restoration and unsupported-input fallback\n";return 0;
    }
    const bool weather_color=std::find(argv+2,argv+argc,std::string("--weather-color"))!=argv+argc;
    const bool weather_scene=std::find(argv+2,argv+argc,std::string("--weather-scene"))!=argv+argc;
    if(weather_color || weather_scene || std::find(argv+2,argv+argc,std::string("--weather"))!=argv+argc) {
      // Recover authored fog opacity directly from the original game's DXBC:
      // black background + white fog source makes its output equal opacity.
      // Keep captured camera/weather, isolate AO and authored color overrides.
      if(!weather_color && !weather_scene) {
        for(UINT index:{39u,40u,41u,188u,190u})
          for(int c=0;c<3;++c)frame[index*4+c]=1.f;
        frame[188*4+3]=frame[190*4+3]=1.f;
      }
      controls[4]=1.f;
      buffer(3,controls);
      if(!weather_scene)std::fill(scene.begin(),scene.end(),0.f);
      texture(1,W,H,scene);
      buffer(13,Constants("cb13.bin"));
      ComPtr<ID3D11Buffer> lighting;ctx->PSGetConstantBuffers(13,1,&lighting);
      ComPtr<ID3D11DeviceContext1> context;Check(ctx.As(&context));
      const float shadow_depth=1.f;
      const std::array<D3D11_SUBRESOURCE_DATA,4> shadow_data{{{&shadow_depth,4,0},{&shadow_depth,4,0},{&shadow_depth,4,0},{&shadow_depth,4,0}}};
      const D3D11_TEXTURE2D_DESC shadow_desc{1,1,1,4,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
      ComPtr<ID3D11Texture2D> shadow;ComPtr<ID3D11ShaderResourceView> shadow_view;
      Check(dev->CreateTexture2D(&shadow_desc,shadow_data.data(),&shadow));
      Check(dev->CreateShaderResourceView(shadow.Get(),nullptr,&shadow_view));
      witcher3classic::volumetrics::Pipeline pipeline;
      const witcher3classic::volumetrics::Parameters parameters{
          {64,64,256,1000},{1,0,benchmark?1.f:0.f,.5f},{1,.1f,0,0},{1.f/W,1.f/H,1,0},
          {1,1,per_pixel?1.f:0.f,4}};
      uint64_t frame_id=0;
      std::vector<float> exponents{frame[42*4+3]};
      if(!weather_scene)exponents.push_back(1.f);
      for(float exponent:exponents) {
        frame[42*4+3]=exponent;buffer(12,frame);
        ComPtr<ID3D11Buffer> constants;ctx->PSGetConstantBuffers(12,1,&constants);
        auto native=render(original.data(),original.size());
        if(!pipeline.Generate(context.Get(),constants.Get(),lighting.Get(),shadow_view.Get(),nullptr,nullptr,parameters,++frame_id)
            ||!pipeline.Bind(context.Get(),false,frame_id))throw std::runtime_error("Weather volume generation failed");
        auto custom=render(code->GetBufferPointer(),code->GetBufferSize());
        pipeline.Restore(context.Get());
        if(benchmark) {
          ComPtr<ID3D11Resource> resource;pipeline.ParametersView()->GetResource(&resource);
          const D3D11_BOX reconstruction_flag{21*16,0,0,22*16,1,1};
          for(int variant=0;variant<3;++variant) {
            if(!pipeline.Bind(context.Get(),false,frame_id))throw std::runtime_error("Benchmark volume bind failed");
            const std::array<float,4> reconstruction{variant==2?1.f:0.f,per_pixel?1.f:0.f,4,0};
            ctx->UpdateSubresource(resource.Get(),0,&reconstruction_flag,reconstruction.data(),0,0);
            ComPtr<ID3D11PixelShader> shader;
            if(variant==0)Check(dev->CreatePixelShader(original.data(),original.size(),nullptr,&shader));
            else Check(dev->CreatePixelShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&shader));
            ctx->PSSetShader(shader.Get(),nullptr,0);
            std::cout<<"Fog composite 2560x1440 RGBA32F GPU timing, "<<(variant==0?"native":per_pixel?"Per-pixel":variant==1?"Linear":"Smooth")
                     <<": "<<time_draws()<<" ms\n";
            pipeline.Restore(context.Get());
          }
          // Sun scattering is enabled for nonzero volume data in this timing
          // run; native-equivalence checks run separately without extra lights.
          return 0;
        }
        double error=0,mean=0,relative=0,mean_relative=0;size_t count=0;
        for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
          const size_t i=(y*W+x)*4;
          double h[4];for(int c=0;c<4;++c)h[c]=double(x)*frame[210*4+c]+double(y)*frame[211*4+c]+depth[i]*frame[212*4+c]+frame[213*4+c];
          double distance=0;for(int c=0;c<3;++c)distance+=std::pow(h[c]/h[3]-frame[c],2);distance=std::sqrt(distance);
          if(distance<8 ||distance>1000 ||depth[i]*frame[22*4]+frame[22*4+1]>=1.f)continue;
          // The native shader uses 16 end-point opacity products; production
          // uses analytic Beer-Lambert segments. Compare their scene-range
          // coverage, allowing this integration difference and 3D filtering.
          for(int c=0;c<3;++c) {
            if(!std::isfinite(native[i+c])||!std::isfinite(custom[i+c]))throw std::runtime_error("Nonfinite weather opacity");
            double delta=std::abs(double(custom[i+c])-native[i+c]);error=std::max(error,delta);mean+=delta;++count;
            double normalized=delta/(1.+std::abs(native[i+c]));relative=std::max(relative,normalized);mean_relative+=normalized;
          }
        }
        std::cout<<"Original DXBC weather "<<(weather_scene?"HDR scene":weather_color?"RGB":"opacity")<<": exponent="<<exponent<<", samples="<<count<<", max="<<error<<", mean="<<mean/std::max(size_t(1),count)
                 <<", normalized max="<<relative<<", normalized mean="<<mean_relative/std::max(size_t(1),count)<<'\n';
        if(count<100 || ((!weather_color && !weather_scene)?error>(per_pixel?.001:.025):relative>(per_pixel?.001:.05)))throw std::runtime_error("Weather composition differs from original DXBC");
      }
      std::cout<<"PASS captured weather "<<(weather_scene?"color/desaturation over signed HDR":weather_color?"directional/local fog color":"opacity/fade")<<" against original game bytecode through production "<<(per_pixel?"per-pixel fog":"fog volume")<<'\n';
      return 0;
    }
    if(std::find(argv+2,argv+argc,std::string("--sky"))!=argv+argc) {
      const auto native_sky=Read(root/"native-sky.cso");
      const auto custom_sky=Compiled("0xBC930752.ps_5_0.hlsl");
      buffer(0,Constants("sky-cb0.bin"));buffer(1,Constants("sky-cb1.bin"));
      buffer(13,Constants("cb13.bin"));
      const char* sky_vs="cbuffer Frame:register(b12){float4 f[214];} struct V{float4 p:SV_Position;float4 uv:TEXCOORD0;float3 world:TEXCOORD1;}; V main(uint id:SV_VertexID){V v;float2 uv=float2((id<<1)&2,id&2);float2 ndc=uv*float2(2,-2)+float2(-1,1);v.p=float4(ndc,0,1);v.uv=float4(ndc,1,1);float4 w=ndc.x*f[17]+ndc.y*f[18]+.5*f[19]+f[20];v.world=w.xyz/w.w;return v;}";
      Check(D3DCompile(sky_vs,strlen(sky_vs),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&vsBlob,nullptr));
      vs.Reset();Check(dev->CreateVertexShader(vsBlob->GetBufferPointer(),vsBlob->GetBufferSize(),nullptr,&vs));
      ctx->VSSetShader(vs.Get(),nullptr,0);
      const std::array<float,4> sky_pixel{.2f,.3f,.4f,1.f};
      std::array<D3D11_SUBRESOURCE_DATA,6> cube_data;
      for(auto& face:cube_data)face={sky_pixel.data(),16,0};
      const D3D11_TEXTURE2D_DESC cube_desc{1,1,1,6,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_TEXTURECUBE};
      ComPtr<ID3D11Texture2D> sky_cube;ComPtr<ID3D11ShaderResourceView> sky_view;
      Check(dev->CreateTexture2D(&cube_desc,cube_data.data(),&sky_cube));Check(dev->CreateShaderResourceView(sky_cube.Get(),nullptr,&sky_view));
      ctx->PSSetShaderResources(0,1,sky_view.GetAddressOf());
      const float shadow_depth=1;
      std::array<D3D11_SUBRESOURCE_DATA,4> shadow_data;
      for(auto& layer:shadow_data)layer={&shadow_depth,4,0};
      const D3D11_TEXTURE2D_DESC shadow_desc{1,1,1,4,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
      ComPtr<ID3D11Texture2D> shadow;ComPtr<ID3D11ShaderResourceView> shadow_view;
      Check(dev->CreateTexture2D(&shadow_desc,shadow_data.data(),&shadow));Check(dev->CreateShaderResourceView(shadow.Get(),nullptr,&shadow_view));
      ComPtr<ID3D11DeviceContext1> context;Check(ctx.As(&context));
      ComPtr<ID3D11Buffer> lighting;ctx->PSGetConstantBuffers(13,1,&lighting);
      witcher3classic::volumetrics::Pipeline pipeline;
      witcher3classic::volumetrics::Parameters parameters{{64,64,128,1000},{1,0,0,.5f},{1,.1f,0,0},{1.f/W,1.f/H,1,0}};
      parameters.sky[2]=per_pixel?1.f:0.f;parameters.sky[3]=4;
      uint64_t frame_id=0;double maximum=0;
      // Compare the actual native weather and an unsaturated density case.
      for(float base_density:{frame[44*4],.00005f})for(float multiplier:{0.f,.5f,1.f,2.f}) {
        frame[44*4]=base_density*multiplier;buffer(12,frame);
        ComPtr<ID3D11Buffer> constants;ctx->PSGetConstantBuffers(12,1,&constants);
        ctx->VSSetConstantBuffers(12,1,constants.GetAddressOf());
        auto native=render(native_sky.data(),native_sky.size());
        frame[44*4]=base_density;buffer(12,frame);constants.Reset();ctx->PSGetConstantBuffers(12,1,&constants);
        ctx->VSSetConstantBuffers(12,1,constants.GetAddressOf());parameters.sky[0]=multiplier;
        if(!pipeline.Generate(context.Get(),constants.Get(),lighting.Get(),shadow_view.Get(),nullptr,nullptr,parameters,++frame_id)
            ||!pipeline.Bind(context.Get(),false,frame_id))throw std::runtime_error("Sky volume setup failed");
        auto actual=render(custom_sky->GetBufferPointer(),custom_sky->GetBufferSize());pipeline.Restore(context.Get());
        double error=Difference(native,actual);maximum=std::max(maximum,error);
        std::cout<<"Native sky density="<<base_density<<", multiplier="<<multiplier<<", max RGB error="<<error<<'\n';
        if(error>.002)throw std::runtime_error("Sky haze differs from native scaled density");
      }
      std::cout<<"PASS native sky profile/color and independent 0/.5/1/2 density controls; max error="<<maximum<<'\n';
      return 0;
    }
    auto expected=render(original.data(),original.size());
    auto actual=render(code->GetBufferPointer(),code->GetBufferSize());
    float difference=Difference(expected,actual);
    if(difference>2.e-5f)throw std::runtime_error("Native fog fallback changed: "+std::to_string(difference));
    std::cout<<"PASS native-bytecode fog fallback, signed HDR, depth range, sky branch; max difference="<<difference<<'\n';
    // A constant integrated volume isolates composition, masks and resource binding.
    const float fog[8]={10,4,2,.5f,10,4,2,.5f};
    D3D11_TEXTURE3D_DESC vd={1,1,2,1,DXGI_FORMAT_R32G32B32A32_FLOAT,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    D3D11_SUBRESOURCE_DATA vi={fog,16,16};
    ComPtr<ID3D11Texture3D> volume;ComPtr<ID3D11ShaderResourceView> view;
    Check(dev->CreateTexture3D(&vd,&vi,&volume));Check(dev->CreateShaderResourceView(volume.Get(),nullptr,&view));
    ctx->PSSetShaderResources(116,1,view.GetAddressOf());ctx->PSSetSamplers(11,1,sampler.GetAddressOf());
    float params[16]={1,1,1,1000,1,0,1,.5f,1,.1f,0,0,1.f/W,1.f/H,1.f,1.f};
    D3D11_BUFFER_DESC bd={64,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
    D3D11_SUBRESOURCE_DATA bi={params};ComPtr<ID3D11Buffer> pb;ComPtr<ID3D11ShaderResourceView> pv;
    Check(dev->CreateBuffer(&bd,&bi,&pb));Check(dev->CreateShaderResourceView(pb.Get(),nullptr,&pv));ctx->PSSetShaderResources(117,1,pv.GetAddressOf());
    actual=render(code->GetBufferPointer(),code->GetBufferSize());
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
      size_t i=(y*W+x)*4;
      if(depth[i]*frame[22*4]+frame[22*4+1]>=1.f) {for(int c=0;c<3;++c)expected[i+c]=0;continue;}
      // Native pixel-to-world rows include their own sample-center offset;
      // the original shader explicitly converts SV_Position to integer pixels.
      double h[4];for(int c=0;c<4;++c)h[c]=double(x)*frame[210*4+c]+double(y)*frame[211*4+c]+depth[i]*frame[212*4+c]+frame[213*4+c];
      double distance=0;for(int c=0;c<3;++c)distance+=std::pow(h[c]/h[3]-frame[c],2);distance=std::sqrt(distance);
      double fade=std::clamp((distance-controls[0])/(controls[1]-controls[0]),0.,1.);
      double suppression=1.+(std::max(mask[i],controls[4])-1.)*(controls[2]+fade*(controls[3]-controls[2]));
      for(int c=0;c<3;++c)expected[i+c]=float(scene[i+c]*(1.-.5*suppression)+fog[c]*suppression);
    }
    difference=Difference(expected,actual);
    if(difference>3.e-4f)throw std::runtime_error("Integrated fog composition/mask mismatch: "+std::to_string(difference));
    std::cout<<"PASS custom scattering/transmittance composition with captured AO mask; max difference="<<difference<<'\n';
    // Exercise actual D3D11 rasterizer semantics, not a fabricated PS position.
    // SV_Position.w preserves clip W in D3D11; GLSL's reciprocal convention
    // previously made transparent surfaces almost fog-free.
    const char* perspective_vs="float4 main(uint id:SV_VertexID):SV_Position {float2 uv=float2((id<<1)&2,id&2);return float4((uv*float2(2,-2)+float2(-1,1))*32,16,32);}";
    Check(D3DCompile(perspective_vs,strlen(perspective_vs),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&vsBlob,nullptr));
    vs.Reset();Check(dev->CreateVertexShader(vsBlob->GetBufferPointer(),vsBlob->GetBufferSize(),nullptr,&vs));
    ctx->VSSetShader(vs.Get(),nullptr,0);
    std::array<float,33*4> gradient{};
    for(int z=0;z<=32;++z) {gradient[z*4]=gradient[z*4+1]=gradient[z*4+2]=float(z)/32;gradient[z*4+3]=1.f-float(z)/32;}
    vd.Depth=33;vi.pSysMem=gradient.data();volume.Reset();view.Reset();
    Check(dev->CreateTexture3D(&vd,&vi,&volume));Check(dev->CreateShaderResourceView(volume.Get(),nullptr,&view));
    ctx->PSSetShaderResources(116,1,view.GetAddressOf());
    params[2]=32;params[3]=1024;params[9]=1;ctx->UpdateSubresource(pb.Get(),0,nullptr,params,0,0);
    const auto include=Read("src/games/thewitcher3classic/volumetrics/sample.hlsli");
    std::string pixel_source(include.begin(),include.end());
    pixel_source+="\nfloat4 main(float4 p:SV_Position):SV_Target {return float4(SampleClassicFogPixel(p).x,p.w,0,1);}";
    ComPtr<ID3DBlob> pixel;
    Check(D3DCompile(pixel_source.data(),pixel_source.size(),"src/games/thewitcher3classic/volumetrics/probe.hlsl",nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,"main","ps_5_0",0,0,&pixel,nullptr));
    actual=render(pixel->GetBufferPointer(),pixel->GetBufferSize());
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
      const double nx=2.*(x+.5)/W-1.,ny=1.-2.*(y+.5)/H;
      const double distance=32.*std::sqrt(1.+nx*nx+ny*ny);
      const size_t i=(y*W+x)*4;
      // Filtering weights have finite fractional precision; one 1/256 weight
      // step over a 1/32 gradient is 0.0001221.
      if(std::abs(actual[i]-std::log2(distance)/10.)>2.e-4 || actual[i+1]!=32.f)
        throw std::runtime_error("D3D11 transparent-fragment distance or fog-volume lookup mismatch: sampled="+std::to_string(actual[i])+", expected="+std::to_string(std::log2(distance)/10.)+", W="+std::to_string(actual[i+1]));
    }
    std::cout<<"PASS actual D3D11 perspective W and radial fog sampling across the viewport\n";
    {
      // Independent continuous B-spline impulse response versus the production
      // eight-fetch reconstruction. Opacity must stay bit-identical to linear.
      std::vector<float> impulse(13*13*33*4);
      for(int z=0;z<33;++z)for(int y=0;y<13;++y)for(int x=0;x<13;++x) {
        size_t i=((z*13+y)*13+x)*4;
        impulse[i]=(x==6&&y==6&&z==16)?16.f:0.f;
        impulse[i+1]=2.f;impulse[i+3]=.25f+.01f*z;
      }
      D3D11_TEXTURE3D_DESC impulse_desc{13,13,33,1,DXGI_FORMAT_R32G32B32A32_FLOAT,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
      D3D11_SUBRESOURCE_DATA impulse_data{impulse.data(),13*16,13*13*16};
      ComPtr<ID3D11Texture3D> impulse_texture;ComPtr<ID3D11ShaderResourceView> impulse_view;
      Check(dev->CreateTexture3D(&impulse_desc,&impulse_data,&impulse_texture));
      Check(dev->CreateShaderResourceView(impulse_texture.Get(),nullptr,&impulse_view));
      std::array<float,22*4> controls{};controls[0]=controls[1]=13;controls[2]=32;controls[3]=1024;controls[9]=1;
      D3D11_BUFFER_DESC controls_desc{sizeof(controls),D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
      D3D11_SUBRESOURCE_DATA controls_data{controls.data()};ComPtr<ID3D11Buffer> controls_buffer;ComPtr<ID3D11ShaderResourceView> controls_view;
      Check(dev->CreateBuffer(&controls_desc,&controls_data,&controls_buffer));Check(dev->CreateShaderResourceView(controls_buffer.Get(),nullptr,&controls_view));
      ctx->PSSetShaderResources(116,1,impulse_view.GetAddressOf());ctx->PSSetShaderResources(117,1,controls_view.GetAddressOf());
      std::string reconstruction_source(include.begin(),include.end());
      reconstruction_source+="\nfloat4 main(float4 p:SV_Position):SV_Target {float3 c=float3(4+p.x*5/64,4+p.y*5/64,14+p.x*4/64);return SampleClassicFogRaw((c.xy+.5)/13,exp2(c.z*10/32));}";
      ComPtr<ID3DBlob> reconstruction;
      Check(D3DCompile(reconstruction_source.data(),reconstruction_source.size(),"src/games/thewitcher3classic/volumetrics/probe.hlsl",nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,"main","ps_5_0",D3DCOMPILE_OPTIMIZATION_LEVEL3,0,&reconstruction,nullptr));
      auto linear=render(reconstruction->GetBufferPointer(),reconstruction->GetBufferSize());
      controls[21*4]=1;ctx->UpdateSubresource(controls_buffer.Get(),0,nullptr,controls.data(),0,0);
      auto smooth=render(reconstruction->GetBufferPointer(),reconstruction->GetBufferSize());
      auto kernel=[](double x) {x=std::abs(x);return x<1?(4-6*x*x+3*x*x*x)/6:x<2?std::pow(2-x,3)/6:0.;};
      double maximum=0,maximum_change=0;
      for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
        size_t i=(y*W+x)*4;
        double reference=16*kernel(4+(x+.5)*5/64.-6)*kernel(4+(y+.5)*5/64.-6)*kernel(14+(x+.5)*4/64.-16);
        maximum=std::max(maximum,std::abs(smooth[i]-reference));maximum_change=std::max(maximum_change,double(std::abs(smooth[i]-linear[i])));
        if(smooth[i]<0 ||smooth[i]>16 ||std::abs(smooth[i+1]-2)>1.e-5 ||smooth[i+2]!=0 ||smooth[i+3]!=linear[i+3])
          throw std::runtime_error("Lighting reconstruction changed opacity, constant signal or HDR bounds");
      }
      std::cout<<"Cubic reference error="<<maximum<<", change from linear="<<maximum_change<<std::endl;
      // D3D11 texture interpolation has finite subtexel weight precision:
      // one 1/256 weight step on this 16-unit HDR impulse is 0.0625.
      if(maximum>16./256. ||maximum_change<.1)throw std::runtime_error("Cubic fog lighting reconstruction does not match B-spline reference");
      std::cout<<"PASS cubic HDR impulse/constant reconstruction, no overshoot, unchanged opacity; max reference error="<<maximum<<'\n';
      ctx->PSSetShaderResources(116,1,view.GetAddressOf());ctx->PSSetShaderResources(117,1,pv.GetAddressOf());
    }

    // Actual spark PS, with the captured VS output layout (TEXCOORD0..3,
    // SV_Position last). A prepended position silently shifts every input.
    const char* spark_vs="struct V{float4 a:TEXCOORD0;float3 b:TEXCOORD1;float4 c:TEXCOORD2;float4 d:TEXCOORD3;float4 p:SV_Position;};V main(uint id:SV_VertexID){V v;float2 uv=float2((id<<1)&2,id&2);v.a=float4(.11,.22,.33,.44);v.b=float3(0,.4,.6);v.c=float4(2,3,4,0);v.d=float4(5,6,7,.65);v.p=float4((uv*float2(2,-2)+float2(-1,1))*8,4,8);return v;}";
    Check(D3DCompile(spark_vs,strlen(spark_vs),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&vsBlob,nullptr));
    vs.Reset();Check(dev->CreateVertexShader(vsBlob->GetBufferPointer(),vsBlob->GetBufferSize(),nullptr,&vs));ctx->VSSetShader(vs.Get(),nullptr,0);
    std::vector<float> spark_cb2(12,1.f),spark_cb4(24,1.f);
    buffer(2,spark_cb2);buffer(4,spark_cb4);texture(0,1,1,{.7f,.4f,.2f,1.f});
    ID3D11ShaderResourceView* unbound=nullptr;ctx->PSSetShaderResources(117,1,&unbound);
    const auto native_spark=Read(root/"particle-originals/0xA7921C82.ps_5_0.cso");
    const auto spark=Compiled("0xA7921C82.ps_5_0.hlsl");
    expected=render(native_spark.data(),native_spark.size());actual=render(spark->GetBufferPointer(),spark->GetBufferSize());
    if(Difference(expected,actual)>1.e-6f || actual[0]<=0.f)throw std::runtime_error("Native spark linkage or emission changed");
    vd.Depth=2;vi.pSysMem=fog;volume.Reset();view.Reset();
    Check(dev->CreateTexture3D(&vd,&vi,&volume));Check(dev->CreateShaderResourceView(volume.Get(),nullptr,&view));ctx->PSSetShaderResources(116,1,view.GetAddressOf());
    params[2]=1;params[3]=1000;params[9]=.1f;ctx->UpdateSubresource(pb.Get(),0,nullptr,params,0,0);ctx->PSSetShaderResources(117,1,pv.GetAddressOf());
    actual=render(spark->GetBufferPointer(),spark->GetBufferSize());
    for(size_t i=0;i<expected.size();i+=4)for(int c=0;c<3;++c)expected[i+c]*=.5f;
    if(Difference(expected,actual)>1.e-6f)throw std::runtime_error("Additive spark must receive T only, with no fog radiance added");
    std::cout<<"PASS actual spark shader: native VS/PS linkage, unchanged unfogged emission, additive transmittance without in-scattering\n";

    // Igni glow contains bitwise selection of IEEE float 1.0. The decompiler
    // emitted a numeric 0x3f800000, making the radial falloff enormous. Compare
    // original bytecode over every pixel of the full texture-coordinate domain.
    const char* flame_vs="struct V{float4 a:TEXCOORD0;float4 b:TEXCOORD1;float3 c:TEXCOORD2;float4 d:TEXCOORD3;float3 e:TEXCOORD4;float3 f:TEXCOORD5;float4 p:SV_Position;};V main(uint id:SV_VertexID){V v;float2 uv=float2((id<<1)&2,id&2);v.a=0;v.b=0;v.c=float3(uv,1);v.d=float4(0,0,0,.3);v.e=float3(0,0,1);v.f=0;v.p=float4((uv*float2(2,-2)+float2(-1,1))*8,4,8);return v;}";
    Check(D3DCompile(flame_vs,strlen(flame_vs),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&vsBlob,nullptr));
    vs.Reset();Check(dev->CreateVertexShader(vsBlob->GetBufferPointer(),vsBlob->GetBufferSize(),nullptr,&vs));ctx->VSSetShader(vs.Get(),nullptr,0);
    std::vector<float> flame_frame(23*4),flame_camera(9*4),flame_controls(8);
    spark_cb2[8]=spark_cb2[9]=spark_cb2[10]=1000.f;buffer(2,spark_cb2);
    flame_frame[21*4]=1;flame_frame[22*4]=1;flame_camera[8*4+2]=10;flame_controls[6]=1.f/W;flame_controls[7]=1.f/H;
    buffer(0,flame_controls);buffer(1,flame_camera);buffer(12,flame_frame);texture(1,1,1,{.4f,.3f,.2f,1.f});texture(15,1,1,{.01f,0,0,0});
    ctx->PSSetShaderResources(117,1,&unbound);
    const auto native_flame=Read(root/"particle-originals/0x4EF2AAF8.ps_5_0.cso");const auto flame=Compiled("0x4EF2AAF8.ps_5_0.hlsl");
    expected=render(native_flame.data(),native_flame.size());actual=render(flame->GetBufferPointer(),flame->GetBufferSize());
    difference=Difference(expected,actual);if(difference>1.e-5f)throw std::runtime_error("Igni radial glow differs from native bytecode: "+std::to_string(difference));
    ctx->PSSetShaderResources(117,1,pv.GetAddressOf());actual=render(flame->GetBufferPointer(),flame->GetBufferSize());
    for(size_t i=0;i<expected.size();i+=4)for(int c=0;c<3;++c)expected[i+c]*=.5f;
    if(Difference(expected,actual)>1.e-5f)throw std::runtime_error("Igni radial glow custom transmittance mismatch");
    std::cout<<"PASS original Igni glow bytecode over full radial domain and custom transmittance; native max difference="<<difference<<'\n';
    // Actual production PS captures clip W=8, not reciprocal W=.125. Its
    // transparent billboard corners must not become reflection occluders.
    td.Width=W;td.Height=H;td.Format=DXGI_FORMAT_R32_FLOAT;td.Usage=D3D11_USAGE_DEFAULT;td.BindFlags=D3D11_BIND_RENDER_TARGET;td.CPUAccessFlags=0;
    ComPtr<ID3D11Texture2D> emission_depth,depth_readback;ComPtr<ID3D11RenderTargetView> depth_rt;
    Check(dev->CreateTexture2D(&td,nullptr,&emission_depth));Check(dev->CreateRenderTargetView(emission_depth.Get(),nullptr,&depth_rt));
    td.Usage=D3D11_USAGE_STAGING;td.BindFlags=0;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;Check(dev->CreateTexture2D(&td,nullptr,&depth_readback));
    ID3D11RenderTargetView* mrt[]={rt.Get(),nullptr,nullptr,nullptr,depth_rt.Get()};ctx->OMSetRenderTargets(5,mrt,nullptr);
    actual=render(flame->GetBufferPointer(),flame->GetBufferSize());
    if(Difference(expected,actual)>1.e-5f)throw std::runtime_error("Depth capture changed native particle color");
    ctx->CopyResource(depth_readback.Get(),emission_depth.Get());D3D11_MAPPED_SUBRESOURCE mapped;Check(ctx->Map(depth_readback.Get(),0,D3D11_MAP_READ,0,&mapped));
    size_t emitted=0,empty=0;
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
      const auto i=(y*W+x)*4;const float z=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)[x];
      const float luma=actual[i]*.2126f+actual[i+1]*.7152f+actual[i+2]*.0722f;
      if(luma>1.e-3f) {if(z!=8.f)throw std::runtime_error("Particle depth must equal rasterized clip W");++emitted;}
      else {if(z!=65504.f)throw std::runtime_error("Empty billboard contributes reflection depth");++empty;}
    }
    ctx->Unmap(depth_readback.Get(),0);
    std::cout<<"Particle depth visible="<<emitted<<" transparent="<<empty<<std::endl;
    if(!emitted || !empty)throw std::runtime_error("Particle-depth fixture needs visible and transparent pixels");
    std::cout<<"PASS native particle color with extra depth MRT; clip W and transparent holes\n";
    return 0;
  }catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}
}
