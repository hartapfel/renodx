/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

// Opt-in support build: /DGOTSUSHIMA_UI_DIAGNOSTICS=1, Release only.
#include <atomic>
#include <map>
#include <mutex>
#include <set>
#include <sstream>
#include <string>

namespace gotsushima::diagnostics {

struct Counters {
  std::atomic_uint64_t matched = 0;
  std::atomic_uint64_t accepted = 0;
  std::atomic_uint64_t injection_ready = 0;
  std::atomic_uint64_t replacement_ready = 0;
  std::atomic_uint64_t reported_states = 0;
};

inline std::map<uint32_t, Counters> counters;
inline std::map<uint32_t, uint32_t> replacements;
inline std::mutex inventory_mutex;
inline std::set<uint32_t> seen_shaders;
inline std::atomic_uint64_t last_sample_ms = 0;
inline uint32_t setting_reports = 0;
inline uint32_t summaries = 0;
inline std::map<std::string, float> previous_settings;
inline const renodx::utils::settings::Settings* observed_settings = nullptr;

inline void Log(const std::string& message) {
  reshade::log::message(reshade::log::level::info, ("[GHOST-UI-DIAG v2] " + message).c_str());
}

inline void OnInitDevice(reshade::api::device* device) {
  uint32_t vendor = 0;
  uint32_t product = 0;
  device->get_property(reshade::api::device_properties::vendor_id, &vendor);
  device->get_property(reshade::api::device_properties::device_id, &product);
  std::ostringstream line;
  line << "DEVICE api=0x" << std::hex << static_cast<uint32_t>(device->get_api())
       << " vendor=0x" << vendor << " device=0x" << product;
  Log(line.str());
}

inline void OnInitPipeline(
    reshade::api::device*, reshade::api::pipeline_layout layout, uint32_t count,
    const reshade::api::pipeline_subobject* subobjects, reshade::api::pipeline pipeline) {
  for (uint32_t i = 0; i < count; ++i) {
    if ((subobjects[i].type != reshade::api::pipeline_subobject_type::pixel_shader
         && subobjects[i].type != reshade::api::pipeline_subobject_type::compute_shader)
        || subobjects[i].count == 0 || subobjects[i].data == nullptr) continue;
    const auto& desc = *static_cast<const reshade::api::shader_desc*>(subobjects[i].data);
    if (desc.code == nullptr || desc.code_size == 0) continue;
    const auto hash = renodx::utils::hash::ComputeCRC32(static_cast<const uint8_t*>(desc.code), desc.code_size);
    // Keep the inventory bounded even if the game compiles many variants.
    const std::lock_guard lock(inventory_mutex);
    if (seen_shaders.size() >= 8192 || !seen_shaders.insert(hash).second) continue;
    std::ostringstream line;
    line << (subobjects[i].type == reshade::api::pipeline_subobject_type::compute_shader ? "CS" : "PS")
         << " hash=0x" << std::hex << hash << " pipeline=0x" << pipeline.handle
         << " layout=0x" << layout.handle << std::dec << " bytes=" << desc.code_size
         << " registered=" << counters.contains(hash);
    if (const auto found = replacements.find(hash); found != replacements.end()) {
      line << " replacement_for=0x" << std::hex << found->second;
    }
    Log(line.str());
  }
}

inline void Observe(reshade::api::command_list* cmd_list, uint32_t hash, Counters* counts, bool accepted, bool hud) {
  counts->matched.fetch_add(1, std::memory_order_relaxed);
  if (accepted) counts->accepted.fetch_add(1, std::memory_order_relaxed);
  const auto* command_state = renodx::utils::shader::GetCurrentState(cmd_list);
  const renodx::utils::shader::PipelineShaderDetails* details = nullptr;
  // Include the bloom compute shader without reading an unrelated pixel PSO.
  if (command_state != nullptr) {
    for (const auto index : {renodx::utils::shader::PIXEL_INDEX, renodx::utils::shader::COMPUTE_INDEX}) {
      const auto* candidate = command_state->stage_states[index].pipeline_details;
      if (candidate != nullptr && candidate->compatible_shader_infos[index].shader_hash == hash) {
        details = candidate;
        break;
      }
    }
  }
  const reshade::api::blend_desc* blend = nullptr;
  if (details != nullptr) {
    for (const auto& item : details->subobjects) {
      if (item.type == reshade::api::pipeline_subobject_type::blend_state && item.count != 0 && item.data != nullptr) {
        blend = static_cast<const reshade::api::blend_desc*>(item.data);
        break;
      }
    }
  }
  const bool injection = details != nullptr && details->injection_layout.handle != 0 && details->injection_index >= 0;
  const bool replacement = details != nullptr && details->replacement_pipeline.handle != 0;
  if (injection) counts->injection_ready.fetch_add(1, std::memory_order_relaxed);
  if (replacement) counts->replacement_ready.fetch_add(1, std::memory_order_relaxed);
  const uint64_t bit = 1ull << (uint32_t(accepted) | (uint32_t(injection) << 1)
      | (uint32_t(replacement) << 2) | (uint32_t(blend != nullptr) << 3) | (uint32_t(details != nullptr) << 4));
  if ((counts->reported_states.fetch_or(bit, std::memory_order_relaxed) & bit) != 0) return;
  std::ostringstream line;
  line << "MATCH hash=0x" << std::hex << hash << " cmd=0x" << cmd_list->get_native() << std::dec << " hud=" << hud
       << " allowed=" << accepted << " details=" << (details != nullptr)
       << " blend_found=" << (blend != nullptr) << " injection_ready=" << injection
       << " replacement_ready=" << replacement;
  if (hud) line << " decision=" << (accepted ? "color" : details == nullptr ? "missing_pipeline" : blend == nullptr ? "missing_blend" : "multiply_guard");
  if (blend != nullptr) {
    line << " blend_enable=" << blend->blend_enable[0]
         << " src_rgb=" << static_cast<uint32_t>(blend->source_color_blend_factor[0])
         << " dst_rgb=" << static_cast<uint32_t>(blend->dest_color_blend_factor[0])
         << " rgb_op=" << static_cast<uint32_t>(blend->color_blend_op[0])
         << " src_alpha=" << static_cast<uint32_t>(blend->source_alpha_blend_factor[0])
         << " dst_alpha=" << static_cast<uint32_t>(blend->dest_alpha_blend_factor[0])
         << " write_mask=" << uint32_t(blend->render_target_write_mask[0]);
  }
  if (details != nullptr) {
    line << " pipeline=0x" << std::hex << details->pipeline.handle
         << " layout=0x" << details->layout.handle << " injection_layout=0x" << details->injection_layout.handle
         << " replacement=0x" << details->replacement_pipeline.handle << std::dec
         << " injection_index=" << details->injection_index << " injection_b=" << details->injection_register_index
         << " injection_offset=" << details->injection_constant_buffer_offset
         << " cached_subobjects=" << details->subobjects.size()
         << " initialized_replacement=" << details->initialized_replacement;
  }
  Log(line.str());
}

inline void OnPresent(
    reshade::api::command_queue*, reshade::api::swapchain* swapchain, const reshade::api::rect*,
    const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  const uint64_t now = GetTickCount64();
  uint64_t previous = last_sample_ms.load(std::memory_order_relaxed);
  if (now - previous < 1000 || !last_sample_ms.compare_exchange_strong(previous, now)) return;
  // Settings writes use the same lock. Never sample the per-frame random seed.
  const std::unique_lock lock(renodx::utils::mutex::global_mutex);
  for (const auto* setting : *observed_settings) {
    if (setting->binding == nullptr || setting_reports >= 300) continue;
    const float value = setting->GetValue();
    const auto found = previous_settings.find(setting->key);
    if (found != previous_settings.end() && found->second == value) continue;
    previous_settings[setting->key] = value;
    ++setting_reports;
    std::ostringstream line;
    line << "SETTING key=" << setting->key << " ui=" << value
         << " parsed=" << setting->parse(value) << " cpu_bound=" << *setting->binding;
    Log(line.str());
  }
  // At most ten minutes of summaries; counters continue without log growth.
  if (summaries >= 600) return;
  if (++summaries != 1 && summaries % 5 != 0) return;
  std::ostringstream line;
  line << "SUMMARY sample=" << summaries << " color_space=" << static_cast<uint32_t>(swapchain->get_color_space())
       << " runtime_replacements=" << renodx::utils::shader::runtime_replacement_count.load();
  Log(line.str());
  for (const auto& [hash, counts] : counters) {
    std::ostringstream row;
    row << "COUNTERS hash=0x" << std::hex << hash << std::dec << " matched=" << counts.matched.load()
        << " accepted=" << counts.accepted.load() << " injection_ready=" << counts.injection_ready.load()
        << " replacement_ready=" << counts.replacement_ready.load();
    Log(row.str());
  }
}

inline void Attach(renodx::mods::shader::CustomShaders* shaders, const renodx::utils::settings::Settings* settings) {
  observed_settings = settings;
  Log("START Release " __DATE__ " " __TIME__ "; UI diagnostic v2; " + std::to_string(sizeof(ShaderInjectData)) + "-byte injection b13 space50; pipeline metadata retention enabled; shaders and blend guard unchanged.");
  Log("Readiness and cpu_bound are CPU-side evidence, not GPU readback. Initial replacement_ready=0 can be normal lazy creation.");
  for (auto& [hash, shader] : *shaders) {
    auto* counts = &counters.try_emplace(hash).first->second;
    replacements.emplace(renodx::utils::hash::ComputeCRC32(shader.code.data(), shader.code.size()), hash);
    const bool hud = shader.on_replace != nullptr;
    if (hud) {
      shader.on_replace = [hash, counts, previous = shader.on_replace](auto* cmd_list) {
        const bool accepted = previous(cmd_list);
        Observe(cmd_list, hash, counts, accepted, true);
        return accepted;
      };
    } else {
      // Do not add a replacement gate or an on_drawn hook to scene shaders:
      // either would change the normal replacement/replay policy.
      shader.on_draw = [hash, counts, previous = shader.on_draw](auto* cmd_list) {
        const bool accepted = previous == nullptr || previous(cmd_list);
        Observe(cmd_list, hash, counts, accepted, false);
        return accepted;
      };
    }
    std::ostringstream line;
    line << "REGISTER hash=0x" << std::hex << hash << std::dec << " hud=" << hud << " bytes=" << shader.code.size();
    Log(line.str());
  }
}

inline void Use(DWORD reason) {
  if (reason == DLL_PROCESS_ATTACH) {
    reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::register_event<reshade::addon_event::init_pipeline>(OnInitPipeline);
    reshade::register_event<reshade::addon_event::present>(OnPresent);
  } else if (reason == DLL_PROCESS_DETACH) {
    reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
    reshade::unregister_event<reshade::addon_event::init_pipeline>(OnInitPipeline);
    reshade::unregister_event<reshade::addon_event::present>(OnPresent);
  }
}

}  // namespace gotsushima::diagnostics
