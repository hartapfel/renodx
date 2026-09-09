#include "../ui.hlsli"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t7 : register(t7);

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
  float cb12_005w : packoffset(c005.w);
  float cb12_006x : packoffset(c006.x);
  float cb12_008w : packoffset(c008.w);
  float cb12_009w : packoffset(c009.w);
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
  float cb13_003x : packoffset(c003.x);
  float cb13_003z : packoffset(c003.z);
  float cb13_003w : packoffset(c003.w);
  float cb13_004x : packoffset(c004.x);
  float cb13_004y : packoffset(c004.y);
  float cb13_004z : packoffset(c004.z);
  float cb13_005y : packoffset(c005.y);
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
  float4 _23 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _28 = TEXCOORD_2.x / TEXCOORD_2.w;
  float _29 = TEXCOORD_2.y / TEXCOORD_2.w;
  float _33 = cbufGlobal_128.x * _28;
  float _34 = cbufGlobal_128.y * _29;
  float _37 = _33 + cbufGlobal_128.z;
  float _38 = _34 + cbufGlobal_128.w;
  float4 _43 = t10.Sample(s3, float2(_37, _38));
  bool _45 = (cb12_009w < _43.x);
  float _51;
  float _125;
  float _170;
  float _171;
  float _172;
  float _173;
  if (_45) {
    float _49 = cb13_005z * _23.w;
    _51 = _49;
  } else {
    _51 = _23.w;
  }
  float _52 = _23.x * TEXCOORD.x;
  float _53 = _23.y * TEXCOORD.y;
  float _54 = _23.z * TEXCOORD.z;
  float _55 = _51 * TEXCOORD.w;
  float _68 = cb13_000x * _52;
  float _69 = mad(_53, cb13_001x, _68);
  float _70 = mad(_54, cb13_002x, _69);
  float _71 = cb13_000y * _52;
  float _72 = mad(_53, cb13_001y, _71);
  float _73 = mad(_54, cb13_002y, _72);
  float _74 = cb13_000z * _52;
  float _75 = mad(_53, cb13_001z, _74);
  float _76 = mad(_54, cb13_002z, _75);
  float _77 = dot(float3(_70, _73, _76), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _80 = _77 - _70;
  float _81 = _77 - _73;
  float _82 = _77 - _76;
  float _83 = cbufGlobal_288 * _80;
  float _84 = cbufGlobal_288 * _81;
  float _85 = cbufGlobal_288 * _82;
  float _86 = _83 + _70;
  float _87 = _84 + _73;
  float _88 = _85 + _76;
  bool _91 = (_55 < cb13_003x);
  if (_91) {
    if (true) discard;
  }
  float _94 = _86 * _55;
  float _95 = _87 * _55;
  float _96 = _88 * _55;
  float _101 = cb12_005w - cb12_006x;
  float _102 = abs(_101);
  bool _103 = (_102 > 0.0f);
  if (_103) {
    float _107 = cb13_003z * TEXCOORD_1.x;
    float _108 = cb13_003z * TEXCOORD_1.y;
    float4 _111 = t7.SampleLevel(s3, float2(_107, _108), 0.0f);
    bool _115 = !(cb13_004y <= 0.0f);
    float _116 = max(cb12_005w, cb12_006x);
    if (_115) {
      float _118 = _116 - _111.x;
      float _121 = cb13_005y * _118;
      float _122 = 1.0f - _121;
      float _123 = saturate(_122);
      _125 = _123;
    } else {
      _125 = 0.0f;
    }
    float _127 = cb13_004z * _125;
    float _128 = _127 + 1.0f;
    float _129 = _128 * _94;
    float _130 = _128 * _95;
    float _131 = _128 * _96;
    float _134 = min(cb12_005w, cb12_006x);
    float _135 = _116 - _134;
    float _136 = 0.5f - _116;
    float _137 = abs(_136);
    float _138 = 0.5f - _137;
    float _139 = cb13_003w * 0.5f;
    float _140 = min(_139, _138);
    float _141 = min(_140, _135);
    bool _142 = (_116 < _111.x);
    float _143 = select(_142, 0.0f, 1.0f);
    float _144 = _111.x - _116;
    float _145 = _144 + _141;
    float _146 = _141 * 2.0f;
    float _147 = _145 / _146;
    float _148 = 1.0f - _147;
    float _149 = saturate(_148);
    bool _150 = (_141 <= 0.0f);
    float _151 = select(_150, _143, _149);
    float _152 = 0.5f - _134;
    float _153 = abs(_152);
    float _154 = 0.5f - _153;
    float _155 = cb13_004x * 0.5f;
    float _156 = min(_155, _154);
    float _157 = min(_156, _135);
    bool _158 = (_111.x < _134);
    float _159 = select(_158, 0.0f, 1.0f);
    float _160 = _134 - _111.x;
    float _161 = _160 + _157;
    float _162 = _157 * 2.0f;
    float _163 = _161 / _162;
    float _164 = 1.0f - _163;
    float _165 = saturate(_164);
    bool _166 = (_157 <= 0.0f);
    float _167 = select(_166, _159, _165);
    float _168 = min(_167, _151);
    _170 = _129;
    _171 = _130;
    _172 = _131;
    _173 = _168;
  } else {
    _170 = _94;
    _171 = _95;
    _172 = _96;
    _173 = 0.0f;
  }
  float _174 = _173 * _170;
  float _175 = _173 * _171;
  float _176 = _173 * _172;
  float _177 = _173 * _55;
  float _180 = _174 * cb12_008w;
  float _181 = _175 * cb12_008w;
  float _182 = _176 * cb12_008w;
  SV_Target.x = _180;
  SV_Target.y = _181;
  SV_Target.z = _182;
  SV_Target.w = _177;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_174, _175, _176), _177);
  }
  return SV_Target;
}
