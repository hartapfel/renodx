// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[17];
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
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
  r2.x = dot(r2.xyz, r2.xyz);
  r2.x = sqrt(r2.x);
  r2.x = saturate(cb4[3].x + -r2.x);
  r2.yzw = t3.Sample(s0_s, v1.xy).yxz;
  r3.xy = cb4[4].xy * v1.xy;
  r4.x = -abs(cb4[5].x) + 1;
  r4.y = cb4[5].x;
  r5.x = dot(r4.xy, r3.xy);
  r4.z = -cb4[5].x;
  r5.y = dot(r4.zx, r3.xy);
  r3.xyzw = t4.Sample(s0_s, r5.xy).xyzw;
  r4.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r3.wxyz;
  r3.x = 0.5 * r4.x;
  r6.xyz = float3(-0.550000012,-1,-0.5) + r2.wzw;
  r2.z = saturate(2.22222233 * r6.x);
  r3.y = 0.449999988 + -r2.w;
  r3.y = saturate(2.22222233 * r3.y);
  r3.z = r3.x * r3.y;
  r3.z = r1.x * r2.z + r3.z;
  r3.z = r3.z * r2.x;
  r0.w = saturate(r3.z * cb4[2].x + r0.w);
  r3.z = cb4[6].x * cb4[2].x;
  r3.x = -r3.x * r3.y;
  r1.x = -r1.x * r2.z + r3.x;
  r1.x = r1.x * r2.x;
  r1.x = r1.x * r3.z + 1;
  r1.x = max(0, r1.x);
  r5.xyzw = t5.Sample(s0_s, r5.xy).xyzw;
  r2.z = saturate(r2.w + r2.w);
  r7.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r2.z = 1 + -r2.z;
  r5.xyzw = float4(-1,-1,-1,-1) + r5.xyzw;
  r5.xyzw = r2.zzzz * r5.xyzw + float4(1,1,1,1);
  r5.xyzw = r5.xyzw * r7.xyzw;
  r3.xyz = log2(r5.xyz);
  r3.xyz = float3(2.20000005,2.20000005,2.20000005) * r3.xyz;
  r5.xyz = exp2(r3.xyz);
  r5.xyzw = r5.xyzw * r1.xxxx;
  r3.x = cmp(0 < cb4[9].x);
  if (r3.x != 0) {
    r3.xyz = log2(r5.xzy);
    r3.xyz = float3(0.454544991,0.454544991,0.454544991) * r3.xyz;
    r3.xyz = exp2(r3.xyz);
    r4.x = r3.x + r3.y;
    r6.xw = r3.xy / r4.xx;
    r6.xw = float2(-0.300000012,-0.300000012) + r6.xw;
    r6.xw = saturate(float2(1.42857146,1.42857146) * r6.xw);
    r4.x = cmp(0 < cb4[7].x);
    if (r4.x != 0) {
      r4.x = r6.x + r6.w;
      r4.x = r6.w / r4.x;
      r6.x = 1 + -r4.x;
      r7.xyzw = cb2[11].zyxw * r4.xxxx;
      r8.xyzw = cb2[12].zyxw * r4.xxxx;
      r9.xyzw = cb2[13].zyxw * r4.xxxx;
      r7.xyzw = r6.xxxx * cb2[7].xyzw + r7.xyzw;
      r8.xyzw = r6.xxxx * cb2[8].xyzw + r8.xyzw;
      r9.xyzw = r6.xxxx * cb2[9].xyzw + r9.xyzw;
    } else {
      r4.x = cmp(r3.x >= r3.y);
      r7.xyzw = r4.xxxx ? cb2[7].xyzw : cb2[11].zyxw;
      r8.xyzw = r4.xxxx ? cb2[8].xyzw : cb2[12].zyxw;
      r9.xyzw = r4.xxxx ? cb2[9].xyzw : cb2[13].zyxw;
    }
    r4.x = min(r3.z, r3.y);
    r4.x = min(r4.x, r3.x);
    r3.y = max(r3.z, r3.y);
    r3.x = max(r3.x, r3.y);
    r3.y = cmp(0 < cb4[8].x);
    if (r3.y != 0) {
      r3.y = r3.x + -r4.x;
      r3.x = r3.y / r3.x;
      r3.x = -0.100000001 + r3.x;
      r3.x = saturate(5 * r3.x);
      r2.y = r3.x * r2.y;
    }
    r3.xyz = log2(r5.xyz);
    r3.xyz = float3(0.454544991,0.454544991,0.454544991) * r3.xyz;
    r5.xyz = exp2(r3.xyz);
    r3.x = dot(r5.xyzw, r7.xyzw);
    r3.y = dot(r5.xyzw, r8.xyzw);
    r3.z = dot(r5.xyzw, r9.xyzw);
    r3.xyz = r3.xyz + -r5.xyz;
    r3.xyz = r2.yyy * r3.xyz + r5.xyz;
  } else {
    r5.xyz = log2(r5.xyz);
    r5.xyz = float3(0.454544991,0.454544991,0.454544991) * r5.xyz;
    r3.xyz = exp2(r5.xyz);
  }
  r2.y = saturate(cb4[10].x);
  r2.y = r2.y * r6.y + 1;
  r3.xyz = r3.xyz * r2.yyy;
  r2.y = max(r3.y, r3.z);
  r2.y = max(r3.x, r2.y);
  r2.y = cmp(0.219999999 < r2.y);
  r2.y = r2.y ? -0.300000012 : -0.149999976;
  r2.y = v0.z * r2.y + 1;
  o0.xyz = r3.xyz * r2.yyy;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r1.yzw = r1.yzw + r1.yzw;
  r3.xyz = r4.yzw + r4.yzw;
  r2.x = cb4[2].x * r2.x;
  r2.y = -0.0500000007 + abs(r6.z);
  r2.y = saturate(2.22222233 * r2.y);
  r2.x = r2.x * r2.y;
  r2.y = cmp(0.5 < r2.w);
  r1.yzw = r2.yyy ? r1.yzw : r3.xyz;
  r3.xyz = r1.www * r0.xyz;
  r0.xy = r2.xx * r1.yz;
  r3.xy = r0.xy * r0.zz + r3.xy;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r3.xyz * r0.xxx;
  r3.x = v0.w;
  r3.yz = v1.zw;
  r1.yzw = r3.xyz * r0.yyy;
  r1.yzw = v4.xyz * r0.xxx + r1.yzw;
  r0.xyz = v2.xyz * r0.zzz + r1.yzw;
  r1.y = cmp(0 >= (uint)v5.x);
  if (r1.y != 0) {
    r1.y = dot(v2.xyz, r0.xyz);
    r1.yzw = v2.xyz * r1.yyy;
    r0.xyz = -r1.yzw * float3(2,2,2) + r0.xyz;
  }
  r1.y = 1 + -r3.w;
  r1.y = r2.z * r1.y;
  r1.y = saturate(7 * r1.y);
  r1.yzw = cb4[11].xyz * r1.yyy;
  r1.yzw = saturate(r1.yzw * cb4[12].xxx + cb4[13].xxx);
  r1.yzw = log2(r1.yzw);
  r1.yzw = float3(2.20000005,2.20000005,2.20000005) * r1.yzw;
  r1.yzw = exp2(r1.yzw);
  r1.xyz = r1.xxx * r1.yzw;
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r1.w = max(r1.y, r1.z);
  r1.w = max(r1.x, r1.w);
  r1.w = cmp(0.200000003 < r1.w);
  r2.xyz = r1.www ? r1.xyz : float3(0.119999997,0.119999997,0.119999997);
  r2.xyz = r2.xyz + -r1.xyz;
  o2.xyz = v0.zzz * r2.xyz + r1.xyz;
  r1.x = cb4[15].x + -cb4[14].x;
  r0.w = saturate(r0.w * r1.x + cb4[14].x);
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
  o0.w = cb4[16].x;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}