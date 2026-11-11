/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <tuple>
#include "../sky/settings.hpp"

#include "../../../mods/shader.hpp"
#include "../../../utils/settings.hpp"
#include "night_lighting.hpp"
#include "vegetation_saturation.hpp"

namespace witcher::night::ui {

inline bool IsNightLightingEnabled() {
  return witcher::night::lighting_enabled == 1.f && witcher::night::Supported();
}


inline renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "NightLightingEnabled",
        .binding = &witcher::night::lighting_enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Night Lighting",
        .section = "Night Lighting",
        .tooltip = "Enables the night brightness, colour and exposure adjustments.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return witcher::night::Supported(); },
    },
    new renodx::utils::settings::Setting{
        .key = "NightRegionalNormalization",
        .binding = &witcher::night::normalization::enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Balance Regions",
        .section = "Night Lighting",
        .tooltip = "Keeps night lighting more consistent between different regions.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::normalization::supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightWeatherNormalization",
        .binding = &witcher::night::normalization::weather_enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Balance Weather",
        .section = "Night Lighting",
        .tooltip = "Balances night lighting while preserving each weather's mood.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::normalization::weather_supported; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Smoothly adjusts nighttime light and colour during the hours below. Local lights stay native. Light intensity: 0 = off, 50 = baseline, 100 = double. Normalization balances regional and weather baselines.",
        .section = "Night Lighting",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Soft Nights",
        .section = "Night Lighting",
        .group = "night-lighting-presets",
        .tooltip = "Applies softer night lighting and smooth brightness adaptation.",
        .is_enabled = []() { return witcher::night::Supported(); },
        .on_change = []() {
          renodx::utils::settings::UpdateSettings({
              {"NightLightingEnabled", 1.f},
              {"NightRegionalNormalization", 1.f},
              {"NightWeatherNormalization", 1.f},
              {"NightDarkeningStart", 18.f},
              {"NightFullDarknessStart", 23.f},
              {"NightFadeOutStart", 3.5f},
              {"NightDarkeningEnd", 6.f},
              {"NightSkyStrength", 15.f},
              {"NightDirectStrength", 15.f},
              {"NightFogStrength", 15.f},
              {"NightHazeStrength", 15.f},
              {"NightVisibleSkyStrength", 15.f},
              {"NightSkyHazeStrength", 15.f},
              {"NightMoonStrength", 35.f},
              {"NightCloudStrength", 15.f},
              {"NightRainStrength", 15.f},
              {"NightWaterStrength", 0.f},
              {"NightColorGradeLuminance", 100.f},
              {"NightColorGradeChroma", 100.f},
              {"NightSaturation", 75.f},
              {"NightVegetationTint", 50.f},
              {"NightExposureAllDay", 1.f},
              {"NightAutoExposureEnabled", 1.f},
              {"NightExposureAdaptation", 1.f},
              {"NightExposureBrighteningSpeed", 35.f},
              {"NightExposureDarkeningSpeed", 5.f},
              {"NightExposureMaximumBrightening", 100.f},
              {"NightExposureMaximumDarkening", 100.f},
              {"NightExposureFixedLuminance", 0.18f},

          });
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Dark Nights",
        .section = "Night Lighting",
        .group = "night-lighting-presets",
        .tooltip = "Applies darker night lighting and smooth brightness adaptation.",
        .is_enabled = []() { return witcher::night::Supported(); },
        .on_change = []() {
          renodx::utils::settings::UpdateSettings({
              {"NightLightingEnabled", 1.f},
              {"NightRegionalNormalization", 1.f},
              {"NightWeatherNormalization", 1.f},
              {"NightDarkeningStart", 18.f},
              {"NightFullDarknessStart", 23.f},
              {"NightFadeOutStart", 3.5f},
              {"NightDarkeningEnd", 6.f},
              {"NightSkyStrength", 5.f},
              {"NightDirectStrength", 5.f},
              {"NightFogStrength", 5.f},
              {"NightHazeStrength", 5.f},
              {"NightVisibleSkyStrength", 5.f},
              {"NightSkyHazeStrength", 5.f},
              {"NightMoonStrength", 15.f},
              {"NightCloudStrength", 1.f},
              {"NightRainStrength", 1.f},
              {"NightWaterStrength", 0.f},
              {"NightColorGradeLuminance", 100.f},
              {"NightColorGradeChroma", 100.f},
              {"NightSaturation", 75.f},
              {"NightVegetationTint", 50.f},
              {"NightExposureAllDay", 1.f},
              {"NightAutoExposureEnabled", 1.f},
              {"NightExposureAdaptation", 1.f},
              {"NightExposureBrighteningSpeed", 35.f},
              {"NightExposureDarkeningSpeed", 5.f},
              {"NightExposureMaximumBrightening", 100.f},
              {"NightExposureMaximumDarkening", 100.f},
              {"NightExposureFixedLuminance", 0.18f},

          });
        },
    },
    new renodx::utils::settings::Setting{
        .key = "NightDarkeningStart",
        .binding = &witcher::night::darkening_start,
        .default_value = 18.f,
        .label = "Begin Darkening",
        .section = "Night Schedule",
        .tooltip = "Starts fading in your night look at this time.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightFullDarknessStart",
        .binding = &witcher::night::full_darkness_start,
        .default_value = 23.f,
        .label = "Full Night Look",
        .section = "Night Schedule",
        .tooltip = "Applies your night settings at full strength from this time.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightFadeOutStart",
        .binding = &witcher::night::fade_out_start,
        .default_value = 3.5f,
        .label = "Begin Dawn Fade",
        .section = "Night Schedule",
        .tooltip = "Starts fading back to original lighting at this time.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightDarkeningEnd",
        .binding = &witcher::night::darkening_end,
        .default_value = 6.f,
        .label = "End Night Look",
        .section = "Night Schedule",
        .tooltip = "Returns fully to original daytime lighting at this time.",
        .max = 24.f,
        .format = "%.1f h",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Use 24-hour times in this order: Begin Darkening, Full Night Look, Begin Dawn Fade, End Night Look. Times can cross midnight.",
        .section = "Night Schedule",
        .is_visible = []() { return witcher::night::lighting_enabled == 1.f && witcher::night::NightSchedule() == 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightSkyStrength",
        .binding = &witcher::night::sky_strength,
        .default_value = 15.f,
        .label = "Ambient Skylight",
        .section = "Night Brightness",
        .tooltip = "Changes how much the night sky lights the world.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightDirectStrength",
        .binding = &witcher::night::direct_strength,
        .default_value = 15.f,
        .label = "Direct Moonlight",
        .section = "Night Brightness",
        .tooltip = "Changes how brightly moonlight lights the world.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightWaterStrength",
        .binding = &witcher::night::water_strength,
        .default_value = 0.f,
        .label = "Water Lighting",
        .section = "Night Brightness",
        .tooltip = "Changes the brightness of night lighting on water.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightMoonStrength",
        .binding = &witcher::night::moon_strength,
        .default_value = 35.f,
        .label = "Moon Brightness",
        .section = "Night Atmosphere",
        .tooltip = "Changes the visible brightness of the moon.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::moon_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightStarBrightness",
        .binding = &hartapfelfx::sky::star_brightness,
        .default_value = 400.f,
        .label = "Star Brightness",
        .section = "Night Atmosphere",
        .tooltip = "Brightness of stars behind the volumetric clouds. Stars fade naturally at dawn and through haze. Zero hides stars.",
        .min = 0.f,
        .max = 400.f,
        .format = "%.0f%%",
        .is_enabled = [] { return hartapfelfx::clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightFogStrength",
        .binding = &witcher::night::fog_strength,
        .default_value = 15.f,
        .label = "Fog Brightness",
        .section = "Night Atmosphere",
        .tooltip = "Changes the brightness of nearby fog at night.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightHazeStrength",
        .binding = &witcher::night::haze_strength,
        .default_value = 15.f,
        .label = "Distance Haze Brightness",
        .section = "Night Atmosphere",
        .tooltip = "Changes the brightness of haze over distant scenery.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightVisibleSkyStrength",
        .binding = &witcher::night::visible_sky_strength,
        .default_value = 15.f,
        .label = "Sky Brightness",
        .section = "Night Atmosphere",
        .tooltip = "Changes the visible brightness of the night sky.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightSkyHazeStrength",
        .binding = &witcher::night::sky_haze_strength,
        .default_value = 15.f,
        .label = "Sky Haze Brightness",
        .section = "Night Atmosphere",
        .tooltip = "Changes the brightness of haze across the night sky.",
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
        .tooltip = "Changes the visible brightness of clouds at night.",
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
        .tooltip = "Changes the brightness of falling rain at night.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::rain_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightColorGradeLuminance",
        .binding = &witcher::night::grading::luminance_strength,
        .default_value = 100.f,
        .label = "Night Brightness & Contrast",
        .section = "Night Colour",
        .tooltip = "Scales the game's night colour grade; zero removes its brightness curve.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::grading::supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightColorGradeChroma",
        .binding = &witcher::night::grading::chroma_strength,
        .default_value = 100.f,
        .label = "Night Colour Tint",
        .section = "Night Colour",
        .tooltip = "Scales the game's night colour tint; zero removes it.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::grading::supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightSaturation",
        .binding = &witcher::night::grading::saturation_strength,
        .default_value = 75.f,
        .label = "Vegetation Saturation",
        .section = "Night Colour",
        .tooltip = "Reduces green and cyan colour strength; 100 keeps the original.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightVegetationTint",
        .binding = &witcher::night::grading::vegetation_tint,
        .default_value = 50.f,
        .label = "Vegetation Tint Correction",
        .section = "Night Colour",
        .tooltip = "Warms green and cyan night tones; zero leaves them unchanged.",
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = IsNightLightingEnabled,
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureAllDay",
        .binding = &witcher::night::exposure::all_day,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Apply Exposure All Day",
        .section = "Exposure",
        .tooltip = "Uses these exposure settings all day instead of only at night.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::exposure::supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightAutoExposureEnabled",
        .binding = &witcher::night::exposure::enabled,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Automatic Exposure",
        .section = "Exposure",
        .tooltip = "Adapts image brightness automatically, or uses a fixed reference.",
        .labels = {"Fixed", "Automatic"},
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::exposure::supported; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Exposure follows the night schedule unless All Day is enabled. Native keeps the game's response; Smoothed slows it; Custom unlocks speeds and limits.",
        .section = "Exposure",
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureAdaptation",
        .binding = &witcher::night::exposure::adaptation,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Brightness Adaptation",
        .section = "Exposure",
        .tooltip = "Choose original, smooth or custom reactions to changing light.",
        .labels = {"Original", "Smooth", "Custom"},
        .max = 2.f,
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::exposure::supported; },
        .is_visible = []() { return witcher::night::exposure::enabled == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureBrighteningSpeed",
        .binding = &witcher::night::exposure::brightening_speed,
        .default_value = witcher::night::exposure::smoothed_brightening_speed,
        .label = "Brightening Speed",
        .section = "Exposure Tuning (Advanced)",
        .tooltip = "Higher values brighten the image faster after entering darkness.",
        .min = 1.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::exposure::supported; },
        .is_visible = []() { return witcher::night::exposure::enabled == 1.f && witcher::night::exposure::adaptation == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureDarkeningSpeed",
        .binding = &witcher::night::exposure::darkening_speed,
        .default_value = witcher::night::exposure::smoothed_darkening_speed,
        .label = "Darkening Speed",
        .section = "Exposure Tuning (Advanced)",
        .tooltip = "Higher values darken the image faster after entering bright light.",
        .min = 1.f,
        .max = 200.f,
        .format = "%.0f%%",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::exposure::supported; },
        .is_visible = []() { return witcher::night::exposure::enabled == 1.f && witcher::night::exposure::adaptation == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureMaximumBrightening",
        .binding = &witcher::night::exposure::maximum_brightening,
        .default_value = witcher::night::exposure::smoothed_maximum_brightening,
        .label = "Brightening Limit",
        .section = "Exposure Tuning (Advanced)",
        .tooltip = "Limits how far automatic exposure can brighten dark scenes.",
        .max = 100.f,
        .format = "%.0f%%",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::exposure::supported; },
        .is_visible = []() { return witcher::night::exposure::enabled == 1.f && witcher::night::exposure::adaptation == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureMaximumDarkening",
        .binding = &witcher::night::exposure::maximum_darkening,
        .default_value = witcher::night::exposure::smoothed_maximum_darkening,
        .label = "Darkening Limit",
        .section = "Exposure Tuning (Advanced)",
        .tooltip = "Limits how far automatic exposure can darken bright scenes.",
        .max = 100.f,
        .format = "%.0f%%",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::exposure::supported; },
        .is_visible = []() { return witcher::night::exposure::enabled == 1.f && witcher::night::exposure::adaptation == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "NightExposureFixedLuminance",
        .binding = &witcher::night::exposure::fixed_luminance,
        .default_value = 0.18f,
        .label = "Fixed Brightness Reference",
        .section = "Exposure Tuning (Advanced)",
        .tooltip = "Lower values brighten the image; higher values darken it.",
        .min = 0.001f,
        .max = 10.f,
        .format = "%.3f",
        .is_enabled = []() { return IsNightLightingEnabled() && witcher::night::exposure::supported; },
        .is_visible = []() { return witcher::night::exposure::enabled == 0.f; },
        .is_logarithmic = true,
    },
    new renodx::utils::settings::Setting{
        .key = "SunSize",
        .binding = &witcher::night::sun_size,
        .default_value = 75.f,
        .label = "Sun Size",
        .section = "Sun & Moon Appearance",
        .tooltip = "Scales the Sun and its glow from the game's own size. 100% uses the native size.",
        .min = 1.f,
        .max = 500.f,
        .format = "%.0f%%",
        .is_enabled = []() { return witcher::night::Supported() && witcher::night::sun_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "SunGlowSizeV1",
        .binding = &hartapfelfx::sky::sun_glow_size,
        .default_value = 125.f,
        .label = "Sun Glow Size",
        .section = "Sun & Moon Appearance",
        .tooltip = "Size of the glow around the Sun. Sun Size scales both the Sun and its glow; this adjusts only the glow.",
        .min = 25.f,
        .max = 400.f,
        .format = "%.0f%%",
        .is_enabled = [] { return hartapfelfx::clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "MoonSize",
        .binding = &witcher::night::moon_size,
        .default_value = 75.f,
        .label = "Moon Size",
        .section = "Sun & Moon Appearance",
        .tooltip = "Scales the Moon from the game's own size. 100% uses the native size.",
        .min = 1.f,
        .max = 500.f,
        .format = "%.0f%%",
        .is_enabled = []() { return witcher::night::Supported() && witcher::night::moon_supported; },
    },
    new renodx::utils::settings::Setting{
        .key = "EveningSunlightColourV1",
        .binding = &hartapfelfx::sky::evening_sunlight,
        .default_value = 50.f,
        .label = "Evening Sunlight Colour",
        .section = "Sun & Moon Appearance",
        .tooltip = "Blends original sunlight (0%) with the enhanced sunset colour (100%) on world surfaces. Clouds keep their sunset colours. Light brightness stays the same.",
        .min = 0.f, .max = 100.f, .format = "%.0f%%",
        .is_enabled = [] { return hartapfelfx::clouds::mode > .5f; },
        .parse = [](float value) { return value * .01f; },
    },

};

inline void OnPresetOff() {
  renodx::utils::settings::UpdateSettings({
      {"NightLightingEnabled", 0.f},
      {"MoonSize", 100.f},
      {"SunSize", 100.f},
      {"NightSaturation", 100.f},
      {"NightVegetationTint", 0.f},
  });
  witcher::night::vegetation::adjustments.store(0, std::memory_order_relaxed);
  if (witcher::night::installed) witcher::night::Update(false);
}

inline void OnPresent(reshade::api::command_queue*, reshade::api::swapchain*, const reshade::api::rect*,
               const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  witcher::night::Update(true);
  const float weight = IsNightLightingEnabled() && witcher::night::installed
          && witcher::night::NightSchedule() != 0
      ? std::clamp(witcher::night::night_weight.load(std::memory_order_relaxed), 0.f, 1.f) : 0.f;
  const float saturation = weight > 0.f && std::isfinite(witcher::night::grading::saturation_strength)
      ? (std::clamp(witcher::night::grading::saturation_strength / 100.f, 0.f, 2.f) - 1.f)
          * weight : 0.f;
  const float tint = weight > 0.f && std::isfinite(witcher::night::grading::vegetation_tint)
      ? std::clamp(witcher::night::grading::vegetation_tint / 100.f, 0.f, 1.f) * weight : 0.f;
  witcher::night::vegetation::adjustments.store(uint64_t(std::bit_cast<uint32_t>(saturation))
      | (uint64_t(std::bit_cast<uint32_t>(tint)) << 32), std::memory_order_relaxed);
  static bool reported = false;
  if (witcher::night::attempted && !reported) {
    reshade::log::message(witcher::night::installed ? reshade::log::level::info : reshade::log::level::warning,
                         witcher::night::installed ? "[RenoDX Witcher Lighting] Native lighting controls installed."
                                                   : "[RenoDX Witcher Lighting] Native lighting hooks unavailable; lighting preserved. See the native hook scan for details.");
    if (witcher::night::installed) {
      reshade::log::message(witcher::night::normalization::supported ? reshade::log::level::info : reshade::log::level::warning,
                           witcher::night::normalization::supported ? "[RenoDX Witcher Lighting] Regional night normalization available."
                                                                   : "[RenoDX Witcher Lighting] Region identification unavailable; native regional baselines preserved.");
      reshade::log::message(witcher::night::normalization::weather_supported ? reshade::log::level::info : reshade::log::level::warning,
                           witcher::night::normalization::weather_supported ? "[RenoDX Witcher Lighting] Weather night normalization available."
                                                                           : "[RenoDX Witcher Lighting] Weather identification unavailable; native weather relationships preserved.");
      reshade::log::message(witcher::night::exposure::supported ? reshade::log::level::info : reshade::log::level::warning,
                           witcher::night::exposure::supported ? "[RenoDX Witcher Lighting] Night exposure rate and metering controls available."
                                                              : "[RenoDX Witcher Lighting] Night exposure controls unavailable; native exposure preserved.");
      reshade::log::message(witcher::night::water_sky_supported ? reshade::log::level::info : reshade::log::level::warning,
                           witcher::night::water_sky_supported ? "[RenoDX Witcher Lighting] Water sky contribution follows Skylight."
                                                               : "[RenoDX Witcher Lighting] Water sky contribution control unavailable.");
    }
    if (witcher::night::installed && !witcher::night::grading::supported) {
      reshade::log::message(reshade::log::level::warning,
                           "[RenoDX Witcher Lighting] Night grading controls unavailable.");
    }
    reported = true;
  }
}


inline void MigrateProfiles(std::string_view config_namespace) {
  // Keep the original remaster keys and scale. Fill gaps from the parity
  // build, then use the profile's sky setting for an unsaved horizon gain.
  for (unsigned preset = 1; preset <= 3; ++preset) {
    const auto section = std::string(config_namespace) + "-preset" + std::to_string(preset);
    for (const auto& [source, target, scale] : {
             std::tuple{"NightSkylight", "NightSkyStrength", 0.5f},
             std::tuple{"NightMoonlightIntensity", "NightDirectStrength", 0.5f},
             std::tuple{"NightMoonBrightness", "NightMoonStrength", 0.5f},
             std::tuple{"NightMoonSize", "MoonSize", 1.f},
             std::tuple{"NightWaterAmbient", "NightWaterStrength", 0.5f},
             std::tuple{"NightFogBrightness", "NightFogStrength", 0.5f},
             std::tuple{"NightHazeBrightness", "NightHazeStrength", 0.5f},
             std::tuple{"NightSkyBrightness", "NightVisibleSkyStrength", 0.5f},
             std::tuple{"NightSkyHazeBrightness", "NightSkyHazeStrength", 0.5f},
             std::tuple{"NightVisibleSkyStrength", "NightSkyHazeStrength", 1.f},
             std::tuple{"NightCloudBrightness", "NightCloudStrength", 0.5f}}) {
      float value;
      if (!reshade::get_config_value(nullptr, section.c_str(), target, value)
          && reshade::get_config_value(nullptr, section.c_str(), source, value) && std::isfinite(value)) {
        const bool moon_size = std::string_view(target) == "MoonSize";
        reshade::set_config_value(nullptr, section.c_str(), target,
                                  std::clamp(value * scale, moon_size ? 1.f : 0.f, moon_size ? 500.f : 100.f));
      }
    }
  }
}

inline void ConfigureShader(uint32_t hash, renodx::mods::shader::CustomShader* replacement) {
  auto& shader = *replacement;
  // Every replacement uses existing native constants and layouts.
  shader.on_inject = [](auto*) { return false; };
  if (hash == 0x14AEBBFB || hash == 0x680C44CE) {
    shader.on_replace = [hash](auto* cmd_list) {
      return witcher::night::installed && witcher::night::moon_supported
             && (witcher::night::moon_multiplier.load(std::memory_order_relaxed) != 1.f
                 || (witcher::night::moon_brightness_multiplier.load(std::memory_order_relaxed) != 1.f
                     && witcher::night::night_weight.load(std::memory_order_relaxed) > 0.f))
             && renodx::utils::shader::GetCurrentPixelShaderHash(
                    renodx::utils::shader::GetCurrentState(cmd_list))
                    == (hash == 0x680C44CE ? 0x6D5A1EC2 : 0xE446F231);
    };
  } else if (hash == 0xE446F231 || hash == 0x6D5A1EC2) {
    shader.on_replace = [hash](auto* cmd_list) {
      return witcher::night::installed && witcher::night::moon_supported
             && witcher::night::moon_brightness_multiplier.load(std::memory_order_relaxed) != 1.f
             && witcher::night::night_weight.load(std::memory_order_relaxed) > 0.f
             && renodx::utils::shader::GetCurrentVertexShaderHash(
                    renodx::utils::shader::GetCurrentState(cmd_list))
                    == (hash == 0x6D5A1EC2 ? 0x680C44CE : 0x14AEBBFB);
    };
  } else if (hash == 0x3B15DAAB) {
    shader.on_replace = [](auto*) {
      return witcher::night::installed && witcher::night::sky_padding_supported
             && witcher::night::night_weight.load(std::memory_order_relaxed) > 0.f
             && witcher::night::sky_haze_multiplier.load(std::memory_order_relaxed)
                    * witcher::night::normalization::GetCalibration().sky != 1.f;
    };
  } else if (hash == 0xE1C4426E) {
    shader.on_replace = [](auto* cmd_list) {
      return witcher::night::installed && witcher::night::sun_supported
             && witcher::night::sun_multiplier.load(std::memory_order_relaxed) != 1.f
             && renodx::utils::shader::GetCurrentPixelShaderHash(
                    renodx::utils::shader::GetCurrentState(cmd_list)) == 0xE46451D5;
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
             && witcher::night::cloud_multiplier.load(std::memory_order_relaxed)
                    * witcher::night::normalization::GetCalibration().cloud != 1.f
             && witcher::night::night_weight.load(std::memory_order_relaxed) > 0.f;
    };
  }
}

}  // namespace witcher::night::ui
