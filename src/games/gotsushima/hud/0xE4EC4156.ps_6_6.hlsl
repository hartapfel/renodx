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
  float cb12_007w : packoffset(c007.w);
  float cb12_008w : packoffset(c008.w);
  float cb12_011x : packoffset(c011.x);
  float cb12_011y : packoffset(c011.y);
  float cb12_012x : packoffset(c012.x);
  float cb12_012y : packoffset(c012.y);
  float cb12_012z : packoffset(c012.z);
  float cb12_012w : packoffset(c012.w);
};

cbuffer cb13 : register(b13) {
  float cb13_004w : packoffset(c004.w);
};

SamplerState s0 : register(s0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float2 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _19 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _24 = ddx_coarse(TEXCOORD_1.x);
  float _25 = ddy_coarse(TEXCOORD_1.x);
  float _26 = _24 * _24;
  float _27 = _25 * _25;
  float _28 = _27 + _26;
  float _29 = sqrt(_28);
  float _30 = ddx_coarse(TEXCOORD_1.y);
  float _31 = ddy_coarse(TEXCOORD_1.y);
  float _32 = _30 * _30;
  float _33 = _31 * _31;
  float _34 = _33 + _32;
  float _35 = sqrt(_34);
  float _39 = cb12_011x * _29;
  float _40 = cb12_011y * _35;
  float _43 = cb13_004w * 0.5f;
  float _44 = max(0.0f, _43);
  float _47 = cb12_007w + _44;
  float _48 = _47 * _39;
  float _49 = _47 * _40;
  float _50 = 1.0f - _48;
  float _51 = 1.0f - _49;
  float _52 = _48 - TEXCOORD_1.x;
  float _53 = _49 - TEXCOORD_1.y;
  float _54 = TEXCOORD_1.x - _50;
  float _55 = TEXCOORD_1.y - _51;
  float _56 = max(_52, _54);
  float _57 = max(_53, _55);
  float _58 = _56 / _39;
  float _59 = _57 / _40;
  float _60 = abs(_54);
  float _61 = abs(_55);
  float _62 = abs(_52);
  float _63 = abs(_53);
  float _64 = min(_62, _60);
  float _65 = min(_63, _61);
  float _66 = _64 / _39;
  float _67 = _65 / _40;
  float _68 = max(_66, _59);
  float _69 = max(_67, _58);
  float _70 = min(_68, _69);
  float _71 = _70 - _44;
  float _72 = _71 / cb12_007w;
  float _73 = 1.0f - _72;
  float _74 = saturate(_73);
  float _75 = _19.x * TEXCOORD.x;
  float _76 = _19.y * TEXCOORD.y;
  float _77 = _19.z * TEXCOORD.z;
  float _78 = _19.w * TEXCOORD.w;
  float _79 = dot(float3(_75, _76, _77), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _82 = _79 - _75;
  float _83 = _79 - _76;
  float _84 = _79 - _77;
  float _85 = cbufGlobal_288 * _82;
  float _86 = cbufGlobal_288 * _83;
  float _87 = cbufGlobal_288 * _84;
  float _88 = _85 + _75;
  float _89 = _86 + _76;
  float _90 = _87 + _77;
  float _94 = dot(float2(TEXCOORD_2.x, TEXCOORD_2.y), float2(cb12_012x, cb12_012y));
  float _97 = _94 - cb12_012z;
  float _98 = cb12_012w - cb12_012z;
  float _99 = _97 / _98;
  float _100 = saturate(_99);
  float _101 = _78 * _100;
  float _102 = _101 * _74;
  float _105 = _88 * _74;
  float _106 = _105 * _101;
  float _107 = _106 * cb12_008w;
  float _108 = _89 * _74;
  float _109 = _108 * _101;
  float _110 = _109 * cb12_008w;
  float _111 = _90 * _74;
  float _112 = _111 * _101;
  float _113 = _112 * cb12_008w;
  SV_Target.x = _107;
  SV_Target.y = _110;
  SV_Target.z = _113;
  SV_Target.w = _102;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_106, _109, _112), _102);
  }
  return SV_Target;
}
