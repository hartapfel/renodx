#include "final_effects.hlsli"

// BlitzFX 1.1.0 final grade. Borders, dither and diagnostic views remain native.
// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 21:36:41 2026
Texture2D<float4> t69 : register(t69);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

cbuffer cb3 : register(b3)
{
  float4 cb3[18];
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
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;
  const bool custom = RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31
      && RENODX_PEAK_WHITE_NITS > 0.f && asuint(cb1[43].w) == 0;

  r0.xy = cb3[17].zw * v0.xy;
  r1.xyz = t0.SampleLevel(s1_s, r0.xy, 0).xyz;
  r0.zw = cb3[17].zw * v0.xy + -cb3[17].xy;
  r0.zw = r0.zw / cb3[17].xy;
  r1.w = dot(r0.zw, r0.zw);
  r1.w = sqrt(r1.w);
  r2.x = -cb3[16].y + r1.w;
  r2.x = saturate(cb3[16].z * r2.x);
  r2.y = cmp(0 < r2.x);
  if (r2.y != 0 && !(custom && CUSTOM_CA_MODE != 0.f)) {
    r2.x = r2.x * r2.x;
    r2.x = cb3[16].x * r2.x;
    r1.w = max(9.99999975e-005, r1.w);
    r1.w = r2.x / r1.w;
    r0.zw = r1.ww * r0.zw;
    r0.zw = cb3[17].zw * r0.zw;
    r0.xy = r0.zw * float2(-2,-2) + r0.xy;
    r1.x = t0.SampleLevel(s1_s, r0.xy, 0).x;
    r0.xy = cb3[17].zw * v0.xy + -r0.zw;
    r1.y = t0.SampleLevel(s1_s, r0.xy, 0).y;
  }
  if (custom) {
    const float2 scene_uv = cb3[17].zw * v0.xy;
    r1.xyz = BlitzSampleFinalEffects(t0, r1.xyz, scene_uv, r2.y != 0, r0.zw);
    r0.xyz = ClassicGradeAndMap(r1.xyz, scene_uv, w1.xy, cb3,
        cb1[44].y < 0.001f, -1.f, asuint(cb1[43].y) != 0);
  } else {
  r0.xyz = log2(abs(r1.xyz));
  r0.xyz = cb3[8].xxx * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r1.xyz = r0.xyz * cb3[14].xxx + cb3[14].yyy;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r1.xyz = log2(r1.xyz);
  r1.xyz = cb3[14].zzz * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.w = dot(float3(0.298999995,0.587000012,0.114), r1.xyz);
  r1.xyz = min(float3(1,1,1), r1.xyz);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(2.20000005,2.20000005,2.20000005) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r2.xy = -cb3[10].xz + r0.ww;
  r2.xy = saturate(cb3[10].yw * r2.xy);
  r3.xyzw = -cb3[12].xyzw + cb3[11].xyzw;
  r3.xyzw = r2.xxxx * r3.xyzw + cb3[12].xyzw;
  r4.xyzw = cb3[13].xyzw + -r3.xyzw;
  r2.xyzw = r2.yyyy * r4.xyzw + r3.xyzw;
  r0.w = dot(float3(0.212599993,0.715200007,0.0722000003), r1.xyz);
  r1.xyz = r1.xyz + -r0.www;
  r1.xyz = r1.xyz * r2.www + r0.www;
  r1.xyz = saturate(r1.xyz * r2.xyz);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454545468,0.454545468,0.454545468) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.xyz = asuint(cb1[43].y) != 0 ? r1.xyz : r0.xyz;
  r1.xyz = cb3[9].xyz * r0.xyz;
  r0.w = cmp(cb1[44].y < 0.00100000005);
  if (r0.w != 0) {
    r2.xy = float2(-0.5,-0.5) + w1.xy;
    r0.w = dot(r2.xy, r2.xy);
    r0.w = sqrt(r0.w);
    r0.w = r0.w * 2 + -0.550000012;
    r2.w = saturate(1.21951222 * r0.w);
    r2.z = r2.w * r2.w;
    r2.xy = r2.zz * r2.zw;
    r0.w = dot(float4(-0.100000001,-0.104999997,1.12,0.0900000036), r2.xyzw);
    r0.w = min(0.939999998, r0.w);
  } else {
    r0.w = 0;
  }
  r2.xyz = log2(r1.xyz);
  r2.xyz = float3(2.20000005,2.20000005,2.20000005) * r2.xyz;
  r2.xyz = exp2(r2.xyz);
  r1.w = dot(r2.xyz, cb3[6].xyz);
  r1.w = saturate(1 + -r1.w);
  r1.w = cb3[6].w * r1.w;
  r0.w = saturate(r1.w * r0.w);
  r0.xyz = -r0.xyz * cb3[9].xyz + cb3[7].xyz;
  r0.xyz = r0.www * r0.xyz + r1.xyz;
  r0.w = cb3[15].y + -cb3[15].x;
  r0.xyz = saturate(r0.xyz * r0.www + cb3[15].xxx);
  if (RENODX_GRAPHICS_WHITE_NITS > 0.f)
    r0.xyz *= pow(203.f / RENODX_GRAPHICS_WHITE_NITS, 1.f / 2.2f);
  }
  r1.xy = (uint2)v0.xy;
  r2.xy = (int2)r1.xy & int2(255,255);
  r2.zw = float2(0,0);
  r1.xzw = t69.Load(r2.xyz).xyz;
  r1.xzw = r1.xzw * float3(2,2,2) + float3(-0.5,-0.5,-0.5);
  r0.xyz = r1.xzw * float3(0.00392156886,0.00392156886,0.00392156886) + r0.xyz;
  r0.w = cmp(cb1[43].z != 1.000000);
  r1.x = cb0[23].w + cb0[23].w;
  r1.y = (uint)r1.y;
  r1.y = -cb0[23].y * 0.5 + r1.y;
  r1.x = abs(r1.y) * r1.x;
  r1.x = cmp(r1.x < cb1[43].z);
  r1.x = r1.x ? 1.000000 : 0;
  r0.w = r0.w ? r1.x : 1;
  r0.xyz = r0.xyz * r0.www;
  if (asuint(cb1[43].w) != 0) {
    r1.xy = (int2)v0.xy;
    r0.w = cmp(asuint(cb1[43].w) < 4);
    if (r0.w != 0) {
      r0.w = cmp(asuint(cb1[43].w) < 2);
      if (r0.w != 0) {
        r1.z = 0;
        r0.w = t1.Load(r1.xyz).x;
        r0.w = max(0.00100000005, r0.w);
        r0.w = 1 / r0.w;
        r0.xyz = float3(0.00100000005,0.00100000005,0.00100000005) * r0.www;
      } else {
        r0.w = cmp(asint(cb1[43].w) == 2);
        if (r0.w != 0) {
          r1.w = 0;
          r0.xyz = t2.Load(r1.xyw).xyz;
        } else {
          r0.w = cmp(asint(cb1[43].w) == 3);
          if (r0.w != 0) {
            r1.zw = float2(0,0);
            r0.xyz = t3.Load(r1.xyz).xyz;
          }
        }
      }
    } else {
      r0.w = cmp(asuint(cb1[43].w) < 6);
      if (r0.w != 0) {
        r0.w = cmp(asint(cb1[43].w) == 4);
        if (r0.w != 0) {
          r1.zw = float2(0,0);
          r0.w = t3.Load(r1.xyz).w;
          r0.xyz = r0.www;
        } else {
          r0.w = cmp(asint(cb1[43].w) == 5);
          if (r0.w != 0) {
            r1.zw = float2(0,0);
            r0.xyz = t4.Load(r1.xyz).xyz;
          }
        }
      } else {
        r0.w = cmp(asint(cb1[43].w) == 6);
        if (r0.w != 0) {
          r1.zw = float2(0,0);
          r0.w = t5.Load(r1.xyz).x;
          r0.xyz = r0.www;
        } else {
          r0.w = cmp(asint(cb1[43].w) == 7);
          if (r0.w != 0) {
            r1.zw = float2(0,0);
            r0.w = t5.Load(r1.xyz).y;
            r0.xyz = r0.www;
          }
        }
      }
    }
  }
  o0.xyz = r0.xyz;
  o0.w = 1;
  return;
}
