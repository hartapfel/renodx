// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[4];
}




// 3Dmigoto declarations
#define cmp -


#include "./object_pixel.hlsli"

void main(
  float4 v0 : TEXCOORD0,
  float3 v1 : TEXCOORD1,
  float4 motion_position : SV_Position,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v2 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = t0.Sample(s0_s, v0.xy).xyz;
  r0.w = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r1.xyz = r0.www + -r0.xyz;
  r0.xyw = cb4[0].xxx * r1.xyz + r0.xyz;
  r0.xyw = cb4[1].xyz * r0.xyw;
  o0.xyz = cb4[2].xxx * r0.xyw;
  r0.x = dot(v1.xyz, v1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyw = v1.xyz * r0.xxx;
  r1.x = cmp(0 >= (uint)v2.x);
  if (r1.x != 0) {
    r1.x = dot(v1.xyz, r0.xyw);
    r1.xyz = v1.xyz * r1.xxx;
    r0.xyw = -r1.xyz * float3(2,2,2) + r0.xyw;
  }
  o2.xyz = cb4[3].xxx * r0.zzz;
  r0.z = dot(r0.xyw, r0.xyw);
  r0.z = rsqrt(r0.z);
  r0.xyz = r0.xyw * r0.zzz;
  r0.w = max(abs(r0.x), abs(r0.y));
  r0.w = max(abs(r0.z), r0.w);
  r1.xy = cmp(abs(r0.zy) < r0.ww);
  r1.yz = r1.yy ? abs(r0.zy) : abs(r0.zx);
  r1.xy = r1.xx ? r1.yz : abs(r0.yx);
  r1.z = cmp(r1.y < r1.x);
  r1.xy = r1.zz ? r1.xy : r1.yx;
  r1.z = r1.y / r1.x;
  r0.xyz = r0.xyz / r0.www;
  r0.w = t13.SampleLevel(s13_s, r1.xz, 0).x;
  r0.xyz = r0.xyz * r0.www;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = 0;
  o1.w = 0.5;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}