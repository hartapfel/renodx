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
  linear float2 TEXCOORD_1 : TEXCOORD1
) : SV_Target {
  float4 SV_Target = 0;
  float4 _17 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _22 = _17.x * TEXCOORD.x;
  float _23 = _17.y * TEXCOORD.y;
  float _24 = _17.z * TEXCOORD.z;
  float _25 = _17.w * TEXCOORD.w;
  float _38 = _22 * cb13_000x;
  float _39 = mad(_23, cb13_001x, _38);
  float _40 = mad(_24, cb13_002x, _39);
  float _41 = _22 * cb13_000y;
  float _42 = mad(_23, cb13_001y, _41);
  float _43 = mad(_24, cb13_002y, _42);
  float _44 = _22 * cb13_000z;
  float _45 = mad(_23, cb13_001z, _44);
  float _46 = mad(_24, cb13_002z, _45);
  float _59 = cb12_000x * _40;
  float _60 = mad(_43, cb12_001x, _59);
  float _61 = mad(_46, cb12_002x, _60);
  float _62 = cb12_000y * _40;
  float _63 = mad(_43, cb12_001y, _62);
  float _64 = mad(_46, cb12_002y, _63);
  float _65 = cb12_000z * _40;
  float _66 = mad(_43, cb12_001z, _65);
  float _67 = mad(_46, cb12_002z, _66);
  float _68 = dot(float3(_61, _64, _67), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _71 = _68 - _61;
  float _72 = _68 - _64;
  float _73 = _68 - _67;
  float _74 = cbufGlobal_288 * _71;
  float _75 = cbufGlobal_288 * _72;
  float _76 = cbufGlobal_288 * _73;
  float _77 = _74 + _61;
  float _78 = _75 + _64;
  float _79 = _76 + _67;
  float _82 = cb12_008w * _25;
  float _83 = _82 * _77;
  float _84 = _82 * _78;
  float _85 = _82 * _79;
  SV_Target.x = _83;
  SV_Target.y = _84;
  SV_Target.z = _85;
  SV_Target.w = _25;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_77, _78, _79) * _25, _25);
  }
  return SV_Target;
}
