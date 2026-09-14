// ---- Created with 3Dmigoto v1.4.9 on Sun Sep 13 19:12:38 2026
// Original bytecode/HLSL are preserved in
// renodx-dev/shader-baseline-20260913. DXBC and/or operate on float bits;
// the decompiler's numeric (int4) casts changed texture sample values.
#include "./common.hlsli"

Texture3D<float4> t33 : register(t33);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb4 : register(b4)
{
  float4 cb4[236];
}

cbuffer cb3 : register(b3)
{
  float4 cb3[77];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_POSITION0,
  float4 v1 : TEXCOORD8,
  float4 v2 : COLOR0,
  float4 v3 : COLOR1,
  float4 v4 : TEXCOORD9,
  float4 v5 : TEXCOORD0,
  float4 v6 : TEXCOORD1,
  float4 v7 : TEXCOORD2,
  float4 v8 : TEXCOORD3,
  float4 v9 : TEXCOORD4,
  float4 v10 : TEXCOORD5,
  float4 v11 : TEXCOORD6,
  float4 v12 : TEXCOORD7,
  out float4 o0 : SV_TARGET0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v5.xy).xyzw;
  r0.xyzw = asfloat(asuint(r0.xyzw) & asuint(cb3[44].xyzw));
  r0.xyzw = asfloat(asuint(r0.xyzw) | asuint(cb3[45].xyzw));
  if (shader_injection.injection_version == 30.f && RENODX_TONE_MAP_TYPE == 1.f
      && RENODX_DIFFUSE_WHITE_NITS > 0.f && RENODX_PEAK_WHITE_NITS > 0.f) {
    o0 = float4(AC2ToneMapScene(r0.rgb, t33, s1_s, cb4[8].xyz, cb4[9].xyz,
                              asuint(cb3[46].xyz), asuint(cb3[47].xyz)), 0.f);
    return;
  }
  // Native path retained for Vanilla and absent/incompatible injection.
  r1.xyz = cb4[8].xyz;
  r0.xyz = r0.xyz * r1.xyz + cb4[9].xyz;
  r0.xyzw = t33.Sample(s1_s, r0.xyz).xyzw;
  r0.xyzw = asfloat(asuint(r0.xyzw) & asuint(cb3[46].xyzw));
  r0.xyzw = asfloat(asuint(r0.xyzw) | asuint(cb3[47].xyzw));
  o0.xyz = r0.xyz;
  o0.w = 0;
  return;
}
