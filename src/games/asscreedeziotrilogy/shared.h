#ifndef SRC_GAMES_ASSCREEDEZIOTRILOGY_SHARED_H_
#define SRC_GAMES_ASSCREEDEZIOTRILOGY_SHARED_H_

// Keep the AC2/Brotherhood control layout; seven float4 registers on DX9.
struct ShaderInjectData {
  float output_mode;
  float paper_white_nits;
  float peak_white_nits;
  float swap_chain_decoding;
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
  float color_filter;
  float ui_premultiplied;
  float injection_version;
  float white_gradient_intensity;
  float padding_1;
  float padding_2;
};

#ifdef __cplusplus
static_assert(sizeof(ShaderInjectData) == 112);
#else
#if (__SHADER_TARGET_MAJOR == 3)
float4 shader_injection[7] : register(c50);
#else
#if ((__SHADER_TARGET_MAJOR == 5 && __SHADER_TARGET_MINOR >= 1) || __SHADER_TARGET_MAJOR >= 6)
cbuffer shader_injection : register(b13, space50) {
#else
cbuffer shader_injection : register(b13) {
#endif
  ShaderInjectData shader_injection : packoffset(c0);
}
#endif

#if (__SHADER_TARGET_MAJOR == 3)
#define RENODX_PEAK_WHITE_NITS          shader_injection[0].z
#define RENODX_DIFFUSE_WHITE_NITS       shader_injection[0].y
#define RENODX_GRAPHICS_WHITE_NITS      shader_injection[5].y
#define RENODX_SWAP_CHAIN_SCALING_NITS  shader_injection[0].y
#define RENODX_GAMMA_CORRECTION         renodx::draw::GAMMA_CORRECTION_NONE
// Vanilla/Off preserves sRGB; the native PsychoV path composes in gamma 2.2.
#define RENODX_SWAP_CHAIN_DECODING      (shader_injection[1].x == 0.f ? renodx::draw::ENCODING_SRGB : renodx::draw::ENCODING_GAMMA_2_2)
#define RENODX_SWAP_CHAIN_OUTPUT_PRESET renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_HDR10

#define RENODX_TONE_MAP_TYPE                  shader_injection[1].x
#define RENODX_TONE_MAP_EXPOSURE              shader_injection[1].y
#define RENODX_TONE_MAP_GAMMA                 shader_injection[1].z
#define RENODX_TONE_MAP_HIGHLIGHTS            shader_injection[1].w
#define RENODX_TONE_MAP_SHADOWS               shader_injection[2].x
#define RENODX_TONE_MAP_CONTRAST              shader_injection[2].y
#define RENODX_TONE_MAP_SATURATION            shader_injection[2].z
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION  shader_injection[2].w
#define RENODX_TONE_MAP_BLOWOUT               shader_injection[3].x
#define RENODX_TONE_MAP_FLARE                 shader_injection[3].y
#define RENODX_PSYCHOV_HUE_SHIFT              shader_injection[3].z
#define RENODX_PSYCHOV_CONE_RESPONSE_EXPONENT shader_injection[3].w
#define RENODX_PSYCHOV_ADAPTATION_ANCHOR      shader_injection[4].x
#define RENODX_PSYCHOV_BACKGROUND_ANCHOR      shader_injection[4].y
#define RENODX_PSYCHOV_GAMUT_COMPRESSION      shader_injection[4].z
#define RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE shader_injection[4].w
#define RENODX_PSYCHOV_COMPRESSION            shader_injection[5].x

#define CUSTOM_COLOR_FILTER      shader_injection[5].z
#define CUSTOM_UI_PREMULTIPLIED  shader_injection[5].w
#define CUSTOM_INJECTION_VERSION shader_injection[6].x
#define CUSTOM_WHITE_GRADIENT_INTENSITY shader_injection[6].y
#else
#define RENODX_PEAK_WHITE_NITS          shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS       shader_injection.paper_white_nits
#define RENODX_GRAPHICS_WHITE_NITS      shader_injection.graphics_white_nits
#define RENODX_SWAP_CHAIN_SCALING_NITS  shader_injection.paper_white_nits
#define RENODX_GAMMA_CORRECTION         renodx::draw::GAMMA_CORRECTION_NONE
// Vanilla/Off preserves sRGB; the native PsychoV path composes in gamma 2.2.
#define RENODX_SWAP_CHAIN_DECODING      (shader_injection.tone_map_type == 0.f ? renodx::draw::ENCODING_SRGB : renodx::draw::ENCODING_GAMMA_2_2)
#define RENODX_SWAP_CHAIN_OUTPUT_PRESET renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_HDR10

#define RENODX_TONE_MAP_TYPE                  shader_injection.tone_map_type
#define RENODX_TONE_MAP_EXPOSURE              shader_injection.tone_map_exposure
#define RENODX_TONE_MAP_GAMMA                 shader_injection.tone_map_gamma
#define RENODX_TONE_MAP_HIGHLIGHTS            shader_injection.tone_map_highlights
#define RENODX_TONE_MAP_SHADOWS               shader_injection.tone_map_shadows
#define RENODX_TONE_MAP_CONTRAST              shader_injection.tone_map_contrast
#define RENODX_TONE_MAP_SATURATION            shader_injection.tone_map_saturation
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION  shader_injection.tone_map_highlight_saturation
#define RENODX_TONE_MAP_BLOWOUT               shader_injection.tone_map_blowout
#define RENODX_TONE_MAP_FLARE                 shader_injection.tone_map_flare
#define RENODX_PSYCHOV_HUE_SHIFT              shader_injection.psychov_hue_shift
#define RENODX_PSYCHOV_CONE_RESPONSE_EXPONENT shader_injection.psychov_cone_response_exponent
#define RENODX_PSYCHOV_ADAPTATION_ANCHOR      shader_injection.psychov_adaptation_anchor
#define RENODX_PSYCHOV_BACKGROUND_ANCHOR      shader_injection.psychov_background_anchor
#define RENODX_PSYCHOV_GAMUT_COMPRESSION      shader_injection.psychov_gamut_compression
#define RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE shader_injection.psychov_gamut_compression_mode
#define RENODX_PSYCHOV_COMPRESSION            shader_injection.psychov_compression

#define CUSTOM_COLOR_FILTER      shader_injection.color_filter
#define CUSTOM_UI_PREMULTIPLIED  shader_injection.ui_premultiplied
#define CUSTOM_INJECTION_VERSION shader_injection.injection_version
#define CUSTOM_WHITE_GRADIENT_INTENSITY shader_injection.white_gradient_intensity
#endif

#include "../../shaders/renodx.hlsl"
#endif

#endif  // SRC_GAMES_ASSCREEDEZIOTRILOGY_SHARED_H_
