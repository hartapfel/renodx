// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "bindings.hpp"
#include "../../../../../utils/state.hpp"
#include <d3d12.h>

namespace witcher3graphics::bindings {
// Restore exactly the state our fullscreen passes modify. General Apply()
// consults an unrelated resource-lifetime cache and crashed this game earlier.
class RestorePassState {
 public:
  RestorePassState(reshade::api::command_list* cmd, const renodx::utils::state::CommandListState& state,
                   const CommandData& roots) : cmd_(cmd), state_(state), roots_(roots) {}
  RestorePassState(const RestorePassState&) = delete;
  RestorePassState& operator=(const RestorePassState&) = delete;
  ~RestorePassState() {
    using namespace reshade::api;
    cmd_->bind_render_targets_and_depth_stencil(uint32_t(state_.render_targets.size()), state_.render_targets.data(), state_.depth_stencil);
    cmd_->bind_viewports(0, uint32_t(state_.viewports.size()), state_.viewports.data());
    cmd_->bind_scissor_rects(0, uint32_t(state_.scissor_rects.size()), state_.scissor_rects.data());
    roots_.compute.Restore(cmd_, shader_stage::all_compute);
    roots_.graphics.Restore(cmd_, shader_stage::all_graphics);
    // D3D12 has one PSO slot shared by graphics and compute.
    cmd_->bind_pipeline(roots_.last_stages, roots_.last_pipeline);
    // ReShade's graphics PSO binding also sets topology and blend factor.
    // Restore dynamic values afterwards, including a valid zero blend factor.
    if (state_.primitive_topology != primitive_topology::undefined)
      cmd_->bind_pipeline_state(dynamic_state::primitive_topology, uint32_t(state_.primitive_topology));
    if (cmd_->get_device()->get_api() == device_api::d3d12) {
      // ReShade 6.8's generic setter unpacks at 4-bit offsets, although the
      // event packs four 8-bit channels. Use the native setter on this API.
      const float blend[4]{float(state_.blend_constant & 255u) / 255.f,
          float((state_.blend_constant >> 8) & 255u) / 255.f,
          float((state_.blend_constant >> 16) & 255u) / 255.f,
          float(state_.blend_constant >> 24) / 255.f};
      reinterpret_cast<ID3D12GraphicsCommandList*>(cmd_->get_native())->OMSetBlendFactor(blend);
    } else cmd_->bind_pipeline_state(dynamic_state::blend_constant, state_.blend_constant);
  }

 private:
  reshade::api::command_list* cmd_;
  renodx::utils::state::CommandListState state_;
  CommandData roots_;
};
}  // namespace witcher3graphics::bindings
