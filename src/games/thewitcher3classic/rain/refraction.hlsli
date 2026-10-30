// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_RAIN
#define WITCHER_CLASSIC_RAIN
#include "../blitzfx/scene_pool.hlsli"
Texture2D<float4> ClassicRainScene : register(t6);
StructuredBuffer<float4> ClassicRainParameters : register(t110);
SamplerState ClassicRainSampler : register(s10);
bool ClassicRainReady() {
  uint count,stride;
  ClassicRainParameters.GetDimensions(count,stride);
  return count == 1 && ClassicRainParameters[0].x == 1.f;
}
// Adapted from the captured BlitzFX refractive rain pass: four gradient-
// filtered atlas taps, paired refraction samples, native depth/fog fades and
// 400x coverage. The native full-size HDR copy replaces BlitzFX's half-size
// t50. This returns its premultiplied second pass for single-draw composition.
float4 ClassicRainRefraction(float4 v0,float4 v1,float4 v2,float4 v3,float4 v4,float3 v5,float4 v6) {
  float4 result;
  uint color_width, color_height;
  ClassicRainScene.GetDimensions(color_width, color_height);
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = cb0[0].xx * cb4[1].xy;
  r0.xy = v1.yz * cb4[0].xy + r0.xy;
  r1.x = 1 / cb4[2].x;
  r1.y = 1 / cb4[3].x;
  r0.z = floor(v1.x);
  r2.x = r0.z * r1.x;
  r0.z = v1.x * r1.x;
  r0.z = floor(r0.z);
  r2.y = r0.z * r1.y;
  r0.zw = r1.xy * r0.xy;
  r1.zw = r0.xy * r1.xy + r2.xy;
  r2.xy = ddx_coarse(r0.zw);
  r0.zw = ddy_coarse(r0.zw);
  r3.xyz = float3(1,-0.5,-0.5) + v1.xyz;
  r2.z = floor(r3.x);
  r4.x = r2.z * r1.x;
  r2.z = r3.x * r1.x;
  r2.z = floor(r2.z);
  r4.y = r2.z * r1.y;
  r0.xy = r0.xy * r1.xy + r4.xy;
  r1.x = frac(v1.x);
  r2.zw = r2.xy * float2(0.25,0.25) + r1.zw;
  r2.zw = r0.zw * float2(0.25,0.25) + r2.zw;
  r4.xyzw = t0.Sample(s0_s, r2.zw).xyzw;
  r2.zw = r2.xy * float2(0.25,0.25) + r0.xy;
  r2.zw = r0.zw * float2(0.25,0.25) + r2.zw;
  r5.xyzw = t0.Sample(s0_s, r2.zw).xyzw;
  r5.xyzw = r5.xyzw + -r4.xyzw;
  r4.xyzw = r1.xxxx * r5.xyzw + r4.xyzw;
  r1.yz = -r2.xy * float2(0.25,0.25) + r1.zw;
  r1.yz = -r0.zw * float2(0.25,0.25) + r1.yz;
  r5.xyzw = t0.Sample(s0_s, r1.yz).xyzw;
  r0.xy = -r2.xy * float2(0.25,0.25) + r0.xy;
  r0.xy = -r0.zw * float2(0.25,0.25) + r0.xy;
  r0.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r0.xyzw = r0.xyzw + -r5.xyzw;
  r0.xyzw = r1.xxxx * r0.xyzw + r5.xyzw;
  r1.x = 0.5 * r0.w;
  r1.x = r4.w * 0.5 + r1.x;
  // These depth/fog UVs already use output-pool reciprocals in cb0. The
  // refracted ClassicRainScene samples below instead use render reciprocals from cb3.
  r1.yz = cb0[1].zw * v6.xy;
  r1.w = t15.SampleLevel(s15_s, r1.yz, 0).x;
  r1.w = r1.w * cb12[22].x + cb12[22].y;
  r1.w = r1.w * cb12[21].x + cb12[21].y;
  r1.w = max(9.99999975e-005, r1.w);
  r1.w = 1 / r1.w;
  r2.x = cmp(cb12[67].w >= 0);
  if (r2.x != 0) {
    r2.yz = t24.Sample(s8_s, r1.yz).yx;
    r5.xyz = -cb12[0].xyz + v5.xyz;
    r1.y = dot(r5.xyz, r5.xyz);
    r1.y = sqrt(r1.y);
    r6.x = cb12[1].z;
    r6.y = cb12[2].z;
    r6.z = cb12[3].z;
    r1.z = dot(r6.xyz, r5.xyz);
    r2.w = 1 / cb12[21].y;
    r2.w = r2.w * r1.y;
    r1.z = r2.w / r1.z;
    r1.z = -r1.z + r1.y;
    r1.z = saturate(cb13[33].w * r1.z);
    r1.z = cb13[33].z * r1.z;
    r1.z = max(0.00100000005, r1.z);
    r2.x = r1.y / cb13[34].z;
    r5.xyzw = cmp(r2.xyxz < r2.zxyx);
    r1.y = cb13[34].z * r2.z + -cb13[34].x;
    r6.w = saturate(-r1.y * cb13[34].y + 1);
    r2.xw = r2.xx + -r2.zy;
    r2.xw = cb13[34].zz * r2.xw;
    r1.yz = saturate(r2.xw / r1.zz);
    r6.y = r1.y * r6.w;
    r1.y = (int)r5.y | (int)r5.x;
    r1.y = (int)r1.y;
    r1.y = cmp(0 != r1.y);
    r6.xz = float2(1,1);
    r2.xw = r1.yy ? float2(0,1) : r6.xy;
    r2.yz = cmp(r2.zy < r2.yz);
    r5.y = 1 + -r1.z;
    r5.x = 1;
    r1.yz = r5.ww ? r6.zw : r5.xy;
    r1.yz = r5.zz ? float2(1,1) : r1.yz;
    r1.yz = r2.zz ? r1.yz : float2(0,1);
    r1.yz = r2.yy ? r2.xw : r1.yz;
    r1.y = -r1.z * r1.y + 1;
  } else {
    r1.y = 0;
  }
  r1.y = r1.y * r0.w + -r0.w;
  r0.w = cb4[9].x * r1.y + r0.w;
  r1.yz = r3.yz * r3.yz;
  r1.yz = -r1.yz * r1.yz + float2(1,1);
  r1.y = r1.y * r1.z;
  r1.y = log2(r1.y);
  r1.y = cb4[11].x * r1.y;
  r1.y = exp2(r1.y);
  r1.y = min(1, r1.y);
  r1.z = r0.w * cb0[7].y + -r0.w;
  r0.w = cb4[10].x * r1.z + r0.w;
  r1.z = -v1.w + r1.w;
  r1.z = saturate(cb4[8].x * r1.z);
  r1.w = -1 + v4.w;
  r1.y = r0.w * r1.y + -r0.w;
  r0.w = cb4[12].x * r1.y + r0.w;
  r0.w = r1.w + r0.w;
  r0.w = r0.w * r1.z;
  r0.w = saturate(cb4[13].x * r0.w);
  r0.w = r1.x * r0.w;
  r0.w = cb2[2].x * r0.w;
  r1.x = saturate(1 + -v2.w);
  r1.x = cb2[2].w * r1.x;
  r0.w = r1.x * r0.w;
  r1.x = cmp(0 >= r0.w);
  if (r1.x != 0) return float4(0,0,0,0);
  r1.xyz = float3(-0.5,-0.5,-0.5) + r4.xyz;
  r1.xyz = cb4[4].xyz * r1.xyz;
  r1.xyz = r1.xyz + r1.xyz;
  r1.z = dot(r1.xyz, r1.xyz);
  r1.z = rsqrt(r1.z);
  r1.xy = r1.xy * r1.zz;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = cb4[4].xyz * r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r0.z = dot(r0.xyz, r0.xyz);
  r0.z = rsqrt(r0.z);
  r0.xy = r0.xy * r0.zz;
  r2.x = cb12[23].y * cb12[23].z;
  r2.y = 0.300000012;
  r1.xy = r2.xy * r1.xy;
  r1.z = 0.300000012 * r1.x;
  r1.xy = v6.xy * cb12[23].zw + r1.zy;
  r1.xyz = ClassicRainScene.SampleLevel(ClassicRainSampler, BlitzScenePoolUV(r1.xy, cb12[23].xy, float2(color_width, color_height)), 0).xyz;
  r0.xy = r2.xy * r0.xy;
  r0.z = 0.300000012 * r0.x;
  r0.xy = v6.xy * cb12[23].zw + r0.zy;
  r0.xyz = ClassicRainScene.SampleLevel(ClassicRainSampler, BlitzScenePoolUV(r0.xy, cb12[23].xy, float2(color_width, color_height)), 0).xyz;
  r0.xyz = r1.xyz + r0.xyz;
  r0.xyz = float3(0.5,0.5,0.5) * r0.xyz;
  r0.w = 400 * r0.w;
  r0.w = min(1, r0.w);
  result.xyz = r0.xyz * r0.www;
  result.w = r0.w;
  return result;
}
#endif
