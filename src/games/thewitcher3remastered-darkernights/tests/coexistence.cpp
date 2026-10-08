/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#define ImTextureID ImU64
#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>
#include <intrin.h>
#include <array>
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

namespace {
HMODULE ModuleForAddress(const void* address) {
  HMODULE module = nullptr;
  GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                    reinterpret_cast<LPCWSTR>(address), &module);
  return module;
}
struct Callback { reshade::addon_event event; void* function; HMODULE owner; };
std::vector<Callback> callbacks;
std::set<HMODULE> addons;
unsigned invalid_registrations = 0;
std::map<std::pair<std::string, std::string>, std::string> configuration;
}

extern "C" __declspec(dllexport) bool ReShadeRegisterAddon(void* module, uint32_t) {
  addons.insert(static_cast<HMODULE>(module)); return true;
}
extern "C" __declspec(dllexport) void ReShadeUnregisterAddon(void* module) {
  addons.erase(static_cast<HMODULE>(module));
}
extern "C" __declspec(dllexport) void ReShadeLogMessage(void*, int, const char*) {}
extern "C" __declspec(dllexport) const imgui_function_table* ReShadeGetImGuiFunctionTable(uint32_t) {
  static imgui_function_table table{}; return &table;
}
extern "C" __declspec(dllexport) bool ReShadeGetConfigValue(void*, reshade::api::effect_runtime*, const char* section,
                                                        const char* key, char* value, size_t* size) {
  const auto entry = configuration.find({section, key});
  if (entry == configuration.end()) return false;
  if (!value || *size <= entry->second.size()) { *size = entry->second.size(); return false; }
  std::memcpy(value, entry->second.c_str(), entry->second.size() + 1);
  *size = entry->second.size();
  return true;
}
extern "C" __declspec(dllexport) void ReShadeSetConfigValue(void*, reshade::api::effect_runtime*, const char* section,
                                                        const char* key, const char* value) {
  configuration[{section, key}] = value;
}
extern "C" __declspec(dllexport) void ReShadeRegisterEvent(reshade::addon_event event, void* function) {
  HMODULE owner = ModuleForAddress(function);
  if (!addons.contains(owner)) { ++invalid_registrations; return; }
  if (std::ranges::none_of(callbacks, [&](const auto& item) { return item.event == event && item.function == function; })) {
    callbacks.push_back({event, function, owner});
  }
}
extern "C" __declspec(dllexport) void ReShadeUnregisterEvent(reshade::addon_event event, void* function) {
  std::erase_if(callbacks, [&](const auto& item) { return item.event == event && item.function == function; });
}
extern "C" __declspec(dllexport) void ReShadeRegisterOverlay(const char*, void(*)(reshade::api::effect_runtime*)) {}
extern "C" __declspec(dllexport) void ReShadeUnregisterOverlay(const char*, void(*)(reshade::api::effect_runtime*)) {}

using namespace reshade::api;
#include "mock_device.hpp"

