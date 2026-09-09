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
  float cb12_007w : packoffset(c007.w);
  float cb12_008w : packoffset(c008.w);
  float cb12_011x : packoffset(c011.x);
  float cb12_011y : packoffset(c011.y);
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
  float _74 = cb13_000x * _58;
  float _75 = mad(_59, cb13_001x, _74);
  float _76 = mad(_60, cb13_002x, _75);
  float _77 = cb13_000y * _58;
  float _78 = mad(_59, cb13_001y, _77);
  float _79 = mad(_60, cb13_002y, _78);
  float _80 = cb13_000z * _58;
  float _81 = mad(_59, cb13_001z, _80);
  float _82 = mad(_60, cb13_002z, _81);
  float _95 = cb12_000x * _76;
  float _96 = mad(_79, cb12_001x, _95);
  float _97 = mad(_82, cb12_002x, _96);
  float _98 = cb12_000y * _76;
  float _99 = mad(_79, cb12_001y, _98);
  float _100 = mad(_82, cb12_002y, _99);
  float _101 = cb12_000z * _76;
  float _102 = mad(_79, cb12_001z, _101);
  float _103 = mad(_82, cb12_002z, _102);
  float _104 = dot(float3(_97, _100, _103), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _107 = _104 - _97;
  float _108 = _104 - _100;
  float _109 = _104 - _103;
  float _110 = cbufGlobal_288 * _107;
  float _111 = cbufGlobal_288 * _108;
  float _112 = cbufGlobal_288 * _109;
  float _113 = _110 + _97;
  float _114 = _111 + _100;
  float _115 = _112 + _103;
  float _116 = _57 * _61;
  float _117 = _116 * _113;
  float _118 = _116 * _114;
  float _119 = _116 * _115;
  float _124 = cb12_005w - cb12_006x;
  float _125 = abs(_124);
  bool _126 = (_125 > 0.0f);
  float _152;
  float _202;
  float _203;
  float _204;
  float _205;
  if (_126) {
    float _130 = cb13_003z * TEXCOORD_1.x;
    float _131 = cb13_003z * TEXCOORD_1.y;
    float4 _134 = t7.SampleLevel(s3, float2(_130, _131), 0.0f);
    bool _138 = !(cb13_004y <= 0.0f);
    if (_138) {
      float _144 = max(cb12_005w, cb12_006x);
      float _145 = _144 - _134.x;
      float _148 = cb13_005y * _145;
      float _149 = 1.0f - _148;
      float _150 = saturate(_149);
      _152 = _150;
    } else {
      _152 = 0.0f;
    }
    float _154 = cb13_004z * _152;
    float _155 = _154 + 1.0f;
    float _156 = _155 * _117;
    float _157 = _155 * _118;
    float _158 = _155 * _119;
    float _165 = min(cb12_005w, cb12_006x);
    float _166 = max(cb12_005w, cb12_006x);
    float _167 = _166 - _165;
    float _168 = 0.5f - _166;
    float _169 = abs(_168);
    float _170 = 0.5f - _169;
    float _171 = cb13_003w * 0.5f;
    float _172 = min(_171, _170);
    float _173 = min(_172, _167);
    bool _174 = (_166 < _134.x);
    float _175 = select(_174, 0.0f, 1.0f);
    float _176 = _134.x - _166;
    float _177 = _176 + _173;
    float _178 = _173 * 2.0f;
    float _179 = _177 / _178;
    float _180 = 1.0f - _179;
    float _181 = saturate(_180);
    bool _182 = (_173 <= 0.0f);
    float _183 = select(_182, _175, _181);
    float _184 = 0.5f - _165;
    float _185 = abs(_184);
    float _186 = 0.5f - _185;
    float _187 = cb13_004x * 0.5f;
    float _188 = min(_187, _186);
    float _189 = min(_188, _167);
    bool _190 = (_134.x < _165);
    float _191 = select(_190, 0.0f, 1.0f);
    float _192 = _165 - _134.x;
    float _193 = _192 + _189;
    float _194 = _189 * 2.0f;
    float _195 = _193 / _194;
    float _196 = 1.0f - _195;
    float _197 = saturate(_196);
    bool _198 = (_189 <= 0.0f);
    float _199 = select(_198, _191, _197);
    float _200 = min(_199, _183);
    _202 = _156;
    _203 = _157;
    _204 = _158;
    _205 = _200;
  } else {
    _202 = _117;
    _203 = _118;
    _204 = _119;
    _205 = 0.0f;
  }
  float _206 = _205 * _202;
  float _207 = _205 * _203;
  float _208 = _205 * _204;
  float _209 = _116 * _205;
  float _212 = _206 * cb12_008w;
  float _213 = _207 * cb12_008w;
  float _214 = _208 * cb12_008w;
  SV_Target.x = _212;
  SV_Target.y = _213;
  SV_Target.z = _214;
  SV_Target.w = _209;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_206, _207, _208), _209);
  }
  return SV_Target;
}
