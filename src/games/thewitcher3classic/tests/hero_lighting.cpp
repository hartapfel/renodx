/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3dcompiler.h>
#include <bit>
#include <iostream>
#include "motion_gpu.hpp"

// Captured skin constants plus controlled temporary lights. Unlike a zeroed
// lighting fixture, this executes the loop that exposed a decompiler index leak.
int main(int argc, char** argv) {
  std::cout << std::unitbuf;
  assert(argc == 3 || argc == 4);
  const std::filesystem::path capture = argv[1], originals = argv[2];
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr, argc == 4 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP,
      nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context)));
  const char* vertex_source = R"(
struct V {
  float4 a:TEXCOORD0; float4 b:TEXCOORD1; float4 c:TEXCOORD2;
  float4 d:TEXCOORD3; float4 e:TEXCOORD4; float3 f:TEXCOORD5;
  float4 p:SV_Position; float4 previous:TEXCOORD10;
  nointerpolation float history:TEXCOORD11;
};
V main(uint id:SV_VertexID) {
  V v; float2 uv=float2((id<<1)&2,id&2);
  v.p=float4(uv*float2(2,-2)+float2(-1,1),.5,1);
  v.a=float4(0,0,.5,0); v.b=float4(.5,.5,1,0);
  v.c=float4(0,0,.5,1); v.d=float4(0,0,1,0);
  v.e=float4(108,-48,3.3,1); v.f=float3(1,0,0);
  v.previous=v.p; v.history=1; return v;
})";
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
  for (UINT slot : {1u, 2u, 3u, 4u, 5u, 12u})
    bind_constants(slot, Read(capture / ("head-b" + std::to_string(slot) + ".bin")));
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
  for (UINT slot : {0u, 1u, 2u, 3u}) bind_texture(slot, {.5f, .5f, .75f, 1.f});
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
  const auto native = Read(originals / "0x90BFECE8.cso");
  const auto previous = Read(capture / "0x90BFECE8-before.cso");
  const auto replacement = Read("build/thewitcher3classic.include/embed/0x90BFECE8.cso");
  auto lights = Read(capture / "head-b13.bin");
  auto* light = reinterpret_cast<float*>(lights.data());
  light[0] = .2f; light[1] = .3f; light[2] = std::sqrt(.87f);
  float worst_previous = 0;
  for (UINT count : {0u, 1u, 3u}) for (UINT last : {0u, 5u}) for (bool outside_radius : {false, true}) {
    // Vary both list length and final index. The original faulty source used
    // the last loop register instead of the fixed directional-light constant.
    std::vector<uint32_t> indices(256 * 1024, 256);
    for (UINT tile = 0; tile < 1024; ++tile) for (UINT i = 0; i < count; ++i)
      indices[tile * 256 + i] = i + 1 == count ? last : i + 1;
    for (UINT id = 0; id < 6; ++id) {
      const size_t base = (58 + id * 9) * 4;
      light[base] = 108.5f; light[base + 1] = -47; light[base + 2] = 4; light[base + 3] = 10;
      light[base + 12] = 5; light[base + 13] = 2; light[base + 14] = 1;
      light[base + 15] = std::bit_cast<float>(4096u);
      light[base + 20] = .1f; light[base + 22] = 0; light[base + 24] = 0;
      if (outside_radius && id == last) light[base + 3] = .25f;
    }
    bind_constants(13, lights);
    const D3D11_BUFFER_DESC raw_desc{UINT(indices.size() * 4), D3D11_USAGE_DEFAULT,
        D3D11_BIND_SHADER_RESOURCE, 0, D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS};
    const D3D11_SUBRESOURCE_DATA raw_data{indices.data()};
    ComPtr<ID3D11Buffer> raw;
    ComPtr<ID3D11ShaderResourceView> raw_view;
    assert(SUCCEEDED(device->CreateBuffer(&raw_desc, &raw_data, &raw)));
    D3D11_SHADER_RESOURCE_VIEW_DESC raw_view_desc{};
    raw_view_desc.Format = DXGI_FORMAT_R32_TYPELESS;
    raw_view_desc.ViewDimension = D3D11_SRV_DIMENSION_BUFFEREX;
    raw_view_desc.BufferEx.NumElements = UINT(indices.size());
    raw_view_desc.BufferEx.Flags = D3D11_BUFFEREX_SRV_FLAG_RAW;
    assert(SUCCEEDED(device->CreateShaderResourceView(raw.Get(), &raw_view_desc, &raw_view)));
    context->PSSetShaderResources(20, 1, raw_view.GetAddressOf());
    const auto expected = render(native), old = render(previous), actual = render(replacement);
    float error = 0;
    for (UINT c = 0; c < 3; ++c) {
      assert(std::isfinite(expected[c]) && std::isfinite(actual[c]));
      error = std::max(error, std::abs(expected[c] - actual[c]));
      worst_previous = std::max(worst_previous, std::isfinite(old[c]) ? std::abs(expected[c] - old[c]) : 1.f);
    }
    std::cout << "lights=" << count << " last=" << last << " outside=" << outside_radius << " native=" << expected[0] << ',' << expected[1]
              << ',' << expected[2] << " previous=" << old[0] << ',' << old[1] << ',' << old[2] << " error=" << error << '\n';
    assert(error < .002f);
  }
  assert(worst_previous > .01f);
  std::cout << "PASS temporary-light skin shading matches original DXBC; old maximum error=" << worst_previous << '\n';
}
