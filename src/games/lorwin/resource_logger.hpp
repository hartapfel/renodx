/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <algorithm>
#include <array>
#include <atomic>
#include <cstdint>
#include <mutex>
#include <shared_mutex>
#include <sstream>

#include <Windows.h>
#include <include/reshade.hpp>

#include "../../mods/shader.hpp"
#include "../../utils/bitwise.hpp"
#include "../../utils/descriptor.hpp"
#include "../../utils/pipeline_layout.hpp"
#include "../../utils/resource.hpp"
#include "../../utils/state.hpp"

namespace lorwin::resource_logger {

inline float enabled = 0.f;

inline constexpr uint32_t kTrackedSrvCount = 8u;
inline constexpr uint32_t kBurstFrameCount = 8u;
inline constexpr uint32_t kBurstDrawLimit = 32u;
inline constexpr std::array<uint32_t, 4> kPostProcessShaders = {
    0xCFC0C7CFu,
    0x17BBC7EEu,
    0x9805B9F6u,
    0x0C0E1BA4u,
};
inline constexpr std::array<const char*, kTrackedSrvCount> kSrvNames = {
    "scene_color",
    "bloom",
    "luminance",
    "depth",
    "out_of_focus",
    "noise",
    "distortion",
    "gamma",
};

struct TrackedSrv {
  reshade::api::resource_view view = {0u};
  reshade::api::descriptor_table table = {0u};
  reshade::api::descriptor_heap heap = {0u};
  uint32_t layout_param = UINT32_MAX;
  uint32_t range_index = UINT32_MAX;
  uint32_t binding = UINT32_MAX;
  uint32_t heap_index = UINT32_MAX;
};

inline std::atomic_uint64_t frame_index = 0u;
inline std::mutex burst_mutex;
inline bool was_enabled = false;
inline bool burst_active = false;
inline uint64_t burst_start_frame = 0u;
inline uint32_t burst_draw_count = 0u;
inline bool installed_callbacks = false;
inline bool installed_events = false;

inline bool IsTrackedSrvType(reshade::api::descriptor_type type) {
  switch (type) {
    case reshade::api::descriptor_type::sampler_with_resource_view:
    case reshade::api::descriptor_type::texture_shader_resource_view:
    case reshade::api::descriptor_type::buffer_shader_resource_view:
      return true;
    default:
      return false;
  }
}

inline std::array<TrackedSrv, kTrackedSrvCount> ReadPixelSrvs(
    reshade::api::command_list* cmd_list,
    bool table_relative_zero) {
  std::array<TrackedSrv, kTrackedSrvCount> result = {};
  auto* device = cmd_list != nullptr ? cmd_list->get_device() : nullptr;
  auto* state = cmd_list != nullptr ? renodx::utils::state::GetCurrentState(cmd_list) : nullptr;
  if (device == nullptr || state == nullptr || state->graphics_pipeline_layout.handle == 0u) return result;

  auto* descriptor_data = renodx::utils::data::Get<renodx::utils::descriptor::DeviceData>(device);
  if (descriptor_data == nullptr) return result;

  const std::shared_lock descriptor_lock(descriptor_data->mutex);
  renodx::utils::pipeline_layout::GetPipelineLayoutData(
      state->graphics_pipeline_layout,
      [&](const renodx::utils::pipeline_layout::PipelineLayoutData* layout_data) {
        for (uint32_t layout_param = 0u; layout_param < layout_data->ranges.size(); ++layout_param) {
          if (layout_param >= state->graphics_descriptor_tables.size()) continue;

          const auto table = state->graphics_descriptor_tables[layout_param];
          if (table.handle == 0u) continue;

          const auto& ranges = layout_data->ranges[layout_param];
          for (uint32_t range_index = 0u; range_index < ranges.size(); ++range_index) {
            const auto& range = ranges[range_index];
            if (!IsTrackedSrvType(range.type)
                || range.dx_register_space != 0u
                || range.dx_register_index >= kTrackedSrvCount
                || !renodx::utils::bitwise::HasFlag(range.visibility, reshade::api::shader_stage::pixel)) {
              continue;
            }

            reshade::api::descriptor_heap heap = {0u};
            uint32_t base_heap_index = 0u;
            device->get_descriptor_heap_offset(
                table,
                table_relative_zero ? 0u : range.binding,
                0u,
                &heap,
                &base_heap_index);
            if (heap.handle == 0u) continue;

            const auto heap_pair = descriptor_data->heaps.find(heap.handle);
            if (heap_pair == descriptor_data->heaps.end()) continue;

            const auto& heap_data = heap_pair->second;
            const uint32_t range_count = range.count == UINT32_MAX
                                             ? kTrackedSrvCount - range.dx_register_index
                                             : std::min(range.count, kTrackedSrvCount - range.dx_register_index);
            for (uint32_t offset = 0u; offset < range_count; ++offset) {
              const uint32_t heap_index = base_heap_index + offset;
              if (heap_index >= heap_data.size()) break;

              const auto& descriptor = heap_data[heap_index];
              if (!descriptor.HasResourceView()) continue;

              result[range.dx_register_index + offset] = {
                  .view = descriptor.resource_view,
                  .table = table,
                  .heap = heap,
                  .layout_param = layout_param,
                  .range_index = range_index,
                  .binding = range.binding + offset,
                  .heap_index = heap_index,
              };
            }
          }
        }
      });

  return result;
}

inline uint32_t ScoreSrvMapping(
    reshade::api::device* device,
    const std::array<TrackedSrv, kTrackedSrvCount>& srvs,
    uint32_t target_width,
    uint32_t target_height) {
  uint32_t score = 0u;
  for (const auto& srv : srvs) {
    if (srv.view.handle != 0u) ++score;
  }

  if (srvs[0].view.handle != 0u) {
    const auto resource = renodx::utils::resource::GetResourceFromView(device, srvs[0].view);
    if (resource.handle != 0u) {
      const auto desc = renodx::utils::resource::GetResourceDesc(device, resource);
      if (desc.texture.width == target_width && desc.texture.height == target_height) {
        score += kTrackedSrvCount;
      }
    }
  }
  return score;
}

inline void AppendView(
    std::stringstream& s,
    reshade::api::device* device,
    const char* label,
    reshade::api::resource_view view) {
  s << "\n  " << label << " native_view=0x" << std::hex << view.handle << std::dec;
  if (device == nullptr || view.handle == 0u) return;

  const auto resource = renodx::utils::resource::GetResourceFromView(device, view);
  s << " native_resource=0x" << std::hex << resource.handle << std::dec;
  if (resource.handle == 0u) return;

  const auto desc = renodx::utils::resource::GetResourceDesc(device, resource);
  const auto view_desc = renodx::utils::resource::GetResourceViewDesc(device, view);
  s << " size=" << desc.texture.width << "x" << desc.texture.height
    << " resource_format=" << static_cast<uint32_t>(desc.texture.format)
    << " view_format=" << static_cast<uint32_t>(view_desc.format)
    << " usage=0x" << std::hex << static_cast<uint32_t>(desc.usage) << std::dec;
}

inline void AppendViewportState(
    std::stringstream& s,
    const renodx::utils::state::CommandListState& state) {
  s << "\n  viewports=" << state.viewports.size();
  for (uint32_t i = 0u; i < state.viewports.size(); ++i) {
    const auto& viewport = state.viewports[i];
    s << " [" << i << ": x=" << viewport.x
      << " y=" << viewport.y
      << " w=" << viewport.width
      << " h=" << viewport.height
      << " min_depth=" << viewport.min_depth
      << " max_depth=" << viewport.max_depth << "]";
  }

  s << "\n  scissors=" << state.scissor_rects.size();
  for (uint32_t i = 0u; i < state.scissor_rects.size(); ++i) {
    const auto& rect = state.scissor_rects[i];
    s << " [" << i << ": " << rect.left << "," << rect.top
      << " -> " << rect.right << "," << rect.bottom << "]";
  }
}

inline void LogPostProcessDraw(uint32_t shader_hash, reshade::api::command_list* cmd_list) {
  std::scoped_lock lock(burst_mutex);

  if (enabled == 0.f) {
    was_enabled = false;
    burst_active = false;
    burst_draw_count = 0u;
    return;
  }

  const uint64_t current_frame = frame_index.load();
  if (!was_enabled) {
    was_enabled = true;
    burst_active = true;
    burst_start_frame = current_frame;
    burst_draw_count = 0u;
    reshade::log::message(
        reshade::log::level::info,
        "LORWIN DLAA probe: starting passive 8-frame postprocess resource capture.");
  }
  if (!burst_active) return;

  if (current_frame - burst_start_frame >= kBurstFrameCount || burst_draw_count >= kBurstDrawLimit) {
    burst_active = false;
    reshade::log::message(
        reshade::log::level::info,
        "LORWIN DLAA probe: passive capture complete; toggle Resource Logging off and on to capture again.");
    return;
  }

  auto* device = cmd_list != nullptr ? cmd_list->get_device() : nullptr;
  auto* state = cmd_list != nullptr ? renodx::utils::state::GetCurrentState(cmd_list) : nullptr;
  if (device == nullptr || state == nullptr || state->render_targets.empty()) return;

  const auto target = renodx::utils::resource::GetResourceFromView(device, state->render_targets[0]);
  if (target.handle == 0u) return;
  const auto target_desc = renodx::utils::resource::GetResourceDesc(device, target);

  const auto binding_srvs = ReadPixelSrvs(cmd_list, false);
  const auto relative_srvs = ReadPixelSrvs(cmd_list, true);
  const bool use_relative_mapping = ScoreSrvMapping(
                                        device,
                                        relative_srvs,
                                        target_desc.texture.width,
                                        target_desc.texture.height)
                                    > ScoreSrvMapping(
                                        device,
                                        binding_srvs,
                                        target_desc.texture.width,
                                        target_desc.texture.height);
  const auto& srvs = use_relative_mapping ? relative_srvs : binding_srvs;

  std::stringstream s;
  s << "LORWIN DLAA probe: frame=" << current_frame
    << " draw=" << (burst_draw_count + 1u)
    << " shader=0x" << std::hex << shader_hash << std::dec
    << " srv_mapping=" << (use_relative_mapping ? "table_relative" : "range_binding")
    << " graphics_layout=0x" << std::hex << state->graphics_pipeline_layout.handle << std::dec
    << " bound_tables=" << state->graphics_descriptor_tables.size();

  for (uint32_t i = 0u; i < srvs.size(); ++i) {
    std::stringstream label;
    label << "t" << i << " " << kSrvNames[i];
    AppendView(s, device, label.str().c_str(), srvs[i].view);
    if (srvs[i].view.handle != 0u) {
      s << " table_param=" << srvs[i].layout_param
        << " range=" << srvs[i].range_index
        << " binding=" << srvs[i].binding
        << " table=0x" << std::hex << srvs[i].table.handle
        << " heap=0x" << srvs[i].heap.handle << std::dec
        << " heap_index=" << srvs[i].heap_index;
    }
  }

  for (uint32_t i = 0u; i < state->render_targets.size(); ++i) {
    std::stringstream label;
    label << "rtv" << i;
    AppendView(s, device, label.str().c_str(), state->render_targets[i]);
  }
  AppendViewportState(s, *state);

  reshade::log::message(reshade::log::level::info, s.str().c_str());
  ++burst_draw_count;
}

inline void InstallCallbacks(renodx::mods::shader::CustomShaders& shaders) {
  if (installed_callbacks) return;

  for (const uint32_t shader_hash : kPostProcessShaders) {
    const auto shader = shaders.find(shader_hash);
    if (shader == shaders.end()) continue;

    const auto previous_on_draw = shader->second.on_draw;
    shader->second.on_draw = [shader_hash, previous_on_draw](reshade::api::command_list* cmd_list) {
      LogPostProcessDraw(shader_hash, cmd_list);
      return previous_on_draw == nullptr || previous_on_draw(cmd_list);
    };
  }
  installed_callbacks = true;
}

inline void OnPresent(
    reshade::api::command_queue*,
    reshade::api::swapchain*,
    const reshade::api::rect*,
    const reshade::api::rect*,
    uint32_t,
    const reshade::api::rect*) {
  ++frame_index;
}

inline void Use(DWORD fdw_reason) {
  renodx::utils::descriptor::trace_descriptor_tables = true;
  renodx::utils::descriptor::Use(fdw_reason);
  renodx::utils::pipeline_layout::Use(fdw_reason);
  renodx::utils::resource::Use(fdw_reason);
  renodx::utils::state::Use(fdw_reason);

  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!installed_events) {
        installed_events = true;
        reshade::register_event<reshade::addon_event::present>(OnPresent);
      }
      break;
    case DLL_PROCESS_DETACH:
      if (installed_events) {
        installed_events = false;
        reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      }
      break;
  }
}

}  // namespace lorwin::resource_logger
