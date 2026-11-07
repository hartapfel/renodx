// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_REMASTERED_WATER_ELEVATION
#define WITCHER_REMASTERED_WATER_ELEVATION

// 81EAA494 selects the first regional sample with abs(height) > .001, then
// uses it only if abs(height) > .01. A small nonzero first hit therefore MUST
// NOT fall through to a later overlapping region. Preserve the native sampler's
// addressing/filtering; an explicit UV clip would change border footprints.
// Where the native shader uses mesh POSITION.z, the caller must supply that
// current water body's base height or leave fallback_known false.
bool GraphicsWaterElevation(Texture2DArray<float4> heights, SamplerState native_sampler,
    float4 regions[116], float2 world, bool fallback_known, float fallback_height,
    out float elevation, out int selected_region) {
  elevation = 0.f;
  selected_region = -1;
  uint width, height, layers;
  heights.GetDimensions(width, height, layers);
  int count = asint(regions[6].x);
  if (width == 0 || height == 0 || count < 0 || count > 44 || count > (int)layers
      || any(!isfinite(world))) return false;
  float sampled = 0.f;
  [loop] for (int i = 0; i < count; ++i) {
    float4 rectangle = regions[7 + i];
    if (any(!isfinite(rectangle)) || any(rectangle.zw == 0.f)) return false;
    sampled = heights.SampleLevel(native_sampler, float3((world - rectangle.xy) / rectangle.zw, i), 0.f).x;
    if (!isfinite(sampled)) return false;
    if (abs(sampled) > .001f) { selected_region = i; break; }
  }
  if (abs(sampled) > .01f) { elevation = sampled; return true; }
  if (!fallback_known || !isfinite(fallback_height)) return false;
  selected_region = -1;
  elevation = fallback_height;
  return true;
}

bool GraphicsWaterElevation(Texture2DArray<float4> heights, SamplerState native_sampler,
    float4 regions[116], float2 world, bool fallback_known, float fallback_height, out float elevation) {
  int selected_region;
  return GraphicsWaterElevation(heights, native_sampler, regions, world, fallback_known,
      fallback_height, elevation, selected_region);
}
#endif
