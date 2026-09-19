/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#define NOMINMAX
#include <windows.h>
#include <cassert>
#include <cmath>
#include <iostream>
#include "../../presentation_pacing.hpp"
#include "../../frame_metrics.hpp"
#include "../display_policy.hpp"
int main() {
  using namespace acbrotherhood::presentation;
  auto state = CalculatePacing({2, 60}, 2, 5, 1);
  assert(state.mode == 1 && state.interval_us == 16667 && state.sync_interval == 1);
  assert(ReflexInterval(state.interval_us, 3) == 5556);
  assert(ReflexInterval(state.interval_us, 1) == 16667);
  state = CalculatePacing({2, 0}, 0, 5, 2);
  assert(state.mode == 2 && state.interval_us == 0 && state.sync_interval == 2);
  state = CalculatePacing({0, 60}, 5, 1, 0);
  assert(state.mode == 1 && state.multiplier == 1 && state.interval_us == 16667 && !state.sync_interval);
  state = CalculatePacing({0, 60}, 0, 0, 0);
  assert(state.mode == 0 && state.interval_us == 16667);
  // Feed driver snapshots directly: tests never change the user's profile.
  DisplayPolicy display(GetCurrentProcess());
  Packet packet;
  display.published = {VSYNCMODE_FORCEON, VRR_MODE_FULLSCREEN_ONLY, 240, true};
  for (uint32_t multiplier : {1u, 2u, 3u, 6u}) {
    packet.pacing_state = CalculatePacing({1, 0}, multiplier - 1, 5, 0);
    packet.pacing_state.driver_multiplier = multiplier;
    display.Apply(&packet);
    assert(packet.pacing_state.sync_interval == 1 && packet.pacing_state.driver_interval_us == 4467);
  }
  packet.pacing_state = CalculatePacing({1, 60}, 2, 5, 0);
  packet.pacing_state.driver_interval_us = ReflexInterval(packet.pacing_state.interval_us, 3);
  display.Apply(&packet);
  assert(packet.pacing_state.driver_interval_us == 5556);  // 60 rendered / 180 displayed.
  display.published.refresh_hz = 144;
  packet.pacing_state = CalculatePacing({1, 0}, 2, 5, 0);
  display.Apply(&packet);
  assert(packet.pacing_state.driver_interval_us == 7245);
  display.published.vsync = VSYNCMODE_FORCEOFF;
  packet.pacing_state = CalculatePacing({1, 0}, 2, 5, 1);
  display.Apply(&packet);
  assert(!packet.pacing_state.sync_interval && !packet.pacing_state.driver_interval_us);
  display.published.vsync = VSYNCMODE_PASSIVE;
  packet.pacing_state = CalculatePacing({1, 0}, 2, 5, 0);
  display.Apply(&packet);
  assert(!packet.pacing_state.sync_interval && !packet.pacing_state.driver_interval_us);
  display.published.vrr = false;
  packet.pacing_state = CalculatePacing({1, 0}, 2, 5, 1);
  display.Apply(&packet);
  assert(packet.pacing_state.sync_interval == 1 && !packet.pacing_state.driver_interval_us);
  display.published.vrr = true;
  packet.pacing_state = CalculatePacing({0, 0}, 0, 5, 1);
  display.Apply(&packet);
  assert(!packet.pacing_state.mode && !packet.pacing_state.driver_interval_us);
  FrameMetrics metrics;
  for (unsigned i = 0; i <= 300; ++i) metrics.Add(1.0 + i / 60.0, 3);
  auto summary = metrics.Summarize();
  assert(metrics.count == 240 && std::abs(summary.rendered_fps - 60) < .001);
  assert(std::abs(summary.output_fps - 180) < .001 && metrics.Fresh(6.1) && !metrics.Fresh(7.1));
  metrics = {}; metrics.Add(1, 1); metrics.Add(1.01, 3); metrics.Add(1.04, 1); metrics.Add(1.05, 0);
  summary = metrics.Summarize();
  assert(std::abs(summary.rendered_fps - 60) < .001 && std::abs(summary.output_fps - 80) < .001);
  metrics.Add(3, 3); assert(!metrics.count); metrics.Add(3.02, 1); assert(metrics.count == 1);
  metrics.Add(2, 1); assert(!metrics.count);
  std::cout << "Reflex policy and measured frame telemetry passed.\n";
}
