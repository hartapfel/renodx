#include "scene_pool.hlsli"

// Current depth is render-sized; previous reconstructed scene color is output-sized.
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 24 00:53:36 2026
Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb3 : register(b3)
{
  float4 cb3[2];  // Captured buffer also carries render-to-quarter factors.
}

cbuffer cb0 : register(b0)
{
  float4 cb0[37];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  uint depth_width, depth_height;
  t1.GetDimensions(depth_width, depth_height);
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = floor(v0.xy);
  r0.xy = (uint2)r0.xy;
  r0.xy = (uint2)r0.xy;
  r0.xy = float2(0.5,0.5) + r0.xy;
  r1.xyzw = rcp(cb3[0].xyxy);
  r0.xy = r1.xy * r0.xy;
  r2.z = t1.SampleLevel(s1_s, BlitzScenePoolUV(r0.xy, cb3[0].xy * cb3[1].zw, float2(depth_width, depth_height)), 0).x;
  r2.xy = r0.xy * float2(2,-2) + float2(-1,1);
  r2.w = 1;
  r0.x = dot(cb0[24].xyzw, r2.xyzw);
  r0.y = dot(cb0[25].xyzw, r2.xyzw);
  r0.z = dot(cb0[26].xyzw, r2.xyzw);
  r0.w = dot(cb0[27].xyzw, r2.xyzw);
  r0.xyz = r0.xyz / r0.www;
  r0.w = 1;
  r2.x = dot(cb0[28].xyzw, r0.xyzw);
  r2.y = dot(cb0[29].xyzw, r0.xyzw);
  r0.x = dot(cb0[31].xyzw, r0.xyzw);
  r0.xy = r2.xy / r0.xx;
  r0.xy = -cb0[36].xy * float2(0.5,0.5) + r0.xy;
  r0.xy = r0.xy * float2(0.5,0.5) + float2(0.5,0.5);
  r0.z = 1 + -r0.y;
  r2.xyzw = r1.zwzw * float4(-0.5,-0.5,-0.5,0.5) + r0.xzxz;
  r0.xyzw = r1.xyzw * float4(0.5,-0.5,0.5,0.5) + r0.xzxz;
  r1.xyz = t2.SampleLevel(s0_s, r2.xy, 0).xyz;
  r2.xyz = t2.SampleLevel(s0_s, r2.zw, 0).xyz;
  r1.xyz = r2.xyz + r1.xyz;
  r2.xyz = t2.SampleLevel(s0_s, r0.xy, 0).xyz;
  r0.xyz = t2.SampleLevel(s0_s, r0.zw, 0).xyz;
  r1.xyz = r2.xyz + r1.xyz;
  r0.xyz = r1.xyz + r0.xyz;
  o0.xyz = float3(0.25,0.25,0.25) * r0.xyz;
  o0.w = 0;
  return;
}
