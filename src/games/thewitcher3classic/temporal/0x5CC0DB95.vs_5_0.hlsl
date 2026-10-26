ByteAddressBuffer Raw21 : register(t21);
// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 12:40:52 2026
Texture2D<float4> t24 : register(t24);

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t22 : register(t22);

Texture2DArray<float4> t19 : register(t19);

Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float4> t8 : register(t8);

SamplerState s14_s : register(s14);

SamplerState s11_s : register(s11);

SamplerState s10_s : register(s10);

SamplerComparisonState s9_s : register(s9);

cbuffer cb13 : register(b13)
{
  float4 cb13[3323];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[183];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[7];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}




// 3Dmigoto declarations
#define cmp -


#include "./deformed_vertex.hlsli"

void main(
  float3 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TANGENT0,
  float2 v3 : TEXCOORD0,
  uint vertex : SV_VertexID,
  out float4 o0 : TEXCOORD0,
  out float4 o1 : TEXCOORD1,
  out float4 o2 : TEXCOORD2,
  out float4 o3 : TEXCOORD3,
  out float4 o4 : TEXCOORD4,
  out float4 o5 : TEXCOORD5,
  out float4 o6 : TEXCOORD6,
  out float4 o7 : TEXCOORD7,
  out precise float4 o8 : SV_Position0,
  out float4 previous_clip : TEXCOORD10,
  out nointerpolation float motion_history : TEXCOORD11)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = v0.xyz;
  r0.w = 1;
  r1.x = dot(r0.xyzw, cb2[0].xyzw);
  r1.y = dot(r0.xyzw, cb2[1].xyzw);
  r1.z = dot(r0.xyzw, cb2[2].xyzw);
  // Preserve native clip MAD ordering for the opaque depth-equal pass.
  r2.xyzw = cb2[1].xyzw * cb1[0].yyyy;
  r2.xyzw = mad(cb2[0].xyzw, cb1[0].xxxx, r2.xyzw);
  r2.xyzw = mad(cb2[2].xyzw, cb1[0].zzzz, r2.xyzw);
  r2.xyzw = mad(cb1[0].wwww, float4(0,0,0,1), r2.xyzw);
  r3.xyzw = cb2[1].xyzw * cb1[1].yyyy;
  r3.xyzw = mad(cb2[0].xyzw, cb1[1].xxxx, r3.xyzw);
  r3.xyzw = mad(cb2[2].xyzw, cb1[1].zzzz, r3.xyzw);
  r3.xyzw = mad(cb1[1].wwww, float4(0,0,0,1), r3.xyzw);
  r4.xyzw = cb2[1].xyzw * cb1[2].yyyy;
  r4.xyzw = mad(cb2[0].xyzw, cb1[2].xxxx, r4.xyzw);
  r4.xyzw = mad(cb2[2].xyzw, cb1[2].zzzz, r4.xyzw);
  r4.xyzw = mad(cb1[2].wwww, float4(0,0,0,1), r4.xyzw);
  r5.xyzw = cb2[1].xyzw * cb1[3].yyyy;
  r5.xyzw = mad(cb2[0].xyzw, cb1[3].xxxx, r5.xyzw);
  r5.xyzw = mad(cb2[2].xyzw, cb1[3].zzzz, r5.xyzw);
  r5.xyzw = mad(cb1[3].wwww, float4(0,0,0,1), r5.xyzw);
  o8.x = dot(r0.xyzw, r2.xyzw);
  o8.y = dot(r0.xyzw, r3.xyzw);
  o8.z = dot(r0.xyzw, r4.xyzw);
  o8.w = dot(r0.xyzw, r5.xyzw);
  r0.xyz = v2.zxy * v1.yzx;
  r0.xyz = v2.yzx * v1.zxy + -r0.xyz;
  r0.xyz = v2.www * r0.xyz;
  r2.x = dot(v1.xyz, cb2[0].xyz);
  r2.y = dot(v1.xyz, cb2[1].xyz);
  r2.z = dot(v1.xyz, cb2[2].xyz);
  r0.w = dot(r2.xyz, r2.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyw = r2.xyz * r0.www;
  r3.x = dot(r0.xyz, cb2[0].xyz);
  r3.y = dot(r0.xyz, cb2[1].xyz);
  r3.z = dot(r0.xyz, cb2[2].xyz);
  r0.x = dot(r3.xyz, r3.xyz);
  r0.x = rsqrt(r0.x);
  o5.xyz = r3.xyz * r0.xxx;
  r0.x = dot(v2.xyz, cb2[0].xyz);
  r0.y = dot(v2.xyz, cb2[1].xyz);
  r0.z = dot(v2.xyz, cb2[2].xyz);
  r1.w = dot(r0.xyz, r0.xyz);
  r1.w = rsqrt(r1.w);
  r0.xyz = r1.www * r0.xyz;
  o2.w = 1 + -v3.y;
  r3.xyzw = cb12[2].xyzw * r1.yyyy;
  r3.xyzw = cb12[1].xyzw * r1.xxxx + r3.xyzw;
  r3.xyzw = cb12[3].xyzw * r1.zzzz + r3.xyzw;
  r3.xyzw = cb12[4].xyzw + r3.xyzw;
  r4.xyz = cb12[14].xyw * r3.yyy;
  r4.xyz = cb12[13].xyw * r3.xxx + r4.xyz;
  r4.xyz = cb12[15].xyw * r3.zzz + r4.xyz;
  r4.xyz = cb12[16].xyw * r3.www + r4.xyz;
  r1.w = max(9.99999975e-005, r4.z);
  r4.xy = r4.xy / r1.ww;
  r5.xy = r4.xy * float2(0.5,-0.5) + float2(0.5,0.5);
  r5.xy = cb12[23].xy * r5.xy;
  r1.w = cmp(0 < asint(cb13[35].x));
  if (r1.w != 0) {
    r5.zw = -cb12[0].xy + r1.xy;
    r1.w = dot(r5.zw, r5.zw);
    r1.w = sqrt(r1.w);
    r4.w = cmp(r1.w < cb13[36].y);
    if (r4.w != 0) {
      r4.w = cb13[37].z * r1.w;
      r4.w = max(1, r4.w);
      r4.w = cb13[36].x / r4.w;
      r4.w = min(1, r4.w);
      r1.w = cb13[36].z + r1.w;
      r1.w = saturate(cb13[36].w * r1.w);
      r6.y = 0;
      r5.zw = float2(0,0);
      r6.z = 0;
      while (true) {
        r6.w = cmp((int)r5.w >= asint(cb13[35].x));
        r6.z = 0;
        if (r6.w != 0) break;
        r7.xy = -cb13[r5.w+39].xy + r1.xy;
        r8.xy = cb13[r5.w+39].zw * r7.xy;
        r7.xz = cmp(r8.xy >= float2(0,0));
        r6.w = r7.z ? r7.x : 0;
        r7.xz = cmp(float2(1,1) >= r8.xy);
        r6.w = r6.w ? r7.x : 0;
        r6.w = r7.z ? r6.w : 0;
        if (r6.w != 0) {
          r8.z = (int)r5.w;
          r8.w = -r7.y * cb13[r5.w+39].w + 1;
          r7.x = t19.SampleLevel(s10_s, r8.xwz, 0).x;
          r7.x = cb13[38].x * r7.x + cb13[38].y;
          r7.x = r7.x + -r1.z;
          r7.x = -0.100000001 + r7.x;
          r7.x = saturate(r7.x * r4.w);
          r7.x = 1 + -r7.x;
          r7.y = 1 + -r7.x;
          r5.z = r1.w * r7.y + r7.x;
          r6.z = -1;
          break;
        }
        r6.x = (int)r5.w + 1;
        r5.zw = r6.yx;
        r6.z = r6.w;
      }
    } else {
      r6.z = 0;
    }
  } else {
    r6.z = 0;
  }
  r6.x = r6.z ? r5.z : 1;
  r1.w = cmp(0 < r6.x);
  if (r1.w != 0) {
    r7.xyz = cb13[5].xyz * r1.yyy;
    r7.xyz = cb13[4].xyz * r1.xxx + r7.xyz;
    r7.xyz = cb13[6].xyz * r1.zzz + r7.xyz;
    r7.xyz = cb13[7].xyz + r7.xyz;
    r1.w = cmp(abs(r7.z) >= 0.999000013);
    if (r1.w != 0) {
      r4.w = 1;
    }
    if (r1.w == 0) {
      r8.xyzw = -cb13[8].xyzw + r7.xxxx;
      r9.xyzw = -cb13[9].xyzw + r7.yyyy;
      r8.xyzw = max(abs(r9.xyzw), abs(r8.xyzw));
      r9.xyzw = cmp(r8.xyzw < cb13[10].xyzw);
      r9.xyzw = r9.xyzw ? float4(1,1,1,1) : 0;
      r10.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb13[15].zzzz);
      r10.xyzw = r10.xyzw ? float4(1,1,1,1) : 0;
      r1.w = dot(r9.xyzw, r10.xyzw);
      r5.z = cmp(r1.w < 0.5);
      if (r5.z != 0) {
        r4.w = 1;
      }
      if (r5.z == 0) {
        r8.xyzw = r8.xyzw / cb13[10].xyzw;
        r9.xyzw = float4(1,1,1,1) + -cb13[17].xyzw;
        r8.xyzw = -r9.xyzw + r8.xyzw;
        r8.xyzw = saturate(r8.xyzw / cb13[17].xyzw);
        r1.w = cb13[15].z + -r1.w;
        r5.w = (int)r1.w;
        r7.w = (int)cb13[15].z;
        r7.w = (int)r7.w + -1;
        r9.xy = cb13[r5.w+11].zz * float2(1,-1);
        r9.xy = r7.xy * r9.xy + cb13[r5.w+11].xy;
        r9.z = trunc(r1.w);
        r1.w = cmp(asint(cb13[18].x) >= 1);
        if (r1.w != 0) {
          r1.w = t8.SampleCmpLevelZero(s9_s, r9.xyz, r7.z).x;
          r10.xyzw = cb13[r5.w+11].wwww * float4(-2.10683131,0.317230552,-5.7376194,2.94642639) + r9.xyxy;
          r11.xy = r10.xy;
          r11.z = r9.z;
          r7.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r7.z).x;
          r1.w = r7.x + r1.w;
          r11.xy = r10.zw;
          r7.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r7.z).x;
          r1.w = r7.x + r1.w;
          r10.xyzw = cb13[r5.w+11].wwww * float4(-0.159624487,-3.19071364,-3.52795029,-1.76808) + r9.xyxy;
          r11.xy = r10.xy;
          r7.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r7.z).x;
          r1.w = r7.x + r1.w;
          r11.xy = r10.zw;
          r7.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r7.z).x;
          r1.w = r7.x + r1.w;
          r11.xy = cb13[r5.w+11].ww * float2(1.76031363,2.3547585) + r9.xy;
          r5.w = t8.SampleCmpLevelZero(s9_s, r11.xyz, r7.z).x;
          r1.w = r5.w + r1.w;
          r1.w = 0.166666672 * r1.w;
          r1.w = r1.w * r1.w;
        } else {
          r5.w = t8.SampleCmpLevelZero(s9_s, r9.xyz, r7.z).x;
          r1.w = r5.w * r5.w;
        }
        r5.w = (int)r7.w;
        r5.w = cmp(r9.z >= r5.w);
        r5.w = r5.w ? 1.000000 : 0;
        r7.x = dot(r8.xyzw, icb[r7.w+0].xyzw);
        r1.w = r5.w * r7.x + r1.w;
        r1.w = min(1, r1.w);
      } else {
        r1.w = 1;
      }
      r4.w = r5.z ? r4.w : r1.w;
    }
    r1.w = r6.x * r4.w;
    r4.w = 20 * cb12[66].x;
    r7.zw = trunc(cb12[68].xy);
    r8.xyz = -cb12[0].xyz + r1.xyz;
    r5.z = dot(r8.xyz, r8.xyz);
    r5.z = sqrt(r5.z);
    r8.xy = cb12[67].xy;
    r8.z = 0;
    r8.xyz = r8.xyz + r1.xyz;
    r8.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r8.xyz;
    r8.xyz = r8.xyz / cb12[66].xxx;
    r9.xy = float2(20,20) * cb12[67].xy;
    r9.z = 0;
    r9.xyz = r9.xyz + r1.xyz;
    r9.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r9.xyz;
    r9.xyz = r9.xyz / r4.www;
    r8.zw = cb13[0].xy * r8.zz;
    r8.zw = r8.zw / cb13[0].zz;
    r7.xy = r8.xy + -r8.zw;
    r8.xy = cb13[0].xy * r9.zz;
    r8.xy = r8.xy / cb13[0].zz;
    r8.xy = r9.xy + -r8.xy;
    r4.w = t14.SampleLevel(s14_s, r7.xyz, 1).x;
    r5.w = t14.SampleLevel(s14_s, r7.xyw, 1).x;
    r5.w = r5.w + -r4.w;
    r4.w = cb12[66].w * r5.w + r4.w;
    r8.zw = r7.zw;
    r5.w = t14.SampleLevel(s14_s, r8.xyz, 1).x;
    r7.x = t14.SampleLevel(s14_s, r8.xyw, 1).x;
    r7.x = r7.x + -r5.w;
    r5.w = cb12[66].w * r7.x + r5.w;
    r7.x = -0.25 + cb13[0].z;
    r7.x = saturate(10 * r7.x);
    r5.z = -100 + r5.z;
    r5.z = saturate(0.00666666683 * r5.z);
    r5.w = r5.w + -r4.w;
    r4.w = r5.z * r5.w + r4.w;
    r4.w = -r7.x * r4.w + 1;
    r6.x = r4.w * r1.w;
  }
  r5.xy = (int2)r5.xy;
  r5.zw = (int2)r5.xy ^ int2(2,2);
  r7.xy = max((int2)-r5.xy, (int2)r5.xy);
  r7.xy = (uint2)r7.xy >> int2(1,1);
  r7.zw = -(int2)r7.xy;
  r5.zw = (int2)r5.zw & int2(0x80000000,0x80000000);
  r7.xy = r5.zw ? r7.zw : r7.xy;
  r7.zw = float2(0,0);
  r5.zw = t24.Load(r7.xyz).xy;
  r7.xyz = -cb12[0].xyz + r1.xyz;
  r1.w = dot(r7.xyz, r7.xyz);
  r1.w = sqrt(r1.w);
  r8.x = cb12[1].z;
  r8.y = cb12[2].z;
  r8.z = cb12[3].z;
  r4.w = dot(r8.xyz, r7.xyz);
  r7.x = 1 / cb12[21].y;
  r7.x = r7.x * r1.w;
  r4.w = r7.x / r4.w;
  r4.w = -r4.w + r1.w;
  r4.w = saturate(cb13[33].w * r4.w);
  r4.w = cb13[33].z * r4.w;
  r4.w = max(0.00100000005, r4.w);
  r1.w = r1.w / cb13[34].z;
  r7.x = cmp(r5.z < r5.w);
  if (r7.x != 0) {
    r7.x = cmp(r1.w < r5.z);
    r7.y = cmp(r5.w < r1.w);
    r7.z = cb13[34].z * r5.z + -cb13[34].x;
    r7.z = saturate(-r7.z * cb13[34].y + 1);
    r7.w = r1.w + -r5.z;
    r7.w = cb13[34].z * r7.w;
    r7.w = saturate(r7.w / r4.w);
    r8.y = r7.z * r7.w;
    r7.x = (int)r7.x | (int)r7.y;
    r8.x = 1;
    r7.xy = r7.xx ? float2(0,1) : r8.xy;
  } else {
    r7.z = cmp(r5.w < r5.z);
    r7.w = cmp(r1.w < r5.w);
    r8.x = cmp(r5.z < r1.w);
    r5.z = cb13[34].z * r5.z + -cb13[34].x;
    r9.y = saturate(-r5.z * cb13[34].y + 1);
    r1.w = r1.w + -r5.w;
    r1.w = cb13[34].z * r1.w;
    r1.w = saturate(r1.w / r4.w);
    r9.w = 1 + -r1.w;
    r9.xz = float2(1,1);
    r5.zw = r8.xx ? r9.xy : r9.zw;
    r5.zw = r7.ww ? float2(1,1) : r5.zw;
    r7.xy = r7.zz ? r5.zw : float2(0,1);
  }
  r1.w = -r7.y * r7.x + 1;
  r5.zw = (int2)r5.xy & int2(1,1);
  r7.xy = r5.ww ? float2(1,3) : float2(2,0);
  r4.w = r5.z ? r7.x : r7.y;
  if (1 == 0) r7.x = 0; else if (1+1 < 32) {   r7.x = (uint)r5.x << (32-(1 + 1)); r7.x = (uint)r7.x >> (32-1);  } else r7.x = (uint)r5.x >> 1;
  if (1 == 0) r7.y = 0; else if (1+1 < 32) {   r7.y = (uint)r5.y << (32-(1 + 1)); r7.y = (uint)r7.y >> (32-1);  } else r7.y = (uint)r5.y >> 1;
  if (1 == 0) r7.z = 0; else if (1+2 < 32) {   r7.z = (uint)r5.x << (32-(1 + 2)); r7.z = (uint)r7.z >> (32-1);  } else r7.z = (uint)r5.x >> 2;
  if (1 == 0) r7.w = 0; else if (1+2 < 32) {   r7.w = (uint)r5.y << (32-(1 + 2)); r7.w = (uint)r7.w >> (32-1);  } else r7.w = (uint)r5.y >> 2;
  r8.xyzw = r7.yyww ? float4(1,3,1,3) : float4(2,0,2,0);
  r5.zw = r7.xz ? r8.xz : r8.yw;
  r4.w = (uint)r4.w << 4;
  r4.w = mad((int)r5.z, 4, (int)r4.w);
  r4.w = (int)r4.w + (int)r5.w;
  r4.w = (int)r4.w;
  r4.w = 0.5 + r4.w;
  r5.z = 0.015625 * r4.w;
  r5.xy = (uint2)r5.xy >> int2(5,5);
  r5.w = (int)cb12[24].z;
  r5.x = mad((int)r5.y, (int)r5.w, (int)r5.x);
  r4.w = -r4.w * 0.015625 + 1;
  r3.w = 1;
  r7.xzw = float3(0,0,0);
  r8.xyzw = float4(0,0,0,0);
  r5.y = 0;
  while (true) {
    r5.w = cmp((uint)r5.y >= 192);
    if (r5.w != 0) break;
    r5.w = mad((int)r5.x, 192, (int)r5.y);
    r5.w = (uint)r5.w << 2;
    r5.w = Raw21.Load((uint)r5.w);
    r9.x = cmp((uint)r5.w >= 192);
    if (r9.x != 0) {
      break;
    }
    r5.w = (int)r5.w * 5;
    r9.x = dot(r3.xyzw, cb13[r5.w+2363].xyzw);
    r9.y = dot(r3.xyzw, cb13[r5.w+2364].xyzw);
    r9.z = dot(r3.xyzw, cb13[r5.w+2365].xyzw);
    r10.xyz = cmp(abs(r9.xyz) < float3(1,1,1));
    r9.w = r10.y ? r10.x : 0;
    r9.w = r10.z ? r9.w : 0;
    if (r9.w != 0) {
      r9.w = asuint(cb13[r5.w+2366].w) >> 16;
      r9.w = (uint)r9.w;
      r9.w = 1.52590219e-005 * r9.w;
      r10.x = 0x0000ffff & asint(cb13[r5.w+2366].w);
      r10.x = (uint)r10.x;
      r10.x = 1.52590219e-005 * r10.x;
      r9.x = dot(r9.xyz, r9.xyz);
      r9.x = sqrt(r9.x);
      r9.x = 1 + -r9.x;
      r9.x = max(0, r9.x);
      r9.xy = cb13[r5.w+2367].wx * r9.xx;
      r9.x = saturate(r9.x);
      r9.z = cmp(-1.000000 == cb13[r5.w+2367].w);
      r10.y = cmp(r9.w >= r4.w);
      r7.y = r10.y ? 1.000000 : 0;
      r9.w = cmp(r9.w >= r5.z);
      r9.w = r9.w ? 1.000000 : 0;
      r10.x = r10.x * r9.w;
      r10.y = min(0.998037279, r9.y);
      r10.zw = cb13[r5.w+2367].yz * r9.xx;
      r9.xyzw = r9.zzzz ? r7.xyzw : r10.xyzw;
      r8.xyzw = max(r8.xyzw, r9.xyzw);
    }
    r5.y = (int)r5.y + 1;
  }
  r3.x = r8.y * r8.y;
  r3.y = cmp(0 < r8.x);
  r3.z = r3.y ? 0 : 1;
  r1.w = r1.w * r1.w;
  r1.w = min(r3.z, r1.w);
  r1.w = max(r1.w, r3.x);
  r1.w = 1 + -r1.w;
  r3.x = 1 + -r8.x;
  r3.z = 1 + -cb13[33].y;
  r3.x = r3.y ? r3.x : r3.z;
  r3.yz = float2(1,1) + -r8.zw;
  r3.x = min(r3.x, r3.y);
  r3.x = r3.x + -r3.z;
  r6.y = saturate(r1.w * r3.x + r3.z);
  r6.z = saturate(1 + -r1.w);
  r1.w = cmp(0 < r4.z);
  r3.x = max(abs(r4.x), abs(r4.y));
  r3.x = 1 + -r3.x;
  r3.x = saturate(10 * r3.x);
  r1.w = r1.w ? r3.x : 0;
  r3.xyz = -cb1[8].xyz + r1.xyz;
  r3.w = dot(r3.xyz, r3.xyz);
  r3.w = rsqrt(r3.w);
  r3.xyz = r3.xyz * r3.www;
  r3.w = dot(r3.xyz, r2.xyw);
  r3.w = r3.w + r3.w;
  r3.xyz = -r3.www * r2.xyw + r3.xyz;
  r3.w = cmp(r2.w < 0);
  // Native integer bit 1 selects the other environment-probe hemisphere.
  // The decompiler rounded its float bit pattern to zero before the int-to-float conversion.
  r4.x = r3.w ? 1.f : 0.f;
  r5.xyzw = float4(0.5,-0.5,-0.5,0.5) * r2.xyxy;
  r4.y = -r2.z * r0.w + 1;
  r4.y = max(0.00100000005, r4.y);
  r4.yz = r5.xy / r4.yy;
  r4.yz = float2(0.5,0.5) + r4.yz;
  r0.w = r2.z * r0.w + 1;
  r0.w = max(0.00100000005, r0.w);
  r5.xy = r5.zw / r0.ww;
  r5.xy = float2(0.5,0.5) + r5.xy;
  r4.yz = r3.ww ? r4.yz : r5.xy;
  r4.yz = r4.yz * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
  r5.x = (int)r4.x;
  r5.y = 0;
  r4.xy = r5.xy + r4.yz;
  r4.xy = float2(0.5,0.142857149) * r4.xy;
  r5.xyz = cb12[114].xyz * r1.yyy;
  r5.xyz = cb12[113].xyz * r1.xxx + r5.xyz;
  r5.xyz = cb12[115].xyz * r1.zzz + r5.xyz;
  r5.xyz = cb12[116].xyz + r5.xyz;
  r5.xyz = float3(1,1,1) + -abs(r5.xyz);
  r7.xy = asint(cb12[117].yy) & int2(1,2);
  r0.w = r7.x ? 1 : r6.z;
  r2.z = 1 + -r6.z;
  r3.w = r7.y ? 1 : r2.z;
  r0.w = r3.w * r0.w;
  r7.xyz = cmp(float3(0,0,0) < r5.xyz);
  r3.w = r7.y ? r7.x : 0;
  r3.w = r7.z ? r3.w : 0;
  r5.w = cmp(0 < r0.w);
  r3.w = r5.w ? r3.w : 0;
  if (r3.w != 0) {
    r5.xyz = saturate(cb12[112].xyz * r5.xyz);
    r0.w = cb12[111].x * r0.w;
    r0.w = 0.999989986 * r0.w;
    r3.w = r5.x * r5.y;
    r3.w = r3.w * r5.z;
    r5.x = r3.w * r0.w;
    r0.w = r0.w * r3.w + 9.99999975e-006;
    r3.w = cb12[117].x * r5.x;
    r5.x = asint(cb12[122].x);
    r4.z = r5.x * 0.142857149 + r4.y;
    r5.xyz = t22.SampleLevel(s11_s, r4.xz, 1).xyz;
    r5.xyz = r5.xyz * r3.www;
    r4.z = dot(r3.xyz, r3.xyz);
    r4.z = rsqrt(r4.z);
    r7.xyz = r4.zzz * r3.xyz;
    r5.w = cmp(r7.z < 0);
    r7.z = r5.w ? 1.f : 0.f;
    r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r7.xyxy;
    r7.x = -r3.z * r4.z + 1;
    r7.x = max(0.00100000005, r7.x);
    r7.xy = r8.xy / r7.xx;
    r7.xy = float2(0.5,0.5) + r7.xy;
    r4.z = r3.z * r4.z + 1;
    r4.z = max(0.00100000005, r4.z);
    r8.xy = r8.zw / r4.zz;
    r8.xy = float2(0.5,0.5) + r8.xy;
    r7.xy = r5.ww ? r7.xy : r8.xy;
    r7.xy = r7.xy * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
    r8.y = asint(cb12[122].x);
    r8.z = (int)r7.z;
    r8.xw = float2(0,0);
    r7.xy = r8.zw + r7.xy;
    r7.xy = r8.xy + r7.xy;
    r7.xy = float2(0.5,0.142857149) * r7.xy;
    r7.xyz = t23.SampleLevel(s11_s, r7.xy, 5).xyz;
    r7.xyz = r7.xyz * r3.www;
  } else {
    r5.xyz = float3(0,0,0);
    r7.xyz = float3(0,0,0);
    r0.w = 9.99999975e-006;
  }
  r3.w = cmp(r0.w < 0.999000013);
  if (r3.w != 0) {
    r8.xyz = cb12[126].xyz * r1.yyy;
    r8.xyz = cb12[125].xyz * r1.xxx + r8.xyz;
    r8.xyz = cb12[127].xyz * r1.zzz + r8.xyz;
    r8.xyz = cb12[128].xyz + r8.xyz;
    r8.xyz = float3(1,1,1) + -abs(r8.xyz);
    r9.xy = asint(cb12[129].yy) & int2(1,2);
    r4.z = r9.x ? 1 : r6.z;
    r5.w = r9.y ? 1 : r2.z;
    r4.z = r5.w * r4.z;
    r9.xyz = cmp(float3(0,0,0) < r8.xyz);
    r5.w = r9.y ? r9.x : 0;
    r5.w = r9.z ? r5.w : 0;
    r7.w = cmp(0 < r4.z);
    r5.w = r7.w ? r5.w : 0;
    if (r5.w != 0) {
      r8.xyz = saturate(cb12[124].xyz * r8.xyz);
      r5.w = 1 + -r0.w;
      r4.z = r5.w * r4.z;
      r4.z = cb12[123].x * r4.z;
      r5.w = r8.x * r8.y;
      r5.w = r5.w * r8.z;
      r7.w = r5.w * r4.z;
      r0.w = r4.z * r5.w + r0.w;
      r4.z = cb12[129].x * r7.w;
      r5.w = asint(cb12[134].x);
      r4.w = r5.w * 0.142857149 + r4.y;
      r8.xyz = t22.SampleLevel(s11_s, r4.xw, 1).xyz;
      r5.xyz = r4.zzz * r8.xyz + r5.xyz;
      r4.w = dot(r3.xyz, r3.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r4.www * r3.xyz;
      r5.w = cmp(r8.z < 0);
      r7.w = r5.w ? 1.f : 0.f;
      r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
      r9.x = -r3.z * r4.w + 1;
      r9.x = max(0.00100000005, r9.x);
      r8.xy = r8.xy / r9.xx;
      r4.w = r3.z * r4.w + 1;
      r4.w = max(0.00100000005, r4.w);
      r8.zw = r8.zw / r4.ww;
      r8.xyzw = float4(0.5,0.5,0.5,0.5) + r8.xyzw;
      r8.xy = r5.ww ? r8.xy : r8.zw;
      r8.xy = r8.xy * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r9.y = asint(cb12[134].x);
      r9.z = (int)r7.w;
      r9.xw = float2(0,0);
      r8.xy = r9.zw + r8.xy;
      r8.xy = r9.xy + r8.xy;
      r8.xy = float2(0.5,0.142857149) * r8.xy;
      r8.xyz = t23.SampleLevel(s11_s, r8.xy, 5).xyz;
      r7.xyz = r4.zzz * r8.xyz + r7.xyz;
    }
  }
  r4.z = cmp(r0.w < 0.999000013);
  r3.w = r3.w ? r4.z : 0;
  if (r3.w != 0) {
    r8.xyz = cb12[138].xyz * r1.yyy;
    r8.xyz = cb12[137].xyz * r1.xxx + r8.xyz;
    r8.xyz = cb12[139].xyz * r1.zzz + r8.xyz;
    r8.xyz = cb12[140].xyz + r8.xyz;
    r8.xyz = float3(1,1,1) + -abs(r8.xyz);
    r4.zw = asint(cb12[141].yy) & int2(1,2);
    r4.z = r4.z ? 1 : r6.z;
    r4.w = r4.w ? 1 : r2.z;
    r4.z = r4.z * r4.w;
    r9.xyz = cmp(float3(0,0,0) < r8.xyz);
    r4.w = r9.y ? r9.x : 0;
    r4.w = r9.z ? r4.w : 0;
    r5.w = cmp(0 < r4.z);
    r4.w = r5.w ? r4.w : 0;
    if (r4.w != 0) {
      r8.xyz = saturate(cb12[136].xyz * r8.xyz);
      r4.w = 1 + -r0.w;
      r4.z = r4.w * r4.z;
      r4.z = cb12[135].x * r4.z;
      r4.w = r8.x * r8.y;
      r4.w = r4.w * r8.z;
      r5.w = r4.z * r4.w;
      r0.w = r4.z * r4.w + r0.w;
      r4.z = cb12[141].x * r5.w;
      r4.w = asint(cb12[146].x);
      r8.y = r4.w * 0.142857149 + r4.y;
      r8.x = r4.x;
      r8.xyz = t22.SampleLevel(s11_s, r8.xy, 1).xyz;
      r5.xyz = r4.zzz * r8.xyz + r5.xyz;
      r4.w = dot(r3.xyz, r3.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r4.www * r3.xyz;
      r5.w = cmp(r8.z < 0);
      r7.w = r5.w ? 1.f : 0.f;
      r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
      r9.x = -r3.z * r4.w + 1;
      r9.x = max(0.00100000005, r9.x);
      r8.xy = r8.xy / r9.xx;
      r4.w = r3.z * r4.w + 1;
      r4.w = max(0.00100000005, r4.w);
      r8.zw = r8.zw / r4.ww;
      r8.xyzw = float4(0.5,0.5,0.5,0.5) + r8.xyzw;
      r8.xy = r5.ww ? r8.xy : r8.zw;
      r8.xy = r8.xy * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r9.y = asint(cb12[146].x);
      r9.z = (int)r7.w;
      r9.xw = float2(0,0);
      r8.xy = r9.zw + r8.xy;
      r8.xy = r9.xy + r8.xy;
      r8.xy = float2(0.5,0.142857149) * r8.xy;
      r8.xyz = t23.SampleLevel(s11_s, r8.xy, 5).xyz;
      r7.xyz = r4.zzz * r8.xyz + r7.xyz;
    }
  }
  r4.z = cmp(r0.w < 0.999000013);
  r3.w = r3.w ? r4.z : 0;
  if (r3.w != 0) {
    r8.xyz = cb12[150].xyz * r1.yyy;
    r8.xyz = cb12[149].xyz * r1.xxx + r8.xyz;
    r8.xyz = cb12[151].xyz * r1.zzz + r8.xyz;
    r8.xyz = cb12[152].xyz + r8.xyz;
    r8.xyz = float3(1,1,1) + -abs(r8.xyz);
    r4.zw = asint(cb12[153].yy) & int2(1,2);
    r4.z = r4.z ? 1 : r6.z;
    r4.w = r4.w ? 1 : r2.z;
    r4.z = r4.z * r4.w;
    r9.xyz = cmp(float3(0,0,0) < r8.xyz);
    r4.w = r9.y ? r9.x : 0;
    r4.w = r9.z ? r4.w : 0;
    r5.w = cmp(0 < r4.z);
    r4.w = r5.w ? r4.w : 0;
    if (r4.w != 0) {
      r8.xyz = saturate(cb12[148].xyz * r8.xyz);
      r4.w = 1 + -r0.w;
      r4.z = r4.w * r4.z;
      r4.z = cb12[147].x * r4.z;
      r4.w = r8.x * r8.y;
      r4.w = r4.w * r8.z;
      r5.w = r4.z * r4.w;
      r0.w = r4.z * r4.w + r0.w;
      r4.z = cb12[153].x * r5.w;
      r4.w = asint(cb12[158].x);
      r8.y = r4.w * 0.142857149 + r4.y;
      r8.x = r4.x;
      r8.xyz = t22.SampleLevel(s11_s, r8.xy, 1).xyz;
      r5.xyz = r4.zzz * r8.xyz + r5.xyz;
      r4.w = dot(r3.xyz, r3.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r4.www * r3.xyz;
      r5.w = cmp(r8.z < 0);
      r7.w = r5.w ? 1.f : 0.f;
      r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
      r9.x = -r3.z * r4.w + 1;
      r9.x = max(0.00100000005, r9.x);
      r8.xy = r8.xy / r9.xx;
      r4.w = r3.z * r4.w + 1;
      r4.w = max(0.00100000005, r4.w);
      r8.zw = r8.zw / r4.ww;
      r8.xyzw = float4(0.5,0.5,0.5,0.5) + r8.xyzw;
      r8.xy = r5.ww ? r8.xy : r8.zw;
      r8.xy = r8.xy * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r9.y = asint(cb12[158].x);
      r9.z = (int)r7.w;
      r9.xw = float2(0,0);
      r8.xy = r9.zw + r8.xy;
      r8.xy = r9.xy + r8.xy;
      r8.xy = float2(0.5,0.142857149) * r8.xy;
      r8.xyz = t23.SampleLevel(s11_s, r8.xy, 5).xyz;
      r7.xyz = r4.zzz * r8.xyz + r7.xyz;
    }
  }
  r4.z = cmp(r0.w < 0.999000013);
  r3.w = r3.w ? r4.z : 0;
  if (r3.w != 0) {
    r8.xyz = cb12[162].xyz * r1.yyy;
    r8.xyz = cb12[161].xyz * r1.xxx + r8.xyz;
    r8.xyz = cb12[163].xyz * r1.zzz + r8.xyz;
    r8.xyz = cb12[164].xyz + r8.xyz;
    r8.xyz = float3(1,1,1) + -abs(r8.xyz);
    r4.zw = asint(cb12[165].yy) & int2(1,2);
    r4.z = r4.z ? 1 : r6.z;
    r4.w = r4.w ? 1 : r2.z;
    r4.z = r4.z * r4.w;
    r9.xyz = cmp(float3(0,0,0) < r8.xyz);
    r4.w = r9.y ? r9.x : 0;
    r4.w = r9.z ? r4.w : 0;
    r5.w = cmp(0 < r4.z);
    r4.w = r5.w ? r4.w : 0;
    if (r4.w != 0) {
      r8.xyz = saturate(cb12[160].xyz * r8.xyz);
      r4.w = 1 + -r0.w;
      r4.z = r4.w * r4.z;
      r4.z = cb12[159].x * r4.z;
      r4.w = r8.x * r8.y;
      r4.w = r4.w * r8.z;
      r5.w = r4.z * r4.w;
      r0.w = r4.z * r4.w + r0.w;
      r4.z = cb12[165].x * r5.w;
      r4.w = asint(cb12[170].x);
      r8.y = r4.w * 0.142857149 + r4.y;
      r8.x = r4.x;
      r8.xyz = t22.SampleLevel(s11_s, r8.xy, 1).xyz;
      r5.xyz = r4.zzz * r8.xyz + r5.xyz;
      r4.w = dot(r3.xyz, r3.xyz);
      r4.w = rsqrt(r4.w);
      r8.xyz = r4.www * r3.xyz;
      r5.w = cmp(r8.z < 0);
      r7.w = r5.w ? 1.f : 0.f;
      r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
      r9.x = -r3.z * r4.w + 1;
      r9.x = max(0.00100000005, r9.x);
      r8.xy = r8.xy / r9.xx;
      r4.w = r3.z * r4.w + 1;
      r4.w = max(0.00100000005, r4.w);
      r8.zw = r8.zw / r4.ww;
      r8.xyzw = float4(0.5,0.5,0.5,0.5) + r8.xyzw;
      r8.xy = r5.ww ? r8.xy : r8.zw;
      r8.xy = r8.xy * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r9.y = asint(cb12[170].x);
      r9.z = (int)r7.w;
      r9.xw = float2(0,0);
      r8.xy = r9.zw + r8.xy;
      r8.xy = r9.xy + r8.xy;
      r8.xy = float2(0.5,0.142857149) * r8.xy;
      r8.xyz = t23.SampleLevel(s11_s, r8.xy, 5).xyz;
      r7.xyz = r4.zzz * r8.xyz + r7.xyz;
    }
  }
  r4.z = cmp(r0.w < 0.999000013);
  r3.w = r3.w ? r4.z : 0;
  if (r3.w != 0) {
    r8.xyz = cb12[174].xyz * r1.yyy;
    r8.xyz = cb12[173].xyz * r1.xxx + r8.xyz;
    r8.xyz = cb12[175].xyz * r1.zzz + r8.xyz;
    r8.xyz = cb12[176].xyz + r8.xyz;
    r8.xyz = float3(1,1,1) + -abs(r8.xyz);
    r4.zw = asint(cb12[177].yy) & int2(1,2);
    r3.w = r4.z ? 1 : r6.z;
    r2.z = r4.w ? 1 : r2.z;
    r2.z = r3.w * r2.z;
    r9.xyz = cmp(float3(0,0,0) < r8.xyz);
    r3.w = r9.y ? r9.x : 0;
    r3.w = r9.z ? r3.w : 0;
    r4.z = cmp(0 < r2.z);
    r3.w = r4.z ? r3.w : 0;
    if (r3.w != 0) {
      r8.xyz = saturate(cb12[172].xyz * r8.xyz);
      r3.w = 1 + -r0.w;
      r2.z = r3.w * r2.z;
      r2.z = cb12[171].x * r2.z;
      r3.w = r8.x * r8.y;
      r3.w = r3.w * r8.z;
      r4.z = r3.w * r2.z;
      r0.w = r2.z * r3.w + r0.w;
      r2.z = cb12[177].x * r4.z;
      r3.w = asint(cb12[182].x);
      r8.y = r3.w * 0.142857149 + r4.y;
      r8.x = r4.x;
      r8.xyz = t22.SampleLevel(s11_s, r8.xy, 1).xyz;
      r5.xyz = r2.zzz * r8.xyz + r5.xyz;
      r3.w = dot(r3.xyz, r3.xyz);
      r3.w = rsqrt(r3.w);
      r8.xyz = r3.xyz * r3.www;
      r4.z = cmp(r8.z < 0);
      r4.w = r4.z ? 1.f : 0.f;
      r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
      r5.w = -r3.z * r3.w + 1;
      r5.w = max(0.00100000005, r5.w);
      r8.xy = r8.xy / r5.ww;
      r3.w = r3.z * r3.w + 1;
      r3.w = max(0.00100000005, r3.w);
      r8.zw = r8.zw / r3.ww;
      r8.xyzw = float4(0.5,0.5,0.5,0.5) + r8.xyzw;
      r8.xy = r4.zz ? r8.xy : r8.zw;
      r8.xy = r8.xy * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r9.y = asint(cb12[182].x);
      r9.z = (int)r4.w;
      r9.xw = float2(0,0);
      r4.zw = r9.zw + r8.xy;
      r4.zw = r9.xy + r4.zw;
      r4.zw = float2(0.5,0.142857149) * r4.zw;
      r8.xyz = t23.SampleLevel(s11_s, r4.zw, 5).xyz;
      r7.xyz = r2.zzz * r8.xyz + r7.xyz;
    }
  }
  r2.z = cmp(r0.w < 1);
  if (r2.z != 0) {
    r2.z = 1 + -r0.w;
    r3.w = cb12[99].x * r2.z;
    r0.w = r2.z * cb12[99].x + r0.w;
    r2.z = cb12[105].x * r3.w;
    r3.w = asint(cb12[110].x);
    r4.y = r3.w * 0.142857149 + r4.y;
    r4.xyz = t22.SampleLevel(s11_s, r4.xy, 1).xyz;
    r5.xyz = r2.zzz * r4.xyz + r5.xyz;
    r3.w = cmp(r3.z < 0);
    r4.x = r3.w ? 1.f : 0.f;
    r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r3.xyxy;
    r3.x = 1 + -r3.z;
    r3.x = max(0.00100000005, r3.x);
    r3.xy = r8.xy / r3.xx;
    r3.xy = float2(0.5,0.5) + r3.xy;
    r3.z = 1 + r3.z;
    r3.z = max(0.00100000005, r3.z);
    r4.yz = r8.zw / r3.zz;
    r4.yz = float2(0.5,0.5) + r4.yz;
    r3.xy = r3.ww ? r3.xy : r4.yz;
    r3.xy = r3.xy * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
    r8.y = asint(cb12[110].x);
    r8.z = (int)r4.x;
    r8.xw = float2(0,0);
    r3.xy = r8.zw + r3.xy;
    r3.xy = r8.xy + r3.xy;
    r3.xy = float2(0.5,0.142857149) * r3.xy;
    r3.xyz = t23.SampleLevel(s11_s, r3.xy, 5).xyz;
    r7.xyz = r2.zzz * r3.xyz + r7.xyz;
  }
  r0.w = 1 / r0.w;
  r3.xyz = r5.xyz * r0.www;
  r4.xyz = r7.xyz * r0.www;
  o1.xyz = r3.xyz * r1.www;
  o2.xyz = r4.xyz * r1.www;
  r6.w = 1;
  o3.xyzw = r6.xyzw * r1.wwww;
  o0.xyzw = cb2[6].xyzw;
  o1.w = v3.x;
  o4.xyzw = float4(1,1,1,1);
  o5.w = r0.x;
  o6.w = r0.y;
  o6.xyz = r2.xyw;
  o7.w = r0.z;
  o7.xyz = r1.xyz;
  previous_clip = PreviousDeformedClip(vertex, motion_history);
  return;
}