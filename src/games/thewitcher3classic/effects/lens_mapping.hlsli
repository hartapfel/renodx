#ifndef WITCHER3CLASSIC_LENS_MAPPING_HLSLI_
#define WITCHER3CLASSIC_LENS_MAPPING_HLSLI_

// Custom lens mapping (MIT, LoreanXavier / Hartapfel; see optics/LICENSE.optics).
// The scene source is already linear BT.709.
float2 WitcherLensSource(float2 uv, uint2 size, float dispersion, float intensity) {
  const float aspect = float(size.x) / size.y;
  const float2 p = (uv * 2.f - 1.f) * float2(aspect / (16.f / 9.f), 1.f);
  const float radius = saturate(length(p) * 0.52240777f);
  const float dome = 1.f - sin(1.5707964f * radius);
  const float2 offset = pow(radius, 1.75f) * 84.f * float2(1.f / (1080.f * aspect), 1.f / 1080.f)
      * p * rsqrt(max(dot(p, p) + dome * dome, 1e-12f));
  return lerp(uv, uv * 0.9f + 0.050000012f + offset * dispersion,
      intensity);
}

#endif
