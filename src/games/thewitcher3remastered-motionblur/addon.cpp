/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#define ImTextureID ImU64
// Match Darker Nights' isolation strategy, with a distinct addon namespace.
// Keep this standalone addon independent of the HDR addon's private state.
#define RENODX_PRIVATE_DATA_NAMESPACE 0x4D42524Du
#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>
#include <embed/shaders.h>
#include <cmath>
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/settings.hpp"
#include "motion_blur.hpp"
#include "motion_activation.hpp"

namespace {
renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Enhanced activates motion blur automatically.",
        .section = "Motion Blur",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Automatic activation is unavailable on this game build. Enable Motion Blur in the game's graphics settings.",
        .section = "Motion Blur",
        .is_visible = []() { return witcher::motion::mode == 1.f && witcher::motion::activation::attempted && !witcher::motion::activation::installed; },
    },
    new renodx::utils::settings::Setting{
        .key = "MotionBlurMode",
        .binding = &witcher::motion::mode,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Mode",
        .section = "Motion Blur",
        .tooltip = "Enhanced activates the motion-blur pipeline and applies custom blur. Native follows the game's own Motion Blur On/Off setting. Your saved game preference is preserved.",
        .labels = {"Native", "Enhanced"},
        .on_change_value = [](float, float current) { witcher::motion::activation::enhanced.store(current == 1.f, std::memory_order_relaxed); },
    },
    new renodx::utils::settings::Setting{
        .key = "MotionBlurCamera",
        .binding = &witcher::motion::camera_motion,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Camera Motion Blur",
        .section = "Motion Sources",
        .tooltip = "Blur from camera movement and rotation. Disable this and leave Object Motion Blur on to blur moving objects without blurring the scene during camera sway.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return witcher::motion::mode == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "MotionBlurCameraIntensity",
        .binding = &witcher::motion::shutter_angle,
        .default_value = 50.f,
        .label = "Camera Intensity",
        .section = "Motion Sources",
        .tooltip = "0 removes blur, 50 is a 180-degree shutter, and 100 is a 360-degree shutter. Per-frame motion naturally adjusts the blur to the rendered frame rate.",
        .min = 0.f,
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return witcher::motion::mode == 1.f && witcher::motion::camera_motion != 0.f; },
        .parse = [](float value) { return value * 3.6f; },
    },
    new renodx::utils::settings::Setting{
        .key = "MotionBlurObjects",
        .binding = &witcher::motion::object_motion,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Object Motion Blur",
        .section = "Motion Sources",
        .tooltip = "Blur from object movement and animation. With Camera Motion Blur off, trails follow visible screen motion and exclude camera-only movement, keeping camera-followed subjects sharp. Equal intensities with both toggles on preserve combined blur; both toggles off remove it.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return witcher::motion::mode == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "MotionBlurObjectIntensity",
        .binding = &witcher::motion::object_shutter_angle,
        .default_value = 50.f,
        .label = "Object Intensity",
        .section = "Motion Sources",
        .tooltip = "0 removes blur, 50 is a 180-degree shutter, and 100 is a 360-degree shutter. Per-frame motion naturally adjusts the blur to the rendered frame rate.",
        .min = 0.f,
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return witcher::motion::mode == 1.f && witcher::motion::object_motion != 0.f; },
        .parse = [](float value) { return value * 3.6f; },
    },
    new renodx::utils::settings::Setting{
        .key = "MotionBlurHalfResolution",
        .binding = &witcher::motion::half_resolution,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Half-Resolution Blur",
        .section = "Quality",
        .tooltip = "Reduce reconstruction cost using a half-width, half-height blur with depth/motion-aware upsampling. Static detail and incompatible edges use full-resolution reconstruction. Full resolution retains finer moving detail.",
        .labels = {"Off", "On"},
        .is_enabled = []() { return witcher::motion::mode == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "MotionBlurSamples",
        .binding = &witcher::motion::sample_count,
        .default_value = 16.f,
        // Keep numeric sample counts in the existing config; older slider
        // values select the nearest tier without changing the storage format.
        .min = 16.f,
        .max = 128.f,
        .parse = [](float value) {
          if (value < 24.f) return 16.f;
          if (value < 48.f) return 32.f;
          if (value < 96.f) return 64.f;
          return 128.f;
        },
        .is_visible = []() { return false; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "Sample Quality",
        .section = "Quality",
        .tooltip = "Maximum samples per pixel. Higher tiers reduce noise on long trails at a greater GPU cost. Increasing intensity does not increase this sample budget.",
        .is_enabled = []() { return witcher::motion::mode == 1.f; },
        .on_draw = []() {
          constexpr const char* labels[] = {"16 Samples - Low", "32 Samples - Medium", "64 Samples - High", "128 Samples - Ultra"};
          int selected = 0;
          while (selected < 3 && witcher::motion::sample_count > float(16 << selected)) ++selected;
          bool changed = false;
          if (ImGui::BeginCombo("Sample Quality", labels[selected])) {
            for (int index = 0; index < 4; ++index) {
              if (ImGui::Selectable(labels[index], index == selected)) {
                renodx::utils::settings::UpdateSetting("MotionBlurSamples", float(16 << index));
                changed = true;
              }
              if (index == selected) ImGui::SetItemDefaultFocus();
            }
            ImGui::EndCombo();
          }
          return changed;
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All Settings",
        .section = "Options",
        .tooltip = "Restore the default mode, motion sources, intensities and sample quality.",
        .on_change = []() { renodx::utils::settings::ResetSettings(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Mode: Enhanced = automatic custom blur. Native = game's On/Off setting.\n\n"
                 "Object-only: Camera Off, Object On.\n\n"
                 "Intensity: Adjust each source separately. 0 = off; 50 = 180-degree shutter.\n\n"
                 "Quality: Start at Low. Higher tiers smooth trails at a higher GPU cost.\n\n"
                 "Half-Resolution Blur: Faster, with softer moving detail. Off keeps full resolution.\n\n"
                 "Settings save automatically. Compare blur while moving.",
        .section = "How to Use",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Game mod by Hartapfel; RenoDX framework by ShortFuse.",
        .section = "About & Build",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME + " | DX12 / x64",
        .section = "About & Build",
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

void OnPresent(reshade::api::command_queue*, reshade::api::swapchain*, const reshade::api::rect*,
               const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  witcher::motion::activation::enhanced.store(witcher::motion::mode == 1.f, std::memory_order_relaxed);
  if (witcher::motion::mode != 1.f || witcher::motion::activation::attempted) return;
  const bool installed = witcher::motion::activation::Install(reinterpret_cast<const unsigned char*>(GetModuleHandleW(nullptr)));
  reshade::log::message(installed ? reshade::log::level::info : reshade::log::level::warning,
                       installed ? "Motion Blur: automatic Enhanced activation installed; native On/Off preference preserved."
                                 : "Motion Blur: automatic activation unavailable; enable Motion Blur in the game's graphics settings.");
}

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "Motion Blur - Remastered";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION =
    "Standalone motion blur for The Witcher 3 Remastered by Hartapfel";
BOOL APIENTRY DllMain(HMODULE module, DWORD reason, LPVOID) {
  if (reason == DLL_PROCESS_ATTACH) {
    if (!reshade::register_addon(module)) return FALSE;
    renodx::utils::settings::global_name = "renodx-motionblur-remastered";
    // Keep the existing preset1 storage so saved slider values survive the
    // simplified menu. Native mode replaces the old Preset Off selector.
    renodx::utils::settings::use_presets = false;
    // Seed each new control once from the former shared intensity. Never
    // overwrite an independently saved value, including an explicit zero.
    const auto section = renodx::utils::settings::global_name + "-preset1";
    float legacy_intensity;
    if (reshade::get_config_value(nullptr, section.c_str(), "MotionBlurIntensity", legacy_intensity)
        && std::isfinite(legacy_intensity)) {
      for (const char* key : {"MotionBlurCameraIntensity", "MotionBlurObjectIntensity"}) {
        float saved_intensity;
        if (!reshade::get_config_value(nullptr, section.c_str(), key, saved_intensity)) {
          reshade::set_config_value(nullptr, section.c_str(), key, std::clamp(legacy_intensity, 0.f, 100.f));
        }
      }
    }
    witcher::motion::code = {__0xF3B10000, __0xF3B10001, __0xF3B10002, __0x9F1C32F1, __0xF3B10004, __0xF3B10005, __0xF3B10006, __0xF3B10007, __0xF3B10008};
  }
  witcher::motion::Use(reason);
  renodx::utils::settings::Use(reason, &settings);
  if (reason == DLL_PROCESS_ATTACH) {
    witcher::motion::activation::enhanced.store(witcher::motion::mode == 1.f, std::memory_order_relaxed);
    reshade::register_event<reshade::addon_event::present>(OnPresent);
  } else if (reason == DLL_PROCESS_DETACH) {
    witcher::motion::activation::enhanced.store(false, std::memory_order_relaxed);
    reshade::unregister_event<reshade::addon_event::present>(OnPresent);
  }
  // Shared utilities may transfer callback ownership during teardown.
  if (reason == DLL_PROCESS_DETACH) reshade::unregister_addon(module);
  return TRUE;
}
