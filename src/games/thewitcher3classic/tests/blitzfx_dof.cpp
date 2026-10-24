/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3dcompiler.h>
#include <bit>
#include <iostream>
#include "motion_gpu.hpp"

int main(int argc, char** argv) {
  assert(argc == 2 || argc == 3);
  std::cout << std::unitbuf;
  const std::filesystem::path originals = argv[1];
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr, argc == 3 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP,
      nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context)));
  constexpr UINT W = 64, H = 48;
  const D3D11_TEXTURE2D_DESC target_desc{W, H, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT,
      {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_RENDER_TARGET | D3D11_BIND_UNORDERED_ACCESS};
  std::array<ComPtr<ID3D11Texture2D>, 2> targets;
  std::array<ComPtr<ID3D11UnorderedAccessView>, 2> uavs;
  ComPtr<ID3D11RenderTargetView> rtv;
  for (UINT i = 0; i < 2; ++i) {
    assert(SUCCEEDED(device->CreateTexture2D(&target_desc, nullptr, &targets[i])));
    assert(SUCCEEDED(device->CreateUnorderedAccessView(targets[i].Get(), nullptr, &uavs[i])));
  }
  assert(SUCCEEDED(device->CreateRenderTargetView(targets[0].Get(), nullptr, &rtv)));
  auto staging_desc = target_desc;
  staging_desc.Usage = D3D11_USAGE_STAGING; staging_desc.BindFlags = 0;
  staging_desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
  ComPtr<ID3D11Texture2D> staging;
  assert(SUCCEEDED(device->CreateTexture2D(&staging_desc, nullptr, &staging)));
  const auto buffer = [&](UINT slot, const std::vector<float>& values) {
    auto cb = Buffer(device.Get(), values.data(), UINT(values.size() * 4), D3D11_BIND_CONSTANT_BUFFER);
    context->PSSetConstantBuffers(slot, 1, cb.GetAddressOf());
    context->CSSetConstantBuffers(slot, 1, cb.GetAddressOf());
  };
  const auto texture = [&](UINT slot, UINT width, UINT height, UINT active_width, UINT active_height, bool coc) {
    std::vector<std::array<float, 4>> pixels(width * height, {1000, 2000, 3000, 1});
    for (UINT y = 0; y < active_height; ++y) for (UINT x = 0; x < active_width; ++x) {
      const float weight = float((x / 3 + y / 3) % 4) / 3;
      pixels[y * width + x] = coc ? std::array<float, 4>{weight, weight, weight, weight}
          : std::array<float, 4>{(.05f + .02f * x) * weight, (.1f + .03f * y) * weight,
                (.2f + .002f * x * y) * weight, weight};
    }
    const D3D11_TEXTURE2D_DESC desc{width, height, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT,
        {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE};
    const D3D11_SUBRESOURCE_DATA initial{pixels.data(), width * 16};
    ComPtr<ID3D11Texture2D> resource;
    ComPtr<ID3D11ShaderResourceView> view;
    assert(SUCCEEDED(device->CreateTexture2D(&desc, &initial, &resource)));
    assert(SUCCEEDED(device->CreateShaderResourceView(resource.Get(), nullptr, &view)));
    context->PSSetShaderResources(slot, 1, view.GetAddressOf());
    context->CSSetShaderResources(slot, 1, view.GetAddressOf());
  };
  auto sampler_desc = CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
  sampler_desc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
  sampler_desc.AddressU = sampler_desc.AddressV = sampler_desc.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
  ComPtr<ID3D11SamplerState> sampler;
  assert(SUCCEEDED(device->CreateSamplerState(&sampler_desc, &sampler)));
  context->CSSetSamplers(0, 1, sampler.GetAddressOf());
  context->PSSetSamplers(1, 1, sampler.GetAddressOf());
  const char* vertex_text = "float4 main(uint id:SV_VertexID):SV_Position {return float4(float2((id<<1)&2,id&2)*float2(2,-2)+float2(-1,1),.5,1);}";
  ComPtr<ID3DBlob> vertex_code;
  assert(SUCCEEDED(D3DCompile(vertex_text, strlen(vertex_text), nullptr, nullptr, nullptr,
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
  const auto run = [&](const std::vector<uint8_t>& code, UINT width, UINT height, bool composite, UINT outputs) {
    context->OMSetRenderTargets(0, nullptr, nullptr);
    const float zero[4] = {};
    for (const auto& uav : uavs) context->ClearUnorderedAccessViewFloat(uav.Get(), zero);
    if (composite) {
      ComPtr<ID3D11PixelShader> pixel;
      assert(SUCCEEDED(device->CreatePixelShader(code.data(), code.size(), nullptr, &pixel)));
      const D3D11_VIEWPORT viewport{0, 0, float(width), float(height), 0, 1};
      context->RSSetViewports(1, &viewport);
      context->OMSetRenderTargets(1, rtv.GetAddressOf(), nullptr);
      context->PSSetShader(pixel.Get(), nullptr, 0);
      context->Draw(3, 0);
      context->OMSetRenderTargets(0, nullptr, nullptr);
    } else {
      ComPtr<ID3D11ComputeShader> compute;
      assert(SUCCEEDED(device->CreateComputeShader(code.data(), code.size(), nullptr, &compute)));
      context->CSSetShader(compute.Get(), nullptr, 0);
      ID3D11UnorderedAccessView* views[] = {uavs[0].Get(), uavs[1].Get()};
      context->CSSetUnorderedAccessViews(0, outputs, views, nullptr);
      context->Dispatch((width + 7) / 8, (height + 7) / 8, 1);
      ID3D11UnorderedAccessView* empty[2] = {};
      context->CSSetUnorderedAccessViews(0, 2, empty, nullptr);
    }
    std::vector<float> result;
    for (UINT i = 0; i < outputs; ++i) {
      context->CopyResource(staging.Get(), targets[i].Get());
      D3D11_MAPPED_SUBRESOURCE mapped;
      assert(SUCCEEDED(context->Map(staging.Get(), 0, D3D11_MAP_READ, 0, &mapped)));
      for (UINT y = 0; y < height; ++y) {
        const auto* row = reinterpret_cast<const float*>(static_cast<const uint8_t*>(mapped.pData) + y * mapped.RowPitch);
        result.insert(result.end(), row, row + width * 4);
      }
      context->Unmap(staging.Get(), 0);
    }
    return result;
  };
  for (const auto* hash : {"0xB018A95A", "0x48885E0D", "0xB73522BB", "0xAE334616", "0x249DA2F1"}) {
    const bool reduction = std::string_view(hash) == "0xB018A95A", composite = std::string_view(hash) == "0xAE334616";
    const bool motion_blur = std::string_view(hash) == "0x249DA2F1";
    const auto native = Read(originals / (std::string(hash) + ".cso"));
    const auto replacement = Read(std::filesystem::path("build/thewitcher3classic.include/embed") / (std::string(hash) + ".cso"));
    float worst_error = 0, worst_original = 0;
    for (const auto size : {std::array<UINT, 2>{64, 48}, {42, 30}, {36, 26}, {32, 24}, {22, 16}, {43, 31}})
      for (UINT cinematic : {0u, 1u}) {
        std::vector<float> frame(96), focus(212);
        frame[92] = float(size[0]); frame[93] = float(size[1]);
        frame[94] = 1.f / size[0]; frame[95] = 1.f / size[1];
        focus[207] = .8f; focus[210] = std::bit_cast<float>(cinematic); focus[211] = 2;
        if (motion_blur) {
          // Inverse current projection and translated previous projection:
          // both zero-motion and nonzero camera-blur branches must execute.
          focus[96] = focus[101] = focus[106] = focus[111] = 1;
          focus[112] = focus[117] = focus[122] = focus[127] = 1;
          focus[115] = cinematic ? -.25f : 0.f;
        }
        buffer(0, frame); buffer(1, focus); buffer(3, {10, 100, .35f, 0});
        const auto inputs = [&](UINT width, UINT height) {
          if (motion_blur) {
            texture(0, width, height, size[0], size[1], true);
            texture(51, width, height, size[0], size[1], true);
            texture(52, width, height, size[0], size[1], false);
            return;
          }
          texture(50, reduction ? width : width / 2, reduction ? height : height / 2,
              reduction ? size[0] : size[0] / 2, reduction ? size[1] : size[1] / 2, false);
          texture(reduction || composite ? 52 : 51, reduction || composite ? width : width / 2,
              reduction || composite ? height : height / 2, reduction || composite ? size[0] : size[0] / 2,
              reduction || composite ? size[1] : size[1] / 2, true);
        };
        const UINT width = composite || motion_blur ? size[0] : size[0] / 2, height = composite || motion_blur ? size[1] : size[1] / 2;
        const UINT outputs = reduction ? 2 : 1;
        inputs(size[0], size[1]);
        const auto expected = run(native, width, height, composite, outputs);
        inputs(W, H);
        const auto old = run(native, width, height, composite, outputs);
        const auto actual = run(replacement, width, height, composite, outputs);
        float error = 0;
        for (size_t i = 0; i < actual.size(); ++i) {
          assert(std::isfinite(actual[i]) && std::isfinite(expected[i]));
          error = std::max(error, std::abs(actual[i] - expected[i]));
          worst_original = std::max(worst_original, std::abs(old[i] - expected[i]));
        }
        worst_error = std::max(worst_error, error);
        std::cout << hash << ' ' << size[0] << 'x' << size[1] << " cinematic=" << cinematic << " error=" << error << '\n';
        // The longer motion-blur filter accumulates texture-weight rounding
        // across 16 gathers. NVIDIA stays within 5e-7; WARP's odd-size filter
        // weights need the same .002 tolerance as the native material suite.
        assert(error < (motion_blur ? .002f : .0005f));
      }
    assert(worst_original > 1.f);
    std::cout << "PASS " << hash << " corrected error=" << worst_error << " original pool error=" << worst_original << '\n';
  }
}
