/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include <d3d11sdklayers.h>
#include <d3dcompiler.h>
#include <bit>
#include <format>
#include <iostream>
#include "../temporal/object_motion.hpp"
#include "../temporal/object_shaders.hpp"
#include "./motion_gpu.hpp"
#include "./vertex_outputs.hpp"
using namespace witcher3classic::temporal;

int main(int argc, char** argv) {
  std::cout << std::unitbuf;
  assert(argc == 2 || argc == 3);
  const std::filesystem::path captures = argv[1], embeds = "build/thewitcher3classic.include/embed";
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> base;
  auto result = D3D11CreateDevice(nullptr, argc == 3 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP,
                                  nullptr, D3D11_CREATE_DEVICE_DEBUG, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &base);
  if (FAILED(result)) result = D3D11CreateDevice(nullptr, argc == 3 ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP,
                                                 nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &base);
  assert(SUCCEEDED(result));
  ComPtr<ID3D11DeviceContext1> context;
  assert(SUCCEEDED(base.As(&context)));
  using Reflect = HRESULT(WINAPI*)(const void*, SIZE_T, REFIID, void**);
  const auto reflect = reinterpret_cast<Reflect>(GetProcAddress(LoadLibraryW(L"d3dcompiler_47.dll"), "D3DReflect"));
  assert(reflect);
  std::array<ComPtr<ID3D11Texture2D>, 3> colors;
  std::array<ComPtr<ID3D11RenderTargetView>, 3> targets;
  for (UINT i = 0; i < 3; ++i) {
    const D3D11_TEXTURE2D_DESC desc{64, 64, 1, 1, DXGI_FORMAT_R16G16B16A16_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_RENDER_TARGET};
    assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &colors[i])));
    assert(SUCCEEDED(device->CreateRenderTargetView(colors[i].Get(), nullptr, &targets[i])));
  }
  ComPtr<ID3D11Texture2D> depth;
  ComPtr<ID3D11DepthStencilView> depth_view;
  const D3D11_TEXTURE2D_DESC depth_desc{64, 64, 1, 1, DXGI_FORMAT_D32_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_DEPTH_STENCIL};
  assert(SUCCEEDED(device->CreateTexture2D(&depth_desc, nullptr, &depth)));
  assert(SUCCEEDED(device->CreateDepthStencilView(depth.Get(), nullptr, &depth_view)));
  ID3D11RenderTargetView* rt[] = {targets[0].Get(), targets[1].Get(), targets[2].Get()};
  context->OMSetRenderTargets(3, rt, depth_view.Get());
  const D3D11_VIEWPORT viewport{0, 0, 64, 64, 0, 1};
  context->RSSetViewports(1, &viewport);
  context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  constexpr UINT slots[] = {0, 1, 2, 3, 11, 12};
  const auto sampler_desc = CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
  ComPtr<ID3D11SamplerState> sampler;
  assert(SUCCEEDED(device->CreateSamplerState(&sampler_desc, &sampler)));
  auto* samp = sampler.Get();
  for (UINT s = 0; s < 16; ++s) context->VSSetSamplers(s, 1, &samp);
  const float texel[] = {.6f, .65f, .8f, 1.f};
  const D3D11_TEXTURE2D_DESC tex_desc{1, 1, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0}, D3D11_USAGE_IMMUTABLE, D3D11_BIND_SHADER_RESOURCE};
  const D3D11_SUBRESOURCE_DATA initial{texel, sizeof(texel)};
  ComPtr<ID3D11Texture2D> texture;
  ComPtr<ID3D11ShaderResourceView> texture_view, array_view;
  assert(SUCCEEDED(device->CreateTexture2D(&tex_desc, &initial, &texture)));
  assert(SUCCEEDED(device->CreateShaderResourceView(texture.Get(), nullptr, &texture_view)));
  D3D11_SHADER_RESOURCE_VIEW_DESC array_desc{};
  array_desc.Format = tex_desc.Format;
  array_desc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2DARRAY;
  array_desc.Texture2DArray.MipLevels = array_desc.Texture2DArray.ArraySize = 1;
  assert(SUCCEEDED(device->CreateShaderResourceView(texture.Get(), &array_desc, &array_view)));
  auto* srv = texture_view.Get();
  context->VSSetShaderResources(3, 1, &srv);
  srv = array_view.Get();
  context->VSSetShaderResources(4, 1, &srv);
  UINT clip_differences = 0, prior_differences = 0;
  for (const auto& shader : OBJECT_VERTEX_SHADERS) {
    if (!shader.foliage) continue;
    const auto native = Read(captures / std::format("0x{:08X}.cso", shader.hash));
    const auto modified = Read(embeds / std::format("0x{:08X}.cso", shader.hash));
    std::array<std::array<std::vector<float>, 6>, 2> data;
    std::array<ComPtr<ID3D11Buffer>, 6> buffers;
    for (UINT n = 0; n < 2; ++n)
      for (UINT i = 0; i < 6; ++i) {
        const auto bytes = Read(captures / std::format("0x{:08X}-{}-b{}.bin", shader.hash, n, slots[i]));
        data[n][i].resize(bytes.size() / 4);
        std::memcpy(data[n][i].data(), bytes.data(), bytes.size());
        if (!n) buffers[i] = Buffer(device.Get(), bytes.data(), UINT(bytes.size()), D3D11_BIND_CONSTANT_BUFFER);
      }
    ComPtr<ID3D11ShaderReflection> reflection;
    assert(SUCCEEDED(reflect(native.data(), native.size(), __uuidof(ID3D11ShaderReflection), &reflection)));
    D3D11_SHADER_DESC desc;
    assert(SUCCEEDED(reflection->GetDesc(&desc)));
    std::vector<D3D11_INPUT_ELEMENT_DESC> layout;
    for (UINT i = 0; i < desc.InputParameters; ++i) {
      D3D11_SIGNATURE_PARAMETER_DESC p;
      assert(SUCCEEDED(reflection->GetInputParameterDesc(i, &p)));
      assert(p.ComponentType == D3D_REGISTER_COMPONENT_FLOAT32);
      layout.push_back({p.SemanticName, p.SemanticIndex, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, p.Register * 16});
    }
    ComPtr<ID3D11InputLayout> input;
    assert(SUCCEEDED(device->CreateInputLayout(layout.data(), UINT(layout.size()), native.data(), native.size(), &input)));
    context->IASetInputLayout(input.Get());
    std::vector<D3D11_SO_DECLARATION_ENTRY> outputs;
    UINT components = 0;
    for (UINT i = 0; i < desc.OutputParameters; ++i) {
      D3D11_SIGNATURE_PARAMETER_DESC p;
      assert(SUCCEEDED(reflection->GetOutputParameterDesc(i, &p)));
      const auto count = BYTE(std::popcount(p.Mask));
      assert(p.Mask == (1u << count) - 1);
      outputs.push_back({0, p.SemanticName, p.SemanticIndex, 0, count, 0});
      components += count;
    }
    assert(std::string_view(outputs[0].SemanticName) == "SV_POSITION");
    outputs.push_back({0, "TEXCOORD", 10, 0, 4, 0});
    outputs.push_back({0, "TEXCOORD", 11, 0, 1, 0});
    std::array<std::array<std::array<float, 4>, 11>, 3> vertices{};
    for (UINT v = 0; v < 3; ++v) {
      for (UINT i = 0; i < 11; ++i) vertices[v][i] = {.2f, .4f, .6f, .8f};
      for (UINT c = 0; c < 3; ++c) vertices[v][0][c] = data[0][0][64 + c] + data[0][0][68 + c] * 10.f;
      vertices[v][0][3] = 1.f;
      vertices[v][1] = {0, 0, 1, .3f};
      vertices[v][2] = {1, 0, 0, .6f};
      vertices[v][3] = {float(v) - 1.f, .2f, .5f + float(v) * .2f, .3f};
      vertices[v][9] = {.7f, .6f, .9f, .8f};
    }
    auto vb = Buffer(device.Get(), vertices.data(), sizeof(vertices), D3D11_BIND_VERTEX_BUFFER);
    auto* vertex_buffer = vb.Get();
    const UINT stride = sizeof(vertices[0]), offset = 0;
    context->IASetVertexBuffers(0, 1, &vertex_buffer, &stride, &offset);
    for (UINT scenario = 0; scenario < 3; ++scenario) {
      ObjectMotion motion;
      motion.uploads.track_writes = true;
      motion.Configure(depth.Get(), 64, 64);
      auto states = data;
      if (scenario == 1) {
        // Freeze camera and wind, move a contact ellipsoid across this mesh.
        states[1] = states[0];
        for (UINT n = 0; n < 2; ++n) {
          std::fill(states[n][4].begin() + 4, states[n][4].begin() + 260, 0.f);
          states[n][4][4] = states[n][4][9] = states[n][4][14] = 2.f;
          for (UINT c = 0; c < 3; ++c) states[n][4][16 + c] = vertices[0][0][c];
          states[n][4][16] += (n == 0 ? -.25f : .25f);
          states[n][4][19] = 1.f;
          states[n][4][260] = std::bit_cast<float>(1u);
          states[n][1][118] = 1.f;
        }
      } else if (scenario == 2) {
        // Freeze the camera/contacts; exercise a visibly different wind phase.
        states[1] = states[0];
        for (UINT i : {8u, 16u, 24u, 32u, 35u, 41u, 44u, 47u, 53u, 56u}) states[1][3][i] += .4f;
      }
      std::array<std::vector<float>, 2> original_outputs;
      std::vector<float> extended;
      for (UINT n = 0; n < 2; ++n) {
        for (UINT i = 0; i < 6; ++i) {
          motion.uploads.Update(buffers[i].Get(), states[n][i].data(), 0, UINT64_MAX);
          context->UpdateSubresource(buffers[i].Get(), 0, nullptr, states[n][i].data(), 0, 0);
          auto* cb = slots[i] == 11 && !(shader.foliage & 16) ? nullptr : buffers[i].Get();
          context->VSSetConstantBuffers(slots[i], 1, &cb);
        }
        original_outputs[n] = VertexOutputs(device.Get(), context.Get(), native, std::span(outputs).first(desc.OutputParameters));
        assert(motion.Begin(context.Get(), n, false, false, false, false, shader.foliage));
        extended = VertexOutputs(device.Get(), context.Get(), modified, outputs);
        motion.End(context.Get(), true);
        assert(motion.HasPendingPass());
        // A second covered draw reuses the motion attachments/blend state,
        // while constants still restore after every individual draw.
        assert(motion.Begin(context.Get(), n, false, false, false, false, shader.foliage));
        const auto repeated = VertexOutputs(device.Get(), context.Get(), modified, outputs);
        assert(repeated.size() == extended.size() && std::memcmp(repeated.data(), extended.data(), repeated.size() * sizeof(float)) == 0);
        motion.End(context.Get(), true);
        motion.ClosePass(context.Get());
        assert(!motion.HasPendingPass());
        std::array<ID3D11RenderTargetView*, 5> restored_targets = {};
        context->OMGetRenderTargets(UINT(restored_targets.size()), restored_targets.data(), nullptr);
        for (UINT i = 0; i < 5; ++i) {
          assert(restored_targets[i] == (i < 3 ? rt[i] : nullptr));
          if (restored_targets[i]) restored_targets[i]->Release();
        }
        // The history-only profiling stage restores state before the native
        // draw. All original outputs must survive that preparation round trip.
        assert(motion.Begin(context.Get(), n, false, false, false, false, shader.foliage));
        motion.End(context.Get());
        const auto after_history = VertexOutputs(device.Get(), context.Get(), native, std::span(outputs).first(desc.OutputParameters));
        assert(after_history.size() == original_outputs[n].size());
        assert(std::memcmp(after_history.data(), original_outputs[n].data(), after_history.size() * sizeof(float)) == 0);
        for (UINT v = 0; v < 3; ++v) {
          for (UINT c = 0; c < components; ++c) {
            const float a = original_outputs[n][v * components + c], b = extended[v * (components + 5) + c];
            if (!SameColor(a, b)) std::cerr << std::format("varying {:08X} {} {} {} {}\n", shader.hash, v, c, a, b);
            assert(SameColor(a, b));
          }
          for (UINT c = 0; c < 4; ++c) clip_differences += std::bit_cast<UINT>(original_outputs[n][v * components + c]) != std::bit_cast<UINT>(extended[v * (components + 5) + c]);
          assert(extended[v * (components + 5) + components + 4] == float(n));
          if (n)
            for (UINT c = 0; c < 4; ++c) {
              const float expected = original_outputs[0][v * components + c] - (c < 2 ? states[0][5][60 + c] * original_outputs[0][v * components + 3] : 0.f);
              const float actual = extended[v * (components + 5) + components + c];
              if (!std::isfinite(actual) || std::abs(expected - actual) > 2e-4f) {
                ++prior_differences;
                std::cerr << std::format("previous {:08X} scenario {} v{} c{} {} {}\n", shader.hash, scenario, v, c, expected, actual);
              }
            }
        }
        // Native collision b11 and all other native CBs survive the draw.
        for (UINT i = 0; i < 6; ++i) {
          ComPtr<ID3D11Buffer> restored;
          context->VSGetConstantBuffers(slots[i], 1, &restored);
          assert(restored.Get() == (slots[i] == 11 && !(shader.foliage & 16) ? nullptr : buffers[i].Get()));
        }
        motion.Finish(context.Get(), n);
      }
      float movement = 0;
      for (UINT v = 0; v < 3; ++v)
        for (UINT c = 0; c < 3; ++c) movement += std::abs(original_outputs[0][v * components + c] - original_outputs[1][v * components + c]);
      std::cout << std::format("PASS foliage {:08X} scenario {} native delta {}\n", shader.hash, scenario, movement);
      if (shader.hash == 0x134AA93D && scenario) assert(movement > 1e-5f);
      // An unobserved frame invalidates history; it never reuses an older pose.
      assert(motion.Begin(context.Get(), 3, false, false, false, false, shader.foliage));
      extended = VertexOutputs(device.Get(), context.Get(), modified, outputs);
      motion.End(context.Get());
      for (UINT v = 0; v < 3; ++v) assert(extended[v * (components + 5) + components + 4] == 0.f);
      // A native pass change owns its new bindings. Closing our old batch must
      // not resurrect the preceding G-buffer targets or blend state.
      assert(motion.Begin(context.Get(), 4, false, false, false, false, shader.foliage));
      motion.End(context.Get(), true);
      context->OMSetRenderTargets(1, rt, nullptr);
      auto native_blend_desc = CD3D11_BLEND_DESC(D3D11_DEFAULT);
      native_blend_desc.RenderTarget[0].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_RED;
      ComPtr<ID3D11BlendState> new_blend, actual_blend;
      assert(SUCCEEDED(device->CreateBlendState(&native_blend_desc, &new_blend)));
      context->OMSetBlendState(new_blend.Get(), nullptr, UINT_MAX);
      motion.ClosePass(context.Get());
      context->OMGetBlendState(&actual_blend, nullptr, nullptr);
      assert(actual_blend == new_blend);
      std::array<ID3D11RenderTargetView*, 5> native_targets = {};
      context->OMGetRenderTargets(UINT(native_targets.size()), native_targets.data(), nullptr);
      for (UINT i = 0; i < 5; ++i) {
        assert(native_targets[i] == (i == 0 ? rt[0] : nullptr));
        if (native_targets[i]) native_targets[i]->Release();
      }
      context->OMSetRenderTargets(3, rt, depth_view.Get());
      context->OMSetBlendState(nullptr, nullptr, UINT_MAX);
    }
  }
  // Isolate native material/alpha coverage from vertex deformation. Feed both
  // pixel shaders identical full-screen varyings and exercise accepted/rejected
  // alpha or dissolve, with valid and invalid temporal history.
  auto depth_state_desc = CD3D11_DEPTH_STENCIL_DESC(D3D11_DEFAULT);
  depth_state_desc.DepthEnable = FALSE;
  ComPtr<ID3D11DepthStencilState> depth_state;
  assert(SUCCEEDED(device->CreateDepthStencilState(&depth_state_desc, &depth_state)));
  context->OMSetDepthStencilState(depth_state.Get(), 0);
  auto raster_desc = CD3D11_RASTERIZER_DESC(D3D11_DEFAULT);
  raster_desc.CullMode = D3D11_CULL_NONE;
  ComPtr<ID3D11RasterizerState> raster;
  assert(SUCCEEDED(device->CreateRasterizerState(&raster_desc, &raster)));
  context->RSSetState(raster.Get());
  using Compile = decltype(&D3DCompile);
  const auto compile = reinterpret_cast<Compile>(GetProcAddress(LoadLibraryW(L"d3dcompiler_47.dll"), "D3DCompile"));
  assert(compile);
  const float clear[] = {-2, -2, -2, -2};
  for (const auto& shader : OBJECT_PIXEL_SHADERS) {
    if (shader.signature < 20 || shader.signature > 23) continue;
    const auto native = Read(captures / std::format("0x{:08X}.cso", shader.hash));
    const auto modified = Read(embeds / std::format("0x{:08X}.cso", shader.hash));
    ComPtr<ID3D11PixelShader> native_ps, motion_ps;
    assert(SUCCEEDED(device->CreatePixelShader(native.data(), native.size(), nullptr, &native_ps)));
    assert(SUCCEEDED(device->CreatePixelShader(modified.data(), modified.size(), nullptr, &motion_ps)));
    const auto vertex = std::find_if(OBJECT_VERTEX_SHADERS.begin(), OBJECT_VERTEX_SHADERS.end(), [&](const auto& v) { return v.signature == shader.signature; });
    assert(vertex != OBJECT_VERTEX_SHADERS.end());
    std::array<ComPtr<ID3D11Buffer>, 6> constants;
    for (UINT i = 0; i < 6; ++i) {
      auto bytes = Read(captures / std::format("0x{:08X}-0-b{}.bin", vertex->hash, slots[i]));
      if (slots[i] == 12) {
        auto* values = reinterpret_cast<float*>(bytes.data());
        values[60] = values[61] = 0;
        values[92] = values[93] = 64;
        // Isolate billboard alpha from grain; native and replacement receive
        // the same constants. Its grain threshold is tested separately in-game.
        if (shader.hash == 0xCEC6D9F4) values[257] = values[258] = 0;
      }
      constants[i] = Buffer(device.Get(), bytes.data(), UINT(bytes.size()), D3D11_BIND_CONSTANT_BUFFER);
      auto* cb = constants[i].Get();
      context->VSSetConstantBuffers(slots[i], 1, &cb);
      context->PSSetConstantBuffers(slots[i], 1, &cb);
    }
    for (UINT s = 0; s < 16; ++s) context->PSSetSamplers(s, 1, &samp);
    ComPtr<ID3D11ShaderReflection> reflection;
    assert(SUCCEEDED(reflect(native.data(), native.size(), __uuidof(ID3D11ShaderReflection), &reflection)));
    D3D11_SHADER_DESC desc;
    assert(SUCCEEDED(reflection->GetDesc(&desc)));
    std::string fields, assignments;
    for (UINT i = 0; i < desc.InputParameters; ++i) {
      D3D11_SIGNATURE_PARAMETER_DESC p;
      assert(SUCCEEDED(reflection->GetInputParameterDesc(i, &p)));
      if (p.SystemValueType != D3D_NAME_UNDEFINED) continue;
      fields += std::format("float4 v{} : {}{};", i, p.SemanticName, p.SemanticIndex);
      assignments += std::format("o.v{}=float4(.5,.6,.7,1);", i);
    }
    for (UINT reject = 0; reject < 2; ++reject)
      for (UINT history = 0; history < 2; ++history) {
        const auto hlsl = std::string("struct O {float4 p:SV_POSITION;") + fields +
                          "float4 previous:TEXCOORD10;nointerpolation float history:TEXCOORD11;};O main(uint i:SV_VertexID){O o;"
                          "float2 p=float2((i<<1)&2,i&2)*2-1;o.p=float4(p,.5,1);"
                          + assignments + std::format("o.previous=o.p+float4(.25,0,0,0);o.history={};return o;}}", history);
        ComPtr<ID3DBlob> bytecode, messages;
        auto hr = compile(hlsl.data(), hlsl.size(), nullptr, nullptr, nullptr, "main", "vs_5_0", D3DCOMPILE_OPTIMIZATION_LEVEL3, 0, &bytecode, &messages);
        if (FAILED(hr) && messages) std::cerr << static_cast<const char*>(messages->GetBufferPointer());
        assert(SUCCEEDED(hr));
        ComPtr<ID3D11VertexShader> vs;
        assert(SUCCEEDED(device->CreateVertexShader(bytecode->GetBufferPointer(), bytecode->GetBufferSize(), nullptr, &vs)));
        context->VSSetShader(vs.Get(), nullptr, 0);
        context->IASetInputLayout(nullptr);
        const float rgba[] = {reject ? 0.f : .6f, .65f, .8f, reject ? 0.f : 1.f};
        const D3D11_SUBRESOURCE_DATA pixel_data{rgba, sizeof(rgba)};
        ComPtr<ID3D11Texture2D> material;
        ComPtr<ID3D11ShaderResourceView> material_view;
        assert(SUCCEEDED(device->CreateTexture2D(&tex_desc, &pixel_data, &material)));
        assert(SUCCEEDED(device->CreateShaderResourceView(material.Get(), nullptr, &material_view)));
        BindMaterialInputs(context.Get(), native, material_view.Get(), array_view.Get());
        for (auto& target : targets) context->ClearRenderTargetView(target.Get(), clear);
        context->PSSetShader(native_ps.Get(), nullptr, 0);
        context->Draw(3, 0);
        std::array<std::array<float, 4>, 3> expected;
        for (UINT i = 0; i < 3; ++i) expected[i] = Pixel(context.Get(), colors[i].Get());
        if ((expected[0][0] == -2.f) != bool(reject)) std::cerr << std::format("Coverage {:08X} reject {} history {} color {}\n", shader.hash, reject, history, expected[0][0]);
        assert((expected[0][0] == -2.f) == bool(reject));
        ObjectMotion motion;
        motion.Configure(depth.Get(), 64, 64);
        assert(motion.Begin(context.Get(), 0, false, false, false, false, vertex->foliage));
        for (auto& target : targets) context->ClearRenderTargetView(target.Get(), clear);
        context->PSSetShader(motion_ps.Get(), nullptr, 0);
        context->Draw(3, 0);
        motion.End(context.Get(), true);
        assert(motion.Begin(context.Get(), 0, false, false, false, false, vertex->foliage));
        context->Draw(3, 0);
        motion.End(context.Get(), true);
        assert(motion.target_reuses == 1);
        motion.ClosePass(context.Get());
        for (UINT i = 0; i < 3; ++i) {
          const auto actual = Pixel(context.Get(), colors[i].Get());
          for (UINT c = 0; c < 4; ++c) assert(SameColor(expected[i][c], actual[c]));
        }
        ComPtr<ID3D11Resource> vectors, surface;
        motion.surfaces[0]->GetResource(&vectors);
        motion.surfaces[1]->GetResource(&surface);
        assert(Pixel(context.Get(), surface.Get())[0] == (reject ? -2.f : history ? .5f
                                                                                  : -.5f));
        assert(std::abs(Pixel(context.Get(), vectors.Get())[0] - (reject || !history ? 0.f : .125f)) < .001f);
      }
    std::cout << std::format("PASS foliage material {:08X}: native G-buffer, alpha/dissolve, motion and history\n", shader.hash);
  }
  std::cout << "Current clip-bit differences: " << clip_differences << "; previous-position differences: " << prior_differences << '\n';
  assert(!clip_differences && !prior_differences);
  ComPtr<ID3D11InfoQueue> queue;
  if (FAILED(device.As(&queue))) {
    std::cout << "D3D11 debug layer unavailable; GPU assertions completed.\n";
    return 0;
  }
  UINT errors = 0;
  for (UINT64 i = 0; i < queue->GetNumStoredMessages(); ++i) {
    SIZE_T bytes = 0;
    queue->GetMessage(i, nullptr, &bytes);
    std::vector<uint8_t> memory(bytes);
    auto* m = reinterpret_cast<D3D11_MESSAGE*>(memory.data());
    queue->GetMessage(i, m, &bytes);
    if (m->Severity <= D3D11_MESSAGE_SEVERITY_ERROR) {
      ++errors;
      std::cerr << m->pDescription << '\n';
    }
  }
  assert(!errors);
}
