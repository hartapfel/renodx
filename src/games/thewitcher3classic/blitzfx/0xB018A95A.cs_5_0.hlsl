RWTexture2D<float4> u0 : register(u0);
RWTexture2D<float4> u1 : register(u1);
#include "scene_pool.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 24 01:44:49 2026
Texture2D<float4> t52 : register(t52);

Texture2D<float4> t50 : register(t50);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[24];
}

// 3Dmigoto declarations
#define cmp -

[numthreads(8, 8, 1)]
void main(uint3 vThreadID : SV_DispatchThreadID)
{

  uint color_width, color_height, coc_width, coc_height;
  t50.GetDimensions(color_width, color_height);
  t52.GetDimensions(coc_width, coc_height);
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = (uint2)vThreadID.xy;
  r0.xy = float2(0.5,0.5) + r0.xy;
  r0.zw = cb0[23].zw + cb0[23].zw;
  r0.xy = r0.xy * r0.zw;
  r1.xyzw = t52.GatherRed(s0_s, BlitzScenePoolUV(r0.xy, cb0[23].xy, float2(coc_width, coc_height), 1.f)).xyzw;
  r0.z = r1.x + r1.y;
  r0.z = r0.z + r1.z;
  r0.z = r0.z + r1.w;
  r2.w = 0.25 * r0.z;
  r3.xyzw = t50.GatherRed(s0_s, BlitzScenePoolUV(r0.xy, cb0[23].xy, float2(color_width, color_height), 1.f)).xyzw;
  r0.z = dot(r3.xyzw, r1.xyzw);
  r2.x = 0.25 * r0.z;
  r3.xyzw = t50.GatherGreen(s0_s, BlitzScenePoolUV(r0.xy, cb0[23].xy, float2(color_width, color_height), 1.f)).xyzw;
  r0.xyzw = t50.GatherBlue(s0_s, BlitzScenePoolUV(r0.xy, cb0[23].xy, float2(color_width, color_height), 1.f)).xyzw;
  r0.x = dot(r0.xyzw, r1.xyzw);
  r2.z = 0.25 * r0.x;
  r0.x = dot(r3.xyzw, r1.xyzw);
  r2.y = 0.25 * r0.x;
  u0[vThreadID.xy] = r2;
  r0.x = max(r1.z, r1.w);
  r0.x = max(r1.y, r0.x);
  r0.x = max(r1.x, r0.x);
  u1[vThreadID.xy] = r0.xxxx;
  return;
}