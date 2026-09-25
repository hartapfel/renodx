#ifndef SRC_GAMES_GOTSUSHIMA_INTERMEDIATE_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_INTERMEDIATE_HLSLI_

#include "./sdr.hlsli"

// HDR uses a bounded gamma-2.2 composition buffer for scene and UI. SDR keeps
// the native HUD untouched and converts only the PsychoV scene to the signal
// expected by the game's unchanged BT.709 final output transfer.
float3 GhostEncodeIntermediate(float3 color_nits) {
  const float3 normalized = max(color_nits, 0.f.xxx) / RENODX_INTERMEDIATE_SCALING;
  if (GHOST_SDR_OUTPUT != 0.f) {
    return GhostInverseSDRDisplayCode(renodx::color::srgb::EncodeSafe(saturate(normalized)));
  }
  return renodx::color::gamma::EncodeSafe(normalized, 2.2f);
}

float3 GhostDecodeIntermediate(float3 encoded) {
  if (GHOST_SDR_OUTPUT != 0.f) {
    return renodx::color::srgb::DecodeSafe(GhostSDRDisplayCode(saturate(encoded)));
  }
  return renodx::color::gamma::DecodeSafe(max(encoded, 0.f.xxx), 2.2f);
}

#endif  // SRC_GAMES_GOTSUSHIMA_INTERMEDIATE_HLSLI_
