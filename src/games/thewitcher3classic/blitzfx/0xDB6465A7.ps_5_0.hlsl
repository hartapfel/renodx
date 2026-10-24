// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 21:55:11 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[10];
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = -1 + cb4[5].x;
  r0.x = 0.5 * r0.x;
  r0.y = saturate(r0.x);
  r1.y = cb4[2].x;
  r0.zw = cb4[1].xy * v1.xy;
  r1.x = 1 + -abs(cb4[2].x);
  r2.x = dot(r1.xy, r0.zw);
  r1.z = -cb4[2].x;
  r2.y = dot(r1.zx, r0.zw);
  r1.xyzw = t1.Sample(s0_s, r2.xy).xyzw;
  r1.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r1.wxyz;
  r0.z = cb4[0].x * v0.z;
  r0.z = r0.z * -0.600000024 + cb4[0].x;
  r0.w = 0.25 * r0.z;
  r0.w = r0.w * r1.x;
  r2.xyz = t0.Sample(s0_s, v1.xy).xyz;
  r3.xyz = cb1[8].xyz + -v3.xyz;
  r1.x = dot(r3.xyz, r3.xyz);
  r1.x = sqrt(r1.x);
  r1.x = saturate(cb4[3].x + -r1.x);
  r2.xyz = r0.www * r1.xxx + r2.xyz;
  r2.w = r2.x + r2.y;
  r2.w = r2.w + r2.z;
  r3.x = 0.333299994 * r2.w;
  r2.w = r2.w * -0.666599989 + 1;
  r0.y = r0.y * r2.w + r3.x;
  r0.x = saturate(r0.y * abs(r0.x));
  r3.xyz = cb4[4].xyz * r2.xyz;
  r3.xyz = saturate(float3(1.5,1.5,1.5) * r3.xyz);
  r3.xyz = r3.xyz + -r2.xyz;
  r2.xyz = r0.xxx * r3.xyz + r2.xyz;
  r0.x = max(r2.y, r2.z);
  r0.x = max(r2.x, r0.x);
  r0.x = cmp(0.219999999 < r0.x);
  r0.x = r0.x ? -0.300000012 : -0.149999976;
  r0.x = v0.z * r0.x + 1;
  o0.xyz = r2.xyz * r0.xxx;
  o0.w = cb4[9].x;
  r0.xy = r1.xx * r0.zz;
  r0.z = 2;
  r2.xyz = r0.xyz * r1.yzw;
  r2.w = 2;
  r3.xyzw = t2.Sample(s0_s, v1.xy).xyzw;
  r1.yzw = float3(-0.5,-0.5,-0.5) + r3.xyz;
  r1.yzw = r2.zzw * r1.yzw;
  r0.x = dot(r1.ww, r2.yy);
  r0.x = r1.z * 2 + r0.x;
  r3.x = v0.w;
  r3.yz = v1.zw;
  r3.xyz = r3.xyz * r0.xxx;
  r0.x = dot(r1.ww, r2.xx);
  r0.z = r1.w * r2.z;
  r0.x = r1.y * 2 + r0.x;
  r1.yzw = v4.xyz * r0.xxx + r3.xyz;
  r1.yzw = v2.xyz * r0.zzz + r1.yzw;
  r0.x = dot(v2.xyz, r1.yzw);
  r2.xyz = v2.xyz * r0.xxx;
  r2.xyz = r2.xyz * float3(-2,-2,-2) + r1.yzw;
  r0.x = cmp(0 >= (uint)v5.x);
  r1.yzw = r0.xxx ? r2.xyz : r1.yzw;
  r0.x = dot(r1.yzw, r1.yzw);
  r0.x = rsqrt(r0.x);
  r1.yzw = r1.yzw * r0.xxx;
  r0.x = max(abs(r1.y), abs(r1.z));
  r0.x = max(abs(r1.w), r0.x);
  r2.xy = cmp(abs(r1.wz) < r0.xx);
  r3.xyz = r1.yzw / r0.xxx;
  r0.xz = r2.yy ? abs(r1.wz) : abs(r1.wy);
  r0.xz = r2.xx ? r0.xz : abs(r1.zy);
  r2.x = cmp(r0.z < r0.x);
  r2.xy = r2.xx ? r0.xz : r0.zx;
  r2.z = r2.y / r2.x;
  r0.x = t13.SampleLevel(s13_s, r2.xz, 0).x;
  r2.xyz = r3.xyz * r0.xxx;
  o1.xyz = r2.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r0.x = saturate(r0.y * r0.w + r3.w);
  r0.y = -r0.w * r1.x + r3.w;
  r0.y = 1 + -r0.y;
  r0.y = r0.y * cb4[7].x + cb4[8].x;
  r0.z = cmp(r0.x < 0.330000013);
  r0.w = 0.949999988 * r0.x;
  r0.z = r0.z ? r0.w : 0.330000013;
  r0.z = r0.z + -r0.x;
  r0.x = v0.z * r0.z + r0.x;
  r2.xyz = ddx_coarse(r1.yzw);
  r1.xyz = ddy_coarse(r1.yzw);
  r0.z = dot(r1.xyz, r1.xyz);
  r0.w = dot(r2.xyz, r2.xyz);
  r0.z = r0.w + r0.z;
  r0.z = 0.5 * r0.z;
  r0.z = min(0.180000007, r0.z);
  r0.x = r0.x * r0.x + r0.z;
  r0.x = min(1, r0.x);
  o1.w = sqrt(r0.x);
  r0.xzw = log2(cb4[6].xyz);
  r0.xzw = float3(2.20000005,2.20000005,2.20000005) * r0.xzw;
  r0.xzw = exp2(r0.xzw);
  r0.xyz = saturate(r0.xzw * r0.yyy);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.454544991,0.454544991,0.454544991) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.w = max(r0.y, r0.z);
  r0.w = max(r0.x, r0.w);
  r0.w = cmp(0.200000003 < r0.w);
  r1.xyz = r0.www ? r0.xyz : float3(0.119999997,0.119999997,0.119999997);
  r1.xyz = r1.xyz + -r0.xyz;
  o2.xyz = v0.zzz * r1.xyz + r0.xyz;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}