// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);




// 3Dmigoto declarations
#define cmp -


#include "./object_pixel.hlsli"

void main(
  float4 v0 : TEXCOORD0,
  float3 v1 : TEXCOORD1,
  float4 motion_position : SV_Position,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v2 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = t0.Sample(s0_s, v0.xy).w;
  r0.y = dot(v1.xyz, v1.xyz);
  r0.y = rsqrt(r0.y);
  r0.yzw = v1.xyz * r0.yyy;
  r1.x = cmp(0 >= (uint)v2.x);
  if (r1.x != 0) {
    r1.x = dot(v1.xyz, r0.yzw);
    r1.xyz = v1.xyz * r1.xxx;
    r0.yzw = -r1.xyz * float3(2,2,2) + r0.yzw;
  }
  r1.x = dot(r0.yzw, r0.yzw);
  r1.x = rsqrt(r1.x);
  r0.yzw = r1.xxx * r0.yzw;
  r1.x = max(abs(r0.y), abs(r0.z));
  r1.x = max(r1.x, abs(r0.w));
  r1.yz = cmp(abs(r0.wz) < r1.xx);
  r1.zw = r1.zz ? abs(r0.wz) : abs(r0.wy);
  r1.yz = r1.yy ? r1.zw : abs(r0.zy);
  r1.w = cmp(r1.z < r1.y);
  r2.xy = r1.ww ? r1.yz : r1.zy;
  r2.z = r2.y / r2.x;
  r0.yzw = r0.yzw / r1.xxx;
  r1.x = t13.SampleLevel(s13_s, r2.xz, 0).x;
  r0.yzw = r1.xxx * r0.yzw;
  o1.xyz = r0.yzw * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.xyz = r0.xxx;
  o0.w = 0;
  o1.w = 0.0500000007;
  o2.xyzw = float4(1,1,1,0);
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}