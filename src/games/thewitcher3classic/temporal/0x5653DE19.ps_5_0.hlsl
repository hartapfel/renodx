// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}




// 3Dmigoto declarations
#define cmp -


#include "./object_pixel.hlsli"

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float3 v3 : TEXCOORD3,
  float4 motion_position : SV_Position,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v4 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = cb1[8].xyz + -v2.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r1.xy = v0.zw;
  r1.z = v1.w;
  r0.x = dot(r1.xyz, r0.xyz);
  r0.x = saturate(1 + -r0.x);
  r0.y = r0.x * r0.x;
  r0.x = r0.x * r0.y;
  r0.yzw = t0.Sample(s0_s, v0.xy).xyz;
  r0.yzw = float3(1,0.964706004,0.925490022) * r0.yzw;
  o0.xyz = r0.xxx * float3(0.200000003,0.200000003,0.200000003) + r0.yzw;
  r0.xyz = t1.Sample(s0_s, v0.xy).xyw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = r0.x * r0.z;
  r0.z = -r0.x * r0.x + 1;
  r0.z = -r0.y * r0.y + r0.z;
  r0.z = max(0, r0.z);
  r0.z = rsqrt(r0.z);
  r0.z = 1 / r0.z;
  r2.xyz = v1.xyz * r0.yyy;
  r0.xyw = v3.xyz * r0.xxx + r2.xyz;
  r0.xyz = r1.xyz * r0.zzz + r0.xyw;
  r0.w = cmp(0 >= (uint)v4.x);
  if (r0.w != 0) {
    r0.w = dot(r1.xyz, r0.xyz);
    r1.xyz = r1.xyz * r0.www;
    r0.xyz = -r1.xyz * float3(2,2,2) + r0.xyz;
  }
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
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
  o2.xyzw = float4(0,0,0,0);
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}