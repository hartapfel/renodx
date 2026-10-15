/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#define WITCHER_COEXISTENCE_HOST_ONLY
#include <limits>
#include "coexistence.cpp"
#define DllMain LightingDllMain
#include "../addon.cpp"
#undef DllMain

int main(int argc, char** argv) {
  if (argc != 2) return 1;
  if (std::strcmp(argv[1], "missing")) configuration[{"renodx-darkernights-remastered", "SelectedPreset"}] = argv[1];
  configuration[{"renodx", "SelectedPreset"}] = "3";
  for (unsigned i = 1; i <= 3; ++i) {
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightWeatherNormalization"}] = i == 3 ? "0" : "1";
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightRegionalNormalization"}] = i == 2 ? "0" : "1";
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightSaturation"}] = std::to_string(i * 25);
    if (std::strcmp(argv[1], "legacy")) configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightVegetationTint"}] = std::to_string(i * 20);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightRainStrength"}] = std::to_string(i * 10);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "CutsceneCameraLightStrength"}] = std::to_string(i * 20);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightMoonStrength"}] = std::to_string(i * 15);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "MoonSize"}] = std::to_string(i * 30);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "SunSize"}] = std::to_string(i * 50);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "FogAmount"}] = std::to_string(i * 25);
    if (std::strcmp(argv[1], "defaults")) configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "FogStartDistance"}] = std::to_string(i * 20);
    if (std::strcmp(argv[1], "defaults") && std::strcmp(argv[1], "legacy")) configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "IndoorFogStartDistance"}] = std::to_string(i * 30);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightAutoExposureEnabled"}] = i == 2 ? "0" : "1";
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightExposureAllDay"}] = i == 2 ? "1" : "0";
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightExposureAdaptation"}] = std::to_string(i - 1);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightExposureBrighteningSpeed"}] = std::to_string(i * 20);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightExposureDarkeningSpeed"}] = std::to_string(i * 30);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightExposureFixedLuminance"}] = std::to_string(i * 0.1f);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightExposureMaximumDarkening"}] = std::to_string(i * 15);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightExposureMaximumBrightening"}] = std::to_string(i * 25);
  }
  if (!LightingDllMain(GetModuleHandleW(nullptr), DLL_PROCESS_ATTACH, nullptr)) return 2;
  int expected = 1;
  if (!std::strcmp(argv[1], "0")) expected = 0;
  else if (!std::strcmp(argv[1], "2")) expected = 2;
  else if (!std::strcmp(argv[1], "3")) expected = 3;
  if (renodx::utils::settings::preset_index != expected) return 3;
  if (expected == 0) {
    if (witcher::night::lighting_enabled != 0.f || witcher::night::camera_strength != 50.f
        || witcher::night::cutscene_strength != 50.f
        || witcher::night::moon_size != 100.f
        || witcher::night::sun_size != 100.f
        || witcher::night::fog_amount != 100.f
        || witcher::night::fog_start_distance != 0.f || witcher::night::indoor_fog_start_distance != 0.f
        || witcher::night::grading::saturation_strength != 100.f || witcher::night::grading::vegetation_tint != 0.f) return 4;
  } else if (witcher::night::grading::saturation_strength != expected * 25.f
             || witcher::night::grading::vegetation_tint != (!std::strcmp(argv[1], "legacy") ? 100.f : expected * 20.f)
             || witcher::night::rain_strength != expected * 10.f
             || witcher::night::moon_strength != expected * 15.f
             || witcher::night::cutscene_strength != expected * 20.f
             || witcher::night::moon_size != expected * 30.f
             || witcher::night::sun_size != expected * 50.f
             || witcher::night::fog_amount != expected * 25.f
             || witcher::night::fog_start_distance != (!std::strcmp(argv[1], "defaults") ? 10.f : expected * 20.f)
             || witcher::night::indoor_fog_start_distance != (!std::strcmp(argv[1], "defaults") || !std::strcmp(argv[1], "legacy") ? 40.f : expected * 30.f)) return 5;
  if (expected != 0 && (witcher::night::exposure::enabled != (expected == 2 ? 0.f : 1.f)
      || witcher::night::exposure::all_day != (expected == 2 ? 1.f : 0.f)
      || witcher::night::exposure::adaptation != expected - 1.f
      || witcher::night::exposure::brightening_speed != expected * 20.f
      || witcher::night::exposure::darkening_speed != expected * 30.f
      || witcher::night::exposure::maximum_darkening != expected * 15.f
      || witcher::night::exposure::maximum_brightening != expected * 25.f
      || std::abs(witcher::night::exposure::fixed_luminance - expected * 0.1f) > 1e-6f)) return 10;
  if (expected != 0 && witcher::night::normalization::enabled != (expected == 2 ? 0.f : 1.f)) return 14;
  if (expected != 0 && witcher::night::normalization::weather_enabled != (expected == 3 ? 0.f : 1.f)) return 15;
  for (int selection : {0, 1, 2, 3}) {
    renodx::utils::settings::preset_index = selection;
    for (auto& callback : renodx::utils::settings::on_preset_changed_callbacks) callback();
    if (configuration[{"renodx-darkernights-remastered", "SelectedPreset"}] != std::to_string(selection)
        || configuration[{"renodx", "SelectedPreset"}] != "3") return 6;
  }
  // Both recipes must cover every night section, independently of mutable UI
  // defaults and the previously selected recipe. Soft matches startup defaults.
  std::map<std::string, float> soft_expected;
  for (auto* setting : settings) {
    if (setting->key.starts_with("Night") || setting->key == "MoonSize") {
      if (!soft_expected.emplace(setting->key, setting->default_value).second) return 22;
      setting->default_value = setting->default_value == setting->min ? setting->GetMax() : setting->min;
    }
  }
  if (soft_expected.at("NightSaturation") != 75.f || soft_expected.at("NightVegetationTint") != 100.f) return 23;
  auto dark_expected = soft_expected;
  for (const auto& [key, value] : std::map<std::string, float>{
           {"NightSkyStrength", 5.f}, {"NightDirectStrength", 5.f},
           {"NightFogStrength", 1.f}, {"NightHazeStrength", 5.f},
           {"NightVisibleSkyStrength", 5.f}, {"NightMoonStrength", 15.f},
           {"NightCloudStrength", 1.f}, {"NightRainStrength", 1.f}, {"MoonSize", 30.f}, {"NightSaturation", 50.f}}) {
    dark_expected.at(key) = value;
  }
  renodx::utils::settings::UpdateSettings({{"GameplayCameraLightStrength", 13.f},
                                        {"CutsceneCameraLightStrength", 23.f}, {"MoonSize", 250.f}, {"SunSize", 150.f},
                                        {"FogAmount", 35.f}, {"FogStartDistance", 45.f}, {"IndoorFogStartDistance", 65.f}});
  for (const std::string label : {"Dark Nights", "Soft Nights", "Dark Nights", "Soft Nights"}) {
    const auto& recipe = label == "Soft Nights" ? soft_expected : dark_expected;
    for (const auto* setting : settings) {
      if (recipe.contains(setting->key)) {
        renodx::utils::settings::UpdateSetting(setting->key, recipe.at(setting->key) == setting->min ? setting->GetMax() : setting->min);
      }
    }
    unsigned buttons = 0;
    for (const auto* setting : settings) {
      if (setting->label == label) { setting->on_change(); ++buttons; }
    }
    if (buttons != 1) return 24;
    for (const auto* setting : settings) {
      if (recipe.contains(setting->key) && setting->GetValue() != recipe.at(setting->key)) {
        std::printf("FAIL: %s: %s = %g, expected %g\n", label.c_str(), setting->key.c_str(), setting->GetValue(), recipe.at(setting->key));
        return 8;
      }
    }
    if (witcher::night::camera_strength != 13.f || witcher::night::cutscene_strength != 23.f
        || witcher::night::sun_size != 150.f || witcher::night::fog_amount != 35.f
        || witcher::night::fog_start_distance != 45.f || witcher::night::indoor_fog_start_distance != 65.f) return 9;
    if (renodx::utils::settings::preset_index != 3) return 25;
    const auto before_save = configuration;
    renodx::utils::settings::SaveSettings();
    for (const auto& [key, value] : before_save) {
      if (key.first != "renodx-darkernights-remastered-preset3" && configuration.at(key) != value) return 26;
    }
    for (const auto* setting : settings) {
      if (recipe.contains(setting->key)) renodx::utils::settings::UpdateSetting(setting->key, setting->default_value);
    }
    renodx::utils::settings::LoadSettings(renodx::utils::settings::GetCurrentPresetName());
    for (const auto* setting : settings) {
      if (recipe.contains(setting->key) && std::abs(setting->GetValue() - recipe.at(setting->key)) > 1e-6f) return 27;
    }
  }
  for (auto* setting : settings) {
    if (soft_expected.contains(setting->key)) setting->default_value = soft_expected.at(setting->key);
  }
  OnPresetOff();
  if (witcher::night::fog_amount != 100.f || witcher::night::fog_start_distance != 0.f || witcher::night::indoor_fog_start_distance != 0.f) return 16;
  // Publish both colour controls coherently through the actual Present path.
  // Native builders are not executed in this host; supply their night weight.
  witcher::night::checked = witcher::night::supported = witcher::night::installed = true;
  witcher::night::normalization::enabled = witcher::night::normalization::weather_enabled = 0.f;
  float native_impact = 1.f;
  witcher::night::sky_impact.Initialize(&native_impact);
  witcher::night::lighting_enabled = 1.f;
  for (float weight : {0.f, .25f, 1.f}) for (float saturation : {0.f, 50.f, 100.f})
      for (float tint : {0.f, 50.f, 100.f, 300.f, std::numeric_limits<float>::quiet_NaN()}) {
    witcher::night::night_weight.store(weight);
    witcher::night::grading::saturation_strength = saturation;
    witcher::night::grading::vegetation_tint = tint;
    OnPresent(nullptr, nullptr, nullptr, nullptr, 0, nullptr);
    const uint64_t amounts = witcher::night::vegetation::adjustments.load();
    const float delta = std::bit_cast<float>(uint32_t(amounts));
    const float correction = std::bit_cast<float>(uint32_t(amounts >> 32));
    if (delta != (saturation / 100.f - 1.f) * weight
        || correction != (std::isfinite(tint) ? std::clamp(tint / 100.f, 0.f, 1.f) * weight : 0.f)) return 17;
    if (weight == 0.f && amounts != 0) return 18;
  }
  witcher::night::grading::vegetation_tint = 100.f;
  witcher::night::lighting_enabled = 0.f;
  OnPresent(nullptr, nullptr, nullptr, nullptr, 0, nullptr);
  if (witcher::night::vegetation::adjustments.load() != 0) return 19;
  witcher::night::lighting_enabled = 1.f;
  witcher::night::darkening_end = witcher::night::darkening_start;
  OnPresent(nullptr, nullptr, nullptr, nullptr, 0, nullptr);
  if (witcher::night::vegetation::adjustments.load() != 0) return 20;
  OnPresetOff();
  if (witcher::night::grading::vegetation_tint != 0.f || witcher::night::vegetation::adjustments.load() != 0) return 21;
  witcher::night::installed = false;
  // Off exposes only the fixed reference. Enabled exposes Adaptation, and
  // its two speed sliders appear exclusively for Custom.
  for (float enabled : {0.f, 1.f}) for (float mode : {0.f, 1.f, 2.f}) {
    witcher::night::exposure::enabled = enabled;
    witcher::night::exposure::adaptation = mode;
    for (const auto* setting : settings) {
      if (setting->key == "NightExposureAdaptation" && setting->is_visible() != (enabled == 1.f)) return 11;
      if ((setting->key == "NightExposureBrighteningSpeed" || setting->key == "NightExposureDarkeningSpeed"
           || setting->key == "NightExposureMaximumDarkening" || setting->key == "NightExposureMaximumBrightening")
          && setting->is_visible() != (enabled == 1.f && mode == 2.f)) return 12;
      if (setting->key == "NightExposureFixedLuminance" && setting->is_visible() != (enabled == 0.f)) return 13;
    }
  }
  LightingDllMain(GetModuleHandleW(nullptr), DLL_PROCESS_DETACH, nullptr);
  if (!callbacks.empty() || !addons.empty() || invalid_registrations) return 7;
  std::printf("PASS: startup '%s', saved profiles/visibility, Off, HDR isolation, explicit Soft/Dark recipes independent of UI defaults\n", argv[1]);
}
