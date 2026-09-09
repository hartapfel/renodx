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
  float cb12_000x : packoffset(c000.x);
  float cb12_000y : packoffset(c000.y);
  float cb12_000z : packoffset(c000.z);
  float cb12_001x : packoffset(c001.x);
  float cb12_001y : packoffset(c001.y);
  float cb12_001z : packoffset(c001.z);
  float cb12_002x : packoffset(c002.x);
  float cb12_002y : packoffset(c002.y);
  float cb12_002z : packoffset(c002.z);
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
  float _61 = cb12_000x * _42;
  float _62 = mad(_45, cb12_001x, _61);
  float _63 = mad(_48, cb12_002x, _62);
  float _64 = cb12_000y * _42;
  float _65 = mad(_45, cb12_001y, _64);
  float _66 = mad(_48, cb12_002y, _65);
  float _67 = cb12_000z * _42;
  float _68 = mad(_45, cb12_001z, _67);
  float _69 = mad(_48, cb12_002z, _68);
  float _70 = dot(float3(_63, _66, _69), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _73 = _70 - _63;
  float _74 = _70 - _66;
  float _75 = _70 - _69;
  float _76 = cbufGlobal_288 * _73;
  float _77 = cbufGlobal_288 * _74;
  float _78 = cbufGlobal_288 * _75;
  float _79 = _76 + _63;
  float _80 = _77 + _66;
  float _81 = _78 + _69;
  float _82 = _79 * _27;
  float _83 = _80 * _27;
  float _84 = _81 * _27;
  float _89 = cb12_005w - cb12_006x;
  float _90 = abs(_89);
  bool _91 = (_90 > 0.0f);
  float _117;
  float _167;
  float _168;
  float _169;
  float _170;
  if (_91) {
    float _95 = cb13_003z * TEXCOORD_1.x;
    float _96 = cb13_003z * TEXCOORD_1.y;
    float4 _99 = t7.SampleLevel(s3, float2(_95, _96), 0.0f);
    bool _103 = !(cb13_004y <= 0.0f);
    if (_103) {
      float _109 = max(cb12_005w, cb12_006x);
      float _110 = _109 - _99.x;
      float _113 = cb13_005y * _110;
      float _114 = 1.0f - _113;
      float _115 = saturate(_114);
      _117 = _115;
    } else {
      _117 = 0.0f;
    }
    float _119 = cb13_004z * _117;
    float _120 = _119 + 1.0f;
    float _121 = _120 * _82;
    float _122 = _120 * _83;
    float _123 = _120 * _84;
    float _130 = min(cb12_005w, cb12_006x);
    float _131 = max(cb12_005w, cb12_006x);
    float _132 = _131 - _130;
    float _133 = 0.5f - _131;
    float _134 = abs(_133);
    float _135 = 0.5f - _134;
    float _136 = cb13_003w * 0.5f;
    float _137 = min(_136, _135);
    float _138 = min(_137, _132);
    bool _139 = (_131 < _99.x);
    float _140 = select(_139, 0.0f, 1.0f);
    float _141 = _99.x - _131;
    float _142 = _141 + _138;
    float _143 = _138 * 2.0f;
    float _144 = _142 / _143;
    float _145 = 1.0f - _144;
    float _146 = saturate(_145);
    bool _147 = (_138 <= 0.0f);
    float _148 = select(_147, _140, _146);
    float _149 = 0.5f - _130;
    float _150 = abs(_149);
    float _151 = 0.5f - _150;
    float _152 = cb13_004x * 0.5f;
    float _153 = min(_152, _151);
    float _154 = min(_153, _132);
    bool _155 = (_99.x < _130);
    float _156 = select(_155, 0.0f, 1.0f);
    float _157 = _130 - _99.x;
    float _158 = _157 + _154;
    float _159 = _154 * 2.0f;
    float _160 = _158 / _159;
    float _161 = 1.0f - _160;
    float _162 = saturate(_161);
    bool _163 = (_154 <= 0.0f);
    float _164 = select(_163, _156, _162);
    float _165 = min(_164, _148);
    _167 = _121;
    _168 = _122;
    _169 = _123;
    _170 = _165;
  } else {
    _167 = _82;
    _168 = _83;
    _169 = _84;
    _170 = 0.0f;
  }
  float _171 = _170 * _167;
  float _172 = _170 * _168;
  float _173 = _170 * _169;
  float _174 = _170 * _27;
  float _177 = _171 * cb12_008w;
  float _178 = _172 * cb12_008w;
  float _179 = _173 * cb12_008w;
  SV_Target.x = _177;
  SV_Target.y = _178;
  SV_Target.z = _179;
  SV_Target.w = _174;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_171, _172, _173), _174);
  }
  return SV_Target;
}
