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
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = t0.Sample(s0_s, v0.xy).xyz;
  r0.w = dot(v1.xyz, v1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v1.xyz * r0.www;
  r0.w = cmp(0 >= (uint)v2.x);
  if (r0.w != 0) {
    r0.w = dot(v1.xyz, r1.xyz);
    r2.xyz = v1.xyz * r0.www;
    r1.xyz = -r2.xyz * float3(2,2,2) + r1.xyz;
  }
  r0.w = dot(r1.xyz, r1.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r1.xyz * r0.www;
  r0.w = max(abs(r1.x), abs(r1.y));
  r0.w = max(abs(r1.z), r0.w);
  r2.xy = cmp(abs(r1.zy) < r0.ww);
  r2.yz = r2.yy ? abs(r1.zy) : abs(r1.zx);
  r2.xy = r2.xx ? r2.yz : abs(r1.yx);
  r1.w = cmp(r2.y < r2.x);
  r2.xy = r1.ww ? r2.xy : r2.yx;
  r2.z = r2.y / r2.x;
  r1.xyz = r1.xyz / r0.www;
  r0.w = t13.SampleLevel(s13_s, r2.xz, 0).x;
  r1.xyz = r1.xyz * r0.www;
  o1.xyz = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.xyz = r0.xyz;
  o0.w = 0;
  o1.w = 1;
  o2.xyzw = float4(0,0,0,0);
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}