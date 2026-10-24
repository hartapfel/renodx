/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstring>
#include <mutex>
#include "../blitzfx/compatibility.hpp"

namespace witcher3classic::temporal::upscale_engine {
// Classic's ForcedRendererResolution path uses a smaller top-left viewport in
// an output-sized pool. Keep those allocations: shadows, UI and postprocessing
// share the pool. Change only the submitted primary view on the render thread.
struct Plan {
  uint32_t width = 0, height = 0, output_width = 0, output_height = 0;
  uint32_t quality = 0;
  bool operator==(const Plan&) const = default;
};
struct State {
  std::mutex mutex;
  Plan plan;
  bool failed = false;
  uint32_t jitter_index = 0;
  uint64_t scaled_frames = 0, reconstructed_frames = 0;
};
// These hooks are pinned with the object-history hooks and may outlive ReShade.
// No GPU objects or callbacks into device state are retained here.
inline State* state = new State;
struct Frame {
  uint8_t* view;
  Plan plan;
  std::array<float, 2> jitter{};
  bool temporal_seen = false;
  bool reconstructed = false;
  bool post_restored = false;
};
inline thread_local Frame* active = nullptr;
using RenderFunction = void (*)(uint8_t*, uint8_t*, void*);
using PostFunction = void (*)(void*, void*, uint8_t*, void*, uint32_t, int);
using JitterFunction = void (*)(uint8_t*, float, float, uint32_t, uint32_t);
inline RenderFunction render_function = nullptr;
inline PostFunction post_function = nullptr;
inline JitterFunction jitter_function = nullptr;

inline float Halton(uint32_t index, uint32_t base) {
  float result = 0.f, fraction = 1.f;
  while (index) {
    fraction /= static_cast<float>(base);
    result += fraction * static_cast<float>(index % base);
    index /= base;
  }
  return result - 0.5f;
}

inline void JitterHook(uint8_t* camera, float x, float y, uint32_t width, uint32_t height) {
  // Native reprojection also calls this setter on an UNJITTERED local camera.
  // Only override the two cameras owned by the active submitted primary view.
  if (active && !active->post_restored
      && (camera == active->view + 0x10 || camera == active->view + 0x410)) {
    x = active->jitter[0];
    y = active->jitter[1];
    width = active->plan.width;
    height = active->plan.height;
  }
  jitter_function(camera, x, y, width, height);
}

inline void Publish(const Plan& plan) {
  std::lock_guard lock(state->mutex);
  if (plan.quality > 4 || !plan.width || !plan.height
      || plan.width > plan.output_width || plan.height > plan.output_height
      || plan.output_width > 8192 || plan.output_height > 8192
      || uint64_t{plan.output_width} * plan.output_height > 8388608) {
    state->plan = {};
    return;
  }
  if (plan.quality == 0) state->failed = false;
  if (state->failed) return;
  if (state->plan != plan) state->jitter_index = 0;
  state->plan = plan;
}
inline void Disable(bool reset_failure = false) {
  std::lock_guard lock(state->mutex);
  state->plan = {};
  state->jitter_index = 0;
  if (reset_failure) state->failed = false;
}

inline void RenderHook(uint8_t* renderer, uint8_t* submitted, void* world) {
  const blitzfx::ScopedTemporalOwner temporal_owner(!active && world && submitted
      && *reinterpret_cast<void**>(submitted + 0x10) && submitted[0x830] == 0 && submitted[0x824] != 0);
  Plan plan;
  {
    std::lock_guard lock(state->mutex);
    plan = state->plan;
  }
  // Main world view only. Offscreen/cubemap/thumbnail views, custom viewports,
  // resized swapchains and recursive renders pass through without modification.
  const auto* pool = *reinterpret_cast<const uint8_t* const*>(renderer + 0x90);
  if (active || !plan.width || !world || !submitted || !pool
      || !*reinterpret_cast<void**>(submitted + 0x10) || submitted[0x830] != 0
      || submitted[0x824] == 0
      || *reinterpret_cast<const uint32_t*>(submitted + 0x828) != plan.output_width
      || *reinterpret_cast<const uint32_t*>(submitted + 0x82c) != plan.output_height
      || *reinterpret_cast<const uint32_t*>(submitted + 0xb420) != plan.output_width
      || *reinterpret_cast<const uint32_t*>(submitted + 0xb424) != plan.output_height
      || *reinterpret_cast<const uint32_t*>(pool + 0x168) != plan.output_width
      || *reinterpret_cast<const uint32_t*>(pool + 0x16c) != plan.output_height) {
    render_function(renderer, submitted, world);
    return;
  }
  Frame frame{submitted + 0x10, plan};
  {
    std::lock_guard lock(state->mutex);
    // NVIDIA: eight phases per output/input pixel-area ratio. Use at least
    // 32 for better coverage in DLAA/Quality; Ultra Performance uses 72+.
    const uint64_t input_pixels = uint64_t{plan.width} * plan.height;
    const uint32_t phases = static_cast<uint32_t>(std::clamp<uint64_t>(
        (8 * uint64_t{plan.output_width} * plan.output_height + input_pixels - 1) / input_pixels, 32, 1024));
    const uint32_t index = state->jitter_index++ % phases + 1;
    frame.jitter = {Halton(index, 2), Halton(index, 3)};
  }
  std::array<std::array<float, 2>, 2> saved_jitter;
  constexpr size_t cameras[] = {0x10, 0x410};
  for (size_t i = 0; i < std::size(cameras); ++i)
    std::memcpy(saved_jitter[i].data(), frame.view + cameras[i] + 0x340, sizeof(saved_jitter[i]));
  active = &frame;
  *reinterpret_cast<uint32_t*>(frame.view + 0x818) = plan.width;
  *reinterpret_cast<uint32_t*>(frame.view + 0x81c) = plan.height;
  for (const size_t offset : cameras)
    JitterHook(frame.view + offset, 0.f, 0.f, plan.width, plan.height);
  render_function(renderer, submitted, world);
  // Restore the owned descriptor even when native rendering exits early or
  // omits TAA. Never alter global renderer settings or the submission source.
  *reinterpret_cast<uint32_t*>(frame.view + 0x818) = plan.output_width;
  *reinterpret_cast<uint32_t*>(frame.view + 0x81c) = plan.output_height;
  active = nullptr;
  for (size_t i = 0; i < std::size(cameras); ++i) {
    if (std::memcmp(saved_jitter[i].data(), frame.view + cameras[i] + 0x340, sizeof(saved_jitter[i])))
      jitter_function(frame.view + cameras[i], saved_jitter[i][0] * 0.5f, saved_jitter[i][1] * 0.5f, 1, 1);
  }
  std::lock_guard lock(state->mutex);
  ++state->scaled_frames;
  if (frame.reconstructed && frame.post_restored) ++state->reconstructed_frames;
  else {
    // Menus/loading can legitimately omit TAA. Suspend the reduced viewport,
    // then rearm after a successful native-size gameplay resolve. Only an
    // encountered-but-broken reconstruction boundary is a latched failure.
    state->failed = frame.temporal_seen;
    state->plan = {};
  }
}

inline void PostHook(void* post, void* context, uint8_t* view, void* pool, uint32_t flags, int color) {
  // C48810 has finished TAA before C4D150 begins final grading. The native TAA
  // pool surface now contains full-resolution DLSS output. Restore dimensions
  // before optional sharpening, final grading, thumbnail capture and UI.
  if (active && active->view == view && active->reconstructed) {
    *reinterpret_cast<uint32_t*>(view + 0x818) = active->plan.output_width;
    *reinterpret_cast<uint32_t*>(view + 0x81c) = active->plan.output_height;
    active->post_restored = true;
  }
  post_function(post, context, view, pool, flags, color);
}

inline bool Verify(uintptr_t image) {
  constexpr uint8_t render[] = {72,139,196,76,137,64,24,72,137,80,16,85,83,86,87,65,84,65,85,65,86,65,87,72};
  constexpr uint8_t post[] = {72,137,92,36,16,76,137,76,36,32,85,86,87,65,84,65,85,65,86,65,87,72,141,108};
  constexpr uint8_t jitter[] = {15,87,192,65,139,193,243,72,15,42,192,139,68,36,40,243,15,94,200,15,87,192,243,72};
  constexpr uint8_t matrices[] = {72,139,196,72,137,88,8,72,137,112,16,72,137,120,24,76,137,96,32,85,65,86,65,87};
  if (std::memcmp(reinterpret_cast<void*>(image + 0xc1c910), render, sizeof(render))
      || std::memcmp(reinterpret_cast<void*>(image + 0xc4d150), post, sizeof(post))
      || std::memcmp(reinterpret_cast<void*>(image + 0x1f4360), jitter, sizeof(jitter))
      || std::memcmp(reinterpret_cast<void*>(image + 0x1f43b0), matrices, sizeof(matrices))) return false;
  render_function = reinterpret_cast<RenderFunction>(image + 0xc1c910);
  post_function = reinterpret_cast<PostFunction>(image + 0xc4d150);
  jitter_function = reinterpret_cast<JitterFunction>(image + 0x1f4360);
  return true;
}
}  // namespace witcher3classic::temporal::upscale_engine
