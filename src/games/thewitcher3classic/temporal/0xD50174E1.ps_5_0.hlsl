// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[19];
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
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t1.Sample(s0_s, v1.xy).xyzw;
  r1.xy = cb4[0].xy * v1.xy;
  r2.x = -abs(cb4[1].x) + 1;
  r2.y = cb4[1].x;
  r3.x = dot(r2.xy, r1.xy);
  r2.z = -cb4[1].x;
  r3.y = dot(r2.zx, r1.xy);
  r1.xyzw = t2.Sample(s0_s, r3.xy).xyzw;
  r1.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r1.wxyz;
  r1.x = 0.5 * r1.x;
  r2.xyz = cb1[8].xyz + -v3.xyz;
  r2.w = dot(r2.xyz, r2.xyz);
  r3.x = sqrt(r2.w);
  r3.x = saturate(cb4[3].x + -r3.x);
  r3.yzw = t3.Sample(s0_s, v1.xy).yxz;
  r4.xy = cb4[4].xy * v1.xy;
  r5.x = -abs(cb4[5].x) + 1;
  r5.y = cb4[5].x;
  r6.x = dot(r5.xy, r4.xy);
  r5.z = -cb4[5].x;
  r6.y = dot(r5.zx, r4.xy);
  r4.xyzw = t4.Sample(s0_s, r6.xy).xyzw;
  r4.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r4.wxyz;
  r4.x = 0.5 * r4.x;
  r5.x = cb4[2].x * v0.z;
  r5.x = r5.x * -0.600000024 + cb4[2].x;
  r5.yzw = float3(-0.550000012,-0.5,-1) + r3.wwz;
  r3.z = saturate(2.22222233 * r5.y);
  r5.y = 0.449999988 + -r3.w;
  r5.y = saturate(2.22222233 * r5.y);
  r6.x = r5.y * r4.x;
  r6.x = r1.x * r3.z + r6.x;
  r6.x = r6.x * r3.x;
  r0.w = saturate(r6.x * r5.x + r0.w);
  r6.x = cb4[6].x * r5.x;
  r4.x = r5.y * -r4.x;
  r1.x = -r1.x * r3.z + r4.x;
  r1.x = r1.x * r3.x;
  r1.x = r1.x * r6.x + 1;
  r1.x = max(0, r1.x);
  r6.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r7.xyz = log2(r6.xyz);
  r7.xyz = float3(2.20000005,2.20000005,2.20000005) * r7.xyz;
  r6.xyz = exp2(r7.xyz);
  r6.xyzw = r6.xyzw * r1.xxxx;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r1.xyz = r1.yzw + r1.yzw;
  r4.xyz = r4.yzw + r4.yzw;
  r1.w = r5.x * r3.x;
  r3.x = -0.0500000007 + abs(r5.z);
  r3.x = saturate(2.22222233 * r3.x);
  r1.w = r3.x * r1.w;
  r3.x = cmp(0.5 < r3.w);
  r1.xyz = r3.xxx ? r1.xyz : r4.xyz;
  r3.xzw = r1.zzz * r0.xyz;
  r0.xy = r1.ww * r1.xy;
  r3.xz = r0.xy * r0.zz + r3.xz;
  r0.x = dot(r3.xzw, r3.xzw);
  r0.x = rsqrt(r0.x);
  r0.xyz = r3.xzw * r0.xxx;
  r1.x = v0.w;
  r1.yz = v1.zw;
  r1.xyz = r1.xyz * r0.yyy;
  r1.xyz = v4.xyz * r0.xxx + r1.xyz;
  r0.xyz = v2.xyz * r0.zzz + r1.xyz;
  r1.x = rsqrt(r2.w);
  r1.xyz = r2.xyz * r1.xxx;
  r1.x = dot(r0.xyz, r1.xyz);
  r1.x = saturate(1 + -r1.x);
  r1.x = log2(r1.x);
  r1.x = cb4[7].x * r1.x;
  r1.x = exp2(r1.x);
  r1.y = cmp(0 < cb4[11].x);
  if (r1.y != 0) {
    r1.yzw = log2(r6.xzy);
    r1.yzw = float3(0.454544991,0.454544991,0.454544991) * r1.yzw;
    r1.yzw = exp2(r1.yzw);
    r1.yzw = r1.xxx * cb4[8].xxx + r1.yzw;
    r2.x = r1.y + r1.z;
    r2.xy = r1.yz / r2.xx;
    r2.xy = float2(-0.300000012,-0.300000012) + r2.xy;
    r2.xy = saturate(float2(1.42857146,1.42857146) * r2.xy);
    r2.z = cmp(0 < cb4[9].x);
    if (r2.z != 0) {
      r2.x = r2.x + r2.y;
      r2.x = r2.y / r2.x;
      r2.y = 1 + -r2.x;
      r4.xyzw = cb2[11].zyxw * r2.xxxx;
      r7.xyzw = cb2[12].zyxw * r2.xxxx;
      r8.xyzw = cb2[13].zyxw * r2.xxxx;
      r4.xyzw = r2.yyyy * cb2[7].xyzw + r4.xyzw;
      r7.xyzw = r2.yyyy * cb2[8].xyzw + r7.xyzw;
      r2.xyzw = r2.yyyy * cb2[9].xyzw + r8.xyzw;
    } else {
      r3.x = cmp(r1.y >= r1.z);
      r4.xyzw = r3.xxxx ? cb2[7].xyzw : cb2[11].zyxw;
      r7.xyzw = r3.xxxx ? cb2[8].xyzw : cb2[12].zyxw;
      r2.xyzw = r3.xxxx ? cb2[9].xyzw : cb2[13].zyxw;
    }
    r3.x = min(r1.w, r1.z);
    r3.x = min(r3.x, r1.y);
    r1.z = max(r1.w, r1.z);
    r1.y = max(r1.y, r1.z);
    r1.z = cmp(0 < cb4[10].x);
    if (r1.z != 0) {
      r1.z = r1.y + -r3.x;
      r1.y = r1.z / r1.y;
      r1.y = -0.100000001 + r1.y;
      r1.y = saturate(5 * r1.y);
      r3.y = r3.y * r1.y;
    }
    r1.yzw = log2(r6.xyz);
    r1.yzw = float3(0.454544991,0.454544991,0.454544991) * r1.yzw;
    r6.xyz = exp2(r1.yzw);
    r8.xyzw = r1.xxxx * cb4[8].xxxx + r6.xyzw;
    r4.x = dot(r8.xyzw, r4.xyzw);
    r4.y = dot(r8.xyzw, r7.xyzw);
    r4.z = dot(r8.xyzw, r2.xyzw);
    r1.yzw = r4.xyz + -r8.xyz;
    r1.yzw = r3.yyy * r1.yzw + r8.xyz;
  } else {
    r2.xyz = log2(r6.xyz);
    r2.xyz = float3(0.454544991,0.454544991,0.454544991) * r2.xyz;
    r2.xyz = exp2(r2.xyz);
    r1.yzw = r1.xxx * cb4[8].xxx + r2.xyz;
  }
  r1.x = saturate(cb4[12].x);
  r1.x = r1.x * r5.w + 1;
  r1.xyz = r1.yzw * r1.xxx;
  r1.w = max(r1.y, r1.z);
  r1.w = max(r1.x, r1.w);
  r1.w = cmp(0.219999999 < r1.w);
  r1.w = r1.w ? -0.300000012 : -0.149999976;
  r1.w = v0.z * r1.w + 1;
  o0.xyz = r1.xyz * r1.www;
  r1.x = cmp(0 >= (uint)v5.x);
  if (r1.x != 0) {
    r1.x = dot(v2.xyz, r0.xyz);
    r1.xyz = v2.xyz * r1.xxx;
    r0.xyz = -r1.xyz * float3(2,2,2) + r0.xyz;
  }
  r1.x = 1 + -r0.w;
  r1.yzw = log2(cb4[13].xyz);
  r1.yzw = float3(2.20000005,2.20000005,2.20000005) * r1.yzw;
  r1.yzw = exp2(r1.yzw);
  r1.x = r1.x * cb4[14].x + cb4[15].x;
  r1.xyz = saturate(r1.yzw * r1.xxx);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r1.w = max(r1.y, r1.z);
  r1.w = max(r1.x, r1.w);
  r1.w = cmp(0.200000003 < r1.w);
  r2.xyz = r1.www ? r1.xyz : float3(0.119999997,0.119999997,0.119999997);
  r2.xyz = r2.xyz + -r1.xyz;
  o2.xyz = v0.zzz * r2.xyz + r1.xyz;
  r1.x = cb4[17].x + -cb4[16].x;
  r0.w = saturate(r0.w * r1.x + cb4[16].x);
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
  o0.w = cb4[18].x;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}