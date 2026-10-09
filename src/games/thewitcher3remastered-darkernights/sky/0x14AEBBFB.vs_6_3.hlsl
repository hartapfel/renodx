/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include "celestial.hlsli"

struct ShaderCommonEnvProbeParams {
  float ShaderCommonEnvProbeParams_000;
  float3 ShaderCommonEnvProbeParams_004;
  float3 ShaderCommonEnvProbeParams_016;
  row_major float4x4 ShaderCommonEnvProbeParams_028;
  float4 ShaderCommonEnvProbeParams_092;
  row_major float4x4 ShaderCommonEnvProbeParams_108;
  int ShaderCommonEnvProbeParams_172;
};

struct ShaderCullingEnvProbeParams {
  row_major float4x3 ShaderCullingEnvProbeParams_000;
  float3 ShaderCullingEnvProbeParams_048;
  int ShaderCullingEnvProbeParams_060;
};

struct ShaderWorldTear {
  float4 ShaderWorldTear_000;
  float4 ShaderWorldTear_016;
  float ShaderWorldTear_032;
  float ShaderWorldTear_036;
  float ShaderWorldTear_040;
  float ShaderWorldTear_044;
};

struct ShaderWorldTearArray {
  int ShaderWorldTearArray_000;
  float ShaderWorldTearArray_004;
  float ShaderWorldTearArray_008;
  float ShaderWorldTearArray_012;
  ShaderWorldTear ShaderWorldTearArray_016[10];
};

struct ShaderWorldTearConstants {
  int4 ShaderWorldTearConstants_000[16];
};


cbuffer cb1 : register(b1) {
  float cb1_036x : packoffset(c036.x);
  float cb1_036y : packoffset(c036.y);
  float cb1_036z : packoffset(c036.z);
  float cb1_045x : packoffset(c045.x);
  float cb1_045y : packoffset(c045.y);
  float cb1_045z : packoffset(c045.z);
  float cb1_045w : packoffset(c045.w);
  float cb1_046x : packoffset(c046.x);
  float cb1_046y : packoffset(c046.y);
  float cb1_046z : packoffset(c046.z);
  float cb1_046w : packoffset(c046.w);
  float cb1_047x : packoffset(c047.x);
  float cb1_047y : packoffset(c047.y);
  float cb1_047z : packoffset(c047.z);
  float cb1_047w : packoffset(c047.w);
  float cb1_048x : packoffset(c048.x);
  float cb1_048y : packoffset(c048.y);
  float cb1_048z : packoffset(c048.z);
  float cb1_048w : packoffset(c048.w);
  uint cb1_padding : packoffset(c53.w);
};

cbuffer cb2 : register(b2) {
  row_major float4x4 FrequentVertexConsts_000 : packoffset(c000.x);
  row_major float4x4 FrequentVertexConsts_064 : packoffset(c004.x);
  float4 FrequentVertexConsts_128 : packoffset(c008.x);
  float4 FrequentVertexConsts_144 : packoffset(c009.x);
  float4 FrequentVertexConsts_160 : packoffset(c010.x);
  float4 FrequentVertexConsts_176 : packoffset(c011.x);
  float4 FrequentVertexConsts_192 : packoffset(c012.x);
};

