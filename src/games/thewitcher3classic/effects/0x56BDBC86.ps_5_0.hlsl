#include "bloom.hlsli"

// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 16:04:47 2026
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb3 : register(b3)
{
  float4 cb3[10];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
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
  r1.xyzw = float4(-1,-1,1,-1) / cb3[0].xyxy;
  r1.xyzw = r1.xyzw + r0.xyxy;
  r2.xyzw = float4(0.5,0.5,0.5,0.5) + cb3[5].xyzw;
  r2.xyzw = r2.xyzw / cb3[0].xyxy;
  r1.xyzw = max(r2.xyxy, r1.xyzw);
  r1.xyzw = min(r1.xyzw, r2.zwzw);
  r3.xyz = t0.SampleLevel(s0_s, r1.xy, 0).xyz;
  r3.xyz = ClassicBloomReference(r3.xyz, cb3[9].xyz);
  r1.xyz = t0.SampleLevel(s0_s, r1.zw, 0).xyz;
  r1.xyz = ClassicBloomReference(r1.xyz, cb3[9].xyz);
  r1.xyz = r3.xyz + r1.xyz;
  r0.zw = float2(-1,1) / cb3[0].xy;
  r0.zw = r0.xy + r0.zw;
  r0.zw = max(r0.zw, r2.xy);
  r0.zw = min(r0.zw, r2.zw);
  r3.xyz = t0.SampleLevel(s0_s, r0.zw, 0).xyz;
  r3.xyz = ClassicBloomReference(r3.xyz, cb3[9].xyz);
  r1.xyz = r3.xyz + r1.xyz;
  r0.zw = float2(1,1) / cb3[0].xy;
  r0.xy = r0.xy + r0.zw;
  r0.xy = max(r0.xy, r2.xy);
  r0.xy = min(r0.xy, r2.zw);
  r0.xyz = t0.SampleLevel(s0_s, r0.xy, 0).xyz;
  r0.xyz = ClassicBloomReference(r0.xyz, cb3[9].xyz);
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = float3(0.25,0.25,0.25) * r0.xyz;
  r0.w = dot(cb3[9].xyz, r0.xyz);
  r1.x = -cb3[8].x + r0.w;
  r0.w = max(9.99999975e-005, r0.w);
  r1.x = max(0, r1.x);
  r1.y = saturate(cb3[8].y * r1.x);
  r1.x = r1.x * r1.y;
  r1.x = min(cb3[7].x, r1.x);
  r0.w = r1.x / r0.w;
  r0.xyz = r0.xyz * r0.www;
  o0.xyz = cb3[6].xxx * r0.xyz;
  o0.w = 0;
  return;
}