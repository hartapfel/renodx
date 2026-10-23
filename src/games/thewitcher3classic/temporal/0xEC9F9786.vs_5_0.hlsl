// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:06:35 2026
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
  float4 cb2[6];
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
  float4 v6 : INSTANCE_TRANSFORM0,
  float4 v7 : INSTANCE_TRANSFORM1,
  float4 v8 : INSTANCE_TRANSFORM2,
  float4 v9 : INSTANCE_LOD_PARAMS0,
  float4 v10 : INSTANCE_SKINNING_DATA0,
  uint motion_instance : SV_InstanceID,
  out float4 o0 : TEXCOORD0,
  out float4 o1 : TEXCOORD1,
  out float4 o2 : TEXCOORD2,
  out float3 o3 : TEXCOORD3,
  out float4 o4 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r0.w = 1;
  o0.x = dot(r0.xyzw, cb3[7].xyzw);
  o0.y = dot(r0.xyzw, cb3[8].xyzw);
  o0.z = dot(r0.xyzw, cb3[9].xyzw);
  o1.xyzw = v9.xyzw;
  o2.xyzw = v3.xyxy;
  r1.x = v2.x + v2.y;
  r1.x = v2.z + r1.x;
  r1.x = v2.w + r1.x;
  r1.xyzw = v2.xyzw / r1.xxxx;
  r2.xyzw = (uint4)v1.xyzw;
  r2.xyzw = r2.xyzw * v10.yyyy + v10.xxxx;
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
  r7.z = t0[r2.y].val[32/4+3];
  r7.w = t0[r2.y].val[32/4+2];
  r4.z = r7.x;
  r4.x = dot(r0.xyzw, r4.xyzw);
  r8.w = r3.y;
  r8.x = r5.y;
  r8.y = r6.y;
  r8.z = r7.y;
  r4.y = dot(r0.xyzw, r8.xyzw);
  r3.x = r5.z;
  r7.x = r5.w;
  r3.y = r6.z;
  r7.y = r6.w;
  r3.z = r7.w;
  r4.z = dot(r0.xyzw, r3.xyzw);
  r7.w = 1;
  r4.w = dot(r0.xyzw, r7.xyzw);
  r3.xyzw = r4.xyzw * r1.yyyy;
  r4.x = t0[r2.x].val[48/4];
  r4.y = t0[r2.x].val[48/4+1];
  r4.w = t0[r2.x].val[48/4+2];
  r5.w = r4.x;
  r6.x = t0[r2.x].val[0/4];
  r6.y = t0[r2.x].val[0/4+1];
  r6.z = t0[r2.x].val[0/4+2];
  r6.w = t0[r2.x].val[0/4+3];
  r5.x = r6.x;
  r7.x = t0[r2.x].val[16/4];
  r7.y = t0[r2.x].val[16/4+1];
  r7.z = t0[r2.x].val[16/4+2];
  r7.w = t0[r2.x].val[16/4+3];
  r5.y = r7.x;
  r8.x = t0[r2.x].val[32/4];
  r8.y = t0[r2.x].val[32/4+1];
  r8.z = t0[r2.x].val[32/4+3];
  r8.w = t0[r2.x].val[32/4+2];
  r5.z = r8.x;
  r5.x = dot(r0.xyzw, r5.xyzw);
  r9.w = r4.y;
  r9.x = r6.y;
  r9.y = r7.y;
  r9.z = r8.y;
  r5.y = dot(r0.xyzw, r9.xyzw);
  r4.x = r6.z;
  r8.x = r6.w;
  r4.y = r7.z;
  r8.y = r7.w;
  r4.z = r8.w;
  r5.z = dot(r0.xyzw, r4.xyzw);
  r8.w = 1;
  r5.w = dot(r0.xyzw, r8.xyzw);
  r3.xyzw = r5.xyzw * r1.xxxx + r3.xyzw;
  r4.x = t0[r2.z].val[48/4];
  r4.y = t0[r2.z].val[48/4+1];
  r4.w = t0[r2.z].val[48/4+2];
  r5.w = r4.x;
  r6.x = t0[r2.z].val[0/4];
  r6.y = t0[r2.z].val[0/4+1];
  r6.z = t0[r2.z].val[0/4+2];
  r6.w = t0[r2.z].val[0/4+3];
  r5.x = r6.x;
  r7.x = t0[r2.z].val[16/4];
  r7.y = t0[r2.z].val[16/4+1];
  r7.z = t0[r2.z].val[16/4+2];
  r7.w = t0[r2.z].val[16/4+3];
  r5.y = r7.x;
  r8.x = t0[r2.z].val[32/4];
  r8.y = t0[r2.z].val[32/4+1];
  r8.z = t0[r2.z].val[32/4+3];
  r8.w = t0[r2.z].val[32/4+2];
  r5.z = r8.x;
  r5.x = dot(r0.xyzw, r5.xyzw);
  r9.w = r4.y;
  r9.x = r6.y;
  r9.y = r7.y;
  r9.z = r8.y;
  r5.y = dot(r0.xyzw, r9.xyzw);
  r4.x = r6.z;
  r8.x = r6.w;
  r4.y = r7.z;
  r8.y = r7.w;
  r4.z = r8.w;
  r5.z = dot(r0.xyzw, r4.xyzw);
  r8.w = 1;
  r5.w = dot(r0.xyzw, r8.xyzw);
  r3.xyzw = r5.xyzw * r1.zzzz + r3.xyzw;
  r4.x = t0[r2.w].val[48/4];
  r4.y = t0[r2.w].val[48/4+1];
  r4.w = t0[r2.w].val[48/4+2];
  r5.w = r4.x;
  r6.x = t0[r2.w].val[0/4];
  r6.y = t0[r2.w].val[0/4+1];
  r6.z = t0[r2.w].val[0/4+2];
  r6.w = t0[r2.w].val[0/4+3];
  r5.x = r6.x;
  r7.x = t0[r2.w].val[16/4];
  r7.y = t0[r2.w].val[16/4+1];
  r7.z = t0[r2.w].val[16/4+2];
  r7.w = t0[r2.w].val[16/4+3];
  r2.x = t0[r2.w].val[32/4];
  r2.y = t0[r2.w].val[32/4+1];
  r2.z = t0[r2.w].val[32/4+3];
  r2.w = t0[r2.w].val[32/4+2];
  r5.y = r7.x;
  r5.z = r2.x;
  r5.x = dot(r0.xyzw, r5.xyzw);
  r8.w = r4.y;
  r8.x = r6.y;
  r8.y = r7.y;
  r8.z = r2.y;
  r5.y = dot(r0.xyzw, r8.xyzw);
  r4.x = r6.z;
  r2.x = r6.w;
  r4.y = r7.z;
  r2.y = r7.w;
  r4.z = r2.w;
  r5.z = dot(r0.xyzw, r4.xyzw);
  r2.w = 1;
  r5.w = dot(r0.xyzw, r2.xyzw);
  r0.xyzw = r5.xyzw * r1.wwww + r3.xyzw;
  o3.x = dot(r0.xyzw, v6.xyzw);
  o3.y = dot(r0.xyzw, v7.xyzw);
  o3.z = dot(r0.xyzw, v8.xyzw);
  r1.xyzw = cb1[0].yyyy * v7.xyzw;
  r1.xyzw = v6.xyzw * cb1[0].xxxx + r1.xyzw;
  r1.xyzw = v8.xyzw * cb1[0].zzzz + r1.xyzw;
  r1.xyzw = cb1[0].wwww * float4(0,0,0,1) + r1.xyzw;
  o4.x = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[1].yyyy * v7.xyzw;
  r1.xyzw = v6.xyzw * cb1[1].xxxx + r1.xyzw;
  r1.xyzw = v8.xyzw * cb1[1].zzzz + r1.xyzw;
  r1.xyzw = cb1[1].wwww * float4(0,0,0,1) + r1.xyzw;
  o4.y = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[2].yyyy * v7.xyzw;
  r1.xyzw = v6.xyzw * cb1[2].xxxx + r1.xyzw;
  r1.xyzw = v8.xyzw * cb1[2].zzzz + r1.xyzw;
  r1.xyzw = cb1[2].wwww * float4(0,0,0,1) + r1.xyzw;
  o4.z = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[3].yyyy * v7.xyzw;
  r1.xyzw = v6.xyzw * cb1[3].xxxx + r1.xyzw;
  r1.xyzw = v8.xyzw * cb1[3].zzzz + r1.xyzw;
  r1.xyzw = cb1[3].wwww * float4(0,0,0,1) + r1.xyzw;
  o4.w = dot(r0.xyzw, r1.xyzw);
  previous_clip = PreviousObjectClip(v0 * cb2[4].xyz + cb2[5].xyz, v1, v2, v10, 1.f, motion_instance, motion_history);
  return;
}