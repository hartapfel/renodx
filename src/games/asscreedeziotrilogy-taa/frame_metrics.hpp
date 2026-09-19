/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>

namespace acbrotherhood::presentation {
// One sample per completed game frame. Output counts come from the FG runtime,
// not the requested multiplier. This measures throughput, not display scanout.
struct FrameMetrics {
  static constexpr unsigned capacity = 240;
  struct Sample { float milliseconds = 0; uint32_t outputs = 0; };
  struct Summary {
    double rendered_fps = 0, output_fps = 0;
    float average_ms = 0, p95_ms = 0, maximum_ms = 0;
    unsigned samples = 0;
  };
  std::array<Sample, capacity> history{};
  unsigned next = 0, count = 0;
  double previous_seconds = 0;

  void Add(double now, uint32_t outputs) {
    if (!std::isfinite(now) || now <= 0) { *this = {}; return; }
    const double elapsed = (now - previous_seconds) * 1000;
    const bool first = previous_seconds == 0;
    previous_seconds = now;
    if (first) return;
    if (elapsed <= 0 || elapsed > 1000) {
      *this = {}; previous_seconds = now; return;
    }
    history[next] = {float(elapsed), outputs};
    next = (next + 1) % capacity;
    count = std::min(count + 1, capacity);
  }
  bool Fresh(double now) const { return count && now >= previous_seconds && now - previous_seconds < 1; }
  Summary Summarize() const {
    Summary result;
    std::array<float, capacity> sorted{};
    double elapsed = 0;
    uint64_t outputs = 0;
    // About one second of real samples, including pauses or missing outputs.
    for (unsigned i = 0; i < count && elapsed < 1000; ++i) {
      const auto& sample = history[(next + capacity - 1 - i) % capacity];
      sorted[result.samples++] = sample.milliseconds;
      elapsed += sample.milliseconds; outputs += sample.outputs;
    }
    if (!result.samples || elapsed <= 0) return result;
    result.rendered_fps = 1000.0 * result.samples / elapsed;
    result.output_fps = 1000.0 * outputs / elapsed;
    result.average_ms = float(elapsed / result.samples);
    std::sort(sorted.begin(), sorted.begin() + result.samples);
    result.p95_ms = sorted[(result.samples - 1) * 95 / 100];
    for (unsigned i = 0; i < count; ++i) result.maximum_ms = std::max(result.maximum_ms, history[i].milliseconds);
    return result;
  }
};
}  // namespace acbrotherhood::presentation
