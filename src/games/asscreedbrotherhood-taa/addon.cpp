/*
 * Copyright (C) 2024 Carlos Lopez
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Native DX9 temporal anti-aliasing, independent of the Ezio Trilogy HDR addon.
#define ImTextureID ImU64
#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/settings.hpp"
#include "./native_taa.hpp"

namespace {
renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Assassin's Creed Brotherhood - Temporal Anti-Aliasing",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Start with TAA On and Object Motion for smoother edges and animated objects. Both are enabled by default.",
        .section = "How to Use",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Choose Camera Motion for lower CPU cost; moving characters and clothing may leave more trails. Keep Debug View Off for normal gameplay.",
        .section = "How to Use",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Native MSAA is optional and can be combined with TAA for additional edge coverage. Higher MSAA levels use more GPU time and memory.",
        .section = "How to Use",
    },
    new renodx::utils::settings::Setting{
        .key = "TAAEnabled",
        .binding = &acbrotherhood::taa::enabled,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "TAA",
        .section = "TAA",
        .tooltip = "Smooth edges using jittered samples and information from previous frames. With in-game MSAA, use a smaller synchronized jitter pattern and motion-responsive history after the native resolve. Works with native SDR or the separate Ezio Trilogy HDR addon. Off also disables debug views.",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .key = "TAAMotionSource",
        .binding = &acbrotherhood::taa::object_motion_enabled,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Motion Vectors",
        .section = "TAA",
        .tooltip = "Object Motion combines camera reprojection for verified static scenery with object vectors for supported characters, clothing, wind animation and other moving surfaces. Camera Motion uses camera movement only: faster, but moving objects can leave trails.",
        .labels = {"Camera Motion", "Object Motion"},
        .is_enabled = [] { return acbrotherhood::taa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "RCASSharpening",
        .binding = &acbrotherhood::taa::rcas_strength,
        .default_value = 0.f,
        .label = "Lilium RCAS",
        .section = "Sharpening",
        .tooltip = "Sharpens the resolved TAA image before color grading and the HUD. 0 disables sharpening; 100 is full strength. Uses luminance-based sharpening with noise suppression. Debug views remain unsharpened.",
        .max = 100.f,
        .is_enabled = [] { return acbrotherhood::taa::enabled != 0.f && acbrotherhood::taa::debug_view == 0.f; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "TAADebugViewV2",
        .binding = &acbrotherhood::taa::debug_view,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Debug View",
        .section = "Debug",
        .tooltip = "Depth: native scene depth. Motion Vectors: the combined history-sampling motion selected by TAA; gray = still, red/green = horizontal/vertical motion, magenta = no valid reprojection. The view follows your selected motion source and keeps TAA running. History Confidence: red = reset, yellow = low, cyan = medium, green = high. History Rejection: blue = depth mismatch, magenta = color clipping, red = other reset, green = accepted. Colors pass through the game's color grade.",
        .labels = {"Off", "Depth", "Motion Vectors", "History Confidence", "History Rejection"},
        .is_enabled = [] { return acbrotherhood::taa::enabled != 0.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "TAADumpResolve",
        .binding = &acbrotherhood::taa::dump_resolve,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Capture Resolve Frame",
        .section = "Debug",
        .tooltip = "Experimental TAA only. Capture one frame for offline analysis in renodx-dev/taa-capture, then return to Idle. Temporarily stalls rendering; about 316 MiB on disk at 4K. Captures raw inputs, output and constants without altering TAA.",
        .labels = {"Idle", "Capture Once"},
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .key = "TAAInputCapture",
        .binding = &acbrotherhood::taa::capture_enabled,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "TAA Input Capture",
        .section = "Debug",
        .tooltip = "Log camera/depth validation, motion matching, shader-cache misses and CPU/GPU timing. Timing queries never wait for the GPU. Does not enable TAA.",
        .labels = {"Off", "On"},
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Supports Brotherhood's native DirectX 9 renderer with 32-bit ReShade and addon support. Use alone for SDR, or alongside the current Ezio Trilogy HDR addon for HDR.",
        .section = "Important Information",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Install only one Brotherhood TAA addon. Replace older acbrotherhood-taa files and Ezio builds with embedded TAA. Close the game before updating addon files.",
        .section = "Important Information",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Some water, transparency and animated surfaces can still show temporal artifacts. When reporting an issue, include the build below, MSAA level, motion setting and a screenshot of the affected scene.",
        .section = "Important Information",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "RenoDX Discord",
        .section = "Links",
        .group = "discord-links",
        .tint = 0x5865F2,
        .on_change = [] { renodx::utils::platform::LaunchURL("https://discord.gg/", "Ce9bQHQrSV"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "HDR Den Discord",
        .section = "Links",
        .group = "discord-links",
        .tint = 0x5865F2,
        .on_change = [] { renodx::utils::platform::LaunchURL("https://discord.gg/", "5WZXDpmbpP"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "GitHub",
        .section = "Links",
        .tint = 0x2B3137,
        .on_change = [] { renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Hartapfel's Ko-Fi",
        .section = "Links",
        .group = "support-links",
        .tint = 0xFF5A16,
        .on_change = [] { renodx::utils::platform::LaunchURL("https://ko-fi.com/hartapfel"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "ShortFuse's Ko-Fi",
        .section = "Links",
        .group = "support-links",
        .tint = 0xFF5A16,
        .on_change = [] { renodx::utils::platform::LaunchURL("https://ko-fi.com/shortfuse"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "TAA mod by Hartapfel. RenoDX framework by ShortFuse. RCAS by AMD, with Lilium's luminance adaptation.",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Experimental | Native DirectX 9 | 32-bit",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
        .section = "About",
    },
};
}

extern "C" __declspec(dllexport) constexpr const char* NAME = "Assassin's Creed Brotherhood TAA";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "Temporal anti-aliasing with camera and object motion; supports native MSAA, standalone SDR and RenoDX HDR";

BOOL APIENTRY DllMain(HMODULE module, DWORD reason, LPVOID) {
  if (reason == DLL_PROCESS_ATTACH) {
    if (!reshade::register_addon(module)) return FALSE;
    renodx::utils::settings::global_name = "asscreedbrotherhood-taa";
    renodx::utils::settings::use_presets = false;
  }
  renodx::utils::settings::Use(reason, &settings);
  acbrotherhood::taa::Use(reason);
  if (reason == DLL_PROCESS_DETACH) reshade::unregister_addon(module);
  return TRUE;
}
