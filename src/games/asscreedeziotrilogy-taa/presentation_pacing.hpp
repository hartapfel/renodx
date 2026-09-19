/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <cstdint>

namespace acbrotherhood::presentation {
struct PacingSettings {
  uint32_t reflex_mode = 1;  // Off / On / On + Boost. FG locks this to On.
  uint32_t render_fps = 0;   // 0: no user cap, otherwise BEFORE frame generation.
};
struct PacingState {
  uint32_t available = 0, mode = 0, interval_us = 0, error = 0;
  uint32_t multiplier = 1, sync_interval = 0;
  uint32_t driver_interval_us = 0, driver_multiplier = 1;
};

// The only user cap is the simulation rate. Preserve the source VSync interval;
// Reflex/the driver own display synchronization and any driver-imposed ceiling.
inline PacingState CalculatePacing(const PacingSettings& settings, uint32_t generated,
                                   uint32_t maximum, uint32_t source_sync) {
  PacingState result;
  result.mode = generated ? 1 : settings.reflex_mode;
  result.multiplier = maximum && generated > maximum ? 1 : generated + 1;
  result.sync_interval = source_sync;
  if (settings.render_fps) result.interval_us = (1000000u + settings.render_fps - 1) / settings.render_fps;
  return result;
}
// Reflex's driver limiter measures the post-FG cadence. Only convert using
// the previous Present's confirmed multiplier; selected FG may be paused.
inline uint32_t ReflexInterval(uint32_t rendered_interval_us, uint32_t presented_multiplier) {
  return (rendered_interval_us + presented_multiplier - 1) / presented_multiplier;
}
}  // namespace acbrotherhood::presentation
