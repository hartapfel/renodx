/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include "../../../shaders/color/ycbcr.hlsl"

Texture2D<float4> video_planes[3] : register(t0);
SamplerState video_samplers[3] : register(s0);

float4 main(float4 color : COLOR0, float2 uv : TEXCOORD0) : SV_Target0 {
  float3 ycbcr = float3(
      video_planes[0].Sample(video_samplers[0], uv).r,
      video_planes[1].Sample(video_samplers[1], uv).r,
      video_planes[2].Sample(video_samplers[2], uv).r);
  // Preserve the native 8-bit limited-range levels and vertex opacity.
  // Use the BT.709 coding coefficients (ITU-R BT.709-6, items 3.2-3.4),
  // rather than the slightly different coefficients of the RGB/XYZ matrix.
  return float4(renodx::color::ycbcr::Decode(
                    renodx::color::ycbcr::from::Limited(ycbcr),
                    float3(0.2126f, 0.7152f, 0.0722f)),
                color.a);
}
