// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t5 : register(t5);

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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v2.xy).xyzw;
  r1.xyzw = cmp(cb2[18].xyzw != float4(0,0,0,0));
  if (r1.x != 0) {
    r2.xy = float2(5,5) * v2.xy;
    r2.xyz = t1.Sample(s0_s, r2.xy).xyz;
    r1.x = dot(r2.xyz, float3(2,2,2));
    r2.x = cb4[0].x + cb2[0].x;
    r1.x = r2.x * r1.x;
    r1.x = r0.w * r1.x + -0.699999988;
    r1.x = cmp(r1.x < 0);
    if (r1.x != 0) discard;
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
    r1.x = t18.Load(r2.xyz).x;
    r1.x = r1.x * v1.x + v1.y;
    r1.x = cmp(r1.x < 0);
    if (r1.x != 0) discard;
  }
  if (r1.z != 0) {
    r1.x = t12.Sample(s12_s, v2.zw).x;
    r1.x = r1.x * v1.z + v1.w;
    r1.x = cmp(r1.x < 0);
    if (r1.x != 0) discard;
  }
  if (r1.w != 0) {
    r1.x = dot(v0.xyz, v0.xyz);
    r1.x = -1 + r1.x;
    r1.x = cmp(r1.x < 0);
    if (r1.x != 0) discard;
  }
  r1.xyz = t2.Sample(s0_s, v2.xy).yxz;
  r2.xy = cb4[1].xy * v2.xy;
  r3.x = -abs(cb4[2].x) + 1;
  r3.y = cb4[2].x;
  r4.x = dot(r3.xy, r2.xy);
  r3.z = -cb4[2].x;
  r4.y = dot(r3.zx, r2.xy);
  r2.xyzw = t3.Sample(s0_s, r4.xy).xyzw;
  r3.x = v0.w;
  r3.y = v3.w;
  r3.z = v4.w;
  r3.xyz = cb1[8].xyz + -r3.xyz;
  r1.w = dot(r3.xyz, r3.xyz);
  r1.w = sqrt(r1.w);
  r1.w = saturate(cb4[3].x + -r1.w);
  r3.xy = float2(-0.5,-1) + r1.zy;
  r1.y = r3.x + r3.x;
  r1.y = cb4[4].x * abs(r1.y);
  r3.x = r1.w * r1.y;
  r3.z = 0.25 * r3.x;
  r2.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r2.wxyz;
  r2.x = r3.z * r2.x;
  r4.xy = cb4[5].xy * v2.xy;
  r5.x = -abs(cb4[6].x) + 1;
  r5.y = cb4[6].x;
  r6.x = dot(r5.xy, r4.xy);
  r5.z = -cb4[6].x;
  r6.y = dot(r5.zx, r4.xy);
  r4.xyzw = t4.Sample(s0_s, r6.xy).xyzw;
  r4.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r4.wxyz;
  r3.z = r4.x * r3.z;
  r3.w = 1 + -r1.z;
  r2.x = r3.w * r2.x;
  r2.x = r1.z * r3.z + r2.x;
  r5.xy = r1.ww * r2.xx + r0.xz;
  r3.z = cmp(0 < cb4[7].x);
  if (r3.z != 0) {
    r3.z = r5.x + r5.y;
    r5.zw = r5.xy / r3.zz;
    r5.zw = float2(-0.300000012,-0.300000012) + r5.zw;
    r5.zw = saturate(float2(1.42857146,1.42857146) * r5.zw);
    r3.z = r5.z + r5.w;
    r3.z = r5.w / r3.z;
    r4.x = 1 + -r3.z;
    r6.xyzw = cb2[11].zyxw * r3.zzzz;
    r7.xyzw = cb2[12].zyxw * r3.zzzz;
    r8.xyzw = cb2[13].zyxw * r3.zzzz;
    r6.xyzw = r4.xxxx * cb2[7].xyzw + r6.xyzw;
    r7.xyzw = r4.xxxx * cb2[8].xyzw + r7.xyzw;
    r8.xyzw = r4.xxxx * cb2[9].xyzw + r8.xyzw;
  } else {
    r3.z = cmp(r5.x >= r5.y);
    r6.xyzw = r3.zzzz ? cb2[7].xyzw : cb2[11].zyxw;
    r7.xyzw = r3.zzzz ? cb2[8].xyzw : cb2[12].zyxw;
    r8.xyzw = r3.zzzz ? cb2[9].xyzw : cb2[13].zyxw;
  }
  r3.z = cmp(0 < cb4[8].x);
  if (r3.z != 0) {
    r3.z = r1.w * r2.x + r0.y;
    r4.x = min(r3.z, r5.y);
    r4.x = min(r5.x, r4.x);
    r3.z = max(r3.z, r5.y);
    r3.z = max(r5.x, r3.z);
    r4.x = r3.z + -r4.x;
    r3.z = r4.x / r3.z;
    r3.z = -0.100000001 + r3.z;
    r3.z = saturate(5 * r3.z);
    r1.x = r3.z * r1.x;
  }
  r0.xyzw = r1.wwww * r2.xxxx + r0.xyzw;
  r5.x = dot(r0.xyzw, r6.xyzw);
  r5.y = dot(r0.xyzw, r7.xyzw);
  r5.z = dot(r0.xyzw, r8.xyzw);
  r5.xyz = r5.xyz + -r0.xyz;
  r0.xyz = r1.xxx * r5.xyz + r0.xyz;
  r0.w = saturate(cb4[9].x);
  r0.w = r0.w * r3.y + 1;
  o0.xyz = r0.xyz * r0.www;
  r0.xyzw = t5.Sample(s0_s, v2.xy).xyzw;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r4.xyz = r4.yzw + r4.yzw;
  r2.yzw = r2.yzw + r2.yzw;
  r5.xyz = r4.zzz * r0.xyz;
  r0.x = r1.z * r1.y;
  r0.x = r0.x * r1.w;
  r0.x = cb4[4].x * r0.x;
  r0.xy = r0.xx * r4.xy;
  r0.xy = r0.xy * r0.zz + r5.xy;
  r0.z = r3.w * r1.y;
  r0.z = r0.z * r1.w;
  r0.z = cb4[4].x * r0.z;
  r1.xy = r0.zz * r2.yz;
  r1.xy = r1.xy * r5.zz;
  r0.xy = r0.xy * r2.ww + r1.xy;
  r0.z = r5.z * r2.w;
  r1.xyz = v3.xyz * r0.yyy;
  r1.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.xyz = v4.xyz * r0.zzz + r1.xyz;
  r1.x = cmp(0 >= (uint)v7.x);
  if (r1.x != 0) {
    r1.x = dot(v4.xyz, r0.xyz);
    r1.xyz = v4.xyz * r1.xxx;
    r0.xyz = -r1.xyz * float3(2,2,2) + r0.xyz;
  }
  r0.w = saturate(r3.x * r2.x + r0.w);
  r1.x = 1 + -r0.w;
  r1.yzw = log2(cb4[10].xyz);
  r1.yzw = float3(2.20000005,2.20000005,2.20000005) * r1.yzw;
  r1.yzw = exp2(r1.yzw);
  r1.x = r1.x * cb4[11].x + cb4[12].x;
  r1.xyz = saturate(r1.yzw * r1.xxx);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
  o2.xyz = exp2(r1.xyz);
  r1.x = dot(r0.xyz, r0.xyz);
  r1.x = rsqrt(r1.x);
  r0.xyz = r1.xxx * r0.xyz;
  r1.x = max(abs(r0.x), abs(r0.y));
  r1.x = max(r1.x, abs(r0.z));
  r1.yz = cmp(abs(r0.zy) < r1.xx);
  r1.zw = r1.zz ? abs(r0.zy) : abs(r0.zx);
  r1.yz = r1.yy ? r1.zw : abs(r0.yx);
  r1.w = cmp(r1.z < r1.y);
  r2.xy = r1.ww ? r1.yz : r1.zy;
  r2.z = r2.y / r2.x;
  r0.xyz = r0.xyz / r1.xxx;
  r1.x = t13.SampleLevel(s13_s, r2.xz, 0).x;
  r0.xyz = r1.xxx * r0.xyz;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.w = cb4[13].x;
  o1.w = r0.w;
  o2.w = 0;
  WriteObjectMotion(v6, previous_clip, motion_history, object_motion, object_depth);
  return;
}