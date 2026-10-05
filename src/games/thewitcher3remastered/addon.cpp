/*
 * Copyright (C) 2026 Carlos Lopez
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define DEBUG_LEVEL_0

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
#include "./motion_blur.hpp"
#include "./video.hpp"
#include "./night_lighting.hpp"

namespace {

// Captured DX12 tone-map, screen blend, LUT, post-process and HDR output passes.
renodx::mods::shader::CustomShaders custom_shaders = {
#ifdef __ALL_CUSTOM_SHADERS
    __ALL_CUSTOM_SHADERS
#endif
};

ShaderInjectData shader_injection;
// Compute replacement selection is CPU-only; it needs no additional root data.
float motion_blur_mode = 1.f;
float video_bt709 = 1.f;
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
        // Like the constants above, our injected movie table is already
        // reserved in the budget below. Do not count it again during init.
        if (param.push_descriptors.type == descriptor_type::shader_resource_view
            && param.push_descriptors.dx_register_space == 51
            && param.push_descriptors.dx_register_index == 0
            && param.push_descriptors.count == 1) break;
        inspect_range(param.push_descriptors);
        root_dwords += 2;
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
  // The separate movie SRV needs one additional descriptor-table DWORD.
  return has_b3 && has_b12 && root_dwords <= 63 - sizeof(ShaderInjectData) / sizeof(float);
}

bool IsPsychoV() {
  return shader_injection.tone_map_type == 1.f;
}

bool IsNightLightingEnabled() {
  return IsPsychoV() && witcher::night::lighting_enabled == 1.f && witcher::night::Supported();
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
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
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
        .default_value = 100.f,
        .label = "Hue Shift",
        .section = "Tone Mapping",
        .tooltip = "Controls PsychoV-30 response-side hue shift.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.02f; },
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
        .default_value = 100.f,
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
        .binding = &shader_injection.custom_color_grading,
        .default_value = 100.f,
        .label = "Color Grading Strength",
        .section = "Scene Grading",
        .tooltip = "Contribution of the native color grade after LUTs. Vignette strength remains independent.",
        .max = 100.f,
        .is_enabled = []() { return IsPsychoV(); },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    },
/*     new renodx::utils::settings::Setting{
        .key = "GamutUnclamp",
        .binding = &shader_injection.mode_flags,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .packed_values = {0u, WITCHER_FLAG_GAMUT_UNCLAMP},
        .label = "Color Gamut",
        .section = "Scene Grading",
        .tooltip = "Preserves signed wide-gamut colors generated by native grading instead of clipping negative BT.709 channels. PsychoV still maps to its selected display gamut.",
        .labels = {"Vanilla", "Wide Color Gamut"},
        .is_enabled = []() { return IsPsychoV(); },
        .is_visible = []() { return settings[0]->GetValue() >= 1.f; },
    }, */
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
        .tooltip = "Controls PsychoV-30's projection into the selected display gamut.",
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
        .tooltip = "Selects the target gamut. Output remains represented as linear BT.709.",
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
        .key = "FxMotionBlurMode",
        .binding = &motion_blur_mode,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Motion Blur",
        .section = "Effects",
        .tooltip = "Enhanced reconstructs full-resolution HDR blur from per-object frame motion and depth. The mod controls shutter duration independently of native intensity. Requires the game's Motion Blur setting.",
        .labels = {"Native", "Enhanced"},
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxMotionIntensity",
        .binding = &witcher::motion::shutter_angle,
        .default_value = 50.f,
        .label = "Motion Blur Intensity",
        .section = "Effects",
        .tooltip = "Controls how much movement is blurred. 0 is off, 50 is the default, and 100 doubles the strength. Blur automatically adjusts to the frame rate.",
        .min = 0.f,
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return IsPsychoV() && motion_blur_mode == 1.f; },
        .parse = [](float value) { return value * 3.6f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxMotionSamples",
        .binding = &witcher::motion::sample_count,
        .default_value = 16.f,
        .label = "Motion Blur Samples",
        .section = "Effects",
        .tooltip = "Higher values make blur smoother but can reduce performance. Longer blur trails automatically get extra samples to keep them smooth.",
        .min = 16.f,
        .max = 128.f,
        .format = "%.0f",
        .is_enabled = []() { return IsPsychoV() && motion_blur_mode == 1.f; },
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
        .tooltip = "Uses BT.709 color decoding for videos. Turn off to use the game's original BT.601 decoding.",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .key = "VideoAutoHDR",
        .binding = &shader_injection.mode_flags,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .packed_values = {0u, WITCHER_FLAG_VIDEO_AUTO_HDR},
        .label = "Video AutoHDR",
        .section = "Video",
        .tooltip = "Expands SDR videos to HDR using BT.2446 Method A.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return IsPsychoV(); },
    },
    new renodx::utils::settings::Setting{
        .key = "GameplayCameraLightStrength",
        .binding = &witcher::night::camera_strength,
        .default_value = 50.f,
        .label = "Gameplay Camera Light",
        .section = "Gameplay Lighting",
        .tooltip = "Player-following camera light, all day. 0 is off, 50 is native, 100 doubles it. Preserves cutscene lights and torches. Works without a separate lighting mod.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return IsPsychoV() && witcher::night::Supported() && witcher::night::camera_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightLightingEnabled",
        .binding = &witcher::night::lighting_enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Enable Night Lighting",
        .section = "Night Lighting",
        .tooltip = "Enables the night sliders. Off restores native lighting and keeps your slider values.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return IsPsychoV() && witcher::night::Supported(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Adjusts environmental light during the selected hours with smooth fades. Times use the 24-hour clock and can cross midnight. Local lights stay unchanged. Intensity: 0 = off, 50 = native, 100 = double.",
        .section = "Night Lighting",
    },
    new renodx::utils::settings::Setting{
        .key = "NightDarkeningStart",
        .binding = &witcher::night::darkening_start,
        .default_value = 20.f,
        .label = "Darkening Start",
        .section = "Night Lighting",
        .tooltip = "Time when darkening begins fading in.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightFullDarknessStart",
        .binding = &witcher::night::full_darkness_start,
        .default_value = 23.f,
        .label = "Full Darkness Start",
        .section = "Night Lighting",
        .tooltip = "Time when the night sliders reach full strength.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightFadeOutStart",
        .binding = &witcher::night::fade_out_start,
        .default_value = 3.5f,
        .label = "Fade-out Start",
        .section = "Night Lighting",
        .tooltip = "Time when darkening begins fading back to native lighting.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightDarkeningEnd",
        .binding = &witcher::night::darkening_end,
        .default_value = 6.f,
        .label = "Darkening End",
        .section = "Night Lighting",
        .tooltip = "Time when native lighting is fully restored.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Choose Start, Full Darkness, Fade-out, then End in that order within one day. Overrides are inactive until the times form a valid schedule.",
        .section = "Night Lighting",
        .is_visible = []() { return IsPsychoV() && witcher::night::lighting_enabled == 1.f && witcher::night::NightSchedule() == 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightSkyStrength",
        .binding = &witcher::night::sky_strength,
        .default_value = 1.f,
        .label = "Night Skylight",
        .section = "Night Lighting",
        .tooltip = "Skylight and outdoor environment-probe illumination and reflections.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightDirectStrength",
        .binding = &witcher::night::direct_strength,
        .default_value = 5.f,
        .label = "Night Direct Light",
        .section = "Night Lighting",
        .tooltip = "Direct directional light from the environment, including grass illumination.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightFogStrength",
        .binding = &witcher::night::fog_strength,
        .default_value = 15.f,
        .label = "Night Directional Fog",
        .section = "Night Lighting",
        .tooltip = "Brightness of directional and custom fog colors. Preserves fog density.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightHazeStrength",
        .binding = &witcher::night::haze_strength,
        .default_value = 5.f,
        .label = "Night Aerial Haze",
        .section = "Night Lighting",
        .tooltip = "Brightness of aerial haze and distance fog. Preserves atmospheric extinction.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightVisibleSkyStrength",
        .binding = &witcher::night::visible_sky_strength,
        .default_value = 5.f,
        .label = "Night Sky Brightness",
        .section = "Night Lighting",
        .tooltip = "Visible sky, horizon glow and horizon tint on distant clouds. Preserves the moon and stars.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightCloudStrength",
        .binding = &witcher::night::cloud_strength,
        .default_value = 10.f,
        .label = "Night Clouds",
        .section = "Night Lighting",
        .tooltip = "Cloud brightness and cloud/smoke volume glow. Preserves coverage.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightWaterStrength",
        .binding = &witcher::night::water_strength,
        .default_value = 0.f,
        .label = "Night Water Lighting",
        .section = "Night Lighting",
        .tooltip = "Water base color and ambient/diffuse fill. Preserves reflections, foam and local lights.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
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
              {"ColorGradeHighlightContrast", 58.f},
              {"ColorGradeShadowContrast", 58.f},
              {"PsychoVCompression", 0.95f},
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
      {"GamutUnclamp", 0.f},
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
      {"FxMotionBlurMode", 0.f},
      {"VideoBT709", 0.f},
      {"VideoAutoHDR", 0.f},
      {"FxDepthBlur", 50.f},
      {"NightSkyStrength", 50.f},
      {"NightLightingEnabled", 0.f},
      {"NightDarkeningStart", 18.f},
      {"NightFullDarknessStart", 20.f},
      {"NightFadeOutStart", 4.f},
      {"NightDarkeningEnd", 6.f},
      {"NightDirectStrength", 50.f},
      {"NightFogStrength", 50.f},
      {"NightHazeStrength", 50.f},
      {"NightVisibleSkyStrength", 50.f},
      {"NightWaterStrength", 50.f},
      {"NightCloudStrength", 50.f},
      {"GameplayCameraLightStrength", 50.f},
      {"FxSunShaftStrength", 50.f},
      {"FxLensDirt", 50.f},
      {"FxBloomStrength", 50.f},
      {"FxVignetteStrength", 50.f},
      {"FxVignetteBlackFloor", 0.f},
  });
}

