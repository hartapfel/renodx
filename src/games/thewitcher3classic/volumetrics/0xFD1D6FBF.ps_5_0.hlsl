#include "../lighting/parameters.hlsli"
ByteAddressBuffer Raw20 : register(t20);
#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 18:39:40 2026
Texture2D<float4> t70 : register(t70);

Texture2D<float4> t69 : register(t69);

Texture2DArray<float4> t19 : register(t19);

Texture2D<float4> t18 : register(t18);

Texture2DArray<float4> t14 : register(t14);

Texture2D<float4> t12 : register(t12);

TextureCubeArray<float4> t10 : register(t10);

Texture2DArray<float4> t9 : register(t9);

Texture2DArray<float4> t8 : register(t8);

Texture3D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s14_s : register(s14);

SamplerState s12_s : register(s12);

SamplerState s10_s : register(s10);

SamplerComparisonState s9_s : register(s9);

SamplerState s3_s : register(s3);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb12 : register(b12)
{
  float4 cb12[219];
}

cbuffer cb13 : register(b13)
{
  float4 cb13[3323];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[19];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[13];
}

cbuffer cb6 : register(b6)
{
  float4 cb6[50];
}

cbuffer cb5 : register(b5)
{
  float4 cb5[44];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[69];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float4 v5 : TEXCOORD5,
  float4 v6 : TEXCOORD6,
  float4 v7 : TEXCOORD7,
  float4 v8 : TEXCOORD8,
  float4 v9 : TEXCOORD9,
  float4 v10 : TEXCOORD10,
  float3 v11 : TEXCOORD11,
  float4 v12 : SV_Position0,
  uint v13 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
// Native light-index buffer declaration.
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22;
  uint4 bitmask, uiDest;
  float4 fDest;

  ClassicForwardFog(v12, v0.w, v5);


  r0.x = v1.w;
  r0.y = v3.w;
  r1.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r0.z = saturate(3.030303 * r1.w);
  r0.w = cmp(0.999000013 < r0.z);
  if (r0.w != 0) discard;
  r2.xyz = cmp(cb2[18].yzw != float3(0,0,0));
  if (r2.x != 0) {
    r3.xyzw = float4(16,16,16,16) * v12.xyxy;
    r3.xyzw = cmp(r3.xyzw >= -r3.zwzw);
    r3.xyzw = r3.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r2.xw = v12.xy * r3.zw;
    r2.xw = frac(r2.xw);
    r2.xw = r3.xy * r2.xw;
    r2.xw = trunc(r2.xw);
    r3.xy = (int2)r2.xw;
    r3.zw = float2(0,0);
    r0.w = t18.Load(r3.xyz).x;
    r0.w = r0.w * v2.x + v2.y;
    r0.w = cmp(r0.w < 0);
    if (r0.w != 0) discard;
  }
  if (r2.y != 0) {
    r0.w = t12.Sample(s12_s, v7.xy).x;
    r0.w = r0.w * v2.z + v2.w;
    r0.w = cmp(r0.w < 0);
    if (r0.w != 0) discard;
  }
  r0.w = dot(v1.xyz, v1.xyz);
  r0.w = -1 + r0.w;
  r0.w = cmp(r0.w < 0);
  r0.w = r0.w ? r2.z : 0;
  if (r0.w != 0) discard;
  r0.w = cmp(0.00294117653 < r0.z);
  r0.w = r0.w ? -1.000000 : 0;
  r2.x = -0.330000013 + r1.w;
  r2.x = cmp(r2.x < 0);
  r0.w = r0.w ? r2.x : 0;
  r0.w = cmp(r0.w != 0.000000);
  r2.xyzw = t1.Sample(s0_s, r0.xy).wxyz;
  if (r0.w != 0) {
    r3.xyz = v10.xyz;
    r3.w = 1;
    r4.x = dot(cb6[1].xyzw, r3.xyzw);
    r4.y = dot(cb6[2].xyzw, r3.xyzw);
    r4.z = dot(cb6[3].xyzw, r3.xyzw);
    r0.x = dot(cb6[4].xyzw, r3.xyzw);
    r0.xyw = r4.xyz / r0.xxx;
    r0.w = -cb6[11].z + r0.w;
    r0.w = max(9.99999975e-005, r0.w);
    r0.w = cb6[11].w / r0.w;
    r3.xy = r0.xy * float2(0.5,-0.5) + float2(0.5,0.5);
    r0.x = r0.w * cb6[19].x + cb6[19].y;
    r0.x = log2(r0.x);
    r0.x = cb6[19].z * r0.x;
    r3.z = cb6[18].z * r0.x;
    r0.x = t3.SampleLevel(s2_s, r3.xyz, 0).x;
    r0.y = max(0.00100000005, v6.w);
    r3.xyz = v3.xyz / r0.yyy;
    r4.xyz = v4.xyz / r0.yyy;
    r0.y = cmp(0 < r0.x);
    if (r0.y != 0) {
      r0.yw = float2(0.333333343,0.25) * r0.xx;
      r0.y = saturate(r0.y);
      r3.w = r0.y * -2 + 3;
      r0.y = r0.y * r0.y;
      r0.y = r3.w * r0.y;
      r3.w = -r0.y * 0.5 + 1;
      r5.xyz = t2.SampleLevel(s2_s, float2(0.5,0.5), 0).xyz;
      r5.xyz = float3(0.25,0.25,0.25) * r5.xyz;
      r4.w = 1 + -cb6[47].w;
      r5.xyz = r5.xyz * r4.www;
      r5.xyz = r5.xyz * r0.yyy;
      r6.xyz = r3.xyz * r3.www + r5.xyz;
      r5.xyz = r4.xyz * r3.www + r5.xyz;
      r7.xyz = cb6[48].xyz + cb6[47].xyz;
      r0.y = max(0, r0.w);
      r7.xyz = -r0.yyy * r7.xyz;
      r7.xyz = float3(1.44269502,1.44269502,1.44269502) * r7.xyz;
      r7.xyz = exp2(r7.xyz);
      r3.xyz = r7.xyz * r6.xyz;
      r4.xyz = r7.xyz * r5.xyz;
    }
    r0.y = cmp(0.00100000005 < v6.w);
    if (r0.y == 0) discard;
    r0.w = r1.x + r1.y;
    r0.w = r0.w + r1.z;
    r3.w = -1 + cb4[1].x;
    r3.w = 0.5 * r3.w;
    r4.w = saturate(r3.w);
    r5.x = 0.333299994 * r0.w;
    r0.w = r0.w * -0.666599989 + 1;
    r0.w = r4.w * r0.w + r5.x;
    r5.xyzw = cb4[0].xyzw * r1.xyzw;
    r5.xyzw = saturate(float4(1.5,1.5,1.5,1.5) * r5.xyzw);
    r0.w = saturate(r0.w * abs(r3.w));
    r5.xyzw = r5.xyzw + -r1.xyzw;
    r1.xyzw = r0.wwww * r5.xyzw + r1.xyzw;
    r0.w = cmp(0 < cb4[3].x);
    r3.w = r1.x + r1.z;
    r5.xy = r1.xz / r3.ww;
    r5.xy = float2(-0.300000012,-0.300000012) + r5.xy;
    r5.xy = saturate(float2(1.42857146,1.42857146) * r5.xy);
    r3.w = r5.x + r5.y;
    r3.w = r5.y / r3.w;
    r4.w = 1 + -r3.w;
    r5.xyzw = cb2[11].zyxw * r3.wwww;
    r6.xyzw = cb2[12].zyxw * r3.wwww;
    r7.xyzw = cb2[13].zyxw * r3.wwww;
    r5.xyzw = r4.wwww * cb2[7].xyzw + r5.xyzw;
    r6.xyzw = r4.wwww * cb2[8].xyzw + r6.xyzw;
    r7.xyzw = r4.wwww * cb2[9].xyzw + r7.xyzw;
    r3.w = cmp(r1.x >= r1.z);
    r8.xyzw = r3.wwww ? cb2[7].xyzw : cb2[11].zyxw;
    r9.xyzw = r3.wwww ? cb2[8].xyzw : cb2[12].zyxw;
    r10.xyzw = r3.wwww ? cb2[9].xyzw : cb2[13].zyxw;
    r5.xyzw = r0.wwww ? r5.xyzw : r8.xyzw;
    r6.xyzw = r0.wwww ? r6.xyzw : r9.xyzw;
    r7.xyzw = r0.wwww ? r7.xyzw : r10.xyzw;
    r0.w = cmp(0 < cb4[4].x);
    r3.w = min(r1.y, r1.z);
    r3.w = min(r3.w, r1.x);
    r4.w = max(r1.y, r1.z);
    r4.w = max(r4.w, r1.x);
    r3.w = r4.w + -r3.w;
    r3.w = r3.w / r4.w;
    r3.w = -0.100000001 + r3.w;
    r3.w = saturate(5 * r3.w);
    r3.w = cb4[2].x * r3.w;
    r0.w = r0.w ? r3.w : cb4[2].x;
    r2.yzw = float3(-0.5,-0.5,-0.5) + r2.yzw;
    r2.yzw = r2.yzw + r2.yzw;
    r8.x = v4.w;
    r8.yz = v7.zw;
    r8.xyz = r8.xyz * r2.zzz;
    r8.xyz = v11.xyz * r2.yyy + r8.xyz;
    r2.yzw = v9.xyz * r2.www + r8.xyz;
    r3.w = cmp(0 >= (uint)v13.x);
    r4.w = dot(v9.xyz, r2.yzw);
    r8.xyz = v9.xyz * r4.www;
    r8.xyz = r8.xyz * float3(-2,-2,-2) + r2.yzw;
    r8.xyz = r3.www ? r8.xyz : r2.yzw;
    r5.x = dot(r1.xyzw, r5.xyzw);
    r5.y = dot(r1.xyzw, r6.xyzw);
    r5.z = dot(r1.xyzw, r7.xyzw);
    r5.xyz = r5.xyz + -r1.xyz;
    r1.xyz = r0.www * r5.xyz + r1.xyz;
    r1.xyz = saturate(v8.xyz * r1.xyz);
    r0.w = 1 + -r2.x;
    r5.xyz = log2(cb4[5].xyz);
    r5.xyz = float3(2.20000005,2.20000005,2.20000005) * r5.xyz;
    r5.xyz = exp2(r5.xyz);
    r0.w = r0.w * cb4[6].x + cb4[7].x;
    r5.xyz = saturate(r5.xyz * r0.www);
    r5.xyz = log2(r5.xyz);
    r6.xyz = cb1[8].xyz + -v10.xyz;
    r0.w = dot(r6.xyz, r6.xyz);
    r0.w = rsqrt(r0.w);
    r6.xyz = r6.xyz * r0.www;
    r0.w = dot(r2.yzw, r6.xyz);
    r0.w = saturate(1 + -r0.w);
    r0.w = r0.w * r0.w;
    r0.w = log2(r0.w);
    r0.w = cb4[8].x * r0.w;
    r0.w = exp2(r0.w);
    r0.w = cb4[9].x * r0.w;
    r0.w = saturate(cb4[10].x * r0.w);
    r1.xyz = log2(r1.xyz);
    r1.xyz = float3(2.20000005,2.20000005,2.20000005) * r1.xyz;
    r1.xyz = exp2(r1.xyz);
    r2.yzw = float3(0.999998987,0.999998987,0.999998987) * r5.xyz;
    r2.yzw = exp2(r2.yzw);
    r2.x = saturate(r2.x);
    r5.xy = (uint2)v12.yx;
    r1.w = dot(r8.xyz, r8.xyz);
    r1.w = rsqrt(r1.w);
    r6.xyz = r8.xyz * r1.www;
    r1.w = dot(v9.xyz, v9.xyz);
    r1.w = rsqrt(r1.w);
    r7.xyz = v9.xyz * r1.www;
    r5.xy = (uint2)r5.xy >> int2(4,4);
    r5.xy = (uint2)r5.xy;
    r1.w = trunc(cb12[24].x);
    r1.w = (int)r1.w;
    r5.xy = (int2)r5.xy;
    r1.w = mad((int)r5.x, (int)r1.w, (int)r5.y);
    r1.w = (int)r1.w;
    r1.w = (uint)r1.w;
    r1.w = (uint)r1.w << 8;
    r1.w = (uint)r1.w;
    r5.xyz = cb12[0].xyz + -v10.xyz;
    r3.w = dot(r5.xyz, r5.xyz);
    r3.w = rsqrt(r3.w);
    r8.xyz = r5.xyz * r3.www;
    r9.xy = v6.yz / v6.ww;
    r9.x = saturate(r9.x);
    r9.y = saturate(1.00196469 * r9.y);
    r9.xy = r0.yy ? r9.xy : float2(1,1);
    r9.zw = -cb3[0].xy + v10.xy;
    r0.y = dot(r9.zw, r9.zw);
    r0.y = sqrt(r0.y);
    r10.xyz = -cb3[0].xyz + v10.xyz;
    r4.w = dot(r10.xyz, r10.xyz);
    r4.w = sqrt(r4.w);
    r5.w = cmp(r0.y < cb5[36].y);
    if (r5.w != 0) {
      r5.w = cb5[37].z * r0.y;
      r5.w = max(1, r5.w);
      r5.w = cb5[36].x / r5.w;
      r5.w = min(10, r5.w);
      r6.w = r4.w * 0.0199999996 + 0.0500000007;
      r0.y = cb5[36].z + r0.y;
      r0.y = saturate(cb5[36].w * r0.y);
      r7.w = -10000 + -v10.z;
      r6.w = cmp(abs(r7.w) < r6.w);
      r6.w = r6.w ? 10000 : -v10.z;
      r10.y = 0;
      r9.zw = float2(0,0);
      r7.w = 0;
      while (true) {
        r8.w = cmp((int)r9.w >= asint(cb5[35].x));
        r7.w = 0;
        if (r8.w != 0) break;
        r10.zw = -cb5[r9.w+39].xy + v10.xy;
        r11.xy = cb5[r9.w+39].zw * r10.zw;
        r12.xy = cmp(r11.xy >= float2(0,0));
        r12.zw = cmp(float2(1,1) >= r11.xy);
        r12.xy = r12.zw ? r12.xy : 0;
        r8.w = r12.y ? r12.x : 0;
        if (r8.w != 0) {
          r11.w = (int)r9.w;
          r11.z = -r10.w * cb5[r9.w+39].w + 1;
          r10.z = t19.SampleLevel(s10_s, r11.xzw, 0).x;
          r10.z = cb5[38].x * r10.z + cb5[38].y;
          r10.z = r10.z + r6.w;
          r10.z = -0.100000001 + r10.z;
          r10.z = saturate(r10.z * r5.w);
          r10.z = 1 + -r10.z;
          r10.w = 1 + -r10.z;
          r9.z = r0.y * r10.w + r10.z;
          r7.w = -1;
          break;
        }
        r10.x = (int)r9.w + 1;
        r9.zw = r10.yx;
        r7.w = r8.w;
      }
    } else {
      r7.w = 0;
    }
    r0.y = r7.w ? r9.z : 1;
    r5.w = cmp(0 < r0.y);
    if (r5.w != 0) {
      r9.zw = (int2)v12.xy;
      r10.xy = (int2)r9.zw & int2(255,255);
      r10.zw = float2(0,0);
      r5.w = t69.Load(r10.xyz).x;
      r10.xyz = cb5[5].xyz * v10.yyy;
      r10.xyz = v10.xxx * cb5[4].xyz + r10.xyz;
      r10.xyz = v10.zzz * cb5[6].xyz + r10.xyz;
      r10.xyz = cb5[7].xyz + r10.xyz;
      r6.w = cmp(abs(r10.z) < 0.999000013);
      if (r6.w != 0) {
        r11.xyzw = -cb5[8].xyzw + r10.xxxx;
        r12.xyzw = -cb5[9].xyzw + r10.yyyy;
        r11.xyzw = max(abs(r12.xyzw), abs(r11.xyzw));
        r12.xyzw = cmp(r11.xyzw < cb5[10].xyzw);
        r12.xyzw = r12.xyzw ? float4(1,1,1,1) : 0;
        r13.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb5[15].zzzz);
        r13.xyzw = r13.xyzw ? float4(1,1,1,1) : 0;
        r6.w = dot(r12.xyzw, r13.xyzw);
        r7.w = cmp(r6.w >= 0.5);
        if (r7.w != 0) {
          r11.xyzw = r11.xyzw / cb5[10].xyzw;
          r12.xyzw = float4(1,1,1,1) + -cb5[17].xyzw;
          r11.xyzw = -r12.xyzw + r11.xyzw;
          r11.xyzw = saturate(r11.xyzw / cb5[17].xyzw);
          r6.w = cb5[15].z + -r6.w;
          r6.w = (uint)r6.w;
          r7.w = -1 + cb5[15].z;
          r7.w = (uint)r7.w;
          r8.w = dot(r11.xyzw, icb[r6.w+0].xyzw);
          r8.w = cmp(r5.w < r8.w);
          r8.w = r8.w ? 0.000000 : 0;
          r6.w = (int)r6.w + (int)r8.w;
          r6.w = min((uint)r6.w, (uint)r7.w);
          r10.w = 1;
          r9.zw = cb5[r6.w+11].zz * r10.wy;
          r10.y = -1;
          r12.xy = r10.xy * r9.zw + cb5[r6.w+11].xy;
          r8.w = 6.28318548 * r5.w;
          if (cb6[49].w != 0) {
            r9.z = cb5[r6.w+11].z / cb5[r6.w+11].z;
            r9.z = cb6[0].w * r9.z;
            r12.z = (uint)r6.w;
            r9.w = t8.SampleLevel(s1_s, r12.xyz, 0).x;
            r10.x = cmp(r9.w < r10.z);
            r9.w = r10.x ? r9.w : 0;
            r13.xyzw = float4(0.00124999997,0.00216506352,0.00279508485,0.00330718886) * r9.zzzz;
            sincos(r8.w, r14.x, r15.x);
            r15.y = r14.x;
            r14.xy = r15.xy * r13.xx + r12.xy;
            r14.z = r12.z;
            r15.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r15.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r15.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = r10.x ? 1.000000 : 0;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(2.39996004,4.79992008,7.19988012,9.59984016);
            sincos(r15.x, r13.x, r16.x);
            r16.y = r13.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.y, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.zz + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.z, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.ww + r12.xy;
            r13.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r13.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r13.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r13.xyzw = float4(0.00374999992,0.00414578104,0.00450693909,0.00484122941) * r9.zzzz;
            sincos(r15.w, r15.x, r16.x);
            r16.y = r15.x;
            r14.xy = r16.xy * r13.xx + r12.xy;
            r15.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r15.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r15.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(11.9997997,14.3997602,16.7997208,19.1996803);
            sincos(r15.x, r13.x, r16.x);
            r16.y = r13.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.y, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.zz + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.z, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.ww + r12.xy;
            r13.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r13.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r13.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r13.xyzw = float4(0.00515388185,0.00544862356,0.00572821964,0.0059947893) * r9.zzzz;
            sincos(r15.w, r15.x, r16.x);
            r16.y = r15.x;
            r14.xy = r16.xy * r13.xx + r12.xy;
            r15.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r15.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r15.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(21.5996399,23.9995995,26.3995609,28.7995205);
            sincos(r15.x, r13.x, r16.x);
            r16.y = r13.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.y, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.zz + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.z, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.ww + r12.xy;
            r13.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r13.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r13.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r13.xyzw = float4(0.00624999963,0.00649519032,0.00673145568,0.00695970515) * r9.zzzz;
            sincos(r15.w, r15.x, r16.x);
            r16.y = r15.x;
            r14.xy = r16.xy * r13.xx + r12.xy;
            r15.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r15.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r15.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(31.1994801,33.5994415,35.9994011,38.3993607);
            sincos(r15.x, r13.x, r16.x);
            r16.y = r13.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.y, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.zz + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.z, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.ww + r12.xy;
            r13.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r13.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r13.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r13.xyzw = float4(0.00718070334,0.00739509985,0.00760345301,0.0078062471) * r9.zzzz;
            sincos(r15.w, r15.x, r16.x);
            r16.y = r15.x;
            r14.xy = r16.xy * r13.xx + r12.xy;
            r15.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r15.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r15.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(40.7993202,43.1992798,45.5992393,47.9991989);
            sincos(r15.x, r13.x, r16.x);
            r16.y = r13.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.y, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.zz + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.z, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.ww + r12.xy;
            r13.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r13.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r13.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r13.xyzw = float4(0.00800390542,0.00819679815,0.008385255,0.0085695684) * r9.zzzz;
            sincos(r15.w, r15.x, r16.x);
            r16.y = r15.x;
            r14.xy = r16.xy * r13.xx + r12.xy;
            r15.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r15.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r15.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(50.3991623,52.7991219,55.1990814,57.599041);
            sincos(r15.x, r13.x, r16.x);
            r16.y = r13.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.y, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.zz + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.z, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.ww + r12.xy;
            r13.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r13.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r13.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r13.xyzw = float4(0.00875000004,0.00892678555,0.00910013728,0.009270248) * r9.zzzz;
            sincos(r15.w, r15.x, r16.x);
            r16.y = r15.x;
            r14.xy = r16.xy * r13.xx + r12.xy;
            r15.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r15.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r15.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(59.9990005,62.3989601,64.7989197,67.1988831);
            sincos(r15.x, r13.x, r16.x);
            r16.y = r13.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.y, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.zz + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.z, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.ww + r12.xy;
            r13.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r13.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r13.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r13.xyzw = float4(0.00943729281,0.0096014319,0.00976281241,0.00992156751) * r9.zzzz;
            sincos(r15.w, r15.x, r16.x);
            r16.y = r15.x;
            r14.xy = r16.xy * r13.xx + r12.xy;
            r15.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r16.xyzw = cmp(r15.xyzw < r10.zzzz);
            r16.xyzw = r16.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r16.xyzw, r15.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r16.x + r16.y;
            r10.y = r10.y + r16.z;
            r10.y = r10.y + r16.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r15.xyz = r5.www * float3(6.28318548,6.28318548,6.28318548) + float3(69.5988388,71.9988022,74.3987579);
            sincos(r15.x, r13.x, r16.x);
            r16.y = r13.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.y, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.zz + r12.xy;
            r16.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r17.xyzw = cmp(r16.xyzw < r10.zzzz);
            r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r17.xyzw, r16.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r17.x + r17.y;
            r10.y = r10.y + r17.z;
            r10.y = r10.y + r17.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            sincos(r15.z, r13.x, r15.x);
            r15.y = r13.x;
            r14.xy = r15.xy * r13.ww + r12.xy;
            r13.xyzw = t8.Gather(s1_s, r14.xyz).xyzw;
            r14.xyzw = cmp(r13.xyzw < r10.zzzz);
            r14.xyzw = r14.xyzw ? float4(1,1,1,1) : 0;
            r10.y = dot(r14.xyzw, r13.xyzw);
            r9.w = r10.y + r9.w;
            r10.y = r14.x + r14.y;
            r10.y = r10.y + r14.z;
            r10.y = r10.y + r14.w;
            r10.x = (uint)r10.x;
            r10.x = r10.x + r10.y;
            r10.x = (uint)r10.x;
            r10.yw = cmp((int2)r10.xx == int2(0,129));
            if (r10.w != 0) {
              r13.x = 0;
            } else {
              r13.x = 1;
            }
            r12.z = (uint)r10.x;
            r9.w = r9.w / r12.z;
            r12.z = 32 * cb6[0].z;
            r12.w = r10.z + -r9.w;
            r12.z = r12.z * r12.w;
            r9.w = r12.z / r9.w;
            r9.w = min(1, r9.w);
            r12.z = cb5[r6.w+11].w * 0.5;
            r9.z = r9.w * r9.z;
            r9.z = 0.00999999978 * r9.z;
            r9.z = max(r12.z, r9.z);
            r13.y = r10.w ? cb5[r6.w+11].w : r9.z;
            r14.x = 1;
            r14.y = cb5[r6.w+11].w;
            r9.zw = r10.xx ? r13.xy : r14.xy;
            r10.x = (int)r10.y | (int)r10.w;
          } else {
            r9.z = 1;
            r9.w = cb5[r6.w+11].w;
            r10.x = 0;
          }
          if (r10.x == 0) {
            r13.xyzw = float4(0.125,0.216506347,0.279508501,0.330718905) * r9.wwww;
            sincos(r8.w, r10.x, r14.x);
            r14.y = r10.x;
            r14.xy = r14.xy * r13.xx + r12.xy;
            r14.z = (uint)r6.w;
            r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(2.39996004,4.79992008,7.19988012,9.59984016);
            sincos(r15.x, r10.x, r16.x);
            r16.y = r10.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.y, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.zz + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.z, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.ww + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r13.xyzw = float4(0.375,0.41457811,0.450693905,0.484122932) * r9.wwww;
            sincos(r15.w, r10.x, r15.x);
            r15.y = r10.x;
            r14.xy = r15.xy * r13.xx + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(11.9997997,14.3997602,16.7997208,19.1996803);
            sincos(r15.x, r10.x, r16.x);
            r16.y = r10.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.y, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.zz + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.z, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.ww + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r13.xyzw = float4(0.515388191,0.54486239,0.572821975,0.59947896) * r9.wwww;
            sincos(r15.w, r10.x, r15.x);
            r15.y = r10.x;
            r14.xy = r15.xy * r13.xx + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(21.5996399,23.9995995,26.3995609,28.7995205);
            sincos(r15.x, r10.x, r16.x);
            r16.y = r10.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.y, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.zz + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.z, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.ww + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r13.xyzw = float4(0.625,0.649519026,0.673145592,0.695970535) * r9.wwww;
            sincos(r15.w, r10.x, r15.x);
            r15.y = r10.x;
            r14.xy = r15.xy * r13.xx + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(31.1994801,33.5994415,35.9994011,38.3993607);
            sincos(r15.x, r10.x, r16.x);
            r16.y = r10.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.y, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.zz + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.z, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.ww + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r13.xyzw = float4(0.718070328,0.73951,0.76034534,0.780624747) * r9.wwww;
            sincos(r15.w, r10.x, r15.x);
            r15.y = r10.x;
            r14.xy = r15.xy * r13.xx + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(40.7993202,43.1992798,45.5992393,47.9991989);
            sincos(r15.x, r10.x, r16.x);
            r16.y = r10.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.y, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.zz + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.z, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.ww + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r13.xyzw = float4(0.800390542,0.819679797,0.838525474,0.85695684) * r9.wwww;
            sincos(r15.w, r10.x, r15.x);
            r15.y = r10.x;
            r14.xy = r15.xy * r13.xx + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(50.3991623,52.7991219,55.1990814,57.599041);
            sincos(r15.x, r10.x, r16.x);
            r16.y = r10.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.y, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.zz + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.z, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.ww + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r13.xyzw = float4(0.875,0.892678559,0.910013735,0.927024782) * r9.wwww;
            sincos(r15.w, r10.x, r15.x);
            r15.y = r10.x;
            r14.xy = r15.xy * r13.xx + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r15.xyzw = r5.wwww * float4(6.28318548,6.28318548,6.28318548,6.28318548) + float4(59.9990005,62.3989601,64.7989197,67.1988831);
            sincos(r15.x, r10.x, r16.x);
            r16.y = r10.x;
            r14.xy = r16.xy * r13.yy + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.y, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.zz + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            sincos(r15.z, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.ww + r12.xy;
            r10.x = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r10.x + r8.w;
            r13.xyzw = float4(0.943729281,0.960143209,0.976281226,0.992156744) * r9.wwww;
            sincos(r15.w, r10.x, r15.x);
            r15.y = r10.x;
            r14.xy = r15.xy * r13.xx + r12.xy;
            r9.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r8.w = r9.w + r8.w;
            r10.xyw = r5.www * float3(6.28318548,6.28318548,6.28318548) + float3(69.5988388,71.9988022,74.3987579);
            sincos(r10.x, r10.x, r15.x);
            r15.y = r10.x;
            r14.xy = r15.xy * r13.yy + r12.xy;
            r5.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r5.w = r8.w + r5.w;
            sincos(r10.y, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.zz + r12.xy;
            r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r5.w = r8.w + r5.w;
            sincos(r10.w, r10.x, r13.x);
            r13.y = r10.x;
            r14.xy = r13.xy * r13.ww + r12.xy;
            r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
            r5.w = r8.w + r5.w;
            r6.w = cmp((uint)r6.w >= (uint)r7.w);
            r6.w = r6.w ? 1.000000 : 0;
            r7.w = dot(r11.xyzw, icb[r7.w+0].xyzw);
            r6.w = r7.w * r6.w;
            r5.w = r5.w * 0.03125 + r6.w;
            r9.z = min(1, r5.w);
          }
        } else {
          r9.z = 1;
        }
      } else {
        r9.z = 1;
      }
      r5.w = r9.z * r0.y;
      r6.w = 20 * cb3[66].x;
      r10.zw = trunc(cb3[68].xy);
      r11.xy = cb3[67].xy;
      r11.z = 0;
      r11.xyz = v10.xyz + r11.xyz;
      r11.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r11.xyz;
      r11.xyz = r11.xyz / cb3[66].xxx;
      r12.xy = float2(20,20) * cb3[67].xy;
      r12.z = 0;
      r12.xyz = v10.xyz + r12.xyz;
      r12.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r12.xyz;
      r12.xyz = r12.xyz / r6.www;
      r9.zw = cb5[0].xy * r11.zz;
      r9.zw = r9.zw / cb5[0].zz;
      r10.xy = r11.xy + -r9.zw;
      r9.zw = cb5[0].xy * r12.zz;
      r9.zw = r9.zw / cb5[0].zz;
      r11.xy = r12.xy + -r9.zw;
      r6.w = t14.SampleLevel(s14_s, r10.xyz, 1).x;
      r7.w = t14.SampleLevel(s14_s, r10.xyw, 1).x;
      r7.w = r7.w + -r6.w;
      r6.w = cb3[66].w * r7.w + r6.w;
      r11.zw = r10.zw;
      r7.w = t14.SampleLevel(s14_s, r11.xyz, 1).x;
      r8.w = t14.SampleLevel(s14_s, r11.xyw, 1).x;
      r8.w = r8.w + -r7.w;
      r7.w = cb3[66].w * r8.w + r7.w;
      r8.w = -0.25 + cb5[0].z;
      r8.w = saturate(10 * r8.w);
      r4.w = -100 + r4.w;
      r4.w = saturate(0.00666666683 * r4.w);
      r7.w = r7.w + -r6.w;
      r4.w = r4.w * r7.w + r6.w;
      r4.w = -r8.w * r4.w + 1;
      r0.y = r5.w * r4.w;
    }
    r4.w = cmp(0 < r0.y);
    if (r4.w != 0) {
      r4.w = dot(r7.xyz, cb13[0].xyz);
      r4.w = cb4[12].x + r4.w;
      r5.w = 1 + cb4[12].x;
      r4.w = saturate(r4.w / r5.w);
      r5.w = dot(r6.xyz, cb13[0].xyz);
      r6.w = r5.w + r4.w;
      r4.w = 1 + r4.w;
      r6.w = r6.w / r4.w;
      r4.w = 1 / r4.w;
      r10.xyz = saturate(r6.www);
      r11.xyz = r5.xyz * r3.www + cb13[0].xyz;
      r6.w = dot(r11.xyz, r11.xyz);
      r6.w = rsqrt(r6.w);
      r11.xyz = r11.xyz * r6.www;
      r6.w = dot(r11.xyz, r8.xyz);
      r6.w = 1 + -abs(r6.w);
      r6.w = max(0, r6.w);
      r7.w = r6.w * r6.w;
      r7.w = r7.w * r7.w;
      r6.w = r7.w * r6.w;
      r7.w = 1 + -r2.x;
      r11.xyz = float3(1,1,1) + -r2.yzw;
      r12.xyz = cb13[56].xxx * r11.xyz;
      r12.xyz = r12.xyz * r6.www;
      r6.w = cb13[56].z + 1;
      r6.w = -cb13[56].z * r7.w + r6.w;
      r12.xyz = r12.xyz / r6.www;
      r12.xyz = r12.xyz + r2.yzw;
      r12.xyz = float3(1,1,1) + -r12.xyz;
      r12.xyz = r12.xyz * r10.xyz;
      r12.xyz = float3(0.318309873,0.318309873,0.318309873) * r12.xyz;
      r6.w = cmp(0 < r0.w);
      r5.w = 1 + r5.w;
      r5.w = 0.5 * r5.w;
      r7.w = dot(cb13[0].xyz, -r8.xyz);
      r7.w = 1 + r7.w;
      r7.w = 0.5 * r7.w;
      r8.w = dot(r6.xyz, -r8.xyz);
      r8.w = 1 + r8.w;
      r8.w = cb12[36].w * r8.w;
      r7.w = r7.w * r7.w;
      r8.w = 0.5 * r8.w;
      r7.w = r7.w * r7.w + -r5.w;
      r5.w = cb12[36].x * r7.w + r5.w;
      r5.w = r8.w * r5.w;
      r7.w = cb12[36].y * r0.w;
      r11.xyz = cb12[36].zzz * r11.xyz + -r12.xyz;
      r11.xyz = r7.www * r11.xyz + r12.xyz;
      r11.xyz = r5.www * r0.www + r11.xyz;
      r11.xyz = r6.www ? r11.xyz : r12.xyz;
      r11.xyz = r11.xyz * r4.www;
      r9.zw = -cb12[0].xy + v10.xy;
      r4.w = dot(r9.zw, r9.zw);
      r4.w = sqrt(r4.w);
      r5.w = saturate(v10.z * cb12[218].z + cb12[218].w);
      r12.xyz = -cb13[52].xyz + cb13[51].xyz;
      r12.xyz = r5.www * r12.xyz + cb13[52].xyz;
      r4.w = saturate(r4.w * cb12[218].x + cb12[218].y);
      r12.xyz = -cb13[1].xyz + r12.xyz;
      r12.xyz = r4.www * r12.xyz + cb13[1].xyz;
      r4.w = cmp(0 >= r0.x);
      if (r4.w != 0) {
        r13.xyz = float3(1,1,1);
      }
      if (r4.w == 0) {
        r0.x = max(0, r0.x);
        r14.xyz = cb6[48].xyz + cb6[47].xyz;
        r4.w = r0.x / abs(cb6[46].z);
        r15.xyzw = cb6[46].xyxy * v10.zzzz;
        r15.xyzw = r15.xyzw / cb6[46].zzzz;
        r15.xyzw = v10.xyxy + -r15.xyzw;
        r16.xyzw = float4(0.0949999988,0.0474999994,-0.0500000007,0) * cb6[37].wwww;
        r15.xyzw = r15.xyzw * float4(0.200000003,0.200000003,0.200000003,0.200000003) + r16.xyzw;
        r5.w = t70.SampleLevel(s3_s, r15.xy, 0).x;
        r9.zw = float2(0.100000001,0.100000001) + r15.zw;
        r6.w = t70.SampleLevel(s3_s, r9.zw, 0).x;
        r5.w = min(r6.w, r5.w);
        r6.w = 1.5 * r0.x;
        r6.w = min(1, r6.w);
        r5.w = r5.w * 6 + -1;
        r5.w = r6.w * r5.w + 1;
        r14.xyz = -r4.www * r14.xyz;
        r14.xyz = float3(1.44269502,1.44269502,1.44269502) * r14.xyz;
        r14.xyz = exp2(r14.xyz);
        r14.xyz = cb6[46].www * r14.xyz;
        r0.x = -0.00999999978 + r0.x;
        r0.x = saturate(25 * r0.x);
        r14.xyz = r14.xyz * r5.www + float3(-1,-1,-1);
        r13.xyz = r0.xxx * r14.xyz + float3(1,1,1);
      }
      r12.xyz = r13.xyz * r12.xyz;
      r11.xyz = r11.xyz * r0.yyy;
      r11.xyz = r11.xyz * r12.xyz;
    } else {
      r10.xyz = float3(0,0,0);
      r11.xyz = float3(0,0,0);
    }
    r10.xyz = min(r10.xyz, r0.yyy);
    r0.x = cmp(r9.y == 1.000000);
    r0.y = cmp(cb2[16].x < 0);
    r0.y = r0.y ? 1 : cb12[71].x;
    float recipient_fill = r0.y;
    r4.w = 1 + cb4[12].x;
    r2.x = 1 + -r2.x;
    r9.yzw = float3(1,1,1) + -r2.yzw;
    r12.xyz = cb13[56].xxx * r9.yzw;
    r13.xy = cb13[56].zw + float2(1,1);
    r13.xy = -cb13[56].zw * r2.xx + r13.xy;
    r2.x = cmp(0 < r0.w);
    r5.w = dot(r6.xyz, -r8.xyz);
    r5.w = 1 + r5.w;
    r5.w = cb12[36].w * r5.w;
    r5.w = 0.5 * r5.w;
    r6.w = cb12[36].y * r0.w;
    r7.w = r0.x ? 0 : 1;
    r1.w = (int)r1.w;
    r14.xyz = r11.xyz;
    r8.w = 0;
    while (true) {
      r10.w = (int)r8.w;
      r11.w = cmp((int)r10.w >= 256);
      if (r11.w != 0) {
        break;
      }
      r11.w = (int)r1.w + (int)r10.w;
      r11.w = (int)r11.w;
      r11.w = (uint)r11.w;
      r11.w = (uint)r11.w << 2;
    r11.w = Raw20.Load((uint)r11.w);
      r12.w = cmp((uint)r11.w >= 256);
      if (r12.w != 0) {
        break;
      }
      r11.w = (uint)r11.w;
      r11.w = (int)r11.w;
      r11.w = (int)r11.w * 9;
      r11.w = (int)r11.w;
      r15.xyzw = float4(58,61,63,64) + r11.wwww;
      r15.xyzw = (uint4)r15.xyzw;
      r16.xyz = cb13[r15.x+0].xyz + -v10.xyz;
      r12.w = dot(r16.xyz, r16.xyz);
      r13.z = sqrt(r12.w);
      r13.w = r13.z / cb13[r15.x+0].w;
      r14.w = r13.w * r13.w;
      r14.w = -r14.w * r14.w + 1;
      r14.w = max(0, r14.w);
      r14.w = r14.w * r14.w;
      r17.xyz = int3(1,2048,4096) & asint(cb13[r15.y+0].www);
      r17.xyz = (int3)r17.xyz;
      r17.w = cmp(0 < cb13[r15.z+0].z);
      r18.x = cmp(0 < cb13[r15.w+0].x);
      r18.y = r12.w * cb13[r15.z+0].x + 1;
      r14.w = r14.w / r18.y;
      r17.x = cmp(r17.x != 0.000000);
      if (r17.x != 0) {
        r18.y = rsqrt(r12.w);
        r18.yzw = r18.yyy * r16.xyz;
        r19.xy = float2(60,62) + r11.ww;
        r19.xy = (uint2)r19.xy;
        r18.y = dot(-r18.yzw, cb13[r19.x+0].xyz);
        r18.y = saturate(r18.y * cb13[r19.y+0].y + cb13[r19.y+0].z);
        r18.y = log2(r18.y);
        r18.y = cb13[r19.y+0].w * r18.y;
        r18.y = exp2(r18.y);
        r14.w = r18.y * r14.w;
      }
      r18.y = cmp(0 < r14.w);
      r18.y = r18.y ? -1.000000 : 0;
      r17.w = r17.w ? r18.y : 0;
      r17.w = cmp(r17.w != 0.000000);
      if (r17.w != 0) {
        if (r17.x != 0) {
          r19.xyz = -cb13[r15.x+0].xyz + v10.xyz;
          r17.xw = float2(65,60) + r11.ww;
          r17.xw = (uint2)r17.xw;
          r20.xyz = cb13[r17.x+0].zwy * cb13[r17.w+0].zxy;
          r20.xyz = cb13[r17.w+0].yzx * cb13[r17.x+0].wyz + -r20.xyz;
          r20.x = dot(r20.xyz, r19.xyz);
          r20.y = dot(cb13[r17.x+0].yzw, r19.xyz);
          r20.z = dot(cb13[r17.w+0].xyz, r19.xyz);
          r17.x = cb13[r17.x+0].x;
        } else {
          r20.xzw = -cb13[r15.x+0].xzy + v10.xzy;
          r19.xyz = r16.yzx / r13.zzz;
          r13.z = max(abs(r19.x), abs(r19.y));
          r13.z = cmp(r13.z < abs(r19.z));
          if (r13.z != 0) {
            r13.z = cmp(0 < r19.z);
            r21.xyz = float3(1,1,-1) * r20.wzx;
            r15.x = 65 + r11.w;
            r15.x = (uint)r15.x;
            r22.xyz = float3(-1,1,1) * r20.wzx;
            r20.xyz = r13.zzz ? r21.xyz : r22.xyz;
            r17.x = r13.z ? cb13[r15.x+0].x : cb13[r15.x+0].y;
          } else {
            r13.z = max(abs(r19.z), abs(r19.y));
            r13.z = cmp(r13.z < abs(r19.x));
            if (r13.z != 0) {
              r13.z = cmp(0 < r19.x);
              r19.xzw = float3(-1,1,-1) * r20.xzw;
              r15.x = 65 + r11.w;
              r15.x = (uint)r15.x;
              r20.xyz = r13.zzz ? r19.xzw : r20.xzw;
              r17.x = r13.z ? cb13[r15.x+0].z : cb13[r15.x+0].w;
            } else {
              r13.z = cmp(0 < r19.y);
              r20.y = r13.z ? r20.w : -r20.w;
              r20.z = r13.z ? -r20.z : r20.z;
              r15.x = 66 + r11.w;
              r15.x = (uint)r15.x;
              r17.x = r13.z ? cb13[r15.x+0].x : cb13[r15.x+0].y;
            }
          }
        }
        r13.z = asuint(r17.x) & 1023u;
        r13.z = (uint)r13.z;
        r15.x = cmp(0 != r13.z);
        if (r15.x != 0) {
          r15.xz = cb13[r15.z+0].yy * r20.xy;
          r15.xz = r15.xz / r20.zz;
          r15.xz = r15.xz * float2(0.5,-0.5) + float2(0.5,0.5);
          float4 atlas = DecodeShadowAtlas(r17.x);
          r18.zw = atlas.xy;
          r19.z = atlas.w;
          r15.xz = r15.xz * r13.zz + r18.zw;
          r19.xy = float2(0.0009765625,0.0009765625) * r15.xz;
          r13.z = t9.SampleLevel(s10_s, r19.xyz, 0).x;
          r13.z = r13.w * -0.99000001 + r13.z;
          r13.z = 144.269501 * r13.z;
          r13.z = exp2(r13.z);
          r13.z = min(1, r13.z);
        } else {
          r13.z = 1;
        }
      } else {
        r13.z = 1;
      }
      r15.x = r18.y ? r18.x : 0;
      r15.x = cmp(r15.x != 0.000000);
      if (r15.x != 0) {
        r16.w = cb13[r15.w+0].y;
        r15.x = t10.SampleLevel(s10_s, r16.xyzw, 0).x;
        r13.w = r13.w * -0.99000001 + r15.x;
        r13.w = 144.269501 * r13.w;
        r13.w = exp2(r13.w);
        r13.w = min(1, r13.w);
        r13.z = r13.z * r13.w;
      }
      r13.z = -1 + r13.z;
      r11.w = 60 + r11.w;
      r11.w = (uint)r11.w;
      r11.w = cb13[r11.w+0].w * r13.z + 1;
      r11.w = r14.w * r11.w;
      r13.zw = cmp(float2(0,0) != r17.yz);
      r13.z = (int)r0.x | (int)r13.z;
      r13.z = r13.z ? 1.000000 : 0;
      r13.w = r13.w ? 1 : r7.w;
      r13.z = r13.z * r13.w;
      r11.w = r13.z * r11.w;
      r13.z = cmp(0 < r11.w);
      if (r13.z != 0) {
        r13.z = 0x80000000 & asint(cb13[r15.y+0].w);
        r13.z = (uint)r13.z;
        r13.z = cmp(0 != r13.z);
        r13.z = r13.z ? r0.y : 1;
        r11.w = r13.z * r11.w;
        r12.w = rsqrt(r12.w);
        r15.xzw = r16.xyz * r12.www;
        r12.w = dot(r7.xyz, r15.xzw);
        r12.w = cb4[12].x + r12.w;
        r12.w = saturate(r12.w / r4.w);
        r13.z = dot(r6.xyz, r15.xzw);
        r13.w = r13.z + r12.w;
        r12.w = 1 + r12.w;
        r13.w = saturate(r13.w / r12.w);
        r12.w = 1 / r12.w;
        r16.xyz = r5.xyz * r3.www + r15.xzw;
        r14.w = dot(r16.xyz, r16.xyz);
        r14.w = rsqrt(r14.w);
        r16.xyz = r16.xyz * r14.www;
        r14.w = dot(r16.xyz, r8.xyz);
        r14.w = 1 + -abs(r14.w);
        r14.w = max(0, r14.w);
        r16.x = r14.w * r14.w;
        r16.x = r16.x * r16.x;
        r14.w = r16.x * r14.w;
        r16.xyz = r14.www * r12.xyz;
        r16.xyz = r16.xyz / r13.xxx;
        r16.xyz = r16.xyz + r2.yzw;
        r16.xyz = float3(1,1,1) + -r16.xyz;
        r16.xyz = r16.xyz * r13.www;
        r16.xyz = float3(0.318309873,0.318309873,0.318309873) * r16.xyz;
        r13.z = 1 + r13.z;
        r13.w = dot(r15.xzw, -r8.xyz);
        r13.w = 1 + r13.w;
        r13.zw = float2(0.5,0.5) * r13.zw;
        r13.w = r13.w * r13.w;
        r13.w = r13.w * r13.w + -r13.z;
        r13.z = cb12[36].x * r13.w + r13.z;
        r13.z = r13.z * r5.w;
        r15.xzw = cb12[36].zzz * r9.yzw + -r16.xyz;
        r15.xzw = r6.www * r15.xzw + r16.xyz;
        r15.xzw = r13.zzz * r0.www + r15.xzw;
        r15.xzw = r2.xxx ? r15.xzw : r16.xyz;
        r15.xzw = r15.xzw * r12.www;
        r15.xyz = (cb13[r15.y+0].xyz * PlayerFillScale(asuint(cb13[r15.y+0].w),recipient_fill,cb12[71].x)) * r15.xzw;
        r14.xyz = r11.www * r15.xyz + r14.xyz;
      }
      r10.w = (int)r10.w + 1;
      r8.w = (int)r10.w;
    }
    r0.x = abs(cb2[16].x) + -cb2[16].y;
    r0.xyw = r10.xyz * r0.xxx + cb2[16].yyy;
    r1.w = cb2[16].z + -cb2[16].w;
    r5.xyz = r10.xyz * r1.www + cb2[16].www;
    r0.xyw = r0.xyw * r3.xyz;
    r3.xyz = r5.xyz * r4.xyz;
    r4.xy = -cb12[0].xy + v10.xy;
    r1.w = dot(r4.xy, r4.xy);
    r1.w = sqrt(r1.w);
    r1.w = saturate(r1.w * cb12[218].x + cb12[218].y);
    r2.x = -1 + cb12[184].z;
    r1.w = r1.w * r2.x + 1;
    r2.x = cb12[183].x + -cb12[183].y;
    r4.xyz = r10.xyz * r2.xxx + cb12[183].yyy;
    r4.xyz = r4.xyz * r1.www;
    r2.x = cb12[184].x + -cb12[184].y;
    r5.xyz = r10.xyz * r2.xxx + cb12[184].yyy;
    r5.xyz = r5.xyz * r1.www;
    r10.xyz = cb12[183].zzz * r14.xyz;
    r0.xyw = r4.xyz * r0.xyw;
    r1.w = dot(r6.xyz, r8.xyz);
    r2.x = dot(r7.xyz, r8.xyz);
    r1.w = max(abs(r2.x), abs(r1.w));
    r1.w = 1 + -r1.w;
    r1.w = max(0, r1.w);
    r2.x = r1.w * r1.w;
    r2.x = r2.x * r2.x;
    r1.w = r2.x * r1.w;
    r2.x = min(cb13[56].y, 0.25);
    r4.xyz = r2.xxx * r9.yzw;
    r4.xyz = r4.xyz * r1.www;
    r4.xyz = r4.xyz / r13.yyy;
    r2.xyz = r4.xyz + r2.yzw;
    r4.xyz = float3(1,1,1) + -r2.xyz;
    r0.xyw = r4.xyz * r0.xyw;
    r3.xyz = r5.xyz * r3.xyz;
    r2.xyz = r3.xyz * r2.xyz;
    r1.w = AMBIENT_ONLY_AO ? 1.f : cb12[69].x + cb12[69].y;
    r2.xyz = r2.xyz * r9.xxx;
    r3.xyz = r10.xyz * r1.www;
    r0.xyw = r0.xyw * r9.xxx + r3.xyz;
    r0.xyw = r1.xyz * r0.xyw + r2.xyz;
  } else {
    r0.xyw = float3(0,0,0);
  }
  r1.x = dot(float3(0.333000004,0.555000007,0.222000003), r0.xyw);
  r1.xyz = r1.xxx * v0.xyz + -r0.xyw;
  r0.xyw = v0.www * r1.xyz + r0.xyw;
  r1.xyz = v5.xyz + -r0.xyw;
  r0.xyw = v5.www * r1.xyz + r0.xyw;
  o0.xyz = r0.xyw * r0.zzz;
  o0.w = r0.z;
  return;
}