#ifndef SRC_GAMES_THEWITCHER3REMASTERED_CHROMATIC_ABERRATION_HLSLI_
#define SRC_GAMES_THEWITCHER3REMASTERED_CHROMATIC_ABERRATION_HLSLI_

#include "./lilium_rcas.hlsli"

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

// Exact GoT dispersion math in the Witcher scene's linear BT.709 domain.
float3 WitcherApplyChromaticAberration(float3 center, Texture2D<float4> scene, float2 uv, uint2 size) {
  if (CUSTOM_CA_MODE == 0.f || CUSTOM_CA_INTENSITY <= 0.f) return center;
  const float start = clamp(CUSTOM_CA_START_OFFSET, 0.f, 1.f);
  if (start >= 1.f) return center;
  const float2 screen_position = uv * 2.f - 1.f;
  // UE5's axis-wise start offset and 611/549/464 nm dispersion pattern.
  const float2 fringe = sign(screen_position)
                        * saturate(abs(screen_position) - start) / (1.f - start);
  if (all(fringe == 0.f)) return center;
  const float2 offset = fringe * (0.5f * 0.01f * 0.007f * CUSTOM_CA_INTENSITY);
  const float red = WitcherSampleFringe(scene, uv - offset * 147.f, size).r;
  const float green = WitcherSampleFringe(scene, uv - offset * 85.f, size).g;
  const float3 delta = float3(red - center.r, green - center.g, 0.f);
  return center + delta;
}

#endif  // SRC_GAMES_THEWITCHER3REMASTERED_CHROMATIC_ABERRATION_HLSLI_
