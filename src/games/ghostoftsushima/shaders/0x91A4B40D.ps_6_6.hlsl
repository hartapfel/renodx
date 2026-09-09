#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t11 : register(t11);

cbuffer cb0 : register(b0) {
  float4 cbufGlobal_000[4] : packoffset(c000.x);
  float4 cbufGlobal_064[4] : packoffset(c004.x);
  float4 cbufGlobal_128 : packoffset(c008.x);
  float4 cbufGlobal_144 : packoffset(c009.x);
  float2 cbufGlobal_160 : packoffset(c010.x);
  float2 cbufGlobal_168 : packoffset(c010.z);
  float4 cbufGlobal_176 : packoffset(c011.x);
  float4 cbufGlobal_192 : packoffset(c012.x);
  float3 cbufGlobal_208 : packoffset(c013.x);
  float cbufGlobal_220 : packoffset(c013.w);
  float cbufGlobal_224 : packoffset(c014.x);
  float cbufGlobal_228 : packoffset(c014.y);
  float cbufGlobal_232 : packoffset(c014.z);
  float cbufGlobal_236 : packoffset(c014.w);
  float cbufGlobal_240 : packoffset(c015.x);
  float cbufGlobal_244 : packoffset(c015.y);
  float cbufGlobal_248 : packoffset(c015.z);
  float cbufGlobal_252 : packoffset(c015.w);
  float cbufGlobal_256 : packoffset(c016.x);
  float cbufGlobal_260 : packoffset(c016.y);
  float cbufGlobal_264 : packoffset(c016.z);
  float cbufGlobal_268 : packoffset(c016.w);
  float2 cbufGlobal_272 : packoffset(c017.x);
  int cbufGlobal_280 : packoffset(c017.z);
  float cbufGlobal_284 : packoffset(c017.w);
  float cbufGlobal_288 : packoffset(c018.x);
  float3 cbufGlobal_292 : packoffset(c018.y);
};

cbuffer cb12 : register(b12) {
  float cb12_008x : packoffset(c008.x);
  float cb12_008y : packoffset(c008.y);
  float cb12_008z : packoffset(c008.z);
  float cb12_008w : packoffset(c008.w);
  float cb12_009x : packoffset(c009.x);
  float cb12_009y : packoffset(c009.y);
  float cb12_009z : packoffset(c009.z);
};

cbuffer cb13 : register(b13) {
  float cb13_000x : packoffset(c000.x);
  float cb13_000y : packoffset(c000.y);
  float cb13_000z : packoffset(c000.z);
  float cb13_001x : packoffset(c001.x);
  float cb13_001y : packoffset(c001.y);
  float cb13_001z : packoffset(c001.z);
  float cb13_002x : packoffset(c002.x);
  float cb13_002y : packoffset(c002.y);
  float cb13_002z : packoffset(c002.z);
};

SamplerState s0 : register(s0);

SamplerState s2 : register(s2);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _22 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _27 = TEXCOORD_2.x / TEXCOORD_2.w;
  float _28 = TEXCOORD_2.y / TEXCOORD_2.w;
  float _33 = dot(float3(_27, _28, 1.0f), float3(cb12_008x, cb12_008y, cb12_008z));
  float _38 = dot(float3(_27, _28, 1.0f), float3(cb12_009x, cb12_009y, cb12_009z));
  float4 _41 = t11.Sample(s2, float2(_33, _38));
  float _43 = min(1.0f, _41.x);
  float _44 = _22.x * TEXCOORD.x;
  float _45 = _22.y * TEXCOORD.y;
  float _46 = _22.z * TEXCOORD.z;
  float _47 = _22.w * TEXCOORD.w;
  float _48 = _47 * _43;
  float _61 = cb13_000x * _44;
  float _62 = mad(_45, cb13_001x, _61);
  float _63 = mad(_46, cb13_002x, _62);
  float _64 = cb13_000y * _44;
  float _65 = mad(_45, cb13_001y, _64);
  float _66 = mad(_46, cb13_002y, _65);
  float _67 = cb13_000z * _44;
  float _68 = mad(_45, cb13_001z, _67);
  float _69 = mad(_46, cb13_002z, _68);
  float _70 = dot(float3(_63, _66, _69), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _73 = _70 - _63;
  float _74 = _70 - _66;
  float _75 = _70 - _69;
  float _76 = cbufGlobal_288 * _73;
  float _77 = cbufGlobal_288 * _74;
  float _78 = cbufGlobal_288 * _75;
  float _79 = _76 + _63;
  float _80 = _77 + _66;
  float _81 = _78 + _69;
  float _83 = cb12_008w * _48;
  float _84 = _83 * _79;
  float _85 = _83 * _80;
  float _86 = _83 * _81;
  SV_Target.x = _84;
  SV_Target.y = _85;
  SV_Target.z = _86;
  SV_Target.w = _48;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_79, _80, _81) * _48, _48);
  }
  return SV_Target;
}
