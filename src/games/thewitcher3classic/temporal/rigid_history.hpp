/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <cmath>
#include "./object_history.hpp"

namespace witcher3classic::temporal {
// A transform is not an identity: character parts and unrelated overlapping
// objects can have identical worlds. Keep each native proxy's history separate.
class RigidHistory {
 public:
  ObjectPose Record(uint64_t frame, uintptr_t object, uintptr_t mesh, const WorldTransform& world) {
    if (!object || !std::ranges::all_of(world, [](float v) { return std::isfinite(v); })) return {};
    if (objects_.size() >= 8192 && !objects_.contains(object)) {
      std::erase_if(objects_, [frame](const auto& entry) { return entry.second.frame + 120 < frame; });
      if (objects_.size() >= 8192) return {};
    }
    auto& state = objects_[object];
    if (state.frame == frame) {
      if (state.world != world || state.mesh != mesh) {
        state.previous.valid = 0;
        state.ambiguous = true;
      }
      return state.previous;
    }
    state.previous = {state.world, 0, 0, uint32_t(state.frame != UINT64_MAX && state.frame + 1 == frame && state.mesh == mesh && !state.ambiguous), 0};
    state.world = world;
    state.mesh = mesh;
    state.frame = frame;
    state.ambiguous = false;
    return state.previous;
  }
  ObjectPose Previous(uint64_t frame, uintptr_t object, uintptr_t mesh, const WorldTransform& world) const {
    const auto entry = objects_.find(object);
    if (entry == objects_.end() || entry->second.frame != frame || entry->second.mesh != mesh || entry->second.world != world) return {};
    return entry->second.previous;
  }
  void Erase(uintptr_t object) { objects_.erase(object); }
  void Clear() { objects_.clear(); }

 private:
  struct State {
    WorldTransform world = {};
    ObjectPose previous;
    uintptr_t mesh = 0;
    uint64_t frame = UINT64_MAX;
    bool ambiguous = false;
  };
  std::unordered_map<uintptr_t, State> objects_;
};
}  // namespace witcher3classic::temporal