void OnPresent(reshade::api::command_queue*, reshade::api::swapchain*, const reshade::api::rect*,
               const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  witcher::night::Update(IsPsychoV());
  // Some cloud materials reuse the moon's color group or carry a separate
  // material tint. Scale those inputs only in their cloud shaders, preserving
  // the moon and the CPU-scaled main cloud group. Use the same night clock.
  const float cloud = 1.f + (witcher::night::cloud_multiplier.load(std::memory_order_relaxed) - 1.f)
                               * witcher::night::night_weight.load(std::memory_order_relaxed);
  shader_injection.mode_flags = std::bit_cast<float>(
      (std::bit_cast<uint32_t>(shader_injection.mode_flags) & ~WITCHER_NIGHT_CLOUD_MASK)
      | ((1u + static_cast<uint32_t>(std::round(std::clamp(cloud, 0.f, 2.f) * 200.f)))
         << WITCHER_NIGHT_CLOUD_SHIFT));
  static bool reported = false;
  if (witcher::night::attempted && !reported) {
    reshade::log::message(witcher::night::installed ? reshade::log::level::info : reshade::log::level::warning,
                         witcher::night::installed ? "[RenoDX Witcher] Native night-lighting controls installed."
                                                   : "[RenoDX Witcher] Native night-lighting controls unavailable; native lighting preserved.");
    if (witcher::night::installed) {
      reshade::log::message(witcher::night::camera_supported ? reshade::log::level::info : reshade::log::level::warning,
                           witcher::night::camera_supported ? "[RenoDX Witcher] Gameplay camera-light intensity control installed."
                                                            : "[RenoDX Witcher] Gameplay camera-light intensity control unavailable; native camera lighting preserved.");
    }
    reported = true;
  }
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

      // Preserve saved shutter settings when switching the UI to 0-100.
      for (const auto& section : {renodx::utils::settings::global_name,
                                 renodx::utils::settings::global_name + "-preset1",
                                 renodx::utils::settings::global_name + "-preset2",
                                 renodx::utils::settings::global_name + "-preset3"}) {
        float value = 0.f;
        if (!reshade::get_config_value(nullptr, section.c_str(), "FxMotionIntensity", value)
            && reshade::get_config_value(nullptr, section.c_str(), "FxMotionShutterAngle", value)) {
          reshade::set_config_value(nullptr, section.c_str(), "FxMotionIntensity", std::clamp(value / 3.6f, 0.f, 100.f));
        }
      }

      witcher::motion::code = {__0xF3B10000, __0xF3B10001, __0xF3B10002, __0xF3B10003};
      renodx::utils::descriptor::trace_descriptor_tables = true;
      // These shaders are private compute passes, not native replacements.
      for (uint32_t hash : {0xF3B10000u, 0xF3B10001u, 0xF3B10002u, 0xF3B10003u}) custom_shaders.erase(hash);

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
          // Video correction is independent of scene tone mapping. Selecting
          // Off restores the original shader, with no extra constant binding.
          custom_shader.on_replace = [](auto*) { return video_bt709 != 0.f; };
          custom_shader.on_inject = [](auto*) { return false; };
          custom_shader.on_draw = &witcher::video::OnDraw;
          custom_shader.on_drawn = &witcher::video::OnDrawn;
          continue;
        }
        if (hash == 0x866E78BC || hash == 0x2B7AF9F0) {
          custom_shader.on_draw = [](auto* cmd) {
            return !IsPsychoV() || motion_blur_mode != 1.f || !witcher::motion::Run(cmd);
          };
          custom_shader.on_replace = [](auto*) { return false; };
          custom_shader.on_inject = [](auto*) { return false; };
          continue;
        }
        if (hash == 0xE6A77B56 || hash == 0x8DBF022F || hash == 0xEAAAC84D || hash == 0x1C12BED7 || hash == 0x1B63829B || hash == 0x56511D80
            || hash == 0xD2C88922 || hash == 0x02320E1A) {
          // New irradiance and RT sky-ray sources skip legacy environment weights.
          // Uses only native b12 padding written by the guarded night hook.
          custom_shader.on_replace = [](auto*) {
            return IsPsychoV() && witcher::night::installed
                   && witcher::night::sky_multiplier.load(std::memory_order_relaxed) != 1.f
                   && witcher::night::night_weight.load(std::memory_order_relaxed) > 0.f;
          };
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
      custom_shaders[0x9F1C32F1] = {
          .crc32 = 0x9F1C32F1,
          .on_replace = [](auto*) { return false; },
          .on_inject = [](auto*) { return false; },
          .on_draw = [](auto* cmd) {
            return !IsPsychoV() || motion_blur_mode != 1.f || witcher::motion::CaptureMotionDepth(cmd);
          },
      };
      witcher::video::settings = &shader_injection;
      for (uint32_t hash : {0x8F5737B5u, 0x496222DAu}) {
        custom_shaders.at(hash).views = {{
            .type = reshade::api::descriptor_type::shader_resource_view,
            .slot = 0u,
            .space = 51u,
            .get_view = &witcher::video::GetView,
        }};
      }
      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::register_event<reshade::addon_event::present>(OnPresent);
      break;
    case DLL_PROCESS_DETACH:
      if (witcher::night::installed) witcher::night::Update(false);
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_addon(h_module);
      break;
  }

  witcher::motion::Use(fdw_reason);
  witcher::video::Use(fdw_reason);
  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::utils::random::Use(fdw_reason, {&shader_injection.random_seed});
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);
  return TRUE;
}
