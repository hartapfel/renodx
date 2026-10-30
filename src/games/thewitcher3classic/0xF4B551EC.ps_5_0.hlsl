#include "./night_sky.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 30 09:01:43 2026
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[17];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[269];
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
  float3 v2 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = -cb12[0].xyz + v2.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = sqrt(r0.w);
  r0.xyz = r0.xyz / r0.www;
  r0.x = dot(cb12[38].xyz, r0.xyz);
  r0.y = abs(r0.x) * abs(r0.x);
  r0.w = saturate(cb12[42].z * 0.00200000009 + -0.300000012);
  r0.y = r0.y * r0.w;
  r0.w = cmp(0 < r0.x);
  r1.xyz = r0.www ? cb12[39].xyz : cb12[41].xyz;
  r1.xyz = -cb12[40].xyz + r1.xyz;
  r1.xyz = r0.yyy * r1.xyz + cb12[40].xyz;
  r0.y = cmp(cb12[42].z >= cb12[48].y);
  if (r0.y != 0) {
    r0.y = r0.z * cb12[22].z + cb12[0].z;
    r0.z = cb12[42].z * r0.z;
    r0.w = cb12[44].x * cb12[42].z;
    r0.zw = float2(0.0625,0.0625) * r0.zw;
    r0.x = cb12[42].x + r0.x;
    r1.w = 1 + cb12[42].x;
    r0.x = saturate(r0.x / r1.w);
    r1.w = cb12[44].y + -cb12[44].z;
    r0.x = r0.x * r1.w + cb12[44].z;
    r0.y = cb12[42].y + r0.y;
    r1.w = r0.y * r0.x;
    r0.z = r0.z * r0.x;
    r2.xyzw = r0.zzzz * float4(16,15,14,13) + r1.wwww;
    r2.xyzw = max(float4(0,0,0,0), r2.xyzw);
    r2.xyzw = float4(1,1,1,1) + r2.xyzw;
    r2.xyzw = saturate(r0.wwww / r2.xyzw);
    r2.xyzw = float4(1,1,1,1) + -r2.xyzw;
    r2.x = r2.x * r2.y;
    r2.x = r2.x * r2.z;
    r2.x = r2.x * r2.w;
    r3.xyzw = r0.zzzz * float4(12,11,10,9) + r1.wwww;
    r3.xyzw = max(float4(0,0,0,0), r3.xyzw);
    r3.xyzw = float4(1,1,1,1) + r3.xyzw;
    r3.xyzw = saturate(r0.wwww / r3.xyzw);
    r3.xyzw = float4(1,1,1,1) + -r3.xyzw;
    r2.x = r3.x * r2.x;
    r2.x = r2.x * r3.y;
    r2.x = r2.x * r3.z;
    r2.x = r2.x * r3.w;
    r3.xyzw = r0.zzzz * float4(8,7,6,5) + r1.wwww;
    r3.xyzw = max(float4(0,0,0,0), r3.xyzw);
    r3.xyzw = float4(1,1,1,1) + r3.xyzw;
    r3.xyzw = saturate(r0.wwww / r3.xyzw);
    r3.xyzw = float4(1,1,1,1) + -r3.xyzw;
    r2.x = r3.x * r2.x;
    r2.x = r2.x * r3.y;
    r2.x = r2.x * r3.z;
    r2.x = r2.x * r3.w;
    r2.yz = r0.zz * float2(4,3) + r1.ww;
    r2.yz = max(float2(0,0), r2.yz);
    r2.yz = float2(1,1) + r2.yz;
    r2.yz = saturate(r0.ww / r2.yz);
    r2.yz = float2(1,1) + -r2.yz;
    r2.x = r2.x * r2.y;
    r2.x = r2.x * r2.z;
    r1.w = r0.z * 2 + r1.w;
    r1.w = max(0, r1.w);
    r1.w = 1 + r1.w;
    r1.w = saturate(r0.w / r1.w);
    r1.w = 1 + -r1.w;
    r1.w = r2.x * r1.w;
    r0.x = r0.y * r0.x + r0.z;
    r0.x = max(0, r0.x);
    r0.x = 1 + r0.x;
    r0.x = saturate(r0.w / r0.x);
    r0.x = 1 + -r0.x;
    r0.x = -r1.w * r0.x + 1;
    r0.y = -cb12[48].y + cb12[42].z;
    r0.y = saturate(cb12[48].z * r0.y);
  } else {
    r0.xy = float2(1,0);
  }
  r0.x = log2(r0.x);
  r0.x = cb12[42].w * r0.x;
  r0.x = exp2(r0.x);
  r0.x = r0.y * r0.x;
  r0.yz = saturate(r0.xx * cb12[189].xz + cb12[189].yw);
  r2.xyz = cb12[188].xyz + -r1.xyz;
  r2.xyz = r0.yyy * r2.xyz + r1.xyz;
  r0.y = -1 + cb12[188].w;
  r0.y = r0.z * r0.y + 1;
  r2.w = saturate(r0.x * r0.y);
  r0.y = cmp(0 < cb12[192].x);
  if (r0.y != 0) {
    r0.yz = saturate(r0.xx * cb12[191].xz + cb12[191].yw);
    r3.xyz = cb12[190].xyz + -r1.xyz;
    r1.xyz = r0.yyy * r3.xyz + r1.xyz;
    r0.y = -1 + cb12[190].w;
    r0.y = r0.z * r0.y + 1;
    r1.w = saturate(r0.x * r0.y);
    r0.xyzw = r1.xyzw + -r2.xyzw;
    r2.xyzw = cb12[192].xxxx * r0.xyzw + r2.xyzw;
  }
  r0.xy = cb4[0].xy * v0.yz;
  r1.x = 1 / cb4[1].x;
  r1.y = 1 / cb4[2].x;
  r0.z = floor(v0.x);
  r3.x = r0.z * r1.x;
  r0.z = v0.x * r1.x;
  r0.z = floor(r0.z);
  r3.y = r0.z * r1.y;
  r0.xy = r0.xy * r1.xy + r3.xy;
  r0.xy = t0.Sample(s0_s, r0.xy).xy;
  r0.z = cb4[3].x * r0.x;
  r0.w = saturate(v0.z);
  r1.x = cmp(r0.w >= 0.00158399995);
  r1.yz = cmp(float2(0.985903025,0.00158399995) >= r0.ww);
  r1.x = r1.y ? r1.x : 0;
  r0.w = -0.00158399995 + r0.w;
  r3.x = 1.01593077 * r0.w;
  r0.w = r0.w * -1.01593077 + 1;
  r4.x = r1.z ? 1.000000 : 0;
  r1.y = (int)r1.x | (int)r1.z;
  r1.z = r1.y ? 1.000000 : 0;
  r3.z = 0;
  r4.y = 0.5;
  r3.xy = r1.xx ? r3.zx : r4.xy;
  r1.y = r1.y ? -1 : -0;
  r1.y = r3.x + r1.y;
  r1.y = r3.y * r1.y + r1.z;
  r0.w = r1.x ? r0.w : r1.y;
  r0.w = -1 + r0.w;
  r1.x = cb4[4].x * r0.w + 1;
  r0.z = r1.x * r0.z;
  r1.xyz = cb1[8].xyz + -v2.xyz;
  r1.w = dot(r1.xyz, r1.xyz);
  r3.x = sqrt(r1.w);
  r3.x = -1000 + r3.x;
  r3.x = saturate(0.000142857141 * r3.x);
  r3.y = cb4[8].x + -cb4[7].x;
  r3.x = r3.x * r3.y + cb4[7].x;
  r3.xyz = cb12[268].xyz * r3.xxx;
  r3.w = 1 + -r0.y;
  r4.x = -r3.w + r0.x;
  r3.w = cb4[6].x * r4.x + r3.w;
  r3.xyz = r3.www * r3.xyz;
  r3.xyz = cb4[5].xxx * r0.xxx + r3.xyz;
  r0.x = cb4[9].x * r0.w + 1;
  r0.w = dot(-cb0[9].xyz, -cb0[9].xyz);
  r0.w = rsqrt(r0.w);
  r4.xyz = -cb0[9].xyz * r0.www;
  r0.w = rsqrt(r1.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = saturate(dot(r4.xyz, r1.xyz));
  r1.xyz = r3.xyz * r0.xxx + -r0.zzz;
  r1.xyz = r0.www * r1.xyz + r0.zzz;
  r3.xyz = cb12[233].xyz * r1.xyz;
  r4.xyz = -cb12[235].xyz + cb12[234].xyz;
  r4.xyz = r0.www * r4.xyz + cb12[235].xyz;
  r1.xyz = r4.xyz * r1.xyz + -r3.xyz;
  r1.xyz = cb4[10].xxx * r1.xyz + r3.xyz;
  r0.xz = cb4[13].xy * cb0[0].xx;
  r0.xz = v0.yz * cb4[12].xy + r0.xz;
  r0.x = t1.Sample(s0_s, r0.xz).x;
  r0.z = r0.x * cb4[14].x + -cb4[14].x;
  r1.w = cb4[15].x * v1.w;
  r0.z = saturate(cb4[14].x * r1.w + r0.z);
  r0.w = r0.w * 11 + -10;
  r0.w = max(0, r0.w);
  r0.x = -1 + r0.x;
  r0.x = r0.w * r0.x + 1;
  r0.x = r0.x * r0.z + -r0.z;
  r0.x = cb4[16].x * r0.x + r0.z;
  r0.x = r0.y * r0.x;
  r0.x = saturate(cb4[11].x * r0.x);
  r0.yzw = log2(r1.xyz);
  r0.yzw = float3(2.20000005,2.20000005,2.20000005) * r0.yzw;
  r0.yzw = exp2(r0.yzw);
  r0.yzw *= ClassicCloudBrightness(asuint(cb12[184].w));
  r1.xyz = r2.xyz + -r0.yzw;
  r0.yzw = r2.www * r1.xyz + r0.yzw;
  o0.xyz = r0.yzw * r0.xxx;
  o0.w = r0.x;
  return;
}