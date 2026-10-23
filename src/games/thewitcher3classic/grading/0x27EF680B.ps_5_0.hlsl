#include "../shared.h"

// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 16:04:47 2026
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb3 : register(b3)
{
  float4 cb3[2];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = max(cb3[0].xy, v1.xy);
  r0.xy = min(cb3[0].zw, r0.xy);
  r0.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  // Keep the original packed 64^3 addressing and game-controlled blend.
  // N2 compresses the scene into LUT range; restore that range after grading.
  float scene_scale = 1.f;
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31 && RENODX_PEAK_WHITE_NITS > 0.f) {
    scene_scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(r0.xyz);
    r0.xyz *= scene_scale;
  }

  r1.xyz = log2(abs(r0.xyz));
  r1.xyz = float3(0.454545468,0.454545468,0.454545468) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r2.xyz = r1.xyz * float3(1,1,0.99609375) + float3(0,0,0.015625);
  r2.xyz = min(float3(1,1,1), r2.xyz);
  r2.z = min(0.999989986, r2.z);
  r2.xy = float2(0.0078125,0.0078125) + r2.xy;
  r2.xyzw = float4(0.99609375,0.99609375,64,8) * r2.xyzz;
  r2.xy = max(float2(0.015625,0.015625), r2.xy);
  r2.xy = min(float2(0.984375,0.984375), r2.xy);
  r3.xz = floor(r2.ww);
  r2.z = -r3.x * 8 + r2.z;
  r3.y = floor(r2.z);
  r2.zw = float2(0.125,0.125) * r3.yz;
  r2.xy = r2.xy * float2(0.125,0.125) + r2.zw;
  r2.xyz = t1.SampleLevel(s1_s, r2.xy, 0).xyz;
  r2.w = 63.75 * r1.z;
  r2.w = floor(r2.w);
  r1.w = 0.015625 * r2.w;
  r1.z = r1.z * 63.75 + -r2.w;
  r1.xyw = min(float3(1,1,1), r1.xyw);
  r1.w = min(0.999989986, r1.w);
  r1.xy = float2(0.0078125,0.0078125) + r1.xy;
  r1.xy = float2(0.99609375,0.99609375) * r1.xy;
  r1.xy = max(float2(0.015625,0.015625), r1.xy);
  r1.xy = min(float2(0.984375,0.984375), r1.xy);
  r3.xy = float2(64,8) * r1.ww;
  r4.xz = floor(r3.yy);
  r1.w = -r4.x * 8 + r3.x;
  r4.y = floor(r1.w);
  r3.xy = float2(0.125,0.125) * r4.yz;
  r1.xy = r1.xy * float2(0.125,0.125) + r3.xy;
  r1.xyw = t1.SampleLevel(s1_s, r1.xy, 0).xyz;
  r2.xyz = r2.xyz + -r1.xyw;
  r1.xyz = r1.zzz * r2.xyz + r1.xyw;
  r1.xyz = log2(abs(r1.xyz));
  r1.xyz = float3(2.20000005,2.20000005,2.20000005) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r1.xyz = cb3[1].zzz * r1.xyz + -r0.xyz;
  o0.xyz = cb3[1].yyy * r1.xyz + r0.xyz;
  o0.xyz /= max(scene_scale, 1e-6f);
  o0.w = r0.w;
  return;
}