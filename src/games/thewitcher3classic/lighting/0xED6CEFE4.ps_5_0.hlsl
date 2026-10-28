// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 23:13:49 2026
TextureCubeArray<float4> t10 : register(t10);

Texture2DArray<float4> t9 : register(t9);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s10_s : register(s10);

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
  r3.x = dot(r2.xyz, r2.xyz);
  r3.y = sqrt(r3.x);
  r3.z = cmp(r3.y < cb13[r1.w+58].w);
  if (r3.z != 0) {
    r3.zw = t4.Load(r0.xyw).xz;
    r4.xyzw = t1.Load(r0.xyw).xyzw;
    r5.xyzw = t2.Load(r0.xyw).xyzw;
    if (CUSTOM_BRDF) r5.w=FilterDirectRoughness(int2(r0.xy),r5);
    r0.xyz = t3.Load(r0.xyz).xyz;
    r0.w = r3.y / cb13[r1.w+58].w;
    r6.x = r0.w * r0.w;
    r6.x = -r6.x * r6.x + 1;
    r6.x = max(0, r6.x);
    r6.x = r6.x * r6.x;
    r6.y = cmp(0 < cb13[r1.w+63].z);
    r6.z = cmp(0 < cb13[r1.w+64].x);
    r6.w = r3.x * cb13[r1.w+63].x + 1;
    r6.x = r6.x / r6.w;
    r3.x = rsqrt(r3.x);
    r7.xyz = r3.xxx * r2.xyz;
    r3.x = dot(-r7.xyz, cb13[r1.w+60].xyz);
    r3.x = saturate(r3.x * cb13[r1.w+62].y + cb13[r1.w+62].z);
    r3.x = log2(r3.x);
    r3.x = cb13[r1.w+62].w * r3.x;
    r3.x = exp2(r3.x);
    r3.x = r6.x * r3.x;
    r6.x = cmp(0 < r3.x);
    r6.y = r6.x ? r6.y : 0;
    if (r6.y != 0) {
      r7.xyz = -cb13[r1.w+58].xyz + r1.xyz;
      r8.xyz = cb13[r1.w+65].zwy * cb13[r1.w+60].zxy;
      r8.xyz = cb13[r1.w+60].yzx * cb13[r1.w+65].wyz + -r8.xyz;
      r6.y = dot(r8.xyz, r7.xyz);
      r6.w = dot(cb13[r1.w+65].yzw, r7.xyz);
      r7.x = dot(cb13[r1.w+60].xyz, r7.xyz);
      r8.xy = cb13[r1.w+63].yy * r6.yw;
      r6.yw = r8.xy / r7.xx;
      r6.yw = r6.yw * float2(0.5,-0.5) + float2(0.5,0.5);
      float4 shadow_tile = DecodeShadowAtlas(cb13[r1.w+65].x);
      r7.xy = shadow_tile.xy;
      r7.z = shadow_tile.z;
      r8.z = shadow_tile.w;
      r7.w = cmp(0 < r7.z);
      if (r7.w != 0) {
        r6.yw = r6.yw * r7.zz + r7.xy;
        r8.xy = float2(0.0009765625,0.0009765625) * r6.yw;
        r6.y = t9.SampleLevel(s10_s, r8.xyz, 0).x;
        r6.y = -r0.w * 0.99000001 + r6.y;
        r6.y = 144.269501 * r6.y;
        r6.y = exp2(r6.y);
        r6.y = min(1, r6.y);
      } else {
        r6.y = 1;
      }
    } else {
      r6.y = 1;
    }
    r6.x = r6.x ? r6.z : 0;
    if (r6.x != 0) {
      r2.w = cb13[r1.w+64].y;
      r2.w = t10.SampleLevel(s10_s, r2.xyzw, 0).x;
      r0.w = -r0.w * 0.99000001 + r2.w;
      r0.w = 144.269501 * r0.w;
      r0.w = exp2(r0.w);
      r0.w = min(1, r0.w);
      r6.y = r6.y * r0.w;
    }
    r0.w = -1 + r6.y;
    r0.w = cb13[r1.w+60].w * r0.w + 1;
    r0.w = r3.x * r0.w;
    r6.xy = int2(2048,4096) & asint(cb13[r1.w+61].ww);
    r2.w = cmp(r3.w == 1.000000);
    r3.x = r2.w ? 1.000000 : 0;
    r3.x = r6.x ? 1 : r3.x;
    r2.w = r2.w ? 0 : 1;
    r2.w = r6.y ? 1 : r2.w;
    r2.w = r3.x * r2.w;
    r0.w = r2.w * r0.w;
    r2.w = cmp(0 < r0.w);
    if (r2.w != 0) {
      r4.xyz = log2(r4.xyz);
      r4.xyz = float3(2.20000005,2.20000005,2.20000005) * r4.xyz;
      r4.xyz = exp2(r4.xyz);
      r0.xyz = log2(r0.xyz);
      r0.xyz = float3(2.20000005,2.20000005,2.20000005) * r0.xyz;
      r0.xyz = exp2(r0.xyz);
      r5.xyz = float3(-0.5,-0.5,-0.5) + r5.xyz;
      r2.w = dot(r5.xyz, r5.xyz);
      r2.w = rsqrt(r2.w);
      r5.xyz = r5.xyz * r2.www;
      r2.xyz = r2.xyz / r3.yyy;
      r1.xyz = cb12[0].xyz + -r1.xyz;
      r2.w = dot(r1.xyz, r1.xyz);
      r2.w = rsqrt(r2.w);
      r3.xyw = r2.www * r1.xyz;
      r6.xy = cb12[183].zw * r0.ww;
      r0.w = dot(r5.xyz, r2.xyz);
      r6.z = saturate(r0.w);
      r1.xyz = r1.xyz * r2.www + r2.xyz;
      r2.w = dot(r1.xyz, r1.xyz);
      r2.w = rsqrt(r2.w);
      r1.xyz = r2.www * r1.xyz;
      r2.w = dot(r1.xyz, r3.xyw);
      r2.w = 1 + -abs(r2.w);
      r2.w = max(0, r2.w);
      r6.w = r2.w * r2.w;
      r6.w = r6.w * r6.w;
      r2.w = r6.w * r2.w;
      float3 direct_fresnel = DirectFresnel(r0.xyz, r2.w);
      r6.w = 1 + -r5.w;
      r7.xyz = float3(1,1,1) + -r0.xyz;
      r8.xyz = max(float3(0,0,0), r7.xyz);
      r8.xyz = cb13[56].xxx * r8.xyz;
      r8.xyz = r8.xyz * r2.www;
      r2.w = 1 + cb13[56].z;
      r2.w = -cb13[56].z * r6.w + r2.w;
      r8.xyz = r8.xyz / r2.www;
      r0.xyz = CUSTOM_BRDF ? direct_fresnel : r8.xyz + r0.xyz;
      r8.xyz = float3(1,1,1) + -r0.xyz;
      r8.xyz = r8.xyz * r6.zzz;
      r8.xyz = float3(0.318309873,0.318309873,0.318309873) * r8.xyz;
      if (CUSTOM_BRDF) r8.xyz *= DirectDiffuseFactor(dot(r5.xyz,r3.xyw),r6.z,dot(r1.xyz,r3.xyw),r5.w);
      r2.w = cmp(0 < r4.w);
      if (r2.w != 0) {
        r2.w = 1 + r0.w;
        r2.x = dot(r2.xyz, -r3.xyw);
        r2.x = 1 + r2.x;
        r2.xw = float2(0.5,0.5) * r2.xw;
        r2.y = dot(r5.xyz, -r3.xyw);
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
      r0.w = cmp(0 < r0.w);
      if (r0.w != 0) {
        if (CUSTOM_BRDF) {
          r0.xyz = r0.xyz * DirectGGX(dot(r5.xyz,r1.xyz),dot(r5.xyz,r3.xyw),r6.z,r5.w);
        } else {
        r0.w = saturate(dot(r5.xyz, r1.xyz));
        r1.x = dot(r5.xyz, r3.xyw);
        r1.y = r5.w * r5.w;
        r1.z = r1.y * r1.y;
        r0.w = r0.w * r0.w;
        r1.y = r1.y * r1.y + -1;
        r0.w = r0.w * r1.y + 1;
        r0.w = r0.w * r0.w;
        r0.w = 3.14152002 * r0.w;
        r0.w = r1.z / r0.w;
        r1.y = 1 + r5.w;
        r1.y = r1.y * r1.y;
        r1.z = 0.125 * r1.y;
        r1.y = -r1.y * 0.125 + 1;
        r2.w = r6.z * r1.y + r1.z;
        r2.w = r6.z / r2.w;
        r1.y = abs(r1.x) * r1.y + r1.z;
        r1.y = abs(r1.x) / r1.y;
        r1.y = r2.w * r1.y;
        r0.w = r1.y * r0.w;
        r0.xyz = r0.www * r0.xyz;
        r0.w = r6.z * abs(r1.x);
        r0.w = 4 * r0.w;
        r0.xyz = r0.xyz / r0.www;
        r0.xyz = r0.xyz * r6.zzz;
        }
      } else {
        r0.xyz = float3(0,0,0);
      }
      r0.xyz = (cb13[r1.w+61].xyz * PlayerFillScale(asuint(cb13[r1.w+61].w), recipient_fill, cb12[71].x)) * r0.xyz;
      r0.xyz = r6.yyy * r0.xyz;
      r0.xyz = r4.xyz * r2.xyz + r0.xyz;
      r1.xyz = saturate(r3.zzz * cb12[186].xyz + cb12[187].xyz);
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