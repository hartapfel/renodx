// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s12_s : register(s12);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[3];
}

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
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v0.w;
  r0.y = v2.w;
  r1.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r2.xyzw = cmp(cb2[18].xyzw != float4(0,0,0,0));
  if (r2.x != 0) {
    r0.z = -0.330000013 + r1.w;
    r0.z = cmp(r0.z < 0);
    if (r0.z != 0) discard;
  }
  if (r2.y != 0) {
    r3.xyzw = float4(16,16,16,16) * v6.xyxy;
    r3.xyzw = cmp(r3.xyzw >= -r3.zwzw);
    r3.xyzw = r3.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r0.zw = v6.xy * r3.zw;
    r0.zw = frac(r0.zw);
    r0.zw = r3.xy * r0.zw;
    r3.xy = (int2)r0.zw;
    r3.zw = float2(0,0);
    r0.z = t18.Load(r3.xyz).x;
    r0.z = r0.z * v1.x + v1.y;
    r0.z = cmp(r0.z < 0);
    if (r0.z != 0) discard;
  }
  if (r2.z != 0) {
    r0.z = t12.Sample(s12_s, v3.xy).x;
    r0.z = r0.z * v1.z + v1.w;
    r0.z = cmp(r0.z < 0);
    if (r0.z != 0) discard;
  }
  if (r2.w != 0) {
    r0.z = dot(v0.xyz, v0.xyz);
    r0.z = -1 + r0.z;
    r0.z = cmp(r0.z < 0);
    if (r0.z != 0) discard;
  }
  r2.xyzw = t1.Sample(s0_s, r0.xy).xyzw;
  r0.z = r1.x + r1.y;
  r0.z = r0.z + r1.z;
  r0.w = 0.333299994 * r0.z;
  r1.w = cb4[1].x + -1;
  r1.w = 0.5 * r1.w;
  r3.x = saturate(r1.w);
  r0.z = r0.z * -0.666599989 + 1;
  r0.z = r3.x * r0.z + r0.w;
  r3.xyz = cb4[0].xyz * r1.xyz;
  r3.xyz = saturate(float3(1.5,1.5,1.5) * r3.xyz);
  r0.z = saturate(r0.z * abs(r1.w));
  r3.xyz = r3.xyz + -r1.xyz;
  r1.xyz = r0.zzz * r3.xyz + r1.xyz;
  r0.z = max(r1.y, r1.z);
  r0.z = max(r1.x, r0.z);
  r0.z = cmp(0.219999999 < r0.z);
  r0.z = r0.z ? -0.300000012 : -0.149999976;
  r0.z = v2.z * r0.z + 1;
  o0.xyz = r1.xyz * r0.zzz;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r2.xyz;
  r1.xyz = r1.xyz + r1.xyz;
  r2.xyz = v4.xyz * r1.yyy;
  r3.xy = v3.zw;
  r3.z = v4.w;
  r1.xyw = v5.xyz * r1.xxx + r2.xyz;
  r1.xyz = r3.xyz * r1.zzz + r1.xyw;
  r0.z = cmp(0 >= (uint)v7.x);
  if (r0.z != 0) {
    r0.z = dot(r3.xyz, r1.xyz);
    r2.xyz = r3.xyz * r0.zzz;
    r1.xyz = -r2.xyz * float3(2,2,2) + r1.xyz;
  }
  r0.xyz = t2.Sample(s0_s, r0.xy).xyz;
  r0.w = max(r0.y, r0.z);
  r0.w = max(r0.x, r0.w);
  r0.w = cmp(0.200000003 < r0.w);
  r2.xyz = r0.www ? r0.xyz : float3(0.119999997,0.119999997,0.119999997);
  r2.xyz = r2.xyz + -r0.xyz;
  o2.xyz = v2.zzz * r2.xyz + r0.xyz;
  r0.x = cmp(r2.w < 0.330000013);
  r0.y = 0.949999988 * r2.w;
  r0.x = r0.x ? r0.y : 0.330000013;
  r0.x = r0.x + -r2.w;
  o1.w = v2.z * r0.x + r2.w;
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
  o0.w = cb4[2].x;
  o2.w = 0;
  WriteObjectMotion(v6, previous_clip, motion_history, object_motion, object_depth);
  return;
}