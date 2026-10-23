// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t6 : register(t6);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[12];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[14];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}




// 3Dmigoto declarations
#define cmp -


#include "./object_pixel.hlsli"

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float3 v4 : TEXCOORD4,
  float4 motion_position : SV_Position,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v5 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t1.Sample(s0_s, v1.xy).xyzw;
  r1.xyz = cb1[8].xyz + -v3.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r1.x = sqrt(r1.x);
  r1.x = -cb4[0].x + r1.x;
  r1.x = saturate(r1.x / -cb4[0].x);
  r1.x = cb4[1].x * r1.x;
  r1.yzw = t2.Sample(s0_s, v1.xy).yxz;
  r2.x = r1.w * 2 + -1;
  r2.xy = saturate(r2.xx);
  r3.xy = cb4[2].xy * v1.xy;
  r4.x = -abs(cb4[3].x) + 1;
  r4.y = cb4[3].x;
  r5.x = dot(r4.xy, r3.xy);
  r4.z = -cb4[3].x;
  r5.y = dot(r4.zx, r3.xy);
  r3.xyzw = t3.Sample(s0_s, r5.xy).xyzw;
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r3.wxyz;
  r2.w = r3.x * r2.y;
  r1.w = 1 + -r1.w;
  r1.w = r1.w * 2 + -1;
  r4.xy = saturate(r1.ww);
  r5.xy = cb4[4].xy * v1.xy;
  r6.x = -abs(cb4[5].x) + 1;
  r6.y = cb4[5].x;
  r7.x = dot(r6.xy, r5.xy);
  r6.z = -cb4[5].x;
  r7.y = dot(r6.zx, r5.xy);
  r5.xyzw = t4.Sample(s0_s, r7.xy).xyzw;
  r5.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r5.wxyz;
  r1.w = r5.x * r4.y;
  r1.w = 0.25 * r1.w;
  r1.w = r2.w * 0.25 + r1.w;
  r2.w = saturate(cb4[6].x);
  r6.xyzw = t5.Sample(s0_s, v1.xy).xyzw;
  r7.xy = r1.xx * r1.ww + r6.xz;
  r3.x = cmp(0 < cb4[7].x);
  if (r3.x != 0) {
    r3.x = r7.x + r7.y;
    r7.zw = r7.xy / r3.xx;
    r7.zw = float2(-0.300000012,-0.300000012) + r7.zw;
    r7.zw = saturate(float2(1.42857146,1.42857146) * r7.zw);
    r3.x = r7.z + r7.w;
    r3.x = r7.w / r3.x;
    r4.w = 1 + -r3.x;
    r8.xyzw = cb2[11].zyxw * r3.xxxx;
    r9.xyzw = cb2[12].zyxw * r3.xxxx;
    r10.xyzw = cb2[13].zyxw * r3.xxxx;
    r8.xyzw = r4.wwww * cb2[7].xyzw + r8.xyzw;
    r9.xyzw = r4.wwww * cb2[8].xyzw + r9.xyzw;
    r10.xyzw = r4.wwww * cb2[9].xyzw + r10.xyzw;
  } else {
    r3.x = cmp(r7.x >= r7.y);
    r8.xyzw = r3.xxxx ? cb2[7].xyzw : cb2[11].zyxw;
    r9.xyzw = r3.xxxx ? cb2[8].xyzw : cb2[12].zyxw;
    r10.xyzw = r3.xxxx ? cb2[9].xyzw : cb2[13].zyxw;
  }
  r3.x = cmp(0 < cb4[8].x);
  if (r3.x != 0) {
    r3.x = r1.x * r1.w + r6.y;
    r4.w = min(r3.x, r7.y);
    r4.w = min(r7.x, r4.w);
    r3.x = max(r3.x, r7.y);
    r3.x = max(r7.x, r3.x);
    r4.w = r3.x + -r4.w;
    r3.x = r4.w / r3.x;
    r3.x = -0.100000001 + r3.x;
    r3.x = saturate(5 * r3.x);
    r1.y = r3.x * r1.y;
  }
  r6.xyzw = r1.xxxx * r1.wwww + r6.xyzw;
  r7.x = dot(r6.xyzw, r8.xyzw);
  r7.y = dot(r6.xyzw, r9.xyzw);
  r7.z = dot(r6.xyzw, r10.xyzw);
  r7.xyz = r7.xyz + -r6.xyz;
  r6.xyz = r1.yyy * r7.xyz + r6.xyz;
  r1.y = -1 + r1.z;
  r1.y = r2.w * r1.y + 1;
  r6.xyz = r1.yyy * r6.xyz;
  r1.y = max(r6.y, r6.z);
  r1.y = max(r6.x, r1.y);
  r1.y = cmp(0.219999999 < r1.y);
  r1.y = r1.y ? -0.300000012 : -0.149999976;
  r1.y = v0.z * r1.y + 1;
  o0.xyz = r6.xyz * r1.yyy;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r2.z = 2;
  r2.xyz = r3.yzw * r2.xyz;
  r4.z = 2;
  r3.xyz = r5.yzw * r4.xyz;
  r4.x = dot(r3.zzxx, r2.xxzz);
  r4.y = dot(r3.zzyy, r2.yyzz);
  r4.z = r3.z * r2.z;
  r1.y = dot(r4.xyz, r4.xyz);
  r1.y = rsqrt(r1.y);
  r2.xyz = r4.zxy * r1.yyy;
  r3.xyz = r2.xxx * r0.xyz;
  r0.xy = r2.yz * r1.xx;
  r3.xy = r0.xy * r0.zz + r3.xy;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = rsqrt(r0.x);
  r0.yz = r3.xy * r0.xx;
  r2.x = v0.w;
  r2.yz = v1.zw;
  r2.xyz = r2.xyz * r0.zzz;
  r0.x = r3.z * r0.x;
  r2.xyz = v4.xyz * r0.yyy + r2.xyz;
  r0.xyz = v2.xyz * r0.xxx + r2.xyz;
  r1.y = cmp(0 >= (uint)v5.x);
  if (r1.y != 0) {
    r1.y = dot(v2.xyz, r0.xyz);
    r2.xyz = v2.xyz * r1.yyy;
    r0.xyz = -r2.xyz * float3(2,2,2) + r0.xyz;
  }
  r2.xyz = t6.Sample(s0_s, v1.xy).xyz;
  r2.xyz = saturate(r2.xyz * cb4[9].xxx + cb4[10].xxx);
  r2.xyz = r1.xxx * r1.www + r2.xyz;
  r1.y = max(r2.y, r2.z);
  r1.y = max(r2.x, r1.y);
  r1.y = cmp(0.200000003 < r1.y);
  r3.xyz = r1.yyy ? r2.xyz : float3(0.119999997,0.119999997,0.119999997);
  r3.xyz = r3.xyz + -r2.xyz;
  o2.xyz = v0.zzz * r3.xyz + r2.xyz;
  r0.w = r1.x * r1.w + r0.w;
  r1.x = cmp(r0.w < 0.330000013);
  r1.y = 0.949999988 * r0.w;
  r1.x = r1.x ? r1.y : 0.330000013;
  r1.x = r1.x + -r0.w;
  o1.w = v0.z * r1.x + r0.w;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = max(abs(r0.x), abs(r0.y));
  r0.w = max(abs(r0.z), r0.w);
  r1.xy = cmp(abs(r0.zy) < r0.ww);
  r1.yz = r1.yy ? abs(r0.zy) : abs(r0.zx);
  r1.xy = r1.xx ? r1.yz : abs(r0.yx);
  r1.z = cmp(r1.y < r1.x);
  r1.xy = r1.zz ? r1.xy : r1.yx;
  r1.z = r1.y / r1.x;
  r0.xyz = r0.xyz / r0.www;
  r0.w = t13.SampleLevel(s13_s, r1.xz, 0).x;
  r0.xyz = r0.xyz * r0.www;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = cb4[11].x;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}