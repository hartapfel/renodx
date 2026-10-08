/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#ifndef SRC_GAMES_DARKERNIGHTS_REMASTERED_SKY_MOON_HLSLI_
#define SRC_GAMES_DARKERNIGHTS_REMASTERED_SKY_MOON_HLSLI_

#include "../shared.h"

float3 ScaleMoonPosition(float3 position, float3 extent, float3 minimum, uint size_bits) {
  if ((size_bits & WITCHER_MOON_TAG_MASK) == WITCHER_MOON_TAG) {
    float scale = float(size_bits & WITCHER_MOON_FACTOR_MASK) / WITCHER_MOON_FACTOR_SCALE;
    if (scale >= 0.01f && scale <= 5.f) {
      float3 center = minimum + 0.5f * extent;
      return center + (position - center) * scale;
    }
  }
  return position;
}

#endif  // SRC_GAMES_DARKERNIGHTS_REMASTERED_SKY_MOON_HLSLI_
