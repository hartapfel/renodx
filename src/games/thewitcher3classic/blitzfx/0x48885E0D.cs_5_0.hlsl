RWTexture2D<float4> u0 : register(u0);
#include "dof_kernel.hlsli"
#include "scene_pool.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 24 01:44:49 2026
Texture2D<float4> t51 : register(t51);

Texture2D<float4> t50 : register(t50);

SamplerState s0_s : register(s0);

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

[numthreads(8, 8, 1)]
void main(uint3 vThreadID : SV_DispatchThreadID)
{

  uint color_width, color_height;
  t50.GetDimensions(color_width, color_height);
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = vThreadID.xy;
  r0.zw = float2(0,0);
  r1.x = t51.Load(r0.xyw).x;
  r1.y = cmp(r1.x == 0.000000);
  if (r1.y != 0) {
    u0[vThreadID.xy] = 0;
    return;
  }
  r1.yz = cb0[23].zw + cb0[23].zw;
  r2.xy = (uint2)vThreadID.xy;
  r2.xy = float2(0.5,0.5) + r2.xy;
  r1.w = cb0[23].y * cb0[23].z;
  r2.z = cb3[0].z * cb1[52].w;
  r2.z = min(1, r2.z);
  r2.z = asuint(cb1[52].z) != 0u ? cb1[51].w : r2.z;
  r1.x = r2.z * r1.x;
  r1.x = 0.00999999978 * r1.x;
  r3.xyz = float3(0,0,0);
  r2.zw = float2(0,0);
  while (true) {
    r3.w = cmp((int)r2.w >= 49);
    if (r3.w != 0) break;
    r4.yz = icb[r2.w+0].xy * r1.xx;
    r4.x = r4.y * r1.w;
    r4.xy = r2.xy * r1.yz + r4.xz;
    r4.xyzw = t50.SampleLevel(s0_s, BlitzScenePoolUV(r4.xy, floor(cb0[23].xy * .5f), float2(color_width, color_height)), 0).xyzw;
    r3.xyz = r4.xyz * r4.www + r3.xyz;
    r2.z = r4.w * r4.w + r2.z;
    r2.w = (int)r2.w + 1;
  }
  r1.x = cmp(0.00100000005 < r2.z);
  r1.yzw = r3.xyz / r2.zzz;
  r1.xyz = r1.xxx ? r1.yzw : 0;
  r0.w = t50.Load(r0.xyz).w;
  r0.xyz = r1.xyz * r0.www;
  u0[vThreadID.xy] = r0;
  return;
}