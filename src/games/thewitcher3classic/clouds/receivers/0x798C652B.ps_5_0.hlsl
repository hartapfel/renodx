#include "../shadow_inputs.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 31 15:08:28 2026
Texture2DArray<float4> t19 : register(t19);

Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float4> t8 : register(t8);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s14_s : register(s14);

SamplerState s10_s : register(s10);

SamplerComparisonState s9_s : register(s9);

SamplerState s0_s : register(s0);

cbuffer cb13 : register(b13)
{
  float4 cb13[44];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[6];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[69];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[3];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[11];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float3 v4 : TEXCOORD4,
  out float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = cmp(0 < asint(cb13[35].x));
  if (r0.x != 0) {
    r0.xy = -cb12[0].xy + v4.xy;
    r0.x = dot(r0.xy, r0.xy);
    r0.x = sqrt(r0.x);
    r0.y = cmp(r0.x < cb13[36].y);
    if (r0.y != 0) {
      r0.y = cb13[37].z * r0.x;
      r0.y = max(1, r0.y);
      r0.y = cb13[36].x / r0.y;
      r0.y = min(1, r0.y);
      r0.x = cb13[36].z + r0.x;
      r0.x = saturate(cb13[36].w * r0.x);
      r1.y = 0;
      r0.zw = float2(0,0);
      r1.z = 0;
      while (true) {
        r1.w = cmp((int)r0.w >= asint(cb13[35].x));
        r1.z = 0;
        if (r1.w != 0) break;
        r2.xy = -cb13[r0.w+39].xy + v4.xy;
        r3.xy = cb13[r0.w+39].zw * r2.xy;
        r2.xz = cmp(r3.xy >= float2(0,0));
        r1.w = r2.z ? r2.x : 0;
        r2.xz = cmp(float2(1,1) >= r3.xy);
        r1.w = r1.w ? r2.x : 0;
        r1.w = r2.z ? r1.w : 0;
        if (r1.w != 0) {
          r3.z = (int)r0.w;
          r3.w = -r2.y * cb13[r0.w+39].w + 1;
          r2.x = t19.SampleLevel(s10_s, r3.xwz, 0).x;
          r2.x = cb13[38].x * r2.x + cb13[38].y;
          r2.x = -v4.z + r2.x;
          r2.x = -0.100000001 + r2.x;
          r2.x = saturate(r2.x * r0.y);
          r2.x = 1 + -r2.x;
          r2.y = 1 + -r2.x;
          r0.z = r0.x * r2.y + r2.x;
          r1.z = -1;
          break;
        }
        r1.x = (int)r0.w + 1;
        r0.zw = r1.yx;
        r1.z = r1.w;
      }
    } else {
      r1.z = 0;
    }
  } else {
    r1.z = 0;
  }
  r0.x = r1.z ? r0.z : 1;
  r0.y = cmp(0 < r0.x);
  if (r0.y != 0) {
    r0.yzw = cb13[5].xyz * v4.yyy;
    r0.yzw = cb13[4].xyz * v4.xxx + r0.yzw;
    r0.yzw = cb13[6].xyz * v4.zzz + r0.yzw;
    r0.yzw = cb13[7].xyz + r0.yzw;
    r1.x = cmp(abs(r0.w) >= 0.999000013);
    if (r1.x != 0) {
      r1.y = 1;
    }
    if (r1.x == 0) {
      r2.xyzw = -cb13[8].xyzw + r0.yyyy;
      r3.xyzw = -cb13[9].xyzw + r0.zzzz;
      r2.xyzw = max(abs(r3.xyzw), abs(r2.xyzw));
      r3.xyzw = cmp(r2.xyzw < cb13[10].xyzw);
      r3.xyzw = r3.xyzw ? float4(1,1,1,1) : 0;
      r4.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb13[15].zzzz);
      r4.xyzw = r4.xyzw ? float4(1,1,1,1) : 0;
      r1.x = dot(r3.xyzw, r4.xyzw);
      r1.z = cmp(r1.x < 0.5);
      if (r1.z != 0) {
        r1.y = 1;
      }
      if (r1.z == 0) {
        r2.xyzw = r2.xyzw / cb13[10].xyzw;
        r3.xyzw = float4(1,1,1,1) + -cb13[17].xyzw;
        r2.xyzw = -r3.xyzw + r2.xyzw;
        r2.xyzw = saturate(r2.xyzw / cb13[17].xyzw);
        r1.x = cb13[15].z + -r1.x;
        r1.w = (int)r1.x;
        r3.x = (int)cb13[15].z;
        r3.x = (int)r3.x + -1;
        r3.yz = cb13[r1.w+11].zz * float2(1,-1);
        r4.xy = r0.yz * r3.yz + cb13[r1.w+11].xy;
        r4.z = trunc(r1.x);
        r0.y = cmp(asint(cb13[18].x) >= 1);
        if (r0.y != 0) {
          r0.y = t8.SampleCmpLevelZero(s9_s, r4.xyz, r0.w).x;
          r5.xyzw = cb13[r1.w+11].wwww * float4(-0.263353914,0.0396538191,-0.717202425,0.368303299) + r4.xyxy;
          r6.xy = r5.xy;
          r6.z = r4.z;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(-0.0199530609,-0.398839206,-0.440993786,-0.22101) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(0.220039204,0.294344813,-0.767565727,-0.148275301) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(-0.2381019,0.547106206,0.217303097,-0.134587899) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(-0.638777375,0.756133914,-0.1614144,0.977652073) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(0.215631902,0.612341285,0.232887506,0.945287228) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(-0.944064379,0.123607703,-0.740823686,-0.507682979) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(-0.411301911,-0.890596688,-0.248642907,-0.621399283) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(0.696784973,0.264493704,0.539436281,0.817321479) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(0.615120828,-0.149864003,0.0936533585,-0.78174752) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(0.276806712,-0.489596814,0.663918078,-0.600717187) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(0.388036907,-0.895089388,0.991614401,-0.0793915167) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(0.783184826,0.602934778,0.899860322,-0.398354292) + r4.xyxy;
          r6.xy = r5.xy;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r6.xy = r5.zw;
          r0.z = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.y = r0.y + r0.z;
          r0.y = 0.0370370373 * r0.y;
          r0.y = r0.y * r0.y;
        } else {
          r0.z = t8.SampleCmpLevelZero(s9_s, r4.xyz, r0.w).x;
          r5.xyzw = cb13[r1.w+11].wwww * float4(-0.507720828,-0.617089927,-0.0515490212,-0.750809789) + r4.xyxy;
          r6.xy = r5.xy;
          r6.z = r4.z;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r6.xy = r5.zw;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(-0.764104187,0.200915202,0.00728477398,-0.205946997) + r4.xyxy;
          r6.xy = r5.xy;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r6.xy = r5.zw;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(-0.366203994,0.732379675,-0.923958182,-0.255964309) + r4.xyxy;
          r6.xy = r5.xy;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r6.xy = r5.zw;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(-0.286924005,0.278052986,0.772301197,0.157332897) + r4.xyxy;
          r6.xy = r5.xy;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r6.xy = r5.zw;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(0.378513008,0.405219913,0.463021696,-0.691461921) + r4.xyxy;
          r6.xy = r5.xy;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r6.xy = r5.zw;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r5.xyzw = cb13[r1.w+11].wwww * float4(0.423523009,0.86302799,0.855864286,-0.338255405) + r4.xyxy;
          r6.xy = r5.xy;
          r1.x = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r1.x + r0.z;
          r6.xy = r5.zw;
          r0.w = t8.SampleCmpLevelZero(s9_s, r6.xyz, r0.w).x;
          r0.z = r0.z + r0.w;
          r0.z = 0.0769230798 * r0.z;
          r0.y = r0.z * r0.z;
        }
        r0.z = (int)r3.x;
        r0.z = cmp(r4.z >= r0.z);
        r0.z = r0.z ? 1.000000 : 0;
        r0.w = dot(r2.xyzw, icb[r3.x+0].xyzw);
        r0.y = r0.z * r0.w + r0.y;
        r0.y = min(1, r0.y);
      } else {
        r0.y = 1;
      }
      r1.y = r1.z ? r1.y : r0.y;
    }
    r0.x = min(r1.y, r0.x);
    float3 classic_cloud_world_0 = v4.xyz;
    r0.y = 20 * cb12[66].x;
    r1.zw = trunc(cb12[68].xy);
    r2.xyz = -cb12[0].xyz + v4.xyz;
    r0.z = dot(r2.xyz, r2.xyz);
    r0.z = sqrt(r0.z);
    r2.xy = cb12[67].xy;
    r2.z = 0;
    r2.xyz = v4.xyz + r2.xyz;
    r2.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r2.xyz;
    r2.xyz = r2.xyz / cb12[66].xxx;
    r3.xy = float2(20,20) * cb12[67].xy;
    r3.z = 0;
    r3.xyz = v4.xyz + r3.xyz;
    r3.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r3.xyz;
    r3.xyz = r3.xyz / r0.yyy;
    r0.yw = cb13[0].xy * r2.zz;
    r0.yw = r0.yw / cb13[0].zz;
    r1.xy = r2.xy + -r0.yw;
    r0.yw = cb13[0].xy * r3.zz;
    r0.yw = r0.yw / cb13[0].zz;
    r2.xy = r3.xy + -r0.yw;
    r0.y = t14.SampleLevel(s14_s, r1.xyz, 1).x;
    r0.w = t14.SampleLevel(s14_s, r1.xyw, 1).x;
    r0.w = r0.w + -r0.y;
    r0.y = cb12[66].w * r0.w + r0.y;
    r2.zw = r1.zw;
    r0.w = t14.SampleLevel(s14_s, r2.xyz, 1).x;
    r1.x = t14.SampleLevel(s14_s, r2.xyw, 1).x;
    r1.x = r1.x + -r0.w;
    r0.w = cb12[66].w * r1.x + r0.w;
    r1.x = -0.25 + cb13[0].z;
    r1.x = saturate(10 * r1.x);
    r0.z = -100 + r0.z;
    r0.z = saturate(0.00666666683 * r0.z);
    r0.w = r0.w + -r0.y;
    r0.y = r0.z * r0.w + r0.y;
    r0.y = -r1.x * r0.y + 1;
    r0.y = ClassicCloudShadow(classic_cloud_world_0, r0.y);
    r0.x = r0.x * r0.y;
  } else {
    r0.x = 0;
  }
  r0.yzw = cb4[2].xxx * cb4[1].xyz;
  r1.xy = cb4[4].xx * v2.xy;
  r1.xy = cb0[0].xx * cb4[3].xy + r1.xy;
  r1.xy = t0.Sample(s0_s, r1.xy).xy;
  r1.xy = r1.xy * float2(0.5,0.5) + float2(-0.200000003,-0.200000003);
  r1.xy = r1.xy * cb4[5].xx + v2.xy;
  r1.xyz = t1.Sample(s0_s, r1.xy).xyz;
  r1.xyz = v3.www * r1.xyz;
  r1.xyz = v3.xyz * r1.xyz;
  r0.yzw = cb0[10].xyz * cb4[0].xxx + r0.yzw;
  r0.yzw = r0.yzw * r1.xyz;
  r0.x = max(0.600000024, r0.x);
  r1.xyz = cb0[9].www * r0.yzw;
  r1.xyz = float3(0.399999976,0.399999976,0.399999976) * r1.xyz;
  r0.yzw = r0.yzw * float3(0.600000024,0.600000024,0.600000024) + r1.xyz;
  r0.xyz = r0.xxx * r0.yzw;
  r0.xyz = float3(2.20000005,2.20000005,2.20000005) * r0.xyz;
  r0.xyz = max(float3(0,0,0), r0.xyz);
  r0.xyz = log2(r0.xyz);
  r0.xyz = float3(2.20000005,2.20000005,2.20000005) * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.xyz = cb2[2].xyz * r0.xyz;
  r0.w = saturate(1 + -v1.w);
  r0.w = cb2[2].w * r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = 0;
  return;
}
