#include "../shadow_inputs.hlsli"
ByteAddressBuffer Raw21 : register(t21);
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 31 15:08:29 2026
Texture2D<float4> t24 : register(t24);

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t22 : register(t22);

Texture2DArray<float4> t19 : register(t19);

Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float4> t8 : register(t8);

Texture2D<float4> t1 : register(t1);

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
  float4 cb2[6];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float3 v0 : POSITION0,
  uint4 v1 : BLENDINDICES0,
  float4 v2 : BLENDWEIGHT0,
  float2 v3 : TEXCOORD0,
  float3 v4 : NORMAL0,
  float4 v5 : TANGENT0,
  float4 v6 : COLOR0,
  float2 v7 : TEXCOORD1,
  float4 v8 : INSTANCE_TRANSFORM0,
  float4 v9 : INSTANCE_TRANSFORM1,
  float4 v10 : INSTANCE_TRANSFORM2,
  float4 v11 : INSTANCE_LOD_PARAMS0,
  float4 v12 : INSTANCE_SKINNING_DATA0,
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
  out float4 o10 : TEXCOORD10,
  out float3 o11 : TEXCOORD11,
  out precise float4 o12 : SV_Position0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyz = mad(v0.xyz, cb2[4].xyz, cb2[5].xyz);
  r1.x = v2.x + v2.y;
  r1.x = v2.z + r1.x;
  r1.x = v2.w + r1.x;
  r2.xyzw = (uint4)v1.xyzw;
  r2.xyzw = mad(r2.xyzw, v12.yyyy, v12.xxxx);
  r2.xyzw = (uint4)r2.xyzw;
  r3.x = t0[r2.x].val[48/4];
  r3.y = t0[r2.x].val[48/4+1];
  r3.w = t0[r2.x].val[48/4+2];
  r4.x = t0[r2.x].val[0/4];
  r4.y = t0[r2.x].val[0/4+1];
  r4.z = t0[r2.x].val[0/4+2];
  r4.w = t0[r2.x].val[0/4+3];
  r5.x = t0[r2.x].val[16/4];
  r5.y = t0[r2.x].val[16/4+1];
  r5.z = t0[r2.x].val[16/4+2];
  r5.w = t0[r2.x].val[16/4+3];
  r6.x = t0[r2.x].val[32/4];
  r6.y = t0[r2.x].val[32/4+1];
  r6.z = t0[r2.x].val[32/4+2];
  r6.w = t0[r2.x].val[32/4+3];
  r0.w = 1;
  r7.x = r4.x;
  r7.y = r5.x;
  r7.z = r6.x;
  r7.w = r3.x;
  r8.x = dot(r0.xyzw, r7.xyzw);
  r9.x = r4.y;
  r9.y = r5.y;
  r9.z = r6.y;
  r9.w = r3.y;
  r8.y = dot(r0.xyzw, r9.xyzw);
  r3.x = r4.z;
  r3.y = r5.z;
  r3.z = r6.z;
  r8.z = dot(r0.xyzw, r3.xyzw);
  r10.x = r4.w;
  r10.y = r5.w;
  r10.z = r6.w;
  r10.w = 1;
  r8.w = dot(r0.xyzw, r10.xyzw);
  r1.xyzw = v2.xyzw / r1.xxxx;
  r10.x = t0[r2.y].val[48/4];
  r10.y = t0[r2.y].val[48/4+1];
  r10.w = t0[r2.y].val[48/4+2];
  r11.x = t0[r2.y].val[0/4];
  r11.y = t0[r2.y].val[0/4+1];
  r11.z = t0[r2.y].val[0/4+2];
  r11.w = t0[r2.y].val[0/4+3];
  r12.x = t0[r2.y].val[16/4];
  r12.y = t0[r2.y].val[16/4+1];
  r12.z = t0[r2.y].val[16/4+2];
  r12.w = t0[r2.y].val[16/4+3];
  r13.x = t0[r2.y].val[32/4];
  r13.y = t0[r2.y].val[32/4+1];
  r13.z = t0[r2.y].val[32/4+2];
  r13.w = t0[r2.y].val[32/4+3];
  r14.x = r11.x;
  r14.y = r12.x;
  r14.z = r13.x;
  r14.w = r10.x;
  r14.x = dot(r0.xyzw, r14.xyzw);
  r15.x = r11.y;
  r15.y = r12.y;
  r15.z = r13.y;
  r15.w = r10.y;
  r14.y = dot(r0.xyzw, r15.xyzw);
  r10.x = r11.z;
  r10.y = r12.z;
  r10.z = r13.z;
  r14.z = dot(r0.xyzw, r10.xyzw);
  r10.x = r11.w;
  r10.y = r12.w;
  r10.z = r13.w;
  r10.w = 1;
  r14.w = dot(r0.xyzw, r10.xyzw);
  r10.xyzw = r14.xyzw * r1.yyyy;
  r8.xyzw = mad(r8.xyzw, r1.xxxx, r10.xyzw);
  r10.x = t0[r2.z].val[48/4];
  r10.y = t0[r2.z].val[48/4+1];
  r10.w = t0[r2.z].val[48/4+2];
  r14.x = t0[r2.z].val[0/4];
  r14.y = t0[r2.z].val[0/4+1];
  r14.z = t0[r2.z].val[0/4+2];
  r14.w = t0[r2.z].val[0/4+3];
  r15.x = t0[r2.z].val[16/4];
  r15.y = t0[r2.z].val[16/4+1];
  r15.z = t0[r2.z].val[16/4+2];
  r15.w = t0[r2.z].val[16/4+3];
  r16.x = t0[r2.z].val[32/4];
  r16.y = t0[r2.z].val[32/4+1];
  r16.z = t0[r2.z].val[32/4+2];
  r16.w = t0[r2.z].val[32/4+3];
  r17.x = r14.x;
  r17.y = r15.x;
  r17.z = r16.x;
  r17.w = r10.x;
  r17.x = dot(r0.xyzw, r17.xyzw);
  r18.x = r14.y;
  r18.y = r15.y;
  r18.z = r16.y;
  r18.w = r10.y;
  r17.y = dot(r0.xyzw, r18.xyzw);
  r10.x = r14.z;
  r10.y = r15.z;
  r10.z = r16.z;
  r17.z = dot(r0.xyzw, r10.xyzw);
  r10.x = r14.w;
  r10.y = r15.w;
  r10.z = r16.w;
  r10.w = 1;
  r17.w = dot(r0.xyzw, r10.xyzw);
  r8.xyzw = mad(r17.xyzw, r1.zzzz, r8.xyzw);
  r10.x = t0[r2.w].val[48/4];
  r10.y = t0[r2.w].val[48/4+1];
  r10.w = t0[r2.w].val[48/4+2];
  r17.x = t0[r2.w].val[0/4];
  r17.y = t0[r2.w].val[0/4+1];
  r17.z = t0[r2.w].val[0/4+2];
  r17.w = t0[r2.w].val[0/4+3];
  r18.x = t0[r2.w].val[16/4];
  r18.y = t0[r2.w].val[16/4+1];
  r18.z = t0[r2.w].val[16/4+2];
  r18.w = t0[r2.w].val[16/4+3];
  r19.x = t0[r2.w].val[32/4];
  r19.y = t0[r2.w].val[32/4+1];
  r19.z = t0[r2.w].val[32/4+2];
  r19.w = t0[r2.w].val[32/4+3];
  r20.x = r17.x;
  r20.y = r18.x;
  r20.z = r19.x;
  r20.w = r10.x;
  r20.x = dot(r0.xyzw, r20.xyzw);
  r21.x = r17.y;
  r21.y = r18.y;
  r21.z = r19.y;
  r21.w = r10.y;
  r20.y = dot(r0.xyzw, r21.xyzw);
  r10.x = r17.z;
  r10.y = r18.z;
  r10.z = r19.z;
  r20.z = dot(r0.xyzw, r10.xyzw);
  r10.x = r17.w;
  r10.y = r18.w;
  r10.z = r19.w;
  r10.w = 1;
  r20.w = dot(r0.xyzw, r10.xyzw);
  r8.xyzw = mad(r20.xyzw, r1.wwww, r8.xyzw);
  r10.xyzw = r11.xyzw * r1.yyyy;
  r11.xyzw = r12.xyzw * r1.yyyy;
  r12.xyzw = r13.xyzw * r1.yyyy;
  r4.xyzw = mad(r4.xyzw, r1.xxxx, r10.xyzw);
  r5.xyzw = mad(r5.xyzw, r1.xxxx, r11.xyzw);
  r6.xyzw = mad(r6.xyzw, r1.xxxx, r12.xyzw);
  r4.xyzw = mad(r14.xyzw, r1.zzzz, r4.xyzw);
  r5.xyzw = mad(r15.xyzw, r1.zzzz, r5.xyzw);
  r6.xyzw = mad(r16.xyzw, r1.zzzz, r6.xyzw);
  r4.xyzw = mad(r17.xyzw, r1.wwww, r4.xyzw);
  r5.xyzw = mad(r18.xyzw, r1.wwww, r5.xyzw);
  r1.xyzw = mad(r19.xyzw, r1.wwww, r6.xyzw);
  r6.x = v1.x;
  r6.yzw = float3(0,0,0);
  r6.xyz = t1.Load(r6.xyz).xyz;
  r2.y = t0[r2.x].val[0/4];
  r2.z = t0[r2.x].val[0/4+1];
  r2.w = t0[r2.x].val[0/4+2];
  r10.x = t0[r2.x].val[16/4];
  r10.y = t0[r2.x].val[16/4+1];
  r10.z = t0[r2.x].val[16/4+2];
  r3.x = t0[r2.x].val[32/4];
  r3.y = t0[r2.x].val[32/4+1];
  r3.z = t0[r2.x].val[32/4+2];
  r6.w = 1;
  r7.x = r2.y;
  r7.y = r10.x;
  r7.z = r3.x;
  r7.x = dot(r6.xyzw, r7.xyzw);
  r9.x = r2.z;
  r9.y = r10.y;
  r9.z = r3.y;
  r7.y = dot(r6.xyzw, r9.xyzw);
  r3.x = r2.w;
  r3.y = r10.z;
  r7.z = dot(r6.xyzw, r3.xyzw);
  r2.x = saturate(v6.w);
  r2.yzw = r8.xyz + -r7.xyz;
  r8.xyz = mad(r2.xxx, r2.yzw, r7.xyz);
  o1.x = dot(r0.xyzw, cb3[7].xyzw);
  o1.y = dot(r0.xyzw, cb3[8].xyzw);
  o1.z = dot(r0.xyzw, cb3[9].xyzw);
  r0.x = dot(r8.xyzw, v8.xyzw);
  r0.y = dot(r8.xyzw, v9.xyzw);
  r0.z = dot(r8.xyzw, v10.xyzw);
  r2.xyzw = cb1[0].yyyy * v9.xyzw;
  r2.xyzw = mad(v8.xyzw, cb1[0].xxxx, r2.xyzw);
  r2.xyzw = mad(v10.xyzw, cb1[0].zzzz, r2.xyzw);
  r2.xyzw = mad(cb1[0].wwww, float4(0,0,0,1), r2.xyzw);
  r3.xyzw = cb1[1].yyyy * v9.xyzw;
  r3.xyzw = mad(v8.xyzw, cb1[1].xxxx, r3.xyzw);
  r3.xyzw = mad(v10.xyzw, cb1[1].zzzz, r3.xyzw);
  r3.xyzw = mad(cb1[1].wwww, float4(0,0,0,1), r3.xyzw);
  r6.xyzw = cb1[2].yyyy * v9.xyzw;
  r6.xyzw = mad(v8.xyzw, cb1[2].xxxx, r6.xyzw);
  r6.xyzw = mad(v10.xyzw, cb1[2].zzzz, r6.xyzw);
  r6.xyzw = mad(cb1[2].wwww, float4(0,0,0,1), r6.xyzw);
  r7.xyzw = cb1[3].yyyy * v9.xyzw;
  r7.xyzw = mad(v8.xyzw, cb1[3].xxxx, r7.xyzw);
  r7.xyzw = mad(v10.xyzw, cb1[3].zzzz, r7.xyzw);
  r7.xyzw = mad(cb1[3].wwww, float4(0,0,0,1), r7.xyzw);
  o12.x = dot(r8.xyzw, r2.xyzw);
  o12.y = dot(r8.xyzw, r3.xyzw);
  o12.z = dot(r8.xyzw, r6.xyzw);
  o12.w = dot(r8.xyzw, r7.xyzw);
  r2.x = dot(r4.xyzw, v8.xyzw);
  r3.x = dot(r4.xyzw, v9.xyzw);
  r4.x = dot(r4.xyzw, v10.xyzw);
  r2.y = dot(r5.xyzw, v8.xyzw);
  r3.y = dot(r5.xyzw, v9.xyzw);
  r4.y = dot(r5.xyzw, v10.xyzw);
  r2.z = dot(r1.xyzw, v8.xyzw);
  r3.z = dot(r1.xyzw, v9.xyzw);
  r4.z = dot(r1.xyzw, v10.xyzw);
  r1.xyz = mad(v4.xyz, float3(2,2,2), float3(-1,-1,-1));
  r5.xyzw = mad(v5.xyzw, float4(2,2,2,2), float4(-1,-1,-1,-1));
  r6.xyz = r5.yzx * r1.zxy;
  r6.xyz = mad(r1.yzx, r5.zxy, -r6.xyz);
  r6.xyz = r6.xyz * r5.www;
  r0.w = dot(r6.xyz, r6.xyz);
  r0.w = rsqrt(r0.w);
  r6.xyz = r6.xyz * r0.www;
  r7.x = dot(r1.xyz, r2.xyz);
  r7.y = dot(r1.xyz, r3.xyz);
  r7.z = dot(r1.xyz, r4.xyz);
  r0.w = dot(r7.xyz, r7.xyz);
  r0.w = rsqrt(r0.w);
  r1.xyz = r7.xyz * r0.www;
  r8.x = dot(r6.xyz, r2.xyz);
  r8.y = dot(r6.xyz, r3.xyz);
  r8.z = dot(r6.xyz, r4.xyz);
  r1.w = dot(r8.xyz, r8.xyz);
  r1.w = rsqrt(r1.w);
  r6.xyz = r8.xyz * r1.www;
  r2.x = dot(r5.xyz, r2.xyz);
  r2.y = dot(r5.xyz, r3.xyz);
  r2.z = dot(r5.xyz, r4.xyz);
  r1.w = dot(r2.xyz, r2.xyz);
  r1.w = rsqrt(r1.w);
  o11.xyz = r2.xyz * r1.www;
  r2.xyzw = cb12[2].xyzw * r0.yyyy;
  r2.xyzw = mad(cb12[1].xyzw, r0.xxxx, r2.xyzw);
  r2.xyzw = mad(cb12[3].xyzw, r0.zzzz, r2.xyzw);
  r2.xyzw = cb12[4].xyzw + r2.xyzw;
  r3.xyz = cb12[14].xyw * r2.yyy;
  r3.xyz = mad(cb12[13].xyw, r2.xxx, r3.xyz);
  r3.xyz = mad(cb12[15].xyw, r2.zzz, r3.xyz);
  r3.xyz = mad(cb12[16].xyw, r2.www, r3.xyz);
  r1.w = max(9.99999975e-005, r3.z);
  r3.xy = r3.xy / r1.ww;
  r4.xy = mad(r3.xy, float2(0.5,-0.5), float2(0.5,0.5));
  r4.xy = cb12[23].xy * r4.xy;
  r1.w = cmp(0 < asint(cb13[35].x));
  if (r1.w != 0) {
    r4.zw = -cb12[0].xy + r0.xy;
    r1.w = dot(r4.zw, r4.zw);
    r1.w = sqrt(r1.w);
    r3.w = cmp(r1.w < cb13[36].y);
    if (r3.w != 0) {
      r3.w = cb13[37].z * r1.w;
      r3.w = max(1, r3.w);
      r3.w = cb13[36].x / r3.w;
      r3.w = min(1, r3.w);
      r1.w = cb13[36].z + r1.w;
      r1.w = saturate(cb13[36].w * r1.w);
      r5.y = 0;
      r4.zw = float2(0,0);
      r5.z = 0;
      while (true) {
        r5.w = cmp((int)r4.w >= asint(cb13[35].x));
        r5.z = 0;
        if (r5.w != 0) break;
        r7.xy = -cb13[r4.w+39].xy + r0.xy;
        r8.xy = cb13[r4.w+39].zw * r7.xy;
        r7.xw = cmp(r8.xy >= float2(0,0));
        r5.w = r7.w ? r7.x : 0;
        r7.xw = cmp(float2(1,1) >= r8.xy);
        r5.w = r5.w ? r7.x : 0;
        r5.w = r7.w ? r5.w : 0;
        if (r5.w != 0) {
          r8.z = (int)r4.w;
          r8.w = mad(-r7.y, cb13[r4.w+39].w, 1);
          r6.w = t19.SampleLevel(s10_s, r8.xwz, 0).x;
          r6.w = mad(cb13[38].x, r6.w, cb13[38].y);
          r6.w = r6.w + -r0.z;
          r6.w = -0.100000001 + r6.w;
          r6.w = saturate(r6.w * r3.w);
          r6.w = 1 + -r6.w;
          r7.x = 1 + -r6.w;
          r4.z = mad(r1.w, r7.x, r6.w);
          r5.z = -1;
          break;
        }
        r5.x = (int)r4.w + 1;
        r4.zw = r5.yx;
        r5.z = r5.w;
      }
    } else {
      r5.z = 0;
    }
  } else {
    r5.z = 0;
  }
  r5.x = r5.z ? r4.z : 1;
  r1.w = cmp(0 < r5.x);
  if (r1.w != 0) {
    r7.xyw = cb13[5].xyz * r0.yyy;
    r7.xyw = mad(cb13[4].xyz, r0.xxx, r7.xyw);
    r7.xyw = mad(cb13[6].xyz, r0.zzz, r7.xyw);
    r7.xyw = cb13[7].xyz + r7.xyw;
    r1.w = cmp(abs(r7.w) >= 0.999000013);
    if (r1.w != 0) {
      r3.w = 1;
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
      r4.z = cmp(r1.w < 0.5);
      if (r4.z != 0) {
        r3.w = 1;
      }
      if (r4.z == 0) {
        r8.xyzw = r8.xyzw / cb13[10].xyzw;
        r9.xyzw = float4(1,1,1,1) + -cb13[17].xyzw;
        r8.xyzw = -r9.xyzw + r8.xyzw;
        r8.xyzw = saturate(r8.xyzw / cb13[17].xyzw);
        r1.w = cb13[15].z + -r1.w;
        r4.w = (int)r1.w;
        r6.w = (int)cb13[15].z;
        r6.w = (int)r6.w + -1;
        r9.xy = cb13[r4.w+11].zz * float2(1,-1);
        r9.xy = mad(r7.xy, r9.xy, cb13[r4.w+11].xy);
        r9.z = trunc(r1.w);
        r1.w = cmp(asint(cb13[18].x) >= 1);
        if (r1.w != 0) {
          r1.w = t8.SampleCmpLevelZero(s9_s, r9.xyz, r7.w).x;
          r10.xyzw = mad(cb13[r4.w+11].wwww, float4(-2.10683131,0.317230552,-5.7376194,2.94642639), r9.xyxy);
          r11.xy = r10.xy;
          r11.z = r9.z;
          r7.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r7.w).x;
          r1.w = r7.x + r1.w;
          r11.xy = r10.zw;
          r7.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r7.w).x;
          r1.w = r7.x + r1.w;
          r10.xyzw = mad(cb13[r4.w+11].wwww, float4(-0.159624487,-3.19071364,-3.52795029,-1.76808), r9.xyxy);
          r11.xy = r10.xy;
          r7.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r7.w).x;
          r1.w = r7.x + r1.w;
          r11.xy = r10.zw;
          r7.x = t8.SampleCmpLevelZero(s9_s, r11.xyz, r7.w).x;
          r1.w = r7.x + r1.w;
          r11.xy = mad(cb13[r4.w+11].ww, float2(1.76031363,2.3547585), r9.xy);
          r4.w = t8.SampleCmpLevelZero(s9_s, r11.xyz, r7.w).x;
          r1.w = r4.w + r1.w;
          r1.w = 0.166666672 * r1.w;
          r1.w = r1.w * r1.w;
        } else {
          r4.w = t8.SampleCmpLevelZero(s9_s, r9.xyz, r7.w).x;
          r1.w = r4.w * r4.w;
        }
        r4.w = (int)r6.w;
        r4.w = cmp(r9.z >= r4.w);
        r4.w = r4.w ? 1.000000 : 0;
        r6.w = dot(r8.xyzw, icb[r6.w+0].xyzw);
        r1.w = mad(r4.w, r6.w, r1.w);
        r1.w = min(1, r1.w);
      } else {
        r1.w = 1;
      }
      r3.w = r4.z ? r3.w : r1.w;
    }
    r1.w = r5.x * r3.w;
    float3 classic_cloud_world_0 = r0.xyz;
    r3.w = 20 * cb12[66].x;
    r8.zw = trunc(cb12[68].xy);
    r7.xyw = -cb12[0].xyz + r0.xyz;
    r4.z = dot(r7.xyw, r7.xyw);
    r4.z = sqrt(r4.z);
    r9.xy = cb12[67].xy;
    r9.z = 0;
    r7.xyw = r9.xyz + r0.xyz;
    r7.xyw = float3(0.00999999978,0.00999999978,0.00999999978) * r7.xyw;
    r7.xyw = r7.xyw / cb12[66].xxx;
    r9.xy = float2(20,20) * cb12[67].xy;
    r9.z = 0;
    r9.xyz = r9.xyz + r0.xyz;
    r9.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r9.xyz;
    r9.xyz = r9.xyz / r3.www;
    r10.xy = cb13[0].xy * r7.ww;
    r10.xy = r10.xy / cb13[0].zz;
    r8.xy = -r10.xy + r7.xy;
    r7.xy = cb13[0].xy * r9.zz;
    r7.xy = r7.xy / cb13[0].zz;
    r9.xy = r9.xy + -r7.xy;
    r3.w = t14.SampleLevel(s14_s, r8.xyz, 1).x;
    r4.w = t14.SampleLevel(s14_s, r8.xyw, 1).x;
    r4.w = r4.w + -r3.w;
    r3.w = mad(cb12[66].w, r4.w, r3.w);
    r9.zw = r8.zw;
    r4.w = t14.SampleLevel(s14_s, r9.xyz, 1).x;
    r6.w = t14.SampleLevel(s14_s, r9.xyw, 1).x;
    r6.w = r6.w + -r4.w;
    r4.w = mad(cb12[66].w, r6.w, r4.w);
    r6.w = -0.25 + cb13[0].z;
    r6.w = saturate(10 * r6.w);
    r4.z = -100 + r4.z;
    r4.z = saturate(0.00666666683 * r4.z);
    r4.w = r4.w + -r3.w;
    r3.w = mad(r4.z, r4.w, r3.w);
    r3.w = mad(-r6.w, r3.w, 1);
    r3.w = ClassicCloudShadow(classic_cloud_world_0, r3.w);
    r5.x = r3.w * r1.w;
  }
  r4.xy = (int2)r4.xy;
  r4.zw = (int2)r4.xy ^ int2(2,2);
  r7.xy = max((int2)-r4.xy, (int2)r4.xy);
  r7.xy = (uint2)r7.xy >> int2(1,1);
  r8.xy = -(int2)r7.xy;
  r4.zw = (int2)r4.zw & int2(0x80000000,0x80000000);
  r8.xy = r4.zw ? r8.xy : r7.xy;
  r8.zw = float2(0,0);
  r4.zw = t24.Load(r8.xyz).xy;
  r7.xyw = -cb12[0].xyz + r0.xyz;
  r1.w = dot(r7.xyw, r7.xyw);
  r1.w = sqrt(r1.w);
  r8.x = cb12[1].z;
  r8.y = cb12[2].z;
  r8.z = cb12[3].z;
  r3.w = dot(r8.xyz, r7.xyw);
  r6.w = 1 / cb12[21].y;
  r6.w = r6.w * r1.w;
  r3.w = r6.w / r3.w;
  r3.w = -r3.w + r1.w;
  r3.w = saturate(cb13[33].w * r3.w);
  r3.w = cb13[33].z * r3.w;
  r3.w = max(0.00100000005, r3.w);
  r6.w = r1.w / cb13[34].z;
  r8.x = cmp(r4.z < r4.w);
  if (r8.x != 0) {
    r8.x = cmp(r6.w < r4.z);
    r8.y = cmp(r4.w < r6.w);
    r8.z = mad(cb13[34].z, r4.z, -cb13[34].x);
    r8.z = saturate(-r8.z * cb13[34].y + 1);
    r8.w = r6.w + -r4.z;
    r8.w = cb13[34].z * r8.w;
    r8.w = saturate(r8.w / r3.w);
    r9.y = r8.z * r8.w;
    r8.x = (int)r8.x | (int)r8.y;
    r9.x = 1;
    r8.xy = r8.xx ? float2(0,1) : r9.xy;
  } else {
    r8.z = cmp(r4.w < r4.z);
    r8.w = cmp(r6.w < r4.w);
    r9.x = cmp(r4.z < r6.w);
    r4.z = mad(cb13[34].z, r4.z, -cb13[34].x);
    r10.y = saturate(-r4.z * cb13[34].y + 1);
    r4.z = r6.w + -r4.w;
    r4.z = cb13[34].z * r4.z;
    r3.w = saturate(r4.z / r3.w);
    r10.w = 1 + -r3.w;
    r10.xz = float2(1,1);
    r4.zw = r9.xx ? r10.xy : r10.zw;
    r4.zw = r8.ww ? float2(1,1) : r4.zw;
    r8.xy = r8.zz ? r4.zw : float2(0,1);
  }
  r3.w = mad(-r8.y, r8.x, 1);
  r4.zw = (int2)r4.xy & int2(1,1);
  r8.xy = r4.ww ? float2(1,3) : float2(2,0);
  r4.z = r4.z ? r8.x : r8.y;
  if (1 == 0) r8.x = 0; else if (1+1 < 32) {   r8.x = (uint)r4.x << (32-(1 + 1)); r8.x = (uint)r8.x >> (32-1);  } else r8.x = (uint)r4.x >> 1;
  if (1 == 0) r8.y = 0; else if (1+1 < 32) {   r8.y = (uint)r4.y << (32-(1 + 1)); r8.y = (uint)r8.y >> (32-1);  } else r8.y = (uint)r4.y >> 1;
  if (1 == 0) r8.z = 0; else if (1+2 < 32) {   r8.z = (uint)r4.x << (32-(1 + 2)); r8.z = (uint)r8.z >> (32-1);  } else r8.z = (uint)r4.x >> 2;
  if (1 == 0) r8.w = 0; else if (1+2 < 32) {   r8.w = (uint)r4.y << (32-(1 + 2)); r8.w = (uint)r8.w >> (32-1);  } else r8.w = (uint)r4.y >> 2;
  r9.xyzw = r8.yyww ? float4(1,3,1,3) : float4(2,0,2,0);
  r8.xy = r8.xz ? r9.xz : r9.yw;
  r4.z = (uint)r4.z << 4;
  r4.z = mad((int)r8.x, 4, (int)r4.z);
  r4.z = (int)r4.z + (int)r8.y;
  r4.z = (int)r4.z;
  r4.z = 0.5 + r4.z;
  r4.w = 0.015625 * r4.z;
  r4.xy = (uint2)r4.xy >> int2(5,5);
  r6.w = (int)cb12[24].z;
  r4.x = mad((int)r4.y, (int)r6.w, (int)r4.x);
  r4.y = mad(-r4.z, 0.015625, 1);
  r2.w = 1;
  r8.xzw = float3(0,0,0);
  r9.xyzw = float4(0,0,0,0);
  r4.z = 0;
  while (true) {
    r6.w = cmp((uint)r4.z >= 192);
    if (r6.w != 0) break;
    r6.w = mad((int)r4.x, 192, (int)r4.z);
    r6.w = (uint)r6.w << 2;
  // No code for instruction (needs manual fix):
    r6.w = Raw21.Load((uint)r6.w);
    r10.x = cmp((uint)r6.w >= 192);
    if (r10.x != 0) {
      break;
    }
    r6.w = (int)r6.w * 5;
    r10.x = dot(r2.xyzw, cb13[r6.w+2363].xyzw);
    r10.y = dot(r2.xyzw, cb13[r6.w+2364].xyzw);
    r10.z = dot(r2.xyzw, cb13[r6.w+2365].xyzw);
    r11.xyz = cmp(abs(r10.xyz) < float3(1,1,1));
    r10.w = r11.y ? r11.x : 0;
    r10.w = r11.z ? r10.w : 0;
    if (r10.w != 0) {
      r10.w = asuint(cb13[r6.w+2366].w) >> 16;
      r10.w = (uint)r10.w;
      r10.w = 1.52590219e-005 * r10.w;
      r11.x = 0x0000ffff & asint(cb13[r6.w+2366].w);
      r11.x = (uint)r11.x;
      r11.x = 1.52590219e-005 * r11.x;
      r10.x = dot(r10.xyz, r10.xyz);
      r10.x = sqrt(r10.x);
      r10.x = 1 + -r10.x;
      r10.x = max(0, r10.x);
      r10.xy = cb13[r6.w+2367].wx * r10.xx;
      r10.x = saturate(r10.x);
      r10.z = cmp(-1.000000 == cb13[r6.w+2367].w);
      r11.y = cmp(r10.w >= r4.y);
      r8.y = r11.y ? 1.000000 : 0;
      r10.w = cmp(r10.w >= r4.w);
      r10.w = r10.w ? 1.000000 : 0;
      r11.x = r11.x * r10.w;
      r11.y = min(0.998037279, r10.y);
      r11.zw = cb13[r6.w+2367].yz * r10.xx;
      r10.xyzw = r10.zzzz ? r8.xyzw : r11.xyzw;
      r9.xyzw = max(r9.xyzw, r10.xyzw);
    }
    r4.z = (int)r4.z + 1;
  }
  r2.x = r9.y * r9.y;
  r2.y = cmp(0 < r9.x);
  r2.z = r2.y ? 0 : 1;
  r2.w = r3.w * r3.w;
  r2.z = min(r2.z, r2.w);
  r2.x = max(r2.z, r2.x);
  r2.x = 1 + -r2.x;
  r2.z = 1 + -r9.x;
  r2.w = 1 + -cb13[33].y;
  r2.y = r2.y ? r2.z : r2.w;
  r2.zw = float2(1,1) + -r9.zw;
  r2.y = min(r2.y, r2.z);
  r2.y = r2.y + -r2.w;
  r5.y = saturate(r2.x * r2.y + r2.w);
  r5.z = saturate(1 + -r2.x);
  r2.x = cmp(0 < r3.z);
  r2.y = max(abs(r3.x), abs(r3.y));
  r2.y = 1 + -r2.y;
  r2.y = saturate(10 * r2.y);
  r2.x = r2.x ? r2.y : 0;
  r2.yzw = -cb1[8].xyz + r0.xyz;
  r3.x = dot(r2.yzw, r2.yzw);
  r3.x = rsqrt(r3.x);
  r2.yzw = r3.xxx * r2.yzw;
  r3.x = dot(r2.yzw, r1.xyz);
  r3.x = r3.x + r3.x;
  r2.yzw = mad(-r3.xxx, r1.xyz, r2.yzw);
  r3.x = cmp(r1.z < 0);
  r3.y = r3.x ? 1.f : 0.f;
  r4.xyzw = float4(0.5,-0.5,-0.5,0.5) * r1.xyxy;
  r3.z = mad(-r7.z, r0.w, 1);
  r3.z = max(0.00100000005, r3.z);
  r3.zw = r4.xy / r3.zz;
  r3.zw = float2(0.5,0.5) + r3.zw;
  r0.w = mad(r7.z, r0.w, 1);
  r0.w = max(0.00100000005, r0.w);
  r4.xy = r4.zw / r0.ww;
  r4.xy = float2(0.5,0.5) + r4.xy;
  r3.xz = r3.xx ? r3.zw : r4.xy;
  r3.xz = mad(r3.xz, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
  r4.x = (int)r3.y;
  r4.y = 0;
  r3.xy = r4.xy + r3.xz;
  r3.xy = float2(0.5,0.142857149) * r3.xy;
  r4.xyz = cb12[114].xyz * r0.yyy;
  r4.xyz = mad(cb12[113].xyz, r0.xxx, r4.xyz);
  r4.xyz = mad(cb12[115].xyz, r0.zzz, r4.xyz);
  r4.xyz = cb12[116].xyz + r4.xyz;
  r4.xyz = float3(1,1,1) + -abs(r4.xyz);
  r8.xy = asint(cb12[117].yy) & int2(1,2);
  r0.w = r8.x ? 1 : r5.z;
  r4.w = 1 + -r5.z;
  r6.w = r8.y ? 1 : r4.w;
  r0.w = r6.w * r0.w;
  r8.xyz = cmp(float3(0,0,0) < r4.xyz);
  r6.w = r8.y ? r8.x : 0;
  r6.w = r8.z ? r6.w : 0;
  r7.z = cmp(0 < r0.w);
  r6.w = r7.z ? r6.w : 0;
  if (r6.w != 0) {
    r4.xyz = saturate(cb12[112].xyz * r4.xyz);
    r0.w = cb12[111].x * r0.w;
    r0.w = 0.999989986 * r0.w;
    r4.x = r4.x * r4.y;
    r4.x = r4.x * r4.z;
    r4.y = r4.x * r0.w;
    r0.w = mad(r0.w, r4.x, 9.99999975e-006);
    r4.x = cb12[117].x * r4.y;
    r4.y = asint(cb12[122].x);
    r3.z = mad(r4.y, 0.142857149, r3.y);
    r8.xyz = t22.SampleLevel(s11_s, r3.xz, 1).xyz;
    r8.xyz = r8.xyz * r4.xxx;
    r3.z = dot(r2.yzw, r2.yzw);
    r3.z = rsqrt(r3.z);
    r9.xyz = r3.zzz * r2.yzw;
    r4.y = cmp(r9.z < 0);
    r4.z = r4.y ? 1.f : 0.f;
    r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r9.xyxy;
    r6.w = mad(-r2.w, r3.z, 1);
    r6.w = max(0.00100000005, r6.w);
    r9.xy = r9.xy / r6.ww;
    r3.z = mad(r2.w, r3.z, 1);
    r3.z = max(0.00100000005, r3.z);
    r9.zw = r9.zw / r3.zz;
    r9.xyzw = float4(0.5,0.5,0.5,0.5) + r9.xyzw;
    r9.xy = r4.yy ? r9.xy : r9.zw;
    r9.xy = mad(r9.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
    r10.y = asint(cb12[122].x);
    r10.z = (int)r4.z;
    r10.xw = float2(0,0);
    r4.yz = r10.zw + r9.xy;
    r4.yz = r10.xy + r4.yz;
    r4.yz = float2(0.5,0.142857149) * r4.yz;
    r9.xyz = t23.SampleLevel(s11_s, r4.yz, 5).xyz;
    r4.xyz = r9.xyz * r4.xxx;
  } else {
    r8.xyz = float3(0,0,0);
    r4.xyz = float3(0,0,0);
    r0.w = 9.99999975e-006;
  }
  r3.z = cmp(r0.w < 0.999000013);
  if (r3.z != 0) {
    r9.xyz = cb12[126].xyz * r0.yyy;
    r9.xyz = mad(cb12[125].xyz, r0.xxx, r9.xyz);
    r9.xyz = mad(cb12[127].xyz, r0.zzz, r9.xyz);
    r9.xyz = cb12[128].xyz + r9.xyz;
    r9.xyz = float3(1,1,1) + -abs(r9.xyz);
    r10.xy = asint(cb12[129].yy) & int2(1,2);
    r6.w = r10.x ? 1 : r5.z;
    r7.z = r10.y ? 1 : r4.w;
    r6.w = r7.z * r6.w;
    r10.xyz = cmp(float3(0,0,0) < r9.xyz);
    r7.z = r10.y ? r10.x : 0;
    r7.z = r10.z ? r7.z : 0;
    r8.w = cmp(0 < r6.w);
    r7.z = r8.w ? r7.z : 0;
    if (r7.z != 0) {
      r9.xyz = saturate(cb12[124].xyz * r9.xyz);
      r7.z = 1 + -r0.w;
      r6.w = r7.z * r6.w;
      r6.w = cb12[123].x * r6.w;
      r7.z = r9.x * r9.y;
      r7.z = r7.z * r9.z;
      r8.w = r7.z * r6.w;
      r0.w = mad(r6.w, r7.z, r0.w);
      r6.w = cb12[129].x * r8.w;
      r7.z = asint(cb12[134].x);
      r3.w = mad(r7.z, 0.142857149, r3.y);
      r9.xyz = t22.SampleLevel(s11_s, r3.xw, 1).xyz;
      r8.xyz = mad(r6.www, r9.xyz, r8.xyz);
      r3.w = dot(r2.yzw, r2.yzw);
      r3.w = rsqrt(r3.w);
      r9.xyz = r3.www * r2.yzw;
      r7.z = cmp(r9.z < 0);
      r8.w = r7.z ? 1.f : 0.f;
      r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r9.xyxy;
      r10.x = mad(-r2.w, r3.w, 1);
      r10.x = max(0.00100000005, r10.x);
      r9.xy = r9.xy / r10.xx;
      r3.w = mad(r2.w, r3.w, 1);
      r3.w = max(0.00100000005, r3.w);
      r9.zw = r9.zw / r3.ww;
      r9.xyzw = float4(0.5,0.5,0.5,0.5) + r9.xyzw;
      r9.xy = r7.zz ? r9.xy : r9.zw;
      r9.xy = mad(r9.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r10.y = asint(cb12[134].x);
      r10.z = (int)r8.w;
      r10.xw = float2(0,0);
      r9.xy = r10.zw + r9.xy;
      r9.xy = r10.xy + r9.xy;
      r9.xy = float2(0.5,0.142857149) * r9.xy;
      r9.xyz = t23.SampleLevel(s11_s, r9.xy, 5).xyz;
      r4.xyz = mad(r6.www, r9.xyz, r4.xyz);
    }
  }
  r3.w = cmp(r0.w < 0.999000013);
  r3.z = r3.w ? r3.z : 0;
  if (r3.z != 0) {
    r9.xyz = cb12[138].xyz * r0.yyy;
    r9.xyz = mad(cb12[137].xyz, r0.xxx, r9.xyz);
    r9.xyz = mad(cb12[139].xyz, r0.zzz, r9.xyz);
    r9.xyz = cb12[140].xyz + r9.xyz;
    r9.xyz = float3(1,1,1) + -abs(r9.xyz);
    r10.xy = asint(cb12[141].yy) & int2(1,2);
    r3.w = r10.x ? 1 : r5.z;
    r6.w = r10.y ? 1 : r4.w;
    r3.w = r6.w * r3.w;
    r10.xyz = cmp(float3(0,0,0) < r9.xyz);
    r6.w = r10.y ? r10.x : 0;
    r6.w = r10.z ? r6.w : 0;
    r7.z = cmp(0 < r3.w);
    r6.w = r7.z ? r6.w : 0;
    if (r6.w != 0) {
      r9.xyz = saturate(cb12[136].xyz * r9.xyz);
      r6.w = 1 + -r0.w;
      r3.w = r6.w * r3.w;
      r3.w = cb12[135].x * r3.w;
      r6.w = r9.x * r9.y;
      r6.w = r6.w * r9.z;
      r7.z = r6.w * r3.w;
      r0.w = mad(r3.w, r6.w, r0.w);
      r3.w = cb12[141].x * r7.z;
      r6.w = asint(cb12[146].x);
      r9.y = mad(r6.w, 0.142857149, r3.y);
      r9.x = r3.x;
      r9.xyz = t22.SampleLevel(s11_s, r9.xy, 1).xyz;
      r8.xyz = mad(r3.www, r9.xyz, r8.xyz);
      r6.w = dot(r2.yzw, r2.yzw);
      r6.w = rsqrt(r6.w);
      r9.xyz = r6.www * r2.yzw;
      r7.z = cmp(r9.z < 0);
      r8.w = r7.z ? 1.f : 0.f;
      r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r9.xyxy;
      r10.x = mad(-r2.w, r6.w, 1);
      r10.x = max(0.00100000005, r10.x);
      r9.xy = r9.xy / r10.xx;
      r6.w = mad(r2.w, r6.w, 1);
      r6.w = max(0.00100000005, r6.w);
      r9.zw = r9.zw / r6.ww;
      r9.xyzw = float4(0.5,0.5,0.5,0.5) + r9.xyzw;
      r9.xy = r7.zz ? r9.xy : r9.zw;
      r9.xy = mad(r9.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r10.y = asint(cb12[146].x);
      r10.z = (int)r8.w;
      r10.xw = float2(0,0);
      r9.xy = r10.zw + r9.xy;
      r9.xy = r10.xy + r9.xy;
      r9.xy = float2(0.5,0.142857149) * r9.xy;
      r9.xyz = t23.SampleLevel(s11_s, r9.xy, 5).xyz;
      r4.xyz = mad(r3.www, r9.xyz, r4.xyz);
    }
  }
  r3.w = cmp(r0.w < 0.999000013);
  r3.z = r3.w ? r3.z : 0;
  if (r3.z != 0) {
    r9.xyz = cb12[150].xyz * r0.yyy;
    r9.xyz = mad(cb12[149].xyz, r0.xxx, r9.xyz);
    r9.xyz = mad(cb12[151].xyz, r0.zzz, r9.xyz);
    r9.xyz = cb12[152].xyz + r9.xyz;
    r9.xyz = float3(1,1,1) + -abs(r9.xyz);
    r10.xy = asint(cb12[153].yy) & int2(1,2);
    r3.w = r10.x ? 1 : r5.z;
    r6.w = r10.y ? 1 : r4.w;
    r3.w = r6.w * r3.w;
    r10.xyz = cmp(float3(0,0,0) < r9.xyz);
    r6.w = r10.y ? r10.x : 0;
    r6.w = r10.z ? r6.w : 0;
    r7.z = cmp(0 < r3.w);
    r6.w = r7.z ? r6.w : 0;
    if (r6.w != 0) {
      r9.xyz = saturate(cb12[148].xyz * r9.xyz);
      r6.w = 1 + -r0.w;
      r3.w = r6.w * r3.w;
      r3.w = cb12[147].x * r3.w;
      r6.w = r9.x * r9.y;
      r6.w = r6.w * r9.z;
      r7.z = r6.w * r3.w;
      r0.w = mad(r3.w, r6.w, r0.w);
      r3.w = cb12[153].x * r7.z;
      r6.w = asint(cb12[158].x);
      r9.y = mad(r6.w, 0.142857149, r3.y);
      r9.x = r3.x;
      r9.xyz = t22.SampleLevel(s11_s, r9.xy, 1).xyz;
      r8.xyz = mad(r3.www, r9.xyz, r8.xyz);
      r6.w = dot(r2.yzw, r2.yzw);
      r6.w = rsqrt(r6.w);
      r9.xyz = r6.www * r2.yzw;
      r7.z = cmp(r9.z < 0);
      r8.w = r7.z ? 1.f : 0.f;
      r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r9.xyxy;
      r10.x = mad(-r2.w, r6.w, 1);
      r10.x = max(0.00100000005, r10.x);
      r9.xy = r9.xy / r10.xx;
      r6.w = mad(r2.w, r6.w, 1);
      r6.w = max(0.00100000005, r6.w);
      r9.zw = r9.zw / r6.ww;
      r9.xyzw = float4(0.5,0.5,0.5,0.5) + r9.xyzw;
      r9.xy = r7.zz ? r9.xy : r9.zw;
      r9.xy = mad(r9.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r10.y = asint(cb12[158].x);
      r10.z = (int)r8.w;
      r10.xw = float2(0,0);
      r9.xy = r10.zw + r9.xy;
      r9.xy = r10.xy + r9.xy;
      r9.xy = float2(0.5,0.142857149) * r9.xy;
      r9.xyz = t23.SampleLevel(s11_s, r9.xy, 5).xyz;
      r4.xyz = mad(r3.www, r9.xyz, r4.xyz);
    }
  }
  r3.w = cmp(r0.w < 0.999000013);
  r3.z = r3.w ? r3.z : 0;
  if (r3.z != 0) {
    r9.xyz = cb12[162].xyz * r0.yyy;
    r9.xyz = mad(cb12[161].xyz, r0.xxx, r9.xyz);
    r9.xyz = mad(cb12[163].xyz, r0.zzz, r9.xyz);
    r9.xyz = cb12[164].xyz + r9.xyz;
    r9.xyz = float3(1,1,1) + -abs(r9.xyz);
    r10.xy = asint(cb12[165].yy) & int2(1,2);
    r3.w = r10.x ? 1 : r5.z;
    r6.w = r10.y ? 1 : r4.w;
    r3.w = r6.w * r3.w;
    r10.xyz = cmp(float3(0,0,0) < r9.xyz);
    r6.w = r10.y ? r10.x : 0;
    r6.w = r10.z ? r6.w : 0;
    r7.z = cmp(0 < r3.w);
    r6.w = r7.z ? r6.w : 0;
    if (r6.w != 0) {
      r9.xyz = saturate(cb12[160].xyz * r9.xyz);
      r6.w = 1 + -r0.w;
      r3.w = r6.w * r3.w;
      r3.w = cb12[159].x * r3.w;
      r6.w = r9.x * r9.y;
      r6.w = r6.w * r9.z;
      r7.z = r6.w * r3.w;
      r0.w = mad(r3.w, r6.w, r0.w);
      r3.w = cb12[165].x * r7.z;
      r6.w = asint(cb12[170].x);
      r9.y = mad(r6.w, 0.142857149, r3.y);
      r9.x = r3.x;
      r9.xyz = t22.SampleLevel(s11_s, r9.xy, 1).xyz;
      r8.xyz = mad(r3.www, r9.xyz, r8.xyz);
      r6.w = dot(r2.yzw, r2.yzw);
      r6.w = rsqrt(r6.w);
      r9.xyz = r6.www * r2.yzw;
      r7.z = cmp(r9.z < 0);
      r8.w = r7.z ? 1.f : 0.f;
      r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r9.xyxy;
      r10.x = mad(-r2.w, r6.w, 1);
      r10.x = max(0.00100000005, r10.x);
      r9.xy = r9.xy / r10.xx;
      r6.w = mad(r2.w, r6.w, 1);
      r6.w = max(0.00100000005, r6.w);
      r9.zw = r9.zw / r6.ww;
      r9.xyzw = float4(0.5,0.5,0.5,0.5) + r9.xyzw;
      r9.xy = r7.zz ? r9.xy : r9.zw;
      r9.xy = mad(r9.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r10.y = asint(cb12[170].x);
      r10.z = (int)r8.w;
      r10.xw = float2(0,0);
      r9.xy = r10.zw + r9.xy;
      r9.xy = r10.xy + r9.xy;
      r9.xy = float2(0.5,0.142857149) * r9.xy;
      r9.xyz = t23.SampleLevel(s11_s, r9.xy, 5).xyz;
      r4.xyz = mad(r3.www, r9.xyz, r4.xyz);
    }
  }
  r3.w = cmp(r0.w < 0.999000013);
  r3.z = r3.w ? r3.z : 0;
  if (r3.z != 0) {
    r9.xyz = cb12[174].xyz * r0.yyy;
    r9.xyz = mad(cb12[173].xyz, r0.xxx, r9.xyz);
    r9.xyz = mad(cb12[175].xyz, r0.zzz, r9.xyz);
    r9.xyz = cb12[176].xyz + r9.xyz;
    r9.xyz = float3(1,1,1) + -abs(r9.xyz);
    r3.zw = asint(cb12[177].yy) & int2(1,2);
    r3.z = r3.z ? 1 : r5.z;
    r3.w = r3.w ? 1 : r4.w;
    r3.z = r3.z * r3.w;
    r10.xyz = cmp(float3(0,0,0) < r9.xyz);
    r3.w = r10.y ? r10.x : 0;
    r3.w = r10.z ? r3.w : 0;
    r4.w = cmp(0 < r3.z);
    r3.w = r4.w ? r3.w : 0;
    if (r3.w != 0) {
      r9.xyz = saturate(cb12[172].xyz * r9.xyz);
      r3.w = 1 + -r0.w;
      r3.z = r3.w * r3.z;
      r3.z = cb12[171].x * r3.z;
      r3.w = r9.x * r9.y;
      r3.w = r3.w * r9.z;
      r4.w = r3.z * r3.w;
      r0.w = mad(r3.z, r3.w, r0.w);
      r3.z = cb12[177].x * r4.w;
      r3.w = asint(cb12[182].x);
      r9.y = mad(r3.w, 0.142857149, r3.y);
      r9.x = r3.x;
      r9.xyz = t22.SampleLevel(s11_s, r9.xy, 1).xyz;
      r8.xyz = mad(r3.zzz, r9.xyz, r8.xyz);
      r3.w = dot(r2.yzw, r2.yzw);
      r3.w = rsqrt(r3.w);
      r9.xyz = r3.www * r2.yzw;
      r4.w = cmp(r9.z < 0);
      r6.w = r4.w ? 1.f : 0.f;
      r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r9.xyxy;
      r7.z = mad(-r2.w, r3.w, 1);
      r7.z = max(0.00100000005, r7.z);
      r9.xy = r9.xy / r7.zz;
      r3.w = mad(r2.w, r3.w, 1);
      r3.w = max(0.00100000005, r3.w);
      r9.zw = r9.zw / r3.ww;
      r9.xyzw = float4(0.5,0.5,0.5,0.5) + r9.xyzw;
      r9.xy = r4.ww ? r9.xy : r9.zw;
      r9.xy = mad(r9.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r10.y = asint(cb12[182].x);
      r10.z = (int)r6.w;
      r10.xw = float2(0,0);
      r9.xy = r10.zw + r9.xy;
      r9.xy = r10.xy + r9.xy;
      r9.xy = float2(0.5,0.142857149) * r9.xy;
      r9.xyz = t23.SampleLevel(s11_s, r9.xy, 5).xyz;
      r4.xyz = mad(r3.zzz, r9.xyz, r4.xyz);
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
    r8.xyz = mad(r3.zzz, r3.xyw, r8.xyz);
    r3.x = cmp(r2.w < 0);
    r3.y = r3.x ? 1.f : 0.f;
    r9.xyzw = float4(0.5,-0.5,-0.5,0.5) * r2.yzyz;
    r2.y = 1 + -r2.w;
    r2.y = max(0.00100000005, r2.y);
    r2.yz = r9.xy / r2.yy;
    r2.yz = float2(0.5,0.5) + r2.yz;
    r2.w = 1 + r2.w;
    r2.w = max(0.00100000005, r2.w);
    r9.xy = r9.zw / r2.ww;
    r9.xy = float2(0.5,0.5) + r9.xy;
    r2.yz = r3.xx ? r2.yz : r9.xy;
    r2.yz = mad(r2.yz, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
    r9.y = asint(cb12[110].x);
    r9.z = (int)r3.y;
    r9.xw = float2(0,0);
    r2.yz = r9.zw + r2.yz;
    r2.yz = r9.xy + r2.yz;
    r2.yz = float2(0.5,0.142857149) * r2.yz;
    r2.yzw = t23.SampleLevel(s11_s, r2.yz, 5).xyz;
    r4.xyz = mad(r3.zzz, r2.yzw, r4.xyz);
  }
  r0.w = 1 / r0.w;
  r2.yzw = r8.xyz * r0.www;
  r3.xyz = r4.xyz * r0.www;
  o3.xyz = r2.yzw * r2.xxx;
  o4.xyz = r3.xyz * r2.xxx;
  r2.yzw = r7.xyw / r1.www;
  r0.w = -cb12[22].z + r1.w;
  r0.w = max(0, r0.w);
  r0.w = min(cb12[42].z, r0.w);
  r1.w = dot(cb12[38].xyz, r2.yzw);
  r2.y = abs(r1.w) * abs(r1.w);
  r2.z = saturate(r0.w * 0.00200000009 + -0.300000012);
  r2.y = r2.y * r2.z;
  r2.z = cmp(0 < r1.w);
  r3.xyz = r2.zzz ? cb12[39].xyz : cb12[41].xyz;
  r3.xyz = -cb12[40].xyz + r3.xyz;
  r3.xyz = mad(r2.yyy, r3.xyz, cb12[40].xyz);
  r4.xyz = r2.zzz ? cb12[45].xyz : cb12[47].xyz;
  r4.xyz = -cb12[46].xyz + r4.xyz;
  o0.xyz = r2.yyy * r4.xyz + cb12[46].xyz;
  r2.y = cmp(r0.w >= cb12[48].y);
  if (r2.y != 0) {
    r2.y = mad(r2.w, cb12[22].z, cb12[0].z);
    r2.z = r2.w * r0.w;
    r2.w = cb12[43].x * r0.w;
    r2.zw = float2(0.0625,0.0625) * r2.zw;
    r1.w = cb12[42].x + r1.w;
    r3.w = 1 + cb12[42].x;
    r1.w = saturate(r1.w / r3.w);
    r3.w = cb12[43].y + -cb12[43].z;
    r1.w = mad(r1.w, r3.w, cb12[43].z);
    r2.y = cb12[42].y + r2.y;
    r3.w = r2.y * r1.w;
    r2.z = r2.z * r1.w;
    r4.xyzw = mad(r2.zzzz, float4(16,15,14,13), r3.wwww);
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.wwww / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r4.x = r4.x * r4.y;
    r4.x = r4.x * r4.z;
    r4.x = r4.x * r4.w;
    r7.xyzw = mad(r2.zzzz, float4(12,11,10,9), r3.wwww);
    r7.xyzw = max(float4(0,0,0,0), r7.xyzw);
    r7.xyzw = float4(1,1,1,1) + r7.xyzw;
    r7.xyzw = saturate(r2.wwww / r7.xyzw);
    r7.xyzw = float4(1,1,1,1) + -r7.xyzw;
    r4.x = r7.x * r4.x;
    r4.x = r4.x * r7.y;
    r4.x = r4.x * r7.z;
    r4.x = r4.x * r7.w;
    r7.xyzw = mad(r2.zzzz, float4(8,7,6,5), r3.wwww);
    r7.xyzw = max(float4(0,0,0,0), r7.xyzw);
    r7.xyzw = float4(1,1,1,1) + r7.xyzw;
    r7.xyzw = saturate(r2.wwww / r7.xyzw);
    r7.xyzw = float4(1,1,1,1) + -r7.xyzw;
    r4.x = r7.x * r4.x;
    r4.x = r4.x * r7.y;
    r4.x = r4.x * r7.z;
    r4.x = r4.x * r7.w;
    r4.yz = mad(r2.zz, float2(4,3), r3.ww);
    r4.yz = max(float2(0,0), r4.yz);
    r4.yz = float2(1,1) + r4.yz;
    r4.yz = saturate(r2.ww / r4.yz);
    r4.yz = float2(1,1) + -r4.yz;
    r4.x = r4.x * r4.y;
    r4.x = r4.x * r4.z;
    r3.w = mad(r2.z, 2, r3.w);
    r3.w = max(0, r3.w);
    r3.w = 1 + r3.w;
    r3.w = saturate(r2.w / r3.w);
    r3.w = 1 + -r3.w;
    r3.w = r4.x * r3.w;
    r1.w = mad(r2.y, r1.w, r2.z);
    r1.w = max(0, r1.w);
    r1.w = 1 + r1.w;
    r1.w = saturate(r2.w / r1.w);
    r1.w = 1 + -r1.w;
    r1.w = mad(-r3.w, r1.w, 1);
    r0.w = -cb12[48].y + r0.w;
    r0.w = saturate(cb12[48].z * r0.w);
  } else {
    r1.w = 1;
    r0.w = 0;
  }
  r1.w = log2(r1.w);
  r2.y = cb12[42].w * r1.w;
  r2.y = exp2(r2.y);
  r2.y = r2.y * r0.w;
  r1.w = cb12[48].x * r1.w;
  r1.w = exp2(r1.w);
  o0.w = r1.w * r0.w;
  r2.zw = saturate(r2.yy * cb12[189].xz + cb12[189].yw);
  r4.xyz = cb12[188].xyz + -r3.xyz;
  r4.xyz = mad(r2.zzz, r4.xyz, r3.xyz);
  r0.w = -1 + cb12[188].w;
  r0.w = mad(r2.w, r0.w, 1);
  r4.w = saturate(r2.y * r0.w);
  r0.w = cmp(0 < cb12[192].x);
  if (r0.w != 0) {
    r2.zw = saturate(r2.yy * cb12[191].xz + cb12[191].yw);
    r7.xyz = cb12[190].xyz + -r3.xyz;
    r3.xyz = mad(r2.zzz, r7.xyz, r3.xyz);
    r0.w = -1 + cb12[190].w;
    r0.w = mad(r2.w, r0.w, 1);
    r3.w = saturate(r2.y * r0.w);
    r3.xyzw = r3.xyzw + -r4.xyzw;
    o5.xyzw = cb12[192].xxxx * r3.xyzw + r4.xyzw;
  } else {
    o5.xyzw = r4.xyzw;
  }
  r5.w = 1;
  o6.xyzw = r5.xyzw * r2.xxxx;
  o1.w = v3.x;
  o2.xyzw = v11.xyzw;
  o3.w = v3.y;
  o4.w = r6.x;
  o7.xy = v3.xy;
  o7.zw = r6.yz;
  o8.xyzw = v6.xyzw;
  o9.xyz = r1.xyz;
  o10.xyz = r0.xyz;
  return;
}
