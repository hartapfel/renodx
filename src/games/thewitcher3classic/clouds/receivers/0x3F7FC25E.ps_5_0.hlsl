#include "../shadow_inputs.hlsli"
ByteAddressBuffer Raw21 : register(t21);
ByteAddressBuffer Raw20 : register(t20);
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 31 15:08:28 2026
Texture2D<float4> t24 : register(t24);

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t22 : register(t22);

Texture2DArray<float4> t19 : register(t19);

Texture2D<float4> t18 : register(t18);

Texture2DArray<float4> t14 : register(t14);

Texture2D<float4> t12 : register(t12);

TextureCubeArray<float4> t10 : register(t10);

Texture2DArray<float4> t9 : register(t9);

Texture2DArray<float4> t8 : register(t8);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s14_s : register(s14);

SamplerState s12_s : register(s12);

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
  float4 cb2[19];
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
  float4 v6 : TEXCOORD6,
  float4 v7 : TEXCOORD7,
  float3 v8 : TEXCOORD8,
  float4 v9 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = cmp(cb2[18].yzw != float3(0,0,0));
  if (r0.x != 0) {
    r1.xyzw = float4(16,16,16,16) * v9.xyxy;
    r1.xyzw = cmp(r1.xyzw >= -r1.zwzw);
    r1.xyzw = r1.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r0.xw = v9.xy * r1.zw;
    r0.xw = frac(r0.xw);
    r0.xw = r1.xy * r0.xw;
    r1.xy = (int2)r0.xw;
    r1.zw = float2(0,0);
    r0.x = t18.Load(r1.xyz).x;
    r0.x = r0.x * v2.x + v2.y;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  if (r0.y != 0) {
    r0.x = t12.Sample(s12_s, v4.zw).x;
    r0.x = r0.x * v2.z + v2.w;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  if (r0.z != 0) {
    r0.x = dot(v1.xyz, v1.xyz);
    r0.x = -1 + r0.x;
    r0.x = cmp(r0.x < 0);
    if (r0.x != 0) discard;
  }
  r0.xyzw = t0.Sample(s0_s, v4.xy).xyzw;
  r0.xyz = float3(-0.5,-0.5,-0.5) + r0.xyz;
  r0.xyz = r0.xyz + r0.xyz;
  r1.xyz = v6.xyz * r0.yyy;
  r1.xyz = v8.xyz * r0.xxx + r1.xyz;
  r0.xyz = v7.xyz * r0.zzz + r1.xyz;
  r1.xyzw = t1.Sample(s0_s, v4.xy).xyzw;
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
  r3.xyzw = (uint4)v9.xyxy;
  r2.z = dot(r0.xyz, r0.xyz);
  r2.z = rsqrt(r2.z);
  r4.xyz = r2.zzz * r0.xyz;
  r5.xyzw = (uint4)r3.zwzw >> int4(4,4,5,5);
  r0.xy = (int2)cb12[24].xz;
  r0.xy = mad((int2)r5.yw, (int2)r0.xy, (int2)r5.xz);
  r0.x = (uint)r0.x << 8;
  r5.x = v5.w;
  r5.y = v6.w;
  r5.z = v7.w;
  r6.xyz = cb12[0].xyz + -r5.xyz;
  r2.w = dot(r6.xyz, r6.xyz);
  r2.w = rsqrt(r2.w);
  r7.xyz = r6.xyz * r2.www;
  r8.xy = (int2)r3.zw ^ int2(2,2);
  r8.zw = max((int2)-r3.zw, (int2)r3.xy);
  r8.zw = (uint2)r8.zw >> int2(1,1);
  r9.xy = -(int2)r8.zw;
  r8.xy = (int2)r8.xy & int2(0x80000000,0x80000000);
  r8.xy = r8.xy ? r9.xy : r8.zw;
  r8.zw = float2(0,0);
  r8.xy = t24.Load(r8.xyz).xy;
  r9.xyz = -cb12[0].xyz + r5.xyz;
  r4.w = dot(r9.xyz, r9.xyz);
  r4.w = sqrt(r4.w);
  r10.x = cb12[1].z;
  r10.y = cb12[2].z;
  r10.z = cb12[3].z;
  r5.w = dot(r10.xyz, r9.xyz);
  r6.w = 1 / cb12[21].y;
  r6.w = r6.w * r4.w;
  r5.w = r6.w / r5.w;
  r5.w = -r5.w + r4.w;
  r5.w = saturate(cb13[33].w * r5.w);
  r5.w = cb13[33].z * r5.w;
  r5.w = max(0.00100000005, r5.w);
  r6.w = r4.w / cb13[34].z;
  r7.w = cmp(r8.x < r8.y);
  if (r7.w != 0) {
    r7.w = cmp(r6.w < r8.x);
    r8.z = cmp(r8.y < r6.w);
    r8.w = cb13[34].z * r8.x + -cb13[34].x;
    r8.w = saturate(-r8.w * cb13[34].y + 1);
    r9.w = r6.w + -r8.x;
    r9.w = cb13[34].z * r9.w;
    r9.w = saturate(r9.w / r5.w);
    r10.y = r9.w * r8.w;
    r7.w = (int)r7.w | (int)r8.z;
    r10.x = 1;
    r8.zw = r7.ww ? float2(0,1) : r10.xy;
  } else {
    r7.w = cmp(r8.y < r8.x);
    r9.w = cmp(r6.w < r8.y);
    r10.x = cmp(r8.x < r6.w);
    r8.x = cb13[34].z * r8.x + -cb13[34].x;
    r11.y = saturate(-r8.x * cb13[34].y + 1);
    r6.w = r6.w + -r8.y;
    r6.w = cb13[34].z * r6.w;
    r5.w = saturate(r6.w / r5.w);
    r11.w = 1 + -r5.w;
    r11.xz = float2(1,1);
    r8.xy = r10.xx ? r11.xy : r11.zw;
    r8.xy = r9.ww ? float2(1,1) : r8.xy;
    r8.zw = r7.ww ? r8.xy : float2(0,1);
  }
  r5.w = -r8.w * r8.z + 1;
  r8.xy = (int2)r3.zw & int2(1,1);
  r8.zw = r8.yy ? float2(1.40129846e-045,4.20389539e-045) : float2(2.80259693e-045,0);
  r6.w = r8.x ? r8.z : r8.w;
  if (1 == 0) r3.x = 0; else if (1+1 < 32) {   r3.x = (uint)r3.x << (32-(1 + 1)); r3.x = (uint)r3.x >> (32-1);  } else r3.x = (uint)r3.x >> 1;
  if (1 == 0) r3.y = 0; else if (1+1 < 32) {   r3.y = (uint)r3.y << (32-(1 + 1)); r3.y = (uint)r3.y >> (32-1);  } else r3.y = (uint)r3.y >> 1;
  if (1 == 0) r3.z = 0; else if (1+2 < 32) {   r3.z = (uint)r3.z << (32-(1 + 2)); r3.z = (uint)r3.z >> (32-1);  } else r3.z = (uint)r3.z >> 2;
  if (1 == 0) r3.w = 0; else if (1+2 < 32) {   r3.w = (uint)r3.w << (32-(1 + 2)); r3.w = (uint)r3.w >> (32-1);  } else r3.w = (uint)r3.w >> 2;
  r10.xyzw = r3.yyww ? float4(1,3,1,3) : float4(2,0,2,0);
  r3.xy = r3.xz ? r10.xz : r10.yw;
  r3.z = (uint)r6.w << 4;
  r3.x = mad((int)r3.x, 4, (int)r3.z);
  r3.x = (int)r3.x + (int)r3.y;
  r3.x = (int)r3.x;
  r3.x = 0.5 + r3.x;
  r3.y = 0.015625 * r3.x;
  r10.xyz = cb12[2].xyz * v6.www;
  r10.xyz = cb12[1].xyz * v5.www + r10.xyz;
  r10.xyz = cb12[3].xyz * v7.www + r10.xyz;
  r10.xyz = cb12[4].xyz + r10.xyz;
  r3.x = -r3.x * 0.015625 + 1;
  r10.w = 1;
  r11.xzw = float3(0,0,0);
  r12.xyzw = float4(0,0,0,0);
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
    r13.x = dot(r10.xyzw, cb13[r3.w+2363].xyzw);
    r13.y = dot(r10.xyzw, cb13[r3.w+2364].xyzw);
    r13.z = dot(r10.xyzw, cb13[r3.w+2365].xyzw);
    r14.xyz = cmp(abs(r13.xyz) < float3(1,1,1));
    r6.w = r14.y ? r14.x : 0;
    r6.w = r14.z ? r6.w : 0;
    if (r6.w != 0) {
      r6.w = asuint(cb13[r3.w+2366].w) >> 16;
      r6.w = (uint)r6.w;
      r6.w = 1.52590219e-005 * r6.w;
      r7.w = 0x0000ffff & asint(cb13[r3.w+2366].w);
      r7.w = (uint)r7.w;
      r7.w = 1.52590219e-005 * r7.w;
      r8.z = dot(r13.xyz, r13.xyz);
      r8.z = sqrt(r8.z);
      r8.z = 1 + -r8.z;
      r8.z = max(0, r8.z);
      r8.zw = cb13[r3.w+2367].wx * r8.zz;
      r8.z = saturate(r8.z);
      r9.w = cmp(-1.000000 == cb13[r3.w+2367].w);
      r13.x = cmp(r6.w >= r3.x);
      r11.y = r13.x ? 1.000000 : 0;
      r6.w = cmp(r6.w >= r3.y);
      r6.w = r6.w ? 1.000000 : 0;
      r13.x = r7.w * r6.w;
      r13.y = min(0.998037279, r8.w);
      r13.zw = cb13[r3.w+2367].yz * r8.zz;
      r13.xyzw = r9.wwww ? r11.xyzw : r13.xyzw;
      r12.xyzw = max(r12.xyzw, r13.xyzw);
    }
    r3.z = (int)r3.z + 1;
  }
  r0.y = r12.y * r12.y;
  r3.x = cmp(0 < r12.x);
  r3.y = r3.x ? 0 : 1;
  r3.z = r5.w * r5.w;
  r3.y = min(r3.y, r3.z);
  r0.y = max(r3.y, r0.y);
  r0.y = 1 + -r0.y;
  r3.y = 1 + -r12.x;
  r3.z = 1 + -cb13[33].y;
  r3.x = r3.x ? r3.y : r3.z;
  r3.yz = float2(1,1) + -r12.zw;
  r3.x = min(r3.x, r3.y);
  r3.x = r3.x + -r3.z;
  r3.x = saturate(r0.y * r3.x + r3.z);
  r0.y = saturate(1 + -r0.y);
  r3.y = cmp(0 < asint(cb13[35].x));
  if (r3.y != 0) {
    r3.yz = -cb12[0].xy + r5.xy;
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
      r10.y = 0;
      r8.zw = float2(0,0);
      r3.w = 0;
      while (true) {
        r5.w = cmp((int)r8.w >= asint(cb13[35].x));
        r3.w = 0;
        if (r5.w != 0) break;
        r10.zw = -cb13[r8.w+39].xy + r5.xy;
        r11.xy = cb13[r8.w+39].zw * r10.zw;
        r12.xy = cmp(r11.xy >= float2(0,0));
        r5.w = r12.y ? r12.x : 0;
        r12.xy = cmp(float2(1,1) >= r11.xy);
        r5.w = r5.w ? r12.x : 0;
        r5.w = r12.y ? r5.w : 0;
        if (r5.w != 0) {
          r11.z = (int)r8.w;
          r11.w = -r10.w * cb13[r8.w+39].w + 1;
          r6.w = t19.SampleLevel(s10_s, r11.xwz, 0).x;
          r6.w = cb13[38].x * r6.w + cb13[38].y;
          r6.w = -v7.w + r6.w;
          r6.w = -0.100000001 + r6.w;
          r6.w = saturate(r6.w * r3.z);
          r6.w = 1 + -r6.w;
          r7.w = 1 + -r6.w;
          r8.z = r3.y * r7.w + r6.w;
          r3.w = -1;
          break;
        }
        r10.x = (int)r8.w + 1;
        r8.zw = r10.yx;
        r3.w = r5.w;
      }
    } else {
      r3.w = 0;
    }
  } else {
    r3.w = 0;
  }
  r3.y = r3.w ? r8.z : 1;
  r3.z = cmp(0 < r3.y);
  if (r3.z != 0) {
    r10.xyz = cb13[5].xyz * v6.www;
    r10.xyz = cb13[4].xyz * v5.www + r10.xyz;
    r10.xyz = cb13[6].xyz * v7.www + r10.xyz;
    r10.xyz = cb13[7].xyz + r10.xyz;
    r3.z = cmp(abs(r10.z) >= 0.999000013);
    if (r3.z != 0) {
      r3.w = 1;
    }
    if (r3.z == 0) {
      r11.xyzw = -cb13[8].xyzw + r10.xxxx;
      r12.xyzw = -cb13[9].xyzw + r10.yyyy;
      r11.xyzw = max(abs(r12.xyzw), abs(r11.xyzw));
      r12.xyzw = cmp(r11.xyzw < cb13[10].xyzw);
      r12.xyzw = r12.xyzw ? float4(1,1,1,1) : 0;
      r13.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb13[15].zzzz);
      r13.xyzw = r13.xyzw ? float4(1,1,1,1) : 0;
      r3.z = dot(r12.xyzw, r13.xyzw);
      r5.w = cmp(r3.z < 0.5);
      if (r5.w != 0) {
        r3.w = 1;
      }
      if (r5.w == 0) {
        r11.xyzw = r11.xyzw / cb13[10].xyzw;
        r12.xyzw = float4(1,1,1,1) + -cb13[17].xyzw;
        r11.xyzw = -r12.xyzw + r11.xyzw;
        r11.xyzw = saturate(r11.xyzw / cb13[17].xyzw);
        r3.z = cb13[15].z + -r3.z;
        r6.w = (int)r3.z;
        r7.w = (int)cb13[15].z;
        r7.w = (int)r7.w + -1;
        r8.zw = cb13[r6.w+11].zz * float2(1,-1);
        r12.xy = r10.xy * r8.zw + cb13[r6.w+11].xy;
        r12.z = trunc(r3.z);
        r3.z = cmp(asint(cb13[18].x) >= 1);
        if (r3.z != 0) {
          r3.z = t8.SampleCmpLevelZero(s9_s, r12.xyz, r10.z).x;
          r13.xyzw = cb13[r6.w+11].wwww * float4(-0.263353914,0.0396538191,-0.717202425,0.368303299) + r12.xyxy;
          r14.xy = r13.xy;
          r14.z = r12.z;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(-0.0199530609,-0.398839206,-0.440993786,-0.22101) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(0.220039204,0.294344813,-0.767565727,-0.148275301) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(-0.2381019,0.547106206,0.217303097,-0.134587899) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(-0.638777375,0.756133914,-0.1614144,0.977652073) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(0.215631902,0.612341285,0.232887506,0.945287228) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(-0.944064379,0.123607703,-0.740823686,-0.507682979) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(-0.411301911,-0.890596688,-0.248642907,-0.621399283) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(0.696784973,0.264493704,0.539436281,0.817321479) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(0.615120828,-0.149864003,0.0936533585,-0.78174752) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(0.276806712,-0.489596814,0.663918078,-0.600717187) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(0.388036907,-0.895089388,0.991614401,-0.0793915167) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r13.xyzw = cb13[r6.w+11].wwww * float4(0.783184826,0.602934778,0.899860322,-0.398354292) + r12.xyxy;
          r14.xy = r13.xy;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r3.z = r8.z + r3.z;
          r3.z = 0.0370370373 * r3.z;
          r3.z = r3.z * r3.z;
        } else {
          r8.z = t8.SampleCmpLevelZero(s9_s, r12.xyz, r10.z).x;
          r13.xyzw = cb13[r6.w+11].wwww * float4(-0.507720828,-0.617089927,-0.0515490212,-0.750809789) + r12.xyxy;
          r14.xy = r13.xy;
          r14.z = r12.z;
          r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r8.z = r8.z + r8.w;
          r14.xy = r13.zw;
          r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r8.z = r8.z + r8.w;
          r13.xyzw = cb13[r6.w+11].wwww * float4(-0.764104187,0.200915202,0.00728477398,-0.205946997) + r12.xyxy;
          r14.xy = r13.xy;
          r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r8.z = r8.z + r8.w;
          r14.xy = r13.zw;
          r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r8.z = r8.z + r8.w;
          r13.xyzw = cb13[r6.w+11].wwww * float4(-0.366203994,0.732379675,-0.923958182,-0.255964309) + r12.xyxy;
          r14.xy = r13.xy;
          r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r8.z = r8.z + r8.w;
          r14.xy = r13.zw;
          r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r8.z = r8.z + r8.w;
          r13.xyzw = cb13[r6.w+11].wwww * float4(-0.286924005,0.278052986,0.772301197,0.157332897) + r12.xyxy;
          r14.xy = r13.xy;
          r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r8.z = r8.z + r8.w;
          r14.xy = r13.zw;
          r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r8.z = r8.z + r8.w;
          r13.xyzw = cb13[r6.w+11].wwww * float4(0.378513008,0.405219913,0.463021696,-0.691461921) + r12.xyxy;
          r14.xy = r13.xy;
          r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r8.z = r8.z + r8.w;
          r14.xy = r13.zw;
          r8.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r8.z = r8.z + r8.w;
          r13.xyzw = cb13[r6.w+11].wwww * float4(0.423523009,0.86302799,0.855864286,-0.338255405) + r12.xyxy;
          r14.xy = r13.xy;
          r6.w = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r6.w = r8.z + r6.w;
          r14.xy = r13.zw;
          r8.z = t8.SampleCmpLevelZero(s9_s, r14.xyz, r10.z).x;
          r6.w = r8.z + r6.w;
          r6.w = 0.0769230798 * r6.w;
          r3.z = r6.w * r6.w;
        }
        r6.w = (int)r7.w;
        r6.w = cmp(r12.z >= r6.w);
        r6.w = r6.w ? 1.000000 : 0;
        r7.w = dot(r11.xyzw, icb[r7.w+0].xyzw);
        r3.z = r6.w * r7.w + r3.z;
        r3.z = min(1, r3.z);
      } else {
        r3.z = 1;
      }
      r3.w = r5.w ? r3.w : r3.z;
    }
    r3.z = r3.y * r3.w;
    float3 classic_cloud_world_0 = r5.xyz;
    r3.w = 20 * cb12[66].x;
    r10.zw = trunc(cb12[68].xy);
    r11.xy = cb12[67].xy;
    r11.z = 0;
    r11.xyz = r11.xyz + r5.xyz;
    r11.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r11.xyz;
    r11.xyz = r11.xyz / cb12[66].xxx;
    r12.xy = float2(20,20) * cb12[67].xy;
    r12.z = 0;
    r12.xyz = r12.xyz + r5.xyz;
    r12.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r12.xyz;
    r12.xyz = r12.xyz / r3.www;
    r8.zw = cb13[0].xy * r11.zz;
    r8.zw = r8.zw / cb13[0].zz;
    r10.xy = r11.xy + -r8.zw;
    r8.zw = cb13[0].xy * r12.zz;
    r8.zw = r8.zw / cb13[0].zz;
    r11.xy = r12.xy + -r8.zw;
    r3.w = t14.SampleLevel(s14_s, r10.xyz, 1).x;
    r5.w = t14.SampleLevel(s14_s, r10.xyw, 1).x;
    r5.w = r5.w + -r3.w;
    r3.w = cb12[66].w * r5.w + r3.w;
    r11.zw = r10.zw;
    r5.w = t14.SampleLevel(s14_s, r11.xyz, 1).x;
    r6.w = t14.SampleLevel(s14_s, r11.xyw, 1).x;
    r6.w = r6.w + -r5.w;
    r5.w = cb12[66].w * r6.w + r5.w;
    r6.w = -0.25 + cb13[0].z;
    r6.w = saturate(10 * r6.w);
    r7.w = -100 + r4.w;
    r7.w = saturate(0.00666666683 * r7.w);
    r5.w = r5.w + -r3.w;
    r3.w = r7.w * r5.w + r3.w;
    r3.w = -r6.w * r3.w + 1;
    r3.w = ClassicCloudShadow(classic_cloud_world_0, r3.w);
    r3.y = r3.z * r3.w;
  }
  r3.z = cmp(0 < r3.y);
  if (r3.z != 0) {
    r3.z = dot(cb13[0].xyz, r4.xyz);
    r10.xyz = saturate(r3.zzz);
    r3.w = cb4[6].x + r10.z;
    r3.w = cmp(0 < r3.w);
    if (r3.w != 0) {
      r11.xyz = r6.xyz * r2.www + cb13[0].xyz;
      r3.w = dot(r11.xyz, r11.xyz);
      r3.w = rsqrt(r3.w);
      r11.xyz = r11.xyz * r3.www;
      r3.w = dot(r11.xyz, r7.xyz);
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
      r6.w = r10.z * r6.w;
      r12.xyz = float3(0.318309873,0.318309873,0.318309873) * r6.www;
      r6.w = cmp(0 < cb4[6].x);
      if (r6.w != 0) {
        r6.w = 1 + r3.z;
        r6.w = 0.5 * r6.w;
        r7.w = dot(cb13[0].xyz, -r7.xyz);
        r7.w = 1 + r7.w;
        r7.w = 0.5 * r7.w;
        r8.z = dot(r4.xyz, -r7.xyz);
        r8.z = 1 + r8.z;
        r8.z = cb12[36].w * r8.z;
        r7.w = r7.w * r7.w;
        r8.z = 0.5 * r8.z;
        r7.w = r7.w * r7.w + -r6.w;
        r6.w = cb12[36].x * r7.w + r6.w;
        r6.w = r8.z * r6.w;
        r7.w = cb4[6].x * cb12[36].y;
        r5.w = cb12[36].z * r5.w + -r12.z;
        r5.w = r7.w * r5.w + r12.z;
        r12.xyz = r6.www * cb4[6].xxx + r5.www;
      }
      r8.zw = -cb12[0].xy + r5.xy;
      r5.w = dot(r8.zw, r8.zw);
      r5.w = sqrt(r5.w);
      r6.w = saturate(v7.w * cb12[218].z + cb12[218].w);
      r13.xyz = -cb13[52].xyz + cb13[51].xyz;
      r13.xyz = r6.www * r13.xyz + cb13[52].xyz;
      r5.w = saturate(r5.w * cb12[218].x + cb12[218].y);
      r13.xyz = -cb13[1].xyz + r13.xyz;
      r13.xyz = r5.www * r13.xyz + cb13[1].xyz;
      r12.xyz = r12.xyz * r3.yyy;
      r12.xyz = r12.xyz * r13.xyz;
      r3.z = cmp(0 < r3.z);
      if (r3.z != 0) {
        r3.z = saturate(dot(r4.xyz, r11.xyz));
        r5.w = dot(r4.xyz, r7.xyz);
        r6.w = r0.w * r0.w;
        r7.w = r6.w * r6.w;
        r3.z = r3.z * r3.z;
        r6.w = r6.w * r6.w + -1;
        r3.z = r3.z * r6.w + 1;
        r3.z = r3.z * r3.z;
        r3.z = 3.14152002 * r3.z;
        r3.z = r7.w / r3.z;
        r6.w = 1 + r0.w;
        r6.w = r6.w * r6.w;
        r7.w = 0.125 * r6.w;
        r6.w = -r6.w * 0.125 + 1;
        r8.z = r10.z * r6.w + r7.w;
        r8.z = r10.z / r8.z;
        r6.w = abs(r5.w) * r6.w + r7.w;
        r6.w = abs(r5.w) / r6.w;
        r6.w = r8.z * r6.w;
        r3.z = r6.w * r3.z;
        r3.z = r3.z * r3.w;
        r3.w = r10.z * abs(r5.w);
        r3.w = 4 * r3.w;
        r3.z = r3.z / r3.w;
        r11.xyz = r3.zzz * r10.zzz;
      } else {
        r11.xyz = float3(0,0,0);
      }
      r11.xyz = r11.xyz * r3.yyy;
      r11.xyz = r11.xyz * r13.xyz;
    } else {
      r10.xyz = float3(0,0,0);
      r12.xyz = float3(0,0,0);
      r11.xyz = float3(0,0,0);
    }
  } else {
    r10.xyz = float3(0,0,0);
    r12.xyz = float3(0,0,0);
    r11.xyz = float3(0,0,0);
  }
  r3.yzw = min(r10.xyz, r3.yyy);
  r5.w = cmp(r0.y == 1.000000);
  r6.w = cmp(cb2[16].x < 0);
  r6.w = r6.w ? 1 : cb12[71].x;
  r7.w = 1 + -r2.y;
  r8.z = cb13[56].x * r7.w;
  r10.xy = float2(1,1) + cb13[56].zw;
  r10.xy = -cb13[56].zw * r2.xx + r10.xy;
  r2.x = cmp(0 < cb4[6].x);
  r8.w = dot(r4.xyz, -r7.xyz);
  r9.w = 1 + r8.w;
  r9.w = cb12[36].w * r9.w;
  r9.w = 0.5 * r9.w;
  r10.z = cb4[6].x * cb12[36].y;
  r10.w = dot(r4.xyz, r7.xyz);
  r11.w = r0.w * r0.w;
  r12.w = r11.w * r11.w;
  r13.x = r11.w * r11.w + -1;
  r0.w = 1 + r0.w;
  r0.w = r0.w * r0.w;
  r13.y = 0.125 * r0.w;
  r0.w = -r0.w * 0.125 + 1;
  r13.z = abs(r10.w) * r0.w + r13.y;
  r13.z = abs(r10.w) / r13.z;
  r13.w = 4 * abs(r10.w);
  r14.x = r5.w ? 1.000000 : 0;
  r5.w = r5.w ? 0 : 1;
  r14.yzw = r12.xyz;
  r15.xyz = r11.xyz;
  r15.w = 0;
  while (true) {
    r16.x = cmp((int)r15.w >= 256);
    if (r16.x != 0) break;
    r16.x = (int)r0.x + (int)r15.w;
    r16.x = (uint)r16.x << 2;
  // No code for instruction (needs manual fix):
    r16.x = Raw20.Load((uint)r16.x);
    r16.y = cmp((uint)r16.x >= 256);
    if (r16.y != 0) {
      break;
    }
    r16.x = (int)r16.x * 9;
    r17.xyz = cb13[r16.x+58].xyz + -r5.xyz;
    r16.y = dot(r17.xyz, r17.xyz);
    r16.z = sqrt(r16.y);
    r16.w = r16.z / cb13[r16.x+58].w;
    r18.x = r16.w * r16.w;
    r18.x = -r18.x * r18.x + 1;
    r18.x = max(0, r18.x);
    r18.x = r18.x * r18.x;
    r18.yzw = int3(1,2048,4096) & asint(cb13[r16.x+61].www);
    r19.x = cmp(0 < cb13[r16.x+63].z);
    r19.y = cmp(0 < cb13[r16.x+64].x);
    r19.z = r16.y * cb13[r16.x+63].x + 1;
    r18.x = r18.x / r19.z;
    if (r18.y != 0) {
      r19.z = rsqrt(r16.y);
      r20.xyz = r19.zzz * r17.xyz;
      r19.z = dot(-r20.xyz, cb13[r16.x+60].xyz);
      r19.z = saturate(r19.z * cb13[r16.x+62].y + cb13[r16.x+62].z);
      r19.z = log2(r19.z);
      r19.z = cb13[r16.x+62].w * r19.z;
      r19.z = exp2(r19.z);
      r18.x = r19.z * r18.x;
    }
    r19.z = cmp(0 < r18.x);
    r19.x = r19.z ? r19.x : 0;
    if (r19.x != 0) {
      if (r18.y != 0) {
        r20.xyz = -cb13[r16.x+58].xyz + r5.xyz;
        r21.xyz = cb13[r16.x+65].zwy * cb13[r16.x+60].zxy;
        r21.xyz = cb13[r16.x+60].yzx * cb13[r16.x+65].wyz + -r21.xyz;
        r21.x = dot(r21.xyz, r20.xyz);
        r21.y = dot(cb13[r16.x+65].yzw, r20.xyz);
        r21.z = dot(cb13[r16.x+60].xyz, r20.xyz);
        r21.w = cb13[r16.x+65].x;
      } else {
        r20.xyz = -cb13[r16.x+58].xzy + r5.xzy;
        r22.xyz = r17.xyz / r16.zzz;
        r16.z = max(abs(r22.y), abs(r22.z));
        r16.z = cmp(r16.z < abs(r22.x));
        if (r16.z != 0) {
          r16.z = cmp(0 < r22.x);
          r23.xyz = float3(1,1,-1) * r20.zyx;
          r23.w = cb13[r16.x+65].x;
          r24.xyz = float3(-1,1,1) * r20.zyx;
          r24.w = cb13[r16.x+65].y;
          r21.xyzw = r16.zzzz ? r23.xyzw : r24.xyzw;
        } else {
          r16.z = max(abs(r22.x), abs(r22.z));
          r16.z = cmp(r16.z < abs(r22.y));
          if (r16.z != 0) {
            r16.z = cmp(0 < r22.y);
            r23.xyz = float3(-1,1,-1) * r20.xyz;
            r23.w = cb13[r16.x+65].z;
            r20.w = cb13[r16.x+65].w;
            r21.xyzw = r16.zzzz ? r23.xyzw : r20.xyzw;
          } else {
            r16.z = cmp(0 < r22.z);
            r21.x = r20.x;
            r21.y = r16.z ? r20.z : -r20.z;
            r21.z = r16.z ? -r20.y : r20.y;
            r21.w = r16.z ? cb13[r16.x+66].x : cb13[r16.x+66].y;
          }
        }
      }
      r19.xw = cb13[r16.x+63].yy * r21.xy;
      r19.xw = r19.xw / r21.zz;
      r19.xw = r19.xw * float2(0.5,-0.5) + float2(0.5,0.5);
      if (10 == 0) r20.x = 0; else if (10+20 < 32) {       r20.x = (uint)r21.w << (32-(10 + 20)); r20.x = (uint)r20.x >> (32-10);      } else r20.x = (uint)r21.w >> 20;
      if (10 == 0) r20.y = 0; else if (10+10 < 32) {       r20.y = (uint)r21.w << (32-(10 + 10)); r20.y = (uint)r20.y >> (32-10);      } else r20.y = (uint)r21.w >> 10;
      r20.xy = (uint2)r20.xy;
      r16.z = (int)r21.w & 1023;
      r16.z = (uint)r16.z;
      r18.y = (uint)r21.w >> 30;
      r21.z = (uint)r18.y;
      r18.y = cmp(0 < r16.z);
      if (r18.y != 0) {
        r19.xw = r19.xw * r16.zz + r20.xy;
        r21.xy = float2(0.0009765625,0.0009765625) * r19.xw;
        r16.z = t9.SampleLevel(s10_s, r21.xyz, 0).x;
        r16.z = -r16.w * 0.99000001 + r16.z;
        r16.z = 144.269501 * r16.z;
        r16.z = exp2(r16.z);
        r16.z = min(1, r16.z);
      } else {
        r16.z = 1;
      }
    } else {
      r16.z = 1;
    }
    r18.y = r19.z ? r19.y : 0;
    if (r18.y != 0) {
      r17.w = cb13[r16.x+64].y;
      r17.w = t10.SampleLevel(s10_s, r17.xyzw, 0).x;
      r16.w = -r16.w * 0.99000001 + r17.w;
      r16.w = 144.269501 * r16.w;
      r16.w = exp2(r16.w);
      r16.w = min(1, r16.w);
      r16.z = r16.z * r16.w;
    }
    r16.z = -1 + r16.z;
    r16.z = cb13[r16.x+60].w * r16.z + 1;
    r16.z = r18.x * r16.z;
    r16.w = r18.z ? 1 : r14.x;
    r17.w = r18.w ? 1 : r5.w;
    r16.w = r17.w * r16.w;
    r16.z = r16.z * r16.w;
    r16.w = cmp(0 < r16.z);
    if (r16.w != 0) {
      r16.w = 0x80000000 & asint(cb13[r16.x+61].w);
      r16.w = r16.w ? r6.w : 1;
      r16.z = r16.z * r16.w;
      r16.y = rsqrt(r16.y);
      r17.xyz = r17.xyz * r16.yyy;
      r16.y = dot(r4.xyz, r17.xyz);
      r16.w = saturate(r16.y);
      r18.xyz = r6.xyz * r2.www + r17.xyz;
      r17.w = dot(r18.xyz, r18.xyz);
      r17.w = rsqrt(r17.w);
      r18.xyz = r18.xyz * r17.www;
      r17.w = dot(r18.xyz, r7.xyz);
      r17.w = 1 + -abs(r17.w);
      r17.w = max(0, r17.w);
      r18.w = r17.w * r17.w;
      r18.w = r18.w * r18.w;
      r17.w = r18.w * r17.w;
      r17.w = r17.w * r8.z;
      r17.w = r17.w / r10.x;
      r17.w = r17.w + r2.y;
      r18.w = 1 + -r17.w;
      r18.w = r18.w * r16.w;
      r19.xyz = float3(0.318309873,0.318309873,0.318309873) * r18.www;
      if (r2.x != 0) {
        r18.w = 1 + r16.y;
        r18.w = 0.5 * r18.w;
        r17.x = dot(r17.xyz, -r7.xyz);
        r17.x = 1 + r17.x;
        r17.x = 0.5 * r17.x;
        r17.x = r17.x * r17.x;
        r17.x = r17.x * r17.x + -r18.w;
        r17.x = cb12[36].x * r17.x + r18.w;
        r17.x = r17.x * r9.w;
        r17.y = cb12[36].z * r7.w + -r19.z;
        r17.y = r10.z * r17.y + r19.z;
        r19.xyz = r17.xxx * cb4[6].xxx + r17.yyy;
      }
      r17.xyz = cb13[r16.x+61].xyz * r19.xyz;
      r14.yzw = r16.zzz * r17.xyz + r14.yzw;
      r16.y = cmp(0 < r16.y);
      if (r16.y != 0) {
        r16.y = saturate(dot(r4.xyz, r18.xyz));
        r16.y = r16.y * r16.y;
        r16.y = r16.y * r13.x + 1;
        r16.y = r16.y * r16.y;
        r16.y = 3.14152002 * r16.y;
        r16.y = r12.w / r16.y;
        r17.x = r16.w * r0.w + r13.y;
        r17.x = r16.w / r17.x;
        r17.x = r17.x * r13.z;
        r16.y = r17.x * r16.y;
        r16.y = r16.y * r17.w;
        r17.x = r16.w * r13.w;
        r16.y = r16.y / r17.x;
        r17.xyz = r16.yyy * r16.www;
      } else {
        r17.xyz = float3(0,0,0);
      }
      r16.xyw = cb13[r16.x+61].xyz * r17.xyz;
      r15.xyz = r16.zzz * r16.xyw + r15.xyz;
    }
    r15.w = (int)r15.w + 1;
  }
  r0.x = r8.w + r8.w;
  r6.xyz = r4.xyz * -r0.xxx + -r7.xyz;
  r0.x = dot(r6.xyz, r6.xyz);
  r0.x = rsqrt(r0.x);
  r7.xyz = r6.xyz * r0.xxx;
  r11.xyz = ddx_coarse(r7.xyz);
  r12.xyz = ddy_coarse(r7.xyz);
  r8.xzw = r8.xxx ? -r11.xyz : r11.xyz;
  r11.xyz = r8.yyy ? -r12.xyz : r12.xyz;
  r8.xyz = r6.xyz * r0.xxx + r8.xzw;
  r0.w = dot(r8.xyz, r8.xyz);
  r0.w = rsqrt(r0.w);
  r8.xyz = r8.xyz * r0.www;
  r0.w = dot(r7.xyz, r8.xyz);
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
  r8.xyz = r6.xyz * r0.xxx + r11.xyz;
  r0.x = dot(r8.xyz, r8.xyz);
  r0.x = rsqrt(r0.x);
  r8.xyz = r8.xyz * r0.xxx;
  r0.x = dot(r7.xyz, r8.xyz);
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
  r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r4.xyxy;
  r2.w = -r0.z * r2.z + 1;
  r2.w = max(0.00100000005, r2.w);
  r4.xy = r8.xy / r2.ww;
  r4.xy = float2(0.5,0.5) + r4.xy;
  r0.z = r0.z * r2.z + 1;
  r0.z = max(0.00100000005, r0.z);
  r2.zw = r8.zw / r0.zz;
  r2.zw = float2(0.5,0.5) + r2.zw;
  r0.zw = r0.ww ? r4.xy : r2.zw;
  r0.zw = r0.zw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
  r4.x = (int)r2.x;
  r4.y = 0;
  r0.zw = r4.xy + r0.zw;
  r8.xy = float2(0.5,0.142857149) * r0.zw;
  r2.xzw = cb12[114].xyz * v6.www;
  r2.xzw = cb12[113].xyz * v5.www + r2.xzw;
  r2.xzw = cb12[115].xyz * v7.www + r2.xzw;
  r2.xzw = cb12[116].xyz + r2.xzw;
  r2.xzw = float3(1,1,1) + -abs(r2.xzw);
  r0.zw = asint(cb12[117].yy) & int2(1,2);
  r0.z = r0.z ? 1 : r0.y;
  r4.x = 1 + -r0.y;
  r0.w = r0.w ? 1 : r4.x;
  r0.z = r0.z * r0.w;
  r7.xyz = cmp(float3(0,0,0) < r2.xzw);
  r0.w = r7.y ? r7.x : 0;
  r0.w = r7.z ? r0.w : 0;
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
    r8.z = r2.x * 0.142857149 + r8.y;
    r2.xzw = t22.SampleLevel(s11_s, r8.xz, 0).xyz;
    r2.xzw = r2.xzw * r0.www;
    r7.xyz = cb12[119].xyz * r6.yyy;
    r7.xyz = cb12[118].xyz * r6.xxx + r7.xyz;
    r7.xyz = cb12[120].xyz * r6.zzz + r7.xyz;
    r11.xyz = cb12[119].xyz * v6.www;
    r11.xyz = cb12[118].xyz * v5.www + r11.xyz;
    r11.xyz = cb12[120].xyz * v7.www + r11.xyz;
    r11.xyz = cb12[121].xyz + r11.xyz;
    r7.xyz = float3(1,1,1) / r7.xyz;
    r12.xyz = -r11.xyz * r7.xyz + r7.xyz;
    r7.xyz = -r11.xyz * r7.xyz + -r7.xyz;
    r7.xyz = max(r12.xyz, r7.xyz);
    r4.y = min(r7.y, r7.z);
    r4.y = min(r7.x, r4.y);
    r7.xyz = r6.xyz * r4.yyy + r5.xyz;
    r7.xyz = -cb12[111].yzw + r7.xyz;
    r4.y = dot(r7.xyz, r7.xyz);
    r4.y = rsqrt(r4.y);
    r11.xyz = r7.xyz * r4.yyy;
    r4.z = cmp(r11.z < 0);
    r5.w = r4.z ? 1.f : 0.f;
    r11.xyzw = float4(0.5,-0.5,-0.5,0.5) * r11.xyxy;
    r6.w = -r7.z * r4.y + 1;
    r6.w = max(0.00100000005, r6.w);
    r7.xy = r11.xy / r6.ww;
    r7.xy = float2(0.5,0.5) + r7.xy;
    r4.y = r7.z * r4.y + 1;
    r4.y = max(0.00100000005, r4.y);
    r10.xz = r11.zw / r4.yy;
    r10.xz = float2(0.5,0.5) + r10.xz;
    r4.yz = r4.zz ? r7.xy : r10.xz;
    r4.yz = r4.yz * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
    r11.y = asint(cb12[122].x);
    r11.z = (int)r5.w;
    r11.xw = float2(0,0);
    r4.yz = r11.zw + r4.yz;
    r4.yz = r11.xy + r4.yz;
    r4.yz = float2(0.5,0.142857149) * r4.yz;
    r7.xyz = t23.SampleLevel(s11_s, r4.yz, r0.x).xyz;
    r7.xyz = r7.xyz * r0.www;
  } else {
    r2.xzw = float3(0,0,0);
    r7.xyz = float3(0,0,0);
    r0.z = 9.99999975e-006;
  }
  r0.w = cmp(r0.z < 0.999000013);
  if (r0.w != 0) {
    r11.xyz = cb12[126].xyz * v6.www;
    r11.xyz = cb12[125].xyz * v5.www + r11.xyz;
    r11.xyz = cb12[127].xyz * v7.www + r11.xyz;
    r11.xyz = cb12[128].xyz + r11.xyz;
    r11.xyz = float3(1,1,1) + -abs(r11.xyz);
    r4.yz = asint(cb12[129].yy) & int2(1,2);
    r4.y = r4.y ? 1 : r0.y;
    r4.z = r4.z ? 1 : r4.x;
    r4.y = r4.y * r4.z;
    r12.xyz = cmp(float3(0,0,0) < r11.xyz);
    r4.z = r12.y ? r12.x : 0;
    r4.z = r12.z ? r4.z : 0;
    r5.w = cmp(0 < r4.y);
    r4.z = r5.w ? r4.z : 0;
    if (r4.z != 0) {
      r11.xyz = saturate(cb12[124].xyz * r11.xyz);
      r4.z = 1 + -r0.z;
      r4.y = r4.z * r4.y;
      r4.y = cb12[123].x * r4.y;
      r4.z = r11.x * r11.y;
      r4.z = r4.z * r11.z;
      r5.w = r4.y * r4.z;
      r0.z = r4.y * r4.z + r0.z;
      r4.y = cb12[129].x * r5.w;
      r4.z = asint(cb12[134].x);
      r8.w = r4.z * 0.142857149 + r8.y;
      r11.xyz = t22.SampleLevel(s11_s, r8.xw, 0).xyz;
      r2.xzw = r4.yyy * r11.xyz + r2.xzw;
      r11.xyz = cb12[131].xyz * r6.yyy;
      r11.xyz = cb12[130].xyz * r6.xxx + r11.xyz;
      r11.xyz = cb12[132].xyz * r6.zzz + r11.xyz;
      r12.xyz = cb12[131].xyz * v6.www;
      r12.xyz = cb12[130].xyz * v5.www + r12.xyz;
      r12.xyz = cb12[132].xyz * v7.www + r12.xyz;
      r12.xyz = cb12[133].xyz + r12.xyz;
      r11.xyz = float3(1,1,1) / r11.xyz;
      r13.xyz = -r12.xyz * r11.xyz + r11.xyz;
      r11.xyz = -r12.xyz * r11.xyz + -r11.xyz;
      r11.xyz = max(r13.xyz, r11.xyz);
      r4.z = min(r11.y, r11.z);
      r4.z = min(r11.x, r4.z);
      r11.xyz = r6.xyz * r4.zzz + r5.xyz;
      r11.xyz = -cb12[123].yzw + r11.xyz;
      r4.z = dot(r11.xyz, r11.xyz);
      r4.z = rsqrt(r4.z);
      r11.xyw = r11.xyz * r4.zzz;
      r5.w = cmp(r11.w < 0);
      r6.w = r5.w ? 1.f : 0.f;
      r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r11.xyxy;
      r8.z = -r11.z * r4.z + 1;
      r8.z = max(0.00100000005, r8.z);
      r8.zw = r12.xy / r8.zz;
      r8.zw = float2(0.5,0.5) + r8.zw;
      r4.z = r11.z * r4.z + 1;
      r4.z = max(0.00100000005, r4.z);
      r10.xz = r12.zw / r4.zz;
      r10.xz = float2(0.5,0.5) + r10.xz;
      r8.zw = r5.ww ? r8.zw : r10.xz;
      r8.zw = r8.zw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r11.y = asint(cb12[134].x);
      r11.z = (int)r6.w;
      r11.xw = float2(0,0);
      r8.zw = r11.zw + r8.zw;
      r8.zw = r11.xy + r8.zw;
      r8.zw = float2(0.5,0.142857149) * r8.zw;
      r11.xyz = t23.SampleLevel(s11_s, r8.zw, r0.x).xyz;
      r7.xyz = r4.yyy * r11.xyz + r7.xyz;
    }
  }
  r4.y = cmp(r0.z < 0.999000013);
  r0.w = r0.w ? r4.y : 0;
  if (r0.w != 0) {
    r11.xyz = cb12[138].xyz * v6.www;
    r11.xyz = cb12[137].xyz * v5.www + r11.xyz;
    r11.xyz = cb12[139].xyz * v7.www + r11.xyz;
    r11.xyz = cb12[140].xyz + r11.xyz;
    r11.xyz = float3(1,1,1) + -abs(r11.xyz);
    r4.yz = asint(cb12[141].yy) & int2(1,2);
    r4.y = r4.y ? 1 : r0.y;
    r4.z = r4.z ? 1 : r4.x;
    r4.y = r4.y * r4.z;
    r12.xyz = cmp(float3(0,0,0) < r11.xyz);
    r4.z = r12.y ? r12.x : 0;
    r4.z = r12.z ? r4.z : 0;
    r5.w = cmp(0 < r4.y);
    r4.z = r5.w ? r4.z : 0;
    if (r4.z != 0) {
      r11.xyz = saturate(cb12[136].xyz * r11.xyz);
      r4.z = 1 + -r0.z;
      r4.y = r4.z * r4.y;
      r4.y = cb12[135].x * r4.y;
      r4.z = r11.x * r11.y;
      r4.z = r4.z * r11.z;
      r5.w = r4.y * r4.z;
      r0.z = r4.y * r4.z + r0.z;
      r4.y = cb12[141].x * r5.w;
      r4.z = asint(cb12[146].x);
      r11.y = r4.z * 0.142857149 + r8.y;
      r11.x = r8.x;
      r11.xyz = t22.SampleLevel(s11_s, r11.xy, 0).xyz;
      r2.xzw = r4.yyy * r11.xyz + r2.xzw;
      r11.xyz = cb12[143].xyz * r6.yyy;
      r11.xyz = cb12[142].xyz * r6.xxx + r11.xyz;
      r11.xyz = cb12[144].xyz * r6.zzz + r11.xyz;
      r12.xyz = cb12[143].xyz * v6.www;
      r12.xyz = cb12[142].xyz * v5.www + r12.xyz;
      r12.xyz = cb12[144].xyz * v7.www + r12.xyz;
      r12.xyz = cb12[145].xyz + r12.xyz;
      r11.xyz = float3(1,1,1) / r11.xyz;
      r13.xyz = -r12.xyz * r11.xyz + r11.xyz;
      r11.xyz = -r12.xyz * r11.xyz + -r11.xyz;
      r11.xyz = max(r13.xyz, r11.xyz);
      r4.z = min(r11.y, r11.z);
      r4.z = min(r11.x, r4.z);
      r11.xyz = r6.xyz * r4.zzz + r5.xyz;
      r11.xyz = -cb12[135].yzw + r11.xyz;
      r4.z = dot(r11.xyz, r11.xyz);
      r4.z = rsqrt(r4.z);
      r11.xyw = r11.xyz * r4.zzz;
      r5.w = cmp(r11.w < 0);
      r6.w = r5.w ? 1.f : 0.f;
      r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r11.xyxy;
      r8.z = -r11.z * r4.z + 1;
      r8.z = max(0.00100000005, r8.z);
      r8.zw = r12.xy / r8.zz;
      r8.zw = float2(0.5,0.5) + r8.zw;
      r4.z = r11.z * r4.z + 1;
      r4.z = max(0.00100000005, r4.z);
      r10.xz = r12.zw / r4.zz;
      r10.xz = float2(0.5,0.5) + r10.xz;
      r8.zw = r5.ww ? r8.zw : r10.xz;
      r8.zw = r8.zw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r11.y = asint(cb12[146].x);
      r11.z = (int)r6.w;
      r11.xw = float2(0,0);
      r8.zw = r11.zw + r8.zw;
      r8.zw = r11.xy + r8.zw;
      r8.zw = float2(0.5,0.142857149) * r8.zw;
      r11.xyz = t23.SampleLevel(s11_s, r8.zw, r0.x).xyz;
      r7.xyz = r4.yyy * r11.xyz + r7.xyz;
    }
  }
  r4.y = cmp(r0.z < 0.999000013);
  r0.w = r0.w ? r4.y : 0;
  if (r0.w != 0) {
    r11.xyz = cb12[150].xyz * v6.www;
    r11.xyz = cb12[149].xyz * v5.www + r11.xyz;
    r11.xyz = cb12[151].xyz * v7.www + r11.xyz;
    r11.xyz = cb12[152].xyz + r11.xyz;
    r11.xyz = float3(1,1,1) + -abs(r11.xyz);
    r4.yz = asint(cb12[153].yy) & int2(1,2);
    r4.y = r4.y ? 1 : r0.y;
    r4.z = r4.z ? 1 : r4.x;
    r4.y = r4.y * r4.z;
    r12.xyz = cmp(float3(0,0,0) < r11.xyz);
    r4.z = r12.y ? r12.x : 0;
    r4.z = r12.z ? r4.z : 0;
    r5.w = cmp(0 < r4.y);
    r4.z = r5.w ? r4.z : 0;
    if (r4.z != 0) {
      r11.xyz = saturate(cb12[148].xyz * r11.xyz);
      r4.z = 1 + -r0.z;
      r4.y = r4.z * r4.y;
      r4.y = cb12[147].x * r4.y;
      r4.z = r11.x * r11.y;
      r4.z = r4.z * r11.z;
      r5.w = r4.y * r4.z;
      r0.z = r4.y * r4.z + r0.z;
      r4.y = cb12[153].x * r5.w;
      r4.z = asint(cb12[158].x);
      r11.y = r4.z * 0.142857149 + r8.y;
      r11.x = r8.x;
      r11.xyz = t22.SampleLevel(s11_s, r11.xy, 0).xyz;
      r2.xzw = r4.yyy * r11.xyz + r2.xzw;
      r11.xyz = cb12[155].xyz * r6.yyy;
      r11.xyz = cb12[154].xyz * r6.xxx + r11.xyz;
      r11.xyz = cb12[156].xyz * r6.zzz + r11.xyz;
      r12.xyz = cb12[155].xyz * v6.www;
      r12.xyz = cb12[154].xyz * v5.www + r12.xyz;
      r12.xyz = cb12[156].xyz * v7.www + r12.xyz;
      r12.xyz = cb12[157].xyz + r12.xyz;
      r11.xyz = float3(1,1,1) / r11.xyz;
      r13.xyz = -r12.xyz * r11.xyz + r11.xyz;
      r11.xyz = -r12.xyz * r11.xyz + -r11.xyz;
      r11.xyz = max(r13.xyz, r11.xyz);
      r4.z = min(r11.y, r11.z);
      r4.z = min(r11.x, r4.z);
      r11.xyz = r6.xyz * r4.zzz + r5.xyz;
      r11.xyz = -cb12[147].yzw + r11.xyz;
      r4.z = dot(r11.xyz, r11.xyz);
      r4.z = rsqrt(r4.z);
      r11.xyw = r11.xyz * r4.zzz;
      r5.w = cmp(r11.w < 0);
      r6.w = r5.w ? 1.f : 0.f;
      r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r11.xyxy;
      r8.z = -r11.z * r4.z + 1;
      r8.z = max(0.00100000005, r8.z);
      r8.zw = r12.xy / r8.zz;
      r8.zw = float2(0.5,0.5) + r8.zw;
      r4.z = r11.z * r4.z + 1;
      r4.z = max(0.00100000005, r4.z);
      r10.xz = r12.zw / r4.zz;
      r10.xz = float2(0.5,0.5) + r10.xz;
      r8.zw = r5.ww ? r8.zw : r10.xz;
      r8.zw = r8.zw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r11.y = asint(cb12[158].x);
      r11.z = (int)r6.w;
      r11.xw = float2(0,0);
      r8.zw = r11.zw + r8.zw;
      r8.zw = r11.xy + r8.zw;
      r8.zw = float2(0.5,0.142857149) * r8.zw;
      r11.xyz = t23.SampleLevel(s11_s, r8.zw, r0.x).xyz;
      r7.xyz = r4.yyy * r11.xyz + r7.xyz;
    }
  }
  r4.y = cmp(r0.z < 0.999000013);
  r0.w = r0.w ? r4.y : 0;
  if (r0.w != 0) {
    r11.xyz = cb12[162].xyz * v6.www;
    r11.xyz = cb12[161].xyz * v5.www + r11.xyz;
    r11.xyz = cb12[163].xyz * v7.www + r11.xyz;
    r11.xyz = cb12[164].xyz + r11.xyz;
    r11.xyz = float3(1,1,1) + -abs(r11.xyz);
    r4.yz = asint(cb12[165].yy) & int2(1,2);
    r4.y = r4.y ? 1 : r0.y;
    r4.z = r4.z ? 1 : r4.x;
    r4.y = r4.y * r4.z;
    r12.xyz = cmp(float3(0,0,0) < r11.xyz);
    r4.z = r12.y ? r12.x : 0;
    r4.z = r12.z ? r4.z : 0;
    r5.w = cmp(0 < r4.y);
    r4.z = r5.w ? r4.z : 0;
    if (r4.z != 0) {
      r11.xyz = saturate(cb12[160].xyz * r11.xyz);
      r4.z = 1 + -r0.z;
      r4.y = r4.z * r4.y;
      r4.y = cb12[159].x * r4.y;
      r4.z = r11.x * r11.y;
      r4.z = r4.z * r11.z;
      r5.w = r4.y * r4.z;
      r0.z = r4.y * r4.z + r0.z;
      r4.y = cb12[165].x * r5.w;
      r4.z = asint(cb12[170].x);
      r11.y = r4.z * 0.142857149 + r8.y;
      r11.x = r8.x;
      r11.xyz = t22.SampleLevel(s11_s, r11.xy, 0).xyz;
      r2.xzw = r4.yyy * r11.xyz + r2.xzw;
      r11.xyz = cb12[167].xyz * r6.yyy;
      r11.xyz = cb12[166].xyz * r6.xxx + r11.xyz;
      r11.xyz = cb12[168].xyz * r6.zzz + r11.xyz;
      r12.xyz = cb12[167].xyz * v6.www;
      r12.xyz = cb12[166].xyz * v5.www + r12.xyz;
      r12.xyz = cb12[168].xyz * v7.www + r12.xyz;
      r12.xyz = cb12[169].xyz + r12.xyz;
      r11.xyz = float3(1,1,1) / r11.xyz;
      r13.xyz = -r12.xyz * r11.xyz + r11.xyz;
      r11.xyz = -r12.xyz * r11.xyz + -r11.xyz;
      r11.xyz = max(r13.xyz, r11.xyz);
      r4.z = min(r11.y, r11.z);
      r4.z = min(r11.x, r4.z);
      r11.xyz = r6.xyz * r4.zzz + r5.xyz;
      r11.xyz = -cb12[159].yzw + r11.xyz;
      r4.z = dot(r11.xyz, r11.xyz);
      r4.z = rsqrt(r4.z);
      r11.xyw = r11.xyz * r4.zzz;
      r5.w = cmp(r11.w < 0);
      r6.w = r5.w ? 1.f : 0.f;
      r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r11.xyxy;
      r8.z = -r11.z * r4.z + 1;
      r8.z = max(0.00100000005, r8.z);
      r8.zw = r12.xy / r8.zz;
      r8.zw = float2(0.5,0.5) + r8.zw;
      r4.z = r11.z * r4.z + 1;
      r4.z = max(0.00100000005, r4.z);
      r10.xz = r12.zw / r4.zz;
      r10.xz = float2(0.5,0.5) + r10.xz;
      r8.zw = r5.ww ? r8.zw : r10.xz;
      r8.zw = r8.zw * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r11.y = asint(cb12[170].x);
      r11.z = (int)r6.w;
      r11.xw = float2(0,0);
      r8.zw = r11.zw + r8.zw;
      r8.zw = r11.xy + r8.zw;
      r8.zw = float2(0.5,0.142857149) * r8.zw;
      r11.xyz = t23.SampleLevel(s11_s, r8.zw, r0.x).xyz;
      r7.xyz = r4.yyy * r11.xyz + r7.xyz;
    }
  }
  r4.y = cmp(r0.z < 0.999000013);
  r0.w = r0.w ? r4.y : 0;
  if (r0.w != 0) {
    r11.xyz = cb12[174].xyz * v6.www;
    r11.xyz = cb12[173].xyz * v5.www + r11.xyz;
    r11.xyz = cb12[175].xyz * v7.www + r11.xyz;
    r11.xyz = cb12[176].xyz + r11.xyz;
    r11.xyz = float3(1,1,1) + -abs(r11.xyz);
    r4.yz = asint(cb12[177].yy) & int2(1,2);
    r0.y = r4.y ? 1 : r0.y;
    r0.w = r4.z ? 1 : r4.x;
    r0.y = r0.y * r0.w;
    r4.xyz = cmp(float3(0,0,0) < r11.xyz);
    r0.w = r4.y ? r4.x : 0;
    r0.w = r4.z ? r0.w : 0;
    r4.x = cmp(0 < r0.y);
    r0.w = r4.x ? r0.w : 0;
    if (r0.w != 0) {
      r4.xyz = saturate(cb12[172].xyz * r11.xyz);
      r0.w = 1 + -r0.z;
      r0.y = r0.w * r0.y;
      r0.y = cb12[171].x * r0.y;
      r0.w = r4.x * r4.y;
      r0.w = r0.w * r4.z;
      r4.x = r0.y * r0.w;
      r0.z = r0.y * r0.w + r0.z;
      r0.y = cb12[177].x * r4.x;
      r0.w = asint(cb12[182].x);
      r4.y = r0.w * 0.142857149 + r8.y;
      r4.x = r8.x;
      r4.xyz = t22.SampleLevel(s11_s, r4.xy, 0).xyz;
      r2.xzw = r0.yyy * r4.xyz + r2.xzw;
      r4.xyz = cb12[179].xyz * r6.yyy;
      r4.xyz = cb12[178].xyz * r6.xxx + r4.xyz;
      r4.xyz = cb12[180].xyz * r6.zzz + r4.xyz;
      r11.xyz = cb12[179].xyz * v6.www;
      r11.xyz = cb12[178].xyz * v5.www + r11.xyz;
      r11.xyz = cb12[180].xyz * v7.www + r11.xyz;
      r11.xyz = cb12[181].xyz + r11.xyz;
      r4.xyz = float3(1,1,1) / r4.xyz;
      r12.xyz = -r11.xyz * r4.xyz + r4.xyz;
      r4.xyz = -r11.xyz * r4.xyz + -r4.xyz;
      r4.xyz = max(r12.xyz, r4.xyz);
      r0.w = min(r4.y, r4.z);
      r0.w = min(r4.x, r0.w);
      r4.xyz = r6.xyz * r0.www + r5.xyz;
      r4.xyz = -cb12[171].yzw + r4.xyz;
      r0.w = dot(r4.xyz, r4.xyz);
      r0.w = rsqrt(r0.w);
      r5.xyz = r4.xyz * r0.www;
      r4.x = cmp(r5.z < 0);
      r4.y = r4.x ? 1.f : 0.f;
      r5.xyzw = float4(0.5,-0.5,-0.5,0.5) * r5.xyxy;
      r6.w = -r4.z * r0.w + 1;
      r6.w = max(0.00100000005, r6.w);
      r5.xy = r5.xy / r6.ww;
      r0.w = r4.z * r0.w + 1;
      r0.w = max(0.00100000005, r0.w);
      r5.zw = r5.zw / r0.ww;
      r5.xyzw = float4(0.5,0.5,0.5,0.5) + r5.xyzw;
      r4.xz = r4.xx ? r5.xy : r5.zw;
      r4.xz = r4.xz * float2(0.666666627,0.666666627) + float2(0.166666672,0.166666672);
      r5.y = asint(cb12[182].x);
      r5.z = (int)r4.y;
      r5.xw = float2(0,0);
      r4.xy = r5.zw + r4.xz;
      r4.xy = r5.xy + r4.xy;
      r4.xy = float2(0.5,0.142857149) * r4.xy;
      r4.xyz = t23.SampleLevel(s11_s, r4.xy, r0.x).xyz;
      r7.xyz = r0.yyy * r4.xyz + r7.xyz;
    }
  }
  r0.y = cmp(r0.z < 0.999000013);
  if (r0.y != 0) {
    r0.y = 1 + -r0.z;
    r0.w = cb12[99].x * r0.y;
    r0.z = r0.y * cb12[99].x + r0.z;
    r0.y = cb12[105].x * r0.w;
    r0.w = asint(cb12[110].x);
    r8.y = r0.w * 0.142857149 + r8.y;
    r4.xyz = t22.SampleLevel(s11_s, r8.xy, 0).xyz;
    r2.xzw = r0.yyy * r4.xyz + r2.xzw;
    r0.w = cmp(r6.z < 0);
    r4.x = r0.w ? 1.f : 0.f;
    r5.xyzw = float4(0.5,-0.5,-0.5,0.5) * r6.xyxy;
    r4.y = 1 + -r6.z;
    r4.y = max(0.00100000005, r4.y);
    r4.yz = r5.xy / r4.yy;
    r4.yz = float2(0.5,0.5) + r4.yz;
    r5.x = 1 + r6.z;
    r5.x = max(0.00100000005, r5.x);
    r5.xy = r5.zw / r5.xx;
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
    r7.xyz = r0.yyy * r4.xyz + r7.xyz;
  }
  r0.x = 1 / r0.z;
  r0.yzw = r2.xzw * r0.xxx;
  r2.xzw = r7.xyz * r0.xxx;
  r0.x = abs(cb2[16].x) + -cb2[16].y;
  r4.xyz = r3.yzw * r0.xxx + cb2[16].yyy;
  r0.x = cb2[16].z + -cb2[16].w;
  r5.xyz = r3.yzw * r0.xxx + cb2[16].www;
  r0.xyz = r4.xyz * r0.yzw;
  r2.xzw = r5.xyz * r2.xzw;
  r0.w = dot(r9.xy, r9.xy);
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
  r5.xyz = cb12[183].zzz * r14.yzw;
  r6.xyz = cb12[183].www * r15.xyz;
  r0.xyz = r4.xyz * r0.xyz;
  r0.w = max(abs(r10.w), abs(r10.w));
  r0.w = 1 + -r0.w;
  r0.w = max(0, r0.w);
  r4.x = r0.w * r0.w;
  r4.x = r4.x * r4.x;
  r0.w = r4.x * r0.w;
  r4.x = min(1, cb13[56].y);
  r4.x = r4.x * r7.w;
  r0.w = r4.x * r0.w;
  r0.w = r0.w / r10.y;
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
  r1.xyz = r9.xyz / r4.www;
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
  r1.xyz = v3.xyz + -r0.xyz;
  r0.xyz = v3.www * r1.xyz + r0.xyz;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r0.w;
  return;
}
