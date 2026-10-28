#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 18:39:41 2026
Texture2D<float4> t15 : register(t15);

Texture2D<float4> t0 : register(t0);

SamplerState s15_s : register(s15);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[7];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[23];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[3];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[2];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : SV_Position0,
  out float4 o0 : SV_Target0,
  out float reflection_depth : SV_Target4)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  if (ClassicFogReady()) v2.w = 1.f - SampleClassicFogPixel(v4).a;


  r0.x = 1 + v1.x;
  r0.y = floor(r0.x);
  r1.xy = float2(1,1) / cb4[2].xx;
  r0.x = r1.y * r0.x;
  r0.x = floor(r0.x);
  r1.z = 1 / cb4[3].x;
  r2.xy = r1.yz * r0.yx;
  r0.xy = v1.yz * r1.yz + r2.xy;
  r0.xy = t0.Sample(s0_s, r0.xy).xy;
  r0.z = v1.x * r1.x;
  r0.z = floor(r0.z);
  r2.y = r0.z * r1.z;
  r0.z = floor(v1.x);
  r2.x = r0.z * r1.y;
  r0.zw = v1.yz * r1.yz + r2.xy;
  r0.zw = t0.Sample(s0_s, r0.zw).xy;
  r0.xy = r0.xy + -r0.zw;
  r1.x = frac(v1.x);
  r0.xy = r1.xx * r0.xy + r0.zw;
  r1.xyz = cb4[5].xxx * cb4[4].xyz;
  r0.yzw = r1.xyz * r0.yyy;
  r1.xyz = cb4[1].xxx * cb4[0].xyz;
  r0.xyz = r1.xyz * r0.xxx + r0.yzw;
  r1.xy = cb0[1].zw * v4.xy;
  r0.w = t15.SampleLevel(s15_s, r1.xy, 0).x;
  r0.w = r0.w * cb12[22].x + cb12[22].y;
  r0.w = r0.w * cb12[21].x + cb12[21].y;
  r0.w = max(9.99999975e-005, r0.w);
  r0.w = 1 / r0.w;
  r0.w = -v1.w + r0.w;
  r0.w = saturate(cb4[6].x * r0.w);
  r0.w = v3.w * r0.w;
  r0.xyz = r0.xyz * r0.www;
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(2.20000005,2.20000005,2.20000005) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = cb2[2].xyz * r0.xyz;
  r0.w = saturate(1 + -v2.w);
  r0.w = cb2[2].w * r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  // Capture only visible emission, not transparent billboard corners.
  reflection_depth = dot(max(o0.rgb,0.f),float3(.2126f,.7152f,.0722f))>1.e-3f
      ? min(65504.f,abs(v4.w)) : 65504.f;
  return;
}