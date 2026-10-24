#include "scene_pool.hlsli"
RWTexture2D<float4> u0 : register(u0);
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 24 01:58:50 2026
Texture2D<float4> t52 : register(t52);

Texture2D<float4> t51 : register(t51);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[37];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[24];
}

// 3Dmigoto declarations
#define cmp -

[numthreads(8, 8, 1)]
void main(uint3 vThreadID : SV_DispatchThreadID)
{
  uint mask_width, mask_height, color_width, color_height;
  t51.GetDimensions(mask_width, mask_height);
  t52.GetDimensions(color_width, color_height);
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = vThreadID.xy;
  r0.zw = float2(0,0);
  r1.x = t0.Load(r0.xyw).x;
  r0.xyz = t52.Load(r0.xyz).xyz;
  r2.xy = (uint2)vThreadID.xy;
  r2.xy = float2(0.5,0.5) + r2.xy;
  r2.xy = cb0[23].zw * r2.xy;
  r1.zw = r2.yx * float2(-2,2) + float2(1,-1);
  r1.y = 1;
  r3.x = dot(cb1[24].zwyx, r1.xyzw);
  r3.y = dot(cb1[25].zwyx, r1.xyzw);
  r3.z = dot(cb1[26].zwyx, r1.xyzw);
  r0.w = dot(cb1[27].zwyx, r1.xyzw);
  r3.xyz = r3.xyz / r0.www;
  r3.w = 1;
  r4.x = dot(cb1[28].xyzw, r3.xyzw);
  r4.y = dot(cb1[29].xyzw, r3.xyzw);
  r0.w = dot(cb1[31].xyzw, r3.xyzw);
  r2.zw = r4.xy / r0.ww;
  r1.xy = -cb1[36].xy * float2(0.5,0.5) + r2.zw;
  r1.xy = r1.wy + -r1.xz;
  r1.xy = float2(0.125,0.125) * r1.xy;
  r0.w = t51.SampleLevel(s0_s, BlitzScenePoolUV(r2.xy, cb0[23].xy, float2(mask_width, mask_height)), 0).x;
  r1.xy = r1.xy * r0.ww;
  r0.w = dot(r1.xy, r1.xy);
  r0.w = sqrt(r0.w);
  r0.w = -0.00200000009 + r0.w;
  r0.w = saturate(1000.00006 * r0.w);
  r1.z = cmp(0 < r0.w);
  if (r1.z != 0) {
    r1.xy = r1.xy * r0.ww;
    r0.w = dot(r1.xy, r1.xy);
    r0.w = sqrt(r0.w);
    r1.xy = r1.xy / r0.ww;
    r0.w = min(0.00999999978, r0.w);
    r1.zw = r1.xy * r0.ww;
    r2.z = (int)vThreadID.y + (int)vThreadID.x;
    r2.z = (int)r2.z & 1;
    r2.z = (uint)r2.z;
    r2.z = cmp(r2.z < 0.5);
    r2.z = r2.z ? 0.0666666701 : -0.0666666701;
    r2.xy = r2.zz * r1.zw + r2.xy;
    r1.xy = r1.xy * r0.ww + r2.xy;
    r3.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r1.xy, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r3.z, r3.w);
    r0.w = min(r3.y, r0.w);
    r3.w = min(r3.x, r0.w);
    r4.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r1.xy, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r4.xyz = min(float3(650000,650000,650000), r4.xyz);
    r5.xyz = cmp(r4.xyz == float3(650000,650000,650000));
    r4.xyz = r5.xyz ? float3(0,0,0) : r4.xyz;
    r3.xyz = r4.xyz * r3.www;
    r4.xyzw = -r1.zwzw * float4(-0.866666675,-0.866666675,-0.733333349,-0.733333349) + r2.xyxy;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.xy, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r6.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.xy, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r6.xyz = min(float3(650000,650000,650000), r6.xyz);
    r7.xyz = cmp(r6.xyz == float3(650000,650000,650000));
    r6.xyz = r7.xyz ? float3(0,0,0) : r6.xyz;
    r5.xyz = r6.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.zw, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r4.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.zw, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r4.xyz = min(float3(650000,650000,650000), r4.xyz);
    r6.xyz = cmp(r4.xyz == float3(650000,650000,650000));
    r4.xyz = r6.xyz ? float3(0,0,0) : r4.xyz;
    r5.xyz = r4.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r4.xyzw = -r1.zwzw * float4(-0.600000024,-0.600000024,-0.466666698,-0.466666698) + r2.xyxy;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.xy, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r6.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.xy, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r6.xyz = min(float3(650000,650000,650000), r6.xyz);
    r7.xyz = cmp(r6.xyz == float3(650000,650000,650000));
    r6.xyz = r7.xyz ? float3(0,0,0) : r6.xyz;
    r5.xyz = r6.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.zw, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r4.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.zw, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r4.xyz = min(float3(650000,650000,650000), r4.xyz);
    r6.xyz = cmp(r4.xyz == float3(650000,650000,650000));
    r4.xyz = r6.xyz ? float3(0,0,0) : r4.xyz;
    r5.xyz = r4.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r4.xyzw = -r1.zwzw * float4(-0.333333373,-0.333333373,-0.200000033,-0.200000033) + r2.xyxy;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.xy, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r6.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.xy, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r6.xyz = min(float3(650000,650000,650000), r6.xyz);
    r7.xyz = cmp(r6.xyz == float3(650000,650000,650000));
    r6.xyz = r7.xyz ? float3(0,0,0) : r6.xyz;
    r5.xyz = r6.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.zw, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r4.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.zw, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r4.xyz = min(float3(650000,650000,650000), r4.xyz);
    r6.xyz = cmp(r4.xyz == float3(650000,650000,650000));
    r4.xyz = r6.xyz ? float3(0,0,0) : r4.xyz;
    r5.xyz = r4.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r4.xyzw = -r1.zwzw * float4(-0.0666666925,-0.0666666925,0.0666666478,0.0666666478) + r2.xyxy;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.xy, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r6.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.xy, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r6.xyz = min(float3(650000,650000,650000), r6.xyz);
    r7.xyz = cmp(r6.xyz == float3(650000,650000,650000));
    r6.xyz = r7.xyz ? float3(0,0,0) : r6.xyz;
    r5.xyz = r6.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.zw, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r4.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.zw, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r4.xyz = min(float3(650000,650000,650000), r4.xyz);
    r6.xyz = cmp(r4.xyz == float3(650000,650000,650000));
    r4.xyz = r6.xyz ? float3(0,0,0) : r4.xyz;
    r5.xyz = r4.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r4.xyzw = -r1.zwzw * float4(0.199999988,0.199999988,0.333333313,0.333333313) + r2.xyxy;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.xy, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r6.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.xy, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r6.xyz = min(float3(650000,650000,650000), r6.xyz);
    r7.xyz = cmp(r6.xyz == float3(650000,650000,650000));
    r6.xyz = r7.xyz ? float3(0,0,0) : r6.xyz;
    r5.xyz = r6.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.zw, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r4.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.zw, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r4.xyz = min(float3(650000,650000,650000), r4.xyz);
    r6.xyz = cmp(r4.xyz == float3(650000,650000,650000));
    r4.xyz = r6.xyz ? float3(0,0,0) : r4.xyz;
    r5.xyz = r4.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r4.xyzw = -r1.zwzw * float4(0.466666639,0.466666639,0.599999964,0.599999964) + r2.xyxy;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.xy, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r6.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.xy, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r6.xyz = min(float3(650000,650000,650000), r6.xyz);
    r7.xyz = cmp(r6.xyz == float3(650000,650000,650000));
    r6.xyz = r7.xyz ? float3(0,0,0) : r6.xyz;
    r5.xyz = r6.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.zw, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r4.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.zw, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r4.xyz = min(float3(650000,650000,650000), r4.xyz);
    r6.xyz = cmp(r4.xyz == float3(650000,650000,650000));
    r4.xyz = r6.xyz ? float3(0,0,0) : r4.xyz;
    r5.xyz = r4.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r4.xyzw = -r1.zwzw * float4(0.73333329,0.73333329,0.866666615,0.866666615) + r2.xyxy;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.xy, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r6.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.xy, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r6.xyz = min(float3(650000,650000,650000), r6.xyz);
    r7.xyz = cmp(r6.xyz == float3(650000,650000,650000));
    r6.xyz = r7.xyz ? float3(0,0,0) : r6.xyz;
    r5.xyz = r6.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r5.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r4.zw, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r5.z, r5.w);
    r0.w = min(r5.y, r0.w);
    r5.w = min(r5.x, r0.w);
    r4.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r4.zw, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r4.xyz = min(float3(650000,650000,650000), r4.xyz);
    r6.xyz = cmp(r4.xyz == float3(650000,650000,650000));
    r4.xyz = r6.xyz ? float3(0,0,0) : r4.xyz;
    r5.xyz = r4.xyz * r5.www;
    r3.xyzw = r5.xyzw + r3.xyzw;
    r1.xy = -r1.zw * float2(0.99999994,0.99999994) + r2.xy;
    r2.xyzw = BlitzGatherScenePoolRed(t51, s0_s, r1.xy, uint2(cb0[23].xy), uint2(mask_width, mask_height)).xyzw;
    r0.w = min(r2.z, r2.w);
    r0.w = min(r2.y, r0.w);
    r2.w = min(r2.x, r0.w);
    r1.xyz = t52.SampleLevel(s1_s, BlitzScenePoolUV(r1.xy, cb0[23].xy, float2(color_width, color_height)), 0).xyz;
    r1.xyz = min(float3(650000,650000,650000), r1.xyz);
    r4.xyz = cmp(r1.xyz == float3(650000,650000,650000));
    r1.xyz = r4.xyz ? float3(0,0,0) : r1.xyz;
    r2.xyz = r1.xyz * r2.www;
    r1.xyzw = r3.xyzw + r2.xyzw;
    r0.w = cmp(9.99999975e-005 < r1.w);
    r1.xyz = r1.xyz / r1.www;
    r0.xyz = r0.www ? r1.xyz : r0.xyz;
  }
  u0[vThreadID.xy] = r0.xyzx;
  return;
}