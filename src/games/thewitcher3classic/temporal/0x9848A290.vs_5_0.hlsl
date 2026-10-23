// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:06:33 2026
struct t0_t {
  float val[16];
};
StructuredBuffer<t0_t> t0 : register(t0);

cbuffer cb12 : register(b12)
{
  float4 cb12[193];
}

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
  out float4 o4 : TEXCOORD4,
  out float3 o5 : TEXCOORD5,
  out float4 o6 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r1.x = v2.x + v2.y;
  r1.x = v2.z + r1.x;
  r1.x = v2.w + r1.x;
  r2.xyzw = (uint4)v1.xyzw;
  r2.xyzw = r2.xyzw * v12.yyyy + v12.xxxx;
  r2.xyzw = (uint4)r2.xyzw;
  r3.x = t0[r2.x].val[48/4];
  r3.y = t0[r2.x].val[48/4+1];
  r3.w = t0[r2.x].val[48/4+2];
  r4.x = t0[r2.x].val[0/4];
  r4.y = t0[r2.x].val[0/4+1];
  r4.z = t0[r2.x].val[0/4+2];
  r4.w = t0[r2.x].val[0/4+3];
  r5.x = t0[r2.x].val[16/4];
  r5.y = t0[r2.x].val[16/4+1];
  r5.z = t0[r2.x].val[16/4+2];
  r5.w = t0[r2.x].val[16/4+3];
  r6.x = t0[r2.x].val[32/4];
  r6.y = t0[r2.x].val[32/4+1];
  r6.z = t0[r2.x].val[32/4+2];
  r6.w = t0[r2.x].val[32/4+3];
  r0.w = 1;
  r7.x = r4.x;
  r7.y = r5.x;
  r7.z = r6.x;
  r7.w = r3.x;
  r7.x = dot(r0.xyzw, r7.xyzw);
  r8.x = r4.y;
  r8.y = r5.y;
  r8.z = r6.y;
  r8.w = r3.y;
  r7.y = dot(r0.xyzw, r8.xyzw);
  r3.x = r4.z;
  r3.y = r5.z;
  r3.z = r6.z;
  r7.z = dot(r0.xyzw, r3.xyzw);
  r3.x = r4.w;
  r3.y = r5.w;
  r3.z = r6.w;
  r3.w = 1;
  r7.w = dot(r0.xyzw, r3.xyzw);
  r1.xyzw = v2.xyzw / r1.xxxx;
  r3.x = t0[r2.y].val[48/4];
  r3.y = t0[r2.y].val[48/4+1];
  r3.w = t0[r2.y].val[48/4+2];
  r8.x = t0[r2.y].val[0/4];
  r8.y = t0[r2.y].val[0/4+1];
  r8.z = t0[r2.y].val[0/4+2];
  r8.w = t0[r2.y].val[0/4+3];
  r9.x = t0[r2.y].val[16/4];
  r9.y = t0[r2.y].val[16/4+1];
  r9.z = t0[r2.y].val[16/4+2];
  r9.w = t0[r2.y].val[16/4+3];
  r10.x = t0[r2.y].val[32/4];
  r10.y = t0[r2.y].val[32/4+1];
  r10.z = t0[r2.y].val[32/4+2];
  r10.w = t0[r2.y].val[32/4+3];
  r11.x = r8.x;
  r11.y = r9.x;
  r11.z = r10.x;
  r11.w = r3.x;
  r11.x = dot(r0.xyzw, r11.xyzw);
  r12.x = r8.y;
  r12.y = r9.y;
  r12.z = r10.y;
  r12.w = r3.y;
  r11.y = dot(r0.xyzw, r12.xyzw);
  r3.x = r8.z;
  r3.y = r9.z;
  r3.z = r10.z;
  r11.z = dot(r0.xyzw, r3.xyzw);
  r3.x = r8.w;
  r3.y = r9.w;
  r3.z = r10.w;
  r3.w = 1;
  r11.w = dot(r0.xyzw, r3.xyzw);
  r3.xyzw = r11.xyzw * r1.yyyy;
  r3.xyzw = r7.xyzw * r1.xxxx + r3.xyzw;
  r7.x = t0[r2.z].val[48/4];
  r7.y = t0[r2.z].val[48/4+1];
  r7.w = t0[r2.z].val[48/4+2];
  r11.x = t0[r2.z].val[0/4];
  r11.y = t0[r2.z].val[0/4+1];
  r11.z = t0[r2.z].val[0/4+2];
  r11.w = t0[r2.z].val[0/4+3];
  r12.x = t0[r2.z].val[16/4];
  r12.y = t0[r2.z].val[16/4+1];
  r12.z = t0[r2.z].val[16/4+2];
  r12.w = t0[r2.z].val[16/4+3];
  r13.x = t0[r2.z].val[32/4];
  r13.y = t0[r2.z].val[32/4+1];
  r13.z = t0[r2.z].val[32/4+2];
  r13.w = t0[r2.z].val[32/4+3];
  r14.x = r11.x;
  r14.y = r12.x;
  r14.z = r13.x;
  r14.w = r7.x;
  r14.x = dot(r0.xyzw, r14.xyzw);
  r15.x = r11.y;
  r15.y = r12.y;
  r15.z = r13.y;
  r15.w = r7.y;
  r14.y = dot(r0.xyzw, r15.xyzw);
  r7.x = r11.z;
  r7.y = r12.z;
  r7.z = r13.z;
  r14.z = dot(r0.xyzw, r7.xyzw);
  r7.x = r11.w;
  r7.y = r12.w;
  r7.z = r13.w;
  r7.w = 1;
  r14.w = dot(r0.xyzw, r7.xyzw);
  r3.xyzw = r14.xyzw * r1.zzzz + r3.xyzw;
  r7.x = t0[r2.w].val[48/4];
  r7.y = t0[r2.w].val[48/4+1];
  r7.w = t0[r2.w].val[48/4+2];
  r14.x = t0[r2.w].val[0/4];
  r14.y = t0[r2.w].val[0/4+1];
  r14.z = t0[r2.w].val[0/4+2];
  r14.w = t0[r2.w].val[0/4+3];
  r15.x = t0[r2.w].val[16/4];
  r15.y = t0[r2.w].val[16/4+1];
  r15.z = t0[r2.w].val[16/4+2];
  r15.w = t0[r2.w].val[16/4+3];
  r2.x = t0[r2.w].val[32/4];
  r2.y = t0[r2.w].val[32/4+1];
  r2.z = t0[r2.w].val[32/4+2];
  r2.w = t0[r2.w].val[32/4+3];
  r16.x = r14.x;
  r16.y = r15.x;
  r16.z = r2.x;
  r16.w = r7.x;
  r16.x = dot(r0.xyzw, r16.xyzw);
  r17.x = r14.y;
  r17.y = r15.y;
  r17.z = r2.y;
  r17.w = r7.y;
  r16.y = dot(r0.xyzw, r17.xyzw);
  r7.x = r14.z;
  r7.y = r15.z;
  r7.z = r2.z;
  r16.z = dot(r0.xyzw, r7.xyzw);
  r7.x = r14.w;
  r7.y = r15.w;
  r7.z = r2.w;
  r7.w = 1;
  r16.w = dot(r0.xyzw, r7.xyzw);
  r3.xyzw = r16.xyzw * r1.wwww + r3.xyzw;
  r7.xyzw = r8.xyzw * r1.yyyy;
  r8.xyzw = r9.xyzw * r1.yyyy;
  r9.xyzw = r10.xyzw * r1.yyyy;
  r4.xyzw = r4.xyzw * r1.xxxx + r7.xyzw;
  r5.xyzw = r5.xyzw * r1.xxxx + r8.xyzw;
  r6.xyzw = r6.xyzw * r1.xxxx + r9.xyzw;
  r4.xyzw = r11.xyzw * r1.zzzz + r4.xyzw;
  r5.xyzw = r12.xyzw * r1.zzzz + r5.xyzw;
  r6.xyzw = r13.xyzw * r1.zzzz + r6.xyzw;
  r4.xyzw = r14.xyzw * r1.wwww + r4.xyzw;
  r5.xyzw = r15.xyzw * r1.wwww + r5.xyzw;
  r1.xyzw = r2.xyzw * r1.wwww + r6.xyzw;
  o1.x = dot(r0.xyzw, cb3[7].xyzw);
  o1.y = dot(r0.xyzw, cb3[8].xyzw);
  o1.z = dot(r0.xyzw, cb3[9].xyzw);
  r0.x = dot(r3.xyzw, v8.xyzw);
  r0.y = dot(r3.xyzw, v9.xyzw);
  r0.z = dot(r3.xyzw, v10.xyzw);
  r2.xyzw = cb1[0].yyyy * v9.xyzw;
  r2.xyzw = v8.xyzw * cb1[0].xxxx + r2.xyzw;
  r2.xyzw = v10.xyzw * cb1[0].zzzz + r2.xyzw;
  r2.xyzw = cb1[0].wwww * float4(0,0,0,1) + r2.xyzw;
  r6.xyzw = cb1[1].yyyy * v9.xyzw;
  r6.xyzw = v8.xyzw * cb1[1].xxxx + r6.xyzw;
  r6.xyzw = v10.xyzw * cb1[1].zzzz + r6.xyzw;
  r6.xyzw = cb1[1].wwww * float4(0,0,0,1) + r6.xyzw;
  r7.xyzw = cb1[2].yyyy * v9.xyzw;
  r7.xyzw = v8.xyzw * cb1[2].xxxx + r7.xyzw;
  r7.xyzw = v10.xyzw * cb1[2].zzzz + r7.xyzw;
  r7.xyzw = cb1[2].wwww * float4(0,0,0,1) + r7.xyzw;
  r8.xyzw = cb1[3].yyyy * v9.xyzw;
  r8.xyzw = v8.xyzw * cb1[3].xxxx + r8.xyzw;
  r8.xyzw = v10.xyzw * cb1[3].zzzz + r8.xyzw;
  r8.xyzw = cb1[3].wwww * float4(0,0,0,1) + r8.xyzw;
  o6.x = dot(r3.xyzw, r2.xyzw);
  o6.y = dot(r3.xyzw, r6.xyzw);
  o6.z = dot(r3.xyzw, r7.xyzw);
  o6.w = dot(r3.xyzw, r8.xyzw);
  r2.x = dot(r4.xyzw, v8.xyzw);
  r3.x = dot(r4.xyzw, v9.xyzw);
  r4.x = dot(r4.xyzw, v10.xyzw);
  r2.y = dot(r5.xyzw, v8.xyzw);
  r3.y = dot(r5.xyzw, v9.xyzw);
  r4.y = dot(r5.xyzw, v10.xyzw);
  r2.z = dot(r1.xyzw, v8.xyzw);
  r3.z = dot(r1.xyzw, v9.xyzw);
  r4.z = dot(r1.xyzw, v10.xyzw);
  r1.xyz = v4.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.x = dot(r1.xyz, r2.xyz);
  r2.y = dot(r1.xyz, r3.xyz);
  r2.z = dot(r1.xyz, r4.xyz);
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r2.xyz * r0.www;
  r2.xyz = -cb12[0].xyz + r0.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = sqrt(r0.w);
  r2.xyz = r2.xyz / r0.www;
  r0.w = -cb12[22].z + r0.w;
  r0.w = max(0, r0.w);
  r0.w = min(cb12[42].z, r0.w);
  r1.w = dot(cb12[38].xyz, r2.xyz);
  r2.x = abs(r1.w) * abs(r1.w);
  r2.y = saturate(r0.w * 0.00200000009 + -0.300000012);
  r2.x = r2.x * r2.y;
  r2.y = cmp(0 < r1.w);
  r3.xyz = r2.yyy ? cb12[39].xyz : cb12[41].xyz;
  r3.xyz = -cb12[40].xyz + r3.xyz;
  r3.xyz = r2.xxx * r3.xyz + cb12[40].xyz;
  r4.xyz = r2.yyy ? cb12[45].xyz : cb12[47].xyz;
  r4.xyz = -cb12[46].xyz + r4.xyz;
  o0.xyz = r2.xxx * r4.xyz + cb12[46].xyz;
  r2.x = cmp(r0.w >= cb12[48].y);
  if (r2.x != 0) {
    r2.x = r2.z * cb12[22].z + cb12[0].z;
    r2.y = r2.z * r0.w;
    r2.z = cb12[43].x * r0.w;
    r2.yz = float2(0.0625,0.0625) * r2.yz;
    r1.w = cb12[42].x + r1.w;
    r2.w = 1 + cb12[42].x;
    r1.w = saturate(r1.w / r2.w);
    r2.w = cb12[43].y + -cb12[43].z;
    r1.w = r1.w * r2.w + cb12[43].z;
    r2.x = cb12[42].y + r2.x;
    r2.yw = r2.yx * r1.ww;
    r4.xyzw = r2.yyyy * float4(16,15,14,13) + r2.wwww;
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.zzzz / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r3.w = r4.x * r4.y;
    r3.w = r3.w * r4.z;
    r3.w = r3.w * r4.w;
    r4.xyzw = r2.yyyy * float4(12,11,10,9) + r2.wwww;
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.zzzz / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r3.w = r4.x * r3.w;
    r3.w = r3.w * r4.y;
    r3.w = r3.w * r4.z;
    r3.w = r3.w * r4.w;
    r4.xyzw = r2.yyyy * float4(8,7,6,5) + r2.wwww;
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.zzzz / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r3.w = r4.x * r3.w;
    r3.w = r3.w * r4.y;
    r3.w = r3.w * r4.z;
    r3.w = r3.w * r4.w;
    r4.xy = r2.yy * float2(4,3) + r2.ww;
    r4.xy = max(float2(0,0), r4.xy);
    r4.xy = float2(1,1) + r4.xy;
    r4.xy = saturate(r2.zz / r4.xy);
    r4.xy = float2(1,1) + -r4.xy;
    r3.w = r4.x * r3.w;
    r3.w = r3.w * r4.y;
    r2.w = r2.y * 2 + r2.w;
    r2.w = max(0, r2.w);
    r2.w = 1 + r2.w;
    r2.w = saturate(r2.z / r2.w);
    r2.w = 1 + -r2.w;
    r2.w = r3.w * r2.w;
    r1.w = r2.x * r1.w + r2.y;
    r1.w = max(0, r1.w);
    r1.w = 1 + r1.w;
    r1.w = saturate(r2.z / r1.w);
    r1.w = 1 + -r1.w;
    r1.w = -r2.w * r1.w + 1;
    r0.w = -cb12[48].y + r0.w;
    r0.w = saturate(cb12[48].z * r0.w);
  } else {
    r1.w = 1;
    r0.w = 0;
  }
  r1.w = log2(r1.w);
  r2.x = cb12[42].w * r1.w;
  r2.x = exp2(r2.x);
  r2.x = r2.x * r0.w;
  r1.w = cb12[48].x * r1.w;
  r1.w = exp2(r1.w);
  o0.w = r1.w * r0.w;
  r2.yz = saturate(r2.xx * cb12[189].xz + cb12[189].yw);
  r4.xyz = cb12[188].xyz + -r3.xyz;
  r4.xyz = r2.yyy * r4.xyz + r3.xyz;
  r0.w = -1 + cb12[188].w;
  r0.w = r2.z * r0.w + 1;
  r4.w = saturate(r2.x * r0.w);
  r0.w = cmp(0 < cb12[192].x);
  if (r0.w != 0) {
    r2.yz = saturate(r2.xx * cb12[191].xz + cb12[191].yw);
    r5.xyz = cb12[190].xyz + -r3.xyz;
    r3.xyz = r2.yyy * r5.xyz + r3.xyz;
    r0.w = -1 + cb12[190].w;
    r0.w = r2.z * r0.w + 1;
    r3.w = saturate(r2.x * r0.w);
    r2.xyzw = r3.xyzw + -r4.xyzw;
    o3.xyzw = cb12[192].xxxx * r2.xyzw + r4.xyzw;
  } else {
    o3.xyzw = r4.xyzw;
  }
  o1.w = r1.x;
  o2.xyzw = v11.xyzw;
  o4.xy = v3.xy;
  o4.zw = r1.yz;
  o5.xyz = r0.xyz;
  previous_clip = PreviousObjectClip(v0 * cb2[4].xyz + cb2[5].xyz, v1, v2, v12, 1.f, motion_instance, motion_history);
  return;
}