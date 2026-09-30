#ifndef SRC_GAMES_THEWITCHER3REMASTERED_SHARED_H_
#define SRC_GAMES_THEWITCHER3REMASTERED_SHARED_H_

// Keep scalar order identical in the C++ injection payload and HLSL cbuffer.
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
  float psychov_gamut_compression_mode;
  float psychov_compression;
  float graphics_white_nits;

  float chromatic_aberration_mode;
  float chromatic_aberration_intensity;
  float chromatic_aberration_start_offset;
  float sharpening_mode;
  float sharpening;
  float film_grain;
  float random_seed;
  float bloom_strength;
  float vignette_strength;
  float vignette_black_floor;
  float native_brightness_compensation;
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
#define RENODX_TONE_MAP_SATURATION shader_injection.tone_map_saturation
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION shader_injection.tone_map_highlight_saturation
#define RENODX_TONE_MAP_BLOWOUT shader_injection.tone_map_blowout
#define RENODX_TONE_MAP_FLARE shader_injection.tone_map_flare
#define RENODX_PSYCHOV_HUE_SHIFT shader_injection.psychov_hue_shift
#define RENODX_PSYCHOV_CONE_RESPONSE_EXPONENT shader_injection.psychov_cone_response_exponent
#define RENODX_PSYCHOV_ADAPTATION_ANCHOR shader_injection.psychov_adaptation_anchor
#define RENODX_PSYCHOV_BACKGROUND_ANCHOR shader_injection.psychov_background_anchor
#define RENODX_PSYCHOV_GAMUT_COMPRESSION shader_injection.psychov_gamut_compression
#define RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE shader_injection.psychov_gamut_compression_mode
#define RENODX_PSYCHOV_COMPRESSION shader_injection.psychov_compression

#define CUSTOM_CA_MODE shader_injection.chromatic_aberration_mode
#define CUSTOM_CA_INTENSITY shader_injection.chromatic_aberration_intensity
#define CUSTOM_CA_START_OFFSET shader_injection.chromatic_aberration_start_offset
#define CUSTOM_SHARPENING_MODE shader_injection.sharpening_mode
#define CUSTOM_SHARPENING shader_injection.sharpening
#define CUSTOM_FILM_GRAIN shader_injection.film_grain
#define CUSTOM_RANDOM shader_injection.random_seed
#define CUSTOM_BLOOM_STRENGTH shader_injection.bloom_strength
#define CUSTOM_VIGNETTE_STRENGTH shader_injection.vignette_strength
#define CUSTOM_VIGNETTE_BLACK_FLOOR shader_injection.vignette_black_floor
#define CUSTOM_NATIVE_BRIGHTNESS_COMPENSATION shader_injection.native_brightness_compensation

// Scene intermediates use BT.709; the native output pass encodes BT.2020 PQ.
#include "../../shaders/color.hlsl"
#include "../../shaders/colorcorrect.hlsl"
#include "../../shaders/math.hlsl"
#endif

#endif  // SRC_GAMES_THEWITCHER3REMASTERED_SHARED_H_
