#ifndef SRC_GAMES_GOTSUSHIMA_SDR_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_SDR_HLSLI_

#include "./shared.h"

bool GhostIsSDRReference() {
  return RENODX_TONE_MAP_TYPE == GHOST_TONE_MAP_SDR_REFERENCE;
}

// Native SDR 0x24A0E87E: RootSrt offsets 344..364, captured in SDR and
// checked against the HDR variant. HDR supplies different coefficients, so
// clamping its curve cannot reproduce SDR. The surrounding matrices match.
// Native SDR clamps this result BEFORE the second color-space matrix.
float3 GhostToneMapSDR(float3 color) {
  return saturate(
      (color * (2.238881826400757f + color * (94.45838165283203f + color * 714.7163696289062f)))
      / (1.f + color * (155.2942352294922f + color * (341.29400634765625f + color * 698.90869140625f))));
}

// BT.709 OETF from native SDR output shader 0x571EE768. This produces
// display code values; the display EOTF must still be applied afterwards.
float3 GhostSDRDisplayCode(float3 linear_bt709) {
  return renodx::math::CopySign(
      renodx::math::Select(
          abs(linear_bt709) <= 0.018f,
          abs(linear_bt709) * 4.5f,
          1.099f * pow(abs(linear_bt709), 0.45f) - 0.099f),
      linear_bt709);
}

#endif  // SRC_GAMES_GOTSUSHIMA_SDR_HLSLI_
