// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t12 : register(t12);

TextureCube<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s12_s : register(s12);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[1];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[19];
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
  float3 v3 : TEXCOORD3,
  float4 v4 : SV_Position0,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v5 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = cmp(cb2[18].yzw != float3(0,0,0));
  if (r0.x != 0) {
    r1.xyzw = float4(16,16,16,16) * v4.xyxy;
    r1.xyzw = cmp(r1.xyzw >= -r1.zwzw);
    r1.xyzw = r1.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r0.xw = v4.xy * r1.zw;
    r0.xw = frac(r0.xw);
    r0.xw = r1.xy * r0.xw;
    r1.xy = (int2)r0.xw;
    r1.zw = float2(0,0);
    r0.x = t18.Load(r1.xyz).x;
    r0.x = r0.x * v1.x + v1.y;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  if (r0.y != 0) {
    r0.x = t12.Sample(s12_s, v2.xy).x;
    r0.x = r0.x * v1.z + v1.w;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  if (r0.z != 0) {
    r0.x = dot(v0.xyz, v0.xyz);
    r0.x = -1 + r0.x;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  r0.xyz = cb1[8].xyz + -v3.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r1.x = v0.w;
  r1.yz = v2.zw;
  r0.w = dot(r0.xyz, r1.xyz);
  r0.w = r0.w + r0.w;
  r0.xyz = -r0.www * r1.xyz + r0.xyz;
  r0.xyz = -r0.xyz;
  r0.xyz = t0.Sample(s0_s, r0.xyz).xyz;
  o0.xyz = r0.xyz * float3(0.449999988,0.449999988,0.449999988) + float3(0.300784886,0.295686305,0.295686305);
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r1.xyz * r0.xxx;
  r0.w = cmp(0 >= (uint)v5.x);
  if (r0.w != 0) {
    r0.w = dot(r1.xyz, r0.xyz);
    r1.xyz = r1.xyz * r0.www;
    r0.xyz = -r1.xyz * float3(2,2,2) + r0.xyz;
  }
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
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
  o0.w = 0.550000012;
  o1.w = cb4[0].x;
  o2.xyzw = float4(0.325489998,0.305882007,0.274509996,0);
  WriteObjectMotion(v4, previous_clip, motion_history, object_motion, object_depth);
  return;
}