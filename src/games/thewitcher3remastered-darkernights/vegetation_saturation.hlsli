/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#ifndef WITCHER_VEGETATION_SATURATION_HLSLI
#define WITCHER_VEGETATION_SATURATION_HLSLI
#include "../../shaders/color.hlsl"

// Scene transport at the audited post-grade outputs is signed gamma 2.2
// BT.709, before scene/UI composition. Delta already includes the night fade.
float3 WitcherVegetationSaturation(float3 encoded, float delta) {
  if (delta == 0.f) return encoded;
  const float3 linear_bt709 = sign(encoded) * pow(abs(encoded), 2.2f);
  const float3 lab = renodx::color::oklab::from::BT709(linear_bt709);
  const float relative_chroma = length(lab.yz) / max(lab.x, 1e-6f);
  if (relative_chroma <= 0.02f) return encoded;
  float hue = atan2(lab.z, lab.y) * (180.f / 3.141592653589793f);
  if (hue < 0.f) hue += 360.f;
  const float warm_weight = 0.35f * smoothstep(85.f, 110.f, hue)
      + 0.65f * smoothstep(110.f, 135.f, hue);
  const float cool_weight = 1.f - 0.65f * smoothstep(220.f, 250.f, hue)
      - 0.35f * smoothstep(250.f, 275.f, hue);
  const float weight = saturate(warm_weight * cool_weight)
      * smoothstep(0.02f, 0.06f, relative_chroma);
  if (weight == 0.f) return encoded;
  float saturation = 1.f + delta * weight;
  float3 target = renodx::color::bt2020::from::BT709(linear_bt709);
  const float luminance = renodx::color::y::from::BT2020(target);
  const float3 chroma = target - luminance;
  if (saturation > 1.f) {
    // There is no display peak here: the chosen downstream tonemapper owns
    // highlight mapping. Soft-limit only against the RGB black boundary.
    const float3 limits = renodx::math::Select(chroma < 0.f,
        renodx::math::DivideSafe((-luminance).xxx, chroma, 1e10f.xxx), 1e10f.xxx);
    const float headroom = max(renodx::math::Min(limits) - 1.f, 0.f);
    const float boost = saturation - 1.f;
    saturation = 1.f + headroom * boost / (headroom + boost);
  }
  target = renodx::color::bt709::from::BT2020(luminance + chroma * saturation);
  return sign(target) * pow(abs(target), 1.f / 2.2f);
}
#endif
