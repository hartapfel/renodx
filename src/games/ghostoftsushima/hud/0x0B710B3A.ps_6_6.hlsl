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

SamplerState s0 : register(s0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float2 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _17 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _22 = _17.x * TEXCOORD.x;
  float _23 = _17.y * TEXCOORD.y;
  float _24 = _17.z * TEXCOORD.z;
  float _25 = _17.w * TEXCOORD.w;
  float _26 = dot(float3(_22, _23, _24), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _29 = _26 - _22;
  float _30 = _26 - _23;
  float _31 = _26 - _24;
  float _32 = cbufGlobal_288 * _29;
  float _33 = cbufGlobal_288 * _30;
  float _34 = cbufGlobal_288 * _31;
  float _35 = _32 + _22;
  float _36 = _33 + _23;
  float _37 = _34 + _24;
  float _41 = dot(float2(TEXCOORD_2.x, TEXCOORD_2.y), float2(cb12_012x, cb12_012y));
  float _44 = _41 - cb12_012z;
  float _45 = cb12_012w - cb12_012z;
  float _46 = _44 / _45;
  float _47 = saturate(_46);
  float _48 = _25 * _47;
  float _49 = _48 * _35;
  float _50 = _48 * _36;
  float _51 = _48 * _37;
  float _54 = _49 * cb12_008w;
  float _55 = _50 * cb12_008w;
  float _56 = _51 * cb12_008w;
  SV_Target.x = _54;
  SV_Target.y = _55;
  SV_Target.z = _56;
  SV_Target.w = _48;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_49, _50, _51), _48);
  }
  return SV_Target;
}
