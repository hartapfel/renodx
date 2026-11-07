// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <array>
#include <mutex>
#include <unordered_map>
#include "../../rendering/pass.hpp"

namespace witcher3graphics::contact {
struct NativeMotionInputs {
  std::array<reshade::api::resource_view, 2> views{};
  reshade::api::buffer_range camera{};
  reshade::api::resource resource{};
  reshade::api::resource_usage state = reshade::api::resource_usage::undefined;
};
// Native motion is already produced with the opaque G-buffer. Observe its
// proven writer and subsequent native barriers on the SAME recording before
// borrowing it. A temporary read transition restores the observed native state.
// Cross-frame/queue states are not inferred. Descriptors retire with resources.
class MotionInputs {
 public:
  explicit MotionInputs(reshade::api::device* dev) : dev_(dev) {}
  ~MotionInputs() {
    for (const auto& [resource, view] : views_) if (view.handle) dev_->destroy_resource_view(view);
  }
  void Observe(reshade::api::command_list* cmd) {
    using namespace reshade::api;
    std::lock_guard lock(mutex_);
    recordings_.erase(cmd);
    const auto* state = hartapfelfx::raster::Get(cmd);
    if (!state || state->render_targets.size() != 4 || !state->depth_stencil.handle) return;
    for (uint32_t i = 0; i < 3; ++i)
      if (!state->render_targets[i].handle || dev_->get_resource_view_desc(state->render_targets[i]).format != format::r8g8b8a8_unorm) return;
    if (!state->render_targets[3].handle) return;
    const auto motion = dev_->get_resource_from_view(state->render_targets[3]);
    const auto depth = dev_->get_resource_from_view(state->depth_stencil);
    if (!motion.handle || !depth.handle) return;
    const auto desc = dev_->get_resource_desc(motion);
    const auto depth_desc = dev_->get_resource_desc(depth);
    if (desc.type != resource_type::texture_2d || desc.texture.format != format::r16g16b16a16_float
        || desc.texture.samples != 1 || desc.texture.levels != 1 || desc.texture.depth_or_layers != 1
        || depth_desc.type != resource_type::texture_2d || depth_desc.texture.samples != 1
        || depth_desc.texture.levels != 1 || depth_desc.texture.depth_or_layers != 1
        || depth_desc.texture.width != desc.texture.width || depth_desc.texture.height != desc.texture.height) return;
    const auto camera = bindings::Find(cmd, shader_stage::vertex, descriptor_type::constant_buffer, 1);
    if (camera.type != descriptor_type::constant_buffer || !camera.buffer_range.buffer.handle) return;
    auto& view = views_[motion.handle];
    if (!view.handle) {
      resource_view_desc view_desc(format::r16g16b16a16_float);
      view_desc.type = resource_view_type::texture_2d; view_desc.texture = {0, 1, 0, 1};
      if (!dev_->create_resource_view(motion, resource_usage::shader_resource, view_desc, &view)) return;
    }
    recordings_[cmd] = {motion, depth, camera.buffer_range, view, resource_usage::render_target};
  }
  NativeMotionInputs Resolve(reshade::api::command_list* cmd, reshade::api::resource_view depth_view) {
    std::lock_guard lock(mutex_);
    const auto it = recordings_.find(cmd);
    if (it == recordings_.end() || it->second.state == reshade::api::resource_usage::undefined
        || it->second.depth != dev_->get_resource_from_view(depth_view)) return {};
    return {{it->second.view, depth_view}, it->second.camera, it->second.motion, it->second.state};
  }
  void Barrier(reshade::api::command_list* cmd, uint32_t count, const reshade::api::resource* resources,
      const reshade::api::resource_usage* states) {
    std::lock_guard lock(mutex_);
    const auto it = recordings_.find(cmd);
    if (it == recordings_.end()) return;
    for (uint32_t i = 0; i < count; ++i) {
      if (resources[i] == it->second.motion) {
        // A later writer/alias is no longer the observed G-buffer transaction.
        if (it->second.state != reshade::api::resource_usage::undefined
            && (uint32_t(states[i]) & uint32_t(reshade::api::resource_usage::shader_resource)) != 0)
          it->second.state = states[i];
        else it->second.state = reshade::api::resource_usage::undefined;
      }
      if (resources[i] == it->second.depth && (uint32_t(states[i]) & uint32_t(
          reshade::api::resource_usage::depth_stencil_write | reshade::api::resource_usage::copy_dest)) != 0)
        it->second.state = reshade::api::resource_usage::undefined;
    }
  }
  void Reset(reshade::api::command_list* cmd = nullptr) {
    std::lock_guard lock(mutex_);
    if (cmd) recordings_.erase(cmd); else recordings_.clear();
  }
  void DestroyResource(reshade::api::resource resource) {
    std::lock_guard lock(mutex_);
    std::erase_if(recordings_, [&](const auto& entry) {
      return entry.second.motion == resource || entry.second.depth == resource || entry.second.camera.buffer == resource;
    });
    if (const auto it = views_.find(resource.handle); it != views_.end()) {
      dev_->destroy_resource_view(it->second); views_.erase(it);
    }
  }
 private:
  struct Recording {
    reshade::api::resource motion, depth;
    reshade::api::buffer_range camera;
    reshade::api::resource_view view;
    reshade::api::resource_usage state;
  };
  reshade::api::device* dev_;
  std::mutex mutex_;
  std::unordered_map<uint64_t, reshade::api::resource_view> views_;
  std::unordered_map<reshade::api::command_list*, Recording> recordings_;
};
}  // namespace witcher3graphics::contact
