#include "../ui.hlsli"

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t6 : register(t6);

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
  float cb12_011z : packoffset(c011.z);
};

SamplerState s0 : register(s0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1
) : SV_Target {
  float4 SV_Target = 0;
  float4 _16 = t5.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float4 _19 = t6.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _22 = _16.x * 1.16412353515625f;
  float _23 = _19.y * 1.595794677734375f;
  float _24 = _19.y * 0.8134765625f;
  float _25 = _19.x * 0.391448974609375f;
  float _26 = _19.x * 2.017822265625f;
  float _27 = _22 + -0.8706550598144531f;
  float _28 = _27 + _23;
  float _29 = _22 + 0.5297050476074219f;
  float _30 = _29 - _24;
  float _31 = _30 - _25;
  float _32 = _22 + -1.0816688537597656f;
  float _33 = _32 + _26;
  float _36 = _28 * TEXCOORD.x;
  float _37 = _31 * TEXCOORD.y;
  float _38 = _33 * TEXCOORD.z;
  float _39 = cb12_011z * TEXCOORD.w;
  float _40 = dot(float3(_36, _37, _38), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _43 = _40 - _36;
  float _44 = _40 - _37;
  float _45 = _40 - _38;
  float _46 = _43 * cbufGlobal_288;
  float _47 = _44 * cbufGlobal_288;
  float _48 = _45 * cbufGlobal_288;
  float _49 = _46 + _36;
  float _50 = _47 + _37;
  float _51 = _48 + _38;
  float _54 = _49 * cb12_008w;
  float _55 = _50 * cb12_008w;
  float _56 = _51 * cb12_008w;
  SV_Target.x = _54;
  SV_Target.y = _55;
  SV_Target.z = _56;
  SV_Target.w = _39;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_49, _50, _51), 1.f);
  }
  return SV_Target;
}
