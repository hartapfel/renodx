#ifndef THEWITCHER3CLASSIC_BLITZFX_FINAL_EFFECTS_HLSLI_
#define THEWITCHER3CLASSIC_BLITZFX_FINAL_EFFECTS_HLSLI_

#include "../grading/final_grade.hlsli"

// All final-grade variants run after reconstruction. Preserve native CA when
// its replacement is off, sampling the same sharpened scene for each channel.
float3 BlitzSampleFinalEffects(Texture2D<float4> scene, float3 color, float2 uv,
                              bool native_ca, float2 native_ca_offset) {
  uint width, height;
  scene.GetDimensions(width, height);
  if (CUSTOM_SHARPENING_MODE != 0.f && CUSTOM_SHARPENING > 0.f) {
    color = WitcherSampleFringe(scene, uv, uint2(width, height));
    if (CUSTOM_CA_MODE == 0.f && native_ca) {
      color.r = WitcherSampleFringe(scene, uv - 2.f * native_ca_offset, uint2(width, height)).r;
      color.g = WitcherSampleFringe(scene, uv - native_ca_offset, uint2(width, height)).g;
    }
  }
  if (CUSTOM_CA_MODE != 0.f)
    color = WitcherApplyChromaticAberration(color, scene, uv, uint2(width, height));
  return color;
}

#endif
