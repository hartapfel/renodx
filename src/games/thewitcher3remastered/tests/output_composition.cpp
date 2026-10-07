/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Compares production normal/FG output; optionally sweeps native HDR saturation
// or verifies the three shared FSR outputs against the four-target compositor.
// The former movie texture is transparent, matching gameplay and native UI composition.
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
#include <string>
#include <vector>
#include "../shared.h"

using Microsoft::WRL::ComPtr;
using Pixel = std::array<float, 4>;
constexpr unsigned PIXELS = 512;
void Check(HRESULT result) { if (FAILED(result)) throw std::runtime_error("D3D failure " + std::to_string(result)); }
void Require(bool pass, const char* reason) { if (!pass) throw std::runtime_error(reason); }
int main(int argc, char** argv) {
  try {
    Require(argc == 5 || (argc == 6 && (std::string(argv[5]) == "hdr-saturation" || std::string(argv[5]) == "fsr" || std::string(argv[5]) == "fsr-native")),
            "Expected normal/FG shaders before and after, optionally hdr-saturation, fsr or fsr-native");
    const bool fsr_test = argc == 6 && std::string(argv[5]).starts_with("fsr");
    const bool native_test = argc == 6 && std::string(argv[5]) == "fsr-native";
    ComPtr<ID3D11Device> device;
    ComPtr<ID3D11DeviceContext> context;
    Check(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0,
                           D3D11_SDK_VERSION, &device, nullptr, &context));
    ComPtr<ID3D11ComputeShader> shaders[4];
    for (unsigned i = 0; i < 4; ++i) {
      std::ifstream file(argv[i + 1], std::ios::binary);
      std::vector<char> bytes((std::istreambuf_iterator<char>(file)), {});
      Check(device->CreateComputeShader(bytes.data(), bytes.size(), nullptr, &shaders[i]));
    }
    ComPtr<ID3D11Buffer> cb3, cb12, cb13, output, readback;
    D3D11_BUFFER_DESC cb = {400, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER, 0, 0, 0};
    Check(device->CreateBuffer(&cb, nullptr, &cb3));
    cb.ByteWidth = 5456;
    Check(device->CreateBuffer(&cb, nullptr, &cb12));
    cb.ByteWidth = 128;
    Check(device->CreateBuffer(&cb, nullptr, &cb13));
    context->CSSetConstantBuffers(3, 1, cb3.GetAddressOf());
    context->CSSetConstantBuffers(12, 1, cb12.GetAddressOf());
    context->CSSetConstantBuffers(13, 1, cb13.GetAddressOf());
    std::array<float, 100> native = {};
    native[0] = 203; native[3] = 1000; native[8] = 2.2f; native[10] = 1 / 2.2f;
    native[11] = .18f; native[14] = 32; native[15] = 16;
    native[16] = native[21] = native[26] = 1;
    const bool saturation_test = argc == 6;
    if (saturation_test) {
      const float matrix[] = {1.4023422f, -.37857088f, -.01947296f, 0,
          -.06701347f, 1.08590949f, -.01053586f, 0,
          -.00720287f, -.08839649f, 1.092839f, 0};
      std::copy(std::begin(matrix), std::end(matrix), native.begin() + 16);
    }
    context->UpdateSubresource(cb3.Get(), 0, nullptr, native.data(), 0, 0);
    const std::array<float, 1364> environment = {};
    context->UpdateSubresource(cb12.Get(), 0, nullptr, environment.data(), 0, 0);
    D3D11_BUFFER_DESC result_desc = {PIXELS * 4 * sizeof(Pixel), D3D11_USAGE_DEFAULT,
        D3D11_BIND_UNORDERED_ACCESS, 0, D3D11_RESOURCE_MISC_BUFFER_STRUCTURED, sizeof(Pixel)};
    Check(device->CreateBuffer(&result_desc, nullptr, &output));
    ComPtr<ID3D11UnorderedAccessView> uav;
    Check(device->CreateUnorderedAccessView(output.Get(), nullptr, &uav));
    context->CSSetUnorderedAccessViews(0, 1, uav.GetAddressOf(), nullptr);
    result_desc.Usage = D3D11_USAGE_STAGING; result_desc.BindFlags = 0;
    result_desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ; result_desc.MiscFlags = 0;
    Check(device->CreateBuffer(&result_desc, nullptr, &readback));
    ComPtr<ID3D11SamplerState> sampler;
    D3D11_SAMPLER_DESC sd = {};
    sd.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sd.AddressU = sd.AddressV = sd.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    sd.MaxLOD = D3D11_FLOAT32_MAX;
    Check(device->CreateSamplerState(&sd, &sampler));
    context->CSSetSamplers(1, 1, sampler.GetAddressOf());
    ComPtr<ID3D11Texture2D> textures[4];
    ComPtr<ID3D11ShaderResourceView> views[4];
    D3D11_TEXTURE2D_DESC td = {32, 16, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0},
        D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE, 0, 0};
    std::array<Pixel, PIXELS> black = {}, scene = {}, ui = {};
    for (unsigned i = 0; i < 4; ++i) {
      Check(device->CreateTexture2D(&td, nullptr, &textures[i]));
      Check(device->CreateShaderResourceView(textures[i].Get(), nullptr, &views[i]));
      context->CSSetShaderResources(i, 1, views[i].GetAddressOf());
      context->UpdateSubresource(textures[i].Get(), 0, nullptr, black.data(), 32 * sizeof(Pixel), 0);
    }
    struct { ShaderInjectData data; float padding[1]; } settings = {};
    static_assert(sizeof(settings) == 128);
    auto& p = settings.data;
    p.tone_map_type = 1;
    p.tone_map_exposure = p.tone_map_gamma = p.tone_map_highlights = p.tone_map_shadows = 1;
    p.tone_map_contrast = p.tone_map_saturation = p.tone_map_highlight_saturation = 1;
    p.psychov_hue_shift = p.psychov_cone_response_exponent = p.psychov_gamut_compression = 1;
    p.psychov_adaptation_anchor = p.psychov_background_anchor = .18f;
    p.effect_strengths = std::bit_cast<float>((50u << 21) | (50u << 14) | (50u << 7) | 50u);
    unsigned cases = 0;
    float worst = 0;
    for (float peak : {400.f, 1000.f, 4000.f}) for (float game : {80.f, 203.f, 500.f})
    for (unsigned mode : {0u, 1u}) for (unsigned gamut : {0u, 1u})
    for (float ui_opacity : {0.f, .25f, 1.f}) for (float ui_white : {80.f, 203.f, 500.f}) {
      if (native_test && mode != 0) continue;
      std::vector<Pixel> neutral[2];
      for (float native_saturation : {0.f, .5f, 1.f}) {
        if (!saturation_test && native_saturation != 0.f) continue;
        native[2] = native_saturation;
        context->UpdateSubresource(cb3.Get(), 0, nullptr, native.data(), 0, 0);
        p.tone_map_type = float(mode);
        p.peak_white_nits = peak; p.diffuse_white_nits = game; p.graphics_white_nits = ui_white;
        p.mode_flags = std::bit_cast<float>((gamut ? WITCHER_FLAG_GAMUT_TARGET : 0u) | (50u << 7) | (50u << 14));
        context->UpdateSubresource(cb13.Get(), 0, nullptr, &settings, 0, 0);
        for (unsigned i = 0; i < PIXELS; ++i) {
          float ramp = float(i % 256) / 255.f;
          scene[i] = i < 256 ? Pixel{ramp * 3, ramp * 3, ramp * 3, 1}
                            : Pixel{ramp * 3, (1 - ramp) * 3, .13f, 1};
          if (fsr_test && mode == 1 && i >= 384) {
            scene[i] = {ramp * 5, (1 - ramp) * 3 - .3f, -.2f, 1};
          }
          ui[i] = {.7f, .4f, .1f, ui_opacity};
        }
        context->UpdateSubresource(textures[0].Get(), 0, nullptr, scene.data(), 32 * sizeof(Pixel), 0);
        context->UpdateSubresource(textures[1].Get(), 0, nullptr, ui.data(), 32 * sizeof(Pixel), 0);
        std::vector<Pixel> values[4];
        for (unsigned pass = 0; pass < 4; ++pass) {
          context->CSSetShader(shaders[pass].Get(), nullptr, 0);
          context->Dispatch(8, 1, 1);
          context->CopyResource(readback.Get(), output.Get());
          D3D11_MAPPED_SUBRESOURCE mapped;
          Check(context->Map(readback.Get(), 0, D3D11_MAP_READ, 0, &mapped));
          values[pass].assign(static_cast<const Pixel*>(mapped.pData), static_cast<const Pixel*>(mapped.pData) + PIXELS * 4);
          context->Unmap(readback.Get(), 0);
        }
        for (unsigned i = 0; i < PIXELS * 4; ++i) for (unsigned c = 0; c < 4; ++c) {
          for (unsigned pass = 0; pass < 2; ++pass) {
            if (fsr_test && pass == 1 && i % 4 == 3) continue;
            float a = values[pass][i][c], b = values[pass + 2][i][c];
            Require(std::isfinite(a) && std::isfinite(b), "Nonfinite scene/UI output");
            worst = std::max(worst, std::abs(a - b));
            if (!saturation_test || mode == 0 || native_saturation == 0.f) {
              Require(std::abs(a - b) < 2e-5, "Changed native UI or scene composition");
            }
            if (saturation_test && mode == 1 && native_saturation != 0.f) {
              Require(std::abs(b - neutral[pass][i][c]) < 1e-6, "Native HDR saturation affects custom output");
            }
          }
          if (i % 4 < 2) Require(std::abs(values[2][i][c] - values[3][i][c]) < 2e-5, "Normal/FG primary or secondary mismatch");
          if (!fsr_test && i % 4 == 3) Require(std::abs(values[3][i][c] - ui_opacity) < 1e-6, "Wrong native FG UI mask");
        }
        if (native_saturation == 0.f) {
          neutral[0] = values[2];
          neutral[1] = values[3];
        }
        ++cases;
      }
    }
    std::cout << "PASS " << cases << " configurations / " << cases * PIXELS * 4
              << " output pixels; " << (saturation_test ? "maximum intentional difference=" : "maximum error=")
              << worst << "\n";
  } catch (const std::exception& error) {
    std::cerr << "FAIL " << error.what() << '\n';
    return 1;
  }
}
