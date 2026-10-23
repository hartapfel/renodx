/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <format>
#include <windows.h>
#include <include/reshade.hpp>

namespace witcher3classic::temporal {
// Temporary, opt-in ablation sweep, never saved as a user setting. PresentMon
// supplies GPU busy times externally: inserting timestamps around every draw
// could itself serialize the workload we are trying to measure.
class MotionProfile {
 public:
  enum Probe { FULL, CAMERA_ONLY, SKIN, DEFORMED, RIGID, FOLIAGE, HISTORY_ONLY };
  static constexpr Probe probes[] = {FULL, CAMERA_ONLY, SKIN, DEFORMED, RIGID, FOLIAGE, HISTORY_ONLY, FULL};
  static constexpr const char* names[] = {"Full motion", "Camera only", "Skinned objects only", "Deformed meshes only",
                                         "Rigid objects only", "Foliage only", "All histories, native shaders"};
  std::atomic<bool> start = false, cancel = false;
  // -2 is the 15-second countdown; -1 is idle. Only Advance changes stages.
  std::atomic<int> stage = -1;

  Probe Current() const {
    const int value = stage.load(std::memory_order_relaxed);
    return value >= 0 ? probes[value] : FULL;
  }
  bool Accept(bool deformed, bool rigid, bool foliage) const {
    switch (Current()) {
      case CAMERA_ONLY: return false;
      case SKIN: return !deformed && !rigid && !foliage;
      case DEFORMED: return deformed;
      case RIGID: return rigid;
      case FOLIAGE: return foliage;
      default: return true;
    }
  }

  // Called at the main swapchain's frame boundary. No settings are modified;
  // abort/end immediately restores the normal path on the following frame.
  void Advance(bool eligible, int quality, int model, uint32_t width, uint32_t height,
               const std::array<uint32_t, 4>& draws) {
    const auto now = std::chrono::steady_clock::now();
    int value = stage.load(std::memory_order_relaxed);
    if (start.exchange(false)) {
      value = eligible ? -2 : -1;
      stage.store(value, std::memory_order_relaxed);
      selected_ = {quality, model, int(width), int(height)};
      began_ = now;
      frames_ = 0;
      counts_.fill(0);
      if (eligible) Log("countdown", -2);
    }
    if (cancel.exchange(false) || (value != -1 && (!eligible || selected_ != std::array{quality, model, int(width), int(height)}))) {
      if (value != -1) Log("aborted; full motion restored", value);
      stage.store(-1, std::memory_order_relaxed);
      return;
    }
    if (value == -1) return;
    const double elapsed = std::chrono::duration<double>(now - began_).count();
    // Exclude the first second after switching histories and shader families.
    if (value >= 0 && elapsed >= 1.0) {
      ++frames_;
      for (size_t i = 0; i < counts_.size(); ++i) counts_[i] += draws[i];
    }
    if (elapsed < (value == -2 ? 15.0 : 8.0)) return;
    if (value >= 0) {
      reshade::log::message(reshade::log::level::info,
          std::format("Witcher Classic motion profile: stage={} frames={} draws skin/cloth/rigid/foliage={}/{}/{}/{}",
                      value, frames_, counts_[0], counts_[1], counts_[2], counts_[3]).c_str());
    }
    value = value == -2 ? 0 : value + 1;
    if (value == int(std::size(probes))) {
      Log("complete; full motion restored", value);
      stage.store(-1, std::memory_order_relaxed);
    } else {
      stage.store(value, std::memory_order_relaxed);
      Log(names[probes[value]], value);
    }
    began_ = now;
    frames_ = 0;
    counts_.fill(0);
  }

 private:
  static void Log(const char* label, int stage) {
    LARGE_INTEGER ticks, frequency;
    QueryPerformanceCounter(&ticks);
    QueryPerformanceFrequency(&frequency);
    // PresentMon --qpc_time_ms uses this same clock; discard phase edges when
    // joining the log and ETW trace. These are CPU submission boundaries.
    reshade::log::message(reshade::log::level::info,
        std::format("Witcher Classic motion profile: boundary stage={} qpc_ms={:.6f} {}",
                    stage, double(ticks.QuadPart) * 1000.0 / double(frequency.QuadPart), label).c_str());
  }
  std::chrono::steady_clock::time_point began_;
  std::array<int, 4> selected_ = {};
  std::array<uint64_t, 4> counts_ = {};
  uint64_t frames_ = 0;
};
inline MotionProfile motion_profile;
}  // namespace witcher3classic::temporal
