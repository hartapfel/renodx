#ifndef SRC_GAMES_GHOSTOFTSUSHIMA_SHARED_H_
#define SRC_GAMES_GHOSTOFTSUSHIMA_SHARED_H_

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

  float gamma_correction;
  float psychov_hue_shift;
  float psychov_cone_response_exponent;
  float psychov_adaptation_anchor;

  float psychov_background_anchor;
  float psychov_gamut_compression;
  float psychov_gamut_compression_mode;
  float psychov_compression;
};

#ifdef __cplusplus
static_assert(sizeof(ShaderInjectData) == 80);
#endif

#ifndef __cplusplus
cbuffer shader_injection : register(b13, space50) {
  ShaderInjectData shader_injection : packoffset(c0);
}

#define RENODX_PEAK_WHITE_NITS shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS shader_injection.diffuse_white_nits
#define RENODX_GRAPHICS_WHITE_NITS 203.f
#define RENODX_TONE_MAP_TYPE shader_injection.tone_map_type
#define RENODX_TONE_MAP_EXPOSURE shader_injection.tone_map_exposure
#define RENODX_TONE_MAP_GAMMA shader_injection.tone_map_gamma
#define RENODX_TONE_MAP_HIGHLIGHTS shader_injection.tone_map_highlights
#define RENODX_TONE_MAP_SHADOWS shader_injection.tone_map_shadows
#define RENODX_TONE_MAP_CONTRAST shader_injection.tone_map_contrast
#define RENODX_TONE_MAP_SATURATION shader_injection.tone_map_saturation
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION shader_injection.tone_map_highlight_saturation
#define RENODX_TONE_MAP_BLOWOUT shader_injection.tone_map_blowout
#define RENODX_TONE_MAP_FLARE shader_injection.tone_map_flare
#define RENODX_GAMMA_CORRECTION shader_injection.gamma_correction
#define RENODX_PSYCHOV_HUE_SHIFT shader_injection.psychov_hue_shift
#define RENODX_PSYCHOV_CONE_RESPONSE_EXPONENT shader_injection.psychov_cone_response_exponent
#define RENODX_PSYCHOV_ADAPTATION_ANCHOR shader_injection.psychov_adaptation_anchor
#define RENODX_PSYCHOV_BACKGROUND_ANCHOR shader_injection.psychov_background_anchor
#define RENODX_PSYCHOV_GAMUT_COMPRESSION shader_injection.psychov_gamut_compression
#define RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE shader_injection.psychov_gamut_compression_mode
#define RENODX_PSYCHOV_COMPRESSION shader_injection.psychov_compression

// Carry the PsychoV result as absolute-nit PQ through the game's bounded
// post-tonemap RGB10A2 UNORM target. The final pass only clamps and re-encodes
// that PQ signal; it must not apply an SDR transfer to the composed frame.
#define RENODX_INTERMEDIATE_SCALING RENODX_DIFFUSE_WHITE_NITS
#define RENODX_INTERMEDIATE_ENCODING renodx::draw::ENCODING_PQ
#define RENODX_SWAP_CHAIN_DECODING renodx::draw::ENCODING_PQ
#define RENODX_SWAP_CHAIN_DECODING_COLOR_SPACE \
  renodx::color::convert::COLOR_SPACE_BT2020
#define RENODX_SWAP_CHAIN_SCALING_NITS 1.f
#define RENODX_SWAP_CHAIN_OUTPUT_PRESET renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_HDR10

#include "../../shaders/renodx.hlsl"
#endif

#endif  // SRC_GAMES_GHOSTOFTSUSHIMA_SHARED_H_