#ifndef WITCHER_COEXISTENCE_HOST_ONLY
int main(int argc, char** argv) {
  if (argc != 4) { std::puts("Usage: coexistence.exe lighting.addon64 hdr.addon64 lighting-first|hdr-first"); return 1; }
  const bool lighting_first = std::strcmp(argv[3], "lighting-first") == 0;
  for (unsigned cycle = 0; cycle < 2; ++cycle) {
    HMODULE first = LoadLibraryA(argv[lighting_first ? 1 : 2]);
    HMODULE second = LoadLibraryA(argv[lighting_first ? 2 : 1]);
    if (!first || !second) { std::printf("FAIL: DLL load (%lu)\n", GetLastError()); return 2; }
    HMODULE lighting = lighting_first ? first : second;
    for (const auto& callback : callbacks) {
      if (callback.owner == lighting && callback.event == reshade::addon_event::create_pipeline_layout) {
        std::puts("FAIL: lighting addon modifies native root-signature creation"); return 3;
      }
    }
    MockDevice device;
    const auto init_callbacks = callbacks;
    for (const auto& callback : init_callbacks) {
      if (callback.event == reshade::addon_event::init_device) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::init_device>::decl>(callback.function)(&device);
      }
    }
    if (device.collisions) { std::puts("FAIL: addons overwrote each other's device private data"); return 4; }

    // A native pixel layout after the installed HDR addon injected 53 DWORDs.
    descriptor_range native_ranges[2]{};
    pipeline_layout_param native_params[3]{};
    for (unsigned i = 0; i < 2; ++i) {
      native_ranges[i].type = descriptor_type::constant_buffer;
      native_ranges[i].dx_register_index = i == 0 ? 3 : 12;
      native_ranges[i].count = 1;
      native_ranges[i].visibility = shader_stage::pixel;
      native_params[i].type = pipeline_layout_param_type::push_descriptors;
      native_params[i].push_descriptors = native_ranges[i];
    }
    native_params[2].type = pipeline_layout_param_type::push_constants;
    native_params[2].push_constants.dx_register_index = 13;
    native_params[2].push_constants.dx_register_space = 50;
    native_params[2].push_constants.count = 53;
    native_params[2].push_constants.visibility = shader_stage::pixel;
    const auto layout_callbacks = callbacks;
    for (const auto& callback : layout_callbacks) {
      if (callback.owner == lighting && callback.event == reshade::addon_event::init_pipeline_layout) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::init_pipeline_layout>::decl>(callback.function)(
            &device, 3, native_params, {0x1234});
      }
    }
    if (device.layout_creations || native_params[2].push_constants.count != 53) {
      std::puts("FAIL: lighting addon changed or cloned the HDR root signature"); return 5;
    }
    // Also exercise the installed HDR DLL's actual create-layout callback.
    // HDR builds may use either root constants or a settings CBV.
    uint32_t hdr_count = 2;
    pipeline_layout_param* hdr_params = native_params;
    const auto create_callbacks = callbacks;
    for (const auto& callback : create_callbacks) {
      if (callback.event == reshade::addon_event::create_pipeline_layout) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::create_pipeline_layout>::decl>(callback.function)(
            &device, hdr_count, hdr_params);
      }
    }
    bool hdr_injected = false;
    for (uint32_t i = 0; i < hdr_count; ++i) {
      if (hdr_params[i].type == pipeline_layout_param_type::push_constants) {
        const auto& hdr = hdr_params[i].push_constants;
        hdr_injected |= hdr.dx_register_index == 13 && hdr.dx_register_space == 50 && hdr.count > 0;
      }
      if (hdr_params[i].type == pipeline_layout_param_type::push_descriptors) {
        const auto& hdr = hdr_params[i].push_descriptors;
        hdr_injected |= hdr.type == descriptor_type::constant_buffer && hdr.dx_register_index == 13
                        && hdr.dx_register_space == 50 && hdr.count == 1;
      }
    }
    if (!hdr_injected) { std::puts("FAIL: HDR DLL could not inject its settings binding"); return 9; }
    for (const auto& callback : layout_callbacks) {
      if (callback.event == reshade::addon_event::init_pipeline_layout) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::init_pipeline_layout>::decl>(callback.function)(
            &device, hdr_count, hdr_params, {0x2345});
      }
    }
    if (device.layout_creations) { std::puts("FAIL: lighting addon created an extra root signature"); return 10; }
    const auto destroy_callbacks = callbacks;
    for (const auto& callback : destroy_callbacks) {
      if (callback.event == reshade::addon_event::destroy_device) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::destroy_device>::decl>(callback.function)(&device);
      }
    }
    if (!device.private_data.empty()) { std::puts("FAIL: device private data survived destruction"); return 6; }
    if (!FreeLibrary(first) || !FreeLibrary(second)) return 7;
    if (!callbacks.empty() || !addons.empty() || invalid_registrations) {
      std::puts("FAIL: unbalanced callbacks/addon registration after detach"); return 8;
    }
  }
  std::printf("PASS: %s, device isolation, unchanged HDR root signatures/settings binding, destruction, detach and reload\n", argv[3]);
}
#endif
