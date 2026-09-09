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
  linear float3 TEXCOORD : TEXCOORD,
  noperspective float3 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2,
  linear float4 TEXCOORD_6 : TEXCOORD6,
  nointerpolation int TEXCOORD_7 : TEXCOORD7,
  nointerpolation float2 TEXCOORD_8 : TEXCOORD8
) : SV_Target {
  float4 SV_Target = 0;
  SV_Target.x = 0.0f;
  SV_Target.y = 0.0f;
  SV_Target.z = 0.0f;
  SV_Target.w = 0.0f;
  int4 _24 = asint(t1_space1.Load4(RootSrtCbv_000));
  uint _26 = (uint)(_24.x) + 16u;
  int4 _27 = asint(t1_space1.Load4(_26));
  ByteAddressBuffer _30 = ResourceDescriptorHeap[(uint)(_27.x)];
  float4 _31 = asfloat(_30.Load4((TEXCOORD_7 * 116 + 0)));
  float4 _34 = asfloat(_30.Load4((TEXCOORD_7 * 116 + 8)));
  float4 _37 = asfloat(_30.Load4((TEXCOORD_7 * 116 + 28)));
  int4 _39 = asint(_30.Load4((TEXCOORD_7 * 116 + 48)));
  float4 _41 = asfloat(_30.Load4((TEXCOORD_7 * 116 + 72)));
  float _44 = TEXCOORD.x * 2.0f;
  float _45 = TEXCOORD.y * 2.0f;
  float _46 = _44 + -1.0f;
  float _47 = _45 + -1.0f;
  float _48 = _46 * _46;
  float _49 = _47 * _47;
  float _50 = _49 + _48;
  float _51 = sqrt(_50);
  float _52 = abs(_37.x);
  bool _53 = (_52 > 0.0010000000474974513f);
  float _73;
  float _74;
  if (_53) {
    float _55 = 1.0f - _37.x;
    float _56 = max(0.0f, _55);
    float _57 = abs(_55);
    float _58 = 1.0f - _57;
    float _59 = -0.0f - _55;
    float _60 = max(0.0f, _59);
    float _61 = _51 * _51;
    float _62 = _61 * _51;
    float _63 = dot(float3(_56, _58, _60), float3(_51, _61, _62));
    float _64 = _63 * _46;
    float _65 = _63 * _47;
    float _66 = _64 / _51;
    float _67 = _65 / _51;
    float _68 = _66 + 1.0f;
    float _69 = _67 + 1.0f;
    float _70 = _68 * 0.5f;
    float _71 = _69 * 0.5f;
    _73 = _70;
    _74 = _71;
  } else {
    _73 = TEXCOORD.x;
    _74 = TEXCOORD.y;
  }
  float _75 = _73 * TEXCOORD_6.z;
  float _76 = _74 * TEXCOORD_6.w;
  float _77 = _75 + TEXCOORD_6.x;
  float _78 = _76 + TEXCOORD_6.y;
  float _79 = _77 * _41.x;
  float _80 = _78 * _41.y;
  float _81 = _79 + TEXCOORD_8.x;
  float _82 = _80 + TEXCOORD_8.y;
  Texture2D<float4> _84 = ResourceDescriptorHeap[NonUniformResourceIndex((uint)(_39.x))];
  float4 _86 = _84.Sample(s0, float2(_81, _82));
  float _91 = _86.x * 0.07739938050508499f;
  float _92 = _86.y * 0.07739938050508499f;
  float _93 = _86.z * 0.07739938050508499f;
  float _94 = _86.x + 0.054999999701976776f;
  float _95 = _86.y + 0.054999999701976776f;
  float _96 = _86.z + 0.054999999701976776f;
  float _97 = _94 * 0.9478673338890076f;
  float _98 = _95 * 0.9478673338890076f;
  float _99 = _96 * 0.9478673338890076f;
  float _100 = log2(_97);
  float _101 = log2(_98);
  float _102 = log2(_99);
  float _103 = _100 * 2.4000000953674316f;
  float _104 = _101 * 2.4000000953674316f;
  float _105 = _102 * 2.4000000953674316f;
  float _106 = exp2(_103);
  float _107 = exp2(_104);
  float _108 = exp2(_105);
  bool _109 = (_86.x <= 0.0392800010740757f);
  float _110 = select(_109, _91, _106);
  bool _111 = (_86.y <= 0.0392800010740757f);
  float _112 = select(_111, _92, _107);
  bool _113 = (_86.z <= 0.0392800010740757f);
  float _114 = select(_113, _93, _108);
  float _115 = _110 * TEXCOORD_2.x;
  float _116 = _112 * TEXCOORD_2.y;
  float _117 = _114 * TEXCOORD_2.z;
  float _118 = dot(float3(_115, _116, _117), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _121 = _118 - _115;
  float _122 = _118 - _116;
  float _123 = _118 - _117;
  float _124 = cbufGlobal_288 * _121;
  float _125 = cbufGlobal_288 * _122;
  float _126 = cbufGlobal_288 * _123;
  float _127 = _124 + _115;
  float _128 = _125 + _116;
  float _129 = _126 + _117;
  float _130 = _51 * _31.y;
  float _131 = _130 + _31.x;
  float _132 = saturate(_131);
  float _133 = saturate(_132);
  float _134 = _133 * 2.0f;
  float _135 = 3.0f - _134;
  float _136 = _34.x * TEXCOORD_2.w;
  float _137 = _136 * _86.w;
  float _138 = _133 * _133;
  float _139 = _138 * _137;
  float _140 = _139 * _135;
  float _141 = _140 + _34.y;
  float _142 = saturate(_141);
  float _143 = _142 * TEXCOORD.z;
  float _144 = _142 - _143;
  float _145 = _127 * _142;
  float _146 = _128 * _142;
  float _147 = _129 * _142;
  float _150 = _145 * cbufGlobal_264;
  float _151 = _146 * cbufGlobal_264;
  float _152 = _147 * cbufGlobal_264;
  SV_Target.x = _150;
  SV_Target.y = _151;
  SV_Target.z = _152;
  SV_Target.w = _144;
  if (GhostIsUIOverrideActive()) {
    // RGB uses _142 as coverage; _144 separately controls destination attenuation.
    SV_Target.rgb = GhostRenderUI(float3(_145, _146, _147), _142, true);
  }
  return SV_Target;
}
