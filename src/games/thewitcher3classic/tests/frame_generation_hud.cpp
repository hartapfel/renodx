/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
// Compare replacement target 0 against the game's ORIGINAL DXBC and verify
// accumulated R8 UI opacity. GPU readbacks are confined to this fixture.
#include <d3dcompiler.h>
#include <embed/shaders.h>
#include <array>
#include <cmath>
#include <cassert>
#include <cstdio>
#include <filesystem>
#include <fstream>
#include "../frame_generation/capture.hpp"
#include "../shared.h"

using namespace witcher3classic::frame_generation;
int wmain(int argc, wchar_t** argv) {
  std::setvbuf(stdout, nullptr, _IONBF, 0);
  if (argc != 2) return 2;
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> base;
  ComPtr<ID3D11DeviceContext1> context;
  assert(SUCCEEDED(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &base)));
  assert(SUCCEEDED(base.As(&context)));
  Capture capture;
  assert(capture.Initialize(device.Get(), __swap_chain_proxy_vertex_shader, __swap_chain_proxy_pixel_shader, sizeof(ShaderInjectData)));
  const char* vertex_sources[] = {R"(
struct Output { float2 uv:TEXCOORD0; float4 color:COLOR0; float4 position:SV_Position; };
Output main(uint id:SV_VertexID) {
 Output o; float2 uv=float2(id==1?2:0,id==2?2:0); o.position=float4(uv*float2(2,-2)+float2(-1,1),0,1);
 o.uv=.5; o.color=float4(.4,.6,.7,.75); return o;
})",
                                  R"(
struct Output { float4 a:TEXCOORD0; float4 b:TEXCOORD1; float2 uv:TEXCOORD2; float4 position:SV_Position; };
Output main(uint id:SV_VertexID) {
 Output o; float2 uv=float2(id==1?2:0,id==2?2:0); o.position=float4(uv*float2(2,-2)+float2(-1,1),0,1);
 o.a=float4(.2,.3,.1,.15); o.b=float4(.8,.7,.6,.5); o.uv=.5; return o;
})",
                                  R"(
struct Output { float4 color:COLOR0; float4 a:TEXCOORD0; float4 b:TEXCOORD1; float2 uv:TEXCOORD2; float4 position:SV_Position; };
Output main(uint id:SV_VertexID) {
 Output o; float2 uv=float2(id==1?2:0,id==2?2:0); o.position=float4(uv*float2(2,-2)+float2(-1,1),0,1);
 o.a=float4(.2,.3,.1,.15); o.b=float4(.8,.7,.6,.5); o.uv=.5; o.color=float4(.4,.6,.7,.75); return o;
})",
                                  R"(
struct Output { float4 color:COLOR0; float4 opacity:COLOR1; float4 position:SV_Position; };
Output main(uint id:SV_VertexID) {
 Output o; float2 uv=float2(id==1?2:0,id==2?2:0); o.position=float4(uv*float2(2,-2)+float2(-1,1),0,1);
 o.color=float4(.4,.6,.7,.75); o.opacity=.5; return o;
})",
                                  R"(
struct Output { float4 color:COLOR0; float4 opacity:COLOR1; float4 a:TEXCOORD0; float4 b:TEXCOORD1; float4 position:SV_Position; };
Output main(uint id:SV_VertexID) {
 Output o; float2 uv=float2(id==1?2:0,id==2?2:0); o.position=float4(uv*float2(2,-2)+float2(-1,1),0,1);
 o.color=float4(.4,.6,.7,.75); o.opacity=.5; o.a=float4(.2,.3,.1,.15); o.b=float4(.8,.7,.6,.5); return o;
})",
                                  R"(
struct Output { float4 color:COLOR0; float2 uv:TEXCOORD0; float4 position:SV_Position; };
Output main(uint id:SV_VertexID) {
 Output o; float2 uv=float2(id==1?2:0,id==2?2:0); o.position=float4(uv*float2(2,-2)+float2(-1,1),0,1);
 o.color=float4(.4,.6,.7,.75); o.uv=.5; return o;
})",
                                  R"(
