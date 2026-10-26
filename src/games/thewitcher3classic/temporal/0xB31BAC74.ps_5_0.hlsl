// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s12_s : register(s12);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[15];
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
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v0.w;
  r0.y = v2.w;
  r1.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r2.xyzw = cmp(cb2[18].xyzw != float4(0,0,0,0));
  if (r2.x != 0) {
    r0.z = -0.699999988 + r1.w;
    r0.z = cmp(r0.z < 0);
    if (r0.z != 0) discard;
  }
  if (r2.y != 0) {
    r3.xyzw = float4(16,16,16,16) * v7.xyxy;
    r3.xyzw = cmp(r3.xyzw >= -r3.zwzw);
    r3.xyzw = r3.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r0.zw = v7.xy * r3.zw;
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
  r0.zw = cb4[0].xy * r0.xy;
  r3.x = -abs(cb4[1].x) + 1;
  r3.y = cb4[1].x;
  r4.x = dot(r3.xy, r0.zw);
  r3.z = -cb4[1].x;
  r4.y = dot(r3.zx, r0.zw);
  r3.xyzw = t2.Sample(s0_s, r4.xy).xyzw;
  r3.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r3.wxyz;
  r0.z = 0.5 * r3.x;
  r4.xyz = cb1[8].xyz + -v5.xyz;
  r0.w = dot(r4.xyz, r4.xyz);
  r0.w = sqrt(r0.w);
  r0.w = saturate(cb4[3].x + -r0.w);
  r4.xyz = t3.Sample(s0_s, r0.xy).yxz;
  r0.xy = float2(-0.550000012,-1) + r4.zy;
  r0.x = saturate(2.22222233 * r0.x);
  r3.x = r0.z * r0.x;
  r3.x = r3.x * r0.w;
  r2.w = saturate(r3.x * cb4[2].x + r2.w);
  r3.x = cb4[4].x * cb4[2].x;
  r0.z = -r0.z * r0.x;
  r0.z = r0.z * r0.w;
  r0.z = r0.z * r3.x + 1;
  r0.z = max(0, r0.z);
  r4.yzw = log2(r1.xyz);
  r4.yzw = float3(2.20000005,2.20000005,2.20000005) * r4.yzw;
  r1.xyz = exp2(r4.yzw);
  r1.xyzw = r1.xyzw * r0.zzzz;
  r0.z = cmp(0 < cb4[7].x);
  if (r0.z != 0) {
    r4.yzw = log2(r1.xzy);
    r4.yzw = float3(0.454544991,0.454544991,0.454544991) * r4.yzw;
    r4.yzw = exp2(r4.yzw);
    r0.z = r4.y + r4.z;
    r5.xy = r4.yz / r0.zz;
    r5.xy = float2(-0.300000012,-0.300000012) + r5.xy;
    r5.xy = saturate(float2(1.42857146,1.42857146) * r5.xy);
    r0.z = cmp(0 < cb4[5].x);
    if (r0.z != 0) {
      r0.z = r5.x + r5.y;
      r0.z = r5.y / r0.z;
      r3.x = 1 + -r0.z;
      r5.xyzw = cb2[11].zyxw * r0.zzzz;
      r6.xyzw = cb2[12].zyxw * r0.zzzz;
      r7.xyzw = cb2[13].zyxw * r0.zzzz;
      r5.xyzw = r3.xxxx * cb2[7].xyzw + r5.xyzw;
      r6.xyzw = r3.xxxx * cb2[8].xyzw + r6.xyzw;
      r7.xyzw = r3.xxxx * cb2[9].xyzw + r7.xyzw;
    } else {
      r0.z = cmp(r4.y >= r4.z);
      r5.xyzw = r0.zzzz ? cb2[7].xyzw : cb2[11].zyxw;
      r6.xyzw = r0.zzzz ? cb2[8].xyzw : cb2[12].zyxw;
      r7.xyzw = r0.zzzz ? cb2[9].xyzw : cb2[13].zyxw;
    }
    r0.z = min(r4.w, r4.z);
    r0.z = min(r4.y, r0.z);
    r3.x = max(r4.w, r4.z);
    r3.x = max(r4.y, r3.x);
    r4.y = cmp(0 < cb4[6].x);
    if (r4.y != 0) {
      r0.z = r3.x + -r0.z;
      r0.z = r0.z / r3.x;
      r0.z = -0.100000001 + r0.z;
      r0.z = saturate(5 * r0.z);
      r4.x = r4.x * r0.z;
    }
    r4.yzw = log2(r1.xyz);
    r4.yzw = float3(0.454544991,0.454544991,0.454544991) * r4.yzw;
    r1.xyz = exp2(r4.yzw);
    r5.x = dot(r1.xyzw, r5.xyzw);
    r5.y = dot(r1.xyzw, r6.xyzw);
    r5.z = dot(r1.xyzw, r7.xyzw);
    r4.yzw = r5.xyz + -r1.xyz;
    r4.xyz = r4.xxx * r4.yzw + r1.xyz;
  } else {
    r1.xyz = log2(r1.xyz);
    r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
    r4.xyz = exp2(r1.xyz);
  }
  r0.z = saturate(cb4[8].x);
  r0.y = r0.z * r0.y + 1;
  r1.xyz = r4.xyz * r0.yyy;
  r0.y = max(r1.y, r1.z);
  r0.y = max(r1.x, r0.y);
  r0.y = cmp(0.219999999 < r0.y);
  r0.y = r0.y ? -0.300000012 : -0.149999976;
  r0.y = v2.z * r0.y + 1;
  o0.xyz = r1.xyz * r0.yyy;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r2.xyz;
  r1.xyz = r1.xyz + r1.xyz;
  r2.xyz = r3.yzw + r3.yzw;
  r0.y = cb4[2].x * r0.w;
  r0.x = r0.y * r0.x;
  r0.yzw = r2.zzz * r1.xyz;
  r1.xy = r0.xx * r2.xy;
  r0.yz = r1.xy * r1.zz + r0.yz;
  r0.x = dot(r0.yzw, r0.yzw);
  r0.x = rsqrt(r0.x);
  r0.xyz = r0.yzw * r0.xxx;
  r1.xyz = v4.xyz * r0.yyy;
  r2.xy = v3.zw;
  r2.z = v4.w;
  r0.xyw = v6.xyz * r0.xxx + r1.xyz;
  r0.xyz = r2.xyz * r0.zzz + r0.xyw;
  r0.w = cmp(0 >= (uint)v8.x);
  if (r0.w != 0) {
    r0.w = dot(r2.xyz, r0.xyz);
    r1.xyz = r2.xyz * r0.www;
    r0.xyz = -r1.xyz * float3(2,2,2) + r0.xyz;
  }
  r0.w = 1 + -r2.w;
  r1.xyz = log2(cb4[9].xyz);
  r1.xyz = float3(2.20000005,2.20000005,2.20000005) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.w = r0.w * cb4[10].x + cb4[11].x;
  r1.xyz = saturate(r1.xyz * r0.www);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.w = max(r1.y, r1.z);
  r0.w = max(r1.x, r0.w);
  r0.w = cmp(0.200000003 < r0.w);
  r2.xyz = r0.www ? r1.xyz : float3(0.119999997,0.119999997,0.119999997);
  r2.xyz = r2.xyz + -r1.xyz;
  o2.xyz = v2.zzz * r2.xyz + r1.xyz;
  r0.w = cb4[13].x + -cb4[12].x;
  r0.w = saturate(r2.w * r0.w + cb4[12].x);
  r1.x = cmp(r0.w < 0.330000013);
  r1.y = 0.949999988 * r0.w;
  r1.x = r1.x ? r1.y : 0.330000013;
  r1.x = r1.x + -r0.w;
  o1.w = v2.z * r1.x + r0.w;
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
  o0.w = cb4[14].x;
  o2.w = 0;
  WriteObjectMotion(v7, previous_clip, motion_history, object_motion, object_depth);
  return;
}