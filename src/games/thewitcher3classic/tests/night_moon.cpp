/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <d3d11.h>
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
#include "../darker_nights.hpp"

using Microsoft::WRL::ComPtr;
int main(int argc, char** argv) {
  try {
    if (argc < 2) return 2;
    auto check = [](HRESULT result) { if (FAILED(result)) throw std::runtime_error(std::to_string(result)); };
    auto read = [](const std::filesystem::path& path) {
      std::ifstream file(path, std::ios::binary);
      if (!file) throw std::runtime_error(path.string());
      return std::vector<char>{std::istreambuf_iterator<char>(file), {}};
    };
    ComPtr<ID3D11Device> device; ComPtr<ID3D11DeviceContext> context;
    check(D3D11CreateDevice(nullptr, argc > 2 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP,
                           nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context));
    {
      using namespace witcher3classic::night;
      std::array<float,269*4> source{}, expected{};
      for(size_t i=0;i<source.size();++i)source[i]=float(i+1)*.125f;
      source[37*4+3]=0;source[39*4]=4096.f;
      const Controls controls{.schedule=NightSchedule(),.ambient_light=.25f,.ambient_shadow=.5f,
          .reflection_light=.75f,.reflection_shadow=0,.fog=.125f,.haze=.25f,.sky=.5f,
          .moon_brightness=2,.moon_size=5};
      D3D11_BUFFER_DESC desc{sizeof(source),D3D11_USAGE_DYNAMIC,D3D11_BIND_CONSTANT_BUFFER,D3D11_CPU_ACCESS_WRITE};
      ComPtr<ID3D11Buffer> upload,readback;check(device->CreateBuffer(&desc,nullptr,&upload));
      desc.Usage=D3D11_USAGE_STAGING;desc.BindFlags=0;desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
      check(device->CreateBuffer(&desc,nullptr,&readback));
      D3D11_MAPPED_SUBRESOURCE mapped{};check(context->Map(upload.Get(),0,D3D11_MAP_WRITE_DISCARD,0,&mapped));
      {
        CommonUpload scope(controls,0.f);
        std::memcpy(scope.Redirect(mapped.pData,1),source.data(),sizeof(source));
        scope.Publish();
      }
      context->Unmap(upload.Get(),0);context->CopyResource(readback.Get(),upload.Get());
      check(context->Map(readback.Get(),0,D3D11_MAP_READ,0,&mapped));
      expected=source;ApplyCommon(expected.data(),controls,0.f);
      const bool identical=std::memcmp(mapped.pData,expected.data(),sizeof(expected))==0;
      context->Unmap(readback.Get(),0);
      if(!identical)throw std::runtime_error("GPU common upload lost HDR/alpha/tag bits");
      std::cout<<"PASS real D3D11 WRITE_DISCARD shadow upload, HDR/alpha/tag byte preservation\n";
    }
    constexpr unsigned W = 64, H = 64;
    const D3D11_TEXTURE2D_DESC target_desc{W,H,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_RENDER_TARGET};
    ComPtr<ID3D11Texture2D> target, staging; check(device->CreateTexture2D(&target_desc,nullptr,&target));
    ComPtr<ID3D11RenderTargetView> rtv; check(device->CreateRenderTargetView(target.Get(),nullptr,&rtv));
    context->OMSetRenderTargets(1,rtv.GetAddressOf(),nullptr);
    auto staging_desc=target_desc;staging_desc.Usage=D3D11_USAGE_STAGING;staging_desc.BindFlags=0;staging_desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
    check(device->CreateTexture2D(&staging_desc,nullptr,&staging));
    const D3D11_VIEWPORT viewport{0,0,float(W),float(H),0,1};context->RSSetViewports(1,&viewport);
    D3D11_RASTERIZER_DESC raster{};raster.FillMode=D3D11_FILL_SOLID;raster.CullMode=D3D11_CULL_NONE;raster.DepthClipEnable=TRUE;
    ComPtr<ID3D11RasterizerState> rs;check(device->CreateRasterizerState(&raster,&rs));context->RSSetState(rs.Get());
    struct Vertex { float position[3], uv[2], normal[3], tangent[4]; };
    std::array<Vertex,6> vertices{};
    unsigned indices[]={0,1,2,2,1,3};
    for(unsigned i=0;i<6;++i) {
      const unsigned x=indices[i]&1,y=indices[i]>>1;
      vertices[i]={{float(x),float(y),0},{float(x),float(y)},{.5f,.5f,0},{1,.5f,.5f,1}};
    }
    D3D11_BUFFER_DESC vertices_desc{sizeof(vertices),D3D11_USAGE_IMMUTABLE,D3D11_BIND_VERTEX_BUFFER};
    D3D11_SUBRESOURCE_DATA vertices_data{vertices.data()};ComPtr<ID3D11Buffer> vb;
    check(device->CreateBuffer(&vertices_desc,&vertices_data,&vb));UINT stride=sizeof(Vertex),offset=0;
    context->IASetVertexBuffers(0,1,vb.GetAddressOf(),&stride,&offset);context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    auto buffer = [&](bool vertex, unsigned slot, const auto& values) {
      D3D11_BUFFER_DESC desc{UINT(values.size()*sizeof(float)),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
      D3D11_SUBRESOURCE_DATA data{values.data()};ComPtr<ID3D11Buffer> result;check(device->CreateBuffer(&desc,&data,&result));
      if(vertex)context->VSSetConstantBuffers(slot,1,result.GetAddressOf());else context->PSSetConstantBuffers(slot,1,result.GetAddressOf());
      return result;
    };
    std::array<float,16> matrix{};for(unsigned i=0;i<4;++i)matrix[i*5]=1;buffer(true,1,matrix);
    std::array<float,24> model{};model[0]=model[5]=model[10]=model[15]=1;model[16]=model[17]=2;model[20]=model[21]=-1;model[22]=1;buffer(true,2,model);
    std::array<float,36> camera{};buffer(false,1,camera);
    std::array<float,12> material{2,4,8,1,0,0,0,0,1,1,1,1};buffer(false,2,material);
    std::array<float,4> global{};buffer(false,0,global);
    std::array<float,269*4> frame{};
    frame[22*4+2]=.1f;frame[42*4]=1;frame[42*4+2]=1000;frame[42*4+3]=1;
    frame[48*4]=1;frame[48*4+1]=-1;frame[48*4+2]=1;frame[266*4]=2;frame[266*4+1]=4;frame[266*4+2]=8;
    auto common=buffer(true,12,frame);context->PSSetConstantBuffers(12,1,common.GetAddressOf());
    const std::array<float,4> texel{1,1,1,1};D3D11_SUBRESOURCE_DATA texture_data{texel.data(),16,0};
    const D3D11_TEXTURE2D_DESC texture_desc{1,1,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_IMMUTABLE,D3D11_BIND_SHADER_RESOURCE};
    ComPtr<ID3D11Texture2D> texture;ComPtr<ID3D11ShaderResourceView> view;check(device->CreateTexture2D(&texture_desc,&texture_data,&texture));check(device->CreateShaderResourceView(texture.Get(),nullptr,&view));context->PSSetShaderResources(0,1,view.GetAddressOf());
    D3D11_SAMPLER_DESC sampler_desc{};sampler_desc.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;sampler_desc.AddressU=sampler_desc.AddressV=sampler_desc.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;sampler_desc.MaxLOD=D3D11_FLOAT32_MAX;
    ComPtr<ID3D11SamplerState> sampler;check(device->CreateSamplerState(&sampler_desc,&sampler));context->PSSetSamplers(0,1,sampler.GetAddressOf());
    for(const auto& [vertex_hash,pixel_hash]:{std::pair{"0x910C4B43","0x8C9C55EC"},std::pair{"0x3939C615","0x89760976"}}) {
      const auto original_vertex=read(std::filesystem::path(argv[1])/(std::string(vertex_hash)+".vs_5_0.cso"));
      const auto original_pixel=read(std::filesystem::path(argv[1])/(std::string(pixel_hash)+".ps_5_0.cso"));
      const auto production_vertex=read(std::filesystem::path("build/thewitcher3classic.include/embed")/(std::string(vertex_hash)+".cso"));
      const auto production_pixel=read(std::filesystem::path("build/thewitcher3classic.include/embed")/(std::string(pixel_hash)+".cso"));
      const D3D11_INPUT_ELEMENT_DESC elements[]={{"POSITION",0,DXGI_FORMAT_R32G32B32_FLOAT,0,0,D3D11_INPUT_PER_VERTEX_DATA,0},{"TEXCOORD",0,DXGI_FORMAT_R32G32_FLOAT,0,12,D3D11_INPUT_PER_VERTEX_DATA,0},{"NORMAL",0,DXGI_FORMAT_R32G32B32_FLOAT,0,20,D3D11_INPUT_PER_VERTEX_DATA,0},{"TANGENT",0,DXGI_FORMAT_R32G32B32A32_FLOAT,0,32,D3D11_INPUT_PER_VERTEX_DATA,0}};
      ComPtr<ID3D11InputLayout> layout;check(device->CreateInputLayout(elements,4,original_vertex.data(),original_vertex.size(),&layout));context->IASetInputLayout(layout.Get());
      auto render = [&](bool original, uint32_t tag) {
        std::memcpy(&frame[37*4+3],&tag,4);context->UpdateSubresource(common.Get(),0,nullptr,frame.data(),0,0);
        const auto& vs=(original?original_vertex:production_vertex);const auto& ps=(original?original_pixel:production_pixel);
        ComPtr<ID3D11VertexShader> vertex;ComPtr<ID3D11PixelShader> pixel;check(device->CreateVertexShader(vs.data(),vs.size(),nullptr,&vertex));check(device->CreatePixelShader(ps.data(),ps.size(),nullptr,&pixel));
        context->VSSetShader(vertex.Get(),nullptr,0);context->PSSetShader(pixel.Get(),nullptr,0);
        const float clear[4]{};context->ClearRenderTargetView(rtv.Get(),clear);context->Draw(6,0);context->CopyResource(staging.Get(),target.Get());
        D3D11_MAPPED_SUBRESOURCE mapped{};check(context->Map(staging.Get(),0,D3D11_MAP_READ,0,&mapped));std::vector<float> values(W*H*4);
        for(unsigned y=0;y<H;++y)std::memcpy(values.data()+y*W*4,static_cast<const char*>(mapped.pData)+y*mapped.RowPitch,W*16);
        context->Unmap(staging.Get(),0);return values;
      };
      const auto original=render(true,0);const auto neutral=render(false,0);
      float baseline_error=0,peak=0;unsigned full_coverage=0;
      for(size_t i=0;i<original.size();++i) {
        if(!std::isfinite(original[i])||!std::isfinite(neutral[i]))throw std::runtime_error("Nonfinite moon baseline");
        baseline_error=std::max(baseline_error,std::abs(original[i]-neutral[i]));peak=std::max(peak,original[i]);
        if(i%4==0&&original[i]>1.e-6f)++full_coverage;
      }
      if(peak<=0 ||baseline_error>2.e-4f)throw std::runtime_error("Moon baseline mismatch or empty fixture: "+std::to_string(peak)+", "+std::to_string(baseline_error));
      for(unsigned brightness:{0u,1023u,2046u}) {
        auto actual=render(false,0xd5000000u|(brightness<<13)|1024u);float maximum=0;
        for(size_t i=0;i<actual.size();++i) {
          const float expected=(i%4==3?original[i]:original[i]*brightness/1023.f);
          maximum=std::max(maximum,std::abs(actual[i]-expected));
        }
        if(maximum>5.e-4f*std::max(peak,1.f))throw std::runtime_error("Moon brightness/alpha differs from native reference");
      }
      const auto reduced=render(false,0xd5000000u|(1023u<<13)|512u);unsigned small_coverage=0;
      for(size_t i=0;i<reduced.size();i+=4)if(reduced[i]>1.e-6f)++small_coverage;
      const float area=float(small_coverage)/full_coverage;
      if(std::abs(area-.25f)>.01f)throw std::runtime_error("Half-size moon did not cover one quarter of native area: "+std::to_string(area));
      std::cout<<"PASS "<<vertex_hash<<" / "<<pixel_hash<<": native max error="<<baseline_error<<", HDR peak="<<peak<<", 0/100/200% brightness, half-size area="<<area<<'\n';
    }
  } catch(const std::exception& error) {std::cerr<<error.what()<<'\n';return 1;}
}
