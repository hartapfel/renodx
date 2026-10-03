#ifndef SRC_GAMES_THEWITCHER3REMASTERED_OUTPUT_HLSLI_
#define SRC_GAMES_THEWITCHER3REMASTERED_OUTPUT_HLSLI_

#include "./common.hlsli"
#include "./video.hlsli"
#include "../../shaders/effects.hlsl"

// Shared by normal presentation and both frame-generation HDR outputs.
// Input already includes the native display matrix, in linear BT.2020.
// Apply the scene response once, then grain, before UI and PQ encoding.
float3 WitcherToneMapOutput(float3 scene_bt2020, float2 uv) {
  float3 mapped_bt2020 = renodx::color::bt2020::from::BT709(
      WitcherToneMapPsychoV30(renodx::color::bt709::from::BT2020(scene_bt2020)));
  if (CUSTOM_FILM_GRAIN > 0.f) {
    mapped_bt2020 = renodx::effects::ApplyFilmGrain(
        mapped_bt2020, uv, CUSTOM_RANDOM, CUSTOM_FILM_GRAIN * 0.03f,
        1.f, false, renodx::color::BT2020_TO_XYZ_MAT);
  }
  return mapped_bt2020;
}

#endif  // SRC_GAMES_THEWITCHER3REMASTERED_OUTPUT_HLSLI_
