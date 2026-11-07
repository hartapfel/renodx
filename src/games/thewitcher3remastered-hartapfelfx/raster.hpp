// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <algorithm>
#include <vector>
#include <include/reshade.hpp>
#include "../../utils/data.hpp"

namespace hartapfelfx::raster {
namespace api = reshade::api;

// Only the native values modified by our private passes. In particular this
// cache does not capture pipelines, descriptor tables, IA buffers or resources.
struct State {
  std::vector<api::resource_view> render_targets;
  api::resource_view depth_stencil{};
  std::vector<api::viewport> viewports;
  std::vector<api::rect> scissor_rects;
  api::primitive_topology primitive_topology = api::primitive_topology::undefined;
  uint32_t blend_constant = 0;
};
struct __declspec(uuid("b549d466-0754-49a6-9611-42f021e90710")) CommandData {
  State state;
};
inline State* Get(api::command_list* cmd) {
  auto* data = renodx::utils::data::Get<CommandData>(cmd);
  return (data ? &data->state : nullptr);
}
inline void OnInit(api::command_list* cmd) {
  if (cmd->get_device()->get_api() == api::device_api::d3d12) {
    renodx::utils::data::Create<CommandData>(cmd);
  }
}
inline void OnDestroy(api::command_list* cmd) { renodx::utils::data::Delete<CommandData>(cmd); }
inline void OnReset(api::command_list* cmd) {
  if (auto* state = Get(cmd)) {
    state->render_targets.clear();
    state->depth_stencil = {};
    state->viewports.clear();
    state->scissor_rects.clear();
    state->primitive_topology = api::primitive_topology::undefined;
    state->blend_constant = 0;
  }
}
inline void OnTargets(api::command_list* cmd, uint32_t count, const api::resource_view* targets, api::resource_view depth) {
  auto* state = Get(cmd);
  if (!state || count > 8 || (count && !targets)) return;
  state->render_targets.resize(count);
  if (count) {
    std::copy_n(targets, count, state->render_targets.begin());
  }
  state->depth_stencil = depth;
}
inline void OnBeginPass(api::command_list* cmd, uint32_t count, const api::render_pass_render_target_desc* targets,
                         const api::render_pass_depth_stencil_desc* depth) {
  auto* state = Get(cmd);
  if (!state || count > 8 || (count && !targets)) return;
  state->render_targets.resize(count);
  for (uint32_t index = 0; index < count; ++index) {
    state->render_targets[index] = targets[index].view;
  }
  state->depth_stencil = (depth ? depth->view : api::resource_view{});
}
inline void OnViewports(api::command_list* cmd, uint32_t first, uint32_t count, const api::viewport* values) {
  auto* state = Get(cmd);
  if (!state || first > 16 || count > 16 - first || (count && !values)) return;
  state->viewports.resize(first == 0 ? count : std::max<size_t>(state->viewports.size(), first + count));
  if (count) {
    std::copy_n(values, count, state->viewports.begin() + first);
  }
}
inline void OnScissors(api::command_list* cmd, uint32_t first, uint32_t count, const api::rect* values) {
  auto* state = Get(cmd);
  if (!state || first > 16 || count > 16 - first || (count && !values)) return;
  state->scissor_rects.resize(first == 0 ? count : std::max<size_t>(state->scissor_rects.size(), first + count));
  if (count) {
    std::copy_n(values, count, state->scissor_rects.begin() + first);
  }
}
inline void OnStates(api::command_list* cmd, uint32_t count, const api::dynamic_state* states, const uint32_t* values) {
  auto* state = Get(cmd);
  if (!state) return;
  for (uint32_t index = 0; index < count; ++index) {
    switch (states[index]) {
      case api::dynamic_state::primitive_topology:
        state->primitive_topology = api::primitive_topology(values[index]);
        break;
      case api::dynamic_state::blend_constant:
        state->blend_constant = values[index];
        break;
      default: break;
    }
  }
}
inline void Use(DWORD reason) {
#define HFX_RASTER_EVENT(event, callback) \
  if (reason == DLL_PROCESS_ATTACH) reshade::register_event<reshade::addon_event::event>(callback); \
  else if (reason == DLL_PROCESS_DETACH) reshade::unregister_event<reshade::addon_event::event>(callback)
  HFX_RASTER_EVENT(init_command_list, OnInit);
  HFX_RASTER_EVENT(destroy_command_list, OnDestroy);
  HFX_RASTER_EVENT(reset_command_list, OnReset);
  HFX_RASTER_EVENT(bind_render_targets_and_depth_stencil, OnTargets);
  HFX_RASTER_EVENT(begin_render_pass, OnBeginPass);
  HFX_RASTER_EVENT(bind_viewports, OnViewports);
  HFX_RASTER_EVENT(bind_scissor_rects, OnScissors);
  HFX_RASTER_EVENT(bind_pipeline_states, OnStates);
#undef HFX_RASTER_EVENT
}
}  // namespace hartapfelfx::raster
