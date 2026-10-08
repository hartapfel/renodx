/*
 * Copyright (C) 2026 Carlos Lopez
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64
#define DEBUG_LEVEL_0

// Do not share shader/layout state or device data with another RenoDX DLL.
#define RENODX_PRIVATE_DATA_NAMESPACE 0x444E524Du

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>
#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"
#include "./night_lighting.hpp"
#include "./vegetation_saturation.hpp"

namespace {

renodx::mods::shader::CustomShaders custom_shaders = {
#ifdef __ALL_CUSTOM_SHADERS
    __ALL_CUSTOM_SHADERS
#endif
};

bool IsNightLightingEnabled() {
  return witcher::night::lighting_enabled == 1.f && witcher::night::Supported();
}

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "GameplayCameraLightStrength",
        .binding = &witcher::night::camera_strength,
        .default_value = 50.f,
        .label = "Gameplay Camera Light",
        .section = "Camera Lighting",
        .tooltip = "Player-following fill light, day and night. 0 = off, 50 = native, 100 = double.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return witcher::night::Supported() && witcher::night::camera_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "CutsceneCameraLightStrength",
        .binding = &witcher::night::cutscene_strength,
        .default_value = 50.f,
        .label = "Cutscene Camera Light",
        .section = "Camera Lighting",
        .tooltip = "Artificial scene and dialogue camera fill. 0 = off, 50 = native, 100 = double.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return witcher::night::Supported() && witcher::night::cutscene_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightLightingEnabled",
        .binding = &witcher::night::lighting_enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Enable Night Lighting",
        .section = "Night Lighting",
        .tooltip = "Enables the night sliders. Off restores native lighting and grading; keeps your slider values.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return witcher::night::Supported(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Smoothly adjusts nighttime light and colour during the hours below. Local lights stay native. Light intensity: 0 = off, 50 = native, 100 = double.",
        .section = "Night Lighting",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Soft Nights",
        .section = "Night Lighting",
        .group = "night-lighting-presets",
        .tooltip = "Restores the default softer night lighting settings.",
        .is_enabled = []() { return witcher::night::Supported(); },
        .on_change = []() {
          for (const auto* setting : settings) {
            if (!setting->key.starts_with("Night")) continue;
            renodx::utils::settings::UpdateSetting(setting->key, setting->default_value);
          }
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Dark Nights",
        .section = "Night Lighting",
        .group = "night-lighting-presets",
        .tooltip = "Applies the darker night lighting preset.",
        .is_enabled = []() { return witcher::night::Supported(); },
        .on_change = []() {
          renodx::utils::settings::UpdateSettings({
              {"NightLightingEnabled", 1.f},
              {"NightDarkeningStart", 20.f},
              {"NightFullDarknessStart", 23.f},
              {"NightFadeOutStart", 3.5f},
              {"NightDarkeningEnd", 6.f},
              {"NightSkyStrength", 5.f},
              {"NightDirectStrength", 5.f},
              {"NightFogStrength", 5.f},
              {"NightHazeStrength", 5.f},
              {"NightVisibleSkyStrength", 5.f},
              {"NightCloudStrength", 10.f},
              {"NightRainStrength", 10.f},
              {"NightWaterStrength", 0.f},
              {"NightColorGradeLuminance", 100.f},
              {"NightColorGradeChroma", 100.f},
              {"NightSaturation", 50.f},
          });
        },
    },
    new renodx::utils::settings::Setting{
        .key = "NightDarkeningStart",
        .binding = &witcher::night::darkening_start,
        .default_value = 20.f,
        .label = "Darkening Start",
        .section = "Night Schedule",
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
        .section = "Night Schedule",
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
        .section = "Night Schedule",
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
        .section = "Night Schedule",
        .tooltip = "Time when native lighting is fully restored.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Choose Start, Full Darkness, Fade-out, then End in that order within one day. Overrides are inactive until the times form a valid schedule.",
        .section = "Night Schedule",
        .is_visible = []() { return witcher::night::lighting_enabled == 1.f && witcher::night::NightSchedule() == 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightSkyStrength",
        .binding = &witcher::night::sky_strength,
        .default_value = 15.f,
        .label = "Skylight",
        .section = "Night Illumination",
        .tooltip = "Skylight, outdoor probe illumination and the sky contribution to water reflections.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightDirectStrength",
        .binding = &witcher::night::direct_strength,
        .default_value = 15.f,
        .label = "Direct Light",
        .section = "Night Illumination",
        .tooltip = "Direct directional light from the environment, including grass illumination.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightWaterStrength",
        .binding = &witcher::night::water_strength,
        .default_value = 0.f,
        .label = "Water Lighting",
        .section = "Night Illumination",
        .tooltip = "Water base color and ambient/diffuse fill. Preserves reflections and refraction.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightFogStrength",
        .binding = &witcher::night::fog_strength,
        .default_value = 15.f,
        .label = "Directional Fog",
        .section = "Night Atmosphere",
        .tooltip = "Brightness of directional and custom fog colors. Preserves fog density.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightHazeStrength",
        .binding = &witcher::night::haze_strength,
        .default_value = 5.f,
        .label = "Aerial Haze",
        .section = "Night Atmosphere",
        .tooltip = "Brightness of aerial haze and distance fog. Preserves atmospheric extinction.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightVisibleSkyStrength",
        .binding = &witcher::night::visible_sky_strength,
        .default_value = 5.f,
        .label = "Sky Brightness",
        .section = "Night Atmosphere",
        .tooltip = "Visible sky, horizon glow and horizon tint on distant clouds. Preserves the moon and stars.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightCloudStrength",
        .binding = &witcher::night::cloud_strength,
        .default_value = 15.f,
        .label = "Cloud Brightness",
        .section = "Night Atmosphere",
        .tooltip = "Cloud brightness and cloud/smoke volume glow. Preserves coverage.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightRainStrength",
        .binding = &witcher::night::rain_strength,
        .default_value = 15.f,
        .label = "Rain Brightness",
        .section = "Night Atmosphere",
        .tooltip = "Brightness of falling rain streaks. Preserves weather intensity and wet surfaces.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::rain_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightColorGradeLuminance",
        .binding = &witcher::night::grading::luminance_strength,
        .default_value = 100.f,
        .label = "Brightness & Contrast",
        .section = "Night Colour Grading",
        .tooltip = "Night grade's brightness and contrast curve. 0 removes it; 100 keeps the normal strength.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::grading::supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightColorGradeChroma",
        .binding = &witcher::night::grading::chroma_strength,
        .default_value = 100.f,
        .label = "Tint & Saturation",
        .section = "Night Colour Grading",
        .tooltip = "Night grade's colour tint and saturation. 0 removes it; 100 keeps the normal strength.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::grading::supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightSaturation",
        .binding = &witcher::night::grading::saturation_strength,
        .default_value = 50.f,
        .label = "Vegetation Saturation",
        .section = "Night Colour Grading",
        .tooltip = "Reduces green/cyan saturation, with gentler yellow/blue coverage. 100 is native. Matching non-foliage colours also respond.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "MoonSize",
        .binding = &witcher::night::moon_size,
        .default_value = 50.f,
        .label = "Moon Size",
        .section = "Sky Appearance",
        .tooltip = "Moon diameter: 100% = native, 50% = half, 500% = five times.",
        .min = 1.f,
        .max = 500.f,
        .format = "%.0f%%",
        .is_enabled = []() { return witcher::night::Supported() && witcher::night::moon_supported; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All Settings",
        .section = "Options",
        .on_change = []() { renodx::utils::settings::ResetSettings(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Times use a 24-hour clock and can cross midnight. Camera lights and moon size work independently of night lighting. Preset Off restores all native values.",
        .section = "Help & About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Lighting controls are unavailable for this executable build.",
        .section = "Help & About",
        .is_visible = []() { return !witcher::night::Supported(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Game mod by Hartapfel; RenoDX framework by ShortFuse.",
        .section = "Help & About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
        .section = "Help & About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "RenoDX Discord",
        .section = "Community & Support",
        .group = "button-line-2",
        .tint = 0x5865F2,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/", "Ce9bQHQrSV"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "HDR Den Discord",
        .section = "Community & Support",
        .group = "button-line-2",
        .tint = 0x5865F2,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/", "5WZXDpmbpP"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Github",
        .section = "Community & Support",
        .group = "button-line-2",
        .tint = 0x2B3137,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Hartapfel's Ko-Fi",
        .section = "Community & Support",
        .group = "button-line-3",
        .tint = 0xFF5A16,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/hartapfel"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "ShortFuse's Ko-Fi",
        .section = "Community & Support",
        .group = "button-line-3",
        .tint = 0xFF5A16,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/shortfuse"); },
    },
};

void OnPresetOff() {
  renodx::utils::settings::UpdateSettings({
      {"NightLightingEnabled", 0.f},
      {"GameplayCameraLightStrength", 50.f},
      {"CutsceneCameraLightStrength", 50.f},
      {"MoonSize", 100.f},
      {"NightSaturation", 100.f},
  });
  witcher::night::vegetation::delta.store(0.f, std::memory_order_relaxed);
  if (witcher::night::installed) witcher::night::Update(false);
}

void OnPresent(reshade::api::command_queue*, reshade::api::swapchain*, const reshade::api::rect*,
               const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  witcher::night::Update(true);
  witcher::night::vegetation::delta.store(IsNightLightingEnabled() && witcher::night::installed
          && witcher::night::NightSchedule() != 0
          && std::isfinite(witcher::night::grading::saturation_strength)
      ? (std::clamp(witcher::night::grading::saturation_strength / 100.f, 0.f, 2.f) - 1.f)
          * std::clamp(witcher::night::night_weight.load(std::memory_order_relaxed), 0.f, 1.f)
      : 0.f, std::memory_order_relaxed);
  static bool reported = false;
  if (witcher::night::attempted && !reported) {
    reshade::log::message(witcher::night::installed ? reshade::log::level::info : reshade::log::level::warning,
                         witcher::night::installed ? "[RenoDX Witcher Lighting] Native lighting controls installed."
                                                   : "[RenoDX Witcher Lighting] Unsupported build; native lighting preserved.");
    if (witcher::night::installed && !witcher::night::camera_supported) {
      reshade::log::message(reshade::log::level::warning,
                           "[RenoDX Witcher Lighting] Gameplay camera-light control unavailable.");
    }
    if (witcher::night::installed) {
      reshade::log::message(witcher::night::water_sky_supported ? reshade::log::level::info : reshade::log::level::warning,
                           witcher::night::water_sky_supported ? "[RenoDX Witcher Lighting] Water sky contribution follows Skylight."
                                                               : "[RenoDX Witcher Lighting] Water sky contribution control unavailable.");
    }
    if (witcher::night::installed) {
      reshade::log::message(witcher::night::cutscene_supported ? reshade::log::level::info : reshade::log::level::warning,
                           witcher::night::cutscene_supported ? "[RenoDX Witcher Lighting] Cutscene camera-light control installed."
                                                              : "[RenoDX Witcher Lighting] Cutscene camera-light control unavailable.");
    }
    if (witcher::night::installed && !witcher::night::grading::supported) {
      reshade::log::message(reshade::log::level::warning,
                           "[RenoDX Witcher Lighting] Night grading controls unavailable.");
    }
    reported = true;
  }
}

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "Darker Nights - Remastered";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION =
    "The Witcher 3 Remastered: standalone night, gameplay and cutscene lighting controls by Hartapfel";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;
      renodx::utils::settings::global_name = "renodx-darkernights-remastered";
      // Helper compute code is an independent pass, never a game replacement.
      custom_shaders.erase(0xF3B20000);
      renodx::mods::shader::force_pipeline_cloning = true;
      for (auto& [hash, shader] : custom_shaders) {
        // Every replacement uses existing native constants and layouts.
        shader.on_inject = [](auto*) { return false; };
        if (hash == 0x14AEBBFB || hash == 0x680C44CE) {
          shader.on_replace = [hash](auto* cmd_list) {
            return witcher::night::installed && witcher::night::moon_supported
                   && witcher::night::moon_multiplier.load(std::memory_order_relaxed) != 1.f
                   && renodx::utils::shader::GetCurrentPixelShaderHash(
                          renodx::utils::shader::GetCurrentState(cmd_list))
                          == (hash == 0x680C44CE ? 0x6D5A1EC2 : 0xE446F231);
          };
        } else if (hash == 0x04251B31) {
          shader.on_replace = [](auto* cmd_list) {
            const uint32_t vertex = renodx::utils::shader::GetCurrentVertexShaderHash(
                renodx::utils::shader::GetCurrentState(cmd_list));
            return witcher::night::installed && witcher::night::rain_supported
                   && witcher::night::rain_multiplier.load(std::memory_order_relaxed) != 1.f
                   && witcher::night::night_weight.load(std::memory_order_relaxed) > 0.f
                   && (vertex == 0x5653D7C9 || vertex == 0xDE079650);
          };
        } else if (hash == 0xE6A77B56 || hash == 0x8DBF022F || hash == 0xEAAAC84D || hash == 0x1C12BED7
            || hash == 0x1B63829B || hash == 0x56511D80 || hash == 0xD2C88922 || hash == 0x02320E1A) {
          shader.on_replace = [](auto*) {
            return witcher::night::installed
                   && witcher::night::sky_multiplier.load(std::memory_order_relaxed) != 1.f
                   && witcher::night::night_weight.load(std::memory_order_relaxed) > 0.f;
          };
        } else {
          shader.on_replace = [](auto*) {
            return witcher::night::installed
                   && witcher::night::cloud_multiplier.load(std::memory_order_relaxed) != 1.f
                   && witcher::night::night_weight.load(std::memory_order_relaxed) > 0.f;
          };
        }
      }
      // HDR addons that replace at pipeline creation expose their bytecode
      // hashes to our isolated tracker. Observe the audited replacements too;
      // keep the foreign shader, settings binding and root signature intact.
      for (uint32_t hash : {0x16967617u, 0x9600E32Au, 0xAD02BAB3u, 0xC5AB358Eu, 0xF961D049u,
                            0x2BF760E2u,  // Toussaint grading with texture vignette
                            0x6DDA5B7Bu,  // Photo Mode grading; observe scene before UI
                            0xE715845Fu,  // Photo Mode replacement, HDR v0.2026.1006.1950
                            0x3BC7DBE4u,  // 0x16967617, installed HDR v0.2026.1003.311
                            0x2957BB38u,  // 0xAD02BAB3
                            0x823D59CBu,  // 0xC5AB358E
                            0xBEDA0207u,  // 0xF961D049
                            0xE8588026u,  // 0x16967617, installed HDR v0.2026.1006.1950
                            0x8074E167u,  // 0x9600E32A
                            0xE22E8A08u,  // 0xAD02BAB3
                            0x3ADEE5E4u,  // 0xC5AB358E
                            0x8DC14D3Bu,  // 0xF961D049
                            0xFF89140Cu}) {  // 0x2BF760E2, installed HDR v0.2026.1006.1950
        custom_shaders.emplace(hash, renodx::mods::shader::CustomShader{
            .crc32 = hash,
            .on_replace = [](auto*) { return false; },
            .on_inject = [](auto*) { return false; },
            .on_draw = &witcher::night::vegetation::Arm,
        });
      }
      reshade::register_event<reshade::addon_event::present>(OnPresent);
      break;
    case DLL_PROCESS_DETACH:
      if (witcher::night::installed) witcher::night::Update(false);
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      break;
  }
  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  if (fdw_reason == DLL_PROCESS_ATTACH) {
    // Persist the top-level selector independently of the individual profiles.
    renodx::utils::settings::on_preset_changed_callbacks.emplace_back([]() {
      reshade::set_config_value(nullptr, renodx::utils::settings::global_name.c_str(),
                               "SelectedPreset", renodx::utils::settings::preset_index);
    });
    int selected_preset = 1;
    if (!reshade::get_config_value(nullptr, renodx::utils::settings::global_name.c_str(),
                                  "SelectedPreset", selected_preset)
        || selected_preset < 0 || selected_preset > 3) selected_preset = 1;
    renodx::utils::settings::preset_index = selected_preset;
    if (selected_preset == 0) OnPresetOff();
    else if (selected_preset != 1) {
      renodx::utils::settings::LoadSettings(renodx::utils::settings::GetCurrentPresetName());
    }
  }
  renodx::mods::shader::Use(fdw_reason, custom_shaders);
  renodx::utils::swapchain::Use(fdw_reason);
  witcher::night::vegetation::Use(fdw_reason);
  // Utility detach can transfer event ownership. Keep this addon registered
  // until all of its framework callbacks have been removed.
  if (fdw_reason == DLL_PROCESS_DETACH) reshade::unregister_addon(h_module);
  return TRUE;
}
