#include "../tonemap/native_curve.hlsli"

// BlitzFX 1.1.0: retain exposure, white balance, contrast and pre-curve vignette.
// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 21:43:03 2026
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

cbuffer cb3 : register(b3)
{
  float4 cb3[17];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[45];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[24];
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

  r0.x = t1.Load(float4(0,0,0,0)).x;
  r0.y = max(cb3[4].y, r0.x);
  r0.y = min(cb3[4].z, r0.y);
  r0.y = max(9.99999975e-005, r0.y);
  r0.z = 11.1999998 * cb3[16].x;
  r0.y = r0.y / r0.z;
  r0.y = log2(r0.y);
  r0.y = cb3[16].z * r0.y;
  r0.y = exp2(r0.y);
  r0.y = r0.y * r0.z;
  r0.y = cb3[16].x / r0.y;
  r0.y = cb1[42].z * r0.y;
  r0.z = cmp(cb1[44].y == 0.000000);
  if (r0.z != 0) {
    r0.w = 1;
  }
  r1.xy = v0.xy * cb0[23].zw + float2(-0.5,-0.5);
  r1.x = dot(r1.xy, r1.xy);
  r1.x = sqrt(r1.x);
  r1.x = r1.x * 1.38592935 + -cb1[44].w;
  r1.y = 1 + -cb1[44].w;
  r1.x = r1.x / r1.y;
  r1.x = max(0, r1.x);
  r1.x = log2(r1.x);
  r1.x = cb1[44].z * r1.x;
  r1.x = exp2(r1.x);
  r1.x = -r1.x * cb1[44].y + 1;
  r1.x = max(0, r1.x);
  r0.z = r0.z ? r0.w : r1.x;
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31 && RENODX_PEAK_WHITE_NITS > 0.f)
    r0.z = shader_injection.vignette_strength <= 0.f ? 1.f
        : pow(saturate(r0.z), shader_injection.vignette_strength);
  r0.y = r0.y * r0.z;
  r1.xy = (uint2)v0.xy;
  r1.zw = float2(0,0);
  r1.xyz = t0.Load(r1.xyz).xyz;
  r0.x = 9.99999975e-006 + r0.x;
  r0.x = log2(r0.x);
  r1.xyz = r1.xyz * cb1[41].xyz + float3(9.99999975e-006,9.99999975e-006,9.99999975e-006);
  r1.xyz = log2(r1.xyz);
  r1.xyz = r1.xyz + -r0.xxx;
  r0.xzw = r1.xyz * cb1[44].xxx + r0.xxx;
  r0.xzw = exp2(r0.xzw);
  r0.xzw = float3(-9.99999975e-006,-9.99999975e-006,-9.99999975e-006) + r0.xzw;
  r0.xzw = max(float3(0,0,0), r0.xzw);
  r0.xyz = r0.yyy * r0.xzw;
  if (asuint(cb1[42].y) != 0) {
    r0.xyz = cb3[16].yyy * r0.xyz;
    r0.w = 1;
  } else {
    r0.w = cb3[16].y;
  }
  r1.x = dot(r0.xyz, float3(0.272228718,0.674081743,0.0536895171));
  r0.xyz = -r1.xxx + r0.xyz;
  r0.xyz = cb1[41].www * r0.xyz + r1.xxx;
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31 && RENODX_PEAK_WHITE_NITS > 0.f) {
    o0 = float4(ClassicExtendNative(r0.xyz, cb3[7].xyz, cb3[8].xyz, r0.w), 1.f);
    return;
  }
  r1.x = cb3[7].z * cb3[7].y;
  r1.yzw = cb3[7].xxx * r0.xyz + r1.xxx;
  r2.xy = cb3[8].xx * cb3[8].yz;
  r1.yzw = r0.xyz * r1.yzw + r2.xxx;
  r3.xyz = cb3[7].xxx * r0.xyz + cb3[7].yyy;
  r0.xyz = r0.xyz * r3.xyz + r2.yyy;
  r0.xyz = r1.yzw / r0.xyz;
  r1.y = cb3[8].y / cb3[8].z;
  r0.xyz = -r1.yyy + r0.xyz;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.xyz = r0.xyz * r0.www;
  r0.w = cb3[7].x * 11.1999998 + r1.x;
  r0.w = r0.w * 11.1999998 + r2.x;
  r1.x = cb3[7].x * 11.1999998 + cb3[7].y;
  r1.x = r1.x * 11.1999998 + r2.y;
  r0.w = r0.w / r1.x;
  r0.w = r0.w + -r1.y;
  r0.w = max(9.99999975e-005, r0.w);
  o0.xyz = saturate(r0.xyz / r0.www);
  o0.w = 1;
  return;
}
