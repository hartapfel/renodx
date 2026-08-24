/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#ifndef SRC_GAMES_APTREQUIEM_SHARED_H_
#define SRC_GAMES_APTREQUIEM_SHARED_H_

struct ShaderInjectData {
  float tone_map_type;
  float peak_white_nits;
  float diffuse_white_nits;
  float psychov_hue_shift;

  float tone_map_exposure;
  float tone_map_gamma;
  float tone_map_highlights;
  float tone_map_shadows;

  float tone_map_contrast;
  float tone_map_saturation;
  float tone_map_highlight_saturation;
  float tone_map_blowout;

  float tone_map_flare;
  float color_grade_lut_scaling;
  float tone_map_color_scale;
  float custom_sharpness;

  float tone_map_white_clip;
  float psychov_wide_gamut;
  float padding_1;
  float padding_2;
};

#ifdef __cplusplus
static_assert(sizeof(ShaderInjectData) == 80);
#endif

#ifndef __cplusplus
cbuffer shader_injection : register(b13, space50) {
  ShaderInjectData shader_injection : packoffset(c0);
}

#define RENODX_TONE_MAP_TYPE shader_injection.tone_map_type
#define RENODX_PEAK_WHITE_NITS shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS shader_injection.diffuse_white_nits
#define RENODX_PSYCHOV_HUE_SHIFT shader_injection.psychov_hue_shift

#define RENODX_TONE_MAP_EXPOSURE shader_injection.tone_map_exposure
#define RENODX_TONE_MAP_GAMMA shader_injection.tone_map_gamma
#define RENODX_TONE_MAP_HIGHLIGHTS shader_injection.tone_map_highlights
#define RENODX_TONE_MAP_SHADOWS shader_injection.tone_map_shadows
#define RENODX_TONE_MAP_CONTRAST shader_injection.tone_map_contrast
#define RENODX_TONE_MAP_SATURATION shader_injection.tone_map_saturation
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION shader_injection.tone_map_highlight_saturation
#define RENODX_TONE_MAP_BLOWOUT shader_injection.tone_map_blowout
#define RENODX_TONE_MAP_FLARE shader_injection.tone_map_flare
#define RENODX_COLOR_GRADE_LUT_SCALING shader_injection.color_grade_lut_scaling
#define RENODX_TONE_MAP_COLOR_SCALE shader_injection.tone_map_color_scale
#define RENODX_TONE_MAP_WHITE_CLIP shader_injection.tone_map_white_clip
#define RENODX_PSYCHOV_WIDE_GAMUT shader_injection.psychov_wide_gamut
#define CUSTOM_SHARPNESS shader_injection.custom_sharpness

#include "../../shaders/renodx.hlsl"
#endif

#endif  // SRC_GAMES_APTREQUIEM_SHARED_H_
