// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 20:46:48 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2DArray<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[13];
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
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v1.xy;
  r0.z = cb4[0].x;
  r0.xy = t0.Sample(s0_s, r0.xyz).xy;
  r0.zw = cb4[2].xx * v1.xy;
  r1.xy = floor(r0.zw);
  r1.y = reversebits((uint)r1.y);
  r1.z = (int)r1.y + (int)r1.x;
  r1.w = (uint)r1.z >> 13;
  r1.z = (int)r1.z ^ (int)r1.w;
  r1.w = (int)r1.z * (int)r1.z;
  r1.w = mad((int)r1.w, 0x0000ec4d, 0x0131071f);
  r1.z = mad((int)r1.z, (int)r1.w, 0x5208dd0d);
  r1.z = (int)r1.z & 0x7fffffff;
  r1.z = (int)r1.z;
  r2.xy = cb4[2].xx * v1.xy + float2(-1,-1);
  r2.xy = floor(r2.xy);
  r1.y = (int)r1.y + (int)r2.x;
  r1.w = (uint)r1.y >> 13;
  r1.y = (int)r1.y ^ (int)r1.w;
  r1.w = (int)r1.y * (int)r1.y;
  r1.w = mad((int)r1.w, 0x0000ec4d, 0x0131071f);
  r1.y = mad((int)r1.y, (int)r1.w, 0x5208dd0d);
  r1.y = (int)r1.y & 0x7fffffff;
  r1.w = reversebits((uint)r2.y);
  r1.x = (int)r1.w + (int)r1.x;
  r2.y = (uint)r1.x >> 13;
  r1.x = (int)r1.x ^ (int)r2.y;
  r2.y = (int)r1.x * (int)r1.x;
  r2.y = mad((int)r2.y, 0x0000ec4d, 0x0131071f);
  r1.x = mad((int)r1.x, (int)r2.y, 0x5208dd0d);
  r1.x = (int)r1.x & 0x7fffffff;
  r1.xy = (int2)r1.xy;
  r1.xz = float2(4.65661287e-010,4.65661287e-010) * r1.xz;
  r1.w = (int)r1.w + (int)r2.x;
  r2.x = (uint)r1.w >> 13;
  r1.w = (int)r1.w ^ (int)r2.x;
  r2.x = (int)r1.w * (int)r1.w;
  r2.x = mad((int)r2.x, 0x0000ec4d, 0x0131071f);
  r1.w = mad((int)r1.w, (int)r2.x, 0x5208dd0d);
  r1.w = (int)r1.w & 0x7fffffff;
  r1.w = (int)r1.w;
  r0.zw = frac(r0.zw);
  r0.zw = float2(1,1) + -r0.zw;
  r2.xy = r0.zw * r0.zw;
  r0.zw = r2.xy * r0.zw;
  r2.xy = float2(3,3) * r2.xy;
  r0.zw = r0.zw * float2(-2,-2) + r2.xy;
  r1.y = r1.y * 4.65661287e-010 + -r1.z;
  r1.y = r0.z * r1.y + r1.z;
  r1.z = r1.w * 4.65661287e-010 + -r1.x;
  r0.z = r0.z * r1.z + r1.x;
  r0.z = r0.z + -r1.y;
  r0.z = r0.w * r0.z + r1.y;
  r0.z = -0.5 + r0.z;
  r0.z = cb4[1].x * r0.z;
  r0.w = 1 + -r0.x;
  sincos(cb4[3].x, r1.x, r2.x);
  r1.xy = v1.yx * r1.xx;
  r3.x = v1.x * r2.x + -r1.x;
  r3.y = v1.y * r2.x + r1.y;
  r1.xy = cb4[4].xx * r3.xy;
  r1.xy = r0.zz * r0.ww + r1.xy;
  r1.xyzw = t1.Sample(s0_s, r1.xy).xyzw;
  r0.x = r0.x * 2 + r1.w;
  r0.x = saturate(-1 + r0.x);
  r2.xy = cmp(cb2[18].xy != float2(0,0));
  if (r2.x != 0) {
    r0.z = -0.00999999978 + r0.x;
    r0.z = cmp(r0.z < 0);
    if (r0.z != 0) discard;
  }
  if (r2.y != 0) {
    r2.xyzw = float4(16,16,16,16) * v4.xyxy;
    r2.xyzw = cmp(r2.xyzw >= -r2.zwzw);
    r2.xyzw = r2.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r2.zw = v4.xy * r2.zw;
    r2.zw = frac(r2.zw);
    r2.xy = r2.xy * r2.zw;
    r2.xy = (int2)r2.xy;
    r2.zw = float2(0,0);
    r0.z = t18.Load(r2.xyz).x;
    r0.z = r0.z * v0.x + v0.y;
    r0.z = cmp(r0.z < 0);
    if (r0.z != 0) discard;
  }
  r2.xyz = t2.Sample(s0_s, v1.xy).xyz;
  r3.xyz = cb4[6].xyz + -r2.xyz;
  r2.xyz = cb4[7].xxx * r3.xyz + r2.xyz;
  r3.xyz = cb4[8].xyz + float3(-1,-1,-1);
  r3.xyz = r0.yyy * r3.xyz + float3(1,1,1);
  r4.xyz = r3.xyz * r2.xyz;
  r0.y = r0.w * 2 + r1.w;
  r0.y = saturate(-1 + r0.y);
  r0.y = r0.y * r0.y;
  r5.xyz = -cb4[5].xyz + float3(1,1,1);
  r5.xyz = r1.www * r5.xyz + cb4[5].xyz;
  r2.xyz = -r2.xyz * r3.xyz + cb4[9].xyz;
  r0.yzw = r0.yyy * r2.xyz + r4.xyz;
  o0.xyz = r5.xyz * r0.yzw;
  r0.yzw = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.x = cb4[10].x;
  r1.y = 2;
  r0.yz = r1.xx * r0.yz;
  r0.yz = r0.yz + r0.yz;
  r1.xzw = v2.xyz * r0.zzz;
  r0.z = r1.y * r0.w + -1;
  r0.z = cb4[10].x * r0.z + 1;
  r2.xy = v1.zw;
  r2.z = v2.w;
  r1.xyz = v3.xyz * r0.yyy + r1.xzw;
  r0.yzw = r2.xyz * r0.zzz + r1.xyz;
  r1.x = cmp(0 >= (uint)v5.x);
  if (r1.x != 0) {
    r1.x = dot(r2.xyz, r0.yzw);
    r1.xyz = r2.xyz * r1.xxx;
    r0.yzw = -r1.xyz * float3(2,2,2) + r0.yzw;
  }
  r0.x = 1 + -r0.x;
  r1.x = cb4[12].x + -cb4[11].x;
  o0.w = r0.x * r1.x + cb4[11].x;
  r0.x = dot(r0.yzw, r0.yzw);
  r0.x = rsqrt(r0.x);
  r0.xyz = r0.yzw * r0.xxx;
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
  o1.w = 0.5;
  o2.xyzw = float4(0,0,0,1);
  WriteObjectMotion(v4, previous_clip, motion_history, object_motion, object_depth);
  return;
}