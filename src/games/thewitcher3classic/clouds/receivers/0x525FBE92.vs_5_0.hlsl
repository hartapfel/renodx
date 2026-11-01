#include "../shadow_inputs.hlsli"
ByteAddressBuffer Raw21 : register(t21);
// ---- Created with 3Dmigoto v1.3.16 on Sat Oct 31 15:08:28 2026
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
  float4 cb12[183];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[4];
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

cbuffer cb0 : register(b0)
{
  float4 cb0[1];
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
  out float3 o9 : TEXCOORD9,
  out precise float4 o10 : SV_Position0)
{
  const float4 icb[] = { { 1.000000, 0, 0, 0},
                              { 0, 1.000000, 0, 0},
                              { 0, 0, 1.000000, 0},
                              { 0, 0, 0, 1.000000} };
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20;
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
  r3.z = t0[r2.x].val[48/4+2];
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
  r7.x = dot(r0.xyzw, r7.xyzw);
  r8.x = r4.y;
  r8.y = r5.y;
  r8.z = r6.y;
  r8.w = r3.y;
  r7.y = dot(r0.xyzw, r8.xyzw);
  r8.x = r4.z;
  r8.y = r5.z;
  r8.z = r6.z;
  r8.w = r3.z;
  r7.z = dot(r0.xyzw, r8.xyzw);
  r8.x = r4.w;
  r8.y = r5.w;
  r8.z = r6.w;
  r8.w = 1;
  r7.w = dot(r0.xyzw, r8.xyzw);
  r1.xyzw = v2.xyzw / r1.xxxx;
  r8.x = t0[r2.y].val[48/4];
  r8.y = t0[r2.y].val[48/4+1];
  r8.z = t0[r2.y].val[48/4+2];
  r9.x = t0[r2.y].val[0/4];
  r9.y = t0[r2.y].val[0/4+1];
  r9.z = t0[r2.y].val[0/4+2];
  r9.w = t0[r2.y].val[0/4+3];
  r10.x = t0[r2.y].val[16/4];
  r10.y = t0[r2.y].val[16/4+1];
  r10.z = t0[r2.y].val[16/4+2];
  r10.w = t0[r2.y].val[16/4+3];
  r11.x = t0[r2.y].val[32/4];
  r11.y = t0[r2.y].val[32/4+1];
  r11.z = t0[r2.y].val[32/4+2];
  r11.w = t0[r2.y].val[32/4+3];
  r12.x = r9.x;
  r12.y = r10.x;
  r12.z = r11.x;
  r12.w = r8.x;
  r12.x = dot(r0.xyzw, r12.xyzw);
  r13.x = r9.y;
  r13.y = r10.y;
  r13.z = r11.y;
  r13.w = r8.y;
  r12.y = dot(r0.xyzw, r13.xyzw);
  r13.x = r9.z;
  r13.y = r10.z;
  r13.z = r11.z;
  r13.w = r8.z;
  r12.z = dot(r0.xyzw, r13.xyzw);
  r13.x = r9.w;
  r13.y = r10.w;
  r13.z = r11.w;
  r13.w = 1;
  r12.w = dot(r0.xyzw, r13.xyzw);
  r12.xyzw = r12.xyzw * r1.yyyy;
  r7.xyzw = mad(r7.xyzw, r1.xxxx, r12.xyzw);
  r12.x = t0[r2.z].val[48/4];
  r12.y = t0[r2.z].val[48/4+1];
  r12.z = t0[r2.z].val[48/4+2];
  r13.x = t0[r2.z].val[0/4];
  r13.y = t0[r2.z].val[0/4+1];
  r13.z = t0[r2.z].val[0/4+2];
  r13.w = t0[r2.z].val[0/4+3];
  r14.x = t0[r2.z].val[16/4];
  r14.y = t0[r2.z].val[16/4+1];
  r14.z = t0[r2.z].val[16/4+2];
  r14.w = t0[r2.z].val[16/4+3];
  r15.x = t0[r2.z].val[32/4];
  r15.y = t0[r2.z].val[32/4+1];
  r15.z = t0[r2.z].val[32/4+2];
  r15.w = t0[r2.z].val[32/4+3];
  r16.x = r13.x;
  r16.y = r14.x;
  r16.z = r15.x;
  r16.w = r12.x;
  r16.x = dot(r0.xyzw, r16.xyzw);
  r17.x = r13.y;
  r17.y = r14.y;
  r17.z = r15.y;
  r17.w = r12.y;
  r16.y = dot(r0.xyzw, r17.xyzw);
  r17.x = r13.z;
  r17.y = r14.z;
  r17.z = r15.z;
  r17.w = r12.z;
  r16.z = dot(r0.xyzw, r17.xyzw);
  r17.x = r13.w;
  r17.y = r14.w;
  r17.z = r15.w;
  r17.w = 1;
  r16.w = dot(r0.xyzw, r17.xyzw);
  r7.xyzw = mad(r16.xyzw, r1.zzzz, r7.xyzw);
  r16.x = t0[r2.w].val[48/4];
  r16.y = t0[r2.w].val[48/4+1];
  r16.z = t0[r2.w].val[48/4+2];
  r17.x = t0[r2.w].val[0/4];
  r17.y = t0[r2.w].val[0/4+1];
  r17.z = t0[r2.w].val[0/4+2];
  r17.w = t0[r2.w].val[0/4+3];
  r18.x = t0[r2.w].val[16/4];
  r18.y = t0[r2.w].val[16/4+1];
  r18.z = t0[r2.w].val[16/4+2];
  r18.w = t0[r2.w].val[16/4+3];
  r2.x = t0[r2.w].val[32/4];
  r2.y = t0[r2.w].val[32/4+1];
  r2.z = t0[r2.w].val[32/4+2];
  r2.w = t0[r2.w].val[32/4+3];
  r19.x = r17.x;
  r19.y = r18.x;
  r19.z = r2.x;
  r19.w = r16.x;
  r19.x = dot(r0.xyzw, r19.xyzw);
  r20.x = r17.y;
  r20.y = r18.y;
  r20.z = r2.y;
  r20.w = r16.y;
  r19.y = dot(r0.xyzw, r20.xyzw);
  r20.x = r17.z;
  r20.y = r18.z;
  r20.z = r2.z;
  r20.w = r16.z;
  r19.z = dot(r0.xyzw, r20.xyzw);
  r20.x = r17.w;
  r20.y = r18.w;
  r20.z = r2.w;
  r20.w = 1;
  r19.w = dot(r0.xyzw, r20.xyzw);
  r7.xyzw = mad(r19.xyzw, r1.wwww, r7.xyzw);
  r3.w = 1;
  r9.xyzw = r9.xyzw * r1.yyyy;
  r10.xyzw = r10.xyzw * r1.yyyy;
  r11.xyzw = r11.xyzw * r1.yyyy;
  r8.w = 1;
  r8.xyzw = r8.xyzw * r1.yyyy;
  r4.xyzw = mad(r4.xyzw, r1.xxxx, r9.xyzw);
  r5.xyzw = mad(r5.xyzw, r1.xxxx, r10.xyzw);
  r6.xyzw = mad(r6.xyzw, r1.xxxx, r11.xyzw);
  r3.xyzw = mad(r3.xyzw, r1.xxxx, r8.xyzw);
  r12.w = 1;
  r4.xyzw = mad(r13.xyzw, r1.zzzz, r4.xyzw);
  r5.xyzw = mad(r14.xyzw, r1.zzzz, r5.xyzw);
  r6.xyzw = mad(r15.xyzw, r1.zzzz, r6.xyzw);
  r3.xyzw = mad(r12.xyzw, r1.zzzz, r3.xyzw);
  r16.w = 1;
  r4.xyzw = mad(r17.xyzw, r1.wwww, r4.xyzw);
  r5.xyzw = mad(r18.xyzw, r1.wwww, r5.xyzw);
  r2.xyzw = mad(r2.xyzw, r1.wwww, r6.xyzw);
  r1.xyzw = mad(r16.xyzw, r1.wwww, r3.xyzw);
  o0.x = dot(r0.xyzw, cb3[7].xyzw);
  o0.y = dot(r0.xyzw, cb3[8].xyzw);
  o0.z = dot(r0.xyzw, cb3[9].xyzw);
  r3.x = dot(r7.xyzw, v8.xyzw);
  r3.y = dot(r7.xyzw, v9.xyzw);
  r3.z = dot(r7.xyzw, v10.xyzw);
  r6.x = dot(r4.xyzw, v8.xyzw);
  r7.x = dot(r4.xyzw, v9.xyzw);
  r8.x = dot(r4.xyzw, v10.xyzw);
  r6.y = dot(r5.xyzw, v8.xyzw);
  r7.y = dot(r5.xyzw, v9.xyzw);
  r8.y = dot(r5.xyzw, v10.xyzw);
  r6.z = dot(r2.xyzw, v8.xyzw);
  r7.z = dot(r2.xyzw, v9.xyzw);
  r8.z = dot(r2.xyzw, v10.xyzw);
  r6.w = dot(r1.xyzw, v8.xyzw);
  r7.w = dot(r1.xyzw, v9.xyzw);
  r8.w = dot(r1.xyzw, v10.xyzw);
  r9.xyz = mad(v4.xyz, float3(2,2,2), float3(-1,-1,-1));
  r10.xyzw = mad(v5.xyzw, float4(2,2,2,2), float4(-1,-1,-1,-1));
  r11.xyz = r10.yzx * r9.zxy;
  r11.xyz = mad(r9.yzx, r10.zxy, -r11.xyz);
  r11.xyz = r11.xyz * r10.www;
  r0.w = dot(r11.xyz, r11.xyz);
  r0.w = rsqrt(r0.w);
  r11.xyz = r11.xyz * r0.www;
  r12.x = dot(r9.xyz, r6.xyz);
  r12.y = dot(r9.xyz, r7.xyz);
  r12.z = dot(r9.xyz, r8.xyz);
  r0.w = dot(r12.xyz, r12.xyz);
  r0.w = rsqrt(r0.w);
  r9.xyz = r12.xyz * r0.www;
  r13.x = dot(r11.xyz, r6.xyz);
  r13.y = dot(r11.xyz, r7.xyz);
  r13.z = dot(r11.xyz, r8.xyz);
  r3.w = dot(r13.xyz, r13.xyz);
  r3.w = rsqrt(r3.w);
  r11.xyz = r13.xyz * r3.www;
  r13.x = dot(r10.xyz, r6.xyz);
  r13.y = dot(r10.xyz, r7.xyz);
  r13.z = dot(r10.xyz, r8.xyz);
  r3.w = dot(r13.xyz, r13.xyz);
  r3.w = rsqrt(r3.w);
  o9.xyz = r13.xyz * r3.www;
  r10.xyzw = cb12[2].xyzw * r3.yyyy;
  r10.xyzw = mad(cb12[1].xyzw, r3.xxxx, r10.xyzw);
  r10.xyzw = mad(cb12[3].xyzw, r3.zzzz, r10.xyzw);
  r10.xyzw = cb12[4].xyzw + r10.xyzw;
  r12.xyw = cb12[14].xyw * r10.yyy;
  r12.xyw = mad(cb12[13].xyw, r10.xxx, r12.xyw);
  r12.xyw = mad(cb12[15].xyw, r10.zzz, r12.xyw);
  r12.xyw = mad(cb12[16].xyw, r10.www, r12.xyw);
  r3.w = max(9.99999975e-005, r12.w);
  r12.xy = r12.xy / r3.ww;
  r13.xy = mad(r12.xy, float2(0.5,-0.5), float2(0.5,0.5));
  r13.xy = cb12[23].xy * r13.xy;
  r3.w = cmp(0 < asint(cb13[35].x));
  if (r3.w != 0) {
    r13.zw = -cb12[0].xy + r3.xy;
    r3.w = dot(r13.zw, r13.zw);
    r3.w = sqrt(r3.w);
    r9.w = cmp(r3.w < cb13[36].y);
    if (r9.w != 0) {
      r9.w = cb13[37].z * r3.w;
      r9.w = max(1, r9.w);
      r9.w = cb13[36].x / r9.w;
      r9.w = min(1, r9.w);
      r3.w = cb13[36].z + r3.w;
      r3.w = saturate(cb13[36].w * r3.w);
      r14.y = 0;
      r13.zw = float2(0,0);
      r11.w = 0;
      while (true) {
        r14.z = cmp((int)r13.w >= asint(cb13[35].x));
        r11.w = 0;
        if (r14.z != 0) break;
        r14.zw = -cb13[r13.w+39].xy + r3.xy;
        r15.xy = cb13[r13.w+39].zw * r14.zw;
        r16.xy = cmp(r15.xy >= float2(0,0));
        r14.z = r16.y ? r16.x : 0;
        r16.xy = cmp(float2(1,1) >= r15.xy);
        r14.z = r16.x ? r14.z : 0;
        r14.z = r16.y ? r14.z : 0;
        if (r14.z != 0) {
          r15.z = (int)r13.w;
          r15.w = mad(-r14.w, cb13[r13.w+39].w, 1);
          r14.w = t19.SampleLevel(s10_s, r15.xwz, 0).x;
          r14.w = mad(cb13[38].x, r14.w, cb13[38].y);
          r14.w = r14.w + -r3.z;
          r14.w = -0.100000001 + r14.w;
          r14.w = saturate(r14.w * r9.w);
          r14.w = 1 + -r14.w;
          r15.x = 1 + -r14.w;
          r13.z = mad(r3.w, r15.x, r14.w);
          r11.w = -1;
          break;
        }
        r14.x = (int)r13.w + 1;
        r13.zw = r14.yx;
        r11.w = r14.z;
      }
    } else {
      r11.w = 0;
    }
  } else {
    r11.w = 0;
  }
  r14.x = r11.w ? r13.z : 1;
  r3.w = cmp(0 < r14.x);
  if (r3.w != 0) {
    r15.xyz = cb13[5].xyz * r3.yyy;
    r15.xyz = mad(cb13[4].xyz, r3.xxx, r15.xyz);
    r15.xyz = mad(cb13[6].xyz, r3.zzz, r15.xyz);
    r15.xyz = cb13[7].xyz + r15.xyz;
    r3.w = cmp(abs(r15.z) >= 0.999000013);
    if (r3.w != 0) {
      r9.w = 1;
    }
    if (r3.w == 0) {
      r16.xyzw = -cb13[8].xyzw + r15.xxxx;
      r17.xyzw = -cb13[9].xyzw + r15.yyyy;
      r16.xyzw = max(abs(r17.xyzw), abs(r16.xyzw));
      r17.xyzw = cmp(r16.xyzw < cb13[10].xyzw);
      r17.xyzw = r17.xyzw ? float4(1,1,1,1) : 0;
      r18.xyzw = cmp(float4(0.5,1.5,2.5,3.5) < cb13[15].zzzz);
      r18.xyzw = r18.xyzw ? float4(1,1,1,1) : 0;
      r3.w = dot(r17.xyzw, r18.xyzw);
      r11.w = cmp(r3.w < 0.5);
      if (r11.w != 0) {
        r9.w = 1;
      }
      if (r11.w == 0) {
        r16.xyzw = r16.xyzw / cb13[10].xyzw;
        r17.xyzw = float4(1,1,1,1) + -cb13[17].xyzw;
        r16.xyzw = -r17.xyzw + r16.xyzw;
        r16.xyzw = saturate(r16.xyzw / cb13[17].xyzw);
        r3.w = cb13[15].z + -r3.w;
        r13.z = (int)r3.w;
        r13.w = (int)cb13[15].z;
        r13.w = (int)r13.w + -1;
        r17.xy = cb13[r13.z+11].zz * float2(1,-1);
        r17.xy = mad(r15.xy, r17.xy, cb13[r13.z+11].xy);
        r17.z = trunc(r3.w);
        r3.w = cmp(asint(cb13[18].x) >= 1);
        if (r3.w != 0) {
          r3.w = t8.SampleCmpLevelZero(s9_s, r17.xyz, r15.z).x;
          r18.xyzw = mad(cb13[r13.z+11].wwww, float4(-2.10683131,0.317230552,-5.7376194,2.94642639), r17.xyxy);
          r19.xy = r18.xy;
          r19.z = r17.z;
          r15.x = t8.SampleCmpLevelZero(s9_s, r19.xyz, r15.z).x;
          r3.w = r15.x + r3.w;
          r19.xy = r18.zw;
          r15.x = t8.SampleCmpLevelZero(s9_s, r19.xyz, r15.z).x;
          r3.w = r15.x + r3.w;
          r18.xyzw = mad(cb13[r13.z+11].wwww, float4(-0.159624487,-3.19071364,-3.52795029,-1.76808), r17.xyxy);
          r19.xy = r18.xy;
          r15.x = t8.SampleCmpLevelZero(s9_s, r19.xyz, r15.z).x;
          r3.w = r15.x + r3.w;
          r19.xy = r18.zw;
          r15.x = t8.SampleCmpLevelZero(s9_s, r19.xyz, r15.z).x;
          r3.w = r15.x + r3.w;
          r19.xy = mad(cb13[r13.z+11].ww, float2(1.76031363,2.3547585), r17.xy);
          r13.z = t8.SampleCmpLevelZero(s9_s, r19.xyz, r15.z).x;
          r3.w = r13.z + r3.w;
          r3.w = 0.166666672 * r3.w;
          r3.w = r3.w * r3.w;
        } else {
          r13.z = t8.SampleCmpLevelZero(s9_s, r17.xyz, r15.z).x;
          r3.w = r13.z * r13.z;
        }
        r13.z = (int)r13.w;
        r13.z = cmp(r17.z >= r13.z);
        r13.z = r13.z ? 1.000000 : 0;
        r13.w = dot(r16.xyzw, icb[r13.w+0].xyzw);
        r3.w = mad(r13.z, r13.w, r3.w);
        r3.w = min(1, r3.w);
      } else {
        r3.w = 1;
      }
      r9.w = r11.w ? r9.w : r3.w;
    }
    r3.w = r14.x * r9.w;
    float3 classic_cloud_world_0 = r3.xyz;
    r9.w = 20 * cb12[66].x;
    r15.zw = trunc(cb12[68].xy);
    r16.xyz = -cb12[0].xyz + r3.xyz;
    r11.w = dot(r16.xyz, r16.xyz);
    r11.w = sqrt(r11.w);
    r16.xy = cb12[67].xy;
    r16.z = 0;
    r16.xyz = r16.xyz + r3.xyz;
    r16.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r16.xyz;
    r16.xyz = r16.xyz / cb12[66].xxx;
    r17.xy = float2(20,20) * cb12[67].xy;
    r17.z = 0;
    r17.xyz = r17.xyz + r3.xyz;
    r17.xyz = float3(0.00999999978,0.00999999978,0.00999999978) * r17.xyz;
    r17.xyz = r17.xyz / r9.www;
    r13.zw = cb13[0].xy * r16.zz;
    r13.zw = r13.zw / cb13[0].zz;
    r15.xy = r16.xy + -r13.zw;
    r13.zw = cb13[0].xy * r17.zz;
    r13.zw = r13.zw / cb13[0].zz;
    r16.xy = r17.xy + -r13.zw;
    r9.w = t14.SampleLevel(s14_s, r15.xyz, 1).x;
    r13.z = t14.SampleLevel(s14_s, r15.xyw, 1).x;
    r13.z = r13.z + -r9.w;
    r9.w = mad(cb12[66].w, r13.z, r9.w);
    r16.zw = r15.zw;
    r13.z = t14.SampleLevel(s14_s, r16.xyz, 1).x;
    r13.w = t14.SampleLevel(s14_s, r16.xyw, 1).x;
    r13.w = r13.w + -r13.z;
    r13.z = mad(cb12[66].w, r13.w, r13.z);
    r13.w = -0.25 + cb13[0].z;
    r13.w = saturate(10 * r13.w);
    r11.w = -100 + r11.w;
    r11.w = saturate(0.00666666683 * r11.w);
    r13.z = r13.z + -r9.w;
    r9.w = mad(r11.w, r13.z, r9.w);
    r9.w = mad(-r13.w, r9.w, 1);
    r9.w = ClassicCloudShadow(classic_cloud_world_0, r9.w);
    r14.x = r9.w * r3.w;
  }
  r13.xy = (int2)r13.xy;
  r13.zw = (int2)r13.xy ^ int2(2,2);
  r15.xy = max((int2)-r13.xy, (int2)r13.xy);
  r15.xy = (uint2)r15.xy >> int2(1,1);
  r15.zw = -(int2)r15.xy;
  r13.zw = (int2)r13.zw & int2(0x80000000,0x80000000);
  r15.xy = r13.zw ? r15.zw : r15.xy;
  r15.zw = float2(0,0);
  r13.zw = t24.Load(r15.xyz).xy;
  r15.xyz = -cb12[0].xyz + r3.xyz;
  r3.w = dot(r15.xyz, r15.xyz);
  r3.w = sqrt(r3.w);
  r16.x = cb12[1].z;
  r16.y = cb12[2].z;
  r16.z = cb12[3].z;
  r9.w = dot(r16.xyz, r15.xyz);
  r11.w = 1 / cb12[21].y;
  r11.w = r11.w * r3.w;
  r9.w = r11.w / r9.w;
  r9.w = -r9.w + r3.w;
  r9.w = saturate(cb13[33].w * r9.w);
  r9.w = cb13[33].z * r9.w;
  r9.w = max(0.00100000005, r9.w);
  r3.w = r3.w / cb13[34].z;
  r11.w = cmp(r13.z < r13.w);
  if (r11.w != 0) {
    r11.w = cmp(r3.w < r13.z);
    r15.x = cmp(r13.w < r3.w);
    r15.y = mad(cb13[34].z, r13.z, -cb13[34].x);
    r15.y = saturate(-r15.y * cb13[34].y + 1);
    r15.z = r3.w + -r13.z;
    r15.z = cb13[34].z * r15.z;
    r15.z = saturate(r15.z / r9.w);
    r16.y = r15.y * r15.z;
    r11.w = (int)r11.w | (int)r15.x;
    r16.x = 1;
    r15.xy = r11.ww ? float2(0,1) : r16.xy;
  } else {
    r11.w = cmp(r13.w < r13.z);
    r15.z = cmp(r3.w < r13.w);
    r15.w = cmp(r13.z < r3.w);
    r13.z = mad(cb13[34].z, r13.z, -cb13[34].x);
    r16.y = saturate(-r13.z * cb13[34].y + 1);
    r3.w = r3.w + -r13.w;
    r3.w = cb13[34].z * r3.w;
    r3.w = saturate(r3.w / r9.w);
    r16.w = 1 + -r3.w;
    r16.xz = float2(1,1);
    r13.zw = r15.ww ? r16.xy : r16.zw;
    r13.zw = r15.zz ? float2(1,1) : r13.zw;
    r15.xy = r11.ww ? r13.zw : float2(0,1);
  }
  r3.w = mad(-r15.y, r15.x, 1);
  r13.zw = (int2)r13.xy & int2(1,1);
  r15.xy = r13.ww ? float2(1,3) : float2(2,0);
  r9.w = r13.z ? r15.x : r15.y;
  if (1 == 0) r15.x = 0; else if (1+1 < 32) {   r15.x = (uint)r13.x << (32-(1 + 1)); r15.x = (uint)r15.x >> (32-1);  } else r15.x = (uint)r13.x >> 1;
  if (1 == 0) r15.y = 0; else if (1+1 < 32) {   r15.y = (uint)r13.y << (32-(1 + 1)); r15.y = (uint)r15.y >> (32-1);  } else r15.y = (uint)r13.y >> 1;
  if (1 == 0) r15.z = 0; else if (1+2 < 32) {   r15.z = (uint)r13.x << (32-(1 + 2)); r15.z = (uint)r15.z >> (32-1);  } else r15.z = (uint)r13.x >> 2;
  if (1 == 0) r15.w = 0; else if (1+2 < 32) {   r15.w = (uint)r13.y << (32-(1 + 2)); r15.w = (uint)r15.w >> (32-1);  } else r15.w = (uint)r13.y >> 2;
  r16.xyzw = r15.yyww ? float4(1,3,1,3) : float4(2,0,2,0);
  r13.zw = r15.xz ? r16.xz : r16.yw;
  r9.w = (uint)r9.w << 4;
  r9.w = mad((int)r13.z, 4, (int)r9.w);
  r9.w = (int)r9.w + (int)r13.w;
  r9.w = (int)r9.w;
  r9.w = 0.5 + r9.w;
  r11.w = 0.015625 * r9.w;
  r13.xy = (uint2)r13.xy >> int2(5,5);
  r13.z = (int)cb12[24].z;
  r13.x = mad((int)r13.y, (int)r13.z, (int)r13.x);
  r9.w = mad(-r9.w, 0.015625, 1);
  r10.w = 1;
  r15.xzw = float3(0,0,0);
  r16.xyzw = float4(0,0,0,0);
  r13.y = 0;
  while (true) {
    r13.z = cmp((uint)r13.y >= 192);
    if (r13.z != 0) break;
    r13.z = mad((int)r13.x, 192, (int)r13.y);
    r13.z = (uint)r13.z << 2;
  // No code for instruction (needs manual fix):
    r13.z = Raw21.Load((uint)r13.z);
    r13.w = cmp((uint)r13.z >= 192);
    if (r13.w != 0) {
      break;
    }
    r13.z = (int)r13.z * 5;
    r17.x = dot(r10.xyzw, cb13[r13.z+2363].xyzw);
    r17.y = dot(r10.xyzw, cb13[r13.z+2364].xyzw);
    r17.z = dot(r10.xyzw, cb13[r13.z+2365].xyzw);
    r18.xyz = cmp(abs(r17.xyz) < float3(1,1,1));
    r13.w = r18.y ? r18.x : 0;
    r13.w = r18.z ? r13.w : 0;
    if (r13.w != 0) {
      r13.w = asuint(cb13[r13.z+2366].w) >> 16;
      r13.w = (uint)r13.w;
      r13.w = 1.52590219e-005 * r13.w;
      r17.w = 0x0000ffff & asint(cb13[r13.z+2366].w);
      r17.w = (uint)r17.w;
      r17.w = 1.52590219e-005 * r17.w;
      r17.x = dot(r17.xyz, r17.xyz);
      r17.x = sqrt(r17.x);
      r17.x = 1 + -r17.x;
      r17.x = max(0, r17.x);
      r17.xy = cb13[r13.z+2367].wx * r17.xx;
      r17.x = saturate(r17.x);
      r17.z = cmp(-1.000000 == cb13[r13.z+2367].w);
      r18.x = cmp(r13.w >= r9.w);
      r15.y = r18.x ? 1.000000 : 0;
      r13.w = cmp(r13.w >= r11.w);
      r13.w = r13.w ? 1.000000 : 0;
      r18.x = r17.w * r13.w;
      r18.y = min(0.998037279, r17.y);
      r18.zw = cb13[r13.z+2367].yz * r17.xx;
      r17.xyzw = r17.zzzz ? r15.xyzw : r18.xyzw;
      r16.xyzw = max(r16.xyzw, r17.xyzw);
    }
    r13.y = (int)r13.y + 1;
  }
  r9.w = r16.y * r16.y;
  r10.x = cmp(0 < r16.x);
  r10.y = r10.x ? 0 : 1;
  r3.w = r3.w * r3.w;
  r3.w = min(r10.y, r3.w);
  r3.w = max(r3.w, r9.w);
  r3.w = 1 + -r3.w;
  r9.w = 1 + -r16.x;
  r10.y = 1 + -cb13[33].y;
  r9.w = r10.x ? r9.w : r10.y;
  r10.xy = float2(1,1) + -r16.zw;
  r9.w = min(r10.x, r9.w);
  r9.w = r9.w + -r10.y;
  r14.y = saturate(r3.w * r9.w + r10.y);
  r14.z = saturate(1 + -r3.w);
  r3.w = cmp(0 < r12.w);
  r9.w = max(abs(r12.x), abs(r12.y));
  r9.w = 1 + -r9.w;
  r9.w = saturate(10 * r9.w);
  r3.w = r3.w ? r9.w : 0;
  r10.xyz = -cb1[8].xyz + r3.xyz;
  r9.w = dot(r10.xyz, r10.xyz);
  r9.w = rsqrt(r9.w);
  r10.xyz = r10.xyz * r9.www;
  r9.w = dot(r10.xyz, r9.xyz);
  r9.w = r9.w + r9.w;
  r10.xyz = mad(-r9.www, r9.xyz, r10.xyz);
  r9.w = cmp(r9.z < 0);
  r10.w = r9.w ? 1.f : 0.f;
  r13.xyzw = float4(0.5,-0.5,-0.5,0.5) * r9.xyxy;
  r11.w = mad(-r12.z, r0.w, 1);
  r11.w = max(0.00100000005, r11.w);
  r12.xy = r13.xy / r11.ww;
  r0.w = mad(r12.z, r0.w, 1);
  r0.w = max(0.00100000005, r0.w);
  r12.zw = r13.zw / r0.ww;
  r12.xyzw = float4(0.5,0.5,0.5,0.5) + r12.xyzw;
  r12.xy = r9.ww ? r12.xy : r12.zw;
  r12.xy = mad(r12.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
  r13.x = (int)r10.w;
  r13.y = 0;
  r12.xy = r13.xy + r12.xy;
  r12.xy = float2(0.5,0.142857149) * r12.xy;
  r13.xyz = cb12[114].xyz * r3.yyy;
  r13.xyz = mad(cb12[113].xyz, r3.xxx, r13.xyz);
  r13.xyz = mad(cb12[115].xyz, r3.zzz, r13.xyz);
  r13.xyz = cb12[116].xyz + r13.xyz;
  r13.xyz = float3(1,1,1) + -abs(r13.xyz);
  r15.xy = asint(cb12[117].yy) & int2(1,2);
  r0.w = r15.x ? 1 : r14.z;
  r9.w = 1 + -r14.z;
  r10.w = r15.y ? 1 : r9.w;
  r0.w = r10.w * r0.w;
  r15.xyz = cmp(float3(0,0,0) < r13.xyz);
  r10.w = r15.y ? r15.x : 0;
  r10.w = r15.z ? r10.w : 0;
  r11.w = cmp(0 < r0.w);
  r10.w = r11.w ? r10.w : 0;
  if (r10.w != 0) {
    r13.xyz = saturate(cb12[112].xyz * r13.xyz);
    r0.w = cb12[111].x * r0.w;
    r0.w = 0.999989986 * r0.w;
    r10.w = r13.x * r13.y;
    r10.w = r10.w * r13.z;
    r11.w = r10.w * r0.w;
    r0.w = mad(r0.w, r10.w, 9.99999975e-006);
    r10.w = cb12[117].x * r11.w;
    r11.w = asint(cb12[122].x);
    r12.z = mad(r11.w, 0.142857149, r12.y);
    r13.xyz = t22.SampleLevel(s11_s, r12.xz, 1).xyz;
    r13.xyz = r13.xyz * r10.www;
    r11.w = dot(r10.xyz, r10.xyz);
    r11.w = rsqrt(r11.w);
    r15.xyz = r11.www * r10.xyz;
    r12.z = cmp(r15.z < 0);
    r13.w = r12.z ? 1.f : 0.f;
    r15.xyzw = float4(0.5,-0.5,-0.5,0.5) * r15.xyxy;
    r16.x = mad(-r10.z, r11.w, 1);
    r16.x = max(0.00100000005, r16.x);
    r15.xy = r15.xy / r16.xx;
    r11.w = mad(r10.z, r11.w, 1);
    r11.w = max(0.00100000005, r11.w);
    r15.zw = r15.zw / r11.ww;
    r15.xyzw = float4(0.5,0.5,0.5,0.5) + r15.xyzw;
    r15.xy = r12.zz ? r15.xy : r15.zw;
    r15.xy = mad(r15.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
    r16.y = asint(cb12[122].x);
    r16.z = (int)r13.w;
    r16.xw = float2(0,0);
    r15.xy = r16.zw + r15.xy;
    r15.xy = r16.xy + r15.xy;
    r15.xy = float2(0.5,0.142857149) * r15.xy;
    r15.xyz = t23.SampleLevel(s11_s, r15.xy, 5).xyz;
    r15.xyz = r15.xyz * r10.www;
  } else {
    r13.xyz = float3(0,0,0);
    r15.xyz = float3(0,0,0);
    r0.w = 9.99999975e-006;
  }
  r10.w = cmp(r0.w < 0.999000013);
  if (r10.w != 0) {
    r16.xyz = cb12[126].xyz * r3.yyy;
    r16.xyz = mad(cb12[125].xyz, r3.xxx, r16.xyz);
    r16.xyz = mad(cb12[127].xyz, r3.zzz, r16.xyz);
    r16.xyz = cb12[128].xyz + r16.xyz;
    r16.xyz = float3(1,1,1) + -abs(r16.xyz);
    r17.xy = asint(cb12[129].yy) & int2(1,2);
    r11.w = r17.x ? 1 : r14.z;
    r12.z = r17.y ? 1 : r9.w;
    r11.w = r12.z * r11.w;
    r17.xyz = cmp(float3(0,0,0) < r16.xyz);
    r12.z = r17.y ? r17.x : 0;
    r12.z = r17.z ? r12.z : 0;
    r13.w = cmp(0 < r11.w);
    r12.z = r13.w ? r12.z : 0;
    if (r12.z != 0) {
      r16.xyz = saturate(cb12[124].xyz * r16.xyz);
      r12.z = 1 + -r0.w;
      r11.w = r12.z * r11.w;
      r11.w = cb12[123].x * r11.w;
      r12.z = r16.x * r16.y;
      r12.z = r12.z * r16.z;
      r13.w = r12.z * r11.w;
      r0.w = mad(r11.w, r12.z, r0.w);
      r11.w = cb12[129].x * r13.w;
      r12.z = asint(cb12[134].x);
      r12.w = mad(r12.z, 0.142857149, r12.y);
      r16.xyz = t22.SampleLevel(s11_s, r12.xw, 1).xyz;
      r13.xyz = mad(r11.www, r16.xyz, r13.xyz);
      r12.z = dot(r10.xyz, r10.xyz);
      r12.z = rsqrt(r12.z);
      r16.xyz = r12.zzz * r10.xyz;
      r12.w = cmp(r16.z < 0);
      r13.w = r12.w ? 1.f : 0.f;
      r16.xyzw = float4(0.5,-0.5,-0.5,0.5) * r16.xyxy;
      r15.w = mad(-r10.z, r12.z, 1);
      r15.w = max(0.00100000005, r15.w);
      r16.xy = r16.xy / r15.ww;
      r12.z = mad(r10.z, r12.z, 1);
      r12.z = max(0.00100000005, r12.z);
      r16.zw = r16.zw / r12.zz;
      r16.xyzw = float4(0.5,0.5,0.5,0.5) + r16.xyzw;
      r12.zw = r12.ww ? r16.xy : r16.zw;
      r12.zw = mad(r12.zw, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r16.y = asint(cb12[134].x);
      r16.z = (int)r13.w;
      r16.xw = float2(0,0);
      r12.zw = r16.zw + r12.zw;
      r12.zw = r16.xy + r12.zw;
      r12.zw = float2(0.5,0.142857149) * r12.zw;
      r16.xyz = t23.SampleLevel(s11_s, r12.zw, 5).xyz;
      r15.xyz = mad(r11.www, r16.xyz, r15.xyz);
    }
  }
  r11.w = cmp(r0.w < 0.999000013);
  r10.w = r10.w ? r11.w : 0;
  if (r10.w != 0) {
    r16.xyz = cb12[138].xyz * r3.yyy;
    r16.xyz = mad(cb12[137].xyz, r3.xxx, r16.xyz);
    r16.xyz = mad(cb12[139].xyz, r3.zzz, r16.xyz);
    r16.xyz = cb12[140].xyz + r16.xyz;
    r16.xyz = float3(1,1,1) + -abs(r16.xyz);
    r12.zw = asint(cb12[141].yy) & int2(1,2);
    r11.w = r12.z ? 1 : r14.z;
    r12.z = r12.w ? 1 : r9.w;
    r11.w = r12.z * r11.w;
    r17.xyz = cmp(float3(0,0,0) < r16.xyz);
    r12.z = r17.y ? r17.x : 0;
    r12.z = r17.z ? r12.z : 0;
    r12.w = cmp(0 < r11.w);
    r12.z = r12.w ? r12.z : 0;
    if (r12.z != 0) {
      r16.xyz = saturate(cb12[136].xyz * r16.xyz);
      r12.z = 1 + -r0.w;
      r11.w = r12.z * r11.w;
      r11.w = cb12[135].x * r11.w;
      r12.z = r16.x * r16.y;
      r12.z = r12.z * r16.z;
      r12.w = r12.z * r11.w;
      r0.w = mad(r11.w, r12.z, r0.w);
      r11.w = cb12[141].x * r12.w;
      r12.z = asint(cb12[146].x);
      r16.y = mad(r12.z, 0.142857149, r12.y);
      r16.x = r12.x;
      r16.xyz = t22.SampleLevel(s11_s, r16.xy, 1).xyz;
      r13.xyz = mad(r11.www, r16.xyz, r13.xyz);
      r12.z = dot(r10.xyz, r10.xyz);
      r12.z = rsqrt(r12.z);
      r16.xyz = r12.zzz * r10.xyz;
      r12.w = cmp(r16.z < 0);
      r13.w = r12.w ? 1.f : 0.f;
      r16.xyzw = float4(0.5,-0.5,-0.5,0.5) * r16.xyxy;
      r15.w = mad(-r10.z, r12.z, 1);
      r15.w = max(0.00100000005, r15.w);
      r16.xy = r16.xy / r15.ww;
      r12.z = mad(r10.z, r12.z, 1);
      r12.z = max(0.00100000005, r12.z);
      r16.zw = r16.zw / r12.zz;
      r16.xyzw = float4(0.5,0.5,0.5,0.5) + r16.xyzw;
      r12.zw = r12.ww ? r16.xy : r16.zw;
      r12.zw = mad(r12.zw, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r16.y = asint(cb12[146].x);
      r16.z = (int)r13.w;
      r16.xw = float2(0,0);
      r12.zw = r16.zw + r12.zw;
      r12.zw = r16.xy + r12.zw;
      r12.zw = float2(0.5,0.142857149) * r12.zw;
      r16.xyz = t23.SampleLevel(s11_s, r12.zw, 5).xyz;
      r15.xyz = mad(r11.www, r16.xyz, r15.xyz);
    }
  }
  r11.w = cmp(r0.w < 0.999000013);
  r10.w = r10.w ? r11.w : 0;
  if (r10.w != 0) {
    r16.xyz = cb12[150].xyz * r3.yyy;
    r16.xyz = mad(cb12[149].xyz, r3.xxx, r16.xyz);
    r16.xyz = mad(cb12[151].xyz, r3.zzz, r16.xyz);
    r16.xyz = cb12[152].xyz + r16.xyz;
    r16.xyz = float3(1,1,1) + -abs(r16.xyz);
    r12.zw = asint(cb12[153].yy) & int2(1,2);
    r11.w = r12.z ? 1 : r14.z;
    r12.z = r12.w ? 1 : r9.w;
    r11.w = r12.z * r11.w;
    r17.xyz = cmp(float3(0,0,0) < r16.xyz);
    r12.z = r17.y ? r17.x : 0;
    r12.z = r17.z ? r12.z : 0;
    r12.w = cmp(0 < r11.w);
    r12.z = r12.w ? r12.z : 0;
    if (r12.z != 0) {
      r16.xyz = saturate(cb12[148].xyz * r16.xyz);
      r12.z = 1 + -r0.w;
      r11.w = r12.z * r11.w;
      r11.w = cb12[147].x * r11.w;
      r12.z = r16.x * r16.y;
      r12.z = r12.z * r16.z;
      r12.w = r12.z * r11.w;
      r0.w = mad(r11.w, r12.z, r0.w);
      r11.w = cb12[153].x * r12.w;
      r12.z = asint(cb12[158].x);
      r16.y = mad(r12.z, 0.142857149, r12.y);
      r16.x = r12.x;
      r16.xyz = t22.SampleLevel(s11_s, r16.xy, 1).xyz;
      r13.xyz = mad(r11.www, r16.xyz, r13.xyz);
      r12.z = dot(r10.xyz, r10.xyz);
      r12.z = rsqrt(r12.z);
      r16.xyz = r12.zzz * r10.xyz;
      r12.w = cmp(r16.z < 0);
      r13.w = r12.w ? 1.f : 0.f;
      r16.xyzw = float4(0.5,-0.5,-0.5,0.5) * r16.xyxy;
      r15.w = mad(-r10.z, r12.z, 1);
      r15.w = max(0.00100000005, r15.w);
      r16.xy = r16.xy / r15.ww;
      r12.z = mad(r10.z, r12.z, 1);
      r12.z = max(0.00100000005, r12.z);
      r16.zw = r16.zw / r12.zz;
      r16.xyzw = float4(0.5,0.5,0.5,0.5) + r16.xyzw;
      r12.zw = r12.ww ? r16.xy : r16.zw;
      r12.zw = mad(r12.zw, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r16.y = asint(cb12[158].x);
      r16.z = (int)r13.w;
      r16.xw = float2(0,0);
      r12.zw = r16.zw + r12.zw;
      r12.zw = r16.xy + r12.zw;
      r12.zw = float2(0.5,0.142857149) * r12.zw;
      r16.xyz = t23.SampleLevel(s11_s, r12.zw, 5).xyz;
      r15.xyz = mad(r11.www, r16.xyz, r15.xyz);
    }
  }
  r11.w = cmp(r0.w < 0.999000013);
  r10.w = r10.w ? r11.w : 0;
  if (r10.w != 0) {
    r16.xyz = cb12[162].xyz * r3.yyy;
    r16.xyz = mad(cb12[161].xyz, r3.xxx, r16.xyz);
    r16.xyz = mad(cb12[163].xyz, r3.zzz, r16.xyz);
    r16.xyz = cb12[164].xyz + r16.xyz;
    r16.xyz = float3(1,1,1) + -abs(r16.xyz);
    r12.zw = asint(cb12[165].yy) & int2(1,2);
    r11.w = r12.z ? 1 : r14.z;
    r12.z = r12.w ? 1 : r9.w;
    r11.w = r12.z * r11.w;
    r17.xyz = cmp(float3(0,0,0) < r16.xyz);
    r12.z = r17.y ? r17.x : 0;
    r12.z = r17.z ? r12.z : 0;
    r12.w = cmp(0 < r11.w);
    r12.z = r12.w ? r12.z : 0;
    if (r12.z != 0) {
      r16.xyz = saturate(cb12[160].xyz * r16.xyz);
      r12.z = 1 + -r0.w;
      r11.w = r12.z * r11.w;
      r11.w = cb12[159].x * r11.w;
      r12.z = r16.x * r16.y;
      r12.z = r12.z * r16.z;
      r12.w = r12.z * r11.w;
      r0.w = mad(r11.w, r12.z, r0.w);
      r11.w = cb12[165].x * r12.w;
      r12.z = asint(cb12[170].x);
      r16.y = mad(r12.z, 0.142857149, r12.y);
      r16.x = r12.x;
      r16.xyz = t22.SampleLevel(s11_s, r16.xy, 1).xyz;
      r13.xyz = mad(r11.www, r16.xyz, r13.xyz);
      r12.z = dot(r10.xyz, r10.xyz);
      r12.z = rsqrt(r12.z);
      r16.xyz = r12.zzz * r10.xyz;
      r12.w = cmp(r16.z < 0);
      r13.w = r12.w ? 1.f : 0.f;
      r16.xyzw = float4(0.5,-0.5,-0.5,0.5) * r16.xyxy;
      r15.w = mad(-r10.z, r12.z, 1);
      r15.w = max(0.00100000005, r15.w);
      r16.xy = r16.xy / r15.ww;
      r12.z = mad(r10.z, r12.z, 1);
      r12.z = max(0.00100000005, r12.z);
      r16.zw = r16.zw / r12.zz;
      r16.xyzw = float4(0.5,0.5,0.5,0.5) + r16.xyzw;
      r12.zw = r12.ww ? r16.xy : r16.zw;
      r12.zw = mad(r12.zw, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r16.y = asint(cb12[170].x);
      r16.z = (int)r13.w;
      r16.xw = float2(0,0);
      r12.zw = r16.zw + r12.zw;
      r12.zw = r16.xy + r12.zw;
      r12.zw = float2(0.5,0.142857149) * r12.zw;
      r16.xyz = t23.SampleLevel(s11_s, r12.zw, 5).xyz;
      r15.xyz = mad(r11.www, r16.xyz, r15.xyz);
    }
  }
  r11.w = cmp(r0.w < 0.999000013);
  r10.w = r10.w ? r11.w : 0;
  if (r10.w != 0) {
    r16.xyz = cb12[174].xyz * r3.yyy;
    r16.xyz = mad(cb12[173].xyz, r3.xxx, r16.xyz);
    r3.xyz = mad(cb12[175].xyz, r3.zzz, r16.xyz);
    r3.xyz = cb12[176].xyz + r3.xyz;
    r3.xyz = float3(1,1,1) + -abs(r3.xyz);
    r12.zw = asint(cb12[177].yy) & int2(1,2);
    r10.w = r12.z ? 1 : r14.z;
    r9.w = r12.w ? 1 : r9.w;
    r9.w = r10.w * r9.w;
    r16.xyz = cmp(float3(0,0,0) < r3.xyz);
    r10.w = r16.y ? r16.x : 0;
    r10.w = r16.z ? r10.w : 0;
    r11.w = cmp(0 < r9.w);
    r10.w = r11.w ? r10.w : 0;
    if (r10.w != 0) {
      r3.xyz = saturate(cb12[172].xyz * r3.xyz);
      r10.w = 1 + -r0.w;
      r9.w = r10.w * r9.w;
      r9.w = cb12[171].x * r9.w;
      r3.x = r3.x * r3.y;
      r3.x = r3.x * r3.z;
      r3.y = r9.w * r3.x;
      r0.w = mad(r9.w, r3.x, r0.w);
      r3.x = cb12[177].x * r3.y;
      r3.y = asint(cb12[182].x);
      r16.y = mad(r3.y, 0.142857149, r12.y);
      r16.x = r12.x;
      r16.xyz = t22.SampleLevel(s11_s, r16.xy, 1).xyz;
      r13.xyz = mad(r3.xxx, r16.xyz, r13.xyz);
      r3.y = dot(r10.xyz, r10.xyz);
      r3.y = rsqrt(r3.y);
      r16.xyz = r10.xyz * r3.yyy;
      r3.z = cmp(r16.z < 0);
      r9.w = r3.z ? 1.f : 0.f;
      r16.xyzw = float4(0.5,-0.5,-0.5,0.5) * r16.xyxy;
      r10.w = mad(-r10.z, r3.y, 1);
      r10.w = max(0.00100000005, r10.w);
      r12.zw = r16.xy / r10.ww;
      r12.zw = float2(0.5,0.5) + r12.zw;
      r3.y = mad(r10.z, r3.y, 1);
      r3.y = max(0.00100000005, r3.y);
      r16.xy = r16.zw / r3.yy;
      r16.xy = float2(0.5,0.5) + r16.xy;
      r3.yz = r3.zz ? r12.zw : r16.xy;
      r3.yz = mad(r3.yz, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
      r16.y = asint(cb12[182].x);
      r16.z = (int)r9.w;
      r16.xw = float2(0,0);
      r3.yz = r16.zw + r3.yz;
      r3.yz = r16.xy + r3.yz;
      r3.yz = float2(0.5,0.142857149) * r3.yz;
      r16.xyz = t23.SampleLevel(s11_s, r3.yz, 5).xyz;
      r15.xyz = mad(r3.xxx, r16.xyz, r15.xyz);
    }
  }
  r3.x = cmp(r0.w < 1);
  if (r3.x != 0) {
    r3.x = 1 + -r0.w;
    r3.y = cb12[99].x * r3.x;
    r0.w = mad(r3.x, cb12[99].x, r0.w);
    r3.x = cb12[105].x * r3.y;
    r3.y = asint(cb12[110].x);
    r12.y = mad(r3.y, 0.142857149, r12.y);
    r12.xyz = t22.SampleLevel(s11_s, r12.xy, 1).xyz;
    r13.xyz = mad(r3.xxx, r12.xyz, r13.xyz);
    r3.y = cmp(r10.z < 0);
    r3.z = r3.y ? 1.f : 0.f;
    r12.xyzw = float4(0.5,-0.5,-0.5,0.5) * r10.xyxy;
    r9.w = 1 + -r10.z;
    r9.w = max(0.00100000005, r9.w);
    r10.xy = r12.xy / r9.ww;
    r9.w = 1 + r10.z;
    r9.w = max(0.00100000005, r9.w);
    r10.zw = r12.zw / r9.ww;
    r10.xyzw = float4(0.5,0.5,0.5,0.5) + r10.xyzw;
    r10.xy = r3.yy ? r10.xy : r10.zw;
    r10.xy = mad(r10.xy, float2(0.666666627,0.666666627), float2(0.166666672,0.166666672));
    r12.y = asint(cb12[110].x);
    r12.z = (int)r3.z;
    r12.xw = float2(0,0);
    r3.yz = r12.zw + r10.xy;
    r3.yz = r12.xy + r3.yz;
    r3.yz = float2(0.5,0.142857149) * r3.yz;
    r10.xyz = t23.SampleLevel(s11_s, r3.yz, 5).xyz;
    r15.xyz = mad(r3.xxx, r10.xyz, r15.xyz);
  }
  r0.w = 1 / r0.w;
  r3.xyz = r13.xyz * r0.www;
  r10.xyz = r15.xyz * r0.www;
  o2.xyz = r3.xyz * r3.www;
  o3.xyz = r10.xyz * r3.www;
  r0.w = cb4[3].x + cb4[3].x;
  r3.xy = float2(0.000500000024,0.00139999995) * r0.xz;
  r10.xyzw = mad(-cb0[0].xxxx, float4(0.0979999974,0.0929000005,0.0927999988,0.0939000025), r3.xyxy);
  r10.xyzw = frac(r10.xyzw);
  r10.xyzw = mad(r10.xyzw, r0.wwww, -cb4[3].xxxx);
  r10.xyzw = mad(r10.xyzw, r10.xyzw, float4(2,2,2,2));
  r10.xyzw = float4(2,2,2,2) / r10.xyzw;
  r3.xy = mad(-cb0[0].xx, float2(0.0948000029,0.0900000036), r3.xy);
  r3.xy = frac(r3.xy);
  r3.xy = mad(r3.xy, r0.ww, float2(-25,-25));
  r3.xy = mad(r3.xy, r3.xy, float2(2,2));
  r3.xy = float2(2,2) / r3.xy;
  r0.w = r10.x + r10.z;
  r0.w = r0.w + r3.y;
  r0.w = 0.333333343 * r0.w;
  r3.xy = r10.zx + r3.xx;
  r3.xy = r3.xy + r10.yw;
  r3.xy = float2(0.333333343,0.333333343) * r3.xy;
  r10.xy = cb4[1].xx * float2(0.150000006,0.00999999978);
  r12.xyzw = cb4[2].xxxx * r0.xyzx;
  r10.zw = float2(10.0930004,96.1071014) * r12.wy;
  r3.z = r10.z + r10.w;
  r3.z = mad(r12.z, -0.181820005, r3.z);
  r3.z = mad(-cb0[0].x, cb4[0].x, r3.z);
  r3.z = sin(r3.z);
  r3.z = r10.x * r3.z;
  r13.xyz = float3(30.0582504,79.6894989,-0.141279995) * r12.ywy;
  r9.w = mad(r12.w, -0.151679993, r13.x);
  r9.w = mad(r12.z, 60.0054016, r9.w);
  r9.w = mad(-cb0[0].x, cb4[0].x, r9.w);
  r9.w = sin(r9.w);
  r9.w = r10.x * r9.w;
  r10.z = r13.y + r13.z;
  r13.xy = float2(10.1099005,96.1052017) * r12.wy;
  r10.z = mad(r12.z, 89.5821991, r10.z);
  r10.z = mad(-cb0[0].x, cb4[0].x, r10.z);
  r10.z = sin(r10.z);
  r10.x = r10.x * r10.z;
  r10.z = r13.x + r13.y;
  r10.z = mad(r12.z, -1.81819999, r10.z);
  r10.z = mad(-cb0[0].x, cb4[0].x, r10.z);
  r10.z = sin(r10.z);
  r13.xy = float2(-1.19879997,30.0559998) * r12.xy;
  r10.w = r13.x + r13.y;
  r10.w = mad(r12.z, 60.730999, r10.w);
  r10.w = mad(-cb0[0].x, cb4[0].x, r10.w);
  r10.w = sin(r10.w);
  r10.zw = r10.yy * r10.zw;
  r11.w = -0.119400002 * r12.y;
  r11.w = mad(r12.w, 79.8014984, r11.w);
  r11.w = mad(r12.z, 90.7630005, r11.w);
  r11.w = mad(-cb0[0].x, cb4[0].x, r11.w);
  r11.w = sin(r11.w);
  r10.y = r11.w * r10.y;
  r0.w = mad(r0.w, r3.z, r10.z);
  r12.x = v6.w * r0.w;
  r0.w = mad(r3.x, r9.w, r10.w);
  r12.y = v6.w * r0.w;
  r0.w = mad(r3.y, r10.x, r10.y);
  r12.z = v6.w * r0.w;
  r0.xyz = r12.xyz + r0.xyz;
  r0.w = 1;
  o8.x = dot(r0.xyzw, r6.xyzw);
  o8.y = dot(r0.xyzw, r7.xyzw);
  o8.z = dot(r0.xyzw, r8.xyzw);
  r4.x = r6.x;
  r4.y = r7.x;
  r4.z = r8.x;
  r10.x = dot(r4.xyzw, cb1[0].xyzw);
  r12.x = dot(r4.xyzw, cb1[1].xyzw);
  r13.x = dot(r4.xyzw, cb1[2].xyzw);
  r4.x = dot(r4.xyzw, cb1[3].xyzw);
  r5.x = r6.y;
  r5.y = r7.y;
  r5.z = r8.y;
  r10.y = dot(r5.xyzw, cb1[0].xyzw);
  r12.y = dot(r5.xyzw, cb1[1].xyzw);
  r13.y = dot(r5.xyzw, cb1[2].xyzw);
  r4.y = dot(r5.xyzw, cb1[3].xyzw);
  r2.x = r6.z;
  r2.y = r7.z;
  r2.z = r8.z;
  r10.z = dot(r2.xyzw, cb1[0].xyzw);
  r12.z = dot(r2.xyzw, cb1[1].xyzw);
  r13.z = dot(r2.xyzw, cb1[2].xyzw);
  r4.z = dot(r2.xyzw, cb1[3].xyzw);
  r1.x = r6.w;
  r1.y = r7.w;
  r1.z = r8.w;
  r10.w = dot(r1.xyzw, cb1[0].xyzw);
  r12.w = dot(r1.xyzw, cb1[1].xyzw);
  r13.w = dot(r1.xyzw, cb1[2].xyzw);
  r4.w = dot(r1.xyzw, cb1[3].xyzw);
  o10.x = dot(r0.xyzw, r10.xyzw);
  o10.y = dot(r0.xyzw, r12.xyzw);
  o10.z = dot(r0.xyzw, r13.xyzw);
  o10.w = dot(r0.xyzw, r4.xyzw);
  r14.w = 1;
  o4.xyzw = r14.xyzw * r3.wwww;
  o0.w = v3.x;
  o1.xyzw = v11.xyzw;
  o2.w = v3.y;
  o3.w = r11.x;
  o5.xy = v3.xy;
  o5.zw = r11.yz;
  o6.xyzw = v6.xyzw;
  o7.xyz = r9.xyz;
  return;
}
