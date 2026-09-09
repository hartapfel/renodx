#include "../ui.hlsli"

Texture2D<float4> t2 : register(t2);

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
  float4 _17 = t5.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float4 _20 = t6.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _23 = _17.x * 1.16412353515625f;
  float _24 = _20.y * 1.595794677734375f;
  float _25 = _20.y * 0.8134765625f;
  float _26 = _20.x * 0.391448974609375f;
  float _27 = _20.x * 2.017822265625f;
  float _28 = _23 + -0.8706550598144531f;
  float _29 = _28 + _24;
  float _30 = _23 + 0.5297050476074219f;
  float _31 = _30 - _25;
  float _32 = _31 - _26;
  float _33 = _23 + -1.0816688537597656f;
  float _34 = _33 + _27;
  float4 _38 = t2.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _40 = min(1.0f, _38.x);
  float _41 = _29 * TEXCOORD.x;
  float _42 = _32 * TEXCOORD.y;
  float _43 = _34 * TEXCOORD.z;
  float _44 = cb12_011z * TEXCOORD.w;
  float _45 = _44 * _40;
  float _46 = dot(float3(_41, _42, _43), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _49 = _46 - _41;
  float _50 = _46 - _42;
  float _51 = _46 - _43;
  float _52 = cbufGlobal_288 * _49;
  float _53 = cbufGlobal_288 * _50;
  float _54 = cbufGlobal_288 * _51;
  float _55 = _52 + _41;
  float _56 = _53 + _42;
  float _57 = _54 + _43;
  float _60 = cb12_008w * _45;
  float _61 = _60 * _55;
  float _62 = _60 * _56;
  float _63 = _60 * _57;
  SV_Target.x = _61;
  SV_Target.y = _62;
  SV_Target.z = _63;
  SV_Target.w = _45;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_55, _56, _57) * _45, _45);
  }
  return SV_Target;
}
