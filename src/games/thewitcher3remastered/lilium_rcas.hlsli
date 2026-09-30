#ifndef SRC_GAMES_THEWITCHER3REMASTERED_LILIUM_RCAS_HLSLI_
#define SRC_GAMES_THEWITCHER3REMASTERED_LILIUM_RCAS_HLSLI_

#include "./common.hlsli"

// Lilium's luminance RCAS, ported from Ghost of Tsushima. Witcher's scene
// texture is already linear BT.709 in scene-white units, so 125 scene whites
// is the same HDR normalization without GoT's intermediate encoding/scaling.
float3 WitcherLoadSharpenedScene(Texture2D<float4> scene, int2 pixel, uint2 size) {
  pixel = clamp(pixel, int2(0, 0), int2(size) - 1);
  const float3 center = scene.Load(int3(pixel, 0)).rgb;
  if (CUSTOM_SHARPENING_MODE == 0.f || CUSTOM_SHARPENING <= 0.f) return center;

  const float normalization = 125.f;
  const float e = renodx::color::y::from::BT709(center) / normalization;
  if (e <= 0.f) return center;
  const float b = renodx::color::y::from::BT709(scene.Load(
      int3(clamp(pixel + int2(0, -1), int2(0, 0), int2(size) - 1), 0)).rgb) / normalization;
  const float d = renodx::color::y::from::BT709(scene.Load(
      int3(clamp(pixel + int2(-1, 0), int2(0, 0), int2(size) - 1), 0)).rgb) / normalization;
  const float f = renodx::color::y::from::BT709(scene.Load(
      int3(clamp(pixel + int2(1, 0), int2(0, 0), int2(size) - 1), 0)).rgb) / normalization;
  const float h = renodx::color::y::from::BT709(scene.Load(
      int3(clamp(pixel + int2(0, 1), int2(0, 0), int2(size) - 1), 0)).rgb) / normalization;

  const float ring_min = min(min(b, d), min(f, h));
  const float ring_max = max(max(b, d), max(f, h));
  const float range = max(ring_max, e) - min(ring_min, e);
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

#endif  // SRC_GAMES_THEWITCHER3REMASTERED_LILIUM_RCAS_HLSLI_
