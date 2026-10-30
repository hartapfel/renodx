#include "moon.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 29 17:20:46 2026
cbuffer cb12 : register(b12)
{
  float4 cb12[193];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[6];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[4];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float3 v0 : POSITION0,
  float2 v1 : TEXCOORD0,
  float3 v2 : NORMAL0,
  float4 v3 : TANGENT0,
  out float4 o0 : TEXCOORD0,
  out float4 o1 : TEXCOORD1,
  out float4 o2 : TEXCOORD2,
  out float4 o3 : TEXCOORD3,
  out float4 o4 : TEXCOORD4,
  out float3 o5 : TEXCOORD5,
  out float4 o6 : SV_Position0)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v0.xyz * cb2[4].xyz + cb2[5].xyz;
  r0.xyz = ClassicMoonPosition(r0.xyz, cb2[4].xyz, cb2[5].xyz, asuint(cb12[37].w));
  r0.w = 1;
  r1.x = dot(r0.xyzw, cb2[0].xyzw);
  r1.y = dot(r0.xyzw, cb2[1].xyzw);
  r1.z = dot(r0.xyzw, cb2[2].xyzw);
  r2.xyzw = cb2[1].xyzw * cb1[0].yyyy;
  r2.xyzw = cb2[0].xyzw * cb1[0].xxxx + r2.xyzw;
  r2.xyzw = cb2[2].xyzw * cb1[0].zzzz + r2.xyzw;
  r2.xyzw = cb1[0].wwww * float4(0,0,0,1) + r2.xyzw;
  r3.xyzw = cb2[1].xyzw * cb1[1].yyyy;
  r3.xyzw = cb2[0].xyzw * cb1[1].xxxx + r3.xyzw;
  r3.xyzw = cb2[2].xyzw * cb1[1].zzzz + r3.xyzw;
  r3.xyzw = cb1[1].wwww * float4(0,0,0,1) + r3.xyzw;
  r4.xyzw = cb2[1].xyzw * cb1[2].yyyy;
  r4.xyzw = cb2[0].xyzw * cb1[2].xxxx + r4.xyzw;
  r4.xyzw = cb2[2].xyzw * cb1[2].zzzz + r4.xyzw;
  r4.xyzw = cb1[2].wwww * float4(0,0,0,1) + r4.xyzw;
  r5.xyzw = cb2[1].xyzw * cb1[3].yyyy;
  r5.xyzw = cb2[0].xyzw * cb1[3].xxxx + r5.xyzw;
  r5.xyzw = cb2[2].xyzw * cb1[3].zzzz + r5.xyzw;
  r5.xyzw = cb1[3].wwww * float4(0,0,0,1) + r5.xyzw;
  o6.x = dot(r0.xyzw, r2.xyzw);
  o6.y = dot(r0.xyzw, r3.xyzw);
  o6.z = dot(r0.xyzw, r4.xyzw);
  o6.w = dot(r0.xyzw, r5.xyzw);
  r0.xyz = v2.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r2.xyzw = v3.xyzw * float4(2,2,2,2) + float4(-1,-1,-1,-1);
  r3.xyz = r2.yzx * r0.zxy;
  r3.xyz = r0.yzx * r2.zxy + -r3.xyz;
  r3.xyz = r3.xyz * r2.www;
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  r3.xyz = r3.xyz * r0.www;
  r4.x = dot(r0.xyz, cb2[0].xyz);
  r4.y = dot(r0.xyz, cb2[1].xyz);
  r4.z = dot(r0.xyz, cb2[2].xyz);
  r0.x = dot(r4.xyz, r4.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r4.xyz * r0.xxx;
  r4.x = dot(r3.xyz, cb2[0].xyz);
  r4.y = dot(r3.xyz, cb2[1].xyz);
  r4.z = dot(r3.xyz, cb2[2].xyz);
  r0.w = dot(r4.xyz, r4.xyz);
  r0.w = rsqrt(r0.w);
  o3.xyz = r4.xyz * r0.www;
  r3.x = dot(r2.xyz, cb2[0].xyz);
  r3.y = dot(r2.xyz, cb2[1].xyz);
  r3.z = dot(r2.xyz, cb2[2].xyz);
  r0.w = dot(r3.xyz, r3.xyz);
  r0.w = rsqrt(r0.w);
  o5.xyz = r3.xyz * r0.www;
  r2.xyz = -cb12[0].xyz + r1.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = sqrt(r0.w);
  r2.xyz = r2.xyz / r0.www;
  r0.w = -cb12[22].z + r0.w;
  r0.w = max(0, r0.w);
  r0.w = min(cb12[42].z, r0.w);
  r1.w = dot(cb12[38].xyz, r2.xyz);
  r2.x = abs(r1.w) * abs(r1.w);
  r2.y = saturate(r0.w * 0.00200000009 + -0.300000012);
  r2.x = r2.x * r2.y;
  r2.y = cmp(0 < r1.w);
  r3.xyz = r2.yyy ? cb12[39].xyz : cb12[41].xyz;
  r3.xyz = -cb12[40].xyz + r3.xyz;
  r3.xyz = r2.xxx * r3.xyz + cb12[40].xyz;
  r4.xyz = r2.yyy ? cb12[45].xyz : cb12[47].xyz;
  r4.xyz = -cb12[46].xyz + r4.xyz;
  o0.xyz = r2.xxx * r4.xyz + cb12[46].xyz;
  r2.x = cmp(r0.w >= cb12[48].y);
  if (r2.x != 0) {
    r2.x = r2.z * cb12[22].z + cb12[0].z;
    r2.y = r2.z * r0.w;
    r2.z = cb12[43].x * r0.w;
    r2.yz = float2(0.0625,0.0625) * r2.yz;
    r1.w = cb12[42].x + r1.w;
    r2.w = 1 + cb12[42].x;
    r1.w = saturate(r1.w / r2.w);
    r2.w = cb12[43].y + -cb12[43].z;
    r1.w = r1.w * r2.w + cb12[43].z;
    r2.x = cb12[42].y + r2.x;
    r2.yw = r2.yx * r1.ww;
    r4.xyzw = r2.yyyy * float4(16,15,14,13) + r2.wwww;
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.zzzz / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r3.w = r4.x * r4.y;
    r3.w = r3.w * r4.z;
    r3.w = r3.w * r4.w;
    r4.xyzw = r2.yyyy * float4(12,11,10,9) + r2.wwww;
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.zzzz / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r3.w = r4.x * r3.w;
    r3.w = r3.w * r4.y;
    r3.w = r3.w * r4.z;
    r3.w = r3.w * r4.w;
    r4.xyzw = r2.yyyy * float4(8,7,6,5) + r2.wwww;
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.zzzz / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r3.w = r4.x * r3.w;
    r3.w = r3.w * r4.y;
    r3.w = r3.w * r4.z;
    r3.w = r3.w * r4.w;
    r4.xy = r2.yy * float2(4,3) + r2.ww;
    r4.xy = max(float2(0,0), r4.xy);
    r4.xy = float2(1,1) + r4.xy;
    r4.xy = saturate(r2.zz / r4.xy);
    r4.xy = float2(1,1) + -r4.xy;
    r3.w = r4.x * r3.w;
    r3.w = r3.w * r4.y;
    r2.w = r2.y * 2 + r2.w;
    r2.w = max(0, r2.w);
    r2.w = 1 + r2.w;
    r2.w = saturate(r2.z / r2.w);
    r2.w = 1 + -r2.w;
    r2.w = r3.w * r2.w;
    r1.w = r2.x * r1.w + r2.y;
    r1.w = max(0, r1.w);
    r1.w = 1 + r1.w;
    r1.w = saturate(r2.z / r1.w);
    r1.w = 1 + -r1.w;
    r1.w = -r2.w * r1.w + 1;
    r0.w = -cb12[48].y + r0.w;
    r0.w = saturate(cb12[48].z * r0.w);
  } else {
    r1.w = 1;
    r0.w = 0;
  }
  r1.w = log2(r1.w);
  r2.x = cb12[42].w * r1.w;
  r2.x = exp2(r2.x);
  r2.x = r2.x * r0.w;
  r1.w = cb12[48].x * r1.w;
  r1.w = exp2(r1.w);
  o0.w = r1.w * r0.w;
  r2.yz = saturate(r2.xx * cb12[189].xz + cb12[189].yw);
  r4.xyz = cb12[188].xyz + -r3.xyz;
  r4.xyz = r2.yyy * r4.xyz + r3.xyz;
  r0.w = -1 + cb12[188].w;
  r0.w = r2.z * r0.w + 1;
  r4.w = saturate(r2.x * r0.w);
  r0.w = cmp(0 < cb12[192].x);
  if (r0.w != 0) {
    r2.yz = saturate(r2.xx * cb12[191].xz + cb12[191].yw);
    r5.xyz = cb12[190].xyz + -r3.xyz;
    r3.xyz = r2.yyy * r5.xyz + r3.xyz;
    r0.w = -1 + cb12[190].w;
    r0.w = r2.z * r0.w + 1;
    r3.w = saturate(r2.x * r0.w);
    r2.xyzw = r3.xyzw + -r4.xyzw;
    o1.xyzw = cb12[192].xxxx * r2.xyzw + r4.xyzw;
  } else {
    o1.xyzw = r4.xyzw;
  }
  o2.xy = v1.xy;
  o2.zw = r0.xy;
  o3.w = r0.z;
  o4.xyz = r1.xyz;
  return;
}