// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 20:46:48 2026
cbuffer cb2 : register(b2)
{
  float4 cb2[7];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[4];
}




// 3Dmigoto declarations
#define cmp -


#include "./deformed_vertex.hlsli"

void main(
  float3 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TANGENT0,
  float2 v3 : TEXCOORD0,
  uint vertex : SV_VertexID,
  out float4 o0 : TEXCOORD0,
  out float4 o1 : TEXCOORD1,
  out float4 o2 : TEXCOORD2,
  out float3 o3 : TEXCOORD3,
  out float4 o4 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xyzw = cb2[6].xyzw;
  r0.x = dot(v1.xyz, cb2[0].xyz);
  r0.y = dot(v1.xyz, cb2[1].xyz);
  r0.z = dot(v1.xyz, cb2[2].xyz);
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  o1.zw = r0.xy;
  o2.w = r0.z;
  o1.xy = v3.xy * float2(1,-1) + float2(0,1);
  r0.xyz = v2.zxy * v1.yzx;
  r0.xyz = v2.yzx * v1.zxy + -r0.xyz;
  r0.xyz = v2.www * r0.xyz;
  r1.x = dot(r0.xyz, cb2[0].xyz);
  r1.y = dot(r0.xyz, cb2[1].xyz);
  r1.z = dot(r0.xyz, cb2[2].xyz);
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  o2.xyz = r1.xyz * r0.xxx;
  r0.x = dot(v2.xyz, cb2[0].xyz);
  r0.y = dot(v2.xyz, cb2[1].xyz);
  r0.z = dot(v2.xyz, cb2[2].xyz);
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o3.xyz = r0.xyz * r0.www;
  r0.xyzw = cb2[1].xyzw * cb1[0].yyyy;
  r0.xyzw = cb2[0].xyzw * cb1[0].xxxx + r0.xyzw;
  r0.xyzw = cb2[2].xyzw * cb1[0].zzzz + r0.xyzw;
  r0.xyzw = cb1[0].wwww * float4(0,0,0,1) + r0.xyzw;
  r1.xyz = v0.xyz;
  r1.w = 1;
  o4.x = dot(r1.xyzw, r0.xyzw);
  r0.xyzw = cb2[1].xyzw * cb1[1].yyyy;
  r0.xyzw = cb2[0].xyzw * cb1[1].xxxx + r0.xyzw;
  r0.xyzw = cb2[2].xyzw * cb1[1].zzzz + r0.xyzw;
  r0.xyzw = cb1[1].wwww * float4(0,0,0,1) + r0.xyzw;
  o4.y = dot(r1.xyzw, r0.xyzw);
  r0.xyzw = cb2[1].xyzw * cb1[2].yyyy;
  r0.xyzw = cb2[0].xyzw * cb1[2].xxxx + r0.xyzw;
  r0.xyzw = cb2[2].xyzw * cb1[2].zzzz + r0.xyzw;
  r0.xyzw = cb1[2].wwww * float4(0,0,0,1) + r0.xyzw;
  o4.z = dot(r1.xyzw, r0.xyzw);
  r0.xyzw = cb2[1].xyzw * cb1[3].yyyy;
  r0.xyzw = cb2[0].xyzw * cb1[3].xxxx + r0.xyzw;
  r0.xyzw = cb2[2].xyzw * cb1[3].zzzz + r0.xyzw;
  r0.xyzw = cb1[3].wwww * float4(0,0,0,1) + r0.xyzw;
  o4.w = dot(r1.xyzw, r0.xyzw);
  previous_clip = PreviousDeformedClip(vertex, motion_history);
  return;
}