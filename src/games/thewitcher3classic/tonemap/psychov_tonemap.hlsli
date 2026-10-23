#ifndef THEWITCHER3CLASSIC_PSYCHOV_TONEMAP_HLSLI_
#define THEWITCHER3CLASSIC_PSYCHOV_TONEMAP_HLSLI_

#include "../shared.h"
#include "./customtest31.hlsli"
#include "./psychov_gamut.hlsli"

// Scene and result are linear BT.709 relative to game white. Exposure has
// already run in the native pass; custom grading runs once in the new mapper.
float3 WitcherToneMapPsychoVCustom31(float3 color_bt709, bool is_hdr) {
  const float white_nits = is_hdr ? max(RENODX_DIFFUSE_WHITE_NITS, 1.f) : 100.f;
  const float target_peak = is_hdr ? RENODX_PEAK_WHITE_NITS / white_nits : 1.f;
  const float peak = target_peak;
  color_bt709 *= RENODX_TONE_MAP_EXPOSURE;
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
  // Grade luminance once before the observer response. Grading each cone
  // separately leaves a weak S cone below the highlight-control threshold
  // while L/M saturate, holding saturated highlights on a coloured plateau.
  // One positive gain preserves scene chromaticity and the zero black floor.
  const float source_y = renodx::color::y::from::BT709(color_bt709);
  if (!(source_y > 0.f)) return 0.f;
  const float graded_y = renodx::tonemap::witcher_psychov_custom31::custom_psycho31_ApplyAnchoredTonalGrading(
      source_y.xxx, RENODX_PSYCHOV_ADAPTATION_ANCHOR.xxx,
      RENODX_PSYCHOV_ADAPTATION_ANCHOR.xxx,
      RENODX_TONE_MAP_CONTRAST, RENODX_TONE_MAP_FLARE,
      RENODX_TONE_MAP_HIGHLIGHT_CONTRAST, RENODX_TONE_MAP_SHADOW_CONTRAST,
      RENODX_TONE_MAP_HIGHLIGHTS, RENODX_TONE_MAP_SHADOWS).x;
  color_bt709 *= graded_y / source_y;
  const float background_anchor = min(RENODX_PSYCHOV_BACKGROUND_ANCHOR, peak * 0.99f);
  const float response_compression = RENODX_PSYCHOV_COMPRESSION == 0.f
      ? renodx::tonemap::witcher_psychov_custom31::psycho30_AutoCompressionPower(
          background_anchor, peak)
      : RENODX_PSYCHOV_COMPRESSION;
  float3 mapped_bt709 = renodx::tonemap::witcher_psychov_custom31::custom_psychotm_test31(
      WitcherCompressPsychoVConeInput(color_bt709),
      peak,
      1.f,
      1.f, 1.f, 1.f, 0.f, 1.f, 1.f,  // Tonal grading was applied above.
      1.f,  // Global saturation is applied above, before signed fallback selection.
      RENODX_TONE_MAP_HIGHLIGHT_SATURATION,
      0.f,  // Retain the shared Blowout control's full-grayscale endpoint below.
      RENODX_PSYCHOV_ADAPTATION_ANCHOR.xxx,
      background_anchor.xxx,
      0.f,  // SDR EOTF emulation stays off.
      0.f,  // The game-local display gamut fit below owns this operation.
      is_hdr ? (int)RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE : 0,
      response_compression,
      RENODX_PSYCHOV_HIGHLIGHT_HUE);
  mapped_bt709 = WitcherCompressPsychoVGamut(
      mapped_bt709, color_bt709, peak, response_compression,
      is_hdr ? (int)RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE : 0,
      RENODX_PSYCHOV_GAMUT_COMPRESSION);
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
