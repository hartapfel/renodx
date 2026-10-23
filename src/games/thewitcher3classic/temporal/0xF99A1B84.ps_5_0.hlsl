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
  float4 cb4[14];
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
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float4 v5 : TEXCOORD5,
  float3 v6 : TEXCOORD6,
  float4 v7 : SV_Position0,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v8 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = cmp(cb2[18].yzw != float3(0,0,0));
  if (r0.x != 0) {
    r1.xyzw = float4(16,16,16,16) * v7.xyxy;
    r1.xyzw = cmp(r1.xyzw >= -r1.zwzw);
    r1.xyzw = r1.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r0.xw = v7.xy * r1.zw;
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
    r0.x = t12.Sample(s12_s, v3.xy).x;
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
  r0.y = v2.w;
  r1.xyz = t0.Sample(s0_s, r0.xy).yxz;
  r0.zw = float2(-0.5,-1) + r1.zy;
  r0.z = r0.z + r0.z;
  r0.z = cb4[0].x * abs(r0.z);
  r1.yz = cb4[1].xy * r0.xy;
  r2.x = -abs(cb4[2].x) + 1;
  r2.y = cb4[2].x;
  r3.x = dot(r2.xy, r1.yz);
  r2.z = -cb4[2].x;
  r3.y = dot(r2.zx, r1.yz);
  r2.xyzw = t1.Sample(s0_s, r3.xy).xyzw;
  r1.y = 0.25 * r0.z;
  r2.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r2.wxyz;
  r1.y = r2.x * r1.y;
  r3.xyzw = t2.Sample(s0_s, r0.xy).xyzw;
  r4.xyz = cb1[8].xyz + -v5.xyz;
  r0.x = dot(r4.xyz, r4.xyz);
  r0.x = sqrt(r0.x);
  r0.x = saturate(cb4[5].x + -r0.x);
  r0.y = r3.w * cb4[3].x + cb4[4].x;
  r4.xy = r0.zz * r0.xx;
  r0.y = saturate(r4.y * r1.y + r0.y);
  r1.zw = r0.xx * r1.yy + cb4[6].xz;
  r0.z = cmp(0 < cb4[7].x);
  if (r0.z != 0) {
    r0.z = r1.z + r1.w;
    r5.xy = r1.zw / r0.zz;
    r5.xy = float2(-0.300000012,-0.300000012) + r5.xy;
    r5.xy = saturate(float2(1.42857146,1.42857146) * r5.xy);
    r0.z = r5.x + r5.y;
    r0.z = r5.y / r0.z;
    r2.x = 1 + -r0.z;
    r5.xyzw = cb2[11].zyxw * r0.zzzz;
    r6.xyzw = cb2[12].zyxw * r0.zzzz;
    r7.xyzw = cb2[13].zyxw * r0.zzzz;
    r5.xyzw = r2.xxxx * cb2[7].xyzw + r5.xyzw;
    r6.xyzw = r2.xxxx * cb2[8].xyzw + r6.xyzw;
    r7.xyzw = r2.xxxx * cb2[9].xyzw + r7.xyzw;
  } else {
    r0.z = cmp(r1.z >= r1.w);
    r5.xyzw = r0.zzzz ? cb2[7].xyzw : cb2[11].zyxw;
    r6.xyzw = r0.zzzz ? cb2[8].xyzw : cb2[12].zyxw;
    r7.xyzw = r0.zzzz ? cb2[9].xyzw : cb2[13].zyxw;
  }
  r0.z = cmp(0 < cb4[8].x);
  if (r0.z != 0) {
    r0.z = r0.x * r1.y + cb4[6].y;
    r2.x = min(r0.z, r1.w);
    r2.x = min(r2.x, r1.z);
    r0.z = max(r0.z, r1.w);
    r0.z = max(r1.z, r0.z);
    r1.z = r0.z + -r2.x;
    r0.z = r1.z / r0.z;
    r0.z = -0.100000001 + r0.z;
    r0.z = saturate(5 * r0.z);
    r1.x = r1.x * r0.z;
  }
  r8.xyzw = r0.xxxx * r1.yyyy + cb4[6].xyzw;
  r5.x = dot(r8.xyzw, r5.xyzw);
  r5.y = dot(r8.xyzw, r6.xyzw);
  r5.z = dot(r8.xyzw, r7.xyzw);
  r1.yzw = r5.xyz + -r8.xyz;
  r1.xyz = r1.xxx * r1.yzw + r8.xyz;
  r0.x = saturate(cb4[9].x);
  r0.x = r0.x * r0.w + 1;
  r0.xzw = r1.xyz * r0.xxx;
  r1.x = max(r0.z, r0.w);
  r1.x = max(r1.x, r0.x);
  r1.x = cmp(0.219999999 < r1.x);
  r1.x = r1.x ? -0.300000012 : -0.149999976;
  r1.x = v2.z * r1.x + 1;
  o0.xyz = r1.xxx * r0.xzw;
  r0.xzw = float3(-0.5,-0.5,-0.5) + r3.xyz;
  r0.xzw = r0.xzw + r0.xzw;
  r4.z = 2;
  r1.xyz = r4.xyz * r2.yzw;
  r0.x = dot(r0.wwx, r1.xxz);
  r0.z = dot(r0.wwz, r1.yyz);
  r0.w = r1.z * r0.w;
  r1.xyz = v4.xyz * r0.zzz;
  r2.xy = v3.zw;
  r2.z = v4.w;
  r1.xyz = v6.xyz * r0.xxx + r1.xyz;
  r0.xzw = r2.xyz * r0.www + r1.xyz;
  r1.x = cmp(0 >= (uint)v8.x);
  if (r1.x != 0) {
    r1.x = dot(r2.xyz, r0.xzw);
    r1.xyz = r2.xyz * r1.xxx;
    r0.xzw = -r1.xyz * float3(2,2,2) + r0.xzw;
  }
  r1.x = 1 + -r0.y;
  r1.yzw = log2(cb4[10].xyz);
  r1.yzw = float3(2.20000005,2.20000005,2.20000005) * r1.yzw;
  r1.yzw = exp2(r1.yzw);
  r1.x = r1.x * cb4[11].x + cb4[12].x;
  r1.xyz = saturate(r1.yzw * r1.xxx);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r1.w = max(r1.y, r1.z);
  r1.w = max(r1.x, r1.w);
  r1.w = cmp(0.200000003 < r1.w);
  r2.xyz = r1.www ? r1.xyz : float3(0.119999997,0.119999997,0.119999997);
  r2.xyz = r2.xyz + -r1.xyz;
  o2.xyz = v2.zzz * r2.xyz + r1.xyz;
  r1.x = cmp(r0.y < 0.330000013);
  r1.y = 0.949999988 * r0.y;
  r1.x = r1.x ? r1.y : 0.330000013;
  r1.x = r1.x + -r0.y;
  o1.w = v2.z * r1.x + r0.y;
  r0.y = dot(r0.xzw, r0.xzw);
  r0.y = rsqrt(r0.y);
  r0.xyz = r0.xzw * r0.yyy;
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
  o0.w = cb4[13].x;
  o2.w = 0;
  WriteObjectMotion(v7, previous_clip, motion_history, object_motion, object_depth);
  return;
}