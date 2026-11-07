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
  bool _2467;
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
  float _766;
  float _833;
  float _834;
  float _835;
  float _836;
  float _837;
  float _838;
  float _917;
  float _918;
  float _919;
  float _1095;
  float _1150;
  float _1151;
  float _1152;
  float _1157;
  float _1158;
  float _1159;
  float _1167;
  float _1168;
  float _1169;
  float _1170;
  float _1171;
  float _1172;
  float _1173;
  float _1174;
  float _1175;
  float _1180;
  float _1181;
  float _1182;
  float _1183;
  float _1184;
  float _1185;
  int _1186;
  float _1269;
  float _1381;
  float _1382;
  float _1383;
  float _1384;
  float _1464;
  float _1465;
  float _1466;
  float _1467;
  float _1471;
  float _1472;
  float _1473;
  float _1474;
  int _1475;
  float _1518;
  int _1531;
  int _1532;
  float _1570;
  float _1571;
  float _1572;
  float _1577;
  float _1578;
  float _1579;
  float _1581;
  float _1582;
  float _1583;
  float _1584;
  float _1599;
  float _1614;
  float _1623;
  float _1643;
  float _1733;
  float _1797;
  float _1798;
  float _1799;
  float _1878;
  float _1879;
  float _1880;
  float _2017;
  float _2072;
  float _2073;
  float _2074;
  float _2079;
  float _2080;
  float _2081;
  float _2089;
  float _2090;
  float _2091;
  float _2092;
  float _2093;
  float _2094;
  float _2098;
  float _2099;
  float _2100;
  float _2101;
  float _2102;
  float _2103;
  float _2208;
  float _2209;
  int _2212;
  float _2213;
  float _2214;
  float _2215;
  float _2216;
  float _2217;
  float _2218;
  float _2219;
  float _2274;
  float _2332;
  float _2333;
  float _2334;
  float _2458;
  float _2459;
  float _2460;
  float _2461;
  float _2462;
  float _2463;
  float _2464;
  float _2504;
  float _2505;
  float _2506;
  float _2552;
  float _2553;
  float _2554;
  float _2555;
  float _2556;
  float _2557;
  float _2558;
  float _2644;
  float _2645;
  float _2646;
  float _2777;
  float _2778;
  float _2779;
  float _2813;
  float _2824;
  float _2833;
  float _2843;
  float _2874;
  float _2875;
  float _2876;
  float _2885;
  float _2886;
  float _2887;
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
  uint _646 = uint(SV_Position.x);
  uint _647 = uint(SV_Position.y);
  bool _650 = (cb12_226x > 0.0f);
  bool _652 = (cb12_226y > 0.0f);
  int _655 = int(cb12_220y);
  int _656 = (uint)(_646) >> 4;
  int _657 = (uint)(_647) >> 4;
  int _660 = int(cb12_024x);
  uint _661 = _660 * _657;
  uint _662 = _661 + _656;
  uint _663 = _662 << 8u;
  float _668 = cb12_000x - _75;
  float _669 = cb12_000y - _76;
  float _670 = cb12_000z - _77;
  float _671 = dot(float3(_668, _669, _670), float3(_668, _669, _670));
  float _672 = rsqrt(_671);
  float _673 = _668 * _672;
  float _674 = _669 * _672;
  float _675 = _670 * _672;
  float4 _677 = t17.Load(int3(_646, _647, 0));
  GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
      float3(_75, _76, _77), float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
  // HairWorks keeps its native anisotropic lobes and ambient shadow weights.
  float graphics_sun_visibility = min(_677.y, GraphicsForwardContact(
      float3(_75, _76, _77), float3(_615, _616, _617), SV_Position.xy, true));
  bool _685 = (_677.y > 0.0f);
  if (_685) {
    float _687 = dot(float3(_615, _616, _617), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
    float _688 = _687 + 0.25f;
    float _689 = _688 * 0.800000011920929f;
    float _690 = saturate(_689);
    float _691 = _690 + _687;
    float _692 = _690 + 1.0f;
    float _693 = _691 / _692;
    float _694 = 1.0f / _692;
    float _695 = saturate(_693);
    bool _696 = (_655 == 1);
    if (_696) {
      float _698 = saturate(_687);
      bool _699 = (_617 > 0.0f);
      int _700 = (int)(uint)(_699);
      int _701 = _700 << 1u;
      int _702 = _701 + -1;
      float _703 = float((int)(_702));
      float _704 = _703 + _617;
      float _705 = -1.0f / _704;
      float _706 = _615 * _616;
      float _707 = _706 * _705;
      float _708 = _615 * _615;
      float _709 = _708 * _703;
      float _710 = _709 * _705;
      float _711 = _710 + 1.0f;
      float _712 = _707 * _703;
      int _713 = 1 - _701;
      float _714 = float((int)(_713));
      float _715 = _714 * _615;
      float _716 = _616 * _616;
      float _717 = _716 * _705;
      float _718 = _717 + _703;
      float _719 = -0.0f - _616;
      float _720 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
      float _721 = rsqrt(_720);
      float _722 = _721 * water_light.sun.x;
      float _723 = _721 * water_light.sun.y;
      float _724 = _721 * water_light.sun.z;
      float _725 = _722 * _711;
      float _726 = mad(_712, _723, _725);
      float _727 = mad(_715, _724, _726);
      float _728 = _722 * _707;
      float _729 = mad(_718, _723, _728);
      float _730 = mad(_719, _724, _729);
      float _731 = _722 * _615;
      float _732 = mad(_616, _723, _731);
      float _733 = mad(_617, _724, _732);
      float _734 = dot(float3(_727, _730, _733), float3(_727, _730, _733));
      float _735 = rsqrt(_734);
      float _736 = _735 * _727;
      float _737 = _735 * _730;
      float _738 = _735 * _733;
      float _739 = dot(float3(_673, _674, _675), float3(_673, _674, _675));
      float _740 = rsqrt(_739);
      float _741 = _740 * _673;
      float _742 = _740 * _674;
      float _743 = _740 * _675;
      float _744 = _741 * _711;
      float _745 = mad(_712, _742, _744);
      float _746 = mad(_715, _743, _745);
      float _747 = _741 * _707;
      float _748 = mad(_718, _742, _747);
      float _749 = mad(_719, _743, _748);
      float _750 = _741 * _615;
      float _751 = mad(_616, _742, _750);
      float _752 = mad(_617, _743, _751);
      float _753 = dot(float3(_746, _749, _752), float3(_746, _749, _752));
      float _754 = rsqrt(_753);
      float _755 = _754 * _746;
      float _756 = _754 * _749;
      float _757 = _754 * _752;
      float _758 = dot(float3(_736, _737, _738), float3(_755, _756, _757));
      float _759 = _757 * _738;
      float _760 = _758 - _759;
      bool _761 = (_760 > 0.0f);
      if (_761) {
        float _763 = max(_738, _757);
        float _764 = _760 / _763;
        _766 = _764;
      } else {
        _766 = _760;
      }
      float _767 = _766 * 0.20908956229686737f;
      float _768 = _767 + 0.25813528895378113f;
      float _769 = _768 * _598;
      float _770 = _768 * _599;
      float _771 = _768 * _600;
      float _772 = 1.0f - _757;
      float _773 = _772 * 0.07144299894571304f;
      float _774 = _773 + -0.332181453704834f;
      float _775 = _774 * _772;
      float _776 = _775 + 0.4918818771839142f;
      float _777 = _776 * _772;
      float _778 = _777 + 0.05710852891206741f;
      float _779 = _772 * 0.6568742394447327f;
      float _780 = _779 * _778;
      float _781 = 1.0f - _738;
      float _782 = _781 * 0.07144299894571304f;
      float _783 = _782 + -0.332181453704834f;
      float _784 = _783 * _781;
      float _785 = _784 + 0.4918818771839142f;
      float _786 = _785 * _781;
      float _787 = _786 + 0.05710852891206741f;
      float _788 = _781 * 0.6568742394447327f;
      float _789 = _788 * _787;
      float _790 = _598 * _598;
      float _791 = _599 * _599;
      float _792 = _600 * _600;
      float _793 = _790 * 0.8585715889930725f;
      float _794 = _791 * 0.8585715889930725f;
      float _795 = _792 * 0.8585715889930725f;
      float _796 = _598 * 0.1414284110069275f;
      float _797 = _599 * 0.1414284110069275f;
      float _798 = _600 * 0.1414284110069275f;
      float _799 = 1.0f - _796;
      float _800 = 1.0f - _797;
      float _801 = 1.0f - _798;
      float _802 = _793 / _799;
      float _803 = _794 / _800;
      float _804 = _795 / _801;
      float _805 = 0.1890440583229065f - _780;
      float _806 = max(1.0000000116860974e-07f, _805);
      float _807 = 0.1890440583229065f - _789;
      float _808 = max(1.0000000116860974e-07f, _807);
      float _809 = _806 * 2.250678300857544f;
      float _810 = _809 * _808;
      float _811 = _810 * _802;
      float _812 = _810 * _803;
      float _813 = _810 * _804;
      float _814 = _811 + _769;
      float _815 = _812 + _770;
      float _816 = _813 + _771;
      float _817 = _814 * _698;
      float _818 = _815 * _698;
      float _819 = _816 * _698;
      float _820 = _695 - _698;
      float _821 = max(0.0f, _820);
      float _822 = _821 * 0.31830987334251404f;
      float _823 = _822 * _598;
      float _824 = _822 * _599;
      float _825 = _822 * _600;
      float _826 = _817 + _823;
      float _827 = _818 + _824;
      float _828 = _819 + _825;
      float _829 = _826 * 3.1415927410125732f;
      float _830 = _827 * 3.1415927410125732f;
      float _831 = _828 * 3.1415927410125732f;
      _833 = _826;
      _834 = _827;
      _835 = _828;
      _836 = _829;
      _837 = _830;
      _838 = _831;
    } else {
      _833 = _695;
      _834 = _695;
      _835 = _695;
      _836 = _695;
      _837 = _695;
      _838 = _695;
    }
    bool _841 = (cb12_221x > 0.0f);
    float _842 = 1.0f - _610;
    float _843 = 1.0f - _611;
    float _844 = 1.0f - _612;
    if (_841) {
      float _846 = dot(float3(_615, _616, _617), float3(_673, _674, _675));
      float4 _849 = t43.SampleLevel(s10, float2(0.8999999761581421f, _846), 0.0f);
      float _852 = _849.x * _610;
      float _853 = _849.x * _611;
      float _854 = _849.x * _612;
      float _855 = _852 + _849.y;
      float _856 = _853 + _849.y;
      float _857 = _854 + _849.y;
      float _858 = _842 * 0.0476190485060215f;
      float _859 = _843 * 0.0476190485060215f;
      float _860 = _844 * 0.0476190485060215f;
      float _861 = _858 + _610;
      float _862 = _859 + _611;
      float _863 = _860 + _612;
      float _864 = 1.0f - _855;
      float _865 = 1.0f - _856;
      float _866 = 1.0f - _857;
      float _867 = _864 * _861;
      float _868 = _865 * _862;
      float _869 = _866 * _863;
      float _870 = 1.0f - _867;
      float _871 = 1.0f - _868;
      float _872 = 1.0f - _869;
      float _873 = max(_870, 0.0010000000474974513f);
      float _874 = max(_871, 0.0010000000474974513f);
      float _875 = max(_872, 0.0010000000474974513f);
      float _876 = _855 / _873;
      float _877 = _856 / _874;
      float _878 = _857 / _875;
      float _879 = min(_876, 1.0f);
      float _880 = min(_877, 1.0f);
      float _881 = min(_878, 1.0f);
      _917 = _879;
      _918 = _880;
      _919 = _881;
    } else {
      float _883 = water_light.sun.x + _673;
      float _884 = water_light.sun.y + _674;
      float _885 = water_light.sun.z + _675;
      float _886 = dot(float3(_883, _884, _885), float3(_883, _884, _885));
      float _887 = rsqrt(_886);
      float _888 = _887 * _883;
      float _889 = _887 * _884;
      float _890 = _887 * _885;
      float _891 = dot(float3(_888, _889, _890), float3(_673, _674, _675));
      float _892 = abs(_891);
      float _893 = 1.0f - _892;
      float _894 = saturate(_893);
      float _895 = _894 * _894;
      float _899 = max(0.0f, _842);
      float _900 = max(0.0f, _843);
      float _901 = max(0.0f, _844);
      float _902 = _895 * _895;
      float _903 = _902 * _894;
      float _904 = _903 * cb13_066x;
      float _905 = _904 * _899;
      float _906 = _904 * _900;
      float _907 = _904 * _901;
      float _908 = cb13_066z * 0.8999999761581421f;
      float _909 = _908 + 1.0f;
      float _910 = _905 / _909;
      float _911 = _906 / _909;
      float _912 = _907 / _909;
      float _913 = _910 + _610;
      float _914 = _911 + _611;
      float _915 = _912 + _612;
      _917 = _913;
      _918 = _914;
      _919 = _915;
    }
    float _920 = 1.0f - _917;
    float _921 = 1.0f - _918;
    float _922 = 1.0f - _919;
    float _923 = _920 * _833;
    float _924 = _921 * _834;
    float _925 = _922 * _835;
    int _926 = _655 & -3;
    bool _927 = (_926 == 0);
    float _928 = _923 * 0.31830987334251404f;
    float _929 = _924 * 0.31830987334251404f;
    float _930 = _925 * 0.31830987334251404f;
    float _931 = select(_927, _928, _923);
    float _932 = select(_927, _929, _924);
    float _933 = select(_927, _930, _925);
    float _934 = _75 - cb12_000x;
    float _935 = _76 - cb12_000y;
    float _936 = _934 * _934;
    float _937 = _935 * _935;
    float _938 = _936 + _937;
    float _939 = sqrt(_938);
    float _942 = cb12_219z * _77;
    float _944 = _942 + cb12_219w;
    float _945 = saturate(_944);
    float _954 = cb13_061x - cb13_062x;
    float _955 = cb13_061y - cb13_062y;
    float _956 = cb13_061z - cb13_062z;
    float _957 = _954 * _945;
    float _958 = _955 * _945;
    float _959 = _956 * _945;
    float _960 = _957 + cb13_062x;
    float _961 = _958 + cb13_062y;
    float _962 = _959 + cb13_062z;
    float _964 = cb12_219x * _939;
    float _966 = _964 + cb12_219y;
    float _967 = saturate(_966);
    float _972 = _960 - cb13_001x;
    float _973 = _961 - cb13_001y;
    float _974 = _962 - cb13_001z;
    float _975 = _972 * _967;
    float _976 = _973 * _967;
    float _977 = _974 * _967;
    float _978 = (_975 + cb13_001x) * water_light.direct.x;
    float _979 = (_976 + cb13_001y) * water_light.direct.y;
    float _980 = (_977 + cb13_001z) * water_light.direct.z;
    float _981 = _694 * graphics_sun_visibility;
    float _982 = _931 * _981;
    float _983 = _982 * _978;
    float _984 = _932 * _981;
    float _985 = _984 * _979;
    float _986 = _933 * _981;
    float _987 = _986 * _980;
    float _988 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_615, _616, _617));
    bool _989 = (_988 > 0.0f);
    [branch]
    if (_989) {
      float _991 = water_light.sun.x + _673;
      float _992 = water_light.sun.y + _674;
      float _993 = water_light.sun.z + _675;
      float _994 = dot(float3(_991, _992, _993), float3(_991, _992, _993));
      float _995 = rsqrt(_994);
      float _996 = _995 * _991;
      float _997 = _995 * _992;
      float _998 = _995 * _993;
      float _999 = dot(float3(_615, _616, _617), float3(_673, _674, _675));
      float _1000 = saturate(_687);
      float _1001 = dot(float3(_182, _183, _184), float3(_182, _183, _184));
      float _1002 = rsqrt(_1001);
      float _1003 = _1002 * _182;
      float _1004 = _1002 * _183;
      float _1005 = _1002 * _184;
      float _1006 = dot(float3(_1003, _1004, _1005), float3(_615, _616, _617));
      float _1007 = _1006 * _615;
      float _1008 = _1006 * _616;
      float _1009 = _1006 * _617;
      float _1010 = _1003 - _1007;
      float _1011 = _1004 - _1008;
      float _1012 = _1005 - _1009;
      float _1013 = dot(float3(_1010, _1011, _1012), float3(_1010, _1011, _1012));
      float _1014 = rsqrt(_1013);
      float _1015 = _1010 * _1014;
      float _1016 = _1011 * _1014;
      float _1017 = _1012 * _1014;
      float _1018 = _1016 * _617;
      float _1019 = _1017 * _616;
      float _1020 = _1018 - _1019;
      float _1021 = _1017 * _615;
      float _1022 = _1015 * _617;
      float _1023 = _1021 - _1022;
      float _1024 = _1015 * _616;
      float _1025 = _1016 * _615;
      float _1026 = _1024 - _1025;
      float _1027 = dot(float3(_1020, _1023, _1026), float3(_1020, _1023, _1026));
      float _1028 = rsqrt(_1027);
      float _1029 = _1020 * _1028;
      float _1030 = _1023 * _1028;
      float _1031 = _1026 * _1028;
      float _1032 = dot(float3(_1015, _1016, _1017), float3(_996, _997, _998));
      float _1033 = _1032 * 1.2345679998397827f;
      float _1034 = _1033 * _1033;
      float _1035 = dot(float3(_1029, _1030, _1031), float3(_996, _997, _998));
      float _1036 = _1035 * 1.2345679998397827f;
      float _1037 = _1036 * _1036;
      float _1038 = dot(float3(_615, _616, _617), float3(_996, _997, _998));
      float _1039 = saturate(_1038);
      float _1040 = _1039 * _1039;
      float _1041 = _1037 + _1034;
      float _1042 = _1041 + _1040;
      float _1043 = _1042 * _1042;
      float _1044 = 0.4851658046245575f / _1043;
      float _1045 = abs(_999);
      float _1046 = dot(float3(_996, _997, _998), float3(_673, _674, _675));
      float _1047 = abs(_1046);
      float _1048 = 1.0f - _1047;
      float _1049 = saturate(_1048);
      float _1050 = _1049 * _1049;
      float _1054 = max(0.0f, _842);
      float _1055 = max(0.0f, _843);
      float _1056 = max(0.0f, _844);
      float _1057 = _1050 * _1050;
      float _1058 = _1057 * _1049;
      float _1059 = _1058 * cb13_066x;
      float _1060 = _1059 * _1054;
      float _1061 = _1059 * _1055;
      float _1062 = _1059 * _1056;
      float _1063 = cb13_066z * 0.8999999761581421f;
      float _1064 = _1063 + 1.0f;
      float _1065 = _1060 / _1064;
      float _1066 = _1061 / _1064;
      float _1067 = _1062 / _1064;
      float _1068 = _1065 + _610;
      float _1069 = _1066 + _611;
      float _1070 = _1067 + _612;
      bool _1072 = (cb12_221z > 0.0f);
      [branch]
      if (_1072) {
        float _1074 = saturate(_999);
        float _1075 = _1074 + _1000;
        float _1076 = _1000 * 2.0f;
        float _1077 = _1076 * _1074;
        float _1078 = _1075 - _1077;
        float _1079 = _1078 * 0.809999942779541f;
        float _1080 = _1079 + _1077;
        _1095 = _1080;
      } else {
        float _1082 = _1045 * _1045;
        float _1083 = _1082 * 0.34390008449554443f;
        float _1084 = _1083 + 0.6560999155044556f;
        float _1085 = sqrt(_1084);
        float _1086 = _1085 * _1000;
        float _1087 = _1000 * _1000;
        float _1088 = _1087 * 0.34390008449554443f;
        float _1089 = _1088 + 0.6560999155044556f;
        float _1090 = sqrt(_1089);
        float _1091 = _1090 * _1045;
        float _1092 = _1086 + 9.999999747378752e-05f;
        float _1093 = _1092 + _1091;
        _1095 = _1093;
      }
      float _1096 = 0.5f / _1095;
      float _1097 = _1096 * _1044;
      float _1098 = _1097 * _1068;
      float _1099 = _1097 * _1069;
      float _1100 = _1097 * _1070;
      bool _1102 = (cb12_221y > 0.0f);
      if (_1102) {
        float _1104 = dot(float3(_615, _616, _617), float3(_1096, _1096, _1096));
        float4 _1107 = t43.SampleLevel(s10, float2(0.8999999761581421f, _1104), 0.0f);
        float _1110 = _1107.x * _610;
        float _1111 = _1107.x * _611;
        float _1112 = _1107.x * _612;
        float _1113 = _1110 + _1107.y;
        float _1114 = _1111 + _1107.y;
        float _1115 = _1112 + _1107.y;
        float _1116 = _842 * 0.0476190485060215f;
        float _1117 = _843 * 0.0476190485060215f;
        float _1118 = _844 * 0.0476190485060215f;
        float _1119 = _1116 + _610;
        float _1120 = _1117 + _611;
        float _1121 = _1118 + _612;
        float _1122 = 1.0f - _1113;
        float _1123 = 1.0f - _1114;
        float _1124 = 1.0f - _1115;
        float _1125 = _1122 * _1119;
        float _1126 = _1123 * _1120;
        float _1127 = _1124 * _1121;
        float _1128 = 1.0f - _1125;
        float _1129 = 1.0f - _1126;
        float _1130 = 1.0f - _1127;
        float _1131 = max(_1128, 0.0010000000474974513f);
        float _1132 = max(_1129, 0.0010000000474974513f);
        float _1133 = max(_1130, 0.0010000000474974513f);
        float _1134 = _1113 / _1131;
        float _1135 = _1114 / _1132;
        float _1136 = _1115 / _1133;
        float _1137 = min(_1134, 1.0f);
        float _1138 = min(_1135, 1.0f);
        float _1139 = min(_1136, 1.0f);
        float _1140 = max(_1113, 9.999999747378752e-05f);
        float _1141 = max(_1114, 9.999999747378752e-05f);
        float _1142 = max(_1115, 9.999999747378752e-05f);
        float _1143 = _1137 / _1140;
        float _1144 = _1138 / _1141;
        float _1145 = _1139 / _1142;
        float _1146 = _1143 * _1098;
        float _1147 = _1144 * _1099;
        float _1148 = _1145 * _1100;
        _1150 = _1146;
        _1151 = _1147;
        _1152 = _1148;
      } else {
        _1150 = _1098;
        _1151 = _1099;
        _1152 = _1100;
      }
      float _1153 = _1150 * _1000;
      float _1154 = _1151 * _1000;
      float _1155 = _1152 * _1000;
      _1157 = _1153;
      _1158 = _1154;
      _1159 = _1155;
    } else {
      _1157 = 0.0f;
      _1158 = 0.0f;
      _1159 = 0.0f;
    }
    float _1160 = _978 * graphics_sun_visibility;
    float _1161 = _1160 * _1157;
    float _1162 = _979 * graphics_sun_visibility;
    float _1163 = _1162 * _1158;
    float _1164 = _980 * graphics_sun_visibility;
    float _1165 = _1164 * _1159;
    _1167 = _1161;
    _1168 = _1163;
    _1169 = _1165;
    _1170 = _983;
    _1171 = _985;
    _1172 = _987;
    _1173 = _836;
    _1174 = _837;
    _1175 = _838;
  } else {
    _1167 = 0.0f;
    _1168 = 0.0f;
    _1169 = 0.0f;
    _1170 = 0.0f;
    _1171 = 0.0f;
    _1172 = 0.0f;
    _1173 = 0.0f;
    _1174 = 0.0f;
    _1175 = 0.0f;
  }
  if (any(water_light.direct != 1.f)) {
    float3 native_environment = GraphicsForwardSunEnvironment(float3(_615, _616, _617), float3(_615, _616, _617),
        float3(_673, _674, _675), float3(cb13_000x, cb13_000y, cb13_000z), float3(_598, _599, _600), .9f, int(cb12_220y), .25f, _677.y);
    _1173 = native_environment.x; _1174 = native_environment.y; _1175 = native_environment.z;
  }
  float _1176 = min(_1173, _677.y);
  float _1177 = min(_1174, _677.y);
  float _1178 = min(_1175, _677.y);
  _1180 = _1170;
  _1181 = _1171;
  _1182 = _1172;
  _1183 = _1167;
  _1184 = _1168;
  _1185 = _1169;
  _1186 = 0;
  while(true) {
    int _1187 = _1186 + _663;
    uint _1188 = _1187 << 2u;
    int4 _1190 = asint(t20.Load4(_1188));
    bool _1192 = ((uint)_1190.x > (uint)255);
    [branch]
    if (!_1192) {
      uint _1194 = _1190.x * 10;
      uint _1195 = _1194 + 68u;
      float _1200 = (cb13_raw[_1195].x) - _75;
      float _1201 = (cb13_raw[_1195].y) - _76;
      float _1202 = (cb13_raw[_1195].z) - _77;
      float _1203 = _1200 * _1200;
      float _1204 = _1201 * _1201;
      float _1205 = _1203 + _1204;
      float _1206 = _1202 * _1202;
      float _1207 = _1205 + _1206;
      float _1208 = sqrt(_1207);
      float _1209 = _1208 * _1208;
      uint _1210 = _1194 + 73u;
      float _1213 = _1209 * (cb13_raw[_1210].x);
      float _1215 = _1208 / (cb13_raw[_1195].w);
      float _1216 = _1215 * _1215;
      float _1217 = _1216 * _1216;
      float _1218 = 1.0f - _1217;
      float _1219 = saturate(_1218);
      float _1220 = _1219 * _1219;
      uint _1221 = _1194 + 71u;
      int _1224 = asint((cb13_raw[_1221].w));
      int _1225 = _1224 & 1;
      bool _1226 = (_1225 != 0);
      bool _1228 = ((cb13_raw[_1210].z) > 0.0f);
      uint _1229 = _1194 + 74u;
      bool _1232 = ((cb13_raw[_1229].x) > 0.0f);
      uint _1233 = _1194 + 77u;
      int _1236 = asint((cb13_raw[_1233].x));
      int _1237 = _1236 & 1;
      bool _1238 = (_1237 != 0);
      float _1239 = _1213 + 1.0f;
      float _1240 = _1220 / _1239;
      if (_1226) {
        uint _1242 = _1194 + 70u;
        float _1247 = dot(float3(_1200, _1201, _1202), float3(_1200, _1201, _1202));
        float _1248 = rsqrt(_1247);
        float _1249 = _1200 * _1248;
        float _1250 = -0.0f - _1249;
        float _1251 = _1201 * _1248;
        float _1252 = -0.0f - _1251;
        float _1253 = _1202 * _1248;
        float _1254 = -0.0f - _1253;
        float _1255 = dot(float3(_1250, _1252, _1254), float3((cb13_raw[_1242].x), (cb13_raw[_1242].y), (cb13_raw[_1242].z)));
        uint _1256 = _1194 + 72u;
        float _1260 = (cb13_raw[_1256].y) * _1255;
        float _1262 = _1260 + (cb13_raw[_1256].z);
        float _1263 = saturate(_1262);
        float _1264 = log2(_1263);
        float _1265 = _1264 * (cb13_raw[_1256].w);
        float _1266 = exp2(_1265);
        float _1267 = _1266 * _1240;
        _1269 = _1267;
      } else {
        _1269 = _1240;
      }
      bool _1270 = _1228 || _1238;
      bool _1271 = (_1269 > 0.0f);
      bool _1272 = _1270 && _1271;
      if (_1272) {
        float _1274 = -0.0f - _1200;
        float _1275 = -0.0f - _1201;
        float _1276 = -0.0f - _1202;
        if (_1226) {
          uint _1278 = _1194 + 70u;
          uint _1283 = _1194 + 75u;
          float _1288 = (cb13_raw[_1283].w) * (cb13_raw[_1278].y);
          float _1289 = (cb13_raw[_1283].z) * (cb13_raw[_1278].z);
          float _1290 = _1288 - _1289;
          float _1291 = (cb13_raw[_1283].y) * (cb13_raw[_1278].z);
          float _1292 = (cb13_raw[_1283].w) * (cb13_raw[_1278].x);
          float _1293 = _1291 - _1292;
          float _1294 = (cb13_raw[_1283].z) * (cb13_raw[_1278].x);
          float _1295 = (cb13_raw[_1283].y) * (cb13_raw[_1278].y);
          float _1296 = _1294 - _1295;
          float _1297 = _1290 * _1274;
          float _1298 = mad(_1293, _1275, _1297);
          float _1299 = mad(_1296, _1276, _1298);
          float _1300 = (cb13_raw[_1283].y) * _1274;
          float _1301 = mad((cb13_raw[_1283].z), _1275, _1300);
          float _1302 = mad((cb13_raw[_1283].w), _1276, _1301);
          float _1303 = (cb13_raw[_1278].x) * _1274;
          float _1304 = mad((cb13_raw[_1278].y), _1275, _1303);
          float _1305 = mad((cb13_raw[_1278].z), _1276, _1304);
          int _1308 = asint((cb13_raw[_1233].z));
          _1471 = _1299;
          _1472 = _1302;
          _1473 = _1305;
          _1474 = (cb13_raw[_1283].x);
          _1475 = _1308;
        } else {
          if (_1238) {
            uint _1311 = _1194 + 72u;
            uint _1316 = _1194 + 70u;
            float _1321 = (cb13_raw[_1316].y) * (cb13_raw[_1311].w);
            float _1322 = (cb13_raw[_1316].z) * (cb13_raw[_1311].z);
            float _1323 = _1321 - _1322;
            float _1324 = (cb13_raw[_1316].z) * (cb13_raw[_1311].y);
            float _1325 = (cb13_raw[_1316].x) * (cb13_raw[_1311].w);
            float _1326 = _1324 - _1325;
            float _1327 = (cb13_raw[_1316].x) * (cb13_raw[_1311].z);
            float _1328 = (cb13_raw[_1316].y) * (cb13_raw[_1311].y);
            float _1329 = _1327 - _1328;
            float _1330 = _1323 * _1274;
            float _1331 = mad(_1326, _1275, _1330);
            float _1332 = mad(_1329, _1276, _1331);
            float _1333 = (cb13_raw[_1316].x) * _1274;
            float _1334 = mad((cb13_raw[_1316].y), _1275, _1333);
            float _1335 = mad((cb13_raw[_1316].z), _1276, _1334);
            float _1336 = (cb13_raw[_1311].y) * _1274;
            float _1337 = mad((cb13_raw[_1311].z), _1275, _1336);
            float _1338 = mad((cb13_raw[_1311].w), _1276, _1337);
            float _1339 = -0.0f - _1332;
            float _1340 = -0.0f - _1335;
            float _1341 = -0.0f - _1338;
            float _1342 = _1339 / _1208;
            float _1343 = _1340 / _1208;
            float _1344 = _1341 / _1208;
            float _1345 = abs(_1342);
            float _1346 = abs(_1343);
            float _1347 = abs(_1344);
            int _1348 = _1236 & 4;
            bool _1349 = (_1348 == 0);
            float _1350 = max(_1346, _1347);
            bool _1351 = (_1345 > _1350);
            if (!_1349) {
              if (_1351) {
                bool _1354 = (_1342 > 0.0f);
                uint _1355 = _1194 + 75u;
                if (_1354) {
                  _1381 = _1335;
                  _1382 = _1338;
                  _1383 = _1339;
                  _1384 = (cb13_raw[_1355].x);
                } else {
                  _1381 = _1340;
                  _1382 = _1338;
                  _1383 = _1332;
                  _1384 = (cb13_raw[_1355].y);
                }
              } else {
                float _1362 = max(_1345, _1347);
                bool _1363 = (_1346 > _1362);
                if (_1363) {
                  bool _1365 = (_1343 > 0.0f);
                  uint _1366 = _1194 + 75u;
                  if (_1365) {
                    _1381 = _1339;
                    _1382 = _1338;
                    _1383 = _1340;
                    _1384 = (cb13_raw[_1366].z);
                  } else {
                    _1381 = _1332;
                    _1382 = _1338;
                    _1383 = _1335;
                    _1384 = (cb13_raw[_1366].w);
                  }
                } else {
                  bool _1373 = (_1344 > 0.0f);
                  uint _1374 = _1194 + 76u;
                  if (_1373) {
                    _1381 = _1332;
                    _1382 = _1335;
                    _1383 = _1341;
                    _1384 = (cb13_raw[_1374].x);
                  } else {
                    _1381 = _1332;
                    _1382 = _1340;
                    _1383 = _1338;
                    _1384 = (cb13_raw[_1374].y);
                  }
                }
              }
              int _1386 = asint((cb13_raw[_1233].z));
              _1471 = _1381;
              _1472 = _1382;
              _1473 = _1383;
              _1474 = _1384;
              _1475 = _1386;
            } else {
              if (_1351) {
                bool _1389 = (_1342 > 0.0f);
                uint _1390 = _1194 + 75u;
                int _1393 = asint((cb13_raw[_1233].z));
                if (_1389) {
                  _1471 = _1335;
                  _1472 = _1338;
                  _1473 = _1339;
                  _1474 = (cb13_raw[_1390].x);
                  _1475 = _1393;
                } else {
                  int _1398 = (uint)(_1393) >> 10;
                  _1471 = _1340;
                  _1472 = _1338;
                  _1473 = _1332;
                  _1474 = (cb13_raw[_1390].y);
                  _1475 = _1398;
                }
              } else {
                float _1400 = max(_1345, _1347);
                bool _1401 = (_1346 > _1400);
                if (_1401) {
                  bool _1403 = (_1343 > 0.0f);
                  uint _1404 = _1194 + 75u;
                  if (_1403) {
                    int _1409 = asint((cb13_raw[_1233].z));
                    int _1410 = (uint)(_1409) >> 20;
                    _1471 = _1339;
                    _1472 = _1338;
                    _1473 = _1340;
                    _1474 = (cb13_raw[_1404].z);
                    _1475 = _1410;
                  } else {
                    int _1414 = asint((cb13_raw[_1233].w));
                    _1471 = _1332;
                    _1472 = _1338;
                    _1473 = _1335;
                    _1474 = (cb13_raw[_1404].w);
                    _1475 = _1414;
                  }
                } else {
                  bool _1416 = (_1344 > 0.0f);
                  uint _1417 = _1194 + 76u;
                  int _1420 = asint((cb13_raw[_1233].w));
                  if (_1416) {
                    int _1423 = (uint)(_1420) >> 10;
                    _1471 = _1332;
                    _1472 = _1335;
                    _1473 = _1341;
                    _1474 = (cb13_raw[_1417].x);
                    _1475 = _1423;
                  } else {
                    int _1426 = (uint)(_1420) >> 20;
                    _1471 = _1332;
                    _1472 = _1340;
                    _1473 = _1338;
                    _1474 = (cb13_raw[_1417].y);
                    _1475 = _1426;
                  }
                }
              }
            }
          } else {
            float _1428 = _1200 / _1208;
            float _1429 = _1201 / _1208;
            float _1430 = _1202 / _1208;
            float _1431 = abs(_1428);
            float _1432 = abs(_1429);
            float _1433 = abs(_1430);
            float _1434 = max(_1432, _1433);
            bool _1435 = (_1431 > _1434);
            if (_1435) {
              bool _1437 = (_1428 > 0.0f);
              uint _1438 = _1194 + 75u;
              if (_1437) {
                _1464 = _1275;
                _1465 = _1276;
                _1466 = _1200;
                _1467 = (cb13_raw[_1438].x);
              } else {
                _1464 = _1201;
                _1465 = _1276;
                _1466 = _1274;
                _1467 = (cb13_raw[_1438].y);
              }
            } else {
              float _1445 = max(_1431, _1433);
              bool _1446 = (_1432 > _1445);
              if (_1446) {
                bool _1448 = (_1429 > 0.0f);
                uint _1449 = _1194 + 75u;
                if (_1448) {
                  _1464 = _1200;
                  _1465 = _1276;
                  _1466 = _1201;
                  _1467 = (cb13_raw[_1449].z);
                } else {
                  _1464 = _1274;
                  _1465 = _1276;
                  _1466 = _1275;
                  _1467 = (cb13_raw[_1449].w);
                }
              } else {
                bool _1456 = (_1430 > 0.0f);
                uint _1457 = _1194 + 76u;
                if (_1456) {
                  _1464 = _1274;
                  _1465 = _1275;
                  _1466 = _1202;
                  _1467 = (cb13_raw[_1457].x);
                } else {
                  _1464 = _1274;
                  _1465 = _1201;
                  _1466 = _1276;
                  _1467 = (cb13_raw[_1457].y);
                }
              }
            }
            int _1469 = asint((cb13_raw[_1233].z));
            _1471 = _1464;
            _1472 = _1465;
            _1473 = _1466;
            _1474 = _1467;
            _1475 = _1469;
          }
        }
        float _1477 = _1471 * (cb13_raw[_1210].y);
        float _1478 = mad((cb13_raw[_1210].y), _1472, 0.0f);
        float _1479 = _1477 / _1473;
        float _1480 = _1478 / _1473;
        float _1481 = _1479 * 0.5f;
        float _1482 = _1480 * 0.5f;
        float _1483 = _1481 + 0.5f;
        float _1484 = 0.5f - _1482;
        if (_1228) {
          int _1486 = asint(_1474);
          int _1487 = (uint)(_1486) >> 18;
          int _1488 = _1487 & 4092;
          float _1489 = float((uint)_1488);
          bool _1490 = (_1488 == 0);
          [branch]
          if (!_1490) {
            int _1492 = (uint)(_1486) >> 30;
            float _1493 = float((uint)_1492);
            int _1494 = (uint)(_1486) >> 8;
            int _1495 = _1494 & 4092;
            float _1496 = float((uint)_1495);
            uint _1497 = _1486 << 2u;
            int _1498 = _1497 & 4092;
            float _1499 = float((uint)_1498);
            float _1500 = _1483 * _1489;
            float _1501 = _1484 * _1489;
            float _1502 = _1500 + _1499;
            float _1503 = _1501 + _1496;
            float _1506 = cb13_067x * _1502;
            float _1507 = cb13_067x * _1503;
            float _1510 = t9.SampleLevel(s10, float3(_1506, _1507, _1493), 0.0f);
            float _1512 = _1215 * 0.9900000095367432f;
            float _1513 = _1510.x - _1512;
            float _1514 = _1513 * 144.26950073242188f;
            float _1515 = exp2(_1514);
            float _1516 = saturate(_1515);
            _1518 = _1516;
          } else {
            _1518 = 1.0f;
          }
        } else {
          _1518 = 1.0f;
        }
        if (_1238) {
          int _1520 = _1236 & 2;
          bool _1521 = (_1520 != 0);
          int _1522 = _1236 & 8;
          bool _1523 = (_1522 == 0);
          if (_1521) {
            int _1525 = _1475 & 1023;
            _1531 = _1525;
            _1532 = 0;
          } else {
            int _1527 = _1475 & 255;
            int _1528 = (uint)(_1475) >> 8;
            int _1529 = _1528 & 3;
            _1531 = _1527;
            _1532 = _1529;
          }
          float _1533 = float((uint)_1531);
          float _1535 = floor(cb13_raw[_1233].y);
          float _1536 = _1535 + _1533;
          float4 _1540 = t42.SampleLevel(s10, float3(_1483, _1484, _1536), 0.0f);
          _38[0] = _1540.x;
          _38[1] = _1540.y;
          _38[2] = _1540.z;
          _38[3] = _1540.w;
          if (!_1523) {
            float _1550 = _1536 + 1.0f;
            float4 _1551 = t42.SampleLevel(s10, float3(_1483, _1484, _1550), 0.0f);
            float _1556 = frac(cb13_raw[_1233].y);
            float _1557 = _1551.x - _1540.x;
            float _1558 = _1551.y - _1540.y;
            float _1559 = _1551.z - _1540.z;
            float _1560 = _1551.w - _1540.w;
            float _1561 = _1557 * _1556;
            float _1562 = _1558 * _1556;
            float _1563 = _1559 * _1556;
            float _1564 = _1560 * _1556;
            float _1565 = _1561 + _1540.x;
            float _1566 = _1562 + _1540.y;
            float _1567 = _1563 + _1540.z;
            float _1568 = _1564 + _1540.w;
            _38[0] = _1565;
            _38[1] = _1566;
            _38[2] = _1567;
            _38[3] = _1568;
            _1570 = _1567;
            _1571 = _1566;
            _1572 = _1565;
          } else {
            _1570 = _1540.z;
            _1571 = _1540.y;
            _1572 = _1540.x;
          }
          if (!_1521) {
            float _1575 = _38[_1532];
            _1577 = _1575;
            _1578 = _1575;
            _1579 = _1575;
          } else {
            _1577 = _1572;
            _1578 = _1571;
            _1579 = _1570;
          }
          _1581 = _1518;
          _1582 = _1577;
          _1583 = _1578;
          _1584 = _1579;
        } else {
          _1581 = _1518;
          _1582 = 1.0f;
          _1583 = 1.0f;
          _1584 = 1.0f;
        }
      } else {
        _1581 = 1.0f;
        _1582 = 1.0f;
        _1583 = 1.0f;
        _1584 = 1.0f;
      }
      bool _1585 = _1232 && _1271;
      if (_1585) {
        float _1590 = t10.SampleLevel(s10, float4(_1200, _1201, _1202, (cb13_raw[_1229].y)), 0.0f);
        float _1592 = _1215 * 0.9900000095367432f;
        float _1593 = _1590.x - _1592;
        float _1594 = _1593 * 144.26950073242188f;
        float _1595 = exp2(_1594);
        float _1596 = saturate(_1595);
        float _1597 = _1596 * _1581;
        _1599 = _1597;
      } else {
        _1599 = _1581;
      }
      uint _1600 = _1194 + 70u;
      float _1603 = _1599 + -1.0f;
      float _1604 = (cb13_raw[_1600].w) * _1603;
      float _1605 = _1604 + 1.0f;
      int _1606 = _1224 & 2048;
      bool _1607 = (_1606 != 0);
      bool _1608 = (_677.z == 1.0f);
      bool _1609 = _1608 || _1607;
      if (_1609) {
        _1614 = cb12_071y;
      } else {
        _1614 = 0.0f;
      }
      int _1615 = _1224 & 4096;
      bool _1616 = (_1615 != 0);
      bool _1617 = !(_677.z == 1.0f);
      bool _1618 = _1617 || _1616;
      if (_1618) {
        _1623 = cb12_071z;
      } else {
        _1623 = 0.0f;
      }
      float _1624 = _1605 * _1269;
      float _1625 = _1624 * _1614;
      float _1626 = _1625 * _1623;
      float _1627 = _1626 * _1582;
      float _1628 = _1626 * _1583;
      float _1629 = _1626 * _1584;
      bool _1630 = (_1627 > 0.0f);
      bool _1631 = (_1628 > 0.0f);
      bool _1632 = (_1629 > 0.0f);
      bool _1633 = _1630 || _1631;
      bool _1634 = _1632 || _1633;
      [branch]
      if (_1634) {
        bool _1638 = (FrequentPixelConsts_256.x < 0.0f);
        if (!_1638) {
          _1643 = cb12_071x;
        } else {
          _1643 = 1.0f;
        }
        bool _1644 = ((int)_1224 < (int)0);
        float _1645 = select(_1644, _1643, 1.0f);
        float _1646 = _1645 * _1627;
        float _1647 = _1645 * _1628;
        float _1648 = _1645 * _1629;
        float _1649 = dot(float3(_1200, _1201, _1202), float3(_1200, _1201, _1202));
        float _1650 = rsqrt(_1649);
        float _1651 = _1650 * _1200;
        float _1652 = _1650 * _1201;
        float _1653 = _1650 * _1202;
        float _1654 = dot(float3(_615, _616, _617), float3(_1651, _1652, _1653));
        float _1655 = _1654 + 0.25f;
        float _1656 = _1655 * 0.800000011920929f;
        float _1657 = saturate(_1656);
        float _1658 = _1657 + _1654;
        float _1659 = _1657 + 1.0f;
        float _1660 = _1658 / _1659;
        float _1661 = 1.0f / _1659;
        float _1662 = saturate(_1660);
        bool _1663 = (_655 == 1);
        if (_1663) {
          float _1665 = saturate(_1654);
          bool _1666 = (_617 > 0.0f);
          int _1667 = (int)(uint)(_1666);
          int _1668 = _1667 << 1u;
          int _1669 = _1668 + -1;
          float _1670 = float((int)(_1669));
          float _1671 = _1670 + _617;
          float _1672 = -1.0f / _1671;
          float _1673 = _615 * _616;
          float _1674 = _1673 * _1672;
          float _1675 = _615 * _615;
          float _1676 = _1675 * _1670;
          float _1677 = _1676 * _1672;
          float _1678 = _1677 + 1.0f;
          float _1679 = _1674 * _1670;
          int _1680 = 1 - _1668;
          float _1681 = float((int)(_1680));
          float _1682 = _1681 * _615;
          float _1683 = _616 * _616;
          float _1684 = _1683 * _1672;
          float _1685 = _1684 + _1670;
          float _1686 = -0.0f - _616;
          float _1687 = dot(float3(_1651, _1652, _1653), float3(_1651, _1652, _1653));
          float _1688 = rsqrt(_1687);
          float _1689 = _1688 * _1651;
          float _1690 = _1688 * _1652;
          float _1691 = _1688 * _1653;
          float _1692 = _1689 * _1678;
          float _1693 = mad(_1679, _1690, _1692);
          float _1694 = mad(_1682, _1691, _1693);
          float _1695 = _1689 * _1674;
          float _1696 = mad(_1685, _1690, _1695);
          float _1697 = mad(_1686, _1691, _1696);
          float _1698 = _1689 * _615;
          float _1699 = mad(_616, _1690, _1698);
          float _1700 = mad(_617, _1691, _1699);
          float _1701 = dot(float3(_1694, _1697, _1700), float3(_1694, _1697, _1700));
          float _1702 = rsqrt(_1701);
          float _1703 = _1702 * _1694;
          float _1704 = _1702 * _1697;
          float _1705 = _1702 * _1700;
          float _1706 = dot(float3(_673, _674, _675), float3(_673, _674, _675));
          float _1707 = rsqrt(_1706);
          float _1708 = _1707 * _673;
          float _1709 = _1707 * _674;
          float _1710 = _1707 * _675;
          float _1711 = _1708 * _1678;
          float _1712 = mad(_1679, _1709, _1711);
          float _1713 = mad(_1682, _1710, _1712);
          float _1714 = _1708 * _1674;
          float _1715 = mad(_1685, _1709, _1714);
          float _1716 = mad(_1686, _1710, _1715);
          float _1717 = _1708 * _615;
          float _1718 = mad(_616, _1709, _1717);
          float _1719 = mad(_617, _1710, _1718);
          float _1720 = dot(float3(_1713, _1716, _1719), float3(_1713, _1716, _1719));
          float _1721 = rsqrt(_1720);
          float _1722 = _1721 * _1713;
          float _1723 = _1721 * _1716;
          float _1724 = _1721 * _1719;
          float _1725 = dot(float3(_1703, _1704, _1705), float3(_1722, _1723, _1724));
          float _1726 = _1724 * _1705;
          float _1727 = _1725 - _1726;
          bool _1728 = (_1727 > 0.0f);
          if (_1728) {
            float _1730 = max(_1705, _1724);
            float _1731 = _1727 / _1730;
            _1733 = _1731;
          } else {
            _1733 = _1727;
          }
          float _1734 = _1733 * 0.20908956229686737f;
          float _1735 = _1734 + 0.25813528895378113f;
          float _1736 = _1735 * _598;
          float _1737 = _1735 * _599;
          float _1738 = _1735 * _600;
          float _1739 = 1.0f - _1724;
          float _1740 = _1739 * 0.07144299894571304f;
          float _1741 = _1740 + -0.332181453704834f;
          float _1742 = _1741 * _1739;
          float _1743 = _1742 + 0.4918818771839142f;
          float _1744 = _1743 * _1739;
          float _1745 = _1744 + 0.05710852891206741f;
          float _1746 = _1739 * 0.6568742394447327f;
          float _1747 = _1746 * _1745;
          float _1748 = 1.0f - _1705;
          float _1749 = _1748 * 0.07144299894571304f;
          float _1750 = _1749 + -0.332181453704834f;
          float _1751 = _1750 * _1748;
          float _1752 = _1751 + 0.4918818771839142f;
          float _1753 = _1752 * _1748;
          float _1754 = _1753 + 0.05710852891206741f;
          float _1755 = _1748 * 0.6568742394447327f;
          float _1756 = _1755 * _1754;
          float _1757 = _598 * _598;
          float _1758 = _599 * _599;
          float _1759 = _600 * _600;
          float _1760 = _1757 * 0.8585715889930725f;
          float _1761 = _1758 * 0.8585715889930725f;
          float _1762 = _1759 * 0.8585715889930725f;
          float _1763 = _598 * 0.1414284110069275f;
          float _1764 = _599 * 0.1414284110069275f;
          float _1765 = _600 * 0.1414284110069275f;
          float _1766 = 1.0f - _1763;
          float _1767 = 1.0f - _1764;
          float _1768 = 1.0f - _1765;
          float _1769 = _1760 / _1766;
          float _1770 = _1761 / _1767;
          float _1771 = _1762 / _1768;
          float _1772 = 0.1890440583229065f - _1747;
          float _1773 = max(1.0000000116860974e-07f, _1772);
          float _1774 = 0.1890440583229065f - _1756;
          float _1775 = max(1.0000000116860974e-07f, _1774);
          float _1776 = _1773 * 2.250678300857544f;
          float _1777 = _1776 * _1775;
          float _1778 = _1777 * _1769;
          float _1779 = _1777 * _1770;
          float _1780 = _1777 * _1771;
          float _1781 = _1778 + _1736;
          float _1782 = _1779 + _1737;
          float _1783 = _1780 + _1738;
          float _1784 = _1781 * _1665;
          float _1785 = _1782 * _1665;
          float _1786 = _1783 * _1665;
          float _1787 = _1662 - _1665;
          float _1788 = max(0.0f, _1787);
          float _1789 = _1788 * 0.31830987334251404f;
          float _1790 = _1789 * _598;
          float _1791 = _1789 * _599;
          float _1792 = _1789 * _600;
          float _1793 = _1784 + _1790;
          float _1794 = _1785 + _1791;
          float _1795 = _1786 + _1792;
          _1797 = _1793;
          _1798 = _1794;
          _1799 = _1795;
        } else {
          _1797 = _1662;
          _1798 = _1662;
          _1799 = _1662;
        }
        bool _1802 = (cb12_221x > 0.0f);
        float _1803 = 1.0f - _610;
        float _1804 = 1.0f - _611;
        float _1805 = 1.0f - _612;
        if (_1802) {
          float _1807 = dot(float3(_615, _616, _617), float3(_673, _674, _675));
          float4 _1810 = t43.SampleLevel(s10, float2(0.8999999761581421f, _1807), 0.0f);
          float _1813 = _1810.x * _610;
          float _1814 = _1810.x * _611;
          float _1815 = _1810.x * _612;
          float _1816 = _1813 + _1810.y;
          float _1817 = _1814 + _1810.y;
          float _1818 = _1815 + _1810.y;
          float _1819 = _1803 * 0.0476190485060215f;
          float _1820 = _1804 * 0.0476190485060215f;
          float _1821 = _1805 * 0.0476190485060215f;
          float _1822 = _1819 + _610;
          float _1823 = _1820 + _611;
          float _1824 = _1821 + _612;
          float _1825 = 1.0f - _1816;
          float _1826 = 1.0f - _1817;
          float _1827 = 1.0f - _1818;
          float _1828 = _1825 * _1822;
          float _1829 = _1826 * _1823;
          float _1830 = _1827 * _1824;
          float _1831 = 1.0f - _1828;
          float _1832 = 1.0f - _1829;
          float _1833 = 1.0f - _1830;
          float _1834 = max(_1831, 0.0010000000474974513f);
          float _1835 = max(_1832, 0.0010000000474974513f);
          float _1836 = max(_1833, 0.0010000000474974513f);
          float _1837 = _1816 / _1834;
          float _1838 = _1817 / _1835;
          float _1839 = _1818 / _1836;
          float _1840 = min(_1837, 1.0f);
          float _1841 = min(_1838, 1.0f);
          float _1842 = min(_1839, 1.0f);
          _1878 = _1840;
          _1879 = _1841;
          _1880 = _1842;
        } else {
          float _1844 = _1651 + _673;
          float _1845 = _1652 + _674;
          float _1846 = _1653 + _675;
          float _1847 = dot(float3(_1844, _1845, _1846), float3(_1844, _1845, _1846));
          float _1848 = rsqrt(_1847);
          float _1849 = _1848 * _1844;
          float _1850 = _1848 * _1845;
          float _1851 = _1848 * _1846;
          float _1852 = dot(float3(_1849, _1850, _1851), float3(_673, _674, _675));
          float _1853 = abs(_1852);
          float _1854 = 1.0f - _1853;
          float _1855 = saturate(_1854);
          float _1856 = _1855 * _1855;
          float _1860 = max(0.0f, _1803);
          float _1861 = max(0.0f, _1804);
          float _1862 = max(0.0f, _1805);
          float _1863 = _1856 * _1856;
          float _1864 = _1863 * _1855;
          float _1865 = _1864 * cb13_066x;
          float _1866 = _1865 * _1860;
          float _1867 = _1865 * _1861;
          float _1868 = _1865 * _1862;
          float _1869 = cb13_066z * 0.8999999761581421f;
          float _1870 = _1869 + 1.0f;
          float _1871 = _1866 / _1870;
          float _1872 = _1867 / _1870;
          float _1873 = _1868 / _1870;
          float _1874 = _1871 + _610;
          float _1875 = _1872 + _611;
          float _1876 = _1873 + _612;
          _1878 = _1874;
          _1879 = _1875;
          _1880 = _1876;
        }
        float _1881 = 1.0f - _1878;
        float _1882 = 1.0f - _1879;
        float _1883 = 1.0f - _1880;
        float _1884 = _1881 * _1797;
        float _1885 = _1882 * _1798;
        float _1886 = _1883 * _1799;
        int _1887 = _655 & -3;
        bool _1888 = (_1887 == 0);
        float _1889 = _1884 * 0.31830987334251404f;
        float _1890 = _1885 * 0.31830987334251404f;
        float _1891 = _1886 * 0.31830987334251404f;
        float _1892 = select(_1888, _1889, _1884);
        float _1893 = select(_1888, _1890, _1885);
        float _1894 = select(_1888, _1891, _1886);
        float _1898 = _1646 * (cb13_raw[_1221].x);
        float _1899 = _1898 * _1661;
        float _1900 = _1899 * _1892;
        float _1901 = _1647 * (cb13_raw[_1221].y);
        float _1902 = _1901 * _1661;
        float _1903 = _1902 * _1893;
        float _1904 = _1648 * (cb13_raw[_1221].z);
        float _1905 = _1904 * _1661;
        float _1906 = _1905 * _1894;
        float _1907 = _1900 + _1180;
        float _1908 = _1903 + _1181;
        float _1909 = _1906 + _1182;
        float _1910 = dot(float3(_1651, _1652, _1653), float3(_615, _616, _617));
        bool _1911 = (_1910 > 0.0f);
        [branch]
        if (_1911) {
          float _1913 = _1651 + _673;
          float _1914 = _1652 + _674;
          float _1915 = _1653 + _675;
          float _1916 = dot(float3(_1913, _1914, _1915), float3(_1913, _1914, _1915));
          float _1917 = rsqrt(_1916);
          float _1918 = _1917 * _1913;
          float _1919 = _1917 * _1914;
          float _1920 = _1917 * _1915;
          float _1921 = dot(float3(_615, _616, _617), float3(_673, _674, _675));
          float _1922 = saturate(_1654);
          float _1923 = dot(float3(_182, _183, _184), float3(_182, _183, _184));
          float _1924 = rsqrt(_1923);
          float _1925 = _1924 * _182;
          float _1926 = _1924 * _183;
          float _1927 = _1924 * _184;
          float _1928 = dot(float3(_1925, _1926, _1927), float3(_615, _616, _617));
          float _1929 = _1928 * _615;
          float _1930 = _1928 * _616;
          float _1931 = _1928 * _617;
          float _1932 = _1925 - _1929;
          float _1933 = _1926 - _1930;
          float _1934 = _1927 - _1931;
          float _1935 = dot(float3(_1932, _1933, _1934), float3(_1932, _1933, _1934));
          float _1936 = rsqrt(_1935);
          float _1937 = _1932 * _1936;
          float _1938 = _1933 * _1936;
          float _1939 = _1934 * _1936;
          float _1940 = _1938 * _617;
          float _1941 = _1939 * _616;
          float _1942 = _1940 - _1941;
          float _1943 = _1939 * _615;
          float _1944 = _1937 * _617;
          float _1945 = _1943 - _1944;
          float _1946 = _1937 * _616;
          float _1947 = _1938 * _615;
          float _1948 = _1946 - _1947;
          float _1949 = dot(float3(_1942, _1945, _1948), float3(_1942, _1945, _1948));
          float _1950 = rsqrt(_1949);
          float _1951 = _1942 * _1950;
          float _1952 = _1945 * _1950;
          float _1953 = _1948 * _1950;
          float _1954 = dot(float3(_1937, _1938, _1939), float3(_1918, _1919, _1920));
          float _1955 = _1954 * 1.2345679998397827f;
          float _1956 = _1955 * _1955;
          float _1957 = dot(float3(_1951, _1952, _1953), float3(_1918, _1919, _1920));
          float _1958 = _1957 * 1.2345679998397827f;
          float _1959 = _1958 * _1958;
          float _1960 = dot(float3(_615, _616, _617), float3(_1918, _1919, _1920));
          float _1961 = saturate(_1960);
          float _1962 = _1961 * _1961;
          float _1963 = _1959 + _1956;
          float _1964 = _1963 + _1962;
          float _1965 = _1964 * _1964;
          float _1966 = 0.4851658046245575f / _1965;
          float _1967 = abs(_1921);
          float _1968 = dot(float3(_1918, _1919, _1920), float3(_673, _674, _675));
          float _1969 = abs(_1968);
          float _1970 = 1.0f - _1969;
          float _1971 = saturate(_1970);
          float _1972 = _1971 * _1971;
          float _1976 = max(0.0f, _1803);
          float _1977 = max(0.0f, _1804);
          float _1978 = max(0.0f, _1805);
          float _1979 = _1972 * _1972;
          float _1980 = _1979 * _1971;
          float _1981 = _1980 * cb13_066x;
          float _1982 = _1981 * _1976;
          float _1983 = _1981 * _1977;
          float _1984 = _1981 * _1978;
          float _1985 = cb13_066z * 0.8999999761581421f;
          float _1986 = _1985 + 1.0f;
          float _1987 = _1982 / _1986;
          float _1988 = _1983 / _1986;
          float _1989 = _1984 / _1986;
          float _1990 = _1987 + _610;
          float _1991 = _1988 + _611;
          float _1992 = _1989 + _612;
          bool _1994 = (cb12_221z > 0.0f);
          [branch]
          if (_1994) {
            float _1996 = saturate(_1921);
            float _1997 = _1996 + _1922;
            float _1998 = _1922 * 2.0f;
            float _1999 = _1998 * _1996;
            float _2000 = _1997 - _1999;
            float _2001 = _2000 * 0.809999942779541f;
            float _2002 = _2001 + _1999;
            _2017 = _2002;
          } else {
            float _2004 = _1967 * _1967;
            float _2005 = _2004 * 0.34390008449554443f;
            float _2006 = _2005 + 0.6560999155044556f;
            float _2007 = sqrt(_2006);
            float _2008 = _2007 * _1922;
            float _2009 = _1922 * _1922;
            float _2010 = _2009 * 0.34390008449554443f;
            float _2011 = _2010 + 0.6560999155044556f;
            float _2012 = sqrt(_2011);
            float _2013 = _2012 * _1967;
            float _2014 = _2008 + 9.999999747378752e-05f;
            float _2015 = _2014 + _2013;
            _2017 = _2015;
          }
          float _2018 = 0.5f / _2017;
          float _2019 = _2018 * _1966;
          float _2020 = _2019 * _1990;
          float _2021 = _2019 * _1991;
          float _2022 = _2019 * _1992;
          bool _2024 = (cb12_221y > 0.0f);
          if (_2024) {
            float _2026 = dot(float3(_615, _616, _617), float3(_2018, _2018, _2018));
            float4 _2029 = t43.SampleLevel(s10, float2(0.8999999761581421f, _2026), 0.0f);
            float _2032 = _2029.x * _610;
            float _2033 = _2029.x * _611;
            float _2034 = _2029.x * _612;
            float _2035 = _2032 + _2029.y;
            float _2036 = _2033 + _2029.y;
            float _2037 = _2034 + _2029.y;
            float _2038 = _1803 * 0.0476190485060215f;
            float _2039 = _1804 * 0.0476190485060215f;
            float _2040 = _1805 * 0.0476190485060215f;
            float _2041 = _2038 + _610;
            float _2042 = _2039 + _611;
            float _2043 = _2040 + _612;
            float _2044 = 1.0f - _2035;
            float _2045 = 1.0f - _2036;
            float _2046 = 1.0f - _2037;
            float _2047 = _2044 * _2041;
            float _2048 = _2045 * _2042;
            float _2049 = _2046 * _2043;
            float _2050 = 1.0f - _2047;
            float _2051 = 1.0f - _2048;
            float _2052 = 1.0f - _2049;
            float _2053 = max(_2050, 0.0010000000474974513f);
            float _2054 = max(_2051, 0.0010000000474974513f);
            float _2055 = max(_2052, 0.0010000000474974513f);
            float _2056 = _2035 / _2053;
            float _2057 = _2036 / _2054;
            float _2058 = _2037 / _2055;
            float _2059 = min(_2056, 1.0f);
            float _2060 = min(_2057, 1.0f);
            float _2061 = min(_2058, 1.0f);
            float _2062 = max(_2035, 9.999999747378752e-05f);
            float _2063 = max(_2036, 9.999999747378752e-05f);
            float _2064 = max(_2037, 9.999999747378752e-05f);
            float _2065 = _2059 / _2062;
            float _2066 = _2060 / _2063;
            float _2067 = _2061 / _2064;
            float _2068 = _2065 * _2020;
            float _2069 = _2066 * _2021;
            float _2070 = _2067 * _2022;
            _2072 = _2068;
            _2073 = _2069;
            _2074 = _2070;
          } else {
            _2072 = _2020;
            _2073 = _2021;
            _2074 = _2022;
          }
          float _2075 = _2072 * _1922;
          float _2076 = _2073 * _1922;
          float _2077 = _2074 * _1922;
          _2079 = _2075;
          _2080 = _2076;
          _2081 = _2077;
        } else {
          _2079 = 0.0f;
          _2080 = 0.0f;
          _2081 = 0.0f;
        }
        float _2082 = _1898 * _2079;
        float _2083 = _1901 * _2080;
        float _2084 = _1904 * _2081;
        float _2085 = _2082 + _1183;
        float _2086 = _2083 + _1184;
        float _2087 = _2084 + _1185;
        _2089 = _1907;
        _2090 = _1908;
        _2091 = _1909;
        _2092 = _2085;
        _2093 = _2086;
        _2094 = _2087;
      } else {
        _2089 = _1180;
        _2090 = _1181;
        _2091 = _1182;
        _2092 = _1183;
        _2093 = _1184;
        _2094 = _1185;
      }
      int _2095 = _1186 + 1;
      bool _2096 = ((int)_2095 < (int)256);
      if (_2096) {
        _1180 = _2089;
        _1181 = _2090;
        _1182 = _2091;
        _1183 = _2092;
        _1184 = _2093;
        _1185 = _2094;
        _1186 = _2095;
        continue;
      } else {
        _2098 = _2089;
        _2099 = _2090;
        _2100 = _2091;
        _2101 = _2092;
        _2102 = _2093;
        _2103 = _2094;
      }
    } else {
      _2098 = _1180;
      _2099 = _1181;
      _2100 = _1182;
      _2101 = _1183;
      _2102 = _1184;
      _2103 = _1185;
    }
    break;
  }
  float _2104 = -0.0f - _673;
  float _2105 = -0.0f - _674;
  float _2106 = -0.0f - _675;
  float _2107 = dot(float3(_2104, _2105, _2106), float3(_615, _616, _617));
  float _2108 = _2107 * 2.0f;
  float _2109 = _2108 * _615;
  float _2110 = _2108 * _616;
  float _2111 = _2108 * _617;
  float _2112 = _2104 - _2109;
  float _2113 = _2105 - _2110;
  float _2114 = _2106 - _2111;
  float _2115 = dot(float3(_2112, _2113, _2114), float3(_2112, _2113, _2114));
  float _2116 = rsqrt(_2115);
  float _2117 = _2112 * _2116;
  float _2118 = _2113 * _2116;
  float _2119 = _2114 * _2116;
  float _2120 = ddx_coarse(_2117);
  float _2121 = ddx_coarse(_2118);
  float _2122 = ddx_coarse(_2119);
  float _2123 = ddy_coarse(_2117);
  float _2124 = ddy_coarse(_2118);
  float _2125 = ddy_coarse(_2119);
  int _2126 = _646 & 1;
  bool _2127 = (_2126 != 0);
  float _2128 = -0.0f - _2120;
  float _2129 = -0.0f - _2121;
  float _2130 = -0.0f - _2122;
  float _2131 = select(_2127, _2128, _2120);
  float _2132 = select(_2127, _2129, _2121);
  float _2133 = select(_2127, _2130, _2122);
  int _2134 = _647 & 1;
  bool _2135 = (_2134 != 0);
  float _2136 = -0.0f - _2123;
  float _2137 = -0.0f - _2124;
  float _2138 = -0.0f - _2125;
  float _2139 = select(_2135, _2136, _2123);
  float _2140 = select(_2135, _2137, _2124);
  float _2141 = select(_2135, _2138, _2125);
  float _2142 = _2139 + _2117;
  float _2143 = _2140 + _2118;
  float _2144 = _2141 + _2119;
  float _2145 = dot(float3(_2142, _2143, _2144), float3(_2142, _2143, _2144));
  float _2146 = rsqrt(_2145);
  float _2147 = _2146 * _2142;
  float _2148 = _2146 * _2143;
  float _2149 = _2144 * _2146;
  float _2150 = dot(float3(_2117, _2118, _2119), float3(_2147, _2148, _2149));
  float _2151 = acos(_2150);
  float _2152 = _2151 * 81.4873275756836f;
  float _2153 = log2(_2152);
  float _2154 = max(0.0f, _2153);
  float _2155 = _2131 + _2117;
  float _2156 = _2132 + _2118;
  float _2157 = _2133 + _2119;
  float _2158 = dot(float3(_2155, _2156, _2157), float3(_2155, _2156, _2157));
  float _2159 = rsqrt(_2158);
  float _2160 = _2159 * _2155;
  float _2161 = _2159 * _2156;
  float _2162 = _2159 * _2157;
  float _2163 = dot(float3(_2117, _2118, _2119), float3(_2160, _2161, _2162));
  float _2164 = acos(_2163);
  float _2165 = _2164 * 81.4873275756836f;
  float _2166 = log2(_2165);
  float _2167 = max(0.0f, _2166);
  float _2168 = max(_2167, _2154);
  float _2169 = _2168 * 0.625f;
  float _2170 = max(8.504999160766602f, _2169);
  float _2171 = max(_2170, 0.0f);
  float _2172 = min(_2171, 5.0f);
  bool _2173 = (_617 < 0.0f);
  float _2174 = _615 * 0.5f;
  float _2175 = _616 * -0.5f;
  float _2176 = 1.0f - _617;
  float _2177 = 1.0f / _2176;
  float _2178 = max(_2177, -3.4028234663852886e+38f);
  float _2179 = min(_2178, 3.4028234663852886e+38f);
  float _2180 = _2174 * _2179;
  float _2181 = _2175 * _2179;
  float _2182 = _615 * -0.5f;
  float _2183 = _616 * 0.5f;
  float _2184 = _617 + 1.0f;
  float _2185 = 1.0f / _2184;
  float _2186 = max(_2185, -3.4028234663852886e+38f);
  float _2187 = min(_2186, 3.4028234663852886e+38f);
  float _2188 = _2182 * _2187;
  float _2189 = _2183 * _2187;
  float _2190 = select(_2173, _2180, _2188);
  float _2191 = _2190 + 0.5f;
  float _2192 = select(_2173, _2181, _2189);
  float _2193 = _2192 + 0.5f;
  float _2194 = float((bool)_2173);
  if (_650) {
    float _2196 = _2191 * 0.9696969985961914f;
    float _2197 = _2193 * 0.9696969985961914f;
    float _2198 = _2197 + 0.01515151560306549f;
    float _2199 = _2194 + 0.01515151560306549f;
    float _2200 = _2199 + _2196;
    _2208 = _2200;
    _2209 = _2198;
  } else {
    float _2202 = _2191 * 0.6666666269302368f;
    float _2203 = _2193 * 0.6666666269302368f;
    float _2204 = _2203 + 0.1666666716337204f;
    float _2205 = _2194 + 0.1666666716337204f;
    float _2206 = _2205 + _2202;
    _2208 = _2206;
    _2209 = _2204;
  }
  float _2210 = _2208 * 0.5f;
  _2212 = 1;
  _2213 = 0.0f;
  _2214 = 0.0f;
  _2215 = 0.0f;
  _2216 = 0.0f;
  _2217 = 0.0f;
  _2218 = 0.0f;
  _2219 = 9.999999747378752e-06f;
  while(true) {
    int _2220 = _2212 * 12;
    int _2221 = _2220 + 102;
    int _2226 = _2220 + 103;
    int _2231 = _2220 + 104;
    int _2236 = _2220 + 105;
    float _2241 = (cb12_raw[_2221].x) * _75;
    float _2242 = mad((cb12_raw[_2226].x), _76, _2241);
    float _2243 = mad((cb12_raw[_2231].x), _77, _2242);
    float _2244 = _2243 + (cb12_raw[_2236].x);
    float _2245 = (cb12_raw[_2221].y) * _75;
    float _2246 = mad((cb12_raw[_2226].y), _76, _2245);
    float _2247 = mad((cb12_raw[_2231].y), _77, _2246);
    float _2248 = _2247 + (cb12_raw[_2236].y);
    float _2249 = (cb12_raw[_2221].z) * _75;
    float _2250 = mad((cb12_raw[_2226].z), _76, _2249);
    float _2251 = mad((cb12_raw[_2231].z), _77, _2250);
    float _2252 = _2251 + (cb12_raw[_2236].z);
    float _2253 = abs(_2244);
    float _2254 = abs(_2248);
    float _2255 = abs(_2252);
    float _2256 = 1.0f - _2253;
    float _2257 = 1.0f - _2254;
    float _2258 = 1.0f - _2255;
    int _2259 = _2220 + 106;
    int _2262 = asint((cb12_raw[_2259].y));
    bool _2263 = !(_677.z == -1.0f);
    [branch]
    if (_2263) {
      int _2265 = _2262 & 1;
      bool _2266 = (_2265 != 0);
      float _2267 = select(_2266, 1.0f, _677.z);
      int _2268 = _2262 & 2;
      bool _2269 = (_2268 != 0);
      float _2270 = 1.0f - _677.z;
      float _2271 = select(_2269, 1.0f, _2270);
      float _2272 = _2267 * _2271;
      _2274 = _2272;
    } else {
      _2274 = 1.0f;
    }
    bool _2275 = (_2256 > 0.0f);
    bool _2276 = (_2257 > 0.0f);
    bool _2277 = (_2258 > 0.0f);
    bool _2278 = _2275 && _2276;
    bool _2279 = _2278 && _2277;
    bool _2280 = (_2274 > 0.0f);
    bool _2281 = _2279 && _2280;
    if (_2281) {
      int _2283 = _2220 + 101;
      float _2288 = (cb12_raw[_2283].x) * _2256;
      float _2289 = (cb12_raw[_2283].y) * _2257;
      float _2290 = (cb12_raw[_2283].z) * _2258;
      float _2291 = saturate(_2288);
      float _2292 = saturate(_2289);
      float _2293 = saturate(_2290);
      float _2294 = 1.0f - _2219;
      float _2295 = _2274 * _2294;
      int _2296 = _2220 + 100;
      float _2299 = _2295 * _2291;
      float _2300 = _2299 * _2292;
      float _2301 = _2300 * _2293;
      float _2302 = _2301 * (cb12_raw[_2296].x);
      float _2303 = _2302 + _2219;
      float _2305 = _2302 * (cb12_raw[_2259].x);
      int _2306 = _2220 + 111;
      float _2309 = float((int)(asint(cb12_raw[_2306].x)));
      float _2310 = _2309 + _2209;
      float _2311 = _2310 * 0.1428571492433548f;
      if (_650) {
        float4 _2315 = t27.SampleLevel(s11, float2(_2210, _2311), 0.0f);
        float _2319 = _2315.x * _2302;
        float _2320 = _2315.y * _2302;
        float _2321 = _2315.z * _2302;
        _2332 = _2319;
        _2333 = _2320;
        _2334 = _2321;
      } else {
        float4 _2324 = t22.SampleLevel(s11, float2(_2210, _2311), 0.0f);
        float _2328 = _2324.x * _2305;
        float _2329 = _2324.y * _2305;
        float _2330 = _2324.z * _2305;
        _2332 = _2328;
        _2333 = _2329;
        _2334 = _2330;
      }
      float _2335 = _2332 + _2218;
      float _2336 = _2333 + _2217;
      float _2337 = _2334 + _2216;
      int _2341 = _2220 + 107;
      int _2346 = _2220 + 108;
      int _2351 = _2220 + 109;
      float _2356 = (cb12_raw[_2341].x) * _2112;
      float _2357 = mad((cb12_raw[_2346].x), _2113, _2356);
      float _2358 = mad((cb12_raw[_2351].x), _2114, _2357);
      float _2359 = (cb12_raw[_2341].y) * _2112;
      float _2360 = mad((cb12_raw[_2346].y), _2113, _2359);
      float _2361 = mad((cb12_raw[_2351].y), _2114, _2360);
      float _2362 = (cb12_raw[_2341].z) * _2112;
      float _2363 = mad((cb12_raw[_2346].z), _2113, _2362);
      float _2364 = mad((cb12_raw[_2351].z), _2114, _2363);
      int _2365 = _2220 + 110;
      float _2370 = (cb12_raw[_2341].x) * _75;
      float _2371 = mad((cb12_raw[_2346].x), _76, _2370);
      float _2372 = mad((cb12_raw[_2351].x), _77, _2371);
      float _2373 = _2372 + (cb12_raw[_2365].x);
      float _2374 = (cb12_raw[_2341].y) * _75;
      float _2375 = mad((cb12_raw[_2346].y), _76, _2374);
      float _2376 = mad((cb12_raw[_2351].y), _77, _2375);
      float _2377 = _2376 + (cb12_raw[_2365].y);
      float _2378 = (cb12_raw[_2341].z) * _75;
      float _2379 = mad((cb12_raw[_2346].z), _76, _2378);
      float _2380 = mad((cb12_raw[_2351].z), _77, _2379);
      float _2381 = _2380 + (cb12_raw[_2365].z);
      float _2382 = 1.0f / _2358;
      float _2383 = 1.0f / _2361;
      float _2384 = 1.0f / _2364;
      float _2385 = _2382 * _2373;
      float _2386 = _2383 * _2377;
      float _2387 = _2384 * _2381;
      float _2388 = _2382 - _2385;
      float _2389 = _2383 - _2386;
      float _2390 = _2384 - _2387;
      float _2391 = -0.0f - _2382;
      float _2392 = -0.0f - _2383;
      float _2393 = -0.0f - _2384;
      float _2394 = _2391 - _2385;
      float _2395 = _2392 - _2386;
      float _2396 = _2393 - _2387;
      float _2397 = max(_2388, _2394);
      float _2398 = max(_2389, _2395);
      float _2399 = max(_2390, _2396);
      float _2400 = min(_2398, _2399);
      float _2401 = min(_2397, _2400);
      float _2402 = _2401 * _2112;
      float _2403 = _2401 * _2113;
      float _2404 = _2401 * _2114;
      float _2405 = _75 - (cb12_raw[_2296].y);
      float _2406 = _2402 + _2405;
      float _2407 = _76 - (cb12_raw[_2296].z);
      float _2408 = _2403 + _2407;
      float _2409 = _77 - (cb12_raw[_2296].w);
      float _2410 = _2404 + _2409;
      float _2411 = dot(float3(_2406, _2408, _2410), float3(_2406, _2408, _2410));
      float _2412 = rsqrt(_2411);
      float _2413 = _2406 * _2412;
      float _2414 = _2408 * _2412;
      float _2415 = _2410 * _2412;
      bool _2416 = (_2415 < 0.0f);
      float _2417 = _2413 * 0.5f;
      float _2418 = _2414 * -0.5f;
      float _2419 = 1.0f - _2415;
      float _2420 = 1.0f / _2419;
      float _2421 = max(_2420, -3.4028234663852886e+38f);
      float _2422 = min(_2421, 3.4028234663852886e+38f);
      float _2423 = _2417 * _2422;
      float _2424 = _2418 * _2422;
      float _2425 = _2413 * -0.5f;
      float _2426 = _2414 * 0.5f;
      float _2427 = _2415 + 1.0f;
      float _2428 = 1.0f / _2427;
      float _2429 = max(_2428, -3.4028234663852886e+38f);
      float _2430 = min(_2429, 3.4028234663852886e+38f);
      float _2431 = _2425 * _2430;
      float _2432 = _2426 * _2430;
      float _2433 = select(_2416, _2423, _2431);
      float _2434 = _2433 + 0.5f;
      float _2435 = select(_2416, _2424, _2432);
      float _2436 = _2435 + 0.5f;
      float _2437 = _2434 * 0.6666666269302368f;
      float _2438 = _2436 * 0.6666666269302368f;
      float _2439 = float((bool)_2416);
      float _2440 = _2439 + 0.1666666716337204f;
      float _2441 = _2440 + _2437;
      float _2442 = _2309 + 0.1666666716337204f;
      float _2443 = _2442 + _2438;
      float _2444 = _2441 * 0.5f;
      float _2445 = _2443 * 0.1428571492433548f;
      float4 _2447 = t23.SampleLevel(s11, float2(_2444, _2445), _2172);
      float _2451 = _2447.x * _2305;
      float _2452 = _2447.y * _2305;
      float _2453 = _2447.z * _2305;
      float _2454 = _2451 + _2215;
      float _2455 = _2452 + _2214;
      float _2456 = _2453 + _2213;
      _2458 = _2303;
      _2459 = _2335;
      _2460 = _2336;
      _2461 = _2337;
      _2462 = _2454;
      _2463 = _2455;
      _2464 = _2456;
    } else {
      _2458 = _2219;
      _2459 = _2218;
      _2460 = _2217;
      _2461 = _2216;
      _2462 = _2215;
      _2463 = _2214;
      _2464 = _2213;
    }
    int _2465 = _2212 + 1;
    bool _2466 = ((uint)_2465 < (uint)7);
    _2467 = (_2458 < 0.9990000128746033f);
    bool _2468 = _2466 && _2467;
    if (_2468) {
      _2212 = _2465;
      _2213 = _2464;
      _2214 = _2463;
      _2215 = _2462;
      _2216 = _2461;
      _2217 = _2460;
      _2218 = _2459;
      _2219 = _2458;
      continue;
    }
    break;
  }
  [branch]
  if (_2467) {
    float _2471 = 1.0f - _2458;
    float _2474 = cb12_100x * _2471;
    float _2475 = _2474 + _2458;
    float _2478 = _2474 * cb12_106x;
    float _2481 = float((int)(cb12_111x));
    float _2482 = _2481 + _2209;
    float _2483 = _2482 * 0.1428571492433548f;
    if (_650) {
      float4 _2487 = t27.SampleLevel(s11, float2(_2210, _2483), 0.0f);
      float _2491 = _2487.x * _2474;
      float _2492 = _2487.y * _2474;
      float _2493 = _2487.z * _2474;
      _2504 = _2491;
      _2505 = _2492;
      _2506 = _2493;
    } else {
      float4 _2496 = t22.SampleLevel(s11, float2(_2210, _2483), 0.0f);
      float _2500 = _2496.x * _2478;
      float _2501 = _2496.y * _2478;
      float _2502 = _2496.z * _2478;
      _2504 = _2500;
      _2505 = _2501;
      _2506 = _2502;
    }
    float _2507 = _2504 + _2459;
    float _2508 = _2505 + _2460;
    float _2509 = _2506 + _2461;
    bool _2510 = (_2114 < 0.0f);
    float _2511 = _2112 * 0.5f;
    float _2512 = _2113 * -0.5f;
    float _2513 = 1.0f - _2114;
    float _2514 = 1.0f / _2513;
    float _2515 = max(_2514, -3.4028234663852886e+38f);
    float _2516 = min(_2515, 3.4028234663852886e+38f);
    float _2517 = _2511 * _2516;
    float _2518 = _2512 * _2516;
    float _2519 = _2112 * -0.5f;
    float _2520 = _2113 * 0.5f;
    float _2521 = _2114 + 1.0f;
    float _2522 = 1.0f / _2521;
    float _2523 = max(_2522, -3.4028234663852886e+38f);
    float _2524 = min(_2523, 3.4028234663852886e+38f);
    float _2525 = _2519 * _2524;
    float _2526 = _2520 * _2524;
    float _2527 = select(_2510, _2517, _2525);
    float _2528 = _2527 + 0.5f;
    float _2529 = select(_2510, _2518, _2526);
    float _2530 = _2529 + 0.5f;
    float _2531 = _2528 * 0.6666666269302368f;
    float _2532 = _2530 * 0.6666666269302368f;
    float _2533 = float((bool)_2510);
    float _2534 = _2533 + 0.1666666716337204f;
    float _2535 = _2534 + _2531;
    float _2536 = _2481 + 0.1666666716337204f;
    float _2537 = _2536 + _2532;
    float _2538 = _2535 * 0.5f;
    float _2539 = _2537 * 0.1428571492433548f;
    float4 _2541 = t23.SampleLevel(s11, float2(_2538, _2539), _2172);
    float _2545 = _2541.x * _2478;
    float _2546 = _2541.y * _2478;
    float _2547 = _2541.z * _2478;
    float _2548 = _2545 + _2462;
    float _2549 = _2546 + _2463;
    float _2550 = _2547 + _2464;
    _2552 = _2475;
    _2553 = _2507;
    _2554 = _2508;
    _2555 = _2509;
    _2556 = _2548;
    _2557 = _2549;
    _2558 = _2550;
  } else {
    _2552 = _2458;
    _2553 = _2459;
    _2554 = _2460;
    _2555 = _2461;
    _2556 = _2462;
    _2557 = _2463;
    _2558 = _2464;
  }
  float _2559 = 1.0f / _2552;
  float _2560 = _2559 * _2553;
  float _2561 = _2559 * _2554;
  float _2562 = _2559 * _2555;
  float _2563 = _2559 * _2556;
  float _2564 = _2559 * _2557;
  float _2565 = _2559 * _2558;
  bool _2568 = (cb12_074x > 0.0f);
  float _2569 = select(_2568, 0.0f, _2563);
  float _2570 = select(_2568, 0.0f, _2564);
  float _2571 = select(_2568, 0.0f, _2565);
  float _2574 = abs(FrequentPixelConsts_256.x);
  float _2578 = _2574 - FrequentPixelConsts_256.y;
  float _2579 = _2578 * _1176;
  float _2580 = _2578 * _1177;
  float _2581 = _2578 * _1178;
  float _2582 = _2579 + FrequentPixelConsts_256.y;
  float _2583 = _2580 + FrequentPixelConsts_256.y;
  float _2584 = _2581 + FrequentPixelConsts_256.y;
  float _2585 = FrequentPixelConsts_256.z - FrequentPixelConsts_256.w;
  float _2586 = _2585 * _1176;
  float _2587 = _2585 * _1177;
  float _2588 = _2585 * _1178;
  float _2589 = _2586 + FrequentPixelConsts_256.w;
  float _2590 = _2587 + FrequentPixelConsts_256.w;
  float _2591 = _2588 + FrequentPixelConsts_256.w;
  float _2592 = _2560 * _2582;
  float _2593 = _2561 * _2583;
  float _2594 = _2562 * _2584;
  float _2595 = _2589 * _2569;
  float _2596 = _2590 * _2570;
  float _2597 = _2591 * _2571;
  float _2601 = _75 - cb12_000x;
  float _2602 = _76 - cb12_000y;
  float _2603 = _2601 * _2601;
  float _2604 = _2602 * _2602;
  float _2605 = _2603 + _2604;
  float _2606 = sqrt(_2605);
  float _2609 = cb12_219x * _2606;
  float _2611 = _2609 + cb12_219y;
  float _2612 = saturate(_2611);
  float _2615 = cb12_185z + -1.0f;
  float _2616 = _2615 * _2612;
  float _2617 = _2616 + 1.0f;
  float _2623 = cb12_184x - cb12_184y;
  float _2624 = _2623 * _1176;
  float _2625 = _2623 * _1177;
  float _2626 = _2623 * _1178;
  float _2627 = _2624 + cb12_184y;
  float _2628 = _2625 + cb12_184y;
  float _2629 = _2626 + cb12_184y;
  if (!_2568) {
    float _2633 = cb12_185x - cb12_185y;
    float _2634 = _2633 * _1176;
    float _2635 = _2633 * _1177;
    float _2636 = _2633 * _1178;
    float _2637 = _2634 + cb12_185y;
    float _2638 = _2635 + cb12_185y;
    float _2639 = _2636 + cb12_185y;
    float _2640 = _2637 * _2617;
    float _2641 = _2638 * _2617;
    float _2642 = _2639 * _2617;
    _2644 = _2640;
    _2645 = _2641;
    _2646 = _2642;
  } else {
    _2644 = 1.0f;
    _2645 = 1.0f;
    _2646 = 1.0f;
  }
  float _2647 = dot(float3(_615, _616, _617), float3(_673, _674, _675));
  float _2648 = abs(_2647);
  float _2649 = max(_2648, _2648);
  float _2650 = abs(_2649);
  float _2651 = 1.0f - _2650;
  float _2652 = saturate(_2651);
  float _2653 = _2652 * _2652;
  float _2654 = _2653 * _2653;
  float _2655 = _2654 * _2652;
  float _2659 = min(0.25f, cb13_066y);
  float _2660 = 1.0f - _610;
  float _2661 = 1.0f - _611;
  float _2662 = 1.0f - _612;
  float _2663 = max(0.0f, _2660);
  float _2664 = max(0.0f, _2661);
  float _2665 = max(0.0f, _2662);
  float _2666 = _2655 * _2659;
  float _2667 = _2666 * _2663;
  float _2668 = _2666 * _2664;
  float _2669 = _2665 * _2666;
  float _2670 = cb13_066w * 0.8999999761581421f;
  float _2671 = _2670 + 1.0f;
  float _2672 = _2667 / _2671;
  float _2673 = _2668 / _2671;
  float _2674 = _2669 / _2671;
  float _2675 = _2660 - _2672;
  float _2676 = _2661 - _2673;
  float _2677 = _2662 - _2674;
  if (_650) {
    if (_652) {
      bool _2680 = (_617 > 0.0f);
      int _2681 = (int)(uint)(_2680);
      int _2682 = _2681 << 1u;
      int _2683 = _2682 + -1;
      float _2684 = float((int)(_2683));
      float _2685 = _2684 + _617;
      float _2686 = -1.0f / _2685;
      float _2687 = _615 * _616;
      float _2688 = _2687 * _2686;
      float _2689 = _615 * _615;
      float _2690 = _2689 * _2684;
      float _2691 = _2690 * _2686;
      float _2692 = _2691 + 1.0f;
      float _2693 = _2688 * _2684;
      int _2694 = 1 - _2682;
      float _2695 = float((int)(_2694));
      float _2696 = _2695 * _615;
      float _2697 = _616 * _616;
      float _2698 = _2697 * _2686;
      float _2699 = _2698 + _2684;
      float _2700 = -0.0f - _616;
      float _2701 = dot(float3(_673, _674, _675), float3(_673, _674, _675));
      float _2702 = rsqrt(_2701);
      float _2703 = _2702 * _673;
      float _2704 = _2702 * _674;
      float _2705 = _2702 * _675;
      float _2706 = _2703 * _2692;
      float _2707 = mad(_2693, _2704, _2706);
      float _2708 = mad(_2696, _2705, _2707);
      float _2709 = _2703 * _2688;
      float _2710 = mad(_2699, _2704, _2709);
      float _2711 = mad(_2700, _2705, _2710);
      float _2712 = _2703 * _615;
      float _2713 = mad(_616, _2704, _2712);
      float _2714 = mad(_617, _2705, _2713);
      float _2715 = dot(float3(_2708, _2711, _2714), float3(_2708, _2711, _2714));
      float _2716 = rsqrt(_2715);
      float _2717 = _2716 * _2714;
      float _2718 = 1.0f - _2717;
      float _2719 = _2718 * 0.07144299894571304f;
      float _2720 = _2719 + -0.332181453704834f;
      float _2721 = _2720 * _2718;
      float _2722 = _2721 + 0.4918818771839142f;
      float _2723 = _2722 * _2718;
      float _2724 = _2723 + 0.05710852891206741f;
      float _2725 = _2718 * 0.6568742394447327f;
      float _2726 = _2725 * _2724;
      float _2727 = _2726 + 0.8109559416770935f;
      float _2728 = _598 * _598;
      float _2729 = _599 * _599;
      float _2730 = _600 * _600;
      float _2731 = _2728 * 0.8585715889930725f;
      float _2732 = _2729 * 0.8585715889930725f;
      float _2733 = _2730 * 0.8585715889930725f;
      float _2734 = _598 * 0.1414284110069275f;
      float _2735 = _599 * 0.1414284110069275f;
      float _2736 = _600 * 0.1414284110069275f;
      float _2737 = 1.0f - _2734;
      float _2738 = 1.0f - _2735;
      float _2739 = 1.0f - _2736;
      float _2740 = _2731 / _2737;
      float _2741 = _2732 / _2738;
      float _2742 = _2733 / _2739;
      float _2743 = _2727 * _598;
      float _2744 = _2727 * _599;
      float _2745 = _2727 * _600;
      float _2746 = 0.1890440583229065f - _2726;
      float _2747 = _2746 * _2740;
      float _2748 = _2746 * _2741;
      float _2749 = _2746 * _2742;
      float _2750 = _2743 + _2747;
      float _2751 = _2744 + _2748;
      float _2752 = _2745 + _2749;
      float _2753 = _2675 * _2592;
      float _2754 = _2753 * _2750;
      float _2755 = _2676 * _2593;
      float _2756 = _2755 * _2751;
      float _2757 = _2677 * _2594;
      float _2758 = _2757 * _2752;
      _2777 = _2754;
      _2778 = _2756;
      _2779 = _2758;
    } else {
      float _2760 = _2675 * _2592;
      float _2761 = _2760 * _598;
      float _2762 = _2676 * _2593;
      float _2763 = _2762 * _599;
      float _2764 = _2677 * _2594;
      float _2765 = _2764 * _600;
      _2777 = _2761;
      _2778 = _2763;
      _2779 = _2765;
    }
#ifdef WITCHER_GRAPHICS_CUSTOM_LIGHTING
    float night_skylight = WitcherNightSkylight(cb12_raw[185].w);
    _2777 *= night_skylight;
    _2778 *= night_skylight;
    _2779 *= night_skylight;
#endif
  } else {
    float _2767 = _2675 * _2592;
    float _2768 = _2767 * _2617;
    float _2769 = _2768 * _2627;
    float _2770 = _2676 * _2593;
    float _2771 = _2770 * _2617;
    float _2772 = _2771 * _2628;
    float _2773 = _2677 * _2594;
    float _2774 = _2773 * _2617;
    float _2775 = _2774 * _2629;
    _2777 = _2769;
    _2778 = _2772;
    _2779 = _2775;
  }
  float _2780 = _2595 * _2644;
  float _2781 = _2596 * _2645;
  float _2782 = _2597 * _2646;
  float _2783 = _2672 + _610;
  float _2784 = _2673 + _611;
  float _2785 = _2674 + _612;
  float _2786 = _2780 * _2783;
  float _2787 = _2781 * _2784;
  float _2788 = _2782 * _2785;
  float4 _2790 = t17.Load(int3(_646, _647, 0));
  float _2794 = cb12_187x * _2790.x;
  float _2797 = _2794 + cb12_188x;
  float _2798 = saturate(_2797);
  float _2799 = _2798 + -1.0f;
  float _2800 = _2799 * 0.699999988079071f;
  float _2801 = _2800 + 1.0f;
  float _2802 = _2801 * _677.w;
  float _2805 = _2801 * cb12_069x;
  float _2807 = _2805 + cb12_069y;
  bool _2808 = (_677.z < 0.9900000095367432f);
  if (_2808) {
    _2813 = cb12_287w;
  } else {
    _2813 = 1.0f;
  }
  float _2816 = cb12_288x * _2813;
  float _2817 = log2(_2802);
  float _2818 = _2816 * _2817;
  float _2819 = exp2(_2818);
  if (_2808) {
    _2824 = cb12_287w;
  } else {
    _2824 = 1.0f;
  }
  float _2826 = _2817 * cb12_288y;
  float _2827 = _2826 * _2824;
  float _2828 = exp2(_2827);
  if (_2808) {
    _2833 = cb12_287w;
  } else {
    _2833 = 1.0f;
  }
  float _2835 = _2833 * cb12_288z;
  float _2836 = log2(_2807);
  float _2837 = _2835 * _2836;
  float _2838 = exp2(_2837);
  if (_2808) {
    _2843 = cb12_287w;
  } else {
    _2843 = 1.0f;
  }
  float _2845 = _2836 * cb12_288w;
  float _2846 = _2845 * _2843;
  float _2847 = exp2(_2846);
  float _2848 = (_2819 * _2777) * water_light.ambient.x;
  float _2849 = (_2819 * _2778) * water_light.ambient.y;
  float _2850 = (_2819 * _2779) * water_light.ambient.z;
  float _2851 = (_2786 * _2828) * water_light.ambient.x;
  float _2852 = (_2787 * _2828) * water_light.ambient.y;
  float _2853 = (_2788 * _2828) * water_light.ambient.z;
  float _2854 = _2838 * cb12_184z;
  float _2855 = _2854 * _2098;
  float _2856 = _2854 * _2099;
  float _2857 = _2854 * _2100;
  float _2858 = _2847 * cb12_184w;
  float _2859 = _2858 * _2101;
  float _2860 = _2858 * _2102;
  float _2861 = _2858 * _2103;
  bool _2862 = (_655 == 0);
  float _2863 = _2855 * _598;
  float _2864 = _2856 * _599;
  float _2865 = _2857 * _600;
  float _2866 = select(_2862, _2863, _2855);
  float _2867 = select(_2862, _2864, _2856);
  float _2868 = select(_2862, _2865, _2857);
  if (!_650) {
    float _2870 = _2848 * _598;
    float _2871 = _2849 * _599;
    float _2872 = _2850 * _600;
    _2874 = _2870;
    _2875 = _2871;
    _2876 = _2872;
  } else {
    _2874 = _2848;
    _2875 = _2849;
    _2876 = _2850;
  }
  float _2877 = _2859 + _2866;
  float _2878 = _2860 + _2867;
  float _2879 = _2861 + _2868;
  if (!_2568) {
    float _2881 = _2877 + _2851;
    float _2882 = _2878 + _2852;
    float _2883 = _2879 + _2853;
    _2885 = _2881;
    _2886 = _2882;
    _2887 = _2883;
  } else {
    _2885 = _2877;
    _2886 = _2878;
    _2887 = _2879;
  }
  float _2888 = _2876 + _2887;
  float _2889 = _2875 + _2886;
  float _2890 = _2874 + _2885;
  float _2891 = HAIR_TEX + 9.99999993922529e-09f;
  float _2892 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_172 + 9.99999993922529e-09f;
  float _2893 = _2891 / _2892;
  float _2894 = saturate(_2893);
  float _2897 = 1.0f - cbPerFrame_000.NvHair_ConstantBuffer_600;
  float _2898 = _2897 * _2894;
  float _2899 = saturate(_2898);
  float _2900 = _460 * 0.5f;
  float _2901 = _461 * -0.5f;
  SV_Target.x = _2890;
  SV_Target.y = _2889;
  SV_Target.z = _2888;
  SV_Target.w = _2899;
  SV_Target_1.x = _643;
  SV_Target_1.y = _644;
  SV_Target_1.z = _645;
  SV_Target_1.w = 0.8999999761581421f;
  SV_Target_2.x = _2900;
  SV_Target_2.y = _2901;
  SV_Target_2.z = _462;
  SV_Target_2.w = 1.0f;
  OutputSignature output_signature = { SV_Target, SV_Target_1, SV_Target_2 };
  return output_signature;
}
