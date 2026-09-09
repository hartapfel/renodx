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
  float cb12_000x : packoffset(c000.x);
  float cb12_000y : packoffset(c000.y);
  float cb12_000z : packoffset(c000.z);
  float cb12_001x : packoffset(c001.x);
  float cb12_001y : packoffset(c001.y);
  float cb12_001z : packoffset(c001.z);
  float cb12_002x : packoffset(c002.x);
  float cb12_002y : packoffset(c002.y);
  float cb12_002z : packoffset(c002.z);
  float cb12_008w : packoffset(c008.w);
};

SamplerState s0 : register(s0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1
) : SV_Target {
  float4 SV_Target = 0;
  float4 _15 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _20 = _15.x * TEXCOORD.x;
  float _21 = _15.y * TEXCOORD.y;
  float _22 = _15.z * TEXCOORD.z;
  float _23 = _15.w * TEXCOORD.w;
  float _36 = _20 * cb12_000x;
  float _37 = mad(_21, cb12_001x, _36);
  float _38 = mad(_22, cb12_002x, _37);
  float _39 = _20 * cb12_000y;
  float _40 = mad(_21, cb12_001y, _39);
  float _41 = mad(_22, cb12_002y, _40);
  float _42 = _20 * cb12_000z;
  float _43 = mad(_21, cb12_001z, _42);
  float _44 = mad(_22, cb12_002z, _43);
  float _45 = dot(float3(_38, _41, _44), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _48 = _45 - _38;
  float _49 = _45 - _41;
  float _50 = _45 - _44;
  float _51 = cbufGlobal_288 * _48;
  float _52 = cbufGlobal_288 * _49;
  float _53 = cbufGlobal_288 * _50;
  float _54 = _51 + _38;
  float _55 = _52 + _41;
  float _56 = _53 + _44;
  float _59 = cb12_008w * _23;
  float _60 = _59 * _54;
  float _61 = _59 * _55;
  float _62 = _59 * _56;
  SV_Target.x = _60;
  SV_Target.y = _61;
  SV_Target.z = _62;
  SV_Target.w = _23;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_54, _55, _56) * _23, _23);
  }
  return SV_Target;
}
