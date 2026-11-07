// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#pragma once
#include <algorithm>
#include <atomic>
#include "hit_field.hpp"
#include "../water/submission.hpp"

namespace witcher3graphics::raytracing {
struct HitRecording {};
struct HitTargets {
  std::array<uint64_t, 3> resources{}, generations{};
  uint32_t width = 0, height = 0;
  bool operator==(const HitTargets&) const = default;
  bool Valid() const {
    return width && height && width <= 16384 && height <= 16384
        && uint64_t(width) * height <= W3_HIT_MAX_PIXELS
        && std::ranges::all_of(resources, [](uint64_t value) { return value != 0; })
        && std::ranges::all_of(generations, [](uint64_t value) { return value != 0; })
        && resources[0] != resources[1] && resources[0] != resources[2] && resources[1] != resources[2];
  }
};

// Same-recording publication only: CPU recording order across command lists is
// not evidence of GPU ordering. Reset replaces the token; target writes, alias
// barriers, destruction and mode/frame changes invalidate publication explicitly.
// Submission leases/fences still retain every recorded allocation through replay.
class HitPool {
 public:
  static constexpr uint64_t MAX_RESIDENT_BYTES = 512ull * 1024 * 1024;
  explicit HitPool(device* dev) : device_(dev) {}
  HitPool(const HitPool&) = delete;
  HitPool& operator=(const HitPool&) = delete;

  template <typename Dispatch>
  bool Produce(command_list* cmd, const std::shared_ptr<HitRecording>& recording, const HitTargets& targets,
      uint32_t context_root, uint32_t output_root, std::span<const uint8_t> clear_code,
      shader_stage stage, Dispatch&& dispatch, const HitSelectionDispatch* selection = nullptr) {
    if (!recording || cmd->get_device() != device_ || !targets.Valid()) { Invalidate(); return false; }
    std::unique_lock lock(mutex_);
    Entry* next = nullptr;
    if (selection) {
      for (auto& entry : entries_)
        if (entry.selected && entry.published && !entry.invalidated && entry.owner == cmd
            && entry.recording.lock() == recording && entry.targets == targets
            && entry.field && entry.field->Compatible(targets.width, targets.height, clear_code)) { next = &entry; break; }
    }
    const bool reuse = next != nullptr;
    // Even an allocation/admission failure supersedes the preceding producer.
    for (auto& entry : entries_)
      for (const auto resource : targets.resources)
        if (&entry != next && std::ranges::find(entry.targets.resources, resource) != entry.targets.resources.end()) {
          entry.published = false; entry.invalidated = true;
        }
    if (!reuse && epoch_ == UINT32_MAX) return false;
    if (!reuse) for (auto& entry : std::span(entries_).first(selection ? entries_.size() : 8)) {
      if (entry.lifetime && (entry.lifetime.use_count() != 1 || !entry.lifetime->Idle())) continue;
      if (!next || (entry.field && entry.width == targets.width && entry.height == targets.height)) next = &entry;
    }
    if (!next) return false;
    next->published = false;
    if (next->field && !next->field->Compatible(targets.width, targets.height, clear_code)) next->field.reset();
    const uint64_t requested = W3_HIT_HEADER_BYTES + uint64_t(targets.width) * targets.height * W3_HIT_STRIDE;
    if (!next->field) {
      uint64_t resident = 0;
      for (const auto& entry : entries_) if (entry.field) resident += entry.field->Bytes();
      // Bound aggregate memory, including retired fields whose GPU work remains.
      for (auto& entry : entries_) {
        // Four 3840x2160 fields fit: three frames in flight plus the current
        // recording. The former 256 MiB cap held only two and could alternate
        // between improved/native reflections under normal queued rendering.
        if (resident + requested <= MAX_RESIDENT_BYTES) break;
        if (entry.field && (!entry.lifetime || (entry.lifetime.use_count() == 1 && entry.lifetime->Idle()))) {
          resident -= entry.field->Bytes(); entry.field.reset(); entry.published = false;
        }
      }
      if (resident + requested > MAX_RESIDENT_BYTES) return false;
      next->field = std::make_unique<HitField>(device_);
      if (!next->field->Initialize(targets.width, targets.height, clear_code)) { next->field.reset(); return false; }
      next->width = targets.width; next->height = targets.height;
    }
    if (!reuse) {
      next->field->Recycle();
      next->lifetime = std::make_shared<water::submission::Lifetime>();
      next->epoch = ++epoch_;
    }
    if (!water::submission::Track(cmd, next->lifetime, true)) return false;
    if (!next->field->BeginWrite(cmd, next->epoch, context_root, output_root, stage, selection, reuse)) return false;
    next->selected = selection != nullptr;
    next->targets = targets; next->recording = recording; next->owner = cmd; next->invalidated = false;
    active_.store(true, std::memory_order_release);
    // Record the pending identity before unlocking: writes on another recording
    // can cancel it while dispatch is being issued. Completion must not revive
    // data invalidated in that interval. The lease already prevents recycling.
    // Issue the producer via the addon API, which does not re-enter its observers.
    lock.unlock();
    dispatch();
    if (!next->field->EndWrite(cmd)) return false;
    lock.lock();
    if (next->invalidated) return false;
    next->published = true;
    return true;
  }

  bool BindConsumer(command_list* cmd, const std::shared_ptr<HitRecording>& recording, const HitTargets& targets,
      uint32_t context_root, uint32_t input_root) {
    if (!recording || cmd->get_device() != device_) return false;
    std::lock_guard lock(mutex_);
    for (auto& entry : entries_) {
      if (!entry.published || entry.owner != cmd || entry.recording.lock() != recording || entry.targets != targets) continue;
      // The producer's existing recording lease also covers these reads. Never
      // attach a reader to an unrelated or reset recording on pointer identity.
      return water::submission::Track(cmd, entry.lifetime, true)
          && entry.field->BindRead(cmd, context_root, input_root);
    }
    return false;
  }
  bool Active() const { return active_.load(std::memory_order_acquire); }
  void Invalidate(uint64_t resource = 0) {
    if (!Active()) return;
    std::lock_guard lock(mutex_);
    for (auto& entry : entries_)
      if (!resource || std::ranges::find(entry.targets.resources, resource) != entry.targets.resources.end()) {
        entry.published = false; entry.invalidated = true;
      }
    if (!resource) active_.store(false, std::memory_order_release);
  }

 private:
  struct Entry {
    std::unique_ptr<HitField> field;
    std::shared_ptr<water::submission::Lifetime> lifetime;
    std::weak_ptr<HitRecording> recording;
    HitTargets targets;
    command_list* owner = nullptr;
    uint32_t width = 0, height = 0, epoch = 0;
    bool selected = false;
    bool published = false, invalidated = false;
  };
  device* device_;
  std::atomic_bool active_{false};
  std::mutex mutex_;
  std::array<Entry, 12> entries_;
  uint32_t epoch_ = 0;
};
}  // namespace witcher3graphics::raytracing
