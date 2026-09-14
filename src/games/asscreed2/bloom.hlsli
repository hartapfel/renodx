#ifndef AC2_BLOOM_HLSLI
#define AC2_BLOOM_HLSLI

#include "./shared.h"

// The pre-LUT bloom downsample reads both scene color and a separate glow
// mask. FP16 exposes mask gains near 800 which used to hit UNORM write limits.
// Apply a smooth shoulder before filtering, so excessive source energy cannot
// spread into every bloom level. Keep weak inputs exact and retain HDR above 1.
// Work in the native encoded/mask domain used by the subsequent multiplication.
float3 AC2BloomSeed(float3 color) {
  // FP16 mask gains need the same protection in Vanilla/Off and PsychoV.
  if (shader_injection.injection_version != 30.f) return color;
  float peak = max(color.r, max(color.g, color.b));
  if (peak <= 1.f) return color;
  // f(x) = 2 - 1/x: value and slope match identity at 1, with no hard clip.
  return color * ((2.f - rcp(peak)) / peak);
}

#endif
