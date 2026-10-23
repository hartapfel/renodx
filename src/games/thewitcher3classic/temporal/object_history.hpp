/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include <cstdint>
#include <span>
#include <unordered_map>
#include <vector>

namespace witcher3classic::temporal {
using WorldTransform = std::array<float, 12>;
struct BoneAllocation {
  uintptr_t id = 0, storage = 0;
  uint32_t base = 0, count = 0;
};
// Matches ObjectPose in object_vertex.hlsli. A compact pose table is addressed
// through a separate current-palette-base -> table-entry indirection buffer.
struct ObjectPose {
  WorldTransform world = {};
  uint32_t previous_base = 0, bone_count = 0, valid = 0, palette_valid = 0;
};
static_assert(sizeof(ObjectPose) == 64);

class ObjectHistory {
 public:
  void Record(uint64_t frame, uintptr_t allocation, const WorldTransform& world) {
    if (!allocation || (states_.size() >= 4096 && !states_.contains(allocation))) return;
    auto& state = states_[allocation];
    if (state.observed_frame != frame) {
      state.observed_frame = frame;
      state.current = world;
      state.ambiguous = false;
    } else if (state.current != world) {
      // Several mesh parts may share a skeleton. Different instance worlds
      // cannot share one previous-world entry: reject rather than cross actors.
      state.ambiguous = true;
    }
  }

  ObjectPose Previous(uint64_t frame, const BoneAllocation& allocation) const {
    const auto found = states_.find(allocation.id);
    if (found == states_.end()) return {};
    const auto& state = found->second;
    // Native pose storage rotates between animation buffers. The allocation is
    // the persistent owner; its destruction hook invalidates address reuse.
    if (state.committed_frame == UINT64_MAX || state.committed_frame + 1 != frame
        || state.allocation.count != allocation.count) return {};
    return {state.previous, state.allocation.base, allocation.count, uint32_t(state.valid), 1};
  }

  void Commit(uint64_t frame, std::span<const BoneAllocation> allocations) {
    for (const auto& allocation : allocations) {
      // Swarm instances share palettes but have separate world histories.
      // Retain registered palettes even without an ordinary mesh observation.
      auto found = states_.find(allocation.id);
      if (found == states_.end()) {
        if (states_.size() >= 4096) continue;
        found = states_.try_emplace(allocation.id).first;
      }
      auto& state = found->second;
      state.valid = state.observed_frame == frame && !state.ambiguous;
      state.previous = state.current;
      state.allocation = allocation;
      state.committed_frame = frame;
    }
  }
  void Erase(uintptr_t allocation) { states_.erase(allocation); }
  void Clear() { states_.clear(); }

 private:
  struct State {
    WorldTransform current = {}, previous = {};
    BoneAllocation allocation;
    uint64_t observed_frame = UINT64_MAX, committed_frame = UINT64_MAX;
    bool ambiguous = false, valid = false;
  };
  std::unordered_map<uintptr_t, State> states_;
};
}  // namespace witcher3classic::temporal
