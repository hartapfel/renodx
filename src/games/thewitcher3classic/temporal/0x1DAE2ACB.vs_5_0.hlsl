// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:06:31 2026
struct t0_t {
  float val[16];
};
StructuredBuffer<t0_t> t0 : register(t0);

cbuffer cb3 : register(b3)
{
  float4 cb3[10];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[8];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[4];
}




// 3Dmigoto declarations
#define cmp -


#include "./object_vertex.hlsli"

void main(
  float3 v0 : POSITION0,
  uint4 v1 : BLENDINDICES0,
  float4 v2 : BLENDWEIGHT0,
  float2 v3 : TEXCOORD0,
  float3 v4 : NORMAL0,
  float4 v5 : TANGENT0,
  uint motion_instance : SV_InstanceID,
  out float4 o0 : TEXCOORD0,
  out float4 o1 : TEXCOORD1,
  out float4 o2 : TEXCOORD2,
  out float4 o3 : TEXCOORD3,
  out float4 o4 : TEXCOORD4,
  out float3 o5 : TEXCOORD5,
  out float4 o6 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v2.x + v2.y;
  r0.x = v2.z + r0.x;
  r0.x = v2.w + r0.x;
  r0.xyzw = v2.xyzw / r0.xxxx;
  r1.xyzw = (uint4)v1.xyzw;
  r1.xyzw = r1.xyzw * cb2[7].yyyy + cb2[7].xxxx;
  r1.xyzw = (uint4)r1.xyzw;
  r2.x = t0[r1.y].val[48/4];
  r2.y = t0[r1.y].val[48/4+1];
  r2.w = t0[r1.y].val[48/4+2];
  r3.w = r2.x;
  r4.x = t0[r1.y].val[0/4];
  r4.y = t0[r1.y].val[0/4+1];
  r4.z = t0[r1.y].val[0/4+2];
  r4.w = t0[r1.y].val[0/4+3];
  r3.x = r4.x;
  r5.x = t0[r1.y].val[16/4];
  r5.y = t0[r1.y].val[16/4+1];
  r5.z = t0[r1.y].val[16/4+2];
  r5.w = t0[r1.y].val[16/4+3];
  r3.y = r5.x;
  r6.x = t0[r1.y].val[32/4];
  r6.y = t0[r1.y].val[32/4+1];
  r6.z = t0[r1.y].val[32/4+2];
  r6.w = t0[r1.y].val[32/4+3];
  r3.z = r6.x;
  r7.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r7.w = 1;
  r3.x = dot(r7.xyzw, r3.xyzw);
  r8.w = r2.y;
  r8.x = r4.y;
  r8.y = r5.y;
  r8.z = r6.y;
  r3.y = dot(r7.xyzw, r8.xyzw);
  r2.x = r4.z;
  r2.y = r5.z;
  r2.z = r6.z;
  r3.z = dot(r7.xyzw, r2.xyzw);
  r2.w = 1;
  r2.x = r4.w;
  r4.xyzw = r4.xyzw * r0.yyyy;
  r2.y = r5.w;
  r5.xyzw = r5.xyzw * r0.yyyy;
  r2.z = r6.w;
  r6.xyzw = r6.xyzw * r0.yyyy;
  r3.w = dot(r7.xyzw, r2.xyzw);
  r2.xyzw = r3.xyzw * r0.yyyy;
  r3.x = t0[r1.x].val[48/4];
  r3.y = t0[r1.x].val[48/4+1];
  r3.w = t0[r1.x].val[48/4+2];
  r8.w = r3.x;
  r9.x = t0[r1.x].val[0/4];
  r9.y = t0[r1.x].val[0/4+1];
  r9.z = t0[r1.x].val[0/4+2];
  r9.w = t0[r1.x].val[0/4+3];
  r8.x = r9.x;
  r10.x = t0[r1.x].val[16/4];
  r10.y = t0[r1.x].val[16/4+1];
  r10.z = t0[r1.x].val[16/4+2];
  r10.w = t0[r1.x].val[16/4+3];
  r8.y = r10.x;
  r11.x = t0[r1.x].val[32/4];
  r11.y = t0[r1.x].val[32/4+1];
  r11.z = t0[r1.x].val[32/4+2];
  r11.w = t0[r1.x].val[32/4+3];
  r8.z = r11.x;
  r8.x = dot(r7.xyzw, r8.xyzw);
  r12.w = r3.y;
  r12.x = r9.y;
  r12.y = r10.y;
  r12.z = r11.y;
  r8.y = dot(r7.xyzw, r12.xyzw);
  r3.x = r9.z;
  r3.y = r10.z;
  r3.z = r11.z;
  r8.z = dot(r7.xyzw, r3.xyzw);
  r3.w = 1;
  r3.x = r9.w;
  r4.xyzw = r9.xyzw * r0.xxxx + r4.xyzw;
  r3.y = r10.w;
  r5.xyzw = r10.xyzw * r0.xxxx + r5.xyzw;
  r3.z = r11.w;
  r6.xyzw = r11.xyzw * r0.xxxx + r6.xyzw;
  r8.w = dot(r7.xyzw, r3.xyzw);
  r2.xyzw = r8.xyzw * r0.xxxx + r2.xyzw;
  r3.x = t0[r1.z].val[48/4];
  r3.y = t0[r1.z].val[48/4+1];
  r3.w = t0[r1.z].val[48/4+2];
  r8.w = r3.x;
  r9.x = t0[r1.z].val[0/4];
  r9.y = t0[r1.z].val[0/4+1];
  r9.z = t0[r1.z].val[0/4+2];
  r9.w = t0[r1.z].val[0/4+3];
  r8.x = r9.x;
  r10.x = t0[r1.z].val[16/4];
  r10.y = t0[r1.z].val[16/4+1];
  r10.z = t0[r1.z].val[16/4+2];
  r10.w = t0[r1.z].val[16/4+3];
  r8.y = r10.x;
  r11.x = t0[r1.z].val[32/4];
  r11.y = t0[r1.z].val[32/4+1];
  r11.z = t0[r1.z].val[32/4+2];
  r11.w = t0[r1.z].val[32/4+3];
  r8.z = r11.x;
  r8.x = dot(r7.xyzw, r8.xyzw);
  r12.w = r3.y;
  r12.x = r9.y;
  r12.y = r10.y;
  r12.z = r11.y;
  r8.y = dot(r7.xyzw, r12.xyzw);
  r3.x = r9.z;
  r3.y = r10.z;
  r3.z = r11.z;
  r8.z = dot(r7.xyzw, r3.xyzw);
  r3.w = 1;
  r3.x = r9.w;
  r4.xyzw = r9.xyzw * r0.zzzz + r4.xyzw;
  r3.y = r10.w;
  r5.xyzw = r10.xyzw * r0.zzzz + r5.xyzw;
  r3.z = r11.w;
  r6.xyzw = r11.xyzw * r0.zzzz + r6.xyzw;
  r8.w = dot(r7.xyzw, r3.xyzw);
  r2.xyzw = r8.xyzw * r0.zzzz + r2.xyzw;
  r3.x = t0[r1.w].val[48/4];
  r3.y = t0[r1.w].val[48/4+1];
  r3.w = t0[r1.w].val[48/4+2];
  r8.w = r3.x;
  r9.x = t0[r1.w].val[0/4+3];
  r9.y = t0[r1.w].val[0/4];
  r9.z = t0[r1.w].val[0/4+1];
  r9.w = t0[r1.w].val[0/4+2];
  r8.x = r9.y;
  r10.x = t0[r1.w].val[16/4];
  r10.y = t0[r1.w].val[16/4+1];
  r10.z = t0[r1.w].val[16/4+2];
  r10.w = t0[r1.w].val[16/4+3];
  r1.x = t0[r1.w].val[32/4];
  r1.y = t0[r1.w].val[32/4+1];
  r1.z = t0[r1.w].val[32/4+2];
  r1.w = t0[r1.w].val[32/4+3];
  r8.y = r10.x;
  r8.z = r1.x;
  r8.x = dot(r7.xyzw, r8.xyzw);
  r11.w = r3.y;
  r11.x = r9.z;
  r11.y = r10.y;
  r11.z = r1.y;
  r8.y = dot(r7.xyzw, r11.xyzw);
  r3.x = r9.w;
  r3.y = r10.z;
  r3.z = r1.z;
  r8.z = dot(r7.xyzw, r3.xyzw);
  r3.xyzw = r9.yzwx * r0.wwww + r4.xyzw;
  r9.y = r10.w;
  r4.xyzw = r10.xyzw * r0.wwww + r5.xyzw;
  r9.z = r1.w;
  r1.xyzw = r1.xyzw * r0.wwww + r6.xyzw;
  r9.w = 1;
  r8.w = dot(r7.xyzw, r9.xyzw);
  r0.xyzw = r8.xyzw * r0.wwww + r2.xyzw;
  o0.w = dot(r0.xyzw, cb2[0].xyzw);
  o0.x = dot(r7.xyzw, cb3[7].xyzw);
  o0.y = dot(r7.xyzw, cb3[8].xyzw);
  o0.z = dot(r7.xyzw, cb3[9].xyzw);
  o1.xyzw = cb2[6].xyzw;
  o2.xyzw = v3.xyxy;
  o3.w = dot(r0.xyzw, cb2[1].xyzw);
  r2.x = dot(r3.xyzw, cb2[0].xyzw);
  r2.y = dot(r4.xyzw, cb2[0].xyzw);
  r2.z = dot(r1.xyzw, cb2[0].xyzw);
  r5.xyz = v4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r6.xyzw = v5.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r7.xyz = r6.yzx * r5.zxy;
  r7.xyz = r5.yzx * r6.zxy + -r7.xyz;
  r7.xyz = r7.xyz * r6.www;
  r2.w = dot(r7.xyz, r7.xyz);
  r2.w = rsqrt(r2.w);
  r7.xyz = r7.xyz * r2.www;
  r8.x = dot(r7.xyz, r2.xyz);
  r9.x = dot(r3.xyzw, cb2[1].xyzw);
  r3.x = dot(r3.xyzw, cb2[2].xyzw);
  r9.y = dot(r4.xyzw, cb2[1].xyzw);
  r3.y = dot(r4.xyzw, cb2[2].xyzw);
  r9.z = dot(r1.xyzw, cb2[1].xyzw);
  r3.z = dot(r1.xyzw, cb2[2].xyzw);
  r8.y = dot(r7.xyz, r9.xyz);
  r8.z = dot(r7.xyz, r3.xyz);
  r1.x = dot(r8.xyz, r8.xyz);
  r1.x = rsqrt(r1.x);
  o3.xyz = r8.xyz * r1.xxx;
  r1.x = dot(r5.xyz, r2.xyz);
  r2.x = dot(r6.xyz, r2.xyz);
  r1.y = dot(r5.xyz, r9.xyz);
  r2.y = dot(r6.xyz, r9.xyz);
  r2.z = dot(r6.xyz, r3.xyz);
  r1.z = dot(r5.xyz, r3.xyz);
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  o4.xyz = r1.xyz * r1.www;
  o4.w = dot(r0.xyzw, cb2[2].xyzw);
  r1.x = dot(r2.xyz, r2.xyz);
  r1.x = rsqrt(r1.x);
  o5.xyz = r2.xyz * r1.xxx;
  r1.xyzw = cb2[1].xyzw * cb1[0].yyyy;
  r1.xyzw = cb2[0].xyzw * cb1[0].xxxx + r1.xyzw;
  r1.xyzw = cb2[2].xyzw * cb1[0].zzzz + r1.xyzw;
  r1.xyzw = cb1[0].wwww * float4(0,0,0,1) + r1.xyzw;
  o6.x = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb2[1].xyzw * cb1[1].yyyy;
  r1.xyzw = cb2[0].xyzw * cb1[1].xxxx + r1.xyzw;
  r1.xyzw = cb2[2].xyzw * cb1[1].zzzz + r1.xyzw;
  r1.xyzw = cb1[1].wwww * float4(0,0,0,1) + r1.xyzw;
  o6.y = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb2[1].xyzw * cb1[2].yyyy;
  r1.xyzw = cb2[0].xyzw * cb1[2].xxxx + r1.xyzw;
  r1.xyzw = cb2[2].xyzw * cb1[2].zzzz + r1.xyzw;
  r1.xyzw = cb1[2].wwww * float4(0,0,0,1) + r1.xyzw;
  o6.z = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb2[1].xyzw * cb1[3].yyyy;
  r1.xyzw = cb2[0].xyzw * cb1[3].xxxx + r1.xyzw;
  r1.xyzw = cb2[2].xyzw * cb1[3].zzzz + r1.xyzw;
  r1.xyzw = cb1[3].wwww * float4(0,0,0,1) + r1.xyzw;
  o6.w = dot(r0.xyzw, r1.xyzw);
  previous_clip = PreviousObjectClip(v0 * cb2[4].xyz + cb2[5].xyz, v1, v2, cb2[7], 1.f, motion_instance, motion_history);
  return;
}