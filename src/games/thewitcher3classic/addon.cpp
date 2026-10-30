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
#include "./weather_materials.hpp"
#include "./temporal/runtime.hpp"
#include "./volumetrics/runtime.hpp"
#include "./lighting/runtime.hpp"
#include "./darker_nights_runtime.hpp"
#include "./rain/runtime.hpp"
#include "./frame_generation/runtime.hpp"
#include "./frame_generation/factory.hpp"

namespace {
float settings_mode = 0.f;
float video_auto_hdr = 1.f;
bool draw_effects = false;
bool draw_graphics = false;
bool draw_nights = false;
// FG preferences are independent of SR quality and HDR presets.
auto& fg_mode = witcher3classic::frame_generation::mode;
auto& fg_multiplier = witcher3classic::frame_generation::multiplier;
auto& fg_target_fps = witcher3classic::frame_generation::target_fps;
auto& fg_hud_quality = witcher3classic::frame_generation::hud_quality;
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
  witcher3classic::WeatherMaterials weather_materials;
  std::atomic<uint32_t> material_width = 0, material_height = 0;
};
std::atomic<reshade::api::device*> pending_weather_device = nullptr;

// Fallback cleanup if a weather draw is skipped or its copy sequence changes.
// The ordinary path restores immediately after the two native material copies.
// When inactive the command boundary costs just one null atomic load.
inline constexpr auto OnWeatherMaterialBoundary = []<typename Context>(Context& context)
    -> renodx::utils::command_action::CallbackResult<Context> {
  auto* device = pending_weather_device.load(std::memory_order_relaxed);
  if (!device || device != context.cmd_list->get_device()) return {};
  if (auto* data = renodx::utils::data::Get<BloomRouting>(device))
    data->weather_materials.Restore(context.cmd_list);
  pending_weather_device.store(nullptr, std::memory_order_relaxed);
  return {};
};
inline constexpr auto OnWeatherMaterials = []<typename Context>(Context& context)
    -> renodx::utils::command_action::CallbackResult<Context> {
  auto* device = context.cmd_list->get_device();
  if (device->get_api() != reshade::api::device_api::d3d11) return {};
  if (auto* data = renodx::utils::data::Get<BloomRouting>(device)) {
    if (data->weather_materials.Begin(context.cmd_list,
            data->material_width.load(std::memory_order_relaxed),
            data->material_height.load(std::memory_order_relaxed),
            {renodx::utils::resource::GetResourceFromView(device, {data->native_material_views[2].load(std::memory_order_relaxed)}),
             renodx::utils::resource::GetResourceFromView(device, {data->native_material_views[1].load(std::memory_order_relaxed)})}))
      pending_weather_device.store(device, std::memory_order_relaxed);
  }
  return {};
};
bool OnWeatherCopy(reshade::api::command_list* cmd, reshade::api::resource source, reshade::api::resource dest) {
  auto* device = pending_weather_device.load(std::memory_order_relaxed);
  if (!device || device != cmd->get_device()) return false;
  auto* data = renodx::utils::data::Get<BloomRouting>(device);
  if (!data || !data->weather_materials.CopyMaterial(cmd, source, dest, [&] { cmd->copy_resource(source, dest); })) return false;
  if (!data->weather_materials.Pending()) pending_weather_device.store(nullptr, std::memory_order_relaxed);
  return true;
}
bool OnWeatherCopyRegion(reshade::api::command_list* cmd, reshade::api::resource source, uint32_t source_subresource,
                         const reshade::api::subresource_box* source_box, reshade::api::resource dest, uint32_t dest_subresource,
                         const reshade::api::subresource_box* dest_box, reshade::api::filter_mode filter) {
  auto* device = pending_weather_device.load(std::memory_order_relaxed);
  if (!device || device != cmd->get_device()) return false;
  auto* data = renodx::utils::data::Get<BloomRouting>(device);
  if (!data || !data->weather_materials.CopyMaterial(cmd, source, dest, [&] {
        cmd->copy_texture_region(source, source_subresource, source_box, dest, dest_subresource, dest_box, filter);
      })) return false;
  if (!data->weather_materials.Pending()) pending_weather_device.store(nullptr, std::memory_order_relaxed);
  return true;
}

