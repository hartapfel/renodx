// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:06:34 2026
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
  float2 v6 : TEXCOORD2,
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r1.xyzw = v5.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r2.xyz = r1.yzx * r0.zxy;
  r2.xyz = r0.yzx * r1.zxy + -r2.xyz;
  r2.xyz = r2.xyz * r1.www;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r2.xyz * r0.www;
  r0.w = v2.x + v2.y;
  r0.w = v2.z + r0.w;
  r0.w = v2.w + r0.w;
  r3.xyzw = v2.xyzw / r0.wwww;
  r4.xyzw = (uint4)v1.xyzw;
  r4.xyzw = r4.xyzw * cb2[7].yyyy + cb2[7].xxxx;
  r4.xyzw = (uint4)r4.xyzw;
  r5.x = t0[r4.y].val[0/4];
  r5.y = t0[r4.y].val[0/4+1];
  r5.z = t0[r4.y].val[0/4+2];
  r5.w = t0[r4.y].val[0/4+3];
  r6.xyzw = r5.xyzw * r3.yyyy;
  r7.x = t0[r4.x].val[0/4];
  r7.y = t0[r4.x].val[0/4+1];
  r7.z = t0[r4.x].val[0/4+2];
  r7.w = t0[r4.x].val[0/4+3];
  r6.xyzw = r7.xyzw * r3.xxxx + r6.xyzw;
  r8.x = t0[r4.z].val[0/4];
  r8.y = t0[r4.z].val[0/4+1];
  r8.z = t0[r4.z].val[0/4+2];
  r8.w = t0[r4.z].val[0/4+3];
  r6.xyzw = r8.xyzw * r3.zzzz + r6.xyzw;
  r9.x = t0[r4.w].val[0/4];
  r9.y = t0[r4.w].val[0/4+1];
  r9.z = t0[r4.w].val[0/4+2];
  r9.w = t0[r4.w].val[0/4+3];
  r6.xyzw = r9.xyzw * r3.wwww + r6.xyzw;
  r10.x = dot(r6.xyzw, cb2[0].xyzw);
  r11.x = t0[r4.y].val[16/4];
  r11.y = t0[r4.y].val[16/4+1];
  r11.z = t0[r4.y].val[16/4+2];
  r11.w = t0[r4.y].val[16/4+3];
  r12.xyzw = r11.xyzw * r3.yyyy;
  r13.x = t0[r4.x].val[16/4];
  r13.y = t0[r4.x].val[16/4+1];
  r13.z = t0[r4.x].val[16/4+2];
  r13.w = t0[r4.x].val[16/4+3];
  r12.xyzw = r13.xyzw * r3.xxxx + r12.xyzw;
  r14.x = t0[r4.z].val[16/4];
  r14.y = t0[r4.z].val[16/4+1];
  r14.z = t0[r4.z].val[16/4+2];
  r14.w = t0[r4.z].val[16/4+3];
  r12.xyzw = r14.xyzw * r3.zzzz + r12.xyzw;
  r15.x = t0[r4.w].val[16/4];
  r15.y = t0[r4.w].val[16/4+1];
  r15.z = t0[r4.w].val[16/4+2];
  r15.w = t0[r4.w].val[16/4+3];
  r12.xyzw = r15.xyzw * r3.wwww + r12.xyzw;
  r10.y = dot(r12.xyzw, cb2[0].xyzw);
  r16.x = t0[r4.y].val[32/4];
  r16.y = t0[r4.y].val[32/4+1];
  r16.z = t0[r4.y].val[32/4+3];
  r16.w = t0[r4.y].val[32/4+2];
  r17.xyzw = r16.xywz * r3.yyyy;
  r18.x = t0[r4.x].val[32/4];
  r18.y = t0[r4.x].val[32/4+1];
  r18.z = t0[r4.x].val[32/4+3];
  r18.w = t0[r4.x].val[32/4+2];
  r17.xyzw = r18.xywz * r3.xxxx + r17.xyzw;
  r19.x = t0[r4.z].val[32/4];
  r19.y = t0[r4.z].val[32/4+1];
  r19.z = t0[r4.z].val[32/4+3];
  r19.w = t0[r4.z].val[32/4+2];
  r17.xyzw = r19.xywz * r3.zzzz + r17.xyzw;
  r20.x = t0[r4.w].val[32/4];
  r20.y = t0[r4.w].val[32/4+1];
  r20.z = t0[r4.w].val[32/4+3];
  r20.w = t0[r4.w].val[32/4+2];
  r17.xyzw = r20.xywz * r3.wwww + r17.xyzw;
  r10.z = dot(r17.xyzw, cb2[0].xyzw);
  r21.x = dot(r2.xyz, r10.xyz);
  r22.x = dot(r6.xyzw, cb2[1].xyzw);
  r6.x = dot(r6.xyzw, cb2[2].xyzw);
  r22.y = dot(r12.xyzw, cb2[1].xyzw);
  r6.y = dot(r12.xyzw, cb2[2].xyzw);
  r22.z = dot(r17.xyzw, cb2[1].xyzw);
  r6.z = dot(r17.xyzw, cb2[2].xyzw);
  r21.y = dot(r2.xyz, r22.xyz);
  r21.z = dot(r2.xyz, r6.xyz);
  r0.w = dot(r21.xyz, r21.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r21.xyz * r0.www;
  o0.w = r2.x;
  o3.zw = r2.yz;
  r2.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r2.w = 1;
  o0.x = dot(r2.xyzw, cb3[7].xyzw);
  o0.y = dot(r2.xyzw, cb3[8].xyzw);
  o0.z = dot(r2.xyzw, cb3[9].xyzw);
  o1.xyzw = cb2[6].xyzw;
  o2.xy = v3.xy;
  o2.zw = float2(0,0);
  o3.xy = v6.xy;
  r12.x = dot(r0.xyz, r10.xyz);
  r10.x = dot(r1.xyz, r10.xyz);
  r12.y = dot(r0.xyz, r22.xyz);
  r10.y = dot(r1.xyz, r22.xyz);
  r10.z = dot(r1.xyz, r6.xyz);
  r12.z = dot(r0.xyz, r6.xyz);
  r0.x = dot(r12.xyz, r12.xyz);
  r0.x = rsqrt(r0.x);
  o4.xyz = r12.xyz * r0.xxx;
  r0.x = dot(r10.xyz, r10.xyz);
  r0.x = rsqrt(r0.x);
  o5.xyz = r10.xyz * r0.xxx;
  r0.x = t0[r4.y].val[48/4];
  r0.y = t0[r4.y].val[48/4+1];
  r0.w = t0[r4.y].val[48/4+2];
  r1.w = r0.x;
  r1.x = r5.x;
  r1.y = r11.x;
  r1.z = r16.x;
  r1.x = dot(r2.xyzw, r1.xyzw);
  r6.w = r0.y;
  r6.x = r5.y;
  r6.y = r11.y;
  r6.z = r16.y;
  r1.y = dot(r2.xyzw, r6.xyzw);
  r0.x = r5.z;
  r16.x = r5.w;
  r0.y = r11.z;
  r16.y = r11.w;
  r0.z = r16.w;
  r1.z = dot(r2.xyzw, r0.xyzw);
  r16.w = 1;
  r1.w = dot(r2.xyzw, r16.xyzw);
  r0.xyzw = r1.xyzw * r3.yyyy;
  r1.x = t0[r4.x].val[48/4];
  r1.y = t0[r4.x].val[48/4+1];
  r1.w = t0[r4.x].val[48/4+2];
  r5.w = r1.x;
  r5.x = r7.x;
  r5.y = r13.x;
  r5.z = r18.x;
  r5.x = dot(r2.xyzw, r5.xyzw);
  r6.w = r1.y;
  r6.x = r7.y;
  r6.y = r13.y;
  r6.z = r18.y;
  r5.y = dot(r2.xyzw, r6.xyzw);
  r1.x = r7.z;
  r18.x = r7.w;
  r1.y = r13.z;
  r18.y = r13.w;
  r1.z = r18.w;
  r5.z = dot(r2.xyzw, r1.xyzw);
  r18.w = 1;
  r5.w = dot(r2.xyzw, r18.xyzw);
  r0.xyzw = r5.xyzw * r3.xxxx + r0.xyzw;
  r1.x = t0[r4.z].val[48/4];
  r1.y = t0[r4.z].val[48/4+1];
  r1.w = t0[r4.z].val[48/4+2];
  r4.x = t0[r4.w].val[48/4];
  r4.y = t0[r4.w].val[48/4+1];
  r4.w = t0[r4.w].val[48/4+2];
  r5.w = r1.x;
  r5.x = r8.x;
  r5.y = r14.x;
  r5.z = r19.x;
  r5.x = dot(r2.xyzw, r5.xyzw);
  r6.w = r1.y;
  r6.x = r8.y;
  r6.y = r14.y;
  r6.z = r19.y;
  r5.y = dot(r2.xyzw, r6.xyzw);
  r1.x = r8.z;
  r19.x = r8.w;
  r1.y = r14.z;
  r19.y = r14.w;
  r1.z = r19.w;
  r5.z = dot(r2.xyzw, r1.xyzw);
  r19.w = 1;
  r5.w = dot(r2.xyzw, r19.xyzw);
  r0.xyzw = r5.xyzw * r3.zzzz + r0.xyzw;
  r1.w = r4.x;
  r1.x = r9.x;
  r1.y = r15.x;
  r1.z = r20.x;
  r1.x = dot(r2.xyzw, r1.xyzw);
  r5.w = r4.y;
  r5.x = r9.y;
  r5.y = r15.y;
  r5.z = r20.y;
  r1.y = dot(r2.xyzw, r5.xyzw);
  r4.x = r9.z;
  r20.x = r9.w;
  r4.y = r15.z;
  r20.y = r15.w;
  r4.z = r20.w;
  r1.z = dot(r2.xyzw, r4.xyzw);
  r20.w = 1;
  r1.w = dot(r2.xyzw, r20.xyzw);
  r0.xyzw = r1.xyzw * r3.wwww + r0.xyzw;
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