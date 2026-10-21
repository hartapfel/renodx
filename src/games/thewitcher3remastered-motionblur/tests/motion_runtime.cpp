/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include <cstdio>
#include <set>

#include "../motion_blur.hpp"

// Exercise the real module attach/detach path without a running game. The
// runtime must not enable frame-wide descriptor/CBV tracking, even in Native.
static std::set<std::pair<reshade::addon_event, void*>> callbacks;
extern "C" __declspec(dllexport) bool ReShadeRegisterAddon(void*, uint32_t) { return true; }
extern "C" __declspec(dllexport) void ReShadeUnregisterAddon(void*) {}
extern "C" __declspec(dllexport) void ReShadeLogMessage(void*, int, const char*) {}
extern "C" __declspec(dllexport) void ReShadeRegisterEvent(reshade::addon_event event, void* callback) {
  callbacks.emplace(event, callback);
}
extern "C" __declspec(dllexport) void ReShadeUnregisterEvent(reshade::addon_event event, void* callback) {
  callbacks.erase({event, callback});
}

int main() {
  // Native must return before dereferencing any command/device state.
  witcher::motion::mode = 0.f;
  witcher::motion::OnBindPipeline(nullptr, reshade::api::pipeline_stage::all, {});
  witcher::motion::OnBindTables(nullptr, reshade::api::shader_stage::all, {}, 0, 0, nullptr);
  witcher::motion::OnStates(nullptr, 1, nullptr, nullptr);
  if (witcher::motion::OnDispatch(nullptr, 1, 1, 1)) return 6;
  witcher::motion::mode = 1.f;
  for (int iteration = 0; iteration < 2; ++iteration) {
    witcher::motion::Use(DLL_PROCESS_ATTACH);
    if (!callbacks.contains({reshade::addon_event::dispatch,
                             reinterpret_cast<void*>(&witcher::motion::OnDispatch)})) {
      std::puts("FAIL: motion runtime did not register its compute dispatch hook");
      return 4;
    }
    for (const auto& [event, callback] : callbacks) {
      if (event == reshade::addon_event::draw || event == reshade::addon_event::draw_indexed
          || event == reshade::addon_event::draw_or_dispatch_indirect
          || event == reshade::addon_event::push_descriptors
          || event == reshade::addon_event::push_constants
          || event == reshade::addon_event::copy_descriptor_tables
          || event == reshade::addon_event::update_descriptor_tables
          || event == reshade::addon_event::init_resource_view) {
        std::puts("FAIL: motion runtime registered game-wide draw/descriptor/constant-buffer tracking");
        return 5;
      }
    }
    witcher::motion::Use(DLL_PROCESS_DETACH);
    if (!callbacks.empty()) {
      std::puts("FAIL: motion runtime left registered callbacks after detach");
      return 3;
    }
  }
  std::puts("PASS: native binding reuse, no descriptor/CBV tracking, detach and reattach without DevKit");
}
