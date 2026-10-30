/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Native-bytecode equivalence with varying material/probe/shadow inputs, then
// independent checks that controls change only their intended light terms.
#include <d3d11.h>
#include <d3dcompiler.h>
#include <d3d11shader.h>
#include <wrl/client.h>
#include <array>
#include <vector>
#include <fstream>
#include <iostream>
#include <string>
#include <cassert>
#include <cmath>
#include <cstring>
#include <algorithm>
#include "../lighting/contact.hpp"
#include "../lighting/player_fill.hpp"
using Microsoft::WRL::ComPtr;
using Pixel=std::array<float,4>;
std::vector<char> Read(const std::string& path) {
  std::ifstream file(path,std::ios::binary);assert(file);return {std::istreambuf_iterator<char>(file),{}};
}
int main(int argc,char**) {
  std::cout<<std::unitbuf;
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> ctx;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&ctx)));
  constexpr UINT W=64,H=64;
  const std::string scratch="tmp/witcher3classic-investigation/lighting-20261027/";
  std::array<Pixel,269> frame{};std::array<Pixel,3323> lighting{};
  auto bytes=Read(scratch+"lighting-cb12.bin");memcpy(frame.data(),bytes.data(),sizeof(frame));
  bytes=Read(scratch+"lighting-cb13.bin");memcpy(lighting.data(),bytes.data(),std::min(bytes.size(),sizeof(lighting)));
  // Deterministic receiver grid in world metres; captured probe and weather data.
  frame[0]={0,0,3,1};frame[210]={.03f,0,0,0};frame[211]={0,.03f,0,0};frame[212]={0,0,0,0};frame[213]={-.96f,-.96f,0,1};
  frame[22]={1,0,0,0};frame[23]={W,H,1.f/W,1.f/H};
  lighting[0]={.3f,0,.9539392f,0};lighting[1]={2,1.5f,1,0};
  lighting[58]={0,0,2,10};lighting[60]={0,0,-1,0};lighting[61]={4,3,2,0};
  { const UINT flags=0x1800;memcpy(&lighting[61][3],&flags,4); }
  lighting[62]={0,0,1,1};lighting[63]={1,1,0,0};lighting[64]={0,1,0,0};
  frame[183][2]=1;frame[183][3]=1;frame[69]={1,0,1,0};frame[186]={1,1,1,0};frame[187]={0,0,0,0};
  ComPtr<ID3D11Buffer> frame_cb,light_cb,draw_cb,param_buffer;ComPtr<ID3D11ShaderResourceView> param_view;
  auto buffer=[&](const void* data,UINT size,UINT bind,UINT stride) {
    D3D11_BUFFER_DESC d{size,D3D11_USAGE_DEFAULT,bind,0,stride?D3D11_RESOURCE_MISC_BUFFER_STRUCTURED:0u,stride};
    D3D11_SUBRESOURCE_DATA init{data};ComPtr<ID3D11Buffer> result;assert(SUCCEEDED(device->CreateBuffer(&d,&init,&result)));return result;
  };
  frame_cb=buffer(frame.data(),sizeof(frame),D3D11_BIND_CONSTANT_BUFFER,0);
  light_cb=buffer(lighting.data(),sizeof(lighting),D3D11_BIND_CONSTANT_BUFFER,0);
  // Exercise the actual shared producer policy, rather than shader-local
  // controls that left uncovered native skin LODs at full strength.
  auto upload_fill=[&](const witcher3classic::lighting::player_fill::Controls& controls) {
    auto common=frame;auto lights=lighting;
    std::array<float,0x4050/4> environment{};environment[0x404c/4]=frame[71][0];
    const UINT count=256;std::memcpy(&lights[57][0],&count,sizeof(count));
    witcher3classic::lighting::player_fill::ApplyCommon(common.data(),controls);
    witcher3classic::lighting::player_fill::ApplyLights(lights.data(),environment.data(),controls);
    ctx->UpdateSubresource(frame_cb.Get(),0,nullptr,common.data(),0,0);
    ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lights.data(),0,0);
  };
  Pixel draw{};draw_cb=buffer(draw.data(),sizeof(draw),D3D11_BIND_CONSTANT_BUFFER,0);
  std::array<Pixel,3> params{};param_buffer=buffer(params.data(),sizeof(params),D3D11_BIND_SHADER_RESOURCE,16);
  assert(SUCCEEDED(device->CreateShaderResourceView(param_buffer.Get(),nullptr,&param_view)));
  ctx->CSSetConstantBuffers(12,1,frame_cb.GetAddressOf());ctx->CSSetConstantBuffers(13,1,light_cb.GetAddressOf());
  ctx->PSSetConstantBuffers(12,1,frame_cb.GetAddressOf());ctx->PSSetConstantBuffers(13,1,light_cb.GetAddressOf());ctx->PSSetConstantBuffers(3,1,draw_cb.GetAddressOf());
  ctx->CSSetShaderResources(118,1,param_view.GetAddressOf());ctx->PSSetShaderResources(118,1,param_view.GetAddressOf());
  auto texture=[&](UINT w,UINT h,UINT layers,UINT mips,DXGI_FORMAT format,auto fill,bool cube=false) {
    std::vector<std::vector<Pixel>> pixels;std::vector<std::vector<float>> scalar;std::vector<D3D11_SUBRESOURCE_DATA> data;
    for(UINT layer=0;layer<layers;++layer)for(UINT mip=0;mip<mips;++mip) {
      UINT mw=std::max(1u,w>>mip),mh=std::max(1u,h>>mip);pixels.emplace_back(mw*mh);
      for(UINT y=0;y<mh;++y)for(UINT x=0;x<mw;++x)pixels.back()[y*mw+x]=fill(x,y,layer,mip);
      if(format==DXGI_FORMAT_R32_FLOAT) {
        scalar.emplace_back(mw*mh);for(UINT i=0;i<mw*mh;++i)scalar.back()[i]=pixels.back()[i][0];
        data.push_back({scalar.back().data(),mw*4});
      } else data.push_back({pixels.back().data(),mw*16});
    }
    D3D11_TEXTURE2D_DESC desc{w,h,mips,layers,format,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,cube?D3D11_RESOURCE_MISC_TEXTURECUBE:0u};
    ComPtr<ID3D11Texture2D> t;ComPtr<ID3D11ShaderResourceView> v;
    assert(SUCCEEDED(device->CreateTexture2D(&desc,data.data(),&t)));
    D3D11_SHADER_RESOURCE_VIEW_DESC vd{};vd.Format=format;
    if(cube){vd.ViewDimension=D3D11_SRV_DIMENSION_TEXTURECUBEARRAY;vd.TextureCubeArray.MipLevels=mips;vd.TextureCubeArray.NumCubes=layers/6;}
    else if(layers>1){vd.ViewDimension=D3D11_SRV_DIMENSION_TEXTURE2DARRAY;vd.Texture2DArray.MipLevels=mips;vd.Texture2DArray.ArraySize=layers;}
    else{vd.ViewDimension=D3D11_SRV_DIMENSION_TEXTURE2D;vd.Texture2D.MipLevels=mips;}
    assert(SUCCEEDED(device->CreateShaderResourceView(t.Get(),&vd,&v)));return v;
  };
  auto depth=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT,UINT,UINT,UINT){return Pixel{.5f,0,0,0};});
  auto albedo=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT x,UINT y,UINT,UINT){return Pixel{.1f+.8f*x/W,.15f+.7f*y/H,.5f,x%3==0?.5f:0.f};});
  auto normal=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT x,UINT y,UINT,UINT){float z=(x%2?1.f:-1.f)*.6f;return Pixel{.8f,.5f+.3f*std::sin(float(y)),.5f+z*.5f,.08f+.9f*y/H};});
  auto spec=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT x,UINT,UINT,UINT){return Pixel{.22f,.2f,.18f,float(x%16)/255};});
  auto mask=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT x,UINT y,UINT,UINT){return Pixel{.2f+.7f*y/H,.15f+.8f*x/W,x%2?1.f:0.f,1};});
  auto stencil=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_UINT,[](UINT x,UINT,UINT,UINT){Pixel v{};reinterpret_cast<UINT*>(v.data())[1]=x%2?2:0;return v;});
  auto probe=texture(48,168,1,6,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT x,UINT y,UINT,UINT m){return Pixel{.2f+.01f*x,.1f+.005f*y,.1f+.1f*m,1};});
  auto shadow=texture(64,64,4,1,DXGI_FORMAT_R32_FLOAT,[](UINT x,UINT,UINT l,UINT){return Pixel{x<32?.3f+.05f*l:.95f,0,0,0};});
  auto cloud=texture(64,64,4,2,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT x,UINT y,UINT,UINT){return Pixel{.1f+.3f*((x+y)%7)/7,0,0,0};});
  auto cube=texture(8,8,6,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT,UINT,UINT,UINT){return Pixel{1,1,1,1};},true);
  ID3D11ShaderResourceView* srvs[]={depth.Get(),albedo.Get(),normal.Get(),stencil.Get(),spec.Get(),nullptr,probe.Get(),probe.Get()};
  ctx->CSSetShaderResources(0,8,srvs);ctx->CSSetShaderResources(16,1,mask.GetAddressOf());
  D3D11_SAMPLER_DESC sd=CD3D11_SAMPLER_DESC(D3D11_DEFAULT);sd.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;sd.AddressU=sd.AddressV=sd.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;
  ComPtr<ID3D11SamplerState> sampler,comparison;assert(SUCCEEDED(device->CreateSamplerState(&sd,&sampler)));
  ctx->CSSetSamplers(6,1,sampler.GetAddressOf());for(UINT slot:{0u,6u,10u,11u,14u})ctx->PSSetSamplers(slot,1,sampler.GetAddressOf());
  sd.Filter=D3D11_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT;sd.ComparisonFunc=D3D11_COMPARISON_LESS_EQUAL;
  assert(SUCCEEDED(device->CreateSamplerState(&sd,&comparison)));ctx->PSSetSamplers(9,1,comparison.GetAddressOf());
  D3D11_TEXTURE2D_DESC td{W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_RENDER_TARGET|D3D11_BIND_UNORDERED_ACCESS};
  ComPtr<ID3D11Texture2D> output,staging;ComPtr<ID3D11UnorderedAccessView> uav;ComPtr<ID3D11RenderTargetView> rtv;
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&output)));assert(SUCCEEDED(device->CreateUnorderedAccessView(output.Get(),nullptr,&uav)));assert(SUCCEEDED(device->CreateRenderTargetView(output.Get(),nullptr,&rtv)));
  td.Usage=D3D11_USAGE_STAGING;td.BindFlags=0;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&staging)));
  auto read=[&](){ctx->CopyResource(staging.Get(),output.Get());D3D11_MAPPED_SUBRESOURCE m;assert(SUCCEEDED(ctx->Map(staging.Get(),0,D3D11_MAP_READ,0,&m)));std::vector<float> result(W*H*4);for(UINT y=0;y<H;++y)memcpy(result.data()+y*W*4,(const char*)m.pData+y*m.RowPitch,W*16);ctx->Unmap(staging.Get(),0);return result;};
  auto compare=[&](const auto& a,const auto& b,const char* label){float worst=0;size_t nonzero=0;for(size_t i=0;i<a.size();++i){assert(std::isfinite(a[i])&&std::isfinite(b[i]));worst=std::max(worst,std::abs(a[i]-b[i]));if(i%4<3&&a[i]!=0)++nonzero;}std::cout<<label<<" native max error="<<worst<<" nonzero="<<nonzero<<std::endl;assert(worst<.002f&&nonzero>100);};
  auto cs=[&](const std::string& path){auto code=Read(path);ComPtr<ID3D11ComputeShader> shader;assert(SUCCEEDED(device->CreateComputeShader(code.data(),code.size(),nullptr,&shader)));ctx->CSSetShader(shader.Get(),nullptr,0);ctx->CSSetUnorderedAccessViews(0,1,uav.GetAddressOf(),nullptr);ctx->Dispatch(W/16,H/16,1);return read();};
  auto original=cs(scratch+"originals/0xFB29B4E6.cs_5_0.cso");auto baseline=cs("build/thewitcher3classic.include/embed/0xFB29B4E6.cso");compare(original,baseline,"Directional/IBL");
  params[0]={1,1,0,0};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  auto custom=cs("build/thewitcher3classic.include/embed/0xFB29B4E6.cso");size_t changed=0;for(size_t i=0;i<custom.size();++i){assert(std::isfinite(custom[i]));if(std::abs(custom[i]-baseline[i])>.001f)++changed;}assert(changed>100);std::cout<<"Custom direct BRDF/AO changed="<<changed<<std::endl;
  params={};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);ID3D11UnorderedAccessView* null_uav=nullptr;ctx->CSSetUnorderedAccessViews(0,1,&null_uav,nullptr);
  const char* vs_text="float4 main(uint id:SV_VertexID):SV_Position{float2 uv=float2((id<<1)&2,id&2);return float4(uv*float2(2,-2)+float2(-1,1),.5,1);}";
  ComPtr<ID3DBlob> code;assert(SUCCEEDED(D3DCompile(vs_text,strlen(vs_text),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&code,nullptr)));ComPtr<ID3D11VertexShader> vs;assert(SUCCEEDED(device->CreateVertexShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&vs)));
  ctx->VSSetShader(vs.Get(),nullptr,0);ctx->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);D3D11_VIEWPORT viewport{0,0,W,H,0,1};ctx->RSSetViewports(1,&viewport);ctx->OMSetRenderTargets(1,rtv.GetAddressOf(),nullptr);
  auto ps=[&](const std::string& path){auto code=Read(path);ComPtr<ID3D11PixelShader> shader;assert(SUCCEEDED(device->CreatePixelShader(code.data(),code.size(),nullptr,&shader)));ctx->PSSetShader(shader.Get(),nullptr,0);ctx->Draw(3,0);return read();};
  ID3D11ShaderResourceView* pixels[]={depth.Get(),albedo.Get(),normal.Get(),spec.Get(),mask.Get(),stencil.Get()};ctx->PSSetShaderResources(0,6,pixels);ctx->PSSetShaderResources(9,1,shadow.GetAddressOf());ctx->PSSetShaderResources(10,1,cube.GetAddressOf());
  for(const char* hash:{"0x95991F6F","0xD3573BB9","0x72225972","0x3FFDA0D9","0x3946E96C","0x0AB3A292","0x3CED9DA6","0xED6CEFE4"}) {
    params={};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
    auto a=ps(scratch+"originals/"+hash+".ps_5_0.cso"),b=ps(std::string("build/thewitcher3classic.include/embed/")+hash+".cso");compare(a,b,hash);
    // Light ordering changes with visibility. Slot zero alone cannot detect
    // decompiler errors in relative CB indexing or stale per-draw selection.
    for (UINT index : {1u,7u,31u,255u}) {
      std::copy_n(lighting.begin()+58,9,lighting.begin()+58+9*index);
      lighting[61+9*index][0] *= .75f;
      draw[0]=float(index);
      ctx->UpdateSubresource(draw_cb.Get(),0,nullptr,draw.data(),0,0);
      ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
      auto indexed_native=ps(scratch+"originals/"+hash+".ps_5_0.cso");
      auto indexed_custom=ps(std::string("build/thewitcher3classic.include/embed/")+hash+".cso");
      compare(indexed_native,indexed_custom,"Reordered local-light native equivalence");
    }
    draw[0]=0;
    ctx->UpdateSubresource(draw_cb.Get(),0,nullptr,draw.data(),0,0);
    params[0]={1,1,0,0};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);auto c=ps(std::string("build/thewitcher3classic.include/embed/")+hash+".cso");changed=0;for(size_t i=0;i<c.size();++i){assert(std::isfinite(c[i]));if(std::abs(c[i]-b[i])>.001f)++changed;}assert(changed>100);
    // Only engine-tagged camera lights respond to the player controls.
    params={};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
    upload_fill({true,true,0.f});
    auto ordinary=ps(std::string("build/thewitcher3classic.include/embed/")+hash+".cso");compare(b,ordinary,"World light unaffected by player control");
    const UINT fill_flags=0x80001800u;memcpy(&lighting[61][3],&fill_flags,4);frame[71][0]=.25f;
    ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);ctx->UpdateSubresource(frame_cb.Get(),0,nullptr,frame.data(),0,0);
    params={};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);auto fill_native=ps(std::string("build/thewitcher3classic.include/embed/")+hash+".cso");
    upload_fill({true,false,.5f});auto half=ps(std::string("build/thewitcher3classic.include/embed/")+hash+".cso");
    for(size_t k=0;k<half.size();++k)if(k%4<3)assert(std::abs(half[k]-.5f*fill_native[k])<.002f);
    upload_fill({true,true,1.f});auto unified=ps(std::string("build/thewitcher3classic.include/embed/")+hash+".cso");
    bool native_recipient=std::string(hash)=="0x72225972"||std::string(hash)=="0x3FFDA0D9"||std::string(hash)=="0x0AB3A292"||std::string(hash)=="0x3CED9DA6";
    for(size_t k=0;k<unified.size();++k)if(k%4<3){float expected_scale=native_recipient&&((k/4)%W)%2==0?1.f:.25f;assert(std::abs(unified[k]-expected_scale*fill_native[k])<.002f);}
    const UINT world_flags=0x1800u;memcpy(&lighting[61][3],&world_flags,4);ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
    if(std::string(hash)=="0x3946E96C"||std::string(hash)=="0x3CED9DA6"
        ||std::string(hash)=="0x0AB3A292"||std::string(hash)=="0xED6CEFE4") {
      const auto saved60=lighting[60],saved63=lighting[63],saved65=lighting[65],saved66=lighting[66];
      auto atlas=texture(64,64,4,1,DXGI_FORMAT_R32_FLOAT,[](UINT x,UINT y,UINT layer,UINT){return Pixel{.17f+.08f*x/64+.01f*layer+.005f*y/64,0,0,0};});
      ctx->PSSetShaderResources(9,1,atlas.GetAddressOf());
      params={};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
      lighting[60][3]=1.f;lighting[63][2]=1.f;
      std::vector<float> first_atlas;
      for(UINT layer:{0u,2u}) {
        const UINT packed_tile=((layer==0?128u:640u)<<20)|(96u<<10)|256u|(layer<<30);
        for(float& v:lighting[65])memcpy(&v,&packed_tile,4);
        for(float& v:lighting[66])memcpy(&v,&packed_tile,4);
        // Spot shadow basis is stored alongside its packed atlas tile.
        if(std::string(hash)=="0x0AB3A292"||std::string(hash)=="0xED6CEFE4") {
          lighting[65][1]=0;lighting[65][2]=1;lighting[65][3]=0;
        }
        ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
        auto expected=ps(scratch+"originals/"+hash+".ps_5_0.cso");
        auto actual=ps(std::string("build/thewitcher3classic.include/embed/")+hash+".cso");
        compare(expected,actual,"Packed local shadow atlas");
        if(first_atlas.empty())first_atlas=expected;
        else {size_t altered=0;for(size_t k=0;k<expected.size();++k)if(std::abs(expected[k]-first_atlas[k])>.001f)++altered;assert(altered>30);}
      }
      lighting[60]=saved60;lighting[63]=saved63;lighting[65]=saved65;lighting[66]=saved66;
      ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
      ctx->PSSetShaderResources(9,1,shadow.GetAddressOf());
    }

  }
  // Main shadow mask: cloud/terrain intact with controls disabled. New PCSS
  // must react to blockers and remain finite across cascade transitions.
  params={};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  ctx->PSSetShaderResources(2,1,spec.GetAddressOf());ctx->PSSetShaderResources(8,1,shadow.GetAddressOf());ctx->PSSetShaderResources(14,1,cloud.GetAddressOf());ctx->PSSetShaderResources(15,1,cloud.GetAddressOf());ctx->PSSetShaderResources(19,1,cloud.GetAddressOf());
  lighting[4]={.5f,0,0,0};lighting[5]={0,.5f,0,0};lighting[6]={0,0,.01f,0};lighting[7]={0,0,.5f,0};lighting[8]={0,0,0,0};lighting[9]={0,0,0,0};lighting[10]={.15f,.3f,.6f,1};lighting[15][2]=4;lighting[17]={.15f,.15f,.15f,.15f};lighting[35]={0,0,0,0};for(UINT i=0;i<4;++i)lighting[11+i]={.5f,.5f,.5f/lighting[10][i],1.f/64};
  ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
  auto a=ps(scratch+"originals/0x05FE9FA8.ps_5_0.cso"),b=ps("build/thewitcher3classic.include/embed/0x05FE9FA8.cso");compare(a,b,"Shadow mask");
  params[0][2]=1;params[2]={.535f,0,W,H};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  auto c=ps("build/thewitcher3classic.include/embed/0x05FE9FA8.cso");float low=1,high=0;for(float v:c){assert(std::isfinite(v)&&v>=0&&v<=1);low=std::min(low,v);high=std::max(high,v);}std::cout<<"PCSS visibility "<<low<<".."<<high<<std::endl;assert(low<.1f&&high>.8f);
  // Perspective depth field: a plane at view Z=3 and an occluding strip at 2.9.
  // This verifies camera projection, linearization, world-space reach and self-hit rejection.
  frame[0]={0,0,-3,1};frame[1]={1,0,0,0};frame[2]={0,1,0,0};frame[3]={0,0,1,0};frame[4]={0,0,3,1};
  frame[13]={1,0,0,0};frame[14]={0,1,0,0};frame[15]={0,0,1,1};frame[16]={0,0,0,0};
  frame[210]={2.f/W,0,0,0};frame[211]={0,-2.f/H,0,0};frame[212]={0,0,-3,1};frame[213]={-1,1,1,0};frame[21]={1,0,0,0};
  lighting[0]={.8f,0,-.6f,0};lighting[15][2]=0;
  ctx->UpdateSubresource(frame_cb.Get(),0,nullptr,frame.data(),0,0);ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
  params={};params[0][3]=.3f;params[2]={.535f,0,W,H};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  auto contact_depth=[&](bool strip,UINT stencil_bits) {
    std::vector<UINT> pixels(W*H);
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x)
      pixels[y*W+x]=UINT(std::round(16777215.f/(strip&&x>31&&x<38?2.9f:3.f)))|(stencil_bits<<24);
    D3D11_TEXTURE2D_DESC desc{W,H,1,1,DXGI_FORMAT_R24G8_TYPELESS,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_DEPTH_STENCIL};
    D3D11_SUBRESOURCE_DATA initial{pixels.data(),W*4};ComPtr<ID3D11Texture2D> t;ComPtr<ID3D11ShaderResourceView> v;
    assert(SUCCEEDED(device->CreateTexture2D(&desc,&initial,&t)));
    D3D11_SHADER_RESOURCE_VIEW_DESC vd{};vd.Format=DXGI_FORMAT_R24_UNORM_X8_TYPELESS;vd.ViewDimension=D3D11_SRV_DIMENSION_TEXTURE2D;vd.Texture2D.MipLevels=1;
    assert(SUCCEEDED(device->CreateShaderResourceView(t.Get(),&vd,&v)));return v;
  };
  witcher3classic::lighting::ContactPipeline contact_pipeline;
  ComPtr<ID3D11DeviceContext1> context1;assert(SUCCEEDED(ctx.As(&context1)));
  auto contact_draw=[&]() {
    ID3D11ShaderResourceView* contact_view=contact_pipeline.Generate(context1.Get(),param_view.Get(),W,H);
    assert(contact_view);
    // Isolated dispatches must restore the native PS bindings and CB ranges.
    ComPtr<ID3D11ShaderResourceView> restored;ctx->PSGetShaderResources(118,1,&restored);assert(restored==param_view);
    ComPtr<ID3D11Buffer> restored_cb;context1->PSGetConstantBuffers(12,1,&restored_cb);assert(restored_cb==frame_cb);
    ctx->PSSetShaderResources(119,1,&contact_view);
    auto result=ps("build/thewitcher3classic.include/embed/0x05FE9FA8.cso");
    ID3D11ShaderResourceView* empty=nullptr;ctx->PSSetShaderResources(119,1,&empty);
    return result;
  };
  auto flat=contact_depth(false,0);
  auto face_normal=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT,UINT,UINT,UINT){return Pixel{.5f,.5f,0,1};});
  ctx->PSSetShaderResources(1,1,face_normal.GetAddressOf());
  auto opaque_material=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT,UINT,UINT,UINT){return Pixel{.04f,.04f,.04f,0};});
  ctx->PSSetShaderResources(2,1,opaque_material.GetAddressOf());
  ctx->PSSetShaderResources(0,1,flat.GetAddressOf());auto flat_contact=contact_draw();
  params[0][3]=0;ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);auto flat_native=ps("build/thewitcher3classic.include/embed/0x05FE9FA8.cso");compare(flat_native,flat_contact,"Contact flat plane");
  auto occluder=contact_depth(true,0);
  ctx->PSSetShaderResources(0,1,occluder.GetAddressOf());auto no_contact=ps("build/thewitcher3classic.include/embed/0x05FE9FA8.cso");
  params[0][3]=.3f;ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);auto contact=contact_draw();
  changed=0;for(UINT i=0;i<W*H;++i){assert(std::isfinite(contact[i*4])&&contact[i*4]<=no_contact[i*4]+.0001f);if(no_contact[i*4]-contact[i*4]>.05f)++changed;}std::cout<<"Contact strip shadow pixels="<<changed<<std::endl;assert(changed>30);
  for(UINT material:{1u,8u,6u,128u,255u}) {
    auto material_view=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[&](UINT,UINT,UINT,UINT){return Pixel{.04f,.04f,.04f,float(material)/255};});
    ctx->PSSetShaderResources(2,1,material_view.GetAddressOf());auto result=contact_draw();
    size_t shadowed=0;for(UINT i=0;i<W*H;++i){assert(std::isfinite(result[i*4]));if(result[i*4]<.99f)++shadowed;}
    std::cout<<"Contact material "<<material<<" shadow pixels="<<shadowed<<std::endl;
    if(material==1||material==8)assert(shadowed>0);else assert(shadowed==0);
  }
  for(UINT blocker:{6u,128u,255u}) {
    auto material_view=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[&](UINT x,UINT,UINT,UINT){return Pixel{.04f,.04f,.04f,x>31&&x<38?float(blocker)/255:0.f};});
    ctx->PSSetShaderResources(2,1,material_view.GetAddressOf());auto result=contact_draw();
    size_t shadowed=0;for(UINT y=0;y<H;++y)for(UINT x=0;x<32;++x)if(result[(y*W+x)*4]<.99f)++shadowed;
    std::cout<<"Contact blocker "<<blocker<<" shadow pixels="<<shadowed<<std::endl;
    if(blocker==6)assert(shadowed>0);else assert(shadowed==0);
  }
  ctx->PSSetShaderResources(2,1,opaque_material.GetAddressOf());
  auto back_normal=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT,UINT,UINT,UINT){return Pixel{.5f,.5f,1,1};});
  ctx->PSSetShaderResources(1,1,back_normal.GetAddressOf());
  auto back=contact_draw();for(UINT i=0;i<W*H;++i)assert(std::abs(back[i*4]-1.f)<1.e-6f);
  auto character_depth=contact_depth(true,2);ctx->PSSetShaderResources(0,1,character_depth.GetAddressOf());
  auto character=contact_draw();changed=0;for(UINT i=0;i<W*H;++i)if(character[i*4]<.99f)++changed;
  std::cout<<"Back-facing character contact pixels="<<changed<<std::endl;assert(changed>0);
  // Reproduce ranged bindings: copying the buffer pointer without FirstConstant
  // silently reads a different camera/light. The isolated dispatch must preserve
  // these ranges and restore the native graphics state exactly.
  std::vector<Pixel> padded_frame(16+272),padded_light(16+64);
  std::copy_n(frame.begin(),214,padded_frame.begin()+16);
  std::copy_n(lighting.begin(),49,padded_light.begin()+16);
  auto ranged_frame=buffer(padded_frame.data(),UINT(padded_frame.size()*16),D3D11_BIND_CONSTANT_BUFFER,0);
  auto ranged_light=buffer(padded_light.data(),UINT(padded_light.size()*16),D3D11_BIND_CONSTANT_BUFFER,0);
  UINT first_constant=16,frame_count=224,light_count=64;
  context1->PSSetConstantBuffers1(12,1,ranged_frame.GetAddressOf(),&first_constant,&frame_count);
  context1->PSSetConstantBuffers1(13,1,ranged_light.GetAddressOf(),&first_constant,&light_count);
  ID3D11ShaderResourceView* ranged_mask=contact_pipeline.Generate(context1.Get(),param_view.Get(),W,H);assert(ranged_mask);
  ctx->PSSetShaderResources(119,1,&ranged_mask);auto ranged=ps("build/thewitcher3classic.include/embed/0x05FE9FA8.cso");
  compare(character,ranged,"Contact ranged constants");
  UINT restored_first=0,restored_count=0;ComPtr<ID3D11Buffer> restored_range;
  context1->PSGetConstantBuffers1(12,1,&restored_range,&restored_first,&restored_count);
  assert(restored_range==ranged_frame&&restored_first==16&&restored_count==224);
  ctx->PSSetConstantBuffers(12,1,frame_cb.GetAddressOf());ctx->PSSetConstantBuffers(13,1,light_cb.GetAddressOf());
  ID3D11ShaderResourceView* no_mask=nullptr;ctx->PSSetShaderResources(119,1,&no_mask);
  // Odd render sizes in a larger allocation: the compute passes only write the
  // active rectangle. A failed size request must not expose an older mask.
  params[2][2]=31;params[2][3]=27;ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  ID3D11ShaderResourceView* small_mask=contact_pipeline.Generate(context1.Get(),param_view.Get(),31,27);assert(small_mask);
  ComPtr<ID3D11Resource> small_resource;small_mask->GetResource(&small_resource);ComPtr<ID3D11Texture2D> small_texture;assert(SUCCEEDED(small_resource.As(&small_texture)));
  D3D11_TEXTURE2D_DESC small_desc;small_texture->GetDesc(&small_desc);assert(small_desc.Width==31&&small_desc.Height==27);
  assert(!contact_pipeline.Generate(context1.Get(),param_view.Get(),W+1,H));
  frame[23]={31,27,1.f/31,1.f/27};ctx->UpdateSubresource(frame_cb.Get(),0,nullptr,frame.data(),0,0);
  ID3D11ShaderResourceView* cropped=contact_pipeline.Generate(context1.Get(),param_view.Get(),31,27);assert(cropped);
  ctx->PSSetShaderResources(119,1,&cropped);auto cropped_result=ps("build/thewitcher3classic.include/embed/0x05FE9FA8.cso");
  ctx->PSSetShaderResources(119,1,&no_mask);
  params[2][2]=W;params[2][3]=H;ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  auto pooled_result=contact_draw();compare(cropped_result,pooled_result,"Contact active rectangle in larger pool");
  frame[23]={W,H,1.f/W,1.f/H};ctx->UpdateSubresource(frame_cb.Get(),0,nullptr,frame.data(),0,0);
  params[2][2]=W;params[2][3]=H;ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  auto resized=contact_draw();compare(character,resized,"Contact resize recovery");

  // Exercise the production history allocation, GPU constant copies and ranged
  // bindings. The shader-specific noise/reprojection checks live in contact_history.cpp.
  // This fixture has constant normals and fully lit native visibility. Its raw
  // mask can therefore be convolved independently to check the spatial stage.
  auto spatial_reference=[&](const std::vector<float>& raw) {
    auto result=raw;
    for(int y=0;y<int(H);++y)for(int x=0;x<int(W);++x) {
      const float z=x>31&&x<38?2.900390625f:3.f; // Stored FP16 trace depth.
      float sum=0.f,weight=0.f;
      for(int dy=-1;dy<=1;++dy)for(int dx=-1;dx<=1;++dx) {
        if(x+dx<0||x+dx>=int(W)||y+dy<0||y+dy>=int(H))continue;
        const float nz=x+dx>31&&x+dx<38?2.900390625f:3.f;
        const float w=std::exp2(-std::abs(nz-z)/(.01f*z))*(dx==0?2.f:1.f)*(dy==0?2.f:1.f);
        sum+=raw[((y+dy)*W+x+dx)*4]*w;weight+=w;
      }
      for(int c=0;c<4;++c)result[(y*W+x)*4+c]=sum/weight;
    }
    return result;
  };
  const auto filtered_character=spatial_reference(character);
  auto temporal_draw=[&](uint64_t id,ID3D11ShaderResourceView* motion=nullptr,ID3D11ShaderResourceView* motion_depth=nullptr) {
    ID3D11ShaderResourceView* view=contact_pipeline.Generate(context1.Get(),param_view.Get(),W,H,id,motion,motion_depth);
    assert(view);ctx->PSSetShaderResources(119,1,&view);
    auto result=ps("build/thewitcher3classic.include/embed/0x05FE9FA8.cso");
    ctx->PSSetShaderResources(119,1,&no_mask);return result;
  };
  compare(filtered_character,temporal_draw(100),"Contact spatial filter before first history frame");
  compare(filtered_character,temporal_draw(101),"Contact history uncovered character fallback");
  context1->PSSetConstantBuffers1(12,1,ranged_frame.GetAddressOf(),&first_constant,&frame_count);
  context1->PSSetConstantBuffers1(13,1,ranged_light.GetAddressOf(),&first_constant,&light_count);
  compare(filtered_character,temporal_draw(102),"Contact history ranged GPU copies");
  context1->PSGetConstantBuffers1(12,1,&restored_range,&restored_first,&restored_count);
  assert(restored_range==ranged_frame&&restored_first==16&&restored_count==224);
  ctx->PSSetConstantBuffers(12,1,frame_cb.GetAddressOf());ctx->PSSetConstantBuffers(13,1,light_cb.GetAddressOf());
  compare(filtered_character,temporal_draw(105),"Contact history frame gap");
  assert(!contact_pipeline.Generate(context1.Get(),param_view.Get(),W+1,H,106));
  compare(filtered_character,temporal_draw(107),"Contact history failed input recovery");
  auto still_motion=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT,UINT,UINT,UINT){return Pixel{};});
  auto matched_depth=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT x,UINT,UINT,UINT){
    return Pixel{std::round(16777215.f/(x>31&&x<38?2.9f:3.f))/16777215.f,0,0,0};
  });
  compare(filtered_character,temporal_draw(108,still_motion.Get(),matched_depth.Get()),"Contact history stationary object");
  auto alternating_blocker=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT x,UINT y,UINT,UINT){
    return Pixel{.04f,.04f,.04f,x>31&&x<38&&(y&1u)?128.f/255:0.f};
  });
  ctx->PSSetShaderResources(2,1,alternating_blocker.GetAddressOf());
  witcher3classic::lighting::ContactPipeline raw_pipeline;
  ID3D11ShaderResourceView* raw_mask=raw_pipeline.Generate(context1.Get(),param_view.Get(),W,H);assert(raw_mask);
  ctx->PSSetShaderResources(119,1,&raw_mask);auto raw_alternating=ps("build/thewitcher3classic.include/embed/0x05FE9FA8.cso");
  ctx->PSSetShaderResources(119,1,&no_mask);
  const auto filtered_alternating=spatial_reference(raw_alternating);
  auto stable_alternating=temporal_draw(109,still_motion.Get(),matched_depth.Get());
  changed=0;for(UINT i=0;i<W*H;++i)if(std::abs(filtered_alternating[i*4]-stable_alternating[i*4])>.01f)++changed;
  assert(changed>20);std::cout<<"Contact history accumulation active pixels="<<changed<<'\n';
  // Updating settings must invalidate real accumulated GPU history immediately.
  params[0][0]=1;ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  compare(filtered_alternating,temporal_draw(110,still_motion.Get(),matched_depth.Get()),"Contact history settings reset");
  params[0][0]=0;ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  ctx->PSSetShaderResources(2,1,opaque_material.GetAddressOf());

  // Fixed screen-space sampling must not move when world reach changes.
  // At this zoom the complete screen-space kernel fits inside every reach.
  // The old stretched 24-tap lattice changes silhouettes between these values.
  const auto saved_contact_frame=frame;
  const auto saved_contact_lighting=lighting;
  ctx->PSSetShaderResources(1,1,face_normal.GetAddressOf());
  ctx->PSSetShaderResources(2,1,opaque_material.GetAddressOf());
  for(UINT axis=0;axis<2;++axis)for(float sign:{-1.f,1.f})for(float phase:{0.f,.25f,.75f}) {
    frame=saved_contact_frame;
    frame[13][0]=frame[14][1]=100.f;
    frame[210][0]=2.f/W/100.f;frame[211][1]=-2.f/H/100.f;
    frame[213][0]=(-1.f+phase*2.f/W)/100.f;
    frame[213][1]=(1.f-phase*2.f/H)/100.f;
    lighting[0]=axis==0?Pixel{sign*.8f,0,-.6f,0}:Pixel{0,-sign*.8f,-.6f,0};
    ctx->UpdateSubresource(frame_cb.Get(),0,nullptr,frame.data(),0,0);
    ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
    std::vector<UINT> pixels(W*H);
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x)
      pixels[y*W+x]=UINT(std::round(16777215.f/((axis==0?x:y)==32?2.98f:3.f)))|(2u<<24);
    const D3D11_TEXTURE2D_DESC desc{W,H,1,1,DXGI_FORMAT_R24G8_TYPELESS,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_DEPTH_STENCIL};
    D3D11_SUBRESOURCE_DATA data{pixels.data(),W*4};
    ComPtr<ID3D11Texture2D> tex;ComPtr<ID3D11ShaderResourceView> view;
    assert(SUCCEEDED(device->CreateTexture2D(&desc,&data,&tex)));
    D3D11_SHADER_RESOURCE_VIEW_DESC vd{};vd.Format=DXGI_FORMAT_R24_UNORM_X8_TYPELESS;
    vd.ViewDimension=D3D11_SRV_DIMENSION_TEXTURE2D;vd.Texture2D.MipLevels=1;
    assert(SUCCEEDED(device->CreateShaderResourceView(tex.Get(),&vd,&view)));
    ctx->PSSetShaderResources(0,1,view.GetAddressOf());
    std::vector<float> reference;
    for(float reach:{.08f,.16f,.3f,.6f}) {
      params[0][3]=reach;ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
      auto result=contact_draw();
      if(reference.empty())reference=result;
      else compare(reference,result,"Contact reach preserves sampling");
      UINT count=0;
      for(UINT y=8;y<H-8;++y)for(UINT x=8;x<W-8;++x)if(result[(y*W+x)*4]<.99f) {
        ++count;
        // At 64x64 BlitzFX's 16-tap screen range is about 3.2 pixels;
        // allow the raster footprint and the existing one-pixel filter.
        assert(std::abs(int(axis==0?x:y)-32)<=5);
      }
      assert(count>20);
    }
    // A continuous shallow sloping plane, viewed at close range, is not an
    // occluder of itself when the light points out of it. This catches the
    // faceted acne caused by the rejected surface-crossing/no-bias trace.
    lighting[0]=axis==0?Pixel{sign*.8f,0,.15f,0}:Pixel{0,-sign*.8f,.15f,0};
    ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
    auto slope_normal=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[&](UINT,UINT,UINT,UINT){
      const float n=std::sqrt(1.04f);
      return axis==0?Pixel{.5f+sign*.1f/n,.5f,.5f-.5f/n,1}:Pixel{.5f,.5f-sign*.1f/n,.5f-.5f/n,1};
    });
    ctx->PSSetShaderResources(1,1,slope_normal.GetAddressOf());
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
      const float ndc=(-1.f+2.f*((axis==0?x:y)+phase)/W)/100.f;
      const float raw=(1.f-sign*.2f*ndc)/3.f;
      pixels[y*W+x]=UINT(std::round(16777215.f*raw))|(2u<<24);
    }
    ctx->UpdateSubresource(tex.Get(),0,nullptr,pixels.data(),W*4,0);
    auto slope=contact_draw();
    for(UINT y=8;y<H-8;++y)for(UINT x=8;x<W-8;++x)assert(slope[(y*W+x)*4]>.999f);
    ctx->PSSetShaderResources(1,1,face_normal.GetAddressOf());
  }
  frame=saved_contact_frame;lighting=saved_contact_lighting;
  params[0][3]=.3f;ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  ctx->UpdateSubresource(frame_cb.Get(),0,nullptr,frame.data(),0,0);
  ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
  std::cout<<"PASS fixed sampling across reach/axis/direction/phase and sloped-surface self-shadow rejection\n";

  // Actual HairWorks constant layout with synthetic, spatially varying textures.
  // Packed mixed-type PS inputs must match the original linkage exactly.
  std::array<ComPtr<ID3D11Buffer>,4> hair_constants;
  UINT n=0;for(UINT slot:{2u,10u,12u,13u}) {
    auto b=Read(scratch+"hair-cb"+std::to_string(slot)+".bin");
    hair_constants[n]=buffer(b.data(),UINT(b.size()),D3D11_BIND_CONSTANT_BUFFER,0);
    ctx->PSSetConstantBuffers(slot,1,hair_constants[n++].GetAddressOf());
  }
  const char* hair_vs=R"(
    struct Output {float4 position:SV_Position; nointerpolation float packed:COMP_TEX_COORD;
      nointerpolation uint primitive:PRIMITIVE_ID; nointerpolation float coords:COORDS; float hair:HAIR_TEX;};
    Output main(uint id:SV_VertexID) {float2 uv=float2((id<<1)&2,id&2);Output o;
      o.position=float4(uv*float2(2,-2)+float2(-1,1),.97,1);o.packed=.25;
      o.primitive=0;o.coords=.25;o.hair=.1+.7*uv.x;return o;})";
  code.Reset();assert(SUCCEEDED(D3DCompile(hair_vs,strlen(hair_vs),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&code,nullptr)));
  vs.Reset();assert(SUCCEEDED(device->CreateVertexShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&vs)));ctx->VSSetShader(vs.Get(),nullptr,0);
  std::array<ComPtr<ID3D11Buffer>,5> hair_buffers;std::array<ComPtr<ID3D11ShaderResourceView>,5> hair_views;
  for(UINT index=0;index<5;++index) {
    UINT size=index<3?65536:1024*1024;std::vector<UINT> words(size/4,index==3?256:192);
    if(index<3)for(UINT v=0;v<size/16;++v) {
      Pixel value=index==0?Pixel{0,1,2,0}:Pixel{.1f+.8f*std::sin(v*.3f),.7f,.2f+.6f*std::cos(v*.3f),0};
      memcpy(words.data()+v*4,value.data(),16);
    }
    D3D11_BUFFER_DESC bd{size,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,index<3?0u:D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS};D3D11_SUBRESOURCE_DATA init{words.data()};
    assert(SUCCEEDED(device->CreateBuffer(&bd,&init,&hair_buffers[index])));
    D3D11_SHADER_RESOURCE_VIEW_DESC vd{};vd.ViewDimension=D3D11_SRV_DIMENSION_BUFFEREX;
    vd.Format=index<3?DXGI_FORMAT_R32G32B32A32_FLOAT:DXGI_FORMAT_R32_TYPELESS;vd.BufferEx.NumElements=size/(index<3?16:4);vd.BufferEx.Flags=index<3?0:D3D11_BUFFEREX_SRV_FLAG_RAW;
    assert(SUCCEEDED(device->CreateShaderResourceView(hair_buffers[index].Get(),&vd,&hair_views[index])));
    ctx->PSSetShaderResources(index<3?3+index:20+index-3,1,hair_views[index].GetAddressOf());
  }
  ctx->PSSetShaderResources(0,1,albedo.GetAddressOf());ctx->PSSetShaderResources(1,1,spec.GetAddressOf());ctx->PSSetShaderResources(2,1,normal.GetAddressOf());
  ctx->PSSetShaderResources(22,1,probe.GetAddressOf());ctx->PSSetShaderResources(23,1,probe.GetAddressOf());ctx->PSSetShaderResources(24,1,mask.GetAddressOf());
  params={};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  auto hair_native=ps(scratch+"originals/0x4E4E4B53.ps_5_0.cso"),hair_custom=ps("build/thewitcher3classic.include/embed/0x4E4E4B53.cso");compare(hair_native,hair_custom,"HairWorks all lighting");
  params[0][2]=1.f;ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  hair_custom=ps("build/thewitcher3classic.include/embed/0x4E4E4B53.cso");
  for(float v:hair_custom)assert(std::isfinite(v));
  std::cout<<"HairWorks follows Custom Soft Shadows with finite output"<<std::endl;

  const char* forward[]={"0x12B76681","0x20C1C070","0x30F033B5","0x9B839F3B","0xB18EC2FB","0xEB8C3FAE"};
  for(UINT i=0;i<6;++i) {
    auto a=Read(std::string("tmp/witcher3classic-investigation/temporal-dev/devkit-live/dlss-audit/")+forward[i]+".cso");
    auto b=Read("build/thewitcher3classic.include/embed/0xF3C4001"+std::to_string(i)+".cso");
    ComPtr<ID3D11ShaderReflection> ar,br;assert(SUCCEEDED(D3DReflect(a.data(),a.size(),IID_PPV_ARGS(&ar))));assert(SUCCEEDED(D3DReflect(b.data(),b.size(),IID_PPV_ARGS(&br))));
    D3D11_SHADER_DESC ad,bd;ar->GetDesc(&ad);br->GetDesc(&bd);assert(ad.InputParameters==bd.InputParameters&&ad.OutputParameters==bd.OutputParameters);
    for(UINT j=0;j<ad.InputParameters;++j){D3D11_SIGNATURE_PARAMETER_DESC av,bv;ar->GetInputParameterDesc(j,&av);br->GetInputParameterDesc(j,&bv);if(strcmp(av.SemanticName,bv.SemanticName)||av.SemanticIndex!=bv.SemanticIndex||av.Register!=bv.Register||av.Mask!=bv.Mask||av.ComponentType!=bv.ComponentType)std::cout<<forward[i]<<" input "<<j<<" "<<av.SemanticName<<av.SemanticIndex<<" reg="<<av.Register<<" mask="<<UINT(av.Mask)<<" vs "<<bv.SemanticName<<bv.SemanticIndex<<" reg="<<bv.Register<<" mask="<<UINT(bv.Mask)<<std::endl;assert(!_stricmp(av.SemanticName,bv.SemanticName)&&av.SemanticIndex==bv.SemanticIndex&&av.Register==bv.Register&&av.Mask==bv.Mask&&av.ComponentType==bv.ComponentType);}
  }
  std::cout<<"Six color-only forward shader signatures match native VS/PS linkage"<<std::endl;

  // Transparent hair is a separate late draw from opaque hair/HairWorks.
  // Replay its original DXBC with the actual material CBs, raw tiled light
  // list and a VS matching all native varyings. Do not accept a zero image.
  const std::string fringe_scratch="tmp/witcher3classic-investigation/interior-fog-20261028/";
  std::array<ComPtr<ID3D11Buffer>,3> fringe_cb;
  std::vector<char> fringe_material;
  n=0;for(UINT slot:{1u,2u,4u}) {
    auto data=Read(fringe_scratch+"hair-transparent-cb"+std::to_string(slot)+".bin");
    if(slot==2)fringe_material=data;
    fringe_cb[n]=buffer(data.data(),UINT(data.size()),D3D11_BIND_CONSTANT_BUFFER,0);
    ctx->PSSetConstantBuffers(slot,1,fringe_cb[n++].GetAddressOf());
  }
  frame[0]={0,0,3,1};frame[24][0]=W/16;frame[71][0]=.25f;
  frame[218]={0,0,0,0};
  ctx->UpdateSubresource(frame_cb.Get(),0,nullptr,frame.data(),0,0);
  ctx->PSSetConstantBuffers(12,1,frame_cb.GetAddressOf());
  ctx->PSSetConstantBuffers(13,1,light_cb.GetAddressOf());
  const char* fringe_vs=R"(
    struct Output {float4 t[11]:TEXCOORD0;float3 tangent:TEXCOORD11;float4 position:SV_Position;};
    Output main(uint id:SV_VertexID){float2 uv=float2((id<<1)&2,id&2);Output o=(Output)0;
      o.position=float4(uv*float2(2,-2)+float2(-1,1),.5,1);
      o.t[0]=float4(1,1,1,0);o.t[1].w=uv.x;o.t[3]=float4(.1,.2,.3,uv.y);
      o.t[4]=float4(.2,.15,.1,0);o.t[6]=1;o.t[7]=float4(uv,1,0);
      o.t[8]=1;o.t[9]=float4(0,0,1,0);o.t[10]=float4((uv-.5)*2,0,1);o.tangent=float3(1,0,0);return o;})";
  code.Reset();assert(SUCCEEDED(D3DCompile(fringe_vs,strlen(fringe_vs),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&code,nullptr)));
  vs.Reset();assert(SUCCEEDED(device->CreateVertexShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&vs)));ctx->VSSetShader(vs.Get(),nullptr,0);
  auto fringe_color=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT x,UINT y,UINT,UINT){return Pixel{.25f+.5f*x/W,.3f,.4f,.4f*y/H};});
  auto fringe_normal=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[](UINT,UINT,UINT,UINT){return Pixel{.5f,.5f,1,.5f};});
  ctx->PSSetShaderResources(0,1,fringe_color.GetAddressOf());ctx->PSSetShaderResources(1,1,fringe_normal.GetAddressOf());
  std::vector<UINT> indices(1024*1024/4,256);
  for(UINT i=0;i<W*H/256;++i)indices[i*256]=0;
  ctx->UpdateSubresource(hair_buffers[3].Get(),0,nullptr,indices.data(),0,0);
  const std::string fringe_original=fringe_scratch+"0xFAB74FB3.cso",fringe_replacement="build/thewitcher3classic.include/embed/0xFAB74FB3.cso";
  for(UINT flags:{0x1800u,0x80001800u}) for(float recipient:{-1.f,1.f}) {
    memcpy(&lighting[61][3],&flags,4);ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
    memcpy(fringe_material.data()+16*16,&recipient,4);ctx->UpdateSubresource(fringe_cb[1].Get(),0,nullptr,fringe_material.data(),0,0);
    params={};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
    upload_fill({false,false,1.f});auto original=ps(fringe_original),replacement=ps(fringe_replacement);compare(original,replacement,"Transparent hair native RGBA");
    upload_fill({true,false,0.f});auto off=ps(fringe_replacement);
    upload_fill({true,false,.5f});auto half=ps(fringe_replacement);
    upload_fill({true,true,1.f});auto unified=ps(fringe_replacement);
    size_t affected=0;
    for(size_t i=0;i<original.size();++i) {
      if(i%4==3){assert(original[i]==off[i]&&off[i]==half[i]&&half[i]==unified[i]);continue;}
      if(flags==0x1800u){assert(std::abs(original[i]-off[i])<.0001f);continue;}
      if(std::abs(original[i]-off[i])>.001f)++affected;
      assert(std::abs(half[i]-(off[i]+.5f*(original[i]-off[i])))<.001f);
      float scale=recipient<0?.25f:1.f;
      assert(std::abs(unified[i]-(off[i]+scale*(original[i]-off[i])))<.001f);
    }
    if(flags==0x80001800u)assert(affected>100);
  }
  upload_fill({false,false,1.f});
  std::cout<<"PASS transparent hair: native RGBA, nonzero tagged-fill removal/scaling, character/world unification, unchanged world lights and alpha\n";
  // Camera direction and nonzero packed shadow tiles must be exercised together:
  // a numeric cast of the packed float can silently disable local shadows.
  params={};ctx->UpdateSubresource(param_buffer.Get(),0,nullptr,params.data(),0,0);
  auto local_atlas=texture(64,64,4,1,DXGI_FORMAT_R32_FLOAT,[](UINT x,UINT y,UINT layer,UINT){return Pixel{.05f+.5f*x/64+.1f*y/64+.1f*layer,0,0,0};});
  ctx->PSSetShaderResources(9,1,local_atlas.GetAddressOf());
  ctx->PSSetShaderResources(17,1,mask.GetAddressOf());
  auto broken_bytes=Read("src/games/thewitcher3classic/temporal/0xB18EC2FB.ps_5_0.hlsl");
  std::string broken_source(broken_bytes.begin(),broken_bytes.end());
  const auto decoder=broken_source.find("DecodeShadowAtlas(r25.w)");assert(decoder!=std::string::npos);
  broken_source.replace(decoder,strlen("DecodeShadowAtlas(r25.w)"),"float4(((uint)r25.w>>20)&1023u,((uint)r25.w>>10)&1023u,(uint)r25.w&1023u,(uint)r25.w>>30)");
  broken_source="#define RENO_NO_OBJECT_MOTION\n"+broken_source;
  code.Reset();ComPtr<ID3DBlob> errors;
  HRESULT broken_compile=D3DCompile(broken_source.data(),broken_source.size(),"src/games/thewitcher3classic/temporal/0xB18EC2FB.ps_5_0.hlsl",nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,"main","ps_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&code,&errors);
  if(FAILED(broken_compile)&&errors)std::cerr<<static_cast<const char*>(errors->GetBufferPointer());
  assert(SUCCEEDED(broken_compile));
  {std::ofstream output(fringe_scratch+"old-hair-atlas.cso",std::ios::binary);output.write(static_cast<const char*>(code->GetBufferPointer()),code->GetBufferSize());}
  size_t old_decoder_errors=0;
  for(UINT material=0;material<3;++material) {
    std::string material_vs=fringe_vs;
    if(material!=0)material_vs.insert(material_vs.find("return o;"),material==1
        ? "o.t[0].w=uv.x;o.t[2]=float4(.1,.2,.3,uv.y);o.t[3]=float4(.2,.15,.1,0);o.t[4]=1;o.t[5]=float4(0,0,1,0);o.t[6]=1;o.t[7]=float4(0,0,1,0);o.t[8]=float4((uv-.5)*2,0,0);o.t[9]=float4(1,0,0,0);"
        : "o.t[1]=float4(.1,.2,.3,uv.x);o.t[2]=float4(.2,.15,.1,uv.y);o.t[3]=1;o.t[4]=1;o.t[5]=float4(0,1,0,1);o.t[6]=float4(0,0,1,0);o.t[7]=float4((uv-.5)*2,0,0);");
    code.Reset();assert(SUCCEEDED(D3DCompile(material_vs.data(),material_vs.size(),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&code,nullptr)));
    vs.Reset();assert(SUCCEEDED(device->CreateVertexShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&vs)));ctx->VSSetShader(vs.Get(),nullptr,0);
    auto color=texture(W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,[&](UINT x,UINT,UINT,UINT){return Pixel{.25f+.5f*x/W,.3f,.4f,material==0?.2f:.8f};});
    ctx->PSSetShaderResources(0,1,color.GetAddressOf());
    std::string native_path=material==0?fringe_original:std::string("tmp/witcher3classic-investigation/temporal-dev/devkit-live/dlss-audit/")+(material==1?"0xB18EC2FB.cso":"0x9B839F3B.cso");
    std::string custom_path=material==0?fringe_replacement:std::string("build/thewitcher3classic.include/embed/")+(material==1?"0xF3C40014.cso":"0xF3C40013.cso");
    size_t shadow_pixels=0;
    for(float camera_x:{-3.f,0.f,3.f}) for(UINT layer:{0u,2u}) {
      frame[0][0]=camera_x;ctx->UpdateSubresource(frame_cb.Get(),0,nullptr,frame.data(),0,0);
      lighting[58]={0,0,2,4};lighting[60]={0,0,-1,1};lighting[63]={1,1,1,0};lighting[64][0]=0;
      const UINT flags=0x80001800u, packed=(128u<<20)|(96u<<10)|512u|(layer<<30);
      memcpy(&lighting[61][3],&flags,4);
      for(float& v:lighting[65])memcpy(&v,&packed,4);
      for(float& v:lighting[66])memcpy(&v,&packed,4);
      ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
      auto original=ps(native_path),replacement=ps(custom_path);
      compare(original,replacement,"Hair camera-angle / packed shadow atlas");
      if(material==1) {
        auto broken=ps(fringe_scratch+"old-hair-atlas.cso");
        for(size_t i=0;i<original.size();++i)if(std::abs(original[i]-broken[i])>.001f)++old_decoder_errors;
      }
      lighting[60][3]=0;ctx->UpdateSubresource(light_cb.Get(),0,nullptr,lighting.data(),0,0);
      auto unshadowed=ps(native_path);
      for(size_t i=0;i<original.size();++i)if(std::abs(original[i]-unshadowed[i])>.001f)++shadow_pixels;
    }
    assert(shadow_pixels>100);
  }
  assert(old_decoder_errors>100);
  std::cout<<"PASS regression detects old numeric shadow-atlas decoding: "<<old_decoder_errors<<" changed components\n";

}
