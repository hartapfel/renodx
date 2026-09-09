#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

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
  float cb12_012x : packoffset(c012.x);
  float cb12_012y : packoffset(c012.y);
  float cb12_012z : packoffset(c012.z);
  float cb12_012w : packoffset(c012.w);
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

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float2 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _19 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _24 = _19.x * TEXCOORD.x;
  float _25 = _19.y * TEXCOORD.y;
  float _26 = _19.z * TEXCOORD.z;
  float _27 = _19.w * TEXCOORD.w;
  float _40 = _24 * cb13_000x;
  float _41 = mad(_25, cb13_001x, _40);
  float _42 = mad(_26, cb13_002x, _41);
  float _43 = _24 * cb13_000y;
  float _44 = mad(_25, cb13_001y, _43);
  float _45 = mad(_26, cb13_002y, _44);
  float _46 = _24 * cb13_000z;
  float _47 = mad(_25, cb13_001z, _46);
  float _48 = mad(_26, cb13_002z, _47);
  float _49 = dot(float3(_42, _45, _48), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _52 = _49 - _42;
  float _53 = _49 - _45;
  float _54 = _49 - _48;
  float _55 = cbufGlobal_288 * _52;
  float _56 = cbufGlobal_288 * _53;
  float _57 = cbufGlobal_288 * _54;
  float _58 = _55 + _42;
  float _59 = _56 + _45;
  float _60 = _57 + _48;
  float _64 = dot(float2(TEXCOORD_2.x, TEXCOORD_2.y), float2(cb12_012x, cb12_012y));
  float _67 = _64 - cb12_012z;
  float _68 = cb12_012w - cb12_012z;
  float _69 = _67 / _68;
  float _70 = saturate(_69);
  float _71 = _27 * _70;
  float _72 = _71 * _58;
  float _73 = _71 * _59;
  float _74 = _71 * _60;
  float _77 = _72 * cb12_008w;
  float _78 = _73 * cb12_008w;
  float _79 = _74 * cb12_008w;
  SV_Target.x = _77;
  SV_Target.y = _78;
  SV_Target.z = _79;
  SV_Target.w = _71;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_72, _73, _74), _71);
  }
  return SV_Target;
}
