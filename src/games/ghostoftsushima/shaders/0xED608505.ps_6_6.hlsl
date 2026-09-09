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
};

cbuffer cb13 : register(b13) {
  float cb13_004w : packoffset(c004.w);
};

SamplerState s0 : register(s0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1
) : SV_Target {
  float4 SV_Target = 0;
  float4 _17 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _22 = ddx_coarse(TEXCOORD_1.x);
  float _23 = ddy_coarse(TEXCOORD_1.x);
  float _24 = _22 * _22;
  float _25 = _23 * _23;
  float _26 = _25 + _24;
  float _27 = sqrt(_26);
  float _28 = ddx_coarse(TEXCOORD_1.y);
  float _29 = ddy_coarse(TEXCOORD_1.y);
  float _30 = _28 * _28;
  float _31 = _29 * _29;
  float _32 = _31 + _30;
  float _33 = sqrt(_32);
  float _37 = cb12_011x * _27;
  float _38 = cb12_011y * _33;
  float _41 = cb13_004w * 0.5f;
  float _42 = max(0.0f, _41);
  float _45 = cb12_007w + _42;
  float _46 = _45 * _37;
  float _47 = _45 * _38;
  float _48 = 1.0f - _46;
  float _49 = 1.0f - _47;
  float _50 = _46 - TEXCOORD_1.x;
  float _51 = _47 - TEXCOORD_1.y;
  float _52 = TEXCOORD_1.x - _48;
  float _53 = TEXCOORD_1.y - _49;
  float _54 = max(_50, _52);
  float _55 = max(_51, _53);
  float _56 = _54 / _37;
  float _57 = _55 / _38;
  float _58 = abs(_52);
  float _59 = abs(_53);
  float _60 = abs(_50);
  float _61 = abs(_51);
  float _62 = min(_60, _58);
  float _63 = min(_61, _59);
  float _64 = _62 / _37;
  float _65 = _63 / _38;
  float _66 = max(_64, _57);
  float _67 = max(_65, _56);
  float _68 = min(_66, _67);
  float _69 = _68 - _42;
  float _70 = _69 / cb12_007w;
  float _71 = 1.0f - _70;
  float _72 = saturate(_71);
  float _73 = _17.x * TEXCOORD.x;
  float _74 = _17.y * TEXCOORD.y;
  float _75 = _17.z * TEXCOORD.z;
  float _76 = _17.w * TEXCOORD.w;
  float _77 = dot(float3(_73, _74, _75), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _80 = _77 - _73;
  float _81 = _77 - _74;
  float _82 = _77 - _75;
  float _83 = cbufGlobal_288 * _80;
  float _84 = cbufGlobal_288 * _81;
  float _85 = cbufGlobal_288 * _82;
  float _86 = _83 + _73;
  float _87 = _84 + _74;
  float _88 = _85 + _75;
  float _89 = _72 * _76;
  float _92 = _89 * cb12_008w;
  float _93 = _92 * _86;
  float _94 = _92 * _87;
  float _95 = _92 * _88;
  SV_Target.x = _93;
  SV_Target.y = _94;
  SV_Target.z = _95;
  SV_Target.w = _89;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_86, _87, _88) * _89, _89);
  }
  return SV_Target;
}
