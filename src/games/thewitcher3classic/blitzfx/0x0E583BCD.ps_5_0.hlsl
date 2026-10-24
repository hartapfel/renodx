#include "../tonemap/native_curve.hlsli"

// BlitzFX environment transition: preserve both exposures and their native blend.
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 24 00:44:08 2026
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

cbuffer cb3 : register(b3)
{
  float4 cb3[18];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[45];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[24];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = t1.Load(float4(0,0,0,0)).x;
  r0.y = max(cb3[9].y, r0.x);
  r0.y = min(cb3[9].z, r0.y);
  r0.y = max(9.99999975e-005, r0.y);
  r0.z = 11.1999998 * cb3[17].x;
  r0.y = r0.y / r0.z;
  r0.y = log2(r0.y);
  r0.y = cb3[17].z * r0.y;
  r0.y = exp2(r0.y);
  r0.y = r0.y * r0.z;
  r0.y = cb3[17].x / r0.y;
  r0.z = max(cb3[4].y, r0.x);
  r0.z = min(cb3[4].z, r0.z);
  r0.z = max(9.99999975e-005, r0.z);
  r0.w = 11.1999998 * cb3[16].x;
  r0.z = r0.z / r0.w;
  r0.z = log2(r0.z);
  r0.z = cb3[16].z * r0.z;
  r0.z = exp2(r0.z);
  r0.z = r0.z * r0.w;
  r0.z = cb3[16].x / r0.z;
  r0.yz = cb1[42].zz * r0.yz;
  r0.w = cmp(cb1[44].y == 0.000000);
  if (r0.w != 0) {
    r1.x = 1;
  }
  r1.yz = v0.xy * cb0[23].zw + float2(-0.5,-0.5);
  r1.y = dot(r1.yz, r1.yz);
  r1.y = sqrt(r1.y);
  r1.y = r1.y * 1.38592935 + -cb1[44].w;
  r1.z = 1 + -cb1[44].w;
  r1.y = r1.y / r1.z;
  r1.y = max(0, r1.y);
  r1.y = log2(r1.y);
  r1.y = cb1[44].z * r1.y;
  r1.y = exp2(r1.y);
  r1.y = -r1.y * cb1[44].y + 1;
  r1.y = max(0, r1.y);
  r0.w = r0.w ? r1.x : r1.y;
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31 && RENODX_PEAK_WHITE_NITS > 0.f)
    r0.w = shader_injection.vignette_strength <= 0.f ? 1.f
        : pow(saturate(r0.w), shader_injection.vignette_strength);
  r0.yz = r0.yz * r0.ww;
  r1.xy = (uint2)v0.xy;
  r1.zw = float2(0,0);
  r1.xyz = t0.Load(r1.xyz).xyz;
  r0.x = 9.99999975e-006 + r0.x;
  r0.x = log2(r0.x);
  r1.xyz = r1.xyz * cb1[41].xyz + float3(9.99999975e-006,9.99999975e-006,9.99999975e-006);
  r1.xyz = log2(r1.xyz);
  r1.xyz = r1.xyz + -r0.xxx;
  r1.xyz = r1.xyz * cb1[44].xxx + r0.xxx;
  r1.xyz = exp2(r1.xyz);
  r1.xyz = float3(-9.99999975e-006,-9.99999975e-006,-9.99999975e-006) + r1.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r0.xyw = r1.xyz * r0.yyy;
  if (asuint(cb1[42].y) != 0) {
    r0.xyw = cb3[17].yyy * r0.xyw;
    r1.w = 1;
  } else {
    r1.w = cb3[17].y;
  }
  r2.x = dot(r0.xyw, float3(0.272228718,0.674081743,0.0536895171));
  r0.xyw = -r2.xxx + r0.xyw;
  r0.xyw = cb1[41].www * r0.xyw + r2.xxx;
  if (RENODX_TONE_MAP_TYPE == CLASSIC_TONE_MAP_PSYCHOV31 && RENODX_PEAK_WHITE_NITS > 0.f) {
    const float3 environment_b = ClassicExtendNative(r0.xyw, cb3[11].xyz, cb3[12].xyz, r1.w);
    r1.xyz *= r0.zzz;
    if (asuint(cb1[42].y) != 0) {
      r1.xyz *= cb3[16].yyy;
      r0.z = 1.f;
    } else {
      r0.z = cb3[16].y;
    }
    r1.w = dot(r1.xyz, float3(0.272228718, 0.674081743, 0.0536895171));
    r1.xyz = cb1[41].www * (r1.xyz - r1.www) + r1.www;
    o0 = float4(lerp(ClassicExtendNative(r1.xyz, cb3[7].xyz, cb3[8].xyz, r0.z),
                    environment_b, cb3[13].x), 1.f);
    return;
  }
  r2.x = cb3[11].z * cb3[11].y;
  r2.yzw = cb3[11].xxx * r0.xyw + r2.xxx;
  r3.xy = cb3[12].xx * cb3[12].yz;
  r2.yzw = r0.xyw * r2.yzw + r3.xxx;
  r4.xyz = cb3[11].xxx * r0.xyw + cb3[11].yyy;
  r0.xyw = r0.xyw * r4.xyz + r3.yyy;
  r0.xyw = r2.yzw / r0.xyw;
  r2.y = cb3[12].y / cb3[12].z;
  r0.xyw = -r2.yyy + r0.xyw;
  r0.xyw = max(float3(0,0,0), r0.xyw);
  r0.xyw = r0.xyw * r1.www;
  r1.w = cb3[11].x * 11.1999998 + r2.x;
  r1.w = r1.w * 11.1999998 + r3.x;
  r2.x = cb3[11].x * 11.1999998 + cb3[11].y;
  r2.x = r2.x * 11.1999998 + r3.y;
  r1.w = r1.w / r2.x;
  r1.w = r1.w + -r2.y;
  r1.w = max(9.99999975e-005, r1.w);
  r0.xyw = r0.xyw / r1.www;
  r1.xyz = r1.xyz * r0.zzz;
  if (asuint(cb1[42].y) != 0) {
    r1.xyz = cb3[16].yyy * r1.xyz;
    r0.z = 1;
  } else {
    r0.z = cb3[16].y;
  }
  r1.w = dot(r1.xyz, float3(0.272228718,0.674081743,0.0536895171));
  r1.xyz = r1.xyz + -r1.www;
  r1.xyz = cb1[41].www * r1.xyz + r1.www;
  r1.w = cb3[7].z * cb3[7].y;
  r2.xyz = cb3[7].xxx * r1.xyz + r1.www;
  r3.xy = cb3[8].xx * cb3[8].yz;
  r2.xyz = r1.xyz * r2.xyz + r3.xxx;
  r4.xyz = cb3[7].xxx * r1.xyz + cb3[7].yyy;
  r1.xyz = r1.xyz * r4.xyz + r3.yyy;
  r1.xyz = r2.xyz / r1.xyz;
  r2.x = cb3[8].y / cb3[8].z;
  r1.xyz = -r2.xxx + r1.xyz;
  r1.xyz = max(float3(0,0,0), r1.xyz);
  r1.xyz = r1.xyz * r0.zzz;
  r0.z = cb3[7].x * 11.1999998 + r1.w;
  r0.z = r0.z * 11.1999998 + r3.x;
  r1.w = cb3[7].x * 11.1999998 + cb3[7].y;
  r1.w = r1.w * 11.1999998 + r3.y;
  r0.z = r0.z / r1.w;
  r0.z = r0.z + -r2.x;
  r0.z = max(9.99999975e-005, r0.z);
  r1.xyz = r1.xyz / r0.zzz;
  r0.xyz = -r1.xyz + r0.xyw;
  o0.xyz = saturate(cb3[13].xxx * r0.xyz + r1.xyz);
  o0.w = 1;
  return;
}