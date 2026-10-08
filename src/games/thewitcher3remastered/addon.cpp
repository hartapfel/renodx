/*
 * Copyright (C) 2026 Carlos Lopez
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#ifndef NDEBUG
#define DEBUG_LEVEL_0
#endif

#include <algorithm>
#include <bit>
#include <vector>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../utils/random.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/swapchain.hpp"
#include "./shared.h"
#include "./native_bloom.hpp"

namespace {

// Captured DX12 tone-map, screen blend, LUT, post-process and HDR output passes.
renodx::mods::shader::CustomShaders custom_shaders = {
#ifdef __ALL_CUSTOM_SHADERS
    __ALL_CUSTOM_SHADERS
#endif
};

ShaderInjectData shader_injection;
float video_bt709 = 1.f;
float color_grading_strength = 1.f;
float color_grading_saturation = 1.f;
bool fired_on_init_swapchain = false;

// The post-processing shaders use pixel-visible b3 and b12 in space0.
// In particular, the HairWorks layouts seen in the capture do not expose b3.
bool ShouldInjectPostProcessLayout(std::span<const reshade::api::pipeline_layout_param> params) {
  using namespace reshade::api;
  bool has_b3 = false;
  bool has_b12 = false;
  uint32_t root_dwords = 0;
  const auto inspect_range = [&](const descriptor_range& range) {
    if (range.type != descriptor_type::constant_buffer || range.dx_register_space != 0
        || !renodx::utils::bitwise::HasFlag(range.visibility, shader_stage::pixel)) return;
    has_b3 |= range.dx_register_index <= 3 && 3 - range.dx_register_index < range.count;
    has_b12 |= range.dx_register_index <= 12 && 12 - range.dx_register_index < range.count;
  };

  for (const auto& param : params) {
    switch (param.type) {
      case pipeline_layout_param_type::push_constants:
        // Recognize our own range during init, but leave native constant layouts alone.
        if (param.push_constants.dx_register_space != 50
            || param.push_constants.dx_register_index != 13
            || param.push_constants.count != sizeof(ShaderInjectData) / sizeof(float)) return false;
        break;
      case pipeline_layout_param_type::push_descriptors:
        inspect_range(param.push_descriptors);
        // The native bloom buffer is our own injected root UAV. Reserve its
        // two DWORDs below, both before creation and after layout injection.
        if (param.push_descriptors.type != descriptor_type::buffer_unordered_access_view
            || param.push_descriptors.dx_register_space != 50
            || param.push_descriptors.dx_register_index != 0
            || param.push_descriptors.count != 1) root_dwords += 2;
        break;
      case pipeline_layout_param_type::descriptor_table:
        for (uint32_t i = 0; i < param.descriptor_table.count; ++i) {
          inspect_range(param.descriptor_table.ranges[i]);
        }
        ++root_dwords;
        break;
      case pipeline_layout_param_type::push_descriptors_with_static_samplers:
      case pipeline_layout_param_type::descriptor_table_with_static_samplers: {
        bool has_dynamic_range = false;
        for (uint32_t i = 0; i < param.descriptor_table_with_static_samplers.count; ++i) {
          const auto& range = param.descriptor_table_with_static_samplers.ranges[i];
          inspect_range(range);
          has_dynamic_range |= range.count != 0 && range.static_samplers == nullptr;
        }
        if (has_dynamic_range) {
          root_dwords += param.type == pipeline_layout_param_type::push_descriptors_with_static_samplers ? 2 : 1;
        }
        break;
      }
      default:
        return false;
    }
  }

  // Never let the shared injection path truncate the complete settings payload.
  return has_b3 && has_b12 && root_dwords <= 64 - sizeof(ShaderInjectData) / sizeof(float) - 2;
}

bool IsPsychoV() {
  return renodx::utils::bitwise::HasFlag(shader_injection.mode_flags, WITCHER_FLAG_PSYCHOV);
}

// Settings::Write clears only this percentage field; neighboring flags and
// percentages retain their values.
std::vector<uint32_t> PackedPercentValues(uint32_t shift) {
  std::vector<uint32_t> values;
  values.reserve(101);
  for (uint32_t value = 0; value <= 100; ++value) values.push_back(value << shift);
  return values;
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
        .binding = &shader_injection.mode_flags,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .packed_values = {0u, WITCHER_FLAG_PSYCHOV},
        .can_reset = false,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Selects the native HDR pipeline or PsychoV-30 with direct HDR output.",
        .labels = {"Vanilla", "PsychoV-30"},
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapPeakNits",
        .binding = &shader_injection.peak_white_nits,
        .default_value = 1000.f,
        .can_reset = false,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Detected from the HDR display on startup. A manual override is preserved; Reset restores the detected peak.",
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
        .tooltip = "Sets reference white in nits for PsychoV-30.",
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
        .tooltip = "Sets UI white in nits independently of scene brightness.",
        .min = 80.f,
        .max = 500.f,
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueShift",
        .binding = &shader_injection.psychov_hue_shift,
        .default_value = 50.f,
        .label = "Hue Shift",
        .section = "Tone Mapping",
        .tooltip = "Controls PsychoV-30 response-side hue shift.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
    },
        new renodx::utils::settings::Setting{
        .key = "NativeBrightnessCompensation",
        .binding = &shader_injection.mode_flags,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .packed_values = {0u, WITCHER_FLAG_NATIVE_BRIGHTNESS, WITCHER_FLAG_NATIVE_BRIGHTNESS_DARKEN_ONLY},
        .label = "Brightness Compensation",
        .section = "Tone Mapping",
        .tooltip = "Uses the native curve's middle-grey gain as an exposure multiplier. On allows darkening and brightening; Darken Only caps each environment's gain at 1x before transition blending. It does not disable the game's separate auto-exposure.",
        .labels = {"Off", "On", "Darken Only"},
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "LutGradeStrength",
        .binding = &shader_injection.custom_lut_strength,
        .default_value = 100.f,
        .label = "LUT Grading Strength",
        .section = "Scene Grading",
        .tooltip = "Contribution of the native color grading LUTs, including their environment blend and gain. 0 bypasses the LUT grade.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "LutScaling",
        .binding = &shader_injection.custom_lut_scaling,
        .default_value = 72.f,
        .label = "LUT Scaling",
        .section = "Scene Grading",
        .tooltip = "Restores the LUT black and white range using the original mod's black, midgray and white samples. 0 preserves native LUT levels.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeStrength",
        .binding = &color_grading_strength,
        .default_value = 100.f,
        .label = "Color Grading Strength",
        .section = "Scene Grading",
        .tooltip = "Contribution of the native color grade after LUTs. Vignette strength remains independent.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
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
        .key = "ColorGradeHighlightContrast",
        .binding = &shader_injection.mode_flags,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 50.f,
        .packed_values = PackedPercentValues(WITCHER_CONTRAST_HIGHLIGHTS_SHIFT),
        .label = "Highlight Contrast",
        .section = "Color Grading",
        .tooltip = "Adjusts contrast above 18% grey before PsychoV. 50 is neutral; lower values flatten highlights and higher values increase their contrast. PsychoV still rolls highlights toward Peak Brightness.",
        .max = 100.f,
        .format = "%d",
        .is_enabled = []() { return IsPsychoV(); },
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
        .key = "ColorGradeShadowContrast",
        .binding = &shader_injection.mode_flags,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 50.f,
        .packed_values = PackedPercentValues(WITCHER_CONTRAST_SHADOWS_SHIFT),
        .label = "Shadow Contrast",
        .section = "Color Grading",
        .tooltip = "Adjusts contrast below 18% grey before PsychoV. 50 is neutral; lower values flatten shadows and higher values deepen them. Keeps the grey pivot fixed.",
        .max = 100.f,
        .format = "%d",
        .is_enabled = []() { return IsPsychoV(); },
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
        .binding = &color_grading_saturation,
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
        .default_value = 1.f,
        .label = "Cone Response Exponent",
        .section = "PsychoV30",
        .tooltip = "Sets the cone response exponent. 1.0 is the uncalibrated neutral baseline.",
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
        .tooltip = "Sets the input adaptation anchor; higher values generally darken the scene.",
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
        .tooltip = "Sets the output background anchor; higher values generally brighten the scene.",
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
        .tooltip = "Maps colours toward the selected gamut: 0 leaves gamut unclamped; 1 fully maps to the target.",
        .max = 1.f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "PsychoVGamutCompressionMode",
        .binding = &shader_injection.mode_flags,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .packed_values = {0u, WITCHER_FLAG_GAMUT_TARGET},
        .label = "Gamut Compression Target",
        .section = "PsychoV30",
        .tooltip = "Display gamut used by Gamut Compression. Scene grading remains unclamped before tonemapping.",
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
        .tooltip = "0 selects PsychoV-30 automatic compression. Positive values set the response power directly.",
        .max = 5.f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return IsPsychoV() && settings[0]->GetValue() >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxDepthBlur",
        .binding = &shader_injection.effect_strengths,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 50.f,
        .packed_values = PackedPercentValues(WITCHER_EFFECT_BLUR_SHIFT),
        .label = "Blur",
        .section = "Effects",
        .tooltip = "Ports the original mod's depth-blur radius control. 0 removes depth blur; 50 is original-mod strength; 100 doubles the radius. Does not control Motion Blur or Witcher Senses.",
        .max = 100.f,
        .format = "%d",
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxBloomStrength",
        .binding = &shader_injection.effect_strengths,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 50.f,
        .packed_values = PackedPercentValues(WITCHER_EFFECT_BLOOM_SHIFT),
        .label = "Bloom Strength",
        .section = "Effects",
        .tooltip = "Scales the native additive bloom contribution before exposure and tone mapping. 0 removes it; 50 retains the game's strength; 100 doubles it. Requires native Bloom to be enabled.",
        .max = 100.f,
        .format = "%d",
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSunShaftStrength",
        .binding = &shader_injection.effect_strengths,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 50.f,
        .packed_values = PackedPercentValues(WITCHER_EFFECT_SHAFTS_SHIFT),
        .label = "Sunshafts Strength",
        .section = "Effects",
        .tooltip = "Scales the native sky input feeding sunshafts, as in the original mod. 0 removes it; 50 is native strength; 100 doubles it. Requires native Light Shafts.",
        .max = 100.f,
        .format = "%d",
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxLensDirt",
        .binding = &shader_injection.effect_strengths,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 50.f,
        .packed_values = PackedPercentValues(WITCHER_EFFECT_LENS_SHIFT),
        .label = "Lens Dirt",
        .section = "Effects",
        .tooltip = "Scales the dirt texture contribution, as in the original mod. 0 removes dirt; 50 is native strength; 100 doubles it. Requires native Camera Lens Effects and Bloom.",
        .max = 100.f,
        .format = "%d",
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxVignetteStrength",
        .binding = &shader_injection.vignette_strength,
        .default_value = 50.f,
        .label = "Vignette Strength",
        .section = "Effects",
        .tooltip = "Scales the native vignette. 0 removes it; 50 retains the game's strength; 100 doubles it. Applies to both radial and texture-based vignettes.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxVignetteBlackFloor",
        .binding = &shader_injection.mode_flags,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .packed_values = {0u, WITCHER_FLAG_VIGNETTE_BLACK},
        .label = "Vignette Black Floor",
        .section = "Effects",
        .tooltip = "Perfect Black darkens without adding a colored black floor. Above strength 50, it darkens progressively while retaining detail under partial vignette masks.",
        .labels = {"Native", "Perfect Black"},
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpeningMode",
        .binding = &shader_injection.mode_flags,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .packed_values = {0u, WITCHER_FLAG_SHARPENING},
        .label = "Sharpening",
        .section = "RenoFX",
        .tooltip = "Native follows the game's sharpening setting. Lilium RCAS replaces native sharpening and runs before chromatic aberration.",
        .labels = {"Native", "Lilium RCAS"},
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpening",
        .binding = &shader_injection.sharpening,
        .default_value = 0.f,
        .label = "Lilium RCAS Strength",
        .section = "RenoFX",
        .tooltip = "Sharpens scene detail with noise attenuation. 0 disables sharpening in Lilium RCAS mode. Does not sharpen HUD or menu graphics.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV() && renodx::utils::bitwise::HasFlag(shader_injection.mode_flags, WITCHER_FLAG_SHARPENING); },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxFilmGrain",
        .binding = &shader_injection.film_grain,
        .default_value = 50.f,
        .label = "Perceptual Film Grain",
        .section = "RenoFX",
        .tooltip = "Adds luminance-adaptive film grain after sharpening and chromatic aberration. 0 disables it. Does not affect HUD or menu graphics.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationMode",
        .binding = &shader_injection.mode_flags,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .packed_values = {0u, WITCHER_FLAG_CA},
        .label = "Chromatic Aberration",
        .section = "RenoFX",
        .tooltip = "Native follows the game's CA setting. RenoDX replaces it with the Ghost of Tsushima mod's lens dispersion, even when native CA is disabled.",
        .labels = {"Native", "RenoDX"},
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationIntensity",
        .binding = &shader_injection.chromatic_aberration_intensity,
        .default_value = 0.7f,
        .label = "CA Intensity",
        .section = "RenoFX",
        .tooltip = "Strength of the red/green lens separation. 0 removes fringing.",
        .max = 5.f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV() && renodx::utils::bitwise::HasFlag(shader_injection.mode_flags, WITCHER_FLAG_CA); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationStartOffset",
        .binding = &shader_injection.chromatic_aberration_start_offset,
        .default_value = 0.7f,
        .label = "CA Start Offset",
        .section = "RenoFX",
        .tooltip = "Protects the center from fringing. 0 starts at the center; 0.5 keeps the middle half clear; values near 1 confine the effect to the edges.",
        .max = 0.95f,
        .format = "%.2f",
        .is_enabled = []() { return IsPsychoV() && renodx::utils::bitwise::HasFlag(shader_injection.mode_flags, WITCHER_FLAG_CA); },
    },
    new renodx::utils::settings::Setting{
        .key = "VideoBT709",
        .binding = &video_bt709,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "BT.709 Video Colors",
        .section = "Video",
        .tooltip = "Uses BT.709 color decoding for videos. Off restores the game's original BT.601 decoding.",
        .labels = {"Off", "On"},
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
        .label = "Recommended",
        .section = "Options",
        .group = "button-line-2",
        .tooltip = "Recommended setting for slightly increased contrast.",
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
              {"ColorGradeShadows", 80.f},
              {"PsychoVConeResponseExponent", 1.3f},
              {"PsychoVCompression", 0.64f},
          });
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Use the game's native HDR output. Vanilla restores the native HDR pipeline.",
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
      {"NativeBrightnessCompensation", 0.f},
      {"LutGradeStrength", 100.f},
      {"LutScaling", 0.f},
      {"ColorGradeStrength", 100.f},
      {"ToneMapPeakNits", renodx::utils::settings::FindSetting("ToneMapPeakNits")->default_value},
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
      {"ColorGradeHighlightContrast", 50.f},
      {"ColorGradeShadows", 50.f},
      {"ColorGradeShadowContrast", 50.f},
      {"ColorGradeContrast", 50.f},
      {"ColorGradeSaturation", 50.f},
      {"ColorGradeHighlightSaturation", 50.f},
      {"ColorGradeBlowout", 0.f},
      {"ColorGradeFlare", 0.f},
      {"FxChromaticAberrationMode", 0.f},
      {"FxChromaticAberrationIntensity", 0.7f},
      {"FxChromaticAberrationStartOffset", 0.7f},
      {"FxSharpeningMode", 0.f},
      {"FxSharpening", 0.f},
      {"FxFilmGrain", 0.f},
      {"VideoBT709", 0.f},
      {"FxDepthBlur", 50.f},
      {"FxSunShaftStrength", 50.f},
      {"FxLensDirt", 50.f},
      {"FxBloomStrength", 50.f},
      {"FxVignetteStrength", 50.f},
      {"FxVignetteBlackFloor", 0.f},
  });
}

void OnPresent(reshade::api::command_queue*, reshade::api::swapchain*, const reshade::api::rect*,
               const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  shader_injection.tone_map_saturation = color_grading_saturation;
  shader_injection.custom_color_grading = color_grading_strength;
}

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  (void)resize;
  const auto format = swapchain->get_device()->get_resource_desc(swapchain->get_back_buffer(0)).texture.format;
  if (format == reshade::api::format::r8g8b8a8_unorm
      || format == reshade::api::format::r8g8b8a8_unorm_srgb) return;
  auto* peak_setting = renodx::utils::settings::FindSetting("ToneMapPeakNits");
  if (peak_setting == nullptr || fired_on_init_swapchain) return;

  auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
  if (!peak.has_value()) return;
  const bool using_default_peak = peak_setting->GetValue() == peak_setting->default_value;
  peak_setting->default_value = std::clamp(peak.value(), peak_setting->min, peak_setting->max);
  peak_setting->can_reset = true;
  if (using_default_peak) {
    peak_setting->Set(peak_setting->default_value)->Write();
  }
  fired_on_init_swapchain = true;
}

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX - The Witcher 3 - Remastered";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION =
    "The Witcher 3 - Remastered: PsychoV-30 HDR tone mapping and color grading";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      // HDR needs no descriptor heap history.
      renodx::utils::descriptor::trace_descriptor_tables = false;

      // Extend only compatible post-process layouts; cloning regressed level loading.
      renodx::mods::shader::expected_constant_buffer_space = 50;
      renodx::mods::shader::expected_constant_buffer_index = 13;
      renodx::mods::shader::force_pipeline_cloning = true;
      renodx::mods::shader::on_create_pipeline_layout = [](auto* device, auto params) {
        return device->get_api() == reshade::api::device_api::d3d12 && ShouldInjectPostProcessLayout(params);
      };
      renodx::mods::shader::on_init_pipeline_layout = [](auto* device, auto, auto params) {
        return device->get_api() == reshade::api::device_api::d3d12 && ShouldInjectPostProcessLayout(params);
      };
      // Defer replacement until the draw so a rejected layout keeps its native shader.
      for (auto& [hash, custom_shader] : custom_shaders) {
        if (hash == 0x7EF4001F) {
          // Correct decoding in place with native textures, samplers and opacity.
          // No movie redirection, binding tracking or injected constants.
          custom_shader.on_replace = [](auto*) { return video_bt709 != 0.f; };
          custom_shader.on_inject = [](auto*) { return false; };
          continue;
        }
        if (hash == 0x3650C210) {
          // The native sharpening dispatch becomes a copy only in custom mode.
          // It uses native bindings exclusively; never extend/inject its layout.
          custom_shader.on_replace = [](auto*) { return IsPsychoV() && renodx::utils::bitwise::HasFlag(shader_injection.mode_flags, WITCHER_FLAG_SHARPENING); };
          custom_shader.on_inject = [](auto*) { return false; };
          continue;
        }
        custom_shader.on_replace = [](reshade::api::command_list* cmd_list) {
          const auto* state = renodx::utils::shader::GetCurrentState(cmd_list);
          if (state == nullptr) return false;
          const auto* details = state->stage_states[renodx::utils::shader::PIXEL_INDEX].pipeline_details;
          return details != nullptr && details->injection_layout.handle != 0
                 && details->injection_index >= 0 && details->injection_register_index == 13;
        };
      }
      // A 384-byte root UAV carries the real native exposure/curve response
      // between the exposure and extraction draws, without heap tracking.
      for (const auto hash : {0x382CDBDBu, 0x724E225Fu, 0x0BF2A7DCu}) {
        auto& shader = custom_shaders.at(hash);
        shader.views.push_back({.type = reshade::api::descriptor_type::buffer_unordered_access_view,
                                .slot = 0, .space = 50, .get_view = &witcher::bloom::GetReference});
        if (hash != 0x0BF2A7DCu) shader.on_draw = &witcher::bloom::BeginCapture;
        shader.on_drawn = hash == 0x0BF2A7DCu ? &witcher::bloom::FinishExtraction : &witcher::bloom::FinishCapture;
      }
      custom_shaders.at(0x1132ADF9u).on_drawn = &witcher::bloom::MarkShafts;
      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::register_event<reshade::addon_event::present>(OnPresent);
      reshade::log::message(reshade::log::level::info,
                           "Witcher HDR: native motion blur; BT.709 video correction only; descriptor heap tracking disabled.");
      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  if (fdw_reason == DLL_PROCESS_ATTACH) {
    shader_injection.custom_color_grading = color_grading_strength;
    shader_injection.tone_map_saturation = color_grading_saturation;
  }
  renodx::utils::random::Use(fdw_reason, {&shader_injection.random_seed});
  witcher::bloom::Use(fdw_reason);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);
  return TRUE;
}
