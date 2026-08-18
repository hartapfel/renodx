/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define RENODX_MODS_SWAPCHAIN_VERSION 2

#include <optional>
#include <sstream>

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
float dlaa_debug = 0.f;
bool hdr_output_active = false;
bool hdr_output_state_known = false;

bool IsDlaaDebugEnabled() {
  return dlaa_debug != 0.f;
}

bool IsHDROutputActive() {
  return !hdr_output_state_known || hdr_output_active;
}

void SetHDROutputState(bool active, const char* source) {
  const bool changed = !hdr_output_state_known || hdr_output_active != active;
  hdr_output_state_known = true;
  hdr_output_active = active;
  shader_injection.hdr_output_active = active ? 1.f : 0.f;
  if (!changed) return;

  std::stringstream s;
  s << "LORWIN output: Windows HDR is " << (active ? "enabled" : "disabled")
    << " via " << source << "; HDR tonemapping and swapchain proxy "
    << (active ? "enabled." : "disabled, vanilla SDR tonemapping forced.");
  reshade::log::message(reshade::log::level::info, s.str().c_str());
}

std::optional<bool> GetWindowHDRState(HWND window) {
  if (window == nullptr || IsWindow(window) == FALSE) return std::nullopt;
  const HMONITOR monitor = MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST);
  if (monitor == nullptr) return std::nullopt;
  const auto path = renodx::utils::platform::GetPathInfo(monitor);
  if (!path.has_value()) return std::nullopt;
  return renodx::utils::swapchain::GetHDREnabled(path.value());
}

