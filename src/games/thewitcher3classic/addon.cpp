/*
 * Copyright (C) 2024 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */
#include <algorithm>
#include <cmath>

#define ImTextureID ImU64
#include <deps/imgui/imgui.h>
#include <embed/shaders.h>
#include <include/reshade.hpp>
#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/random.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/swapchain.hpp"
#include "./shared.h"
#include "./temporal/runtime.hpp"
#include "./volumetrics/runtime.hpp"
#include "./lighting/runtime.hpp"

namespace {
float settings_mode = 0.f;
float video_auto_hdr = 1.f;
bool draw_effects = false;
bool draw_graphics = false;
float depth_controls_mode = 1.f;
bool detected_peak = false;

ShaderInjectData shader_injection = {
    .tone_map_type = CLASSIC_TONE_MAP_PSYCHOV31,
    .peak_white_nits = 1000.f,
    .diffuse_white_nits = 203.f,
    .graphics_white_nits = 203.f,
    .tone_map_exposure = 1.f,
    .tone_map_highlights = 1.f,
    .tone_map_shadows = 1.f,
    .tone_map_contrast = 1.f,
    .tone_map_highlight_contrast = 1.f,
    .tone_map_shadow_contrast = 1.f,
    .tone_map_saturation = 1.f,
    .tone_map_highlight_saturation = 1.f,
    .tone_map_gamma = 1.f,
    .psychov_adaptation_anchor = 0.18f,
    .psychov_background_anchor = 0.18f,
    .psychov_highlight_hue = 1.f,
    .psychov_gamut_compression = 1.f,
    .psychov_gamut_compression_mode = 3.f,
    .custom_bloom = 1.f,
    .custom_lens_dirt = 1.f,
    .custom_sunshafts_strength = 1.f,
    .custom_blur = 1.f,
    .chromatic_aberration_intensity = 1.f,
    .vignette_strength = 1.f,
    .vignette_black_floor = 1.f,
    .lut_strength = 1.f,
    .color_grading_strength = 1.f,
};

struct __declspec(uuid("de5bfd39-2532-4eb9-ac11-94d4df036e87")) BloomRouting {
  std::atomic<bool> blitz_drawn = false;
  std::array<std::atomic<uint64_t>, 3> native_material_views{};
};

// Detect the executed composite, not merely an installed DLL or compiled PSO.
// The captured BlitzFX composite precedes the native post-filmic effects.
void OnBloomInitDevice(reshade::api::device* device) {
  renodx::utils::data::Create<BloomRouting>(device);
}
void OnBloomDestroyDevice(reshade::api::device* device) {
  renodx::utils::data::Delete<BloomRouting>(device);
}

// Material data is UNORM, not scene radiance. The broad scene-color rule also
// matches Classic's three G-buffer attachments. In BlitzFX PBR this admits
// roughness > 1, unquantized normals and invalid packed material fields.
void OnMaterialTargets(reshade::api::command_list* cmd, uint32_t count,
                       const reshade::api::resource_view* rtvs, reshade::api::resource_view dsv) {
  if (count != 3 || !dsv.handle
      || cmd->get_device()->get_api() != reshade::api::device_api::d3d11) return;
  auto* data = renodx::utils::data::Get<BloomRouting>(cmd->get_device());
  if (!data || (data->native_material_views[0].load(std::memory_order_relaxed) == rtvs[0].handle
      && data->native_material_views[1].load(std::memory_order_relaxed) == rtvs[1].handle
      && data->native_material_views[2].load(std::memory_order_relaxed) == rtvs[2].handle)) return;

  const auto depth = cmd->get_device()->get_resource_desc(
      renodx::utils::resource::GetResourceFromView(cmd->get_device(), dsv));
  if (depth.texture.format != reshade::api::format::r24_g8_typeless
      && depth.texture.format != reshade::api::format::d24_unorm_s8_uint) return;
  std::array<reshade::api::resource, 3> resources{};
  for (uint32_t i = 0; i < 3; ++i) {
    bool material = false;
    renodx::utils::resource::GetResourceViewInfo(rtvs[i], [&](const auto& view) {
      if (view.is_clone || view.desc.format != reshade::api::format::r8g8b8a8_unorm) return;
      resources[i] = view.original_resource;
    });
    if (!resources[i].handle) return;
    renodx::utils::resource::GetResourceInfo(resources[i], [&](const auto& info) {
      material = !info.is_clone && !info.is_swap_chain
          && ((!info.clone_target && !info.clone_enabled)
              || (info.clone_target && info.clone_target->name == "Classic scene color"))
          && info.desc.type == reshade::api::resource_type::texture_2d
          && info.desc.texture.format == reshade::api::format::r8g8b8a8_unorm
          && info.desc.texture.width == depth.texture.width
          && info.desc.texture.height == depth.texture.height
          && info.desc.texture.depth_or_layers == 1 && info.desc.texture.samples == 1;
    });
    if (!material) return;
  }

  for (uint32_t i = 0; i < 3; ++i) {
    std::vector<uint64_t> views;
    renodx::utils::resource::UpdateResourceInfo(resources[i], [&](auto* info) {
      info->clone_enabled = false;
      info->clone_can_deactivate = false;
      info->clone_target = nullptr;
      views.assign(info->resource_view_handles.begin(), info->resource_view_handles.end());
    });
    for (const auto handle : views) {
      renodx::utils::resource::UpdateResourceViewInfo({handle}, [](auto* view) {
        view->clone_enabled = false;
        view->clone_can_deactivate = false;
        view->clone_target = nullptr;
      });
    }
    data->native_material_views[i].store(rtvs[i].handle, std::memory_order_relaxed);
  }
  if(auto* lighting=renodx::utils::data::Get<witcher3classic::lighting::DeviceData>(cmd->get_device())) {
    auto* albedo=reinterpret_cast<ID3D11Resource*>(resources[0].handle);
    if(lighting->contact.albedo_resource.Get()!=albedo) {
      lighting->contact.albedo.Reset();lighting->contact.albedo_resource.Reset();
      Microsoft::WRL::ComPtr<ID3D11Device> device;albedo->GetDevice(&device);
      if(SUCCEEDED(device->CreateShaderResourceView(albedo,nullptr,&lighting->contact.albedo)))
        lighting->contact.albedo_resource=albedo;
    }
  }
  // A shared cloning callback may already have rebound the FP16 targets.
  // Rebind the application's native views once, independent of callback order.
  cmd->bind_render_targets_and_depth_stencil(count, rtvs, dsv);
  reshade::log::message(reshade::log::level::info,
      "Witcher Classic: preserving native UNORM material G-buffer storage.");
}

void OnMaterialViewDestroyed(reshade::api::device* device, reshade::api::resource_view view) {
  if (auto* data = renodx::utils::data::Get<BloomRouting>(device)) {
    for (auto& cached : data->native_material_views) {
      if (cached.load(std::memory_order_relaxed) == view.handle) cached.store(0, std::memory_order_relaxed);
    }
  }
}
void OnBloomPresent(reshade::api::command_queue*, reshade::api::swapchain* swapchain,
                    const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  witcher3classic::optics::custom = shader_injection.tone_map_type == CLASSIC_TONE_MAP_PSYCHOV31;
  if (auto* data = renodx::utils::data::Get<BloomRouting>(swapchain->get_device())) {
    data->blitz_drawn.store(false, std::memory_order_relaxed);
  }
}
bool OnNativeBloomInject(reshade::api::command_list* cmd) {
  const auto* data = renodx::utils::data::Get<BloomRouting>(cmd->get_device());
  shader_injection.blitz_bloom_active = (witcher3classic::optics::custom && witcher3classic::optics::bloom_mode == 1.f)
      || (data && data->blitz_drawn.load(std::memory_order_relaxed)) ? 1.f : 0.f;
  return true;
}

// b13 is unused by these replacements, but may belong to a later native compute
// shader. Restore the actual binding without enabling global state snapshots.
thread_local std::vector<Microsoft::WRL::ComPtr<ID3D11Buffer>> blitz_compute_constants;
bool OnBlitzComputeInject(reshade::api::command_list* cmd) {
  shader_injection.blitz_bloom_active = witcher3classic::optics::custom && witcher3classic::optics::bloom_mode == 1.f ? -1.f : 0.f;
  blitz_compute_constants.emplace_back();
  reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native())->CSGetConstantBuffers(
      13, 1, blitz_compute_constants.back().GetAddressOf());
  const auto* frame = witcher3classic::temporal::upscale_engine::active;
  shader_injection.blitz_shadow_jitter_delta_x = frame ? frame->shadow_jitter_delta[0] : 0.f;
  shader_injection.blitz_shadow_jitter_delta_y = frame ? frame->shadow_jitter_delta[1] : 0.f;
  return true;
}
void OnBlitzComputeDrawn(reshade::api::command_list* cmd) {
  if (!blitz_compute_constants.empty()) {
    reinterpret_cast<ID3D11DeviceContext*>(cmd->get_native())->CSSetConstantBuffers(
        13, 1, blitz_compute_constants.back().GetAddressOf());
    blitz_compute_constants.pop_back();
  }
}
void OnBlitzBloomDrawn(reshade::api::command_list* cmd) {
  OnBlitzComputeDrawn(cmd);
  if (auto* data = renodx::utils::data::Get<BloomRouting>(cmd->get_device())) {
    data->blitz_drawn.store(true, std::memory_order_relaxed);
  }
}

