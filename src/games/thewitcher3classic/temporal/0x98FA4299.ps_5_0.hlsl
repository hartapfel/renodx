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
  float4 cb4[17];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[19];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[1];
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
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = cmp(cb2[18].xyzw != float4(0,0,0,0));
  if (r0.x != 0) {
    r1.xy = float2(0.100000001,-0.0500000007) * cb0[0].xx;
    r1.xz = v2.xy * cb4[0].xx + r1.xx;
    r1.xzw = t0.Sample(s0_s, r1.xz).xyz;
    r2.xy = v2.xy * cb4[1].xx + r1.yy;
    r2.xyz = t0.Sample(s0_s, r2.xy).xyz;
    r1.xyz = r2.xyz * r1.xzw;
    r0.x = dot(r1.xyz, float3(2,2,2));
    r1.x = 6 + cb2[0].x;
    r0.x = r0.x * r1.x + -0.330000013;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  if (r0.y != 0) {
    r1.xyzw = float4(16,16,16,16) * v6.xyxy;
    r1.xyzw = cmp(r1.xyzw >= -r1.zwzw);
    r1.xyzw = r1.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r0.xy = v6.xy * r1.zw;
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
    r0.x = t12.Sample(s12_s, v2.zw).x;
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
  r0.xy = cb4[2].xy * v2.xy;
  r1.x = -abs(cb4[3].x) + 1;
  r1.y = cb4[3].x;
  r2.x = dot(r1.xy, r0.xy);
  r1.z = -cb4[3].x;
  r2.y = dot(r1.zx, r0.xy);
  r0.xyzw = t1.Sample(s0_s, r2.xy).xyzw;
  r1.x = cb4[4].x * 0.25;
  r0.xyzw = float4(-0.5,-0.5,-0.5,-0.5) + r0.wxyz;
  r0.x = r1.x * r0.x;
  r1.x = v0.w;
  r1.y = v3.w;
  r1.z = v4.w;
  r1.xyz = cb1[8].xyz + -r1.xyz;
  r1.x = dot(r1.xyz, r1.xyz);
  r1.x = sqrt(r1.x);
  r1.x = saturate(cb4[5].x + -r1.x);
  r1.yz = cb4[7].xy * v2.xy;
  r1.yz = cb0[0].xx * cb4[6].xy + r1.yz;
  r1.yz = t0.Sample(s0_s, r1.yz).xy;
  r2.xy = cb4[9].xy * v2.xy;
  r2.xy = cb0[0].xx * cb4[8].xy + r2.xy;
  r2.xy = t0.Sample(s0_s, r2.xy).xy;
  r1.yz = r1.yz * r2.xy + float2(-0.0500000007,-0.0500000007);
  r1.yz = r1.yz * cb4[10].xx + v2.xy;
  r2.xyz = t2.Sample(s0_s, r1.yz).xyz;
  r2.xyz = r0.xxx * r1.xxx + r2.xyz;
  r1.w = r2.x + r2.y;
  r1.w = r1.w + r2.z;
  r2.w = 0.333299994 * r1.w;
  r3.x = cb4[12].x + -1;
  r3.x = 0.5 * r3.x;
  r3.y = saturate(r3.x);
  r1.w = r1.w * -0.666599989 + 1;
  r1.w = r3.y * r1.w + r2.w;
  r3.yzw = cb4[11].xyz * r2.xyz;
  r3.yzw = saturate(float3(1.5,1.5,1.5) * r3.yzw);
  r1.w = saturate(r1.w * abs(r3.x));
  r3.xyz = r3.yzw + -r2.xyz;
  o0.xyz = r1.www * r3.xyz + r2.xyz;
  r2.xyz = r0.yzw + r0.yzw;
  r3.xyzw = t3.Sample(s0_s, r1.yz).xyzw;
  r0.yzw = float3(-0.5,-0.5,-0.5) + r3.xyz;
  r2.w = 2;
  r0.yzw = r2.zzw * r0.yzw;
  r1.y = cb4[4].x * r1.x;
  r0.yz = r0.yz + r0.yz;
  r1.zw = r1.yy * r2.xy;
  r0.yz = r1.zw * r0.ww + r0.yz;
  r0.w = r0.w * r2.z;
  r2.xyz = v3.xyz * r0.zzz;
  r2.xyz = v5.xyz * r0.yyy + r2.xyz;
  r0.yzw = v4.xyz * r0.www + r2.xyz;
  r1.z = cmp(0 >= (uint)v7.x);
  if (r1.z != 0) {
    r1.z = dot(v4.xyz, r0.yzw);
    r2.xyz = v4.xyz * r1.zzz;
    r0.yzw = -r2.xyz * float3(2,2,2) + r0.yzw;
  }
  r1.x = -r0.x * r1.x + r3.w;
  r1.x = 1 + -r1.x;
  r2.xyz = log2(cb4[13].xyz);
  r2.xyz = float3(2.20000005,2.20000005,2.20000005) * r2.xyz;
  r2.xyz = exp2(r2.xyz);
  r1.x = r1.x * cb4[14].x + cb4[15].x;
  r1.xzw = saturate(r2.xyz * r1.xxx);
  r1.xzw = log2(r1.xzw);
  r1.xzw = float3(0.454544991,0.454544991,0.454544991) * r1.xzw;
  o2.xyz = exp2(r1.xzw);
  o1.w = saturate(r1.y * r0.x + r3.w);
  r0.x = dot(r0.yzw, r0.yzw);
  r0.x = rsqrt(r0.x);
  r0.xyz = r0.yzw * r0.xxx;
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
  o0.w = cb4[16].x;
  o2.w = 0;
  WriteObjectMotion(v6, previous_clip, motion_history, object_motion, object_depth);
  return;
}