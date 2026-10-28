// ---- Created with 3Dmigoto v1.3.16 on Tue Oct 27 23:08:19 2026
Texture2DArray<float4> t19 : register(t19);

Texture2DArray<float4> t15 : register(t15);

Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float4> t8 : register(t8);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t0 : register(t0);

SamplerState s14_s : register(s14);

SamplerState s10_s : register(s10);

SamplerComparisonState s9_s : register(s9);

cbuffer cb13 : register(b13)
{
  float4 cb13[49];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[214];
}




// 3Dmigoto declarations
#include "shadows.hlsli"
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = (uint2)v0.xy;
  r0.zw = float2(0,0);
  r1.x = t0.Load(r0.xyw).x;
  r1.y = r1.x * cb12[22].x + cb12[22].y;
  r1.y = cmp(r1.y < 1);
  if (r1.y != 0) {
    r0.z = t2.Load(r0.xyz).w;
    r1.yz = (uint2)r0.xy;
    r2.xyzw = cb12[211].xyzw * r1.zzzz;
    r2.xyzw = cb12[210].xyzw * r1.yyyy + r2.xyzw;
    r1.xyzw = cb12[212].xyzw * r1.xxxx + r2.xyzw;
    r1.xyzw = cb12[213].xyzw + r1.xyzw;
    r1.xyz = r1.xyz / r1.www;
    r0.z = r0.z * 255 + 0.5;
    r0.z = (uint)r0.z;
    r0.z = (int)r0.z & 26;
    r0.w = cmp(0 < asint(cb13[35].x));
    if (r0.w != 0) {
      r0.w = cmp(0 < asint(cb13[35].y));
      if (r0.w != 0) {
        r2.y = 0;
        r3.xyz = float3(0,0,0);
        r0.w = 0;
        while (true) {
          r1.w = cmp((int)r3.z >= asint(cb13[35].y));
          r0.w = 0;
          if (r1.w != 0) break;
          r2.zw = -cb13[r3.z+39].xy + r1.xy;
          r2.zw = cb13[r3.z+39].zw * r2.zw;
          r4.xy = cmp(r2.zw >= float2(0,0));
          r1.w = r4.y ? r4.x : 0;
          r4.xy = cmp(float2(1,1) >= r2.zw);
          r1.w = r1.w ? r4.x : 0;
          r1.w = r4.y ? r1.w : 0;
          if (r1.w != 0) {
            r4.xy = cb13[r3.z+44].zw + -cb13[r3.z+44].xy;
            r2.zw = r2.zw * r4.xy + cb13[r3.z+44].xy;
            r4.xyzw = float4(0.00048828125,-0.00048828125,0.00244140625,-0.00048828125) + r2.zwzw;
            r5.z = (int)r3.z;
            r5.xy = r4.xy;
            r3.w = t15.SampleLevel(s10_s, r5.xyz, 0).x;
            r3.x = cb13[38].x * r3.w + cb13[38].y;
            r5.xy = r4.zw;
            r3.w = t15.SampleLevel(s10_s, r5.xyz, 0).x;
            r3.w = cb13[38].x * r3.w + cb13[38].y;
            r4.xyzw = float4(0.00048828125,0.00146484375,-0.00146484375,-0.00048828125) + r2.zwzw;
            r5.xy = r4.xy;
            r4.x = t15.SampleLevel(s10_s, r5.xyz, 0).x;
            r4.x = cb13[38].x * r4.x + cb13[38].y;
            r5.xy = r4.zw;
            r4.y = t15.SampleLevel(s10_s, r5.xyz, 0).x;
            r4.y = cb13[38].x * r4.y + cb13[38].y;
            r5.xy = float2(0.00048828125,-0.00244140625) + r2.zw;
            r2.z = t15.SampleLevel(s10_s, r5.xyz, 0).x;
            r2.z = cb13[38].x * r2.z + cb13[38].y;
            r2.w = r3.w + -r3.x;
            r3.w = r4.y + -r3.x;
            r2.w = max(abs(r3.w), abs(r2.w));
            r3.w = r4.x + -r3.x;
            r2.z = r2.z + -r3.x;
            r2.z = max(abs(r3.w), abs(r2.z));
            r3.y = max(r2.w, r2.z);
            r0.w = -1;
            break;
          }
          r2.x = (int)r3.z + 1;
          r3.xyz = r2.yyx;
          r0.w = r1.w;
        }
      } else {
        r0.w = 0;
      }
      r2.xy = r0.ww ? r3.xy : float2(-10000,0);
      r2.zw = -cb12[0].xy + r1.xy;
      r0.w = dot(r2.zw, r2.zw);
      r0.w = sqrt(r0.w);
      r3.xyz = -cb12[0].xyz + r1.xyz;
      r1.w = dot(r3.xyz, r3.xyz);
      r1.w = sqrt(r1.w);
      r2.z = cmp(r0.w < cb13[36].y);
      if (r2.z != 0) {
        r2.y = max(0.100000001, r2.y);
        r2.y = 1 / r2.y;
        r2.z = cb13[37].z * r0.w;
        r2.z = max(1, r2.z);
        r2.z = cb13[36].x / r2.z;
        r2.y = min(r2.y, r2.z);
        r1.w = r1.w * 0.0199999996 + 0.0500000007;
        r0.w = cb13[36].z + r0.w;
        r0.w = saturate(cb13[36].w * r0.w);
        r3.y = r1.z;
        r3.xz = float2(0,0);
        r2.z = 0;
        while (true) {
          r2.w = cmp((int)r3.z >= asint(cb13[35].x));
          r2.z = 0;
          if (r2.w != 0) break;
          r4.xy = -cb13[r3.z+39].xy + r1.xy;
          r5.xy = cb13[r3.z+39].zw * r4.xy;
          r4.xz = cmp(r5.xy >= float2(0,0));
          r2.w = r4.z ? r4.x : 0;
          r4.xz = cmp(float2(1,1) >= r5.xy);
          r2.w = r2.w ? r4.x : 0;
          r2.w = r4.z ? r2.w : 0;
          if (r2.w != 0) {
            r5.z = (int)r3.z;
            r5.w = -r4.y * cb13[r3.z+39].w + 1;
            r3.w = t19.SampleLevel(s10_s, r5.xwz, 0).x;
            r3.w = cb13[38].x * r3.w + cb13[38].y;
            r4.x = -r3.y + r2.x;
            r4.x = cmp(abs(r4.x) < r1.w);
            r4.x = r4.x ? r2.x : r3.y;
            r3.w = -0.100000001 + r3.w;
            r3.w = r3.w + -r4.x;
            r3.w = saturate(r3.w * r2.y);
            r3.w = 1 + -r3.w;
            r4.x = 1 + -r3.w;
            r3.w = r0.w * r4.x + r3.w;
            r2.z = -1;
            r3.x = r3.w;
            break;
          }
          r3.z = (int)r3.z + 1;
          r2.z = r2.w;
        }
      } else {
        r2.z = 0;
      }
    } else {
      r2.z = 0;
    }
    r0.w = r2.z ? r3.x : 1;
    r1.w = cmp(0 < r0.w);
    if (r1.w != 0) {
      if (CUSTOM_SHADOWS) {
        r2.w = DirectionalVisibility(r1.xyz,24,true,r0.z != 0.f);
      } else {
      r2.xyz = cb13[5].xyz * r1.yyy;
      r2.xyz = cb13[4].xyz * r1.xxx + r2.xyz;
      r2.xyz = cb13[6].xyz * r1.zzz + r2.xyz;
      r2.xyz = cb13[7].xyz + r2.xyz;
      r1.w = cmp(abs(r2.z) >= 0.999000013);
      if (r1.w != 0) {
        r2.w = 1;
      }
      if (r1.w == 0) {
        r3.xyzw = -cb13[8].xyzw + r2.xxxx;
        r4.xyzw = -cb13[9].xyzw + r2.yyyy;
        r3.xyzw = max(abs(r4.xyzw), abs(r3.xyzw));
        r4.xyzw = cmp(r3.xyzw < cb13[10].xyzw);
        r4.xyzw = r4.xyzw ? float4(1,1,1,1) : 0;
        r5.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb13[15].zzzz);
        r5.xyzw = r5.xyzw ? float4(1,1,1,1) : 0;
        r1.w = dot(r4.xyzw, r5.xyzw);
        r4.x = cmp(r1.w < 0.5);
        if (r4.x != 0) {
          r2.w = 1;
        }
        if (r4.x == 0) {
          r3.xyzw = r3.xyzw / cb13[10].xyzw;
          r5.xyzw = float4(1,1,1,1) + -cb13[17].xyzw;
          r3.xyzw = -r5.xyzw + r3.xyzw;
          r3.xyzw = saturate(r3.xyzw / cb13[17].xyzw);
          r1.w = cb13[15].z + -r1.w;
          r1.w = (int)r1.w;
          r4.y = (int)cb13[15].z;
          r4.y = (int)r4.y + -1;
          r4.zw = (int2)r0.xy & int2(1,1);
          r5.xy = r4.ww ? float2(1,3) : float2(2,0);
          r4.z = r4.z ? r5.x : r5.y;
          if (1 == 0) r5.x = 0; else if (1+1 < 32) {           r5.x = (uint)r0.x << (32-(1 + 1)); r5.x = (uint)r5.x >> (32-1);          } else r5.x = (uint)r0.x >> 1;
          if (1 == 0) r5.y = 0; else if (1+1 < 32) {           r5.y = (uint)r0.y << (32-(1 + 1)); r5.y = (uint)r5.y >> (32-1);          } else r5.y = (uint)r0.y >> 1;
          if (1 == 0) r5.z = 0; else if (1+2 < 32) {           r5.z = (uint)r0.x << (32-(1 + 2)); r5.z = (uint)r5.z >> (32-1);          } else r5.z = (uint)r0.x >> 2;
          if (1 == 0) r5.w = 0; else if (1+2 < 32) {           r5.w = (uint)r0.y << (32-(1 + 2)); r5.w = (uint)r5.w >> (32-1);          } else r5.w = (uint)r0.y >> 2;
          r6.xyzw = r5.yyww ? float4(1,3,1,3) : float4(2,0,2,0);
          r5.xy = r5.xz ? r6.xz : r6.yw;
          r4.z = (uint)r4.z << 6;
          r4.z = mad((int)r5.x, 16, (int)r4.z);
          r4.z = mad((int)r5.y, 4, (int)r4.z);
          if (1 == 0) r0.x = 0; else if (1+3 < 32) {           r0.x = (uint)r0.x << (32-(1 + 3)); r0.x = (uint)r0.x >> (32-1);          } else r0.x = (uint)r0.x >> 3;
          if (1 == 0) r0.y = 0; else if (1+3 < 32) {           r0.y = (uint)r0.y << (32-(1 + 3)); r0.y = (uint)r0.y >> (32-1);          } else r0.y = (uint)r0.y >> 3;
          r5.xy = r0.yy ? float2(1,3) : float2(2,0);
          r0.x = r0.x ? r5.x : r5.y;
          r0.x = (int)r4.z + (int)r0.x;
          r0.x = (int)r0.x;
          r0.x = 0.5 + r0.x;
          r0.x = 0.00390625 * r0.x;
          r0.y = dot(r3.xyzw, icb[r1.w+0].xyzw);
          r0.x = cmp(r0.x < r0.y);
          r0.x = r0.x ? 1 : 0;
          r0.x = (int)r0.x + (int)r1.w;
          r0.x = min((int)r0.x, (int)r4.y);
          r4.zw = cb13[r0.x+11].zz * float2(1,-1);
          r5.xy = r2.xy * r4.zw + cb13[r0.x+11].xy;
          r2.xy = r0.zz ? cb13[r0.x+19].xx : cb13[r0.x+11].ww;
          r0.y = r0.z ? cb13[r0.x+19].y : 0;
          r5.z = (int)r0.x;
          r0.x = cmp(asint(cb13[18].x) >= 1);
          if (r0.x != 0) {
            r0.x = t8.SampleCmpLevelZero(s9_s, r5.xyz, r2.z).x;
            r0.z = -r0.y * 0.0370370373 + r2.z;
            r6.xy = r2.yy * float2(-0.263353914,0.0396538191) + r5.xy;
            r6.z = r5.z;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.0740740746 + r2.z;
            r6.xy = r2.yy * float2(-0.717202425,0.368303299) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.111111112 + r2.z;
            r6.xy = r2.yy * float2(-0.0199530609,-0.398839206) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.148148149 + r2.z;
            r6.xy = r2.yy * float2(-0.440993786,-0.22101) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.185185179 + r2.z;
            r6.xy = r2.yy * float2(0.220039204,0.294344813) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.222222224 + r2.z;
            r6.xy = r2.yy * float2(-0.767565727,-0.148275301) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.259259254 + r2.z;
            r6.xy = r2.yy * float2(-0.2381019,0.547106206) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.296296299 + r2.z;
            r6.xy = r2.yy * float2(0.217303097,-0.134587899) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.333333343 + r2.z;
            r6.xy = r2.yy * float2(-0.638777375,0.756133914) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.370370358 + r2.z;
            r6.xy = r2.yy * float2(-0.1614144,0.977652073) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.407407403 + r2.z;
            r6.xy = r2.yy * float2(0.215631902,0.612341285) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.444444448 + r2.z;
            r6.xy = r2.yy * float2(0.232887506,0.945287228) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.481481493 + r2.z;
            r6.xy = r2.yy * float2(-0.944064379,0.123607703) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.518518507 + r2.z;
            r6.xy = r2.yy * float2(-0.740823686,-0.507682979) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.555555582 + r2.z;
            r6.xy = r2.yy * float2(-0.411301911,-0.890596688) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.592592597 + r2.z;
            r6.xy = r2.yy * float2(-0.248642907,-0.621399283) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.629629612 + r2.z;
            r6.xy = r2.yy * float2(0.696784973,0.264493704) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.666666687 + r2.z;
            r6.xy = r2.yy * float2(0.539436281,0.817321479) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.703703701 + r2.z;
            r6.xy = r2.yy * float2(0.615120828,-0.149864003) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.740740716 + r2.z;
            r6.xy = r2.yy * float2(0.0936533585,-0.78174752) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.777777791 + r2.z;
            r6.xy = r2.yy * float2(0.276806712,-0.489596814) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.814814806 + r2.z;
            r6.xy = r2.yy * float2(0.663918078,-0.600717187) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.851851881 + r2.z;
            r6.xy = r2.yy * float2(0.388036907,-0.895089388) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.888888896 + r2.z;
            r6.xy = r2.yy * float2(0.991614401,-0.0793915167) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.92592591 + r2.z;
            r6.xy = r2.yy * float2(0.783184826,0.602934778) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.z = -r0.y * 0.962962985 + r2.z;
            r6.xy = r2.yy * float2(0.899860322,-0.398354292) + r5.xy;
            r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.z).x;
            r0.x = r0.x + r0.z;
            r0.x = 0.0370370373 * r0.x;
            r0.x = r0.x * r0.x;
          } else {
            r0.z = t8.SampleCmpLevelZero(s9_s, r5.xyz, r2.z).x;
            r1.w = -r0.y * 0.0769230798 + r2.z;
            r6.xy = r2.yy * float2(-0.507720828,-0.617089927) + r5.xy;
            r6.z = r5.z;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r1.w = -r0.y * 0.15384616 + r2.z;
            r6.xy = r2.yy * float2(-0.0515490212,-0.750809789) + r5.xy;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r1.w = -r0.y * 0.230769232 + r2.z;
            r6.xy = r2.yy * float2(-0.764104187,0.200915202) + r5.xy;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r1.w = -r0.y * 0.307692319 + r2.z;
            r6.xy = r2.yy * float2(0.00728477398,-0.205946997) + r5.xy;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r1.w = -r0.y * 0.384615391 + r2.z;
            r6.xy = r2.yy * float2(-0.366203994,0.732379675) + r5.xy;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r1.w = -r0.y * 0.461538464 + r2.z;
            r6.xy = r2.yy * float2(-0.923958182,-0.255964309) + r5.xy;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r1.w = -r0.y * 0.538461566 + r2.z;
            r6.xy = r2.yy * float2(-0.286924005,0.278052986) + r5.xy;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r1.w = -r0.y * 0.615384638 + r2.z;
            r6.xy = r2.yy * float2(0.772301197,0.157332897) + r5.xy;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r1.w = -r0.y * 0.692307711 + r2.z;
            r6.xy = r2.yy * float2(0.378513008,0.405219913) + r5.xy;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r1.w = -r0.y * 0.769230783 + r2.z;
            r6.xy = r2.yy * float2(0.463021696,-0.691461921) + r5.xy;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r1.w = -r0.y * 0.846153855 + r2.z;
            r6.xy = r2.yy * float2(0.423523009,0.86302799) + r5.xy;
            r1.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
            r0.z = r1.w + r0.z;
            r0.y = -r0.y * 0.923076928 + r2.z;
            r6.xy = r2.xy * float2(0.855864286,-0.338255405) + r5.xy;
            r0.y = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.y).x;
            r0.y = r0.z + r0.y;
            r0.y = 0.0769230798 * r0.y;
            r0.x = r0.y * r0.y;
          }
          r0.y = (int)r4.y;
          r0.y = cmp(r5.z >= r0.y);
          r0.y = r0.y ? 1.000000 : 0;
          r0.z = dot(r3.xyzw, icb[r4.y+0].xyzw);
          r0.x = r0.y * r0.z + r0.x;
          r0.x = min(1, r0.x);
        } else {
          r0.x = 1;
        }
        r2.w = r4.x ? r2.w : r0.x;
      }
      }
      if (CONTACT_LENGTH > 0.f) r2.w = min(r2.w,FilteredContactVisibility(floor(v0.xy)));
      r0.x = r2.w * r0.w;
      r0.y = 20 * cb12[66].x;
      r2.zw = trunc(cb12[68].xy);
      r3.xyz = -cb12[0].xyz + r1.xyz;
      r0.z = dot(r3.xyz, r3.xyz);
      r0.z = sqrt(r0.z);
      r3.xy = cb12[67].xy;
      r3.z = 0;
      r3.xyz = r3.xyz + r1.xyz;
      r3.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r3.xyz;
      r3.xyz = r3.xyz / cb12[66].xxx;
      r4.xy = float2(20,20) * cb12[67].xy;
      r4.z = 0;
      r1.xyz = r4.xyz + r1.xyz;
      r1.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r1.xyz;
      r1.xyz = r1.xyz / r0.yyy;
      r3.zw = cb13[0].xy * r3.zz;
      r3.zw = r3.zw / cb13[0].zz;
      r2.xy = r3.xy + -r3.zw;
      r1.zw = cb13[0].xy * r1.zz;
      r1.zw = r1.zw / cb13[0].zz;
      r1.xy = r1.xy + -r1.zw;
      r0.y = t14.SampleLevel(s14_s, r2.xyz, 1).x;
      r2.x = t14.SampleLevel(s14_s, r2.xyw, 1).x;
      r2.x = r2.x + -r0.y;
      r0.y = cb12[66].w * r2.x + r0.y;
      r1.zw = r2.zw;
      r1.z = t14.SampleLevel(s14_s, r1.xyz, 1).x;
      r1.x = t14.SampleLevel(s14_s, r1.xyw, 1).x;
      r1.x = r1.x + -r1.z;
      r1.x = cb12[66].w * r1.x + r1.z;
      r1.y = -0.25 + cb13[0].z;
      r1.y = saturate(10 * r1.y);
      r0.z = -100 + r0.z;
      r0.z = saturate(0.00666666683 * r0.z);
      r1.x = r1.x + -r0.y;
      r0.y = r0.z * r1.x + r0.y;
      r0.y = -r1.y * r0.y + 1;
      r0.w = r0.x * r0.y;
    }
  } else {
    r0.w = 1;
  }
  o0.xyzw = r0.wwww;
  return;
}
