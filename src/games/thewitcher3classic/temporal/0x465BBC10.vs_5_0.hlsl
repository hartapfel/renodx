// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 21:33:02 2026
cbuffer cb2 : register(b2)
{
  float4 cb2[6];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[4];
}




// 3Dmigoto declarations
#define cmp -


#include "./rigid_vertex.hlsli"

void main(
  float3 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  float4 v3 : TANGENT0,
  float4 v4 : COLOR0,
  float2 v5 : TEXCOORD1,
  float4 v6 : INSTANCE_TRANSFORM0,
  float4 v7 : INSTANCE_TRANSFORM1,
  float4 v8 : INSTANCE_TRANSFORM2,
  float4 v9 : INSTANCE_LOD_PARAMS0,
  uint instance : SV_InstanceID,
  out float4 o0 : TEXCOORD0,
  out float4 o1 : TEXCOORD1,
  out float4 o2 : TEXCOORD2,
  out float3 o3 : TEXCOORD3,
  out float4 o4 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v1.xy;
  o0.zw = v5.xy;
  r0.xyz = v2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = v3.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r2.xyz = r1.yzx * r0.zxy;
  r2.xyz = r0.yzx * r1.zxy + -r2.xyz;
  r2.xyz = r2.xyz * r1.www;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r3.x = dot(r2.xyz, v6.xyz);
  r3.y = dot(r2.xyz, v7.xyz);
  r3.z = dot(r2.xyz, v8.xyz);
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  o1.xyz = r3.xyz * r0.www;
  r2.x = dot(r0.xyz, v6.xyz);
  r2.y = dot(r0.xyz, v7.xyz);
  r2.z = dot(r0.xyz, v8.xyz);
  r0.x = dot(r2.xyz, r2.xyz);
  r0.x = rsqrt(r0.x);
  o2.xyz = r2.xyz * r0.xxx;
  r0.x = dot(r1.xyz, v6.xyz);
  r0.y = dot(r1.xyz, v7.xyz);
  r0.z = dot(r1.xyz, v8.xyz);
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o3.xyz = r0.xyz * r0.www;
  r0.xyzw = cb1[0].yyyy * v7.xyzw;
  r0.xyzw = v6.xyzw * cb1[0].xxxx + r0.xyzw;
  r0.xyzw = v8.xyzw * cb1[0].zzzz + r0.xyzw;
  r0.xyzw = cb1[0].wwww * float4(0,0,0,1) + r0.xyzw;
  r1.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r1.w = 1;
  o4.x = dot(r1.xyzw, r0.xyzw);
  r0.xyzw = cb1[1].yyyy * v7.xyzw;
  r0.xyzw = v6.xyzw * cb1[1].xxxx + r0.xyzw;
  r0.xyzw = v8.xyzw * cb1[1].zzzz + r0.xyzw;
  r0.xyzw = cb1[1].wwww * float4(0,0,0,1) + r0.xyzw;
  o4.y = dot(r1.xyzw, r0.xyzw);
  r0.xyzw = cb1[2].yyyy * v7.xyzw;
  r0.xyzw = v6.xyzw * cb1[2].xxxx + r0.xyzw;
  r0.xyzw = v8.xyzw * cb1[2].zzzz + r0.xyzw;
  r0.xyzw = cb1[2].wwww * float4(0,0,0,1) + r0.xyzw;
  o4.z = dot(r1.xyzw, r0.xyzw);
  r0.xyzw = cb1[3].yyyy * v7.xyzw;
  r0.xyzw = v6.xyzw * cb1[3].xxxx + r0.xyzw;
  r0.xyzw = v8.xyzw * cb1[3].zzzz + r0.xyzw;
  r0.xyzw = cb1[3].wwww * float4(0,0,0,1) + r0.xyzw;
  o4.w = dot(r1.xyzw, r0.xyzw);
  previous_clip = PreviousRigidClip(v0 * cb2[4].xyz + cb2[5].xyz, instance, motion_history);
  return;
}