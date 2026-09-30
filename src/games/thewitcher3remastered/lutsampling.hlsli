#ifndef SRC_GAMES_THEWITCHER3REMASTERED_LUTSAMPLING_HLSLI_
#define SRC_GAMES_THEWITCHER3REMASTERED_LUTSAMPLING_HLSLI_

#include "./common.hlsli"
#include "../../shaders/lut.hlsl"

// Native 64-slice LUTs use an 8x8 tiled atlas, with nonstandard cell offsets.
// Preserve the original mod's addressing rather than treating this as a strip.
float3 WitcherSampleLUTGamma(float3 color, Texture2D<float4> lut, SamplerState lut_sampler) {
  float slice = color.b * 63.75f;
  float slice_floor = floor(slice);
  float upper = min(0.9999899864196777f, saturate(color.b * 0.99609375f + 0.015625f));
  float lower = min(0.9999899864196777f, saturate(slice_floor * 0.015625f));
  float2 cell = clamp((saturate(color.rg) + 0.0078125f) * 0.99609375f, 0.015625f, 0.984375f);
  float upper_row = floor(upper * 8.f);
  float lower_row = floor(lower * 8.f);
  float2 upper_uv = (float2(floor(upper * 64.f - upper_row * 8.f), upper_row) + cell) * 0.125f;
  float2 lower_uv = (float2(floor(lower * 64.f - lower_row * 8.f), lower_row) + cell) * 0.125f;
  return lerp(lut.SampleLevel(lut_sampler, lower_uv, 0.f).rgb,
              lut.SampleLevel(lut_sampler, upper_uv, 0.f).rgb, slice - slice_floor);
}

// Port of the original Witcher mod's LUTSampling scaling: sample black,
// midgray and white in gamma 2.2, then restore range with perceptual recoloring.
// Input/output are linear within the existing reversible HDR grading proxy.
float3 WitcherSampleLUT(float3 neutral_sdr, Texture2D<float4> lut, SamplerState lut_sampler) {
  float3 gamma_color = renodx::color::gamma::Encode(neutral_sdr);
  float3 sampled = WitcherSampleLUTGamma(gamma_color, lut, lut_sampler);
  float3 linear_color = renodx::color::gamma::Decode(abs(sampled));
  if (CUSTOM_LUT_SCALING == 0.f) return linear_color;

  float3 black = WitcherSampleLUTGamma(0.f.xxx, lut, lut_sampler);
  float3 mid = WitcherSampleLUTGamma(renodx::color::gamma::Encode(0.18f).xxx, lut, lut_sampler);
  float3 white = WitcherSampleLUTGamma(1.f.xxx, lut, lut_sampler);
  float mid_average = (mid.r + mid.g + mid.b) / 3.f;
  // Constant black/white LUTs have no recoverable range; avoid Unclamp's
  // zero-length shadow/highlight divisions while retaining their native grade.
  if (mid_average <= 1e-6f || mid_average >= 1.f - 1e-6f) return linear_color;
  return renodx::lut::RecolorUnclamped(
      linear_color,
      renodx::color::gamma::Decode(renodx::lut::Unclamp(sampled, black, mid, white, gamma_color)),
      CUSTOM_LUT_SCALING);
}

#endif
