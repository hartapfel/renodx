ByteAddressBuffer Raw20 : register(t20);
// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 09:31:09 2026
Texture2D<float4> t23 : register(t23);

Texture2D<float4> t22 : register(t22);

Texture2D<float4> t17 : register(t17);

TextureCubeArray<float4> t10 : register(t10);

Texture2DArray<float4> t9 : register(t9);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

TextureCube<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s11_s : register(s11);

SamplerState s10_s : register(s10);

SamplerState s0_s : register(s0);

cbuffer cb13 : register(b13)
{
  float4 cb13[2362];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[24];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[219];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[25];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[17];
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
  float3 v3 : TEXCOORD3,
  float4 v4 : SV_Position0,
  float4 previous_clip : TEXCOORD10,
  nointerpolation float motion_history : TEXCOORD11,
  out float4 o0 : SV_Target0,
  out float4 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24,r25;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = cmp(0 < v0.x);
  r0.yz = float2(-1,1) + v0.xx;
  r0.x = r0.x ? r0.y : r0.z;
  r0.z = cmp(r0.x >= 0);
  r0.z = r0.z ? 0 : 1;
  r0.w = dot(v3.xyz, v3.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = v3.xyz * r0.www;
  r0.y = v0.y;
  r2.xy = cb4[2].xx * r0.xy;
  r2.xy = t0.Sample(s0_s, r2.xy).xy;
  r2.xy = float2(-0.5,-0.5) + r2.xy;
  r2.xy = r2.xy + r2.xy;
  r3.xy = float2(-0.5,-0.5) + r0.xy;
  r0.w = cb4[4].x + -cb4[3].x;
  r1.w = cb4[4].x + cb4[3].x;
  r2.z = dot(r3.xy, r3.xy);
  r2.z = sqrt(r2.z);
  r2.w = r2.z + -r0.w;
  r0.w = r1.w + -r0.w;
  r0.w = r2.w / r0.w;
  r0.w = saturate(1 + -r0.w);
  r1.w = 1 + -r0.w;
  r3.z = cb4[8].x * cb4[7].x;
  r2.w = dot(r3.xyz, r3.xyz);
  r2.w = rsqrt(r2.w);
  r4.xyz = r3.xyz * r2.www;
  r2.w = cb4[8].x * r4.z;
  r2.w = cmp(r3.z < r2.w);
  r3.xyw = cb4[8].xxx * r4.xyz + -r3.xyz;
  r4.x = dot(r3.xyw, r3.xyw);
  r4.x = rsqrt(r4.x);
  r3.xyw = r4.xxx * r3.xyw;
  r3.xyw = r2.www ? r3.xyw : float3(0,0,1);
  r2.w = r3.z * r3.z;
  r2.w = cb4[8].x * cb4[8].x + -r2.w;
  r2.w = sqrt(r2.w);
  r2.z = cb4[6].x * r2.z;
  r2.z = r2.z / r2.w;
  r2.z = saturate(1 + -r2.z);
  r2.z = log2(r2.z);
  r2.z = cb4[5].x * r2.z;
  r2.z = exp2(r2.z);
  r3.xy = r2.zz * r3.xy;
  r2.z = dot(r3.xyw, r3.xyw);
  r2.z = rsqrt(r2.z);
  r4.xy = r2.xy * r1.ww;
  r4.z = 0;
  r2.xyz = r3.xyw * r2.zzz + r4.xyz;
  r1.w = dot(r2.xyz, r2.xyz);
  r1.w = rsqrt(r1.w);
  r2.xyz = r2.xyz * r1.www;
  r3.xy = v0.zw;
  r3.z = v1.w;
  r1.w = dot(r3.xyz, r3.xyz);
  r1.w = rsqrt(r1.w);
  r3.xyw = r3.xyz * r1.www;
  r2.w = dot(v1.xyz, v1.xyz);
  r2.w = rsqrt(r2.w);
  r4.xyz = v1.xyz * r2.www;
  r5.xyz = r4.xyz * r2.yyy;
  r2.xyw = r2.xxx * r1.xyz + r5.xyz;
  r2.xyz = r2.zzz * r3.xyw + r2.xyw;
  r2.w = dot(r2.xyz, r2.xyz);
  r2.w = rsqrt(r2.w);
  r2.xyz = r2.xyz * r2.www;
  r5.xyz = cb1[8].xyz + -v2.xyz;
  r2.w = dot(r5.xyz, r5.xyz);
  r4.w = rsqrt(r2.w);
  r5.xyz = r5.xyz * r4.www;
  r2.w = sqrt(r2.w);
  r6.xyz = -r3.xyy * cb4[9].xxx + v2.xyy;
  r7.xyz = r5.xyz * r2.www + v2.xyz;
  r6.xyz = r7.xyy + -r6.xyz;
  r2.w = dot(r6.xz, r6.xz);
  r8.w = rsqrt(r2.w);
  r8.xyz = r8.www * r6.xyz;
  r6.yzw = float3(0,0,1) * r8.xxz;
  r6.x = 0;
  r6.xyzw = -r8.xyzw * float4(1,0,0,0) + r6.xyzw;
  r8.xy = float2(0,1) * r6.zw;
  r6.yz = r6.xy * float2(1,0) + -r8.xy;
  r7.xyz = v2.xyz + -r7.xyz;
  r2.w = dot(r7.xyz, r7.xyz);
  r2.w = rsqrt(r2.w);
  r7.xyz = r7.xyz * r2.www;
  r2.w = dot(r7.xyz, r2.xyz);
  r2.w = r2.w + r2.w;
  r7.xyz = r2.xyz * -r2.www + r7.xyz;
  r8.x = dot(r6.wx, r7.xy);
  r8.y = dot(-r6.yz, r7.xy);
  r8.z = r7.z;
  r6.xyz = t1.Sample(s0_s, r8.xyz).xyz;
  r2.w = cb4[1].x + -cb4[0].x;
  r2.w = r0.z * r2.w + cb4[0].x;
  r6.xyz = log2(r6.xyz);
  r6.xyz = float3(2.20000005,2.20000005,2.20000005) * r6.xyz;
  r6.xyz = exp2(r6.xyz);
  r6.xyz = r6.xyz * r2.www;
  r2.w = cmp(0 >= v0.x);
  r4.w = r2.w ? -cb4[15].x : -cb4[14].x;
  r4.w = 0.0174532942 * r4.w;
  sincos(r4.w, r7.x, r8.x);
  r9.xyz = r2.www ? cb3[11].xyz : cb3[8].xyz;
  r10.xyz = r2.www ? cb3[12].xzy : cb3[9].xzy;
  r7.y = r8.x;
  r9.w = r10.x;
  r8.x = dot(r7.xy, r9.xw);
  r10.xw = r9.zy;
  r8.y = dot(r7.yx, r10.zw);
  r8.z = dot(r7.xy, r10.xy);
  r2.w = dot(r1.xyz, r8.xyz);
  r7.xyz = -r8.xyz * r2.www + r1.xyz;
  r2.w = dot(r7.xyz, r7.xyz);
  r2.w = rsqrt(r2.w);
  r7.xyz = r7.xyz * r2.www;
  r9.xyz = r7.zxy * r8.yzx;
  r9.xyz = r7.yzx * r8.zxy + -r9.xyz;
  r10.xyz = -r3.xyw * cb4[9].xxx + v2.xyz;
  r10.xyz = v2.xyz + -r10.xyz;
  r11.x = dot(r7.xyz, r10.xyz);
  r2.w = dot(r8.xyz, r10.xyz);
  r11.y = dot(r9.xyz, r10.xyz);
  r10.x = dot(r7.xyz, -r5.xyz);
  r10.y = dot(r8.xyz, -r5.xyz);
  r10.z = dot(r9.xyz, -r5.xyz);
  r5.x = dot(r7.xyz, r3.xyw);
  r5.y = dot(r8.xyz, r3.xyw);
  r5.z = dot(r9.xyz, r3.xyw);
  r4.w = dot(r10.xyz, r5.xyz);
  r5.w = cb4[11].x * cb4[11].x;
  r6.w = -r4.w * r4.w + 1;
  r5.w = -r5.w * r6.w + 1;
  r6.w = sqrt(r5.w);
  r4.w = cb4[11].x * r4.w + r6.w;
  r5.w = cmp(r5.w >= 0);
  r5.xyz = r4.www * r5.xyz;
  r5.xyz = cb4[11].xxx * r10.xyz + -r5.xyz;
  r5.xyz = r5.www ? r5.xyz : 0;
  r2.w = -cb4[16].x + r2.w;
  r2.w = max(0, r2.w);
  r5.xz = r5.xz * r2.ww;
  r2.w = max(9.99999975e-005, abs(r5.y));
  r5.xy = r5.xz / r2.ww;
  r5.xy = cb4[12].xx * r5.xy + r11.xy;
  r5.xy = cb4[17].xx * r5.xy;
  r2.w = cb4[9].x + cb4[9].x;
  r5.xy = r5.xy / r2.ww;
  r5.xy = float2(0.5,0.5) + r5.xy;
  r5.xy = r5.xy + -r0.xy;
  r0.xy = r0.ww * r5.xy + r0.xy;
  r5.xyz = t2.Sample(s0_s, r0.xy).xyz;
  r0.xyw = t3.Sample(s0_s, r0.xy).xyz;
  r0.xyw = float3(-0.5,-0.5,-0.5) + r0.xyw;
  r0.xyw = r0.xyw + r0.xyw;
  r4.xyz = r0.yyy * r4.xyz;
  r1.xyz = r0.xxx * r1.xyz + r4.xyz;
  r0.xyw = r0.www * r3.xyw + r1.xyz;
  r1.x = dot(r0.xyw, r0.xyw);
  r1.x = rsqrt(r1.x);
  r0.xyw = r1.xxx * r0.xyw;
  r1.x = cb4[19].x + -cb4[18].x;
  r0.z = saturate(r0.z * r1.x + cb4[18].x);
  r1.xyz = max(float3(0,0,0), r6.xyz);
  r5.xyz = saturate(r5.xyz);
  r4.xyz = log2(r5.xyz);
  r4.xyz = float3(2.20000005,2.20000005,2.20000005) * r4.xyz;
  r4.xyz = exp2(r4.xyz);
  r0.z = log2(r0.z);
  r0.z = 2.20000005 * r0.z;
  r0.z = exp2(r0.z);
  r2.w = saturate(cb4[20].x);
  r5.xy = (uint2)v4.xy;
  r6.xy = (uint2)r5.xy >> int2(4,4);
  r4.w = (int)cb12[24].x;
  r4.w = mad((int)r6.y, (int)r4.w, (int)r6.x);
  r4.w = (uint)r4.w << 8;
  r6.xyz = cb12[0].xyz + -v2.xyz;
  r6.w = dot(r6.xyz, r6.xyz);
  r6.w = rsqrt(r6.w);
  r7.xyz = r6.xyz * r6.www;
  r5.zw = float2(0,0);
  r8.xyz = t17.Load(r5.xyz).yzw;
  r5.z = cmp(0 < r8.x);
  if (r5.z != 0) {
    r5.z = dot(r0.xyw, cb13[0].xyz);
    r5.z = cb4[21].x + r5.z;
    r5.w = cb4[21].x + 1;
    r5.z = r5.z / r5.w;
    r5.w = 1 / r5.w;
    r9.xyz = saturate(r5.zzz);
    r10.xyz = r6.xyz * r6.www + cb13[0].xyz;
    r5.z = dot(r10.xyz, r10.xyz);
    r5.z = rsqrt(r5.z);
    r10.xyz = r10.xyz * r5.zzz;
    r5.z = dot(r10.xyz, r7.xyz);
    r5.z = 1 + -abs(r5.z);
    r5.z = max(0, r5.z);
    r7.w = r5.z * r5.z;
    r7.w = r7.w * r7.w;
    r5.z = r7.w * r5.z;
    r7.w = 1 + -r2.w;
    r8.w = 1 + -r0.z;
    r8.w = cb13[56].x * r8.w;
    r5.z = r8.w * r5.z;
    r8.w = 1 + cb13[56].z;
    r7.w = -cb13[56].z * r7.w + r8.w;
    r5.z = r5.z / r7.w;
    r5.z = r5.z + r0.z;
    r7.w = 1 + -r5.z;
    r7.w = r9.z * r7.w;
    r5.w = r7.w * r5.w;
    r5.w = r5.w * r8.x;
    r11.xy = -cb12[0].xy + v2.xy;
    r7.w = dot(r11.xy, r11.xy);
    r7.w = sqrt(r7.w);
    r8.w = saturate(v2.z * cb12[218].z + cb12[218].w);
    r11.xyz = -cb13[52].xyz + cb13[51].xyz;
    r11.xyz = r8.www * r11.xyz + cb13[52].xyz;
    r7.w = saturate(r7.w * cb12[218].x + cb12[218].y);
    r11.xyz = -cb13[1].xyz + r11.xyz;
    r11.xyz = r7.www * r11.xyz + cb13[1].xyz;
    r5.w = 0.318309873 * r5.w;
    r12.xyz = r5.www * r11.xyz;
    r5.w = dot(cb13[0].xyz, r2.xyz);
    r7.w = cmp(0 < r5.w);
    if (r7.w != 0) {
      r7.w = saturate(dot(r2.xyz, r10.xyz));
      r8.w = dot(r2.xyz, r7.xyz);
      r5.w = saturate(r5.w);
      r9.w = r2.w * r2.w;
      r10.x = r9.w * r9.w;
      r7.w = r7.w * r7.w;
      r9.w = r9.w * r9.w + -1;
      r7.w = r7.w * r9.w + 1;
      r7.w = r7.w * r7.w;
      r7.w = 3.14152002 * r7.w;
      r7.w = r10.x / r7.w;
      r9.w = 1 + r2.w;
      r9.w = r9.w * r9.w;
      r10.x = 0.125 * r9.w;
      r9.w = -r9.w * 0.125 + 1;
      r10.y = r5.w * r9.w + r10.x;
      r10.y = r5.w / r10.y;
      r9.w = abs(r8.w) * r9.w + r10.x;
      r9.w = abs(r8.w) / r9.w;
      r9.w = r10.y * r9.w;
      r7.w = r9.w * r7.w;
      r5.z = r7.w * r5.z;
      r7.w = r5.w * abs(r8.w);
      r7.w = 4 * r7.w;
      r5.z = r5.z / r7.w;
      r10.xyz = r5.zzz * r5.www;
    } else {
      r10.xyz = float3(0,0,0);
    }
    r10.xyz = r10.xyz * r8.xxx;
    r10.xyz = r10.xyz * r11.xyz;
  } else {
    r9.xyz = float3(0,0,0);
    r12.xyz = float3(0,0,0);
    r10.xyz = float3(0,0,0);
  }
  r9.xyz = min(r9.xyz, r8.xxx);
  r5.z = cmp(r8.y == 1.000000);
  r5.w = cmp(cb3[24].y != 0.000000);
  r11.x = cb3[21].z * cb4[23].x + cb3[21].y;
  r11.y = cb3[22].z * cb4[23].x + cb3[22].y;
  r11.z = cb3[23].z * cb4[23].x + cb3[23].y;
  r13.xyz = v2.xyz + -r11.xyz;
  r7.w = dot(r13.xyz, r13.xyz);
  r7.w = rsqrt(r7.w);
  r13.xyz = r13.xyz * r7.www;
  r7.w = cb4[22].x + -0.200000003;
  r8.x = cmp(cb2[16].x < 0);
  r8.x = r8.x ? 1 : cb12[71].x;
  r8.w = cb4[21].x + 1;
  r9.w = 1 / r8.w;
  r10.w = 1 + -r2.w;
  r11.w = 1 + -r0.z;
  r12.w = cb13[56].x * r11.w;
  r14.xy = float2(1,1) + cb13[56].zw;
  r14.xy = -cb13[56].zw * r10.ww + r14.xy;
  r10.w = dot(r2.xyz, r7.xyz);
  r13.w = r2.w * r2.w;
  r14.z = r13.w * r13.w;
  r14.w = r13.w * r13.w + -1;
  r2.w = 1 + r2.w;
  r2.w = r2.w * r2.w;
  r15.x = 0.125 * r2.w;
  r2.w = -r2.w * 0.125 + 1;
  r15.y = abs(r10.w) * r2.w + r15.x;
  r15.y = abs(r10.w) / r15.y;
  r10.w = 4 * abs(r10.w);
  r15.z = r5.z ? 1.000000 : 0;
  r5.z = r5.z ? 0 : 1;
  r16.xyz = r12.xyz;
  r17.xyz = r10.xyz;
  r15.w = 0;
  while (true) {
    r16.w = cmp((int)r15.w >= 256);
    if (r16.w != 0) break;
    r16.w = (int)r4.w + (int)r15.w;
    r16.w = (uint)r16.w << 2;
    r16.w = Raw20.Load((uint)r16.w);
    r17.w = cmp((uint)r16.w >= 256);
    if (r17.w != 0) {
      break;
    }
    r16.w = (int)r16.w * 9;
    r18.xyz = cb13[r16.w+58].xyz + -v2.xyz;
    r17.w = dot(r18.xyz, r18.xyz);
    r19.x = sqrt(r17.w);
    r19.y = r19.x / cb13[r16.w+58].w;
    r19.z = r19.y * r19.y;
    r19.z = -r19.z * r19.z + 1;
    r19.z = max(0, r19.z);
    r19.z = r19.z * r19.z;
    r20.xyz = int3(1,2048,4096) & asint(cb13[r16.w+61].www);
    r19.w = cmp(0 < cb13[r16.w+63].z);
    r20.w = cmp(0 < cb13[r16.w+64].x);
    r21.x = r17.w * cb13[r16.w+63].x + 1;
    r19.z = r19.z / r21.x;
    if (r20.x != 0) {
      r21.x = rsqrt(r17.w);
      r21.xyz = r21.xxx * r18.xyz;
      r21.x = dot(-r21.xyz, cb13[r16.w+60].xyz);
      r21.x = saturate(r21.x * cb13[r16.w+62].y + cb13[r16.w+62].z);
      r21.x = log2(r21.x);
      r21.x = cb13[r16.w+62].w * r21.x;
      r21.x = exp2(r21.x);
      r19.z = r21.x * r19.z;
    }
    r21.x = cmp(0 < r19.z);
    r19.w = r19.w ? r21.x : 0;
    if (r19.w != 0) {
      if (r20.x != 0) {
        r21.yzw = -cb13[r16.w+58].xyz + v2.xyz;
        r22.xyz = cb13[r16.w+65].zwy * cb13[r16.w+60].zxy;
        r22.xyz = cb13[r16.w+60].yzx * cb13[r16.w+65].wyz + -r22.xyz;
        r22.x = dot(r22.xyz, r21.yzw);
        r22.y = dot(cb13[r16.w+65].yzw, r21.yzw);
        r22.z = dot(cb13[r16.w+60].xyz, r21.yzw);
        r22.w = cb13[r16.w+65].x;
      } else {
        r23.xyz = -cb13[r16.w+58].xzy + v2.xzy;
        r21.yzw = r18.xyz / r19.xxx;
        r19.x = max(abs(r21.z), abs(r21.w));
        r19.x = cmp(r19.x < abs(r21.y));
        if (r19.x != 0) {
          r19.x = cmp(0 < r21.y);
          r24.xyz = float3(1,1,-1) * r23.zyx;
          r24.w = cb13[r16.w+65].x;
          r25.xyz = float3(-1,1,1) * r23.zyx;
          r25.w = cb13[r16.w+65].y;
          r22.xyzw = r19.xxxx ? r24.xyzw : r25.xyzw;
        } else {
          r19.x = max(abs(r21.y), abs(r21.w));
          r19.x = cmp(r19.x < abs(r21.z));
          if (r19.x != 0) {
            r19.x = cmp(0 < r21.z);
            r24.xyz = float3(-1,1,-1) * r23.xyz;
            r24.w = cb13[r16.w+65].z;
            r23.w = cb13[r16.w+65].w;
            r22.xyzw = r19.xxxx ? r24.xyzw : r23.xyzw;
          } else {
            r19.x = cmp(0 < r21.w);
            r22.x = r23.x;
            r22.y = r19.x ? r23.z : -r23.z;
            r22.z = r19.x ? -r23.y : r23.y;
            r22.w = r19.x ? cb13[r16.w+66].x : cb13[r16.w+66].y;
          }
        }
      }
      r19.xw = cb13[r16.w+63].yy * r22.xy;
      r19.xw = r19.xw / r22.zz;
      r19.xw = r19.xw * float2(0.5,-0.5) + float2(0.5,0.5);
      if (10 == 0) r21.y = 0; else if (10+20 < 32) {       r21.y = (uint)r22.w << (32-(10 + 20)); r21.y = (uint)r21.y >> (32-10);      } else r21.y = (uint)r22.w >> 20;
      if (10 == 0) r21.z = 0; else if (10+10 < 32) {       r21.z = (uint)r22.w << (32-(10 + 10)); r21.z = (uint)r21.z >> (32-10);      } else r21.z = (uint)r22.w >> 10;
      r21.yz = (uint2)r21.yz;
      r20.x = (int)r22.w & 1023;
      r20.x = (uint)r20.x;
      r21.w = (uint)r22.w >> 30;
      r22.z = (uint)r21.w;
      r21.w = cmp(0 < r20.x);
      if (r21.w != 0) {
        r19.xw = r19.xw * r20.xx + r21.yz;
        r22.xy = float2(0.0009765625,0.0009765625) * r19.xw;
        r19.x = t9.SampleLevel(s10_s, r22.xyz, 0).x;
        r19.x = -r19.y * 0.99000001 + r19.x;
        r19.x = 144.269501 * r19.x;
        r19.x = exp2(r19.x);
        r19.x = min(1, r19.x);
      } else {
        r19.x = 1;
      }
    } else {
      r19.x = 1;
    }
    r19.w = r20.w ? r21.x : 0;
    if (r19.w != 0) {
      r18.w = cb13[r16.w+64].y;
      r18.w = t10.SampleLevel(s10_s, r18.xyzw, 0).x;
      r18.w = -r19.y * 0.99000001 + r18.w;
      r18.w = 144.269501 * r18.w;
      r18.w = exp2(r18.w);
      r18.w = min(1, r18.w);
      r19.x = r19.x * r18.w;
    }
    r18.w = -1 + r19.x;
    r18.w = cb13[r16.w+60].w * r18.w + 1;
    r18.w = r19.z * r18.w;
    r19.x = r20.y ? 1 : r15.z;
    r19.y = r20.z ? 1 : r5.z;
    r19.x = r19.x * r19.y;
    r18.w = r19.x * r18.w;
    if (r5.w != 0) {
      r19.xyz = cb13[r16.w+58].xyz + -r11.xyz;
      r19.w = dot(r19.xyz, r19.xyz);
      r19.w = rsqrt(r19.w);
      r19.xyz = r19.xyz * r19.www;
      r19.x = dot(r13.xyz, r19.xyz);
      r19.x = r19.x * 0.5 + -r7.w;
      r19.x = 0.5 + r19.x;
      r19.x = saturate(5 * r19.x);
    } else {
      r19.x = 1;
    }
    r18.w = r19.x * r18.w;
    r19.x = cmp(0 < r18.w);
    if (r19.x != 0) {
      r19.x = 0x80000000 & asint(cb13[r16.w+61].w);
      r19.x = r19.x ? r8.x : 1;
      r18.w = r19.x * r18.w;
      r17.w = rsqrt(r17.w);
      r18.xyz = r18.xyz * r17.www;
      r17.w = dot(r0.xyw, r18.xyz);
      r17.w = cb4[21].x + r17.w;
      r17.w = saturate(r17.w / r8.w);
      r19.xyz = r6.xyz * r6.www + r18.xyz;
      r19.w = dot(r19.xyz, r19.xyz);
      r19.w = rsqrt(r19.w);
      r19.xyz = r19.xyz * r19.www;
      r19.w = dot(r19.xyz, r7.xyz);
      r19.w = 1 + -abs(r19.w);
      r19.w = max(0, r19.w);
      r20.x = r19.w * r19.w;
      r20.x = r20.x * r20.x;
      r19.w = r20.x * r19.w;
      r19.w = r19.w * r12.w;
      r19.w = r19.w / r14.x;
      r19.w = r19.w + r0.z;
      r20.x = 1 + -r19.w;
      r17.w = r20.x * r17.w;
      r17.w = r17.w * r9.w;
      r17.w = 0.318309873 * r17.w;
      r20.xyz = cb13[r16.w+61].xyz * r17.www;
      r16.xyz = r18.www * r20.xyz + r16.xyz;
      r17.w = dot(r18.xyz, r2.xyz);
      r18.x = cmp(0 < r17.w);
      if (r18.x != 0) {
        r18.x = saturate(dot(r2.xyz, r19.xyz));
        r17.w = saturate(r17.w);
        r18.x = r18.x * r18.x;
        r18.x = r18.x * r14.w + 1;
        r18.x = r18.x * r18.x;
        r18.x = 3.14152002 * r18.x;
        r18.x = r14.z / r18.x;
        r18.y = r17.w * r2.w + r15.x;
        r18.y = r17.w / r18.y;
        r18.y = r18.y * r15.y;
        r18.x = r18.x * r18.y;
        r18.x = r18.x * r19.w;
        r18.y = r17.w * r10.w;
        r18.x = r18.x / r18.y;
        r18.xyz = r18.xxx * r17.www;
      } else {
        r18.xyz = float3(0,0,0);
      }
      r18.xyz = cb13[r16.w+61].xyz * r18.xyz;
      r17.xyz = r18.www * r18.xyz + r17.xyz;
    }
    r15.w = (int)r15.w + 1;
  }
  r0.x = dot(-r7.xyz, r2.xyz);
  r0.x = r0.x + r0.x;
  r0.xyw = r2.xyz * -r0.xxx + -r7.xyz;
  r2.x = dot(r0.xyw, r0.xyw);
  r2.x = rsqrt(r2.x);
  r2.yzw = r2.xxx * r0.xyw;
  r6.xyz = ddx_coarse(r2.yzw);
  r10.xyz = ddy_coarse(r2.yzw);
  r5.xy = (int2)r5.xy & int2(1,1);
  r5.xzw = r5.xxx ? -r6.xyz : r6.xyz;
  r6.xyz = r5.yyy ? -r10.xyz : r10.xyz;
  r5.xyz = r0.xyw * r2.xxx + r5.xzw;
  r4.w = dot(r5.xyz, r5.xyz);
  r4.w = rsqrt(r4.w);
  r5.xyz = r5.xyz * r4.www;
  r4.w = dot(r2.yzw, r5.xyz);
  r5.x = 1 + -abs(r4.w);
  r5.x = sqrt(r5.x);
  r5.y = abs(r4.w) * -0.0187292993 + 0.0742610022;
  r5.y = r5.y * abs(r4.w) + -0.212114394;
  r5.y = r5.y * abs(r4.w) + 1.57072878;
  r5.z = r5.y * r5.x;
  r5.z = r5.z * -2 + 3.14159274;
  r4.w = cmp(r4.w < -r4.w);
  r4.w = r4.w ? r5.z : 0;
  r4.w = r5.y * r5.x + r4.w;
  r4.w = 81.4873276 * r4.w;
  r4.w = log2(r4.w);
  r4.w = max(0, r4.w);
  r5.xyz = r0.xyw * r2.xxx + r6.xyz;
  r2.x = dot(r5.xyz, r5.xyz);
  r2.x = rsqrt(r2.x);
  r5.xyz = r5.xyz * r2.xxx;
  r2.x = dot(r2.yzw, r5.xyz);
  r2.y = 1 + -abs(r2.x);
  r2.y = sqrt(r2.y);
  r2.z = abs(r2.x) * -0.0187292993 + 0.0742610022;
  r2.z = r2.z * abs(r2.x) + -0.212114394;
  r2.z = r2.z * abs(r2.x) + 1.57072878;
  r2.w = r2.z * r2.y;
  r2.w = r2.w * -2 + 3.14159274;
  r2.x = cmp(r2.x < -r2.x);
  r2.x = r2.x ? r2.w : 0;
  r2.x = r2.z * r2.y + r2.x;
  r2.x = 81.4873276 * r2.x;
  r2.x = log2(r2.x);
  r2.x = max(0, r2.x);
  r2.x = max(r4.w, r2.x);
  r2.x = 0.625 * r2.x;
  r2.y = 10.5 * r13.w;
  r2.x = max(r2.y, r2.x);
  r2.y = cmp(r3.w < 0);
  // Native integer bit 1 selects the other environment-probe hemisphere.
  // The decompiler rounded its float bit pattern to zero before the int-to-float conversion.
  r2.z = r2.y ? 1.f : 0.f;
  r5.xyzw = float4(0.5,-0.5,-0.5,0.5) * r3.xyxy;
  r2.w = -r3.z * r1.w + 1;
  r2.w = max(0.00100000005, r2.w);
  r5.xy = r5.xy / r2.ww;
  r1.w = r3.z * r1.w + 1;
  r1.w = max(0.00100000005, r1.w);
  r5.zw = r5.zw / r1.ww;
  r5.xyzw = float4(0.5,0.5,0.5,0.5) + r5.xyzw;
  r2.yw = r2.yy ? r5.xy : r5.zw;
  r2.yw = r2.yw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
  r5.x = (int)r2.z;
  r5.y = 0;
  r2.yz = r5.xy + r2.yw;
  r5.xy = float2(0.5,0.142857149) * r2.yz;
  r2.yzw = cb12[114].xyz * v2.yyy;
  r2.yzw = cb12[113].xyz * v2.xxx + r2.yzw;
  r2.yzw = cb12[115].xyz * v2.zzz + r2.yzw;
  r2.yzw = cb12[116].xyz + r2.yzw;
  r2.yzw = float3(1,1,1) + -abs(r2.yzw);
  r1.w = cmp(r8.y != -1.000000);
  if (r1.w != 0) {
    r6.xy = asint(cb12[117].yy) & int2(1,2);
    r3.z = r6.x ? 1 : r8.y;
    r4.w = 1 + -r8.y;
    r4.w = r6.y ? 1 : r4.w;
    r3.z = r4.w * r3.z;
  } else {
    r3.z = 1;
  }
  r6.xyz = cmp(float3(0,0,0) < r2.yzw);
  r4.w = r6.y ? r6.x : 0;
  r4.w = r6.z ? r4.w : 0;
  r6.x = cmp(0 < r3.z);
  r4.w = r6.x ? r4.w : 0;
  if (r4.w != 0) {
    r2.yzw = saturate(cb12[112].xyz * r2.yzw);
    r3.z = cb12[111].x * r3.z;
    r3.z = 0.999989986 * r3.z;
    r2.y = r2.y * r2.z;
    r2.y = r2.y * r2.w;
    r2.z = r3.z * r2.y;
    r2.y = r3.z * r2.y + 9.99999975e-006;
    r2.z = cb12[117].x * r2.z;
    r2.w = asint(cb12[122].x);
    r5.z = r2.w * 0.142857149 + r5.y;
    r6.xyz = t22.SampleLevel(s11_s, r5.xz, 1).xyz;
    r6.xyz = r6.xyz * r2.zzz;
    r10.xyz = cb12[119].xyz * r0.yyy;
    r10.xyz = cb12[118].xyz * r0.xxx + r10.xyz;
    r10.xyz = cb12[120].xyz * r0.www + r10.xyz;
    r11.xyz = cb12[119].xyz * v2.yyy;
    r11.xyz = cb12[118].xyz * v2.xxx + r11.xyz;
    r11.xyz = cb12[120].xyz * v2.zzz + r11.xyz;
    r11.xyz = cb12[121].xyz + r11.xyz;
    r10.xyz = float3(1,1,1) / r10.xyz;
    r12.xyz = -r11.xyz * r10.xyz + r10.xyz;
    r10.xyz = -r11.xyz * r10.xyz + -r10.xyz;
    r10.xyz = max(r12.xyz, r10.xyz);
    r2.w = min(r10.y, r10.z);
    r2.w = min(r10.x, r2.w);
    r10.xyz = r0.xyw * r2.www + v2.xyz;
    r10.xyz = -cb12[111].yzw + r10.xyz;
    r2.w = dot(r10.xyz, r10.xyz);
    r2.w = rsqrt(r2.w);
    r10.xyw = r10.xyz * r2.www;
    r3.z = cmp(r10.w < 0);
    r4.w = r3.z ? 1.f : 0.f;
    r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r10.xyxy;
    r5.z = -r10.z * r2.w + 1;
    r5.z = max(0.00100000005, r5.z);
    r8.xw = r12.xy / r5.zz;
    r8.xw = float2(0.5,0.5) + r8.xw;
    r2.w = r10.z * r2.w + 1;
    r2.w = max(0.00100000005, r2.w);
    r10.xy = r12.zw / r2.ww;
    r10.xy = float2(0.5,0.5) + r10.xy;
    r8.xw = r3.zz ? r8.xw : r10.xy;
    r8.xw = r8.xw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
    r10.y = asint(cb12[122].x);
    r10.z = (int)r4.w;
    r10.xw = float2(0,0);
    r8.xw = r10.zw + r8.xw;
    r8.xw = r10.xy + r8.xw;
    r8.xw = float2(0.5,0.142857149) * r8.xw;
    r10.xyz = t23.SampleLevel(s11_s, r8.xw, r2.x).xyz;
    r10.xyz = r10.xyz * r2.zzz;
  } else {
    r6.xyz = float3(0,0,0);
    r10.xyz = float3(0,0,0);
    r2.y = 9.99999975e-006;
  }
  r2.z = cmp(r2.y < 0.999000013);
  if (r2.z != 0) {
    r11.xyz = cb12[126].xyz * v2.yyy;
    r11.xyz = cb12[125].xyz * v2.xxx + r11.xyz;
    r11.xyz = cb12[127].xyz * v2.zzz + r11.xyz;
    r11.xyz = cb12[128].xyz + r11.xyz;
    r11.xyz = float3(1,1,1) + -abs(r11.xyz);
    if (r1.w != 0) {
      r8.xw = asint(cb12[129].yy) & int2(1,2);
      r2.w = r8.x ? 1 : r8.y;
      r3.z = 1 + -r8.y;
      r3.z = r8.w ? 1 : r3.z;
      r2.w = r3.z * r2.w;
    } else {
      r2.w = 1;
    }
    r12.xyz = cmp(float3(0,0,0) < r11.xyz);
    r3.z = r12.y ? r12.x : 0;
    r3.z = r12.z ? r3.z : 0;
    r4.w = cmp(0 < r2.w);
    r3.z = r4.w ? r3.z : 0;
    if (r3.z != 0) {
      r11.xyz = saturate(cb12[124].xyz * r11.xyz);
      r3.z = 1 + -r2.y;
      r2.w = r3.z * r2.w;
      r2.w = cb12[123].x * r2.w;
      r3.z = r11.x * r11.y;
      r3.z = r3.z * r11.z;
      r4.w = r3.z * r2.w;
      r2.y = r2.w * r3.z + r2.y;
      r2.w = cb12[129].x * r4.w;
      r3.z = asint(cb12[134].x);
      r5.w = r3.z * 0.142857149 + r5.y;
      r11.xyz = t22.SampleLevel(s11_s, r5.xw, 1).xyz;
      r6.xyz = r2.www * r11.xyz + r6.xyz;
      r11.xyz = cb12[131].xyz * r0.yyy;
      r11.xyz = cb12[130].xyz * r0.xxx + r11.xyz;
      r11.xyz = cb12[132].xyz * r0.www + r11.xyz;
      r12.xyz = cb12[131].xyz * v2.yyy;
      r12.xyz = cb12[130].xyz * v2.xxx + r12.xyz;
      r12.xyz = cb12[132].xyz * v2.zzz + r12.xyz;
      r12.xyz = cb12[133].xyz + r12.xyz;
      r11.xyz = float3(1,1,1) / r11.xyz;
      r13.xyz = -r12.xyz * r11.xyz + r11.xyz;
      r11.xyz = -r12.xyz * r11.xyz + -r11.xyz;
      r11.xyz = max(r13.xyz, r11.xyz);
      r3.z = min(r11.y, r11.z);
      r3.z = min(r11.x, r3.z);
      r11.xyz = r0.xyw * r3.zzz + v2.xyz;
      r11.xyz = -cb12[123].yzw + r11.xyz;
      r3.z = dot(r11.xyz, r11.xyz);
      r3.z = rsqrt(r3.z);
      r12.xyz = r11.xyz * r3.zzz;
      r4.w = cmp(r12.z < 0);
      r5.z = r4.w ? 1.f : 0.f;
      r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r12.xyxy;
      r5.w = -r11.z * r3.z + 1;
      r5.w = max(0.00100000005, r5.w);
      r8.xw = r12.xy / r5.ww;
      r8.xw = float2(0.5,0.5) + r8.xw;
      r3.z = r11.z * r3.z + 1;
      r3.z = max(0.00100000005, r3.z);
      r11.xy = r12.zw / r3.zz;
      r11.xy = float2(0.5,0.5) + r11.xy;
      r8.xw = r4.ww ? r8.xw : r11.xy;
      r8.xw = r8.xw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r12.y = asint(cb12[134].x);
      r12.z = (int)r5.z;
      r12.xw = float2(0,0);
      r5.zw = r12.zw + r8.xw;
      r5.zw = r12.xy + r5.zw;
      r5.zw = float2(0.5,0.142857149) * r5.zw;
      r11.xyz = t23.SampleLevel(s11_s, r5.zw, r2.x).xyz;
      r10.xyz = r2.www * r11.xyz + r10.xyz;
    }
  }
  r2.w = cmp(r2.y < 0.999000013);
  r2.z = r2.w ? r2.z : 0;
  if (r2.z != 0) {
    r11.xyz = cb12[138].xyz * v2.yyy;
    r11.xyz = cb12[137].xyz * v2.xxx + r11.xyz;
    r11.xyz = cb12[139].xyz * v2.zzz + r11.xyz;
    r11.xyz = cb12[140].xyz + r11.xyz;
    r11.xyz = float3(1,1,1) + -abs(r11.xyz);
    if (r1.w != 0) {
      r5.zw = asint(cb12[141].yy) & int2(1,2);
      r2.w = r5.z ? 1 : r8.y;
      r3.z = 1 + -r8.y;
      r3.z = r5.w ? 1 : r3.z;
      r2.w = r3.z * r2.w;
    } else {
      r2.w = 1;
    }
    r12.xyz = cmp(float3(0,0,0) < r11.xyz);
    r3.z = r12.y ? r12.x : 0;
    r3.z = r12.z ? r3.z : 0;
    r4.w = cmp(0 < r2.w);
    r3.z = r4.w ? r3.z : 0;
    if (r3.z != 0) {
      r11.xyz = saturate(cb12[136].xyz * r11.xyz);
      r3.z = 1 + -r2.y;
      r2.w = r3.z * r2.w;
      r2.w = cb12[135].x * r2.w;
      r3.z = r11.x * r11.y;
      r3.z = r3.z * r11.z;
      r4.w = r3.z * r2.w;
      r2.y = r2.w * r3.z + r2.y;
      r2.w = cb12[141].x * r4.w;
      r3.z = asint(cb12[146].x);
      r11.y = r3.z * 0.142857149 + r5.y;
      r11.x = r5.x;
      r11.xyz = t22.SampleLevel(s11_s, r11.xy, 1).xyz;
      r6.xyz = r2.www * r11.xyz + r6.xyz;
      r11.xyz = cb12[143].xyz * r0.yyy;
      r11.xyz = cb12[142].xyz * r0.xxx + r11.xyz;
      r11.xyz = cb12[144].xyz * r0.www + r11.xyz;
      r12.xyz = cb12[143].xyz * v2.yyy;
      r12.xyz = cb12[142].xyz * v2.xxx + r12.xyz;
      r12.xyz = cb12[144].xyz * v2.zzz + r12.xyz;
      r12.xyz = cb12[145].xyz + r12.xyz;
      r11.xyz = float3(1,1,1) / r11.xyz;
      r13.xyz = -r12.xyz * r11.xyz + r11.xyz;
      r11.xyz = -r12.xyz * r11.xyz + -r11.xyz;
      r11.xyz = max(r13.xyz, r11.xyz);
      r3.z = min(r11.y, r11.z);
      r3.z = min(r11.x, r3.z);
      r11.xyz = r0.xyw * r3.zzz + v2.xyz;
      r11.xyz = -cb12[135].yzw + r11.xyz;
      r3.z = dot(r11.xyz, r11.xyz);
      r3.z = rsqrt(r3.z);
      r12.xyz = r11.xyz * r3.zzz;
      r4.w = cmp(r12.z < 0);
      r5.z = r4.w ? 1.f : 0.f;
      r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r12.xyxy;
      r5.w = -r11.z * r3.z + 1;
      r5.w = max(0.00100000005, r5.w);
      r8.xw = r12.xy / r5.ww;
      r8.xw = float2(0.5,0.5) + r8.xw;
      r3.z = r11.z * r3.z + 1;
      r3.z = max(0.00100000005, r3.z);
      r11.xy = r12.zw / r3.zz;
      r11.xy = float2(0.5,0.5) + r11.xy;
      r8.xw = r4.ww ? r8.xw : r11.xy;
      r8.xw = r8.xw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r12.y = asint(cb12[146].x);
      r12.z = (int)r5.z;
      r12.xw = float2(0,0);
      r5.zw = r12.zw + r8.xw;
      r5.zw = r12.xy + r5.zw;
      r5.zw = float2(0.5,0.142857149) * r5.zw;
      r11.xyz = t23.SampleLevel(s11_s, r5.zw, r2.x).xyz;
      r10.xyz = r2.www * r11.xyz + r10.xyz;
    }
  }
  r2.w = cmp(r2.y < 0.999000013);
  r2.z = r2.w ? r2.z : 0;
  if (r2.z != 0) {
    r11.xyz = cb12[150].xyz * v2.yyy;
    r11.xyz = cb12[149].xyz * v2.xxx + r11.xyz;
    r11.xyz = cb12[151].xyz * v2.zzz + r11.xyz;
    r11.xyz = cb12[152].xyz + r11.xyz;
    r11.xyz = float3(1,1,1) + -abs(r11.xyz);
    if (r1.w != 0) {
      r5.zw = asint(cb12[153].yy) & int2(1,2);
      r2.w = r5.z ? 1 : r8.y;
      r3.z = 1 + -r8.y;
      r3.z = r5.w ? 1 : r3.z;
      r2.w = r3.z * r2.w;
    } else {
      r2.w = 1;
    }
    r12.xyz = cmp(float3(0,0,0) < r11.xyz);
    r3.z = r12.y ? r12.x : 0;
    r3.z = r12.z ? r3.z : 0;
    r4.w = cmp(0 < r2.w);
    r3.z = r4.w ? r3.z : 0;
    if (r3.z != 0) {
      r11.xyz = saturate(cb12[148].xyz * r11.xyz);
      r3.z = 1 + -r2.y;
      r2.w = r3.z * r2.w;
      r2.w = cb12[147].x * r2.w;
      r3.z = r11.x * r11.y;
      r3.z = r3.z * r11.z;
      r4.w = r3.z * r2.w;
      r2.y = r2.w * r3.z + r2.y;
      r2.w = cb12[153].x * r4.w;
      r3.z = asint(cb12[158].x);
      r11.y = r3.z * 0.142857149 + r5.y;
      r11.x = r5.x;
      r11.xyz = t22.SampleLevel(s11_s, r11.xy, 1).xyz;
      r6.xyz = r2.www * r11.xyz + r6.xyz;
      r11.xyz = cb12[155].xyz * r0.yyy;
      r11.xyz = cb12[154].xyz * r0.xxx + r11.xyz;
      r11.xyz = cb12[156].xyz * r0.www + r11.xyz;
      r12.xyz = cb12[155].xyz * v2.yyy;
      r12.xyz = cb12[154].xyz * v2.xxx + r12.xyz;
      r12.xyz = cb12[156].xyz * v2.zzz + r12.xyz;
      r12.xyz = cb12[157].xyz + r12.xyz;
      r11.xyz = float3(1,1,1) / r11.xyz;
      r13.xyz = -r12.xyz * r11.xyz + r11.xyz;
      r11.xyz = -r12.xyz * r11.xyz + -r11.xyz;
      r11.xyz = max(r13.xyz, r11.xyz);
      r3.z = min(r11.y, r11.z);
      r3.z = min(r11.x, r3.z);
      r11.xyz = r0.xyw * r3.zzz + v2.xyz;
      r11.xyz = -cb12[147].yzw + r11.xyz;
      r3.z = dot(r11.xyz, r11.xyz);
      r3.z = rsqrt(r3.z);
      r12.xyz = r11.xyz * r3.zzz;
      r4.w = cmp(r12.z < 0);
      r5.z = r4.w ? 1.f : 0.f;
      r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r12.xyxy;
      r5.w = -r11.z * r3.z + 1;
      r5.w = max(0.00100000005, r5.w);
      r8.xw = r12.xy / r5.ww;
      r8.xw = float2(0.5,0.5) + r8.xw;
      r3.z = r11.z * r3.z + 1;
      r3.z = max(0.00100000005, r3.z);
      r11.xy = r12.zw / r3.zz;
      r11.xy = float2(0.5,0.5) + r11.xy;
      r8.xw = r4.ww ? r8.xw : r11.xy;
      r8.xw = r8.xw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r12.y = asint(cb12[158].x);
      r12.z = (int)r5.z;
      r12.xw = float2(0,0);
      r5.zw = r12.zw + r8.xw;
      r5.zw = r12.xy + r5.zw;
      r5.zw = float2(0.5,0.142857149) * r5.zw;
      r11.xyz = t23.SampleLevel(s11_s, r5.zw, r2.x).xyz;
      r10.xyz = r2.www * r11.xyz + r10.xyz;
    }
  }
  r2.w = cmp(r2.y < 0.999000013);
  r2.z = r2.w ? r2.z : 0;
  if (r2.z != 0) {
    r11.xyz = cb12[162].xyz * v2.yyy;
    r11.xyz = cb12[161].xyz * v2.xxx + r11.xyz;
    r11.xyz = cb12[163].xyz * v2.zzz + r11.xyz;
    r11.xyz = cb12[164].xyz + r11.xyz;
    r11.xyz = float3(1,1,1) + -abs(r11.xyz);
    if (r1.w != 0) {
      r5.zw = asint(cb12[165].yy) & int2(1,2);
      r2.w = r5.z ? 1 : r8.y;
      r3.z = 1 + -r8.y;
      r3.z = r5.w ? 1 : r3.z;
      r2.w = r3.z * r2.w;
    } else {
      r2.w = 1;
    }
    r12.xyz = cmp(float3(0,0,0) < r11.xyz);
    r3.z = r12.y ? r12.x : 0;
    r3.z = r12.z ? r3.z : 0;
    r4.w = cmp(0 < r2.w);
    r3.z = r4.w ? r3.z : 0;
    if (r3.z != 0) {
      r11.xyz = saturate(cb12[160].xyz * r11.xyz);
      r3.z = 1 + -r2.y;
      r2.w = r3.z * r2.w;
      r2.w = cb12[159].x * r2.w;
      r3.z = r11.x * r11.y;
      r3.z = r3.z * r11.z;
      r4.w = r3.z * r2.w;
      r2.y = r2.w * r3.z + r2.y;
      r2.w = cb12[165].x * r4.w;
      r3.z = asint(cb12[170].x);
      r11.y = r3.z * 0.142857149 + r5.y;
      r11.x = r5.x;
      r11.xyz = t22.SampleLevel(s11_s, r11.xy, 1).xyz;
      r6.xyz = r2.www * r11.xyz + r6.xyz;
      r11.xyz = cb12[167].xyz * r0.yyy;
      r11.xyz = cb12[166].xyz * r0.xxx + r11.xyz;
      r11.xyz = cb12[168].xyz * r0.www + r11.xyz;
      r12.xyz = cb12[167].xyz * v2.yyy;
      r12.xyz = cb12[166].xyz * v2.xxx + r12.xyz;
      r12.xyz = cb12[168].xyz * v2.zzz + r12.xyz;
      r12.xyz = cb12[169].xyz + r12.xyz;
      r11.xyz = float3(1,1,1) / r11.xyz;
      r13.xyz = -r12.xyz * r11.xyz + r11.xyz;
      r11.xyz = -r12.xyz * r11.xyz + -r11.xyz;
      r11.xyz = max(r13.xyz, r11.xyz);
      r3.z = min(r11.y, r11.z);
      r3.z = min(r11.x, r3.z);
      r11.xyz = r0.xyw * r3.zzz + v2.xyz;
      r11.xyz = -cb12[159].yzw + r11.xyz;
      r3.z = dot(r11.xyz, r11.xyz);
      r3.z = rsqrt(r3.z);
      r12.xyz = r11.xyz * r3.zzz;
      r4.w = cmp(r12.z < 0);
      r5.z = r4.w ? 1.f : 0.f;
      r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r12.xyxy;
      r5.w = -r11.z * r3.z + 1;
      r5.w = max(0.00100000005, r5.w);
      r8.xw = r12.xy / r5.ww;
      r8.xw = float2(0.5,0.5) + r8.xw;
      r3.z = r11.z * r3.z + 1;
      r3.z = max(0.00100000005, r3.z);
      r11.xy = r12.zw / r3.zz;
      r11.xy = float2(0.5,0.5) + r11.xy;
      r8.xw = r4.ww ? r8.xw : r11.xy;
      r8.xw = r8.xw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r12.y = asint(cb12[170].x);
      r12.z = (int)r5.z;
      r12.xw = float2(0,0);
      r5.zw = r12.zw + r8.xw;
      r5.zw = r12.xy + r5.zw;
      r5.zw = float2(0.5,0.142857149) * r5.zw;
      r11.xyz = t23.SampleLevel(s11_s, r5.zw, r2.x).xyz;
      r10.xyz = r2.www * r11.xyz + r10.xyz;
    }
  }
  r2.w = cmp(r2.y < 0.999000013);
  r2.z = r2.w ? r2.z : 0;
  if (r2.z != 0) {
    r11.xyz = cb12[174].xyz * v2.yyy;
    r11.xyz = cb12[173].xyz * v2.xxx + r11.xyz;
    r11.xyz = cb12[175].xyz * v2.zzz + r11.xyz;
    r11.xyz = cb12[176].xyz + r11.xyz;
    r11.xyz = float3(1,1,1) + -abs(r11.xyz);
    if (r1.w != 0) {
      r2.zw = asint(cb12[177].yy) & int2(1,2);
      r1.w = r2.z ? 1 : r8.y;
      r2.z = 1 + -r8.y;
      r2.z = r2.w ? 1 : r2.z;
      r1.w = r2.z * r1.w;
    } else {
      r1.w = 1;
    }
    r8.xyw = cmp(float3(0,0,0) < r11.xyz);
    r2.z = r8.y ? r8.x : 0;
    r2.z = r8.w ? r2.z : 0;
    r2.w = cmp(0 < r1.w);
    r2.z = r2.w ? r2.z : 0;
    if (r2.z != 0) {
      r8.xyw = saturate(cb12[172].xyz * r11.xyz);
      r2.z = 1 + -r2.y;
      r1.w = r2.z * r1.w;
      r1.w = cb12[171].x * r1.w;
      r2.z = r8.x * r8.y;
      r2.z = r2.z * r8.w;
      r2.w = r2.z * r1.w;
      r2.y = r1.w * r2.z + r2.y;
      r1.w = cb12[177].x * r2.w;
      r2.z = asint(cb12[182].x);
      r8.y = r2.z * 0.142857149 + r5.y;
      r8.x = r5.x;
      r8.xyw = t22.SampleLevel(s11_s, r8.xy, 1).xyz;
      r6.xyz = r1.www * r8.xyw + r6.xyz;
      r8.xyw = cb12[179].xyz * r0.yyy;
      r8.xyw = cb12[178].xyz * r0.xxx + r8.xyw;
      r8.xyw = cb12[180].xyz * r0.www + r8.xyw;
      r11.xyz = cb12[179].xyz * v2.yyy;
      r11.xyz = cb12[178].xyz * v2.xxx + r11.xyz;
      r11.xyz = cb12[180].xyz * v2.zzz + r11.xyz;
      r11.xyz = cb12[181].xyz + r11.xyz;
      r8.xyw = float3(1,1,1) / r8.xyw;
      r12.xyz = -r11.xyz * r8.xyw + r8.xyw;
      r8.xyw = -r11.xyz * r8.xyw + -r8.xyw;
      r8.xyw = max(r12.xyz, r8.xyw);
      r2.z = min(r8.y, r8.w);
      r2.z = min(r8.x, r2.z);
      r8.xyw = r0.xyw * r2.zzz + v2.xyz;
      r8.xyw = -cb12[171].yzw + r8.xyw;
      r2.z = dot(r8.xyw, r8.xyw);
      r2.z = rsqrt(r2.z);
      r11.xyz = r8.xyw * r2.zzz;
      r2.w = cmp(r11.z < 0);
      r3.z = r2.w ? 1.f : 0.f;
      r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r11.xyxy;
      r4.w = -r8.w * r2.z + 1;
      r4.w = max(0.00100000005, r4.w);
      r5.zw = r12.xy / r4.ww;
      r5.zw = float2(0.5,0.5) + r5.zw;
      r2.z = r8.w * r2.z + 1;
      r2.z = max(0.00100000005, r2.z);
      r8.xy = r12.zw / r2.zz;
      r8.xy = float2(0.5,0.5) + r8.xy;
      r2.zw = r2.ww ? r5.zw : r8.xy;
      r2.zw = r2.zw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r12.y = asint(cb12[182].x);
      r12.z = (int)r3.z;
      r12.xw = float2(0,0);
      r2.zw = r12.zw + r2.zw;
      r2.zw = r12.xy + r2.zw;
      r2.zw = float2(0.5,0.142857149) * r2.zw;
      r8.xyw = t23.SampleLevel(s11_s, r2.zw, r2.x).xyz;
      r10.xyz = r1.www * r8.xyw + r10.xyz;
    }
  }
  r1.w = cmp(r2.y < 0.999000013);
  if (r1.w != 0) {
    r1.w = 1 + -r2.y;
    r2.z = cb12[99].x * r1.w;
    r2.y = r1.w * cb12[99].x + r2.y;
    r1.w = cb12[105].x * r2.z;
    r2.z = asint(cb12[110].x);
    r5.y = r2.z * 0.142857149 + r5.y;
    r5.xyz = t22.SampleLevel(s11_s, r5.xy, 1).xyz;
    r6.xyz = r1.www * r5.xyz + r6.xyz;
    r2.z = cmp(r0.w < 0);
    r2.w = r2.z ? 1.f : 0.f;
    r5.xyzw = float4(0.5,-0.5,-0.5,0.5) * r0.xyxy;
    r0.x = 1 + -r0.w;
    r0.x = max(0.00100000005, r0.x);
    r0.xy = r5.xy / r0.xx;
    r0.xy = float2(0.5,0.5) + r0.xy;
    r0.w = 1 + r0.w;
    r0.w = max(0.00100000005, r0.w);
    r5.xy = r5.zw / r0.ww;
    r5.xy = float2(0.5,0.5) + r5.xy;
    r0.xy = r2.zz ? r0.xy : r5.xy;
    r0.xy = r0.xy * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
    r5.y = asint(cb12[110].x);
    r5.z = (int)r2.w;
    r5.xw = float2(0,0);
    r0.xy = r5.zw + r0.xy;
    r0.xy = r5.xy + r0.xy;
    r0.xy = float2(0.5,0.142857149) * r0.xy;
    r0.xyw = t23.SampleLevel(s11_s, r0.xy, r2.x).xyz;
    r10.xyz = r1.www * r0.xyw + r10.xyz;
  }
  r0.x = 1 / r2.y;
  r2.xyz = r6.xyz * r0.xxx;
  r0.xyw = r10.xyz * r0.xxx;
  r1.w = abs(cb2[16].x) + -cb2[16].y;
  r5.xyz = r9.xyz * r1.www + cb2[16].yyy;
  r1.w = cb2[16].z + -cb2[16].w;
  r6.xyz = r9.xyz * r1.www + cb2[16].www;
  r2.xyz = r5.xyz * r2.xyz;
  r0.xyw = r6.xyz * r0.xyw;
  r5.xy = -cb12[0].xy + v2.xy;
  r1.w = dot(r5.xy, r5.xy);
  r1.w = sqrt(r1.w);
  r1.w = saturate(r1.w * cb12[218].x + cb12[218].y);
  r2.w = -1 + cb12[184].z;
  r1.w = r1.w * r2.w + 1;
  r2.w = cb12[183].x + -cb12[183].y;
  r5.xyz = r9.xyz * r2.www + cb12[183].yyy;
  r5.xyz = r5.xyz * r1.www;
  r2.w = cb12[184].x + -cb12[184].y;
  r6.xyz = r9.xyz * r2.www + cb12[184].yyy;
  r6.xyz = r6.xyz * r1.www;
  r8.xyw = cb12[183].zzz * r16.xyz;
  r2.xyz = r5.xyz * r2.xyz;
  r1.w = dot(r3.xyw, r7.xyz);
  r1.w = max(abs(r1.w), abs(r1.w));
  r1.w = 1 + -r1.w;
  r1.w = max(0, r1.w);
  r2.w = r1.w * r1.w;
  r2.w = r2.w * r2.w;
  r1.w = r2.w * r1.w;
  r2.w = min(1, cb13[56].y);
  r2.w = r2.w * r11.w;
  r1.w = r2.w * r1.w;
  r1.w = r1.w / r14.y;
  r0.z = r1.w + r0.z;
  r1.w = 1 + -r0.z;
  r2.xyz = r2.xyz * r1.www;
  r0.xyw = r6.xyz * r0.xyw;
  r0.xyz = r0.xyw * r0.zzz;
  r0.w = 1 + -cb13[55].w;
  r3.xyz = r9.xyz * r0.www + cb13[55].www;
  r1.xyz = r3.xyz * r1.xyz;
  r1.xyz = cb13[55].xyz * r1.xyz;
  r1.xyz = r17.xyz * cb12[183].www + r1.xyz;
  r0.w = cb12[69].x + cb12[69].y;
  r3.xyz = r8.xyw * r0.www;
  r1.xyz = r1.xyz * r0.www;
  r2.xyz = r2.xyz * r8.zzz + r3.xyz;
  r1.xyz = r4.xyz * r2.xyz + r1.xyz;
  o0.xyz = r0.xyz * r8.zzz + r1.xyz;
  o0.w = 1;
  WriteObjectMotion(v4, previous_clip, motion_history, object_motion, object_depth);
  return;
}