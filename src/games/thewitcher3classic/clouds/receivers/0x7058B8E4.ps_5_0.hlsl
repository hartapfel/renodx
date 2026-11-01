#include "../shadow_inputs.hlsli"
ByteAddressBuffer Raw21 : register(t21);
ByteAddressBuffer Raw20 : register(t20);
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 31 15:08:28 2026
Texture2D<float4> t24 : register(t24);

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t22 : register(t22);

Texture2DArray<float4> t19 : register(t19);

Texture2DArray<float4> t14 : register(t14);

TextureCubeArray<float4> t10 : register(t10);

Texture2DArray<float4> t9 : register(t9);

Texture2DArray<float4> t8 : register(t8);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s14_s : register(s14);

SamplerState s11_s : register(s11);

SamplerState s10_s : register(s10);

SamplerComparisonState s9_s : register(s9);

SamplerState s0_s : register(s0);

cbuffer cb13 : register(b13)
{
  float4 cb13[3323];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[8];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[219];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[17];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float4 v5 : TEXCOORD5,
  float3 v6 : TEXCOORD6,
  float4 v7 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v2.xy).xyzw;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r1.xyz = v4.xyz * r0.yyy;
  r2.x = v2.w;
  r2.y = v3.w;
  r2.z = v4.w;
  r1.xyz = v6.xyz * r0.xxx + r1.xyz;
  r0.xyz = r2.xyz * r0.zzz + r1.xyz;
  r1.xyzw = t1.Sample(s0_s, v2.xy).xyzw;
  r1.xyz = log2(r1.xyz);
  r1.xyz = float3(2.20000005,2.20000005,2.20000005) * r1.xyz;
  r1.xyz = exp2(r1.xyz);
  r2.x = r1.x + r1.y;
  r2.x = r2.x + r1.z;
  r2.z = cb4[1].x + -1;
  r2.yz = float2(0.333299994,0.5) * r2.xz;
  r2.w = saturate(r2.z);
  r2.x = r2.x * -0.666599989 + 1;
  r2.x = r2.w * r2.x + r2.y;
  r3.xyz = cb4[0].xyz * r1.xyz;
  r3.xyz = saturate(float3(1.5,1.5,1.5) * r3.xyz);
  r2.x = saturate(r2.x * abs(r2.z));
  r2.yzw = r3.xyz + -r1.xyz;
  r1.xyz = r2.xxx * r2.yzw + r1.xyz;
  r1.w = min(cb4[2].x, r1.w);
  r1.xyz = saturate(r1.xyz * r1.www);
  r0.w = log2(r0.w);
  r0.w = 2.20000005 * r0.w;
  r0.w = exp2(r0.w);
  r2.x = 1 + -r0.w;
  r2.y = log2(cb4[3].x);
  r2.y = 2.20000005 * r2.y;
  r2.y = exp2(r2.y);
  r2.z = r2.x * cb4[4].x + cb4[5].x;
  r2.y = saturate(r2.y * r2.z);
  r3.xyzw = (uint4)v7.xyxy;
  r2.z = dot(r0.xyz, r0.xyz);
  r2.z = rsqrt(r2.z);
  r4.xyz = r2.zzz * r0.xyz;
  r5.xyzw = (uint4)r3.zwzw >> int4(4,4,5,5);
  r0.xy = (int2)cb12[24].xz;
  r0.xy = mad((int2)r5.yw, (int2)r0.xy, (int2)r5.xz);
  r0.x = (uint)r0.x << 8;
  r5.xyz = cb12[0].xyz + -v5.xyz;
  r2.w = dot(r5.xyz, r5.xyz);
  r2.w = rsqrt(r2.w);
  r6.xyz = r5.xyz * r2.www;
  r7.xy = (int2)r3.zw ^ int2(2,2);
  r7.zw = max((int2)-r3.zw, (int2)r3.xy);
  r7.zw = (uint2)r7.zw >> int2(1,1);
  r8.xy = -(int2)r7.zw;
  r7.xy = (int2)r7.xy & int2(0x80000000,0x80000000);
  r7.xy = r7.xy ? r8.xy : r7.zw;
  r7.zw = float2(0,0);
  r7.xy = t24.Load(r7.xyz).xy;
  r8.xyz = -cb12[0].xyz + v5.xyz;
  r4.w = dot(r8.xyz, r8.xyz);
  r4.w = sqrt(r4.w);
  r9.x = cb12[1].z;
  r9.y = cb12[2].z;
  r9.z = cb12[3].z;
  r5.w = dot(r9.xyz, r8.xyz);
  r6.w = 1 / cb12[21].y;
  r6.w = r6.w * r4.w;
  r5.w = r6.w / r5.w;
  r5.w = -r5.w + r4.w;
  r5.w = saturate(cb13[33].w * r5.w);
  r5.w = cb13[33].z * r5.w;
  r5.w = max(0.00100000005, r5.w);
  r6.w = r4.w / cb13[34].z;
  r7.z = cmp(r7.x < r7.y);
  if (r7.z != 0) {
    r7.z = cmp(r6.w < r7.x);
    r7.w = cmp(r7.y < r6.w);
    r8.w = cb13[34].z * r7.x + -cb13[34].x;
    r8.w = saturate(-r8.w * cb13[34].y + 1);
    r9.x = r6.w + -r7.x;
    r9.x = cb13[34].z * r9.x;
    r9.x = saturate(r9.x / r5.w);
    r9.y = r9.x * r8.w;
    r7.z = (int)r7.z | (int)r7.w;
    r9.x = 1;
    r7.zw = r7.zz ? float2(0,1) : r9.xy;
  } else {
    r8.w = cmp(r7.y < r7.x);
    r9.x = cmp(r6.w < r7.y);
    r9.y = cmp(r7.x < r6.w);
    r7.x = cb13[34].z * r7.x + -cb13[34].x;
    r10.y = saturate(-r7.x * cb13[34].y + 1);
    r6.w = r6.w + -r7.y;
    r6.w = cb13[34].z * r6.w;
    r5.w = saturate(r6.w / r5.w);
    r10.w = 1 + -r5.w;
    r10.xz = float2(1,1);
    r7.xy = r9.yy ? r10.xy : r10.zw;
    r7.xy = r9.xx ? float2(1,1) : r7.xy;
    r7.zw = r8.ww ? r7.xy : float2(0,1);
  }
  r5.w = -r7.w * r7.z + 1;
  r7.xy = (int2)r3.zw & int2(1,1);
  r7.zw = r7.yy ? float2(1.40129846e-045,4.20389539e-045) : float2(2.80259693e-045,0);
  r6.w = r7.x ? r7.z : r7.w;
  if (1 == 0) r3.x = 0; else if (1+1 < 32) {   r3.x = (uint)r3.x << (32-(1 + 1)); r3.x = (uint)r3.x >> (32-1);  } else r3.x = (uint)r3.x >> 1;
  if (1 == 0) r3.y = 0; else if (1+1 < 32) {   r3.y = (uint)r3.y << (32-(1 + 1)); r3.y = (uint)r3.y >> (32-1);  } else r3.y = (uint)r3.y >> 1;
  if (1 == 0) r3.z = 0; else if (1+2 < 32) {   r3.z = (uint)r3.z << (32-(1 + 2)); r3.z = (uint)r3.z >> (32-1);  } else r3.z = (uint)r3.z >> 2;
  if (1 == 0) r3.w = 0; else if (1+2 < 32) {   r3.w = (uint)r3.w << (32-(1 + 2)); r3.w = (uint)r3.w >> (32-1);  } else r3.w = (uint)r3.w >> 2;
  r9.xyzw = r3.yyww ? float4(1,3,1,3) : float4(2,0,2,0);
  r3.xy = r3.xz ? r9.xz : r9.yw;
  r3.z = (uint)r6.w << 4;
  r3.x = mad((int)r3.x, 4, (int)r3.z);
  r3.x = (int)r3.x + (int)r3.y;
  r3.x = (int)r3.x;
  r3.x = 0.5 + r3.x;
  r3.y = 0.015625 * r3.x;
  r9.xyz = cb12[2].xyz * v5.yyy;
  r9.xyz = cb12[1].xyz * v5.xxx + r9.xyz;
  r9.xyz = cb12[3].xyz * v5.zzz + r9.xyz;
  r9.xyz = cb12[4].xyz + r9.xyz;
  r3.x = -r3.x * 0.015625 + 1;
  r9.w = 1;
  r10.xzw = float3(0,0,0);
  r11.xyzw = float4(0,0,0,0);
  r3.z = 0;
  while (true) {
    r3.w = cmp((uint)r3.z >= 192);
    if (r3.w != 0) break;
    r3.w = mad((int)r0.y, 192, (int)r3.z);
    r3.w = (uint)r3.w << 2;
  // No code for instruction (needs manual fix):
    r3.w = Raw21.Load((uint)r3.w);
    r6.w = cmp((uint)r3.w >= 192);
    if (r6.w != 0) {
      break;
    }
    r3.w = (int)r3.w * 5;
    r12.x = dot(r9.xyzw, cb13[r3.w+2363].xyzw);
    r12.y = dot(r9.xyzw, cb13[r3.w+2364].xyzw);
    r12.z = dot(r9.xyzw, cb13[r3.w+2365].xyzw);
    r13.xyz = cmp(abs(r12.xyz) < float3(1,1,1));
    r6.w = r13.y ? r13.x : 0;
    r6.w = r13.z ? r6.w : 0;
    if (r6.w != 0) {
      r6.w = asuint(cb13[r3.w+2366].w) >> 16;
      r6.w = (uint)r6.w;
      r6.w = 1.52590219e-005 * r6.w;
      r7.z = 0x0000ffff & asint(cb13[r3.w+2366].w);
      r7.z = (uint)r7.z;
      r7.z = 1.52590219e-005 * r7.z;
      r7.w = dot(r12.xyz, r12.xyz);
      r7.w = sqrt(r7.w);
      r7.w = 1 + -r7.w;
      r7.w = max(0, r7.w);
      r12.xy = cb13[r3.w+2367].wx * r7.ww;
      r12.x = saturate(r12.x);
      r7.w = cmp(-1.000000 == cb13[r3.w+2367].w);
      r8.w = cmp(r6.w >= r3.x);
      r10.y = r8.w ? 1.000000 : 0;
      r6.w = cmp(r6.w >= r3.y);
      r6.w = r6.w ? 1.000000 : 0;
      r13.x = r7.z * r6.w;
      r13.y = min(0.998037279, r12.y);
      r13.zw = cb13[r3.w+2367].yz * r12.xx;
      r12.xyzw = r7.wwww ? r10.xyzw : r13.xyzw;
      r11.xyzw = max(r11.xyzw, r12.xyzw);
    }
    r3.z = (int)r3.z + 1;
  }
  r0.y = r11.y * r11.y;
  r3.x = cmp(0 < r11.x);
  r3.y = r3.x ? 0 : 1;
  r3.z = r5.w * r5.w;
  r3.y = min(r3.y, r3.z);
  r0.y = max(r3.y, r0.y);
  r0.y = 1 + -r0.y;
  r3.y = 1 + -r11.x;
  r3.z = 1 + -cb13[33].y;
  r3.x = r3.x ? r3.y : r3.z;
  r3.yz = float2(1,1) + -r11.zw;
  r3.x = min(r3.x, r3.y);
  r3.x = r3.x + -r3.z;
  r3.x = saturate(r0.y * r3.x + r3.z);
  r0.y = saturate(1 + -r0.y);
  r3.y = cmp(0 < asint(cb13[35].x));
  if (r3.y != 0) {
    r3.yz = -cb12[0].xy + v5.xy;
    r3.y = dot(r3.yz, r3.yz);
    r3.y = sqrt(r3.y);
    r3.z = cmp(r3.y < cb13[36].y);
    if (r3.z != 0) {
      r3.z = cb13[37].z * r3.y;
      r3.z = max(1, r3.z);
      r3.z = cb13[36].x / r3.z;
      r3.z = min(1, r3.z);
      r3.y = cb13[36].z + r3.y;
      r3.y = saturate(cb13[36].w * r3.y);
      r9.y = 0;
      r7.zw = float2(0,0);
      r3.w = 0;
      while (true) {
        r5.w = cmp((int)r7.w >= asint(cb13[35].x));
        r3.w = 0;
        if (r5.w != 0) break;
        r9.zw = -cb13[r7.w+39].xy + v5.xy;
        r10.xy = cb13[r7.w+39].zw * r9.zw;
        r11.xy = cmp(r10.xy >= float2(0,0));
        r5.w = r11.y ? r11.x : 0;
        r11.xy = cmp(float2(1,1) >= r10.xy);
        r5.w = r5.w ? r11.x : 0;
        r5.w = r11.y ? r5.w : 0;
        if (r5.w != 0) {
          r10.z = (int)r7.w;
          r10.w = -r9.w * cb13[r7.w+39].w + 1;
          r6.w = t19.SampleLevel(s10_s, r10.xwz, 0).x;
          r6.w = cb13[38].x * r6.w + cb13[38].y;
          r6.w = -v5.z + r6.w;
          r6.w = -0.100000001 + r6.w;
          r6.w = saturate(r6.w * r3.z);
          r6.w = 1 + -r6.w;
          r8.w = 1 + -r6.w;
          r7.z = r3.y * r8.w + r6.w;
          r3.w = -1;
          break;
        }
        r9.x = (int)r7.w + 1;
        r7.zw = r9.yx;
        r3.w = r5.w;
      }
    } else {
      r3.w = 0;
    }
  } else {
    r3.w = 0;
  }
  r3.y = r3.w ? r7.z : 1;
  r3.z = cmp(0 < r3.y);
  if (r3.z != 0) {
    r9.xyz = cb13[5].xyz * v5.yyy;
    r9.xyz = cb13[4].xyz * v5.xxx + r9.xyz;
    r9.xyz = cb13[6].xyz * v5.zzz + r9.xyz;
    r9.xyz = cb13[7].xyz + r9.xyz;
    r3.z = cmp(abs(r9.z) >= 0.999000013);
    if (r3.z != 0) {
      r3.w = 1;
    }
    if (r3.z == 0) {
      r10.xyzw = -cb13[8].xyzw + r9.xxxx;
      r11.xyzw = -cb13[9].xyzw + r9.yyyy;
      r10.xyzw = max(abs(r11.xyzw), abs(r10.xyzw));
      r11.xyzw = cmp(r10.xyzw < cb13[10].xyzw);
      r11.xyzw = r11.xyzw ? float4(1,1,1,1) : 0;
      r12.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb13[15].zzzz);
      r12.xyzw = r12.xyzw ? float4(1,1,1,1) : 0;
      r3.z = dot(r11.xyzw, r12.xyzw);
      r5.w = cmp(r3.z < 0.5);
      if (r5.w != 0) {
        r3.w = 1;
      }
      if (r5.w == 0) {
        r10.xyzw = r10.xyzw / cb13[10].xyzw;
        r11.xyzw = float4(1,1,1,1) + -cb13[17].xyzw;
        r10.xyzw = -r11.xyzw + r10.xyzw;
        r10.xyzw = saturate(r10.xyzw / cb13[17].xyzw);
        r3.z = cb13[15].z + -r3.z;
        r6.w = (int)r3.z;
        r7.z = (int)cb13[15].z;
        r7.z = (int)r7.z + -1;
        r11.xy = cb13[r6.w+11].zz * float2(1,-1);
        r11.xy = r9.xy * r11.xy + cb13[r6.w+11].xy;
        r11.z = trunc(r3.z);
        r3.z = cmp(asint(cb13[18].x) >= 1);
        if (r3.z != 0) {
          r3.z = t8.SampleCmpLevelZero(s9_s, r11.xyz, r9.z).x;
          r12.xyzw = cb13[r6.w+11].wwww * float4(-0.263353914,0.0396538191,-0.717202425,0.368303299) + r11.xyxy;
          r13.xy = r12.xy;
          r13.z = r11.z;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(-0.0199530609,-0.398839206,-0.440993786,-0.22101) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(0.220039204,0.294344813,-0.767565727,-0.148275301) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(-0.2381019,0.547106206,0.217303097,-0.134587899) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(-0.638777375,0.756133914,-0.1614144,0.977652073) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(0.215631902,0.612341285,0.232887506,0.945287228) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(-0.944064379,0.123607703,-0.740823686,-0.507682979) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(-0.411301911,-0.890596688,-0.248642907,-0.621399283) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(0.696784973,0.264493704,0.539436281,0.817321479) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(0.615120828,-0.149864003,0.0936533585,-0.78174752) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(0.276806712,-0.489596814,0.663918078,-0.600717187) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(0.388036907,-0.895089388,0.991614401,-0.0793915167) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r12.xyzw = cb13[r6.w+11].wwww * float4(0.783184826,0.602934778,0.899860322,-0.398354292) + r11.xyxy;
          r13.xy = r12.xy;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r3.z = r7.w + r3.z;
          r3.z = 0.0370370373 * r3.z;
          r3.z = r3.z * r3.z;
        } else {
          r7.w = t8.SampleCmpLevelZero(s9_s, r11.xyz, r9.z).x;
          r12.xyzw = cb13[r6.w+11].wwww * float4(-0.507720828,-0.617089927,-0.0515490212,-0.750809789) + r11.xyxy;
          r13.xy = r12.xy;
          r13.z = r11.z;
          r8.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r7.w = r8.w + r7.w;
          r13.xy = r12.zw;
          r8.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r7.w = r8.w + r7.w;
          r12.xyzw = cb13[r6.w+11].wwww * float4(-0.764104187,0.200915202,0.00728477398,-0.205946997) + r11.xyxy;
          r13.xy = r12.xy;
          r8.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r7.w = r8.w + r7.w;
          r13.xy = r12.zw;
          r8.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r7.w = r8.w + r7.w;
          r12.xyzw = cb13[r6.w+11].wwww * float4(-0.366203994,0.732379675,-0.923958182,-0.255964309) + r11.xyxy;
          r13.xy = r12.xy;
          r8.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r7.w = r8.w + r7.w;
          r13.xy = r12.zw;
          r8.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r7.w = r8.w + r7.w;
          r12.xyzw = cb13[r6.w+11].wwww * float4(-0.286924005,0.278052986,0.772301197,0.157332897) + r11.xyxy;
          r13.xy = r12.xy;
          r8.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r7.w = r8.w + r7.w;
          r13.xy = r12.zw;
          r8.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r7.w = r8.w + r7.w;
          r12.xyzw = cb13[r6.w+11].wwww * float4(0.378513008,0.405219913,0.463021696,-0.691461921) + r11.xyxy;
          r13.xy = r12.xy;
          r8.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r7.w = r8.w + r7.w;
          r13.xy = r12.zw;
          r8.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r7.w = r8.w + r7.w;
          r12.xyzw = cb13[r6.w+11].wwww * float4(0.423523009,0.86302799,0.855864286,-0.338255405) + r11.xyxy;
          r13.xy = r12.xy;
          r6.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r6.w = r7.w + r6.w;
          r13.xy = r12.zw;
          r7.w = t8.SampleCmpLevelZero(s9_s, r13.xyz, r9.z).x;
          r6.w = r7.w + r6.w;
          r6.w = 0.0769230798 * r6.w;
          r3.z = r6.w * r6.w;
        }
        r6.w = (int)r7.z;
        r6.w = cmp(r11.z >= r6.w);
        r6.w = r6.w ? 1.000000 : 0;
        r7.z = dot(r10.xyzw, icb[r7.z+0].xyzw);
        r3.z = r6.w * r7.z + r3.z;
        r3.z = min(1, r3.z);
      } else {
        r3.z = 1;
      }
      r3.w = r5.w ? r3.w : r3.z;
    }
    r3.z = r3.y * r3.w;
    float3 classic_cloud_world_0 = v5.xyz;
    r3.w = 20 * cb12[66].x;
    r9.zw = trunc(cb12[68].xy);
    r10.xy = cb12[67].xy;
    r10.z = 0;
    r10.xyz = v5.xyz + r10.xyz;
    r10.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r10.xyz;
    r10.xyz = r10.xyz / cb12[66].xxx;
    r11.xy = float2(20,20) * cb12[67].xy;
    r11.z = 0;
    r11.xyz = v5.xyz + r11.xyz;
    r11.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r11.xyz;
    r11.xyz = r11.xyz / r3.www;
    r7.zw = cb13[0].xy * r10.zz;
    r7.zw = r7.zw / cb13[0].zz;
    r9.xy = r10.xy + -r7.zw;
    r7.zw = cb13[0].xy * r11.zz;
    r7.zw = r7.zw / cb13[0].zz;
    r10.xy = r11.xy + -r7.zw;
    r3.w = t14.SampleLevel(s14_s, r9.xyz, 1).x;
    r5.w = t14.SampleLevel(s14_s, r9.xyw, 1).x;
    r5.w = r5.w + -r3.w;
    r3.w = cb12[66].w * r5.w + r3.w;
    r10.zw = r9.zw;
    r5.w = t14.SampleLevel(s14_s, r10.xyz, 1).x;
    r6.w = t14.SampleLevel(s14_s, r10.xyw, 1).x;
    r6.w = r6.w + -r5.w;
    r5.w = cb12[66].w * r6.w + r5.w;
    r6.w = -0.25 + cb13[0].z;
    r6.w = saturate(10 * r6.w);
    r7.z = -100 + r4.w;
    r7.z = saturate(0.00666666683 * r7.z);
    r5.w = r5.w + -r3.w;
    r3.w = r7.z * r5.w + r3.w;
    r3.w = -r6.w * r3.w + 1;
    r3.w = ClassicCloudShadow(classic_cloud_world_0, r3.w);
    r3.y = r3.z * r3.w;
  }
  r3.z = cmp(0 < r3.y);
  if (r3.z != 0) {
    r3.z = dot(cb13[0].xyz, r4.xyz);
    r9.xyz = saturate(r3.zzz);
    r3.w = cb4[6].x + r9.z;
    r3.w = cmp(0 < r3.w);
    if (r3.w != 0) {
      r10.xyz = r5.xyz * r2.www + cb13[0].xyz;
      r3.w = dot(r10.xyz, r10.xyz);
      r3.w = rsqrt(r3.w);
      r10.xyz = r10.xyz * r3.www;
      r3.w = dot(r10.xyz, r6.xyz);
      r3.w = 1 + -abs(r3.w);
      r3.w = max(0, r3.w);
      r5.w = r3.w * r3.w;
      r5.w = r5.w * r5.w;
      r3.w = r5.w * r3.w;
      r5.w = 1 + -r2.y;
      r6.w = cb13[56].x * r5.w;
      r3.w = r6.w * r3.w;
      r6.w = 1 + cb13[56].z;
      r6.w = -cb13[56].z * r2.x + r6.w;
      r3.w = r3.w / r6.w;
      r3.w = r3.w + r2.y;
      r6.w = 1 + -r3.w;
      r6.w = r9.z * r6.w;
      r11.xyz = float3(0.318309873,0.318309873,0.318309873) * r6.www;
      r6.w = cmp(0 < cb4[6].x);
      if (r6.w != 0) {
        r6.w = 1 + r3.z;
        r6.w = 0.5 * r6.w;
        r7.z = dot(cb13[0].xyz, -r6.xyz);
        r7.z = 1 + r7.z;
        r7.z = 0.5 * r7.z;
        r7.w = dot(r4.xyz, -r6.xyz);
        r7.w = 1 + r7.w;
        r7.w = cb12[36].w * r7.w;
        r7.z = r7.z * r7.z;
        r7.w = 0.5 * r7.w;
        r7.z = r7.z * r7.z + -r6.w;
        r6.w = cb12[36].x * r7.z + r6.w;
        r6.w = r7.w * r6.w;
        r7.z = cb4[6].x * cb12[36].y;
        r5.w = cb12[36].z * r5.w + -r11.z;
        r5.w = r7.z * r5.w + r11.z;
        r11.xyz = r6.www * cb4[6].xxx + r5.www;
      }
      r7.zw = -cb12[0].xy + v5.xy;
      r5.w = dot(r7.zw, r7.zw);
      r5.w = sqrt(r5.w);
      r6.w = saturate(v5.z * cb12[218].z + cb12[218].w);
      r12.xyz = -cb13[52].xyz + cb13[51].xyz;
      r12.xyz = r6.www * r12.xyz + cb13[52].xyz;
      r5.w = saturate(r5.w * cb12[218].x + cb12[218].y);
      r12.xyz = -cb13[1].xyz + r12.xyz;
      r12.xyz = r5.www * r12.xyz + cb13[1].xyz;
      r11.xyz = r11.xyz * r3.yyy;
      r11.xyz = r11.xyz * r12.xyz;
      r3.z = cmp(0 < r3.z);
      if (r3.z != 0) {
        r3.z = saturate(dot(r4.xyz, r10.xyz));
        r5.w = dot(r4.xyz, r6.xyz);
        r6.w = r0.w * r0.w;
        r7.z = r6.w * r6.w;
        r3.z = r3.z * r3.z;
        r6.w = r6.w * r6.w + -1;
        r3.z = r3.z * r6.w + 1;
        r3.z = r3.z * r3.z;
        r3.z = 3.14152002 * r3.z;
        r3.z = r7.z / r3.z;
        r6.w = 1 + r0.w;
        r6.w = r6.w * r6.w;
        r7.z = 0.125 * r6.w;
        r6.w = -r6.w * 0.125 + 1;
        r7.w = r9.z * r6.w + r7.z;
        r7.w = r9.z / r7.w;
        r6.w = abs(r5.w) * r6.w + r7.z;
        r6.w = abs(r5.w) / r6.w;
        r6.w = r7.w * r6.w;
        r3.z = r6.w * r3.z;
        r3.z = r3.z * r3.w;
        r3.w = r9.z * abs(r5.w);
        r3.w = 4 * r3.w;
        r3.z = r3.z / r3.w;
        r10.xyz = r3.zzz * r9.zzz;
      } else {
        r10.xyz = float3(0,0,0);
      }
      r10.xyz = r10.xyz * r3.yyy;
      r10.xyz = r10.xyz * r12.xyz;
    } else {
      r9.xyz = float3(0,0,0);
      r11.xyz = float3(0,0,0);
      r10.xyz = float3(0,0,0);
    }
  } else {
    r9.xyz = float3(0,0,0);
    r11.xyz = float3(0,0,0);
    r10.xyz = float3(0,0,0);
  }
  r3.yzw = min(r9.xyz, r3.yyy);
  r5.w = cmp(r0.y == 1.000000);
  r6.w = cmp(cb2[16].x < 0);
  r6.w = r6.w ? 1 : cb12[71].x;
  r7.z = 1 + -r2.y;
  r7.w = cb13[56].x * r7.z;
  r9.xy = float2(1,1) + cb13[56].zw;
  r9.xy = -cb13[56].zw * r2.xx + r9.xy;
  r2.x = cmp(0 < cb4[6].x);
  r8.w = dot(r4.xyz, -r6.xyz);
  r9.z = 1 + r8.w;
  r9.z = cb12[36].w * r9.z;
  r9.z = 0.5 * r9.z;
  r9.w = cb4[6].x * cb12[36].y;
  r10.w = dot(r4.xyz, r6.xyz);
  r11.w = r0.w * r0.w;
  r12.x = r11.w * r11.w;
  r12.y = r11.w * r11.w + -1;
  r0.w = 1 + r0.w;
  r0.w = r0.w * r0.w;
  r12.z = 0.125 * r0.w;
  r0.w = -r0.w * 0.125 + 1;
  r12.w = abs(r10.w) * r0.w + r12.z;
  r12.w = abs(r10.w) / r12.w;
  r13.x = 4 * abs(r10.w);
  r13.y = r5.w ? 1.000000 : 0;
  r5.w = r5.w ? 0 : 1;
  r14.xyz = r11.xyz;
  r15.xyz = r10.xyz;
  r13.z = 0;
  while (true) {
    r13.w = cmp((int)r13.z >= 256);
    if (r13.w != 0) break;
    r13.w = (int)r0.x + (int)r13.z;
    r13.w = (uint)r13.w << 2;
  // No code for instruction (needs manual fix):
    r13.w = Raw20.Load((uint)r13.w);
    r14.w = cmp((uint)r13.w >= 256);
    if (r14.w != 0) {
      break;
    }
    r13.w = (int)r13.w * 9;
    r16.xyz = cb13[r13.w+58].xyz + -v5.xyz;
    r14.w = dot(r16.xyz, r16.xyz);
    r15.w = sqrt(r14.w);
    r17.x = r15.w / cb13[r13.w+58].w;
    r17.y = r17.x * r17.x;
    r17.y = -r17.y * r17.y + 1;
    r17.y = max(0, r17.y);
    r17.y = r17.y * r17.y;
    r18.xyz = int3(1,2048,4096) & asint(cb13[r13.w+61].www);
    r17.z = cmp(0 < cb13[r13.w+63].z);
    r17.w = cmp(0 < cb13[r13.w+64].x);
    r18.w = r14.w * cb13[r13.w+63].x + 1;
    r17.y = r17.y / r18.w;
    if (r18.x != 0) {
      r18.w = rsqrt(r14.w);
      r19.xyz = r18.www * r16.xyz;
      r18.w = dot(-r19.xyz, cb13[r13.w+60].xyz);
      r18.w = saturate(r18.w * cb13[r13.w+62].y + cb13[r13.w+62].z);
      r18.w = log2(r18.w);
      r18.w = cb13[r13.w+62].w * r18.w;
      r18.w = exp2(r18.w);
      r17.y = r18.w * r17.y;
    }
    r18.w = cmp(0 < r17.y);
    r17.z = r17.z ? r18.w : 0;
    if (r17.z != 0) {
      if (r18.x != 0) {
        r19.xyz = -cb13[r13.w+58].xyz + v5.xyz;
        r20.xyz = cb13[r13.w+65].zwy * cb13[r13.w+60].zxy;
        r20.xyz = cb13[r13.w+60].yzx * cb13[r13.w+65].wyz + -r20.xyz;
        r20.x = dot(r20.xyz, r19.xyz);
        r20.y = dot(cb13[r13.w+65].yzw, r19.xyz);
        r20.z = dot(cb13[r13.w+60].xyz, r19.xyz);
        r20.w = cb13[r13.w+65].x;
      } else {
        r19.xyz = -cb13[r13.w+58].xzy + v5.xzy;
        r21.xyz = r16.xyz / r15.www;
        r15.w = max(abs(r21.y), abs(r21.z));
        r15.w = cmp(r15.w < abs(r21.x));
        if (r15.w != 0) {
          r15.w = cmp(0 < r21.x);
          r22.xyz = float3(1,1,-1) * r19.zyx;
          r22.w = cb13[r13.w+65].x;
          r23.xyz = float3(-1,1,1) * r19.zyx;
          r23.w = cb13[r13.w+65].y;
          r20.xyzw = r15.wwww ? r22.xyzw : r23.xyzw;
        } else {
          r15.w = max(abs(r21.x), abs(r21.z));
          r15.w = cmp(r15.w < abs(r21.y));
          if (r15.w != 0) {
            r15.w = cmp(0 < r21.y);
            r22.xyz = float3(-1,1,-1) * r19.xyz;
            r22.w = cb13[r13.w+65].z;
            r19.w = cb13[r13.w+65].w;
            r20.xyzw = r15.wwww ? r22.xyzw : r19.xyzw;
          } else {
            r15.w = cmp(0 < r21.z);
            r20.x = r19.x;
            r20.y = r15.w ? r19.z : -r19.z;
            r20.z = r15.w ? -r19.y : r19.y;
            r20.w = r15.w ? cb13[r13.w+66].x : cb13[r13.w+66].y;
          }
        }
      }
      r19.xy = cb13[r13.w+63].yy * r20.xy;
      r19.xy = r19.xy / r20.zz;
      r19.xy = r19.xy * float2(0.5,-0.5) + float2(0.5,0.5);
      if (10 == 0) r19.z = 0; else if (10+20 < 32) {       r19.z = (uint)r20.w << (32-(10 + 20)); r19.z = (uint)r19.z >> (32-10);      } else r19.z = (uint)r20.w >> 20;
      if (10 == 0) r19.w = 0; else if (10+10 < 32) {       r19.w = (uint)r20.w << (32-(10 + 10)); r19.w = (uint)r19.w >> (32-10);      } else r19.w = (uint)r20.w >> 10;
      r19.zw = (uint2)r19.zw;
      r15.w = (int)r20.w & 1023;
      r15.w = (uint)r15.w;
      r17.z = (uint)r20.w >> 30;
      r20.z = (uint)r17.z;
      r17.z = cmp(0 < r15.w);
      if (r17.z != 0) {
        r19.xy = r19.xy * r15.ww + r19.zw;
        r20.xy = float2(0.0009765625,0.0009765625) * r19.xy;
        r15.w = t9.SampleLevel(s10_s, r20.xyz, 0).x;
        r15.w = -r17.x * 0.99000001 + r15.w;
        r15.w = 144.269501 * r15.w;
        r15.w = exp2(r15.w);
        r15.w = min(1, r15.w);
      } else {
        r15.w = 1;
      }
    } else {
      r15.w = 1;
    }
    r17.z = r17.w ? r18.w : 0;
    if (r17.z != 0) {
      r16.w = cb13[r13.w+64].y;
      r16.w = t10.SampleLevel(s10_s, r16.xyzw, 0).x;
      r16.w = -r17.x * 0.99000001 + r16.w;
      r16.w = 144.269501 * r16.w;
      r16.w = exp2(r16.w);
      r16.w = min(1, r16.w);
      r15.w = r16.w * r15.w;
    }
    r15.w = -1 + r15.w;
    r15.w = cb13[r13.w+60].w * r15.w + 1;
    r15.w = r17.y * r15.w;
    r16.w = r18.y ? 1 : r13.y;
    r17.x = r18.z ? 1 : r5.w;
    r16.w = r17.x * r16.w;
    r15.w = r16.w * r15.w;
    r16.w = cmp(0 < r15.w);
    if (r16.w != 0) {
      r16.w = 0x80000000 & asint(cb13[r13.w+61].w);
      r16.w = r16.w ? r6.w : 1;
      r15.w = r16.w * r15.w;
      r14.w = rsqrt(r14.w);
      r16.xyz = r16.xyz * r14.www;
      r14.w = dot(r4.xyz, r16.xyz);
      r16.w = saturate(r14.w);
      r17.xyz = r5.xyz * r2.www + r16.xyz;
      r17.w = dot(r17.xyz, r17.xyz);
      r17.w = rsqrt(r17.w);
      r17.xyz = r17.xyz * r17.www;
      r17.w = dot(r17.xyz, r6.xyz);
      r17.w = 1 + -abs(r17.w);
      r17.w = max(0, r17.w);
      r18.x = r17.w * r17.w;
      r18.x = r18.x * r18.x;
      r17.w = r18.x * r17.w;
      r17.w = r17.w * r7.w;
      r17.w = r17.w / r9.x;
      r17.w = r17.w + r2.y;
      r18.x = 1 + -r17.w;
      r18.x = r18.x * r16.w;
      r18.xyz = float3(0.318309873,0.318309873,0.318309873) * r18.xxx;
      if (r2.x != 0) {
        r18.w = 1 + r14.w;
        r18.w = 0.5 * r18.w;
        r16.x = dot(r16.xyz, -r6.xyz);
        r16.x = 1 + r16.x;
        r16.x = 0.5 * r16.x;
        r16.x = r16.x * r16.x;
        r16.x = r16.x * r16.x + -r18.w;
        r16.x = cb12[36].x * r16.x + r18.w;
        r16.x = r16.x * r9.z;
        r16.y = cb12[36].z * r7.z + -r18.z;
        r16.y = r9.w * r16.y + r18.z;
        r18.xyz = r16.xxx * cb4[6].xxx + r16.yyy;
      }
      r16.xyz = cb13[r13.w+61].xyz * r18.xyz;
      r14.xyz = r15.www * r16.xyz + r14.xyz;
      r14.w = cmp(0 < r14.w);
      if (r14.w != 0) {
        r14.w = saturate(dot(r4.xyz, r17.xyz));
        r14.w = r14.w * r14.w;
        r14.w = r14.w * r12.y + 1;
        r14.w = r14.w * r14.w;
        r14.w = 3.14152002 * r14.w;
        r14.w = r12.x / r14.w;
        r16.x = r16.w * r0.w + r12.z;
        r16.x = r16.w / r16.x;
        r16.x = r16.x * r12.w;
        r14.w = r16.x * r14.w;
        r14.w = r14.w * r17.w;
        r16.x = r16.w * r13.x;
        r14.w = r14.w / r16.x;
        r16.xyz = r14.www * r16.www;
      } else {
        r16.xyz = float3(0,0,0);
      }
      r16.xyz = cb13[r13.w+61].xyz * r16.xyz;
      r15.xyz = r15.www * r16.xyz + r15.xyz;
    }
    r13.z = (int)r13.z + 1;
  }
  r0.x = r8.w + r8.w;
  r5.xyz = r4.xyz * -r0.xxx + -r6.xyz;
  r0.x = dot(r5.xyz, r5.xyz);
  r0.x = rsqrt(r0.x);
  r6.xyz = r5.xyz * r0.xxx;
  r9.xzw = ddx_coarse(r6.xyz);
  r10.xyz = ddy_coarse(r6.xyz);
  r9.xzw = r7.xxx ? -r9.xzw : r9.xzw;
  r7.xyw = r7.yyy ? -r10.xyz : r10.xyz;
  r9.xzw = r5.xyz * r0.xxx + r9.xzw;
  r0.w = dot(r9.xzw, r9.xzw);
  r0.w = rsqrt(r0.w);
  r9.xzw = r9.xzw * r0.www;
  r0.w = dot(r6.xyz, r9.xzw);
  r2.x = 1 + -abs(r0.w);
  r2.x = sqrt(r2.x);
  r2.w = abs(r0.w) * -0.0187292993 + 0.0742610022;
  r2.w = r2.w * abs(r0.w) + -0.212114394;
  r2.w = r2.w * abs(r0.w) + 1.57072878;
  r5.w = r2.w * r2.x;
  r5.w = r5.w * -2 + 3.14159274;
  r0.w = cmp(r0.w < -r0.w);
  r0.w = r0.w ? r5.w : 0;
  r0.w = r2.w * r2.x + r0.w;
  r0.w = 81.4873276 * r0.w;
  r0.w = log2(r0.w);
  r7.xyw = r5.xyz * r0.xxx + r7.xyw;
  r0.x = dot(r7.xyw, r7.xyw);
  r0.x = rsqrt(r0.x);
  r7.xyw = r7.xyw * r0.xxx;
  r0.x = dot(r6.xyz, r7.xyw);
  r2.x = 1 + -abs(r0.x);
  r2.x = sqrt(r2.x);
  r2.w = abs(r0.x) * -0.0187292993 + 0.0742610022;
  r2.w = r2.w * abs(r0.x) + -0.212114394;
  r2.w = r2.w * abs(r0.x) + 1.57072878;
  r5.w = r2.w * r2.x;
  r5.w = r5.w * -2 + 3.14159274;
  r0.x = cmp(r0.x < -r0.x);
  r0.x = r0.x ? r5.w : 0;
  r0.x = r2.w * r2.x + r0.x;
  r0.x = 81.4873276 * r0.x;
  r0.x = log2(r0.x);
  r0.xw = max(float2(0,0), r0.xw);
  r0.x = max(r0.w, r0.x);
  r0.x = 0.625 * r0.x;
  r0.w = 10.5 * r11.w;
  r0.x = max(r0.w, r0.x);
  r0.w = cmp(r4.z < 0);
  r2.x = r0.w ? 1.f : 0.f;
  r6.xyzw = float4(0.5,-0.5,-0.5,0.5) * r4.xyxy;
  r2.w = -r0.z * r2.z + 1;
  r2.w = max(0.00100000005, r2.w);
  r4.xy = r6.xy / r2.ww;
  r4.xy = float2(0.5,0.5) + r4.xy;
  r0.z = r0.z * r2.z + 1;
  r0.z = max(0.00100000005, r0.z);
  r2.zw = r6.zw / r0.zz;
  r2.zw = float2(0.5,0.5) + r2.zw;
  r0.zw = r0.ww ? r4.xy : r2.zw;
  r0.zw = r0.zw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
  r4.x = (int)r2.x;
  r4.y = 0;
  r0.zw = r4.xy + r0.zw;
  r6.xy = float2(0.5,0.142857149) * r0.zw;
  r2.xzw = cb12[114].xyz * v5.yyy;
  r2.xzw = cb12[113].xyz * v5.xxx + r2.xzw;
  r2.xzw = cb12[115].xyz * v5.zzz + r2.xzw;
  r2.xzw = cb12[116].xyz + r2.xzw;
  r2.xzw = float3(1,1,1) + -abs(r2.xzw);
  r0.zw = asint(cb12[117].yy) & int2(1,2);
  r0.z = r0.z ? 1 : r0.y;
  r4.x = 1 + -r0.y;
  r0.w = r0.w ? 1 : r4.x;
  r0.z = r0.z * r0.w;
  r7.xyw = cmp(float3(0,0,0) < r2.xzw);
  r0.w = r7.y ? r7.x : 0;
  r0.w = r7.w ? r0.w : 0;
  r4.y = cmp(0 < r0.z);
  r0.w = r4.y ? r0.w : 0;
  if (r0.w != 0) {
    r2.xzw = saturate(cb12[112].xyz * r2.xzw);
    r0.z = cb12[111].x * r0.z;
    r0.z = 0.999989986 * r0.z;
    r0.w = r2.x * r2.z;
    r0.w = r0.w * r2.w;
    r2.x = r0.z * r0.w;
    r0.z = r0.z * r0.w + 9.99999975e-006;
    r0.w = cb12[117].x * r2.x;
    r2.x = asint(cb12[122].x);
    r6.z = r2.x * 0.142857149 + r6.y;
    r2.xzw = t22.SampleLevel(s11_s, r6.xz, 0).xyz;
    r2.xzw = r2.xzw * r0.www;
    r7.xyw = cb12[119].xyz * r5.yyy;
    r7.xyw = cb12[118].xyz * r5.xxx + r7.xyw;
    r7.xyw = cb12[120].xyz * r5.zzz + r7.xyw;
    r9.xzw = cb12[119].xyz * v5.yyy;
    r9.xzw = cb12[118].xyz * v5.xxx + r9.xzw;
    r9.xzw = cb12[120].xyz * v5.zzz + r9.xzw;
    r9.xzw = cb12[121].xyz + r9.xzw;
    r7.xyw = float3(1,1,1) / r7.xyw;
    r10.xyz = -r9.xzw * r7.xyw + r7.xyw;
    r7.xyw = -r9.xzw * r7.xyw + -r7.xyw;
    r7.xyw = max(r10.xyz, r7.xyw);
    r4.y = min(r7.y, r7.w);
    r4.y = min(r7.x, r4.y);
    r7.xyw = r5.xyz * r4.yyy + v5.xyz;
    r7.xyw = -cb12[111].yzw + r7.xyw;
    r4.y = dot(r7.xyw, r7.xyw);
    r4.y = rsqrt(r4.y);
    r9.xzw = r7.xyw * r4.yyy;
    r4.z = cmp(r9.w < 0);
    r5.w = r4.z ? 1.f : 0.f;
    r11.xyzw = float4(0.5,-0.5,-0.5,0.5) * r9.xzxz;
    r6.z = -r7.w * r4.y + 1;
    r6.z = max(0.00100000005, r6.z);
    r7.xy = r11.xy / r6.zz;
    r7.xy = float2(0.5,0.5) + r7.xy;
    r4.y = r7.w * r4.y + 1;
    r4.y = max(0.00100000005, r4.y);
    r9.xz = r11.zw / r4.yy;
    r9.xz = float2(0.5,0.5) + r9.xz;
    r4.yz = r4.zz ? r7.xy : r9.xz;
    r4.yz = r4.yz * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
    r11.y = asint(cb12[122].x);
    r11.z = (int)r5.w;
    r11.xw = float2(0,0);
    r4.yz = r11.zw + r4.yz;
    r4.yz = r11.xy + r4.yz;
    r4.yz = float2(0.5,0.142857149) * r4.yz;
    r7.xyw = t23.SampleLevel(s11_s, r4.yz, r0.x).xyz;
    r7.xyw = r7.xyw * r0.www;
  } else {
    r2.xzw = float3(0,0,0);
    r7.xyw = float3(0,0,0);
    r0.z = 9.99999975e-006;
  }
  r0.w = cmp(r0.z < 0.999000013);
  if (r0.w != 0) {
    r9.xzw = cb12[126].xyz * v5.yyy;
    r9.xzw = cb12[125].xyz * v5.xxx + r9.xzw;
    r9.xzw = cb12[127].xyz * v5.zzz + r9.xzw;
    r9.xzw = cb12[128].xyz + r9.xzw;
    r9.xzw = float3(1,1,1) + -abs(r9.xzw);
    r4.yz = asint(cb12[129].yy) & int2(1,2);
    r4.y = r4.y ? 1 : r0.y;
    r4.z = r4.z ? 1 : r4.x;
    r4.y = r4.y * r4.z;
    r10.xyz = cmp(float3(0,0,0) < r9.xzw);
    r4.z = r10.y ? r10.x : 0;
    r4.z = r10.z ? r4.z : 0;
    r5.w = cmp(0 < r4.y);
    r4.z = r5.w ? r4.z : 0;
    if (r4.z != 0) {
      r9.xzw = saturate(cb12[124].xyz * r9.xzw);
      r4.z = 1 + -r0.z;
      r4.y = r4.z * r4.y;
      r4.y = cb12[123].x * r4.y;
      r4.z = r9.x * r9.z;
      r4.z = r4.z * r9.w;
      r5.w = r4.y * r4.z;
      r0.z = r4.y * r4.z + r0.z;
      r4.y = cb12[129].x * r5.w;
      r4.z = asint(cb12[134].x);
      r6.w = r4.z * 0.142857149 + r6.y;
      r9.xzw = t22.SampleLevel(s11_s, r6.xw, 0).xyz;
      r2.xzw = r4.yyy * r9.xzw + r2.xzw;
      r9.xzw = cb12[131].xyz * r5.yyy;
      r9.xzw = cb12[130].xyz * r5.xxx + r9.xzw;
      r9.xzw = cb12[132].xyz * r5.zzz + r9.xzw;
      r10.xyz = cb12[131].xyz * v5.yyy;
      r10.xyz = cb12[130].xyz * v5.xxx + r10.xyz;
      r10.xyz = cb12[132].xyz * v5.zzz + r10.xyz;
      r10.xyz = cb12[133].xyz + r10.xyz;
      r9.xzw = float3(1,1,1) / r9.xzw;
      r11.xyz = -r10.xyz * r9.xzw + r9.xzw;
      r9.xzw = -r10.xyz * r9.xzw + -r9.xzw;
      r9.xzw = max(r11.xyz, r9.xzw);
      r4.z = min(r9.z, r9.w);
      r4.z = min(r9.x, r4.z);
      r9.xzw = r5.xyz * r4.zzz + v5.xyz;
      r9.xzw = -cb12[123].yzw + r9.xzw;
      r4.z = dot(r9.xzw, r9.xzw);
      r4.z = rsqrt(r4.z);
      r10.xyz = r9.xzw * r4.zzz;
      r5.w = cmp(r10.z < 0);
      r6.z = r5.w ? 1.f : 0.f;
      r11.xyzw = float4(0.5,-0.5,-0.5,0.5) * r10.xyxy;
      r6.w = -r9.w * r4.z + 1;
      r6.w = max(0.00100000005, r6.w);
      r9.xz = r11.xy / r6.ww;
      r9.xz = float2(0.5,0.5) + r9.xz;
      r4.z = r9.w * r4.z + 1;
      r4.z = max(0.00100000005, r4.z);
      r10.xy = r11.zw / r4.zz;
      r10.xy = float2(0.5,0.5) + r10.xy;
      r9.xz = r5.ww ? r9.xz : r10.xy;
      r9.xz = r9.xz * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r11.y = asint(cb12[134].x);
      r11.z = (int)r6.z;
      r11.xw = float2(0,0);
      r6.zw = r11.zw + r9.xz;
      r6.zw = r11.xy + r6.zw;
      r6.zw = float2(0.5,0.142857149) * r6.zw;
      r9.xzw = t23.SampleLevel(s11_s, r6.zw, r0.x).xyz;
      r7.xyw = r4.yyy * r9.xzw + r7.xyw;
    }
  }
  r4.y = cmp(r0.z < 0.999000013);
  r0.w = r0.w ? r4.y : 0;
  if (r0.w != 0) {
    r9.xzw = cb12[138].xyz * v5.yyy;
    r9.xzw = cb12[137].xyz * v5.xxx + r9.xzw;
    r9.xzw = cb12[139].xyz * v5.zzz + r9.xzw;
    r9.xzw = cb12[140].xyz + r9.xzw;
    r9.xzw = float3(1,1,1) + -abs(r9.xzw);
    r4.yz = asint(cb12[141].yy) & int2(1,2);
    r4.y = r4.y ? 1 : r0.y;
    r4.z = r4.z ? 1 : r4.x;
    r4.y = r4.y * r4.z;
    r10.xyz = cmp(float3(0,0,0) < r9.xzw);
    r4.z = r10.y ? r10.x : 0;
    r4.z = r10.z ? r4.z : 0;
    r5.w = cmp(0 < r4.y);
    r4.z = r5.w ? r4.z : 0;
    if (r4.z != 0) {
      r9.xzw = saturate(cb12[136].xyz * r9.xzw);
      r4.z = 1 + -r0.z;
      r4.y = r4.z * r4.y;
      r4.y = cb12[135].x * r4.y;
      r4.z = r9.x * r9.z;
      r4.z = r4.z * r9.w;
      r5.w = r4.y * r4.z;
      r0.z = r4.y * r4.z + r0.z;
      r4.y = cb12[141].x * r5.w;
      r4.z = asint(cb12[146].x);
      r10.y = r4.z * 0.142857149 + r6.y;
      r10.x = r6.x;
      r9.xzw = t22.SampleLevel(s11_s, r10.xy, 0).xyz;
      r2.xzw = r4.yyy * r9.xzw + r2.xzw;
      r9.xzw = cb12[143].xyz * r5.yyy;
      r9.xzw = cb12[142].xyz * r5.xxx + r9.xzw;
      r9.xzw = cb12[144].xyz * r5.zzz + r9.xzw;
      r10.xyz = cb12[143].xyz * v5.yyy;
      r10.xyz = cb12[142].xyz * v5.xxx + r10.xyz;
      r10.xyz = cb12[144].xyz * v5.zzz + r10.xyz;
      r10.xyz = cb12[145].xyz + r10.xyz;
      r9.xzw = float3(1,1,1) / r9.xzw;
      r11.xyz = -r10.xyz * r9.xzw + r9.xzw;
      r9.xzw = -r10.xyz * r9.xzw + -r9.xzw;
      r9.xzw = max(r11.xyz, r9.xzw);
      r4.z = min(r9.z, r9.w);
      r4.z = min(r9.x, r4.z);
      r9.xzw = r5.xyz * r4.zzz + v5.xyz;
      r9.xzw = -cb12[135].yzw + r9.xzw;
      r4.z = dot(r9.xzw, r9.xzw);
      r4.z = rsqrt(r4.z);
      r10.xyz = r9.xzw * r4.zzz;
      r5.w = cmp(r10.z < 0);
      r6.z = r5.w ? 1.f : 0.f;
      r11.xyzw = float4(0.5,-0.5,-0.5,0.5) * r10.xyxy;
      r6.w = -r9.w * r4.z + 1;
      r6.w = max(0.00100000005, r6.w);
      r9.xz = r11.xy / r6.ww;
      r9.xz = float2(0.5,0.5) + r9.xz;
      r4.z = r9.w * r4.z + 1;
      r4.z = max(0.00100000005, r4.z);
      r10.xy = r11.zw / r4.zz;
      r10.xy = float2(0.5,0.5) + r10.xy;
      r9.xz = r5.ww ? r9.xz : r10.xy;
      r9.xz = r9.xz * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r11.y = asint(cb12[146].x);
      r11.z = (int)r6.z;
      r11.xw = float2(0,0);
      r6.zw = r11.zw + r9.xz;
      r6.zw = r11.xy + r6.zw;
      r6.zw = float2(0.5,0.142857149) * r6.zw;
      r9.xzw = t23.SampleLevel(s11_s, r6.zw, r0.x).xyz;
      r7.xyw = r4.yyy * r9.xzw + r7.xyw;
    }
  }
  r4.y = cmp(r0.z < 0.999000013);
  r0.w = r0.w ? r4.y : 0;
  if (r0.w != 0) {
    r9.xzw = cb12[150].xyz * v5.yyy;
    r9.xzw = cb12[149].xyz * v5.xxx + r9.xzw;
    r9.xzw = cb12[151].xyz * v5.zzz + r9.xzw;
    r9.xzw = cb12[152].xyz + r9.xzw;
    r9.xzw = float3(1,1,1) + -abs(r9.xzw);
    r4.yz = asint(cb12[153].yy) & int2(1,2);
    r4.y = r4.y ? 1 : r0.y;
    r4.z = r4.z ? 1 : r4.x;
    r4.y = r4.y * r4.z;
    r10.xyz = cmp(float3(0,0,0) < r9.xzw);
    r4.z = r10.y ? r10.x : 0;
    r4.z = r10.z ? r4.z : 0;
    r5.w = cmp(0 < r4.y);
    r4.z = r5.w ? r4.z : 0;
    if (r4.z != 0) {
      r9.xzw = saturate(cb12[148].xyz * r9.xzw);
      r4.z = 1 + -r0.z;
      r4.y = r4.z * r4.y;
      r4.y = cb12[147].x * r4.y;
      r4.z = r9.x * r9.z;
      r4.z = r4.z * r9.w;
      r5.w = r4.y * r4.z;
      r0.z = r4.y * r4.z + r0.z;
      r4.y = cb12[153].x * r5.w;
      r4.z = asint(cb12[158].x);
      r10.y = r4.z * 0.142857149 + r6.y;
      r10.x = r6.x;
      r9.xzw = t22.SampleLevel(s11_s, r10.xy, 0).xyz;
      r2.xzw = r4.yyy * r9.xzw + r2.xzw;
      r9.xzw = cb12[155].xyz * r5.yyy;
      r9.xzw = cb12[154].xyz * r5.xxx + r9.xzw;
      r9.xzw = cb12[156].xyz * r5.zzz + r9.xzw;
      r10.xyz = cb12[155].xyz * v5.yyy;
      r10.xyz = cb12[154].xyz * v5.xxx + r10.xyz;
      r10.xyz = cb12[156].xyz * v5.zzz + r10.xyz;
      r10.xyz = cb12[157].xyz + r10.xyz;
      r9.xzw = float3(1,1,1) / r9.xzw;
      r11.xyz = -r10.xyz * r9.xzw + r9.xzw;
      r9.xzw = -r10.xyz * r9.xzw + -r9.xzw;
      r9.xzw = max(r11.xyz, r9.xzw);
      r4.z = min(r9.z, r9.w);
      r4.z = min(r9.x, r4.z);
      r9.xzw = r5.xyz * r4.zzz + v5.xyz;
      r9.xzw = -cb12[147].yzw + r9.xzw;
      r4.z = dot(r9.xzw, r9.xzw);
      r4.z = rsqrt(r4.z);
      r10.xyz = r9.xzw * r4.zzz;
      r5.w = cmp(r10.z < 0);
      r6.z = r5.w ? 1.f : 0.f;
      r11.xyzw = float4(0.5,-0.5,-0.5,0.5) * r10.xyxy;
      r6.w = -r9.w * r4.z + 1;
      r6.w = max(0.00100000005, r6.w);
      r9.xz = r11.xy / r6.ww;
      r9.xz = float2(0.5,0.5) + r9.xz;
      r4.z = r9.w * r4.z + 1;
      r4.z = max(0.00100000005, r4.z);
      r10.xy = r11.zw / r4.zz;
      r10.xy = float2(0.5,0.5) + r10.xy;
      r9.xz = r5.ww ? r9.xz : r10.xy;
      r9.xz = r9.xz * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r11.y = asint(cb12[158].x);
      r11.z = (int)r6.z;
      r11.xw = float2(0,0);
      r6.zw = r11.zw + r9.xz;
      r6.zw = r11.xy + r6.zw;
      r6.zw = float2(0.5,0.142857149) * r6.zw;
      r9.xzw = t23.SampleLevel(s11_s, r6.zw, r0.x).xyz;
      r7.xyw = r4.yyy * r9.xzw + r7.xyw;
    }
  }
  r4.y = cmp(r0.z < 0.999000013);
  r0.w = r0.w ? r4.y : 0;
  if (r0.w != 0) {
    r9.xzw = cb12[162].xyz * v5.yyy;
    r9.xzw = cb12[161].xyz * v5.xxx + r9.xzw;
    r9.xzw = cb12[163].xyz * v5.zzz + r9.xzw;
    r9.xzw = cb12[164].xyz + r9.xzw;
    r9.xzw = float3(1,1,1) + -abs(r9.xzw);
    r4.yz = asint(cb12[165].yy) & int2(1,2);
    r4.y = r4.y ? 1 : r0.y;
    r4.z = r4.z ? 1 : r4.x;
    r4.y = r4.y * r4.z;
    r10.xyz = cmp(float3(0,0,0) < r9.xzw);
    r4.z = r10.y ? r10.x : 0;
    r4.z = r10.z ? r4.z : 0;
    r5.w = cmp(0 < r4.y);
    r4.z = r5.w ? r4.z : 0;
    if (r4.z != 0) {
      r9.xzw = saturate(cb12[160].xyz * r9.xzw);
      r4.z = 1 + -r0.z;
      r4.y = r4.z * r4.y;
      r4.y = cb12[159].x * r4.y;
      r4.z = r9.x * r9.z;
      r4.z = r4.z * r9.w;
      r5.w = r4.y * r4.z;
      r0.z = r4.y * r4.z + r0.z;
      r4.y = cb12[165].x * r5.w;
      r4.z = asint(cb12[170].x);
      r10.y = r4.z * 0.142857149 + r6.y;
      r10.x = r6.x;
      r9.xzw = t22.SampleLevel(s11_s, r10.xy, 0).xyz;
      r2.xzw = r4.yyy * r9.xzw + r2.xzw;
      r9.xzw = cb12[167].xyz * r5.yyy;
      r9.xzw = cb12[166].xyz * r5.xxx + r9.xzw;
      r9.xzw = cb12[168].xyz * r5.zzz + r9.xzw;
      r10.xyz = cb12[167].xyz * v5.yyy;
      r10.xyz = cb12[166].xyz * v5.xxx + r10.xyz;
      r10.xyz = cb12[168].xyz * v5.zzz + r10.xyz;
      r10.xyz = cb12[169].xyz + r10.xyz;
      r9.xzw = float3(1,1,1) / r9.xzw;
      r11.xyz = -r10.xyz * r9.xzw + r9.xzw;
      r9.xzw = -r10.xyz * r9.xzw + -r9.xzw;
      r9.xzw = max(r11.xyz, r9.xzw);
      r4.z = min(r9.z, r9.w);
      r4.z = min(r9.x, r4.z);
      r9.xzw = r5.xyz * r4.zzz + v5.xyz;
      r9.xzw = -cb12[159].yzw + r9.xzw;
      r4.z = dot(r9.xzw, r9.xzw);
      r4.z = rsqrt(r4.z);
      r10.xyz = r9.xzw * r4.zzz;
      r5.w = cmp(r10.z < 0);
      r6.z = r5.w ? 1.f : 0.f;
      r11.xyzw = float4(0.5,-0.5,-0.5,0.5) * r10.xyxy;
      r6.w = -r9.w * r4.z + 1;
      r6.w = max(0.00100000005, r6.w);
      r9.xz = r11.xy / r6.ww;
      r9.xz = float2(0.5,0.5) + r9.xz;
      r4.z = r9.w * r4.z + 1;
      r4.z = max(0.00100000005, r4.z);
      r10.xy = r11.zw / r4.zz;
      r10.xy = float2(0.5,0.5) + r10.xy;
      r9.xz = r5.ww ? r9.xz : r10.xy;
      r9.xz = r9.xz * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r11.y = asint(cb12[170].x);
      r11.z = (int)r6.z;
      r11.xw = float2(0,0);
      r6.zw = r11.zw + r9.xz;
      r6.zw = r11.xy + r6.zw;
      r6.zw = float2(0.5,0.142857149) * r6.zw;
      r9.xzw = t23.SampleLevel(s11_s, r6.zw, r0.x).xyz;
      r7.xyw = r4.yyy * r9.xzw + r7.xyw;
    }
  }
  r4.y = cmp(r0.z < 0.999000013);
  r0.w = r0.w ? r4.y : 0;
  if (r0.w != 0) {
    r9.xzw = cb12[174].xyz * v5.yyy;
    r9.xzw = cb12[173].xyz * v5.xxx + r9.xzw;
    r9.xzw = cb12[175].xyz * v5.zzz + r9.xzw;
    r9.xzw = cb12[176].xyz + r9.xzw;
    r9.xzw = float3(1,1,1) + -abs(r9.xzw);
    r4.yz = asint(cb12[177].yy) & int2(1,2);
    r0.y = r4.y ? 1 : r0.y;
    r0.w = r4.z ? 1 : r4.x;
    r0.y = r0.y * r0.w;
    r4.xyz = cmp(float3(0,0,0) < r9.xzw);
    r0.w = r4.y ? r4.x : 0;
    r0.w = r4.z ? r0.w : 0;
    r4.x = cmp(0 < r0.y);
    r0.w = r4.x ? r0.w : 0;
    if (r0.w != 0) {
      r4.xyz = saturate(cb12[172].xyz * r9.xzw);
      r0.w = 1 + -r0.z;
      r0.y = r0.w * r0.y;
      r0.y = cb12[171].x * r0.y;
      r0.w = r4.x * r4.y;
      r0.w = r0.w * r4.z;
      r4.x = r0.y * r0.w;
      r0.z = r0.y * r0.w + r0.z;
      r0.y = cb12[177].x * r4.x;
      r0.w = asint(cb12[182].x);
      r4.y = r0.w * 0.142857149 + r6.y;
      r4.x = r6.x;
      r4.xyz = t22.SampleLevel(s11_s, r4.xy, 0).xyz;
      r2.xzw = r0.yyy * r4.xyz + r2.xzw;
      r4.xyz = cb12[179].xyz * r5.yyy;
      r4.xyz = cb12[178].xyz * r5.xxx + r4.xyz;
      r4.xyz = cb12[180].xyz * r5.zzz + r4.xyz;
      r9.xzw = cb12[179].xyz * v5.yyy;
      r9.xzw = cb12[178].xyz * v5.xxx + r9.xzw;
      r9.xzw = cb12[180].xyz * v5.zzz + r9.xzw;
      r9.xzw = cb12[181].xyz + r9.xzw;
      r4.xyz = float3(1,1,1) / r4.xyz;
      r10.xyz = -r9.xzw * r4.xyz + r4.xyz;
      r4.xyz = -r9.xzw * r4.xyz + -r4.xyz;
      r4.xyz = max(r10.xyz, r4.xyz);
      r0.w = min(r4.y, r4.z);
      r0.w = min(r4.x, r0.w);
      r4.xyz = r5.xyz * r0.www + v5.xyz;
      r4.xyz = -cb12[171].yzw + r4.xyz;
      r0.w = dot(r4.xyz, r4.xyz);
      r0.w = rsqrt(r0.w);
      r9.xzw = r4.xyz * r0.www;
      r4.x = cmp(r9.w < 0);
      r4.y = r4.x ? 1.f : 0.f;
      r11.xyzw = float4(0.5,-0.5,-0.5,0.5) * r9.xzxz;
      r5.w = -r4.z * r0.w + 1;
      r5.w = max(0.00100000005, r5.w);
      r6.zw = r11.xy / r5.ww;
      r6.zw = float2(0.5,0.5) + r6.zw;
      r0.w = r4.z * r0.w + 1;
      r0.w = max(0.00100000005, r0.w);
      r9.xz = r11.zw / r0.ww;
      r9.xz = float2(0.5,0.5) + r9.xz;
      r4.xz = r4.xx ? r6.zw : r9.xz;
      r4.xz = r4.xz * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r11.y = asint(cb12[182].x);
      r11.z = (int)r4.y;
      r11.xw = float2(0,0);
      r4.xy = r11.zw + r4.xz;
      r4.xy = r11.xy + r4.xy;
      r4.xy = float2(0.5,0.142857149) * r4.xy;
      r4.xyz = t23.SampleLevel(s11_s, r4.xy, r0.x).xyz;
      r7.xyw = r0.yyy * r4.xyz + r7.xyw;
    }
  }
  r0.y = cmp(r0.z < 0.999000013);
  if (r0.y != 0) {
    r0.y = 1 + -r0.z;
    r0.w = cb12[99].x * r0.y;
    r0.z = r0.y * cb12[99].x + r0.z;
    r0.y = cb12[105].x * r0.w;
    r0.w = asint(cb12[110].x);
    r6.y = r0.w * 0.142857149 + r6.y;
    r4.xyz = t22.SampleLevel(s11_s, r6.xy, 0).xyz;
    r2.xzw = r0.yyy * r4.xyz + r2.xzw;
    r0.w = cmp(r5.z < 0);
    r4.x = r0.w ? 1.f : 0.f;
    r6.xyzw = float4(0.5,-0.5,-0.5,0.5) * r5.xyxy;
    r4.y = 1 + -r5.z;
    r4.y = max(0.00100000005, r4.y);
    r4.yz = r6.xy / r4.yy;
    r4.yz = float2(0.5,0.5) + r4.yz;
    r5.x = 1 + r5.z;
    r5.x = max(0.00100000005, r5.x);
    r5.xy = r6.zw / r5.xx;
    r5.xy = float2(0.5,0.5) + r5.xy;
    r4.yz = r0.ww ? r4.yz : r5.xy;
    r4.yz = r4.yz * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
    r5.y = asint(cb12[110].x);
    r5.z = (int)r4.x;
    r5.xw = float2(0,0);
    r4.xy = r5.zw + r4.yz;
    r4.xy = r5.xy + r4.xy;
    r4.xy = float2(0.5,0.142857149) * r4.xy;
    r4.xyz = t23.SampleLevel(s11_s, r4.xy, r0.x).xyz;
    r7.xyw = r0.yyy * r4.xyz + r7.xyw;
  }
  r0.x = 1 / r0.z;
  r0.yzw = r2.xzw * r0.xxx;
  r2.xzw = r7.xyw * r0.xxx;
  r0.x = abs(cb2[16].x) + -cb2[16].y;
  r4.xyz = r3.yzw * r0.xxx + cb2[16].yyy;
  r0.x = cb2[16].z + -cb2[16].w;
  r5.xyz = r3.yzw * r0.xxx + cb2[16].www;
  r0.xyz = r4.xyz * r0.yzw;
  r2.xzw = r5.xyz * r2.xzw;
  r0.w = dot(r8.xy, r8.xy);
  r0.w = sqrt(r0.w);
  r0.w = saturate(r0.w * cb12[218].x + cb12[218].y);
  r4.x = -1 + cb12[184].z;
  r0.w = r0.w * r4.x + 1;
  r4.x = cb12[183].x + -cb12[183].y;
  r4.xyz = r3.yzw * r4.xxx + cb12[183].yyy;
  r4.xyz = r4.xyz * r0.www;
  r5.x = cb12[184].x + -cb12[184].y;
  r3.yzw = r3.yzw * r5.xxx + cb12[184].yyy;
  r3.yzw = r3.yzw * r0.www;
  r5.xyz = cb12[183].zzz * r14.xyz;
  r6.xyz = cb12[183].www * r15.xyz;
  r0.xyz = r4.xyz * r0.xyz;
  r0.w = max(abs(r10.w), abs(r10.w));
  r0.w = 1 + -r0.w;
  r0.w = max(0, r0.w);
  r4.x = r0.w * r0.w;
  r4.x = r4.x * r4.x;
  r0.w = r4.x * r0.w;
  r4.x = min(1, cb13[56].y);
  r4.x = r4.x * r7.z;
  r0.w = r4.x * r0.w;
  r0.w = r0.w / r9.y;
  r0.w = r2.y + r0.w;
  r2.y = 1 + -r0.w;
  r0.xyz = r2.yyy * r0.xyz;
  r2.xyz = r3.yzw * r2.xzw;
  r2.xyz = r2.xyz * r0.www;
  r0.w = cb12[69].x + cb12[69].y;
  r3.yzw = r5.xyz * r0.www;
  r4.xyz = r6.xyz * r0.www;
  r0.xyz = r0.xyz * r3.xxx + r3.yzw;
  r0.xyz = r1.xyz * r0.xyz + r4.xyz;
  r0.xyz = r2.xyz * r3.xxx + r0.xyz;
  r1.xyz = r8.xyz / r4.www;
  r0.w = -cb12[22].z + r4.w;
  r0.w = max(0, r0.w);
  r0.w = min(cb12[42].z, r0.w);
  r1.x = dot(cb12[38].xyz, r1.xyz);
  r1.y = abs(r1.x) * abs(r1.x);
  r2.x = saturate(r0.w * 0.00200000009 + -0.300000012);
  r1.y = r2.x * r1.y;
  r2.x = cmp(0 < r1.x);
  r2.yzw = r2.xxx ? cb12[39].xyz : cb12[41].xyz;
  r2.yzw = -cb12[40].xyz + r2.yzw;
  r2.yzw = r1.yyy * r2.yzw + cb12[40].xyz;
  r3.xyz = r2.xxx ? cb12[45].xyz : cb12[47].xyz;
  r3.xyz = -cb12[46].xyz + r3.xyz;
  r3.xyz = r1.yyy * r3.xyz + cb12[46].xyz;
  r1.y = cmp(r0.w >= cb12[48].y);
  if (r1.y != 0) {
    r1.y = r1.z * cb12[22].z + cb12[0].z;
    r1.z = r1.z * r0.w;
    r1.z = 0.0625 * r1.z;
    r2.x = cb12[43].x * r0.w;
    r2.x = 0.0625 * r2.x;
    r1.x = cb12[42].x + r1.x;
    r3.w = 1 + cb12[42].x;
    r1.x = saturate(r1.x / r3.w);
    r3.w = cb12[43].y + -cb12[43].z;
    r1.x = r1.x * r3.w + cb12[43].z;
    r1.y = cb12[42].y + r1.y;
    r3.w = r1.y * r1.x;
    r1.z = r1.z * r1.x;
    r4.xyzw = r1.zzzz * float4(16,15,14,13) + r3.wwww;
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.xxxx / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r4.x = r4.x * r4.y;
    r4.x = r4.x * r4.z;
    r4.x = r4.x * r4.w;
    r5.xyzw = r1.zzzz * float4(12,11,10,9) + r3.wwww;
    r5.xyzw = max(float4(0,0,0,0), r5.xyzw);
    r5.xyzw = float4(1,1,1,1) + r5.xyzw;
    r5.xyzw = saturate(r2.xxxx / r5.xyzw);
    r5.xyzw = float4(1,1,1,1) + -r5.xyzw;
    r4.x = r5.x * r4.x;
    r4.x = r4.x * r5.y;
    r4.x = r4.x * r5.z;
    r4.x = r4.x * r5.w;
    r5.xyzw = r1.zzzz * float4(8,7,6,5) + r3.wwww;
    r5.xyzw = max(float4(0,0,0,0), r5.xyzw);
    r5.xyzw = float4(1,1,1,1) + r5.xyzw;
    r5.xyzw = saturate(r2.xxxx / r5.xyzw);
    r5.xyzw = float4(1,1,1,1) + -r5.xyzw;
    r4.x = r5.x * r4.x;
    r4.x = r4.x * r5.y;
    r4.x = r4.x * r5.z;
    r4.x = r4.x * r5.w;
    r4.yz = r1.zz * float2(4,3) + r3.ww;
    r4.yz = max(float2(0,0), r4.yz);
    r4.yz = float2(1,1) + r4.yz;
    r4.yz = saturate(r2.xx / r4.yz);
    r4.yz = float2(1,1) + -r4.yz;
    r4.x = r4.x * r4.y;
    r4.x = r4.x * r4.z;
    r3.w = r1.z * 2 + r3.w;
    r3.w = max(0, r3.w);
    r3.w = 1 + r3.w;
    r3.w = saturate(r2.x / r3.w);
    r3.w = 1 + -r3.w;
    r3.w = r4.x * r3.w;
    r1.x = r1.y * r1.x + r1.z;
    r1.x = max(0, r1.x);
    r1.x = 1 + r1.x;
    r1.x = saturate(r2.x / r1.x);
    r1.x = 1 + -r1.x;
    r1.x = -r3.w * r1.x + 1;
    r0.w = -cb12[48].y + r0.w;
    r0.w = saturate(cb12[48].z * r0.w);
  } else {
    r1.x = 1;
    r0.w = 0;
  }
  r1.x = log2(r1.x);
  r1.y = cb12[42].w * r1.x;
  r1.y = exp2(r1.y);
  r1.y = r1.y * r0.w;
  r1.x = cb12[48].x * r1.x;
  r1.x = exp2(r1.x);
  r0.w = r1.x * r0.w;
  r1.xz = saturate(r1.yy * cb12[189].xz + cb12[189].yw);
  r4.xyz = cb12[188].xyz + -r2.yzw;
  r4.xyz = r1.xxx * r4.xyz + r2.yzw;
  r1.x = -1 + cb12[188].w;
  r1.x = r1.z * r1.x + 1;
  r4.w = saturate(r1.y * r1.x);
  r1.x = cmp(0 < cb12[192].x);
  if (r1.x != 0) {
    r1.xz = saturate(r1.yy * cb12[191].xz + cb12[191].yw);
    r5.xyz = cb12[190].xyz + -r2.yzw;
    r2.xyz = r1.xxx * r5.xyz + r2.yzw;
    r1.x = -1 + cb12[190].w;
    r1.x = r1.z * r1.x + 1;
    r2.w = saturate(r1.y * r1.x);
    r2.xyzw = r2.xyzw + -r4.xyzw;
    r4.xyzw = cb12[192].xxxx * r2.xyzw + r4.xyzw;
  }
  r1.x = dot(float3(0.333000004,0.555000007,0.222000003), r0.xyz);
  r1.xyz = r1.xxx * r3.xyz + -r0.xyz;
  r0.xyz = r0.www * r1.xyz + r0.xyz;
  r1.xyz = r4.xyz + -r0.xyz;
  r0.xyz = r4.www * r1.xyz + r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r0.xyz * r0.www;
  r0.w = dot(r0.xyz, float3(0.298999995,0.587000012,0.114));
  r0.w = saturate(cb4[7].x * r0.w + r1.w);
  r1.xyz = min(r1.xyz, r0.xyz);
  r0.xyz = -r1.xyz + r0.xyz;
  r0.xyz = r1.www * r0.xyz + r1.xyz;
  r0.xyz = cb2[2].xyz * r0.xyz;
  r0.w = cb2[2].w * r0.w;
  r1.x = dot(float3(0.333000004,0.555000007,0.222000003), r0.xyz);
  r1.xyz = r1.xxx * v0.xyz + -r0.xyz;
  r0.xyz = v0.www * r1.xyz + r0.xyz;
  r1.xyz = v1.xyz + -r0.xyz;
  r0.xyz = v1.www * r1.xyz + r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r0.w;
  return;
}
