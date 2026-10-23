/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <cmath>
#include "./object_history.hpp"

namespace witcher3classic::temporal {
// Slots address the full native swarm array before visibility sorting/LOD
// partitioning. Neither the visible draw index nor the rotating array pointer
// is persistent identity. Native proxy destruction removes the whole owner.
class SwarmHistory {
 public:
  ObjectPose Record(uint64_t frame, uintptr_t owner, uintptr_t group, uint32_t count, uint32_t slot, const WorldTransform& world) {
    if (!owner || !count || count > 4096 || slot >= count
        || !std::ranges::all_of(world, [](float value) { return std::isfinite(value); })) return {};
    auto found = owners_.find(owner);
    if (found != owners_.end() && (found->second.group != group || found->second.instances.size() != count)) {
      instances_ -= found->second.instances.size();
      owners_.erase(found);
      found = owners_.end();
    }
    if (found == owners_.end()) {
      if (owners_.size() >= 256 || instances_ + count > 8192)
        for (auto it = owners_.begin(); it != owners_.end();) {
          if (it->second.frame + 120 < frame) {
            instances_ -= it->second.instances.size();
            it = owners_.erase(it);
          } else ++it;
        }
      if (owners_.size() >= 256 || instances_ + count > 8192) return {};
      found = owners_.emplace(owner, Owner{group, frame, std::vector<Instance>(count)}).first;
      instances_ += count;
    }
    found->second.frame = frame;
    auto& instance = found->second.instances[slot];
    if (instance.frame != frame) {
      instance.previous = {instance.current, 0, 0, uint32_t(instance.frame != UINT64_MAX && instance.frame + 1 == frame), 0};
      instance.current = world;
      instance.frame = frame;
    } else if (instance.current != world) {
      instance.previous.valid = 0;
    }
    return instance.previous;
  }
  void Erase(uintptr_t owner) {
    const auto found = owners_.find(owner);
    if (found == owners_.end()) return;
    instances_ -= found->second.instances.size();
    owners_.erase(found);
  }
  void Clear() { owners_.clear(); instances_ = 0; }

 private:
  struct Instance {
    WorldTransform current = {};
    ObjectPose previous;
    uint64_t frame = UINT64_MAX;
  };
  struct Owner {
    uintptr_t group;
    uint64_t frame;
    std::vector<Instance> instances;
  };
  std::unordered_map<uintptr_t, Owner> owners_;
  size_t instances_ = 0;
};
}  // namespace witcher3classic::temporal
