#ifndef SRC_GAMES_GHOSTOFTSUSHIMA_LILIUM_RCAS_HLSLI_
#define SRC_GAMES_GHOSTOFTSUSHIMA_LILIUM_RCAS_HLSLI_

#include "./shared.h"

// Lilium's luminance RCAS, adapted from the Crimson Desert/Nioh 3 mods.
// Retains the HDR normalization, 0.99 overshoot limiter, noise attenuation,
// and luminance-ratio resolve. Black and constant neighborhoods are guarded.
// Input is the linear BT.709 scene texture, before local exposure/LUT/PsychoV.
float3 GhostApplyRCAS(
    float3 center, float2 uv, Texture2D<float4> scene, SamplerState scene_sampler) {
  if (CUSTOM_SHARPENING <= 0.f) return center;

  center = max(center, 0.f.xxx);
  static const float normalization = 125.f;
  const float e = renodx::color::y::from::BT709(center) / normalization;
  if (e <= 0.f) return center;

  uint width, height;
  scene.GetDimensions(width, height);
  const float2 texel = rcp(float2(width, height));

  // Cross neighborhood in source texels. All five samples use the same
  // linear signal and the same native sampler at the distorted scene UV.
  const float b = renodx::color::y::from::BT709(max(
      scene.SampleLevel(scene_sampler, uv + float2(0.f, -texel.y), 0).rgb, 0.f.xxx)) / normalization;
  const float d = renodx::color::y::from::BT709(max(
      scene.SampleLevel(scene_sampler, uv + float2(-texel.x, 0.f), 0).rgb, 0.f.xxx)) / normalization;
  const float f = renodx::color::y::from::BT709(max(
      scene.SampleLevel(scene_sampler, uv + float2(texel.x, 0.f), 0).rgb, 0.f.xxx)) / normalization;
  const float h = renodx::color::y::from::BT709(max(
      scene.SampleLevel(scene_sampler, uv + float2(0.f, texel.y), 0).rgb, 0.f.xxx)) / normalization;

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

#endif  // SRC_GAMES_GHOSTOFTSUSHIMA_LILIUM_RCAS_HLSLI_
