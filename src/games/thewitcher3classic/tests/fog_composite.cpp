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
    constexpr UINT W = 64, H = 64;
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

    auto frame=Constants("cb12.bin"), controls=Constants("cb3.bin");
    for(int k=0;k<4;++k) {frame[210*4+k]*=frame[23*4]/W;frame[211*4+k]*=frame[23*4+1]/H;}
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
    Check(D3DCompile(pixel_source.data(),pixel_source.size(),nullptr,nullptr,nullptr,"main","ps_5_0",0,0,&pixel,nullptr));
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
