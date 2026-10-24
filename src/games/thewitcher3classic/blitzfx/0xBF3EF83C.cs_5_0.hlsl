#include "scene_pool.hlsli"

// BlitzFX bloom occupies the same normalized pool subrect as the scene.
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 24 00:39:23 2026
Texture2D<float4> t52 : register(t52);

Texture2D<float4> t51 : register(t51);

Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[46];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[1];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[24];
}




// 3Dmigoto declarations
#define cmp -


RWTexture2D<float4> output_color : register(u0);
[numthreads(8, 8, 1)]
void main(uint3 vThreadID : SV_DispatchThreadID)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = (uint2)vThreadID.xy;
  r0.xy = float2(0.5,0.5) + r0.xy;
  r0.zw = r0.xy / (2.f * cb1[0].xy);
  r1.xyzw = cb1[0].zwzw * float4(-1,0,1,0) + r0.zwzw;
  r2.xyz = t51.SampleLevel(s0_s, BlitzClampPoolUV(r1.xy, cb0[23].xy * 0.5f, cb1[0].xy, 0.5f), 0).xyz;
  r1.xyz = t51.SampleLevel(s0_s, BlitzClampPoolUV(r1.zw, cb0[23].xy * 0.5f, cb1[0].xy, 0.5f), 0).xyz;
  r2.xyzw = float4(0.125,0.125,0.125,0.125) * r2.xyzx;
  r3.xyz = t51.SampleLevel(s0_s, BlitzClampPoolUV(r0.zw, cb0[23].xy * 0.5f, cb1[0].xy, 0.5f), 0).xyz;
  r2.xyzw = r3.xyzx * float4(0.25,0.25,0.25,0.25) + r2.xyzw;
  r1.xyzw = r1.xyzx * float4(0.125,0.125,0.125,0.125) + r2.xyzw;
  r2.xyzw = cb1[0].zwzw * float4(0,-1,0,1) + r0.zwzw;
  r3.xyzw = cb1[0].zwzw * float4(1,-1,-1,1) + r0.zwzw;
  r4.xyz = t51.SampleLevel(s0_s, BlitzClampPoolUV(r2.xy, cb0[23].xy * 0.5f, cb1[0].xy, 0.5f), 0).xyz;
  r2.xyz = t51.SampleLevel(s0_s, BlitzClampPoolUV(r2.zw, cb0[23].xy * 0.5f, cb1[0].xy, 0.5f), 0).xyz;
  r1.xyzw = r4.xyzx * float4(0.125,0.125,0.125,0.125) + r1.xyzw;
  r1.xyzw = r2.xyzx * float4(0.125,0.125,0.125,0.125) + r1.xyzw;
  r0.zw = r0.xy / (2.f * cb1[0].xy) + -cb1[0].zw;
  r0.xy = r0.xy / (2.f * cb1[0].xy) + cb1[0].zw;
  r2.xyz = t51.SampleLevel(s0_s, BlitzClampPoolUV(r0.xy, cb0[23].xy * 0.5f, cb1[0].xy, 0.5f), 0).xyz;
  r0.xyz = t51.SampleLevel(s0_s, BlitzClampPoolUV(r0.zw, cb0[23].xy * 0.5f, cb1[0].xy, 0.5f), 0).xyz;
  r0.xyzw = r0.xyzx * float4(0.0625,0.0625,0.0625,0.0625) + r1.xyzw;
  r1.xyz = t51.SampleLevel(s0_s, BlitzClampPoolUV(r3.xy, cb0[23].xy * 0.5f, cb1[0].xy, 0.5f), 0).xyz;
  r3.xyz = t51.SampleLevel(s0_s, BlitzClampPoolUV(r3.zw, cb0[23].xy * 0.5f, cb1[0].xy, 0.5f), 0).xyz;
  r0.xyzw = r1.xyzx * float4(0.0625,0.0625,0.0625,0.0625) + r0.xyzw;
  r0.xyzw = r3.xyzx * float4(0.0625,0.0625,0.0625,0.0625) + r0.xyzw;
  r0.xyzw = r2.xyzx * float4(0.0625,0.0625,0.0625,0.0625) + r0.xyzw;
  r0.xyzw = min(float4(650000,650000,650000,650000), r0.xyzw);
  r1.xyzw = cmp(r0.wyzw == float4(650000,650000,650000,650000));
  r0.xyzw = r1.xyzw ? float4(0,0,0,0) : r0.xyzw;
  r1.xy = vThreadID.xy;
  r1.zw = float2(0,0);
  r2.xyz = t52.Load(r1.xyw).xyz;
  r1.xyz = t0.Load(r1.xyz).xyz;
  r1.x = dot(r1.xyz, float3(0.212599993,0.715200007,0.0722000003));
  r1.x = 1 + -r1.x;
  r1.x = cb2[45].z * r1.x;
  r1.x = max(cb2[42].x, r1.x);
  r0.xyzw = -r2.xyzx + r0.xyzw;
  r0.xyzw = r1.xxxx * r0.xyzw + r2.xyzx;
  output_color[vThreadID.xy] = r0.xyzw;
  return;
}
