/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Include the real registration table: isolated pixel-shader replay cannot
// detect an injection callback overwriting a later native vertex shader's b13.
#include "../addon.cpp"
#include <d3dcompiler.h>
#include <iostream>
#include <stdexcept>

int main(int argc, char**) {
  using Microsoft::WRL::ComPtr;
  using namespace witcher3classic::night;
  try {
    auto check=[](HRESULT hr){if(FAILED(hr))throw std::runtime_error(std::to_string(hr));};
    ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> context;
    check(D3D11CreateDevice(nullptr,argc>1?D3D_DRIVER_TYPE_HARDWARE:D3D_DRIVER_TYPE_WARP,nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&context));
    std::array<float,3323*4> lighting{};lighting[4]=2;lighting[5]=4;lighting[6]=8;
    D3D11_BUFFER_DESC buffer_desc{sizeof(lighting),D3D11_USAGE_DEFAULT,D3D11_BIND_CONSTANT_BUFFER};
    D3D11_SUBRESOURCE_DATA data{lighting.data()};ComPtr<ID3D11Buffer> native,injection;
    check(device->CreateBuffer(&buffer_desc,&data,&native));
    buffer_desc.ByteWidth=sizeof(shader_injection);data.pSysMem=&shader_injection;
    check(device->CreateBuffer(&buffer_desc,&data,&injection));
    // Both stages consume the native slot, as do the game's native forward
    // vertex/pixel shaders. Keep HDR values above one in the downstream draw.
    const char* vertex=R"(cbuffer Lighting:register(b13){float4 f[3323];}
struct V{float4 p:SV_Position;float x:TEXCOORD0;};
V main(uint id:SV_VertexID){V v;float2 uv=float2((id<<1)&2,id&2);v.p=float4(uv*float2(2,-2)+float2(-1,1),0,1);v.x=f[1].x;return v;})";
    const char* pixel=R"(cbuffer Lighting:register(b13){float4 f[3323];}
float4 main(float4 p:SV_Position,float x:TEXCOORD0):SV_Target{return float4(x,f[1].yz,1);})";
    ComPtr<ID3DBlob> code;ComPtr<ID3D11VertexShader> vs;ComPtr<ID3D11PixelShader> ps;
    check(D3DCompile(vertex,strlen(vertex),nullptr,nullptr,nullptr,"main","vs_5_0",0,0,&code,nullptr));check(device->CreateVertexShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&vs));
    code.Reset();check(D3DCompile(pixel,strlen(pixel),nullptr,nullptr,nullptr,"main","ps_5_0",0,0,&code,nullptr));check(device->CreatePixelShader(code->GetBufferPointer(),code->GetBufferSize(),nullptr,&ps));
    D3D11_TEXTURE2D_DESC desc{8,8,1,1,DXGI_FORMAT_R32G32B32A32_FLOAT,{1,0},D3D11_USAGE_DEFAULT,D3D11_BIND_RENDER_TARGET};
    ComPtr<ID3D11Texture2D> target,staging;ComPtr<ID3D11RenderTargetView> rtv;
    check(device->CreateTexture2D(&desc,nullptr,&target));check(device->CreateRenderTargetView(target.Get(),nullptr,&rtv));
    desc.Usage=D3D11_USAGE_STAGING;desc.BindFlags=0;desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;check(device->CreateTexture2D(&desc,nullptr,&staging));
    D3D11_RASTERIZER_DESC raster{};raster.FillMode=D3D11_FILL_SOLID;raster.CullMode=D3D11_CULL_NONE;ComPtr<ID3D11RasterizerState> rs;check(device->CreateRasterizerState(&raster,&rs));context->RSSetState(rs.Get());
    const D3D11_VIEWPORT viewport{0,0,8,8,0,1};context->RSSetViewports(1,&viewport);context->OMSetRenderTargets(1,rtv.GetAddressOf(),nullptr);
    context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);context->VSSetShader(vs.Get(),nullptr,0);context->PSSetShader(ps.Get(),nullptr,0);
    installed=common_supported=true;
    for(unsigned region:{0u,2u,6u})for(uint32_t hash:{0x6F0FF708u,0xF12E637Du,0xC6178ADCu,0xF4B551ECu})for(float master:{0.f,1.f})for(float gain:{0.f,50.f,100.f,200.f}) {
      enabled=master;cloud_brightness=star_brightness=sky_haze_brightness=gain;
      normalization::current.store(region, std::memory_order_relaxed);
      context->VSSetConstantBuffers(13,1,native.GetAddressOf());context->PSSetConstantBuffers(13,1,native.GetAddressOf());
      auto& registration=custom_shaders.at(hash);
      // Same default/override decision used by mods::shader::OnCommandAction.
      // PushShaderInjections uses all_graphics, so an accidental default binds
      // the 160-byte settings buffer to both stages, including the native VS.
      if(registration.on_replace(nullptr)&&(!registration.on_inject||registration.on_inject(nullptr))) {
        context->VSSetConstantBuffers(13,1,injection.GetAddressOf());context->PSSetConstantBuffers(13,1,injection.GetAddressOf());
      }
      ComPtr<ID3D11Buffer> vertex_binding,pixel_binding;
      context->VSGetConstantBuffers(13,1,&vertex_binding);context->PSGetConstantBuffers(13,1,&pixel_binding);
      if(vertex_binding.Get()!=native.Get()||pixel_binding.Get()!=native.Get())throw std::runtime_error("Night cloud/sky registration overwrites native b13");
      context->Draw(3,0);context->CopyResource(staging.Get(),target.Get());D3D11_MAPPED_SUBRESOURCE mapped{};check(context->Map(staging.Get(),0,D3D11_MAP_READ,0,&mapped));
      for(unsigned y=0;y<8;++y)for(unsigned x=0;x<8;++x){const auto* actual=reinterpret_cast<const float*>(static_cast<const char*>(mapped.pData)+y*mapped.RowPitch)+x*4;if(actual[0]!=2||actual[1]!=4||actual[2]!=8||actual[3]!=1)throw std::runtime_error("Downstream native HDR draw lost vertex/pixel lighting");}
      context->Unmap(staging.Get(),0);
    }
    witcher3classic::water::mode=witcher3classic::volumetrics::mode=0.f;
    enabled=1.f;
    water_ambient=0.f;
    if(!custom_shaders.at(0x28D7BDFE).on_replace(nullptr))throw std::runtime_error("Night water ambient is skipped with native water/fog");
    water_ambient=100.f;
    if(custom_shaders.at(0x28D7BDFE).on_replace(nullptr))throw std::runtime_error("Neutral night water forces a shader replacement");
    water_ambient=0.f;enabled=0.f;
    if(custom_shaders.at(0x28D7BDFE).on_replace(nullptr))throw std::runtime_error("Disabled nights force a water replacement");
    std::cout<<"PASS real night registrations at Off/On and 0/50/100/200%, native VS/PS b13 preserved, downstream HDR RGB=(2,4,8), native-water activation\n";
  } catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}
}
