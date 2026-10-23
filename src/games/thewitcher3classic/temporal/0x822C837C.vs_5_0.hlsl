// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:06:33 2026
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
  float4 cb1[7];
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = cb2[1].xyzw * cb1[6].yyyy;
  r0.xyzw = cb2[0].xyzw * cb1[6].xxxx + r0.xyzw;
  r0.xyzw = cb2[2].xyzw * cb1[6].zzzz + r0.xyzw;
  r0.xyzw = cb1[6].wwww * float4(0,0,0,1) + r0.xyzw;
  r1.x = v2.x + v2.y;
  r1.x = v2.z + r1.x;
  r1.x = v2.w + r1.x;
  r1.xyzw = v2.xyzw / r1.xxxx;
  r2.xyzw = (uint4)v1.xyzw;
  r2.xyzw = r2.xyzw * cb2[7].yyyy + cb2[7].xxxx;
  r2.xyzw = (uint4)r2.xyzw;
  r3.x = t0[r2.y].val[48/4];
  r3.y = t0[r2.y].val[48/4+1];
  r3.w = t0[r2.y].val[48/4+2];
  r4.w = r3.x;
  r5.x = t0[r2.y].val[0/4];
  r5.y = t0[r2.y].val[0/4+1];
  r5.z = t0[r2.y].val[0/4+2];
  r5.w = t0[r2.y].val[0/4+3];
  r4.x = r5.x;
  r6.x = t0[r2.y].val[16/4];
  r6.y = t0[r2.y].val[16/4+1];
  r6.z = t0[r2.y].val[16/4+2];
  r6.w = t0[r2.y].val[16/4+3];
  r4.y = r6.x;
  r7.x = t0[r2.y].val[32/4];
  r7.y = t0[r2.y].val[32/4+1];
  r7.z = t0[r2.y].val[32/4+2];
  r7.w = t0[r2.y].val[32/4+3];
  r4.z = r7.x;
  r8.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r8.w = 1;
  r4.x = dot(r8.xyzw, r4.xyzw);
  r9.w = r3.y;
  r9.x = r5.y;
  r9.y = r6.y;
  r9.z = r7.y;
  r4.y = dot(r8.xyzw, r9.xyzw);
  r3.x = r5.z;
  r3.y = r6.z;
  r3.z = r7.z;
  r4.z = dot(r8.xyzw, r3.xyzw);
  r3.w = 1;
  r3.x = r5.w;
  r5.xyzw = r5.xyzw * r1.yyyy;
  r3.y = r6.w;
  r6.xyzw = r6.xyzw * r1.yyyy;
  r3.z = r7.w;
  r7.xyzw = r7.xyzw * r1.yyyy;
  r4.w = dot(r8.xyzw, r3.xyzw);
  r3.xyzw = r4.xyzw * r1.yyyy;
  r4.x = t0[r2.x].val[48/4];
  r4.y = t0[r2.x].val[48/4+1];
  r4.w = t0[r2.x].val[48/4+2];
  r9.w = r4.x;
  r10.x = t0[r2.x].val[0/4];
  r10.y = t0[r2.x].val[0/4+1];
  r10.z = t0[r2.x].val[0/4+2];
  r10.w = t0[r2.x].val[0/4+3];
  r9.x = r10.x;
  r11.x = t0[r2.x].val[16/4];
  r11.y = t0[r2.x].val[16/4+1];
  r11.z = t0[r2.x].val[16/4+2];
  r11.w = t0[r2.x].val[16/4+3];
  r9.y = r11.x;
  r12.x = t0[r2.x].val[32/4];
  r12.y = t0[r2.x].val[32/4+1];
  r12.z = t0[r2.x].val[32/4+2];
  r12.w = t0[r2.x].val[32/4+3];
  r9.z = r12.x;
  r9.x = dot(r8.xyzw, r9.xyzw);
  r13.w = r4.y;
  r13.x = r10.y;
  r13.y = r11.y;
  r13.z = r12.y;
  r9.y = dot(r8.xyzw, r13.xyzw);
  r4.x = r10.z;
  r4.y = r11.z;
  r4.z = r12.z;
  r9.z = dot(r8.xyzw, r4.xyzw);
  r4.w = 1;
  r4.x = r10.w;
  r5.xyzw = r10.xyzw * r1.xxxx + r5.xyzw;
  r4.y = r11.w;
  r6.xyzw = r11.xyzw * r1.xxxx + r6.xyzw;
  r4.z = r12.w;
  r7.xyzw = r12.xyzw * r1.xxxx + r7.xyzw;
  r9.w = dot(r8.xyzw, r4.xyzw);
  r3.xyzw = r9.xyzw * r1.xxxx + r3.xyzw;
  r4.x = t0[r2.z].val[48/4];
  r4.y = t0[r2.z].val[48/4+1];
  r4.w = t0[r2.z].val[48/4+2];
  r9.w = r4.x;
  r10.x = t0[r2.z].val[0/4];
  r10.y = t0[r2.z].val[0/4+1];
  r10.z = t0[r2.z].val[0/4+2];
  r10.w = t0[r2.z].val[0/4+3];
  r9.x = r10.x;
  r11.x = t0[r2.z].val[16/4];
  r11.y = t0[r2.z].val[16/4+1];
  r11.z = t0[r2.z].val[16/4+2];
  r11.w = t0[r2.z].val[16/4+3];
  r9.y = r11.x;
  r12.x = t0[r2.z].val[32/4];
  r12.y = t0[r2.z].val[32/4+1];
  r12.z = t0[r2.z].val[32/4+2];
  r12.w = t0[r2.z].val[32/4+3];
  r9.z = r12.x;
  r9.x = dot(r8.xyzw, r9.xyzw);
  r13.w = r4.y;
  r13.x = r10.y;
  r13.y = r11.y;
  r13.z = r12.y;
  r9.y = dot(r8.xyzw, r13.xyzw);
  r4.x = r10.z;
  r4.y = r11.z;
  r4.z = r12.z;
  r9.z = dot(r8.xyzw, r4.xyzw);
  r4.w = 1;
  r4.x = r10.w;
  r5.xyzw = r10.xyzw * r1.zzzz + r5.xyzw;
  r4.y = r11.w;
  r6.xyzw = r11.xyzw * r1.zzzz + r6.xyzw;
  r4.z = r12.w;
  r7.xyzw = r12.xyzw * r1.zzzz + r7.xyzw;
  r9.w = dot(r8.xyzw, r4.xyzw);
  r3.xyzw = r9.xyzw * r1.zzzz + r3.xyzw;
  r4.x = t0[r2.w].val[48/4];
  r4.y = t0[r2.w].val[48/4+1];
  r4.w = t0[r2.w].val[48/4+2];
  r9.w = r4.x;
  r10.x = t0[r2.w].val[0/4+3];
  r10.y = t0[r2.w].val[0/4];
  r10.z = t0[r2.w].val[0/4+1];
  r10.w = t0[r2.w].val[0/4+2];
  r9.x = r10.y;
  r11.x = t0[r2.w].val[16/4];
  r11.y = t0[r2.w].val[16/4+1];
  r11.z = t0[r2.w].val[16/4+2];
  r11.w = t0[r2.w].val[16/4+3];
  r2.x = t0[r2.w].val[32/4];
  r2.y = t0[r2.w].val[32/4+1];
  r2.z = t0[r2.w].val[32/4+2];
  r2.w = t0[r2.w].val[32/4+3];
  r9.y = r11.x;
  r9.z = r2.x;
  r9.x = dot(r8.xyzw, r9.xyzw);
  r12.w = r4.y;
  r12.x = r10.z;
  r12.y = r11.y;
  r12.z = r2.y;
  r9.y = dot(r8.xyzw, r12.xyzw);
  r4.x = r10.w;
  r4.y = r11.z;
  r4.z = r2.z;
  r9.z = dot(r8.xyzw, r4.xyzw);
  r4.xyzw = r10.yzwx * r1.wwww + r5.xyzw;
  r10.y = r11.w;
  r5.xyzw = r11.xyzw * r1.wwww + r6.xyzw;
  r10.z = r2.w;
  r2.xyzw = r2.xyzw * r1.wwww + r7.xyzw;
  r10.w = 1;
  r9.w = dot(r8.xyzw, r10.xyzw);
  r1.xyzw = r9.xyzw * r1.wwww + r3.xyzw;
  o0.w = dot(r1.xyzw, r0.xyzw);
  o0.x = dot(r8.xyzw, cb3[7].xyzw);
  o0.y = dot(r8.xyzw, cb3[8].xyzw);
  o0.z = dot(r8.xyzw, cb3[9].xyzw);
  o1.xyzw = cb2[6].xyzw;
  o2.xyzw = v3.xyxy;
  o3.xyzw = float4(1,1,1,1);
  r0.x = dot(r4.xyzw, cb2[0].xyzw);
  r0.y = dot(r5.xyzw, cb2[0].xyzw);
  r0.z = dot(r2.xyzw, cb2[0].xyzw);
  r3.xyz = v4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = dot(r3.xyz, r0.xyz);
  r6.x = dot(r4.xyzw, cb2[1].xyzw);
  r4.x = dot(r4.xyzw, cb2[2].xyzw);
  r6.y = dot(r5.xyzw, cb2[1].xyzw);
  r4.y = dot(r5.xyzw, cb2[2].xyzw);
  r6.z = dot(r2.xyzw, cb2[1].xyzw);
  r4.z = dot(r2.xyzw, cb2[2].xyzw);
  r0.z = dot(r3.xyz, r4.xyz);
  r0.y = dot(r3.xyz, r6.xyz);
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o4.xyz = r0.xyz * r0.www;
  o5.x = dot(r1.xyzw, cb2[0].xyzw);
  o5.y = dot(r1.xyzw, cb2[1].xyzw);
  o5.z = dot(r1.xyzw, cb2[2].xyzw);
  r0.xyzw = cb2[1].xyzw * cb1[0].yyyy;
  r0.xyzw = cb2[0].xyzw * cb1[0].xxxx + r0.xyzw;
  r0.xyzw = cb2[2].xyzw * cb1[0].zzzz + r0.xyzw;
  r0.xyzw = cb1[0].wwww * float4(0,0,0,1) + r0.xyzw;
  o6.x = dot(r1.xyzw, r0.xyzw);
  r0.xyzw = cb2[1].xyzw * cb1[1].yyyy;
  r0.xyzw = cb2[0].xyzw * cb1[1].xxxx + r0.xyzw;
  r0.xyzw = cb2[2].xyzw * cb1[1].zzzz + r0.xyzw;
  r0.xyzw = cb1[1].wwww * float4(0,0,0,1) + r0.xyzw;
  o6.y = dot(r1.xyzw, r0.xyzw);
  r0.xyzw = cb2[1].xyzw * cb1[2].yyyy;
  r0.xyzw = cb2[0].xyzw * cb1[2].xxxx + r0.xyzw;
  r0.xyzw = cb2[2].xyzw * cb1[2].zzzz + r0.xyzw;
  r0.xyzw = cb1[2].wwww * float4(0,0,0,1) + r0.xyzw;
  o6.z = dot(r1.xyzw, r0.xyzw);
  r0.xyzw = cb2[1].xyzw * cb1[3].yyyy;
  r0.xyzw = cb2[0].xyzw * cb1[3].xxxx + r0.xyzw;
  r0.xyzw = cb2[2].xyzw * cb1[3].zzzz + r0.xyzw;
  r0.xyzw = cb1[3].wwww * float4(0,0,0,1) + r0.xyzw;
  o6.w = dot(r1.xyzw, r0.xyzw);
  previous_clip = PreviousObjectClip(v0 * cb2[4].xyz + cb2[5].xyz, v1, v2, cb2[7], 1.f, motion_instance, motion_history);
  return;
}