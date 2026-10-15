/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#ifndef WITCHER_VEGETATION_SATURATION_HLSLI
#define WITCHER_VEGETATION_SATURATION_HLSLI
#include "../../shaders/color.hlsl"

// Scene transport at the audited post-grade outputs is signed gamma 2.2
// BT.709, before scene/UI composition. Both amounts include the night fade.
float3 WitcherVegetationGrade(float3 encoded, float delta, float tint_correction, bool signed_transport) {
  if (delta == 0.f && tint_correction == 0.f) return encoded;
  float3 linear_bt709 = sign(encoded) * pow(abs(encoded), 2.2f);
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
  if (tint_correction != 0.f) {
    // Complementary RGB addition would neutralize the same chroma we want
    // to retain. Rotate toward warmer yellow/green instead (up to 25 degrees),
    // with the same original-colour selection as the saturation control.
    float sine, cosine;
    const float angle = -tint_correction * weight * (25.f * 3.141592653589793f / 180.f);
    sincos(angle, sine, cosine);
    float3 corrected = renodx::color::bt709::from::OkLab(float3(lab.x,
        lab.y * cosine - lab.z * sine, lab.y * sine + lab.z * cosine));
    if (!signed_transport && all(linear_bt709 >= 0.f) && any(corrected < 0.f)) {
      // Native presentation uses log2(rgb), not signed gamma. Shorten the
      // hue arc at its black boundary instead of clipping channels or losing
      // saturation. Audited HDR presentation has no such BT.709 restriction.
      float lower = 0.f, upper = 1.f;
      corrected = linear_bt709;
      for (uint i = 0u; i < 8u; ++i) {
        const float amount = (lower + upper) * 0.5f;
        sincos(angle * amount, sine, cosine);
        const float3 candidate = renodx::color::bt709::from::OkLab(float3(lab.x,
            lab.y * cosine - lab.z * sine, lab.y * sine + lab.z * cosine));
        if (all(candidate >= 0.f)) {
          lower = amount;
          corrected = candidate;
        } else upper = amount;
      }
    }
    const float luminance = renodx::color::y::from::BT709(linear_bt709);
    const float corrected_luminance = renodx::color::y::from::BT709(corrected);
    if (luminance > 0.f && corrected_luminance > 1e-20f) {
      // Uniform linear rescaling restores Y and leaves OKLab C/L unchanged.
      // Keep signed wide-gamut channels; the downstream tonemapper maps them.
      linear_bt709 = corrected * (luminance / corrected_luminance);
    }
    if (delta == 0.f) return sign(linear_bt709) * pow(abs(linear_bt709), 1.f / 2.2f);
  }
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
