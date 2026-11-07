// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "shared.h"

struct DimmerParams {
  row_major float4x3 DimmerParams_000;
  float3 DimmerParams_048;
  int DimmerParams_060;
  float DimmerParams_064;
  float DimmerParams_068;
  float DimmerParams_072;
  float DimmerParams_076;
};

struct LightParams {
  float4 LightParams_000;
  float4 LightParams_016;
  float4 LightParams_032;
  float4 LightParams_048;
  float4 LightParams_064;
  float4 LightParams_080;
  float4 LightParams_096;
  float4 LightParams_112;
  float4 LightParams_128;
  float4 LightParams_144;
};

struct NvHair_Material {
  float NvHair_Material_000;
  float NvHair_Material_004;
  float NvHair_Material_008;
  float NvHair_Material_012;
  float NvHair_Material_016;
  float NvHair_Material_020;
  float NvHair_Material_024;
  float NvHair_Material_028;
  float NvHair_Material_032;
  float NvHair_Material_036;
  float NvHair_Material_040;
  float NvHair_Material_044;
  float4 NvHair_Material_048;
  float4 NvHair_Material_064;
  float4 NvHair_Material_080;
  float NvHair_Material_096;
  float NvHair_Material_100;
  float NvHair_Material_104;
  float NvHair_Material_108;
  float NvHair_Material_112;
  float NvHair_Material_116;
  float NvHair_Material_120;
  float NvHair_Material_124;
  float NvHair_Material_128;
  float NvHair_Material_132;
  float NvHair_Material_136;
  float NvHair_Material_140;
  float NvHair_Material_144;
  float NvHair_Material_148;
  float NvHair_Material_152;
  float NvHair_Material_156;
  float NvHair_Material_160;
  float NvHair_Material_164;
  float NvHair_Material_168;
  float NvHair_Material_172;
};

struct NvHair_ConstantBuffer {
  row_major float4x4 NvHair_ConstantBuffer_000;
  row_major float4x4 NvHair_ConstantBuffer_064;
  row_major float4x4 NvHair_ConstantBuffer_128;
  row_major float4x4 NvHair_ConstantBuffer_192;
  row_major float4x4 NvHair_ConstantBuffer_256;
  row_major float4x4 NvHair_ConstantBuffer_320;
  row_major float4x4 NvHair_ConstantBuffer_384;
  row_major float4x4 NvHair_ConstantBuffer_448;
  float4 NvHair_ConstantBuffer_512;
  float4 NvHair_ConstantBuffer_528;
  int NvHair_ConstantBuffer_544;
  int NvHair_ConstantBuffer_548;
  int NvHair_ConstantBuffer_552;
  int NvHair_ConstantBuffer_556;
  int NvHair_ConstantBuffer_560;
  int NvHair_ConstantBuffer_564;
  float NvHair_ConstantBuffer_568;
  float NvHair_ConstantBuffer_572;
  int NvHair_ConstantBuffer_576;
  int NvHair_ConstantBuffer_580;
  int NvHair_ConstantBuffer_584;
  int NvHair_ConstantBuffer_588;
  float NvHair_ConstantBuffer_592;
  float NvHair_ConstantBuffer_596;
  float NvHair_ConstantBuffer_600;
  float NvHair_ConstantBuffer_604;
  NvHair_Material NvHair_ConstantBuffer_608;
  float4 NvHair_ConstantBuffer_784[64];
};

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


Texture2D<float4> t13 : register(t13);

Texture2D<float4> t17 : register(t17);

Texture2D<float4> t22 : register(t22);

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t27 : register(t27);

Texture2D<float4> t43 : register(t43);

Texture2DArray<float> t9 : register(t9);

TextureCubeArray<float> t10 : register(t10);

Texture2DArray<float4> t42 : register(t42);

ByteAddressBuffer t20 : register(t20);

Buffer<float3> t0 : register(t0);

Buffer<float4> t1 : register(t1);

Buffer<float4> t2 : register(t2);

Buffer<float4> t3 : register(t3);

Buffer<float4> t4 : register(t4);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t6 : register(t6);

Texture2D<float4> t7 : register(t7);

cbuffer cb2 : register(b2) {
  float4 FrequentPixelConsts_000 : packoffset(c000.x);
  float4 FrequentPixelConsts_016 : packoffset(c001.x);
  float4 FrequentPixelConsts_032 : packoffset(c002.x);
  float4 FrequentPixelConsts_048 : packoffset(c003.x);
  float4 FrequentPixelConsts_064 : packoffset(c004.x);
  float4 FrequentPixelConsts_080 : packoffset(c005.x);
  float4 FrequentPixelConsts_096 : packoffset(c006.x);
  row_major float4x4 FrequentPixelConsts_112 : packoffset(c007.x);
  row_major float4x4 FrequentPixelConsts_176 : packoffset(c011.x);
  float4 FrequentPixelConsts_240 : packoffset(c015.x);
  float4 FrequentPixelConsts_256 : packoffset(c016.x);
  float4 FrequentPixelConsts_272 : packoffset(c017.x);
  float4 FrequentPixelConsts_288 : packoffset(c018.x);
};

cbuffer cb12 : register(b12) {
  float4 cb12_raw[341] : packoffset(c0);
};

#define cb12_184y (cb12_raw[184].y)
#define cb12_226x (cb12_raw[226].x)
#define cb12_024x (cb12_raw[24].x)
#define cb12_184x (cb12_raw[184].x)
#define cb12_226y (cb12_raw[226].y)
#define cb12_000y (cb12_raw[0].y)
#define cb12_220y (cb12_raw[220].y)
#define cb12_000x (cb12_raw[0].x)
#define cb12_000z (cb12_raw[0].z)
#define cb12_188x (cb12_raw[188].x)
#define cb12_221x (cb12_raw[221].x)
#define cb12_219z (cb12_raw[219].z)
#define cb12_219w (cb12_raw[219].w)
#define cb12_219x (cb12_raw[219].x)
#define cb12_219y (cb12_raw[219].y)
#define cb12_221z (cb12_raw[221].z)
#define cb12_221y (cb12_raw[221].y)
#define cb12_185y (cb12_raw[185].y)
#define cb12_071y (cb12_raw[71].y)
#define cb12_185z (cb12_raw[185].z)
#define cb12_071z (cb12_raw[71].z)
#define cb12_185x (cb12_raw[185].x)
#define cb12_071x (cb12_raw[71].x)
#define cb12_288y (cb12_raw[288].y)
#define cb12_100x (cb12_raw[100].x)
#define cb12_106x (cb12_raw[106].x)
#define cb12_111x (asint(cb12_raw[111].x))
#define cb12_074x (cb12_raw[74].x)
#define cb12_184z (cb12_raw[184].z)
#define cb12_069y (cb12_raw[69].y)
#define cb12_184w (cb12_raw[184].w)
#define cb12_187x (cb12_raw[187].x)
#define cb12_069x (cb12_raw[69].x)
#define cb12_287w (cb12_raw[287].w)
#define cb12_288x (cb12_raw[288].x)
#define cb12_288z (cb12_raw[288].z)
#define cb12_288w (cb12_raw[288].w)

cbuffer cb13 : register(b13) {
  float4 cb13_raw[3589] : packoffset(c0);
};

#define cb13_061y (cb13_raw[61].y)
#define cb13_066x (cb13_raw[66].x)
#define cb13_000x (cb13_raw[0].x)
#define cb13_061x (cb13_raw[61].x)
#define cb13_000y (cb13_raw[0].y)
#define cb13_001y (cb13_raw[1].y)
#define cb13_066z (cb13_raw[66].z)
#define cb13_000z (cb13_raw[0].z)
#define cb13_061z (cb13_raw[61].z)
#define cb13_062x (cb13_raw[62].x)
#define cb13_062y (cb13_raw[62].y)
#define cb13_062z (cb13_raw[62].z)
#define cb13_001x (cb13_raw[1].x)
#define cb13_066y (cb13_raw[66].y)
#define cb13_001z (cb13_raw[1].z)
#define cb13_067x (cb13_raw[67].x)
#define cb13_066w (cb13_raw[66].w)

cbuffer cb0 : register(b0) {
  NvHair_ConstantBuffer cbPerFrame_000 : packoffset(c000.x);
};

SamplerState s13 : register(s13);

SamplerState s11 : register(s11);

SamplerState s10 : register(s10);

SamplerState s0 : register(s0);

#include "lighting/contact/forward.hlsli"
#include "lighting/sun_environment.hlsli"
#include "water/receiver.hlsli"

struct OutputSignature {
  float4 SV_Target : SV_Target;
  float4 SV_Target_1 : SV_Target1;
  float4 SV_Target_2 : SV_Target2;
  float4 SV_Target_3 : SV_Target3;
};

