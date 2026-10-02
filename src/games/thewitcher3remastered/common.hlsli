#ifndef SRC_GAMES_THEWITCHER3REMASTERED_COMMON_HLSLI_
#define SRC_GAMES_THEWITCHER3REMASTERED_COMMON_HLSLI_

#include "./shared.h"
#include "./test30.hlsl"
#include "../../shaders/tonemap/neutwo.hlsl"

// Reversible SDR proxy for native LUTs and bounded presentation effects.
// Keep the state local to each pixel/pass; alpha belongs to the native pipeline.
struct WitcherGradeState {
  float3 neutral_sdr;
  float gamut_scale;
  float range_scale;
};

WitcherGradeState WitcherPrepareGrade(float3 color_bt709) {
  WitcherGradeState state;
  // A luminance-axis contraction is invertible for display-valid BT.2020
  // represented in BT.709, including blue outside the CIE170-2 spectral bound.
  state.gamut_scale = max(renodx::color::correct::ComputeGamutCompressionScale(color_bt709), 1e-6f);
  state.neutral_sdr = max(renodx::color::correct::GamutCompress(
      color_bt709, renodx::color::y::from::BT709(color_bt709), state.gamut_scale), 0.f);
  state.range_scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(state.neutral_sdr);
  state.neutral_sdr *= state.range_scale;
  return state;
}

float3 WitcherRestoreGrade(float3 graded_sdr, WitcherGradeState state) {
  return renodx::color::correct::GamutDecompress(
      graded_sdr / max(state.range_scale, 1e-6f),
      state.gamut_scale);
}

// Evaluate the original curve at 18% grey in the exposure shaders, then use
// only its luminance gain. A scalar preserves HDR ratios and chromaticity.
float WitcherNativeBrightnessScale(float3 native_midgray) {
  float scale = dot(native_midgray, float3(0.2126f, 0.7152f, 0.0722f)) / 0.18f;
  // Invalid native parameters must not contaminate an otherwise valid scene.
  scale = (scale >= 0.f && scale <= 3.402823466e+38f) ? scale : 1.f;
  // Cap each environment's gain before transition blending. Retain native
  // darkening while preventing this compensation from adding exposure.
  return CUSTOM_NATIVE_BRIGHTNESS_DARKEN_ONLY != 0.f ? min(scale, 1.f) : scale;
}

// Native gamma-shaped intermediates must retain signed wide-gamut channels.
float3 WitcherSignedPow(float3 color, float exponent) {
  return sign(color) * pow(abs(color), max(exponent, 1e-6f));
}

float3 WitcherApplyPsychoVInputExtensions(float3 color_bt709) {
  color_bt709 = renodx::math::ZeroNaN(color_bt709);
  color_bt709 = renodx::math::Select(isinf(color_bt709), 0.f.xxx, color_bt709);

  if (RENODX_TONE_MAP_GAMMA == 1.f
      && RENODX_TONE_MAP_CONTRAST == 1.f
      && RENODX_TONE_MAP_CONTRAST_HIGHLIGHTS == 1.f
      && RENODX_TONE_MAP_CONTRAST_SHADOWS == 1.f
      && RENODX_TONE_MAP_FLARE == 0.f) {
    return color_bt709;
  }

  const float luminance = max(
      renodx::color::y::from::BT709(color_bt709),
      0.f);
  float adjusted_luminance = luminance;
  if (RENODX_TONE_MAP_GAMMA != 1.f) {
    adjusted_luminance = pow(adjusted_luminance, RENODX_TONE_MAP_GAMMA);
  }
  if (RENODX_TONE_MAP_CONTRAST != 1.f
      || RENODX_TONE_MAP_CONTRAST_HIGHLIGHTS != 1.f
      || RENODX_TONE_MAP_CONTRAST_SHADOWS != 1.f
      || RENODX_TONE_MAP_FLARE != 0.f) {
    static const float mid_gray = 0.18f;
    // Match the other mods' split contrast, preserving RGB ratios and the
    // grey pivot. Grade before PsychoV so stronger contrast retains rolloff.
    const float split_contrast = adjusted_luminance < mid_gray
        ? RENODX_TONE_MAP_CONTRAST_SHADOWS : RENODX_TONE_MAP_CONTRAST_HIGHLIGHTS;
    const float normalized_luminance = max(
        adjusted_luminance / mid_gray,
        1e-6f);
    const float flare = 0.10f * pow(RENODX_TONE_MAP_FLARE, 10.f);
    const float flare_exponent = renodx::math::DivideSafe(
        normalized_luminance + flare,
        normalized_luminance,
        1.f);
    adjusted_luminance = pow(
        normalized_luminance,
        RENODX_TONE_MAP_CONTRAST * split_contrast * flare_exponent) * mid_gray;
  }

  return renodx::color::correct::Luminance(
      color_bt709,
      luminance,
      max(adjusted_luminance, 0.f));
}

