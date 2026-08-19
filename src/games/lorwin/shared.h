#ifndef SRC_GAMES_LORWIN_SHARED_H_
#define SRC_GAMES_LORWIN_SHARED_H_

// Must be 32-bit aligned.
struct ShaderInjectData {
  float tone_map_type;
  float peak_white_nits;
  float diffuse_white_nits;
  float graphics_white_nits;

  float tone_map_exposure;
  float tone_map_highlights;
  float tone_map_shadows;
  float tone_map_contrast;

  float tone_map_saturation;
  float tone_map_highlight_saturation;
  float tone_map_blowout;
  float tone_map_flare;

  float tone_map_hue_shift;
  float tone_map_white_clip;
  float tone_map_clamp_color_space;
  float tone_map_clamp_peak;

  float tone_map_hue_processor;
  float tone_map_per_channel;
  float gamma_correction;

  float swap_chain_decoding;
  float swap_chain_gamma_correction;
  float swap_chain_custom_color_space;
  float swap_chain_clamp_color_space;

  float swap_chain_encoding;
  float swap_chain_encoding_color_space;

  float scene_grade_strength;
  float custom_film_grain_type;
  float custom_film_grain_strength;
  float custom_random;
  float dlaa_debug_view;
  float dlaa_enabled;
  float hdr_output_active;
  float improved_ambient_occlusion;
  float improved_bloom;
  float improved_bloom_strength;
  float rcas_sharpening;
  float chromatic_aberration;
  float chromatic_aberration_strength;
  float chromatic_aberration_start;
  float chromatic_aberration_falloff;
  float chromatic_aberration_shape;
  float chromatic_aberration_saturation;
};

#ifndef __cplusplus
#if ((__SHADER_TARGET_MAJOR == 5 && __SHADER_TARGET_MINOR >= 1) || __SHADER_TARGET_MAJOR >= 6)
cbuffer shader_injection : register(b13, space50) {
#else
cbuffer shader_injection : register(b13) {
#endif
  ShaderInjectData shader_injection : packoffset(c0);
}

#define RENODX_HDR_OUTPUT_ACTIVE             shader_injection.hdr_output_active
#define RENODX_TONE_MAP_TYPE                 (RENODX_HDR_OUTPUT_ACTIVE != 0.f ? shader_injection.tone_map_type : 0.f)
#define RENODX_PEAK_WHITE_NITS               shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS            shader_injection.diffuse_white_nits
#define RENODX_GRAPHICS_WHITE_NITS           shader_injection.graphics_white_nits
#define RENODX_TONE_MAP_EXPOSURE             shader_injection.tone_map_exposure
#define RENODX_TONE_MAP_HIGHLIGHTS           shader_injection.tone_map_highlights
#define RENODX_TONE_MAP_SHADOWS              shader_injection.tone_map_shadows
#define RENODX_TONE_MAP_CONTRAST             shader_injection.tone_map_contrast
#define RENODX_TONE_MAP_SATURATION           shader_injection.tone_map_saturation
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION shader_injection.tone_map_highlight_saturation
#define RENODX_TONE_MAP_BLOWOUT              shader_injection.tone_map_blowout
#define RENODX_TONE_MAP_FLARE                shader_injection.tone_map_flare
#define RENODX_TONE_MAP_HUE_SHIFT            shader_injection.tone_map_hue_shift
#define RENODX_TONE_MAP_WHITE_CLIP           shader_injection.tone_map_white_clip
#define RENODX_TONE_MAP_CLAMP_COLOR_SPACE    shader_injection.tone_map_clamp_color_space
#define RENODX_TONE_MAP_CLAMP_PEAK           shader_injection.tone_map_clamp_peak
#define RENODX_TONE_MAP_HUE_PROCESSOR        shader_injection.tone_map_hue_processor
#define RENODX_TONE_MAP_PER_CHANNEL          shader_injection.tone_map_per_channel
#define RENODX_GAMMA_CORRECTION              shader_injection.gamma_correction
#define RENODX_SCENE_GRADE_STRENGTH          shader_injection.scene_grade_strength
#define CUSTOM_FILM_GRAIN_TYPE               shader_injection.custom_film_grain_type
#define CUSTOM_FILM_GRAIN_STRENGTH           shader_injection.custom_film_grain_strength
#define CUSTOM_RANDOM                        shader_injection.custom_random
#define CUSTOM_DLAA_DEBUG_VIEW                shader_injection.dlaa_debug_view
#define CUSTOM_DLAA_ENABLED                   shader_injection.dlaa_enabled
#define CUSTOM_IMPROVED_AMBIENT_OCCLUSION     shader_injection.improved_ambient_occlusion
#define CUSTOM_IMPROVED_BLOOM                 shader_injection.improved_bloom
#define CUSTOM_IMPROVED_BLOOM_STRENGTH        shader_injection.improved_bloom_strength
#define CUSTOM_RCAS_SHARPENING                shader_injection.rcas_sharpening
#define CUSTOM_CHROMATIC_ABERRATION            shader_injection.chromatic_aberration
#define CUSTOM_CHROMATIC_ABERRATION_STRENGTH   shader_injection.chromatic_aberration_strength
#define CUSTOM_CHROMATIC_ABERRATION_START      shader_injection.chromatic_aberration_start
#define CUSTOM_CHROMATIC_ABERRATION_FALLOFF    shader_injection.chromatic_aberration_falloff
#define CUSTOM_CHROMATIC_ABERRATION_SHAPE      shader_injection.chromatic_aberration_shape
#define CUSTOM_CHROMATIC_ABERRATION_SATURATION shader_injection.chromatic_aberration_saturation
#define RENODX_SWAP_CHAIN_DECODING           (RENODX_GAMMA_CORRECTION + 1.f)
#define RENODX_SWAP_CHAIN_GAMMA_CORRECTION   2.2f
#define RENODX_SWAP_CHAIN_CUSTOM_COLOR_SPACE renodx::color::convert::COLOR_SPACE_BT709
#define RENODX_SWAP_CHAIN_CLAMP_COLOR_SPACE  renodx::color::convert::COLOR_SPACE_BT2020
#define RENODX_SWAP_CHAIN_OUTPUT_PRESET      (RENODX_HDR_OUTPUT_ACTIVE != 0.f ? renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_HDR10 : renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_SDR)

#include "../../shaders/renodx.hlsl"

#endif

#endif  // SRC_GAMES_LORWIN_SHARED_H_
