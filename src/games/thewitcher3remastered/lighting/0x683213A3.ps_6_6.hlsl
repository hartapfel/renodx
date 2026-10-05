#include "./common.hlsli"

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

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

cbuffer cb4 : register(b4) {
  float cb4_000x : packoffset(c000.x);
  float cb4_001x : packoffset(c001.x);
  float cb4_002x : packoffset(c002.x);
  float cb4_002y : packoffset(c002.y);
  float cb4_003x : packoffset(c003.x);
  float cb4_003y : packoffset(c003.y);
  float cb4_004x : packoffset(c004.x);
  float cb4_005x : packoffset(c005.x);
  float cb4_006x : packoffset(c006.x);
  float cb4_007x : packoffset(c007.x);
  float cb4_007y : packoffset(c007.y);
  float cb4_007z : packoffset(c007.z);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
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
  float _43 = (cb4_003x * GlobalShaderConsts_000.x) + (cb4_002x * TEXCOORD_1.x);
  float _44 = (cb4_003y * GlobalShaderConsts_000.x) + (cb4_002y * TEXCOORD_1.y);
  float4 _47 = t0.Sample(s0, float2(_43, _44));
  float4 _52 = t0.Sample(s0, float2(_43, _44));
  float _57 = cb4_004x * (_47.x + -0.48500001430511475f);
  float _58 = (_52.y + -0.5049999952316284f) * cb4_004x;
  float _61 = GlobalShaderConsts_000.x * 0.10000000149011612f;
  float _62 = frac(_61);
  float _65 = (_57 * _62) + _43;
  float _66 = (_62 * _58) + _44;
  float4 _69 = t1.Sample(s0, float2(_65, _66));
  float _72 = frac(_61 + 0.5f);
  float _75 = (_72 * _57) + _43;
  float _76 = (_72 * _58) + _44;
  float4 _79 = t1.Sample(s0, float2(_75, _76));
  float _87 = rsqrt(dot(float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, 0.0f), float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, 0.0f)));
  float4 _92 = t1.Sample(s0, float2(_65, _66));
  float4 _98 = t1.Sample(s0, float2(_75, _76));
  float _102 = abs((_62 + -0.5f) * 2.0f);
  float _120 = (cb4_007x * 2.0f) * ((_92.x + -0.5f) + ((_98.x - _92.x) * _102));
  float _122 = (cb4_007y * 2.0f) * ((_92.y + -0.5f) + ((_98.y - _92.y) * _102));
  float _124 = (cb4_007z * 2.0f) * ((_92.z + -0.5f) + ((_98.z - _92.z) * _102));
  float _126 = rsqrt(dot(float3(_120, _122, _124), float3(_120, _122, _124)));
  float _127 = _120 * _126;
  float _128 = _122 * _126;
  float _129 = _124 * _126;
  float _148 = _102 * (_79.w - _69.w);
  float _161 = exp2(log2((((1.0f - _69.w) - _148) + cb4_005x) + ((cb4_006x - cb4_005x) * saturate(dot(float3((_87 * GlobalShaderConsts_144.x), (_87 * GlobalShaderConsts_144.y), 0.0f), float3((((_127 * TEXCOORD_5.x) + (_128 * TEXCOORD_3.x)) + (_129 * TEXCOORD_1.z)), (((_127 * TEXCOORD_5.y) + (_128 * TEXCOORD_3.y)) + (_129 * TEXCOORD_1.w)), (((_127 * TEXCOORD_5.z) + (_128 * TEXCOORD_3.z)) + (_129 * TEXCOORD_3.w))))))) * 2.200000047683716f);
  // Native material tint bypasses the common cloud color groups.
  // Scale its radiance before fog; preserve coverage and fog extinction.
  float night_cloud = WitcherNightCloudMultiplier();
  float _166 = FrequentPixelConsts_032.x * _161 * night_cloud;
  float _167 = FrequentPixelConsts_032.y * _161 * night_cloud;
  float _168 = FrequentPixelConsts_032.z * _161 * night_cloud;
  float _173 = cb1_036x - TEXCOORD_4.x;
  float _174 = cb1_036y - TEXCOORD_4.y;
  float _175 = cb1_036z - TEXCOORD_4.z;
  float _200 = saturate((((_69.w + -1.0f) + _148) + saturate((TEXCOORD_1.x + -1.0f) + (TEXCOORD_2.w * 2.0f))) * cb4_009x);
  float _204 = TEXCOORD.x - _166;
  float _205 = TEXCOORD.y - _167;
  float _206 = TEXCOORD.z - _168;
  float _207 = saturate((sqrt(((_173 * _173) + (_174 * _174)) + (_175 * _175)) - cb4_000x) / (cb4_001x - cb4_000x)) * TEXCOORD.w;
  SV_Target.x = ((((_207 * _204) + _166) + (cb4_008x * (_204 * (TEXCOORD.w - _207)))) * _200);
  SV_Target.y = ((((_207 * _205) + _167) + (cb4_008x * (_205 * (TEXCOORD.w - _207)))) * _200);
  SV_Target.z = ((((_207 * _206) + _168) + (cb4_008x * (_206 * (TEXCOORD.w - _207)))) * _200);
  SV_Target.w = saturate(_200);
  return SV_Target;
}
