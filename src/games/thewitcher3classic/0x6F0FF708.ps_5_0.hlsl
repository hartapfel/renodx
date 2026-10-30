#include "night_sky.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 29 18:25:05 2026
Texture2D<float4> t15 : register(t15);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s15_s : register(s15);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[28];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[268];
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
  float3 v3 : TEXCOORD3,
  float4 v4 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = float2(1,1) / cb4[7].xx;
  r0.x = v0.x * r0.x;
  r0.x = floor(r0.x);
  r0.z = 1 / cb4[8].x;
  r1.y = r0.x * r0.z;
  r0.x = floor(v0.x);
  r1.x = r0.x * r0.y;
  r0.xy = v0.yz * r0.yz + r1.xy;
  r0.zw = t0.Sample(s0_s, r0.xy).xy;
  r1.xy = r0.zw * float2(2,2) + float2(-1,-1);
  r0.z = -r1.x * r1.x + 1;
  r0.z = -r1.y * r1.y + r0.z;
  r0.z = max(0, r0.z);
  r1.z = sqrt(r0.z);
  r1.xyz = cb4[9].xyz * r1.xyz;
  r0.z = dot(r1.xyz, r1.xyz);
  r0.z = rsqrt(r0.z);
  r1.xyz = r1.xyz * r0.zzz;
  r0.zw = float2(1,-1) * cb0[9].yx;
  r1.w = dot(r0.zw, r0.zw);
  r1.w = rsqrt(r1.w);
  r0.zw = r1.ww * r0.zw;
  r2.xyz = cb1[8].xyz + -v3.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r2.z = rsqrt(r1.w);
  r1.w = sqrt(r1.w);
  r2.xy = r2.xy * r2.zz;
  r0.z = saturate(dot(r0.zw, r2.xy));
  r0.z = rsqrt(r0.z);
  r0.z = 1 / r0.z;
  r0.z = min(1, r0.z);
  r3.xyz = cb4[4].xyz + -cb4[3].xyz;
  r3.xyz = r0.zzz * r3.xyz + cb4[3].xyz;
  r4.xyz = cb4[5].xyz + -r3.xyz;
  r0.z = dot(-cb0[9].xy, -cb0[9].xy);
  r0.z = rsqrt(r0.z);
  r0.zw = -cb0[9].xy * r0.zz;
  r0.z = saturate(dot(r0.zw, r2.xy));
  r0.w = r0.z * r0.z;
  r0.w = r0.w * r0.w;
  r0.z = r0.z * r0.w;
  r3.xyz = r0.zzz * r4.xyz + r3.xyz;
  r4.xyz = cb4[6].xyz + -r3.xyz;
  r0.w = dot(cb0[9].xy, cb0[9].xy);
  r0.w = rsqrt(r0.w);
  r2.zw = cb0[9].xy * r0.ww;
  r0.w = saturate(dot(r2.zw, r2.xy));
  r2.xyz = r0.www * r4.xyz + r3.xyz;
  r2.w = dot(r2.xyz, r2.xyz);
  r2.w = rsqrt(r2.w);
  r2.xyz = r2.xyz * r2.www;
  r1.x = dot(r2.xyz, r1.xyz);
  r1.x = cb4[10].x + r1.x;
  r1.x = saturate(cb4[11].x * r1.x);
  r1.y = cb4[16].x + -cb4[15].x;
  r1.z = saturate(cb0[9].z * 4 + -1);
  r1.y = r1.z * r1.y + cb4[15].x;
  r2.x = cb4[14].x + -cb4[13].x;
  r2.x = r1.z * r2.x + cb4[13].x;
  r1.y = -r2.x * r1.x + r1.y;
  r2.x = r2.x * r1.x;
  r1.y = r0.w * r1.y + r2.x;
  r2.xy = t1.Sample(s0_s, r0.xy).xy;
  r0.x = t2.Sample(s0_s, r0.xy).x;
  r0.y = r2.x * r1.y;
  r1.y = log2(r2.y);
  r0.y = max(0, r0.y);
  r0.y = min(100, r0.y);
  r2.x = cb4[18].x + -cb4[17].x;
  r2.x = r1.z * r2.x + cb4[17].x;
  r1.y = r2.x * r1.y;
  r1.y = exp2(r1.y);
  r2.x = cb4[20].x + -cb4[19].x;
  r1.z = r1.z * r2.x + cb4[19].x;
  r1.y = r1.y * r1.z;
  r0.y = r1.y * r0.z + r0.y;
  r2.xyz = -cb12[266].xyz + cb12[233].xyz;
  r1.xyz = r1.xxx * r2.xyz + cb12[266].xyz;
  r2.x = dot(r1.xyz, float3(0.298999995,0.587000012,0.114));
  r2.xyz = r2.xxx + -r1.xyz;
  r1.xyz = cb4[12].xxx * r2.xyz + r1.xyz;
  r2.x = 0.00066666666 * r1.w;
  r2.x = min(1, r2.x);
  r2.yzw = float3(-1,-1,-1) + cb12[267].xyz;
  r2.xyz = r2.xxx * r2.yzw + float3(1,1,1);
  r2.xyz = r2.xyz * r1.xyz + -r1.xyz;
  r1.xyz = r0.www * r2.xyz + r1.xyz;
  r1.xyz = r1.xyz * r0.yyy;
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(2.20000005,2.20000005,2.20000005) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r1.xyz *= ClassicCloudBrightness(asuint(cb12[184].w));
  r2.xyz = -cb4[2].xyz * r1.xyz + v1.xyz;
  r1.xyz = cb4[2].xyz * r1.xyz;
  r2.xyz = v1.www * r2.xyz;
  r0.y = -cb4[0].x + r1.w;
  r0.w = cb4[1].x + -cb4[0].x;
  r0.y = saturate(r0.y / r0.w);
  r1.xyz = r0.yyy * r2.xyz + r1.xyz;
  r0.y = -cb4[26].x + r1.w;
  r0.w = -cb4[24].x + r1.w;
  r1.w = cb4[27].x + -cb4[26].x;
  r0.y = saturate(r0.y / r1.w);
  r1.w = cb4[25].x + -cb4[24].x;
  r0.w = saturate(r0.w / r1.w);
  r0.y = r0.w * -r0.y + r0.y;
  r2.xy = cb0[1].zw * v4.xy;
  r0.w = t15.SampleLevel(s15_s, r2.xy, 0).x;
  r0.w = r0.w * cb12[22].x + cb12[22].y;
  r0.w = r0.w * cb12[21].x + cb12[21].y;
  r0.w = max(9.99999975e-005, r0.w);
  r0.w = 1 / r0.w;
  r0.w = -v0.w + r0.w;
  r0.w = saturate(cb4[23].x * r0.w);
  r0.y = r0.w * r0.y;
  r0.y = v2.w * r0.y;
  r0.w = r0.z * -0.600000024 + 1;
  r0.y = r0.w * r0.y;
  r0.w = t3.Sample(s0_s, v0.yz).x;
  r0.w = r0.w * 3 + -2.5;
  r0.y = saturate(r0.y * 3 + r0.w);
  r0.x = saturate(r0.x * r0.y);
  r0.y = cb4[22].x + -cb4[21].x;
  r0.y = r0.z * r0.y + cb4[21].x;
  r0.x = saturate(r0.y * r0.x);
  o0.xyz = r1.xyz * r0.xxx;
  o0.w = r0.x;
  return;
}