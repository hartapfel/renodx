#ifndef SRC_GAMES_GHOSTOFTSUSHIMA_UI_HLSLI_
#define SRC_GAMES_GHOSTOFTSUSHIMA_UI_HLSLI_

#include "./shared.h"

bool GhostIsUIOverrideActive() {
  return RENODX_TONE_MAP_TYPE != 0.f
         && RENODX_PEAK_WHITE_NITS > 0.f
         && RENODX_GRAPHICS_WHITE_NITS > 0.f;
}

// Input is the game's encoded HUD color before its native brightness
// multiplier. Pass the RGB coverage for premultiplied shaders, or 1 for
// straight alpha. Some overlays already decode their texture to linear;
// linear_input preserves that result without a second SDR decode.
// Keep coverage outside the nonlinear color transform.
float3 GhostRenderUI(float3 color_bt709, float coverage, bool linear_input = false) {
  if (coverage <= 0.f) return 0.f.xxx;
  color_bt709 /= coverage;

  // HUD textures/tints are display-encoded colors, not PQ values. Vanilla
  // scales them into the scene intermediate and applies its display curve
  // after blending. Decode the SDR color here, then use the same forward
  // SDR gamma emulation as the scene before encoding for our PQ compositor.
  float3 linear_bt709 = linear_input
                           ? color_bt709
                           : renodx::color::srgb::DecodeSafe(color_bt709);
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    linear_bt709 = renodx::color::correct::GammaSafe(linear_bt709, false, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    linear_bt709 = renodx::color::correct::GammaSafe(linear_bt709, false, 2.4f);
  }
  return renodx::color::pq::EncodeSafe(
             renodx::color::bt2020::from::BT709(linear_bt709),
             RENODX_GRAPHICS_WHITE_NITS)
         * coverage;
}

#endif  // SRC_GAMES_GHOSTOFTSUSHIMA_UI_HLSLI_
