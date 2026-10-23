/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#include "../temporal/upscale_engine.hpp"
#include <array>
#include <cassert>
#include <cmath>
#include <iostream>
#include <set>

using namespace witcher3classic::temporal::upscale_engine;
alignas(16) std::array<uint8_t, 0xb5c0> submitted{};
alignas(16) std::array<uint8_t, 0x180> pool{};
alignas(16) std::array<uint8_t, 0x100> renderer{};
Plan plan{853, 480, 1280, 720, 1};
bool reconstruct = true, expect_scaled = true, temporal_seen = true;
unsigned render_calls = 0, post_calls = 0;
std::set<std::array<float, 2>> samples;

void Jitter(uint8_t* camera, float x, float y, uint32_t width, uint32_t height) {
  *reinterpret_cast<float*>(camera + 0x340) = x / width * 2.f;
  *reinterpret_cast<float*>(camera + 0x344) = y / height * 2.f;
  // Mock the native matrix rebuild. Geometry projection and CPU jitter shadow
  // must both originate from this call, not an NGX-only offset override.
  *reinterpret_cast<float*>(camera + 0x1a0) = -x / width * 2.f;
  *reinterpret_cast<float*>(camera + 0x1a4) = y / height * 2.f;
}

void Post(void*, void*, uint8_t* view, void*, uint32_t flags, int color) {
  ++post_calls;
  assert(flags == 0x123 && color == 28);
  assert(*reinterpret_cast<uint32_t*>(view + 0x818) == (expect_scaled && !reconstruct ? plan.width : 1280u));
  if (expect_scaled) assert(*reinterpret_cast<uint32_t*>(submitted.data() + 0xb420) == 1280);
  if (expect_scaled && reconstruct) {
    JitterHook(view + 0x10, 0.f, 0.f, 1280, 720);
    assert(*reinterpret_cast<float*>(view + 0x350) == 0.f);  // Postprocessing is outside the override.
  }
}
void Render(uint8_t* owner, uint8_t* frame, void* world) {
  ++render_calls;
  assert(owner == renderer.data() && frame == submitted.data());
  if (expect_scaled) {
    assert(active && active->plan == plan);
    assert(*reinterpret_cast<uint32_t*>(frame + 0x828) == plan.width);
    assert(*reinterpret_cast<uint32_t*>(frame + 0x82c) == plan.height);
    assert(*reinterpret_cast<uint32_t*>(pool.data() + 0x168) == 1280);
    for (const size_t offset : {0x20, 0x420}) {
      // The engine can set its two-position jitter again during rendering.
      JitterHook(frame + offset, 0.25f, -0.25f, 1280, 720);
      assert(*reinterpret_cast<float*>(frame + offset + 0x340) == active->jitter[0] / plan.width * 2.f);
      assert(*reinterpret_cast<float*>(frame + offset + 0x1a4) == active->jitter[1] / plan.height * 2.f);
    }
    std::array<uint8_t, 0x400> local_camera{};
    JitterHook(local_camera.data(), 0.f, 0.f, 1280, 720);
    assert(*reinterpret_cast<float*>(local_camera.data() + 0x340) == 0.f);
    assert(*reinterpret_cast<float*>(local_camera.data() + 0x344) == 0.f);
    for (const auto value : active->jitter) assert(value >= -0.5f && value <= 0.5f);
    samples.insert(active->jitter);
    active->temporal_seen = temporal_seen;
    active->reconstructed = reconstruct;
  } else assert(!active);
  PostHook(nullptr, nullptr, frame + 0x10, pool.data(), 0x123, 28);
}

