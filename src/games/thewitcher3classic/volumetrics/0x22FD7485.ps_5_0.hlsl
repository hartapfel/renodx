#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 18:21:58 2026
Texture2DArray<float4> t14 : register(t14);

SamplerState s0_s : register(s0);

cbuffer cb7 : register(b7)
{
  float4 cb7[3];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[193];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb6 : register(b6)
{
  float4 cb6[44];
}

cbuffer cb5 : register(b5)
{
  float4 cb5[2];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[69];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float3 v1 : TEXCOORD1,
  float4 fog_position : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = cb1[8].xyz + -v1.xyz;
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = rsqrt(r0.x);
  r0.x = r0.z * r0.x + 1.03999996;
  r0.y = r0.x * r0.x;
  r0.x = r0.x * r0.y;
  r0.y = r0.y * r0.y;
  r0.x = -r0.x * r0.y + 1;
  r0.x = log2(r0.x);
  r0.x = 2.20000005 * r0.x;
  r0.x = exp2(r0.x);
  r0.y = cb6[42].w ? cb6[43].x : cb7[0].x;
  r1.x = -cb7[0].w;
  r1.y = -cb7[1].w;
  r1.z = -cb7[2].w;
  r1.xyz = cb3[0].xyz + r1.xyz;
  r0.z = dot(r1.xyz, r1.xyz);
  r0.y = -r0.y * r0.y + r0.z;
  r0.yw = sqrt(r0.yz);
  r0.y = r0.y / r0.w;
  r0.y = 1 + -r0.y;
  r0.y = 6.28318548 * r0.y;
  r0.yzw = cb5[1].xyz / r0.yyy;
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = -cb12[0].xyz + v1.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = sqrt(r0.w);
  r1.w = -cb12[22].z + r0.w;
  r1.w = max(0, r1.w);
  r1.w = min(cb12[42].z, r1.w);
  r2.x = cmp(r1.w >= cb12[48].y);
  if (r2.x != 0) {
    r1.xyz = r1.xyz / r0.www;
    r0.w = r1.z * cb12[22].z + cb12[0].z;
    r2.x = r1.z * r1.w;
    r2.y = cb12[43].x * r1.w;
    r2.xy = float2(0.0625,0.0625) * r2.xy;
    r1.x = dot(cb12[38].xyz, r1.xyz);
    r1.x = cb12[42].x + r1.x;
    r1.y = 1 + cb12[42].x;
    r1.x = saturate(r1.x / r1.y);
    r1.y = cb12[43].y + -cb12[43].z;
    r1.x = r1.x * r1.y + cb12[43].z;
    r0.w = cb12[42].y + r0.w;
    r1.y = r0.w * r1.x;
    r1.z = r2.x * r1.x;
    r3.xyzw = r1.zzzz * float4(16,15,14,13) + r1.yyyy;
    r3.xyzw = max(float4(0,0,0,0), r3.xyzw);
    r3.xyzw = float4(1,1,1,1) + r3.xyzw;
    r3.xyzw = saturate(r2.yyyy / r3.xyzw);
    r3.xyzw = float4(1,1,1,1) + -r3.xyzw;
    r2.x = r3.x * r3.y;
    r2.x = r2.x * r3.z;
    r2.x = r2.x * r3.w;
    r3.xyzw = r1.zzzz * float4(12,11,10,9) + r1.yyyy;
    r3.xyzw = max(float4(0,0,0,0), r3.xyzw);
    r3.xyzw = float4(1,1,1,1) + r3.xyzw;
    r3.xyzw = saturate(r2.yyyy / r3.xyzw);
    r3.xyzw = float4(1,1,1,1) + -r3.xyzw;
    r2.x = r3.x * r2.x;
    r2.x = r2.x * r3.y;
    r2.x = r2.x * r3.z;
    r2.x = r2.x * r3.w;
    r3.xyzw = r1.zzzz * float4(8,7,6,5) + r1.yyyy;
    r3.xyzw = max(float4(0,0,0,0), r3.xyzw);
    r3.xyzw = float4(1,1,1,1) + r3.xyzw;
    r3.xyzw = saturate(r2.yyyy / r3.xyzw);
    r3.xyzw = float4(1,1,1,1) + -r3.xyzw;
    r2.x = r3.x * r2.x;
    r2.x = r2.x * r3.y;
    r2.x = r2.x * r3.z;
    r2.x = r2.x * r3.w;
    r2.zw = r1.zz * float2(4,3) + r1.yy;
    r2.zw = max(float2(0,0), r2.zw);
    r2.zw = float2(1,1) + r2.zw;
    r2.zw = saturate(r2.yy / r2.zw);
    r2.zw = float2(1,1) + -r2.zw;
    r2.x = r2.x * r2.z;
    r2.x = r2.x * r2.w;
    r1.y = r1.z * 2 + r1.y;
    r1.y = max(0, r1.y);
    r1.y = 1 + r1.y;
    r1.y = saturate(r2.y / r1.y);
    r1.y = 1 + -r1.y;
    r1.y = r2.x * r1.y;
    r0.w = r0.w * r1.x + r1.z;
    r0.w = max(0, r0.w);
    r0.w = 1 + r0.w;
    r0.w = saturate(r2.y / r0.w);
    r0.w = 1 + -r0.w;
    r0.w = -r1.y * r0.w + 1;
    r1.x = -cb12[48].y + r1.w;
    r1.x = saturate(cb12[48].z * r1.x);
  } else {
    r0.w = 1;
    r1.x = 0;
  }
  r0.w = log2(r0.w);
  r0.w = cb12[42].w * r0.w;
  r0.w = exp2(r0.w);
  r0.w = r1.x * r0.w;
  r1.x = saturate(r0.w * cb12[189].z + cb12[189].w);
  r1.y = -1 + cb12[188].w;
  r1.x = r1.x * r1.y + 1;
  r1.x = saturate(r1.x * r0.w);
  r1.y = cmp(0 < cb12[192].x);
  r1.z = saturate(r0.w * cb12[191].z + cb12[191].w);
  r1.w = -1 + cb12[190].w;
  r1.z = r1.z * r1.w + 1;
  r0.w = saturate(r1.z * r0.w);
  r0.w = r0.w + -r1.x;
  r0.w = cb12[192].x * r0.w + r1.x;
  r0.w = r1.y ? r0.w : r1.x;
  r0.w = 1 + -r0.w;
  if (ClassicFogReady()) r0.w = SampleClassicFogPixel(fog_position).a;
  r0.xyz = r0.xyz * r0.www;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.w = 20 * cb3[66].x;
  r1.zw = trunc(cb3[68].xy);
  r2.xyz = -cb3[0].xyz + v1.xyz;
  r2.x = dot(r2.xyz, r2.xyz);
  r2.x = sqrt(r2.x);
  r3.xy = cb3[67].xy;
  r3.z = 0;
  r2.yzw = v1.xyz + r3.xyz;
  r2.yzw = float3(0.00999999978,0.00999999978,0.00999999978) * r2.yzw;
  r2.yzw = r2.yzw / cb3[66].xxx;
  r3.xy = float2(20,20) * cb3[67].xy;
  r3.z = 0;
  r3.xyz = v1.xyz + r3.xyz;
  r3.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r3.xyz;
  r3.xyz = r3.xyz / r0.www;
  r4.xy = cb5[0].xy * r2.ww;
  r4.xy = r4.xy / cb5[0].zz;
  r1.xy = -r4.xy + r2.yz;
  r2.yz = cb5[0].xy * r3.zz;
  r2.yz = r2.yz / cb5[0].zz;
  r3.xy = r3.xy + -r2.yz;
  r0.w = t14.SampleLevel(s0_s, r1.xyz, 1).x;
  r1.x = t14.SampleLevel(s0_s, r1.xyw, 1).x;
  r1.x = r1.x + -r0.w;
  r0.w = cb3[66].w * r1.x + r0.w;
  r3.zw = r1.zw;
  r1.x = t14.SampleLevel(s0_s, r3.xyz, 1).x;
  r1.y = t14.SampleLevel(s0_s, r3.xyw, 1).x;
  r1.y = r1.y + -r1.x;
  r1.x = cb3[66].w * r1.y + r1.x;
  r1.y = -0.25 + cb5[0].z;
  r1.z = -100 + r2.x;
  r1.yz = saturate(float2(10,0.00666666683) * r1.yz);
  r1.x = r1.x + -r0.w;
  r0.w = r1.z * r1.x + r0.w;
  r0.w = -r1.y * r0.w + 1;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  return;
}