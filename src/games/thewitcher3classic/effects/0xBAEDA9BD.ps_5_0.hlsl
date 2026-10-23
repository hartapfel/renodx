#include "../shared.h"

// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 16:20:10 2026
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

cbuffer cb12 : register(b12)
{
  float4 cb12[23];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = (int2)v0.xy;
  r0.zw = float2(0,0);
  r1.x = t1.Load(r0.xyw).x;
  r0.xyz = t0.Load(r0.xyz).xyz;
  r0.w = r1.x * cb12[22].x + cb12[22].y;
  r0.w = cmp(r0.w >= 1);
  r0.w = r0.w ? 1.000000 : 0;
  o0.xyz = r0.xyz * r0.www;
  // Scale only the masked sky branch, before shared extraction.
  if (RENODX_PEAK_WHITE_NITS > 0.f) o0.xyz *= shader_injection.custom_sunshafts_strength;
  o0.w = 1;
  return;
}