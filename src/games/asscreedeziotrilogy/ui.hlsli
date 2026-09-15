#ifndef SRC_GAMES_ASSCREEDEZIOTRILOGY_UI_HLSLI_
#define SRC_GAMES_ASSCREEDEZIOTRILOGY_UI_HLSLI_

#include "./shared.h"

float3 AC2ScaleUI(float4 color) {
  if (CUSTOM_INJECTION_VERSION != 30.f || RENODX_TONE_MAP_TYPE != 1.f
      || RENODX_DIFFUSE_WHITE_NITS <= 0.f || RENODX_GRAPHICS_WHITE_NITS == RENODX_DIFFUSE_WHITE_NITS) {
    return color.rgb;
  }
  const float alpha = CUSTOM_UI_PREMULTIPLIED != 0.f ? color.a : 1.f;
  if (alpha <= 0.f) return color.rgb;
  return renodx::draw::EncodeColor(
      renodx::draw::DecodeColor(color.rgb / alpha, RENODX_SWAP_CHAIN_DECODING)
          * (RENODX_GRAPHICS_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS),
      RENODX_SWAP_CHAIN_DECODING) * alpha;
}

#endif  // SRC_GAMES_ASSCREEDEZIOTRILOGY_UI_HLSLI_
