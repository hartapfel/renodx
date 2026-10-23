// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:06:32 2026
struct t0_t {
  float val[16];
};
StructuredBuffer<t0_t> t0 : register(t0);

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
  float4 v6 : COLOR0,
  float2 v7 : TEXCOORD1,
  float4 v8 : INSTANCE_TRANSFORM0,
  float4 v9 : INSTANCE_TRANSFORM1,
  float4 v10 : INSTANCE_TRANSFORM2,
  float4 v11 : INSTANCE_LOD_PARAMS0,
  float4 v12 : INSTANCE_SKINNING_DATA0,
  uint motion_instance : SV_InstanceID,
  out float4 o0 : TEXCOORD0,
  out float3 o1 : TEXCOORD1,
  out float4 o2 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v3.xy;
  r0.x = v2.x + v2.y;
  r0.x = v2.z + r0.x;
  r0.x = v2.w + r0.x;
  r0.xyzw = v2.xyzw / r0.xxxx;
  r1.xyzw = (uint4)v1.xyzw;
  r1.xyzw = r1.xyzw * v12.yyyy + v12.xxxx;
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
  r6.z = t0[r1.y].val[32/4+3];
  r6.w = t0[r1.y].val[32/4+2];
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
  r6.x = r4.w;
  r2.y = r5.z;
  r6.y = r5.w;
  r2.z = r6.w;
  r3.z = dot(r7.xyzw, r2.xyzw);
  r6.w = 1;
  r3.w = dot(r7.xyzw, r6.xyzw);
  r2.xyzw = r3.xyzw * r0.yyyy;
  r3.x = t0[r1.x].val[48/4];
  r3.y = t0[r1.x].val[48/4+1];
  r3.w = t0[r1.x].val[48/4+2];
  r4.w = r3.x;
  r5.x = t0[r1.x].val[0/4];
  r5.y = t0[r1.x].val[0/4+1];
  r5.z = t0[r1.x].val[0/4+2];
  r5.w = t0[r1.x].val[0/4+3];
  r4.x = r5.x;
  r6.x = t0[r1.x].val[16/4];
  r6.y = t0[r1.x].val[16/4+1];
  r6.z = t0[r1.x].val[16/4+2];
  r6.w = t0[r1.x].val[16/4+3];
  r4.y = r6.x;
  r8.x = t0[r1.x].val[32/4];
  r8.y = t0[r1.x].val[32/4+1];
  r8.z = t0[r1.x].val[32/4+3];
  r8.w = t0[r1.x].val[32/4+2];
  r4.z = r8.x;
  r4.x = dot(r7.xyzw, r4.xyzw);
  r9.w = r3.y;
  r9.x = r5.y;
  r9.y = r6.y;
  r9.z = r8.y;
  r4.y = dot(r7.xyzw, r9.xyzw);
  r3.x = r5.z;
  r8.x = r5.w;
  r3.y = r6.z;
  r8.y = r6.w;
  r3.z = r8.w;
  r4.z = dot(r7.xyzw, r3.xyzw);
  r8.w = 1;
  r4.w = dot(r7.xyzw, r8.xyzw);
  r2.xyzw = r4.xyzw * r0.xxxx + r2.xyzw;
  r3.x = t0[r1.z].val[48/4];
  r3.y = t0[r1.z].val[48/4+1];
  r3.w = t0[r1.z].val[48/4+2];
  r4.w = r3.x;
  r5.x = t0[r1.z].val[0/4];
  r5.y = t0[r1.z].val[0/4+1];
  r5.z = t0[r1.z].val[0/4+2];
  r5.w = t0[r1.z].val[0/4+3];
  r4.x = r5.x;
  r6.x = t0[r1.z].val[16/4];
  r6.y = t0[r1.z].val[16/4+1];
  r6.z = t0[r1.z].val[16/4+2];
  r6.w = t0[r1.z].val[16/4+3];
  r4.y = r6.x;
  r8.x = t0[r1.z].val[32/4];
  r8.y = t0[r1.z].val[32/4+1];
  r8.z = t0[r1.z].val[32/4+3];
  r8.w = t0[r1.z].val[32/4+2];
  r4.z = r8.x;
  r4.x = dot(r7.xyzw, r4.xyzw);
  r9.w = r3.y;
  r9.x = r5.y;
  r9.y = r6.y;
  r9.z = r8.y;
  r4.y = dot(r7.xyzw, r9.xyzw);
  r3.x = r5.z;
  r8.x = r5.w;
  r3.y = r6.z;
  r8.y = r6.w;
  r3.z = r8.w;
  r4.z = dot(r7.xyzw, r3.xyzw);
  r8.w = 1;
  r4.w = dot(r7.xyzw, r8.xyzw);
  r2.xyzw = r4.xyzw * r0.zzzz + r2.xyzw;
  r3.x = t0[r1.w].val[48/4];
  r3.y = t0[r1.w].val[48/4+1];
  r3.w = t0[r1.w].val[48/4+2];
  r4.w = r3.x;
  r5.x = t0[r1.w].val[0/4];
  r5.y = t0[r1.w].val[0/4+1];
  r5.z = t0[r1.w].val[0/4+2];
  r5.w = t0[r1.w].val[0/4+3];
  r4.x = r5.x;
  r6.x = t0[r1.w].val[16/4];
  r6.y = t0[r1.w].val[16/4+1];
  r6.z = t0[r1.w].val[16/4+2];
  r6.w = t0[r1.w].val[16/4+3];
  r1.x = t0[r1.w].val[32/4];
  r1.y = t0[r1.w].val[32/4+1];
  r1.z = t0[r1.w].val[32/4+3];
  r1.w = t0[r1.w].val[32/4+2];
  r4.y = r6.x;
  r4.z = r1.x;
  r4.x = dot(r7.xyzw, r4.xyzw);
  r8.w = r3.y;
  r8.x = r5.y;
  r8.y = r6.y;
  r8.z = r1.y;
  r4.y = dot(r7.xyzw, r8.xyzw);
  r3.x = r5.z;
  r1.x = r5.w;
  r3.y = r6.z;
  r1.y = r6.w;
  r3.z = r1.w;
  r4.z = dot(r7.xyzw, r3.xyzw);
  r1.w = 1;
  r4.w = dot(r7.xyzw, r1.xyzw);
  r0.xyzw = r4.xyzw * r0.wwww + r2.xyzw;
  o1.x = dot(r0.xyzw, v8.xyzw);
  o1.y = dot(r0.xyzw, v9.xyzw);
  o1.z = dot(r0.xyzw, v10.xyzw);
  r1.xyzw = cb1[0].yyyy * v9.xyzw;
  r1.xyzw = v8.xyzw * cb1[0].xxxx + r1.xyzw;
  r1.xyzw = v10.xyzw * cb1[0].zzzz + r1.xyzw;
  r1.xyzw = cb1[0].wwww * float4(0,0,0,1) + r1.xyzw;
  o2.x = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[1].yyyy * v9.xyzw;
  r1.xyzw = v8.xyzw * cb1[1].xxxx + r1.xyzw;
  r1.xyzw = v10.xyzw * cb1[1].zzzz + r1.xyzw;
  r1.xyzw = cb1[1].wwww * float4(0,0,0,1) + r1.xyzw;
  o2.y = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[2].yyyy * v9.xyzw;
  r1.xyzw = v8.xyzw * cb1[2].xxxx + r1.xyzw;
  r1.xyzw = v10.xyzw * cb1[2].zzzz + r1.xyzw;
  r1.xyzw = cb1[2].wwww * float4(0,0,0,1) + r1.xyzw;
  o2.z = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[3].yyyy * v9.xyzw;
  r1.xyzw = v8.xyzw * cb1[3].xxxx + r1.xyzw;
  r1.xyzw = v10.xyzw * cb1[3].zzzz + r1.xyzw;
  r1.xyzw = cb1[3].wwww * float4(0,0,0,1) + r1.xyzw;
  o2.w = dot(r0.xyzw, r1.xyzw);
  previous_clip = PreviousObjectClip(v0 * cb2[4].xyz + cb2[5].xyz, v1, v2, v12, 1.f, motion_instance, motion_history);
  return;
}