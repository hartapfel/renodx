// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 23:13:49 2026
Texture2D<uint4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

cbuffer cb13 : register(b13)
{
  float4 cb13[2362];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[214];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[1];
}




// 3Dmigoto declarations
#include "brdf.hlsli"
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  float recipient_fill = 1.f;
  r0.xy = (int2)v0.xy;
  r0.zw = float2(0,0);
  r1.x = t0.Load(r0.xyw).x;
  r1.yz = trunc(v0.xy);
  r2.xyzw = cb12[211].xyzw * r1.zzzz;
  r2.xyzw = cb12[210].xyzw * r1.yyyy + r2.xyzw;
  r1.xyzw = cb12[212].xyzw * r1.xxxx + r2.xyzw;
  r1.xyzw = cb12[213].xyzw + r1.xyzw;
  r1.xyz = r1.xyz / r1.www;
  r1.w = (int)cb3[0].x;
  r1.w = (int)r1.w * 9;
  r2.xyz = cb13[r1.w+58].xyz + -r1.xyz;
  r2.w = dot(r2.xyz, r2.xyz);
  r3.x = sqrt(r2.w);
  r3.y = cmp(r3.x < cb13[r1.w+58].w);
  if (r3.y != 0) {
    r3.yz = t4.Load(r0.xyw).xz;
    r4.xyzw = t1.Load(r0.xyw).xyzw;
    r5.xyzw = t2.Load(r0.xyw).xyzw;
    if (CUSTOM_BRDF) r5.w=FilterDirectRoughness(int2(r0.xy),r5);
    r6.xyz = t3.Load(r0.xyw).xyz;
    r3.w = r3.x / cb13[r1.w+58].w;
    r3.w = r3.w * r3.w;
    r3.w = -r3.w * r3.w + 1;
    r3.w = max(0, r3.w);
    r3.w = r3.w * r3.w;
    r6.w = r2.w * cb13[r1.w+63].x + 1;
    r3.w = r3.w / r6.w;
    r2.w = rsqrt(r2.w);
    r7.xyz = r2.xyz * r2.www;
    r2.w = dot(-r7.xyz, cb13[r1.w+60].xyz);
    r2.w = saturate(r2.w * cb13[r1.w+62].y + cb13[r1.w+62].z);
    r2.w = log2(r2.w);
    r2.w = cb13[r1.w+62].w * r2.w;
    r2.w = exp2(r2.w);
    r2.w = r3.w * r2.w;
    r7.xy = int2(2048,4096) & asint(cb13[r1.w+61].ww);
    r3.z = cmp(r3.z == 1.000000);
    r3.w = r3.z ? 1.000000 : 0;
    r3.z = r3.z ? 0 : 1;
    r3.zw = r7.yx ? float2(1,1) : r3.zw;
    r3.z = r3.w * r3.z;
    r2.w = r3.z * r2.w;
    r3.z = cmp(0 < r2.w);
    if (r3.z != 0) {
      r0.x = t5.Load(r0.xyz).y;
      r0.x = (int)r0.x & 2;
      r0.x = r0.x ? 1 : cb12[71].x;
      recipient_fill = r0.x;
      r0.y = 0x80000000 & asint(cb13[r1.w+61].w);
      r0.x = r0.y ? r0.x : 1;
      r0.x = r2.w * r0.x;
      r0.yzw = log2(r4.xyz);
      r0.yzw = float3(2.20000005,2.20000005,2.20000005) * r0.yzw;
      r0.yzw = exp2(r0.yzw);
      r4.xyz = log2(r6.xyz);
      r4.xyz = float3(2.20000005,2.20000005,2.20000005) * r4.xyz;
      r4.xyz = exp2(r4.xyz);
      r5.xyz = float3(-0.5,-0.5,-0.5) + r5.xyz;
      r2.w = dot(r5.xyz, r5.xyz);
      r2.w = rsqrt(r2.w);
      r5.xyz = r5.xyz * r2.www;
      r2.xyz = r2.xyz / r3.xxx;
      r1.xyz = cb12[0].xyz + -r1.xyz;
      r2.w = dot(r1.xyz, r1.xyz);
      r2.w = rsqrt(r2.w);
      r3.xzw = r2.www * r1.xyz;
      r6.xy = cb12[183].zw * r0.xx;
      r0.x = dot(r5.xyz, r2.xyz);
      r6.z = saturate(r0.x);
      r1.xyz = r1.xyz * r2.www + r2.xyz;
      r2.w = dot(r1.xyz, r1.xyz);
      r2.w = rsqrt(r2.w);
      r1.xyz = r2.www * r1.xyz;
      r2.w = dot(r1.xyz, r3.xzw);
      r2.w = 1 + -abs(r2.w);
      r2.w = max(0, r2.w);
      r6.w = r2.w * r2.w;
      r6.w = r6.w * r6.w;
      r2.w = r6.w * r2.w;
      float3 direct_fresnel = DirectFresnel(r4.xyz, r2.w);
      r6.w = 1 + -r5.w;
      r7.xyz = float3(1,1,1) + -r4.xyz;
      r8.xyz = max(float3(0,0,0), r7.xyz);
      r8.xyz = cb13[56].xxx * r8.xyz;
      r8.xyz = r8.xyz * r2.www;
      r2.w = 1 + cb13[56].z;
      r2.w = -cb13[56].z * r6.w + r2.w;
      r8.xyz = r8.xyz / r2.www;
      r4.xyz = CUSTOM_BRDF ? direct_fresnel : r8.xyz + r4.xyz;
      r8.xyz = float3(1,1,1) + -r4.xyz;
      r8.xyz = r8.xyz * r6.zzz;
      r8.xyz = float3(0.318309873,0.318309873,0.318309873) * r8.xyz;
      if (CUSTOM_BRDF) r8.xyz *= DirectDiffuseFactor(dot(r5.xyz,r3.xzw),r6.z,dot(r1.xyz,r3.xzw),r5.w);
      r2.w = cmp(0 < r4.w);
      if (r2.w != 0) {
        r2.w = 1 + r0.x;
        r2.x = dot(r2.xyz, -r3.xzw);
        r2.x = 1 + r2.x;
        r2.xw = float2(0.5,0.5) * r2.xw;
        r2.y = dot(r5.xyz, -r3.xzw);
        r2.y = 1 + r2.y;
        r2.y = cb12[36].w * r2.y;
        r2.x = r2.x * r2.x;
        r2.y = 0.5 * r2.y;
        r2.x = r2.x * r2.x + -r2.w;
        r2.x = cb12[36].x * r2.x + r2.w;
        r2.x = r2.y * r2.x;
        r2.y = cb12[36].y * r4.w;
        r7.xyz = cb12[36].zzz * r7.xyz + -r8.xyz;
        r2.yzw = r2.yyy * r7.xyz + r8.xyz;
        r8.xyz = r2.xxx * r4.www + r2.yzw;
      }
      r2.xyz = (cb13[r1.w+61].xyz * PlayerFillScale(asuint(cb13[r1.w+61].w), recipient_fill, cb12[71].x)) * r8.xyz;
      r2.xyz = r6.xxx * r2.xyz;
      r0.x = cmp(0 < r0.x);
      if (r0.x != 0) {
        if (CUSTOM_BRDF) {
          r1.xyz = r4.xyz * DirectGGX(dot(r5.xyz,r1.xyz),dot(r5.xyz,r3.xzw),r6.z,r5.w);
        } else {
        r0.x = saturate(dot(r5.xyz, r1.xyz));
        r1.x = dot(r5.xyz, r3.xzw);
        r1.y = r5.w * r5.w;
        r1.z = r1.y * r1.y;
        r0.x = r0.x * r0.x;
        r1.y = r1.y * r1.y + -1;
        r0.x = r0.x * r1.y + 1;
        r0.x = r0.x * r0.x;
        r0.x = 3.14152002 * r0.x;
        r0.x = r1.z / r0.x;
        r1.y = 1 + r5.w;
        r1.y = r1.y * r1.y;
        r1.z = 0.125 * r1.y;
        r1.y = -r1.y * 0.125 + 1;
        r2.w = r6.z * r1.y + r1.z;
        r2.w = r6.z / r2.w;
        r1.y = abs(r1.x) * r1.y + r1.z;
        r1.y = abs(r1.x) / r1.y;
        r1.y = r2.w * r1.y;
        r0.x = r1.y * r0.x;
        r3.xzw = r0.xxx * r4.xyz;
        r0.x = r6.z * abs(r1.x);
        r0.x = 4 * r0.x;
        r1.xyz = r3.xzw / r0.xxx;
        r1.xyz = r1.xyz * r6.zzz;
        }
      } else {
        r1.xyz = float3(0,0,0);
      }
      r1.xyz = (cb13[r1.w+61].xyz * PlayerFillScale(asuint(cb13[r1.w+61].w), recipient_fill, cb12[71].x)) * r1.xyz;
      r1.xyz = r6.yyy * r1.xyz;
      r0.xyz = r0.yzw * r2.xyz + r1.xyz;
      r1.xyz = saturate(r3.yyy * cb12[186].xyz + cb12[187].xyz);
      r0.w = -1 + cb12[69].z;
      r0.w = r4.w * r0.w + 1;
      r1.xyz = float3(-1,-1,-1) + r1.xyz;
      r1.xyz = r0.www * r1.xyz + float3(1,1,1);
      r1.xyz = AMBIENT_ONLY_AO ? 1.f : cb12[69].xxx * r1.xyz + cb12[69].yyy;
      r0.xyz = r1.xyz * r0.xyz;
    } else {
      r0.xyz = float3(0,0,0);
    }
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = r0.xyz;
  o0.w = 1;
  return;
}