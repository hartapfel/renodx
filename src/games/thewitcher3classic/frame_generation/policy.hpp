/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <cmath>
#include <cstdint>

namespace witcher3classic::frame_generation {
enum class Mode : uint32_t { Off,
                             Fixed,
                             Auto,
                             Dynamic };
struct Request {
  Mode mode = Mode::Off;
  uint32_t multiplier = 2;  // Displayed total, including the rendered frame.
  float target_fps = 0;     // Dynamic mode: zero follows the display.
  bool recompose_ui = false;
};
struct Capabilities {
  bool supported = false, dynamic = false, reflex_available = false;
  uint32_t max_generated = 0, min_dimension = 0;
};
struct Frame {
  bool presenter_ready = false, hdr10 = false, inputs_valid = false;
  bool gameplay = false, transitioning = false, hud_valid = false;  // Current pre-UI scene; alpha is optional.
  bool reflex_active = false, runtime_ok = false;
  uint32_t width = 0, height = 0;
};
struct Decision {
  Mode mode = Mode::Off;
  uint32_t generated = 0;
  float target_fps = 0;
  bool recompose_ui = false;
  const char* reason = "Off";
};

// Fails closed. Device support does not prove a working presentation/input/
// latency integration. No GPU-generation heuristics and no silently inflated
// multipliers; limits are from slDLSSGGetState on the actual adapter.
inline Decision Resolve(const Request& request, const Capabilities& capabilities, const Frame& frame) {
  if (request.mode == Mode::Off) return {};
  if (!frame.presenter_ready) return {.reason = "Frame Generation presentation is not connected yet"};
  if (!capabilities.supported || !capabilities.max_generated) return {.reason = "Frame Generation is unavailable on this system"};
  if (!capabilities.reflex_available) return {.reason = "NVIDIA Reflex is unavailable"};
  if (!frame.reflex_active) return {.reason = "Waiting for a gameplay simulation and render frame"};
  if (!frame.runtime_ok) return {.reason = "Frame Generation runtime reported an error"};
  if (!frame.hdr10) return {.reason = "HDR10 output is required"};
  if (frame.transitioning || !frame.gameplay) return {.reason = "Paused during menus, loading or display changes"};
  if (!frame.inputs_valid || !frame.hud_valid) return {.reason = "Waiting for a complete scene and HUD frame"};
  if (!frame.width || !frame.height || frame.width < capabilities.min_dimension || frame.height < capabilities.min_dimension)
    return {.reason = "Output resolution is below the Frame Generation minimum"};
  if (request.mode == Mode::Dynamic) {
    if (!capabilities.dynamic) return {.reason = "Dynamic Multi Frame Generation is unavailable"};
    if (!std::isfinite(request.target_fps) || request.target_fps < 0.f) return {.reason = "Invalid target frame rate"};
    return {Mode::Dynamic, 0, request.target_fps, request.recompose_ui, "Dynamic"};
  }
  if (request.mode != Mode::Fixed && request.mode != Mode::Auto) return {.reason = "Invalid Frame Generation mode"};
  if (request.multiplier < 2 || request.multiplier - 1 > capabilities.max_generated)
    return {.reason = "Selected multiplier is unavailable"};
  return {request.mode, request.multiplier - 1, 0, request.recompose_ui, request.mode == Mode::Auto ? "Auto" : "Fixed"};
}
}  // namespace witcher3classic::frame_generation
