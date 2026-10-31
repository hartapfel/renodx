/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <cassert>
#include <algorithm>
#include <cmath>
#include <iostream>
#include <fstream>
#include <d3dcompiler.h>
#include <vector>
#include <embed/0x128133E9.h>
#include <embed/0xC8C78997.h>
#include "../water/underwater.hpp"
using Microsoft::WRL::ComPtr;
int main(int argc,char** argv) {
  std::cout<<std::unitbuf;
  assert(argc>=2);
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> base;ComPtr<ID3D11DeviceContext1> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>2?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&base)));
  assert(SUCCEEDED(base.As(&context)));
  std::array<std::array<float,4>,269> frame{};
  std::array<std::array<float,4>,116> surface{};
  std::array<std::array<float,4>,49> light{};
  std::array<std::array<float,4>,16> material{};
  std::array<float,4> ranges{-10,10,0,0};
  frame[0]={0,0,-2,1};frame[23]={128,64,1.f/128,1.f/64};frame[38]={0,0,1,1};
  surface[0]={4,8,16,0};surface[1]={1,0,0,0};
  light[0]={0,0,1,1};light[1]={4,8,16,1};material[11]={.1f,.2f,.3f,0};
  ComPtr<ID3D11Buffer> frame_buffer,surface_buffer,light_buffer,material_buffer,range_buffer;
  auto buffer=[&](const auto& values,ComPtr<ID3D11Buffer>* result) {
    D3D11_BUFFER_DESC desc{UINT(sizeof(values)),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
    D3D11_SUBRESOURCE_DATA data{values.data()};assert(SUCCEEDED(device->CreateBuffer(&desc,&data,result->GetAddressOf())));
  };
  buffer(frame,&frame_buffer);buffer(surface,&surface_buffer);buffer(light,&light_buffer);buffer(material,&material_buffer);buffer(ranges,&range_buffer);
  ComPtr<ID3D11Texture2D> waves,heights,tiles;
  ComPtr<ID3D11ShaderResourceView> waves_view,heights_view,tiles_view;
  std::vector<std::array<float,4>> pixels(128*128);
  D3D11_TEXTURE2D_DESC td{128,128,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  D3D11_SUBRESOURCE_DATA initial{pixels.data(),128*16};
  assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&waves)));
  assert(SUCCEEDED(device->CreateShaderResourceView(waves.Get(),nullptr,&waves_view)));
  td.Width=td.Height=1;td.Format=DXGI_FORMAT_R32_FLOAT;float zero=0;initial={&zero,4};
  assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&heights)));
  D3D11_SHADER_RESOURCE_VIEW_DESC vd{};vd.Format=td.Format;vd.ViewDimension=D3D11_SRV_DIMENSION_TEXTURE2DARRAY;
  vd.Texture2DArray.MipLevels=1;vd.Texture2DArray.ArraySize=1;
  assert(SUCCEEDED(device->CreateShaderResourceView(heights.Get(),&vd,&heights_view)));
  td.Width=1;td.Height=2;td.Format=DXGI_FORMAT_R32G32B32A32_FLOAT;
  const std::array<std::array<float,4>,2> metadata{{{-1000,-1000,1000,1000},{0,0,1,1}}};initial={metadata.data(),16};
  assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&tiles)));
  assert(SUCCEEDED(device->CreateShaderResourceView(tiles.Get(),nullptr,&tiles_view)));
  context->PSSetConstantBuffers(0,1,material_buffer.GetAddressOf());
  context->PSSetConstantBuffers(4,1,surface_buffer.GetAddressOf());
  context->PSSetConstantBuffers(5,1,range_buffer.GetAddressOf());
  context->PSSetConstantBuffers(12,1,frame_buffer.GetAddressOf());
  context->VSSetShaderResources(2,1,heights_view.GetAddressOf());
  context->PSSetShaderResources(4,1,heights_view.GetAddressOf());
  context->PSSetShaderResources(5,1,waves_view.GetAddressOf());
  context->PSSetShaderResources(17,1,tiles_view.GetAddressOf());
  witcher3classic::water::Underwater pipeline;
  assert(!pipeline.Bind(context.Get(),1));
  assert(pipeline.Capture(context.Get(),1));
  assert(!pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),3,{}));
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),2,{}));
  // Readback belongs exclusively to this test. The production path remains GPU-only.
  ComPtr<ID3D11Resource> resource;pipeline.CausticsView()->GetResource(&resource);
  ComPtr<ID3D11Texture2D> map;assert(SUCCEEDED(resource.As(&map)));map->GetDesc(&td);
  td.BindFlags=0;td.Usage=D3D11_USAGE_STAGING;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  ComPtr<ID3D11Texture2D> readback;assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&readback)));
  D3D11_MAPPED_SUBRESOURCE mapped{};
  auto read=[&](bool flat) {
    context->CopyResource(readback.Get(),map.Get());assert(SUCCEEDED(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped)));
    std::array<double,4> sum{},minimum{1.e30,1.e30,1.e30,1.e30},maximum{};
    for(UINT y=0;y<CLASSIC_CAUSTIC_ATLAS;++y)for(UINT x=0;x<CLASSIC_CAUSTIC_ATLAS;++x) {
      float value=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)[x];
      if(!std::isfinite(value) || value<0) {
        std::cerr<<"bad pixel "<<x<<","<<y<<" value="<<value<<'\n';
      }
      assert(std::isfinite(value) &&value>=0);
      unsigned layer=x/CLASSIC_CAUSTIC_TILE+2*(y/CLASSIC_CAUSTIC_TILE);sum[layer]+=value;
      minimum[layer]=std::min(minimum[layer],double(value));maximum[layer]=std::max(maximum[layer],double(value));
      if(flat && x%CLASSIC_CAUSTIC_TILE>=3 &&x%CLASSIC_CAUSTIC_TILE<CLASSIC_CAUSTIC_TILE-3 &&y%CLASSIC_CAUSTIC_TILE>=3 &&y%CLASSIC_CAUSTIC_TILE<CLASSIC_CAUSTIC_TILE-3)assert(std::abs(value-1.f)<2.e-4f);
    }
    context->Unmap(readback.Get(),0);
    for(unsigned layer=0;layer<4;++layer) {
      std::cout<<"layer "<<layer<<" mean="<<sum[layer]/double(CLASSIC_CAUSTIC_TILE*CLASSIC_CAUSTIC_TILE)<<" min="<<minimum[layer]<<" max="<<maximum[layer]<<'\n';
      assert(std::abs(sum[layer]/double(CLASSIC_CAUSTIC_TILE*CLASSIC_CAUSTIC_TILE)-1)<.04);
    }
  };
  read(true);
  // A periodic wave redistributes illumination. Dark regions must compensate
  // bright ones; the map must not create a global brightness boost.
  for(UINT y=0;y<128;++y)for(UINT x=0;x<128;++x)
    pixels[y*128+x][3]=.005f*std::sin((float(x)+.5f)*6.283185307f/128)*std::sin((float(y)+.5f)*6.283185307f/128);
  context->UpdateSubresource(waves.Get(),0,nullptr,pixels.data(),128*16,0);
  assert(pipeline.Capture(context.Get(),2));
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),3,{}));
  read(false);
  // Folded waves and subpixel animation: concentrated footprints must retain
  // energy and vary continuously rather than switching on/off at pixel centers.
  std::vector<float> prior_map(CLASSIC_CAUSTIC_ATLAS*CLASSIC_CAUSTIC_ATLAS);double prior_flux=0;
  for(unsigned phase=0;phase<2;++phase) {
    for(UINT y=0;y<128;++y)for(UINT x=0;x<128;++x)
      pixels[y*128+x][3]=.15f*std::sin((float(x)+.5f)*6.283185307f/128+phase*.001f)
          *std::sin((float(y)+.5f)*6.283185307f/128);
    context->UpdateSubresource(waves.Get(),0,nullptr,pixels.data(),128*16,0);
    assert(pipeline.Capture(context.Get(),2));
    assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),3,{}));
    context->CopyResource(readback.Get(),map.Get());assert(SUCCEEDED(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped)));
    double flux=0,max_delta=0,max_value=0;
    for(UINT y=0;y<CLASSIC_CAUSTIC_ATLAS;++y)for(UINT x=0;x<CLASSIC_CAUSTIC_ATLAS;++x) {
      float value=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)[x];
      assert(std::isfinite(value) &&value>=0);flux+=value;max_value=std::max(max_value,double(value));
      if(phase)max_delta=std::max(max_delta,double(std::abs(value-prior_map[y*CLASSIC_CAUSTIC_ATLAS+x])));
      prior_map[y*CLASSIC_CAUSTIC_ATLAS+x]=value;
    }
    context->Unmap(readback.Get(),0);
    std::cout<<"Folded wave phase="<<phase<<" flux="<<flux<<" peak="<<max_value<<" subpixel max delta="<<max_delta<<'\n';
    assert(max_value<32 &&std::abs(flux/double(CLASSIC_CAUSTIC_ATLAS*CLASSIC_CAUSTIC_ATLAS)-1)<.04);
    if(phase)assert(std::abs(flux-prior_flux)/prior_flux<.001 &&max_delta<.15);
    prior_flux=flux;
  }
  ID3D11ShaderResourceView* sentinels[13];std::fill(std::begin(sentinels),std::end(sentinels),waves_view.Get());
  D3D11_SAMPLER_DESC native_sampler_desc=CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
  native_sampler_desc.Filter=D3D11_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT;
  native_sampler_desc.ComparisonFunc=D3D11_COMPARISON_LESS_EQUAL;
  ComPtr<ID3D11SamplerState> native_sampler;
  assert(SUCCEEDED(device->CreateSamplerState(&native_sampler_desc,&native_sampler)));
  for(bool compute:{false,true}) {
    if(compute)context->CSSetShaderResources(86,13,sentinels);else context->PSSetShaderResources(86,13,sentinels);
    if(compute)context->CSSetSamplers(12,1,native_sampler.GetAddressOf());else context->PSSetSamplers(12,1,native_sampler.GetAddressOf());
    assert(pipeline.Bind(context.Get(),3,compute));assert(!pipeline.Bind(context.Get(),3,compute));
    ComPtr<ID3D11SamplerState> material_sampler;
    if(compute)context->CSGetSamplers(12,1,&material_sampler);else context->PSGetSamplers(12,1,&material_sampler);
    assert(material_sampler.Get()==native_sampler.Get());
    pipeline.Restore(context.Get());
    ComPtr<ID3D11ShaderResourceView> restored;
    if(compute)context->CSGetShaderResources(88,1,&restored);else context->PSGetShaderResources(88,1,&restored);
    assert(restored.Get()==waves_view.Get());
  }
  // Moving above water disables all indirect photon/raster work and the state.
  for(auto* original_sampler:{native_sampler.Get(),static_cast<ID3D11SamplerState*>(nullptr)}) {
    context->PSSetSamplers(12,1,&original_sampler);
    assert(pipeline.Bind(context.Get(),3,false,true));
    ComPtr<ID3D11SamplerState> comparison;
    context->PSGetSamplers(12,1,&comparison);assert(comparison);
    D3D11_SAMPLER_DESC desc{};comparison->GetDesc(&desc);
    assert(desc.ComparisonFunc==D3D11_COMPARISON_LESS_EQUAL &&desc.Filter==D3D11_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT);
    pipeline.Restore(context.Get());comparison.Reset();context->PSGetSamplers(12,1,&comparison);
    assert(comparison.Get()==original_sampler);
  }
  std::cout<<"PASS comparison sampler restricted to composite and restored (including null)\n";
  frame[0][2]=2;context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),3,{}));
  pipeline.StateView()->GetResource(&resource);
  D3D11_BUFFER_DESC bd{8*16,D3D11_USAGE_STAGING,0,D3D11_CPU_ACCESS_READ};ComPtr<ID3D11Buffer> state_read;
  assert(SUCCEEDED(device->CreateBuffer(&bd,nullptr,&state_read)));
  context->CopyResource(state_read.Get(),resource.Get());assert(SUCCEEDED(context->Map(state_read.Get(),0,D3D11_MAP_READ,0,&mapped)));
  assert(static_cast<const float*>(mapped.pData)[3]==0.f);context->Unmap(state_read.Get(),0);
  std::cout<<"PASS flat-water unity, wave flux conservation, atlas clipping, stale frames, PS/CS restoration and above-water suppression\n";
  // Camera effects are absent above/at the interface and ramp continuously
  // only below it. Clearing physical murkiness also clears the scattering source.
  witcher3classic::water::Underwater::Controls camera_controls;
  float previous_camera_weight=0;
  for(float z:{.2f,0.f,-.05f,-.15f,-.25f,-.4f,-1.f}) {
    frame[0][2]=z;context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),3,camera_controls));
    context->CopyResource(state_read.Get(),resource.Get());assert(SUCCEEDED(context->Map(state_read.Get(),0,D3D11_MAP_READ,0,&mapped)));
    const auto* values=static_cast<const float*>(mapped.pData);
    assert(values[23]>=previous_camera_weight &&values[23]<=1.f &&values[28]==0.f);
    if(z>=-.05f)assert(values[23]==0.f &&values[28]==0.f);
    if(z<=-.4f)assert(std::abs(values[23]-1.f)<1e-6f &&values[28]==0.f);
    previous_camera_weight=values[23];context->Unmap(state_read.Get(),0);
  }
  camera_controls.medium[0]=0;
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),3,camera_controls));
  context->CopyResource(state_read.Get(),resource.Get());assert(SUCCEEDED(context->Map(state_read.Get(),0,D3D11_MAP_READ,0,&mapped)));
  assert(static_cast<const float*>(mapped.pData)[12]==0.f && static_cast<const float*>(mapped.pData)[13]==0.f && static_cast<const float*>(mapped.pData)[14]==0.f);context->Unmap(state_read.Get(),0);
  frame[0][2]=2;context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),3,{}));
  std::cout<<"PASS camera immersion fade and zero-murkiness scattering bypass\n";

  // Execute the complete production underwater composite, first against the
  // game's original bytecode, then against a physical homogeneous-medium oracle.
  std::ifstream original_file(argv[1],std::ios::binary);assert(original_file);
  std::vector<char> original_code{std::istreambuf_iterator<char>(original_file),{}};
  ComPtr<ID3D11PixelShader> original_ps,custom_ps,air_ps;
  assert(SUCCEEDED(device->CreatePixelShader(original_code.data(),original_code.size(),nullptr,&original_ps)));
  assert(SUCCEEDED(device->CreatePixelShader(__0x128133E9.data(),__0x128133E9.size(),nullptr,&custom_ps)));
  assert(SUCCEEDED(device->CreatePixelShader(__0xC8C78997.data(),__0xC8C78997.size(),nullptr,&air_ps)));
  const char* vs_text="struct O{float4 p:SV_Position;float2 uv:TEXCOORD0;};O main(uint id:SV_VertexID){O o;o.uv=float2((id<<1)&2,id&2);o.p=float4(o.uv*float2(2,-2)+float2(-1,1),0,1);return o;}";
  ComPtr<ID3DBlob> vs_blob;ComPtr<ID3D11VertexShader> vs;
  assert(SUCCEEDED(D3DCompile(vs_text,strlen(vs_text),nullptr,nullptr,nullptr,"main","vs_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&vs_blob,nullptr)));
  assert(SUCCEEDED(device->CreateVertexShader(vs_blob->GetBufferPointer(),vs_blob->GetBufferSize(),nullptr,&vs)));
  ComPtr<ID3D11Texture2D> scene,mask,depth_texture,result,result_read;
  ComPtr<ID3D11ShaderResourceView> scene_view,mask_view,depth_view;
  td={64,4,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
  const float radiance[]={64,128,256,1},immersion[]={1,0,0,0};
  const std::vector<std::array<float,4>> scene_pixels(64*4,{64,128,256,1});initial={scene_pixels.data(),64*16};
  assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&scene)));
  assert(SUCCEEDED(device->CreateShaderResourceView(scene.Get(),nullptr,&scene_view)));
  td.Width=td.Height=1;initial={immersion,16};assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&mask)));
  assert(SUCCEEDED(device->CreateShaderResourceView(mask.Get(),nullptr,&mask_view)));
  const std::vector<float> depth_pixels(64*4,.04f);td.Width=64;td.Height=4;td.Format=DXGI_FORMAT_R32_FLOAT;initial={depth_pixels.data(),64*4};
  assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&depth_texture)));
  assert(SUCCEEDED(device->CreateShaderResourceView(depth_texture.Get(),nullptr,&depth_view)));
  td.Width=64;td.Height=4;td.Format=DXGI_FORMAT_R32G32B32A32_FLOAT;td.BindFlags=D3D11_BIND_RENDER_TARGET;
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&result)));
  ComPtr<ID3D11RenderTargetView> result_target;assert(SUCCEEDED(device->CreateRenderTargetView(result.Get(),nullptr,&result_target)));
  td.Usage=D3D11_USAGE_STAGING;td.BindFlags=0;td.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&result_read)));
  material[2]={64,4,1,1};material[13]={0,.3f,.4f,.2f};material[14]={.5f,.5f,0,0};material[11]={0,0,0,0};
  frame[0]={0,0,-2,1};frame[21]={-5,5,1,1};frame[22]={-1,1,.2f,5000};
  frame[210]={1.f/64,0,0,0};frame[211]={0,0,-.25f,0};frame[212]={0,0,0,1};frame[213]={-.5f,1,-.2f,0};
  light[1]={0,0,0,0};
  context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
  context->UpdateSubresource(material_buffer.Get(),0,nullptr,material.data(),0,0);
  context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
  std::fill(pixels.begin(),pixels.end(),std::array<float,4>{});context->UpdateSubresource(waves.Get(),0,nullptr,pixels.data(),128*16,0);
  assert(pipeline.Capture(context.Get(),3));
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),4,{}));
  std::array<ID3D11ShaderResourceView*,13> empty{};context->PSSetShaderResources(86,13,empty.data());
  context->CSSetShaderResources(86,13,empty.data());
  context->OMSetRenderTargets(1,result_target.GetAddressOf(),nullptr);context->OMSetBlendState(nullptr,nullptr,UINT_MAX);
  context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  context->VSSetShader(vs.Get(),nullptr,0);
  D3D11_VIEWPORT viewport{0,0,64,4,0,1};context->RSSetViewports(1,&viewport);
  context->PSSetShaderResources(0,1,scene_view.GetAddressOf());context->PSSetShaderResources(2,1,mask_view.GetAddressOf());
  context->PSSetShaderResources(3,1,depth_view.GetAddressOf());context->PSSetShaderResources(15,1,depth_view.GetAddressOf());
  D3D11_SAMPLER_DESC sd=CD3D11_SAMPLER_DESC(D3D11_DEFAULT);sd.AddressU=sd.AddressV=sd.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;
  ComPtr<ID3D11SamplerState> sampler;assert(SUCCEEDED(device->CreateSamplerState(&sd,&sampler)));
  for(UINT slot:{0u,2u,3u,5u,15u})context->PSSetSamplers(slot,1,sampler.GetAddressOf());
  auto render=[&](ID3D11PixelShader* shader) {
    context->PSSetShader(shader,nullptr,0);context->Draw(3,0);context->CopyResource(result_read.Get(),result.Get());
    assert(SUCCEEDED(context->Map(result_read.Get(),0,D3D11_MAP_READ,0,&mapped)));
    std::vector<std::array<float,4>> data(64*4);
    for(UINT y=0;y<4;++y)memcpy(data.data()+64*y,static_cast<const char*>(mapped.pData)+y*mapped.RowPitch,64*16);
    context->Unmap(result_read.Get(),0);return data;
  };
  auto native=render(original_ps.Get()),fallback=render(custom_ps.Get());
  for(size_t i=0;i<native.size();++i)for(unsigned c=0;c<4;++c)
    assert(std::isfinite(fallback[i][c]) &&std::abs(native[i][c]-fallback[i][c])<2.e-5f);
  // Above-water caustics use the same receiver optics but must not modify dry
  // land, cave surfaces below the native terrain, or a region with a dry floor.
  ComPtr<ID3DBlob> receiver_code,receiver_errors;ComPtr<ID3D11PixelShader> receiver_ps;
  HRESULT receiver_compiled=D3DCompileFromFile(L"src/games/thewitcher3classic/tests/underwater_receivers.hlsl",
      nullptr,D3D_COMPILE_STANDARD_FILE_INCLUDE,"main","ps_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&receiver_code,&receiver_errors);
  if(receiver_errors)std::cerr<<static_cast<const char*>(receiver_errors->GetBufferPointer());
  assert(SUCCEEDED(receiver_compiled));
  assert(SUCCEEDED(device->CreatePixelShader(receiver_code->GetBufferPointer(),receiver_code->GetBufferSize(),nullptr,&receiver_ps)));
  frame[0][2]=2.f;context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
  witcher3classic::water::Underwater::Controls surface_controls;surface_controls.quality[2]=1.f;
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),4,surface_controls));
  read(true);
  assert(pipeline.Bind(context.Get(),4,false,true));auto receivers=render(receiver_ps.Get());pipeline.Restore(context.Get());
  for(UINT y=0;y<4;++y)for(UINT x=0;x<64;++x) {
    const auto& value=receivers[y*64+x];
    if(y==1 ||y==2) {assert(value[0]==0.f);for(UINT c=1;c<4;++c)assert(value[c]==1.f);}
    else {
      double depth=y==0?2.:.05,weight=y==0?1.:.5;
      assert(std::abs(value[0]-weight)<1.e-5);
      for(UINT c=0;c<3;++c) {
        double extinction=-std::log(double(material[13][c+1]))/10+.03*double(material[13][c+1])/.4;
        double flux=1-std::pow((1.333-1)/(1.333+1),2);
        double expected=1-weight+weight*flux*std::exp(-extinction*depth);
        assert(std::abs(value[c+1]-expected)<1.e-4);
      }
    }
  }
  float dry_floor=1.f;context->UpdateSubresource(heights.Get(),0,nullptr,&dry_floor,4,0);
  assert(pipeline.Bind(context.Get(),4,false,true));auto dry=render(receiver_ps.Get());pipeline.Restore(context.Get());
  for(const auto& value:dry) {assert(value[0]==0.f);for(UINT c=1;c<4;++c)assert(value[c]==1.f);}
  context->UpdateSubresource(heights.Get(),0,nullptr,&zero,4,0);
  surface_controls.quality[2]=0.f;
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),4,surface_controls));
  assert(pipeline.Bind(context.Get(),4,false,true));auto surface_native=render(receiver_ps.Get());pipeline.Restore(context.Get());
  for(const auto& value:surface_native) {assert(value[0]==0.f);for(UINT c=1;c<4;++c)assert(value[c]==1.f);}
  frame[0][2]=-2.f;context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
  surface_controls.medium[2]=0.f;surface_controls.quality[2]=1.f;
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),4,surface_controls));
  assert(pipeline.Bind(context.Get(),4,false,true));auto underwater_native=render(receiver_ps.Get());pipeline.Restore(context.Get());
  for(const auto& value:underwater_native) {assert(value[0]==0.f);for(UINT c=1;c<4;++c)assert(value[c]==1.f);}
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),4,{}));
  std::cout<<"PASS above-water caustic preparation, shared receiver transport, dry land/below-terrain exclusion and independent Native modes\n";
  assert(pipeline.Bind(context.Get(),4,false,true));
  auto transported=render(custom_ps.Get());
  for(UINT y=0;y<4;++y)for(UINT x=0;x<64;++x) {
    double wx=(double(x)/64-.5)/.04,wy=25,wz=(-double(y)/4-.2)/.04;
    double length=std::sqrt(wx*wx+wy*wy+(wz+2)*(wz+2));
    for(unsigned c=0;c<3;++c) {
      double extinction=-std::log(double(material[13][c+1]))/10+.03*double(material[13][c+1])/.4;
      double expected=radiance[c]*std::exp(-extinction*length)*material[14][0];
      if(!std::isfinite(transported[y*64+x][c]) ||std::abs(transported[y*64+x][c]-expected)>=1.e-4)
        std::cerr<<"transport "<<x<<","<<y<<","<<c<<" actual="<<transported[y*64+x][c]<<" expected="<<expected<<'\n';
      assert(std::isfinite(transported[y*64+x][c]) &&std::abs(transported[y*64+x][c]-expected)<1.e-4);
    }
    if(y==0 &&x==32)assert(transported[y*64+x][2]>1.f);
  }
  context->PSSetShaderResources(0,1,depth_view.GetAddressOf());context->PSSetShaderResources(1,1,scene_view.GetAddressOf());
  auto without_air=render(air_ps.Get());
  for(const auto& pixel:without_air)for(unsigned c=0;c<3;++c)assert(pixel[c]==radiance[c]);
  pipeline.Restore(context.Get());
  std::cout<<"PASS original-DXBC fallback, complete underwater RGB attenuation/HDR, and exclusion of double-counted opaque air fog\n";
  context->PSSetShaderResources(0,1,scene_view.GetAddressOf());
  for(float density:{.5f,0.f}) {
    witcher3classic::water::Underwater::Controls controls;controls.medium[0]=.03f*density;
    assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),4,controls));
    assert(pipeline.Bind(context.Get(),4,false,true));auto clear=render(custom_ps.Get());pipeline.Restore(context.Get());
    for(size_t i=0;i<clear.size();++i)for(unsigned c=0;c<3;++c) {
      assert(clear[i][c]>transported[i][c]);
      if(density==0.f)assert(std::abs(clear[i][c]-radiance[c]*material[14][0])<1.e-5f);
    }
  }
  std::cout<<"PASS lower murkiness clears absorption and scattering; zero density preserves scene HDR\n";
  // The captured transition had a fully submerged native mask at camera z=-.254
  // but the previous .35..1 m activation ramp still selected native tint/blur.
  // Check the complete former ramp and fractional waterline coverage against
  // Beer-Lambert transport, including rays entering water from just above it.
  for(float camera_z:{.1f,-.001f,-.1f,-.254f,-.35f,-.675f,-.999f,-1.f,-2.f}) {
    frame[0][2]=camera_z;
    context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),4,{}));
    assert(pipeline.Bind(context.Get(),4,false,true));
    for(float coverage:{0.f,.25f,.998f,1.f}) {
      const float waterline[]={coverage,0,0,0};context->UpdateSubresource(mask.Get(),0,nullptr,waterline,16,0);
      auto transition=render(custom_ps.Get());
      for(UINT y=0;y<4;++y)for(UINT x=0;x<64;++x) {
        double wx=(double(x)/64-.5)/.04,wy=25,wz=(-double(y)/4-.2)/.04;
        double distance=std::sqrt(wx*wx+wy*wy+(wz-camera_z)*(wz-camera_z));
        if(camera_z>0.f)distance*=(-wz)/(camera_z-wz);
        for(unsigned c=0;c<3;++c) {
          double extinction=-std::log(double(material[13][c+1]))/10+.03*double(material[13][c+1])/.4;
          double expected=radiance[c]*(1-coverage)+coverage*radiance[c]*std::exp(-extinction*distance)*material[14][0];
          assert(std::isfinite(transition[y*64+x][c]) &&std::abs(transition[y*64+x][c]-expected)<1.e-4);
        }
      }
    }
    pipeline.Restore(context.Get());
  }
  context->UpdateSubresource(mask.Get(),0,nullptr,immersion,16,0);
  // Above-water receivers before the ray reaches the interface must remain
  // unchanged, even if a feathered native mask has nonzero coverage.
  frame[0][2]=.1f;frame[213][2]=.08f;frame[211][2]=0.f;
  context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),4,{}));
  assert(pipeline.Bind(context.Get(),4,false,true));auto above_surface=render(custom_ps.Get());pipeline.Restore(context.Get());
  for(const auto& pixel:above_surface)for(unsigned c=0;c<4;++c)assert(pixel[c]==radiance[c]);
  frame[0][2]=-2.f;frame[213][2]=-.2f;frame[211][2]=-.25f;
  context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
  std::cout<<"PASS shallow immersion, fractional meniscus and above-water segment exclusion without native fog handoff\n";
  light[1]={4,8,16,1};context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
  context->PSSetShaderResources(0,1,scene_view.GetAddressOf());
  for(float quality:{1.f,4.f}) {
    witcher3classic::water::Underwater::Controls controls;controls.quality[0]=quality;
    assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),4,controls));
    assert(pipeline.Bind(context.Get(),4,false,true));auto lit=render(custom_ps.Get());pipeline.Restore(context.Get());
    for(UINT y=0;y<4;++y)for(UINT x=0;x<64;++x) {
      double wx=(double(x)/64-.5)/.04,wy=25,wz=(-double(y)/4-.2)/.04;
      double distance=std::sqrt(wx*wx+wy*wy+(wz+2)*(wz+2)),dz=(wz+2)/distance;
      double phase=.75/(4*3.141592653589793*std::pow(1.25-dz,1.5));
      double fresnel=std::pow((1.333-1)/(1.333+1),2);
      for(unsigned c=0;c<3;++c) {
        double scatter=.03*double(material[13][c+1])/.4;
        double extinction=-std::log(double(material[13][c+1]))/10+scatter;
        double integral=0;
        for(unsigned i=0;i<4096;++i) {
          double eye=(i+.5)*distance/4096;
          integral+=std::exp(-extinction*(eye+2-dz*eye))*distance/4096;
        }
        double expected=(radiance[c]*std::exp(-extinction*distance)+scatter*light[1][c]*(1-fresnel)*phase*integral)*material[14][0];
        assert(std::abs(lit[y*64+x][c]-expected)<1.e-4);
      }
    }
  }
  // A native straight-light shadow lying BELOW the interface is not a valid
  // blocker of the air-to-water ray. The rejected double lookup incorrectly
  // projects it through the underwater integral as repeated large silhouettes.
  const auto saved_light=light;
  light[6]={0,0,-.1f,0};light[7]={0,0,.25f,0};light[10]={100,100,100,100};
  light[11]={.5f,.5f,.001f,0};light[15][2]=1;
  context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
  std::vector<std::array<float,4>> unshadowed;
  for(float occluder:{1.f,.3f,.2f}) {
    context->UpdateSubresource(heights.Get(),0,nullptr,&occluder,4,0);
    for(float quality:{1.f,2.f,4.f}) {
      witcher3classic::water::Underwater::Controls controls;controls.quality[0]=quality;
      assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),4,controls));
      assert(pipeline.Bind(context.Get(),4,false,true));auto shadowed=render(custom_ps.Get());pipeline.Restore(context.Get());
      if(unshadowed.empty())unshadowed=shadowed;
      for(size_t i=0;i<shadowed.size();++i)for(unsigned c=0;c<3;++c) {
        float expected=occluder<.25f ? transported[i][c]:unshadowed[i][c];
        assert(std::abs(shadowed[i][c]-expected)<1.e-4f);
      }
    }
  }
  light=saved_light;context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
  std::cout<<"PASS submerged occluder does not cast false air shadows; above-water occluder still blocks shafts at every detail\n";
  // Spatial blocker regression: one thin above-water strip must integrate into
  // a continuous shadow volume, not a stack of copies at fixed Gauss depths.
  // Compare the complete production pixel shader with dense scalar quadrature.
  {
    std::vector<float> blocker(256,1.f);
    for(UINT x=143;x<151;++x)blocker[x]=.2f;
    const D3D11_TEXTURE2D_DESC shadow_desc{256,1,1,1,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    const D3D11_SUBRESOURCE_DATA shadow_data{blocker.data(),256*4,0};
    ComPtr<ID3D11Texture2D> shadow_texture;ComPtr<ID3D11ShaderResourceView> shadow_view;
    assert(SUCCEEDED(device->CreateTexture2D(&shadow_desc,&shadow_data,&shadow_texture)));
    D3D11_SHADER_RESOURCE_VIEW_DESC shadow_srv{};shadow_srv.Format=DXGI_FORMAT_R32_FLOAT;
    shadow_srv.ViewDimension=D3D11_SRV_DIMENSION_TEXTURE2DARRAY;shadow_srv.Texture2DArray.MipLevels=1;shadow_srv.Texture2DArray.ArraySize=1;
    assert(SUCCEEDED(device->CreateShaderResourceView(shadow_texture.Get(),&shadow_srv,&shadow_view)));
    light[4]={.04f,0,0,0};light[5]={0,0,0,0};light[6]={0,0,-.1f,0};light[7]={0,0,.25f,0};
    light[8]={0,0,0,0};light[9]={0,0,0,0};light[10]={100,100,100,100};
    light[11]={.5f,.5f,1,0};light[15][2]=1;light[17]={0,0,0,0};
    context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
    std::array<std::array<double,3>,256> reference{},normalizer{};
    for(UINT y=0;y<4;++y)for(UINT x=0;x<64;++x) {
      double wx=(double(x)/64-.5)/.04,wy=25,wz=(-double(y)/4-.2)/.04;
      double distance=std::sqrt(wx*wx+wy*wy+(wz+2)*(wz+2)),dz=(wz+2)/distance;
      double phase=.75/(4*3.141592653589793*std::pow(1.25-dz,1.5));
      double fresnel=std::pow((1.333-1)/(1.333+1),2);
      for(UINT c=0;c<3;++c) {
        double scatter=.03*double(material[13][c+1])/.4;
        double extinction=-std::log(double(material[13][c+1]))/10+scatter;
        double integral=0,full=0;
        for(UINT i=0;i<16384;++i) {
          double t=(i+.5)*distance/16384,coordinate=(.5+.04*wx*t/distance)*256-.5;
          int cell=int(std::floor(coordinate));double f=coordinate-cell;
          double visibility=(blocker[std::clamp(cell,0,255)]>=.25?1.:0.)*(1-f)
              +(blocker[std::clamp(cell+1,0,255)]>=.25?1.:0.)*f;
          double weight=std::exp(-extinction*(t+2-dz*t))*distance/16384;
          integral+=weight*visibility;full+=weight;
        }
        double source=scatter*light[1][c]*(1-fresnel)*phase;
        reference[y*64+x][c]=(radiance[c]*std::exp(-extinction*distance)+source*integral)*material[14][0];
        normalizer[y*64+x][c]=source*full*material[14][0];
      }
    }
    for(float quality:{1.f,2.f,4.f}) {
      witcher3classic::water::Underwater::Controls controls;controls.quality[0]=quality;
      assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),shadow_view.Get(),4,controls));
      assert(pipeline.Bind(context.Get(),4,false,true));auto shadowed=render(custom_ps.Get());pipeline.Restore(context.Get());
      double squared=0,bias=0,maximum=0;
      for(size_t i=0;i<shadowed.size();++i)for(UINT c=0;c<3;++c) {
        double error=(shadowed[i][c]-reference[i][c])/std::max(normalizer[i][c],1e-6);
        squared+=error*error;bias+=error;maximum=std::max(maximum,std::abs(error));
      }
      double rms=std::sqrt(squared/(256*3));bias/=256*3;
      std::cout<<"Thin blocker Q="<<quality<<" RMS="<<rms<<" bias="<<bias<<" max="<<maximum<<'\n';
      assert(rms<.025/quality &&std::abs(bias)<.008 &&maximum<.12/quality);
      if(argc>4 &&std::string(argv[3])=="--compare-shadow") {
        std::ifstream old_file(argv[4],std::ios::binary);assert(old_file);
        std::vector<char> old_code{std::istreambuf_iterator<char>(old_file),{}};
        ComPtr<ID3D11PixelShader> old_shader;
        assert(SUCCEEDED(device->CreatePixelShader(old_code.data(),old_code.size(),nullptr,&old_shader)));
        assert(pipeline.Bind(context.Get(),4,false,true));auto old=render(old_shader.Get());pipeline.Restore(context.Get());
        double old_squared=0;
        for(size_t i=0;i<old.size();++i)for(UINT c=0;c<3;++c) {
          double error=(old[i][c]-reference[i][c])/std::max(normalizer[i][c],1e-6);
          old_squared+=error*error;
        }
        double old_rms=std::sqrt(old_squared/(256*3));
        std::cout<<"Previous shadow shader Q="<<quality<<" RMS="<<old_rms<<" new/old="<<rms/old_rms<<'\n';
        if(quality==4.f)assert(rms<old_rms);
      }
    }
    light=saved_light;context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
    std::cout<<"PASS thin-blocker volumetric shadow vs dense quadrature at every quality\n";
  }
  // Nonzero regional water elevation must supersede the global ocean plane.
  UINT one=1;memcpy(&surface[6][0],&one,4);surface[7]={-1000,-1000,2000,2000};
  context->UpdateSubresource(surface_buffer.Get(),0,nullptr,surface.data(),0,0);
  float lake=5;context->UpdateSubresource(heights.Get(),0,nullptr,&lake,4,0);
  assert(pipeline.Capture(context.Get(),10));
  assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),11,{}));
  pipeline.StateView()->GetResource(&resource);context->CopyResource(state_read.Get(),resource.Get());
  assert(SUCCEEDED(context->Map(state_read.Get(),0,D3D11_MAP_READ,0,&mapped)));
  assert(static_cast<const float*>(mapped.pData)[7]==5.f);context->Unmap(state_read.Get(),0);
  std::cout<<"PASS complete sunlight scattering vs numerical quadrature at low/high detail and nonzero regional water elevations\n";
  if(argc>4 &&std::string(argv[3])=="--scene") {
    auto load=[&](const char* name,void* destination,size_t size) {
      std::ifstream file(std::string(argv[4])+"/"+name,std::ios::binary);assert(file);
      file.read(static_cast<char*>(destination),size);assert(file.gcount()==size);
    };
    load("revision-cb0.bin",material.data(),sizeof(material));
    load("revision-cb4.bin",surface.data(),sizeof(surface));
    load("revision-cb5.bin",ranges.data(),sizeof(ranges));
    load("revision-cb12.bin",frame.data(),sizeof(frame));
    // Scene fixture isolates the captured ocean waves; terrain/region arrays
    // remain synthetic. Do not call this a complete gameplay replay.
    surface[6][0]=0;float ocean=0;context->UpdateSubresource(heights.Get(),0,nullptr,&ocean,4,0);
    light[0]=material[9];light[1]=material[10];
    context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    context->UpdateSubresource(surface_buffer.Get(),0,nullptr,surface.data(),0,0);
    context->UpdateSubresource(material_buffer.Get(),0,nullptr,material.data(),0,0);
    context->UpdateSubresource(range_buffer.Get(),0,nullptr,ranges.data(),0,0);
    context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
    std::vector<std::array<float,4>> captured_waves(512*512);
    load("revision-waves.bin",captured_waves.data(),captured_waves.size()*16);
    td={512,512,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    initial={captured_waves.data(),512*16};waves.Reset();waves_view.Reset();
    assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&waves)));
    assert(SUCCEEDED(device->CreateShaderResourceView(waves.Get(),nullptr,&waves_view)));
    context->PSSetShaderResources(5,1,waves_view.GetAddressOf());
    assert(pipeline.Capture(context.Get(),30));
    assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),heights_view.Get(),31,{}));
    context->CopyResource(readback.Get(),map.Get());assert(SUCCEEDED(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped)));
    std::ofstream raw(std::string(argv[4])+"/revised-native-caustics.bin",std::ios::binary);
    double total=0,peak=0;
    for(UINT y=0;y<CLASSIC_CAUSTIC_ATLAS;++y) {
      const auto* row=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch);
      raw.write(reinterpret_cast<const char*>(row),CLASSIC_CAUSTIC_ATLAS*4);
      for(UINT x=0;x<CLASSIC_CAUSTIC_ATLAS;++x){assert(std::isfinite(row[x]) &&row[x]>=0);total+=row[x];peak=std::max(peak,double(row[x]));}
    }
    context->Unmap(readback.Get(),0);
    std::cout<<"Captured ocean wave replay mean="<<total/(CLASSIC_CAUSTIC_ATLAS*CLASSIC_CAUSTIC_ATLAS)<<" peak="<<peak<<'\n';
  }
  if(argc>3 &&std::string(argv[3])=="--benchmark") {
    // Synthetic full-screen cost, not a gameplay FPS prediction. Include four
    // CSM layers so the lighting loop performs actual shadow texture reads.
    constexpr UINT width=3840,height=2160;
    frame[23]={float(width),float(height),1.f/width,1.f/height};
    frame[210]={1.f/width,0,0,0};frame[211]={0,0,-1.f/height,0};
    material[2]={float(width),float(height),1,1};
    light[4]={.005f,0,0,0};light[5]={0,.005f,0,0};light[6]={0,0,.005f,0};
    light[7]={0,0,.5f,0};light[10]={1,2,4,8};light[15][2]=4;
    for(unsigned i=0;i<4;++i)light[11+i]={.5f,.5f,.5f,0};
    context->UpdateSubresource(frame_buffer.Get(),0,nullptr,frame.data(),0,0);
    context->UpdateSubresource(material_buffer.Get(),0,nullptr,material.data(),0,0);
    context->UpdateSubresource(light_buffer.Get(),0,nullptr,light.data(),0,0);
    td={width,height,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    std::vector<std::array<float,4>> colors(width*height,{4,8,16,1});initial={colors.data(),width*16};
    scene.Reset();scene_view.Reset();assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&scene)));
    assert(SUCCEEDED(device->CreateShaderResourceView(scene.Get(),nullptr,&scene_view)));
    td.Format=DXGI_FORMAT_R32_FLOAT;std::vector<float> depths(width*height,.04f);initial={depths.data(),width*4};
    depth_texture.Reset();depth_view.Reset();assert(SUCCEEDED(device->CreateTexture2D(&td,&initial,&depth_texture)));
    assert(SUCCEEDED(device->CreateShaderResourceView(depth_texture.Get(),nullptr,&depth_view)));
    td.Format=DXGI_FORMAT_R16G16B16A16_FLOAT;td.BindFlags=D3D11_BIND_RENDER_TARGET;
    result.Reset();result_target.Reset();assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&result)));
    assert(SUCCEEDED(device->CreateRenderTargetView(result.Get(),nullptr,&result_target)));
    td={512,512,1,4,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
    std::vector<float> shadow_pixels(512*512,1.f);std::array<D3D11_SUBRESOURCE_DATA,4> shadow_data;
    for(auto& layer:shadow_data)layer={shadow_pixels.data(),512*4};
    ComPtr<ID3D11Texture2D> shadow_map;ComPtr<ID3D11ShaderResourceView> shadow_view;
    assert(SUCCEEDED(device->CreateTexture2D(&td,shadow_data.data(),&shadow_map)));
    assert(SUCCEEDED(device->CreateShaderResourceView(shadow_map.Get(),nullptr,&shadow_view)));
    context->OMSetRenderTargets(1,result_target.GetAddressOf(),nullptr);
    viewport.Width=float(width);viewport.Height=float(height);context->RSSetViewports(1,&viewport);
    context->PSSetShaderResources(0,1,scene_view.GetAddressOf());
    context->PSSetShaderResources(3,1,depth_view.GetAddressOf());context->PSSetShaderResources(15,1,depth_view.GetAddressOf());
    assert(pipeline.Capture(context.Get(),20));
    D3D11_QUERY_DESC qd{D3D11_QUERY_TIMESTAMP_DISJOINT,0};ComPtr<ID3D11Query> disjoint,start,end;
    assert(SUCCEEDED(device->CreateQuery(&qd,&disjoint)));qd.Query=D3D11_QUERY_TIMESTAMP;
    assert(SUCCEEDED(device->CreateQuery(&qd,&start)));assert(SUCCEEDED(device->CreateQuery(&qd,&end)));
    auto measure=[&](const char* label,auto operation) {
      for(unsigned i=0;i<5;++i)operation();
      context->Begin(disjoint.Get());context->End(start.Get());
      for(unsigned i=0;i<30;++i)operation();
      context->End(end.Get());context->End(disjoint.Get());context->Flush();
      D3D11_QUERY_DATA_TIMESTAMP_DISJOINT frequency{};UINT64 first=0,last=0;
      while(context->GetData(disjoint.Get(),&frequency,sizeof(frequency),0)==S_FALSE)Sleep(1);
      assert(!frequency.Disjoint);
      assert(context->GetData(start.Get(),&first,sizeof(first),0)==S_OK);
      assert(context->GetData(end.Get(),&last,sizeof(last),0)==S_OK);
      std::cout<<label<<" GPU ms="<<double(last-first)*1000/double(frequency.Frequency)/30<<'\n';
    };
    measure("Caustic preparation",[&]{assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),shadow_view.Get(),21,{}));});
    context->PSSetShader(original_ps.Get(),nullptr,0);
    measure("Native underwater 4K",[&]{context->Draw(3,0);});
    ComPtr<ID3D11PixelShader> previous_ps;
    if(argc>4) {
      std::ifstream file(argv[4],std::ios::binary);assert(file);
      std::vector<char> code{std::istreambuf_iterator<char>(file),{}};
      assert(SUCCEEDED(device->CreatePixelShader(code.data(),code.size(),nullptr,&previous_ps)));
    }
    for(float quality:{1.f,2.f,4.f}) {
      witcher3classic::water::Underwater::Controls controls;controls.quality[0]=quality;
      assert(pipeline.Prepare(context.Get(),frame_buffer.Get(),light_buffer.Get(),shadow_view.Get(),21,controls));
      assert(pipeline.Bind(context.Get(),21,false,true));context->PSSetShader(custom_ps.Get(),nullptr,0);
      std::cout<<"Sunlight Detail="<<quality<<' ';
      measure("Custom underwater 4K",[&]{context->Draw(3,0);});
      if(previous_ps) {
        context->PSSetShader(previous_ps.Get(),nullptr,0);
        measure("Previous underwater 4K",[&]{context->Draw(3,0);});
      }
      pipeline.Restore(context.Get());
    }
  }
}
