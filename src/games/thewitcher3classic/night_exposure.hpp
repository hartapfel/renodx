/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#pragma once

#include <algorithm>
#include <atomic>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <utility>
#include "presets.hpp"

namespace witcher3classic::night::exposure {

inline float enabled = presets::Default(presets::night, "NightAutoExposureEnabled");
inline float adaptation = presets::Default(presets::night, "NightExposureAdaptation");
inline float all_day = presets::Default(presets::night, "NightExposureAllDay");
inline std::atomic<bool> all_day_active = false;
inline constexpr float metering_anchor = 0.18f;
inline constexpr float smoothed_brightening_speed = presets::Default(presets::night, "NightExposureBrighteningSpeed");
inline constexpr float smoothed_darkening_speed = presets::Default(presets::night, "NightExposureDarkeningSpeed");
inline constexpr float smoothed_maximum_darkening = presets::Default(presets::night, "NightExposureMaximumDarkening");
inline constexpr float smoothed_maximum_brightening = presets::Default(presets::night, "NightExposureMaximumBrightening");
inline float brightening_speed = smoothed_brightening_speed, darkening_speed = smoothed_darkening_speed;
inline float maximum_darkening = smoothed_maximum_darkening;
inline float maximum_brightening = smoothed_maximum_brightening;
inline float fixed_luminance = presets::Default(presets::night, "NightExposureFixedLuminance");
inline std::atomic<float> brightening_scale = 1.f, darkening_scale = 1.f;
inline std::atomic<float> fixed_reference = 0.f;
inline std::atomic<float> darkening_range = 1.f;
inline std::atomic<float> brightening_range = 1.f;
inline bool supported = false;
inline uintptr_t rate_caller = 0;


// c4 and c9 are the first/second native exposure states. The latter is used
// during environment transitions, not the separate analytic grading upload.
inline constexpr std::pair<uint32_t, uint32_t> limit_uploads[] = {
    {24, 0xc56684}, {29, 0xc5675b}, {24, 0xc5675b},
};

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
  for (const auto& [slot, address] : limit_uploads) {
    if (first != slot || caller != static_cast<uintptr_t>(address)) continue;
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

// Classic 1.32 native b3 uploads. The adaptation draw was traced live to
// C52350/C5242B (PS 5622173C); c4/c9 limits feed all HDR tone-map variants.
inline bool Validate(const unsigned char* image, uint32_t size) {
  supported = false;
  rate_caller = 0;
  if (size < 0xc56760) return false;
  constexpr unsigned char setter[] = {0x48,0x89,0x5c,0x24,0x08,0x57,0x48,0x83,0xec,0x20};
  constexpr unsigned char rates[] = {0x41,0x8d,0x48,0x13,0x48,0xc7,0x44,0x24,0x48,0,0,0,0,
      0xf3,0x0f,0x11,0x44,0x24,0x40,0xf3,0x0f,0x11,0x4c,0x24,0x44};
  constexpr unsigned char shader[] = {0x48,0x8b,0x92,0x90,0x2a,0,0};
  constexpr unsigned char first[] = {0xf3,0x0f,0x10,0x83,0xbc,0x50,0,0,0xf3,0x0f,0x10,0x8b,0xdc,0x50,0,0};
  constexpr unsigned char second[] = {0xf3,0x0f,0x10,0x83,0x0c,0x87,0,0,0xf3,0x0f,0x10,0x8b,0x2c,0x87,0,0};
  constexpr unsigned char single[] = {0xf3,0x0f,0x10,0x83,0x6c,0x1a,0,0,0xf3,0x0f,0x10,0x8b,0x8c,0x1a,0,0};
  if (std::memcmp(image + 0x19f00, setter, sizeof(setter))
      || std::memcmp(image + 0xc5240d, rates, sizeof(rates))
      || std::memcmp(image + 0xc52441, shader, sizeof(shader))
      || std::memcmp(image + 0xc56653, first, sizeof(first))
      || std::memcmp(image + 0xc56689, second, sizeof(second))
      || std::memcmp(image + 0xc56724, single, sizeof(single))) return false;
  for (uint32_t caller : {0xc5242bu, 0xc56684u, 0xc5675bu}) {
    int32_t displacement;
    std::memcpy(&displacement, image + caller - 4, sizeof(displacement));
    if (image[caller - 5] != 0xe8 || int64_t(caller) + displacement != 0x19f00) return false;
  }
  rate_caller = 0xc5242b;
  supported = true;
  return true;
}
}  // namespace witcher3classic::night::exposure
