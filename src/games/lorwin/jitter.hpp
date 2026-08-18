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
#include <string>
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
inline float camera_jitter_scale = 1.f;
inline const float* dlaa_enabled_binding = nullptr;

// These shaders generate fullscreen post-process triangles. Their outputs may
// contribute to the scene-color lineage, but moving their viewport does not
// jitter the camera projection; it shifts an already-rendered image instead.
inline constexpr uint32_t kPostProcessPosUvVertexShader = 0x8806E17Au;
inline constexpr uint32_t kPostProcessPosUvVpVertexShader = 0xCD04EF41u;

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
  std::atomic<uint64_t> scene_color_unknown = 0u;
  std::atomic<uint64_t> scene_color_mismatch = 0u;
  std::atomic<uint64_t> scene_color_missing_depth = 0u;
  std::atomic<uint64_t> excluded_postprocess_draws = 0u;
  std::atomic<uint64_t> depth_eligible_draws = 0u;
  std::atomic<uint64_t> scene_color_eligible_draws = 0u;
  std::atomic<uint64_t> eligible_draws = 0u;
  std::atomic<uint64_t> viewport_jitter_binds = 0u;
  std::atomic<uint64_t> viewport_restores = 0u;
};

struct CoverageDiagnostics {
  std::atomic<uint64_t> observed_draws = 0u;
  std::atomic<uint64_t> contributor_draws = 0u;
  std::atomic<uint64_t> jittered_contributor_draws = 0u;
  std::atomic<uint64_t> exact_depth_contributor_draws = 0u;
  std::atomic<uint64_t> scene_color_fallback_draws = 0u;
  std::atomic<uint64_t> excluded_postprocess_draws = 0u;
  std::atomic<uint64_t> missed_pattern_off = 0u;
  std::atomic<uint64_t> missed_zero_jitter = 0u;
  std::atomic<uint64_t> missed_no_state = 0u;
  std::atomic<uint64_t> missed_no_viewport = 0u;
  std::atomic<uint64_t> missed_viewport_size = 0u;
  std::atomic<uint64_t> missed_no_depth = 0u;
  std::atomic<uint64_t> missed_depth_size = 0u;
  std::atomic<uint64_t> missed_untracked_depth = 0u;
  std::atomic<uint64_t> missed_indirect_draw = 0u;
  std::atomic<uint64_t> depth_only_draws = 0u;
  std::atomic<uint64_t> excluded_non_scene_depth_draws = 0u;
  std::atomic<uint64_t> scene_color_clears = 0u;
  std::atomic<uint64_t> scene_color_transfers = 0u;
};

inline Diagnostics diagnostics;
inline CoverageDiagnostics coverage_diagnostics;
inline std::mutex probe_mutex;
inline std::set<uint32_t> logged_vertex_shaders;
inline std::set<uint32_t> logged_scene_color_vertex_shaders;
inline std::mutex coverage_mutex;
inline std::set<std::string> logged_contributor_passes;
inline std::set<std::string> logged_depth_only_passes;
inline std::set<std::string> logged_scene_operations;
inline reshade::api::swapchain* tracked_swapchain = nullptr;
inline uint32_t render_width = 0u;
inline uint32_t render_height = 0u;
inline std::atomic<uint64_t> postprocess_depth_resource = 0u;
inline std::atomic<uint64_t> main_scene_depth_resource = 0u;
inline std::atomic<uint64_t> postprocess_scene_color_resource = 0u;
inline std::atomic<uint64_t> main_scene_color_resource = 0u;
inline std::atomic<uint64_t> last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
inline std::mutex resource_lineage_mutex;
inline std::unordered_map<uint64_t, uint64_t> resource_copy_sources;
inline std::atomic<uint64_t> probe_start_frame = std::numeric_limits<uint64_t>::max();
inline std::atomic<int> last_logged_pattern = -1;
inline std::atomic<bool> diagnostics_logged = false;
inline std::atomic<uint64_t> coverage_start_frame = std::numeric_limits<uint64_t>::max();
inline std::atomic<bool> coverage_capture_active = false;
inline std::atomic<bool> coverage_summary_logged = false;
inline bool installed_events = false;

inline void StartCoverageCapture();
inline void RecordSceneColorTransfer(
    reshade::api::resource source,
    reshade::api::resource dest,
    const char* operation);

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

inline bool IsFullscreenPostProcessVertexShader(uint32_t shader_hash) {
  return shader_hash == kPostProcessPosUvVertexShader
         || shader_hash == kPostProcessPosUvVpVertexShader;
}

inline std::array<float, 2> GetPixelJitter() {
  const uint64_t frame_index = resource_logger::frame_index.load();
  std::array<float, 2> pixel_jitter = {};
  switch (GetSelectedPattern()) {
    case 1:
      pixel_jitter = Halton8(frame_index);
      break;
    case 2:
      pixel_jitter = FourQuadrant(frame_index);
      break;
    default:
      return {0.f, 0.f};
  }
  const float scale = std::clamp(camera_jitter_scale, 0.f, 200.f);
  return {pixel_jitter[0] * scale, pixel_jitter[1] * scale};
}

inline bool WasMainSceneJitteredThisFrame() {
  return last_scene_jitter_frame.load() == resource_logger::frame_index.load();
}

inline reshade::api::viewport GetActiveViewport(
    reshade::api::command_list* cmd_list,
    uint32_t index,
    const reshade::api::viewport& fallback) {
  const auto* data = cmd_list != nullptr
                         ? renodx::utils::data::Get<CommandListData>(cmd_list)
                         : nullptr;
  if (data == nullptr || index >= data->base_viewports.size()) return fallback;

  auto viewport = data->base_viewports[index];
  if (data->jitter_applied) {
    viewport.x += data->applied_pixel_jitter[0];
    viewport.y += data->applied_pixel_jitter[1];
  }
  return viewport;
}

