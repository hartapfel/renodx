#ifndef SRC_GAMES_ASSCREED2_SHARED_H_
#define SRC_GAMES_ASSCREED2_SHARED_H_

// Must stay 32-bit aligned for shader constant-buffer injection.
struct ShaderInjectData {
  float tone_map_type;
  float peak_white_nits;
  float diffuse_white_nits;
  float graphics_white_nits;

  float gamma_correction;
  float tone_map_hue_shift;
  float tone_map_white_clip;
  float tone_map_exposure;

  float tone_map_highlights;
  float tone_map_shadows;
  float tone_map_contrast;
  float tone_map_saturation;

  float tone_map_highlight_saturation;
  float tone_map_blowout;
  float tone_map_dechroma;
  float tone_map_flare;

  float color_grade_strength;
  float custom_random;
  float custom_grain_strength;
  float custom_video_hdr;

  float color_grade_scaling;
  float padding_3;
  float padding_4;
  float padding_5;
};

#ifndef __cplusplus

#if __SHADER_TARGET_MAJOR < 4
float4 shader_injection[6] : register(c50);

#define RENODX_TONE_MAP_TYPE                 shader_injection[0].x
#define RENODX_PEAK_WHITE_NITS               shader_injection[0].y
#define RENODX_DIFFUSE_WHITE_NITS            shader_injection[0].z
#define RENODX_GRAPHICS_WHITE_NITS           shader_injection[0].w
#define RENODX_GAMMA_CORRECTION              shader_injection[1].x
#define RENODX_TONE_MAP_HUE_SHIFT            shader_injection[1].y
#define RENODX_TONE_MAP_WHITE_CLIP           shader_injection[1].z
#define RENODX_TONE_MAP_EXPOSURE             shader_injection[1].w
#define RENODX_TONE_MAP_HIGHLIGHTS           shader_injection[2].x
#define RENODX_TONE_MAP_SHADOWS              shader_injection[2].y
#define RENODX_TONE_MAP_CONTRAST             shader_injection[2].z
#define RENODX_TONE_MAP_SATURATION           shader_injection[2].w
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION shader_injection[3].x
#define RENODX_TONE_MAP_BLOWOUT              shader_injection[3].y
#define RENODX_TONE_MAP_DECHROMA             shader_injection[3].z
#define RENODX_TONE_MAP_FLARE                shader_injection[3].w
#define RENODX_COLOR_GRADE_STRENGTH          shader_injection[4].x
#define CUSTOM_RANDOM                        shader_injection[4].y
#define CUSTOM_GRAIN_STRENGTH                shader_injection[4].z
#define CUSTOM_VIDEO_HDR                     shader_injection[4].w
#define RENODX_COLOR_GRADE_SCALING           shader_injection[5].x

#else
cbuffer cb13 : register(b13) {
  ShaderInjectData shader_injection : packoffset(c0);
}

#define RENODX_TONE_MAP_TYPE                 shader_injection.tone_map_type
#define RENODX_PEAK_WHITE_NITS               shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS            shader_injection.diffuse_white_nits
#define RENODX_GRAPHICS_WHITE_NITS           shader_injection.graphics_white_nits
#define RENODX_GAMMA_CORRECTION              shader_injection.gamma_correction
#define RENODX_TONE_MAP_HUE_SHIFT            shader_injection.tone_map_hue_shift
#define RENODX_TONE_MAP_BLOWOUT              shader_injection.tone_map_blowout
#define RENODX_TONE_MAP_DECHROMA             shader_injection.tone_map_dechroma
#define RENODX_TONE_MAP_WHITE_CLIP           shader_injection.tone_map_white_clip
#define RENODX_TONE_MAP_EXPOSURE             shader_injection.tone_map_exposure
#define RENODX_TONE_MAP_HIGHLIGHTS           shader_injection.tone_map_highlights
#define RENODX_TONE_MAP_SHADOWS              shader_injection.tone_map_shadows
#define RENODX_TONE_MAP_CONTRAST             shader_injection.tone_map_contrast
#define RENODX_TONE_MAP_SATURATION           shader_injection.tone_map_saturation
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION shader_injection.tone_map_highlight_saturation
#define RENODX_TONE_MAP_FLARE                shader_injection.tone_map_flare
#define RENODX_COLOR_GRADE_STRENGTH          shader_injection.color_grade_strength
#define CUSTOM_RANDOM                        shader_injection.custom_random
#define CUSTOM_GRAIN_STRENGTH                shader_injection.custom_grain_strength
#define CUSTOM_VIDEO_HDR                     shader_injection.custom_video_hdr
#define RENODX_COLOR_GRADE_SCALING           shader_injection.color_grade_scaling
#endif

#include "../../shaders/renodx.hlsl"

#endif

#endif  // SRC_GAMES_ASSCREED2_SHARED_H_
