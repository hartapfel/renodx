/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <array>
#include <atomic>
#include <cmath>
#include <cstdint>
#include <limits>
#include <mutex>
#include <set>
#include <sstream>
#include <unordered_map>
#include <vector>

#include <Windows.h>
#include <include/reshade.hpp>

#include "../../utils/data.hpp"
#include "../../utils/resource.hpp"
#include "../../utils/shader.hpp"
#include "../../utils/state.hpp"
#include "resource_logger.hpp"

namespace lorwin::jitter {

// Applying a pixel offset to the viewport is equivalent to applying
// {2 * x / width, -2 * y / height} in NDC. This gives the camera a real
// sub-pixel jitter without reading or modifying the game's constant buffers.
inline float pattern = 0.f;
inline const float* dlaa_enabled_binding = nullptr;

struct __declspec(uuid("7f40fd89-fac0-44b8-b1e8-3609d82d1da5")) CommandListData {
  std::vector<reshade::api::viewport> base_viewports;
  std::array<float, 2> applied_pixel_jitter = {};
  uint64_t applied_frame = std::numeric_limits<uint64_t>::max();
  bool jitter_applied = false;
  bool internal_viewport_bind = false;
};

struct Diagnostics {
  std::atomic<uint64_t> draws = 0u;
  std::atomic<uint64_t> missing_render_size = 0u;
  std::atomic<uint64_t> missing_state = 0u;
  std::atomic<uint64_t> missing_viewport = 0u;
  std::atomic<uint64_t> viewport_size_mismatch = 0u;
  std::atomic<uint64_t> missing_depth = 0u;
  std::atomic<uint64_t> depth_size_mismatch = 0u;
  std::atomic<uint64_t> main_depth_unknown = 0u;
  std::atomic<uint64_t> main_depth_mismatch = 0u;
  std::atomic<uint64_t> eligible_draws = 0u;
  std::atomic<uint64_t> viewport_jitter_binds = 0u;
  std::atomic<uint64_t> viewport_restores = 0u;
};

inline Diagnostics diagnostics;
inline std::mutex probe_mutex;
inline std::set<uint32_t> logged_vertex_shaders;
inline reshade::api::swapchain* tracked_swapchain = nullptr;
inline uint32_t render_width = 0u;
inline uint32_t render_height = 0u;
inline std::atomic<uint64_t> postprocess_depth_resource = 0u;
inline std::atomic<uint64_t> main_scene_depth_resource = 0u;
inline std::atomic<uint64_t> last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
inline std::mutex depth_lineage_mutex;
inline std::unordered_map<uint64_t, uint64_t> depth_copy_sources;
inline std::atomic<uint64_t> probe_start_frame = std::numeric_limits<uint64_t>::max();
inline std::atomic<int> last_logged_pattern = -1;
inline std::atomic<bool> diagnostics_logged = false;
inline bool installed_events = false;

inline std::array<float, 2> Halton8(uint64_t frame_index) {
  const uint32_t index = static_cast<uint32_t>(frame_index % 8u) + 1u;
  const auto radical_inverse = [](uint32_t value, uint32_t base) {
    float result = 0.f;
    float fraction = 1.f / static_cast<float>(base);
    while (value != 0u) {
      result += static_cast<float>(value % base) * fraction;
      value /= base;
      fraction /= static_cast<float>(base);
    }
    return result;
  };
  return {
      radical_inverse(index, 2u) - 0.5f,
      radical_inverse(index, 3u) - 0.5f,
  };
}

inline std::array<float, 2> FourQuadrant(uint64_t frame_index) {
  static constexpr std::array<std::array<float, 2>, 4> kPattern = {{
      {0.25f, -0.25f},
      {-0.25f, 0.25f},
      {0.25f, 0.25f},
      {-0.25f, -0.25f},
  }};
  return kPattern[frame_index % kPattern.size()];
}

inline int GetSelectedPattern() {
  const int selected = static_cast<int>(std::round(pattern));
  if (selected == 3) return 0;
  if (selected == 0 && dlaa_enabled_binding != nullptr && *dlaa_enabled_binding != 0.f) return 1;
  return selected;
}

inline void SetDlaaEnabledBinding(const float* binding) {
  dlaa_enabled_binding = binding;
}

inline std::array<float, 2> GetPixelJitter() {
  const uint64_t frame_index = resource_logger::frame_index.load();
  switch (GetSelectedPattern()) {
    case 1:
      return Halton8(frame_index);
    case 2:
      return FourQuadrant(frame_index);
    default:
      return {0.f, 0.f};
  }
}

inline bool WasMainSceneJitteredThisFrame() {
  return last_scene_jitter_frame.load() == resource_logger::frame_index.load();
}

inline std::array<float, 2> GetEvaluationPixelJitter() {
  return WasMainSceneJitteredThisFrame() ? GetPixelJitter() : std::array<float, 2>{0.f, 0.f};
}

inline uint64_t ResolveDepthCopySourceLocked(uint64_t resource) {
  for (uint32_t i = 0u; i < 16u; ++i) {
    const auto pair = depth_copy_sources.find(resource);
    if (pair == depth_copy_sources.end() || pair->second == 0u || pair->second == resource) break;
    resource = pair->second;
  }
  return resource;
}

inline void SetPostprocessDepthResource(reshade::api::resource resource) {
  if (resource.handle == 0u) return;
  const uint64_t previous = postprocess_depth_resource.exchange(resource.handle);
  if (previous == resource.handle) return;

  uint64_t source = resource.handle;
  {
    std::scoped_lock lock(depth_lineage_mutex);
    source = ResolveDepthCopySourceLocked(resource.handle);
  }
  main_scene_depth_resource = source == resource.handle ? 0u : source;
  last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
  std::stringstream s;
  s << "LORWIN DLAA jitter: tracking postprocess depth resource=0x" << std::hex << resource.handle;
  if (source != resource.handle) s << " exact source DSV=0x" << source;
  else s << " exact source DSV unresolved (direct binding remains eligible)";
  reshade::log::message(reshade::log::level::info, s.str().c_str());
}

inline void RecordDepthCopy(
    reshade::api::resource source,
    reshade::api::resource dest,
    const char* operation) {
  if (source.handle == 0u || dest.handle == 0u) return;

  uint64_t resolved_source = 0u;
  {
    std::scoped_lock lock(depth_lineage_mutex);
    depth_copy_sources[dest.handle] = source.handle;
    const uint64_t postprocess_depth = postprocess_depth_resource.load();
    if (postprocess_depth != 0u) resolved_source = ResolveDepthCopySourceLocked(postprocess_depth);
  }

  const uint64_t postprocess_depth = postprocess_depth_resource.load();
  if (postprocess_depth == 0u || resolved_source == 0u || resolved_source == postprocess_depth) return;
  const uint64_t previous = main_scene_depth_resource.exchange(resolved_source);
  if (previous == resolved_source) return;

  last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
  std::stringstream s;
  s << "LORWIN DLAA jitter: resolved exact main-scene depth source=0x" << std::hex << resolved_source
    << " -> postprocess depth=0x" << postprocess_depth << " via " << operation;
  reshade::log::message(reshade::log::level::info, s.str().c_str());
}

inline void ForgetDepthResource(reshade::api::resource resource) {
  uint64_t expected = resource.handle;
  postprocess_depth_resource.compare_exchange_strong(expected, 0u);
  expected = resource.handle;
  if (expected != 0u && main_scene_depth_resource.compare_exchange_strong(expected, 0u)) {
    last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
  }
  std::scoped_lock lock(depth_lineage_mutex);
  depth_copy_sources.erase(resource.handle);
  for (auto it = depth_copy_sources.begin(); it != depth_copy_sources.end();) {
    if (it->second == resource.handle) it = depth_copy_sources.erase(it);
    else ++it;
  }
}

inline std::array<float, 2> GetProjectionJitter() {
  if (render_width == 0u || render_height == 0u) return {0.f, 0.f};
  const auto pixel_jitter = GetPixelJitter();
  return {
      pixel_jitter[0] * 2.f / static_cast<float>(render_width),
      -pixel_jitter[1] * 2.f / static_cast<float>(render_height),
  };
}

inline void ResetDiagnostics() {
  diagnostics.draws = 0u;
  diagnostics.missing_render_size = 0u;
  diagnostics.missing_state = 0u;
  diagnostics.missing_viewport = 0u;
  diagnostics.viewport_size_mismatch = 0u;
  diagnostics.missing_depth = 0u;
  diagnostics.depth_size_mismatch = 0u;
  diagnostics.main_depth_unknown = 0u;
  diagnostics.main_depth_mismatch = 0u;
  diagnostics.eligible_draws = 0u;
  diagnostics.viewport_jitter_binds = 0u;
  diagnostics.viewport_restores = 0u;
  diagnostics_logged = false;
  std::scoped_lock lock(probe_mutex);
  logged_vertex_shaders.clear();
}

inline bool IsFullResolutionSceneDraw(reshade::api::command_list* cmd_list) {
  ++diagnostics.draws;
  if (cmd_list == nullptr || render_width == 0u || render_height == 0u) {
    ++diagnostics.missing_render_size;
    return false;
  }

  auto* device = cmd_list->get_device();
  const auto* state = renodx::utils::state::GetCurrentState(cmd_list);
  if (device == nullptr || state == nullptr) {
    ++diagnostics.missing_state;
    return false;
  }
  if (state->viewports.empty()) {
    ++diagnostics.missing_viewport;
    return false;
  }

  const auto& viewport = state->viewports[0];
  if (std::abs(viewport.width - static_cast<float>(render_width)) >= 0.5f
      || std::abs(viewport.height - static_cast<float>(render_height)) >= 0.5f) {
    ++diagnostics.viewport_size_mismatch;
    return false;
  }
  if (state->depth_stencil.handle == 0u) {
    ++diagnostics.missing_depth;
    return false;
  }

  const auto depth = renodx::utils::resource::GetResourceFromView(device, state->depth_stencil);
  if (depth.handle == 0u) {
    ++diagnostics.missing_depth;
    return false;
  }
  const auto depth_desc = renodx::utils::resource::GetResourceDesc(device, depth);
  if (depth_desc.texture.width != render_width || depth_desc.texture.height != render_height) {
    ++diagnostics.depth_size_mismatch;
    return false;
  }
  const uint64_t postprocess_depth = postprocess_depth_resource.load();
  const uint64_t expected_depth = main_scene_depth_resource.load();
  if (postprocess_depth == 0u) {
    ++diagnostics.main_depth_unknown;
    return false;
  }
  if (depth.handle != postprocess_depth && depth.handle != expected_depth) {
    ++diagnostics.main_depth_mismatch;
    return false;
  }

  ++diagnostics.eligible_draws;
  return true;
}

inline void LogDiagnostics(uint64_t frame_index) {
  const auto start_frame = probe_start_frame.load();
  bool expected = false;
  if (start_frame == std::numeric_limits<uint64_t>::max()
      || frame_index - start_frame < 60u
      || !diagnostics_logged.compare_exchange_strong(expected, true)) {
    return;
  }

  size_t unique_vertex_shaders = 0u;
  {
    std::scoped_lock lock(probe_mutex);
    unique_vertex_shaders = logged_vertex_shaders.size();
  }
  std::stringstream s;
  s << "LORWIN DLAA jitter probe: 60-frame diagnostics"
    << " draws=" << diagnostics.draws.exchange(0u)
    << " no_render_size=" << diagnostics.missing_render_size.exchange(0u)
    << " no_state=" << diagnostics.missing_state.exchange(0u)
    << " no_viewport=" << diagnostics.missing_viewport.exchange(0u)
    << " viewport_mismatch=" << diagnostics.viewport_size_mismatch.exchange(0u)
    << " no_depth=" << diagnostics.missing_depth.exchange(0u)
    << " depth_mismatch=" << diagnostics.depth_size_mismatch.exchange(0u)
    << " main_depth_unknown=" << diagnostics.main_depth_unknown.exchange(0u)
    << " main_depth_mismatch=" << diagnostics.main_depth_mismatch.exchange(0u)
    << " eligible=" << diagnostics.eligible_draws.exchange(0u)
    << " jitter_binds=" << diagnostics.viewport_jitter_binds.exchange(0u)
    << " viewport_restores=" << diagnostics.viewport_restores.exchange(0u)
    << " unique_vertex_shaders=" << unique_vertex_shaders;
  reshade::log::message(reshade::log::level::info, s.str().c_str());
}

inline void BindBaseViewports(reshade::api::command_list* cmd_list, CommandListData* data) {
  if (cmd_list == nullptr || data == nullptr || data->base_viewports.empty() || !data->jitter_applied) return;
  data->internal_viewport_bind = true;
  cmd_list->bind_viewports(0u, static_cast<uint32_t>(data->base_viewports.size()), data->base_viewports.data());
  data->internal_viewport_bind = false;
  data->jitter_applied = false;
  data->applied_frame = std::numeric_limits<uint64_t>::max();
  ++diagnostics.viewport_restores;
}

inline void BindJitteredViewports(
    reshade::api::command_list* cmd_list,
    CommandListData* data,
    uint64_t frame_index,
    const std::array<float, 2>& pixel_jitter) {
  if (cmd_list == nullptr || data == nullptr || data->base_viewports.empty()) return;

  if (data->jitter_applied
      && data->applied_frame == frame_index
      && data->applied_pixel_jitter == pixel_jitter) {
    return;
  }

  auto jittered_viewports = data->base_viewports;
  for (auto& viewport : jittered_viewports) {
    viewport.x += pixel_jitter[0];
    viewport.y += pixel_jitter[1];
  }

  data->internal_viewport_bind = true;
  cmd_list->bind_viewports(0u, static_cast<uint32_t>(jittered_viewports.size()), jittered_viewports.data());
  data->internal_viewport_bind = false;
  data->applied_pixel_jitter = pixel_jitter;
  data->applied_frame = frame_index;
  data->jitter_applied = true;
  last_scene_jitter_frame = frame_index;
  ++diagnostics.viewport_jitter_binds;
}

inline void ApplyCameraJitter(reshade::api::command_list* cmd_list) {
  auto* command_list_data = renodx::utils::data::Get<CommandListData>(cmd_list);
  const int selected_pattern = GetSelectedPattern();
  if (selected_pattern == 0) {
    BindBaseViewports(cmd_list, command_list_data);
    const int logged_pattern = static_cast<int>(std::round(pattern)) == 3 ? 3 : 0;
    if (last_logged_pattern.exchange(logged_pattern) != logged_pattern && logged_pattern == 3) {
      reshade::log::message(
          reshade::log::level::info,
          "LORWIN DLAA jitter: FORCED OFF; viewport and NGX jitter are both zero.");
    }
    return;
  }

  const uint64_t frame_index = resource_logger::frame_index.load();
  if (last_logged_pattern.exchange(selected_pattern) != selected_pattern) {
    ResetDiagnostics();
    probe_start_frame = frame_index;
    const auto pixel_jitter = GetPixelJitter();
    const auto projection_jitter = GetProjectionJitter();
    std::stringstream s;
    s << "LORWIN DLAA jitter: ACTIVE viewport pattern="
      << (selected_pattern == 1 ? "Halton8" : "FourQuadrant")
      << " render_size=" << render_width << "x" << render_height
      << " pixel=(" << pixel_jitter[0] << ", " << pixel_jitter[1] << ")"
      << " projection=(" << projection_jitter[0] << ", " << projection_jitter[1] << ")"
      << "; game constant-buffer memory is not read or modified.";
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }

  if (!IsFullResolutionSceneDraw(cmd_list)) {
    BindBaseViewports(cmd_list, command_list_data);
    LogDiagnostics(frame_index);
    return;
  }

  BindJitteredViewports(cmd_list, command_list_data, frame_index, GetPixelJitter());

  uint32_t vertex_shader_hash = 0u;
  if (auto* shader_data = renodx::utils::data::Get<renodx::utils::shader::CommandListData>(cmd_list)) {
    vertex_shader_hash = renodx::utils::shader::GetCurrentVertexShaderHash(shader_data);
  }

  bool should_log = false;
  {
    std::scoped_lock lock(probe_mutex);
    if (logged_vertex_shaders.size() < 64u) {
      should_log = logged_vertex_shaders.insert(vertex_shader_hash).second;
    }
  }
  if (should_log) {
    const auto* state = renodx::utils::state::GetCurrentState(cmd_list);
    std::stringstream s;
    s << "LORWIN DLAA jitter probe: eligible vertex_shader=0x" << std::hex << vertex_shader_hash
      << " graphics_layout=0x" << (state != nullptr ? state->graphics_pipeline_layout.handle : 0u)
      << std::dec << " render_size=" << render_width << "x" << render_height;
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }
  LogDiagnostics(frame_index);
}

inline bool OnDraw(reshade::api::command_list* cmd_list, uint32_t, uint32_t, uint32_t, uint32_t) {
  ApplyCameraJitter(cmd_list);
  return false;
}

inline bool OnDrawIndexed(reshade::api::command_list* cmd_list, uint32_t, uint32_t, uint32_t, int32_t, uint32_t) {
  ApplyCameraJitter(cmd_list);
  return false;
}

inline bool OnCopyResource(
    reshade::api::command_list*,
    reshade::api::resource source,
    reshade::api::resource dest) {
  RecordDepthCopy(source, dest, "copy_resource");
  return false;
}

inline bool OnCopyTextureRegion(
    reshade::api::command_list*,
    reshade::api::resource source,
    uint32_t,
    const reshade::api::subresource_box*,
    reshade::api::resource dest,
    uint32_t,
    const reshade::api::subresource_box*,
    reshade::api::filter_mode) {
  RecordDepthCopy(source, dest, "copy_texture_region");
  return false;
}

inline bool OnResolveTextureRegion(
    reshade::api::command_list*,
    reshade::api::resource source,
    uint32_t,
    const reshade::api::subresource_box*,
    reshade::api::resource dest,
    uint32_t,
    uint32_t,
    uint32_t,
    uint32_t,
    reshade::api::format) {
  RecordDepthCopy(source, dest, "resolve_texture_region");
  return false;
}

inline void OnInitCommandList(reshade::api::command_list* cmd_list) {
  renodx::utils::data::Create<CommandListData>(cmd_list);
}

inline void OnResetCommandList(reshade::api::command_list* cmd_list) {
  auto* data = renodx::utils::data::Get<CommandListData>(cmd_list);
  if (data == nullptr) return;
  data->base_viewports.clear();
  data->applied_pixel_jitter = {};
  data->applied_frame = std::numeric_limits<uint64_t>::max();
  data->jitter_applied = false;
  data->internal_viewport_bind = false;
}

inline void OnDestroyCommandList(reshade::api::command_list* cmd_list) {
  renodx::utils::data::Delete<CommandListData>(cmd_list);
}

inline void OnBindViewports(
    reshade::api::command_list* cmd_list,
    uint32_t first,
    uint32_t count,
    const reshade::api::viewport* viewports) {
  auto* data = renodx::utils::data::Get<CommandListData>(cmd_list);
  if (data == nullptr || data->internal_viewport_bind || viewports == nullptr) return;

  if (first == 0u) {
    data->base_viewports.assign(viewports, viewports + count);
  } else {
    const size_t required_size = static_cast<size_t>(first) + count;
    if (data->base_viewports.size() < required_size) data->base_viewports.resize(required_size);
    for (uint32_t i = 0u; i < count; ++i) {
      data->base_viewports[first + i] = viewports[i];
    }
  }
  data->jitter_applied = false;
}

inline void OnInitSwapchain(reshade::api::swapchain* swapchain, bool) {
  if (swapchain == nullptr) return;
  auto* device = swapchain->get_device();
  if (device == nullptr) return;
  const auto back_buffer = swapchain->get_back_buffer(0u);
  if (back_buffer.handle == 0u) return;
  const auto desc = device->get_resource_desc(back_buffer);
  if (tracked_swapchain != nullptr
      && tracked_swapchain != swapchain
      && static_cast<uint64_t>(desc.texture.width) * desc.texture.height
             < static_cast<uint64_t>(render_width) * render_height) {
    return;
  }

  const bool size_changed = render_width != desc.texture.width || render_height != desc.texture.height;
  tracked_swapchain = swapchain;
  render_width = desc.texture.width;
  render_height = desc.texture.height;
  if (size_changed) {
    postprocess_depth_resource = 0u;
    main_scene_depth_resource = 0u;
    last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
    {
      std::scoped_lock lock(depth_lineage_mutex);
      depth_copy_sources.clear();
    }
    std::stringstream s;
    s << "LORWIN DLAA jitter probe: tracking primary swapchain render_size="
      << render_width << "x" << render_height;
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }
}

inline void OnDestroySwapchain(reshade::api::swapchain* swapchain, bool resize) {
  if (swapchain != tracked_swapchain) return;
  postprocess_depth_resource = 0u;
  main_scene_depth_resource = 0u;
  last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
  {
    std::scoped_lock lock(depth_lineage_mutex);
    depth_copy_sources.clear();
  }
  if (resize) return;
  tracked_swapchain = nullptr;
  render_width = 0u;
  render_height = 0u;
}

inline void Use(DWORD fdw_reason) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!installed_events) {
        installed_events = true;
        reshade::register_event<reshade::addon_event::init_command_list>(OnInitCommandList);
        reshade::register_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
        reshade::register_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
        reshade::register_event<reshade::addon_event::bind_viewports>(OnBindViewports);
        reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
        reshade::register_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
        reshade::register_event<reshade::addon_event::draw>(OnDraw);
        reshade::register_event<reshade::addon_event::draw_indexed>(OnDrawIndexed);
        reshade::register_event<reshade::addon_event::copy_resource>(OnCopyResource);
        reshade::register_event<reshade::addon_event::copy_texture_region>(OnCopyTextureRegion);
        reshade::register_event<reshade::addon_event::resolve_texture_region>(OnResolveTextureRegion);
      }
      break;
    case DLL_PROCESS_DETACH:
      if (installed_events) {
        installed_events = false;
        reshade::unregister_event<reshade::addon_event::init_command_list>(OnInitCommandList);
        reshade::unregister_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
        reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
        reshade::unregister_event<reshade::addon_event::bind_viewports>(OnBindViewports);
        reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
        reshade::unregister_event<reshade::addon_event::destroy_swapchain>(OnDestroySwapchain);
        reshade::unregister_event<reshade::addon_event::draw>(OnDraw);
        reshade::unregister_event<reshade::addon_event::draw_indexed>(OnDrawIndexed);
        reshade::unregister_event<reshade::addon_event::copy_resource>(OnCopyResource);
        reshade::unregister_event<reshade::addon_event::copy_texture_region>(OnCopyTextureRegion);
        reshade::unregister_event<reshade::addon_event::resolve_texture_region>(OnResolveTextureRegion);
      }
      break;
  }
}

}  // namespace lorwin::jitter
