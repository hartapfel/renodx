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
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  float4 v6 : SV_Position0,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v7 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = cmp(cb2[18].yzw != float3(0,0,0));
  if (r0.x != 0) {
    r1.xyzw = float4(16,16,16,16) * v6.xyxy;
    r1.xyzw = cmp(r1.xyzw >= -r1.zwzw);
    r1.xyzw = r1.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r0.xw = v6.xy * r1.zw;
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
    r0.x = t12.Sample(s12_s, v2.zw).x;
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
  r0.x = v0.w;
  r0.y = v3.w;
  r0.z = v4.w;
  r0.xyz = cb1[8].xyz + -r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.x = dot(v4.xyz, r0.xyz);
  r0.x = saturate(1 + -r0.x);
  r0.y = r0.x * r0.x;
  r0.x = r0.x * r0.y;
  r0.yzw = t0.Sample(s0_s, v2.xy).xyz;
  r0.yzw = float3(1,0.964706004,0.925490022) * r0.yzw;
  o0.xyz = r0.xxx * float3(0.200000003,0.200000003,0.200000003) + r0.yzw;
  r0.xyz = t1.Sample(s0_s, v2.xy).xyw;
  r0.xyz = r0.xyz * float3(2,2,2) + float3(-1,-1,-1);
  r0.x = r0.x * r0.z;
  r0.z = -r0.x * r0.x + 1;
  r0.z = -r0.y * r0.y + r0.z;
  r0.z = max(0, r0.z);
  r0.z = rsqrt(r0.z);
  r0.z = 1 / r0.z;
  r1.xyz = v3.xyz * r0.yyy;
  r0.xyw = v5.xyz * r0.xxx + r1.xyz;
  r0.xyz = v4.xyz * r0.zzz + r0.xyw;
  r0.w = cmp(0 >= (uint)v7.x);
  if (r0.w != 0) {
    r0.w = dot(v4.xyz, r0.xyz);
    r1.xyz = v4.xyz * r0.www;
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
  o0.w = 0;
  o1.w = 0.5;
  o2.xyzw = float4(0,0,0,0);
  WriteObjectMotion(v6, previous_clip, motion_history, object_motion, object_depth);
  return;
}