bool OnOpticsInject(reshade::api::command_list* cmd) {
  using namespace witcher3classic::temporal;
  auto* data = renodx::utils::data::Get<DeviceData>(cmd->get_device());
  if (!data || !data->motion_context || show_object_vectors != 0.f
      || shader_injection.tone_map_type != CLASSIC_TONE_MAP_PSYCHOV31) return true;
  auto* context = data->motion_context.Get();
  ComPtr<ID3D11ShaderResourceView> source;
  context->PSGetShaderResources(0, 1, &source);
  if (!source) return true;
  ComPtr<ID3D11Resource> resource; ComPtr<ID3D11Texture2D> texture;
  source->GetResource(&resource);
  if (FAILED(resource.As(&texture))) return true;
  D3D11_TEXTURE2D_DESC desc; texture->GetDesc(&desc);
  D3D11_VIEWPORT viewport; UINT count = 1;
  context->RSGetViewports(&count, &viewport);
  if (count != 1 || viewport.TopLeftX != 0 || viewport.TopLeftY != 0
      || viewport.Width != float(desc.Width) || viewport.Height != float(desc.Height)) return true;
  const float sharpening = shader_injection.chromatic_aberration_mode != 0.f
      && shader_injection.chromatic_aberration_intensity > 0.f && shader_injection.sharpening_mode != 0.f
      ? shader_injection.sharpening_strength : 0.f;
  if (auto* filtered = data->optics.Run(context, source.Get(), desc.Width, desc.Height, data->frame, sharpening)) {
    data->optics.saved_scene = source;
    context->PSSetShaderResources(0, 1, &filtered);
    if (sharpening > 0.f) {
      data->optics.saved_sharpening = shader_injection.sharpening_strength;
      shader_injection.sharpening_strength = 0.f;
    }
  }
  return true;
}
void OnOpticsDrawn(reshade::api::command_list* cmd) {
  auto* data = renodx::utils::data::Get<witcher3classic::temporal::DeviceData>(cmd->get_device());
  if (!data || !data->optics.saved_scene || !data->motion_context) {
    return;
  }
  auto* source = data->optics.saved_scene.Get();
  data->motion_context->PSSetShaderResources(0, 1, &source);
  data->optics.saved_scene.Reset();
  if (data->optics.saved_sharpening >= 0.f) {
    shader_injection.sharpening_strength = data->optics.saved_sharpening;
    data->optics.saved_sharpening = -1.f;
  }
}

