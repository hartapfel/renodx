#ifndef WITCHER_NIGHT_CLOUD_COMMON_HLSLI
#define WITCHER_NIGHT_CLOUD_COMMON_HLSLI

#include "../shared.h"

float WitcherNightCloudMultiplier(float tag) {
  uint packed = asuint(tag);
  // Native padding is zero, so an absent addon preserves brightness.
  return (packed & WITCHER_NIGHT_TAG_MASK) == WITCHER_NIGHT_TAG
      ? float(packed & WITCHER_NIGHT_FACTOR_MASK) / float(WITCHER_NIGHT_FACTOR_SCALE)
      : 1.f;
}

#endif
