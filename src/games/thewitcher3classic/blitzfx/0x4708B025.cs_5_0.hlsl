#include "scene_pool.hlsli"
#include "../shared.h"

// BlitzFX screen-space shadow inputs retain output-sized pool allocations.
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 24 00:58:54 2026
Texture2D<float4> t44 : register(t44);

Texture2D<float4> t43 : register(t43);

Texture2D<float4> t42 : register(t42);

Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[32];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[210];
}




// 3Dmigoto declarations
#define cmp -


RWTexture2D<float4> output_mask : register(u0);
[numthreads(8, 8, 1)]
void main(uint3 vThreadID : SV_DispatchThreadID)
{
  uint history_width, history_height, depth_width, depth_height;
  t42.GetDimensions(history_width, history_height);
  t44.GetDimensions(depth_width, depth_height);
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = vThreadID.xy;
  r0.zw = float2(0,0);
  r1.x = t0.Load(r0.xyw).x;
  r1.y = cmp(r1.x == 0.000000);
  if (r1.y != 0) {
    return;
  }
  r1.yz = (uint2)vThreadID.xy;
  r1.yz = float2(0.5,0.5) + r1.yz;
  r2.xy = cb0[23].zw * r1.yz;
  r0.x = t43.Load(r0.xyz).x;
  r0.yz = r2.xy * float2(2,-2) + float2(-1,1);
  r2.xyzw = cb0[207].xyzw * r0.zzzz;
  r2.xyzw = cb0[206].xyzw * r0.yyyy + r2.xyzw;
  r2.xyzw = cb0[208].xyzw * r1.xxxx + r2.xyzw;
  r2.xyzw = cb0[209].xyzw + r2.xyzw;
  r2.xyz = r2.xyz / r2.www;
  r2.w = 1;
  r3.x = dot(cb1[28].xyzw, r2.xyzw);
  r3.y = dot(cb1[29].xyzw, r2.xyzw);
  r0.y = dot(cb1[31].xyzw, r2.xyzw);
  r0.yz = r3.xy / r0.yy;
  r3.xy = r0.yz * float2(0.5,0.5) + float2(0.5,0.5);
  r4.x = dot(cb1[20].xyzw, r2.xyzw);
  r4.y = dot(cb1[21].xyzw, r2.xyzw);
  r0.y = dot(cb1[23].xyzw, r2.xyzw);
  r0.yz = r4.xy / r0.yy;
  r2.xy = r0.yz * float2(0.5,0.5) + float2(0.5,0.5);
  r2.z = 1 + -r2.y;
  r3.z = 1 + -r3.y;
  r0.yz = r3.xz + -r2.xz;
  r0.yz = r1.yz * cb0[23].zw + r0.yz;
  // BlitzFX's current/previous WVPs are unjittered even while the scene uses
  // our Halton projection. Account for the actual raster-sample displacement.
  r0.yz += float2(shader_injection.blitz_shadow_jitter_delta_x,
                 shader_injection.blitz_shadow_jitter_delta_y);
  r1.yz = cmp(r0.yz < float2(0,0));
  r0.w = (int)r1.z | (int)r1.y;
  r1.yz = cmp(float2(1,1) < r0.yz);
  r1.y = (int)r1.z | (int)r1.y;
  r0.w = (int)r0.w | (int)r1.y;
  if (r0.w != 0) {
      output_mask[vThreadID.xy] = r0.xxxx;
    return;
  }
  r2.xyzw = (int4)vThreadID.xyxy + int4(-1,-1,-1,0);
  r2.xyzw = (int4)r2.xyzw;
  r3.xyzw = float4(-1,-1,-1,-1) + cb0[23].xyxy;
  r2.xyzw = max(float4(0,0,0,0), r2.xyzw);
  r2.xyzw = min(r2.xyzw, r3.xyzw);
  r2.xyzw = (int4)r2.zwxy;
  r4.xy = r2.zw;
  r4.zw = float2(0,0);
  r0.w = t43.Load(r4.xyz).x;
  r1.y = min(r0.x, r0.w);
  r0.w = max(r0.x, r0.w);
  r2.zw = float2(0,0);
  r1.z = t43.Load(r2.xyz).x;
  r1.y = min(r1.y, r1.z);
  r0.w = max(r1.z, r0.w);
  r2.xyzw = (int4)vThreadID.xyxy + int4(-1,1,0,-1);
  r2.xyzw = (int4)r2.xyzw;
  r2.xyzw = max(float4(0,0,0,0), r2.xyzw);
  r2.xyzw = min(r2.xyzw, r3.xyzw);
  r2.xyzw = (int4)r2.zwxy;
  r4.xy = r2.zw;
  r4.zw = float2(0,0);
  r1.z = t43.Load(r4.xyz).x;
  r1.y = min(r1.y, r1.z);
  r0.w = max(r1.z, r0.w);
  r2.zw = float2(0,0);
  r1.z = t43.Load(r2.xyz).x;
  r1.y = min(r1.y, r1.z);
  r0.w = max(r1.z, r0.w);
  r2.xyzw = (int4)vThreadID.xyxy + int4(0,1,1,-1);
  r2.xyzw = (int4)r2.xyzw;
  r1.zw = min(r2.xy, r3.zw);
  r4.xy = (int2)r1.zw;
  r4.zw = float2(0,0);
  r1.z = t43.Load(r4.xyz).x;
  r1.y = min(r1.y, r1.z);
  r0.w = max(r1.z, r0.w);
  r1.zw = max(float2(0,0), r2.zw);
  r1.zw = min(r1.zw, r3.xy);
  r2.xy = (int2)r1.zw;
  r2.zw = float2(0,0);
  r1.z = t43.Load(r2.xyz).x;
  r1.y = min(r1.y, r1.z);
  r0.w = max(r1.z, r0.w);
  r2.xyzw = (int4)vThreadID.xyxy + int4(1,0,1,1);
  r2.xyzw = (int4)r2.xyzw;
  r2.xyzw = min(r2.xyzw, r3.xyzw);
  r2.xyzw = (int4)r2.zwxy;
  r3.xy = r2.zw;
  r3.zw = float2(0,0);
  r1.z = t43.Load(r3.xyz).x;
  r1.y = min(r1.y, r1.z);
  r0.w = max(r1.z, r0.w);
  r2.zw = float2(0,0);
  r1.z = t43.Load(r2.xyz).x;
  r1.y = min(r1.y, r1.z);
  r0.w = max(r1.z, r0.w);
  r1.x = r1.x * cb0[22].x + cb0[22].y;
  r1.x = r1.x * cb0[21].x + cb0[21].y;
  r1.x = max(9.99999975e-005, r1.x);
  r1.x = rcp(r1.x);
  r2.xyzw = t44.Gather(s0_s, BlitzScenePoolUV(r0.yz, cb0[23].xy, float2(depth_width, depth_height), 1.f)).xyzw;
  r3.xyzw = t42.Gather(s0_s, BlitzScenePoolUV(r0.yz, cb0[23].xy, float2(history_width, history_height), 1.f)).xyzw;
  r2.xyzw = -r2.xyzw + r1.xxxx;
  r2.xyzw = -abs(r2.xyzw) * float4(10,10,10,10) + float4(1,1,1,1);
  r2.xyzw = max(float4(0,0,0,0), r2.xyzw);
  r3.xyzw = r3.xyzw + -r0.xxxx;
  r2.xyzw = r2.xyzw * r3.xyzw + r0.xxxx;
  r0.yz = r0.yz * cb0[23].xy + float2(0.5,0.5);
  r0.yz = frac(r0.yz);
  r1.xz = r2.zy + -r2.wx;
  r1.xz = r0.yy * r1.xz + r2.wx;
  r0.y = r1.z + -r1.x;
  r0.y = r0.z * r0.y + r1.x;
  r0.y = max(r0.y, r1.y);
  r0.y = min(r0.y, r0.w);
  r0.z = -7.21347523 * cb1[0].y;
  r0.z = exp2(r0.z);
  r0.y = r0.y + -r0.x;
  r0.x = r0.z * r0.y + r0.x;
output_mask[vThreadID.xy] = r0.xxxx;
  return;
}