struct Output { float2 uv:TEXCOORD0; float4 position:SV_Position; };
Output main(uint id:SV_VertexID) {
 Output o; float2 uv=float2(id==1?2:0,id==2?2:0); o.position=float4(uv*float2(2,-2)+float2(-1,1),0,1);
 o.uv=.5; return o;
})"};
  std::array<ComPtr<ID3D11VertexShader>, std::size(vertex_sources)> vertices;
  for (size_t i = 0; i < vertices.size(); ++i) {
    ComPtr<ID3DBlob> bytecode, errors;
    assert(SUCCEEDED(D3DCompile(vertex_sources[i], std::strlen(vertex_sources[i]), nullptr, nullptr, nullptr, "main", "vs_5_0", D3DCOMPILE_OPTIMIZATION_LEVEL3, 0, &bytecode, &errors)));
    assert(SUCCEEDED(device->CreateVertexShader(bytecode->GetBufferPointer(), bytecode->GetBufferSize(), nullptr, &vertices[i])));
  }
  std::array<ComPtr<ID3D11PixelShader>, std::size(vertex_sources)> originals, replacements;
  const wchar_t* hashes[] = {L"0xC38B68F9", L"0xD7880DBE", L"0x7560E408", L"0xF1A79FBF", L"0x72826F5B", L"0xCC0C2DF3", L"0xD98FBA78"};
  const std::span<const uint8_t> compiled[] = {__0xC38B68F9, __0xD7880DBE, __0x7560E408, __0xF1A79FBF, __0x72826F5B, __0xCC0C2DF3, __0xD98FBA78};
  for (size_t i = 0; i < vertices.size(); ++i) {
    std::ifstream input(std::filesystem::path(argv[1]) / (std::wstring(hashes[i]) + L".ps_5_0.cso"), std::ios::binary);
    assert(input);
    std::vector<char> bytes((std::istreambuf_iterator<char>(input)), {});
    assert(SUCCEEDED(device->CreatePixelShader(bytes.data(), bytes.size(), nullptr, &originals[i])));
    assert(SUCCEEDED(device->CreatePixelShader(compiled[i].data(), compiled[i].size(), nullptr, &replacements[i])));
  }
  ComPtr<ID3D11Texture2D> target, reference, readback, input;
  D3D11_TEXTURE2D_DESC desc{16, 16, 1, 1, DXGI_FORMAT_R16G16B16A16_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_RENDER_TARGET};
  assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &target)));
  assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &reference)));
  desc.Usage = D3D11_USAGE_STAGING;
  desc.BindFlags = 0;
  desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
  assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &readback)));
  desc = {1, 1, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0}, D3D11_USAGE_IMMUTABLE, D3D11_BIND_SHADER_RESOURCE};
  const float pixel[] = {.25f, .5f, .75f, .5f};
  const D3D11_SUBRESOURCE_DATA initial{pixel, sizeof(pixel)};
  assert(SUCCEEDED(device->CreateTexture2D(&desc, &initial, &input)));
  ComPtr<ID3D11ShaderResourceView> srv;
  ComPtr<ID3D11RenderTargetView> rtv;
  assert(SUCCEEDED(device->CreateShaderResourceView(input.Get(), nullptr, &srv)));
  assert(SUCCEEDED(device->CreateRenderTargetView(target.Get(), nullptr, &rtv)));
  D3D11_BLEND_DESC blend = CD3D11_BLEND_DESC(D3D11_DEFAULT);
  blend.RenderTarget[0] = {TRUE, D3D11_BLEND_SRC_ALPHA, D3D11_BLEND_INV_SRC_ALPHA, D3D11_BLEND_OP_ADD,
                           D3D11_BLEND_ONE, D3D11_BLEND_INV_SRC_ALPHA, D3D11_BLEND_OP_ADD, D3D11_COLOR_WRITE_ENABLE_ALL};
  ComPtr<ID3D11BlendState> blend_state;
  assert(SUCCEEDED(device->CreateBlendState(&blend, &blend_state)));
  D3D11_SAMPLER_DESC sampler = CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
  ComPtr<ID3D11SamplerState> sampler_state;
  assert(SUCCEEDED(device->CreateSamplerState(&sampler, &sampler_state)));
  auto* source = srv.Get();
  auto* target_view = rtv.Get();
  auto* sample = sampler_state.Get();
  context->PSSetShaderResources(0, 1, &source);
  context->PSSetSamplers(0, 1, &sample);
  context->OMSetRenderTargets(1, &target_view, nullptr);
  context->OMSetBlendState(blend_state.Get(), nullptr, UINT_MAX);
  const D3D11_VIEWPORT viewport{0, 0, 16, 16, 0, 1};
  context->RSSetViewports(1, &viewport);
  context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
  const float clear[] = {.6f, .5f, .4f, 1.f};
  for (UINT pass = 0; pass < 2; ++pass) {
    context->ClearRenderTargetView(rtv.Get(), clear);
    capture.Reset(pass);
    if (pass) assert(capture.BeginScene(context.Get(), pass, 16, 16));
    for (size_t i = 0; i < vertices.size(); ++i) {
      context->VSSetShader(vertices[i].Get(), nullptr, 0);
      if (pass) assert(capture.BeginUI(context.Get(), pass, 16, 16));
      context->PSSetShader(pass ? replacements[i].Get() : originals[i].Get(), nullptr, 0);
      context->Draw(3, 0);
      if (pass) capture.EndUI(context.Get());
    }
    context->CopyResource(pass ? readback.Get() : reference.Get(), target.Get());
  }
  ComPtr<ID3D11Texture2D> reference_readback;
  readback->GetDesc(&desc);
  assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &reference_readback)));
  context->CopyResource(reference_readback.Get(), reference.Get());
  D3D11_MAPPED_SUBRESOURCE baseline{}, modified{};
  assert(SUCCEEDED(context->Map(reference_readback.Get(), 0, D3D11_MAP_READ, 0, &baseline)));
  assert(SUCCEEDED(context->Map(readback.Get(), 0, D3D11_MAP_READ, 0, &modified)));
  for (UINT row = 0; row < 16; ++row)
    assert(std::memcmp(static_cast<uint8_t*>(baseline.pData) + row * baseline.RowPitch,
                       static_cast<uint8_t*>(modified.pData) + row * modified.RowPitch, 16 * 8)
           == 0);
  context->Unmap(reference_readback.Get(), 0);
  context->Unmap(readback.Get(), 0);
  desc.Format = DXGI_FORMAT_R8_UNORM;
  ComPtr<ID3D11Texture2D> alpha_readback;
  assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &alpha_readback)));
  context->CopyResource(alpha_readback.Get(), capture.alpha.Get());
  assert(SUCCEEDED(context->Map(alpha_readback.Get(), 0, D3D11_MAP_READ, 0, &modified)));
  int expected_alpha = 0;
  for (const float alpha : {.1875f, .4f, .3f, .375f, .2625f, .375f, .5f})
    expected_alpha = int(std::lround(alpha * 255.f + (1.f - alpha) * expected_alpha));
  for (UINT row = 0; row < 16; ++row)
    for (UINT col = 0; col < 16; ++col) {
      const int alpha = static_cast<uint8_t*>(modified.pData)[row * modified.RowPitch + col];
      if (!row && !col) std::printf("Accumulated UI alpha: %d\n", alpha);
      assert(std::abs(alpha - expected_alpha) <= 1);
    }
  context->Unmap(alpha_readback.Get(), 0);
  ShaderInjectData injection{};
  injection.peak_white_nits=1000.f; injection.diffuse_white_nits=injection.graphics_white_nits=203.f;
  assert(capture.Encode(context.Get(),&injection));
  ComPtr<ID3D11RenderTargetView> restored_target; ComPtr<ID3D11BlendState> restored_blend;
  context->OMGetRenderTargets(1,&restored_target,nullptr); context->OMGetBlendState(&restored_blend,nullptr,nullptr);
  assert(restored_target==rtv && restored_blend==blend_state);
  desc.Format=DXGI_FORMAT_R10G10B10A2_UNORM; ComPtr<ID3D11Texture2D> encoded_readback;
  assert(SUCCEEDED(device->CreateTexture2D(&desc,nullptr,&encoded_readback)));
  context->CopyResource(encoded_readback.Get(),capture.hudless.Get());
  assert(SUCCEEDED(context->Map(encoded_readback.Get(),0,D3D11_MAP_READ,0,&modified)));
  // Independent BT.709 -> BT.2020 and ST 2084 reference for the pre-HUD
  // gray-brown patch. This checks scene preservation and correct HDR encoding.
  const double gamut[3][3]={{.6274038959,.3292830384,.0433130657},{.0690972894,.9195403951,.0113623156},{.0163914389,.0880133079,.8955952532}};
  const double encoded_scene[]={.60009765625,.5,.39990234375}; // Actual FP16 clear values.
  int expected_pq[3];
  for (size_t c=0;c<3;++c) {
    double nits=0; for (size_t k=0;k<3;++k) nits+=gamut[c][k]*std::pow(encoded_scene[k],2.2)*203.;
    const double p=std::pow(nits/10000.,2610./16384.);
    expected_pq[c]=int(std::lround(1023.*std::pow((3424./4096.+2413./128.*p)/(1.+2392./128.*p),2523./32.)));
  }
  for (UINT row=0;row<16;++row) for (UINT col=0;col<16;++col) {
    const auto packed=reinterpret_cast<const uint32_t*>(static_cast<uint8_t*>(modified.pData)+row*modified.RowPitch)[col];
    for (UINT c=0;c<3;++c) assert(std::abs(int((packed>>(10*c))&1023)-expected_pq[c])<=2);
  }
  context->Unmap(encoded_readback.Get(),0);
  // Radial-menu stencil construction uses the captured UI target but writes
  // no color. Neither an unknown shader nor a known UI shader may reject the
  // frame or accumulate opacity for those draws.
  blend.RenderTarget[0].RenderTargetWriteMask = 0;
  ComPtr<ID3D11BlendState> stencil_blend;
  assert(SUCCEEDED(device->CreateBlendState(&blend, &stencil_blend)));
  context->OMSetBlendState(stencil_blend.Get(), nullptr, UINT_MAX);
  capture.ObserveDraw(context.Get(), false);
  assert(capture.valid);
  assert(!capture.BeginUI(context.Get(), 1, 16, 16));
  assert(capture.valid);
  context->OMGetRenderTargets(1, &restored_target, nullptr);
  context->OMGetBlendState(&restored_blend, nullptr, nullptr);
  assert(restored_target == rtv && restored_blend == stencil_blend);
  context->OMSetBlendState(blend_state.Get(), nullptr, UINT_MAX);
  assert(capture.BeginUI(context.Get(), 1, 16, 16));
  capture.EndUI(context.Get());
  // Native HUD filters may render another UI surface between main-HUD draws.
  // Neither equal-size nor smaller offscreen targets may invalidate capture.
  for (const UINT size : {16u, 4u}) {
    ComPtr<ID3D11Texture2D> offscreen;
    ComPtr<ID3D11RenderTargetView> offscreen_view;
    D3D11_TEXTURE2D_DESC filter{size, size, 1, 1, DXGI_FORMAT_R8G8B8A8_UNORM, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_RENDER_TARGET};
    assert(SUCCEEDED(device->CreateTexture2D(&filter, nullptr, &offscreen)));
    assert(SUCCEEDED(device->CreateRenderTargetView(offscreen.Get(), nullptr, &offscreen_view)));
    auto* filter_target = offscreen_view.Get();
    context->OMSetRenderTargets(1, &filter_target, nullptr);
    capture.ObserveDraw(context.Get(), false);
    assert(!capture.BeginUI(context.Get(), 1, 16, 16) && capture.valid);
    context->OMGetRenderTargets(1, &restored_target, nullptr);
    assert(restored_target == offscreen_view);
  }
  context->OMSetRenderTargets(1, &target_view, nullptr);
  assert(capture.BeginUI(context.Get(), 1, 16, 16) && capture.valid);
  capture.EndUI(context.Get());
  // The same unknown shader with color writes must still reject the frame.
  capture.ObserveDraw(context.Get(), false);
  assert(!capture.valid);
  // Additive UI cannot supply a source-over alpha mask. Preserve the scene,
  // omit alpha for the whole frame and never recapture already composited UI.
  capture.Reset(2);
  blend.RenderTarget[0].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;
  blend.RenderTarget[0].SrcBlend = D3D11_BLEND_SRC_ALPHA;
  blend.RenderTarget[0].DestBlend = D3D11_BLEND_ONE;
  ComPtr<ID3D11BlendState> additive_blend;
  assert(SUCCEEDED(device->CreateBlendState(&blend, &additive_blend)));
  context->ClearRenderTargetView(rtv.Get(), clear);
  context->OMSetBlendState(additive_blend.Get(), nullptr, UINT_MAX);
  assert(!capture.BeginUI(context.Get(), 2, 16, 16));
  assert(capture.valid && !capture.alpha_valid && capture.Encode(context.Get(), &injection));
  context->PSSetShader(originals.back().Get(), nullptr, 0);
  context->Draw(3, 0);
  context->OMSetBlendState(blend_state.Get(), nullptr, UINT_MAX);
  assert(!capture.BeginUI(context.Get(), 2, 16, 16));
  assert(capture.valid && !capture.alpha_valid);
  assert(capture.Encode(context.Get(), &injection));
  context->CopyResource(encoded_readback.Get(), capture.hudless.Get());
  assert(SUCCEEDED(context->Map(encoded_readback.Get(), 0, D3D11_MAP_READ, 0, &modified)));
  const auto additive_hudless = *static_cast<const uint32_t*>(modified.pData);
  for (UINT c = 0; c < 3; ++c) assert(std::abs(int((additive_hudless >> (10*c)) & 1023) - expected_pq[c]) <= 2);
  context->Unmap(encoded_readback.Get(), 0);
  // Hiding the HUD leaves a complete scene and an entirely transparent mask.
  capture.Reset(3);
  context->ClearRenderTargetView(rtv.Get(), clear);
  assert(capture.BeginScene(context.Get(), 3, 16, 16));
  assert(capture.BeginUI(context.Get(), 3, 16, 16)); // Missing alpha cannot leak into the next frame.
  capture.EndUI(context.Get());
  assert(capture.valid && capture.alpha_valid && capture.Encode(context.Get(), &injection));
  assert(!capture.BeginScene(context.Get(), 3, 16, 16)); // Never recapture later UI.
  context->CopyResource(alpha_readback.Get(), capture.alpha.Get());
  assert(SUCCEEDED(context->Map(alpha_readback.Get(), 0, D3D11_MAP_READ, 0, &modified)));
  for (UINT row = 0; row < 16; ++row)
    for (UINT col = 0; col < 16; ++col)
      assert(static_cast<uint8_t*>(modified.pData)[row * modified.RowPitch + col] == 0);
  context->Unmap(alpha_readback.Get(), 0);
  std::puts("PASS: original DXBC color preserved bit-for-bit; R8 UI alpha, independent PQ/BT.2020 reference, context restoration and rejection checks passed.");
}
