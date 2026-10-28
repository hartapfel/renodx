#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 18:39:41 2026
Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[3];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[19];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float4 fog_position : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  ClassicForwardFog(fog_position, v0.w, v2);


  r0.xy = float2(1,1) / cb4[0].xx;
  r0.z = 1 / cb4[1].x;
  r0.w = floor(v1.x);
  r0.x = v1.x * r0.x;
  r0.x = floor(r0.x);
  r1.xy = r0.wx * r0.yz;
  r0.xw = v1.yz * r0.yz + r1.xy;
  r1.xyzw = t0.Sample(s0_s, r0.xw).xyzw;
  r0.x = 1 + v1.x;
  r0.w = floor(r0.x);
  r0.x = r0.x * r0.y;
  r0.x = floor(r0.x);
  r2.xy = r0.wx * r0.yz;
  r0.xy = v1.yz * r0.yz + r2.xy;
  r0.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r2.x = frac(v1.x);
  r2.y = cmp(cb2[18].x != 0.000000);
  if (r2.y != 0) {
    r0.w = r0.w + -r1.w;
    r0.w = r2.x * r0.w + r1.w;
    r0.w = r0.w * v4.w + -0.400000006;
    r0.w = cmp(r0.w < 0);
    if (r0.w != 0) discard;
  }
  r0.xyz = r0.xyz + -r1.xyz;
  r0.xyz = r2.xxx * r0.xyz + r1.xyz;
  r0.xyz = cb4[2].xxx * r0.xyz;
  r0.xyz = v3.xyz * r0.xyz;
  r0.xyz = cb2[2].xyz * r0.xyz;
  r0.w = dot(float3(0.333000004,0.555000007,0.222000003), r0.xyz);
  r1.xyz = r0.www * v0.xyz + -r0.xyz;
  r0.xyz = v0.www * r1.xyz + r0.xyz;
  r1.xyz = v2.xyz + -r0.xyz;
  r0.xyz = v2.www * r1.xyz + r0.xyz;
  o0.xyz = cb2[2].www * r0.xyz;
  o0.w = cb2[2].w;
  return;
}