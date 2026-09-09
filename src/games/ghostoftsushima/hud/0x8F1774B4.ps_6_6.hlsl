#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t7 : register(t7);

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
  float cb12_005w : packoffset(c005.w);
  float cb12_006x : packoffset(c006.x);
  float cb12_008x : packoffset(c008.x);
  float cb12_008y : packoffset(c008.y);
  float cb12_008z : packoffset(c008.z);
  float cb12_008w : packoffset(c008.w);
  float cb12_009x : packoffset(c009.x);
  float cb12_009y : packoffset(c009.y);
  float cb12_009z : packoffset(c009.z);
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

SamplerState s2 : register(s2);

SamplerState s3 : register(s3);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _24 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _29 = TEXCOORD_2.x / TEXCOORD_2.w;
  float _30 = TEXCOORD_2.y / TEXCOORD_2.w;
  float _35 = dot(float3(_29, _30, 1.0f), float3(cb12_008x, cb12_008y, cb12_008z));
  float _40 = dot(float3(_29, _30, 1.0f), float3(cb12_009x, cb12_009y, cb12_009z));
  float4 _43 = t11.Sample(s2, float2(_35, _40));
  float _45 = min(1.0f, _43.x);
  float _46 = _24.x * TEXCOORD.x;
  float _47 = _24.y * TEXCOORD.y;
  float _48 = _24.z * TEXCOORD.z;
  float _49 = _24.w * TEXCOORD.w;
  float _50 = _49 * _45;
  float _51 = dot(float3(_46, _47, _48), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _54 = _51 - _46;
  float _55 = _51 - _47;
  float _56 = _51 - _48;
  float _57 = cbufGlobal_288 * _54;
  float _58 = cbufGlobal_288 * _55;
  float _59 = cbufGlobal_288 * _56;
  float _60 = _57 + _46;
  float _61 = _58 + _47;
  float _62 = _59 + _48;
  float _63 = _60 * _50;
  float _64 = _61 * _50;
  float _65 = _62 * _50;
  float _70 = cb12_005w - cb12_006x;
  float _71 = abs(_70);
  bool _72 = (_71 > 0.0f);
  float _94;
  float _139;
  float _140;
  float _141;
  float _142;
  if (_72) {
    float _76 = cb13_003z * TEXCOORD_1.x;
    float _77 = cb13_003z * TEXCOORD_1.y;
    float4 _80 = t7.SampleLevel(s3, float2(_76, _77), 0.0f);
    bool _84 = !(cb13_004y <= 0.0f);
    float _85 = max(cb12_005w, cb12_006x);
    if (_84) {
      float _87 = _85 - _80.x;
      float _90 = cb13_005y * _87;
      float _91 = 1.0f - _90;
      float _92 = saturate(_91);
      _94 = _92;
    } else {
      _94 = 0.0f;
    }
    float _96 = cb13_004z * _94;
    float _97 = _96 + 1.0f;
    float _98 = _97 * _63;
    float _99 = _97 * _64;
    float _100 = _97 * _65;
    float _103 = min(cb12_005w, cb12_006x);
    float _104 = _85 - _103;
    float _105 = 0.5f - _85;
    float _106 = abs(_105);
    float _107 = 0.5f - _106;
    float _108 = cb13_003w * 0.5f;
    float _109 = min(_108, _107);
    float _110 = min(_109, _104);
    bool _111 = (_85 < _80.x);
    float _112 = select(_111, 0.0f, 1.0f);
    float _113 = _80.x - _85;
    float _114 = _113 + _110;
    float _115 = _110 * 2.0f;
    float _116 = _114 / _115;
    float _117 = 1.0f - _116;
    float _118 = saturate(_117);
    bool _119 = (_110 <= 0.0f);
    float _120 = select(_119, _112, _118);
    float _121 = 0.5f - _103;
    float _122 = abs(_121);
    float _123 = 0.5f - _122;
    float _124 = cb13_004x * 0.5f;
    float _125 = min(_124, _123);
    float _126 = min(_125, _104);
    bool _127 = (_80.x < _103);
    float _128 = select(_127, 0.0f, 1.0f);
    float _129 = _103 - _80.x;
    float _130 = _129 + _126;
    float _131 = _126 * 2.0f;
    float _132 = _130 / _131;
    float _133 = 1.0f - _132;
    float _134 = saturate(_133);
    bool _135 = (_126 <= 0.0f);
    float _136 = select(_135, _128, _134);
    float _137 = min(_136, _120);
    _139 = _98;
    _140 = _99;
    _141 = _100;
    _142 = _137;
  } else {
    _139 = _63;
    _140 = _64;
    _141 = _65;
    _142 = 0.0f;
  }
  float _143 = _142 * _139;
  float _144 = _142 * _140;
  float _145 = _142 * _141;
  float _146 = _142 * _50;
  float _148 = _143 * cb12_008w;
  float _149 = _144 * cb12_008w;
  float _150 = _145 * cb12_008w;
  SV_Target.x = _148;
  SV_Target.y = _149;
  SV_Target.z = _150;
  SV_Target.w = _146;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_143, _144, _145), _146);
  }
  return SV_Target;
}
