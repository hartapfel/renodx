ByteAddressBuffer Raw20 : register(t20);
// ---- Created with 3Dmigoto v1.3.16 on Fri Oct 23 21:55:11 2026
Texture2D<float4> t70 : register(t70);

Texture2D<float4> t18 : register(t18);

Texture2D<float4> t17 : register(t17);

Texture2D<float4> t12 : register(t12);

TextureCubeArray<float4> t10 : register(t10);

Texture2DArray<float4> t9 : register(t9);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s12_s : register(s12);

SamplerState s10_s : register(s10);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb2 : register(b2)
{
  float4 cb2[19];
}

cbuffer cb12 : register(b12)
{
  float4 cb12[219];
}

cbuffer cb4 : register(b4)
{
  float4 cb4[16];
}

cbuffer cb13 : register(b13)
{
  float4 cb13[2362];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[49];
}




// 3Dmigoto declarations
#define cmp -


#include "../temporal/object_pixel.hlsli"

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : TEXCOORD2,
  float4 v3 : TEXCOORD3,
  float4 v4 : TEXCOORD4,
  float4 v5 : TEXCOORD5,
  float4 v6 : TEXCOORD6,
  float4 v7 : TEXCOORD7,
  float4 v8 : TEXCOORD8,
  float3 v9 : TEXCOORD9,
  float4 v10 : SV_Position0,
  float4 previous_clip : TEXCOORD12,
  nointerpolation float motion_history : TEXCOORD13,
  uint v11 : SV_IsFrontFace0,
  out float4 o0 : SV_Target0,
  out float2 object_motion : SV_Target3,
  out float object_depth : SV_Target4)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.x = v0.w;
  r0.y = v2.w;
  r1.xyzw = t0.Sample(s0_s, r0.xy).xyzw;
  r0.z = -0.330000013 + r1.w;
  r0.w = cmp(r0.z < 0);
  if (r0.w != 0) discard;
  r2.xyz = cmp(cb2[18].yzw != float3(0,0,0));
  if (r2.x != 0) {
    r3.xyzw = float4(16,16,16,16) * v10.xyxy;
    r3.xyzw = cmp(r3.xyzw >= -r3.zwzw);
    r3.xyzw = r3.xyzw ? float4(16,16,0.0625,0.0625) : float4(-16,-16,-0.0625,-0.0625);
    r2.xw = v10.xy * r3.zw;
    r2.xw = frac(r2.xw);
    r2.xw = r3.xy * r2.xw;
    r2.xw = trunc(r2.xw);
    r3.xy = (int2)r2.xw;
    r3.zw = float2(0,0);
    r0.w = t18.Load(r3.xyz).x;
    r0.w = r0.w * v1.x + v1.y;
    r0.w = cmp(r0.w < 0);
    if (r0.w != 0) discard;
  }
  if (r2.y != 0) {
    r0.w = t12.Sample(s12_s, v5.xy).x;
    r0.w = r0.w * v1.z + v1.w;
    r0.w = cmp(r0.w < 0);
    if (r0.w != 0) discard;
  }
  r0.w = dot(v0.xyz, v0.xyz);
  r0.w = -1 + r0.w;
  r0.w = cmp(r0.w < 0);
  r0.w = r0.w ? r2.z : 0;
  if (r0.w != 0) discard;
  r0.w = r1.x + r1.y;
  r0.w = r0.w + r1.z;
  r2.x = -1 + cb4[1].x;
  r2.x = 0.5 * r2.x;
  r2.y = saturate(r2.x);
  r2.z = 0.333299994 * r0.w;
  r0.w = r0.w * -0.666599989 + 1;
  r0.w = r2.y * r0.w + r2.z;
  r3.xyzw = cb4[0].xyzw * r1.xyzw;
  r3.xyzw = saturate(float4(1.5,1.5,1.5,1.5) * r3.xyzw);
  r0.w = saturate(r0.w * abs(r2.x));
  r2.xyzw = r3.xyzw + -r1.xyzw;
  r2.xyzw = r0.wwww * r2.xyzw + r1.xyzw;
  r0.w = cmp(0 < cb4[3].x);
  if (r0.w != 0) {
    r0.w = r2.x + r2.z;
    r3.xy = r2.xz / r0.ww;
    r3.xy = float2(-0.300000012,-0.300000012) + r3.xy;
    r3.xy = saturate(float2(1.42857146,1.42857146) * r3.xy);
    r0.w = r3.x + r3.y;
    r0.w = r3.y / r0.w;
    r3.x = 1 + -r0.w;
    r4.xyzw = cb2[11].zyxw * r0.wwww;
    r5.xyzw = cb2[12].zyxw * r0.wwww;
    r6.xyzw = cb2[13].zyxw * r0.wwww;
    r4.xyzw = r3.xxxx * cb2[7].xyzw + r4.xyzw;
    r5.xyzw = r3.xxxx * cb2[8].xywz + r5.xywz;
    r3.xyzw = r3.xxxx * cb2[9].xyzw + r6.xyzw;
  } else {
    r0.w = cmp(r2.x >= r2.z);
    r4.xyzw = r0.wwww ? cb2[7].xyzw : cb2[11].zyxw;
    r5.xyzw = r0.wwww ? cb2[8].xywz : cb2[12].zywx;
    r3.xyzw = r0.wwww ? cb2[9].xyzw : cb2[13].zyxw;
  }
  r6.xy = cb4[14].xy * r0.xy;
  r0.w = t2.Sample(s0_s, r6.xy).x;
  r0.z = cmp(r0.z >= 0);
  r6.xyzw = t1.Sample(s0_s, r0.xy).wxyz;
  if (r0.z != 0) {
    r7.xy = (int2)v10.xy;
    r7.zw = float2(0,0);
    r0.x = t4.Load(r7.xyz).x;
    r0.y = cmp(0 < cb4[4].x);
    r0.z = min(r2.y, r2.z);
    r0.z = min(r2.x, r0.z);
    r7.x = max(r2.y, r2.z);
    r7.x = max(r7.x, r2.x);
    r0.z = r7.x + -r0.z;
    r0.z = r0.z / r7.x;
    r0.z = -0.100000001 + r0.z;
    r0.z = saturate(5 * r0.z);
    r0.z = cb4[2].x * r0.z;
    r0.y = r0.y ? r0.z : cb4[2].x;
    r6.yzw = float3(-0.5,-0.5,-0.5) + r6.yzw;
    r6.yzw = r6.yzw + r6.yzw;
    r7.x = v3.w;
    r7.yz = v5.zw;
    r7.xyz = r7.xyz * r6.zzz;
    r7.xyz = v9.xyz * r6.yyy + r7.xyz;
    r6.yzw = v7.xyz * r6.www + r7.xyz;
    r0.z = cmp(0 >= (uint)v11.x);
    r7.x = dot(v7.xyz, r6.yzw);
    r7.xyz = v7.xyz * r7.xxx;
    r7.xyz = r7.xyz * float3(-2,-2,-2) + r6.yzw;
    r7.xyz = r0.zzz ? r7.xyz : r6.yzw;
    r4.x = dot(r2.xyzw, r4.xyzw);
    r4.y = dot(r2.xywz, r5.xyzw);
    r4.z = dot(r2.xyzw, r3.xyzw);
    r3.xyz = r4.xyz + -r2.xyz;
    r2.xyz = r0.yyy * r3.xyz + r2.xyz;
    r2.xyz = saturate(v6.xyz * r2.xyz);
    r0.y = 1 + -r6.x;
    r3.xyz = log2(cb4[5].xyz);
    r3.xyz = float3(2.20000005,2.20000005,2.20000005) * r3.xyz;
    r3.xyz = exp2(r3.xyz);
    r0.y = r0.y * cb4[6].x + cb4[7].x;
    r3.xyz = saturate(r3.xyz * r0.yyy);
    r3.xyz = log2(r3.xyz);
    r4.xyz = cb1[8].xyz + -v8.xyz;
    r0.y = dot(r4.xyz, r4.xyz);
    r0.y = rsqrt(r0.y);
    r4.xyz = r4.xyz * r0.yyy;
    r0.y = dot(r6.yzw, r4.xyz);
    r0.y = saturate(1 + -r0.y);
    r0.y = r0.y * r0.y;
    r0.y = log2(r0.y);
    r0.y = cb4[8].x * r0.y;
    r0.y = exp2(r0.y);
    r0.y = cb4[9].x * r0.y;
    r0.y = saturate(cb4[10].x * r0.y);
    r0.z = saturate(cb4[11].x);
    r0.w = -0.5 + r0.w;
    r0.w = cb4[15].x * r0.w;
    r2.w = max(0.00100000005, v4.w);
    r4.xyz = v2.xyz / r2.www;
    r5.xyz = v3.xyz / r2.www;
    r2.xyz = log2(r2.xyz);
    r2.xyz = float3(2.20000005,2.20000005,2.20000005) * r2.xyz;
    r2.xyz = exp2(r2.xyz);
    r3.xyz = float3(0.999998987,0.999998987,0.999998987) * r3.xyz;
    r3.xyz = exp2(r3.xyz);
    r6.x = saturate(r6.x);
    r6.yz = (uint2)v10.yx;
    r8.xy = (uint2)r6.zy;
    r2.w = dot(r7.xyz, r7.xyz);
    r2.w = rsqrt(r2.w);
    r7.xyz = r7.xyz * r2.www;
    r2.w = dot(v7.xyz, v7.xyz);
    r2.w = rsqrt(r2.w);
    r9.xyz = v7.xyz * r2.www;
    r6.yz = (uint2)r6.yz >> int2(4,4);
    r6.yz = (uint2)r6.yz;
    r2.w = trunc(cb12[24].x);
    r2.w = (int)r2.w;
    r6.yz = (int2)r6.yz;
    r2.w = mad((int)r6.y, (int)r2.w, (int)r6.z);
    r2.w = (int)r2.w;
    r2.w = (uint)r2.w;
    r2.w = (uint)r2.w << 8;
    r2.w = (uint)r2.w;
    r6.yzw = cb12[0].xyz + -v8.xyz;
    r3.w = dot(r6.yzw, r6.yzw);
    r3.w = rsqrt(r3.w);
    r10.xyz = r6.yzw * r3.www;
    r4.w = cmp(0.00100000005 < v4.w);
    r8.zw = v4.yz / v4.ww;
    r8.z = saturate(r8.z);
    r8.w = saturate(1.00196469 * r8.w);
    r8.zw = r4.ww ? r8.zw : float2(0,0.5);
    r11.xy = (int2)r8.xy;
    r11.zw = (int2)r5.ww;
    r11.xyz = t17.Load(r11.xyz).xyz;
    r4.w = cmp(0 < r0.x);
    if (r4.w != 0) {
      r8.xy = float2(0.333333343,0.25) * r0.xx;
      r8.x = saturate(r8.x);
      r4.w = r8.x * -2 + 3;
      r5.w = r8.x * r8.x;
      r4.w = r5.w * r4.w;
      r5.w = -r4.w * 0.5 + 1;
      r12.xyz = t3.SampleLevel(s1_s, float2(0.5,0.5), 0).xyz;
      r12.xyz = r12.xyz * r11.zzz;
      r12.xyz = float3(0.25,0.25,0.25) * r12.xyz;
      r7.w = 1 + -cb3[47].w;
      r12.xyz = r12.xyz * r7.www;
      r12.xyz = r12.xyz * r4.www;
      r13.xyz = r4.xyz * r5.www + r12.xyz;
      r12.xyz = r5.xyz * r5.www + r12.xyz;
      r14.xyz = cb3[48].xyz + cb3[47].xyz;
      r4.w = max(0, r8.y);
      r14.xyz = -r4.www * r14.xyz;
      r14.xyz = float3(1.44269502,1.44269502,1.44269502) * r14.xyz;
      r14.xyz = exp2(r14.xyz);
      r4.xyz = r14.xyz * r13.xyz;
      r5.xyz = r14.xyz * r12.xyz;
    }
    r4.w = cmp(0 < r11.y);
    if (r4.w != 0) {
      r4.w = dot(r9.xyz, cb13[0].xyz);
      r4.w = cb4[12].x + r4.w;
      r5.w = 1 + cb4[12].x;
      r4.w = saturate(r4.w / r5.w);
      r5.w = dot(r7.xyz, cb13[0].xyz);
      r7.w = r5.w + r4.w;
      r4.w = 1 + r4.w;
      r7.w = r7.w / r4.w;
      r4.w = 1 / r4.w;
      r12.xyz = saturate(r7.www);
      r13.xyz = r6.yzw * r3.www + cb13[0].xyz;
      r7.w = dot(r13.xyz, r13.xyz);
      r7.w = rsqrt(r7.w);
      r13.xyz = r13.xyz * r7.www;
      r7.w = dot(r13.xyz, r10.xyz);
      r7.w = 1 + -abs(r7.w);
      r7.w = max(0, r7.w);
      r8.x = r7.w * r7.w;
      r8.x = r8.x * r8.x;
      r7.w = r8.x * r7.w;
      r8.x = 1 + -r6.x;
      r14.xyz = float3(1,1,1) + -r3.xyz;
      r15.xyz = cb13[56].xxx * r14.xyz;
      r15.xyz = r15.xyz * r7.www;
      r7.w = cb13[56].z + 1;
      r7.w = -cb13[56].z * r8.x + r7.w;
      r15.xyz = r15.xyz / r7.www;
      r15.xyz = r15.xyz + r3.xyz;
      r16.xyz = float3(1,1,1) + -r15.xyz;
      r16.xyz = r16.xyz * r12.xyz;
      r16.xyz = float3(0.318309873,0.318309873,0.318309873) * r16.xyz;
      r7.w = cmp(0 < r0.y);
      r8.x = 1 + r5.w;
      r8.y = dot(cb13[0].xyz, -r10.xyz);
      r8.y = 1 + r8.y;
      r8.xy = float2(0.5,0.5) * r8.xy;
      r9.w = dot(r7.xyz, -r10.xyz);
      r9.w = 1 + r9.w;
      r9.w = cb12[36].w * r9.w;
      r8.y = r8.y * r8.y;
      r9.w = 0.5 * r9.w;
      r8.y = r8.y * r8.y + -r8.x;
      r8.x = cb12[36].x * r8.y + r8.x;
      r8.x = r9.w * r8.x;
      r8.y = cb12[36].y * r0.y;
      r14.xyz = cb12[36].zzz * r14.xyz + -r16.xyz;
      r14.xyz = r8.yyy * r14.xyz + r16.xyz;
      r14.xyz = r8.xxx * r0.yyy + r14.xyz;
      r14.xyz = r7.www ? r14.xyz : r16.xyz;
      r14.xyz = r14.xyz * r4.www;
      r8.xy = -cb12[0].xy + v8.xy;
      r4.w = dot(r8.xy, r8.xy);
      r4.w = sqrt(r4.w);
      r7.w = saturate(v8.z * cb12[218].z + cb12[218].w);
      r16.xyz = -cb13[52].xyz + cb13[51].xyz;
      r16.xyz = r7.www * r16.xyz + cb13[52].xyz;
      r4.w = saturate(r4.w * cb12[218].x + cb12[218].y);
      r16.xyz = -cb13[1].xyz + r16.xyz;
      r16.xyz = r4.www * r16.xyz + cb13[1].xyz;
      r4.w = cmp(0 >= r0.x);
      if (r4.w != 0) {
        r17.xyz = float3(1,1,1);
      }
      if (r4.w == 0) {
        r0.x = max(0, r0.x);
        r18.xyz = cb3[48].xyz + cb3[47].xyz;
        r4.w = r0.x / abs(cb3[46].z);
        r19.xyzw = cb3[46].xyxy * v8.zzzz;
        r19.xyzw = r19.xyzw / cb3[46].zzzz;
        r19.xyzw = v8.xyxy + -r19.xyzw;
        r20.xyzw = float4(0.0949999988,0.0474999994,-0.0500000007,0) * cb3[37].wwww;
        r19.xyzw = r19.xyzw * float4(0.200000003,0.200000003,0.200000003,0.200000003) + r20.xyzw;
        r7.w = t70.SampleLevel(s2_s, r19.xy, 0).x;
        r8.xy = float2(0.100000001,0.100000001) + r19.zw;
        r8.x = t70.SampleLevel(s2_s, r8.xy, 0).x;
        r7.w = min(r8.x, r7.w);
        r8.x = 1.5 * r0.x;
        r8.x = min(1, r8.x);
        r7.w = r7.w * 6 + -1;
        r7.w = r8.x * r7.w + 1;
        r18.xyz = -r4.www * r18.xyz;
        r18.xyz = float3(1.44269502,1.44269502,1.44269502) * r18.xyz;
        r18.xyz = exp2(r18.xyz);
        r18.xyz = cb3[46].www * r18.xyz;
        r0.x = -0.00999999978 + r0.x;
        r0.x = saturate(25 * r0.x);
        r18.xyz = r18.xyz * r7.www + float3(-1,-1,-1);
        r17.xyz = r0.xxx * r18.xyz + float3(1,1,1);
      }
      r16.xyz = r17.xyz * r16.xyz;
      r14.xyz = r14.xyz * r11.yyy;
      r14.xyz = r14.xyz * r16.xyz;
      r0.x = cmp(0 < r5.w);
      if (r0.x != 0) {
        r0.x = dot(r7.xyz, r10.xyz);
        r5.w = saturate(r5.w);
        r4.w = r6.x * r6.x;
        r7.w = 1 + -r0.z;
        r7.w = r7.w * r4.w;
        r4.w = max(9.99999975e-005, r4.w);
        r7.w = max(9.99999975e-005, r7.w);
        r8.x = dot(v9.xyz, v9.xyz);
        r8.x = rsqrt(r8.x);
        r17.xyz = v9.xyz * r8.xxx;
        r8.x = dot(r17.xyz, r7.xyz);
        r17.xyz = -r7.xyz * r8.xxx + r17.xyz;
        r8.x = dot(r17.xyz, r17.xyz);
        r8.x = rsqrt(r8.x);
        r17.xyz = r17.xyz * r8.xxx;
        r18.xyz = r17.zxy * r7.yzx;
        r18.xyz = r17.yzx * r7.zxy + -r18.xyz;
        r18.xyz = r7.xyz * r0.www + r18.xyz;
        r8.x = dot(r18.xyz, r18.xyz);
        r8.x = rsqrt(r8.x);
        r18.xyz = r18.xyz * r8.xxx;
        r8.x = dot(r17.xyz, r13.xyz);
        r8.x = r8.x / r4.w;
        r8.y = dot(r18.xyz, r13.xyz);
        r8.y = r8.y / r7.w;
        r8.y = r8.y * r8.y;
        r9.w = saturate(dot(r7.xyz, r13.xyz));
        r4.w = r7.w * r4.w;
        r4.w = 3.14152002 * r4.w;
        r7.w = r8.x * r8.x + r8.y;
        r7.w = r9.w * r9.w + r7.w;
        r7.w = r7.w * r7.w;
        r4.w = r7.w * r4.w;
        r4.w = 1 / r4.w;
        r7.w = 1 + r6.x;
        r7.w = r7.w * r7.w;
        r8.x = 0.125 * r7.w;
        r7.w = r7.w * -0.125 + 1;
        r8.y = r5.w * r7.w + r8.x;
        r8.y = r5.w / r8.y;
        r7.w = abs(r0.x) * r7.w + r8.x;
        r7.w = abs(r0.x) / r7.w;
        r7.w = r8.y * r7.w;
        r4.w = r7.w * r4.w;
        r13.xyz = r4.www * r15.xyz;
        r0.x = r5.w * abs(r0.x);
        r0.x = 4 * r0.x;
        r13.xyz = r13.xyz / r0.xxx;
        r13.xyz = r13.xyz * r5.www;
      } else {
        r13.xyz = float3(0,0,0);
      }
      r13.xyz = r13.xyz * r11.yyy;
      r13.xyz = r13.xyz * r16.xyz;
    } else {
      r12.xyz = float3(0,0,0);
      r13.xyz = float3(0,0,0);
      r14.xyz = float3(0,0,0);
    }
    r11.yzw = min(r12.xyz, r11.yyy);
    r0.x = cmp(r8.w == 1.000000);
    r4.w = cmp(cb2[16].x < 0);
    r4.w = r4.w ? 1 : cb12[71].x;
    r5.w = 1 + cb4[12].x;
    r7.w = 1 + -r6.x;
    r8.xyw = float3(1,1,1) + -r3.xyz;
    r12.xyz = cb13[56].xxx * r8.xyw;
    r15.xy = cb13[56].zw + float2(1,1);
    r15.xy = -cb13[56].zw * r7.ww + r15.xy;
    r7.w = cmp(0 < r0.y);
    r9.w = dot(r7.xyz, -r10.xyz);
    r9.w = 1 + r9.w;
    r9.w = cb12[36].w * r9.w;
    r9.w = 0.5 * r9.w;
    r10.w = cb12[36].y * r0.y;
    r12.w = dot(r7.xyz, r10.xyz);
    r13.w = r6.x * r6.x;
    r0.z = 1 + -r0.z;
    r0.z = r0.z * r13.w;
    r13.w = max(9.99999975e-005, r13.w);
    r0.z = max(9.99999975e-005, r0.z);
    r14.w = dot(v9.xyz, v9.xyz);
    r14.w = rsqrt(r14.w);
    r16.xyz = v9.xyz * r14.www;
    r14.w = dot(r16.xyz, r7.xyz);
    r16.xyz = -r7.xyz * r14.www + r16.xyz;
    r14.w = dot(r16.xyz, r16.xyz);
    r14.w = rsqrt(r14.w);
    r16.xyz = r16.xyz * r14.www;
    r17.xyz = r16.zxy * r7.yzx;
    r17.xyz = r16.yzx * r7.zxy + -r17.xyz;
    r17.xyz = r7.xyz * r0.www + r17.xyz;
    r0.w = dot(r17.xyz, r17.xyz);
    r0.w = rsqrt(r0.w);
    r17.xyz = r17.xyz * r0.www;
    r0.w = r0.z * r13.w;
    r0.w = 3.14152002 * r0.w;
    r6.x = 1 + r6.x;
    r6.x = r6.x * r6.x;
    r14.w = 0.125 * r6.x;
    r6.x = r6.x * -0.125 + 1;
    r15.z = abs(r12.w) * r6.x + r14.w;
    r15.z = abs(r12.w) / r15.z;
    r15.w = 4 * abs(r12.w);
    r16.w = r0.x ? 0 : 1;
    r2.w = (int)r2.w;
    r18.xyz = r14.xyz;
    r19.xyz = r13.xyz;
    r17.w = 0;
    while (true) {
      r18.w = (int)r17.w;
      r19.w = cmp((int)r18.w >= 256);
      if (r19.w != 0) {
        break;
      }
      r19.w = (int)r2.w + (int)r18.w;
      r19.w = (int)r19.w;
      r19.w = (uint)r19.w;
      r19.w = (uint)r19.w << 2;
    r19.w = Raw20.Load((uint)r19.w);
      r20.x = cmp((uint)r19.w >= 256);
      if (r20.x != 0) {
        break;
      }
      r19.w = (uint)r19.w;
      r19.w = (int)r19.w;
      r19.w = (int)r19.w * 9;
      r19.w = (int)r19.w;
      r20.xyzw = float4(58,61,63,64) + r19.wwww;
      r20.xyzw = (uint4)r20.xyzw;
      r21.xyz = cb13[r20.x+0].xyz + -v8.xyz;
      r22.x = dot(r21.xyz, r21.xyz);
      r22.y = sqrt(r22.x);
      r22.z = r22.y / cb13[r20.x+0].w;
      r22.w = r22.z * r22.z;
      r22.w = -r22.w * r22.w + 1;
      r22.w = max(0, r22.w);
      r22.w = r22.w * r22.w;
      r23.xyz = int3(1,2048,4096) & asint(cb13[r20.y+0].www);
      r23.xyz = (int3)r23.xyz;
      r23.w = cmp(0 < cb13[r20.z+0].z);
      r24.x = cmp(0 < cb13[r20.w+0].x);
      r24.y = r22.x * cb13[r20.z+0].x + 1;
      r22.w = r22.w / r24.y;
      r23.x = cmp(r23.x != 0.000000);
      if (r23.x != 0) {
        r24.y = rsqrt(r22.x);
        r24.yzw = r24.yyy * r21.xyz;
        r25.xy = float2(60,62) + r19.ww;
        r25.xy = (uint2)r25.xy;
        r24.y = dot(-r24.yzw, cb13[r25.x+0].xyz);
        r24.y = saturate(r24.y * cb13[r25.y+0].y + cb13[r25.y+0].z);
        r24.y = log2(r24.y);
        r24.y = cb13[r25.y+0].w * r24.y;
        r24.y = exp2(r24.y);
        r22.w = r24.y * r22.w;
      }
      r24.y = cmp(0 < r22.w);
      r24.y = r24.y ? -1.000000 : 0;
      r23.w = r23.w ? r24.y : 0;
      r23.w = cmp(r23.w != 0.000000);
      if (r23.w != 0) {
        if (r23.x != 0) {
          r25.xyz = -cb13[r20.x+0].xyz + v8.xyz;
          r23.xw = float2(65,60) + r19.ww;
          r23.xw = (uint2)r23.xw;
          r26.xyz = cb13[r23.x+0].zwy * cb13[r23.w+0].zxy;
          r26.xyz = cb13[r23.w+0].yzx * cb13[r23.x+0].wyz + -r26.xyz;
          r26.x = dot(r26.xyz, r25.xyz);
          r26.y = dot(cb13[r23.x+0].yzw, r25.xyz);
          r26.z = dot(cb13[r23.w+0].xyz, r25.xyz);
          r23.x = cb13[r23.x+0].x;
        } else {
          r26.xzw = -cb13[r20.x+0].xzy + v8.xzy;
          r25.xyz = r21.yzx / r22.yyy;
          r20.x = max(abs(r25.x), abs(r25.y));
          r20.x = cmp(r20.x < abs(r25.z));
          if (r20.x != 0) {
            r20.x = cmp(0 < r25.z);
            r27.xyz = float3(1,1,-1) * r26.wzx;
            r22.y = 65 + r19.w;
            r22.y = (uint)r22.y;
            r28.xyz = float3(-1,1,1) * r26.wzx;
            r26.xyz = r20.xxx ? r27.xyz : r28.xyz;
            r23.x = r20.x ? cb13[r22.y+0].x : cb13[r22.y+0].y;
          } else {
            r20.x = max(abs(r25.z), abs(r25.y));
            r20.x = cmp(r20.x < abs(r25.x));
            if (r20.x != 0) {
              r20.x = cmp(0 < r25.x);
              r25.xzw = float3(-1,1,-1) * r26.xzw;
              r22.y = 65 + r19.w;
              r22.y = (uint)r22.y;
              r26.xyz = r20.xxx ? r25.xzw : r26.xzw;
              r23.x = r20.x ? cb13[r22.y+0].z : cb13[r22.y+0].w;
            } else {
              r20.x = cmp(0 < r25.y);
              r26.y = r20.x ? r26.w : -r26.w;
              r26.z = r20.x ? -r26.z : r26.z;
              r22.y = 66 + r19.w;
              r22.y = (uint)r22.y;
              r23.x = r20.x ? cb13[r22.y+0].x : cb13[r22.y+0].y;
            }
          }
        }
        r20.x = (int)r23.x & 1023;
        r20.x = (uint)r20.x;
        r22.y = cmp(0 != r20.x);
        if (r22.y != 0) {
          r24.zw = cb13[r20.z+0].yy * r26.xy;
          r24.zw = r24.zw / r26.zz;
          r24.zw = r24.zw * float2(0.5,-0.5) + float2(0.5,0.5);
          if (10 == 0) r25.x = 0; else if (10+20 < 32) {           r25.x = (uint)r23.x << (32-(10 + 20)); r25.x = (uint)r25.x >> (32-10);          } else r25.x = (uint)r23.x >> 20;
          if (10 == 0) r25.y = 0; else if (10+10 < 32) {           r25.y = (uint)r23.x << (32-(10 + 10)); r25.y = (uint)r25.y >> (32-10);          } else r25.y = (uint)r23.x >> 10;
          r25.xy = (uint2)r25.xy;
          r20.z = (uint)r23.x >> 30;
          r26.z = (uint)r20.z;
          r20.xz = r24.zw * r20.xx + r25.xy;
          r26.xy = float2(0.0009765625,0.0009765625) * r20.xz;
          r20.x = t9.SampleLevel(s10_s, r26.xyz, 0).x;
          r20.x = r22.z * -0.99000001 + r20.x;
          r20.x = 144.269501 * r20.x;
          r20.x = exp2(r20.x);
          r20.x = min(1, r20.x);
        } else {
          r20.x = 1;
        }
      } else {
        r20.x = 1;
      }
      r20.z = r24.y ? r24.x : 0;
      r20.z = cmp(r20.z != 0.000000);
      if (r20.z != 0) {
        r21.w = cb13[r20.w+0].y;
        r20.z = t10.SampleLevel(s10_s, r21.xyzw, 0).x;
        r20.z = r22.z * -0.99000001 + r20.z;
        r20.z = 144.269501 * r20.z;
        r20.z = exp2(r20.z);
        r20.z = min(1, r20.z);
        r20.x = r20.z * r20.x;
      }
      r20.x = -1 + r20.x;
      r19.w = 60 + r19.w;
      r19.w = (uint)r19.w;
      r19.w = cb13[r19.w+0].w * r20.x + 1;
      r19.w = r22.w * r19.w;
      r20.xz = cmp(float2(0,0) != r23.yz);
      r20.x = (int)r0.x | (int)r20.x;
      r20.x = r20.x ? 1.000000 : 0;
      r20.z = r20.z ? 1 : r16.w;
      r20.x = r20.z * r20.x;
      r19.w = r20.x * r19.w;
      r20.x = cmp(0 < r19.w);
      if (r20.x != 0) {
        r20.x = 0x80000000 & asint(cb13[r20.y+0].w);
        r20.x = (uint)r20.x;
        r20.x = cmp(0 != r20.x);
        r20.x = r20.x ? r4.w : 1;
        r19.w = r20.x * r19.w;
        r20.x = rsqrt(r22.x);
        r20.xzw = r21.xyz * r20.xxx;
        r21.x = dot(r9.xyz, r20.xzw);
        r21.x = cb4[12].x + r21.x;
        r21.x = saturate(r21.x / r5.w);
        r21.y = dot(r7.xyz, r20.xzw);
        r21.z = r21.y + r21.x;
        r21.x = 1 + r21.x;
        r21.z = saturate(r21.z / r21.x);
        r21.x = 1 / r21.x;
        r22.xyz = r6.yzw * r3.www + r20.xzw;
        r21.w = dot(r22.xyz, r22.xyz);
        r21.w = rsqrt(r21.w);
        r22.xyz = r21.www * r22.xyz;
        r21.w = dot(r22.xyz, r10.xyz);
        r21.w = 1 + -abs(r21.w);
        r21.w = max(0, r21.w);
        r22.w = r21.w * r21.w;
        r22.w = r22.w * r22.w;
        r21.w = r22.w * r21.w;
        r23.xyz = r21.www * r12.xyz;
        r23.xyz = r23.xyz / r15.xxx;
        r23.xyz = r23.xyz + r3.xyz;
        r24.xyz = float3(1,1,1) + -r23.xyz;
        r24.xyz = r24.xyz * r21.zzz;
        r24.xyz = float3(0.318309873,0.318309873,0.318309873) * r24.xyz;
        r21.z = 1 + r21.y;
        r21.z = 0.5 * r21.z;
        r20.x = dot(r20.xzw, -r10.xyz);
        r20.x = 1 + r20.x;
        r20.x = 0.5 * r20.x;
        r20.x = r20.x * r20.x;
        r20.x = r20.x * r20.x + -r21.z;
        r20.x = cb12[36].x * r20.x + r21.z;
        r20.x = r20.x * r9.w;
        r25.xyz = cb12[36].zzz * r8.xyw + -r24.xyz;
        r25.xyz = r10.www * r25.xyz + r24.xyz;
        r20.xzw = r20.xxx * r0.yyy + r25.xyz;
        r20.xzw = r7.www ? r20.xzw : r24.xyz;
        r20.xzw = r20.xzw * r21.xxx;
        r20.xzw = cb13[r20.y+0].xyz * r20.xzw;
        r18.xyz = r19.www * r20.xzw + r18.xyz;
        r20.x = cmp(0 < r21.y);
        r21.y = saturate(r21.y);
        r20.z = dot(r16.xyz, r22.xyz);
        r20.z = r20.z / r13.w;
        r20.w = dot(r17.xyz, r22.xyz);
        r20.w = r20.w / r0.z;
        r20.w = r20.w * r20.w;
        r21.x = saturate(dot(r7.xyz, r22.xyz));
        r20.z = r20.z * r20.z + r20.w;
        r20.z = r21.x * r21.x + r20.z;
        r20.z = r20.z * r20.z;
        r20.z = r20.z * r0.w;
        r20.z = 1 / r20.z;
        r20.w = r21.y * r6.x + r14.w;
        r20.w = r21.y / r20.w;
        r20.w = r20.w * r15.z;
        r20.z = r20.w * r20.z;
        r21.xzw = r20.zzz * r23.xyz;
        r20.z = r21.y * r15.w;
        r21.xzw = r21.xzw / r20.zzz;
        r21.xyz = r21.xzw * r21.yyy;
        r20.xzw = r20.xxx ? r21.xyz : 0;
        r20.xyz = cb13[r20.y+0].xyz * r20.xzw;
        r19.xyz = r19.www * r20.xyz + r19.xyz;
      }
      r18.w = (int)r18.w + 1;
      r17.w = (int)r18.w;
    }
    r0.x = abs(cb2[16].x) + -cb2[16].y;
    r0.xzw = r11.yzw * r0.xxx + cb2[16].yyy;
    r2.w = cb2[16].z + -cb2[16].w;
    r6.xyz = r11.yzw * r2.www + cb2[16].www;
    r0.xzw = r0.xzw * r4.xyz;
    r4.xyz = r6.xyz * r5.xyz;
    r5.xy = -cb12[0].xy + v8.xy;
    r2.w = dot(r5.xy, r5.xy);
    r2.w = sqrt(r2.w);
    r2.w = saturate(r2.w * cb12[218].x + cb12[218].y);
    r3.w = -1 + cb12[184].z;
    r2.w = r2.w * r3.w + 1;
    r3.w = cb12[183].x + -cb12[183].y;
    r5.xyz = r11.yzw * r3.www + cb12[183].yyy;
    r5.xyz = r5.xyz * r2.www;
    r3.w = cb12[184].x + -cb12[184].y;
    r6.xyz = r11.yzw * r3.www + cb12[184].yyy;
    r6.xyz = r6.xyz * r2.www;
    r7.xyz = cb12[183].zzz * r18.xyz;
    r11.yzw = cb12[183].www * r19.xyz;
    r0.xzw = r5.xyz * r0.xzw;
    r2.w = dot(r9.xyz, r10.xyz);
    r2.w = max(abs(r12.w), abs(r2.w));
    r2.w = 1 + -r2.w;
    r2.w = max(0, r2.w);
    r3.w = r2.w * r2.w;
    r3.w = r3.w * r3.w;
    r2.w = r3.w * r2.w;
    r3.w = min(cb13[56].y, 0.25);
    r5.xyz = r3.www * r8.xyw;
    r5.xyz = r5.xyz * r2.www;
    r5.xyz = r5.xyz / r15.yyy;
    r3.xyz = r5.xyz + r3.xyz;
    r5.xyz = float3(1,1,1) + -r3.xyz;
    r0.xzw = r5.xyz * r0.xzw;
    r4.xyz = r6.xyz * r4.xyz;
    r3.xyz = r4.xyz * r3.xyz;
    r4.xyz = saturate(r11.xxx * cb12[186].xyz + cb12[187].xyz);
    r2.w = saturate(cb4[13].x);
    r4.xyz = float3(-1,-1,-1) + r4.xyz;
    r4.xyz = r4.xyz * r2.www;
    r2.w = -1 + cb12[69].z;
    r0.y = r0.y * r2.w + 1;
    r4.xyz = r0.yyy * r4.xyz + float3(1,1,1);
    r5.xyz = r8.zzz * r4.xyz;
    r4.xyz = cb12[69].xxx * r4.xyz + cb12[69].yyy;
    r6.xyz = r7.xyz * r4.xyz;
    r4.xyz = r11.yzw * r4.xyz;
    r0.xyz = r0.xzw * r5.xyz + r6.xyz;
    r0.xyz = r2.xyz * r0.xyz + r4.xyz;
    r1.xyz = r3.xyz * r5.xyz + r0.xyz;
  } else {
    r1.xyz = float3(0,0,0);
  }
  o0.xyzw = r1.xyzw;
  WriteObjectMotion(v10, previous_clip, motion_history, object_motion, object_depth);
  return;
}