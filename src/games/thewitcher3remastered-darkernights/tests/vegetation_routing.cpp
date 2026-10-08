/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
// Reuse the CPU ReShade host; compile the standalone's actual registration
// code here so its isolated tracker and observation callbacks are inspectable.
#define WITCHER_COEXISTENCE_HOST_ONLY
#include "coexistence.cpp"
#define DllMain LightingDllMain
#include "../addon.cpp"
#undef DllMain
#include <fstream>

int main(int argc, char** argv) {
  if (argc != 4) {
    std::puts("Usage: vegetation-routing.exe originals-directory hdr.addon64|none lighting-first|hdr-first");
    return 1;
  }
  const bool with_hdr = std::strcmp(argv[2], "none") != 0;
  const bool lighting_first = std::strcmp(argv[3], "lighting-first") == 0;
  std::printf("Testing %s, %s\n", with_hdr ? "installed HDR" : "standalone", argv[3]);
  std::fflush(stdout);
  HMODULE hdr = nullptr;
  if (with_hdr && !lighting_first) hdr = LoadLibraryA(argv[2]);
  if (!LightingDllMain(GetModuleHandleW(nullptr), DLL_PROCESS_ATTACH, nullptr)) return 2;
  if (with_hdr && lighting_first) hdr = LoadLibraryA(argv[2]);
  if (with_hdr && !hdr) return 3;
  MockDevice device;
  for (const auto& callback : callbacks) {
    if (callback.event == reshade::addon_event::init_device) {
      reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::init_device>::decl>(callback.function)(&device);
    }
  }
  uint64_t handle = 0x5000;
  for (uint32_t hash : {0x16967617u, 0x9600E32Au, 0xAD02BAB3u, 0xC5AB358Eu, 0xF961D049u, 0x2BF760E2u, 0x6DDA5B7Bu}) {
    char name[64]; std::snprintf(name, sizeof(name), "/0x%08X.ps_6_6.cso", hash);
    std::ifstream file(std::string(argv[1]) + name, std::ios::binary);
    std::vector<uint8_t> original((std::istreambuf_iterator<char>(file)), {});
    if (original.empty() || renodx::utils::hash::ComputeCRC32(original.data(), original.size()) != hash) return 4;
    shader_desc shader = {original.data(), original.size()};
    const pipeline_subobject subobject = {pipeline_subobject_type::pixel_shader, 1, &shader};
    // The foreign DLL performs its real create-time substitution, exactly as
    // ReShade does before notifying each addon's isolated pipeline tracker.
    for (const auto& callback : callbacks) {
      if (callback.event == reshade::addon_event::create_pipeline) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::create_pipeline>::decl>(callback.function)(
            &device, {}, 1, &subobject);
      }
    }
    const pipeline p = {++handle};
    for (const auto& callback : callbacks) {
      if (callback.event == reshade::addon_event::init_pipeline) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::init_pipeline>::decl>(callback.function)(
            &device, {}, 1, &subobject, p);
      }
    }
    bool observed = false;
    renodx::utils::shader::GetPipelineShaderDetails(p, [&](const auto& details) {
      const uint32_t actual = details.compatible_shader_infos[renodx::utils::shader::PIXEL_INDEX].shader_hash;
      const auto entry = renodx::mods::shader::custom_shaders.find(actual);
      const auto* observer = entry == renodx::mods::shader::custom_shaders.end() ? nullptr
          : entry->second.on_draw.template target<bool (*)(command_list*)>();
      observed = entry != renodx::mods::shader::custom_shaders.end()
          && observer && *observer == &witcher::night::vegetation::Arm
          && !entry->second.on_replace(nullptr) && !entry->second.on_inject(nullptr)
          && !details.replacement_pipeline.handle;
      std::printf("%08X -> %08X: %s\n", hash, actual, observed ? "observe only" : "FAIL");
    });
    if (!observed) return 5;
    for (const auto& callback : callbacks) {
      if (callback.event == reshade::addon_event::destroy_pipeline) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::destroy_pipeline>::decl>(callback.function)(&device, p);
      }
    }
    // Older HDR builds point directly at embedded bytecode; newer builds
    // allocate a copy for the create event. Never free the DLL's image data.
    MEMORY_BASIC_INFORMATION storage = {};
    if (shader.code != original.data() && VirtualQuery(shader.code, &storage, sizeof(storage))
        && storage.Type == MEM_PRIVATE) std::free(const_cast<void*>(shader.code));
  }
  for (const auto& callback : callbacks) {
    if (callback.event == reshade::addon_event::destroy_device) {
      reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::destroy_device>::decl>(callback.function)(&device);
    }
  }
  if (hdr) FreeLibrary(hdr);
  LightingDllMain(GetModuleHandleW(nullptr), DLL_PROCESS_DETACH, nullptr);
  if (device.collisions || !device.private_data.empty() || !callbacks.empty() || !addons.empty() || invalid_registrations) return 6;
  std::puts("PASS: all seven grading routes remain observation-only, alone/with actual HDR substitution, with clean isolation and detach");
}
