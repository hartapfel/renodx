#ifndef SRC_GAMES_THEWITCHER3REMASTERED_SHARED_H_
#define SRC_GAMES_THEWITCHER3REMASTERED_SHARED_H_

// Keep scalar order identical in the C++ injection payload and HLSL cbuffer.
#define WITCHER_FLAG_GAMUT_TARGET (1u << 0)
#define WITCHER_FLAG_CA (1u << 1)
#define WITCHER_FLAG_SHARPENING (1u << 2)
#define WITCHER_FLAG_VIGNETTE_BLACK (1u << 3)
#define WITCHER_FLAG_NATIVE_BRIGHTNESS (1u << 4)
// Bit 5 is retired; keep the remaining packed settings in their existing slots.
#define WITCHER_FLAG_NATIVE_BRIGHTNESS_DARKEN_ONLY (1u << 6)

// Split contrast percentages share unused bits with the boolean/mode flags.
#define WITCHER_CONTRAST_HIGHLIGHTS_SHIFT 7u
#define WITCHER_CONTRAST_SHADOWS_SHIFT 14u
// Runtime cloud multiplier: 0 is an older addon/uninitialized payload;
// 1..401 represent 0..2 in 0.005 steps.
#define WITCHER_NIGHT_CLOUD_SHIFT 22u
#define WITCHER_NIGHT_CLOUD_MASK (511u << WITCHER_NIGHT_CLOUD_SHIFT)

// Pack four independent effect percentages into one root DWORD.
#define WITCHER_EFFECT_BLUR_SHIFT 0u
#define WITCHER_EFFECT_SHAFTS_SHIFT 7u
#define WITCHER_EFFECT_LENS_SHIFT 14u
#define WITCHER_EFFECT_BLOOM_SHIFT 21u

// Unequal grade strengths share the existing DWORD. The tagged negative
// float is finite; ordinary nonnegative payloads keep the legacy strength.
#define WITCHER_GRADE_SPLIT_TAG 0x80000000u
#define WITCHER_GRADE_SPLIT_MASK 0xc0000000u
#define WITCHER_GRADE_STRENGTH_MASK 32767u
#define WITCHER_GRADE_CHROMA_SHIFT 15u

struct ShaderInjectData {
  float peak_white_nits;
  float diffuse_white_nits;
  float tone_map_type;
  float tone_map_exposure;

  float tone_map_gamma;
  float tone_map_highlights;
  float tone_map_shadows;
  float tone_map_contrast;

  float tone_map_saturation;
  float tone_map_highlight_saturation;
  float tone_map_blowout;
  float tone_map_flare;

  float psychov_hue_shift;
  float psychov_cone_response_exponent;
  float psychov_adaptation_anchor;
  float psychov_background_anchor;

  float psychov_gamut_compression;
  float mode_flags;
  float psychov_compression;
  float graphics_white_nits;

  float chromatic_aberration_intensity;
  float chromatic_aberration_start_offset;
  float sharpening;
  float film_grain;
  float random_seed;
  float vignette_strength;
  float custom_lut_strength;
  float custom_lut_scaling;
  float custom_color_grading;
  float effect_strengths;
  // Zero is neutral; effective night slider delta already includes the fade.
  float night_saturation_delta;
};

#ifdef __cplusplus
static_assert(sizeof(ShaderInjectData) == 124);
#else
// DX12 injection binding, paired with addon.cpp; native buffers use space0.
cbuffer shader_injection : register(b13, space50) {
  ShaderInjectData shader_injection : packoffset(c0);
}

