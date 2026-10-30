#include "./night_sky.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 30 09:02:31 2026
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[13];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[238];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[10];
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
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = float3(1,1,-1) * cb0[9].xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r1.xy = cb4[5].xy * cb0[0].xx;
  r1.xy = v1.xy * cb4[4].xy + r1.xy;
  r1.xyzw = t0.Sample(s0_s, r1.xy).xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.xyz = r1.xyz + r1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r2.xyz = v3.xyz * r1.yyy;
  r2.xyz = v5.xyz * r1.xxx + r2.xyz;
  r3.xy = v1.zw;
  r3.z = v3.w;
  r1.xyz = r3.xyz * r1.zzz + r2.xyz;
  r0.x = saturate(dot(r0.xyz, r1.xyz));
  r0.y = cb4[3].x + -cb4[2].x;
  r0.x = r0.x * r0.y + cb4[2].x;
  r0.y = dot(-cb0[9].xy, -cb0[9].xy);
  r0.y = rsqrt(r0.y);
  r0.yz = -cb0[9].xy * r0.yy;
  r1.xyz = cb1[8].xyz + -v4.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r1.z = rsqrt(r0.w);
  r0.w = sqrt(r0.w);
  r0.w = -cb4[7].x + r0.w;
  r1.xy = r1.xy * r1.zz;
  r0.y = saturate(dot(r0.yz, r1.xy));
  r0.y = r0.y + r0.y;
  r0.y = min(1, r0.y);
  r0.z = cb4[1].x + -cb4[0].x;
  r0.z = r0.y * r0.z + cb4[0].x;
  r0.x = r0.z * r0.x;
  r0.x = log2(r0.x);
  r0.x = 2.20000005 * r0.x;
  r0.x = exp2(r0.x);
  r1.xyz = -cb12[237].xyz + cb12[236].xyz;
  r1.xyz = r0.yyy * r1.xyz + cb12[237].xyz;
  r1.xyz *= ClassicCloudBrightness(asuint(cb12[184].w));
  r2.xyz = r1.xyz * r0.xxx;
  r0.xyz = -r1.xyz * r0.xxx + v0.xyz;
  r0.xyz = v0.www * r0.xyz + r2.xyz;
  r1.x = cb4[8].x + -cb4[7].x;
  r0.w = saturate(r0.w / r1.x);
  r1.x = cb4[9].x * r1.w;
  r1.y = -cb4[9].x * r1.w + r1.w;
  r0.w = r0.w * r1.y + r1.x;
  r1.xy = cb4[11].xy * cb0[0].xx;
  r1.xy = v1.xy * cb4[10].xy + r1.xy;
  r1.x = t1.Sample(s0_s, r1.xy).x;
  r1.x = r1.x * cb4[12].x + -cb4[12].x;
  r1.x = saturate(cb4[12].x * v2.w + r1.x);
  r0.w = r1.x * r0.w;
  r0.w = saturate(cb4[6].x * r0.w);
  o0.xyz = r0.xyz * r0.www;
  o0.w = r0.w;
  return;
}