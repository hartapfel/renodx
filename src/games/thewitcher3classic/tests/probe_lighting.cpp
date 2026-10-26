/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Captured vertex-stage lighting constants plus spatially varying environment
// atlases. Constant-color atlases cannot detect a wrong hemisphere selector.
#include <d3dcompiler.h>
#include <algorithm>
#include <bit>
#include <iostream>
#include <string_view>
#include "./motion_gpu.hpp"
#include "./vertex_outputs.hpp"
struct Vertex {
  float p[3];
  uint32_t index[4];
  float weight[4];
  float uv[2];
  float normal[3];
  float tangent[4];
  float color[4];
  float uv1[2];
};
int main(int argc, char** argv) {
  std::cout << std::unitbuf;
  assert(argc == 3 || (argc == 4 && std::string_view(argv[3]) == "--hardware"));
  const std::filesystem::path p = argv[1], originals = argv[2];
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr, argc == 4 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &context)));
  for (UINT slot : {1u, 2u, 3u, 12u, 13u}) {
    auto data = Read(p / ("hair-constantBuffers-" + std::to_string(slot) + ".bin"));
    auto buffer = Buffer(device.Get(), data.data(), UINT(data.size()), D3D11_BIND_CONSTANT_BUFFER);
    context->VSSetConstantBuffers(slot, 1, buffer.GetAddressOf());
  }
  std::array<float, 64> bones{};
  for (UINT bone = 0; bone < 4; ++bone) {
    for (UINT i = 0; i < 4; ++i) bones[bone * 16 + i * 5] = 1;
    bones[bone * 16 + 12] = bone * .03f;
    bones[bone * 16 + 15] = .25f;
  }
  auto bone_buffer = Buffer(device.Get(), bones.data(), sizeof(bones), D3D11_BIND_SHADER_RESOURCE, 64);
  ComPtr<ID3D11ShaderResourceView> bone_view;
  assert(SUCCEEDED(device->CreateShaderResourceView(bone_buffer.Get(), nullptr, &bone_view)));
  context->VSSetShaderResources(0, 1, bone_view.GetAddressOf());
  auto instance = Read(p / "hair-vertexBuffers-7.bin");
  auto* inst = reinterpret_cast<float*>(instance.data());
  inst[16] = 0;
  inst[17] = 1;
  auto instances = Buffer(device.Get(), instance.data(), 80, D3D11_BIND_VERTEX_BUFFER);
  const UINT instance_stride = 80, offset = 0;
  context->IASetVertexBuffers(7, 1, instances.GetAddressOf(), &instance_stride, &offset);
  const auto layout_code = Read(originals / "0xAB3E8304.cso");
  const D3D11_INPUT_ELEMENT_DESC layout[] = {
      {"POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, offsetof(Vertex, p)}, {"BLENDINDICES", 0, DXGI_FORMAT_R32G32B32A32_UINT, 0, offsetof(Vertex, index)}, {"BLENDWEIGHT", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, offsetof(Vertex, weight)}, {"TEXCOORD", 0, DXGI_FORMAT_R32G32_FLOAT, 0, offsetof(Vertex, uv)}, {"NORMAL", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, offsetof(Vertex, normal)}, {"TANGENT", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, offsetof(Vertex, tangent)}, {"COLOR", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, offsetof(Vertex, color)}, {"TEXCOORD", 1, DXGI_FORMAT_R32G32_FLOAT, 0, offsetof(Vertex, uv1)}, {"INSTANCE_TRANSFORM", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 7, 0, D3D11_INPUT_PER_INSTANCE_DATA, 1}, {"INSTANCE_TRANSFORM", 1, DXGI_FORMAT_R32G32B32A32_FLOAT, 7, 16, D3D11_INPUT_PER_INSTANCE_DATA, 1}, {"INSTANCE_TRANSFORM", 2, DXGI_FORMAT_R32G32B32A32_FLOAT, 7, 32, D3D11_INPUT_PER_INSTANCE_DATA, 1}, {"INSTANCE_LOD_PARAMS", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 7, 48, D3D11_INPUT_PER_INSTANCE_DATA, 1}, {"INSTANCE_SKINNING_DATA", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 7, 64, D3D11_INPUT_PER_INSTANCE_DATA, 1}};
  ComPtr<ID3D11InputLayout> input;
  assert(SUCCEEDED(device->CreateInputLayout(layout, 13, layout_code.data(), layout_code.size(), &input)));
  context->IASetInputLayout(input.Get());
  context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  const auto texture = [&](UINT slot, UINT width, UINT height, UINT layers, UINT mips, std::array<float, 4> color) {
    std::vector<std::vector<std::array<float, 4>>> pixels;
    std::vector<D3D11_SUBRESOURCE_DATA> data;
    for (UINT layer = 0; layer < layers; ++layer)
      for (UINT mip = 0; mip < mips; ++mip) {
        UINT w = std::max(1u, width >> mip), h = std::max(1u, height >> mip);
        pixels.emplace_back(w * h, color);
        for (UINT y = 0; y < h; ++y)
          for (UINT x = 0; x < w; ++x) {
            auto& v = pixels.back()[y * w + x];
            v[0] *= .3f + float(x) / w;
            v[1] *= .3f + float(y) / h;
          }
        data.push_back({pixels.back().data(), w * 16});
      }
    const D3D11_TEXTURE2D_DESC td{width, height, mips, layers, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE};
    ComPtr<ID3D11Texture2D> t;
    ComPtr<ID3D11ShaderResourceView> v;
    assert(SUCCEEDED(device->CreateTexture2D(&td, data.data(), &t)));
    assert(SUCCEEDED(device->CreateShaderResourceView(t.Get(), nullptr, &v)));
    context->VSSetShaderResources(slot, 1, v.GetAddressOf());
  };
  texture(1, 64, 1, 1, 1, {.1f, .2f, .3f, 1});
  texture(8, 64, 64, 4, 1, {.8f, .8f, .8f, 1});
  texture(14, 64, 64, 4, 2, {.3f, .3f, .3f, 1});
  texture(19, 64, 64, 4, 1, {.2f, .2f, .2f, 1});
  texture(22, 48, 168, 1, 2, {.4f, .6f, .9f, 1});
  texture(23, 384, 1344, 1, 6, {.2f, .4f, .8f, 1});
  texture(24, 1920, 1080, 1, 1, {.1f, .9f, 0, 0});
  auto sd = CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
  sd.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
  sd.AddressU = sd.AddressV = sd.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
  ComPtr<ID3D11SamplerState> sampler;
  assert(SUCCEEDED(device->CreateSamplerState(&sd, &sampler)));
  for (UINT slot : {10u, 11u, 14u}) context->VSSetSamplers(slot, 1, sampler.GetAddressOf());
  sd.Filter = D3D11_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT;
  sd.ComparisonFunc = D3D11_COMPARISON_LESS_EQUAL;
  ComPtr<ID3D11SamplerState> cmp;
  assert(SUCCEEDED(device->CreateSamplerState(&sd, &cmp)));
  context->VSSetSamplers(9, 1, cmp.GetAddressOf());
  std::vector<uint32_t> indices(192 * 16384, 192);
  D3D11_BUFFER_DESC bd{UINT(indices.size() * 4), D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE, 0, D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS};
  D3D11_SUBRESOURCE_DATA init{indices.data()};
  ComPtr<ID3D11Buffer> raw;
  ComPtr<ID3D11ShaderResourceView> rv;
  assert(SUCCEEDED(device->CreateBuffer(&bd, &init, &raw)));
  D3D11_SHADER_RESOURCE_VIEW_DESC rd{};
  rd.Format = DXGI_FORMAT_R32_TYPELESS;
  rd.ViewDimension = D3D11_SRV_DIMENSION_BUFFEREX;
  rd.BufferEx.NumElements = UINT(indices.size());
  rd.BufferEx.Flags = D3D11_BUFFEREX_SRV_FLAG_RAW;
  assert(SUCCEEDED(device->CreateShaderResourceView(raw.Get(), &rd, &rv)));
  context->VSSetShaderResources(21, 1, rv.GetAddressOf());
  UINT total_failures = 0;
  for (const char* hash : {"0xAB3E8304", "0xB0B4EB6F", "0x5CC0DB95", "0xAE216EAE"}) {
    const auto native = Read(originals / (std::string(hash) + ".cso")), replacement = Read(std::filesystem::path("build/thewitcher3classic.include/embed") / (std::string(hash) + ".cso"));
    auto mesh = Read(p / "hair-constantBuffers-2.bin");
    if (std::string_view(hash) == "0x5CC0DB95" || std::string_view(hash) == "0xAE216EAE") {
      // These paths consume deformed positions directly. Put their synthetic
      // vertices at the captured hair's decoded origin, inside the lighting
      // frustum, rather than at the character's offscreen foot-level root.
      const auto* captured_mesh = reinterpret_cast<const float*>(mesh.data());
      const std::array<float, 4> origin = {captured_mesh[20], captured_mesh[21], captured_mesh[22], 1.f};
      std::copy_n(inst, 12, reinterpret_cast<float*>(mesh.data()));
      for (UINT row = 0; row < 3; ++row)
        reinterpret_cast<float*>(mesh.data())[row * 4 + 3] = inst[row * 4] * origin[0] + inst[row * 4 + 1] * origin[1] + inst[row * 4 + 2] * origin[2] + inst[row * 4 + 3];
      reinterpret_cast<float*>(mesh.data())[24] = 1;
    }
    auto mesh_buffer = Buffer(device.Get(), mesh.data(), UINT(mesh.size()), D3D11_BIND_CONSTANT_BUFFER);
    context->VSSetConstantBuffers(2, 1, mesh_buffer.GetAddressOf());
    using Reflect = HRESULT(WINAPI*)(const void*, SIZE_T, REFIID, void**);
    auto reflect = reinterpret_cast<Reflect>(GetProcAddress(LoadLibraryW(L"d3dcompiler_47.dll"), "D3DReflect"));
    ComPtr<ID3D11ShaderReflection> reflection;
    assert(SUCCEEDED(reflect(native.data(), native.size(), __uuidof(ID3D11ShaderReflection), &reflection)));
    D3D11_SHADER_DESC desc;
    reflection->GetDesc(&desc);
    std::vector<D3D11_SO_DECLARATION_ENTRY> outputs;
    std::vector<UINT> lighting_components;
    UINT count = 0;
    const UINT first_lighting_semantic = (std::string_view(hash) == "0xAB3E8304" || std::string_view(hash) == "0xB0B4EB6F") ? 2u : 1u;
    for (UINT i = 0; i < desc.OutputParameters; ++i) {
      D3D11_SIGNATURE_PARAMETER_DESC d;
      reflection->GetOutputParameterDesc(i, &d);
      BYTE n = BYTE(std::popcount(d.Mask));
      outputs.push_back({0, d.SemanticName, d.SemanticIndex, 0, n, 0});
      if (std::string_view(d.SemanticName) == "TEXCOORD"
          && (d.SemanticIndex == first_lighting_semantic || d.SemanticIndex == first_lighting_semantic + 1))
        for (UINT c = 0; c < 3; ++c) lighting_components.push_back(count + c);
      count += n;
    }

    float worst = 0, lighting_energy = 0;
    UINT failures = 0, finite_lighting = 0;
    assert(lighting_components.size() == 6);
    for (UINT sample = 0; sample < 12; ++sample) {
      Vertex vertices[3]{};
      for (UINT v = 0; v < 3; ++v) {
        auto& vertex = vertices[v];
        for (UINT c = 0; c < 3; ++c) {
          vertex.p[c] = .2f * std::sin(float(sample * 3 + c * 7 + v * 5));
          vertex.normal[c] = .1f + .8f * float((sample * 7 + c * 11 + v) % 37) / 36;
          vertex.tangent[c] = .1f + .8f * float((sample * 11 + c * 13 + v) % 41) / 40;
        }
        vertex.tangent[3] = sample % 2;
        for (UINT c = 0; c < 4; ++c) {
          vertex.index[c] = c;
          vertex.weight[c] = .1f * (c + 1);
          vertex.color[c] = .7f;
        }
        vertex.uv[0] = .31f;
        vertex.uv[1] = .59f;
      }
      auto vb = Buffer(device.Get(), vertices, sizeof(vertices), D3D11_BIND_VERTEX_BUFFER);
      const UINT stride = sizeof(Vertex);
      context->IASetVertexBuffers(0, 1, vb.GetAddressOf(), &stride, &offset);
      const auto a = VertexOutputs(device.Get(), context.Get(), native, outputs), b = VertexOutputs(device.Get(), context.Get(), replacement, outputs);
      for (UINT i = 0; i < a.size(); ++i) {
        const UINT component = i % count;
        if (std::find(lighting_components.begin(), lighting_components.end(), component) != lighting_components.end()) {
          assert(std::isfinite(a[i]) && std::isfinite(b[i]));
          lighting_energy += std::abs(a[i]);
          ++finite_lighting;
        }
        if (std::isfinite(a[i]) && std::isfinite(b[i])) worst = std::max(worst, std::abs(a[i] - b[i]));
        if (!SameColor(a[i], b[i])) {
          if (failures < 30) std::cout << "sample=" << sample << " component=" << i % count << " native=" << a[i] << " actual=" << b[i] << '\n';
          ++failures;
        }
      }
    }
    assert(finite_lighting == 12 * 3 * 6 && lighting_energy > .01f);
    std::cout << hash << " captured probe lighting: components=" << count << " worst=" << worst << " failures=" << failures
              << " finite lighting=" << finite_lighting << " energy=" << lighting_energy << '\n';
    total_failures += failures;
  }
  return total_failures ? 1 : 0;
}