#define RENODX_PEAK_WHITE_NITS shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS shader_injection.diffuse_white_nits
#define RENODX_GRAPHICS_WHITE_NITS shader_injection.graphics_white_nits
#define RENODX_TONE_MAP_TYPE shader_injection.tone_map_type
#define RENODX_TONE_MAP_EXPOSURE shader_injection.tone_map_exposure
#define RENODX_TONE_MAP_GAMMA shader_injection.tone_map_gamma
#define RENODX_TONE_MAP_HIGHLIGHTS shader_injection.tone_map_highlights
#define RENODX_TONE_MAP_SHADOWS shader_injection.tone_map_shadows
#define RENODX_TONE_MAP_CONTRAST shader_injection.tone_map_contrast
#define RENODX_TONE_MAP_CONTRAST_HIGHLIGHTS (float((asuint(shader_injection.mode_flags) >> WITCHER_CONTRAST_HIGHLIGHTS_SHIFT) & 127u) * 0.02f)
#define RENODX_TONE_MAP_CONTRAST_SHADOWS (float((asuint(shader_injection.mode_flags) >> WITCHER_CONTRAST_SHADOWS_SHIFT) & 127u) * 0.02f)
#define RENODX_TONE_MAP_SATURATION shader_injection.tone_map_saturation
#define WITCHER_NIGHT_SATURATION_DELTA shader_injection.night_saturation_delta
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION shader_injection.tone_map_highlight_saturation
#define RENODX_TONE_MAP_BLOWOUT shader_injection.tone_map_blowout
#define RENODX_TONE_MAP_FLARE shader_injection.tone_map_flare
#define RENODX_PSYCHOV_HUE_SHIFT shader_injection.psychov_hue_shift
#define RENODX_PSYCHOV_CONE_RESPONSE_EXPONENT shader_injection.psychov_cone_response_exponent
#define RENODX_PSYCHOV_ADAPTATION_ANCHOR shader_injection.psychov_adaptation_anchor
#define RENODX_PSYCHOV_BACKGROUND_ANCHOR shader_injection.psychov_background_anchor
#define RENODX_PSYCHOV_GAMUT_COMPRESSION shader_injection.psychov_gamut_compression
#define WITCHER_MODE_FLAG(flag) float((asuint(shader_injection.mode_flags) & (flag)) != 0u)
#define RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE WITCHER_MODE_FLAG(WITCHER_FLAG_GAMUT_TARGET)
#define RENODX_PSYCHOV_COMPRESSION shader_injection.psychov_compression

#define CUSTOM_CA_MODE WITCHER_MODE_FLAG(WITCHER_FLAG_CA)
#define CUSTOM_CA_INTENSITY shader_injection.chromatic_aberration_intensity
#define CUSTOM_CA_START_OFFSET shader_injection.chromatic_aberration_start_offset
#define CUSTOM_SHARPENING_MODE WITCHER_MODE_FLAG(WITCHER_FLAG_SHARPENING)
#define CUSTOM_SHARPENING shader_injection.sharpening
#define CUSTOM_FILM_GRAIN shader_injection.film_grain
#define CUSTOM_RANDOM shader_injection.random_seed
#define CUSTOM_VIGNETTE_STRENGTH shader_injection.vignette_strength
#define CUSTOM_VIGNETTE_BLACK_FLOOR WITCHER_MODE_FLAG(WITCHER_FLAG_VIGNETTE_BLACK)
#define CUSTOM_NATIVE_BRIGHTNESS_COMPENSATION WITCHER_MODE_FLAG(WITCHER_FLAG_NATIVE_BRIGHTNESS | WITCHER_FLAG_NATIVE_BRIGHTNESS_DARKEN_ONLY)
#define CUSTOM_NATIVE_BRIGHTNESS_DARKEN_ONLY WITCHER_MODE_FLAG(WITCHER_FLAG_NATIVE_BRIGHTNESS_DARKEN_ONLY)
#define CUSTOM_LUT_STRENGTH shader_injection.custom_lut_strength
#define CUSTOM_LUT_SCALING shader_injection.custom_lut_scaling
float WitcherColorGradeStrength(uint shift) {
  uint packed = asuint(shader_injection.custom_color_grading);
  return (packed & WITCHER_GRADE_SPLIT_MASK) == WITCHER_GRADE_SPLIT_TAG
      ? float((packed >> shift) & WITCHER_GRADE_STRENGTH_MASK) / float(WITCHER_GRADE_STRENGTH_MASK)
      : shader_injection.custom_color_grading;
}
#define CUSTOM_COLOR_GRADING_LUMINANCE WitcherColorGradeStrength(0u)
#define CUSTOM_COLOR_GRADING_CHROMA WitcherColorGradeStrength(WITCHER_GRADE_CHROMA_SHIFT)

#define WITCHER_EFFECT_STRENGTH(shift) (float((asuint(shader_injection.effect_strengths) >> (shift)) & 127u) * 0.02f)
#define CUSTOM_BLUR_STRENGTH WITCHER_EFFECT_STRENGTH(WITCHER_EFFECT_BLUR_SHIFT)
#define CUSTOM_SHAFTS_STRENGTH WITCHER_EFFECT_STRENGTH(WITCHER_EFFECT_SHAFTS_SHIFT)
#define CUSTOM_LENS_STRENGTH WITCHER_EFFECT_STRENGTH(WITCHER_EFFECT_LENS_SHIFT)
#define CUSTOM_BLOOM_STRENGTH WITCHER_EFFECT_STRENGTH(WITCHER_EFFECT_BLOOM_SHIFT)

// Scene intermediates use BT.709; the native output pass encodes BT.2020 PQ.
#include "../../shaders/color.hlsl"
#include "../../shaders/colorcorrect.hlsl"
#include "../../shaders/math.hlsl"
#endif

#endif  // SRC_GAMES_THEWITCHER3REMASTERED_SHARED_H_
