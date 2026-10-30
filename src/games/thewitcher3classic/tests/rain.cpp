/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <d3d11.h>
#include <d3dcompiler.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <include/reshade.hpp>
#include <iostream>
#include <stdexcept>
#include <vector>
#include "../rain/runtime.hpp"
using Microsoft::WRL::ComPtr;
namespace fs = std::filesystem;
fs::path root;
void Check(HRESULT hr) {
  if (FAILED(hr)) throw std::runtime_error(std::to_string(hr));
}
std::vector<char> Read(const fs::path& p) {
  std::ifstream f(p, std::ios::binary);
  if (!f) throw std::runtime_error(p.string());
  return {std::istreambuf_iterator<char>(f), {}};
}
ComPtr<ID3DBlob> Compiled(const fs::path& path) {
  // Exercise the exact FXC output embedded by the Release addon target.
  const auto bytes = Read(fs::path("build/thewitcher3classic.include/embed") / (path.stem().stem().string() + ".cso"));
  ComPtr<ID3DBlob> code;
  Check(D3DCreateBlob(bytes.size(), &code));
  std::memcpy(code->GetBufferPointer(), bytes.data(), bytes.size());
  return code;
}
std::vector<float> Constants(const char* name) {
  auto bytes = Read(root / name);
  std::vector<float> values(bytes.size() / sizeof(float));
  std::memcpy(values.data(), bytes.data(), bytes.size());
  return values;
}
float Difference(const std::vector<float>& a, const std::vector<float>& b) {
  if (a.size() != b.size()) throw std::runtime_error("Size mismatch");
  float error = 0;
  for (size_t i = 0; i < a.size(); ++i) {
    if (!std::isfinite(a[i]) || !std::isfinite(b[i])) throw std::runtime_error("Nonfinite output");
    error = std::max(error, std::abs(a[i] - b[i]));
  }
  return error;
}
int main(int argc, char** argv) {
  try {
    if (argc < 2) return 2;
    root = argv[1];
    ComPtr<ID3D11Device> dev;
    ComPtr<ID3D11DeviceContext> ctx;
    Check(D3D11CreateDevice(nullptr, std::find(argv + 2, argv + argc, std::string("--hardware")) != argv + argc ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &dev, nullptr, &ctx));
    constexpr UINT W = 64, H = 64;
    const char* vsText = "struct V {float4 p:SV_Position;float2 uv:TEXCOORD0;float2 vignette:TEXCOORD2;}; V main(uint id:SV_VertexID){V v;v.uv=float2((id<<1)&2,id&2);v.p=float4(v.uv*float2(2,-2)+float2(-1,1),0,1);v.vignette=v.uv;return v;}";
    ComPtr<ID3DBlob> vsBlob;
    Check(D3DCompile(vsText, strlen(vsText), nullptr, nullptr, nullptr, "main", "vs_5_0", 0, 0, &vsBlob, nullptr));
    ComPtr<ID3D11VertexShader> vs;
    Check(dev->CreateVertexShader(vsBlob->GetBufferPointer(), vsBlob->GetBufferSize(), nullptr, &vs));
    ctx->VSSetShader(vs.Get(), nullptr, 0);
    ctx->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    D3D11_RASTERIZER_DESC rd = {};
    rd.FillMode = D3D11_FILL_SOLID;
    rd.CullMode = D3D11_CULL_NONE;
    rd.DepthClipEnable = TRUE;
    ComPtr<ID3D11RasterizerState> rs;
    Check(dev->CreateRasterizerState(&rd, &rs));
    ctx->RSSetState(rs.Get());
    D3D11_VIEWPORT vp = {0, 0, float(W), float(H), 0, 1};
    ctx->RSSetViewports(1, &vp);
    D3D11_TEXTURE2D_DESC td = {};
    td.Width = W;
    td.Height = H;
    td.MipLevels = td.ArraySize = td.SampleDesc.Count = 1;
    td.Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
    td.BindFlags = D3D11_BIND_RENDER_TARGET;
    ComPtr<ID3D11Texture2D> out, staging;
    Check(dev->CreateTexture2D(&td, nullptr, &out));
    ComPtr<ID3D11RenderTargetView> rt;
    Check(dev->CreateRenderTargetView(out.Get(), nullptr, &rt));
    ctx->OMSetRenderTargets(1, rt.GetAddressOf(), nullptr);
    td.BindFlags = 0;
    td.Usage = D3D11_USAGE_STAGING;
    td.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    Check(dev->CreateTexture2D(&td, nullptr, &staging));
    auto buffer = [&](UINT slot, const std::vector<float>& values) {D3D11_BUFFER_DESC d={};d.ByteWidth=UINT((values.size()*4+15)&~15);d.BindFlags=D3D11_BIND_CONSTANT_BUFFER;std::vector<float> padded(d.ByteWidth/4);std::copy(values.begin(),values.end(),padded.begin());D3D11_SUBRESOURCE_DATA data={padded.data()};ComPtr<ID3D11Buffer>b;Check(dev->CreateBuffer(&d,&data,&b));ctx->PSSetConstantBuffers(slot,1,b.GetAddressOf()); };
    auto texture = [&](UINT slot, UINT w, UINT h, const std::vector<float>& pixels) {D3D11_TEXTURE2D_DESC d={};d.Width=w;d.Height=h;d.MipLevels=d.ArraySize=d.SampleDesc.Count=1;d.Format=DXGI_FORMAT_R32G32B32A32_FLOAT;d.BindFlags=D3D11_BIND_SHADER_RESOURCE;D3D11_SUBRESOURCE_DATA data={pixels.data(),w*16};ComPtr<ID3D11Texture2D>t;Check(dev->CreateTexture2D(&d,&data,&t));ComPtr<ID3D11ShaderResourceView>s;Check(dev->CreateShaderResourceView(t.Get(),nullptr,&s));ctx->PSSetShaderResources(slot,1,s.GetAddressOf()); };
    D3D11_SAMPLER_DESC sd = {};
    sd.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sd.AddressU = sd.AddressV = sd.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    sd.MaxLOD = D3D11_FLOAT32_MAX;
    ComPtr<ID3D11SamplerState> sampler;
    Check(dev->CreateSamplerState(&sd, &sampler));
    for (UINT slot = 0; slot < 3; slot++) ctx->PSSetSamplers(slot, 1, sampler.GetAddressOf());
    auto render = [&](const void* data, size_t bytes) {ComPtr<ID3D11PixelShader>ps;Check(dev->CreatePixelShader(data,bytes,nullptr,&ps));ctx->PSSetShader(ps.Get(),nullptr,0);ctx->Draw(3,0);ctx->CopyResource(staging.Get(),out.Get());D3D11_MAPPED_SUBRESOURCE m;Check(ctx->Map(staging.Get(),0,D3D11_MAP_READ,0,&m));std::vector<float> values(W*H*4);for(UINT y=0;y<H;y++)memcpy(values.data()+y*W*4,static_cast<char*>(m.pData)+y*m.RowPitch,W*16);ctx->Unmap(staging.Get(),0);return values; };
    using witcher3classic::rain::Pipeline;
    using witcher3classic::rain::RainAtlas;
    // Synthetic signatures exercise classification and row padding without
    // redistributing game textures. Only the final CRC patch differs from zero.
    for (auto spec : {std::array<UINT, 3>{512, 512, 0}, std::array<UINT, 3>{128, 256, 1}}) {
      reshade::api::resource_desc desc(spec[0], spec[1], 1, 1, reshade::api::format::bc3_unorm, 1, reshade::api::memory_heap::gpu_only, reshade::api::resource_usage::shader_resource);
      std::vector<uint8_t> bytes(spec[0] * spec[1]);
      const uint8_t patches[2][4] = {{0xb, 0x8e, 0xad, 0x9f}, {0x8, 0x18, 0x6b, 0x13}};
      std::memcpy(bytes.data() + bytes.size() - 4, patches[spec[2]], 4);
      reshade::api::subresource_data upload{bytes.data(), spec[0] * 4, UINT(bytes.size())};
      if (!RainAtlas(desc, upload)) throw std::runtime_error("Known rain signature rejected");
      bytes[0] ^= 1;
      if (RainAtlas(desc, upload)) throw std::runtime_error("Unrelated particle atlas accepted");
      bytes[0] ^= 1;
      std::vector<uint8_t> padded((spec[0] * 4 + 16) * (spec[1] / 4), 0xff);
      for (UINT row = 0; row < spec[1] / 4; ++row) std::memcpy(padded.data() + row * (spec[0] * 4 + 16), bytes.data() + row * spec[0] * 4, spec[0] * 4);
      upload = {padded.data(), spec[0] * 4 + 16, UINT(padded.size())};
      if (!RainAtlas(desc, upload)) throw std::runtime_error("Row padding breaks rain classification");
    }
    std::cout << "PASS rain atlas signatures, padded uploads and unrelated particle rejection\n";
    const char* vertex = R"(struct V{float4 a:TEXCOORD0;float4 b:TEXCOORD1;float4 c:TEXCOORD2;float4 d:TEXCOORD3;float4 e:TEXCOORD4;float3 f:TEXCOORD5;float4 p:SV_Position;};
V main(uint id:SV_VertexID){V v;float2 uv=float2((id<<1)&2,id&2);v.a=1;v.b=float4(0,uv,1);v.c=float4(1,1,1,0);v.d=float4(0,0,0,1);v.e=float4(0,0,1,1);v.f=float3(0,0,1);v.p=float4(uv*float2(2,-2)+float2(-1,1),0,1);return v;})";
    vsBlob.Reset();
    Check(D3DCompile(vertex, strlen(vertex), nullptr, nullptr, nullptr, "main", "vs_5_0", 0, 0, &vsBlob, nullptr));
    vs.Reset();
    Check(dev->CreateVertexShader(vsBlob->GetBufferPointer(), vsBlob->GetBufferSize(), nullptr, &vs));
    ctx->VSSetShader(vs.Get(), nullptr, 0);
    auto frame = Constants("cb12.bin"), global = Constants("cb0.bin"), material = Constants("cb4.bin"), model = Constants("cb2.bin");
    buffer(1, Constants("cb1.bin"));
    buffer(13, Constants("cb13.bin"));
    frame[21 * 4] = 1;
    frame[21 * 4 + 1] = 0;
    frame[22 * 4] = 1;
    frame[22 * 4 + 1] = 0;
    frame[67 * 4 + 3] = -1;
    material[9 * 4] = 0;
    buffer(4, material);
    texture(0, 1, 1, {.7f, .65f, .9f, .7f});
    texture(15, W, H, std::vector<float>(W * H * 4, .01f));
    texture(24, W, H, std::vector<float>(W * H * 4, .5f));
    ctx->PSSetSamplers(8, 1, sampler.GetAddressOf());
    ctx->PSSetSamplers(15, 1, sampler.GetAddressOf());
    std::array<float, 4> cube_pixel{.4f, .6f, .8f, 1};
    std::array<D3D11_SUBRESOURCE_DATA, 6> faces;
    for (auto& face : faces) face = {cube_pixel.data(), 16, 0};
    D3D11_TEXTURE2D_DESC cube_desc{1, 1, 1, 6, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0}, D3D11_USAGE_IMMUTABLE, D3D11_BIND_SHADER_RESOURCE, 0, D3D11_RESOURCE_MISC_TEXTURECUBE};
    ComPtr<ID3D11Texture2D> cube;
    ComPtr<ID3D11ShaderResourceView> cube_view;
    Check(dev->CreateTexture2D(&cube_desc, faces.data(), &cube));
    Check(dev->CreateShaderResourceView(cube.Get(), nullptr, &cube_view));
    ctx->PSSetShaderResources(1, 1, cube_view.GetAddressOf());
    const auto native = Read("E:/SteamLibrary/steamapps/common/The Witcher 3/bin/x64/renodx-dev/dump/0x105478E1.ps_5_0.cso");
    const auto blitz = Read("tmp/witcher3classic-investigation/blitzfx-20261023/scene-shaders/0x1F3A90A1.cso");
    const auto production = Compiled("0x105478E1.ps_5_0.hlsl");
    D3D11_BLEND_DESC blend_desc{};
    auto& attachment = blend_desc.RenderTarget[0];
    attachment.BlendEnable = TRUE;
    attachment.SrcBlend = D3D11_BLEND_ONE;
    attachment.DestBlend = D3D11_BLEND_INV_SRC_ALPHA;
    attachment.BlendOp = D3D11_BLEND_OP_ADD;
    attachment.SrcBlendAlpha = D3D11_BLEND_ONE;
    attachment.DestBlendAlpha = D3D11_BLEND_ZERO;
    attachment.BlendOpAlpha = D3D11_BLEND_OP_ADD;
    attachment.RenderTargetWriteMask = 15;
    ComPtr<ID3D11BlendState> blend;
    Check(dev->CreateBlendState(&blend_desc, &blend));
    Pipeline pipeline;
    ComPtr<ID3D11Buffer> native_lighting;
    ctx->PSGetConstantBuffers(13, 1, &native_lighting);
    ctx->VSSetConstantBuffers(13, 1, native_lighting.GetAddressOf());
    D3D11_SAMPLER_DESC old_sampler_desc{};
    sampler->GetDesc(&old_sampler_desc);
    old_sampler_desc.Filter = D3D11_FILTER_MIN_MAG_MIP_POINT;
    ComPtr<ID3D11SamplerState> old_sampler;
    Check(dev->CreateSamplerState(&old_sampler_desc, &old_sampler));
    ctx->PSSetSamplers(10, 1, old_sampler.GetAddressOf());
    ComPtr<ID3D11ShaderResourceView> atlas;
    ctx->PSGetShaderResources(0, 1, &atlas);
    ComPtr<ID3D11Resource> atlas_resource;
    atlas->GetResource(&atlas_resource);
    pipeline.Observe(reinterpret_cast<uint64_t>(atlas_resource.Get()), true);
    auto draw = [&](const void* bytes, size_t count) {const float clear[4]{};ctx->ClearRenderTargetView(rt.Get(),clear);return render(bytes,count); };
    for (auto size : {std::array<UINT, 2>{64, 64}, {44, 36}, {32, 28}, {20, 20}, {45, 37}})
      for (float opacity : {0.f, .0003f, 1.f}) {
        frame[23 * 4] = float(size[0]);
        frame[23 * 4 + 1] = float(size[1]);
        frame[23 * 4 + 2] = 1.f / size[0];
        frame[23 * 4 + 3] = 1.f / size[1];
        buffer(3, frame);
        buffer(12, frame);
        global[4] = float(size[0]);
        global[5] = float(size[1]);
        global[6] = 1.f / size[0];
        global[7] = 1.f / size[1];
        buffer(0, global);
        model[11] = opacity;
        buffer(2, model);
        const D3D11_VIEWPORT viewport{0, 0, float(size[0]), float(size[1]), 0, 1};
        ctx->RSSetViewports(1, &viewport);
        std::vector<float> pixels(W * H * 4, 1000), crop(size[0] * size[1] * 4);
        for (UINT y = 0; y < size[1]; ++y)
          for (UINT x = 0; x < size[0]; ++x)
            for (UINT c = 0; c < 4; ++c) {
              float value = c == 3 ? 1.f : c == 2 ? -.35f + .02f * x - .01f * y
                                                  : .1f + .03f * c + .2f * x + .03f * y;
              pixels[(y * W + x) * 4 + c] = crop[(y * size[0] + x) * 4 + c] = value;
            }
        texture(50, size[0], size[1], crop);
        texture(6, W, H, pixels);
        const auto original = draw(native.data(), native.size());
        const auto off = draw(production->GetBufferPointer(), production->GetBufferSize());
        if (Difference(original, off) > .0001) throw std::runtime_error("Rain Off changes native particle RGB/alpha");
        const auto refracted = draw(blitz.data(), blitz.size());
        ctx->OMSetBlendState(blend.Get(), nullptr, ~0u);
        if (!pipeline.Bind(ctx.Get())) throw std::runtime_error("Valid rain pipeline did not bind");
        ctx->OMSetBlendState(nullptr, nullptr, ~0u);
        const auto actual = draw(production->GetBufferPointer(), production->GetBufferSize());
        pipeline.Restore();
        float error = 0, peak = 0;
        size_t covered = 0;
        for (UINT y = 0; y < size[1]; ++y)
          for (UINT x = 0; x < size[0]; ++x)
            for (UINT c = 0; c < 4; ++c) {
              size_t i = (y * W + x) * 4 + c;
              float alpha = std::max(0.f, refracted[(y * W + x) * 4 + 3]);
              float expected = c == 3 ? alpha : original[i] * (1 - alpha) + refracted[i];
              if (!std::isfinite(actual[i])) throw std::runtime_error("Rain produced nonfinite HDR");
              error = std::max(error, std::abs(actual[i] - expected));
              if (c == 3 && actual[i] > 0)
                ++covered;
              else if (c < 3)
                peak = std::max(peak, actual[i]);
            }
        if (error > .001f || (opacity > 0 && !covered) || (opacity == 1.f && peak <= 1)) throw std::runtime_error("Single-draw rain differs from BlitzFX two-pass composition: " + std::to_string(error) + " opacity=" + std::to_string(opacity) + " coverage=" + std::to_string(covered) + " peak=" + std::to_string(peak));
        ComPtr<ID3D11ShaderResourceView> restored;
        ctx->PSGetShaderResources(110, 1, &restored);
        if (restored) throw std::runtime_error("Rain parameter binding leaked");
        ComPtr<ID3D11SamplerState> restored_sampler;
        ctx->PSGetSamplers(10, 1, &restored_sampler);
        if (restored_sampler.Get() != old_sampler.Get()) throw std::runtime_error("Rain sampler binding leaked");
        ComPtr<ID3D11Buffer> vs_lighting, ps_lighting;
        ctx->VSGetConstantBuffers(13, 1, &vs_lighting);
        ctx->PSGetConstantBuffers(13, 1, &ps_lighting);
        if (vs_lighting.Get() != native_lighting.Get() || ps_lighting.Get() != native_lighting.Get()) throw std::runtime_error("Rain overwrites native VS/PS lighting");
      }
    pipeline.Observe(reinterpret_cast<uint64_t>(atlas_resource.Get()), false);
    ctx->OMSetBlendState(blend.Get(), nullptr, ~0u);
    if (pipeline.Bind(ctx.Get())) throw std::runtime_error("Unrecognized particle enabled rain");
    std::cout << "PASS native Off, BlitzFX two-pass equivalence in one draw, five pool sizes/poisoned edges, 0/partial/full coverage, HDR, binding restoration and non-rain rejection\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
