/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3dcompiler.h>
#include <bit>
#include <iostream>
#include "motion_gpu.hpp"
#include "../lighting/player_fill.hpp"

// Replay the uncovered native skin material with controlled, HDR fill lights.
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
float4 d:TEXCOORD3;float4 e:TEXCOORD4;float4 f:TEXCOORD5;
float4 g:TEXCOORD6;float3 h:TEXCOORD7;float4 p:SV_Position;};
V main(uint id:SV_VertexID){V v=(V)0;float2 uv=float2((id<<1)&2,id&2);
v.p=float4(uv*float2(2,-2)+float2(-1,1),.5,1);
v.b=float4(.5,.5,1,0);v.c=float4(0,0,.5,1);
v.e=float4(0,.5,.5,0);v.f=float4(0,1,0,1);v.h=float3(1,0,0);return v;})";
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
    auto bytes=Read(capture/("skin-b"+std::to_string(slot)+".bin"));
    if(slot==2){bytes.resize(19*16);std::fill_n(reinterpret_cast<float*>(bytes.data())+18*4,4,0.f);}
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
  using namespace witcher3classic::lighting;
  // Deliberately use the original uncovered DXBC. The fix must reach it
  // without a shader replacement, extra varying or motion-vector prerequisite.
  const auto native=Read(originals/"0xF1FB6FB1.ps_5_0.cso");
  auto frame=Read(capture/"skin-b12.bin"),lights=Read(capture/"skin-b13.bin");
  auto* common=reinterpret_cast<float*>(frame.data());
  auto* light=reinterpret_cast<float*>(lights.data());
  common[0]=common[1]=0;common[2]=3;
  common[24*4]=4;common[69*4]=1;common[69*4+1]=0;common[69*4+2]=1;
  common[183*4]=common[183*4+1]=0;common[183*4+2]=common[183*4+3]=1;
  common[184*4]=common[184*4+1]=0;
  for(UINT row:{1u,51u,52u})for(UINT c=0;c<3;++c)light[row*4+c]=0;
  const UINT count=1;std::memcpy(light+57*4,&count,4);
  std::fill_n(light+58*4,9*4,0.f);
  light[58*4]=.5f;light[58*4+2]=2;light[58*4+3]=10;
  light[61*4]=16;light[61*4+1]=8;light[61*4+2]=4;
  std::vector<uint32_t> indices(256*1024,256);
  for(UINT tile=0;tile<1024;++tile)indices[tile*256]=0;
  ComPtr<ID3D11Buffer> raw;ComPtr<ID3D11ShaderResourceView> raw_view;
  D3D11_BUFFER_DESC raw_desc{UINT(indices.size()*4),D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS};
  const D3D11_SUBRESOURCE_DATA raw_data{indices.data()};
  assert(SUCCEEDED(device->CreateBuffer(&raw_desc,&raw_data,&raw)));
  D3D11_SHADER_RESOURCE_VIEW_DESC raw_view_desc{};raw_view_desc.Format=DXGI_FORMAT_R32_TYPELESS;
  raw_view_desc.ViewDimension=D3D11_SRV_DIMENSION_BUFFEREX;raw_view_desc.BufferEx.NumElements=UINT(indices.size());raw_view_desc.BufferEx.Flags=D3D11_BUFFEREX_SRV_FLAG_RAW;
  assert(SUCCEEDED(device->CreateShaderResourceView(raw.Get(),&raw_view_desc,&raw_view)));
  context->PSSetShaderResources(20,1,raw_view.GetAddressOf());
  auto material=Read(capture/"skin-b2.bin");material.resize(19*16);
  std::fill_n(reinterpret_cast<float*>(material.data())+18*4,4,0.f);
  std::array<float,0xb400/4> environment{};
  const auto* env=reinterpret_cast<const uint8_t*>(environment.data());
  bool detects_gap=false,has_hdr=false;
  for(UINT flags:{0x1800u,0x80001800u,0x80001801u})for(float gain:{0.f,.25f,1.f,2.f}) {
    std::memcpy(light+61*4+3,&flags,4);common[71*4]=gain;environment[0x404c/4]=gain;
    // Additional flag bit is a spot light; choose a constant open cone.
    light[60*4+2]=-1;light[62*4+2]=1;light[62*4+3]=1;
    std::array<float,4> unified_character{};
    for(float recipient:{-1.f,1.f}) {
      reinterpret_cast<float*>(material.data())[16*4]=recipient;
      bind_constants(2,material);
      auto draw=[&](const player_fill::Controls& controls) {
        auto f=frame,l=lights;
        player_fill::ApplyCommon(f.data(),controls);
        if(flags&0x80000000u)player_fill::ApplyCameraLight(l.data()+0x3a0,env+0x10,env+0xb148,env+0x3960,nullptr,controls);
        bind_constants(12,f);bind_constants(13,l);return render(native);
      };
      const auto original=draw({false,false,1.f}),off=draw({true,false,0.f});
      for(float strength:{.2f,.5f,1.f}) {
        const auto scaled=draw({true,false,strength});
        for(UINT c=0;c<4;++c) {
          assert(std::isfinite(original[c])&&std::isfinite(scaled[c]));
          if(c==3||!(flags&0x80000000u))assert(std::abs(scaled[c]-original[c])<.002f);
          else assert(std::abs(scaled[c]-(off[c]+strength*(original[c]-off[c])))<.005f);
          detects_gap|=c<3&&(flags&0x80000000u)&&std::abs(scaled[c]-original[c])>.05f;
          has_hdr|=c<3&&scaled[c]>1.f;
        }
      }
      const auto unified=draw({true,true,.2f});
      for(float c:unified)assert(std::isfinite(c));
      if(flags&0x80000000u) {
        if(recipient<0)unified_character=unified;
        else for(UINT c=0;c<4;++c)assert(std::abs(unified[c]-unified_character[c])<.005f);
      }
      std::cout<<"Native skin F1FB6FB1 flags="<<std::hex<<flags<<std::dec<<" gain="<<gain<<" recipient="<<recipient<<" native="<<original[0]<<" scaled="<<draw({true,false,.2f})[0]<<'\n';
    }
  }
  // Replay the exact scene-fill compute shader observed twice in the live
  // cutscene. It overwrites the bank RGB from two exposure-selected colours,
  // which is why scaling the bank before the dispatch did not cover scenes.
  const auto scene_code=Read(originals/"0x0E9BEC7A.cs_5_0.cso");
  ComPtr<ID3D11ComputeShader> scene_shader;
  assert(SUCCEEDED(device->CreateComputeShader(scene_code.data(),scene_code.size(),nullptr,&scene_shader)));
  context->CSSetShader(scene_shader.Get(),nullptr,0);
  std::array<uint32_t,0x500/4> initial;
  initial.fill(0x12345678u);
  D3D11_BUFFER_DESC bank_desc{UINT(sizeof(initial)),D3D11_USAGE_DEFAULT,D3D11_BIND_UNORDERED_ACCESS,
      0,D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS,0};
  const D3D11_SUBRESOURCE_DATA bank_data{initial.data()};
  ComPtr<ID3D11Buffer> scene_bank,staging;
  assert(SUCCEEDED(device->CreateBuffer(&bank_desc,&bank_data,&scene_bank)));
  D3D11_UNORDERED_ACCESS_VIEW_DESC uav_desc{};uav_desc.Format=DXGI_FORMAT_R32_TYPELESS;
  uav_desc.ViewDimension=D3D11_UAV_DIMENSION_BUFFER;
  uav_desc.Buffer.NumElements=UINT(initial.size());uav_desc.Buffer.Flags=D3D11_BUFFER_UAV_FLAG_RAW;
  ComPtr<ID3D11UnorderedAccessView> scene_uav;
  assert(SUCCEEDED(device->CreateUnorderedAccessView(scene_bank.Get(),&uav_desc,&scene_uav)));
  bank_desc.Usage=D3D11_USAGE_STAGING;bank_desc.BindFlags=bank_desc.MiscFlags=0;bank_desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  assert(SUCCEEDED(device->CreateBuffer(&bank_desc,nullptr,&staging)));
  const std::array<float,8> scene_colors={6.809904f,7.86273f,7.86273f,.2f,3.931306f,3.342363f,2.093967f,.2f};
  size_t scene_cases=0;
  for(float exposure:{0.f,.5f,1.f})for(float strength:{0.f,.2f,1.f})
    for(float cutscene:{0.f,.2f,.5f,1.f})for(float gain:{0.f,.25f,1.f,2.f})for(bool unify:{false,true})for(bool enabled:{false,true}) {
      const D3D11_TEXTURE2D_DESC exposure_desc{1,1,1,1,DXGI_FORMAT_R32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE};
      const D3D11_SUBRESOURCE_DATA exposure_data{&exposure,4};
      ComPtr<ID3D11Texture2D> exposure_texture;ComPtr<ID3D11ShaderResourceView> exposure_view;
      assert(SUCCEEDED(device->CreateTexture2D(&exposure_desc,&exposure_data,&exposure_texture)));
      assert(SUCCEEDED(device->CreateShaderResourceView(exposure_texture.Get(),nullptr,&exposure_view)));
      context->CSSetShaderResources(0,1,exposure_view.GetAddressOf());
      std::array<float,36> record{};auto colors=scene_colors;
      environment[0x404c/4]=gain;
      player_fill::ApplyCameraLight(record.data(),env+0x10,env+0xb0e8,env+0x3b00,colors.data(),{enabled,unify,strength,cutscene});
      assert(colors[3]==scene_colors[3]&&colors[7]==scene_colors[7]);
      context->UpdateSubresource(scene_bank.Get(),0,nullptr,initial.data(),0,0);
      for(unsigned second=0;second<2;++second) {
        std::array<float,12> constants{};constants[0]=float(0x3d0+second*0x90);
        std::copy(colors.begin(),colors.end(),constants.begin()+4);
        auto cb=Buffer(device.Get(),constants.data(),sizeof(constants),D3D11_BIND_CONSTANT_BUFFER);
        context->CSSetConstantBuffers(0,1,cb.GetAddressOf());
        context->CSSetUnorderedAccessViews(0,1,scene_uav.GetAddressOf(),nullptr);
        context->Dispatch(1,1,1);
        ID3D11UnorderedAccessView* none=nullptr;context->CSSetUnorderedAccessViews(0,1,&none,nullptr);
      }
      context->CopyResource(staging.Get(),scene_bank.Get());
      D3D11_MAPPED_SUBRESOURCE mapped{};assert(SUCCEEDED(context->Map(staging.Get(),0,D3D11_MAP_READ,0,&mapped)));
      const auto* words=static_cast<const uint32_t*>(mapped.pData);
      const unsigned selected=exposure>.5f?0:4;
      const float scale=enabled?cutscene*(unify?gain:1.f):1.f;
      for(unsigned i=0;i<initial.size();++i) {
        const unsigned local=i>=0x460/4?i-0x460/4:i>=0x3d0/4?i-0x3d0/4:4;
        if(local<3)assert(std::abs(std::bit_cast<float>(words[i])-scene_colors[selected+local]*scale)<.00001f);
        else assert(words[i]==initial[i]);
      }
      context->Unmap(staging.Get(),0);++scene_cases;
    }
  std::cout<<"PASS "<<scene_cases<<" original scene-fill compute cases: independent cutscene strength, both exposure choices, two bank offsets, native bypass, matching, RGB-only HDR and untouched metadata\n";
  assert(detects_gap&&has_hdr);
  std::cout<<"PASS original uncovered skin DXBC: native identity, full/20%/50% strengths, world-light identity, matching across receiver types, shadow/shape flags, HDR and regression detects missing scaling\n";
}
