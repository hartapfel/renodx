/*
 * Copyright (C) 2026 Carlos Lopez
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID                   ImU64
#define RENODX_MODS_SWAPCHAIN_VERSION 2

#include <algorithm>
#include <cwchar>
#include <sstream>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/windowing.hpp"
#include "./native_alpha.hpp"
#include "./native_presentation.hpp"
#include "./shared.h"

namespace {

renodx::mods::shader::CustomShaders custom_shaders = {
    __ALL_CUSTOM_SHADERS,
};
ShaderInjectData shader_injection = {
    .output_mode = 1.f,
    .paper_white_nits = 203.f,
    .peak_white_nits = 1000.f,
    .swap_chain_decoding = 1.f,
    .tone_map_type = 1.f,
    .tone_map_exposure = 1.f,
    .tone_map_gamma = 1.f,
    .tone_map_highlights = 1.f,
    .tone_map_shadows = 1.f,
    .tone_map_contrast = 1.f,
    .tone_map_saturation = 1.f,
    .tone_map_highlight_saturation = 1.f,
    .psychov_hue_shift = 2.f,
    .psychov_cone_response_exponent = 1.f,
    .psychov_adaptation_anchor = 0.18f,
    .psychov_background_anchor = 0.18f,
    .psychov_gamut_compression = 1.f,
    .psychov_gamut_compression_mode = 1.f,
    .graphics_white_nits = 203.f,
    .color_filter = 1.f,
    .injection_version = 30.f,
    .white_gradient_intensity = 0.f,
    .video_auto_hdr = 1.f,
};

bool is_brotherhood = false;
bool scene_tonemapped = false;

bool IsUIColorDraw(reshade::api::command_list* cmd_list) {
  shader_injection.ui_premultiplied = 0.f;
  if (cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return false;

  auto* device = reinterpret_cast<IDirect3DDevice9*>(cmd_list->get_native());
  DWORD write_mask = 0;
  DWORD blend_enabled = 0;
  if (FAILED(device->GetRenderState(D3DRS_COLORWRITEENABLE, &write_mask))
      || (write_mask & (D3DCOLORWRITEENABLE_RED | D3DCOLORWRITEENABLE_GREEN | D3DCOLORWRITEENABLE_BLUE)) == 0
      || FAILED(device->GetRenderState(D3DRS_ALPHABLENDENABLE, &blend_enabled))) return false;
  if (blend_enabled == FALSE) return true;

  DWORD source = 0;
  DWORD dest = 0;
  DWORD operation = 0;
  if (FAILED(device->GetRenderState(D3DRS_SRCBLEND, &source))
      || FAILED(device->GetRenderState(D3DRS_DESTBLEND, &dest))
      || FAILED(device->GetRenderState(D3DRS_BLENDOP, &operation))) return false;
  if (source == D3DBLEND_DESTCOLOR || source == D3DBLEND_INVDESTCOLOR
      || dest == D3DBLEND_SRCCOLOR || dest == D3DBLEND_INVSRCCOLOR) return false;
  // These UI hashes also draw the sun/flare into the pre-LUT scene.
  if (!scene_tonemapped && operation == D3DBLENDOP_ADD
      && source == D3DBLEND_ONE && dest == D3DBLEND_ONE) return false;
  shader_injection.ui_premultiplied = source == D3DBLEND_ONE && dest == D3DBLEND_INVSRCALPHA ? 1.f : 0.f;
  return true;
}

bool IsPsychoV() {
  return shader_injection.tone_map_type == 1.f;
}

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "SettingsMode",
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Settings Mode",
        .labels = {"Simple", "Advanced"},
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapType",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .can_reset = false,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Selects the native scene tone mapper.",
        .labels = {"Vanilla", "PsychoV-30"},
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapPeakNits",
        .binding = &shader_injection.peak_white_nits,
        .default_value = 1000.f,
        .can_reset = false,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Display peak brightness in nits. Automatically detected for the default; manual adjustments are preserved. Reset restores the detected peak.",
        .min = 400.f,
        .max = 4000.f,
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapGameNits",
        .binding = &shader_injection.paper_white_nits,
        .default_value = 203.f,
        .label = "Game Brightness",
        .section = "Tone Mapping",
        .tooltip = "Scene reference white in HDR output, independent of HUD brightness.",
        .min = 80.f,
        .max = 500.f,
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapUINits",
        .binding = &shader_injection.graphics_white_nits,
        .default_value = 203.f,
        .label = "UI Brightness",
        .section = "Tone Mapping",
        .tooltip = "Brightness of supported HUD and menu color draws, independent of scene white. Masks and multiplicative draws retain native behavior.",
        .min = 80.f,
        .max = 500.f,
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueShift",
        .binding = &shader_injection.psychov_hue_shift,
        .default_value = 100.f,
        .label = "Hue Shift",
        .section = "Tone Mapping",
        .tooltip = "Shifts PsychoV-30 fire hues away from pink towards orange.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeExposure",
        .binding = &shader_injection.tone_map_exposure,
        .default_value = 1.f,
        .label = "Exposure",
        .section = "Color Grading",
        .max = 2.f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeGamma",
        .binding = &shader_injection.tone_map_gamma,
        .default_value = 1.f,
        .label = "Gamma",
        .section = "Color Grading",
        .min = 0.75f,
        .max = 1.25f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlights",
        .binding = &shader_injection.tone_map_highlights,
        .default_value = 50.f,
        .label = "Highlights",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeShadows",
        .binding = &shader_injection.tone_map_shadows,
        .default_value = 50.f,
        .label = "Shadows",
        .section = "Color Grading",
        .tooltip = "Darkens shadows below 50 and lifts them above 50. Preserves black and the adaptation anchor.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeContrast",
        .binding = &shader_injection.tone_map_contrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeSaturation",
        .binding = &shader_injection.tone_map_saturation,
        .default_value = 50.f,
        .label = "Saturation",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlightSaturation",
        .binding = &shader_injection.tone_map_highlight_saturation,
        .default_value = 50.f,
        .label = "Highlight Saturation",
        .section = "Color Grading",
        .tooltip = "Adds or removes highlight color.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeBlowout",
        .binding = &shader_injection.tone_map_blowout,
        .default_value = 0.f,
        .label = "Blowout",
        .section = "Color Grading",
        .tooltip = "Controls color loss from overexposure.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeFlare",
        .binding = &shader_injection.tone_map_flare,
        .default_value = 0.f,
        .label = "Flare",
        .section = "Color Grading",
        .tooltip = "Flare/glare compensation.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeFilter",
        .binding = &shader_injection.color_filter,
        .default_value = 100.f,
        .label = "Color Filter",
        .section = "Color Grading",
        .tooltip = "Strength of the native scene color grade. 0 removes its color changes; 100 retains the original grade. Preserves graded luminance and scene lighting.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "PsychoVConeResponseExponent",
        .binding = &shader_injection.psychov_cone_response_exponent,
        .default_value = 1.0f,
        .label = "Cone Response Exponent",
        .section = "PsychoV30",
        .tooltip = "Scales the cone response around the LUT-calibrated gray anchor. 1.0 retains the baseline slope.",
        .min = 0.1f,
        .max = 5.f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "PsychoVAdaptationAnchor",
        .binding = &shader_injection.psychov_adaptation_anchor,
        .default_value = 0.18f,
        .label = "Adaptation Anchor",
        .section = "PsychoV30",
        .tooltip = "Scales PsychoV-30's calibrated input anchor. 0.18 preserves the baseline; higher values generally darken the scene. Does not change the calibrated cone slope.",
        .min = 0.01f,
        .max = 0.5f,
        .format = "%.4f",
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "PsychoVBackgroundAnchor",
        .binding = &shader_injection.psychov_background_anchor,
        .default_value = 0.18f,
        .label = "Background Anchor",
        .section = "PsychoV30",
        .tooltip = "Scales PsychoV-30's calibrated output anchor. 0.18 preserves the baseline; higher values generally brighten the scene. Does not change the calibrated cone slope.",
        .min = 0.01f,
        .max = 0.5f,
        .format = "%.4f",
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "PsychoVGamutCompression",
        .binding = &shader_injection.psychov_gamut_compression,
        .default_value = 1.f,
        .label = "Gamut Compression",
        .section = "PsychoV30",
        .tooltip = "Controls PsychoV-30's projection into the selected display gamut.",
        .max = 1.f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "PsychoVGamutCompressionMode",
        .binding = &shader_injection.psychov_gamut_compression_mode,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Gamut Compression Target",
        .section = "PsychoV30",
        .tooltip = "Selects the display gamut used by PsychoV-30's target-volume projection.",
        .labels = {"BT.709", "BT.2020"},
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "PsychoVCompression",
        .binding = &shader_injection.psychov_compression,
        .default_value = 0.f,
        .label = "Compression (0 = Auto)",
        .section = "PsychoV30",
        .tooltip = "0 uses automatic compression with a wider HDR working range and smooth display roll-off. Positive values set PsychoV's response power directly at the selected display peak.",
        .max = 5.f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "WhiteGradientIntensity",
        .binding = &shader_injection.white_gradient_intensity,
        .default_value = 0.f,
        .label = "White Gradient Intensity",
        .section = "Effects",
        .tooltip = "Strength of Brotherhood's white gradient overlay. 0 turns it off; 100 retains the original intensity.",
        .min = 0.f,
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return is_brotherhood; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxVideoAutoHDR",
        .binding = &shader_injection.video_auto_hdr,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Video AutoHDR",
        .section = "Video",
        .tooltip = "Expands prerendered SDR video to HDR using BT.2446 Method A. Uses Game and Peak Brightness; Vanilla keeps the original video colors.",
        .labels = {"Off", "BT2446A"},
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All",
        .section = "Options",
        .group = "button-line-2",
        .on_change = []() { renodx::utils::settings::ResetSettings(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Enable Windows HDR and use 32-bit ReShade with the native DirectX 9 game.",
        .section = "Instructions",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Peak Brightness is detected automatically; adjust if needed. Game and UI Brightness default to 203 nits.",
        .section = "Instructions",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Assassin's Creed II, Brotherhood and Revelations are supported.",
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
};

void OnPresetOff() {
  renodx::utils::settings::UpdateSettings({
      {"ToneMapType", 0.f},
      {"ToneMapPeakNits", 1000.f},
      {"ToneMapGameNits", 203.f},
      {"ToneMapUINits", 203.f},
      {"ToneMapHueShift", 0.f},
      {"PsychoVConeResponseExponent", 1.f},
      {"PsychoVAdaptationAnchor", 0.18f},
      {"PsychoVBackgroundAnchor", 0.18f},
      {"PsychoVGamutCompression", 1.f},
      {"PsychoVGamutCompressionMode", 1.f},
      {"PsychoVCompression", 0.f},
      {"ColorGradeExposure", 1.f},
      {"ColorGradeGamma", 1.f},
      {"ColorGradeHighlights", 50.f},
      {"ColorGradeShadows", 50.f},
      {"ColorGradeContrast", 50.f},
      {"ColorGradeSaturation", 50.f},
      {"ColorGradeHighlightSaturation", 50.f},
      {"ColorGradeBlowout", 0.f},
      {"ColorGradeFlare", 0.f},
      {"ColorGradeFilter", 100.f},
      {"WhiteGradientIntensity", 100.f},
      {"FxVideoAutoHDR", 0.f},
  });
}

bool fired_on_init_swapchain = false;
bool initialized = false;
bool native_borderless_pending = false;

bool OnCreateResource(
    reshade::api::device* device,
    reshade::api::resource_desc& desc,
    reshade::api::subresource_data*,
    reshade::api::resource_usage) {
  if (device->get_api() != reshade::api::device_api::d3d9
      || desc.type != reshade::api::resource_type::texture_2d
      || desc.texture.levels != 1
      || desc.texture.width == 0 || desc.texture.height == 0
      || (desc.texture.width >= 4 && desc.texture.height >= 4)) return false;

  switch (desc.texture.format) {
    case reshade::api::format::bc1_unorm:
    case reshade::api::format::bc2_unorm:
    case reshade::api::format::bc3_unorm:
      break;
    default:
      return false;
  }

  // AC2 requests a single-level 2x16 DXT5 texture during save loading. The
  // native runtime rejects a top level smaller than one 4x4 compression block,
  // then AC2 dereferences the failed CreateTexture result. Each upload already
  // contains whole blocks, so this adds no blocks or retained upload storage.
  std::stringstream message;
  message << "AC2: padding sub-block DX9 texture " << desc.texture.width << "x" << desc.texture.height;
  desc.texture.width = std::max(4u, desc.texture.width);
  desc.texture.height = std::max(4u, desc.texture.height);
  message << " to " << desc.texture.width << "x" << desc.texture.height << " (" << desc.texture.format << ")";
  reshade::log::message(reshade::log::level::info, message.str().c_str());
  return true;
}

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  (void)resize;
  if (swapchain->get_device()->get_api() == reshade::api::device_api::d3d9) {
    // DX9 reports the proxy's forced windowed state immediately after init,
    // which clears the shared fullscreen request before the first present.
    native_borderless_pending = true;
    return;
  }
  if (fired_on_init_swapchain) return;
  // Peak detection belongs to the DX11 presentation proxy.
  if (!renodx::utils::swapchain::IsDXGI(swapchain)) return;

  auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
  if (!peak.has_value()) return;

  auto* peak_setting = renodx::utils::settings::FindSetting("ToneMapPeakNits");
  if (peak_setting == nullptr) return;
  const bool using_default_peak = peak_setting->GetValue() == peak_setting->default_value;
  peak_setting->default_value = std::clamp(peak.value(), peak_setting->min, peak_setting->max);
  peak_setting->can_reset = true;

  if (using_default_peak) {
    peak_setting->Set(peak_setting->default_value)->Write();
  }

  fired_on_init_swapchain = true;
}

void OnPresent(
    reshade::api::command_queue*,
    reshade::api::swapchain* swapchain,
    const reshade::api::rect*,
    const reshade::api::rect*,
    uint32_t,
    const reshade::api::rect*) {
  if (swapchain->get_device()->get_api() != reshade::api::device_api::d3d9) return;
  ac2::native_alpha::expand_lighting = IsPsychoV();
  scene_tonemapped = false;
  if (!native_borderless_pending
      || !renodx::utils::windowing::CanApplyFakeFullscreen(static_cast<HWND>(swapchain->get_hwnd()))) return;

  // Clear before resizing: a device reset can queue another request.
  native_borderless_pending = false;
  if (!renodx::utils::windowing::ApplyFakeFullscreen(
          swapchain, swapchain->get_device()->get_resource_desc(swapchain->get_current_back_buffer()))) {
    native_borderless_pending = true;
  }
}

bool OnCopyTextureRegion(
    reshade::api::command_list* cmd_list,
    reshade::api::resource source,
    uint32_t source_subresource,
    const reshade::api::subresource_box* source_box,
    reshade::api::resource dest,
    uint32_t dest_subresource,
    const reshade::api::subresource_box* dest_box,
    reshade::api::filter_mode filter) {
  if (cmd_list->get_device()->get_api() != reshade::api::device_api::d3d9) return false;

  bool is_swapchain = false;
  renodx::utils::resource::GetResourceInfo(dest, [&](const renodx::utils::resource::ResourceInfo& info) {
    is_swapchain = info.is_swap_chain && info.clone_enabled;
  });
  if (!is_swapchain) return false;

  // The shared copy handler excludes DX9 surfaces. Redirect the game's final
  // StretchRect to the FP16 backbuffer that the DX11 proxy actually presents.
  const auto dest_clone = renodx::utils::resource::upgrade::GetResourceClone(dest);
  if (dest_clone.handle == 0u) return false;
  const auto source_clone = renodx::utils::resource::upgrade::GetResourceClone(source);
  cmd_list->copy_texture_region(
      source_clone.handle != 0u ? source_clone : source, source_subresource, source_box,
      dest_clone, dest_subresource, dest_box, filter);
  return true;
}

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX for Assassin's Creed Ezio Trilogy";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "Native DX9 HDR for Assassin's Creed Ezio Trilogy";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      if (!initialized) {
        is_brotherhood = _wcsicmp(renodx::utils::platform::GetCurrentProcessPath().filename().c_str(), L"ACBSP.exe") == 0;
        custom_shaders.at(0x48DCE479u).on_draw = [](reshade::api::command_list* cmd_list) {
          if (cmd_list->get_device()->get_api() == reshade::api::device_api::d3d9) scene_tonemapped = true;
          return true;
        };
        custom_shaders.at(0xB4D7A117u).on_replace = [](reshade::api::command_list* cmd_list) {
          // The same downsampler is used by post-LUT DOF/Eagle Vision.
          return !scene_tonemapped && cmd_list->get_device()->get_api() == reshade::api::device_api::d3d9;
        };
        for (const auto hash : {0x7258C5E9u, 0x5E3A6B72u, 0xFB5A6594u, 0xAFDE4E3Du}) {
          custom_shaders.at(hash).on_replace = &IsUIColorDraw;
        }
        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;
        // c50-c56 are unused by all nine audited native pixel shaders.
        renodx::mods::shader::constant_buffer_offset = 50 * 4;

        renodx::mods::swapchain::expected_constant_buffer_index = 13;
        renodx::mods::swapchain::expected_constant_buffer_space = 50;
        renodx::mods::swapchain::ignored_device_apis = {
            reshade::api::device_api::d3d10,
            reshade::api::device_api::d3d12,
            reshade::api::device_api::opengl,
            reshade::api::device_api::vulkan,
        };
        renodx::mods::swapchain::SetUseHDR10(true);
        renodx::mods::swapchain::force_screen_tearing = false;
        renodx::mods::swapchain::use_resource_cloning = true;
        // The device proxy owns HDR10 color space; the DX9 host stays native.
        renodx::mods::swapchain::set_color_space = false;
        renodx::mods::swapchain::use_device_proxy = true;
        renodx::mods::swapchain::swapchain_proxy_revert_state = true;
        renodx::mods::swapchain::swap_chain_proxy_format = reshade::api::format::r16g16b16a16_float;
        renodx::mods::swapchain::swap_chain_proxy_shaders = {
            {reshade::api::device_api::d3d11,
             {
                 .vertex_shader = __swap_chain_proxy_vertex_shader,
                 .pixel_shader = __swap_chain_proxy_pixel_shader,
             }},
        };

        // Match scene/bloom/postprocess/HUD targets to the current backbuffer's
        // aspect ratio, including ultrawide resolutions. Rounded bloom levels
        // retain the existing tolerance.
        // DX9 uses direct upgrades for these RTs; dgVoodoo's typeless integer
        // views and their cloning workaround do not apply here.
        for (const auto format : {
                 reshade::api::format::b8g8r8a8_unorm,
                 reshade::api::format::b8g8r8x8_unorm,
             }) {
          renodx::mods::swapchain::resource_upgrade_infos.push_back({
              .old_format = format,
              .new_format = reshade::api::format::r16g16b16a16_float,
              .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
              .aspect_ratio_tolerance = 0.1f,
              .usage_include = reshade::api::resource_usage::render_target,
              .usage_exclude = reshade::api::resource_usage::depth_stencil | reshade::api::resource_usage::unordered_access,
              .name = "Ezio Trilogy Scene / Bloom / Postprocess / HUD",
          });
        }

        reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
        reshade::register_event<reshade::addon_event::create_resource>(OnCreateResource);
        reshade::register_event<reshade::addon_event::present>(OnPresent);
        reshade::register_event<reshade::addon_event::copy_texture_region>(OnCopyTextureRegion);
        initialized = true;
      }
      break;

    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_event<reshade::addon_event::create_resource>(OnCreateResource);
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      reshade::unregister_event<reshade::addon_event::copy_texture_region>(OnCopyTextureRegion);
      reshade::unregister_addon(h_module);
      break;
  }

  ac2::native_presentation::Use(fdw_reason);
  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);
  ac2::native_alpha::Use(fdw_reason, custom_shaders);
  return TRUE;
}
