/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Original DXBC versus compiled coverage variants across the audited UI family.
// GPU readback is test-only; no game or NVIDIA runtime is needed.
#include <d3d11.h>
#include <d3dcompiler.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <bit>
#include <cassert>
#include <cmath>
#include <cstdio>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <vector>
#include "../frame_generation/ui_shaders.hpp"
using Microsoft::WRL::ComPtr;
int wmain(int argc, wchar_t** argv) {
  std::setvbuf(stdout, nullptr, _IONBF, 0);
  if (argc != 2) return 2;
  assert(std::is_sorted(std::begin(witcher3classic::frame_generation::ui_shaders), std::end(witcher3classic::frame_generation::ui_shaders),
                        [](const auto& a, const auto& b) { return a.first < b.first; }));
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context)));
  D3D11_TEXTURE2D_DESC desc{8,8,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_RENDER_TARGET};
  std::array<ComPtr<ID3D11Texture2D>,3> targets, staging;
  std::array<ComPtr<ID3D11RenderTargetView>,3> views;
  for (unsigned i=0;i<3;++i) {
    assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&targets[i])));
    assert(SUCCEEDED(device->CreateRenderTargetView(targets[i].Get(),nullptr,&views[i])));
  }
  desc.Usage=D3D11_USAGE_STAGING; desc.BindFlags=0; desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;
  for (auto& texture:staging) assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&texture)));
  std::array<ComPtr<ID3D11Texture2D>,4> textures;
  std::array<ComPtr<ID3D11ShaderResourceView>,4> srvs;
  desc.Usage=D3D11_USAGE_DEFAULT;desc.BindFlags=D3D11_BIND_SHADER_RESOURCE;desc.CPUAccessFlags=0;
  for (unsigned i=0;i<4;++i) {
    assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&textures[i])));
    assert(SUCCEEDED(device->CreateShaderResourceView(textures[i].Get(),nullptr,&srvs[i])));
    auto* srv=srvs[i].Get();context->PSSetShaderResources(i,1,&srv);
  }
  D3D11_SAMPLER_DESC sampler{};
  sampler.Filter=D3D11_FILTER_MIN_MAG_MIP_LINEAR;
  sampler.AddressU=sampler.AddressV=sampler.AddressW=D3D11_TEXTURE_ADDRESS_CLAMP;
  sampler.MaxLOD=D3D11_FLOAT32_MAX;
  ComPtr<ID3D11SamplerState> sampling;
  assert(SUCCEEDED(device->CreateSamplerState(&sampler,&sampling)));
  for (unsigned i=0;i<4;++i) {auto* value=sampling.Get();context->PSSetSamplers(i,1,&value);}
  ComPtr<ID3D11Buffer> constants;
  D3D11_BUFFER_DESC buffer{4096,D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
  assert(SUCCEEDED(device->CreateBuffer(&buffer,nullptr,&constants)));
  auto* cb=constants.Get();context->PSSetConstantBuffers(0,1,&cb);
  D3D11_RASTERIZER_DESC raster{};raster.FillMode=D3D11_FILL_SOLID;raster.CullMode=D3D11_CULL_NONE;raster.DepthClipEnable=TRUE;
  ComPtr<ID3D11RasterizerState> raster_state;
  assert(SUCCEEDED(device->CreateRasterizerState(&raster,&raster_state)));
  context->RSSetState(raster_state.Get());
  const D3D11_VIEWPORT viewport{0,0,8,8,0,1};context->RSSetViewports(1,&viewport);
  context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  unsigned failures=0;
  float worst_error=0;
  for (const auto& [hash,code]:witcher3classic::frame_generation::ui_shaders) {
    char name[40];std::snprintf(name,sizeof(name),"0x%08X.ps_5_0.cso",hash);
    std::ifstream file(std::filesystem::path(argv[1])/name,std::ios::binary);assert(file);
    std::vector<char> bytes((std::istreambuf_iterator<char>(file)),{});
    ComPtr<ID3D11PixelShader> original, replacement;
    assert(SUCCEEDED(device->CreatePixelShader(bytes.data(),bytes.size(),nullptr,&original)));
    assert(SUCCEEDED(device->CreatePixelShader(code.data(),code.size(),nullptr,&replacement)));
    ComPtr<ID3D11ShaderReflection> reflection;
    assert(SUCCEEDED(D3DReflect(bytes.data(),bytes.size(),IID_PPV_ARGS(&reflection))));
    D3D11_SHADER_DESC shader{};assert(SUCCEEDED(reflection->GetDesc(&shader)));
    std::ostringstream fields,assignments;
    for (UINT i=0;i<shader.InputParameters;++i) {
      D3D11_SIGNATURE_PARAMETER_DESC param{};assert(SUCCEEDED(reflection->GetInputParameterDesc(i,&param)));
      assert(param.ComponentType==D3D_REGISTER_COMPONENT_FLOAT32 && param.SystemValueType==D3D_NAME_UNDEFINED);
      const auto count=std::popcount(param.Mask);
      fields<<"float"<<count<<" v"<<i<<":"<<param.SemanticName<<param.SemanticIndex<<";";
      assignments<<"o.v"<<i<<"=float4(.23+uv.x*.13,.37+uv.y*.11,.51,.63)."<<std::string("xyzw",count)<<";";
    }
    const auto source="struct V{"+fields.str()+"float4 pos:SV_Position;};V main(uint id:SV_VertexID){V o;float2 uv=float2(id==1?2:0,id==2?2:0);o.pos=float4(uv*float2(2,-2)+float2(-1,1),0,1);"+assignments.str()+"return o;}";
    ComPtr<ID3DBlob> vs_code,errors;
    const HRESULT compiled=D3DCompile(source.data(),source.size(),nullptr,nullptr,nullptr,"main","vs_5_0",D3DCOMPILE_OPTIMIZATION_LEVEL3,0,&vs_code,&errors);
    if (FAILED(compiled)) {std::printf("VS %s: %s\n",name,errors?static_cast<char*>(errors->GetBufferPointer()):"error");return 1;}
    ComPtr<ID3D11VertexShader> vs;assert(SUCCEEDED(device->CreateVertexShader(vs_code->GetBufferPointer(),vs_code->GetBufferSize(),nullptr,&vs)));
    context->VSSetShader(vs.Get(),nullptr,0);
    bool failed=false;
    for (unsigned scenario=0;scenario<3;++scenario) {
      std::array<float,1024> data;
      for (unsigned i=0;i<data.size();++i) data[i]=.125f*float(1+(i+scenario)%4);
      context->UpdateSubresource(constants.Get(),0,nullptr,data.data(),0,0);
      for (unsigned t=0;t<4;++t) {
        std::array<float,8*8*4> pixels;
        for (unsigned y=0;y<8;++y) for (unsigned x=0;x<8;++x) for (unsigned c=0;c<4;++c)
          pixels[(y*8+x)*4+c]=.1f+.1f*float((x+y+c+t+scenario)%7);
        context->UpdateSubresource(textures[t].Get(),0,nullptr,pixels.data(),8*16,0);
      }
      const float clear[]={-9,-9,-9,-9};for(auto& view:views) context->ClearRenderTargetView(view.Get(),clear);
      auto* baseline=views[0].Get();context->OMSetRenderTargets(1,&baseline,nullptr);
      context->PSSetShader(original.Get(),nullptr,0);context->Draw(3,0);
      ID3D11RenderTargetView* modified[]={views[1].Get(),views[2].Get()};context->OMSetRenderTargets(2,modified,nullptr);
      context->PSSetShader(replacement.Get(),nullptr,0);context->Draw(3,0);
      context->OMSetRenderTargets(0,nullptr,nullptr);
      std::array<D3D11_MAPPED_SUBRESOURCE,3> maps{};
      for(unsigned i=0;i<3;++i) {context->CopyResource(staging[i].Get(),targets[i].Get());assert(SUCCEEDED(context->Map(staging[i].Get(),0,D3D11_MAP_READ,0,&maps[i])));}
      for(unsigned y=0;y<8;++y) for(unsigned x=0;x<8;++x) for(unsigned c=0;c<4;++c) {
        const auto* a=reinterpret_cast<float*>(static_cast<char*>(maps[0].pData)+y*maps[0].RowPitch)+x*4;
        const auto* b=reinterpret_cast<float*>(static_cast<char*>(maps[1].pData)+y*maps[1].RowPitch)+x*4;
        const auto* alpha=reinterpret_cast<float*>(static_cast<char*>(maps[2].pData)+y*maps[2].RowPitch)+x*4;
        const float error=std::abs(a[c]-b[c])/std::max(1.f,std::abs(a[c]));
        worst_error=std::max(worst_error,error);
        failed|=!std::isfinite(a[c]) || !std::isfinite(b[c]) || a[c]==-9 || error>2e-5f
                || !std::isfinite(alpha[c]) || std::abs(alpha[c]-a[3])>2e-5f*std::max(1.f,std::abs(a[3]));
      }
      for(auto& texture:staging) context->Unmap(texture.Get(),0);
    }
    if(failed) {std::printf("FAIL %s\n",name);++failures;}
  }
  std::printf("UI family: %zu shaders x 3 input cases; failures=%u; max relative color error=%.9g\n",std::size(witcher3classic::frame_generation::ui_shaders),failures,worst_error);
  return failures?1:0;
}