cbuffer cb12 : register(b12) {
  uint moon_size_bits : packoffset(c037.w);
  float cb12_000x : packoffset(c000.x);
  float cb12_000y : packoffset(c000.y);
  float cb12_000z : packoffset(c000.z);
  float cb12_022z : packoffset(c022.z);
  float cb12_038x : packoffset(c038.x);
  float cb12_038y : packoffset(c038.y);
  float cb12_038z : packoffset(c038.z);
  float cb12_039x : packoffset(c039.x);
  float cb12_039y : packoffset(c039.y);
  float cb12_039z : packoffset(c039.z);
  float cb12_040x : packoffset(c040.x);
  float cb12_040y : packoffset(c040.y);
  float cb12_040z : packoffset(c040.z);
  float cb12_041x : packoffset(c041.x);
  float cb12_041y : packoffset(c041.y);
  float cb12_041z : packoffset(c041.z);
  float cb12_042x : packoffset(c042.x);
  float cb12_042y : packoffset(c042.y);
  float cb12_042z : packoffset(c042.z);
  float cb12_042w : packoffset(c042.w);
  float cb12_043x : packoffset(c043.x);
  float cb12_043y : packoffset(c043.y);
  float cb12_043z : packoffset(c043.z);
  float cb12_045x : packoffset(c045.x);
  float cb12_045y : packoffset(c045.y);
  float cb12_045z : packoffset(c045.z);
  float cb12_046x : packoffset(c046.x);
  float cb12_046y : packoffset(c046.y);
  float cb12_046z : packoffset(c046.z);
  float cb12_047x : packoffset(c047.x);
  float cb12_047y : packoffset(c047.y);
  float cb12_047z : packoffset(c047.z);
  float cb12_048x : packoffset(c048.x);
  float cb12_048y : packoffset(c048.y);
  float cb12_048z : packoffset(c048.z);
  float cb12_189x : packoffset(c189.x);
  float cb12_189y : packoffset(c189.y);
  float cb12_189z : packoffset(c189.z);
  float cb12_189w : packoffset(c189.w);
  float cb12_190x : packoffset(c190.x);
  float cb12_190y : packoffset(c190.y);
  float cb12_190z : packoffset(c190.z);
  float cb12_190w : packoffset(c190.w);
  float cb12_191x : packoffset(c191.x);
  float cb12_191y : packoffset(c191.y);
  float cb12_191z : packoffset(c191.z);
  float cb12_191w : packoffset(c191.w);
  float cb12_192x : packoffset(c192.x);
  float cb12_192y : packoffset(c192.y);
  float cb12_192z : packoffset(c192.z);
  float cb12_192w : packoffset(c192.w);
  float cb12_193x : packoffset(c193.x);
  int cb12_287z : packoffset(c287.z);
  uint cb12_padding : packoffset(c340.w);
};

struct OutputSignature {
  linear float4 output_TEXCOORD : TEXCOORD;
  linear float4 TEXCOORD_1 : TEXCOORD1;
  linear float4 TEXCOORD_2 : TEXCOORD2;
  linear float4 TEXCOORD_3 : TEXCOORD3;
  linear float3 TEXCOORD_4 : TEXCOORD4;
  linear float3 TEXCOORD_5 : TEXCOORD5;
  noperspective float4 SV_Position : SV_Position;
};