// Detect the executed composite, not merely an installed DLL or compiled PSO.
// The captured BlitzFX composite precedes the native post-filmic effects.
void OnBloomInitDevice(reshade::api::device* device) {
  renodx::utils::data::Create<BloomRouting>(device);
}
void OnBloomDestroyDevice(reshade::api::device* device) {
  if (auto* data = renodx::utils::data::Get<BloomRouting>(device)) data->weather_materials.Restore();
  if (pending_weather_device.load(std::memory_order_relaxed) == device)
    pending_weather_device.store(nullptr, std::memory_order_relaxed);
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
  data->material_width.store(depth.texture.width, std::memory_order_relaxed);
  data->material_height.store(depth.texture.height, std::memory_order_relaxed);
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
void OnBloomPresent(reshade::api::command_queue* queue, reshade::api::swapchain* swapchain,
                    const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  witcher3classic::optics::custom = shader_injection.tone_map_type == CLASSIC_TONE_MAP_PSYCHOV31;
  if (auto* data = renodx::utils::data::Get<BloomRouting>(swapchain->get_device())) {
    if (pending_weather_device.load(std::memory_order_relaxed) == swapchain->get_device()) {
      data->weather_materials.Restore(queue->get_immediate_command_list());
      pending_weather_device.store(nullptr, std::memory_order_relaxed);
    }
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
    {0x910C4B43, {.crc32 = 0x910C4B43, .code = __0x910C4B43}},
    {0x3939C615, {.crc32 = 0x3939C615, .code = __0x3939C615}},
    {0x89760976, {.crc32 = 0x89760976, .code = __0x89760976}},
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
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f || witcher3classic::water::mode != 0.f
            || (witcher3classic::night::enabled == 1.f && witcher3classic::night::installed
                && witcher3classic::night::common_supported && witcher3classic::night::water_ambient != 100.f); },
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
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f || witcher3classic::water::mode != 0.f || (!witcher3classic::blitzfx::runtime_aa && witcher3classic::rain::enabled == 1.f); },
        .on_inject = [](auto* cmd) {
          witcher3classic::volumetrics::OnParticle(cmd);
          if (!witcher3classic::blitzfx::runtime_aa) witcher3classic::rain::OnDraw(cmd);
          return false;
        },
        .on_drawn = [](auto* cmd) { witcher3classic::rain::OnDrawn(cmd); witcher3classic::volumetrics::OnDrawn(cmd); }}},
    {0x22FD7485, {.crc32 = 0x22FD7485, .code = __0x22FD7485,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f; },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    // These read gains from native b12. Default RenoDX injection would replace
    // b13 for every graphics stage, including the paired native VS constants.
    {0xF12E637D, {.crc32 = 0xF12E637D, .code = __0xF12E637D,
        .on_replace = [](auto*) { return witcher3classic::night::enabled == 1.f && witcher3classic::night::installed
            && witcher3classic::night::common_supported
            && (witcher3classic::night::star_brightness != 100.f || witcher3classic::night::sky_haze_brightness != 100.f
                || witcher3classic::night::normalization::current.load(std::memory_order_relaxed) != 0); },
        .on_inject = [](auto*) { return false; }}},
    {0x6F0FF708, {.crc32 = 0x6F0FF708, .code = __0x6F0FF708,
        .on_replace = [](auto*) { return witcher3classic::night::enabled == 1.f && witcher3classic::night::installed
            && witcher3classic::night::common_supported
                && (witcher3classic::night::cloud_brightness != 100.f || witcher3classic::night::normalization::current.load(std::memory_order_relaxed) != 0); },
        .on_inject = [](auto*) { return false; }}},
    {0xC6178ADC, {.crc32 = 0xC6178ADC, .code = __0xC6178ADC,
        .on_replace = [](auto*) { return witcher3classic::night::enabled == 1.f && witcher3classic::night::installed
            && witcher3classic::night::common_supported
                && (witcher3classic::night::cloud_brightness != 100.f || witcher3classic::night::normalization::current.load(std::memory_order_relaxed) != 0); },
        .on_inject = [](auto*) { return false; }}},
    {0xF4B551EC, {.crc32 = 0xF4B551EC, .code = __0xF4B551EC,
        .on_replace = [](auto*) { return witcher3classic::night::enabled == 1.f && witcher3classic::night::installed
            && witcher3classic::night::common_supported
                && (witcher3classic::night::cloud_brightness != 100.f || witcher3classic::night::normalization::current.load(std::memory_order_relaxed) != 0); },
        .on_inject = [](auto*) { return false; }}},
    {0xBC930752, {.crc32 = 0xBC930752, .code = __0xBC930752,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f
            || (witcher3classic::night::enabled == 1.f && witcher3classic::night::installed
                && witcher3classic::night::common_supported && witcher3classic::night::star_brightness != 100.f); },
        .on_inject = &witcher3classic::volumetrics::OnForward,
        .on_drawn = &witcher3classic::volumetrics::OnDrawn}},
    {0x22D1E925, {.crc32 = 0x22D1E925, .code = __0x22D1E925,
        .on_replace = [](auto*) { return witcher3classic::volumetrics::mode != 0.f
            || (witcher3classic::night::enabled == 1.f && witcher3classic::night::installed
                && witcher3classic::night::common_supported
                && (witcher3classic::night::cloud_brightness != 100.f || witcher3classic::night::normalization::current.load(std::memory_order_relaxed) != 0)); },
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
template <std::size_t N>
void ApplyTabPreset(const witcher3classic::presets::Value (&preset)[N], bool custom) {
  std::vector<std::pair<std::string, float>> values;
  for (const auto& value : preset) values.emplace_back(value.key, custom ? value.custom : value.vanilla);
  renodx::utils::settings::UpdateSettings(values);
  witcher3classic::night::Update(renodx::utils::settings::preset_index != 0);
  if (renodx::utils::settings::preset_index != 0) renodx::utils::settings::SaveSettings();
}
void ShowHint(const char* text);

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "GfxPresetButtons",
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .can_reset = false,
        .section = "Presets",
        .on_draw = [] {
          if (ImGui::Button("Vanilla Graphics")) ApplyTabPreset(witcher3classic::presets::graphics, false);
          ShowHint("Applies the original graphics modes. Other tabs and the game's settings stay as they are.");
          ImGui::SameLine();
          if (ImGui::Button("Improved Graphics")) ApplyTabPreset(witcher3classic::presets::graphics, true);
          ShowHint("Applies the recommended graphics settings and saves them to the selected profile.");
          return false;
        },
    },
    new renodx::utils::settings::Setting{
        .key = "NightPresetButtons",
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .can_reset = false,
        .section = "Presets",
        .on_draw = [] {
          if (ImGui::Button("Vanilla")) ApplyTabPreset(witcher3classic::presets::night, false);
          ShowHint("Restores original night lighting and native auto exposure, with regional normalization and exposure overrides off. Saves to the selected profile.");
          ImGui::SameLine();
          if (ImGui::Button("Darker")) ApplyTabPreset(witcher3classic::presets::night, true);
          ShowHint("Applies the darker-night values, regional normalization and smoothed exposure, reaching full darkness at 21.5 h. Saves to the selected profile.");
          return false;
        },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxLighting",
        .binding = &witcher3classic::lighting::shading,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxLighting"),
        .label = "Surface Lighting",
        .section = "Lighting",
        .tooltip = "Custom improves how surfaces respond to sunlight, moonlight and nearby lights. Native uses the game's original lighting.",
        .labels = {"Native", "Custom PBR"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxAmbientAO",
        .binding = &witcher3classic::lighting::ambient_ao,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxAmbientAO"),
        .label = "Ambient Occlusion Influence",
        .section = "Lighting",
        .tooltip = "Ambient Only keeps directly lit areas brighter while preserving dark creases and contact shading.",
        .labels = {"Native", "Ambient Only"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxSoftShadows",
        .binding = &witcher3classic::lighting::soft_shadows,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxSoftShadows"),
        .label = "Directional Shadows",
        .section = "Shadows",
        .tooltip = "Custom makes sun and moon shadows soften with distance from the object casting them. Native keeps the original shadows.",
        .labels = {"Native", "Custom Soft Shadows"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxSunDiameter",
        .binding = &witcher3classic::lighting::sun_diameter,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxSunDiameter"),
        .label = "Light Angular Diameter",
        .section = "Shadows",
        .tooltip = "Larger values make sun and moon shadows softer. This changes shadow softness, not the visible size of the sun or moon.",
        .min = 0.05f,
        .max = 2.0f,
        .format = "%.3f degrees",
        .is_enabled = [] { return witcher3classic::lighting::soft_shadows != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxContactShadows",
        .binding = &witcher3classic::lighting::contact_shadows,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxContactShadows"),
        .label = "Contact Shadows",
        .section = "Shadows",
        .tooltip = "Adds small shadows where visible objects meet, helping feet, grass and surface details look more grounded.",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxContactLength",
        .binding = &witcher3classic::lighting::contact_length,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxContactLength"),
        .label = "Contact Shadow Reach",
        .section = "Shadows",
        .tooltip = "How far contact shadows can extend, in metres. Larger values reach farther but may reveal artifacts near screen edges.",
        .min = 0.05f,
        .max = 1.0f,
        .format = "%.2f m",
        .is_enabled = [] { return witcher3classic::lighting::contact_shadows != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxPlayerFill",
        .binding = &witcher3classic::lighting::player_control,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxPlayerFill"),
        .label = "Player Fill Light",
        .section = "Player Lighting",
        .tooltip = "Lets you adjust the extra light that follows the camera and brightens characters and nearby surfaces. World lights keep their normal strength.",
        .labels = {"Native", "Custom"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxPlayerStrength",
        .binding = &witcher3classic::lighting::player_strength,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxPlayerStrength"),
        .label = "Fill Light Strength",
        .section = "Player Lighting",
        .tooltip = "Brightness of the camera-following fill light. 0 removes it; 1 keeps the game's original strength.",
        .min = 0.0f,
        .max = 1.0f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::lighting::player_control != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxPlayerUnify",
        .binding = &witcher3classic::lighting::player_unify,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxPlayerUnify"),
        .label = "Match Character and World Fill",
        .section = "Player Lighting",
        .tooltip = "Uses the same fill-light strength for characters and their surroundings, reducing the extra brightness on characters.",
        .labels = {"Off", "On"},
        .is_enabled = [] { return witcher3classic::lighting::player_control != 0.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "GfxVolumetrics",
        .binding = &witcher3classic::volumetrics::mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxVolumetrics"),
        .label = "Atmospheric Fog",
        .section = "Volumetric Lighting and Fog",
        .tooltip = "Custom lets sunlight, moonlight and nearby lights illuminate the fog and form visible shafts. It follows the current weather.",
        .labels = {"Native", "Custom"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogDensity",
        .binding = &witcher3classic::volumetrics::density,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogDensity"),
        .label = "Fog Density",
        .section = "Volumetric Lighting and Fog",
        .tooltip = "Amount of fog in the scene. 1 follows the weather; 0 removes it. Higher values make distant objects harder to see.",
        .min = 0.f,
        .max = 4.0f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogSkyDensity",
        .binding = &witcher3classic::volumetrics::sky_density,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogSkyDensity"),
        .label = "Sky Haze Density",
        .section = "Volumetric Lighting and Fog",
        .tooltip = "Amount of haze covering the sky. 1 keeps the game's weather strength; 0 removes it. Separate from ground-level fog.",
        .min = 0.f,
        .max = 4.0f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogStart",
        .binding = &witcher3classic::volumetrics::start_distance,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogStart"),
        .label = "Fog Start Distance",
        .section = "Volumetric Lighting and Fog",
        .tooltip = "Distance from the camera before fog begins, in metres. Increase this to keep nearby objects clearer.",
        .min = 0.f,
        .max = 200.0f,
        .format = "%.0f m",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogLight",
        .binding = &witcher3classic::volumetrics::light_strength,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogLight"),
        .label = "Sun and Moon Scattering",
        .section = "Volumetric Lighting and Fog",
        .tooltip = "Brightness of sunlight and moonlight in the fog. Higher values make light shafts stronger; 0 removes them.",
        .min = 0.f,
        .max = 4.0f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogLocalLight",
        .binding = &witcher3classic::volumetrics::local_light_strength,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogLocalLight"),
        .label = "Local Light Scattering",
        .section = "Volumetric Lighting and Fog",
        .tooltip = "How strongly torches, lamps and other nearby lights illuminate the fog. 0 disables this glow without dimming the lights themselves.",
        .min = 0.f,
        .max = 4.0f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogAnisotropy",
        .binding = &witcher3classic::volumetrics::anisotropy,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogAnisotropy"),
        .label = "Scattering Directionality",
        .section = "Volumetric Lighting and Fog",
        .tooltip = "How strongly fog glows when looking toward a light. Higher values make that glow more focused; 0 spreads it evenly in all directions.",
        .min = 0.f,
        .max = 0.8f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogHeight",
        .binding = &witcher3classic::volumetrics::height_falloff,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogHeight"),
        .label = "Height Falloff",
        .section = "Volumetric Lighting and Fog",
        .tooltip = "How quickly fog thins with height. Higher values keep it closer to the ground; 1 follows the weather and 0 gives an even layer.",
        .min = 0.f,
        .max = 4.0f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "GfxFogRenderer",
        .binding = &witcher3classic::volumetrics::renderer,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogRenderer"),
        .label = "Fog Rendering",
        .section = "Fog Quality",
        .tooltip = "Per-pixel gives cleaner light shafts with less banding. Volume is faster but may show visible steps in the fog.",
        .labels = {"Volume", "Per-pixel"},
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogResolutionQuality",
        .binding = &witcher3classic::volumetrics::resolution_quality,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogResolutionQuality"),
        .label = "Sampling Quality",
        .section = "Fog Quality",
        .tooltip = "Raises fog detail and reduces visible steps. Higher quality uses more GPU power.",
        .min = 1.f,
        .max = 4.f,
        .format = "%d / 4",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogReconstruction",
        .binding = &witcher3classic::volumetrics::reconstruction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogReconstruction"),
        .label = "Lighting Reconstruction",
        .section = "Fog Quality",
        .tooltip = "Smooth softens bands and edges in illuminated fog. Linear is faster but can make those steps more visible.",
        .labels = {"Linear", "Smooth"},
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f && witcher3classic::volumetrics::renderer == 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxFogShadowQuality",
        .binding = &witcher3classic::volumetrics::shadow_quality,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxFogShadowQuality"),
        .label = "Lighting Shadow Quality",
        .section = "Fog Quality",
        .tooltip = "Smooths shadow edges inside the fog, reducing stepping as you move. Higher settings cost more performance.",
        .min = 1.f,
        .max = 4.f,
        .format = "%d / 4",
        .is_enabled = [] { return witcher3classic::volumetrics::mode != 0.f && witcher3classic::volumetrics::renderer == 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GfxWater",
        .binding = &witcher3classic::water::mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxWater"),
        .label = "Water Shading",
        .section = "Water",
        .tooltip = "Custom improves water color, clarity and surface lighting. Native keeps the original appearance. Underwater views keep the game's normal rendering.",
        .labels = {"Native", "Custom"},
    },
    new renodx::utils::settings::Setting{
        .key = "GfxWaterClarity",
        .binding = &witcher3classic::water::clarity,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxWaterClarity"),
        .label = "Water Clarity",
        .section = "Water",
        .tooltip = "How clearly you can see through water. Higher values reveal more of the river bed; lower values make the water murkier.",
        .min = .25f,
        .max = 4.f,
        .format = "%.2f",
        .is_enabled = [] { return witcher3classic::water::mode != 0.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "GfxRefractiveRain",
        .binding = &witcher3classic::rain::enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::graphics, "GfxRefractiveRain"),
        .label = "Refractive Rain",
        .section = "Rain",
        .tooltip = "Makes raindrops bend the view of the scene behind them while keeping their lighting and fade into fog.",
        .is_enabled = [] { return !witcher3classic::blitzfx::runtime_aa; },
    },

    new renodx::utils::settings::Setting{
        .key = "NightLightingEnabled",
        .binding = &witcher3classic::night::enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightLightingEnabled"),
        .label = "Enable Darker Nights",
        .section = "Darker Nights",
        .tooltip = "Applies this tab's controls during your night schedule. Off restores the original night lighting while keeping your chosen values.",
        .labels = {"Off", "On"},
        .is_enabled = [] { return witcher3classic::night::Supported(); },
    },
    new renodx::utils::settings::Setting{
        .key = "NightRegionalNormalization",
        .binding = &witcher3classic::night::normalization::enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightRegionalNormalization"),
        .label = "Normalize Regional Lighting",
        .section = "Normalization",
        .tooltip = "Reduces differences in night brightness between regions while keeping their colors.",
        .labels = {"Off", "On"},
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::normalization::supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightMoonlightIntensity",
        .binding = &witcher3classic::night::moonlight,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightMoonlightIntensity"),
        .label = "Moonlight Intensity",
        .section = "Moon",
        .tooltip = "Strength of moonlight on the world and in fog. 0% removes it; 100% is original strength. The visible moon has its own control.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported(); },
    },
    new renodx::utils::settings::Setting{
        .key = "NightMoonBrightness",
        .binding = &witcher3classic::night::moon_brightness,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightMoonBrightness"),
        .label = "Moon Brightness",
        .section = "Moon",
        .tooltip = "Brightness of the visible moon. 100% keeps its original brightness. This does not change the light it casts on the world.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightMoonSize",
        .binding = &witcher3classic::night::moon_size,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightMoonSize"),
        .label = "Moon Size",
        .section = "Moon",
        .tooltip = "Size of the visible moon. 100% is original size; 200% doubles its diameter.",
        .min = 1.f,
        .max = 500.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightAmbientLight",
        .binding = &witcher3classic::night::ambient_light,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightAmbientLight"),
        .label = "Ambient Light",
        .section = "Ambient Illumination",
        .tooltip = "Soft background light on lit surfaces. Lower values make nights darker; 100% keeps the original lighting.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightAmbientShadow",
        .binding = &witcher3classic::night::ambient_shadow,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightAmbientShadow"),
        .label = "Ambient Light in Shadows",
        .section = "Ambient Illumination",
        .tooltip = "Soft background light in shaded areas. Lower this if objects stay too bright after reducing moonlight.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightReflectionLight",
        .binding = &witcher3classic::night::reflection_light,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightReflectionLight"),
        .label = "Ambient Reflections",
        .section = "Ambient Illumination",
        .tooltip = "Brightness of reflections from the surroundings on lit surfaces. 100% keeps the original strength.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightReflectionShadow",
        .binding = &witcher3classic::night::reflection_shadow,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightReflectionShadow"),
        .label = "Ambient Reflections in Shadows",
        .section = "Ambient Illumination",
        .tooltip = "Brightness of reflections from the surroundings in shaded areas. Lower values darken reflective surfaces in shadow.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightWaterAmbient",
        .binding = &witcher3classic::night::water_ambient,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightWaterAmbient"),
        .label = "Water Ambient Light",
        .section = "Ambient Illumination",
        .tooltip = "Brightness of the water's own background glow at night. Keeps waves, transparency, refraction and direct lighting unchanged.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightFogBrightness",
        .binding = &witcher3classic::night::fog_brightness,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightFogBrightness"),
        .label = "Fog Brightness",
        .section = "Atmosphere",
        .tooltip = "Brightness of the fog's background color. Lower values make it darker without changing how much fog covers the scene.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightHazeBrightness",
        .binding = &witcher3classic::night::haze_brightness,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightHazeBrightness"),
        .label = "Distance Haze Brightness",
        .section = "Atmosphere",
        .tooltip = "Brightness of the haze over distant objects. Lower values darken that haze without changing how far it reaches.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightSkyBrightness",
        .binding = &witcher3classic::night::sky_brightness,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightSkyBrightness"),
        .label = "Sky Brightness",
        .section = "Atmosphere",
        .tooltip = "Brightness of the sky's main colors. Clouds, stars, the moon and sky haze have separate controls.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightSkyHazeBrightness",
        .binding = &witcher3classic::night::sky_haze_brightness,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightSkyHazeBrightness"),
        .label = "Sky Haze Brightness",
        .section = "Atmosphere",
        .tooltip = "Brightness of sky haze and the background glow near the horizon. Lower values darken both without changing haze density.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightCloudBrightness",
        .binding = &witcher3classic::night::cloud_brightness,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightCloudBrightness"),
        .label = "Cloud Brightness",
        .section = "Atmosphere",
        .tooltip = "Brightness of clouds at night. Lower values darken them while keeping their shape and coverage.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightStarBrightness",
        .binding = &witcher3classic::night::star_brightness,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightStarBrightness"),
        .label = "Star Brightness",
        .section = "Atmosphere",
        .tooltip = "Brightness of the stars. 0% hides them; 100% keeps their original brightness.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported() && witcher3classic::night::common_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureAllDay",
        .binding = &witcher3classic::night::exposure::all_day,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightExposureAllDay"),
        .label = "Apply Exposure Overrides All Day",
        .section = "Night Exposure",
        .tooltip = "Applies exposure settings at all hours. Off follows the night schedule. Requires Darker Nights.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return witcher3classic::night::enabled == 1.f && witcher3classic::night::exposure::supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightAutoExposureEnabled",
        .binding = &witcher3classic::night::exposure::enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightAutoExposureEnabled"),
        .label = "Auto Exposure",
        .section = "Night Exposure",
        .tooltip = "Enabled adapts to scene brightness. Off uses Fixed Luminance.",
        .labels = {"Off", "Enabled"},
        .is_enabled = []() { return witcher3classic::night::enabled == 1.f && witcher3classic::night::exposure::supported; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Exposure follows the night schedule unless All Day is enabled. Native keeps the game's response; Smoothed slows changes and limits brightening; Custom unlocks the controls.",
        .section = "Night Exposure",
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureAdaptation",
        .binding = &witcher3classic::night::exposure::adaptation,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightExposureAdaptation"),
        .label = "Adaptation",
        .section = "Night Exposure",
        .tooltip = "Smoothed uses 35% brightening speed, 5% darkening speed and a 5% brightening limit. Custom lets you adjust these values and the darkening limit.",
        .labels = {"Native", "Smoothed", "Custom"},
        .max = 2.f,
        .is_enabled = []() { return witcher3classic::night::enabled == 1.f && witcher3classic::night::exposure::supported; },
        .is_visible = []() { return witcher3classic::night::exposure::enabled == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureBrighteningSpeed",
        .binding = &witcher3classic::night::exposure::brightening_speed,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightExposureBrighteningSpeed"),
        .label = "Brightening Speed",
        .section = "Night Exposure",
        .tooltip = "How quickly exposure lifts darker scenes. 100% = native; lower = slower.",
        .min = 1.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = []() { return witcher3classic::night::enabled == 1.f && witcher3classic::night::exposure::supported; },
        .is_visible = []() { return witcher3classic::night::exposure::enabled == 1.f && witcher3classic::night::exposure::adaptation == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureDarkeningSpeed",
        .binding = &witcher3classic::night::exposure::darkening_speed,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightExposureDarkeningSpeed"),
        .label = "Darkening Speed",
        .section = "Night Exposure",
        .tooltip = "How quickly exposure lowers brighter scenes. 100% = native; lower = slower.",
        .min = 1.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = []() { return witcher3classic::night::enabled == 1.f && witcher3classic::night::exposure::supported; },
        .is_visible = []() { return witcher3classic::night::exposure::enabled == 1.f && witcher3classic::night::exposure::adaptation == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureMaximumBrightening",
        .binding = &witcher3classic::night::exposure::maximum_brightening,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightExposureMaximumBrightening"),
        .label = "Maximum Brightening",
        .section = "Night Exposure",
        .tooltip = "Limits how much dark scenes can brighten. 0% prevents the boost; 100% keeps the game's full range.",
        .max = 100.f,
        .format = "%.0f%%",
        .is_enabled = []() { return witcher3classic::night::enabled == 1.f && witcher3classic::night::exposure::supported; },
        .is_visible = []() { return witcher3classic::night::exposure::enabled == 1.f && witcher3classic::night::exposure::adaptation == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureMaximumDarkening",
        .binding = &witcher3classic::night::exposure::maximum_darkening,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightExposureMaximumDarkening"),
        .label = "Maximum Darkening",
        .section = "Night Exposure",
        .tooltip = "Limits how much bright scenes can darken. 0% prevents the reduction; 100% keeps the game's full range.",
        .max = 100.f,
        .format = "%.0f%%",
        .is_enabled = []() { return witcher3classic::night::enabled == 1.f && witcher3classic::night::exposure::supported; },
        .is_visible = []() { return witcher3classic::night::exposure::enabled == 1.f && witcher3classic::night::exposure::adaptation == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureFixedLuminance",
        .binding = &witcher3classic::night::exposure::fixed_luminance,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightExposureFixedLuminance"),
        .label = "Fixed Luminance",
        .section = "Night Exposure",
        .tooltip = "Sets a constant exposure when Auto Exposure is off. Lower values brighten the image; higher values darken it.",
        .min = 0.001f,
        .max = 10.f,
        .format = "%.3f",
        .is_enabled = []() { return witcher3classic::night::enabled == 1.f && witcher3classic::night::exposure::supported; },
        .is_visible = []() { return witcher3classic::night::exposure::enabled == 0.f; },
        .is_logarithmic = true,
    },
    new renodx::utils::settings::Setting{
        .key = "NightDarkeningStart",
        .binding = &witcher3classic::night::darkening_start,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightDarkeningStart"),
        .label = "Darkening Start",
        .section = "Night Schedule",
        .tooltip = "Game time when lighting starts to fade from its original brightness toward your night settings.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported(); },
    },
    new renodx::utils::settings::Setting{
        .key = "NightFullDarknessStart",
        .binding = &witcher3classic::night::full_darkness_start,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightFullDarknessStart"),
        .label = "Full Darkness Start",
        .section = "Night Schedule",
        .tooltip = "Game time when your night settings reach full strength.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported(); },
    },
    new renodx::utils::settings::Setting{
        .key = "NightFadeOutStart",
        .binding = &witcher3classic::night::fade_out_start,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightFadeOutStart"),
        .label = "Fade-out Start",
        .section = "Night Schedule",
        .tooltip = "Game time when lighting starts to fade from your night settings back to its original brightness.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported(); },
    },
    new renodx::utils::settings::Setting{
        .key = "NightDarkeningEnd",
        .binding = &witcher3classic::night::darkening_end,
        .default_value = witcher3classic::presets::Default(witcher3classic::presets::night, "NightDarkeningEnd"),
        .label = "Darkening End",
        .section = "Night Schedule",
        .tooltip = "Game time when the original lighting is fully restored.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::Supported(); },
    },
    new renodx::utils::settings::Setting{
        .key = "NightScheduleStatus",
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "These times are out of order. Set Start, Full Darkness, Fade-out and End in order, allowing for midnight. Original lighting stays active until the schedule is valid.",
        .section = "Night Schedule",
        .is_visible = [] { return witcher3classic::night::enabled == 1.f && witcher3classic::night::NightSchedule() == 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "SettingsMode",
        .binding = &settings_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Settings Mode",
        .tooltip = "Simple shows the essential controls. Advanced adds more color-grading and tone-mapping options.",
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
        .tooltip = "Vanilla keeps the game's tone mapping. Custom preserves more HDR highlight detail and enables the extra color controls.",
        .labels = {"Vanilla", "PsychoV-31 (Custom)"},
    },
    new renodx::utils::settings::Setting{
        .key = "PeakBrightness",
        .binding = &shader_injection.peak_white_nits,
        .default_value = 1000.f,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Maximum brightness your display can show, in nits. Usually detected automatically; adjust it to match your monitor or TV.",
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
        .tooltip = "Brightness of the game world, in nits. Increase this to make the scene brighter.",
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
        .tooltip = "Brightness of the HUD and menus, in nits. Adjust this separately from the game world.",
        .min = 48.f,
        .max = 500.f,
    },
    new renodx::utils::settings::Setting{
        .key = "LutGradeStrength",
        .binding = &shader_injection.lut_strength,
        .default_value = 100.f,
        .label = "LUT Grading Strength",
        .section = "Scene Color Grading",
        .tooltip = "Strength of the game's color filters, which shape the weather and cinematic look. 0 removes them; 100 keeps their full effect.",
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
        .tooltip = "Restores deeper blacks and brighter whites in the game's color filters. Higher values can change the intended weather or cinematic look.",
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
        .tooltip = "Strength of the game's final color adjustments. 0 removes them; 100 keeps their full effect.",
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
        .tooltip = "Overall scene brightness before tone mapping. 50 keeps the reference exposure; higher values brighten the image.",
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
        .tooltip = "Brightness of bright areas. 50 keeps the reference look.",
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
        .tooltip = "Contrast within bright areas, affecting highlight detail and separation. 50 keeps the reference look.",
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
        .tooltip = "Difference between bright and dark tones. Higher values give a stronger contrast; 50 keeps the reference look.",
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
        .tooltip = "Contrast within dark areas, affecting shadow depth and detail. 50 keeps the reference look.",
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
        .tooltip = "Brightness of dark areas. Increase this to reveal more shadow detail. 50 keeps the reference look.",
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
        .tooltip = "Overall color intensity. 0 gives a black-and-white image; 50 keeps the reference colors.",
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
        .tooltip = "Color intensity in bright areas. Lower values make highlights less colorful; 50 keeps the reference look.",
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
        .tooltip = "Reduces color intensity for a washed-out look. Higher values move colors closer to grey.",
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
        .tooltip = "Deepens the darkest tones near black. 0 leaves them unchanged.",
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
        .tooltip = "Scene brightness treated as the custom tone mapper's reference. 0.18 is the default starting point.",
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
        .tooltip = "How bright that reference appears in the final image. 0.18 keeps the default brightness balance.",
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
        .tooltip = "Higher values keep more of the original color in very bright highlights.",
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
        .tooltip = "Softens colors that exceed the selected color range, helping avoid harsh clipping. 1 applies the full correction; 0 disables it.",
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
        .tooltip = "Controls how strongly bright areas are compressed to fit your display. 0 chooses the amount automatically.",
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
        .tooltip = "Adjusts the brightness balance of middle and dark tones. 1 keeps the reference look.",
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
        .tooltip = "Color range used to keep bright, saturated colors under control. BT.709 is narrower; Display P3 and BT.2020 allow richer colors.",
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
        .tooltip = "Adds blur to movement. Object Only keeps camera movement sharp while blurring moving objects. Requires Object Motion and the game's Anti-aliasing option.",
        .labels = {"Camera + Object", "Object Only", "Off"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "FxMotionBlurStrength",
        .binding = &witcher3classic::optics::motion_strength,
        .default_value = 50.0f,
        .label = "Motion Blur Strength",
        .section = "Motion Blur",
        .tooltip = "Amount of motion blur. 0 removes it; higher values create longer trails. Blur strength stays consistent as frame rate changes.",
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
        .tooltip = "Blurs objects outside the focus distance. Native follows the game's blur; Custom uses the lens controls below. Off disables depth blur.",
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
        .tooltip = "Strength of the game's depth blur. 0 removes it, 50 is original strength, and 100 doubles it. Requires the game's Blur option.",
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
        .tooltip = "Overall strength of Custom depth of field. 0 keeps the scene sharp; 50 uses the selected lens settings.",
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
        .tooltip = "Distance from the camera that stays sharp, in metres. Objects nearer or farther away can blur.",
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
        .tooltip = "Longer values create stronger background blur. This affects depth of field without zooming the camera.",
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
        .tooltip = "Lower values blur the background more. Higher values keep more of the scene in focus.",
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
        .tooltip = "Amount of blur on objects in front of the focus distance. 0 removes it; 50 uses the reference strength.",
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
        .tooltip = "Adds a soft glow around bright areas. Native follows the game; Custom uses the controls below.",
        .labels = {"Native", "Custom"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "FxBloomSize",
        .binding = &witcher3classic::optics::bloom_size,
        .default_value = 2.0f,
        .label = "Bloom Size",
        .section = "Bloom",
        .tooltip = "How far the glow spreads around bright areas. Larger values create a wider glow and cost more performance.",
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
        .tooltip = "Which lights contribute to bloom. Lower values include dimmer areas; higher values concentrate the glow on bright highlights.",
        .min = 1.0f,
        .max = 4.0f,
        .format = "%.2f",
        .is_enabled = [] { return IsCustom() && witcher3classic::optics::bloom_mode == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxBloom",
        .binding = &witcher3classic::optics::bloom_strength,
        .default_value = 5.f,
        .label = "Bloom Strength",
        .section = "Bloom",
        .tooltip = "Brightness of the glow around highlights. 0 removes it; 50 is reference strength and 100 doubles it.",
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
        .tooltip = "Brightness of rays from the sun. 0 removes them; 50 is reference strength. Requires the game's Light Shafts option.",
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
        .tooltip = "Visibility of dirt on the camera lens around bright lights. 0 removes it; 50 is reference strength. Requires Camera Lens Effects.",
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
        .tooltip = "Perfect Black darkens the screen edges without a colored tint. Native keeps the game's vignette color.",
        .labels = {"Native", "Perfect Black"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "FxVignetteStrength",
        .binding = &shader_injection.vignette_strength,
        .default_value = 50.f,
        .label = "Vignette Strength",
        .section = "Vignette",
        .tooltip = "Darkening around the screen edges. 0 removes it; 50 is original strength. Requires the game's Vignetting option.",
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
        .tooltip = "Adds sharpening after anti-aliasing for clearer detail. Works with the game's Sharpening option off; requires the Custom tone mapper.",
        .is_enabled = &IsCustom,
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpening",
        .binding = &shader_injection.sharpening_strength,
        .default_value = 0.f,
        .label = "Lilium RCAS Strength",
        .section = "Sharpening",
        .tooltip = "Amount of added sharpening. Higher values bring out detail but may emphasize noise. HUD and menu text stay unchanged.",
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
        .tooltip = "Adds colored fringes near screen edges. Native follows the game; Custom uses the intensity control below.",
        .labels = {"Native", "Custom"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationIntensity",
        .binding = &shader_injection.chromatic_aberration_intensity,
        .default_value = 0.5f,
        .label = "CA Intensity",
        .section = "Chromatic Aberration",
        .tooltip = "Strength of colored fringes and lens distortion. 0 removes them; 1 uses the reference lens effect.",
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
        .tooltip = "Adds fine film-like texture to the image. 0 removes it; higher values make it more visible. HUD and menus stay clear.",
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
        .tooltip = "Expands the brightness range of prerendered videos for HDR. Off keeps their original appearance. Uses Game Brightness and Peak Brightness.",
        .labels = {"Off", "BT2446A"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All",
        .section = "Options",
        .group = "button-line-1",
        .tooltip = "Restores all settings in the selected profile to their defaults.",
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
        .tooltip = "Opens the RenoDX community for help, discussion and updates.",
        .tint = 0x5865F2,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/", "Ce9bQHQrSV"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "HDR Den Discord",
        .section = "Links",
        .group = "button-line-2",
        .tooltip = "Opens the HDR Den community for HDR help and discussion.",
        .tint = 0x5865F2,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/", "5WZXDpmbpP"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Github",
        .section = "Links",
        .group = "button-line-2",
        .tooltip = "Opens the RenoDX project page, including source code and issue reports.",
        .tint = 0x2B3137,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Hartapfel's Ko-Fi",
        .section = "Links",
        .group = "button-line-3",
        .tooltip = "Opens the support page for the creator of this game mod.",
        .tint = 0xFF5A16,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/hartapfel"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "ShortFuse's Ko-Fi",
        .section = "Links",
        .group = "button-line-3",
        .tooltip = "Opens the support page for the creator of the RenoDX framework.",
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
        .key = "DLSSFGMode",
        .binding = &fg_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .min = 0.f,
        .max = 3.f,
        .is_global = true,
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLSSFGMultiplier",
        .binding = &fg_multiplier,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 2.f,
        .min = 2.f,
        .max = 6.f,
        .is_global = true,
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLSSFGTargetFPS",
        .binding = &fg_target_fps,
        .default_value = 0.f,
        .min = 0.f,
        .max = 1000.f,
        .is_global = true,
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLSSFGHUDQuality",
        .binding = &fg_hud_quality,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .min = 0.f,
        .max = 1.f,
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
  renodx::utils::settings::UpdateSetting("GfxRefractiveRain", 0.f);
  ApplyTabPreset(witcher3classic::presets::night, false);
}

void OnNightPresent(reshade::api::command_queue*, reshade::api::swapchain*,
                    const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  witcher3classic::night::Update(renodx::utils::settings::preset_index != 0);
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


void DrawAddon(reshade::api::effect_runtime* runtime) {
  if (!ImGui::BeginTabBar("ClassicTabs")) return;
  if (ImGui::BeginTabItem("HDR")) {
    draw_nights = false;
    draw_effects = false;
    draw_graphics = false;
    renodx::utils::settings::OnRegisterOverlay(runtime);
    ImGui::EndTabItem();
  }
  if (ImGui::BeginTabItem("Effects")) {
    draw_nights = false;
    draw_effects = true;
    draw_graphics = false;
    renodx::utils::settings::OnRegisterOverlay(runtime);
    ImGui::EndTabItem();
  }
  if (ImGui::BeginTabItem("Graphics")) {
    draw_nights = false;
    draw_effects = false;
    draw_graphics = true;
    renodx::utils::settings::OnRegisterOverlay(runtime);
    ImGui::EndTabItem();
  }
  if (ImGui::BeginTabItem("Darker Nights")) {
    draw_effects = false;
    draw_graphics = false;
    draw_nights = true;
    renodx::utils::settings::OnRegisterOverlay(runtime);
    if (!witcher3classic::night::Supported()) {
      ImGui::TextDisabled("Darker Nights is not available for this game version.");
    } else if (witcher3classic::night::attempted && !witcher3classic::night::installed) {
      ImGui::TextDisabled("Darker Nights could not start. The original lighting is active.");
    } else if (witcher3classic::night::enabled == 1.f) {
      if (witcher3classic::night::common_supported && witcher3classic::night::installed
          && witcher3classic::night::state->common_uploads.load(std::memory_order_relaxed) == 0) {
        ImGui::TextDisabled("Waiting for the game scene...");
      }
      const float hour = witcher3classic::night::state->hour.load(std::memory_order_relaxed);
      if (hour >= 0.f) ImGui::TextDisabled("Game time: %.1f h", hour);
    }
    ImGui::EndTabItem();
  }
  if (ImGui::BeginTabItem("DLSS")) {
    using namespace witcher3classic::temporal;
    bool changed = false;
    bool enabled = mode != 0.f;
    if (ImGui::Checkbox("Enable DLSS", &enabled))
      changed |= renodx::utils::settings::UpdateSetting("AADevelopment", enabled ? 1.f : 0.f);
    ShowHint("Uses DLSS or DLAA to improve image stability and reduce jagged edges. Keep Anti-aliasing enabled in the game's settings.");
    ImGui::SeparatorText("Image Quality");
    ImGui::BeginDisabled(!enabled);
    int selected_quality = std::clamp(static_cast<int>(quality), 0, 4);
    const char* qualities[] = {"DLAA", "Quality", "Balanced", "Performance", "Ultra Performance"};
    if (ImGui::Combo("Quality", &selected_quality, qualities, 5))
      changed |= renodx::utils::settings::UpdateSetting("DLSSQuality", static_cast<float>(selected_quality));
    ShowHint("DLAA gives the clearest image at your display resolution. Quality through Ultra Performance trade some detail for higher frame rates.");
    int selected_model = std::clamp(static_cast<int>(model), 0, 4);
    const char* models[] = {"K", "J", "L", "M", "C"};
    if (ImGui::Combo("Upscaling Model", &selected_model, models, 5))
      changed |= renodx::utils::settings::UpdateSetting("DLSSModel", static_cast<float>(selected_model));
    ShowHint("Selects the NVIDIA image-reconstruction model. Different models may change clarity or ghosting; unsupported choices use the available default.");
    ImGui::EndDisabled();

    ImGui::SeparatorText("Frame Generation");
    ImGui::TextWrapped("%s", witcher3classic::frame_generation::status.load());
    int selected_fg_mode = static_cast<int>(std::clamp(fg_mode, 0.f, 3.f));
    const char* fg_modes[] = {"Off", "Fixed", "Auto", "Dynamic"};
    if (ImGui::Combo("Frame Generation Mode", &selected_fg_mode, fg_modes, 4))
      changed |= renodx::utils::settings::UpdateSetting("DLSSFGMode", static_cast<float>(selected_fg_mode));
    ShowHint("Fixed keeps your chosen multiplier. Auto pauses generation when it would hurt performance; Dynamic adjusts the multiplier toward your target frame rate.");
    if (selected_fg_mode && !witcher3classic::frame_generation::transport_active)
      ImGui::TextWrapped("Frame Generation is unavailable in this session. Check the status above; HDR10 and windowed or borderless display mode are required.");
    if (witcher3classic::frame_generation::transport_active)
      ImGui::TextWrapped("Changes apply during gameplay. Your Frame Generation settings are saved automatically.");
    if (witcher3classic::frame_generation::transport_active)
      ImGui::Text("Last rendered frame: %u displayed frame(s)", witcher3classic::frame_generation::frames_presented.load());
    if (selected_fg_mode == 3 && witcher3classic::frame_generation::transport_active && !witcher3classic::frame_generation::dynamic_supported)
      ImGui::TextWrapped("Dynamic MFG is unavailable on the active NVIDIA runtime. Select Fixed or Auto.");
    ImGui::BeginDisabled(selected_fg_mode == 0);
    if (selected_fg_mode == 3) {
      float target_fps = std::clamp(fg_target_fps, 0.f, 1000.f);
      if (ImGui::SliderFloat("Target Frame Rate", &target_fps, 0.f, 1000.f, target_fps == 0.f ? "Display refresh rate" : "%.0f FPS"))
        changed |= renodx::utils::settings::UpdateSetting("DLSSFGTargetFPS", target_fps);
      ShowHint("Frame rate Dynamic generation aims to reach. 0 follows your display's refresh rate; VSync also uses that refresh rate.");
    } else {
      int selected_multiplier = static_cast<int>(std::clamp(fg_multiplier, 2.f, 6.f)) - 2;
      const char* multipliers[] = {"2x", "3x", "4x", "5x", "6x"};
      if (ImGui::Combo("Frame Multiplier", &selected_multiplier, multipliers,
                        static_cast<int>(std::clamp(witcher3classic::frame_generation::max_multiplier.load(), 2u, 6u)) - 1))
        changed |= renodx::utils::settings::UpdateSetting("DLSSFGMultiplier", static_cast<float>(selected_multiplier + 2));
      ShowHint("Total displayed frames per game-rendered frame. 2x adds one generated frame; 6x adds five. Higher values can improve smoothness but cost more GPU power.");
    }
    int selected_hud_quality = static_cast<int>(std::clamp(fg_hud_quality, 0.f, 1.f));
    const char* hud_qualities[] = {"Standard", "Enhanced HUD"};
    if (ImGui::Combo("HUD Quality", &selected_hud_quality, hud_qualities, 2))
      changed |= renodx::utils::settings::UpdateSetting("DLSSFGHUDQuality", static_cast<float>(selected_hud_quality));
    ShowHint("Enhanced HUD processes the interface separately for clearer generated frames. It costs more performance than Standard.");
    ImGui::EndDisabled();
    ImGui::TextWrapped("Reflex reduces input delay automatically. Frame generation pauses while this menu is open or incompatible visual effects are active.");

    ImGui::BeginDisabled(!enabled);
    ImGui::SeparatorText("Performance");
    bool exclude_foliage = exclude_vegetation != 0.f;
    if (ImGui::Checkbox("Exclude Vegetation from Object Motion (high performance impact)", &exclude_foliage))
      changed |= renodx::utils::settings::UpdateSetting("ExcludeVegetationMotion", exclude_foliage ? 1.f : 0.f);
    ShowHint("Skips tracking wind-blown grass and trees to improve performance. This can leave trails around moving foliage.");
    ImGui::SeparatorText("Diagnostics");
    int view = std::clamp(static_cast<int>(show_object_vectors), 0, 5);
    const char* views[] = {"Off", "Object Motion / Coverage", "DLSS Motion Vectors", "Depth (Reverse Z)", "History Rejection Mask", "DLSS Input Color"};
    if (ImGui::Combo("Debug View", &view, views, 6))
      changed |= renodx::utils::settings::UpdateSetting("AAObjectVectors", static_cast<float>(view));
    const char* help[] = {
        "Shows the normal game image. Use Off for normal gameplay.",
        "Shows tracked object movement: grey is still, color is moving, amber is missing history, and dark areas are untracked.",
        "Shows movement used by DLSS. Colors show direction; brighter areas show faster motion.",
        "Shows distance from the camera: bright areas are near and dark areas are far away.",
        "Shows where older frames are rejected: white uses the new image, while black can reuse previous detail.",
        "Shows the scene before DLSS improves it. Useful for checking the image entering DLSS."};
    ShowHint(help[view]);
    if (ImGui::TreeNode("Advanced Diagnostics")) {
      if (ImGui::Button("Capture Frame Generation Inputs")) {
        witcher3classic::frame_generation::diagnostics::status = "Close this overlay to capture two generated gameplay frames";
        witcher3classic::frame_generation::diagnostics::remaining = 2;
      }
      ShowHint("Saves diagnostic images and data for troubleshooting frame generation. Briefly pauses rendering.");
      ImGui::TextWrapped("%s", witcher3classic::frame_generation::diagnostics::status.load());
      bool objects = object_motion != 0.f;
      if (ImGui::Checkbox("Object Motion", &objects))
        changed |= renodx::utils::settings::UpdateSetting("AAObjectMotion", objects ? 1.f : 0.f);
      ShowHint("Tracks moving characters and objects to reduce ghosting. Leave On for normal gameplay.");
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
#if __has_include("../../../bin/streamline-2.14.16/include/sl.h")
    witcher3classic::frame_generation::output_constants=&shader_injection;
    reshade::register_event<reshade::addon_event::init_device>(&witcher3classic::frame_generation::factory::OnInitDevice);
    reshade::register_event<reshade::addon_event::destroy_device>(&witcher3classic::frame_generation::factory::OnDestroyDevice);
#endif
    for (const auto& [hash,code] : witcher3classic::frame_generation::ui_shaders) {
      custom_shaders.emplace(hash, renodx::mods::shader::CustomShader{
          .crc32=hash, .code=code,
          .on_replace=&witcher3classic::frame_generation::OnUI,
          .on_inject=[](auto*) { return false; },
          .on_drawn=&witcher3classic::frame_generation::OnUIDrawn});
    }
    renodx::utils::settings::global_name = "renodx-thewitcher3classic";
    renodx::utils::settings::use_presets = true;
    // Keep one ordered settings list and the normal preset/reset/save behavior.
    // Video AutoHDR is an HDR conversion option; all optical effects live in Effects.
    for (auto* setting : settings) {
      const bool effect = setting->key.starts_with("Fx") && setting->key != "FxVideoAutoHDR";
      const bool graphics = setting->key.starts_with("Gfx");
      const bool night = setting->key.starts_with("Night");
      setting->is_visible = [effect, graphics, night, visible = std::move(setting->is_visible)] {
        return effect == draw_effects && graphics == draw_graphics && night == draw_nights && (!visible || visible());
      };
    }
    // Gate replacement itself so Off uses native bytecode, without extending
    // the shared injection layout used by the existing HDR/motion shaders.
    for (const auto hash : {0x043049C7u, 0x30C6DAFAu, 0x7542753Bu, 0xA850FB8Du,
                            0x989EB8B2u, 0xDC4FAC37u, 0xDCEB62A5u}) {
      custom_shaders.at(hash).on_replace = [](auto*) { return IsCustom() && video_auto_hdr == 1.f; };
    }
    reshade::register_event<reshade::addon_event::init_swapchain>(&OnInitSwapchain);
    reshade::register_event<reshade::addon_event::present>(&OnNightPresent);
    reshade::register_event<reshade::addon_event::init_device>(&witcher3classic::rain::OnInit);
    reshade::register_event<reshade::addon_event::destroy_device>(&witcher3classic::rain::OnDestroy);
    reshade::register_event<reshade::addon_event::init_resource>(&witcher3classic::rain::OnInitResource);
    reshade::register_event<reshade::addon_event::update_texture_region>(&witcher3classic::rain::OnUpdateTexture);
    reshade::register_event<reshade::addon_event::destroy_resource>(&witcher3classic::rain::OnDestroyResource);
    reshade::register_event<reshade::addon_event::init_device>(&witcher3classic::night::OnInit);
    reshade::register_event<reshade::addon_event::destroy_device>(&witcher3classic::night::OnDestroy);
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
    reshade::register_event<reshade::addon_event::copy_resource>(&OnWeatherCopy);
    reshade::register_event<reshade::addon_event::copy_texture_region>(&OnWeatherCopyRegion);
    renodx::utils::command_action::Register(OnWeatherMaterialBoundary, {});
    renodx::utils::command_action::Register(OnWeatherMaterials, {
        .shader_hash = 0x5D7114F1u,
        .command_types = renodx::utils::command_action::COMMAND_TYPE_DIRECT_DRAW});

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
    // Restrict shared mesh permutations to their audited moon pixel partners.
    for (const auto& [vertex, pixel] : {std::pair{0x910C4B43u, 0x8C9C55ECu}, std::pair{0x3939C615u, 0x89760976u}}) {
      auto& moon_vertex = custom_shaders.at(vertex);
      moon_vertex.on_replace = [pixel](auto* cmd) {
        return witcher3classic::night::installed && witcher3classic::night::common_supported
            && witcher3classic::night::enabled == 1.f && witcher3classic::night::moon_size != 100.f
            && renodx::utils::shader::GetCurrentPixelShaderHash(renodx::utils::shader::GetCurrentState(cmd)) == pixel;
      };
      moon_vertex.on_inject = [](auto*) { return false; };
      auto& moon_pixel = custom_shaders.at(pixel);
      auto previous_replace = moon_pixel.on_replace;
      auto previous_inject = moon_pixel.on_inject;
      auto previous_drawn = moon_pixel.on_drawn;
      moon_pixel.on_replace = [vertex, previous_replace](auto* cmd) {
        return (previous_replace && previous_replace(cmd))
            || (witcher3classic::night::installed && witcher3classic::night::common_supported
                && witcher3classic::night::enabled == 1.f && witcher3classic::night::moon_brightness != 100.f
                && renodx::utils::shader::GetCurrentVertexShaderHash(renodx::utils::shader::GetCurrentState(cmd)) == vertex);
      };
      moon_pixel.on_inject = [pixel, previous_inject](auto* cmd) {
        bool inject = previous_inject ? previous_inject(cmd) : false;
        if (pixel == 0x8C9C55ECu) witcher3classic::night::OnMoonPixel(cmd);
        return inject;
      };
      moon_pixel.on_drawn = [previous_drawn](auto* cmd) {
        witcher3classic::night::OnMoonDrawn(cmd);
        if (previous_drawn) previous_drawn(cmd);
      };
    }
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
        if(!replace && (witcher3classic::lighting::player_control != 0.f || witcher3classic::lighting::ambient_ao!=0.f))
          witcher3classic::lighting::BindColorOnly(cmd,i,code);
        return replace;
      };
      shader.on_inject=[previous_inject](auto* cmd) {
        bool inject=previous_inject ? previous_inject(cmd) : true;
        if(witcher3classic::lighting::player_control != 0.f || witcher3classic::lighting::ambient_ao!=0.f)
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
        return (previous_replace && previous_replace(cmd)) || witcher3classic::lighting::player_control != 0.f || witcher3classic::lighting::ambient_ao!=0.f;
      };
      shader.on_inject=[previous_inject](auto* cmd) {
        bool inject=previous_inject ? previous_inject(cmd) : true;
        if(witcher3classic::lighting::player_control != 0.f || witcher3classic::lighting::ambient_ao!=0.f)
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
    witcher3classic::night::Update(false);
    reshade::unregister_event<reshade::addon_event::present>(&OnNightPresent);
    reshade::unregister_event<reshade::addon_event::init_device>(&witcher3classic::rain::OnInit);
    reshade::unregister_event<reshade::addon_event::destroy_device>(&witcher3classic::rain::OnDestroy);
    reshade::unregister_event<reshade::addon_event::init_resource>(&witcher3classic::rain::OnInitResource);
    reshade::unregister_event<reshade::addon_event::update_texture_region>(&witcher3classic::rain::OnUpdateTexture);
    reshade::unregister_event<reshade::addon_event::destroy_resource>(&witcher3classic::rain::OnDestroyResource);
    reshade::unregister_event<reshade::addon_event::init_device>(&witcher3classic::night::OnInit);
    reshade::unregister_event<reshade::addon_event::destroy_device>(&witcher3classic::night::OnDestroy);
#if __has_include("../../../bin/streamline-2.14.16/include/sl.h")
    reshade::unregister_event<reshade::addon_event::init_device>(&witcher3classic::frame_generation::factory::OnInitDevice);
    reshade::unregister_event<reshade::addon_event::destroy_device>(&witcher3classic::frame_generation::factory::OnDestroyDevice);
#endif
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
    reshade::unregister_event<reshade::addon_event::copy_resource>(&OnWeatherCopy);
    reshade::unregister_event<reshade::addon_event::copy_texture_region>(&OnWeatherCopyRegion);
    renodx::utils::command_action::Unregister(OnWeatherMaterialBoundary);
    renodx::utils::command_action::Unregister(OnWeatherMaterials);
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
  witcher3classic::frame_generation::Use(reason);
  renodx::utils::random::Use(reason, {&shader_injection.random_seed});
  return TRUE;
}
