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
  out float4 o1 : TEXCOORD1,
  out float4 o2 : TEXCOORD2,
  out float3 o3 : TEXCOORD3,
  out float4 o4 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20;
  uint4 bitmask, uiDest;
  float4 fDest;

  o0.xy = v3.xy;
  r0.xyz = v4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.w = v2.x + v2.y;
  r0.w = v2.z + r0.w;
  r0.w = v2.w + r0.w;
  r1.xyzw = v2.xyzw / r0.wwww;
  r2.xyzw = (uint4)v1.xyzw;
  r2.xyzw = r2.xyzw * v12.yyyy + v12.xxxx;
  r2.xyzw = (uint4)r2.xyzw;
  r3.x = t0[r2.y].val[0/4];
  r3.y = t0[r2.y].val[0/4+1];
  r3.z = t0[r2.y].val[0/4+2];
  r3.w = t0[r2.y].val[0/4+3];
  r4.xyzw = r3.xyzw * r1.yyyy;
  r5.x = t0[r2.x].val[0/4];
  r5.y = t0[r2.x].val[0/4+1];
  r5.z = t0[r2.x].val[0/4+2];
  r5.w = t0[r2.x].val[0/4+3];
  r4.xyzw = r5.xyzw * r1.xxxx + r4.xyzw;
  r6.x = t0[r2.z].val[0/4];
  r6.y = t0[r2.z].val[0/4+1];
  r6.z = t0[r2.z].val[0/4+2];
  r6.w = t0[r2.z].val[0/4+3];
  r4.xyzw = r6.xyzw * r1.zzzz + r4.xyzw;
  r7.x = t0[r2.w].val[0/4];
  r7.y = t0[r2.w].val[0/4+1];
  r7.z = t0[r2.w].val[0/4+2];
  r7.w = t0[r2.w].val[0/4+3];
  r4.xyzw = r7.xyzw * r1.wwww + r4.xyzw;
  r8.x = dot(r4.xyzw, v8.xyzw);
  r9.x = t0[r2.y].val[16/4];
  r9.y = t0[r2.y].val[16/4+1];
  r9.z = t0[r2.y].val[16/4+2];
  r9.w = t0[r2.y].val[16/4+3];
  r10.xyzw = r9.xyzw * r1.yyyy;
  r11.x = t0[r2.x].val[16/4];
  r11.y = t0[r2.x].val[16/4+1];
  r11.z = t0[r2.x].val[16/4+2];
  r11.w = t0[r2.x].val[16/4+3];
  r10.xyzw = r11.xyzw * r1.xxxx + r10.xyzw;
  r12.x = t0[r2.z].val[16/4];
  r12.y = t0[r2.z].val[16/4+1];
  r12.z = t0[r2.z].val[16/4+2];
  r12.w = t0[r2.z].val[16/4+3];
  r10.xyzw = r12.xyzw * r1.zzzz + r10.xyzw;
  r13.x = t0[r2.w].val[16/4];
  r13.y = t0[r2.w].val[16/4+1];
  r13.z = t0[r2.w].val[16/4+2];
  r13.w = t0[r2.w].val[16/4+3];
  r10.xyzw = r13.xyzw * r1.wwww + r10.xyzw;
  r8.y = dot(r10.xyzw, v8.xyzw);
  r14.x = t0[r2.y].val[32/4];
  r14.y = t0[r2.y].val[32/4+1];
  r14.z = t0[r2.y].val[32/4+3];
  r14.w = t0[r2.y].val[32/4+2];
  r15.xyzw = r14.xywz * r1.yyyy;
  r16.x = t0[r2.x].val[32/4];
  r16.y = t0[r2.x].val[32/4+1];
  r16.z = t0[r2.x].val[32/4+3];
  r16.w = t0[r2.x].val[32/4+2];
  r15.xyzw = r16.xywz * r1.xxxx + r15.xyzw;
  r17.x = t0[r2.z].val[32/4];
  r17.y = t0[r2.z].val[32/4+1];
  r17.z = t0[r2.z].val[32/4+3];
  r17.w = t0[r2.z].val[32/4+2];
  r15.xyzw = r17.xywz * r1.zzzz + r15.xyzw;
  r18.x = t0[r2.w].val[32/4];
  r18.y = t0[r2.w].val[32/4+1];
  r18.z = t0[r2.w].val[32/4+3];
  r18.w = t0[r2.w].val[32/4+2];
  r15.xyzw = r18.xywz * r1.wwww + r15.xyzw;
  r8.z = dot(r15.xyzw, v8.xyzw);
  r19.x = dot(r0.xyz, r8.xyz);
  r20.x = dot(r4.xyzw, v9.xyzw);
  r4.x = dot(r4.xyzw, v10.xyzw);
  r20.y = dot(r10.xyzw, v9.xyzw);
  r4.y = dot(r10.xyzw, v10.xyzw);
  r20.z = dot(r15.xyzw, v9.xyzw);
  r4.z = dot(r15.xyzw, v10.xyzw);
  r19.y = dot(r0.xyz, r20.xyz);
  r19.z = dot(r0.xyz, r4.xyz);
  r0.w = dot(r19.xyz, r19.xyz);
  r0.w = rsqrt(r0.w);
  r10.xyz = r19.xyz * r0.www;
  o0.zw = r10.xy;
  o1.w = r10.z;
  r10.xyzw = v5.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r15.xyz = r10.yzx * r0.zxy;
  r0.xyz = r0.yzx * r10.zxy + -r15.xyz;
  r0.xyz = r0.xyz * r10.www;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r15.x = dot(r0.xyz, r8.xyz);
  r8.x = dot(r10.xyz, r8.xyz);
  r15.y = dot(r0.xyz, r20.xyz);
  r8.y = dot(r10.xyz, r20.xyz);
  r8.z = dot(r10.xyz, r4.xyz);
  r15.z = dot(r0.xyz, r4.xyz);
  r0.x = dot(r15.xyz, r15.xyz);
  r0.x = rsqrt(r0.x);
  o1.xyz = r15.xyz * r0.xxx;
  r0.x = t0[r2.y].val[48/4];
  r0.y = t0[r2.y].val[48/4+1];
  r0.w = t0[r2.y].val[48/4+2];
  r4.w = r0.x;
  r4.x = r3.x;
  r4.y = r9.x;
  r4.z = r14.x;
  r10.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r10.w = 1;
  r4.x = dot(r10.xyzw, r4.xyzw);
  r15.w = r0.y;
  r15.x = r3.y;
  r15.y = r9.y;
  r15.z = r14.y;
  r4.y = dot(r10.xyzw, r15.xyzw);
  r0.x = r3.z;
  r14.x = r3.w;
  r0.y = r9.z;
  r14.y = r9.w;
  r0.z = r14.w;
  r4.z = dot(r10.xyzw, r0.xyzw);
  r14.w = 1;
  r4.w = dot(r10.xyzw, r14.xyzw);
  r0.xyzw = r4.xyzw * r1.yyyy;
  r3.x = t0[r2.x].val[48/4];
  r3.y = t0[r2.x].val[48/4+1];
  r3.w = t0[r2.x].val[48/4+2];
  r4.w = r3.x;
  r4.x = r5.x;
  r4.y = r11.x;
  r4.z = r16.x;
  r4.x = dot(r10.xyzw, r4.xyzw);
  r9.w = r3.y;
  r9.x = r5.y;
  r9.y = r11.y;
  r9.z = r16.y;
  r4.y = dot(r10.xyzw, r9.xyzw);
  r3.x = r5.z;
  r16.x = r5.w;
  r3.y = r11.z;
  r16.y = r11.w;
  r3.z = r16.w;
  r4.z = dot(r10.xyzw, r3.xyzw);
  r16.w = 1;
  r4.w = dot(r10.xyzw, r16.xyzw);
  r0.xyzw = r4.xyzw * r1.xxxx + r0.xyzw;
  r3.x = t0[r2.z].val[48/4];
  r3.y = t0[r2.z].val[48/4+1];
  r3.w = t0[r2.z].val[48/4+2];
  r2.x = t0[r2.w].val[48/4];
  r2.y = t0[r2.w].val[48/4+1];
  r2.w = t0[r2.w].val[48/4+2];
  r4.w = r3.x;
  r4.x = r6.x;
  r4.y = r12.x;
  r4.z = r17.x;
  r4.x = dot(r10.xyzw, r4.xyzw);
  r5.w = r3.y;
  r5.x = r6.y;
  r5.y = r12.y;
  r5.z = r17.y;
  r4.y = dot(r10.xyzw, r5.xyzw);
  r3.x = r6.z;
  r17.x = r6.w;
  r3.y = r12.z;
  r17.y = r12.w;
  r3.z = r17.w;
  r4.z = dot(r10.xyzw, r3.xyzw);
  r17.w = 1;
  r4.w = dot(r10.xyzw, r17.xyzw);
  r0.xyzw = r4.xyzw * r1.zzzz + r0.xyzw;
  r3.w = r2.x;
  r3.x = r7.x;
  r3.y = r13.x;
  r3.z = r18.x;
  r3.x = dot(r10.xyzw, r3.xyzw);
  r4.w = r2.y;
  r4.x = r7.y;
  r4.y = r13.y;
  r4.z = r18.y;
  r3.y = dot(r10.xyzw, r4.xyzw);
  r2.x = r7.z;
  r18.x = r7.w;
  r2.y = r13.z;
  r18.y = r13.w;
  r2.z = r18.w;
  r3.z = dot(r10.xyzw, r2.xyzw);
  r18.w = 1;
  r3.w = dot(r10.xyzw, r18.xyzw);
  r0.xyzw = r3.xyzw * r1.wwww + r0.xyzw;
  o2.x = dot(r0.xyzw, v8.xyzw);
  o2.y = dot(r0.xyzw, v9.xyzw);
  o2.z = dot(r0.xyzw, v10.xyzw);
  r1.x = dot(r8.xyz, r8.xyz);
  r1.x = rsqrt(r1.x);
  o3.xyz = r8.xyz * r1.xxx;
  r1.xyzw = cb1[0].yyyy * v9.xyzw;
  r1.xyzw = v8.xyzw * cb1[0].xxxx + r1.xyzw;
  r1.xyzw = v10.xyzw * cb1[0].zzzz + r1.xyzw;
  r1.xyzw = cb1[0].wwww * float4(0,0,0,1) + r1.xyzw;
  o4.x = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[1].yyyy * v9.xyzw;
  r1.xyzw = v8.xyzw * cb1[1].xxxx + r1.xyzw;
  r1.xyzw = v10.xyzw * cb1[1].zzzz + r1.xyzw;
  r1.xyzw = cb1[1].wwww * float4(0,0,0,1) + r1.xyzw;
  o4.y = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[2].yyyy * v9.xyzw;
  r1.xyzw = v8.xyzw * cb1[2].xxxx + r1.xyzw;
  r1.xyzw = v10.xyzw * cb1[2].zzzz + r1.xyzw;
  r1.xyzw = cb1[2].wwww * float4(0,0,0,1) + r1.xyzw;
  o4.z = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[3].yyyy * v9.xyzw;
  r1.xyzw = v8.xyzw * cb1[3].xxxx + r1.xyzw;
  r1.xyzw = v10.xyzw * cb1[3].zzzz + r1.xyzw;
  r1.xyzw = cb1[3].wwww * float4(0,0,0,1) + r1.xyzw;
  o4.w = dot(r0.xyzw, r1.xyzw);
  previous_clip = PreviousObjectClip(v0 * cb2[4].xyz + cb2[5].xyz, v1, v2, v12, 1.f, motion_instance, motion_history);
  return;
}