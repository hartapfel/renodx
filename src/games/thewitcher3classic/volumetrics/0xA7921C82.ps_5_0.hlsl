#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 18:39:41 2026
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[6];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[3];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 fog_position : SV_Position0,
  out float4 o0 : SV_Target0,
  out float reflection_depth : SV_Target4)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  if (ClassicFogReady()) v2.w = 1.f - SampleClassicFogPixel(fog_position).a;


  r0.xy = float2(1,1) / cb4[2].xx;
  r0.x = v1.x * r0.x;
  r0.x = floor(r0.x);
  r0.z = 1 / cb4[3].x;
  r1.y = r0.x * r0.z;
  r0.x = floor(v1.x);
  r1.x = r0.x * r0.y;
  r0.xy = v1.yz * r0.yz + r1.xy;
  r0.xyz = t0.Sample(s0_s, r0.xy).xyz;
  r1.xyz = v3.www * r0.xyz;
  r0.w = dot(r1.xyz, float3(0.298999995,0.587000012,0.114));
  r0.xyz = -v3.www * r0.xyz + r0.www;
  r0.xyz = cb4[4].xxx * r0.xyz + r1.xyz;
  r1.xyz = cb4[1].xxx * cb4[0].xyz;
  r0.xyz = r1.xyz * r0.xyz;
  r0.xyz = log2(r0.xyz);
  r0.xyz = cb4[5].xxx * r0.xyz;
  r0.xyz = float3(2.20000005,2.20000005,2.20000005) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = cb2[2].xyz * r0.xyz;
  r0.w = saturate(1 + -v2.w);
  r0.w = cb2[2].w * r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  // Only visible emission contributes depth; transparent billboard corners do not.
  reflection_depth = dot(max(o0.rgb,0.f),float3(.2126f,.7152f,.0722f))>1.e-3f
      ? min(65504.f,abs(fog_position.w)) : 65504.f;
  return;
}