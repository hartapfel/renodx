/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#ifndef SRC_GAMES_DARKERNIGHTS_REMASTERED_SKY_CELESTIAL_HLSLI_
#define SRC_GAMES_DARKERNIGHTS_REMASTERED_SKY_CELESTIAL_HLSLI_

#include "../shared.h"

float3 ScaleCelestialPosition(float3 position, float3 extent, float3 minimum, uint size_bits, uint tag, uint tag_mask = WITCHER_CELESTIAL_TAG_MASK) {
  if ((size_bits & tag_mask) == tag) {
    float scale = float(size_bits & WITCHER_CELESTIAL_FACTOR_MASK) / WITCHER_CELESTIAL_FACTOR_SCALE;
    if (scale >= 0.01f && scale <= 5.f && scale != 1.f) {
      float3 center = minimum + 0.5f * extent;
      return center + (position - center) * scale;
    }
  }
  return position;
}

// The paired moon pixel shaders do not use TEXCOORD0.x. Carry brightness
// there so no pixel-stage constant buffer or root binding needs to be added.
float MoonBrightness(uint moon_bits) {
  if ((moon_bits & WITCHER_MOON_TAG_MASK) == WITCHER_MOON_TAG) {
    return float((moon_bits >> WITCHER_MOON_BRIGHTNESS_SHIFT) & WITCHER_MOON_BRIGHTNESS_MASK)
        / WITCHER_MOON_BRIGHTNESS_SCALE;
  }
  return 1.f;
}

#endif  // SRC_GAMES_DARKERNIGHTS_REMASTERED_SKY_CELESTIAL_HLSLI_
