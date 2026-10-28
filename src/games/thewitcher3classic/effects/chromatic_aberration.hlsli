#ifndef SRC_GAMES_THEWITCHER3CLASSIC_CHROMATIC_ABERRATION_HLSLI_
#define SRC_GAMES_THEWITCHER3CLASSIC_CHROMATIC_ABERRATION_HLSLI_

#include "./lilium_rcas.hlsli"
#include "./lens_mapping.hlsli"

// Ghost of Tsushima's Sharpening -> CA sampling. Sharpen each texel before
// bilinear reconstruction so displaced taps sample the same sharpened image.
// This scene buffer already contains linear BT.709.
float3 WitcherSampleFringe(Texture2D<float4> scene, float2 uv, uint2 size) {
  const float2 position = clamp(uv * float2(size) - 0.5f, 0.f.xx, float2(size - 1u));
  const int2 low = int2(floor(position));
  const int2 high = min(low + 1, int2(size) - 1);
  const float2 weight = frac(position);
  return lerp(
      lerp(WitcherLoadSharpenedScene(scene, low, size),
           WitcherLoadSharpenedScene(scene, int2(high.x, low.y), size), weight.x),
      lerp(WitcherLoadSharpenedScene(scene, int2(low.x, high.y), size),
           WitcherLoadSharpenedScene(scene, high, size), weight.x),
      weight.y);
}

float4 WitcherLensWeights(float f) {
  return float4(-0.5f*f+f*f-0.5f*f*f*f, 1.f-2.5f*f*f+1.5f*f*f*f,
      0.5f*f+2.f*f*f-1.5f*f*f*f, -0.5f*f*f+0.5f*f*f*f);
}

float WitcherLensSample(Texture2D<float4> scene, float2 uv, uint2 size, float dispersion, uint channel) {
  const float2 q = WitcherLensSource(uv, size, dispersion, CUSTOM_CA_INTENSITY);
  const float2 dx = ddx(q), dy = ddy(q);
  const float footprint = max(length(dx * size), length(dy * size));
  float area = 0.f;
  if (footprint > 1.1f) {
    [unroll] for (uint i = 0; i < 4; ++i)
      area += WitcherSampleFringe(scene, q + ((i & 1) ? 0.25f : -0.25f) * dx
          + ((i & 2) ? 0.25f : -0.25f) * dy, size)[channel] * 0.25f;
    if (footprint >= 1.4f) return area;
  }
  const float2 p = q * size - 0.5f, f = frac(p);
  const int2 base = int2(floor(p));
  const float4 wx = WitcherLensWeights(f.x), wy = WitcherLensWeights(f.y);
  float sum = 0.f, low = 1e30f, high = -1e30f;
  [unroll] for (int y = 0; y < 4; ++y) [unroll] for (int x = 0; x < 4; ++x) {
    const float c = WitcherLoadSharpenedScene(scene, clamp(base + int2(x-1,y-1), 0, int2(size)-1), size)[channel];
    sum += c * wx[x] * wy[y];
    if (x >= 1 && x <= 2 && y >= 1 && y <= 2) { low = min(low, c); high = max(high, c); }
  }
  return lerp(clamp(sum, low, high), area, smoothstep(1.1f, 1.4f, footprint));
}

float3 WitcherApplyChromaticAberration(float3 center, Texture2D<float4> scene, float2 uv, uint2 size) {
  if (CUSTOM_CA_MODE == 0.f || CUSTOM_CA_INTENSITY <= 0.f) return center;
  return float3(WitcherLensSample(scene, uv, size, 1.42f, 0),
      WitcherLensSample(scene, uv, size, 1.275f, 1), WitcherLensSample(scene, uv, size, 1.12f, 2));
}

#endif  // SRC_GAMES_THEWITCHER3CLASSIC_CHROMATIC_ABERRATION_HLSLI_
