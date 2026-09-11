#ifndef SRC_GAMES_GOTSUSHIMA_INTERMEDIATE_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_INTERMEDIATE_HLSLI_

#include "./shared.h"

// Keep the bounded composition buffer in a power-law encoding, like the
// native pre-display signal. PQ alpha blending darkens partially covered
// black outlines and changes the apparent weight of text and icons.
// Scene and UI use the same scale; their independent white levels are
// already expressed in nits before this transport conversion.
float3 GhostEncodeIntermediate(float3 color_bt2020_nits) {
  return renodx::color::gamma::EncodeSafe(
      max(color_bt2020_nits, 0.f.xxx) / RENODX_INTERMEDIATE_SCALING,
      2.2f);
}

#endif  // SRC_GAMES_GOTSUSHIMA_INTERMEDIATE_HLSLI_
