#ifndef SRC_GAMES_GOTSUSHIMA_POST_EFFECTS_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_POST_EFFECTS_HLSLI_

#include "./chromatic_aberration.hlsli"

bool GhostPostEffectsEnabled() {
  return CUSTOM_SHARPENING > 0.f || CUSTOM_FILM_GRAIN > 0.f
         || (CUSTOM_CA_ENABLED != 0.f && CUSTOM_CA_INTENSITY > 0.f);
}

// Shared by the pre-HUD pass and HUD-hidden output fallback. All effects run
// at reconstructed display resolution: Sharpening -> CA -> Film Grain.
float4 GhostApplyPostUpscaleEffects(Texture2D<float4> scene, uint2 pixel) {
  const float4 original = scene.Load(int3(pixel, 0));
  if (!GhostPostEffectsEnabled()) return original;
  uint width, height;
  scene.GetDimensions(width, height);
  const float2 uv = (float2(pixel) + 0.5f) / float2(width, height);
  float3 color = GhostLoadSharpenedScene(scene, int2(pixel), uint2(width, height));
  color = max(GhostApplyChromaticAberration(color, scene, uv, uint2(width, height)), 0.f);
  if (CUSTOM_FILM_GRAIN > 0.f) {
    // Same perceptual density/strength as before, relative to scene white.
    // Grain is generated at the destination pixel after all displaced sampling.
    color = renodx::effects::ApplyFilmGrain(
        color, uv, CUSTOM_RANDOM, CUSTOM_FILM_GRAIN * 0.03f,
        max(RENODX_DIFFUSE_WHITE_NITS, 1.f) / RENODX_INTERMEDIATE_SCALING,
        false, GHOST_SDR_OUTPUT != 0.f
                   ? renodx::color::BT709_TO_XYZ_MAT
                   : renodx::color::BT2020_TO_XYZ_MAT);
  }
  return float4(GhostEncodeIntermediate(max(color, 0.f) * RENODX_INTERMEDIATE_SCALING), original.a);
}

#endif
