#include "../shared.h"

// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 16:20:10 2026
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb3 : register(b3)
{
  float4 cb3[4];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = t1.Sample(s1_s, w1.xy).xyz;
  r0.w = dot(r0.xyz, float3(0.300000012,0.589999974,0.109999999));
  float3 scene = r0.xyz;
  r0.xyz = float3(1,1,1) + -r0.xyz;
  r0.w = -3 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = saturate(cb3[2].w * r0.w);
  r0.w = -1 + r0.w;
  r0.w = cb3[3].x * r0.w + 1;
  r1.xyz = t0.Sample(s0_s, v1.xy).xyz;
  r1.xyz = cb3[2].xyz * r1.xyz;
  r1.xyz = saturate(r1.xyz * r0.www);
  if (RENODX_PEAK_WHITE_NITS > 0.f) {
    // Keep native screen blending in SDR, but never subtract HDR highlights
    // through its (1 - scene) factor. Scale the isolated effect, not scene.
    if (RENODX_TONE_MAP_TYPE != CLASSIC_TONE_MAP_VANILLA) {
      o0.xyz = scene + r1.xyz * (1.f - saturate(scene))
          * (shader_injection.blitz_bloom_active != 0.f ? 1.f : shader_injection.custom_bloom);
      o0.w = 1.f;
      return;
    }
    if (shader_injection.blitz_bloom_active == 0.f) r1.xyz *= shader_injection.custom_bloom;
  }
  r1.xyz = float3(1,1,1) + -r1.xyz;
  o0.xyz = -r0.xyz * r1.xyz + float3(1,1,1);
  o0.w = 1;
  return;
}
