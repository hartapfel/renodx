// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[7];
}




// 3Dmigoto declarations
#define cmp -


#include "./object_pixel.hlsli"

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float3 v3 : TEXCOORD3,
  float4 motion_position : SV_Position,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v4 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = t0.Sample(s0_s, v0.xy).xyz;
  r0.w = r0.x + r0.y;
  r0.w = r0.w + r0.z;
  r1.x = 0.333299994 * r0.w;
  r1.y = cb4[1].x + -1;
  r1.y = 0.5 * r1.y;
  r1.z = saturate(r1.y);
  r0.w = r0.w * -0.666599989 + 1;
  r0.w = r1.z * r0.w + r1.x;
  r1.xzw = cb4[0].xyz * r0.xyz;
  r1.xzw = saturate(float3(1.5,1.5,1.5) * r1.xzw);
  r0.w = saturate(r0.w * abs(r1.y));
  r1.xyz = r1.xzw + -r0.xyz;
  r0.xyz = r0.www * r1.xyz + r0.xyz;
  r0.w = floor(cb4[2].x);
  r1.x = 0.25 * r0.w;
  r0.w = cb4[2].x * 0.25;
  r1.y = floor(r0.w);
  r1.xy = v0.zw * float2(0.25,1) + r1.xy;
  r1.xyzw = t1.Sample(s0_s, r1.xy).xyzw;
  r2.xyz = float3(0.150000006,0.150000006,0.150000006) + -r0.xyz;
  o0.xyz = r1.www * r2.xyz + r0.xyz;
  r0.xyzw = t2.Sample(s0_s, v0.xy).xyzw;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r1.xyz = r1.xyz * float3(1,-1,1) + float3(-0.5,0.5,-0.5);
  r1.z = r1.z + r1.z;
  r2.xyz = r1.zzz * r0.xyz;
  r0.xy = r1.xy * r0.zz;
  r2.xy = r0.xy * float2(0.800000012,0.800000012) + r2.xy;
  r0.x = dot(r2.xyz, r2.xyz);
  r0.x = rsqrt(r0.x);
  r0.yz = r2.xy * r0.xx;
  r1.xyz = v1.xyz * r0.zzz;
  r0.x = r2.z * r0.x;
  r1.xyz = v3.xyz * r0.yyy + r1.xyz;
  r0.xyz = v2.xyz * r0.xxx + r1.xyz;
  r1.x = cmp(0 >= (uint)v4.x);
  if (r1.x != 0) {
    r1.x = dot(v2.xyz, r0.xyz);
    r1.xyz = v2.xyz * r1.xxx;
    r0.xyz = -r1.xyz * float3(2,2,2) + r0.xyz;
  }
  r1.x = 0.400000006 + -r0.w;
  r0.w = r1.w * r1.x + r0.w;
  r1.x = 1 + -r0.w;
  r1.yzw = log2(cb4[3].xyz);
  r1.yzw = float3(2.20000005,2.20000005,2.20000005) * r1.yzw;
  r1.yzw = exp2(r1.yzw);
  r1.x = r1.x * cb4[4].x + cb4[5].x;
  r1.xyz = saturate(r1.yzw * r1.xxx);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
  o2.xyz = exp2(r1.xyz);
  r1.x = dot(r0.xyz, r0.xyz);
  r1.x = rsqrt(r1.x);
  r0.xyz = r1.xxx * r0.xyz;
  r1.x = max(abs(r0.x), abs(r0.y));
  r1.x = max(r1.x, abs(r0.z));
  r1.yz = cmp(abs(r0.zy) < r1.xx);
  r1.zw = r1.zz ? abs(r0.zy) : abs(r0.zx);
  r1.yz = r1.yy ? r1.zw : abs(r0.yx);
  r1.w = cmp(r1.z < r1.y);
  r2.xy = r1.ww ? r1.yz : r1.zy;
  r2.z = r2.y / r2.x;
  r0.xyz = r0.xyz / r1.xxx;
  r1.x = t13.SampleLevel(s13_s, r2.xz, 0).x;
  r0.xyz = r1.xxx * r0.xyz;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = cb4[6].x;
  o1.w = r0.w;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}