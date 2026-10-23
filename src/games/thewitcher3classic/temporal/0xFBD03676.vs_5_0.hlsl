// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:16:00 2026
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
  out float4 o3 : TEXCOORD3,
  out float3 o4 : TEXCOORD4,
  out float4 o5 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r0.w = 1;
  o0.x = dot(r0.xyzw, cb3[7].xyzw);
  o0.y = dot(r0.xyzw, cb3[8].xyzw);
  o0.z = dot(r0.xyzw, cb3[9].xyzw);
  o1.xyzw = v9.xyzw;
  o2.xyzw = v3.xyxy;
  r1.xyz = v4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.w = v2.x + v2.y;
  r1.w = v2.z + r1.w;
  r1.w = v2.w + r1.w;
  r2.xyzw = v2.xyzw / r1.wwww;
  r3.xyzw = (uint4)v1.xyzw;
  r3.xyzw = r3.xyzw * v10.yyyy + v10.xxxx;
  r3.xyzw = (uint4)r3.xyzw;
  r4.x = t0[r3.y].val[0/4];
  r4.y = t0[r3.y].val[0/4+1];
  r4.z = t0[r3.y].val[0/4+2];
  r4.w = t0[r3.y].val[0/4+3];
  r5.xyzw = r4.xyzw * r2.yyyy;
  r6.x = t0[r3.x].val[0/4];
  r6.y = t0[r3.x].val[0/4+1];
  r6.z = t0[r3.x].val[0/4+2];
  r6.w = t0[r3.x].val[0/4+3];
  r5.xyzw = r6.xyzw * r2.xxxx + r5.xyzw;
  r7.x = t0[r3.z].val[0/4];
  r7.y = t0[r3.z].val[0/4+1];
  r7.z = t0[r3.z].val[0/4+2];
  r7.w = t0[r3.z].val[0/4+3];
  r5.xyzw = r7.xyzw * r2.zzzz + r5.xyzw;
  r8.x = t0[r3.w].val[0/4];
  r8.y = t0[r3.w].val[0/4+1];
  r8.z = t0[r3.w].val[0/4+2];
  r8.w = t0[r3.w].val[0/4+3];
  r5.xyzw = r8.xyzw * r2.wwww + r5.xyzw;
  r9.x = dot(r5.xyzw, v6.xyzw);
  r10.x = t0[r3.y].val[16/4];
  r10.y = t0[r3.y].val[16/4+1];
  r10.z = t0[r3.y].val[16/4+2];
  r10.w = t0[r3.y].val[16/4+3];
  r11.xyzw = r10.xyzw * r2.yyyy;
  r12.x = t0[r3.x].val[16/4];
  r12.y = t0[r3.x].val[16/4+1];
  r12.z = t0[r3.x].val[16/4+2];
  r12.w = t0[r3.x].val[16/4+3];
  r11.xyzw = r12.xyzw * r2.xxxx + r11.xyzw;
  r13.x = t0[r3.z].val[16/4];
  r13.y = t0[r3.z].val[16/4+1];
  r13.z = t0[r3.z].val[16/4+2];
  r13.w = t0[r3.z].val[16/4+3];
  r11.xyzw = r13.xyzw * r2.zzzz + r11.xyzw;
  r14.x = t0[r3.w].val[16/4];
  r14.y = t0[r3.w].val[16/4+1];
  r14.z = t0[r3.w].val[16/4+2];
  r14.w = t0[r3.w].val[16/4+3];
  r11.xyzw = r14.xyzw * r2.wwww + r11.xyzw;
  r9.y = dot(r11.xyzw, v6.xyzw);
  r15.x = t0[r3.y].val[32/4];
  r15.y = t0[r3.y].val[32/4+1];
  r15.z = t0[r3.y].val[32/4+3];
  r15.w = t0[r3.y].val[32/4+2];
  r16.xyzw = r15.xywz * r2.yyyy;
  r17.x = t0[r3.x].val[32/4];
  r17.y = t0[r3.x].val[32/4+1];
  r17.z = t0[r3.x].val[32/4+3];
  r17.w = t0[r3.x].val[32/4+2];
  r16.xyzw = r17.xywz * r2.xxxx + r16.xyzw;
  r18.x = t0[r3.z].val[32/4];
  r18.y = t0[r3.z].val[32/4+1];
  r18.z = t0[r3.z].val[32/4+3];
  r18.w = t0[r3.z].val[32/4+2];
  r16.xyzw = r18.xywz * r2.zzzz + r16.xyzw;
  r19.x = t0[r3.w].val[32/4];
  r19.y = t0[r3.w].val[32/4+1];
  r19.z = t0[r3.w].val[32/4+3];
  r19.w = t0[r3.w].val[32/4+2];
  r16.xyzw = r19.xywz * r2.wwww + r16.xyzw;
  r9.z = dot(r16.xyzw, v6.xyzw);
  r9.x = dot(r1.xyz, r9.xyz);
  r20.x = dot(r5.xyzw, v7.xyzw);
  r5.x = dot(r5.xyzw, v8.xyzw);
  r20.y = dot(r11.xyzw, v7.xyzw);
  r5.y = dot(r11.xyzw, v8.xyzw);
  r20.z = dot(r16.xyzw, v7.xyzw);
  r5.z = dot(r16.xyzw, v8.xyzw);
  r9.z = dot(r1.xyz, r5.xyz);
  r9.y = dot(r1.xyz, r20.xyz);
  r1.x = dot(r9.xyz, r9.xyz);
  r1.x = rsqrt(r1.x);
  o3.xyz = r9.xyz * r1.xxx;
  r1.x = t0[r3.y].val[48/4];
  r1.y = t0[r3.y].val[48/4+1];
  r1.w = t0[r3.y].val[48/4+2];
  r5.w = r1.x;
  r5.x = r4.x;
  r5.y = r10.x;
  r5.z = r15.x;
  r5.x = dot(r0.xyzw, r5.xyzw);
  r9.w = r1.y;
  r9.x = r4.y;
  r9.y = r10.y;
  r9.z = r15.y;
  r5.y = dot(r0.xyzw, r9.xyzw);
  r1.x = r4.z;
  r15.x = r4.w;
  r1.y = r10.z;
  r15.y = r10.w;
  r1.z = r15.w;
  r5.z = dot(r0.xyzw, r1.xyzw);
  r15.w = 1;
  r5.w = dot(r0.xyzw, r15.xyzw);
  r1.xyzw = r5.xyzw * r2.yyyy;
  r4.x = t0[r3.x].val[48/4];
  r4.y = t0[r3.x].val[48/4+1];
  r4.w = t0[r3.x].val[48/4+2];
  r5.w = r4.x;
  r5.x = r6.x;
  r5.y = r12.x;
  r5.z = r17.x;
  r5.x = dot(r0.xyzw, r5.xyzw);
  r9.w = r4.y;
  r9.x = r6.y;
  r9.y = r12.y;
  r9.z = r17.y;
  r5.y = dot(r0.xyzw, r9.xyzw);
  r4.x = r6.z;
  r17.x = r6.w;
  r4.y = r12.z;
  r17.y = r12.w;
  r4.z = r17.w;
  r5.z = dot(r0.xyzw, r4.xyzw);
  r17.w = 1;
  r5.w = dot(r0.xyzw, r17.xyzw);
  r1.xyzw = r5.xyzw * r2.xxxx + r1.xyzw;
  r4.x = t0[r3.z].val[48/4];
  r4.y = t0[r3.z].val[48/4+1];
  r4.w = t0[r3.z].val[48/4+2];
  r3.x = t0[r3.w].val[48/4];
  r3.y = t0[r3.w].val[48/4+1];
  r3.w = t0[r3.w].val[48/4+2];
  r5.w = r4.x;
  r5.x = r7.x;
  r5.y = r13.x;
  r5.z = r18.x;
  r5.x = dot(r0.xyzw, r5.xyzw);
  r6.w = r4.y;
  r6.x = r7.y;
  r6.y = r13.y;
  r6.z = r18.y;
  r5.y = dot(r0.xyzw, r6.xyzw);
  r4.x = r7.z;
  r18.x = r7.w;
  r4.y = r13.z;
  r18.y = r13.w;
  r4.z = r18.w;
  r5.z = dot(r0.xyzw, r4.xyzw);
  r18.w = 1;
  r5.w = dot(r0.xyzw, r18.xyzw);
  r1.xyzw = r5.xyzw * r2.zzzz + r1.xyzw;
  r4.w = r3.x;
  r4.x = r8.x;
  r4.y = r14.x;
  r4.z = r19.x;
  r4.x = dot(r0.xyzw, r4.xyzw);
  r5.w = r3.y;
  r5.x = r8.y;
  r5.y = r14.y;
  r5.z = r19.y;
  r4.y = dot(r0.xyzw, r5.xyzw);
  r3.x = r8.z;
  r19.x = r8.w;
  r3.y = r14.z;
  r19.y = r14.w;
  r3.z = r19.w;
  r4.z = dot(r0.xyzw, r3.xyzw);
  r19.w = 1;
  r4.w = dot(r0.xyzw, r19.xyzw);
  r0.xyzw = r4.xyzw * r2.wwww + r1.xyzw;
  o4.x = dot(r0.xyzw, v6.xyzw);
  o4.y = dot(r0.xyzw, v7.xyzw);
  o4.z = dot(r0.xyzw, v8.xyzw);
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
  previous_clip = PreviousObjectClip(v0 * cb2[4].xyz + cb2[5].xyz, v1, v2, v10, 1.f, motion_instance, motion_history);
  return;
}