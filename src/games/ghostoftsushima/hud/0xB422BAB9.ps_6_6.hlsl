#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t10 : register(t10);

Texture2D<float4> t12 : register(t12);

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
  float _56;
  float _57;
  float _58;
  float _59;
  if (_43) {
    float4 _47 = t12.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
    float _54 = cb13_005z * _47.w;
    _56 = _47.x;
    _57 = _47.y;
    _58 = _47.z;
    _59 = _54;
  } else {
    _56 = _23.x;
    _57 = _23.y;
    _58 = _23.z;
    _59 = _23.w;
  }
  float _60 = _56 * TEXCOORD.x;
  float _61 = _57 * TEXCOORD.y;
  float _62 = _58 * TEXCOORD.z;
  float _63 = _59 * TEXCOORD.w;
  float _64 = dot(float3(_60, _61, _62), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _67 = _64 - _60;
  float _68 = _64 - _61;
  float _69 = _64 - _62;
  float _70 = cbufGlobal_288 * _67;
  float _71 = cbufGlobal_288 * _68;
  float _72 = cbufGlobal_288 * _69;
  float _73 = _70 + _60;
  float _74 = _71 + _61;
  float _75 = _72 + _62;
  float _78 = cb12_008w * _63;
  float _79 = _78 * _73;
  float _80 = _78 * _74;
  float _81 = _78 * _75;
  SV_Target.x = _79;
  SV_Target.y = _80;
  SV_Target.z = _81;
  SV_Target.w = _63;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_73, _74, _75) * _63, _63);
  }
  return SV_Target;
}
