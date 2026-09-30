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

SamplerState s1 : register(s1);

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float _15 = TEXCOORD.x - CustomPixelConsts_272.x;
  float _16 = TEXCOORD.y - CustomPixelConsts_272.y;
  float _17 = _15 / CustomPixelConsts_272.x;
  float _18 = _16 / CustomPixelConsts_272.y;
  float _19 = _17 * _17;
  float _20 = _18 * _18;
  float _21 = _20 + _19;
  float _22 = sqrt(_21);
  float _23 = _22 - CustomPixelConsts_256.y;
  float _24 = _23 * CustomPixelConsts_256.z;
  float _25 = saturate(_24);
  float4 _28 = t0.SampleLevel(s1, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
  uint width = 0, height = 0;
  const bool use_rcas = WitcherUsePsychoV30() && CUSTOM_SHARPENING_MODE != 0.f && CUSTOM_SHARPENING > 0.f;
  if (use_rcas) {
    t0.GetDimensions(width, height);
    _28.rgb = WitcherSampleFringe(t0, TEXCOORD, uint2(width, height));
  }
  bool _33 = (_25 > 0.0f);
  float _59;
  float _60;
  [branch]
  if (WitcherUsePsychoV30() && CUSTOM_CA_MODE != 0.f) {
    t0.GetDimensions(width, height);
    _28.rgb = WitcherApplyChromaticAberration(_28.rgb, t0, TEXCOORD, uint2(width, height));
    _59 = _28.x;
    _60 = _28.y;
  } else if (_33) {
    float _38 = 1.0f / _22;
    float _39 = max(_38, -3.4028234663852886e+38f);
    float _40 = min(_39, 3.4028234663852886e+38f);
    float _41 = _25 * _25;
    float _42 = _41 * CustomPixelConsts_256.x;
    float _43 = _42 * _40;
    float _44 = _17 * CustomPixelConsts_272.z;
    float _45 = _44 * _43;
    float _46 = _18 * CustomPixelConsts_272.w;
    float _47 = _46 * _43;
    float _48 = _45 * 2.0f;
    float _49 = _47 * 2.0f;
    float _50 = TEXCOORD.x - _48;
    float _51 = TEXCOORD.y - _49;
    float4 _52 = t0.SampleLevel(s1, float2(_50, _51), 0.0f);
    float _54 = TEXCOORD.x - _45;
    float _55 = TEXCOORD.y - _47;
    float4 _56 = t0.SampleLevel(s1, float2(_54, _55), 0.0f);
    if (use_rcas) {
      _52.rgb = WitcherSampleFringe(t0, float2(_50, _51), uint2(width, height));
      _56.rgb = WitcherSampleFringe(t0, float2(_54, _55), uint2(width, height));
    }
    _59 = _52.x;
    _60 = _56.y;
  } else {
    _59 = _28.x;
    _60 = _28.y;
  }
  // RenoDX: retain CA sampling, then grade a bounded proxy of the sampled HDR.
  WitcherGradeState grade_state = (WitcherGradeState)0;
  if (WitcherUsePsychoV30()) {
    grade_state = WitcherPrepareGrade(float3(_59, _60, _28.z));
    _59 = grade_state.neutral_sdr.x;
    _60 = grade_state.neutral_sdr.y;
    _28.z = grade_state.neutral_sdr.z;
  }
  float _63 = abs(_59);
  float _64 = abs(_60);
  float _65 = abs(_28.z);
  float _66 = log2(_63);
  float _67 = log2(_64);
  float _68 = log2(_65);
  float _69 = _66 * CustomPixelConsts_128.x;
  float _70 = _67 * CustomPixelConsts_128.x;
  float _71 = _68 * CustomPixelConsts_128.x;
  float _72 = exp2(_69);
  float _73 = exp2(_70);
  float _74 = exp2(_71);
  float _78 = CustomPixelConsts_224.x * _72;
  float _79 = CustomPixelConsts_224.x * _73;
  float _80 = CustomPixelConsts_224.x * _74;
  float _82 = _78 + CustomPixelConsts_224.y;
  float _83 = _79 + CustomPixelConsts_224.y;
  float _84 = _80 + CustomPixelConsts_224.y;
  float _85 = max(0.0f, _82);
  float _86 = max(0.0f, _83);
  float _87 = max(0.0f, _84);
  float _88 = log2(_85);
  float _89 = log2(_86);
  float _90 = log2(_87);
  float _91 = _88 * CustomPixelConsts_224.z;
  float _92 = _89 * CustomPixelConsts_224.z;
  float _93 = _90 * CustomPixelConsts_224.z;
  float _94 = exp2(_91);
  float _95 = exp2(_92);
  float _96 = exp2(_93);
  float _97 = dot(float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f), float3(_94, _95, _96));
  float _100 = _97 - CustomPixelConsts_160.x;
  float _102 = _100 * CustomPixelConsts_160.y;
  float _103 = saturate(_102);
  float _105 = _97 - CustomPixelConsts_160.z;
  float _107 = _105 * CustomPixelConsts_160.w;
  float _108 = saturate(_107);
  float _109 = max(0.0f, _94);
  float _110 = max(0.0f, _95);
  float _111 = max(0.0f, _96);
  float _112 = log2(_109);
  float _113 = log2(_110);
  float _114 = log2(_111);
  float _115 = _112 * 2.200000047683716f;
  float _116 = _113 * 2.200000047683716f;
  float _117 = _114 * 2.200000047683716f;
  float _118 = exp2(_115);
  float _119 = exp2(_116);
  float _120 = exp2(_117);
  float _121 = dot(float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f), float3(_118, _119, _120));
  float _132 = CustomPixelConsts_176.x - CustomPixelConsts_192.x;
  float _133 = CustomPixelConsts_176.y - CustomPixelConsts_192.y;
  float _134 = CustomPixelConsts_176.z - CustomPixelConsts_192.z;
  float _135 = CustomPixelConsts_176.w - CustomPixelConsts_192.w;
  float _136 = _132 * _103;
  float _137 = _133 * _103;
  float _138 = _134 * _103;
  float _139 = _135 * _103;
  float _140 = _136 + CustomPixelConsts_192.x;
  float _141 = _137 + CustomPixelConsts_192.y;
  float _142 = _138 + CustomPixelConsts_192.z;
  float _143 = _139 + CustomPixelConsts_192.w;
  float _149 = CustomPixelConsts_208.x - _140;
  float _150 = CustomPixelConsts_208.y - _141;
  float _151 = CustomPixelConsts_208.z - _142;
  float _152 = CustomPixelConsts_208.w - _143;
  float _153 = _149 * _108;
  float _154 = _150 * _108;
  float _155 = _151 * _108;
  float _156 = _152 * _108;
  float _157 = _153 + _140;
  float _158 = _154 + _141;
  float _159 = _155 + _142;
  float _160 = _156 + _143;
  float _161 = _118 - _121;
  float _162 = _119 - _121;
  float _163 = _120 - _121;
  float _164 = _160 * _161;
  float _165 = _160 * _162;
  float _166 = _160 * _163;
  float _167 = _164 + _121;
  float _168 = _165 + _121;
  float _169 = _166 + _121;
  float _170 = _167 * _157;
  float _171 = _168 * _158;
  float _172 = _169 * _159;
  float _173 = max(0.0f, _170);
  float _174 = max(0.0f, _171);
  float _175 = max(0.0f, _172);
  float _176 = log2(_173);
  float _177 = log2(_174);
  float _178 = log2(_175);
  float _179 = _176 * 0.4545454680919647f;
  float _180 = _177 * 0.4545454680919647f;
  float _181 = _178 * 0.4545454680919647f;
  float _182 = exp2(_179);
  float _183 = exp2(_180);
  float _184 = exp2(_181);
  float _189 = CustomPixelConsts_144.x * _182;
  float _190 = CustomPixelConsts_144.y * _183;
  float _191 = CustomPixelConsts_144.z * _184;
  float _192 = TEXCOORD_2.x + -0.5f;
  float _193 = TEXCOORD_2.y + -0.5f;
  float _194 = _192 * _192;
  float _195 = _193 * _193;
  float _196 = _195 + _194;
  float _197 = sqrt(_196);
  float _198 = _197 * 2.4390244483947754f;
  float _199 = _198 + -0.6707317233085632f;
  float _200 = saturate(_199);
  float _201 = _200 * _200;
  float _202 = _201 * _200;
  float _203 = _201 * _201;
  float _204 = dot(float4(-0.10000000149011612f, -0.10499999672174454f, 1.1200000047683716f, 0.09000000357627869f), float4(_203, _202, _201, _200));
  float _205 = min(_204, 0.9399999976158142f);
  float _211 = log2(_189);
  float _212 = log2(_190);
  float _213 = log2(_191);
  float _214 = _211 * 2.200000047683716f;
  float _215 = _212 * 2.200000047683716f;
  float _216 = _213 * 2.200000047683716f;
  float _217 = exp2(_214);
  float _218 = exp2(_215);
  float _219 = exp2(_216);
  float _220 = dot(float3(_217, _218, _219), float3(CustomPixelConsts_096.x, CustomPixelConsts_096.y, CustomPixelConsts_096.z));
  float _221 = 1.0f - _220;
  float _222 = saturate(_221);
  float _223 = CustomPixelConsts_096.w * _205;
  float _224 = _223 * _222;
  float _225 = saturate(_224);
  // Scale only the native vignette blend, preserving the surrounding grade.
  if (WitcherUsePsychoV30()) _225 *= CUSTOM_VIGNETTE_STRENGTH;
  // In zero-nit mode, replace the coloured blend with linear HDR darkening
  // after grade reconstruction. Retain the native mask and independent strength.
  float black_vignette = 0.f;
  if (WitcherUsePsychoV30() && CUSTOM_VIGNETTE_BLACK_FLOOR != 0.f && CUSTOM_VIGNETTE_STRENGTH > 0.f) {
    black_vignette = _225;
    _225 = 0.f;
  }
  float _230 = CustomPixelConsts_112.x - _189;
  float _231 = CustomPixelConsts_112.y - _190;
  float _232 = CustomPixelConsts_112.z - _191;
  float _233 = _230 * _225;
  float _234 = _231 * _225;
  float _235 = _232 * _225;
  float _236 = _233 + _189;
  float _237 = _234 + _190;
  float _238 = _235 + _191;
  float _242 = CustomPixelConsts_240.y - CustomPixelConsts_240.x;
  float _243 = _236 * _242;
  float _244 = _237 * _242;
  float _245 = _238 * _242;
  float _246 = _243 + CustomPixelConsts_240.x;
  float _247 = _244 + CustomPixelConsts_240.x;
  float _248 = _245 + CustomPixelConsts_240.x;
  SV_Target.x = _246;
  SV_Target.y = _247;
  SV_Target.z = _248;
  SV_Target.w = _28.w;
  if (WitcherUsePsychoV30()) {
    // The native initial power determines this pass's output transport.
    // Restore in linear space, then retain that same signed encoding.
    SV_Target.rgb = WitcherSignedPow(
        WitcherRestoreGrade(
            WitcherSignedPow(SV_Target.rgb, rcp(max(CustomPixelConsts_128.x, 1e-6f))),
            grade_state) * (1.f - black_vignette),
        CustomPixelConsts_128.x);
  }
  return SV_Target;
}
