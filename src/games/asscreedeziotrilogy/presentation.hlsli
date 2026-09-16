#ifndef SRC_GAMES_ASSCREEDEZIOTRILOGY_PRESENTATION_HLSLI_
#define SRC_GAMES_ASSCREEDEZIOTRILOGY_PRESENTATION_HLSLI_

#include "./shared.h"

// The native FP16 buffer retains headroom through later game effects. Scene
// colors remove their finite working-range shoulder; HUD colors remove the
// display shoulder. The proxy applies the display fit once after composition.
float AC2DisplayPeak() {
  return RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f);
}

float3 AC2ExpandForPresentation(float3 linear_bt709, float source_peak) {
  const float peak = AC2DisplayPeak();
  const float knee = min(1.f, peak * 0.5f);
  const float maximum = renodx::math::Max(RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                                            ? linear_bt709 : renodx::color::bt2020::from::BT709(linear_bt709));
  if (maximum <= knee) return linear_bt709;
  const float distance = maximum - knee;
  // Finite continuation at the endpoint keeps FP16 gamma transport valid.
  // It also preserves ordering for UI settings above the physical display peak.
  const float expanded = knee + distance / max(1.f - distance / (source_peak - knee), 1e-4f);
  return linear_bt709 * (expanded / maximum);
}

float3 AC2FitForPresentation(float3 linear_bt709) {
  const float peak = AC2DisplayPeak();
  const float knee = min(1.f, peak * 0.5f);
  const float maximum = renodx::math::Max(RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                                            ? linear_bt709 : renodx::color::bt2020::from::BT709(linear_bt709));
  if (maximum <= knee) return linear_bt709;
  const float distance = maximum - knee;
  const float fitted = knee + distance * ((peak - knee) / (peak - knee + distance));
  return linear_bt709 * (fitted / maximum);
}

#endif
