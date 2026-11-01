#include "../shadow_inputs.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 31 15:08:30 2026
Texture2DArray<float4> t14 : register(t14);

SamplerState s1_s : register(s1);

cbuffer cb12 : register(b12)
{
  float4 cb12[204];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[44];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[2];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[69];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v0.zw;
  r0.z = v1.w;
  r1.xyz = -cb2[0].xyz + r0.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r1.www;
  r1.w = dot(cb12[203].yzw, cb12[203].yzw);
  r1.w = rsqrt(r1.w);
  r2.xyz = cb12[203].yzw * r1.www;
  r1.x = saturate(dot(r2.xyz, r1.xyz));
  r1.y = 1 + -r1.x;
  r1.y = sqrt(r1.y);
  r1.z = r1.x * -0.0187292993 + 0.0742610022;
  r1.z = r1.z * r1.x + -0.212114394;
  r1.x = r1.z * r1.x + 1.57072878;
  r1.x = dot(r1.xx, r1.yy);
  r1.x = cos(r1.x);
  r1.x = 1 + -r1.x;
  r1.y = cb4[42].w ? cb4[43].x : 10;
  r1.y = -r1.y * r1.y + 10000;
  r1.y = sqrt(r1.y);
  r1.y = -r1.y * 0.00999999978 + 1;
  r1.xy = float2(12.566371,6.28318548) * r1.xy;
  r1.x = cmp(r1.y < r1.x);
  if (r1.x != 0) discard;
  r1.xyz = cb3[1].xyz / r1.yyy;
  float3 classic_cloud_world_0 = r0.xyz;
  r1.w = 20 * cb2[66].x;
  r2.zw = trunc(cb2[68].xy);
  r0.w = sqrt(r0.w);
  r3.xy = cb2[67].xy;
  r3.z = 0;
  r3.xyz = r3.xyz + r0.xyz;
  r3.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r3.xyz;
  r3.xyz = r3.xyz / cb2[66].xxx;
  r4.xy = float2(20,20) * cb2[67].xy;
  r4.z = 0;
  r0.xyz = r4.xyz + r0.xyz;
  r0.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r0.xyz;
  r0.xyz = r0.xyz / r1.www;
  r3.zw = cb3[0].xy * r3.zz;
  r3.zw = r3.zw / cb3[0].zz;
  r2.xy = r3.xy + -r3.zw;
  r3.xy = cb3[0].xy * r0.zz;
  r3.xy = r3.xy / cb3[0].zz;
  r3.xy = -r3.xy + r0.xy;
  r0.x = t14.SampleLevel(s1_s, r2.xyz, 1).x;
  r0.y = t14.SampleLevel(s1_s, r2.xyw, 1).x;
  r0.y = r0.y + -r0.x;
  r0.x = cb2[66].w * r0.y + r0.x;
  r3.zw = r2.zw;
  r0.y = t14.SampleLevel(s1_s, r3.xyz, 1).x;
  r0.z = t14.SampleLevel(s1_s, r3.xyw, 1).x;
  r0.z = r0.z + -r0.y;
  r0.y = cb2[66].w * r0.z + r0.y;
  r0.z = -0.25 + cb3[0].z;
  r0.w = -100 + r0.w;
  r0.zw = saturate(float2(10,0.00666666683) * r0.zw);
  r0.y = r0.y + -r0.x;
  r0.x = r0.w * r0.y + r0.x;
  r0.x = -r0.z * r0.x + 1;
  r0.x = ClassicCloudShadow(classic_cloud_world_0, r0.x);
  o0.xyz = r1.xyz * r0.xxx;
  return;
}
