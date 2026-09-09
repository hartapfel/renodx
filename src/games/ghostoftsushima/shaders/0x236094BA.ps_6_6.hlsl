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

SamplerState s0 : register(s0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1
) : SV_Target {
  float4 SV_Target = 0;
  float4 _16 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float4 _22 = t2.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _24 = min(1.0f, _22.x);
  float _25 = _16.x * TEXCOORD.x;
  float _26 = _16.y * TEXCOORD.y;
  float _27 = _16.z * TEXCOORD.z;
  float _28 = _16.w * TEXCOORD.w;
  float _29 = _28 * _24;
  float _30 = dot(float3(_25, _26, _27), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _33 = _30 - _25;
  float _34 = _30 - _26;
  float _35 = _30 - _27;
  float _36 = cbufGlobal_288 * _33;
  float _37 = cbufGlobal_288 * _34;
  float _38 = cbufGlobal_288 * _35;
  float _39 = _36 + _25;
  float _40 = _37 + _26;
  float _41 = _38 + _27;
  float _44 = cb12_008w * _29;
  float _45 = _44 * _39;
  float _46 = _44 * _40;
  float _47 = _44 * _41;
  SV_Target.x = _45;
  SV_Target.y = _46;
  SV_Target.z = _47;
  SV_Target.w = _29;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_39, _40, _41) * _29, _29);
  }
  return SV_Target;
}
