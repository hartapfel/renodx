/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#ifndef SRC_GAMES_RESONANCEPLAGUETALELEGACY_SHARED_H_
#define SRC_GAMES_RESONANCEPLAGUETALELEGACY_SHARED_H_

struct ShaderInjectData {
  float peak_white_nits;
  float diffuse_white_nits;
  float ui_white_nits;
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
  float gamma_correction;
  float lut_luminance_curve_strength;

  float custom_film_grain_type;
  float custom_film_grain_strength;
  float custom_sharpness;
  float custom_sharpening_type;

  float custom_random;
  float custom_chromatic_aberration_type;
  float custom_chromatic_aberration_strength;
  float padding_3;
};

#ifdef __cplusplus
static_assert(sizeof(ShaderInjectData) == 96);
#endif

#ifndef __cplusplus
cbuffer shader_injection : register(b13, space50) {
  ShaderInjectData shader_injection : packoffset(c0);
}

#define RENODX_TONE_MAP_TYPE shader_injection.tone_map_type
#define RENODX_PEAK_WHITE_NITS shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS shader_injection.diffuse_white_nits
#define RENODX_GRAPHICS_WHITE_NITS 203.f
#define RENODX_UI_WHITE_NITS shader_injection.ui_white_nits
#define RENODX_GAMMA_CORRECTION shader_injection.gamma_correction
#define RENODX_PSYCHOV_HUE_SHIFT shader_injection.psychov_hue_shift

// The native HDR transformer decodes this intermediate as sRGB. Keep that
// transport encoding fixed so RenderIntermediatePass's EOTF correction is not
// cancelled by a matching gamma encode before the native sRGB decode.
#define RENODX_INTERMEDIATE_ENCODING renodx::draw::ENCODING_SRGB

#define RENODX_TONE_MAP_EXPOSURE shader_injection.tone_map_exposure
#define RENODX_TONE_MAP_GAMMA shader_injection.tone_map_gamma
#define RENODX_TONE_MAP_HIGHLIGHTS shader_injection.tone_map_highlights
#define RENODX_TONE_MAP_SHADOWS shader_injection.tone_map_shadows
#define RENODX_TONE_MAP_CONTRAST shader_injection.tone_map_contrast
#define RENODX_TONE_MAP_SATURATION shader_injection.tone_map_saturation
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION shader_injection.tone_map_highlight_saturation
#define RENODX_TONE_MAP_BLOWOUT shader_injection.tone_map_blowout
#define RENODX_TONE_MAP_FLARE shader_injection.tone_map_flare
#define CUSTOM_FILM_GRAIN_TYPE shader_injection.custom_film_grain_type
#define CUSTOM_FILM_GRAIN_STRENGTH shader_injection.custom_film_grain_strength
#define CUSTOM_RANDOM shader_injection.custom_random
#define CUSTOM_SHARPNESS shader_injection.custom_sharpness
#define CUSTOM_SHARPENING_TYPE shader_injection.custom_sharpening_type
#define CUSTOM_CHROMATIC_ABERRATION_TYPE shader_injection.custom_chromatic_aberration_type
#define CUSTOM_CHROMATIC_ABERRATION_STRENGTH shader_injection.custom_chromatic_aberration_strength
#define RENODX_LUT_LUMINANCE_CURVE_STRENGTH shader_injection.lut_luminance_curve_strength

#define RENODX_SWAP_CHAIN_OUTPUT_PRESET renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_HDR10

#include "../../shaders/renodx.hlsl"
#endif

#endif  // SRC_GAMES_RESONANCEPLAGUETALELEGACY_SHARED_H_
