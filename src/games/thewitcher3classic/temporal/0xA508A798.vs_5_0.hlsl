// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:06:34 2026
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
  out float4 o3 : TEXCOORD3,
  out float3 o4 : TEXCOORD4,
  out float4 o5 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v2.x + v2.y;
  r0.x = v2.z + r0.x;
  r0.x = v2.w + r0.x;
  r0.xyzw = v2.xyzw / r0.xxxx;
  r1.xyzw = (uint4)v1.xyzw;
  r1.xyzw = r1.xyzw * v12.yyyy + v12.xxxx;
  r1.xyzw = (uint4)r1.xyzw;
  r2.x = t0[r1.y].val[48/4];
  r2.y = t0[r1.y].val[48/4+3];
  r2.z = t0[r1.y].val[48/4+1];
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
  r8.w = r2.z;
  r8.x = r4.y;
  r8.y = r5.y;
  r8.z = r6.y;
  r3.y = dot(r7.xyzw, r8.xyzw);
  r8.w = r2.w;
  r8.x = r4.z;
  r8.y = r5.z;
  r8.z = r6.z;
  r3.z = dot(r7.xyzw, r8.xyzw);
  r8.w = 1;
  r8.x = r4.w;
  r4.xyzw = r4.xyzw * r0.yyyy;
  r8.y = r5.w;
  r5.xyzw = r5.xyzw * r0.yyyy;
  r8.z = r6.w;
  r6.xyzw = r6.xyzw * r0.yyyy;
  r3.w = dot(r7.xyzw, r8.xyzw);
  r3.xyzw = r3.xyzw * r0.yyyy;
  r8.x = t0[r1.x].val[48/4];
  r8.y = t0[r1.x].val[48/4+1];
  r8.z = t0[r1.x].val[48/4+3];
  r8.w = t0[r1.x].val[48/4+2];
  r9.w = r8.x;
  r10.x = t0[r1.x].val[0/4];
  r10.y = t0[r1.x].val[0/4+1];
  r10.z = t0[r1.x].val[0/4+2];
  r10.w = t0[r1.x].val[0/4+3];
  r9.x = r10.x;
  r11.x = t0[r1.x].val[16/4];
  r11.y = t0[r1.x].val[16/4+1];
  r11.z = t0[r1.x].val[16/4+2];
  r11.w = t0[r1.x].val[16/4+3];
  r9.y = r11.x;
  r12.x = t0[r1.x].val[32/4];
  r12.y = t0[r1.x].val[32/4+1];
  r12.z = t0[r1.x].val[32/4+2];
  r12.w = t0[r1.x].val[32/4+3];
  r9.z = r12.x;
  r9.x = dot(r7.xyzw, r9.xyzw);
  r13.w = r8.y;
  r13.x = r10.y;
  r13.y = r11.y;
  r13.z = r12.y;
  r9.y = dot(r7.xyzw, r13.xyzw);
  r2.x = r8.z;
  r8.x = r10.z;
  r8.y = r11.z;
  r8.z = r12.z;
  r9.z = dot(r7.xyzw, r8.xyzw);
  r8.w = 1;
  r8.x = r10.w;
  r4.xyzw = r10.xyzw * r0.xxxx + r4.xyzw;
  r8.y = r11.w;
  r5.xyzw = r11.xyzw * r0.xxxx + r5.xyzw;
  r8.z = r12.w;
  r6.xyzw = r12.xyzw * r0.xxxx + r6.xyzw;
  r9.w = dot(r7.xyzw, r8.xyzw);
  r3.xyzw = r9.xyzw * r0.xxxx + r3.xyzw;
  r8.x = t0[r1.z].val[48/4];
  r8.y = t0[r1.z].val[48/4+1];
  r8.z = t0[r1.z].val[48/4+3];
  r8.w = t0[r1.z].val[48/4+2];
  r9.w = r8.x;
  r10.x = t0[r1.z].val[0/4];
  r10.y = t0[r1.z].val[0/4+1];
  r10.z = t0[r1.z].val[0/4+2];
  r10.w = t0[r1.z].val[0/4+3];
  r9.x = r10.x;
  r11.x = t0[r1.z].val[16/4];
  r11.y = t0[r1.z].val[16/4+1];
  r11.z = t0[r1.z].val[16/4+2];
  r11.w = t0[r1.z].val[16/4+3];
  r9.y = r11.x;
  r12.x = t0[r1.z].val[32/4];
  r12.y = t0[r1.z].val[32/4+1];
  r12.z = t0[r1.z].val[32/4+2];
  r12.w = t0[r1.z].val[32/4+3];
  r9.z = r12.x;
  r9.x = dot(r7.xyzw, r9.xyzw);
  r13.w = r8.y;
  r13.x = r10.y;
  r13.y = r11.y;
  r13.z = r12.y;
  r9.y = dot(r7.xyzw, r13.xyzw);
  r2.z = r8.z;
  r8.x = r10.z;
  r8.y = r11.z;
  r8.z = r12.z;
  r9.z = dot(r7.xyzw, r8.xyzw);
  r8.w = 1;
  r8.x = r10.w;
  r4.xyzw = r10.xyzw * r0.zzzz + r4.xyzw;
  r8.y = r11.w;
  r5.xyzw = r11.xyzw * r0.zzzz + r5.xyzw;
  r8.z = r12.w;
  r6.xyzw = r12.xyzw * r0.zzzz + r6.xyzw;
  r9.w = dot(r7.xyzw, r8.xyzw);
  r3.xyzw = r9.xyzw * r0.zzzz + r3.xyzw;
  r8.x = t0[r1.w].val[48/4];
  r8.y = t0[r1.w].val[48/4+1];
  r8.z = t0[r1.w].val[48/4+3];
  r8.w = t0[r1.w].val[48/4+2];
  r9.w = r8.x;
  r10.x = t0[r1.w].val[0/4+3];
  r10.y = t0[r1.w].val[0/4];
  r10.z = t0[r1.w].val[0/4+1];
  r10.w = t0[r1.w].val[0/4+2];
  r9.x = r10.y;
  r11.x = t0[r1.w].val[16/4];
  r11.y = t0[r1.w].val[16/4+1];
  r11.z = t0[r1.w].val[16/4+2];
  r11.w = t0[r1.w].val[16/4+3];
  r1.x = t0[r1.w].val[32/4];
  r1.y = t0[r1.w].val[32/4+1];
  r1.z = t0[r1.w].val[32/4+2];
  r1.w = t0[r1.w].val[32/4+3];
  r9.y = r11.x;
  r9.z = r1.x;
  r9.x = dot(r7.xyzw, r9.xyzw);
  r12.w = r8.y;
  r12.x = r10.z;
  r12.y = r11.y;
  r12.z = r1.y;
  r9.y = dot(r7.xyzw, r12.xyzw);
  r2.w = r8.z;
  r2.xyzw = float4(1,1,1,1) + -r2.xyzw;
  r8.x = r10.w;
  r8.y = r11.z;
  r8.z = r1.z;
  r9.z = dot(r7.xyzw, r8.xyzw);
  r4.xyzw = r10.yzwx * r0.wwww + r4.xyzw;
  r10.y = r11.w;
  r5.xyzw = r11.xyzw * r0.wwww + r5.xyzw;
  r10.z = r1.w;
  r1.xyzw = r1.xyzw * r0.wwww + r6.xyzw;
  r10.w = 1;
  r9.w = dot(r7.xyzw, r10.xyzw);
  r3.xyzw = r9.xyzw * r0.wwww + r3.xyzw;
  o0.w = dot(r3.xyzw, v8.xyzw);
  o0.x = saturate(v4.z);
  o0.y = 0;
  r0.xy = r2.xy * r0.xy;
  r0.x = r0.x + r0.y;
  r0.x = r2.z * r0.z + r0.x;
  r0.x = r2.w * r0.w + r0.x;
  o0.z = saturate(5 * r0.x);
  o1.xy = v3.xy;
  o1.zw = v7.xy;
  o2.w = dot(r3.xyzw, v9.xyzw);
  r0.x = dot(r4.xyzw, v8.xyzw);
  r0.y = dot(r5.xyzw, v8.xyzw);
  r0.z = dot(r1.xyzw, v8.xyzw);
  r2.xyz = v4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r6.xyzw = v5.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r7.xyz = r6.yzx * r2.zxy;
  r7.xyz = r2.yzx * r6.zxy + -r7.xyz;
  r7.xyz = r7.xyz * r6.www;
  r0.w = dot(r7.xyz, r7.xyz);
  r0.w = rsqrt(r0.w);
  r7.xyz = r7.xyz * r0.www;
  r8.x = dot(r7.xyz, r0.xyz);
  r9.x = dot(r4.xyzw, v9.xyzw);
  r4.x = dot(r4.xyzw, v10.xyzw);
  r9.y = dot(r5.xyzw, v9.xyzw);
  r4.y = dot(r5.xyzw, v10.xyzw);
  r9.z = dot(r1.xyzw, v9.xyzw);
  r4.z = dot(r1.xyzw, v10.xyzw);
  r8.y = dot(r7.xyz, r9.xyz);
  r8.z = dot(r7.xyz, r4.xyz);
  r0.w = dot(r8.xyz, r8.xyz);
  r0.w = rsqrt(r0.w);
  o2.xyz = r8.xyz * r0.www;
  r1.x = dot(r2.xyz, r0.xyz);
  r0.x = dot(r6.xyz, r0.xyz);
  r1.y = dot(r2.xyz, r9.xyz);
  r0.y = dot(r6.xyz, r9.xyz);
  r0.z = dot(r6.xyz, r4.xyz);
  r1.z = dot(r2.xyz, r4.xyz);
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  o3.xyz = r1.xyz * r0.www;
  o3.w = dot(r3.xyzw, v10.xyzw);
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  o4.xyz = r0.xyz * r0.www;
  r0.xyzw = cb1[0].yyyy * v9.xyzw;
  r0.xyzw = v8.xyzw * cb1[0].xxxx + r0.xyzw;
  r0.xyzw = v10.xyzw * cb1[0].zzzz + r0.xyzw;
  r0.xyzw = cb1[0].wwww * float4(0,0,0,1) + r0.xyzw;
  o5.x = dot(r3.xyzw, r0.xyzw);
  r0.xyzw = cb1[1].yyyy * v9.xyzw;
  r0.xyzw = v8.xyzw * cb1[1].xxxx + r0.xyzw;
  r0.xyzw = v10.xyzw * cb1[1].zzzz + r0.xyzw;
  r0.xyzw = cb1[1].wwww * float4(0,0,0,1) + r0.xyzw;
  o5.y = dot(r3.xyzw, r0.xyzw);
  r0.xyzw = cb1[2].yyyy * v9.xyzw;
  r0.xyzw = v8.xyzw * cb1[2].xxxx + r0.xyzw;
  r0.xyzw = v10.xyzw * cb1[2].zzzz + r0.xyzw;
  r0.xyzw = cb1[2].wwww * float4(0,0,0,1) + r0.xyzw;
  o5.z = dot(r3.xyzw, r0.xyzw);
  r0.xyzw = cb1[3].yyyy * v9.xyzw;
  r0.xyzw = v8.xyzw * cb1[3].xxxx + r0.xyzw;
  r0.xyzw = v10.xyzw * cb1[3].zzzz + r0.xyzw;
  r0.xyzw = cb1[3].wwww * float4(0,0,0,1) + r0.xyzw;
  o5.w = dot(r3.xyzw, r0.xyzw);
  previous_clip = PreviousObjectClip(v0 * cb2[4].xyz + cb2[5].xyz, v1, v2, v12, 1.f, motion_instance, motion_history);
  return;
}