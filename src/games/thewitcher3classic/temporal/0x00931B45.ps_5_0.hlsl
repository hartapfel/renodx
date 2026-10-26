// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t6 : register(t6);

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
  float4 cb4[12];
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
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = cmp(cb2[18].xyzw != float4(0,0,0,0));
  if (r0.x != 0) {
    r1.x = v0.w;
    r1.y = v2.w;
    r0.x = t0.Sample(s0_s, r1.xy).x;
    r1.x = -1 + cb2[0].x;
    r0.x = saturate(r0.x * 2 + r1.x);
    r0.x = saturate(r0.x * 20 + -10);
    r0.x = -0.330000013 + r0.x;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  if (r0.y != 0) {
    r1.xyzw = float4(16,16,16,16) * v7.xyxy;
    r1.xyzw = cmp(r1.xyzw >= -r1.zwzw);
    r1.xyzw = r1.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r0.xy = v7.xy * r1.zw;
    r0.xy = frac(r0.xy);
    r0.xy = r1.xy * r0.xy;
    r1.xy = (int2)r0.xy;
    r1.zw = float2(0,0);
    r0.x = t18.Load(r1.xyz).x;
    r0.x = r0.x * v1.x + v1.y;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  if (r0.z != 0) {
    r0.x = t12.Sample(s12_s, v3.xy).x;
    r0.x = r0.x * v1.z + v1.w;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  if (r0.w != 0) {
    r0.x = dot(v0.xyz, v0.xyz);
    r0.x = -1 + r0.x;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  r0.x = v0.w;
  r0.y = v2.w;
  r1.xyzw = t1.Sample(s0_s, r0.xy).xyzw;
  r2.xyz = cb1[8].xyz + -v5.xyz;
  r0.z = dot(r2.xyz, r2.xyz);
  r0.z = sqrt(r0.z);
  r0.z = -cb4[0].x + r0.z;
  r0.z = saturate(r0.z / -cb4[0].x);
  r0.z = cb4[1].x * r0.z;
  r2.xyz = t2.Sample(s0_s, r0.xy).yxz;
  r0.w = r2.z * 2 + -1;
  r3.xy = saturate(r0.ww);
  r4.xy = cb4[2].xy * r0.xy;
  r5.x = -abs(cb4[3].x) + 1;
  r5.y = cb4[3].x;
  r6.x = dot(r5.xy, r4.xy);
  r5.z = -cb4[3].x;
  r6.y = dot(r5.zx, r4.xy);
  r4.xyzw = t3.Sample(s0_s, r6.xy).xyzw;
  r4.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r4.wxyz;
  r0.w = r4.x * r3.y;
  r2.z = 1 + -r2.z;
  r2.z = r2.z * 2 + -1;
  r5.xy = saturate(r2.zz);
  r2.zw = cb4[4].xy * r0.xy;
  r6.x = -abs(cb4[5].x) + 1;
  r6.y = cb4[5].x;
  r7.x = dot(r6.xy, r2.zw);
  r6.z = -cb4[5].x;
  r7.y = dot(r6.zx, r2.zw);
  r6.xyzw = t4.Sample(s0_s, r7.xy).xyzw;
  r6.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r6.wxyz;
  r2.z = r6.x * r5.y;
  r2.z = 0.25 * r2.z;
  r0.w = r0.w * 0.25 + r2.z;
  r2.z = saturate(cb4[6].x);
  r7.xyzw = t5.Sample(s0_s, r0.xy).xyzw;
  r8.xy = r0.zz * r0.ww + r7.xz;
  r2.w = cmp(0 < cb4[7].x);
  if (r2.w != 0) {
    r2.w = r8.x + r8.y;
    r8.zw = r8.xy / r2.ww;
    r8.zw = float2(-0.300000012,-0.300000012) + r8.zw;
    r8.zw = saturate(float2(1.42857146,1.42857146) * r8.zw);
    r2.w = r8.z + r8.w;
    r2.w = r8.w / r2.w;
    r3.w = 1 + -r2.w;
    r9.xyzw = cb2[11].zyxw * r2.wwww;
    r10.xyzw = cb2[12].zyxw * r2.wwww;
    r11.xyzw = cb2[13].zyxw * r2.wwww;
    r9.xyzw = r3.wwww * cb2[7].xyzw + r9.xyzw;
    r10.xyzw = r3.wwww * cb2[8].xyzw + r10.xyzw;
    r11.xyzw = r3.wwww * cb2[9].xyzw + r11.xyzw;
  } else {
    r2.w = cmp(r8.x >= r8.y);
    r9.xyzw = r2.wwww ? cb2[7].xyzw : cb2[11].zyxw;
    r10.xyzw = r2.wwww ? cb2[8].xyzw : cb2[12].zyxw;
    r11.xyzw = r2.wwww ? cb2[9].xyzw : cb2[13].zyxw;
  }
  r2.w = cmp(0 < cb4[8].x);
  if (r2.w != 0) {
    r2.w = r0.z * r0.w + r7.y;
    r3.w = min(r2.w, r8.y);
    r3.w = min(r8.x, r3.w);
    r2.w = max(r2.w, r8.y);
    r2.w = max(r8.x, r2.w);
    r3.w = r2.w + -r3.w;
    r2.w = r3.w / r2.w;
    r2.w = -0.100000001 + r2.w;
    r2.w = saturate(5 * r2.w);
    r2.x = r2.x * r2.w;
  }
  r7.xyzw = r0.zzzz * r0.wwww + r7.xyzw;
  r8.x = dot(r7.xyzw, r9.xyzw);
  r8.y = dot(r7.xyzw, r10.xyzw);
  r8.z = dot(r7.xyzw, r11.xyzw);
  r8.xyz = r8.xyz + -r7.xyz;
  r7.xyz = r2.xxx * r8.xyz + r7.xyz;
  r2.x = -1 + r2.y;
  r2.x = r2.z * r2.x + 1;
  r2.xyz = r2.xxx * r7.xyz;
  r2.w = max(r2.y, r2.z);
  r2.w = max(r2.x, r2.w);
  r2.w = cmp(0.219999999 < r2.w);
  r2.w = r2.w ? -0.300000012 : -0.149999976;
  r2.w = v2.z * r2.w + 1;
  o0.xyz = r2.xyz * r2.www;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.xyz = r1.xyz + r1.xyz;
  r3.z = 2;
  r2.xyz = r4.yzw * r3.xyz;
  r5.z = 2;
  r3.xyz = r6.yzw * r5.xyz;
  r4.x = dot(r3.zzxx, r2.xxzz);
  r4.y = dot(r3.zzyy, r2.yyzz);
  r4.z = r3.z * r2.z;
  r2.x = dot(r4.xyz, r4.xyz);
  r2.x = rsqrt(r2.x);
  r2.xyz = r4.zxy * r2.xxx;
  r3.xyz = r2.xxx * r1.xyz;
  r1.xy = r2.yz * r0.zz;
  r3.xy = r1.xy * r1.zz + r3.xy;
  r1.x = dot(r3.xyz, r3.xyz);
  r1.x = rsqrt(r1.x);
  r1.yz = r3.xy * r1.xx;
  r2.xyz = v4.xyz * r1.zzz;
  r1.x = r3.z * r1.x;
  r3.xy = v3.zw;
  r3.z = v4.w;
  r2.xyz = v6.xyz * r1.yyy + r2.xyz;
  r1.xyz = r3.xyz * r1.xxx + r2.xyz;
  r2.x = cmp(0 >= (uint)v8.x);
  if (r2.x != 0) {
    r2.x = dot(r3.xyz, r1.xyz);
    r2.xyz = r3.xyz * r2.xxx;
    r1.xyz = -r2.xyz * float3(2,2,2) + r1.xyz;
  }
  r2.xyz = t6.Sample(s0_s, r0.xy).xyz;
  r2.xyz = saturate(r2.xyz * cb4[9].xxx + cb4[10].xxx);
  r2.xyz = r0.zzz * r0.www + r2.xyz;
  r0.x = max(r2.y, r2.z);
  r0.x = max(r2.x, r0.x);
  r0.x = cmp(0.200000003 < r0.x);
  r3.xyz = r0.xxx ? r2.xyz : float3(0.119999997,0.119999997,0.119999997);
  r3.xyz = r3.xyz + -r2.xyz;
  o2.xyz = v2.zzz * r3.xyz + r2.xyz;
  r0.x = r0.z * r0.w + r1.w;
  r0.y = cmp(r0.x < 0.330000013);
  r0.z = 0.949999988 * r0.x;
  r0.y = r0.y ? r0.z : 0.330000013;
  r0.y = r0.y + -r0.x;
  o1.w = v2.z * r0.y + r0.x;
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
  o0.w = cb4[11].x;
  o2.w = 0;
  WriteObjectMotion(v7, previous_clip, motion_history, object_motion, object_depth);
  return;
}