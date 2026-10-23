// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 22 20:14:10 2026
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
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v2.xy).xyzw;
  r1.xyzw = cmp(cb2[18].xyzw != float4(0,0,0,0));
  if (r1.x != 0) {
    r1.x = saturate(cb4[0].x + r0.w);
    r1.x = -0.170000002 + r1.x;
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
  r1.x = r0.x + r0.y;
  r1.x = r1.x + r0.z;
  r1.z = cb4[2].x + -1;
  r1.yz = float2(0.333299994,0.5) * r1.xz;
  r1.w = saturate(r1.z);
  r1.x = r1.x * -0.666599989 + 1;
  r1.x = r1.w * r1.x + r1.y;
  r2.xyzw = cb4[1].xyzw * r0.xyzw;
  r2.xyzw = saturate(float4(1.5,1.5,1.5,1.5) * r2.xyzw);
  r1.x = saturate(r1.x * abs(r1.z));
  r2.xyzw = r2.xyzw + -r0.xyzw;
  r0.xyzw = r1.xxxx * r2.xyzw + r0.xyzw;
  r0.xyzw = cb4[3].xxxx * r0.xyzw;
  r1.xyzw = v3.xyzw * r0.xyzw;
  r0.w = cmp(0 < cb4[6].x);
  if (r0.w != 0) {
    r0.w = t1.Sample(s0_s, v2.xy).y;
    r2.x = r1.x + r1.z;
    r2.xy = r1.xz / r2.xx;
    r2.xy = float2(-0.300000012,-0.300000012) + r2.xy;
    r2.xy = saturate(float2(1.42857146,1.42857146) * r2.xy);
    r2.z = cmp(0 < cb4[4].x);
    if (r2.z != 0) {
      r2.x = r2.x + r2.y;
      r2.x = r2.y / r2.x;
      r2.y = 1 + -r2.x;
      r3.xyzw = cb2[11].zyxw * r2.xxxx;
      r4.xyzw = cb2[12].zyxw * r2.xxxx;
      r5.xyzw = cb2[13].zyxw * r2.xxxx;
      r3.xyzw = r2.yyyy * cb2[7].xyzw + r3.xyzw;
      r4.xyzw = r2.yyyy * cb2[8].xyzw + r4.xyzw;
      r2.xyzw = r2.yyyy * cb2[9].xyzw + r5.xyzw;
    } else {
      r5.x = cmp(r1.x >= r1.z);
      r3.xyzw = r5.xxxx ? cb2[7].xyzw : cb2[11].zyxw;
      r4.xyzw = r5.xxxx ? cb2[8].xyzw : cb2[12].zyxw;
      r2.xyzw = r5.xxxx ? cb2[9].xyzw : cb2[13].zyxw;
    }
    r5.x = min(r1.y, r1.z);
    r5.x = min(r5.x, r1.x);
    r5.y = max(r1.y, r1.z);
    r5.y = max(r5.y, r1.x);
    r5.z = cmp(0 < cb4[5].x);
    if (r5.z != 0) {
      r5.x = r5.y + -r5.x;
      r5.x = r5.x / r5.y;
      r5.x = -0.100000001 + r5.x;
      r5.x = saturate(5 * r5.x);
      r0.w = r5.x * r0.w;
    }
    r3.x = dot(r1.xyzw, r3.xyzw);
    r3.y = dot(r1.xyzw, r4.xyzw);
    r3.z = dot(r1.xyzw, r2.xyzw);
    r0.xyz = -v3.xyz * r0.xyz + r3.xyz;
    r1.xyz = r0.www * r0.xyz + r1.xyz;
  }
  r0.xyzw = t2.Sample(s0_s, v2.xy).xyzw;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r2.x = v0.w;
  r2.y = v4.w;
  r2.z = v5.w;
  r3.xyz = v4.xyz * r0.yyy;
  r2.xyz = r2.xyz * r0.xxx + r3.xyz;
  r0.xyz = v5.xyz * r0.zzz + r2.xyz;
  r1.w = cmp(0 >= (uint)v7.x);
  if (r1.w != 0) {
    r1.w = dot(v5.xyz, r0.xyz);
    r2.xyz = v5.xyz * r1.www;
    r0.xyz = -r2.xyz * float3(2,2,2) + r0.xyz;
  }
  r2.xy = cb4[10].xy * v2.xy;
  r1.w = t3.Sample(s0_s, r2.xy).x;
  r2.x = 1 + -r0.w;
  r2.y = cb4[9].x + -cb4[8].x;
  r2.x = r2.x * r2.y + cb4[8].x;
  r2.x = r2.x * r1.w;
  r2.yzw = log2(cb4[7].xyz);
  r2.yzw = float3(2.20000005,2.20000005,2.20000005) * r2.yzw;
  r2.yzw = exp2(r2.yzw);
  r2.xyz = saturate(r2.yzw * r2.xxx);
  r2.xyz = log2(r2.xyz);
  r2.xyz = float3(0.454544991,0.454544991,0.454544991) * r2.xyz;
  o2.xyz = exp2(r2.xyz);
  r2.x = cb4[12].x + -cb4[11].x;
  r0.w = r0.w * r2.x + cb4[11].x;
  r1.w = 1 + -r1.w;
  r2.x = cb4[14].x + -cb4[13].x;
  r1.w = r1.w * r2.x + cb4[13].x;
  o1.w = saturate(r1.w * r0.w);
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r0.w = max(abs(r0.x), abs(r0.y));
  r0.w = max(abs(r0.z), r0.w);
  r2.xy = cmp(abs(r0.zy) < r0.ww);
  r2.yz = r2.yy ? abs(r0.zy) : abs(r0.zx);
  r2.xy = r2.xx ? r2.yz : abs(r0.yx);
  r1.w = cmp(r2.y < r2.x);
  r2.xy = r1.ww ? r2.xy : r2.yx;
  r2.z = r2.y / r2.x;
  r0.xyz = r0.xyz / r0.www;
  r0.w = t13.SampleLevel(s13_s, r2.xz, 0).x;
  r0.xyz = r0.xyz * r0.www;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  o0.xyz = r1.xyz;
  o0.w = 0;
  o2.w = 0;
  WriteObjectMotion(v6, previous_clip, motion_history, object_motion, object_depth);
  return;
}