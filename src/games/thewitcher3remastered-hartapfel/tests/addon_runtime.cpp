/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#define ImTextureID ImU64
#include <cstdio>
#include <cstring>
#include <set>
#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

// Load the real Release addon into a minimal host. No game or GPU callbacks
// are invoked; this verifies that the expensive feature callbacks are absent.
static std::set<std::pair<reshade::addon_event, void*>> callbacks;
static bool setting_read = false;
static bool native_effects_logged = false;
extern "C" __declspec(dllexport) bool ReShadeRegisterAddon(void*, uint32_t) { return true; }
extern "C" __declspec(dllexport) void ReShadeUnregisterAddon(void*) {}
extern "C" __declspec(dllexport) const imgui_function_table* ReShadeGetImGuiFunctionTable(uint32_t) {
  static const imgui_function_table table{};
  return &table;
}
extern "C" __declspec(dllexport) void ReShadeLogMessage(void*, int, const char* message) {
  if (std::strstr(message, "BT.709 video correction only; descriptor heap tracking disabled")) native_effects_logged = true;
}
extern "C" __declspec(dllexport) void ReShadeGetBasePath(char* path, size_t* size) {
  if (path && *size) path[0] = '\0';
  *size = 0;
}
extern "C" __declspec(dllexport) bool ReShadeGetConfigValue(void*, reshade::api::effect_runtime*, const char* section, const char* key, char* value, size_t* size) {
  if (std::strcmp(section, "renodx")) return false;
  if (std::strncmp(key, "Night", 5) && std::strcmp(key, "GameplayCameraLightStrength")
      && std::strcmp(key, "CutsceneCameraLightStrength") && std::strcmp(key, "MoonSize")
      && std::strcmp(key, "CpuPerformanceMode") && std::strcmp(key, "FxMotionBlurMode")
      && std::strcmp(key, "FxMotionIntensity") && std::strcmp(key, "FxMotionShutterAngle")
      && std::strcmp(key, "FxMotionSamples")
      && std::strcmp(key, "VideoAutoHDR")) return false;
  setting_read = true;
  if (value && *size >= 2) {
    value[0] = '1';
    value[1] = '\0';
  }
  *size = 1;
  return true;
}
extern "C" __declspec(dllexport) void ReShadeSetConfigValue(void*, reshade::api::effect_runtime*, const char*, const char*, const char*) {}
extern "C" __declspec(dllexport) void ReShadeRegisterOverlay(const char*, void(*)(reshade::api::effect_runtime*)) {}
extern "C" __declspec(dllexport) void ReShadeUnregisterOverlay(const char*, void(*)(reshade::api::effect_runtime*)) {}
extern "C" __declspec(dllexport) void ReShadeRegisterEvent(reshade::addon_event event, void* callback) { callbacks.emplace(event, callback); }
extern "C" __declspec(dllexport) void ReShadeUnregisterEvent(reshade::addon_event event, void* callback) { callbacks.erase({event, callback}); }

int main(int argc, char** argv) {
  if (argc != 2) return 1;
  auto module = LoadLibraryA(argv[1]);
  if (!module) { std::printf("FAIL: LoadLibrary error %lu\n", GetLastError()); return 2; }
  if (setting_read || !native_effects_logged) return 3;
  const auto has_event = [](reshade::addon_event event) {
    for (const auto& registration : callbacks) if (registration.first == event) return true;
    return false;
  };
  for (const auto event : {reshade::addon_event::update_descriptor_tables, reshade::addon_event::copy_descriptor_tables,
                           reshade::addon_event::bind_descriptor_tables, reshade::addon_event::push_descriptors,
                           reshade::addon_event::push_constants, reshade::addon_event::bind_render_targets_and_depth_stencil}) {
    if (has_event(event)) { std::printf("FAIL: unexpected tracking event %u\n", unsigned(event)); return 4; }
  }
  // The shared shader state and native bloom GPU buffer each reset once.
  unsigned resets = 0;
  for (const auto& registration : callbacks) if (registration.first == reshade::addon_event::reset_command_list) ++resets;
  if (resets != 2) return 7;
  for (const auto event : {reshade::addon_event::bind_pipeline, reshade::addon_event::draw,
                           reshade::addon_event::create_pipeline_layout, reshade::addon_event::present,
                           reshade::addon_event::init_swapchain}) {
    if (!has_event(event)) return 5;
  }
  if (!FreeLibrary(module) || !callbacks.empty()) return 6;
  std::puts("PASS: real Release addon ignores removed lighting/motion/movie settings, has no motion/movie/descriptor tracking callbacks, retains HDR events and detaches cleanly");
}
