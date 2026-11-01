/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Differential native-bytecode check for the additional cloud receiver pixels.
#include <d3dcompiler.h>
#include <algorithm>
#include <bit>
#include <iostream>
#include <sstream>
#include "motion_gpu.hpp"
int main(int argc,char**) {
  ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,
      nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&context)));
  using Reflect=HRESULT(WINAPI*)(const void*,SIZE_T,REFIID,void**);
  auto reflect=reinterpret_cast<Reflect>(GetProcAddress(LoadLibraryW(L"d3dcompiler_47.dll"),"D3DReflect"));
  auto common=Read("tmp/witcher3classic-investigation/object-lighting-20261026/candidate-31524/hair-constantBuffers-12.bin");
  auto light=Read("tmp/witcher3classic-investigation/object-lighting-20261026/candidate-31524/hair-constantBuffers-13.bin");
  std::fill_n(reinterpret_cast<float*>(light.data())+57*4,4,0.f);
  ComPtr<ID3D11Buffer> common_buffer=Buffer(device.Get(),common.data(),UINT(common.size()),D3D11_BIND_CONSTANT_BUFFER),
      light_buffer=Buffer(device.Get(),light.data(),UINT(light.size()),D3D11_BIND_CONSTANT_BUFFER);
  context->PSSetConstantBuffers(12,1,common_buffer.GetAddressOf());context->PSSetConstantBuffers(13,1,light_buffer.GetAddressOf());
  ComPtr<ID3D11Texture2D> target;ComPtr<ID3D11RenderTargetView> target_view;
  D3D11_TEXTURE2D_DESC td{32,32,1,1,DXGI_FORMAT_R16G16B16A16_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_RENDER_TARGET};
  assert(SUCCEEDED(device->CreateTexture2D(&td,nullptr,&target)));assert(SUCCEEDED(device->CreateRenderTargetView(target.Get(),nullptr,&target_view)));
  context->OMSetRenderTargets(1,target_view.GetAddressOf(),nullptr);
  const D3D11_VIEWPORT viewport{0,0,32,32,0,1};context->RSSetViewports(1,&viewport);
  context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  D3D11_RASTERIZER_DESC raster=CD3D11_RASTERIZER_DESC(D3D11_DEFAULT);raster.CullMode=D3D11_CULL_NONE;
  ComPtr<ID3D11RasterizerState> raster_state;assert(SUCCEEDED(device->CreateRasterizerState(&raster,&raster_state)));context->RSSetState(raster_state.Get());
  auto texture=[&](UINT layers,UINT flags) {
    std::vector<std::vector<std::array<float,4>>> pixels;std::vector<D3D11_SUBRESOURCE_DATA> data;
    for(UINT layer=0;layer<layers;++layer)for(UINT mip=0;mip<4;++mip) {
      UINT w=std::max(1u,8u>>mip);pixels.emplace_back(w*w);
      for(UINT y=0;y<w;++y)for(UINT x=0;x<w;++x)pixels.back()[y*w+x]={.3f+.2f*x/w,.4f+.2f*y/w,.7f,1};
      data.push_back({pixels.back().data(),w*16});
    }
    D3D11_TEXTURE2D_DESC desc{8,8,4,layers,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,flags};
    ComPtr<ID3D11Texture2D> resource;assert(SUCCEEDED(device->CreateTexture2D(&desc,data.data(),&resource)));
    ComPtr<ID3D11ShaderResourceView> view;assert(SUCCEEDED(device->CreateShaderResourceView(resource.Get(),nullptr,&view)));return view;
  };
  auto flat=texture(1,0),array=texture(8,0),cube=texture(6,D3D11_RESOURCE_MISC_TEXTURECUBE),cubes=texture(12,D3D11_RESOURCE_MISC_TEXTURECUBE);
  // A single cube needs an explicit array view when the shader expects cubes.
  D3D11_SAMPLER_DESC sampler=CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
  sampler.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D11_TEXTURE_ADDRESS_WRAP;
  ComPtr<ID3D11SamplerState> linear;assert(SUCCEEDED(device->CreateSamplerState(&sampler,&linear)));
  for(UINT i=0;i<16;++i)context->PSSetSamplers(i,1,linear.GetAddressOf());
  sampler.Filter=D3D11_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT;sampler.ComparisonFunc=D3D11_COMPARISON_LESS_EQUAL;
  ComPtr<ID3D11SamplerState> comparison;assert(SUCCEEDED(device->CreateSamplerState(&sampler,&comparison)));
  context->PSSetSamplers(9,1,comparison.GetAddressOf());
  std::vector<UINT> raw_pixels(1024*1024,0);
  D3D11_BUFFER_DESC raw_desc{UINT(raw_pixels.size()*4),D3D11_USAGE_DEFAULT,D3D11_BIND_SHADER_RESOURCE,0,D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS};
  D3D11_SUBRESOURCE_DATA initial{raw_pixels.data()};ComPtr<ID3D11Buffer> raw;
  assert(SUCCEEDED(device->CreateBuffer(&raw_desc,&initial,&raw)));
  D3D11_SHADER_RESOURCE_VIEW_DESC raw_view_desc{};raw_view_desc.Format=DXGI_FORMAT_R32_TYPELESS;raw_view_desc.ViewDimension=D3D11_SRV_DIMENSION_BUFFEREX;
  raw_view_desc.BufferEx.NumElements=UINT(raw_pixels.size());raw_view_desc.BufferEx.Flags=D3D11_BUFFEREX_SRV_FLAG_RAW;
  ComPtr<ID3D11ShaderResourceView> raw_view;assert(SUCCEEDED(device->CreateShaderResourceView(raw.Get(),&raw_view_desc,&raw_view)));
  context->PSSetShaderResources(20,1,raw_view.GetAddressOf());context->PSSetShaderResources(21,1,raw_view.GetAddressOf());
  const std::filesystem::path natives="tmp/witcher3classic-investigation/volumetric-clouds-20261031/native";
  UINT total=0;
  for(const auto& entry:std::filesystem::directory_iterator("src/games/thewitcher3classic/clouds/receivers")) {
    auto name=entry.path().filename().string();if(name.find(".ps_5_0.hlsl")==std::string::npos)continue;
    auto original=Read(natives/(name.substr(0,10)+".ps_5_0.cso"));
    auto replacement=Read(std::filesystem::path("build/thewitcher3classic.include/embed")/(name.substr(0,10)+".cso"));
    ComPtr<ID3D11ShaderReflection> reflection;assert(SUCCEEDED(reflect(original.data(),original.size(),__uuidof(ID3D11ShaderReflection),&reflection)));
    D3D11_SHADER_DESC desc{};reflection->GetDesc(&desc);
    std::ostringstream source;source<<"struct V {float4 p:SV_Position;";
    std::vector<D3D11_SIGNATURE_PARAMETER_DESC> inputs;
    for(UINT i=0;i<desc.InputParameters;++i) {
      D3D11_SIGNATURE_PARAMETER_DESC input{};reflection->GetInputParameterDesc(i,&input);
      if(input.SystemValueType!=D3D_NAME_UNDEFINED)continue;
      inputs.push_back(input);
      const char* type=input.ComponentType==D3D_REGISTER_COMPONENT_UINT32?"nointerpolation uint4":input.ComponentType==D3D_REGISTER_COMPONENT_SINT32?"nointerpolation int4":"float4";
      source<<type<<" a"<<inputs.size()-1<<":"<<input.SemanticName<<input.SemanticIndex<<";";
    }
    source<<"}; V main(uint id:SV_VertexID) {V v;float2 uv=float2((id<<1)&2,id&2);v.p=float4(uv*float2(2,-2)+float2(-1,1),.5,1);";
    for(UINT i=0;i<inputs.size();++i)source<<"v.a"<<i<<"="<<(inputs[i].ComponentType==D3D_REGISTER_COMPONENT_FLOAT32?"float4(.3,.5,.8,1)":"1")<<";";
    source<<"return v;}";
    ComPtr<ID3DBlob> vs_code,errors;auto text=source.str();
    HRESULT compile=D3DCompile(text.data(),text.size(),nullptr,nullptr,nullptr,"main","vs_5_0",D3DCOMPILE_ENABLE_STRICTNESS,0,&vs_code,&errors);
    if(FAILED(compile)&&errors)std::cerr<<static_cast<const char*>(errors->GetBufferPointer());assert(SUCCEEDED(compile));
    ComPtr<ID3D11VertexShader> vertex;assert(SUCCEEDED(device->CreateVertexShader(vs_code->GetBufferPointer(),vs_code->GetBufferSize(),nullptr,&vertex)));
    context->VSSetShader(vertex.Get(),nullptr,0);
    BindMaterialInputs(context.Get(),original,flat.Get(),array.Get(),cube.Get(),cubes.Get());
    std::vector<float> material(4096,.5f);
    for(UINT slot=0;slot<12;++slot) {
      auto buffer=Buffer(device.Get(),material.data(),UINT(material.size()*4),D3D11_BIND_CONSTANT_BUFFER);
      context->PSSetConstantBuffers(slot,1,buffer.GetAddressOf());
    }
    const auto render=[&](const auto& code) {
      ComPtr<ID3D11PixelShader> pixel;assert(SUCCEEDED(device->CreatePixelShader(code.data(),code.size(),nullptr,&pixel)));
      const float clear[]{-1,-2,-3,-4};context->ClearRenderTargetView(target_view.Get(),clear);
      context->PSSetShader(pixel.Get(),nullptr,0);context->Draw(3,0);return Pixel(context.Get(),target.Get());
    };
    auto a=render(original),b=render(replacement);UINT failures=0;
    for(UINT i=0;i<4;++i)if(!SameColor(a[i],b[i]))++failures;
    std::cout<<name.substr(0,10)<<" native="<<a[0]<<","<<a[1]<<","<<a[2]<<","<<a[3]
        <<" replacement="<<b[0]<<","<<b[1]<<","<<b[2]<<","<<b[3]<<" failures="<<failures<<'\n'<<std::flush;
    total+=failures;
  }
  return total ? 1 : 0;
}
