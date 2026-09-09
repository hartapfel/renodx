#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

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
  float4 _19 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _24 = _19.x * TEXCOORD.x;
  float _25 = _19.y * TEXCOORD.y;
  float _26 = _19.z * TEXCOORD.z;
  float _27 = _19.w * TEXCOORD.w;
  float _28 = dot(float3(_24, _25, _26), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _31 = _28 - _24;
  float _32 = _28 - _25;
  float _33 = _28 - _26;
  float _34 = cbufGlobal_288 * _31;
  float _35 = cbufGlobal_288 * _32;
  float _36 = cbufGlobal_288 * _33;
  float _37 = _34 + _24;
  float _38 = _35 + _25;
  float _39 = _36 + _26;
  float _40 = _37 * _27;
  float _41 = _38 * _27;
  float _42 = _39 * _27;
  float _47 = cb12_005w - cb12_006x;
  float _48 = abs(_47);
  bool _49 = (_48 > 0.0f);
  float _75;
  float _125;
  float _126;
  float _127;
  float _128;
  if (_49) {
    float _53 = cb13_003z * TEXCOORD_1.x;
    float _54 = cb13_003z * TEXCOORD_1.y;
    float4 _57 = t7.SampleLevel(s3, float2(_53, _54), 0.0f);
    bool _61 = !(cb13_004y <= 0.0f);
    if (_61) {
      float _67 = max(cb12_005w, cb12_006x);
      float _68 = _67 - _57.x;
      float _71 = cb13_005y * _68;
      float _72 = 1.0f - _71;
      float _73 = saturate(_72);
      _75 = _73;
    } else {
      _75 = 0.0f;
    }
    float _77 = cb13_004z * _75;
    float _78 = _77 + 1.0f;
    float _79 = _78 * _40;
    float _80 = _78 * _41;
    float _81 = _78 * _42;
    float _88 = min(cb12_005w, cb12_006x);
    float _89 = max(cb12_005w, cb12_006x);
    float _90 = _89 - _88;
    float _91 = 0.5f - _89;
    float _92 = abs(_91);
    float _93 = 0.5f - _92;
    float _94 = cb13_003w * 0.5f;
    float _95 = min(_94, _93);
    float _96 = min(_95, _90);
    bool _97 = (_89 < _57.x);
    float _98 = select(_97, 0.0f, 1.0f);
    float _99 = _57.x - _89;
    float _100 = _99 + _96;
    float _101 = _96 * 2.0f;
    float _102 = _100 / _101;
    float _103 = 1.0f - _102;
    float _104 = saturate(_103);
    bool _105 = (_96 <= 0.0f);
    float _106 = select(_105, _98, _104);
    float _107 = 0.5f - _88;
    float _108 = abs(_107);
    float _109 = 0.5f - _108;
    float _110 = cb13_004x * 0.5f;
    float _111 = min(_110, _109);
    float _112 = min(_111, _90);
    bool _113 = (_57.x < _88);
    float _114 = select(_113, 0.0f, 1.0f);
    float _115 = _88 - _57.x;
    float _116 = _115 + _112;
    float _117 = _112 * 2.0f;
    float _118 = _116 / _117;
    float _119 = 1.0f - _118;
    float _120 = saturate(_119);
    bool _121 = (_112 <= 0.0f);
    float _122 = select(_121, _114, _120);
    float _123 = min(_122, _106);
    _125 = _79;
    _126 = _80;
    _127 = _81;
    _128 = _123;
  } else {
    _125 = _40;
    _126 = _41;
    _127 = _42;
    _128 = 0.0f;
  }
  float _129 = _128 * _125;
  float _130 = _128 * _126;
  float _131 = _128 * _127;
  float _132 = _128 * _27;
  float _135 = _129 * cb12_008w;
  float _136 = _130 * cb12_008w;
  float _137 = _131 * cb12_008w;
  SV_Target.x = _135;
  SV_Target.y = _136;
  SV_Target.z = _137;
  SV_Target.w = _132;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_129, _130, _131), _132);
  }
  return SV_Target;
}
