/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11.h>
#include <wrl/client.h>
#include <embed/0xF3C70002.h>
#include <array>
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
  constexpr UINT W=64,H=48;
  struct Texture {
    ComPtr<ID3D11Texture2D> texture;ComPtr<ID3D11ShaderResourceView> view;ComPtr<ID3D11UnorderedAccessView> output;
  };
  auto create=[&](DXGI_FORMAT format) {
    Texture t;D3D11_TEXTURE2D_DESC d{W,H,1,1,format,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_UNORDERED_ACCESS};
    assert(SUCCEEDED(device->CreateTexture2D(&d,nullptr,&t.texture)));
    assert(SUCCEEDED(device->CreateShaderResourceView(t.texture.Get(),nullptr,&t.view)));
    assert(SUCCEEDED(device->CreateUnorderedAccessView(t.texture.Get(),nullptr,&t.output)));return t;
  };
  auto color=create(DXGI_FORMAT_R32G32B32A32_FLOAT),guide=create(DXGI_FORMAT_R32G32_FLOAT),padding=create(DXGI_FORMAT_R32G32B32A32_FLOAT);
  std::array<Texture,2> histories{create(DXGI_FORMAT_R32G32B32A32_FLOAT),create(DXGI_FORMAT_R32G32B32A32_FLOAT)};
  auto old_guide=create(DXGI_FORMAT_R32G32_FLOAT);
  std::vector<std::array<float,4>> pixels(W*H),pad(W*H,{2048,512,32,1});
  std::vector<std::array<float,2>> guides(W*H,{10,1});
  context->UpdateSubresource(padding.texture.Get(),0,nullptr,pad.data(),W*16,0);
  std::array<std::array<float,4>,269> frame{};
  frame[1]={1,0,0,0};frame[2]={0,1,0,0};frame[3]={0,0,1,0};frame[4]={0,0,0,1};
  frame[13]={1,0,0,0};frame[14]={0,1,0,0};frame[15]={0,0,0,1};
  frame[206]={1,0,0,0};frame[207]={0,1,0,0};frame[208]={0,0,0,1};frame[209]={0,0,1,0};
  std::array<ComPtr<ID3D11Buffer>,2> frames;std::array<ComPtr<ID3D11ShaderResourceView>,2> frame_views;
  D3D11_BUFFER_DESC b{sizeof(frame),D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
  D3D11_SUBRESOURCE_DATA initial{frame.data()};
  for(UINT i=0;i<2;++i) {assert(SUCCEEDED(device->CreateBuffer(&b,&initial,&frames[i])));assert(SUCCEEDED(device->CreateShaderResourceView(frames[i].Get(),nullptr,&frame_views[i])));}
  ComPtr<ID3D11Buffer> controls;std::array<float,12> values{W,H,W,H,0,1,1,1};
  b={sizeof(values),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};initial={values.data()};assert(SUCCEEDED(device->CreateBuffer(&b,&initial,&controls)));
  context->CSSetConstantBuffers(0,1,controls.GetAddressOf());
  ComPtr<ID3D11ComputeShader> filter;assert(SUCCEEDED(device->CreateComputeShader(__0xF3C70002.data(),__0xF3C70002.size(),nullptr,&filter)));
  context->CSSetShader(filter.Get(),nullptr,0);
  D3D11_SAMPLER_DESC s{};s.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;s.AddressU=s.AddressV=s.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;
  ComPtr<ID3D11SamplerState> sampler;assert(SUCCEEDED(device->CreateSamplerState(&s,&sampler)));context->CSSetSamplers(0,1,sampler.GetAddressOf());
  D3D11_TEXTURE2D_DESC d{W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_STAGING,0,D3D11_CPU_ACCESS_READ};
  ComPtr<ID3D11Texture2D> staging;assert(SUCCEEDED(device->CreateTexture2D(&d,nullptr,&staging)));
  UINT ping=0;
  auto run=[&] {
    context->UpdateSubresource(color.texture.Get(),0,nullptr,pixels.data(),W*16,0);
    context->UpdateSubresource(guide.texture.Get(),0,nullptr,guides.data(),W*8,0);
    context->UpdateSubresource(controls.Get(),0,nullptr,values.data(),0,0);
    ID3D11ShaderResourceView* views[]={color.view.Get(),guide.view.Get(),histories[ping].view.Get(),old_guide.view.Get(),frame_views[0].Get(),frame_views[1].Get(),padding.view.Get()};
    context->CSSetShaderResources(0,7,views);context->CSSetUnorderedAccessViews(0,1,histories[ping^1].output.GetAddressOf(),nullptr);
    context->Dispatch((W+7)/8,(H+7)/8,1);
    ID3D11UnorderedAccessView* clear=nullptr;context->CSSetUnorderedAccessViews(0,1,&clear,nullptr);
    ID3D11ShaderResourceView* clear_views[7]{};context->CSSetShaderResources(0,7,clear_views);
    context->CopyResource(old_guide.texture.Get(),guide.texture.Get());ping^=1;
    context->CopyResource(staging.Get(),histories[ping].texture.Get());D3D11_MAPPED_SUBRESOURCE m{};
    assert(SUCCEEDED(context->Map(staging.Get(),0,D3D11_MAP_READ,0,&m)));
    std::vector<std::array<float,4>> result(W*H);
    for(UINT y=0;y<H;++y)memcpy(result.data()+y*W,static_cast<const char*>(m.pData)+y*m.RowPitch,W*16);
    context->Unmap(staging.Get(),0);return result;
  };
  double raw_error=0,filtered_error=0;
  for(UINT f=0;f<40;++f) {
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
      float n=(x+y+f)%2?.2f:-.2f;pixels[y*W+x]={64*(1+n),32*(1+n),16*(1+n),1};
    }
    values[4]=f?1.f:0.f;auto result=run();
    if(f>20)for(UINT y=3;y<H-3;++y)for(UINT x=3;x<W-3;++x) {
      float a=pixels[y*W+x][0]/64-1,b=result[y*W+x][0]/64-1;raw_error+=a*a;filtered_error+=b*b;
      assert(std::isfinite(b) &&result[y*W+x][3]==1);
    }
  }
  std::cout<<"Steady HDR alternating-noise residual energy="<<filtered_error/raw_error<<'\n';assert(filtered_error<raw_error*.1);
  // A newly revealed reflected surface must immediately replace old history.
  for(auto& g:guides)g={20,1};for(auto& p:pixels)p={512,128,32,1};
  for(auto p:run())assert(p[0]==512 &&p[1]==128);
  // Same depth, sudden changed lighting: variance clipping must not smear it.
  for(auto& p:pixels)p={1024,256,64,1};for(auto p:run())assert(p[0]==1024);
  // Camera cut and disabled stabilization both reject stale reflected detail.
  frame[0][0]=10;context->UpdateSubresource(frames[0].Get(),0,nullptr,frame.data(),0,0);
  for(auto& p:pixels)p={64,16,4,1};for(auto p:run())assert(p[0]==64);
  values[5]=0;for(auto& p:pixels)p={128,32,8,1};for(auto p:run())assert(p[0]==128);
  for(auto& g:guides)g={0,0};for(auto p:run())assert(p[0]==2048 &&p[3]==1);
  // Camera motion must track the reflected hit, not the water receiver.
  frame[0][0]=0;frame[208]={0,0,0,1};frame[4]={0,0,0,1};
  for(auto& buffer:frames)context->UpdateSubresource(buffer.Get(),0,nullptr,frame.data(),0,0);
  for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x) {
    const float nx=2*(x+.5f)/W-1,ny=1-2*(y+.5f)/H;
    guides[y*W+x]={10*std::sqrt(nx*nx+ny*ny+1),1};
    pixels[y*W+x]={x<W/2?64.f:256.f,16,4,1};
  }
  values[4]=0;values[5]=1;run();
  const float translation=20.f/W;
  frame[0][0]=translation;frame[4][0]=-translation;frame[208][0]=translation;
  context->UpdateSubresource(frames[0].Get(),0,nullptr,frame.data(),0,0);
  for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x)pixels[y*W+x][0]=x+1<W/2?64.f:256.f;
  values[4]=1;auto moved=run();
  for(UINT y=3;y<H-3;++y)for(UINT x=3;x<W-3;++x)assert(std::abs(moved[y*W+x][0]-pixels[y*W+x][0])<.01f);
  std::cout<<"PASS reflection disocclusion, rapid HDR lighting change, camera cut, filter Off, native shoreline padding\n";
  std::cout<<"PASS moving reflected edge follows virtual-hit reprojection without a trailing old edge\n";
}
