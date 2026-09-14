#ifndef SRC_GAMES_GOTSUSHIMA_CHROMATIC_ABERRATION_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_CHROMATIC_ABERRATION_HLSLI_

#include "./lilium_rcas.hlsli"

// Evaluate the sharpened image at each bilinear tap. Sharpening after the
// interpolation would not be equivalent to Sharpening -> CA at subpixel offsets.
float3 GhostSampleFringe(Texture2D<float4> scene, float2 uv, uint2 size) {
  const float2 position = clamp(uv * float2(size) - 0.5f, 0.f.xx, float2(size - 1u));
  const int2 low = int2(floor(position));
  const int2 high = min(low + 1, int2(size) - 1);
  const float2 weight = frac(position);
  return renodx::color::bt709::from::BT2020(lerp(
      lerp(GhostLoadSharpenedScene(scene, low, size),
           GhostLoadSharpenedScene(scene, int2(high.x, low.y), size), weight.x),
      lerp(GhostLoadSharpenedScene(scene, int2(low.x, high.y), size),
           GhostLoadSharpenedScene(scene, high, size), weight.x),
      weight.y));
}

// Linear BT.2020 in/out, before film grain and composition encoding.
float3 GhostApplyChromaticAberration(float3 center, Texture2D<float4> scene, float2 uv, uint2 size) {
  if (CUSTOM_CA_ENABLED == 0.f || CUSTOM_CA_INTENSITY <= 0.f) return center;
  const float start = clamp(CUSTOM_CA_START_OFFSET, 0.f, 1.f);
  if (start >= 1.f) return center;
  const float2 screen_position = uv * 2.f - 1.f;
  // UE5's axis-wise start offset and 611/549/464 nm dispersion pattern.
  const float2 fringe = sign(screen_position)
                        * saturate(abs(screen_position) - start) / (1.f - start);
  if (all(fringe == 0.f)) return center;
  const float2 offset = fringe * (0.5f * 0.01f * 0.007f * CUSTOM_CA_INTENSITY);
  const float3 base = renodx::color::bt709::from::BT2020(center);
  const float red = GhostSampleFringe(scene, uv - offset * 147.f, size).r;
  const float green = GhostSampleFringe(scene, uv - offset * 85.f, size).g;
  // Preserve the undisplaced blue channel and avoid a matrix roundtrip of the
  // whole center. Disperse BT.709 channels, not BT.2020 transport components.
  return center + renodx::color::bt2020::from::BT709(float3(red - base.r, green - base.g, 0.f));
}

#endif
