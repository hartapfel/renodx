// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 21:55:11 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[8];
}




// 3Dmigoto declarations
#define cmp -


#include "../temporal/object_pixel.hlsli"

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
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = -1 + cb4[2].x;
  r0.x = 0.5 * r0.x;
  r0.y = saturate(r0.x);
  r1.xyz = t0.Sample(s0_s, v1.xy).xyz;
  r0.z = r1.x + r1.y;
  r0.z = r0.z + r1.z;
  r0.w = 0.333299994 * r0.z;
  r0.z = r0.z * -0.666599989 + 1;
  r0.y = r0.y * r0.z + r0.w;
  r0.x = saturate(r0.y * abs(r0.x));
  r0.yzw = cb4[1].xyz * r1.xyz;
  r0.yzw = saturate(float3(1.5,1.5,1.5) * r0.yzw);
  r0.yzw = r0.yzw + -r1.xyz;
  r0.xyz = r0.xxx * r0.yzw + r1.xyz;
  r0.w = max(r0.y, r0.z);
  r0.w = max(r0.w, r0.x);
  r0.w = cmp(0.219999999 < r0.w);
  r0.w = r0.w ? -0.300000012 : -0.149999976;
  r1.x = cb4[0].x * v0.z;
  r0.w = r1.x * r0.w + 1;
  o0.xyz = r0.xyz * r0.www;
  o0.w = cb4[6].x;
  r0.xyzw = t1.Sample(s0_s, v1.xy).xyzw;
  r1.x = cmp(r0.w < 0.330000013);
  r1.y = 0.949999988 * r0.w;
  r1.x = r1.x ? r1.y : 0.330000013;
  r1.x = r1.x + -r0.w;
  r1.x = v0.z * r1.x + r0.w;
  r2.x = v0.w;
  r2.yz = v1.zw;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.w = 1 + -r0.w;
  r0.w = r0.w * cb4[4].x + cb4[5].x;
  r0.xyz = r0.xyz + r0.xyz;
  r1.yzw = r2.xyz * r0.yyy;
  r1.yzw = v3.xyz * r0.xxx + r1.yzw;
  r0.xyz = v2.xyz * r0.zzz + r1.yzw;
  r1.y = dot(v2.xyz, r0.xyz);
  r1.yzw = v2.xyz * r1.yyy;
  r1.yzw = r1.yzw * float3(-2,-2,-2) + r0.xyz;
  r2.x = cmp(0 >= (uint)v4.x);
  r0.xyz = r2.xxx ? r1.yzw : r0.xyz;
  r1.y = dot(r0.xyz, r0.xyz);
  r1.y = rsqrt(r1.y);
  r0.xyz = r1.yyy * r0.xyz;
  r1.yzw = ddx_coarse(r0.xyz);
  r1.y = dot(r1.yzw, r1.yzw);
  r2.xyz = ddy_coarse(r0.xyz);
  r1.z = dot(r2.xyz, r2.xyz);
  r1.y = r1.y + r1.z;
  r1.y = 0.5 * r1.y;
  r1.y = min(0.180000007, r1.y);
  r1.x = r1.x * r1.x + r1.y;
  r1.x = min(1, r1.x);
  o1.w = sqrt(r1.x);
  r1.x = max(abs(r0.x), abs(r0.y));
  r1.x = max(r1.x, abs(r0.z));
  r1.yz = cmp(abs(r0.zy) < r1.xx);
  r2.xyz = r0.xyz / r1.xxx;
  r1.xz = r1.zz ? abs(r0.zy) : abs(r0.zx);
  r0.xy = r1.yy ? r1.xz : abs(r0.yx);
  r0.z = cmp(r0.y < r0.x);
  r0.xy = r0.zz ? r0.xy : r0.yx;
  r0.z = r0.y / r0.x;
  r0.x = t13.SampleLevel(s13_s, r0.xz, 0).x;
  r0.xyz = r2.xyz * r0.xxx;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r0.xyz = log2(cb4[3].xyz);
  r0.xyz = float3(2.20000005,2.20000005,2.20000005) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = saturate(r0.xyz * r0.www);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.454544991,0.454544991,0.454544991) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.w = max(r0.y, r0.z);
  r0.w = max(r0.x, r0.w);
  r0.w = cmp(0.200000003 < r0.w);
  r1.xyz = r0.www ? r0.xyz : float3(0.119999997,0.119999997,0.119999997);
  r1.xyz = r1.xyz + -r0.xyz;
  o2.xyz = v0.zzz * r1.xyz + r0.xyz;
  r0.x = cmp(0 < cb4[7].x);
  o2.w = r0.x ? 0.064706 : 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}