OutputSignature main(
  noperspective float4 SV_Position : SV_Position,
  linear float HAIR_TEX : HAIR_TEX,
  nointerpolation float COMP_TEXCOORD : COMP_TEXCOORD,
  nointerpolation uint C : C,
  nointerpolation float COORDS : COORDS
) {
  float4 SV_Target = 0;
  float4 SV_Target_1 = 0;
  float4 SV_Target_2 = 0;
  float4 SV_Target_3 = 0;
  bool _2478;
  float _38[4];
  float _59 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].x) * SV_Position.x;
  float _60 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].x), _59);
  float _61 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].x), _60);
  float _62 = _61 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].x);
  float _63 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].y) * SV_Position.x;
  float _64 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].y), _63);
  float _65 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].y), _64);
  float _66 = _65 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].y);
  float _67 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].z) * SV_Position.x;
  float _68 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].z), _67);
  float _69 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].z), _68);
  float _70 = _69 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].z);
  float _71 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].w) * SV_Position.x;
  float _72 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].w), _71);
  float _73 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].w), _72);
  float _74 = _73 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].w);
  float _75 = _62 / _74;
  float _76 = _66 / _74;
  float _77 = _70 / _74;
  float _78 = floor(COMP_TEXCOORD);
  float _79 = _78 * 0.00048828125f;
  float _80 = COMP_TEXCOORD - _78;
  int _83 = cbPerFrame_000.NvHair_ConstantBuffer_584 + -1;
  float _84 = float((int)(_83));
  float _85 = _84 * HAIR_TEX;
  float _86 = floor(_85);
  int _87 = int(_86);
  int _88 = _87 + 1;
  int _89 = min(_88, _83);
  float _90 = frac(_85);
  float3 _92 = t0.Load(C);
  float _96 = floor(_92.x);
  float _97 = floor(_92.y);
  float _98 = floor(_92.z);
  int _99 = int(_96);
  int _100 = int(_97);
  int _101 = int(_98);
  uint _102 = _99 * cbPerFrame_000.NvHair_ConstantBuffer_584;
  uint _103 = _100 * cbPerFrame_000.NvHair_ConstantBuffer_584;
  uint _104 = _101 * cbPerFrame_000.NvHair_ConstantBuffer_584;
  uint _105 = _102 + _87;
  uint _106 = _103 + _87;
  uint _107 = _104 + _87;
  uint _108 = _102 + _89;
  uint _109 = _103 + _89;
  uint _110 = _104 + _89;
  float _111 = floor(COORDS);
  float _112 = _111 * 0.00048828125f;
  float _113 = COORDS - _111;
  float4 _115 = t1.Load(_105);
  float4 _119 = t1.Load(_106);
  float4 _123 = t1.Load(_107);
  float _127 = _115.x * _113;
  float _128 = _115.y * _113;
  float _129 = _115.z * _113;
  float _130 = _119.x * _112;
  float _131 = _119.y * _112;
  float _132 = _119.z * _112;
  float _133 = _130 + _127;
  float _134 = _131 + _128;
  float _135 = _132 + _129;
  float _136 = 1.0f - _113;
  float _137 = _136 - _112;
  float _138 = _123.x * _137;
  float _139 = _123.y * _137;
  float _140 = _123.z * _137;
  float _141 = _133 + _138;
  float _142 = _134 + _139;
  float _143 = _135 + _140;
  float4 _144 = t1.Load(_108);
  float4 _148 = t1.Load(_109);
  float4 _152 = t1.Load(_110);
  float _156 = _144.x * _113;
  float _157 = _144.y * _113;
  float _158 = _144.z * _113;
  float _159 = _148.x * _112;
  float _160 = _148.y * _112;
  float _161 = _148.z * _112;
  float _162 = _152.x * _137;
  float _163 = _152.y * _137;
  float _164 = _152.z * _137;
  float _165 = _156 - _141;
  float _166 = _165 + _159;
  float _167 = _166 + _162;
  float _168 = _157 - _142;
  float _169 = _168 + _160;
  float _170 = _169 + _163;
  float _171 = _158 - _143;
  float _172 = _171 + _161;
  float _173 = _172 + _164;
  float _174 = _167 * _90;
  float _175 = _170 * _90;
  float _176 = _173 * _90;
  float _177 = _174 + _141;
  float _178 = _175 + _142;
  float _179 = _176 + _143;
  float _180 = dot(float3(_177, _178, _179), float3(_177, _178, _179));
  float _181 = rsqrt(_180);
  float _182 = _177 * _181;
  float _183 = _178 * _181;
  float _184 = _179 * _181;
  float4 _186 = t2.Load(_105);
  float4 _190 = t2.Load(_106);
  float4 _194 = t2.Load(_107);
  float _198 = _186.x * _113;
  float _199 = _186.y * _113;
  float _200 = _186.z * _113;
  float _201 = _190.x * _112;
  float _202 = _190.y * _112;
  float _203 = _190.z * _112;
  float _204 = _201 + _198;
  float _205 = _202 + _199;
  float _206 = _203 + _200;
  float _207 = _194.x * _137;
  float _208 = _194.y * _137;
  float _209 = _194.z * _137;
  float _210 = _204 + _207;
  float _211 = _205 + _208;
  float _212 = _206 + _209;
  float4 _213 = t2.Load(_108);
  float4 _217 = t2.Load(_109);
  float4 _221 = t2.Load(_110);
  float _225 = _213.x * _113;
  float _226 = _213.y * _113;
  float _227 = _213.z * _113;
  float _228 = _217.x * _112;
  float _229 = _217.y * _112;
  float _230 = _217.z * _112;
  float _231 = _221.x * _137;
  float _232 = _221.y * _137;
  float _233 = _221.z * _137;
  float _234 = _225 - _210;
  float _235 = _234 + _228;
  float _236 = _235 + _231;
  float _237 = _226 - _211;
  float _238 = _237 + _229;
  float _239 = _238 + _232;
  float _240 = _227 - _212;
  float _241 = _240 + _230;
  float _242 = _241 + _233;
  float _243 = _236 * _90;
  float _244 = _239 * _90;
  float _245 = _242 * _90;
  float _246 = _243 + _210;
  float _247 = _244 + _211;
  float _248 = _245 + _212;
  float _249 = dot(float3(_246, _247, _248), float3(_246, _247, _248));
  float _250 = rsqrt(_249);
  float _251 = _246 * _250;
  float _252 = _247 * _250;
  float _253 = _248 * _250;
  float4 _255 = t3.Load(_105);
  float4 _259 = t3.Load(_106);
  float4 _263 = t3.Load(_107);
  float _267 = _255.x * _113;
  float _268 = _255.y * _113;
  float _269 = _255.z * _113;
  float _270 = _259.x * _112;
  float _271 = _259.y * _112;
  float _272 = _259.z * _112;
  float _273 = _270 + _267;
  float _274 = _271 + _268;
  float _275 = _272 + _269;
  float _276 = _263.x * _137;
  float _277 = _263.y * _137;
  float _278 = _263.z * _137;
  float _279 = _273 + _276;
  float _280 = _274 + _277;
  float _281 = _275 + _278;
  float4 _282 = t3.Load(_108);
  float4 _286 = t3.Load(_109);
  float4 _290 = t3.Load(_110);
  float _294 = _282.x * _113;
  float _295 = _282.y * _113;
  float _296 = _282.z * _113;
  float _297 = _286.x * _112;
  float _298 = _286.y * _112;
  float _299 = _286.z * _112;
  float _300 = _290.x * _137;
  float _301 = _290.y * _137;
  float _302 = _290.z * _137;
  float _303 = _294 - _279;
  float _304 = _303 + _297;
  float _305 = _304 + _300;
  float _306 = _295 - _280;
  float _307 = _306 + _298;
  float _308 = _307 + _301;
  float _309 = _296 - _281;
  float _310 = _309 + _299;
  float _311 = _310 + _302;
  float _312 = _305 * _90;
  float _313 = _308 * _90;
  float _314 = _311 * _90;
  float _315 = _312 + _279;
  float _316 = _313 + _280;
  float _317 = _314 + _281;
  float4 _319 = t4.Load(_105);
  float4 _323 = t4.Load(_106);
  float4 _327 = t4.Load(_107);
  float _331 = _319.x * _113;
  float _332 = _319.y * _113;
  float _333 = _319.z * _113;
  float _334 = _323.x * _112;
  float _335 = _323.y * _112;
  float _336 = _323.z * _112;
  float _337 = _334 + _331;
  float _338 = _335 + _332;
  float _339 = _336 + _333;
  float _340 = _327.x * _137;
  float _341 = _327.y * _137;
  float _342 = _327.z * _137;
  float _343 = _337 + _340;
  float _344 = _338 + _341;
  float _345 = _339 + _342;
  float4 _346 = t4.Load(_108);
  float4 _350 = t4.Load(_109);
  float4 _354 = t4.Load(_110);
  float _358 = _346.x * _113;
  float _359 = _346.y * _113;
  float _360 = _346.z * _113;
  float _361 = _350.x * _112;
  float _362 = _350.y * _112;
  float _363 = _350.z * _112;
  float _364 = _354.x * _137;
  float _365 = _354.y * _137;
  float _366 = _354.z * _137;
  float _367 = _358 - _343;
  float _368 = _367 + _361;
  float _369 = _368 + _364;
  float _370 = _359 - _344;
  float _371 = _370 + _362;
  float _372 = _371 + _365;
  float _373 = _360 - _345;
  float _374 = _373 + _363;
  float _375 = _374 + _366;
  float _376 = _369 * _90;
  float _377 = _372 * _90;
  float _378 = _375 * _90;
  float _379 = _376 + _343;
  float _380 = _377 + _344;
  float _381 = _378 + _345;
  float _402 = (cbPerFrame_000.NvHair_ConstantBuffer_256[0].x) * _315;
  float _403 = mad(_316, (cbPerFrame_000.NvHair_ConstantBuffer_256[1].x), _402);
  float _404 = mad(_317, (cbPerFrame_000.NvHair_ConstantBuffer_256[2].x), _403);
  float _405 = _404 + (cbPerFrame_000.NvHair_ConstantBuffer_256[3].x);
  float _406 = (cbPerFrame_000.NvHair_ConstantBuffer_256[0].y) * _315;
  float _407 = mad(_316, (cbPerFrame_000.NvHair_ConstantBuffer_256[1].y), _406);
  float _408 = mad(_317, (cbPerFrame_000.NvHair_ConstantBuffer_256[2].y), _407);
  float _409 = _408 + (cbPerFrame_000.NvHair_ConstantBuffer_256[3].y);
  float _410 = (cbPerFrame_000.NvHair_ConstantBuffer_256[0].z) * _315;
  float _411 = mad(_316, (cbPerFrame_000.NvHair_ConstantBuffer_256[1].z), _410);
  float _412 = mad(_317, (cbPerFrame_000.NvHair_ConstantBuffer_256[2].z), _411);
  float _413 = _412 + (cbPerFrame_000.NvHair_ConstantBuffer_256[3].z);
  float _414 = (cbPerFrame_000.NvHair_ConstantBuffer_256[0].w) * _315;
  float _415 = mad(_316, (cbPerFrame_000.NvHair_ConstantBuffer_256[1].w), _414);
  float _416 = mad(_317, (cbPerFrame_000.NvHair_ConstantBuffer_256[2].w), _415);
  float _417 = _416 + (cbPerFrame_000.NvHair_ConstantBuffer_256[3].w);
  float _418 = _405 / _417;
  float _419 = _409 / _417;
  float _420 = _413 / _417;
  float _441 = (cbPerFrame_000.NvHair_ConstantBuffer_384[0].x) * _379;
  float _442 = mad(_380, (cbPerFrame_000.NvHair_ConstantBuffer_384[1].x), _441);
  float _443 = mad(_381, (cbPerFrame_000.NvHair_ConstantBuffer_384[2].x), _442);
  float _444 = _443 + (cbPerFrame_000.NvHair_ConstantBuffer_384[3].x);
  float _445 = (cbPerFrame_000.NvHair_ConstantBuffer_384[0].y) * _379;
  float _446 = mad(_380, (cbPerFrame_000.NvHair_ConstantBuffer_384[1].y), _445);
  float _447 = mad(_381, (cbPerFrame_000.NvHair_ConstantBuffer_384[2].y), _446);
  float _448 = _447 + (cbPerFrame_000.NvHair_ConstantBuffer_384[3].y);
  float _449 = (cbPerFrame_000.NvHair_ConstantBuffer_384[0].z) * _379;
  float _450 = mad(_380, (cbPerFrame_000.NvHair_ConstantBuffer_384[1].z), _449);
  float _451 = mad(_381, (cbPerFrame_000.NvHair_ConstantBuffer_384[2].z), _450);
  float _452 = _451 + (cbPerFrame_000.NvHair_ConstantBuffer_384[3].z);
  float _453 = (cbPerFrame_000.NvHair_ConstantBuffer_384[0].w) * _379;
  float _454 = mad(_380, (cbPerFrame_000.NvHair_ConstantBuffer_384[1].w), _453);
  float _455 = mad(_381, (cbPerFrame_000.NvHair_ConstantBuffer_384[2].w), _454);
  float _456 = _455 + (cbPerFrame_000.NvHair_ConstantBuffer_384[3].w);
  float _457 = _444 / _456;
  float _458 = _448 / _456;
  float _459 = _452 / _456;
  float _460 = _418 - _457;
  float _461 = _419 - _458;
  float _462 = _420 - _459;
  bool _487 = (cbPerFrame_000.NvHair_ConstantBuffer_544 == 0);
  float _496;
  float _497;
  float _498;
  float _510;
  float _511;
  float _512;
  float _524;
  float _586;
  float _587;
  float _588;
  float _777;
  float _844;
  float _845;
  float _846;
  float _847;
  float _848;
  float _849;
  float _928;
  float _929;
  float _930;
  float _1106;
  float _1161;
  float _1162;
  float _1163;
  float _1168;
  float _1169;
  float _1170;
  float _1178;
  float _1179;
  float _1180;
  float _1181;
  float _1182;
  float _1183;
  float _1184;
  float _1185;
  float _1186;
  float _1191;
  float _1192;
  float _1193;
  float _1194;
  float _1195;
  float _1196;
  int _1197;
  float _1280;
  float _1392;
  float _1393;
  float _1394;
  float _1395;
  float _1475;
  float _1476;
  float _1477;
  float _1478;
  float _1482;
  float _1483;
  float _1484;
  float _1485;
  int _1486;
  float _1529;
  int _1542;
  int _1543;
  float _1581;
  float _1582;
  float _1583;
  float _1588;
  float _1589;
  float _1590;
  float _1592;
  float _1593;
  float _1594;
  float _1595;
  float _1610;
  float _1625;
  float _1634;
  float _1654;
  float _1744;
  float _1808;
  float _1809;
  float _1810;
  float _1889;
  float _1890;
  float _1891;
  float _2028;
  float _2083;
  float _2084;
  float _2085;
  float _2090;
  float _2091;
  float _2092;
  float _2100;
  float _2101;
  float _2102;
  float _2103;
  float _2104;
  float _2105;
  float _2109;
  float _2110;
  float _2111;
  float _2112;
  float _2113;
  float _2114;
  float _2219;
  float _2220;
  int _2223;
  float _2224;
  float _2225;
  float _2226;
  float _2227;
  float _2228;
  float _2229;
  float _2230;
  float _2285;
  float _2343;
  float _2344;
  float _2345;
  float _2469;
  float _2470;
  float _2471;
  float _2472;
  float _2473;
  float _2474;
  float _2475;
  float _2515;
  float _2516;
  float _2517;
  float _2563;
  float _2564;
  float _2565;
  float _2566;
  float _2567;
  float _2568;
  float _2569;
  float _2655;
  float _2656;
  float _2657;
  float _2788;
  float _2789;
  float _2790;
  float _2824;
  float _2835;
  float _2844;
  float _2854;
  float _2885;
  float _2886;
  float _2887;
  float _2896;
  float _2897;
  float _2898;
  if (!_487) {
    float4 _491 = t5.SampleLevel(s0, float2(_80, _79), 0.0f);
    _496 = _491.x;
    _497 = _491.y;
    _498 = _491.z;
  } else {
    _496 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.x;
    _497 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.y;
    _498 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.z;
  }
  bool _501 = (cbPerFrame_000.NvHair_ConstantBuffer_548 == 0);
  if (!_501) {
    float4 _505 = t6.SampleLevel(s0, float2(_80, _79), 0.0f);
    _510 = _505.x;
    _511 = _505.y;
    _512 = _505.z;
  } else {
    _510 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.x;
    _511 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.y;
    _512 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.z;
  }
  bool _513 = (cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144 < 0.5f);
  if (_513) {
    float _515 = HAIR_TEX * 2.0f;
    float _516 = _515 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144;
    _524 = _516;
  } else {
    float _518 = 1.0f - cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144;
    float _519 = HAIR_TEX + -1.0f;
    float _520 = _519 * 2.0f;
    float _521 = _520 * _518;
    float _522 = _521 + 1.0f;
    _524 = _522;
  }
  float _525 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_148 + 0.0010000000474974513f;
  float _526 = 1.0f / _525;
  float _527 = _524 + -0.5f;
  float _528 = _526 * _527;
  float _529 = _528 + 0.5f;
  float _530 = saturate(_529);
  float _531 = _510 - _496;
  float _532 = _511 - _497;
  float _533 = _512 - _498;
  float _534 = _530 * _531;
  float _535 = _530 * _532;
  float _536 = _530 * _533;
  float _537 = _534 + _496;
  float _538 = _535 + _497;
  float _539 = _536 + _498;
  bool _541 = (cbPerFrame_000.NvHair_ConstantBuffer_552 == 0);
  if (!_541) {
    float4 _545 = t7.SampleLevel(s0, float2(HAIR_TEX, 0.5f), 0.0f);
    switch (cbPerFrame_000.NvHair_ConstantBuffer_576) {
      case 0: {
        float _552 = _545.x * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _553 = _545.y * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _554 = _545.z * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        _586 = _552;
        _587 = _553;
        _588 = _554;
        break;
      }
      case 1: {
        float _556 = _545.x * _537;
        float _557 = _545.y * _538;
        float _558 = _545.z * _539;
        float _559 = _556 - _537;
        float _560 = _557 - _538;
        float _561 = _558 - _539;
        float _562 = _559 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _563 = _560 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _564 = _561 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _565 = _562 + _537;
        float _566 = _563 + _538;
        float _567 = _564 + _539;
        _586 = _565;
        _587 = _566;
        _588 = _567;
        break;
      }
      case 2: {
        float _569 = _545.x * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _570 = _545.y * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _571 = _545.z * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _572 = _569 + _537;
        float _573 = _570 + _538;
        float _574 = _571 + _539;
        _586 = _572;
        _587 = _573;
        _588 = _574;
        break;
      }
      case 3: {
        float _576 = _545.x + -0.5f;
        float _577 = _545.y + -0.5f;
        float _578 = _545.z + -0.5f;
        float _579 = _576 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _580 = _577 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _581 = _578 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _582 = _579 + _537;
        float _583 = _580 + _538;
        float _584 = _581 + _539;
        _586 = _582;
        _587 = _583;
        _588 = _584;
        break;
      }
      default: {
        _586 = _537;
        _587 = _538;
        _588 = _539;
        break;
      }
    }
  } else {
    _586 = _537;
    _587 = _538;
    _588 = _539;
  }
  float _589 = _586 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _590 = _587 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _591 = _588 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _592 = log2(_589);
  float _593 = log2(_590);
  float _594 = log2(_591);
  float _595 = _592 * 2.200000047683716f;
  float _596 = _593 * 2.200000047683716f;
  float _597 = _594 * 2.200000047683716f;
  float _598 = exp2(_595);
  float _599 = exp2(_596);
  float _600 = exp2(_597);
  float _601 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.x);
  float _602 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.y);
  float _603 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.z);
  float _604 = _601 * 2.200000047683716f;
  float _605 = _602 * 2.200000047683716f;
  float _606 = _603 * 2.200000047683716f;
  float _607 = exp2(_604);
  float _608 = exp2(_605);
  float _609 = exp2(_606);
  float _610 = _607 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _611 = _608 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _612 = _609 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _613 = dot(float3(_251, _252, _253), float3(_251, _252, _253));
  float _614 = rsqrt(_613);
  float _615 = _614 * _251;
  float _616 = _614 * _252;
  float _617 = _614 * _253;
  float _618 = abs(_615);
  float _619 = abs(_616);
  float _620 = abs(_617);
  float _621 = max(_618, _619);
  float _622 = max(_620, _621);
  bool _623 = (_620 < _622);
  bool _624 = (_619 < _622);
  bool _625 = _623 && _624;
  float _626 = select(_625, _619, _618);
  float _627 = select(_623, _620, _619);
  bool _628 = (_626 < _627);
  float _629 = select(_628, _627, _626);
  float _630 = select(_628, _626, _627);
  float _631 = _630 / _629;
  float _632 = _615 / _622;
  float _633 = _616 / _622;
  float _634 = _617 / _622;
  float4 _637 = t13.SampleLevel(s13, float2(_629, _631), 0.0f);
  float _639 = _637.x * 0.5f;
  float _640 = _639 * _632;
  float _641 = _639 * _633;
  float _642 = _639 * _634;
  float _643 = _640 + 0.5f;
  float _644 = _641 + 0.5f;
  float _645 = _642 + 0.5f;
  float _646 = HAIR_TEX + 9.99999993922529e-09f;
  float _647 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_172 + 9.99999993922529e-09f;
  float _648 = _646 / _647;
  float _649 = saturate(_648);
  float _652 = 1.0f - cbPerFrame_000.NvHair_ConstantBuffer_600;
  float _653 = _652 * _649;
  float _654 = saturate(_653);
  bool _655 = (_654 >= 1.0f);
  float _656 = select(_655, 1.0f, 0.0f);
  uint _657 = uint(SV_Position.x);
  uint _658 = uint(SV_Position.y);
  bool _661 = (cb12_226x > 0.0f);
  bool _663 = (cb12_226y > 0.0f);
  int _666 = int(cb12_220y);
  int _667 = (uint)(_657) >> 4;
  int _668 = (uint)(_658) >> 4;
  int _671 = int(cb12_024x);
  uint _672 = _671 * _668;
  uint _673 = _672 + _667;
  uint _674 = _673 << 8u;
  float _679 = cb12_000x - _75;
  float _680 = cb12_000y - _76;
  float _681 = cb12_000z - _77;
  float _682 = dot(float3(_679, _680, _681), float3(_679, _680, _681));
  float _683 = rsqrt(_682);
  float _684 = _679 * _683;
  float _685 = _680 * _683;
  float _686 = _681 * _683;
  float4 _688 = t17.Load(int3(_657, _658, 0));
  GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
      float3(_75, _76, _77), float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
  // HairWorks keeps its native anisotropic lobes and ambient shadow weights.
  float graphics_sun_visibility = min(_688.y, GraphicsForwardContact(
      float3(_75, _76, _77), float3(_615, _616, _617), SV_Position.xy, true));
  bool _696 = (_688.y > 0.0f);
  if (_696) {
    float _698 = dot(float3(_615, _616, _617), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
    float _699 = _698 + 0.25f;
    float _700 = _699 * 0.800000011920929f;
    float _701 = saturate(_700);
    float _702 = _701 + _698;
    float _703 = _701 + 1.0f;
    float _704 = _702 / _703;
    float _705 = 1.0f / _703;
    float _706 = saturate(_704);
    bool _707 = (_666 == 1);
    if (_707) {
      float _709 = saturate(_698);
      bool _710 = (_617 > 0.0f);
      int _711 = (int)(uint)(_710);
      int _712 = _711 << 1u;
      int _713 = _712 + -1;
      float _714 = float((int)(_713));
      float _715 = _714 + _617;
      float _716 = -1.0f / _715;
      float _717 = _615 * _616;
      float _718 = _717 * _716;
      float _719 = _615 * _615;
      float _720 = _719 * _714;
      float _721 = _720 * _716;
      float _722 = _721 + 1.0f;
      float _723 = _718 * _714;
      int _724 = 1 - _712;
      float _725 = float((int)(_724));
      float _726 = _725 * _615;
      float _727 = _616 * _616;
      float _728 = _727 * _716;
      float _729 = _728 + _714;
      float _730 = -0.0f - _616;
      float _731 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
      float _732 = rsqrt(_731);
      float _733 = _732 * water_light.sun.x;
      float _734 = _732 * water_light.sun.y;
      float _735 = _732 * water_light.sun.z;
      float _736 = _733 * _722;
      float _737 = mad(_723, _734, _736);
      float _738 = mad(_726, _735, _737);
      float _739 = _733 * _718;
      float _740 = mad(_729, _734, _739);
      float _741 = mad(_730, _735, _740);
      float _742 = _733 * _615;
      float _743 = mad(_616, _734, _742);
      float _744 = mad(_617, _735, _743);
      float _745 = dot(float3(_738, _741, _744), float3(_738, _741, _744));
      float _746 = rsqrt(_745);
      float _747 = _746 * _738;
      float _748 = _746 * _741;
      float _749 = _746 * _744;
      float _750 = dot(float3(_684, _685, _686), float3(_684, _685, _686));
      float _751 = rsqrt(_750);
      float _752 = _751 * _684;
      float _753 = _751 * _685;
      float _754 = _751 * _686;
      float _755 = _752 * _722;
      float _756 = mad(_723, _753, _755);
      float _757 = mad(_726, _754, _756);
      float _758 = _752 * _718;
      float _759 = mad(_729, _753, _758);
      float _760 = mad(_730, _754, _759);
      float _761 = _752 * _615;
      float _762 = mad(_616, _753, _761);
      float _763 = mad(_617, _754, _762);
      float _764 = dot(float3(_757, _760, _763), float3(_757, _760, _763));
      float _765 = rsqrt(_764);
      float _766 = _765 * _757;
      float _767 = _765 * _760;
      float _768 = _765 * _763;
      float _769 = dot(float3(_747, _748, _749), float3(_766, _767, _768));
      float _770 = _768 * _749;
      float _771 = _769 - _770;
      bool _772 = (_771 > 0.0f);
      if (_772) {
        float _774 = max(_749, _768);
        float _775 = _771 / _774;
        _777 = _775;
      } else {
        _777 = _771;
      }
      float _778 = _777 * 0.20908956229686737f;
      float _779 = _778 + 0.25813528895378113f;
      float _780 = _779 * _598;
      float _781 = _779 * _599;
      float _782 = _779 * _600;
      float _783 = 1.0f - _768;
      float _784 = _783 * 0.07144299894571304f;
      float _785 = _784 + -0.332181453704834f;
      float _786 = _785 * _783;
      float _787 = _786 + 0.4918818771839142f;
      float _788 = _787 * _783;
      float _789 = _788 + 0.05710852891206741f;
      float _790 = _783 * 0.6568742394447327f;
      float _791 = _790 * _789;
      float _792 = 1.0f - _749;
      float _793 = _792 * 0.07144299894571304f;
      float _794 = _793 + -0.332181453704834f;
      float _795 = _794 * _792;
      float _796 = _795 + 0.4918818771839142f;
      float _797 = _796 * _792;
      float _798 = _797 + 0.05710852891206741f;
      float _799 = _792 * 0.6568742394447327f;
      float _800 = _799 * _798;
      float _801 = _598 * _598;
      float _802 = _599 * _599;
      float _803 = _600 * _600;
      float _804 = _801 * 0.8585715889930725f;
      float _805 = _802 * 0.8585715889930725f;
      float _806 = _803 * 0.8585715889930725f;
      float _807 = _598 * 0.1414284110069275f;
      float _808 = _599 * 0.1414284110069275f;
      float _809 = _600 * 0.1414284110069275f;
      float _810 = 1.0f - _807;
      float _811 = 1.0f - _808;
      float _812 = 1.0f - _809;
      float _813 = _804 / _810;
      float _814 = _805 / _811;
      float _815 = _806 / _812;
      float _816 = 0.1890440583229065f - _791;
      float _817 = max(1.0000000116860974e-07f, _816);
      float _818 = 0.1890440583229065f - _800;
      float _819 = max(1.0000000116860974e-07f, _818);
      float _820 = _817 * 2.250678300857544f;
      float _821 = _820 * _819;
      float _822 = _821 * _813;
      float _823 = _821 * _814;
      float _824 = _821 * _815;
      float _825 = _822 + _780;
      float _826 = _823 + _781;
      float _827 = _824 + _782;
      float _828 = _825 * _709;
      float _829 = _826 * _709;
      float _830 = _827 * _709;
      float _831 = _706 - _709;
      float _832 = max(0.0f, _831);
      float _833 = _832 * 0.31830987334251404f;
      float _834 = _833 * _598;
      float _835 = _833 * _599;
      float _836 = _833 * _600;
      float _837 = _828 + _834;
      float _838 = _829 + _835;
      float _839 = _830 + _836;
      float _840 = _837 * 3.1415927410125732f;
      float _841 = _838 * 3.1415927410125732f;
      float _842 = _839 * 3.1415927410125732f;
      _844 = _837;
      _845 = _838;
      _846 = _839;
      _847 = _840;
      _848 = _841;
      _849 = _842;
    } else {
      _844 = _706;
      _845 = _706;
      _846 = _706;
      _847 = _706;
      _848 = _706;
      _849 = _706;
    }
    bool _852 = (cb12_221x > 0.0f);
    float _853 = 1.0f - _610;
    float _854 = 1.0f - _611;
    float _855 = 1.0f - _612;
    if (_852) {
      float _857 = dot(float3(_615, _616, _617), float3(_684, _685, _686));
      float4 _860 = t43.SampleLevel(s10, float2(0.8999999761581421f, _857), 0.0f);
      float _863 = _860.x * _610;
      float _864 = _860.x * _611;
      float _865 = _860.x * _612;
      float _866 = _863 + _860.y;
      float _867 = _864 + _860.y;
      float _868 = _865 + _860.y;
      float _869 = _853 * 0.0476190485060215f;
      float _870 = _854 * 0.0476190485060215f;
      float _871 = _855 * 0.0476190485060215f;
      float _872 = _869 + _610;
      float _873 = _870 + _611;
      float _874 = _871 + _612;
      float _875 = 1.0f - _866;
      float _876 = 1.0f - _867;
      float _877 = 1.0f - _868;
      float _878 = _875 * _872;
      float _879 = _876 * _873;
      float _880 = _877 * _874;
      float _881 = 1.0f - _878;
      float _882 = 1.0f - _879;
      float _883 = 1.0f - _880;
      float _884 = max(_881, 0.0010000000474974513f);
      float _885 = max(_882, 0.0010000000474974513f);
      float _886 = max(_883, 0.0010000000474974513f);
      float _887 = _866 / _884;
      float _888 = _867 / _885;
      float _889 = _868 / _886;
      float _890 = min(_887, 1.0f);
      float _891 = min(_888, 1.0f);
      float _892 = min(_889, 1.0f);
      _928 = _890;
      _929 = _891;
      _930 = _892;
    } else {
      float _894 = water_light.sun.x + _684;
      float _895 = water_light.sun.y + _685;
      float _896 = water_light.sun.z + _686;
      float _897 = dot(float3(_894, _895, _896), float3(_894, _895, _896));
      float _898 = rsqrt(_897);
      float _899 = _898 * _894;
      float _900 = _898 * _895;
      float _901 = _898 * _896;
      float _902 = dot(float3(_899, _900, _901), float3(_684, _685, _686));
      float _903 = abs(_902);
      float _904 = 1.0f - _903;
      float _905 = saturate(_904);
      float _906 = _905 * _905;
      float _910 = max(0.0f, _853);
      float _911 = max(0.0f, _854);
      float _912 = max(0.0f, _855);
      float _913 = _906 * _906;
      float _914 = _913 * _905;
      float _915 = _914 * cb13_066x;
      float _916 = _915 * _910;
      float _917 = _915 * _911;
      float _918 = _915 * _912;
      float _919 = cb13_066z * 0.8999999761581421f;
      float _920 = _919 + 1.0f;
      float _921 = _916 / _920;
      float _922 = _917 / _920;
      float _923 = _918 / _920;
      float _924 = _921 + _610;
      float _925 = _922 + _611;
      float _926 = _923 + _612;
      _928 = _924;
      _929 = _925;
      _930 = _926;
    }
    float _931 = 1.0f - _928;
    float _932 = 1.0f - _929;
    float _933 = 1.0f - _930;
    float _934 = _931 * _844;
    float _935 = _932 * _845;
    float _936 = _933 * _846;
    int _937 = _666 & -3;
    bool _938 = (_937 == 0);
    float _939 = _934 * 0.31830987334251404f;
    float _940 = _935 * 0.31830987334251404f;
    float _941 = _936 * 0.31830987334251404f;
    float _942 = select(_938, _939, _934);
    float _943 = select(_938, _940, _935);
    float _944 = select(_938, _941, _936);
    float _945 = _75 - cb12_000x;
    float _946 = _76 - cb12_000y;
    float _947 = _945 * _945;
    float _948 = _946 * _946;
    float _949 = _947 + _948;
    float _950 = sqrt(_949);
    float _953 = cb12_219z * _77;
    float _955 = _953 + cb12_219w;
    float _956 = saturate(_955);
    float _965 = cb13_061x - cb13_062x;
    float _966 = cb13_061y - cb13_062y;
    float _967 = cb13_061z - cb13_062z;
    float _968 = _965 * _956;
    float _969 = _966 * _956;
    float _970 = _967 * _956;
    float _971 = _968 + cb13_062x;
    float _972 = _969 + cb13_062y;
    float _973 = _970 + cb13_062z;
    float _975 = cb12_219x * _950;
    float _977 = _975 + cb12_219y;
    float _978 = saturate(_977);
    float _983 = _971 - cb13_001x;
    float _984 = _972 - cb13_001y;
    float _985 = _973 - cb13_001z;
    float _986 = _983 * _978;
    float _987 = _984 * _978;
    float _988 = _985 * _978;
    float _989 = (_986 + cb13_001x) * water_light.direct.x;
    float _990 = (_987 + cb13_001y) * water_light.direct.y;
    float _991 = (_988 + cb13_001z) * water_light.direct.z;
    float _992 = _705 * graphics_sun_visibility;
    float _993 = _942 * _992;
    float _994 = _993 * _989;
    float _995 = _943 * _992;
    float _996 = _995 * _990;
    float _997 = _944 * _992;
    float _998 = _997 * _991;
    float _999 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_615, _616, _617));
    bool _1000 = (_999 > 0.0f);
    [branch]
    if (_1000) {
      float _1002 = water_light.sun.x + _684;
      float _1003 = water_light.sun.y + _685;
      float _1004 = water_light.sun.z + _686;
      float _1005 = dot(float3(_1002, _1003, _1004), float3(_1002, _1003, _1004));
      float _1006 = rsqrt(_1005);
      float _1007 = _1006 * _1002;
      float _1008 = _1006 * _1003;
      float _1009 = _1006 * _1004;
      float _1010 = dot(float3(_615, _616, _617), float3(_684, _685, _686));
      float _1011 = saturate(_698);
      float _1012 = dot(float3(_182, _183, _184), float3(_182, _183, _184));
      float _1013 = rsqrt(_1012);
      float _1014 = _1013 * _182;
      float _1015 = _1013 * _183;
      float _1016 = _1013 * _184;
      float _1017 = dot(float3(_1014, _1015, _1016), float3(_615, _616, _617));
      float _1018 = _1017 * _615;
      float _1019 = _1017 * _616;
      float _1020 = _1017 * _617;
      float _1021 = _1014 - _1018;
      float _1022 = _1015 - _1019;
      float _1023 = _1016 - _1020;
      float _1024 = dot(float3(_1021, _1022, _1023), float3(_1021, _1022, _1023));
      float _1025 = rsqrt(_1024);
      float _1026 = _1021 * _1025;
      float _1027 = _1022 * _1025;
      float _1028 = _1023 * _1025;
      float _1029 = _1027 * _617;
      float _1030 = _1028 * _616;
      float _1031 = _1029 - _1030;
      float _1032 = _1028 * _615;
      float _1033 = _1026 * _617;
      float _1034 = _1032 - _1033;
      float _1035 = _1026 * _616;
      float _1036 = _1027 * _615;
      float _1037 = _1035 - _1036;
      float _1038 = dot(float3(_1031, _1034, _1037), float3(_1031, _1034, _1037));
      float _1039 = rsqrt(_1038);
      float _1040 = _1031 * _1039;
      float _1041 = _1034 * _1039;
      float _1042 = _1037 * _1039;
      float _1043 = dot(float3(_1026, _1027, _1028), float3(_1007, _1008, _1009));
      float _1044 = _1043 * 1.2345679998397827f;
      float _1045 = _1044 * _1044;
      float _1046 = dot(float3(_1040, _1041, _1042), float3(_1007, _1008, _1009));
      float _1047 = _1046 * 1.2345679998397827f;
      float _1048 = _1047 * _1047;
      float _1049 = dot(float3(_615, _616, _617), float3(_1007, _1008, _1009));
      float _1050 = saturate(_1049);
      float _1051 = _1050 * _1050;
      float _1052 = _1048 + _1045;
      float _1053 = _1052 + _1051;
      float _1054 = _1053 * _1053;
      float _1055 = 0.4851658046245575f / _1054;
      float _1056 = abs(_1010);
      float _1057 = dot(float3(_1007, _1008, _1009), float3(_684, _685, _686));
      float _1058 = abs(_1057);
      float _1059 = 1.0f - _1058;
      float _1060 = saturate(_1059);
      float _1061 = _1060 * _1060;
      float _1065 = max(0.0f, _853);
      float _1066 = max(0.0f, _854);
      float _1067 = max(0.0f, _855);
      float _1068 = _1061 * _1061;
      float _1069 = _1068 * _1060;
      float _1070 = _1069 * cb13_066x;
      float _1071 = _1070 * _1065;
      float _1072 = _1070 * _1066;
      float _1073 = _1070 * _1067;
      float _1074 = cb13_066z * 0.8999999761581421f;
      float _1075 = _1074 + 1.0f;
      float _1076 = _1071 / _1075;
      float _1077 = _1072 / _1075;
      float _1078 = _1073 / _1075;
      float _1079 = _1076 + _610;
      float _1080 = _1077 + _611;
      float _1081 = _1078 + _612;
      bool _1083 = (cb12_221z > 0.0f);
      [branch]
      if (_1083) {
        float _1085 = saturate(_1010);
        float _1086 = _1085 + _1011;
        float _1087 = _1011 * 2.0f;
        float _1088 = _1087 * _1085;
        float _1089 = _1086 - _1088;
        float _1090 = _1089 * 0.809999942779541f;
        float _1091 = _1090 + _1088;
        _1106 = _1091;
      } else {
        float _1093 = _1056 * _1056;
        float _1094 = _1093 * 0.34390008449554443f;
        float _1095 = _1094 + 0.6560999155044556f;
        float _1096 = sqrt(_1095);
        float _1097 = _1096 * _1011;
        float _1098 = _1011 * _1011;
        float _1099 = _1098 * 0.34390008449554443f;
        float _1100 = _1099 + 0.6560999155044556f;
        float _1101 = sqrt(_1100);
        float _1102 = _1101 * _1056;
        float _1103 = _1097 + 9.999999747378752e-05f;
        float _1104 = _1103 + _1102;
        _1106 = _1104;
      }
      float _1107 = 0.5f / _1106;
      float _1108 = _1107 * _1055;
      float _1109 = _1108 * _1079;
      float _1110 = _1108 * _1080;
      float _1111 = _1108 * _1081;
      bool _1113 = (cb12_221y > 0.0f);
      if (_1113) {
        float _1115 = dot(float3(_615, _616, _617), float3(_1107, _1107, _1107));
        float4 _1118 = t43.SampleLevel(s10, float2(0.8999999761581421f, _1115), 0.0f);
        float _1121 = _1118.x * _610;
        float _1122 = _1118.x * _611;
        float _1123 = _1118.x * _612;
        float _1124 = _1121 + _1118.y;
        float _1125 = _1122 + _1118.y;
        float _1126 = _1123 + _1118.y;
        float _1127 = _853 * 0.0476190485060215f;
        float _1128 = _854 * 0.0476190485060215f;
        float _1129 = _855 * 0.0476190485060215f;
        float _1130 = _1127 + _610;
        float _1131 = _1128 + _611;
        float _1132 = _1129 + _612;
        float _1133 = 1.0f - _1124;
        float _1134 = 1.0f - _1125;
        float _1135 = 1.0f - _1126;
        float _1136 = _1133 * _1130;
        float _1137 = _1134 * _1131;
        float _1138 = _1135 * _1132;
        float _1139 = 1.0f - _1136;
        float _1140 = 1.0f - _1137;
        float _1141 = 1.0f - _1138;
        float _1142 = max(_1139, 0.0010000000474974513f);
        float _1143 = max(_1140, 0.0010000000474974513f);
        float _1144 = max(_1141, 0.0010000000474974513f);
        float _1145 = _1124 / _1142;
        float _1146 = _1125 / _1143;
        float _1147 = _1126 / _1144;
        float _1148 = min(_1145, 1.0f);
        float _1149 = min(_1146, 1.0f);
        float _1150 = min(_1147, 1.0f);
        float _1151 = max(_1124, 9.999999747378752e-05f);
        float _1152 = max(_1125, 9.999999747378752e-05f);
        float _1153 = max(_1126, 9.999999747378752e-05f);
        float _1154 = _1148 / _1151;
        float _1155 = _1149 / _1152;
        float _1156 = _1150 / _1153;
        float _1157 = _1154 * _1109;
        float _1158 = _1155 * _1110;
        float _1159 = _1156 * _1111;
        _1161 = _1157;
        _1162 = _1158;
        _1163 = _1159;
      } else {
        _1161 = _1109;
        _1162 = _1110;
        _1163 = _1111;
      }
      float _1164 = _1161 * _1011;
      float _1165 = _1162 * _1011;
      float _1166 = _1163 * _1011;
      _1168 = _1164;
      _1169 = _1165;
      _1170 = _1166;
    } else {
      _1168 = 0.0f;
      _1169 = 0.0f;
      _1170 = 0.0f;
    }
    float _1171 = _989 * graphics_sun_visibility;
    float _1172 = _1171 * _1168;
    float _1173 = _990 * graphics_sun_visibility;
    float _1174 = _1173 * _1169;
    float _1175 = _991 * graphics_sun_visibility;
    float _1176 = _1175 * _1170;
    _1178 = _1172;
    _1179 = _1174;
    _1180 = _1176;
    _1181 = _994;
    _1182 = _996;
    _1183 = _998;
    _1184 = _847;
    _1185 = _848;
    _1186 = _849;
  } else {
    _1178 = 0.0f;
    _1179 = 0.0f;
    _1180 = 0.0f;
    _1181 = 0.0f;
    _1182 = 0.0f;
    _1183 = 0.0f;
    _1184 = 0.0f;
    _1185 = 0.0f;
    _1186 = 0.0f;
  }
  if (any(water_light.direct != 1.f)) {
    float3 native_environment = GraphicsForwardSunEnvironment(float3(_615, _616, _617), float3(_615, _616, _617),
        float3(_684, _685, _686), float3(cb13_000x, cb13_000y, cb13_000z), float3(_598, _599, _600), .9f, int(cb12_220y), .25f, _688.y);
    _1184 = native_environment.x; _1185 = native_environment.y; _1186 = native_environment.z;
  }
  float _1187 = min(_1184, _688.y);
  float _1188 = min(_1185, _688.y);
  float _1189 = min(_1186, _688.y);
  _1191 = _1181;
  _1192 = _1182;
  _1193 = _1183;
  _1194 = _1178;
  _1195 = _1179;
  _1196 = _1180;
  _1197 = 0;
  while(true) {
    int _1198 = _1197 + _674;
    uint _1199 = _1198 << 2u;
    int4 _1201 = asint(t20.Load4(_1199));
    bool _1203 = ((uint)_1201.x > (uint)255);
    [branch]
    if (!_1203) {
      uint _1205 = _1201.x * 10;
      uint _1206 = _1205 + 68u;
      float _1211 = (cb13_raw[_1206].x) - _75;
      float _1212 = (cb13_raw[_1206].y) - _76;
      float _1213 = (cb13_raw[_1206].z) - _77;
      float _1214 = _1211 * _1211;
      float _1215 = _1212 * _1212;
      float _1216 = _1214 + _1215;
      float _1217 = _1213 * _1213;
      float _1218 = _1216 + _1217;
      float _1219 = sqrt(_1218);
      float _1220 = _1219 * _1219;
      uint _1221 = _1205 + 73u;
      float _1224 = _1220 * (cb13_raw[_1221].x);
      float _1226 = _1219 / (cb13_raw[_1206].w);
      float _1227 = _1226 * _1226;
      float _1228 = _1227 * _1227;
      float _1229 = 1.0f - _1228;
      float _1230 = saturate(_1229);
      float _1231 = _1230 * _1230;
      uint _1232 = _1205 + 71u;
      int _1235 = asint((cb13_raw[_1232].w));
      int _1236 = _1235 & 1;
      bool _1237 = (_1236 != 0);
      bool _1239 = ((cb13_raw[_1221].z) > 0.0f);
      uint _1240 = _1205 + 74u;
      bool _1243 = ((cb13_raw[_1240].x) > 0.0f);
      uint _1244 = _1205 + 77u;
      int _1247 = asint((cb13_raw[_1244].x));
      int _1248 = _1247 & 1;
      bool _1249 = (_1248 != 0);
      float _1250 = _1224 + 1.0f;
      float _1251 = _1231 / _1250;
      if (_1237) {
        uint _1253 = _1205 + 70u;
        float _1258 = dot(float3(_1211, _1212, _1213), float3(_1211, _1212, _1213));
        float _1259 = rsqrt(_1258);
        float _1260 = _1211 * _1259;
        float _1261 = -0.0f - _1260;
        float _1262 = _1212 * _1259;
        float _1263 = -0.0f - _1262;
        float _1264 = _1213 * _1259;
        float _1265 = -0.0f - _1264;
        float _1266 = dot(float3(_1261, _1263, _1265), float3((cb13_raw[_1253].x), (cb13_raw[_1253].y), (cb13_raw[_1253].z)));
        uint _1267 = _1205 + 72u;
        float _1271 = (cb13_raw[_1267].y) * _1266;
        float _1273 = _1271 + (cb13_raw[_1267].z);
        float _1274 = saturate(_1273);
        float _1275 = log2(_1274);
        float _1276 = _1275 * (cb13_raw[_1267].w);
        float _1277 = exp2(_1276);
        float _1278 = _1277 * _1251;
        _1280 = _1278;
      } else {
        _1280 = _1251;
      }
      bool _1281 = _1239 || _1249;
      bool _1282 = (_1280 > 0.0f);
      bool _1283 = _1281 && _1282;
      if (_1283) {
        float _1285 = -0.0f - _1211;
        float _1286 = -0.0f - _1212;
        float _1287 = -0.0f - _1213;
        if (_1237) {
          uint _1289 = _1205 + 70u;
          uint _1294 = _1205 + 75u;
          float _1299 = (cb13_raw[_1294].w) * (cb13_raw[_1289].y);
          float _1300 = (cb13_raw[_1294].z) * (cb13_raw[_1289].z);
          float _1301 = _1299 - _1300;
          float _1302 = (cb13_raw[_1294].y) * (cb13_raw[_1289].z);
          float _1303 = (cb13_raw[_1294].w) * (cb13_raw[_1289].x);
          float _1304 = _1302 - _1303;
          float _1305 = (cb13_raw[_1294].z) * (cb13_raw[_1289].x);
          float _1306 = (cb13_raw[_1294].y) * (cb13_raw[_1289].y);
          float _1307 = _1305 - _1306;
          float _1308 = _1301 * _1285;
          float _1309 = mad(_1304, _1286, _1308);
          float _1310 = mad(_1307, _1287, _1309);
          float _1311 = (cb13_raw[_1294].y) * _1285;
          float _1312 = mad((cb13_raw[_1294].z), _1286, _1311);
          float _1313 = mad((cb13_raw[_1294].w), _1287, _1312);
          float _1314 = (cb13_raw[_1289].x) * _1285;
          float _1315 = mad((cb13_raw[_1289].y), _1286, _1314);
          float _1316 = mad((cb13_raw[_1289].z), _1287, _1315);
          int _1319 = asint((cb13_raw[_1244].z));
          _1482 = _1310;
          _1483 = _1313;
          _1484 = _1316;
          _1485 = (cb13_raw[_1294].x);
          _1486 = _1319;
        } else {
          if (_1249) {
            uint _1322 = _1205 + 72u;
            uint _1327 = _1205 + 70u;
            float _1332 = (cb13_raw[_1327].y) * (cb13_raw[_1322].w);
            float _1333 = (cb13_raw[_1327].z) * (cb13_raw[_1322].z);
            float _1334 = _1332 - _1333;
            float _1335 = (cb13_raw[_1327].z) * (cb13_raw[_1322].y);
            float _1336 = (cb13_raw[_1327].x) * (cb13_raw[_1322].w);
            float _1337 = _1335 - _1336;
            float _1338 = (cb13_raw[_1327].x) * (cb13_raw[_1322].z);
            float _1339 = (cb13_raw[_1327].y) * (cb13_raw[_1322].y);
            float _1340 = _1338 - _1339;
            float _1341 = _1334 * _1285;
            float _1342 = mad(_1337, _1286, _1341);
            float _1343 = mad(_1340, _1287, _1342);
            float _1344 = (cb13_raw[_1327].x) * _1285;
            float _1345 = mad((cb13_raw[_1327].y), _1286, _1344);
            float _1346 = mad((cb13_raw[_1327].z), _1287, _1345);
            float _1347 = (cb13_raw[_1322].y) * _1285;
            float _1348 = mad((cb13_raw[_1322].z), _1286, _1347);
            float _1349 = mad((cb13_raw[_1322].w), _1287, _1348);
            float _1350 = -0.0f - _1343;
            float _1351 = -0.0f - _1346;
            float _1352 = -0.0f - _1349;
            float _1353 = _1350 / _1219;
            float _1354 = _1351 / _1219;
            float _1355 = _1352 / _1219;
            float _1356 = abs(_1353);
            float _1357 = abs(_1354);
            float _1358 = abs(_1355);
            int _1359 = _1247 & 4;
            bool _1360 = (_1359 == 0);
            float _1361 = max(_1357, _1358);
            bool _1362 = (_1356 > _1361);
            if (!_1360) {
              if (_1362) {
                bool _1365 = (_1353 > 0.0f);
                uint _1366 = _1205 + 75u;
                if (_1365) {
                  _1392 = _1346;
                  _1393 = _1349;
                  _1394 = _1350;
                  _1395 = (cb13_raw[_1366].x);
                } else {
                  _1392 = _1351;
                  _1393 = _1349;
                  _1394 = _1343;
                  _1395 = (cb13_raw[_1366].y);
                }
              } else {
                float _1373 = max(_1356, _1358);
                bool _1374 = (_1357 > _1373);
                if (_1374) {
                  bool _1376 = (_1354 > 0.0f);
                  uint _1377 = _1205 + 75u;
                  if (_1376) {
                    _1392 = _1350;
                    _1393 = _1349;
                    _1394 = _1351;
                    _1395 = (cb13_raw[_1377].z);
                  } else {
                    _1392 = _1343;
                    _1393 = _1349;
                    _1394 = _1346;
                    _1395 = (cb13_raw[_1377].w);
                  }
                } else {
                  bool _1384 = (_1355 > 0.0f);
                  uint _1385 = _1205 + 76u;
                  if (_1384) {
                    _1392 = _1343;
                    _1393 = _1346;
                    _1394 = _1352;
                    _1395 = (cb13_raw[_1385].x);
                  } else {
                    _1392 = _1343;
                    _1393 = _1351;
                    _1394 = _1349;
                    _1395 = (cb13_raw[_1385].y);
                  }
                }
              }
              int _1397 = asint((cb13_raw[_1244].z));
              _1482 = _1392;
              _1483 = _1393;
              _1484 = _1394;
              _1485 = _1395;
              _1486 = _1397;
            } else {
              if (_1362) {
                bool _1400 = (_1353 > 0.0f);
                uint _1401 = _1205 + 75u;
                int _1404 = asint((cb13_raw[_1244].z));
                if (_1400) {
                  _1482 = _1346;
                  _1483 = _1349;
                  _1484 = _1350;
                  _1485 = (cb13_raw[_1401].x);
                  _1486 = _1404;
                } else {
                  int _1409 = (uint)(_1404) >> 10;
                  _1482 = _1351;
                  _1483 = _1349;
                  _1484 = _1343;
                  _1485 = (cb13_raw[_1401].y);
                  _1486 = _1409;
                }
              } else {
                float _1411 = max(_1356, _1358);
                bool _1412 = (_1357 > _1411);
                if (_1412) {
                  bool _1414 = (_1354 > 0.0f);
                  uint _1415 = _1205 + 75u;
                  if (_1414) {
                    int _1420 = asint((cb13_raw[_1244].z));
                    int _1421 = (uint)(_1420) >> 20;
                    _1482 = _1350;
                    _1483 = _1349;
                    _1484 = _1351;
                    _1485 = (cb13_raw[_1415].z);
                    _1486 = _1421;
                  } else {
                    int _1425 = asint((cb13_raw[_1244].w));
                    _1482 = _1343;
                    _1483 = _1349;
                    _1484 = _1346;
                    _1485 = (cb13_raw[_1415].w);
                    _1486 = _1425;
                  }
                } else {
                  bool _1427 = (_1355 > 0.0f);
                  uint _1428 = _1205 + 76u;
                  int _1431 = asint((cb13_raw[_1244].w));
                  if (_1427) {
                    int _1434 = (uint)(_1431) >> 10;
                    _1482 = _1343;
                    _1483 = _1346;
                    _1484 = _1352;
                    _1485 = (cb13_raw[_1428].x);
                    _1486 = _1434;
                  } else {
                    int _1437 = (uint)(_1431) >> 20;
                    _1482 = _1343;
                    _1483 = _1351;
                    _1484 = _1349;
                    _1485 = (cb13_raw[_1428].y);
                    _1486 = _1437;
                  }
                }
              }
            }
          } else {
            float _1439 = _1211 / _1219;
            float _1440 = _1212 / _1219;
            float _1441 = _1213 / _1219;
            float _1442 = abs(_1439);
            float _1443 = abs(_1440);
            float _1444 = abs(_1441);
            float _1445 = max(_1443, _1444);
            bool _1446 = (_1442 > _1445);
            if (_1446) {
              bool _1448 = (_1439 > 0.0f);
              uint _1449 = _1205 + 75u;
              if (_1448) {
                _1475 = _1286;
                _1476 = _1287;
                _1477 = _1211;
                _1478 = (cb13_raw[_1449].x);
              } else {
                _1475 = _1212;
                _1476 = _1287;
                _1477 = _1285;
                _1478 = (cb13_raw[_1449].y);
              }
            } else {
              float _1456 = max(_1442, _1444);
              bool _1457 = (_1443 > _1456);
              if (_1457) {
                bool _1459 = (_1440 > 0.0f);
                uint _1460 = _1205 + 75u;
                if (_1459) {
                  _1475 = _1211;
                  _1476 = _1287;
                  _1477 = _1212;
                  _1478 = (cb13_raw[_1460].z);
                } else {
                  _1475 = _1285;
                  _1476 = _1287;
                  _1477 = _1286;
                  _1478 = (cb13_raw[_1460].w);
                }
              } else {
                bool _1467 = (_1441 > 0.0f);
                uint _1468 = _1205 + 76u;
                if (_1467) {
                  _1475 = _1285;
                  _1476 = _1286;
                  _1477 = _1213;
                  _1478 = (cb13_raw[_1468].x);
                } else {
                  _1475 = _1285;
                  _1476 = _1212;
                  _1477 = _1287;
                  _1478 = (cb13_raw[_1468].y);
                }
              }
            }
            int _1480 = asint((cb13_raw[_1244].z));
            _1482 = _1475;
            _1483 = _1476;
            _1484 = _1477;
            _1485 = _1478;
            _1486 = _1480;
          }
        }
        float _1488 = _1482 * (cb13_raw[_1221].y);
        float _1489 = mad((cb13_raw[_1221].y), _1483, 0.0f);
        float _1490 = _1488 / _1484;
        float _1491 = _1489 / _1484;
        float _1492 = _1490 * 0.5f;
        float _1493 = _1491 * 0.5f;
        float _1494 = _1492 + 0.5f;
        float _1495 = 0.5f - _1493;
        if (_1239) {
          int _1497 = asint(_1485);
          int _1498 = (uint)(_1497) >> 18;
          int _1499 = _1498 & 4092;
          float _1500 = float((uint)_1499);
          bool _1501 = (_1499 == 0);
          [branch]
          if (!_1501) {
            int _1503 = (uint)(_1497) >> 30;
            float _1504 = float((uint)_1503);
            int _1505 = (uint)(_1497) >> 8;
            int _1506 = _1505 & 4092;
            float _1507 = float((uint)_1506);
            uint _1508 = _1497 << 2u;
            int _1509 = _1508 & 4092;
            float _1510 = float((uint)_1509);
            float _1511 = _1494 * _1500;
            float _1512 = _1495 * _1500;
            float _1513 = _1511 + _1510;
            float _1514 = _1512 + _1507;
            float _1517 = cb13_067x * _1513;
            float _1518 = cb13_067x * _1514;
            float _1521 = t9.SampleLevel(s10, float3(_1517, _1518, _1504), 0.0f);
            float _1523 = _1226 * 0.9900000095367432f;
            float _1524 = _1521.x - _1523;
            float _1525 = _1524 * 144.26950073242188f;
            float _1526 = exp2(_1525);
            float _1527 = saturate(_1526);
            _1529 = _1527;
          } else {
            _1529 = 1.0f;
          }
        } else {
          _1529 = 1.0f;
        }
        if (_1249) {
          int _1531 = _1247 & 2;
          bool _1532 = (_1531 != 0);
          int _1533 = _1247 & 8;
          bool _1534 = (_1533 == 0);
          if (_1532) {
            int _1536 = _1486 & 1023;
            _1542 = _1536;
            _1543 = 0;
          } else {
            int _1538 = _1486 & 255;
            int _1539 = (uint)(_1486) >> 8;
            int _1540 = _1539 & 3;
            _1542 = _1538;
            _1543 = _1540;
          }
          float _1544 = float((uint)_1542);
          float _1546 = floor(cb13_raw[_1244].y);
          float _1547 = _1546 + _1544;
          float4 _1551 = t42.SampleLevel(s10, float3(_1494, _1495, _1547), 0.0f);
          _38[0] = _1551.x;
          _38[1] = _1551.y;
          _38[2] = _1551.z;
          _38[3] = _1551.w;
          if (!_1534) {
            float _1561 = _1547 + 1.0f;
            float4 _1562 = t42.SampleLevel(s10, float3(_1494, _1495, _1561), 0.0f);
            float _1567 = frac(cb13_raw[_1244].y);
            float _1568 = _1562.x - _1551.x;
            float _1569 = _1562.y - _1551.y;
            float _1570 = _1562.z - _1551.z;
            float _1571 = _1562.w - _1551.w;
            float _1572 = _1568 * _1567;
            float _1573 = _1569 * _1567;
            float _1574 = _1570 * _1567;
            float _1575 = _1571 * _1567;
            float _1576 = _1572 + _1551.x;
            float _1577 = _1573 + _1551.y;
            float _1578 = _1574 + _1551.z;
            float _1579 = _1575 + _1551.w;
            _38[0] = _1576;
            _38[1] = _1577;
            _38[2] = _1578;
            _38[3] = _1579;
            _1581 = _1578;
            _1582 = _1577;
            _1583 = _1576;
          } else {
            _1581 = _1551.z;
            _1582 = _1551.y;
            _1583 = _1551.x;
          }
          if (!_1532) {
            float _1586 = _38[_1543];
            _1588 = _1586;
            _1589 = _1586;
            _1590 = _1586;
          } else {
            _1588 = _1583;
            _1589 = _1582;
            _1590 = _1581;
          }
          _1592 = _1529;
          _1593 = _1588;
          _1594 = _1589;
          _1595 = _1590;
        } else {
          _1592 = _1529;
          _1593 = 1.0f;
          _1594 = 1.0f;
          _1595 = 1.0f;
        }
      } else {
        _1592 = 1.0f;
        _1593 = 1.0f;
        _1594 = 1.0f;
        _1595 = 1.0f;
      }
      bool _1596 = _1243 && _1282;
      if (_1596) {
        float _1601 = t10.SampleLevel(s10, float4(_1211, _1212, _1213, (cb13_raw[_1240].y)), 0.0f);
        float _1603 = _1226 * 0.9900000095367432f;
        float _1604 = _1601.x - _1603;
        float _1605 = _1604 * 144.26950073242188f;
        float _1606 = exp2(_1605);
        float _1607 = saturate(_1606);
        float _1608 = _1607 * _1592;
        _1610 = _1608;
      } else {
        _1610 = _1592;
      }
      uint _1611 = _1205 + 70u;
      float _1614 = _1610 + -1.0f;
      float _1615 = (cb13_raw[_1611].w) * _1614;
      float _1616 = _1615 + 1.0f;
      int _1617 = _1235 & 2048;
      bool _1618 = (_1617 != 0);
      bool _1619 = (_688.z == 1.0f);
      bool _1620 = _1619 || _1618;
      if (_1620) {
        _1625 = cb12_071y;
      } else {
        _1625 = 0.0f;
      }
      int _1626 = _1235 & 4096;
      bool _1627 = (_1626 != 0);
      bool _1628 = !(_688.z == 1.0f);
      bool _1629 = _1628 || _1627;
      if (_1629) {
        _1634 = cb12_071z;
      } else {
        _1634 = 0.0f;
      }
      float _1635 = _1616 * _1280;
      float _1636 = _1635 * _1625;
      float _1637 = _1636 * _1634;
      float _1638 = _1637 * _1593;
      float _1639 = _1637 * _1594;
      float _1640 = _1637 * _1595;
      bool _1641 = (_1638 > 0.0f);
      bool _1642 = (_1639 > 0.0f);
      bool _1643 = (_1640 > 0.0f);
      bool _1644 = _1641 || _1642;
      bool _1645 = _1643 || _1644;
      [branch]
      if (_1645) {
        bool _1649 = (FrequentPixelConsts_256.x < 0.0f);
        if (!_1649) {
          _1654 = cb12_071x;
        } else {
          _1654 = 1.0f;
        }
        bool _1655 = ((int)_1235 < (int)0);
        float _1656 = select(_1655, _1654, 1.0f);
        float _1657 = _1656 * _1638;
        float _1658 = _1656 * _1639;
        float _1659 = _1656 * _1640;
        float _1660 = dot(float3(_1211, _1212, _1213), float3(_1211, _1212, _1213));
        float _1661 = rsqrt(_1660);
        float _1662 = _1661 * _1211;
        float _1663 = _1661 * _1212;
        float _1664 = _1661 * _1213;
        float _1665 = dot(float3(_615, _616, _617), float3(_1662, _1663, _1664));
        float _1666 = _1665 + 0.25f;
        float _1667 = _1666 * 0.800000011920929f;
        float _1668 = saturate(_1667);
        float _1669 = _1668 + _1665;
        float _1670 = _1668 + 1.0f;
        float _1671 = _1669 / _1670;
        float _1672 = 1.0f / _1670;
        float _1673 = saturate(_1671);
        bool _1674 = (_666 == 1);
        if (_1674) {
          float _1676 = saturate(_1665);
          bool _1677 = (_617 > 0.0f);
          int _1678 = (int)(uint)(_1677);
          int _1679 = _1678 << 1u;
          int _1680 = _1679 + -1;
          float _1681 = float((int)(_1680));
          float _1682 = _1681 + _617;
          float _1683 = -1.0f / _1682;
          float _1684 = _615 * _616;
          float _1685 = _1684 * _1683;
          float _1686 = _615 * _615;
          float _1687 = _1686 * _1681;
          float _1688 = _1687 * _1683;
          float _1689 = _1688 + 1.0f;
          float _1690 = _1685 * _1681;
          int _1691 = 1 - _1679;
          float _1692 = float((int)(_1691));
          float _1693 = _1692 * _615;
          float _1694 = _616 * _616;
          float _1695 = _1694 * _1683;
          float _1696 = _1695 + _1681;
          float _1697 = -0.0f - _616;
          float _1698 = dot(float3(_1662, _1663, _1664), float3(_1662, _1663, _1664));
          float _1699 = rsqrt(_1698);
          float _1700 = _1699 * _1662;
          float _1701 = _1699 * _1663;
          float _1702 = _1699 * _1664;
          float _1703 = _1700 * _1689;
          float _1704 = mad(_1690, _1701, _1703);
          float _1705 = mad(_1693, _1702, _1704);
          float _1706 = _1700 * _1685;
          float _1707 = mad(_1696, _1701, _1706);
          float _1708 = mad(_1697, _1702, _1707);
          float _1709 = _1700 * _615;
          float _1710 = mad(_616, _1701, _1709);
          float _1711 = mad(_617, _1702, _1710);
          float _1712 = dot(float3(_1705, _1708, _1711), float3(_1705, _1708, _1711));
          float _1713 = rsqrt(_1712);
          float _1714 = _1713 * _1705;
          float _1715 = _1713 * _1708;
          float _1716 = _1713 * _1711;
          float _1717 = dot(float3(_684, _685, _686), float3(_684, _685, _686));
          float _1718 = rsqrt(_1717);
          float _1719 = _1718 * _684;
          float _1720 = _1718 * _685;
          float _1721 = _1718 * _686;
          float _1722 = _1719 * _1689;
          float _1723 = mad(_1690, _1720, _1722);
          float _1724 = mad(_1693, _1721, _1723);
          float _1725 = _1719 * _1685;
          float _1726 = mad(_1696, _1720, _1725);
          float _1727 = mad(_1697, _1721, _1726);
          float _1728 = _1719 * _615;
          float _1729 = mad(_616, _1720, _1728);
          float _1730 = mad(_617, _1721, _1729);
          float _1731 = dot(float3(_1724, _1727, _1730), float3(_1724, _1727, _1730));
          float _1732 = rsqrt(_1731);
          float _1733 = _1732 * _1724;
          float _1734 = _1732 * _1727;
          float _1735 = _1732 * _1730;
          float _1736 = dot(float3(_1714, _1715, _1716), float3(_1733, _1734, _1735));
          float _1737 = _1735 * _1716;
          float _1738 = _1736 - _1737;
          bool _1739 = (_1738 > 0.0f);
          if (_1739) {
            float _1741 = max(_1716, _1735);
            float _1742 = _1738 / _1741;
            _1744 = _1742;
          } else {
            _1744 = _1738;
          }
          float _1745 = _1744 * 0.20908956229686737f;
          float _1746 = _1745 + 0.25813528895378113f;
          float _1747 = _1746 * _598;
          float _1748 = _1746 * _599;
          float _1749 = _1746 * _600;
          float _1750 = 1.0f - _1735;
          float _1751 = _1750 * 0.07144299894571304f;
          float _1752 = _1751 + -0.332181453704834f;
          float _1753 = _1752 * _1750;
          float _1754 = _1753 + 0.4918818771839142f;
          float _1755 = _1754 * _1750;
          float _1756 = _1755 + 0.05710852891206741f;
          float _1757 = _1750 * 0.6568742394447327f;
          float _1758 = _1757 * _1756;
          float _1759 = 1.0f - _1716;
          float _1760 = _1759 * 0.07144299894571304f;
          float _1761 = _1760 + -0.332181453704834f;
          float _1762 = _1761 * _1759;
          float _1763 = _1762 + 0.4918818771839142f;
          float _1764 = _1763 * _1759;
          float _1765 = _1764 + 0.05710852891206741f;
          float _1766 = _1759 * 0.6568742394447327f;
          float _1767 = _1766 * _1765;
          float _1768 = _598 * _598;
          float _1769 = _599 * _599;
          float _1770 = _600 * _600;
          float _1771 = _1768 * 0.8585715889930725f;
          float _1772 = _1769 * 0.8585715889930725f;
          float _1773 = _1770 * 0.8585715889930725f;
          float _1774 = _598 * 0.1414284110069275f;
          float _1775 = _599 * 0.1414284110069275f;
          float _1776 = _600 * 0.1414284110069275f;
          float _1777 = 1.0f - _1774;
          float _1778 = 1.0f - _1775;
          float _1779 = 1.0f - _1776;
          float _1780 = _1771 / _1777;
          float _1781 = _1772 / _1778;
          float _1782 = _1773 / _1779;
          float _1783 = 0.1890440583229065f - _1758;
          float _1784 = max(1.0000000116860974e-07f, _1783);
          float _1785 = 0.1890440583229065f - _1767;
          float _1786 = max(1.0000000116860974e-07f, _1785);
          float _1787 = _1784 * 2.250678300857544f;
          float _1788 = _1787 * _1786;
          float _1789 = _1788 * _1780;
          float _1790 = _1788 * _1781;
          float _1791 = _1788 * _1782;
          float _1792 = _1789 + _1747;
          float _1793 = _1790 + _1748;
          float _1794 = _1791 + _1749;
          float _1795 = _1792 * _1676;
          float _1796 = _1793 * _1676;
          float _1797 = _1794 * _1676;
          float _1798 = _1673 - _1676;
          float _1799 = max(0.0f, _1798);
          float _1800 = _1799 * 0.31830987334251404f;
          float _1801 = _1800 * _598;
          float _1802 = _1800 * _599;
          float _1803 = _1800 * _600;
          float _1804 = _1795 + _1801;
          float _1805 = _1796 + _1802;
          float _1806 = _1797 + _1803;
          _1808 = _1804;
          _1809 = _1805;
          _1810 = _1806;
        } else {
          _1808 = _1673;
          _1809 = _1673;
          _1810 = _1673;
        }
        bool _1813 = (cb12_221x > 0.0f);
        float _1814 = 1.0f - _610;
        float _1815 = 1.0f - _611;
        float _1816 = 1.0f - _612;
        if (_1813) {
          float _1818 = dot(float3(_615, _616, _617), float3(_684, _685, _686));
          float4 _1821 = t43.SampleLevel(s10, float2(0.8999999761581421f, _1818), 0.0f);
          float _1824 = _1821.x * _610;
          float _1825 = _1821.x * _611;
          float _1826 = _1821.x * _612;
          float _1827 = _1824 + _1821.y;
          float _1828 = _1825 + _1821.y;
          float _1829 = _1826 + _1821.y;
          float _1830 = _1814 * 0.0476190485060215f;
          float _1831 = _1815 * 0.0476190485060215f;
          float _1832 = _1816 * 0.0476190485060215f;
          float _1833 = _1830 + _610;
          float _1834 = _1831 + _611;
          float _1835 = _1832 + _612;
          float _1836 = 1.0f - _1827;
          float _1837 = 1.0f - _1828;
          float _1838 = 1.0f - _1829;
          float _1839 = _1836 * _1833;
          float _1840 = _1837 * _1834;
          float _1841 = _1838 * _1835;
          float _1842 = 1.0f - _1839;
          float _1843 = 1.0f - _1840;
          float _1844 = 1.0f - _1841;
          float _1845 = max(_1842, 0.0010000000474974513f);
          float _1846 = max(_1843, 0.0010000000474974513f);
          float _1847 = max(_1844, 0.0010000000474974513f);
          float _1848 = _1827 / _1845;
          float _1849 = _1828 / _1846;
          float _1850 = _1829 / _1847;
          float _1851 = min(_1848, 1.0f);
          float _1852 = min(_1849, 1.0f);
          float _1853 = min(_1850, 1.0f);
          _1889 = _1851;
          _1890 = _1852;
          _1891 = _1853;
        } else {
          float _1855 = _1662 + _684;
          float _1856 = _1663 + _685;
          float _1857 = _1664 + _686;
          float _1858 = dot(float3(_1855, _1856, _1857), float3(_1855, _1856, _1857));
          float _1859 = rsqrt(_1858);
          float _1860 = _1859 * _1855;
          float _1861 = _1859 * _1856;
          float _1862 = _1859 * _1857;
          float _1863 = dot(float3(_1860, _1861, _1862), float3(_684, _685, _686));
          float _1864 = abs(_1863);
          float _1865 = 1.0f - _1864;
          float _1866 = saturate(_1865);
          float _1867 = _1866 * _1866;
          float _1871 = max(0.0f, _1814);
          float _1872 = max(0.0f, _1815);
          float _1873 = max(0.0f, _1816);
          float _1874 = _1867 * _1867;
          float _1875 = _1874 * _1866;
          float _1876 = _1875 * cb13_066x;
          float _1877 = _1876 * _1871;
          float _1878 = _1876 * _1872;
          float _1879 = _1876 * _1873;
          float _1880 = cb13_066z * 0.8999999761581421f;
          float _1881 = _1880 + 1.0f;
          float _1882 = _1877 / _1881;
          float _1883 = _1878 / _1881;
          float _1884 = _1879 / _1881;
          float _1885 = _1882 + _610;
          float _1886 = _1883 + _611;
          float _1887 = _1884 + _612;
          _1889 = _1885;
          _1890 = _1886;
          _1891 = _1887;
        }
        float _1892 = 1.0f - _1889;
        float _1893 = 1.0f - _1890;
        float _1894 = 1.0f - _1891;
        float _1895 = _1892 * _1808;
        float _1896 = _1893 * _1809;
        float _1897 = _1894 * _1810;
        int _1898 = _666 & -3;
        bool _1899 = (_1898 == 0);
        float _1900 = _1895 * 0.31830987334251404f;
        float _1901 = _1896 * 0.31830987334251404f;
        float _1902 = _1897 * 0.31830987334251404f;
        float _1903 = select(_1899, _1900, _1895);
        float _1904 = select(_1899, _1901, _1896);
        float _1905 = select(_1899, _1902, _1897);
        float _1909 = _1657 * (cb13_raw[_1232].x);
        float _1910 = _1909 * _1672;
        float _1911 = _1910 * _1903;
        float _1912 = _1658 * (cb13_raw[_1232].y);
        float _1913 = _1912 * _1672;
        float _1914 = _1913 * _1904;
        float _1915 = _1659 * (cb13_raw[_1232].z);
        float _1916 = _1915 * _1672;
        float _1917 = _1916 * _1905;
        float _1918 = _1911 + _1191;
        float _1919 = _1914 + _1192;
        float _1920 = _1917 + _1193;
        float _1921 = dot(float3(_1662, _1663, _1664), float3(_615, _616, _617));
        bool _1922 = (_1921 > 0.0f);
        [branch]
        if (_1922) {
          float _1924 = _1662 + _684;
          float _1925 = _1663 + _685;
          float _1926 = _1664 + _686;
          float _1927 = dot(float3(_1924, _1925, _1926), float3(_1924, _1925, _1926));
          float _1928 = rsqrt(_1927);
          float _1929 = _1928 * _1924;
          float _1930 = _1928 * _1925;
          float _1931 = _1928 * _1926;
          float _1932 = dot(float3(_615, _616, _617), float3(_684, _685, _686));
          float _1933 = saturate(_1665);
          float _1934 = dot(float3(_182, _183, _184), float3(_182, _183, _184));
          float _1935 = rsqrt(_1934);
          float _1936 = _1935 * _182;
          float _1937 = _1935 * _183;
          float _1938 = _1935 * _184;
          float _1939 = dot(float3(_1936, _1937, _1938), float3(_615, _616, _617));
          float _1940 = _1939 * _615;
          float _1941 = _1939 * _616;
          float _1942 = _1939 * _617;
          float _1943 = _1936 - _1940;
          float _1944 = _1937 - _1941;
          float _1945 = _1938 - _1942;
          float _1946 = dot(float3(_1943, _1944, _1945), float3(_1943, _1944, _1945));
          float _1947 = rsqrt(_1946);
          float _1948 = _1943 * _1947;
          float _1949 = _1944 * _1947;
          float _1950 = _1945 * _1947;
          float _1951 = _1949 * _617;
          float _1952 = _1950 * _616;
          float _1953 = _1951 - _1952;
          float _1954 = _1950 * _615;
          float _1955 = _1948 * _617;
          float _1956 = _1954 - _1955;
          float _1957 = _1948 * _616;
          float _1958 = _1949 * _615;
          float _1959 = _1957 - _1958;
          float _1960 = dot(float3(_1953, _1956, _1959), float3(_1953, _1956, _1959));
          float _1961 = rsqrt(_1960);
          float _1962 = _1953 * _1961;
          float _1963 = _1956 * _1961;
          float _1964 = _1959 * _1961;
          float _1965 = dot(float3(_1948, _1949, _1950), float3(_1929, _1930, _1931));
          float _1966 = _1965 * 1.2345679998397827f;
          float _1967 = _1966 * _1966;
          float _1968 = dot(float3(_1962, _1963, _1964), float3(_1929, _1930, _1931));
          float _1969 = _1968 * 1.2345679998397827f;
          float _1970 = _1969 * _1969;
          float _1971 = dot(float3(_615, _616, _617), float3(_1929, _1930, _1931));
          float _1972 = saturate(_1971);
          float _1973 = _1972 * _1972;
          float _1974 = _1970 + _1967;
          float _1975 = _1974 + _1973;
          float _1976 = _1975 * _1975;
          float _1977 = 0.4851658046245575f / _1976;
          float _1978 = abs(_1932);
          float _1979 = dot(float3(_1929, _1930, _1931), float3(_684, _685, _686));
          float _1980 = abs(_1979);
          float _1981 = 1.0f - _1980;
          float _1982 = saturate(_1981);
          float _1983 = _1982 * _1982;
          float _1987 = max(0.0f, _1814);
          float _1988 = max(0.0f, _1815);
          float _1989 = max(0.0f, _1816);
          float _1990 = _1983 * _1983;
          float _1991 = _1990 * _1982;
          float _1992 = _1991 * cb13_066x;
          float _1993 = _1992 * _1987;
          float _1994 = _1992 * _1988;
          float _1995 = _1992 * _1989;
          float _1996 = cb13_066z * 0.8999999761581421f;
          float _1997 = _1996 + 1.0f;
          float _1998 = _1993 / _1997;
          float _1999 = _1994 / _1997;
          float _2000 = _1995 / _1997;
          float _2001 = _1998 + _610;
          float _2002 = _1999 + _611;
          float _2003 = _2000 + _612;
          bool _2005 = (cb12_221z > 0.0f);
          [branch]
          if (_2005) {
            float _2007 = saturate(_1932);
            float _2008 = _2007 + _1933;
            float _2009 = _1933 * 2.0f;
            float _2010 = _2009 * _2007;
            float _2011 = _2008 - _2010;
            float _2012 = _2011 * 0.809999942779541f;
            float _2013 = _2012 + _2010;
            _2028 = _2013;
          } else {
            float _2015 = _1978 * _1978;
            float _2016 = _2015 * 0.34390008449554443f;
            float _2017 = _2016 + 0.6560999155044556f;
            float _2018 = sqrt(_2017);
            float _2019 = _2018 * _1933;
            float _2020 = _1933 * _1933;
            float _2021 = _2020 * 0.34390008449554443f;
            float _2022 = _2021 + 0.6560999155044556f;
            float _2023 = sqrt(_2022);
            float _2024 = _2023 * _1978;
            float _2025 = _2019 + 9.999999747378752e-05f;
            float _2026 = _2025 + _2024;
            _2028 = _2026;
          }
          float _2029 = 0.5f / _2028;
          float _2030 = _2029 * _1977;
          float _2031 = _2030 * _2001;
          float _2032 = _2030 * _2002;
          float _2033 = _2030 * _2003;
          bool _2035 = (cb12_221y > 0.0f);
          if (_2035) {
            float _2037 = dot(float3(_615, _616, _617), float3(_2029, _2029, _2029));
            float4 _2040 = t43.SampleLevel(s10, float2(0.8999999761581421f, _2037), 0.0f);
            float _2043 = _2040.x * _610;
            float _2044 = _2040.x * _611;
            float _2045 = _2040.x * _612;
            float _2046 = _2043 + _2040.y;
            float _2047 = _2044 + _2040.y;
            float _2048 = _2045 + _2040.y;
            float _2049 = _1814 * 0.0476190485060215f;
            float _2050 = _1815 * 0.0476190485060215f;
            float _2051 = _1816 * 0.0476190485060215f;
            float _2052 = _2049 + _610;
            float _2053 = _2050 + _611;
            float _2054 = _2051 + _612;
            float _2055 = 1.0f - _2046;
            float _2056 = 1.0f - _2047;
            float _2057 = 1.0f - _2048;
            float _2058 = _2055 * _2052;
            float _2059 = _2056 * _2053;
            float _2060 = _2057 * _2054;
            float _2061 = 1.0f - _2058;
            float _2062 = 1.0f - _2059;
            float _2063 = 1.0f - _2060;
            float _2064 = max(_2061, 0.0010000000474974513f);
            float _2065 = max(_2062, 0.0010000000474974513f);
            float _2066 = max(_2063, 0.0010000000474974513f);
            float _2067 = _2046 / _2064;
            float _2068 = _2047 / _2065;
            float _2069 = _2048 / _2066;
            float _2070 = min(_2067, 1.0f);
            float _2071 = min(_2068, 1.0f);
            float _2072 = min(_2069, 1.0f);
            float _2073 = max(_2046, 9.999999747378752e-05f);
            float _2074 = max(_2047, 9.999999747378752e-05f);
            float _2075 = max(_2048, 9.999999747378752e-05f);
            float _2076 = _2070 / _2073;
            float _2077 = _2071 / _2074;
            float _2078 = _2072 / _2075;
            float _2079 = _2076 * _2031;
            float _2080 = _2077 * _2032;
            float _2081 = _2078 * _2033;
            _2083 = _2079;
            _2084 = _2080;
            _2085 = _2081;
          } else {
            _2083 = _2031;
            _2084 = _2032;
            _2085 = _2033;
          }
          float _2086 = _2083 * _1933;
          float _2087 = _2084 * _1933;
          float _2088 = _2085 * _1933;
          _2090 = _2086;
          _2091 = _2087;
          _2092 = _2088;
        } else {
          _2090 = 0.0f;
          _2091 = 0.0f;
          _2092 = 0.0f;
        }
        float _2093 = _1909 * _2090;
        float _2094 = _1912 * _2091;
        float _2095 = _1915 * _2092;
        float _2096 = _2093 + _1194;
        float _2097 = _2094 + _1195;
        float _2098 = _2095 + _1196;
        _2100 = _1918;
        _2101 = _1919;
        _2102 = _1920;
        _2103 = _2096;
        _2104 = _2097;
        _2105 = _2098;
      } else {
        _2100 = _1191;
        _2101 = _1192;
        _2102 = _1193;
        _2103 = _1194;
        _2104 = _1195;
        _2105 = _1196;
      }
      int _2106 = _1197 + 1;
      bool _2107 = ((int)_2106 < (int)256);
      if (_2107) {
        _1191 = _2100;
        _1192 = _2101;
        _1193 = _2102;
        _1194 = _2103;
        _1195 = _2104;
        _1196 = _2105;
        _1197 = _2106;
        continue;
      } else {
        _2109 = _2100;
        _2110 = _2101;
        _2111 = _2102;
        _2112 = _2103;
        _2113 = _2104;
        _2114 = _2105;
      }
    } else {
      _2109 = _1191;
      _2110 = _1192;
      _2111 = _1193;
      _2112 = _1194;
      _2113 = _1195;
      _2114 = _1196;
    }
    break;
  }
  float _2115 = -0.0f - _684;
  float _2116 = -0.0f - _685;
  float _2117 = -0.0f - _686;
  float _2118 = dot(float3(_2115, _2116, _2117), float3(_615, _616, _617));
  float _2119 = _2118 * 2.0f;
  float _2120 = _2119 * _615;
  float _2121 = _2119 * _616;
  float _2122 = _2119 * _617;
  float _2123 = _2115 - _2120;
  float _2124 = _2116 - _2121;
  float _2125 = _2117 - _2122;
  float _2126 = dot(float3(_2123, _2124, _2125), float3(_2123, _2124, _2125));
  float _2127 = rsqrt(_2126);
  float _2128 = _2123 * _2127;
  float _2129 = _2124 * _2127;
  float _2130 = _2125 * _2127;
  float _2131 = ddx_coarse(_2128);
  float _2132 = ddx_coarse(_2129);
  float _2133 = ddx_coarse(_2130);
  float _2134 = ddy_coarse(_2128);
  float _2135 = ddy_coarse(_2129);
  float _2136 = ddy_coarse(_2130);
  int _2137 = _657 & 1;
  bool _2138 = (_2137 != 0);
  float _2139 = -0.0f - _2131;
  float _2140 = -0.0f - _2132;
  float _2141 = -0.0f - _2133;
  float _2142 = select(_2138, _2139, _2131);
  float _2143 = select(_2138, _2140, _2132);
  float _2144 = select(_2138, _2141, _2133);
  int _2145 = _658 & 1;
  bool _2146 = (_2145 != 0);
  float _2147 = -0.0f - _2134;
  float _2148 = -0.0f - _2135;
  float _2149 = -0.0f - _2136;
  float _2150 = select(_2146, _2147, _2134);
  float _2151 = select(_2146, _2148, _2135);
  float _2152 = select(_2146, _2149, _2136);
  float _2153 = _2150 + _2128;
  float _2154 = _2151 + _2129;
  float _2155 = _2152 + _2130;
  float _2156 = dot(float3(_2153, _2154, _2155), float3(_2153, _2154, _2155));
  float _2157 = rsqrt(_2156);
  float _2158 = _2157 * _2153;
  float _2159 = _2157 * _2154;
  float _2160 = _2155 * _2157;
  float _2161 = dot(float3(_2128, _2129, _2130), float3(_2158, _2159, _2160));
  float _2162 = acos(_2161);
  float _2163 = _2162 * 81.4873275756836f;
  float _2164 = log2(_2163);
  float _2165 = max(0.0f, _2164);
  float _2166 = _2142 + _2128;
  float _2167 = _2143 + _2129;
  float _2168 = _2144 + _2130;
  float _2169 = dot(float3(_2166, _2167, _2168), float3(_2166, _2167, _2168));
  float _2170 = rsqrt(_2169);
  float _2171 = _2170 * _2166;
  float _2172 = _2170 * _2167;
  float _2173 = _2170 * _2168;
  float _2174 = dot(float3(_2128, _2129, _2130), float3(_2171, _2172, _2173));
  float _2175 = acos(_2174);
  float _2176 = _2175 * 81.4873275756836f;
  float _2177 = log2(_2176);
  float _2178 = max(0.0f, _2177);
  float _2179 = max(_2178, _2165);
  float _2180 = _2179 * 0.625f;
  float _2181 = max(8.504999160766602f, _2180);
  float _2182 = max(_2181, 0.0f);
  float _2183 = min(_2182, 5.0f);
  bool _2184 = (_617 < 0.0f);
  float _2185 = _615 * 0.5f;
  float _2186 = _616 * -0.5f;
  float _2187 = 1.0f - _617;
  float _2188 = 1.0f / _2187;
  float _2189 = max(_2188, -3.4028234663852886e+38f);
  float _2190 = min(_2189, 3.4028234663852886e+38f);
  float _2191 = _2185 * _2190;
  float _2192 = _2186 * _2190;
  float _2193 = _615 * -0.5f;
  float _2194 = _616 * 0.5f;
  float _2195 = _617 + 1.0f;
  float _2196 = 1.0f / _2195;
  float _2197 = max(_2196, -3.4028234663852886e+38f);
  float _2198 = min(_2197, 3.4028234663852886e+38f);
  float _2199 = _2193 * _2198;
  float _2200 = _2194 * _2198;
  float _2201 = select(_2184, _2191, _2199);
  float _2202 = _2201 + 0.5f;
  float _2203 = select(_2184, _2192, _2200);
  float _2204 = _2203 + 0.5f;
  float _2205 = float((bool)_2184);
  if (_661) {
    float _2207 = _2202 * 0.9696969985961914f;
    float _2208 = _2204 * 0.9696969985961914f;
    float _2209 = _2208 + 0.01515151560306549f;
    float _2210 = _2205 + 0.01515151560306549f;
    float _2211 = _2210 + _2207;
    _2219 = _2211;
    _2220 = _2209;
  } else {
    float _2213 = _2202 * 0.6666666269302368f;
    float _2214 = _2204 * 0.6666666269302368f;
    float _2215 = _2214 + 0.1666666716337204f;
    float _2216 = _2205 + 0.1666666716337204f;
    float _2217 = _2216 + _2213;
    _2219 = _2217;
    _2220 = _2215;
  }
  float _2221 = _2219 * 0.5f;
  _2223 = 1;
  _2224 = 0.0f;
  _2225 = 0.0f;
  _2226 = 0.0f;
  _2227 = 0.0f;
  _2228 = 0.0f;
  _2229 = 0.0f;
  _2230 = 9.999999747378752e-06f;
  while(true) {
    int _2231 = _2223 * 12;
    int _2232 = _2231 + 102;
    int _2237 = _2231 + 103;
    int _2242 = _2231 + 104;
    int _2247 = _2231 + 105;
    float _2252 = (cb12_raw[_2232].x) * _75;
    float _2253 = mad((cb12_raw[_2237].x), _76, _2252);
    float _2254 = mad((cb12_raw[_2242].x), _77, _2253);
    float _2255 = _2254 + (cb12_raw[_2247].x);
    float _2256 = (cb12_raw[_2232].y) * _75;
    float _2257 = mad((cb12_raw[_2237].y), _76, _2256);
    float _2258 = mad((cb12_raw[_2242].y), _77, _2257);
    float _2259 = _2258 + (cb12_raw[_2247].y);
    float _2260 = (cb12_raw[_2232].z) * _75;
    float _2261 = mad((cb12_raw[_2237].z), _76, _2260);
    float _2262 = mad((cb12_raw[_2242].z), _77, _2261);
    float _2263 = _2262 + (cb12_raw[_2247].z);
    float _2264 = abs(_2255);
    float _2265 = abs(_2259);
    float _2266 = abs(_2263);
    float _2267 = 1.0f - _2264;
    float _2268 = 1.0f - _2265;
    float _2269 = 1.0f - _2266;
    int _2270 = _2231 + 106;
    int _2273 = asint((cb12_raw[_2270].y));
    bool _2274 = !(_688.z == -1.0f);
    [branch]
    if (_2274) {
      int _2276 = _2273 & 1;
      bool _2277 = (_2276 != 0);
      float _2278 = select(_2277, 1.0f, _688.z);
      int _2279 = _2273 & 2;
      bool _2280 = (_2279 != 0);
      float _2281 = 1.0f - _688.z;
      float _2282 = select(_2280, 1.0f, _2281);
      float _2283 = _2278 * _2282;
      _2285 = _2283;
    } else {
      _2285 = 1.0f;
    }
    bool _2286 = (_2267 > 0.0f);
    bool _2287 = (_2268 > 0.0f);
    bool _2288 = (_2269 > 0.0f);
    bool _2289 = _2286 && _2287;
    bool _2290 = _2289 && _2288;
    bool _2291 = (_2285 > 0.0f);
    bool _2292 = _2290 && _2291;
    if (_2292) {
      int _2294 = _2231 + 101;
      float _2299 = (cb12_raw[_2294].x) * _2267;
      float _2300 = (cb12_raw[_2294].y) * _2268;
      float _2301 = (cb12_raw[_2294].z) * _2269;
      float _2302 = saturate(_2299);
      float _2303 = saturate(_2300);
      float _2304 = saturate(_2301);
      float _2305 = 1.0f - _2230;
      float _2306 = _2285 * _2305;
      int _2307 = _2231 + 100;
      float _2310 = _2306 * _2302;
      float _2311 = _2310 * _2303;
      float _2312 = _2311 * _2304;
      float _2313 = _2312 * (cb12_raw[_2307].x);
      float _2314 = _2313 + _2230;
      float _2316 = _2313 * (cb12_raw[_2270].x);
      int _2317 = _2231 + 111;
      float _2320 = float((int)(asint(cb12_raw[_2317].x)));
      float _2321 = _2320 + _2220;
      float _2322 = _2321 * 0.1428571492433548f;
      if (_661) {
        float4 _2326 = t27.SampleLevel(s11, float2(_2221, _2322), 0.0f);
        float _2330 = _2326.x * _2313;
        float _2331 = _2326.y * _2313;
        float _2332 = _2326.z * _2313;
        _2343 = _2330;
        _2344 = _2331;
        _2345 = _2332;
      } else {
        float4 _2335 = t22.SampleLevel(s11, float2(_2221, _2322), 0.0f);
        float _2339 = _2335.x * _2316;
        float _2340 = _2335.y * _2316;
        float _2341 = _2335.z * _2316;
        _2343 = _2339;
        _2344 = _2340;
        _2345 = _2341;
      }
      float _2346 = _2343 + _2229;
      float _2347 = _2344 + _2228;
      float _2348 = _2345 + _2227;
      int _2352 = _2231 + 107;
      int _2357 = _2231 + 108;
      int _2362 = _2231 + 109;
      float _2367 = (cb12_raw[_2352].x) * _2123;
      float _2368 = mad((cb12_raw[_2357].x), _2124, _2367);
      float _2369 = mad((cb12_raw[_2362].x), _2125, _2368);
      float _2370 = (cb12_raw[_2352].y) * _2123;
      float _2371 = mad((cb12_raw[_2357].y), _2124, _2370);
      float _2372 = mad((cb12_raw[_2362].y), _2125, _2371);
      float _2373 = (cb12_raw[_2352].z) * _2123;
      float _2374 = mad((cb12_raw[_2357].z), _2124, _2373);
      float _2375 = mad((cb12_raw[_2362].z), _2125, _2374);
      int _2376 = _2231 + 110;
      float _2381 = (cb12_raw[_2352].x) * _75;
      float _2382 = mad((cb12_raw[_2357].x), _76, _2381);
      float _2383 = mad((cb12_raw[_2362].x), _77, _2382);
      float _2384 = _2383 + (cb12_raw[_2376].x);
      float _2385 = (cb12_raw[_2352].y) * _75;
      float _2386 = mad((cb12_raw[_2357].y), _76, _2385);
      float _2387 = mad((cb12_raw[_2362].y), _77, _2386);
      float _2388 = _2387 + (cb12_raw[_2376].y);
      float _2389 = (cb12_raw[_2352].z) * _75;
      float _2390 = mad((cb12_raw[_2357].z), _76, _2389);
      float _2391 = mad((cb12_raw[_2362].z), _77, _2390);
      float _2392 = _2391 + (cb12_raw[_2376].z);
      float _2393 = 1.0f / _2369;
      float _2394 = 1.0f / _2372;
      float _2395 = 1.0f / _2375;
      float _2396 = _2393 * _2384;
      float _2397 = _2394 * _2388;
      float _2398 = _2395 * _2392;
      float _2399 = _2393 - _2396;
      float _2400 = _2394 - _2397;
      float _2401 = _2395 - _2398;
      float _2402 = -0.0f - _2393;
      float _2403 = -0.0f - _2394;
      float _2404 = -0.0f - _2395;
      float _2405 = _2402 - _2396;
      float _2406 = _2403 - _2397;
      float _2407 = _2404 - _2398;
      float _2408 = max(_2399, _2405);
      float _2409 = max(_2400, _2406);
      float _2410 = max(_2401, _2407);
      float _2411 = min(_2409, _2410);
      float _2412 = min(_2408, _2411);
      float _2413 = _2412 * _2123;
      float _2414 = _2412 * _2124;
      float _2415 = _2412 * _2125;
      float _2416 = _75 - (cb12_raw[_2307].y);
      float _2417 = _2413 + _2416;
      float _2418 = _76 - (cb12_raw[_2307].z);
      float _2419 = _2414 + _2418;
      float _2420 = _77 - (cb12_raw[_2307].w);
      float _2421 = _2415 + _2420;
      float _2422 = dot(float3(_2417, _2419, _2421), float3(_2417, _2419, _2421));
      float _2423 = rsqrt(_2422);
      float _2424 = _2417 * _2423;
      float _2425 = _2419 * _2423;
      float _2426 = _2421 * _2423;
      bool _2427 = (_2426 < 0.0f);
      float _2428 = _2424 * 0.5f;
      float _2429 = _2425 * -0.5f;
      float _2430 = 1.0f - _2426;
      float _2431 = 1.0f / _2430;
      float _2432 = max(_2431, -3.4028234663852886e+38f);
      float _2433 = min(_2432, 3.4028234663852886e+38f);
      float _2434 = _2428 * _2433;
      float _2435 = _2429 * _2433;
      float _2436 = _2424 * -0.5f;
      float _2437 = _2425 * 0.5f;
      float _2438 = _2426 + 1.0f;
      float _2439 = 1.0f / _2438;
      float _2440 = max(_2439, -3.4028234663852886e+38f);
      float _2441 = min(_2440, 3.4028234663852886e+38f);
      float _2442 = _2436 * _2441;
      float _2443 = _2437 * _2441;
      float _2444 = select(_2427, _2434, _2442);
      float _2445 = _2444 + 0.5f;
      float _2446 = select(_2427, _2435, _2443);
      float _2447 = _2446 + 0.5f;
      float _2448 = _2445 * 0.6666666269302368f;
      float _2449 = _2447 * 0.6666666269302368f;
      float _2450 = float((bool)_2427);
      float _2451 = _2450 + 0.1666666716337204f;
      float _2452 = _2451 + _2448;
      float _2453 = _2320 + 0.1666666716337204f;
      float _2454 = _2453 + _2449;
      float _2455 = _2452 * 0.5f;
      float _2456 = _2454 * 0.1428571492433548f;
      float4 _2458 = t23.SampleLevel(s11, float2(_2455, _2456), _2183);
      float _2462 = _2458.x * _2316;
      float _2463 = _2458.y * _2316;
      float _2464 = _2458.z * _2316;
      float _2465 = _2462 + _2226;
      float _2466 = _2463 + _2225;
      float _2467 = _2464 + _2224;
      _2469 = _2314;
      _2470 = _2346;
      _2471 = _2347;
      _2472 = _2348;
      _2473 = _2465;
      _2474 = _2466;
      _2475 = _2467;
    } else {
      _2469 = _2230;
      _2470 = _2229;
      _2471 = _2228;
      _2472 = _2227;
      _2473 = _2226;
      _2474 = _2225;
      _2475 = _2224;
    }
    int _2476 = _2223 + 1;
    bool _2477 = ((uint)_2476 < (uint)7);
    _2478 = (_2469 < 0.9990000128746033f);
    bool _2479 = _2477 && _2478;
    if (_2479) {
      _2223 = _2476;
      _2224 = _2475;
      _2225 = _2474;
      _2226 = _2473;
      _2227 = _2472;
      _2228 = _2471;
      _2229 = _2470;
      _2230 = _2469;
      continue;
    }
    break;
  }
  [branch]
  if (_2478) {
    float _2482 = 1.0f - _2469;
    float _2485 = cb12_100x * _2482;
    float _2486 = _2485 + _2469;
    float _2489 = _2485 * cb12_106x;
    float _2492 = float((int)(cb12_111x));
    float _2493 = _2492 + _2220;
    float _2494 = _2493 * 0.1428571492433548f;
    if (_661) {
      float4 _2498 = t27.SampleLevel(s11, float2(_2221, _2494), 0.0f);
      float _2502 = _2498.x * _2485;
      float _2503 = _2498.y * _2485;
      float _2504 = _2498.z * _2485;
      _2515 = _2502;
      _2516 = _2503;
      _2517 = _2504;
    } else {
      float4 _2507 = t22.SampleLevel(s11, float2(_2221, _2494), 0.0f);
      float _2511 = _2507.x * _2489;
      float _2512 = _2507.y * _2489;
      float _2513 = _2507.z * _2489;
      _2515 = _2511;
      _2516 = _2512;
      _2517 = _2513;
    }
    float _2518 = _2515 + _2470;
    float _2519 = _2516 + _2471;
    float _2520 = _2517 + _2472;
    bool _2521 = (_2125 < 0.0f);
    float _2522 = _2123 * 0.5f;
    float _2523 = _2124 * -0.5f;
    float _2524 = 1.0f - _2125;
    float _2525 = 1.0f / _2524;
    float _2526 = max(_2525, -3.4028234663852886e+38f);
    float _2527 = min(_2526, 3.4028234663852886e+38f);
    float _2528 = _2522 * _2527;
    float _2529 = _2523 * _2527;
    float _2530 = _2123 * -0.5f;
    float _2531 = _2124 * 0.5f;
    float _2532 = _2125 + 1.0f;
    float _2533 = 1.0f / _2532;
    float _2534 = max(_2533, -3.4028234663852886e+38f);
    float _2535 = min(_2534, 3.4028234663852886e+38f);
    float _2536 = _2530 * _2535;
    float _2537 = _2531 * _2535;
    float _2538 = select(_2521, _2528, _2536);
    float _2539 = _2538 + 0.5f;
    float _2540 = select(_2521, _2529, _2537);
    float _2541 = _2540 + 0.5f;
    float _2542 = _2539 * 0.6666666269302368f;
    float _2543 = _2541 * 0.6666666269302368f;
    float _2544 = float((bool)_2521);
    float _2545 = _2544 + 0.1666666716337204f;
    float _2546 = _2545 + _2542;
    float _2547 = _2492 + 0.1666666716337204f;
    float _2548 = _2547 + _2543;
    float _2549 = _2546 * 0.5f;
    float _2550 = _2548 * 0.1428571492433548f;
    float4 _2552 = t23.SampleLevel(s11, float2(_2549, _2550), _2183);
    float _2556 = _2552.x * _2489;
    float _2557 = _2552.y * _2489;
    float _2558 = _2552.z * _2489;
    float _2559 = _2556 + _2473;
    float _2560 = _2557 + _2474;
    float _2561 = _2558 + _2475;
    _2563 = _2486;
    _2564 = _2518;
    _2565 = _2519;
    _2566 = _2520;
    _2567 = _2559;
    _2568 = _2560;
    _2569 = _2561;
  } else {
    _2563 = _2469;
    _2564 = _2470;
    _2565 = _2471;
    _2566 = _2472;
    _2567 = _2473;
    _2568 = _2474;
    _2569 = _2475;
  }
  float _2570 = 1.0f / _2563;
  float _2571 = _2570 * _2564;
  float _2572 = _2570 * _2565;
  float _2573 = _2570 * _2566;
  float _2574 = _2570 * _2567;
  float _2575 = _2570 * _2568;
  float _2576 = _2570 * _2569;
  bool _2579 = (cb12_074x > 0.0f);
  float _2580 = select(_2579, 0.0f, _2574);
  float _2581 = select(_2579, 0.0f, _2575);
  float _2582 = select(_2579, 0.0f, _2576);
  float _2585 = abs(FrequentPixelConsts_256.x);
  float _2589 = _2585 - FrequentPixelConsts_256.y;
  float _2590 = _2589 * _1187;
  float _2591 = _2589 * _1188;
  float _2592 = _2589 * _1189;
  float _2593 = _2590 + FrequentPixelConsts_256.y;
  float _2594 = _2591 + FrequentPixelConsts_256.y;
  float _2595 = _2592 + FrequentPixelConsts_256.y;
  float _2596 = FrequentPixelConsts_256.z - FrequentPixelConsts_256.w;
  float _2597 = _2596 * _1187;
  float _2598 = _2596 * _1188;
  float _2599 = _2596 * _1189;
  float _2600 = _2597 + FrequentPixelConsts_256.w;
  float _2601 = _2598 + FrequentPixelConsts_256.w;
  float _2602 = _2599 + FrequentPixelConsts_256.w;
  float _2603 = _2571 * _2593;
  float _2604 = _2572 * _2594;
  float _2605 = _2573 * _2595;
  float _2606 = _2600 * _2580;
  float _2607 = _2601 * _2581;
  float _2608 = _2602 * _2582;
  float _2612 = _75 - cb12_000x;
  float _2613 = _76 - cb12_000y;
  float _2614 = _2612 * _2612;
  float _2615 = _2613 * _2613;
  float _2616 = _2614 + _2615;
  float _2617 = sqrt(_2616);
  float _2620 = cb12_219x * _2617;
  float _2622 = _2620 + cb12_219y;
  float _2623 = saturate(_2622);
  float _2626 = cb12_185z + -1.0f;
  float _2627 = _2626 * _2623;
  float _2628 = _2627 + 1.0f;
  float _2634 = cb12_184x - cb12_184y;
  float _2635 = _2634 * _1187;
  float _2636 = _2634 * _1188;
  float _2637 = _2634 * _1189;
  float _2638 = _2635 + cb12_184y;
  float _2639 = _2636 + cb12_184y;
  float _2640 = _2637 + cb12_184y;
  if (!_2579) {
    float _2644 = cb12_185x - cb12_185y;
    float _2645 = _2644 * _1187;
    float _2646 = _2644 * _1188;
    float _2647 = _2644 * _1189;
    float _2648 = _2645 + cb12_185y;
    float _2649 = _2646 + cb12_185y;
    float _2650 = _2647 + cb12_185y;
    float _2651 = _2648 * _2628;
    float _2652 = _2649 * _2628;
    float _2653 = _2650 * _2628;
    _2655 = _2651;
    _2656 = _2652;
    _2657 = _2653;
  } else {
    _2655 = 1.0f;
    _2656 = 1.0f;
    _2657 = 1.0f;
  }
  float _2658 = dot(float3(_615, _616, _617), float3(_684, _685, _686));
  float _2659 = abs(_2658);
  float _2660 = max(_2659, _2659);
  float _2661 = abs(_2660);
  float _2662 = 1.0f - _2661;
  float _2663 = saturate(_2662);
  float _2664 = _2663 * _2663;
  float _2665 = _2664 * _2664;
  float _2666 = _2665 * _2663;
  float _2670 = min(0.25f, cb13_066y);
  float _2671 = 1.0f - _610;
  float _2672 = 1.0f - _611;
  float _2673 = 1.0f - _612;
  float _2674 = max(0.0f, _2671);
  float _2675 = max(0.0f, _2672);
  float _2676 = max(0.0f, _2673);
  float _2677 = _2666 * _2670;
  float _2678 = _2677 * _2674;
  float _2679 = _2677 * _2675;
  float _2680 = _2676 * _2677;
  float _2681 = cb13_066w * 0.8999999761581421f;
  float _2682 = _2681 + 1.0f;
  float _2683 = _2678 / _2682;
  float _2684 = _2679 / _2682;
  float _2685 = _2680 / _2682;
  float _2686 = _2671 - _2683;
  float _2687 = _2672 - _2684;
  float _2688 = _2673 - _2685;
  if (_661) {
    if (_663) {
      bool _2691 = (_617 > 0.0f);
      int _2692 = (int)(uint)(_2691);
      int _2693 = _2692 << 1u;
      int _2694 = _2693 + -1;
      float _2695 = float((int)(_2694));
      float _2696 = _2695 + _617;
      float _2697 = -1.0f / _2696;
      float _2698 = _615 * _616;
      float _2699 = _2698 * _2697;
      float _2700 = _615 * _615;
      float _2701 = _2700 * _2695;
      float _2702 = _2701 * _2697;
      float _2703 = _2702 + 1.0f;
      float _2704 = _2699 * _2695;
      int _2705 = 1 - _2693;
      float _2706 = float((int)(_2705));
      float _2707 = _2706 * _615;
      float _2708 = _616 * _616;
      float _2709 = _2708 * _2697;
      float _2710 = _2709 + _2695;
      float _2711 = -0.0f - _616;
      float _2712 = dot(float3(_684, _685, _686), float3(_684, _685, _686));
      float _2713 = rsqrt(_2712);
      float _2714 = _2713 * _684;
      float _2715 = _2713 * _685;
      float _2716 = _2713 * _686;
      float _2717 = _2714 * _2703;
      float _2718 = mad(_2704, _2715, _2717);
      float _2719 = mad(_2707, _2716, _2718);
      float _2720 = _2714 * _2699;
      float _2721 = mad(_2710, _2715, _2720);
      float _2722 = mad(_2711, _2716, _2721);
      float _2723 = _2714 * _615;
      float _2724 = mad(_616, _2715, _2723);
      float _2725 = mad(_617, _2716, _2724);
      float _2726 = dot(float3(_2719, _2722, _2725), float3(_2719, _2722, _2725));
      float _2727 = rsqrt(_2726);
      float _2728 = _2727 * _2725;
      float _2729 = 1.0f - _2728;
      float _2730 = _2729 * 0.07144299894571304f;
      float _2731 = _2730 + -0.332181453704834f;
      float _2732 = _2731 * _2729;
      float _2733 = _2732 + 0.4918818771839142f;
      float _2734 = _2733 * _2729;
      float _2735 = _2734 + 0.05710852891206741f;
      float _2736 = _2729 * 0.6568742394447327f;
      float _2737 = _2736 * _2735;
      float _2738 = _2737 + 0.8109559416770935f;
      float _2739 = _598 * _598;
      float _2740 = _599 * _599;
      float _2741 = _600 * _600;
      float _2742 = _2739 * 0.8585715889930725f;
      float _2743 = _2740 * 0.8585715889930725f;
      float _2744 = _2741 * 0.8585715889930725f;
      float _2745 = _598 * 0.1414284110069275f;
      float _2746 = _599 * 0.1414284110069275f;
      float _2747 = _600 * 0.1414284110069275f;
      float _2748 = 1.0f - _2745;
      float _2749 = 1.0f - _2746;
      float _2750 = 1.0f - _2747;
      float _2751 = _2742 / _2748;
      float _2752 = _2743 / _2749;
      float _2753 = _2744 / _2750;
      float _2754 = _2738 * _598;
      float _2755 = _2738 * _599;
      float _2756 = _2738 * _600;
      float _2757 = 0.1890440583229065f - _2737;
      float _2758 = _2757 * _2751;
      float _2759 = _2757 * _2752;
      float _2760 = _2757 * _2753;
      float _2761 = _2754 + _2758;
      float _2762 = _2755 + _2759;
      float _2763 = _2756 + _2760;
      float _2764 = _2686 * _2603;
      float _2765 = _2764 * _2761;
      float _2766 = _2687 * _2604;
      float _2767 = _2766 * _2762;
      float _2768 = _2688 * _2605;
      float _2769 = _2768 * _2763;
      _2788 = _2765;
      _2789 = _2767;
      _2790 = _2769;
    } else {
      float _2771 = _2686 * _2603;
      float _2772 = _2771 * _598;
      float _2773 = _2687 * _2604;
      float _2774 = _2773 * _599;
      float _2775 = _2688 * _2605;
      float _2776 = _2775 * _600;
      _2788 = _2772;
      _2789 = _2774;
      _2790 = _2776;
    }
  } else {
    float _2778 = _2686 * _2603;
    float _2779 = _2778 * _2628;
    float _2780 = _2779 * _2638;
    float _2781 = _2687 * _2604;
    float _2782 = _2781 * _2628;
    float _2783 = _2782 * _2639;
    float _2784 = _2688 * _2605;
    float _2785 = _2784 * _2628;
    float _2786 = _2785 * _2640;
    _2788 = _2780;
    _2789 = _2783;
    _2790 = _2786;
  }
  float _2791 = _2606 * _2655;
  float _2792 = _2607 * _2656;
  float _2793 = _2608 * _2657;
  float _2794 = _2683 + _610;
  float _2795 = _2684 + _611;
  float _2796 = _2685 + _612;
  float _2797 = _2791 * _2794;
  float _2798 = _2792 * _2795;
  float _2799 = _2793 * _2796;
  float4 _2801 = t17.Load(int3(_657, _658, 0));
  float _2805 = cb12_187x * _2801.x;
  float _2808 = _2805 + cb12_188x;
  float _2809 = saturate(_2808);
  float _2810 = _2809 + -1.0f;
  float _2811 = _2810 * 0.699999988079071f;
  float _2812 = _2811 + 1.0f;
  float _2813 = _2812 * _688.w;
  float _2816 = _2812 * cb12_069x;
  float _2818 = _2816 + cb12_069y;
  bool _2819 = (_688.z < 0.9900000095367432f);
  if (_2819) {
    _2824 = cb12_287w;
  } else {
    _2824 = 1.0f;
  }
  float _2827 = cb12_288x * _2824;
  float _2828 = log2(_2813);
  float _2829 = _2827 * _2828;
  float _2830 = exp2(_2829);
  if (_2819) {
    _2835 = cb12_287w;
  } else {
    _2835 = 1.0f;
  }
  float _2837 = _2828 * cb12_288y;
  float _2838 = _2837 * _2835;
  float _2839 = exp2(_2838);
  if (_2819) {
    _2844 = cb12_287w;
  } else {
    _2844 = 1.0f;
  }
  float _2846 = _2844 * cb12_288z;
  float _2847 = log2(_2818);
  float _2848 = _2846 * _2847;
  float _2849 = exp2(_2848);
  if (_2819) {
    _2854 = cb12_287w;
  } else {
    _2854 = 1.0f;
  }
  float _2856 = _2847 * cb12_288w;
  float _2857 = _2856 * _2854;
  float _2858 = exp2(_2857);
  float _2859 = (_2830 * _2788) * water_light.ambient.x;
  float _2860 = (_2830 * _2789) * water_light.ambient.y;
  float _2861 = (_2830 * _2790) * water_light.ambient.z;
  float _2862 = (_2797 * _2839) * water_light.ambient.x;
  float _2863 = (_2798 * _2839) * water_light.ambient.y;
  float _2864 = (_2799 * _2839) * water_light.ambient.z;
  float _2865 = _2849 * cb12_184z;
  float _2866 = _2865 * _2109;
  float _2867 = _2865 * _2110;
  float _2868 = _2865 * _2111;
  float _2869 = _2858 * cb12_184w;
  float _2870 = _2869 * _2112;
  float _2871 = _2869 * _2113;
  float _2872 = _2869 * _2114;
  bool _2873 = (_666 == 0);
  float _2874 = _2866 * _598;
  float _2875 = _2867 * _599;
  float _2876 = _2868 * _600;
  float _2877 = select(_2873, _2874, _2866);
  float _2878 = select(_2873, _2875, _2867);
  float _2879 = select(_2873, _2876, _2868);
  if (!_661) {
    float _2881 = _2859 * _598;
    float _2882 = _2860 * _599;
    float _2883 = _2861 * _600;
    _2885 = _2881;
    _2886 = _2882;
    _2887 = _2883;
  } else {
    _2885 = _2859;
    _2886 = _2860;
    _2887 = _2861;
  }
  float _2888 = _2870 + _2877;
  float _2889 = _2871 + _2878;
  float _2890 = _2872 + _2879;
  if (!_2579) {
    float _2892 = _2888 + _2862;
    float _2893 = _2889 + _2863;
    float _2894 = _2890 + _2864;
    _2896 = _2892;
    _2897 = _2893;
    _2898 = _2894;
  } else {
    _2896 = _2888;
    _2897 = _2889;
    _2898 = _2890;
  }
  float _2899 = _2887 + _2898;
  float _2900 = _2886 + _2897;
  float _2901 = _2885 + _2896;
  float _2902 = _460 * 0.5f;
  float _2903 = _461 * -0.5f;
  SV_Target.x = _2901;
  SV_Target.y = _2900;
  SV_Target.z = _2899;
  SV_Target.w = _654;
  SV_Target_1.x = _643;
  SV_Target_1.y = _644;
  SV_Target_1.z = _645;
  SV_Target_1.w = 0.8999999761581421f;
  SV_Target_2.x = _2902;
  SV_Target_2.y = _2903;
  SV_Target_2.z = _462;
  SV_Target_2.w = 1.0f;
  SV_Target_3.x = _656;
  SV_Target_3.y = 0.0f;
  SV_Target_3.z = 0.0f;
  SV_Target_3.w = _654;
  OutputSignature output_signature = { SV_Target, SV_Target_1, SV_Target_2, SV_Target_3 };
  return output_signature;
}
