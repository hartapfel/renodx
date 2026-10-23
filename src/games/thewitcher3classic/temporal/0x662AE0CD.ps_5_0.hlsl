// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[16];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[14];
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
  float3 v4 : TEXCOORD4,
  float4 motion_position : SV_Position,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v5 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = t1.Sample(s0_s, v1.xy).xyz;
  r1.xy = cb4[0].xy * v1.xy;
  r2.x = -abs(cb4[1].x) + 1;
  r2.y = cb4[1].x;
  r3.x = dot(r2.xy, r1.xy);
  r2.z = -cb4[1].x;
  r3.y = dot(r2.zx, r1.xy);
  r1.xyz = t2.Sample(s0_s, r3.xy).xyz;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.zxy;
  r0.w = 0.5 * r1.x;
  r2.xyz = cb1[8].xyz + -v3.xyz;
  r1.x = dot(r2.xyz, r2.xyz);
  r1.x = sqrt(r1.x);
  r1.x = saturate(cb4[3].x + -r1.x);
  r2.xyz = t3.Sample(s0_s, v1.xy).yxz;
  r3.xy = cb4[4].xy * v1.xy;
  r4.x = -abs(cb4[5].x) + 1;
  r4.y = cb4[5].x;
  r5.x = dot(r4.xy, r3.xy);
  r4.z = -cb4[5].x;
  r5.y = dot(r4.zx, r3.xy);
  r3.xyz = t4.Sample(s0_s, r5.xy).xyz;
  r3.xyz = float3(-0.5,-0.5,-0.5) + r3.zxy;
  r1.w = 0.5 * r3.x;
  r4.xyz = float3(-0.550000012,-1,-0.5) + r2.zyz;
  r2.y = saturate(2.22222233 * r4.x);
  r2.w = 0.449999988 + -r2.z;
  r2.w = saturate(2.22222233 * r2.w);
  r3.x = r2.w * r1.w;
  r3.x = r0.w * r2.y + r3.x;
  r3.x = r3.x * r1.x;
  r0.z = saturate(r3.x * cb4[2].x + r0.z);
  r3.x = cb4[6].x * cb4[2].x;
  r1.w = r2.w * -r1.w;
  r0.w = -r0.w * r2.y + r1.w;
  r0.w = r0.w * r1.x;
  r0.w = r0.w * r3.x + 1;
  r0.w = max(0, r0.w);
  r5.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r6.xyz = log2(r5.xyz);
  r6.xyz = float3(2.20000005,2.20000005,2.20000005) * r6.xyz;
  r5.xyz = exp2(r6.xyz);
  r5.xyzw = r5.xyzw * r0.wwww;
  r1.w = cmp(0 < cb4[9].x);
  if (r1.w != 0) {
    r6.xyz = log2(r5.xzy);
    r6.xyz = float3(0.454544991,0.454544991,0.454544991) * r6.xyz;
    r6.xyz = exp2(r6.xyz);
    r1.w = r6.x + r6.y;
    r2.yw = r6.xy / r1.ww;
    r2.yw = float2(-0.300000012,-0.300000012) + r2.yw;
    r2.yw = saturate(float2(1.42857146,1.42857146) * r2.yw);
    r1.w = cmp(0 < cb4[7].x);
    if (r1.w != 0) {
      r1.w = r2.y + r2.w;
      r1.w = r2.w / r1.w;
      r2.y = 1 + -r1.w;
      r7.xyzw = cb2[11].zyxw * r1.wwww;
      r8.xyzw = cb2[12].zyxw * r1.wwww;
      r9.xyzw = cb2[13].zyxw * r1.wwww;
      r7.xyzw = r2.yyyy * cb2[7].xyzw + r7.xyzw;
      r8.xyzw = r2.yyyy * cb2[8].xyzw + r8.xyzw;
      r9.xyzw = r2.yyyy * cb2[9].xyzw + r9.xyzw;
    } else {
      r1.w = cmp(r6.x >= r6.y);
      r7.xyzw = r1.wwww ? cb2[7].xyzw : cb2[11].zyxw;
      r8.xyzw = r1.wwww ? cb2[8].xyzw : cb2[12].zyxw;
      r9.xyzw = r1.wwww ? cb2[9].xyzw : cb2[13].zyxw;
    }
    r1.w = min(r6.z, r6.y);
    r1.w = min(r6.x, r1.w);
    r2.y = max(r6.z, r6.y);
    r2.y = max(r6.x, r2.y);
    r2.w = cmp(0 < cb4[8].x);
    if (r2.w != 0) {
      r1.w = r2.y + -r1.w;
      r1.w = r1.w / r2.y;
      r1.w = -0.100000001 + r1.w;
      r1.w = saturate(5 * r1.w);
      r2.x = r2.x * r1.w;
    }
    r6.xyz = log2(r5.xyz);
    r6.xyz = float3(0.454544991,0.454544991,0.454544991) * r6.xyz;
    r5.xyz = exp2(r6.xyz);
    r6.x = dot(r5.xyzw, r7.xyzw);
    r6.y = dot(r5.xyzw, r8.xyzw);
    r6.z = dot(r5.xyzw, r9.xyzw);
    r6.xyz = r6.xyz + -r5.xyz;
    r2.xyw = r2.xxx * r6.xyz + r5.xyz;
  } else {
    r5.xyz = log2(r5.xyz);
    r5.xyz = float3(0.454544991,0.454544991,0.454544991) * r5.xyz;
    r2.xyw = exp2(r5.xyz);
  }
  r1.w = saturate(cb4[10].x);
  r1.w = r1.w * r4.y + 1;
  r2.xyw = r2.xyw * r1.www;
  r1.w = max(r2.y, r2.w);
  r1.w = max(r2.x, r1.w);
  r1.w = cmp(0.219999999 < r1.w);
  r1.w = r1.w ? -0.300000012 : -0.149999976;
  r1.w = v0.z * r1.w + 1;
  o0.xyz = r2.xyw * r1.www;
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r0.xy = r0.xy + r0.xy;
  r1.yz = r1.yz + r1.yz;
  r2.xy = r3.yz + r3.yz;
  r1.x = cb4[2].x * r1.x;
  r1.w = -0.0500000007 + abs(r4.z);
  r1.w = saturate(2.22222233 * r1.w);
  r1.x = r1.x * r1.w;
  r1.w = cmp(0.5 < r2.z);
  r1.yz = r1.ww ? r1.yz : r2.xy;
  r1.xy = r1.xx * r1.yz + r0.xy;
  r1.z = 1;
  r0.x = dot(r1.xyz, r1.xyz);
  r0.x = rsqrt(r0.x);
  r1.xyz = r1.xyz * r0.xxx;
  r2.x = v0.w;
  r2.yz = v1.zw;
  r2.xyz = r2.xyz * r1.yyy;
  r1.xyw = v4.xyz * r1.xxx + r2.xyz;
  r1.xyz = v2.xyz * r1.zzz + r1.xyw;
  r0.x = cmp(0 >= (uint)v5.x);
  if (r0.x != 0) {
    r0.x = dot(v2.xyz, r1.xyz);
    r2.xyz = v2.xyz * r0.xxx;
    r1.xyz = -r2.xyz * float3(2,2,2) + r1.xyz;
  }
  r2.xyz = t5.Sample(s0_s, v1.xy).xyz;
  r2.xyz = saturate(r2.xyz * cb4[11].xxx + cb4[12].xxx);
  r2.xyz = log2(r2.xyz);
  r2.xyz = float3(2.20000005,2.20000005,2.20000005) * r2.xyz;
  r2.xyz = exp2(r2.xyz);
  r0.xyw = r2.xyz * r0.www;
  r0.xyw = log2(r0.xyw);
  r0.xyw = float3(0.454544991,0.454544991,0.454544991) * r0.xyw;
  r0.xyw = exp2(r0.xyw);
  r1.w = max(r0.y, r0.w);
  r1.w = max(r1.w, r0.x);
  r1.w = cmp(0.200000003 < r1.w);
  r2.xyz = r1.www ? r0.xyw : float3(0.119999997,0.119999997,0.119999997);
  r2.xyz = r2.xyz + -r0.xyw;
  o2.xyz = v0.zzz * r2.xyz + r0.xyw;
  r0.x = cb4[14].x + -cb4[13].x;
  r0.x = saturate(r0.z * r0.x + cb4[13].x);
  r0.y = cmp(r0.x < 0.330000013);
  r0.z = 0.949999988 * r0.x;
  r0.y = r0.y ? r0.z : 0.330000013;
  r0.y = r0.y + -r0.x;
  o1.w = v0.z * r0.y + r0.x;
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
  o0.w = cb4[15].x;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}