/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include <cstdio>
#include <set>

#include "../motion_blur.hpp"

// Exercise the real module attach/detach path without a running game. The
// resource tracker belongs to each addon module, even when DevKit is loaded.
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
  for (int iteration = 0; iteration < 2; ++iteration) {
    witcher::motion::Use(DLL_PROCESS_ATTACH);
    if (renodx::utils::resource::shared.data == nullptr
        || !callbacks.contains({reshade::addon_event::init_resource_view,
                                reinterpret_cast<void*>(&renodx::utils::resource::OnInitResourceView)})) {
      std::puts("FAIL: motion runtime did not initialize its resource dependency");
      return 1;
    }
    // This lookup dereferenced the uninitialized resource map in both game
    // crash dumps, before any private motion-blur GPU work was submitted.
    if (renodx::utils::resource::GetResourceViewInfo({0x1234}, [](const auto&) {})) return 2;
    witcher::motion::Use(DLL_PROCESS_DETACH);
    if (!callbacks.empty()) {
      std::puts("FAIL: motion runtime left registered callbacks after detach");
      return 3;
    }
  }
  std::puts("PASS: attach, resource lookup, detach and reattach without DevKit");
}
