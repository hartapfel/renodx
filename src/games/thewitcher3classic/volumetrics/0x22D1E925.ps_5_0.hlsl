#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 18:43:58 2026
Texture2D<float4> t15 : register(t15);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s15_s : register(s15);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[21];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[268];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[3];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[10];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float3 v5 : TEXCOORD5,
  float4 v6 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;
  uint4 bitmask, uiDest;
  float4 fDest;
  // This material applies its own distance fade to atmospheric fog. Retain
  // that authored fade and alpha while replacing the L/T pair it consumes.
  if (ClassicFogReady()) {
    float4 fog = SampleClassicFogPixel(v6);
    float opacity = saturate(1.f-fog.a);
    v0 = float4(opacity > 1.e-7f ? fog.rgb/opacity : 0.f,opacity);
  }

  r0.xy = cb4[3].xy * cb0[0].xx;
  r0.xy = v1.xy * cb4[2].xy + r0.xy;
  r0.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = cb4[4].xyz * r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r1.x = dot(r0.xyz, r0.xyz);
  r1.x = rsqrt(r1.x);
  r0.xyz = r1.xxx * r0.xyz;
  r1.xyz = v3.xyz * r0.yyy;
  r1.xyz = v5.xyz * r0.xxx + r1.xyz;
  r0.xyz = v4.xyz * r0.zzz + r1.xyz;
  r1.xyz = float3(1,1,-1) * cb0[9].xyz;
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  r1.xyz = r1.xyz * r1.www;
  r0.x = saturate(dot(r1.xyz, r0.xyz));
  r0.y = cb4[7].x + -cb4[6].x;
  r0.y = r0.x * r0.y + cb4[6].x;
  r0.y = max(0, r0.y);
  r0.y = min(5, r0.y);
  r0.y = -cb4[5].x + r0.y;
  r0.z = dot(-cb0[9].xyz, -cb0[9].xyz);
  r0.z = rsqrt(r0.z);
  r1.xyz = -cb0[9].xyz * r0.zzz;
  r2.y = v3.w;
  r2.z = v4.w;
  r2.xw = v1.wz;
  r2.xyz = cb1[8].xyz + -r2.xyz;
  r0.z = dot(r2.xyz, r2.xyz);
  r1.w = rsqrt(r0.z);
  r0.z = sqrt(r0.z);
  r2.xyz = r2.xyz * r1.www;
  r1.x = saturate(dot(r1.xyz, r2.xyz));
  r0.y = r1.x * r0.y + cb4[5].x;
  r1.y = cb4[9].x + -cb4[8].x;
  r1.y = r1.x * r1.y + cb4[8].x;
  r1.y = r1.y + -r0.y;
  r1.z = saturate(cb0[9].z * 4 + -1);
  r0.y = r1.z * r1.y + r0.y;
  r1.y = cb4[11].x + -cb4[10].x;
  r1.y = r0.x * r1.y + cb4[10].x;
  r0.y = r1.y * r0.y;
  r0.y = log2(r0.y);
  r0.y = 2.20000005 * r0.y;
  r0.y = exp2(r0.y);
  r1.y = dot(cb0[9].xy, cb0[9].xy);
  r1.y = rsqrt(r1.y);
  r1.yz = cb0[9].xy * r1.yy;
  r1.y = saturate(dot(r1.yz, r2.xy));
  r2.xyz = -cb12[266].xyz + cb12[233].xyz;
  r2.xyz = r0.xxx * r2.xyz + cb12[266].xyz;
  r0.x = 0.00066666666 * r0.z;
  r0.x = min(1, r0.x);
  r3.xyz = float3(-1,-1,-1) + cb12[267].xyz;
  r3.xyz = r0.xxx * r3.xyz + float3(1,1,1);
  r3.xyz = r3.xyz * r2.xyz + -r2.xyz;
  r1.yzw = r1.yyy * r3.xyz + r2.xyz;
  r1.yzw = r1.yzw * r0.yyy;
  r2.xyz = -cb12[237].xyz * r1.yzw + v0.xyz;
  r1.yzw = cb12[237].xyz * r1.yzw;
  r2.xyz = v0.www * r2.xyz;
  r0.x = -cb4[0].x + r0.z;
  r0.y = -cb4[12].x + r0.z;
  r0.z = cb4[1].x + -cb4[0].x;
  r0.x = saturate(r0.x / r0.z);
  r1.yzw = r0.xxx * r2.xyz + r1.yzw;
  r1.yzw = cb2[2].xyz * r1.yzw;
  r0.xz = cb0[1].zw * v6.xy;
  r0.x = t15.SampleLevel(s15_s, r0.xz, 0).x;
  r0.x = r0.x * cb12[22].x + cb12[22].y;
  r0.x = r0.x * cb12[21].x + cb12[21].y;
  r0.x = max(9.99999975e-005, r0.x);
  r0.x = 1 / r0.x;
  r0.x = r0.x + -r2.w;
  r0.x = saturate(cb4[18].x * r0.x);
  r0.x = r0.w * r0.x;
  r0.z = cb4[13].x + -cb4[12].x;
  r0.y = saturate(r0.y / r0.z);
  r0.zw = cb4[17].xy * cb0[0].xx;
  r0.zw = v1.xy * cb4[16].xy + r0.zw;
  r0.z = t1.Sample(s0_s, r0.zw).x;
  r0.w = cb4[15].x + -cb4[14].x;
  r0.z = saturate(r0.z * r0.w + cb4[14].x);
  r0.w = -1 + v1.x;
  r0.w = saturate(v2.w * 2 + r0.w);
  r0.z = r0.w * r0.z;
  r0.w = r0.y * r0.z + -1;
  r0.y = r0.y * r0.z + -r0.w;
  r0.x = r0.x * r0.y + r0.w;
  r0.y = cb4[20].x + -cb4[19].x;
  r0.y = r1.x * r0.y + cb4[19].x;
  r0.x = saturate(r0.x * r0.y);
  r0.x = cb2[2].w * r0.x;
  o0.xyz = r1.yzw * r0.xxx;
  o0.w = r0.x;
  return;
}