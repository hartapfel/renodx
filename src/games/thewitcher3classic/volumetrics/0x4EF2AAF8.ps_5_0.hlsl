#include "sample.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 20:17:27 2026
Texture2D<float4> t15 : register(t15);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s15_s : register(s15);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[6];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[23];
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
  float4 cb0[2];
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
  out float4 o0 : SV_Target0,
  out float reflection_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5;
  uint4 bitmask, uiDest;
  float4 fDest;
  if (ClassicFogReady()) v1.w = 1.f - SampleClassicFogPixel(v6).a;


  r0.xyz = t0.Sample(s0_s, v2.xy).xyz;
  r0.x = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r0.x = 0.100000001 * r0.x;
  r0.yz = cb0[1].zw * v6.xy;
  r0.y = t15.SampleLevel(s15_s, r0.yz, 0).x;
  r0.y = r0.y * cb12[22].x + cb12[22].y;
  r0.y = r0.y * cb12[21].x + cb12[21].y;
  r0.y = max(9.99999975e-005, r0.y);
  r0.y = 1 / r0.y;
  r0.y = -v2.z + r0.y;
  r0.yz = saturate(float2(0.5,1.60000002) * r0.yy);
  r0.x = r0.x * r0.y;
  r1.xy = float2(-0.5,-0.5) + v2.xy;
  r1.xy = r1.xy + r1.xy;
  r1.xy = r1.xy * r1.xy;
  r0.w = r1.x + r1.y;
  r0.w = sqrt(r0.w);
  r0.w = min(1, r0.w);
  r1.x = cmp(r0.w >= 0.442595005);
  r1.yz = cmp(float2(0.995839,0.442595005) >= r0.ww);
  r1.x = r1.y ? r1.x : 0;
  r0.w = -0.442595005 + r0.w;
  r2.y = 1.80752075 * r0.w;
  r0.w = saturate(r2.y);
  r1.y = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.w = -r1.y * r0.w + 1;
  r2.z = r1.z ? 1.000000 : 0;
  r1.y = (int)r1.x | (int)r1.z;
  // DXBC AND selects the IEEE float bits for 1.0, not integer 1065353216.
  r1.z = r1.y ? 1.f : 0.f;
  r2.xw = float2(0,0.5);
  r2.xy = r1.xx ? r2.yx : r2.wz;
  r2.x = saturate(r2.x);
  r1.w = r2.x * -2 + 3;
  r2.x = r2.x * r2.x;
  r1.w = r2.x * r1.w;
  r1.y = r1.y ? -1 : -0;
  r1.y = r2.y + r1.y;
  r1.y = r1.w * r1.y + r1.z;
  r0.w = r1.x ? r0.w : r1.y;
  r1.xyzw = float4(-0.100000001,0.0500000007,-0.200000003,-0.0500000007) * cb0[0].xxxx;
  r2.xy = cb4[1].xy * v2.xy;
  r2.xy = cb0[0].xx * cb4[0].xy + r2.xy;
  r2.xy = t0.Sample(s0_s, r2.xy).xy;
  r2.zw = cb4[3].xy * v2.xy;
  r2.zw = cb0[0].xx * cb4[2].xy + r2.zw;
  r2.zw = t0.Sample(s0_s, r2.zw).xy;
  r2.xyzw = r2.xyxy * r2.zwzw + -cb4[4].xxxx;
  r1.xyzw = v2.xyxy * float4(0.600000024,0.600000024,0.5,0.5) + r1.xyzw;
  r1.xyzw = r2.xyzw * cb4[5].xxxx + r1.xyzw;
  r2.xyz = t1.Sample(s0_s, r1.xy).xyz;
  r1.xyz = t1.Sample(s0_s, r1.zw).xyz;
  r1.xyz = r2.xyz * r1.xyz;
  r1.x = dot(r1.xyz, float3(0.298999995,0.587000012,0.114));
  r1.x = log2(r1.x);
  r1.x = 0.25 * r1.x;
  r1.x = exp2(r1.x);
  r1.y = saturate(v2.x);
  r1.zw = cmp(float2(0.946421027,0.225306004) >= r1.yy);
  r2.w = 4.4384079 * r1.y;
  r3.x = min(1, r2.w);
  r3.y = r3.x * -2 + 3;
  r3.x = r3.x * r3.x;
  r3.xyz = r3.yyy * r3.xxx;
  r2.xyz = float3(1,1,1);
  r2.xyzw = r1.wwww ? r2.xyzw : float4(0,0,0,0.5);
  r3.w = ~(int)r1.w;
  if (r1.w == 0) {
    r1.w = cmp(0.462695003 >= r1.y);
    r4.x = -0.225306004 + r1.y;
    r4.w = 4.21249533 * r4.x;
    r5.x = saturate(r4.w);
    r5.y = r5.x * -2 + 3;
    r5.x = r5.x * r5.x;
    r5.x = r5.y * r5.x;
    r5.x = r5.x * -0.0341849923 + 1;
    r4.xyz = float3(0.965815008,0.965815008,0.965815008);
    r2.xyzw = r1.wwww ? r4.xyzw : r2.xyzw;
    r3.xyz = r1.www ? r5.xxx : r3.zzz;
    r4.xyz = r1.www ? float3(1,1,1) : 0;
  } else {
    r4.xyz = float3(0,0,0);
    r1.w = -1;
  }
  r4.w = ~(int)r1.w;
  r3.w = (int)r3.w & (int)r4.w;
  if (r3.w != 0) {
    r1.w = cmp(r1.y >= 0.462695003);
    r1.y = -0.462695003 + r1.y;
    r5.w = 2.06728601 * r1.y;
    r1.y = saturate(r5.w);
    r3.w = r1.y * -2 + 3;
    r1.y = r1.y * r1.y;
    r1.y = r3.w * r1.y;
    r1.y = r1.y * -0.965815008 + 0.965815008;
    r5.xyz = float3(0,0,0);
    r2.xyzw = r1.wwww ? r5.xyzw : r2.xyzw;
    r3.xyz = r1.www ? r1.yyy : r3.xyz;
    r4.xyz = r1.www ? float3(0.965815008,0.965815008,0.965815008) : r4.xyz;
  }
  r4.xyz = r1.zzz ? r4.xyz : 0;
  r2.xyzw = r1.zzzz ? r2.wxyz : float4(0.5,0,0,0);
  r1.y = r1.w ? r1.z : 0;
  r2.x = saturate(r2.x);
  r1.z = r2.x * -2 + 3;
  r1.w = r2.x * r2.x;
  r1.z = r1.z * r1.w;
  r2.xyz = r2.yzw + -r4.xyz;
  r2.xyz = r1.zzz * r2.xyz + r4.xyz;
  r1.yzw = r1.yyy ? r3.xyz : r2.xyz;
  r0.y = 1 + -r0.y;
  r0.xy = r0.xw * r0.wy;
  r0.y = r0.y * r0.z;
  r0.y = dot(r0.yy, v3.ww);
  r0.yzw = r1.yzw * r0.yyy;
  r1.yzw = cb1[8].xyz + -v5.xyz;
  r2.x = dot(r1.yzw, r1.yzw);
  r2.x = rsqrt(r2.x);
  r1.yzw = r2.xxx * r1.yzw;
  r1.y = dot(v4.xyz, r1.yzw);
  r1.y = 1 + -abs(r1.y);
  r1.y = max(0, r1.y);
  r1.z = -r1.y * r1.y + 1;
  r0.yzw = r1.zzz * r0.yzw;
  r0.yzw = r1.xxx * r0.yzw;
  r0.xyz = r0.xxx * v3.www + r0.yzw;
  r0.xyz = float3(2.97647095,2.01176405,1.42352998) * r0.xyz;
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(1.29999995,1.29999995,1.29999995) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.w = rsqrt(r1.y);
  r0.w = 1 / r0.w;
  r0.w = 1 + -r0.w;
  r0.xyz = r0.www * r0.xyz;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(2.20000005,2.20000005,2.20000005) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = cb2[2].xyz * r0.xyz;
  r0.w = saturate(1 + -v1.w);
  r0.w = cb2[2].w * r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  // Capture only visible emission, not transparent billboard corners.
  reflection_depth = dot(max(o0.rgb,0.f),float3(.2126f,.7152f,.0722f))>1.e-3f
      ? min(65504.f,abs(v6.w)) : 65504.f;
  return;
}
