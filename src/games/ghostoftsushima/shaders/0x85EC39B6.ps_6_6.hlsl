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
};

SamplerState s0 : register(s0);

SamplerState s2 : register(s2);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _20 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _25 = TEXCOORD_2.x / TEXCOORD_2.w;
  float _26 = TEXCOORD_2.y / TEXCOORD_2.w;
  float _31 = dot(float3(_25, _26, 1.0f), float3(cb12_008x, cb12_008y, cb12_008z));
  float _36 = dot(float3(_25, _26, 1.0f), float3(cb12_009x, cb12_009y, cb12_009z));
  float4 _39 = t11.Sample(s2, float2(_31, _36));
  float _41 = min(1.0f, _39.x);
  float _42 = _20.x * TEXCOORD.x;
  float _43 = _20.y * TEXCOORD.y;
  float _44 = _20.z * TEXCOORD.z;
  float _45 = _20.w * TEXCOORD.w;
  float _46 = _45 * _41;
  float _47 = dot(float3(_42, _43, _44), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _50 = _47 - _42;
  float _51 = _47 - _43;
  float _52 = _47 - _44;
  float _53 = cbufGlobal_288 * _50;
  float _54 = cbufGlobal_288 * _51;
  float _55 = cbufGlobal_288 * _52;
  float _56 = _53 + _42;
  float _57 = _54 + _43;
  float _58 = _55 + _44;
  float _60 = cb12_008w * _46;
  float _61 = _60 * _56;
  float _62 = _60 * _57;
  float _63 = _60 * _58;
  SV_Target.x = _61;
  SV_Target.y = _62;
  SV_Target.z = _63;
  SV_Target.w = _46;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_56, _57, _58) * _46, _46);
  }
  return SV_Target;
}
