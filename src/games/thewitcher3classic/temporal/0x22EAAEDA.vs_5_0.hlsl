// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 20:56:41 2026
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
  out float4 o3 : TEXCOORD3,
  out float3 o4 : TEXCOORD4,
  out float4 o5 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.w = 0;
  r1.xyz = v2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.xyzw = v3.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r3.xyz = r2.yzx * r1.zxy;
  r3.xyz = r1.yzx * r2.zxy + -r3.xyz;
  r3.xyz = r3.xyz * r2.www;
  r1.w = dot(r3.xyz, r3.xyz);
  r1.w = rsqrt(r1.w);
  r3.xyz = r3.xyz * r1.www;
  r4.x = dot(r3.xyz, v6.xyz);
  r4.y = dot(r3.xyz, v7.xyz);
  r4.z = dot(r3.xyz, v8.xyz);
  r1.w = dot(r4.xyz, r4.xyz);
  r1.w = rsqrt(r1.w);
  r0.xyz = r4.xyz * r1.www;
  o0.xyzw = r0.wwwx;
  o1.zw = r0.yz;
  o1.xy = v1.xy;
  r0.x = dot(r1.xyz, v6.xyz);
  r0.y = dot(r1.xyz, v7.xyz);
  r0.z = dot(r1.xyz, v8.xyz);
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r0.xyz * r0.www;
  r0.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r0.w = 1;
  o3.x = dot(r0.xyzw, v6.xyzw);
  o3.y = dot(r0.xyzw, v7.xyzw);
  o3.z = dot(r0.xyzw, v8.xyzw);
  r1.x = dot(r2.xyz, v6.xyz);
  r1.y = dot(r2.xyz, v7.xyz);
  r1.z = dot(r2.xyz, v8.xyz);
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  o4.xyz = r1.xyz * r1.www;
  r1.xyzw = cb1[0].yyyy * v7.xyzw;
  r1.xyzw = v6.xyzw * cb1[0].xxxx + r1.xyzw;
  r1.xyzw = v8.xyzw * cb1[0].zzzz + r1.xyzw;
  r1.xyzw = cb1[0].wwww * float4(0,0,0,1) + r1.xyzw;
  o5.x = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[1].yyyy * v7.xyzw;
  r1.xyzw = v6.xyzw * cb1[1].xxxx + r1.xyzw;
  r1.xyzw = v8.xyzw * cb1[1].zzzz + r1.xyzw;
  r1.xyzw = cb1[1].wwww * float4(0,0,0,1) + r1.xyzw;
  o5.y = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[2].yyyy * v7.xyzw;
  r1.xyzw = v6.xyzw * cb1[2].xxxx + r1.xyzw;
  r1.xyzw = v8.xyzw * cb1[2].zzzz + r1.xyzw;
  r1.xyzw = cb1[2].wwww * float4(0,0,0,1) + r1.xyzw;
  o5.z = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[3].yyyy * v7.xyzw;
  r1.xyzw = v6.xyzw * cb1[3].xxxx + r1.xyzw;
  r1.xyzw = v8.xyzw * cb1[3].zzzz + r1.xyzw;
  r1.xyzw = cb1[3].wwww * float4(0,0,0,1) + r1.xyzw;
  o5.w = dot(r0.xyzw, r1.xyzw);
  previous_clip = PreviousRigidClip(v0 * cb2[4].xyz + cb2[5].xyz, instance, motion_history);
  return;
}