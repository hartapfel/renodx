#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 18:39:41 2026
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
  float4 cb4[21];
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
  float4 cb0[8];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  float4 v6 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  ClassicForwardFog(v6, v0.w, v2);


  r0.xyz = cb4[1].xxx * cb4[0].xyz;
  r1.xy = cb4[4].xy * v1.yz;
  r1.xy = cb0[0].xx * cb4[3].xy + r1.xy;
  r1.xy = t0.Sample(s0_s, r1.xy).xy;
  r1.zw = cb4[6].xy * v1.yz;
  r1.zw = cb0[0].xx * cb4[5].xy + r1.zw;
  r1.zw = t0.Sample(s0_s, r1.zw).xy;
  r1.xy = r1.xy * r1.zw + -cb4[7].xx;
  r1.xy = r1.xy * cb4[8].xx + v1.yz;
  r2.x = 1 / cb4[9].x;
  r2.y = 1 / cb4[10].x;
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
  r2.xyz = max(cb4[2].xxx, v3.xyz);
  r0.w = frac(v1.x);
  r1.xyzw = r1.xyzw + -r3.xyzw;
  r1.xyzw = r0.wwww * r1.xyzw + r3.xyzw;
  r3.xyz = r2.xyz * r1.xyz;
  r0.w = dot(r3.xyz, float3(0.298999995,0.587000012,0.114));
  r1.xyz = -r2.xyz * r1.xyz + r0.www;
  r1.xyz = cb4[11].xxx * r1.xyz + r3.xyz;
  r1.xyz = v4.xyz * r1.xyz;
  r0.xyz = r1.xyz * r0.xyz;
  r1.xyz = cb1[8].xyz + -v5.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = sqrt(r0.w);
  r1.x = -cb4[14].x + r0.w;
  r1.y = cb4[15].x + -cb4[14].x;
  r1.x = saturate(r1.x / r1.y);
  r0.w = -cb4[12].x + r0.w;
  r1.y = cb4[13].x + -cb4[12].x;
  r0.w = saturate(r0.w / r1.y);
  r1.yz = cb0[1].zw * v6.xy;
  r2.x = t15.SampleLevel(s15_s, r1.yz, 0).x;
  r2.x = r2.x * cb12[22].x + cb12[22].y;
  r2.x = r2.x * cb12[21].x + cb12[21].y;
  r2.x = max(9.99999975e-005, r2.x);
  r2.x = 1 / r2.x;
  r1.x = r1.x * r1.w;
  r0.w = r0.w * -r1.x + r1.x;
  r1.x = -v1.w + r2.x;
  r1.x = saturate(cb4[16].x * r1.x);
  r0.w = r1.x * r0.w;
  r1.x = cb4[17].x * v4.w;
  r0.w = r1.x * r0.w;
  r1.x = cmp(cb12[67].w >= 0);
  if (r1.x != 0) {
    r1.xy = t24.Sample(s8_s, r1.yz).xy;
    r2.xyz = -cb12[0].xyz + v5.xyz;
    r1.z = dot(r2.xyz, r2.xyz);
    r1.z = sqrt(r1.z);
    r3.x = cb12[1].z;
    r3.y = cb12[2].z;
    r3.z = cb12[3].z;
    r1.w = dot(r3.xyz, r2.xyz);
    r2.x = 1 / cb12[21].y;
    r2.x = r2.x * r1.z;
    r1.w = r2.x / r1.w;
    r1.w = r1.z + -r1.w;
    r1.w = saturate(cb13[33].w * r1.w);
    r1.w = cb13[33].z * r1.w;
    r1.w = max(0.00100000005, r1.w);
    r1.z = r1.z / cb13[34].z;
    r2.x = cmp(r1.x < r1.y);
    if (r2.x != 0) {
      r2.xy = cmp(r1.zy < r1.xz);
      r2.z = cb13[34].z * r1.x + -cb13[34].x;
      r2.z = saturate(-r2.z * cb13[34].y + 1);
      r2.w = r1.z + -r1.x;
      r2.w = cb13[34].z * r2.w;
      r2.w = saturate(r2.w / r1.w);
      r3.y = r2.z * r2.w;
      r2.x = (int)r2.x | (int)r2.y;
      r3.x = 1;
      r2.xy = r2.xx ? float2(0,1) : r3.xy;
    } else {
      r2.zw = cmp(r1.yz < r1.xy);
      r3.x = cmp(r1.x < r1.z);
      r1.x = cb13[34].z * r1.x + -cb13[34].x;
      r4.y = saturate(-r1.x * cb13[34].y + 1);
      r1.x = r1.z + -r1.y;
      r1.x = cb13[34].z * r1.x;
      r1.x = saturate(r1.x / r1.w);
      r4.w = 1 + -r1.x;
      r4.xz = float2(1,1);
      r1.xy = r3.xx ? r4.xy : r4.zw;
      r1.xy = r2.ww ? float2(1,1) : r1.xy;
      r2.xy = r2.zz ? r1.xy : float2(0,1);
    }
    r1.x = -r2.y * r2.x + 1;
  } else {
    r1.x = 0;
  }
  r1.x = r1.x * r0.w + -r0.w;
  r0.w = cb4[18].x * r1.x + r0.w;
  r1.x = cb4[20].x + -cb4[19].x;
  r1.x = cb0[7].y * r1.x + cb4[19].x;
  r0.w = r1.x * r0.w;
  r0.xyzw = cb2[2].xyzw * r0.xyzw;
  r1.x = dot(float3(0.333000004,0.555000007,0.222000003), r0.xyz);
  r1.xyz = r1.xxx * v0.xyz + -r0.xyz;
  r0.xyz = v0.www * r1.xyz + r0.xyz;
  r1.xyz = v2.xyz + -r0.xyz;
  r0.xyz = v2.www * r1.xyz + r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r0.w;
  return;
}