inline std::array<float, 2> GetEvaluationPixelJitter() {
  return WasMainSceneJitteredThisFrame() ? GetPixelJitter() : std::array<float, 2>{0.f, 0.f};
}

inline bool IsTrackedSceneDepth(reshade::api::command_list* cmd_list) {
  auto* device = cmd_list != nullptr ? cmd_list->get_device() : nullptr;
  const auto* state = cmd_list != nullptr ? renodx::utils::state::GetCurrentState(cmd_list) : nullptr;
  if (device == nullptr || state == nullptr || state->depth_stencil.handle == 0u) return false;

  const auto depth = renodx::utils::resource::GetResourceFromView(device, state->depth_stencil);
  if (depth.handle == 0u) return false;
  const uint64_t postprocess_depth = postprocess_depth_resource.load();
  const uint64_t main_depth = main_scene_depth_resource.load();
  return depth.handle == postprocess_depth || (main_depth != 0u && depth.handle == main_depth);
}

inline uint64_t ResolveCopySourceLocked(uint64_t resource) {
  for (uint32_t i = 0u; i < 16u; ++i) {
    const auto pair = resource_copy_sources.find(resource);
    if (pair == resource_copy_sources.end() || pair->second == 0u || pair->second == resource) break;
    resource = pair->second;
  }
  return resource;
}

enum class SceneColorLineageRole {
  kNone,
  kPostprocessInput,
  kTransferSource,
};

inline SceneColorLineageRole GetSceneColorLineageRole(uint64_t resource) {
  const uint64_t postprocess_color = postprocess_scene_color_resource.load();
  if (resource == 0u || postprocess_color == 0u) return SceneColorLineageRole::kNone;
  if (resource == postprocess_color) return SceneColorLineageRole::kPostprocessInput;

  std::scoped_lock lock(resource_lineage_mutex);
  uint64_t current = postprocess_color;
  for (uint32_t i = 0u; i < 16u; ++i) {
    const auto pair = resource_copy_sources.find(current);
    if (pair == resource_copy_sources.end() || pair->second == 0u || pair->second == current) break;
    current = pair->second;
    if (current == resource) return SceneColorLineageRole::kTransferSource;
  }
  return SceneColorLineageRole::kNone;
}

inline void SetPostprocessDepthResource(reshade::api::resource resource) {
  if (resource.handle == 0u) return;
  const uint64_t previous = postprocess_depth_resource.exchange(resource.handle);
  if (previous == resource.handle) return;

  uint64_t source = resource.handle;
  {
    std::scoped_lock lock(resource_lineage_mutex);
    source = ResolveCopySourceLocked(resource.handle);
  }
  main_scene_depth_resource = source == resource.handle ? 0u : source;
  last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
  std::stringstream s;
  s << "LORWIN DLAA jitter: tracking postprocess depth resource=0x" << std::hex << resource.handle;
  if (source != resource.handle) s << " exact source DSV=0x" << source;
  else s << " exact source DSV unresolved (direct binding remains eligible)";
  reshade::log::message(reshade::log::level::info, s.str().c_str());
}

inline void SetPostprocessSceneColorResource(reshade::api::resource resource) {
  if (resource.handle == 0u) return;
  const uint64_t previous = postprocess_scene_color_resource.exchange(resource.handle);
  if (previous == resource.handle) return;

  uint64_t source = resource.handle;
  {
    std::scoped_lock lock(resource_lineage_mutex);
    source = ResolveCopySourceLocked(resource.handle);
  }
  main_scene_color_resource = source == resource.handle ? 0u : source;
  last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
  std::stringstream s;
  s << "LORWIN DLAA jitter: tracking postprocess scene color resource=0x" << std::hex << resource.handle;
  if (source != resource.handle) s << " exact source RTV=0x" << source;
  else s << " direct source RTV";
  reshade::log::message(reshade::log::level::info, s.str().c_str());
}

inline void RecordResourceCopy(
    reshade::api::resource source,
    reshade::api::resource dest,
    const char* operation) {
  if (source.handle == 0u || dest.handle == 0u) return;

  uint64_t resolved_source = 0u;
  uint64_t resolved_color_source = 0u;
  {
    std::scoped_lock lock(resource_lineage_mutex);
    resource_copy_sources[dest.handle] = source.handle;
    const uint64_t postprocess_depth = postprocess_depth_resource.load();
    if (postprocess_depth != 0u) resolved_source = ResolveCopySourceLocked(postprocess_depth);
    const uint64_t postprocess_color = postprocess_scene_color_resource.load();
    if (postprocess_color != 0u) resolved_color_source = ResolveCopySourceLocked(postprocess_color);
  }

  bool changed = false;
  const uint64_t postprocess_depth = postprocess_depth_resource.load();
  if (postprocess_depth != 0u && resolved_source != 0u && resolved_source != postprocess_depth) {
    const uint64_t previous = main_scene_depth_resource.exchange(resolved_source);
    if (previous != resolved_source) {
      changed = true;
      std::stringstream s;
      s << "LORWIN DLAA jitter: resolved exact main-scene depth source=0x" << std::hex << resolved_source
        << " -> postprocess depth=0x" << postprocess_depth << " via " << operation;
      reshade::log::message(reshade::log::level::info, s.str().c_str());
    }
  }

  const uint64_t postprocess_color = postprocess_scene_color_resource.load();
  if (postprocess_color != 0u
      && resolved_color_source != 0u
      && resolved_color_source != postprocess_color) {
    const uint64_t previous_color = main_scene_color_resource.exchange(resolved_color_source);
    if (previous_color != resolved_color_source) {
      changed = true;
      std::stringstream color_log;
      color_log << "LORWIN DLAA jitter: resolved exact main-scene color source=0x" << std::hex
                << resolved_color_source << " -> postprocess scene color=0x" << postprocess_color
                << " via " << operation;
      reshade::log::message(reshade::log::level::info, color_log.str().c_str());
    }
  }
  if (changed) last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
  RecordSceneColorTransfer(source, dest, operation);
}

