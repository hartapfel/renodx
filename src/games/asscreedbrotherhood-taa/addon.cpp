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
#include "../../utils/device_upgrade.hpp"
#include "./native_taa.hpp"

namespace {
renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Assassin's Creed Brotherhood - Temporal Anti-Aliasing",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Start with Anti-Aliasing set to TAA and Object Motion for smoother edges and animated objects. Both are selected by default.",
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
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "For DLAA, install the optional renodx-asscreedbrotherhood-dlaa helper folder beside this addon, restart the game, turn native MSAA Off and select DLAA. Requires an NVIDIA RTX GPU. Check DLAA Status below; unsupported configurations use TAA.",
        .section = "How to Use",
    },
    new renodx::utils::settings::Setting{
        .key = "TAAEnabled",
        .binding = &acbrotherhood::taa::enabled,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Anti-Aliasing",
        .section = "TAA",
        .tooltip = "TAA supports native MSAA. DLAA uses NVIDIA's native-resolution reconstruction instead of TAA and requires an RTX GPU, the x64 helper and MSAA Off. If unavailable, TAA runs automatically; see DLAA Status. Both support standalone SDR and the Ezio Trilogy HDR addon. Off also disables debug views.",
        .labels = {"Off", "TAA", "DLAA"},
    },
    // Keep the persisted integer in the settings framework; draw it as a combo.
    new renodx::utils::settings::Setting{
        .key = "DLAAPreset",
        .binding = &acbrotherhood::dlaa::render_preset,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .labels = {"DLL Default", "F (Legacy)", "J", "K", "L", "M"},
        .parse = [](float value) {
          return value >= 0.f && value < float(acbrotherhood::dlaa::kRenderPresets.size())
                     ? float(acbrotherhood::dlaa::kRenderPresets[unsigned(value)]) : 0.f;
        },
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "DLSS Preset",
        .section = "TAA",
        .tooltip = "DLL Default leaves the runtime's preset choice unchanged. Other options request a specific preset; support depends on the installed DLL, and NVIDIA driver overrides may take precedence. Changing presets restarts DLAA and clears its history; TAA runs during startup.",
        .on_draw = [] {
          auto* setting = renodx::utils::settings::FindSetting("DLAAPreset");
          int selection = std::clamp(setting->value_as_int, 0, int(setting->labels.size()) - 1);
          if (!ImGui::Combo("DLSS Preset", &selection, [](void* data, int index) {
                return static_cast<renodx::utils::settings::Setting*>(data)->labels[index].c_str();
              }, setting, int(setting->labels.size()))) return false;
          renodx::utils::settings::UpdateSetting("DLAAPreset", float(selection));
          return true;
        },
        .is_visible = [] { return acbrotherhood::taa::enabled == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "DLAA Status",
        .section = "TAA",
        .on_draw = [] {
          const auto status = acbrotherhood::dlaa::status.load();
          const bool colored = status == acbrotherhood::dlaa::Status::active || status == acbrotherhood::dlaa::Status::failed;
          if (colored) ImGui::PushStyleColor(ImGuiCol_Text, status == acbrotherhood::dlaa::Status::active
                                                             ? ImVec4(0.35f, 0.85f, 0.4f, 1.f)
                                                             : ImVec4(1.f, 0.35f, 0.35f, 1.f));
          ImGui::TextWrapped("%s", acbrotherhood::dlaa::StatusText());
          if (status == acbrotherhood::dlaa::Status::failed)
            ImGui::Text("Stage %u, error 0x%08X", acbrotherhood::dlaa::error_stage.load(), acbrotherhood::dlaa::error_code.load());
          if (colored) ImGui::PopStyleColor();
          return false;
        },
        .is_visible = [] { return acbrotherhood::taa::enabled == 2.f; },
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
        .tooltip = "Sharpens the resolved TAA or DLAA image before color grading and the HUD. 0 disables sharpening; 100 is full strength. Uses luminance-based sharpening with noise suppression. Debug views remain unsharpened.",
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
        .tooltip = "Depth: native scene depth. Motion Vectors: motion used by the active AA method; gray = still, red/green = horizontal/vertical motion, magenta = invalid. DLAA shows its raw undilated vectors; TAA shows its history-sampling motion. Depth and History views temporarily use TAA. History Confidence: red = reset, yellow = low, cyan = medium, green = high. History Rejection: blue = depth mismatch, magenta = color clipping, red = other reset, green = accepted. Colors pass through the game's color grade.",
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
        .label = "TAA/DLAA mod by Hartapfel. RenoDX framework by ShortFuse. Optional DLAA by NVIDIA.",
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
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "TAA and optional NVIDIA DLAA with camera/object motion and Lilium RCAS; standalone SDR and RenoDX HDR";

BOOL APIENTRY DllMain(HMODULE module, DWORD reason, LPVOID) {
  if (reason == DLL_PROCESS_ATTACH) {
    if (!reshade::register_addon(module)) return FALSE;
    acbrotherhood::dlaa::addon_module = module;
    // DX9Ex enables GPU sharing; it does not enable HDR or change formats.
    // The HDR addon already requests this through the same shared utility.
    // Standalone TAA keeps ordinary DX9 unless the optional helper is installed.
    std::wstring path(32768, L'\0');
    if (GetModuleFileNameW(module, path.data(), DWORD(path.size()))) {
      renodx::utils::device_upgrade::use_dx9ex_upgrade = GetFileAttributesW(
          (std::filesystem::path(path.c_str()).parent_path() / L"renodx-asscreedbrotherhood-dlaa" / L"renodx-asscreedbrotherhood-dlaa.exe").c_str()) != INVALID_FILE_ATTRIBUTES;
    }
    renodx::utils::settings::global_name = "asscreedbrotherhood-taa";
    renodx::utils::settings::use_presets = false;
  }
  renodx::utils::settings::Use(reason, &settings);
  renodx::utils::device_upgrade::Use(reason);
  acbrotherhood::taa::Use(reason);
  if (reason == DLL_PROCESS_DETACH) reshade::unregister_addon(module);
  return TRUE;
}
