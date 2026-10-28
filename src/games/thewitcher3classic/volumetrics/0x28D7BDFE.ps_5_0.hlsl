#include "sample.hlsli"
#include "../water/shading.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 18:39:40 2026
Texture2D<float4> t24 : register(t24);

Texture2DArray<float4> t19 : register(t19);

Texture2D<float4> t17 : register(t17);

Texture2D<float4> t15 : register(t15);

Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float4> t8 : register(t8);

Texture2D<float4> t6 : register(t6);

Texture2D<float4> t5 : register(t5);

Texture2DArray<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t1 : register(t1);

Texture2DArray<float4> t0 : register(t0);

SamplerState s15_s : register(s15);

SamplerState s14_s : register(s14);

SamplerState s10_s : register(s10);

SamplerComparisonState s9_s : register(s9);

SamplerState s6_s : register(s6);

SamplerState s5_s : register(s5);

SamplerState s4_s : register(s4);

SamplerState s3_s : register(s3);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb5 : register(b5)
{
  float4 cb5[1];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[116];
}

cbuffer cb13 : register(b13)
{
  float4 cb13[44];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[214];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[11];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[15];
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
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1)
{

  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19;
  uint4 bitmask, uiDest;
  float4 fDest;

  ClassicForwardFog(v0, v4.w, v3);


  r0.xy = v0.xy / cb0[1].xy;
  r0.zw = -cb0[1].zw * float2(0.5,0.5) + cb0[2].xy;
  r1.xy = float2(2.5,2.5) / cb0[2].xy;
  r2.x = -r1.x;
  r2.z = 0;
  r2.xy = saturate(r0.xy * float2(0.5,0.5) + r2.xz);
  r2.x = t3.Sample(s3_s, r2.xy).z;
  r1.z = 0;
  r3.xyzw = saturate(r0.xyxy * float4(0.5,0.5,0.5,0.5) + r1.xzzy);
  r1.x = t3.Sample(s3_s, r3.xy).z;
  r4.x = r2.x + -r1.x;
  r1.x = t3.Sample(s3_s, r3.zw).z;
  r1.w = -r1.y;
  r1.yz = saturate(r0.xy * float2(0.5,0.5) + r1.zw);
  r1.y = t3.Sample(s3_s, r1.yz).z;
  r4.y = r1.x + -r1.y;
  r4.z = 1;
  r1.x = dot(r4.xyz, r4.xyz);
  r1.x = rsqrt(r1.x);
  r1.yzw = r4.xyz * r1.xxx;
  r2.yz = -cb1[8].xy + v2.xy;
  r2.y = dot(r2.yz, r2.yz);
  r2.y = sqrt(r2.y);
  r3.xyzw = float4(350,2000,40,20) + -r2.yyyy;
  r3.xyzw = float4(0.00285714283,0.000500000024,0.0250000004,0.0500000007) * r3.xyzw;
  r3.xyzw = max(float4(0,0,0,0), r3.xyzw);
  r2.z = r3.x * r3.x;
  r2.z = r2.z * r2.z;
  r2.w = r2.z * r2.z;
  r5.xyzw = v1.xyxy / cb4[0].xxyy;
  r6.xy = v1.xy / cb4[0].zz;
  r6.zw = t5.SampleLevel(s5_s, r5.xy, 0).xy;
  r7.xy = t5.SampleLevel(s5_s, r5.zw, 0).xy;
  r8.xy = t5.SampleLevel(s5_s, r6.xy, 0).xy;
  t17.GetDimensions(0, fDest.x, fDest.y, fDest.z);
  r4.w = fDest.x;
  r4.w = (int)r4.w;
  r9.yzw = float3(0,0,0);
  r6.y = 0;
  r7.zw = float2(0,0);
  r8.w = 0;
  while (true) {
    r10.x = cmp((int)r7.w >= (int)r4.w);
    r8.w = 0;
    if (r10.x != 0) break;
    r9.x = r7.w;
    r10.xyzw = t17.Load(r9.xyz).xyzw;
    r10.xy = cmp(r10.xy < v2.xy);
    r10.zw = cmp(v2.xy < r10.zw);
    r9.x = r10.z ? r10.x : 0;
    r9.x = r10.y ? r9.x : 0;
    r9.x = r10.w ? r9.x : 0;
    if (r9.x != 0) {
      r7.z = r7.w;
      r8.w = -1;
      break;
    }
    r6.x = (int)r7.w + 1;
    r7.zw = r6.yx;
    r8.w = r9.x;
  }
  r9.x = r8.w ? r7.z : -1;
  r4.w = cmp((int)r9.x >= 0);
  if (r4.w != 0) {
    // Native ld reads metadata row 1 (DXBC integer bits 1). Converting the
    // decompiler's subnormal float literal to a Load coordinate selects row 0,
    // corrupting the water-map UV bounds and producing diagonal normal seams.
    // This is the same correction as the BlitzFX water permutation 2825099C.
    r9.yzw = float3(1,0,0);
    r10.xyzw = t17.Load(r9.xww).xyzw;
    r11.xyzw = t17.Load(r9.xyz).xyzw;
    t4.GetDimensions(0, fDest.x, fDest.y, fDest.z, fDest.w);
    r6.xy = fDest.xy;
    r7.zw = v2.xy + -r10.xy;
    r9.yz = r10.zw + -r10.xy;
    r7.zw = r7.zw / r9.yz;
    r6.xy = float2(0.5,0.5) / r6.xy;
    r6.xy = abs(r7.zw) + r6.xy;
    r7.zw = r11.zw + -r11.xy;
    r10.xy = r6.xy * r7.zw + r11.xy;
    r10.z = (int)r9.x;
    r4.w = t4.SampleLevel(s4_s, r10.xyz, 0).x;
    r4.w = saturate(r4.w);
    r6.x = cb5[0].y + -cb5[0].x;
    r4.w = r4.w * r6.x + cb5[0].x;
  } else {
    r4.w = -10;
  }
  r4.w = v2.z + -r4.w;
  r6.x = saturate(-0.100000001 * r4.w);
  r6.x = 1 + -r6.x;
  r9.xyz = r3.xxx * float3(0,1,1) + float3(1,0,-1);
  r9.xyz = r6.xxx * r9.xyz + float3(0,0,1);
  r7.zw = cb4[3].zw * r6.xx;
  r5.xy = r7.zz * r6.zw + r5.xy;
  r6.yzw = t5.SampleLevel(s5_s, r5.xy, 0).xyz;
  r5.xy = r7.ww * r7.xy + r5.zw;
  r5.xyz = t5.SampleLevel(s5_s, r5.xy, 0).xyz;
  r5.w = max(0.0500000007, cb4[1].w);
  r5.w = min(1, r5.w);
  r7.xy = float2(0.200000003,15) * abs(r4.ww);
  r7.xy = min(float2(1,1), r7.xy);
  r7.xz = r7.xx * float2(0.400000006,0.400000006) + float2(-0.920000017,-0.200000003);
  r7.xz = r5.ww * r7.xz + float2(0.920000017,0.200000003);
  r7.z = r7.z * r5.z;
  r7.x = r7.x * r6.w + r7.z;
  r7.x = max(0, r7.x);
  r7.x = min(100, r7.x);
  r3.x = r7.x * r3.x;
  r6.w = 0.000150000007;
  r7.x = dot(r6.yzw, r6.yzw);
  r7.x = rsqrt(r7.x);
  r3.yzw = r9.xyz * r3.yzw;
  r6.yzw = r6.yzw * r7.xxx + float3(-0,-0,-1);
  r6.yzw = r3.yyy * r6.yzw + float3(0,0,1);
  r3.y = dot(r6.yzw, r6.yzw);
  r3.y = rsqrt(r3.y);
  r5.z = 0.000349999988;
  r7.x = dot(r5.xyz, r5.xyz);
  r7.x = rsqrt(r7.x);
  r5.xyz = r5.xyz * r7.xxx + float3(-0,-0,-1);
  r5.xyz = r3.zzz * r5.xyz + float3(0,0,1);
  r3.z = dot(r5.xyz, r5.xyz);
  r3.z = rsqrt(r3.z);
  r8.z = 0.00079999998;
  r7.x = dot(r8.xyz, r8.xyz);
  r7.x = rsqrt(r7.x);
  r7.xzw = r8.xyz * r7.xxx + float3(-0,-0,-1);
  r7.xzw = r3.www * r7.xzw + float3(0,0,1);
  r3.w = dot(r7.xzw, r7.xzw);
  r3.w = rsqrt(r3.w);
  r7.xzw = r7.xzw * r3.www;
  r5.xyz = r5.xyz * r3.zzz + float3(0,0,1);
  r7.xzw = float3(-1,-1,1) * r7.xzw;
  r3.z = dot(r7.xzw, r7.xzw);
  r3.z = rsqrt(r3.z);
  r7.xzw = r7.xzw * r3.zzz;
  r3.z = dot(r5.xyz, r7.xzw);
  r7.xzw = r7.xzw * r5.zzz;
  r5.xyz = r5.xyz * r3.zzz + -r7.xzw;
  r3.z = dot(r5.xyz, r5.xyz);
  r3.z = rsqrt(r3.z);
  r7.xzw = r5.xyz * r3.zzz;
  r6.yzw = r6.yzw * r3.yyy + float3(0,0,1);
  r8.xyz = float3(-1,-1,1) * r7.xzw;
  r3.y = dot(r8.xyz, r8.xyz);
  r3.y = rsqrt(r3.y);
  r8.xyz = r8.xyz * r3.yyy;
  r3.y = dot(r6.yzw, r8.xyz);
  r8.xyz = r8.xyz * r6.www;
  r6.yzw = r6.yzw * r3.yyy + -r8.xyz;
  r3.y = dot(r6.yzw, r6.yzw);
  r3.y = rsqrt(r3.y);
  r6.yzw = r6.yzw * r3.yyy;
  r3.y = saturate(1 + -r2.x);
  r6.yz = r6.yz * r3.yy;
  r3.y = dot(r6.yzw, r6.yzw);
  r3.y = rsqrt(r3.y);
  r6.yzw = r6.yzw * r3.yyy;
  r3.yw = -cb4[4].xy + v2.xy;
  r3.yw = r3.yw * float2(0.0333333351,0.0333333351) + float2(0.5,0.5);
  r8.xyzw = t1.SampleLevel(s1_s, r3.yw, 0).xyzw;
  r3.yw = (int2)v0.xy;
  r5.xz = (int2)r3.yw ^ int2(2,2);
  r3.yw = max((int2)-r3.yw, (int2)r3.yw);
  r3.yw = (uint2)r3.yw >> int2(1,1);
  r9.xy = -(int2)r3.yw;
  r5.xz = (int2)r5.xz & int2(0x80000000,0x80000000);
  r9.xy = r5.xz ? r9.xy : r3.yw;
  r9.zw = float2(0,0);
  r3.yw = t24.Load(r9.xyz).xy;
  r9.xyz = -cb12[0].xyz + v2.xyz;
  r5.x = dot(r9.xyz, r9.xyz);
  r5.x = sqrt(r5.x);
  r10.x = cb12[1].z;
  r10.y = cb12[2].z;
  r10.z = cb12[3].z;
  r5.z = dot(r10.xyz, r9.xyz);
  r7.z = 1 / cb12[21].y;
  r7.z = r7.z * r5.x;
  r5.z = r7.z / r5.z;
  r5.z = r5.x + -r5.z;
  r5.z = saturate(cb13[33].w * r5.z);
  r5.z = cb13[33].z * r5.z;
  r5.z = max(0.00100000005, r5.z);
  r5.x = r5.x / cb13[34].z;
  r7.z = cmp(r3.y < r3.w);
  if (r7.z != 0) {
    r7.z = cmp(r5.x < r3.y);
    r9.x = cmp(r3.w < r5.x);
    r9.y = cb13[34].z * r3.y + -cb13[34].x;
    r9.y = saturate(-r9.y * cb13[34].y + 1);
    r9.z = r5.x + -r3.y;
    r9.z = cb13[34].z * r9.z;
    r9.z = saturate(r9.z / r5.z);
    r11.y = r9.y * r9.z;
    r7.z = (int)r7.z | (int)r9.x;
    r11.x = 1;
    r9.xy = r7.zz ? float2(0,1) : r11.xy;
  } else {
    r7.z = cmp(r3.w < r3.y);
    r9.z = cmp(r5.x < r3.w);
    r9.w = cmp(r3.y < r5.x);
    r3.y = cb13[34].z * r3.y + -cb13[34].x;
    r11.y = saturate(-r3.y * cb13[34].y + 1);
    r3.y = r5.x + -r3.w;
    r3.y = cb13[34].z * r3.y;
    r3.y = saturate(r3.y / r5.z);
    r11.w = 1 + -r3.y;
    r11.xz = float2(1,1);
    r3.yw = r9.ww ? r11.xy : r11.zw;
    r3.yw = r9.zz ? float2(1,1) : r3.yw;
    r9.xy = r7.zz ? r3.yw : float2(0,1);
  }
  r3.y = -r9.y * r9.x + 1;
  r2.y = -r2.y * 0.0500000007 + 1;
  r2.y = max(0, r2.y);
  r5.xz = r8.zw * r2.yy;
  r9.xy = r5.xz * r3.yy;
  r8.z = 0.00499999989;
  r2.y = dot(r8.xyz, r8.xyz);
  r2.y = rsqrt(r2.y);
  r11.xyz = r8.xyz * r2.yyy;
  r9.z = 0.0500000007;
  r2.y = dot(r9.xyz, r9.xyz);
  r2.y = rsqrt(r2.y);
  r9.w = r11.z;
  r12.xyz = r9.xyw * r2.yyy;
  r9.xyz = r12.xyz * r9.wwz + r11.xyz;
  r2.y = dot(r9.xyz, r9.xyz);
  r2.y = rsqrt(r2.y);
  r11.xyz = r9.xyz * r2.yyy;
  r1.w = r11.z * r1.w;
  r1.w = min(1, r1.w);
  r12.xyz = r1.www * float3(0.999989986,0.999989986,-39) + float3(9.99999975e-006,9.99999975e-006,40);
  r6.yzw = r12.xyz * r6.yzw;
  r1.w = dot(r6.yzw, r6.yzw);
  r1.w = rsqrt(r1.w);
  r6.yzw = r6.yzw * r1.www;
  r9.xyz = r9.xyz * r2.yyy + float3(0,0,1);
  r6.yzw = float3(-1,-1,1) * r6.yzw;
  r1.w = dot(r6.yzw, r6.yzw);
  r1.w = rsqrt(r1.w);
  r6.yzw = r6.yzw * r1.www;
  r1.w = dot(r9.xyz, r6.yzw);
  r6.yzw = r6.yzw * r9.zzz;
  r6.yzw = r9.xyz * r1.www + -r6.yzw;
  r1.w = dot(r6.yzw, r6.yzw);
  r1.w = rsqrt(r1.w);
  r6.yzw = r6.yzw * r1.www;
  r4.xyz = r4.xyz * r1.xxx + float3(0,0,1);
  r6.yzw = float3(-1,-1,1) * r6.yzw;
  r1.x = dot(r6.yzw, r6.yzw);
  r1.x = rsqrt(r1.x);
  r6.yzw = r6.yzw * r1.xxx;
  r1.x = dot(r4.xyz, r6.yzw);
  r6.yzw = r6.yzw * r4.zzz;
  r4.xyz = r4.xyz * r1.xxx + -r6.yzw;
  r1.x = dot(r4.xyz, r4.xyz);
  r1.x = rsqrt(r1.x);
  r6.yzw = r4.xyz * r1.xxx;
  r1.w = t15.Sample(s15_s, r0.xy).x;
  r1.w = r1.w * cb12[22].x + cb12[22].y;
  r1.w = r1.w * cb12[21].x + cb12[21].y;
  r1.w = max(9.99999975e-005, r1.w);
  r1.w = 1 / r1.w;
  r2.y = -w1.x + r1.w;
  r9.zw = abs(r2.yy);
  r12.xyz = -cb1[8].xyz + v2.xyz;
  r2.y = dot(r12.xyz, cb1[10].xyz);
  r2.y = 4.5 * abs(r2.y);
  r2.y = min(1, r2.y);
  r2.y = log2(r2.y);
  r2.y = 6.4000001 * r2.y;
  r2.y = exp2(r2.y);
  r3.yw = r5.ww * float2(-0.0149999997,0.699999988) + float2(0.0299999993,0.300000012);
  r4.xy = r3.yy * r6.yz;
  r3.y = r9.w + r9.w;
  r3.y = min(1, r3.y);
  r4.xy = r4.xy * r3.yy;
  r4.xy = r4.xy * r2.yy;
  r4.xy = r4.xy * r2.ww;
  r3.y = 0;
  r5.x = 0;
  while (true) {
    r5.z = cmp((int)r5.x >= asint(cb4[51].x));
    if (r5.z != 0) break;
    r5.z = (uint)r5.x << 2;
    bitmask.x = ((~(-1 << 30)) << 2) & 0xffffffff;  r13.x = (((uint)r5.x << 2) & bitmask.x) | ((uint)1 & ~bitmask.x);
    bitmask.y = ((~(-1 << 30)) << 2) & 0xffffffff;  r13.y = (((uint)r5.x << 2) & bitmask.y) | ((uint)2 & ~bitmask.y);
    bitmask.z = ((~(-1 << 30)) << 2) & 0xffffffff;  r13.z = (((uint)r5.x << 2) & bitmask.z) | ((uint)3 & ~bitmask.z);
    r14.xyz = -cb4[r13.z+52].xyz + v2.xyz;
    r7.z = dot(r14.xyz, cb4[r5.z+52].xyz);
    r5.z = dot(cb4[r5.z+52].xyz, cb4[r5.z+52].xyz);
    r15.x = r7.z / r5.z;
    r5.z = dot(r14.xyz, cb4[r13.x+52].xyz);
    r7.z = dot(cb4[r13.x+52].xyz, cb4[r13.x+52].xyz);
    r15.y = r5.z / r7.z;
    r5.z = dot(r14.xyz, cb4[r13.y+52].xyz);
    r7.z = dot(cb4[r13.y+52].xyz, cb4[r13.y+52].xyz);
    r15.z = r5.z / r7.z;
    r5.z = dot(r15.xyz, r15.xyz);
    r5.z = sqrt(r5.z);
    r5.z = min(1, r5.z);
    r5.z = log2(r5.z);
    r5.z = 16 * r5.z;
    r5.z = exp2(r5.z);
    r5.z = -r5.z + r3.y;
    r3.y = 1 + r5.z;
    r5.x = (int)r5.x + 1;
  }
  r3.y = saturate(r3.y);
  r5.x = 1 + -r3.y;
  r3.x = r5.x * r3.x;
  r13.xy = r5.xx * r4.xy;
  r4.xy = r4.xy * r5.xx + r0.xy;
  r4.x = t15.Sample(s15_s, r4.xy).x;
  r4.x = r4.x * cb12[22].x + cb12[22].y;
  r4.x = r4.x * cb12[21].x + cb12[21].y;
  r4.x = max(9.99999975e-005, r4.x);
  r4.x = 1 / r4.x;
  r4.y = dot(r10.xyz, r12.xyz);
  r4.y = cmp(r4.x < r4.y);
  r4.x = -w1.x + r4.x;
  r13.zw = abs(r4.xx);
  r9.xy = float2(0,0);
  r9.xyzw = r4.yyyy ? r9.xyzw : r13.xyzw;
  r4.x = 2 + -r5.w;
  r10.xyzw = float4(0.100000001,0.100000001,0.300000012,0.300000012) * r11.xyxy;
  r4.xy = r9.xy * r4.xx + r10.xy;
  r1.yz = r1.yz * float2(0.25,0.25) + r4.xy;
  r11.xyzw = float4(1.20000005,1.20000005,0.200000003,0.200000003) * v1.xyxy;
  r1.yz = r1.yz * float2(0.159999996,0.159999996) + r11.xy;
  r4.x = cos(cb0[0].x);
  r4.xy = r10.zw * r4.xx;
  r1.yz = r1.yz * float2(2.20000005,2.20000005) + r4.xy;
  r1.yz = cb0[0].xx * float2(0.0500000007,0.0500000007) + r1.yz;
  r10.xy = r6.yz * float2(0.400000006,0.400000006) + r1.yz;
  r10.z = 0;
  r1.y = t0.Sample(s0_s, r10.xyz).x;
  r4.xy = v2.xy * float2(0.800000012,0.800000012) + r11.zw;
  r10.xyzw = float4(0.639999986,0.639999986,3,0.5) * r9.xyzw;
  r11.xy = r4.xy * float2(0.180000007,0.180000007) + r10.xy;
  r11.z = 0;
  r1.z = t0.Sample(s0_s, r11.xyz).y;
  r1.y = r1.y * r1.z;
  r11.xyz = cb1[8].xyz + -v2.xyz;
  r13.xyz = r6.yzw * float3(0.00499999989,0.00499999989,0.0500000007) + r11.xyz;
  r4.x = dot(r13.xyz, r13.xyz);
  r4.x = rsqrt(r4.x);
  r14.xyz = r13.xyz * r4.xxx;
  r4.y = dot(cb0[9].xyz, cb0[9].xyz);
  r4.y = rsqrt(r4.y);
  r15.xyz = cb0[9].xyz * r4.yyy;
  r8.zw = r9.xy + r0.xy;
  r16.xyz = t6.Sample(s6_s, r8.zw).xyz;
  r8.zw = min(float2(1,1), r10.zw);
  r10.x = 1 + -r8.w;
  r4.y = r8.z * r5.x;
  r4.y = 0.00150000001 * r4.y;
  r5.z = r7.w + r7.x;
  r3.z = r5.y * r3.z + r5.z;
  r3.z = r4.y * r3.z;
  r4.y = r3.z + r3.z;
  r3.z = r10.x * r3.z;
  r5.yz = r3.zz * float2(0,3) + r9.xy;
  r5.yz = r5.yz + r0.xy;
  r5.yz = max(float2(0,0), r5.yz);
  r5.yz = min(r5.yz, r0.zw);
  r7.xzw = t6.Sample(s6_s, r5.yz).xyz;
  r17.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r16.xyz;
  r18.xyz = float3(4,4,4) * r16.xyz;
  r7.xzw = max(r17.xyz, r7.xzw);
  r7.xzw = min(r7.xzw, r18.xyz);
  r3.z = dot(r7.xzw, float3(1,1,1));
  r3.z = 1 + -r3.z;
  r3.z = max(-0.5, r3.z);
  r3.z = min(0.5, r3.z);
  r3.z = 1 + r3.z;
  r3.z = r4.y * r3.z;
  r10.yzw = float3(1,0.699999988,-0.699999988);
  r5.yz = r10.yx * r3.zz;
  r5.yz = r5.yz * r10.xz + r9.xy;
  r5.yz = r5.yz + r0.xy;
  r5.yz = max(float2(0,0), r5.yz);
  r5.yz = min(r5.yz, r0.zw);
  r19.xyz = t6.Sample(s6_s, r5.yz).xyz;
  r19.xyz = max(r19.xyz, r17.xyz);
  r19.xyz = min(r19.xyz, r18.xyz);
  r7.xzw = r19.xyz + r7.xzw;
  r3.z = dot(r7.xzw, float3(1,1,1));
  r3.z = 1 + -r3.z;
  r3.z = max(-0.5, r3.z);
  r3.z = min(0.5, r3.z);
  r3.z = 1 + r3.z;
  r3.z = r4.y * r3.z;
  r5.yz = r10.yx * r3.zz;
  r5.yz = r5.yz * r10.xw + r9.xy;
  r5.yz = r5.yz + r0.xy;
  r5.yz = max(float2(0,0), r5.yz);
  r5.yz = min(r5.yz, r0.zw);
  r10.yzw = t6.Sample(s6_s, r5.yz).xyz;
  r10.yzw = max(r10.yzw, r17.xyz);
  r10.yzw = min(r10.yzw, r18.xyz);
  r7.xzw = r10.yzw + r7.xzw;
  r3.z = dot(r7.xzw, float3(1,1,1));
  r3.z = 1 + -r3.z;
  r3.z = max(-0.5, r3.z);
  r3.z = min(0.5, r3.z);
  r3.z = 1 + r3.z;
  r3.z = r4.y * r3.z;
  r3.z = r10.x * r3.z;
  r5.yz = r3.zz * float2(0,-1) + r9.xy;
  r5.yz = r5.yz + r0.xy;
  r5.yz = max(float2(0,0), r5.yz);
  r5.yz = min(r5.yz, r0.zw);
  r10.yzw = t6.Sample(s6_s, r5.yz).xyz;
  r10.yzw = max(r10.yzw, r17.xyz);
  r10.yzw = min(r10.yzw, r18.xyz);
  r7.xzw = r10.yzw + r7.xzw;
  r3.z = dot(r7.xzw, float3(1,1,1));
  r3.z = 1 + -r3.z;
  r3.z = max(-0.5, r3.z);
  r3.z = min(0.5, r3.z);
  r3.z = 1 + r3.z;
  r3.z = r4.y * r3.z;
  r3.z = r10.x * r3.z;
  r5.yz = r3.zz * float2(-1,-0.699999988) + r9.xy;
  r5.yz = r5.yz + r0.xy;
  r5.yz = max(float2(0,0), r5.yz);
  r5.yz = min(r5.yz, r0.zw);
  r10.yzw = t6.Sample(s6_s, r5.yz).xyz;
  r10.yzw = max(r10.yzw, r17.xyz);
  r10.yzw = min(r10.yzw, r18.xyz);
  r7.xzw = r10.yzw + r7.xzw;
  r3.z = dot(r7.xzw, float3(1,1,1));
  r3.z = 1 + -r3.z;
  r3.z = max(-0.5, r3.z);
  r3.z = min(0.5, r3.z);
  r3.z = 1 + r3.z;
  r3.z = r4.y * r3.z;
  r3.z = r10.x * r3.z;
  r5.yz = r3.zz * float2(-1,0.699999988) + r9.xy;
  r5.yz = r5.yz + r0.xy;
  r5.yz = max(float2(0,0), r5.yz);
  r0.zw = min(r5.yz, r0.zw);
  r9.xyz = t6.Sample(s6_s, r0.zw).xyz;
  r9.xyz = max(r9.xyz, r17.xyz);
  r9.xyz = min(r9.xyz, r18.xyz);
  r7.xzw = r9.xyz + r7.xzw;
  r7.xzw = float3(0.166666672,0.166666672,0.166666672) * r7.xzw;
  r0.z = dot(r6.yz, r6.yz);
  r0.z = rsqrt(r0.z);
  r0.zw = r6.yz * r0.zz;
  r0.zw = float2(0.00499999989,0.00499999989) * r0.zw;
  r3.z = dot(r12.xyz, r12.xyz);
  r3.z = rsqrt(r3.z);
  r9.xyz = r12.xyz * r3.zzz;
  r3.z = dot(cb1[10].xyz, r9.xyz);
  r3.z = 1 / r3.z;
  r9.xyz = r9.xyz * r3.zzz;
  r9.xyz = r9.xyz * r1.www + cb1[8].xyz;
  r0.zw = r9.xy * float2(0.119999997,0.119999997) + r0.zw;
  r5.yz = cb13[0].xy * r9.zz;
  r0.zw = -r5.yz * float2(0.100000001,0.100000001) + r0.zw;
  r9.xy = cb0[0].xx * float2(0.00499999989,0.00499999989) + r0.zw;
  r9.z = 0;
  r0.z = t0.Sample(s0_s, r9.xyz).w;
  r5.yz = float2(1.70000005,1) + -abs(r4.ww);
  r5.y = saturate(r5.y);
  r0.w = r7.y * r5.y;
  r0.z = r0.z * r0.w;
  r0.w = -r2.z * r2.z + 1.01999998;
  r0.w = 3 * r0.w;
  r9.xy = r0.ww * r6.yz;
  r9.z = 0;
  r9.xyz = v2.xyz + -r9.xyz;
  r0.w = cmp(0 < asint(cb13[35].x));
  if (r0.w != 0) {
    r8.zw = -cb12[0].xy + r9.xy;
    r0.w = dot(r8.zw, r8.zw);
    r0.w = sqrt(r0.w);
    r2.z = cmp(r0.w < cb13[36].y);
    if (r2.z != 0) {
      r2.z = cb13[37].z * r0.w;
      r2.z = max(1, r2.z);
      r2.z = cb13[36].x / r2.z;
      r2.z = min(1, r2.z);
      r0.w = cb13[36].z + r0.w;
      r0.w = saturate(cb13[36].w * r0.w);
      r10.y = 0;
      r8.zw = float2(0,0);
      r3.z = 0;
      while (true) {
        r4.y = cmp((int)r8.w >= asint(cb13[35].x));
        r3.z = 0;
        if (r4.y != 0) break;
        r10.zw = -cb13[r8.w+39].xy + r9.xy;
        r12.xy = cb13[r8.w+39].zw * r10.zw;
        r17.xy = cmp(r12.xy >= float2(0,0));
        r4.y = r17.y ? r17.x : 0;
        r17.xy = cmp(float2(1,1) >= r12.xy);
        r4.y = r4.y ? r17.x : 0;
        r4.y = r17.y ? r4.y : 0;
        if (r4.y != 0) {
          r12.z = (int)r8.w;
          r12.w = -r10.w * cb13[r8.w+39].w + 1;
          r7.y = t19.SampleLevel(s10_s, r12.xwz, 0).x;
          r7.y = cb13[38].x * r7.y + cb13[38].y;
          r7.y = r7.y + -r9.z;
          r7.y = -0.100000001 + r7.y;
          r7.y = saturate(r7.y * r2.z);
          r7.y = 1 + -r7.y;
          r10.z = 1 + -r7.y;
          r8.z = r0.w * r10.z + r7.y;
          r3.z = -1;
          break;
        }
        r10.x = (int)r8.w + 1;
        r8.zw = r10.yx;
        r3.z = r4.y;
      }
    } else {
      r3.z = 0;
    }
  } else {
    r3.z = 0;
  }
  r0.w = r3.z ? r8.z : 1;
  r2.z = cmp(0 < r0.w);
  if (r2.z != 0) {
    r10.xyz = cb13[5].xyz * r9.yyy;
    r10.xyz = cb13[4].xyz * r9.xxx + r10.xyz;
    r10.xyz = cb13[6].xyz * r9.zzz + r10.xyz;
    r10.xyz = cb13[7].xyz + r10.xyz;
    r2.z = cmp(abs(r10.z) >= 0.999000013);
    if (r2.z != 0) {
      r3.z = 1;
    }
    if (r2.z == 0) {
      r12.xyzw = -cb13[8].xyzw + r10.xxxx;
      r17.xyzw = -cb13[9].xyzw + r10.yyyy;
      r12.xyzw = max(abs(r17.xyzw), abs(r12.xyzw));
      r17.xyzw = cmp(r12.xyzw < cb13[10].xyzw);
      r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
      r18.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb13[15].zzzz);
      r18.xyzw = r18.xyzw ? float4(1,1,1,1) : 0;
      r2.z = dot(r17.xyzw, r18.xyzw);
      r4.y = cmp(r2.z < 0.5);
      if (r4.y != 0) {
        r3.z = 1;
      }
      if (r4.y == 0) {
        r12.xyzw = r12.xyzw / cb13[10].xyzw;
        r17.xyzw = float4(1,1,1,1) + -cb13[17].xyzw;
        r12.xyzw = -r17.xyzw + r12.xyzw;
        r12.xyzw = saturate(r12.xyzw / cb13[17].xyzw);
        r2.z = cb13[15].z + -r2.z;
        r7.y = (int)r2.z;
        r8.z = (int)cb13[15].z;
        r8.z = (int)r8.z + -1;
        r17.xy = cb13[r7.y+11].zz * float2(1,-1);
        r17.xy = r10.xy * r17.xy + cb13[r7.y+11].xy;
        r17.z = trunc(r2.z);
        r2.z = cmp(asint(cb13[18].x) >= 1);
        if (r2.z != 0) {
          r2.z = t8.SampleCmpLevelZero(s9_s, r17.xyz, r10.z).x;
          r2.z = r2.z * r2.z;
        } else {
          r7.y = t8.SampleCmpLevelZero(s9_s, r17.xyz, r10.z).x;
          r2.z = r7.y * r7.y;
        }
        r7.y = (int)r8.z;
        r7.y = cmp(r17.z >= r7.y);
        r7.y = r7.y ? 1.000000 : 0;
        r8.z = dot(r12.xyzw, icb[r8.z+0].xyzw);
        r2.z = r7.y * r8.z + r2.z;
        r2.z = min(1, r2.z);
      } else {
        r2.z = 1;
      }
      r3.z = r4.y ? r3.z : r2.z;
    }
    r0.w = min(r3.z, r0.w);
  }
  r2.z = 20 * cb12[66].x;
  r10.zw = trunc(cb12[68].xy);
  r12.xyz = -cb12[0].xyz + r9.xyz;
  r3.z = dot(r12.xyz, r12.xyz);
  r3.z = sqrt(r3.z);
  r12.xy = cb12[67].xy;
  r12.z = 0;
  r12.xyz = r12.xyz + r9.xyz;
  r12.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r12.xyz;
  r12.xyz = r12.xyz / cb12[66].xxx;
  r17.xy = float2(20,20) * cb12[67].xy;
  r17.z = 0;
  r9.xyz = r17.xyz + r9.xyz;
  r9.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r9.xyz;
  r9.xyz = r9.xyz / r2.zzz;
  r8.zw = cb13[0].xy * r12.zz;
  r8.zw = r8.zw / cb13[0].zz;
  r10.xy = r12.xy + -r8.zw;
  r8.zw = cb13[0].xy * r9.zz;
  r8.zw = r8.zw / cb13[0].zz;
  r12.xy = r9.xy + -r8.zw;
  r2.z = t14.SampleLevel(s14_s, r10.xyz, 1).x;
  r4.y = t14.SampleLevel(s14_s, r10.xyw, 1).x;
  r4.y = r4.y + -r2.z;
  r2.z = cb12[66].w * r4.y + r2.z;
  r12.zw = r10.zw;
  r4.y = t14.SampleLevel(s14_s, r12.xyz, 1).x;
  r7.y = t14.SampleLevel(s14_s, r12.xyw, 1).x;
  r7.y = r7.y + -r4.y;
  r4.y = cb12[66].w * r7.y + r4.y;
  r7.y = -0.25 + cb13[0].z;
  r7.y = saturate(10 * r7.y);
  r3.z = -100 + r3.z;
  r3.z = saturate(0.00666666683 * r3.z);
  r4.y = r4.y + -r2.z;
  r2.z = r3.z * r4.y + r2.z;
  r2.z = -r7.y * r2.z + 1;
  r0.w = r2.z * r0.w;
  float custom_water_visibility = r0.w;
  r8.zw = cb12[211].zw * r0.yy;
  r0.xy = cb12[210].zw * r0.xx + r8.zw;
  r0.xy = cb12[212].zw * r1.ww + r0.xy;
  r0.xy = cb12[213].zw + r0.xy;
  r0.x = r0.x / r0.y;
  r0.x = -v2.w + r0.x;
  r0.y = dot(r11.xy, r11.xy);
  r0.y = sqrt(r0.y);
  r1.w = saturate(1 + r11.z);
  r1.w = r1.w * 0.350000024 + 0.649999976;
  r1.w = r2.y * r1.w;
  r2.y = abs(r8.x) + abs(r8.y);
  r8.xy = float2(0.0160000008,0.0109999999) * r0.yy;
  r2.z = 1 + -r6.x;
  r3.z = saturate(r0.y * 0.00499999989 + -r2.z);
  r4.y = -r9.w + abs(r4.w);
  r3.z = r3.z * r4.y + r9.w;
  r3.z = log2(r3.z);
  r3.z = 0.600000024 * r3.z;
  r3.z = exp2(r3.z);
  r4.y = saturate(cb0[9].w);
  r9.xyz = r4.yyy * float3(0.169999987,0,0.0300000012) + float3(0.330000013,0.319999993,0.310000002);
  r9.xyz = r9.xyz * r3.zzz;
  r4.y = r5.y * r1.y;
  r8.zw = min(float2(1,0.300000012), r3.xx);
  r10.xy = float2(10,20) * r2.yy;
  r4.y = saturate(r4.y * r8.z + -r10.x);
  r10.xz = float2(0.150000006,0.00999999978) * r1.zz;
  r5.y = r1.y * 0.899999976 + r10.x;
  r5.y = r5.y * r2.y;
  r5.y = 20 * r5.y;
  r5.y = saturate(r5.y * r8.w);
  r3.w = r3.w * r4.y + r5.y;
  r11.z = r4.z * r1.x + r8.x;
  r0.y = -r0.y * 0.00555555569 + 1;
  r0.y = max(0, r0.y);
  r0.y = max(0.0500000007, r0.y);
  r11.xy = r6.yz * r0.yy;
  r0.y = dot(r11.xyz, r11.xyz);
  r0.y = rsqrt(r0.y);
  r8.xzw = r11.xyz * r0.yyy;
  r0.y = dot(r15.xyz, r8.xzw);
  r1.x = cmp(0 < r0.y);
  if (r1.x != 0) {
    r4.xyz = r13.xyz * r4.xxx + r15.xyz;
    r1.x = dot(r4.xyz, r4.xyz);
    r1.x = rsqrt(r1.x);
    r4.xyz = r4.xyz * r1.xxx;
    r1.x = 1.14999998 + -r5.w;
    r1.x = min(1, r1.x);
    r1.x = r1.x * r1.x;
    r5.y = 0.699999988 * r1.x;
    r7.y = saturate(dot(r8.xzw, r4.xyz));
    r0.y = saturate(r0.y);
    r7.y = r7.y * r7.y;
    r7.y = r7.y * -0.999899983 + 1;
    r7.y = r7.y * r7.y;
    r7.y = 3.14152002 * r7.y;
    r7.y = 0.000100000012 / r7.y;
    r8.x = dot(r8.xzw, r14.xyz);
    r8.z = r0.y * 0.848749995 + 0.151250005;
    r8.z = r0.y / r8.z;
    r8.w = abs(r8.x) * 0.848749995 + 0.151250005;
    r8.w = abs(r8.x) / r8.w;
    r8.z = r8.z * r8.w;
    r7.y = r8.z * r7.y;
    r4.x = saturate(dot(r4.xyz, r14.xyz));
    r4.x = 1 + -r4.x;
    r1.x = -r1.x * 0.699999988 + 0.899999976;
    r4.x = r4.x * r4.x;
    r4.x = r4.x * r4.x;
    r1.x = r1.x * r4.x + r5.y;
    r1.x = r7.y * r1.x;
    r4.x = abs(r8.x) * r0.y;
    r4.x = 4 * r4.x;
    r1.x = r1.x / r4.x;
    r0.y = r1.x * r0.y;
    r4.xyz = min(float3(1,1,1), r0.yyy);
  } else {
    r4.xyz = float3(0,0,0);
  }
  r8.xzw = log2(cb13[1].xyz);
  r8.xzw = float3(0.454545468,0.454545468,0.454545468) * r8.xzw;
  r8.xzw = exp2(r8.xzw);
  r4.xyz = r8.xzw * r4.xyz;
  r4.xyz = r4.xyz * r6.xxx;
  r0.y = -r5.w * 5 + 7;
  r1.x = log2(r3.x);
  r0.y = r1.x * r0.y;
  r0.y = exp2(r0.y);
  r0.y = 0.100000001 * r0.y;
  r1.x = saturate(dot(r6.yzw, cb0[9].xyz));
  r1.x = 1 + -r1.x;
  r1.x = r1.x * 0.800000012 + 0.200000003;
  r0.y = r1.x * r0.y;
  r1.x = 0.5 + cb0[13].x;
  r1.x = max(0, r1.x);
  r1.x = min(20, r1.x);
  r5.y = r1.x + r1.x;
  r5.y = min(1, r5.y);
  r5.y = r6.x * r5.y;
  r0.y = r5.y * r0.y;
  r3.z = r3.z * r1.w;
  r3.xz = float2(0.5,0.5) * r3.xz;
  r3.z = min(1, r3.z);
  r3.z = r3.z * -0.25 + 1;
  r5.y = r10.z * r10.z;
  r5.y = r5.y * r5.y;
  r7.y = r5.y * r5.y;
  r3.x = log2(r3.x);
  r3.x = 12 * r3.x;
  r3.x = exp2(r3.x);
  r3.x = min(1, r3.x);
  r5.y = -r5.y * r5.y + r1.z;
  r3.x = r3.x * r5.y + r7.y;
  r5.y = rsqrt(r3.x);
  r5.y = 1 / r5.y;
  r5.y = r5.y * 0.5 + -r3.x;
  r3.x = r5.w * r5.y + r3.x;
  r5.y = max(0, r5.z);
  r5.z = 1 + -r5.y;
  r3.x = r5.z * r3.x;
  r3.x = r3.x * r5.w;
  r5.z = saturate(r2.x);
  r3.x = r5.z * -r3.x + r3.x;
  r1.y = r2.y * r1.y;
  r1.y = r1.y * 0.5 + r3.x;
  r1.y = max(r1.y, r3.w);
  float custom_water_foam = saturate(r1.y);
  r2.y = 20 * cb0[12].z;
  r3.x = cb0[12].w * 20 + -r2.y;
  r2.y = r0.w * r3.x + r2.y;
  r1.y = r2.y * r1.y;
  r2.y = r6.x * 0.899999976 + 0.100000001;
  r1.y = r2.y * r1.y;
  r0.z = saturate(cb0[12].y * r0.z);
  r2.y = r0.w * 0.699999988 + 0.300000012;
  r11.xyzw = float4(3,0.5,0.74000001,1) * r0.yyyy;
  r3.x = min(1, r11.x);
  r0.z = r3.x * r0.z;
  r3.x = r2.y * r0.z;
  r8.xzw = r2.yyy * r0.zzz + cb0[11].xyz;
  r3.xzw = r7.xzw * r3.zzz + r3.xxx;
  r4.xyz = r4.xyz * r0.www + r8.xzw;
  r0.z = r1.x * r1.y;
  r7.xyz = max(r11.yzw, r0.zzz);
  r4.xyz = r7.xyz + r4.xyz;
  r1.x = r2.x * r1.x;
  r1.y = saturate(r1.z * 0.850000024 + 0.150000006);
  r1.y = 4.5 * r1.y;
  r1.x = log2(r1.x);
  r1.x = 1.60000002 * r1.x;
  r1.x = exp2(r1.x);
  r1.x = r1.y * r1.x;
  r1.y = min(1, r10.y);
  r1.x = r1.y * -r1.x + r1.x;
  r1.xyz = r4.xyz + r1.xxx;
  r2.x = saturate(dot(r6.yzw, r14.xyz));
  r2.x = 1 + -r2.x;
  r2.x = r2.x * r2.x;
  r2.x = r2.x * r2.x;
  r2.x = r2.x * 0.25 + 0.0500000007;
  r2.y = 0.5 + cb0[12].x;
  r2.y = max(0.00999999978, r2.y);
  r2.y = min(6, r2.y);
  r2.x = log2(r2.x);
  r2.x = r2.y * r2.x;
  r2.x = exp2(r2.x);
  r2.y = 1 + -v3.w;
  r2.y = log2(r2.y);
  r2.y = 2.5 * r2.y;
  r2.y = exp2(r2.y);
  r2.x = r2.x * r2.y;
  r2.x = r2.x * r1.w;
  r2.y = cb0[12].w + -cb0[12].z;
  r0.w = r0.w * r2.y + cb0[12].z;
  r0.w = r2.x * r0.w;
  r0.x = saturate(-10 * r0.x);
  r0.x = 1 + -r0.x;
  r2.xy = max(float2(0.00999999978,0.5), r0.xx);
  r0.x = r2.x * r1.w;
  r4.xyz = r0.xxx * r9.xyz;
  r4.xyz = min(float3(1,1,1), r4.xyz);
  r1.xyz = r1.xyz * r6.xxx + -r3.xzw;
  r1.xyz = r4.xyz * r1.xyz + r3.xzw;
  r0.x = max(0, cb0[14].x);
  r0.x = min(10, r0.x);
  r1.w = 1 + -r2.x;
  r1.w = r8.y * r1.w;
  r1.w = min(1, r1.w);
  r3.xzw = r0.xxx * cb0[13].yzw + -r1.xyz;
  r1.xyz = r1.www * r3.xzw + r1.xyz;
  r0.x = r0.z * r5.y;
  r0.z = abs(r4.w) + abs(r4.w);
  r0.z = min(1, r0.z);
  r1.xyz = r0.zzz * r0.xxx + r1.xyz;
  r0.x = dot(float3(0.333000004,0.555000007,0.222000003), r1.xyz);
  r3.xzw = r0.xxx * v4.xyz + -r1.xyz;
  r1.xyz = v4.www * r3.xzw + r1.xyz;
  r3.xzw = v3.xyz + -r1.xyz;
  r1.xyz = v3.www * r3.xzw + r1.xyz;
  r0.x = rsqrt(r0.y);
  r0.x = 1 / r0.x;
  r0.x = 4 * r0.x;
  r0.x = min(1, r0.x);
  r0.x = r0.x * 0.600000024 + 0.400000006;
  r0.y = 0.5 * r2.z;
  r0.x = r0.w * r0.x + r0.y;
  r0.y = min(1, r9.x);
  r0.x = saturate(r0.x * r0.y);
  r0.x = r0.x * r2.y;
  r0.yzw = r16.xyz + -r1.xyz;
  o0.xyz = r3.yyy * r0.yzw + r1.xyz;
  r0.y = r2.w * 0.0850000009 + 0.0149999997;
  r0.z = cmp(r6.x < 0.999000013);
  r0.w = r0.y * r2.z;
  r0.w = 6 * r0.w;
  r0.y = r0.z ? r0.w : r0.y;
  r0.yw = r0.yy * r6.yz;
  r1.xy = r0.yw * float2(2.5,2.5) + float2(0.5,0.5);
  r0.x = rsqrt(r0.x);
  r1.w = 1 / r0.x;
  r1.z = r0.z ? 0 : 1;
  o1.xyzw = r5.xxxx * r1.xyzw;
  o0.w = 0;
  if (ClassicWaterReady() && cb12[0].z >= v2.z) {
    float4 water = ShadeClassicWater(t15,v0,v2.xyz,r6.yzw,cb13[0].xyz,cb13[1].xyz,
        custom_water_visibility,cb0[11].xyz,custom_water_foam,v3);
    // Keep the authored boat/interior water-exclusion volume and SSR encoding.
    o0.xyz = lerp(water.rgb,r16.xyz,saturate(r3.y));
    o1.w = sqrt(max(0.f,water.a*saturate(1.f-r3.y)));

  }
  return;
}
