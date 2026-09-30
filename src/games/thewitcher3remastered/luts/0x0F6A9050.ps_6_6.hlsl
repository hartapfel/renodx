#include "../lutsampling.hlsli"

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t3 : register(t3);

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

SamplerState s3 : register(s3);

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target = 0;
  float _16 = max(TEXCOORD.x, CustomPixelConsts_000.x);
  float _17 = max(TEXCOORD.y, CustomPixelConsts_000.y);
  float _18 = min(_16, CustomPixelConsts_000.z);
  float _19 = min(_17, CustomPixelConsts_000.w);
  float4 _22 = t0.Sample(s0, float2(_18, _19));
  // RenoDX: retain native LUT addressing, gains and environment blending.
  if (WitcherUsePsychoV30()) {
    if (CUSTOM_LUT_STRENGTH == 0.f) return _22;
    WitcherGradeState state = WitcherPrepareGrade(_22.rgb);
    float3 grade1 = lerp(state.neutral_sdr,
        WitcherSampleLUT(state.neutral_sdr, t1, s1) * CustomPixelConsts_016.z,
        CustomPixelConsts_016.y);
    float3 grade2 = lerp(state.neutral_sdr,
        WitcherSampleLUT(state.neutral_sdr, t3, s3) * CustomPixelConsts_032.z,
        CustomPixelConsts_032.y);
    float3 graded = lerp(grade1, grade2, CustomPixelConsts_032.w);
    return float4(WitcherRestoreGrade(
        lerp(state.neutral_sdr, graded, CUSTOM_LUT_STRENGTH), state), _22.w);
  }
  float _27 = abs(_22.x);
  float _28 = abs(_22.y);
  float _29 = abs(_22.z);
  float _30 = log2(_27);
  float _31 = log2(_28);
  float _32 = log2(_29);
  float _33 = _30 * 0.4545454680919647f;
  float _34 = _31 * 0.4545454680919647f;
  float _35 = _32 * 0.4545454680919647f;
  float _36 = exp2(_33);
  float _37 = exp2(_34);
  float _38 = exp2(_35);
  float _39 = _38 * 0.99609375f;
  float _40 = _38 * 63.75f;
  float _41 = floor(_40);
  float _42 = _41 * 0.015625f;
  float _43 = _39 + 0.015625f;
  float _44 = _40 - _41;
  float _45 = saturate(_36);
  float _46 = saturate(_37);
  float _47 = saturate(_43);
  float _48 = min(0.9999899864196777f, _47);
  float _49 = _45 + 0.0078125f;
  float _50 = _46 + 0.0078125f;
  float _51 = _49 * 0.99609375f;
  float _52 = _50 * 0.99609375f;
  float _53 = max(_51, 0.015625f);
  float _54 = max(_52, 0.015625f);
  float _55 = min(_53, 0.984375f);
  float _56 = min(_54, 0.984375f);
  float _57 = _48 * 64.0f;
  float _58 = _48 * 8.0f;
  float _59 = floor(_58);
  float _60 = _59 * 8.0f;
  float _61 = _57 - _60;
  float _62 = floor(_61);
  float _63 = _62 + _55;
  float _64 = _63 * 0.125f;
  float _65 = _59 + _56;
  float _66 = _65 * 0.125f;
  float4 _69 = t1.SampleLevel(s1, float2(_64, _66), 0.0f);
  float _73 = saturate(_42);
  float _74 = min(0.9999899864196777f, _73);
  float _75 = _74 * 64.0f;
  float _76 = _74 * 8.0f;
  float _77 = floor(_76);
  float _78 = _77 * 8.0f;
  float _79 = _75 - _78;
  float _80 = floor(_79);
  float _81 = _80 + _55;
  float _82 = _81 * 0.125f;
  float _83 = _77 + _56;
  float _84 = _83 * 0.125f;
  float4 _85 = t1.SampleLevel(s1, float2(_82, _84), 0.0f);
  float _89 = _69.x - _85.x;
  float _90 = _69.y - _85.y;
  float _91 = _69.z - _85.z;
  float _92 = _89 * _44;
  float _93 = _90 * _44;
  float _94 = _91 * _44;
  float _95 = _92 + _85.x;
  float _96 = _93 + _85.y;
  float _97 = _94 + _85.z;
  float _98 = abs(_95);
  float _99 = abs(_96);
  float _100 = abs(_97);
  float _101 = log2(_98);
  float _102 = log2(_99);
  float _103 = log2(_100);
  float _104 = _101 * 2.200000047683716f;
  float _105 = _102 * 2.200000047683716f;
  float _106 = _103 * 2.200000047683716f;
  float _107 = exp2(_104);
  float _108 = exp2(_105);
  float _109 = exp2(_106);
  float _113 = CustomPixelConsts_016.z * _107;
  float _114 = CustomPixelConsts_016.z * _108;
  float _115 = CustomPixelConsts_016.z * _109;
  float _116 = _113 - _22.x;
  float _117 = _114 - _22.y;
  float _118 = _115 - _22.z;
  float _119 = _116 * CustomPixelConsts_016.y;
  float _120 = _117 * CustomPixelConsts_016.y;
  float _121 = _118 * CustomPixelConsts_016.y;
  float _122 = _119 + _22.x;
  float _123 = _120 + _22.y;
  float _124 = _121 + _22.z;
  float4 _129 = t3.SampleLevel(s3, float2(_64, _66), 0.0f);
  float4 _133 = t3.SampleLevel(s3, float2(_82, _84), 0.0f);
  float _137 = _129.x - _133.x;
  float _138 = _129.y - _133.y;
  float _139 = _129.z - _133.z;
  float _140 = _137 * _44;
  float _141 = _138 * _44;
  float _142 = _139 * _44;
  float _143 = _140 + _133.x;
  float _144 = _141 + _133.y;
  float _145 = _142 + _133.z;
  float _146 = abs(_143);
  float _147 = abs(_144);
  float _148 = abs(_145);
  float _149 = log2(_146);
  float _150 = log2(_147);
  float _151 = log2(_148);
  float _152 = _149 * 2.200000047683716f;
  float _153 = _150 * 2.200000047683716f;
  float _154 = _151 * 2.200000047683716f;
  float _155 = exp2(_152);
  float _156 = exp2(_153);
  float _157 = exp2(_154);
  float _160 = _155 * CustomPixelConsts_032.z;
  float _161 = _156 * CustomPixelConsts_032.z;
  float _162 = _157 * CustomPixelConsts_032.z;
  float _163 = _160 - _22.x;
  float _164 = _161 - _22.y;
  float _165 = _162 - _22.z;
  float _166 = _163 * CustomPixelConsts_032.y;
  float _167 = _164 * CustomPixelConsts_032.y;
  float _168 = _165 * CustomPixelConsts_032.y;
  float _169 = _166 - _119;
  float _170 = _167 - _120;
  float _171 = _168 - _121;
  float _172 = _169 * CustomPixelConsts_032.w;
  float _173 = _170 * CustomPixelConsts_032.w;
  float _174 = _171 * CustomPixelConsts_032.w;
  float _175 = _122 + _172;
  float _176 = _123 + _173;
  float _177 = _124 + _174;
  SV_Target.x = _175;
  SV_Target.y = _176;
  SV_Target.z = _177;
  SV_Target.w = _22.w;
  return SV_Target;
}
