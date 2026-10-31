/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3dcompiler.h>
#include <bit>
#include <iostream>
#include "motion_gpu.hpp"


// Original/native skin linkage plus incoming underwater lighting coverage.
int main(int argc, char** argv) {
  std::cout << std::unitbuf;
  assert(argc == 3 || argc == 4);
  const std::filesystem::path capture = argv[1], originals = argv[2];
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr, argc == 4 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP,
      nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context)));
  const char* vertex_source=R"(
struct V {float4 a:TEXCOORD0;float4 b:TEXCOORD1;float4 c:TEXCOORD2;
float3 d:TEXCOORD3;float3 e:TEXCOORD4;float3 f:TEXCOORD5;float4 p:SV_Position;};
V main(uint id:SV_VertexID){V v=(V)0;float2 uv=float2((id<<1)&2,id&2);
v.p=float4(uv*float2(2,-2)+float2(-1,1),.5,1);
v.a=float4(1,0,1,0);v.b=float4(uv,1,0);v.c=float4(0,0,1,0);
v.d=float3(0,0,1);v.f=float3(1,0,0);return v;})";
  ComPtr<ID3DBlob> vertex_code;
  assert(SUCCEEDED(D3DCompile(vertex_source, strlen(vertex_source), nullptr, nullptr, nullptr,
      "main", "vs_5_0", 0, 0, &vertex_code, nullptr)));
  ComPtr<ID3D11VertexShader> vertex;
  assert(SUCCEEDED(device->CreateVertexShader(vertex_code->GetBufferPointer(), vertex_code->GetBufferSize(), nullptr, &vertex)));
  context->VSSetShader(vertex.Get(), nullptr, 0);
  context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  auto raster_desc = CD3D11_RASTERIZER_DESC(D3D11_DEFAULT);
  raster_desc.CullMode = D3D11_CULL_NONE;
  ComPtr<ID3D11RasterizerState> raster;
  assert(SUCCEEDED(device->CreateRasterizerState(&raster_desc, &raster)));
  context->RSSetState(raster.Get());
  const D3D11_VIEWPORT viewport{0, 0, 64, 64, 0, 1};
  context->RSSetViewports(1, &viewport);
  const D3D11_TEXTURE2D_DESC target_desc{64, 64, 1, 1, DXGI_FORMAT_R16G16B16A16_FLOAT,
      {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_RENDER_TARGET};
  ComPtr<ID3D11Texture2D> target;
  ComPtr<ID3D11RenderTargetView> target_view;
  assert(SUCCEEDED(device->CreateTexture2D(&target_desc, nullptr, &target)));
  assert(SUCCEEDED(device->CreateRenderTargetView(target.Get(), nullptr, &target_view)));
  context->OMSetRenderTargets(1, target_view.GetAddressOf(), nullptr);
  const auto bind_constants = [&](UINT slot, const std::vector<uint8_t>& bytes) {
    auto cb = Buffer(device.Get(), bytes.data(), UINT(bytes.size()), D3D11_BIND_CONSTANT_BUFFER);
    context->PSSetConstantBuffers(slot, 1, cb.GetAddressOf());
  };
  for(UINT slot:{1u,2u,3u,4u}) {
    auto bytes=Read(capture/("skin-forward-cb"+std::to_string(slot)+".bin"));
    bind_constants(slot,bytes);
  }
  const auto bind_texture = [&](UINT slot, std::array<float, 4> value) {
    std::vector<std::array<float, 4>> pixels(64 * 64, value);
    const D3D11_TEXTURE2D_DESC desc{64, 64, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT,
        {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE};
    const D3D11_SUBRESOURCE_DATA initial{pixels.data(), 64 * 16};
    ComPtr<ID3D11Texture2D> texture;
    ComPtr<ID3D11ShaderResourceView> view;
    assert(SUCCEEDED(device->CreateTexture2D(&desc, &initial, &texture)));
    assert(SUCCEEDED(device->CreateShaderResourceView(texture.Get(), nullptr, &view)));
    context->PSSetShaderResources(slot, 1, view.GetAddressOf());
  };
  for(UINT slot:{0u,2u})bind_texture(slot,{.5f,.5f,.75f,1.f});
  bind_texture(1,{.5f,.5f,1.f,.5f});bind_texture(3,{.5f,.5f,1.f,1.f});
  bind_texture(12,{1,1,1,1});bind_texture(18,{1,1,1,1});
  bind_texture(4, {.6f, .4f, .3f, 1.f});
  for (UINT slot : {5u, 22u, 23u, 70u}) bind_texture(slot, {.2f, .25f, .3f, 1.f});
  bind_texture(6, {0, 0, 0, 0});
  bind_texture(17, {1, 1, 1, 1});
  auto sampler_desc = CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
  sampler_desc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
  sampler_desc.AddressU = sampler_desc.AddressV = sampler_desc.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
  ComPtr<ID3D11SamplerState> sampler;
  assert(SUCCEEDED(device->CreateSamplerState(&sampler_desc, &sampler)));
  for (UINT slot = 0; slot < 16; ++slot) context->PSSetSamplers(slot, 1, sampler.GetAddressOf());
  const auto render = [&](const std::vector<uint8_t>& code) {
    ComPtr<ID3D11PixelShader> pixel;
    assert(SUCCEEDED(device->CreatePixelShader(code.data(), code.size(), nullptr, &pixel)));
    context->PSSetShader(pixel.Get(), nullptr, 0);
    context->Draw(3, 0);
    return Pixel(context.Get(), target.Get());
  };
  auto frame=Read(capture/"skin-forward-cb12.bin"),lights=Read(capture/"skin-forward-cb13.bin");
  reinterpret_cast<float*>(frame.data())[0]=0;reinterpret_cast<float*>(frame.data())[1]=0;reinterpret_cast<float*>(frame.data())[2]=3;
  reinterpret_cast<float*>(frame.data())[24*4]=4;
  bind_constants(12,frame);bind_constants(13,lights);
  std::vector<UINT> indices(1024*16,256);
  D3D11_BUFFER_DESC bd{UINT(indices.size()*4),D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS};
  D3D11_SUBRESOURCE_DATA init{indices.data()};ComPtr<ID3D11Buffer> raw;ComPtr<ID3D11ShaderResourceView> raw_view;
  assert(SUCCEEDED(device->CreateBuffer(&bd,&init,&raw)));
  D3D11_SHADER_RESOURCE_VIEW_DESC vd{};vd.Format=DXGI_FORMAT_R32_TYPELESS;vd.ViewDimension=D3D11_SRV_DIMENSION_BUFFEREX;
  vd.BufferEx.NumElements=UINT(indices.size());vd.BufferEx.Flags=D3D11_BUFFEREX_SRV_FLAG_RAW;
  assert(SUCCEEDED(device->CreateShaderResourceView(raw.Get(),&vd,&raw_view)));context->PSSetShaderResources(20,1,raw_view.GetAddressOf());
  auto original=Read(originals/"0x20C1C070.ps_5_0.cso");auto replacement=Read("build/thewitcher3classic.include/embed/0xF3C40011.cso");
  auto native=render(original),above=render(replacement);
  for(unsigned c=0;c<4;++c)assert(std::isfinite(above[c]) &&std::abs(native[c]-above[c])<.002f);
  assert(above[0]+above[1]+above[2]>.001f);
  std::array<std::array<float,4>,8> water{};water[0]={0,0,-2,1};water[1]={0,0,1,10};water[2]={.1f,.2f,.3f,0};
  water[5]={-32,-32,64,512};water[6]={.25f,2,8,32};
  bd={sizeof(water),D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_STRUCTURED,16};init={water.data()};
  ComPtr<ID3D11Buffer> state;ComPtr<ID3D11ShaderResourceView> state_view;
  assert(SUCCEEDED(device->CreateBuffer(&bd,&init,&state)));assert(SUCCEEDED(device->CreateShaderResourceView(state.Get(),nullptr,&state_view)));
  context->PSSetShaderResources(88,1,state_view.GetAddressOf());auto below=render(replacement);
  std::cout<<"skin native="<<above[0]<<","<<above[1]<<","<<above[2]<<" underwater="<<below[0]<<","<<below[1]<<","<<below[2]<<'\n';
  for(unsigned c=0;c<3;++c)assert(std::isfinite(below[c]) &&below[c]<above[c]);
  assert(below[3]==above[3]);
  ID3D11ShaderResourceView* empty=nullptr;context->PSSetShaderResources(88,1,&empty);
  auto restored=render(replacement);for(unsigned c=0;c<4;++c)assert(restored[c]==above[c]);
  std::cout<<"PASS native forward skin RGBA, underwater incoming-light attenuation and restoration with motion vectors off\n";
}
