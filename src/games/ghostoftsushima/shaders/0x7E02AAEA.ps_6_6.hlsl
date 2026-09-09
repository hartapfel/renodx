#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t7 : register(t7);

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
  float cb12_005w : packoffset(c005.w);
  float cb12_006x : packoffset(c006.x);
  float cb12_008w : packoffset(c008.w);
};

cbuffer cb13 : register(b13) {
  float cb13_003z : packoffset(c003.z);
  float cb13_003w : packoffset(c003.w);
  float cb13_004x : packoffset(c004.x);
  float cb13_004y : packoffset(c004.y);
  float cb13_004z : packoffset(c004.z);
  float cb13_005y : packoffset(c005.y);
};

SamplerState s0 : register(s0);

SamplerState s3 : register(s3);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _20 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float4 _26 = t2.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _28 = min(1.0f, _26.x);
  float _29 = _20.x * TEXCOORD.x;
  float _30 = _20.y * TEXCOORD.y;
  float _31 = _20.z * TEXCOORD.z;
  float _32 = _20.w * TEXCOORD.w;
  float _33 = _32 * _28;
  float _34 = dot(float3(_29, _30, _31), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _37 = _34 - _29;
  float _38 = _34 - _30;
  float _39 = _34 - _31;
  float _40 = cbufGlobal_288 * _37;
  float _41 = cbufGlobal_288 * _38;
  float _42 = cbufGlobal_288 * _39;
  float _43 = _40 + _29;
  float _44 = _41 + _30;
  float _45 = _42 + _31;
  float _46 = _43 * _33;
  float _47 = _44 * _33;
  float _48 = _45 * _33;
  float _53 = cb12_005w - cb12_006x;
  float _54 = abs(_53);
  bool _55 = (_54 > 0.0f);
  float _81;
  float _131;
  float _132;
  float _133;
  float _134;
  if (_55) {
    float _59 = cb13_003z * TEXCOORD_1.x;
    float _60 = cb13_003z * TEXCOORD_1.y;
    float4 _63 = t7.SampleLevel(s3, float2(_59, _60), 0.0f);
    bool _67 = !(cb13_004y <= 0.0f);
    if (_67) {
      float _73 = max(cb12_005w, cb12_006x);
      float _74 = _73 - _63.x;
      float _77 = cb13_005y * _74;
      float _78 = 1.0f - _77;
      float _79 = saturate(_78);
      _81 = _79;
    } else {
      _81 = 0.0f;
    }
    float _83 = cb13_004z * _81;
    float _84 = _83 + 1.0f;
    float _85 = _84 * _46;
    float _86 = _84 * _47;
    float _87 = _84 * _48;
    float _94 = min(cb12_005w, cb12_006x);
    float _95 = max(cb12_005w, cb12_006x);
    float _96 = _95 - _94;
    float _97 = 0.5f - _95;
    float _98 = abs(_97);
    float _99 = 0.5f - _98;
    float _100 = cb13_003w * 0.5f;
    float _101 = min(_100, _99);
    float _102 = min(_101, _96);
    bool _103 = (_95 < _63.x);
    float _104 = select(_103, 0.0f, 1.0f);
    float _105 = _63.x - _95;
    float _106 = _105 + _102;
    float _107 = _102 * 2.0f;
    float _108 = _106 / _107;
    float _109 = 1.0f - _108;
    float _110 = saturate(_109);
    bool _111 = (_102 <= 0.0f);
    float _112 = select(_111, _104, _110);
    float _113 = 0.5f - _94;
    float _114 = abs(_113);
    float _115 = 0.5f - _114;
    float _116 = cb13_004x * 0.5f;
    float _117 = min(_116, _115);
    float _118 = min(_117, _96);
    bool _119 = (_63.x < _94);
    float _120 = select(_119, 0.0f, 1.0f);
    float _121 = _94 - _63.x;
    float _122 = _121 + _118;
    float _123 = _118 * 2.0f;
    float _124 = _122 / _123;
    float _125 = 1.0f - _124;
    float _126 = saturate(_125);
    bool _127 = (_118 <= 0.0f);
    float _128 = select(_127, _120, _126);
    float _129 = min(_128, _112);
    _131 = _85;
    _132 = _86;
    _133 = _87;
    _134 = _129;
  } else {
    _131 = _46;
    _132 = _47;
    _133 = _48;
    _134 = 0.0f;
  }
  float _135 = _134 * _131;
  float _136 = _134 * _132;
  float _137 = _134 * _133;
  float _138 = _134 * _33;
  float _141 = _135 * cb12_008w;
  float _142 = _136 * cb12_008w;
  float _143 = _137 * cb12_008w;
  SV_Target.x = _141;
  SV_Target.y = _142;
  SV_Target.z = _143;
  SV_Target.w = _138;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_135, _136, _137), _138);
  }
  return SV_Target;
}
