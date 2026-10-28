#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 18:16:23 2026
Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

cbuffer cb12 : register(b12)
{
  float4 cb12[214];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[2];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = (uint2)v0.xy;
  r0.zw = float2(0,0);
  r1.x = t0.Load(r0.xyw).x;
  r1.y = r1.x * cb12[22].x + cb12[22].y;
  r1.y = cmp(r1.y < 1);
  if (r1.y != 0) {
    r1.yz = (uint2)r0.xy;
    r2.xyzw = cb12[211].xyzw * r1.zzzz;
    r2.xyzw = cb12[210].xyzw * r1.yyyy + r2.xyzw;
    r1.xyzw = cb12[212].xyzw * r1.xxxx + r2.xyzw;
    r1.xyzw = cb12[213].xyzw + r1.xyzw;
    r1.xyz = r1.xyz / r1.www;
    r2.xyz = t1.Load(r0.xyw).xyz;
    r0.x = t2.Load(r0.xyz).x;
    r0.x = max(cb3[1].x, r0.x);
    r0.yzw = -cb12[0].xyz + r1.xyz;
    r1.x = dot(r0.yzw, r0.yzw);
    r1.x = sqrt(r1.x);
    r1.y = -cb3[0].x + r1.x;
    r1.zw = cb3[0].yw + -cb3[0].xz;
    r1.y = saturate(r1.y / r1.z);
    r1.y = r1.y * r1.w + cb3[0].z;
    r0.x = -1 + r0.x;
    r0.x = r1.y * r0.x + 1;
    if (ClassicFogReady()) {
      float4 fog = SampleClassicFog(v0.xy * cb12[23].zw, r1.x);
      // Preserve Classic's distance-dependent AO influence on atmospheric fog.
      // Interior exclusion is applied to density before volume integration.
      o0 = float4(r2.xyz * lerp(1.f, fog.a, r0.x) + fog.rgb * r0.x, 1.f);
      return;
    }
    r0.yzw = r0.yzw / r1.xxx;
    r1.y = r0.w * cb12[22].z + cb12[0].z;
    r1.x = -cb12[22].z + r1.x;
    r1.x = max(0, r1.x);
    r1.x = min(cb12[42].z, r1.x);
    r1.z = r1.x * r0.w;
    r1.w = cb12[43].x * r1.x;
    r1.zw = float2(0.0625,0.0625) * r1.zw;
    r0.y = dot(cb12[38].xyz, r0.yzw);
    r0.z = cb12[42].x + r0.y;
    r0.w = 1 + cb12[42].x;
    r0.z = saturate(r0.z / r0.w);
    r0.w = cb12[43].y + -cb12[43].z;
    r0.z = r0.z * r0.w + cb12[43].z;
    r0.w = abs(r0.y) * abs(r0.y);
    r2.w = saturate(r1.x * 0.00200000009 + -0.300000012);
    r0.w = r2.w * r0.w;
    r0.y = cmp(0 < r0.y);
    r3.xyz = r0.yyy ? cb12[39].xyz : cb12[41].xyz;
    r3.xyz = -cb12[40].xyz + r3.xyz;
    r3.xyz = r0.www * r3.xyz + cb12[40].xyz;
    r4.xyz = r0.yyy ? cb12[45].xyz : cb12[47].xyz;
    r4.xyz = -cb12[46].xyz + r4.xyz;
    r4.xyz = r0.www * r4.xyz + cb12[46].xyz;
    r0.y = cmp(r1.x >= cb12[48].y);
    if (r0.y != 0) {
      r0.y = cb12[42].y + r1.y;
      r0.w = r0.y * r0.z;
      r1.y = r1.z * r0.z;
      r5.xyzw = r1.yyyy * float4(16,15,14,13) + r0.wwww;
      r5.xyzw = max(float4(0,0,0,0), r5.xyzw);
      r5.xyzw = float4(1,1,1,1) + r5.xyzw;
      r5.xyzw = saturate(r1.wwww / r5.xyzw);
      r5.xyzw = float4(1,1,1,1) + -r5.xyzw;
      r1.z = r5.x * r5.y;
      r1.z = r1.z * r5.z;
      r1.z = r1.z * r5.w;
      r5.xyzw = r1.yyyy * float4(12,11,10,9) + r0.wwww;
      r5.xyzw = max(float4(0,0,0,0), r5.xyzw);
      r5.xyzw = float4(1,1,1,1) + r5.xyzw;
      r5.xyzw = saturate(r1.wwww / r5.xyzw);
      r5.xyzw = float4(1,1,1,1) + -r5.xyzw;
      r1.z = r5.x * r1.z;
      r1.z = r1.z * r5.y;
      r1.z = r1.z * r5.z;
      r1.z = r1.z * r5.w;
      r5.xyzw = r1.yyyy * float4(8,7,6,5) + r0.wwww;
      r5.xyzw = max(float4(0,0,0,0), r5.xyzw);
      r5.xyzw = float4(1,1,1,1) + r5.xyzw;
      r5.xyzw = saturate(r1.wwww / r5.xyzw);
      r5.xyzw = float4(1,1,1,1) + -r5.xyzw;
      r1.z = r5.x * r1.z;
      r1.z = r1.z * r5.y;
      r1.z = r1.z * r5.z;
      r1.z = r1.z * r5.w;
      r5.xy = r1.yy * float2(4,3) + r0.ww;
      r5.xy = max(float2(0,0), r5.xy);
      r5.xy = float2(1,1) + r5.xy;
      r5.xy = saturate(r1.ww / r5.xy);
      r5.xy = float2(1,1) + -r5.xy;
      r1.z = r5.x * r1.z;
      r1.z = r1.z * r5.y;
      r0.w = r1.y * 2 + r0.w;
      r0.w = max(0, r0.w);
      r0.w = 1 + r0.w;
      r0.w = saturate(r1.w / r0.w);
      r0.w = 1 + -r0.w;
      r0.w = r1.z * r0.w;
      r0.y = r0.y * r0.z + r1.y;
      r0.y = max(0, r0.y);
      r0.y = 1 + r0.y;
      r0.y = saturate(r1.w / r0.y);
      r0.y = 1 + -r0.y;
      r0.y = -r0.w * r0.y + 1;
      r0.z = -cb12[48].y + r1.x;
      r0.z = saturate(cb12[48].z * r0.z);
    } else {
      r0.yz = float2(1,0);
    }
    r0.y = log2(r0.y);
    r0.w = cb12[42].w * r0.y;
    r0.w = exp2(r0.w);
    r0.y = cb12[48].x * r0.y;
    r0.y = exp2(r0.y);
    r0.yw = r0.zz * r0.yw;
    r1.xy = saturate(r0.ww * cb12[189].xz + cb12[189].yw);
    r5.xyz = cb12[188].xyz + -r3.xyz;
    r5.xyz = r1.xxx * r5.xyz + r3.xyz;
    r0.z = -1 + cb12[188].w;
    r0.z = r1.y * r0.z + 1;
    r5.w = saturate(r0.w * r0.z);
    r0.z = cmp(0 < cb12[192].x);
    if (r0.z != 0) {
      r1.xy = saturate(r0.ww * cb12[191].xz + cb12[191].yw);
      r6.xyz = cb12[190].xyz + -r3.xyz;
      r3.xyz = r1.xxx * r6.xyz + r3.xyz;
      r0.z = -1 + cb12[190].w;
      r0.z = r1.y * r0.z + 1;
      r3.w = saturate(r0.w * r0.z);
      r1.xyzw = r3.xyzw + -r5.xyzw;
      r5.xyzw = cb12[192].xxxx * r1.xyzw + r5.xyzw;
    }
    r0.z = r5.w * r0.x;
    r0.x = r0.y * r0.x;
    r0.y = dot(float3(0.333000004,0.555000007,0.222000003), r2.xyz);
    r1.xyz = r0.yyy * r4.xyz + -r2.xyz;
    r0.xyw = r0.xxx * r1.xyz + r2.xyz;
    r1.xyz = r5.xyz + -r0.xyw;
    r0.xyz = r0.zzz * r1.xyz + r0.xyw;
  } else {
    r0.xyz = float3(0,0,0);
  }
  o0.xyz = r0.xyz;
  o0.w = 1;
  return;
}
