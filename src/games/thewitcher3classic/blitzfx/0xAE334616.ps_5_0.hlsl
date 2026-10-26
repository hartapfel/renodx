#include "dof_kernel.hlsli"
#include "scene_pool.hlsli"
#include "../shared.h"
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 24 01:44:49 2026
Texture2D<float4> t52 : register(t52);

Texture2D<float4> t50 : register(t50);

SamplerState s1_s : register(s1);

cbuffer cb3 : register(b3)
{
  float4 cb3[1];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[53];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[24];
}

// 3Dmigoto declarations
#define cmp -

void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0,
  out float oDepth : SV_Depth)
{
  // Per-draw routing; the scene remains untouched by native alpha blending,
  // while depth/stencil behavior is identical to the native composite.
  if (RENODX_PEAK_WHITE_NITS > 0.f && shader_injection.blitz_bloom_active == -2.f) {
    o0 = 0.f;
    oDepth = 1.f;
    return;
  }

  uint color_width, color_height;
  t50.GetDimensions(color_width, color_height);
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = (int2)v0.xy;
  r0.zw = float2(0,0);
  r0.x = t52.Load(r0.xyz).x;
  r0.y = cb0[23].y * cb0[23].z;
  r0.z = cb3[0].z * cb1[52].w;
  r0.z = min(1, r0.z);
  r0.z = asuint(cb1[52].z) != 0u ? cb1[51].w : r0.z;
  r0.w = r0.x * r0.z;
  r0.w = 0.00499999989 * r0.w;
  r1.xyzw = float4(0,0,0,0);
  r2.x = 0;
  while (true) {
    r2.y = cmp((int)r2.x >= 9);
    if (r2.y != 0) break;
    r3.yz = icb[r2.x+0].xy * r0.ww;
    r3.x = r3.y * r0.y;
    r2.yz = v0.xy * cb0[23].zw + r3.xz;
    r3.xyzw = t50.SampleLevel(s1_s, BlitzScenePoolUV(r2.yz, floor(cb0[23].xy * .5f), float2(color_width, color_height)), 0).xyzw;
    r1.xyz = r3.xyz * r3.www + r1.xyz;
    r1.w = r3.w * r3.w + r1.w;
    r2.x = (int)r2.x + 1;
  }
  r0.y = cmp(0.00100000005 < r1.w);
  r1.xyz = r1.xyz / r1.www;
  o0.xyz = r0.yyy ? r1.xyz : 0;
  r0.x = r0.x * r0.z + -0.00999999978;
  r0.x = saturate(5.26315784 * r0.x);
  r0.y = r0.x * -2 + 3;
  r0.x = r0.x * r0.x;
  o0.w = r0.y * r0.x;
  oDepth = 1;
  return;
}
