#include "../shared.h"

// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 16:04:47 2026
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb3 : register(b3)
{
  float4 cb3[9];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = (int2)v0.xy;
  r0.zw = (int2)cb3[4].zw;
  r0.xy = (int2)-r0.zw + (int2)r0.xy;
  r0.xy = (int2)r0.xy;
  r0.xy = float2(0.5,0.5) + r0.xy;
  r0.xy = r0.xy / cb3[3].xy;
  r0.zw = trunc(cb3[4].xy);
  r0.xy = r0.xy * cb3[1].xy + r0.zw;
  r0.xy = r0.xy / cb3[0].xy;
  r1.xyzw = float4(0.5,0.5,0.5,0.5) + cb3[5].xyzw;
  r1.xyzw = r1.xyzw / cb3[0].xyxy;
  r0.xy = max(r1.xy, r0.xy);
  r0.xy = min(r0.xy, r1.zw);
  r0.xyz = t0.SampleLevel(s0_s, r0.xy, 0).xyz;
  r1.xy = cb3[8].xy * v0.xy;
  r1.xyz = t1.Sample(s1_s, r1.xy).xyz;
  // Dirt scales separately from the uniform bloom contribution.
  if (RENODX_PEAK_WHITE_NITS > 0.f) r1.xyz *= shader_injection.custom_lens_dirt;
  r1.xyz = cb3[7].xyz * r1.xyz + cb3[6].xyz;
  o0.xyz = r1.xyz * r0.xyz;
  if (RENODX_PEAK_WHITE_NITS > 0.f) o0.xyz *= shader_injection.custom_bloom;
  o0.w = 0;
  return;
}