inline void ForgetResource(reshade::api::resource resource) {
  bool forgot_tracked_resource = false;
  uint64_t expected = resource.handle;
  if (postprocess_depth_resource.compare_exchange_strong(expected, 0u)) {
    main_scene_depth_resource = 0u;
    forgot_tracked_resource = true;
  }
  expected = resource.handle;
  if (expected != 0u && main_scene_depth_resource.compare_exchange_strong(expected, 0u)) {
    forgot_tracked_resource = true;
  }
  expected = resource.handle;
  if (postprocess_scene_color_resource.compare_exchange_strong(expected, 0u)) {
    main_scene_color_resource = 0u;
    forgot_tracked_resource = true;
  }
  expected = resource.handle;
  if (expected != 0u && main_scene_color_resource.compare_exchange_strong(expected, 0u)) {
    forgot_tracked_resource = true;
  }
  if (forgot_tracked_resource) last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
  std::scoped_lock lock(resource_lineage_mutex);
  resource_copy_sources.erase(resource.handle);
  for (auto it = resource_copy_sources.begin(); it != resource_copy_sources.end();) {
    if (it->second == resource.handle) it = resource_copy_sources.erase(it);
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
  diagnostics.scene_color_unknown = 0u;
  diagnostics.scene_color_mismatch = 0u;
  diagnostics.scene_color_missing_depth = 0u;
  diagnostics.excluded_postprocess_draws = 0u;
  diagnostics.depth_eligible_draws = 0u;
  diagnostics.scene_color_eligible_draws = 0u;
  diagnostics.eligible_draws = 0u;
  diagnostics.viewport_jitter_binds = 0u;
  diagnostics.viewport_restores = 0u;
  diagnostics_logged = false;
  std::scoped_lock lock(probe_mutex);
  logged_vertex_shaders.clear();
  logged_scene_color_vertex_shaders.clear();
}

inline void ResetCoverageDiagnostics() {
  coverage_diagnostics.observed_draws = 0u;
  coverage_diagnostics.contributor_draws = 0u;
  coverage_diagnostics.jittered_contributor_draws = 0u;
  coverage_diagnostics.exact_depth_contributor_draws = 0u;
  coverage_diagnostics.scene_color_fallback_draws = 0u;
  coverage_diagnostics.excluded_postprocess_draws = 0u;
  coverage_diagnostics.missed_pattern_off = 0u;
  coverage_diagnostics.missed_zero_jitter = 0u;
  coverage_diagnostics.missed_no_state = 0u;
  coverage_diagnostics.missed_no_viewport = 0u;
  coverage_diagnostics.missed_viewport_size = 0u;
  coverage_diagnostics.missed_no_depth = 0u;
  coverage_diagnostics.missed_depth_size = 0u;
  coverage_diagnostics.missed_untracked_depth = 0u;
  coverage_diagnostics.missed_indirect_draw = 0u;
  coverage_diagnostics.depth_only_draws = 0u;
  coverage_diagnostics.excluded_non_scene_depth_draws = 0u;
  coverage_diagnostics.scene_color_clears = 0u;
  coverage_diagnostics.scene_color_transfers = 0u;
  coverage_summary_logged = false;
  std::scoped_lock lock(coverage_mutex);
  logged_contributor_passes.clear();
  logged_depth_only_passes.clear();
  logged_scene_operations.clear();
}

inline void StartCoverageCapture() {
  ResetDiagnostics();
  probe_start_frame = resource_logger::frame_index.load();
  ResetCoverageDiagnostics();
  coverage_start_frame = resource_logger::frame_index.load();
  coverage_capture_active = true;

  std::stringstream s;
  s << "LORWIN DLAA jitter coverage: starting 60-frame scene-contributor capture"
    << " postprocess_scene=0x" << std::hex << postprocess_scene_color_resource.load()
    << " resolved_scene=0x" << main_scene_color_resource.load() << std::dec
    << "; classifying all direct/indexed/indirect graphics draws writing the scene-color lineage,"
       " plus clears and copy/resolve transfers.";
  reshade::log::message(reshade::log::level::info, s.str().c_str());
}

enum class SceneDrawEligibility {
  kIneligible,
  kNonSpatialPostProcess,
  kExactDepth,
  kExactSceneColor,
};

enum class CoverageClassification {
  kExcludedPostProcess,
  kJitteredExactDepth,
  kJitteredSceneColorFallback,
  kJitteredOther,
  kMissedPatternOff,
  kMissedZeroJitter,
  kMissedNoState,
  kMissedNoViewport,
  kMissedViewportSize,
  kMissedNoDepth,
  kMissedDepthSize,
  kMissedUntrackedDepth,
  kMissedIndirectDraw,
};

inline const char* GetCoverageClassificationName(CoverageClassification classification) {
  switch (classification) {
    case CoverageClassification::kExcludedPostProcess:
      return "excluded_postprocess";
    case CoverageClassification::kJitteredExactDepth:
      return "jittered_exact_depth";
    case CoverageClassification::kJitteredSceneColorFallback:
      return "jittered_scene_color_fallback";
    case CoverageClassification::kJitteredOther:
      return "jittered_other";
    case CoverageClassification::kMissedPatternOff:
      return "missed_pattern_off";
    case CoverageClassification::kMissedZeroJitter:
      return "missed_zero_jitter";
    case CoverageClassification::kMissedNoState:
      return "missed_no_state";
    case CoverageClassification::kMissedNoViewport:
      return "missed_no_viewport";
    case CoverageClassification::kMissedViewportSize:
      return "missed_viewport_size";
    case CoverageClassification::kMissedNoDepth:
      return "missed_no_depth";
    case CoverageClassification::kMissedDepthSize:
      return "missed_depth_size";
    case CoverageClassification::kMissedUntrackedDepth:
      return "missed_untracked_depth";
    case CoverageClassification::kMissedIndirectDraw:
      return "missed_indirect_draw";
  }
  return "unknown";
}

inline SceneDrawEligibility GetFullResolutionSceneDrawEligibility(
    reshade::api::command_list* cmd_list,
    bool collect_diagnostics = false) {
  if (collect_diagnostics) ++diagnostics.draws;
  if (cmd_list == nullptr || render_width == 0u || render_height == 0u) {
    if (collect_diagnostics) ++diagnostics.missing_render_size;
    return SceneDrawEligibility::kIneligible;
  }

  auto* device = cmd_list->get_device();
  const auto* state = renodx::utils::state::GetCurrentState(cmd_list);
  if (device == nullptr || state == nullptr) {
    if (collect_diagnostics) ++diagnostics.missing_state;
    return SceneDrawEligibility::kIneligible;
  }
  if (state->viewports.empty()) {
    if (collect_diagnostics) ++diagnostics.missing_viewport;
    return SceneDrawEligibility::kIneligible;
  }

  const auto& viewport = state->viewports[0];
  if (std::abs(viewport.width - static_cast<float>(render_width)) >= 0.5f
      || std::abs(viewport.height - static_cast<float>(render_height)) >= 0.5f) {
    if (collect_diagnostics) ++diagnostics.viewport_size_mismatch;
    return SceneDrawEligibility::kIneligible;
  }

  if (auto* shader_data = renodx::utils::data::Get<renodx::utils::shader::CommandListData>(cmd_list);
      shader_data != nullptr
      && IsFullscreenPostProcessVertexShader(
          renodx::utils::shader::GetCurrentVertexShaderHash(shader_data))) {
    if (collect_diagnostics) ++diagnostics.excluded_postprocess_draws;
    return SceneDrawEligibility::kNonSpatialPostProcess;
  }

  const uint64_t postprocess_color = postprocess_scene_color_resource.load();
  const uint64_t expected_color = main_scene_color_resource.load();
  if (postprocess_color == 0u) {
    if (collect_diagnostics) ++diagnostics.scene_color_unknown;
    return SceneDrawEligibility::kIneligible;
  }

  bool exact_scene_color = false;
  for (const auto render_target_view : state->render_targets) {
    if (render_target_view.handle == 0u) continue;
    const auto render_target = renodx::utils::resource::GetResourceFromView(device, render_target_view);
    if (render_target.handle == postprocess_color
        || (expected_color != 0u && render_target.handle == expected_color)) {
      exact_scene_color = true;
      break;
    }
  }

  if (state->depth_stencil.handle == 0u) {
    if (collect_diagnostics) {
      ++diagnostics.missing_depth;
      if (exact_scene_color) ++diagnostics.scene_color_missing_depth;
    }
    return SceneDrawEligibility::kIneligible;
  }
  const auto depth = renodx::utils::resource::GetResourceFromView(device, state->depth_stencil);
  if (depth.handle == 0u) {
    if (collect_diagnostics) {
      ++diagnostics.missing_depth;
      if (exact_scene_color) ++diagnostics.scene_color_missing_depth;
    }
    return SceneDrawEligibility::kIneligible;
  }
  const auto depth_desc = renodx::utils::resource::GetResourceDesc(device, depth);
  if (depth_desc.texture.width != render_width || depth_desc.texture.height != render_height) {
    if (collect_diagnostics) ++diagnostics.depth_size_mismatch;
    return SceneDrawEligibility::kIneligible;
  }
  const uint64_t postprocess_depth = postprocess_depth_resource.load();
  const uint64_t expected_depth = main_scene_depth_resource.load();
  const bool exact_depth = postprocess_depth != 0u
                           && (depth.handle == postprocess_depth
                               || (expected_depth != 0u && depth.handle == expected_depth));
  if (postprocess_depth == 0u) {
    if (collect_diagnostics) ++diagnostics.main_depth_unknown;
  } else if (exact_depth && exact_scene_color) {
    if (collect_diagnostics) {
      ++diagnostics.depth_eligible_draws;
      ++diagnostics.eligible_draws;
    }
    return SceneDrawEligibility::kExactDepth;
  }

  if (!exact_scene_color) {
    if (collect_diagnostics) ++diagnostics.scene_color_mismatch;
    return SceneDrawEligibility::kIneligible;
  }

  if (collect_diagnostics) {
    ++diagnostics.main_depth_mismatch;
    ++diagnostics.scene_color_eligible_draws;
    ++diagnostics.eligible_draws;
  }
  return SceneDrawEligibility::kExactSceneColor;
}

inline void LogCoverageSummary(uint64_t frame_index) {
  if (!coverage_capture_active.load()) return;
  const uint64_t start_frame = coverage_start_frame.load();
  bool expected = false;
  if (start_frame == std::numeric_limits<uint64_t>::max()
      || frame_index < start_frame
      || frame_index - start_frame < 60u
      || !coverage_summary_logged.compare_exchange_strong(expected, true)) {
    return;
  }
  coverage_capture_active = false;

  size_t unique_contributor_passes = 0u;
  size_t unique_depth_only_passes = 0u;
  size_t unique_scene_operations = 0u;
  {
    std::scoped_lock lock(coverage_mutex);
    unique_contributor_passes = logged_contributor_passes.size();
    unique_depth_only_passes = logged_depth_only_passes.size();
    unique_scene_operations = logged_scene_operations.size();
  }

  const uint64_t contributor_draws = coverage_diagnostics.contributor_draws.load();
  const uint64_t excluded_postprocess_draws = coverage_diagnostics.excluded_postprocess_draws.load();
  const uint64_t spatial_contributor_draws = contributor_draws - excluded_postprocess_draws;
  const uint64_t jittered_contributors = coverage_diagnostics.jittered_contributor_draws.load();
  const float coverage_percent = spatial_contributor_draws == 0u
                                     ? 0.f
                                     : 100.f * static_cast<float>(jittered_contributors)
                                           / static_cast<float>(spatial_contributor_draws);
  std::stringstream s;
  s << "LORWIN DLAA jitter coverage: 60-frame result"
    << " verdict=" << (spatial_contributor_draws == 0u
                             ? "NO_SCENE_WRITERS_OBSERVED"
                             : (jittered_contributors == spatial_contributor_draws ? "COMPLETE" : "INCOMPLETE"))
    << " coverage=" << coverage_percent << "%"
    << " observed_draws=" << coverage_diagnostics.observed_draws.load()
    << " contributor_draws=" << contributor_draws
    << " spatial_contributors=" << spatial_contributor_draws
    << " excluded_postprocess=" << excluded_postprocess_draws
    << " jittered_contributors=" << jittered_contributors
    << " exact_depth_contributors=" << coverage_diagnostics.exact_depth_contributor_draws.load()
    << " scene_color_fallback_contributors=" << coverage_diagnostics.scene_color_fallback_draws.load()
    << " missed_pattern_off=" << coverage_diagnostics.missed_pattern_off.load()
    << " missed_zero_jitter=" << coverage_diagnostics.missed_zero_jitter.load()
    << " missed_no_state=" << coverage_diagnostics.missed_no_state.load()
    << " missed_no_viewport=" << coverage_diagnostics.missed_no_viewport.load()
    << " missed_viewport_size=" << coverage_diagnostics.missed_viewport_size.load()
    << " missed_no_depth=" << coverage_diagnostics.missed_no_depth.load()
    << " missed_depth_size=" << coverage_diagnostics.missed_depth_size.load()
    << " missed_untracked_depth=" << coverage_diagnostics.missed_untracked_depth.load()
    << " missed_indirect_draw=" << coverage_diagnostics.missed_indirect_draw.load()
    << " depth_only_false_positives=" << coverage_diagnostics.depth_only_draws.load()
    << " excluded_non_scene_depth_draws=" << coverage_diagnostics.excluded_non_scene_depth_draws.load()
    << " scene_clears=" << coverage_diagnostics.scene_color_clears.load()
    << " scene_transfers=" << coverage_diagnostics.scene_color_transfers.load()
    << " unique_contributor_passes=" << unique_contributor_passes
    << " unique_depth_only_passes=" << unique_depth_only_passes
    << " unique_scene_operations=" << unique_scene_operations;
  reshade::log::message(
      spatial_contributor_draws != 0u && jittered_contributors != spatial_contributor_draws
          ? reshade::log::level::warning
          : reshade::log::level::info,
      s.str().c_str());
}

inline void RecordSceneColorTransfer(
    reshade::api::resource source,
    reshade::api::resource dest,
    const char* operation) {
  if (!coverage_capture_active.load()
      || GetSceneColorLineageRole(dest.handle) == SceneColorLineageRole::kNone) {
    return;
  }

  ++coverage_diagnostics.scene_color_transfers;
  std::stringstream key;
  key << operation << ':' << std::hex << source.handle << ':' << dest.handle;
  bool should_log = false;
  {
    std::scoped_lock lock(coverage_mutex);
    if (logged_scene_operations.size() < 64u) {
      should_log = logged_scene_operations.insert(key.str()).second;
    }
  }
  if (should_log) {
    std::stringstream s;
    s << "LORWIN DLAA jitter coverage: scene transfer operation=" << operation
      << " source=0x" << std::hex << source.handle
      << " dest=0x" << dest.handle;
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }
  LogCoverageSummary(resource_logger::frame_index.load());
}

inline void RecordCoverageDraw(
    reshade::api::command_list* cmd_list,
    SceneDrawEligibility eligibility,
    int selected_pattern,
    uint64_t frame_index,
    bool handled_by_jitter_hook = true) {
  if (!coverage_capture_active.load()) return;
  ++coverage_diagnostics.observed_draws;

  auto* device = cmd_list != nullptr ? cmd_list->get_device() : nullptr;
  const auto* state = cmd_list != nullptr ? renodx::utils::state::GetCurrentState(cmd_list) : nullptr;
  if (device == nullptr || state == nullptr) {
    LogCoverageSummary(frame_index);
    return;
  }

  reshade::api::resource scene_target = {};
  SceneColorLineageRole scene_role = SceneColorLineageRole::kNone;
  uint32_t render_target_index = UINT32_MAX;
  for (uint32_t i = 0u; i < state->render_targets.size(); ++i) {
    if (state->render_targets[i].handle == 0u) continue;
    const auto resource = renodx::utils::resource::GetResourceFromView(device, state->render_targets[i]);
    const auto role = GetSceneColorLineageRole(resource.handle);
    if (role == SceneColorLineageRole::kNone) continue;
    scene_target = resource;
    scene_role = role;
    render_target_index = i;
    break;
  }

  auto* command_list_data = renodx::utils::data::Get<CommandListData>(cmd_list);
  const bool jitter_is_bound = command_list_data != nullptr
                               && command_list_data->jitter_applied
                               && command_list_data->applied_frame == frame_index
                               && (command_list_data->applied_pixel_jitter[0] != 0.f
                                   || command_list_data->applied_pixel_jitter[1] != 0.f);

  uint32_t vertex_shader_hash = 0u;
  uint32_t pixel_shader_hash = 0u;
  if (auto* shader_data = renodx::utils::data::Get<renodx::utils::shader::CommandListData>(cmd_list)) {
    vertex_shader_hash = renodx::utils::shader::GetCurrentVertexShaderHash(shader_data);
    pixel_shader_hash = renodx::utils::shader::GetCurrentPixelShaderHash(shader_data);
  }

  reshade::api::resource depth = {};
  if (state->depth_stencil.handle != 0u) {
    depth = renodx::utils::resource::GetResourceFromView(device, state->depth_stencil);
  }
  const auto& viewport = state->viewports.empty() ? reshade::api::viewport{} : state->viewports[0];

  if (scene_role == SceneColorLineageRole::kNone) {
    const uint64_t postprocess_depth = postprocess_depth_resource.load();
    const uint64_t expected_depth = main_scene_depth_resource.load();
    const bool tracked_depth = depth.handle != 0u
                               && (depth.handle == postprocess_depth
                                   || (expected_depth != 0u && depth.handle == expected_depth));
    if (selected_pattern != 0 && tracked_depth) {
      if (jitter_is_bound) {
        ++coverage_diagnostics.depth_only_draws;
      } else {
        ++coverage_diagnostics.excluded_non_scene_depth_draws;
      }

      std::stringstream key;
      key << (jitter_is_bound ? "jittered:" : "excluded:")
          << std::hex << vertex_shader_hash << ':' << pixel_shader_hash << ':'
          << state->graphics_pipeline_layout.handle << ':' << depth.handle;
      bool should_log = false;
      {
        std::scoped_lock lock(coverage_mutex);
        if (logged_depth_only_passes.size() < 64u) {
          should_log = logged_depth_only_passes.insert(key.str()).second;
        }
      }
      if (should_log) {
        std::stringstream s;
        s << "LORWIN DLAA jitter coverage: non-scene draw "
          << (jitter_is_bound ? "FALSE_POSITIVE_JITTER" : "correctly_excluded")
          << " vertex_shader=0x" << std::hex << vertex_shader_hash
          << " pixel_shader=0x" << pixel_shader_hash
          << " graphics_layout=0x" << state->graphics_pipeline_layout.handle
          << " depth=0x" << depth.handle << std::dec
          << "; this pass does not write the g_SceneTexture lineage.";
        reshade::log::message(reshade::log::level::info, s.str().c_str());
      }
    }
    LogCoverageSummary(frame_index);
    return;
  }

  ++coverage_diagnostics.contributor_draws;
  CoverageClassification classification = CoverageClassification::kMissedUntrackedDepth;
  if (eligibility == SceneDrawEligibility::kNonSpatialPostProcess) {
    classification = CoverageClassification::kExcludedPostProcess;
    ++coverage_diagnostics.excluded_postprocess_draws;
  } else if (selected_pattern == 0) {
    classification = CoverageClassification::kMissedPatternOff;
    ++coverage_diagnostics.missed_pattern_off;
  } else if (camera_jitter_scale == 0.f) {
    classification = CoverageClassification::kMissedZeroJitter;
    ++coverage_diagnostics.missed_zero_jitter;
  } else if (jitter_is_bound) {
    ++coverage_diagnostics.jittered_contributor_draws;
    if (eligibility == SceneDrawEligibility::kExactDepth) {
      classification = CoverageClassification::kJitteredExactDepth;
      ++coverage_diagnostics.exact_depth_contributor_draws;
    } else if (eligibility == SceneDrawEligibility::kExactSceneColor) {
      classification = CoverageClassification::kJitteredSceneColorFallback;
      ++coverage_diagnostics.scene_color_fallback_draws;
    } else {
      classification = CoverageClassification::kJitteredOther;
    }
  } else if (!handled_by_jitter_hook) {
    classification = CoverageClassification::kMissedIndirectDraw;
    ++coverage_diagnostics.missed_indirect_draw;
  } else if (state->viewports.empty()) {
    classification = CoverageClassification::kMissedNoViewport;
    ++coverage_diagnostics.missed_no_viewport;
  } else if (std::abs(viewport.width - static_cast<float>(render_width)) >= 0.5f
             || std::abs(viewport.height - static_cast<float>(render_height)) >= 0.5f) {
    classification = CoverageClassification::kMissedViewportSize;
    ++coverage_diagnostics.missed_viewport_size;
  } else if (depth.handle == 0u) {
    classification = CoverageClassification::kMissedNoDepth;
    ++coverage_diagnostics.missed_no_depth;
  } else {
    const auto depth_desc = renodx::utils::resource::GetResourceDesc(device, depth);
    if (depth_desc.texture.width != render_width || depth_desc.texture.height != render_height) {
      classification = CoverageClassification::kMissedDepthSize;
      ++coverage_diagnostics.missed_depth_size;
    } else {
      ++coverage_diagnostics.missed_untracked_depth;
    }
  }

  std::stringstream key;
  key << static_cast<uint32_t>(classification) << ':' << std::hex
      << vertex_shader_hash << ':' << pixel_shader_hash << ':'
      << state->graphics_pipeline_layout.handle << ':' << scene_target.handle << ':' << depth.handle
      << std::dec << ':' << render_target_index << ':' << viewport.width << ':' << viewport.height;
  bool should_log = false;
  {
    std::scoped_lock lock(coverage_mutex);
    if (logged_contributor_passes.size() < 128u) {
      should_log = logged_contributor_passes.insert(key.str()).second;
    }
  }
  if (should_log) {
    std::stringstream s;
    s << "LORWIN DLAA jitter coverage: contributor"
      << " classification=" << GetCoverageClassificationName(classification)
      << " scene_role="
      << (scene_role == SceneColorLineageRole::kPostprocessInput ? "postprocess_input" : "transfer_source")
      << " rtv_index=" << render_target_index
      << " scene_target=0x" << std::hex << scene_target.handle
      << " depth=0x" << depth.handle
      << " vertex_shader=0x" << vertex_shader_hash
      << " pixel_shader=0x" << pixel_shader_hash
      << " graphics_layout=0x" << state->graphics_pipeline_layout.handle << std::dec
      << " viewport=" << viewport.width << "x" << viewport.height;
    reshade::log::message(
        jitter_is_bound || classification == CoverageClassification::kExcludedPostProcess
            ? reshade::log::level::info
            : reshade::log::level::warning,
        s.str().c_str());
  }
  LogCoverageSummary(frame_index);
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
  size_t unique_scene_color_vertex_shaders = 0u;
  {
    std::scoped_lock lock(probe_mutex);
    unique_vertex_shaders = logged_vertex_shaders.size();
    unique_scene_color_vertex_shaders = logged_scene_color_vertex_shaders.size();
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
    << " scene_color_unknown=" << diagnostics.scene_color_unknown.exchange(0u)
    << " scene_color_mismatch=" << diagnostics.scene_color_mismatch.exchange(0u)
    << " scene_color_no_depth=" << diagnostics.scene_color_missing_depth.exchange(0u)
    << " excluded_postprocess=" << diagnostics.excluded_postprocess_draws.exchange(0u)
    << " depth_eligible=" << diagnostics.depth_eligible_draws.exchange(0u)
    << " scene_color_eligible=" << diagnostics.scene_color_eligible_draws.exchange(0u)
    << " eligible=" << diagnostics.eligible_draws.exchange(0u)
    << " jitter_binds=" << diagnostics.viewport_jitter_binds.exchange(0u)
    << " viewport_restores=" << diagnostics.viewport_restores.exchange(0u)
    << " unique_vertex_shaders=" << unique_vertex_shaders
    << " unique_scene_color_vertex_shaders=" << unique_scene_color_vertex_shaders;
  reshade::log::message(reshade::log::level::info, s.str().c_str());
}

inline void BindBaseViewports(reshade::api::command_list* cmd_list, CommandListData* data) {
  if (cmd_list == nullptr || data == nullptr || data->base_viewports.empty() || !data->jitter_applied) return;
  data->internal_viewport_bind = true;
  cmd_list->bind_viewports(0u, static_cast<uint32_t>(data->base_viewports.size()), data->base_viewports.data());
  data->internal_viewport_bind = false;
  data->jitter_applied = false;
  data->applied_frame = std::numeric_limits<uint64_t>::max();
  if (coverage_capture_active.load(std::memory_order_relaxed)) ++diagnostics.viewport_restores;
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
  if (coverage_capture_active.load(std::memory_order_relaxed)) ++diagnostics.viewport_jitter_binds;
}

inline void ApplyCameraJitter(reshade::api::command_list* cmd_list) {
  auto* command_list_data = renodx::utils::data::Get<CommandListData>(cmd_list);
  const int selected_pattern = GetSelectedPattern();
  const uint64_t frame_index = resource_logger::frame_index.load();
  const bool capture_active = coverage_capture_active.load(std::memory_order_relaxed);
  if (selected_pattern == 0) {
    BindBaseViewports(cmd_list, command_list_data);
    if (capture_active) {
      RecordCoverageDraw(cmd_list, SceneDrawEligibility::kIneligible, selected_pattern, frame_index);
      LogDiagnostics(frame_index);
    }
    const int logged_pattern = static_cast<int>(std::round(pattern)) == 3 ? 3 : 0;
    if (last_logged_pattern.exchange(logged_pattern) != logged_pattern && logged_pattern == 3) {
      reshade::log::message(
          reshade::log::level::info,
          "LORWIN DLAA jitter: FORCED OFF; viewport and NGX jitter are both zero.");
    }
    return;
  }

  if (last_logged_pattern.exchange(selected_pattern) != selected_pattern) {
    const auto pixel_jitter = GetPixelJitter();
    const auto projection_jitter = GetProjectionJitter();
    std::stringstream s;
    s << "LORWIN DLAA jitter: ACTIVE viewport pattern="
      << (selected_pattern == 1 ? "Halton8" : "FourQuadrant")
      << " render_size=" << render_width << "x" << render_height
      << " scale=" << camera_jitter_scale
      << " pixel=(" << pixel_jitter[0] << ", " << pixel_jitter[1] << ")"
      << " projection=(" << projection_jitter[0] << ", " << projection_jitter[1] << ")"
      << "; game constant-buffer memory is not read or modified.";
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }

  const auto eligibility = GetFullResolutionSceneDrawEligibility(cmd_list, capture_active);
  if (eligibility == SceneDrawEligibility::kIneligible
      || eligibility == SceneDrawEligibility::kNonSpatialPostProcess) {
    BindBaseViewports(cmd_list, command_list_data);
    if (capture_active) {
      RecordCoverageDraw(cmd_list, eligibility, selected_pattern, frame_index);
      LogDiagnostics(frame_index);
    }
    return;
  }

  BindJitteredViewports(cmd_list, command_list_data, frame_index, GetPixelJitter());
  if (capture_active) {
    RecordCoverageDraw(cmd_list, eligibility, selected_pattern, frame_index);

    uint32_t vertex_shader_hash = 0u;
    if (auto* shader_data = renodx::utils::data::Get<renodx::utils::shader::CommandListData>(cmd_list)) {
      vertex_shader_hash = renodx::utils::shader::GetCurrentVertexShaderHash(shader_data);
    }

    bool should_log = false;
    {
      std::scoped_lock lock(probe_mutex);
      auto& logged_shaders = eligibility == SceneDrawEligibility::kExactSceneColor
                                 ? logged_scene_color_vertex_shaders
                                 : logged_vertex_shaders;
      if (logged_shaders.size() < 64u) {
        should_log = logged_shaders.insert(vertex_shader_hash).second;
      }
    }
    if (should_log) {
      const auto* state = renodx::utils::state::GetCurrentState(cmd_list);
      std::stringstream s;
      const char* eligibility_name = eligibility == SceneDrawEligibility::kExactSceneColor
                                         ? "scene_color_fallback"
                                         : "exact_depth";
      s << "LORWIN DLAA jitter probe: eligible="
        << eligibility_name
        << " vertex_shader=0x" << std::hex << vertex_shader_hash
        << " graphics_layout=0x" << (state != nullptr ? state->graphics_pipeline_layout.handle : 0u)
        << std::dec << " render_size=" << render_width << "x" << render_height;
      reshade::log::message(reshade::log::level::info, s.str().c_str());
    }
    LogDiagnostics(frame_index);
  }
}

inline bool OnDraw(reshade::api::command_list* cmd_list, uint32_t, uint32_t, uint32_t, uint32_t) {
  ApplyCameraJitter(cmd_list);
  return false;
}

inline bool OnDrawIndexed(reshade::api::command_list* cmd_list, uint32_t, uint32_t, uint32_t, int32_t, uint32_t) {
  ApplyCameraJitter(cmd_list);
  return false;
}

inline bool OnDrawOrDispatchIndirect(
    reshade::api::command_list* cmd_list,
    reshade::api::indirect_command type,
    reshade::api::resource,
    uint64_t,
    uint32_t,
    uint32_t) {
  if (!coverage_capture_active.load(std::memory_order_relaxed)) return false;

  bool is_dispatch = false;
  switch (type) {
    case reshade::api::indirect_command::unknown: {
      auto* shader_data = renodx::utils::data::Get<renodx::utils::shader::CommandListData>(cmd_list);
      is_dispatch = shader_data != nullptr
                    && renodx::utils::shader::GetCurrentComputeShaderHash(shader_data) != 0u;
      break;
    }
    case reshade::api::indirect_command::dispatch:
    case reshade::api::indirect_command::dispatch_mesh:
    case reshade::api::indirect_command::dispatch_rays:
      is_dispatch = true;
      break;
    default:
      break;
  }
  if (!is_dispatch) {
    const int selected_pattern = GetSelectedPattern();
    const uint64_t frame_index = resource_logger::frame_index.load();
    const auto eligibility = selected_pattern == 0
                                 ? SceneDrawEligibility::kIneligible
                                 : GetFullResolutionSceneDrawEligibility(cmd_list, true);
    RecordCoverageDraw(cmd_list, eligibility, selected_pattern, frame_index, false);
    LogDiagnostics(frame_index);
  }
  return false;
}

inline bool OnClearRenderTargetView(
    reshade::api::command_list* cmd_list,
    reshade::api::resource_view rtv,
    const float[4],
    uint32_t,
    const reshade::api::rect*) {
  if (!coverage_capture_active.load() || cmd_list == nullptr || rtv.handle == 0u) return false;
  auto* device = cmd_list->get_device();
  if (device == nullptr) return false;
  const auto resource = renodx::utils::resource::GetResourceFromView(device, rtv);
  if (GetSceneColorLineageRole(resource.handle) == SceneColorLineageRole::kNone) return false;

  ++coverage_diagnostics.scene_color_clears;
  std::stringstream key;
  key << "clear:" << std::hex << resource.handle;
  bool should_log = false;
  {
    std::scoped_lock lock(coverage_mutex);
    if (logged_scene_operations.size() < 64u) {
      should_log = logged_scene_operations.insert(key.str()).second;
    }
  }
  if (should_log) {
    std::stringstream s;
    s << "LORWIN DLAA jitter coverage: scene clear target=0x" << std::hex << resource.handle
      << "; clear is a non-spatial contributor and does not require camera jitter.";
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }
  LogCoverageSummary(resource_logger::frame_index.load());
  return false;
}

inline bool OnCopyResource(
    reshade::api::command_list*,
    reshade::api::resource source,
    reshade::api::resource dest) {
  RecordResourceCopy(source, dest, "copy_resource");
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
  RecordResourceCopy(source, dest, "copy_texture_region");
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
  RecordResourceCopy(source, dest, "resolve_texture_region");
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
    postprocess_scene_color_resource = 0u;
    main_scene_color_resource = 0u;
    last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
    coverage_capture_active = false;
    coverage_start_frame = std::numeric_limits<uint64_t>::max();
    {
      std::scoped_lock lock(resource_lineage_mutex);
      resource_copy_sources.clear();
    }
  }
}

inline void OnDestroySwapchain(reshade::api::swapchain* swapchain, bool resize) {
  if (swapchain != tracked_swapchain) return;
  postprocess_depth_resource = 0u;
  main_scene_depth_resource = 0u;
  postprocess_scene_color_resource = 0u;
  main_scene_color_resource = 0u;
  last_scene_jitter_frame = std::numeric_limits<uint64_t>::max();
  coverage_capture_active = false;
  coverage_start_frame = std::numeric_limits<uint64_t>::max();
  {
    std::scoped_lock lock(resource_lineage_mutex);
    resource_copy_sources.clear();
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
        reshade::register_event<reshade::addon_event::draw_or_dispatch_indirect>(OnDrawOrDispatchIndirect);
        reshade::register_event<reshade::addon_event::clear_render_target_view>(OnClearRenderTargetView);
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
        reshade::unregister_event<reshade::addon_event::draw_or_dispatch_indirect>(OnDrawOrDispatchIndirect);
        reshade::unregister_event<reshade::addon_event::clear_render_target_view>(OnClearRenderTargetView);
        reshade::unregister_event<reshade::addon_event::copy_resource>(OnCopyResource);
        reshade::unregister_event<reshade::addon_event::copy_texture_region>(OnCopyTextureRegion);
        reshade::unregister_event<reshade::addon_event::resolve_texture_region>(OnResolveTextureRegion);
      }
      break;
  }
}

}  // namespace lorwin::jitter
