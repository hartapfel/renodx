#ifndef THEWITCHER3CLASSIC_FINAL_GRADE_HLSLI_
#define THEWITCHER3CLASSIC_FINAL_GRADE_HLSLI_

#include "../tonemap/psychov_tonemap.hlsli"
#include "../effects/chromatic_aberration.hlsli"
#include "../../../shaders/effects.hlsl"

#ifndef CLASSIC_GRADE_CONSTANT_COUNT
#define CLASSIC_GRADE_CONSTANT_COUNT 18
#endif

// Native analytic grade, with only the SDR colour bounds removed. Masks,
// exposure, saturation, vignette and game-controlled fades retain their order.
// The input is the extended native filmic signal after bloom/LUT/AA.
float3 ClassicGradeAndMap(float3 scene, float2 scene_uv, float2 vignette_uv, float4 constants[CLASSIC_GRADE_CONSTANT_COUNT], bool apply_vignette = true, float texture_vignette = -1.f) {
  float3 color = renodx::math::SignPow(scene, constants[8].x);
  color = pow(max(color * constants[14].x + constants[14].y, 0.f), constants[14].z);
  const float grade_luma = dot(color, float3(0.299f, 0.587f, 0.114f));
  const float2 weights = saturate((grade_luma - constants[10].xz) * constants[10].yw);
  const float4 grade = lerp(lerp(constants[12], constants[11], weights.x), constants[13], weights.y);
  color = renodx::color::gamma::DecodeSafe(color, 2.2f);
  const float luminance = renodx::color::y::from::BT709(color);
  color = (luminance + (color - luminance) * grade.w) * grade.rgb;
  color = renodx::color::gamma::EncodeSafe(color, 2.2f) * constants[9].rgb;

  float native_vignette = 0.f;
  if (apply_vignette) {
    const float distance = length(vignette_uv - 0.5f);
    const float position = saturate((distance * 2.f - 0.55f) * 1.21951222f);
    const float position2 = position * position;
    // Texture and analytic vignette permutations share the native color mask.
    const float vignette = texture_vignette >= 0.f ? texture_vignette
        : min(0.94f, dot(float4(-0.1f, -0.105f, 1.12f, 0.09f),
                        float4(position2 * position2, position2 * position, position2, position)));
    native_vignette = saturate(vignette * constants[6].w
        * saturate(1.f - dot(renodx::color::gamma::DecodeSafe(color, 2.2f), constants[6].rgb)));
    if (shader_injection.vignette_black_floor == 0.f) {
      color = lerp(color, constants[7].rgb, saturate(native_vignette * shader_injection.vignette_strength));
    }
  }
  color = color * (constants[15].y - constants[15].x) + constants[15].x;
  color = renodx::color::gamma::DecodeSafe(color, 2.2f);
  if (apply_vignette && shader_injection.vignette_black_floor != 0.f) {
    // Remastered's black-floor fix attenuates linear light after native levels,
    // rather than blending toward a colored floor. Above 1x, optical density
    // preserves detail in partial masks instead of saturating opacity to black.
    color *= shader_injection.vignette_strength > 1.f
        ? pow(1.f - native_vignette, shader_injection.vignette_strength)
        : 1.f - saturate(native_vignette * shader_injection.vignette_strength);
  }
  color = WitcherToneMapPsychoVCustom31(color, true);
  // Post-reconstruction grain: never enters the temporal history or HUD.
  if (shader_injection.film_grain > 0.f) {
    color = renodx::effects::ApplyFilmGrain(color, scene_uv, shader_injection.random_seed,
        shader_injection.film_grain * 0.03f);
  }
  color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
  return renodx::color::gamma::EncodeSafe(color, 2.2f);
}

#endif
