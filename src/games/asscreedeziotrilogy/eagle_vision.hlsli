#ifndef AC2_EAGLE_VISION_HLSLI
#define AC2_EAGLE_VISION_HLSLI

#include "./shared.h"

// Eagle Vision adds its signed, 0.5-biased glow/streak filters after the scene
// LUT and PsychoV. Preserve that encoded-domain composition and its black floor.
// The proxy fits the preserved HDR composition after this addition.
float3 AC2CompositeEagleVision(float3 encoded_scene, float3 encoded_effect) {
  float3 composite = encoded_scene + encoded_effect;
  if (CUSTOM_INJECTION_VERSION != 30.f || RENODX_TONE_MAP_TYPE != 1.f
      || RENODX_DIFFUSE_WHITE_NITS <= 0.f || RENODX_PEAK_WHITE_NITS <= 0.f) {
    return saturate(composite);
  }
  return max(composite, 0.f.xxx);
}

#endif
