/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Execute the original and production Photo Mode shader on D3D11 WARP.
#define NOMINMAX
#include <d3d11.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <bit>
#include <cmath>
#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <vector>
#include "../shared.h"
using Microsoft::WRL::ComPtr;
using Pixel = std::array<float, 4>;
void Check(HRESULT hr) { if (FAILED(hr)) throw std::runtime_error("D3D failure"); }
void Require(bool ok, const char* why) { if (!ok) throw std::runtime_error(why); }
int main(int argc, char** argv) {
  try {
    Require(argc == 3, "Expected original and production Photo Mode compute shaders");
    ComPtr<ID3D11Device> d;
    ComPtr<ID3D11DeviceContext> c;
    Check(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0,
                          D3D11_SDK_VERSION, &d, nullptr, &c));
    ComPtr<ID3D11ComputeShader> shaders[2];
    for (unsigned i = 0; i < 2; ++i) {
      std::ifstream f(argv[i + 1], std::ios::binary);
      std::vector<char> bytes((std::istreambuf_iterator<char>(f)), {});
      Check(d->CreateComputeShader(bytes.data(), bytes.size(), nullptr, &shaders[i]));
    }
    ComPtr<ID3D11Buffer> cb3, cb13, output, read;
    D3D11_BUFFER_DESC desc = {400, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER, 0, 0, 0};
    Check(d->CreateBuffer(&desc, nullptr, &cb3));
    desc.ByteWidth = 128;
    Check(d->CreateBuffer(&desc, nullptr, &cb13));
    c->CSSetConstantBuffers(3, 1, cb3.GetAddressOf());
    c->CSSetConstantBuffers(13, 1, cb13.GetAddressOf());
    desc = {512 * sizeof(Pixel), D3D11_USAGE_DEFAULT, D3D11_BIND_UNORDERED_ACCESS,
            0, D3D11_RESOURCE_MISC_BUFFER_STRUCTURED, sizeof(Pixel)};
    Check(d->CreateBuffer(&desc, nullptr, &output));
    ComPtr<ID3D11UnorderedAccessView> uav;
    Check(d->CreateUnorderedAccessView(output.Get(), nullptr, &uav));
    c->CSSetUnorderedAccessViews(0, 1, uav.GetAddressOf(), nullptr);
    desc.Usage = D3D11_USAGE_STAGING; desc.BindFlags = 0;
    desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ; desc.MiscFlags = 0;
    Check(d->CreateBuffer(&desc, nullptr, &read));
    ComPtr<ID3D11Texture2D> texture;
    ComPtr<ID3D11ShaderResourceView> view;
    D3D11_TEXTURE2D_DESC td = {32, 16, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0},
        D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE, 0, 0};
    Check(d->CreateTexture2D(&td, nullptr, &texture));
    Check(d->CreateShaderResourceView(texture.Get(), nullptr, &view));
    c->CSSetShaderResources(0, 1, view.GetAddressOf());
    D3D11_SAMPLER_DESC sd = {};
    sd.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sd.AddressU = sd.AddressV = sd.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    sd.MaxLOD = D3D11_FLOAT32_MAX;
    ComPtr<ID3D11SamplerState> sampler;
    Check(d->CreateSamplerState(&sd, &sampler));
    c->CSSetSamplers(1, 1, sampler.GetAddressOf());
    std::array<Pixel, 512> source;
    for (unsigned i = 0; i < source.size(); ++i) {
      float value = float(i % 64) / 63.f * std::exp2(float(i / 64));
      source[i] = {value, value * .37f, value * (i % 3 == 0 ? -.03f : .08f), float(i % 7) / 6.f};
    }
    c->UpdateSubresource(texture.Get(), 0, nullptr, source.data(), 32 * sizeof(Pixel), 0);
    std::array<float, 100> native = {};
    native[32] = 1.f / 2.2f;
    native[36] = native[37] = native[38] = 1;
    native[41] = native[43] = 1;
    std::fill(native.begin() + 44, native.begin() + 56, 1.f);
    native[56] = native[58] = native[61] = 1;
    native[68] = native[69] = .5f;
    native[75] = 6550;
    native[77] = 1; native[78] = 32; native[79] = 16;
    struct { ShaderInjectData data; float pad[3]; } settings = {};
    settings.data.peak_white_nits = 1000;
    settings.data.diffuse_white_nits = 203;
    settings.data.custom_color_grading = 1;
    settings.data.mode_flags = std::bit_cast<float>((50u << 7) | (50u << 14));
    auto run = [&](unsigned shader) {
      c->UpdateSubresource(cb3.Get(), 0, nullptr, native.data(), 0, 0);
      c->UpdateSubresource(cb13.Get(), 0, nullptr, &settings, 0, 0);
      c->CSSetShader(shaders[shader].Get(), nullptr, 0);
      c->Dispatch(8, 1, 1);
      c->CopyResource(read.Get(), output.Get());
      D3D11_MAPPED_SUBRESOURCE map;
      Check(c->Map(read.Get(), 0, D3D11_MAP_READ, 0, &map));
      std::vector<Pixel> result(static_cast<Pixel*>(map.pData), static_cast<Pixel*>(map.pData) + 512);
      c->Unmap(read.Get(), 0);
      for (unsigned i = 0; i < result.size(); ++i) {
        for (float v : result[i]) Require(std::isfinite(v), "Nonfinite Photo Mode output");
        Require(result[i][3] == source[i][3], "Photo Mode changed source alpha");
      }
      return result;
    };
    unsigned cases = 0;
    for (float exposure : {0.f, 1.f, 2.f}) for (float contrast : {.5f, 1.f, 1.5f})
    for (float saturation : {0.f, 1.f, 2.f}) for (float temperature : {3000.f, 6550.f, 10000.f})
    for (bool night_grade : {false, true}) {
      native[72] = exposure; native[73] = contrast;
      native[74] = saturation; native[75] = temperature;
      for (unsigned offset : {44u, 48u, 52u}) {
        native[offset] = night_grade ? .8f : 1.f;
        native[offset + 1] = night_grade ? 1.2f : 1.f;
        native[offset + 2] = night_grade ? .6f : 1.f;
        native[offset + 3] = night_grade ? 1.5f : 1.f;
      }
      settings.data.mode_flags = std::bit_cast<float>(std::bit_cast<uint32_t>(settings.data.mode_flags) & ~WITCHER_FLAG_PSYCHOV);
      auto original = run(0), vanilla = run(1);
      for (unsigned i = 0; i < 512; ++i) for (unsigned k = 0; k < 4; ++k) {
        Require(std::abs(original[i][k] - vanilla[i][k]) < 2e-5f, "Vanilla Photo Mode changed");
      }
      settings.data.mode_flags = std::bit_cast<float>(std::bit_cast<uint32_t>(settings.data.mode_flags) | WITCHER_FLAG_PSYCHOV);
      run(1);
      ++cases;
    }
    native[72] = native[73] = native[74] = 1; native[75] = 6550;
    settings.data.custom_color_grading = 0;
    auto neutral = run(1);
    Require(neutral[510][0] > 1.f, "Lost HDR range");
    Require(neutral[510][2] < 0.f, "Lost signed gamut");
    native[72] = 2;
    auto doubled = run(1);
    for (unsigned i = 0; i < 512; ++i) for (unsigned k = 0; k < 3; ++k) {
      Require(std::abs(doubled[i][k] - neutral[i][k] * std::pow(2.f, 1.f/2.2f)) < 2e-5f,
              "Photo Mode exposure no longer scales linear HDR");
    }
    std::cout << "PASS " << cases << " Photo Mode cases; Vanilla, alpha, finite signed HDR and exposure\n";
  } catch (const std::exception& e) { std::cerr << "FAIL " << e.what() << '\n'; return 1; }
}
