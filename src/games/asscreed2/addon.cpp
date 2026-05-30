/*
 * Copyright (C) 2026 Vik
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define RENODX_MODS_SWAPCHAIN_VERSION 2

#include <algorithm>
#include <chrono>
#include <thread>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/random.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/windowing.hpp"
#include "./shared.h"

namespace {

renodx::mods::shader::CustomShaders custom_shaders = {
    __ALL_CUSTOM_SHADERS,
};

constexpr uint32_t kVideoShaderHash = 0x947F8B85;

ShaderInjectData shader_injection;
bool fired_on_init_swapchain = false;
bool borderless_resize_pending = false;
uint32_t borderless_resize_attempts = 0;
bool initialized = false;
float transition_limiter_enabled = 1.f;
float transition_limiter_fps = 15.f;
float transition_limiter_seconds = 10.f;
float transition_limiter_draw_threshold = 80.f;
std::chrono::steady_clock::time_point transition_limiter_until = {};
std::chrono::steady_clock::time_point transition_limiter_last_present = {};
std::chrono::steady_clock::time_point video_limiter_last_present = {};
uint32_t frame_draw_count = 0;
uint32_t frame_video_draw_count = 0;
std::chrono::steady_clock::time_point video_playback_until = {};
constexpr float kTransitionLimiterProxyPacingScale = 2.f;
constexpr float kVideoPlaybackLimiterFPS = 30.f;

void StartTransitionLimiter(float seconds = -1.f) {
  if (transition_limiter_enabled == 0.f || transition_limiter_fps <= 0.f) return;

  const float duration_seconds = (seconds >= 0.f) ? seconds : transition_limiter_seconds;
  if (duration_seconds <= 0.f) return;

  auto until = std::chrono::steady_clock::now() + std::chrono::duration_cast<std::chrono::steady_clock::duration>(
                                                    std::chrono::duration<float>(duration_seconds));
  transition_limiter_until = std::max(transition_limiter_until, until);
}

void ApplyTransitionLimiter() {
  if (transition_limiter_enabled == 0.f || transition_limiter_fps <= 0.f) return;

  const auto now = std::chrono::steady_clock::now();
  if (now >= transition_limiter_until) {
    transition_limiter_last_present = {};
    return;
  }

  const auto frame_time = std::chrono::duration_cast<std::chrono::steady_clock::duration>(
      std::chrono::duration<float>(1.f / (transition_limiter_fps * kTransitionLimiterProxyPacingScale)));

  if (transition_limiter_last_present.time_since_epoch().count() == 0) {
    transition_limiter_last_present = now;
    return;
  }

  const auto next_present = transition_limiter_last_present + frame_time;
  if (now < next_present) {
    std::this_thread::sleep_until(next_present);
  }

  transition_limiter_last_present = std::chrono::steady_clock::now();
}

void ApplyVideoPlaybackLimiter() {
  const auto now = std::chrono::steady_clock::now();
  const auto frame_time = std::chrono::duration_cast<std::chrono::steady_clock::duration>(
      std::chrono::duration<float>(1.f / (kVideoPlaybackLimiterFPS * kTransitionLimiterProxyPacingScale)));

  if (video_limiter_last_present.time_since_epoch().count() == 0) {
    video_limiter_last_present = now;
    return;
  }

  const auto next_present = video_limiter_last_present + frame_time;
  if (now < next_present) {
    std::this_thread::sleep_until(next_present);
  }

  video_limiter_last_present = std::chrono::steady_clock::now();
}

void OnFrameDraw() {
  ++frame_draw_count;
}

bool OnDraw(
    reshade::api::command_list* cmd_list,
    uint32_t vertex_count,
    uint32_t instance_count,
    uint32_t first_vertex,
    uint32_t first_instance) {
  OnFrameDraw();
  return false;
}

bool OnDrawIndexed(
    reshade::api::command_list* cmd_list,
    uint32_t index_count,
    uint32_t instance_count,
    uint32_t first_index,
    int32_t vertex_offset,
    uint32_t first_instance) {
  OnFrameDraw();
  return false;
}

bool OnDrawOrDispatchIndirect(
    reshade::api::command_list* cmd_list,
    reshade::api::indirect_command type,
    reshade::api::resource buffer,
    uint64_t offset,
    uint32_t draw_count,
    uint32_t stride) {
  OnFrameDraw();
  return false;
}

bool OnVideoDraw(reshade::api::command_list* cmd_list) {
  ++frame_video_draw_count;
  video_playback_until = std::chrono::steady_clock::now() + std::chrono::milliseconds(500);
  return true;
}

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "ToneMapType",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 2.f,
        .can_reset = true,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Sets the tone mapper type.",
        .labels = {"Vanilla", "None", "Neutwo"},
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapPeakNits",
        .binding = &shader_injection.peak_white_nits,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of peak white in nits.",
        .min = 48.f,
        .max = 4000.f,
        .is_enabled = []() { return shader_injection.tone_map_type == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapGameNits",
        .binding = &shader_injection.diffuse_white_nits,
        .default_value = 203.f,
        .label = "Game Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of 100% white in nits.",
        .min = 48.f,
        .max = 500.f,
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapUINits",
        .binding = &shader_injection.graphics_white_nits,
        .default_value = 203.f,
        .label = "UI Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the brightness of UI and HUD elements in nits.",
        .min = 48.f,
        .max = 500.f,
    },
    new renodx::utils::settings::Setting{
        .key = "GammaCorrection",
        .binding = &shader_injection.gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "SDR EOTF Emulation",
        .section = "Tone Mapping",
        .tooltip = "Emulates output decoding used on SDR displays.",
        .labels = {"None", "2.2", "BT.1886"},
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueShift",
        .binding = &shader_injection.tone_map_hue_shift,
        .default_value = 0.f,
        .label = "Hue Shift",
        .section = "Tone Mapping",
        .tooltip = "Hue retention strength.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type > 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapBlowout",
        .binding = &shader_injection.tone_map_blowout,
        .default_value = 50.f,
        .label = "Blowout",
        .section = "Tone Mapping",
        .tooltip = "Emulates blowout from per channel tonemapping.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapWhiteClip",
        .binding = &shader_injection.tone_map_white_clip,
        .default_value = 100.f,
        .label = "White Clip",
        .section = "Tone Mapping",
        .tooltip = "Sets the clipping point for the HDR tone mapper.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeExposure",
        .binding = &shader_injection.tone_map_exposure,
        .default_value = 1.f,
        .label = "Exposure",
        .section = "Color Grading",
        .max = 2.f,
        .format = "%.2f",
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlights",
        .binding = &shader_injection.tone_map_highlights,
        .default_value = 55.f,
        .label = "Highlights",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeShadows",
        .binding = &shader_injection.tone_map_shadows,
        .default_value = 50.f,
        .label = "Shadows",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeContrast",
        .binding = &shader_injection.tone_map_contrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeSaturation",
        .binding = &shader_injection.tone_map_saturation,
        .default_value = 50.f,
        .label = "Saturation",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlightSaturation",
        .binding = &shader_injection.tone_map_highlight_saturation,
        .default_value = 50.f,
        .label = "Highlight Saturation",
        .section = "Color Grading",
        .tooltip = "Adds or removes highlight color.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeDechroma",
        .binding = &shader_injection.tone_map_dechroma,
        .default_value = 0.f,
        .label = "Dechroma",
        .section = "Color Grading",
        .tooltip = "Controls highlight desaturation due to overexposure.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeFlare",
        .binding = &shader_injection.tone_map_flare,
        .default_value = 0.f,
        .label = "Flare",
        .section = "Color Grading",
        .tooltip = "Flare/glare compensation.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeScene",
        .binding = &shader_injection.color_grade_strength,
        .default_value = 100.f,
        .label = "Scene Grading",
        .section = "Color Grading",
        .tooltip = "Scene grading as applied by the game.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeSceneScaling",
        .binding = &shader_injection.color_grade_scaling,
        .default_value = 100.f,
        .label = "Scene Grading Scaling",
        .section = "Color Grading",
        .tooltip = "Scales gamma-space scene grading back toward full range when the LUT crushes shadows or clips highlights.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxGrainStrength",
        .binding = &shader_injection.custom_grain_strength,
        .default_value = 0.f,
        .label = "Film Grain",
        .section = "Effects",
        .tooltip = "Adds post-tonemap film grain when shader hooks call the shared tone mapper.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxVideoAutoHDR",
        .binding = &shader_injection.custom_video_hdr,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Video AutoHDR",
        .section = "Video",
        .tooltip = "Upgrades SDR prerendered video when detected.",
        .labels = {"Off", "BT2446A"},
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "TransitionLimiterEnabled",
        .binding = &transition_limiter_enabled,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Loading Safety Limiter",
        .section = "Stability",
        .tooltip = "Temporarily limits FPS during low-draw loading/transition frames to avoid AC2 DX9 proxy instability.",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .key = "TransitionLimiterFPS",
        .binding = &transition_limiter_fps,
        .default_value = 20.f,
        .label = "Loading Safety FPS",
        .section = "Stability",
        .tooltip = "FPS cap used only while the loading safety limiter is active.",
        .min = 5.f,
        .max = 60.f,
        .is_enabled = []() { return transition_limiter_enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "TransitionLimiterDrawThreshold",
        .binding = &transition_limiter_draw_threshold,
        .default_value = 95.f,
        .label = "Loading Draw Threshold",
        .section = "Stability",
        .tooltip = "Activates the temporary FPS cap when a frame has this many draw calls or fewer. Raise if game crashes during loading sequences; lower if normal gameplay is capped.",
        .min = 1.f,
        .max = 1000.f,
        .is_enabled = []() { return transition_limiter_enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "TransitionLimiterSeconds",
        .binding = &transition_limiter_seconds,
        .default_value = 10.f,
        .label = "Loading Safety Duration",
        .section = "Stability",
        .tooltip = "Seconds to keep the temporary FPS cap active after swapchain/fullscreen transitions.",
        .min = 1.f,
        .max = 30.f,
        .is_enabled = []() { return transition_limiter_enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All",
        .section = "Options",
        .group = "button-line-1",
        .on_change = []() {
          for (auto* setting : settings) {
            if (setting->key.empty()) continue;
            if (!setting->can_reset) continue;
            renodx::utils::settings::UpdateSetting(setting->key, setting->default_value);
          }
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "RenoDX Discord",
        .section = "Links",
        .group = "button-line-2",
        .tint = 0x5865F2,
        .on_change = []() {
          renodx::utils::platform::LaunchURL("https://discord.gg/", "Ce9bQHQrSV");
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "More Mods",
        .section = "Links",
        .group = "button-line-2",
        .tint = 0x2B3137,
        .on_change = []() {
          renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx/wiki/Mods");
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Github",
        .section = "Links",
        .group = "button-line-2",
        .tint = 0x2B3137,
        .on_change = []() {
          renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx");
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
        .section = "About",
    },
};

void OnPresetOff() {
  renodx::utils::settings::UpdateSettings({
      {"ToneMapType", 0.f},
      {"ToneMapPeakNits", 203.f},
      {"ToneMapGameNits", 203.f},
      {"ToneMapUINits", 203.f},
      {"GammaCorrection", 0.f},
      {"ToneMapHueShift", 0.f},
      {"ToneMapBlowout", 50.f},
      {"ToneMapWhiteClip", 100.f},
      {"ColorGradeExposure", 1.f},
      {"ColorGradeHighlights", 50.f},
      {"ColorGradeShadows", 50.f},
      {"ColorGradeContrast", 50.f},
      {"ColorGradeSaturation", 50.f},
      {"ColorGradeHighlightSaturation", 50.f},
      {"ColorGradeDechroma", 0.f},
      {"ColorGradeFlare", 0.f},
      {"ColorGradeScene", 100.f},
      {"ColorGradeSceneScaling", 100.f},
      {"FxGrainStrength", 0.f},
      {"FxVideoAutoHDR", 1.f},
      {"TransitionLimiterEnabled", 1.f},
      {"TransitionLimiterFPS", 20.f},
      {"TransitionLimiterDrawThreshold", 95.f},
      {"TransitionLimiterSeconds", 10.f},
  });
}

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  if (!renodx::utils::swapchain::IsDXGI(swapchain)) return;

  if (!fired_on_init_swapchain) {
    float peak = renodx::utils::swapchain::GetPeakNits(swapchain).value_or(1000.f);
    settings[1]->default_value = peak;
    settings[1]->can_reset = true;

    fired_on_init_swapchain = true;

    borderless_resize_pending = true;
    borderless_resize_attempts = 10;
  }

  StartTransitionLimiter();
}

bool ApplyNativeBorderlessWindow(reshade::api::swapchain* swapchain) {
  if (swapchain == nullptr) return false;
  if (!renodx::utils::swapchain::IsDXGI(swapchain)) return false;

  HWND hwnd = static_cast<HWND>(swapchain->get_hwnd());
  if (hwnd == nullptr) return false;
  if (IsWindow(hwnd) == FALSE) return false;

  RECT monitor_rect = {};
  if (!renodx::utils::windowing::GetMonitorRect(hwnd, &monitor_rect)) return false;

  const auto monitor_width = static_cast<uint32_t>(monitor_rect.right - monitor_rect.left);
  const auto monitor_height = static_cast<uint32_t>(monitor_rect.bottom - monitor_rect.top);
  if (monitor_width == 0 || monitor_height == 0) return false;

  renodx::utils::windowing::RemoveWindowBorder(hwnd);

  const bool positioned = renodx::utils::windowing::SetWindowPositionAndSize(
      hwnd,
      monitor_rect.left,
      monitor_rect.top,
      monitor_width,
      monitor_height,
      SWP_ASYNCWINDOWPOS | SWP_FRAMECHANGED | SWP_SHOWWINDOW | SWP_NOZORDER);

  if (!positioned) return false;

  SendMessage(hwnd, WM_SIZE, SIZE_RESTORED, MAKELPARAM(monitor_width, monitor_height));
  UpdateWindow(hwnd);
  return true;
}

bool OnSetFullscreenState(reshade::api::swapchain* swapchain, bool fullscreen, void* hmonitor) {
  StartTransitionLimiter();

  borderless_resize_pending = true;
  borderless_resize_attempts = 120;

  if (!fullscreen) return false;

  ApplyNativeBorderlessWindow(swapchain);
  return true;
}

void OnPresent(
    reshade::api::command_queue* queue,
    reshade::api::swapchain* swapchain,
    const reshade::api::rect* source_rect,
    const reshade::api::rect* dest_rect,
    uint32_t dirty_rect_count,
    const reshade::api::rect* dirty_rects) {
  const uint32_t draw_count = frame_draw_count;
  const uint32_t video_draw_count = frame_video_draw_count;
  frame_draw_count = 0;
  frame_video_draw_count = 0;

  const bool video_playing = video_draw_count > 0u || std::chrono::steady_clock::now() < video_playback_until;

  if (transition_limiter_enabled != 0.f
      && transition_limiter_draw_threshold > 0.f
      && draw_count > 0u
      && draw_count <= static_cast<uint32_t>(transition_limiter_draw_threshold)
      && !video_playing) {
    StartTransitionLimiter(1.f);
  }

  if (video_playing) {
    transition_limiter_last_present = {};
    ApplyVideoPlaybackLimiter();
  } else {
    video_limiter_last_present = {};
    ApplyTransitionLimiter();
  }

  if (!borderless_resize_pending) return;

  if (ApplyNativeBorderlessWindow(swapchain) || borderless_resize_attempts == 0) {
    borderless_resize_pending = false;
    return;
  }

  --borderless_resize_attempts;
}

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Assassin's Creed II";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      if (!initialized) {
        if (auto it = custom_shaders.find(kVideoShaderHash); it != custom_shaders.end()) {
          it->second.on_draw = &OnVideoDraw;
        }

        if (!custom_shaders.contains(kVideoShaderHash)) {
          custom_shaders[kVideoShaderHash] = {
              .crc32 = kVideoShaderHash,
              .on_replace = [](reshade::api::command_list*) { return false; },
              .on_draw = &OnVideoDraw,
          };
        }

        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;
        renodx::mods::shader::constant_buffer_offset = 50 * 4;

        renodx::mods::swapchain::expected_constant_buffer_index = 13;
        renodx::mods::swapchain::expected_constant_buffer_space = 50;
        renodx::mods::swapchain::prevent_full_screen = false;
        renodx::mods::swapchain::force_screen_tearing = false;
        renodx::mods::swapchain::use_resource_cloning = true;
        renodx::mods::swapchain::set_color_space = false;
        renodx::mods::swapchain::use_device_proxy = true;
        renodx::mods::swapchain::swapchain_proxy_revert_state = true;
        renodx::mods::swapchain::device_proxy_wait_idle_source = true;
        renodx::mods::swapchain::device_proxy_wait_idle_destination = false;
        renodx::mods::swapchain::swap_chain_proxy_shaders = {
            {
                reshade::api::device_api::d3d11,
                {
                    .vertex_shader = __swap_chain_proxy_vertex_shader_dx11,
                    .pixel_shader = __swap_chain_proxy_pixel_shader_dx11,
                },
            },
            {
                reshade::api::device_api::d3d12,
                {
                    .vertex_shader = __swap_chain_proxy_vertex_shader_dx12,
                    .pixel_shader = __swap_chain_proxy_pixel_shader_dx12,
                },
            },
        };
        reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
        reshade::register_event<reshade::addon_event::set_fullscreen_state>(OnSetFullscreenState);
        reshade::register_event<reshade::addon_event::present>(OnPresent);
        reshade::register_event<reshade::addon_event::draw>(OnDraw);
        reshade::register_event<reshade::addon_event::draw_indexed>(OnDrawIndexed);
        reshade::register_event<reshade::addon_event::draw_or_dispatch_indirect>(OnDrawOrDispatchIndirect);

#if 1  // Render Target Upgrades

        renodx::mods::swapchain::resource_upgrade_infos.push_back({
            .old_format = reshade::api::format::b8g8r8x8_unorm,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .ignore_size = false,
            .use_resource_view_cloning = false,
            .use_resource_view_hot_swap = false,
            .aspect_ratio = 16.f / 9.f,
            .aspect_ratio_tolerance = 0.001f,
            .usage_include = reshade::api::resource_usage::render_target,
            .name = "Scene Intermediate",
        });
        
        renodx::mods::swapchain::resource_upgrade_infos.push_back({
            .old_format = reshade::api::format::b8g8r8a8_unorm,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .ignore_size = false,
            .use_resource_view_cloning = false,
            .use_resource_view_hot_swap = false,
            .aspect_ratio = 16.f / 9.f,
            .aspect_ratio_tolerance = 0.001f,
            .usage_include = reshade::api::resource_usage::render_target,
            .name = "Scene Intermediate bloom",
        });

#endif

        initialized = true;
      }

      renodx::utils::random::binds.push_back(&shader_injection.custom_random);
      break;

    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_event<reshade::addon_event::set_fullscreen_state>(OnSetFullscreenState);
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      reshade::unregister_event<reshade::addon_event::draw>(OnDraw);
      reshade::unregister_event<reshade::addon_event::draw_indexed>(OnDrawIndexed);
      reshade::unregister_event<reshade::addon_event::draw_or_dispatch_indirect>(OnDrawOrDispatchIndirect);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);
  renodx::utils::random::Use(fdw_reason);

  return TRUE;
}
