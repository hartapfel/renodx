// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:17:22 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t13 : register(t13);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[7];
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
  float3 v4 : TEXCOORD4,
  float4 v5 : SV_Position0,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  uint v6 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float4 o1 : SV_Target1,
  out float4 o2 : SV_Target2,
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v2.xy).xyzw;
  r1.xyz = cmp(cb2[18].xyw != float3(0,0,0));
  if (r1.x != 0) {
    r1.xw = float2(6,6) * v2.xy;
    r2.xyz = t1.Sample(s0_s, r1.xw).xyz;
    r1.x = dot(r2.xyz, float3(2,2,2));
    r1.w = 3 + cb2[0].x;
    r1.x = r1.x * r1.w;
    r1.x = r0.w * r1.x + -0.699999988;
    r1.x = cmp(r1.x < 0);
    if (r1.x != 0) discard;
  }
  if (r1.y != 0) {
    r2.xyzw = float4(16,16,16,16) * v5.xyxy;
    r2.xyzw = cmp(r2.xyzw >= -r2.zwzw);
    r2.xyzw = r2.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r1.xy = v5.xy * r2.zw;
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
    r1.x = dot(v0.xyz, v0.xyz);
    r1.x = -1 + r1.x;
    r1.x = cmp(r1.x < 0);
    if (r1.x != 0) discard;
  }
  r1.xy = t2.Sample(s0_s, v2.xy).yx;
  r1.z = cmp(0 < cb4[0].x);
  if (r1.z != 0) {
    r1.z = r0.x + r0.z;
    r1.zw = r0.xz / r1.zz;
    r1.zw = float2(-0.300000012,-0.300000012) + r1.zw;
    r1.zw = saturate(float2(1.42857146,1.42857146) * r1.zw);
    r1.z = r1.z + r1.w;
    r1.z = r1.w / r1.z;
    r1.w = 1 + -r1.z;
    r2.xyzw = cb2[11].zyxw * r1.zzzz;
    r3.xyzw = cb2[12].zyxw * r1.zzzz;
    r4.xyzw = cb2[13].zyxw * r1.zzzz;
    r2.xyzw = r1.wwww * cb2[7].xyzw + r2.xyzw;
    r3.xyzw = r1.wwww * cb2[8].xyzw + r3.xyzw;
    r4.xyzw = r1.wwww * cb2[9].xyzw + r4.xyzw;
  } else {
    r1.z = cmp(r0.x >= r0.z);
    r2.xyzw = r1.zzzz ? cb2[7].xyzw : cb2[11].zyxw;
    r3.xyzw = r1.zzzz ? cb2[8].xyzw : cb2[12].zyxw;
    r4.xyzw = r1.zzzz ? cb2[9].xyzw : cb2[13].zyxw;
  }
  r1.z = cmp(0 < cb4[1].x);
  if (r1.z != 0) {
    r1.z = min(r0.y, r0.z);
    r1.z = min(r1.z, r0.x);
    r1.w = max(r0.y, r0.z);
    r1.w = max(r1.w, r0.x);
    r1.z = r1.w + -r1.z;
    r1.z = r1.z / r1.w;
    r1.z = -0.100000001 + r1.z;
    r1.z = saturate(5 * r1.z);
    r1.x = r1.x * r1.z;
  }
  r2.x = dot(r0.xyzw, r2.xyzw);
  r2.y = dot(r0.xyzw, r3.xyzw);
  r2.z = dot(r0.xyzw, r4.xyzw);
  r2.xyz = r2.xyz + -r0.xyz;
  r0.xyz = r1.xxx * r2.xyz + r0.xyz;
  r0.w = saturate(cb4[2].x);
  r1.x = -1 + r1.y;
  r0.w = r0.w * r1.x + 1;
  o0.xyz = r0.xyz * r0.www;
  r0.xyzw = t3.Sample(s0_s, v2.xy).xyzw;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r1.x = v0.w;
  r1.yz = v2.zw;
  r1.xyz = r1.xyz * r0.yyy;
  r1.xyz = v4.xyz * r0.xxx + r1.xyz;
  r0.xyz = v3.xyz * r0.zzz + r1.xyz;
  r1.x = cmp(0 >= (uint)v6.x);
  if (r1.x != 0) {
    r1.x = dot(v3.xyz, r0.xyz);
    r1.xyz = v3.xyz * r1.xxx;
    r0.xyz = -r1.xyz * float3(2,2,2) + r0.xyz;
  }
  r1.x = 1 + -r0.w;
  r1.yzw = log2(cb4[3].xyz);
  r1.yzw = float3(2.20000005,2.20000005,2.20000005) * r1.yzw;
  r1.yzw = exp2(r1.yzw);
  r1.x = r1.x * cb4[4].x + cb4[5].x;
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
  o0.w = cb4[6].x;
  o1.w = r0.w;
  o2.w = 0;
  WriteObjectMotion(v5, previous_clip, motion_history, object_motion, object_depth);
  return;
}