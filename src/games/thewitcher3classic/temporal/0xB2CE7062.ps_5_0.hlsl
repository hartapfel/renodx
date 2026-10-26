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
  float4 cb4[13];
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
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = t1.Sample(s0_s, v0.xy).yxz;
  r1.xy = cb4[0].xy * v0.xy;
  r2.x = -abs(cb4[1].x) + 1;
  r2.y = cb4[1].x;
  r3.x = dot(r2.xy, r1.xy);
  r2.z = -cb4[1].x;
  r3.y = dot(r2.zx, r1.xy);
  r1.xyzw = t2.Sample(s0_s, r3.xy).xyzw;
  r2.xyz = cb1[8].xyz + -v2.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = sqrt(r0.w);
  r0.w = saturate(cb4[2].x + -r0.w);
  r2.xy = float2(-0.5,-1) + r0.zy;
  r0.y = r2.x + r2.x;
  r0.y = cb4[3].x * abs(r0.y);
  r2.x = r0.w * r0.y;
  r2.z = 0.25 * r2.x;
  r1.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r1.wxyz;
  r1.x = r2.z * r1.x;
  r3.xy = cb4[4].xy * v0.xy;
  r4.x = -abs(cb4[5].x) + 1;
  r4.y = cb4[5].x;
  r5.x = dot(r4.xy, r3.xy);
  r4.z = -cb4[5].x;
  r5.y = dot(r4.zx, r3.xy);
  r3.xyzw = t3.Sample(s0_s, r5.xy).xyzw;
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r3.wxyz;
  r2.z = r3.x * r2.z;
  r2.w = 1 + -r0.z;
  r1.x = r2.w * r1.x;
  r1.x = r0.z * r2.z + r1.x;
  r4.xyzw = t0.Sample(s0_s, v0.xy).xyzw;
  r5.xy = r0.ww * r1.xx + r4.xz;
  r2.z = cmp(0 < cb4[6].x);
  if (r2.z != 0) {
    r2.z = r5.x + r5.y;
    r5.zw = r5.xy / r2.zz;
    r5.zw = float2(-0.300000012,-0.300000012) + r5.zw;
    r5.zw = saturate(float2(1.42857146,1.42857146) * r5.zw);
    r2.z = r5.z + r5.w;
    r2.z = r5.w / r2.z;
    r3.x = 1 + -r2.z;
    r6.xyzw = cb2[11].zyxw * r2.zzzz;
    r7.xyzw = cb2[12].zyxw * r2.zzzz;
    r8.xyzw = cb2[13].zyxw * r2.zzzz;
    r6.xyzw = r3.xxxx * cb2[7].xyzw + r6.xyzw;
    r7.xyzw = r3.xxxx * cb2[8].xyzw + r7.xyzw;
    r8.xyzw = r3.xxxx * cb2[9].xyzw + r8.xyzw;
  } else {
    r2.z = cmp(r5.x >= r5.y);
    r6.xyzw = r2.zzzz ? cb2[7].xyzw : cb2[11].zyxw;
    r7.xyzw = r2.zzzz ? cb2[8].xyzw : cb2[12].zyxw;
    r8.xyzw = r2.zzzz ? cb2[9].xyzw : cb2[13].zyxw;
  }
  r2.z = cmp(0 < cb4[7].x);
  if (r2.z != 0) {
    r2.z = r0.w * r1.x + r4.y;
    r3.x = min(r2.z, r5.y);
    r3.x = min(r5.x, r3.x);
    r2.z = max(r2.z, r5.y);
    r2.z = max(r5.x, r2.z);
    r3.x = r2.z + -r3.x;
    r2.z = r3.x / r2.z;
    r2.z = -0.100000001 + r2.z;
    r2.z = saturate(5 * r2.z);
    r0.x = r2.z * r0.x;
  }
  r4.xyzw = r0.wwww * r1.xxxx + r4.xyzw;
  r5.x = dot(r4.xyzw, r6.xyzw);
  r5.y = dot(r4.xyzw, r7.xyzw);
  r5.z = dot(r4.xyzw, r8.xyzw);
  r5.xyz = r5.xyz + -r4.xyz;
  r4.xyz = r0.xxx * r5.xyz + r4.xyz;
  r0.x = saturate(cb4[8].x);
  r0.x = r0.x * r2.y + 1;
  o0.xyz = r4.xyz * r0.xxx;
  r4.xyzw = t4.Sample(s0_s, v0.xy).xyzw;
  r4.xyz = float3(-0.5,-0.5,-0.5) + r4.xyz;
  r4.xyz = r4.xyz + r4.xyz;
  r3.xyz = r3.yzw + r3.yzw;
  r1.yzw = r1.yzw + r1.yzw;
  r5.xyz = r4.xyz * r3.zzz;
  r0.x = r0.z * r0.y;
  r0.x = r0.x * r0.w;
  r0.x = cb4[3].x * r0.x;
  r0.xz = r0.xx * r3.xy;
  r0.xz = r0.xz * r4.zz + r5.xy;
  r0.y = r2.w * r0.y;
  r0.y = r0.y * r0.w;
  r0.y = cb4[3].x * r0.y;
  r0.yw = r0.yy * r1.yz;
  r0.yw = r0.yw * r5.zz;
  r0.xy = r0.xz * r1.ww + r0.yw;
  r0.z = r5.z * r1.w;
  r1.yzw = v1.xyz * r0.yyy;
  r3.xy = v0.zw;
  r3.z = v1.w;
  r0.xyw = v3.xyz * r0.xxx + r1.yzw;
  r0.xyz = r3.xyz * r0.zzz + r0.xyw;
  r0.w = cmp(0 >= (uint)v4.x);
  if (r0.w != 0) {
    r0.w = dot(r3.xyz, r0.xyz);
    r1.yzw = r3.xyz * r0.www;
    r0.xyz = -r1.yzw * float3(2,2,2) + r0.xyz;
  }
  r0.w = saturate(r2.x * r1.x + r4.w);
  r1.x = 1 + -r0.w;
  r1.yzw = log2(cb4[9].xyz);
  r1.yzw = float3(2.20000005,2.20000005,2.20000005) * r1.yzw;
  r1.yzw = exp2(r1.yzw);
  r1.x = r1.x * cb4[10].x + cb4[11].x;
  r1.xyz = saturate(r1.yzw * r1.xxx);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
  o2.xyz = exp2(r1.xyz);
  r1.x = dot(r0.xyz, r0.xyz);
  r1.x = rsqrt(r1.x);
  r0.xyz = r1.xxx * r0.xyz;
  r1.x = max(abs(r0.x), abs(r0.y));
  r1.x = max(r1.x, abs(r0.z));
  r1.yz = cmp(abs(r0.zy) < r1.xx);
  r1.zw = r1.zz ? abs(r0.zy) : abs(r0.zx);
  r1.yz = r1.yy ? r1.zw : abs(r0.yx);
  r1.w = cmp(r1.z < r1.y);
  r2.xy = r1.ww ? r1.yz : r1.zy;
  r2.z = r2.y / r2.x;
  r0.xyz = r0.xyz / r1.xxx;
  r1.x = t13.SampleLevel(s13_s, r2.xz, 0).x;
  r0.xyz = r1.xxx * r0.xyz;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = cb4[12].x;
  o1.w = r0.w;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}