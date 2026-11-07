/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#define WITCHER_COEXISTENCE_HOST_ONLY
#include "../night/tests/coexistence.cpp"

#define DllMain HartapfelDllMain
#include "../addon.cpp"
#undef DllMain

int main() {
  using namespace renodx::utils::settings;
  constexpr auto target = "thewitcher3remastered-hartapfelfx-preset2";
  constexpr auto legacy_night = "renodx-darkernights-remastered-preset2";
  constexpr auto legacy_fill = "renodx-witcher3remastered-graphics-preset2";
  configuration[{"thewitcher3remastered-hartapfelfx", "SelectedPreset"}] = "2";
  configuration[{target, "NightFogStrength"}] = "14";
  configuration[{legacy_night, "NightFogStrength"}] = "5";
  configuration[{legacy_night, "NightVisibleSkyStrength"}] = "25";
  configuration[{legacy_fill, "GameplayLightStrength"}] = "0.35";
  configuration[{legacy_fill, "CutsceneLightStrength"}] = "0.43";
  const auto module = GetModuleHandleW(nullptr);
  if (!HartapfelDllMain(module, DLL_PROCESS_ATTACH, nullptr)) return 1;
  if (preset_index != 2 || nights::fog_strength != 14.f || nights::sky_haze_strength != 25.f
      || gameplay_strength != .35f || cutscene_strength != .43f) return 2;

  const auto* player = FindSetting("PlayerLighting");
  const auto* cloud = FindSetting("CloudModeV2");
  const auto* sky_haze = FindSetting("NightSkyHazeStrength");
  if (!player || !cloud || !sky_haze || (*renodx::utils::settings::settings)[0] != player
      || player->section != "Player Fill Lights") return 3;
  draw_nights = false;
  if (!player->is_visible() || !cloud->is_visible() || sky_haze->is_visible()) return 4;
  draw_nights = true;
  if (player->is_visible() || cloud->is_visible() || !sky_haze->is_visible()) return 5;
  UpdateSetting("CloudModeV2", 0.f);
  nights::ui::ResetSettings();
  if (clouds::mode != 0.f || gameplay_strength != .35f || nights::sky_haze_strength != 15.f) return 6;

  // Exercise the actual composed hook against fresh common constants. The
  // environment matching scalar and the night fog color must coexist.
  fill_native::layout.common = nights::detected_layout.common = 1;
  nights::night_schedule.store(nights::NightSchedule());
  nights::fog_multiplier.store(.5f);
  nights::build_common_constants = [](const void*, void* output) {
    auto* frame = static_cast<float*>(output);
    frame[71 * 4] = .25f;
    frame[39 * 4] = .8f;
    frame[39 * 4 + 3] = .6f;
  };
  std::array<unsigned char, 0x15c4> environment{};
  const void* input[2] = {nullptr, environment.data()};
  std::array<float, 341 * 4> frame{};
  player_fill::Publish(true, true, .2f, .2f);
  nights::CommonConstantsHook(input, frame.data());
  if (frame[71 * 4] != 1.f || frame[39 * 4] != .4f || frame[39 * 4 + 3] != .6f) return 7;
  float sky_impact = 1.f;
  nights::sky_impact.Initialize(&sky_impact);
  nights::installed = nights::attempted = true;
  OnPresetOff();
  if (player_fill::GetControls().enabled || nights::lighting_enabled != 0.f
      || injection.enabled != 0.f || clouds::mode != 0.f) return 8;
  nights::CommonConstantsHook(input, frame.data());
  if (frame[71 * 4] != .25f || frame[39 * 4] != .8f) return 9;
  if (!HartapfelDllMain(module, DLL_PROCESS_DETACH, nullptr) || invalid_registrations || !callbacks.empty()) return 10;
  std::puts("PASS: tab routing, standalone profiles, isolated night reset, shared constants and preset Off");
}
