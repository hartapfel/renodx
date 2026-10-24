// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 21:55:11 2026
Texture2D<float4> t13 : register(t13);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s13_s : register(s13);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb2 : register(b2)
{
  float4 cb2[1];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[7];
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
  float4 r0,r1,r2,r3,r4;
  uint4 bitmask, uiDest;
  float4 fDest;

  float4 x0[13];
  x0[0].xyz = float3(0,0,0);
  x0[1].xyz = float3(0.686200023,0.423500001,0.0901999995);
  x0[2].xyz = float3(0.160799995,0.0666999966,0.0234999992);
  x0[3].xyz = float3(0.411799997,0.674499989,0.223499998);
  x0[4].xyz = float3(0.180399999,0.41170001,0.176499993);
  x0[5].xyz = float3(0.905900002,0.415600002,0);
  x0[6].xyz = float3(1,0.713699996,0.176499993);
  x0[7].xyz = float3(0.149000004,0.5255,0.858799994);
  x0[8].xyz = float3(0.68629998,0.074500002,0.074500002);
  x0[9].xyz = float3(0.945100009,0.231399998,0.0392000005);
  x0[10].xyz = float3(0.537199974,0.533299983,0.407799989);
  x0[11].xyz = float3(0.443100005,0.835300028,0.705900013);
  x0[12].xyz = float3(0.67839998,0.0469999984,0.356900007);
  r0.x = trunc(cb2[0].w);
  r0.x = (uint)r0.x;
  r0.xyz = x0[r0.x+0].xyz;
  r1.xyzw = t2.Sample(s0_s, v0.zw).wxyz;
  r2.xyz = r1.zzz * r0.xyz;
  r0.xyz = r2.xyz * float3(-0.75,-0.75,-0.75) + r0.xyz;
  r0.w = -1 + cb4[1].x;
  r0.w = 0.5 * r0.w;
  r2.x = saturate(r0.w);
  r2.yzw = t0.Sample(s0_s, v0.xy).xyz;
  r3.x = r2.y + r2.z;
  r3.x = r3.x + r2.w;
  r3.y = 0.333299994 * r3.x;
  r3.x = r3.x * -0.666599989 + 1;
  r2.x = r2.x * r3.x + r3.y;
  r0.w = saturate(r2.x * abs(r0.w));
  r3.xyz = cb4[0].xyz * r2.yzw;
  r3.xyz = saturate(float3(1.5,1.5,1.5) * r3.xyz);
  r3.xyz = r3.xyz + -r2.yzw;
  r2.xyz = r0.www * r3.xyz + r2.yzw;
  r3.xyz = float3(0.0500000007,0.0500000007,0.0500000007) + -r2.xyz;
  r0.w = 0.100000001 + cb2[0].z;
  r2.w = floor(r0.w);
  r0.w = 0.25 * r0.w;
  r4.y = floor(r0.w);
  r4.x = 0.25 * r2.w;
  r4.xy = v0.zw * float2(0.25,1) + r4.xy;
  r4.xyzw = t1.Sample(s1_s, r4.xy).xyzw;
  r2.xyz = r4.www * r3.xyz + r2.xyz;
  r0.xyz = -r2.xyz + r0.xyz;
  r1.x = saturate(r1.x);
  r1.yzw = float3(-0.5,-0.5,-0.5) + r1.yzw;
  r0.w = cmp(cb2[0].w < 0.00999999978);
  r0.w = r0.w ? 0 : r1.x;
  o0.xyz = r0.www * r0.xyz + r2.xyz;
  o0.w = cb4[6].x;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r4.xyz;
  r2.x = cb4[2].x;
  r2.z = 2;
  r0.xyz = r2.xxz * r0.xyz;
  r2.xyzw = t3.Sample(s0_s, v0.xy).xyzw;
  r2.xyz = float3(-0.5,-0.5,-0.5) + r2.xyz;
  r2.xyz = r2.xyz + r2.xyz;
  r3.x = dot(r2.zzx, r0.xxz);
  r3.y = dot(r2.zzy, r0.yyz);
  r3.z = r2.z * r0.z;
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = rsqrt(r0.x);
  r0.xyz = r3.xyz * r0.xxx;
  r1.xyz = r1.yzw * float3(2,2,2) + -r0.xyz;
  r0.xyz = r0.www * r1.xyz + r0.xyz;
  r1.xyz = v1.xyz * r0.yyy;
  r1.xyz = v3.xyz * r0.xxx + r1.xyz;
  r0.xyz = v2.xyz * r0.zzz + r1.xyz;
  r1.x = dot(v2.xyz, r0.xyz);
  r1.xyz = v2.xyz * r1.xxx;
  r1.xyz = r1.xyz * float3(-2,-2,-2) + r0.xyz;
  r1.w = cmp(0 >= (uint)v4.x);
  r0.xyz = r1.www ? r1.xyz : r0.xyz;
  r1.x = dot(r0.xyz, r0.xyz);
  r1.x = rsqrt(r1.x);
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = ddx_coarse(r0.xyz);
  r1.x = dot(r1.xyz, r1.xyz);
  r1.yzw = ddy_coarse(r0.xyz);
  r1.y = dot(r1.yzw, r1.yzw);
  r1.x = r1.x + r1.y;
  r1.x = 0.5 * r1.x;
  r1.x = min(0.180000007, r1.x);
  r1.y = 0.600000024 + -r2.w;
  r1.y = r4.w * r1.y + r2.w;
  r1.z = 0.25 + -r1.y;
  r1.y = r0.w * r1.z + r1.y;
  r1.x = r1.y * r1.y + r1.x;
  r1.y = 1 + -r1.y;
  r1.x = min(1, r1.x);
  o1.w = sqrt(r1.x);
  r1.x = max(abs(r0.x), abs(r0.y));
  r1.x = max(r1.x, abs(r0.z));
  r1.zw = cmp(abs(r0.zy) < r1.xx);
  r2.xyz = r0.xyz / r1.xxx;
  r1.xw = r1.ww ? abs(r0.zy) : abs(r0.zx);
  r0.xy = r1.zz ? r1.xw : abs(r0.yx);
  r0.z = cmp(r0.y < r0.x);
  r0.xy = r0.zz ? r0.xy : r0.yx;
  r0.z = r0.y / r0.x;
  r0.x = t13.SampleLevel(s13_s, r0.xz, 0).x;
  r0.xyz = r2.xyz * r0.xxx;
  o1.xyz = r0.xyz * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
  r0.x = 0.5 + -r1.y;
  r0.x = r0.w * r0.x + r1.y;
  r0.x = r0.x * cb4[4].x + cb4[5].x;
  r0.yzw = log2(cb4[3].xyz);
  r0.yzw = float3(2.20000005,2.20000005,2.20000005) * r0.yzw;
  r0.yzw = exp2(r0.yzw);
  r0.xyz = saturate(r0.yzw * r0.xxx);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(0.454544991,0.454544991,0.454544991) * r0.xyz;
  o2.xyz = exp2(r0.xyz);
  o2.w = 0;
  WriteObjectMotion(motion_position, previous_clip, motion_history, object_motion, object_depth);
  return;
}