int main() {
  render_function = Render;
  post_function = Post;
  jitter_function = Jitter;
  *reinterpret_cast<uint8_t**>(renderer.data() + 0x90) = pool.data();
  *reinterpret_cast<void**>(submitted.data() + 0x10) = submitted.data();
  submitted[0x824] = 1;
  for (const size_t offset : {0x828, 0xb420}) {
    *reinterpret_cast<uint32_t*>(submitted.data() + offset) = 1280;
    *reinterpret_cast<uint32_t*>(submitted.data() + offset + 4) = 720;
  }
  *reinterpret_cast<uint32_t*>(pool.data() + 0x168) = 1280;
  *reinterpret_cast<uint32_t*>(pool.data() + 0x16c) = 720;
  Jitter(submitted.data() + 0x20, 0.25f, -0.25f, 1280, 720);
  Jitter(submitted.data() + 0x420, -0.25f, 0.25f, 1280, 720);
  Publish(plan);
  RenderHook(renderer.data(), submitted.data(), pool.data());
  assert(!active && state->scaled_frames == 1 && state->reconstructed_frames == 1 && !state->failed);
  assert(*reinterpret_cast<uint32_t*>(submitted.data() + 0x828) == 1280);
  assert(*reinterpret_cast<float*>(submitted.data() + 0x360) == 0.5f / 1280.f);
  assert(*reinterpret_cast<float*>(submitted.data() + 0x764) == 0.5f / 720.f);

  // Menu omits TAA: suspend without latching. A native-size gameplay resolve
  // can publish the selected quality again without the user touching settings.
  reconstruct = false;
  temporal_seen = false;
  RenderHook(renderer.data(), submitted.data(), pool.data());
  assert(!active && !state->failed && state->plan.width == 0);
  assert(*reinterpret_cast<uint32_t*>(submitted.data() + 0x828) == 1280);
  expect_scaled = false;
  RenderHook(renderer.data(), submitted.data(), pool.data());
  Publish(plan);
  expect_scaled = reconstruct = temporal_seen = true;
  RenderHook(renderer.data(), submitted.data(), pool.data());
  assert(!state->failed && state->reconstructed_frames == 2);

  // Encountered-but-failed TAA remains a hard failure.
  reconstruct = false;
  RenderHook(renderer.data(), submitted.data(), pool.data());
  assert(!active && state->failed && state->plan.quality == 0);
  assert(*reinterpret_cast<uint32_t*>(submitted.data() + 0x828) == 1280);
  expect_scaled = false;
  Publish(plan);
  assert(state->plan.quality == 0);
  RenderHook(renderer.data(), submitted.data(), pool.data());

  Disable(true);
  Publish(plan);
  RenderHook(renderer.data(), submitted.data(), nullptr);  // Not a world view.
  submitted[0x830] = 1;
  RenderHook(renderer.data(), submitted.data(), pool.data());  // Offscreen view.
  submitted[0x830] = 0;
  *reinterpret_cast<uint32_t*>(submitted.data() + 0xb420) = 1920;
  RenderHook(renderer.data(), submitted.data(), pool.data());  // Resize/mismatched overlay.
  *reinterpret_cast<uint32_t*>(submitted.data() + 0xb420) = 1280;
  Publish({0, 480, 1280, 720, 1});
  assert(state->plan.quality == 0);
  RenderHook(renderer.data(), submitted.data(), pool.data());
  assert(render_calls == 10 && post_calls == 10);
  assert(state->scaled_frames == 4 && state->reconstructed_frames == 2);

  // DLAA and Ultra Performance both use the same correctly scoped camera
  // setter, with a longer cycle at the larger reconstruction ratio.
  expect_scaled = reconstruct = temporal_seen = true;
  for (const auto mode : {0u, 4u}) {
    plan = mode == 0 ? Plan{1280, 720, 1280, 720, 0} : Plan{427, 240, 1280, 720, 4};
    Publish(plan);
    samples.clear();
    const unsigned phases = mode == 0 ? 32 : 72;
    for (unsigned i = 0; i < phases; ++i) RenderHook(renderer.data(), submitted.data(), pool.data());
    assert(samples.size() == phases);
    RenderHook(renderer.data(), submitted.data(), pool.data());
    assert(samples.size() == phases);  // Exact bounded cycle.
  }
  Disable(true);
  assert(state->jitter_index == 0);
  std::cout << "PASS menu recovery, hard failure latch, scene/post scope, view/resize guards, 32/72-phase geometry jitter, unjittered-camera isolation and restoration\n";
}
