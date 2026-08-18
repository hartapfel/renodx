// HDR-aware replacement for PostProcessBrightPassFilter.
// The vanilla path is retained for SDR and when Improved Bloom is disabled.

Texture2D<float4> g_SceneTexture : register(t0);
Texture2D<float4> g_AvgLum : register(t1);

cbuffer $Globals : register(b0) {
  float4 g_MiddleGray : packoffset(c0);
  float4 g_BrightPassThresh : packoffset(c1);
  float4 g_BrightPassOffset : packoffset(c2);
  float4 g_Desaturate : packoffset(c3);
};

SamplerState g_SamplerPointClamp : register(s1);

#include "../shared.h"

float4 main(
    float4 position : SV_Position,
    float2 screen_position : TEXCOORD0) : SV_Target {
  float4 scene_sample = g_SceneTexture.Sample(g_SamplerPointClamp, screen_position);
  const float adapted_luminance = g_AvgLum.Sample(g_SamplerPointClamp, float2(0.5f, 0.5f)).r;

  // The scene stores additional pre-tonemap range in alpha.
  scene_sample.rgb *= scene_sample.a * 10.f + 1.f;

  if (CUSTOM_IMPROVED_BLOOM == 0.f || RENODX_HDR_OUTPUT_ACTIVE == 0.f) {
    // Original PostProcessBrightPassFilter behavior.
    const float hdr_min = saturate(adapted_luminance - g_MiddleGray.x);
    const float hdr_max = saturate(adapted_luminance + g_MiddleGray.x);
    const float pixel_luminance = dot(float3(0.2125f, 0.7154f, 0.0721f), scene_sample.rgb);
    const float toned_luminance = saturate(
        (pixel_luminance - hdr_min) / (hdr_max - hdr_min));
    scene_sample.rgb *= toned_luminance / pixel_luminance;
    scene_sample.rgb -= g_BrightPassThresh.x;
    scene_sample.rgb = max(scene_sample.rgb, 0.f.xxx);
    scene_sample.rgb /= g_BrightPassOffset.x + scene_sample.rgb;

    const float3 desaturate_weights = float3(1.f / 3.f, 0.2f, 0.1f);
    scene_sample.rgb = lerp(
        scene_sample.rgb,
        dot(scene_sample.rgb, desaturate_weights).xxx,
        saturate(g_Desaturate.x));
  } else {
    // Locate the vanilla threshold in the reconstructed scene domain, then
    // extract energy with a luminance soft knee instead of channel clipping
    // and the old bounded rational compression.
    scene_sample.rgb = max(scene_sample.rgb, 0.f.xxx);
    const float hdr_min = saturate(adapted_luminance - g_MiddleGray.x);
    const float hdr_max = saturate(adapted_luminance + g_MiddleGray.x);
    const float exposure_range = max(hdr_max - hdr_min, 1e-5f);
    const float threshold = hdr_min + saturate(g_BrightPassThresh.x) * exposure_range;
    const float knee = max(threshold * 0.5f, exposure_range * 0.05f);
    const float pixel_luminance = max(
        dot(float3(0.2125f, 0.7154f, 0.0721f), scene_sample.rgb),
        0.f);

    float soft_contribution = pixel_luminance - threshold + knee;
    soft_contribution = clamp(soft_contribution, 0.f, 2.f * knee);
    soft_contribution = soft_contribution * soft_contribution / max(4.f * knee, 1e-5f);
    const float contribution = max(pixel_luminance - threshold, soft_contribution);

    scene_sample.rgb *= contribution
                        / max(pixel_luminance * exposure_range, 1e-5f)
                        * CUSTOM_IMPROVED_BLOOM_STRENGTH;
  }
  return scene_sample;
}
