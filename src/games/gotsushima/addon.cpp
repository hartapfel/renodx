/*
 * Copyright (C) 2026 Carlos Lopez
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64
#define DEBUG_LEVEL_0

#include <algorithm>

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
  __ALL_CUSTOM_SHADERS,
};

ShaderInjectData shader_injection;

bool IsPsychoV() {
  return shader_injection.tone_map_type == 1.f;
}

bool IsUIColorDraw(reshade::api::command_list* cmd_list) {
  const auto* state = renodx::utils::shader::GetCurrentPixelState(
      renodx::utils::shader::GetCurrentState(cmd_list));
  if (state->pipeline_details == nullptr) return false;

  for (const auto& subobject : state->pipeline_details->subobjects) {
    if (subobject.type != reshade::api::pipeline_subobject_type::blend_state
        || subobject.count == 0u) continue;
    const auto& blend = *static_cast<const reshade::api::blend_desc*>(subobject.data);
    // The same HUD shader can draw colors or multiply the destination.
    // Multipliers must retain their native identity of 1; treating them as
    // encoded colors makes the neutral region of a quad darken the background.
    return !blend.blend_enable[0]
           || (blend.source_color_blend_factor[0] != reshade::api::blend_factor::dest_color
               && blend.source_color_blend_factor[0] != reshade::api::blend_factor::one_minus_dest_color
               && blend.dest_color_blend_factor[0] != reshade::api::blend_factor::source_color
               && blend.dest_color_blend_factor[0] != reshade::api::blend_factor::one_minus_source_color);
  }
  return false;
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
        .tooltip = "Vanilla preserves native HDR. PsychoV-30 provides custom HDR. SDR in HDR reproduces the native SDR shader path at 203 nits with fixed gamma 2.2 and no mod grading or effects.",
        .labels = {"Vanilla", "PsychoV-30"/* , "SDR in HDR" */},
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapPeakNits",
        .binding = &shader_injection.peak_white_nits,
        .default_value = 1000.f,
        .can_reset = false,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Overrides the game's native HDR peak brightness in nits.",
        .min = 400.f,
        .max = 4000.f,
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapGameNits",
        .binding = &shader_injection.diffuse_white_nits,
        .default_value = 203.f,
        .label = "Game Brightness",
        .section = "Tone Mapping",
        .tooltip = "Overrides the game's paper white setting in nits.",
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
        .tooltip = "Sets HUD and menu white brightness in nits, overriding the in-game HUD brightness setting.",
        .min = 80.f,
        .max = 500.f,
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapGammaCorrection",
        .binding = &shader_injection.gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "SDR Gamma Emulation",
        .section = "Tone Mapping",
        .tooltip = "Selects sRGB, gamma 2.2, or gamma 2.4 decoding. Scene LUT colors omit the native SDR display contrast; UI retains its native SDR transfer.",
        .labels = {"None", "2.2", "BT.1886"},
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
        .key = "PsychoVConeResponseExponent",
        .binding = &shader_injection.psychov_cone_response_exponent,
        .default_value = 1.0f,
        .label = "Cone Response Exponent",
        .section = "PsychoV30",
        .tooltip = "Scales contrast calibrated to the native SDR scene curve before LUT grading and its display transform. 1.0 preserves that baseline response.",
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
        .key = "FxFilmGrain",
        .binding = &shader_injection.film_grain,
        .default_value = 0.f,
        .label = "Perceptual Film Grain",
        .section = "Effects",
        .tooltip = "Adds luminance-adaptive film grain to the scene. 0 disables it. Does not affect HUD or menu graphics.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpening",
        .binding = &shader_injection.sharpening,
        .default_value = 0.f,
        .label = "Lilium RCAS Sharpening",
        .section = "Effects",
        .tooltip = "Sharpens scene detail with noise attenuation. 0 disables it. Does not sharpen HUD or menu graphics.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberration",
        .binding = &shader_injection.chromatic_aberration_enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .label = "Chromatic Aberration",
        .section = "Effects",
        .tooltip = "Adds lens color fringing to the scene.",
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationIntensity",
        .binding = &shader_injection.chromatic_aberration_intensity,
        .default_value = 0.75f,
        .label = "CA Intensity",
        .section = "Effects",
        .tooltip = "Strength of the red/green lens separation. 0 removes fringing;",
        .max = 5.f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV() && shader_injection.chromatic_aberration_enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationStartOffset",
        .binding = &shader_injection.chromatic_aberration_start_offset,
        .default_value = 0.5f,
        .label = "CA Start Offset",
        .section = "Effects",
        .tooltip = "Protects the center from fringing. 0 starts at the center; 0.5 keeps the middle half clear; values near 1 confine the effect to the edges.",
        .max = 0.95f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV() && shader_injection.chromatic_aberration_enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Recommended",
        .section = "Presets",
        .group = "button-line-1",
        .tooltip = "Restores tone-mapping and grading defaults, then sets Cone Response to 1.15, Highlights to 45, Shadows to 80, and Blowout to 5. Preserves Game Brightness, UI Brightness, and effects.",
        .tint = 0xFF5F5F,
        .is_enabled = []() { return IsPsychoV(); },
        .on_change = []() {
          for (const auto* setting : settings) {
            if (setting->section != "Tone Mapping"
                && setting->section != "Color Grading"
                && setting->section != "PsychoV30") continue;
            if (setting->key == "ToneMapType"
                || setting->key == "ToneMapGameNits"
                || setting->key == "ToneMapUINits") continue;
            renodx::utils::settings::UpdateSetting(setting->key, setting->default_value);
          }
          renodx::utils::settings::UpdateSettings({
              {"PsychoVConeResponseExponent", 1.15f},
              {"ColorGradeHighlights", 45.f},
              {"ColorGradeShadows", 80.f},
              {"ColorGradeBlowout", 5.f},
          });
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All",
        .section = "Presets",
        .group = "button-line-2",
        .is_enabled = []() { return shader_injection.tone_map_type != GHOST_TONE_MAP_SDR_REFERENCE; },
        .on_change = []() { renodx::utils::settings::ResetSettings(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = " - Native HDR MUST BE ENABLED in game!",
        .section = "Instructions",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "SDR reference: 203 nits, gamma 2.2. Mod grading and effects are bypassed.",
        .section = "Instructions",
        .is_visible = []() { return shader_injection.tone_map_type == GHOST_TONE_MAP_SDR_REFERENCE; },
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
      {"ToneMapGammaCorrection", 0.f},
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
      {"FxFilmGrain", 0.f},
      {"FxSharpening", 0.f},
      {"FxChromaticAberration", 0.f},
      {"FxChromaticAberrationIntensity", 1.f},
      {"FxChromaticAberrationStartOffset", 0.f},
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
  peak_setting->default_value = std::clamp(peak.value(), peak_setting->min, peak_setting->max);
  peak_setting->can_reset = true;

  if (using_default_peak) {
    peak_setting->Set(peak_setting->default_value)->Write();
  }

  fired_on_init_swapchain = true;
}

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX - Ghost of Tsushima";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION =
    "RenoDX for Ghost of Tsushima DIRECTOR'S CUT";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      if (!initialized) {
        for (const auto hash : {
                 0x85EC39B6u, 0x9D97A7C7u, 0x2128DADEu, 0x083CEF82u,
                 0x37D7A160u, 0x6E8460A0u, 0x6B74C298u, 0x168D9561u,
                 0x09804E52u, 0x04DC2391u, 0x236094BAu, 0x13D89EB3u,
                 0x0B710B3Au, 0xED608505u, 0xE0DCA3C7u, 0x4F8C2C1Du,
                 0x027C0198u, 0x04F475C4u, 0x059F7117u, 0x15995B1Bu,
                 0x2588C976u, 0x262C634Du, 0x27D78F1Bu, 0x2BB323B6u,
                 0x2C0D8F65u, 0x2F104DEAu, 0x33DA8A2Fu, 0x380D3C1Cu,
                 0x38519174u, 0x499BFA9Bu, 0x540CD1C7u, 0x6A947342u,
                 0x6F5B640Du, 0x790A518Du, 0x7E02AAEAu, 0x878CCC82u,
                 0x8B2B6654u, 0x8F1774B4u, 0x91A4B40Du, 0x993F64DBu,
                 0x9AECF3C3u, 0x9E36EC97u, 0xB14E2DD7u, 0xB422BAB9u,
                 0xB787EAF7u, 0xB983666Du, 0xD78E8A46u, 0xD7BD2603u,
                 0xE4EC4156u, 0xF2927008u, 0x85013553u,
             }) {
          custom_shaders.at(hash).on_replace = &IsUIColorDraw;
        }
        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;

        initialized = true;
      }

      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::utils::random::Use(fdw_reason, {&shader_injection.random_seed});
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
