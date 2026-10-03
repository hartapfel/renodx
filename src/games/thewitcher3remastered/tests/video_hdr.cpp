/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Runs both production output shaders through WARP, including their PQ encode.
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
double Nits(float pq) {
  double v = std::pow(pq, 1. / 78.84375);
  return 10000 * std::pow(std::max(v - .8359375, 0.) / (18.8515625 - 18.6875 * v), 1. / .1593017578125);
}

int main(int argc, char** argv) {
  try {
    Require(argc == 3, "Expected normal and frame-generation output compute shaders");
    ComPtr<ID3D11Device> device;
    ComPtr<ID3D11DeviceContext> context;
    Check(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0,
                           D3D11_SDK_VERSION, &device, nullptr, &context));
    ComPtr<ID3D11ComputeShader> shaders[2];
    for (unsigned i = 0; i < 2; ++i) {
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
    std::array<Pixel, PIXELS> black = {}, video = {}, ui = {};
    for (unsigned i = 0; i < 4; ++i) {
      Check(device->CreateTexture2D(&td, nullptr, &textures[i]));
      Check(device->CreateShaderResourceView(textures[i].Get(), nullptr, &views[i]));
      context->CSSetShaderResources(i, 1, views[i].GetAddressOf());
      context->UpdateSubresource(textures[i].Get(), 0, nullptr, black.data(), 32 * sizeof(Pixel), 0);
    }
    struct { ShaderInjectData data; float padding[2]; } settings = {};
    static_assert(sizeof(settings) == 128);
    auto& p = settings.data;
    p.tone_map_type = 1;
    p.tone_map_exposure = p.tone_map_gamma = p.tone_map_highlights = p.tone_map_shadows = 1;
    p.tone_map_contrast = p.tone_map_saturation = p.tone_map_highlight_saturation = 1;
    p.psychov_hue_shift = p.psychov_cone_response_exponent = p.psychov_gamut_compression = 1;
    p.psychov_adaptation_anchor = p.psychov_background_anchor = .18f;
    p.effect_strengths = std::bit_cast<float>((50u << 21) | (50u << 14) | (50u << 7) | 50u);
    unsigned cases = 0;
    double worst_parity = 0, worst_endpoint = 0;
    std::vector<Pixel> ui_reference;
    for (float peak : {400.f, 1000.f, 4000.f}) for (float game : {80.f, 203.f, 500.f})
    for (unsigned hdr : {0u, 1u}) for (unsigned gamut : {0u, 1u})
    for (float opacity : {0.f, .37f, 1.f}) for (float ui_opacity : {0.f, .25f, 1.f})
    for (float ui_white : {80.f, 203.f, 500.f}) {
      p.peak_white_nits = peak; p.diffuse_white_nits = game; p.graphics_white_nits = ui_white;
      p.mode_flags = std::bit_cast<float>((hdr ? WITCHER_FLAG_VIDEO_AUTO_HDR : 0u)
          | (gamut ? WITCHER_FLAG_GAMUT_TARGET : 0u) | (50u << 7) | (50u << 14));
      context->UpdateSubresource(cb13.Get(), 0, nullptr, &settings, 0, 0);
      for (unsigned i = 0; i < PIXELS; ++i) {
        float ramp = float(i % 256) / 255.f;
        video[i] = i < 256 ? Pixel{ramp * opacity, ramp * opacity, ramp * opacity, opacity}
                          : Pixel{ramp * opacity, (1 - ramp) * opacity, .13f * opacity, opacity};
        ui[i] = {.7f, .7f, .7f, ui_opacity};
      }
      context->UpdateSubresource(textures[1].Get(), 0, nullptr, ui.data(), 32 * sizeof(Pixel), 0);
      context->UpdateSubresource(textures[3].Get(), 0, nullptr, video.data(), 32 * sizeof(Pixel), 0);
      std::vector<Pixel> values[2];
      for (unsigned pass = 0; pass < 2; ++pass) {
        context->CSSetShader(shaders[pass].Get(), nullptr, 0);
        context->Dispatch(8, 1, 1);
        context->CopyResource(readback.Get(), output.Get());
        D3D11_MAPPED_SUBRESOURCE mapped;
        Check(context->Map(readback.Get(), 0, D3D11_MAP_READ, 0, &mapped));
        values[pass].assign(static_cast<const Pixel*>(mapped.pData), static_cast<const Pixel*>(mapped.pData) + PIXELS * 4);
        context->Unmap(readback.Get(), 0);
      }
      if (ui_white == 80) ui_reference = values[0];
      for (unsigned i = 0; i < PIXELS; ++i) {
        for (unsigned c = 0; c < 8; ++c) {
          float a = values[0][i * 4 + c / 4][c % 4], b = values[1][i * 4 + c / 4][c % 4];
          Require(std::isfinite(a) && std::isfinite(b), "Nonfinite video output");
          worst_parity = std::max(worst_parity, double(std::abs(a - b)));
          Require(std::abs(a - b) < 2e-5, "Normal/FG output mismatch");
        }
        for (unsigned c = 0; c < 3; ++c) {
          double actual = Nits(values[0][i * 4][c]);
          Require(actual >= 0 && actual < peak + .5, "Video exceeds display range");
          if (ui_opacity == 0) Require(values[0][i * 4][c] == ui_reference[i * 4][c], "UI Brightness changed video");
          if (i < 256 && (hdr == 0 || i == 0 || i == 255 || opacity == 0 || ui_opacity == 1)) {
            double movie = hdr ? (i == 255 ? peak : 0) : std::pow(double(i) / 255., 2.2) * game;
            double expected = std::min(double(peak), movie * opacity * (1 - ui_opacity)
                + std::pow(.7, 2.2) * ui_white * ui_opacity);
            worst_endpoint = std::max(worst_endpoint, std::abs(actual - expected));
            Require(std::abs(actual - expected) < .5, "Wrong video/UI brightness or fade");
          }
          // The native float PQ encode has small roundoff after blending a
          // nearly black video sample over a much brighter subtitle.
          if (i > 0 && i < 256 && actual + .02 < Nits(values[0][(i - 1) * 4][c])) {
            std::cerr << "peak=" << peak << " game=" << game << " hdr=" << hdr << " gamut=" << gamut
                      << " alpha=" << opacity << " ui_alpha=" << ui_opacity << " ui=" << ui_white << " pixel=" << i
                      << " nits=" << Nits(values[0][(i - 1) * 4][c]) << " -> " << actual << '\n';
            throw std::runtime_error("Nonmonotonic video ramp");
          }
          Require(values[1][i * 4 + 2][c] < 1e-4f, "Movie leaked into FG scene-only image");
          Require(std::abs(values[1][i * 4 + 3][c] - (ui_opacity + opacity * (1 - ui_opacity))) < 1e-6f, "Wrong FG video/UI mask");
        }
      }
      ++cases;
    }
    std::cout << "PASS " << cases << " configurations / " << cases * PIXELS * 2
              << " output pixels; parity=" << worst_parity << ", endpoint error=" << worst_endpoint << " nits\n";
  } catch (const std::exception& error) {
    std::cerr << "FAIL " << error.what() << '\n';
    return 1;
  }
}
