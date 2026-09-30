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

#include "../postgrade.hlsli"

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD,
  linear float2 TEXCOORD_2 : TEXCOORD2
) : SV_Target {
  float4 SV_Target = 0;
  float4 _11 = t0.SampleLevel(s0, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
  if (WitcherUsePsychoV30() && (CUSTOM_CA_MODE != 0.f || (CUSTOM_SHARPENING_MODE != 0.f && CUSTOM_SHARPENING > 0.f))) {
    uint width, height;
    t0.GetDimensions(width, height);
    if (CUSTOM_SHARPENING_MODE != 0.f && CUSTOM_SHARPENING > 0.f) {
      _11.rgb = WitcherSampleFringe(t0, TEXCOORD, uint2(width, height));
    }
    _11.rgb = WitcherApplyChromaticAberration(_11.rgb, t0, TEXCOORD, uint2(width, height));
  }
  // RenoDX: preserve HDR through the native bounded color grade.
  if (WitcherUsePsychoV30()) {
    return float4(WitcherApplyPostGrade(_11.rgb, WitcherRadialVignette(TEXCOORD_2)), _11.w);
  }
  float _18 = abs(_11.x);
  float _19 = abs(_11.y);
  float _20 = abs(_11.z);
  float _21 = log2(_18);
  float _22 = log2(_19);
  float _23 = log2(_20);
  float _24 = _21 * CustomPixelConsts_128.x;
  float _25 = _22 * CustomPixelConsts_128.x;
  float _26 = _23 * CustomPixelConsts_128.x;
  float _27 = exp2(_24);
  float _28 = exp2(_25);
  float _29 = exp2(_26);
  float _33 = CustomPixelConsts_224.x * _27;
  float _34 = CustomPixelConsts_224.x * _28;
  float _35 = CustomPixelConsts_224.x * _29;
  float _37 = _33 + CustomPixelConsts_224.y;
  float _38 = _34 + CustomPixelConsts_224.y;
  float _39 = _35 + CustomPixelConsts_224.y;
  float _40 = max(0.0f, _37);
  float _41 = max(0.0f, _38);
  float _42 = max(0.0f, _39);
  float _43 = log2(_40);
  float _44 = log2(_41);
  float _45 = log2(_42);
  float _46 = _43 * CustomPixelConsts_224.z;
  float _47 = _44 * CustomPixelConsts_224.z;
  float _48 = _45 * CustomPixelConsts_224.z;
  float _49 = exp2(_46);
  float _50 = exp2(_47);
  float _51 = exp2(_48);
  float _52 = dot(float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f), float3(_49, _50, _51));
  float _55 = _52 - CustomPixelConsts_160.x;
  float _57 = _55 * CustomPixelConsts_160.y;
  float _58 = saturate(_57);
  float _60 = _52 - CustomPixelConsts_160.z;
  float _62 = _60 * CustomPixelConsts_160.w;
  float _63 = saturate(_62);
  float _64 = max(0.0f, _49);
  float _65 = max(0.0f, _50);
  float _66 = max(0.0f, _51);
  float _67 = log2(_64);
  float _68 = log2(_65);
  float _69 = log2(_66);
  float _70 = _67 * 2.200000047683716f;
  float _71 = _68 * 2.200000047683716f;
  float _72 = _69 * 2.200000047683716f;
  float _73 = exp2(_70);
  float _74 = exp2(_71);
  float _75 = exp2(_72);
  float _76 = dot(float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f), float3(_73, _74, _75));
  float _87 = CustomPixelConsts_176.x - CustomPixelConsts_192.x;
  float _88 = CustomPixelConsts_176.y - CustomPixelConsts_192.y;
  float _89 = CustomPixelConsts_176.z - CustomPixelConsts_192.z;
  float _90 = CustomPixelConsts_176.w - CustomPixelConsts_192.w;
  float _91 = _87 * _58;
  float _92 = _88 * _58;
  float _93 = _89 * _58;
  float _94 = _90 * _58;
  float _95 = _91 + CustomPixelConsts_192.x;
  float _96 = _92 + CustomPixelConsts_192.y;
  float _97 = _93 + CustomPixelConsts_192.z;
  float _98 = _94 + CustomPixelConsts_192.w;
  float _104 = CustomPixelConsts_208.x - _95;
  float _105 = CustomPixelConsts_208.y - _96;
  float _106 = CustomPixelConsts_208.z - _97;
  float _107 = CustomPixelConsts_208.w - _98;
  float _108 = _104 * _63;
  float _109 = _105 * _63;
  float _110 = _106 * _63;
  float _111 = _107 * _63;
  float _112 = _108 + _95;
  float _113 = _109 + _96;
  float _114 = _110 + _97;
  float _115 = _111 + _98;
  float _116 = _73 - _76;
  float _117 = _74 - _76;
  float _118 = _75 - _76;
  float _119 = _115 * _116;
  float _120 = _115 * _117;
  float _121 = _115 * _118;
  float _122 = _119 + _76;
  float _123 = _120 + _76;
  float _124 = _121 + _76;
  float _125 = _122 * _112;
  float _126 = _123 * _113;
  float _127 = _124 * _114;
  float _128 = max(0.0f, _125);
  float _129 = max(0.0f, _126);
  float _130 = max(0.0f, _127);
  float _131 = log2(_128);
  float _132 = log2(_129);
  float _133 = log2(_130);
  float _134 = _131 * 0.4545454680919647f;
  float _135 = _132 * 0.4545454680919647f;
  float _136 = _133 * 0.4545454680919647f;
  float _137 = exp2(_134);
  float _138 = exp2(_135);
  float _139 = exp2(_136);
  float _144 = CustomPixelConsts_144.x * _137;
  float _145 = CustomPixelConsts_144.y * _138;
  float _146 = CustomPixelConsts_144.z * _139;
  float _147 = TEXCOORD_2.x + -0.5f;
  float _148 = TEXCOORD_2.y + -0.5f;
  float _149 = _147 * _147;
  float _150 = _148 * _148;
  float _151 = _150 + _149;
  float _152 = sqrt(_151);
  float _153 = _152 * 2.4390244483947754f;
  float _154 = _153 + -0.6707317233085632f;
  float _155 = saturate(_154);
  float _156 = _155 * _155;
  float _157 = _156 * _155;
  float _158 = _156 * _156;
  float _159 = dot(float4(-0.10000000149011612f, -0.10499999672174454f, 1.1200000047683716f, 0.09000000357627869f), float4(_158, _157, _156, _155));
  float _160 = min(_159, 0.9399999976158142f);
  float _166 = log2(_144);
  float _167 = log2(_145);
  float _168 = log2(_146);
  float _169 = _166 * 2.200000047683716f;
  float _170 = _167 * 2.200000047683716f;
  float _171 = _168 * 2.200000047683716f;
  float _172 = exp2(_169);
  float _173 = exp2(_170);
  float _174 = exp2(_171);
  float _175 = dot(float3(_172, _173, _174), float3(CustomPixelConsts_096.x, CustomPixelConsts_096.y, CustomPixelConsts_096.z));
  float _176 = 1.0f - _175;
  float _177 = saturate(_176);
  float _178 = CustomPixelConsts_096.w * _160;
  float _179 = _178 * _177;
  float _180 = saturate(_179);
  float _185 = CustomPixelConsts_112.x - _144;
  float _186 = CustomPixelConsts_112.y - _145;
  float _187 = CustomPixelConsts_112.z - _146;
  float _188 = _185 * _180;
  float _189 = _186 * _180;
  float _190 = _187 * _180;
  float _191 = _188 + _144;
  float _192 = _189 + _145;
  float _193 = _190 + _146;
  float _197 = CustomPixelConsts_240.y - CustomPixelConsts_240.x;
  float _198 = _191 * _197;
  float _199 = _192 * _197;
  float _200 = _193 * _197;
  float _201 = _198 + CustomPixelConsts_240.x;
  float _202 = _199 + CustomPixelConsts_240.x;
  float _203 = _200 + CustomPixelConsts_240.x;
  SV_Target.x = _201;
  SV_Target.y = _202;
  SV_Target.z = _203;
  SV_Target.w = _11.w;
  return SV_Target;
}
