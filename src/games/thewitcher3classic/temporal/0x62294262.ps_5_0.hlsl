// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[11];
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
  float3 v3 : TEXCOORD3,
  float4 motion_position : SV_Position,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v4 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = cb1[8].xyz + -v2.xyz;
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = sqrt(r0.x);
  r0.x = saturate(cb4[0].x + -r0.x);
  r0.yz = cb4[1].xy * v0.xy;
  r1.x = -abs(cb4[2].x) + 1;
  r1.y = cb4[2].x;
  r2.x = dot(r1.xy, r0.yz);
  r1.z = -cb4[2].x;
  r2.y = dot(r1.zx, r0.yz);
  r1.xyzw = t2.Sample(s0_s, r2.xy).xyzw;
  r0.yzw = t3.Sample(s0_s, v0.xy).yxz;
  r0.zw = float2(-0.5,-1) + r0.wz;
  r0.z = r0.z + r0.z;
  r0.z = cb4[3].x * abs(r0.z);
  r2.x = 0.25 * r0.z;
  r1.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r1.wxyz;
  r1.x = r2.x * r1.x;
  r2.xyzw = t0.Sample(s0_s, v0.xy).xyzw;
  r3.xy = r0.xx * r1.xx + r2.xz;
  r3.z = cmp(0 < cb4[4].x);
  if (r3.z != 0) {
    r3.z = r3.x + r3.y;
    r3.zw = r3.xy / r3.zz;
    r3.zw = float2(-0.300000012,-0.300000012) + r3.zw;
    r3.zw = saturate(float2(1.42857146,1.42857146) * r3.zw);
    r3.z = r3.z + r3.w;
    r3.z = r3.w / r3.z;
    r3.w = 1 + -r3.z;
    r4.xyzw = cb2[11].zyxw * r3.zzzz;
    r5.xyzw = cb2[12].zyxw * r3.zzzz;
    r6.xyzw = cb2[13].zyxw * r3.zzzz;
    r4.xyzw = r3.wwww * cb2[7].xyzw + r4.xyzw;
    r5.xyzw = r3.wwww * cb2[8].xyzw + r5.xyzw;
    r6.xyzw = r3.wwww * cb2[9].xyzw + r6.xyzw;
  } else {
    r3.z = cmp(r3.x >= r3.y);
    r4.xyzw = r3.zzzz ? cb2[7].xyzw : cb2[11].zyxw;
    r5.xyzw = r3.zzzz ? cb2[8].xyzw : cb2[12].zyxw;
    r6.xyzw = r3.zzzz ? cb2[9].xyzw : cb2[13].zyxw;
  }
  r3.z = cmp(0 < cb4[5].x);
  if (r3.z != 0) {
    r3.z = r0.x * r1.x + r2.y;
    r3.w = min(r3.z, r3.y);
    r3.w = min(r3.x, r3.w);
    r3.y = max(r3.z, r3.y);
    r3.x = max(r3.x, r3.y);
    r3.y = r3.x + -r3.w;
    r3.x = r3.y / r3.x;
    r3.x = -0.100000001 + r3.x;
    r3.x = saturate(5 * r3.x);
    r0.y = r3.x * r0.y;
  }
  r2.xyzw = r0.xxxx * r1.xxxx + r2.xyzw;
  r3.x = dot(r2.xyzw, r4.xyzw);
  r3.y = dot(r2.xyzw, r5.xyzw);
  r3.z = dot(r2.xyzw, r6.xyzw);
  r3.xyz = r3.xyz + -r2.xyz;
  r2.xyz = r0.yyy * r3.xyz + r2.xyz;
  r0.y = saturate(cb4[6].x);
  r0.y = r0.y * r0.w + 1;
  o0.xyz = r2.xyz * r0.yyy;
  r2.xyzw = t4.Sample(s0_s, v0.xy).xyzw;
  r2.xyz = float3(-0.5,-0.5,-0.5) + r2.xyz;
  r2.xyz = r2.xyz + r2.xyz;
  r1.yzw = r1.yzw + r1.yzw;
  r0.x = r0.z * r0.x;
  r0.yzw = r2.xyz * r1.www;
  r1.yz = r0.xx * r1.yz;
  r0.yz = r1.yz * r2.zz + r0.yz;
  r1.yzw = v1.xyz * r0.zzz;
  r2.xy = v0.zw;
  r2.z = v1.w;
  r1.yzw = v3.xyz * r0.yyy + r1.yzw;
  r0.yzw = r2.xyz * r0.www + r1.yzw;
  r1.y = cmp(0 >= (uint)v4.x);
  if (r1.y != 0) {
    r1.y = dot(r2.xyz, r0.yzw);
    r1.yzw = r2.xyz * r1.yyy;
    r0.yzw = -r1.yzw * float3(2,2,2) + r0.yzw;
  }
  r0.x = saturate(r0.x * r1.x + r2.w);
  r1.x = 1 + -r0.x;
  r1.yzw = log2(cb4[7].xyz);
  r1.yzw = float3(2.20000005,2.20000005,2.20000005) * r1.yzw;
  r1.yzw = exp2(r1.yzw);
  r1.x = r1.x * cb4[8].x + cb4[9].x;
  r1.xyz = saturate(r1.yzw * r1.xxx);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
  o2.xyz = exp2(r1.xyz);
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r0.yzw = r1.xxx * r0.yzw;
  r1.x = max(abs(r0.y), abs(r0.z));
  r1.x = max(r1.x, abs(r0.w));
  r1.yz = cmp(abs(r0.wz) < r1.xx);
  r1.zw = r1.zz ? abs(r0.wz) : abs(r0.wy);
  r1.yz = r1.yy ? r1.zw : abs(r0.zy);
  r1.w = cmp(r1.z < r1.y);
  r2.xy = r1.ww ? r1.yz : r1.zy;
  r2.z = r2.y / r2.x;
  r0.yzw = r0.yzw / r1.xxx;
  r1.x = t13.SampleLevel(s13_s, r2.xz, 0).x;
  r0.yzw = r1.xxx * r0.yzw;
  o1.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = cb4[10].x;
  o1.w = r0.x;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}