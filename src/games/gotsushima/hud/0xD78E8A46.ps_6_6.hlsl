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

SamplerState s2 : register(s2);

SamplerState s3 : register(s3);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_1 : TEXCOORD1,
  linear float2 TEXCOORD_3 : TEXCOORD3,
  linear float4 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _26 = t1.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _31 = TEXCOORD_2.x / TEXCOORD_2.w;
  float _32 = TEXCOORD_2.y / TEXCOORD_2.w;
  float _37 = dot(float3(_31, _32, 1.0f), float3(cb12_008x, cb12_008y, cb12_008z));
  float _42 = dot(float3(_31, _32, 1.0f), float3(cb12_009x, cb12_009y, cb12_009z));
  float4 _45 = t11.Sample(s2, float2(_37, _42));
  float _47 = min(1.0f, _45.x);
  float _48 = _26.x * TEXCOORD.x;
  float _49 = _26.y * TEXCOORD.y;
  float _50 = _26.z * TEXCOORD.z;
  float _51 = dot(float3(_48, _49, _50), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _54 = _51 - _48;
  float _55 = _51 - _49;
  float _56 = _51 - _50;
  float _57 = cbufGlobal_288 * _54;
  float _58 = cbufGlobal_288 * _55;
  float _59 = cbufGlobal_288 * _56;
  float _60 = _57 + _48;
  float _61 = _58 + _49;
  float _62 = _59 + _50;
  float _66 = dot(float2(TEXCOORD_3.x, TEXCOORD_3.y), float2(cb12_012x, cb12_012y));
  float _69 = _66 - cb12_012z;
  float _70 = cb12_012w - cb12_012z;
  float _71 = _69 / _70;
  float _72 = saturate(_71);
  float _73 = _26.w * TEXCOORD.w;
  float _74 = _73 * _47;
  float _75 = _74 * _72;
  float _76 = _75 * _60;
  float _77 = _75 * _61;
  float _78 = _75 * _62;
  float _83 = cb12_005w - cb12_006x;
  float _84 = abs(_83);
  bool _85 = (_84 > 0.0f);
  float _107;
  float _152;
  float _153;
  float _154;
  float _155;
  if (_85) {
    float _89 = cb13_003z * TEXCOORD_1.x;
    float _90 = cb13_003z * TEXCOORD_1.y;
    float4 _93 = t7.SampleLevel(s3, float2(_89, _90), 0.0f);
    bool _97 = !(cb13_004y <= 0.0f);
    float _98 = max(cb12_005w, cb12_006x);
    if (_97) {
      float _100 = _98 - _93.x;
      float _103 = cb13_005y * _100;
      float _104 = 1.0f - _103;
      float _105 = saturate(_104);
      _107 = _105;
    } else {
      _107 = 0.0f;
    }
    float _109 = cb13_004z * _107;
    float _110 = _109 + 1.0f;
    float _111 = _110 * _76;
    float _112 = _110 * _77;
    float _113 = _110 * _78;
    float _116 = min(cb12_005w, cb12_006x);
    float _117 = _98 - _116;
    float _118 = 0.5f - _98;
    float _119 = abs(_118);
    float _120 = 0.5f - _119;
    float _121 = cb13_003w * 0.5f;
    float _122 = min(_121, _120);
    float _123 = min(_122, _117);
    bool _124 = (_98 < _93.x);
    float _125 = select(_124, 0.0f, 1.0f);
    float _126 = _93.x - _98;
    float _127 = _126 + _123;
    float _128 = _123 * 2.0f;
    float _129 = _127 / _128;
    float _130 = 1.0f - _129;
    float _131 = saturate(_130);
    bool _132 = (_123 <= 0.0f);
    float _133 = select(_132, _125, _131);
    float _134 = 0.5f - _116;
    float _135 = abs(_134);
    float _136 = 0.5f - _135;
    float _137 = cb13_004x * 0.5f;
    float _138 = min(_137, _136);
    float _139 = min(_138, _117);
    bool _140 = (_93.x < _116);
    float _141 = select(_140, 0.0f, 1.0f);
    float _142 = _116 - _93.x;
    float _143 = _142 + _139;
    float _144 = _139 * 2.0f;
    float _145 = _143 / _144;
    float _146 = 1.0f - _145;
    float _147 = saturate(_146);
    bool _148 = (_139 <= 0.0f);
    float _149 = select(_148, _141, _147);
    float _150 = min(_149, _133);
    _152 = _111;
    _153 = _112;
    _154 = _113;
    _155 = _150;
  } else {
    _152 = _76;
    _153 = _77;
    _154 = _78;
    _155 = 0.0f;
  }
  float _156 = _155 * _152;
  float _157 = _155 * _153;
  float _158 = _155 * _154;
  float _159 = _155 * _75;
  float _161 = _156 * cb12_008w;
  float _162 = _157 * cb12_008w;
  float _163 = _158 * cb12_008w;
  SV_Target.x = _161;
  SV_Target.y = _162;
  SV_Target.z = _163;
  SV_Target.w = _159;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_156, _157, _158), _159);
  }
  return SV_Target;
}
