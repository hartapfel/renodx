// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

TextureCube<float4> t5 : register(t5);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[18];
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
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v2.xy).xyzw;
  r1.xy = cmp(cb2[18].xy != float2(0,0));
  if (r1.x != 0) {
    r1.x = -0.699999988 + r0.w;
    r1.x = cmp(r1.x < 0);
    if (r1.x != 0) discard;
  }
  if (r1.y != 0) {
    r1.xyzw = float4(16,16,16,16) * v6.xyxy;
    r1.xyzw = cmp(r1.xyzw >= -r1.zwzw);
    r1.xyzw = r1.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r1.zw = v6.xy * r1.zw;
    r1.zw = frac(r1.zw);
    r1.xy = r1.xy * r1.zw;
    r1.xy = (int2)r1.xy;
    r1.zw = float2(0,0);
    r1.x = t18.Load(r1.xyz).x;
    r1.x = r1.x * v0.x + v0.y;
    r1.x = cmp(r1.x < 0);
    if (r1.x != 0) discard;
  }
  r1.xyzw = t1.Sample(s0_s, v2.xy).xyzw;
  r2.xy = cb4[0].xy * v2.xy;
  r3.x = -abs(cb4[1].x) + 1;
  r3.y = cb4[1].x;
  r4.x = dot(r3.xy, r2.xy);
  r3.z = -cb4[1].x;
  r4.y = dot(r3.zx, r2.xy);
  r2.xyzw = t2.Sample(s0_s, r4.xy).xyzw;
  r2.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r2.wxyz;
  r2.x = 0.5 * r2.x;
  r3.x = v1.w;
  r3.y = v3.w;
  r3.z = v4.w;
  r3.xyz = cb1[8].xyz + -r3.xyz;
  r3.w = dot(r3.xyz, r3.xyz);
  r4.x = sqrt(r3.w);
  r4.y = saturate(cb4[3].x + -r4.x);
  r5.xyz = t3.Sample(s0_s, v2.xy).yxz;
  r4.zw = float2(-0.550000012,-1) + r5.zy;
  r4.z = saturate(2.22222233 * r4.z);
  r5.y = r4.z * r2.x;
  r5.y = r5.y * r4.y;
  r1.w = saturate(r5.y * cb4[2].x + r1.w);
  r5.y = cb4[4].x * cb4[2].x;
  r2.x = r4.z * -r2.x;
  r2.x = r2.x * r4.y;
  r2.x = r2.x * r5.y + 1;
  r2.x = max(0, r2.x);
  r6.xyz = log2(r0.xyz);
  r6.xyz = float3(2.20000005,2.20000005,2.20000005) * r6.xyz;
  r0.xyz = exp2(r6.xyz);
  r0.xyzw = r2.xxxx * r0.xyzw;
  r1.xyz = float3(-0.5,-0.5,-0.5) + r1.xyz;
  r1.xyz = r1.xyz + r1.xyz;
  r2.xyz = r2.yzw + r2.yzw;
  r2.w = cb4[2].x * r4.y;
  r2.w = r2.w * r4.z;
  r6.xyz = r2.zzz * r1.xyz;
  r1.xy = r2.ww * r2.xy;
  r6.xy = r1.xy * r1.zz + r6.xy;
  r1.x = dot(r6.xyz, r6.xyz);
  r1.x = rsqrt(r1.x);
  r1.xyz = r6.xyz * r1.xxx;
  r2.xyz = v3.xyz * r1.yyy;
  r2.xyz = v5.xyz * r1.xxx + r2.xyz;
  r1.xyz = v4.xyz * r1.zzz + r2.xyz;
  r2.x = rsqrt(r3.w);
  r2.xyz = r3.xyz * r2.xxx;
  r2.w = dot(r1.xyz, r2.xyz);
  r3.x = saturate(1 + -r2.w);
  r3.y = log2(r3.x);
  r3.y = cb4[5].x * r3.y;
  r3.y = exp2(r3.y);
  r3.z = cb4[6].x * r5.z;
  r3.w = cmp(0 < cb4[9].x);
  if (r3.w != 0) {
    r5.yzw = log2(r0.xzy);
    r5.yzw = float3(0.454544991,0.454544991,0.454544991) * r5.yzw;
    r5.yzw = exp2(r5.yzw);
    r5.yzw = r3.yyy * r3.zzz + r5.yzw;
    r3.w = r5.y + r5.z;
    r4.yz = r5.yz / r3.ww;
    r4.yz = float2(-0.300000012,-0.300000012) + r4.yz;
    r4.yz = saturate(float2(1.42857146,1.42857146) * r4.yz);
    r3.w = cmp(0 < cb4[7].x);
    if (r3.w != 0) {
      r3.w = r4.y + r4.z;
      r3.w = r4.z / r3.w;
      r4.y = 1 + -r3.w;
      r6.xyzw = cb2[11].zyxw * r3.wwww;
      r7.xyzw = cb2[12].zyxw * r3.wwww;
      r8.xyzw = cb2[13].zyxw * r3.wwww;
      r6.xyzw = r4.yyyy * cb2[7].xyzw + r6.xyzw;
      r7.xyzw = r4.yyyy * cb2[8].xyzw + r7.xyzw;
      r8.xyzw = r4.yyyy * cb2[9].xyzw + r8.xyzw;
    } else {
      r3.w = cmp(r5.y >= r5.z);
      r6.xyzw = r3.wwww ? cb2[7].xyzw : cb2[11].zyxw;
      r7.xyzw = r3.wwww ? cb2[8].xyzw : cb2[12].zyxw;
      r8.xyzw = r3.wwww ? cb2[9].xyzw : cb2[13].zyxw;
    }
    r3.w = min(r5.w, r5.z);
    r3.w = min(r5.y, r3.w);
    r4.y = max(r5.w, r5.z);
    r4.y = max(r5.y, r4.y);
    r4.z = cmp(0 < cb4[8].x);
    if (r4.z != 0) {
      r3.w = r4.y + -r3.w;
      r3.w = r3.w / r4.y;
      r3.w = -0.100000001 + r3.w;
      r3.w = saturate(5 * r3.w);
      r5.x = r5.x * r3.w;
    }
    r5.yzw = log2(r0.xyz);
    r5.yzw = float3(0.454544991,0.454544991,0.454544991) * r5.yzw;
    r0.xyz = exp2(r5.yzw);
    r9.xyzw = r3.yyyy * r3.zzzz + r0.xyzw;
    r6.x = dot(r9.xyzw, r6.xyzw);
    r6.y = dot(r9.xyzw, r7.xyzw);
    r6.z = dot(r9.xyzw, r8.xyzw);
    r5.yzw = r6.xyz + -r9.xyz;
    r5.xyz = r5.xxx * r5.yzw + r9.xyz;
  } else {
    r0.xyz = log2(r0.xyz);
    r0.xyz = float3(0.454544991,0.454544991,0.454544991) * r0.xyz;
    r0.xyz = exp2(r0.xyz);
    r5.xyz = r3.yyy * r3.zzz + r0.xyz;
  }
  r0.x = saturate(cb4[10].x);
  r0.x = r0.x * r4.w + 1;
  r0.xyz = r5.xyz * r0.xxx;
  r0.w = max(r0.y, r0.z);
  r0.w = max(r0.x, r0.w);
  r0.w = cmp(0.219999999 < r0.w);
  r0.w = r0.w ? -0.300000012 : -0.149999976;
  r0.w = v1.z * r0.w + 1;
  r3.yzw = r0.xyz * r0.www;
  r5.x = 0.219999999 * r4.x;
  r5.y = 0;
  r4.yz = v2.zw + r5.xy;
  r5.xyzw = t4.Sample(s0_s, r4.yz).xyzw;
  r3.x = r3.x * r3.x;
  r3.x = log2(r3.x);
  r3.x = cb4[11].x * r3.x;
  r3.x = exp2(r3.x);
  r3.x = saturate(-r3.x * cb4[12].x + 1);
  r2.w = r2.w + r2.w;
  r2.xyz = -r2.www * r1.xyz + r2.xyz;
  r4.x = 4 * r4.x;
  r4.yz = float2(0,0);
  r2.xyz = r4.xyz + -r2.xyz;
  r2.xyz = t5.Sample(s0_s, r2.xyz).xyz;
  r0.xyz = -r0.xyz * r0.www + r5.xyz;
  r0.xyz = r3.xxx * r0.xyz + r3.yzw;
  o0.xyz = r2.xyz * float3(1.39999998,1.39999998,1.39999998) + r0.xyz;
  r0.x = cmp(0 >= (uint)v7.x);
  if (r0.x != 0) {
    r0.x = dot(v4.xyz, r1.xyz);
    r0.xyz = v4.xyz * r0.xxx;
    r1.xyz = -r0.xyz * float3(2,2,2) + r1.xyz;
  }
  r0.x = 1 + -r1.w;
  r0.yzw = log2(cb4[13].xyz);
  r0.yzw = float3(2.20000005,2.20000005,2.20000005) * r0.yzw;
  r0.yzw = exp2(r0.yzw);
  r0.x = r0.x * cb4[14].x + cb4[15].x;
  r0.xyz = saturate(r0.yzw * r0.xxx);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.454544991,0.454544991,0.454544991) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.w = max(r0.y, r0.z);
  r0.w = max(r0.x, r0.w);
  r0.w = cmp(0.200000003 < r0.w);
  r2.xyz = r0.www ? r0.xyz : float3(0.119999997,0.119999997,0.119999997);
  r2.xyz = r2.xyz + -r0.xyz;
  o2.xyz = v1.zzz * r2.xyz + r0.xyz;
  r0.x = cb4[17].x + -cb4[16].x;
  r0.x = saturate(r1.w * r0.x + cb4[16].x);
  r0.y = cmp(r0.x < 0.330000013);
  r0.z = 0.949999988 * r0.x;
  r0.y = r0.y ? r0.z : 0.330000013;
  r0.y = r0.y + -r0.x;
  o1.w = v1.z * r0.y + r0.x;
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
  o0.w = r5.w;
  o2.w = 0;
  WriteObjectMotion(v6, previous_clip, motion_history, object_motion, object_depth);
  return;
}