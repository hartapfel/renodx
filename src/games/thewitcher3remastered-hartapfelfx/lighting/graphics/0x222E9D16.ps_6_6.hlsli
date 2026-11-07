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

struct PROBE_GRID_DESC {
  float3 PROBE_GRID_DESC_000;
  float PROBE_GRID_DESC_012;
  float3 PROBE_GRID_DESC_016;
  float PROBE_GRID_DESC_028;
  int3 PROBE_GRID_DESC_032;
  float PROBE_GRID_DESC_044;
  int3 PROBE_GRID_DESC_048;
  float PROBE_GRID_DESC_060;
  int PROBE_GRID_DESC_064;
  int PROBE_GRID_DESC_068;
  int PROBE_GRID_DESC_072;
  int PROBE_GRID_DESC_076;
  int PROBE_GRID_DESC_080;
  int PROBE_GRID_DESC_084;
  int PROBE_GRID_DESC_088;
  int PROBE_GRID_DESC_092;
  float PROBE_GRID_DESC_096;
  float PROBE_GRID_DESC_100;
  float PROBE_GRID_DESC_104;
  float PROBE_GRID_DESC_108;
  int3 PROBE_GRID_DESC_112;
  int PROBE_GRID_DESC_124;
  int3 PROBE_GRID_DESC_128;
  float PROBE_GRID_DESC_140;
  float PROBE_GRID_DESC_144;
  float PROBE_GRID_DESC_148;
  float PROBE_GRID_DESC_152;
  float PROBE_GRID_DESC_156;
  float3 PROBE_GRID_DESC_160;
  int PROBE_GRID_DESC_172;
  float3 PROBE_GRID_DESC_176;
  int PROBE_GRID_DESC_188;
  float3 PROBE_GRID_DESC_192;
  float PROBE_GRID_DESC_204;
  float3 PROBE_GRID_DESC_208;
  float PROBE_GRID_DESC_220;
  float3 PROBE_GRID_DESC_224;
  float PROBE_GRID_DESC_236;
  int3 PROBE_GRID_DESC_240;
  int PROBE_GRID_DESC_252;
  int3 PROBE_GRID_DESC_256;
  int PROBE_GRID_DESC_268;
  float PROBE_GRID_DESC_272;
  int PROBE_GRID_DESC_276;
  float PROBE_GRID_DESC_280;
  float PROBE_GRID_DESC_284;
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

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t43 : register(t43);

Texture2DArray<float4> t28[2] : register(t28);

Texture2DArray<float3> t30[2] : register(t30);

Texture2D<uint> t32[2] : register(t32);

Texture2D<float4> t34[2] : register(t34);

Texture2DArray<uint> t38 : register(t38);

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

#define cb12_000y (cb12_raw[0].y)
#define cb12_220y (cb12_raw[220].y)
#define cb12_024x (cb12_raw[24].x)
#define cb12_000x (cb12_raw[0].x)
#define cb12_219z (cb12_raw[219].z)
#define cb12_000z (cb12_raw[0].z)
#define cb12_188x (cb12_raw[188].x)
#define cb12_221x (cb12_raw[221].x)
#define cb12_219w (cb12_raw[219].w)
#define cb12_219x (cb12_raw[219].x)
#define cb12_219y (cb12_raw[219].y)
#define cb12_221z (cb12_raw[221].z)
#define cb12_221y (cb12_raw[221].y)
#define cb12_071y (cb12_raw[71].y)
#define cb12_071z (cb12_raw[71].z)
#define cb12_071x (cb12_raw[71].x)
#define cb12_288y (cb12_raw[288].y)
#define cb12_100x (cb12_raw[100].x)
#define cb12_106x (cb12_raw[106].x)
#define cb12_111x (asint(cb12_raw[111].x))
#define cb12_074y (cb12_raw[74].y)
#define cb12_074x (cb12_raw[74].x)
#define cb12_184z (cb12_raw[184].z)
#define cb12_069y (cb12_raw[69].y)
#define cb12_184w (cb12_raw[184].w)
#define cb12_187x (cb12_raw[187].x)
#define cb12_069x (cb12_raw[69].x)
#define cb12_287w (cb12_raw[287].w)
#define cb12_288z (cb12_raw[288].z)
#define cb12_288w (cb12_raw[288].w)

cbuffer cb7 : register(b7) {
  PROBE_GRID_DESC gridDesc_000[2] : packoffset(c000.x);
};

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

SamplerState s7 : register(s7);

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
  bool _2381;
  bool _2113;
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
  bool _278 = (cbPerFrame_000.NvHair_ConstantBuffer_544 == 0);
  float _287;
  float _288;
  float _289;
  float _301;
  float _302;
  float _303;
  float _315;
  float _377;
  float _378;
  float _379;
  float _560;
  float _627;
  float _628;
  float _629;
  float _630;
  float _631;
  float _632;
  float _711;
  float _712;
  float _713;
  float _889;
  float _944;
  float _945;
  float _946;
  float _951;
  float _952;
  float _953;
  float _961;
  float _962;
  float _963;
  float _964;
  float _965;
  float _966;
  float _967;
  float _968;
  float _969;
  float _974;
  float _975;
  float _976;
  float _977;
  float _978;
  float _979;
  int _980;
  float _1063;
  float _1175;
  float _1176;
  float _1177;
  float _1178;
  float _1258;
  float _1259;
  float _1260;
  float _1261;
  float _1265;
  float _1266;
  float _1267;
  float _1268;
  int _1269;
  float _1312;
  int _1325;
  int _1326;
  float _1364;
  float _1365;
  float _1366;
  float _1371;
  float _1372;
  float _1373;
  float _1375;
  float _1376;
  float _1377;
  float _1378;
  float _1393;
  float _1406;
  float _1415;
  float _1435;
  float _1525;
  float _1589;
  float _1590;
  float _1591;
  float _1670;
  float _1671;
  float _1672;
  float _1809;
  float _1864;
  float _1865;
  float _1866;
  float _1871;
  float _1872;
  float _1873;
  float _1881;
  float _1882;
  float _1883;
  float _1884;
  float _1885;
  float _1886;
  float _1890;
  float _1891;
  float _1892;
  float _1893;
  float _1894;
  float _1895;
  int _1908;
  float _1909;
  float _1910;
  float _1911;
  float _1912;
  float _2107;
  float _2108;
  float _2109;
  float _2110;
  float _2171;
  float _2172;
  float _2173;
  float _2174;
  int _2176;
  float _2177;
  float _2178;
  float _2179;
  float _2180;
  float _2375;
  float _2376;
  float _2377;
  float _2378;
  float _2440;
  float _2441;
  float _2442;
  float _2443;
  float _2598;
  float _2599;
  float _2600;
  float _2601;
  float _2602;
  int _2603;
  float _2708;
  float _2709;
  float _2764;
  float _2765;
  float _2816;
  float _2830;
  float _2831;
  float _2832;
  float _2833;
  float _2834;
  float _2860;
  float _2861;
  float _2862;
  float _2863;
  float _2866;
  float _2867;
  float _2868;
  float _2870;
  float _2871;
  float _2872;
  int _2873;
  int _2874;
  float _2875;
  float _2951;
  float _2952;
  float _2953;
  float _2954;
  float _2955;
  int _2956;
  float _3069;
  float _3070;
  float _3121;
  float _3122;
  float _3173;
  float _3187;
  float _3188;
  float _3189;
  float _3190;
  float _3191;
  float _3217;
  float _3218;
  float _3219;
  float _3220;
  float _3224;
  float _3225;
  float _3226;
  int _3227;
  float _3228;
  float _3229;
  int _3230;
  float _3231;
  float _3232;
  float _3233;
  float _3279;
  float _3280;
  float _3319;
  float _3320;
  float _3321;
  float _3322;
  float _3343;
  float _3344;
  float _3345;
  bool _3346;
  float _3434;
  float _3445;
  float _3455;
  float _3486;
  float _3487;
  float _3488;
  if (!_278) {
    float4 _282 = t5.SampleLevel(s0, float2(_80, _79), 0.0f);
    _287 = _282.x;
    _288 = _282.y;
    _289 = _282.z;
  } else {
    _287 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.x;
    _288 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.y;
    _289 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.z;
  }
  bool _292 = (cbPerFrame_000.NvHair_ConstantBuffer_548 == 0);
  if (!_292) {
    float4 _296 = t6.SampleLevel(s0, float2(_80, _79), 0.0f);
    _301 = _296.x;
    _302 = _296.y;
    _303 = _296.z;
  } else {
    _301 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.x;
    _302 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.y;
    _303 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.z;
  }
  bool _304 = (cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144 < 0.5f);
  if (_304) {
    float _306 = HAIR_TEX * 2.0f;
    float _307 = _306 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144;
    _315 = _307;
  } else {
    float _309 = 1.0f - cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144;
    float _310 = HAIR_TEX + -1.0f;
    float _311 = _310 * 2.0f;
    float _312 = _311 * _309;
    float _313 = _312 + 1.0f;
    _315 = _313;
  }
  float _316 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_148 + 0.0010000000474974513f;
  float _317 = 1.0f / _316;
  float _318 = _315 + -0.5f;
  float _319 = _317 * _318;
  float _320 = _319 + 0.5f;
  float _321 = saturate(_320);
  float _322 = _301 - _287;
  float _323 = _302 - _288;
  float _324 = _303 - _289;
  float _325 = _321 * _322;
  float _326 = _321 * _323;
  float _327 = _321 * _324;
  float _328 = _325 + _287;
  float _329 = _326 + _288;
  float _330 = _327 + _289;
  bool _332 = (cbPerFrame_000.NvHair_ConstantBuffer_552 == 0);
  if (!_332) {
    float4 _336 = t7.SampleLevel(s0, float2(HAIR_TEX, 0.5f), 0.0f);
    switch (cbPerFrame_000.NvHair_ConstantBuffer_576) {
      case 0: {
        float _343 = _336.x * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _344 = _336.y * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _345 = _336.z * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        _377 = _343;
        _378 = _344;
        _379 = _345;
        break;
      }
      case 1: {
        float _347 = _336.x * _328;
        float _348 = _336.y * _329;
        float _349 = _336.z * _330;
        float _350 = _347 - _328;
        float _351 = _348 - _329;
        float _352 = _349 - _330;
        float _353 = _350 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _354 = _351 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _355 = _352 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _356 = _353 + _328;
        float _357 = _354 + _329;
        float _358 = _355 + _330;
        _377 = _356;
        _378 = _357;
        _379 = _358;
        break;
      }
      case 2: {
        float _360 = _336.x * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _361 = _336.y * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _362 = _336.z * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _363 = _360 + _328;
        float _364 = _361 + _329;
        float _365 = _362 + _330;
        _377 = _363;
        _378 = _364;
        _379 = _365;
        break;
      }
      case 3: {
        float _367 = _336.x + -0.5f;
        float _368 = _336.y + -0.5f;
        float _369 = _336.z + -0.5f;
        float _370 = _367 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _371 = _368 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _372 = _369 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _373 = _370 + _328;
        float _374 = _371 + _329;
        float _375 = _372 + _330;
        _377 = _373;
        _378 = _374;
        _379 = _375;
        break;
      }
      default: {
        _377 = _328;
        _378 = _329;
        _379 = _330;
        break;
      }
    }
  } else {
    _377 = _328;
    _378 = _329;
    _379 = _330;
  }
  float _380 = _377 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _381 = _378 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _382 = _379 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _383 = log2(_380);
  float _384 = log2(_381);
  float _385 = log2(_382);
  float _386 = _383 * 2.200000047683716f;
  float _387 = _384 * 2.200000047683716f;
  float _388 = _385 * 2.200000047683716f;
  float _389 = exp2(_386);
  float _390 = exp2(_387);
  float _391 = exp2(_388);
  float _392 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.x);
  float _393 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.y);
  float _394 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.z);
  float _395 = _392 * 2.200000047683716f;
  float _396 = _393 * 2.200000047683716f;
  float _397 = _394 * 2.200000047683716f;
  float _398 = exp2(_395);
  float _399 = exp2(_396);
  float _400 = exp2(_397);
  float _401 = _398 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _402 = _399 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _403 = _400 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _404 = dot(float3(_251, _252, _253), float3(_251, _252, _253));
  float _405 = rsqrt(_404);
  float _406 = _405 * _251;
  float _407 = _405 * _252;
  float _408 = _405 * _253;
  float _409 = abs(_406);
  float _410 = abs(_407);
  float _411 = abs(_408);
  float _412 = max(_409, _410);
  float _413 = max(_411, _412);
  bool _414 = (_411 < _413);
  bool _415 = (_410 < _413);
  bool _416 = _414 && _415;
  float _417 = select(_416, _410, _409);
  float _418 = select(_414, _411, _410);
  bool _419 = (_417 < _418);
  float _420 = select(_419, _418, _417);
  float _421 = select(_419, _417, _418);
  float _422 = _421 / _420;
  float _423 = _406 / _413;
  float _424 = _407 / _413;
  float _425 = _408 / _413;
  float4 _428 = t13.SampleLevel(s13, float2(_420, _422), 0.0f);
  float _430 = _428.x * 0.5f;
  float _431 = _430 * _423;
  float _432 = _430 * _424;
  float _433 = _430 * _425;
  float _434 = _431 + 0.5f;
  float _435 = _432 + 0.5f;
  float _436 = _433 + 0.5f;
  float _437 = HAIR_TEX + 9.99999993922529e-09f;
  float _438 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_172 + 9.99999993922529e-09f;
  float _439 = _437 / _438;
  float _440 = saturate(_439);
  float _443 = 1.0f - cbPerFrame_000.NvHair_ConstantBuffer_600;
  float _444 = _443 * _440;
  float _445 = saturate(_444);
  uint _446 = uint(SV_Position.x);
  uint _447 = uint(SV_Position.y);
  int _450 = int(cb12_220y);
  int _451 = (uint)(_446) >> 4;
  int _452 = (uint)(_447) >> 4;
  int _455 = int(cb12_024x);
  uint _456 = _455 * _452;
  uint _457 = _456 + _451;
  uint _458 = _457 << 8u;
  float _463 = cb12_000x - _75;
  float _464 = cb12_000y - _76;
  float _465 = cb12_000z - _77;
  float _466 = dot(float3(_463, _464, _465), float3(_463, _464, _465));
  float _467 = rsqrt(_466);
  float _468 = _463 * _467;
  float _469 = _464 * _467;
  float _470 = _465 * _467;
  float4 _472 = t17.Load(int3(_446, _447, 0));
  GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
      float3(_75, _76, _77), float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
  // HairWorks keeps its native anisotropic lobes and ambient shadow weights.
  float graphics_sun_visibility = min(_472.y, GraphicsForwardContact(
      float3(_75, _76, _77), float3(_406, _407, _408), SV_Position.xy, true));
  bool _479 = (_472.y > 0.0f);
  if (_479) {
    float _481 = dot(float3(_406, _407, _408), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
    float _482 = _481 + 0.25f;
    float _483 = _482 * 0.800000011920929f;
    float _484 = saturate(_483);
    float _485 = _484 + _481;
    float _486 = _484 + 1.0f;
    float _487 = _485 / _486;
    float _488 = 1.0f / _486;
    float _489 = saturate(_487);
    bool _490 = (_450 == 1);
    if (_490) {
      float _492 = saturate(_481);
      bool _493 = (_408 > 0.0f);
      int _494 = (int)(uint)(_493);
      int _495 = _494 << 1u;
      int _496 = _495 + -1;
      float _497 = float((int)(_496));
      float _498 = _497 + _408;
      float _499 = -1.0f / _498;
      float _500 = _406 * _407;
      float _501 = _500 * _499;
      float _502 = _406 * _406;
      float _503 = _502 * _497;
      float _504 = _503 * _499;
      float _505 = _504 + 1.0f;
      float _506 = _501 * _497;
      int _507 = 1 - _495;
      float _508 = float((int)(_507));
      float _509 = _508 * _406;
      float _510 = _407 * _407;
      float _511 = _510 * _499;
      float _512 = _511 + _497;
      float _513 = -0.0f - _407;
      float _514 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
      float _515 = rsqrt(_514);
      float _516 = _515 * water_light.sun.x;
      float _517 = _515 * water_light.sun.y;
      float _518 = _515 * water_light.sun.z;
      float _519 = _516 * _505;
      float _520 = mad(_506, _517, _519);
      float _521 = mad(_509, _518, _520);
      float _522 = _516 * _501;
      float _523 = mad(_512, _517, _522);
      float _524 = mad(_513, _518, _523);
      float _525 = _516 * _406;
      float _526 = mad(_407, _517, _525);
      float _527 = mad(_408, _518, _526);
      float _528 = dot(float3(_521, _524, _527), float3(_521, _524, _527));
      float _529 = rsqrt(_528);
      float _530 = _529 * _521;
      float _531 = _529 * _524;
      float _532 = _529 * _527;
      float _533 = dot(float3(_468, _469, _470), float3(_468, _469, _470));
      float _534 = rsqrt(_533);
      float _535 = _534 * _468;
      float _536 = _534 * _469;
      float _537 = _534 * _470;
      float _538 = _535 * _505;
      float _539 = mad(_506, _536, _538);
      float _540 = mad(_509, _537, _539);
      float _541 = _535 * _501;
      float _542 = mad(_512, _536, _541);
      float _543 = mad(_513, _537, _542);
      float _544 = _535 * _406;
      float _545 = mad(_407, _536, _544);
      float _546 = mad(_408, _537, _545);
      float _547 = dot(float3(_540, _543, _546), float3(_540, _543, _546));
      float _548 = rsqrt(_547);
      float _549 = _548 * _540;
      float _550 = _548 * _543;
      float _551 = _548 * _546;
      float _552 = dot(float3(_530, _531, _532), float3(_549, _550, _551));
      float _553 = _551 * _532;
      float _554 = _552 - _553;
      bool _555 = (_554 > 0.0f);
      if (_555) {
        float _557 = max(_532, _551);
        float _558 = _554 / _557;
        _560 = _558;
      } else {
        _560 = _554;
      }
      float _561 = _560 * 0.20908956229686737f;
      float _562 = _561 + 0.25813528895378113f;
      float _563 = _562 * _389;
      float _564 = _562 * _390;
      float _565 = _562 * _391;
      float _566 = 1.0f - _551;
      float _567 = _566 * 0.07144299894571304f;
      float _568 = _567 + -0.332181453704834f;
      float _569 = _568 * _566;
      float _570 = _569 + 0.4918818771839142f;
      float _571 = _570 * _566;
      float _572 = _571 + 0.05710852891206741f;
      float _573 = _566 * 0.6568742394447327f;
      float _574 = _573 * _572;
      float _575 = 1.0f - _532;
      float _576 = _575 * 0.07144299894571304f;
      float _577 = _576 + -0.332181453704834f;
      float _578 = _577 * _575;
      float _579 = _578 + 0.4918818771839142f;
      float _580 = _579 * _575;
      float _581 = _580 + 0.05710852891206741f;
      float _582 = _575 * 0.6568742394447327f;
      float _583 = _582 * _581;
      float _584 = _389 * _389;
      float _585 = _390 * _390;
      float _586 = _391 * _391;
      float _587 = _584 * 0.8585715889930725f;
      float _588 = _585 * 0.8585715889930725f;
      float _589 = _586 * 0.8585715889930725f;
      float _590 = _389 * 0.1414284110069275f;
      float _591 = _390 * 0.1414284110069275f;
      float _592 = _391 * 0.1414284110069275f;
      float _593 = 1.0f - _590;
      float _594 = 1.0f - _591;
      float _595 = 1.0f - _592;
      float _596 = _587 / _593;
      float _597 = _588 / _594;
      float _598 = _589 / _595;
      float _599 = 0.1890440583229065f - _574;
      float _600 = max(1.0000000116860974e-07f, _599);
      float _601 = 0.1890440583229065f - _583;
      float _602 = max(1.0000000116860974e-07f, _601);
      float _603 = _600 * 2.250678300857544f;
      float _604 = _603 * _602;
      float _605 = _604 * _596;
      float _606 = _604 * _597;
      float _607 = _604 * _598;
      float _608 = _605 + _563;
      float _609 = _606 + _564;
      float _610 = _607 + _565;
      float _611 = _608 * _492;
      float _612 = _609 * _492;
      float _613 = _610 * _492;
      float _614 = _489 - _492;
      float _615 = max(0.0f, _614);
      float _616 = _615 * 0.31830987334251404f;
      float _617 = _616 * _389;
      float _618 = _616 * _390;
      float _619 = _616 * _391;
      float _620 = _611 + _617;
      float _621 = _612 + _618;
      float _622 = _613 + _619;
      float _623 = _620 * 3.1415927410125732f;
      float _624 = _621 * 3.1415927410125732f;
      float _625 = _622 * 3.1415927410125732f;
      _627 = _620;
      _628 = _621;
      _629 = _622;
      _630 = _623;
      _631 = _624;
      _632 = _625;
    } else {
      _627 = _489;
      _628 = _489;
      _629 = _489;
      _630 = _489;
      _631 = _489;
      _632 = _489;
    }
    bool _635 = (cb12_221x > 0.0f);
    float _636 = 1.0f - _401;
    float _637 = 1.0f - _402;
    float _638 = 1.0f - _403;
    if (_635) {
      float _640 = dot(float3(_406, _407, _408), float3(_468, _469, _470));
      float4 _643 = t43.SampleLevel(s10, float2(0.8999999761581421f, _640), 0.0f);
      float _646 = _643.x * _401;
      float _647 = _643.x * _402;
      float _648 = _643.x * _403;
      float _649 = _646 + _643.y;
      float _650 = _647 + _643.y;
      float _651 = _648 + _643.y;
      float _652 = _636 * 0.0476190485060215f;
      float _653 = _637 * 0.0476190485060215f;
      float _654 = _638 * 0.0476190485060215f;
      float _655 = _652 + _401;
      float _656 = _653 + _402;
      float _657 = _654 + _403;
      float _658 = 1.0f - _649;
      float _659 = 1.0f - _650;
      float _660 = 1.0f - _651;
      float _661 = _658 * _655;
      float _662 = _659 * _656;
      float _663 = _660 * _657;
      float _664 = 1.0f - _661;
      float _665 = 1.0f - _662;
      float _666 = 1.0f - _663;
      float _667 = max(_664, 0.0010000000474974513f);
      float _668 = max(_665, 0.0010000000474974513f);
      float _669 = max(_666, 0.0010000000474974513f);
      float _670 = _649 / _667;
      float _671 = _650 / _668;
      float _672 = _651 / _669;
      float _673 = min(_670, 1.0f);
      float _674 = min(_671, 1.0f);
      float _675 = min(_672, 1.0f);
      _711 = _673;
      _712 = _674;
      _713 = _675;
    } else {
      float _677 = water_light.sun.x + _468;
      float _678 = water_light.sun.y + _469;
      float _679 = water_light.sun.z + _470;
      float _680 = dot(float3(_677, _678, _679), float3(_677, _678, _679));
      float _681 = rsqrt(_680);
      float _682 = _681 * _677;
      float _683 = _681 * _678;
      float _684 = _681 * _679;
      float _685 = dot(float3(_682, _683, _684), float3(_468, _469, _470));
      float _686 = abs(_685);
      float _687 = 1.0f - _686;
      float _688 = saturate(_687);
      float _689 = _688 * _688;
      float _693 = max(0.0f, _636);
      float _694 = max(0.0f, _637);
      float _695 = max(0.0f, _638);
      float _696 = _689 * _689;
      float _697 = _696 * _688;
      float _698 = _697 * cb13_066x;
      float _699 = _698 * _693;
      float _700 = _698 * _694;
      float _701 = _698 * _695;
      float _702 = cb13_066z * 0.8999999761581421f;
      float _703 = _702 + 1.0f;
      float _704 = _699 / _703;
      float _705 = _700 / _703;
      float _706 = _701 / _703;
      float _707 = _704 + _401;
      float _708 = _705 + _402;
      float _709 = _706 + _403;
      _711 = _707;
      _712 = _708;
      _713 = _709;
    }
    float _714 = 1.0f - _711;
    float _715 = 1.0f - _712;
    float _716 = 1.0f - _713;
    float _717 = _714 * _627;
    float _718 = _715 * _628;
    float _719 = _716 * _629;
    int _720 = _450 & -3;
    bool _721 = (_720 == 0);
    float _722 = _717 * 0.31830987334251404f;
    float _723 = _718 * 0.31830987334251404f;
    float _724 = _719 * 0.31830987334251404f;
    float _725 = select(_721, _722, _717);
    float _726 = select(_721, _723, _718);
    float _727 = select(_721, _724, _719);
    float _728 = _75 - cb12_000x;
    float _729 = _76 - cb12_000y;
    float _730 = _728 * _728;
    float _731 = _729 * _729;
    float _732 = _730 + _731;
    float _733 = sqrt(_732);
    float _736 = cb12_219z * _77;
    float _738 = _736 + cb12_219w;
    float _739 = saturate(_738);
    float _748 = cb13_061x - cb13_062x;
    float _749 = cb13_061y - cb13_062y;
    float _750 = cb13_061z - cb13_062z;
    float _751 = _748 * _739;
    float _752 = _749 * _739;
    float _753 = _750 * _739;
    float _754 = _751 + cb13_062x;
    float _755 = _752 + cb13_062y;
    float _756 = _753 + cb13_062z;
    float _758 = cb12_219x * _733;
    float _760 = _758 + cb12_219y;
    float _761 = saturate(_760);
    float _766 = _754 - cb13_001x;
    float _767 = _755 - cb13_001y;
    float _768 = _756 - cb13_001z;
    float _769 = _766 * _761;
    float _770 = _767 * _761;
    float _771 = _768 * _761;
    float _772 = (_769 + cb13_001x) * water_light.direct.x;
    float _773 = (_770 + cb13_001y) * water_light.direct.y;
    float _774 = (_771 + cb13_001z) * water_light.direct.z;
    float _775 = _488 * graphics_sun_visibility;
    float _776 = _725 * _775;
    float _777 = _776 * _772;
    float _778 = _726 * _775;
    float _779 = _778 * _773;
    float _780 = _727 * _775;
    float _781 = _780 * _774;
    float _782 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_406, _407, _408));
    bool _783 = (_782 > 0.0f);
    [branch]
    if (_783) {
      float _785 = water_light.sun.x + _468;
      float _786 = water_light.sun.y + _469;
      float _787 = water_light.sun.z + _470;
      float _788 = dot(float3(_785, _786, _787), float3(_785, _786, _787));
      float _789 = rsqrt(_788);
      float _790 = _789 * _785;
      float _791 = _789 * _786;
      float _792 = _789 * _787;
      float _793 = dot(float3(_406, _407, _408), float3(_468, _469, _470));
      float _794 = saturate(_481);
      float _795 = dot(float3(_182, _183, _184), float3(_182, _183, _184));
      float _796 = rsqrt(_795);
      float _797 = _796 * _182;
      float _798 = _796 * _183;
      float _799 = _796 * _184;
      float _800 = dot(float3(_797, _798, _799), float3(_406, _407, _408));
      float _801 = _800 * _406;
      float _802 = _800 * _407;
      float _803 = _800 * _408;
      float _804 = _797 - _801;
      float _805 = _798 - _802;
      float _806 = _799 - _803;
      float _807 = dot(float3(_804, _805, _806), float3(_804, _805, _806));
      float _808 = rsqrt(_807);
      float _809 = _804 * _808;
      float _810 = _805 * _808;
      float _811 = _806 * _808;
      float _812 = _810 * _408;
      float _813 = _811 * _407;
      float _814 = _812 - _813;
      float _815 = _811 * _406;
      float _816 = _809 * _408;
      float _817 = _815 - _816;
      float _818 = _809 * _407;
      float _819 = _810 * _406;
      float _820 = _818 - _819;
      float _821 = dot(float3(_814, _817, _820), float3(_814, _817, _820));
      float _822 = rsqrt(_821);
      float _823 = _814 * _822;
      float _824 = _817 * _822;
      float _825 = _820 * _822;
      float _826 = dot(float3(_809, _810, _811), float3(_790, _791, _792));
      float _827 = _826 * 1.2345679998397827f;
      float _828 = _827 * _827;
      float _829 = dot(float3(_823, _824, _825), float3(_790, _791, _792));
      float _830 = _829 * 1.2345679998397827f;
      float _831 = _830 * _830;
      float _832 = dot(float3(_406, _407, _408), float3(_790, _791, _792));
      float _833 = saturate(_832);
      float _834 = _833 * _833;
      float _835 = _831 + _828;
      float _836 = _835 + _834;
      float _837 = _836 * _836;
      float _838 = 0.4851658046245575f / _837;
      float _839 = abs(_793);
      float _840 = dot(float3(_790, _791, _792), float3(_468, _469, _470));
      float _841 = abs(_840);
      float _842 = 1.0f - _841;
      float _843 = saturate(_842);
      float _844 = _843 * _843;
      float _848 = max(0.0f, _636);
      float _849 = max(0.0f, _637);
      float _850 = max(0.0f, _638);
      float _851 = _844 * _844;
      float _852 = _851 * _843;
      float _853 = _852 * cb13_066x;
      float _854 = _853 * _848;
      float _855 = _853 * _849;
      float _856 = _853 * _850;
      float _857 = cb13_066z * 0.8999999761581421f;
      float _858 = _857 + 1.0f;
      float _859 = _854 / _858;
      float _860 = _855 / _858;
      float _861 = _856 / _858;
      float _862 = _859 + _401;
      float _863 = _860 + _402;
      float _864 = _861 + _403;
      bool _866 = (cb12_221z > 0.0f);
      [branch]
      if (_866) {
        float _868 = saturate(_793);
        float _869 = _868 + _794;
        float _870 = _794 * 2.0f;
        float _871 = _870 * _868;
        float _872 = _869 - _871;
        float _873 = _872 * 0.809999942779541f;
        float _874 = _873 + _871;
        _889 = _874;
      } else {
        float _876 = _839 * _839;
        float _877 = _876 * 0.34390008449554443f;
        float _878 = _877 + 0.6560999155044556f;
        float _879 = sqrt(_878);
        float _880 = _879 * _794;
        float _881 = _794 * _794;
        float _882 = _881 * 0.34390008449554443f;
        float _883 = _882 + 0.6560999155044556f;
        float _884 = sqrt(_883);
        float _885 = _884 * _839;
        float _886 = _880 + 9.999999747378752e-05f;
        float _887 = _886 + _885;
        _889 = _887;
      }
      float _890 = 0.5f / _889;
      float _891 = _890 * _838;
      float _892 = _891 * _862;
      float _893 = _891 * _863;
      float _894 = _891 * _864;
      bool _896 = (cb12_221y > 0.0f);
      if (_896) {
        float _898 = dot(float3(_406, _407, _408), float3(_890, _890, _890));
        float4 _901 = t43.SampleLevel(s10, float2(0.8999999761581421f, _898), 0.0f);
        float _904 = _901.x * _401;
        float _905 = _901.x * _402;
        float _906 = _901.x * _403;
        float _907 = _904 + _901.y;
        float _908 = _905 + _901.y;
        float _909 = _906 + _901.y;
        float _910 = _636 * 0.0476190485060215f;
        float _911 = _637 * 0.0476190485060215f;
        float _912 = _638 * 0.0476190485060215f;
        float _913 = _910 + _401;
        float _914 = _911 + _402;
        float _915 = _912 + _403;
        float _916 = 1.0f - _907;
        float _917 = 1.0f - _908;
        float _918 = 1.0f - _909;
        float _919 = _916 * _913;
        float _920 = _917 * _914;
        float _921 = _918 * _915;
        float _922 = 1.0f - _919;
        float _923 = 1.0f - _920;
        float _924 = 1.0f - _921;
        float _925 = max(_922, 0.0010000000474974513f);
        float _926 = max(_923, 0.0010000000474974513f);
        float _927 = max(_924, 0.0010000000474974513f);
        float _928 = _907 / _925;
        float _929 = _908 / _926;
        float _930 = _909 / _927;
        float _931 = min(_928, 1.0f);
        float _932 = min(_929, 1.0f);
        float _933 = min(_930, 1.0f);
        float _934 = max(_907, 9.999999747378752e-05f);
        float _935 = max(_908, 9.999999747378752e-05f);
        float _936 = max(_909, 9.999999747378752e-05f);
        float _937 = _931 / _934;
        float _938 = _932 / _935;
        float _939 = _933 / _936;
        float _940 = _937 * _892;
        float _941 = _938 * _893;
        float _942 = _939 * _894;
        _944 = _940;
        _945 = _941;
        _946 = _942;
      } else {
        _944 = _892;
        _945 = _893;
        _946 = _894;
      }
      float _947 = _944 * _794;
      float _948 = _945 * _794;
      float _949 = _946 * _794;
      _951 = _947;
      _952 = _948;
      _953 = _949;
    } else {
      _951 = 0.0f;
      _952 = 0.0f;
      _953 = 0.0f;
    }
    float _954 = _772 * graphics_sun_visibility;
    float _955 = _954 * _951;
    float _956 = _773 * graphics_sun_visibility;
    float _957 = _956 * _952;
    float _958 = _774 * graphics_sun_visibility;
    float _959 = _958 * _953;
    _961 = _955;
    _962 = _957;
    _963 = _959;
    _964 = _777;
    _965 = _779;
    _966 = _781;
    _967 = _630;
    _968 = _631;
    _969 = _632;
  } else {
    _961 = 0.0f;
    _962 = 0.0f;
    _963 = 0.0f;
    _964 = 0.0f;
    _965 = 0.0f;
    _966 = 0.0f;
    _967 = 0.0f;
    _968 = 0.0f;
    _969 = 0.0f;
  }
  if (any(water_light.direct != 1.f)) {
    float3 native_environment = GraphicsForwardSunEnvironment(float3(_406, _407, _408), float3(_406, _407, _408),
        float3(_468, _469, _470), float3(cb13_000x, cb13_000y, cb13_000z), float3(_389, _390, _391), .9f, int(cb12_220y), .25f, _472.y);
    _967 = native_environment.x; _968 = native_environment.y; _969 = native_environment.z;
  }
  float _970 = min(_967, _472.y);
  float _971 = min(_968, _472.y);
  float _972 = min(_969, _472.y);
  _974 = _964;
  _975 = _965;
  _976 = _966;
  _977 = _961;
  _978 = _962;
  _979 = _963;
  _980 = 0;
  while(true) {
    int _981 = _980 + _458;
    uint _982 = _981 << 2u;
    int4 _984 = asint(t20.Load4(_982));
    bool _986 = ((uint)_984.x > (uint)255);
    [branch]
    if (!_986) {
      uint _988 = _984.x * 10;
      uint _989 = _988 + 68u;
      float _994 = (cb13_raw[_989].x) - _75;
      float _995 = (cb13_raw[_989].y) - _76;
      float _996 = (cb13_raw[_989].z) - _77;
      float _997 = _994 * _994;
      float _998 = _995 * _995;
      float _999 = _997 + _998;
      float _1000 = _996 * _996;
      float _1001 = _999 + _1000;
      float _1002 = sqrt(_1001);
      float _1003 = _1002 * _1002;
      uint _1004 = _988 + 73u;
      float _1007 = _1003 * (cb13_raw[_1004].x);
      float _1009 = _1002 / (cb13_raw[_989].w);
      float _1010 = _1009 * _1009;
      float _1011 = _1010 * _1010;
      float _1012 = 1.0f - _1011;
      float _1013 = saturate(_1012);
      float _1014 = _1013 * _1013;
      uint _1015 = _988 + 71u;
      int _1018 = asint((cb13_raw[_1015].w));
      int _1019 = _1018 & 1;
      bool _1020 = (_1019 != 0);
      bool _1022 = ((cb13_raw[_1004].z) > 0.0f);
      uint _1023 = _988 + 74u;
      bool _1026 = ((cb13_raw[_1023].x) > 0.0f);
      uint _1027 = _988 + 77u;
      int _1030 = asint((cb13_raw[_1027].x));
      int _1031 = _1030 & 1;
      bool _1032 = (_1031 != 0);
      float _1033 = _1007 + 1.0f;
      float _1034 = _1014 / _1033;
      if (_1020) {
        uint _1036 = _988 + 70u;
        float _1041 = dot(float3(_994, _995, _996), float3(_994, _995, _996));
        float _1042 = rsqrt(_1041);
        float _1043 = _994 * _1042;
        float _1044 = -0.0f - _1043;
        float _1045 = _995 * _1042;
        float _1046 = -0.0f - _1045;
        float _1047 = _996 * _1042;
        float _1048 = -0.0f - _1047;
        float _1049 = dot(float3(_1044, _1046, _1048), float3((cb13_raw[_1036].x), (cb13_raw[_1036].y), (cb13_raw[_1036].z)));
        uint _1050 = _988 + 72u;
        float _1054 = (cb13_raw[_1050].y) * _1049;
        float _1056 = _1054 + (cb13_raw[_1050].z);
        float _1057 = saturate(_1056);
        float _1058 = log2(_1057);
        float _1059 = _1058 * (cb13_raw[_1050].w);
        float _1060 = exp2(_1059);
        float _1061 = _1060 * _1034;
        _1063 = _1061;
      } else {
        _1063 = _1034;
      }
      bool _1064 = _1022 || _1032;
      bool _1065 = (_1063 > 0.0f);
      bool _1066 = _1064 && _1065;
      if (_1066) {
        float _1068 = -0.0f - _994;
        float _1069 = -0.0f - _995;
        float _1070 = -0.0f - _996;
        if (_1020) {
          uint _1072 = _988 + 70u;
          uint _1077 = _988 + 75u;
          float _1082 = (cb13_raw[_1077].w) * (cb13_raw[_1072].y);
          float _1083 = (cb13_raw[_1077].z) * (cb13_raw[_1072].z);
          float _1084 = _1082 - _1083;
          float _1085 = (cb13_raw[_1077].y) * (cb13_raw[_1072].z);
          float _1086 = (cb13_raw[_1077].w) * (cb13_raw[_1072].x);
          float _1087 = _1085 - _1086;
          float _1088 = (cb13_raw[_1077].z) * (cb13_raw[_1072].x);
          float _1089 = (cb13_raw[_1077].y) * (cb13_raw[_1072].y);
          float _1090 = _1088 - _1089;
          float _1091 = _1084 * _1068;
          float _1092 = mad(_1087, _1069, _1091);
          float _1093 = mad(_1090, _1070, _1092);
          float _1094 = (cb13_raw[_1077].y) * _1068;
          float _1095 = mad((cb13_raw[_1077].z), _1069, _1094);
          float _1096 = mad((cb13_raw[_1077].w), _1070, _1095);
          float _1097 = (cb13_raw[_1072].x) * _1068;
          float _1098 = mad((cb13_raw[_1072].y), _1069, _1097);
          float _1099 = mad((cb13_raw[_1072].z), _1070, _1098);
          int _1102 = asint((cb13_raw[_1027].z));
          _1265 = _1093;
          _1266 = _1096;
          _1267 = _1099;
          _1268 = (cb13_raw[_1077].x);
          _1269 = _1102;
        } else {
          if (_1032) {
            uint _1105 = _988 + 72u;
            uint _1110 = _988 + 70u;
            float _1115 = (cb13_raw[_1110].y) * (cb13_raw[_1105].w);
            float _1116 = (cb13_raw[_1110].z) * (cb13_raw[_1105].z);
            float _1117 = _1115 - _1116;
            float _1118 = (cb13_raw[_1110].z) * (cb13_raw[_1105].y);
            float _1119 = (cb13_raw[_1110].x) * (cb13_raw[_1105].w);
            float _1120 = _1118 - _1119;
            float _1121 = (cb13_raw[_1110].x) * (cb13_raw[_1105].z);
            float _1122 = (cb13_raw[_1110].y) * (cb13_raw[_1105].y);
            float _1123 = _1121 - _1122;
            float _1124 = _1117 * _1068;
            float _1125 = mad(_1120, _1069, _1124);
            float _1126 = mad(_1123, _1070, _1125);
            float _1127 = (cb13_raw[_1110].x) * _1068;
            float _1128 = mad((cb13_raw[_1110].y), _1069, _1127);
            float _1129 = mad((cb13_raw[_1110].z), _1070, _1128);
            float _1130 = (cb13_raw[_1105].y) * _1068;
            float _1131 = mad((cb13_raw[_1105].z), _1069, _1130);
            float _1132 = mad((cb13_raw[_1105].w), _1070, _1131);
            float _1133 = -0.0f - _1126;
            float _1134 = -0.0f - _1129;
            float _1135 = -0.0f - _1132;
            float _1136 = _1133 / _1002;
            float _1137 = _1134 / _1002;
            float _1138 = _1135 / _1002;
            float _1139 = abs(_1136);
            float _1140 = abs(_1137);
            float _1141 = abs(_1138);
            int _1142 = _1030 & 4;
            bool _1143 = (_1142 == 0);
            float _1144 = max(_1140, _1141);
            bool _1145 = (_1139 > _1144);
            if (!_1143) {
              if (_1145) {
                bool _1148 = (_1136 > 0.0f);
                uint _1149 = _988 + 75u;
                if (_1148) {
                  _1175 = _1129;
                  _1176 = _1132;
                  _1177 = _1133;
                  _1178 = (cb13_raw[_1149].x);
                } else {
                  _1175 = _1134;
                  _1176 = _1132;
                  _1177 = _1126;
                  _1178 = (cb13_raw[_1149].y);
                }
              } else {
                float _1156 = max(_1139, _1141);
                bool _1157 = (_1140 > _1156);
                if (_1157) {
                  bool _1159 = (_1137 > 0.0f);
                  uint _1160 = _988 + 75u;
                  if (_1159) {
                    _1175 = _1133;
                    _1176 = _1132;
                    _1177 = _1134;
                    _1178 = (cb13_raw[_1160].z);
                  } else {
                    _1175 = _1126;
                    _1176 = _1132;
                    _1177 = _1129;
                    _1178 = (cb13_raw[_1160].w);
                  }
                } else {
                  bool _1167 = (_1138 > 0.0f);
                  uint _1168 = _988 + 76u;
                  if (_1167) {
                    _1175 = _1126;
                    _1176 = _1129;
                    _1177 = _1135;
                    _1178 = (cb13_raw[_1168].x);
                  } else {
                    _1175 = _1126;
                    _1176 = _1134;
                    _1177 = _1132;
                    _1178 = (cb13_raw[_1168].y);
                  }
                }
              }
              int _1180 = asint((cb13_raw[_1027].z));
              _1265 = _1175;
              _1266 = _1176;
              _1267 = _1177;
              _1268 = _1178;
              _1269 = _1180;
            } else {
              if (_1145) {
                bool _1183 = (_1136 > 0.0f);
                uint _1184 = _988 + 75u;
                int _1187 = asint((cb13_raw[_1027].z));
                if (_1183) {
                  _1265 = _1129;
                  _1266 = _1132;
                  _1267 = _1133;
                  _1268 = (cb13_raw[_1184].x);
                  _1269 = _1187;
                } else {
                  int _1192 = (uint)(_1187) >> 10;
                  _1265 = _1134;
                  _1266 = _1132;
                  _1267 = _1126;
                  _1268 = (cb13_raw[_1184].y);
                  _1269 = _1192;
                }
              } else {
                float _1194 = max(_1139, _1141);
                bool _1195 = (_1140 > _1194);
                if (_1195) {
                  bool _1197 = (_1137 > 0.0f);
                  uint _1198 = _988 + 75u;
                  if (_1197) {
                    int _1203 = asint((cb13_raw[_1027].z));
                    int _1204 = (uint)(_1203) >> 20;
                    _1265 = _1133;
                    _1266 = _1132;
                    _1267 = _1134;
                    _1268 = (cb13_raw[_1198].z);
                    _1269 = _1204;
                  } else {
                    int _1208 = asint((cb13_raw[_1027].w));
                    _1265 = _1126;
                    _1266 = _1132;
                    _1267 = _1129;
                    _1268 = (cb13_raw[_1198].w);
                    _1269 = _1208;
                  }
                } else {
                  bool _1210 = (_1138 > 0.0f);
                  uint _1211 = _988 + 76u;
                  int _1214 = asint((cb13_raw[_1027].w));
                  if (_1210) {
                    int _1217 = (uint)(_1214) >> 10;
                    _1265 = _1126;
                    _1266 = _1129;
                    _1267 = _1135;
                    _1268 = (cb13_raw[_1211].x);
                    _1269 = _1217;
                  } else {
                    int _1220 = (uint)(_1214) >> 20;
                    _1265 = _1126;
                    _1266 = _1134;
                    _1267 = _1132;
                    _1268 = (cb13_raw[_1211].y);
                    _1269 = _1220;
                  }
                }
              }
            }
          } else {
            float _1222 = _994 / _1002;
            float _1223 = _995 / _1002;
            float _1224 = _996 / _1002;
            float _1225 = abs(_1222);
            float _1226 = abs(_1223);
            float _1227 = abs(_1224);
            float _1228 = max(_1226, _1227);
            bool _1229 = (_1225 > _1228);
            if (_1229) {
              bool _1231 = (_1222 > 0.0f);
              uint _1232 = _988 + 75u;
              if (_1231) {
                _1258 = _1069;
                _1259 = _1070;
                _1260 = _994;
                _1261 = (cb13_raw[_1232].x);
              } else {
                _1258 = _995;
                _1259 = _1070;
                _1260 = _1068;
                _1261 = (cb13_raw[_1232].y);
              }
            } else {
              float _1239 = max(_1225, _1227);
              bool _1240 = (_1226 > _1239);
              if (_1240) {
                bool _1242 = (_1223 > 0.0f);
                uint _1243 = _988 + 75u;
                if (_1242) {
                  _1258 = _994;
                  _1259 = _1070;
                  _1260 = _995;
                  _1261 = (cb13_raw[_1243].z);
                } else {
                  _1258 = _1068;
                  _1259 = _1070;
                  _1260 = _1069;
                  _1261 = (cb13_raw[_1243].w);
                }
              } else {
                bool _1250 = (_1224 > 0.0f);
                uint _1251 = _988 + 76u;
                if (_1250) {
                  _1258 = _1068;
                  _1259 = _1069;
                  _1260 = _996;
                  _1261 = (cb13_raw[_1251].x);
                } else {
                  _1258 = _1068;
                  _1259 = _995;
                  _1260 = _1070;
                  _1261 = (cb13_raw[_1251].y);
                }
              }
            }
            int _1263 = asint((cb13_raw[_1027].z));
            _1265 = _1258;
            _1266 = _1259;
            _1267 = _1260;
            _1268 = _1261;
            _1269 = _1263;
          }
        }
        float _1271 = _1265 * (cb13_raw[_1004].y);
        float _1272 = mad((cb13_raw[_1004].y), _1266, 0.0f);
        float _1273 = _1271 / _1267;
        float _1274 = _1272 / _1267;
        float _1275 = _1273 * 0.5f;
        float _1276 = _1274 * 0.5f;
        float _1277 = _1275 + 0.5f;
        float _1278 = 0.5f - _1276;
        if (_1022) {
          int _1280 = asint(_1268);
          int _1281 = (uint)(_1280) >> 18;
          int _1282 = _1281 & 4092;
          float _1283 = float((uint)_1282);
          bool _1284 = (_1282 == 0);
          [branch]
          if (!_1284) {
            int _1286 = (uint)(_1280) >> 30;
            float _1287 = float((uint)_1286);
            int _1288 = (uint)(_1280) >> 8;
            int _1289 = _1288 & 4092;
            float _1290 = float((uint)_1289);
            uint _1291 = _1280 << 2u;
            int _1292 = _1291 & 4092;
            float _1293 = float((uint)_1292);
            float _1294 = _1277 * _1283;
            float _1295 = _1278 * _1283;
            float _1296 = _1294 + _1293;
            float _1297 = _1295 + _1290;
            float _1300 = cb13_067x * _1296;
            float _1301 = cb13_067x * _1297;
            float _1304 = t9.SampleLevel(s10, float3(_1300, _1301, _1287), 0.0f);
            float _1306 = _1009 * 0.9900000095367432f;
            float _1307 = _1304.x - _1306;
            float _1308 = _1307 * 144.26950073242188f;
            float _1309 = exp2(_1308);
            float _1310 = saturate(_1309);
            _1312 = _1310;
          } else {
            _1312 = 1.0f;
          }
        } else {
          _1312 = 1.0f;
        }
        if (_1032) {
          int _1314 = _1030 & 2;
          bool _1315 = (_1314 != 0);
          int _1316 = _1030 & 8;
          bool _1317 = (_1316 == 0);
          if (_1315) {
            int _1319 = _1269 & 1023;
            _1325 = _1319;
            _1326 = 0;
          } else {
            int _1321 = _1269 & 255;
            int _1322 = (uint)(_1269) >> 8;
            int _1323 = _1322 & 3;
            _1325 = _1321;
            _1326 = _1323;
          }
          float _1327 = float((uint)_1325);
          float _1329 = floor(cb13_raw[_1027].y);
          float _1330 = _1329 + _1327;
          float4 _1334 = t42.SampleLevel(s10, float3(_1277, _1278, _1330), 0.0f);
          _38[0] = _1334.x;
          _38[1] = _1334.y;
          _38[2] = _1334.z;
          _38[3] = _1334.w;
          if (!_1317) {
            float _1344 = _1330 + 1.0f;
            float4 _1345 = t42.SampleLevel(s10, float3(_1277, _1278, _1344), 0.0f);
            float _1350 = frac(cb13_raw[_1027].y);
            float _1351 = _1345.x - _1334.x;
            float _1352 = _1345.y - _1334.y;
            float _1353 = _1345.z - _1334.z;
            float _1354 = _1345.w - _1334.w;
            float _1355 = _1351 * _1350;
            float _1356 = _1352 * _1350;
            float _1357 = _1353 * _1350;
            float _1358 = _1354 * _1350;
            float _1359 = _1355 + _1334.x;
            float _1360 = _1356 + _1334.y;
            float _1361 = _1357 + _1334.z;
            float _1362 = _1358 + _1334.w;
            _38[0] = _1359;
            _38[1] = _1360;
            _38[2] = _1361;
            _38[3] = _1362;
            _1364 = _1361;
            _1365 = _1360;
            _1366 = _1359;
          } else {
            _1364 = _1334.z;
            _1365 = _1334.y;
            _1366 = _1334.x;
          }
          if (!_1315) {
            float _1369 = _38[_1326];
            _1371 = _1369;
            _1372 = _1369;
            _1373 = _1369;
          } else {
            _1371 = _1366;
            _1372 = _1365;
            _1373 = _1364;
          }
          _1375 = _1312;
          _1376 = _1371;
          _1377 = _1372;
          _1378 = _1373;
        } else {
          _1375 = _1312;
          _1376 = 1.0f;
          _1377 = 1.0f;
          _1378 = 1.0f;
        }
      } else {
        _1375 = 1.0f;
        _1376 = 1.0f;
        _1377 = 1.0f;
        _1378 = 1.0f;
      }
      bool _1379 = _1026 && _1065;
      if (_1379) {
        float _1384 = t10.SampleLevel(s10, float4(_994, _995, _996, (cb13_raw[_1023].y)), 0.0f);
        float _1386 = _1009 * 0.9900000095367432f;
        float _1387 = _1384.x - _1386;
        float _1388 = _1387 * 144.26950073242188f;
        float _1389 = exp2(_1388);
        float _1390 = saturate(_1389);
        float _1391 = _1390 * _1375;
        _1393 = _1391;
      } else {
        _1393 = _1375;
      }
      float _1395 = _1393 + -1.0f;
      float _1396 = _1395 * (cb13_raw[_1004].w);
      float _1397 = _1396 + 1.0f;
      int _1398 = _1018 & 2048;
      bool _1399 = (_1398 != 0);
      bool _1400 = (_472.z == 1.0f);
      bool _1401 = _1400 || _1399;
      if (_1401) {
        _1406 = cb12_071y;
      } else {
        _1406 = 0.0f;
      }
      int _1407 = _1018 & 4096;
      bool _1408 = (_1407 != 0);
      bool _1409 = !(_472.z == 1.0f);
      bool _1410 = _1409 || _1408;
      if (_1410) {
        _1415 = cb12_071z;
      } else {
        _1415 = 0.0f;
      }
      float _1416 = _1397 * _1063;
      float _1417 = _1416 * _1406;
      float _1418 = _1417 * _1415;
      float _1419 = _1418 * _1376;
      float _1420 = _1418 * _1377;
      float _1421 = _1418 * _1378;
      bool _1422 = (_1419 > 0.0f);
      bool _1423 = (_1420 > 0.0f);
      bool _1424 = (_1421 > 0.0f);
      bool _1425 = _1422 || _1423;
      bool _1426 = _1424 || _1425;
      [branch]
      if (_1426) {
        bool _1430 = (FrequentPixelConsts_256.x < 0.0f);
        if (!_1430) {
          _1435 = cb12_071x;
        } else {
          _1435 = 1.0f;
        }
        bool _1436 = ((int)_1018 < (int)0);
        float _1437 = select(_1436, _1435, 1.0f);
        float _1438 = _1437 * _1419;
        float _1439 = _1437 * _1420;
        float _1440 = _1437 * _1421;
        float _1441 = dot(float3(_994, _995, _996), float3(_994, _995, _996));
        float _1442 = rsqrt(_1441);
        float _1443 = _1442 * _994;
        float _1444 = _1442 * _995;
        float _1445 = _1442 * _996;
        float _1446 = dot(float3(_406, _407, _408), float3(_1443, _1444, _1445));
        float _1447 = _1446 + 0.25f;
        float _1448 = _1447 * 0.800000011920929f;
        float _1449 = saturate(_1448);
        float _1450 = _1449 + _1446;
        float _1451 = _1449 + 1.0f;
        float _1452 = _1450 / _1451;
        float _1453 = 1.0f / _1451;
        float _1454 = saturate(_1452);
        bool _1455 = (_450 == 1);
        if (_1455) {
          float _1457 = saturate(_1446);
          bool _1458 = (_408 > 0.0f);
          int _1459 = (int)(uint)(_1458);
          int _1460 = _1459 << 1u;
          int _1461 = _1460 + -1;
          float _1462 = float((int)(_1461));
          float _1463 = _1462 + _408;
          float _1464 = -1.0f / _1463;
          float _1465 = _406 * _407;
          float _1466 = _1465 * _1464;
          float _1467 = _406 * _406;
          float _1468 = _1467 * _1462;
          float _1469 = _1468 * _1464;
          float _1470 = _1469 + 1.0f;
          float _1471 = _1466 * _1462;
          int _1472 = 1 - _1460;
          float _1473 = float((int)(_1472));
          float _1474 = _1473 * _406;
          float _1475 = _407 * _407;
          float _1476 = _1475 * _1464;
          float _1477 = _1476 + _1462;
          float _1478 = -0.0f - _407;
          float _1479 = dot(float3(_1443, _1444, _1445), float3(_1443, _1444, _1445));
          float _1480 = rsqrt(_1479);
          float _1481 = _1480 * _1443;
          float _1482 = _1480 * _1444;
          float _1483 = _1480 * _1445;
          float _1484 = _1481 * _1470;
          float _1485 = mad(_1471, _1482, _1484);
          float _1486 = mad(_1474, _1483, _1485);
          float _1487 = _1481 * _1466;
          float _1488 = mad(_1477, _1482, _1487);
          float _1489 = mad(_1478, _1483, _1488);
          float _1490 = _1481 * _406;
          float _1491 = mad(_407, _1482, _1490);
          float _1492 = mad(_408, _1483, _1491);
          float _1493 = dot(float3(_1486, _1489, _1492), float3(_1486, _1489, _1492));
          float _1494 = rsqrt(_1493);
          float _1495 = _1494 * _1486;
          float _1496 = _1494 * _1489;
          float _1497 = _1494 * _1492;
          float _1498 = dot(float3(_468, _469, _470), float3(_468, _469, _470));
          float _1499 = rsqrt(_1498);
          float _1500 = _1499 * _468;
          float _1501 = _1499 * _469;
          float _1502 = _1499 * _470;
          float _1503 = _1500 * _1470;
          float _1504 = mad(_1471, _1501, _1503);
          float _1505 = mad(_1474, _1502, _1504);
          float _1506 = _1500 * _1466;
          float _1507 = mad(_1477, _1501, _1506);
          float _1508 = mad(_1478, _1502, _1507);
          float _1509 = _1500 * _406;
          float _1510 = mad(_407, _1501, _1509);
          float _1511 = mad(_408, _1502, _1510);
          float _1512 = dot(float3(_1505, _1508, _1511), float3(_1505, _1508, _1511));
          float _1513 = rsqrt(_1512);
          float _1514 = _1513 * _1505;
          float _1515 = _1513 * _1508;
          float _1516 = _1513 * _1511;
          float _1517 = dot(float3(_1495, _1496, _1497), float3(_1514, _1515, _1516));
          float _1518 = _1516 * _1497;
          float _1519 = _1517 - _1518;
          bool _1520 = (_1519 > 0.0f);
          if (_1520) {
            float _1522 = max(_1497, _1516);
            float _1523 = _1519 / _1522;
            _1525 = _1523;
          } else {
            _1525 = _1519;
          }
          float _1526 = _1525 * 0.20908956229686737f;
          float _1527 = _1526 + 0.25813528895378113f;
          float _1528 = _1527 * _389;
          float _1529 = _1527 * _390;
          float _1530 = _1527 * _391;
          float _1531 = 1.0f - _1516;
          float _1532 = _1531 * 0.07144299894571304f;
          float _1533 = _1532 + -0.332181453704834f;
          float _1534 = _1533 * _1531;
          float _1535 = _1534 + 0.4918818771839142f;
          float _1536 = _1535 * _1531;
          float _1537 = _1536 + 0.05710852891206741f;
          float _1538 = _1531 * 0.6568742394447327f;
          float _1539 = _1538 * _1537;
          float _1540 = 1.0f - _1497;
          float _1541 = _1540 * 0.07144299894571304f;
          float _1542 = _1541 + -0.332181453704834f;
          float _1543 = _1542 * _1540;
          float _1544 = _1543 + 0.4918818771839142f;
          float _1545 = _1544 * _1540;
          float _1546 = _1545 + 0.05710852891206741f;
          float _1547 = _1540 * 0.6568742394447327f;
          float _1548 = _1547 * _1546;
          float _1549 = _389 * _389;
          float _1550 = _390 * _390;
          float _1551 = _391 * _391;
          float _1552 = _1549 * 0.8585715889930725f;
          float _1553 = _1550 * 0.8585715889930725f;
          float _1554 = _1551 * 0.8585715889930725f;
          float _1555 = _389 * 0.1414284110069275f;
          float _1556 = _390 * 0.1414284110069275f;
          float _1557 = _391 * 0.1414284110069275f;
          float _1558 = 1.0f - _1555;
          float _1559 = 1.0f - _1556;
          float _1560 = 1.0f - _1557;
          float _1561 = _1552 / _1558;
          float _1562 = _1553 / _1559;
          float _1563 = _1554 / _1560;
          float _1564 = 0.1890440583229065f - _1539;
          float _1565 = max(1.0000000116860974e-07f, _1564);
          float _1566 = 0.1890440583229065f - _1548;
          float _1567 = max(1.0000000116860974e-07f, _1566);
          float _1568 = _1565 * 2.250678300857544f;
          float _1569 = _1568 * _1567;
          float _1570 = _1569 * _1561;
          float _1571 = _1569 * _1562;
          float _1572 = _1569 * _1563;
          float _1573 = _1570 + _1528;
          float _1574 = _1571 + _1529;
          float _1575 = _1572 + _1530;
          float _1576 = _1573 * _1457;
          float _1577 = _1574 * _1457;
          float _1578 = _1575 * _1457;
          float _1579 = _1454 - _1457;
          float _1580 = max(0.0f, _1579);
          float _1581 = _1580 * 0.31830987334251404f;
          float _1582 = _1581 * _389;
          float _1583 = _1581 * _390;
          float _1584 = _1581 * _391;
          float _1585 = _1576 + _1582;
          float _1586 = _1577 + _1583;
          float _1587 = _1578 + _1584;
          _1589 = _1585;
          _1590 = _1586;
          _1591 = _1587;
        } else {
          _1589 = _1454;
          _1590 = _1454;
          _1591 = _1454;
        }
        bool _1594 = (cb12_221x > 0.0f);
        float _1595 = 1.0f - _401;
        float _1596 = 1.0f - _402;
        float _1597 = 1.0f - _403;
        if (_1594) {
          float _1599 = dot(float3(_406, _407, _408), float3(_468, _469, _470));
          float4 _1602 = t43.SampleLevel(s10, float2(0.8999999761581421f, _1599), 0.0f);
          float _1605 = _1602.x * _401;
          float _1606 = _1602.x * _402;
          float _1607 = _1602.x * _403;
          float _1608 = _1605 + _1602.y;
          float _1609 = _1606 + _1602.y;
          float _1610 = _1607 + _1602.y;
          float _1611 = _1595 * 0.0476190485060215f;
          float _1612 = _1596 * 0.0476190485060215f;
          float _1613 = _1597 * 0.0476190485060215f;
          float _1614 = _1611 + _401;
          float _1615 = _1612 + _402;
          float _1616 = _1613 + _403;
          float _1617 = 1.0f - _1608;
          float _1618 = 1.0f - _1609;
          float _1619 = 1.0f - _1610;
          float _1620 = _1617 * _1614;
          float _1621 = _1618 * _1615;
          float _1622 = _1619 * _1616;
          float _1623 = 1.0f - _1620;
          float _1624 = 1.0f - _1621;
          float _1625 = 1.0f - _1622;
          float _1626 = max(_1623, 0.0010000000474974513f);
          float _1627 = max(_1624, 0.0010000000474974513f);
          float _1628 = max(_1625, 0.0010000000474974513f);
          float _1629 = _1608 / _1626;
          float _1630 = _1609 / _1627;
          float _1631 = _1610 / _1628;
          float _1632 = min(_1629, 1.0f);
          float _1633 = min(_1630, 1.0f);
          float _1634 = min(_1631, 1.0f);
          _1670 = _1632;
          _1671 = _1633;
          _1672 = _1634;
        } else {
          float _1636 = _1443 + _468;
          float _1637 = _1444 + _469;
          float _1638 = _1445 + _470;
          float _1639 = dot(float3(_1636, _1637, _1638), float3(_1636, _1637, _1638));
          float _1640 = rsqrt(_1639);
          float _1641 = _1640 * _1636;
          float _1642 = _1640 * _1637;
          float _1643 = _1640 * _1638;
          float _1644 = dot(float3(_1641, _1642, _1643), float3(_468, _469, _470));
          float _1645 = abs(_1644);
          float _1646 = 1.0f - _1645;
          float _1647 = saturate(_1646);
          float _1648 = _1647 * _1647;
          float _1652 = max(0.0f, _1595);
          float _1653 = max(0.0f, _1596);
          float _1654 = max(0.0f, _1597);
          float _1655 = _1648 * _1648;
          float _1656 = _1655 * _1647;
          float _1657 = _1656 * cb13_066x;
          float _1658 = _1657 * _1652;
          float _1659 = _1657 * _1653;
          float _1660 = _1657 * _1654;
          float _1661 = cb13_066z * 0.8999999761581421f;
          float _1662 = _1661 + 1.0f;
          float _1663 = _1658 / _1662;
          float _1664 = _1659 / _1662;
          float _1665 = _1660 / _1662;
          float _1666 = _1663 + _401;
          float _1667 = _1664 + _402;
          float _1668 = _1665 + _403;
          _1670 = _1666;
          _1671 = _1667;
          _1672 = _1668;
        }
        float _1673 = 1.0f - _1670;
        float _1674 = 1.0f - _1671;
        float _1675 = 1.0f - _1672;
        float _1676 = _1673 * _1589;
        float _1677 = _1674 * _1590;
        float _1678 = _1675 * _1591;
        int _1679 = _450 & -3;
        bool _1680 = (_1679 == 0);
        float _1681 = _1676 * 0.31830987334251404f;
        float _1682 = _1677 * 0.31830987334251404f;
        float _1683 = _1678 * 0.31830987334251404f;
        float _1684 = select(_1680, _1681, _1676);
        float _1685 = select(_1680, _1682, _1677);
        float _1686 = select(_1680, _1683, _1678);
        float _1690 = _1438 * (cb13_raw[_1015].x);
        float _1691 = _1690 * _1453;
        float _1692 = _1691 * _1684;
        float _1693 = _1439 * (cb13_raw[_1015].y);
        float _1694 = _1693 * _1453;
        float _1695 = _1694 * _1685;
        float _1696 = _1440 * (cb13_raw[_1015].z);
        float _1697 = _1696 * _1453;
        float _1698 = _1697 * _1686;
        float _1699 = _1692 + _974;
        float _1700 = _1695 + _975;
        float _1701 = _1698 + _976;
        float _1702 = dot(float3(_1443, _1444, _1445), float3(_406, _407, _408));
        bool _1703 = (_1702 > 0.0f);
        [branch]
        if (_1703) {
          float _1705 = _1443 + _468;
          float _1706 = _1444 + _469;
          float _1707 = _1445 + _470;
          float _1708 = dot(float3(_1705, _1706, _1707), float3(_1705, _1706, _1707));
          float _1709 = rsqrt(_1708);
          float _1710 = _1709 * _1705;
          float _1711 = _1709 * _1706;
          float _1712 = _1709 * _1707;
          float _1713 = dot(float3(_406, _407, _408), float3(_468, _469, _470));
          float _1714 = saturate(_1446);
          float _1715 = dot(float3(_182, _183, _184), float3(_182, _183, _184));
          float _1716 = rsqrt(_1715);
          float _1717 = _1716 * _182;
          float _1718 = _1716 * _183;
          float _1719 = _1716 * _184;
          float _1720 = dot(float3(_1717, _1718, _1719), float3(_406, _407, _408));
          float _1721 = _1720 * _406;
          float _1722 = _1720 * _407;
          float _1723 = _1720 * _408;
          float _1724 = _1717 - _1721;
          float _1725 = _1718 - _1722;
          float _1726 = _1719 - _1723;
          float _1727 = dot(float3(_1724, _1725, _1726), float3(_1724, _1725, _1726));
          float _1728 = rsqrt(_1727);
          float _1729 = _1724 * _1728;
          float _1730 = _1725 * _1728;
          float _1731 = _1726 * _1728;
          float _1732 = _1730 * _408;
          float _1733 = _1731 * _407;
          float _1734 = _1732 - _1733;
          float _1735 = _1731 * _406;
          float _1736 = _1729 * _408;
          float _1737 = _1735 - _1736;
          float _1738 = _1729 * _407;
          float _1739 = _1730 * _406;
          float _1740 = _1738 - _1739;
          float _1741 = dot(float3(_1734, _1737, _1740), float3(_1734, _1737, _1740));
          float _1742 = rsqrt(_1741);
          float _1743 = _1734 * _1742;
          float _1744 = _1737 * _1742;
          float _1745 = _1740 * _1742;
          float _1746 = dot(float3(_1729, _1730, _1731), float3(_1710, _1711, _1712));
          float _1747 = _1746 * 1.2345679998397827f;
          float _1748 = _1747 * _1747;
          float _1749 = dot(float3(_1743, _1744, _1745), float3(_1710, _1711, _1712));
          float _1750 = _1749 * 1.2345679998397827f;
          float _1751 = _1750 * _1750;
          float _1752 = dot(float3(_406, _407, _408), float3(_1710, _1711, _1712));
          float _1753 = saturate(_1752);
          float _1754 = _1753 * _1753;
          float _1755 = _1751 + _1748;
          float _1756 = _1755 + _1754;
          float _1757 = _1756 * _1756;
          float _1758 = 0.4851658046245575f / _1757;
          float _1759 = abs(_1713);
          float _1760 = dot(float3(_1710, _1711, _1712), float3(_468, _469, _470));
          float _1761 = abs(_1760);
          float _1762 = 1.0f - _1761;
          float _1763 = saturate(_1762);
          float _1764 = _1763 * _1763;
          float _1768 = max(0.0f, _1595);
          float _1769 = max(0.0f, _1596);
          float _1770 = max(0.0f, _1597);
          float _1771 = _1764 * _1764;
          float _1772 = _1771 * _1763;
          float _1773 = _1772 * cb13_066x;
          float _1774 = _1773 * _1768;
          float _1775 = _1773 * _1769;
          float _1776 = _1773 * _1770;
          float _1777 = cb13_066z * 0.8999999761581421f;
          float _1778 = _1777 + 1.0f;
          float _1779 = _1774 / _1778;
          float _1780 = _1775 / _1778;
          float _1781 = _1776 / _1778;
          float _1782 = _1779 + _401;
          float _1783 = _1780 + _402;
          float _1784 = _1781 + _403;
          bool _1786 = (cb12_221z > 0.0f);
          [branch]
          if (_1786) {
            float _1788 = saturate(_1713);
            float _1789 = _1788 + _1714;
            float _1790 = _1714 * 2.0f;
            float _1791 = _1790 * _1788;
            float _1792 = _1789 - _1791;
            float _1793 = _1792 * 0.809999942779541f;
            float _1794 = _1793 + _1791;
            _1809 = _1794;
          } else {
            float _1796 = _1759 * _1759;
            float _1797 = _1796 * 0.34390008449554443f;
            float _1798 = _1797 + 0.6560999155044556f;
            float _1799 = sqrt(_1798);
            float _1800 = _1799 * _1714;
            float _1801 = _1714 * _1714;
            float _1802 = _1801 * 0.34390008449554443f;
            float _1803 = _1802 + 0.6560999155044556f;
            float _1804 = sqrt(_1803);
            float _1805 = _1804 * _1759;
            float _1806 = _1800 + 9.999999747378752e-05f;
            float _1807 = _1806 + _1805;
            _1809 = _1807;
          }
          float _1810 = 0.5f / _1809;
          float _1811 = _1810 * _1758;
          float _1812 = _1811 * _1782;
          float _1813 = _1811 * _1783;
          float _1814 = _1811 * _1784;
          bool _1816 = (cb12_221y > 0.0f);
          if (_1816) {
            float _1818 = dot(float3(_406, _407, _408), float3(_1810, _1810, _1810));
            float4 _1821 = t43.SampleLevel(s10, float2(0.8999999761581421f, _1818), 0.0f);
            float _1824 = _1821.x * _401;
            float _1825 = _1821.x * _402;
            float _1826 = _1821.x * _403;
            float _1827 = _1824 + _1821.y;
            float _1828 = _1825 + _1821.y;
            float _1829 = _1826 + _1821.y;
            float _1830 = _1595 * 0.0476190485060215f;
            float _1831 = _1596 * 0.0476190485060215f;
            float _1832 = _1597 * 0.0476190485060215f;
            float _1833 = _1830 + _401;
            float _1834 = _1831 + _402;
            float _1835 = _1832 + _403;
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
            float _1854 = max(_1827, 9.999999747378752e-05f);
            float _1855 = max(_1828, 9.999999747378752e-05f);
            float _1856 = max(_1829, 9.999999747378752e-05f);
            float _1857 = _1851 / _1854;
            float _1858 = _1852 / _1855;
            float _1859 = _1853 / _1856;
            float _1860 = _1857 * _1812;
            float _1861 = _1858 * _1813;
            float _1862 = _1859 * _1814;
            _1864 = _1860;
            _1865 = _1861;
            _1866 = _1862;
          } else {
            _1864 = _1812;
            _1865 = _1813;
            _1866 = _1814;
          }
          float _1867 = _1864 * _1714;
          float _1868 = _1865 * _1714;
          float _1869 = _1866 * _1714;
          _1871 = _1867;
          _1872 = _1868;
          _1873 = _1869;
        } else {
          _1871 = 0.0f;
          _1872 = 0.0f;
          _1873 = 0.0f;
        }
        float _1874 = _1690 * _1871;
        float _1875 = _1693 * _1872;
        float _1876 = _1696 * _1873;
        float _1877 = _1874 + _977;
        float _1878 = _1875 + _978;
        float _1879 = _1876 + _979;
        _1881 = _1699;
        _1882 = _1700;
        _1883 = _1701;
        _1884 = _1877;
        _1885 = _1878;
        _1886 = _1879;
      } else {
        _1881 = _974;
        _1882 = _975;
        _1883 = _976;
        _1884 = _977;
        _1885 = _978;
        _1886 = _979;
      }
      int _1887 = _980 + 1;
      bool _1888 = ((int)_1887 < (int)256);
      if (_1888) {
        _974 = _1881;
        _975 = _1882;
        _976 = _1883;
        _977 = _1884;
        _978 = _1885;
        _979 = _1886;
        _980 = _1887;
        continue;
      } else {
        _1890 = _1881;
        _1891 = _1882;
        _1892 = _1883;
        _1893 = _1884;
        _1894 = _1885;
        _1895 = _1886;
      }
    } else {
      _1890 = _974;
      _1891 = _975;
      _1892 = _976;
      _1893 = _977;
      _1894 = _978;
      _1895 = _979;
    }
    break;
  }
  float _1896 = -0.0f - _468;
  float _1897 = -0.0f - _469;
  float _1898 = -0.0f - _470;
  float _1899 = dot(float3(_1896, _1897, _1898), float3(_406, _407, _408));
  float _1900 = _1899 * 2.0f;
  float _1901 = _1900 * _406;
  float _1902 = _1900 * _407;
  float _1903 = _1900 * _408;
  float _1904 = _1896 - _1901;
  float _1905 = _1897 - _1902;
  float _1906 = _1898 - _1903;
  _1908 = 1;
  _1909 = 0.0f;
  _1910 = 0.0f;
  _1911 = 0.0f;
  _1912 = 9.999999747378752e-06f;
  while(true) {
    int _1913 = _1908 * 12;
    int _1914 = _1913 + 102;
    int _1919 = _1913 + 103;
    int _1924 = _1913 + 104;
    int _1929 = _1913 + 105;
    float _1934 = (cb12_raw[_1914].x) * _75;
    float _1935 = mad((cb12_raw[_1919].x), _76, _1934);
    float _1936 = mad((cb12_raw[_1924].x), _77, _1935);
    float _1937 = _1936 + (cb12_raw[_1929].x);
    float _1938 = (cb12_raw[_1914].y) * _75;
    float _1939 = mad((cb12_raw[_1919].y), _76, _1938);
    float _1940 = mad((cb12_raw[_1924].y), _77, _1939);
    float _1941 = _1940 + (cb12_raw[_1929].y);
    float _1942 = (cb12_raw[_1914].z) * _75;
    float _1943 = mad((cb12_raw[_1919].z), _76, _1942);
    float _1944 = mad((cb12_raw[_1924].z), _77, _1943);
    float _1945 = _1944 + (cb12_raw[_1929].z);
    float _1946 = abs(_1937);
    float _1947 = abs(_1941);
    float _1948 = abs(_1945);
    float _1949 = 1.0f - _1946;
    float _1950 = 1.0f - _1947;
    float _1951 = 1.0f - _1948;
    bool _1952 = (_1949 > 0.0f);
    bool _1953 = (_1950 > 0.0f);
    bool _1954 = (_1951 > 0.0f);
    bool _1955 = _1952 && _1953;
    bool _1956 = _1955 && _1954;
    if (_1956) {
      int _1958 = _1913 + 101;
      float _1963 = (cb12_raw[_1958].x) * _1949;
      float _1964 = (cb12_raw[_1958].y) * _1950;
      float _1965 = (cb12_raw[_1958].z) * _1951;
      float _1966 = saturate(_1963);
      float _1967 = saturate(_1964);
      float _1968 = saturate(_1965);
      float _1969 = 1.0f - _1912;
      int _1970 = _1913 + 100;
      float _1973 = _1966 * _1969;
      float _1974 = _1973 * _1967;
      float _1975 = _1974 * _1968;
      float _1976 = _1975 * (cb12_raw[_1970].x);
      float _1977 = _1976 + _1912;
      int _1978 = _1913 + 106;
      float _1981 = _1976 * (cb12_raw[_1978].x);
      int _1985 = _1913 + 107;
      int _1990 = _1913 + 108;
      int _1995 = _1913 + 109;
      float _2000 = (cb12_raw[_1985].x) * _1904;
      float _2001 = mad((cb12_raw[_1990].x), _1905, _2000);
      float _2002 = mad((cb12_raw[_1995].x), _1906, _2001);
      float _2003 = (cb12_raw[_1985].y) * _1904;
      float _2004 = mad((cb12_raw[_1990].y), _1905, _2003);
      float _2005 = mad((cb12_raw[_1995].y), _1906, _2004);
      float _2006 = (cb12_raw[_1985].z) * _1904;
      float _2007 = mad((cb12_raw[_1990].z), _1905, _2006);
      float _2008 = mad((cb12_raw[_1995].z), _1906, _2007);
      int _2009 = _1913 + 110;
      float _2014 = (cb12_raw[_1985].x) * _75;
      float _2015 = mad((cb12_raw[_1990].x), _76, _2014);
      float _2016 = mad((cb12_raw[_1995].x), _77, _2015);
      float _2017 = _2016 + (cb12_raw[_2009].x);
      float _2018 = (cb12_raw[_1985].y) * _75;
      float _2019 = mad((cb12_raw[_1990].y), _76, _2018);
      float _2020 = mad((cb12_raw[_1995].y), _77, _2019);
      float _2021 = _2020 + (cb12_raw[_2009].y);
      float _2022 = (cb12_raw[_1985].z) * _75;
      float _2023 = mad((cb12_raw[_1990].z), _76, _2022);
      float _2024 = mad((cb12_raw[_1995].z), _77, _2023);
      float _2025 = _2024 + (cb12_raw[_2009].z);
      float _2026 = 1.0f / _2002;
      float _2027 = 1.0f / _2005;
      float _2028 = 1.0f / _2008;
      float _2029 = _2026 * _2017;
      float _2030 = _2027 * _2021;
      float _2031 = _2028 * _2025;
      float _2032 = _2026 - _2029;
      float _2033 = _2027 - _2030;
      float _2034 = _2028 - _2031;
      float _2035 = -0.0f - _2026;
      float _2036 = -0.0f - _2027;
      float _2037 = -0.0f - _2028;
      float _2038 = _2035 - _2029;
      float _2039 = _2036 - _2030;
      float _2040 = _2037 - _2031;
      float _2041 = max(_2032, _2038);
      float _2042 = max(_2033, _2039);
      float _2043 = max(_2034, _2040);
      float _2044 = min(_2042, _2043);
      float _2045 = min(_2041, _2044);
      float _2046 = _2045 * _1904;
      float _2047 = _2045 * _1905;
      float _2048 = _2045 * _1906;
      float _2049 = _75 - (cb12_raw[_1970].y);
      float _2050 = _2046 + _2049;
      float _2051 = _76 - (cb12_raw[_1970].z);
      float _2052 = _2047 + _2051;
      float _2053 = _77 - (cb12_raw[_1970].w);
      float _2054 = _2048 + _2053;
      float _2055 = dot(float3(_2050, _2052, _2054), float3(_2050, _2052, _2054));
      float _2056 = rsqrt(_2055);
      float _2057 = _2050 * _2056;
      float _2058 = _2052 * _2056;
      float _2059 = _2054 * _2056;
      int _2060 = _1913 + 111;
      bool _2063 = (_2059 < 0.0f);
      float _2064 = _2057 * 0.5f;
      float _2065 = _2058 * -0.5f;
      float _2066 = 1.0f - _2059;
      float _2067 = 1.0f / _2066;
      float _2068 = max(_2067, -3.4028234663852886e+38f);
      float _2069 = min(_2068, 3.4028234663852886e+38f);
      float _2070 = _2064 * _2069;
      float _2071 = _2065 * _2069;
      float _2072 = _2057 * -0.5f;
      float _2073 = _2058 * 0.5f;
      float _2074 = _2059 + 1.0f;
      float _2075 = 1.0f / _2074;
      float _2076 = max(_2075, -3.4028234663852886e+38f);
      float _2077 = min(_2076, 3.4028234663852886e+38f);
      float _2078 = _2072 * _2077;
      float _2079 = _2073 * _2077;
      float _2080 = select(_2063, _2070, _2078);
      float _2081 = _2080 + 0.5f;
      float _2082 = select(_2063, _2071, _2079);
      float _2083 = _2082 + 0.5f;
      float _2084 = _2081 * 0.6666666269302368f;
      float _2085 = _2083 * 0.6666666269302368f;
      float _2086 = float((int)(asint(cb12_raw[_2060].x)));
      float _2087 = float((bool)_2063);
      float _2088 = _2087 + 0.1666666716337204f;
      float _2089 = _2088 + _2084;
      float _2090 = _2086 + 0.1666666716337204f;
      float _2091 = _2090 + _2085;
      float _2092 = _2089 * 0.5f;
      float _2093 = _2091 * 0.1428571492433548f;
      float4 _2096 = t23.SampleLevel(s11, float2(_2092, _2093), 5.0f);
      float _2100 = _2096.x * _1981;
      float _2101 = _2096.y * _1981;
      float _2102 = _2096.z * _1981;
      float _2103 = _2100 + _1911;
      float _2104 = _2101 + _1910;
      float _2105 = _2102 + _1909;
      _2107 = _1977;
      _2108 = _2103;
      _2109 = _2104;
      _2110 = _2105;
    } else {
      _2107 = _1912;
      _2108 = _1911;
      _2109 = _1910;
      _2110 = _1909;
    }
    int _2111 = _1908 + 1;
    bool _2112 = ((uint)_2111 < (uint)7);
    _2113 = (_2107 < 0.9990000128746033f);
    bool _2114 = _2112 && _2113;
    if (_2114) {
      _1908 = _2111;
      _1909 = _2110;
      _1910 = _2109;
      _1911 = _2108;
      _1912 = _2107;
      continue;
    }
    break;
  }
  [branch]
  if (_2113) {
    float _2117 = 1.0f - _2107;
    float _2120 = cb12_100x * _2117;
    float _2121 = _2120 + _2107;
    float _2124 = _2120 * cb12_106x;
    bool _2127 = (_1906 < 0.0f);
    float _2128 = _1904 * 0.5f;
    float _2129 = _1905 * -0.5f;
    float _2130 = 1.0f - _1906;
    float _2131 = 1.0f / _2130;
    float _2132 = max(_2131, -3.4028234663852886e+38f);
    float _2133 = min(_2132, 3.4028234663852886e+38f);
    float _2134 = _2128 * _2133;
    float _2135 = _2129 * _2133;
    float _2136 = _1904 * -0.5f;
    float _2137 = _1905 * 0.5f;
    float _2138 = _1906 + 1.0f;
    float _2139 = 1.0f / _2138;
    float _2140 = max(_2139, -3.4028234663852886e+38f);
    float _2141 = min(_2140, 3.4028234663852886e+38f);
    float _2142 = _2136 * _2141;
    float _2143 = _2137 * _2141;
    float _2144 = select(_2127, _2134, _2142);
    float _2145 = _2144 + 0.5f;
    float _2146 = select(_2127, _2135, _2143);
    float _2147 = _2146 + 0.5f;
    float _2148 = _2145 * 0.6666666269302368f;
    float _2149 = _2147 * 0.6666666269302368f;
    float _2150 = float((int)(cb12_111x));
    float _2151 = float((bool)_2127);
    float _2152 = _2151 + 0.1666666716337204f;
    float _2153 = _2152 + _2148;
    float _2154 = _2150 + 0.1666666716337204f;
    float _2155 = _2154 + _2149;
    float _2156 = _2153 * 0.5f;
    float _2157 = _2155 * 0.1428571492433548f;
    float4 _2160 = t23.SampleLevel(s11, float2(_2156, _2157), 5.0f);
    float _2164 = _2160.x * _2124;
    float _2165 = _2160.y * _2124;
    float _2166 = _2160.z * _2124;
    float _2167 = _2164 + _2108;
    float _2168 = _2165 + _2109;
    float _2169 = _2166 + _2110;
    _2171 = _2121;
    _2172 = _2167;
    _2173 = _2168;
    _2174 = _2169;
  } else {
    _2171 = _2107;
    _2172 = _2108;
    _2173 = _2109;
    _2174 = _2110;
  }
  _2176 = 1;
  _2177 = 0.0f;
  _2178 = 0.0f;
  _2179 = 0.0f;
  _2180 = 9.999999747378752e-06f;
  while(true) {
    int _2181 = _2176 * 12;
    int _2182 = _2181 + 102;
    int _2187 = _2181 + 103;
    int _2192 = _2181 + 104;
    int _2197 = _2181 + 105;
    float _2202 = (cb12_raw[_2182].x) * _75;
    float _2203 = mad((cb12_raw[_2187].x), _76, _2202);
    float _2204 = mad((cb12_raw[_2192].x), _77, _2203);
    float _2205 = _2204 + (cb12_raw[_2197].x);
    float _2206 = (cb12_raw[_2182].y) * _75;
    float _2207 = mad((cb12_raw[_2187].y), _76, _2206);
    float _2208 = mad((cb12_raw[_2192].y), _77, _2207);
    float _2209 = _2208 + (cb12_raw[_2197].y);
    float _2210 = (cb12_raw[_2182].z) * _75;
    float _2211 = mad((cb12_raw[_2187].z), _76, _2210);
    float _2212 = mad((cb12_raw[_2192].z), _77, _2211);
    float _2213 = _2212 + (cb12_raw[_2197].z);
    float _2214 = abs(_2205);
    float _2215 = abs(_2209);
    float _2216 = abs(_2213);
    float _2217 = 1.0f - _2214;
    float _2218 = 1.0f - _2215;
    float _2219 = 1.0f - _2216;
    bool _2220 = (_2217 > 0.0f);
    bool _2221 = (_2218 > 0.0f);
    bool _2222 = (_2219 > 0.0f);
    bool _2223 = _2220 && _2221;
    bool _2224 = _2223 && _2222;
    if (_2224) {
      int _2226 = _2181 + 101;
      float _2231 = (cb12_raw[_2226].x) * _2217;
      float _2232 = (cb12_raw[_2226].y) * _2218;
      float _2233 = (cb12_raw[_2226].z) * _2219;
      float _2234 = saturate(_2231);
      float _2235 = saturate(_2232);
      float _2236 = saturate(_2233);
      float _2237 = 1.0f - _2180;
      int _2238 = _2181 + 100;
      float _2241 = _2234 * _2237;
      float _2242 = _2241 * _2235;
      float _2243 = _2242 * _2236;
      float _2244 = _2243 * (cb12_raw[_2238].x);
      float _2245 = _2244 + _2180;
      int _2246 = _2181 + 106;
      float _2249 = _2244 * (cb12_raw[_2246].x);
      int _2253 = _2181 + 107;
      int _2258 = _2181 + 108;
      int _2263 = _2181 + 109;
      float _2268 = (cb12_raw[_2253].x) * _1904;
      float _2269 = mad((cb12_raw[_2258].x), _1905, _2268);
      float _2270 = mad((cb12_raw[_2263].x), _1906, _2269);
      float _2271 = (cb12_raw[_2253].y) * _1904;
      float _2272 = mad((cb12_raw[_2258].y), _1905, _2271);
      float _2273 = mad((cb12_raw[_2263].y), _1906, _2272);
      float _2274 = (cb12_raw[_2253].z) * _1904;
      float _2275 = mad((cb12_raw[_2258].z), _1905, _2274);
      float _2276 = mad((cb12_raw[_2263].z), _1906, _2275);
      int _2277 = _2181 + 110;
      float _2282 = (cb12_raw[_2253].x) * _75;
      float _2283 = mad((cb12_raw[_2258].x), _76, _2282);
      float _2284 = mad((cb12_raw[_2263].x), _77, _2283);
      float _2285 = _2284 + (cb12_raw[_2277].x);
      float _2286 = (cb12_raw[_2253].y) * _75;
      float _2287 = mad((cb12_raw[_2258].y), _76, _2286);
      float _2288 = mad((cb12_raw[_2263].y), _77, _2287);
      float _2289 = _2288 + (cb12_raw[_2277].y);
      float _2290 = (cb12_raw[_2253].z) * _75;
      float _2291 = mad((cb12_raw[_2258].z), _76, _2290);
      float _2292 = mad((cb12_raw[_2263].z), _77, _2291);
      float _2293 = _2292 + (cb12_raw[_2277].z);
      float _2294 = 1.0f / _2270;
      float _2295 = 1.0f / _2273;
      float _2296 = 1.0f / _2276;
      float _2297 = _2294 * _2285;
      float _2298 = _2295 * _2289;
      float _2299 = _2296 * _2293;
      float _2300 = _2294 - _2297;
      float _2301 = _2295 - _2298;
      float _2302 = _2296 - _2299;
      float _2303 = -0.0f - _2294;
      float _2304 = -0.0f - _2295;
      float _2305 = -0.0f - _2296;
      float _2306 = _2303 - _2297;
      float _2307 = _2304 - _2298;
      float _2308 = _2305 - _2299;
      float _2309 = max(_2300, _2306);
      float _2310 = max(_2301, _2307);
      float _2311 = max(_2302, _2308);
      float _2312 = min(_2310, _2311);
      float _2313 = min(_2309, _2312);
      float _2314 = _2313 * _1904;
      float _2315 = _2313 * _1905;
      float _2316 = _2313 * _1906;
      float _2317 = _75 - (cb12_raw[_2238].y);
      float _2318 = _2314 + _2317;
      float _2319 = _76 - (cb12_raw[_2238].z);
      float _2320 = _2315 + _2319;
      float _2321 = _77 - (cb12_raw[_2238].w);
      float _2322 = _2316 + _2321;
      float _2323 = dot(float3(_2318, _2320, _2322), float3(_2318, _2320, _2322));
      float _2324 = rsqrt(_2323);
      float _2325 = _2318 * _2324;
      float _2326 = _2320 * _2324;
      float _2327 = _2322 * _2324;
      int _2328 = _2181 + 111;
      bool _2331 = (_2327 < 0.0f);
      float _2332 = _2325 * 0.5f;
      float _2333 = _2326 * -0.5f;
      float _2334 = 1.0f - _2327;
      float _2335 = 1.0f / _2334;
      float _2336 = max(_2335, -3.4028234663852886e+38f);
      float _2337 = min(_2336, 3.4028234663852886e+38f);
      float _2338 = _2332 * _2337;
      float _2339 = _2333 * _2337;
      float _2340 = _2325 * -0.5f;
      float _2341 = _2326 * 0.5f;
      float _2342 = _2327 + 1.0f;
      float _2343 = 1.0f / _2342;
      float _2344 = max(_2343, -3.4028234663852886e+38f);
      float _2345 = min(_2344, 3.4028234663852886e+38f);
      float _2346 = _2340 * _2345;
      float _2347 = _2341 * _2345;
      float _2348 = select(_2331, _2338, _2346);
      float _2349 = _2348 + 0.5f;
      float _2350 = select(_2331, _2339, _2347);
      float _2351 = _2350 + 0.5f;
      float _2352 = _2349 * 0.6666666269302368f;
      float _2353 = _2351 * 0.6666666269302368f;
      float _2354 = float((int)(asint(cb12_raw[_2328].x)));
      float _2355 = float((bool)_2331);
      float _2356 = _2355 + 0.1666666716337204f;
      float _2357 = _2356 + _2352;
      float _2358 = _2354 + 0.1666666716337204f;
      float _2359 = _2358 + _2353;
      float _2360 = _2357 * 0.5f;
      float _2361 = _2359 * 0.1428571492433548f;
      float4 _2364 = t23.SampleLevel(s11, float2(_2360, _2361), 5.0f);
      float _2368 = _2364.x * _2249;
      float _2369 = _2364.y * _2249;
      float _2370 = _2364.z * _2249;
      float _2371 = _2368 + _2179;
      float _2372 = _2369 + _2178;
      float _2373 = _2370 + _2177;
      _2375 = _2245;
      _2376 = _2371;
      _2377 = _2372;
      _2378 = _2373;
    } else {
      _2375 = _2180;
      _2376 = _2179;
      _2377 = _2178;
      _2378 = _2177;
    }
    int _2379 = _2176 + 1;
    bool _2380 = ((uint)_2379 < (uint)7);
    _2381 = (_2375 < 0.9990000128746033f);
    bool _2382 = _2380 && _2381;
    if (_2382) {
      _2176 = _2379;
      _2177 = _2378;
      _2178 = _2377;
      _2179 = _2376;
      _2180 = _2375;
      continue;
    }
    break;
  }
  float _2384 = 1.0f / _2171;
  [branch]
  if (_2381) {
    float _2386 = 1.0f - _2375;
    float _2389 = cb12_100x * _2386;
    float _2390 = _2389 + _2375;
    float _2393 = _2389 * cb12_106x;
    bool _2396 = (_1906 < 0.0f);
    float _2397 = _1904 * 0.5f;
    float _2398 = _1905 * -0.5f;
    float _2399 = 1.0f - _1906;
    float _2400 = 1.0f / _2399;
    float _2401 = max(_2400, -3.4028234663852886e+38f);
    float _2402 = min(_2401, 3.4028234663852886e+38f);
    float _2403 = _2397 * _2402;
    float _2404 = _2398 * _2402;
    float _2405 = _1904 * -0.5f;
    float _2406 = _1905 * 0.5f;
    float _2407 = _1906 + 1.0f;
    float _2408 = 1.0f / _2407;
    float _2409 = max(_2408, -3.4028234663852886e+38f);
    float _2410 = min(_2409, 3.4028234663852886e+38f);
    float _2411 = _2405 * _2410;
    float _2412 = _2406 * _2410;
    float _2413 = select(_2396, _2403, _2411);
    float _2414 = _2413 + 0.5f;
    float _2415 = select(_2396, _2404, _2412);
    float _2416 = _2415 + 0.5f;
    float _2417 = _2414 * 0.6666666269302368f;
    float _2418 = _2416 * 0.6666666269302368f;
    float _2419 = float((int)(cb12_111x));
    float _2420 = float((bool)_2396);
    float _2421 = _2420 + 0.1666666716337204f;
    float _2422 = _2421 + _2417;
    float _2423 = _2419 + 0.1666666716337204f;
    float _2424 = _2423 + _2418;
    float _2425 = _2422 * 0.5f;
    float _2426 = _2424 * 0.1428571492433548f;
    float4 _2429 = t23.SampleLevel(s11, float2(_2425, _2426), 5.0f);
    float _2433 = _2429.x * _2393;
    float _2434 = _2429.y * _2393;
    float _2435 = _2429.z * _2393;
    float _2436 = _2433 + _2376;
    float _2437 = _2434 + _2377;
    float _2438 = _2435 + _2378;
    _2440 = _2390;
    _2441 = _2436;
    _2442 = _2437;
    _2443 = _2438;
  } else {
    _2440 = _2375;
    _2441 = _2376;
    _2442 = _2377;
    _2443 = _2378;
  }
  float _2444 = 1.0f / _2440;
  float _2445 = _2444 * _2441;
  float _2446 = _2444 * _2442;
  float _2447 = _2444 * _2443;
  bool _2450 = (cb12_074y > 0.0f);
  if (!_2450) {
    float _2456 = (gridDesc_000[1].PROBE_GRID_DESC_176.x) * _75;
    float _2457 = (gridDesc_000[1].PROBE_GRID_DESC_176.y) * _76;
    float _2458 = (gridDesc_000[1].PROBE_GRID_DESC_176.z) * _77;
    float _2463 = _2456 + (gridDesc_000[1].PROBE_GRID_DESC_208.x);
    float _2464 = _2457 + (gridDesc_000[1].PROBE_GRID_DESC_208.y);
    float _2465 = _2458 + (gridDesc_000[1].PROBE_GRID_DESC_208.z);
    float _2466 = abs(_2463);
    float _2467 = abs(_2464);
    float _2468 = abs(_2465);
    float _2473 = (gridDesc_000[1].PROBE_GRID_DESC_224.x) * _2466;
    float _2474 = (gridDesc_000[1].PROBE_GRID_DESC_224.y) * _2467;
    float _2475 = (gridDesc_000[1].PROBE_GRID_DESC_224.z) * _2468;
    float _2477 = _2473 + (gridDesc_000[1].PROBE_GRID_DESC_236);
    float _2478 = _2474 + (gridDesc_000[1].PROBE_GRID_DESC_236);
    float _2479 = _2475 + (gridDesc_000[1].PROBE_GRID_DESC_236);
    float _2480 = saturate(_2477);
    float _2481 = saturate(_2478);
    float _2482 = saturate(_2479);
    float _2483 = min(_2480, _2481);
    float _2484 = _2482 * _2482;
    float _2485 = _2484 * _2483;
    float _2490 = (gridDesc_000[0].PROBE_GRID_DESC_176.x) * _75;
    float _2491 = (gridDesc_000[0].PROBE_GRID_DESC_176.y) * _76;
    float _2492 = (gridDesc_000[0].PROBE_GRID_DESC_176.z) * _77;
    float _2497 = _2490 + (gridDesc_000[0].PROBE_GRID_DESC_208.x);
    float _2498 = _2491 + (gridDesc_000[0].PROBE_GRID_DESC_208.y);
    float _2499 = _2492 + (gridDesc_000[0].PROBE_GRID_DESC_208.z);
    float _2500 = abs(_2497);
    float _2501 = abs(_2498);
    float _2502 = abs(_2499);
    float _2507 = (gridDesc_000[0].PROBE_GRID_DESC_224.x) * _2500;
    float _2508 = (gridDesc_000[0].PROBE_GRID_DESC_224.y) * _2501;
    float _2509 = (gridDesc_000[0].PROBE_GRID_DESC_224.z) * _2502;
    float _2511 = _2507 + (gridDesc_000[0].PROBE_GRID_DESC_236);
    float _2512 = _2508 + (gridDesc_000[0].PROBE_GRID_DESC_236);
    float _2513 = _2509 + (gridDesc_000[0].PROBE_GRID_DESC_236);
    float _2514 = saturate(_2511);
    float _2515 = saturate(_2512);
    float _2516 = saturate(_2513);
    float _2517 = min(_2514, _2515);
    float _2518 = _2516 * _2516;
    float _2519 = _2518 * _2517;
    bool _2520 = (_2485 > 9.999999717180685e-10f);
    int _2521 = (int)(uint)(_2520);
    bool _2522 = (_2485 < 1.0f);
    bool _2523 = (_2519 > 9.999999717180685e-10f);
    bool _2524 = _2522 && _2523;
    int _2525 = (int)(uint)(_2524);
    if (_2520) {
      float _2559 = (gridDesc_000[1].PROBE_GRID_DESC_152) * _406;
      float _2560 = (gridDesc_000[1].PROBE_GRID_DESC_152) * _407;
      float _2561 = (gridDesc_000[1].PROBE_GRID_DESC_152) * _408;
      float _2562 = _2559 + _75;
      float _2563 = _2560 + _76;
      float _2564 = _2561 + _77;
      float _2565 = (gridDesc_000[1].PROBE_GRID_DESC_156) * _468;
      float _2566 = (gridDesc_000[1].PROBE_GRID_DESC_156) * _469;
      float _2567 = (gridDesc_000[1].PROBE_GRID_DESC_156) * _470;
      float _2568 = _2562 + _2565;
      float _2569 = _2563 + _2566;
      float _2570 = _2564 + _2567;
      float _2571 = _2568 * (gridDesc_000[1].PROBE_GRID_DESC_176.x);
      float _2572 = _2569 * (gridDesc_000[1].PROBE_GRID_DESC_176.y);
      float _2573 = _2570 * (gridDesc_000[1].PROBE_GRID_DESC_176.z);
      float _2574 = _2571 + (gridDesc_000[1].PROBE_GRID_DESC_192.x);
      float _2575 = _2572 + (gridDesc_000[1].PROBE_GRID_DESC_192.y);
      float _2576 = _2573 + (gridDesc_000[1].PROBE_GRID_DESC_192.z);
      int _2577 = int(_2574);
      int _2578 = int(_2575);
      int _2579 = int(_2576);
      uint _2580 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) + -1u;
      uint _2581 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) + -1u;
      uint _2582 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) + -1u;
      int _2583 = max(_2577, 0);
      int _2584 = max(_2578, 0);
      int _2585 = max(_2579, 0);
      int _2586 = min(_2583, _2580);
      int _2587 = min(_2584, _2581);
      int _2588 = min(_2585, _2582);
      float _2589 = float((int)(_2586));
      float _2590 = float((int)(_2587));
      float _2591 = float((int)(_2588));
      float _2592 = _2574 - _2589;
      float _2593 = _2575 - _2590;
      float _2594 = _2576 - _2591;
      _2598 = 0.0f;
      _2599 = 0.0f;
      _2600 = 0.0f;
      _2601 = 0.0f;
      _2602 = 0.0f;
      _2603 = 0;
      while(true) {
        int _2604 = (uint)(_2603) >> 1;
        int _2605 = (uint)(_2603) >> 2;
        int _2606 = _2603 & 1;
        int _2607 = _2604 & 1;
        int _2608 = _2605 & 1;
        uint _2609 = _2606 + _2586;
        uint _2610 = _2607 + _2587;
        uint _2611 = _2608 + _2588;
        bool _2612 = ((int)_2609 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.x));
        bool _2613 = ((int)_2610 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.y));
        bool _2614 = ((int)_2611 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.z));
        bool _2615 = _2612 || _2613;
        bool _2616 = _2614 || _2615;
        if (!_2616) {
          uint _2618 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.x));
          uint _2619 = _2618 + _2609;
          uint _2620 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.y));
          uint _2621 = _2620 + _2610;
          uint _2622 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.z));
          uint _2623 = _2622 + _2611;
          int _2624 = (int)(_2619) % (int)(gridDesc_000[1].PROBE_GRID_DESC_032.x);
          int _2625 = (int)(_2621) % (int)(gridDesc_000[1].PROBE_GRID_DESC_032.y);
          int _2626 = (int)(_2623) % (int)(gridDesc_000[1].PROBE_GRID_DESC_032.z);
          int _2627 = _2624 * (gridDesc_000[1].PROBE_GRID_DESC_032.z);
          int _2628 = _2626 + _2627;
          float4 _2631 = t34[1].Load(int3(_2628, _2625, 0));
          uint _2634 = t32[1].Load(int3(_2628, _2625, 0));
          int _2636 = _2634.x & -2;
          bool _2637 = (_2636 == 2);
          if (_2637) {
            float _2640 = _2631.z * 0.44999998807907104f;
            float _2642 = _2631.y * 0.44999998807907104f;
            float _2644 = _2631.x * 0.44999998807907104f;
            float _2645 = float((int)(_2606));
            float _2646 = float((int)(_2607));
            float _2647 = float((int)(_2608));
            float _2648 = _2589 - (gridDesc_000[1].PROBE_GRID_DESC_160.x);
            float _2649 = _2648 + _2645;
            float _2650 = _2649 + _2644;
            float _2651 = _2650 * (gridDesc_000[1].PROBE_GRID_DESC_016.x);
            float _2652 = (gridDesc_000[1].PROBE_GRID_DESC_000.x) - _2568;
            float _2653 = _2651 + _2652;
            float _2654 = _2590 - (gridDesc_000[1].PROBE_GRID_DESC_160.y);
            float _2655 = _2654 + _2646;
            float _2656 = _2655 + _2642;
            float _2657 = _2656 * (gridDesc_000[1].PROBE_GRID_DESC_016.y);
            float _2658 = (gridDesc_000[1].PROBE_GRID_DESC_000.y) - _2569;
            float _2659 = _2657 + _2658;
            float _2660 = _2591 - (gridDesc_000[1].PROBE_GRID_DESC_160.z);
            float _2661 = _2660 + _2647;
            float _2662 = _2661 + _2640;
            float _2663 = _2662 * (gridDesc_000[1].PROBE_GRID_DESC_016.z);
            float _2664 = (gridDesc_000[1].PROBE_GRID_DESC_000.z) - _2570;
            float _2665 = _2663 + _2664;
            float _2666 = _2653 * _2653;
            float _2667 = _2659 * _2659;
            float _2668 = _2666 + _2667;
            float _2669 = _2665 * _2665;
            float _2670 = _2668 + _2669;
            float _2671 = sqrt(_2670);
            float _2672 = max(_2671, 9.999999747378752e-06f);
            float _2673 = _2653 / _2672;
            float _2674 = _2659 / _2672;
            float _2675 = _2665 / _2672;
            float _2676 = -0.0f - _2673;
            float _2677 = -0.0f - _2674;
            float _2678 = -0.0f - _2675;
            float _2679 = abs(_2676);
            float _2680 = abs(_2677);
            float _2681 = _2680 + _2679;
            float _2682 = abs(_2678);
            float _2683 = _2681 + _2682;
            float _2684 = _2676 / _2683;
            float _2685 = _2677 / _2683;
            float _2686 = _2678 / _2683;
            bool _2687 = (_2686 > 0.0f);
            if (!_2687) {
              float _2689 = abs(_2685);
              float _2690 = abs(_2684);
              float _2691 = 1.0f - _2689;
              float _2692 = 1.0f - _2690;
              bool _2693 = (_2684 > 0.0f);
              bool _2694 = (_2685 > 0.0f);
              bool _2695 = (_2684 < 0.0f);
              bool _2696 = (_2685 < 0.0f);
              int _2697 = (int)(uint)(_2693);
              int _2698 = (int)(uint)(_2694);
              int _2699 = (int)(uint)(_2695);
              int _2700 = (int)(uint)(_2696);
              int _2701 = _2697 - _2699;
              int _2702 = _2698 - _2700;
              float _2703 = float((int)(_2701));
              float _2704 = float((int)(_2702));
              float _2705 = _2691 * _2703;
              float _2706 = _2692 * _2704;
              _2708 = _2705;
              _2709 = _2706;
            } else {
              _2708 = _2684;
              _2709 = _2685;
            }
            float _2710 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_092));
            float _2711 = _2710 * 0.5f;
            float _2712 = _2710 + 2.0f;
            float _2713 = _2711 / _2712;
            float _2714 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.x));
            float _2715 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.y));
            float _2716 = 1.0f / _2714;
            float _2717 = 1.0f / _2715;
            float _2718 = float((int)(_2624));
            float _2719 = float((int)(_2625));
            float _2720 = _2718 + 0.5f;
            float _2721 = _2719 + 0.5f;
            float _2722 = _2713 * _2708;
            float _2723 = _2713 * _2709;
            float _2724 = _2722 + _2720;
            float _2725 = _2723 + _2721;
            float _2726 = _2724 * _2716;
            float _2727 = _2725 * _2717;
            float _2728 = float((int)(_2626));
            float3 _2732 = t30[1].SampleLevel(s7, float3(_2726, _2727, _2728), 0.0f);
            float _2735 = abs(_1904);
            float _2736 = abs(_1905);
            float _2737 = _2736 + _2735;
            float _2738 = abs(_1906);
            float _2739 = _2737 + _2738;
            float _2740 = _1904 / _2739;
            float _2741 = _1905 / _2739;
            float _2742 = _1906 / _2739;
            bool _2743 = (_2742 > 0.0f);
            if (!_2743) {
              float _2745 = abs(_2741);
              float _2746 = abs(_2740);
              float _2747 = 1.0f - _2745;
              float _2748 = 1.0f - _2746;
              bool _2749 = (_2740 > 0.0f);
              bool _2750 = (_2741 > 0.0f);
              bool _2751 = (_2740 < 0.0f);
              bool _2752 = (_2741 < 0.0f);
              int _2753 = (int)(uint)(_2749);
              int _2754 = (int)(uint)(_2750);
              int _2755 = (int)(uint)(_2751);
              int _2756 = (int)(uint)(_2752);
              int _2757 = _2753 - _2755;
              int _2758 = _2754 - _2756;
              float _2759 = float((int)(_2757));
              float _2760 = float((int)(_2758));
              float _2761 = _2747 * _2759;
              float _2762 = _2748 * _2760;
              _2764 = _2761;
              _2765 = _2762;
            } else {
              _2764 = _2740;
              _2765 = _2741;
            }
            float _2766 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_088));
            float _2767 = _2766 * 0.5f;
            float _2768 = _2766 + 2.0f;
            float _2769 = _2767 / _2768;
            float _2770 = _2769 * _2764;
            float _2771 = _2769 * _2765;
            float _2772 = _2770 + _2720;
            float _2773 = _2771 + _2721;
            float _2774 = _2772 * _2716;
            float _2775 = _2773 * _2717;
            float4 _2779 = t28[1].SampleLevel(s7, float3(_2774, _2775, _2728), 0.0f);
            float _2783 = (gridDesc_000[1].PROBE_GRID_DESC_104) * 0.5f;
            float _2784 = log2(_2779.x);
            float _2785 = log2(_2779.y);
            float _2786 = log2(_2779.z);
            float _2787 = _2784 * _2783;
            float _2788 = _2785 * _2783;
            float _2789 = _2786 * _2783;
            float _2790 = exp2(_2787);
            float _2791 = exp2(_2788);
            float _2792 = exp2(_2789);
            float _2793 = 1.0f - _2592;
            float _2794 = 1.0f - _2593;
            float _2795 = 1.0f - _2594;
            bool _2796 = (_2606 != 0);
            bool _2797 = (_2607 != 0);
            bool _2798 = (_2608 != 0);
            float _2799 = select(_2796, _2592, _2793);
            float _2800 = select(_2797, _2593, _2794);
            float _2801 = select(_2798, _2594, _2795);
            float _2802 = _2800 * _2799;
            float _2803 = _2802 * _2801;
            float _2804 = _2803 + _2602;
            bool _2805 = (_2671 > _2732.x);
            if (_2805) {
              float _2807 = _2732.x * _2732.x;
              float _2808 = _2732.y - _2807;
              float _2809 = abs(_2808);
              float _2810 = _2671 - _2732.x;
              float _2811 = _2810 * _2810;
              float _2812 = _2809 + _2811;
              float _2813 = _2809 / _2812;
              float _2814 = _2813 * _2803;
              _2816 = _2814;
            } else {
              _2816 = _2803;
            }
            float _2817 = dot(float3(_2673, _2674, _2675), float3(_406, _407, _408));
            float _2818 = _2817 * 0.5f;
            float _2819 = _2818 + 0.5f;
            float _2820 = saturate(_2819);
            float _2821 = _2820 * _2816;
            float _2822 = _2821 * _2790;
            float _2823 = _2821 * _2791;
            float _2824 = _2821 * _2792;
            float _2825 = _2822 + _2598;
            float _2826 = _2823 + _2599;
            float _2827 = _2824 + _2600;
            float _2828 = _2821 + _2601;
            _2830 = _2825;
            _2831 = _2826;
            _2832 = _2827;
            _2833 = _2828;
            _2834 = _2804;
          } else {
            _2830 = _2598;
            _2831 = _2599;
            _2832 = _2600;
            _2833 = _2601;
            _2834 = _2602;
          }
        } else {
          _2830 = _2598;
          _2831 = _2599;
          _2832 = _2600;
          _2833 = _2601;
          _2834 = _2602;
        }
        int _2835 = _2603 + 1;
        bool _2836 = (_2835 == 8);
        if (!_2836) {
          _2598 = _2830;
          _2599 = _2831;
          _2600 = _2832;
          _2601 = _2833;
          _2602 = _2834;
          _2603 = _2835;
          continue;
        }
        break;
      }
      while(true) {
        bool _2596 = (_2833 > 9.999999747378752e-06f);
        if (_2596) {
          float _2838 = _2830 / _2833;
          float _2839 = _2831 / _2833;
          float _2840 = _2832 / _2833;
          float _2841 = _2838 * _2838;
          float _2842 = _2841 * 3.1415927410125732f;
          float _2843 = _2839 * _2839;
          float _2844 = _2843 * 3.1415927410125732f;
          float _2845 = _2840 * _2840;
          float _2846 = _2845 * 3.1415927410125732f;
          _2860 = _2842;
          _2861 = _2844;
          _2862 = _2846;
          _2863 = _2833;
        } else {
          bool _2848 = (_2834 > 9.999999747378752e-06f);
          if (_2848) {
            float _2850 = _2830 / _2834;
            float _2851 = _2831 / _2834;
            float _2852 = _2832 / _2834;
            float _2853 = _2850 * _2850;
            float _2854 = _2853 * 3.1415927410125732f;
            float _2855 = _2851 * _2851;
            float _2856 = _2855 * 3.1415927410125732f;
            float _2857 = _2852 * _2852;
            float _2858 = _2857 * 3.1415927410125732f;
            _2860 = _2854;
            _2861 = _2856;
            _2862 = _2858;
            _2863 = _2834;
          } else {
            _2860 = 0.0f;
            _2861 = 0.0f;
            _2862 = 0.0f;
            _2863 = 0.0f;
          }
        }
        bool _2864 = (_2863 < 9.999999747378752e-06f);
        if (!_2864) {
          _2866 = _2860;
          _2867 = _2861;
          _2868 = _2862;
          if (_2524) {
            _2870 = _2866;
            _2871 = _2867;
            _2872 = _2868;
            _2873 = _2525;
            _2874 = _2521;
            _2875 = _2485;
            float _2912 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _406;
            float _2913 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _407;
            float _2914 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _408;
            float _2915 = _2912 + _75;
            float _2916 = _2913 + _76;
            float _2917 = _2914 + _77;
            float _2918 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _468;
            float _2919 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _469;
            float _2920 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _470;
            float _2921 = _2915 + _2918;
            float _2922 = _2916 + _2919;
            float _2923 = _2917 + _2920;
            float _2924 = _2921 * (gridDesc_000[0].PROBE_GRID_DESC_176.x);
            float _2925 = _2922 * (gridDesc_000[0].PROBE_GRID_DESC_176.y);
            float _2926 = _2923 * (gridDesc_000[0].PROBE_GRID_DESC_176.z);
            float _2927 = _2924 + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
            float _2928 = _2925 + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
            float _2929 = _2926 + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
            int _2930 = int(_2927);
            int _2931 = int(_2928);
            int _2932 = int(_2929);
            uint _2933 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u;
            uint _2934 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u;
            uint _2935 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u;
            int _2936 = max(_2930, 0);
            int _2937 = max(_2931, 0);
            int _2938 = max(_2932, 0);
            int _2939 = min(_2936, _2933);
            int _2940 = min(_2937, _2934);
            int _2941 = min(_2938, _2935);
            float _2942 = float((int)(_2939));
            float _2943 = float((int)(_2940));
            float _2944 = float((int)(_2941));
            float _2945 = _2927 - _2942;
            float _2946 = _2928 - _2943;
            float _2947 = _2929 - _2944;
            _2951 = 0.0f;
            _2952 = 0.0f;
            _2953 = 0.0f;
            _2954 = 0.0f;
            _2955 = 0.0f;
            _2956 = 0;
            while(true) {
              int _2957 = (uint)(_2956) >> 1;
              int _2958 = (uint)(_2956) >> 2;
              int _2959 = _2956 & 1;
              int _2960 = _2957 & 1;
              int _2961 = _2958 & 1;
              uint _2962 = _2959 + _2939;
              uint _2963 = _2960 + _2940;
              uint _2964 = _2961 + _2941;
              bool _2965 = ((int)_2962 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x));
              bool _2966 = ((int)_2963 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y));
              bool _2967 = ((int)_2964 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z));
              bool _2968 = _2965 || _2966;
              bool _2969 = _2967 || _2968;
              if (!_2969) {
                uint _2971 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x));
                uint _2972 = _2971 + _2962;
                uint _2973 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y));
                uint _2974 = _2973 + _2963;
                uint _2975 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z));
                uint _2976 = _2975 + _2964;
                int _2977 = (int)(_2972) % (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x);
                int _2978 = (int)(_2974) % (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y);
                int _2979 = (int)(_2976) % (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z);
                uint _2981 = t38.Load(int4(_2977, _2978, _2979, 0));
                int _2983 = _2981.x & 511;
                int _2984 = (uint)((uint)(_2981.x)) >> 9;
                float4 _2987 = t34[0].Load(int3(_2983, _2984, 0));
                uint _2989 = t38.Load(int4(_2977, _2978, _2979, 0));
                int _2991 = _2989.x & 127;
                int _2992 = (uint)((uint)(_2989.x)) >> 7;
                int _2993 = _2992 & 127;
                int _2994 = (uint)((uint)(_2989.x)) >> 14;
                int _2995 = _2992 | _2989.x;
                int _2996 = _2995 & 127;
                int _2997 = _2996 | _2994;
                bool _2998 = (_2997 == 0);
                if (!_2998) {
                  float _3001 = _2987.z * 0.44999998807907104f;
                  float _3003 = _2987.y * 0.44999998807907104f;
                  float _3005 = _2987.x * 0.44999998807907104f;
                  float _3006 = float((int)(_2959));
                  float _3007 = float((int)(_2960));
                  float _3008 = float((int)(_2961));
                  float _3009 = _2942 - (gridDesc_000[0].PROBE_GRID_DESC_160.x);
                  float _3010 = _3009 + _3006;
                  float _3011 = _3010 + _3005;
                  float _3012 = _3011 * (gridDesc_000[0].PROBE_GRID_DESC_016.x);
                  float _3013 = (gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2921;
                  float _3014 = _3012 + _3013;
                  float _3015 = _2943 - (gridDesc_000[0].PROBE_GRID_DESC_160.y);
                  float _3016 = _3015 + _3007;
                  float _3017 = _3016 + _3003;
                  float _3018 = _3017 * (gridDesc_000[0].PROBE_GRID_DESC_016.y);
                  float _3019 = (gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2922;
                  float _3020 = _3018 + _3019;
                  float _3021 = _2944 - (gridDesc_000[0].PROBE_GRID_DESC_160.z);
                  float _3022 = _3021 + _3008;
                  float _3023 = _3022 + _3001;
                  float _3024 = _3023 * (gridDesc_000[0].PROBE_GRID_DESC_016.z);
                  float _3025 = (gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2923;
                  float _3026 = _3024 + _3025;
                  float _3027 = _3014 * _3014;
                  float _3028 = _3020 * _3020;
                  float _3029 = _3027 + _3028;
                  float _3030 = _3026 * _3026;
                  float _3031 = _3029 + _3030;
                  float _3032 = sqrt(_3031);
                  float _3033 = max(_3032, 9.999999747378752e-06f);
                  float _3034 = _3014 / _3033;
                  float _3035 = _3020 / _3033;
                  float _3036 = _3026 / _3033;
                  float _3037 = -0.0f - _3034;
                  float _3038 = -0.0f - _3035;
                  float _3039 = -0.0f - _3036;
                  float _3040 = abs(_3037);
                  float _3041 = abs(_3038);
                  float _3042 = _3041 + _3040;
                  float _3043 = abs(_3039);
                  float _3044 = _3042 + _3043;
                  float _3045 = _3037 / _3044;
                  float _3046 = _3038 / _3044;
                  float _3047 = _3039 / _3044;
                  bool _3048 = (_3047 > 0.0f);
                  if (!_3048) {
                    float _3050 = abs(_3046);
                    float _3051 = abs(_3045);
                    float _3052 = 1.0f - _3050;
                    float _3053 = 1.0f - _3051;
                    bool _3054 = (_3045 > 0.0f);
                    bool _3055 = (_3046 > 0.0f);
                    bool _3056 = (_3045 < 0.0f);
                    bool _3057 = (_3046 < 0.0f);
                    int _3058 = (int)(uint)(_3054);
                    int _3059 = (int)(uint)(_3055);
                    int _3060 = (int)(uint)(_3056);
                    int _3061 = (int)(uint)(_3057);
                    int _3062 = _3058 - _3060;
                    int _3063 = _3059 - _3061;
                    float _3064 = float((int)(_3062));
                    float _3065 = float((int)(_3063));
                    float _3066 = _3052 * _3064;
                    float _3067 = _3053 * _3065;
                    _3069 = _3066;
                    _3070 = _3067;
                  } else {
                    _3069 = _3045;
                    _3070 = _3046;
                  }
                  float _3071 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                  float _3072 = _3071 * 0.5f;
                  float _3073 = _3071 + 2.0f;
                  float _3074 = _3072 / _3073;
                  float _3075 = float((int)(_2991));
                  float _3076 = float((int)(_2993));
                  float _3077 = _3075 + 0.5f;
                  float _3078 = _3076 + 0.5f;
                  float _3079 = _3074 * _3069;
                  float _3080 = _3074 * _3070;
                  float _3081 = _3079 + _3077;
                  float _3082 = _3080 + _3078;
                  float _3083 = _3081 * 0.0078125f;
                  float _3084 = _3082 * 0.0078125f;
                  float _3085 = float((int)(_2994));
                  float3 _3089 = t30[0].SampleLevel(s7, float3(_3083, _3084, _3085), 0.0f);
                  float _3092 = abs(_1904);
                  float _3093 = abs(_1905);
                  float _3094 = _3093 + _3092;
                  float _3095 = abs(_1906);
                  float _3096 = _3094 + _3095;
                  float _3097 = _1904 / _3096;
                  float _3098 = _1905 / _3096;
                  float _3099 = _1906 / _3096;
                  bool _3100 = (_3099 > 0.0f);
                  if (!_3100) {
                    float _3102 = abs(_3098);
                    float _3103 = abs(_3097);
                    float _3104 = 1.0f - _3102;
                    float _3105 = 1.0f - _3103;
                    bool _3106 = (_3097 > 0.0f);
                    bool _3107 = (_3098 > 0.0f);
                    bool _3108 = (_3097 < 0.0f);
                    bool _3109 = (_3098 < 0.0f);
                    int _3110 = (int)(uint)(_3106);
                    int _3111 = (int)(uint)(_3107);
                    int _3112 = (int)(uint)(_3108);
                    int _3113 = (int)(uint)(_3109);
                    int _3114 = _3110 - _3112;
                    int _3115 = _3111 - _3113;
                    float _3116 = float((int)(_3114));
                    float _3117 = float((int)(_3115));
                    float _3118 = _3104 * _3116;
                    float _3119 = _3105 * _3117;
                    _3121 = _3118;
                    _3122 = _3119;
                  } else {
                    _3121 = _3097;
                    _3122 = _3098;
                  }
                  float _3123 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                  float _3124 = _3123 * 0.5f;
                  float _3125 = _3123 + 2.0f;
                  float _3126 = _3124 / _3125;
                  float _3127 = _3126 * _3121;
                  float _3128 = _3126 * _3122;
                  float _3129 = _3127 + _3077;
                  float _3130 = _3128 + _3078;
                  float _3131 = _3129 * 0.0078125f;
                  float _3132 = _3130 * 0.0078125f;
                  float4 _3136 = t28[0].SampleLevel(s7, float3(_3131, _3132, _3085), 0.0f);
                  float _3140 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                  float _3141 = log2(_3136.x);
                  float _3142 = log2(_3136.y);
                  float _3143 = log2(_3136.z);
                  float _3144 = _3141 * _3140;
                  float _3145 = _3142 * _3140;
                  float _3146 = _3143 * _3140;
                  float _3147 = exp2(_3144);
                  float _3148 = exp2(_3145);
                  float _3149 = exp2(_3146);
                  float _3150 = 1.0f - _2945;
                  float _3151 = 1.0f - _2946;
                  float _3152 = 1.0f - _2947;
                  bool _3153 = (_2959 != 0);
                  bool _3154 = (_2960 != 0);
                  bool _3155 = (_2961 != 0);
                  float _3156 = select(_3153, _2945, _3150);
                  float _3157 = select(_3154, _2946, _3151);
                  float _3158 = select(_3155, _2947, _3152);
                  float _3159 = _3157 * _3156;
                  float _3160 = _3159 * _3158;
                  float _3161 = _3160 + _2955;
                  bool _3162 = (_3032 > _3089.x);
                  if (_3162) {
                    float _3164 = _3089.x * _3089.x;
                    float _3165 = _3089.y - _3164;
                    float _3166 = abs(_3165);
                    float _3167 = _3032 - _3089.x;
                    float _3168 = _3167 * _3167;
                    float _3169 = _3166 + _3168;
                    float _3170 = _3166 / _3169;
                    float _3171 = _3170 * _3160;
                    _3173 = _3171;
                  } else {
                    _3173 = _3160;
                  }
                  float _3174 = dot(float3(_3034, _3035, _3036), float3(_406, _407, _408));
                  float _3175 = _3174 * 0.5f;
                  float _3176 = _3175 + 0.5f;
                  float _3177 = saturate(_3176);
                  float _3178 = _3177 * _3173;
                  float _3179 = _3178 * _3147;
                  float _3180 = _3178 * _3148;
                  float _3181 = _3178 * _3149;
                  float _3182 = _3179 + _2951;
                  float _3183 = _3180 + _2952;
                  float _3184 = _3181 + _2953;
                  float _3185 = _3178 + _2954;
                  _3187 = _3182;
                  _3188 = _3183;
                  _3189 = _3184;
                  _3190 = _3185;
                  _3191 = _3161;
                } else {
                  _3187 = _2951;
                  _3188 = _2952;
                  _3189 = _2953;
                  _3190 = _2954;
                  _3191 = _2955;
                }
              } else {
                _3187 = _2951;
                _3188 = _2952;
                _3189 = _2953;
                _3190 = _2954;
                _3191 = _2955;
              }
              int _3192 = _2956 + 1;
              bool _3193 = (_3192 == 8);
              if (!_3193) {
                _2951 = _3187;
                _2952 = _3188;
                _2953 = _3189;
                _2954 = _3190;
                _2955 = _3191;
                _2956 = _3192;
                continue;
              }
              break;
            }
            while(true) {
              bool _2949 = (_3190 > 9.999999747378752e-06f);
              if (_2949) {
                float _3195 = _3187 / _3190;
                float _3196 = _3188 / _3190;
                float _3197 = _3189 / _3190;
                float _3198 = _3195 * _3195;
                float _3199 = _3198 * 3.1415927410125732f;
                float _3200 = _3196 * _3196;
                float _3201 = _3200 * 3.1415927410125732f;
                float _3202 = _3197 * _3197;
                float _3203 = _3202 * 3.1415927410125732f;
                _3217 = _3199;
                _3218 = _3201;
                _3219 = _3203;
                _3220 = _3190;
              } else {
                bool _3205 = (_3191 > 9.999999747378752e-06f);
                if (_3205) {
                  float _3207 = _3187 / _3191;
                  float _3208 = _3188 / _3191;
                  float _3209 = _3189 / _3191;
                  float _3210 = _3207 * _3207;
                  float _3211 = _3210 * 3.1415927410125732f;
                  float _3212 = _3208 * _3208;
                  float _3213 = _3212 * 3.1415927410125732f;
                  float _3214 = _3209 * _3209;
                  float _3215 = _3214 * 3.1415927410125732f;
                  _3217 = _3211;
                  _3218 = _3213;
                  _3219 = _3215;
                  _3220 = _3191;
                } else {
                  _3217 = 0.0f;
                  _3218 = 0.0f;
                  _3219 = 0.0f;
                  _3220 = 0.0f;
                }
              }
              bool _3221 = (_3220 < 9.999999747378752e-06f);
              if (_3221) {
                _3224 = _2870;
                _3225 = _2871;
                _3226 = _2872;
                _3227 = _2874;
                _3228 = _2875;
                _3229 = 0.0f;
                _3230 = 0;
                _3231 = _3217;
                _3232 = _3218;
                _3233 = _3219;
              } else {
                _3224 = _2870;
                _3225 = _2871;
                _3226 = _2872;
                _3227 = _2874;
                _3228 = _2875;
                _3229 = _2519;
                _3230 = _2873;
                _3231 = _3217;
                _3232 = _3218;
                _3233 = _3219;
              }
              break;
            }
          } else {
            _3224 = _2866;
            _3225 = _2867;
            _3226 = _2868;
            _3227 = _2521;
            _3228 = _2485;
            _3229 = _2519;
            _3230 = _2525;
            _3231 = 0.0f;
            _3232 = 0.0f;
            _3233 = 0.0f;
          }
        } else {
          _2870 = _2860;
          _2871 = _2861;
          _2872 = _2862;
          _2873 = 1;
          _2874 = 0;
          _2875 = 0.0f;
          float _2912 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _406;
          float _2913 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _407;
          float _2914 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _408;
          float _2915 = _2912 + _75;
          float _2916 = _2913 + _76;
          float _2917 = _2914 + _77;
          float _2918 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _468;
          float _2919 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _469;
          float _2920 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _470;
          float _2921 = _2915 + _2918;
          float _2922 = _2916 + _2919;
          float _2923 = _2917 + _2920;
          float _2924 = _2921 * (gridDesc_000[0].PROBE_GRID_DESC_176.x);
          float _2925 = _2922 * (gridDesc_000[0].PROBE_GRID_DESC_176.y);
          float _2926 = _2923 * (gridDesc_000[0].PROBE_GRID_DESC_176.z);
          float _2927 = _2924 + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
          float _2928 = _2925 + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
          float _2929 = _2926 + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
          int _2930 = int(_2927);
          int _2931 = int(_2928);
          int _2932 = int(_2929);
          uint _2933 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u;
          uint _2934 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u;
          uint _2935 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u;
          int _2936 = max(_2930, 0);
          int _2937 = max(_2931, 0);
          int _2938 = max(_2932, 0);
          int _2939 = min(_2936, _2933);
          int _2940 = min(_2937, _2934);
          int _2941 = min(_2938, _2935);
          float _2942 = float((int)(_2939));
          float _2943 = float((int)(_2940));
          float _2944 = float((int)(_2941));
          float _2945 = _2927 - _2942;
          float _2946 = _2928 - _2943;
          float _2947 = _2929 - _2944;
          _2951 = 0.0f;
          _2952 = 0.0f;
          _2953 = 0.0f;
          _2954 = 0.0f;
          _2955 = 0.0f;
          _2956 = 0;
          while(true) {
            int _2957 = (uint)(_2956) >> 1;
            int _2958 = (uint)(_2956) >> 2;
            int _2959 = _2956 & 1;
            int _2960 = _2957 & 1;
            int _2961 = _2958 & 1;
            uint _2962 = _2959 + _2939;
            uint _2963 = _2960 + _2940;
            uint _2964 = _2961 + _2941;
            bool _2965 = ((int)_2962 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x));
            bool _2966 = ((int)_2963 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y));
            bool _2967 = ((int)_2964 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z));
            bool _2968 = _2965 || _2966;
            bool _2969 = _2967 || _2968;
            if (!_2969) {
              uint _2971 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x));
              uint _2972 = _2971 + _2962;
              uint _2973 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y));
              uint _2974 = _2973 + _2963;
              uint _2975 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z));
              uint _2976 = _2975 + _2964;
              int _2977 = (int)(_2972) % (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x);
              int _2978 = (int)(_2974) % (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y);
              int _2979 = (int)(_2976) % (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z);
              uint _2981 = t38.Load(int4(_2977, _2978, _2979, 0));
              int _2983 = _2981.x & 511;
              int _2984 = (uint)((uint)(_2981.x)) >> 9;
              float4 _2987 = t34[0].Load(int3(_2983, _2984, 0));
              uint _2989 = t38.Load(int4(_2977, _2978, _2979, 0));
              int _2991 = _2989.x & 127;
              int _2992 = (uint)((uint)(_2989.x)) >> 7;
              int _2993 = _2992 & 127;
              int _2994 = (uint)((uint)(_2989.x)) >> 14;
              int _2995 = _2992 | _2989.x;
              int _2996 = _2995 & 127;
              int _2997 = _2996 | _2994;
              bool _2998 = (_2997 == 0);
              if (!_2998) {
                float _3001 = _2987.z * 0.44999998807907104f;
                float _3003 = _2987.y * 0.44999998807907104f;
                float _3005 = _2987.x * 0.44999998807907104f;
                float _3006 = float((int)(_2959));
                float _3007 = float((int)(_2960));
                float _3008 = float((int)(_2961));
                float _3009 = _2942 - (gridDesc_000[0].PROBE_GRID_DESC_160.x);
                float _3010 = _3009 + _3006;
                float _3011 = _3010 + _3005;
                float _3012 = _3011 * (gridDesc_000[0].PROBE_GRID_DESC_016.x);
                float _3013 = (gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2921;
                float _3014 = _3012 + _3013;
                float _3015 = _2943 - (gridDesc_000[0].PROBE_GRID_DESC_160.y);
                float _3016 = _3015 + _3007;
                float _3017 = _3016 + _3003;
                float _3018 = _3017 * (gridDesc_000[0].PROBE_GRID_DESC_016.y);
                float _3019 = (gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2922;
                float _3020 = _3018 + _3019;
                float _3021 = _2944 - (gridDesc_000[0].PROBE_GRID_DESC_160.z);
                float _3022 = _3021 + _3008;
                float _3023 = _3022 + _3001;
                float _3024 = _3023 * (gridDesc_000[0].PROBE_GRID_DESC_016.z);
                float _3025 = (gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2923;
                float _3026 = _3024 + _3025;
                float _3027 = _3014 * _3014;
                float _3028 = _3020 * _3020;
                float _3029 = _3027 + _3028;
                float _3030 = _3026 * _3026;
                float _3031 = _3029 + _3030;
                float _3032 = sqrt(_3031);
                float _3033 = max(_3032, 9.999999747378752e-06f);
                float _3034 = _3014 / _3033;
                float _3035 = _3020 / _3033;
                float _3036 = _3026 / _3033;
                float _3037 = -0.0f - _3034;
                float _3038 = -0.0f - _3035;
                float _3039 = -0.0f - _3036;
                float _3040 = abs(_3037);
                float _3041 = abs(_3038);
                float _3042 = _3041 + _3040;
                float _3043 = abs(_3039);
                float _3044 = _3042 + _3043;
                float _3045 = _3037 / _3044;
                float _3046 = _3038 / _3044;
                float _3047 = _3039 / _3044;
                bool _3048 = (_3047 > 0.0f);
                if (!_3048) {
                  float _3050 = abs(_3046);
                  float _3051 = abs(_3045);
                  float _3052 = 1.0f - _3050;
                  float _3053 = 1.0f - _3051;
                  bool _3054 = (_3045 > 0.0f);
                  bool _3055 = (_3046 > 0.0f);
                  bool _3056 = (_3045 < 0.0f);
                  bool _3057 = (_3046 < 0.0f);
                  int _3058 = (int)(uint)(_3054);
                  int _3059 = (int)(uint)(_3055);
                  int _3060 = (int)(uint)(_3056);
                  int _3061 = (int)(uint)(_3057);
                  int _3062 = _3058 - _3060;
                  int _3063 = _3059 - _3061;
                  float _3064 = float((int)(_3062));
                  float _3065 = float((int)(_3063));
                  float _3066 = _3052 * _3064;
                  float _3067 = _3053 * _3065;
                  _3069 = _3066;
                  _3070 = _3067;
                } else {
                  _3069 = _3045;
                  _3070 = _3046;
                }
                float _3071 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                float _3072 = _3071 * 0.5f;
                float _3073 = _3071 + 2.0f;
                float _3074 = _3072 / _3073;
                float _3075 = float((int)(_2991));
                float _3076 = float((int)(_2993));
                float _3077 = _3075 + 0.5f;
                float _3078 = _3076 + 0.5f;
                float _3079 = _3074 * _3069;
                float _3080 = _3074 * _3070;
                float _3081 = _3079 + _3077;
                float _3082 = _3080 + _3078;
                float _3083 = _3081 * 0.0078125f;
                float _3084 = _3082 * 0.0078125f;
                float _3085 = float((int)(_2994));
                float3 _3089 = t30[0].SampleLevel(s7, float3(_3083, _3084, _3085), 0.0f);
                float _3092 = abs(_1904);
                float _3093 = abs(_1905);
                float _3094 = _3093 + _3092;
                float _3095 = abs(_1906);
                float _3096 = _3094 + _3095;
                float _3097 = _1904 / _3096;
                float _3098 = _1905 / _3096;
                float _3099 = _1906 / _3096;
                bool _3100 = (_3099 > 0.0f);
                if (!_3100) {
                  float _3102 = abs(_3098);
                  float _3103 = abs(_3097);
                  float _3104 = 1.0f - _3102;
                  float _3105 = 1.0f - _3103;
                  bool _3106 = (_3097 > 0.0f);
                  bool _3107 = (_3098 > 0.0f);
                  bool _3108 = (_3097 < 0.0f);
                  bool _3109 = (_3098 < 0.0f);
                  int _3110 = (int)(uint)(_3106);
                  int _3111 = (int)(uint)(_3107);
                  int _3112 = (int)(uint)(_3108);
                  int _3113 = (int)(uint)(_3109);
                  int _3114 = _3110 - _3112;
                  int _3115 = _3111 - _3113;
                  float _3116 = float((int)(_3114));
                  float _3117 = float((int)(_3115));
                  float _3118 = _3104 * _3116;
                  float _3119 = _3105 * _3117;
                  _3121 = _3118;
                  _3122 = _3119;
                } else {
                  _3121 = _3097;
                  _3122 = _3098;
                }
                float _3123 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                float _3124 = _3123 * 0.5f;
                float _3125 = _3123 + 2.0f;
                float _3126 = _3124 / _3125;
                float _3127 = _3126 * _3121;
                float _3128 = _3126 * _3122;
                float _3129 = _3127 + _3077;
                float _3130 = _3128 + _3078;
                float _3131 = _3129 * 0.0078125f;
                float _3132 = _3130 * 0.0078125f;
                float4 _3136 = t28[0].SampleLevel(s7, float3(_3131, _3132, _3085), 0.0f);
                float _3140 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                float _3141 = log2(_3136.x);
                float _3142 = log2(_3136.y);
                float _3143 = log2(_3136.z);
                float _3144 = _3141 * _3140;
                float _3145 = _3142 * _3140;
                float _3146 = _3143 * _3140;
                float _3147 = exp2(_3144);
                float _3148 = exp2(_3145);
                float _3149 = exp2(_3146);
                float _3150 = 1.0f - _2945;
                float _3151 = 1.0f - _2946;
                float _3152 = 1.0f - _2947;
                bool _3153 = (_2959 != 0);
                bool _3154 = (_2960 != 0);
                bool _3155 = (_2961 != 0);
                float _3156 = select(_3153, _2945, _3150);
                float _3157 = select(_3154, _2946, _3151);
                float _3158 = select(_3155, _2947, _3152);
                float _3159 = _3157 * _3156;
                float _3160 = _3159 * _3158;
                float _3161 = _3160 + _2955;
                bool _3162 = (_3032 > _3089.x);
                if (_3162) {
                  float _3164 = _3089.x * _3089.x;
                  float _3165 = _3089.y - _3164;
                  float _3166 = abs(_3165);
                  float _3167 = _3032 - _3089.x;
                  float _3168 = _3167 * _3167;
                  float _3169 = _3166 + _3168;
                  float _3170 = _3166 / _3169;
                  float _3171 = _3170 * _3160;
                  _3173 = _3171;
                } else {
                  _3173 = _3160;
                }
                float _3174 = dot(float3(_3034, _3035, _3036), float3(_406, _407, _408));
                float _3175 = _3174 * 0.5f;
                float _3176 = _3175 + 0.5f;
                float _3177 = saturate(_3176);
                float _3178 = _3177 * _3173;
                float _3179 = _3178 * _3147;
                float _3180 = _3178 * _3148;
                float _3181 = _3178 * _3149;
                float _3182 = _3179 + _2951;
                float _3183 = _3180 + _2952;
                float _3184 = _3181 + _2953;
                float _3185 = _3178 + _2954;
                _3187 = _3182;
                _3188 = _3183;
                _3189 = _3184;
                _3190 = _3185;
                _3191 = _3161;
              } else {
                _3187 = _2951;
                _3188 = _2952;
                _3189 = _2953;
                _3190 = _2954;
                _3191 = _2955;
              }
            } else {
              _3187 = _2951;
              _3188 = _2952;
              _3189 = _2953;
              _3190 = _2954;
              _3191 = _2955;
            }
            int _3192 = _2956 + 1;
            bool _3193 = (_3192 == 8);
            if (!_3193) {
              _2951 = _3187;
              _2952 = _3188;
              _2953 = _3189;
              _2954 = _3190;
              _2955 = _3191;
              _2956 = _3192;
              continue;
            }
            break;
          }
          while(true) {
            bool _2949 = (_3190 > 9.999999747378752e-06f);
            if (_2949) {
              float _3195 = _3187 / _3190;
              float _3196 = _3188 / _3190;
              float _3197 = _3189 / _3190;
              float _3198 = _3195 * _3195;
              float _3199 = _3198 * 3.1415927410125732f;
              float _3200 = _3196 * _3196;
              float _3201 = _3200 * 3.1415927410125732f;
              float _3202 = _3197 * _3197;
              float _3203 = _3202 * 3.1415927410125732f;
              _3217 = _3199;
              _3218 = _3201;
              _3219 = _3203;
              _3220 = _3190;
            } else {
              bool _3205 = (_3191 > 9.999999747378752e-06f);
              if (_3205) {
                float _3207 = _3187 / _3191;
                float _3208 = _3188 / _3191;
                float _3209 = _3189 / _3191;
                float _3210 = _3207 * _3207;
                float _3211 = _3210 * 3.1415927410125732f;
                float _3212 = _3208 * _3208;
                float _3213 = _3212 * 3.1415927410125732f;
                float _3214 = _3209 * _3209;
                float _3215 = _3214 * 3.1415927410125732f;
                _3217 = _3211;
                _3218 = _3213;
                _3219 = _3215;
                _3220 = _3191;
              } else {
                _3217 = 0.0f;
                _3218 = 0.0f;
                _3219 = 0.0f;
                _3220 = 0.0f;
              }
            }
            bool _3221 = (_3220 < 9.999999747378752e-06f);
            if (_3221) {
              _3224 = _2870;
              _3225 = _2871;
              _3226 = _2872;
              _3227 = _2874;
              _3228 = _2875;
              _3229 = 0.0f;
              _3230 = 0;
              _3231 = _3217;
              _3232 = _3218;
              _3233 = _3219;
            } else {
              _3224 = _2870;
              _3225 = _2871;
              _3226 = _2872;
              _3227 = _2874;
              _3228 = _2875;
              _3229 = _2519;
              _3230 = _2873;
              _3231 = _3217;
              _3232 = _3218;
              _3233 = _3219;
            }
            break;
          }
        }
        break;
      }
    } else {
      _2866 = 0.0f;
      _2867 = 0.0f;
      _2868 = 0.0f;
      if (_2524) {
        _2870 = _2866;
        _2871 = _2867;
        _2872 = _2868;
        _2873 = _2525;
        _2874 = _2521;
        _2875 = _2485;
        float _2912 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _406;
        float _2913 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _407;
        float _2914 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _408;
        float _2915 = _2912 + _75;
        float _2916 = _2913 + _76;
        float _2917 = _2914 + _77;
        float _2918 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _468;
        float _2919 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _469;
        float _2920 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _470;
        float _2921 = _2915 + _2918;
        float _2922 = _2916 + _2919;
        float _2923 = _2917 + _2920;
        float _2924 = _2921 * (gridDesc_000[0].PROBE_GRID_DESC_176.x);
        float _2925 = _2922 * (gridDesc_000[0].PROBE_GRID_DESC_176.y);
        float _2926 = _2923 * (gridDesc_000[0].PROBE_GRID_DESC_176.z);
        float _2927 = _2924 + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
        float _2928 = _2925 + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
        float _2929 = _2926 + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
        int _2930 = int(_2927);
        int _2931 = int(_2928);
        int _2932 = int(_2929);
        uint _2933 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u;
        uint _2934 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u;
        uint _2935 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u;
        int _2936 = max(_2930, 0);
        int _2937 = max(_2931, 0);
        int _2938 = max(_2932, 0);
        int _2939 = min(_2936, _2933);
        int _2940 = min(_2937, _2934);
        int _2941 = min(_2938, _2935);
        float _2942 = float((int)(_2939));
        float _2943 = float((int)(_2940));
        float _2944 = float((int)(_2941));
        float _2945 = _2927 - _2942;
        float _2946 = _2928 - _2943;
        float _2947 = _2929 - _2944;
        _2951 = 0.0f;
        _2952 = 0.0f;
        _2953 = 0.0f;
        _2954 = 0.0f;
        _2955 = 0.0f;
        _2956 = 0;
        while(true) {
          int _2957 = (uint)(_2956) >> 1;
          int _2958 = (uint)(_2956) >> 2;
          int _2959 = _2956 & 1;
          int _2960 = _2957 & 1;
          int _2961 = _2958 & 1;
          uint _2962 = _2959 + _2939;
          uint _2963 = _2960 + _2940;
          uint _2964 = _2961 + _2941;
          bool _2965 = ((int)_2962 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x));
          bool _2966 = ((int)_2963 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y));
          bool _2967 = ((int)_2964 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z));
          bool _2968 = _2965 || _2966;
          bool _2969 = _2967 || _2968;
          if (!_2969) {
            uint _2971 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x));
            uint _2972 = _2971 + _2962;
            uint _2973 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y));
            uint _2974 = _2973 + _2963;
            uint _2975 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z));
            uint _2976 = _2975 + _2964;
            int _2977 = (int)(_2972) % (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x);
            int _2978 = (int)(_2974) % (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y);
            int _2979 = (int)(_2976) % (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z);
            uint _2981 = t38.Load(int4(_2977, _2978, _2979, 0));
            int _2983 = _2981.x & 511;
            int _2984 = (uint)((uint)(_2981.x)) >> 9;
            float4 _2987 = t34[0].Load(int3(_2983, _2984, 0));
            uint _2989 = t38.Load(int4(_2977, _2978, _2979, 0));
            int _2991 = _2989.x & 127;
            int _2992 = (uint)((uint)(_2989.x)) >> 7;
            int _2993 = _2992 & 127;
            int _2994 = (uint)((uint)(_2989.x)) >> 14;
            int _2995 = _2992 | _2989.x;
            int _2996 = _2995 & 127;
            int _2997 = _2996 | _2994;
            bool _2998 = (_2997 == 0);
            if (!_2998) {
              float _3001 = _2987.z * 0.44999998807907104f;
              float _3003 = _2987.y * 0.44999998807907104f;
              float _3005 = _2987.x * 0.44999998807907104f;
              float _3006 = float((int)(_2959));
              float _3007 = float((int)(_2960));
              float _3008 = float((int)(_2961));
              float _3009 = _2942 - (gridDesc_000[0].PROBE_GRID_DESC_160.x);
              float _3010 = _3009 + _3006;
              float _3011 = _3010 + _3005;
              float _3012 = _3011 * (gridDesc_000[0].PROBE_GRID_DESC_016.x);
              float _3013 = (gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2921;
              float _3014 = _3012 + _3013;
              float _3015 = _2943 - (gridDesc_000[0].PROBE_GRID_DESC_160.y);
              float _3016 = _3015 + _3007;
              float _3017 = _3016 + _3003;
              float _3018 = _3017 * (gridDesc_000[0].PROBE_GRID_DESC_016.y);
              float _3019 = (gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2922;
              float _3020 = _3018 + _3019;
              float _3021 = _2944 - (gridDesc_000[0].PROBE_GRID_DESC_160.z);
              float _3022 = _3021 + _3008;
              float _3023 = _3022 + _3001;
              float _3024 = _3023 * (gridDesc_000[0].PROBE_GRID_DESC_016.z);
              float _3025 = (gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2923;
              float _3026 = _3024 + _3025;
              float _3027 = _3014 * _3014;
              float _3028 = _3020 * _3020;
              float _3029 = _3027 + _3028;
              float _3030 = _3026 * _3026;
              float _3031 = _3029 + _3030;
              float _3032 = sqrt(_3031);
              float _3033 = max(_3032, 9.999999747378752e-06f);
              float _3034 = _3014 / _3033;
              float _3035 = _3020 / _3033;
              float _3036 = _3026 / _3033;
              float _3037 = -0.0f - _3034;
              float _3038 = -0.0f - _3035;
              float _3039 = -0.0f - _3036;
              float _3040 = abs(_3037);
              float _3041 = abs(_3038);
              float _3042 = _3041 + _3040;
              float _3043 = abs(_3039);
              float _3044 = _3042 + _3043;
              float _3045 = _3037 / _3044;
              float _3046 = _3038 / _3044;
              float _3047 = _3039 / _3044;
              bool _3048 = (_3047 > 0.0f);
              if (!_3048) {
                float _3050 = abs(_3046);
                float _3051 = abs(_3045);
                float _3052 = 1.0f - _3050;
                float _3053 = 1.0f - _3051;
                bool _3054 = (_3045 > 0.0f);
                bool _3055 = (_3046 > 0.0f);
                bool _3056 = (_3045 < 0.0f);
                bool _3057 = (_3046 < 0.0f);
                int _3058 = (int)(uint)(_3054);
                int _3059 = (int)(uint)(_3055);
                int _3060 = (int)(uint)(_3056);
                int _3061 = (int)(uint)(_3057);
                int _3062 = _3058 - _3060;
                int _3063 = _3059 - _3061;
                float _3064 = float((int)(_3062));
                float _3065 = float((int)(_3063));
                float _3066 = _3052 * _3064;
                float _3067 = _3053 * _3065;
                _3069 = _3066;
                _3070 = _3067;
              } else {
                _3069 = _3045;
                _3070 = _3046;
              }
              float _3071 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
              float _3072 = _3071 * 0.5f;
              float _3073 = _3071 + 2.0f;
              float _3074 = _3072 / _3073;
              float _3075 = float((int)(_2991));
              float _3076 = float((int)(_2993));
              float _3077 = _3075 + 0.5f;
              float _3078 = _3076 + 0.5f;
              float _3079 = _3074 * _3069;
              float _3080 = _3074 * _3070;
              float _3081 = _3079 + _3077;
              float _3082 = _3080 + _3078;
              float _3083 = _3081 * 0.0078125f;
              float _3084 = _3082 * 0.0078125f;
              float _3085 = float((int)(_2994));
              float3 _3089 = t30[0].SampleLevel(s7, float3(_3083, _3084, _3085), 0.0f);
              float _3092 = abs(_1904);
              float _3093 = abs(_1905);
              float _3094 = _3093 + _3092;
              float _3095 = abs(_1906);
              float _3096 = _3094 + _3095;
              float _3097 = _1904 / _3096;
              float _3098 = _1905 / _3096;
              float _3099 = _1906 / _3096;
              bool _3100 = (_3099 > 0.0f);
              if (!_3100) {
                float _3102 = abs(_3098);
                float _3103 = abs(_3097);
                float _3104 = 1.0f - _3102;
                float _3105 = 1.0f - _3103;
                bool _3106 = (_3097 > 0.0f);
                bool _3107 = (_3098 > 0.0f);
                bool _3108 = (_3097 < 0.0f);
                bool _3109 = (_3098 < 0.0f);
                int _3110 = (int)(uint)(_3106);
                int _3111 = (int)(uint)(_3107);
                int _3112 = (int)(uint)(_3108);
                int _3113 = (int)(uint)(_3109);
                int _3114 = _3110 - _3112;
                int _3115 = _3111 - _3113;
                float _3116 = float((int)(_3114));
                float _3117 = float((int)(_3115));
                float _3118 = _3104 * _3116;
                float _3119 = _3105 * _3117;
                _3121 = _3118;
                _3122 = _3119;
              } else {
                _3121 = _3097;
                _3122 = _3098;
              }
              float _3123 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
              float _3124 = _3123 * 0.5f;
              float _3125 = _3123 + 2.0f;
              float _3126 = _3124 / _3125;
              float _3127 = _3126 * _3121;
              float _3128 = _3126 * _3122;
              float _3129 = _3127 + _3077;
              float _3130 = _3128 + _3078;
              float _3131 = _3129 * 0.0078125f;
              float _3132 = _3130 * 0.0078125f;
              float4 _3136 = t28[0].SampleLevel(s7, float3(_3131, _3132, _3085), 0.0f);
              float _3140 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
              float _3141 = log2(_3136.x);
              float _3142 = log2(_3136.y);
              float _3143 = log2(_3136.z);
              float _3144 = _3141 * _3140;
              float _3145 = _3142 * _3140;
              float _3146 = _3143 * _3140;
              float _3147 = exp2(_3144);
              float _3148 = exp2(_3145);
              float _3149 = exp2(_3146);
              float _3150 = 1.0f - _2945;
              float _3151 = 1.0f - _2946;
              float _3152 = 1.0f - _2947;
              bool _3153 = (_2959 != 0);
              bool _3154 = (_2960 != 0);
              bool _3155 = (_2961 != 0);
              float _3156 = select(_3153, _2945, _3150);
              float _3157 = select(_3154, _2946, _3151);
              float _3158 = select(_3155, _2947, _3152);
              float _3159 = _3157 * _3156;
              float _3160 = _3159 * _3158;
              float _3161 = _3160 + _2955;
              bool _3162 = (_3032 > _3089.x);
              if (_3162) {
                float _3164 = _3089.x * _3089.x;
                float _3165 = _3089.y - _3164;
                float _3166 = abs(_3165);
                float _3167 = _3032 - _3089.x;
                float _3168 = _3167 * _3167;
                float _3169 = _3166 + _3168;
                float _3170 = _3166 / _3169;
                float _3171 = _3170 * _3160;
                _3173 = _3171;
              } else {
                _3173 = _3160;
              }
              float _3174 = dot(float3(_3034, _3035, _3036), float3(_406, _407, _408));
              float _3175 = _3174 * 0.5f;
              float _3176 = _3175 + 0.5f;
              float _3177 = saturate(_3176);
              float _3178 = _3177 * _3173;
              float _3179 = _3178 * _3147;
              float _3180 = _3178 * _3148;
              float _3181 = _3178 * _3149;
              float _3182 = _3179 + _2951;
              float _3183 = _3180 + _2952;
              float _3184 = _3181 + _2953;
              float _3185 = _3178 + _2954;
              _3187 = _3182;
              _3188 = _3183;
              _3189 = _3184;
              _3190 = _3185;
              _3191 = _3161;
            } else {
              _3187 = _2951;
              _3188 = _2952;
              _3189 = _2953;
              _3190 = _2954;
              _3191 = _2955;
            }
          } else {
            _3187 = _2951;
            _3188 = _2952;
            _3189 = _2953;
            _3190 = _2954;
            _3191 = _2955;
          }
          int _3192 = _2956 + 1;
          bool _3193 = (_3192 == 8);
          if (!_3193) {
            _2951 = _3187;
            _2952 = _3188;
            _2953 = _3189;
            _2954 = _3190;
            _2955 = _3191;
            _2956 = _3192;
            continue;
          }
          break;
        }
        while(true) {
          bool _2949 = (_3190 > 9.999999747378752e-06f);
          if (_2949) {
            float _3195 = _3187 / _3190;
            float _3196 = _3188 / _3190;
            float _3197 = _3189 / _3190;
            float _3198 = _3195 * _3195;
            float _3199 = _3198 * 3.1415927410125732f;
            float _3200 = _3196 * _3196;
            float _3201 = _3200 * 3.1415927410125732f;
            float _3202 = _3197 * _3197;
            float _3203 = _3202 * 3.1415927410125732f;
            _3217 = _3199;
            _3218 = _3201;
            _3219 = _3203;
            _3220 = _3190;
          } else {
            bool _3205 = (_3191 > 9.999999747378752e-06f);
            if (_3205) {
              float _3207 = _3187 / _3191;
              float _3208 = _3188 / _3191;
              float _3209 = _3189 / _3191;
              float _3210 = _3207 * _3207;
              float _3211 = _3210 * 3.1415927410125732f;
              float _3212 = _3208 * _3208;
              float _3213 = _3212 * 3.1415927410125732f;
              float _3214 = _3209 * _3209;
              float _3215 = _3214 * 3.1415927410125732f;
              _3217 = _3211;
              _3218 = _3213;
              _3219 = _3215;
              _3220 = _3191;
            } else {
              _3217 = 0.0f;
              _3218 = 0.0f;
              _3219 = 0.0f;
              _3220 = 0.0f;
            }
          }
          bool _3221 = (_3220 < 9.999999747378752e-06f);
          if (_3221) {
            _3224 = _2870;
            _3225 = _2871;
            _3226 = _2872;
            _3227 = _2874;
            _3228 = _2875;
            _3229 = 0.0f;
            _3230 = 0;
            _3231 = _3217;
            _3232 = _3218;
            _3233 = _3219;
          } else {
            _3224 = _2870;
            _3225 = _2871;
            _3226 = _2872;
            _3227 = _2874;
            _3228 = _2875;
            _3229 = _2519;
            _3230 = _2873;
            _3231 = _3217;
            _3232 = _3218;
            _3233 = _3219;
          }
          break;
        }
      } else {
        _3224 = _2866;
        _3225 = _2867;
        _3226 = _2868;
        _3227 = _2521;
        _3228 = _2485;
        _3229 = _2519;
        _3230 = _2525;
        _3231 = 0.0f;
        _3232 = 0.0f;
        _3233 = 0.0f;
      }
    }
    bool _3236 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
    float _3237 = select(_3236, 1.0f, _3224);
    float _3238 = select(_3236, 0.0f, _3225);
    float _3239 = select(_3236, 0.0f, _3226);
    float _3240 = select(_3236, 0.0f, _3231);
    float _3241 = select(_3236, 0.0f, _3232);
    float _3242 = select(_3236, 1.0f, _3233);
    int _3243 = _3230 | _3227;
    bool _3244 = (_3243 == 0);
    bool _3245 = (_3229 < 1.0f);
    bool _3246 = _3245 || _3244;
    if (_3246) {
      float _3250 = abs(_1904);
      float _3251 = abs(_1905);
      float _3252 = _3251 + _3250;
      float _3253 = abs(_1906);
      float _3254 = _3252 + _3253;
      float _3255 = _1904 / _3254;
      float _3256 = _1905 / _3254;
      float _3257 = _1906 / _3254;
      bool _3258 = (_3257 > 0.0f);
      if (!_3258) {
        float _3260 = abs(_3256);
        float _3261 = abs(_3255);
        float _3262 = 1.0f - _3260;
        float _3263 = 1.0f - _3261;
        bool _3264 = (_3255 > 0.0f);
        bool _3265 = (_3256 > 0.0f);
        bool _3266 = (_3255 < 0.0f);
        bool _3267 = (_3256 < 0.0f);
        int _3268 = (int)(uint)(_3264);
        int _3269 = (int)(uint)(_3265);
        int _3270 = (int)(uint)(_3266);
        int _3271 = (int)(uint)(_3267);
        int _3272 = _3268 - _3270;
        int _3273 = _3269 - _3271;
        float _3274 = float((int)(_3272));
        float _3275 = float((int)(_3273));
        float _3276 = _3262 * _3274;
        float _3277 = _3263 * _3275;
        _3279 = _3276;
        _3280 = _3277;
      } else {
        _3279 = _3255;
        _3280 = _3256;
      }
      float _3281 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
      float _3282 = _3281 * 0.5f;
      float _3283 = _3281 + 2.0f;
      float _3284 = _3282 / _3283;
      float _3285 = _3284 * _3279;
      float _3286 = _3284 * _3280;
      float _3287 = _3285 + 0.5f;
      float _3288 = _3286 + 0.5f;
      float _3289 = _3287 * 0.0078125f;
      float _3290 = _3288 * 0.0078125f;
      float4 _3294 = t28[0].SampleLevel(s7, float3(_3289, _3290, 0.0f), 0.0f);
      float _3298 = _3294.x * 3.1415927410125732f;
      float _3299 = _3294.y * 3.1415927410125732f;
      float _3300 = _3294.z * 3.1415927410125732f;
      bool _3303 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
      float _3304 = select(_3303, 0.0f, _3298);
      float _3305 = select(_3303, 1.0f, _3299);
      float _3306 = select(_3303, 0.0f, _3300);
      float _3307 = _3240 - _3304;
      float _3308 = _3241 - _3305;
      float _3309 = _3242 - _3306;
      float _3310 = _3307 * _3229;
      float _3311 = _3308 * _3229;
      float _3312 = _3309 * _3229;
      float _3313 = _3310 + _3304;
      float _3314 = _3311 + _3305;
      float _3315 = _3312 + _3306;
      bool _3316 = (_3243 != 0);
      float _3317 = select(_3316, _3228, 0.0f);
      _3319 = _3317;
      _3320 = _3313;
      _3321 = _3314;
      _3322 = _3315;
    } else {
      _3319 = _3228;
      _3320 = _3240;
      _3321 = _3241;
      _3322 = _3242;
    }
    float _3323 = _3237 - _3320;
    float _3324 = _3238 - _3321;
    float _3325 = _3239 - _3322;
    float _3326 = _3323 * _3319;
    float _3327 = _3324 * _3319;
    float _3328 = _3325 * _3319;
    float _3329 = _3326 + _3320;
    float _3330 = _3327 + _3321;
    float _3331 = _3328 + _3322;
    bool _3332 = isnan(_3329);
    bool _3333 = isnan(_3330);
    bool _3334 = isnan(_3331);
    bool _3335 = _3332 || _3333;
    bool _3336 = _3335 || _3334;
    float _3337 = select(_3336, 0.0f, _3329);
    float _3338 = select(_3336, 0.0f, _3330);
    float _3339 = select(_3336, 0.0f, _3331);
    float _3340 = select(_3336, 0.0f, _3319);
    bool _3341 = (_3340 == 0.0f);
    _3343 = _3337;
    _3344 = _3338;
    _3345 = _3339;
    _3346 = _3341;
  } else {
    _3343 = 0.0f;
    _3344 = 0.0f;
    _3345 = 0.0f;
    _3346 = true;
  }
  float _3347 = dot(float3(_3343, _3344, _3345), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f));
  float _3348 = dot(float3(_2445, _2446, _2447), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f));
  float _3349 = _3347 / _3348;
  float _3350 = select(_3346, 1.0f, _3349);
  float _3351 = _3350 * _2384;
  float _3352 = _3351 * _2172;
  float _3353 = _3351 * _2173;
  float _3354 = _3351 * _2174;
  bool _3357 = (cb12_074x > 0.0f);
  float _3358 = select(_3357, 0.0f, _3352);
  float _3359 = select(_3357, 0.0f, _3353);
  float _3360 = select(_3357, 0.0f, _3354);
  float _3364 = FrequentPixelConsts_256.z - FrequentPixelConsts_256.w;
  float _3365 = _3364 * _970;
  float _3366 = _3364 * _971;
  float _3367 = _3364 * _972;
  float _3368 = _3365 + FrequentPixelConsts_256.w;
  float _3369 = _3366 + FrequentPixelConsts_256.w;
  float _3370 = _3367 + FrequentPixelConsts_256.w;
  float _3371 = _3368 * _3358;
  float _3372 = _3369 * _3359;
  float _3373 = _3370 * _3360;
  float _3377 = dot(float3(_406, _407, _408), float3(_468, _469, _470));
  float _3378 = abs(_3377);
  float _3379 = max(_3378, _3378);
  float _3380 = abs(_3379);
  float _3381 = 1.0f - _3380;
  float _3382 = saturate(_3381);
  float _3383 = _3382 * _3382;
  float _3387 = min(0.25f, cb13_066y);
  float _3388 = 1.0f - _401;
  float _3389 = 1.0f - _402;
  float _3390 = 1.0f - _403;
  float _3391 = max(0.0f, _3388);
  float _3392 = max(0.0f, _3389);
  float _3393 = max(0.0f, _3390);
  float _3394 = _3383 * _3383;
  float _3395 = _3394 * _3382;
  float _3396 = _3395 * _3387;
  float _3397 = _3396 * _3391;
  float _3398 = _3396 * _3392;
  float _3399 = _3393 * _3396;
  float _3400 = cb13_066w * 0.8999999761581421f;
  float _3401 = _3400 + 1.0f;
  float _3402 = _3397 / _3401;
  float _3403 = _3398 / _3401;
  float _3404 = _3399 / _3401;
  float _3405 = _3402 + _401;
  float _3406 = _3403 + _402;
  float _3407 = _3404 + _403;
  float _3408 = _3371 * _3405;
  float _3409 = _3372 * _3406;
  float _3410 = _3373 * _3407;
  float4 _3412 = t17.Load(int3(_446, _447, 0));
  float _3416 = cb12_187x * _3412.x;
  float _3419 = _3416 + cb12_188x;
  float _3420 = saturate(_3419);
  float _3421 = _3420 + -1.0f;
  float _3422 = _3421 * 0.699999988079071f;
  float _3423 = _3422 + 1.0f;
  float _3426 = _3423 * cb12_069x;
  float _3428 = _3426 + cb12_069y;
  bool _3429 = (_472.z < 0.9900000095367432f);
  if (_3429) {
    _3434 = cb12_287w;
  } else {
    _3434 = 1.0f;
  }
  float _3437 = cb12_288y * _3434;
  float _3438 = log2(_3423);
  float _3439 = _3437 * _3438;
  float _3440 = exp2(_3439);
  if (_3429) {
    _3445 = cb12_287w;
  } else {
    _3445 = 1.0f;
  }
  float _3447 = _3445 * cb12_288z;
  float _3448 = log2(_3428);
  float _3449 = _3447 * _3448;
  float _3450 = exp2(_3449);
  if (_3429) {
    _3455 = cb12_287w;
  } else {
    _3455 = 1.0f;
  }
  float _3457 = _3448 * cb12_288w;
  float _3458 = _3457 * _3455;
  float _3459 = exp2(_3458);
  float _3460 = _3450 * cb12_184z;
  float _3461 = _3460 * _1890;
  float _3462 = _3460 * _1891;
  float _3463 = _3460 * _1892;
  float _3464 = _3459 * cb12_184w;
  float _3465 = _3464 * _1893;
  float _3466 = _3464 * _1894;
  float _3467 = _3464 * _1895;
  bool _3468 = (_450 == 0);
  float _3469 = _3461 * _389;
  float _3470 = _3462 * _390;
  float _3471 = _3463 * _391;
  float _3472 = select(_3468, _3469, _3461);
  float _3473 = select(_3468, _3470, _3462);
  float _3474 = select(_3468, _3471, _3463);
  float _3475 = _3465 + _3472;
  float _3476 = _3466 + _3473;
  float _3477 = _3467 + _3474;
  if (!_3357) {
    float _3479 = _3410 * _3440;
    float _3480 = _3409 * _3440;
    float _3481 = _3408 * _3440;
    float _3482 = _3475 + _3481;
    float _3483 = _3476 + _3480;
    float _3484 = _3477 + _3479;
    _3486 = _3482;
    _3487 = _3483;
    _3488 = _3484;
  } else {
    _3486 = _3475;
    _3487 = _3476;
    _3488 = _3477;
  }
  SV_Target.x = _3486;
  SV_Target.y = _3487;
  SV_Target.z = _3488;
  SV_Target.w = _445;
  SV_Target_1.x = _434;
  SV_Target_1.y = _435;
  SV_Target_1.z = _436;
  SV_Target_1.w = 0.8999999761581421f;
  SV_Target_3.x = 1.0f;
  SV_Target_3.y = 0.0f;
  SV_Target_3.z = 0.0f;
  SV_Target_3.w = _445;
  OutputSignature output_signature = { SV_Target, SV_Target_1, SV_Target_3 };
  return output_signature;
}
