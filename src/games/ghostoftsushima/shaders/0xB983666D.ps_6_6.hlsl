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
  float cb13_005x : packoffset(c005.x);
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
  float _27 = cb12_011x * _22;
  float _28 = cb12_011y * _23;
  float _29 = _27 * _27;
  float _30 = _28 * _28;
  float _31 = _29 + _30;
  float _32 = sqrt(_31);
  float _35 = cb13_005x * 0.5f;
  float _36 = _35 * _32;
  float _39 = _35 + cb12_007w;
  float _40 = _39 * _32;
  float _41 = TEXCOORD_1.x + -0.5f;
  float _42 = TEXCOORD_1.y + -0.5f;
  float _43 = _41 * _41;
  float _44 = _42 * _42;
  float _45 = _44 + _43;
  float _46 = sqrt(_45);
  float _47 = _46 + -0.5f;
  float _48 = _47 + _40;
  float _49 = abs(_48);
  float _50 = _49 - _36;
  float _51 = max(0.0f, _50);
  float _52 = cb12_007w * _32;
  float _53 = _51 / _52;
  float _54 = saturate(_53);
  float _55 = 1.0f - _54;
  float _56 = _17.x * TEXCOORD.x;
  float _57 = _17.y * TEXCOORD.y;
  float _58 = _17.z * TEXCOORD.z;
  float _59 = _17.w * TEXCOORD.w;
  float _60 = dot(float3(_56, _57, _58), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _63 = _60 - _56;
  float _64 = _60 - _57;
  float _65 = _60 - _58;
  float _66 = cbufGlobal_288 * _63;
  float _67 = cbufGlobal_288 * _64;
  float _68 = cbufGlobal_288 * _65;
  float _69 = _66 + _56;
  float _70 = _67 + _57;
  float _71 = _68 + _58;
  float _72 = _55 * _59;
  float _75 = _72 * cb12_008w;
  float _76 = _75 * _69;
  float _77 = _75 * _70;
  float _78 = _75 * _71;
  SV_Target.x = _76;
  SV_Target.y = _77;
  SV_Target.z = _78;
  SV_Target.w = _72;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_69, _70, _71) * _72, _72);
  }
  return SV_Target;
}
