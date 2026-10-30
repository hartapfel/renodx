#include "../volumetrics/sample.hlsli"
#include "scene_pool.hlsli"
#include "../water/shading.hlsli"

// BlitzFX water: convert render UVs only when sampling the native scene pool.
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 24 00:35:12 2026
Texture2D<float4> t24 : register(t24);

Texture2DArray<float4> t19 : register(t19);

Texture2D<float4> t17 : register(t17);

Texture2D<float4> t15 : register(t15);

Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float4> t8 : register(t8);

Texture2D<float4> t7 : register(t7);

Texture2D<float4> t6 : register(t6);

Texture2D<float4> t5 : register(t5);

Texture2DArray<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

SamplerState s15_s : register(s15);

SamplerState s14_s : register(s14);

SamplerState s10_s : register(s10);

SamplerComparisonState s9_s : register(s9);

SamplerState s7_s : register(s7);

SamplerState s5_s : register(s5);

SamplerState s4_s : register(s4);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

cbuffer cb12 : register(b12)
{
  float4 cb12[69];
}

cbuffer cb13 : register(b13)
{
  float4 cb13[3323];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[11];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[116];
}

cbuffer cb5 : register(b5)
{
  float4 cb5[1];
}

cbuffer cb7 : register(b7)
{
  float4 cb7[1];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[3];
}

