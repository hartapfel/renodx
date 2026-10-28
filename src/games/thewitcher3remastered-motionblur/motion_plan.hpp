/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#pragma once
#include <array>
#include <cstdint>
#include "motion_blur_config.h"
namespace witcher::motion {
struct Settings {
  float interval = 0, strength = 1;
  uint32_t mode = 0, stage = 0;
  uint32_t output_width = 0, output_height = 0, motion_width = 0, motion_height = 0;
  uint32_t source = 0, target = 0, second = 0, bake = 0;
  uint32_t source_width = 0, source_height = 0, target_width = 0, target_height = 0;
  uint32_t velocity = 0, neighbor = 0, reserved[2] = {};
};
static_assert(sizeof(Settings) == 80);
struct Plan {
  std::array<Settings, 12> stages;
  uint64_t bytes;
  explicit Plan(Settings settings) {
  uint32_t offset = WITCHER_MOTION_HEADER;
  uint32_t width = settings.motion_width, height = settings.motion_height;
  uint32_t previous = 0;
  for (uint32_t stage = 0; stage <= 6; ++stage) {
    settings.source_width = width; settings.source_height = height;
    if (stage > 0 && stage < 6) { width = (width + 1) / 2; height = (height + 1) / 2; }
    settings.stage = stage; settings.source = previous; settings.target = offset;
    settings.target_width = width; settings.target_height = height;
    stages[stage] = settings;
    previous = offset;
    offset += width * height;
  }
  settings.velocity = WITCHER_MOTION_HEADER;
  settings.neighbor = previous;
  settings.bake = offset;
  width = (settings.output_width + 1) / 2; height = (settings.output_height + 1) / 2;
  const uint32_t half_pixels = width * height;
  const uint32_t half_a = offset + half_pixels, half_b = half_a + half_pixels;
  settings.target_width = width; settings.target_height = height;
  settings.source_width = width; settings.source_height = height;
  for (uint32_t stage = 7; stage <= 11; ++stage) {
    settings.stage = stage;
    settings.source = stage == 10 ? half_b : half_a;
    settings.target = stage == 7 ? settings.bake : stage == 9 ? half_b : half_a;
    if (stage == 11) { settings.target_width = settings.output_width; settings.target_height = settings.output_height; }
    stages[stage] = settings;
  }
    bytes = uint64_t(offset + 3u * half_pixels) * 16u;
  }
};
} // namespace witcher::motion
