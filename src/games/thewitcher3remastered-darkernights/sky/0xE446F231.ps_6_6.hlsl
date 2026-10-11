/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
Texture2D<float4> t0 : register(t0);

cbuffer cb0 : register(b0) {
  float4 GlobalShaderConsts_000 : packoffset(c000.x);
  float4 GlobalShaderConsts_016 : packoffset(c001.x);
  float4 GlobalShaderConsts_032 : packoffset(c002.x);
  float4 GlobalShaderConsts_048 : packoffset(c003.x);
  float4 GlobalShaderConsts_064 : packoffset(c004.x);
  float4 GlobalShaderConsts_080 : packoffset(c005.x);
  float4 GlobalShaderConsts_096 : packoffset(c006.x);
  float4 GlobalShaderConsts_112 : packoffset(c007.x);
  float4 GlobalShaderConsts_128 : packoffset(c008.x);
  float4 GlobalShaderConsts_144 : packoffset(c009.x);
  float4 GlobalShaderConsts_160 : packoffset(c010.x);
  float4 GlobalShaderConsts_176 : packoffset(c011.x);
  float4 GlobalShaderConsts_192 : packoffset(c012.x);
  float4 GlobalShaderConsts_208 : packoffset(c013.x);
  float4 GlobalShaderConsts_224 : packoffset(c014.x);
  float4 GlobalShaderConsts_240 : packoffset(c015.x);
};

cbuffer cb1 : register(b1) {
  float cb1_036x : packoffset(c036.x);
  float cb1_036y : packoffset(c036.y);
  float cb1_036z : packoffset(c036.z);
  uint cb1_padding : packoffset(c53.w);
};

cbuffer cb2 : register(b2) {
  float4 FrequentPixelConsts_000 : packoffset(c000.x);
  float4 FrequentPixelConsts_016 : packoffset(c001.x);
  float4 FrequentPixelConsts_032 : packoffset(c002.x);
  float4 FrequentPixelConsts_048 : packoffset(c003.x);
  float4 FrequentPixelConsts_064 : packoffset(c004.x);
  float4 FrequentPixelConsts_080 : packoffset(c005.x);
  float4 FrequentPixelConsts_096 : packoffset(c006.x);
  row_major float4x4 FrequentPixelConsts_112 : packoffset(c007.x);
  row_major float4x4 FrequentPixelConsts_176 : packoffset(c011.x);
  float4 FrequentPixelConsts_240 : packoffset(c015.x);
  float4 FrequentPixelConsts_256 : packoffset(c016.x);
  float4 FrequentPixelConsts_272 : packoffset(c017.x);
  float4 FrequentPixelConsts_288 : packoffset(c018.x);
};

SamplerState s0 : register(s0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2,
  linear float4 TEXCOORD_3 : TEXCOORD3,
  linear float3 TEXCOORD_4 : TEXCOORD4,
  linear float3 TEXCOORD_5 : TEXCOORD5
) : SV_Target {
  float4 SV_Target = 0;
  float _28 = cb1_036x - TEXCOORD_4.x;
  float _29 = cb1_036y - TEXCOORD_4.y;
  float _30 = cb1_036z - TEXCOORD_4.z;
  float _32 = rsqrt(dot(float3(_28, _29, _30), float3(_28, _29, _30)));
  float _33 = _30 * _32;
  float _36 = saturate(-0.800000011920929f - (_33 * 3.5f));
  float _40 = rsqrt(dot(float3(TEXCOORD_2.z, TEXCOORD_2.w, TEXCOORD_3.w), float3(TEXCOORD_2.z, TEXCOORD_2.w, TEXCOORD_3.w)));
  float _46 = log2(1.100000023841858f - dot(float3((_28 * _32), (_29 * _32), _33), float3((_40 * TEXCOORD_2.z), (_40 * TEXCOORD_2.w), (_40 * TEXCOORD_3.w))));
  float4 _57 = t0.Sample(s0, float2((TEXCOORD_2.x - GlobalShaderConsts_000.w), TEXCOORD_2.y));
  float4 _64 = t0.Sample(s0, float2((TEXCOORD_2.x - GlobalShaderConsts_000.w), TEXCOORD_2.y));
  float _71 = (_64.x + -0.5f) * 2.0f;
  float _72 = (_64.y + -0.5f) * 2.0f;
  float _73 = (_64.z + -0.5f) * 2.0f;
  float _75 = rsqrt(dot(float3(_71, _72, _73), float3(_71, _72, _73)));
  float _76 = _71 * _75;
  float _77 = _72 * _75;
  float _78 = _73 * _75;
  float _99 = ((GlobalShaderConsts_000.y * 0.033863864839076996f) + GlobalShaderConsts_000.w) * 6.283185005187988f;
  float _121 = FrequentPixelConsts_032.w * saturate(1.0f - TEXCOORD_1.w);
  float _126 = (pow(_57.w, 2.200000047683716f)) * ((((_36 * _36) * (1.0f - saturate(exp2(_46 * 10.0f)))) * ((exp2(_46 * 7.0f) * 5.0f) + 1.0f)) * saturate(dot(float3((((_76 * TEXCOORD_5.x) + (_77 * TEXCOORD_3.x)) + (_78 * TEXCOORD_2.z)), (((_76 * TEXCOORD_5.y) + (_77 * TEXCOORD_3.y)) + (_78 * TEXCOORD_2.w)), (((_76 * TEXCOORD_5.z) + (_77 * TEXCOORD_3.z)) + (_78 * TEXCOORD_3.w))), float3(cos(_99), sin(_99), 0.0f))));
  SV_Target.x = (((_126 * FrequentPixelConsts_000.x) * FrequentPixelConsts_032.x) * _121);
  SV_Target.y = (((_126 * FrequentPixelConsts_000.y) * FrequentPixelConsts_032.y) * _121);
  SV_Target.z = (((_126 * FrequentPixelConsts_000.z) * FrequentPixelConsts_032.z) * _121);
  SV_Target.w = 0.0f;
  // Brightness from the paired moon vertex shader; preserve fog and additive alpha.
  SV_Target.rgb *= TEXCOORD.x;
  return SV_Target;
}
