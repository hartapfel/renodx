#include "../common.hlsli"
#include "../chromatic_aberration.hlsli"

Texture2D<float4> t0 : register(t0);

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

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target = 0;
  float4 _9 = t0.SampleLevel(s0, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
  if (WitcherUsePsychoV30() && (CUSTOM_CA_MODE != 0.f || (CUSTOM_SHARPENING_MODE != 0.f && CUSTOM_SHARPENING > 0.f))) {
    uint width, height;
    t0.GetDimensions(width, height);
    if (CUSTOM_SHARPENING_MODE != 0.f && CUSTOM_SHARPENING > 0.f) {
      _9.rgb = WitcherSampleFringe(t0, TEXCOORD, uint2(width, height));
    }
    _9.rgb = WitcherApplyChromaticAberration(_9.rgb, t0, TEXCOORD, uint2(width, height));
  }
  // RenoDX: preserve HDR through the native bounded color grade.
  WitcherGradeState grade_state = (WitcherGradeState)0;
  if (WitcherUsePsychoV30()) {
    grade_state = WitcherPrepareGrade(_9.rgb);
    _9.rgb = grade_state.neutral_sdr;
  }
  float _16 = abs(_9.x);
  float _17 = abs(_9.y);
  float _18 = abs(_9.z);
  float _19 = log2(_16);
  float _20 = log2(_17);
  float _21 = log2(_18);
  float _22 = _19 * CustomPixelConsts_128.x;
  float _23 = _20 * CustomPixelConsts_128.x;
  float _24 = _21 * CustomPixelConsts_128.x;
  float _25 = exp2(_22);
  float _26 = exp2(_23);
  float _27 = exp2(_24);
  float _31 = CustomPixelConsts_224.x * _25;
  float _32 = CustomPixelConsts_224.x * _26;
  float _33 = CustomPixelConsts_224.x * _27;
  float _35 = _31 + CustomPixelConsts_224.y;
  float _36 = _32 + CustomPixelConsts_224.y;
  float _37 = _33 + CustomPixelConsts_224.y;
  float _38 = max(0.0f, _35);
  float _39 = max(0.0f, _36);
  float _40 = max(0.0f, _37);
  float _41 = log2(_38);
  float _42 = log2(_39);
  float _43 = log2(_40);
  float _44 = _41 * CustomPixelConsts_224.z;
  float _45 = _42 * CustomPixelConsts_224.z;
  float _46 = _43 * CustomPixelConsts_224.z;
  float _47 = exp2(_44);
  float _48 = exp2(_45);
  float _49 = exp2(_46);
  float _50 = dot(float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f), float3(_47, _48, _49));
  float _53 = _50 - CustomPixelConsts_160.x;
  float _55 = _53 * CustomPixelConsts_160.y;
  float _56 = saturate(_55);
  float _58 = _50 - CustomPixelConsts_160.z;
  float _60 = _58 * CustomPixelConsts_160.w;
  float _61 = saturate(_60);
  float _62 = max(0.0f, _47);
  float _63 = max(0.0f, _48);
  float _64 = max(0.0f, _49);
  float _65 = log2(_62);
  float _66 = log2(_63);
  float _67 = log2(_64);
  float _68 = _65 * 2.200000047683716f;
  float _69 = _66 * 2.200000047683716f;
  float _70 = _67 * 2.200000047683716f;
  float _71 = exp2(_68);
  float _72 = exp2(_69);
  float _73 = exp2(_70);
  float _74 = dot(float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f), float3(_71, _72, _73));
  float _85 = CustomPixelConsts_176.x - CustomPixelConsts_192.x;
  float _86 = CustomPixelConsts_176.y - CustomPixelConsts_192.y;
  float _87 = CustomPixelConsts_176.z - CustomPixelConsts_192.z;
  float _88 = CustomPixelConsts_176.w - CustomPixelConsts_192.w;
  float _89 = _85 * _56;
  float _90 = _86 * _56;
  float _91 = _87 * _56;
  float _92 = _88 * _56;
  float _93 = _89 + CustomPixelConsts_192.x;
  float _94 = _90 + CustomPixelConsts_192.y;
  float _95 = _91 + CustomPixelConsts_192.z;
  float _96 = _92 + CustomPixelConsts_192.w;
  float _102 = CustomPixelConsts_208.x - _93;
  float _103 = CustomPixelConsts_208.y - _94;
  float _104 = CustomPixelConsts_208.z - _95;
  float _105 = CustomPixelConsts_208.w - _96;
  float _106 = _102 * _61;
  float _107 = _103 * _61;
  float _108 = _104 * _61;
  float _109 = _105 * _61;
  float _110 = _106 + _93;
  float _111 = _107 + _94;
  float _112 = _108 + _95;
  float _113 = _109 + _96;
  float _114 = _71 - _74;
  float _115 = _72 - _74;
  float _116 = _73 - _74;
  float _117 = _113 * _114;
  float _118 = _113 * _115;
  float _119 = _113 * _116;
  float _120 = _117 + _74;
  float _121 = _118 + _74;
  float _122 = _119 + _74;
  float _123 = _120 * _110;
  float _124 = _121 * _111;
  float _125 = _122 * _112;
  float _126 = max(0.0f, _123);
  float _127 = max(0.0f, _124);
  float _128 = max(0.0f, _125);
  float _129 = log2(_126);
  float _130 = log2(_127);
  float _131 = log2(_128);
  float _132 = _129 * 0.4545454680919647f;
  float _133 = _130 * 0.4545454680919647f;
  float _134 = _131 * 0.4545454680919647f;
  float _135 = exp2(_132);
  float _136 = exp2(_133);
  float _137 = exp2(_134);
  float _142 = CustomPixelConsts_144.x * _135;
  float _143 = CustomPixelConsts_144.y * _136;
  float _144 = CustomPixelConsts_144.z * _137;
  float _148 = CustomPixelConsts_240.y - CustomPixelConsts_240.x;
  float _149 = _142 * _148;
  float _150 = _143 * _148;
  float _151 = _144 * _148;
  float _152 = _149 + CustomPixelConsts_240.x;
  float _153 = _150 + CustomPixelConsts_240.x;
  float _154 = _151 + CustomPixelConsts_240.x;
  SV_Target.x = _152;
  SV_Target.y = _153;
  SV_Target.z = _154;
  SV_Target.w = _9.w;
  if (WitcherUsePsychoV30()) {
    // Preserve the native gamma-shaped transport after reconstructing HDR.
    SV_Target.rgb = WitcherSignedPow(
        WitcherRestoreGrade(
            WitcherSignedPow(SV_Target.rgb, rcp(max(CustomPixelConsts_128.x, 1e-6f))),
            grade_state),
        CustomPixelConsts_128.x);
  }
  return SV_Target;
}
