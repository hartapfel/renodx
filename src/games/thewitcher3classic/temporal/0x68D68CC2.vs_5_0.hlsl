// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 08:32:28 2026
cbuffer cb3 : register(b3)
{
  float4 cb3[10];
}

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
  float4 v4 : INSTANCE_TRANSFORM0,
  float4 v5 : INSTANCE_TRANSFORM1,
  float4 v6 : INSTANCE_TRANSFORM2,
  float4 v7 : INSTANCE_LOD_PARAMS0,
  uint motion_instance : SV_InstanceID,
  out float4 o0 : TEXCOORD0,
  out float4 o1 : TEXCOORD1,
  out float4 o2 : TEXCOORD2,
  out float4 o3 : TEXCOORD3,
  out float4 o4 : TEXCOORD4,
  out float4 o5 : TEXCOORD5,
  out float3 o6 : TEXCOORD6,
  out float4 o7 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.w = v1.x;
  r0.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r0.w = 1;
  o0.x = dot(r0.xyzw, cb3[7].xyzw);
  o0.y = dot(r0.xyzw, cb3[8].xyzw);
  o0.z = dot(r0.xyzw, cb3[9].xyzw);
  o1.xyzw = v7.xyzw;
  o2.xyz = float3(0,0,0);
  o2.w = v1.y;
  r1.xyz = v2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.x = dot(r1.xyz, v4.xyz);
  r2.y = dot(r1.xyz, v5.xyz);
  r2.z = dot(r1.xyz, v6.xyz);
  r1.w = dot(r2.xyz, r2.xyz);
  r1.w = rsqrt(r1.w);
  r2.xyz = r2.xyz * r1.www;
  o3.zw = r2.xy;
  o4.w = r2.z;
  o3.xy = v1.xy;
  r2.xyzw = v3.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r3.xyz = r2.yzx * r1.zxy;
  r1.xyz = r1.yzx * r2.zxy + -r3.xyz;
  r1.xyz = r1.xyz * r2.www;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  r1.xyz = r1.xyz * r1.www;
  r3.x = dot(r1.xyz, v4.xyz);
  r3.y = dot(r1.xyz, v5.xyz);
  r3.z = dot(r1.xyz, v6.xyz);
  r1.x = dot(r3.xyz, r3.xyz);
  r1.x = rsqrt(r1.x);
  o4.xyz = r3.xyz * r1.xxx;
  o5.x = dot(r0.xyzw, v4.xyzw);
  o5.y = dot(r0.xyzw, v5.xyzw);
  o5.z = dot(r0.xyzw, v6.xyzw);
  r1.x = dot(r2.xyz, v4.xyz);
  r1.y = dot(r2.xyz, v5.xyz);
  r1.z = dot(r2.xyz, v6.xyz);
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  o6.xyz = r1.xyz * r1.www;
  r1.xyzw = cb1[0].yyyy * v5.xyzw;
  r1.xyzw = v4.xyzw * cb1[0].xxxx + r1.xyzw;
  r1.xyzw = v6.xyzw * cb1[0].zzzz + r1.xyzw;
  r1.xyzw = cb1[0].wwww * float4(0,0,0,1) + r1.xyzw;
  o7.x = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[1].yyyy * v5.xyzw;
  r1.xyzw = v4.xyzw * cb1[1].xxxx + r1.xyzw;
  r1.xyzw = v6.xyzw * cb1[1].zzzz + r1.xyzw;
  r1.xyzw = cb1[1].wwww * float4(0,0,0,1) + r1.xyzw;
  o7.y = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[2].yyyy * v5.xyzw;
  r1.xyzw = v4.xyzw * cb1[2].xxxx + r1.xyzw;
  r1.xyzw = v6.xyzw * cb1[2].zzzz + r1.xyzw;
  r1.xyzw = cb1[2].wwww * float4(0,0,0,1) + r1.xyzw;
  o7.z = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[3].yyyy * v5.xyzw;
  r1.xyzw = v4.xyzw * cb1[3].xxxx + r1.xyzw;
  r1.xyzw = v6.xyzw * cb1[3].zzzz + r1.xyzw;
  r1.xyzw = cb1[3].wwww * float4(0,0,0,1) + r1.xyzw;
  o7.w = dot(r0.xyzw, r1.xyzw);
  previous_clip = PreviousRigidClip(v0 * cb2[4].xyz + cb2[5].xyz, motion_instance, motion_history);
  return;
}