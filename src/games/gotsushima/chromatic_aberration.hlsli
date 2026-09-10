#ifndef SRC_GAMES_GOTSUSHIMA_CHROMATIC_ABERRATION_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_CHROMATIC_ABERRATION_HLSLI_

#include "./lilium_rcas.hlsli"

// UE5-style scene fringe: independently threshold each screen-position axis,
// shift red/green samples inward, and retain the blue sample. The sampling
// pattern is visible in Hellblade 2's 0x189339AE and Oblivion Remastered's
// 0x99B126EC. Wavelength-based dispersion uses red/green/blue at 611/549/464 nm.
// Ghost's existing distortion is retained as the base sampling coordinate.
float3 GhostApplySceneLensEffects(
    float3 center, float2 uv, float2 screen_uv,
    Texture2D<float4> scene, SamplerState scene_sampler) {
  center = GhostApplyRCAS(center, uv, scene, scene_sampler);
  if (CUSTOM_CA_ENABLED == 0.f || CUSTOM_CA_INTENSITY <= 0.f) return center;

  const float start = clamp(CUSTOM_CA_START_OFFSET, 0.f, 1.f);
  if (start >= 1.f) return center;
  const float2 screen_position = screen_uv * 2.f - 1.f;
  const float2 fringe = sign(screen_position)
                        * saturate(abs(screen_position) - start) / (1.f - start);
  if (all(fringe == 0.f)) return center;

  uint width, height;
  scene.GetDimensions(width, height);
  const float2 half_texel = 0.5f / float2(width, height);
  // Percent intensity, dispersion coefficient, and screen-position -> UV.
  const float2 offset = fringe * (0.5f * 0.01f * 0.007f * CUSTOM_CA_INTENSITY);
  const float2 red_uv = clamp(uv - offset * (611.f - 464.f), half_texel, 1.f - half_texel);
  const float2 green_uv = clamp(uv - offset * (549.f - 464.f), half_texel, 1.f - half_texel);

  // Sharpen the same source neighborhood for every channel, then select the
  // displaced channels. Mixing a sharpened center with unsharpened neighbors
  // would make enabling fringe also change the channel-wise sharpening.
  const float3 red = GhostApplyRCAS(
      scene.SampleLevel(scene_sampler, red_uv, 0.f).rgb, red_uv, scene, scene_sampler);
  const float3 green = GhostApplyRCAS(
      scene.SampleLevel(scene_sampler, green_uv, 0.f).rgb, green_uv, scene, scene_sampler);
  return float3(red.r, green.g, center.b);
}

#endif  // SRC_GAMES_GOTSUSHIMA_CHROMATIC_ABERRATION_HLSLI_
