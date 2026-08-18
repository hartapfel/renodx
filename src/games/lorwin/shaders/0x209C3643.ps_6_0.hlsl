// Stable replacement for PostProcessSSAO.
// The original rotates a sparse, single-radius kernel with a screen-space
// noise texture. Geometry moving through that noise field makes the AO pattern
// crawl even when temporal anti-aliasing is disabled.

#pragma pack_matrix(row_major)

Texture2D<float4> g_DepthTexture : register(t0);
Texture2D<float4> g_NoiseTexture : register(t1);
Texture2D<float4> g_LinearDepthTexture : register(t2);

cbuffer $Globals : register(b0) {
  float4x4 g_InvProj : packoffset(c000.x);
  float4x4 g_Proj : packoffset(c004.x);
  float4 g_AOParamsLocal : packoffset(c008.x);
  float4 g_FarPlane : packoffset(c011.x);
  float4 g_ScreenParams : packoffset(c038.x);
};

SamplerState g_SamplerPointClamp : register(s1);
SamplerState g_SamplerLinearClamp : register(s4);
SamplerState g_SamplerLinearWrap : register(s5);

#include "../shared.h"

float4 main(
    float4 position : SV_Position,
    float2 screen_position : TEXCOORD0) : SV_Target {
  const float device_depth = g_DepthTexture.Sample(g_SamplerPointClamp, screen_position).r;
  const float linear_depth = g_LinearDepthTexture.Sample(g_SamplerPointClamp, screen_position).r
                             * g_FarPlane.x;
  if (linear_depth <= 0.f || linear_depth >= g_FarPlane.x) return float4(1.f, 1.f, 1.f, 0.f);

  const float4 ndc_position = float4(
      screen_position.x * 2.f - 1.f,
      (1.f - screen_position.y) * 2.f - 1.f,
      device_depth,
      1.f);
  float4 view_position = mul(g_InvProj, ndc_position);
  view_position /= view_position.w;

  float4 one_meter_position = mul(g_Proj, view_position + float4(1.f, 0.f, 0.f, 0.f));
  one_meter_position /= one_meter_position.w;
  const float projected_radius = abs(ndc_position.x - one_meter_position.x)
                                 * 0.5f * g_AOParamsLocal.x;
  const float2 aspect_correction = float2(g_ScreenParams.y / g_ScreenParams.x, 1.f);

  if (CUSTOM_IMPROVED_AMBIENT_OCCLUSION == 0.f) {
    const float2 noise_scale = float2(
        g_ScreenParams.x / g_ScreenParams.z,
        g_ScreenParams.y / g_ScreenParams.w);
    const float2 rotation = normalize(
        g_NoiseTexture.Sample(g_SamplerLinearWrap, screen_position * noise_scale).xy * 2.f - 1.f);
    static const float2 kVanillaOffsets[8] = {
        float2(0.f, 1.f),
        float2(0.383f, 0.924f),
        float2(0.707f, 0.707f),
        float2(0.924f, 0.383f),
        float2(1.f, 0.f),
        float2(0.924f, -0.383f),
        float2(0.707f, -0.707f),
        float2(0.383f, -0.924f),
    };

    float vanilla_occlusion = 0.f;
    float vanilla_occluders = 0.f;
    [unroll]
    for (uint i = 0u; i < 8u; ++i) {
      const float2 offset = kVanillaOffsets[i];
      const float2 rotated_offset = float2(
          offset.x * rotation.x - offset.y * rotation.y,
          offset.x * rotation.y + offset.y * rotation.x);
      const float2 uv_offset = rotated_offset * aspect_correction * projected_radius;
      const float sample_depth_1 = g_LinearDepthTexture.Sample(
          g_SamplerLinearClamp,
          screen_position + uv_offset).r * g_FarPlane.x;
      const float sample_depth_2 = g_LinearDepthTexture.Sample(
          g_SamplerLinearClamp,
          screen_position - uv_offset).r * g_FarPlane.x;
      const float depth_delta_1 = linear_depth - sample_depth_1;
      const float depth_delta_2 = linear_depth - sample_depth_2;

      if (depth_delta_1 > 0.015f
          && depth_delta_2 > 0.015f
          && depth_delta_1 < 1.f
          && depth_delta_2 < 1.f) {
        vanilla_occlusion += saturate((depth_delta_1 + depth_delta_2) * 2.f);
      }
      if (depth_delta_1 < 1.f && depth_delta_2 < 1.f) vanilla_occluders += 1.f;
    }

    const float vanilla_visibility = 1.f
                                     - saturate(vanilla_occlusion / max(vanilla_occluders, 1.f))
                                           * g_AOParamsLocal.w;
    const float distance_fade = saturate(
        (linear_depth - g_FarPlane.z) / (g_FarPlane.w - g_FarPlane.z));
    const float result = lerp(vanilla_visibility, 1.f, distance_fade);
    return float4(result, result, 1.f, 0.f);
  }

  // Four axes, two radii, and their opposite directions retain the original
  // 16 depth taps while removing the unstable screen-space random rotation.
  static const float2 kDirections[4] = {
      float2(1.f, 0.f),
      float2(0.70710678f, 0.70710678f),
      float2(0.f, 1.f),
      float2(-0.70710678f, 0.70710678f),
  };
  static const float kRadii[2] = {0.5f, 1.f};

  float occlusion = 0.f;
  float total_weight = 0.f;
  [unroll]
  for (uint direction_index = 0u; direction_index < 4u; ++direction_index) {
    [unroll]
    for (uint radius_index = 0u; radius_index < 2u; ++radius_index) {
      const float radius_weight = radius_index == 0u ? 0.75f : 1.f;
      const float2 uv_offset = kDirections[direction_index]
                               * aspect_correction
                               * projected_radius
                               * kRadii[radius_index];

      [unroll]
      for (int side = -1; side <= 1; side += 2) {
        const float sample_depth = g_LinearDepthTexture.Sample(
            g_SamplerLinearClamp,
            screen_position + uv_offset * side).r * g_FarPlane.x;
        const float depth_delta = linear_depth - sample_depth;

        // Smooth thresholds avoid the binary on/off response of the original.
        // Reject surfaces over one metre in front so foreground silhouettes do
        // not cast broad screen-space halos onto the background.
        const float occluder = smoothstep(0.015f, 0.08f, depth_delta)
                               * saturate(1.f - depth_delta);
        occlusion += occluder * radius_weight;
        total_weight += radius_weight;
      }
    }
  }

  const float visibility = 1.f - saturate(occlusion / max(total_weight, 1e-4f))
                                   * g_AOParamsLocal.w;
  const float distance_fade = saturate(
      (linear_depth - g_FarPlane.z) / max(g_FarPlane.w - g_FarPlane.z, 1e-4f));
  const float result = lerp(visibility, 1.f, distance_fade);
  return float4(result, result, 1.f, 0.f);
}
