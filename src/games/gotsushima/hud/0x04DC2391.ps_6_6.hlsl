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
  float cb12_007w : packoffset(c007.w);
  float cb12_008w : packoffset(c008.w);
  float cb12_011x : packoffset(c011.x);
  float cb12_011y : packoffset(c011.y);
};

cbuffer cb13 : register(b13) {
  float cb13_003z : packoffset(c003.z);
  float cb13_003w : packoffset(c003.w);
  float cb13_004x : packoffset(c004.x);
  float cb13_004y : packoffset(c004.y);
  float cb13_004z : packoffset(c004.z);
  float cb13_005x : packoffset(c005.x);
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
  float _24 = ddx_coarse(TEXCOORD_1.x);
  float _25 = ddy_coarse(TEXCOORD_1.x);
  float _29 = cb12_011x * _24;
  float _30 = cb12_011y * _25;
  float _31 = _29 * _29;
  float _32 = _30 * _30;
  float _33 = _31 + _32;
  float _34 = sqrt(_33);
  float _37 = cb13_005x * 0.5f;
  float _38 = _37 * _34;
  float _41 = _37 + cb12_007w;
  float _42 = _41 * _34;
  float _43 = TEXCOORD_1.x + -0.5f;
  float _44 = TEXCOORD_1.y + -0.5f;
  float _45 = _43 * _43;
  float _46 = _44 * _44;
  float _47 = _46 + _45;
  float _48 = sqrt(_47);
  float _49 = _48 + -0.5f;
  float _50 = _49 + _42;
  float _51 = abs(_50);
  float _52 = _51 - _38;
  float _53 = max(0.0f, _52);
  float _54 = cb12_007w * _34;
  float _55 = _53 / _54;
  float _56 = saturate(_55);
  float _57 = 1.0f - _56;
  float _58 = _19.x * TEXCOORD.x;
  float _59 = _19.y * TEXCOORD.y;
  float _60 = _19.z * TEXCOORD.z;
  float _61 = _19.w * TEXCOORD.w;
  float _62 = dot(float3(_58, _59, _60), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _65 = _62 - _58;
  float _66 = _62 - _59;
  float _67 = _62 - _60;
  float _68 = cbufGlobal_288 * _65;
  float _69 = cbufGlobal_288 * _66;
  float _70 = cbufGlobal_288 * _67;
  float _71 = _68 + _58;
  float _72 = _69 + _59;
  float _73 = _70 + _60;
  float _74 = _57 * _61;
  float _75 = _74 * _71;
  float _76 = _74 * _72;
  float _77 = _74 * _73;
  float _82 = cb12_005w - cb12_006x;
  float _83 = abs(_82);
  bool _84 = (_83 > 0.0f);
  float _110;
  float _160;
  float _161;
  float _162;
  float _163;
  if (_84) {
    float _88 = cb13_003z * TEXCOORD_1.x;
    float _89 = cb13_003z * TEXCOORD_1.y;
    float4 _92 = t7.SampleLevel(s3, float2(_88, _89), 0.0f);
    bool _96 = !(cb13_004y <= 0.0f);
    if (_96) {
      float _102 = max(cb12_005w, cb12_006x);
      float _103 = _102 - _92.x;
      float _106 = cb13_005y * _103;
      float _107 = 1.0f - _106;
      float _108 = saturate(_107);
      _110 = _108;
    } else {
      _110 = 0.0f;
    }
    float _112 = cb13_004z * _110;
    float _113 = _112 + 1.0f;
    float _114 = _113 * _75;
    float _115 = _113 * _76;
    float _116 = _113 * _77;
    float _123 = min(cb12_005w, cb12_006x);
    float _124 = max(cb12_005w, cb12_006x);
    float _125 = _124 - _123;
    float _126 = 0.5f - _124;
    float _127 = abs(_126);
    float _128 = 0.5f - _127;
    float _129 = cb13_003w * 0.5f;
    float _130 = min(_129, _128);
    float _131 = min(_130, _125);
    bool _132 = (_124 < _92.x);
    float _133 = select(_132, 0.0f, 1.0f);
    float _134 = _92.x - _124;
    float _135 = _134 + _131;
    float _136 = _131 * 2.0f;
    float _137 = _135 / _136;
    float _138 = 1.0f - _137;
    float _139 = saturate(_138);
    bool _140 = (_131 <= 0.0f);
    float _141 = select(_140, _133, _139);
    float _142 = 0.5f - _123;
    float _143 = abs(_142);
    float _144 = 0.5f - _143;
    float _145 = cb13_004x * 0.5f;
    float _146 = min(_145, _144);
    float _147 = min(_146, _125);
    bool _148 = (_92.x < _123);
    float _149 = select(_148, 0.0f, 1.0f);
    float _150 = _123 - _92.x;
    float _151 = _150 + _147;
    float _152 = _147 * 2.0f;
    float _153 = _151 / _152;
    float _154 = 1.0f - _153;
    float _155 = saturate(_154);
    bool _156 = (_147 <= 0.0f);
    float _157 = select(_156, _149, _155);
    float _158 = min(_157, _141);
    _160 = _114;
    _161 = _115;
    _162 = _116;
    _163 = _158;
  } else {
    _160 = _75;
    _161 = _76;
    _162 = _77;
    _163 = 0.0f;
  }
  float _164 = _163 * _160;
  float _165 = _163 * _161;
  float _166 = _163 * _162;
  float _167 = _74 * _163;
  float _170 = _164 * cb12_008w;
  float _171 = _165 * cb12_008w;
  float _172 = _166 * cb12_008w;
  SV_Target.x = _170;
  SV_Target.y = _171;
  SV_Target.z = _172;
  SV_Target.w = _167;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_164, _165, _166), _167);
  }
  return SV_Target;
}
