#include "./native_curve.hlsli"

// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 15:52:09 2026
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

cbuffer cb3 : register(b3)
{
  float4 cb3[17];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = t1.Load(int3(0,0,0)).x;
  r0.x = max(cb3[4].y, r0.x);
  r0.x = min(cb3[4].z, r0.x);
  r0.x = max(9.99999975e-005, r0.x);
  r0.y = 11.1999998 * cb3[16].x;
  r0.x = r0.x / r0.y;
  r0.x = log2(r0.x);
  r0.x = cb3[16].z * r0.x;
  r0.x = exp2(r0.x);
  r0.x = r0.x * r0.y;
  r0.x = cb3[16].x / r0.x;
  r1.xy = (uint2)v0.xy;
  r1.zw = float2(0,0);
  r0.yzw = t0.Load(r1.xyz).xyz;
  r0.xyz = r0.xxx * r0.yzw;
  // Preserve native exposure, then remove only the bounded filmic shoulder.
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31 && RENODX_PEAK_WHITE_NITS > 0.f) {
    o0 = float4(ClassicExtendNative(r0.xyz, cb3[7].xyz, cb3[8].xyz, cb3[16].y), 1.f);
    return;
  }

  r1.xyz = cb3[7].xxx * r0.xyz + cb3[7].yyy;
  r2.xy = cb3[8].xx * cb3[8].yz;
  r1.xyz = r0.xyz * r1.xyz + r2.yyy;
  r0.w = cb3[7].z * cb3[7].y;
  r3.xyz = cb3[7].xxx * r0.xyz + r0.www;
  r0.xyz = r0.xyz * r3.xyz + r2.xxx;
  r0.xyz = r0.xyz / r1.xyz;
  r0.w = cb3[7].x * 11.1999998 + r0.w;
  r0.w = r0.w * 11.1999998 + r2.x;
  r1.x = cb3[8].y / cb3[8].z;
  r0.xyz = -r1.xxx + r0.xyz;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.xyz = cb3[16].yyy * r0.xyz;
  r1.y = cb3[7].x * 11.1999998 + cb3[7].y;
  r1.y = r1.y * 11.1999998 + r2.y;
  r0.w = r0.w / r1.y;
  r0.w = r0.w + -r1.x;
  r0.w = max(0, r0.w);
  o0.xyz = r0.xyz / r0.www;
  o0.w = 1;
  return;
}
