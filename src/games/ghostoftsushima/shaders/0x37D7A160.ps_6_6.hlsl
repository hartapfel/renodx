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
  float cb13_000x : packoffset(c000.x);
  float cb13_000y : packoffset(c000.y);
  float cb13_000z : packoffset(c000.z);
  float cb13_001x : packoffset(c001.x);
  float cb13_001y : packoffset(c001.y);
  float cb13_001z : packoffset(c001.z);
  float cb13_002x : packoffset(c002.x);
  float cb13_002y : packoffset(c002.y);
  float cb13_002z : packoffset(c002.z);
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
  float _40 = _24 * cb13_000x;
  float _41 = mad(_25, cb13_001x, _40);
  float _42 = mad(_26, cb13_002x, _41);
  float _43 = _24 * cb13_000y;
  float _44 = mad(_25, cb13_001y, _43);
  float _45 = mad(_26, cb13_002y, _44);
  float _46 = _24 * cb13_000z;
  float _47 = mad(_25, cb13_001z, _46);
  float _48 = mad(_26, cb13_002z, _47);
  float _49 = dot(float3(_42, _45, _48), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _52 = _49 - _42;
  float _53 = _49 - _45;
  float _54 = _49 - _48;
  float _55 = cbufGlobal_288 * _52;
  float _56 = cbufGlobal_288 * _53;
  float _57 = cbufGlobal_288 * _54;
  float _58 = _55 + _42;
  float _59 = _56 + _45;
  float _60 = _57 + _48;
  float _61 = _58 * _27;
  float _62 = _59 * _27;
  float _63 = _60 * _27;
  float _68 = cb12_005w - cb12_006x;
  float _69 = abs(_68);
  bool _70 = (_69 > 0.0f);
  float _96;
  float _146;
  float _147;
  float _148;
  float _149;
  if (_70) {
    float _74 = cb13_003z * TEXCOORD_1.x;
    float _75 = cb13_003z * TEXCOORD_1.y;
    float4 _78 = t7.SampleLevel(s3, float2(_74, _75), 0.0f);
    bool _82 = !(cb13_004y <= 0.0f);
    if (_82) {
      float _88 = max(cb12_005w, cb12_006x);
      float _89 = _88 - _78.x;
      float _92 = cb13_005y * _89;
      float _93 = 1.0f - _92;
      float _94 = saturate(_93);
      _96 = _94;
    } else {
      _96 = 0.0f;
    }
    float _98 = cb13_004z * _96;
    float _99 = _98 + 1.0f;
    float _100 = _99 * _61;
    float _101 = _99 * _62;
    float _102 = _99 * _63;
    float _109 = min(cb12_005w, cb12_006x);
    float _110 = max(cb12_005w, cb12_006x);
    float _111 = _110 - _109;
    float _112 = 0.5f - _110;
    float _113 = abs(_112);
    float _114 = 0.5f - _113;
    float _115 = cb13_003w * 0.5f;
    float _116 = min(_115, _114);
    float _117 = min(_116, _111);
    bool _118 = (_110 < _78.x);
    float _119 = select(_118, 0.0f, 1.0f);
    float _120 = _78.x - _110;
    float _121 = _120 + _117;
    float _122 = _117 * 2.0f;
    float _123 = _121 / _122;
    float _124 = 1.0f - _123;
    float _125 = saturate(_124);
    bool _126 = (_117 <= 0.0f);
    float _127 = select(_126, _119, _125);
    float _128 = 0.5f - _109;
    float _129 = abs(_128);
    float _130 = 0.5f - _129;
    float _131 = cb13_004x * 0.5f;
    float _132 = min(_131, _130);
    float _133 = min(_132, _111);
    bool _134 = (_78.x < _109);
    float _135 = select(_134, 0.0f, 1.0f);
    float _136 = _109 - _78.x;
    float _137 = _136 + _133;
    float _138 = _133 * 2.0f;
    float _139 = _137 / _138;
    float _140 = 1.0f - _139;
    float _141 = saturate(_140);
    bool _142 = (_133 <= 0.0f);
    float _143 = select(_142, _135, _141);
    float _144 = min(_143, _127);
    _146 = _100;
    _147 = _101;
    _148 = _102;
    _149 = _144;
  } else {
    _146 = _61;
    _147 = _62;
    _148 = _63;
    _149 = 0.0f;
  }
  float _150 = _149 * _146;
  float _151 = _149 * _147;
  float _152 = _149 * _148;
  float _153 = _149 * _27;
  float _156 = _150 * cb12_008w;
  float _157 = _151 * cb12_008w;
  float _158 = _152 * cb12_008w;
  SV_Target.x = _156;
  SV_Target.y = _157;
  SV_Target.z = _158;
  SV_Target.w = _153;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_150, _151, _152), _153);
  }
  return SV_Target;
}
