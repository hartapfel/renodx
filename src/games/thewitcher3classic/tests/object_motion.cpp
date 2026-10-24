/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include "../temporal/object_motion.hpp"
#include <d3d11sdklayers.h>
#include <d3d11shader.h>
#include <cassert>
#include <filesystem>
#include <format>
#include <fstream>
#include <iostream>
#include "../../../utils/float16.hpp"
#include "../temporal/object_shaders.hpp"
#include "../temporal/prepare.hpp"
#include "./vertex_outputs.hpp"

using namespace witcher3classic::temporal;
using Microsoft::WRL::ComPtr;

#include "./motion_gpu.hpp"

int main(int argc, char** argv) {
  uint32_t matched_nonfinite_colors = 0;
  const bool hardware = argc > 2 && std::string_view(argv[2]) == "--hardware";
  const bool forward_only = argc > 2 && std::string_view(argv[argc - 1]) == "--forward-only";
  const bool hair_clip_only = argc > 2 && std::string_view(argv[argc - 1]) == "--hair-clip-only";
  assert(argc == 2 || (argc == 3 && (hardware || forward_only || hair_clip_only)) || (argc == 4 && hardware && (forward_only || hair_clip_only)));
  const std::filesystem::path originals = argv[1], shaders = "build/thewitcher3classic.include/embed";
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> base;
  auto result = D3D11CreateDevice(nullptr, hardware ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP, nullptr, D3D11_CREATE_DEVICE_DEBUG, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &base);
  if (FAILED(result)) result = D3D11CreateDevice(nullptr, hardware ? D3D_DRIVER_TYPE_HARDWARE : D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &device, nullptr, &base);
  assert(SUCCEEDED(result));
  ComPtr<ID3D11DeviceContext1> context;
  assert(SUCCEEDED(base.As(&context)));
  std::array<ComPtr<ID3D11Texture2D>, 3> colors;
  std::array<ComPtr<ID3D11RenderTargetView>, 3> targets;
  for (size_t i = 0; i < colors.size(); ++i) {
    const D3D11_TEXTURE2D_DESC desc{64, 64, 1, 1, DXGI_FORMAT_R16G16B16A16_FLOAT, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE};
    assert(SUCCEEDED(device->CreateTexture2D(&desc, nullptr, &colors[i])));
    assert(SUCCEEDED(device->CreateRenderTargetView(colors[i].Get(), nullptr, &targets[i])));
  }
  ComPtr<ID3D11Texture2D> depth;
  const D3D11_TEXTURE2D_DESC depth_desc{64, 64, 1, 1, DXGI_FORMAT_R24G8_TYPELESS, {1, 0}, D3D11_USAGE_DEFAULT, D3D11_BIND_DEPTH_STENCIL | D3D11_BIND_SHADER_RESOURCE};
  assert(SUCCEEDED(device->CreateTexture2D(&depth_desc, nullptr, &depth)));
  ComPtr<ID3D11DepthStencilView> depth_view;
  const D3D11_DEPTH_STENCIL_VIEW_DESC dsv_desc{DXGI_FORMAT_D24_UNORM_S8_UINT, D3D11_DSV_DIMENSION_TEXTURE2D};
  assert(SUCCEEDED(device->CreateDepthStencilView(depth.Get(), &dsv_desc, &depth_view)));
  auto disabled_depth = CD3D11_DEPTH_STENCIL_DESC(D3D11_DEFAULT);
  disabled_depth.DepthEnable = FALSE;
  ComPtr<ID3D11DepthStencilState> depth_state;
  assert(SUCCEEDED(device->CreateDepthStencilState(&disabled_depth, &depth_state)));
  context->OMSetDepthStencilState(depth_state.Get(), 0);
  context->ClearDepthStencilView(depth_view.Get(), D3D11_CLEAR_DEPTH, 0.5f, 0);
  ID3D11RenderTargetView* render_targets[] = {targets[0].Get(), targets[1].Get(), targets[2].Get()};
  context->OMSetRenderTargets(3, render_targets, depth_view.Get());
  const D3D11_VIEWPORT viewport{0, 0, 64, 64, 0, 1};
  context->RSSetViewports(1, &viewport);
  auto raster_desc = CD3D11_RASTERIZER_DESC(D3D11_DEFAULT);
  raster_desc.CullMode = D3D11_CULL_NONE;
  ComPtr<ID3D11RasterizerState> raster;
  assert(SUCCEEDED(device->CreateRasterizerState(&raster_desc, &raster)));
  context->RSSetState(raster.Get());
  context->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);

  struct Vertex {
    float position[3];
    uint32_t indices[4];
    float weights[4];
    float uv[2], normal[3], tangent[4];
  };
  static_assert(sizeof(Vertex) == 80);
  const Vertex vertices[] = {
      {{-1, -1, .5f}, {0, 255, 255, 255}, {1, 0, 0, 0}, {.5f, .5f}, {.5f, .5f, 1}, {1, .5f, .5f, 1}},
      {{-1, 3, .5f}, {0, 255, 255, 255}, {1, 0, 0, 0}, {.5f, .5f}, {.5f, .5f, 1}, {1, .5f, .5f, 1}},
      {{3, -1, .5f}, {0, 255, 255, 255}, {1, 0, 0, 0}, {.5f, .5f}, {.5f, .5f, 1}, {1, .5f, .5f, 1}},
  };
  auto vertex_buffer = Buffer(device.Get(), vertices, sizeof(vertices), D3D11_BIND_VERTEX_BUFFER);
  float instance[20] = {1, 0, 0, .2f, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1};
  auto instances = Buffer(device.Get(), instance, sizeof(instance), D3D11_BIND_VERTEX_BUFFER);
  ID3D11Buffer* vb = vertex_buffer.Get();
  UINT stride = 80, offset = 0;
  context->IASetVertexBuffers(0, 1, &vb, &stride, &offset);
  vb = instances.Get();
  context->IASetVertexBuffers(7, 1, &vb, &stride, &offset);
  std::array<float, 64> view = {};
  for (UINT i = 0; i < 4; ++i) view[i * 5] = 1;
  view[3] = .05f;
  auto view_buffer = Buffer(device.Get(), view.data(), sizeof(view), D3D11_BIND_CONSTANT_BUFFER);
  std::array<float, 269 * 4> frame = {};
  frame[22 * 4] = -1;
  frame[22 * 4 + 1] = 1;
  frame[23 * 4] = frame[23 * 4 + 1] = 64;
  // Forward skin variants calculate fog varyings. Zero exponents would form
  // 0 * log2(0), so supply a finite native fog configuration in this fixture.
  frame[38 * 4 + 2] = 1;
  frame[42 * 4 + 2] = 1000;
  frame[42 * 4 + 3] = frame[48 * 4] = 1;
  frame[43 * 4] = .01f;
  frame[43 * 4 + 1] = .2f;
  frame[43 * 4 + 2] = .1f;
  frame[48 * 4 + 1] = .1f;
  frame[48 * 4 + 2] = 1;
  auto frame_buffer = Buffer(device.Get(), frame.data(), sizeof(frame), D3D11_BIND_CONSTANT_BUFFER);
  std::array<float, 32 * 4> material;
  material.fill(.5f);
  auto material_buffer = Buffer(device.Get(), material.data(), sizeof(material), D3D11_BIND_CONSTANT_BUFFER);
  std::array<float, 32 * 4> mesh;
  mesh.fill(.5f);
  mesh[16] = mesh[17] = mesh[18] = 1;
  mesh[20] = mesh[21] = mesh[22] = 0;
  for (UINT i = 0; i < 4; ++i) mesh[18 * 4 + i] = 0;
  auto mesh_buffer = Buffer(device.Get(), mesh.data(), sizeof(mesh), D3D11_BIND_CONSTANT_BUFFER);
  auto* cb = view_buffer.Get();
  context->VSSetConstantBuffers(1, 1, &cb);
  cb = mesh_buffer.Get();
  context->VSSetConstantBuffers(2, 1, &cb);
  context->VSSetConstantBuffers(3, 1, &cb);
  context->PSSetConstantBuffers(2, 1, &cb);
  cb = view_buffer.Get();
  context->PSSetConstantBuffers(1, 1, &cb);
  cb = material_buffer.Get();
  context->PSSetConstantBuffers(4, 1, &cb);
  cb = frame_buffer.Get();
  context->VSSetConstantBuffers(12, 1, &cb);
  context->PSSetConstantBuffers(12, 1, &cb);
  std::array<float, 64> bones = {};
  for (UINT bone = 0; bone < 4; ++bone)
    for (UINT i = 0; i < 4; ++i) bones[bone * 16 + i * 5] = 1;
  bones[16 + 12] = .1f;
  // Classic stores shading metadata in element 15. Native vertex shaders
  // explicitly replace it with 1 when transforming positions.
  bones[16 + 15] = .25f;
  auto bone_buffer = Buffer(device.Get(), bones.data(), sizeof(bones), D3D11_BIND_SHADER_RESOURCE, 64);
  ComPtr<ID3D11ShaderResourceView> bone_srv;
  assert(SUCCEEDED(device->CreateShaderResourceView(bone_buffer.Get(), nullptr, &bone_srv)));
  auto* srv = bone_srv.Get();
  context->VSSetShaderResources(0, 1, &srv);
  const float texel[] = {.5f, .5f, 1.f, 1.f};
  const D3D11_TEXTURE2D_DESC tex_desc{1, 1, 1, 1, DXGI_FORMAT_R32G32B32A32_FLOAT, {1, 0}, D3D11_USAGE_IMMUTABLE, D3D11_BIND_SHADER_RESOURCE};
  const D3D11_SUBRESOURCE_DATA tex_initial{texel, sizeof(texel)};
  ComPtr<ID3D11Texture2D> texture;
  ComPtr<ID3D11ShaderResourceView> texture_view;
  assert(SUCCEEDED(device->CreateTexture2D(&tex_desc, &tex_initial, &texture)));
  assert(SUCCEEDED(device->CreateShaderResourceView(texture.Get(), nullptr, &texture_view)));
  srv = texture_view.Get();
  context->VSSetShaderResources(1, 1, &srv);
  // Keep reference-pose positions separate from nondegenerate material data.
  const float material_texel[] = {.6f, .65f, .8f, 1.f};
  const D3D11_SUBRESOURCE_DATA material_initial{material_texel, sizeof(material_texel)};
  ComPtr<ID3D11Texture2D> material_texture;
  ComPtr<ID3D11ShaderResourceView> material_view;
  assert(SUCCEEDED(device->CreateTexture2D(&tex_desc, &material_initial, &material_texture)));
  assert(SUCCEEDED(device->CreateShaderResourceView(material_texture.Get(), nullptr, &material_view)));
  srv = material_view.Get();
  for (UINT slot = 0; slot < 32; ++slot) context->PSSetShaderResources(slot, 1, &srv);
  ComPtr<ID3D11ShaderResourceView> texture_array;
  D3D11_SHADER_RESOURCE_VIEW_DESC array_fixture{};
  array_fixture.Format = tex_desc.Format;
  array_fixture.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2DARRAY;
  array_fixture.Texture2DArray.MipLevels = array_fixture.Texture2DArray.ArraySize = 1;
  assert(SUCCEEDED(device->CreateShaderResourceView(material_texture.Get(), &array_fixture, &texture_array)));
  ComPtr<ID3D11Texture2D> cube_texture;
  ComPtr<ID3D11ShaderResourceView> cube_view, cubes_view;
  auto cube_desc = tex_desc;
  cube_desc.ArraySize = 6;
  cube_desc.MiscFlags = D3D11_RESOURCE_MISC_TEXTURECUBE;
  std::array<D3D11_SUBRESOURCE_DATA, 6> cube_initial;
  cube_initial.fill(material_initial);
  assert(SUCCEEDED(device->CreateTexture2D(&cube_desc, cube_initial.data(), &cube_texture)));
  assert(SUCCEEDED(device->CreateShaderResourceView(cube_texture.Get(), nullptr, &cube_view)));
  D3D11_SHADER_RESOURCE_VIEW_DESC cubes_desc{};
  cubes_desc.Format = tex_desc.Format;
  cubes_desc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURECUBEARRAY;
  cubes_desc.TextureCubeArray.MipLevels = cubes_desc.TextureCubeArray.NumCubes = 1;
  assert(SUCCEEDED(device->CreateShaderResourceView(cube_texture.Get(), &cubes_desc, &cubes_view)));
  std::array<float, 4096 * 4> forward_lights;
  forward_lights.fill(.5f);
  auto forward_light_cb = Buffer(device.Get(), forward_lights.data(), sizeof(forward_lights), D3D11_BIND_CONSTANT_BUFFER);
  cb = forward_light_cb.Get(); context->PSSetConstantBuffers(13, 1, &cb);
  std::array<uint32_t, 4096> forward_indices;
  forward_indices.fill(256);
  ComPtr<ID3D11Buffer> forward_raw;
  const D3D11_BUFFER_DESC forward_raw_desc{sizeof(forward_indices), D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE, 0, D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS};
  const D3D11_SUBRESOURCE_DATA forward_raw_data{forward_indices.data()};
  assert(SUCCEEDED(device->CreateBuffer(&forward_raw_desc, &forward_raw_data, &forward_raw)));
  D3D11_SHADER_RESOURCE_VIEW_DESC forward_raw_view{};
  forward_raw_view.Format = DXGI_FORMAT_R32_TYPELESS;
  forward_raw_view.ViewDimension = D3D11_SRV_DIMENSION_BUFFEREX;
  forward_raw_view.BufferEx.NumElements = UINT(forward_indices.size());
  forward_raw_view.BufferEx.Flags = D3D11_BUFFEREX_SRV_FLAG_RAW;
  ComPtr<ID3D11ShaderResourceView> forward_raw_srv;
  assert(SUCCEEDED(device->CreateShaderResourceView(forward_raw.Get(), &forward_raw_view, &forward_raw_srv)));
  srv = forward_raw_srv.Get(); context->PSSetShaderResources(20, 1, &srv);
  ComPtr<ID3D11SamplerState> sampler;
  const auto sampler_desc = CD3D11_SAMPLER_DESC(D3D11_DEFAULT);
  assert(SUCCEEDED(device->CreateSamplerState(&sampler_desc, &sampler)));
  auto* raw_sampler = sampler.Get();
  context->PSSetSamplers(0, 1, &raw_sampler);
  context->PSSetSamplers(12, 1, &raw_sampler);
  context->PSSetSamplers(13, 1, &raw_sampler);
  for (UINT slot = 0; slot < 16; ++slot) context->PSSetSamplers(slot, 1, &raw_sampler);

  // An owned fake renderer models only the audited allocation registry. No game
  // hooks are installed and no executable addresses are accessed by this test.
  alignas(16) std::array<uint8_t, 0x80> renderer = {}, allocation = {};
  std::array<uint8_t, 0xc0> registry = {};
  uintptr_t registry_pointer = reinterpret_cast<uintptr_t>(registry.data());
  uintptr_t allocation_pointer = reinterpret_cast<uintptr_t>(allocation.data());
  *reinterpret_cast<uintptr_t*>(registry.data() + 0xb8) = reinterpret_cast<uintptr_t>(renderer.data());
  *reinterpret_cast<uintptr_t*>(renderer.data() + 0x58) = reinterpret_cast<uintptr_t>(&allocation_pointer);
  *reinterpret_cast<uint32_t*>(renderer.data() + 0x60) = 1;
  *reinterpret_cast<uint32_t*>(allocation.data() + 0x1c) = 1;
  *reinterpret_cast<float*>(allocation.data() + 0x20) = 1;
  *reinterpret_cast<uintptr_t*>(allocation.data() + 0x38) = 1234;
  InitializeCriticalSection(reinterpret_cast<CRITICAL_SECTION*>(renderer.data() + 0x30));
  object_engine::state->installed = true;
  object_engine::state->registry_address = reinterpret_cast<uintptr_t>(&registry_pointer);
  ObjectMotion motion;
  motion.Configure(depth.Get(), 64, 64);
  const D3D11_VIEWPORT small_viewport{0, 0, 32, 32, 0, 1};
  context->RSSetViewports(1, &small_viewport);
  assert(!motion.Begin(context.Get(), 0, true));
  {
    // Reduced primary viewport in Classic's retained full-size resource pool.
    // Motion MRTs must match the depth allocation, while the draw guard must
    // match the smaller active viewport. No resize/readback belongs in Begin.
    ObjectMotion reduced;
    reduced.Configure(depth.Get(), 64, 64, 32, 32);
    assert(reduced.Begin(context.Get(), 0, true));
    reduced.End(context.Get());
    ComPtr<ID3D11Resource> resource;
    ComPtr<ID3D11Texture2D> texture;
    reduced.surfaces[0]->GetResource(&resource);
    assert(SUCCEEDED(resource.As(&texture)));
    D3D11_TEXTURE2D_DESC desc;
    texture->GetDesc(&desc);
    assert(desc.Width == 64 && desc.Height == 64);
    reduced.Finish(context.Get(), 0);
  }
  context->RSSetViewports(1, &viewport);
  object_engine::state->history.Record(0, allocation_pointer, {1, 0, 0, .2f, 0, 1, 0, 0, 0, 0, 1, 0});
  assert(motion.Begin(context.Get(), 0, true));
  motion.End(context.Get());
  motion.Finish(context.Get(), 0);
  // Actual Classic captures use BUFFEREX (flags zero) for this structured SRV.
  // Keep the first history frame above on BUFFER, then run all native/extended
  // shader comparisons with the game's BUFFEREX descriptor.
  D3D11_SHADER_RESOURCE_VIEW_DESC classic_bones = {};
  classic_bones.ViewDimension = D3D11_SRV_DIMENSION_BUFFEREX;
  classic_bones.BufferEx.NumElements = sizeof(bones) / 64;
  bone_srv.Reset();
  assert(SUCCEEDED(device->CreateShaderResourceView(bone_buffer.Get(), &classic_bones, &bone_srv)));
  srv = bone_srv.Get();
  context->VSSetShaderResources(0, 1, &srv);
  // Repack the same object from palette 1 to 2 and change pose/root/camera.
  *reinterpret_cast<float*>(allocation.data() + 0x20) = 2;
  *reinterpret_cast<uintptr_t*>(allocation.data() + 0x38) = 4321;  // Native animation rotates its pose storage.
  instance[3] = 0;
  instance[16] = 2;
  view[3] = 0;
  context->UpdateSubresource(instances.Get(), 0, nullptr, instance, 0, 0);
  context->UpdateSubresource(view_buffer.Get(), 0, nullptr, view.data(), 0, 0);

  const D3D11_INPUT_ELEMENT_DESC layout[] = {
      {"POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0},
      {"BLENDINDICES", 0, DXGI_FORMAT_R32G32B32A32_UINT, 0, 12},
      {"BLENDWEIGHT", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 28},
      {"TEXCOORD", 0, DXGI_FORMAT_R32G32_FLOAT, 0, 44},
      {"NORMAL", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 52},
      {"TANGENT", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 64},
      {"COLOR", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 44},
      {"TEXCOORD", 1, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 44},
      {"TEXCOORD", 2, DXGI_FORMAT_R32G32_FLOAT, 0, 44},
      {"INSTANCE_TRANSFORM", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 7, 0, D3D11_INPUT_PER_INSTANCE_DATA, 1},
      {"INSTANCE_TRANSFORM", 1, DXGI_FORMAT_R32G32B32A32_FLOAT, 7, 16, D3D11_INPUT_PER_INSTANCE_DATA, 1},
      {"INSTANCE_TRANSFORM", 2, DXGI_FORMAT_R32G32B32A32_FLOAT, 7, 32, D3D11_INPUT_PER_INSTANCE_DATA, 1},
      {"INSTANCE_LOD_PARAMS", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 7, 48, D3D11_INPUT_PER_INSTANCE_DATA, 1},
      {"INSTANCE_SKINNING_DATA", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 7, 64, D3D11_INPUT_PER_INSTANCE_DATA, 1},
  };
  WorldTransform rigid_current;
  std::copy_n(instance, 12, rigid_current.begin());
  auto rigid_previous = rigid_current;
  rigid_previous[3] = .2f;
  object_engine::batch = {instance, 1, 64};
  assert(!motion.Begin(context.Get(), 1, false, false, true));  // No moving history: keep camera vectors.
  // Actual native type 1 includes static meshes with no skinning allocation.
  alignas(16) std::array<uint8_t, 0x188> rigid_object = {};
  std::array<uintptr_t, 24> rigid_context = {};
  *reinterpret_cast<uint32_t*>(rigid_object.data() + 0x10) = 1;
  rigid_context[1] = 999;
  rigid_context[3] = reinterpret_cast<uintptr_t>(rigid_object.data());
  auto* native_world = reinterpret_cast<float*>(rigid_object.data() + 0x40);
  native_world[0] = native_world[5] = native_world[10] = native_world[15] = 1;
  native_world[12] = .2f;
  object_engine::instance_function = [](uint32_t, uintptr_t context) {
    assert(object_engine::direct_object == *reinterpret_cast<const uintptr_t*>(context + 0x18));
  };
  object_engine::state->enabled.store(true);
  object_engine::state->frame.store(0);
  object_engine::InstanceHook(0, reinterpret_cast<uintptr_t>(rigid_context.data()));
  assert(!object_engine::direct_object);
  native_world[12] = 0;
  object_engine::state->frame.store(1);
  object_engine::InstanceHook(0, reinterpret_cast<uintptr_t>(rigid_context.data()));
  assert(object_engine::state->rigid_history.Previous(1, reinterpret_cast<uintptr_t>(rigid_object.data()), 999, rigid_current).valid);
  const std::array<ObjectPose, 1> rigid_poses = {{{rigid_previous, 0, 0, 1, 0}}};
  object_engine::batch.previous = rigid_poses;
  float last_motion = 0;
  for (const auto& vertex : OBJECT_VERTEX_SHADERS)
    for (const auto& pixel : OBJECT_PIXEL_SHADERS) {
      if (vertex.signature != pixel.signature) continue;
      if (vertex.foliage || vertex.deformed || (vertex.forward && (vertex.direct || vertex.signature != 11))) continue;  // Other split-stream paths are exercised below; foliage has its own GPU fixture.
      if (hair_clip_only) continue;
      if (forward_only && !(vertex.forward || pixel.forward)) continue;
      context->OMSetRenderTargets(vertex.forward || pixel.forward ? 1 : 3, render_targets, depth_view.Get());
      srv = pixel.hash == 0xF8635C4B ? texture_array.Get() : texture_view.Get();
      context->PSSetShaderResources(3, 1, &srv);
      stride = vertex.rigid ? 64 : 80;
      vb = instances.Get();
      context->IASetVertexBuffers(7, 1, &vb, &stride, &offset);
      const auto vs_name = std::format("0x{:08X}", vertex.hash), ps_name = std::format("0x{:08X}", pixel.hash);
      const char* vs_hash = vs_name.c_str();
      const char* ps_hash = ps_name.c_str();
      ComPtr<ID3D11VertexShader> native_vs, extended_vs;
      ComPtr<ID3D11PixelShader> native_ps, extended_ps;
      const auto native_v = Read(originals / (std::string(vs_hash) + ".cso"));
      const auto extended_v = Read(shaders / (std::string(vs_hash) + ".cso"));
      const auto native_p = Read(originals / (std::string(ps_hash) + ".cso"));
      const auto extended_p = Read(shaders / (std::string(ps_hash) + ".cso"));
      BindMaterialInputs(context.Get(), native_p, material_view.Get(), texture_array.Get(), cube_view.Get(), cubes_view.Get());
      assert(SUCCEEDED(device->CreateVertexShader(native_v.data(), native_v.size(), nullptr, &native_vs)));
      assert(SUCCEEDED(device->CreateVertexShader(extended_v.data(), extended_v.size(), nullptr, &extended_vs)));
      assert(SUCCEEDED(device->CreatePixelShader(native_p.data(), native_p.size(), nullptr, &native_ps)));
      assert(SUCCEEDED(device->CreatePixelShader(extended_p.data(), extended_p.size(), nullptr, &extended_ps)));
      ComPtr<ID3D11InputLayout> input_layout;
      const auto layout_result = device->CreateInputLayout(layout, UINT(std::size(layout)), native_v.data(), native_v.size(), &input_layout);
      if (FAILED(layout_result)) std::cerr << vs_hash << " input layout HRESULT=" << std::hex << layout_result << std::dec << '\n';
      assert(SUCCEEDED(layout_result));
      context->IASetInputLayout(input_layout.Get());
      context->VSSetShader(native_vs.Get(), nullptr, 0);
      context->PSSetShader(native_ps.Get(), nullptr, 0);
      const float background[] = {.03125f, .0625f, .125f, .25f};
      for (auto& target : targets) context->ClearRenderTargetView(target.Get(), background);
      context->DrawInstanced(3, 1, 0, 0);
      std::array<std::array<float, 4>, 3> reference;
      for (size_t i = 0; i < 3; ++i) reference[i] = Pixel(context.Get(), colors[i].Get());
      if (vertex.hash == 0x465BBC10) {
        object_engine::batch = {};
        object_engine::direct_object = reinterpret_cast<uintptr_t>(rigid_object.data());
        object_engine::direct_mesh = 999;
      }
      assert(motion.Begin(context.Get(), 1, vertex.reference, false, vertex.rigid, vertex.forward || pixel.forward));
      // Check native alpha/LOD coverage as well as RGB. A discarded material
      // must leave the extra MRTs untouched, rather than inheriting a result
      // from the preceding material variant in this fixture.
      for (auto& target : targets) context->ClearRenderTargetView(target.Get(), background);
      for (auto& surface : motion.surfaces) {
        ComPtr<ID3D11Resource> resource;
        ComPtr<ID3D11RenderTargetView> target;
        surface->GetResource(&resource);
        assert(SUCCEEDED(device->CreateRenderTargetView(resource.Get(), nullptr, &target)));
        const float missing[] = {-2, -2, -2, -2};
        context->ClearRenderTargetView(target.Get(), missing);
      }
      context->VSSetShader(extended_vs.Get(), nullptr, 0);
      context->PSSetShader(extended_ps.Get(), nullptr, 0);
      context->DrawInstanced(3, 1, 0, 0);
      motion.End(context.Get());
      object_engine::direct_object = 0;
      object_engine::batch = {instance, 1, 64, rigid_poses};
      for (size_t i = 0; i < 3; ++i) {
        const auto result = Pixel(context.Get(), colors[i].Get());
        for (size_t c = 0; c < 4; ++c) {
          if (!SameColor(reference[i][c], result[c]))
            std::cerr << vs_hash << ' ' << ps_hash << " target=" << i << " channel=" << c << " native=" << reference[i][c] << " extended=" << result[c] << '\n';
          assert(SameColor(reference[i][c], result[c]));
          matched_nonfinite_colors += !std::isfinite(reference[i][c]);
        }
      }
      ComPtr<ID3D11Resource> vectors, surface_depth;
      motion.surfaces[0]->GetResource(&vectors);
      motion.surfaces[1]->GetResource(&surface_depth);
      const auto velocity = Pixel(context.Get(), vectors.Get());
      last_motion = vertex.rigid ? .125f : .175f;
      const bool covered = !std::equal(reference[0].begin(), reference[0].end(), background);
      if (covered) {
        if (std::abs(velocity[0] - last_motion) >= .001f || std::abs(velocity[1]) >= .001f)
          std::cerr << vs_hash << " / " << ps_hash << " motion=" << velocity[0] << "," << velocity[1] << " expected=" << last_motion << " depth=" << Pixel(context.Get(), surface_depth.Get())[0] << '\n';
        assert(std::abs(velocity[0] - last_motion) < .001f && std::abs(velocity[1]) < .001f);
        assert(std::abs(Pixel(context.Get(), surface_depth.Get())[0] - (vertex.reference ? .75f : .5f)) < 1e-6f);
      } else {
        assert(Pixel(context.Get(), surface_depth.Get())[0] == -2.f);
      }
      ComPtr<ID3D11RenderTargetView> extra_target;
      std::array<ID3D11RenderTargetView*, 5> restored = {};
      context->OMGetRenderTargets(5, restored.data(), nullptr);
      assert(!restored[3] && !restored[4]);
      for (auto* target : restored)
        if (target) target->Release();
      std::cout << "PASS " << vs_hash << " / " << ps_hash << " native RGB, repacked bones, root/camera motion and MRT restore\n";
    }
  // The last pair may now be forward; following history tests use G-buffer MRTs.
  context->OMSetRenderTargets(3, render_targets, depth_view.Get());
  if (forward_only) {
    ComPtr<ID3D11InfoQueue> info;
    if (SUCCEEDED(device.As(&info)))
      for (UINT64 index = 0; index < info->GetNumStoredMessages(); ++index) {
        SIZE_T size = 0;
        info->GetMessage(index, nullptr, &size);
        std::vector<uint8_t> bytes(size);
        auto* message = reinterpret_cast<D3D11_MESSAGE*>(bytes.data());
        assert(SUCCEEDED(info->GetMessage(index, message, &size)));
        if (message->Severity <= D3D11_MESSAGE_SEVERITY_ERROR) {
          std::cerr << message->pDescription << '\n';
          assert(false);
        }
      }
    DeleteCriticalSection(reinterpret_cast<CRITICAL_SECTION*>(renderer.data() + 0x30));
    return 0;
  }
  {
    // The rotating mill and attached rigid props use an 80-byte skin instance
    // with palette/stride zero. They must use object transform history.
    instance[16] = instance[17] = 0;
    context->UpdateSubresource(instances.Get(), 0, nullptr, instance, 0, 0);
    object_engine::batch = {instance, 1, 80, rigid_poses};
    stride = 80; vb = instances.Get();
    context->IASetVertexBuffers(7, 1, &vb, &stride, &offset);
    const auto original_vs = Read(originals / "0xF507139A.cso"), extended_vs = Read(shaders / "0xF507139A.cso");
    const auto original_ps = Read(originals / "0x280BDA85.cso"), extended_ps = Read(shaders / "0x280BDA85.cso");
    ComPtr<ID3D11VertexShader> native_vertex, motion_vertex;
    ComPtr<ID3D11PixelShader> native_pixel, motion_pixel;
    ComPtr<ID3D11InputLayout> input;
    assert(SUCCEEDED(device->CreateVertexShader(original_vs.data(), original_vs.size(), nullptr, &native_vertex)));
    assert(SUCCEEDED(device->CreateVertexShader(extended_vs.data(), extended_vs.size(), nullptr, &motion_vertex)));
    assert(SUCCEEDED(device->CreatePixelShader(original_ps.data(), original_ps.size(), nullptr, &native_pixel)));
    assert(SUCCEEDED(device->CreatePixelShader(extended_ps.data(), extended_ps.size(), nullptr, &motion_pixel)));
    assert(SUCCEEDED(device->CreateInputLayout(layout, UINT(std::size(layout)), original_vs.data(), original_vs.size(), &input)));
    context->IASetInputLayout(input.Get());
    context->VSSetShader(native_vertex.Get(), nullptr, 0); context->PSSetShader(native_pixel.Get(), nullptr, 0);
    context->DrawInstanced(3, 1, 0, 0);
    const auto native_color = Pixel(context.Get(), colors[0].Get());
    assert(motion.Begin(context.Get(), 1));
    context->VSSetShader(motion_vertex.Get(), nullptr, 0); context->PSSetShader(motion_pixel.Get(), nullptr, 0);
    context->DrawInstanced(3, 1, 0, 0);
    motion.End(context.Get());
    const auto actual_color = Pixel(context.Get(), colors[0].Get());
    for (UINT i = 0; i < 4; ++i) assert(std::isfinite(actual_color[i]) && std::abs(actual_color[i] - native_color[i]) < .002f);
    ComPtr<ID3D11Resource> vectors, surface;
    motion.surfaces[0]->GetResource(&vectors); motion.surfaces[1]->GetResource(&surface);
    assert(std::abs(Pixel(context.Get(), vectors.Get())[0] - .125f) < .001f);
    last_motion = .125f;
    assert(Pixel(context.Get(), surface.Get())[0] > 0);
    object_engine::object_free_function = [](uintptr_t) {};
    object_engine::ObjectFreeHook(reinterpret_cast<uintptr_t>(rigid_object.data()));
    assert(!object_engine::state->rigid_history.Previous(1, reinterpret_cast<uintptr_t>(rigid_object.data()), 999, rigid_current).valid);
    std::vector<BoneAllocation> active;
    *reinterpret_cast<float*>(allocation.data() + 0x20) = 0;
    assert(object_engine::Allocations(4, &active) && active.empty());
    *reinterpret_cast<float*>(allocation.data() + 0x20) = 2;
    instance[16] = 2; instance[17] = 1;
    context->UpdateSubresource(instances.Get(), 0, nullptr, instance, 0, 0);
    std::cout << "PASS identity-palette mill/attachments: native RGB, rigid motion, destructor and inactive allocation isolation\n";
  }
  Prepare prepare;
  assert(prepare.Initialize(device.Get(), Read(shaders / "0xF3C10001.cso"), Read(shaders / "0xF3C10002.cso"), Read(shaders / "0xF3C10003.cso"), Read(shaders / "0xF3C10004.cso")));
  std::array<float, 180 * 4> camera = {};
  for (UINT i = 0; i < 4; ++i) camera[(78 + i) * 4 + i] = 1;
  auto camera_buffer = Buffer(device.Get(), camera.data(), sizeof(camera), D3D11_BIND_CONSTANT_BUFFER);
  ComPtr<ID3D11ShaderResourceView> scene_srv, depth_srv;
  assert(SUCCEEDED(device->CreateShaderResourceView(colors[0].Get(), nullptr, &scene_srv)));
  D3D11_SHADER_RESOURCE_VIEW_DESC depth_srv_desc{};
  depth_srv_desc.Format = DXGI_FORMAT_R24_UNORM_X8_TYPELESS;
  depth_srv_desc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
  depth_srv_desc.Texture2D.MipLevels = 1;
  assert(SUCCEEDED(device->CreateShaderResourceView(depth.Get(), &depth_srv_desc, &depth_srv)));
  ComPtr<ID3D11Resource> object_depth;
  motion.surfaces[1]->GetResource(&object_depth);
  const float stored_depth = Pixel(context.Get(), object_depth.Get())[0];
  for (float hardware_depth : {stored_depth, stored_depth + .1f}) {
    context->ClearDepthStencilView(depth_view.Get(), D3D11_CLEAR_DEPTH, hardware_depth, 0);
    assert(prepare.Run(context.Get(), scene_srv.Get(), depth_srv.Get(), motion.surfaces[0].Get(), camera_buffer.Get(), frame_buffer.Get(), 64, 64, motion.surfaces[1].Get()));
    const auto vectors = Pixel(context.Get(), prepare.textures[2].Get());
    assert(std::abs(vectors[0] - (hardware_depth == stored_depth ? last_motion : 0.f)) < .001f);
    assert(Pixel(context.Get(), prepare.textures[3].Get())[0] == 0.f);
  }
  ComPtr<ID3D11RenderTargetView> object_depth_target;
  motion.surfaces[1]->GetResource(&object_depth);
  assert(SUCCEEDED(device->CreateRenderTargetView(object_depth.Get(), nullptr, &object_depth_target)));
  const float unavailable[] = {-stored_depth, 0, 0, 0};
  context->ClearRenderTargetView(object_depth_target.Get(), unavailable);
  context->ClearDepthStencilView(depth_view.Get(), D3D11_CLEAR_DEPTH, stored_depth, 0);
  assert(prepare.Run(context.Get(), scene_srv.Get(), depth_srv.Get(), motion.surfaces[0].Get(), camera_buffer.Get(), frame_buffer.Get(), 64, 64, motion.surfaces[1].Get()));
  assert(Pixel(context.Get(), prepare.textures[2].Get())[0] == 0.f);
  assert(Pixel(context.Get(), prepare.textures[3].Get())[0] == 1.f);
  assert(prepare.Blit(context.Get(), motion.surfaces[0].Get(), targets[0].Get(), 64, 64, motion.surfaces[1].Get()));
  assert(std::abs(Pixel(context.Get(), colors[0].Get())[1] - .35f) < .001f);
  const float available[] = {stored_depth, 0, 0, 0};
  context->ClearRenderTargetView(object_depth_target.Get(), available);
  assert(prepare.Blit(context.Get(), motion.surfaces[0].Get(), targets[0].Get(), 64, 64, motion.surfaces[1].Get()));
  assert(std::abs(Pixel(context.Get(), colors[0].Get())[1] - .18f) < .001f);
  // Missing coverage still shows a diagnostic image instead of normal DLAA.
  assert(prepare.Blit(context.Get(), scene_srv.Get(), targets[1].Get(), 64, 64, nullptr, true));
  assert(std::abs(Pixel(context.Get(), colors[1].Get())[1] - .02f) < .001f);
  std::cout << "PASS object/camera merge, opaque occlusion and unavailable-history responsive mask\n";
  {
    ObjectMotion faces;
    faces.Configure(depth.Get(), 64, 64);
    object_engine::deformed_owner = 123;
    const uint32_t face_indices[] = {0, 1, 2};
    auto index_buffer = Buffer(device.Get(), face_indices, sizeof(face_indices), D3D11_BIND_INDEX_BUFFER);
    context->IASetIndexBuffer(index_buffer.Get(), DXGI_FORMAT_R32_UINT, 0);
    const float uv_data[] = {.5f, .5f, .5f, .5f, .5f, .5f};
    auto face_uv = Buffer(device.Get(), uv_data, sizeof(uv_data), D3D11_BIND_VERTEX_BUFFER);
    struct FaceVertex {
      float position[3], normal[3], tangent[4];
    };
    static_assert(sizeof(FaceVertex) == 40);
    std::array<FaceVertex, 3> face_data;
    for (size_t i = 0; i < 3; ++i) {
      std::copy_n(vertices[i].position, 3, face_data[i].position);
      face_data[i].position[0] += .1f;
      std::copy_n(vertices[i].normal, 3, face_data[i].normal);
      std::copy_n(vertices[i].tangent, 4, face_data[i].tangent);
    }
    auto face_a = Buffer(device.Get(), face_data.data(), sizeof(face_data), D3D11_BIND_VERTEX_BUFFER);
    for (auto& vertex : face_data) vertex.position[0] -= .1f;
    auto face_b = Buffer(device.Get(), face_data.data(), sizeof(face_data), D3D11_BIND_VERTEX_BUFFER);
    std::array<float, 32> face_world = {};
    face_world[0] = face_world[5] = face_world[10] = 1;
    face_world[3] = .2f;
    auto face_world_buffer = Buffer(device.Get(), face_world.data(), sizeof(face_world), D3D11_BIND_CONSTANT_BUFFER);
    auto* world_cb = face_world_buffer.Get();
    context->VSSetConstantBuffers(2, 1, &world_cb);
    view[3] = .05f;
    context->UpdateSubresource(view_buffer.Get(), 0, nullptr, view.data(), 0, 0);
    const UINT face_strides[] = {8, 40}, face_offsets[] = {0, 0};
    ID3D11Buffer* streams[] = {face_uv.Get(), face_a.Get()};
    context->IASetVertexBuffers(0, 2, streams, face_strides, face_offsets);
    context->OMSetRenderTargets(3, render_targets, depth_view.Get());
    assert(faces.Begin(context.Get(), 10, false, true));
    faces.End(context.Get());
    faces.Finish(context.Get(), 10);
    streams[1] = face_b.Get();
    context->IASetVertexBuffers(0, 2, streams, face_strides, face_offsets);
    auto index_b = Buffer(device.Get(), face_indices, sizeof(face_indices), D3D11_BIND_INDEX_BUFFER);
    context->IASetIndexBuffer(index_b.Get(), DXGI_FORMAT_R32_UINT, 0);
    face_world[3] = view[3] = 0;
    context->UpdateSubresource(face_world_buffer.Get(), 0, nullptr, face_world.data(), 0, 0);
    context->UpdateSubresource(view_buffer.Get(), 0, nullptr, view.data(), 0, 0);
    const D3D11_INPUT_ELEMENT_DESC face_layout[] = {
        {"POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 1, 0},
        {"NORMAL", 0, DXGI_FORMAT_R32G32B32_FLOAT, 1, 12},
        {"TANGENT", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 1, 24},
        {"TEXCOORD", 0, DXGI_FORMAT_R32G32_FLOAT, 0, 0},
    };
    ComPtr<ID3D11ShaderResourceView> array_view;
    D3D11_SHADER_RESOURCE_VIEW_DESC array_desc{};
    array_desc.Format = tex_desc.Format;
    array_desc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2DARRAY;
    array_desc.Texture2DArray.MipLevels = array_desc.Texture2DArray.ArraySize = 1;
    assert(SUCCEEDED(device->CreateShaderResourceView(texture.Get(), &array_desc, &array_view)));
    // Apex tail hair uses forward lighting with the same split deformation
    // streams. Supply its native resources and test the one-target contract.
    std::array<float, 16384> tail_lights = {};
    auto tail_light_cb = Buffer(device.Get(), tail_lights.data(), sizeof(tail_lights), D3D11_BIND_CONSTANT_BUFFER);
    cb = tail_light_cb.Get(); context->VSSetConstantBuffers(13, 1, &cb);
    srv = forward_raw_srv.Get(); context->VSSetShaderResources(21, 1, &srv);
    srv = texture_array.Get();
    for (UINT slot : {8u, 14u, 19u}) context->VSSetShaderResources(slot, 1, &srv);
    srv = texture_view.Get();
    for (UINT slot : {22u, 23u, 24u}) context->VSSetShaderResources(slot, 1, &srv);
    for (UINT slot = 0; slot < 16; ++slot) context->VSSetSamplers(slot, 1, &raw_sampler);
    for (const auto& vertex : OBJECT_VERTEX_SHADERS)
      for (const auto& pixel : OBJECT_PIXEL_SHADERS) {
        if (!vertex.deformed || vertex.signature != pixel.signature) continue;
        const UINT target_count = vertex.forward || pixel.forward ? 1u : 3u;
        context->OMSetRenderTargets(target_count, render_targets, depth_view.Get());
        srv = pixel.hash == 0xF8635C4B ? texture_array.Get() : texture_view.Get();
        context->PSSetShaderResources(3, 1, &srv);
        srv = pixel.hash == 0xED00FAF7 ? array_view.Get() : texture_view.Get();
        context->PSSetShaderResources(0, 1, &srv);
        const auto original_vs = Read(originals / std::format("0x{:08X}.cso", vertex.hash)), replacement_vs = Read(shaders / std::format("0x{:08X}.cso", vertex.hash));
        const auto original_ps = Read(originals / std::format("0x{:08X}.cso", pixel.hash));
        BindMaterialInputs(context.Get(), original_ps, material_view.Get(), texture_array.Get(), cube_view.Get(), cubes_view.Get());
        ComPtr<ID3D11VertexShader> original_vertex, replacement_vertex;
        ComPtr<ID3D11PixelShader> original_pixel, replacement_pixel;
        ComPtr<ID3D11InputLayout> face_input;
        assert(SUCCEEDED(device->CreateVertexShader(original_vs.data(), original_vs.size(), nullptr, &original_vertex)));
        assert(SUCCEEDED(device->CreateVertexShader(replacement_vs.data(), replacement_vs.size(), nullptr, &replacement_vertex)));
        assert(SUCCEEDED(device->CreatePixelShader(original_ps.data(), original_ps.size(), nullptr, &original_pixel)));
        assert(SUCCEEDED(device->CreatePixelShader(pixel.code.data(), pixel.code.size(), nullptr, &replacement_pixel)));
        assert(SUCCEEDED(device->CreateInputLayout(face_layout, UINT(std::size(face_layout)), original_vs.data(), original_vs.size(), &face_input)));
        context->IASetInputLayout(face_input.Get());
        context->VSSetShader(original_vertex.Get(), nullptr, 0);
        context->PSSetShader(original_pixel.Get(), nullptr, 0);
        context->DrawIndexed(3, 0, 0);
        std::array<std::array<float, 4>, 3> native_colors;
        for (size_t i = 0; i < target_count; ++i) native_colors[i] = Pixel(context.Get(), colors[i].Get());
        assert(faces.Begin(context.Get(), 11, false, true, false, target_count == 1));
        context->VSSetShader(replacement_vertex.Get(), nullptr, 0);
        context->PSSetShader(replacement_pixel.Get(), nullptr, 0);
        context->DrawIndexed(3, 0, 0);
        faces.End(context.Get());
        for (size_t i = 0; i < target_count; ++i) {
          const auto actual = Pixel(context.Get(), colors[i].Get());
          for (size_t c = 0; c < 4; ++c) {
            assert(SameColor(native_colors[i][c], actual[c]));
            matched_nonfinite_colors += !std::isfinite(native_colors[i][c]);
          }
        }
        ComPtr<ID3D11Resource> face_motion, face_depth;
        faces.surfaces[0]->GetResource(&face_motion);
        faces.surfaces[1]->GetResource(&face_depth);
        assert(std::abs(Pixel(context.Get(), face_motion.Get())[0] - .175f) < .001f);
        assert(Pixel(context.Get(), face_depth.Get())[0] > 0);
        if (vertex.forward) {
          // Native hair rejects alpha below .33. Rejected strands must leave
          // both scene color and motion untouched, rather than fill the card.
          const float transparent_texel[] = {.6f, .65f, .8f, .2f};
          const D3D11_SUBRESOURCE_DATA transparent_initial{transparent_texel, sizeof(transparent_texel)};
          ComPtr<ID3D11Texture2D> transparent_texture;
          ComPtr<ID3D11ShaderResourceView> transparent_view;
          assert(SUCCEEDED(device->CreateTexture2D(&tex_desc, &transparent_initial, &transparent_texture)));
          assert(SUCCEEDED(device->CreateShaderResourceView(transparent_texture.Get(), nullptr, &transparent_view)));
          srv = transparent_view.Get(); context->PSSetShaderResources(0, 1, &srv);
          ComPtr<ID3D11RenderTargetView> tail_depth;
          assert(SUCCEEDED(device->CreateRenderTargetView(face_depth.Get(), nullptr, &tail_depth)));
          const float untouched[] = {-2.f, 0, 0, 0};
          context->ClearRenderTargetView(tail_depth.Get(), untouched);
          context->ClearRenderTargetView(targets[0].Get(), untouched);
          context->VSSetShader(original_vertex.Get(), nullptr, 0);
          context->PSSetShader(original_pixel.Get(), nullptr, 0);
          context->DrawIndexed(3, 0, 0);
          assert(Pixel(context.Get(), colors[0].Get())[0] == -2.f);
          assert(faces.Begin(context.Get(), 11, false, true, false, true));
          context->VSSetShader(replacement_vertex.Get(), nullptr, 0);
          context->PSSetShader(replacement_pixel.Get(), nullptr, 0);
          context->DrawIndexed(3, 0, 0);
          faces.End(context.Get());
          assert(Pixel(context.Get(), colors[0].Get())[0] == -2.f);
          assert(Pixel(context.Get(), face_depth.Get())[0] == -2.f);
          srv = material_view.Get(); context->PSSetShaderResources(0, 1, &srv);
          std::vector<D3D11_SO_DECLARATION_ENTRY> outputs;
          for (UINT i = 0; i < 8; ++i) outputs.push_back({0, "TEXCOORD", i, 0, 4, 0});
          outputs.push_back({0, "SV_POSITION", 0, 0, 4, 0});
          outputs.push_back({0, "TEXCOORD", 10, 0, 4, 0});
          outputs.push_back({0, "TEXCOORD", 11, 0, 1, 0});
          const auto saved_view = view;
          const auto saved_world = face_world;
          UINT unequal_clip = 0;
          for (UINT sample = 0; sample < 8; ++sample) {
            for (UINT i = 0; i < 16; ++i) view[i] = std::sin(float(i * 17 + sample * 11 + 1)) * 1.731f;
            for (UINT i = 0; i < 12; ++i) face_world[i] = std::cos(float(i * 7 + sample * 13 + 2)) * 2.193f;
            context->UpdateSubresource(view_buffer.Get(), 0, nullptr, view.data(), 0, 0);
            context->UpdateSubresource(face_world_buffer.Get(), 0, nullptr, face_world.data(), 0, 0);
            const auto native = VertexOutputs(device.Get(), context.Get(), original_vs, std::span(outputs).first(9));
            assert(faces.Begin(context.Get(), 11, false, true, false, true));
            const auto extended = VertexOutputs(device.Get(), context.Get(), replacement_vs, outputs);
            faces.End(context.Get());
            for (UINT v = 0; v < 3; ++v) {
              for (UINT c = 0; c < 36; ++c) assert(SameColor(native[v * 36 + c], extended[v * 41 + c]));
              for (UINT c = 32; c < 36; ++c)
                unequal_clip += std::bit_cast<uint32_t>(native[v * 36 + c]) != std::bit_cast<uint32_t>(extended[v * 41 + c]);
              assert(std::abs(extended[v * 41 + 36] - (face_data[v].position[0] + .35f)) < 2e-5f);
              assert(extended[v * 41 + 40] == 1.f);
            }
          }
          view = saved_view;
          face_world = saved_world;
          context->UpdateSubresource(view_buffer.Get(), 0, nullptr, view.data(), 0, 0);
          context->UpdateSubresource(face_world_buffer.Get(), 0, nullptr, face_world.data(), 0, 0);
          std::cerr << std::format("Deformed tail clip invariance 0x{:08X}: {} / 96 components differ\n", vertex.hash, unequal_clip);
          assert(unequal_clip == 0);
          std::array<ID3D11RenderTargetView*, 5> restored = {};
          context->OMGetRenderTargets(5, restored.data(), nullptr);
          assert(restored[0] == targets[0].Get());
          for (UINT i = 1; i < 5; ++i) assert(!restored[i]);
          restored[0]->Release();
        }
      }
    context->OMSetRenderTargets(3, render_targets, depth_view.Get());
    faces.Finish(context.Get(), 11);
    // The hanging cloth uses three position AND index buffers. A ring-buffer
    // address is not mesh identity; each frame must retain the immediately
    // preceding vertex positions under the same owner and UV stream.
    for (auto& vertex : face_data) vertex.position[0] += .2f;
    auto face_c = Buffer(device.Get(), face_data.data(), sizeof(face_data), D3D11_BIND_VERTEX_BUFFER);
    auto index_c = Buffer(device.Get(), face_indices, sizeof(face_indices), D3D11_BIND_INDEX_BUFFER);
    const auto cloth_vs = Read(shaders / "0x8AF8354B.cso"), cloth_ps = Read(shaders / "0x628E4EBD.cso");
    ComPtr<ID3D11VertexShader> cloth_vertex;
    ComPtr<ID3D11PixelShader> cloth_pixel;
    ComPtr<ID3D11InputLayout> cloth_input;
    assert(SUCCEEDED(device->CreateVertexShader(cloth_vs.data(), cloth_vs.size(), nullptr, &cloth_vertex)));
    assert(SUCCEEDED(device->CreatePixelShader(cloth_ps.data(), cloth_ps.size(), nullptr, &cloth_pixel)));
    assert(SUCCEEDED(device->CreateInputLayout(face_layout, UINT(std::size(face_layout)), cloth_vs.data(), cloth_vs.size(), &cloth_input)));
    context->IASetInputLayout(cloth_input.Get());
    context->VSSetShader(cloth_vertex.Get(), nullptr, 0);
    context->PSSetShader(cloth_pixel.Get(), nullptr, 0);
    srv = texture_view.Get(); context->PSSetShaderResources(0, 1, &srv);
    context->PSSetShaderResources(3, 1, &srv);
    ID3D11Buffer* position_ring[] = {face_c.Get(), face_a.Get(), face_b.Get()};
    ID3D11Buffer* index_ring[] = {index_c.Get(), index_buffer.Get(), index_b.Get()};
    const float expected[] = {-.1f, .05f, .05f};
    for (uint32_t ring = 0; ring < 3; ++ring) {
      streams[1] = position_ring[ring];
      context->IASetVertexBuffers(0, 2, streams, face_strides, face_offsets);
      context->IASetIndexBuffer(index_ring[ring], DXGI_FORMAT_R32_UINT, 0);
      assert(faces.Begin(context.Get(), 12 + ring, false, true));
      context->DrawIndexed(3, 0, 0);
      faces.End(context.Get());
      ComPtr<ID3D11Resource> vectors, surface;
      faces.surfaces[0]->GetResource(&vectors); faces.surfaces[1]->GetResource(&surface);
      assert(std::abs(Pixel(context.Get(), vectors.Get())[0] - expected[ring]) < .001f);
      assert(Pixel(context.Get(), surface.Get())[0] > 0);
      faces.Finish(context.Get(), 12 + ring);
    }
    object_engine::deformed_generation = 1;  // Native proxy destroyed/reused.
    assert(faces.Begin(context.Get(), 15, false, true));
    context->DrawIndexed(3, 0, 0);
    faces.End(context.Get());
    ComPtr<ID3D11Resource> reused_surface;
    faces.surfaces[1]->GetResource(&reused_surface);
    assert(Pixel(context.Get(), reused_surface.Get())[0] < 0);
    faces.Finish(context.Get(), 15);
    object_engine::deformed_generation = 0;
    object_engine::deformed_owner = 0;
    std::cout << "PASS CPU-deformed faces/cloth: all material pairs, three rotating position/index buffers, pose/root/camera history and owner reuse\n";
    // The transient PhysX resource passed to DeformedHook also rotates. The
    // renderer supplies the persistent game proxy, with a destruction epoch.
    std::array<uintptr_t, 8> apex_renderer = {};
    alignas(8) std::array<uint8_t, 32> apex_object = {};
    object_engine::state->image = 0x140000000;
    apex_renderer[0] = object_engine::state->image + 0x2151c00;
    apex_renderer[5] = reinterpret_cast<uintptr_t>(apex_object.data());
    *reinterpret_cast<uintptr_t*>(apex_object.data()) = object_engine::state->image + 0x2153e78;
    *reinterpret_cast<uint32_t*>(apex_object.data() + 0x10) = 9;
    static uintptr_t observed_owner;
    static uint64_t observed_generation;
    object_engine::deformed_function = [](uintptr_t, uintptr_t, uintptr_t) {
      observed_owner = object_engine::deformed_owner;
      observed_generation = object_engine::deformed_generation;
    };
    object_engine::DeformedHook(101, reinterpret_cast<uintptr_t>(apex_renderer.data()), 0);
    assert(observed_owner == reinterpret_cast<uintptr_t>(apex_object.data()) && observed_generation);
    const auto generation = observed_generation;
    object_engine::DeformedHook(102, reinterpret_cast<uintptr_t>(apex_renderer.data()), 0);
    assert(observed_generation == generation);
    object_engine::ObjectFreeHook(reinterpret_cast<uintptr_t>(apex_object.data()));
    object_engine::DeformedHook(103, reinterpret_cast<uintptr_t>(apex_renderer.data()), 0);
    assert(observed_generation != generation);
    assert(!object_engine::deformed_owner && !object_engine::deformed_generation);
    object_engine::state->image = 0;
    std::cout << "PASS Apex owner: rotating PhysX resources, stable proxy identity, destructor invalidation and scope restore\n";
  }
  for (const auto& shader : OBJECT_VERTEX_SHADERS) {
    if (!shader.forward || !shader.direct) continue;
    // The opaque forward skin path has no instance attributes: cb2 carries its
    // world transform and palette. Compare every native vertex output, then
    // verify the previous pose with a repacked palette and moving root/camera.
    context->OMSetRenderTargets(1, render_targets, depth_view.Get());
    vb = vertex_buffer.Get(); stride = sizeof(Vertex); offset = 0;
    context->IASetVertexBuffers(0, 1, &vb, &stride, &offset);
    const auto original = Read(originals / std::format("0x{:08X}.cso", shader.hash));
    const auto replacement = Read(shaders / std::format("0x{:08X}.cso", shader.hash));
    ComPtr<ID3D11InputLayout> input;
    assert(SUCCEEDED(device->CreateInputLayout(layout, 9, original.data(), original.size(), &input)));
    context->IASetInputLayout(input.Get());
    std::array<float, 32> forward_mesh = {};
    forward_mesh[0] = forward_mesh[5] = forward_mesh[10] = 1;
    forward_mesh[16] = forward_mesh[17] = forward_mesh[18] = 1;
    forward_mesh[28] = 2; forward_mesh[29] = 1;
    auto forward_cb = Buffer(device.Get(), forward_mesh.data(), sizeof(forward_mesh), D3D11_BIND_CONSTANT_BUFFER);
    cb = forward_cb.Get(); context->VSSetConstantBuffers(2, 1, &cb);
    cb = view_buffer.Get(); context->VSSetConstantBuffers(1, 1, &cb);
    cb = frame_buffer.Get(); context->VSSetConstantBuffers(12, 1, &cb);
    srv = bone_srv.Get(); context->VSSetShaderResources(0, 1, &srv);
    std::array<D3D11_SO_DECLARATION_ENTRY, 9> outputs = {{
      {0, "TEXCOORD", 0, 0, 4, 0}, {0, "TEXCOORD", 1, 0, 4, 0},
      {0, "TEXCOORD", 2, 0, 4, 0}, {0, "TEXCOORD", 3, 0, 3, 0},
      {0, "TEXCOORD", 4, 0, 3, 0}, {0, "TEXCOORD", 5, 0, 3, 0},
      {0, "SV_POSITION", 0, 0, 4, 0}, {0, "TEXCOORD", 10, 0, 4, 0}, {0, "TEXCOORD", 11, 0, 1, 0}}};
    const auto native_outputs = VertexOutputs(device.Get(), context.Get(), original, std::span(outputs).first(7));
    assert(motion.Begin(context.Get(), 1, false, false, false, true));
    const auto motion_outputs = VertexOutputs(device.Get(), context.Get(), replacement, outputs);
    motion.End(context.Get());
    for (UINT vertex = 0; vertex < 3; ++vertex) {
      for (UINT value = 0; value < 25; ++value) {
        const float expected = native_outputs[vertex * 25 + value], actual = motion_outputs[vertex * 30 + value];
        assert(std::isfinite(actual) && std::abs(expected - actual) < 2e-5f);
      }
      assert(std::abs(motion_outputs[vertex * 30 + 25] - (vertices[vertex].position[0] + .35f)) < 2e-5f);
      assert(motion_outputs[vertex * 30 + 29] == 1.f);
    }
    std::array<ID3D11RenderTargetView*, 5> restored = {};
    context->OMGetRenderTargets(5, restored.data(), nullptr);
    assert(restored[0] == targets[0].Get());
    for (UINT i = 1; i < 5; ++i) assert(restored[i] == nullptr);
    restored[0]->Release();
    std::cout << std::format("PASS direct forward skin 0x{:08X}: native vertex outputs, previous bones/root/camera, one-target restoration\n", shader.hash);
  }
  {
    vb = vertex_buffer.Get(); stride = sizeof(Vertex); offset = 0;
    context->IASetVertexBuffers(0, 1, &vb, &stride, &offset);
    vb = instances.Get(); context->IASetVertexBuffers(7, 1, &vb, &stride, &offset);
    cb = mesh_buffer.Get(); context->VSSetConstantBuffers(2, 1, &cb); context->VSSetConstantBuffers(3, 1, &cb);
    cb = view_buffer.Get(); context->VSSetConstantBuffers(1, 1, &cb);
    cb = frame_buffer.Get(); context->VSSetConstantBuffers(12, 1, &cb);
    std::array<float, 16384> lights = {};
    auto light_cb = Buffer(device.Get(), lights.data(), sizeof(lights), D3D11_BIND_CONSTANT_BUFFER);
    cb = light_cb.Get(); context->VSSetConstantBuffers(13, 1, &cb);
    std::array<uint32_t, 4096> light_indices; light_indices.fill(256);
    ComPtr<ID3D11Buffer> light_list;
    const D3D11_BUFFER_DESC raw_desc{sizeof(light_indices), D3D11_USAGE_DEFAULT, D3D11_BIND_SHADER_RESOURCE, 0, D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS};
    const D3D11_SUBRESOURCE_DATA raw_data{light_indices.data()};
    assert(SUCCEEDED(device->CreateBuffer(&raw_desc, &raw_data, &light_list)));
    D3D11_SHADER_RESOURCE_VIEW_DESC raw_view = {};
    raw_view.Format = DXGI_FORMAT_R32_TYPELESS; raw_view.ViewDimension = D3D11_SRV_DIMENSION_BUFFEREX;
    raw_view.BufferEx.NumElements = UINT(light_indices.size()); raw_view.BufferEx.Flags = D3D11_BUFFEREX_SRV_FLAG_RAW;
    ComPtr<ID3D11ShaderResourceView> raw_srv;
    assert(SUCCEEDED(device->CreateShaderResourceView(light_list.Get(), &raw_view, &raw_srv)));
    srv = raw_srv.Get(); context->VSSetShaderResources(21, 1, &srv);
    srv = bone_srv.Get(); context->VSSetShaderResources(0, 1, &srv);
    srv = texture_view.Get(); context->VSSetShaderResources(1, 1, &srv);
    UINT forward_clip_differences = 0;
    for (const auto& shader : OBJECT_VERTEX_SHADERS) {
      if (!shader.forward || shader.direct || shader.deformed) continue;
      const uint32_t hash = shader.hash;
      const auto original = Read(originals / std::format("0x{:08X}.cso", hash));
      const auto replacement = Read(shaders / std::format("0x{:08X}.cso", hash));
      std::vector<D3D11_INPUT_ELEMENT_DESC> input_layout(std::begin(layout), std::end(layout));
      ComPtr<ID3D11InputLayout> input;
      assert(SUCCEEDED(device->CreateInputLayout(input_layout.data(), UINT(input_layout.size()), original.data(), original.size(), &input)));
      context->IASetInputLayout(input.Get());
      std::vector<D3D11_SO_DECLARATION_ENTRY> outputs;
      assert(shader.signature == 11 || shader.signature == 12);
      // Decompiler float4 declarations can include unwritten W lanes. Reflect
      // the native bytecode so all actual varyings, including fog, are consumed.
      using Reflect = HRESULT(WINAPI*)(const void*, SIZE_T, REFIID, void**);
      const auto reflect = reinterpret_cast<Reflect>(GetProcAddress(GetModuleHandleW(L"d3dcompiler_47.dll"), "D3DReflect"));
      assert(reflect);
      ComPtr<ID3D11ShaderReflection> reflection;
      assert(SUCCEEDED(reflect(original.data(), original.size(), __uuidof(ID3D11ShaderReflection), &reflection)));
      D3D11_SHADER_DESC native_desc;
      assert(SUCCEEDED(reflection->GetDesc(&native_desc)));
      const UINT varying_count = native_desc.OutputParameters - 1;
      UINT native_count = 0;
      for (UINT i = 0; i < native_desc.OutputParameters; ++i) {
        D3D11_SIGNATURE_PARAMETER_DESC parameter;
        assert(SUCCEEDED(reflection->GetOutputParameterDesc(i, &parameter)));
        const BYTE count = BYTE(std::popcount(parameter.Mask));
        assert(parameter.Mask == (1u << count) - 1);
        assert((i == varying_count) == (parameter.SystemValueType == D3D_NAME_POSITION));
        outputs.push_back({0, parameter.SemanticName, parameter.SemanticIndex, 0, count, 0});
        native_count += count;
      }
      const auto native = VertexOutputs(device.Get(), context.Get(), original, outputs);
      const UINT clip_semantic = shader.signature == 12 ? 12 : 10;
      outputs.push_back({0, "TEXCOORD", clip_semantic, 0, 4, 0});
      outputs.push_back({0, "TEXCOORD", clip_semantic + 1, 0, 1, 0});
      assert(motion.Begin(context.Get(), 1, shader.reference, false, false, true));
      const auto extended = VertexOutputs(device.Get(), context.Get(), replacement, outputs);
      motion.End(context.Get());
      for (UINT v = 0; v < 3; ++v) {
        for (UINT c = 0; c < native_count; ++c) {
          const float expected = native[v * native_count + c], actual = extended[v * (native_count + 5) + c];
          if (!std::isfinite(actual) || std::abs(expected - actual) >= 2e-4f)
            std::cerr << "forward/hair " << std::hex << hash << std::dec << " vertex " << v << " component " << c << " native=" << expected << " replacement=" << actual << '\n';
          assert(std::isfinite(actual) && std::abs(expected - actual) < 2e-4f);
        }
        assert(std::abs(extended[v * (native_count + 5) + native_count] - ((shader.reference ? vertices[v].position[0] * .5f + .25f : vertices[v].position[0]) + .35f)) < 2e-5f);
        assert(extended[v * (native_count + 5) + native_count + 4] == 1.f);
      }
      const auto original_view = view, original_bones = bones;
      std::array<float, 20> original_instance;
      std::copy_n(instance, 20, original_instance.begin());
      UINT unequal_clip = 0;
      for (UINT sample = 0; sample < 8; ++sample) {
        for (UINT i = 0; i < 16; ++i) view[i] = std::sin(float(i * 17 + sample * 11 + 1)) * 1.731f;
        for (UINT i = 0; i < 12; ++i) instance[i] = std::cos(float(i * 7 + sample * 13 + 2)) * 2.193f;
        for (UINT i = 0; i < 16; ++i) bones[32 + i] = std::sin(float(i * 3 + sample * 7 + 1)) * .173f + float(i % 5 == 0);
        context->UpdateSubresource(view_buffer.Get(), 0, nullptr, view.data(), 0, 0);
        context->UpdateSubresource(instances.Get(), 0, nullptr, instance, 0, 0);
        context->UpdateSubresource(bone_buffer.Get(), 0, nullptr, bones.data(), 0, 0);
        const auto a = VertexOutputs(device.Get(), context.Get(), original, std::span(outputs).first(varying_count + 1));
        assert(motion.Begin(context.Get(), 1, shader.reference, false, false, true));
        const auto b = VertexOutputs(device.Get(), context.Get(), replacement, outputs);
        motion.End(context.Get());
        for (UINT vertex = 0; vertex < 3; ++vertex)
          for (UINT component = native_count - 4; component < native_count; ++component)
            unequal_clip += std::bit_cast<uint32_t>(a[vertex * native_count + component]) != std::bit_cast<uint32_t>(b[vertex * (native_count + 5) + component]);
      }
      view = original_view; bones = original_bones;
      std::copy_n(original_instance.begin(), 20, instance);
      context->UpdateSubresource(view_buffer.Get(), 0, nullptr, view.data(), 0, 0);
      context->UpdateSubresource(instances.Get(), 0, nullptr, instance, 0, 0);
      context->UpdateSubresource(bone_buffer.Get(), 0, nullptr, bones.data(), 0, 0);
      if (hash == 0xAB3E8304) {
        // Group-12 hair has a different history ABI. The ordinary material
        // pair loop deliberately excludes it; exercise its BlitzFX PS here.
        for (const auto& pixel : OBJECT_PIXEL_SHADERS) {
          if (pixel.signature != 12 || pixel.hash != 0xC2F7B0B1) continue;
          const auto native_pixel_code = Read(originals / std::format("0x{:08X}.cso", pixel.hash));
          BindMaterialInputs(context.Get(), native_pixel_code, material_view.Get(), texture_array.Get(), cube_view.Get(), cubes_view.Get());
          cb = frame_buffer.Get(); context->PSSetConstantBuffers(12, 1, &cb);
          cb = light_cb.Get(); context->PSSetConstantBuffers(13, 1, &cb);
          srv = raw_srv.Get(); context->PSSetShaderResources(20, 1, &srv);
          ComPtr<ID3D11VertexShader> native_vertex, extended_vertex;
          ComPtr<ID3D11PixelShader> native_pixel, extended_pixel;
          assert(SUCCEEDED(device->CreateVertexShader(original.data(), original.size(), nullptr, &native_vertex)));
          assert(SUCCEEDED(device->CreateVertexShader(replacement.data(), replacement.size(), nullptr, &extended_vertex)));
          assert(SUCCEEDED(device->CreatePixelShader(native_pixel_code.data(), native_pixel_code.size(), nullptr, &native_pixel)));
          assert(SUCCEEDED(device->CreatePixelShader(pixel.code.data(), pixel.code.size(), nullptr, &extended_pixel)));
          for (float alpha : {1.f, .2f}) {
            const float hair_texel[] = {.6f, .65f, .8f, alpha};
            const D3D11_SUBRESOURCE_DATA hair_data{hair_texel, sizeof(hair_texel)};
            ComPtr<ID3D11Texture2D> hair_texture;
            ComPtr<ID3D11ShaderResourceView> hair_view;
            assert(SUCCEEDED(device->CreateTexture2D(&tex_desc, &hair_data, &hair_texture)));
            assert(SUCCEEDED(device->CreateShaderResourceView(hair_texture.Get(), nullptr, &hair_view)));
            srv = hair_view.Get(); context->PSSetShaderResources(0, 1, &srv);
            context->OMSetRenderTargets(1, render_targets, depth_view.Get());
            const float background[] = {.03125f, .0625f, .125f, .25f};
            context->ClearRenderTargetView(targets[0].Get(), background);
            context->VSSetShader(native_vertex.Get(), nullptr, 0);
            context->PSSetShader(native_pixel.Get(), nullptr, 0);
            context->DrawInstanced(3, 1, 0, 0);
            const auto reference = Pixel(context.Get(), colors[0].Get());
            assert(motion.Begin(context.Get(), 1, false, false, false, true));
            for (auto& surface : motion.surfaces) {
              ComPtr<ID3D11Resource> resource;
              ComPtr<ID3D11RenderTargetView> target;
              surface->GetResource(&resource);
              assert(SUCCEEDED(device->CreateRenderTargetView(resource.Get(), nullptr, &target)));
              const float sentinel[] = {-2, -2, -2, -2};
              context->ClearRenderTargetView(target.Get(), sentinel);
            }
            context->ClearRenderTargetView(targets[0].Get(), background);
            context->VSSetShader(extended_vertex.Get(), nullptr, 0);
            context->PSSetShader(extended_pixel.Get(), nullptr, 0);
            context->DrawInstanced(3, 1, 0, 0);
            motion.End(context.Get());
            const auto actual = Pixel(context.Get(), colors[0].Get());
            for (UINT channel = 0; channel < 4; ++channel) assert(SameColor(reference[channel], actual[channel]));
            ComPtr<ID3D11Resource> vectors, object_depth;
            motion.surfaces[0]->GetResource(&vectors); motion.surfaces[1]->GetResource(&object_depth);
            if (alpha < .33f) {
              assert(std::equal(reference.begin(), reference.end(), background));
              assert(Pixel(context.Get(), object_depth.Get())[0] == -2.f);
            } else {
              assert(!std::equal(reference.begin(), reference.end(), background));
              assert(std::abs(Pixel(context.Get(), vectors.Get())[0] - .175f) < .001f);
              assert(Pixel(context.Get(), object_depth.Get())[0] > 0);
            }
          }
          std::cout << "PASS BlitzFX hair 0xC2F7B0B1 native color, TEXCOORD12/13 motion and alpha cutout\n";
        }
      }
      std::cerr << std::format("Forward clip invariance 0x{:08X}: {} / 96 components differ with all varyings/motion consumed\n", hash, unequal_clip);
      forward_clip_differences += unequal_clip;
    }
    assert(forward_clip_differences == 0);
    std::cout << "PASS hair/forward instanced skin: all native vertex varyings and previous pose\n";
  }
  {
    // Reproduce c5afa0's CPU packing and c5a4f0's upload, including reordered
    // visibility and a reallocated CPU array. Three proxies overlap exactly;
    // the third is newly visible and must not poison the other two histories.
    alignas(8) std::array<uint8_t, 0x70> packer = {};
    alignas(16) std::array<std::array<uint8_t, 0x188>, 3> objects = {};
    std::array<uintptr_t, 24> draw_context = {};
    std::array<float, 60> packed_a = {}, packed_b = {};
    draw_context[0] = reinterpret_cast<uintptr_t>(packer.data());
    draw_context[1] = 888;
    for (auto& object : objects) {
      *reinterpret_cast<uint32_t*>(object.data() + 0x10) = 1;
      auto* matrix = reinterpret_cast<float*>(object.data() + 0x40);
      matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1;
    }
    static uint32_t packing_stride;
    object_engine::instance_function = [](uint32_t, uintptr_t context) {
      const auto renderer = *reinterpret_cast<const uintptr_t*>(context);
      const auto object = *reinterpret_cast<const uintptr_t*>(context + 0x18);
      auto* count = reinterpret_cast<uint32_t*>(renderer + (packing_stride == 64 ? 0x54 : 0x60));
      auto* data = *reinterpret_cast<float**>(renderer + (packing_stride == 64 ? 0x4c : 0x58)) + *count * (packing_stride / 4);
      const auto* matrix = reinterpret_cast<const float*>(object + 0x40);
      for (size_t row = 0; row < 3; ++row)
        for (size_t column = 0; column < 4; ++column) data[row * 4 + column] = matrix[column * 4 + row];
      ++*count;
    };
    static std::array<float, 3> expected_previous;
    static std::array<bool, 3> expected_valid;
    static bool expect_batch;
    object_engine::batch_function = [](uintptr_t, uintptr_t, uint32_t, const float*, uint32_t count, uint32_t, uintptr_t) {
      assert(count == 3);
      if (!expect_batch) { assert(object_engine::batch.previous.empty()); return; }
      assert(object_engine::batch.previous.size() == 3);
      for (size_t i = 0; i < 3; ++i) {
        const auto& pose = object_engine::batch.previous[i];
        assert(bool(pose.valid) == expected_valid[i]);
        if (pose.valid) assert(pose.world[3] == expected_previous[i]);
      }
    };
    for (auto bytes : {64u, 80u}) {
      object_engine::state->rigid_history.Clear();
      packing_stride = bytes;
      for (uint32_t current = 0; current < 3; ++current) {
        object_engine::state->frame.store(300 + current);
        auto& packed = current % 2 ? packed_b : packed_a;
        *reinterpret_cast<float**>(packer.data() + (bytes == 64 ? 0x4c : 0x58)) = packed.data();
        *reinterpret_cast<uint32_t*>(packer.data() + (bytes == 64 ? 0x54 : 0x60)) = 0;
        // First frame only two persistent objects; add the new overlapping
        // part on the next frame and reverse the submission order after that.
        for (uint32_t index = 0; index < (current == 0 ? 2u : 3u); ++index) {
          const auto object = current == 2 ? 2 - index : index;
          *reinterpret_cast<float*>(objects[object].data() + 0x40 + 12 * 4) = current == 0 ? float(object + 1) : 5.f;
          draw_context[3] = reinterpret_cast<uintptr_t>(objects[object].data());
          object_engine::InstanceHook(0, reinterpret_cast<uintptr_t>(draw_context.data()));
        }
        if (!current) continue;
        expected_previous = current == 1 ? std::array<float, 3>{1, 2, 0} : std::array<float, 3>{5, 5, 5};
        expected_valid = {true, true, current != 1}; expect_batch = true;
        object_engine::batch = {};
        object_engine::BatchHook(draw_context[0], 888, 0, packed.data(), 3, bytes, 0);
        assert(!object_engine::batch.instances && !object_engine::direct_object);
        expect_batch = false;
        object_engine::BatchHook(draw_context[0], 999, 0, packed.data(), 3, bytes, 0);  // Wrong mesh.
        object_engine::BatchHook(draw_context[0], 888, 0, (current % 2 ? packed_a : packed_b).data(), 3, bytes, 0);  // Wrong CPU array.
      }
      *reinterpret_cast<uint32_t*>(packer.data() + (bytes == 64 ? 0x54 : 0x60)) = 0;
    }
    RigidMotion stationary;
    const std::array<ObjectPose, 1> still_pose = {{{rigid_current, 0, 0, 1, 0}}};
    object_engine::batch = {instance, 1, 64, still_pose};
    assert(!stationary.Prepare(context.Get(), 302));
    assert(!stationary.poses);  // Static buildings never allocate/upload poses.
    object_engine::batch = {};
    std::cout << "PASS exact native batch identities: overlaps, new part, reorder, CPU reallocation, wrong-mesh rejection, stationary fast path\n";
  }
  {
    ObjectMotion flock;
    flock.Configure(depth.Get(), 64, 64);
    object_engine::state->history.Clear();
    context->OMSetRenderTargets(3, render_targets, depth_view.Get());
    view[3] = 0;
    context->UpdateSubresource(view_buffer.Get(), 0, nullptr, view.data(), 0, 0);
    cb = view_buffer.Get(); context->VSSetConstantBuffers(1, 1, &cb);
    cb = mesh_buffer.Get(); context->VSSetConstantBuffers(2, 1, &cb);
    cb = frame_buffer.Get(); context->VSSetConstantBuffers(12, 1, &cb);
    srv = bone_srv.Get(); context->VSSetShaderResources(0, 1, &srv);
    srv = texture_view.Get(); context->PSSetShaderResources(0, 1, &srv);
    context->PSSetShaderResources(3, 1, &srv);
    vb = vertex_buffer.Get(); stride = sizeof(Vertex); offset = 0;
    context->IASetVertexBuffers(0, 1, &vb, &stride, &offset);
    std::array<float, 40> flock_instances;
    std::copy_n(instance, 20, flock_instances.begin());
    std::copy_n(instance, 20, flock_instances.begin() + 20);
    auto flock_buffer = Buffer(device.Get(), flock_instances.data(), sizeof(flock_instances), D3D11_BIND_VERTEX_BUFFER);
    vb = flock_buffer.Get(); stride = 80;
    context->IASetVertexBuffers(7, 1, &vb, &stride, &offset);
    auto first = rigid_current, second = rigid_current;
    first[3] = .2f; second[3] = -.4f;
    const std::array<ObjectPose, 2> worlds = {{{first, 0, 0, 1, 0}, {second, 0, 0, 1, 0}}};
    object_engine::swarm_batch = worlds;
    assert(flock.Begin(context.Get(), 100)); flock.End(context.Get()); flock.Finish(context.Get(), 100);
    const auto palette = object_engine::state->history.Previous(101, {allocation_pointer, 0, 2, 1});
    assert(!palette.valid && palette.palette_valid);  // Shared bones, no ordinary world.
    const auto bird_vs = Read(shaders / "0x64BD97C5.cso"), bird_ps = Read(shaders / "0xB7B6FC64.cso");
    ComPtr<ID3D11VertexShader> bird_vertex;
    ComPtr<ID3D11PixelShader> bird_pixel;
    ComPtr<ID3D11InputLayout> bird_input;
    assert(SUCCEEDED(device->CreateVertexShader(bird_vs.data(), bird_vs.size(), nullptr, &bird_vertex)));
    assert(SUCCEEDED(device->CreatePixelShader(bird_ps.data(), bird_ps.size(), nullptr, &bird_pixel)));
    assert(SUCCEEDED(device->CreateInputLayout(layout, UINT(std::size(layout)), bird_vs.data(), bird_vs.size(), &bird_input)));
    context->IASetInputLayout(bird_input.Get());
    context->VSSetShader(bird_vertex.Get(), nullptr, 0); context->PSSetShader(bird_pixel.Get(), nullptr, 0);
    for (UINT bird = 0; bird < 2; ++bird) {
      assert(flock.Begin(context.Get(), 101));
      context->DrawInstanced(3, bird + 1, 0, 0);
      flock.End(context.Get());
      ComPtr<ID3D11Resource> vectors, surface;
      flock.surfaces[0]->GetResource(&vectors); flock.surfaces[1]->GetResource(&surface);
      assert(std::abs(Pixel(context.Get(), vectors.Get())[0] - (bird ? -.2f : .1f)) < .001f);
      assert(Pixel(context.Get(), surface.Get())[0] > 0);
    }
    object_engine::swarm_batch = {};
    // Ordinary skinned parts use the same palette-independent instance worlds,
    // with identities supplied by the native CPU packing path instead of a flock.
    auto parts = worlds;
    object_engine::batch = {flock_instances.data(), 2, 80, parts};
    const auto part_vs = Read(shaders / "0xF507139A.cso"), part_ps = Read(shaders / "0x280BDA85.cso");
    ComPtr<ID3D11VertexShader> part_vertex;
    ComPtr<ID3D11PixelShader> part_pixel;
    ComPtr<ID3D11InputLayout> part_input;
    assert(SUCCEEDED(device->CreateVertexShader(part_vs.data(), part_vs.size(), nullptr, &part_vertex)));
    assert(SUCCEEDED(device->CreatePixelShader(part_ps.data(), part_ps.size(), nullptr, &part_pixel)));
    assert(SUCCEEDED(device->CreateInputLayout(layout, UINT(std::size(layout)), part_vs.data(), part_vs.size(), &part_input)));
    context->IASetInputLayout(part_input.Get());
    context->VSSetShader(part_vertex.Get(), nullptr, 0); context->PSSetShader(part_pixel.Get(), nullptr, 0);
    ComPtr<ID3D11Resource> vectors, surface;
    flock.surfaces[0]->GetResource(&vectors); flock.surfaces[1]->GetResource(&surface);
    for (UINT part = 0; part < 2; ++part) {
      assert(flock.Begin(context.Get(), 101));
      context->DrawInstanced(3, part + 1, 0, 0); flock.End(context.Get());
      assert(std::abs(Pixel(context.Get(), vectors.Get())[0] - (part ? -.2f : .1f)) < .001f);
      assert(Pixel(context.Get(), surface.Get())[0] > 0);
    }
    parts[1].valid = 0;
    assert(flock.Begin(context.Get(), 101));
    context->DrawInstanced(3, 2, 0, 0); flock.End(context.Get());
    assert(Pixel(context.Get(), surface.Get())[0] < 0);
    assert(flock.Begin(context.Get(), 101));
    context->DrawInstanced(3, 1, 0, 0); flock.End(context.Get());
    assert(Pixel(context.Get(), surface.Get())[0] > 0 && std::abs(Pixel(context.Get(), vectors.Get())[0] - .1f) < .001f);
    object_engine::batch = {};
    std::cout << "PASS skinned parts GPU: shared palette, separate worlds, new invalid part isolated from valid part\n";
    std::cout << "PASS flock GPU: two independent instance worlds sharing one palette without an ordinary mesh world\n";
  }
  {
    // Model c63310's sorted visibility list, native Euler call and draw flush.
    // The full data array rotates and visibility order reverses each frame.
    alignas(8) std::array<uint8_t, 0x160> owner = {};
    alignas(8) std::array<uint8_t, 0x50> node = {};
    std::array<std::array<float, 11>, 2> data_a = {}, data_b = {};
    std::array<uintptr_t, 2> visible;
    const auto owner_pointer = reinterpret_cast<uintptr_t>(owner.data());
    object_engine::state->image = 0x140000000;
    *reinterpret_cast<uintptr_t*>(owner.data()) = object_engine::state->image + 0x2154338;
    *reinterpret_cast<uint32_t*>(owner.data() + 0x10) = 14;
    *reinterpret_cast<uint32_t*>(owner.data() + 0x128) = 2;
    *reinterpret_cast<uintptr_t*>(owner.data() + 0x12c) = reinterpret_cast<uintptr_t>(visible.data());
    *reinterpret_cast<uint32_t*>(owner.data() + 0x134) = 2;
    *reinterpret_cast<uintptr_t*>(owner.data() + 0x158) = 99;
    *reinterpret_cast<uintptr_t*>(node.data() + 0x10) = owner_pointer;
    node[0x4c] = 1;
    for (UINT i = 0; i < 2; ++i) {
      data_a[i][0] = float(i + 1); data_a[i][6] = 1;
      data_b[i][0] = float(i + 11); data_b[i][6] = 1;
    }
    object_engine::euler_function = [](const float*, float* rotation) {
      std::fill_n(rotation, 16, 0.f);
      rotation[0] = rotation[5] = rotation[10] = rotation[15] = 1;
    };
    static std::array<float, 2> expected_world;
    static bool expected_valid;
    object_engine::draw_function = [](uintptr_t, uint32_t, uintptr_t, uint32_t count, uintptr_t) {
      assert(count == 2 && object_engine::swarm_batch.size() == 2);
      for (size_t i = 0; i < 2; ++i) {
        assert(bool(object_engine::swarm_batch[i].valid) == expected_valid);
        if (expected_valid) assert(object_engine::swarm_batch[i].world[3] == expected_world[i]);
      }
    };
    object_engine::swarm_function = [](uintptr_t, uintptr_t, uintptr_t, uintptr_t, uintptr_t, uint32_t, uintptr_t, uintptr_t nodes, uintptr_t) -> uintptr_t {
      const auto owner = *reinterpret_cast<const uintptr_t*>(nodes + 0x10);
      const auto* entries = *reinterpret_cast<const uintptr_t* const*>(owner + 0x12c);
      for (size_t i = 0; i < 2; ++i) {
        float rotation[16];
        object_engine::EulerHook(reinterpret_cast<const float*>(entries[i]) + 3, rotation);
      }
      object_engine::DrawHook(0, 0, 0, 2, 0);
      return 12345;
    };
    for (UINT current = 0; current < 3; ++current) {
      const auto& data = current % 2 ? data_b : data_a;
      *reinterpret_cast<uintptr_t*>(owner.data() + 0x118) = reinterpret_cast<uintptr_t>(data.data());
      for (UINT i = 0; i < 2; ++i) visible[i] = reinterpret_cast<uintptr_t>(data[(current + i) % 2].data());
      expected_world = current == 1 ? std::array<float, 2>{2, 1} : std::array<float, 2>{11, 12};
      expected_valid = current != 0;
      object_engine::state->frame.store(200 + current);
      assert(object_engine::SwarmHook(0, 0, 0, 0, 0, 0, 0, reinterpret_cast<uintptr_t>(node.data()), 0) == 12345);
      assert(!object_engine::swarm_scope && object_engine::swarm_batch.empty());
    }
    object_engine::ObjectFreeHook(owner_pointer);
    object_engine::state->frame.store(203); expected_valid = false;
    object_engine::SwarmHook(0, 0, 0, 0, 0, 0, 0, reinterpret_cast<uintptr_t>(node.data()), 0);
    std::cout << "PASS flock hooks: rotating full array, reordered visibility, independent worlds, proxy destruction and scope restore\n";
  }
  if (!hair_clip_only) {
    // Depth-prepass compatibility needs identical native clip positions, not
    // just close RGB under identity matrices. Exercise nontrivial camera,
    // instance and skin transforms across every non-deformed G-buffer VS.
    vb = vertex_buffer.Get(); stride = sizeof(Vertex); offset = 0;
    context->IASetVertexBuffers(0, 1, &vb, &stride, &offset);
    cb = mesh_buffer.Get(); context->VSSetConstantBuffers(2, 1, &cb); context->VSSetConstantBuffers(3, 1, &cb);
    cb = view_buffer.Get(); context->VSSetConstantBuffers(1, 1, &cb);
    srv = bone_srv.Get(); context->VSSetShaderResources(0, 1, &srv);
    srv = texture_view.Get(); context->VSSetShaderResources(1, 1, &srv);
    const D3D11_SO_DECLARATION_ENTRY position[] = {{0, "SV_POSITION", 0, 0, 4, 0}};
    std::array<Vertex, 3> probe_vertices;
    std::copy_n(vertices, 3, probe_vertices.begin());
    for (auto& vertex : probe_vertices) {
      for (uint32_t i = 0; i < 4; ++i) {
        vertex.indices[i] = i;
        vertex.weights[i] = .1f * float(i + 1);
      }
    }
    context->UpdateSubresource(vertex_buffer.Get(), 0, nullptr, probe_vertices.data(), 0, 0);
    for (const auto& shader : OBJECT_VERTEX_SHADERS) {
      if (shader.foliage || shader.deformed || shader.forward) continue;
      const auto native = Read(originals / std::format("0x{:08X}.cso", shader.hash));
      const auto replacement = Read(shaders / std::format("0x{:08X}.cso", shader.hash));
      ComPtr<ID3D11InputLayout> input;
      assert(SUCCEEDED(device->CreateInputLayout(layout, UINT(std::size(layout)), native.data(), native.size(), &input)));
      context->IASetInputLayout(input.Get());
      UINT unequal = 0;
      for (UINT sample = 0; sample < 24; ++sample) {
        for (UINT i = 0; i < 16; ++i) view[i] = std::sin(float(i * 17 + sample * 11 + 1)) * 1.731f;
        for (UINT i = 0; i < 12; ++i) instance[i] = std::cos(float(i * 7 + sample * 13 + 2)) * 2.193f;
        instance[16] = 0; instance[17] = 1;
        for (UINT bone = 0; bone < 4; ++bone)
          for (UINT i = 0; i < 16; ++i) bones[bone * 16 + i] = std::sin(float(bone * 19 + i * 3 + sample * 7 + 1)) * .173f + float(i % 5 == 0);
        context->UpdateSubresource(bone_buffer.Get(), 0, nullptr, bones.data(), 0, 0);
        context->UpdateSubresource(view_buffer.Get(), 0, nullptr, view.data(), 0, 0);
        context->UpdateSubresource(instances.Get(), 0, nullptr, instance, 0, 0);
        vb = instances.Get(); stride = shader.rigid ? 64 : 80;
        context->IASetVertexBuffers(7, 1, &vb, &stride, &offset);
        const auto a = VertexOutputs(device.Get(), context.Get(), native, position);
        const auto b = VertexOutputs(device.Get(), context.Get(), replacement, position);
        for (size_t i = 0; i < a.size(); ++i) unequal += std::bit_cast<uint32_t>(a[i]) != std::bit_cast<uint32_t>(b[i]);
      }
      std::cout << std::format("Native clip invariance 0x{:08X}: {} / 288 components differ\n", shader.hash, unequal);
      assert(unequal == 0);
    }
  }
  std::cout << "Matched native nonfinite color channels in synthetic material combinations: " << matched_nonfinite_colors << '\n';
  DeleteCriticalSection(reinterpret_cast<CRITICAL_SECTION*>(renderer.data() + 0x30));
  ComPtr<ID3D11InfoQueue> info;
  if (SUCCEEDED(device.As(&info)))
    for (UINT64 i = 0; i < info->GetNumStoredMessages(); ++i) {
      SIZE_T size = 0;
      info->GetMessage(i, nullptr, &size);
      std::vector<uint8_t> bytes(size);
      auto* message = reinterpret_cast<D3D11_MESSAGE*>(bytes.data());
      info->GetMessage(i, message, &size);
      if (message->Severity <= D3D11_MESSAGE_SEVERITY_ERROR) {
        std::cerr << message->pDescription << '\n';
        assert(false);
      }
    }
}
