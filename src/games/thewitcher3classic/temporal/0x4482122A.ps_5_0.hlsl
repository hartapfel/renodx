// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t4 : register(t4);

Texture2DArray<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s12_s : register(s12);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[25];
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
  r4.x = -abs(cb4[7].x) + 1;
  r0.zw = r0.xy / cb4[5].xy;
  r0.zw = cb4[4].xy + r0.zw;
  r0.zw = cb4[6].xx * r3.ww + r0.zw;
  r4.y = cb4[7].x;
  r5.x = dot(r4.xy, r0.zw);
  r4.z = -cb4[7].x;
  r5.y = dot(r4.zx, r0.zw);
  r5.z = cb4[3].x;
  r4.xyzw = t3.Sample(s0_s, r5.xyz).xyzw;
  r5.xyzw = saturate(cb4[2].xyzw);
  r6.xyz = r5.xyz * r4.xyz;
  r0.z = r6.x + r6.y;
  r0.z = r4.z * r5.z + r0.z;
  r0.z = saturate(r4.w * r5.w + r0.z);
  r0.xyw = t4.Sample(s0_s, r0.xy).yxz;
  r4.x = 1 + -r0.w;
  r4.x = saturate(r4.x + r4.x);
  r0.z = 1 + -r0.z;
  r4.y = 1 + -r0.z;
  r0.z = r4.x * r4.y + r0.z;
  r4.y = 1 + -r0.z;
  r3.w = -r4.y * cb4[8].x + r3.w;
  r3.w = -0.5 + r3.w;
  r3.w = 0.5 * r3.w;
  r4.yzw = cb1[8].xyz + -v5.xyz;
  r4.y = dot(r4.yzw, r4.yzw);
  r4.y = sqrt(r4.y);
  r4.y = saturate(cb4[10].x + -r4.y);
  r0.yw = float2(-0.550000012,-1) + r0.wy;
  r0.y = saturate(2.22222233 * r0.y);
  r4.z = r3.w * r0.y;
  r4.z = r4.z * r4.y;
  r2.w = saturate(r4.z * cb4[9].x + r2.w);
  r4.z = cb4[11].x * cb4[9].x;
  r3.w = -r3.w * r0.y;
  r3.w = r3.w * r4.y;
  r3.w = r3.w * r4.z + 1;
  r3.w = max(0, r3.w);
  r5.xyz = log2(r1.xyz);
  r5.xyz = float3(2.20000005,2.20000005,2.20000005) * r5.xyz;
  r1.xyz = exp2(r5.xyz);
  r1.xyzw = r3.wwww * r1.xyzw;
  r3.w = cmp(0 < cb4[14].x);
  if (r3.w != 0) {
    r5.xyz = log2(r1.xzy);
    r5.xyz = float3(0.454544991,0.454544991,0.454544991) * r5.xyz;
    r5.xyz = exp2(r5.xyz);
    r3.w = r5.x + r5.y;
    r4.zw = r5.xy / r3.ww;
    r4.zw = float2(-0.300000012,-0.300000012) + r4.zw;
    r4.zw = saturate(float2(1.42857146,1.42857146) * r4.zw);
    r3.w = cmp(0 < cb4[12].x);
    if (r3.w != 0) {
      r3.w = r4.z + r4.w;
      r3.w = r4.w / r3.w;
      r4.z = 1 + -r3.w;
      r7.xyzw = cb2[11].zyxw * r3.wwww;
      r8.xyzw = cb2[12].zyxw * r3.wwww;
      r9.xyzw = cb2[13].zyxw * r3.wwww;
      r7.xyzw = r4.zzzz * cb2[7].xyzw + r7.xyzw;
      r8.xyzw = r4.zzzz * cb2[8].xyzw + r8.xyzw;
      r9.xyzw = r4.zzzz * cb2[9].xyzw + r9.xyzw;
    } else {
      r3.w = cmp(r5.x >= r5.y);
      r7.xyzw = r3.wwww ? cb2[7].xyzw : cb2[11].zyxw;
      r8.xyzw = r3.wwww ? cb2[8].xyzw : cb2[12].zyxw;
      r9.xyzw = r3.wwww ? cb2[9].xyzw : cb2[13].zyxw;
    }
    r3.w = min(r5.z, r5.y);
    r3.w = min(r5.x, r3.w);
    r4.z = max(r5.z, r5.y);
    r4.z = max(r5.x, r4.z);
    r4.w = cmp(0 < cb4[13].x);
    if (r4.w != 0) {
      r3.w = r4.z + -r3.w;
      r3.w = r3.w / r4.z;
      r3.w = -0.100000001 + r3.w;
      r3.w = saturate(5 * r3.w);
      r0.x = r3.w * r0.x;
    }
    r5.xyz = log2(r1.xyz);
    r5.xyz = float3(0.454544991,0.454544991,0.454544991) * r5.xyz;
    r1.xyz = exp2(r5.xyz);
    r5.x = dot(r1.xyzw, r7.xyzw);
    r5.y = dot(r1.xyzw, r8.xyzw);
    r5.z = dot(r1.xyzw, r9.xyzw);
    r5.xyz = r5.xyz + -r1.xyz;
    r5.xyz = r0.xxx * r5.xyz + r1.xyz;
  } else {
    r1.xyz = log2(r1.xyz);
    r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
    r5.xyz = exp2(r1.xyz);
  }
  r1.xyz = cb4[16].xyz * r6.yyy;
  r1.xyz = r6.xxx * cb4[15].xyz + r1.xyz;
  r1.xyz = saturate(r6.zzz * cb4[17].xyz + r1.xyz);
  r0.x = saturate(cb4[18].x);
  r1.xyz = r4.xxx * -r1.xyz + r1.xyz;
  r1.xyz = r0.zzz * r5.xyz + r1.xyz;
  r0.x = r0.x * r0.w + 1;
  r0.xzw = r1.xyz * r0.xxx;
  r1.x = max(r0.z, r0.w);
  r1.x = max(r1.x, r0.x);
  r1.x = cmp(0.219999999 < r1.x);
  r1.x = r1.x ? -0.300000012 : -0.149999976;
  r1.x = v2.z * r1.x + 1;
  o0.xyz = r1.xxx * r0.xzw;
  r0.xzw = float3(-0.5,-0.5,-0.5) + r2.xyz;
  r0.xzw = r0.xzw + r0.xzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r3.xyz;
  r1.xyz = r1.xyz + r1.xyz;
  r1.w = cb4[9].x * r4.y;
  r0.y = r1.w * r0.y;
  r2.xyz = r1.zzz * r0.xzw;
  r0.xy = r0.yy * r1.xy;
  r2.xy = r0.xy * r0.ww + r2.xy;
  r0.x = dot(r2.xyz, r2.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r2.xyz * r0.xxx;
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
  r1.xyz = log2(cb4[19].xyz);
  r1.xyz = float3(2.20000005,2.20000005,2.20000005) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r0.w = r0.w * cb4[20].x + cb4[21].x;
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
  r0.w = cb4[23].x + -cb4[22].x;
  r0.w = saturate(r2.w * r0.w + cb4[22].x);
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
  o0.w = cb4[24].x;
  o2.w = 0;
  WriteObjectMotion(v7, previous_clip, motion_history, object_motion, object_depth);
  return;
}