#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t10 : register(t10);

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
  float cb12_008w : packoffset(c008.w);
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
  float cb13_005z : packoffset(c005.z);
};

SamplerState s0 : register(s0);

SamplerState s3 : register(s3);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float TEXCOORD_3 : TEXCOORD3,
  linear float4 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _23 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _28 = TEXCOORD_2.x / TEXCOORD_2.w;
  float _29 = TEXCOORD_2.y / TEXCOORD_2.w;
  float _33 = cbufGlobal_128.x * _28;
  float _34 = cbufGlobal_128.y * _29;
  float _37 = _33 + cbufGlobal_128.z;
  float _38 = _34 + cbufGlobal_128.w;
  float4 _41 = t10.Sample(s3, float2(_37, _38));
  bool _43 = (TEXCOORD_3 < _41.x);
  float _49;
  if (_43) {
    float _47 = cb13_005z * _23.w;
    _49 = _47;
  } else {
    _49 = _23.w;
  }
  float _50 = _23.x * TEXCOORD.x;
  float _51 = _23.y * TEXCOORD.y;
  float _52 = _23.z * TEXCOORD.z;
  float _53 = _49 * TEXCOORD.w;
  float _66 = cb13_000x * _50;
  float _67 = mad(_51, cb13_001x, _66);
  float _68 = mad(_52, cb13_002x, _67);
  float _69 = cb13_000y * _50;
  float _70 = mad(_51, cb13_001y, _69);
  float _71 = mad(_52, cb13_002y, _70);
  float _72 = cb13_000z * _50;
  float _73 = mad(_51, cb13_001z, _72);
  float _74 = mad(_52, cb13_002z, _73);
  float _75 = dot(float3(_68, _71, _74), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _78 = _75 - _68;
  float _79 = _75 - _71;
  float _80 = _75 - _74;
  float _81 = cbufGlobal_288 * _78;
  float _82 = cbufGlobal_288 * _79;
  float _83 = cbufGlobal_288 * _80;
  float _84 = _81 + _68;
  float _85 = _82 + _71;
  float _86 = _83 + _74;
  float _89 = cb12_008w * _53;
  float _90 = _89 * _84;
  float _91 = _89 * _85;
  float _92 = _89 * _86;
  SV_Target.x = _90;
  SV_Target.y = _91;
  SV_Target.z = _92;
  SV_Target.w = _53;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_84, _85, _86) * _53, _53);
  }
  return SV_Target;
}
