/*
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

renodx::mods::shader::CustomShaders custom_shaders = {
    CustomShaderEntry(0x01A44DD7),  // Post-process tonemap variant
    CustomShaderEntry(0x0EC16507),  // Post-process tonemap variant
    CustomShaderEntry(0x1561C60A),  // Post-process tonemap variant
    CustomShaderEntry(0x22EA236E),  // Post-process tonemap variant
    CustomShaderEntry(0x240C5BC8),  // Post-process tonemap variant
    CustomShaderEntry(0x2522E2A6),  // Post-process tonemap variant
    CustomShaderEntry(0x297D3D79),  // Post-process tonemap variant
    CustomShaderEntry(0x2984493F),  // Post-process tonemap variant
    CustomShaderEntry(0x2A7E977B),  // Post-process tonemap variant
    CustomShaderEntry(0x2B8E9672),  // Post-process tonemap, chromatic aberration off
    CustomShaderEntry(0x3EC88869),  // Post-process tonemap variant
    CustomShaderEntry(0x44D95606),  // Post-process tonemap with extended grading
    CustomShaderEntry(0x4AD83CEE),  // Post-process tonemap variant
    CustomShaderEntry(0x4F46D1B0),  // Post-process tonemap variant
    CustomShaderEntry(0x533B8B68),  // Post-process tonemap variant
    CustomShaderEntry(0x5B02B51D),  // Post-process tonemap variant
    CustomShaderEntry(0x68FF9BFE),  // Post-process tonemap variant
    CustomShaderEntry(0x6980CFD2),  // Post-process tonemap variant
    CustomShaderEntry(0x6AF21F5C),  // Post-process tonemap variant
    CustomShaderEntry(0x73C4E9D6),  // Post-process tonemap variant
    CustomShaderEntry(0x7D349E9E),  // HDR display transform
    CustomShaderEntry(0x7F0D5698),  // Post-process tonemap variant
    CustomShaderEntry(0x7F37290F),  // Post-process tonemap variant
    CustomShaderEntry(0x8A7F93FE),  // Post-process tonemap variant
    CustomShaderEntry(0x9392A263),  // Post-process tonemap variant
    CustomShaderEntry(0x95D09D91),  // Post-process tonemap variant
    CustomShaderEntry(0x9F37EB1A),  // Post-process tonemap variant
    CustomShaderEntry(0xBB3A11D1),  // Post-process tonemap variant
    CustomShaderEntry(0xCCCA1D32),  // Post-process tonemap variant
    CustomShaderEntry(0xD0330814),  // Post-process tonemap variant
    CustomShaderEntry(0xD2CE7E98),  // Post-process tonemap variant
    CustomShaderEntry(0xD723512C),  // Motion-blur resolve
    CustomShaderEntry(0xD57C5F66),  // Post-process tonemap variant
    CustomShaderEntry(0xD6AA21CB),  // Post-process tonemap variant
    CustomShaderEntry(0xE6972E37),  // Post-process tonemap variant
    CustomShaderEntry(0xE81CE463),  // Post-process tonemap variant
    CustomShaderEntry(0xE919C4FD),  // Post-process tonemap variant
    CustomShaderEntry(0xEA6A571E),  // Post-process tonemap variant
    CustomShaderEntry(0xEA8DA350),  // Post-process tonemap
    CustomShaderEntry(0xEF5BAB14),  // Post-process tonemap variant
    CustomShaderEntry(0xF51FE9AA),  // Post-process tonemap variant
    CustomShaderEntry(0xF6BD175C),  // Post-process tonemap with additional effects
    CustomShaderEntry(0xF8142033),  // Post-process tonemap variant
    CustomShaderEntry(0xF817D5BD),  // Post-process tonemap variant
};

ShaderInjectData shader_injection;

bool IsPsychoV() {
  return shader_injection.tone_map_type != 0.f;
}

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "ToneMapType",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Vanilla preserves the game's original HDR output. PsychoV-25 replaces the game's native HDR curve.",
        .labels = {"Vanilla", "PsychoV-25"},
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
        .key = "ToneMapWideGamut",
        .binding = &shader_injection.psychov_wide_gamut,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Wide Gamut",
        .section = "Tone Mapping",
        .tooltip = "Selects PsychoV-25's target gamut. BT.709 preserves the game's narrower vanilla color range; BT.2020 allows wide-gamut HDR colors.",
        .labels = {"BT.709", "BT.2020"},
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueShift",
        .binding = &shader_injection.psychov_hue_shift,
        .default_value = 100.f,
        .label = "Hue Shift",
        .section = "Tone Mapping",
        .tooltip = "Corrects PsychoV-25 hue shifts for fires towards the original hue.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.1f; },
        .is_visible = []() { return IsPsychoV(); },
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
    },
    new renodx::utils::settings::Setting{
        .key = "FxFilmGrainType",
        .binding = &shader_injection.custom_film_grain_type,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Film Grain Type",
        .section = "Effects",
        .tooltip = "Native leaves the game's film grain unchanged. Perceptual replaces it with RenoDX's luminance-aware film grain.",
        .labels = {"Native", "Perceptual"},
        .is_enabled = []() { return IsPsychoV(); },
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
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpeningType",
        .binding = &shader_injection.custom_sharpening_type,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Sharpening Type",
        .section = "Effects",
        .tooltip = "Native leaves the game's sharpening path unchanged. Lilium HDR RCAS enables RenoDX's HDR-aware sharpening.",
        .labels = {"Native", "Lilium HDR RCAS"},
        .is_enabled = []() { return IsPsychoV(); },
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
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All",
        .section = "Options",
        .group = "button-line-1",
        .on_change = []() { renodx::utils::settings::ResetSettings(); },
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
        .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
        .section = "About",
    },
};

void OnPresetOff() {
  renodx::utils::settings::UpdateSettings({
      {"ToneMapType", 0.f},
      {"ToneMapPeakNits", 1000.f},
      {"ToneMapGameNits", 203.f},
      {"ToneMapWideGamut", 0.f},
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

  auto* peak_setting = settings[1];
  const bool using_default_peak = peak_setting->GetValue() == peak_setting->default_value;
  peak_setting->default_value = peak.value();
  peak_setting->can_reset = true;

  if (using_default_peak) {
    peak_setting->Set(peak.value())->Write();
  }

  fired_on_init_swapchain = true;
}

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX - Resonance: A Plague Tale Legacy";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Resonance: A Plague Tale Legacy";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      if (!initialized) {
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
