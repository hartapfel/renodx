#ifndef THEWITCHER3REMASTERED_PSYCHOV_TONEMAP_HLSLI_
#define THEWITCHER3REMASTERED_PSYCHOV_TONEMAP_HLSLI_

#include "../shared.h"
#include "./customtest31.hlsli"

// Evaluate the original curve at 18% grey in the exposure shaders, then use
// only its luminance gain. A scalar preserves HDR ratios and chromaticity.
float WitcherNativeBrightnessScale(float3 native_midgray) {
  float scale = dot(native_midgray, float3(0.2126f, 0.7152f, 0.0722f)) / 0.18f;
  // Invalid native parameters must not contaminate an otherwise valid scene.
  scale = (scale >= 0.f && scale <= 3.402823466e+38f) ? scale : 1.f;
  return scale;
}

// Preserve the native AgX luminance curve through grading, including the
// upstream shoulder extension. A grey sample supplies luminance only: signed
// RGB ratios and PsychoV's observer-space colour response remain independent.
float3 WitcherApplyNativeContrast(float3 scene, float3 native_gray) {
  const float luminance = renodx::color::y::from::BT709(scene);
  if (luminance <= 0.f) return scene;
  float scale = renodx::color::y::from::BT709(native_gray) / luminance;
  scale = (scale >= 0.f && scale <= 3.402823466e+38f) ? scale : 1.f;
  scene *= scale;
  // The unbounded extension can exceed the FP16 intermediate. Compress RGB
  // together well above display range, without clipping channels or SDR white.
  return renodx::tonemap::neutwo::MaxChannel(scene, 16384.f);
}

// Scene and result are linear BT.709 relative to game white. Exposure has
// already run in the native pass; custom grading runs once in the new mapper.
float3 WitcherToneMapPsychoVCustom31(float3 color_bt709, bool is_hdr) {
  const float white_nits = is_hdr ? max(RENODX_DIFFUSE_WHITE_NITS, 1.f) : 100.f;
  const float peak = is_hdr ? RENODX_PEAK_WHITE_NITS / white_nits : 1.f;
  color_bt709 = renodx::math::ZeroNaN(color_bt709);
  color_bt709 = renodx::math::Select(isinf(color_bt709), 0.f.xxx, color_bt709);
  if (RENODX_TONE_MAP_GAMMA != 1.f) {
    const float luminance = max(renodx::color::y::from::BT709(color_bt709), 0.f);
    color_bt709 = renodx::color::correct::Luminance(
        color_bt709, luminance, pow(luminance, RENODX_TONE_MAP_GAMMA));
  }
  // Apply adaptive-neutral purity to signed colour before the custom mapper's
  // abs/sign fallback. Applying it to magnitudes inside that fallback restores
  // chromatic signs even at zero purity. Both anchors here are neutral RGB.
  if (RENODX_TONE_MAP_SATURATION != 1.f) {
    const float neutral = dot(
        renodx::tonemap::witcher_psychov_custom31::PSYCHO30_BT709_SOURCE_YF_WEIGHTS,
        color_bt709) / renodx::tonemap::witcher_psychov_custom31::PSYCHO30_D65_WHITE_YF;
    color_bt709 = lerp(neutral.xxx, color_bt709, RENODX_TONE_MAP_SATURATION);
  }
  float3 mapped_bt709 = renodx::tonemap::witcher_psychov_custom31::custom_psychotm_test31(
      color_bt709,
      peak,
      1.f,
      RENODX_TONE_MAP_HIGHLIGHTS,
      RENODX_TONE_MAP_SHADOWS,
      RENODX_TONE_MAP_CONTRAST,
      RENODX_TONE_MAP_FLARE,
      RENODX_TONE_MAP_HIGHLIGHT_CONTRAST,
      RENODX_TONE_MAP_SHADOW_CONTRAST,
      1.f,  // Global saturation is applied above, before signed fallback selection.
      RENODX_TONE_MAP_HIGHLIGHT_SATURATION,
      0.f,  // Retain the shared Blowout control's full-grayscale endpoint below.
      RENODX_PSYCHOV_ADAPTATION_ANCHOR.xxx,
      RENODX_PSYCHOV_BACKGROUND_ANCHOR.xxx,
      0.f,  // SDR EOTF emulation stays off.
      RENODX_PSYCHOV_GAMUT_COMPRESSION,
      is_hdr ? (int)RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE : 0,
      RENODX_PSYCHOV_COMPRESSION);
  // Remove only numerical neutral-axis error at the exact grayscale endpoint.
  if (RENODX_TONE_MAP_SATURATION == 0.f) {
    return renodx::color::y::from::BT709(mapped_bt709).xxx;
  }
  if (RENODX_TONE_MAP_BLOWOUT != 0.f) {
    mapped_bt709 = lerp(mapped_bt709, renodx::color::y::from::BT709(mapped_bt709).xxx,
                        saturate(RENODX_TONE_MAP_BLOWOUT));
  }
  return mapped_bt709;
}

#endif
