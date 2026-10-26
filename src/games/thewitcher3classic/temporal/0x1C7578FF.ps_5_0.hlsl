// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s12_s : register(s12);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[19];
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
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
  r3.x = sqrt(r0.w);
  r3.x = saturate(cb4[3].x + -r3.x);
  r5.xyz = t3.Sample(s0_s, r0.xy).yxz;
  r0.xy = cb4[4].xy * r0.xy;
  r6.x = -abs(cb4[5].x) + 1;
  r6.y = cb4[5].x;
  r7.x = dot(r6.xy, r0.xy);
  r6.z = -cb4[5].x;
  r7.y = dot(r6.zx, r0.xy);
  r6.xyzw = t4.Sample(s0_s, r7.xy).xyzw;
  r6.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r6.wxyz;
  r0.x = 0.5 * r6.x;
  r0.y = cb4[2].x * v2.z;
  r0.y = r0.y * -0.600000024 + cb4[2].x;
  r7.xyz = float3(-0.550000012,-0.5,-1) + r5.zzy;
  r4.w = saturate(2.22222233 * r7.x);
  r5.y = 0.449999988 + -r5.z;
  r5.y = saturate(2.22222233 * r5.y);
  r5.w = r5.y * r0.x;
  r5.w = r0.z * r4.w + r5.w;
  r5.w = r5.w * r3.x;
  r2.w = saturate(r5.w * r0.y + r2.w);
  r5.w = cb4[6].x * r0.y;
  r0.x = r5.y * -r0.x;
  r0.x = -r0.z * r4.w + r0.x;
  r0.x = r0.x * r3.x;
  r0.x = r0.x * r5.w + 1;
  r0.x = max(0, r0.x);
  r8.xyz = log2(r1.xyz);
  r8.xyz = float3(2.20000005,2.20000005,2.20000005) * r8.xyz;
  r1.xyz = exp2(r8.xyz);
  r1.xyzw = r1.xyzw * r0.xxxx;
  r2.xyz = float3(-0.5,-0.5,-0.5) + r2.xyz;
  r2.xyz = r2.xyz + r2.xyz;
  r3.yzw = r3.yzw + r3.yzw;
  r6.xyz = r6.yzw + r6.yzw;
  r0.x = r0.y * r3.x;
  r0.y = -0.0500000007 + abs(r7.y);
  r0.y = saturate(2.22222233 * r0.y);
  r0.x = r0.x * r0.y;
  r0.y = cmp(0.5 < r5.z);
  r3.xyz = r0.yyy ? r3.yzw : r6.xyz;
  r5.yzw = r3.zzz * r2.xyz;
  r0.xy = r3.xy * r0.xx;
  r5.yz = r0.xy * r2.zz + r5.yz;
  r0.x = dot(r5.yzw, r5.yzw);
  r0.x = rsqrt(r0.x);
  r0.xyz = r5.yzw * r0.xxx;
  r2.xyz = v4.xyz * r0.yyy;
  r3.xy = v3.zw;
  r3.z = v4.w;
  r2.xyz = v6.xyz * r0.xxx + r2.xyz;
  r0.xyz = r3.xyz * r0.zzz + r2.xyz;
  r0.w = rsqrt(r0.w);
  r2.xyz = r4.xyz * r0.www;
  r0.w = dot(r0.xyz, r2.xyz);
  r0.w = saturate(1 + -r0.w);
  r0.w = log2(r0.w);
  r0.w = cb4[7].x * r0.w;
  r0.w = exp2(r0.w);
  r2.x = cmp(0 < cb4[11].x);
  if (r2.x != 0) {
    r2.xyz = log2(r1.xzy);
    r2.xyz = float3(0.454544991,0.454544991,0.454544991) * r2.xyz;
    r2.xyz = exp2(r2.xyz);
    r2.xyz = r0.www * cb4[8].xxx + r2.xyz;
    r3.w = r2.x + r2.y;
    r4.xy = r2.xy / r3.ww;
    r4.xy = float2(-0.300000012,-0.300000012) + r4.xy;
    r4.xy = saturate(float2(1.42857146,1.42857146) * r4.xy);
    r3.w = cmp(0 < cb4[9].x);
    if (r3.w != 0) {
      r3.w = r4.x + r4.y;
      r3.w = r4.y / r3.w;
      r4.x = 1 + -r3.w;
      r6.xyzw = cb2[11].zyxw * r3.wwww;
      r8.xyzw = cb2[12].zyxw * r3.wwww;
      r9.xyzw = cb2[13].zyxw * r3.wwww;
      r6.xyzw = r4.xxxx * cb2[7].xyzw + r6.xyzw;
      r8.xyzw = r4.xxxx * cb2[8].xyzw + r8.xyzw;
      r4.xyzw = r4.xxxx * cb2[9].xyzw + r9.xyzw;
    } else {
      r3.w = cmp(r2.x >= r2.y);
      r6.xyzw = r3.wwww ? cb2[7].xyzw : cb2[11].zyxw;
      r8.xyzw = r3.wwww ? cb2[8].xyzw : cb2[12].zyxw;
      r4.xyzw = r3.wwww ? cb2[9].xyzw : cb2[13].zyxw;
    }
    r3.w = min(r2.z, r2.y);
    r3.w = min(r3.w, r2.x);
    r2.y = max(r2.z, r2.y);
    r2.x = max(r2.x, r2.y);
    r2.y = cmp(0 < cb4[10].x);
    if (r2.y != 0) {
      r2.y = r2.x + -r3.w;
      r2.x = r2.y / r2.x;
      r2.x = -0.100000001 + r2.x;
      r2.x = saturate(5 * r2.x);
      r5.x = r5.x * r2.x;
    }
    r2.xyz = log2(r1.xyz);
    r2.xyz = float3(0.454544991,0.454544991,0.454544991) * r2.xyz;
    r1.xyz = exp2(r2.xyz);
    r9.xyzw = r0.wwww * cb4[8].xxxx + r1.xyzw;
    r2.x = dot(r9.xyzw, r6.xyzw);
    r2.y = dot(r9.xyzw, r8.xyzw);
    r2.z = dot(r9.xyzw, r4.xyzw);
    r2.xyz = r2.xyz + -r9.xyz;
    r2.xyz = r5.xxx * r2.xyz + r9.xyz;
  } else {
    r1.xyz = log2(r1.xyz);
    r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
    r1.xyz = exp2(r1.xyz);
    r2.xyz = r0.www * cb4[8].xxx + r1.xyz;
  }
  r0.w = saturate(cb4[12].x);
  r0.w = r0.w * r7.z + 1;
  r1.xyz = r2.xyz * r0.www;
  r0.w = max(r1.y, r1.z);
  r0.w = max(r1.x, r0.w);
  r0.w = cmp(0.219999999 < r0.w);
  r0.w = r0.w ? -0.300000012 : -0.149999976;
  r0.w = v2.z * r0.w + 1;
  o0.xyz = r1.xyz * r0.www;
  r0.w = cmp(0 >= (uint)v8.x);
  if (r0.w != 0) {
    r0.w = dot(r3.xyz, r0.xyz);
    r1.xyz = r3.xyz * r0.www;
    r0.xyz = -r1.xyz * float3(2,2,2) + r0.xyz;
  }
  r0.w = 1 + -r2.w;
  r1.xyz = log2(cb4[13].xyz);
  r1.xyz = float3(2.20000005,2.20000005,2.20000005) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.w = r0.w * cb4[14].x + cb4[15].x;
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
  r0.w = cb4[17].x + -cb4[16].x;
  r0.w = saturate(r2.w * r0.w + cb4[16].x);
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
  o0.w = cb4[18].x;
  o2.w = 0;
  WriteObjectMotion(v7, previous_clip, motion_history, object_motion, object_depth);
  return;
}