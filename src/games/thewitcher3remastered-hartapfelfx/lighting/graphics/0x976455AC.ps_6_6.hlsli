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
  float4 SV_Target_3 = 0;
  bool _2267;
  float _36[4];
  float _57 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].x) * SV_Position.x;
  float _58 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].x), _57);
  float _59 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].x), _58);
  float _60 = _59 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].x);
  float _61 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].y) * SV_Position.x;
  float _62 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].y), _61);
  float _63 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].y), _62);
  float _64 = _63 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].y);
  float _65 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].z) * SV_Position.x;
  float _66 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].z), _65);
  float _67 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].z), _66);
  float _68 = _67 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].z);
  float _69 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].w) * SV_Position.x;
  float _70 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].w), _69);
  float _71 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].w), _70);
  float _72 = _71 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].w);
  float _73 = _60 / _72;
  float _74 = _64 / _72;
  float _75 = _68 / _72;
  float _76 = floor(COMP_TEXCOORD);
  float _77 = _76 * 0.00048828125f;
  float _78 = COMP_TEXCOORD - _76;
  int _81 = cbPerFrame_000.NvHair_ConstantBuffer_584 + -1;
  float _82 = float((int)(_81));
  float _83 = _82 * HAIR_TEX;
  float _84 = floor(_83);
  int _85 = int(_84);
  int _86 = _85 + 1;
  int _87 = min(_86, _81);
  float _88 = frac(_83);
  float3 _90 = t0.Load(C);
  float _94 = floor(_90.x);
  float _95 = floor(_90.y);
  float _96 = floor(_90.z);
  int _97 = int(_94);
  int _98 = int(_95);
  int _99 = int(_96);
  uint _100 = _97 * cbPerFrame_000.NvHair_ConstantBuffer_584;
  uint _101 = _98 * cbPerFrame_000.NvHair_ConstantBuffer_584;
  uint _102 = _99 * cbPerFrame_000.NvHair_ConstantBuffer_584;
  uint _103 = _100 + _85;
  uint _104 = _101 + _85;
  uint _105 = _102 + _85;
  uint _106 = _100 + _87;
  uint _107 = _101 + _87;
  uint _108 = _102 + _87;
  float _109 = floor(COORDS);
  float _110 = _109 * 0.00048828125f;
  float _111 = COORDS - _109;
  float4 _113 = t1.Load(_103);
  float4 _117 = t1.Load(_104);
  float4 _121 = t1.Load(_105);
  float _125 = _113.x * _111;
  float _126 = _113.y * _111;
  float _127 = _113.z * _111;
  float _128 = _117.x * _110;
  float _129 = _117.y * _110;
  float _130 = _117.z * _110;
  float _131 = _128 + _125;
  float _132 = _129 + _126;
  float _133 = _130 + _127;
  float _134 = 1.0f - _111;
  float _135 = _134 - _110;
  float _136 = _121.x * _135;
  float _137 = _121.y * _135;
  float _138 = _121.z * _135;
  float _139 = _131 + _136;
  float _140 = _132 + _137;
  float _141 = _133 + _138;
  float4 _142 = t1.Load(_106);
  float4 _146 = t1.Load(_107);
  float4 _150 = t1.Load(_108);
  float _154 = _142.x * _111;
  float _155 = _142.y * _111;
  float _156 = _142.z * _111;
  float _157 = _146.x * _110;
  float _158 = _146.y * _110;
  float _159 = _146.z * _110;
  float _160 = _150.x * _135;
  float _161 = _150.y * _135;
  float _162 = _150.z * _135;
  float _163 = _154 - _139;
  float _164 = _163 + _157;
  float _165 = _164 + _160;
  float _166 = _155 - _140;
  float _167 = _166 + _158;
  float _168 = _167 + _161;
  float _169 = _156 - _141;
  float _170 = _169 + _159;
  float _171 = _170 + _162;
  float _172 = _165 * _88;
  float _173 = _168 * _88;
  float _174 = _171 * _88;
  float _175 = _172 + _139;
  float _176 = _173 + _140;
  float _177 = _174 + _141;
  float _178 = dot(float3(_175, _176, _177), float3(_175, _176, _177));
  float _179 = rsqrt(_178);
  float _180 = _175 * _179;
  float _181 = _176 * _179;
  float _182 = _177 * _179;
  float4 _184 = t2.Load(_103);
  float4 _188 = t2.Load(_104);
  float4 _192 = t2.Load(_105);
  float _196 = _184.x * _111;
  float _197 = _184.y * _111;
  float _198 = _184.z * _111;
  float _199 = _188.x * _110;
  float _200 = _188.y * _110;
  float _201 = _188.z * _110;
  float _202 = _199 + _196;
  float _203 = _200 + _197;
  float _204 = _201 + _198;
  float _205 = _192.x * _135;
  float _206 = _192.y * _135;
  float _207 = _192.z * _135;
  float _208 = _202 + _205;
  float _209 = _203 + _206;
  float _210 = _204 + _207;
  float4 _211 = t2.Load(_106);
  float4 _215 = t2.Load(_107);
  float4 _219 = t2.Load(_108);
  float _223 = _211.x * _111;
  float _224 = _211.y * _111;
  float _225 = _211.z * _111;
  float _226 = _215.x * _110;
  float _227 = _215.y * _110;
  float _228 = _215.z * _110;
  float _229 = _219.x * _135;
  float _230 = _219.y * _135;
  float _231 = _219.z * _135;
  float _232 = _223 - _208;
  float _233 = _232 + _226;
  float _234 = _233 + _229;
  float _235 = _224 - _209;
  float _236 = _235 + _227;
  float _237 = _236 + _230;
  float _238 = _225 - _210;
  float _239 = _238 + _228;
  float _240 = _239 + _231;
  float _241 = _234 * _88;
  float _242 = _237 * _88;
  float _243 = _240 * _88;
  float _244 = _241 + _208;
  float _245 = _242 + _209;
  float _246 = _243 + _210;
  float _247 = dot(float3(_244, _245, _246), float3(_244, _245, _246));
  float _248 = rsqrt(_247);
  float _249 = _244 * _248;
  float _250 = _245 * _248;
  float _251 = _246 * _248;
  bool _276 = (cbPerFrame_000.NvHair_ConstantBuffer_544 == 0);
  float _285;
  float _286;
  float _287;
  float _299;
  float _300;
  float _301;
  float _313;
  float _375;
  float _376;
  float _377;
  float _566;
  float _633;
  float _634;
  float _635;
  float _636;
  float _637;
  float _638;
  float _717;
  float _718;
  float _719;
  float _895;
  float _950;
  float _951;
  float _952;
  float _957;
  float _958;
  float _959;
  float _967;
  float _968;
  float _969;
  float _970;
  float _971;
  float _972;
  float _973;
  float _974;
  float _975;
  float _980;
  float _981;
  float _982;
  float _983;
  float _984;
  float _985;
  int _986;
  float _1069;
  float _1181;
  float _1182;
  float _1183;
  float _1184;
  float _1264;
  float _1265;
  float _1266;
  float _1267;
  float _1271;
  float _1272;
  float _1273;
  float _1274;
  int _1275;
  float _1318;
  int _1331;
  int _1332;
  float _1370;
  float _1371;
  float _1372;
  float _1377;
  float _1378;
  float _1379;
  float _1381;
  float _1382;
  float _1383;
  float _1384;
  float _1399;
  float _1414;
  float _1423;
  float _1443;
  float _1533;
  float _1597;
  float _1598;
  float _1599;
  float _1678;
  float _1679;
  float _1680;
  float _1817;
  float _1872;
  float _1873;
  float _1874;
  float _1879;
  float _1880;
  float _1881;
  float _1889;
  float _1890;
  float _1891;
  float _1892;
  float _1893;
  float _1894;
  float _1898;
  float _1899;
  float _1900;
  float _1901;
  float _1902;
  float _1903;
  float _2008;
  float _2009;
  int _2012;
  float _2013;
  float _2014;
  float _2015;
  float _2016;
  float _2017;
  float _2018;
  float _2019;
  float _2074;
  float _2132;
  float _2133;
  float _2134;
  float _2258;
  float _2259;
  float _2260;
  float _2261;
  float _2262;
  float _2263;
  float _2264;
  float _2304;
  float _2305;
  float _2306;
  float _2352;
  float _2353;
  float _2354;
  float _2355;
  float _2356;
  float _2357;
  float _2358;
  float _2444;
  float _2445;
  float _2446;
  float _2577;
  float _2578;
  float _2579;
  float _2613;
  float _2624;
  float _2633;
  float _2643;
  float _2674;
  float _2675;
  float _2676;
  float _2685;
  float _2686;
  float _2687;
  if (!_276) {
    float4 _280 = t5.SampleLevel(s0, float2(_78, _77), 0.0f);
    _285 = _280.x;
    _286 = _280.y;
    _287 = _280.z;
  } else {
    _285 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.x;
    _286 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.y;
    _287 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.z;
  }
  bool _290 = (cbPerFrame_000.NvHair_ConstantBuffer_548 == 0);
  if (!_290) {
    float4 _294 = t6.SampleLevel(s0, float2(_78, _77), 0.0f);
    _299 = _294.x;
    _300 = _294.y;
    _301 = _294.z;
  } else {
    _299 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.x;
    _300 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.y;
    _301 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.z;
  }
  bool _302 = (cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144 < 0.5f);
  if (_302) {
    float _304 = HAIR_TEX * 2.0f;
    float _305 = _304 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144;
    _313 = _305;
  } else {
    float _307 = 1.0f - cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144;
    float _308 = HAIR_TEX + -1.0f;
    float _309 = _308 * 2.0f;
    float _310 = _309 * _307;
    float _311 = _310 + 1.0f;
    _313 = _311;
  }
  float _314 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_148 + 0.0010000000474974513f;
  float _315 = 1.0f / _314;
  float _316 = _313 + -0.5f;
  float _317 = _315 * _316;
  float _318 = _317 + 0.5f;
  float _319 = saturate(_318);
  float _320 = _299 - _285;
  float _321 = _300 - _286;
  float _322 = _301 - _287;
  float _323 = _319 * _320;
  float _324 = _319 * _321;
  float _325 = _319 * _322;
  float _326 = _323 + _285;
  float _327 = _324 + _286;
  float _328 = _325 + _287;
  bool _330 = (cbPerFrame_000.NvHair_ConstantBuffer_552 == 0);
  if (!_330) {
    float4 _334 = t7.SampleLevel(s0, float2(HAIR_TEX, 0.5f), 0.0f);
    switch (cbPerFrame_000.NvHair_ConstantBuffer_576) {
      case 0: {
        float _341 = _334.x * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _342 = _334.y * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _343 = _334.z * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        _375 = _341;
        _376 = _342;
        _377 = _343;
        break;
      }
      case 1: {
        float _345 = _334.x * _326;
        float _346 = _334.y * _327;
        float _347 = _334.z * _328;
        float _348 = _345 - _326;
        float _349 = _346 - _327;
        float _350 = _347 - _328;
        float _351 = _348 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _352 = _349 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _353 = _350 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _354 = _351 + _326;
        float _355 = _352 + _327;
        float _356 = _353 + _328;
        _375 = _354;
        _376 = _355;
        _377 = _356;
        break;
      }
      case 2: {
        float _358 = _334.x * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _359 = _334.y * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _360 = _334.z * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _361 = _358 + _326;
        float _362 = _359 + _327;
        float _363 = _360 + _328;
        _375 = _361;
        _376 = _362;
        _377 = _363;
        break;
      }
      case 3: {
        float _365 = _334.x + -0.5f;
        float _366 = _334.y + -0.5f;
        float _367 = _334.z + -0.5f;
        float _368 = _365 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _369 = _366 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _370 = _367 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _371 = _368 + _326;
        float _372 = _369 + _327;
        float _373 = _370 + _328;
        _375 = _371;
        _376 = _372;
        _377 = _373;
        break;
      }
      default: {
        _375 = _326;
        _376 = _327;
        _377 = _328;
        break;
      }
    }
  } else {
    _375 = _326;
    _376 = _327;
    _377 = _328;
  }
  float _378 = _375 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _379 = _376 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _380 = _377 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _381 = log2(_378);
  float _382 = log2(_379);
  float _383 = log2(_380);
  float _384 = _381 * 2.200000047683716f;
  float _385 = _382 * 2.200000047683716f;
  float _386 = _383 * 2.200000047683716f;
  float _387 = exp2(_384);
  float _388 = exp2(_385);
  float _389 = exp2(_386);
  float _390 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.x);
  float _391 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.y);
  float _392 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.z);
  float _393 = _390 * 2.200000047683716f;
  float _394 = _391 * 2.200000047683716f;
  float _395 = _392 * 2.200000047683716f;
  float _396 = exp2(_393);
  float _397 = exp2(_394);
  float _398 = exp2(_395);
  float _399 = _396 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _400 = _397 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _401 = _398 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _402 = dot(float3(_249, _250, _251), float3(_249, _250, _251));
  float _403 = rsqrt(_402);
  float _404 = _403 * _249;
  float _405 = _403 * _250;
  float _406 = _403 * _251;
  float _407 = abs(_404);
  float _408 = abs(_405);
  float _409 = abs(_406);
  float _410 = max(_407, _408);
  float _411 = max(_409, _410);
  bool _412 = (_409 < _411);
  bool _413 = (_408 < _411);
  bool _414 = _412 && _413;
  float _415 = select(_414, _408, _407);
  float _416 = select(_412, _409, _408);
  bool _417 = (_415 < _416);
  float _418 = select(_417, _416, _415);
  float _419 = select(_417, _415, _416);
  float _420 = _419 / _418;
  float _421 = _404 / _411;
  float _422 = _405 / _411;
  float _423 = _406 / _411;
  float4 _426 = t13.SampleLevel(s13, float2(_418, _420), 0.0f);
  float _428 = _426.x * 0.5f;
  float _429 = _428 * _421;
  float _430 = _428 * _422;
  float _431 = _428 * _423;
  float _432 = _429 + 0.5f;
  float _433 = _430 + 0.5f;
  float _434 = _431 + 0.5f;
  float _435 = HAIR_TEX + 9.99999993922529e-09f;
  float _436 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_172 + 9.99999993922529e-09f;
  float _437 = _435 / _436;
  float _438 = saturate(_437);
  float _441 = 1.0f - cbPerFrame_000.NvHair_ConstantBuffer_600;
  float _442 = _441 * _438;
  float _443 = saturate(_442);
  bool _444 = (_443 >= 1.0f);
  float _445 = select(_444, 1.0f, 0.0f);
  uint _446 = uint(SV_Position.x);
  uint _447 = uint(SV_Position.y);
  bool _450 = (cb12_226x > 0.0f);
  bool _452 = (cb12_226y > 0.0f);
  int _455 = int(cb12_220y);
  int _456 = (uint)(_446) >> 4;
  int _457 = (uint)(_447) >> 4;
  int _460 = int(cb12_024x);
  uint _461 = _460 * _457;
  uint _462 = _461 + _456;
  uint _463 = _462 << 8u;
  float _468 = cb12_000x - _73;
  float _469 = cb12_000y - _74;
  float _470 = cb12_000z - _75;
  float _471 = dot(float3(_468, _469, _470), float3(_468, _469, _470));
  float _472 = rsqrt(_471);
  float _473 = _468 * _472;
  float _474 = _469 * _472;
  float _475 = _470 * _472;
  float4 _477 = t17.Load(int3(_446, _447, 0));
  GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
      float3(_73, _74, _75), float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
  // HairWorks keeps its native anisotropic lobes and ambient shadow weights.
  float graphics_sun_visibility = min(_477.y, GraphicsForwardContact(
      float3(_73, _74, _75), float3(_404, _405, _406), SV_Position.xy, true));
  bool _485 = (_477.y > 0.0f);
  if (_485) {
    float _487 = dot(float3(_404, _405, _406), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
    float _488 = _487 + 0.25f;
    float _489 = _488 * 0.800000011920929f;
    float _490 = saturate(_489);
    float _491 = _490 + _487;
    float _492 = _490 + 1.0f;
    float _493 = _491 / _492;
    float _494 = 1.0f / _492;
    float _495 = saturate(_493);
    bool _496 = (_455 == 1);
    if (_496) {
      float _498 = saturate(_487);
      bool _499 = (_406 > 0.0f);
      int _500 = (int)(uint)(_499);
      int _501 = _500 << 1u;
      int _502 = _501 + -1;
      float _503 = float((int)(_502));
      float _504 = _503 + _406;
      float _505 = -1.0f / _504;
      float _506 = _404 * _405;
      float _507 = _506 * _505;
      float _508 = _404 * _404;
      float _509 = _508 * _503;
      float _510 = _509 * _505;
      float _511 = _510 + 1.0f;
      float _512 = _507 * _503;
      int _513 = 1 - _501;
      float _514 = float((int)(_513));
      float _515 = _514 * _404;
      float _516 = _405 * _405;
      float _517 = _516 * _505;
      float _518 = _517 + _503;
      float _519 = -0.0f - _405;
      float _520 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
      float _521 = rsqrt(_520);
      float _522 = _521 * water_light.sun.x;
      float _523 = _521 * water_light.sun.y;
      float _524 = _521 * water_light.sun.z;
      float _525 = _522 * _511;
      float _526 = mad(_512, _523, _525);
      float _527 = mad(_515, _524, _526);
      float _528 = _522 * _507;
      float _529 = mad(_518, _523, _528);
      float _530 = mad(_519, _524, _529);
      float _531 = _522 * _404;
      float _532 = mad(_405, _523, _531);
      float _533 = mad(_406, _524, _532);
      float _534 = dot(float3(_527, _530, _533), float3(_527, _530, _533));
      float _535 = rsqrt(_534);
      float _536 = _535 * _527;
      float _537 = _535 * _530;
      float _538 = _535 * _533;
      float _539 = dot(float3(_473, _474, _475), float3(_473, _474, _475));
      float _540 = rsqrt(_539);
      float _541 = _540 * _473;
      float _542 = _540 * _474;
      float _543 = _540 * _475;
      float _544 = _541 * _511;
      float _545 = mad(_512, _542, _544);
      float _546 = mad(_515, _543, _545);
      float _547 = _541 * _507;
      float _548 = mad(_518, _542, _547);
      float _549 = mad(_519, _543, _548);
      float _550 = _541 * _404;
      float _551 = mad(_405, _542, _550);
      float _552 = mad(_406, _543, _551);
      float _553 = dot(float3(_546, _549, _552), float3(_546, _549, _552));
      float _554 = rsqrt(_553);
      float _555 = _554 * _546;
      float _556 = _554 * _549;
      float _557 = _554 * _552;
      float _558 = dot(float3(_536, _537, _538), float3(_555, _556, _557));
      float _559 = _557 * _538;
      float _560 = _558 - _559;
      bool _561 = (_560 > 0.0f);
      if (_561) {
        float _563 = max(_538, _557);
        float _564 = _560 / _563;
        _566 = _564;
      } else {
        _566 = _560;
      }
      float _567 = _566 * 0.20908956229686737f;
      float _568 = _567 + 0.25813528895378113f;
      float _569 = _568 * _387;
      float _570 = _568 * _388;
      float _571 = _568 * _389;
      float _572 = 1.0f - _557;
      float _573 = _572 * 0.07144299894571304f;
      float _574 = _573 + -0.332181453704834f;
      float _575 = _574 * _572;
      float _576 = _575 + 0.4918818771839142f;
      float _577 = _576 * _572;
      float _578 = _577 + 0.05710852891206741f;
      float _579 = _572 * 0.6568742394447327f;
      float _580 = _579 * _578;
      float _581 = 1.0f - _538;
      float _582 = _581 * 0.07144299894571304f;
      float _583 = _582 + -0.332181453704834f;
      float _584 = _583 * _581;
      float _585 = _584 + 0.4918818771839142f;
      float _586 = _585 * _581;
      float _587 = _586 + 0.05710852891206741f;
      float _588 = _581 * 0.6568742394447327f;
      float _589 = _588 * _587;
      float _590 = _387 * _387;
      float _591 = _388 * _388;
      float _592 = _389 * _389;
      float _593 = _590 * 0.8585715889930725f;
      float _594 = _591 * 0.8585715889930725f;
      float _595 = _592 * 0.8585715889930725f;
      float _596 = _387 * 0.1414284110069275f;
      float _597 = _388 * 0.1414284110069275f;
      float _598 = _389 * 0.1414284110069275f;
      float _599 = 1.0f - _596;
      float _600 = 1.0f - _597;
      float _601 = 1.0f - _598;
      float _602 = _593 / _599;
      float _603 = _594 / _600;
      float _604 = _595 / _601;
      float _605 = 0.1890440583229065f - _580;
      float _606 = max(1.0000000116860974e-07f, _605);
      float _607 = 0.1890440583229065f - _589;
      float _608 = max(1.0000000116860974e-07f, _607);
      float _609 = _606 * 2.250678300857544f;
      float _610 = _609 * _608;
      float _611 = _610 * _602;
      float _612 = _610 * _603;
      float _613 = _610 * _604;
      float _614 = _611 + _569;
      float _615 = _612 + _570;
      float _616 = _613 + _571;
      float _617 = _614 * _498;
      float _618 = _615 * _498;
      float _619 = _616 * _498;
      float _620 = _495 - _498;
      float _621 = max(0.0f, _620);
      float _622 = _621 * 0.31830987334251404f;
      float _623 = _622 * _387;
      float _624 = _622 * _388;
      float _625 = _622 * _389;
      float _626 = _617 + _623;
      float _627 = _618 + _624;
      float _628 = _619 + _625;
      float _629 = _626 * 3.1415927410125732f;
      float _630 = _627 * 3.1415927410125732f;
      float _631 = _628 * 3.1415927410125732f;
      _633 = _626;
      _634 = _627;
      _635 = _628;
      _636 = _629;
      _637 = _630;
      _638 = _631;
    } else {
      _633 = _495;
      _634 = _495;
      _635 = _495;
      _636 = _495;
      _637 = _495;
      _638 = _495;
    }
    bool _641 = (cb12_221x > 0.0f);
    float _642 = 1.0f - _399;
    float _643 = 1.0f - _400;
    float _644 = 1.0f - _401;
    if (_641) {
      float _646 = dot(float3(_404, _405, _406), float3(_473, _474, _475));
      float4 _649 = t43.SampleLevel(s10, float2(0.8999999761581421f, _646), 0.0f);
      float _652 = _649.x * _399;
      float _653 = _649.x * _400;
      float _654 = _649.x * _401;
      float _655 = _652 + _649.y;
      float _656 = _653 + _649.y;
      float _657 = _654 + _649.y;
      float _658 = _642 * 0.0476190485060215f;
      float _659 = _643 * 0.0476190485060215f;
      float _660 = _644 * 0.0476190485060215f;
      float _661 = _658 + _399;
      float _662 = _659 + _400;
      float _663 = _660 + _401;
      float _664 = 1.0f - _655;
      float _665 = 1.0f - _656;
      float _666 = 1.0f - _657;
      float _667 = _664 * _661;
      float _668 = _665 * _662;
      float _669 = _666 * _663;
      float _670 = 1.0f - _667;
      float _671 = 1.0f - _668;
      float _672 = 1.0f - _669;
      float _673 = max(_670, 0.0010000000474974513f);
      float _674 = max(_671, 0.0010000000474974513f);
      float _675 = max(_672, 0.0010000000474974513f);
      float _676 = _655 / _673;
      float _677 = _656 / _674;
      float _678 = _657 / _675;
      float _679 = min(_676, 1.0f);
      float _680 = min(_677, 1.0f);
      float _681 = min(_678, 1.0f);
      _717 = _679;
      _718 = _680;
      _719 = _681;
    } else {
      float _683 = water_light.sun.x + _473;
      float _684 = water_light.sun.y + _474;
      float _685 = water_light.sun.z + _475;
      float _686 = dot(float3(_683, _684, _685), float3(_683, _684, _685));
      float _687 = rsqrt(_686);
      float _688 = _687 * _683;
      float _689 = _687 * _684;
      float _690 = _687 * _685;
      float _691 = dot(float3(_688, _689, _690), float3(_473, _474, _475));
      float _692 = abs(_691);
      float _693 = 1.0f - _692;
      float _694 = saturate(_693);
      float _695 = _694 * _694;
      float _699 = max(0.0f, _642);
      float _700 = max(0.0f, _643);
      float _701 = max(0.0f, _644);
      float _702 = _695 * _695;
      float _703 = _702 * _694;
      float _704 = _703 * cb13_066x;
      float _705 = _704 * _699;
      float _706 = _704 * _700;
      float _707 = _704 * _701;
      float _708 = cb13_066z * 0.8999999761581421f;
      float _709 = _708 + 1.0f;
      float _710 = _705 / _709;
      float _711 = _706 / _709;
      float _712 = _707 / _709;
      float _713 = _710 + _399;
      float _714 = _711 + _400;
      float _715 = _712 + _401;
      _717 = _713;
      _718 = _714;
      _719 = _715;
    }
    float _720 = 1.0f - _717;
    float _721 = 1.0f - _718;
    float _722 = 1.0f - _719;
    float _723 = _720 * _633;
    float _724 = _721 * _634;
    float _725 = _722 * _635;
    int _726 = _455 & -3;
    bool _727 = (_726 == 0);
    float _728 = _723 * 0.31830987334251404f;
    float _729 = _724 * 0.31830987334251404f;
    float _730 = _725 * 0.31830987334251404f;
    float _731 = select(_727, _728, _723);
    float _732 = select(_727, _729, _724);
    float _733 = select(_727, _730, _725);
    float _734 = _73 - cb12_000x;
    float _735 = _74 - cb12_000y;
    float _736 = _734 * _734;
    float _737 = _735 * _735;
    float _738 = _736 + _737;
    float _739 = sqrt(_738);
    float _742 = cb12_219z * _75;
    float _744 = _742 + cb12_219w;
    float _745 = saturate(_744);
    float _754 = cb13_061x - cb13_062x;
    float _755 = cb13_061y - cb13_062y;
    float _756 = cb13_061z - cb13_062z;
    float _757 = _754 * _745;
    float _758 = _755 * _745;
    float _759 = _756 * _745;
    float _760 = _757 + cb13_062x;
    float _761 = _758 + cb13_062y;
    float _762 = _759 + cb13_062z;
    float _764 = cb12_219x * _739;
    float _766 = _764 + cb12_219y;
    float _767 = saturate(_766);
    float _772 = _760 - cb13_001x;
    float _773 = _761 - cb13_001y;
    float _774 = _762 - cb13_001z;
    float _775 = _772 * _767;
    float _776 = _773 * _767;
    float _777 = _774 * _767;
    float _778 = (_775 + cb13_001x) * water_light.direct.x;
    float _779 = (_776 + cb13_001y) * water_light.direct.y;
    float _780 = (_777 + cb13_001z) * water_light.direct.z;
    float _781 = _494 * graphics_sun_visibility;
    float _782 = _731 * _781;
    float _783 = _782 * _778;
    float _784 = _732 * _781;
    float _785 = _784 * _779;
    float _786 = _733 * _781;
    float _787 = _786 * _780;
    float _788 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_404, _405, _406));
    bool _789 = (_788 > 0.0f);
    [branch]
    if (_789) {
      float _791 = water_light.sun.x + _473;
      float _792 = water_light.sun.y + _474;
      float _793 = water_light.sun.z + _475;
      float _794 = dot(float3(_791, _792, _793), float3(_791, _792, _793));
      float _795 = rsqrt(_794);
      float _796 = _795 * _791;
      float _797 = _795 * _792;
      float _798 = _795 * _793;
      float _799 = dot(float3(_404, _405, _406), float3(_473, _474, _475));
      float _800 = saturate(_487);
      float _801 = dot(float3(_180, _181, _182), float3(_180, _181, _182));
      float _802 = rsqrt(_801);
      float _803 = _802 * _180;
      float _804 = _802 * _181;
      float _805 = _802 * _182;
      float _806 = dot(float3(_803, _804, _805), float3(_404, _405, _406));
      float _807 = _806 * _404;
      float _808 = _806 * _405;
      float _809 = _806 * _406;
      float _810 = _803 - _807;
      float _811 = _804 - _808;
      float _812 = _805 - _809;
      float _813 = dot(float3(_810, _811, _812), float3(_810, _811, _812));
      float _814 = rsqrt(_813);
      float _815 = _810 * _814;
      float _816 = _811 * _814;
      float _817 = _812 * _814;
      float _818 = _816 * _406;
      float _819 = _817 * _405;
      float _820 = _818 - _819;
      float _821 = _817 * _404;
      float _822 = _815 * _406;
      float _823 = _821 - _822;
      float _824 = _815 * _405;
      float _825 = _816 * _404;
      float _826 = _824 - _825;
      float _827 = dot(float3(_820, _823, _826), float3(_820, _823, _826));
      float _828 = rsqrt(_827);
      float _829 = _820 * _828;
      float _830 = _823 * _828;
      float _831 = _826 * _828;
      float _832 = dot(float3(_815, _816, _817), float3(_796, _797, _798));
      float _833 = _832 * 1.2345679998397827f;
      float _834 = _833 * _833;
      float _835 = dot(float3(_829, _830, _831), float3(_796, _797, _798));
      float _836 = _835 * 1.2345679998397827f;
      float _837 = _836 * _836;
      float _838 = dot(float3(_404, _405, _406), float3(_796, _797, _798));
      float _839 = saturate(_838);
      float _840 = _839 * _839;
      float _841 = _837 + _834;
      float _842 = _841 + _840;
      float _843 = _842 * _842;
      float _844 = 0.4851658046245575f / _843;
      float _845 = abs(_799);
      float _846 = dot(float3(_796, _797, _798), float3(_473, _474, _475));
      float _847 = abs(_846);
      float _848 = 1.0f - _847;
      float _849 = saturate(_848);
      float _850 = _849 * _849;
      float _854 = max(0.0f, _642);
      float _855 = max(0.0f, _643);
      float _856 = max(0.0f, _644);
      float _857 = _850 * _850;
      float _858 = _857 * _849;
      float _859 = _858 * cb13_066x;
      float _860 = _859 * _854;
      float _861 = _859 * _855;
      float _862 = _859 * _856;
      float _863 = cb13_066z * 0.8999999761581421f;
      float _864 = _863 + 1.0f;
      float _865 = _860 / _864;
      float _866 = _861 / _864;
      float _867 = _862 / _864;
      float _868 = _865 + _399;
      float _869 = _866 + _400;
      float _870 = _867 + _401;
      bool _872 = (cb12_221z > 0.0f);
      [branch]
      if (_872) {
        float _874 = saturate(_799);
        float _875 = _874 + _800;
        float _876 = _800 * 2.0f;
        float _877 = _876 * _874;
        float _878 = _875 - _877;
        float _879 = _878 * 0.809999942779541f;
        float _880 = _879 + _877;
        _895 = _880;
      } else {
        float _882 = _845 * _845;
        float _883 = _882 * 0.34390008449554443f;
        float _884 = _883 + 0.6560999155044556f;
        float _885 = sqrt(_884);
        float _886 = _885 * _800;
        float _887 = _800 * _800;
        float _888 = _887 * 0.34390008449554443f;
        float _889 = _888 + 0.6560999155044556f;
        float _890 = sqrt(_889);
        float _891 = _890 * _845;
        float _892 = _886 + 9.999999747378752e-05f;
        float _893 = _892 + _891;
        _895 = _893;
      }
      float _896 = 0.5f / _895;
      float _897 = _896 * _844;
      float _898 = _897 * _868;
      float _899 = _897 * _869;
      float _900 = _897 * _870;
      bool _902 = (cb12_221y > 0.0f);
      if (_902) {
        float _904 = dot(float3(_404, _405, _406), float3(_896, _896, _896));
        float4 _907 = t43.SampleLevel(s10, float2(0.8999999761581421f, _904), 0.0f);
        float _910 = _907.x * _399;
        float _911 = _907.x * _400;
        float _912 = _907.x * _401;
        float _913 = _910 + _907.y;
        float _914 = _911 + _907.y;
        float _915 = _912 + _907.y;
        float _916 = _642 * 0.0476190485060215f;
        float _917 = _643 * 0.0476190485060215f;
        float _918 = _644 * 0.0476190485060215f;
        float _919 = _916 + _399;
        float _920 = _917 + _400;
        float _921 = _918 + _401;
        float _922 = 1.0f - _913;
        float _923 = 1.0f - _914;
        float _924 = 1.0f - _915;
        float _925 = _922 * _919;
        float _926 = _923 * _920;
        float _927 = _924 * _921;
        float _928 = 1.0f - _925;
        float _929 = 1.0f - _926;
        float _930 = 1.0f - _927;
        float _931 = max(_928, 0.0010000000474974513f);
        float _932 = max(_929, 0.0010000000474974513f);
        float _933 = max(_930, 0.0010000000474974513f);
        float _934 = _913 / _931;
        float _935 = _914 / _932;
        float _936 = _915 / _933;
        float _937 = min(_934, 1.0f);
        float _938 = min(_935, 1.0f);
        float _939 = min(_936, 1.0f);
        float _940 = max(_913, 9.999999747378752e-05f);
        float _941 = max(_914, 9.999999747378752e-05f);
        float _942 = max(_915, 9.999999747378752e-05f);
        float _943 = _937 / _940;
        float _944 = _938 / _941;
        float _945 = _939 / _942;
        float _946 = _943 * _898;
        float _947 = _944 * _899;
        float _948 = _945 * _900;
        _950 = _946;
        _951 = _947;
        _952 = _948;
      } else {
        _950 = _898;
        _951 = _899;
        _952 = _900;
      }
      float _953 = _950 * _800;
      float _954 = _951 * _800;
      float _955 = _952 * _800;
      _957 = _953;
      _958 = _954;
      _959 = _955;
    } else {
      _957 = 0.0f;
      _958 = 0.0f;
      _959 = 0.0f;
    }
    float _960 = _778 * graphics_sun_visibility;
    float _961 = _960 * _957;
    float _962 = _779 * graphics_sun_visibility;
    float _963 = _962 * _958;
    float _964 = _780 * graphics_sun_visibility;
    float _965 = _964 * _959;
    _967 = _961;
    _968 = _963;
    _969 = _965;
    _970 = _783;
    _971 = _785;
    _972 = _787;
    _973 = _636;
    _974 = _637;
    _975 = _638;
  } else {
    _967 = 0.0f;
    _968 = 0.0f;
    _969 = 0.0f;
    _970 = 0.0f;
    _971 = 0.0f;
    _972 = 0.0f;
    _973 = 0.0f;
    _974 = 0.0f;
    _975 = 0.0f;
  }
  if (any(water_light.direct != 1.f)) {
    float3 native_environment = GraphicsForwardSunEnvironment(float3(_404, _405, _406), float3(_404, _405, _406),
        float3(_473, _474, _475), float3(cb13_000x, cb13_000y, cb13_000z), float3(_387, _388, _389), .9f, int(cb12_220y), .25f, _477.y);
    _973 = native_environment.x; _974 = native_environment.y; _975 = native_environment.z;
  }
  float _976 = min(_973, _477.y);
  float _977 = min(_974, _477.y);
  float _978 = min(_975, _477.y);
  _980 = _970;
  _981 = _971;
  _982 = _972;
  _983 = _967;
  _984 = _968;
  _985 = _969;
  _986 = 0;
  while(true) {
    int _987 = _986 + _463;
    uint _988 = _987 << 2u;
    int4 _990 = asint(t20.Load4(_988));
    bool _992 = ((uint)_990.x > (uint)255);
    [branch]
    if (!_992) {
      uint _994 = _990.x * 10;
      uint _995 = _994 + 68u;
      float _1000 = (cb13_raw[_995].x) - _73;
      float _1001 = (cb13_raw[_995].y) - _74;
      float _1002 = (cb13_raw[_995].z) - _75;
      float _1003 = _1000 * _1000;
      float _1004 = _1001 * _1001;
      float _1005 = _1003 + _1004;
      float _1006 = _1002 * _1002;
      float _1007 = _1005 + _1006;
      float _1008 = sqrt(_1007);
      float _1009 = _1008 * _1008;
      uint _1010 = _994 + 73u;
      float _1013 = _1009 * (cb13_raw[_1010].x);
      float _1015 = _1008 / (cb13_raw[_995].w);
      float _1016 = _1015 * _1015;
      float _1017 = _1016 * _1016;
      float _1018 = 1.0f - _1017;
      float _1019 = saturate(_1018);
      float _1020 = _1019 * _1019;
      uint _1021 = _994 + 71u;
      int _1024 = asint((cb13_raw[_1021].w));
      int _1025 = _1024 & 1;
      bool _1026 = (_1025 != 0);
      bool _1028 = ((cb13_raw[_1010].z) > 0.0f);
      uint _1029 = _994 + 74u;
      bool _1032 = ((cb13_raw[_1029].x) > 0.0f);
      uint _1033 = _994 + 77u;
      int _1036 = asint((cb13_raw[_1033].x));
      int _1037 = _1036 & 1;
      bool _1038 = (_1037 != 0);
      float _1039 = _1013 + 1.0f;
      float _1040 = _1020 / _1039;
      if (_1026) {
        uint _1042 = _994 + 70u;
        float _1047 = dot(float3(_1000, _1001, _1002), float3(_1000, _1001, _1002));
        float _1048 = rsqrt(_1047);
        float _1049 = _1000 * _1048;
        float _1050 = -0.0f - _1049;
        float _1051 = _1001 * _1048;
        float _1052 = -0.0f - _1051;
        float _1053 = _1002 * _1048;
        float _1054 = -0.0f - _1053;
        float _1055 = dot(float3(_1050, _1052, _1054), float3((cb13_raw[_1042].x), (cb13_raw[_1042].y), (cb13_raw[_1042].z)));
        uint _1056 = _994 + 72u;
        float _1060 = (cb13_raw[_1056].y) * _1055;
        float _1062 = _1060 + (cb13_raw[_1056].z);
        float _1063 = saturate(_1062);
        float _1064 = log2(_1063);
        float _1065 = _1064 * (cb13_raw[_1056].w);
        float _1066 = exp2(_1065);
        float _1067 = _1066 * _1040;
        _1069 = _1067;
      } else {
        _1069 = _1040;
      }
      bool _1070 = _1028 || _1038;
      bool _1071 = (_1069 > 0.0f);
      bool _1072 = _1070 && _1071;
      if (_1072) {
        float _1074 = -0.0f - _1000;
        float _1075 = -0.0f - _1001;
        float _1076 = -0.0f - _1002;
        if (_1026) {
          uint _1078 = _994 + 70u;
          uint _1083 = _994 + 75u;
          float _1088 = (cb13_raw[_1083].w) * (cb13_raw[_1078].y);
          float _1089 = (cb13_raw[_1083].z) * (cb13_raw[_1078].z);
          float _1090 = _1088 - _1089;
          float _1091 = (cb13_raw[_1083].y) * (cb13_raw[_1078].z);
          float _1092 = (cb13_raw[_1083].w) * (cb13_raw[_1078].x);
          float _1093 = _1091 - _1092;
          float _1094 = (cb13_raw[_1083].z) * (cb13_raw[_1078].x);
          float _1095 = (cb13_raw[_1083].y) * (cb13_raw[_1078].y);
          float _1096 = _1094 - _1095;
          float _1097 = _1090 * _1074;
          float _1098 = mad(_1093, _1075, _1097);
          float _1099 = mad(_1096, _1076, _1098);
          float _1100 = (cb13_raw[_1083].y) * _1074;
          float _1101 = mad((cb13_raw[_1083].z), _1075, _1100);
          float _1102 = mad((cb13_raw[_1083].w), _1076, _1101);
          float _1103 = (cb13_raw[_1078].x) * _1074;
          float _1104 = mad((cb13_raw[_1078].y), _1075, _1103);
          float _1105 = mad((cb13_raw[_1078].z), _1076, _1104);
          int _1108 = asint((cb13_raw[_1033].z));
          _1271 = _1099;
          _1272 = _1102;
          _1273 = _1105;
          _1274 = (cb13_raw[_1083].x);
          _1275 = _1108;
        } else {
          if (_1038) {
            uint _1111 = _994 + 72u;
            uint _1116 = _994 + 70u;
            float _1121 = (cb13_raw[_1116].y) * (cb13_raw[_1111].w);
            float _1122 = (cb13_raw[_1116].z) * (cb13_raw[_1111].z);
            float _1123 = _1121 - _1122;
            float _1124 = (cb13_raw[_1116].z) * (cb13_raw[_1111].y);
            float _1125 = (cb13_raw[_1116].x) * (cb13_raw[_1111].w);
            float _1126 = _1124 - _1125;
            float _1127 = (cb13_raw[_1116].x) * (cb13_raw[_1111].z);
            float _1128 = (cb13_raw[_1116].y) * (cb13_raw[_1111].y);
            float _1129 = _1127 - _1128;
            float _1130 = _1123 * _1074;
            float _1131 = mad(_1126, _1075, _1130);
            float _1132 = mad(_1129, _1076, _1131);
            float _1133 = (cb13_raw[_1116].x) * _1074;
            float _1134 = mad((cb13_raw[_1116].y), _1075, _1133);
            float _1135 = mad((cb13_raw[_1116].z), _1076, _1134);
            float _1136 = (cb13_raw[_1111].y) * _1074;
            float _1137 = mad((cb13_raw[_1111].z), _1075, _1136);
            float _1138 = mad((cb13_raw[_1111].w), _1076, _1137);
            float _1139 = -0.0f - _1132;
            float _1140 = -0.0f - _1135;
            float _1141 = -0.0f - _1138;
            float _1142 = _1139 / _1008;
            float _1143 = _1140 / _1008;
            float _1144 = _1141 / _1008;
            float _1145 = abs(_1142);
            float _1146 = abs(_1143);
            float _1147 = abs(_1144);
            int _1148 = _1036 & 4;
            bool _1149 = (_1148 == 0);
            float _1150 = max(_1146, _1147);
            bool _1151 = (_1145 > _1150);
            if (!_1149) {
              if (_1151) {
                bool _1154 = (_1142 > 0.0f);
                uint _1155 = _994 + 75u;
                if (_1154) {
                  _1181 = _1135;
                  _1182 = _1138;
                  _1183 = _1139;
                  _1184 = (cb13_raw[_1155].x);
                } else {
                  _1181 = _1140;
                  _1182 = _1138;
                  _1183 = _1132;
                  _1184 = (cb13_raw[_1155].y);
                }
              } else {
                float _1162 = max(_1145, _1147);
                bool _1163 = (_1146 > _1162);
                if (_1163) {
                  bool _1165 = (_1143 > 0.0f);
                  uint _1166 = _994 + 75u;
                  if (_1165) {
                    _1181 = _1139;
                    _1182 = _1138;
                    _1183 = _1140;
                    _1184 = (cb13_raw[_1166].z);
                  } else {
                    _1181 = _1132;
                    _1182 = _1138;
                    _1183 = _1135;
                    _1184 = (cb13_raw[_1166].w);
                  }
                } else {
                  bool _1173 = (_1144 > 0.0f);
                  uint _1174 = _994 + 76u;
                  if (_1173) {
                    _1181 = _1132;
                    _1182 = _1135;
                    _1183 = _1141;
                    _1184 = (cb13_raw[_1174].x);
                  } else {
                    _1181 = _1132;
                    _1182 = _1140;
                    _1183 = _1138;
                    _1184 = (cb13_raw[_1174].y);
                  }
                }
              }
              int _1186 = asint((cb13_raw[_1033].z));
              _1271 = _1181;
              _1272 = _1182;
              _1273 = _1183;
              _1274 = _1184;
              _1275 = _1186;
            } else {
              if (_1151) {
                bool _1189 = (_1142 > 0.0f);
                uint _1190 = _994 + 75u;
                int _1193 = asint((cb13_raw[_1033].z));
                if (_1189) {
                  _1271 = _1135;
                  _1272 = _1138;
                  _1273 = _1139;
                  _1274 = (cb13_raw[_1190].x);
                  _1275 = _1193;
                } else {
                  int _1198 = (uint)(_1193) >> 10;
                  _1271 = _1140;
                  _1272 = _1138;
                  _1273 = _1132;
                  _1274 = (cb13_raw[_1190].y);
                  _1275 = _1198;
                }
              } else {
                float _1200 = max(_1145, _1147);
                bool _1201 = (_1146 > _1200);
                if (_1201) {
                  bool _1203 = (_1143 > 0.0f);
                  uint _1204 = _994 + 75u;
                  if (_1203) {
                    int _1209 = asint((cb13_raw[_1033].z));
                    int _1210 = (uint)(_1209) >> 20;
                    _1271 = _1139;
                    _1272 = _1138;
                    _1273 = _1140;
                    _1274 = (cb13_raw[_1204].z);
                    _1275 = _1210;
                  } else {
                    int _1214 = asint((cb13_raw[_1033].w));
                    _1271 = _1132;
                    _1272 = _1138;
                    _1273 = _1135;
                    _1274 = (cb13_raw[_1204].w);
                    _1275 = _1214;
                  }
                } else {
                  bool _1216 = (_1144 > 0.0f);
                  uint _1217 = _994 + 76u;
                  int _1220 = asint((cb13_raw[_1033].w));
                  if (_1216) {
                    int _1223 = (uint)(_1220) >> 10;
                    _1271 = _1132;
                    _1272 = _1135;
                    _1273 = _1141;
                    _1274 = (cb13_raw[_1217].x);
                    _1275 = _1223;
                  } else {
                    int _1226 = (uint)(_1220) >> 20;
                    _1271 = _1132;
                    _1272 = _1140;
                    _1273 = _1138;
                    _1274 = (cb13_raw[_1217].y);
                    _1275 = _1226;
                  }
                }
              }
            }
          } else {
            float _1228 = _1000 / _1008;
            float _1229 = _1001 / _1008;
            float _1230 = _1002 / _1008;
            float _1231 = abs(_1228);
            float _1232 = abs(_1229);
            float _1233 = abs(_1230);
            float _1234 = max(_1232, _1233);
            bool _1235 = (_1231 > _1234);
            if (_1235) {
              bool _1237 = (_1228 > 0.0f);
              uint _1238 = _994 + 75u;
              if (_1237) {
                _1264 = _1075;
                _1265 = _1076;
                _1266 = _1000;
                _1267 = (cb13_raw[_1238].x);
              } else {
                _1264 = _1001;
                _1265 = _1076;
                _1266 = _1074;
                _1267 = (cb13_raw[_1238].y);
              }
            } else {
              float _1245 = max(_1231, _1233);
              bool _1246 = (_1232 > _1245);
              if (_1246) {
                bool _1248 = (_1229 > 0.0f);
                uint _1249 = _994 + 75u;
                if (_1248) {
                  _1264 = _1000;
                  _1265 = _1076;
                  _1266 = _1001;
                  _1267 = (cb13_raw[_1249].z);
                } else {
                  _1264 = _1074;
                  _1265 = _1076;
                  _1266 = _1075;
                  _1267 = (cb13_raw[_1249].w);
                }
              } else {
                bool _1256 = (_1230 > 0.0f);
                uint _1257 = _994 + 76u;
                if (_1256) {
                  _1264 = _1074;
                  _1265 = _1075;
                  _1266 = _1002;
                  _1267 = (cb13_raw[_1257].x);
                } else {
                  _1264 = _1074;
                  _1265 = _1001;
                  _1266 = _1076;
                  _1267 = (cb13_raw[_1257].y);
                }
              }
            }
            int _1269 = asint((cb13_raw[_1033].z));
            _1271 = _1264;
            _1272 = _1265;
            _1273 = _1266;
            _1274 = _1267;
            _1275 = _1269;
          }
        }
        float _1277 = _1271 * (cb13_raw[_1010].y);
        float _1278 = mad((cb13_raw[_1010].y), _1272, 0.0f);
        float _1279 = _1277 / _1273;
        float _1280 = _1278 / _1273;
        float _1281 = _1279 * 0.5f;
        float _1282 = _1280 * 0.5f;
        float _1283 = _1281 + 0.5f;
        float _1284 = 0.5f - _1282;
        if (_1028) {
          int _1286 = asint(_1274);
          int _1287 = (uint)(_1286) >> 18;
          int _1288 = _1287 & 4092;
          float _1289 = float((uint)_1288);
          bool _1290 = (_1288 == 0);
          [branch]
          if (!_1290) {
            int _1292 = (uint)(_1286) >> 30;
            float _1293 = float((uint)_1292);
            int _1294 = (uint)(_1286) >> 8;
            int _1295 = _1294 & 4092;
            float _1296 = float((uint)_1295);
            uint _1297 = _1286 << 2u;
            int _1298 = _1297 & 4092;
            float _1299 = float((uint)_1298);
            float _1300 = _1283 * _1289;
            float _1301 = _1284 * _1289;
            float _1302 = _1300 + _1299;
            float _1303 = _1301 + _1296;
            float _1306 = cb13_067x * _1302;
            float _1307 = cb13_067x * _1303;
            float _1310 = t9.SampleLevel(s10, float3(_1306, _1307, _1293), 0.0f);
            float _1312 = _1015 * 0.9900000095367432f;
            float _1313 = _1310.x - _1312;
            float _1314 = _1313 * 144.26950073242188f;
            float _1315 = exp2(_1314);
            float _1316 = saturate(_1315);
            _1318 = _1316;
          } else {
            _1318 = 1.0f;
          }
        } else {
          _1318 = 1.0f;
        }
        if (_1038) {
          int _1320 = _1036 & 2;
          bool _1321 = (_1320 != 0);
          int _1322 = _1036 & 8;
          bool _1323 = (_1322 == 0);
          if (_1321) {
            int _1325 = _1275 & 1023;
            _1331 = _1325;
            _1332 = 0;
          } else {
            int _1327 = _1275 & 255;
            int _1328 = (uint)(_1275) >> 8;
            int _1329 = _1328 & 3;
            _1331 = _1327;
            _1332 = _1329;
          }
          float _1333 = float((uint)_1331);
          float _1335 = floor(cb13_raw[_1033].y);
          float _1336 = _1335 + _1333;
          float4 _1340 = t42.SampleLevel(s10, float3(_1283, _1284, _1336), 0.0f);
          _36[0] = _1340.x;
          _36[1] = _1340.y;
          _36[2] = _1340.z;
          _36[3] = _1340.w;
          if (!_1323) {
            float _1350 = _1336 + 1.0f;
            float4 _1351 = t42.SampleLevel(s10, float3(_1283, _1284, _1350), 0.0f);
            float _1356 = frac(cb13_raw[_1033].y);
            float _1357 = _1351.x - _1340.x;
            float _1358 = _1351.y - _1340.y;
            float _1359 = _1351.z - _1340.z;
            float _1360 = _1351.w - _1340.w;
            float _1361 = _1357 * _1356;
            float _1362 = _1358 * _1356;
            float _1363 = _1359 * _1356;
            float _1364 = _1360 * _1356;
            float _1365 = _1361 + _1340.x;
            float _1366 = _1362 + _1340.y;
            float _1367 = _1363 + _1340.z;
            float _1368 = _1364 + _1340.w;
            _36[0] = _1365;
            _36[1] = _1366;
            _36[2] = _1367;
            _36[3] = _1368;
            _1370 = _1367;
            _1371 = _1366;
            _1372 = _1365;
          } else {
            _1370 = _1340.z;
            _1371 = _1340.y;
            _1372 = _1340.x;
          }
          if (!_1321) {
            float _1375 = _36[_1332];
            _1377 = _1375;
            _1378 = _1375;
            _1379 = _1375;
          } else {
            _1377 = _1372;
            _1378 = _1371;
            _1379 = _1370;
          }
          _1381 = _1318;
          _1382 = _1377;
          _1383 = _1378;
          _1384 = _1379;
        } else {
          _1381 = _1318;
          _1382 = 1.0f;
          _1383 = 1.0f;
          _1384 = 1.0f;
        }
      } else {
        _1381 = 1.0f;
        _1382 = 1.0f;
        _1383 = 1.0f;
        _1384 = 1.0f;
      }
      bool _1385 = _1032 && _1071;
      if (_1385) {
        float _1390 = t10.SampleLevel(s10, float4(_1000, _1001, _1002, (cb13_raw[_1029].y)), 0.0f);
        float _1392 = _1015 * 0.9900000095367432f;
        float _1393 = _1390.x - _1392;
        float _1394 = _1393 * 144.26950073242188f;
        float _1395 = exp2(_1394);
        float _1396 = saturate(_1395);
        float _1397 = _1396 * _1381;
        _1399 = _1397;
      } else {
        _1399 = _1381;
      }
      uint _1400 = _994 + 70u;
      float _1403 = _1399 + -1.0f;
      float _1404 = (cb13_raw[_1400].w) * _1403;
      float _1405 = _1404 + 1.0f;
      int _1406 = _1024 & 2048;
      bool _1407 = (_1406 != 0);
      bool _1408 = (_477.z == 1.0f);
      bool _1409 = _1408 || _1407;
      if (_1409) {
        _1414 = cb12_071y;
      } else {
        _1414 = 0.0f;
      }
      int _1415 = _1024 & 4096;
      bool _1416 = (_1415 != 0);
      bool _1417 = !(_477.z == 1.0f);
      bool _1418 = _1417 || _1416;
      if (_1418) {
        _1423 = cb12_071z;
      } else {
        _1423 = 0.0f;
      }
      float _1424 = _1405 * _1069;
      float _1425 = _1424 * _1414;
      float _1426 = _1425 * _1423;
      float _1427 = _1426 * _1382;
      float _1428 = _1426 * _1383;
      float _1429 = _1426 * _1384;
      bool _1430 = (_1427 > 0.0f);
      bool _1431 = (_1428 > 0.0f);
      bool _1432 = (_1429 > 0.0f);
      bool _1433 = _1430 || _1431;
      bool _1434 = _1432 || _1433;
      [branch]
      if (_1434) {
        bool _1438 = (FrequentPixelConsts_256.x < 0.0f);
        if (!_1438) {
          _1443 = cb12_071x;
        } else {
          _1443 = 1.0f;
        }
        bool _1444 = ((int)_1024 < (int)0);
        float _1445 = select(_1444, _1443, 1.0f);
        float _1446 = _1445 * _1427;
        float _1447 = _1445 * _1428;
        float _1448 = _1445 * _1429;
        float _1449 = dot(float3(_1000, _1001, _1002), float3(_1000, _1001, _1002));
        float _1450 = rsqrt(_1449);
        float _1451 = _1450 * _1000;
        float _1452 = _1450 * _1001;
        float _1453 = _1450 * _1002;
        float _1454 = dot(float3(_404, _405, _406), float3(_1451, _1452, _1453));
        float _1455 = _1454 + 0.25f;
        float _1456 = _1455 * 0.800000011920929f;
        float _1457 = saturate(_1456);
        float _1458 = _1457 + _1454;
        float _1459 = _1457 + 1.0f;
        float _1460 = _1458 / _1459;
        float _1461 = 1.0f / _1459;
        float _1462 = saturate(_1460);
        bool _1463 = (_455 == 1);
        if (_1463) {
          float _1465 = saturate(_1454);
          bool _1466 = (_406 > 0.0f);
          int _1467 = (int)(uint)(_1466);
          int _1468 = _1467 << 1u;
          int _1469 = _1468 + -1;
          float _1470 = float((int)(_1469));
          float _1471 = _1470 + _406;
          float _1472 = -1.0f / _1471;
          float _1473 = _404 * _405;
          float _1474 = _1473 * _1472;
          float _1475 = _404 * _404;
          float _1476 = _1475 * _1470;
          float _1477 = _1476 * _1472;
          float _1478 = _1477 + 1.0f;
          float _1479 = _1474 * _1470;
          int _1480 = 1 - _1468;
          float _1481 = float((int)(_1480));
          float _1482 = _1481 * _404;
          float _1483 = _405 * _405;
          float _1484 = _1483 * _1472;
          float _1485 = _1484 + _1470;
          float _1486 = -0.0f - _405;
          float _1487 = dot(float3(_1451, _1452, _1453), float3(_1451, _1452, _1453));
          float _1488 = rsqrt(_1487);
          float _1489 = _1488 * _1451;
          float _1490 = _1488 * _1452;
          float _1491 = _1488 * _1453;
          float _1492 = _1489 * _1478;
          float _1493 = mad(_1479, _1490, _1492);
          float _1494 = mad(_1482, _1491, _1493);
          float _1495 = _1489 * _1474;
          float _1496 = mad(_1485, _1490, _1495);
          float _1497 = mad(_1486, _1491, _1496);
          float _1498 = _1489 * _404;
          float _1499 = mad(_405, _1490, _1498);
          float _1500 = mad(_406, _1491, _1499);
          float _1501 = dot(float3(_1494, _1497, _1500), float3(_1494, _1497, _1500));
          float _1502 = rsqrt(_1501);
          float _1503 = _1502 * _1494;
          float _1504 = _1502 * _1497;
          float _1505 = _1502 * _1500;
          float _1506 = dot(float3(_473, _474, _475), float3(_473, _474, _475));
          float _1507 = rsqrt(_1506);
          float _1508 = _1507 * _473;
          float _1509 = _1507 * _474;
          float _1510 = _1507 * _475;
          float _1511 = _1508 * _1478;
          float _1512 = mad(_1479, _1509, _1511);
          float _1513 = mad(_1482, _1510, _1512);
          float _1514 = _1508 * _1474;
          float _1515 = mad(_1485, _1509, _1514);
          float _1516 = mad(_1486, _1510, _1515);
          float _1517 = _1508 * _404;
          float _1518 = mad(_405, _1509, _1517);
          float _1519 = mad(_406, _1510, _1518);
          float _1520 = dot(float3(_1513, _1516, _1519), float3(_1513, _1516, _1519));
          float _1521 = rsqrt(_1520);
          float _1522 = _1521 * _1513;
          float _1523 = _1521 * _1516;
          float _1524 = _1521 * _1519;
          float _1525 = dot(float3(_1503, _1504, _1505), float3(_1522, _1523, _1524));
          float _1526 = _1524 * _1505;
          float _1527 = _1525 - _1526;
          bool _1528 = (_1527 > 0.0f);
          if (_1528) {
            float _1530 = max(_1505, _1524);
            float _1531 = _1527 / _1530;
            _1533 = _1531;
          } else {
            _1533 = _1527;
          }
          float _1534 = _1533 * 0.20908956229686737f;
          float _1535 = _1534 + 0.25813528895378113f;
          float _1536 = _1535 * _387;
          float _1537 = _1535 * _388;
          float _1538 = _1535 * _389;
          float _1539 = 1.0f - _1524;
          float _1540 = _1539 * 0.07144299894571304f;
          float _1541 = _1540 + -0.332181453704834f;
          float _1542 = _1541 * _1539;
          float _1543 = _1542 + 0.4918818771839142f;
          float _1544 = _1543 * _1539;
          float _1545 = _1544 + 0.05710852891206741f;
          float _1546 = _1539 * 0.6568742394447327f;
          float _1547 = _1546 * _1545;
          float _1548 = 1.0f - _1505;
          float _1549 = _1548 * 0.07144299894571304f;
          float _1550 = _1549 + -0.332181453704834f;
          float _1551 = _1550 * _1548;
          float _1552 = _1551 + 0.4918818771839142f;
          float _1553 = _1552 * _1548;
          float _1554 = _1553 + 0.05710852891206741f;
          float _1555 = _1548 * 0.6568742394447327f;
          float _1556 = _1555 * _1554;
          float _1557 = _387 * _387;
          float _1558 = _388 * _388;
          float _1559 = _389 * _389;
          float _1560 = _1557 * 0.8585715889930725f;
          float _1561 = _1558 * 0.8585715889930725f;
          float _1562 = _1559 * 0.8585715889930725f;
          float _1563 = _387 * 0.1414284110069275f;
          float _1564 = _388 * 0.1414284110069275f;
          float _1565 = _389 * 0.1414284110069275f;
          float _1566 = 1.0f - _1563;
          float _1567 = 1.0f - _1564;
          float _1568 = 1.0f - _1565;
          float _1569 = _1560 / _1566;
          float _1570 = _1561 / _1567;
          float _1571 = _1562 / _1568;
          float _1572 = 0.1890440583229065f - _1547;
          float _1573 = max(1.0000000116860974e-07f, _1572);
          float _1574 = 0.1890440583229065f - _1556;
          float _1575 = max(1.0000000116860974e-07f, _1574);
          float _1576 = _1573 * 2.250678300857544f;
          float _1577 = _1576 * _1575;
          float _1578 = _1577 * _1569;
          float _1579 = _1577 * _1570;
          float _1580 = _1577 * _1571;
          float _1581 = _1578 + _1536;
          float _1582 = _1579 + _1537;
          float _1583 = _1580 + _1538;
          float _1584 = _1581 * _1465;
          float _1585 = _1582 * _1465;
          float _1586 = _1583 * _1465;
          float _1587 = _1462 - _1465;
          float _1588 = max(0.0f, _1587);
          float _1589 = _1588 * 0.31830987334251404f;
          float _1590 = _1589 * _387;
          float _1591 = _1589 * _388;
          float _1592 = _1589 * _389;
          float _1593 = _1584 + _1590;
          float _1594 = _1585 + _1591;
          float _1595 = _1586 + _1592;
          _1597 = _1593;
          _1598 = _1594;
          _1599 = _1595;
        } else {
          _1597 = _1462;
          _1598 = _1462;
          _1599 = _1462;
        }
        bool _1602 = (cb12_221x > 0.0f);
        float _1603 = 1.0f - _399;
        float _1604 = 1.0f - _400;
        float _1605 = 1.0f - _401;
        if (_1602) {
          float _1607 = dot(float3(_404, _405, _406), float3(_473, _474, _475));
          float4 _1610 = t43.SampleLevel(s10, float2(0.8999999761581421f, _1607), 0.0f);
          float _1613 = _1610.x * _399;
          float _1614 = _1610.x * _400;
          float _1615 = _1610.x * _401;
          float _1616 = _1613 + _1610.y;
          float _1617 = _1614 + _1610.y;
          float _1618 = _1615 + _1610.y;
          float _1619 = _1603 * 0.0476190485060215f;
          float _1620 = _1604 * 0.0476190485060215f;
          float _1621 = _1605 * 0.0476190485060215f;
          float _1622 = _1619 + _399;
          float _1623 = _1620 + _400;
          float _1624 = _1621 + _401;
          float _1625 = 1.0f - _1616;
          float _1626 = 1.0f - _1617;
          float _1627 = 1.0f - _1618;
          float _1628 = _1625 * _1622;
          float _1629 = _1626 * _1623;
          float _1630 = _1627 * _1624;
          float _1631 = 1.0f - _1628;
          float _1632 = 1.0f - _1629;
          float _1633 = 1.0f - _1630;
          float _1634 = max(_1631, 0.0010000000474974513f);
          float _1635 = max(_1632, 0.0010000000474974513f);
          float _1636 = max(_1633, 0.0010000000474974513f);
          float _1637 = _1616 / _1634;
          float _1638 = _1617 / _1635;
          float _1639 = _1618 / _1636;
          float _1640 = min(_1637, 1.0f);
          float _1641 = min(_1638, 1.0f);
          float _1642 = min(_1639, 1.0f);
          _1678 = _1640;
          _1679 = _1641;
          _1680 = _1642;
        } else {
          float _1644 = _1451 + _473;
          float _1645 = _1452 + _474;
          float _1646 = _1453 + _475;
          float _1647 = dot(float3(_1644, _1645, _1646), float3(_1644, _1645, _1646));
          float _1648 = rsqrt(_1647);
          float _1649 = _1648 * _1644;
          float _1650 = _1648 * _1645;
          float _1651 = _1648 * _1646;
          float _1652 = dot(float3(_1649, _1650, _1651), float3(_473, _474, _475));
          float _1653 = abs(_1652);
          float _1654 = 1.0f - _1653;
          float _1655 = saturate(_1654);
          float _1656 = _1655 * _1655;
          float _1660 = max(0.0f, _1603);
          float _1661 = max(0.0f, _1604);
          float _1662 = max(0.0f, _1605);
          float _1663 = _1656 * _1656;
          float _1664 = _1663 * _1655;
          float _1665 = _1664 * cb13_066x;
          float _1666 = _1665 * _1660;
          float _1667 = _1665 * _1661;
          float _1668 = _1665 * _1662;
          float _1669 = cb13_066z * 0.8999999761581421f;
          float _1670 = _1669 + 1.0f;
          float _1671 = _1666 / _1670;
          float _1672 = _1667 / _1670;
          float _1673 = _1668 / _1670;
          float _1674 = _1671 + _399;
          float _1675 = _1672 + _400;
          float _1676 = _1673 + _401;
          _1678 = _1674;
          _1679 = _1675;
          _1680 = _1676;
        }
        float _1681 = 1.0f - _1678;
        float _1682 = 1.0f - _1679;
        float _1683 = 1.0f - _1680;
        float _1684 = _1681 * _1597;
        float _1685 = _1682 * _1598;
        float _1686 = _1683 * _1599;
        int _1687 = _455 & -3;
        bool _1688 = (_1687 == 0);
        float _1689 = _1684 * 0.31830987334251404f;
        float _1690 = _1685 * 0.31830987334251404f;
        float _1691 = _1686 * 0.31830987334251404f;
        float _1692 = select(_1688, _1689, _1684);
        float _1693 = select(_1688, _1690, _1685);
        float _1694 = select(_1688, _1691, _1686);
        float _1698 = _1446 * (cb13_raw[_1021].x);
        float _1699 = _1698 * _1461;
        float _1700 = _1699 * _1692;
        float _1701 = _1447 * (cb13_raw[_1021].y);
        float _1702 = _1701 * _1461;
        float _1703 = _1702 * _1693;
        float _1704 = _1448 * (cb13_raw[_1021].z);
        float _1705 = _1704 * _1461;
        float _1706 = _1705 * _1694;
        float _1707 = _1700 + _980;
        float _1708 = _1703 + _981;
        float _1709 = _1706 + _982;
        float _1710 = dot(float3(_1451, _1452, _1453), float3(_404, _405, _406));
        bool _1711 = (_1710 > 0.0f);
        [branch]
        if (_1711) {
          float _1713 = _1451 + _473;
          float _1714 = _1452 + _474;
          float _1715 = _1453 + _475;
          float _1716 = dot(float3(_1713, _1714, _1715), float3(_1713, _1714, _1715));
          float _1717 = rsqrt(_1716);
          float _1718 = _1717 * _1713;
          float _1719 = _1717 * _1714;
          float _1720 = _1717 * _1715;
          float _1721 = dot(float3(_404, _405, _406), float3(_473, _474, _475));
          float _1722 = saturate(_1454);
          float _1723 = dot(float3(_180, _181, _182), float3(_180, _181, _182));
          float _1724 = rsqrt(_1723);
          float _1725 = _1724 * _180;
          float _1726 = _1724 * _181;
          float _1727 = _1724 * _182;
          float _1728 = dot(float3(_1725, _1726, _1727), float3(_404, _405, _406));
          float _1729 = _1728 * _404;
          float _1730 = _1728 * _405;
          float _1731 = _1728 * _406;
          float _1732 = _1725 - _1729;
          float _1733 = _1726 - _1730;
          float _1734 = _1727 - _1731;
          float _1735 = dot(float3(_1732, _1733, _1734), float3(_1732, _1733, _1734));
          float _1736 = rsqrt(_1735);
          float _1737 = _1732 * _1736;
          float _1738 = _1733 * _1736;
          float _1739 = _1734 * _1736;
          float _1740 = _1738 * _406;
          float _1741 = _1739 * _405;
          float _1742 = _1740 - _1741;
          float _1743 = _1739 * _404;
          float _1744 = _1737 * _406;
          float _1745 = _1743 - _1744;
          float _1746 = _1737 * _405;
          float _1747 = _1738 * _404;
          float _1748 = _1746 - _1747;
          float _1749 = dot(float3(_1742, _1745, _1748), float3(_1742, _1745, _1748));
          float _1750 = rsqrt(_1749);
          float _1751 = _1742 * _1750;
          float _1752 = _1745 * _1750;
          float _1753 = _1748 * _1750;
          float _1754 = dot(float3(_1737, _1738, _1739), float3(_1718, _1719, _1720));
          float _1755 = _1754 * 1.2345679998397827f;
          float _1756 = _1755 * _1755;
          float _1757 = dot(float3(_1751, _1752, _1753), float3(_1718, _1719, _1720));
          float _1758 = _1757 * 1.2345679998397827f;
          float _1759 = _1758 * _1758;
          float _1760 = dot(float3(_404, _405, _406), float3(_1718, _1719, _1720));
          float _1761 = saturate(_1760);
          float _1762 = _1761 * _1761;
          float _1763 = _1759 + _1756;
          float _1764 = _1763 + _1762;
          float _1765 = _1764 * _1764;
          float _1766 = 0.4851658046245575f / _1765;
          float _1767 = abs(_1721);
          float _1768 = dot(float3(_1718, _1719, _1720), float3(_473, _474, _475));
          float _1769 = abs(_1768);
          float _1770 = 1.0f - _1769;
          float _1771 = saturate(_1770);
          float _1772 = _1771 * _1771;
          float _1776 = max(0.0f, _1603);
          float _1777 = max(0.0f, _1604);
          float _1778 = max(0.0f, _1605);
          float _1779 = _1772 * _1772;
          float _1780 = _1779 * _1771;
          float _1781 = _1780 * cb13_066x;
          float _1782 = _1781 * _1776;
          float _1783 = _1781 * _1777;
          float _1784 = _1781 * _1778;
          float _1785 = cb13_066z * 0.8999999761581421f;
          float _1786 = _1785 + 1.0f;
          float _1787 = _1782 / _1786;
          float _1788 = _1783 / _1786;
          float _1789 = _1784 / _1786;
          float _1790 = _1787 + _399;
          float _1791 = _1788 + _400;
          float _1792 = _1789 + _401;
          bool _1794 = (cb12_221z > 0.0f);
          [branch]
          if (_1794) {
            float _1796 = saturate(_1721);
            float _1797 = _1796 + _1722;
            float _1798 = _1722 * 2.0f;
            float _1799 = _1798 * _1796;
            float _1800 = _1797 - _1799;
            float _1801 = _1800 * 0.809999942779541f;
            float _1802 = _1801 + _1799;
            _1817 = _1802;
          } else {
            float _1804 = _1767 * _1767;
            float _1805 = _1804 * 0.34390008449554443f;
            float _1806 = _1805 + 0.6560999155044556f;
            float _1807 = sqrt(_1806);
            float _1808 = _1807 * _1722;
            float _1809 = _1722 * _1722;
            float _1810 = _1809 * 0.34390008449554443f;
            float _1811 = _1810 + 0.6560999155044556f;
            float _1812 = sqrt(_1811);
            float _1813 = _1812 * _1767;
            float _1814 = _1808 + 9.999999747378752e-05f;
            float _1815 = _1814 + _1813;
            _1817 = _1815;
          }
          float _1818 = 0.5f / _1817;
          float _1819 = _1818 * _1766;
          float _1820 = _1819 * _1790;
          float _1821 = _1819 * _1791;
          float _1822 = _1819 * _1792;
          bool _1824 = (cb12_221y > 0.0f);
          if (_1824) {
            float _1826 = dot(float3(_404, _405, _406), float3(_1818, _1818, _1818));
            float4 _1829 = t43.SampleLevel(s10, float2(0.8999999761581421f, _1826), 0.0f);
            float _1832 = _1829.x * _399;
            float _1833 = _1829.x * _400;
            float _1834 = _1829.x * _401;
            float _1835 = _1832 + _1829.y;
            float _1836 = _1833 + _1829.y;
            float _1837 = _1834 + _1829.y;
            float _1838 = _1603 * 0.0476190485060215f;
            float _1839 = _1604 * 0.0476190485060215f;
            float _1840 = _1605 * 0.0476190485060215f;
            float _1841 = _1838 + _399;
            float _1842 = _1839 + _400;
            float _1843 = _1840 + _401;
            float _1844 = 1.0f - _1835;
            float _1845 = 1.0f - _1836;
            float _1846 = 1.0f - _1837;
            float _1847 = _1844 * _1841;
            float _1848 = _1845 * _1842;
            float _1849 = _1846 * _1843;
            float _1850 = 1.0f - _1847;
            float _1851 = 1.0f - _1848;
            float _1852 = 1.0f - _1849;
            float _1853 = max(_1850, 0.0010000000474974513f);
            float _1854 = max(_1851, 0.0010000000474974513f);
            float _1855 = max(_1852, 0.0010000000474974513f);
            float _1856 = _1835 / _1853;
            float _1857 = _1836 / _1854;
            float _1858 = _1837 / _1855;
            float _1859 = min(_1856, 1.0f);
            float _1860 = min(_1857, 1.0f);
            float _1861 = min(_1858, 1.0f);
            float _1862 = max(_1835, 9.999999747378752e-05f);
            float _1863 = max(_1836, 9.999999747378752e-05f);
            float _1864 = max(_1837, 9.999999747378752e-05f);
            float _1865 = _1859 / _1862;
            float _1866 = _1860 / _1863;
            float _1867 = _1861 / _1864;
            float _1868 = _1865 * _1820;
            float _1869 = _1866 * _1821;
            float _1870 = _1867 * _1822;
            _1872 = _1868;
            _1873 = _1869;
            _1874 = _1870;
          } else {
            _1872 = _1820;
            _1873 = _1821;
            _1874 = _1822;
          }
          float _1875 = _1872 * _1722;
          float _1876 = _1873 * _1722;
          float _1877 = _1874 * _1722;
          _1879 = _1875;
          _1880 = _1876;
          _1881 = _1877;
        } else {
          _1879 = 0.0f;
          _1880 = 0.0f;
          _1881 = 0.0f;
        }
        float _1882 = _1698 * _1879;
        float _1883 = _1701 * _1880;
        float _1884 = _1704 * _1881;
        float _1885 = _1882 + _983;
        float _1886 = _1883 + _984;
        float _1887 = _1884 + _985;
        _1889 = _1707;
        _1890 = _1708;
        _1891 = _1709;
        _1892 = _1885;
        _1893 = _1886;
        _1894 = _1887;
      } else {
        _1889 = _980;
        _1890 = _981;
        _1891 = _982;
        _1892 = _983;
        _1893 = _984;
        _1894 = _985;
      }
      int _1895 = _986 + 1;
      bool _1896 = ((int)_1895 < (int)256);
      if (_1896) {
        _980 = _1889;
        _981 = _1890;
        _982 = _1891;
        _983 = _1892;
        _984 = _1893;
        _985 = _1894;
        _986 = _1895;
        continue;
      } else {
        _1898 = _1889;
        _1899 = _1890;
        _1900 = _1891;
        _1901 = _1892;
        _1902 = _1893;
        _1903 = _1894;
      }
    } else {
      _1898 = _980;
      _1899 = _981;
      _1900 = _982;
      _1901 = _983;
      _1902 = _984;
      _1903 = _985;
    }
    break;
  }
  float _1904 = -0.0f - _473;
  float _1905 = -0.0f - _474;
  float _1906 = -0.0f - _475;
  float _1907 = dot(float3(_1904, _1905, _1906), float3(_404, _405, _406));
  float _1908 = _1907 * 2.0f;
  float _1909 = _1908 * _404;
  float _1910 = _1908 * _405;
  float _1911 = _1908 * _406;
  float _1912 = _1904 - _1909;
  float _1913 = _1905 - _1910;
  float _1914 = _1906 - _1911;
  float _1915 = dot(float3(_1912, _1913, _1914), float3(_1912, _1913, _1914));
  float _1916 = rsqrt(_1915);
  float _1917 = _1912 * _1916;
  float _1918 = _1913 * _1916;
  float _1919 = _1914 * _1916;
  float _1920 = ddx_coarse(_1917);
  float _1921 = ddx_coarse(_1918);
  float _1922 = ddx_coarse(_1919);
  float _1923 = ddy_coarse(_1917);
  float _1924 = ddy_coarse(_1918);
  float _1925 = ddy_coarse(_1919);
  int _1926 = _446 & 1;
  bool _1927 = (_1926 != 0);
  float _1928 = -0.0f - _1920;
  float _1929 = -0.0f - _1921;
  float _1930 = -0.0f - _1922;
  float _1931 = select(_1927, _1928, _1920);
  float _1932 = select(_1927, _1929, _1921);
  float _1933 = select(_1927, _1930, _1922);
  int _1934 = _447 & 1;
  bool _1935 = (_1934 != 0);
  float _1936 = -0.0f - _1923;
  float _1937 = -0.0f - _1924;
  float _1938 = -0.0f - _1925;
  float _1939 = select(_1935, _1936, _1923);
  float _1940 = select(_1935, _1937, _1924);
  float _1941 = select(_1935, _1938, _1925);
  float _1942 = _1939 + _1917;
  float _1943 = _1940 + _1918;
  float _1944 = _1941 + _1919;
  float _1945 = dot(float3(_1942, _1943, _1944), float3(_1942, _1943, _1944));
  float _1946 = rsqrt(_1945);
  float _1947 = _1946 * _1942;
  float _1948 = _1946 * _1943;
  float _1949 = _1944 * _1946;
  float _1950 = dot(float3(_1917, _1918, _1919), float3(_1947, _1948, _1949));
  float _1951 = acos(_1950);
  float _1952 = _1951 * 81.4873275756836f;
  float _1953 = log2(_1952);
  float _1954 = max(0.0f, _1953);
  float _1955 = _1931 + _1917;
  float _1956 = _1932 + _1918;
  float _1957 = _1933 + _1919;
  float _1958 = dot(float3(_1955, _1956, _1957), float3(_1955, _1956, _1957));
  float _1959 = rsqrt(_1958);
  float _1960 = _1959 * _1955;
  float _1961 = _1959 * _1956;
  float _1962 = _1959 * _1957;
  float _1963 = dot(float3(_1917, _1918, _1919), float3(_1960, _1961, _1962));
  float _1964 = acos(_1963);
  float _1965 = _1964 * 81.4873275756836f;
  float _1966 = log2(_1965);
  float _1967 = max(0.0f, _1966);
  float _1968 = max(_1967, _1954);
  float _1969 = _1968 * 0.625f;
  float _1970 = max(8.504999160766602f, _1969);
  float _1971 = max(_1970, 0.0f);
  float _1972 = min(_1971, 5.0f);
  bool _1973 = (_406 < 0.0f);
  float _1974 = _404 * 0.5f;
  float _1975 = _405 * -0.5f;
  float _1976 = 1.0f - _406;
  float _1977 = 1.0f / _1976;
  float _1978 = max(_1977, -3.4028234663852886e+38f);
  float _1979 = min(_1978, 3.4028234663852886e+38f);
  float _1980 = _1974 * _1979;
  float _1981 = _1975 * _1979;
  float _1982 = _404 * -0.5f;
  float _1983 = _405 * 0.5f;
  float _1984 = _406 + 1.0f;
  float _1985 = 1.0f / _1984;
  float _1986 = max(_1985, -3.4028234663852886e+38f);
  float _1987 = min(_1986, 3.4028234663852886e+38f);
  float _1988 = _1982 * _1987;
  float _1989 = _1983 * _1987;
  float _1990 = select(_1973, _1980, _1988);
  float _1991 = _1990 + 0.5f;
  float _1992 = select(_1973, _1981, _1989);
  float _1993 = _1992 + 0.5f;
  float _1994 = float((bool)_1973);
  if (_450) {
    float _1996 = _1991 * 0.9696969985961914f;
    float _1997 = _1993 * 0.9696969985961914f;
    float _1998 = _1997 + 0.01515151560306549f;
    float _1999 = _1994 + 0.01515151560306549f;
    float _2000 = _1999 + _1996;
    _2008 = _2000;
    _2009 = _1998;
  } else {
    float _2002 = _1991 * 0.6666666269302368f;
    float _2003 = _1993 * 0.6666666269302368f;
    float _2004 = _2003 + 0.1666666716337204f;
    float _2005 = _1994 + 0.1666666716337204f;
    float _2006 = _2005 + _2002;
    _2008 = _2006;
    _2009 = _2004;
  }
  float _2010 = _2008 * 0.5f;
  _2012 = 1;
  _2013 = 0.0f;
  _2014 = 0.0f;
  _2015 = 0.0f;
  _2016 = 0.0f;
  _2017 = 0.0f;
  _2018 = 0.0f;
  _2019 = 9.999999747378752e-06f;
  while(true) {
    int _2020 = _2012 * 12;
    int _2021 = _2020 + 102;
    int _2026 = _2020 + 103;
    int _2031 = _2020 + 104;
    int _2036 = _2020 + 105;
    float _2041 = (cb12_raw[_2021].x) * _73;
    float _2042 = mad((cb12_raw[_2026].x), _74, _2041);
    float _2043 = mad((cb12_raw[_2031].x), _75, _2042);
    float _2044 = _2043 + (cb12_raw[_2036].x);
    float _2045 = (cb12_raw[_2021].y) * _73;
    float _2046 = mad((cb12_raw[_2026].y), _74, _2045);
    float _2047 = mad((cb12_raw[_2031].y), _75, _2046);
    float _2048 = _2047 + (cb12_raw[_2036].y);
    float _2049 = (cb12_raw[_2021].z) * _73;
    float _2050 = mad((cb12_raw[_2026].z), _74, _2049);
    float _2051 = mad((cb12_raw[_2031].z), _75, _2050);
    float _2052 = _2051 + (cb12_raw[_2036].z);
    float _2053 = abs(_2044);
    float _2054 = abs(_2048);
    float _2055 = abs(_2052);
    float _2056 = 1.0f - _2053;
    float _2057 = 1.0f - _2054;
    float _2058 = 1.0f - _2055;
    int _2059 = _2020 + 106;
    int _2062 = asint((cb12_raw[_2059].y));
    bool _2063 = !(_477.z == -1.0f);
    [branch]
    if (_2063) {
      int _2065 = _2062 & 1;
      bool _2066 = (_2065 != 0);
      float _2067 = select(_2066, 1.0f, _477.z);
      int _2068 = _2062 & 2;
      bool _2069 = (_2068 != 0);
      float _2070 = 1.0f - _477.z;
      float _2071 = select(_2069, 1.0f, _2070);
      float _2072 = _2067 * _2071;
      _2074 = _2072;
    } else {
      _2074 = 1.0f;
    }
    bool _2075 = (_2056 > 0.0f);
    bool _2076 = (_2057 > 0.0f);
    bool _2077 = (_2058 > 0.0f);
    bool _2078 = _2075 && _2076;
    bool _2079 = _2078 && _2077;
    bool _2080 = (_2074 > 0.0f);
    bool _2081 = _2079 && _2080;
    if (_2081) {
      int _2083 = _2020 + 101;
      float _2088 = (cb12_raw[_2083].x) * _2056;
      float _2089 = (cb12_raw[_2083].y) * _2057;
      float _2090 = (cb12_raw[_2083].z) * _2058;
      float _2091 = saturate(_2088);
      float _2092 = saturate(_2089);
      float _2093 = saturate(_2090);
      float _2094 = 1.0f - _2019;
      float _2095 = _2074 * _2094;
      int _2096 = _2020 + 100;
      float _2099 = _2095 * _2091;
      float _2100 = _2099 * _2092;
      float _2101 = _2100 * _2093;
      float _2102 = _2101 * (cb12_raw[_2096].x);
      float _2103 = _2102 + _2019;
      float _2105 = _2102 * (cb12_raw[_2059].x);
      int _2106 = _2020 + 111;
      float _2109 = float((int)(asint(cb12_raw[_2106].x)));
      float _2110 = _2109 + _2009;
      float _2111 = _2110 * 0.1428571492433548f;
      if (_450) {
        float4 _2115 = t27.SampleLevel(s11, float2(_2010, _2111), 0.0f);
        float _2119 = _2115.x * _2102;
        float _2120 = _2115.y * _2102;
        float _2121 = _2115.z * _2102;
        _2132 = _2119;
        _2133 = _2120;
        _2134 = _2121;
      } else {
        float4 _2124 = t22.SampleLevel(s11, float2(_2010, _2111), 0.0f);
        float _2128 = _2124.x * _2105;
        float _2129 = _2124.y * _2105;
        float _2130 = _2124.z * _2105;
        _2132 = _2128;
        _2133 = _2129;
        _2134 = _2130;
      }
      float _2135 = _2132 + _2018;
      float _2136 = _2133 + _2017;
      float _2137 = _2134 + _2016;
      int _2141 = _2020 + 107;
      int _2146 = _2020 + 108;
      int _2151 = _2020 + 109;
      float _2156 = (cb12_raw[_2141].x) * _1912;
      float _2157 = mad((cb12_raw[_2146].x), _1913, _2156);
      float _2158 = mad((cb12_raw[_2151].x), _1914, _2157);
      float _2159 = (cb12_raw[_2141].y) * _1912;
      float _2160 = mad((cb12_raw[_2146].y), _1913, _2159);
      float _2161 = mad((cb12_raw[_2151].y), _1914, _2160);
      float _2162 = (cb12_raw[_2141].z) * _1912;
      float _2163 = mad((cb12_raw[_2146].z), _1913, _2162);
      float _2164 = mad((cb12_raw[_2151].z), _1914, _2163);
      int _2165 = _2020 + 110;
      float _2170 = (cb12_raw[_2141].x) * _73;
      float _2171 = mad((cb12_raw[_2146].x), _74, _2170);
      float _2172 = mad((cb12_raw[_2151].x), _75, _2171);
      float _2173 = _2172 + (cb12_raw[_2165].x);
      float _2174 = (cb12_raw[_2141].y) * _73;
      float _2175 = mad((cb12_raw[_2146].y), _74, _2174);
      float _2176 = mad((cb12_raw[_2151].y), _75, _2175);
      float _2177 = _2176 + (cb12_raw[_2165].y);
      float _2178 = (cb12_raw[_2141].z) * _73;
      float _2179 = mad((cb12_raw[_2146].z), _74, _2178);
      float _2180 = mad((cb12_raw[_2151].z), _75, _2179);
      float _2181 = _2180 + (cb12_raw[_2165].z);
      float _2182 = 1.0f / _2158;
      float _2183 = 1.0f / _2161;
      float _2184 = 1.0f / _2164;
      float _2185 = _2182 * _2173;
      float _2186 = _2183 * _2177;
      float _2187 = _2184 * _2181;
      float _2188 = _2182 - _2185;
      float _2189 = _2183 - _2186;
      float _2190 = _2184 - _2187;
      float _2191 = -0.0f - _2182;
      float _2192 = -0.0f - _2183;
      float _2193 = -0.0f - _2184;
      float _2194 = _2191 - _2185;
      float _2195 = _2192 - _2186;
      float _2196 = _2193 - _2187;
      float _2197 = max(_2188, _2194);
      float _2198 = max(_2189, _2195);
      float _2199 = max(_2190, _2196);
      float _2200 = min(_2198, _2199);
      float _2201 = min(_2197, _2200);
      float _2202 = _2201 * _1912;
      float _2203 = _2201 * _1913;
      float _2204 = _2201 * _1914;
      float _2205 = _73 - (cb12_raw[_2096].y);
      float _2206 = _2202 + _2205;
      float _2207 = _74 - (cb12_raw[_2096].z);
      float _2208 = _2203 + _2207;
      float _2209 = _75 - (cb12_raw[_2096].w);
      float _2210 = _2204 + _2209;
      float _2211 = dot(float3(_2206, _2208, _2210), float3(_2206, _2208, _2210));
      float _2212 = rsqrt(_2211);
      float _2213 = _2206 * _2212;
      float _2214 = _2208 * _2212;
      float _2215 = _2210 * _2212;
      bool _2216 = (_2215 < 0.0f);
      float _2217 = _2213 * 0.5f;
      float _2218 = _2214 * -0.5f;
      float _2219 = 1.0f - _2215;
      float _2220 = 1.0f / _2219;
      float _2221 = max(_2220, -3.4028234663852886e+38f);
      float _2222 = min(_2221, 3.4028234663852886e+38f);
      float _2223 = _2217 * _2222;
      float _2224 = _2218 * _2222;
      float _2225 = _2213 * -0.5f;
      float _2226 = _2214 * 0.5f;
      float _2227 = _2215 + 1.0f;
      float _2228 = 1.0f / _2227;
      float _2229 = max(_2228, -3.4028234663852886e+38f);
      float _2230 = min(_2229, 3.4028234663852886e+38f);
      float _2231 = _2225 * _2230;
      float _2232 = _2226 * _2230;
      float _2233 = select(_2216, _2223, _2231);
      float _2234 = _2233 + 0.5f;
      float _2235 = select(_2216, _2224, _2232);
      float _2236 = _2235 + 0.5f;
      float _2237 = _2234 * 0.6666666269302368f;
      float _2238 = _2236 * 0.6666666269302368f;
      float _2239 = float((bool)_2216);
      float _2240 = _2239 + 0.1666666716337204f;
      float _2241 = _2240 + _2237;
      float _2242 = _2109 + 0.1666666716337204f;
      float _2243 = _2242 + _2238;
      float _2244 = _2241 * 0.5f;
      float _2245 = _2243 * 0.1428571492433548f;
      float4 _2247 = t23.SampleLevel(s11, float2(_2244, _2245), _1972);
      float _2251 = _2247.x * _2105;
      float _2252 = _2247.y * _2105;
      float _2253 = _2247.z * _2105;
      float _2254 = _2251 + _2015;
      float _2255 = _2252 + _2014;
      float _2256 = _2253 + _2013;
      _2258 = _2103;
      _2259 = _2135;
      _2260 = _2136;
      _2261 = _2137;
      _2262 = _2254;
      _2263 = _2255;
      _2264 = _2256;
    } else {
      _2258 = _2019;
      _2259 = _2018;
      _2260 = _2017;
      _2261 = _2016;
      _2262 = _2015;
      _2263 = _2014;
      _2264 = _2013;
    }
    int _2265 = _2012 + 1;
    bool _2266 = ((uint)_2265 < (uint)7);
    _2267 = (_2258 < 0.9990000128746033f);
    bool _2268 = _2266 && _2267;
    if (_2268) {
      _2012 = _2265;
      _2013 = _2264;
      _2014 = _2263;
      _2015 = _2262;
      _2016 = _2261;
      _2017 = _2260;
      _2018 = _2259;
      _2019 = _2258;
      continue;
    }
    break;
  }
  [branch]
  if (_2267) {
    float _2271 = 1.0f - _2258;
    float _2274 = cb12_100x * _2271;
    float _2275 = _2274 + _2258;
    float _2278 = _2274 * cb12_106x;
    float _2281 = float((int)(cb12_111x));
    float _2282 = _2281 + _2009;
    float _2283 = _2282 * 0.1428571492433548f;
    if (_450) {
      float4 _2287 = t27.SampleLevel(s11, float2(_2010, _2283), 0.0f);
      float _2291 = _2287.x * _2274;
      float _2292 = _2287.y * _2274;
      float _2293 = _2287.z * _2274;
      _2304 = _2291;
      _2305 = _2292;
      _2306 = _2293;
    } else {
      float4 _2296 = t22.SampleLevel(s11, float2(_2010, _2283), 0.0f);
      float _2300 = _2296.x * _2278;
      float _2301 = _2296.y * _2278;
      float _2302 = _2296.z * _2278;
      _2304 = _2300;
      _2305 = _2301;
      _2306 = _2302;
    }
    float _2307 = _2304 + _2259;
    float _2308 = _2305 + _2260;
    float _2309 = _2306 + _2261;
    bool _2310 = (_1914 < 0.0f);
    float _2311 = _1912 * 0.5f;
    float _2312 = _1913 * -0.5f;
    float _2313 = 1.0f - _1914;
    float _2314 = 1.0f / _2313;
    float _2315 = max(_2314, -3.4028234663852886e+38f);
    float _2316 = min(_2315, 3.4028234663852886e+38f);
    float _2317 = _2311 * _2316;
    float _2318 = _2312 * _2316;
    float _2319 = _1912 * -0.5f;
    float _2320 = _1913 * 0.5f;
    float _2321 = _1914 + 1.0f;
    float _2322 = 1.0f / _2321;
    float _2323 = max(_2322, -3.4028234663852886e+38f);
    float _2324 = min(_2323, 3.4028234663852886e+38f);
    float _2325 = _2319 * _2324;
    float _2326 = _2320 * _2324;
    float _2327 = select(_2310, _2317, _2325);
    float _2328 = _2327 + 0.5f;
    float _2329 = select(_2310, _2318, _2326);
    float _2330 = _2329 + 0.5f;
    float _2331 = _2328 * 0.6666666269302368f;
    float _2332 = _2330 * 0.6666666269302368f;
    float _2333 = float((bool)_2310);
    float _2334 = _2333 + 0.1666666716337204f;
    float _2335 = _2334 + _2331;
    float _2336 = _2281 + 0.1666666716337204f;
    float _2337 = _2336 + _2332;
    float _2338 = _2335 * 0.5f;
    float _2339 = _2337 * 0.1428571492433548f;
    float4 _2341 = t23.SampleLevel(s11, float2(_2338, _2339), _1972);
    float _2345 = _2341.x * _2278;
    float _2346 = _2341.y * _2278;
    float _2347 = _2341.z * _2278;
    float _2348 = _2345 + _2262;
    float _2349 = _2346 + _2263;
    float _2350 = _2347 + _2264;
    _2352 = _2275;
    _2353 = _2307;
    _2354 = _2308;
    _2355 = _2309;
    _2356 = _2348;
    _2357 = _2349;
    _2358 = _2350;
  } else {
    _2352 = _2258;
    _2353 = _2259;
    _2354 = _2260;
    _2355 = _2261;
    _2356 = _2262;
    _2357 = _2263;
    _2358 = _2264;
  }
  float _2359 = 1.0f / _2352;
  float _2360 = _2359 * _2353;
  float _2361 = _2359 * _2354;
  float _2362 = _2359 * _2355;
  float _2363 = _2359 * _2356;
  float _2364 = _2359 * _2357;
  float _2365 = _2359 * _2358;
  bool _2368 = (cb12_074x > 0.0f);
  float _2369 = select(_2368, 0.0f, _2363);
  float _2370 = select(_2368, 0.0f, _2364);
  float _2371 = select(_2368, 0.0f, _2365);
  float _2374 = abs(FrequentPixelConsts_256.x);
  float _2378 = _2374 - FrequentPixelConsts_256.y;
  float _2379 = _2378 * _976;
  float _2380 = _2378 * _977;
  float _2381 = _2378 * _978;
  float _2382 = _2379 + FrequentPixelConsts_256.y;
  float _2383 = _2380 + FrequentPixelConsts_256.y;
  float _2384 = _2381 + FrequentPixelConsts_256.y;
  float _2385 = FrequentPixelConsts_256.z - FrequentPixelConsts_256.w;
  float _2386 = _2385 * _976;
  float _2387 = _2385 * _977;
  float _2388 = _2385 * _978;
  float _2389 = _2386 + FrequentPixelConsts_256.w;
  float _2390 = _2387 + FrequentPixelConsts_256.w;
  float _2391 = _2388 + FrequentPixelConsts_256.w;
  float _2392 = _2360 * _2382;
  float _2393 = _2361 * _2383;
  float _2394 = _2362 * _2384;
  float _2395 = _2389 * _2369;
  float _2396 = _2390 * _2370;
  float _2397 = _2391 * _2371;
  float _2401 = _73 - cb12_000x;
  float _2402 = _74 - cb12_000y;
  float _2403 = _2401 * _2401;
  float _2404 = _2402 * _2402;
  float _2405 = _2403 + _2404;
  float _2406 = sqrt(_2405);
  float _2409 = cb12_219x * _2406;
  float _2411 = _2409 + cb12_219y;
  float _2412 = saturate(_2411);
  float _2415 = cb12_185z + -1.0f;
  float _2416 = _2415 * _2412;
  float _2417 = _2416 + 1.0f;
  float _2423 = cb12_184x - cb12_184y;
  float _2424 = _2423 * _976;
  float _2425 = _2423 * _977;
  float _2426 = _2423 * _978;
  float _2427 = _2424 + cb12_184y;
  float _2428 = _2425 + cb12_184y;
  float _2429 = _2426 + cb12_184y;
  if (!_2368) {
    float _2433 = cb12_185x - cb12_185y;
    float _2434 = _2433 * _976;
    float _2435 = _2433 * _977;
    float _2436 = _2433 * _978;
    float _2437 = _2434 + cb12_185y;
    float _2438 = _2435 + cb12_185y;
    float _2439 = _2436 + cb12_185y;
    float _2440 = _2437 * _2417;
    float _2441 = _2438 * _2417;
    float _2442 = _2439 * _2417;
    _2444 = _2440;
    _2445 = _2441;
    _2446 = _2442;
  } else {
    _2444 = 1.0f;
    _2445 = 1.0f;
    _2446 = 1.0f;
  }
  float _2447 = dot(float3(_404, _405, _406), float3(_473, _474, _475));
  float _2448 = abs(_2447);
  float _2449 = max(_2448, _2448);
  float _2450 = abs(_2449);
  float _2451 = 1.0f - _2450;
  float _2452 = saturate(_2451);
  float _2453 = _2452 * _2452;
  float _2454 = _2453 * _2453;
  float _2455 = _2454 * _2452;
  float _2459 = min(0.25f, cb13_066y);
  float _2460 = 1.0f - _399;
  float _2461 = 1.0f - _400;
  float _2462 = 1.0f - _401;
  float _2463 = max(0.0f, _2460);
  float _2464 = max(0.0f, _2461);
  float _2465 = max(0.0f, _2462);
  float _2466 = _2455 * _2459;
  float _2467 = _2466 * _2463;
  float _2468 = _2466 * _2464;
  float _2469 = _2465 * _2466;
  float _2470 = cb13_066w * 0.8999999761581421f;
  float _2471 = _2470 + 1.0f;
  float _2472 = _2467 / _2471;
  float _2473 = _2468 / _2471;
  float _2474 = _2469 / _2471;
  float _2475 = _2460 - _2472;
  float _2476 = _2461 - _2473;
  float _2477 = _2462 - _2474;
  if (_450) {
    if (_452) {
      bool _2480 = (_406 > 0.0f);
      int _2481 = (int)(uint)(_2480);
      int _2482 = _2481 << 1u;
      int _2483 = _2482 + -1;
      float _2484 = float((int)(_2483));
      float _2485 = _2484 + _406;
      float _2486 = -1.0f / _2485;
      float _2487 = _404 * _405;
      float _2488 = _2487 * _2486;
      float _2489 = _404 * _404;
      float _2490 = _2489 * _2484;
      float _2491 = _2490 * _2486;
      float _2492 = _2491 + 1.0f;
      float _2493 = _2488 * _2484;
      int _2494 = 1 - _2482;
      float _2495 = float((int)(_2494));
      float _2496 = _2495 * _404;
      float _2497 = _405 * _405;
      float _2498 = _2497 * _2486;
      float _2499 = _2498 + _2484;
      float _2500 = -0.0f - _405;
      float _2501 = dot(float3(_473, _474, _475), float3(_473, _474, _475));
      float _2502 = rsqrt(_2501);
      float _2503 = _2502 * _473;
      float _2504 = _2502 * _474;
      float _2505 = _2502 * _475;
      float _2506 = _2503 * _2492;
      float _2507 = mad(_2493, _2504, _2506);
      float _2508 = mad(_2496, _2505, _2507);
      float _2509 = _2503 * _2488;
      float _2510 = mad(_2499, _2504, _2509);
      float _2511 = mad(_2500, _2505, _2510);
      float _2512 = _2503 * _404;
      float _2513 = mad(_405, _2504, _2512);
      float _2514 = mad(_406, _2505, _2513);
      float _2515 = dot(float3(_2508, _2511, _2514), float3(_2508, _2511, _2514));
      float _2516 = rsqrt(_2515);
      float _2517 = _2516 * _2514;
      float _2518 = 1.0f - _2517;
      float _2519 = _2518 * 0.07144299894571304f;
      float _2520 = _2519 + -0.332181453704834f;
      float _2521 = _2520 * _2518;
      float _2522 = _2521 + 0.4918818771839142f;
      float _2523 = _2522 * _2518;
      float _2524 = _2523 + 0.05710852891206741f;
      float _2525 = _2518 * 0.6568742394447327f;
      float _2526 = _2525 * _2524;
      float _2527 = _2526 + 0.8109559416770935f;
      float _2528 = _387 * _387;
      float _2529 = _388 * _388;
      float _2530 = _389 * _389;
      float _2531 = _2528 * 0.8585715889930725f;
      float _2532 = _2529 * 0.8585715889930725f;
      float _2533 = _2530 * 0.8585715889930725f;
      float _2534 = _387 * 0.1414284110069275f;
      float _2535 = _388 * 0.1414284110069275f;
      float _2536 = _389 * 0.1414284110069275f;
      float _2537 = 1.0f - _2534;
      float _2538 = 1.0f - _2535;
      float _2539 = 1.0f - _2536;
      float _2540 = _2531 / _2537;
      float _2541 = _2532 / _2538;
      float _2542 = _2533 / _2539;
      float _2543 = _2527 * _387;
      float _2544 = _2527 * _388;
      float _2545 = _2527 * _389;
      float _2546 = 0.1890440583229065f - _2526;
      float _2547 = _2546 * _2540;
      float _2548 = _2546 * _2541;
      float _2549 = _2546 * _2542;
      float _2550 = _2543 + _2547;
      float _2551 = _2544 + _2548;
      float _2552 = _2545 + _2549;
      float _2553 = _2475 * _2392;
      float _2554 = _2553 * _2550;
      float _2555 = _2476 * _2393;
      float _2556 = _2555 * _2551;
      float _2557 = _2477 * _2394;
      float _2558 = _2557 * _2552;
      _2577 = _2554;
      _2578 = _2556;
      _2579 = _2558;
    } else {
      float _2560 = _2475 * _2392;
      float _2561 = _2560 * _387;
      float _2562 = _2476 * _2393;
      float _2563 = _2562 * _388;
      float _2564 = _2477 * _2394;
      float _2565 = _2564 * _389;
      _2577 = _2561;
      _2578 = _2563;
      _2579 = _2565;
    }
  } else {
    float _2567 = _2475 * _2392;
    float _2568 = _2567 * _2417;
    float _2569 = _2568 * _2427;
    float _2570 = _2476 * _2393;
    float _2571 = _2570 * _2417;
    float _2572 = _2571 * _2428;
    float _2573 = _2477 * _2394;
    float _2574 = _2573 * _2417;
    float _2575 = _2574 * _2429;
    _2577 = _2569;
    _2578 = _2572;
    _2579 = _2575;
  }
  float _2580 = _2395 * _2444;
  float _2581 = _2396 * _2445;
  float _2582 = _2397 * _2446;
  float _2583 = _2472 + _399;
  float _2584 = _2473 + _400;
  float _2585 = _2474 + _401;
  float _2586 = _2580 * _2583;
  float _2587 = _2581 * _2584;
  float _2588 = _2582 * _2585;
  float4 _2590 = t17.Load(int3(_446, _447, 0));
  float _2594 = cb12_187x * _2590.x;
  float _2597 = _2594 + cb12_188x;
  float _2598 = saturate(_2597);
  float _2599 = _2598 + -1.0f;
  float _2600 = _2599 * 0.699999988079071f;
  float _2601 = _2600 + 1.0f;
  float _2602 = _2601 * _477.w;
  float _2605 = _2601 * cb12_069x;
  float _2607 = _2605 + cb12_069y;
  bool _2608 = (_477.z < 0.9900000095367432f);
  if (_2608) {
    _2613 = cb12_287w;
  } else {
    _2613 = 1.0f;
  }
  float _2616 = cb12_288x * _2613;
  float _2617 = log2(_2602);
  float _2618 = _2616 * _2617;
  float _2619 = exp2(_2618);
  if (_2608) {
    _2624 = cb12_287w;
  } else {
    _2624 = 1.0f;
  }
  float _2626 = _2617 * cb12_288y;
  float _2627 = _2626 * _2624;
  float _2628 = exp2(_2627);
  if (_2608) {
    _2633 = cb12_287w;
  } else {
    _2633 = 1.0f;
  }
  float _2635 = _2633 * cb12_288z;
  float _2636 = log2(_2607);
  float _2637 = _2635 * _2636;
  float _2638 = exp2(_2637);
  if (_2608) {
    _2643 = cb12_287w;
  } else {
    _2643 = 1.0f;
  }
  float _2645 = _2636 * cb12_288w;
  float _2646 = _2645 * _2643;
  float _2647 = exp2(_2646);
  float _2648 = (_2619 * _2577) * water_light.ambient.x;
  float _2649 = (_2619 * _2578) * water_light.ambient.y;
  float _2650 = (_2619 * _2579) * water_light.ambient.z;
  float _2651 = (_2586 * _2628) * water_light.ambient.x;
  float _2652 = (_2587 * _2628) * water_light.ambient.y;
  float _2653 = (_2588 * _2628) * water_light.ambient.z;
  float _2654 = _2638 * cb12_184z;
  float _2655 = _2654 * _1898;
  float _2656 = _2654 * _1899;
  float _2657 = _2654 * _1900;
  float _2658 = _2647 * cb12_184w;
  float _2659 = _2658 * _1901;
  float _2660 = _2658 * _1902;
  float _2661 = _2658 * _1903;
  bool _2662 = (_455 == 0);
  float _2663 = _2655 * _387;
  float _2664 = _2656 * _388;
  float _2665 = _2657 * _389;
  float _2666 = select(_2662, _2663, _2655);
  float _2667 = select(_2662, _2664, _2656);
  float _2668 = select(_2662, _2665, _2657);
  if (!_450) {
    float _2670 = _2648 * _387;
    float _2671 = _2649 * _388;
    float _2672 = _2650 * _389;
    _2674 = _2670;
    _2675 = _2671;
    _2676 = _2672;
  } else {
    _2674 = _2648;
    _2675 = _2649;
    _2676 = _2650;
  }
  float _2677 = _2659 + _2666;
  float _2678 = _2660 + _2667;
  float _2679 = _2661 + _2668;
  if (!_2368) {
    float _2681 = _2677 + _2651;
    float _2682 = _2678 + _2652;
    float _2683 = _2679 + _2653;
    _2685 = _2681;
    _2686 = _2682;
    _2687 = _2683;
  } else {
    _2685 = _2677;
    _2686 = _2678;
    _2687 = _2679;
  }
  float _2688 = _2676 + _2687;
  float _2689 = _2675 + _2686;
  float _2690 = _2674 + _2685;
  SV_Target.x = _2690;
  SV_Target.y = _2689;
  SV_Target.z = _2688;
  SV_Target.w = _443;
  SV_Target_1.x = _432;
  SV_Target_1.y = _433;
  SV_Target_1.z = _434;
  SV_Target_1.w = 0.8999999761581421f;
  SV_Target_3.x = _445;
  SV_Target_3.y = 0.0f;
  SV_Target_3.z = 0.0f;
  SV_Target_3.w = _443;
  OutputSignature output_signature = { SV_Target, SV_Target_1, SV_Target_3 };
  return output_signature;
}
