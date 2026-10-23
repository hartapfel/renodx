#define CLASSIC_GRADE_CONSTANT_COUNT 16
#include "./final_grade.hlsli"

// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 11:52:20 2026
Texture2D<float4> t2 : register(t2);

Texture2D<float4> t0 : register(t0);

SamplerState s2_s : register(s2);

SamplerState s0_s : register(s0);

cbuffer cb3 : register(b3)
{
  float4 cb3[16];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = t0.SampleLevel(s0_s, v1.xy, 0).xyz;
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31 && RENODX_PEAK_WHITE_NITS > 0.f) {
    uint width, height;
    t0.GetDimensions(width, height);
    if (CUSTOM_SHARPENING_MODE != 0.f && CUSTOM_SHARPENING > 0.f)
      r0.xyz = WitcherSampleFringe(t0, v1.xy, uint2(width, height));
    r0.xyz = WitcherApplyChromaticAberration(r0.xyz, t0, v1.xy, uint2(width, height));
  }
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31 && RENODX_PEAK_WHITE_NITS > 0.f) {
    o0 = float4(ClassicGradeAndMap(r0.xyz, v1.xy, w1.xy, cb3, true, t2.Sample(s2_s, w1.xy).x), 1.f);
    return;
  }
  r0.xyz = log2(abs(r0.xyz));
  r0.xyz = cb3[8].xxx * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = r0.xyz * cb3[14].xxx + cb3[14].yyy;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.xyz = log2(r0.xyz);
  r0.xyz = cb3[14].zzz * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.w = dot(float3(0.298999995,0.587000012,0.114), r0.xyz);
  r0.xyz = min(float3(1,1,1), r0.xyz);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(2.20000005,2.20000005,2.20000005) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r1.xy = -cb3[10].xz + r0.ww;
  r1.xy = saturate(cb3[10].yw * r1.xy);
  r2.xyzw = -cb3[12].xyzw + cb3[11].xyzw;
  r2.xyzw = r1.xxxx * r2.xyzw + cb3[12].xyzw;
  r3.xyzw = cb3[13].xyzw + -r2.xyzw;
  r1.xyzw = r1.yyyy * r3.xyzw + r2.xyzw;
  r0.w = dot(float3(0.212599993,0.715200007,0.0722000003), r0.xyz);
  r0.xyz = r0.xyz + -r0.www;
  r0.xyz = r0.xyz * r1.www + r0.www;
  r0.xyz = saturate(r0.xyz * r1.xyz);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.454545468,0.454545468,0.454545468) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r1.xyz = -r0.xyz * cb3[9].xyz + cb3[7].xyz;
  r0.xyz = cb3[9].xyz * r0.xyz;
  r2.xyz = log2(r0.xyz);
  r2.xyz = float3(2.20000005,2.20000005,2.20000005) * r2.xyz;
  r2.xyz = exp2(r2.xyz);
  r0.w = dot(r2.xyz, cb3[6].xyz);
  r0.w = saturate(1 + -r0.w);
  r0.w = cb3[6].w * r0.w;
  r1.w = t2.Sample(s2_s, w1.xy).x;
  r0.w = saturate(r1.w * r0.w);
  r0.xyz = r0.www * r1.xyz + r0.xyz;
  r0.w = cb3[15].y + -cb3[15].x;
  o0.xyz = saturate(r0.xyz * r0.www + cb3[15].xxx);
  // Keep Vanilla at 203 nits independently of HDR transport/UI white.
  if (RENODX_GRAPHICS_WHITE_NITS > 0.f) {
    o0.xyz *= pow(203.f / RENODX_GRAPHICS_WHITE_NITS, 1.f / 2.2f);
  }
  o0.w = 1;
  return;
}