#include "moon.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 29 17:31:50 2026
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb12 : register(b12)
{
  float4 cb12[267];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[3];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[1];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float3 v4 : TEXCOORD4,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = -cb0[0].w;
  r0.y = 0;
  r0.xy = v2.xy + r0.xy;
  r0.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.w = log2(r0.w);
  r0.w = 2.20000005 * r0.w;
  r0.w = exp2(r0.w);
  r0.xyz = r0.xyz + r0.xyz;
  r1.x = dot(r0.xyz, r0.xyz);
  r1.x = rsqrt(r1.x);
  r0.xyz = r1.xxx * r0.xyz;
  r1.xy = v3.xy * r0.yy;
  r0.xy = v4.xy * r0.xx + r1.xy;
  r0.xy = v2.zw * r0.zz + r0.xy;
  r0.z = cb0[0].y * 0.0338638648 + cb0[0].w;
  r0.z = 6.28318501 * r0.z;
  sincos(r0.z, r1.x, r2.x);
  r2.y = r1.x;
  r0.x = saturate(dot(r0.xy, r2.xy));
  r0.xyz = cb12[266].xyz * r0.xxx;
  r0.xyz = r0.www * r0.xyz;
  r0.xyz = cb2[2].xyz * r0.xyz;
  r0.w = saturate(1 + -v1.w);
  r0.w = cb2[2].w * r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.xyz *= ClassicMoonBrightness(asuint(cb12[37].w));
  o0.w = 0;
  return;
}