OutputSignature main(
  float3 POSITION : POSITION,
  float2 TEXCOORD : TEXCOORD,
  float3 NORMAL : NORMAL,
  float4 TANGENT : TANGENT
) {
  float4 output_TEXCOORD = 0;
  float4 TEXCOORD_1 = 0;
  float4 TEXCOORD_2 = 0;
  float4 TEXCOORD_3 = 0;
  float3 TEXCOORD_4 = 0;
  float3 TEXCOORD_5 = 0;
  float4 SV_Position = 0;
  float _42 = (POSITION.x * FrequentVertexConsts_128.x) + FrequentVertexConsts_144.x;
  float _43 = (POSITION.y * FrequentVertexConsts_128.y) + FrequentVertexConsts_144.y;
  float _44 = (POSITION.z * FrequentVertexConsts_128.z) + FrequentVertexConsts_144.z;
  // Resize around the packed bounding-box centre; preserve phase/UVs.
  float3 moon_position = ScaleCelestialPosition(float3(_42, _43, _44),
      FrequentVertexConsts_128.xyz, FrequentVertexConsts_144.xyz, moon_size_bits, WITCHER_MOON_TAG);
  _42 = moon_position.x;
  _43 = moon_position.y;
  _44 = moon_position.z;
  float _48 = mad(_44, (FrequentVertexConsts_000[0].z), mad(_43, (FrequentVertexConsts_000[0].y), (_42 * (FrequentVertexConsts_000[0].x)))) + (FrequentVertexConsts_000[0].w);
  float _52 = mad(_44, (FrequentVertexConsts_000[1].z), mad(_43, (FrequentVertexConsts_000[1].y), (_42 * (FrequentVertexConsts_000[1].x)))) + (FrequentVertexConsts_000[1].w);
  float _56 = mad(_44, (FrequentVertexConsts_000[2].z), mad(_43, (FrequentVertexConsts_000[2].y), (_42 * (FrequentVertexConsts_000[2].x)))) + (FrequentVertexConsts_000[2].w);
  float _81 = (FrequentVertexConsts_000[0].w) - cb1_036x;
  float _82 = (FrequentVertexConsts_000[1].w) - cb1_036y;
  float _83 = (FrequentVertexConsts_000[2].w) - cb1_036z;
  float _167 = (NORMAL.x * 2.0f) + -1.0f;
  float _168 = (NORMAL.y * 2.0f) + -1.0f;
  float _169 = (NORMAL.z * 2.0f) + -1.0f;
  float _173 = (TANGENT.x * 2.0f) + -1.0f;
  float _174 = (TANGENT.y * 2.0f) + -1.0f;
  float _175 = (TANGENT.z * 2.0f) + -1.0f;
  float _177 = (TANGENT.w * 2.0f) + -1.0f;
  float _187 = ((_168 * _175) - (_169 * _174)) * _177;
  float _188 = ((_169 * _173) - (_167 * _175)) * _177;
  float _189 = ((_167 * _174) - (_168 * _173)) * _177;
  float _191 = rsqrt(dot(float3(_187, _188, _189), float3(_187, _188, _189)));
  float _192 = _191 * _187;
  float _193 = _191 * _188;
  float _194 = _191 * _189;
  float _197 = mad(_169, (FrequentVertexConsts_000[0].z), mad(_168, (FrequentVertexConsts_000[0].y), ((FrequentVertexConsts_000[0].x) * _167)));
  float _200 = mad(_169, (FrequentVertexConsts_000[1].z), mad(_168, (FrequentVertexConsts_000[1].y), ((FrequentVertexConsts_000[1].x) * _167)));
  float _203 = mad(_169, (FrequentVertexConsts_000[2].z), mad(_168, (FrequentVertexConsts_000[2].y), ((FrequentVertexConsts_000[2].x) * _167)));
  float _205 = rsqrt(dot(float3(_197, _200, _203), float3(_197, _200, _203)));
  float _211 = mad(_194, (FrequentVertexConsts_000[0].z), mad(_193, (FrequentVertexConsts_000[0].y), (_192 * (FrequentVertexConsts_000[0].x))));
  float _214 = mad(_194, (FrequentVertexConsts_000[1].z), mad(_193, (FrequentVertexConsts_000[1].y), (_192 * (FrequentVertexConsts_000[1].x))));
  float _217 = mad(_194, (FrequentVertexConsts_000[2].z), mad(_193, (FrequentVertexConsts_000[2].y), (_192 * (FrequentVertexConsts_000[2].x))));
  float _219 = rsqrt(dot(float3(_211, _214, _217), float3(_211, _214, _217)));
  float _225 = mad(_175, (FrequentVertexConsts_000[0].z), mad(_174, (FrequentVertexConsts_000[0].y), ((FrequentVertexConsts_000[0].x) * _173)));
  float _228 = mad(_175, (FrequentVertexConsts_000[1].z), mad(_174, (FrequentVertexConsts_000[1].y), ((FrequentVertexConsts_000[1].x) * _173)));
  float _231 = mad(_175, (FrequentVertexConsts_000[2].z), mad(_174, (FrequentVertexConsts_000[2].y), ((FrequentVertexConsts_000[2].x) * _173)));
  float _233 = rsqrt(dot(float3(_225, _228, _231), float3(_225, _228, _231)));
  float _252 = _48 - cb12_000x;
  float _253 = _52 - cb12_000y;
  float _254 = _56 - cb12_000z;
  float _260 = sqrt(((_252 * _252) + (_253 * _253)) + (_254 * _254));
  float _263 = _254 / _260;
  float _267 = min(cb12_042z, max(0.0f, (_260 - cb12_022z)));
  float _268 = _267 * 0.0625f;
  float _269 = _268 * _263;
  float _270 = _268 * cb12_043x;
  float _275 = dot(float3(cb12_038x, cb12_038y, cb12_038z), float3((_252 / _260), (_253 / _260), _263));
  float _283 = (saturate((_275 + cb12_042x) / (cb12_042x + 1.0f)) * (cb12_043y - cb12_043z)) + cb12_043z;
  bool _292;
  float _300;
  float _314;
  float _315;
  float _316;
  float _341;
  float _342;
  float _343;
  float _498;
  float _499;
  float _582;
  float _583;
  float _584;
  float _585;
  if (!(cb12_287z == 0)) {
    _292 = ((int)(_275 > 0.0f) && (int)(cb12_287z != 2));
  } else {
    _292 = true;
  }
  float _293 = abs(_275);
  if (_292) {
    _300 = saturate((_267 * 0.0020000000949949026f) + -0.30000001192092896f);
  } else {
    _300 = 1.0f;
  }
  float _301 = (_293 * _293) * _300;
  bool _302 = (_275 > 0.0f);
  if (_302) {
    _314 = cb12_039x;
    _315 = cb12_039y;
    _316 = cb12_039z;
  } else {
    _314 = cb12_041x;
    _315 = cb12_041y;
    _316 = cb12_041z;
  }
  float _327 = ((_314 - cb12_040x) * _301) + cb12_040x;
  float _328 = ((_315 - cb12_040y) * _301) + cb12_040y;
  float _329 = ((_316 - cb12_040z) * _301) + cb12_040z;
  if (_302) {
    _341 = cb12_045x;
    _342 = cb12_045y;
    _343 = cb12_045z;
  } else {
    _341 = cb12_047x;
    _342 = cb12_047y;
    _343 = cb12_047z;
  }
  [branch]
  if (!(!(_267 >= cb12_048y))) {
    float _362 = (cb12_042y + cb12_000z) + (_263 * cb12_022z);
    float _363 = _283 * _362;
    float _364 = _283 * _269;
    _498 = (1.0f - ((((((((((((((((1.0f - saturate(_270 / (max(0.0f, ((_364 * 15.0f) + _363)) + 1.0f))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 16.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 14.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 13.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 12.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 11.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 10.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 9.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 8.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 7.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 6.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 5.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 4.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 3.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, ((_364 * 2.0f) + _363)) + 1.0f)))) * (1.0f - saturate(_270 / (max(0.0f, (_283 * (_269 + _362))) + 1.0f)))));
    _499 = saturate((_267 - cb12_048y) * cb12_048z);
  } else {
    _498 = 1.0f;
    _499 = 0.0f;
  }
  float _501 = log2(abs(_498));
  float _504 = exp2(_501 * cb12_042w) * _499;
  float _513 = saturate((cb12_190x * _504) + cb12_190y);
  float _526 = (cb12_189x - _327) * _513;
  float _527 = (cb12_189y - _328) * _513;
  float _528 = (cb12_189z - _329) * _513;
  float _529 = _526 + _327;
  float _530 = _527 + _328;
  float _531 = _528 + _329;
  float _537 = saturate((((cb12_189w + -1.0f) * saturate((cb12_190z * _504) + cb12_190w)) + 1.0f) * _504);
  [branch]
  if (cb12_193x > 0.0f) {
    float _547 = saturate((cb12_192x * _504) + cb12_192y);
    _582 = (((((cb12_191x - _327) * _547) - _526) * cb12_193x) + _529);
    _583 = (((((cb12_191y - _328) * _547) - _527) * cb12_193x) + _530);
    _584 = (((((cb12_191z - _329) * _547) - _528) * cb12_193x) + _531);
    _585 = (((saturate((((cb12_191w + -1.0f) * saturate((cb12_192z * _504) + cb12_192w)) + 1.0f) * _504) - _537) * cb12_193x) + _537);
  } else {
    _582 = _529;
    _583 = _530;
    _584 = _531;
    _585 = _537;
  }
  output_TEXCOORD.x = (lerp(cb12_046x, _341, _301));
  output_TEXCOORD.y = (lerp(cb12_046y, _342, _301));
  output_TEXCOORD.z = (lerp(cb12_046z, _343, _301));
  output_TEXCOORD.w = (exp2(_501 * cb12_048x) * _499);
  TEXCOORD_1.x = _582;
  TEXCOORD_1.y = _583;
  TEXCOORD_1.z = _584;
  TEXCOORD_1.w = _585;
  TEXCOORD_2.x = TEXCOORD.x;
  TEXCOORD_2.y = TEXCOORD.y;
  TEXCOORD_2.z = (_205 * _197);
  TEXCOORD_2.w = (_205 * _200);
  TEXCOORD_3.x = (_219 * _211);
  TEXCOORD_3.y = (_219 * _214);
  TEXCOORD_3.z = (_219 * _217);
  TEXCOORD_3.w = (_205 * _203);
  TEXCOORD_4.x = _48;
  TEXCOORD_4.y = _52;
  TEXCOORD_4.z = _56;
  TEXCOORD_5.x = (_233 * _225);
  TEXCOORD_5.y = (_233 * _228);
  TEXCOORD_5.z = (_233 * _231);
  SV_Position.x = mad(1.0f, mad(1.0f, cb1_045w, mad(_83, cb1_045z, mad(_82, cb1_045y, (cb1_045x * _81)))), mad(_44, mad(0.0f, cb1_045w, mad((FrequentVertexConsts_000[2].z), cb1_045z, mad((FrequentVertexConsts_000[1].z), cb1_045y, ((FrequentVertexConsts_000[0].z) * cb1_045x)))), mad(_43, mad(0.0f, cb1_045w, mad((FrequentVertexConsts_000[2].y), cb1_045z, mad((FrequentVertexConsts_000[1].y), cb1_045y, ((FrequentVertexConsts_000[0].y) * cb1_045x)))), (_42 * mad(0.0f, cb1_045w, mad((FrequentVertexConsts_000[2].x), cb1_045z, mad((FrequentVertexConsts_000[1].x), cb1_045y, ((FrequentVertexConsts_000[0].x) * cb1_045x))))))));
  SV_Position.y = mad(1.0f, mad(1.0f, cb1_046w, mad(_83, cb1_046z, mad(_82, cb1_046y, (cb1_046x * _81)))), mad(_44, mad(0.0f, cb1_046w, mad((FrequentVertexConsts_000[2].z), cb1_046z, mad((FrequentVertexConsts_000[1].z), cb1_046y, ((FrequentVertexConsts_000[0].z) * cb1_046x)))), mad(_43, mad(0.0f, cb1_046w, mad((FrequentVertexConsts_000[2].y), cb1_046z, mad((FrequentVertexConsts_000[1].y), cb1_046y, ((FrequentVertexConsts_000[0].y) * cb1_046x)))), (_42 * mad(0.0f, cb1_046w, mad((FrequentVertexConsts_000[2].x), cb1_046z, mad((FrequentVertexConsts_000[1].x), cb1_046y, ((FrequentVertexConsts_000[0].x) * cb1_046x))))))));
  SV_Position.z = mad(1.0f, mad(1.0f, cb1_047w, mad(_83, cb1_047z, mad(_82, cb1_047y, (cb1_047x * _81)))), mad(_44, mad(0.0f, cb1_047w, mad((FrequentVertexConsts_000[2].z), cb1_047z, mad((FrequentVertexConsts_000[1].z), cb1_047y, ((FrequentVertexConsts_000[0].z) * cb1_047x)))), mad(_43, mad(0.0f, cb1_047w, mad((FrequentVertexConsts_000[2].y), cb1_047z, mad((FrequentVertexConsts_000[1].y), cb1_047y, ((FrequentVertexConsts_000[0].y) * cb1_047x)))), (_42 * mad(0.0f, cb1_047w, mad((FrequentVertexConsts_000[2].x), cb1_047z, mad((FrequentVertexConsts_000[1].x), cb1_047y, ((FrequentVertexConsts_000[0].x) * cb1_047x))))))));
  SV_Position.w = mad(1.0f, mad(1.0f, cb1_048w, mad(_83, cb1_048z, mad(_82, cb1_048y, (cb1_048x * _81)))), mad(_44, mad(0.0f, cb1_048w, mad((FrequentVertexConsts_000[2].z), cb1_048z, mad((FrequentVertexConsts_000[1].z), cb1_048y, ((FrequentVertexConsts_000[0].z) * cb1_048x)))), mad(_43, mad(0.0f, cb1_048w, mad((FrequentVertexConsts_000[2].y), cb1_048z, mad((FrequentVertexConsts_000[1].y), cb1_048y, ((FrequentVertexConsts_000[0].y) * cb1_048x)))), (_42 * mad(0.0f, cb1_048w, mad((FrequentVertexConsts_000[2].x), cb1_048z, mad((FrequentVertexConsts_000[1].x), cb1_048y, ((FrequentVertexConsts_000[0].x) * cb1_048x))))))));
  OutputSignature output_signature = { output_TEXCOORD, TEXCOORD_1, TEXCOORD_2, TEXCOORD_3, TEXCOORD_4, TEXCOORD_5, SV_Position };
  return output_signature;
}
