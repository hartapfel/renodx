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
#include <filesystem>

int main(int argc, char** argv) {
  if (argc == 3 && std::strcmp(argv[1], "--interfaces") == 0) {
    // Includes all native shader dumps and all CSOs extracted from both the
    // installed HDR addon and our HDR build. The seven native grades and seven
    // replacements in each HDR build are the only accepted shaders.
    const std::set<uint32_t> expected = {
        0x16967617, 0x9600E32A, 0xAD02BAB3, 0xC5AB358E, 0xF961D049, 0x2BF760E2, 0x6DDA5B7B,
        0xCE1A0970, 0x9259C77E, 0xF461A605, 0x9743E54D, 0x92B4C36F, 0xC57C4E7E, 0x3D87EF7F,
        0xD0775084, 0x14C9BF5D, 0x550A0973, 0xC74FBE7E, 0xB74F942D, 0xEF359CF7, 0xCFAD6F3F,
    };
    unsigned tested = 0, accepted = 0;
    for (const auto& file : std::filesystem::directory_iterator(argv[2])) {
      if (file.path().extension() != ".cso") continue;
      std::ifstream stream(file.path(), std::ios::binary);
      std::vector<uint8_t> bytes((std::istreambuf_iterator<char>(stream)), {});
      const uint32_t hash = renodx::utils::hash::ComputeCRC32(bytes.data(), bytes.size());
      bool signed_transport = false;
      const bool match = witcher::night::vegetation::IsGradingShader(bytes, &signed_transport);
      if (match != expected.contains(hash)) {
        std::printf("FAIL: interface %08X (%s)\n", hash, file.path().string().c_str()); return 7;
      }
      ++tested;
      accepted += match;
      if (match && hash != 0x16967617 && hash != 0x9600E32A && hash != 0xAD02BAB3
          && hash != 0xC5AB358E && hash != 0xF961D049 && hash != 0x2BF760E2 && hash != 0x6DDA5B7B) {
        if (!signed_transport) return 13;
        bytes[4] ^= 0x42; // Different container identity/hash, identical grading contract.
        if (!witcher::night::vegetation::IsGradingShader(bytes)) return 8;
        for (size_t length = 0; length < bytes.size(); length += 137) {
          if (witcher::night::vegetation::IsGradingShader({bytes.data(), length})) return 9;
        }
        std::fill_n(bytes.begin() + 32, 4, uint8_t(0xff)); // Invalid part offset.
        if (witcher::night::vegetation::IsGradingShader(bytes)) return 10;
      } else if (signed_transport) return 14;
    }
    if (tested == 0 || accepted == 0) return 11;
    std::printf("PASS: %u shader interfaces checked, %u audited grades accepted; unrelated effects and malformed containers excluded\n", tested, accepted);
    return 0;
  }
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
      auto* state = renodx::utils::data::Get<witcher::night::vegetation::DeviceData>(&device);
      std::shared_lock lock(state->grading_mutex);
      observed = state->grading_pipelines.contains(p.handle)
          && !renodx::mods::shader::custom_shaders.contains(actual)
          && !details.replacement_pipeline.handle;
      if (observed) observed = state->grading_pipelines.at(p.handle)
          == (renodx::utils::hash::ComputeCRC32(static_cast<const uint8_t*>(shader.code), shader.code_size) != hash);
      std::printf("%08X -> %08X: %s\n", hash, actual, observed ? "observe only" : "FAIL");
    });
    if (!observed) return 5;
    for (const auto& callback : callbacks) {
      if (callback.event == reshade::addon_event::destroy_pipeline) {
        reinterpret_cast<reshade::addon_event_traits<reshade::addon_event::destroy_pipeline>::decl>(callback.function)(&device, p);
      }
    }
    if (renodx::utils::data::Get<witcher::night::vegetation::DeviceData>(&device)->grading_pipelines.contains(p.handle)) return 12;
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
