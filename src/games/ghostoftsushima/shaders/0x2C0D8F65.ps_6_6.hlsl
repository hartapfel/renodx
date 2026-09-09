#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t10 : register(t10);

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
  float cb12_009w : packoffset(c009.w);
};

cbuffer cb13 : register(b13) {
  float cb13_003x : packoffset(c003.x);
  float cb13_005z : packoffset(c005.z);
};

SamplerState s0 : register(s0);

SamplerState s3 : register(s3);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _22 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _27 = TEXCOORD_2.x / TEXCOORD_2.w;
  float _28 = TEXCOORD_2.y / TEXCOORD_2.w;
  float _32 = cbufGlobal_128.x * _27;
  float _33 = cbufGlobal_128.y * _28;
  float _36 = _32 + cbufGlobal_128.z;
  float _37 = _33 + cbufGlobal_128.w;
  float4 _42 = t10.Sample(s3, float2(_36, _37));
  bool _44 = (cb12_009w < _42.x);
  float _50;
  if (_44) {
    float _48 = cb13_005z * _22.w;
    _50 = _48;
  } else {
    _50 = _22.w;
  }
  float _51 = _22.x * TEXCOORD.x;
  float _52 = _22.y * TEXCOORD.y;
  float _53 = _22.z * TEXCOORD.z;
  float _54 = _50 * TEXCOORD.w;
  float _55 = dot(float3(_51, _52, _53), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _58 = _55 - _51;
  float _59 = _55 - _52;
  float _60 = _55 - _53;
  float _61 = cbufGlobal_288 * _58;
  float _62 = cbufGlobal_288 * _59;
  float _63 = cbufGlobal_288 * _60;
  float _64 = _61 + _51;
  float _65 = _62 + _52;
  float _66 = _63 + _53;
  bool _69 = (_54 < cb13_003x);
  if (_69) {
    if (true) discard;
  }
  float _72 = _64 * _54;
  float _73 = _65 * _54;
  float _74 = _66 * _54;
  float _77 = _72 * cb12_008w;
  float _78 = _73 * cb12_008w;
  float _79 = _74 * cb12_008w;
  SV_Target.x = _77;
  SV_Target.y = _78;
  SV_Target.z = _79;
  SV_Target.w = _54;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_72, _73, _74), _54);
  }
  return SV_Target;
}
