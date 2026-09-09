#ifndef SRC_GAMES_GOTSUSHIMA_UI_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_UI_HLSLI_

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

  // Recover the SDR source, including shaders that already decode sRGB.
  float3 linear_bt709 = linear_input
                           ? color_bt709
                           : renodx::color::srgb::DecodeSafe(color_bt709);

  // Native SDR output (0x571EE768) applies the BT.709 OETF after its sRGB
  // decode. These are the display code values, not linear-light RGB.
  // Omitting this step lifts HUD midtones and weak color channels. Preserve
  // that response before applying the user's selected display EOTF.
  float3 sdr_display_code = renodx::math::CopySign(
      renodx::math::Select(
          abs(linear_bt709) <= 0.018f,
          abs(linear_bt709) * 4.5f,
          1.099f * pow(abs(linear_bt709), 0.45f) - 0.099f),
      linear_bt709);
  linear_bt709 = renodx::color::srgb::DecodeSafe(sdr_display_code);
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

#endif  // SRC_GAMES_GOTSUSHIMA_UI_HLSLI_
