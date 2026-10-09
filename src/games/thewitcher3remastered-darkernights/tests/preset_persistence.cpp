/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#define WITCHER_COEXISTENCE_HOST_ONLY
#include "coexistence.cpp"
#define DllMain LightingDllMain
#include "../addon.cpp"
#undef DllMain

int main(int argc, char** argv) {
  if (argc != 2) return 1;
  if (std::strcmp(argv[1], "missing")) configuration[{"renodx-darkernights-remastered", "SelectedPreset"}] = argv[1];
  configuration[{"renodx", "SelectedPreset"}] = "3";
  for (unsigned i = 1; i <= 3; ++i) {
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightSaturation"}] = std::to_string(i * 25);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightRainStrength"}] = std::to_string(i * 10);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "CutsceneCameraLightStrength"}] = std::to_string(i * 20);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "MoonSize"}] = std::to_string(i * 30);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "SunSize"}] = std::to_string(i * 50);
    configuration[{"renodx-darkernights-remastered-preset" + std::to_string(i), "NightAutoExposureEnabled"}] = i == 2 ? "0" : "1";
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
        || witcher::night::grading::saturation_strength != 100.f) return 4;
  } else if (witcher::night::grading::saturation_strength != expected * 25.f
             || witcher::night::rain_strength != expected * 10.f
             || witcher::night::cutscene_strength != expected * 20.f
             || witcher::night::moon_size != expected * 30.f
             || witcher::night::sun_size != expected * 50.f) return 5;
  if (expected != 0 && (witcher::night::exposure::enabled != (expected == 2 ? 0.f : 1.f)
      || witcher::night::exposure::adaptation != expected - 1.f
      || witcher::night::exposure::brightening_speed != expected * 20.f
      || witcher::night::exposure::darkening_speed != expected * 30.f
      || witcher::night::exposure::maximum_darkening != expected * 15.f
      || witcher::night::exposure::maximum_brightening != expected * 25.f
      || std::abs(witcher::night::exposure::fixed_luminance - expected * 0.1f) > 1e-6f)) return 10;
  for (int selection : {0, 1, 2, 3}) {
    renodx::utils::settings::preset_index = selection;
    for (auto& callback : renodx::utils::settings::on_preset_changed_callbacks) callback();
    if (configuration[{"renodx-darkernights-remastered", "SelectedPreset"}] != std::to_string(selection)
        || configuration[{"renodx", "SelectedPreset"}] != "3") return 6;
  }
  // Regrouping must not limit Soft Nights to the top-level section or reset
  // the independent camera/moon controls. Saved keys stay unchanged.
  for (const auto* setting : settings) {
    if (setting->key.starts_with("Night")) {
      renodx::utils::settings::UpdateSetting(setting->key, setting->default_value + 1.f);
    }
  }
  renodx::utils::settings::UpdateSettings({{"GameplayCameraLightStrength", 13.f},
                                        {"CutsceneCameraLightStrength", 23.f}, {"MoonSize", 250.f}, {"SunSize", 150.f}});
  for (const auto* setting : settings) {
    if (setting->label == "Soft Nights") setting->on_change();
  }
  for (const auto* setting : settings) {
    if (setting->key.starts_with("Night") && setting->GetValue() != setting->default_value) return 8;
  }
  if (witcher::night::camera_strength != 13.f || witcher::night::cutscene_strength != 23.f
      || witcher::night::moon_size != 250.f || witcher::night::sun_size != 150.f) return 9;
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
  std::printf("PASS: startup selection '%s', saved exposure profiles/visibility, Off reset, selector/HDR isolation and regrouped Soft Nights reset\n", argv[1]);
}
