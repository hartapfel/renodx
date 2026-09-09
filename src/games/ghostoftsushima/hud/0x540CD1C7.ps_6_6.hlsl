#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t11 : register(t11);

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
  float cb12_008x : packoffset(c008.x);
  float cb12_008y : packoffset(c008.y);
  float cb12_008z : packoffset(c008.z);
  float cb12_008w : packoffset(c008.w);
  float cb12_009x : packoffset(c009.x);
  float cb12_009y : packoffset(c009.y);
  float cb12_009z : packoffset(c009.z);
  float cb12_012x : packoffset(c012.x);
  float cb12_012y : packoffset(c012.y);
  float cb12_012z : packoffset(c012.z);
  float cb12_012w : packoffset(c012.w);
};

SamplerState s0 : register(s0);

SamplerState s2 : register(s2);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float2 TEXCOORD_3 : TEXCOORD3,
  linear float4 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _22 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _27 = TEXCOORD_2.x / TEXCOORD_2.w;
  float _28 = TEXCOORD_2.y / TEXCOORD_2.w;
  float _33 = dot(float3(_27, _28, 1.0f), float3(cb12_008x, cb12_008y, cb12_008z));
  float _38 = dot(float3(_27, _28, 1.0f), float3(cb12_009x, cb12_009y, cb12_009z));
  float4 _41 = t11.Sample(s2, float2(_33, _38));
  float _43 = min(1.0f, _41.x);
  float _44 = _22.x * TEXCOORD.x;
  float _45 = _22.y * TEXCOORD.y;
  float _46 = _22.z * TEXCOORD.z;
  float _47 = dot(float3(_44, _45, _46), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _50 = _47 - _44;
  float _51 = _47 - _45;
  float _52 = _47 - _46;
  float _53 = cbufGlobal_288 * _50;
  float _54 = cbufGlobal_288 * _51;
  float _55 = cbufGlobal_288 * _52;
  float _56 = _53 + _44;
  float _57 = _54 + _45;
  float _58 = _55 + _46;
  float _62 = dot(float2(TEXCOORD_3.x, TEXCOORD_3.y), float2(cb12_012x, cb12_012y));
  float _65 = _62 - cb12_012z;
  float _66 = cb12_012w - cb12_012z;
  float _67 = _65 / _66;
  float _68 = saturate(_67);
  float _69 = _22.w * TEXCOORD.w;
  float _70 = _69 * _43;
  float _71 = _70 * _68;
  float _72 = _71 * _56;
  float _73 = _71 * _57;
  float _74 = _71 * _58;
  float _76 = _72 * cb12_008w;
  float _77 = _73 * cb12_008w;
  float _78 = _74 * cb12_008w;
  SV_Target.x = _76;
  SV_Target.y = _77;
  SV_Target.z = _78;
  SV_Target.w = _71;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_72, _73, _74), _71);
  }
  return SV_Target;
}
