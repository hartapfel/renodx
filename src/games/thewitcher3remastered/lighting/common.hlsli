#ifndef WITCHER_NIGHT_CLOUD_COMMON_HLSLI
#define WITCHER_NIGHT_CLOUD_COMMON_HLSLI

#include "../shared.h"

float WitcherNightCloudMultiplier() {
  if (RENODX_PEAK_WHITE_NITS <= 0.f || RENODX_TONE_MAP_TYPE != 1.f) return 1.f;
  uint packed = (asuint(shader_injection.mode_flags) & WITCHER_NIGHT_CLOUD_MASK) >> WITCHER_NIGHT_CLOUD_SHIFT;
  // No runtime night data means native behavior, including standalone DevKit.
  return packed == 0u ? 1.f : min(float(packed - 1u) * 0.005f, 2.f);
}

#endif
