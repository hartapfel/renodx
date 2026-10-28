/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3dcompiler.h>
#include <cassert>
#include <cmath>
#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>
#include <embed/0x406B9233.h>
#include "../water/reflections.hpp"
using Microsoft::WRL::ComPtr;
int main(int argc,char**) {
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> base;ComPtr<ID3D11DeviceContext1> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&base)));
  assert(SUCCEEDED(base.As(&context)));
  constexpr UINT W=64,H=64,Q=16,Pool=96;
  ComPtr<ID3DBlob> vs_code,errors;
  const char* text="float4 main(uint id:SV_VertexID):SV_Position{float2 uv=float2((id<<1)&2,id&2);return float4(uv*float2(2,-2)+float2(-1,1),.5,1);}";
  assert(SUCCEEDED(D3DCompile(text,strlen(text),nullptr,nullptr,nullptr,"main","vs_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&vs_code,&errors)));
  ComPtr<ID3D11VertexShader> vs;ComPtr<ID3D11PixelShader> ps,original;
  assert(SUCCEEDED(device->CreateVertexShader(vs_code->GetBufferPointer(),vs_code->GetBufferSize(),nullptr,&vs)));
  assert(SUCCEEDED(device->CreatePixelShader(__0x406B9233.data(),__0x406B9233.size(),nullptr,&ps)));
  std::ifstream f("tmp/witcher3classic-investigation/volumetrics-20261027/particle-originals/0x406B9233.ps_5_0.cso",std::ios::binary);
  assert(f);std::vector<char> native_bytes{std::istreambuf_iterator<char>(f),{}};
  assert(SUCCEEDED(device->CreatePixelShader(native_bytes.data(),native_bytes.size(),nullptr,&original)));
  context->VSSetShader(vs.Get(),nullptr,0);context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  D3D11_RASTERIZER_DESC rd=CD3D11_RASTERIZER_DESC(D3D11_DEFAULT);rd.CullMode=D3D11_CULL_NONE;
  ComPtr<ID3D11RasterizerState> rs;assert(SUCCEEDED(device->CreateRasterizerState(&rd,&rs)));context->RSSetState(rs.Get());
  D3D11_VIEWPORT vp{0,0,float(Q),float(Q),0,1};context->RSSetViewports(1,&vp);
  D3D11_TEXTURE2D_DESC td{Q,Q,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_RENDER_TARGET};
  ComPtr<ID3D11Texture2D> target,readback;ComPtr<ID3D11RenderTargetView> rtv;
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&target)));assert(SUCCEEDED(device->CreateRenderTargetView(target.Get(),nullptr,&rtv)));
  context->OMSetRenderTargets(1,rtv.GetAddressOf(),nullptr);
  td.Usage=D3D11_USAGE_STAGING;td.BindFlags=0;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&readback)));
  auto read=[&] {
    context->CopyResource(readback.Get(),target.Get());D3D11_MAPPED_SUBRESOURCE m;
    assert(SUCCEEDED(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&m)));
    std::vector<float> values(Q*Q*4);
    for(UINT y=0;y<Q;++y)memcpy(values.data()+y*Q*4,static_cast<const char*>(m.pData)+y*m.RowPitch,Q*16);
    context->Unmap(readback.Get(),0);return values;
  };
  std::array<std::array<float,4>,269> frame{};
  frame[1]={1,0,0,0};frame[2]={0,1,0,0};frame[3]={0,0,1,0};frame[4]={0,0,0,1};
  frame[13]={1,0,0,0};frame[14]={0,1,0,0};frame[15]={0,0,0,1};
  frame[21]={1,0,0,0};frame[22]={1,0,0,0};
  frame[206]={1,0,0,0};frame[207]={0,1,0,0};frame[208]={0,0,0,1};frame[209]={0,0,1,0};
  D3D11_BUFFER_DESC bd{sizeof(frame),D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};
  D3D11_SUBRESOURCE_DATA initial{frame.data()};ComPtr<ID3D11Buffer> frame_buffer,dimensions;ComPtr<ID3D11ShaderResourceView> frame_view;
  assert(SUCCEEDED(device->CreateBuffer(&bd,&initial,&frame_buffer)));
  assert(SUCCEEDED(device->CreateShaderResourceView(frame_buffer.Get(),nullptr,&frame_view)));
  std::array<float,8> size{float(Q),float(Q),float(Q),float(Q),.25f,.25f,4,4};
  bd={sizeof(size),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};initial={size.data()};
  assert(SUCCEEDED(device->CreateBuffer(&bd,&initial,&dimensions)));context->PSSetConstantBuffers(3,1,dimensions.GetAddressOf());
  std::vector<std::array<float,4>> native_pixels(Pool*Pool,{1000,1000,1000,1});
  for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x)native_pixels[y*Pool+x]={1,.5f,.25f,.75f};
  td={Pool,Pool,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  initial={native_pixels.data(),Pool*16};ComPtr<ID3D11Texture2D> native_color;ComPtr<ID3D11ShaderResourceView> native_view;
  assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&native_color)));
  assert(SUCCEEDED(device->CreateShaderResourceView(native_color.Get(),nullptr,&native_view)));context->PSSetShaderResources(0,1,native_view.GetAddressOf());
  context->PSSetShader(original.Get(),nullptr,0);context->Draw(3,0);const auto baseline=read();
  auto expect=[&](const std::array<float,4>& value) {
    auto pixels=read();
    for(UINT y=2;y<Q-2;++y)for(UINT x=2;x<Q-2;++x)for(UINT c=0;c<4;++c)
      assert(std::abs(pixels[(y*Q+x)*4+c]-value[c])<.0005f);
  };
  for(const auto format:{DXGI_FORMAT_R32G32B32A32_FLOAT,DXGI_FORMAT_R16G16B16A16_FLOAT,DXGI_FORMAT_R11G11B10_FLOAT}) {
    witcher3classic::water::Reflections reflections;
    ComPtr<ID3D11Texture2D> late_color,depth;ComPtr<ID3D11ShaderResourceView> late_view,depth_view;ComPtr<ID3D11RenderTargetView> late_rtv;
    td={Pool,Pool,1,1,format,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_RENDER_TARGET};
    assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&late_color)));
    assert(SUCCEEDED(device->CreateShaderResourceView(late_color.Get(),nullptr,&late_view)));
    assert(SUCCEEDED(device->CreateRenderTargetView(late_color.Get(),nullptr,&late_rtv)));
    const float glow[]={64,32,16,1};context->ClearRenderTargetView(late_rtv.Get(),glow);
    // Real game depth format; typeless resource with R24_UNORM_X8 SRV.
    std::vector<uint32_t> depths(Pool*Pool,1677722u);
    td={Pool,Pool,1,1,DXGI_FORMAT_R24G8_TYPELESS,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE|D3D11_BIND_DEPTH_STENCIL};
    initial={depths.data(),Pool*4};assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&depth)));
    D3D11_SHADER_RESOURCE_VIEW_DESC dv{};dv.Format=DXGI_FORMAT_R24_UNORM_X8_TYPELESS;dv.ViewDimension=D3D11_SRV_DIMENSION_TEXTURE2D;dv.Texture2D.MipLevels=1;
    assert(SUCCEEDED(device->CreateShaderResourceView(depth.Get(),&dv,&depth_view)));
    D3D11_DEPTH_STENCIL_VIEW_DESC dd{};dd.Format=DXGI_FORMAT_D24_UNORM_S8_UINT;dd.ViewDimension=D3D11_DSV_DIMENSION_TEXTURE2D;
    ComPtr<ID3D11DepthStencilView> depth_target;assert(SUCCEEDED(device->CreateDepthStencilView(depth.Get(),&dd,&depth_target)));
    context->ClearDepthStencilView(depth_target.Get(),D3D11_CLEAR_DEPTH|D3D11_CLEAR_STENCIL,.1f,0);
    context->PSSetShaderResources(1,1,depth_view.GetAddressOf());
    // Sentinel state at the private slots must survive each scope.
    ID3D11ShaderResourceView* sentinels[7];for(auto*& v:sentinels)v=native_view.Get();
    context->PSSetShaderResources(108,7,sentinels);
    D3D11_SAMPLER_DESC sd{};sd.Filter=D3D11_FILTER_MIN_MAG_MIP_POINT;sd.AddressU=sd.AddressV=sd.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;
    ComPtr<ID3D11SamplerState> sentinel_sampler;assert(SUCCEEDED(device->CreateSamplerState(&sd,&sentinel_sampler)));
    context->PSSetSamplers(12,1,sentinel_sampler.GetAddressOf());
    auto draw=[&](uint64_t id,UINT width=W,UINT height=H) {
      assert(reflections.Bind(context.Get(),frame_view.Get(),width,height,id));
      context->PSSetShader(ps.Get(),nullptr,0);context->Draw(3,0);
      reflections.Restore(context.Get(),true);
      ID3D11ShaderResourceView* restored[7]{};context->PSGetShaderResources(108,7,restored);
      for(auto* v:restored){assert(v==native_view.Get());v->Release();}
      ComPtr<ID3D11SamplerState> sampler;context->PSGetSamplers(12,1,&sampler);assert(sampler.Get()==sentinel_sampler.Get());
      ComPtr<ID3D11RenderTargetView> output;context->OMGetRenderTargets(1,&output,nullptr);assert(output.Get()==rtv.Get());
    };
    draw(1);assert(read()==baseline);
    assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),1));
    assert(!reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),1));
    const float ended[]={0,0,0,1};context->ClearRenderTargetView(late_rtv.Get(),ended);
    draw(2);expect({64,32,16,0}); // history remains a copy, not aliased live source
    assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),2));
    draw(3);expect({0,0,0,0}); // effect disappears the next frame, no accumulation tail
    draw(5);assert(read()==baseline); // gap invalidates even if GPU allocations persist
    context->ClearRenderTargetView(late_rtv.Get(),glow);
    assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),5));
    context->ClearDepthStencilView(depth_target.Get(),D3D11_CLEAR_DEPTH,.2f,0);
    draw(6);assert(read()==baseline); // disocclusion, no bright history leak
    assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),6));
    frame[0][0]=3;context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    draw(7);assert(read()==baseline); // camera teleport
    frame[0][0]=0;context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),7));
    draw(8,W/2,H/2);assert(read()==baseline); // render size changes
    assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),8));
    reflections.Invalidate();draw(9,W/2,H/2);assert(read()==baseline);
    if(format==DXGI_FORMAT_R32G32B32A32_FLOAT) {
      // Nonconstant radiance catches matrix orientation, jitter and render-pool
      // coordinate mistakes that a uniform plane cannot expose.
      context->ClearDepthStencilView(depth_target.Get(),D3D11_CLEAR_DEPTH,.1f,0);
      std::vector<std::array<float,4>> ramp(Pool*Pool,{1000,1000,1000,1});
      for(UINT y=0;y<H;++y)for(UINT x=0;x<W;++x)ramp[y*Pool+x]={float(x)+.5f,2,3,1};
      context->UpdateSubresource(late_color.Get(),0,nullptr,ramp.data(),Pool*16,0);
      draw(10);
      assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),10));
      frame[0][0]=1;frame[4][0]=-1;frame[208][0]=1;
      context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
      draw(11);
      assert(std::abs(read()[((Q/2)*Q+Q/2)*4]-37.2f)<.003f);
      frame[0][0]=frame[4][0]=frame[208][0]=0;
      frame[15][0]=.02f;
      context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
      assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),11));
      frame[15][0]=0;
      context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
      draw(12);
      std::cout<<"Jitter-reprojected ramp: "<<read()[((Q/2)*Q+Q/2)*4]<<std::endl;
      // D3D11 bilinear addressing has a finite subtexel grid (8 fractional
      // bits minimum); this unit-slope ramp permits one 1/256 texel step.
      assert(std::abs(read()[((Q/2)*Q+Q/2)*4]-34.64f)<1.f/256.f);
      std::cout<<"PASS gradient reprojection: translated camera and previous projection jitter, cropped render pool\n";
    }
    std::cout<<"PASS native SSR history format "<<format<<": original fallback, HDR energy, expired effects, gaps, cuts, disocclusion, resize, exact state restoration\n";
    // Exercise the actual extra MRT and its frame lifetime. Conventional depth
    // maps a 10 m opaque plane to .9 and a 4 m emissive layer to .75.
    frame[0][0]=frame[4][0]=frame[208][0]=0;
    frame[15]={0,0,1,1};frame[16]={0,0,-1,0};
    frame[21]={-1,1,0,0};frame[22]={1,0,0,0};
    frame[208]={0,0,0,-1};frame[209]={0,0,1,1};
    context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    context->ClearDepthStencilView(depth_target.Get(),D3D11_CLEAR_DEPTH,.9f,0);
    reflections.Invalidate();draw(20);
    D3D11_BLEND_DESC blend=CD3D11_BLEND_DESC(D3D11_DEFAULT);
    blend.RenderTarget[0].BlendEnable=TRUE;blend.RenderTarget[0].SrcBlend=D3D11_BLEND_ONE;
    blend.RenderTarget[0].DestBlend=D3D11_BLEND_INV_SRC_ALPHA;
    ComPtr<ID3D11BlendState> additive;assert(SUCCEEDED(device->CreateBlendState(&blend,&additive)));
    context->OMSetRenderTargets(1,late_rtv.GetAddressOf(),nullptr);context->OMSetBlendState(additive.Get(),nullptr,~0u);
    D3D11_VIEWPORT particle_vp{0,0,W,H,0,1};context->RSSetViewports(1,&particle_vp);
    const char* particle_ps="void main(float4 p:SV_Position,out float4 c:SV_Target0,out float z:SV_Target4){c=float4(1,2,3,0);z=p.x<16?65504:4;}";
    ComPtr<ID3DBlob> particle_code;assert(SUCCEEDED(D3DCompile(particle_ps,strlen(particle_ps),nullptr,nullptr,nullptr,"main","ps_5_0",0,0,&particle_code,nullptr)));
    ComPtr<ID3D11PixelShader> particle_shader;assert(SUCCEEDED(device->CreatePixelShader(particle_code->GetBufferPointer(),particle_code->GetBufferSize(),nullptr,&particle_shader)));
    assert(reflections.BindParticle(context.Get(),20));context->PSSetShader(particle_shader.Get(),nullptr,0);context->Draw(3,0);reflections.Restore(context.Get());
    ComPtr<ID3D11BlendState> restored_blend;context->OMGetBlendState(&restored_blend,nullptr,nullptr);assert(restored_blend.Get()==additive.Get());
    ComPtr<ID3D11RenderTargetView> restored_target;context->OMGetRenderTargets(1,&restored_target,nullptr);assert(restored_target.Get()==late_rtv.Get());
    assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),20));
    context->OMSetRenderTargets(1,rtv.GetAddressOf(),nullptr);context->OMSetBlendState(nullptr,nullptr,~0u);context->RSSetViewports(1,&vp);
    auto read_trace=[&](uint64_t id) {
      assert(reflections.BindTrace(context.Get(),id));ComPtr<ID3D11ShaderResourceView> trace;context->PSGetShaderResources(114,1,&trace);
      ComPtr<ID3D11Resource> resource;trace->GetResource(&resource);ComPtr<ID3D11Texture2D> texture;assert(SUCCEEDED(resource.As(&texture)));
      D3D11_TEXTURE2D_DESC desc;texture->GetDesc(&desc);desc.Usage=D3D11_USAGE_STAGING;desc.BindFlags=0;desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
      ComPtr<ID3D11Texture2D> copy;assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&copy)));context->CopyResource(copy.Get(),texture.Get());
      D3D11_MAPPED_SUBRESOURCE map;assert(SUCCEEDED(context->Map(copy.Get(),0,D3D11_MAP_READ,0,&map)));
      std::vector<float> values(Q*Q);for(UINT y=0;y<Q;++y)memcpy(values.data()+y*Q,static_cast<char*>(map.pData)+y*map.RowPitch,Q*4);
      context->Unmap(copy.Get(),0);reflections.Restore(context.Get());return values;
    };
    draw(21);const auto emitted_depth=read_trace(21);
    std::cout<<"Captured/reprojected emissive Z: "<<emitted_depth[Q*Q/2+Q/2]<<std::endl;
    assert(std::abs(emitted_depth[Q*Q/2+Q/2]-.75f)<1.e-5f);
    assert(emitted_depth[Q*Q/2+1]==1.f); // transparent portion cannot create a surface
    assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),21));
    draw(22);assert(!reflections.BindTrace(context.Get(),22)); // no draws: original trace, no stale surface
    assert(!reflections.BindTrace(context.Get(),23));
    std::cout<<"PASS particle MRT: conventional depth conversion, transparent holes, no stale effects, blend/target restoration\n";
    // Classic's real convention: projection has conventional Z, but its depth
    // texture and inverse VP use reversed Z. Test both conversions together.
    frame[22]={-1,1,0,0};frame[208]={0,0,0,1};frame[209]={0,0,1,0};
    context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    context->ClearDepthStencilView(depth_target.Get(),D3D11_CLEAR_DEPTH,.1f,0);
    reflections.Invalidate();draw(30);
    context->OMSetRenderTargets(1,late_rtv.GetAddressOf(),nullptr);context->OMSetBlendState(additive.Get(),nullptr,~0u);context->RSSetViewports(1,&particle_vp);
    assert(reflections.BindParticle(context.Get(),30));context->PSSetShader(particle_shader.Get(),nullptr,0);context->Draw(3,0);reflections.Restore(context.Get());
    assert(reflections.Capture(context.Get(),late_view.Get(),frame_view.Get(),30));
    context->OMSetRenderTargets(1,rtv.GetAddressOf(),nullptr);context->OMSetBlendState(nullptr,nullptr,~0u);context->RSSetViewports(1,&vp);
    draw(31);const auto reversed_depth=read_trace(31);
    assert(std::abs(reversed_depth[Q*Q/2+Q/2]-.25f)<1.e-5f && reversed_depth[Q*Q/2+1]==0.f);
    std::cout<<"PASS Classic reversed-depth conversion: 4 m particle -> .25, empty -> 0\n";
    // Restore the shared camera fixture for the next color-format iteration.
    frame[15]={0,0,0,1};frame[16]={0,0,0,0};frame[21]={1,0,0,0};frame[22]={1,0,0,0};
    frame[208]={0,0,0,1};frame[209]={0,0,1,0};context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
  }
}
