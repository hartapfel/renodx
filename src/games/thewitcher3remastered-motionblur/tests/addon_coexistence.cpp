/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Load actual DLLs without launching the game. Reuse the existing ReShade host.
#define WITCHER_COEXISTENCE_HOST_ONLY
#define ReShadeUnregisterAddon TestUnregisterAddon
#include "../../thewitcher3remastered-darkernights/tests/coexistence.cpp"
#undef ReShadeUnregisterAddon

extern "C" __declspec(dllexport) void ReShadeUnregisterAddon(void* module) {
  TestUnregisterAddon(module);
  // ReShade removes all events belonging to a departing addon.
  std::erase_if(callbacks, [&](const auto& item) { return item.owner == module; });
}

extern "C" __declspec(dllexport) void ReShadeGetBasePath(char* path, size_t* size) {
  char directory[MAX_PATH]{};
  GetCurrentDirectoryA(MAX_PATH, directory);
  const size_t length = std::strlen(directory);
  if (path && *size > length) std::memcpy(path, directory, length + 1);
  *size = length;
}

int main(int argc, char** argv) {
  if (argc < 2) {
    std::puts("Usage: addon-coexistence.exe addon1.addon64 [addon2.addon64 ...]");
    return 1;
  }
  // Same-order unloading matches the game's startup probe-device teardown.
  // Reverse the arguments to cover the other registration/unloading order.
  for (unsigned cycle = 0; cycle < 2; ++cycle) {
    std::vector<HMODULE> modules;
    for (int i = 1; i < argc; ++i) {
      std::printf("LOAD %s\n", argv[i]);
      std::fflush(stdout);
      modules.push_back(LoadLibraryA(argv[i]));
      if (!modules.back()) {
        std::printf("FAIL: DLL load (%lu)\n", GetLastError());
        return 2;
      }
    }
    MockDevice device;
    for (const auto& callback : std::vector(callbacks)) {
      if (callback.event == reshade::addon_event::init_device) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::init_device>::decl>(callback.function)(&device);
      }
    }
    for (const auto& callback : std::vector(callbacks)) {
      if (callback.event == reshade::addon_event::destroy_device) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::destroy_device>::decl>(callback.function)(&device);
      }
    }
    if (device.collisions || !device.private_data.empty()) {
      std::puts("FAIL: device state collided or survived destruction");
      return 3;
    }
    for (auto module : modules) {
      char path[MAX_PATH]{};
      GetModuleFileNameA(module, path, MAX_PATH);
      std::printf("UNLOAD %s\n", path);
      std::fflush(stdout);
      if (!FreeLibrary(module)) return 4;
    }
    if (!callbacks.empty() || !addons.empty() || invalid_registrations) {
      std::printf("FAIL: %zu callbacks, %zu addons, %u invalid registrations\n",
                  callbacks.size(), addons.size(), invalid_registrations);
      return 5;
    }
  }
  std::puts("PASS: two device lifecycles, clean detach and DLL reload");
}
