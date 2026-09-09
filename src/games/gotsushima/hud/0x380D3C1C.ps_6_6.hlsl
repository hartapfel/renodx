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
  float _104;
  float _149;
  float _150;
  float _151;
  float _152;
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
  float _56 = dot(float3(_52, _53, _54), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _59 = _56 - _52;
  float _60 = _56 - _53;
  float _61 = _56 - _54;
  float _62 = cbufGlobal_288 * _59;
  float _63 = cbufGlobal_288 * _60;
  float _64 = cbufGlobal_288 * _61;
  float _65 = _62 + _52;
  float _66 = _63 + _53;
  float _67 = _64 + _54;
  bool _70 = (_55 < cb13_003x);
  if (_70) {
    if (true) discard;
  }
  float _73 = _65 * _55;
  float _74 = _66 * _55;
  float _75 = _67 * _55;
  float _80 = cb12_005w - cb12_006x;
  float _81 = abs(_80);
  bool _82 = (_81 > 0.0f);
  if (_82) {
    float _86 = cb13_003z * TEXCOORD_1.x;
    float _87 = cb13_003z * TEXCOORD_1.y;
    float4 _90 = t7.SampleLevel(s3, float2(_86, _87), 0.0f);
    bool _94 = !(cb13_004y <= 0.0f);
    float _95 = max(cb12_005w, cb12_006x);
    if (_94) {
      float _97 = _95 - _90.x;
      float _100 = cb13_005y * _97;
      float _101 = 1.0f - _100;
      float _102 = saturate(_101);
      _104 = _102;
    } else {
      _104 = 0.0f;
    }
    float _106 = cb13_004z * _104;
    float _107 = _106 + 1.0f;
    float _108 = _107 * _73;
    float _109 = _107 * _74;
    float _110 = _107 * _75;
    float _113 = min(cb12_005w, cb12_006x);
    float _114 = _95 - _113;
    float _115 = 0.5f - _95;
    float _116 = abs(_115);
    float _117 = 0.5f - _116;
    float _118 = cb13_003w * 0.5f;
    float _119 = min(_118, _117);
    float _120 = min(_119, _114);
    bool _121 = (_95 < _90.x);
    float _122 = select(_121, 0.0f, 1.0f);
    float _123 = _90.x - _95;
    float _124 = _123 + _120;
    float _125 = _120 * 2.0f;
    float _126 = _124 / _125;
    float _127 = 1.0f - _126;
    float _128 = saturate(_127);
    bool _129 = (_120 <= 0.0f);
    float _130 = select(_129, _122, _128);
    float _131 = 0.5f - _113;
    float _132 = abs(_131);
    float _133 = 0.5f - _132;
    float _134 = cb13_004x * 0.5f;
    float _135 = min(_134, _133);
    float _136 = min(_135, _114);
    bool _137 = (_90.x < _113);
    float _138 = select(_137, 0.0f, 1.0f);
    float _139 = _113 - _90.x;
    float _140 = _139 + _136;
    float _141 = _136 * 2.0f;
    float _142 = _140 / _141;
    float _143 = 1.0f - _142;
    float _144 = saturate(_143);
    bool _145 = (_136 <= 0.0f);
    float _146 = select(_145, _138, _144);
    float _147 = min(_146, _130);
    _149 = _108;
    _150 = _109;
    _151 = _110;
    _152 = _147;
  } else {
    _149 = _73;
    _150 = _74;
    _151 = _75;
    _152 = 0.0f;
  }
  float _153 = _152 * _149;
  float _154 = _152 * _150;
  float _155 = _152 * _151;
  float _156 = _152 * _55;
  float _159 = _153 * cb12_008w;
  float _160 = _154 * cb12_008w;
  float _161 = _155 * cb12_008w;
  SV_Target.x = _159;
  SV_Target.y = _160;
  SV_Target.z = _161;
  SV_Target.w = _156;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_153, _154, _155), _156);
  }
  return SV_Target;
}
