/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Executes the production LUT/post-grade paths, reversible proxy and PsychoV.
// A pre-change shader tree supplies the Vanilla and nonnegative-source baseline.
#define NOMINMAX
#include <d3d11.h>
#include <wrl/client.h>
#include <algorithm>
#include <cmath>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <string>
#include <vector>
#include "../shared.h"
using Microsoft::WRL::ComPtr;
void Check(HRESULT hr) {
  if (FAILED(hr)) throw std::runtime_error(std::to_string(hr));
}
int main(int argc, char** argv) {
  try {
    if (argc != 2) throw std::runtime_error("Expected prepared shader directory");
    ComPtr<ID3D11Device> d;
    ComPtr<ID3D11DeviceContext> c;
    Check(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &d, nullptr, &c));

    const char* names[] = {"0xF961D049", "0xC5AB358E", "0x16967617", "0xAD02BAB3", "0x9600E32A", "0x2F2D0992", "0x90AD6BBC", "0x0F6A9050"};
    ComPtr<ID3D11ComputeShader> shaders[2][8];
    for (int m = 0; m < 2; m++)
      for (int j = 0; j < 8; j++) {
        std::string path = std::string(argv[1]) + "/gpu-" + (m ? "after/" : "before/") + names[j] + ".cso";
        std::ifstream f(path, std::ios::binary);
        std::vector<char> b((std::istreambuf_iterator<char>(f)), {});
        Check(d->CreateComputeShader(b.data(), b.size(), nullptr, &shaders[m][j]));
      }
    ComPtr<ID3D11Buffer> cb3, cb13;
    D3D11_BUFFER_DESC cd = {400, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER, 0, 0, 0};
    Check(d->CreateBuffer(&cd, nullptr, &cb3));
    cd.ByteWidth = 128;
    Check(d->CreateBuffer(&cd, nullptr, &cb13));
    c->CSSetConstantBuffers(3, 1, cb3.GetAddressOf());
    c->CSSetConstantBuffers(13, 1, cb13.GetAddressOf());
    D3D11_BUFFER_DESC od = {512 * 4 * 16, D3D11_USAGE_DEFAULT, D3D11_BIND_UNORDERED_ACCESS, 0, D3D11_RESOURCE_MISC_BUFFER_STRUCTURED, 16};
    ComPtr<ID3D11Buffer> output, read;
    Check(d->CreateBuffer(&od, nullptr, &output));
    ComPtr<ID3D11UnorderedAccessView> uav;
    Check(d->CreateUnorderedAccessView(output.Get(), nullptr, &uav));
    c->CSSetUnorderedAccessViews(0, 1, uav.GetAddressOf(), nullptr);
    od.Usage = D3D11_USAGE_STAGING;
    od.BindFlags = 0;
    od.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    od.MiscFlags = 0;
    Check(d->CreateBuffer(&od, nullptr, &read));
    D3D11_SAMPLER_DESC sd = {};
    sd.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sd.AddressU = sd.AddressV = sd.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    sd.MaxLOD = D3D11_FLOAT32_MAX;
    ComPtr<ID3D11SamplerState> sampler;
    Check(d->CreateSamplerState(&sd, &sampler));
    for (int slot = 0; slot < 4; slot++) c->CSSetSamplers(slot, 1, sampler.GetAddressOf());
    ComPtr<ID3D11Texture2D> tex[4];
    ComPtr<ID3D11ShaderResourceView> views[4];
    for (int t = 0; t < 4; t++) {
      UINT w = t ? 512 : 32, h = t ? 512 : 16;
      D3D11_TEXTURE2D_DESC td = {w, h, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE, 0, 0};
      Check(d->CreateTexture2D(&td, nullptr, &tex[t]));
      Check(d->CreateShaderResourceView(tex[t].Get(), nullptr, &views[t]));
      c->CSSetShaderResources(t, 1, views[t].GetAddressOf());
    }
    std::vector<float> scene(512 * 4), lut(512 * 512 * 4);
    for (int i = 0; i < 512; i++) {
      float value = (i % 64) / 63.f * std::pow(2.f, float(i / 64));
      scene[i * 4] = value;
      scene[i * 4 + 1] = value * .37f;
      scene[i * 4 + 2] = value * (i % 3 == 0 ? -.03f : .08f);
      scene[i * 4 + 3] = (i % 7) / 6.f;
    }
    c->UpdateSubresource(tex[0].Get(), 0, nullptr, scene.data(), 32 * 16, 0);
    auto set_lut = [&](int kind) {for(int t=1;t<4;t++){
  for(int y=0;y<512;y++)for(int x=0;x<512;x++)for(int k=0;k<4;k++){
   float value=k==0?(x%64)/63.f:k==1?(y%64)/63.f:((y/64)*8+x/64)/63.f;
   if(kind==1)value=.05f+value*(.85f+.02f*(t+k));
   if(kind==2)value=0;if(kind==3)value=1;
   if(kind==4)value=.04f+value*(k==0?.30f:k==1?.8f:.45f);
   if(kind==5)value=k==0?value*.2f-.1f:value;
   lut[(y*512+x)*4+k]=k==3?1.f:value;
  }
  c->UpdateSubresource(tex[t].Get(),0,nullptr,lut.data(),512*16,0);
 } };
    float native[100] = {};
    struct {
      ShaderInjectData data;
      float pad[2];
    } settings = {};
    static_assert(sizeof(settings) == 128);
    auto& p = settings.data;
    auto initialize = [&](int variant) {
      std::fill(std::begin(native), std::end(native), 0.f);
      settings = {};
      native[2] = native[3] = 1;
      native[4] = .35f;
      native[5] = .8f;
      native[6] = 1.1f;
      native[9] = .6f;
      native[10] = .9f;
      native[11] = .7f;
      native[32] = 1.f / 2.2f;
      native[56] = native[58] = 1;
      native[36] = native[37] = native[38] = 1;
      native[41] = native[42] = native[43] = 1;
      for (int i = 44; i < 56; i++) native[i] = 1;
      native[24] = .1f;
      native[25] = .3f;
      native[26] = .2f;
      native[27] = 1;
      native[28] = .1f;
      native[29] = .12f;
      native[30] = .15f;
      native[60] = (variant % 2) * .03f;
      native[61] = 1;
      if (variant >= 2) {
        native[47] = 1.6f;
        native[51] = 1.3f;
        native[55] = 1.8f;
        native[36] = .9f;
        native[37] = 1.1f;
      }
      if (variant >= 4) {
        native[56] = .9f;
        native[57] = .03f;
        native[58] = 1.05f;
      }
      p.peak_white_nits = 1000;
      p.diffuse_white_nits = 203;
      p.tone_map_type = 1;
      p.tone_map_exposure = p.tone_map_gamma = p.tone_map_highlights = p.tone_map_shadows = 1;
      p.tone_map_contrast = p.tone_map_saturation = p.tone_map_highlight_saturation = 1;
      p.psychov_cone_response_exponent = p.psychov_gamut_compression = 1;
      p.psychov_adaptation_anchor = p.psychov_background_anchor = .18f;
      uint32_t flags = WITCHER_FLAG_GAMUT_TARGET | (50u << 7) | (50u << 14);
      std::memcpy(&p.mode_flags, &flags, 4);
      native[68] = native[69] = .5f;
      p.custom_lut_strength = p.custom_color_grading = 1;
      p.vignette_strength = variant % 2;
    };
    auto run = [&](int mode, int shader) {
      c->UpdateSubresource(cb3.Get(), 0, nullptr, native, 0, 0);
      c->UpdateSubresource(cb13.Get(), 0, nullptr, &settings, 0, 0);
      c->CSSetShader(shaders[mode][shader].Get(), nullptr, 0);
      c->Dispatch(8, 1, 1);
      c->CopyResource(read.Get(), output.Get());
      D3D11_MAPPED_SUBRESOURCE map;
      Check(c->Map(read.Get(), 0, D3D11_MAP_READ, 0, &map));
      std::vector<float> v((float*)map.pData, (float*)map.pData + 512 * 16);
      c->Unmap(read.Get(), 0);
      for (int i = 0; i < 512; i++)
        for (int k = 0; k < 4; k++) {
          if (!std::isfinite(v[i * 16 + k])) throw std::runtime_error(std::string("Nonfinite: ") + names[shader]);
          if (k == 3 && v[i * 16 + k] != scene[i * 4 + k]) throw std::runtime_error("Alpha changed");
        }
      return v;
    };
    int cases = 0;
    float max_error = 0;
    for (int kind = 0; kind < 2; kind++) {
      set_lut(kind);
      for (int j = 0; j < 8; j++)
        for (int variant = 0; variant < 6; variant++)
          for (int vanilla = 0; vanilla < 2; vanilla++) {
            initialize(variant);
            p.tone_map_type = vanilla ? 0 : 1;
            auto before = run(0, j), after = run(1, j);
            for (int i = 0; i < 512; i++)
              for (int k = 0; k < 3; k++) {
                float b = before[i * 16 + k], a = after[i * 16 + k];
                if (j < 5) {
                  b = std::copysign(std::pow(std::abs(b), 1.f / native[32]), b);
                  a = std::copysign(std::pow(std::abs(a), 1.f / native[32]), a);
                }
                float error = std::abs(b - a) / std::max(1.f, std::abs(b));
                if (vanilla) max_error = std::max(max_error, error);
                if (vanilla && a != b) throw std::runtime_error(std::string("Vanilla mismatch ") + names[j] + " error=" + std::to_string(error));
              }
            cases++;
          }
    }
    std::cout << cases << " finite/Vanilla cases passed; Vanilla maximum error " << max_error << '\n';
    set_lut(1);
    for (int j = 0; j < 8; j++) {
      initialize(4);
      p.custom_lut_strength = p.custom_color_grading = 0;
      p.vignette_strength = 0;
      auto value = run(1, j);
      for (int i = 0; i < 512; i++)
        for (int k = 0; k < 3; k++) {
          float expected = scene[i * 4 + k];
          if (j < 5) expected = std::copysign(std::pow(std::abs(expected), native[32]), expected);
          if (std::abs(value[i * 16 + k] - expected) > 2e-4f * std::max(1.f, std::abs(expected))) throw std::runtime_error("Zero contribution is not identity");
        }
    }
    std::cout << "Zero contribution identity: all eight shaders passed\n";
    for (int j = 0; j < 8; j++) {
      initialize(4);
      p.vignette_strength = 0;
      auto full = run(1, j);
      p.custom_lut_strength = p.custom_color_grading = .5f;
      auto half = run(1, j);
      for (int i = 0; i < 512; i++)
        for (int k = 0; k < 3; k++) {
          float f = full[i * 16 + k], h = half[i * 16 + k];
          if (j < 5) {
            f = std::copysign(std::pow(std::abs(f), 1.f / native[32]), f);
            h = std::copysign(std::pow(std::abs(h), 1.f / native[32]), h);
          }
          float expected = (f + scene[i * 4 + k]) * .5f;
          if (std::abs(h - expected) > 2e-4f * std::max(1.f, std::abs(expected))) throw std::runtime_error("Half contribution is not a linear blend");
        }
    }
    std::cout << "Half contribution linear blend: all eight shaders passed\n";
    for (int j = 5; j < 8; j++) {
      initialize(0);
      auto before = run(1, j);
      p.custom_lut_scaling = 1;
      auto after = run(1, j);
      if (after[0] + after[1] + after[2] >= before[0] + before[1] + before[2]) throw std::runtime_error("LUT scaling did not reduce lifted black");
    }
    std::cout << "LUT scaling reduces lifted black in all three variants\n";
    int negatives = 0;
    for (int j = 0; j < 5; j++) {
      initialize(0);
      native[47] = native[51] = native[55] = 5.f;
      uint32_t flags = 32u;
      std::memcpy(&p.mode_flags, &flags, 4);
      auto value = run(1, j);
      for (int i = 0; i < 512; i++)
        for (int k = 0; k < 3; k++)
          if (value[i * 16 + k] < 0) negatives++;
    }
    if (!negatives) throw std::runtime_error("Wide gamut still clips negative channels");
    std::cout << "Wide gamut preserves " << negatives << " signed channels; finite output\n";
    for (int kind = 0; kind < 6; kind++) {
      set_lut(kind);
      for (int j = 5; j < 8; j++)
        for (float scale : {0.f, .5f, 1.f}) {
          initialize(0);
          p.custom_lut_scaling = scale;
          run(1, j);
          cases++;
        }
    }
    std::cout << "LUT scaling finite for neutral, lifted, constant black and constant white LUTs\n";
    set_lut(3);
    for (int j = 0; j < 5; j++)
      for (float grade : {0.f, .5f, 1.f}) {
        initialize(1);
        p.custom_color_grading = grade;
        uint32_t flags = WITCHER_FLAG_VIGNETTE_BLACK | 32u;
        std::memcpy(&p.mode_flags, &flags, 4);
        std::vector<float> previous;
        for (float strength : {0.f, .25f, .5f, 1.f}) {
          p.vignette_strength = strength;
          auto value = run(1, j);
          if (!previous.empty())
            for (int i = 0; i < 512; i++)
              for (int k = 0; k < 3; k++)
                if (std::abs(value[i * 16 + k]) > std::abs(previous[i * 16 + k]) + 1e-4f) throw std::runtime_error("Vignette increased magnitude");
          previous = value;
          cases++;
        }
      }
    std::cout << cases << " total comparison/finite/vignette configurations passed\n";

    const float colors[8][3] = {{1, .37f, .08f}, {1, 1, 1}, {1.660491f, -.12455f, -.018151f}, {-.587641f, 1.1329f, -.100579f}, {-.07285f, -.008349f, 1.11873f}, {1.587641f, -.1329f, 1.100579f}, {.01f, .5f, .8f}, {.7f, .05f, .4f}};
    for (int i = 0; i < 512; i++) {
      float value = (i % 64) / 63.f * std::pow(2.f, float(i / 64));
      for (int k = 0; k < 3; k++) scene[i * 4 + k] = value * colors[i / 64][k];
    }
    c->UpdateSubresource(tex[0].Get(), 0, nullptr, scene.data(), 32 * 16, 0);
    int mapped_wide = 0, changed_signed = 0, unbounded = 0, signed_luts[3] = {};
    float positive_error = 0, proxy_error = 0;
    const float matrix[3][3] = {{.6274039745f, .3292819858f, .0433136001f},
                                {.0690969974f, .9195399880f, .0113612004f},
                                {.0163915996f, .0880132020f, .8955950141f}};
    for (int kind = 0; kind < 6; kind++) {
      set_lut(kind);
      for (int j = 0; j < 8; j++)
        for (unsigned target : {0u, 1u})
          for (float grade : {0.f, .5f, 1.f})
            for (float scaling : {0.f, .5f, 1.f}) {
              initialize(0);
              p.vignette_strength = 0;
              p.custom_lut_strength = p.custom_color_grading = grade;
              p.custom_lut_scaling = scaling;
              uint32_t flags = (target ? WITCHER_FLAG_GAMUT_TARGET : 0u) | (50u << 7) | (50u << 14);
              std::memcpy(&p.mode_flags, &flags, 4);
              auto after = run(1, j), before = run(0, j);
              for (int i = 0; i < 512; i++)
                for (int k = 0; k < 3; k++) {
                  if (j >= 5 && after[i * 16 + k] < -1e-5f) signed_luts[j - 5]++;
                  float error = std::abs(after[i * 16 + 8 + k] - scene[i * 4 + k]) / (1.f + std::abs(scene[i * 4 + k]));
                  proxy_error = std::max(proxy_error, error);
                  if (error > 2e-5f) throw std::runtime_error("Wide source proxy was not restored");
                  bool positive = scene[i * 4] >= 0 && scene[i * 4 + 1] >= 0 && scene[i * 4 + 2] >= 0;
                  float mapped = after[i * 16 + 4 + k], old = before[i * 16 + 4 + k];
                  if (positive) {
                    float e = std::abs(mapped - old) / (1 + std::abs(old));
                    positive_error = std::max(positive_error, e);
                    if (e > 2e-5f) throw std::runtime_error("Nonnegative source tone mapping changed");
                  } else
                    changed_signed += std::abs(mapped - old) > 1e-5f;
                  if (target && mapped < -1e-4f) mapped_wide++;
                  float selected = target ? matrix[k][0] * after[i * 16 + 4] + matrix[k][1] * after[i * 16 + 5] + matrix[k][2] * after[i * 16 + 6] : mapped;
                  if (!std::isfinite(mapped) || selected < -1e-4f || selected > 1000.f / 203.f + 1e-4f)
                    throw std::runtime_error("Selected gamut/peak containment failed");
                }
              cases++;
            }
    }
    if (!mapped_wide || !signed_luts[0] || !signed_luts[1] || !signed_luts[2]) throw std::runtime_error("Missing wide-gamut coverage");
    for (unsigned target : {0u, 1u})
      for (float saturation : {1.f, 2.f}) {
        initialize(0);
        p.tone_map_saturation = saturation;
        uint32_t flags = (target ? WITCHER_FLAG_GAMUT_TARGET : 0u) | (50u << 7) | (50u << 14);
        std::memcpy(&p.mode_flags, &flags, 4);
        p.psychov_gamut_compression = 0;
        auto free = run(1, 0);
        p.psychov_gamut_compression = 1;
        auto full = run(1, 0);
        p.psychov_gamut_compression = .5f;
        auto half = run(1, 0);
        for (int i = 0; i < 512; i++)
          for (int k = 0; k < 3; k++) {
            float a = free[i * 16 + 4 + k], b = full[i * 16 + 4 + k], h = half[i * 16 + 4 + k];
            if (!std::isfinite(a) || !std::isfinite(b) || !std::isfinite(h)) throw std::runtime_error("Nonfinite partial projection");
            if (saturation == 1.f && std::abs(h - (a + b) * .5f) > 2e-4f * (1.f + std::abs(a)))
              throw std::runtime_error("Gamut strength no longer interpolates projection");
            float selected = target ? matrix[k][0] * free[i * 16 + 4] + matrix[k][1] * free[i * 16 + 5] + matrix[k][2] * free[i * 16 + 6] : a;
            unbounded += selected < -1e-4f || selected > 1000.f / 203.f + 1e-4f;
          }
        cases += 3;
      }
    if (!unbounded) throw std::runtime_error("Zero compression still constrains the source gamut");
    for (unsigned target : {0u, 1u})
      for (float peak : {400.f, 1000.f, 4000.f})
        for (float hue : {0.f, .5f, 1.f})
          for (float cone : {.8f, 1.f, 1.2f})
            for (float anchor : {.1f, .18f, .35f})
              for (float compression : {0.f, 1.f})
                for (float saturation : {.5f, 1.f, 2.f}) {
                    initialize(0);
                    p.peak_white_nits = peak;
                    p.psychov_hue_shift = hue;
                    p.psychov_cone_response_exponent = cone;
                    p.psychov_adaptation_anchor = anchor;
                    p.psychov_compression = compression;
                    p.tone_map_saturation = saturation;
                    uint32_t flags = (target ? WITCHER_FLAG_GAMUT_TARGET : 0u) | (50u << 7) | (50u << 14);
                    std::memcpy(&p.mode_flags, &flags, 4);
                    auto value = run(1, 0);
                    for (int i = 0; i < 512; i++)
                      for (int k = 0; k < 3; k++) {
                        float selected = target ? matrix[k][0] * value[i * 16 + 4] + matrix[k][1] * value[i * 16 + 5] + matrix[k][2] * value[i * 16 + 6] : value[i * 16 + 4 + k];
                        if (!std::isfinite(selected) || selected < -1e-4f || selected > peak / 203.f + 1e-4f)
                          throw std::runtime_error("PsychoV controls exceed selected gamut/peak");
                      }
                    cases++;
                  }
    float boundary_error = 0, previous_boundary_error = 0;
    int boundary_cases = 0;
    for (unsigned target : {0u, 1u})
      for (float strength : {0.f, .5f, 1.f})
        for (float hue : {0.f, .5f, 1.f})
          for (float cone : {.5f, .8f, 1.f, 1.2f, 2.f})
            for (float compression : {0.f, 1.f, 2.f}) {
              initialize(0);
              p.psychov_gamut_compression = strength;
              p.psychov_hue_shift = hue;
              p.psychov_cone_response_exponent = cone;
              p.psychov_compression = compression;
              uint32_t flags = (target ? WITCHER_FLAG_GAMUT_TARGET : 0u) | (50u << 7) | (50u << 14);
              std::memcpy(&p.mode_flags, &flags, 4);
              auto after = run(1, 0), before = run(0, 0);
              for (int i = 0; i < 510; i += 3)
                for (int k = 0; k < 3; k++) {
                  float a = after[i * 16 + 12 + k];
                  float z = after[(i + 1) * 16 + 12 + k];
                  float b = after[(i + 2) * 16 + 12 + k];
                  float error = std::max(std::abs(a - z), std::abs(b - z)) / (1000.f / 203.f);
                  boundary_error = std::max(boundary_error, error);
                  if (!std::isfinite(error) || error > .001f)
                    throw std::runtime_error("Discontinuous response across a cone zero plane: sample=" + std::to_string(i)
                        + " target=" + std::to_string(target) + " strength=" + std::to_string(strength)
                        + " hue=" + std::to_string(hue) + " cone=" + std::to_string(cone)
                        + " compression=" + std::to_string(compression) + " step=" + std::to_string(error) + " values=" + std::to_string(a) + "," + std::to_string(z) + "," + std::to_string(b));
                  previous_boundary_error = std::max(previous_boundary_error,
                      std::abs(before[i * 16 + 12 + k] - before[(i + 2) * 16 + 12 + k]) / (1000.f / 203.f));
                }
              for (int i = 0; i < 512; i++)
                for (int k = 0; k < 3; k++) {
                  float mapped = after[i * 16 + 12 + k];
                  if (!std::isfinite(mapped)) throw std::runtime_error("Nonfinite signed cone response");
                  if (i == 510 && mapped != 0.f) throw std::runtime_error("Black cone response changed");
                  if (strength == 1.f) {
                    float selected = target ? matrix[k][0] * after[i * 16 + 12] + matrix[k][1] * after[i * 16 + 13] + matrix[k][2] * after[i * 16 + 14] : mapped;
                    if (selected < -1e-4f || selected > 1000.f / 203.f + 1e-4f)
                      throw std::runtime_error("Signed cone response exceeds the selected target");
                  }
                }
              boundary_cases++;
            }
    std::cout << boundary_cases << " signed cone boundary configurations passed; maximum normalized step "
              << boundary_error << " (baseline " << previous_boundary_error << "); black, finite signed output and full-target bounds passed.\n";
    std::cout << cases << " total configurations: all three LUT paths preserve signed channels ("
              << signed_luts[0] << "," << signed_luts[1] << "," << signed_luts[2] << "); " << mapped_wide
              << " BT.2020 mapped channels outside BT.709, " << changed_signed << " signed source channels corrected; "
              << unbounded << " unclamped channels at zero compression. Positive-source parity error " << positive_error
              << ", proxy identity error " << proxy_error << "; partial-strength interpolation and full-target bounds passed.\n";
    return 0;
  } catch (const std::exception& e) {
    std::cerr << e.what() << '\n';
    return 1;
  }
}
