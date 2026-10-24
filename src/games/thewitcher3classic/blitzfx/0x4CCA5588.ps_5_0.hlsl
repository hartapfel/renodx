// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 21:55:11 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[14];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[9];
}




// 3Dmigoto declarations
#define cmp -


#include "../temporal/object_pixel.hlsli"

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float3 v3 : TEXCOORD3,
  float4 motion_position : SV_Position,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v4 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t1.Sample(s0_s, v1.xy).xyzw;
  r1.xyzw = t0.Sample(s0_s, v1.xy).xyzw;
  r2.x = r1.x + r1.y;
  r2.x = r2.x + r1.z;
  r2.y = -1 + cb4[1].x;
  r2.yw = float2(0.5,0.333299994) * r2.yx;
  r2.z = saturate(r2.y);
  r2.x = r2.x * -0.666599989 + 1;
  r2.x = r2.z * r2.x + r2.w;
  r3.xyzw = cb4[0].xyzw * r1.xyzw;
  r3.xyzw = saturate(float4(1.5,1.5,1.5,1.5) * r3.xyzw);
  r2.x = saturate(r2.x * abs(r2.y));
  r3.xyzw = r3.xyzw + -r1.xyzw;
  r1.xyzw = r2.xxxx * r3.xyzw + r1.xyzw;
  r2.x = cmp(0 < cb4[4].x);
  if (r2.x != 0) {
    r2.x = t2.Sample(s0_s, v1.xy).y;
    r2.y = r1.x + r1.z;
    r2.yz = r1.xz / r2.yy;
    r2.yz = float2(-0.300000012,-0.300000012) + r2.yz;
    r2.yz = saturate(float2(1.42857146,1.42857146) * r2.yz);
    r2.w = cmp(0 < cb4[2].x);
    r2.y = r2.y + r2.z;
    r2.y = r2.z / r2.y;
    r2.z = 1 + -r2.y;
    r3.xyzw = cb2[11].zyxw * r2.yyyy;
    r4.xyzw = cb2[12].zyxw * r2.yyyy;
    r5.xyzw = cb2[13].zyxw * r2.yyyy;
    r3.xyzw = r2.zzzz * cb2[7].xyzw + r3.xyzw;
    r4.xyzw = r2.zzzz * cb2[8].xyzw + r4.xyzw;
    r5.xyzw = r2.zzzz * cb2[9].xyzw + r5.xyzw;
    r2.y = cmp(r1.x >= r1.z);
    r6.xyzw = r2.yyyy ? cb2[7].xyzw : cb2[11].zyxw;
    r7.xyzw = r2.yyyy ? cb2[8].xyzw : cb2[12].zyxw;
    r8.xyzw = r2.yyyy ? cb2[9].xyzw : cb2[13].zyxw;
    r3.xyzw = r2.wwww ? r3.xyzw : r6.xyzw;
    r4.xyzw = r2.wwww ? r4.xyzw : r7.xyzw;
    r5.xyzw = r2.wwww ? r5.xyzw : r8.xyzw;
    r2.y = min(r1.y, r1.z);
    r2.y = min(r2.y, r1.x);
    r2.z = max(r1.y, r1.z);
    r2.z = max(r2.z, r1.x);
    r2.w = cmp(0 < cb4[3].x);
    r2.y = r2.z + -r2.y;
    r2.y = r2.y / r2.z;
    r2.y = -0.100000001 + r2.y;
    r2.y = saturate(5 * r2.y);
    r2.y = r2.x * r2.y;
    r2.x = r2.w ? r2.y : r2.x;
    r3.x = dot(r1.xyzw, r3.xyzw);
    r3.y = dot(r1.xyzw, r4.xyzw);
    r3.z = dot(r1.xyzw, r5.xyzw);
    r2.yzw = r3.xyz + -r1.xyz;
    r1.xyz = r2.xxx * r2.yzw + r1.xyz;
  }
  r1.w = max(r1.y, r1.z);
  r1.w = max(r1.x, r1.w);
  r1.w = cmp(0.219999999 < r1.w);
  r1.w = r1.w ? -0.300000012 : -0.149999976;
  r1.w = v0.z * r1.w + 1;
  o0.xyz = r1.xyz * r1.www;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r1.x = v0.w;
  r1.yz = v1.zw;
  r1.xyz = r1.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.xyz = v2.xyz * r0.zzz + r1.xyz;
  r1.x = cmp(0 >= (uint)v4.x);
  r1.y = dot(v2.xyz, r0.xyz);
  r1.yzw = v2.xyz * r1.yyy;
  r1.yzw = r1.yzw * float3(-2,-2,-2) + r0.xyz;
  r0.xyz = r1.xxx ? r1.yzw : r0.xyz;
  r1.x = 1 + -r0.w;
  r1.yzw = log2(cb4[5].xyz);
  r1.yzw = float3(2.20000005,2.20000005,2.20000005) * r1.yzw;
  r1.yzw = exp2(r1.yzw);
  r1.x = r1.x * cb4[6].x + cb4[7].x;
  r1.xyz = saturate(r1.yzw * r1.xxx);
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(0.454544991,0.454544991,0.454544991) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r1.w = max(r1.y, r1.z);
  r1.w = max(r1.x, r1.w);
  r1.w = cmp(0.200000003 < r1.w);
  r2.xyz = r1.www ? r1.xyz : float3(0.119999997,0.119999997,0.119999997);
  r2.xyz = r2.xyz + -r1.xyz;
  o2.xyz = v0.zzz * r2.xyz + r1.xyz;
  r1.x = cmp(r0.w < 0.330000013);
  r1.y = 0.949999988 * r0.w;
  r1.x = r1.x ? r1.y : 0.330000013;
  r1.x = r1.x + -r0.w;
  r0.w = v0.z * r1.x + r0.w;
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
  r1.xyz = r0.xyz / r1.xxx;
  r1.w = t13.SampleLevel(s13_s, r2.xz, 0).x;
  r1.xyz = r1.xyz * r1.www;
  o1.xyz = r1.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r1.xyz = ddx_coarse(r0.xyz);
  r0.xyz = ddy_coarse(r0.xyz);
  r1.x = dot(r1.xyz, r1.xyz);
  r0.x = dot(r0.xyz, r0.xyz);
  r0.x = r1.x + r0.x;
  r0.x = 0.5 * r0.x;
  r0.x = min(0.180000007, r0.x);
  r0.x = r0.w * r0.w + r0.x;
  r0.x = min(1, r0.x);
  o1.w = sqrt(r0.x);
  o0.w = cb4[8].x;
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}