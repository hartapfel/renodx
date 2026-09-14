#ifndef AC2_EAGLE_VISION_HLSLI
#define AC2_EAGLE_VISION_HLSLI

#include "./shared.h"

// Eagle Vision adds its signed, 0.5-biased glow/streak filters after the scene
// LUT and PsychoV. Preserve that encoded-domain composition and its black floor.
// Fit only added highlight energy into the remaining display headroom; do not
// run the already-tonemapped scene through PsychoV a second time.
float3 AC2CompositeEagleVision(float3 encoded_scene, float3 encoded_effect) {
  float3 composite = encoded_scene + encoded_effect;
  if (shader_injection.injection_version != 30.f || RENODX_TONE_MAP_TYPE != 1.f
      || RENODX_DIFFUSE_WHITE_NITS <= 0.f || RENODX_PEAK_WHITE_NITS <= 0.f) {
    return saturate(composite);
  }
  composite = max(composite, 0.f.xxx);
  float3 linear_composite = renodx::draw::DecodeColor(composite, RENODX_SWAP_CHAIN_DECODING);
  float3 linear_scene = renodx::draw::DecodeColor(max(encoded_scene, 0.f.xxx), RENODX_SWAP_CHAIN_DECODING);
  float3 target_composite = RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                                ? linear_composite : renodx::color::bt2020::from::BT709(linear_composite);
  float3 target_scene = RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                            ? linear_scene : renodx::color::bt2020::from::BT709(linear_scene);
  float composite_peak = renodx::math::Max(target_composite);
  float scene_peak = renodx::math::Max(target_scene);
  float display_peak = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
  float knee = min(1.f, display_peak * 0.5f);
  if (composite_peak <= max(scene_peak, knee)) return composite;

  // Identity and unit slope at the anchor, approaching the selected display
  // peak smoothly. A brighter scene raises the anchor, preserving its level.
  float anchor = min(max(scene_peak, knee), display_peak);
  float headroom = display_peak - anchor;
  float excess = composite_peak - anchor;
  float fitted_peak = anchor + excess * (headroom / (headroom + excess));
  return renodx::draw::EncodeColor(linear_composite * (fitted_peak / composite_peak), RENODX_SWAP_CHAIN_DECODING);
}

#endif
