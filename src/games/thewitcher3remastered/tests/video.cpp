/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// D3D11 WARP checks of the native-equivalent SM5.0 bytecode, archived baseline,
// and production BT.709 shader compiled as ps_5_0 for this reference harness.
#define NOMINMAX
#include <d3d11.h>
#include <d3dcompiler.h>
#include <wrl/client.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <fstream>
#include <iostream>
#include <iterator>
#include <stdexcept>
#include <string>
#include <vector>

using Microsoft::WRL::ComPtr;
using Pixel = std::array<float, 4>;
constexpr unsigned VIDEO_SIZE = 256;
void Check(HRESULT result) { if (FAILED(result)) throw std::runtime_error("D3D failure " + std::to_string(result)); }

int main(int argc, char** argv) {
  try {
    if (argc != 4) throw std::runtime_error("Expected native, baseline and BT.709 pixel shader binaries");
    ComPtr<ID3D11Device> device;
    ComPtr<ID3D11DeviceContext> context;
    Check(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context));
    ComPtr<ID3D11PixelShader> shaders[3];
    for (unsigned i = 0; i < 3; ++i) {
      std::ifstream stream(argv[i + 1], std::ios::binary);
      std::vector<char> bytes((std::istreambuf_iterator<char>(stream)), {});
      Check(device->CreatePixelShader(bytes.data(), bytes.size(), nullptr, &shaders[i]));
    }
    const char vertex_source[] =
        "cbuffer C : register(b0) {float alpha;};"
        "struct V {float4 c:COLOR0; float2 uv:TEXCOORD0; float4 p:SV_Position;};"
        "V main(uint id:SV_VertexID) {V o; o.uv=float2((id<<1)&2,id&2);"
        "o.p=float4(o.uv*float2(2,-2)+float2(-1,1),0,1); o.c=float4(0,0,0,alpha);return o;}";
    ComPtr<ID3DBlob> vs_code, errors;
    Check(D3DCompile(vertex_source, sizeof(vertex_source), nullptr, nullptr, nullptr, "main", "vs_5_0", D3DCOMPILE_ENABLE_STRICTNESS, 0, &vs_code, &errors));
    ComPtr<ID3D11VertexShader> vs;
    Check(device->CreateVertexShader(vs_code->GetBufferPointer(), vs_code->GetBufferSize(), nullptr, &vs));
    context->VSSetShader(vs.Get(), nullptr, 0);
    context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    D3D11_VIEWPORT viewport = {0, 0, VIDEO_SIZE, VIDEO_SIZE, 0, 1};
    context->RSSetViewports(1, &viewport);
    ComPtr<ID3D11Buffer> constants;
    D3D11_BUFFER_DESC cb_desc = {16, D3D11_USAGE_DEFAULT, D3D11_BIND_CONSTANT_BUFFER, 0, 0, 0};
    Check(device->CreateBuffer(&cb_desc, nullptr, &constants));
    context->VSSetConstantBuffers(0, 1, constants.GetAddressOf());
    ComPtr<ID3D11Texture2D> planes[3], output, readback;
    ComPtr<ID3D11ShaderResourceView> srvs[3];
    D3D11_TEXTURE2D_DESC desc = {VIDEO_SIZE, VIDEO_SIZE, 1, 1, DXGI_FORMAT_R32_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE, 0, 0};
    for (unsigned i = 0; i < 3; ++i) {
      Check(device->CreateTexture2D(&desc, nullptr, &planes[i]));
      Check(device->CreateShaderResourceView(planes[i].Get(), nullptr, &srvs[i]));
      context->PSSetShaderResources(i, 1, srvs[i].GetAddressOf());
    }
    desc.Format = DXGI_FORMAT_R32G32B32A32_FLOAT;
    desc.BindFlags = D3D11_BIND_RENDER_TARGET;
    Check(device->CreateTexture2D(&desc, nullptr, &output));
    ComPtr<ID3D11RenderTargetView> rtv;
    Check(device->CreateRenderTargetView(output.Get(), nullptr, &rtv));
    context->OMSetRenderTargets(1, rtv.GetAddressOf(), nullptr);
    desc.BindFlags = 0;
    desc.Usage = D3D11_USAGE_STAGING;
    desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    Check(device->CreateTexture2D(&desc, nullptr, &readback));
    ComPtr<ID3D11SamplerState> sampler;
    D3D11_SAMPLER_DESC sampler_desc = {};
    sampler_desc.Filter = D3D11_FILTER_MIN_MAG_MIP_POINT;
    sampler_desc.AddressU = sampler_desc.AddressV = sampler_desc.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    sampler_desc.MaxLOD = D3D11_FLOAT32_MAX;
    Check(device->CreateSamplerState(&sampler_desc, &sampler));
    for (unsigned i = 0; i < 3; ++i) context->PSSetSamplers(i, 1, sampler.GetAddressOf());

    std::array<std::vector<float>, 3> values;
    for (auto& plane : values) plane.resize(VIDEO_SIZE * VIDEO_SIZE);
    for (unsigned y = 0; y < VIDEO_SIZE; ++y) for (unsigned x = 0; x < VIDEO_SIZE; ++x) {
      values[0][y * VIDEO_SIZE + x] = float((x * 73 + y * 151) & 255) / 255.f;
      values[1][y * VIDEO_SIZE + x] = float(x) / 255.f;
      values[2][y * VIDEO_SIZE + x] = float(y) / 255.f;
    }
    // Exact encoded BT.709 black, white, grey and primary/secondary colors.
    const std::array<Pixel, 9> bars = {{{0, 0, 0, 1}, {1, 1, 1, 1}, {.5f, .5f, .5f, 1},
        {1, 0, 0, 1}, {0, 1, 0, 1}, {0, 0, 1, 1}, {1, 1, 0, 1}, {0, 1, 1, 1}, {1, 0, 1, 1}}};
    for (unsigned i = 0; i < bars.size(); ++i) {
      double y = .2126 * bars[i][0] + .7152 * bars[i][1] + .0722 * bars[i][2];
      values[0][i] = float((y * 219 + 16) / 255);
      values[1][i] = float(((bars[i][2] - y) / 1.8556 * 224 + 128) / 255);
      values[2][i] = float(((bars[i][0] - y) / 1.5748 * 224 + 128) / 255);
    }
    for (unsigned i = 0; i < 3; ++i) context->UpdateSubresource(planes[i].Get(), 0, nullptr, values[i].data(), VIDEO_SIZE * sizeof(float), 0);
    std::vector<Pixel> native(VIDEO_SIZE * VIDEO_SIZE);
    double baseline_error = 0, bt709_error = 0, bar_error = 0;
    unsigned checks = 0;
    for (float alpha : {0.f, .37f, 1.f}) {
      Pixel constants_data = {alpha, 0, 0, 0};
      context->UpdateSubresource(constants.Get(), 0, nullptr, constants_data.data(), 0, 0);
      for (unsigned pass = 0; pass < 3; ++pass) {
        context->PSSetShader(shaders[pass].Get(), nullptr, 0);
        context->Draw(3, 0);
        context->CopyResource(readback.Get(), output.Get());
        D3D11_MAPPED_SUBRESOURCE mapped;
        Check(context->Map(readback.Get(), 0, D3D11_MAP_READ, 0, &mapped));
        for (unsigned y = 0; y < VIDEO_SIZE; ++y) for (unsigned x = 0; x < VIDEO_SIZE; ++x) {
          unsigned i = y * VIDEO_SIZE + x;
          const auto& pixel = reinterpret_cast<const Pixel*>(static_cast<const char*>(mapped.pData) + y * mapped.RowPitch)[x];
          for (float v : pixel) if (!std::isfinite(v)) throw std::runtime_error("Nonfinite video output");
          if (pixel[3] != alpha) throw std::runtime_error("Video opacity changed");
          if (pass == 0) native[i] = pixel;
          if (pass == 1) for (unsigned c = 0; c < 3; ++c)
            baseline_error = std::max(baseline_error, double(std::abs(pixel[c] - native[i][c])));
          if (pass == 2) {
            double luma = (double(values[0][i]) * 255 - 16) / 219;
            double cb = (double(values[1][i]) * 255 - 128) / 224;
            double cr = (double(values[2][i]) * 255 - 128) / 224;
            const std::array<double, 3> expected = {luma + 1.5748 * cr,
                luma - (.0722 * 1.8556 / .7152) * cb - (.2126 * 1.5748 / .7152) * cr,
                luma + 1.8556 * cb};
            for (unsigned c = 0; c < 3; ++c) {
              bt709_error = std::max(bt709_error, std::abs(pixel[c] - expected[c]));
              if (i < bars.size()) bar_error = std::max(bar_error, double(std::abs(pixel[c] - bars[i][c])));
            }
          }
          ++checks;
        }
        context->Unmap(readback.Get(), 0);
      }
    }
    std::cout << "native_baseline_error=" << baseline_error << " bt709_reference_error=" << bt709_error << " color_bar_error=" << bar_error << '\n';
    if (baseline_error > 1e-6 || bt709_error > 1e-6 || bar_error > 1e-6) throw std::runtime_error("Video color conversion mismatch");
    std::cout << "PASS " << checks << " pixels including limited-range endpoints, color bars, full code-range sweeps and alpha\n";
  } catch (const std::exception& error) {
    std::cerr << "FAIL " << error.what() << '\n';
    return 1;
  }
}
