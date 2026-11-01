/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <algorithm>
#include <array>
#include <atomic>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <utility>

#include "../../utils/pe_image.hpp"
#include "./night_grading.hpp"

namespace witcher::night::exposure {

inline float enabled = 1.f, adaptation = 0.f;
inline float all_day = 0.f;
inline std::atomic<bool> all_day_active = false;
inline constexpr float metering_anchor = 0.18f;
inline constexpr float smoothed_brightening_speed = 35.f, smoothed_darkening_speed = 5.f;
inline constexpr float smoothed_maximum_darkening = 100.f, smoothed_maximum_brightening = 100.f;
inline float brightening_speed = smoothed_brightening_speed, darkening_speed = smoothed_darkening_speed;
inline float maximum_darkening = smoothed_maximum_darkening;
inline float maximum_brightening = smoothed_maximum_brightening;
inline float fixed_luminance = metering_anchor;
inline std::atomic<float> brightening_scale = 1.f, darkening_scale = 1.f;
inline std::atomic<float> fixed_reference = 0.f;
inline std::atomic<float> darkening_range = 1.f;
inline std::atomic<float> brightening_range = 1.f;
inline bool supported = false;
inline uintptr_t rate_caller = 0;
inline int32_t caller_offset = 0;

// c4 and c9 are the first/second native exposure states. The latter is used
// during environment transitions, not the separate analytic grading upload.
inline constexpr std::pair<uint32_t, uint32_t> limit_uploads[] = {
    {24, 0x34e3f3},
    {29, 0x34e42b},
    {24, 0x34e56c},
};
inline std::array<uint32_t, 3> resolved_limit_uploads{};

inline void Update(bool active) {
  float up = 1.f, down = 1.f, reference = 0.f, range = 1.f, boost = 1.f;
  if (active && enabled == 0.f && std::isfinite(fixed_luminance)) {
    reference = std::clamp(fixed_luminance, 0.001f, 10.f);
  } else if (active && enabled == 1.f) {
    if (adaptation == 1.f) {
      up = smoothed_brightening_speed / 100.f;
      down = smoothed_darkening_speed / 100.f;
      range = smoothed_maximum_darkening / 100.f;
      boost = smoothed_maximum_brightening / 100.f;
    } else if (adaptation == 2.f) {
      if (std::isfinite(brightening_speed)) up = std::clamp(brightening_speed / 100.f, 0.01f, 2.f);
      if (std::isfinite(darkening_speed)) down = std::clamp(darkening_speed / 100.f, 0.01f, 2.f);
      if (std::isfinite(maximum_darkening)) range = std::clamp(maximum_darkening / 100.f, 0.f, 1.f);
      if (std::isfinite(maximum_brightening)) boost = std::clamp(maximum_brightening / 100.f, 0.f, 1.f);
    }
  }
  brightening_scale.store(up, std::memory_order_relaxed);
  darkening_scale.store(down, std::memory_order_relaxed);
  fixed_reference.store(reference, std::memory_order_relaxed);
  darkening_range.store(range, std::memory_order_relaxed);
  brightening_range.store(boost, std::memory_order_relaxed);
  all_day_active.store(active && all_day == 1.f, std::memory_order_relaxed);
}

// Edit only fresh uploads at validated callers. Native/scheduled daytime paths are
// byte-identical, and c4/c9.xw (curve selector and metadata) remain untouched.
inline bool AdjustConstants(uint32_t first, float* values, uintptr_t caller, float weight) {
  if (!supported || !std::isfinite(weight) || weight < 0.f || weight > 1.f) return false;
  if (all_day_active.load(std::memory_order_relaxed)) weight = 1.f;
  if (weight == 0.f) return false;
  if (first == 20 && caller == rate_caller) {
    const float scales[] = {brightening_scale.load(std::memory_order_relaxed),
                            darkening_scale.load(std::memory_order_relaxed)};
    for (unsigned i = 0; i < 2; ++i) {
      if (!std::isfinite(values[i]) || values[i] < 0.f || values[i] > 1.f) return false;
    }
    bool changed = false;
    for (unsigned i = 0; i < 2; ++i) {
      const float scale = 1.f + (scales[i] - 1.f) * weight;
      if (scale == 1.f || values[i] == 0.f || values[i] == 1.f) continue;
      // Native alpha = 1-exp(-0.5*dt*speed). Scaling its exponent preserves
      // frame-time compensation; multiplying alpha would not.
      values[i] = -std::expm1(std::log1p(-values[i]) * scale);
      changed = true;
    }
    return changed;
  }
  const float reference = fixed_reference.load(std::memory_order_relaxed);
  const float range = darkening_range.load(std::memory_order_relaxed);
  const float boost = brightening_range.load(std::memory_order_relaxed);
  if (reference == 0.f && range == 1.f && boost == 1.f) return false;
  for (unsigned i = 0; i < std::size(limit_uploads); ++i) {
    const auto& [slot, address] = limit_uploads[i];
    const uintptr_t expected = resolved_limit_uploads[i] != 0
                                   ? resolved_limit_uploads[i]
                                   : static_cast<uintptr_t>(int64_t(address) + caller_offset);
    if (first != slot || caller != expected) continue;
    if (!std::isfinite(values[1]) || !std::isfinite(values[2]) || values[1] > values[2]) return false;
    if (reference == 0.f) {
      // Exposure gain is a power of metered luminance. Interpolate its
      // limits logarithmically to scale each side in stops relative to 0.18.
      float floor = values[1], ceiling = values[2];
      const float amount = 1.f + (range - 1.f) * weight;
      if (amount != 1.f && values[2] > metering_anchor) {
        ceiling = amount == 0.f ? metering_anchor
                                : std::min(values[2], static_cast<float>(metering_anchor * std::pow(double(values[2]) / metering_anchor, amount)));
        floor = std::min(floor, ceiling);
      }
      const float lift = 1.f + (boost - 1.f) * weight;
      if (lift != 1.f && values[1] < metering_anchor) {
        // The shader already floors the final metered value at 1e-4. Use
        // that effective endpoint when the native minimum is zero/negative.
        floor = lift == 0.f ? metering_anchor
                            : std::max(values[1], static_cast<float>(metering_anchor * std::pow(double(std::max(values[1], 0.0001f)) / metering_anchor, lift)));
        ceiling = std::max(ceiling, floor);
      }
      if (floor == values[1] && ceiling == values[2]) return false;
      values[1] = floor;
      values[2] = ceiling;
      return true;
    }
    // Equal metering limits remove dependence on adapted luminance, just as
    // the native fixed-luminance variant does. Retain dynamic shader routing
    // so another HDR addon still sees its normal tone-map pass and bindings.
    for (unsigned i : {1u, 2u}) {
      values[i] = weight == 1.f ? reference : values[i] + (reference - values[i]) * weight;
    }
    return true;
  }
  return false;
}

inline constexpr unsigned char RATE_UPLOAD[] = {
    0xb9, 0x14, 0x00, 0x00, 0x00,
    0xc5, 0x7a, 0x11, 0x54, 0x24, 0x30, 0xc5, 0xfa, 0x11, 0x7c, 0x24, 0x34,
    0xc5, 0xfa, 0x11, 0x74, 0x24, 0x38, 0xc5, 0xfa, 0x11, 0x74, 0x24, 0x3c, 0xe8};

inline bool Validate(const unsigned char* image, uint32_t setter_rva, int32_t grade_offset) {
  supported = false;
  rate_caller = 0;
  resolved_limit_uploads = {};
  const renodx::utils::pe::Image executable(image);
  const uint32_t image_size = executable.size;
  if (!executable.Match(setter_rva, grading::PIXEL_CONSTANTS_PREFIX)) return false;
  // Resolve this upload independently: its code can move separately from the
  // environment and grading builders without changing its native contract.
  if (const uint32_t address = executable.FindUnique({{0, RATE_UPLOAD}})) {
    const uint32_t caller = address + sizeof(RATE_UPLOAD) + 4;
    if (executable.Relative(address + sizeof(RATE_UPLOAD) - 1, 1, 5) == setter_rva) rate_caller = caller;
  }
  if (rate_caller == 0) return false;
  // Confirm the actual environment-luminance loads, not just reused slots.
  constexpr unsigned char loads[][16] = {
      {0xc5, 0xfa, 0x10, 0x86, 0xbc, 0x69, 0, 0, 0xc5, 0xfa, 0x10, 0x8e, 0xdc, 0x69, 0, 0},
      {0xc5, 0xfa, 0x10, 0x86, 0x4c, 0xb3, 0, 0, 0xc5, 0xfa, 0x10, 0x8e, 0x6c, 0xb3, 0, 0},
      {0xc5, 0xfa, 0x10, 0x8e, 0x2c, 0x20, 0, 0},
  };
  constexpr uint32_t distances[] = {0x3b, 0x38, 0x3f};
  for (unsigned i = 0; i < 3; ++i) {
    constexpr unsigned char call[] = {0xe8};
    const uint32_t source = executable.FindUnique({{0, std::span(loads[i]).first(i == 2 ? 8 : 16)},
                                                   {distances[i] - 5, call}});
    if (!source) return false;
    const uint32_t address = source + distances[i];
    if (address > image_size || executable.Relative(address - 5, 1, 5) != setter_rva) return false;
    resolved_limit_uploads[i] = address;
  }
  constexpr unsigned char last_max[] = {0xc5, 0xfa, 0x10, 0x86, 0x4c, 0x20, 0, 0};
  if (!executable.Match(resolved_limit_uploads[2] - 0x26, last_max)) return false;
  caller_offset = grade_offset;
  supported = true;
  return true;
}
}  // namespace witcher::night::exposure
