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
        .key = "ClassicMotionMode",
        .binding = &witcher::motion::motion_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Motion Blur",
        .section = "Motion Blur",
        .tooltip = "Object Only follows visible object motion and keeps camera-followed subjects sharp. Off keeps the scene sharp.",
        .labels = {"Camera + Object", "Object Only", "Off"},
        .is_enabled = []() { return witcher::motion::mode == 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ClassicMotionStrength",
        .binding = &witcher::motion::strength,
        .default_value = 50.f,
        .label = "Strength",
        .section = "Motion Blur",
        .tooltip = "Exposure duration: 0 disables blur, 50 uses 1/60 second, 100 uses 1/30 second. Frame-rate compensated using consecutive native motion-conversion intervals. New or interrupted history stays sharp.",
        .min = 0.f,
        .max = 100.f,
        .format = "%.0f",
        .is_enabled = []() { return witcher::motion::mode == 1.f && witcher::motion::motion_mode != 2.f; },
        .parse = [](float value) { return value / 50.f; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All Settings",
        .section = "Options",
        .tooltip = "Restore the mod motion blur defaults.",
        .on_change = []() { renodx::utils::settings::ResetSettings(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Enhanced uses an improved motion blur filter. Native follows the game's On/Off setting.\n\n"
                 "Object Only excludes camera-only motion. Camera-followed subjects stay sharp.\n\n"
                 "Strength: 50 = 1/60 second; 100 = 1/30 second.\n\n"
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
    // New keys intentionally avoid reinterpreting the former shutter-angle
    // sliders as Classic's fixed exposure duration.
    witcher::motion::code = {__0xF3B10000, __0x9F1C32F1, __0xF3B10004};
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
