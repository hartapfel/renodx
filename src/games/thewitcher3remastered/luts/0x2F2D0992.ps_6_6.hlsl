#include "../common.hlsli"

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

cbuffer cb3 : register(b3) {
  float4 CustomPixelConsts_000 : packoffset(c000.x);
  float4 CustomPixelConsts_016 : packoffset(c001.x);
  float4 CustomPixelConsts_032 : packoffset(c002.x);
  float4 CustomPixelConsts_048 : packoffset(c003.x);
  float4 CustomPixelConsts_064 : packoffset(c004.x);
  float4 CustomPixelConsts_080 : packoffset(c005.x);
  float4 CustomPixelConsts_096 : packoffset(c006.x);
  float4 CustomPixelConsts_112 : packoffset(c007.x);
  float4 CustomPixelConsts_128 : packoffset(c008.x);
  float4 CustomPixelConsts_144 : packoffset(c009.x);
  float4 CustomPixelConsts_160 : packoffset(c010.x);
  float4 CustomPixelConsts_176 : packoffset(c011.x);
  float4 CustomPixelConsts_192 : packoffset(c012.x);
  float4 CustomPixelConsts_208 : packoffset(c013.x);
  float4 CustomPixelConsts_224 : packoffset(c014.x);
  float4 CustomPixelConsts_240 : packoffset(c015.x);
  float4 CustomPixelConsts_256 : packoffset(c016.x);
  float4 CustomPixelConsts_272 : packoffset(c017.x);
  float4 CustomPixelConsts_288 : packoffset(c018.x);
  float4 CustomPixelConsts_304 : packoffset(c019.x);
  float4 CustomPixelConsts_320 : packoffset(c020.x);
  row_major float4x4 CustomPixelConsts_336 : packoffset(c021.x);
};

SamplerState s0 : register(s0);

SamplerState s1 : register(s1);

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target = 0;
  float _14 = max(TEXCOORD.x, CustomPixelConsts_000.x);
  float _15 = max(TEXCOORD.y, CustomPixelConsts_000.y);
  float _16 = min(_14, CustomPixelConsts_000.z);
  float _17 = min(_15, CustomPixelConsts_000.w);
  float4 _20 = t0.Sample(s0, float2(_16, _17));
  // RenoDX: preserve the native lookup/blend in bounded SDR proxy space.
  WitcherGradeState grade_state = (WitcherGradeState)0;
  if (WitcherUsePsychoV30()) {
    grade_state = WitcherPrepareGrade(_20.rgb);
    _20.rgb = grade_state.neutral_sdr;
  }
  float _25 = abs(_20.x);
  float _26 = abs(_20.y);
  float _27 = abs(_20.z);
  float _28 = log2(_25);
  float _29 = log2(_26);
  float _30 = log2(_27);
  float _31 = _28 * 0.4545454680919647f;
  float _32 = _29 * 0.4545454680919647f;
  float _33 = _30 * 0.4545454680919647f;
  float _34 = exp2(_31);
  float _35 = exp2(_32);
  float _36 = exp2(_33);
  float _37 = _36 * 0.99609375f;
  float _38 = _36 * 63.75f;
  float _39 = floor(_38);
  float _40 = _39 * 0.015625f;
  float _41 = _37 + 0.015625f;
  float _42 = _38 - _39;
  float _43 = saturate(_34);
  float _44 = saturate(_35);
  float _45 = saturate(_41);
  float _46 = min(0.9999899864196777f, _45);
  float _47 = _43 + 0.0078125f;
  float _48 = _44 + 0.0078125f;
  float _49 = _47 * 0.99609375f;
  float _50 = _48 * 0.99609375f;
  float _51 = max(_49, 0.015625f);
  float _52 = max(_50, 0.015625f);
  float _53 = min(_51, 0.984375f);
  float _54 = min(_52, 0.984375f);
  float _55 = _46 * 64.0f;
  float _56 = _46 * 8.0f;
  float _57 = floor(_56);
  float _58 = _57 * 8.0f;
  float _59 = _55 - _58;
  float _60 = floor(_59);
  float _61 = _60 + _53;
  float _62 = _61 * 0.125f;
  float _63 = _57 + _54;
  float _64 = _63 * 0.125f;
  float4 _67 = t1.SampleLevel(s1, float2(_62, _64), 0.0f);
  float _71 = saturate(_40);
  float _72 = min(0.9999899864196777f, _71);
  float _73 = _72 * 64.0f;
  float _74 = _72 * 8.0f;
  float _75 = floor(_74);
  float _76 = _75 * 8.0f;
  float _77 = _73 - _76;
  float _78 = floor(_77);
  float _79 = _78 + _53;
  float _80 = _79 * 0.125f;
  float _81 = _75 + _54;
  float _82 = _81 * 0.125f;
  float4 _83 = t1.SampleLevel(s1, float2(_80, _82), 0.0f);
  float _87 = _67.x - _83.x;
  float _88 = _67.y - _83.y;
  float _89 = _67.z - _83.z;
  float _90 = _87 * _42;
  float _91 = _88 * _42;
  float _92 = _89 * _42;
  float _93 = _90 + _83.x;
  float _94 = _91 + _83.y;
  float _95 = _92 + _83.z;
  float _96 = abs(_93);
  float _97 = abs(_94);
  float _98 = abs(_95);
  float _99 = log2(_96);
  float _100 = log2(_97);
  float _101 = log2(_98);
  float _102 = _99 * 2.200000047683716f;
  float _103 = _100 * 2.200000047683716f;
  float _104 = _101 * 2.200000047683716f;
  float _105 = exp2(_102);
  float _106 = exp2(_103);
  float _107 = exp2(_104);
  float _111 = CustomPixelConsts_016.z * _105;
  float _112 = CustomPixelConsts_016.z * _106;
  float _113 = CustomPixelConsts_016.z * _107;
  float _114 = _111 - _20.x;
  float _115 = _112 - _20.y;
  float _116 = _113 - _20.z;
  float _117 = _114 * CustomPixelConsts_016.y;
  float _118 = _115 * CustomPixelConsts_016.y;
  float _119 = _116 * CustomPixelConsts_016.y;
  float _120 = _117 + _20.x;
  float _121 = _118 + _20.y;
  float _122 = _119 + _20.z;
  SV_Target.x = _120;
  SV_Target.y = _121;
  SV_Target.z = _122;
  SV_Target.w = _20.w;
  if (WitcherUsePsychoV30()) {
    SV_Target.rgb = WitcherRestoreGrade(SV_Target.rgb, grade_state);
  }
  return SV_Target;
}
