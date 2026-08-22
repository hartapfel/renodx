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
#include "../../utils/settings.hpp"
#include "../../utils/swapchain.hpp"
#include "./shared.h"

namespace {

renodx::mods::shader::CustomShaders custom_shaders = {
    CustomShaderEntry(0x075A3656),  // HDR display transform
    CustomShaderEntry(0x0B400229),  // Post-process tonemap variant
    CustomShaderEntry(0x1334A440),  // Post-process tonemap variant
    CustomShaderEntry(0x1CFA12FF),  // Post-process tonemap variant
    CustomShaderEntry(0x2938303C),  // Post-process tonemap variant
    CustomShaderEntry(0x29BA98C2),  // Post-process tonemap variant
    CustomShaderEntry(0x2DF70FE7),  // Post-process tonemap variant
    CustomShaderEntry(0x3A960CAD),  // Post-process tonemap variant
    CustomShaderEntry(0x3B781817),  // Post-process tonemap variant
    CustomShaderEntry(0x5695F1ED),  // Post-process tonemap variant
    CustomShaderEntry(0x5A093FB0),  // Post-process tonemap variant
    CustomShaderEntry(0x5F538380),  // Post-process tonemap variant
    CustomShaderEntry(0x642DC775),  // Post-process tonemap variant
    CustomShaderEntry(0x75DC93EF),  // Post-process tonemap variant
    CustomShaderEntry(0x77C33C04),  // Post-process tonemap variant
    CustomShaderEntry(0x7A47A81E),  // Post-process tonemap variant
    CustomShaderEntry(0xA1C545E8),  // Post-process tonemap variant
    CustomShaderEntry(0xC29908CB),  // Post-process tonemap variant
    CustomShaderEntry(0xC4D3A175),  // Post-process tonemap variant
    CustomShaderEntry(0xCEFC5D57),  // Post-process tonemap variant
    CustomShaderEntry(0xD067C06B),  // Post-process tonemap variant
    CustomShaderEntry(0xD3A55CCB),  // Post-process tonemap variant
    CustomShaderEntry(0xD5CC0912),  // Post-process tonemap variant
    CustomShaderEntry(0xD7D00858),  // Post-process tonemap variant
    CustomShaderEntry(0xDDA7495C),  // Post-process tonemap variant
    CustomShaderEntry(0xE414472A),  // Post-process tonemap variant
    CustomShaderEntry(0xF0EEA483),  // Post-process tonemap variant
    CustomShaderEntry(0xF3770F49),  // Post-process tonemap variant
    CustomShaderEntry(0xFE4B3711),  // Post-process tonemap variant
};

ShaderInjectData shader_injection;

bool IsVanillaPlus() {
  return shader_injection.tone_map_type == 1.f;
}

bool IsPsychoV() {
  return shader_injection.tone_map_type == 2.f;
}

bool IsCustomToneMap() {
  return shader_injection.tone_map_type == 1.f || shader_injection.tone_map_type == 2.f;
}

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "ToneMapType",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Vanilla preserves the game's original HDR output. Vanilla+ uses RenoDRT Reinhard. PsychoV-25 uses the observer-based Test25 tonemapper.",
        .labels = {"Vanilla", "Vanilla+", "PsychoV-25"},
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
        .is_enabled = []() { return IsCustomToneMap(); },
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
        .is_enabled = []() { return IsCustomToneMap(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapWhiteClip",
        .binding = &shader_injection.tone_map_white_clip,
        .default_value = 100.f,
        .label = "White Clip",
        .section = "Tone Mapping",
        .tooltip = "Sets the scene-relative white point for Vanilla+'s RenoDRT shoulder. Lower values make highlights reach peak brightness sooner.",
        .min = 1.f,
        .max = 100.f,
        .format = "%.2f",
        .is_enabled = []() { return IsVanillaPlus(); },
        .is_visible = []() { return IsVanillaPlus(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapPsychoVCompression",
        .binding = &shader_injection.psychov_compression_power,
        .default_value = 2.f,
        .label = "Compression Power",
        .section = "Tone Mapping",
        .tooltip = "Sets PsychoV-25's highlight compression power. Zero uses automatic compression; higher values make highlights approach peak brightness sooner.",
        .max = 10.f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapColorScale",
        .binding = &shader_injection.tone_map_color_scale,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Color Scaling",
        .section = "Tone Mapping",
        .tooltip = "Luminance preserves color relationships through the HDR rolloff. Per Channel saturates and blows out highlights sooner.",
        .labels = {"Luminance", "Per Channel"},
        .is_enabled = []() { return IsVanillaPlus(); },
        .is_visible = []() { return IsVanillaPlus(); },
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
        .is_enabled = []() { return IsCustomToneMap(); },
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
        .is_enabled = []() { return IsCustomToneMap(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlights",
        .binding = &shader_injection.tone_map_highlights,
        .default_value = 50.f,
        .label = "Highlights",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return IsCustomToneMap(); },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeShadows",
        .binding = &shader_injection.tone_map_shadows,
        .default_value = 50.f,
        .label = "Shadows",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return IsCustomToneMap(); },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeContrast",
        .binding = &shader_injection.tone_map_contrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return IsCustomToneMap(); },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeSaturation",
        .binding = &shader_injection.tone_map_saturation,
        .default_value = 50.f,
        .label = "Saturation",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return IsCustomToneMap(); },
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
        .is_enabled = []() { return IsCustomToneMap(); },
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
        .is_enabled = []() { return IsCustomToneMap(); },
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
        .is_enabled = []() { return IsCustomToneMap(); },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeLUTScaling",
        .binding = &shader_injection.color_grade_lut_scaling,
        .default_value = 100.f,
        .label = "LUT Scaling",
        .section = "Color Grading",
        .tooltip = "Scales the game's color grade LUT to its full range, allowing the black floor to reach zero.",
        .max = 100.f,
        .is_enabled = []() { return IsCustomToneMap(); },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpening",
        .binding = &shader_injection.custom_sharpness,
        .default_value = 0.f,
        .label = "Lilium HDR RCAS Sharpening",
        .section = "Effects",
        .tooltip = "Adds Lilium's HDR-aware RCAS sharpening. Disable other sharpening to avoid double-sharpening.",
        .max = 100.f,
        .is_enabled = []() { return IsCustomToneMap(); },
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
      {"ToneMapWhiteClip", 100.f},
      {"ToneMapPsychoVCompression", 0.f},
      {"ToneMapColorScale", 0.f},
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
      {"ColorGradeLUTScaling", 100.f},
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

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX - A Plague Tale: Requiem";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for A Plague Tale: Requiem";

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
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  if (fdw_reason == DLL_PROCESS_DETACH) {
    reshade::unregister_addon(h_module);
  }

  return TRUE;
}
