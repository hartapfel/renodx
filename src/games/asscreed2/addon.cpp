/*
 * Copyright (C) 2026 Carlos Lopez
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64
#define RENODX_MODS_SWAPCHAIN_VERSION 2

#include <algorithm>
#include <d3d11.h>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"

namespace {

// Bloom prefilter, PsychoV-30 scene/LUT processing and HUD color shaders.
renodx::mods::shader::CustomShaders custom_shaders = {
    __ALL_CUSTOM_SHADERS
};
ShaderInjectData shader_injection = {
    .output_mode = 1.f,
    .paper_white_nits = 203.f,
    .peak_white_nits = 1000.f,
    .swap_chain_decoding = 2.f,
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
};

bool IsPsychoV() {
  return shader_injection.tone_map_type == 1.f;
}

// The captured DX11 frame uses the same downsampler before bloom and after
// the scene LUT for depth of field. Only the pre-LUT calls feed bloom.
bool scene_tonemapped = false;

bool IsUIColorDraw(reshade::api::command_list* cmd_list) {
  shader_injection.ui_premultiplied = 0.f;
  if (cmd_list->get_device()->get_api() != reshade::api::device_api::d3d11) return false;
  // D3D11 binds blend state separately from the pixel shader pipeline. Read
  // the actual output-merger state instead of Ghost's combined PSO subobjects.
  ID3D11BlendState* blend_state = nullptr;
  reinterpret_cast<ID3D11DeviceContext*>(cmd_list->get_native())->OMGetBlendState(&blend_state, nullptr, nullptr);
  if (blend_state == nullptr) return true;  // D3D11 default: opaque RGBA writes.
  D3D11_BLEND_DESC blend = {};
  blend_state->GetDesc(&blend);
  blend_state->Release();
  if ((blend.RenderTarget[0].RenderTargetWriteMask & 7u) == 0u) return false;
  if (!blend.RenderTarget[0].BlendEnable) return true;
  // Preserve mask/multiply identities and alpha-only draws.
  if (blend.RenderTarget[0].SrcBlend == D3D11_BLEND_DEST_COLOR
      || blend.RenderTarget[0].SrcBlend == D3D11_BLEND_INV_DEST_COLOR
      || blend.RenderTarget[0].DestBlend == D3D11_BLEND_SRC_COLOR
      || blend.RenderTarget[0].DestBlend == D3D11_BLEND_INV_SRC_COLOR) return false;
  // The sun and flare reuse the HUD shader for ONE+ONE scene draws before
  // the LUT. Keep their scene energy native; additive HUD draws after the LUT
  // still receive UI scaling. Do not classify these shared shaders by hash alone.
  if (!scene_tonemapped && blend.RenderTarget[0].BlendOp == D3D11_BLEND_OP_ADD
      && blend.RenderTarget[0].SrcBlend == D3D11_BLEND_ONE
      && blend.RenderTarget[0].DestBlend == D3D11_BLEND_ONE) return false;
  shader_injection.ui_premultiplied = blend.RenderTarget[0].SrcBlend == D3D11_BLEND_ONE
                                            && blend.RenderTarget[0].DestBlend == D3D11_BLEND_INV_SRC_ALPHA
                                        ? 1.f : 0.f;
  return true;
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
        .tooltip = "Vanilla retains the original LUT path. PsychoV-30 maps the preserved scene range with custom grading.",
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
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All",
        .section = "Options",
        .group = "button-line-2",
        .on_change = []() { renodx::utils::settings::ResetSettings(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Enable Windows HDR and use dgVoodoo's DirectX 11 output.",
        .section = "Instructions",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Peak Brightness is detected automatically; adjust if needed. Game and UI Brightness default to 203 nits.",
        .section = "Instructions",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Use Advanced settings for color grading. Output is HDR10 with gamma 2.2 input.",
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
  });
}

void OnPresent(reshade::api::command_queue*,
               reshade::api::swapchain* swapchain,
               const reshade::api::rect*,
               const reshade::api::rect*,
               uint32_t,
               const reshade::api::rect*) {
  if (swapchain == nullptr || !renodx::mods::swapchain::IsUpgraded(swapchain)) return;

  scene_tonemapped = false;

  renodx::mods::swapchain::target_color_space = reshade::api::color_space::hdr10_st2084;
  if (swapchain->get_color_space() != renodx::mods::swapchain::target_color_space) {
    renodx::utils::swapchain::ChangeColorSpace(swapchain, renodx::mods::swapchain::target_color_space);
  }
}

bool fired_on_init_swapchain = false;
bool initialized = false;

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  (void)resize;
  if (fired_on_init_swapchain) return;

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

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX for Assassin's Creed II";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "Assassin's Creed II (dgVoodoo DX11, PsychoV-30 HDR)";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      if (!initialized) {
        custom_shaders.at(0x61888319u).on_draw = [](reshade::api::command_list*) {
          scene_tonemapped = true;
          return true;
        };
        custom_shaders.at(0x8FA72580u).on_replace = [](reshade::api::command_list* cmd_list) {
          return !scene_tonemapped && IsPsychoV()
                 && cmd_list->get_device()->get_api() == reshade::api::device_api::d3d11;
        };
        for (const auto hash : {0x0DA2DE91u, 0x12BA0F50u, 0x2EAA46EBu}) {
          custom_shaders.at(hash).on_replace = &IsUIColorDraw;
        }
        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;

        renodx::mods::swapchain::expected_constant_buffer_index = 13;
        renodx::mods::swapchain::expected_constant_buffer_space = 50;
        renodx::mods::swapchain::ignored_device_apis = {
            reshade::api::device_api::d3d9,
            reshade::api::device_api::d3d10,
            reshade::api::device_api::d3d12,
            reshade::api::device_api::opengl,
            reshade::api::device_api::vulkan,
        };
        renodx::mods::swapchain::SetUseHDR10(true);
        // dgVoodoo reuses pipeline state across video frames. Restore its
        // topology, viewport and bindings after the fullscreen output pass.
        renodx::mods::swapchain::swapchain_proxy_revert_state = true;
        renodx::mods::swapchain::use_resource_cloning = true;
        renodx::mods::swapchain::swap_chain_proxy_format = reshade::api::format::r16g16b16a16_float;
        renodx::mods::swapchain::swap_chain_proxy_shaders = {
            {reshade::api::device_api::d3d11,
             {
                 .vertex_shader = __swap_chain_proxy_vertex_shader_dx11,
                 .pixel_shader = __swap_chain_proxy_pixel_shader_dx11,
             }},
        };

        // dgVoodoo creates the scene target before its final swapchain size is
        // available. Match the captured 16:9 color RT family from device init.
        // The tolerance includes rounded bloom levels (e.g. 30x16 at 1080p).
        // Cloning preserves the wrapper's original integer views; replacing
        // the resource format directly prevents those views from being created.
        renodx::mods::swapchain::resource_upgrade_infos.push_back({
            .old_format = reshade::api::format::r8g8b8a8_typeless,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .use_resource_view_cloning = true,
            .aspect_ratio = 16.f / 9.f,
            .aspect_ratio_tolerance = 0.1f,
            .usage_include = reshade::api::resource_usage::render_target,
            .usage_exclude = reshade::api::resource_usage::depth_stencil | reshade::api::resource_usage::unordered_access,
            .name = "AC2 Scene / Bloom / Postprocess / HUD",
        });

        reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
        reshade::register_event<reshade::addon_event::present>(OnPresent);
        initialized = true;
      }
      break;

    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::swapchain::target_color_space = reshade::api::color_space::hdr10_st2084;
  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);
  return TRUE;
}
