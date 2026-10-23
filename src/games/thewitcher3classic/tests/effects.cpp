/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#define NOMINMAX
#include <d3d11.h>
#include <d3dcompiler.h>
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
#include "../shared.h"
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
    Check(D3D11CreateDevice(nullptr, argc > 2 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &dev, nullptr, &ctx));
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
    std::vector<float> scene(W * H * 4);
    for (UINT y = 0; y < H; ++y)
      for (UINT x = 0; x < W; ++x) {
        const size_t i = (y * W + x) * 4;
        const float v = .1f + float(x) / W + ((x / 4 + y / 4) % 2 ? .8f : 0.f);
        scene[i] = v;
        scene[i + 1] = v * .7f;
        scene[i + 2] = v * .4f;
        scene[i + 3] = .001f;
      }
    texture(0, W, H, scene);
    ShaderInjectData injection = {};
    injection.peak_white_nits = 1000;
    injection.diffuse_white_nits = injection.graphics_white_nits = 203;
    injection.tone_map_exposure = injection.tone_map_highlights = injection.tone_map_shadows = 1;
    injection.tone_map_contrast = injection.tone_map_highlight_contrast = injection.tone_map_shadow_contrast = 1;
    injection.tone_map_saturation = injection.tone_map_highlight_saturation = injection.tone_map_gamma = 1;
    injection.psychov_adaptation_anchor = injection.psychov_background_anchor = .18f;
    injection.psychov_highlight_hue = injection.psychov_gamut_compression = 1;
    injection.psychov_gamut_compression_mode = 3;
    injection.custom_blur = 1;
    injection.vignette_strength = 1;
    const auto inject = [&] {
      std::vector<float> values(sizeof(injection) / sizeof(float));
      std::memcpy(values.data(), &injection, sizeof(injection));
      buffer(13, values);
    };
    const auto run = [&](ID3DBlob* code) { return render(code->GetBufferPointer(), code->GetBufferSize()); };
    for (const char* hash : {"649AF4FA", "5CBEC131", "C4D2D4F6", "9F48B203", "1E28F70E", "A1C06A7D"}) {
      auto constants = Constants("grade-b3.bin");
      constants.resize(72);
      constants[68] = constants[69] = .5f;
      constants[70] = 1.f / W;
      constants[71] = 1.f / H;
      buffer(3, constants);
      texture(2, 2, 2, {0, 0, 0, 1, .3f, 0, 0, 1, .7f, 0, 0, 1, 1, 0, 0, 1});
      auto code = Compiled(fs::path("src/games/thewitcher3classic/grading") / (std::string("0x") + hash + ".ps_5_0.hlsl"));
      auto native = Read(root / (std::string("0x") + hash + ".cso"));
      injection.tone_map_type = 0;
      injection.sharpening_mode = 0;
      injection.sharpening_strength = 0;
      injection.chromatic_aberration_mode = 0;
      injection.film_grain = 0;
      injection.vignette_strength = 1;
      injection.vignette_black_floor = 0;
      inject();
      const auto original = render(native.data(), native.size());
      if (Difference(original, run(code.Get())) > .0001f) throw std::runtime_error(std::string(hash) + " native mismatch");
      injection.tone_map_type = 1;
      inject();
      const auto base = run(code.Get());
      injection.sharpening_mode = 1;
      inject();
      if (Difference(base, run(code.Get())) != 0) throw std::runtime_error("Zero RCAS changed output");
      injection.sharpening_strength = .8f;
      inject();
      const auto sharp = run(code.Get());
      if (Difference(base, sharp) < 1e-5f) throw std::runtime_error("RCAS ineffective");
      injection.chromatic_aberration_mode = 1;
      injection.chromatic_aberration_intensity = 5;
      injection.chromatic_aberration_start_offset = .7f;
      inject();
      const auto fringe = run(code.Get());
      if (Difference(sharp, fringe) < 1e-5f) throw std::runtime_error("CA ineffective");
      injection.film_grain = .5f;
      injection.random_seed = .23f;
      inject();
      const auto grain = run(code.Get());
      if (Difference(fringe, grain) < 1e-5f) throw std::runtime_error("Grain ineffective");
      injection.random_seed = .77f;
      inject();
      if (Difference(grain, run(code.Get())) < 1e-5f) throw std::runtime_error("Grain seed ineffective");
      // Vanilla gates every creative effect even when its controls are nonzero.
      injection.tone_map_type = 0;
      injection.vignette_strength = 2;
      injection.vignette_black_floor = 1;
      inject();
      if (Difference(original, run(code.Get())) > .0001f) throw std::runtime_error("Vanilla effects leaked");
      std::cout << "PASS final grade " << hash << " native, RCAS, CA, grain and Vanilla isolation\n";

      // Controlled masks expose black-floor leakage and clipped high-strength
      // opacity, independently of the live scene's current vignette constants.
      injection.tone_map_type = 1;
      injection.sharpening_mode = injection.chromatic_aberration_mode = injection.film_grain = 0;
      constants[24] = constants[25] = constants[26] = 0;
      constants[27] = 1;
      constants[28] = .3f;
      constants[29] = .2f;
      constants[30] = .1f;
      constants[32] = 1;
      constants[36] = constants[37] = constants[38] = 1;
      for (size_t i = 44; i < 56; ++i) constants[i] = 1;
      constants[56] = constants[58] = 1;
      constants[57] = constants[60] = 0;
      constants[61] = 1;
      buffer(3, constants);
      texture(2, 1, 1, {.75f, 0, 0, 1});
      injection.vignette_strength = 0;
      inject();
      const auto no_vignette = run(code.Get());
      injection.vignette_black_floor = 0;
      inject();
      if (Difference(no_vignette, run(code.Get())) > .000001f) throw std::runtime_error("Zero vignette depends on black-floor mode");
      injection.vignette_black_floor = 1;
      injection.vignette_strength = 1;
      inject();
      const auto normal_vignette = run(code.Get());
      injection.vignette_strength = 2;
      inject();
      const auto strong_vignette = run(code.Get());
      const bool vignette_path = std::string(hash) != "5CBEC131" && std::string(hash) != "1E28F70E";
      if (vignette_path) {
        if (Difference(no_vignette, normal_vignette) < 1e-5f || Difference(normal_vignette, strong_vignette) < 1e-5f)
          throw std::runtime_error("Vignette strength ineffective");
        for (size_t i = 0; i < scene.size(); ++i) {
          if (i % 4 == 3) continue;
          if (strong_vignette[i] <= 0 || strong_vignette[i] > normal_vignette[i] + .00001f)
            throw std::runtime_error("Partial vignette clipped or brightened");
        }
      } else if (Difference(no_vignette, strong_vignette) != 0) {
        throw std::runtime_error("Vignette leaked into cutscene/no-vignette path");
      }
      texture(0, W, H, std::vector<float>(scene.size()));
      inject();
      const auto black = run(code.Get());
      for (size_t i = 0; i < black.size(); ++i)
        if (i % 4 != 3 && std::abs(black[i]) > .000001f) throw std::runtime_error("Perfect Black raised black floor");
      injection.vignette_black_floor = 0;
      inject();
      if (vignette_path && Difference(black, run(code.Get())) < 1e-5f) throw std::runtime_error("Native vignette floor missing");
      texture(0, W, H, scene);
      std::cout << "PASS vignette " << hash << " zero/50/100, black floor and permutation isolation\n";
    }
    auto blur = Compiled("src/games/thewitcher3classic/effects/0x6ED58557.ps_5_0.hlsl");
    auto original_blur = Read(root / "0x6ED58557.cso");
    auto frame = Constants("blur-b12.bin");
    frame[294] = 1.f / W;
    frame[295] = 1.f / H;
    buffer(12, frame);
    buffer(3, Constants("blur-b3.bin"));
    for (const float depth : {.001f, 0.f}) {
      std::vector<float> depths(W * H * 4, depth);
      texture(1, W, H, depths);
      const auto original = render(original_blur.data(), original_blur.size());
      injection.tone_map_type = 1;
      injection.custom_blur = 1;
      inject();
      if (Difference(original, run(blur.Get())) > .0001f) throw std::runtime_error("Blur 50 mismatch");
      injection.custom_blur = 0;
      inject();
      const auto disabled = run(blur.Get());
      if (Difference(disabled, std::vector<float>(disabled.size())) != 0) throw std::runtime_error("Blur zero not transparent");
      injection.custom_blur = 2;
      inject();
      const auto doubled = run(blur.Get());
      const float delta = Difference(original, doubled);
      if ((depth == 0 && delta > .0001f) || (depth != 0 && delta < 1e-5f)) throw std::runtime_error("Blur radius/sky isolation failed");
      injection.tone_map_type = 0;
      inject();
      if (Difference(original, run(blur.Get())) > .0001f) throw std::runtime_error("Blur Vanilla mismatch");
    }
    std::cout << "PASS blur native radius, zero, doubled radius and sky isolation\n";
    auto bypass = Compiled("src/games/thewitcher3classic/effects/0x3EDDC379.ps_5_0.hlsl");
    buffer(3, {0, 0, float(W), float(H), 0, 0, 0, 0, 0, 0, 0, 0});
    const auto copied = run(bypass.Get());
    for (size_t i = 3; i < scene.size(); i += 4) scene[i] = 1;
    if (Difference(scene, copied) > .00001f) throw std::runtime_error("Native sharpening bypass changed scene");
    std::cout << "PASS pre-AA sharpening bypass preserves HDR color and native alpha\n";
    return 0;
  } catch (const std::exception& e) {
    std::cerr << e.what() << '\n';
    return 1;
  }
}
