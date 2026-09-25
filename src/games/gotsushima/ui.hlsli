#ifndef SRC_GAMES_GOTSUSHIMA_UI_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_UI_HLSLI_

#include "./sdr.hlsli"
#include "./intermediate.hlsli"

bool GhostIsUIOverrideActive() {
  return GHOST_SDR_OUTPUT == 0.f
         && RENODX_TONE_MAP_TYPE != 0.f
         && RENODX_PEAK_WHITE_NITS > 0.f
         && RENODX_GRAPHICS_WHITE_NITS > 0.f;
}

// Input is the game's encoded HUD color before its native brightness
// multiplier. Pass the RGB coverage for premultiplied shaders, or 1 for
// straight alpha. Some overlays already decode their texture to linear;
// linear_input preserves that result without a second SDR decode.
// Keep coverage outside the nonlinear color transform.
float3 GhostRenderUI(float3 color_bt709, float coverage, bool linear_input = false) {
  // The reference blends the original SDR shader values and coverage first.
  // Its SDR display transfer and HDR container conversion run after all UI.
  if (GhostIsSDRReference()) return color_bt709;
  if (coverage <= 0.f) return 0.f.xxx;
  color_bt709 /= coverage;

  // Recover the SDR source, including shaders that already decode sRGB.
  float3 linear_bt709 = linear_input
                           ? color_bt709
                           : renodx::color::srgb::DecodeSafe(color_bt709);

  // Fixed native-style UI display response: Rec.709 OETF followed by
  // gamma 2.4 decoding, in BT.709 before gamut conversion. Keep source
  // decoding and coverage separate; scene grading never controls this EOTF.
  linear_bt709 = renodx::color::gamma::DecodeSafe(
      GhostSDRDisplayCode(linear_bt709), 2.4f);
  const float3 target_color = GHOST_SDR_OUTPUT != 0.f
                                  ? linear_bt709
                                  : renodx::color::bt2020::from::BT709(linear_bt709);
  return GhostEncodeIntermediate(
             target_color * RENODX_GRAPHICS_WHITE_NITS)
         * coverage;
}

#endif  // SRC_GAMES_GOTSUSHIMA_UI_HLSLI_
