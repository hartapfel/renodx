#include "../shared.h"

// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 11:52:20 2026
Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s4_s : register(s4);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb3 : register(b3)
{
  float4 cb3[3];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;
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
  r2.x = 63.75 * r1.z;
  r2.x = floor(r2.x);
  r1.w = 0.015625 * r2.x;
  r2.x = r1.z * 63.75 + -r2.x;
  r2.yzw = min(float3(1,1,1), r1.xyw);
  r1.xyz = r1.xyz * float3(1,1,0.99609375) + float3(0,0,0.015625);
  r1.xyz = min(float3(1,1,1), r1.xyz);
  r1.w = min(0.999989986, r2.w);
  r2.yz = float2(0.0078125,0.0078125) + r2.yz;
  r2.yz = float2(0.99609375,0.99609375) * r2.yz;
  r2.yz = max(float2(0.015625,0.015625), r2.yz);
  r2.yz = min(float2(0.984375,0.984375), r2.yz);
  r3.xy = float2(64,8) * r1.ww;
  r4.xz = floor(r3.yy);
  r1.w = -r4.x * 8 + r3.x;
  r4.y = floor(r1.w);
  r3.xy = float2(0.125,0.125) * r4.yz;
  r2.yz = r2.yz * float2(0.125,0.125) + r3.xy;
  r3.xyz = t4.SampleLevel(s4_s, r2.yz, 0).xyz;
  r1.z = min(0.999989986, r1.z);
  r1.xy = float2(0.0078125,0.0078125) + r1.xy;
  r1.xyzw = float4(0.99609375,0.99609375,64,8) * r1.xyzz;
  r1.xy = max(float2(0.015625,0.015625), r1.xy);
  r1.xy = min(float2(0.984375,0.984375), r1.xy);
  r4.xz = floor(r1.ww);
  r1.z = -r4.x * 8 + r1.z;
  r4.y = floor(r1.z);
  r1.zw = float2(0.125,0.125) * r4.yz;
  r1.xy = r1.xy * float2(0.125,0.125) + r1.zw;
  r4.xyz = t4.SampleLevel(s4_s, r1.xy, 0).xyz;
  r4.xyz = r4.xyz + -r3.xyz;
  r3.xyz = r2.xxx * r4.xyz + r3.xyz;
  r3.xyz = log2(abs(r3.xyz));
  r3.xyz = float3(2.20000005,2.20000005,2.20000005) * r3.xyz;
  r3.xyz = exp2(r3.xyz);
  r4.xyz = t3.SampleLevel(s3_s, r1.xy, 0).xyz;
  r5.xyz = t3.SampleLevel(s3_s, r2.yz, 0).xyz;
  r4.xyz = -r5.xyz + r4.xyz;
  r4.xyz = r2.xxx * r4.xyz + r5.xyz;
  r4.xyz = log2(abs(r4.xyz));
  r4.xyz = float3(2.20000005,2.20000005,2.20000005) * r4.xyz;
  r4.xyz = exp2(r4.xyz);
  r3.xyz = -r4.xyz + r3.xyz;
  r3.xyz = cb3[2].xxx * r3.xyz + r4.xyz;
  r3.xyz = cb3[2].zzz * r3.xyz + -r0.xyz;
  r3.xyz = cb3[2].yyy * r3.xyz + r0.xyz;
  r4.xyz = t2.SampleLevel(s2_s, r1.xy, 0).xyz;
  r1.xyz = t1.SampleLevel(s1_s, r1.xy, 0).xyz;
  r5.xyz = t2.SampleLevel(s2_s, r2.yz, 0).xyz;
  r2.yzw = t1.SampleLevel(s1_s, r2.yz, 0).xyz;
  r4.xyz = -r5.xyz + r4.xyz;
  r4.xyz = r2.xxx * r4.xyz + r5.xyz;
  r4.xyz = log2(abs(r4.xyz));
  r4.xyz = float3(2.20000005,2.20000005,2.20000005) * r4.xyz;
  r4.xyz = exp2(r4.xyz);
  r1.xyz = -r2.yzw + r1.xyz;
  r1.xyz = r2.xxx * r1.xyz + r2.yzw;
  r1.xyz = log2(abs(r1.xyz));
  r1.xyz = float3(2.20000005,2.20000005,2.20000005) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r2.xyz = r4.xyz + -r1.xyz;
  r1.xyz = cb3[1].xxx * r2.xyz + r1.xyz;
  r1.xyz = cb3[1].zzz * r1.xyz + -r0.xyz;
  r0.xyz = cb3[1].yyy * r1.xyz + r0.xyz;
  o0.w = r0.w;
  r1.xyz = r3.xyz + -r0.xyz;
  o0.xyz = cb3[2].www * r1.xyz + r0.xyz;
  o0.xyz /= max(scene_scale, 1e-6f);
  return;
}