#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 18:39:40 2026
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[3];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
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
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  float4 fog_position : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  if (ClassicFogReady()) v1.w = 1.f - SampleClassicFogPixel(fog_position).a;


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
  r0.xy = v5.xy * r0.xx + r1.xy;
  r0.xy = v2.zw * r0.zz + r0.xy;
  r0.z = cb0[0].y * 0.0338638648 + cb0[0].w;
  r0.z = 6.28318501 * r0.z;
  sincos(r0.z, r1.x, r2.x);
  r2.y = r1.x;
  r0.x = saturate(dot(r0.xy, r2.xy));
  r0.xyz = cb2[0].xyz * r0.xxx;
  r0.xyz = r0.www * r0.xyz;
  r1.xy = v2.zw;
  r1.z = v3.w;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r2.xyzw = cb1[8].zxyz + -v4.zxyz;
  r0.w = dot(r2.yzw, r2.yzw);
  r0.w = rsqrt(r0.w);
  r2.xyzw = r2.xyzw * r0.wwww;
  r0.w = dot(r2.yzw, r1.xyz);
  r1.x = saturate(r2.x * -3.5 + -0.800000012);
  r1.x = r1.x * r1.x;
  r0.w = 1.10000002 + -r0.w;
  r1.y = r0.w * r0.w;
  r0.w = r1.y * r0.w;
  r1.z = r1.y * r1.y;
  r0.w = r1.z * r0.w;
  r1.z = r1.z * r1.z;
  r1.y = r1.y * r1.z;
  r1.y = min(1, r1.y);
  r1.y = 1 + -r1.y;
  r0.w = r0.w * 5 + 1;
  r0.xyz = r0.www * r0.xyz;
  r0.xyz = r1.yyy * r0.xyz;
  r0.xyz = r1.xxx * r0.xyz;
  r0.xyz = cb2[2].xyz * r0.xyz;
  r0.w = saturate(1 + -v1.w);
  r0.w = cb2[2].w * r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  return;
}