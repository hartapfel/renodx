/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define RENODX_MODS_SWAPCHAIN_VERSION 2

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/random.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/swapchain.hpp"
#include "dlaa.hpp"
#include "jitter.hpp"
#include "resource_logger.hpp"
#include "shared.h"

namespace {

renodx::mods::shader::CustomShaders custom_shaders = {
        __ALL_CUSTOM_SHADERS,
};

ShaderInjectData shader_injection;

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "ToneMapType",
        .binding = &shader_injection.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .can_reset = true,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Sets the tone mapper type.",
        .labels = {"Vanilla", "Neutwo"},
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapPeakNits",
        .binding = &shader_injection.peak_white_nits,
        .default_value = 1000.f,
        .can_reset = true,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of peak white in nits.",
        .min = 48.f,
        .max = 4000.f,
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
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "GammaCorrection",
        .binding = &shader_injection.gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "SDR EOTF Emulation",
        .section = "Tone Mapping",
        .tooltip = "Emulates output decoding used on SDR displays.",
        .labels = {"None", "2.2", "BT.1886"},
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapScaling",
        .binding = &shader_injection.tone_map_per_channel,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Scaling",
        .section = "Tone Mapping",
        .tooltip = "Luminance scales colors consistently while per-channel saturates and clips sooner.",
        .labels = {"Luminance", "Per Channel"},
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueShift",
        .binding = &shader_injection.tone_map_hue_shift,
        .default_value = 100.f,
        .label = "Hue Shift Correction",
        .section = "Tone Mapping",
        .tooltip = "Preserves source hue after grading to reduce HDR hue drift.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapWhiteClip",
        .binding = &shader_injection.tone_map_white_clip,
        .default_value = 5.f,
        .label = "White Clip",
        .section = "Tone Mapping",
        .tooltip = "Controls the Neutwo shoulder clip point.",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type == 1.f; },
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
        .default_value = 50.f,
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
        .key = "ColorGradeBlowout",
        .binding = &shader_injection.tone_map_blowout,
        .default_value = 0.f,
        .label = "Blowout",
        .section = "Color Grading",
        .tooltip = "Controls desaturation from overexposure.",
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
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeScene",
        .binding = &shader_injection.scene_grade_strength,
        .default_value = 100.f,
        .label = "Scene Grading",
        .section = "Color Grading",
        .tooltip = "Controls the strength of the game's own scene grading and tint.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxFilmGrain",
        .binding = &shader_injection.custom_film_grain_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Film Grain",
        .section = "Effects",
        .tooltip = "Selects between the game's vanilla noise and RenoDX perceptual film grain.",
        .labels = {"Vanilla Noise", "Perceptual"},
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxFilmGrainStrength",
        .binding = &shader_injection.custom_film_grain_strength,
        .default_value = 50.f,
        .label = "Film Grain Strength",
        .section = "Effects",
        .tooltip = "Controls perceptual film grain strength.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.tone_map_type != 0.f && shader_injection.custom_film_grain_type != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAEnabled",
        .binding = &lorwin::dlaa::enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .can_reset = true,
        .label = "DLAA",
        .section = "DLAA",
        .tooltip = "Runs NVIDIA DLAA on the full-resolution scene immediately before the game's final postprocess pass.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return lorwin::dlaa::is_nvidia_device; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAARenderPreset",
        .binding = &lorwin::dlaa::render_preset,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 4.f,
        .can_reset = true,
        .label = "DLAA Render Preset",
        .section = "DLAA",
        .tooltip = "Selects the NVIDIA DLSS model preset. K is the recommended Transformer 1 preset; L and M use Transformer 2.",
        .labels = {"K (Recommended)", "J (Transformer 1)", "F (Legacy CNN)", "L (Transformer 2)", "M (Transformer 2)"},
        .is_enabled = []() { return lorwin::dlaa::is_nvidia_device && lorwin::dlaa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAADebugView",
        .binding = &shader_injection.dlaa_debug_view,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = true,
        .label = "DLAA Input Debug View",
        .section = "DLAA Investigation",
        .tooltip = "Visualizes the pre-postprocess motion vectors or synthetic history-rejection mask. White mask pixels ask DLAA to favor the current frame.",
        .labels = {"Off", "Motion Direction", "Motion Magnitude", "History Rejection Mask"},
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAMotionVectorDilation",
        .binding = &lorwin::dlaa::motion_vector_dilation,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .can_reset = true,
        .label = "Depth-Neighborhood MV Dilation",
        .section = "DLAA Investigation",
        .tooltip = "Uses AC3 Remastered-style 3x3 far-depth motion-vector dilation and jitter-quadrant selection at disocclusion edges.",
        .labels = {"Off (Raw Camera Vectors)", "On (Recommended)"},
    },
    new renodx::utils::settings::Setting{
        .key = "DLAABiasCurrentColorMask",
        .binding = &lorwin::dlaa::bias_current_color_mask,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .can_reset = true,
        .label = "Synthetic History-Rejection Mask",
        .section = "DLAA Investigation",
        .tooltip = "Favors current-frame color at depth discontinuities and where reprojected frame-to-frame color changes indicate particles, animated textures, disocclusions, or incorrect motion vectors.",
        .labels = {"Off", "On (Recommended)"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAABiasCurrentColorStrength",
        .binding = &lorwin::dlaa::bias_current_color_strength,
        .default_value = 100.f,
        .can_reset = true,
        .label = "History-Rejection Strength",
        .section = "DLAA Investigation",
        .tooltip = "Scales the synthetic current-color bias. Lower values preserve more DLAA history; higher values reject more history in unstable regions.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = []() {
          return lorwin::dlaa::enabled != 0.f && lorwin::dlaa::bias_current_color_mask != 0.f;
        },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAJitterPattern",
        .binding = &lorwin::jitter::pattern,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = true,
        .label = "Camera Jitter Override",
        .section = "DLAA Investigation",
        .tooltip = "Automatic uses Halton 8 while DLAA is enabled. Forced Off keeps DLAA active but disables both viewport jitter and the jitter supplied to NGX.",
        .labels = {"Automatic", "Halton 8 (Forced)", "Four Quadrants (Debug)", "Off (Forced)"},
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAMotionVectorAxes",
        .binding = &lorwin::dlaa::motion_vector_axes,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 3.f,
        .can_reset = true,
        .label = "Motion Vector Direction",
        .section = "DLAA Investigation",
        .tooltip = "Changes the UV motion-vector sign at the NGX boundary. The generated texture is current-minus-previous, so inverting both axes is the expected DLSS convention.",
        .labels = {"Original (+X, +Y)", "Invert X", "Invert Y", "Invert X & Y (Recommended)"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAMotionVectorScale",
        .binding = &lorwin::dlaa::motion_vector_scale,
        .default_value = 100.f,
        .can_reset = true,
        .label = "Motion Vector Scale",
        .section = "DLAA Investigation",
        .tooltip = "Scales the full-resolution UV motion vectors after conversion to render-pixel space.",
        .min = 1.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAJitterAxes",
        .binding = &lorwin::dlaa::jitter_axes,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = true,
        .label = "NGX Jitter Direction",
        .section = "DLAA Investigation",
        .tooltip = "Changes only the pixel-space jitter passed to NGX; it does not change the camera jitter applied by the viewport.",
        .labels = {"Original (+X, +Y) (Recommended)", "Invert X", "Invert Y", "Invert X & Y"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAJitterScale",
        .binding = &lorwin::dlaa::jitter_scale,
        .default_value = 100.f,
        .can_reset = true,
        .label = "NGX Jitter Scale",
        .section = "DLAA Investigation",
        .tooltip = "Scales the pixel-space jitter handed to NGX. Zero is useful for isolating a jitter-convention problem.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAADepthInverted",
        .binding = &lorwin::dlaa::depth_inverted,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .can_reset = true,
        .label = "Depth Convention",
        .section = "DLAA Investigation",
        .tooltip = "Recreates the DLAA feature with NVIDIA's DepthInverted flag.",
        .labels = {"Standard (Recommended)", "Inverted"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAMotionVectorsJittered",
        .binding = &lorwin::dlaa::motion_vectors_jittered,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .can_reset = true,
        .label = "Motion Vectors Include Jitter",
        .section = "DLAA Investigation",
        .tooltip = "Recreates the feature with MVJittered. Keep this off because the generated motion vectors use the game's unjittered reprojection transform.",
        .labels = {"No (Recommended)", "Yes"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAHDRInput",
        .binding = &lorwin::dlaa::hdr_input,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .can_reset = true,
        .label = "NGX Color Input",
        .section = "DLAA Investigation",
        .tooltip = "Recreates the feature with IsHDR. The current RGBA8 pre-postprocess source is expected to use the non-HDR flag.",
        .labels = {"LDR (Recommended)", "HDR"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAAutoExposure",
        .binding = &lorwin::dlaa::auto_exposure,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .can_reset = true,
        .label = "NGX Auto Exposure",
        .section = "DLAA Investigation",
        .tooltip = "Recreates the feature with AutoExposure. No separate exposure texture is available, so this should normally remain enabled.",
        .labels = {"Off", "On (Recommended)"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Restore Recommended DLAA Inputs",
        .section = "DLAA Investigation",
        .group = "dlaa-debug-buttons",
        .on_change = []() {
          renodx::utils::settings::UpdateSettings({
              {"DLAAMotionVectorAxes", 3.f},
              {"DLAAMotionVectorScale", 100.f},
              {"DLAAMotionVectorDilation", 1.f},
              {"DLAABiasCurrentColorMask", 1.f},
              {"DLAABiasCurrentColorStrength", 100.f},
              {"DLAAJitterPattern", 0.f},
              {"DLAAJitterAxes", 0.f},
              {"DLAAJitterScale", 100.f},
              {"DLAADepthInverted", 0.f},
              {"DLAAMotionVectorsJittered", 0.f},
              {"DLAAHDRInput", 0.f},
              {"DLAAAutoExposure", 1.f},
          });
          lorwin::dlaa::reset_history = true;
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset DLAA History",
        .section = "DLAA Investigation",
        .group = "dlaa-debug-buttons",
        .on_change = []() { lorwin::dlaa::reset_history = true; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAResourceLogging",
        .binding = &lorwin::resource_logger::enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .can_reset = true,
        .label = "Resource Logging",
        .section = "DLAA Investigation",
        .tooltip = "Logs a short, passive burst of postprocess resources and state. Toggle off and on to capture another burst.",
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
      {"ToneMapPeakNits", 203.f},
      {"ToneMapWhiteClip", 100.f},
      {"ToneMapGameNits", 203.f},
      {"ToneMapUINits", 203.f},
      {"GammaCorrection", 1.f},
      {"ToneMapScaling", 0.f},
      {"ToneMapHueShift", 0.f},
      {"ColorGradeExposure", 1.f},
      {"ColorGradeHighlights", 50.f},
      {"ColorGradeShadows", 50.f},
      {"ColorGradeContrast", 50.f},
      {"ColorGradeSaturation", 50.f},
      {"ColorGradeHighlightSaturation", 50.f},
      {"ColorGradeBlowout", 0.f},
      {"ColorGradeFlare", 0.f},
      {"ColorGradeScene", 100.f},
      {"FxFilmGrain", 0.f},
      {"FxFilmGrainStrength", 50.f},
      {"DLAAEnabled", 0.f},
      {"DLAARenderPreset", 0.f},
      {"DLAADebugView", 0.f},
      {"DLAAJitterPattern", 0.f},
      {"DLAAMotionVectorAxes", 3.f},
      {"DLAAMotionVectorScale", 100.f},
      {"DLAAMotionVectorDilation", 1.f},
      {"DLAABiasCurrentColorMask", 1.f},
      {"DLAABiasCurrentColorStrength", 100.f},
      {"DLAAJitterAxes", 0.f},
      {"DLAAJitterScale", 100.f},
      {"DLAADepthInverted", 0.f},
      {"DLAAMotionVectorsJittered", 0.f},
      {"DLAAHDRInput", 0.f},
      {"DLAAAutoExposure", 1.f},
      {"DLAAResourceLogging", 0.f},
  });
}

bool fired_on_init_swapchain = false;

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  (void)resize;
  if (fired_on_init_swapchain) return;
  if (!renodx::utils::swapchain::IsDXGI(swapchain)) return;

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

bool initialized = false;

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for The Lord of the Rings: War in the North - Legacy Edition";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      if (!initialized) {
        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;

        renodx::mods::swapchain::expected_constant_buffer_index = 13;
        renodx::mods::swapchain::expected_constant_buffer_space = 50;
        renodx::mods::swapchain::use_resource_cloning = true;
        renodx::mods::swapchain::swapchain_proxy_compatibility_mode = false;
        renodx::mods::swapchain::swap_chain_proxy_vertex_shader = __swap_chain_proxy_vertex_shader;
        renodx::mods::swapchain::swap_chain_proxy_pixel_shader = __swap_chain_proxy_pixel_shader;
        renodx::mods::swapchain::swapchain_proxy_revert_state = true;
        renodx::mods::swapchain::SetUseHDR10(true);

        reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
        lorwin::resource_logger::InstallCallbacks(custom_shaders);
        lorwin::dlaa::InstallCallbacks(custom_shaders, &shader_injection);

/*         renodx::mods::swapchain::resource_upgrade_infos.push_back({
            .old_format = reshade::api::format::r8g8b8a8_typeless,
            .new_format = reshade::api::format::r10g10b10a2_typeless,
            .ignore_size = false,
            .aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
            .view_upgrades = renodx::utils::resource::VIEW_UPGRADES_R10G10B10A2_UNORM,
            .usage_include = reshade::api::resource_usage::render_target,
            .name = "Scene Intermediate",
        }); */

        initialized = true;
      }

      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::utils::random::Use(fdw_reason, {&shader_injection.custom_random});
  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);
  lorwin::resource_logger::Use(fdw_reason);
  lorwin::jitter::Use(fdw_reason);
  lorwin::dlaa::Use(fdw_reason);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