cbuffer cb6 : register(b6)
{
  float4 cb6[49];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[2];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[210];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  float w1 : TEXCOORD2,
  float4 v2 : TEXCOORD3,
  float4 v3 : TEXCOORD4,
  float4 v4 : TEXCOORD5,
  uint v5 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float o2 : SV_Target2)
{

  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v0.xy / cb0[1].xy;
  r1.xy = float2(2.5,2.5) / cb0[2].xy;
  r2.x = -r1.x;
  r2.z = 0;
  r0.zw = saturate(r0.xy * float2(0.5,0.5) + r2.xz);
  r0.z = t3.Sample(s3_s, r0.zw).z;
  r1.z = 0;
  r2.xyzw = saturate(r0.xyxy * float4(0.5,0.5,0.5,0.5) + r1.xzzy);
  r0.w = t3.Sample(s3_s, r2.xy).z;
  r3.x = r0.z + -r0.w;
  r0.w = t3.Sample(s3_s, r2.zw).z;
  r1.w = -r1.y;
  r1.xy = saturate(r0.xy * float2(0.5,0.5) + r1.zw);
  r1.x = t3.Sample(s3_s, r1.xy).z;
  r3.y = -r1.x + r0.w;
  r3.z = 1;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  r1.xy = -cb1[8].xy + v2.xy;
  r1.x = dot(r1.xy, r1.xy);
  r1.x = sqrt(r1.x);
  r1.yz = float2(350,2000) + -r1.xx;
  r1.yz = float2(0.00285714283,0.000500000024) * r1.yz;
  r1.yz = max(float2(0,0), r1.yz);
  r1.w = r1.y * r1.y;
  r1.w = r1.w * r1.w;
  r2.x = r1.w * r1.w;
  r4.xyzw = v1.xyxy / cb4[0].xxzz;
  r5.xyzw = float4(512,512,512,512) * r4.xyzw;
  r6.xyzw = ddx_coarse(r5.xyzw);
  r5.xyzw = ddy_coarse(r5.xyzw);
  r2.y = dot(r6.xy, r6.xy);
  r2.z = dot(r5.xy, r5.xy);
  r2.y = max(r2.y, r2.z);
  r2.y = log2(r2.y);
  r2.zw = t5.SampleLevel(s5_s, r4.xy, 0).xy;
  r3.w = dot(r6.zw, r6.zw);
  r5.x = dot(r5.zw, r5.zw);
  r3.w = max(r5.x, r3.w);
  r3.w = log2(r3.w);
  r5.xy = saturate(float2(0.0500000007,0.0357142873) * r3.ww);
  r5.xy = float2(1,1) + -r5.xy;
  t17.GetDimensions(0, fDest.x, fDest.y, fDest.z);
  r3.w = fDest.x;
  r3.w = (int)r3.w;
  r6.yzw = float3(0,0,0);
  r5.zw = float2(0,0);
  r7.x = 0;
  while (true) {
    r7.y = (int)r5.w;
    r7.z = cmp((int)r7.y >= (int)r3.w);
    if (r7.z != 0) {
      r7.x = 0;
      break;
    }
    r6.x = (int)r5.w;
    r8.xyzw = t17.Load(r6.xyz).xyzw;
    r7.zw = cmp(r8.xy < v2.xy);
    r6.x = r7.z ? -1.000000 : 0;
    r8.xy = cmp(v2.xy < r8.zw);
    r6.x = r8.x ? r6.x : 0;
    r6.x = r7.w ? r6.x : 0;
    r6.x = r8.y ? r6.x : 0;
    r7.z = cmp(r6.x != 0.000000);
    if (r7.z != 0) {
      r5.z = r5.w;
      r7.x = -1;
      break;
    }
    r7.y = (int)r7.y + 1;
    r5.w = (int)r7.y;
    r7.x = r6.x;
    r5.z = 0;
  }
  r3.w = cmp(0 != r7.x);
  r6.z = r3.w ? r5.z : -1;
  r3.w = (int)r6.z;
  r3.w = cmp((int)r3.w >= 0);
  if (r3.w != 0) {
    r7.x = (int)r6.z;
    r7.yzw = float3(0,0,0);
    r7.xyzw = t17.Load(r7.xyz).xyzw;
    r8.x = (int)r6.z;
    // Native ld addresses row 1. The decompiler printed integer bits 1 as a
    // subnormal float; converting that float to a Load coordinate selects 0.
    r8.yzw = float3(1,0,0);
    r8.xyzw = t17.Load(r8.xyz).xyzw;
    t4.GetDimensions(0, fDest.x, fDest.y, fDest.z, fDest.w);
    r5.zw = fDest.xy;
    r9.xy = v2.xy + -r7.xy;
    r7.xy = r7.zw + -r7.xy;
    r7.xy = r9.xy / r7.xy;
    r5.zw = float2(0.5,0.5) / r5.zw;
    r5.zw = abs(r7.xy) + r5.zw;
    r7.xy = r8.zw + -r8.xy;
    r6.xy = r5.zw * r7.xy + r8.xy;
    r3.w = t4.SampleLevel(s4_s, r6.xyz, 0).x;
    r3.w = saturate(r3.w);
    r5.z = cb5[0].y + -cb5[0].x;
    r3.w = r3.w * r5.z + cb5[0].x;
  } else {
    r3.w = -10;
  }
  r3.w = v2.z + -r3.w;
  r5.z = cmp(r3.w >= 0);
  r5.w = r3.w * 2 + -9.5;
  r5.w = r5.z ? r5.w : r3.w;
  r6.x = saturate(-0.100000001 * r5.w);
  r5.w = saturate(0.333333343 * cb7[0].y);
  r5.w = r5.w * 0.75 + 0.25;
  r6.z = 1.5 + -r6.x;
  r6.y = r6.z * r5.w;
  r6.z = 0.5 * r5.w;
  r5.w = -r5.w * 0.5 + 0.100000001;
  r7.y = r6.x * r5.w + r6.z;
  r7.x = max(0.800000012, r6.x);
  r6.xy = r5.zz ? r6.xy : r7.xy;
  r5.w = 0.5 * r6.y;
  r5.x = 20 * r5.x;
  r5.x = max(2, r5.x);
  r6.yz = float2(3.20000005,3.20000005) * r4.zw;
  r7.xy = float2(4,4.34000015) * cb0[0].xx;
  r4.z = r4.w * 19.2000008 + r7.x;
  sincos(r4.z, r7.x, r8.x);
  r4.z = -1 + r7.x;
  r4.z = 1.44269502 * r4.z;
  r4.z = exp2(r4.z);
  r4.w = r4.z * r8.x;
  r6.w = r8.x * r5.w;
  r4.z = r6.w * r4.z;
  r8.y = 6 * r4.z;
  r4.z = -r4.w * r5.w;
  r4.zw = r4.zz * float2(0,0.0359999985) + r6.yz;
  r6.y = dot(float2(-0.675486088,-0.737372696), r4.zw);
  r6.y = r6.y * 7.07999992 + r7.y;
  sincos(r6.y, r7.x, r9.x);
  r6.y = -1 + r7.x;
  r6.y = 1.44269502 * r6.y;
  r6.y = exp2(r6.y);
  r6.z = r7.x * 0.5 + 0.5;
  r6.z = r6.z + -r6.y;
  r6.z = r6.z * 0.00122499769 + r6.y;
  r6.z = r6.z * r9.x;
  r6.w = r9.x * r5.w;
  r6.zw = float2(0.998775005,7.07999992) * r6.zw;
  r7.x = 0.5 + -r6.y;
  r6.y = r7.x * 0.00122499769 + r6.y;
  r6.y = r6.y * r6.w;
  r6.z = -r6.z * r5.w;
  r4.zw = r6.zz * float2(-0.0189676471,-0.0207054242) + r4.zw;
  r8.xz = float2(0,1);
  r6.yz = r6.yy * float2(-0.526879132,-0.575150669) + r8.xy;
  r6.w = cmp(2 < r5.x);
  if (r6.w != 0) {
    r6.w = dot(float2(0.996170044,0.0874373689), r4.zw);
    r7.x = 4.70890045 * cb0[0].x;
    r6.w = r6.w * 8.35439968 + r7.x;
    sincos(r6.w, r7.x, r8.x);
    r6.w = -1 + r7.x;
    r6.w = 1.44269502 * r6.w;
    r6.w = exp2(r6.w);
    r7.x = r7.x * 0.5 + 0.5;
    r7.x = r7.x + -r6.w;
    r7.x = r7.x * 0.00507299043 + r6.w;
    r7.x = r7.x * r8.x;
    r7.y = r8.x * r5.w;
    r7.xy = float2(0.994926989,8.35439968) * r7.xy;
    r7.z = 0.5 + -r6.w;
    r6.w = r7.z * 0.00507299043 + r6.w;
    r6.w = r6.w * r7.y;
    r7.x = -r7.x * r5.w;
    r4.zw = r7.xx * float2(0.0218185131,0.00191508816) + r4.zw;
    r6.yz = r6.ww * float2(0.606069863,0.0531968959) + r6.yz;
    r7.z = 2.38840008;
    r6.w = 3;
  } else {
    r7.z = 1.77999997;
    r6.w = 2;
  }
  r7.w = (int)r6.w;
  r7.w = cmp(r7.w < r5.x);
  if (r7.w != 0) {
    r8.x = dot(float2(-0.79361099,0.608425558), r4.zw);
    r8.y = 5.10915709 * cb0[0].x;
    r8.x = r8.x * 9.85819149 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.0118195601 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.988180459 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 9.85819149 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.0118195601 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(-0.0135579472,0.0103942631) + r4.zw;
    r6.yz = r8.yy * float2(-0.376609653,0.288729548) + r6.yz;
    r7.z = 2.86295199;
    r6.w = 4;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(0.17420496,-0.984709442), r4.zw);
    r8.y = 5.54343557 * cb0[0].x;
    r8.x = r8.x * 11.6326656 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.0217630137 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.978236973 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 11.6326656 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.0217630137 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(0.00232135411,-0.0131216655) + r4.zw;
    r6.yz = r8.yy * float2(0.0644820631,-0.364490718) + r6.yz;
    r7.z = 3.23310256;
    r6.w = 5;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(0.536702573,0.843771517), r4.zw);
    r8.y = 6.01462793 * cb0[0].x;
    r8.x = r8.x * 13.7265444 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.0352261104 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.964773893 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 13.7265444 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.0352261104 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(0.00557839358,0.00877001509) + r4.zw;
    r6.yz = r8.yy * float2(0.154955387,0.243611529) + r6.yz;
    r7.z = 3.52182007;
    r6.w = 6;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(-0.965706289,-0.259636909), r4.zw);
    r8.y = 6.52587175 * cb0[0].x;
    r8.x = r8.x * 16.1973209 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.0525579453 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.947442055 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 16.1973209 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.0525579453 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(-0.0078291595,-0.00210492429) + r4.zw;
    r6.yz = r8.yy * float2(-0.217476651,-0.0584701225) + r6.yz;
    r7.z = 3.74701977;
    r6.w = 7;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(0.887468457,-0.460868478), r4.zw);
    r8.y = 7.08057117 * cb0[0].x;
    r8.x = r8.x * 19.1128387 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.0741359293 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.9258641 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 19.1128387 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.0741359293 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(0.00561199943,-0.00291434978) + r4.zw;
    r6.yz = r8.yy * float2(0.15588887,-0.0809541643) + r6.yz;
    r7.z = 3.92267537;
    r6.w = 8;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(-0.343082547,0.939305246), r4.zw);
    r8.y = 7.68241978 * cb0[0].x;
    r8.x = r8.x * 22.5531483 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.100367829 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.899632156 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 22.5531483 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.100367829 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(-0.00169222418,0.0046330397) + r4.zw;
    r6.yz = r8.yy * float2(-0.0470062271,0.128695548) + r6.yz;
    r7.z = 4.05968666;
    r6.w = 9;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(-0.381509542,-0.924364924), r4.zw);
    r8.y = 8.33542538 * cb0[0].x;
    r8.x = r8.x * 26.6127129 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.131694257 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.868305743 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 26.6127129 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.131694257 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(-0.00146777427,-0.00355629111) + r4.zw;
    r6.yz = r8.yy * float2(-0.0407715067,-0.0987858698) + r6.yz;
    r7.z = 4.1665554;
    r6.w = 10;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(0.905708671,0.423900694), r4.zw);
    r8.y = 9.04393673 * cb0[0].x;
    r8.x = r8.x * 31.4029999 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.168591037 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.831408978 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 31.4029999 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.168591037 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(0.00271792198,0.00127207465) + r4.zw;
    r6.yz = r8.yy * float2(0.0754978359,0.0353354104) + r6.yz;
    r7.z = 4.24991322;
    r6.w = 11;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(-0.954185069,0.299217165), r4.zw);
    r8.y = 9.81267166 * cb0[0].x;
    r8.x = r8.x * 37.0555382 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.211571738 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.788428247 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 37.0555382 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.211571738 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(-0.00223344727,0.000700373319) + r4.zw;
    r6.yz = r8.yy * float2(-0.062040206,0.0194548145) + r6.yz;
    r7.z = 4.31493235;
    r6.w = 12;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(0.501466155,-0.865177274), r4.zw);
    r8.y = 10.6467495 * cb0[0].x;
    r8.x = r8.x * 43.7255325 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.261190623 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.738809347 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 43.7255325 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.261190623 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(0.000915544224,-0.0015795842) + r4.zw;
    r6.yz = r8.yy * float2(0.0254317839,-0.0438773409) + r6.yz;
    r7.z = 4.36564732;
    r6.w = 13;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(0.214643925,0.976692379), r4.zw);
    r8.y = 11.5517235 * cb0[0].x;
    r8.x = r8.x * 51.5961266 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.318045735 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.681954265 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 51.5961266 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.318045735 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(0.000305668655,0.00139088149) + r4.zw;
    r6.yz = r8.yy * float2(0.0084907962,0.0386355966) + r6.yz;
    r7.z = 4.40520477;
    r6.w = 14;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(-0.818012476,-0.575200498), r4.zw);
    r8.y = 12.5336208 * cb0[0].x;
    r8.x = r8.x * 60.8834267 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.382782042 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.617217958 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 60.8834267 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.382782042 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(-0.000908629561,-0.000638919533) + r4.zw;
    r6.yz = r8.yy * float2(-0.0252397116,-0.0177477673) + r6.yz;
    r7.z = 4.43605947;
    r6.w = 15;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(0.991719007,-0.12842688), r4.zw);
    r8.y = 13.598979 * cb0[0].x;
    r8.x = r8.x * 71.8424377 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.45609498 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.54390502 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 71.8424377 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.45609498 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(0.000859231455,-0.000111269845) + r4.zw;
    r6.yz = r8.yy * float2(0.0238675419,-0.00309082912) + r6.yz;
    r7.z = 4.4601264;
    r6.w = 16;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(-0.644518971,0.764588296), r4.zw);
    r8.y = 14.7548923 * cb0[0].x;
    r8.x = r8.x * 84.7740707 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.538734257 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.461265743 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 84.7740707 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.538734257 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(-0.000435563881,0.000516706321) + r4.zw;
    r6.yz = r8.yy * float2(-0.0120989969,0.014352954) + r6.yz;
    r7.z = 4.47889853;
    r6.w = 17;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(-0.0412140824,-0.999150336), r4.zw);
    r8.y = 16.009058 * cb0[0].x;
    r8.x = r8.x * 100.033401 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.631507754 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.368492246 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 100.033401 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.631507754 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(-2.17248289e-005,-0.000526673626) + r4.zw;
    r6.yz = r8.yy * float2(-0.000603467517,-0.0146298241) + r6.yz;
    r7.z = 4.49354076;
    r6.w = 18;
  }
  r8.x = (int)r6.w;
  r8.x = cmp(r8.x < r5.x);
  r7.w = r7.w ? r8.x : 0;
  if (r7.w != 0) {
    r8.x = dot(float2(0.70530802,0.708900988), r4.zw);
    r8.y = 17.3698292 * cb0[0].x;
    r8.x = r8.x * 118.039406 + r8.y;
    sincos(r8.x, r8.x, r9.x);
    r8.y = -1 + r8.x;
    r8.y = 1.44269502 * r8.y;
    r8.y = exp2(r8.y);
    r8.x = r8.x * 0.5 + 0.5;
    r8.x = r8.x + -r8.y;
    r8.x = r8.x * 0.735285938 + r8.y;
    r8.x = r8.x * r9.x;
    r8.x = 0.264714062 * r8.x;
    r9.x = r9.x * r5.w;
    r9.x = 118.039406 * r9.x;
    r9.y = 0.5 + -r8.y;
    r8.y = r9.y * 0.735285938 + r8.y;
    r8.y = r8.y * r9.x;
    r8.x = -r8.x * r5.w;
    r4.zw = r8.xx * float2(0.00028999077,0.000291468052) + r4.zw;
    r6.yz = r8.yy * float2(0.00805529952,0.00809633452) + r6.yz;
    r7.z = 4.50496197;
    r6.w = 19;
  }
  r6.w = (int)r6.w;
  r5.x = cmp(r6.w < r5.x);
  r5.x = r5.x ? r7.w : 0;
  if (r5.x != 0) {
    r4.z = dot(float2(-0.998927474,-0.0463024341), r4.zw);
    r4.w = 18.8462658 * cb0[0].x;
    r4.z = r4.z * 139.286499 + r4.w;
    sincos(r4.z, r5.x, r8.x);
    r4.z = -1 + r5.x;
    r4.z = 1.44269502 * r4.z;
    r4.z = exp2(r4.z);
    r4.w = r8.x * r5.w;
    r4.w = 139.286499 * r4.w;
    r5.x = 0.5 + -r4.z;
    r4.z = r5.x * 0.851006508 + r4.z;
    r4.z = r4.z * r4.w;
    r6.yz = r4.zz * float2(-0.00889879931,-0.000412478461) + r6.yz;
    r7.z = 4.51387024;
  }
  r4.zw = r6.yz / r7.zz;
  r7.xy = -r4.zw;
  r4.z = dot(r7.xyz, r7.xyz);
  r4.z = rsqrt(r4.z);
  r4.zw = r7.xy * r4.zz;
  r4.zw = r4.zw * r5.yy;
  r7.xy = float2(0.00100000005,0.00100000005) * r4.zw;
  r4.z = 1 + -r6.x;
  r5.xy = r1.yy * float2(0,1) + float2(1,-1);
  r5.xy = r4.zz * r5.xy + float2(0,1);
  r1.y = cb4[3].z * r4.z;
  r6.xyzw = r1.yyyy * r2.zwzw + r4.xyxy;
  r9.xyzw = ddx_coarse(r6.zwzw);
  r10.xyzw = ddy_coarse(r6.zwzw);
  r11.xyzw = r9.xyzw * float4(0.125,0.125,0.375,0.375) + r6.zwzw;
  r2.zw = r10.xy * float2(0.375,0.375) + r11.xy;
  r4.xyw = t5.SampleLevel(s5_s, r2.zw, 0).xyz;
  r6.xyzw = -r9.xyzw * float4(0.125,0.125,0.375,0.375) + r6.xyzw;
  r2.zw = -r10.xy * float2(0.375,0.375) + r6.xy;
  r9.xyz = t5.SampleLevel(s5_s, r2.zw, 0).xyz;
  r9.xyw = r9.xyz + r4.xyw;
  r1.y = r9.z * r9.z;
  r1.y = r4.w * r4.w + r1.y;
  r2.zw = -r10.zw * float2(0.125,0.125) + r11.zw;
  r4.xyw = t5.SampleLevel(s5_s, r2.zw, 0).xyz;
  r9.xyz = r9.xyw + r4.xyw;
  r1.y = r4.w * r4.w + r1.y;
  r2.zw = r10.zw * float2(0.125,0.125) + r6.zw;
  r4.xyw = t5.SampleLevel(s5_s, r2.zw, 0).xyz;
  r6.xyz = r9.xyz + r4.xyw;
  r1.y = r4.w * r4.w + r1.y;
  r6.xyz = float3(0.25,0.25,0.25) * r6.xyz;
  r2.z = r6.z * r6.z;
  r1.y = r1.y * 0.25 + -r2.z;
  r1.y = max(0, r1.y);
  r1.y = sqrt(r1.y);
  r6.w = 0.000150000007;
  r2.z = dot(r6.xyw, r6.xyw);
  r2.z = rsqrt(r2.z);
  r4.xy = r5.xy * r1.zz;
  r5.xyw = r6.xyw * r2.zzz + float3(0,0,-1);
  r5.xyw = r4.xxx * r5.xyw + float3(0,0,1);
  r1.z = dot(r5.xyw, r5.xyw);
  r1.z = rsqrt(r1.z);
  r7.z = 0.00079999998;
  r2.z = dot(r7.xyz, r7.xyz);
  r2.z = rsqrt(r2.z);
  r6.xyz = r7.xyz * r2.zzz + float3(0,0,-1);
  r4.xyw = r4.yyy * r6.xyz + float3(0,0,1);
  r2.z = dot(r4.xyw, r4.xyw);
  r2.z = rsqrt(r2.z);
  r4.xyw = r4.xyw * r2.zzz;
  r4.xyw = float3(-1,-1,1) * r4.xyw;
  r2.z = dot(r4.xyw, r4.xyw);
  r2.z = rsqrt(r2.z);
  r4.xyw = r4.xyw * r2.zzz;
  r6.xyz = r4.xyw + r4.xyw;
  r4.xyw = r4.www * float3(0,0,4) + -r6.xyz;
  r2.z = dot(r4.xyw, r4.xyw);
  r2.z = rsqrt(r2.z);
  r4.xyw = r4.xyw * r2.zzz;
  r5.xyw = r5.xyw * r1.zzz + float3(0,0,1);
  r4.xyw = float3(-1,-1,1) * r4.xyw;
  r1.z = dot(r4.xyw, r4.xyw);
  r1.z = rsqrt(r1.z);
  r4.xyw = r4.xyw * r1.zzz;
  r1.z = dot(r5.xyw, r4.xyw);
  r4.xyw = r4.xyw * r5.www;
  r4.xyw = r5.xyw * r1.zzz + -r4.xyw;
  r1.z = dot(r4.xyw, r4.xyw);
  r1.z = rsqrt(r1.z);
  r4.xyw = r4.xyw * r1.zzz;
  r0.z = saturate(1 + -r0.z);
  r4.xy = r4.xy * r0.zz;
  r0.z = dot(r4.xyw, r4.xyw);
  r0.z = rsqrt(r0.z);
  r4.xyw = r4.xyw * r0.zzz;
  r2.zw = -cb4[4].xy + v2.xy;
  r2.zw = r2.zw * float2(0.0333333351,0.0333333351) + float2(0.5,0.5);
  r6.xyzw = t1.SampleLevel(s1_s, r2.zw, 0).zxyw;
  r2.zw = trunc(v0.xy);
  r5.xy = (int2)-r2.zw;
  r2.zw = (int2)r2.zw;
  r2.zw = max((int2)r5.xy, (int2)r2.zw);
  r2.zw = (int2)r2.zw;
  r2.zw = (uint2)r2.zw;
  r2.zw = (uint2)r2.zw >> int2(1,1);
  r2.zw = (uint2)r2.zw;
  r7.xy = (int2)r2.zw;
  r7.zw = float2(0,0);
  r2.zw = t24.Load(r7.xyz).xy;
  r5.xyw = -cb12[0].xyz + v2.xyz;
  r0.z = dot(r5.xyw, r5.xyw);
  r0.z = sqrt(r0.z);
  r7.x = cb12[1].z;
  r7.y = cb12[2].z;
  r7.z = cb12[3].z;
  r1.z = dot(r7.xyz, r5.xyw);
  r5.x = 1 / cb12[21].y;
  r5.x = r5.x * r0.z;
  r1.z = r5.x / r1.z;
  r1.z = -r1.z + r0.z;
  r1.z = saturate(cb13[33].w * r1.z);
  r1.z = cb13[33].z * r1.z;
  r1.z = max(0.00100000005, r1.z);
  r0.z = r0.z / cb13[34].z;
  r5.x = cb13[34].z * r2.z + -cb13[34].x;
  r9.y = saturate(-r5.x * cb13[34].y + 1);
  r5.xy = r0.zz + -r2.zw;
  r5.xy = cb13[34].zz * r5.xy;
  r5.xy = saturate(r5.xy / r1.zz);
  r8.w = r9.y * r5.x;
  r5.xw = cmp(r0.zz < r2.zw);
  r8.xy = cmp(r2.wz < r0.zz);
  r0.z = (int)r5.x | (int)r8.x;
  r8.xz = r0.zz ? float2(0,1) : r8.zw;
  r2.zw = cmp(r2.zw < r2.wz);
  r9.w = 1 + -r5.y;
  r9.xz = float2(1,1);
  r5.xy = r8.yy ? r9.xy : r9.zw;
  r5.xy = r5.ww ? float2(1,1) : r5.xy;
  r5.xy = r2.ww ? r5.xy : float2(0,1);
  r2.zw = r2.zz ? r8.xz : r5.xy;
  r0.z = -r2.w * r2.z + 1;
  r1.x = r1.x * -0.0500000007 + 1;
  r1.x = max(0, r1.x);
  r1.xz = r6.xw * r1.xx;
  r8.xy = r1.xz * r0.zz;
  r6.xw = float2(0.00499999989,0.00499999989);
  r1.x = dot(r6.yzw, r6.yzw);
  r1.x = rsqrt(r1.x);
  r6.xyzw = r6.xyzw * r1.xxxx;
  r8.z = 0.0500000007;
  r1.x = dot(r8.xyz, r8.xyz);
  r1.x = rsqrt(r1.x);
  r8.w = r6.w;
  r9.xyzw = r8.wxyw * r1.xxxx;
  r6.xyzw = r9.xyzw * r8.zwwz + r6.xyzw;
  r1.x = dot(r6.yzw, r6.yzw);
  r1.x = rsqrt(r1.x);
  r1.z = r6.x * r1.x;
  r1.z = r1.z * r0.w;
  r1.z = min(1, r1.z);
  r5.xyw = r1.zzz * float3(0.999989986,0.999989986,-39) + float3(9.99999975e-006,9.99999975e-006,40);
  r4.xyw = r5.xyw * r4.xyw;
  r1.z = dot(r4.xyw, r4.xyw);
  r1.z = rsqrt(r1.z);
  r4.xyw = r4.xyw * r1.zzz;
  r5.xyw = r6.yzw * r1.xxx + float3(0,0,1);
  r4.xyw = float3(-1,-1,1) * r4.xyw;
  r1.x = dot(r4.xyw, r4.xyw);
  r1.x = rsqrt(r1.x);
  r4.xyw = r4.xyw * r1.xxx;
  r1.x = dot(r5.xyw, r4.xyw);
  r4.xyw = r4.xyw * r5.www;
  r4.xyw = r5.xyw * r1.xxx + -r4.xyw;
  r1.x = dot(r4.xyw, r4.xyw);
  r1.x = rsqrt(r1.x);
  r4.xyw = r4.xyw * r1.xxx;
  r3.xyz = r3.xyz * r0.www + float3(0,0,1);
  r4.xyw = float3(-1,-1,1) * r4.xyw;
  r0.w = dot(r4.xyw, r4.xyw);
  r0.w = rsqrt(r0.w);
  r4.xyw = r4.xyw * r0.www;
  r0.w = dot(r3.xyz, r4.xyw);
  r4.xyw = r4.xyw * r3.zzz;
  r3.xyz = r3.xyz * r0.www + -r4.xyw;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r0.w = 0;
  r1.x = 0;
  while (true) {
    r1.z = (int)r1.x;
    r2.z = cmp((int)r1.z >= asint(cb4[51].x));
    if (r2.z != 0) {
      break;
    }
    r2.z = (uint)r1.x;
    r2.w = (uint)r2.z << 2;
    r2.w = (uint)r2.w;
    bitmask.x = ((~(-1 << 30)) << 2) & 0xffffffff;  r4.x = (((uint)r2.z << 2) & bitmask.x) | ((uint)3 & ~bitmask.x);
    bitmask.y = ((~(-1 << 30)) << 2) & 0xffffffff;  r4.y = (((uint)r2.z << 2) & bitmask.y) | ((uint)1 & ~bitmask.y);
    bitmask.w = ((~(-1 << 30)) << 2) & 0xffffffff;  r4.w = (((uint)r2.z << 2) & bitmask.w) | ((uint)2 & ~bitmask.w);
    r4.xyw = (uint3)r4.xyw;
    r4.xyw = float3(52,52,52) + r4.xyw;
    r4.xyw = (uint3)r4.xyw;
    r5.xyw = -cb4[r4.x+0].xyz + v2.xyz;
    r2.z = 52 + r2.w;
    r2.z = (uint)r2.z;
    r2.w = dot(r5.xyw, cb4[r2.z+0].xyz);
    r2.z = dot(cb4[r2.z+0].xyz, cb4[r2.z+0].xyz);
    r6.x = r2.w / r2.z;
    r2.z = dot(r5.xyw, cb4[r4.y+0].xyz);
    r2.w = dot(cb4[r4.y+0].xyz, cb4[r4.y+0].xyz);
    r6.y = r2.z / r2.w;
    r2.z = dot(r5.xyw, cb4[r4.w+0].xyz);
    r2.w = dot(cb4[r4.w+0].xyz, cb4[r4.w+0].xyz);
    r6.z = r2.z / r2.w;
    r2.z = dot(r6.xyz, r6.xyz);
    r2.z = sqrt(r2.z);
    r2.z = min(1, r2.z);
    r2.z = log2(r2.z);
    r2.z = 16 * r2.z;
    r2.z = exp2(r2.z);
    r2.z = -r2.z + r0.w;
    r0.w = 1 + r2.z;
    r1.z = (int)r1.z + 1;
    r1.x = (int)r1.z;
  }
  r0.w = saturate(r0.w);
  r0.w = 1 + -r0.w;
  r1.xz = cb1[8].xy + -v2.xy;
  r1.w = -r1.w * r1.w + 1.01999998;
  r1.w = 3 * r1.w;
  r6.xy = r1.ww * r3.xy;
  r6.z = 0;
  r4.xyw = v2.xyz + -r6.xyz;
  r1.w = cmp(0 < asint(cb13[35].x));
  if (r1.w != 0) {
    r5.yw = -cb12[0].xy + r4.xy;
    r1.w = dot(r5.yw, r5.yw);
    r1.w = sqrt(r1.w);
    r2.z = cmp(r1.w < cb13[36].y);
    if (r2.z != 0) {
      r2.z = cb13[37].z * r1.w;
      r2.z = max(1, r2.z);
      r2.z = cb13[36].x / r2.z;
      r2.z = min(1, r2.z);
      r1.w = cb13[36].z + r1.w;
      r1.w = saturate(cb13[36].w * r1.w);
      r6.xw = float2(-1,0);
      r5.xy = float2(0,0);
      r8.w = 0;
      while (true) {
        r2.w = (int)r8.w;
        r5.w = cmp((int)r2.w >= asint(cb13[35].x));
        if (r5.w != 0) {
          r5.xy = float2(0,0);
          break;
        }
        r5.w = 39 + r8.w;
        r5.w = (uint)r5.w;
        r9.xy = -cb13[r5.w+0].xy + r4.xy;
        r8.xy = cb13[r5.w+0].zw * r9.xy;
        r9.xz = cmp(r8.xy >= float2(0,0));
        r7.w = r9.z ? r9.x : 0;
        r9.xz = cmp(float2(1,1) >= r8.xy);
        r7.w = r9.x ? r7.w : 0;
        r7.w = r9.z ? r7.w : 0;
        if (r7.w != 0) {
          r8.z = -r9.y * cb13[r5.w+0].w + 1;
          r5.w = t19.SampleLevel(s10_s, r8.xzw, 0).x;
          r5.w = cb13[38].x * r5.w + cb13[38].y;
          r5.w = r5.w + -r4.w;
          r5.w = -0.100000001 + r5.w;
          r5.w = saturate(r5.w * r2.z);
          r5.w = 1 + -r5.w;
          r8.x = 1 + -r5.w;
          r6.y = r1.w * r8.x + r5.w;
          r5.xy = r6.xy;
          break;
        }
        r6.z = (int)r7.w & 0xbf800000;
        r2.w = (int)r2.w + 1;
        r8.w = (int)r2.w;
        r5.xy = r6.zw;
      }
    } else {
      r5.x = 0;
    }
  } else {
    r1.w = max(cb4[1].w, 0.0500000007);
    r1.w = min(1, r1.w);
    r2.z = t15.Sample(s15_s, BlitzClampPoolUV(r0.xy, cb2[23].xy, cb0[1].xy, 0.5f)).x;
    r2.z = r2.z * cb2[22].x + cb2[22].y;
    r2.z = r2.z * cb2[21].x + cb2[21].y;
    r2.z = max(9.99999975e-005, r2.z);
    r2.z = rcp(r2.z);
    r2.z = -w1.x + r2.z;
    r6.xyz = -cb1[8].xyz + v2.xyz;
    r2.w = dot(r6.xyz, cb1[10].xyz);
    r2.w = 4.5 * abs(r2.w);
    r2.w = min(1, r2.w);
    r2.w = log2(r2.w);
    r2.w = 6.4000001 * r2.w;
    r2.w = exp2(r2.w);
    r1.w = r1.w * -0.0149999997 + 0.0299999993;
    r8.xy = r1.ww * r3.xy;
    r1.w = abs(r2.z) + abs(r2.z);
    r1.w = min(1, r1.w);
    r8.xy = r8.xy * r1.ww;
    r2.zw = r8.xy * r2.ww;
    r2.zw = r2.zw * r2.xx;
    r1.w = r2.z * r0.w;
    r2.zw = r2.zw * r0.ww + r0.xy;
    r0.y = t15.Sample(s15_s, BlitzClampPoolUV(r2.zw, cb2[23].xy, cb0[1].xy, 0.5f)).x;
    r0.y = r0.y * cb2[22].x + cb2[22].y;
    r0.y = r0.y * cb2[21].x + cb2[21].y;
    r0.y = max(9.99999975e-005, r0.y);
    r0.y = rcp(r0.y);
    r2.z = dot(r7.xyz, r6.xyz);
    r0.y = cmp(r0.y < r2.z);
    r0.y = r0.y ? 0 : r1.w;
    r5.y = r0.y + r0.x;
    r5.x = 0;
  }
  r0.x = cmp(0 != r5.x);
  r0.x = r0.x ? r5.y : 1;
  r0.y = cmp(0 < r0.x);
  if (r0.y != 0) {
    r6.xyz = cb13[5].xyz * r4.yyy;
    r6.xyz = cb13[4].xyz * r4.xxx + r6.xyz;
    r6.xyz = cb13[6].xyz * r4.www + r6.xyz;
    r6.xyz = cb13[7].xyz + r6.xyz;
    r0.y = cmp(abs(r6.z) >= 0.999000013);
    if (r0.y == 0) {
      r7.xyzw = -cb13[8].xyzw + r6.xxxx;
      r8.xyzw = -cb13[9].xyzw + r6.yyyy;
      r7.xyzw = max(abs(r8.xyzw), abs(r7.xyzw));
      r8.xyzw = cmp(r7.xyzw < cb13[10].xyzw);
      r8.xyzw = r8.xyzw ? float4(1,1,1,1) : 0;
      r9.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb13[15].zzzz);
      r9.xyzw = r9.xyzw ? float4(1,1,1,1) : 0;
      r1.w = dot(r8.xyzw, r9.xyzw);
      r2.z = cmp(r1.w < 0.5);
      if (r2.z == 0) {
        r7.xyzw = r7.xyzw / cb13[10].xyzw;
        r8.xyzw = -cb13[17].xyzw + float4(1,1,1,1);
        r7.xyzw = -r8.xyzw + r7.xyzw;
        r7.xyzw = saturate(r7.xyzw / cb13[17].xyzw);
        r1.w = cb13[15].z + -r1.w;
        r8.z = trunc(r1.w);
        r1.w = trunc(cb13[15].z);
        r1.w = (int)r1.w;
        r1.w = (int)r1.w + -1;
        r1.w = (int)r1.w;
        r2.w = 11 + r8.z;
        r2.w = (uint)r2.w;
        r6.w = 1;
        r5.yw = cb13[r2.w+0].zz * r6.wy;
        r6.y = -1;
        r8.xy = r6.xy * r5.yw + cb13[r2.w+0].xy;
        r2.w = t8.SampleCmpLevelZero(s9_s, r8.xyz, r6.z).x;
        r2.w = r2.w * r2.w;
        r5.y = cmp(r8.z >= r1.w);
        r5.y = r5.y ? 1.000000 : 0;
        r1.w = (uint)r1.w;
        r1.w = dot(r7.xyzw, icb[r1.w+0].xyzw);
        r1.w = r5.y * r1.w + r2.w;
        r1.w = min(1, r1.w);
      } else {
        r1.w = 1;
      }
      r1.w = r2.z ? 1 : r1.w;
    } else {
      r1.w = r0.y ? 1 : r5.x;
    }
    r0.x = min(r1.w, r0.x);
  }
  r0.y = dot(r1.xz, r1.xz);
  r0.y = sqrt(r0.y);
  r1.x = 1 + -r4.z;
  r6.z = r0.y * 0.0160000008 + r3.z;
  r0.y = saturate(0.0625 * r2.y);
  r0.y = 1 + -r0.y;
  r6.xy = r3.xy * r0.yy;
  r0.y = dot(r6.xyz, r6.xyz);
  r0.y = rsqrt(r0.y);
  r2.yzw = r6.xyz * r0.yyy;
  r5.xyw = -cb2[0].xyz + v2.xyz;
  r0.y = dot(r5.xyw, r5.xyw);
  r0.y = sqrt(r0.y);
  r5.xyw = r5.xyw / r0.yyy;
  r0.y = -cb2[22].z + r0.y;
  r0.y = max(0, r0.y);
  r0.y = min(cb2[42].z, r0.y);
  r1.z = dot(cb2[38].xyz, r5.xyw);
  r1.w = abs(r1.z) * abs(r1.z);
  r3.z = saturate(r0.y * 0.00200000009 + -0.300000012);
  r1.w = r3.z * r1.w;
  r3.z = cmp(0 < r1.z);
  r6.xyz = r3.zzz ? cb2[39].xyz : cb2[41].xyz;
  r6.xyz = -cb2[40].xyz + r6.xyz;
  r6.xyz = r1.www * r6.xyz + cb2[40].xyz;
  r5.x = cmp(r0.y >= cb2[48].y);
  if (r5.x != 0) {
    r5.x = r5.w * cb2[22].z + cb2[0].z;
    r5.y = r5.w * r0.y;
    r5.w = cb2[43].x * r0.y;
    r5.yw = float2(0.0625,0.0625) * r5.yw;
    r1.z = cb2[42].x + r1.z;
    r6.w = 1 + cb2[42].x;
    r1.z = saturate(r1.z / r6.w);
    r6.w = cb2[43].y + -cb2[43].z;
    r1.z = r1.z * r6.w + cb2[43].z;
    r5.x = cb2[42].y + r5.x;
    r6.w = r5.x * r1.z;
    r5.y = r5.y * r1.z;
    r7.xyzw = r5.yyyy * float4(16,15,14,13) + r6.wwww;
    r7.xyzw = max(float4(0,0,0,0), r7.xyzw);
    r7.xyzw = float4(1,1,1,1) + r7.xyzw;
    r7.xyzw = saturate(r5.wwww / r7.xyzw);
    r7.xyzw = float4(1,1,1,1) + -r7.xyzw;
    r7.x = r7.x * r7.y;
    r7.x = r7.x * r7.z;
    r7.x = r7.x * r7.w;
    r8.xyzw = r5.yyyy * float4(12,11,10,9) + r6.wwww;
    r8.xyzw = max(float4(0,0,0,0), r8.xyzw);
    r8.xyzw = float4(1,1,1,1) + r8.xyzw;
    r8.xyzw = saturate(r5.wwww / r8.xyzw);
    r8.xyzw = float4(1,1,1,1) + -r8.xyzw;
    r7.x = r8.x * r7.x;
    r7.x = r7.x * r8.y;
    r7.x = r7.x * r8.z;
    r7.x = r7.x * r8.w;
    r8.xyzw = r5.yyyy * float4(8,7,6,5) + r6.wwww;
    r8.xyzw = max(float4(0,0,0,0), r8.xyzw);
    r8.xyzw = float4(1,1,1,1) + r8.xyzw;
    r8.xyzw = saturate(r5.wwww / r8.xyzw);
    r8.xyzw = float4(1,1,1,1) + -r8.xyzw;
    r7.x = r8.x * r7.x;
    r7.x = r7.x * r8.y;
    r7.x = r7.x * r8.z;
    r7.x = r7.x * r8.w;
    r7.yz = r5.yy * float2(4,3) + r6.ww;
    r7.yz = max(float2(0,0), r7.yz);
    r7.yz = float2(1,1) + r7.yz;
    r7.yz = saturate(r5.ww / r7.yz);
    r7.yz = float2(1,1) + -r7.yz;
    r7.x = r7.x * r7.y;
    r7.x = r7.x * r7.z;
    r6.w = r5.y * 2 + r6.w;
    r6.w = max(0, r6.w);
    r6.w = 1 + r6.w;
    r6.w = saturate(r5.w / r6.w);
    r6.w = 1 + -r6.w;
    r6.w = r7.x * r6.w;
    r1.z = r5.x * r1.z + r5.y;
    r1.z = max(0, r1.z);
    r1.z = 1 + r1.z;
    r1.z = saturate(r5.w / r1.z);
    r1.z = 1 + -r1.z;
    r1.z = -r6.w * r1.z + 1;
    r0.y = -cb2[48].y + r0.y;
    r0.y = saturate(cb2[48].z * r0.y);
  } else {
    r1.z = 1;
    r0.y = 0;
  }
  r1.z = log2(r1.z);
  r5.x = cb2[42].w * r1.z;
  r5.x = exp2(r5.x);
  r5.x = r5.x * r0.y;
  r5.yw = saturate(r5.xx * cb2[189].xz + cb2[189].yw);
  r7.xyz = cb2[188].xyz + -r6.xyz;
  r7.xyz = r5.yyy * r7.xyz + r6.xyz;
  r5.y = -1 + cb2[188].w;
  r5.y = r5.w * r5.y + 1;
  r7.w = saturate(r5.x * r5.y);
  r5.y = cmp(0 < cb2[192].x);
  if (r5.y != 0) {
    r5.yw = saturate(r5.xx * cb2[191].xz + cb2[191].yw);
    r8.xyz = cb2[190].xyz + -r6.xyz;
    r6.xyz = r5.yyy * r8.xyz + r6.xyz;
    r5.y = -1 + cb2[190].w;
    r5.y = r5.w * r5.y + 1;
    r6.w = saturate(r5.x * r5.y);
    r6.xyzw = r6.xyzw + -r7.xyzw;
    r7.xyzw = cb2[192].xxxx * r6.xyzw + r7.xyzw;
  }
  r2.x = r2.x * 0.0850000009 + 0.0149999997;
  r4.z = cmp(r4.z < 0.999000013);
  r1.x = r2.x * r1.x;
  r1.x = 6 * r1.x;
  r4.z = r5.z ? 0 : r4.z;
  r1.x = r4.z ? r1.x : r2.x;
  r3.xy = r1.xx * r3.xy;
  r5.xy = r3.xy * float2(2.5,2.5) + float2(0.5,0.5);
  r5.z = r4.z ? 0 : 1;
  o1.xyz = r5.xyz * r0.www;
  float custom_water_coverage = saturate(r0.w);
  r5.xyz = cb2[0].xyz + -v2.xyz;
  r0.w = dot(r5.xyz, r5.xyz);
  r1.x = rsqrt(r0.w);
  r6.xyz = r5.xyz * r1.xxx;
  r8.xy = (int2)v0.xy;
  r8.zw = float2(0,0);
  r2.x = t15.Load(r8.xyz).x;
  r3.x = r2.x * cb2[22].x + cb2[22].y;
  r3.x = r3.x * cb2[21].x + cb2[21].y;
  r3.x = max(9.99999975e-005, r3.x);
  r3.x = rcp(r3.x);
  r8.xyzw = cb2[23].zwzw * v0.xyxy;
  r3.y = ~(int)v5.x;
  r4.z = cmp(0.200000003 < r6.z);
  r3.y = (int)r3.y | (int)r4.z;
  r4.z = -w1.x + r3.x;
  r9.xyzw = r3.yyyy ? float4(0.751900017,0.565353632,0,-0.751900017) : float4(1.33000004,1.76890016,0,-1.33000004);
  r5.w = -r2.w * r2.w + 1;
  r5.w = -r9.y * r5.w + 1;
  r6.w = sqrt(r5.w);
  r6.w = r9.x * -r2.w + r6.w;
  r5.w = cmp(r5.w >= 0);
  r9.xyz = -r6.www * r2.yzw + r9.zzw;
  r9.xyz = r5.www ? r9.xyz : 0;
  r4.z = min(1.5, r4.z);
  r5.w = dot(r9.xyz, r9.xyz);
  r5.w = rsqrt(r5.w);
  r9.xyz = r9.xyz * r5.www + float3(-0,-0,1);
  r9.xyz = r9.xyz * r4.zzz + v2.xyz;
  r9.w = 1;
  r10.x = dot(cb6[20].xyzw, r9.xyzw);
  r10.y = dot(cb6[21].xyzw, r9.xyzw);
  r4.z = dot(cb6[23].xyzw, r9.xyzw);
  r9.xy = r10.xy / r4.zz;
  r9.xy = r9.xy * float2(0.5,0.5) + float2(0.5,0.5);
  r9.z = 1 + -r9.y;
  r9.yz = -v0.xy * cb2[23].zw + r9.xz;
  r4.z = cb2[23].y * r9.y;
  r9.x = cb2[23].z * r4.z;
  r4.z = dot(r9.xz, r9.xz);
  r4.z = sqrt(r4.z);
  r9.xy = r9.yz / r4.zz;
  r4.z = min(0.0500000007, r4.z);
  r9.xy = r9.xy * r4.zz + r8.zw;
  r10.xyzw = t15.Gather(s2_s, BlitzScenePoolUV(r9.xy, cb2[23].xy, cb0[1].xy, 1.f)).xyzw;
  r4.z = max(r10.z, r10.w);
  r4.z = max(r10.y, r4.z);
  r4.z = max(r10.x, r4.z);
  r4.z = r4.z * cb2[22].x + cb2[22].y;
  r4.z = r4.z * cb2[21].x + cb2[21].y;
  r4.z = max(9.99999975e-005, r4.z);
  r4.z = rcp(r4.z);
  r5.w = -1 + r4.z;
  r4.z = r3.y ? r4.z : r5.w;
  r4.z = cmp(r4.z < w1.x);
  if (r4.z != 0) {
    r9.xy = r8.zw;
  } else {
    r2.x = t15.SampleLevel(s2_s, BlitzScenePoolUV(r9.xy, cb2[23].xy, cb0[1].xy), 0).x;
    r5.w = r2.x * cb2[22].x + cb2[22].y;
    r5.w = r5.w * cb2[21].x + cb2[21].y;
    r5.w = max(9.99999975e-005, r5.w);
    r3.x = rcp(r5.w);
  }
  r10.xy = cb2[23].xy * r9.xy;
  r10.zw = ddx_coarse(r10.xy);
  r10.xy = ddy_coarse(r10.xy);
  r5.w = dot(r10.zw, r10.zw);
  r6.w = dot(r10.xy, r10.xy);
  r5.w = max(r6.w, r5.w);
  r5.w = log2(r5.w);
  r5.w = 0.5 * r5.w;
  r4.z = r4.z ? 0 : r5.w;
  r10.xyzw = -v0.xyxy * cb2[23].zwzw + r9.xyxy;
  r8.xyzw = r10.xyzw * float4(0.970000029,0.970000029,1.02999997,1.02999997) + r8.xyzw;
  if (r3.y != 0) {
    r10.x = t2.SampleLevel(s7_s, BlitzScenePoolUV(r8.xy, cb2[23].xy, cb0[1].xy), r4.z).x;
    r10.y = t2.SampleLevel(s7_s, BlitzScenePoolUV(r9.xy, cb2[23].xy, cb0[1].xy), r4.z).y;
    r10.z = t2.SampleLevel(s7_s, BlitzScenePoolUV(r8.zw, cb2[23].xy, cb0[1].xy), r4.z).z;
  } else {
    r10.x = t6.SampleLevel(s7_s, BlitzScenePoolUV(r8.xy, cb2[23].xy, cb0[1].xy), r4.z).x;
    r10.y = t6.SampleLevel(s7_s, BlitzScenePoolUV(r9.xy, cb2[23].xy, cb0[1].xy), r4.z).y;
    r10.z = t6.SampleLevel(s7_s, BlitzScenePoolUV(r8.zw, cb2[23].xy, cb0[1].xy), r4.z).z;
  }
  r4.z = dot(-r6.xyz, r2.yzw);
  r5.w = r4.z + r4.z;
  r8.xyz = -r5.www * r2.yzw;
  r5.w = dot(r8.xyz, r8.xyz);
  r5.w = rsqrt(r5.w);
  r8.xyz = r8.xyz * r5.www;
  r5.w = dot(r8.xyz, r6.xyz);
  r5.w = max(0, r5.w);
  r5.w = 1 + -r5.w;
  r5.w = max(0, r5.w);
  r6.w = r5.w * r5.w;
  r6.w = r6.w * r6.w;
  r5.w = r6.w * r5.w;
  r5.w = r5.w * 0.980000019 + 0.0199999996;
  r1.y = sqrt(r1.y);
  r1.y = 1 + -r1.y;
  r6.w = 1 + -r1.y;
  r1.y = r6.z * r6.w + r1.y;
  r1.y = max(0.5, r1.y);
  if (r3.y != 0) {
    r3.y = 20 * cb12[66].x;
    r8.zw = trunc(cb12[68].xy);
    r11.xyz = -cb12[0].xyz + r4.xyw;
    r6.w = dot(r11.xyz, r11.xyz);
    r6.w = sqrt(r6.w);
    r11.xy = cb12[67].xy;
    r11.z = 0;
    r11.xyz = r11.xyz + r4.xyw;
    r11.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r11.xyz;
    r11.xyz = r11.xyz / cb12[66].xxx;
    r12.xy = float2(20,20) * cb12[67].xy;
    r12.z = 0;
    r4.xyw = r12.xyz + r4.xyw;
    r4.xyw = float3(0.00999999978,0.00999999978,0.00999999978) * r4.xyw;
    r4.xyw = r4.xyw / r3.yyy;
    r11.zw = cb13[r2.w+0].xy * r11.zz;
    r11.zw = r11.zw / cb13[r2.w+0].zz;
    r8.xy = r11.xy + -r11.zw;
    r11.xy = cb13[r2.w+0].xy * r4.ww;
    r11.xy = r11.xy / cb13[r2.w+0].zz;
    r11.xy = -r11.xy + r4.xy;
    r3.y = t14.SampleLevel(s14_s, r8.xyz, 1).x;
    r4.x = t14.SampleLevel(s14_s, r8.xyw, 1).x;
    r4.x = r4.x + -r3.y;
    r3.y = cb12[66].w * r4.x + r3.y;
    r11.zw = r8.zw;
    r4.x = t14.SampleLevel(s14_s, r11.xyz, 1).x;
    r4.y = t14.SampleLevel(s14_s, r11.xyw, 1).x;
    r4.y = r4.y + -r4.x;
    r4.x = cb12[66].w * r4.y + r4.x;
    r4.y = cb13[r2.w+0].z + -0.25;
    r4.w = -100 + r6.w;
    r4.yw = saturate(float2(10,0.00666666683) * r4.yw);
    r4.x = r4.x + -r3.y;
    r3.y = r4.w * r4.x + r3.y;
    r3.y = -r4.y * r3.y + 1;
    r0.x = r3.y * r0.x;
    r4.xyw = r3.zzz ? cb2[45].xyz : cb2[47].xyz;
    r4.xyw = -cb2[46].xyz + r4.xyw;
    r4.xyw = r1.www * r4.xyw + cb2[46].xyz;
    r1.z = cb2[48].x * r1.z;
    r1.z = exp2(r1.z);
    r1.w = r1.z * r0.y;
    // Replace atmospheric fog only; underwater scattering/refraction is retained.
    ClassicForwardFog(v0, r1.w, r7);
    if (ClassicWaterReady()) {
      float4 water = ShadeClassicWater(t15,v0,v2.xyz,r2.yzw,cb3[0].xyz,cb3[1].xyz,r0.x,t7.Load(int3(0,0,0)).xyz,0.f,r7);
      float3 excluded = t6.SampleLevel(s7_s,BlitzScenePoolUV(v0.xy*cb2[23].zw,cb2[23].xy,cb0[1].xy),0).rgb;
      o0 = float4(lerp(excluded,water.rgb,custom_water_coverage),0.f);
      // Captured 35624BD6 reflection composite squares the stored mask.
      o1.w = sqrt(max(0.f,water.a*custom_water_coverage));

      o2 = .9f*saturate(2.f-.1f*sqrt(max(r0.w,0.f)));
      return;
    }
    r9.z = 1 + -r9.y;
    r3.yz = r9.xz * float2(2,2) + float2(-1,-1);
    r2.x = max(9.99999975e-006, r2.x);
    r8.xyzw = cb2[207].xyzw * r3.zzzz;
    r8.xyzw = cb2[206].xyzw * r3.yyyy + r8.xyzw;
    r8.xyzw = cb2[208].xyzw * r2.xxxx + r8.xyzw;
    r8.xyzw = cb2[209].xyzw + r8.xyzw;
    r8.xyz = r8.xyz / r8.www;
    r8.xyz = -v2.xyz + r8.xyz;
    r2.x = dot(r2.yzw, cb3[0].xyz);
    r3.y = cmp(0 < r2.x);
    r5.xyz = r5.xyz * r1.xxx + cb3[0].xyz;
    r1.x = dot(r5.xyz, r5.xyz);
    r1.x = rsqrt(r1.x);
    r5.xyz = r5.xyz * r1.xxx;
    r1.x = dot(r2.yzw, r5.xyz);
    r1.x = max(0, r1.x);
    r1.x = r1.x * r1.x;
    r1.x = r1.x * -0.999899983 + 1;
    r1.x = r1.x * r1.x;
    r1.x = 3.14159274 * r1.x;
    r1.x = 0.000100000012 / r1.x;
    r3.z = dot(r2.yzw, r6.xyz);
    r3.z = max(9.99999975e-006, r3.z);
    r2.x = max(0, r2.x);
    r6.w = 4 * r3.z;
    r8.w = r3.z * 0.848749995 + 0.151250005;
    r3.z = r3.z / r8.w;
    r8.w = r2.x * 0.848749995 + 0.151250005;
    r2.x = r2.x / r8.w;
    r2.x = r2.x * r3.z;
    r3.z = dot(r5.xyz, r6.xyz);
    r3.z = max(0, r3.z);
    r3.z = 1 + -r3.z;
    r3.z = max(0, r3.z);
    r5.x = r3.z * r3.z;
    r5.x = r5.x * r5.x;
    r3.z = r5.x * r3.z;
    r3.z = r3.z * 0.980000019 + 0.0199999996;
    r1.x = r2.x * r1.x;
    r1.x = r1.x * r3.z;
    r1.x = r1.x / r6.w;
    r1.x = r3.y ? r1.x : 0;
    r5.xyz = cb3[1].xyz * r1.xxx;
    r1.x = -w1.x + r3.x;
    r1.x = max(0, r1.x);
    r1.x = -14.4269505 * r1.x;
    r1.x = exp2(r1.x);
    r1.x = 1 + -r1.x;
    r2.x = 1 + -r7.w;
    r0.y = -r0.y * r1.z + 1;
    r0.y = r2.x * r0.y;
    r0.y = r5.w * r0.y;
    r0.y = r0.y * r1.x;
    r1.z = r0.y * r1.y;
    r2.x = dot(r8.xyz, r8.xyz);
    r3.x = sqrt(r2.x);
    r8.xyw = cb6[48].xyz + cb6[47].xyz;
    r3.y = -r4.z * r4.z + 1;
    r3.y = -r3.y * 0.565353632 + 1;
    r3.z = sqrt(r3.y);
    r3.z = r4.z * 0.751900017 + r3.z;
    r3.y = cmp(r3.y >= 0);
    r9.xyz = r3.zzz * r2.yzw;
    r9.xyz = r6.xyz * float3(-0.751900017,-0.751900017,-0.751900017) + -r9.xyz;
    r9.xyz = r3.yyy ? r9.xyz : 0;
    r11.xyz = cb6[47].xyz * cb3[1].xyz;
    r3.y = dot(r9.xyz, cb6[46].xyz);
    r3.z = -cb6[47].w * cb6[47].w + 1;
    r4.z = cb6[47].w * cb6[47].w + 1;
    r3.y = dot(r3.yy, cb6[47].ww);
    r3.y = r4.z + -r3.y;
    r3.y = log2(r3.y);
    r3.y = 1.5 * r3.y;
    r3.y = exp2(r3.y);
    r3.y = 12.566371 * r3.y;
    r3.y = r3.z / r3.y;
    r9.xyz = r11.xyz * r3.yyy;
    r3.y = saturate(-0.125 * r3.w);
    r3.y = 1 + -r3.y;
    r0.z = r3.y * r0.z;
    r2.x = rsqrt(r2.x);
    r2.x = r8.z * r2.x;
    r3.y = cb6[48].w * r3.x;
    r9.xyz = r9.xyz * r0.xxx;
    r11.xyz = t7.Load(float4(0,0,0,0)).xyz * ClassicWaterAmbient(asuint(cb2[38].w));
    r11.xyz = cb6[47].xyz * r11.xyz;
    r11.xyz = r11.xyz * r0.zzz;
    r0.z = rcp(abs(cb6[46].z));
    r12.xyz = max(float3(9.99999975e-006,9.99999975e-006,9.99999975e-006), r8.xyw);
    r13.xyz = float3(0,0,0);
    r14.xyz = float3(1,1,1);
    r15.x = 0;
    r15.y = v2.z;
    r3.zw = float2(0.5,0);
    while (true) {
      r4.z = r3.w + r3.z;
      r6.w = cmp(r4.z >= r3.y);
      if (r6.w != 0) {
        r3.z = r3.x * cb6[48].w + -r3.w;
        r3.w = r3.y;
        r15.x = -1;
      } else {
        r3.w = r4.z;
      }
      r15.y = r3.z * r2.x + r15.y;
      r4.z = v2.z + -r15.y;
      r4.z = max(0, r4.z);
      r6.w = r4.z * r0.z;
      r16.xyz = -r6.www * r8.xyw;
      r16.xyz = float3(1.44269502,1.44269502,1.44269502) * r16.xyz;
      r16.xyz = exp2(r16.xyz);
      r16.xyz = cb6[46].www * r16.xyz;
      r17.xyz = -r4.zzz * r8.xyw;
      r17.xyz = float3(0.360673755,0.360673755,0.360673755) * r17.xyz;
      r17.xyz = exp2(r17.xyz);
      r17.xyz = r17.xyz * r11.xyz;
      r17.xyz = float3(0.5,0.5,0.5) * r17.xyz;
      r16.xyz = r9.xyz * r16.xyz + r17.xyz;
      r16.xyz = cb6[47].xyz * (0.1f * ClassicWaterAmbient(asuint(cb2[38].w))) + r16.xyz;
      r17.xyz = -r8.xyw * r3.zzz;
      r17.xyz = float3(1.44269502,1.44269502,1.44269502) * r17.xyz;
      r17.xyz = exp2(r17.xyz);
      r18.xyz = float3(1,1,1) + -r17.xyz;
      r18.xyz = r18.xyz / r12.xyz;
      r16.xyz = r18.xyz * r16.xyz;
      r16.xyz = r16.xyz * r14.xyz + r13.xyz;
      r17.xyz = r17.xyz * r14.xyz;
      r18.xyz = cmp(r17.xyz < float3(9.99999975e-005,9.99999975e-005,9.99999975e-005));
      r4.z = r18.y ? r18.x : 0;
      r4.z = r18.z ? r4.z : 0;
      r4.z = (int)r4.z | (int)r15.x;
      if (r4.z != 0) {
        r13.xyz = r16.xyz;
        r14.xyz = r17.xyz;
        break;
      }
      r3.z = 1.25 * r3.z;
      r13.xyz = r16.xyz;
      r14.xyz = r17.xyz;
    }
    r3.xyz = r10.xyz * r14.xyz + r13.xyz;
    r0.z = -r5.w * r1.y + 1;
    r5.xyz = r5.xyz * r0.xxx;
    r3.xyz = r3.xyz * r0.zzz + r5.xyz;
    r3.xyz = r3.xyz + -r10.xyz;
    r3.xyz = r1.xxx * r3.xyz + r10.xyz;
    r0.x = dot(float3(0.333000004,0.555000007,0.222000003), r3.xyz);
    r4.xyz = r0.xxx * r4.xyw + -r3.xyz;
    r4.xyz = r1.www * r4.xyz + r3.xyz;
    r5.xyz = r7.xyz + -r4.xyz;
    r4.xyz = r7.www * r5.xyz + r4.xyz;
    r0.x = r0.y * r1.y + -0.400000006;
    r0.x = max(0, r0.x);
    r3.xyz = -r4.xyz + r3.xyz;
    r0.xyz = r0.xxx * r3.xyz + r4.xyz;
    o1.w = r1.z;
  } else {
    r1.x = dot(-r2.yzw, r6.xyz);
    r1.x = -0.660000026 + r1.x;
    r1.x = saturate(33.3333664 * r1.x);
    r1.z = r1.x * -2 + 3;
    r1.x = r1.x * r1.x;
    r1.x = r1.z * r1.x;
    r1.y = r5.w * r1.y + -1;
    r1.x = r1.x * r1.y + 1;
    r1.y = 1 + -r1.x;
    r0.xyz = r10.xyz * r1.yyy;
    o1.w = r1.x;
  }
  r0.w = sqrt(r0.w);
  r0.w = saturate(-r0.w * 0.100000001 + 2);
  o2.x = 0.899999976 * r0.w;
  o0.xyz = r0.xyz;
  o0.w = 0;
  return;
}
