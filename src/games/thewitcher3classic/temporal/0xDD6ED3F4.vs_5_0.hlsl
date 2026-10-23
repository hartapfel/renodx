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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.w = v3.x;
  r0.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r0.w = 1;
  o0.x = dot(r0.xyzw, cb3[7].xyzw);
  o0.y = dot(r0.xyzw, cb3[8].xyzw);
  o0.z = dot(r0.xyzw, cb3[9].xyzw);
  o1.xyzw = cb2[6].xyzw;
  o2.x = saturate(v4.z);
  o2.y = 0;
  o2.w = v3.y;
  r1.xyzw = (uint4)v1.xyzw;
  r1.xyzw = r1.xyzw * cb2[7].yyyy + cb2[7].xxxx;
  r1.xyzw = (uint4)r1.xyzw;
  r2.x = t0[r1.x].val[48/4];
  r2.y = t0[r1.x].val[48/4+1];
  r2.z = t0[r1.x].val[48/4+3];
  r2.w = t0[r1.x].val[48/4+2];
  r3.x = r2.z;
  r4.x = t0[r1.y].val[48/4];
  r4.y = t0[r1.y].val[48/4+1];
  r4.z = t0[r1.y].val[48/4+3];
  r4.w = t0[r1.y].val[48/4+2];
  r3.y = r4.z;
  r5.x = t0[r1.z].val[48/4];
  r5.y = t0[r1.z].val[48/4+1];
  r5.z = t0[r1.z].val[48/4+3];
  r5.w = t0[r1.z].val[48/4+2];
  r3.z = r5.z;
  r6.x = t0[r1.w].val[48/4];
  r6.y = t0[r1.w].val[48/4+1];
  r6.z = t0[r1.w].val[48/4+3];
  r6.w = t0[r1.w].val[48/4+2];
  r3.w = r6.z;
  r3.xyzw = float4(1,1,1,1) + -r3.xyzw;
  r7.x = v2.x + v2.y;
  r7.x = v2.z + r7.x;
  r7.x = v2.w + r7.x;
  r7.xyzw = v2.xyzw / r7.xxxx;
  r3.xy = r7.xy * r3.xy;
  r3.x = r3.x + r3.y;
  r3.x = r3.z * r7.z + r3.x;
  r3.x = r3.w * r7.w + r3.x;
  o2.z = saturate(5 * r3.x);
  o3.xy = v3.xy;
  r3.x = t0[r1.y].val[0/4];
  r3.y = t0[r1.y].val[0/4+1];
  r3.z = t0[r1.y].val[0/4+2];
  r3.w = t0[r1.y].val[0/4+3];
  r8.xyzw = r3.xyzw * r7.yyyy;
  r9.x = t0[r1.x].val[0/4];
  r9.y = t0[r1.x].val[0/4+1];
  r9.z = t0[r1.x].val[0/4+2];
  r9.w = t0[r1.x].val[0/4+3];
  r8.xyzw = r9.xyzw * r7.xxxx + r8.xyzw;
  r10.x = t0[r1.z].val[0/4];
  r10.y = t0[r1.z].val[0/4+1];
  r10.z = t0[r1.z].val[0/4+2];
  r10.w = t0[r1.z].val[0/4+3];
  r8.xyzw = r10.xyzw * r7.zzzz + r8.xyzw;
  r11.x = t0[r1.w].val[0/4];
  r11.y = t0[r1.w].val[0/4+1];
  r11.z = t0[r1.w].val[0/4+2];
  r11.w = t0[r1.w].val[0/4+3];
  r8.xyzw = r11.xyzw * r7.wwww + r8.xyzw;
  r12.x = dot(r8.xyzw, cb2[0].xyzw);
  r13.x = t0[r1.y].val[16/4];
  r13.y = t0[r1.y].val[16/4+1];
  r13.z = t0[r1.y].val[16/4+2];
  r13.w = t0[r1.y].val[16/4+3];
  r14.xyzw = r13.xyzw * r7.yyyy;
  r15.x = t0[r1.x].val[16/4];
  r15.y = t0[r1.x].val[16/4+1];
  r15.z = t0[r1.x].val[16/4+2];
  r15.w = t0[r1.x].val[16/4+3];
  r14.xyzw = r15.xyzw * r7.xxxx + r14.xyzw;
  r16.x = t0[r1.z].val[16/4];
  r16.y = t0[r1.z].val[16/4+1];
  r16.z = t0[r1.z].val[16/4+2];
  r16.w = t0[r1.z].val[16/4+3];
  r14.xyzw = r16.xyzw * r7.zzzz + r14.xyzw;
  r17.x = t0[r1.w].val[16/4];
  r17.y = t0[r1.w].val[16/4+1];
  r17.z = t0[r1.w].val[16/4+2];
  r17.w = t0[r1.w].val[16/4+3];
  r14.xyzw = r17.xyzw * r7.wwww + r14.xyzw;
  r12.y = dot(r14.xyzw, cb2[0].xyzw);
  r18.x = t0[r1.y].val[32/4];
  r18.y = t0[r1.y].val[32/4+1];
  r18.z = t0[r1.y].val[32/4+3];
  r18.w = t0[r1.y].val[32/4+2];
  r19.xyzw = r18.xywz * r7.yyyy;
  r20.x = t0[r1.x].val[32/4];
  r20.y = t0[r1.x].val[32/4+1];
  r20.z = t0[r1.x].val[32/4+3];
  r20.w = t0[r1.x].val[32/4+2];
  r19.xyzw = r20.xywz * r7.xxxx + r19.xyzw;
  r21.x = t0[r1.z].val[32/4];
  r21.y = t0[r1.z].val[32/4+1];
  r21.z = t0[r1.z].val[32/4+3];
  r21.w = t0[r1.z].val[32/4+2];
  r1.x = t0[r1.w].val[32/4];
  r1.y = t0[r1.w].val[32/4+1];
  r1.z = t0[r1.w].val[32/4+3];
  r1.w = t0[r1.w].val[32/4+2];
  r19.xyzw = r21.xywz * r7.zzzz + r19.xyzw;
  r19.xyzw = r1.xywz * r7.wwww + r19.xyzw;
  r12.z = dot(r19.xyzw, cb2[0].xyzw);
  r22.xyz = v4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r23.x = dot(r22.xyz, r12.xyz);
  r24.x = dot(r8.xyzw, cb2[1].xyzw);
  r8.x = dot(r8.xyzw, cb2[2].xyzw);
  r24.y = dot(r14.xyzw, cb2[1].xyzw);
  r8.y = dot(r14.xyzw, cb2[2].xyzw);
  r24.z = dot(r19.xyzw, cb2[1].xyzw);
  r8.z = dot(r19.xyzw, cb2[2].xyzw);
  r23.y = dot(r22.xyz, r24.xyz);
  r23.z = dot(r22.xyz, r8.xyz);
  r8.w = dot(r23.xyz, r23.xyz);
  r8.w = rsqrt(r8.w);
  r14.xyz = r23.xyz * r8.www;
  o3.zw = r14.xy;
  o4.w = r14.z;
  r14.xyzw = v5.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r19.xyz = r22.zxy * r14.yzx;
  r19.xyz = r22.yzx * r14.zxy + -r19.xyz;
  r19.xyz = r19.xyz * r14.www;
  r8.w = dot(r19.xyz, r19.xyz);
  r8.w = rsqrt(r8.w);
  r19.xyz = r19.xyz * r8.www;
  r22.x = dot(r19.xyz, r12.xyz);
  r12.x = dot(r14.xyz, r12.xyz);
  r22.y = dot(r19.xyz, r24.xyz);
  r12.y = dot(r14.xyz, r24.xyz);
  r12.z = dot(r14.xyz, r8.xyz);
  r22.z = dot(r19.xyz, r8.xyz);
  r8.x = dot(r22.xyz, r22.xyz);
  r8.x = rsqrt(r8.x);
  o4.xyz = r22.xyz * r8.xxx;
  r8.x = dot(r12.xyz, r12.xyz);
  r8.x = rsqrt(r8.x);
  o5.xyz = r12.xyz * r8.xxx;
  r8.w = r4.x;
  r8.x = r3.x;
  r8.y = r13.x;
  r8.z = r18.x;
  r8.x = dot(r0.xyzw, r8.xyzw);
  r12.w = r4.y;
  r12.x = r3.y;
  r12.y = r13.y;
  r12.z = r18.y;
  r8.y = dot(r0.xyzw, r12.xyzw);
  r4.x = r3.z;
  r18.x = r3.w;
  r4.y = r13.z;
  r18.y = r13.w;
  r4.z = r18.w;
  r8.z = dot(r0.xyzw, r4.xyzw);
  r18.w = 1;
  r8.w = dot(r0.xyzw, r18.xyzw);
  r3.xyzw = r8.xyzw * r7.yyyy;
  r4.w = r2.x;
  r4.x = r9.x;
  r4.y = r15.x;
  r4.z = r20.x;
  r4.x = dot(r0.xyzw, r4.xyzw);
  r8.w = r2.y;
  r8.x = r9.y;
  r8.y = r15.y;
  r8.z = r20.y;
  r4.y = dot(r0.xyzw, r8.xyzw);
  r2.x = r9.z;
  r20.x = r9.w;
  r2.y = r15.z;
  r20.y = r15.w;
  r2.z = r20.w;
  r4.z = dot(r0.xyzw, r2.xyzw);
  r20.w = 1;
  r4.w = dot(r0.xyzw, r20.xyzw);
  r2.xyzw = r4.xyzw * r7.xxxx + r3.xyzw;
  r3.w = r5.x;
  r3.x = r10.x;
  r3.y = r16.x;
  r3.z = r21.x;
  r3.x = dot(r0.xyzw, r3.xyzw);
  r4.w = r5.y;
  r4.x = r10.y;
  r4.y = r16.y;
  r4.z = r21.y;
  r3.y = dot(r0.xyzw, r4.xyzw);
  r5.x = r10.z;
  r21.x = r10.w;
  r5.y = r16.z;
  r21.y = r16.w;
  r5.z = r21.w;
  r3.z = dot(r0.xyzw, r5.xyzw);
  r21.w = 1;
  r3.w = dot(r0.xyzw, r21.xyzw);
  r2.xyzw = r3.xyzw * r7.zzzz + r2.xyzw;
  r3.w = r6.x;
  r3.x = r11.x;
  r3.y = r17.x;
  r3.z = r1.x;
  r3.x = dot(r0.xyzw, r3.xyzw);
  r4.w = r6.y;
  r4.x = r11.y;
  r4.y = r17.y;
  r4.z = r1.y;
  r3.y = dot(r0.xyzw, r4.xyzw);
  r6.x = r11.z;
  r1.x = r11.w;
  r6.y = r17.z;
  r1.y = r17.w;
  r6.z = r1.w;
  r3.z = dot(r0.xyzw, r6.xyzw);
  r1.w = 1;
  r3.w = dot(r0.xyzw, r1.xyzw);
  r0.xyzw = r3.xyzw * r7.wwww + r2.xyzw;
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