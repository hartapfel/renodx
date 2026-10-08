#ifndef WITCHER_NIGHT_SKYLIGHT_HLSLI
#define WITCHER_NIGHT_SKYLIGHT_HLSLI

#include "../shared.h"

// CommonConstantsHook transports both clock-faded factors in native padding.
// Untagged/native data remains neutral.
float WitcherNightSkylight(float tag) {
  uint packed = asuint(tag);
  return (packed & WITCHER_NIGHT_TAG_MASK) == WITCHER_NIGHT_TAG
      ? float((packed >> WITCHER_NIGHT_SKY_SHIFT) & WITCHER_NIGHT_FACTOR_MASK) / float(WITCHER_NIGHT_FACTOR_SCALE)
      : 1.f;
}

#endif
