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
    Check(D3D11CreateDevice(nullptr, std::find(argv + 2, argv + argc, std::string("--hardware")) != argv + argc
        ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &dev, nullptr, &ctx));
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
    injection.lut_strength = injection.color_grading_strength = 1;
    const auto inject = [&] {
      std::vector<float> values(sizeof(injection) / sizeof(float));
      std::memcpy(values.data(), &injection, sizeof(injection));
      buffer(13, values);
    };
    const auto run = [&](ID3DBlob* code) { return render(code->GetBufferPointer(), code->GetBufferSize()); };
    {
      const auto saved = injection;
      const auto code = Compiled("0x620431CF.ps_5_0.hlsl");
      const auto native = Read(root.parent_path() / "20261022/originals/0x620431CF.cso");
      std::vector<float> constants(36);
      constants[0] = constants[1] = constants[4] = constants[5] = constants[12] = constants[13] = W;
      constants[22] = constants[23] = W - 1;
      constants[24] = .3f; constants[25] = .4f; constants[26] = .5f;
      constants[28] = .1f; constants[29] = .2f; constants[30] = .3f;
      constants[32] = constants[33] = 1.f / W;
      texture(1, W, H, std::vector<float>(W * H * 4, .2f));
      buffer(3, constants);
      const auto original = render(native.data(), native.size());
      for (float strength : {0.f, .5f, 1.f, 2.f}) {
        injection.blitz_bloom_active = 0;
        injection.custom_bloom = strength;
        injection.custom_lens_dirt = 1;
        inject();
        auto expected = original;
        for (auto& value : expected) value *= strength;
        if (Difference(expected, run(code.Get())) > 1e-6f) throw std::runtime_error("Native bloom fallback changed");
      }
      constants[24] = constants[25] = constants[26] = 0;
      buffer(3, constants);
      const auto dirt_only = render(native.data(), native.size());
      constants[24] = .3f; constants[25] = .4f; constants[26] = .5f;
      buffer(3, constants);
      for (float strength : {0.f, .5f, 1.f, 2.f}) for (float dirt : {0.f, 1.f, 2.f}) {
        injection.blitz_bloom_active = 1;
        injection.custom_bloom = strength;
        injection.custom_lens_dirt = dirt;
        inject();
        auto expected = dirt_only;
        for (auto& value : expected) value *= dirt;
        if (Difference(expected, run(code.Get())) > 1e-6f) throw std::runtime_error("BlitzFX native bloom suppression/lens dirt isolation failed");
      }
      injection = saved; inject();
      std::cout << "PASS native bloom fallback and BlitzFX uniform-bloom removal with independent lens dirt\n";
    }
    if (std::find(argv + 2, argv + argc, std::string("--blitzfx")) != argv + argc) {
      const auto saved_injection = injection;
      const fs::path blitz = root.parent_path() / "blitzfx-20261023";
      const auto fixture = [&](const char* name) {
        const auto bytes = Read(blitz / "fixtures" / name);
        std::vector<float> values(bytes.size() / 4);
        std::memcpy(values.data(), bytes.data(), bytes.size());
        return values;
      };
      auto constants = fixture("grade-b3.bin");
      auto custom = fixture("grade-b1.bin");
      auto frame = fixture("grade-b0.bin");
      frame[92] = W; frame[93] = H; frame[94] = 1.f / W; frame[95] = 1.f / H;
      constants[68] = constants[69] = .5f;
      constants[70] = 1.f / W; constants[71] = 1.f / H;
      buffer(0, frame);
      buffer(3, constants);
      texture(69, 256, 256, std::vector<float>(256 * 256 * 4, .3f));
      for (UINT slot = 1; slot <= 5; ++slot) texture(slot, W, H, std::vector<float>(W * H * 4, .2f * slot));
      for (const auto* hash : {"0x114D8828", "0xA123EB15", "0x399CBE16", "0x445EB59C", "0x4FC8DAEB", "0xE276DFB3"}) {
        constants = fixture("grade-b3.bin"); custom = fixture("grade-b1.bin");
        constants[68] = constants[69] = .5f; constants[70] = 1.f / W; constants[71] = 1.f / H;
        buffer(3, constants); injection = saved_injection; inject();
        const auto native = Read(blitz / (std::string("scene-shaders/") + hash + ".cso"));
        const auto code = Compiled(std::string(hash) + ".ps_5_0.hlsl");
        for (uint32_t balance : {0u, 1u}) for (float vignette : {0.f, .8f}) for (float border : {1.f, .7f}) {
          std::memcpy(&custom[173], &balance, 4); // HLSL bool, not float(1).
          custom[174] = border; custom[177] = vignette;
          for (uint32_t debug = 0; debug <= 7; ++debug) {
            std::memcpy(&custom[175], &debug, 4);
            buffer(1, custom);
            injection.tone_map_type = 0; inject();
            const auto original = render(native.data(), native.size());
            const float error = Difference(original, run(code.Get()));
            if (error > .0001f) throw std::runtime_error("BlitzFX final grade Vanilla mismatch: balance="
                + std::to_string(balance) + " vignette=" + std::to_string(vignette) + " border=" + std::to_string(border)
                + " debug=" + std::to_string(debug) + " error=" + std::to_string(error));
            if (debug != 0) {
              injection.tone_map_type = 1; inject();
              if (Difference(original, run(code.Get())) > .0001f) throw std::runtime_error("BlitzFX debug view changed");
            }
          }
        }
        custom[173] = custom[175] = 0; custom[174] = 1; custom[177] = .8f;
        buffer(1, custom);
        injection.tone_map_type = 1; inject();
        const auto no_balance = run(code.Get());
        const auto saved_constants = constants;
        constants[56] = .3f; constants[57] = .2f; constants[58] = 1.8f;
        buffer(3, constants);
        if (Difference(no_balance, run(code.Get())) > 1e-6f) throw std::runtime_error("BlitzFX disabled parametric grade leaked");
        constants = saved_constants; buffer(3, constants);
        injection.sharpening_mode = 1; injection.sharpening_strength = .8f; inject();
        const auto sharpened = run(code.Get());
        if (Difference(no_balance, sharpened) < 1e-5f) throw std::runtime_error("BlitzFX RCAS ineffective");
        injection.chromatic_aberration_mode = 1;
        injection.chromatic_aberration_intensity = 0; inject();
        const auto no_ca = run(code.Get());
        constants[64] = constants[66] = 100;
        buffer(3, constants);
        if (Difference(no_ca, run(code.Get())) > 1e-6f) throw std::runtime_error("BlitzFX native CA leaked into zero replacement");
        injection = saved_injection; inject();
        texture(0, W, H, scene);
        auto hdr_scene = scene;
        for (size_t i = 0; i < hdr_scene.size(); ++i) if (i % 4 != 3) hdr_scene[i] *= 1000;
        texture(0, W, H, hdr_scene);
        injection.tone_map_type = 1; inject();
        const auto hdr_grade = run(code.Get());
        if (*std::max_element(hdr_grade.begin(), hdr_grade.end()) <= 1.01f)
          throw std::runtime_error(std::string(hash) + " final grade still clamped to SDR");
        texture(0, W, H, scene);
        std::cout << "PASS BlitzFX grade " << hash << ": 64 native/debug permutations, HDR range, grade/RCAS/CA isolation\n";
      }

      constants = fixture("curve-b3.bin"); custom = fixture("curve-b1.bin");
      custom[177] = 0; custom[176] = 1;  // No vignette; native contrast.
      buffer(1, custom); buffer(3, constants);
      texture(1, 1, 1, {.18f, 0, 0, 0});
      const auto native_curve = Read(blitz / "scene-shaders/0x5AA6AFFF.cso");
      const auto curve = Compiled("0x5AA6AFFF.ps_5_0.hlsl");
      injection.tone_map_type = 0; inject();
      const auto bounded = render(native_curve.data(), native_curve.size());
      if (Difference(bounded, run(curve.Get())) > .0001f) throw std::runtime_error("BlitzFX curve Vanilla mismatch");
      injection.tone_map_type = 1; inject();
      Difference(bounded, run(curve.Get()));  // Includes finite-value validation.
      // The HDR branch must retain native exposure/toe. In particular, the
      // white-reference denominator is NOT a vignette transmission to clamp.
      // These dark samples stay below the Hable shoulder-extension pivot.
      auto dark = scene;
      for (size_t i = 0; i < dark.size(); ++i) if (i % 4 != 3) dark[i] *= 1e-6f;
      texture(0, W, H, dark);
      constants[28] = .3f; constants[29] = .3f; constants[30] = .1f;
      constants[32] = .2f; constants[33] = .01f; constants[34] = .3f;
      constants[65] = 1.0629823f;
      for (float white : {.25f, 1.f, 1.78067f, 5.f}) for (float gamma : {.5f, 1.f, 2.f})
        for (uint32_t modified : {0u, 1u}) for (float vignette : {0.f, .8f}) {
          constants[64] = white; constants[66] = gamma;
          std::memcpy(&custom[169], &modified, 4);
          custom[177] = vignette;
          buffer(1, custom); buffer(3, constants);
          injection.vignette_strength = 1;
          injection.tone_map_type = 0; inject();
          const auto expected = render(native_curve.data(), native_curve.size());
          injection.tone_map_type = 1; inject();
          if (Difference(expected, run(curve.Get())) > .00002f)
            throw std::runtime_error("BlitzFX HDR exposure/toe mismatch: white=" + std::to_string(white)
                + " gamma=" + std::to_string(gamma));
        }
      constants = fixture("curve-b3.bin"); custom = fixture("curve-b1.bin");
      custom[177] = 0; custom[176] = 1;
      buffer(1, custom); buffer(3, constants);
      auto bright = scene;
      for (size_t i = 0; i < bright.size(); ++i) if (i % 4 != 3) bright[i] *= 1000;
      texture(0, W, H, bright);
      const auto extended = run(curve.Get());
      if (*std::max_element(extended.begin(), extended.end()) <= 1.01f) throw std::runtime_error("BlitzFX curve still bounded to SDR");
      if (Difference(extended, extended) != 0) throw std::runtime_error("BlitzFX nonfinite highlight");
      injection = saved_injection; inject(); texture(0, W, H, scene);
      std::cout << "PASS BlitzFX curve native equivalence, 48 HDR exposure/toe cases, finite output and highlight extension\n";

      // Weather/environment transitions use an independent pair of curves.
      const auto blend_native = Read(blitz / "scene-shaders/0x0E583BCD.cso");
      const auto blend_code = Compiled("0x0E583BCD.ps_5_0.hlsl");
      constants.resize(72);
      std::copy_n(constants.begin() + 16, 4, constants.begin() + 36);
      constants[44] = .25f; constants[45] = .35f; constants[46] = .15f;
      constants[48] = .2f; constants[49] = .015f; constants[50] = .3f;
      constants[68] = .8f; constants[69] = 1.3f; constants[70] = .75f;
      for (float blend : {0.f, .25f, .5f, 1.f}) for (uint32_t modified : {0u, 1u})
        for (float vignette : {0.f, .8f}) {
          constants[52] = blend; custom[177] = vignette;
          std::memcpy(&custom[169], &modified, 4);
          buffer(1, custom); buffer(3, constants);
          texture(0, W, H, scene);
          injection.tone_map_type = 0; inject();
          if (Difference(render(blend_native.data(), blend_native.size()), run(blend_code.Get())) > .00002f)
            throw std::runtime_error("BlitzFX blended curve Vanilla mismatch");
          texture(0, W, H, dark);
          const auto expected = render(blend_native.data(), blend_native.size());
          injection.tone_map_type = 1; injection.vignette_strength = 1; inject();
          if (Difference(expected, run(blend_code.Get())) > .00002f)
            throw std::runtime_error("BlitzFX blended HDR exposure/toe mismatch");
          texture(0, W, H, bright);
          const auto hdr = run(blend_code.Get());
          if (*std::max_element(hdr.begin(), hdr.end()) <= 1.01f)
            throw std::runtime_error("BlitzFX blended curve still bounded to SDR");
        }
      injection = saved_injection; inject(); texture(0, W, H, scene);
      std::cout << "PASS BlitzFX blended curves: 16 native/toe/highlight cases, both environment endpoints and blends\n";

      // The reflection ray marcher must receive the same quarter-resolution
      // depth as native rendering into a physically smaller allocation.
      const auto reflection_depth_native = Read(blitz / "scene-shaders/0x657A6576.cso");
      const auto reflection_depth_code = Compiled("0x657A6576.ps_5_0.hlsl");
      D3D11_SAMPLER_DESC depth_sampler_desc = sd;
      depth_sampler_desc.Filter = D3D11_FILTER_MIN_MAG_MIP_POINT;
      ComPtr<ID3D11SamplerState> depth_sampler;
      Check(dev->CreateSamplerState(&depth_sampler_desc, &depth_sampler));
      ctx->PSSetSamplers(0, 1, depth_sampler.GetAddressOf());
      for (const auto size : {std::array<UINT, 2>{64, 64}, {44, 36}, {32, 28}, {20, 20}}) {
        const UINT quarter_width = size[0] / 4, quarter_height = size[1] / 4;
        buffer(3, {float(quarter_width), float(quarter_height), 0, 0, .25f, .25f, 4, 4});
        D3D11_VIEWPORT depth_viewport = {0, 0, float(quarter_width), float(quarter_height), 0, 1};
        ctx->RSSetViewports(1, &depth_viewport);
        const auto depth_input = [&](UINT width, UINT height) {
          std::vector<float> pixels(width * height * 4, .99f);
          for (UINT y = 0; y < size[1]; ++y) for (UINT x = 0; x < size[0]; ++x)
            // Native quarter sampling lands on a point-filter texel boundary.
            // Keep each 4x4 cell constant so reciprocal roundoff cannot turn
            // the coordinate-domain check into a neighboring-texel tie test.
            pixels[(y * width + x) * 4] = .01f + .003f * (x / 4) + .007f * (y / 4);
          texture(0, width, height, pixels);
        };
        depth_input(size[0], size[1]);
        const auto expected = render(reflection_depth_native.data(), reflection_depth_native.size());
        depth_input(W, H);
        const auto uncorrected = render(reflection_depth_native.data(), reflection_depth_native.size());
        const auto actual = run(reflection_depth_code.Get());
        float error = 0, original_error = 0;
        for (UINT y = 0; y < quarter_height; ++y) for (UINT x = 0; x < quarter_width; ++x)
          for (UINT c = 0; c < 4; ++c) {
            const size_t i = (y * W + x) * 4 + c;
            if (!std::isfinite(actual[i])) throw std::runtime_error("Nonfinite reflection depth");
            error = std::max(error, std::abs(expected[i] - actual[i]));
            original_error = std::max(original_error, std::abs(expected[i] - uncorrected[i]));
          }
        if (error > .000001f || (size[0] < W && original_error < .5f))
          throw std::runtime_error("Reflection depth physical-pool mismatch: " + std::to_string(error));
        std::cout << "Reflection depth " << size[0] << 'x' << size[1]
                  << ": corrected error=" << error << ", original pool error=" << original_error << '\n';
      }
      ctx->PSSetSamplers(0, 1, sampler.GetAddressOf());
      ctx->RSSetViewports(1, &vp);
      std::cout << "PASS reflection depth native/full size and three physical render pools with poisoned unused depth\n";

      // Water's quarter-resolution history lives in a FULL-resolution scratch
      // texture. Compare with native rendering into a physically smaller pool,
      // poisoning the unused history with the exact observed yellow clear.
      const auto water_native = Read(blitz / "scene-shaders/0x4E0137BC.cso");
      const auto water_code = Compiled("0x4E0137BC.ps_5_0.hlsl");
      const auto prep_native = Read(blitz / "scene-shaders/0xCA115962.cso");
      const auto prep_code = Compiled("0xCA115962.ps_5_0.hlsl");
      std::vector<float> water_matrices(148), water_params(36);
      for (size_t matrix : {96u, 112u}) for (size_t i = 0; i < 4; ++i)
        water_matrices[matrix + i * 5] = 1;
      water_matrices[114] = .2f; water_matrices[118] = .1f;
      water_matrices[1] = 1.f / 60;
      buffer(0, water_matrices);
      for (UINT quarter : {16u, 10u, 8u, 6u}) {
        water_params[0] = water_params[1] = float(quarter);
        water_params[32] = water_params[33] = .25f;
        water_params[34] = water_params[35] = 4;
        buffer(3, water_params);
        D3D11_VIEWPORT water_viewport = {0, 0, float(quarter), float(quarter), 0, 1};
        ctx->RSSetViewports(1, &water_viewport);
        const auto water_inputs = [&](UINT pool_size) {
          for (UINT slot = 0; slot < 4; ++slot) {
            std::vector<float> pixels(pool_size * pool_size * 4);
            const UINT extent = slot == 2 ? quarter : quarter * 4;
            for (UINT y = 0; y < pool_size; ++y) for (UINT x = 0; x < pool_size; ++x) {
              const size_t i = (y * pool_size + x) * 4;
              if (x >= extent || y >= extent) {
                // The live scratch mask is transparent outside its viewport;
                // isolate history poisoning instead of rejecting reprojection
                // via an artificially invalid depth or opaque water mask.
                if (slot == 2) { pixels[i] = pixels[i + 1] = 1000; pixels[i + 3] = 1; }
                if (slot == 3) pixels[i] = .1f;
              } else if (slot == 3) {
                pixels[i] = .1f + .001f * x + .002f * y;
              } else if (slot != 0) {
                for (UINT c = 0; c < 3; ++c)
                  pixels[i + c] = .1f * slot + .01f * x + .02f * y + .03f * c;
              }
            }
            texture(slot, pool_size, pool_size, pixels);
          }
        };
        water_inputs(quarter * 4);
        const auto expected = render(water_native.data(), water_native.size());
        water_inputs(W);
        const auto uncorrected = render(water_native.data(), water_native.size());
        const auto actual = run(water_code.Get());
        float error = 0, old_error = 0;
        for (UINT y = 0; y < quarter; ++y) for (UINT x = 0; x < quarter; ++x)
          for (UINT c = 0; c < 4; ++c) {
            const size_t i = (y * W + x) * 4 + c;
            if (!std::isfinite(actual[i])) throw std::runtime_error("Nonfinite water history");
            error = std::max(error, std::abs(expected[i] - actual[i]));
            old_error = std::max(old_error, std::abs(expected[i] - uncorrected[i]));
          }
        if (error > .0002f) throw std::runtime_error("Water history subrect mismatch at "
            + std::to_string(quarter) + ": " + std::to_string(error));
        std::cout << "Water quarter " << quarter << ": corrected error=" << error << ", original pool error=" << old_error << '\n';
        if (quarter < W / 4 && old_error < 1.f)
          throw std::runtime_error("Water fixture did not reproduce the original yellow-clear history bug");

        buffer(3, {float(quarter), float(quarter), 0, 0, .25f, .25f, 4, 4});
        std::vector<float> reconstructed(W * H * 4);
        for (UINT y = 0; y < H; ++y) for (UINT x = 0; x < W; ++x)
          for (UINT c = 0; c < 4; ++c) reconstructed[(y * W + x) * 4 + c] = .01f * x + .02f * y + .1f * c;
        texture(2, W, H, reconstructed);
        const auto prep_depth = [&](UINT size) {
          std::vector<float> pixels(size * size * 4, .9f);
          for (UINT y = 0; y < quarter * 4; ++y) for (UINT x = 0; x < quarter * 4; ++x)
            pixels[(y * size + x) * 4] = .1f + .001f * x + .002f * y;
          texture(1, size, size, pixels);
        };
        prep_depth(quarter * 4);
        const auto expected_prep = render(prep_native.data(), prep_native.size());
        prep_depth(W);
        const auto actual_prep = run(prep_code.Get());
        for (UINT y = 0; y < quarter; ++y) for (UINT x = 0; x < quarter; ++x)
          for (UINT c = 0; c < 4; ++c) {
            const size_t i = (y * W + x) * 4 + c;
            if (!std::isfinite(actual_prep[i]) || std::abs(expected_prep[i] - actual_prep[i]) > .0002f)
              throw std::runtime_error("Water prep mixed depth/output-color domain mismatch");
          }
      }
      ctx->RSSetViewports(1, &vp);
      std::cout << "PASS native water history/prep against physical render pools, reprojection, four sizes and yellow-clear poisoning\n";

      // Refraction may leave the viewport. Compare pool sampling with a
      // physically cropped texture, including out-of-range UVs and filter edges.
      const auto pool_header = Read("src/games/thewitcher3classic/blitzfx/scene_pool.hlsli");
      const std::string pool_test = std::string(pool_header.begin(), pool_header.end()) + R"(
Texture2D<float4> scene_color : register(t0);
SamplerState scene_sampler : register(s0);
cbuffer Sizes : register(b3) { float4 sizes; }
float4 main(float4 pos : SV_Position) : SV_Target {
  float2 uv = pos.xy / 64.f * 1.2f - .1f;
  return scene_color.SampleLevel(scene_sampler, BlitzScenePoolUV(uv, sizes.xy, sizes.zw), 0);
})";
      ComPtr<ID3DBlob> pool_code;
      Check(D3DCompile(pool_test.data(), pool_test.size(), nullptr, nullptr, nullptr, "main", "ps_5_0", 0, 0, &pool_code, nullptr));
      for (UINT active_size : {64u, 42u, 38u, 32u, 22u}) {
        const auto pool_inputs = [&](UINT pool_size) {
          std::vector<float> pixels(pool_size * pool_size * 4, 10000.f);
          for (UINT y = 0; y < active_size; ++y) for (UINT x = 0; x < active_size; ++x)
            for (UINT c = 0; c < 4; ++c)
              pixels[(y * pool_size + x) * 4 + c] = .01f * x + .02f * y + .1f * c;
          texture(0, pool_size, pool_size, pixels);
          buffer(3, {float(active_size), float(active_size), float(pool_size), float(pool_size)});
        };
        pool_inputs(active_size);
        const auto expected = run(pool_code.Get());
        pool_inputs(W);
        const float pool_error = Difference(expected, run(pool_code.Get()));
        // D3D11 samplers quantize interpolation weights to finite subtexel
        // precision; differently sized textures can round opposite ways.
        if (pool_error > .0002f)
          throw std::runtime_error("BlitzFX refraction pool/filter-border mismatch at "
              + std::to_string(active_size) + ": " + std::to_string(pool_error));
      }
      std::cout << "PASS BlitzFX refraction sampling against physical crop, five sizes and poisoned filter borders\n";

      // Compare the actual bloom CS against the original shader operating on
      // physically render-sized textures. Poison the unused pool rectangle:
      // a wrong UV or bilinear border must not leak stale pixels into bloom.
      const auto bloom_native = Read(blitz / "scene-shaders/0xBF3EF83C.cso");
      const auto bloom_code = Compiled("0xBF3EF83C.cs_5_0.hlsl");
      td.BindFlags = D3D11_BIND_UNORDERED_ACCESS; td.Usage = D3D11_USAGE_DEFAULT; td.CPUAccessFlags = 0;
      ComPtr<ID3D11Texture2D> compute_target;
      Check(dev->CreateTexture2D(&td, nullptr, &compute_target));
      ComPtr<ID3D11UnorderedAccessView> uav;
      Check(dev->CreateUnorderedAccessView(compute_target.Get(), nullptr, &uav));
      ID3D11SamplerState* compute_sampler = sampler.Get();
      const auto compute_render = [&](const void* bytes, size_t count, UINT active_size) {
        ComPtr<ID3D11ComputeShader> cs;
        Check(dev->CreateComputeShader(bytes, count, nullptr, &cs));
        ctx->CSSetShader(cs.Get(), nullptr, 0);
        for (UINT slot : {0u, 1u, 2u, 42u, 43u, 44u, 51u, 52u, 69u}) {
          ComPtr<ID3D11ShaderResourceView> srv;
          ctx->PSGetShaderResources(slot, 1, &srv); ctx->CSSetShaderResources(slot, 1, srv.GetAddressOf());
        }
        for (UINT slot : {0u, 1u, 2u, 13u}) {
          ComPtr<ID3D11Buffer> cb;
          ctx->PSGetConstantBuffers(slot, 1, &cb); ctx->CSSetConstantBuffers(slot, 1, cb.GetAddressOf());
        }
        ctx->CSSetSamplers(0, 1, &compute_sampler);
        const float zero[4] = {};
        ctx->ClearUnorderedAccessViewFloat(uav.Get(), zero);
        ctx->CSSetUnorderedAccessViews(0, 1, uav.GetAddressOf(), nullptr);
        ctx->Dispatch((active_size + 7) / 8, (active_size + 7) / 8, 1);
        ID3D11UnorderedAccessView* null_uav = nullptr;
        ctx->CSSetUnorderedAccessViews(0, 1, &null_uav, nullptr);
        ctx->CopyResource(staging.Get(), compute_target.Get());
        D3D11_MAPPED_SUBRESOURCE mapped;
        Check(ctx->Map(staging.Get(), 0, D3D11_MAP_READ, 0, &mapped));
        std::vector<float> result(active_size * active_size * 4);
        for (UINT y = 0; y < active_size; ++y)
          std::memcpy(result.data() + y * active_size * 4, static_cast<char*>(mapped.pData) + y * mapped.RowPitch, active_size * 16);
        ctx->Unmap(staging.Get(), 0);
        return result;
      };
      for (UINT active_size : {64u, 42u, 38u, 32u, 22u}) {
        frame.resize(96); frame[92] = frame[93] = float(active_size);
        frame[94] = frame[95] = 1.f / active_size; buffer(0, frame);
        std::vector<float> bloom_custom(184);
        bloom_custom[168] = .1f; bloom_custom[182] = .4f; buffer(2, bloom_custom);
        const auto inputs = [&](UINT pool_size) {
          buffer(1, {float(pool_size / 2), float(pool_size / 2), 2.f / pool_size, 2.f / pool_size});
          for (UINT slot : {0u, 51u, 52u}) {
            const UINT size = slot == 51 ? pool_size / 2 : pool_size;
            const UINT extent = slot == 51 ? active_size / 2 : active_size;
            std::vector<float> pixels(size * size * 4, 10000.f);
            for (UINT y = 0; y < extent; ++y) for (UINT x = 0; x < extent; ++x) {
              const size_t i = (y * size + x) * 4;
              for (UINT c = 0; c < 4; ++c)
                pixels[i + c] = slot == 0 ? .3f : .01f * x + .02f * y + .1f * c;
            }
            texture(slot, size, size, pixels);
          }
        };
        // The slider replaces only BloomScattering. Compare each setting to
        // the original shader with that absolute value, including underwater
        // scattering, then vary BlitzFX's setting without changing the result.
        for (float underwater : {0.f, .4f}) {
          bloom_custom[182] = underwater;
          for (float strength : {0.f, .1f, .5f, 1.f, 2.f}) {
            bloom_custom[168] = strength * .5f; buffer(2, bloom_custom);
            inputs(active_size);
            const auto expected = compute_render(bloom_native.data(), bloom_native.size(), active_size);
            inputs(W);
            injection.custom_bloom = strength; inject();
            for (float blitz_setting : {0.f, .01f, .1f, .5f, 1.f}) {
              bloom_custom[168] = blitz_setting; buffer(2, bloom_custom);
              const auto actual = compute_render(bloom_code->GetBufferPointer(), bloom_code->GetBufferSize(), active_size);
              if (Difference(expected, actual) > .00001f)
                throw std::runtime_error("BlitzFX absolute bloom/subrect/underwater mismatch at " + std::to_string(active_size));
              if (strength == 0.f && underwater == 0.f) {
                for (UINT y = 0; y < active_size; ++y) for (UINT x = 0; x < active_size; ++x) for (UINT c = 0; c < 4; ++c) {
                  const float scene_value = .01f * x + .02f * y + .1f * (c == 3 ? 0 : c);
                  if (std::abs(actual[(y * active_size + x) * 4 + c] - scene_value) > 1e-6f)
                    throw std::runtime_error("BlitzFX Bloom zero changed the unscattered scene");
                }
              }
            }
          }
        }
        // DevKit-only replacement has no injected controls: keep native values.
        const float saved_peak = injection.peak_white_nits;
        injection.peak_white_nits = 0; inject();
        inputs(active_size);
        const auto expected = compute_render(bloom_native.data(), bloom_native.size(), active_size);
        inputs(W);
        if (Difference(expected, compute_render(bloom_code->GetBufferPointer(), bloom_code->GetBufferSize(), active_size)) > .00001f)
          throw std::runtime_error("BlitzFX bloom without injection changed native strength");
        injection.peak_white_nits = saved_peak; inject();
      }
      injection = saved_injection; inject();
      ctx->CSSetShader(nullptr, nullptr, 0);
      std::cout << "PASS BlitzFX absolute bloom: five slider levels independent of five BlitzFX values, underwater isolation, injection fallback and five poisoned subrects\n";
      const auto shadow_native = Read(blitz / "scene-shaders/0x4708B025.cso");
      const auto shadow_code = Compiled("0x4708B025.cs_5_0.hlsl");
      std::vector<float> shadow_frame(840), shadow_matrices(128);
      shadow_frame[84] = shadow_frame[88] = 1;
      for (UINT i = 0; i < 4; ++i) shadow_frame[824 + i * 5] = 1;
      for (UINT start : {80u, 112u}) for (UINT i = 0; i < 4; ++i) shadow_matrices[start + i * 5] = 1;
      shadow_matrices[1] = 1.f / 60;
      buffer(1, shadow_matrices);
      for (UINT active_size : {64u, 42u, 38u, 32u, 22u}) {
        shadow_frame[92] = shadow_frame[93] = float(active_size);
        shadow_frame[94] = shadow_frame[95] = 1.f / active_size; buffer(0, shadow_frame);
        const auto shadow_inputs = [&](UINT pool_size) {
          for (UINT slot : {0u, 42u, 43u, 44u}) {
            std::vector<float> pixels(pool_size * pool_size * 4, 1000.f);
            for (UINT y = 0; y < active_size; ++y) for (UINT x = 0; x < active_size; ++x) {
              const float value = slot == 0 ? .25f : slot == 44 ? 4.f
                  : slot == 42 ? .1f + .01f * x + .002f * y : float((x + y) % 2);
              for (UINT c = 0; c < 4; ++c) pixels[(y * pool_size + x) * 4 + c] = value;
            }
            texture(slot, pool_size, pool_size, pixels);
          }
        };
        shadow_inputs(active_size);
        const auto expected = compute_render(shadow_native.data(), shadow_native.size(), active_size);
        shadow_inputs(W);
        const auto actual = compute_render(shadow_code->GetBufferPointer(), shadow_code->GetBufferSize(), active_size);
        const auto uncorrected = compute_render(shadow_native.data(), shadow_native.size(), active_size);
        float error = 0, old_error = 0;
        // Gather intentionally moves the outermost footprint inward to avoid
        // touching a stale neighbor. Compare interior samples against native.
        for (UINT y = 1; y + 1 < active_size; ++y) for (UINT x = 1; x + 1 < active_size; ++x) {
          const size_t i = (y * active_size + x) * 4;
          if (!std::isfinite(actual[i])) throw std::runtime_error("Nonfinite shadow history");
          error = std::max(error, std::abs(expected[i] - actual[i]));
          old_error = std::max(old_error, std::abs(expected[i] - uncorrected[i]));
        }
        if (error > .0002f) throw std::runtime_error("Shadow history subrect mismatch: " + std::to_string(error));
        if (active_size < W && old_error < .05f)
          throw std::runtime_error("Shadow fixture did not reproduce the uncorrected history mismatch");
      }
      std::cout << "PASS shadow history original/full size and four physical render pools with poisoned history/depth\n";
      const auto contact_native = Read(blitz / "scene-shaders/0x58959EAD.cso");
      const auto contact_code = Compiled("0x58959EAD.cs_5_0.hlsl");
      D3D11_SAMPLER_DESC point_desc = sd;
      point_desc.Filter = D3D11_FILTER_MIN_MAG_MIP_POINT;
      point_desc.AddressU = point_desc.AddressV = point_desc.AddressW = D3D11_TEXTURE_ADDRESS_BORDER;
      ComPtr<ID3D11SamplerState> point_sampler;
      Check(dev->CreateSamplerState(&point_desc, &point_sampler));
      compute_sampler = point_sampler.Get();
      D3D11_TEXTURE2D_DESC stencil_desc = td;
      stencil_desc.Format = DXGI_FORMAT_R32G32B32A32_UINT;
      stencil_desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
      std::vector<uint32_t> stencil(W * H * 4);
      D3D11_SUBRESOURCE_DATA stencil_data = {stencil.data(), W * 16};
      ComPtr<ID3D11Texture2D> stencil_texture;
      Check(dev->CreateTexture2D(&stencil_desc, &stencil_data, &stencil_texture));
      ComPtr<ID3D11ShaderResourceView> stencil_view;
      Check(dev->CreateShaderResourceView(stencil_texture.Get(), nullptr, &stencil_view));
      ctx->PSSetShaderResources(1, 1, stencil_view.GetAddressOf());
      texture(69, 256, 256, std::vector<float>(256 * 256 * 4, .3f));
      std::vector<float> contact_matrices(96);
      for (UINT i = 0; i < 4; ++i) contact_matrices[80 + i * 5] = 1;
      contact_matrices[90] = contact_matrices[95] = 0;
      contact_matrices[91] = contact_matrices[94] = 1;
      buffer(2, contact_matrices);
      buffer(1, {.5f, 0, -.8660254f, 1});
      shadow_frame[0] = shadow_frame[1] = .5f; shadow_frame[2] = 3;
      shadow_frame[834] = shadow_frame[839] = 0;
      shadow_frame[835] = shadow_frame[838] = 1;  // Perspective: raw depth = 1 / view depth.
      for (UINT active_size : {64u, 42u, 32u}) {
        shadow_frame[92] = shadow_frame[93] = float(active_size);
        shadow_frame[94] = shadow_frame[95] = 1.f / active_size; buffer(0, shadow_frame);
        const auto contact_inputs = [&](UINT pool_size) {
          for (UINT slot : {0u, 2u, 42u, 43u}) {
            std::vector<float> pixels(pool_size * pool_size * 4);
            for (UINT y = 0; y < pool_size; ++y) for (UINT x = 0; x < pool_size; ++x) {
              const size_t i = (y * pool_size + x) * 4;
              if (slot == 0) pixels[i] = .25f;
              if (slot == 2) pixels[i + 3] = float(x % 4) / 255;
              if (slot == 42) pixels[i] = 1;
              if (slot == 43) {
                pixels[i] = x < active_size && y < active_size ? 3.8f + .01f * float((x / 3 + y / 3) % 3) : 1000.f;
                const uint32_t normals[] = {0x4080FFFFu, 0x40FF80FFu, 0x3FFF80FFu, 0x400080FFu};
                const uint32_t packed = normals[(x / 5 + y / 5) % 4];
                std::memcpy(&pixels[i + 1], &packed, sizeof(packed));
              }
            }
            texture(slot, pool_size, pool_size, pixels);
          }
        };
        contact_inputs(active_size);
        const auto expected = compute_render(contact_native.data(), contact_native.size(), active_size);
        contact_inputs(W);
        const auto actual = compute_render(contact_code->GetBufferPointer(), contact_code->GetBufferSize(), active_size);
        const float error = Difference(expected, actual);
        std::cout << "Contact-shadow size " << active_size << ": native minimum="
                  << *std::min_element(expected.begin(), expected.end()) << ", error=" << error << '\n';
        if (*std::min_element(expected.begin(), expected.end()) >= .999f)
          throw std::runtime_error("Contact-shadow fixture did not exercise occlusion");
        if (error > .0002f) throw std::runtime_error("Contact-shadow packed data/native or pool mismatch at "
            + std::to_string(active_size) + ": " + std::to_string(error));
      }
      compute_sampler = sampler.Get();
      std::cout << "PASS contact-shadow native/packed-normal equivalence and three ray-buffer sizes\n";
      injection = saved_injection; inject(); texture(0, W, H, scene);
    }
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

      // Scene grading contribution is independent of the user tonemap controls.
      // At zero, changing native grade constants must not change the result.
      injection.tone_map_type = 1;
      injection.sharpening_mode = injection.chromatic_aberration_mode = injection.film_grain = 0;
      injection.vignette_strength = 0;
      injection.color_grading_strength = 0;
      inject();
      const auto bypass_grade = run(code.Get());
      const auto saved_constants = constants;
      constants[36] = .6f;
      constants[37] = .8f;
      constants[38] = 1.2f;
      constants[60] = .05f;
      constants[61] = .9f;
      buffer(3, constants);
      if (Difference(bypass_grade, run(code.Get())) > .000001f)
        throw std::runtime_error("Native grade leaked at strength zero");
      injection.color_grading_strength = 1;
      inject();
      const auto full_grade = run(code.Get());
      if (Difference(bypass_grade, full_grade) < 1e-5f) throw std::runtime_error("Scene grade strength ineffective");
      injection.color_grading_strength = .5f;
      inject();
      const auto half_grade = run(code.Get());
      if (Difference(bypass_grade, half_grade) < 1e-5f || Difference(full_grade, half_grade) < 1e-5f)
        throw std::runtime_error("Scene grade strength midpoint ineffective");
      constants = saved_constants;
      buffer(3, constants);
      // Keep grading bypassed below: vignette must remain independently active.
      injection.color_grading_strength = 0;
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
      injection.color_grading_strength = 1;
      std::cout << "PASS vignette " << hash << " zero/50/100, black floor and permutation isolation\n";
    }

    // All native LUT permutations: unchanged Vanilla; custom scaling zero
    // matches native grading of the N2 proxy, with range restored only at end.
    for (const char* hash : {"27EF680B", "63047C3C", "65B4CEFA", "E91AAC85", "7526E398", "7818760A"}) {
      auto code = Compiled(fs::path("grading") / (std::string("0x") + hash + ".ps_5_0.hlsl"));
      auto native = Read(root.parent_path() / "hdr-permutations-20261023/cache" / (std::string("0x") + hash + ".cso"));
      std::vector<float> constants(12);
      constants[2] = constants[3] = 1;
      constants[4] = .3f;
      constants[5] = .8f;
      constants[6] = 1.1f;
      constants[8] = .6f;
      constants[9] = .7f;
      constants[10] = .9f;
      for (UINT slot = 1; slot <= 4; ++slot) {
        std::vector<float> atlas(512 * 512 * 4);
        for (UINT y = 0; y < 512; ++y)
          for (UINT x = 0; x < 512; ++x) {
            const size_t i = (y * 512 + x) * 4;
            atlas[i] = .04f * slot + .7f * float(x % 64) / 63;
            atlas[i + 1] = .02f * slot + .8f * float(y % 64) / 63;
            atlas[i + 2] = .01f * slot + .85f * float((y / 64) * 8 + x / 64) / 63;
            atlas[i + 3] = 1;
          }
        texture(slot, 512, 512, atlas);
      }
      for (float blend : {0.f, .239534512f, .5f, 1.f}) {
        constants[11] = blend;
        buffer(3, constants);
        texture(0, W, H, scene);
        injection.tone_map_type = 0;
        injection.lut_scaling = 1;
        inject();
        if (Difference(render(native.data(), native.size()), run(code.Get())) > .00001f)
          throw std::runtime_error(std::string(hash) + " LUT Vanilla mismatch");
        std::vector<float> proxy = scene;
        std::vector<float> scales(W * H);
        for (size_t i = 0; i < scene.size(); i += 4) {
          const float m = std::max({scene[i], scene[i + 1], scene[i + 2]});
          scales[i / 4] = 1.f / std::sqrt(1.f + m * m);
          for (size_t c = 0; c < 3; ++c) proxy[i + c] *= scales[i / 4];
        }
        texture(0, W, H, proxy);
        auto expected = render(native.data(), native.size());
        for (size_t i = 0; i < expected.size(); i += 4)
          for (size_t c = 0; c < 3; ++c) expected[i + c] /= scales[i / 4];
        texture(0, W, H, scene);
        injection.tone_map_type = 1;
        injection.lut_scaling = 0;
        inject();
        if (Difference(expected, run(code.Get())) > .0001f)
          throw std::runtime_error(std::string(hash) + " LUT proxy/blend mismatch");
        injection.lut_scaling = 1;
        inject();
        const auto scaled = run(code.Get());
        if (Difference(expected, scaled) < 1e-5f) throw std::runtime_error("LUT scaling ineffective");
        for (size_t i = 3; i < scaled.size(); i += 4)
          if (scaled[i] != scene[i]) throw std::runtime_error("LUT alpha changed");
      }
      // Raised colored black is removed without introducing signed color residue.
      constants[5] = constants[9] = constants[6] = constants[10] = 1;
      buffer(3, constants);
      texture(0, W, H, std::vector<float>(scene.size()));
      injection.lut_scaling = 1;
      inject();
      const auto black = run(code.Get());
      for (size_t i = 0; i < black.size(); ++i)
        if (i % 4 != 3 && std::abs(black[i]) > 1e-5f) throw std::runtime_error("LUT restored black has residue");
      // Degenerate constant black/white LUTs must not divide by zero.
      for (float value : {0.f, 1.f}) {
        for (UINT slot = 1; slot <= 4; ++slot) texture(slot, 1, 1, {value, value, value, 1});
        texture(0, W, H, scene);
        Difference(run(code.Get()), run(code.Get()));
      }
      // Disabling native LUT strength exposes the reversible gamut/range bridge.
      constants[5] = constants[9] = 0;
      buffer(3, constants);
      auto signed_scene = scene;
      for (size_t i = 0; i < signed_scene.size(); i += 4) {
        signed_scene[i] = -.2f * signed_scene[i + 1];
        signed_scene[i + 2] *= 4;
      }
      texture(0, W, H, signed_scene);
      inject();
      if (Difference(signed_scene, run(code.Get())) > .0001f)
        throw std::runtime_error(std::string(hash) + " signed gamut roundtrip failed");
      // New LUT contribution bypasses the entire grade, irrespective of native
      // blend/gain controls, and interpolates in the reversible linear proxy.
      constants[5] = .8f;
      constants[9] = .7f;
      buffer(3, constants);
      injection.lut_strength = 0;
      inject();
      const auto bypass_lut = run(code.Get());
      if (Difference(signed_scene, bypass_lut) > .000001f) throw std::runtime_error("LUT strength zero did not bypass");
      injection.lut_strength = 1;
      inject();
      const auto full_lut = run(code.Get());
      injection.lut_strength = .5f;
      inject();
      const auto half_lut = run(code.Get());
      auto expected_half = full_lut;
      for (size_t i = 0; i < expected_half.size(); ++i)
        expected_half[i] = .5f * (full_lut[i] + bypass_lut[i]);
      if (Difference(expected_half, half_lut) > .0001f) throw std::runtime_error("LUT strength midpoint blend mismatch");
      injection.lut_strength = 1;
      std::cout << "PASS LUT " << hash << " Vanilla, native proxy blends, scaling, black/degenerate and signed HDR roundtrip\n";
    }
    texture(0, W, H, scene);
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
