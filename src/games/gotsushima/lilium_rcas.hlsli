#ifndef SRC_GAMES_GOTSUSHIMA_LILIUM_RCAS_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_LILIUM_RCAS_HLSLI_

#include "./intermediate.hlsli"

// Lilium's luminance RCAS, adapted from the Crimson Desert/Nioh 3 mods.
// Retains the HDR normalization, 0.99 overshoot limiter, noise attenuation,
// and luminance-ratio resolve. Black and constant neighborhoods are guarded.
// Input is the full-resolution composition texture in the active output
// gamut (native SDR signal in BT.709, gamma-2.2 BT.2020 transport in HDR).
// Sharpen individual decoded texels before CA performs bilinear reconstruction.
float GhostSceneLuminance(float3 color) {
  return GHOST_SDR_OUTPUT != 0.f ? renodx::color::y::from::BT709(color)
                                 : renodx::color::y::from::BT2020(color);
}

float3 GhostLoadSharpenedScene(Texture2D<float4> scene, int2 pixel, uint2 size) {
  pixel = clamp(pixel, int2(0, 0), int2(size) - 1);
  const float3 center = GhostDecodeIntermediate(scene.Load(int3(pixel, 0)).rgb);
  if (CUSTOM_SHARPENING <= 0.f) return center;

  // Retain Lilium's 125-scene-white HDR normalization in the transport domain.
  const float normalization = 125.f * max(RENODX_DIFFUSE_WHITE_NITS, 1.f) / RENODX_INTERMEDIATE_SCALING;
  const float e = GhostSceneLuminance(center) / normalization;
  if (e <= 0.f) return center;
  const float b = GhostSceneLuminance(GhostDecodeIntermediate(scene.Load(
      int3(clamp(pixel + int2(0, -1), int2(0, 0), int2(size) - 1), 0)).rgb)) / normalization;
  const float d = GhostSceneLuminance(GhostDecodeIntermediate(scene.Load(
      int3(clamp(pixel + int2(-1, 0), int2(0, 0), int2(size) - 1), 0)).rgb)) / normalization;
  const float f = GhostSceneLuminance(GhostDecodeIntermediate(scene.Load(
      int3(clamp(pixel + int2(1, 0), int2(0, 0), int2(size) - 1), 0)).rgb)) / normalization;
  const float h = GhostSceneLuminance(GhostDecodeIntermediate(scene.Load(
      int3(clamp(pixel + int2(0, 1), int2(0, 0), int2(size) - 1), 0)).rgb)) / normalization;

  const float ring_min = min(min(b, d), min(f, h));
  const float ring_max = max(max(b, d), max(f, h));
  const float range = max(ring_max, e) - min(ring_min, e);
  // Above the normalization point RCAS's upper limiter would select zero.
  if (range <= 0.f || ring_max <= 0.f || ring_min >= 1.f) return center;

  const float limited_max = min(ring_max, 0.99f);
  const float hit_min = ring_min / (4.f * limited_max);
  const float hit_max = (1.f - limited_max) / (4.f * ring_min - 4.f);
  float lobe = max(-0.1875f, min(max(-hit_min, hit_max), 0.f)) * saturate(CUSTOM_SHARPENING);

  const float noise = saturate(abs(0.25f * (b + d + f + h) - e) / range);
  lobe *= 1.f - 0.5f * noise;

  const float sharpened_y = ((b + d + f + h) * lobe + e) / (4.f * lobe + 1.f);
  return center * clamp(sharpened_y / e, 0.f, 4.f);
}

#endif  // SRC_GAMES_GOTSUSHIMA_LILIUM_RCAS_HLSLI_
