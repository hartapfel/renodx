#include "../lighting/parameters.hlsli"
ByteAddressBuffer Raw20 : register(t20);
// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 12:40:52 2026
Texture2D<float4> t18 : register(t18);

Texture2D<float4> t17 : register(t17);

TextureCubeArray<float4> t10 : register(t10);

Texture2DArray<float4> t9 : register(t9);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s10_s : register(s10);

SamplerState s0_s : register(s0);

cbuffer cb13 : register(b13)
{
  float4 cb13[2362];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[16];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[219];
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


#ifndef RENO_NO_OBJECT_MOTION
#include "./object_pixel.hlsli"
#endif

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float4 v5 : TEXCOORD5,
  float4 v6 : TEXCOORD6,
  float4 v7 : TEXCOORD7,
  float4 v8 : SV_Position0,
#ifndef RENO_NO_OBJECT_MOTION
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
#endif
  uint v9 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0
#ifndef RENO_NO_OBJECT_MOTION
  ,
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4
#endif
)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v1.w;
  r0.y = v2.w;
  r1.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r0.z = -0.330000013 + r1.w;
  r0.w = cmp(r0.z < 0);
  if (r0.w != 0) discard;
  r0.w = cmp(cb2[18].y != 0.000000);
  if (r0.w != 0) {
    r2.xyzw = float4(16,16,16,16) * v8.xyxy;
    r2.xyzw = cmp(r2.xyzw >= -r2.zwzw);
    r2.xyzw = r2.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r2.zw = v8.xy * r2.zw;
    r2.zw = frac(r2.zw);
    r2.xy = r2.xy * r2.zw;
    r2.xy = (int2)r2.xy;
    r2.zw = float2(0,0);
    r0.w = t18.Load(r2.xyz).x;
    r0.w = r0.w * v0.x + v0.y;
    r0.w = cmp(r0.w < 0);
    if (r0.w != 0) discard;
  }
  r0.w = r1.x + r1.y;
  r0.w = r0.w + r1.z;
  r2.x = 0.333299994 * r0.w;
  r2.y = cb4[1].x + -1;
  r2.y = 0.5 * r2.y;
  r2.z = saturate(r2.y);
  r0.w = r0.w * -0.666599989 + 1;
  r0.w = r2.z * r0.w + r2.x;
  r3.xyzw = cb4[0].xyzw * r1.xyzw;
  r3.xyzw = saturate(float4(1.5,1.5,1.5,1.5) * r3.xyzw);
  r0.w = saturate(r0.w * abs(r2.y));
  r2.xyzw = r3.xyzw + -r1.xyzw;
  r2.xyzw = r0.wwww * r2.xyzw + r1.xyzw;
  r0.w = cmp(0 < cb4[3].x);
  if (r0.w != 0) {
    r0.w = r2.x + r2.z;
    r3.xy = r2.xz / r0.ww;
    r3.xy = float2(-0.300000012,-0.300000012) + r3.xy;
    r3.xy = saturate(float2(1.42857146,1.42857146) * r3.xy);
    r0.w = r3.x + r3.y;
    r0.w = r3.y / r0.w;
    r3.x = 1 + -r0.w;
    r4.xyzw = cb2[11].zyxw * r0.wwww;
    r5.xyzw = cb2[12].zyxw * r0.wwww;
    r6.xyzw = cb2[13].zyxw * r0.wwww;
    r4.xyzw = r3.xxxx * cb2[7].xyzw + r4.xyzw;
    r5.xyzw = r3.xxxx * cb2[8].xyzw + r5.xyzw;
    r3.xyzw = r3.xxxx * cb2[9].xyzw + r6.xyzw;
  } else {
    r0.w = cmp(r2.x >= r2.z);
    r4.xyzw = r0.wwww ? cb2[7].xyzw : cb2[11].zyxw;
    r5.xyzw = r0.wwww ? cb2[8].xyzw : cb2[12].zyxw;
    r3.xyzw = r0.wwww ? cb2[9].xyzw : cb2[13].zyxw;
  }
  r0.w = cmp(0 < cb4[4].x);
  if (r0.w != 0) {
    r0.w = min(r2.y, r2.z);
    r0.w = min(r2.x, r0.w);
    r6.x = max(r2.y, r2.z);
    r6.x = max(r6.x, r2.x);
    r0.w = r6.x + -r0.w;
    r0.w = r0.w / r6.x;
    r0.w = -0.100000001 + r0.w;
    r0.w = saturate(5 * r0.w);
    r0.w = cb4[2].x * r0.w;
  } else {
    r0.w = cb4[2].x;
  }
  r6.xyzw = t1.Sample(s0_s, r0.xy).wxyz;
  r6.yzw = float3(-0.5,-0.5,-0.5) + r6.yzw;
  r6.yzw = r6.yzw + r6.yzw;
  r7.x = v5.w;
  r7.y = v6.w;
  r7.z = v7.w;
  r8.xyz = v5.xyz * r6.zzz;
  r8.xyz = r7.xyz * r6.yyy + r8.xyz;
  r6.yzw = v6.xyz * r6.www + r8.xyz;
  r7.w = cmp(0 >= (uint)v9.x);
  if (r7.w != 0) {
    r7.w = dot(v6.xyz, r6.yzw);
    r8.xyz = v6.xyz * r7.www;
    r8.xyz = -r8.xyz * float3(2,2,2) + r6.yzw;
  } else {
    r8.xyz = r6.yzw;
  }
  r0.xy = cb4[14].xy * r0.xy;
  r0.x = t2.Sample(s0_s, r0.xy).x;
  r0.y = cmp(r0.z >= 0);
  if (r0.y != 0) {
    r4.x = dot(r2.xyzw, r4.xyzw);
    r4.y = dot(r2.xyzw, r5.xyzw);
    r4.z = dot(r2.xyzw, r3.xyzw);
    r3.xyz = r4.xyz + -r2.xyz;
    r0.yzw = r0.www * r3.xyz + r2.xyz;
    r0.yzw = saturate(v4.xyz * r0.yzw);
    r2.x = 1 + -r6.x;
    r2.yzw = log2(cb4[5].xyz);
    r2.yzw = float3(2.20000005,2.20000005,2.20000005) * r2.yzw;
    r2.yzw = exp2(r2.yzw);
    r2.x = r2.x * cb4[6].x + cb4[7].x;
    r2.xyz = saturate(r2.yzw * r2.xxx);
    r2.xyz = log2(r2.xyz);
    r3.xyz = cb1[8].xyz + -v7.xyz;
    r2.w = dot(r3.xyz, r3.xyz);
    r2.w = rsqrt(r2.w);
    r3.xyz = r3.xyz * r2.www;
    r2.w = dot(r6.yzw, r3.xyz);
    r2.w = saturate(1 + -r2.w);
    r2.w = r2.w * r2.w;
    r2.w = log2(r2.w);
    r2.w = cb4[8].x * r2.w;
    r2.w = exp2(r2.w);
    r2.w = cb4[9].x * r2.w;
    r2.w = saturate(cb4[10].x * r2.w);
    r3.x = saturate(cb4[11].x);
    r0.x = -0.5 + r0.x;
    r0.x = cb4[15].x * r0.x;
    r3.y = max(0.00100000005, v3.w);
    r4.xyz = v1.xyz / r3.yyy;
    r3.yzw = v2.xyz / r3.yyy;
    r0.yzw = log2(r0.yzw);
    r0.yzw = float3(2.20000005,2.20000005,2.20000005) * r0.yzw;
    r0.yzw = exp2(r0.yzw);
    r2.xyz = float3(0.999998987,0.999998987,0.999998987) * r2.xyz;
    r2.xyz = exp2(r2.xyz);
    r6.x = saturate(r6.x);
    r5.xy = (uint2)v8.xy;
    r4.w = dot(r8.xyz, r8.xyz);
    r4.w = rsqrt(r4.w);
    r6.yzw = r8.xyz * r4.www;
    r4.w = dot(v6.xyz, v6.xyz);
    r4.w = rsqrt(r4.w);
    r8.xyz = v6.xyz * r4.www;
    r9.xy = (uint2)r5.xy >> int2(4,4);
    r4.w = (int)cb12[24].x;
    r4.w = mad((int)r9.y, (int)r4.w, (int)r9.x);
    r4.w = (uint)r4.w << 8;
    r9.xyz = cb12[0].xyz + -v7.xyz;
    r7.w = dot(r9.xyz, r9.xyz);
    r7.w = rsqrt(r7.w);
    r10.xyz = r9.xyz * r7.www;
    r8.w = cmp(0.00100000005 < v3.w);
    r11.xyz = v3.xyz / v3.www;
    r11.xy = saturate(r11.xy);
    r11.z = saturate(1.00196469 * r11.z);
    r11.xyz = r8.www ? r11.xyz : float3(0,0,0.5);
    r8.w = cmp(0 < r11.x);
    if (r8.w != 0) {
      r8.w = dot(r8.xyz, cb13[0].xyz);
      r8.w = cb4[12].x + r8.w;
      r9.w = cb4[12].x + 1;
      r8.w = saturate(r8.w / r9.w);
      r9.w = dot(r6.yzw, cb13[0].xyz);
      r10.w = r9.w + r8.w;
      r8.w = 1 + r8.w;
      r10.w = r10.w / r8.w;
      r8.w = 1 / r8.w;
      r12.xyz = saturate(r10.www);
      r13.xyz = r9.xyz * r7.www + cb13[0].xyz;
      r10.w = dot(r13.xyz, r13.xyz);
      r10.w = rsqrt(r10.w);
      r13.xyz = r13.xyz * r10.www;
      r10.w = dot(r13.xyz, r10.xyz);
      r10.w = 1 + -abs(r10.w);
      r10.w = max(0, r10.w);
      r11.w = r10.w * r10.w;
      r11.w = r11.w * r11.w;
      r10.w = r11.w * r10.w;
      r11.w = 1 + -r6.x;
      r14.xyz = float3(1,1,1) + -r2.xyz;
      r15.xyz = cb13[56].xxx * r14.xyz;
      r15.xyz = r15.xyz * r10.www;
      r10.w = 1 + cb13[56].z;
      r10.w = -cb13[56].z * r11.w + r10.w;
      r15.xyz = r15.xyz / r10.www;
      r15.xyz = r15.xyz + r2.xyz;
      r16.xyz = float3(1,1,1) + -r15.xyz;
      r16.xyz = r16.xyz * r12.zzz;
      r16.xyz = float3(0.318309873,0.318309873,0.318309873) * r16.xyz;
      r10.w = cmp(0 < r2.w);
      if (r10.w != 0) {
        r10.w = 1 + r9.w;
        r10.w = 0.5 * r10.w;
        r11.w = dot(cb13[0].xyz, -r10.xyz);
        r11.w = 1 + r11.w;
        r11.w = 0.5 * r11.w;
        r12.w = dot(r6.yzw, -r10.xyz);
        r12.w = 1 + r12.w;
        r12.w = cb12[36].w * r12.w;
        r11.w = r11.w * r11.w;
        r12.w = 0.5 * r12.w;
        r11.w = r11.w * r11.w + -r10.w;
        r10.w = cb12[36].x * r11.w + r10.w;
        r10.w = r12.w * r10.w;
        r11.w = cb12[36].y * r2.w;
        r14.xyz = cb12[36].zzz * r14.xyz + -r16.xyz;
        r14.xyz = r11.www * r14.xyz + r16.xyz;
        r16.xyz = r10.www * r2.www + r14.xyz;
      }
      r14.xyz = r16.xyz * r8.www;
      r16.xy = -cb12[0].xy + v7.xy;
      r8.w = dot(r16.xy, r16.xy);
      r8.w = sqrt(r8.w);
      r10.w = saturate(v7.z * cb12[218].z + cb12[218].w);
      r16.xyz = -cb13[52].xyz + cb13[51].xyz;
      r16.xyz = r10.www * r16.xyz + cb13[52].xyz;
      r8.w = saturate(r8.w * cb12[218].x + cb12[218].y);
      r16.xyz = -cb13[1].xyz + r16.xyz;
      r16.xyz = r8.www * r16.xyz + cb13[1].xyz;
      r14.xyz = r14.xyz * r11.xxx;
      r14.xyz = r14.xyz * r16.xyz;
      r8.w = cmp(0 < r9.w);
      if (r8.w != 0) {
        r8.w = dot(r6.yzw, r10.xyz);
        r9.w = saturate(r9.w);
        r10.w = r6.x * r6.x;
        r11.w = 1 + -r3.x;
        r11.w = r11.w * r10.w;
        r10.w = max(9.99999975e-005, r10.w);
        r11.w = max(9.99999975e-005, r11.w);
        r12.w = dot(r7.xyz, r7.xyz);
        r12.w = rsqrt(r12.w);
        r17.xyz = r12.www * r7.xyz;
        r12.w = dot(r17.xyz, r6.yzw);
        r17.xyz = -r6.yzw * r12.www + r17.xyz;
        r12.w = dot(r17.xyz, r17.xyz);
        r12.w = rsqrt(r12.w);
        r17.xyz = r17.xyz * r12.www;
        r18.xyz = r17.zxy * r6.zwy;
        r18.xyz = r17.yzx * r6.wyz + -r18.xyz;
        r18.xyz = r6.yzw * r0.xxx + r18.xyz;
        r12.w = dot(r18.xyz, r18.xyz);
        r12.w = rsqrt(r12.w);
        r18.xyz = r18.xyz * r12.www;
        r12.w = dot(r17.xyz, r13.xyz);
        r12.w = r12.w / r10.w;
        r13.w = dot(r18.xyz, r13.xyz);
        r13.w = r13.w / r11.w;
        r13.w = r13.w * r13.w;
        r13.x = saturate(dot(r6.yzw, r13.xyz));
        r10.w = r11.w * r10.w;
        r10.w = 3.14152002 * r10.w;
        r11.w = r12.w * r12.w + r13.w;
        r11.w = r13.x * r13.x + r11.w;
        r11.w = r11.w * r11.w;
        r10.w = r11.w * r10.w;
        r10.w = 1 / r10.w;
        r11.w = 1 + r6.x;
        r11.w = r11.w * r11.w;
        r12.w = 0.125 * r11.w;
        r11.w = -r11.w * 0.125 + 1;
        r13.x = r9.w * r11.w + r12.w;
        r13.x = r9.w / r13.x;
        r11.w = abs(r8.w) * r11.w + r12.w;
        r11.w = abs(r8.w) / r11.w;
        r11.w = r13.x * r11.w;
        r10.w = r11.w * r10.w;
        r13.xyz = r10.www * r15.xyz;
        r8.w = r9.w * abs(r8.w);
        r8.w = 4 * r8.w;
        r13.xyz = r13.xyz / r8.www;
        r13.xyz = r13.xyz * r9.www;
      } else {
        r13.xyz = float3(0,0,0);
      }
      r13.xyz = r13.xyz * r11.xxx;
      r13.xyz = r13.xyz * r16.xyz;
    } else {
      r12.xyz = float3(0,0,0);
      r14.xyz = float3(0,0,0);
      r13.xyz = float3(0,0,0);
    }
    r12.xyz = min(r12.xyz, r11.xxx);
    r8.w = cmp(r11.z == 1.000000);
    r9.w = cmp(cb2[16].x < 0);
    r9.w = r9.w ? 1 : cb12[71].x;

    r10.w = cb4[12].x + 1;
    r11.x = 1 + -r6.x;
    r15.xyz = float3(1,1,1) + -r2.xyz;
    r16.xyz = cb13[56].xxx * r15.xyz;
    r11.zw = float2(1,1) + cb13[56].zw;
    r11.xz = -cb13[56].zw * r11.xx + r11.zw;
    r11.w = cmp(0 < r2.w);
    r12.w = dot(r6.yzw, -r10.xyz);
    r12.w = 1 + r12.w;
    r12.w = cb12[36].w * r12.w;
    r12.w = 0.5 * r12.w;
    r13.w = cb12[36].y * r2.w;
    r14.w = dot(r6.yzw, r10.xyz);
    r15.w = r6.x * r6.x;
    r3.x = 1 + -r3.x;
    r3.x = r3.x * r15.w;
    r15.w = max(9.99999975e-005, r15.w);
    r3.x = max(9.99999975e-005, r3.x);
    r16.w = dot(r7.xyz, r7.xyz);
    r16.w = rsqrt(r16.w);
    r7.xyz = r16.www * r7.xyz;
    r16.w = dot(r7.xyz, r6.yzw);
    r7.xyz = -r6.yzw * r16.www + r7.xyz;
    r16.w = dot(r7.xyz, r7.xyz);
    r16.w = rsqrt(r16.w);
    r7.xyz = r16.www * r7.xyz;
    r17.xyz = r7.zxy * r6.zwy;
    r17.xyz = r7.yzx * r6.wyz + -r17.xyz;
    r17.xyz = r6.yzw * r0.xxx + r17.xyz;
    r0.x = dot(r17.xyz, r17.xyz);
    r0.x = rsqrt(r0.x);
    r17.xyz = r17.xyz * r0.xxx;
    r0.x = r3.x * r15.w;
    r0.x = 3.14152002 * r0.x;
    r6.x = 1 + r6.x;
    r6.x = r6.x * r6.x;
    r16.w = 0.125 * r6.x;
    r6.x = -r6.x * 0.125 + 1;
    r17.w = abs(r14.w) * r6.x + r16.w;
    r17.w = abs(r14.w) / r17.w;
    r18.x = 4 * abs(r14.w);
    r18.y = r8.w ? 1.000000 : 0;
    r8.w = r8.w ? 0 : 1;
    r19.xyz = r14.xyz;
    r20.xyz = r13.xyz;
    r18.z = 0;
    while (true) {
      r18.w = cmp((int)r18.z >= 256);
      if (r18.w != 0) break;
      r18.w = (int)r4.w + (int)r18.z;
      r18.w = (uint)r18.w << 2;
    r18.w = Raw20.Load((uint)r18.w);
      r19.w = cmp((uint)r18.w >= 256);
      if (r19.w != 0) {
        break;
      }
      r18.w = (int)r18.w * 9;
      r21.xyz = cb13[r18.w+58].xyz + -v7.xyz;
      r19.w = dot(r21.xyz, r21.xyz);
      r20.w = sqrt(r19.w);
      r22.x = r20.w / cb13[r18.w+58].w;
      r22.y = r22.x * r22.x;
      r22.y = -r22.y * r22.y + 1;
      r22.y = max(0, r22.y);
      r22.y = r22.y * r22.y;
      r23.xyz = int3(1,2048,4096) & asint(cb13[r18.w+61].www);
      r22.z = cmp(0 < cb13[r18.w+63].z);
      r22.w = cmp(0 < cb13[r18.w+64].x);
      r23.w = r19.w * cb13[r18.w+63].x + 1;
      r22.y = r22.y / r23.w;
      if (r23.x != 0) {
        r23.w = rsqrt(r19.w);
        r24.xyz = r23.www * r21.xyz;
        r23.w = dot(-r24.xyz, cb13[r18.w+60].xyz);
        r23.w = saturate(r23.w * cb13[r18.w+62].y + cb13[r18.w+62].z);
        r23.w = log2(r23.w);
        r23.w = cb13[r18.w+62].w * r23.w;
        r23.w = exp2(r23.w);
        r22.y = r23.w * r22.y;
      }
      r23.w = cmp(0 < r22.y);
      r22.z = r22.z ? r23.w : 0;
      if (r22.z != 0) {
        if (r23.x != 0) {
          r24.xyz = -cb13[r18.w+58].xyz + v7.xyz;
          r25.xyz = cb13[r18.w+65].zwy * cb13[r18.w+60].zxy;
          r25.xyz = cb13[r18.w+60].yzx * cb13[r18.w+65].wyz + -r25.xyz;
          r25.x = dot(r25.xyz, r24.xyz);
          r25.y = dot(cb13[r18.w+65].yzw, r24.xyz);
          r25.z = dot(cb13[r18.w+60].xyz, r24.xyz);
          r25.w = cb13[r18.w+65].x;
        } else {
          r24.xyz = -cb13[r18.w+58].xzy + v7.xzy;
          r26.xyz = r21.xyz / r20.www;
          r20.w = max(abs(r26.y), abs(r26.z));
          r20.w = cmp(r20.w < abs(r26.x));
          if (r20.w != 0) {
            r20.w = cmp(0 < r26.x);
            r27.xyz = float3(1,1,-1) * r24.zyx;
            r27.w = cb13[r18.w+65].x;
            r28.xyz = float3(-1,1,1) * r24.zyx;
            r28.w = cb13[r18.w+65].y;
            r25.xyzw = r20.wwww ? r27.xyzw : r28.xyzw;
          } else {
            r20.w = max(abs(r26.x), abs(r26.z));
            r20.w = cmp(r20.w < abs(r26.y));
            if (r20.w != 0) {
              r20.w = cmp(0 < r26.y);
              r27.xyz = float3(-1,1,-1) * r24.xyz;
              r27.w = cb13[r18.w+65].z;
              r24.w = cb13[r18.w+65].w;
              r25.xyzw = r20.wwww ? r27.xyzw : r24.xyzw;
            } else {
              r20.w = cmp(0 < r26.z);
              r25.x = r24.x;
              r25.y = r20.w ? r24.z : -r24.z;
              r25.z = r20.w ? -r24.y : r24.y;
              r25.w = r20.w ? cb13[r18.w+66].x : cb13[r18.w+66].y;
            }
          }
        }
        r24.xy = cb13[r18.w+63].yy * r25.xy;
        r24.xy = r24.xy / r25.zz;
        r24.xy = r24.xy * float2(0.5,-0.5) + float2(0.5,0.5);
        float4 atlas = DecodeShadowAtlas(r25.w);
        r24.z = atlas.x;
        r24.w = atlas.y;
        r20.w = atlas.z;
        r25.z = atlas.w;
        r22.z = cmp(0 < r20.w);
        if (r22.z != 0) {
          r24.xy = r24.xy * r20.ww + r24.zw;
          r25.xy = float2(0.0009765625,0.0009765625) * r24.xy;
          r20.w = t9.SampleLevel(s10_s, r25.xyz, 0).x;
          r20.w = -r22.x * 0.99000001 + r20.w;
          r20.w = 144.269501 * r20.w;
          r20.w = exp2(r20.w);
          r20.w = min(1, r20.w);
        } else {
          r20.w = 1;
        }
      } else {
        r20.w = 1;
      }
      r22.z = r22.w ? r23.w : 0;
      if (r22.z != 0) {
        r21.w = cb13[r18.w+64].y;
        r21.w = t10.SampleLevel(s10_s, r21.xyzw, 0).x;
        r21.w = -r22.x * 0.99000001 + r21.w;
        r21.w = 144.269501 * r21.w;
        r21.w = exp2(r21.w);
        r21.w = min(1, r21.w);
        r20.w = r21.w * r20.w;
      }
      r20.w = -1 + r20.w;
      r20.w = cb13[r18.w+60].w * r20.w + 1;
      r20.w = r22.y * r20.w;
      r21.w = r23.y ? 1 : r18.y;
      r22.x = r23.z ? 1 : r8.w;
      r21.w = r22.x * r21.w;
      r20.w = r21.w * r20.w;
      r21.w = cmp(0 < r20.w);
      if (r21.w != 0) {
        r21.w = 0x80000000 & asint(cb13[r18.w+61].w);
        r21.w = r21.w ? r9.w : 1;
        r20.w = r21.w * r20.w;
        r19.w = rsqrt(r19.w);
        r21.xyz = r21.xyz * r19.www;
        r19.w = dot(r8.xyz, r21.xyz);
        r19.w = cb4[12].x + r19.w;
        r19.w = saturate(r19.w / r10.w);
        r21.w = dot(r6.yzw, r21.xyz);
        r22.x = r21.w + r19.w;
        r19.w = 1 + r19.w;
        r22.x = saturate(r22.x / r19.w);
        r19.w = 1 / r19.w;
        r22.yzw = r9.xyz * r7.www + r21.xyz;
        r23.x = dot(r22.yzw, r22.yzw);
        r23.x = rsqrt(r23.x);
        r22.yzw = r23.xxx * r22.yzw;
        r23.x = dot(r22.yzw, r10.xyz);
        r23.x = 1 + -abs(r23.x);
        r23.x = max(0, r23.x);
        r23.y = r23.x * r23.x;
        r23.y = r23.y * r23.y;
        r23.x = r23.y * r23.x;
        r23.xyz = r23.xxx * r16.xyz;
        r23.xyz = r23.xyz / r11.xxx;
        r23.xyz = r23.xyz + r2.xyz;
        r24.xyz = float3(1,1,1) + -r23.xyz;
        r24.xyz = r24.xyz * r22.xxx;
        r24.xyz = float3(0.318309873,0.318309873,0.318309873) * r24.xyz;
        if (r11.w != 0) {
          r22.x = 1 + r21.w;
          r22.x = 0.5 * r22.x;
          r21.x = dot(r21.xyz, -r10.xyz);
          r21.x = 1 + r21.x;
          r21.x = 0.5 * r21.x;
          r21.x = r21.x * r21.x;
          r21.x = r21.x * r21.x + -r22.x;
          r21.x = cb12[36].x * r21.x + r22.x;
          r21.x = r21.x * r12.w;
          r25.xyz = cb12[36].zzz * r15.xyz + -r24.xyz;
          r25.xyz = r13.www * r25.xyz + r24.xyz;
          r24.xyz = r21.xxx * r2.www + r25.xyz;
        }
        r21.xyz = r24.xyz * r19.www;
        r21.xyz = cb13[r18.w+61].xyz * r21.xyz;
        r19.xyz = r20.www * r21.xyz + r19.xyz;
        r19.w = cmp(0 < r21.w);
        if (r19.w != 0) {
          r21.w = saturate(r21.w);
          r19.w = dot(r7.xyz, r22.yzw);
          r19.w = r19.w / r15.w;
          r21.x = dot(r17.xyz, r22.yzw);
          r21.x = r21.x / r3.x;
          r21.x = r21.x * r21.x;
          r21.y = saturate(dot(r6.yzw, r22.yzw));
          r19.w = r19.w * r19.w + r21.x;
          r19.w = r21.y * r21.y + r19.w;
          r19.w = r19.w * r19.w;
          r19.w = r19.w * r0.x;
          r19.w = 1 / r19.w;
          r21.x = r21.w * r6.x + r16.w;
          r21.x = r21.w / r21.x;
          r21.x = r21.x * r17.w;
          r19.w = r21.x * r19.w;
          r21.xyz = r19.www * r23.xyz;
          r19.w = r21.w * r18.x;
          r21.xyz = r21.xyz / r19.www;
          r21.xyz = r21.xyz * r21.www;
        } else {
          r21.xyz = float3(0,0,0);
        }
        r21.xyz = cb13[r18.w+61].xyz * r21.xyz;
        r20.xyz = r20.www * r21.xyz + r20.xyz;
      }
      r18.z = (int)r18.z + 1;
    }
    r0.x = abs(cb2[16].x) + -cb2[16].y;
    r6.xyz = r12.xyz * r0.xxx + cb2[16].yyy;
    r0.x = cb2[16].z + -cb2[16].w;
    r7.xyz = r12.xyz * r0.xxx + cb2[16].www;
    r4.xyz = r6.xyz * r4.xyz;
    r3.xyz = r7.xyz * r3.yzw;
    r6.xy = -cb12[0].xy + v7.xy;
    r0.x = dot(r6.xy, r6.xy);
    r0.x = sqrt(r0.x);
    r0.x = saturate(r0.x * cb12[218].x + cb12[218].y);
    r3.w = -1 + cb12[184].z;
    r0.x = r0.x * r3.w + 1;
    r3.w = cb12[183].x + -cb12[183].y;
    r6.xyz = r12.xyz * r3.www + cb12[183].yyy;
    r6.xyz = r6.xyz * r0.xxx;
    r3.w = cb12[184].x + -cb12[184].y;
    r7.xyz = r12.xyz * r3.www + cb12[184].yyy;
    r7.xyz = r7.xyz * r0.xxx;
    r9.xyz = cb12[183].zzz * r19.xyz;
    r12.xyz = cb12[183].www * r20.xyz;
    r4.xyz = r6.xyz * r4.xyz;
    r0.x = dot(r8.xyz, r10.xyz);
    r0.x = max(abs(r14.w), abs(r0.x));
    r0.x = 1 + -r0.x;
    r0.x = max(0, r0.x);
    r3.w = r0.x * r0.x;
    r3.w = r3.w * r3.w;
    r0.x = r3.w * r0.x;
    r3.w = min(0.25, cb13[56].y);
    r6.xyz = r3.www * r15.xyz;
    r6.xyz = r6.xyz * r0.xxx;
    r6.xyz = r6.xyz / r11.zzz;
    r2.xyz = r6.xyz + r2.xyz;
    r6.xyz = float3(1,1,1) + -r2.xyz;
    r4.xyz = r6.xyz * r4.xyz;
    r3.xyz = r7.xyz * r3.xyz;
    r2.xyz = r3.xyz * r2.xyz;
    r5.zw = float2(0,0);
    r0.x = t17.Load(r5.xyz).x;
    r3.xyz = saturate(r0.xxx * cb12[186].xyz + cb12[187].xyz);
    r0.x = saturate(cb4[13].x);
    r3.xyz = float3(-1,-1,-1) + r3.xyz;
    r3.xyz = r3.xyz * r0.xxx;
    r0.x = -1 + cb12[69].z;
    r0.x = r2.w * r0.x + 1;
    r3.xyz = r0.xxx * r3.xyz + float3(1,1,1);
    r5.xyz = r11.yyy * r3.xyz;
    r3.xyz = AMBIENT_ONLY_AO ? 1.f : cb12[69].xxx * r3.xyz + cb12[69].yyy;
    r6.xyz = r9.xyz * r3.xyz;
    r3.xyz = r12.xyz * r3.xyz;
    r4.xyz = r4.xyz * r5.xyz + r6.xyz;
    r0.xyz = r0.yzw * r4.xyz + r3.xyz;
    r1.xyz = r2.xyz * r5.xyz + r0.xyz;
  } else {
    r1.xyz = float3(0,0,0);
  }
  o0.xyzw = r1.xyzw;
#ifndef RENO_NO_OBJECT_MOTION
  WriteObjectMotion(v8, previous_clip, motion_history, object_motion, object_depth);
#endif
  return;
}
