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
  float cb12_012x : packoffset(c012.x);
  float cb12_012y : packoffset(c012.y);
  float cb12_012z : packoffset(c012.z);
  float cb12_012w : packoffset(c012.w);
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
  linear float2 TEXCOORD_3 : TEXCOORD3,
  linear float4 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _21 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _26 = _21.x * TEXCOORD.x;
  float _27 = _21.y * TEXCOORD.y;
  float _28 = _21.z * TEXCOORD.z;
  float _29 = _21.w * TEXCOORD.w;
  float _30 = dot(float3(_26, _27, _28), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _33 = _30 - _26;
  float _34 = _30 - _27;
  float _35 = _30 - _28;
  float _36 = cbufGlobal_288 * _33;
  float _37 = cbufGlobal_288 * _34;
  float _38 = cbufGlobal_288 * _35;
  float _39 = _36 + _26;
  float _40 = _37 + _27;
  float _41 = _38 + _28;
  float _45 = dot(float2(TEXCOORD_3.x, TEXCOORD_3.y), float2(cb12_012x, cb12_012y));
  float _48 = _45 - cb12_012z;
  float _49 = cb12_012w - cb12_012z;
  float _50 = _48 / _49;
  float _51 = saturate(_50);
  float _52 = _29 * _51;
  float _53 = _52 * _39;
  float _54 = _52 * _40;
  float _55 = _52 * _41;
  float _60 = cb12_005w - cb12_006x;
  float _61 = abs(_60);
  bool _62 = (_61 > 0.0f);
  float _88;
  float _138;
  float _139;
  float _140;
  float _141;
  if (_62) {
    float _66 = cb13_003z * TEXCOORD_1.x;
    float _67 = cb13_003z * TEXCOORD_1.y;
    float4 _70 = t7.SampleLevel(s3, float2(_66, _67), 0.0f);
    bool _74 = !(cb13_004y <= 0.0f);
    if (_74) {
      float _80 = max(cb12_005w, cb12_006x);
      float _81 = _80 - _70.x;
      float _84 = cb13_005y * _81;
      float _85 = 1.0f - _84;
      float _86 = saturate(_85);
      _88 = _86;
    } else {
      _88 = 0.0f;
    }
    float _90 = cb13_004z * _88;
    float _91 = _90 + 1.0f;
    float _92 = _91 * _53;
    float _93 = _91 * _54;
    float _94 = _91 * _55;
    float _101 = min(cb12_005w, cb12_006x);
    float _102 = max(cb12_005w, cb12_006x);
    float _103 = _102 - _101;
    float _104 = 0.5f - _102;
    float _105 = abs(_104);
    float _106 = 0.5f - _105;
    float _107 = cb13_003w * 0.5f;
    float _108 = min(_107, _106);
    float _109 = min(_108, _103);
    bool _110 = (_102 < _70.x);
    float _111 = select(_110, 0.0f, 1.0f);
    float _112 = _70.x - _102;
    float _113 = _112 + _109;
    float _114 = _109 * 2.0f;
    float _115 = _113 / _114;
    float _116 = 1.0f - _115;
    float _117 = saturate(_116);
    bool _118 = (_109 <= 0.0f);
    float _119 = select(_118, _111, _117);
    float _120 = 0.5f - _101;
    float _121 = abs(_120);
    float _122 = 0.5f - _121;
    float _123 = cb13_004x * 0.5f;
    float _124 = min(_123, _122);
    float _125 = min(_124, _103);
    bool _126 = (_70.x < _101);
    float _127 = select(_126, 0.0f, 1.0f);
    float _128 = _101 - _70.x;
    float _129 = _128 + _125;
    float _130 = _125 * 2.0f;
    float _131 = _129 / _130;
    float _132 = 1.0f - _131;
    float _133 = saturate(_132);
    bool _134 = (_125 <= 0.0f);
    float _135 = select(_134, _127, _133);
    float _136 = min(_135, _119);
    _138 = _92;
    _139 = _93;
    _140 = _94;
    _141 = _136;
  } else {
    _138 = _53;
    _139 = _54;
    _140 = _55;
    _141 = 0.0f;
  }
  float _142 = _141 * _138;
  float _143 = _141 * _139;
  float _144 = _141 * _140;
  float _145 = _141 * _52;
  float _148 = _142 * cb12_008w;
  float _149 = _143 * cb12_008w;
  float _150 = _144 * cb12_008w;
  SV_Target.x = _148;
  SV_Target.y = _149;
  SV_Target.z = _150;
  SV_Target.w = _145;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_142, _143, _144), _145);
  }
  return SV_Target;
}