renodx::mods::shader::CustomShaders custom_shaders = {
    {0x05FE9FA8, {.crc32 = 0x05FE9FA8, .code = __0x05FE9FA8,
        .on_replace = &witcher3classic::lighting::OnShadow,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0x0AB3A292, {.crc32 = 0x0AB3A292, .code = __0x0AB3A292,
        .on_replace = &witcher3classic::lighting::OnLocalLight,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0x3946E96C, {.crc32 = 0x3946E96C, .code = __0x3946E96C,
        .on_replace = &witcher3classic::lighting::OnLocalLight,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0x3CED9DA6, {.crc32 = 0x3CED9DA6, .code = __0x3CED9DA6,
        .on_replace = &witcher3classic::lighting::OnLocalLight,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0x3FFDA0D9, {.crc32 = 0x3FFDA0D9, .code = __0x3FFDA0D9,
        .on_replace = &witcher3classic::lighting::OnLocalLight,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0x4E4E4B53, {.crc32 = 0x4E4E4B53, .code = __0x4E4E4B53,
        .on_replace = &witcher3classic::lighting::OnHair,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0x72225972, {.crc32 = 0x72225972, .code = __0x72225972,
        .on_replace = &witcher3classic::lighting::OnLocalLight,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0x95991F6F, {.crc32 = 0x95991F6F, .code = __0x95991F6F,
        .on_replace = &witcher3classic::lighting::OnLocalLight,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0xD3573BB9, {.crc32 = 0xD3573BB9, .code = __0xD3573BB9,
        .on_replace = &witcher3classic::lighting::OnLocalLight,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0xED6CEFE4, {.crc32 = 0xED6CEFE4, .code = __0xED6CEFE4,
        .on_replace = &witcher3classic::lighting::OnLocalLight,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0xFB29B4E6, {.crc32 = 0xFB29B4E6, .code = __0xFB29B4E6,
        .on_replace = &witcher3classic::lighting::OnLighting,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::lighting::OnDrawn}},
    {0xC8C78997, {.crc32 = 0xC8C78997, .code = __0xC8C78997,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f || witcher3classic::water::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnFog,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x4EF2AAF8, {.crc32 = 0x4EF2AAF8, .code = __0x4EF2AAF8,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f || witcher3classic::water::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnParticle,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x44ECC136, {.crc32 = 0x44ECC136, .code = __0x44ECC136,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x2472CF83, {.crc32 = 0x2472CF83, .code = __0x2472CF83,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x8C9C55EC, {.crc32 = 0x8C9C55EC, .code = __0x8C9C55EC,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x28D7BDFE, {.crc32 = 0x28D7BDFE, .code = __0x28D7BDFE,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f || witcher3classic::water::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnWater,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0xFD1D6FBF, {.crc32 = 0xFD1D6FBF, .code = __0xFD1D6FBF,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0xFAB74FB3, {.crc32 = 0xFAB74FB3, .code = __0xFAB74FB3,
        .on_replace = [](auto*) { return witcher3classic::lighting::player_control != 0.f || witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = [](auto* cmd) {
          if (witcher3classic::lighting::player_control != 0.f) witcher3classic::lighting::Bind(cmd,false);
          return witcher3classic::volumetrics::OnForward(cmd);
        },
        .on_drawn = [](auto* cmd) {
          witcher3classic::lighting::OnDrawn(cmd);
          witcher3classic::volumetrics::OnDrawn(cmd);
        }}},
    {0x02A34C28, {.crc32 = 0x02A34C28, .code = __0x02A34C28,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f || witcher3classic::water::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnParticle,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0xA7921C82, {.crc32 = 0xA7921C82, .code = __0xA7921C82,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f || witcher3classic::water::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnParticle,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x4FBB126B, {.crc32 = 0x4FBB126B, .code = __0x4FBB126B,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x5F9AE754, {.crc32 = 0x5F9AE754, .code = __0x5F9AE754,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x105478E1, {.crc32 = 0x105478E1, .code = __0x105478E1,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f || witcher3classic::water::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnParticle,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x22FD7485, {.crc32 = 0x22FD7485, .code = __0x22FD7485,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0xBC930752, {.crc32 = 0xBC930752, .code = __0xBC930752,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x22D1E925, {.crc32 = 0x22D1E925, .code = __0x22D1E925,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    CustomShaderEntry(0x043049C7),  // SDR video with vertex fade.
    CustomShaderEntry(0x30C6DAFA),  // Opaque SDR video.
    CustomShaderEntry(0x7542753B),  // Premultiplied video with vertex fade.
    CustomShaderEntry(0xA850FB8D),  // Video with alpha plane and vertex fade.
    CustomShaderEntry(0x989EB8B2),  // Premultiplied alpha-plane video with vertex fade.
    CustomShaderEntry(0xDC4FAC37),  // Video with alpha plane.
    CustomShaderEntry(0xDCEB62A5),  // Premultiplied video with alpha plane.
    {0x47CC9FA1, {.crc32 = 0x47CC9FA1, .code = __0x47CC9FA1,
        .on_replace = &witcher3classic::volumetrics::OnReflectionTrace,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x406B9233, {.crc32 = 0x406B9233, .code = __0x406B9233,
        .on_replace = &witcher3classic::volumetrics::OnReflectionInput,
        .on_inject = [](auto*) { return false; },
        .on_drawn = &witcher3classic::volumetrics::OnReflectionInputDrawn}},
    CustomShaderEntry(0xB4953357),  // Native exposure and filmic curve.
    CustomShaderEntry(0xAEE0B973),  // Manual exposure.
    CustomShaderEntry(0xAE7D5FA8),  // Blended environment exposure/filmic curves.
    CustomShaderEntry(0x51F4E5FD),  // Blended curves with manual exposure.
    CustomShaderEntry(0x27EF680B),  // Packed scene LUT, before temporal AA.
    CustomShaderEntry(0x63047C3C),  // Two-LUT grade.
    CustomShaderEntry(0x65B4CEFA),  // Environment blend, one LUT per environment.
    CustomShaderEntry(0xE91AAC85),  // Environment blend, two plus one LUTs.
    CustomShaderEntry(0x7526E398),  // Environment blend, one plus two LUTs.
    CustomShaderEntry(0x7818760A),  // Environment blend, two LUTs per environment.
    {0x201C53B4, {.crc32 = 0x201C53B4, .on_draw = &witcher3classic::temporal::OnTemporalDraw}},
    CustomShaderEntry(0x649AF4FA),  // Analytic grade, vignette, output before UI.
    CustomShaderEntry(0x5CBEC131),  // Cutscene analytic grade without vignette.
    CustomShaderEntry(0x9F48B203),  // Analytic vignette, no chromatic aberration.
    CustomShaderEntry(0x1E28F70E),  // No vignette or chromatic aberration.
    CustomShaderEntry(0xA1C06A7D),  // Texture vignette, no chromatic aberration.
    CustomShaderEntry(0xC4D2D4F6),  // Texture vignette and chromatic aberration.
    CustomShaderEntry(0x6ED58557),  // Native depth blur, before temporal reconstruction.
    CustomShaderEntry(0x1A70FFE2),  // Native motion-blur composite bypass.
    CustomShaderEntry(0x9A905454),  // BlitzFX vanilla depth-blur composite bypass.
    CustomShaderEntry(0x3EDDC379),  // Bypass native pre-AA sharpening in RCAS mode.
    CustomShaderEntry(0x56BDBC86),  // Shared bloom/shafts extraction.
    CustomShaderEntry(0xBAEDA9BD),  // Masked sky feeding light shafts.
    {0x620431CF, {.crc32 = 0x620431CF, .code = __0x620431CF, .on_inject = &OnNativeBloomInject}},  // Additive bloom with lens dirt.
    {0x0CB5EA21, {.crc32 = 0x0CB5EA21, .code = __0x0CB5EA21, .on_inject = &OnNativeBloomInject}},  // Screen-blended effect composite.
    {0x2825099C, {.crc32 = 0x2825099C, .code = __0x2825099C, .on_inject = &witcher3classic::volumetrics::OnWater, .on_drawn = &witcher3classic::volumetrics::OnDrawn}},  // BlitzFX water; preserve native lighting b13.
    {0xBF3EF83C, {.crc32 = 0xBF3EF83C, .code = __0xBF3EF83C, .on_inject = &OnBlitzComputeInject, .on_drawn = &OnBlitzBloomDrawn}},  // BlitzFX bloom strength and subrect.
    {0x4708B025, {.crc32 = 0x4708B025, .code = __0x4708B025, .on_inject = &OnBlitzComputeInject, .on_drawn = &OnBlitzComputeDrawn}},  // BlitzFX shadow subrect and jitter history.
    {0x58959EAD, {.crc32 = 0x58959EAD, .code = __0x58959EAD, .on_inject = [](auto*) { return false; }}},  // BlitzFX shadow subrect.
    {0xCA115962, {.crc32 = 0xCA115962, .code = __0xCA115962, .on_inject = [](auto*) { return false; }}},  // BlitzFX current-depth / reconstructed-color reflection prep.
    {0x4E0137BC, {.crc32 = 0x4E0137BC, .code = __0x4E0137BC, .on_inject = [](auto*) { return false; }}},  // BlitzFX water reflection history subrect.
    {0x657A6576, {.crc32 = 0x657A6576, .code = __0x657A6576, .on_inject = [](auto*) { return false; }}},  // BlitzFX reflection depth subrect.
    {0xB018A95A, {.crc32 = 0xB018A95A, .code = __0xB018A95A, .on_inject = [](auto*) { return false; }}},  // BlitzFX DoF color/CoC reduction.
    {0x48885E0D, {.crc32 = 0x48885E0D, .code = __0x48885E0D, .on_inject = [](auto*) { return false; }}},  // BlitzFX DoF bokeh.
    {0xB73522BB, {.crc32 = 0xB73522BB, .code = __0xB73522BB, .on_inject = [](auto*) { return false; }}},  // BlitzFX DoF color dilation.
    {0xAE334616, {.crc32 = 0xAE334616, .code = __0xAE334616, .on_inject = [](auto*) { return false; }}},  // BlitzFX DoF composite.
    {0x249DA2F1, {.crc32 = 0x249DA2F1, .code = __0x249DA2F1, .on_inject = [](auto*) { return false; }}},  // BlitzFX camera motion blur.
    {0x1F3A90A1, {.crc32 = 0x1F3A90A1, .code = __0x1F3A90A1, .on_inject = [](auto*) { return false; }}},  // BlitzFX refractive rain.
    {0x1C74D220, {.crc32 = 0x1C74D220, .code = __0x1C74D220, .on_inject = [](auto*) { return false; }}},  // Refractive rain without extra particle varying.
    CustomShaderEntry(0x0E583BCD),  // BlitzFX: blended environment filmic curves.
    CustomShaderEntry(0x5AA6AFFF),  // BlitzFX: exposed filmic curve, before scene LUT.
    CustomShaderEntry(0x114D8828),  // BlitzFX: final grade, CA, borders and output.
    CustomShaderEntry(0xA123EB15),  // BlitzFX: cutscene grade with CA, no vignette.
    CustomShaderEntry(0x399CBE16),  // BlitzFX: texture vignette, no native CA.
    CustomShaderEntry(0x445EB59C),  // BlitzFX: texture vignette and native CA.
    CustomShaderEntry(0x4FC8DAEB),  // BlitzFX: analytic vignette, no native CA.
    CustomShaderEntry(0xE276DFB3),  // BlitzFX: no native vignette or CA.
    CustomShaderEntry(0xFBF141A1),  // BlitzFX: avoid sharpening twice in RCAS mode.
};

bool IsCustom() { return shader_injection.tone_map_type == CLASSIC_TONE_MAP_PSYCHOV31; }

float DepthControlMode() {
  return witcher3classic::optics::dof_mode == 2.f ? depth_controls_mode : witcher3classic::optics::dof_mode;
}

// HDR settings appear in this order. Move a complete Setting block to reorder.
// DLSS preferences at the end are global; DrawAddon renders their dropdown UI.
renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "GfxLighting",
        .binding = &witcher3classic::lighting::shading,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.0f,
        .label = "Surface Lighting",
        .section = "Lighting",
        .tooltip = "Native preserves the original materials. Custom uses GGX with height-correlated visibility for deferred sun, moon and local lights. Keeps weather, reflection probes and skin transmission. Intended for use without BlitzFX PBR lighting.",
        .labels = {"Native", "Custom PBR"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxAmbientAO",
        .binding = &witcher3classic::lighting::ambient_ao,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.0f,
        .label = "Ambient Occlusion Influence",
        .section = "Lighting",
        .tooltip = "Ambient Only confines deferred ambient occlusion to indirect lighting. Direct lights retain their own shadows instead of receiving a second AO darkening.",
        .labels = {"Native", "Ambient Only"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxSoftShadows",
        .binding = &witcher3classic::lighting::soft_shadows,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.0f,
        .label = "Directional Shadows",
        .section = "Shadows",
        .tooltip = "Custom uses blocker-dependent soft shadows with filtered cascade transitions. Only the existing sun/moon shadow mask changes; cloud and terrain shadows are retained.",
        .labels = {"Native", "Custom Soft Shadows"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxSunDiameter",
        .binding = &witcher3classic::lighting::sun_diameter,
        .default_value = 0.15f,
        .label = "Light Angular Diameter",
        .section = "Shadows",
        .tooltip = "Apparent diameter of the sun or moon, in degrees. 0.535 approximates the real sun. Larger values broaden penumbras with blocker distance. Does not change the visible sun disk.",
        .min = 0.05f,
        .max = 2.0f,
        .format = "%.3f degrees",
        .is_enabled = [] { return witcher3classic::lighting::soft_shadows != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxContactShadows",
        .binding = &witcher3classic::lighting::contact_shadows,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.0f,
        .label = "Contact Shadows",
        .section = "Shadows",
        .tooltip = "Adds short sun/moon shadows from visible depth detail. Complements shadow maps; cannot see offscreen or transparent blockers. A short reach reduces screen-space artifacts.",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxContactLength",
        .binding = &witcher3classic::lighting::contact_length,
        .default_value = 0.3f,
        .label = "Contact Shadow Reach",
        .section = "Shadows",
        .tooltip = "Maximum distance searched toward the light, in metres. Default is 0.3 m. Limits the search toward the light. Sampling also has a fixed screen-space range, so close-ups can reach that limit first. Increasing reach does not spread the samples farther apart.",
        .min = 0.05f,
        .max = 1.0f,
        .format = "%.2f m",
        .is_enabled = [] { return witcher3classic::lighting::contact_shadows != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxPlayerFill",
        .binding = &witcher3classic::lighting::player_control,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.0f,
        .label = "Player Fill Light",
        .section = "Player Lighting",
        .tooltip = "Controls the artificial camera-following fill lights identified by the engine. Torches, spells and other world lights retain their intensity. This is an artistic control, not a physical light source.",
        .labels = {"Native", "Custom"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxPlayerStrength",
        .binding = &witcher3classic::lighting::player_strength,
        .default_value = 0.2f,
        .label = "Fill Light Strength",
        .section = "Player Lighting",
        .tooltip = "Scales the artificial player fill lights. 1 retains native intensity; 0 removes them. Does not change scene exposure.",
        .min = 0.0f,
        .max = 1.0f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::lighting::player_control != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxPlayerUnify",
        .binding = &witcher3classic::lighting::player_unify,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.0f,
        .label = "Match Character and World Fill",
        .section = "Player Lighting",
        .tooltip = "Uses the world fill-light scale on characters too, reducing the camera-light brightness boost on characters. Keeps disabled scene lights disabled.",
        .labels = {"Off", "On"},
        .is_enabled = [] { return witcher3classic::lighting::player_control != 0.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "GfxVolumetrics",
        .binding = &witcher3classic::volumetrics::mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Atmospheric Fog",
        .section = "Volumetric Sunlight and Fog",
        .tooltip = "Native keeps the game's atmospheric fog. Custom uses a three-dimensional fog volume lit by the sun or moon, with scene and cloud shadows. Follows the current weather. Experimental: water and transparent-surface coverage is being validated.",
        .labels = {"Native", "Custom"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogDensity",
        .binding = &witcher3classic::volumetrics::density,
        .default_value = 1.0f,
        .label = "Fog Density",
        .section = "Volumetric Sunlight and Fog",
        .tooltip = "Scales the amount of fog supplied by the current weather. 0 removes the custom fog; 1 uses the weather density. Increasing density both obscures the background and scatters more light.",
        .min = 0.f,
        .max = 4.0f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogStart",
        .binding = &witcher3classic::volumetrics::start_distance,
        .default_value = 0.0f,
        .label = "Fog Start Distance",
        .section = "Volumetric Sunlight and Fog",
        .tooltip = "Distance from the camera in metres before custom fog begins. A short fade prevents a hard boundary. This does not move lights or their shadows.",
        .min = 0.f,
        .max = 200.0f,
        .format = "%.0f m",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogLight",
        .binding = &witcher3classic::volumetrics::light_strength,
        .default_value = 1.0f,
        .label = "Light Scattering",
        .section = "Volumetric Sunlight and Fog",
        .tooltip = "Scales sunlight and moonlight scattered by the fog. 0 removes their contribution while retaining ambient fog and its density. Higher values make illuminated shafts more prominent.",
        .min = 0.f,
        .max = 4.0f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogAnisotropy",
        .binding = &witcher3classic::volumetrics::anisotropy,
        .default_value = 0.6f,
        .label = "Scattering Directionality",
        .section = "Volumetric Sunlight and Fog",
        .tooltip = "0 scatters light equally in all directions. Higher values concentrate it toward the light, making shafts brightest when looking toward the sun or moon.",
        .min = 0.f,
        .max = 0.8f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogHeight",
        .binding = &witcher3classic::volumetrics::height_falloff,
        .default_value = 1.0f,
        .label = "Height Falloff",
        .section = "Volumetric Sunlight and Fog",
        .tooltip = "Controls how quickly fog thins above the weather-defined ground layer. 1 follows the weather gradient; 0 keeps density uniform with height. Higher values concentrate fog closer to the ground.",
        .min = 0.f,
        .max = 4.0f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "GfxFogResolutionQuality",
        .binding = &witcher3classic::volumetrics::resolution_quality,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 4.f,
        .label = "Volume Resolution",
        .section = "Fog Quality",
        .tooltip = "1: Low (previous resolution), 2: Medium, 3: High, 4: Ultra. Higher levels add detail across the screen and along fog/light shafts, reducing coarse sampling. Increases GPU time and video memory. Changes apply immediately with Custom fog.",
        .min = 1.f,
        .max = 4.f,
        .format = "%d / 4",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogShadowQuality",
        .binding = &witcher3classic::volumetrics::shadow_quality,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 4.f,
        .label = "Lighting Shadow Quality",
        .section = "Fog Quality",
        .tooltip = "1: 4 samples (previous quality), 2: 9, 3: 16, 4: 25. More samples smooth sun/moon shadows within the fog and reduce sampling artifacts. Increases GPU time without increasing volume memory. Does not change fog density or light strength.",
        .min = 1.f,
        .max = 4.f,
        .format = "%d / 4",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxWater",
        .binding = &witcher3classic::water::mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Water Shading",
        .section = "Water",
        .tooltip = "Native keeps the active water material. Custom replaces above-water absorption, scattering and surface lighting, using the existing waves and reflections. Works with Native or Custom atmospheric fog. Experimental; underwater rendering remains native.",
        .labels = {"Native", "Custom"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxWaterClarity",
        .binding = &witcher3classic::water::clarity,
        .default_value = 0.5f,
        .label = "Water Clarity",
        .section = "Water",
        .tooltip = "Controls suspended-particle scattering in Custom water. 1 uses a 2-metre scattering distance; higher values reveal more of the river bed, while lower values make the water murkier. Surface reflections still follow the viewing angle and current lighting.",
        .min = .25f,
        .max = 4.f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::water::mode != 0.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "SettingsMode",
        .binding = &settings_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Settings Mode",
        .tooltip = "Advanced shows color grading and PsychoV-31 controls.",
        .labels = {"Simple", "Advanced"},
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapper",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = CLASSIC_TONE_MAP_PSYCHOV31,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .labels = {"Vanilla", "PsychoV-31 (Custom)"},
    },
    new renodx::utils::settings::Setting{
        .key = "PeakBrightness",
        .binding = &shader_injection.peak_white_nits,
        .default_value = 1000.f,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the HDR highlight limit in nits. Match this to the peak brightness your monitor or TV can display. Usually detected automatically at startup; adjust if the detected value does not match your display's capabilities. Manual adjustments are preserved; Reset restores the detected peak. Defaults to 1000 nits if detection is unavailable.",
        .min = 203.f,
        .max = 10000.f,
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "GameBrightness",
        .binding = &shader_injection.diffuse_white_nits,
        .default_value = 203.f,
        .label = "Game Brightness",
        .section = "Tone Mapping",
        .tooltip = "Scene reference white in nits. Vanilla uses 203 nits.",
        .min = 48.f,
        .max = 500.f,
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "UIBrightness",
        .binding = &shader_injection.graphics_white_nits,
        .default_value = 203.f,
        .label = "UI Brightness",
        .section = "Tone Mapping",
        .tooltip = "HUD and menu reference white in nits.",
        .min = 48.f,
        .max = 500.f,
    },
    new renodx::utils::settings::Setting{
        .key = "LutGradeStrength",
        .binding = &shader_injection.lut_strength,
        .default_value = 100.f,
        .label = "LUT Grading Strength",
        .section = "Scene Color Grading",
        .tooltip = "Contribution of the native color grading LUTs, including their environment blend and gain. 0 bypasses the LUT grade; 100 uses its full contribution.",
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "LutScaling",
        .binding = &shader_injection.lut_scaling,
        .default_value = 100.f,
        .label = "LUT Scaling",
        .section = "Scene Color Grading",
        .tooltip = "Restores the LUT's black and white range using black, midgray and white samples. 0 preserves native LUT levels; 100 applies full restoration. Can alter intentional weather and cinematic grading. HDR range and wide-gamut preservation remain active at 0.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeStrength",
        .binding = &shader_injection.color_grading_strength,
        .default_value = 100.f,
        .label = "Color Grading Strength",
        .section = "Scene Color Grading",
        .tooltip = "Contribution of the native color grade after LUTs. 0 bypasses the grade; 100 uses its full contribution. Vignette strength remains independent.",
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeExposure",
        .binding = &shader_injection.tone_map_exposure,
        .default_value = 50.f,
        .label = "Exposure",
        .section = "Color Grading",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "Highlights",
        .binding = &shader_injection.tone_map_highlights,
        .default_value = 50.f,
        .label = "Highlights",
        .section = "Color Grading",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "HighlightContrast",
        .binding = &shader_injection.tone_map_highlight_contrast,
        .default_value = 50.f,
        .label = "Highlight Contrast",
        .section = "Color Grading",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "Contrast",
        .binding = &shader_injection.tone_map_contrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Color Grading",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ShadowContrast",
        .binding = &shader_injection.tone_map_shadow_contrast,
        .default_value = 50.f,
        .label = "Shadow Contrast",
        .section = "Color Grading",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "Shadows",
        .binding = &shader_injection.tone_map_shadows,
        .default_value = 50.f,
        .label = "Shadows",
        .section = "Color Grading",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "Saturation",
        .binding = &shader_injection.tone_map_saturation,
        .default_value = 50.f,
        .label = "Saturation",
        .section = "Color Grading",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "HighlightSaturation",
        .binding = &shader_injection.tone_map_highlight_saturation,
        .default_value = 50.f,
        .label = "Highlight Saturation",
        .section = "Color Grading",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "Blowout",
        .binding = &shader_injection.tone_map_blowout,
        .default_value = 0.f,
        .label = "Blowout",
        .section = "Color Grading",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "Flare",
        .binding = &shader_injection.tone_map_flare,
        .default_value = 0.f,
        .label = "Flare",
        .section = "Color Grading",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.0001f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "AdaptationAnchor",
        .binding = &shader_injection.psychov_adaptation_anchor,
        .default_value = 0.18f,
        .label = "Adaptation Anchor",
        .section = "PsychoV-31 (Custom)",
        .min = 0.01f,
        .max = 0.5f,
        .format = "%.4f",
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 1.f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "BackgroundAnchor",
        .binding = &shader_injection.psychov_background_anchor,
        .default_value = 0.18f,
        .label = "Background Anchor",
        .section = "PsychoV-31 (Custom)",
        .min = 0.01f,
        .max = 0.5f,
        .format = "%.4f",
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 1.f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "HighlightHue",
        .binding = &shader_injection.psychov_highlight_hue,
        .default_value = 100.f,
        .label = "Highlight Hue Response",
        .section = "PsychoV-31 (Custom)",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GamutCompression",
        .binding = &shader_injection.psychov_gamut_compression,
        .default_value = 1.f,
        .label = "Gamut Compression",
        .section = "PsychoV-31 (Custom)",
        .min = 0.f,
        .max = 1.f,
        .format = "%.2f",
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 1.f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "Compression",
        .binding = &shader_injection.psychov_compression,
        .default_value = 0.f,
        .label = "Compression (0 = Auto)",
        .section = "PsychoV-31 (Custom)",
        .min = 0.f,
        .max = 5.f,
        .format = "%.2f",
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 1.f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "Gamma",
        .binding = &shader_injection.tone_map_gamma,
        .default_value = 1.f,
        .label = "Gamma",
        .section = "PsychoV-31 (Custom)",
        .min = 0.5f,
        .max = 2.f,
        .format = "%.2f",
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 1.f; },
        .is_visible = [] { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "HDRGamutTarget",
        .binding = &shader_injection.psychov_gamut_compression_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 2.f,
        .label = "HDR Gamut Target",
        .section = "PsychoV-31 (Custom)",
        .labels = {"BT.709", "BT.2020", "Display P3"},
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value == 2.f ? 3.f : value; },
        .is_visible = []() { return settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxMotionBlurMode",
        .binding = &witcher3classic::optics::motion_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Motion Blur",
        .section = "Motion Blur",
        .tooltip = "Replaces native motion blur. Object Only follows visible object movement while excluding camera-only motion. Camera-followed subjects stay sharp. Requires Object Motion enabled in DLSS Tab. Keep native Anti-aliasing enabled.",
        .labels = {"Camera + Object", "Object Only", "Off"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "FxMotionBlurStrength",
        .binding = &witcher3classic::optics::motion_strength,
        .default_value = 50.0f,
        .label = "Motion Blur Strength",
        .section = "Motion Blur",
        .tooltip = "Exposure duration: 0 disables blur, 50 uses 1/60 second, 100 uses 1/30 second. Frame-rate compensated using the vector history interval. Invalid/new history stays sharp.",
        .min = 0.0f,
        .max = 100.0f,
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::motion_mode != 2.f; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxDepthOfFieldMode",
        .binding = &witcher3classic::optics::dof_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Depth of Field",
        .section = "Depth of Field",
        .tooltip = "Custom replaces native depth blur and BlitzFX bokeh with separate foreground/background disk filters after reconstruction. Focus is set by the lens controls below. Native shows the native depth-blur control; Custom shows the lens controls. Off disables depth blur and retains the last controls, grayed out.",
        .labels = {"Native", "Custom", "Off"},
        .is_enabled = &IsCustom,
        .on_change_value = [](float previous, float current) {
          // Store this per preset, including when entering Off from an older
          // preset that predates the remembered-control setting.
          if (current < 2.f || previous < 2.f)
            renodx::utils::settings::FindSetting("FxDepthOfFieldControls")->Set(current < 2.f ? current : previous)->Write();
        },
    },
    new renodx::utils::settings::Setting{
        .key = "FxDepthBlur",
        .binding = &shader_injection.custom_blur,
        .default_value = 50.f,
        .label = "Native Depth Blur",
        .section = "Depth of Field",
        .tooltip = "Depth-blur radius: 0 removes it, 50 is native, 100 doubles it. Requires native Blur. Does not control Motion Blur or Witcher Senses.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::dof_mode == 0.f; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return DepthControlMode() == 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxDepthOfFieldStrength",
        .binding = &witcher3classic::optics::dof_strength,
        .default_value = 50.0f,
        .label = "Depth of Field Strength",
        .section = "Depth of Field",
        .tooltip = "Scales the circle of confusion. 0 keeps the scene sharp; 50 uses the specified lens; 100 doubles its defocus.",
        .min = 0.0f,
        .max = 100.0f,
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::dof_mode == 1.f; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return DepthControlMode() == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxFocusDistance",
        .binding = &witcher3classic::optics::focus_distance,
        .default_value = 20.0f,
        .label = "Focus Distance (m)",
        .section = "Depth of Field",
        .tooltip = "Distance from the camera where objects remain in focus. Background and foreground blur are calculated separately.",
        .min = 0.1f,
        .max = 200.0f,
        .format = "%.2f",
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::dof_mode == 1.f; },
        .is_visible = [] { return DepthControlMode() == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxFocalLength",
        .binding = &witcher3classic::optics::focal_length,
        .default_value = 32.5f,
        .label = "Focal Length (mm)",
        .section = "Depth of Field",
        .tooltip = "Optical focal length for depth of field only; does not change the game camera FOV. Longer lenses produce stronger defocus.",
        .min = 10.0f,
        .max = 200.0f,
        .format = "%.2f",
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::dof_mode == 1.f; },
        .is_visible = [] { return DepthControlMode() == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxAperture",
        .binding = &witcher3classic::optics::aperture,
        .default_value = 2.8f,
        .label = "Aperture (f-number)",
        .section = "Depth of Field",
        .tooltip = "Lower f-numbers give a shallower depth of field. Higher values keep more of the scene sharp.",
        .min = 0.7f,
        .max = 22.0f,
        .format = "%.2f",
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::dof_mode == 1.f; },
        .is_visible = [] { return DepthControlMode() == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxNearBlurStrength",
        .binding = &witcher3classic::optics::near_strength,
        .default_value = 0.0f,
        .label = "Foreground Blur",
        .section = "Depth of Field",
        .tooltip = "Controls foreground coverage independently from background defocus. 0 removes foreground spread; 50 uses Custom coverage.",
        .min = 0.0f,
        .max = 50.0f,
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::dof_mode == 1.f; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = [] { return DepthControlMode() == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxBloomMode",
        .binding = &witcher3classic::optics::bloom_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Bloom Implementation",
        .section = "Bloom",
        .tooltip = "Custom replaces native uniform bloom and BlitzFX Bloom Scattering with its own HDR filter. Native restores their original settings; the Custom strength slider does not alter BlitzFX configuration.",
        .labels = {"Native", "Custom"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "FxBloomSize",
        .binding = &witcher3classic::optics::bloom_size,
        .default_value = 2.0f,
        .label = "Bloom Size",
        .section = "Bloom",
        .tooltip = "Custom enhanced multi-scale Gaussian spread. Larger values use more blur passes and increase GPU cost.",
        .min = 0.1f,
        .max = 3.0f,
        .format = "%.2f",
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::bloom_mode == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxBloomExtraction",
        .binding = &witcher3classic::optics::bloom_extraction,
        .default_value = 3.0f,
        .label = "Bloom Highlight Selection",
        .section = "Bloom",
        .tooltip = "Custom brightness polynomial: 1 includes more low-intensity light; 4 concentrates bloom around highlights. Extended HDR energy is preserved.",
        .min = 1.0f,
        .max = 4.0f,
        .format = "%.2f",
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::bloom_mode == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxBloom",
        .binding = &witcher3classic::optics::bloom_strength,
        .default_value = 15.f,
        .label = "Bloom Strength",
        .section = "Bloom",
        .tooltip = "Custom bloom strength: 0 removes the replacement glow, 50 is reference, 100 doubles it.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::bloom_mode == 1.f; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSunShaftStrength",
        .binding = &shader_injection.custom_sunshafts_strength,
        .default_value = 50.f,
        .label = "Sunshafts Strength",
        .section = "Sunshafts",
        .tooltip = "Scales masked sky input to light shafts. 0 removes it, 50 is reference strength, 100 doubles the input. Requires native Light Shafts. Lens dirt and the replacement bloom are independent.",
        .min = 0.f,
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxLensDirt",
        .binding = &shader_injection.custom_lens_dirt,
        .default_value = 50.f,
        .label = "Lens Dirt",
        .section = "Lens Dirt",
        .tooltip = "Scales the dirt texture in the bloom composite. 0 removes dirt, 50 is reference strength, 100 doubles it. Requires native Camera Lens Effects.",
        .min = 0.f,
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxVignetteBlackFloor",
        .binding = &shader_injection.vignette_black_floor,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Vignette Black Floor",
        .section = "Vignette",
        .tooltip = "Perfect Black darkens without adding a colored black floor. Above strength 50, it darkens progressively while retaining detail under partial vignette masks. Native retains the game's vignette color.",
        .labels = {"Native", "Perfect Black"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "FxVignetteStrength",
        .binding = &shader_injection.vignette_strength,
        .default_value = 50.f,
        .label = "Vignette Strength",
        .section = "Vignette",
        .tooltip = "Scales the game's radial and texture-based vignettes. 0 removes them; 50 uses native strength; 100 doubles the strength. Requires the game's Vignetting option.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpeningMode",
        .binding = &shader_injection.sharpening_mode,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Replace Native Sharpening",
        .section = "Sharpening",
        .tooltip = "Replaces the game's sharpening with Lilium RCAS after DLSS or native TAA. Works with native Sharpening off. Requires the PsychoV tone mapper.",
        .is_enabled = &IsCustom,
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpening",
        .binding = &shader_injection.sharpening_strength,
        .default_value = 0.f,
        .label = "Lilium RCAS Strength",
        .section = "Sharpening",
        .tooltip = "0 disables sharpening while replacement remains active. Higher values enhance detail with noise attenuation. HUD and menu graphics are unaffected.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = [] { return IsCustom() && shader_injection.sharpening_mode != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationMode",
        .binding = &shader_injection.chromatic_aberration_mode,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .label = "Chromatic Aberration",
        .section = "Chromatic Aberration",
        .tooltip = "Native follows the game setting. Custom uses its authored radial lens curve and bounded linear-light filtering after reconstruction; works with native CA disabled.",
        .labels = {"Native", "Custom"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationIntensity",
        .binding = &shader_injection.chromatic_aberration_intensity,
        .default_value = 0.7f,
        .label = "CA Intensity",
        .section = "Chromatic Aberration",
        .tooltip = "0 disables lens distortion and dispersion. 1 uses the reference lens curve. Higher values exaggerate the curve.",
        .min = 0.f,
        .max = 5.f,
        .format = "%.2f",
        .is_enabled = [] { return IsCustom() && shader_injection.chromatic_aberration_mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxFilmGrain",
        .binding = &shader_injection.film_grain,
        .default_value = 0.f,
        .label = "Perceptual Film Grain",
        .section = "Film Grain",
        .tooltip = "Luminance-adaptive grain after reconstruction, sharpening, CA and tone mapping. 0 disables it. HUD and menu graphics are unaffected.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxVideoAutoHDR",
        .binding = &video_auto_hdr,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Video AutoHDR",
        .section = "Video",
        .tooltip = "Expands prerendered SDR video to HDR using BT.2446 Method A. Uses Game Brightness and Peak Brightness; Off or Vanilla preserves the original video colors. Fades and subtitles are preserved.",
        .labels = {"Off", "BT2446A"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All",
        .section = "Options",
        .group = "button-line-1",
        .on_change = []() { renodx::utils::settings::ResetSettings(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Enable HDR in Windows. Set Peak Brightness to match your monitor or TV's peak brightness capability; this is usually detected automatically.",
        .section = "Instructions",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "RenoDX Discord",
        .section = "Links",
        .group = "button-line-2",
        .tint = 0x5865F2,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/", "Ce9bQHQrSV"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "HDR Den Discord",
        .section = "Links",
        .group = "button-line-2",
        .tint = 0x5865F2,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/", "5WZXDpmbpP"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Github",
        .section = "Links",
        .group = "button-line-2",
        .tint = 0x2B3137,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Hartapfel's Ko-Fi",
        .section = "Links",
        .group = "button-line-3",
        .tint = 0xFF5A16,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/hartapfel"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "ShortFuse's Ko-Fi",
        .section = "Links",
        .group = "button-line-3",
        .tint = 0xFF5A16,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/shortfuse"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Game mod by Hartapfel; RenoDX framework by ShortFuse.",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .key = "DisplayPeakStatus",
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Display peak unavailable: default is 1000 nits. Set Peak Brightness manually.",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .key = "FxDepthOfFieldControls",
        .binding = &depth_controls_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .max = 1.f,
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "AADevelopment",
        .binding = &witcher3classic::temporal::mode,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .is_global = true,
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "AAObjectMotion",
        .binding = &witcher3classic::temporal::object_motion,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .is_global = true,
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "ExcludeVegetationMotion",
        .binding = &witcher3classic::temporal::exclude_vegetation,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .is_global = true,
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLSSModel",
        .binding = &witcher3classic::temporal::model,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 3.f,
        .min = 0.f,
        .max = 4.f,
        .is_global = true,
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLSSQuality",
        .binding = &witcher3classic::temporal::quality,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .min = 0.f,
        .max = 4.f,
        .is_global = true,
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "AAObjectVectors",
        .binding = &witcher3classic::temporal::show_object_vectors,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .min = 0.f,
        .max = 5.f,
        .is_global = true,
        .is_visible = [] { return false; },
    },
};
// Preset Off restores native processing and neutral effects; HDR transport
// remains active because the swapchain/resources are upgraded at creation.
void OnPresetOff() {
  renodx::utils::settings::ResetSettings();
  renodx::utils::settings::UpdateSetting("ToneMapper", CLASSIC_TONE_MAP_VANILLA);
  renodx::utils::settings::UpdateSetting("FxVideoAutoHDR", 0.f);
}

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  (void)resize;
  if (detected_peak || !renodx::utils::swapchain::IsDXGI(swapchain)) return;
  const auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
  if (!peak.has_value() || !std::isfinite(peak.value()) || peak.value() <= 0.f) return;
  auto* setting = renodx::utils::settings::FindSetting("PeakBrightness");
  if (setting == nullptr) return;
  const bool using_default_peak = setting->GetValue() == setting->default_value;
  setting->default_value = std::clamp(peak.value(), setting->min, setting->max);
  if (using_default_peak) setting->Set(setting->default_value)->Write();
  renodx::utils::settings::FindSetting("DisplayPeakStatus")->label =
      "Detected display peak: " + std::to_string(static_cast<int>(setting->default_value)) + " nits";
  detected_peak = true;
}

void ShowHint(const char* text) {
  if (!ImGui::IsItemHovered(ImGuiHoveredFlags_DelayShort | ImGuiHoveredFlags_AllowWhenDisabled)) return;
  ImGui::BeginTooltip();
  ImGui::PushTextWrapPos(ImGui::GetFontSize() * 28.f);
  ImGui::TextUnformatted(text);
  ImGui::PopTextWrapPos();
  ImGui::EndTooltip();
}

void ApplyGraphicsPreset(bool improved) {
  std::vector<std::pair<std::string, float>> values;
  for (const auto* setting : settings) {
    if (!setting->key.starts_with("Gfx")) continue;
    // Graphics mode selectors use zero for Native/Off. Custom-only sliders
    // retain the approved defaults while inactive in the vanilla preset.
    values.emplace_back(setting->key,
                        !improved && setting->value_type == renodx::utils::settings::SettingValueType::INTEGER && !setting->labels.empty()
                            ? 0.f
                            : setting->default_value);
  }
  renodx::utils::settings::UpdateSettings(values);
  if (renodx::utils::settings::preset_index != 0)
    renodx::utils::settings::SaveSettings();
}

void DrawAddon(reshade::api::effect_runtime* runtime) {
  if (!ImGui::BeginTabBar("ClassicTabs")) return;
  if (ImGui::BeginTabItem("HDR")) {
    draw_effects = false;
    draw_graphics = false;
    renodx::utils::settings::OnRegisterOverlay(runtime);
    ImGui::EndTabItem();
  }
  if (ImGui::BeginTabItem("Effects")) {
    draw_effects = true;
    draw_graphics = false;
    renodx::utils::settings::OnRegisterOverlay(runtime);
    ImGui::EndTabItem();
  }
  if (ImGui::BeginTabItem("Graphics")) {
    draw_effects = false;
    draw_graphics = true;
    ImGui::BeginDisabled(renodx::utils::settings::preset_index == 0);
    if (ImGui::Button("Vanilla Graphics")) ApplyGraphicsPreset(false);
    ShowHint("Restores native lighting, shadows, player fill, atmospheric fog and water by disabling this tab's overrides. HDR, Effects, DLSS and the game's graphics options are unchanged. Saved to the selected preset; select Preset #1, #2 or #3 to use.");
    ImGui::SameLine();
    if (ImGui::Button("Improved Graphics")) ApplyGraphicsPreset(true);
    ShowHint("Restores the recommended defaults for every setting in this tab, including custom lighting, soft and contact shadows, player fill, fog and water. HDR, Effects and DLSS are unchanged. Saved to the selected preset; select Preset #1, #2 or #3 to use.");
    ImGui::EndDisabled();
    ImGui::Separator();
    renodx::utils::settings::OnRegisterOverlay(runtime);
    ImGui::EndTabItem();
  }
  if (ImGui::BeginTabItem("DLSS")) {
    using namespace witcher3classic::temporal;
    bool changed = false;
    bool enabled = mode != 0.f;
    if (ImGui::Checkbox("Enable DLSS", &enabled))
      changed |= renodx::utils::settings::UpdateSetting("AADevelopment", enabled ? 1.f : 0.f);
    ShowHint("Keep Anti-aliasing enabled in the game. DLSS replaces native AA and automatically bypasses BlitzFX TAA when present. Custom optical effects require the native AA boundary; with them active, Off uses native TAA instead of BlitzFX TAA.");
    ImGui::SeparatorText("Image Quality");
    ImGui::BeginDisabled(!enabled);
    int selected_quality = std::clamp(static_cast<int>(quality), 0, 4);
    const char* qualities[] = {"DLAA", "Quality", "Balanced", "Performance", "Ultra Performance"};
    if (ImGui::Combo("Quality", &selected_quality, qualities, 5))
      changed |= renodx::utils::settings::UpdateSetting("DLSSQuality", static_cast<float>(selected_quality));
    ShowHint("DLAA renders at native resolution. Other modes trade rendering resolution for performance.");
    int selected_model = std::clamp(static_cast<int>(model), 0, 4);
    const char* models[] = {"K", "J", "L", "M", "C"};
    if (ImGui::Combo("Upscaling Model", &selected_model, models, 5))
      changed |= renodx::utils::settings::UpdateSetting("DLSSModel", static_cast<float>(selected_model));
    ShowHint("Requests the selected NVIDIA model. Unsupported models fall back to the DLL default. Driver overrides may take precedence.");
    ImGui::EndDisabled();

    ImGui::BeginDisabled(!enabled);
    ImGui::SeparatorText("Performance");
    bool exclude_foliage = exclude_vegetation != 0.f;
    if (ImGui::Checkbox("Exclude Vegetation from Object Motion (high performance impact)", &exclude_foliage))
      changed |= renodx::utils::settings::UpdateSetting("ExcludeVegetationMotion", exclude_foliage ? 1.f : 0.f);
    ShowHint("Off includes wind and contact bending in motion vectors. On improves performance by using camera motion for vegetation, which can increase ghosting. Other moving objects retain their vectors.");
    ImGui::SeparatorText("Diagnostics");
    int view = std::clamp(static_cast<int>(show_object_vectors), 0, 5);
    const char* views[] = {"Off", "Object Motion / Coverage", "DLSS Motion Vectors", "Depth (Reverse Z)", "History Rejection Mask", "DLSS Input Color"};
    if (ImGui::Combo("Debug View", &view, views, 6))
      changed |= renodx::utils::settings::UpdateSetting("AAObjectVectors", static_cast<float>(view));
    const char* help[] = {
        "Normal output. Keep Off when comparing image quality or performance.",
        "Raw object vectors before depth validation: gray = stationary, color = motion, amber = missing history, dark = no object coverage.",
        "Final camera and object vectors supplied to DLSS: hue = direction, brightness = magnitude, black = stationary. Full brightness at 32 pixels per frame.",
        "Hardware depth supplied to DLSS: bright = near, dark = far. Reverse Z is nonlinear.",
        "Our bias-current-color mask: white = reject history, black = usable history. This is not NVIDIA's internal confidence view.",
        "Scene color supplied to DLSS before reconstruction. Later game effects still affect this display."};
    ShowHint(help[view]);
    if (ImGui::TreeNode("Advanced Diagnostics")) {
      bool objects = object_motion != 0.f;
      if (ImGui::Checkbox("Object Motion", &objects))
        changed |= renodx::utils::settings::UpdateSetting("AAObjectMotion", objects ? 1.f : 0.f);
      ShowHint("Keep enabled for moving characters and objects. Disable only to compare camera-only vectors.");
      if (!resolution_status.empty()) ImGui::TextWrapped("%s", resolution_status.c_str());
      {
        std::lock_guard lock(upscale_engine::state->mutex);
        ImGui::Text("Reconstructed frames: %llu / %llu",
                    static_cast<unsigned long long>(upscale_engine::state->reconstructed_frames),
                    static_cast<unsigned long long>(upscale_engine::state->scaled_frames));
      }
      ImGui::TreePop();
    }
    ImGui::EndDisabled();
    ImGui::SeparatorText("Status");
    ImGui::TextWrapped("%s", enabled ? status.c_str() : "Disabled - Native TAA");
    if (changed) renodx::utils::settings::SaveGlobalSettings();
    ImGui::EndTabItem();
  }
  ImGui::EndTabBar();
}

}  // namespace
extern "C" __declspec(dllexport) constexpr const char* NAME = "The Witcher 3 - Classic RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "Classic 1.32 DX11 HDR with PsychoV-31 (Custom)";
BOOL APIENTRY DllMain(HMODULE module, DWORD reason, LPVOID) {
  if (reason == DLL_PROCESS_ATTACH) {
    if (!reshade::register_addon(module)) return FALSE;
    renodx::utils::settings::global_name = "renodx-thewitcher3classic";
    renodx::utils::settings::use_presets = true;
    // Keep one ordered settings list and the normal preset/reset/save behavior.
    // Video AutoHDR is an HDR conversion option; all optical effects live in Effects.
    for (auto* setting : settings) {
      const bool effect = setting->key.starts_with("Fx") && setting->key != "FxVideoAutoHDR";
      const bool graphics = setting->key.starts_with("Gfx");
      setting->is_visible = [effect, graphics, visible = std::move(setting->is_visible)] {
        return effect == draw_effects && graphics == draw_graphics && (!visible || visible());
      };
    }
    // Gate replacement itself so Off uses native bytecode, without extending
    // the shared injection layout used by the existing HDR/motion shaders.
    for (const auto hash : {0x043049C7u, 0x30C6DAFAu, 0x7542753Bu, 0xA850FB8Du,
                            0x989EB8B2u, 0xDC4FAC37u, 0xDCEB62A5u}) {
      custom_shaders.at(hash).on_replace = [](auto*) { return IsCustom() && video_auto_hdr == 1.f; };
    }
    reshade::register_event<reshade::addon_event::init_swapchain>(&OnInitSwapchain);
    reshade::register_event<reshade::addon_event::init_device>(&witcher3classic::volumetrics::OnInit);
    reshade::register_event<reshade::addon_event::init_device>(&witcher3classic::lighting::OnInit);
    reshade::register_event<reshade::addon_event::destroy_device>(&witcher3classic::volumetrics::OnDestroy);
    reshade::register_event<reshade::addon_event::destroy_device>(&witcher3classic::lighting::OnDestroy);
    reshade::register_event<reshade::addon_event::present>(&witcher3classic::volumetrics::OnPresent);
    reshade::register_event<reshade::addon_event::present>(&witcher3classic::lighting::OnPresent);
    reshade::register_event<reshade::addon_event::init_device>(&OnBloomInitDevice);
    reshade::register_event<reshade::addon_event::bind_render_targets_and_depth_stencil>(&OnMaterialTargets);
    reshade::register_event<reshade::addon_event::destroy_resource_view>(&OnMaterialViewDestroyed);
    reshade::register_event<reshade::addon_event::destroy_device>(&OnBloomDestroyDevice);
    reshade::register_event<reshade::addon_event::present>(&OnBloomPresent);

    // Migrate legacy per-preset DLSS preferences without constructing settings.
    for (auto* setting : settings) {
      if (!setting->is_global || setting->key == "SettingsMode") continue;
      float value;
      if (!reshade::get_config_value(nullptr, renodx::utils::settings::global_name.c_str(), setting->key.c_str(), value)
          && reshade::get_config_value(nullptr, (renodx::utils::settings::global_name + "-preset1").c_str(), setting->key.c_str(), value))
        reshade::set_config_value(nullptr, renodx::utils::settings::global_name.c_str(), setting->key.c_str(), value);
    }

    // Exposure used raw multipliers in the first test build. Migrate stored
    // values once, without reinterpreting an existing neutral 1 as UI value 1.
    for (const auto& suffix : {"-preset1", "-preset2", "-preset3"}) {
      const auto section = renodx::utils::settings::global_name + suffix;
      float exposure;
      if (!reshade::get_config_value(nullptr, section.c_str(), "ColorGradeExposure", exposure)
          && reshade::get_config_value(nullptr, section.c_str(), "Exposure", exposure)) {
        reshade::set_config_value(nullptr, section.c_str(), "ColorGradeExposure",
                                  std::clamp(exposure * 50.f, 0.f, 100.f));
      }
    }

    for (const auto& shader : witcher3classic::temporal::OBJECT_VERTEX_SHADERS) {
      custom_shaders.emplace(shader.hash, renodx::mods::shader::CustomShader{
                                              .crc32 = shader.hash,
                                              .code = shader.code,
                                              .on_replace = &witcher3classic::temporal::OnObjectVertex,
                                              .on_inject = [](auto*) { return false; },
                                          });
    }
    for (const auto& shader : witcher3classic::temporal::OBJECT_PIXEL_SHADERS) {
      custom_shaders.emplace(shader.hash, renodx::mods::shader::CustomShader{
                                              .crc32 = shader.hash,
                                              .code = shader.code,
                                              .on_replace = &witcher3classic::temporal::OnObjectPixel,
                                              .on_inject = [](auto*) { return false; },
                                          });
    }
    for (const auto hash : {0x4E0137BCu, 0xCA115962u, 0x657A6576u, 0x58959EADu,
                            0xB018A95Au, 0x48885E0Du, 0xB73522BBu, 0xAE334616u, 0x249DA2F1u,
                            0x1F3A90A1u, 0x1C74D220u}) custom_shaders.at(hash).on_replace = [](auto*) {
      const auto* frame = witcher3classic::temporal::upscale_engine::active;
      return witcher3classic::blitzfx::runtime_aa && frame
          && frame->plan.width < frame->plan.output_width;
    };
    custom_shaders.at(0x4708B025).on_replace = [](auto*) {
      return witcher3classic::blitzfx::runtime_aa && witcher3classic::temporal::upscale_engine::active;
    };
    custom_shaders.at(0x3EDDC379).on_replace = [](auto*) { return IsCustom() && shader_injection.sharpening_mode != 0.f; };
    custom_shaders.at(0x3EDDC379).on_inject = [](auto*) { return false; };
    custom_shaders.at(0xFBF141A1).on_replace = [](auto*) { return IsCustom() && shader_injection.sharpening_mode != 0.f; };
    custom_shaders.at(0xFBF141A1).on_inject = [](auto*) { return false; };
    custom_shaders.at(0x6ED58557).on_replace = [](auto*) { return IsCustom() && shader_injection.custom_blur != 1.f; };
    for(const auto hash : {0xB4953357u,0xAEE0B973u,0xAE7D5FA8u,0x51F4E5FDu})
      custom_shaders.at(hash).on_inject = &witcher3classic::volumetrics::OnReflectionCapture;
    for (const auto hash : {0x649AF4FAu, 0x5CBEC131u, 0x9F48B203u, 0x1E28F70Eu, 0xA1C06A7Du, 0xC4D2D4F6u,
                            0x114D8828u, 0xA123EB15u, 0x399CBE16u, 0x445EB59Cu, 0x4FC8DAEBu, 0xE276DFB3u}) {
      custom_shaders.at(hash).on_inject = &OnOpticsInject;
      custom_shaders.at(hash).on_drawn = &OnOpticsDrawn;
    }
    custom_shaders.at(0x1A70FFE2).on_replace = [](auto*) { return IsCustom(); };
    custom_shaders.at(0x1A70FFE2).on_inject = [](auto*) { return false; };
    custom_shaders.at(0x9A905454).on_replace = [](auto*) { return IsCustom() && witcher3classic::optics::dof_mode != 0.f; };
    custom_shaders.at(0x9A905454).on_inject = [](auto*) { return false; };
    custom_shaders.at(0x6ED58557).on_draw = [](auto*) { return !IsCustom() || witcher3classic::optics::dof_mode == 0.f; };
    // The BlitzFX composite also writes SV_Depth. Keep that native side effect
    // and the blend/stencil operation when removing its colour contribution.
    custom_shaders.at(0xAE334616).on_replace = [](auto*) {
      const auto* frame = witcher3classic::temporal::upscale_engine::active;
      return IsCustom() || (frame && frame->plan.width < frame->plan.output_width);
    };
    custom_shaders.at(0xAE334616).on_inject = [](auto*) {
      shader_injection.blitz_bloom_active = IsCustom() && witcher3classic::optics::dof_mode != 0.f ? -2.f : 0.f;
      return true;
    };
    custom_shaders.at(0x249DA2F1).on_replace = [](auto*) {
      const auto* frame = witcher3classic::temporal::upscale_engine::active;
      return IsCustom() || (frame && frame->plan.width < frame->plan.output_width);
    };
    custom_shaders.at(0x249DA2F1).on_inject = &OnBlitzComputeInject;
    custom_shaders.at(0x249DA2F1).on_drawn = &OnBlitzComputeDrawn;
    // Lighting must work without the motion-extended VS signature as well.
    const std::array<std::pair<uint32_t,std::span<const uint8_t>>,6> forward_lighting{{
      {0x12B76681u,__0xF3C40010},
      {0x20C1C070u,__0xF3C40011},
      {0x30F033B5u,__0xF3C40012},
      {0x9B839F3Bu,__0xF3C40013},
      {0xB18EC2FBu,__0xF3C40014},
      {0xEB8C3FAEu,__0xF3C40015},
    }};
    for (UINT i=0;i<forward_lighting.size();++i) {
      const auto [hash,code]=forward_lighting[i];
      auto& shader=custom_shaders.at(hash);
      auto previous_replace=shader.on_replace;
      auto previous_inject=shader.on_inject;
      auto previous_drawn=shader.on_drawn;
      shader.on_replace=[previous_replace,i,code](auto* cmd) {
        bool replace=previous_replace ? previous_replace(cmd) : true;
        if(!replace && (witcher3classic::lighting::player_control!=0.f || witcher3classic::lighting::ambient_ao!=0.f))
          witcher3classic::lighting::BindColorOnly(cmd,i,code);
        return replace;
      };
      shader.on_inject=[previous_inject](auto* cmd) {
        bool inject=previous_inject ? previous_inject(cmd) : true;
        if(witcher3classic::lighting::player_control!=0.f || witcher3classic::lighting::ambient_ao!=0.f)
          witcher3classic::lighting::Bind(cmd,false);
        return inject;
      };
      shader.on_drawn=[previous_drawn](auto* cmd) {
        witcher3classic::lighting::OnDrawn(cmd);
        if(previous_drawn)previous_drawn(cmd);
      };
    }
    {
      auto& shader=custom_shaders.at(0xFD1D6FBF);
      auto previous_replace=shader.on_replace;
      auto previous_inject=shader.on_inject;
      auto previous_drawn=shader.on_drawn;
      shader.on_replace=[previous_replace](auto* cmd) {
        return (previous_replace && previous_replace(cmd)) || witcher3classic::lighting::player_control!=0.f || witcher3classic::lighting::ambient_ao!=0.f;
      };
      shader.on_inject=[previous_inject](auto* cmd) {
        bool inject=previous_inject ? previous_inject(cmd) : true;
        if(witcher3classic::lighting::player_control!=0.f || witcher3classic::lighting::ambient_ao!=0.f)
          witcher3classic::lighting::Bind(cmd,false);
        return inject;
      };
      shader.on_drawn=[previous_drawn](auto* cmd) {
        witcher3classic::lighting::OnDrawn(cmd);if(previous_drawn)previous_drawn(cmd);
      };
    }
    renodx::mods::shader::force_pipeline_cloning = true;
    renodx::mods::shader::expected_constant_buffer_index = 13;
    renodx::mods::shader::expected_constant_buffer_space = 0;
    renodx::mods::swapchain::expected_constant_buffer_index = 13;
    renodx::mods::swapchain::expected_constant_buffer_space = 0;
    renodx::mods::swapchain::use_resource_cloning = true;
    renodx::mods::swapchain::SetUseHDR10();
    renodx::mods::swapchain::swap_chain_proxy_vertex_shader = __swap_chain_proxy_vertex_shader;
    renodx::mods::swapchain::swap_chain_proxy_pixel_shader = __swap_chain_proxy_pixel_shader;
    // Full-size scene/LUT/AA surfaces need signed storage after gamut restore.
    // Keep reduced-size bloom/effect buffers in their original formats.
    renodx::mods::swapchain::resource_upgrade_infos.push_back({
        .old_format = reshade::api::format::r11g11b10_float,
        .new_format = reshade::api::format::r16g16b16a16_float,
        .use_resource_view_cloning = true,
        .usage_include = reshade::api::resource_usage::render_target,
        .name = "Classic scene color",
    });
    // Preserve encoded HDR through the full-size scene/UI buffer and final copy.
    renodx::mods::swapchain::resource_upgrade_infos.push_back({
        .old_format = reshade::api::format::r8g8b8a8_unorm,
        .new_format = reshade::api::format::r16g16b16a16_float,
        .use_resource_view_cloning = true,
        .usage_include = reshade::api::resource_usage::render_target,
        .name = "Classic scene color",
    });
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::init_swapchain>(&OnInitSwapchain);
    reshade::unregister_event<reshade::addon_event::init_device>(&witcher3classic::volumetrics::OnInit);
    reshade::unregister_event<reshade::addon_event::init_device>(&witcher3classic::lighting::OnInit);
    reshade::unregister_event<reshade::addon_event::destroy_device>(&witcher3classic::volumetrics::OnDestroy);
    reshade::unregister_event<reshade::addon_event::destroy_device>(&witcher3classic::lighting::OnDestroy);
    reshade::unregister_event<reshade::addon_event::present>(&witcher3classic::volumetrics::OnPresent);
    reshade::unregister_event<reshade::addon_event::present>(&witcher3classic::lighting::OnPresent);
    reshade::unregister_event<reshade::addon_event::init_device>(&OnBloomInitDevice);
    reshade::unregister_event<reshade::addon_event::bind_render_targets_and_depth_stencil>(&OnMaterialTargets);
    reshade::unregister_event<reshade::addon_event::destroy_resource_view>(&OnMaterialViewDestroyed);
    reshade::unregister_event<reshade::addon_event::destroy_device>(&OnBloomDestroyDevice);
    reshade::unregister_event<reshade::addon_event::present>(&OnBloomPresent);
    reshade::unregister_addon(module);
  }
  if (reason == DLL_PROCESS_DETACH)
    reshade::unregister_overlay(renodx::utils::settings::overlay_title.c_str(), DrawAddon);
  renodx::utils::settings::Use(reason, &settings, &OnPresetOff);
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::unregister_overlay(renodx::utils::settings::overlay_title.c_str(), renodx::utils::settings::OnRegisterOverlay);
    reshade::register_overlay(renodx::utils::settings::overlay_title.c_str(), DrawAddon);
  }
  renodx::mods::swapchain::Use(reason, &shader_injection);
  renodx::mods::shader::Use(reason, custom_shaders, &shader_injection);
  witcher3classic::temporal::Use(reason);
  renodx::utils::random::Use(reason, {&shader_injection.random_seed});
  return TRUE;
}
