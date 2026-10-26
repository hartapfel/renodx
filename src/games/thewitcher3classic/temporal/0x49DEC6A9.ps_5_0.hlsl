// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[19];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[1];
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
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = cmp(cb2[18].xy != float2(0,0));
  if (r0.x != 0) {
    r0.x = t0.Sample(s0_s, v1.xy).w;
    r0.x = 0.699999988 + r0.x;
    r0.x = saturate(floor(r0.x));
    r1.xyz = -cb1[8].xyz + v3.xyz;
    r0.z = dot(r1.xyz, r1.xyz);
    r0.z = rsqrt(r0.z);
    r1.xyz = r1.xyz * r0.zzz;
    r2.xyz = cb2[0].xyz + -cb1[8].xyz;
    r0.z = dot(r2.xyz, r2.xyz);
    r0.w = rsqrt(r0.z);
    r2.xyz = r2.xyz * r0.www;
    r0.w = 1.5 * cb2[0].w;
    r1.x = dot(r1.xyz, r2.xyz);
    r0.w = r0.w / r0.z;
    r0.w = 1 + -r0.w;
    r1.x = r1.x + -r0.w;
    r0.z = cb2[0].w / r0.z;
    r0.z = -r0.w + -r0.z;
    r2.xz = v2.yy * float2(0.800000012,0.800000012) + -v2.xx;
    r2.yw = v2.yy;
    r3.xyzw = float4(4,4,6,-6) * cb0[0].xxxx;
    r2.xyzw = r2.xyzw * float4(20,20,20,20) + r3.xyzw;
    r1.yz = floor(r2.xy);
    r0.w = reversebits((uint)r1.z);
    r1.z = (int)r0.w + (int)r1.y;
    r1.w = (uint)r1.z >> 13;
    r1.z = (int)r1.z ^ (int)r1.w;
    r1.w = (int)r1.z * (int)r1.z;
    r1.w = mad((int)r1.w, 0x0000ec4d, 0x0131071f);
    r1.z = mad((int)r1.z, (int)r1.w, 0x5208dd0d);
    r1.z = (int)r1.z & 0x7fffffff;
    r1.z = (int)r1.z;
    r3.xy = float2(-1,-1) + r2.xy;
    r3.xy = floor(r3.xy);
    r0.w = (int)r0.w + (int)r3.x;
    r1.w = (uint)r0.w >> 13;
    r0.w = (int)r0.w ^ (int)r1.w;
    r1.w = (int)r0.w * (int)r0.w;
    r1.w = mad((int)r1.w, 0x0000ec4d, 0x0131071f);
    r0.w = mad((int)r0.w, (int)r1.w, 0x5208dd0d);
    r0.w = (int)r0.w & 0x7fffffff;
    r0.w = (int)r0.w;
    r1.w = reversebits((uint)r3.y);
    r1.y = (int)r1.w + (int)r1.y;
    r3.y = (uint)r1.y >> 13;
    r1.y = (int)r1.y ^ (int)r3.y;
    r3.y = (int)r1.y * (int)r1.y;
    r3.y = mad((int)r3.y, 0x0000ec4d, 0x0131071f);
    r1.y = mad((int)r1.y, (int)r3.y, 0x5208dd0d);
    r1.y = (int)r1.y & 0x7fffffff;
    r1.y = (int)r1.y;
    r1.yz = float2(4.65661287e-010,4.65661287e-010) * r1.yz;
    r1.w = (int)r1.w + (int)r3.x;
    r3.x = (uint)r1.w >> 13;
    r1.w = (int)r1.w ^ (int)r3.x;
    r3.x = (int)r1.w * (int)r1.w;
    r3.x = mad((int)r3.x, 0x0000ec4d, 0x0131071f);
    r1.w = mad((int)r1.w, (int)r3.x, 0x5208dd0d);
    r1.w = (int)r1.w & 0x7fffffff;
    r1.w = (int)r1.w;
    r2.xy = frac(r2.xy);
    r2.xy = float2(1,1) + -r2.xy;
    r3.xy = r2.xy * r2.xy;
    r2.xy = r3.xy * r2.xy;
    r3.xy = float2(3,3) * r3.xy;
    r2.xy = r2.xy * float2(-2,-2) + r3.xy;
    r0.w = r0.w * 4.65661287e-010 + -r1.z;
    r0.w = r2.x * r0.w + r1.z;
    r1.z = r1.w * 4.65661287e-010 + -r1.y;
    r1.y = r2.x * r1.z + r1.y;
    r1.y = r1.y + -r0.w;
    r0.w = r2.y * r1.y + r0.w;
    r1.yz = r0.ww * float2(1,-1) + r2.zw;
    r2.xy = floor(r1.yz);
    r0.w = reversebits((uint)r2.y);
    r1.w = (int)r0.w + (int)r2.x;
    r2.y = (uint)r1.w >> 13;
    r1.w = (int)r1.w ^ (int)r2.y;
    r2.y = (int)r1.w * (int)r1.w;
    r2.y = mad((int)r2.y, 0x0000ec4d, 0x0131071f);
    r1.w = mad((int)r1.w, (int)r2.y, 0x5208dd0d);
    r1.w = (int)r1.w & 0x7fffffff;
    r1.w = (int)r1.w;
    r1.w = 4.65661287e-010 * r1.w;
    r2.yz = float2(-1,-1) + r1.yz;
    r2.yz = floor(r2.yz);
    r0.w = (int)r0.w + (int)r2.y;
    r2.w = (uint)r0.w >> 13;
    r0.w = (int)r0.w ^ (int)r2.w;
    r2.w = (int)r0.w * (int)r0.w;
    r2.w = mad((int)r2.w, 0x0000ec4d, 0x0131071f);
    r0.w = mad((int)r0.w, (int)r2.w, 0x5208dd0d);
    r0.w = (int)r0.w & 0x7fffffff;
    r0.w = (int)r0.w;
    r2.z = reversebits((uint)r2.z);
    r2.xy = (int2)r2.zz + (int2)r2.xy;
    r2.zw = (uint2)r2.yx >> int2(13,13);
    r2.xy = (int2)r2.xy ^ (int2)r2.wz;
    r2.zw = (int2)r2.yx * (int2)r2.yx;
    r2.w = mad((int)r2.w, 0x0000ec4d, 0x0131071f);
    r2.x = mad((int)r2.x, (int)r2.w, 0x5208dd0d);
    r2.z = mad((int)r2.z, 0x0000ec4d, 0x0131071f);
    r2.y = mad((int)r2.y, (int)r2.z, 0x5208dd0d);
    r2.xy = (int2)r2.xy & int2(0x7fffffff,0x7fffffff);
    r2.xy = (int2)r2.xy;
    r1.yz = frac(r1.yz);
    r1.yz = float2(1,1) + -r1.yz;
    r2.zw = r1.yz * r1.yz;
    r1.yz = r2.zw * r1.yz;
    r2.xzw = float3(4.65661287e-010,3,3) * r2.xzw;
    r1.yz = r1.yz * float2(-2,-2) + r2.zw;
    r0.w = r0.w * 4.65661287e-010 + -r1.w;
    r0.w = r1.y * r0.w + r1.w;
    r1.w = r2.y * 4.65661287e-010 + -r2.x;
    r1.y = r1.y * r1.w + r2.x;
    r1.y = r1.y + -r0.w;
    r0.w = r1.z * r1.y + r0.w;
    r0.zw = float2(1,-0.5) + r0.zw;
    r0.z = r1.x / r0.z;
    r0.z = r0.w * 0.899999976 + r0.z;
    r0.x = saturate(r0.x * r0.z);
    r0.x = -0.330000013 + r0.x;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  if (r0.y != 0) {
    r0.xyzw = float4(16,16,16,16) * v4.xyxy;
    r0.xyzw = cmp(r0.xyzw >= -r0.zwzw);
    r0.xyzw = r0.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r0.zw = v4.xy * r0.zw;
    r0.zw = frac(r0.zw);
    r0.xy = r0.xy * r0.zw;
    r0.xy = (int2)r0.xy;
    r0.zw = float2(0,0);
    r0.x = t18.Load(r0.xyz).x;
    r0.x = r0.x * v0.x + v0.y;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  r0.xy = v1.zw;
  r0.z = v2.w;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r0.xyz * r0.www;
  r0.w = cmp(0 >= (uint)v5.x);
  if (r0.w != 0) {
    r0.w = dot(r0.xyz, r1.xyz);
    r0.xyz = r0.xyz * r0.www;
    r1.xyz = -r0.xyz * float3(2,2,2) + r1.xyz;
  }
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
  o0.xyzw = float4(0,0,0,0);
  o1.w = 0.5;
  o2.xyzw = float4(0,0,0,0);
  WriteObjectMotion(v4, previous_clip, motion_history, object_motion, object_depth);
  return;
}