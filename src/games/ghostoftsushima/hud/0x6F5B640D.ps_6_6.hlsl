#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

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
  float cb12_009w : packoffset(c009.w);
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
  float cb13_003x : packoffset(c003.x);
  float cb13_005z : packoffset(c005.z);
};

SamplerState s0 : register(s0);

SamplerState s3 : register(s3);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
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
  float4 _43 = t10.Sample(s3, float2(_37, _38));
  bool _45 = (cb12_009w < _43.x);
  float _51;
  if (_45) {
    float _49 = cb13_005z * _23.w;
    _51 = _49;
  } else {
    _51 = _23.w;
  }
  float4 _53 = t2.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _55 = min(1.0f, _53.x);
  float _56 = _23.x * TEXCOORD.x;
  float _57 = _23.y * TEXCOORD.y;
  float _58 = _23.z * TEXCOORD.z;
  float _59 = _51 * TEXCOORD.w;
  float _60 = _59 * _55;
  float _73 = cb13_000x * _56;
  float _74 = mad(_57, cb13_001x, _73);
  float _75 = mad(_58, cb13_002x, _74);
  float _76 = cb13_000y * _56;
  float _77 = mad(_57, cb13_001y, _76);
  float _78 = mad(_58, cb13_002y, _77);
  float _79 = cb13_000z * _56;
  float _80 = mad(_57, cb13_001z, _79);
  float _81 = mad(_58, cb13_002z, _80);
  float _82 = dot(float3(_75, _78, _81), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _85 = _82 - _75;
  float _86 = _82 - _78;
  float _87 = _82 - _81;
  float _88 = cbufGlobal_288 * _85;
  float _89 = cbufGlobal_288 * _86;
  float _90 = cbufGlobal_288 * _87;
  float _91 = _88 + _75;
  float _92 = _89 + _78;
  float _93 = _90 + _81;
  bool _96 = (_60 < cb13_003x);
  if (_96) {
    if (true) discard;
  }
  float _99 = _91 * _60;
  float _100 = _92 * _60;
  float _101 = _93 * _60;
  float _104 = _99 * cb12_008w;
  float _105 = _100 * cb12_008w;
  float _106 = _101 * cb12_008w;
  SV_Target.x = _104;
  SV_Target.y = _105;
  SV_Target.z = _106;
  SV_Target.w = _60;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_99, _100, _101), _60);
  }
  return SV_Target;
}
