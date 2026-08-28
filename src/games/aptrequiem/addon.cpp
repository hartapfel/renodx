/*
 * Copyright (C) 2024 Carlos Lopez
 * Copyright (C) 2026 Ritsu
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64
#define DEBUG_LEVEL_0

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/random.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/swapchain.hpp"
#include "./shared.h"

namespace {

renodx::mods::shader::CustomShaders custom_shaders = {__ALL_CUSTOM_SHADERS};

ShaderInjectData shader_injection;

bool IsPsychoV() {
  return shader_injection.tone_map_type != 0.f;
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
        .tooltip = "Sets the tone mapper type",
        .labels = {"Vanilla", "PsychoV-30"},
        .parse = [](float value) { return value > 0.f ? 3.f : 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapPeakNits",
        .binding = &shader_injection.peak_white_nits,
        .default_value = 1000.f,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Maximum HDR output brightness in nits.",
        .min = 400.f,
        .max = 4000.f,
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapGameNits",
        .binding = &shader_injection.diffuse_white_nits,
        .default_value = 203.f,
        .label = "Paper White",
        .section = "Tone Mapping",
        .tooltip = "Overrides the game's HDR brightness/paper white in nits.",
        .min = 80.f,
        .max = 500.f,
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapLUTLuminanceCurve",
        .binding = &shader_injection.lut_luminance_curve_strength,
        .default_value = 35.f,
        .label = "LUT Luminance Curve",
        .section = "Tone Mapping",
        .tooltip = "Controls how much of the game's original LUT luminance and contrast response is retained after PsychoV-30. 0% keeps only the LUT's color grading; 100% restores its full luminance curve.",
        .max = 100.f,
        .format = "%.0f%%",
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
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
        .parse = [](float value) { return value * 0.01f; },
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
        .key = "FxFilmGrainType",
        .binding = &shader_injection.custom_film_grain_type,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .label = "Film Grain Type",
        .section = "Effects",
        .tooltip = "Native leaves the game's film grain unchanged. Perceptual replaces it with RenoDX's luminance-aware film grain.",
        .labels = {"Native", "Perceptual"},
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxFilmGrain",
        .binding = &shader_injection.custom_film_grain_strength,
        .default_value = 50.f,
        .label = "Film Grain Strength",
        .section = "Effects",
        .tooltip = "Controls the strength of RenoDX perceptual film grain.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV() && shader_injection.custom_film_grain_type == 1.f; },
        .parse = [](float value) { return value * 0.02f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationType",
        .binding = &shader_injection.custom_chromatic_aberration_type,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .label = "Chromatic Aberration Type",
        .section = "Effects",
        .tooltip = "Native leaves the game's chromatic aberration unchanged. RenoDX replaces it with resolution-independent radial chromatic aberration.",
        .labels = {"Native", "RenoDX"},
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberration",
        .binding = &shader_injection.custom_chromatic_aberration_strength,
        .default_value = 50.f,
        .label = "Chromatic Aberration Strength",
        .section = "Effects",
        .tooltip = "Controls the strength of RenoDX radial RGB lens fringing.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV() && shader_injection.custom_chromatic_aberration_type == 1.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpeningType",
        .binding = &shader_injection.custom_sharpening_type,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .label = "Sharpening Type",
        .section = "Effects",
        .tooltip = "Native leaves the game's sharpening path unchanged. Lilium HDR RCAS enables RenoDX's HDR-aware sharpening.",
        .labels = {"Native", "Lilium HDR RCAS"},
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpening",
        .binding = &shader_injection.custom_sharpness,
        .default_value = 0.f,
        .label = "Sharpening Strength",
        .section = "Effects",
        .tooltip = "Adjusts Lilium's HDR-aware RCAS sharpening strength.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV() && shader_injection.custom_sharpening_type == 1.f; },
        .parse = [](float value) { return value == 0.f ? 0.f : exp2(-(1.f - value * 0.01f)); },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
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
        .label = " - Native HDR MUST BE ENABLED in game!",
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
      {"ToneMapLUTLuminanceCurve", 100.f},
      {"ToneMapHueShift", 0.f},
      {"ColorGradeExposure", 1.f},
      {"ColorGradeGamma", 1.f},
      {"ColorGradeHighlights", 50.f},
      {"ColorGradeShadows", 50.f},
      {"ColorGradeContrast", 50.f},
      {"ColorGradeSaturation", 50.f},
      {"ColorGradeHighlightSaturation", 50.f},
      {"ColorGradeBlowout", 0.f},
      {"ColorGradeFlare", 0.f},
      {"FxFilmGrainType", 0.f},
      {"FxFilmGrain", 50.f},
      {"FxChromaticAberrationType", 0.f},
      {"FxChromaticAberration", 75.f},
      {"FxSharpeningType", 0.f},
      {"FxSharpening", 0.f},
  });
}

bool fired_on_init_swapchain = false;
bool initialized = false;

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  (void)resize;
  if (fired_on_init_swapchain) return;

  auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
  if (!peak.has_value()) return;

  auto* peak_setting = settings[2];
  const bool using_default_peak = peak_setting->GetValue() == peak_setting->default_value;
  peak_setting->default_value = peak.value();
  peak_setting->can_reset = true;

  if (using_default_peak) {
    peak_setting->Set(peak.value())->Write();
  }

  fired_on_init_swapchain = true;
}

bool ShouldInjectPostProcessLayout(
    reshade::api::device* device,
    std::span<const reshade::api::pipeline_layout_param> params) {
  if (device->get_api() != reshade::api::device_api::d3d12) return false;

  // Accept a layout that this addon has already extended. This is the form
  // observed by the init callback after the create callback appends the RenoDX
  // constants.
  for (const auto& param : params) {
    if (param.type != reshade::api::pipeline_layout_param_type::push_constants) continue;
    if (param.push_constants.dx_register_index != 13u) continue;
    if (param.push_constants.dx_register_space != 50u) continue;
    return param.push_constants.count == sizeof(ShaderInjectData) / sizeof(uint32_t);
  }

  // Requiem's post-process shaders use this game root signature. Other root
  // signatures must not be extended indiscriminately because doing so breaks
  // the global DXR layouts used by ray-traced shadows.
  if (params.size() == 19u) return true;

  // The LUT builder uses a separate compute root signature. Identify it by the
  // minimum bindings required by 0x3B2D1EB3 instead of relying on its parameter
  // count, which differs from the post-process layout. Explicitly reject an
  // acceleration-structure layout so the DXR safety invariant remains intact.
  bool has_user_constants = false;
  bool has_exposure = false;
  bool has_lut_uav = false;
  bool has_acceleration_structure = false;

  const auto inspect_range = [&](const reshade::api::descriptor_range& range) {
    if (range.type == reshade::api::descriptor_type::acceleration_structure) {
      has_acceleration_structure = true;
      return;
    }
    if (range.dx_register_space != 0u || range.dx_register_index != 0u || range.count == 0u) return;

    switch (range.type) {
      case reshade::api::descriptor_type::constant_buffer:
        has_user_constants = true;
        break;
      case reshade::api::descriptor_type::shader_resource_view:
        has_exposure = true;
        break;
      case reshade::api::descriptor_type::unordered_access_view:
        has_lut_uav = true;
        break;
      default:
        break;
    }
  };

  for (const auto& param : params) {
    switch (param.type) {
      case reshade::api::pipeline_layout_param_type::descriptor_table:
      case reshade::api::pipeline_layout_param_type::push_descriptors_with_ranges:
        for (uint32_t i = 0; i < param.descriptor_table.count; ++i) {
          inspect_range(param.descriptor_table.ranges[i]);
        }
        break;
      case reshade::api::pipeline_layout_param_type::push_descriptors:
        inspect_range(param.push_descriptors);
        break;
      case reshade::api::pipeline_layout_param_type::descriptor_table_with_static_samplers:
      case reshade::api::pipeline_layout_param_type::push_descriptors_with_static_samplers:
        for (uint32_t i = 0; i < param.descriptor_table_with_static_samplers.count; ++i) {
          inspect_range(param.descriptor_table_with_static_samplers.ranges[i]);
        }
        break;
      default:
        break;
    }
  }

  return !has_acceleration_structure && has_user_constants && has_exposure && has_lut_uav;
}

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX - A Plague Tale: Requiem";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for A Plague Tale: Requiem";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      if (!initialized) {
        renodx::mods::shader::on_create_pipeline_layout = [](auto* device, auto params) {
          return ShouldInjectPostProcessLayout(device, params);
        };
        renodx::mods::shader::on_init_pipeline_layout = [](auto* device, auto, auto params) {
          return ShouldInjectPostProcessLayout(device, params);
        };
        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;
        initialized = true;
      }

      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::utils::random::Use(fdw_reason, {&shader_injection.custom_random});
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  if (fdw_reason == DLL_PROCESS_DETACH) {
    reshade::unregister_addon(h_module);
  }

  return TRUE;
}
