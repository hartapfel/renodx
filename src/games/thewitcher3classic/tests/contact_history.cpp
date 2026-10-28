/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// GPU checks for temporal stability, reprojection, disocclusion and reset rules.
#include <d3d11.h>
#include <wrl/client.h>
#include <array>
#include <vector>
#include <cassert>
#include <cmath>
#include <cstring>
#include <iostream>
#include <embed/0xF3C40022.h>
#include <embed/0xF3C40023.h>
using Microsoft::WRL::ComPtr;
using Pixel=std::array<float,4>;
using Pair=std::array<float,2>;
int main(int argc,char**) {
  constexpr UINT W=32,H=32;
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&context)));
  auto buffer=[&](const void* data,UINT bytes,bool structured=false) {
    D3D11_BUFFER_DESC d{bytes,D3D11_USAGE_DEFAULT,UINT(structured?D3D11_BIND_SHADER_RESOURCE:D3D11_BIND_CONSTANT_BUFFER),0,structured?D3D11_RESOURCE_MISC_BUFFER_STRUCTURED:0u,structured?16u:0u};
    D3D11_SUBRESOURCE_DATA initial{data};ComPtr<ID3D11Buffer> b;
    assert(SUCCEEDED(device->CreateBuffer(&d,&initial,&b)));return b;
  };
  auto texture=[&](DXGI_FORMAT format,const void* data,UINT stride) {
    D3D11_TEXTURE2D_DESC d{W,H,1,1,format,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    D3D11_SUBRESOURCE_DATA initial{data,W*stride};ComPtr<ID3D11Texture2D> t;ComPtr<ID3D11ShaderResourceView> v;
    assert(SUCCEEDED(device->CreateTexture2D(&d,&initial,&t)));
    assert(SUCCEEDED(device->CreateShaderResourceView(t.Get(),nullptr,&v)));return v;
  };
  auto update=[&](ID3D11ShaderResourceView* view,const void* data,UINT stride) {
    ComPtr<ID3D11Resource> r;view->GetResource(&r);context->UpdateSubresource(r.Get(),0,nullptr,data,W*stride,0);
  };
  std::array<Pixel,214> frame{};std::array<Pixel,49> light{};std::array<Pixel,218> previous{};
  frame[1]={1,0,0,0};frame[2]={0,1,0,0};frame[3]={0,0,1,0};
  frame[13]={1,0,0,0};frame[14]={0,1,0,0};frame[15]={0,0,0,1};frame[16]={0,0,1,0};
  frame[21]={1,0,0,0};frame[22]={1,0,0,0};frame[23]={W,H,1.f/W,1.f/H};
  frame[210]={2.f/W,0,0,0};frame[211]={0,-2.f/H,0,0};frame[212]={0,0,0,1};frame[213]={-1.f+1.f/W,1.f-1.f/H,1,0};
  std::copy(frame.begin(),frame.end(),previous.begin());
  light[0]={.8f,0,-.6f,0};previous[214]=light[0];
  std::array<Pixel,3> parameters{Pixel{0,0,0,.3f},Pixel{},Pixel{0,0,W,H}};
  std::copy(parameters.begin(),parameters.end(),previous.begin()+215);
  Pixel control{1,0,0,0};
  auto f=buffer(frame.data(),sizeof(frame)),l=buffer(light.data(),sizeof(light)),c=buffer(control.data(),sizeof(control));
  auto p=buffer(parameters.data(),sizeof(parameters),true),prev=buffer(previous.data(),sizeof(previous),true);
  ComPtr<ID3D11ShaderResourceView> pv,prevv;
  assert(SUCCEEDED(device->CreateShaderResourceView(p.Get(),nullptr,&pv)));
  assert(SUCCEEDED(device->CreateShaderResourceView(prev.Get(),nullptr,&prevv)));
  context->CSSetConstantBuffers(11,1,c.GetAddressOf());context->CSSetConstantBuffers(12,1,f.GetAddressOf());context->CSSetConstantBuffers(13,1,l.GetAddressOf());
  context->CSSetShaderResources(6,1,prevv.GetAddressOf());context->CSSetShaderResources(118,1,pv.GetAddressOf());
  std::vector<float> depth(W*H,.5f),motion_depth(W*H,.5f);
  std::vector<Pixel> material(W*H),stencil(W*H);
  std::vector<Pair> raw(W*H),history(W*H,Pair{.5f,2}),motion(W*H);
  auto dv=texture(DXGI_FORMAT_R32_FLOAT,depth.data(),4),mv=texture(DXGI_FORMAT_R32G32B32A32_FLOAT,material.data(),16);
  auto sv=texture(DXGI_FORMAT_R32G32B32A32_UINT,stencil.data(),16);
  auto rawv=texture(DXGI_FORMAT_R32G32_FLOAT,raw.data(),8),hv=texture(DXGI_FORMAT_R32G32_FLOAT,history.data(),8);
  auto motionv=texture(DXGI_FORMAT_R32G32_FLOAT,motion.data(),8),motiondv=texture(DXGI_FORMAT_R32_FLOAT,motion_depth.data(),4);
  context->CSSetShaderResources(0,1,dv.GetAddressOf());context->CSSetShaderResources(2,1,mv.GetAddressOf());context->CSSetShaderResources(3,1,sv.GetAddressOf());
  context->CSSetShaderResources(4,1,rawv.GetAddressOf());context->CSSetShaderResources(5,1,hv.GetAddressOf());context->CSSetShaderResources(7,1,motionv.GetAddressOf());context->CSSetShaderResources(8,1,motiondv.GetAddressOf());
  D3D11_TEXTURE2D_DESC d{W,H,1,1,DXGI_FORMAT_R32G32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_UNORDERED_ACCESS};
  ComPtr<ID3D11Texture2D> output,staging;ComPtr<ID3D11UnorderedAccessView> uav;ComPtr<ID3D11ComputeShader> shader;
  assert(SUCCEEDED(device->CreateTexture2D(&d,nullptr,&output)));assert(SUCCEEDED(device->CreateUnorderedAccessView(output.Get(),nullptr,&uav)));
  d.BindFlags=0;d.Usage=D3D11_USAGE_STAGING;d.CPUAccessFlags=D3D11_CPU_ACCESS_READ;assert(SUCCEEDED(device->CreateTexture2D(&d,nullptr,&staging)));
  assert(SUCCEEDED(device->CreateComputeShader(__0xF3C40022.data(),__0xF3C40022.size(),nullptr,&shader)));
  context->CSSetShader(shader.Get(),nullptr,0);context->CSSetUnorderedAccessViews(0,1,uav.GetAddressOf(),nullptr);
  auto run=[&]() {
    update(rawv.Get(),raw.data(),8);update(hv.Get(),history.data(),8);
    context->UpdateSubresource(prev.Get(),0,nullptr,previous.data(),0,0);
    context->UpdateSubresource(c.Get(),0,nullptr,control.data(),0,0);
    context->Dispatch(W/8,H/8,1);context->CopyResource(staging.Get(),output.Get());
    D3D11_MAPPED_SUBRESOURCE map;assert(SUCCEEDED(context->Map(staging.Get(),0,D3D11_MAP_READ,0,&map)));
    std::vector<Pair> result(W*H);
    for(UINT y=0;y<H;++y)memcpy(result.data()+y*W,(const char*)map.pData+y*map.RowPitch,W*8);
    context->Unmap(staging.Get(),0);
    for(UINT i=0;i<W*H;++i)assert(std::isfinite(result[i][0])&&result[i][0]>=0&&result[i][0]<=1&&result[i][1]==raw[i][1]);
    return result;
  };
  // Spatial observations must be bounded, preserve center depth and avoid
  // crossing depth/normal silhouettes before they enter temporal history.
  ComPtr<ID3D11ComputeShader> spatial;
  assert(SUCCEEDED(device->CreateComputeShader(__0xF3C40023.data(),__0xF3C40023.size(),nullptr,&spatial)));
  std::vector<Pixel> normals(W*H,Pixel{.5f,.5f,0,0});
  auto nv=texture(DXGI_FORMAT_R32G32B32A32_FLOAT,normals.data(),16);
  context->CSSetShaderResources(1,1,nv.GetAddressOf());context->CSSetShader(spatial.Get(),nullptr,0);
  std::fill(raw.begin(),raw.end(),Pair{1,2});raw[16*W+16][0]=0;
  auto filtered=run();
  assert(filtered[16*W+16][0]==.75f&&filtered[16*W+17][0]==.875f&&filtered[17*W+17][0]==.9375f);
  assert(filtered[16*W+18][0]==1.f);
  // One noisy dark tap after a broad blocker disappears must not preserve the
  // old dark shadow. Clipping against filtered observations gives .75 here;
  // clipping raw taps first and then blurring would leave only .15 visibility.
  raw=filtered;std::fill(history.begin(),history.end(),Pair{0,2});
  context->CSSetShader(shader.Get(),nullptr,0);assert(std::abs(run()[16*W+16][0]-.75f)<1.e-6f);
  context->CSSetShader(spatial.Get(),nullptr,0);
  std::cout<<"PASS filtered history clamp rejects stale darkness from isolated noisy taps\n";
  std::fill(raw.begin(),raw.end(),Pair{1,2});raw[0][0]=0;filtered=run();
  assert(std::abs(filtered[0][0]-5.f/9.f)<1.e-6f&&std::abs(filtered[1][0]-5.f/6.f)<1.e-6f);
  for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x)raw[y*W+x]={x<W/2?0.f:1.f,x<W/2?2.f:10.f};
  assert(run()==raw);
  for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x){raw[y*W+x][1]=2;normals[y*W+x][2]=x<W/2?0.f:1.f;}
  update(nv.Get(),normals.data(),16);assert(run()==raw);
  std::cout<<"PASS spatial footprint, image edges, depth and opposing-normal boundaries\n";
  context->CSSetShader(shader.Get(),nullptr,0);
  std::fill(history.begin(),history.end(),Pair{.5f,2});
  // Alternating spatial sample noise must converge rather than flicker 0/1.
  for(UINT step=0;step<24;++step) {
    for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x)raw[y*W+x]={float((x+y+step)&1),2};
    auto result=run();
    if(step>12)for(UINT y=2;y<H-2;++y)for(UINT x=2;x<W-2;++x)assert(std::abs(result[y*W+x][0]-.5f)<.07f);
    history=result;
  }
  std::cout<<"PASS temporal sample-noise attenuation\n";
  // History must clear immediately when the current neighborhood loses a shadow.
  std::fill(raw.begin(),raw.end(),Pair{1,2});std::fill(history.begin(),history.end(),Pair{0,2});
  for(auto v:run())assert(v[0]==1);
  for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x)raw[y*W+x]={float((x+y)&1),2};
  auto require_current=[&](){auto result=run();for(UINT i=0;i<W*H;++i)assert(result[i]==raw[i]);};
  control[0]=0;require_current();control[0]=1;
  std::fill(history.begin(),history.end(),Pair{0,20});require_current();
  std::fill(history.begin(),history.end(),Pair{.5f,2});
  previous[0][0]=4;require_current();previous[0][0]=0;
  previous[215][3]=.6f;require_current();previous[215][3]=.3f;
  previous[214][0]=-.8f;require_current();previous[214]=light[0];
  previous[13][0]=2;require_current();previous[13][0]=1;
  std::cout<<"PASS disocclusion, blocker removal, camera/light/settings/projection reset\n";
  // Missing or invalid object history must not smear an animated character.
  for(auto& v:stencil){UINT bits=2;memcpy(&v[1],&bits,4);}update(sv.Get(),stencil.data(),16);
  std::fill(motion_depth.begin(),motion_depth.end(),-.5f);update(motiondv.Get(),motion_depth.data(),4);require_current();
  std::fill(motion_depth.begin(),motion_depth.end(),.7f);update(motiondv.Get(),motion_depth.data(),4);require_current();
  std::fill(motion_depth.begin(),motion_depth.end(),.5f);update(motiondv.Get(),motion_depth.data(),4);
  // Previous raster jitter adds one pixel; an object vector adds two more.
  // Camera-only reprojection would fetch x instead of the expected x+3.
  previous[15][0]=2.f/W;
  for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x){history[y*W+x]={float(x)/(W-1),2};motion[y*W+x]={2.f/W,0};}
  update(motionv.Get(),motion.data(),8);
  auto result=run();
  for(UINT y=2;y<H-2;++y)for(UINT x=2;x<W-4;++x)assert(std::abs(result[y*W+x][0]-(.2f*raw[y*W+x][0]+.8f*float(x+3)/(W-1)))<.0001f);
  for(UINT y=0;y<H;++y)for(UINT x=W-3;x<W;++x)assert(result[y*W+x]==raw[y*W+x]);
  std::cout<<"PASS object motion, jitter correction and offscreen rejection\n";
}
