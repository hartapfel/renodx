// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[10];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}




// 3Dmigoto declarations
#define cmp -


#include "./object_pixel.hlsli"

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float3 v4 : TEXCOORD4,
  float4 motion_position : SV_Position,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v5 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = cb4[1].xy * v1.xy;
  r1.x = -abs(cb4[2].x) + 1;
  r1.y = cb4[2].x;
  r2.x = dot(r1.xy, r0.xy);
  r1.z = -cb4[2].x;
  r2.y = dot(r1.zx, r0.xy);
  r0.xyz = t1.Sample(s0_s, r2.xy).xyz;
  r0.w = cb4[0].x * 0.25;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.zxy;
  r0.x = r0.w * r0.x;
  r1.xyz = t2.Sample(s0_s, v1.xy).xyz;
  r2.xyz = cb1[8].xyz + -v3.xyz;
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = sqrt(r0.w);
  r0.w = saturate(cb4[3].x + -r0.w);
  r1.w = cb4[0].x * r0.w;
  r2.x = saturate(r1.w * r0.x + r1.z);
  r2.yzw = t0.Sample(s0_s, v1.xy).xyz;
  r2.yzw = r0.xxx * r0.www + r2.yzw;
  r3.x = r2.y + r2.z;
  r3.x = r3.x + r2.w;
  r3.z = cb4[5].x + -1;
  r3.yz = float2(0.333299994,0.5) * r3.xz;
  r3.w = saturate(r3.z);
  r3.x = r3.x * -0.666599989 + 1;
  r3.x = r3.w * r3.x + r3.y;
  r4.xyz = cb4[4].xyz * r2.yzw;
  r4.xyz = saturate(float3(1.5,1.5,1.5) * r4.xyz);
  r3.x = saturate(r3.x * abs(r3.z));
  r3.yzw = r4.xyz + -r2.yzw;
  r2.yzw = r3.xxx * r3.yzw + r2.yzw;
  r3.x = max(r2.z, r2.w);
  r3.x = max(r3.x, r2.y);
  r3.x = cmp(0.219999999 < r3.x);
  r3.x = r3.x ? -0.300000012 : -0.149999976;
  r3.x = v0.z * r3.x + 1;
  o0.xyz = r3.xxx * r2.yzw;
  r0.yz = r1.ww * r0.yz;
  r1.xy = float2(-0.5,-0.5) + r1.xy;
  r0.yz = r0.yz + r0.yz;
  r0.yz = r1.xy * float2(2,2) + r0.yz;
  r3.x = v0.w;
  r3.yz = v1.zw;
  r1.xyw = r3.xyz * r0.zzz;
  r1.xyw = v4.xyz * r0.yyy + r1.xyw;
  r1.xyw = v2.xyz + r1.xyw;
  r0.y = cmp(0 >= (uint)v5.x);
  if (r0.y != 0) {
    r0.y = dot(v2.xyz, r1.xyw);
    r2.yzw = v2.xyz * r0.yyy;
    r1.xyw = -r2.yzw * float3(2,2,2) + r1.xyw;
  }
  r0.x = -r0.x * r0.w + r1.z;
  r0.x = 1 + -r0.x;
  r0.yzw = log2(cb4[6].xyz);
  r0.yzw = float3(2.20000005,2.20000005,2.20000005) * r0.yzw;
  r0.yzw = exp2(r0.yzw);
  r0.x = r0.x * cb4[7].x + cb4[8].x;
  r0.xyz = saturate(r0.yzw * r0.xxx);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.454544991,0.454544991,0.454544991) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.w = max(r0.y, r0.z);
  r0.w = max(r0.x, r0.w);
  r0.w = cmp(0.200000003 < r0.w);
  r2.yzw = r0.www ? r0.xyz : float3(0.119999997,0.119999997,0.119999997);
  r2.yzw = r2.yzw + -r0.xyz;
  o2.xyz = v0.zzz * r2.yzw + r0.xyz;
  r0.x = cmp(r2.x < 0.330000013);
  r0.y = 0.949999988 * r2.x;
  r0.x = r0.x ? r0.y : 0.330000013;
  r0.x = r0.x + -r2.x;
  o1.w = v0.z * r0.x + r2.x;
  r0.x = dot(r1.xyw, r1.xyw);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyw * r0.xxx;
  r0.w = max(abs(r0.x), abs(r0.y));
  r0.w = max(abs(r0.z), r0.w);
  r1.xy = cmp(abs(r0.zy) < r0.ww);
  r1.yz = r1.yy ? abs(r0.zy) : abs(r0.zx);
  r1.xy = r1.xx ? r1.yz : abs(r0.yx);
  r1.z = cmp(r1.y < r1.x);
  r1.xy = r1.zz ? r1.xy : r1.yx;
  r1.z = r1.y / r1.x;
  r0.xyz = r0.xyz / r0.www;
  r0.w = t13.SampleLevel(s13_s, r1.xz, 0).x;
  r0.xyz = r0.xyz * r0.www;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = cb4[9].x;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}