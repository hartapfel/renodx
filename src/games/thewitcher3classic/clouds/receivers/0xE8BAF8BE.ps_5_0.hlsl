#include "../shadow_inputs.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 31 15:08:29 2026
Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float4> t1 : register(t1);

Texture2DArray<float4> t0 : register(t0);

SamplerState s14_s : register(s14);

cbuffer cb13 : register(b13)
{
  float4 cb13[1];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[214];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[4];
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

  r0.xy = (uint2)v0.xy;
  r0.z = (uint)cb3[3].x;
  r0.w = 0;
  r1.x = t1.Load(r0.xyzw).x;
  r1.y = r1.x * cb12[22].x + cb12[22].y;
  r1.y = cmp(r1.y < 1);
  if (r1.y != 0) {
    r1.yz = (uint2)r0.xy;
    r2.xyzw = cb12[211].xyzw * r1.zzzz;
    r2.xyzw = cb12[210].xyzw * r1.yyyy + r2.xyzw;
    r1.xyzw = cb12[212].xyzw * r1.xxxx + r2.xyzw;
    r1.xyzw = cb12[213].xyzw + r1.xyzw;
    r1.xyz = r1.xyz / r1.www;
    r0.xyzw = t0.Load(r0.xyzw).xyzw;
    r1.w = dot(cb3[0].xyzw, r0.xyzw);
    r1.w = (int)r1.w;
    r2.xy = (int2)cb3[2].xy;
    r1.w = (int)r1.w & (int)r2.x;
    r0.x = dot(cb3[1].xyzw, r0.xyzw);
    r0.x = (int)r0.x;
    r0.x = (int)r2.y & (int)r0.x;
    r0.x = r0.x ? 1 : 0;
    r0.yz = r1.ww ? float2(1,-1) : float2(0,-0);
    r0.x = r0.x + r0.z;
    r0.x = cb3[2].z * r0.x + r0.y;
    float3 classic_cloud_world_0 = r1.xyz;
    r0.y = 20 * cb12[66].x;
    r2.zw = trunc(cb12[68].xy);
    r3.xyz = -cb12[0].xyz + r1.xyz;
    r0.z = dot(r3.xyz, r3.xyz);
    r0.z = sqrt(r0.z);
    r3.xy = cb12[67].xy;
    r3.z = 0;
    r3.xyz = r3.xyz + r1.xyz;
    r3.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r3.xyz;
    r3.xyz = r3.xyz / cb12[66].xxx;
    r4.xy = float2(20,20) * cb12[67].xy;
    r4.z = 0;
    r1.xyz = r4.xyz + r1.xyz;
    r1.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r1.xyz;
    r1.xyz = r1.xyz / r0.yyy;
    r0.yw = cb13[0].xy * r3.zz;
    r0.yw = r0.yw / cb13[0].zz;
    r2.xy = r3.xy + -r0.yw;
    r0.yw = cb13[0].xy * r1.zz;
    r0.yw = r0.yw / cb13[0].zz;
    r1.xy = r1.xy + -r0.yw;
    r0.y = t14.SampleLevel(s14_s, r2.xyz, 1).x;
    r0.w = t14.SampleLevel(s14_s, r2.xyw, 1).x;
    r0.w = r0.w + -r0.y;
    r0.y = cb12[66].w * r0.w + r0.y;
    r1.zw = r2.zw;
    r0.w = t14.SampleLevel(s14_s, r1.xyz, 1).x;
    r1.x = t14.SampleLevel(s14_s, r1.xyw, 1).x;
    r1.x = r1.x + -r0.w;
    r0.w = cb12[66].w * r1.x + r0.w;
    r1.x = -0.25 + cb13[0].z;
    r1.x = saturate(10 * r1.x);
    r0.z = -100 + r0.z;
    r0.z = saturate(0.00666666683 * r0.z);
    r0.w = r0.w + -r0.y;
    r0.y = r0.z * r0.w + r0.y;
    r0.y = -r1.x * r0.y + 1;
    r0.y = ClassicCloudShadow(classic_cloud_world_0, r0.y);
    r0.x = r0.x * r0.y;
  } else {
    r0.x = 1;
  }
  r0.y = 1;
  o0.xyzw = r0.yxyy;
  return;
}
