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
#include "./native_device.hpp"
#include "./presentation.hpp"
#include "./standalone_present.hpp"

namespace {
// All choices use the same persisted settings path and native combo behavior.
bool DrawChoice(const char* key, const char* label, int forced = -1, unsigned maximum = UINT32_MAX) {
  auto* setting = renodx::utils::settings::FindSetting(key);
  const int selected = forced >= 0 ? forced : std::clamp(setting->value_as_int, 0, int(setting->labels.size()) - 1);
  bool changed = false;
  ImGui::BeginDisabled(forced >= 0);
  if (ImGui::BeginCombo(label, setting->labels[selected].c_str())) {
    for (int index = 0; index < int(setting->labels.size()); ++index) {
      ImGui::BeginDisabled(unsigned(index) > maximum);
      if (ImGui::Selectable(setting->labels[index].c_str(), index == selected)) {
        renodx::utils::settings::UpdateSetting(key, float(index));
        changed = true;
      }
      if (index == selected) ImGui::SetItemDefaultFocus();
      ImGui::EndDisabled();
    }
    ImGui::EndCombo();
  }
  ImGui::EndDisabled();
  return changed;
}
renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "TAAEnabled",
        .binding = &acbrotherhood::taa::enabled,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .labels = {"Off", "TAA", "DLAA"},
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "Anti-Aliasing",
        .section = "Anti-Aliasing",
        .tooltip = "TAA supports native MSAA. DLAA requires an NVIDIA RTX GPU, the DLAA helper and MSAA Off; TAA is the fallback. Object motion is automatic for both methods. Off disables temporal AA and frame-generation inputs.",
        .on_draw = [] { return DrawChoice("TAAEnabled", "Anti-Aliasing"); },
    },
    new renodx::utils::settings::Setting{
        .key = "DLAAPreset",
        .binding = &acbrotherhood::dlaa::render_preset,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .labels = {"Default", "F (Legacy)", "J", "K", "L", "M"},
        .parse = [](float value) {
          return value >= 0.f && value < float(acbrotherhood::dlaa::kRenderPresets.size())
                     ? float(acbrotherhood::dlaa::kRenderPresets[unsigned(value)]) : 0.f;
        },
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "DLSS Preset",
        .section = "Anti-Aliasing",
        .tooltip = "Default lets NVIDIA's runtime choose. Other presets depend on the installed DLL and driver overrides. Changing presets restarts DLAA and clears its history.",
        .on_draw = [] { return DrawChoice("DLAAPreset", "DLSS Preset"); },
        .is_visible = [] { return acbrotherhood::taa::enabled == 2.f; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "DLAA Status",
        .section = "Anti-Aliasing",
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
        .key = "DLSSFrameGeneration",
        .binding = &acbrotherhood::frame_generation::generation_enabled,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .labels = {"Off", "2x", "3x", "4x", "5x", "6x"},
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "DLSS Frame Generation",
        .section = "Frame Generation",
        .tooltip = "The multiplier includes the rendered frame: 3x adds two generated frames.",
        .on_draw = [] {
          const auto maximum = acbrotherhood::frame_generation::generation_max.load();
          return DrawChoice("DLSSFrameGeneration", "Frame Generation", -1, maximum ? maximum : UINT32_MAX);
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "Frame Generation Status",
        .section = "Frame Generation",
        .on_draw = [] {
          using namespace acbrotherhood::frame_generation;
          const auto state = generation_status.load();
          if (!RequestedFrames()) ImGui::TextDisabled("Off - rendered frames only.");
          else if (state == Status::active)
            ImGui::TextColored(ImVec4(0.35f, 0.85f, 0.4f, 1.f), "Active | %ux confirmed", presented_count.load());
          else if (state == Status::multiplier_unsupported)
            ImGui::TextColored(ImVec4(1.f, 0.35f, 0.35f, 1.f), "Requested %ux is unavailable; maximum %ux.", RequestedFrames() + 1, generation_max.load() + 1);
          else if (state == Status::failed || state == Status::unsupported)
            ImGui::TextColored(ImVec4(1.f, 0.35f, 0.35f, 1.f), "Unavailable (0x%08X) | rendering original frames", generation_error.load());
          else {
            const char* message = "Waiting for valid gameplay frames.";
            if (state == Status::effects) message = "Paused: turn ReShade shader effects Off. The overlay can stay open.";
            else if (state == Status::inputs) message = "Waiting for scene, depth and motion inputs. Keep TAA/DLAA On and Debug View Off.";
            else if (state == Status::camera) message = "Waiting for a valid camera.";
            else if (state == Status::inactive) message = "Paused while the game is in the background.";
            else if (state == Status::resizing) message = "Resuming after a graphics change.";
            else if (state == Status::vsync) message = "Paused: the current runtime/sync interval cannot preserve VSync.";
            ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(1.f, 0.8f, 0.3f, 1.f));
            ImGui::TextWrapped("%s", message); ImGui::PopStyleColor();
          }
          return false;
        },
    },
    new renodx::utils::settings::Setting{
        .key = "ReflexMode",
        .binding = &acbrotherhood::presentation::reflex_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .labels = {"Off", "On", "On + Boost"},
        .is_visible = [] { return false; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "NVIDIA Reflex",
        .section = "Reflex and Frame Pacing",
        .tooltip = "On reduces render latency; On + Boost also keeps GPU clocks elevated.",
        .on_draw = [] {
          const bool locked = acbrotherhood::frame_generation::RequestedFrames() != 0;
          const bool changed = DrawChoice("ReflexMode", "NVIDIA Reflex", locked ? 1 : -1);
          if (locked) ImGui::TextDisabled("Required by Frame Generation.");
          return changed;
        },
    },
    new renodx::utils::settings::Setting{
        .key = "ReflexRenderFPS",
        .binding = &acbrotherhood::presentation::render_fps,
        .default_value = 0.f,
        .label = "Reflex Framerate cap (Before FG)",
        .section = "Reflex and Frame Pacing",
        .tooltip = "Ctrl-click to enter an exact value. 0 removes the manual cap. Reflex keeps output below the display refresh rate automatically. Recommended is a framerate cap of 60 to avoid in-engine bugs.",
        .max = 500.f,
        .format = "%.0f FPS",
        .parse = [](float value) { return std::round(value); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "Performance",
        .section = "Reflex and Frame Pacing",
        .on_draw = [] {
          using namespace acbrotherhood::presentation;
          FrameMetrics snapshot;
          PacingState pacing;
          {
            const std::lock_guard lock(mutex);
            snapshot = frame_metrics; pacing = pacing_state;
          }
          const auto metrics = snapshot.Summarize();
          if (snapshot.Fresh(FrameTimeSeconds())) {
            if (ImGui::BeginTable("FrameRates", 2, ImGuiTableFlags_SizingStretchSame | ImGuiTableFlags_NoSavedSettings)) {
              ImGui::TableNextColumn(); ImGui::TextDisabled("Before FG");
              ImGui::TextColored(ImVec4(0.45f, 0.8f, 1.f, 1.f), "%.1f FPS", metrics.rendered_fps);
              ImGui::TableNextColumn(); ImGui::TextDisabled("After FG");
              ImGui::TextColored(ImVec4(0.45f, 0.9f, 0.65f, 1.f), "%.1f FPS", metrics.output_fps);
              ImGui::EndTable();
            }
            ImGui::TextDisabled("Rendered frametime (ms) | last %u frames", snapshot.count);
            ImGui::PushStyleColor(ImGuiCol_PlotLines, ImVec4(0.45f, 0.8f, 1.f, 1.f));
            ImGui::PlotLines("##RenderedFrametime", &snapshot.history[0].milliseconds, int(snapshot.count),
                snapshot.count == FrameMetrics::capacity ? int(snapshot.next) : 0, nullptr, 0.f,
                std::max(20.f, metrics.maximum_ms * 1.15f), ImVec2(-1.f, 95.f), sizeof(FrameMetrics::Sample));
            ImGui::PopStyleColor();
            if (ImGui::IsItemHovered()) ImGui::SetTooltip("Real rendered-frame intervals, not interpolated display timing.\nFPS averages the last second. After FG counts frames confirmed by the runtime, not the selected multiplier or monitor scanout.");
            ImGui::Text("Average %.2f ms  |  P95 %.2f ms", metrics.average_ms, metrics.p95_ms);
          } else ImGui::TextDisabled("Waiting for frame timing...");
          if (status.load() == Status::active) {
            if (!pacing.available)
              ImGui::TextColored(ImVec4(1.f, 0.35f, 0.35f, 1.f), "Reflex limiter unavailable (0x%08X).", pacing.error);
            else if (pacing.interval_us) ImGui::TextDisabled("Reflex cap: %.1f rendered FPS", 1000000.0 / pacing.interval_us);
            else ImGui::TextDisabled("No manual Reflex cap.");
            if (pacing.available && pacing.driver_interval_us > ReflexInterval(pacing.interval_us, pacing.driver_multiplier))
              ImGui::TextDisabled("Automatic VRR ceiling: %.1f displayed FPS", 1000000.0 / pacing.driver_interval_us);
          }
          return false;
        },
    },
    new renodx::utils::settings::Setting{
        .key = "RCASSharpening",
        .binding = &acbrotherhood::taa::rcas_strength,
        .default_value = 0.f,
        .label = "Lilium RCAS",
        .section = "Sharpening",
        .tooltip = "Uses luminance-based sharpening with noise suppression.",
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
        .value_type = renodx::utils::settings::SettingValueType::CUSTOM,
        .label = "Output Status",
        .section = "Setup and Information",
        .on_draw = [] {
          using namespace acbrotherhood::presentation;
          if (status.load() == Status::active) ImGui::TextColored(ImVec4(0.35f, 0.85f, 0.4f, 1.f), "DX12 output active | VSync follows game / driver");
          else if (status.load() == Status::failed) {
            ImGui::TextColored(ImVec4(1.f, 0.35f, 0.35f, 1.f), "Native output fallback | DX12 error %u: 0x%08X", error_stage.load(), error_code.load());
            if (error_code == ERROR_REVISION_MISMATCH) ImGui::TextWrapped("Update the addon and DX12 helper together.");
            if (ImGui::Button("Retry DX12 Output")) retry_requested = true;
          } else ImGui::TextWrapped("DX12 starts automatically with the installed DX12 helper, in standalone SDR or with the Ezio Trilogy HDR addon. Without the helper, AA uses native output.");
          return false;
        },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "TAA supports native MSAA. DLAA requires an RTX GPU, the DLAA helper and MSAA Off.",
        .section = "Setup and Information",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Frame Generation works with TAA or DLAA. RTX Graphics card required.",
        .section = "Setup and Information",
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
        .label = "TAA/DLAA mod by Hartapfel. RenoDX framework by ShortFuse. DLAA, DLSS Frame Generation and Reflex by NVIDIA.",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "TAA / DLAA / DLSS Frame Generation | Brotherhood | 32-bit addon",
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

BOOL APIENTRY DllMain(HMODULE module, DWORD reason, LPVOID reserved) {
  if (reason == DLL_PROCESS_ATTACH) {
    if (!reshade::register_addon(module)) return FALSE;
    acbrotherhood::dlaa::addon_module = module;
    acbrotherhood::presentation::addon_module = module;
    // DX9Ex enables GPU sharing; it does not enable HDR or change formats.
    // The HDR addon already requests this through the same shared utility.
    // Standalone TAA keeps ordinary DX9 unless the optional helper is installed.
    std::wstring path(32768, L'\0');
    if (GetModuleFileNameW(module, path.data(), DWORD(path.size()))) {
      renodx::utils::device_upgrade::use_dx9ex_upgrade = GetFileAttributesW(
          (std::filesystem::path(path.c_str()).parent_path() / L"renodx-asscreedbrotherhood-dlaa" / L"renodx-asscreedbrotherhood-dlaa.exe").c_str()) != INVALID_FILE_ATTRIBUTES
          || GetFileAttributesW((std::filesystem::path(path.c_str()).parent_path() / L"renodx-asscreedbrotherhood-dx12" / L"renodx-asscreedbrotherhood-dx12.exe").c_str()) != INVALID_FILE_ATTRIBUTES;
    }
    renodx::utils::settings::global_name = "asscreedbrotherhood-taa";
    renodx::utils::settings::use_presets = false;
  }
  renodx::utils::settings::Use(reason, &settings);
  acbrotherhood::native_device::Use(reason);
  acbrotherhood::presentation::standalone::Use(reason, reserved != nullptr);
  acbrotherhood::presentation::Use(reason);
  renodx::utils::device_upgrade::Use(reason);
  acbrotherhood::taa::Use(reason);
  if (reason == DLL_PROCESS_DETACH) reshade::unregister_addon(module);
  return TRUE;
}
