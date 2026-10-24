// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 21:55:11 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[14];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[18];
}




// 3Dmigoto declarations
#define cmp -


#include "../temporal/object_pixel.hlsli"

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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t1.Sample(s0_s, v1.xy).xyzw;
  r1.xy = cb4[0].xy * v1.xy;
  r2.x = 1 + -abs(cb4[1].x);
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
  r2.yzw = t3.Sample(s0_s, v1.xy).xyz;
  r3.xy = cb4[4].xy * v1.xy;
  r4.x = 1 + -abs(cb4[5].x);
  r4.y = cb4[5].x;
  r5.x = dot(r4.xy, r3.xy);
  r4.z = -cb4[5].x;
  r5.y = dot(r4.zx, r3.xy);
  r3.xyzw = t4.Sample(s0_s, r5.xy).xyzw;
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r3.wxyz;
  r3.x = 0.5 * r3.x;
  r4.x = cb4[2].x * v0.z;
  r4.x = r4.x * -0.600000024 + cb4[2].x;
  r4.yzw = float3(-0.550000012,-1,-0.5) + r2.wyw;
  r2.y = saturate(2.22222233 * r4.y);
  r4.y = 0.449999988 + -r2.w;
  r4.y = saturate(2.22222233 * r4.y);
  r5.x = r4.y * r3.x;
  r5.x = r1.x * r2.y + r5.x;
  r5.x = r5.x * r2.x;
  r0.w = saturate(r5.x * r4.x + r0.w);
  r5.x = cb4[6].x * r4.x;
  r3.x = r4.y * -r3.x;
  r1.x = -r1.x * r2.y + r3.x;
  r1.x = r1.x * r2.x;
  r1.x = r1.x * r5.x + 1;
  r1.x = max(0, r1.x);
  r5.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r6.xyz = log2(r5.xyz);
  r6.xyz = float3(2.20000005,2.20000005,2.20000005) * r6.xyz;
  r5.xyz = exp2(r6.xyz);
  r5.xyzw = r5.xyzw * r1.xxxx;
  r1.x = cmp(0 < cb4[9].x);
  if (r1.x != 0) {
    r6.xyz = log2(r5.xyz);
    r6.xyz = float3(0.454544991,0.454544991,0.454544991) * r6.xyz;
    r5.xyz = exp2(r6.xyz);
    r1.x = r5.x + r5.z;
    r6.xy = r5.xz / r1.xx;
    r6.xy = float2(-0.300000012,-0.300000012) + r6.xy;
    r6.xy = saturate(float2(1.42857146,1.42857146) * r6.xy);
    r1.x = cmp(0 < cb4[7].x);
    r2.y = r6.x + r6.y;
    r2.y = r6.y / r2.y;
    r3.x = 1 + -r2.y;
    r6.xyzw = cb2[11].zyxw * r2.yyyy;
    r7.xyzw = cb2[12].zyxw * r2.yyyy;
    r8.xyzw = cb2[13].zyxw * r2.yyyy;
    r6.xyzw = r3.xxxx * cb2[7].xyzw + r6.xyzw;
    r7.xyzw = r3.xxxx * cb2[8].xyzw + r7.xyzw;
    r8.xyzw = r3.xxxx * cb2[9].xyzw + r8.xyzw;
    r2.y = cmp(r5.x >= r5.z);
    r9.xyzw = r2.yyyy ? cb2[7].xyzw : cb2[11].zyxw;
    r10.xyzw = r2.yyyy ? cb2[8].xyzw : cb2[12].zyxw;
    r11.xyzw = r2.yyyy ? cb2[9].xyzw : cb2[13].zyxw;
    r6.xyzw = r1.xxxx ? r6.xyzw : r9.xyzw;
    r7.xyzw = r1.xxxx ? r7.xyzw : r10.xyzw;
    r8.xyzw = r1.xxxx ? r8.xyzw : r11.xyzw;
    r1.x = min(r5.y, r5.z);
    r1.x = min(r5.x, r1.x);
    r2.y = max(r5.y, r5.z);
    r2.y = max(r5.x, r2.y);
    r3.x = cmp(0 < cb4[8].x);
    r1.x = r2.y + -r1.x;
    r1.x = r1.x / r2.y;
    r1.x = -0.100000001 + r1.x;
    r1.x = saturate(5 * r1.x);
    r1.x = r2.z * r1.x;
    r1.x = r3.x ? r1.x : r2.z;
    r6.x = dot(r5.xyzw, r6.xyzw);
    r6.y = dot(r5.xyzw, r7.xyzw);
    r6.z = dot(r5.xyzw, r8.xyzw);
    r6.xyz = r6.xyz + -r5.xyz;
    r6.xyz = r1.xxx * r6.xyz + r5.xyz;
  } else {
    r5.xyz = log2(r5.xyz);
    r5.xyz = float3(0.454544991,0.454544991,0.454544991) * r5.xyz;
    r6.xyz = exp2(r5.xyz);
  }
  r1.x = saturate(cb4[10].x);
  r1.x = r1.x * r4.z + 1;
  r5.xyz = r6.xyz * r1.xxx;
  r1.x = max(r5.y, r5.z);
  r1.x = max(r5.x, r1.x);
  r1.x = cmp(0.219999999 < r1.x);
  r1.x = r1.x ? -0.300000012 : -0.149999976;
  r1.x = v0.z * r1.x + 1;
  o0.xyz = r5.xyz * r1.xxx;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r1.xyz = r1.yzw + r1.yzw;
  r3.xyz = r3.yzw + r3.yzw;
  r1.w = r4.x * r2.x;
  r2.x = -0.0500000007 + abs(r4.w);
  r2.x = saturate(2.22222233 * r2.x);
  r1.w = r2.x * r1.w;
  r2.x = cmp(0.5 < r2.w);
  r1.xyz = r2.xxx ? r1.xyz : r3.xyz;
  r2.xyw = r1.zzz * r0.xyz;
  r0.xy = r1.ww * r1.xy;
  r2.xy = r0.xy * r0.zz + r2.xy;
  r0.x = dot(r2.xyw, r2.xyw);
  r0.x = rsqrt(r0.x);
  r0.xyz = r2.xyw * r0.xxx;
  r1.x = v0.w;
  r1.yz = v1.zw;
  r1.xyz = r1.xyz * r0.yyy;
  r1.xyz = v4.xyz * r0.xxx + r1.xyz;
  r0.xyz = v2.xyz * r0.zzz + r1.xyz;
  r1.x = cmp(0 >= (uint)v5.x);
  r1.y = dot(v2.xyz, r0.xyz);
  r1.yzw = v2.xyz * r1.yyy;
  r1.yzw = r1.yzw * float3(-2,-2,-2) + r0.xyz;
  r0.xyz = r1.xxx ? r1.yzw : r0.xyz;
  r1.x = cb4[12].x * r2.z;
  r1.y = 1 + -r0.w;
  r2.xyz = log2(cb4[11].xyz);
  r2.xyz = float3(2.20000005,2.20000005,2.20000005) * r2.xyz;
  r2.xyz = exp2(r2.xyz);
  r3.xyz = r6.xyz + -r2.xyz;
  r1.xzw = r1.xxx * r3.xyz + r2.xyz;
  r1.y = r1.y * cb4[13].x + cb4[14].x;
  r1.xyz = saturate(r1.xzw * r1.yyy);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r1.w = max(r1.y, r1.z);
  r1.w = max(r1.x, r1.w);
  r1.w = cmp(0.200000003 < r1.w);
  r2.xyz = r1.www ? r1.xyz : float3(0.119999997,0.119999997,0.119999997);
  r2.xyz = r2.xyz + -r1.xyz;
  o2.xyz = v0.zzz * r2.xyz + r1.xyz;
  r1.x = cb4[16].x + -cb4[15].x;
  r0.w = saturate(r0.w * r1.x + cb4[15].x);
  r1.x = cmp(r0.w < 0.330000013);
  r1.y = 0.949999988 * r0.w;
  r1.x = r1.x ? r1.y : 0.330000013;
  r1.x = r1.x + -r0.w;
  r0.w = v0.z * r1.x + r0.w;
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
  r1.xyz = r0.xyz / r1.xxx;
  r1.w = t13.SampleLevel(s13_s, r2.xz, 0).x;
  r1.xyz = r1.xyz * r1.www;
  o1.xyz = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.xyz = ddx_coarse(r0.xyz);
  r0.xyz = ddy_coarse(r0.xyz);
  r1.x = dot(r1.xyz, r1.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = r1.x + r0.x;
  r0.x = 0.5 * r0.x;
  r0.x = min(0.180000007, r0.x);
  r0.x = r0.w * r0.w + r0.x;
  r0.x = min(1, r0.x);
  o1.w = sqrt(r0.x);
  o0.w = cb4[17].x;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}