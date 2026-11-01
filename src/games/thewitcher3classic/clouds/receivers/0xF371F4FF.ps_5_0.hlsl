#include "../shadow_inputs.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 31 15:08:29 2026
Texture2DArray<float4> t19 : register(t19);

Texture2DArray<float4> t15 : register(t15);

Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float4> t8 : register(t8);

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
#define cmp -


void main(
  float4 v0 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = (uint2)v0.xy;
  r0.zw = float2(0,0);
  r1.x = t0.Load(r0.xyw).x;
  r1.y = r1.x * cb12[22].x + cb12[22].y;
  r1.y = cmp(r1.y < 1);
  if (r1.y != 0) {
    r0.z = t2.Load(r0.xyz).w;
    r0.xy = (uint2)r0.xy;
    r2.xyzw = cb12[211].xyzw * r0.yyyy;
    r2.xyzw = cb12[210].xyzw * r0.xxxx + r2.xyzw;
    r1.xyzw = cb12[212].xyzw * r1.xxxx + r2.xyzw;
    r1.xyzw = cb12[213].xyzw + r1.xyzw;
    r0.xyw = r1.xyz / r1.www;
    r0.z = r0.z * 255 + 0.5;
    r0.z = (uint)r0.z;
    r0.z = (int)r0.z & 26;
    r1.x = cmp(0 < asint(cb13[35].x));
    if (r1.x != 0) {
      r1.x = cmp(0 < asint(cb13[35].y));
      if (r1.x != 0) {
        r1.y = 0;
        r2.xyz = float3(0,0,0);
        r1.z = 0;
        while (true) {
          r1.w = cmp((int)r2.z >= asint(cb13[35].y));
          r1.z = 0;
          if (r1.w != 0) break;
          r3.xy = -cb13[r2.z+39].xy + r0.xy;
          r3.xy = cb13[r2.z+39].zw * r3.xy;
          r3.zw = cmp(r3.xy >= float2(0,0));
          r1.w = r3.w ? r3.z : 0;
          r3.zw = cmp(float2(1,1) >= r3.xy);
          r1.w = r1.w ? r3.z : 0;
          r1.w = r3.w ? r1.w : 0;
          if (r1.w != 0) {
            r3.zw = cb13[r2.z+44].zw + -cb13[r2.z+44].xy;
            r3.xy = r3.xy * r3.zw + cb13[r2.z+44].xy;
            r4.xyzw = float4(0.00048828125,-0.00048828125,0.00244140625,-0.00048828125) + r3.xyxy;
            r5.z = (int)r2.z;
            r5.xy = r4.xy;
            r2.w = t15.SampleLevel(s10_s, r5.xyz, 0).x;
            r2.x = cb13[38].x * r2.w + cb13[38].y;
            r5.xy = r4.zw;
            r2.w = t15.SampleLevel(s10_s, r5.xyz, 0).x;
            r2.w = cb13[38].x * r2.w + cb13[38].y;
            r4.xyzw = float4(0.00048828125,0.00146484375,-0.00146484375,-0.00048828125) + r3.xyxy;
            r5.xy = r4.xy;
            r3.z = t15.SampleLevel(s10_s, r5.xyz, 0).x;
            r3.z = cb13[38].x * r3.z + cb13[38].y;
            r5.xy = r4.zw;
            r3.w = t15.SampleLevel(s10_s, r5.xyz, 0).x;
            r3.w = cb13[38].x * r3.w + cb13[38].y;
            r5.xy = float2(0.00048828125,-0.00244140625) + r3.xy;
            r3.x = t15.SampleLevel(s10_s, r5.xyz, 0).x;
            r3.x = cb13[38].x * r3.x + cb13[38].y;
            r2.w = r2.w + -r2.x;
            r3.y = r3.w + -r2.x;
            r2.w = max(abs(r3.y), abs(r2.w));
            r3.xy = r3.xz + -r2.xx;
            r3.x = max(abs(r3.y), abs(r3.x));
            r2.y = max(r3.x, r2.w);
            r1.z = -1;
            break;
          }
          r1.x = (int)r2.z + 1;
          r2.xyz = r1.yyx;
          r1.z = r1.w;
        }
      } else {
        r1.z = 0;
      }
      r1.xy = r1.zz ? r2.xy : float2(-10000,0);
      r1.zw = -cb12[0].xy + r0.xy;
      r1.z = dot(r1.zw, r1.zw);
      r2.xyz = -cb12[0].xyz + r0.xyw;
      r1.w = dot(r2.xyz, r2.xyz);
      r1.zw = sqrt(r1.zw);
      r2.x = cmp(r1.z < cb13[36].y);
      if (r2.x != 0) {
        r1.y = max(0.100000001, r1.y);
        r1.y = 1 / r1.y;
        r2.x = cb13[37].z * r1.z;
        r2.x = max(1, r2.x);
        r2.x = cb13[36].x / r2.x;
        r1.y = min(r2.x, r1.y);
        r1.w = r1.w * 0.0199999996 + 0.0500000007;
        r1.z = cb13[36].z + r1.z;
        r1.z = saturate(cb13[36].w * r1.z);
        r2.y = r0.w;
        r2.xzw = float3(0,0,0);
        while (true) {
          r3.x = cmp((int)r2.z >= asint(cb13[35].x));
          r2.w = 0;
          if (r3.x != 0) break;
          r3.xy = -cb13[r2.z+39].xy + r0.xy;
          r4.xy = cb13[r2.z+39].zw * r3.xy;
          r3.xz = cmp(r4.xy >= float2(0,0));
          r3.x = r3.z ? r3.x : 0;
          r3.zw = cmp(float2(1,1) >= r4.xy);
          r3.x = r3.z ? r3.x : 0;
          r3.x = r3.w ? r3.x : 0;
          if (r3.x != 0) {
            r4.z = (int)r2.z;
            r4.w = -r3.y * cb13[r2.z+39].w + 1;
            r3.y = t19.SampleLevel(s10_s, r4.xwz, 0).x;
            r3.y = cb13[38].x * r3.y + cb13[38].y;
            r3.z = -r2.y + r1.x;
            r3.z = cmp(abs(r3.z) < r1.w);
            r3.z = r3.z ? r1.x : r2.y;
            r3.y = -0.100000001 + r3.y;
            r3.y = r3.y + -r3.z;
            r3.y = saturate(r3.y * r1.y);
            r3.y = 1 + -r3.y;
            r3.z = 1 + -r3.y;
            r3.y = r1.z * r3.z + r3.y;
            r2.w = -1;
            r2.x = r3.y;
            break;
          }
          r2.z = (int)r2.z + 1;
          r2.w = r3.x;
        }
      } else {
        r2.w = 0;
      }
    } else {
      r2.w = 0;
    }
    r1.x = r2.w ? r2.x : 1;
    r1.y = cmp(0 < r1.x);
    if (r1.y != 0) {
      r1.yzw = cb13[5].xyz * r0.yyy;
      r1.yzw = cb13[4].xyz * r0.xxx + r1.yzw;
      r1.yzw = cb13[6].xyz * r0.www + r1.yzw;
      r1.yzw = cb13[7].xyz + r1.yzw;
      r2.x = cmp(abs(r1.w) >= 0.999000013);
      if (r2.x != 0) {
        r2.y = 1;
      }
      if (r2.x == 0) {
        r3.xyzw = -cb13[8].xyzw + r1.yyyy;
        r4.xyzw = -cb13[9].xyzw + r1.zzzz;
        r3.xyzw = max(abs(r4.xyzw), abs(r3.xyzw));
        r4.xyzw = cmp(r3.xyzw < cb13[10].xyzw);
        r4.xyzw = r4.xyzw ? float4(1,1,1,1) : 0;
        r5.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb13[15].zzzz);
        r5.xyzw = r5.xyzw ? float4(1,1,1,1) : 0;
        r2.x = dot(r4.xyzw, r5.xyzw);
        r2.z = cmp(r2.x < 0.5);
        if (r2.z != 0) {
          r2.y = 1;
        }
        if (r2.z == 0) {
          r3.xyzw = r3.xyzw / cb13[10].xyzw;
          r4.xyzw = float4(1,1,1,1) + -cb13[17].xyzw;
          r3.xyzw = -r4.xyzw + r3.xyzw;
          r3.xyzw = saturate(r3.xyzw / cb13[17].xyzw);
          r2.x = cb13[15].z + -r2.x;
          r2.w = (int)r2.x;
          r4.x = (int)cb13[15].z;
          r4.x = (int)r4.x + -1;
          r4.y = dot(r3.xyzw, icb[r2.w+0].xyzw);
          r4.z = cmp(0 < r4.y);
          if (r4.z != 0) {
            r4.zw = cb13[r2.w+11].zz * float2(1,-1);
            r5.xy = r1.yz * r4.zw + cb13[r2.w+11].xy;
            r6.xy = cb13[r2.w+11].ww;
            r6.z = 0;
            r6.xyz = r0.zzz ? cb13[r2.w+19].xxy : r6.xyz;
            r5.z = trunc(r2.x);
            r4.z = cmp(asint(cb13[18].x) >= 1);
            if (r4.z != 0) {
              r4.w = t8.SampleCmpLevelZero(s9_s, r5.xyz, r1.w).x;
              r5.w = -r6.z * 0.0370370373 + r1.w;
              r7.xy = r6.yy * float2(-0.263353914,0.0396538191) + r5.xy;
              r7.z = r5.z;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.0740740746 + r1.w;
              r7.xy = r6.yy * float2(-0.717202425,0.368303299) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.111111112 + r1.w;
              r7.xy = r6.yy * float2(-0.0199530609,-0.398839206) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.148148149 + r1.w;
              r7.xy = r6.yy * float2(-0.440993786,-0.22101) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.185185179 + r1.w;
              r7.xy = r6.yy * float2(0.220039204,0.294344813) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.222222224 + r1.w;
              r7.xy = r6.yy * float2(-0.767565727,-0.148275301) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.259259254 + r1.w;
              r7.xy = r6.yy * float2(-0.2381019,0.547106206) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.296296299 + r1.w;
              r7.xy = r6.yy * float2(0.217303097,-0.134587899) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.333333343 + r1.w;
              r7.xy = r6.yy * float2(-0.638777375,0.756133914) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.370370358 + r1.w;
              r7.xy = r6.yy * float2(-0.1614144,0.977652073) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.407407403 + r1.w;
              r7.xy = r6.yy * float2(0.215631902,0.612341285) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.444444448 + r1.w;
              r7.xy = r6.yy * float2(0.232887506,0.945287228) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.481481493 + r1.w;
              r7.xy = r6.yy * float2(-0.944064379,0.123607703) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.518518507 + r1.w;
              r7.xy = r6.yy * float2(-0.740823686,-0.507682979) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.555555582 + r1.w;
              r7.xy = r6.yy * float2(-0.411301911,-0.890596688) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.592592597 + r1.w;
              r7.xy = r6.yy * float2(-0.248642907,-0.621399283) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.629629612 + r1.w;
              r7.xy = r6.yy * float2(0.696784973,0.264493704) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.666666687 + r1.w;
              r7.xy = r6.yy * float2(0.539436281,0.817321479) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.703703701 + r1.w;
              r7.xy = r6.yy * float2(0.615120828,-0.149864003) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.740740716 + r1.w;
              r7.xy = r6.yy * float2(0.0936533585,-0.78174752) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.777777791 + r1.w;
              r7.xy = r6.yy * float2(0.276806712,-0.489596814) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.814814806 + r1.w;
              r7.xy = r6.yy * float2(0.663918078,-0.600717187) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.851851881 + r1.w;
              r7.xy = r6.yy * float2(0.388036907,-0.895089388) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.888888896 + r1.w;
              r7.xy = r6.yy * float2(0.991614401,-0.0793915167) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.92592591 + r1.w;
              r7.xy = r6.yy * float2(0.783184826,0.602934778) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r5.w = -r6.z * 0.962962985 + r1.w;
              r7.xy = r6.yy * float2(0.899860322,-0.398354292) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r4.w = r5.w + r4.w;
              r4.w = 0.0370370373 * r4.w;
              r4.w = r4.w * r4.w;
            } else {
              r5.w = t8.SampleCmpLevelZero(s9_s, r5.xyz, r1.w).x;
              r6.w = -r6.z * 0.0769230798 + r1.w;
              r7.xy = r6.yy * float2(-0.507720828,-0.617089927) + r5.xy;
              r7.z = r5.z;
              r5.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.w).x;
              r5.z = r5.w + r5.z;
              r5.w = -r6.z * 0.15384616 + r1.w;
              r7.xy = r6.yy * float2(-0.0515490212,-0.750809789) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.z = r5.z + r5.w;
              r5.w = -r6.z * 0.230769232 + r1.w;
              r7.xy = r6.yy * float2(-0.764104187,0.200915202) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.z = r5.z + r5.w;
              r5.w = -r6.z * 0.307692319 + r1.w;
              r7.xy = r6.yy * float2(0.00728477398,-0.205946997) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.z = r5.z + r5.w;
              r5.w = -r6.z * 0.384615391 + r1.w;
              r7.xy = r6.yy * float2(-0.366203994,0.732379675) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.z = r5.z + r5.w;
              r5.w = -r6.z * 0.461538464 + r1.w;
              r7.xy = r6.yy * float2(-0.923958182,-0.255964309) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.z = r5.z + r5.w;
              r5.w = -r6.z * 0.538461566 + r1.w;
              r7.xy = r6.yy * float2(-0.286924005,0.278052986) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.z = r5.z + r5.w;
              r5.w = -r6.z * 0.615384638 + r1.w;
              r7.xy = r6.yy * float2(0.772301197,0.157332897) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.z = r5.z + r5.w;
              r5.w = -r6.z * 0.692307711 + r1.w;
              r7.xy = r6.yy * float2(0.378513008,0.405219913) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.z = r5.z + r5.w;
              r5.w = -r6.z * 0.769230783 + r1.w;
              r7.xy = r6.yy * float2(0.463021696,-0.691461921) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.z = r5.z + r5.w;
              r5.w = -r6.z * 0.846153855 + r1.w;
              r7.xy = r6.yy * float2(0.423523009,0.86302799) + r5.xy;
              r5.w = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.z = r5.z + r5.w;
              r5.w = -r6.z * 0.923076928 + r1.w;
              r7.xy = r6.xy * float2(0.855864286,-0.338255405) + r5.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.x = r5.z + r5.x;
              r5.x = 0.0769230798 * r5.x;
              r4.w = r5.x * r5.x;
            }
            r5.x = (int)r2.w + 1;
            r5.yz = cb13[r5.x+11].zz * float2(1,-1);
            r6.xy = r1.yz * r5.yz + cb13[r5.x+11].xy;
            r5.yz = r0.zz ? cb13[r5.x+19].xx : cb13[r5.x+11].ww;
            r5.w = r0.z ? cb13[r5.x+19].y : 0;
            r6.z = (int)r5.x;
            if (r4.z != 0) {
              r4.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
              r5.x = -r5.w * 0.0370370373 + r1.w;
              r7.xy = r5.zz * float2(-0.263353914,0.0396538191) + r6.xy;
              r7.z = r6.z;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.0740740746 + r1.w;
              r7.xy = r5.zz * float2(-0.717202425,0.368303299) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.111111112 + r1.w;
              r7.xy = r5.zz * float2(-0.0199530609,-0.398839206) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.148148149 + r1.w;
              r7.xy = r5.zz * float2(-0.440993786,-0.22101) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.185185179 + r1.w;
              r7.xy = r5.zz * float2(0.220039204,0.294344813) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.222222224 + r1.w;
              r7.xy = r5.zz * float2(-0.767565727,-0.148275301) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.259259254 + r1.w;
              r7.xy = r5.zz * float2(-0.2381019,0.547106206) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.296296299 + r1.w;
              r7.xy = r5.zz * float2(0.217303097,-0.134587899) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.333333343 + r1.w;
              r7.xy = r5.zz * float2(-0.638777375,0.756133914) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.370370358 + r1.w;
              r7.xy = r5.zz * float2(-0.1614144,0.977652073) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.407407403 + r1.w;
              r7.xy = r5.zz * float2(0.215631902,0.612341285) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.444444448 + r1.w;
              r7.xy = r5.zz * float2(0.232887506,0.945287228) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.481481493 + r1.w;
              r7.xy = r5.zz * float2(-0.944064379,0.123607703) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.518518507 + r1.w;
              r7.xy = r5.zz * float2(-0.740823686,-0.507682979) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.555555582 + r1.w;
              r7.xy = r5.zz * float2(-0.411301911,-0.890596688) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.592592597 + r1.w;
              r7.xy = r5.zz * float2(-0.248642907,-0.621399283) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.629629612 + r1.w;
              r7.xy = r5.zz * float2(0.696784973,0.264493704) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.666666687 + r1.w;
              r7.xy = r5.zz * float2(0.539436281,0.817321479) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.703703701 + r1.w;
              r7.xy = r5.zz * float2(0.615120828,-0.149864003) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.740740716 + r1.w;
              r7.xy = r5.zz * float2(0.0936533585,-0.78174752) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.777777791 + r1.w;
              r7.xy = r5.zz * float2(0.276806712,-0.489596814) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.814814806 + r1.w;
              r7.xy = r5.zz * float2(0.663918078,-0.600717187) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.851851881 + r1.w;
              r7.xy = r5.zz * float2(0.388036907,-0.895089388) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.888888896 + r1.w;
              r7.xy = r5.zz * float2(0.991614401,-0.0793915167) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.92592591 + r1.w;
              r7.xy = r5.zz * float2(0.783184826,0.602934778) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r5.x = -r5.w * 0.962962985 + r1.w;
              r7.xy = r5.zz * float2(0.899860322,-0.398354292) + r6.xy;
              r5.x = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.x).x;
              r4.z = r5.x + r4.z;
              r4.z = 0.0370370373 * r4.z;
              r4.z = r4.z * r4.z;
            } else {
              r5.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r1.w).x;
              r6.w = -r5.w * 0.0769230798 + r1.w;
              r7.xy = r5.zz * float2(-0.507720828,-0.617089927) + r6.xy;
              r7.z = r6.z;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.w).x;
              r5.x = r6.z + r5.x;
              r6.z = -r5.w * 0.15384616 + r1.w;
              r7.xy = r5.zz * float2(-0.0515490212,-0.750809789) + r6.xy;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.z).x;
              r5.x = r6.z + r5.x;
              r6.z = -r5.w * 0.230769232 + r1.w;
              r7.xy = r5.zz * float2(-0.764104187,0.200915202) + r6.xy;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.z).x;
              r5.x = r6.z + r5.x;
              r6.z = -r5.w * 0.307692319 + r1.w;
              r7.xy = r5.zz * float2(0.00728477398,-0.205946997) + r6.xy;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.z).x;
              r5.x = r6.z + r5.x;
              r6.z = -r5.w * 0.384615391 + r1.w;
              r7.xy = r5.zz * float2(-0.366203994,0.732379675) + r6.xy;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.z).x;
              r5.x = r6.z + r5.x;
              r6.z = -r5.w * 0.461538464 + r1.w;
              r7.xy = r5.zz * float2(-0.923958182,-0.255964309) + r6.xy;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.z).x;
              r5.x = r6.z + r5.x;
              r6.z = -r5.w * 0.538461566 + r1.w;
              r7.xy = r5.zz * float2(-0.286924005,0.278052986) + r6.xy;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.z).x;
              r5.x = r6.z + r5.x;
              r6.z = -r5.w * 0.615384638 + r1.w;
              r7.xy = r5.zz * float2(0.772301197,0.157332897) + r6.xy;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.z).x;
              r5.x = r6.z + r5.x;
              r6.z = -r5.w * 0.692307711 + r1.w;
              r7.xy = r5.zz * float2(0.378513008,0.405219913) + r6.xy;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.z).x;
              r5.x = r6.z + r5.x;
              r6.z = -r5.w * 0.769230783 + r1.w;
              r7.xy = r5.zz * float2(0.463021696,-0.691461921) + r6.xy;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.z).x;
              r5.x = r6.z + r5.x;
              r6.z = -r5.w * 0.846153855 + r1.w;
              r7.xy = r5.zz * float2(0.423523009,0.86302799) + r6.xy;
              r6.z = t8.SampleCmpLevelZero(s9_s, r7.xyz, r6.z).x;
              r5.x = r6.z + r5.x;
              r5.w = -r5.w * 0.923076928 + r1.w;
              r7.xy = r5.yz * float2(0.855864286,-0.338255405) + r6.xy;
              r5.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r5.w).x;
              r5.x = r5.x + r5.y;
              r5.x = 0.0769230798 * r5.x;
              r4.z = r5.x * r5.x;
            }
            r4.z = r4.z + -r4.w;
            r4.y = r4.y * r4.z + r4.w;
          } else {
            r4.zw = cb13[r2.w+11].zz * float2(1,-1);
            r5.xy = r1.yz * r4.zw + cb13[r2.w+11].xy;
            r6.xy = cb13[r2.w+11].ww;
            r6.z = 0;
            r6.xyz = r0.zzz ? cb13[r2.w+19].xxy : r6.xyz;
            r5.z = trunc(r2.x);
            r0.z = cmp(asint(cb13[18].x) >= 1);
            if (r0.z != 0) {
              r0.z = t8.SampleCmpLevelZero(s9_s, r5.xyz, r1.w).x;
              r1.y = -r6.z * 0.0370370373 + r1.w;
              r7.xy = r6.yy * float2(-0.263353914,0.0396538191) + r5.xy;
              r7.z = r5.z;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.0740740746 + r1.w;
              r7.xy = r6.yy * float2(-0.717202425,0.368303299) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.111111112 + r1.w;
              r7.xy = r6.yy * float2(-0.0199530609,-0.398839206) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.148148149 + r1.w;
              r7.xy = r6.yy * float2(-0.440993786,-0.22101) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.185185179 + r1.w;
              r7.xy = r6.yy * float2(0.220039204,0.294344813) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.222222224 + r1.w;
              r7.xy = r6.yy * float2(-0.767565727,-0.148275301) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.259259254 + r1.w;
              r7.xy = r6.yy * float2(-0.2381019,0.547106206) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.296296299 + r1.w;
              r7.xy = r6.yy * float2(0.217303097,-0.134587899) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.333333343 + r1.w;
              r7.xy = r6.yy * float2(-0.638777375,0.756133914) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.370370358 + r1.w;
              r7.xy = r6.yy * float2(-0.1614144,0.977652073) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.407407403 + r1.w;
              r7.xy = r6.yy * float2(0.215631902,0.612341285) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.444444448 + r1.w;
              r7.xy = r6.yy * float2(0.232887506,0.945287228) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.481481493 + r1.w;
              r7.xy = r6.yy * float2(-0.944064379,0.123607703) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.518518507 + r1.w;
              r7.xy = r6.yy * float2(-0.740823686,-0.507682979) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.555555582 + r1.w;
              r7.xy = r6.yy * float2(-0.411301911,-0.890596688) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.592592597 + r1.w;
              r7.xy = r6.yy * float2(-0.248642907,-0.621399283) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.629629612 + r1.w;
              r7.xy = r6.yy * float2(0.696784973,0.264493704) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.666666687 + r1.w;
              r7.xy = r6.yy * float2(0.539436281,0.817321479) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.703703701 + r1.w;
              r7.xy = r6.yy * float2(0.615120828,-0.149864003) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.740740716 + r1.w;
              r7.xy = r6.yy * float2(0.0936533585,-0.78174752) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.777777791 + r1.w;
              r7.xy = r6.yy * float2(0.276806712,-0.489596814) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.814814806 + r1.w;
              r7.xy = r6.yy * float2(0.663918078,-0.600717187) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.851851881 + r1.w;
              r7.xy = r6.yy * float2(0.388036907,-0.895089388) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.888888896 + r1.w;
              r7.xy = r6.yy * float2(0.991614401,-0.0793915167) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.92592591 + r1.w;
              r7.xy = r6.yy * float2(0.783184826,0.602934778) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.962962985 + r1.w;
              r7.xy = r6.yy * float2(0.899860322,-0.398354292) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r0.z = 0.0370370373 * r0.z;
              r4.y = r0.z * r0.z;
            } else {
              r0.z = t8.SampleCmpLevelZero(s9_s, r5.xyz, r1.w).x;
              r1.y = -r6.z * 0.0769230798 + r1.w;
              r7.xy = r6.yy * float2(-0.507720828,-0.617089927) + r5.xy;
              r7.z = r5.z;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.15384616 + r1.w;
              r7.xy = r6.yy * float2(-0.0515490212,-0.750809789) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.230769232 + r1.w;
              r7.xy = r6.yy * float2(-0.764104187,0.200915202) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.307692319 + r1.w;
              r7.xy = r6.yy * float2(0.00728477398,-0.205946997) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.384615391 + r1.w;
              r7.xy = r6.yy * float2(-0.366203994,0.732379675) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.461538464 + r1.w;
              r7.xy = r6.yy * float2(-0.923958182,-0.255964309) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.538461566 + r1.w;
              r7.xy = r6.yy * float2(-0.286924005,0.278052986) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.615384638 + r1.w;
              r7.xy = r6.yy * float2(0.772301197,0.157332897) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.692307711 + r1.w;
              r7.xy = r6.yy * float2(0.378513008,0.405219913) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.769230783 + r1.w;
              r7.xy = r6.yy * float2(0.463021696,-0.691461921) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.846153855 + r1.w;
              r7.xy = r6.yy * float2(0.423523009,0.86302799) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r1.y = -r6.z * 0.923076928 + r1.w;
              r7.xy = r6.xy * float2(0.855864286,-0.338255405) + r5.xy;
              r1.y = t8.SampleCmpLevelZero(s9_s, r7.xyz, r1.y).x;
              r0.z = r1.y + r0.z;
              r0.z = 0.0769230798 * r0.z;
              r4.y = r0.z * r0.z;
            }
          }
          r0.z = (int)r4.x;
          r1.y = trunc(r2.x);
          r0.z = cmp(r1.y >= r0.z);
          r0.z = r0.z ? 1.000000 : 0;
          r1.y = dot(r3.xyzw, icb[r4.x+0].xyzw);
          r0.z = saturate(r0.z * r1.y + r4.y);
        } else {
          r0.z = 1;
        }
        r2.y = r2.z ? r2.y : r0.z;
      }
      r0.z = r2.y * r1.x;
      float3 classic_cloud_world_0 = r0.xyw;
      r1.y = 20 * cb12[66].x;
      r2.zw = trunc(cb12[68].xy);
      r3.xyz = -cb12[0].xyz + r0.xyw;
      r1.z = dot(r3.xyz, r3.xyz);
      r1.z = sqrt(r1.z);
      r3.xy = cb12[67].xy;
      r3.z = 0;
      r3.xyz = r3.xyz + r0.xyw;
      r3.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r3.xyz;
      r3.xyz = r3.xyz / cb12[66].xxx;
      r4.xy = float2(20,20) * cb12[67].xy;
      r4.z = 0;
      r0.xyw = r4.xyz + r0.xyw;
      r0.xyw = float3(0.00999999978,0.00999999978,0.00999999978) * r0.xyw;
      r0.xyw = r0.xyw / r1.yyy;
      r1.yw = cb13[0].xy * r3.zz;
      r1.yw = r1.yw / cb13[0].zz;
      r2.xy = r3.xy + -r1.yw;
      r1.yw = cb13[0].xy * r0.ww;
      r1.yw = r1.yw / cb13[0].zz;
      r3.xy = -r1.yw + r0.xy;
      r0.x = t14.SampleLevel(s14_s, r2.xyz, 1).x;
      r0.y = t14.SampleLevel(s14_s, r2.xyw, 1).x;
      r0.y = r0.y + -r0.x;
      r0.x = cb12[66].w * r0.y + r0.x;
      r3.zw = r2.zw;
      r0.y = t14.SampleLevel(s14_s, r3.xyz, 1).x;
      r0.w = t14.SampleLevel(s14_s, r3.xyw, 1).x;
      r0.w = r0.w + -r0.y;
      r0.y = cb12[66].w * r0.w + r0.y;
      r0.w = -0.25 + cb13[0].z;
      r0.w = saturate(10 * r0.w);
      r1.y = -100 + r1.z;
      r1.y = saturate(0.00666666683 * r1.y);
      r0.y = r0.y + -r0.x;
      r0.x = r1.y * r0.y + r0.x;
      r0.x = -r0.w * r0.x + 1;
      r0.x = ClassicCloudShadow(classic_cloud_world_0, r0.x);
      r1.x = r0.z * r0.x;
    }
  } else {
    r1.x = 1;
  }
  o0.xyzw = r1.xxxx;
  return;
}
