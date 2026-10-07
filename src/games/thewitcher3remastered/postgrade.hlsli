#ifndef SRC_GAMES_THEWITCHER3REMASTERED_POSTGRADE_HLSLI_
#define SRC_GAMES_THEWITCHER3REMASTERED_POSTGRADE_HLSLI_

// Included after native cb3 declarations. Gameplay and Photo Mode use the
// same grade constants; their vignette masks and preceding effects differ.
float3 WitcherApplyPostGrade(float3 scene, float vignette_mask) {
  WitcherGradeState state = WitcherPrepareGrade(scene);
  float exponent = max(CustomPixelConsts_128.x, 1e-6f);
  float3 color = pow(state.neutral_sdr, exponent);
  color = WitcherSignedPow(color * CustomPixelConsts_224.x + CustomPixelConsts_224.y,
                          CustomPixelConsts_224.z);
  float luma = dot(color, float3(0.299f, 0.587f, 0.114f));
  float shadow = saturate((luma - CustomPixelConsts_160.x) * CustomPixelConsts_160.y);
  float highlight = saturate((luma - CustomPixelConsts_160.z) * CustomPixelConsts_160.w);
  float4 grade = lerp(CustomPixelConsts_192, CustomPixelConsts_176, shadow);
  grade = lerp(grade, CustomPixelConsts_208, highlight);
  color = WitcherSignedPow(color, 2.2f);
  color = lerp(renodx::color::y::from::BT709(color).xxx, color, grade.w) * grade.rgb;
  // Day/night grades may produce valid wide-gamut colours with negative
  // BT.709 channels. Only the final tonemapper chooses the display gamut.
  color = WitcherSignedPow(color, 1.f / 2.2f) * CustomPixelConsts_144.rgb;

  // Decode signed values for the native luminance-dependent vignette mask;
  // log2 of a negative channel here would otherwise reintroduce NaNs.
  float native_vignette = saturate(CustomPixelConsts_096.w * vignette_mask
      * saturate(1.f - dot(WitcherSignedPow(color, 2.2f), CustomPixelConsts_096.rgb)));
  float vignette = saturate(native_vignette * CUSTOM_VIGNETTE_STRENGTH);
  float levels = CustomPixelConsts_240.y - CustomPixelConsts_240.x;
  color = color * levels + CustomPixelConsts_240.x;
  // Contribution is blended in linear space, as in CustomColorGrading in the
  // old mod. Include native output levels, but keep vignette independent.
  float3 graded = WitcherSignedPow(color, rcp(exponent));
  float luminance_strength = CUSTOM_COLOR_GRADING_LUMINANCE;
  float chroma_strength = CUSTOM_COLOR_GRADING_CHROMA;
  color = lerp(state.neutral_sdr, graded, chroma_strength);
  if (luminance_strength != chroma_strength) {
    // Keep the chosen chromaticity while independently blending luminance.
    // Equal strengths retain the previous linear RGB blend exactly.
    float target_y = lerp(renodx::color::y::from::BT709(state.neutral_sdr),
                          renodx::color::y::from::BT709(graded), luminance_strength);
    float color_y = renodx::color::y::from::BT709(color);
    color = color_y > 0.f ? color * (target_y / color_y) : target_y.xxx;
  }
  color = WitcherSignedPow(color, exponent);
  if (CUSTOM_VIGNETTE_BLACK_FLOOR == 0.f) {
    // The native affine levels transform commutes with its vignette blend.
    color = lerp(color, CustomPixelConsts_112.rgb * levels + CustomPixelConsts_240.x, vignette);
  }
  color = WitcherRestoreGrade(WitcherSignedPow(color, rcp(exponent)), state);
  if (CUSTOM_VIGNETTE_BLACK_FLOOR != 0.f) {
    // The old mod scales native opacity only up to 1x. Keep that response
    // through 50, then scale optical density instead of saturating opacity:
    // at 100 the remaining light is squared, not abruptly clamped to black.
    // A partial native mask stays partial; black input still stays black.
    color *= CUSTOM_VIGNETTE_STRENGTH > 1.f
        ? pow(1.f - native_vignette, CUSTOM_VIGNETTE_STRENGTH)
        : 1.f - vignette;
  }
  return WitcherSignedPow(color, exponent);
}

float WitcherRadialVignette(float2 uv) {
  float radius = saturate(length(uv - 0.5f) * 2.4390244483947754f - 0.6707317233085632f);
  float radius2 = radius * radius;
  return min(dot(float4(-0.1f, -0.105f, 1.12f, 0.09f),
                 float4(radius2 * radius2, radius2 * radius, radius2, radius)), 0.94f);
}

#endif
