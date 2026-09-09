#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

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
};

SamplerState s0 : register(s0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1
) : SV_Target {
  float4 SV_Target = 0;
  float4 _18 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float4 _24 = t2.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _26 = min(1.0f, _24.x);
  float _27 = _18.x * TEXCOORD.x;
  float _28 = _18.y * TEXCOORD.y;
  float _29 = _18.z * TEXCOORD.z;
  float _30 = _18.w * TEXCOORD.w;
  float _31 = _30 * _26;
  float _44 = cb13_000x * _27;
  float _45 = mad(_28, cb13_001x, _44);
  float _46 = mad(_29, cb13_002x, _45);
  float _47 = cb13_000y * _27;
  float _48 = mad(_28, cb13_001y, _47);
  float _49 = mad(_29, cb13_002y, _48);
  float _50 = cb13_000z * _27;
  float _51 = mad(_28, cb13_001z, _50);
  float _52 = mad(_29, cb13_002z, _51);
  float _53 = dot(float3(_46, _49, _52), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _56 = _53 - _46;
  float _57 = _53 - _49;
  float _58 = _53 - _52;
  float _59 = cbufGlobal_288 * _56;
  float _60 = cbufGlobal_288 * _57;
  float _61 = cbufGlobal_288 * _58;
  float _62 = _59 + _46;
  float _63 = _60 + _49;
  float _64 = _61 + _52;
  float _67 = cb12_008w * _31;
  float _68 = _67 * _62;
  float _69 = _67 * _63;
  float _70 = _67 * _64;
  SV_Target.x = _68;
  SV_Target.y = _69;
  SV_Target.z = _70;
  SV_Target.w = _31;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_62, _63, _64) * _31, _31);
  }
  return SV_Target;
}
