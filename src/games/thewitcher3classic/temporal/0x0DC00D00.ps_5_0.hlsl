// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s12_s : register(s12);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[19];
}




// 3Dmigoto declarations
#define cmp -


#include "./object_pixel.hlsli"

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  float4 v6 : SV_Position0,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v7 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v0.w;
  r0.y = v2.w;
  r0.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r1.xyzw = cmp(cb2[18].xyzw != float4(0,0,0,0));
  if (r1.x != 0) {
    r2.xy = float2(0.5,0.5) + v6.xy;
    r2.xy = float2(0.0625,0.0625) * r2.xy;
    r1.x = t1.Sample(s0_s, r2.xy).x;
    r1.x = cmp(v4.w >= r1.x);
    r2.x = r1.x ? 1.000000 : 0;
    r2.yz = r1.xx ? float2(0,-0) : float2(1,-1);
    r1.x = r2.x + r2.z;
    r1.x = v4.x * r1.x + r2.y;
    r0.w = r0.w * r1.x + -0.330000013;
    r0.w = cmp(r0.w < 0);
    if (r0.w != 0) discard;
  }
  if (r1.y != 0) {
    r2.xyzw = float4(16,16,16,16) * v6.xyxy;
    r2.xyzw = cmp(r2.xyzw >= -r2.zwzw);
    r2.xyzw = r2.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r1.xy = v6.xy * r2.zw;
    r1.xy = frac(r1.xy);
    r1.xy = r2.xy * r1.xy;
    r2.xy = (int2)r1.xy;
    r2.zw = float2(0,0);
    r0.w = t18.Load(r2.xyz).x;
    r0.w = r0.w * v1.x + v1.y;
    r0.w = cmp(r0.w < 0);
    if (r0.w != 0) discard;
  }
  if (r1.z != 0) {
    r0.w = t12.Sample(s12_s, v3.zw).x;
    r0.w = r0.w * v1.z + v1.w;
    r0.w = cmp(r0.w < 0);
    if (r0.w != 0) discard;
  }
  if (r1.w != 0) {
    r0.w = dot(v0.xyz, v0.xyz);
    r0.w = -1 + r0.w;
    r0.w = cmp(r0.w < 0);
    if (r0.w != 0) discard;
  }
  o0.xyz = v2.xyz * r0.xyz;
  r1.xyzw = t0.Sample(s0_s, v3.xy).xyzw;
  r0.x = cmp(0 >= (uint)v7.x);
  if (r0.x != 0) {
    r0.x = dot(v5.xyz, r1.xyz);
    r0.xzw = v5.xyz * r0.xxx;
    r1.xyz = -r0.xzw * float3(2,2,2) + r1.xyz;
  }
  r0.xyz = v2.xyz * r0.yyy;
  o2.xyz = float3(0.100000001,0.100000001,0.100000001) * r0.xyz;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
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
  o0.w = r1.w;
  o1.w = 0.5;
  o2.w = 0;
  WriteObjectMotion(v6, previous_clip, motion_history, object_motion, object_depth);
  return;
}