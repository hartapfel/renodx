// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:06:31 2026
Texture2D<float4> t1 : register(t1);

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
  float4 v6 : COLOR0,
  float4 v7 : TEXCOORD1,
  float2 v8 : TEXCOORD2,
  float4 v9 : INSTANCE_TRANSFORM0,
  float4 v10 : INSTANCE_TRANSFORM1,
  float4 v11 : INSTANCE_TRANSFORM2,
  float4 v12 : INSTANCE_LOD_PARAMS0,
  float4 v13 : INSTANCE_SKINNING_DATA0,
  uint motion_instance : SV_InstanceID,
  out float4 o0 : TEXCOORD0,
  out float4 o1 : TEXCOORD1,
  out float4 o2 : TEXCOORD2,
  out float4 o3 : TEXCOORD3,
  out float4 o4 : TEXCOORD4,
  out float4 o5 : TEXCOORD5,
  out float4 o6 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v2.x + v2.y;
  r0.x = v2.z + r0.x;
  r0.x = v2.w + r0.x;
  r0.xyzw = v2.xyzw / r0.xxxx;
  r1.xyzw = (uint4)v1.xyzw;
  r1.xyzw = r1.xyzw * v13.yyyy + v13.xxxx;
  r1.xyzw = (uint4)r1.xyzw;
  r2.x = t0[r1.y].val[0/4];
  r2.y = t0[r1.y].val[0/4+1];
  r2.z = t0[r1.y].val[0/4+2];
  r2.w = t0[r1.y].val[0/4+3];
  r3.xyzw = r2.xyzw * r0.yyyy;
  r4.x = t0[r1.x].val[0/4];
  r4.y = t0[r1.x].val[0/4+1];
  r4.z = t0[r1.x].val[0/4+2];
  r4.w = t0[r1.x].val[0/4+3];
  r3.xyzw = r4.xyzw * r0.xxxx + r3.xyzw;
  r5.x = t0[r1.z].val[0/4];
  r5.y = t0[r1.z].val[0/4+1];
  r5.z = t0[r1.z].val[0/4+2];
  r5.w = t0[r1.z].val[0/4+3];
  r3.xyzw = r5.xyzw * r0.zzzz + r3.xyzw;
  r6.x = t0[r1.w].val[0/4];
  r6.y = t0[r1.w].val[0/4+1];
  r6.z = t0[r1.w].val[0/4+2];
  r6.w = t0[r1.w].val[0/4+3];
  r3.xyzw = r6.xyzw * r0.wwww + r3.xyzw;
  r7.x = dot(r3.xyzw, v9.xyzw);
  r8.x = t0[r1.y].val[16/4];
  r8.y = t0[r1.y].val[16/4+1];
  r8.z = t0[r1.y].val[16/4+2];
  r8.w = t0[r1.y].val[16/4+3];
  r9.xyzw = r8.xyzw * r0.yyyy;
  r10.x = t0[r1.x].val[16/4];
  r10.y = t0[r1.x].val[16/4+1];
  r10.z = t0[r1.x].val[16/4+2];
  r10.w = t0[r1.x].val[16/4+3];
  r9.xyzw = r10.xyzw * r0.xxxx + r9.xyzw;
  r11.x = t0[r1.z].val[16/4];
  r11.y = t0[r1.z].val[16/4+1];
  r11.z = t0[r1.z].val[16/4+2];
  r11.w = t0[r1.z].val[16/4+3];
  r9.xyzw = r11.xyzw * r0.zzzz + r9.xyzw;
  r12.x = t0[r1.w].val[16/4];
  r12.y = t0[r1.w].val[16/4+1];
  r12.z = t0[r1.w].val[16/4+2];
  r12.w = t0[r1.w].val[16/4+3];
  r9.xyzw = r12.xyzw * r0.wwww + r9.xyzw;
  r7.y = dot(r9.xyzw, v9.xyzw);
  r13.x = t0[r1.y].val[32/4];
  r13.y = t0[r1.y].val[32/4+1];
  r13.z = t0[r1.y].val[32/4+3];
  r13.w = t0[r1.y].val[32/4+2];
  r14.xyzw = r13.xywz * r0.yyyy;
  r15.x = t0[r1.x].val[32/4];
  r15.y = t0[r1.x].val[32/4+1];
  r15.z = t0[r1.x].val[32/4+3];
  r15.w = t0[r1.x].val[32/4+2];
  r14.xyzw = r15.xywz * r0.xxxx + r14.xyzw;
  r16.x = t0[r1.z].val[32/4];
  r16.y = t0[r1.z].val[32/4+1];
  r16.z = t0[r1.z].val[32/4+3];
  r16.w = t0[r1.z].val[32/4+2];
  r14.xyzw = r16.xywz * r0.zzzz + r14.xyzw;
  r17.x = t0[r1.w].val[32/4];
  r17.y = t0[r1.w].val[32/4+1];
  r17.z = t0[r1.w].val[32/4+3];
  r17.w = t0[r1.w].val[32/4+2];
  r14.xyzw = r17.xywz * r0.wwww + r14.xyzw;
  r7.z = dot(r14.xyzw, v9.xyzw);
  r18.xyzw = v5.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r19.x = dot(r18.xyz, r7.xyz);
  r20.x = dot(r3.xyzw, v10.xyzw);
  r3.x = dot(r3.xyzw, v11.xyzw);
  r20.y = dot(r9.xyzw, v10.xyzw);
  r3.y = dot(r9.xyzw, v11.xyzw);
  r20.z = dot(r14.xyzw, v10.xyzw);
  r3.z = dot(r14.xyzw, v11.xyzw);
  r19.y = dot(r18.xyz, r20.xyz);
  r19.z = dot(r18.xyz, r3.xyz);
  r3.w = dot(r19.xyz, r19.xyz);
  r3.w = rsqrt(r3.w);
  r9.xyz = r19.xyz * r3.www;
  o0.w = r9.x;
  r14.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r14.w = 1;
  o0.x = dot(r14.xyzw, cb3[7].xyzw);
  o0.y = dot(r14.xyzw, cb3[8].xyzw);
  o0.z = dot(r14.xyzw, cb3[9].xyzw);
  o1.xyzw = v12.xyzw;
  o2.xy = v3.xy;
  o2.zw = v8.xy;
  o3.xyzw = v6.xyzw;
  r19.xyz = v4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r21.xyz = r19.zxy * r18.yzx;
  r18.xyz = r19.yzx * r18.zxy + -r21.xyz;
  r18.xyz = r18.xyz * r18.www;
  r3.w = dot(r18.xyz, r18.xyz);
  r3.w = rsqrt(r3.w);
  r18.xyz = r18.xyz * r3.www;
  r21.x = dot(r18.xyz, r7.xyz);
  r7.x = dot(r19.xyz, r7.xyz);
  r21.y = dot(r18.xyz, r20.xyz);
  r7.y = dot(r19.xyz, r20.xyz);
  r7.z = dot(r19.xyz, r3.xyz);
  r21.z = dot(r18.xyz, r3.xyz);
  r3.x = dot(r21.xyz, r21.xyz);
  r3.x = rsqrt(r3.x);
  o4.xyz = r21.xyz * r3.xxx;
  o4.w = r9.y;
  o5.w = r9.z;
  r3.x = dot(r7.xyz, r7.xyz);
  r3.x = rsqrt(r3.x);
  o5.xyz = r7.xyz * r3.xxx;
  r3.x = t0[r1.y].val[48/4];
  r3.y = t0[r1.y].val[48/4+1];
  r3.w = t0[r1.y].val[48/4+2];
  r7.w = r3.x;
  r7.x = r2.x;
  r7.y = r8.x;
  r7.z = r13.x;
  r7.x = dot(r14.xyzw, r7.xyzw);
  r9.w = r3.y;
  r9.x = r2.y;
  r9.y = r8.y;
  r9.z = r13.y;
  r7.y = dot(r14.xyzw, r9.xyzw);
  r3.x = r2.z;
  r13.x = r2.w;
  r3.y = r8.z;
  r13.y = r8.w;
  r3.z = r13.w;
  r7.z = dot(r14.xyzw, r3.xyzw);
  r13.w = 1;
  r7.w = dot(r14.xyzw, r13.xyzw);
  r2.xyzw = r7.xyzw * r0.yyyy;
  r3.x = t0[r1.x].val[48/4];
  r3.y = t0[r1.x].val[48/4+1];
  r3.w = t0[r1.x].val[48/4+2];
  r7.w = r3.x;
  r7.x = r4.x;
  r7.y = r10.x;
  r7.z = r15.x;
  r8.x = dot(r14.xyzw, r7.xyzw);
  r9.x = r4.y;
  r9.y = r10.y;
  r9.z = r15.y;
  r9.w = r3.y;
  r8.y = dot(r14.xyzw, r9.xyzw);
  r3.x = r4.z;
  r15.x = r4.w;
  r3.y = r10.z;
  r15.y = r10.w;
  r3.z = r15.w;
  r8.z = dot(r14.xyzw, r3.xyzw);
  r15.w = 1;
  r8.w = dot(r14.xyzw, r15.xyzw);
  r2.xyzw = r8.xyzw * r0.xxxx + r2.xyzw;
  r4.x = t0[r1.z].val[48/4];
  r4.y = t0[r1.z].val[48/4+1];
  r4.w = t0[r1.z].val[48/4+2];
  r8.w = r4.x;
  r8.x = r5.x;
  r8.y = r11.x;
  r8.z = r16.x;
  r8.x = dot(r14.xyzw, r8.xyzw);
  r10.w = r4.y;
  r10.x = r5.y;
  r10.y = r11.y;
  r10.z = r16.y;
  r8.y = dot(r14.xyzw, r10.xyzw);
  r4.x = r5.z;
  r16.x = r5.w;
  r4.y = r11.z;
  r16.y = r11.w;
  r4.z = r16.w;
  r8.z = dot(r14.xyzw, r4.xyzw);
  r16.w = 1;
  r8.w = dot(r14.xyzw, r16.xyzw);
  r2.xyzw = r8.xyzw * r0.zzzz + r2.xyzw;
  r4.x = t0[r1.w].val[48/4];
  r4.y = t0[r1.w].val[48/4+1];
  r4.w = t0[r1.w].val[48/4+2];
  r5.w = r4.x;
  r5.x = r6.x;
  r5.y = r12.x;
  r5.z = r17.x;
  r5.x = dot(r14.xyzw, r5.xyzw);
  r8.w = r4.y;
  r8.x = r6.y;
  r8.y = r12.y;
  r8.z = r17.y;
  r5.y = dot(r14.xyzw, r8.xyzw);
  r4.x = r6.z;
  r17.x = r6.w;
  r4.y = r12.z;
  r17.y = r12.w;
  r4.z = r17.w;
  r5.z = dot(r14.xyzw, r4.xyzw);
  r17.w = 1;
  r5.w = dot(r14.xyzw, r17.xyzw);
  r0.xyzw = r5.xyzw * r0.wwww + r2.xyzw;
  r2.x = v1.x;
  r2.yzw = float3(0,0,0);
  r2.xyz = t1.Load(r2.xyz).xyz;
  r9.x = t0[r1.x].val[0/4+1];
  r9.y = t0[r1.x].val[0/4];
  r9.z = t0[r1.x].val[0/4+2];
  r7.x = r9.y;
  r3.x = t0[r1.x].val[16/4];
  r3.y = t0[r1.x].val[16/4+2];
  r3.z = t0[r1.x].val[16/4+1];
  r1.x = t0[r1.x].val[32/4];
  r1.y = t0[r1.x].val[32/4+1];
  r1.z = t0[r1.x].val[32/4+2];
  r7.y = r3.x;
  r7.z = r1.x;
  r2.w = 1;
  r4.x = dot(r2.xyzw, r7.xyzw);
  r3.x = r9.z;
  r9.y = r3.z;
  r9.z = r1.y;
  r3.z = r1.z;
  r4.z = dot(r2.xyzw, r3.xyzw);
  r4.y = dot(r2.xyzw, r9.xyzw);
  r1.xyz = -r4.xyz + r0.xyz;
  r1.w = saturate(v6.w);
  r0.xyz = r1.www * r1.xyz + r4.xyz;
  r1.xyzw = cb1[0].yyyy * v10.xyzw;
  r1.xyzw = v9.xyzw * cb1[0].xxxx + r1.xyzw;
  r1.xyzw = v11.xyzw * cb1[0].zzzz + r1.xyzw;
  r1.xyzw = cb1[0].wwww * float4(0,0,0,1) + r1.xyzw;
  o6.x = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[1].yyyy * v10.xyzw;
  r1.xyzw = v9.xyzw * cb1[1].xxxx + r1.xyzw;
  r1.xyzw = v11.xyzw * cb1[1].zzzz + r1.xyzw;
  r1.xyzw = cb1[1].wwww * float4(0,0,0,1) + r1.xyzw;
  o6.y = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[2].yyyy * v10.xyzw;
  r1.xyzw = v9.xyzw * cb1[2].xxxx + r1.xyzw;
  r1.xyzw = v11.xyzw * cb1[2].zzzz + r1.xyzw;
  r1.xyzw = cb1[2].wwww * float4(0,0,0,1) + r1.xyzw;
  o6.z = dot(r0.xyzw, r1.xyzw);
  r1.xyzw = cb1[3].yyyy * v10.xyzw;
  r1.xyzw = v9.xyzw * cb1[3].xxxx + r1.xyzw;
  r1.xyzw = v11.xyzw * cb1[3].zzzz + r1.xyzw;
  r1.xyzw = cb1[3].wwww * float4(0,0,0,1) + r1.xyzw;
  o6.w = dot(r0.xyzw, r1.xyzw);
  previous_clip = PreviousObjectClip(v0 * cb2[4].xyz + cb2[5].xyz, v1, v2, v13, saturate(v6.w), motion_instance, motion_history);
  return;
}