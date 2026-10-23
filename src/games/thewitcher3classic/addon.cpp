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

namespace {
float settings_mode = 0.f;
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
    .chromatic_aberration_intensity = 0.7f,
    .chromatic_aberration_start_offset = 0.7f,
    .vignette_strength = 1.f,
    .vignette_black_floor = 1.f,
    .lut_strength = 1.f,
    .color_grading_strength = 1.f,
};

renodx::mods::shader::CustomShaders custom_shaders = {
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
    CustomShaderEntry(0x3EDDC379),  // Bypass native pre-AA sharpening in RCAS mode.
    CustomShaderEntry(0x56BDBC86),  // Shared bloom/shafts extraction.
    CustomShaderEntry(0xBAEDA9BD),  // Masked sky feeding light shafts.
    CustomShaderEntry(0x620431CF),  // Additive bloom with lens dirt.
    CustomShaderEntry(0x0CB5EA21),  // Screen-blended effect composite.
};

bool IsCustom() { return shader_injection.tone_map_type == CLASSIC_TONE_MAP_PSYCHOV31; }

// HDR settings appear in this order. Move a complete Setting block to reorder.
// DLSS preferences at the end are global; DrawAddon renders their dropdown UI.
renodx::utils::settings::Settings settings = {
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
        .key = "FxBloom",
        .binding = &shader_injection.custom_bloom,
        .default_value = 50.f,
        .label = "Bloom",
        .section = "Effects",
        .tooltip = "Scales bloom composites. 0 removes bloom, 50 is reference strength, 100 doubles it. Requires native Bloom.",
        .min = 0.f,
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSunShaftStrength",
        .binding = &shader_injection.custom_sunshafts_strength,
        .default_value = 50.f,
        .label = "Sunshafts Strength",
        .section = "Effects",
        .tooltip = "Scales masked sky input to light shafts. 0 removes it, 50 is reference strength, 100 doubles the input. Requires native Light Shafts; Bloom also scales their shared composite.",
        .min = 0.f,
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxDepthBlur",
        .binding = &shader_injection.custom_blur,
        .default_value = 50.f,
        .label = "Blur",
        .section = "Effects",
        .tooltip = "Depth-blur radius: 0 removes it, 50 is native, 100 doubles it. Requires native Blur. Does not control Motion Blur or Witcher Senses.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxLensDirt",
        .binding = &shader_injection.custom_lens_dirt,
        .default_value = 50.f,
        .label = "Lens Dirt",
        .section = "Effects",
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
        .section = "Effects",
        .tooltip = "Perfect Black darkens without adding a colored black floor. Above strength 50, it darkens progressively while retaining detail under partial vignette masks. Native retains the game's vignette color.",
        .labels = {"Native", "Perfect Black"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "FxVignetteStrength",
        .binding = &shader_injection.vignette_strength,
        .default_value = 50.f,
        .label = "Vignette Strength",
        .section = "Effects",
        .tooltip = "Scales the game's radial and texture-based vignettes. 0 removes them; 50 uses native strength; 100 doubles the strength. Requires the game's Vignetting option.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationMode",
        .binding = &shader_injection.chromatic_aberration_mode,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .label = "Chromatic Aberration",
        .section = "Effects",
        .tooltip = "Native follows the game's setting. RenoDX replaces it with lens dispersion after sharpening, even when native CA is off.",
        .labels = {"Native", "RenoDX"},
        .is_enabled = &IsCustom,
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationIntensity",
        .binding = &shader_injection.chromatic_aberration_intensity,
        .default_value = 0.7f,
        .label = "CA Intensity",
        .section = "Effects",
        .tooltip = "Red/green lens separation. 0 removes fringing in RenoDX mode.",
        .min = 0.f,
        .max = 5.f,
        .format = "%.2f",
        .is_enabled = [] { return IsCustom() && shader_injection.chromatic_aberration_mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxChromaticAberrationStartOffset",
        .binding = &shader_injection.chromatic_aberration_start_offset,
        .default_value = 0.7f,
        .label = "CA Start Offset",
        .section = "Effects",
        .tooltip = "Protects the center: 0 starts at the center; values near 1 confine fringing to the edges.",
        .min = 0.f,
        .max = 0.95f,
        .format = "%.2f",
        .is_enabled = [] { return IsCustom() && shader_injection.chromatic_aberration_mode != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxFilmGrain",
        .binding = &shader_injection.film_grain,
        .default_value = 0.f,
        .label = "Perceptual Film Grain",
        .section = "Effects",
        .tooltip = "Luminance-adaptive grain after reconstruction, sharpening, CA and tone mapping. 0 disables it. HUD and menu graphics are unaffected.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = &IsCustom,
        .parse = [](float value) { return value * 0.01f; },
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
        .key = "FxSharpeningMode",
        .binding = &shader_injection.sharpening_mode,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .is_global = true,
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpening",
        .binding = &shader_injection.sharpening_strength,
        .default_value = 0.f,
        .min = 0.f,
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
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
    renodx::utils::settings::OnRegisterOverlay(runtime);
    ImGui::EndTabItem();
  }
  if (ImGui::BeginTabItem("DLSS")) {
    using namespace witcher3classic::temporal;
    bool changed = false;
    bool enabled = mode != 0.f;
    if (ImGui::Checkbox("Enable DLSS", &enabled))
      changed |= renodx::utils::settings::UpdateSetting("AADevelopment", enabled ? 1.f : 0.f);
    ShowHint("Requires Anti-aliasing enabled in the game. Off restores native TAA.");
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

    ImGui::SeparatorText("Sharpening");
    ImGui::BeginDisabled(!IsCustom());
    bool replace_sharpening = shader_injection.sharpening_mode != 0.f;
    if (ImGui::Checkbox("Replace Native Sharpening", &replace_sharpening))
      changed |= renodx::utils::settings::UpdateSetting("FxSharpeningMode", replace_sharpening ? 1.f : 0.f);
    ShowHint("Replaces the game's sharpening with Lilium RCAS after DLSS or native TAA, before chromatic aberration and grain. Works with native Sharpening off. Requires the PsychoV tone mapper.");
    ImGui::BeginDisabled(!replace_sharpening);
    float sharpness = shader_injection.sharpening_strength * 100.f;
    if (ImGui::SliderFloat("Lilium RCAS Strength", &sharpness, 0.f, 100.f, "%.0f"))
      changed |= renodx::utils::settings::UpdateSetting("FxSharpening", sharpness);
    ShowHint("0 disables sharpening while replacement remains active. Higher values enhance detail with noise attenuation. HUD and menu graphics are unaffected.");
    ImGui::EndDisabled();
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
    reshade::register_event<reshade::addon_event::init_swapchain>(&OnInitSwapchain);

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
    custom_shaders.at(0x3EDDC379).on_replace = [](auto*) { return IsCustom() && shader_injection.sharpening_mode != 0.f; };
    custom_shaders.at(0x3EDDC379).on_inject = [](auto*) { return false; };
    custom_shaders.at(0x6ED58557).on_replace = [](auto*) { return IsCustom() && shader_injection.custom_blur != 1.f; };
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
    });
    // Preserve encoded HDR through the full-size scene/UI buffer and final copy.
    renodx::mods::swapchain::resource_upgrade_infos.push_back({
        .old_format = reshade::api::format::r8g8b8a8_unorm,
        .new_format = reshade::api::format::r16g16b16a16_float,
        .use_resource_view_cloning = true,
        .usage_include = reshade::api::resource_usage::render_target,
    });
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::init_swapchain>(&OnInitSwapchain);
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
