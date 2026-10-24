#include "scene_pool.hlsli"

// Native water SSR history: BlitzFX preserves output-sized scratch allocations.
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 24 00:40:06 2026
Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb3 : register(b3)
{
  float4 cb3[9];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[32];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  uint mask_width, mask_height, depth_width, depth_height, history_width, history_height;
  t0.GetDimensions(mask_width, mask_height);
  t3.GetDimensions(depth_width, depth_height);
  t2.GetDimensions(history_width, history_height);
  const float2 scene_size = cb3[0].xy * cb3[8].zw;
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.zw = float2(0,0);
  r1.xy = (uint2)v0.xy;
  r1.xy = (uint2)r1.xy;
  r2.xyz = (int3)r1.xyy;
  r3.xyz = (int3)r2.xzz + int3(-1,0,-1);
  r0.xy = r3.xz;
  r0.xyz = t1.Load(r0.xyz).xyz;
  r4.xy = (int2)r1.xy;
  r1.xy = float2(0.5,0.5) + r1.xy;
  r4.zw = float2(0,0);
  r4.xyz = t1.Load(r4.xyz).xyz;
  r5.xyz = max(r4.xyz, r0.xyz);
  r0.xyz = min(r4.xyz, r0.xyz);
  r3.zw = float2(0,0);
  r3.xyz = t1.Load(r3.xyz).xyz;
  r5.xyz = max(r3.xyz, r5.xyz);
  r0.xyz = min(r3.xyz, r0.xyz);
  r3.xyzw = (int4)r2.xzxz + int4(0,-1,-1,1);
  r6.xy = r3.zw;
  r6.zw = float2(0,0);
  r6.xyz = t1.Load(r6.xyz).xyz;
  r5.xyz = max(r6.xyz, r5.xyz);
  r0.xyz = min(r6.xyz, r0.xyz);
  r3.zw = float2(0,0);
  r3.xyz = t1.Load(r3.xyz).xyz;
  r5.xyz = max(r3.xyz, r5.xyz);
  r0.xyz = min(r3.xyz, r0.xyz);
  r0.xyz = min(r0.xyz, r4.xyz);
  r3.xyz = max(r5.xyz, r4.xyz);
  r5.xyzw = (int4)r2.xzxz + int4(1,-1,0,1);
  r2.xyz = (int3)r2.xyz + int3(1,1,0);
  r6.xy = r5.zw;
  r6.zw = float2(0,0);
  r6.xyz = t1.Load(r6.xyz).xyz;
  r3.xyz = max(r6.xyz, r3.xyz);
  r0.xyz = min(r6.xyz, r0.xyz);
  r5.zw = float2(0,0);
  r5.xyz = t1.Load(r5.xyz).xyz;
  r3.xyz = max(r5.xyz, r3.xyz);
  r0.xyz = min(r5.xyz, r0.xyz);
  r5.xy = r2.xz;
  r5.zw = float2(0,0);
  r5.xyz = t1.Load(r5.xyz).xyz;
  r3.xyz = max(r5.xyz, r3.xyz);
  r0.xyz = min(r5.xyz, r0.xyz);
  r2.zw = float2(0,0);
  r2.xyz = t1.Load(r2.xyz).xyz;
  r3.xyz = max(r2.xyz, r3.xyz);
  r0.xyz = min(r2.xyz, r0.xyz);
  r1.zw = rcp(cb3[0].xy);
  r1.xy = r1.xy * r1.zw;
  r1.zw = float2(1,1) + -r1.zw;
  r2.z = t3.SampleLevel(s0_s, BlitzScenePoolUV(r1.xy, scene_size, float2(depth_width, depth_height)), 0).x;
  r2.xy = r1.xy * float2(2,-2) + float2(-1,1);
  r0.w = t0.Sample(s1_s, BlitzScenePoolUV(r1.xy, scene_size, float2(mask_width, mask_height))).w;
  r0.w = cmp(0 < r0.w);
  r0.w = r0.w ? 1.000000 : 0;
  r2.w = 1;
  r5.x = dot(cb0[24].xyzw, r2.xyzw);
  r5.y = dot(cb0[25].xyzw, r2.xyzw);
  r5.z = dot(cb0[26].xyzw, r2.xyzw);
  r1.x = dot(cb0[27].xyzw, r2.xyzw);
  r2.xyz = r5.xyz / r1.xxx;
  r2.w = 1;
  r1.x = dot(cb0[28].xyzw, r2.xyzw);
  r1.y = dot(cb0[29].xyzw, r2.xyzw);
  r2.x = dot(cb0[31].xyzw, r2.xyzw);
  r1.xy = r1.xy / r2.xx;
  r2.xy = r1.xy * float2(0.5,0.5) + float2(0.5,0.5);
  r2.z = 1 + -r2.y;
  r1.xy = BlitzScenePoolUV(r2.xz, cb3[0].xy, float2(history_width, history_height));
  r5.xyz = t2.Sample(s1_s, r1.xy).xyz;
  r0.xyz = max(r5.xyz, r0.xyz);
  r0.xyz = min(r0.xyz, r3.xyz);
  r0.xyz = r0.xyz + -r5.xyz;
  r0.xyz = r0.www * r0.xyz + r5.xyz;
  r0.xyz = r0.xyz + -r4.xyz;
  r1.xy = cmp(r2.xz >= r1.zw);
  r1.zw = cmp(float2(0,0) >= r2.xz);
  r1.xy = (int2)r1.xy | (int2)r1.zw;
  r0.w = (int)r1.y | (int)r1.x;
  r1.x = -2.88539004 * cb0[0].y;
  r1.x = exp2(r1.x);
  r0.w = r0.w ? 0 : r1.x;
  o0.xyz = r0.www * r0.xyz + r4.xyz;
  o0.w = 1;
  return;
}