#ifndef THEWITCHER3CLASSIC_BLOOM_HLSLI_
#define THEWITCHER3CLASSIC_BLOOM_HLSLI_
#include "../shared.h"

// Remastered's ClampPostProcessing at reference response (1), before each
// extraction sample is averaged. Limit effect energy, preserving sample hue;
// the main scene resource retains its extended HDR values. Classic has no
// alpha metadata in R11G11B10F, so use an explicit SDR reference peak of 1.
// This is a bounded reference approximation, not exact native Hable replay.
float3 ClassicBloomReference(float3 source, float3 intensity_weights) {
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_VANILLA || RENODX_PEAK_WHITE_NITS <= 0.f) return source;
  float intensity = dot(intensity_weights, source);
  float reference = dot(intensity_weights, renodx::tonemap::neutwo::PerChannel(source, 1.f));
  return source * (intensity > 0.f ? reference / max(intensity, 1e-20f) : 1.f);
}
#endif
