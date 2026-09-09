#include "../ui.hlsli"

ByteAddressBuffer t1_space1 : register(t1, space1);

cbuffer cb14 : register(b14) {
  int RootSrtCbv_000 : packoffset(c000.x);
  int RootSrtCbv_004 : packoffset(c000.y);
};

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

SamplerState s0 : register(s0);

float4 main(
  linear float2 TEXCOORD : TEXCOORD,
  linear float4 COLOR : COLOR,
  nointerpolation float4 TEXCOORD_1 : TEXCOORD1,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  uint _19 = (uint)(RootSrtCbv_000) + 32u;
  uint _20 = (uint)(RootSrtCbv_000) + 64u;
  float4 _21 = asfloat(t1_space1.Load4(_20));
  uint _25 = (uint)(RootSrtCbv_000) + 80u;
  float4 _26 = asfloat(t1_space1.Load4(_25));
  int4 _28 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _31 = ResourceDescriptorHeap[(uint)(_28.x)];
  float4 _33 = _31.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  int4 _35 = asint(t1_space1.Load4(_19));
  Texture2D<float4> _38 = ResourceDescriptorHeap[(uint)(_35.x)];
  float4 _39 = _38.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  float _44 = ddx_coarse(TEXCOORD.x);
  float _45 = ddy_coarse(TEXCOORD.x);
  float _46 = _44 * _44;
  float _47 = _45 * _45;
  float _48 = _47 + _46;
  float _49 = sqrt(_48);
  float _50 = ddx_coarse(TEXCOORD.y);
  float _51 = ddy_coarse(TEXCOORD.y);
  float _52 = _50 * _50;
  float _53 = _51 * _51;
  float _54 = _53 + _52;
  float _55 = sqrt(_54);
  float _56 = _55 * _49;
  float _57 = sqrt(_56);
  float _58 = _57 * 0.5f;
  bool _59 = (TEXCOORD_1.z > 0.0f);
  float _60 = _58 / TEXCOORD_1.z;
  float _61 = select(_59, _60, 0.0f);
  float _62 = _61 + 0.5f;
  float _63 = saturate(_62);
  float _64 = 0.5f - _61;
  float _65 = saturate(_64);
  float _66 = _63 - _65;
  float _67 = _33.w - _65;
  float _68 = _67 / _66;
  float _69 = saturate(_68);
  float _70 = _69 * 2.0f;
  float _71 = 3.0f - _70;
  float _72 = _69 * _69;
  float _73 = _72 * _71;
  float _74 = 1.0f - _73;
  float _75 = _74 * TEXCOORD_1.y;
  float _76 = _75 + _73;
  float _77 = _76 * COLOR.w;
  bool _78 = !(_26.x >= 0.003921568859368563f);
  float _108;
  float _109;
  float _110;
  float _111;
  if (!_78) {
    float _81 = _26.x * -0.4000000059604645f;
    float _82 = _81 + 0.6000000238418579f;
    float _83 = saturate(_82);
    float _84 = _81 + 0.4000000059604645f;
    float _85 = saturate(_84);
    float _86 = _83 - _85;
    float _87 = _33.w - _85;
    float _88 = _87 / _86;
    float _89 = saturate(_88);
    float _90 = _89 * 2.0f;
    float _91 = 3.0f - _90;
    float _92 = _89 * _89;
    float _93 = _92 * _21.w;
    float _94 = _93 * _91;
    float _95 = COLOR.x - _21.x;
    float _96 = COLOR.y - _21.y;
    float _97 = COLOR.z - _21.z;
    float _98 = COLOR.w - _94;
    float _99 = _76 * _95;
    float _100 = _76 * _96;
    float _101 = _76 * _97;
    float _102 = _98 * _76;
    float _103 = _99 + _21.x;
    float _104 = _100 + _21.y;
    float _105 = _101 + _21.z;
    float _106 = _102 + _94;
    _108 = _103;
    _109 = _104;
    _110 = _105;
    _111 = _106;
  } else {
    _108 = COLOR.x;
    _109 = COLOR.y;
    _110 = COLOR.z;
    _111 = _77;
  }
  float _112 = _39.x * COLOR.x;
  float _113 = _39.y * COLOR.y;
  float _114 = _39.z * COLOR.z;
  float _115 = _39.w * COLOR.w;
  float _116 = _112 - _108;
  float _117 = _113 - _109;
  float _118 = _114 - _110;
  float _119 = _115 - _111;
  float _120 = _116 * TEXCOORD_1.x;
  float _121 = _117 * TEXCOORD_1.x;
  float _122 = _118 * TEXCOORD_1.x;
  float _123 = _119 * TEXCOORD_1.x;
  float _124 = _120 + _108;
  float _125 = _121 + _109;
  float _126 = _122 + _110;
  float _127 = _123 + _111;
  float _130 = cbufGlobal_264 * _124;
  float _131 = cbufGlobal_264 * _125;
  float _132 = _126 * cbufGlobal_264;
  SV_Target.x = _130;
  SV_Target.y = _131;
  SV_Target.z = _132;
  SV_Target.w = _127;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_124, _125, _126), 1.f);
  }
  return SV_Target;
}