float3 WitcherApplyPsychoVOutputExtensions(
    float3 source_bt709,
    float3 mapped_bt709) {
  mapped_bt709 = renodx::math::ZeroNaN(mapped_bt709);
  mapped_bt709 = renodx::math::Select(isinf(mapped_bt709), 0.f.xxx, mapped_bt709);

  if (RENODX_TONE_MAP_SATURATION == 1.f
      && RENODX_TONE_MAP_HIGHLIGHT_SATURATION == 1.f
      && RENODX_TONE_MAP_BLOWOUT == 0.f) {
    return mapped_bt709;
  }

  // Grade in the actual display gamut: valid BT.2020 can have signed BT.709
  // components. Preserve luminance and chroma direction rather than clipping
  // independent channels after an unbounded saturation adjustment.
  const bool use_bt2020 = RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE != 0.f;
  float3 target = use_bt2020 ? renodx::color::bt2020::from::BT709(mapped_bt709) : mapped_bt709;
  const float luminance = use_bt2020 ? renodx::color::y::from::BT2020(target) : renodx::color::y::from::BT709(target);
  float saturation = RENODX_TONE_MAP_SATURATION;

  if (RENODX_TONE_MAP_BLOWOUT != 0.f) {
    const float percent_hdr_container = saturate(
        luminance * max(RENODX_DIFFUSE_WHITE_NITS, 1.f) / 10000.f);
    saturation *= pow(1.f - percent_hdr_container, 100.f * saturate(RENODX_TONE_MAP_BLOWOUT));
  }

  if (RENODX_TONE_MAP_HIGHLIGHT_SATURATION != 1.f) {
    const float strength = abs(RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f);
    const float source_luminance = max(renodx::color::y::from::BT709(source_bt709), 0.f);
    const float percent_highlight = saturate(source_luminance * 100.f / 10000.f);
    float scale = pow(1.f - percent_highlight, 100.f * strength);
    if (RENODX_TONE_MAP_HIGHLIGHT_SATURATION > 1.f) scale = 2.f - scale;
    saturation *= scale;
  }

  const float3 chroma = target - luminance;
  if (saturation > 1.f) {
    const float peak = RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f);
    const float3 limit = renodx::math::DivideSafe(
        renodx::math::Select(chroma > 0.f, (peak - luminance).xxx, (-luminance).xxx),
        chroma,
        1e10f.xxx);
    const float headroom = max(renodx::math::Min(limit) - 1.f, 0.f);
    const float boost = saturation - 1.f;
    // Unit slope at neutral; asymptotically approaches the available chroma
    // headroom instead of pinning a channel to zero or the display peak.
    saturation = 1.f + headroom * (boost / (headroom + boost));
  }
  target = luminance + chroma * saturation;
  return use_bt2020 ? renodx::color::bt709::from::BT2020(target) : target;
}

// Contract: scene input and result are linear BT.709, relative to game white.
// Call only on a proven pre-tonemap HDR signal. This does not encode output,
// sample native LUTs, or reconstruct HDR from a completed SDR image.
float3 WitcherToneMapPsychoV30(float3 color_bt709) {
  color_bt709 = WitcherApplyPsychoVInputExtensions(color_bt709);
  float3 mapped_bt709 = renodx::tonemap::psychov::psychotm_test30(
      color_bt709,
      RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f),
      RENODX_TONE_MAP_EXPOSURE,
      RENODX_TONE_MAP_HIGHLIGHTS,
      RENODX_TONE_MAP_SHADOWS,
      // Contrast is a scalar luminance grade above, independent of purity.
      1.f,
      // Saturation is applied after the response with a soft gamut limit.
      // Extrapolating LMS purity here pins bright colors to the gamut hull.
      1.f,
      1.f,
      100.f,
      RENODX_PSYCHOV_HUE_SHIFT,
      1.f,
      0,
      RENODX_PSYCHOV_CONE_RESPONSE_EXPONENT,
      RENODX_PSYCHOV_ADAPTATION_ANCHOR.xxx,
      RENODX_PSYCHOV_BACKGROUND_ANCHOR.xxx,
      RENODX_PSYCHOV_GAMUT_COMPRESSION,
      int(RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE),
      1.f,
      RENODX_PSYCHOV_COMPRESSION);
  return WitcherApplyPsychoVOutputExtensions(color_bt709, mapped_bt709);
}

// Use at the native branch point, before evaluating either tonemapper.
// Missing/zero injection data retains native rendering during live development.
bool WitcherUsePsychoV30() {
  return RENODX_TONE_MAP_TYPE == 1.f
         && RENODX_PEAK_WHITE_NITS > 0.f
         && RENODX_DIFFUSE_WHITE_NITS > 0.f;
}

#endif  // SRC_GAMES_THEWITCHER3REMASTERED_COMMON_HLSLI_
