// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include "hit_pool.hpp"

namespace witcher3graphics::raytracing {
enum class HitKind : uint32_t { reflection, global_probe, local_probe };
// Track identities, not borrowed native pointers. Resource destruction and
// writes invalidate pool publication separately; handle recycling gets a new
// generation. Buffer resources (including the pool's own buffers) are excluded.
class HitTargetTracker {
 public:
  void Created(resource object, const resource_desc& description) {
    if (!object.handle || description.type != resource_type::texture_2d
        || description.texture.depth_or_layers != 1 || description.texture.levels != 1 || description.texture.samples != 1
        || (description.usage & resource_usage::unordered_access) == resource_usage::undefined
        || (description.texture.format != format::r16g16b16a16_float && description.texture.format != format::r32g32b32a32_float
            && description.texture.format != format::r8g8b8a8_unorm && description.texture.format != format::r16_float
            && description.texture.format != format::r32_float)) return;
    std::lock_guard lock(mutex_);
    if (sequence_ == UINT64_MAX) { resources_.clear(); return; }
    resources_[object.handle] = {description.texture.width, description.texture.height, description.texture.format, ++sequence_};
  }
  bool Destroyed(resource object) {
    std::lock_guard lock(mutex_);
    return resources_.erase(object.handle) != 0;
  }
  bool Contains(resource object) const {
    std::lock_guard lock(mutex_);
    return resources_.contains(object.handle);
  }
  bool Resolve(command_list* cmd, bool producer, HitTargets* output, HitKind kind = HitKind::reflection) const {
    *output = {};
    const auto stage = producer ? shader_stage::raygen : shader_stage::compute;
    const auto type = producer ? descriptor_type::texture_unordered_access_view : descriptor_type::texture_shader_resource_view;
    HitTargets result;
    for (uint32_t i = 0; i < 3; ++i) {
      const uint32_t binding = kind == HitKind::reflection ? (producer ? i : std::array{5u, 11u, 12u}[i])
          : producer ? 2u + uint32_t(kind) + i * 2u : i;
      const auto slot = bindings::Find(cmd, stage, type, binding, producer ? 1u : 0u);
      if (slot.type != type || !slot.resource_view.handle) return false;
      const auto view = cmd->get_device()->get_resource_view_desc(slot.resource_view);
      const auto object = cmd->get_device()->get_resource_from_view(slot.resource_view);
      if (view.type != resource_view_type::texture_2d || view.texture.first_level != 0
          || (view.texture.level_count != 1 && view.texture.level_count != UINT32_MAX)) return false;
      std::lock_guard lock(mutex_);
      const auto found = resources_.find(object.handle);
      if (found == resources_.end() || view.format != found->second.format) return false;
      const auto& texture = found->second;
      const bool rgba_float = texture.format == format::r16g16b16a16_float || texture.format == format::r32g32b32a32_float;
      if (kind == HitKind::reflection ? !rgba_float
          : i == 0 ? texture.format != format::r8g8b8a8_unorm
          : i == 1 ? !rgba_float : texture.format != format::r16_float && texture.format != format::r32_float) return false;
      if (i == 0) { result.width = texture.width; result.height = texture.height; }
      else if (result.width != texture.width || result.height != texture.height) return false;
      result.resources[i] = object.handle; result.generations[i] = texture.generation;
    }
    if (!result.Valid()) return false;
    *output = result;
    return true;
  }

 private:
  struct Texture { uint32_t width, height; reshade::api::format format; uint64_t generation; };
  mutable std::mutex mutex_;
  std::unordered_map<uint64_t, Texture> resources_;
  uint64_t sequence_ = 0;
};
}  // namespace witcher3graphics::raytracing
