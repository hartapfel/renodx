/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <array>
#include <algorithm>
#include <cassert>
#include <cmath>
#include <cstdio>
#include <vector>
#include <embed/shaders.h>
#include "../../../utils/float16.hpp"
#include "../water/camera.hpp"
using Microsoft::WRL::ComPtr;
int main(int argc,char**) {
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> base;ComPtr<ID3D11DeviceContext1> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&base)));
  assert(SUCCEEDED(base.As(&context)));
  witcher3classic::water::Camera camera;
  std::array<float,32> state{};
  ComPtr<ID3D11Buffer> buffer;ComPtr<ID3D11ShaderResourceView> state_view;
  const D3D11_BUFFER_DESC bd{128,D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
  assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&buffer)));
  assert(SUCCEEDED(device->CreateShaderResourceView(buffer.Get(),nullptr,&state_view)));
  uint64_t frame=0;
  const UINT w=128,h=1080,aw=w+17,ah=h+11;
  for(int pattern:{0,1,3,4,5,6}) for(float immersion:{0.f,.5f,1.f}) {
    std::array<float,2> effects{.15f,1.f};
    if(pattern==0)effects={0,0};
    if(pattern==1)effects={.5f,0};
    if(pattern==3)effects={0,1};
    std::vector<float> pixels(aw*ah*4,60000.f);
    for(UINT y=0;y<h;++y)for(UINT x=0;x<w;++x) {
      const UINT i=(y*aw+x)*4;
      if(pattern==1) {
        pixels[i]=pixels[i+1]=pixels[i+2]=float(((x/2)+(y/2))%2);
      } else if(pattern==0||pattern==3||pattern==4) {
        pixels[i]=pixels[i+2]=float(x+.5f)/w*4;pixels[i+1]=float(y+.5f)/h*4;
      } else {
        pixels[i]=pattern==5?0:pattern==6?16:4;
        pixels[i+1]=pattern==5?0:pattern==6?8:2;
        pixels[i+2]=pattern==5?0:pattern==6?4:1;
      }
      pixels[i+3]=.75f;
    }
    state[12]=.01f;state[13]=.02f;state[14]=.015f;state[23]=immersion;
    context->UpdateSubresource(buffer.Get(),0,nullptr,state.data(),0,0);
    const D3D11_TEXTURE2D_DESC td{aw,ah,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    const D3D11_SUBRESOURCE_DATA initial{pixels.data(),aw*16,0};
    ComPtr<ID3D11Texture2D> source;ComPtr<ID3D11ShaderResourceView> source_view;
    assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&source)));
    assert(SUCCEEDED(device->CreateShaderResourceView(source.Get(),nullptr,&source_view)));
    auto* binding=source_view.Get();context->PSSetShaderResources(0,1,&binding);
    const D3D11_VIEWPORT viewport{3,5,61,39,.2f,.9f};context->RSSetViewports(1,&viewport);
    auto* result=camera.Run(context.Get(),source_view.Get(),state_view.Get(),w,h,++frame,__swap_chain_proxy_vertex_shader,effects);
    assert(result && !camera.Run(context.Get(),source_view.Get(),state_view.Get(),w,h,frame,__swap_chain_proxy_vertex_shader,effects));
    ComPtr<ID3D11ShaderResourceView> restored;context->PSGetShaderResources(0,1,&restored);assert(restored.Get()==source_view.Get());
    D3D11_VIEWPORT after{};UINT count=1;context->RSGetViewports(&count,&after);assert(!memcmp(&viewport,&after,sizeof(viewport)));
    ComPtr<ID3D11Resource> output;result->GetResource(&output);
    auto rd=td;rd.Format=DXGI_FORMAT_R16G16B16A16_FLOAT;rd.Usage=D3D11_USAGE_STAGING;rd.BindFlags=0;rd.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
    ComPtr<ID3D11Texture2D> read;assert(SUCCEEDED(device->CreateTexture2D(&rd,nullptr,&read)));
    context->CopyResource(read.Get(),output.Get());D3D11_MAPPED_SUBRESOURCE mapped{};
    assert(SUCCEEDED(context->Map(read.Get(),0,D3D11_MAP_READ,0,&mapped)));
    double centre_contrast=0,edge_contrast=0;
    for(UINT y=0;y<h;++y)for(UINT x=0;x<w;++x) {
      const auto* row=reinterpret_cast<const uint16_t*>(static_cast<const char*>(mapped.pData)+mapped.RowPitch*y)+x*4;
      float rgb[4];for(int c=0;c<4;++c) {rgb[c]=renodx::utils::float16::Decode(row[c]);assert(std::isfinite(rgb[c])&&rgb[c]>=0&&rgb[c]<32);}
      assert(rgb[3]==.75f);const auto* input=&pixels[(y*aw+x)*4];
      if(pattern==0||immersion==0)for(int c=0;c<3;++c)assert(std::abs(rgb[c]-input[c])<.005f);
      if(pattern==5)assert(rgb[0]==0&&rgb[1]==0&&rgb[2]==0);
      if(pattern==6)for(int c=0;c<3;++c)assert(std::abs(rgb[c]-input[c])<.025f); // HDR color unchanged.
      if(pattern==3) {
        assert(std::abs(rgb[1]-input[1])<.003); // Green geometry unchanged, even at max CA.
        const double r=std::clamp(x+.5+1.5*immersion,.5,double(w)-.5)/w*4;
        const double b=std::clamp(x+.5-1.5*immersion,.5,double(w)-.5)/w*4;
        assert(std::abs(rgb[0]-r)<.005 &&std::abs(rgb[2]-b)<.005);
      }
      if(pattern==1&&y>20&&y<h-20) {
        if(x>48&&x<80)centre_contrast=std::max(centre_contrast,std::abs(rgb[1]-.5));
        if(x>12&&x<32)edge_contrast=std::max(edge_contrast,std::abs(rgb[1]-.5));
      }
    }
    context->Unmap(read.Get(),0);
    if(pattern==1&&immersion==1) {
      assert(centre_contrast<.1 &&edge_contrast<.1);
      std::printf("Blur 0.50 checker contrast: centre %.4f, edge %.4f (input 0.5)\n",centre_contrast,edge_contrast);
    }
  }
  if(argc>2) {
    const UINT width=3840,height=2160;
    const D3D11_TEXTURE2D_DESC td{width,height,1,1,DXGI_FORMAT_R16G16B16A16_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    ComPtr<ID3D11Texture2D> source;ComPtr<ID3D11ShaderResourceView> view;
    assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&source)));
    assert(SUCCEEDED(device->CreateShaderResourceView(source.Get(),nullptr,&view)));
    state[12]=.01f;state[13]=.02f;state[14]=.015f;state[23]=1;context->UpdateSubresource(buffer.Get(),0,nullptr,state.data(),0,0);
    ComPtr<ID3D11Query> disjoint,start,end;
    D3D11_QUERY_DESC q{D3D11_QUERY_TIMESTAMP_DISJOINT};assert(SUCCEEDED(device->CreateQuery(&q,&disjoint)));
    q.Query=D3D11_QUERY_TIMESTAMP;assert(SUCCEEDED(device->CreateQuery(&q,&start)));assert(SUCCEEDED(device->CreateQuery(&q,&end)));
    for(int i=0;i<8;++i)assert(camera.Run(context.Get(),view.Get(),state_view.Get(),width,height,++frame,__swap_chain_proxy_vertex_shader,{.15f,1.f}));
    context->Begin(disjoint.Get());context->End(start.Get());
    for(int i=0;i<32;++i)assert(camera.Run(context.Get(),view.Get(),state_view.Get(),width,height,++frame,__swap_chain_proxy_vertex_shader,{.15f,1.f}));
    context->End(end.Get());context->End(disjoint.Get());context->Flush();
    D3D11_QUERY_DATA_TIMESTAMP_DISJOINT frequency{};UINT64 a=0,b=0;
    while(context->GetData(disjoint.Get(),&frequency,sizeof(frequency),0)==S_FALSE)Sleep(1);
    while(context->GetData(start.Get(),&a,sizeof(a),0)==S_FALSE)Sleep(1);
    while(context->GetData(end.Get(),&b,sizeof(b),0)==S_FALSE)Sleep(1);
    assert(!frequency.Disjoint);std::printf("4K underwater postprocess: %.4f ms\n",1000.*(b-a)/frequency.Frequency/32.);
  }
  std::puts("PASS: full-screen blur/CA, unchanged HDR color, dry/zero bypass, pooled borders, no green warp, state restoration, successive frames without history.");
}
