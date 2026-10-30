#include "night_sky.hlsli"
// ---- Created with 3Dmigoto v1.3.16 on Thu Oct 29 18:31:29 2026
TextureCube<float4> t1 : register(t1);

TextureCube<float4> t0 : register(t0);

SamplerState s0_s : register(s0);

cbuffer cb12 : register(b12)
{
  float4 cb12[268];
}

cbuffer cb1 : register(b1)
{
  float4 cb1[9];
}

cbuffer cb0 : register(b0)
{
  float4 cb0[10];
}




// 3Dmigoto declarations
#define cmp -


// Preserve the native integer register bits and signed shift. The DXBC
// decompiler otherwise converts these noise-hash registers through float.
float ClassicSkyNoiseHash(int2 coordinate) {
  uint value = asuint(coordinate.x) + reversebits(asuint(coordinate.y));
  value ^= asuint(asint(value) >> 13);
  value = value * (value * value * 0xec4du + 0x131071fu) + 0x5208dd0du;
  return float(value & 0x7fffffffu) * 4.65661287e-10f;
}

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float4 v2 : SV_Position0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = v0.zw;
  r0.z = v1.w;
  r1.xyz = -cb12[0].xyz + r0.xyz;
  r0.w = dot(r1.xyz, r1.xyz);
  r1.w = sqrt(r0.w);
  r1.xyw = r1.xyz / r1.www;
  r1.x = dot(cb12[38].xyz, r1.xyw);
  r1.y = abs(r1.x) * abs(r1.x);
  r2.x = saturate(cb12[42].z * 0.00200000009 + -0.300000012);
  r1.y = r2.x * r1.y;
  r2.x = cmp(0 < r1.x);
  r2.xyz = r2.xxx ? cb12[39].xyz : cb12[41].xyz;
  r2.xyz = -cb12[40].xyz + r2.xyz;
  r2.xyz = r1.yyy * r2.xyz + cb12[40].xyz;
  r1.y = cmp(cb12[42].z >= cb12[48].y);
  if (r1.y != 0) {
    r1.y = r1.w * cb12[22].z + cb12[0].z;
    r1.w = cb12[42].z * r1.w;
    r1.w = 0.0625 * r1.w;
    r2.w = cb12[44].x * cb12[42].z;
    r2.w = 0.0625 * r2.w;
    r1.x = cb12[42].x + r1.x;
    r3.x = 1 + cb12[42].x;
    r1.x = saturate(r1.x / r3.x);
    r3.x = cb12[44].y + -cb12[44].z;
    r1.x = r1.x * r3.x + cb12[44].z;
    r1.y = cb12[42].y + r1.y;
    r3.x = r1.y * r1.x;
    r1.w = r1.w * r1.x;
    r4.xyzw = r1.wwww * float4(16,15,14,13) + r3.xxxx;
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.wwww / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r3.y = r4.x * r4.y;
    r3.y = r3.y * r4.z;
    r3.y = r3.y * r4.w;
    r4.xyzw = r1.wwww * float4(12,11,10,9) + r3.xxxx;
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.wwww / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r3.y = r4.x * r3.y;
    r3.y = r3.y * r4.y;
    r3.y = r3.y * r4.z;
    r3.y = r3.y * r4.w;
    r4.xyzw = r1.wwww * float4(8,7,6,5) + r3.xxxx;
    r4.xyzw = max(float4(0,0,0,0), r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + r4.xyzw;
    r4.xyzw = saturate(r2.wwww / r4.xyzw);
    r4.xyzw = float4(1,1,1,1) + -r4.xyzw;
    r3.y = r4.x * r3.y;
    r3.y = r3.y * r4.y;
    r3.y = r3.y * r4.z;
    r3.y = r3.y * r4.w;
    r3.zw = r1.ww * float2(4,3) + r3.xx;
    r3.zw = max(float2(0,0), r3.zw);
    r3.zw = float2(1,1) + r3.zw;
    r3.zw = saturate(r2.ww / r3.zw);
    r3.zw = float2(1,1) + -r3.zw;
    r3.y = r3.y * r3.z;
    r3.y = r3.y * r3.w;
    r3.x = r1.w * 2 + r3.x;
    r3.x = max(0, r3.x);
    r3.x = 1 + r3.x;
    r3.x = saturate(r2.w / r3.x);
    r3.x = 1 + -r3.x;
    r3.x = r3.y * r3.x;
    r1.x = r1.y * r1.x + r1.w;
    r1.x = max(0, r1.x);
    r1.x = 1 + r1.x;
    r1.x = saturate(r2.w / r1.x);
    r1.x = 1 + -r1.x;
    r1.x = -r3.x * r1.x + 1;
    r1.y = -cb12[48].y + cb12[42].z;
    r1.y = saturate(cb12[48].z * r1.y);
  } else {
    r1.xy = float2(1,0);
  }
  r1.x = log2(r1.x);
  r1.x = cb12[42].w * r1.x;
  r1.x = exp2(r1.x);
  r1.x = r1.y * r1.x;
  r1.yw = saturate(r1.xx * cb12[189].xz + cb12[189].yw);
  r3.xyz = cb12[188].xyz + -r2.xyz;
  r3.xyz = r1.yyy * r3.xyz + r2.xyz;
  r1.y = -1 + cb12[188].w;
  r1.y = r1.w * r1.y + 1;
  r3.w = saturate(r1.x * r1.y);
  r1.y = cmp(0 < cb12[192].x);
  if (r1.y != 0) {
    r1.yw = saturate(r1.xx * cb12[191].xz + cb12[191].yw);
    r4.xyz = cb12[190].xyz + -r2.xyz;
    r2.xyz = r1.yyy * r4.xyz + r2.xyz;
    r1.y = -1 + cb12[190].w;
    r1.y = r1.w * r1.y + 1;
    r2.w = saturate(r1.x * r1.y);
    r2.xyzw = r2.xyzw + -r3.xyzw;
    r3.xyzw = cb12[192].xxxx * r2.xyzw + r3.xyzw;
  }
  r1.xyw = cb12[0].xyz + -r0.xyz;
  r2.x = dot(r1.xyw, r1.xyw);
  r2.x = rsqrt(r2.x);
  r1.xyw = r2.xxx * r1.xyw;
  r2.xy = saturate(cb12[205].yx);
  r2.z = dot(-r1.xyw, -r1.xyw);
  r2.z = rsqrt(r2.z);
  r1.xyw = r2.zzz * -r1.xyw;
  r2.z = dot(cb12[204].yz, cb12[204].yz);
  r2.z = rsqrt(r2.z);
  r2.zw = cb12[204].yz * r2.zz;
  r4.x = dot(r1.xy, r1.xy);
  r4.x = rsqrt(r4.x);
  r4.xy = r4.xx * r1.xy;
  r2.z = dot(r2.zw, r4.xy);
  r2.w = saturate(dot(cb12[204].yzw, r1.xyw));
  r4.z = dot(cb12[203].yz, cb12[203].yz);
  r4.z = rsqrt(r4.z);
  r4.zw = cb12[203].yz * r4.zz;
  r4.x = dot(r4.zw, r4.xy);
  r1.x = saturate(dot(cb12[203].yzw, r1.xyw));
  r1.y = r2.z * 0.5 + 0.5;
  r4.yzw = -cb12[200].xyz + cb12[199].xyz;
  r4.yzw = r1.yyy * r4.yzw + cb12[200].xyz;
  r1.y = r4.x * 0.5 + 0.5;
  r5.xyz = -cb12[197].xyz + cb12[196].xyz;
  r5.xyz = r1.yyy * r5.xyz + cb12[197].xyz;
  r1.y = -r1.w * r1.w + 1;
  r1.yw = r1.yy * r2.xy;
  r4.xyz = -cb12[195].xyz + r4.yzw;
  r4.xyz = r1.yyy * r4.xyz + cb12[195].xyz;
  r5.xyz = r5.xyz + -r4.xyz;
  r4.xyz = r1.www * r5.xyz + r4.xyz;
  r0.w = rsqrt(r0.w);
  r0.w = r1.z * r0.w;
  r0.w = r0.w * 1000 + cb12[0].z;
  r0.w = 710 + r0.w;
  r0.w = cb12[202].z * r0.w;
  r0.w = r0.w * 0.00100000005 + 0.100000001;
  r0.w = max(9.99999975e-005, r0.w);
  r0.w = 1 / r0.w;
  r0.w = min(1, r0.w);
  r0.w = log2(r0.w);
  r0.w = 2.79999995 * r0.w;
  r0.w = exp2(r0.w);
  r0.w = 1 + -r0.w;
  r1.yzw = cb12[194].xyz + -r4.xyz;
  r1.yzw = r0.www * r1.yzw + r4.xyz;
  r0.w = log2(r2.w);
  r0.w = cb12[204].x * r0.w;
  r0.w = exp2(r0.w);
  r0.w = r0.w * r2.x;
  r1.x = log2(r1.x);
  r1.x = cb12[203].x * r1.x;
  r1.x = exp2(r1.x);
  r1.x = r1.x * r2.y;
  r2.xyz = cb12[201].xyz + -r1.yzw;
  r1.yzw = r0.www * r2.xyz + r1.yzw;
  r2.xyz = cb12[198].xyz + -r1.yzw;
  r1.xyz = r1.xxx * r2.xyz + r1.yzw;
  r1.xyz = cb12[202].xxx * r1.xyz;
  r0.xyz = cb1[8].xyz + -r0.xyz;
  r0.w = dot(r0.xyz, r0.xyz);
  r0.w = rsqrt(r0.w);
  r0.xyz = r0.xyz * r0.www;
  r2.xyz = float3(0,0,1) * cb12[204].zwy;
  r2.xyz = cb12[204].yzw * float3(0,1,0) + -r2.xyz;
  r4.xyz = cb12[204].zwy * r2.xyz;
  r4.xyz = r2.zxy * cb12[204].wyz + -r4.xyz;
  r4.x = dot(r0.xyz, r4.xyz);
  r4.y = dot(r0.xy, r2.yz);
  r4.z = dot(r0.xyz, cb12[204].yzw);
  r0.w = dot(r4.xyz, r4.xyz);
  r0.w = rsqrt(r0.w);
  r2.xyz = r4.xyz * r0.www;
  r4.xyz = t0.Sample(s0_s, r2.xyz).xyz;
  r4.xyz = r4.xyz * r4.xyz;
  r0.w = t1.Sample(s0_s, r2.xyz).x;
  r1.w = dot(v1.xyz, v1.xyz);
  r1.w = rsqrt(r1.w);
  r2.xyz = v1.xyz * r1.www;
  r1.w = dot(cb12[204].yzw, cb12[204].yzw);
  r1.w = rsqrt(r1.w);
  r5.xyz = cb12[204].yzw * r1.www;
  r1.w = dot(r2.xyz, r5.xyz);
  r0.w = saturate(r0.w * 0.200000003 + r1.w);
  r1.w = cmp(0.497925013 >= r0.w);
  if (r1.w != 0) {
    r1.w = cmp(0.184938997 >= r0.w);
    r2.y = 5.40718842 * r0.w;
    r2.z = min(1, r2.y);
    r2.w = r2.z * -2 + 3;
    r2.z = r2.z * r2.z;
    r2.z = r2.w * r2.z;
    r5.xyz = float3(0.949253976,0.949253976,0.949253976) * r2.zzz;
    r2.x = 0.949253976;
    r2.xw = r1.ww ? r2.xy : float2(0,0.5);
    r4.w = ~(int)r1.w;
    if (r1.w == 0) {
      r1.w = cmp(0.239751995 >= r0.w);
      r5.w = -0.184938997 + r0.w;
      r6.y = 18.2438488 * r5.w;
      r5.w = saturate(r6.y);
      r6.z = r5.w * -2 + 3;
      r5.w = r5.w * r5.w;
      r5.w = r6.z * r5.w;
      r5.w = r5.w * -0.11372596 + 0.949253976;
      r5.xyz = r1.www ? r5.www : r5.zzz;
      r7.xyz = r1.www ? float3(0.949253976,0.949253976,0.949253976) : 0;
      r6.x = 0.835528016;
      r2.xw = r1.ww ? r6.xy : r2.xw;
      r2.xyzw = r2.xxxw;
    } else {
      r7.xyz = float3(0,0,0);
      r2.xyzw = r2.xxxw;
      r1.w = -1;
    }
    r5.w = ~(int)r1.w;
    r4.w = (int)r4.w & (int)r5.w;
    if (r4.w != 0) {
      r5.w = cmp(r0.w >= 0.239751995);
      r6.x = cmp(0.294564009 >= r0.w);
      r1.w = r5.w ? r6.x : 0;
      r5.w = -0.239751995 + r0.w;
      r6.w = 18.244175 * r5.w;
      r5.w = saturate(r6.w);
      r7.w = r5.w * -2 + 3;
      r5.w = r5.w * r5.w;
      r5.w = r7.w * r5.w;
      r5.w = r5.w * 0.0158729553 + 0.835528016;
      r5.xyz = r1.www ? r5.www : r5.xyz;
      r7.xyz = r1.www ? float3(0.835528016,0.835528016,0.835528016) : r7.xyz;
      r6.xyz = float3(0.851400971,0.851400971,0.851400971);
      r2.xyzw = r1.wwww ? r6.xyzw : r2.xyzw;
    }
    r5.w = ~(int)r1.w;
    r4.w = (int)r4.w & (int)r5.w;
    if (r4.w != 0) {
      r1.w = cmp(r0.w >= 0.294564009);
      r0.w = -0.294564009 + r0.w;
      r6.w = 4.91736364 * r0.w;
      r0.w = saturate(r6.w);
      r4.w = r0.w * -2 + 3;
      r0.w = r0.w * r0.w;
      r0.w = r4.w * r0.w;
      r0.w = r0.w * -0.851400971 + 0.851400971;
      r5.xyz = r1.www ? r0.www : r5.xyz;
      r7.xyz = r1.www ? float3(0.851400971,0.851400971,0.851400971) : r7.xyz;
      r6.xyz = float3(0,0,0);
      r2.xyzw = r1.wwww ? r6.xyzw : r2.xyzw;
    }
  } else {
    r7.xyz = float3(0,0,0);
    r2.xyzw = float4(0,0,0,0.5);
    r1.w = 0;
  }
  r2.w = saturate(r2.w);
  r0.w = r2.w * -2 + 3;
  r2.w = r2.w * r2.w;
  r0.w = r2.w * r0.w;
  r2.xyz = r2.xyz + -r7.xyz;
  r2.xyz = r0.www * r2.xyz + r7.xyz;
  r2.xyz = r1.www ? r5.xyz : r2.xyz;
  r2.xyz = float3(0.150000006,0.200000003,0.25) * r2.xyz;
  r2.xyz = r4.xyz * float3(3,3,3) + r2.xyz;
  r0.w = dot(-cb12[204].yzw, -cb12[204].yzw);
  r0.w = rsqrt(r0.w);
  r4.xyz = -cb12[204].yzw * r0.www;
  r0.z = saturate(dot(r4.xyz, r0.xyz));
  r2.xyz = log2(r2.xyz);
  r2.xyz = float3(2.20000005,2.20000005,2.20000005) * r2.xyz;
  r2.xyz = exp2(r2.xyz);
  r0.z = 1 + -r0.z;
  r2.xyz = r2.xyz * r0.zzz;
  r0.z = saturate(v0.y);
  r0.w = cmp(r0.z >= 0.25);
  r1.w = cmp(0.980967999 >= r0.z);
  r0.w = r0.w ? r1.w : 0;
  if (r0.w != 0) {
    r1.w = -0.25 + r0.z;
    r1.w = 1.36804891 * r1.w;
    r2.w = saturate(r1.w);
    r4.x = r2.w * -2 + 3;
    r2.w = r2.w * r2.w;
    r2.w = r4.x * r2.w;
    r4.xyz = r2.www * float3(-0.955447018,-0.955447018,-0.955447018) + float3(1,1,1);
    r5.xyz = float3(1,1,1);
    r6.xyz = float3(0.0445530005,0.0445530005,0.0445530005);
  } else {
    r0.z = cmp(0.25 >= r0.z);
    r6.xyz = r0.zzz ? float3(1,1,1) : float3(0.0445530005,0.0445530005,0.0445530005);
    r5.xyz = r6.zzz;
    r1.w = 0.5;
  }
  r1.w = saturate(r1.w);
  r0.z = r1.w * -2 + 3;
  r1.w = r1.w * r1.w;
  r0.z = r1.w * r0.z;
  r6.xyz = r6.xyz + -r5.xyz;
  r5.xyz = r0.zzz * r6.xyz + r5.xyz;
  r4.xyz = r0.www ? r4.xyz : r5.xyz;
  r2.xyz = saturate(r4.xyz * r2.xyz);
  r0.z = 1 + -cb0[9].w;
  r2.xyz = r2.xyz * r0.zzz;
  r2.xyz = r2.xyz + r2.xyz;
  r2.xyz *= ClassicStarBrightness(asuint(cb12[184].w));
  r1.xyz = r1.xyz * cb12[202].yyy + r2.xyz;
  r2.xyz = r3.xyz + -r1.xyz;
  r1.xyz = r3.www * r2.xyz + r1.xyz;
  r0.z = dot(-cb0[9].xy, -cb0[9].xy);
  r0.z = rsqrt(r0.z);
  r0.zw = -cb0[9].xy * r0.zz;
  r0.x = saturate(dot(r0.zw, r0.xy));
  float2 noise_position = v0.xy * float2(10,1);
  int2 cell = asint(floor(noise_position));
  int2 previous_cell = asint(floor(noise_position - 1.f));
  float2 noise_weight = 1.f - frac(noise_position);
  noise_weight = noise_weight * noise_weight * (3.f - 2.f * noise_weight);
  float noise_value = lerp(
      lerp(ClassicSkyNoiseHash(cell), ClassicSkyNoiseHash(int2(previous_cell.x,cell.y)), noise_weight.x),
      lerp(ClassicSkyNoiseHash(int2(cell.x,previous_cell.y)), ClassicSkyNoiseHash(previous_cell), noise_weight.x), noise_weight.y);
  r0.y = saturate(noise_value * -.25f + v0.y);
  r0.z = cmp(r0.y >= 0.590847015);
  r0.w = cmp(0.991400003 >= r0.y);
  r0.z = r0.w ? r0.z : 0;
  if (r0.z != 0) {
    r0.w = -0.590847015 + r0.y;
    r0.w = 2.49654865 * r0.w;
    r1.w = saturate(r0.w);
    r2.x = r1.w * -2 + 3;
    r1.w = r1.w * r1.w;
    r1.w = r2.x * r1.w;
    r2.xy = float2(0,1);
  } else {
    r0.y = cmp(0.590847015 >= r0.y);
    r2.xy = r0.yy ? float2(0,0) : float2(1,1);
    r0.w = 0.5;
  }
  r0.w = saturate(r0.w);
  r0.y = r0.w * -2 + 3;
  r0.w = r0.w * r0.w;
  r0.y = r0.y * r0.w;
  r0.w = r2.y + -r2.x;
  r0.y = r0.y * r0.w + r2.x;
  r0.y = r0.z ? r1.w : r0.y;
  r2.xyz = -cb12[267].xyz + cb12[238].xyz;
  r0.xzw = r0.xxx * r2.xyz + cb12[267].xyz;
  o0.xyz = r0.xzw * r0.yyy * ClassicSkyHazeBrightness(asuint(cb12[37].z)) + r1.xyz;
  o0.w = 1;
  return;
}
