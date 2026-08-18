// Depth-aware replacement for PostProcessSSAOBloom.
// The original scales its blur radius using only the center depth, so samples
// from unrelated surfaces bleed across silhouettes as the camera moves.

Texture2D<float4> g_SrcTexture : register(t0);
Texture2D<float4> g_DepthTexture : register(t1);

cbuffer $Globals : register(b0) {
  float4 g_SampleWeights[16] : packoffset(c000.x);
  float4 g_SampleOffsets[16] : packoffset(c016.x);
};

SamplerState g_SamplerPointClamp : register(s1);
SamplerState g_SamplerLinearClamp : register(s4);

#include "../shared.h"

float4 main(
    float4 position : SV_Position,
    float2 screen_position : TEXCOORD0) : SV_Target {
  const float center_depth = g_DepthTexture.Sample(g_SamplerPointClamp, screen_position).r;
  const float4 original = g_SrcTexture.Sample(g_SamplerLinearClamp, screen_position);
  const float offset_scale = saturate(1.f - min(center_depth * 150.f, 0.8f));

  if (CUSTOM_IMPROVED_AMBIENT_OCCLUSION == 0.f) {
    float4 vanilla_color = 0.f;
    [unroll]
    for (uint i = 0u; i < 5u; ++i) {
      vanilla_color += g_SampleWeights[i]
                       * (1.f - g_SrcTexture.Sample(
                           g_SamplerLinearClamp,
                           screen_position + g_SampleOffsets[i].xy * offset_scale));
    }
    vanilla_color.gba = original.gba;
    return vanilla_color;
  }

  float filtered_occlusion = 0.f;
  float total_weight = 0.f;
  [unroll]
  for (uint i = 0u; i < 5u; ++i) {
    const float2 sample_position = screen_position + g_SampleOffsets[i].xy * offset_scale;
    const float sample_depth = g_DepthTexture.Sample(g_SamplerPointClamp, sample_position).r;
    const float relative_depth_delta = abs(sample_depth - center_depth)
                                       / max(max(abs(sample_depth), abs(center_depth)), 1e-3f);
    float depth_weight = saturate(1.f - relative_depth_delta / 0.02f);
    depth_weight *= depth_weight;

    const float weight = max(g_SampleWeights[i].x, 0.f) * depth_weight;
    filtered_occlusion += (1.f - g_SrcTexture.Sample(
        g_SamplerLinearClamp,
        sample_position).r) * weight;
    total_weight += weight;
  }

  // This pass runs twice. Preserve its original per-pass inversion so the
  // second direction converts the blurred occlusion back to AO visibility.
  const float fallback = 1.f - original.r;
  return float4(
      total_weight > 1e-5f ? filtered_occlusion / total_weight : fallback,
      original.gba);
}
