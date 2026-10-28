#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 20:17:27 2026
Texture2D<float4> t24 : register(t24);

Texture2D<float4> t15 : register(t15);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s15_s : register(s15);

SamplerState s8_s : register(s8);

SamplerState s0_s : register(s0);

cbuffer cb13 : register(b13)
{
  float4 cb13[35];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[20];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[68];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[3];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[10];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float3 v4 : TEXCOORD4,
  float4 v5 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;
  ClassicForwardFog(v5,v0.w,v2);


  r0.xyz = cb4[1].xxx * cb4[0].xyz;
  r1.xy = cb4[3].xy * v1.yz;
  r1.xy = cb0[0].xx * cb4[2].xy + r1.xy;
  r1.xy = t0.Sample(s0_s, r1.xy).xy;
  r1.zw = cb4[5].xy * v1.yz;
  r1.zw = cb0[0].xx * cb4[4].xy + r1.zw;
  r1.zw = t0.Sample(s0_s, r1.zw).xy;
  r1.xy = r1.xy * r1.zw + -cb4[6].xx;
  r1.xy = r1.xy * cb4[7].xx + v1.yz;
  r2.x = 1 / cb4[8].x;
  r2.y = 1 / cb4[9].x;
  r0.w = floor(v1.x);
  r3.x = r0.w * r2.x;
  r0.w = v1.x * r2.x;
  r0.w = floor(r0.w);
  r3.y = r0.w * r2.y;
  r1.zw = r1.xy * r2.xy + r3.xy;
  r3.xyzw = t1.Sample(s0_s, r1.zw).xyzw;
  r0.w = 1 + v1.x;
  r1.z = floor(r0.w);
  r4.x = r1.z * r2.x;
  r0.w = r0.w * r2.x;
  r0.w = floor(r0.w);
  r4.y = r0.w * r2.y;
  r1.xy = r1.xy * r2.xy + r4.xy;
  r1.xyzw = t1.Sample(s0_s, r1.xy).xyzw;
  r0.w = frac(v1.x);
  r1.xyzw = r1.xyzw + -r3.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r3.xyzw;
  r0.w = dot(r1.xyz, float3(0.298999995,0.587000012,0.114));
  r2.xyz = r0.www + -r1.xyz;
  r1.xyz = cb4[10].xxx * r2.xyz + r1.xyz;
  r0.xyz = r1.xyz * r0.xyz;
  r1.xyz = cb0[9].www * r0.xyz;
  r1.xyz = float3(0.300000012,0.300000012,0.300000012) * r1.xyz;
  r0.xyz = r0.xyz * float3(0.699999988,0.699999988,0.699999988) + r1.xyz;
  r0.xyz = log2(r0.xyz);
  r0.xyz = cb4[11].xxx * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r1.xy = cb0[1].zw * v5.xy;
  r0.w = cmp(cb12[67].w >= 0);
  if (r0.w != 0) {
    r2.xy = t24.Sample(s8_s, r1.xy).xy;
    r3.xyz = -cb12[0].xyz + v4.xyz;
    r0.w = dot(r3.xyz, r3.xyz);
    r0.w = sqrt(r0.w);
    r4.x = cb12[1].z;
    r4.y = cb12[2].z;
    r4.z = cb12[3].z;
    r1.z = dot(r4.xyz, r3.xyz);
    r2.z = 1 / cb12[21].y;
    r2.z = r2.z * r0.w;
    r1.z = r2.z / r1.z;
    r1.z = -r1.z + r0.w;
    r1.z = saturate(cb13[33].w * r1.z);
    r1.z = cb13[33].z * r1.z;
    r1.z = max(0.00100000005, r1.z);
    r0.w = r0.w / cb13[34].z;
    r2.z = cmp(r2.x < r2.y);
    if (r2.z != 0) {
      r2.z = cmp(r0.w < r2.x);
      r2.w = cmp(r2.y < r0.w);
      r3.x = cb13[34].z * r2.x + -cb13[34].x;
      r3.x = saturate(-r3.x * cb13[34].y + 1);
      r3.y = r0.w + -r2.x;
      r3.y = cb13[34].z * r3.y;
      r3.y = saturate(r3.y / r1.z);
      r3.y = r3.x * r3.y;
      r2.z = (int)r2.z | (int)r2.w;
      r3.x = 1;
      r2.zw = r2.zz ? float2(0,1) : r3.xy;
    } else {
      r3.x = cmp(r2.y < r2.x);
      r3.y = cmp(r0.w < r2.y);
      r3.z = cmp(r2.x < r0.w);
      r2.x = cb13[34].z * r2.x + -cb13[34].x;
      r4.y = saturate(-r2.x * cb13[34].y + 1);
      r0.w = r0.w + -r2.y;
      r0.w = cb13[34].z * r0.w;
      r0.w = saturate(r0.w / r1.z);
      r4.w = 1 + -r0.w;
      r4.xz = float2(1,1);
      r2.xy = r3.zz ? r4.xy : r4.zw;
      r2.xy = r3.yy ? float2(1,1) : r2.xy;
      r2.zw = r3.xx ? r2.xy : float2(0,1);
    }
    r0.w = -r2.w * r2.z + 1;
  } else {
    r0.w = 0;
  }
  r0.w = r0.w * r1.w + -r1.w;
  r0.w = cb4[16].x * r0.w + r1.w;
  r0.w = log2(r0.w);
  r0.w = cb4[17].x * r0.w;
  r0.w = exp2(r0.w);
  r2.xyz = cb1[8].xyz + -v4.xyz;
  r1.z = dot(r2.xyz, r2.xyz);
  r1.z = sqrt(r1.z);
  r1.w = -cb4[14].x + r1.z;
  r2.x = cb4[15].x + -cb4[14].x;
  r1.w = saturate(r1.w / r2.x);
  r1.z = -cb4[12].x + r1.z;
  r2.x = cb4[13].x + -cb4[12].x;
  r1.z = saturate(r1.z / r2.x);
  r1.x = t15.SampleLevel(s15_s, r1.xy, 0).x;
  r1.x = r1.x * cb12[22].x + cb12[22].y;
  r1.x = r1.x * cb12[21].x + cb12[21].y;
  r1.x = max(9.99999975e-005, r1.x);
  r1.x = 1 / r1.x;
  r0.w = r1.w * r0.w;
  r0.w = r1.z * -r0.w + r0.w;
  r1.x = -v1.w + r1.x;
  r1.x = saturate(cb4[18].x * r1.x);
  r0.w = r1.x * r0.w;
  r1.x = cb4[19].x * v3.w;
  r0.w = saturate(r1.x * r0.w);
  r0.xyz = cb2[2].xyz * r0.xyz;
  r0.w = cb2[2].w * r0.w;
  r1.x = dot(float3(0.333000004,0.555000007,0.222000003), r0.xyz);
  r1.xyz = r1.xxx * v0.xyz + -r0.xyz;
  r0.xyz = v0.www * r1.xyz + r0.xyz;
  r1.xyz = v2.xyz + -r0.xyz;
  r0.xyz = v2.www * r1.xyz + r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r0.w;
  return;
}