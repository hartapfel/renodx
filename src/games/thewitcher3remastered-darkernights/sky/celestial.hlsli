/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#ifndef SRC_GAMES_DARKERNIGHTS_REMASTERED_SKY_CELESTIAL_HLSLI_
#define SRC_GAMES_DARKERNIGHTS_REMASTERED_SKY_CELESTIAL_HLSLI_

#include "../shared.h"

float3 ScaleCelestialPosition(float3 position, float3 extent, float3 minimum, uint size_bits, uint tag) {
  if ((size_bits & WITCHER_CELESTIAL_TAG_MASK) == tag) {
    float scale = float(size_bits & WITCHER_CELESTIAL_FACTOR_MASK) / WITCHER_CELESTIAL_FACTOR_SCALE;
    if (scale >= 0.01f && scale <= 5.f) {
      float3 center = minimum + 0.5f * extent;
      return center + (position - center) * scale;
    }
  }
  return position;
}

#endif  // SRC_GAMES_DARKERNIGHTS_REMASTERED_SKY_CELESTIAL_HLSLI_
