#include "../shadow_inputs.hlsli"
ByteAddressBuffer Raw21 : register(t21);
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 31 15:08:29 2026
Texture2D<float4> t24 : register(t24);

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t22 : register(t22);

Texture2DArray<float4> t19 : register(t19);

Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float4> t8 : register(t8);

struct t0_t {
  float val[16];
};
StructuredBuffer<t0_t> t0 : register(t0);

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
  float4 cb12[193];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[10];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[8];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float3 v0 : POSITION0,
  float3 v1 : NORMAL0,
  float4 v2 : TANGENT0,
  float2 v3 : TEXCOORD0,
  uint4 v4 : BLENDINDICES0,
  float4 v5 : BLENDWEIGHT0,
  out float4 o0 : TEXCOORD0,
  out float4 o1 : TEXCOORD1,
  out float4 o2 : TEXCOORD2,
  out float4 o3 : TEXCOORD3,
  out float4 o4 : TEXCOORD4,
  out float4 o5 : TEXCOORD5,
  out float4 o6 : TEXCOORD6,
  out float4 o7 : TEXCOORD7,
  out float4 o8 : TEXCOORD8,
  out float4 o9 : TEXCOORD9,
  out float3 o10 : TEXCOORD10,
  out precise float4 o11 : SV_Position0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v5.x + v5.y;
  r0.x = v5.z + r0.x;
  r0.x = v5.w + r0.x;
  r1.xyzw = (uint4)v4.xyzw;
  r1.xyzw = mad(r1.xyzw, cb2[7].yyyy, cb2[7].xxxx);
  r1.xyzw = (uint4)r1.xyzw;
  r0.y = t0[r1.x].val[0/4];
  r0.z = t0[r1.x].val[0/4+1];
  r0.w = t0[r1.x].val[0/4+2];
  r2.x = t0[r1.x].val[16/4];
  r2.y = t0[r1.x].val[16/4+1];
  r2.z = t0[r1.x].val[16/4+2];
  r3.x = t0[r1.x].val[32/4];
  r3.y = t0[r1.x].val[32/4+1];
  r3.z = t0[r1.x].val[32/4+2];
  r4.x = t0[r1.x].val[48/4];
  r4.y = t0[r1.x].val[48/4+1];
  r4.z = t0[r1.x].val[48/4+2];
  r4.w = t0[r1.x].val[48/4+3];
  r5.xyz = v0.xyz;
  r5.w = 1;
  r6.x = r0.y;
  r6.y = r2.x;
  r6.z = r3.x;
  r6.w = r4.x;
  r6.x = dot(r5.xyzw, r6.xyzw);
  r7.x = r0.z;
  r7.y = r2.y;
  r7.z = r3.y;
  r7.w = r4.y;
  r6.y = dot(r5.xyzw, r7.xyzw);
  r3.x = r0.w;
  r3.y = r2.z;
  r3.w = r4.z;
  r6.z = dot(r5.xyzw, r3.xyzw);
  r0.xyzw = v5.xyzw / r0.xxxx;
  r2.x = t0[r1.y].val[0/4];
  r2.y = t0[r1.y].val[0/4+1];
  r2.z = t0[r1.y].val[0/4+2];
  r3.x = t0[r1.y].val[16/4];
  r3.y = t0[r1.y].val[16/4+1];
  r3.z = t0[r1.y].val[16/4+2];
  r7.x = t0[r1.y].val[32/4];
  r7.y = t0[r1.y].val[32/4+1];
  r7.z = t0[r1.y].val[32/4+2];
  r8.x = t0[r1.y].val[48/4];
  r8.y = t0[r1.y].val[48/4+1];
  r8.z = t0[r1.y].val[48/4+2];
  r8.w = t0[r1.y].val[48/4+3];
  r9.x = r2.x;
  r9.y = r3.x;
  r9.z = r7.x;
  r9.w = r8.x;
  r4.x = dot(r5.xyzw, r9.xyzw);
  r9.x = r2.y;
  r9.y = r3.y;
  r9.z = r7.y;
  r9.w = r8.y;
  r4.y = dot(r5.xyzw, r9.xyzw);
  r7.x = r2.z;
  r7.y = r3.z;
  r7.w = r8.z;
  r4.z = dot(r5.xyzw, r7.xyzw);
  r2.xyz = r4.xyz * r0.yyy;
  r2.xyz = mad(r6.xyz, r0.xxx, r2.xyz);
  r3.x = t0[r1.z].val[0/4];
  r3.y = t0[r1.z].val[0/4+1];
  r3.z = t0[r1.z].val[0/4+2];
  r4.x = t0[r1.z].val[16/4];
  r4.y = t0[r1.z].val[16/4+1];
  r4.z = t0[r1.z].val[16/4+2];
  r6.x = t0[r1.z].val[32/4];
  r6.y = t0[r1.z].val[32/4+1];
  r6.z = t0[r1.z].val[32/4+2];
  r7.x = t0[r1.z].val[48/4];
  r7.y = t0[r1.z].val[48/4+1];
  r7.z = t0[r1.z].val[48/4+2];
  r7.w = t0[r1.z].val[48/4+3];
  r9.x = r3.x;
  r9.y = r4.x;
  r9.z = r6.x;
  r9.w = r7.x;
  r8.x = dot(r5.xyzw, r9.xyzw);
  r9.x = r3.y;
  r9.y = r4.y;
  r9.z = r6.y;
  r9.w = r7.y;
  r8.y = dot(r5.xyzw, r9.xyzw);
  r6.x = r3.z;
  r6.y = r4.z;
  r6.w = r7.z;
  r8.z = dot(r5.xyzw, r6.xyzw);
  r2.xyz = mad(r8.xyz, r0.zzz, r2.xyz);
  r3.x = t0[r1.w].val[0/4];
  r3.y = t0[r1.w].val[0/4+1];
  r3.z = t0[r1.w].val[0/4+2];
  r4.x = t0[r1.w].val[16/4];
  r4.y = t0[r1.w].val[16/4+1];
  r4.z = t0[r1.w].val[16/4+2];
  r6.x = t0[r1.w].val[32/4];
  r6.y = t0[r1.w].val[32/4+1];
  r6.z = t0[r1.w].val[32/4+2];
  r9.x = t0[r1.w].val[48/4];
  r9.y = t0[r1.w].val[48/4+1];
  r9.z = t0[r1.w].val[48/4+2];
  r9.w = t0[r1.w].val[48/4+3];
  r10.x = r3.x;
  r10.y = r4.x;
  r10.z = r6.x;
  r10.w = r9.x;
  r7.x = dot(r5.xyzw, r10.xyzw);
  r10.x = r3.y;
  r10.y = r4.y;
  r10.z = r6.y;
  r10.w = r9.y;
  r7.y = dot(r5.xyzw, r10.xyzw);
  r6.x = r3.z;
  r6.y = r4.z;
  r6.w = r9.z;
  r7.z = dot(r5.xyzw, r6.xyzw);
  r2.xyz = mad(r7.xyz, r0.www, r2.xyz);
  r3.x = t0[r1.x].val[0/4];
  r3.y = t0[r1.x].val[0/4+1];
  r3.z = t0[r1.x].val[0/4+2];
  r3.w = t0[r1.x].val[0/4+3];
  r6.x = t0[r1.x].val[16/4];
  r6.y = t0[r1.x].val[16/4+1];
  r6.z = t0[r1.x].val[16/4+2];
  r6.w = t0[r1.x].val[16/4+3];
  r10.x = t0[r1.x].val[32/4];
  r10.y = t0[r1.x].val[32/4+1];
  r10.z = t0[r1.x].val[32/4+2];
  r10.w = t0[r1.x].val[32/4+3];
  r11.x = t0[r1.y].val[0/4];
  r11.y = t0[r1.y].val[0/4+1];
  r11.z = t0[r1.y].val[0/4+2];
  r11.w = t0[r1.y].val[0/4+3];
  r12.x = t0[r1.y].val[16/4];
  r12.y = t0[r1.y].val[16/4+1];
  r12.z = t0[r1.y].val[16/4+2];
  r12.w = t0[r1.y].val[16/4+3];
  r13.x = t0[r1.y].val[32/4];
  r13.y = t0[r1.y].val[32/4+1];
  r13.z = t0[r1.y].val[32/4+2];
  r13.w = t0[r1.y].val[32/4+3];
  r11.xyzw = r11.xyzw * r0.yyyy;
  r12.xyzw = r12.xyzw * r0.yyyy;
  r13.xyzw = r13.xyzw * r0.yyyy;
  r3.xyzw = mad(r3.xyzw, r0.xxxx, r11.xyzw);
  r6.xyzw = mad(r6.xyzw, r0.xxxx, r12.xyzw);
  r10.xyzw = mad(r10.xyzw, r0.xxxx, r13.xyzw);
  r11.x = t0[r1.z].val[0/4];
  r11.y = t0[r1.z].val[0/4+1];
  r11.z = t0[r1.z].val[0/4+2];
  r11.w = t0[r1.z].val[0/4+3];
  r12.x = t0[r1.z].val[16/4];
  r12.y = t0[r1.z].val[16/4+1];
  r12.z = t0[r1.z].val[16/4+2];
  r12.w = t0[r1.z].val[16/4+3];
  r13.x = t0[r1.z].val[32/4];
  r13.y = t0[r1.z].val[32/4+1];
  r13.z = t0[r1.z].val[32/4+2];
  r13.w = t0[r1.z].val[32/4+3];
  r3.xyzw = mad(r11.xyzw, r0.zzzz, r3.xyzw);
  r6.xyzw = mad(r12.xyzw, r0.zzzz, r6.xyzw);
  r10.xyzw = mad(r13.xyzw, r0.zzzz, r10.xyzw);
  r11.x = t0[r1.w].val[0/4];
  r11.y = t0[r1.w].val[0/4+1];
  r11.z = t0[r1.w].val[0/4+2];
  r11.w = t0[r1.w].val[0/4+3];
  r12.x = t0[r1.w].val[16/4];
  r12.y = t0[r1.w].val[16/4+1];
  r12.z = t0[r1.w].val[16/4+2];
  r12.w = t0[r1.w].val[16/4+3];
  r1.x = t0[r1.w].val[32/4];
  r1.y = t0[r1.w].val[32/4+1];
  r1.z = t0[r1.w].val[32/4+2];
  r1.w = t0[r1.w].val[32/4+3];
  r3.xyzw = mad(r11.xyzw, r0.wwww, r3.xyzw);
  r6.xyzw = mad(r12.xyzw, r0.wwww, r6.xyzw);
  r1.xyzw = mad(r1.xyzw, r0.wwww, r10.xyzw);
  r9.x = r4.w;
  r9.y = r8.w;
  r9.z = r7.w;
  r0.x = dot(r9.xyzw, r0.xyzw);
  r0.y = 1 + cb2[6].y;
  o2.y = r0.x * r0.y + -1;
  o1.x = dot(r5.xyzw, cb3[7].xyzw);
  o1.y = dot(r5.xyzw, cb3[8].xyzw);
  o1.z = dot(r5.xyzw, cb3[9].xyzw);
  r2.w = 1;
  r0.x = dot(r2.xyzw, cb2[0].xyzw);
  r0.y = dot(r2.xyzw, cb2[1].xyzw);
  r0.z = dot(r2.xyzw, cb2[2].xyzw);
  r4.xyzw = cb2[1].xyzw * cb1[0].yyyy;
  r4.xyzw = mad(cb2[0].xyzw, cb1[0].xxxx, r4.xyzw);
  r4.xyzw = mad(cb2[2].xyzw, cb1[0].zzzz, r4.xyzw);
  r4.xyzw = mad(cb1[0].wwww, float4(0,0,0,1), r4.xyzw);
  r5.xyzw = cb2[1].xyzw * cb1[1].yyyy;
  r5.xyzw = mad(cb2[0].xyzw, cb1[1].xxxx, r5.xyzw);
  r5.xyzw = mad(cb2[2].xyzw, cb1[1].zzzz, r5.xyzw);
  r5.xyzw = mad(cb1[1].wwww, float4(0,0,0,1), r5.xyzw);
  r7.xyzw = cb2[1].xyzw * cb1[2].yyyy;
  r7.xyzw = mad(cb2[0].xyzw, cb1[2].xxxx, r7.xyzw);
  r7.xyzw = mad(cb2[2].xyzw, cb1[2].zzzz, r7.xyzw);
  r7.xyzw = mad(cb1[2].wwww, float4(0,0,0,1), r7.xyzw);
  r8.xyzw = cb2[1].xyzw * cb1[3].yyyy;
  r8.xyzw = mad(cb2[0].xyzw, cb1[3].xxxx, r8.xyzw);
  r8.xyzw = mad(cb2[2].xyzw, cb1[3].zzzz, r8.xyzw);
  r8.xyzw = mad(cb1[3].wwww, float4(0,0,0,1), r8.xyzw);
  o11.x = dot(r2.xyzw, r4.xyzw);
  o11.y = dot(r2.xyzw, r5.xyzw);
  o11.z = dot(r2.xyzw, r7.xyzw);
  o11.w = dot(r2.xyzw, r8.xyzw);
  r2.x = dot(r3.xyzw, cb2[0].xyzw);
  r4.x = dot(r3.xyzw, cb2[1].xyzw);
  r3.x = dot(r3.xyzw, cb2[2].xyzw);
  r2.y = dot(r6.xyzw, cb2[0].xyzw);
  r4.y = dot(r6.xyzw, cb2[1].xyzw);
  r3.y = dot(r6.xyzw, cb2[2].xyzw);
  r2.z = dot(r1.xyzw, cb2[0].xyzw);
  r4.z = dot(r1.xyzw, cb2[1].xyzw);
  r3.z = dot(r1.xyzw, cb2[2].xyzw);
  r1.xyz = v2.zxy * v1.yzx;
  r1.xyz = mad(v2.yzx, v1.zxy, -r1.xyz);
  r1.xyz = v2.www * r1.xyz;
  r5.x = dot(v1.xyz, r2.xyz);
  r5.y = dot(v1.xyz, r4.xyz);
  r5.z = dot(v1.xyz, r3.xyz);
  r0.w = dot(r5.xyz, r5.xyz);
  r0.w = rsqrt(r0.w);
  r5.xyw = r5.xyz * r0.www;
  r6.x = dot(r1.xyz, r2.xyz);
  r6.y = dot(r1.xyz, r4.xyz);
  r6.z = dot(r1.xyz, r3.xyz);
  r1.x = dot(r6.xyz, r6.xyz);
  r1.x = rsqrt(r1.x);
  o8.xyz = r6.xyz * r1.xxx;
  r1.x = dot(v2.xyz, r2.xyz);
  r1.y = dot(v2.xyz, r4.xyz);
  r1.z = dot(v2.xyz, r3.xyz);
  r1.w = dot(r1.xyz, r1.xyz);
  r1.w = rsqrt(r1.w);
  o10.xyz = r1.xyz * r1.www;
  o3.w = 1 + -v3.y;
  r1.xyzw = cb12[2].xyzw * r0.yyyy;
  r1.xyzw = mad(cb12[1].xyzw, r0.xxxx, r1.xyzw);
  r1.xyzw = mad(cb12[3].xyzw, r0.zzzz, r1.xyzw);
  r1.xyzw = cb12[4].xyzw + r1.xyzw;
  r2.xyz = cb12[14].xyw * r1.yyy;
  r2.xyz = mad(cb12[13].xyw, r1.xxx, r2.xyz);
  r2.xyz = mad(cb12[15].xyw, r1.zzz, r2.xyz);
  r2.xyz = mad(cb12[16].xyw, r1.www, r2.xyz);
  r2.w = max(9.99999975e-005, r2.z);
  r2.xy = r2.xy / r2.ww;
  r3.xy = mad(r2.xy, float2(0.5,-0.5), float2(0.5,0.5));
  r3.xy = cb12[23].xy * r3.xy;
  r2.w = cmp(0 < asint(cb13[35].x));
  if (r2.w != 0) {
    r3.zw = -cb12[0].xy + r0.xy;
    r2.w = dot(r3.zw, r3.zw);
    r2.w = sqrt(r2.w);
    r3.z = cmp(r2.w < cb13[36].y);
    if (r3.z != 0) {
      r3.z = cb13[37].z * r2.w;
      r3.z = max(1, r3.z);
      r3.z = cb13[36].x / r3.z;
      r3.z = min(1, r3.z);
      r2.w = cb13[36].z + r2.w;
      r2.w = saturate(cb13[36].w * r2.w);
      r4.y = 0;
      r4.zw = float2(0,0);
      r3.w = 0;
      while (true) {
        r6.x = cmp((int)r4.w >= asint(cb13[35].x));
        r3.w = 0;
        if (r6.x != 0) break;
        r6.xy = -cb13[r4.w+39].xy + r0.xy;
        r7.xy = cb13[r4.w+39].zw * r6.xy;
        r6.xz = cmp(r7.xy >= float2(0,0));
        r6.x = r6.z ? r6.x : 0;
        r6.zw = cmp(float2(1,1) >= r7.xy);
        r6.x = r6.z ? r6.x : 0;
        r6.x = r6.w ? r6.x : 0;
        if (r6.x != 0) {
          r7.z = (int)r4.w;
          r7.w = mad(-r6.y, cb13[r4.w+39].w, 1);
          r6.y = t19.SampleLevel(s10_s, r7.xwz, 0).x;
          r6.y = mad(cb13[38].x, r6.y, cb13[38].y);
          r6.y = r6.y + -r0.z;
          r6.y = -0.100000001 + r6.y;
          r6.y = saturate(r6.y * r3.z);
          r6.y = 1 + -r6.y;
          r6.z = 1 + -r6.y;
          r4.z = mad(r2.w, r6.z, r6.y);
          r3.w = -1;
          break;
        }
        r4.x = (int)r4.w + 1;
        r4.zw = r4.yx;
        r3.w = r6.x;
      }
    } else {
      r3.w = 0;
    }
  } else {
    r3.w = 0;
  }
  r4.x = r3.w ? r4.z : 1;
  r2.w = cmp(0 < r4.x);
  if (r2.w != 0) {
    r6.xyz = cb13[5].xyz * r0.yyy;
    r6.xyz = mad(cb13[4].xyz, r0.xxx, r6.xyz);
    r6.xyz = mad(cb13[6].xyz, r0.zzz, r6.xyz);
    r6.xyz = cb13[7].xyz + r6.xyz;
    r2.w = cmp(abs(r6.z) >= 0.999000013);
    if (r2.w != 0) {
      r3.z = 1;
    }
    if (r2.w == 0) {
      r7.xyzw = -cb13[8].xyzw + r6.xxxx;
      r8.xyzw = -cb13[9].xyzw + r6.yyyy;
      r7.xyzw = max(abs(r8.xyzw), abs(r7.xyzw));
      r8.xyzw = cmp(r7.xyzw < cb13[10].xyzw);
      r8.xyzw = r8.xyzw ? float4(1,1,1,1) : 0;
      r9.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb13[15].zzzz);
      r9.xyzw = r9.xyzw ? float4(1,1,1,1) : 0;
      r2.w = dot(r8.xyzw, r9.xyzw);
      r3.w = cmp(r2.w < 0.5);
      if (r3.w != 0) {
        r3.z = 1;
      }
      if (r3.w == 0) {
        r7.xyzw = r7.xyzw / cb13[10].xyzw;
        r8.xyzw = float4(1,1,1,1) + -cb13[17].xyzw;
        r7.xyzw = -r8.xyzw + r7.xyzw;
        r7.xyzw = saturate(r7.xyzw / cb13[17].xyzw);
        r2.w = cb13[15].z + -r2.w;
        r6.w = (int)r2.w;
        r8.x = (int)cb13[15].z;
        r8.x = (int)r8.x + -1;
        r8.yz = cb13[r6.w+11].zz * float2(1,-1);
        r9.xy = mad(r6.xy, r8.yz, cb13[r6.w+11].xy);
        r9.z = trunc(r2.w);
        r2.w = cmp(asint(cb13[18].x) >= 1);
        if (r2.w != 0) {
          r2.w = t8.SampleCmpLevelZero(s9_s, r9.xyz, r6.z).x;
          r10.xyzw = mad(cb13[r6.w+11].wwww, float4(-2.10683131,0.317230552,-5.7376194,2.94642639), r9.xyxy);
          r11.xy = r10.xy;
          r11.z = r9.z;
          r6.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r6.z).x;
          r2.w = r6.x + r2.w;
          r11.xy = r10.zw;
          r6.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r6.z).x;
          r2.w = r6.x + r2.w;
          r10.xyzw = mad(cb13[r6.w+11].wwww, float4(-0.159624487,-3.19071364,-3.52795029,-1.76808), r9.xyxy);
          r11.xy = r10.xy;
          r6.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r6.z).x;
          r2.w = r6.x + r2.w;
          r11.xy = r10.zw;
          r6.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r6.z).x;
          r2.w = r6.x + r2.w;
          r11.xy = mad(cb13[r6.w+11].ww, float2(1.76031363,2.3547585), r9.xy);
          r6.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r6.z).x;
          r2.w = r6.x + r2.w;
          r2.w = 0.166666672 * r2.w;
          r2.w = r2.w * r2.w;
        } else {
          r6.x = t8.SampleCmpLevelZero(s9_s, r9.xyz, r6.z).x;
          r2.w = r6.x * r6.x;
        }
        r6.x = (int)r8.x;
        r6.x = cmp(r9.z >= r6.x);
        r6.x = r6.x ? 1.000000 : 0;
        r6.y = dot(r7.xyzw, icb[r8.x+0].xyzw);
        r2.w = mad(r6.x, r6.y, r2.w);
        r2.w = min(1, r2.w);
      } else {
        r2.w = 1;
      }
      r3.z = r3.w ? r3.z : r2.w;
    }
    r2.w = r4.x * r3.z;
    float3 classic_cloud_world_0 = r0.xyz;
    r3.z = 20 * cb12[66].x;
    r6.zw = trunc(cb12[68].xy);
    r7.xyz = -cb12[0].xyz + r0.xyz;
    r3.w = dot(r7.xyz, r7.xyz);
    r3.w = sqrt(r3.w);
    r7.xy = cb12[67].xy;
    r7.z = 0;
    r7.xyz = r7.xyz + r0.xyz;
    r7.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r7.xyz;
    r7.xyz = r7.xyz / cb12[66].xxx;
    r8.xy = float2(20,20) * cb12[67].xy;
    r8.z = 0;
    r8.xyz = r8.xyz + r0.xyz;
    r8.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r8.xyz;
    r8.xyz = r8.xyz / r3.zzz;
    r7.zw = cb13[0].xy * r7.zz;
    r7.zw = r7.zw / cb13[0].zz;
    r6.xy = r7.xy + -r7.zw;
    r7.xy = cb13[0].xy * r8.zz;
    r7.xy = r7.xy / cb13[0].zz;
    r7.xy = r8.xy + -r7.xy;
    r3.z = t14.SampleLevel(s14_s, r6.xyz, 1).x;
    r6.x = t14.SampleLevel(s14_s, r6.xyw, 1).x;
    r6.x = r6.x + -r3.z;
    r3.z = mad(cb12[66].w, r6.x, r3.z);
    r7.zw = r6.zw;
    r6.x = t14.SampleLevel(s14_s, r7.xyz, 1).x;
    r6.y = t14.SampleLevel(s14_s, r7.xyw, 1).x;
    r6.y = r6.y + -r6.x;
    r6.x = mad(cb12[66].w, r6.y, r6.x);
    r6.y = -0.25 + cb13[0].z;
    r6.y = saturate(10 * r6.y);
    r3.w = -100 + r3.w;
    r3.w = saturate(0.00666666683 * r3.w);
    r6.x = r6.x + -r3.z;
    r3.z = mad(r3.w, r6.x, r3.z);
    r3.z = mad(-r6.y, r3.z, 1);
    r3.z = ClassicCloudShadow(classic_cloud_world_0, r3.z);
    r4.x = r3.z * r2.w;
  }
  r3.xy = (int2)r3.xy;
  r3.zw = (int2)r3.xy ^ int2(2,2);
  r6.xy = max((int2)-r3.xy, (int2)r3.xy);
  r6.xy = (uint2)r6.xy >> int2(1,1);
  r6.zw = -(int2)r6.xy;
  r3.zw = (int2)r3.zw & int2(0x80000000,0x80000000);
  r6.xy = r3.zw ? r6.zw : r6.xy;
  r6.zw = float2(0,0);
  r3.zw = t24.Load(r6.xyz).xy;
  r6.xyz = -cb12[0].xyz + r0.xyz;
  r2.w = dot(r6.xyz, r6.xyz);
  r2.w = sqrt(r2.w);
  r7.x = cb12[1].z;
  r7.y = cb12[2].z;
  r7.z = cb12[3].z;
  r6.w = dot(r7.xyz, r6.xyz);
  r7.x = 1 / cb12[21].y;
  r7.x = r7.x * r2.w;
  r6.w = r7.x / r6.w;
  r6.w = -r6.w + r2.w;
  r6.w = saturate(cb13[33].w * r6.w);
  r6.w = cb13[33].z * r6.w;
  r6.w = max(0.00100000005, r6.w);
  r7.x = r2.w / cb13[34].z;
  r7.y = cmp(r3.z < r3.w);
  if (r7.y != 0) {
    r7.y = cmp(r7.x < r3.z);
    r7.z = cmp(r3.w < r7.x);
    r7.w = mad(cb13[34].z, r3.z, -cb13[34].x);
    r7.w = saturate(-r7.w * cb13[34].y + 1);
    r8.x = r7.x + -r3.z;
    r8.x = cb13[34].z * r8.x;
    r8.x = saturate(r8.x / r6.w);
    r8.y = r8.x * r7.w;
    r7.y = (int)r7.y | (int)r7.z;
    r8.x = 1;
    r7.yz = r7.yy ? float2(0,1) : r8.xy;
  } else {
    r7.w = cmp(r3.w < r3.z);
    r8.x = cmp(r7.x < r3.w);
    r8.y = cmp(r3.z < r7.x);
    r3.z = mad(cb13[34].z, r3.z, -cb13[34].x);
    r9.y = saturate(-r3.z * cb13[34].y + 1);
    r3.z = r7.x + -r3.w;
    r3.z = cb13[34].z * r3.z;
    r3.z = saturate(r3.z / r6.w);
    r9.w = 1 + -r3.z;
    r9.xz = float2(1,1);
    r3.zw = r8.yy ? r9.xy : r9.zw;
    r3.zw = r8.xx ? float2(1,1) : r3.zw;
    r7.yz = r7.ww ? r3.zw : float2(0,1);
  }
  r3.z = mad(-r7.z, r7.y, 1);
  r7.xy = (int2)r3.xy & int2(1,1);
  r7.yz = r7.yy ? float2(1.40129846e-045,4.20389539e-045) : float2(2.80259693e-045,0);
  r3.w = r7.x ? r7.y : r7.z;
  if (1 == 0) r7.x = 0; else if (1+1 < 32) {   r7.x = (uint)r3.x << (32-(1 + 1)); r7.x = (uint)r7.x >> (32-1);  } else r7.x = (uint)r3.x >> 1;
  if (1 == 0) r7.y = 0; else if (1+1 < 32) {   r7.y = (uint)r3.y << (32-(1 + 1)); r7.y = (uint)r7.y >> (32-1);  } else r7.y = (uint)r3.y >> 1;
  if (1 == 0) r7.z = 0; else if (1+2 < 32) {   r7.z = (uint)r3.x << (32-(1 + 2)); r7.z = (uint)r7.z >> (32-1);  } else r7.z = (uint)r3.x >> 2;
  if (1 == 0) r7.w = 0; else if (1+2 < 32) {   r7.w = (uint)r3.y << (32-(1 + 2)); r7.w = (uint)r7.w >> (32-1);  } else r7.w = (uint)r3.y >> 2;
  r8.xyzw = r7.yyww ? float4(1,3,1,3) : float4(2,0,2,0);
  r7.xy = r7.xz ? r8.xz : r8.yw;
  r3.w = (uint)r3.w << 4;
  r3.w = mad((int)r7.x, 4, (int)r3.w);
  r3.w = (int)r3.w + (int)r7.y;
  r3.w = (int)r3.w;
  r3.w = 0.5 + r3.w;
  r6.w = 0.015625 * r3.w;
  r3.xy = (uint2)r3.xy >> int2(5,5);
  r7.x = (int)cb12[24].z;
  r3.x = mad((int)r3.y, (int)r7.x, (int)r3.x);
  r3.y = mad(-r3.w, 0.015625, 1);
  r1.w = 1;
  r7.xzw = float3(0,0,0);
  r8.xyzw = float4(0,0,0,0);
  r3.w = 0;
  while (true) {
    r9.x = cmp((uint)r3.w >= 192);
    if (r9.x != 0) break;
    r9.x = mad((int)r3.x, 192, (int)r3.w);
    r9.x = (uint)r9.x << 2;
  // No code for instruction (needs manual fix):
    r9.x = Raw21.Load((uint)r9.x);
    r9.y = cmp((uint)r9.x >= 192);
    if (r9.y != 0) {
      break;
    }
    r9.x = (int)r9.x * 5;
    r10.x = dot(r1.xyzw, cb13[r9.x+2363].xyzw);
    r10.y = dot(r1.xyzw, cb13[r9.x+2364].xyzw);
    r10.z = dot(r1.xyzw, cb13[r9.x+2365].xyzw);
    r9.yzw = cmp(abs(r10.xyz) < float3(1,1,1));
    r9.y = r9.z ? r9.y : 0;
    r9.y = r9.w ? r9.y : 0;
    if (r9.y != 0) {
      r9.y = asuint(cb13[r9.x+2366].w) >> 16;
      r9.y = (uint)r9.y;
      r9.z = 0x0000ffff & asint(cb13[r9.x+2366].w);
      r9.z = (uint)r9.z;
      r9.yz = float2(1.52590219e-005,1.52590219e-005) * r9.yz;
      r9.w = dot(r10.xyz, r10.xyz);
      r9.w = sqrt(r9.w);
      r9.w = 1 + -r9.w;
      r9.w = max(0, r9.w);
      r10.xy = cb13[r9.x+2367].wx * r9.ww;
      r10.x = saturate(r10.x);
      r9.w = cmp(-1.000000 == cb13[r9.x+2367].w);
      r10.z = cmp(r9.y >= r3.y);
      r7.y = r10.z ? 1.000000 : 0;
      r9.y = cmp(r9.y >= r6.w);
      r9.y = r9.y ? 1.000000 : 0;
      r11.x = r9.z * r9.y;
      r11.y = min(0.998037279, r10.y);
      r11.zw = cb13[r9.x+2367].yz * r10.xx;
      r9.xyzw = r9.wwww ? r7.xyzw : r11.xyzw;
      r8.xyzw = max(r8.xyzw, r9.xyzw);
    }
    r3.w = (int)r3.w + 1;
  }
  r1.x = r8.y * r8.y;
  r1.y = cmp(0 < r8.x);
  r1.z = r1.y ? 0 : 1;
  r1.w = r3.z * r3.z;
  r1.z = min(r1.z, r1.w);
  r1.x = max(r1.z, r1.x);
  r1.x = 1 + -r1.x;
  r1.z = 1 + -r8.x;
  r1.w = 1 + -cb13[33].y;
  r1.y = r1.y ? r1.z : r1.w;
  r1.zw = float2(1,1) + -r8.zw;
  r1.y = min(r1.y, r1.z);
  r1.y = r1.y + -r1.w;
  r4.y = saturate(r1.x * r1.y + r1.w);
  r4.z = saturate(1 + -r1.x);
  r1.x = cmp(0 < r2.z);
  r1.y = max(abs(r2.x), abs(r2.y));
  r1.y = 1 + -r1.y;
  r1.y = saturate(10 * r1.y);
  r1.x = r1.x ? r1.y : 0;
  r1.yzw = -cb1[8].xyz + r0.xyz;
  r2.x = dot(r1.yzw, r1.yzw);
  r2.x = rsqrt(r2.x);
  r1.yzw = r2.xxx * r1.yzw;
  r2.x = dot(r1.yzw, r5.xyw);
  r2.x = r2.x + r2.x;
  r1.yzw = mad(-r2.xxx, r5.xyw, r1.yzw);
  r2.x = cmp(r5.w < 0);
  r2.y = r2.x ? 1.f : 0.f;
  r3.xyzw = float4(0.5,-0.5,-0.5,0.5) * r5.xyxy;
  r2.z = mad(-r5.z, r0.w, 1);
  r2.z = max(0.00100000005, r2.z);
  r3.xy = r3.xy / r2.zz;
  r0.w = mad(r5.z, r0.w, 1);
  r0.w = max(0.00100000005, r0.w);
  r3.zw = r3.zw / r0.ww;
  r3.xyzw = float4(0.5,0.5,0.5,0.5) + r3.xyzw;
  r2.xz = r2.xx ? r3.xy : r3.zw;
  r2.xz = mad(r2.xz, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
  r3.x = (int)r2.y;
  r3.y = 0;
  r2.xy = r3.xy + r2.xz;
  r3.xy = float2(0.5,0.142857149) * r2.xy;
  r2.xyz = cb12[114].xyz * r0.yyy;
  r2.xyz = mad(cb12[113].xyz, r0.xxx, r2.xyz);
  r2.xyz = mad(cb12[115].xyz, r0.zzz, r2.xyz);
  r2.xyz = cb12[116].xyz + r2.xyz;
  r2.xyz = float3(1,1,1) + -abs(r2.xyz);
  r7.xy = asint(cb12[117].yy) & int2(1,2);
  r0.w = r7.x ? 1 : r4.z;
  r5.z = 1 + -r4.z;
  r6.w = r7.y ? 1 : r5.z;
  r0.w = r6.w * r0.w;
  r7.xyz = cmp(float3(0,0,0) < r2.xyz);
  r6.w = r7.y ? r7.x : 0;
  r6.w = r7.z ? r6.w : 0;
  r7.x = cmp(0 < r0.w);
  r6.w = r7.x ? r6.w : 0;
  if (r6.w != 0) {
    r2.xyz = saturate(cb12[112].xyz * r2.xyz);
    r0.w = cb12[111].x * r0.w;
    r0.w = 0.999989986 * r0.w;
    r2.x = r2.x * r2.y;
    r2.x = r2.x * r2.z;
    r2.y = r2.x * r0.w;
    r0.w = mad(r0.w, r2.x, 9.99999975e-006);
    r2.x = cb12[117].x * r2.y;
    r2.y = asint(cb12[122].x);
    r3.z = mad(r2.y, 0.142857149, r3.y);
    r7.xyz = t22.SampleLevel(s11_s, r3.xz, 1).xyz;
    r7.xyz = r7.xyz * r2.xxx;
    r2.y = dot(r1.yzw, r1.yzw);
    r2.y = rsqrt(r2.y);
    r8.xyz = r2.yyy * r1.yzw;
    r2.z = cmp(r8.z < 0);
    r3.z = r2.z ? 1.f : 0.f;
    r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
    r6.w = mad(-r1.w, r2.y, 1);
    r6.w = max(0.00100000005, r6.w);
    r8.xy = r8.xy / r6.ww;
    r2.y = mad(r1.w, r2.y, 1);
    r2.y = max(0.00100000005, r2.y);
    r8.zw = r8.zw / r2.yy;
    r8.xyzw = float4(0.5,0.5,0.5,0.5) + r8.xyzw;
    r2.yz = r2.zz ? r8.xy : r8.zw;
    r2.yz = mad(r2.yz, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
    r8.y = asint(cb12[122].x);
    r8.z = (int)r3.z;
    r8.xw = float2(0,0);
    r2.yz = r8.zw + r2.yz;
    r2.yz = r8.xy + r2.yz;
    r2.yz = float2(0.5,0.142857149) * r2.yz;
    r8.xyz = t23.SampleLevel(s11_s, r2.yz, 5).xyz;
    r2.xyz = r8.xyz * r2.xxx;
  } else {
    r7.xyz = float3(0,0,0);
    r2.xyz = float3(0,0,0);
    r0.w = 9.99999975e-006;
  }
  r3.z = cmp(r0.w < 0.999000013);
  if (r3.z != 0) {
    r8.xyz = cb12[126].xyz * r0.yyy;
    r8.xyz = mad(cb12[125].xyz, r0.xxx, r8.xyz);
    r8.xyz = mad(cb12[127].xyz, r0.zzz, r8.xyz);
    r8.xyz = cb12[128].xyz + r8.xyz;
    r8.xyz = float3(1,1,1) + -abs(r8.xyz);
    r9.xy = asint(cb12[129].yy) & int2(1,2);
    r6.w = r9.x ? 1 : r4.z;
    r7.w = r9.y ? 1 : r5.z;
    r6.w = r7.w * r6.w;
    r9.xyz = cmp(float3(0,0,0) < r8.xyz);
    r7.w = r9.y ? r9.x : 0;
    r7.w = r9.z ? r7.w : 0;
    r8.w = cmp(0 < r6.w);
    r7.w = r8.w ? r7.w : 0;
    if (r7.w != 0) {
      r8.xyz = saturate(cb12[124].xyz * r8.xyz);
      r7.w = 1 + -r0.w;
      r6.w = r7.w * r6.w;
      r6.w = cb12[123].x * r6.w;
      r7.w = r8.x * r8.y;
      r7.w = r7.w * r8.z;
      r8.x = r7.w * r6.w;
      r0.w = mad(r6.w, r7.w, r0.w);
      r6.w = cb12[129].x * r8.x;
      r7.w = asint(cb12[134].x);
      r3.w = mad(r7.w, 0.142857149, r3.y);
      r8.xyz = t22.SampleLevel(s11_s, r3.xw, 1).xyz;
      r7.xyz = mad(r6.www, r8.xyz, r7.xyz);
      r3.w = dot(r1.yzw, r1.yzw);
      r3.w = rsqrt(r3.w);
      r8.xyz = r3.www * r1.yzw;
      r7.w = cmp(r8.z < 0);
      r8.z = r7.w ? 1.f : 0.f;
      r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
      r8.x = mad(-r1.w, r3.w, 1);
      r8.x = max(0.00100000005, r8.x);
      r8.xy = r9.xy / r8.xx;
      r8.xy = float2(0.5,0.5) + r8.xy;
      r3.w = mad(r1.w, r3.w, 1);
      r3.w = max(0.00100000005, r3.w);
      r9.xy = r9.zw / r3.ww;
      r9.xy = float2(0.5,0.5) + r9.xy;
      r8.xy = r7.ww ? r8.xy : r9.xy;
      r8.xy = mad(r8.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r9.y = asint(cb12[134].x);
      r9.z = (int)r8.z;
      r9.xw = float2(0,0);
      r8.xy = r9.zw + r8.xy;
      r8.xy = r9.xy + r8.xy;
      r8.xy = float2(0.5,0.142857149) * r8.xy;
      r8.xyz = t23.SampleLevel(s11_s, r8.xy, 5).xyz;
      r2.xyz = mad(r6.www, r8.xyz, r2.xyz);
    }
  }
  r3.w = cmp(r0.w < 0.999000013);
  r3.z = r3.w ? r3.z : 0;
  if (r3.z != 0) {
    r8.xyz = cb12[138].xyz * r0.yyy;
    r8.xyz = mad(cb12[137].xyz, r0.xxx, r8.xyz);
    r8.xyz = mad(cb12[139].xyz, r0.zzz, r8.xyz);
    r8.xyz = cb12[140].xyz + r8.xyz;
    r8.xyz = float3(1,1,1) + -abs(r8.xyz);
    r9.xy = asint(cb12[141].yy) & int2(1,2);
    r3.w = r9.x ? 1 : r4.z;
    r6.w = r9.y ? 1 : r5.z;
    r3.w = r6.w * r3.w;
    r9.xyz = cmp(float3(0,0,0) < r8.xyz);
    r6.w = r9.y ? r9.x : 0;
    r6.w = r9.z ? r6.w : 0;
    r7.w = cmp(0 < r3.w);
    r6.w = r7.w ? r6.w : 0;
    if (r6.w != 0) {
      r8.xyz = saturate(cb12[136].xyz * r8.xyz);
      r6.w = 1 + -r0.w;
      r3.w = r6.w * r3.w;
      r3.w = cb12[135].x * r3.w;
      r6.w = r8.x * r8.y;
      r6.w = r6.w * r8.z;
      r7.w = r6.w * r3.w;
      r0.w = mad(r3.w, r6.w, r0.w);
      r3.w = cb12[141].x * r7.w;
      r6.w = asint(cb12[146].x);
      r8.y = mad(r6.w, 0.142857149, r3.y);
      r8.x = r3.x;
      r8.xyz = t22.SampleLevel(s11_s, r8.xy, 1).xyz;
      r7.xyz = mad(r3.www, r8.xyz, r7.xyz);
      r6.w = dot(r1.yzw, r1.yzw);
      r6.w = rsqrt(r6.w);
      r8.xyz = r6.www * r1.yzw;
      r7.w = cmp(r8.z < 0);
      r8.z = r7.w ? 1.f : 0.f;
      r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
      r8.x = mad(-r1.w, r6.w, 1);
      r8.x = max(0.00100000005, r8.x);
      r8.xy = r9.xy / r8.xx;
      r8.xy = float2(0.5,0.5) + r8.xy;
      r6.w = mad(r1.w, r6.w, 1);
      r6.w = max(0.00100000005, r6.w);
      r9.xy = r9.zw / r6.ww;
      r9.xy = float2(0.5,0.5) + r9.xy;
      r8.xy = r7.ww ? r8.xy : r9.xy;
      r8.xy = mad(r8.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r9.y = asint(cb12[146].x);
      r9.z = (int)r8.z;
      r9.xw = float2(0,0);
      r8.xy = r9.zw + r8.xy;
      r8.xy = r9.xy + r8.xy;
      r8.xy = float2(0.5,0.142857149) * r8.xy;
      r8.xyz = t23.SampleLevel(s11_s, r8.xy, 5).xyz;
      r2.xyz = mad(r3.www, r8.xyz, r2.xyz);
    }
  }
  r3.w = cmp(r0.w < 0.999000013);
  r3.z = r3.w ? r3.z : 0;
  if (r3.z != 0) {
    r8.xyz = cb12[150].xyz * r0.yyy;
    r8.xyz = mad(cb12[149].xyz, r0.xxx, r8.xyz);
    r8.xyz = mad(cb12[151].xyz, r0.zzz, r8.xyz);
    r8.xyz = cb12[152].xyz + r8.xyz;
    r8.xyz = float3(1,1,1) + -abs(r8.xyz);
    r9.xy = asint(cb12[153].yy) & int2(1,2);
    r3.w = r9.x ? 1 : r4.z;
    r6.w = r9.y ? 1 : r5.z;
    r3.w = r6.w * r3.w;
    r9.xyz = cmp(float3(0,0,0) < r8.xyz);
    r6.w = r9.y ? r9.x : 0;
    r6.w = r9.z ? r6.w : 0;
    r7.w = cmp(0 < r3.w);
    r6.w = r7.w ? r6.w : 0;
    if (r6.w != 0) {
      r8.xyz = saturate(cb12[148].xyz * r8.xyz);
      r6.w = 1 + -r0.w;
      r3.w = r6.w * r3.w;
      r3.w = cb12[147].x * r3.w;
      r6.w = r8.x * r8.y;
      r6.w = r6.w * r8.z;
      r7.w = r6.w * r3.w;
      r0.w = mad(r3.w, r6.w, r0.w);
      r3.w = cb12[153].x * r7.w;
      r6.w = asint(cb12[158].x);
      r8.y = mad(r6.w, 0.142857149, r3.y);
      r8.x = r3.x;
      r8.xyz = t22.SampleLevel(s11_s, r8.xy, 1).xyz;
      r7.xyz = mad(r3.www, r8.xyz, r7.xyz);
      r6.w = dot(r1.yzw, r1.yzw);
      r6.w = rsqrt(r6.w);
      r8.xyz = r6.www * r1.yzw;
      r7.w = cmp(r8.z < 0);
      r8.z = r7.w ? 1.f : 0.f;
      r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
      r8.x = mad(-r1.w, r6.w, 1);
      r8.x = max(0.00100000005, r8.x);
      r8.xy = r9.xy / r8.xx;
      r8.xy = float2(0.5,0.5) + r8.xy;
      r6.w = mad(r1.w, r6.w, 1);
      r6.w = max(0.00100000005, r6.w);
      r9.xy = r9.zw / r6.ww;
      r9.xy = float2(0.5,0.5) + r9.xy;
      r8.xy = r7.ww ? r8.xy : r9.xy;
      r8.xy = mad(r8.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r9.y = asint(cb12[158].x);
      r9.z = (int)r8.z;
      r9.xw = float2(0,0);
      r8.xy = r9.zw + r8.xy;
      r8.xy = r9.xy + r8.xy;
      r8.xy = float2(0.5,0.142857149) * r8.xy;
      r8.xyz = t23.SampleLevel(s11_s, r8.xy, 5).xyz;
      r2.xyz = mad(r3.www, r8.xyz, r2.xyz);
    }
  }
  r3.w = cmp(r0.w < 0.999000013);
  r3.z = r3.w ? r3.z : 0;
  if (r3.z != 0) {
    r8.xyz = cb12[162].xyz * r0.yyy;
    r8.xyz = mad(cb12[161].xyz, r0.xxx, r8.xyz);
    r8.xyz = mad(cb12[163].xyz, r0.zzz, r8.xyz);
    r8.xyz = cb12[164].xyz + r8.xyz;
    r8.xyz = float3(1,1,1) + -abs(r8.xyz);
    r9.xy = asint(cb12[165].yy) & int2(1,2);
    r3.w = r9.x ? 1 : r4.z;
    r6.w = r9.y ? 1 : r5.z;
    r3.w = r6.w * r3.w;
    r9.xyz = cmp(float3(0,0,0) < r8.xyz);
    r6.w = r9.y ? r9.x : 0;
    r6.w = r9.z ? r6.w : 0;
    r7.w = cmp(0 < r3.w);
    r6.w = r7.w ? r6.w : 0;
    if (r6.w != 0) {
      r8.xyz = saturate(cb12[160].xyz * r8.xyz);
      r6.w = 1 + -r0.w;
      r3.w = r6.w * r3.w;
      r3.w = cb12[159].x * r3.w;
      r6.w = r8.x * r8.y;
      r6.w = r6.w * r8.z;
      r7.w = r6.w * r3.w;
      r0.w = mad(r3.w, r6.w, r0.w);
      r3.w = cb12[165].x * r7.w;
      r6.w = asint(cb12[170].x);
      r8.y = mad(r6.w, 0.142857149, r3.y);
      r8.x = r3.x;
      r8.xyz = t22.SampleLevel(s11_s, r8.xy, 1).xyz;
      r7.xyz = mad(r3.www, r8.xyz, r7.xyz);
      r6.w = dot(r1.yzw, r1.yzw);
      r6.w = rsqrt(r6.w);
      r8.xyz = r6.www * r1.yzw;
      r7.w = cmp(r8.z < 0);
      r8.z = r7.w ? 1.f : 0.f;
      r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
      r8.x = mad(-r1.w, r6.w, 1);
      r8.x = max(0.00100000005, r8.x);
      r8.xy = r9.xy / r8.xx;
      r8.xy = float2(0.5,0.5) + r8.xy;
      r6.w = mad(r1.w, r6.w, 1);
      r6.w = max(0.00100000005, r6.w);
      r9.xy = r9.zw / r6.ww;
      r9.xy = float2(0.5,0.5) + r9.xy;
      r8.xy = r7.ww ? r8.xy : r9.xy;
      r8.xy = mad(r8.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r9.y = asint(cb12[170].x);
      r9.z = (int)r8.z;
      r9.xw = float2(0,0);
      r8.xy = r9.zw + r8.xy;
      r8.xy = r9.xy + r8.xy;
      r8.xy = float2(0.5,0.142857149) * r8.xy;
      r8.xyz = t23.SampleLevel(s11_s, r8.xy, 5).xyz;
      r2.xyz = mad(r3.www, r8.xyz, r2.xyz);
    }
  }
  r3.w = cmp(r0.w < 0.999000013);
  r3.z = r3.w ? r3.z : 0;
  if (r3.z != 0) {
    r8.xyz = cb12[174].xyz * r0.yyy;
    r8.xyz = mad(cb12[173].xyz, r0.xxx, r8.xyz);
    r8.xyz = mad(cb12[175].xyz, r0.zzz, r8.xyz);
    r8.xyz = cb12[176].xyz + r8.xyz;
    r8.xyz = float3(1,1,1) + -abs(r8.xyz);
    r3.zw = asint(cb12[177].yy) & int2(1,2);
    r3.z = r3.z ? 1 : r4.z;
    r3.w = r3.w ? 1 : r5.z;
    r3.z = r3.z * r3.w;
    r9.xyz = cmp(float3(0,0,0) < r8.xyz);
    r3.w = r9.y ? r9.x : 0;
    r3.w = r9.z ? r3.w : 0;
    r5.z = cmp(0 < r3.z);
    r3.w = r5.z ? r3.w : 0;
    if (r3.w != 0) {
      r8.xyz = saturate(cb12[172].xyz * r8.xyz);
      r3.w = 1 + -r0.w;
      r3.z = r3.w * r3.z;
      r3.z = cb12[171].x * r3.z;
      r3.w = r8.x * r8.y;
      r3.w = r3.w * r8.z;
      r5.z = r3.z * r3.w;
      r0.w = mad(r3.z, r3.w, r0.w);
      r3.z = cb12[177].x * r5.z;
      r3.w = asint(cb12[182].x);
      r8.y = mad(r3.w, 0.142857149, r3.y);
      r8.x = r3.x;
      r8.xyz = t22.SampleLevel(s11_s, r8.xy, 1).xyz;
      r7.xyz = mad(r3.zzz, r8.xyz, r7.xyz);
      r3.w = dot(r1.yzw, r1.yzw);
      r3.w = rsqrt(r3.w);
      r8.xyz = r3.www * r1.yzw;
      r5.z = cmp(r8.z < 0);
      r6.w = r5.z ? 1.f : 0.f;
      r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r8.xyxy;
      r7.w = mad(-r1.w, r3.w, 1);
      r7.w = max(0.00100000005, r7.w);
      r8.xy = r8.xy / r7.ww;
      r3.w = mad(r1.w, r3.w, 1);
      r3.w = max(0.00100000005, r3.w);
      r8.zw = r8.zw / r3.ww;
      r8.xyzw = float4(0.5,0.5,0.5,0.5) + r8.xyzw;
      r8.xy = r5.zz ? r8.xy : r8.zw;
      r8.xy = mad(r8.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r9.y = asint(cb12[182].x);
      r9.z = (int)r6.w;
      r9.xw = float2(0,0);
      r8.xy = r9.zw + r8.xy;
      r8.xy = r9.xy + r8.xy;
      r8.xy = float2(0.5,0.142857149) * r8.xy;
      r8.xyz = t23.SampleLevel(s11_s, r8.xy, 5).xyz;
      r2.xyz = mad(r3.zzz, r8.xyz, r2.xyz);
    }
  }
  r3.z = cmp(r0.w < 1);
  if (r3.z != 0) {
    r3.z = 1 + -r0.w;
    r3.w = cb12[99].x * r3.z;
    r0.w = mad(r3.z, cb12[99].x, r0.w);
    r3.z = cb12[105].x * r3.w;
    r3.w = asint(cb12[110].x);
    r3.y = mad(r3.w, 0.142857149, r3.y);
    r3.xyw = t22.SampleLevel(s11_s, r3.xy, 1).xyz;
    r7.xyz = mad(r3.zzz, r3.xyw, r7.xyz);
    r3.x = cmp(r1.w < 0);
    r3.y = r3.x ? 1.f : 0.f;
    r8.xyzw = float4(0.5,-0.5,-0.5,0.5) * r1.yzyz;
    r1.y = 1 + -r1.w;
    r1.y = max(0.00100000005, r1.y);
    r1.yz = r8.xy / r1.yy;
    r1.yz = float2(0.5,0.5) + r1.yz;
    r1.w = 1 + r1.w;
    r1.w = max(0.00100000005, r1.w);
    r8.xy = r8.zw / r1.ww;
    r8.xy = float2(0.5,0.5) + r8.xy;
    r1.yz = r3.xx ? r1.yz : r8.xy;
    r1.yz = mad(r1.yz, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
    r8.y = asint(cb12[110].x);
    r8.z = (int)r3.y;
    r8.xw = float2(0,0);
    r1.yz = r8.zw + r1.yz;
    r1.yz = r8.xy + r1.yz;
    r1.yz = float2(0.5,0.142857149) * r1.yz;
    r1.yzw = t23.SampleLevel(s11_s, r1.yz, 5).xyz;
    r2.xyz = mad(r3.zzz, r1.yzw, r2.xyz);
  }
  r0.w = 1 / r0.w;
  r1.yzw = r7.xyz * r0.www;
  r2.xyz = r2.xyz * r0.www;
  o3.xyz = r1.yzw * r1.xxx;
  o4.xyz = r2.xyz * r1.xxx;
  r1.yzw = r6.xyz / r2.www;
  r0.w = -cb12[22].z + r2.w;
  r0.w = max(0, r0.w);
  r0.w = min(cb12[42].z, r0.w);
  r1.y = dot(cb12[38].xyz, r1.yzw);
  r1.z = abs(r1.y) * abs(r1.y);
  r2.x = saturate(r0.w * 0.00200000009 + -0.300000012);
  r1.z = r2.x * r1.z;
  r2.x = cmp(0 < r1.y);
  r2.yzw = r2.xxx ? cb12[39].xyz : cb12[41].xyz;
  r2.yzw = -cb12[40].xyz + r2.yzw;
  r2.yzw = mad(r1.zzz, r2.yzw, cb12[40].xyz);
  r3.xyz = r2.xxx ? cb12[45].xyz : cb12[47].xyz;
  r3.xyz = -cb12[46].xyz + r3.xyz;
  o0.xyz = r1.zzz * r3.xyz + cb12[46].xyz;
  r1.z = cmp(r0.w >= cb12[48].y);
  if (r1.z != 0) {
    r1.z = mad(r1.w, cb12[22].z, cb12[0].z);
    r1.w = r1.w * r0.w;
    r1.w = 0.0625 * r1.w;
    r2.x = cb12[43].x * r0.w;
    r2.x = 0.0625 * r2.x;
    r1.y = cb12[42].x + r1.y;
    r3.x = 1 + cb12[42].x;
    r1.y = saturate(r1.y / r3.x);
    r3.x = cb12[43].y + -cb12[43].z;
    r1.y = mad(r1.y, r3.x, cb12[43].z);
    r1.z = cb12[42].y + r1.z;
    r3.x = r1.z * r1.y;
    r1.w = r1.w * r1.y;
    r6.xyzw = mad(r1.wwww, float4(16,15,14,13), r3.xxxx);
    r6.xyzw = max(float4(0,0,0,0), r6.xyzw);
    r6.xyzw = float4(1,1,1,1) + r6.xyzw;
    r6.xyzw = saturate(r2.xxxx / r6.xyzw);
    r6.xyzw = float4(1,1,1,1) + -r6.xyzw;
    r3.y = r6.x * r6.y;
    r3.y = r3.y * r6.z;
    r3.y = r3.y * r6.w;
    r6.xyzw = mad(r1.wwww, float4(12,11,10,9), r3.xxxx);
    r6.xyzw = max(float4(0,0,0,0), r6.xyzw);
    r6.xyzw = float4(1,1,1,1) + r6.xyzw;
    r6.xyzw = saturate(r2.xxxx / r6.xyzw);
    r6.xyzw = float4(1,1,1,1) + -r6.xyzw;
    r3.y = r6.x * r3.y;
    r3.y = r3.y * r6.y;
    r3.y = r3.y * r6.z;
    r3.y = r3.y * r6.w;
    r6.xyzw = mad(r1.wwww, float4(8,7,6,5), r3.xxxx);
    r6.xyzw = max(float4(0,0,0,0), r6.xyzw);
    r6.xyzw = float4(1,1,1,1) + r6.xyzw;
    r6.xyzw = saturate(r2.xxxx / r6.xyzw);
    r6.xyzw = float4(1,1,1,1) + -r6.xyzw;
    r3.y = r6.x * r3.y;
    r3.y = r3.y * r6.y;
    r3.y = r3.y * r6.z;
    r3.y = r3.y * r6.w;
    r3.zw = mad(r1.ww, float2(4,3), r3.xx);
    r3.zw = max(float2(0,0), r3.zw);
    r3.zw = float2(1,1) + r3.zw;
    r3.zw = saturate(r2.xx / r3.zw);
    r3.zw = float2(1,1) + -r3.zw;
    r3.y = r3.y * r3.z;
    r3.y = r3.y * r3.w;
    r3.x = mad(r1.w, 2, r3.x);
    r3.x = max(0, r3.x);
    r3.x = 1 + r3.x;
    r3.x = saturate(r2.x / r3.x);
    r3.x = 1 + -r3.x;
    r3.x = r3.y * r3.x;
    r1.y = mad(r1.z, r1.y, r1.w);
    r1.y = max(0, r1.y);
    r1.y = 1 + r1.y;
    r1.y = saturate(r2.x / r1.y);
    r1.y = 1 + -r1.y;
    r1.y = mad(-r3.x, r1.y, 1);
    r0.w = -cb12[48].y + r0.w;
    r0.w = saturate(cb12[48].z * r0.w);
  } else {
    r1.y = 1;
    r0.w = 0;
  }
  r1.y = log2(r1.y);
  r1.z = cb12[42].w * r1.y;
  r1.z = exp2(r1.z);
  r1.z = r1.z * r0.w;
  r1.y = cb12[48].x * r1.y;
  r1.y = exp2(r1.y);
  o0.w = r1.y * r0.w;
  r1.yw = saturate(r1.zz * cb12[189].xz + cb12[189].yw);
  r3.xyz = cb12[188].xyz + -r2.yzw;
  r3.xyz = mad(r1.yyy, r3.xyz, r2.yzw);
  r0.w = -1 + cb12[188].w;
  r0.w = mad(r1.w, r0.w, 1);
  r3.w = saturate(r1.z * r0.w);
  r0.w = cmp(0 < cb12[192].x);
  if (r0.w != 0) {
    r1.yw = saturate(r1.zz * cb12[191].xz + cb12[191].yw);
    r6.xyz = cb12[190].xyz + -r2.yzw;
    r2.xyz = mad(r1.yyy, r6.xyz, r2.yzw);
    r0.w = -1 + cb12[190].w;
    r0.w = mad(r1.w, r0.w, 1);
    r2.w = saturate(r1.z * r0.w);
    r2.xyzw = r2.xyzw + -r3.xyzw;
    o5.xyzw = cb12[192].xxxx * r2.xyzw + r3.xyzw;
  } else {
    o5.xyzw = r3.xyzw;
  }
  r4.w = 1;
  o6.xyzw = r4.xyzw * r1.xxxx;
  o1.w = v3.x;
  o2.xzw = cb2[6].xzw;
  o4.w = r0.x;
  o7.xyzw = float4(1,1,1,1);
  o8.w = r0.y;
  o9.w = r0.z;
  o9.xyz = r5.xyw;
  return;
}