#if RESHADE_API_VERSION >= 17
bool OnCreateSwapchain(reshade::api::device_api device_api, reshade::api::swapchain_desc& desc, void* hwnd) {
#else
bool OnCreateSwapchain(reshade::api::swapchain_desc& desc, void* hwnd) {
  const auto device_api = reshade::api::device_api::d3d12;
#endif
  if (device_api != reshade::api::device_api::d3d12) return false;
  const auto window = static_cast<HWND>(hwnd);
  if (!renodx::mods::swapchain::ShouldModifySwapchain(window, device_api)) return false;

  const auto hdr_enabled = GetWindowHDRState(window);
  if (!hdr_enabled.has_value()) return false;
  SetHDROutputState(hdr_enabled.value(), "swapchain creation");

  if (hdr_enabled.value()) {
    renodx::mods::swapchain::SetUseHDR10(true);
    renodx::mods::swapchain::use_resource_cloning = true;
    renodx::mods::swapchain::use_resize_buffer = false;
    renodx::mods::swapchain::set_color_space = true;
  } else {
    renodx::mods::swapchain::target_format = desc.back_buffer.texture.format;
    renodx::mods::swapchain::use_resource_cloning = false;
    renodx::mods::swapchain::use_resize_buffer = true;
    renodx::mods::swapchain::set_color_space = false;
  }
  return false;
}

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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
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
        .is_visible = IsHDROutputActive,
    },
    new renodx::utils::settings::Setting{
        .key = "ImprovedAmbientOcclusion",
        .binding = &shader_injection.improved_ambient_occlusion,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .can_reset = true,
        .label = "Improved Ambient Occlusion",
        .section = "Rendering Fixes",
        .tooltip = "Uses a stable multi-radius SSAO kernel and depth-aware blur to reduce crawling and silhouette artifacts during movement.",
        .labels = {"Vanilla", "Improved"},
    },
    new renodx::utils::settings::Setting{
        .key = "ImprovedBloom",
        .binding = &shader_injection.improved_bloom,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .can_reset = true,
        .label = "Improved Bloom",
        .section = "Rendering Fixes",
        .tooltip = "Uses an HDR-aware luminance soft knee to preserve highlight energy. SDR always uses the vanilla bloom path.",
        .labels = {"Vanilla", "Improved"},
    },
    new renodx::utils::settings::Setting{
        .key = "ImprovedBloomStrength",
        .binding = &shader_injection.improved_bloom_strength,
        .default_value = 150.f,
        .can_reset = true,
        .label = "Bloom Strength",
        .section = "Rendering Fixes",
        .tooltip = "Scales the HDR energy produced by Improved Bloom. This does not affect vanilla or SDR bloom.",
        .max = 400.f,
        .is_enabled = []() { return IsHDROutputActive() && shader_injection.improved_bloom != 0.f; },
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
        .tooltip = "Selects the NVIDIA DLSS model preset. M is the default Transformer 2 preset; K and J use Transformer 1, F uses the legacy CNN, and L also uses Transformer 2.",
        .labels = {"K (Transformer 1)", "J (Transformer 1)", "F (Legacy CNN)", "L (Transformer 2)", "M (Recommended)"},
        .is_enabled = []() { return lorwin::dlaa::is_nvidia_device && lorwin::dlaa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAADebug",
        .binding = &dlaa_debug,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .can_reset = true,
        .label = "Debug",
        .section = "DLAA Debugging",
        .tooltip = "Shows organized DLAA visualization, history, motion-vector, and jitter diagnostics.",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Visualization",
        .section = "DLAA Debugging",
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAADebugView",
        .binding = &shader_injection.dlaa_debug_view,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = true,
        .label = "Resource View",
        .section = "DLAA Debugging",
        .tooltip = "Visualizes the exact private resources at the NGX boundary. Input Color is the pInColor copy and Output Color is pInOutput before the game's native postprocess. Difference views use 8x gain. Invalid views use magenta for non-finite values, yellow for out-of-range values, and dark green for valid values.",
        .labels = {
            "Off",
            "NGX Input Color (Pre-DLAA)",
            "NGX Output Color (Post-DLAA)",
            "Input / Output Split",
            "Absolute Output Difference (8x)",
            "Signed Output Difference (8x)",
            "Motion Direction",
            "Motion Magnitude",
            "Depth (Raw)",
            "Depth Discontinuities",
            "History Rejection Mask",
            "Invalid NGX Input",
            "Invalid NGX Output",
            "Four-View Overview",
        },
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "History & Reconstruction",
        .section = "DLAA Debugging",
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAMotionVectorDilation",
        .binding = &lorwin::dlaa::motion_vector_dilation,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .can_reset = true,
        .label = "Depth-Neighborhood MV Dilation",
        .section = "DLAA Debugging",
        .tooltip = "Uses AC3 Remastered-style 3x3 far-depth motion-vector dilation and jitter-quadrant selection at disocclusion edges.",
        .labels = {"Off (Raw Camera Vectors)", "On (Recommended)"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAABiasCurrentColorMask",
        .binding = &lorwin::dlaa::bias_current_color_mask,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .can_reset = true,
        .label = "Synthetic History-Rejection Mask",
        .section = "DLAA Debugging",
        .tooltip = "Favors current-frame color at depth discontinuities and where reprojected frame-to-frame color changes indicate particles, animated textures, disocclusions, or incorrect motion vectors.",
        .labels = {"Off", "On (Recommended)"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAABiasCurrentColorStrength",
        .binding = &lorwin::dlaa::bias_current_color_strength,
        .default_value = 100.f,
        .can_reset = true,
        .label = "History-Rejection Strength",
        .section = "DLAA Debugging",
        .tooltip = "Scales the synthetic current-color bias. Lower values preserve more DLAA history; higher values reject more history in unstable regions.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = []() {
          return lorwin::dlaa::enabled != 0.f && lorwin::dlaa::bias_current_color_mask != 0.f;
        },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAForceHistoryReset",
        .binding = &lorwin::dlaa::force_history_reset,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .can_reset = true,
        .label = "Reset NGX History Every Frame",
        .section = "DLAA Debugging",
        .tooltip = "Forces InReset on every NGX evaluation. If ghosting disappears, the problem is temporal history or reprojection rather than current-frame reconstruction.",
        .labels = {"Normal History (Recommended)", "Reset Every Frame"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Motion-Vector Input",
        .section = "DLAA Debugging",
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAMotionVectorAxes",
        .binding = &lorwin::dlaa::motion_vector_axes,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 3.f,
        .can_reset = true,
        .label = "Motion Vector Direction",
        .section = "DLAA Debugging",
        .tooltip = "Changes the UV motion-vector sign at the NGX boundary. The generated texture is current-minus-previous, so inverting both axes is the expected DLSS convention.",
        .labels = {"Original (+X, +Y)", "Invert X", "Invert Y", "Invert X & Y (Recommended)"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAMotionVectorScale",
        .binding = &lorwin::dlaa::motion_vector_scale,
        .default_value = 100.f,
        .can_reset = true,
        .label = "Motion Vector Scale",
        .section = "DLAA Debugging",
        .tooltip = "Scales the full-resolution UV motion vectors after conversion to render-pixel space.",
        .min = 1.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Jitter Input",
        .section = "DLAA Debugging",
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAJitterPattern",
        .binding = &lorwin::jitter::pattern,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = true,
        .label = "Camera Jitter Override",
        .section = "DLAA Debugging",
        .tooltip = "Automatic uses Halton 8 while DLAA is enabled. Forced Off keeps DLAA active but disables both viewport jitter and the jitter supplied to NGX.",
        .labels = {"Automatic", "Halton 8 (Forced)", "Four Quadrants (Debug)", "Off (Forced)"},
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAACameraJitterScale",
        .binding = &lorwin::jitter::camera_jitter_scale,
        .default_value = 100.f,
        .can_reset = true,
        .label = "Camera Projection Jitter Scale",
        .section = "DLAA Debugging",
        .tooltip = "Scales the jitter applied to the main-scene viewport. 100% is correct. Larger values are a deliberately invalid visibility test and suppress NGX jitter while resetting history.",
        .min = 0.f,
        .max = 20000.f,
        .format = "%.0f%%",
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAJitterAxes",
        .binding = &lorwin::dlaa::jitter_axes,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = true,
        .label = "NGX Jitter Direction",
        .section = "DLAA Debugging",
        .tooltip = "Changes only the pixel-space jitter passed to NGX; it does not change the camera jitter applied by the viewport.",
        .labels = {"Original (+X, +Y) (Recommended)", "Invert X", "Invert Y", "Invert X & Y"},
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAJitterScale",
        .binding = &lorwin::dlaa::jitter_scale,
        .default_value = 100.f,
        .can_reset = true,
        .label = "NGX Jitter Scale",
        .section = "DLAA Debugging",
        .tooltip = "Scales only the pixel-space jitter handed to NGX. Zero isolates a jitter-convention problem. Values above about 114% make the largest Halton-8 X sample exceed the supported -0.5 to +0.5 pixel range; they are passed through only as a diagnostic and are not suitable as a final setting.",
        .min = 0.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Tools",
        .section = "DLAA Debugging",
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Restore Recommended DLAA Inputs",
        .section = "DLAA Debugging",
        .group = "dlaa-debug-buttons",
        .on_change = []() {
          renodx::utils::settings::UpdateSettings({
              {"DLAAMotionVectorAxes", 3.f},
              {"DLAAMotionVectorScale", 100.f},
              {"DLAAMotionVectorDilation", 1.f},
              {"DLAABiasCurrentColorMask", 1.f},
              {"DLAABiasCurrentColorStrength", 100.f},
              {"DLAAJitterPattern", 0.f},
              {"DLAACameraJitterScale", 100.f},
              {"DLAAJitterAxes", 0.f},
              {"DLAAJitterScale", 100.f},
              {"DLAAForceHistoryReset", 0.f},
          });
          lorwin::dlaa::reset_history = true;
        },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset DLAA History",
        .section = "DLAA Debugging",
        .group = "dlaa-debug-buttons",
        .on_change = []() { lorwin::dlaa::reset_history = true; },
        .is_visible = IsDlaaDebugEnabled,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Capture Scene Jitter Coverage",
        .section = "DLAA Debugging",
        .tooltip = "Starts a 60-frame audit of every graphics pass writing the resource lineage used as postprocess g_SceneTexture. The log separates covered scene contributors, missed contributors, and selected-depth passes that do not contribute to scene color.",
        .is_enabled = []() { return lorwin::dlaa::enabled != 0.f; },
        .on_change = []() { lorwin::jitter::StartCoverageCapture(); },
        .is_visible = IsDlaaDebugEnabled,
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
        .is_visible = IsHDROutputActive,
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
      {"ImprovedAmbientOcclusion", 0.f},
      {"ImprovedBloom", 0.f},
      {"ImprovedBloomStrength", 100.f},
      {"DLAAEnabled", 0.f},
      {"DLAARenderPreset", 0.f},
      {"DLAADebug", 0.f},
      {"DLAADebugView", 0.f},
      {"DLAAJitterPattern", 0.f},
      {"DLAACameraJitterScale", 100.f},
      {"DLAAMotionVectorAxes", 3.f},
      {"DLAAMotionVectorScale", 100.f},
      {"DLAAMotionVectorDilation", 1.f},
      {"DLAABiasCurrentColorMask", 1.f},
      {"DLAABiasCurrentColorStrength", 100.f},
      {"DLAAJitterAxes", 0.f},
      {"DLAAJitterScale", 100.f},
      {"DLAAForceHistoryReset", 0.f},
  });
}

bool fired_on_init_swapchain = false;

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  (void)resize;
  if (!renodx::utils::swapchain::IsDXGI(swapchain)) return;

  const auto display_info = renodx::utils::swapchain::GetDisplayInfo(swapchain);
  if (display_info.display_config.has_value()) {
    SetHDROutputState(display_info.hdr_enabled, "swapchain initialization");
  }
  if (!IsHDROutputActive() || fired_on_init_swapchain) return;

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
        renodx::mods::swapchain::prevent_full_screen = false;
        renodx::mods::swapchain::force_borderless = false;
        renodx::mods::swapchain::force_screen_tearing = false;
        renodx::mods::swapchain::SetUseHDR10(true);

        reshade::register_event<reshade::addon_event::create_swapchain>(OnCreateSwapchain);
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
      reshade::unregister_event<reshade::addon_event::create_swapchain>(OnCreateSwapchain);
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
