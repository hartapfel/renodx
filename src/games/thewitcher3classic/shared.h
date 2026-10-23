#ifndef THEWITCHER3CLASSIC_SHARED_H_
#define THEWITCHER3CLASSIC_SHARED_H_

#define CLASSIC_TONE_MAP_VANILLA 0.f
#define CLASSIC_TONE_MAP_PSYCHOV31 1.f

struct ShaderInjectData {
  float tone_map_type;
  float peak_white_nits;
  float diffuse_white_nits;
  float graphics_white_nits;
  float tone_map_exposure;
  float tone_map_highlights;
  float tone_map_shadows;
  float tone_map_contrast;
  float tone_map_highlight_contrast;
  float tone_map_shadow_contrast;
  float tone_map_saturation;
  float tone_map_highlight_saturation;
  float tone_map_blowout;
  float tone_map_flare;
  float tone_map_gamma;
  float psychov_adaptation_anchor;
  float psychov_background_anchor;
  float psychov_highlight_hue;
  float psychov_gamut_compression;
  float psychov_gamut_compression_mode;
  float psychov_compression;
  float custom_bloom;
  float custom_lens_dirt;
  float custom_sunshafts_strength;
  float custom_blur;
  float sharpening_mode;
  float sharpening_strength;
  float chromatic_aberration_mode;
  float chromatic_aberration_intensity;
  float chromatic_aberration_start_offset;
  float film_grain;
  float random_seed;
  float vignette_strength;
  float vignette_black_floor;
  float reserved_effects[2];
};

#ifdef __cplusplus
static_assert(sizeof(ShaderInjectData) == 144);
#else
// b13 is unused by the captured Classic tonemap and final grading draws.
cbuffer classic_injection : register(b13) {
  ShaderInjectData shader_injection : packoffset(c0);
}
#define RENODX_TONE_MAP_TYPE shader_injection.tone_map_type
#define RENODX_PEAK_WHITE_NITS shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS shader_injection.diffuse_white_nits
#define RENODX_GRAPHICS_WHITE_NITS shader_injection.graphics_white_nits
#define RENODX_TONE_MAP_EXPOSURE shader_injection.tone_map_exposure
#define RENODX_TONE_MAP_HIGHLIGHTS shader_injection.tone_map_highlights
#define RENODX_TONE_MAP_SHADOWS shader_injection.tone_map_shadows
#define RENODX_TONE_MAP_CONTRAST shader_injection.tone_map_contrast
#define RENODX_TONE_MAP_HIGHLIGHT_CONTRAST shader_injection.tone_map_highlight_contrast
#define RENODX_TONE_MAP_SHADOW_CONTRAST shader_injection.tone_map_shadow_contrast
#define RENODX_TONE_MAP_SATURATION shader_injection.tone_map_saturation
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION shader_injection.tone_map_highlight_saturation
#define RENODX_TONE_MAP_BLOWOUT shader_injection.tone_map_blowout
#define RENODX_TONE_MAP_FLARE shader_injection.tone_map_flare
#define RENODX_TONE_MAP_GAMMA shader_injection.tone_map_gamma
#define RENODX_PSYCHOV_ADAPTATION_ANCHOR shader_injection.psychov_adaptation_anchor
#define RENODX_PSYCHOV_BACKGROUND_ANCHOR shader_injection.psychov_background_anchor
#define RENODX_PSYCHOV_HIGHLIGHT_HUE shader_injection.psychov_highlight_hue
#define RENODX_PSYCHOV_GAMUT_COMPRESSION shader_injection.psychov_gamut_compression
#define RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE shader_injection.psychov_gamut_compression_mode
#define RENODX_PSYCHOV_COMPRESSION shader_injection.psychov_compression
#define CUSTOM_SHARPENING_MODE shader_injection.sharpening_mode
#define CUSTOM_SHARPENING shader_injection.sharpening_strength
#define CUSTOM_CA_MODE shader_injection.chromatic_aberration_mode
#define CUSTOM_CA_INTENSITY shader_injection.chromatic_aberration_intensity
#define CUSTOM_CA_START_OFFSET shader_injection.chromatic_aberration_start_offset
#define RENODX_SWAP_CHAIN_OUTPUT_PRESET renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_HDR10
#define RENODX_SWAP_CHAIN_DECODING renodx::draw::ENCODING_GAMMA_2_2
#define RENODX_SWAP_CHAIN_SCALING_NITS shader_injection.graphics_white_nits
#define RENODX_SWAP_CHAIN_CLAMP_NITS max(shader_injection.peak_white_nits, shader_injection.graphics_white_nits)
#include "../../shaders/renodx.hlsl"
#endif
#endif
