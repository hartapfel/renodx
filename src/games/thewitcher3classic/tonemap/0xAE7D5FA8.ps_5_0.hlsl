#include "./native_curve.hlsli"

// Preserve each native exposure and the environment blend; extend only the filmic shoulder.
// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 11:52:20 2026
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

cbuffer cb3 : register(b3)
{
  float4 cb3[18];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = t1.Load(int3(0,0,0)).x;
  r0.y = max(cb3[9].y, r0.x);
  r0.x = max(cb3[4].y, r0.x);
  r0.x = min(cb3[4].z, r0.x);
  r0.y = min(cb3[9].z, r0.y);
  r0.xy = max(float2(9.99999975e-005,9.99999975e-005), r0.xy);
  r0.z = 11.1999998 * cb3[17].x;
  r0.y = r0.y / r0.z;
  r0.y = log2(r0.y);
  r0.y = cb3[17].z * r0.y;
  r0.y = exp2(r0.y);
  r0.y = r0.y * r0.z;
  r0.y = cb3[17].x / r0.y;
  r1.xy = (uint2)v0.xy;
  r1.zw = float2(0,0);
  r1.xyz = t0.Load(r1.xyz).xyz;
  r0.yzw = r1.xyz * r0.yyy;
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31 && RENODX_PEAK_WHITE_NITS > 0.f) {
    r0.yzw = ClassicExtendNative(r0.yzw, cb3[11].xyz, cb3[12].xyz, cb3[17].y);
  } else {
    r2.xyz = cb3[11].xxx * r0.yzw + cb3[11].yyy;
    r3.xy = cb3[12].xx * cb3[12].yz;
    r2.xyz = r0.yzw * r2.xyz + r3.yyy;
    r1.w = cb3[11].z * cb3[11].y;
    r4.xyz = cb3[11].xxx * r0.yzw + r1.www;
    r0.yzw = r0.yzw * r4.xyz + r3.xxx;
    r0.yzw = r0.yzw / r2.xyz;
    r1.w = cb3[11].x * 11.1999998 + r1.w;
    r1.w = r1.w * 11.1999998 + r3.x;
    r2.x = cb3[12].y / cb3[12].z;
    r0.yzw = -r2.xxx + r0.yzw;
    r0.yzw = max(float3(0,0,0), r0.yzw);
    r0.yzw = cb3[17].yyy * r0.yzw;
    r2.y = cb3[11].x * 11.1999998 + cb3[11].y;
    r2.y = r2.y * 11.1999998 + r3.y;
    r1.w = r1.w / r2.y;
    r1.w = r1.w + -r2.x;
    r1.w = max(0, r1.w);
    r0.yzw = r0.yzw / r1.www;
  }
  r1.w = 11.1999998 * cb3[16].x;
  r0.x = r0.x / r1.w;
  r0.x = log2(r0.x);
  r0.x = cb3[16].z * r0.x;
  r0.x = exp2(r0.x);
  r0.x = r0.x * r1.w;
  r0.x = cb3[16].x / r0.x;
  r1.xyz = r0.xxx * r1.xyz;
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31 && RENODX_PEAK_WHITE_NITS > 0.f) {
    r1.xyz = ClassicExtendNative(r1.xyz, cb3[7].xyz, cb3[8].xyz, cb3[16].y);
  } else {
    r2.xyz = cb3[7].xxx * r1.xyz + cb3[7].yyy;
    r3.xy = cb3[8].xx * cb3[8].yz;
    r2.xyz = r1.xyz * r2.xyz + r3.yyy;
    r0.x = cb3[7].z * cb3[7].y;
    r4.xyz = cb3[7].xxx * r1.xyz + r0.xxx;
    r1.xyz = r1.xyz * r4.xyz + r3.xxx;
    r1.xyz = r1.xyz / r2.xyz;
    r0.x = cb3[7].x * 11.1999998 + r0.x;
    r0.x = r0.x * 11.1999998 + r3.x;
    r1.w = cb3[8].y / cb3[8].z;
    r1.xyz = r1.xyz + -r1.www;
    r1.xyz = max(float3(0,0,0), r1.xyz);
    r1.xyz = cb3[16].yyy * r1.xyz;
    r2.x = cb3[7].x * 11.1999998 + cb3[7].y;
    r2.x = r2.x * 11.1999998 + r3.y;
    r0.x = r0.x / r2.x;
    r0.x = r0.x + -r1.w;
    r0.x = max(0, r0.x);
    r1.xyz = r1.xyz / r0.xxx;
  }
  r0.xyz = -r1.xyz + r0.yzw;
  o0.xyz = cb3[13].xxx * r0.xyz + r1.xyz;
  o0.w = 1;
  return;
}