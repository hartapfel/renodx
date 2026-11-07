// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "shared.h"
#include "lighting/brdf.hlsli"
#include "water/receiver.hlsli"
#include "lighting/sun_environment.hlsli"

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


Texture2D<float4> t17 : register(t17);

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t0 : register(t0);

TextureCube<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t43 : register(t43);

Texture2DArray<float4> t28[2] : register(t28);

Texture2DArray<float3> t30[2] : register(t30);

Texture2D<uint> t32[2] : register(t32);

Texture2D<float4> t34[2] : register(t34);

Texture2DArray<uint> t38 : register(t38);

Texture2DArray<float> t9 : register(t9);

TextureCubeArray<float> t10 : register(t10);

Texture2DArray<float4> t42 : register(t42);

Texture2DArray<uint> t60 : register(t60);

ByteAddressBuffer t20 : register(t20);

cbuffer cb1 : register(b1) {
  float cb1_036x : packoffset(c036.x);
  float cb1_036y : packoffset(c036.y);
  float cb1_036z : packoffset(c036.z);
  uint cb1_padding : packoffset(c53.w);
};

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

cbuffer cb12 : register(b12) {
  float4 cb12_raw[341] : packoffset(c0);
};

#define cb12_219w (cb12_raw[219].w)
#define cb12_220w (cb12_raw[220].w)
#define cb12_069w (cb12_raw[69].w)
#define cb12_024x (cb12_raw[24].x)
#define cb12_000x (cb12_raw[0].x)
#define cb12_000y (cb12_raw[0].y)
#define cb12_219z (cb12_raw[219].z)
#define cb12_000z (cb12_raw[0].z)
#define cb12_188x (cb12_raw[188].x)
#define cb12_221x (cb12_raw[221].x)
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
#define cb12_340z (asint(cb12_raw[340].z))

cbuffer cb4 : register(b4) {
  float cb4_000x : packoffset(c000.x);
  float cb4_001x : packoffset(c001.x);
  float cb4_002x : packoffset(c002.x);
  float cb4_003x : packoffset(c003.x);
  float cb4_004x : packoffset(c004.x);
  float cb4_005x : packoffset(c005.x);
  float cb4_006x : packoffset(c006.x);
  float cb4_007x : packoffset(c007.x);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
  float cb4_011x : packoffset(c011.x);
  float cb4_012x : packoffset(c012.x);
  float cb4_014x : packoffset(c014.x);
  float cb4_015x : packoffset(c015.x);
  float cb4_016x : packoffset(c016.x);
  float cb4_017x : packoffset(c017.x);
  float cb4_018x : packoffset(c018.x);
  float cb4_019x : packoffset(c019.x);
  float cb4_020x : packoffset(c020.x);
  float cb4_021x : packoffset(c021.x);
  float cb4_022x : packoffset(c022.x);
  float cb4_023x : packoffset(c023.x);
};

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
#define cb13_065w (cb13_raw[65].w)
#define cb13_000z (cb13_raw[0].z)
#define cb13_061z (cb13_raw[61].z)
#define cb13_065y (cb13_raw[65].y)
#define cb13_062x (cb13_raw[62].x)
#define cb13_065x (cb13_raw[65].x)
#define cb13_062y (cb13_raw[62].y)
#define cb13_062z (cb13_raw[62].z)
#define cb13_001x (cb13_raw[1].x)
#define cb13_066y (cb13_raw[66].y)
#define cb13_001z (cb13_raw[1].z)
#define cb13_067x (cb13_raw[67].x)
#define cb13_066w (cb13_raw[66].w)
#define cb13_065z (cb13_raw[65].z)

SamplerState s11 : register(s11);

SamplerState s0 : register(s0);

SamplerState s10 : register(s10);

SamplerState s7 : register(s7);

#include "lighting/contact/forward.hlsli"

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  linear float3 TEXCOORD_2 : TEXCOORD2,
  linear float3 TEXCOORD_3 : TEXCOORD3,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  bool _2427;
  bool _2159;
  float _48[4];
  float _51 = TEXCOORD.x + select((TEXCOORD.x > 0.0f), -1.0f, 1.0f);
  float _53 = select((_51 >= 0.0f), 0.0f, 1.0f);
  float _55 = rsqrt(dot(float3(TEXCOORD_3.x, TEXCOORD_3.y, TEXCOORD_3.z), float3(TEXCOORD_3.x, TEXCOORD_3.y, TEXCOORD_3.z)));
  float _56 = _55 * TEXCOORD_3.x;
  float _57 = _55 * TEXCOORD_3.y;
  float _58 = _55 * TEXCOORD_3.z;
  float4 _65 = t0.Sample(s0, float2((cb4_002x * _51), (cb4_002x * TEXCOORD.y)));
  float _74 = _51 + -0.5f;
  float _75 = TEXCOORD.y + -0.5f;
  float _79 = sqrt((_74 * _74) + (_75 * _75));
  float _85 = saturate(1.0f - (((cb4_003x - cb4_004x) + _79) / (cb4_003x * 2.0f)));
  float _95 = cb4_007x * cb4_008x;
  float _97 = rsqrt(dot(float3(_74, _75, _95), float3(_74, _75, _95)));
  float _98 = _97 * _95;
  float _115;
  float _116;
  float _117;
  float _286;
  float _287;
  float _288;
  float _289;
  float _290;
  float _291;
  float _604;
  float _681;
  float _682;
  float _683;
  float _684;
  float _685;
  float _686;
  float _687;
  float _738;
  float _877;
  float _904;
  float _909;
  float _910;
  float _911;
  float _919;
  float _920;
  float _921;
  float _922;
  float _923;
  float _924;
  float _925;
  float _926;
  float _927;
  int _946;
  int _952;
  int _958;
  int _964;
  int _970;
  int _976;
  int _982;
  int _988;
  int _989;
  int _990;
  int _991;
  int _992;
  int _993;
  int _994;
  int _995;
  int _996;
  float _998;
  float _999;
  float _1000;
  float _1001;
  float _1002;
  float _1003;
  int _1004;
  int _1062;
  float _1068;
  bool _1069;
  float _1136;
  float _1142;
  float _1253;
  float _1254;
  float _1255;
  float _1256;
  float _1336;
  float _1337;
  float _1338;
  float _1339;
  float _1343;
  float _1344;
  float _1345;
  float _1346;
  int _1347;
  float _1392;
  int _1405;
  int _1406;
  float _1444;
  float _1445;
  float _1446;
  float _1451;
  float _1452;
  float _1453;
  float _1455;
  float _1456;
  float _1457;
  float _1458;
  float _1475;
  float _1478;
  float _1479;
  float _1491;
  float _1500;
  float _1543;
  float _1564;
  float _1652;
  float _1726;
  float _1727;
  float _1728;
  float _1729;
  float _1780;
  float _1880;
  float _1907;
  float _1912;
  float _1913;
  float _1914;
  float _1922;
  float _1923;
  float _1924;
  float _1925;
  float _1926;
  float _1927;
  float _1931;
  float _1932;
  float _1933;
  float _1934;
  float _1935;
  float _1936;
  int _1954;
  float _1955;
  float _1956;
  float _1957;
  float _1958;
  float _2153;
  float _2154;
  float _2155;
  float _2156;
  float _2217;
  float _2218;
  float _2219;
  float _2220;
  int _2222;
  float _2223;
  float _2224;
  float _2225;
  float _2226;
  float _2421;
  float _2422;
  float _2423;
  float _2424;
  float _2486;
  float _2487;
  float _2488;
  float _2489;
  float _2644;
  float _2645;
  float _2646;
  float _2647;
  float _2648;
  int _2649;
  float _2754;
  float _2755;
  float _2810;
  float _2811;
  float _2862;
  float _2876;
  float _2877;
  float _2878;
  float _2879;
  float _2880;
  float _2906;
  float _2907;
  float _2908;
  float _2909;
  float _2912;
  float _2913;
  float _2914;
  float _2916;
  float _2917;
  float _2918;
  int _2919;
  int _2920;
  float _2921;
  float _2997;
  float _2998;
  float _2999;
  float _3000;
  float _3001;
  int _3002;
  float _3115;
  float _3116;
  float _3167;
  float _3168;
  float _3219;
  float _3233;
  float _3234;
  float _3235;
  float _3236;
  float _3237;
  float _3263;
  float _3264;
  float _3265;
  float _3266;
  float _3270;
  float _3271;
  float _3272;
  int _3273;
  float _3274;
  float _3275;
  int _3276;
  float _3277;
  float _3278;
  float _3279;
  float _3325;
  float _3326;
  float _3365;
  float _3366;
  float _3367;
  float _3368;
  float _3389;
  float _3390;
  float _3391;
  bool _3392;
  float _3498;
  float _3509;
  float _3519;
  float _3539;
  float _3540;
  float _3541;
  float _3542;
  float _3543;
  float _3544;
  float _3545;
  float _3546;
  float _3547;
  float _3554;
  float _3555;
  float _3556;
  float _3565;
  float _3566;
  float _3567;
  if ((_98 * cb4_008x) > _95) {
    float _102 = _97 * cb4_008x;
    float _105 = (_102 * _74) - _74;
    float _106 = (_102 * _75) - _75;
    float _108 = (_98 - cb4_007x) * cb4_008x;
    float _110 = rsqrt(dot(float3(_105, _106, _108), float3(_105, _106, _108)));
    _115 = (_110 * _105);
    _116 = (_110 * _106);
    _117 = (_110 * _108);
  } else {
    _115 = 0.0f;
    _116 = 0.0f;
    _117 = 1.0f;
  }
  float _128 = exp2(log2(saturate(1.0f - ((cb4_006x * _79) / sqrt((cb4_008x * cb4_008x) - (_95 * _95))))) * cb4_005x);
  float _129 = _128 * _115;
  float _130 = _128 * _116;
  float _132 = rsqrt(dot(float3(_129, _130, _117), float3(_129, _130, _117)));
  float _135 = _132 * _117;
  float _136 = (1.0f - _85) * 2.0f;
  float _139 = (_132 * _129) + (_136 * (_65.x + -0.5f));
  float _140 = (_132 * _130) + (_136 * (_65.y + -0.5f));
  float _142 = rsqrt(dot(float3(_139, _140, _135), float3(_139, _140, _135)));
  float _143 = _139 * _142;
  float _144 = _140 * _142;
  float _145 = _142 * _135;
  float _147 = rsqrt(dot(float3(TEXCOORD.z, TEXCOORD.w, TEXCOORD_1.w), float3(TEXCOORD.z, TEXCOORD.w, TEXCOORD_1.w)));
  float _148 = _147 * TEXCOORD.z;
  float _149 = _147 * TEXCOORD.w;
  float _150 = _147 * TEXCOORD_1.w;
  float _152 = rsqrt(dot(float3(TEXCOORD_1.x, TEXCOORD_1.y, TEXCOORD_1.z), float3(TEXCOORD_1.x, TEXCOORD_1.y, TEXCOORD_1.z)));
  float _153 = _152 * TEXCOORD_1.x;
  float _154 = _152 * TEXCOORD_1.y;
  float _155 = _152 * TEXCOORD_1.z;
  float _158 = mad(_145, _148, mad(_144, _153, (_143 * _56)));
  float _161 = mad(_145, _149, mad(_144, _154, (_143 * _57)));
  float _164 = mad(_145, _150, mad(_144, _155, (_143 * _58)));
  float _166 = rsqrt(dot(float3(_158, _161, _164), float3(_158, _161, _164)));
  float _167 = _166 * _158;
  float _168 = _166 * _161;
  float _169 = _166 * _164;
  float _174 = cb1_036x - TEXCOORD_2.x;
  float _175 = cb1_036y - TEXCOORD_2.y;
  float _176 = cb1_036z - TEXCOORD_2.z;
  float _178 = rsqrt(dot(float3(_174, _175, _176), float3(_174, _175, _176)));
  float _179 = _174 * _178;
  float _180 = _175 * _178;
  float _181 = _176 * _178;
  float _187 = sqrt(((_174 * _174) + (_175 * _175)) + (_176 * _176));
  float _188 = _187 * _179;
  float _189 = _187 * _180;
  float _194 = (cb4_009x * _148) + _188;
  float _195 = (cb4_009x * _149) + _189;
  float _197 = rsqrt(dot(float3(_194, _195, 0.0f), float3(_194, _195, 0.0f)));
  float _198 = _194 * _197;
  float _199 = _195 * _197;
  float _201 = -0.0f - _188;
  float _202 = -0.0f - _189;
  float _204 = -0.0f - (_187 * _181);
  float _206 = rsqrt(dot(float3(_201, _202, _204), float3(_201, _202, _204)));
  float _207 = _206 * _201;
  float _208 = _206 * _202;
  float _209 = _206 * _204;
  float _211 = dot(float3(_207, _208, _209), float3(_167, _168, _169)) * 2.0f;
  float _215 = _207 - (_211 * _167);
  float _216 = _208 - (_211 * _168);
  float _217 = _209 - (_211 * _169);
  float4 _225 = t1.Sample(s0, float3(mad((-0.0f - _198), _216, (_215 * _199)), mad(-0.0f, _217, mad(_199, _216, (_215 * _198))), _217));
  float _235 = ((cb4_001x - cb4_000x) * _53) + cb4_000x;
  bool _262 = (TEXCOORD.x <= 0.0f);
  float _264 = select(_262, cb4_015x, cb4_014x) * -0.01745329424738884f;
  float _265 = sin(_264);
  float _266 = cos(_264);
  if (_262) {
    _286 = CustomPixelConsts_176.x;
    _287 = CustomPixelConsts_192.x;
    _288 = CustomPixelConsts_176.y;
    _289 = CustomPixelConsts_192.y;
    _290 = CustomPixelConsts_176.z;
    _291 = CustomPixelConsts_192.z;
  } else {
    _286 = CustomPixelConsts_128.x;
    _287 = CustomPixelConsts_144.x;
    _288 = CustomPixelConsts_128.y;
    _289 = CustomPixelConsts_144.y;
    _290 = CustomPixelConsts_128.z;
    _291 = CustomPixelConsts_144.z;
  }
  float _293 = mad(_266, _287, (_286 * _265));
  float _295 = mad(_266, _289, (_288 * _265));
  float _297 = mad(_266, _291, (_290 * _265));
  float _299 = rsqrt(dot(float3(_56, _57, _58), float3(_56, _57, _58)));
  float _300 = _299 * _56;
  float _301 = _299 * _57;
  float _302 = _299 * _58;
  float _304 = rsqrt(dot(float3(_148, _149, _150), float3(_148, _149, _150)));
  float _305 = _304 * _148;
  float _306 = _304 * _149;
  float _307 = _304 * _150;
  float _309 = rsqrt(dot(float3(_179, _180, _181), float3(_179, _180, _181)));
  float _311 = -0.0f - (_179 * _309);
  float _313 = -0.0f - (_180 * _309);
  float _315 = -0.0f - (_181 * _309);
  float _316 = dot(float3(_300, _301, _302), float3(_293, _295, _297));
  float _320 = _300 - (_316 * _293);
  float _321 = _301 - (_316 * _295);
  float _322 = _302 - (_316 * _297);
  float _324 = rsqrt(dot(float3(_320, _321, _322), float3(_320, _321, _322)));
  float _325 = _320 * _324;
  float _326 = _321 * _324;
  float _327 = _322 * _324;
  float _330 = (_326 * _297) - (_327 * _295);
  float _333 = (_327 * _293) - (_325 * _297);
  float _336 = (_325 * _295) - (_326 * _293);
  float _337 = _305 * cb4_009x;
  float _338 = _306 * cb4_009x;
  float _339 = _307 * cb4_009x;
  float _351 = mad(_327, _315, mad(_326, _313, (_325 * _311)));
  float _354 = mad(_297, _315, mad(_295, _313, (_293 * _311)));
  float _357 = mad(_336, _315, mad(_333, _313, (_330 * _311)));
  float _360 = mad(_327, _307, mad(_326, _306, (_325 * _305)));
  float _363 = mad(_297, _307, mad(_295, _306, (_305 * _293)));
  float _366 = mad(_336, _307, mad(_333, _306, (_330 * _305)));
  float _367 = dot(float3(_351, _354, _357), float3(_360, _363, _366));
  float _372 = 1.0f - ((cb4_011x * cb4_011x) * (1.0f - (_367 * _367)));
  bool _373 = (_372 >= 0.0f);
  float _379 = (_367 * cb4_011x) + sqrt(_372);
  float _396 = min(max((1.0f / abs(select(_373, ((_354 * cb4_011x) - (_379 * _363)), 0.0f))), -3.4028234663852886e+38f), 3.4028234663852886e+38f) * (max(0.0f, (mad(_297, _339, mad(_295, _338, (_337 * _293))) - cb4_016x)) * cb4_012x);
  float _403 = cb4_009x * 2.0f;
  float _412 = (((0.5f - _51) + ((((_396 * select(_373, ((_351 * cb4_011x) - (_379 * _360)), 0.0f)) + mad(_327, _339, mad(_326, _338, (_325 * _337)))) * cb4_017x) / _403)) * _85) + _51;
  float _413 = (((0.5f - TEXCOORD.y) + ((((_396 * select(_373, ((_357 * cb4_011x) - (_379 * _366)), 0.0f)) + mad(_336, _339, mad(_333, _338, (_330 * _337)))) * cb4_017x) / _403)) * _85) + TEXCOORD.y;
  float4 _416 = t2.Sample(s0, float2(_412, _413));
  float4 _422 = t3.Sample(s0, float2(_412, _413));
  float _429 = (_422.x + -0.5f) * 2.0f;
  float _430 = (_422.y + -0.5f) * 2.0f;
  float _431 = (_422.z + -0.5f) * 2.0f;
  float _434 = mad(_431, _148, mad(_430, _153, (_429 * _56)));
  float _437 = mad(_431, _149, mad(_430, _154, (_429 * _57)));
  float _440 = mad(_431, _150, mad(_430, _155, (_429 * _58)));
  float _442 = rsqrt(dot(float3(_434, _437, _440), float3(_434, _437, _440)));
  float _443 = _442 * _434;
  float _444 = _442 * _437;
  float _445 = _442 * _440;
  uint _461 = uint(SV_Position.x);
  uint _462 = uint(SV_Position.y);
  float _463 = saturate(cb4_020x);
  float _467 = exp2(log2(saturate(lerp(cb4_018x, cb4_019x, _53))) * 2.200000047683716f);
  float _477 = exp2(log2(saturate(_416.x)) * 2.200000047683716f);
  float _478 = exp2(log2(saturate(_416.y)) * 2.200000047683716f);
  float _479 = exp2(log2(saturate(_416.z)) * 2.200000047683716f);
  int _485 = int(cb12_220w);
  float _487 = rsqrt(dot(float3(_443, _444, _445), float3(_443, _444, _445)));
  float _488 = _487 * _443;
  float _489 = _487 * _444;
  float _490 = _487 * _445;
  float _492 = rsqrt(dot(float3(_167, _168, _169), float3(_167, _168, _169)));
  float _493 = _492 * _167;
  float _494 = _492 * _168;
  float _495 = _492 * _169;
  float _508 = cb12_000x - TEXCOORD_2.x;
  float _509 = cb12_000y - TEXCOORD_2.y;
  float _510 = cb12_000z - TEXCOORD_2.z;
  float _512 = rsqrt(dot(float3(_508, _509, _510), float3(_508, _509, _510)));
  float _513 = _508 * _512;
  float _514 = _509 * _512;
  float _515 = _510 * _512;
  bool improved_pbr = graphics_injection.layout_version == 1.f
      && graphics_injection.graphics_mode != 0.f && graphics_injection.pbr_mode != 0.f
      && (_485 == 0 || _485 == 1);
  // The eye material supplies distinct iris and corneal normals. Filter the
  // direct lobes independently, before divergent light branches; retain native
  // refraction, pupil geometry and environment roughness.
  float iris_roughness = GraphicsForwardRoughness(float3(_488, _489, _490), _463);
  float cornea_roughness = GraphicsForwardRoughness(float3(_493, _494, _495), _463);
  iris_roughness = improved_pbr ? iris_roughness : _463;
  cornea_roughness = improved_pbr ? cornea_roughness : _463;
  float4 _517 = t17.Load(int3(_461, _462, 0));
  float graphics_sun_visibility = min(_517.y, GraphicsForwardContact(TEXCOORD_2,
      float3(_488, _489, _490), SV_Position.xy, true));
  GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
      TEXCOORD_2, float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
  if (_517.y > 0.0f) {
    if (_485 == 1) {
      int _531 = ((int)(uint)((int)(_490 > 0.0f))) << 1u;
      float _533 = float((int)(_531 + -1));
      float _535 = -1.0f / (_533 + _490);
      float _537 = (_488 * _489) * _535;
      float _541 = (((_488 * _488) * _533) * _535) + 1.0f;
      float _542 = _537 * _533;
      float _545 = float((int)(1 - _531)) * _488;
      float _548 = ((_489 * _489) * _535) + _533;
      float _549 = -0.0f - _489;
      float _551 = rsqrt(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
      float _552 = _551 * water_light.sun.x;
      float _553 = _551 * water_light.sun.y;
      float _554 = _551 * water_light.sun.z;
      float _557 = mad(_545, _554, mad(_542, _553, (_552 * _541)));
      float _560 = mad(_549, _554, mad(_548, _553, (_552 * _537)));
      float _563 = mad(_490, _554, mad(_489, _553, (_552 * _488)));
      float _565 = rsqrt(dot(float3(_557, _560, _563), float3(_557, _560, _563)));
      float _568 = _565 * _563;
      float _570 = rsqrt(dot(float3(_513, _514, _515), float3(_513, _514, _515)));
      float _571 = _570 * _513;
      float _572 = _570 * _514;
      float _573 = _570 * _515;
      float _576 = mad(_545, _573, mad(_542, _572, (_571 * _541)));
      float _579 = mad(_549, _573, mad(_548, _572, (_571 * _537)));
      float _582 = mad(_490, _573, mad(_489, _572, (_571 * _488)));
      float _584 = rsqrt(dot(float3(_576, _579, _582), float3(_576, _579, _582)));
      float _587 = _584 * _582;
      float _588 = _463 * _463;
      float _591 = dot(float3((_565 * _557), (_565 * _560), _568), float3((_584 * _576), (_584 * _579), _587)) - (_587 * _568);
      if (_591 > 0.0f) {
        _604 = (_591 / max(_568, _587));
      } else {
        _604 = _591;
      }
      float _606 = (_588 * 0.2877933979034424f) + 1.0f;
      float _607 = 1.0f / _606;
      float _611 = ((_604 * _588) + 1.0f) * (_607 * 0.31830987334251404f);
      float _615 = 1.0f - _587;
      float _626 = 1.0f - _568;
      float _639 = _607 * ((_588 * 0.07248824834823608f) + 1.0f);
      float _646 = 1.0f - _639;
      float _661 = max(1.0000000116860974e-07f, (1.0f - ((((_626 * _588) * ((((((_626 * 0.07144299894571304f) + -0.332181453704834f) * _626) + 0.4918818771839142f) * _626) + 0.05710852891206741f)) + 1.0f) / _606))) * (max(1.0000000116860974e-07f, (1.0f - ((((_615 * _588) * ((((((_615 * 0.07144299894571304f) + -0.332181453704834f) * _615) + 0.4918818771839142f) * _615) + 0.05710852891206741f)) + 1.0f) / _606))) * 0.31830987334251404f);
      float _665 = max(1.0000000116860974e-07f, _646);
      float _673 = saturate(dot(float3(_488, _489, _490), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
      float _674 = _673 * (((_661 * (((_477 * _477) * _639) / (1.0f - (_646 * _477)))) / _665) + (_611 * _477));
      float _675 = _673 * (((_661 * (((_478 * _478) * _639) / (1.0f - (_646 * _478)))) / _665) + (_611 * _478));
      float _676 = _673 * (((_661 * (((_479 * _479) * _639) / (1.0f - (_646 * _479)))) / _665) + (_611 * _479));
      _681 = _674;
      _682 = _675;
      _683 = _676;
      _684 = 1.0f;
      _685 = (_674 * 3.1415927410125732f);
      _686 = (_675 * 3.1415927410125732f);
      _687 = (_676 * 3.1415927410125732f);
    } else {
      float _599 = cb4_021x + 1.0f;
      float _602 = saturate((dot(float3(_488, _489, _490), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + cb4_021x) / _599);
      _681 = _602;
      _682 = _602;
      _683 = _602;
      _684 = (1.0f / _599);
      _685 = _602;
      _686 = _602;
      _687 = _602;
    }
    // Iris response uses its refracted normal; cornea highlights remain separate.
    if (improved_pbr) {
      float3 diffuse = GraphicsForwardDiffuse(float3(_488, _489, _490), float3(_513, _514, _515),
          float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), iris_roughness, float3(_477, _478, _479), _485, _681);
      _681 = diffuse.x; _682 = diffuse.y; _683 = diffuse.z;
    }
    float _691 = 1.0f - _467;
    if (cb12_221x > 0.0f) {
      float4 _696 = t43.SampleLevel(s10, float2(iris_roughness, dot(float3(_488, _489, _490), float3(_513, _514, _515))), 0.0f);
      float _700 = (_696.x * _467) + _696.y;
      _738 = min((_700 / max((1.0f - ((1.0f - _700) * ((_691 * 0.0476190485060215f) + _467))), 0.0010000000474974513f)), 1.0f);
    } else {
      float _710 = water_light.sun.x + _513;
      float _711 = water_light.sun.y + _514;
      float _712 = water_light.sun.z + _515;
      float _714 = rsqrt(dot(float3(_710, _711, _712), float3(_710, _711, _712)));
      float _721 = saturate(1.0f - abs(dot(float3((_714 * _710), (_714 * _711), (_714 * _712)), float3(_513, _514, _515))));
      float _722 = _721 * _721;
      _738 = ((((((_722 * _722) * _721) * cb13_066x) * max(0.0f, _691)) / ((cb13_066z + 1.0f) - (cb13_066z * (1.0f - iris_roughness)))) + _467);
    }
    float _742 = (1.0f - _738) * _681;
    float _743 = (1.0f - _738) * _682;
    float _744 = (1.0f - _738) * _683;
    bool _746 = ((_485 & -3) == 0);
    float _753 = TEXCOORD_2.x - cb12_000x;
    float _754 = TEXCOORD_2.y - cb12_000y;
    float _764 = saturate((cb12_219z * TEXCOORD_2.z) + cb12_219w);
    float _786 = saturate((cb12_219x * sqrt((_753 * _753) + (_754 * _754))) + cb12_219y);
    float _797 = ((((lerp(cb13_062x, cb13_061x, _764)) - cb13_001x) * _786) + cb13_001x) * water_light.direct.x;
    float _798 = ((((lerp(cb13_062y, cb13_061y, _764)) - cb13_001y) * _786) + cb13_001y) * water_light.direct.y;
    float _799 = ((((lerp(cb13_062z, cb13_061z, _764)) - cb13_001z) * _786) + cb13_001z) * water_light.direct.z;
    float _800 = _684 * graphics_sun_visibility;
    [branch]
    if (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_493, _494, _495)) > 0.0f) {
      float _810 = water_light.sun.x + _513;
      float _811 = water_light.sun.y + _514;
      float _812 = water_light.sun.z + _515;
      float _814 = rsqrt(dot(float3(_810, _811, _812), float3(_810, _811, _812)));
      float _815 = _814 * _810;
      float _816 = _814 * _811;
      float _817 = _814 * _812;
      float _819 = dot(float3(_493, _494, _495), float3(_513, _514, _515));
      float _821 = saturate(dot(float3(_493, _494, _495), float3(_815, _816, _817)));
      float _822 = saturate(dot(float3(_493, _494, _495), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
      float _823 = cornea_roughness * cornea_roughness;
      float _824 = _823 * _823;
      float _828 = ((_821 * _821) * (_824 + -1.0f)) + 1.0f;
      float _832 = abs(_819);
      float _836 = saturate(1.0f - abs(dot(float3(_815, _816, _817), float3(_513, _514, _515))));
      float _837 = _836 * _836;
      [branch]
      if (cb12_221z > 0.0f) {
        float _855 = saturate(_819);
        float _858 = (_822 * 2.0f) * _855;
        _877 = ((((_855 + _822) - _858) * _823) + _858);
      } else {
        float _863 = 1.0f - _824;
        _877 = (((sqrt(((_832 * _832) * _863) + _824) * _822) + 9.999999747378752e-05f) + (sqrt(((_822 * _822) * _863) + _824) * _832));
      }
      float _878 = 0.5f / _877;
      float _880 = (((((((_837 * _837) * _836) * cb13_066x) * max(0.0f, _691)) / ((cb13_066z + 1.0f) - (cb13_066z * (1.0f - cornea_roughness)))) + _467) * (_824 / ((_828 * _828) * 3.1415200233459473f))) * _878;
      if (improved_pbr) {
        float grazing5 = _836 * _836;
        grazing5 *= grazing5 * _836;
        _880 = GraphicsDirectGGX(_821, _819, _822, cornea_roughness)
            * (_467 + grazing5 * cb13_066x * max(0.f, _691)
                / ((cb13_066z + 1.f) - cb13_066z * (1.f - cornea_roughness)));
      }
      if (cb12_221y > 0.0f) {
        float4 _887 = t43.SampleLevel(s10, float2(cornea_roughness, dot(float3(_493, _494, _495), float3(_878, _878, _878))), 0.0f);
        float _891 = (_887.x * _467) + _887.y;
        _904 = ((min((_891 / max((1.0f - ((1.0f - _891) * ((_691 * 0.0476190485060215f) + _467))), 0.0010000000474974513f)), 1.0f) / max(_891, 9.999999747378752e-05f)) * _880);
      } else {
        _904 = _880;
      }
      _909 = (_904 * _822);
      _910 = (_904 * _822);
      _911 = (_904 * _822);
    } else {
      _909 = 0.0f;
      _910 = 0.0f;
      _911 = 0.0f;
    }
    _919 = ((_797 * graphics_sun_visibility) * _909);
    _920 = ((_798 * graphics_sun_visibility) * _910);
    _921 = ((_799 * graphics_sun_visibility) * _911);
    _922 = ((select(_746, (_742 * 0.31830987334251404f), _742) * _800) * _797);
    _923 = ((select(_746, (_743 * 0.31830987334251404f), _743) * _800) * _798);
    _924 = ((select(_746, (_744 * 0.31830987334251404f), _744) * _800) * _799);
    _925 = _685;
    _926 = _686;
    _927 = _687;
  } else {
    _919 = 0.0f;
    _920 = 0.0f;
    _921 = 0.0f;
    _922 = 0.0f;
    _923 = 0.0f;
    _924 = 0.0f;
    _925 = 0.0f;
    _926 = 0.0f;
    _927 = 0.0f;
  }
  if (any(water_light.direct != 1.f)) {
    float3 environment = GraphicsEyeSunEnvironment(float3(_488, _489, _490), float3(_513, _514, _515),
        float3(cb13_000x, cb13_000y, cb13_000z), float3(_477, _478, _479), _463, _485, cb4_021x, _517.y);
    _925 = environment.x; _926 = environment.y; _927 = environment.z;
  }
  float _928 = min(_925, _517.y);
  float _929 = min(_926, _517.y);
  float _930 = min(_927, _517.y);
  uint4 _932 = 0u; t60.GetDimensions(0u, _932.x, _932.y, _932.z, _932.w);
  if ((int)((uint)_461 < (uint)(int)(_932.x)) && (int)((uint)_462 < (uint)(int)(_932.y))) {
    int _940 = min((int)(_932.z), 8);
    if (!(_940 == 0)) {
      uint _943 = t60.Load(int4(_461, _462, 0, 0));
      _946 = _943.x;
    } else {
      _946 = 0;
    }
    if ((uint)_940 > (uint)1) {
      uint _949 = t60.Load(int4(_461, _462, 1, 0));
      _952 = _949.x;
    } else {
      _952 = 0;
    }
    if ((uint)_940 > (uint)2) {
      uint _955 = t60.Load(int4(_461, _462, 2, 0));
      _958 = _955.x;
    } else {
      _958 = 0;
    }
    if ((uint)_940 > (uint)3) {
      uint _961 = t60.Load(int4(_461, _462, 3, 0));
      _964 = _961.x;
    } else {
      _964 = 0;
    }
    if ((uint)_940 > (uint)4) {
      uint _967 = t60.Load(int4(_461, _462, 4, 0));
      _970 = _967.x;
    } else {
      _970 = 0;
    }
    if ((uint)_940 > (uint)5) {
      uint _973 = t60.Load(int4(_461, _462, 5, 0));
      _976 = _973.x;
    } else {
      _976 = 0;
    }
    if ((uint)_940 > (uint)6) {
      uint _979 = t60.Load(int4(_461, _462, 6, 0));
      _982 = _979.x;
    } else {
      _982 = 0;
    }
    if ((uint)_940 > (uint)7) {
      uint _985 = t60.Load(int4(_461, _462, 7, 0));
      _988 = _964;
      _989 = _958;
      _990 = _952;
      _991 = _946;
      _992 = _985.x;
      _993 = _982;
      _994 = _976;
      _995 = _970;
      _996 = _940;
    } else {
      _988 = _964;
      _989 = _958;
      _990 = _952;
      _991 = _946;
      _992 = 0;
      _993 = _982;
      _994 = _976;
      _995 = _970;
      _996 = _940;
    }
  } else {
    _988 = 0;
    _989 = 0;
    _990 = 0;
    _991 = 0;
    _992 = 0;
    _993 = 0;
    _994 = 0;
    _995 = 0;
    _996 = 0;
  }
  _998 = _922;
  _999 = _923;
  _1000 = _924;
  _1001 = _919;
  _1002 = _920;
  _1003 = _921;
  _1004 = 0;
  while(true) {
    int4 _1008 = asint(t20.Load4(((int)(((uint)(_1004 + ((int)(((int(cb12_024x) * ((uint)(_462) >> 4)) + ((uint)((uint)(_461) >> 4))) << 8u)))) << 2u))));
    [branch]
    if (!((uint)_1008.x > (uint)255)) {
      uint _1012 = _1008.x * 10;
      float _1018 = (cb13_raw[((int)(_1012 + 68u))].x) - TEXCOORD_2.x;
      float _1019 = (cb13_raw[((int)(_1012 + 68u))].y) - TEXCOORD_2.y;
      float _1020 = (cb13_raw[((int)(_1012 + 68u))].z) - TEXCOORD_2.z;
      uint _1021 = (uint)(_1008.x) + 1u;
      if (!(_996 == 0)) {
        if (!((_991 & 511) == _1021)) {
          if (!((uint)_996 < (uint)2)) {
            if (!((_990 & 511) == _1021)) {
              if (!((uint)_996 < (uint)3)) {
                if (!((_989 & 511) == _1021)) {
                  if (!((uint)_996 < (uint)4)) {
                    if (!((_988 & 511) == _1021)) {
                      if (!((uint)_996 < (uint)5)) {
                        if (!((_995 & 511) == _1021)) {
                          if (!((uint)_996 < (uint)6)) {
                            if (!((_994 & 511) == _1021)) {
                              if (!((uint)_996 < (uint)7)) {
                                if (!((_993 & 511) == _1021)) {
                                  if ((int)((uint)_996 > (uint)7) && (int)((_992 & 511) == _1021)) {
                                    _1062 = _992;
                                    _1068 = (float((uint)((uint)(((uint)(_1062) >> 9) & 127))) * 0.007874015718698502f);
                                    _1069 = true;
                                  } else {
                                    _1068 = 1.0f;
                                    _1069 = false;
                                  }
                                } else {
                                  _1062 = _993;
                                  _1068 = (float((uint)((uint)(((uint)(_1062) >> 9) & 127))) * 0.007874015718698502f);
                                  _1069 = true;
                                }
                              } else {
                                _1068 = 1.0f;
                                _1069 = false;
                              }
                            } else {
                              _1062 = _994;
                              _1068 = (float((uint)((uint)(((uint)(_1062) >> 9) & 127))) * 0.007874015718698502f);
                              _1069 = true;
                            }
                          } else {
                            _1068 = 1.0f;
                            _1069 = false;
                          }
                        } else {
                          _1062 = _995;
                          _1068 = (float((uint)((uint)(((uint)(_1062) >> 9) & 127))) * 0.007874015718698502f);
                          _1069 = true;
                        }
                      } else {
                        _1068 = 1.0f;
                        _1069 = false;
                      }
                    } else {
                      _1062 = _988;
                      _1068 = (float((uint)((uint)(((uint)(_1062) >> 9) & 127))) * 0.007874015718698502f);
                      _1069 = true;
                    }
                  } else {
                    _1068 = 1.0f;
                    _1069 = false;
                  }
                } else {
                  _1062 = _989;
                  _1068 = (float((uint)((uint)(((uint)(_1062) >> 9) & 127))) * 0.007874015718698502f);
                  _1069 = true;
                }
              } else {
                _1068 = 1.0f;
                _1069 = false;
              }
            } else {
              _1062 = _990;
              _1068 = (float((uint)((uint)(((uint)(_1062) >> 9) & 127))) * 0.007874015718698502f);
              _1069 = true;
            }
          } else {
            _1068 = 1.0f;
            _1069 = false;
          }
        } else {
          _1062 = _991;
          _1068 = (float((uint)((uint)(((uint)(_1062) >> 9) & 127))) * 0.007874015718698502f);
          _1069 = true;
        }
      } else {
        _1068 = 1.0f;
        _1069 = false;
      }
      float _1075 = sqrt(((_1018 * _1018) + (_1019 * _1019)) + (_1020 * _1020));
      float _1082 = _1075 / (cb13_raw[((int)(_1012 + 68u))].w);
      float _1083 = _1082 * _1082;
      float _1086 = saturate(1.0f - (_1083 * _1083));
      int _1091 = asint((cb13_raw[((int)(_1012 + 71u))].w));
      bool _1093 = ((_1091 & 1) != 0);
      bool _1095 = ((cb13_raw[((int)(_1012 + 73u))].z) > 0.0f);
      int _1103 = asint((cb13_raw[((int)(_1012 + 77u))].x));
      bool _1105 = ((_1103 & 1) != 0);
      float _1107 = (_1086 * _1086) / (((_1075 * _1075) * (cb13_raw[((int)(_1012 + 73u))].x)) + 1.0f);
      if (_1093) {
        float _1115 = rsqrt(dot(float3(_1018, _1019, _1020), float3(_1018, _1019, _1020)));
        _1136 = (exp2(log2(saturate(((cb13_raw[((int)(_1012 + 72u))].y) * dot(float3((-0.0f - (_1018 * _1115)), (-0.0f - (_1019 * _1115)), (-0.0f - (_1020 * _1115))), float3((cb13_raw[((int)(_1012 + 70u))].x), (cb13_raw[((int)(_1012 + 70u))].y), (cb13_raw[((int)(_1012 + 70u))].z)))) + (cb13_raw[((int)(_1012 + 72u))].z))) * (cb13_raw[((int)(_1012 + 72u))].w)) * _1107);
      } else {
        _1136 = _1107;
      }
      bool _1137 = (_1136 > 0.0f);
      if (_1069 && _1137) {
        _1142 = saturate(_1068);
      } else {
        _1142 = 1.0f;
      }
      if (((int)(_1095 || _1105)) && _1137) {
        float _1146 = -0.0f - _1018;
        float _1147 = -0.0f - _1019;
        float _1148 = -0.0f - _1020;
        if (_1093) {
          _1343 = mad((((cb13_raw[((int)(_1012 + 75u))].z) * (cb13_raw[((int)(_1012 + 70u))].x)) - ((cb13_raw[((int)(_1012 + 75u))].y) * (cb13_raw[((int)(_1012 + 70u))].y))), _1148, mad((((cb13_raw[((int)(_1012 + 75u))].y) * (cb13_raw[((int)(_1012 + 70u))].z)) - ((cb13_raw[((int)(_1012 + 75u))].w) * (cb13_raw[((int)(_1012 + 70u))].x))), _1147, ((((cb13_raw[((int)(_1012 + 75u))].w) * (cb13_raw[((int)(_1012 + 70u))].y)) - ((cb13_raw[((int)(_1012 + 75u))].z) * (cb13_raw[((int)(_1012 + 70u))].z))) * _1146)));
          _1344 = mad((cb13_raw[((int)(_1012 + 75u))].w), _1148, mad((cb13_raw[((int)(_1012 + 75u))].z), _1147, ((cb13_raw[((int)(_1012 + 75u))].y) * _1146)));
          _1345 = mad((cb13_raw[((int)(_1012 + 70u))].z), _1148, mad((cb13_raw[((int)(_1012 + 70u))].y), _1147, ((cb13_raw[((int)(_1012 + 70u))].x) * _1146)));
          _1346 = (cb13_raw[((int)(_1012 + 75u))].x);
          _1347 = asint((cb13_raw[((int)(_1012 + 77u))].z));
        } else {
          if (_1105) {
            float _1204 = mad((((cb13_raw[((int)(_1012 + 70u))].x) * (cb13_raw[((int)(_1012 + 72u))].z)) - ((cb13_raw[((int)(_1012 + 70u))].y) * (cb13_raw[((int)(_1012 + 72u))].y))), _1148, mad((((cb13_raw[((int)(_1012 + 70u))].z) * (cb13_raw[((int)(_1012 + 72u))].y)) - ((cb13_raw[((int)(_1012 + 70u))].x) * (cb13_raw[((int)(_1012 + 72u))].w))), _1147, ((((cb13_raw[((int)(_1012 + 70u))].y) * (cb13_raw[((int)(_1012 + 72u))].w)) - ((cb13_raw[((int)(_1012 + 70u))].z) * (cb13_raw[((int)(_1012 + 72u))].z))) * _1146)));
            float _1207 = mad((cb13_raw[((int)(_1012 + 70u))].z), _1148, mad((cb13_raw[((int)(_1012 + 70u))].y), _1147, ((cb13_raw[((int)(_1012 + 70u))].x) * _1146)));
            float _1210 = mad((cb13_raw[((int)(_1012 + 72u))].w), _1148, mad((cb13_raw[((int)(_1012 + 72u))].z), _1147, ((cb13_raw[((int)(_1012 + 72u))].y) * _1146)));
            float _1211 = -0.0f - _1204;
            float _1212 = -0.0f - _1207;
            float _1213 = -0.0f - _1210;
            float _1214 = _1211 / _1075;
            float _1215 = _1212 / _1075;
            float _1216 = _1213 / _1075;
            float _1217 = abs(_1214);
            float _1218 = abs(_1215);
            float _1219 = abs(_1216);
            bool _1223 = (_1217 > max(_1218, _1219));
            if (!((_1103 & 4) == 0)) {
              if (_1223) {
                if (_1214 > 0.0f) {
                  _1253 = _1207;
                  _1254 = _1210;
                  _1255 = _1211;
                  _1256 = (cb13_raw[((int)(_1012 + 75u))].x);
                } else {
                  _1253 = _1212;
                  _1254 = _1210;
                  _1255 = _1204;
                  _1256 = (cb13_raw[((int)(_1012 + 75u))].y);
                }
              } else {
                if (_1218 > max(_1217, _1219)) {
                  if (_1215 > 0.0f) {
                    _1253 = _1211;
                    _1254 = _1210;
                    _1255 = _1212;
                    _1256 = (cb13_raw[((int)(_1012 + 75u))].z);
                  } else {
                    _1253 = _1204;
                    _1254 = _1210;
                    _1255 = _1207;
                    _1256 = (cb13_raw[((int)(_1012 + 75u))].w);
                  }
                } else {
                  if (_1216 > 0.0f) {
                    _1253 = _1204;
                    _1254 = _1207;
                    _1255 = _1213;
                    _1256 = (cb13_raw[((int)(_1012 + 76u))].x);
                  } else {
                    _1253 = _1204;
                    _1254 = _1212;
                    _1255 = _1210;
                    _1256 = (cb13_raw[((int)(_1012 + 76u))].y);
                  }
                }
              }
              _1343 = _1253;
              _1344 = _1254;
              _1345 = _1255;
              _1346 = _1256;
              _1347 = asint((cb13_raw[((int)(_1012 + 77u))].z));
            } else {
              if (_1223) {
                int _1265 = asint((cb13_raw[((int)(_1012 + 77u))].z));
                if (_1214 > 0.0f) {
                  _1343 = _1207;
                  _1344 = _1210;
                  _1345 = _1211;
                  _1346 = (cb13_raw[((int)(_1012 + 75u))].x);
                  _1347 = _1265;
                } else {
                  _1343 = _1212;
                  _1344 = _1210;
                  _1345 = _1204;
                  _1346 = (cb13_raw[((int)(_1012 + 75u))].y);
                  _1347 = ((uint)(_1265) >> 10);
                }
              } else {
                if (_1218 > max(_1217, _1219)) {
                  if (_1215 > 0.0f) {
                    _1343 = _1211;
                    _1344 = _1210;
                    _1345 = _1212;
                    _1346 = (cb13_raw[((int)(_1012 + 75u))].z);
                    _1347 = ((uint)((uint)(asint((cb13_raw[((int)(_1012 + 77u))].z)))) >> 20);
                  } else {
                    _1343 = _1204;
                    _1344 = _1210;
                    _1345 = _1207;
                    _1346 = (cb13_raw[((int)(_1012 + 75u))].w);
                    _1347 = asint((cb13_raw[((int)(_1012 + 77u))].w));
                  }
                } else {
                  int _1292 = asint((cb13_raw[((int)(_1012 + 77u))].w));
                  if (_1216 > 0.0f) {
                    _1343 = _1204;
                    _1344 = _1207;
                    _1345 = _1213;
                    _1346 = (cb13_raw[((int)(_1012 + 76u))].x);
                    _1347 = ((uint)(_1292) >> 10);
                  } else {
                    _1343 = _1204;
                    _1344 = _1212;
                    _1345 = _1210;
                    _1346 = (cb13_raw[((int)(_1012 + 76u))].y);
                    _1347 = ((uint)(_1292) >> 20);
                  }
                }
              }
            }
          } else {
            float _1300 = _1018 / _1075;
            float _1301 = _1019 / _1075;
            float _1302 = _1020 / _1075;
            float _1303 = abs(_1300);
            float _1304 = abs(_1301);
            float _1305 = abs(_1302);
            if (_1303 > max(_1304, _1305)) {
              if (_1300 > 0.0f) {
                _1336 = _1147;
                _1337 = _1148;
                _1338 = _1018;
                _1339 = (cb13_raw[((int)(_1012 + 75u))].x);
              } else {
                _1336 = _1019;
                _1337 = _1148;
                _1338 = _1146;
                _1339 = (cb13_raw[((int)(_1012 + 75u))].y);
              }
            } else {
              if (_1304 > max(_1303, _1305)) {
                if (_1301 > 0.0f) {
                  _1336 = _1018;
                  _1337 = _1148;
                  _1338 = _1019;
                  _1339 = (cb13_raw[((int)(_1012 + 75u))].z);
                } else {
                  _1336 = _1146;
                  _1337 = _1148;
                  _1338 = _1147;
                  _1339 = (cb13_raw[((int)(_1012 + 75u))].w);
                }
              } else {
                if (_1302 > 0.0f) {
                  _1336 = _1146;
                  _1337 = _1147;
                  _1338 = _1020;
                  _1339 = (cb13_raw[((int)(_1012 + 76u))].x);
                } else {
                  _1336 = _1146;
                  _1337 = _1019;
                  _1338 = _1148;
                  _1339 = (cb13_raw[((int)(_1012 + 76u))].y);
                }
              }
            }
            _1343 = _1336;
            _1344 = _1337;
            _1345 = _1338;
            _1346 = _1339;
            _1347 = asint((cb13_raw[((int)(_1012 + 77u))].z));
          }
        }
        float _1355 = (((_1343 * (cb13_raw[((int)(_1012 + 73u))].y)) / _1345) * 0.5f) + 0.5f;
        float _1356 = 0.5f - ((mad((cb13_raw[((int)(_1012 + 73u))].y), _1344, 0.0f) / _1345) * 0.5f);
        if (_1095) {
          int _1358 = asint(_1346);
          int _1360 = ((uint)(_1358) >> 18) & 4092;
          float _1361 = float((uint)_1360);
          [branch]
          if (!(_1360 == 0)) {
            if (!_1069) {
              float _1383 = t9.SampleLevel(s10, float3((cb13_067x * ((_1355 * _1361) + float((uint)((uint)(((int)(_1358 << 2u)) & 4092))))), (cb13_067x * ((_1356 * _1361) + float((uint)((uint)(((uint)(_1358) >> 8) & 4092))))), float((uint)((uint)((uint)(_1358) >> 30)))), 0.0f);
              _1392 = (saturate(exp2((_1383.x - (_1082 * 0.9900000095367432f)) * 144.26950073242188f)) * _1142);
            } else {
              _1392 = _1142;
            }
          } else {
            _1392 = _1142;
          }
        } else {
          _1392 = _1142;
        }
        if (_1105) {
          bool _1395 = ((_1103 & 2) != 0);
          if (_1395) {
            _1405 = (_1347 & 1023);
            _1406 = 0;
          } else {
            _1405 = (_1347 & 255);
            _1406 = (((uint)(_1347) >> 8) & 3);
          }
          float _1410 = floor(cb13_raw[((int)(_1012 + 77u))].y) + float((uint)_1405);
          float4 _1414 = t42.SampleLevel(s10, float3(_1355, _1356, _1410), 0.0f);
          _48[0] = _1414.x;
          _48[1] = _1414.y;
          _48[2] = _1414.z;
          _48[3] = _1414.w;
          if (!((_1103 & 8) == 0)) {
            float4 _1425 = t42.SampleLevel(s10, float3(_1355, _1356, (_1410 + 1.0f)), 0.0f);
            float _1430 = frac(cb13_raw[((int)(_1012 + 77u))].y);
            float _1439 = ((_1425.x - _1414.x) * _1430) + _1414.x;
            float _1440 = ((_1425.y - _1414.y) * _1430) + _1414.y;
            float _1441 = ((_1425.z - _1414.z) * _1430) + _1414.z;
            _48[0] = _1439;
            _48[1] = _1440;
            _48[2] = _1441;
            _48[3] = (lerp(_1414.w, _1425.w, _1430));
            _1444 = _1441;
            _1445 = _1440;
            _1446 = _1439;
          } else {
            _1444 = _1414.z;
            _1445 = _1414.y;
            _1446 = _1414.x;
          }
          if (!_1395) {
            float _1449 = _48[_1406];
            _1451 = _1449;
            _1452 = _1449;
            _1453 = _1449;
          } else {
            _1451 = _1446;
            _1452 = _1445;
            _1453 = _1444;
          }
          _1455 = _1392;
          _1456 = _1451;
          _1457 = _1452;
          _1458 = _1453;
        } else {
          _1455 = _1392;
          _1456 = 1.0f;
          _1457 = 1.0f;
          _1458 = 1.0f;
        }
      } else {
        _1455 = _1142;
        _1456 = 1.0f;
        _1457 = 1.0f;
        _1458 = 1.0f;
      }
      if ((int)((cb13_raw[((int)(_1012 + 74u))].x) > 0.0f) && _1137) {
        if (!_1069) {
          float _1465 = t10.SampleLevel(s10, float4(_1018, _1019, _1020, (cb13_raw[((int)(_1012 + 74u))].y)), 0.0f);
          _1475 = (saturate(exp2((_1465.x - (_1082 * 0.9900000095367432f)) * 144.26950073242188f)) * _1455);
          _1478 = _1475;
          _1479 = (cb13_raw[((int)(_1012 + 73u))].w);
        } else {
          _1478 = _1455;
          _1479 = 1.0f;
        }
      } else {
        if (!_1069) {
          _1475 = _1455;
          _1478 = _1475;
          _1479 = (cb13_raw[((int)(_1012 + 73u))].w);
        } else {
          _1478 = _1455;
          _1479 = 1.0f;
        }
      }
      if ((int)(_517.z == 1.0f) || (int)((_1091 & 2048) != 0)) {
        _1491 = cb12_071y;
      } else {
        _1491 = 0.0f;
      }
      if (((int)(!(_517.z == 1.0f))) || (int)((_1091 & 4096) != 0)) {
        _1500 = cb12_071z;
      } else {
        _1500 = 0.0f;
      }
      [branch]
      if (!((CustomPixelConsts_336[3].y) == 0.0f)) {
        float _1517 = ((CustomPixelConsts_336[0].z) * cb4_023x) + (CustomPixelConsts_336[0].y);
        float _1518 = ((CustomPixelConsts_336[1].z) * cb4_023x) + (CustomPixelConsts_336[1].y);
        float _1519 = ((CustomPixelConsts_336[2].z) * cb4_023x) + (CustomPixelConsts_336[2].y);
        float _1520 = TEXCOORD_2.x - _1517;
        float _1521 = TEXCOORD_2.y - _1518;
        float _1522 = TEXCOORD_2.z - _1519;
        float _1524 = rsqrt(dot(float3(_1520, _1521, _1522), float3(_1520, _1521, _1522)));
        float _1528 = (cb13_raw[((int)(_1012 + 68u))].x) - _1517;
        float _1529 = (cb13_raw[((int)(_1012 + 68u))].y) - _1518;
        float _1530 = (cb13_raw[((int)(_1012 + 68u))].z) - _1519;
        float _1532 = rsqrt(dot(float3(_1528, _1529, _1530), float3(_1528, _1529, _1530)));
        _1543 = saturate(((0.699999988079071f - cb4_022x) + (dot(float3((_1520 * _1524), (_1521 * _1524), (_1522 * _1524)), float3((_1532 * _1528), (_1532 * _1529), (_1530 * _1532))) * 0.5f)) * 5.0f);
      } else {
        _1543 = 1.0f;
      }
      float _1547 = _1543 * (((((_1479 * (_1478 + -1.0f)) + 1.0f) * _1136) * _1491) * _1500);
      float _1548 = _1547 * _1456;
      float _1549 = _1547 * _1457;
      float _1550 = _1547 * _1458;
      [branch]
      if ((int)(_1550 > 0.0f) || ((int)((int)(_1548 > 0.0f) || (int)(_1549 > 0.0f)))) {
        if (!(FrequentPixelConsts_256.x < 0.0f)) {
          _1564 = cb12_071x;
        } else {
          _1564 = 1.0f;
        }
        float _1566 = select(((int)_1091 < (int)0), _1564, 1.0f);
        float _1571 = rsqrt(dot(float3(_1018, _1019, _1020), float3(_1018, _1019, _1020)));
        float _1572 = _1571 * _1018;
        float _1573 = _1571 * _1019;
        float _1574 = _1571 * _1020;
        if (_485 == 1) {
          int _1579 = ((int)(uint)((int)(_490 > 0.0f))) << 1u;
          float _1581 = float((int)(_1579 + -1));
          float _1583 = -1.0f / (_1581 + _490);
          float _1585 = (_488 * _489) * _1583;
          float _1589 = (((_488 * _488) * _1581) * _1583) + 1.0f;
          float _1590 = _1585 * _1581;
          float _1593 = float((int)(1 - _1579)) * _488;
          float _1596 = ((_489 * _489) * _1583) + _1581;
          float _1597 = -0.0f - _489;
          float _1599 = rsqrt(dot(float3(_1572, _1573, _1574), float3(_1572, _1573, _1574)));
          float _1600 = _1599 * _1572;
          float _1601 = _1599 * _1573;
          float _1602 = _1599 * _1574;
          float _1605 = mad(_1593, _1602, mad(_1590, _1601, (_1600 * _1589)));
          float _1608 = mad(_1597, _1602, mad(_1596, _1601, (_1600 * _1585)));
          float _1611 = mad(_490, _1602, mad(_489, _1601, (_1600 * _488)));
          float _1613 = rsqrt(dot(float3(_1605, _1608, _1611), float3(_1605, _1608, _1611)));
          float _1616 = _1613 * _1611;
          float _1618 = rsqrt(dot(float3(_513, _514, _515), float3(_513, _514, _515)));
          float _1619 = _1618 * _513;
          float _1620 = _1618 * _514;
          float _1621 = _1618 * _515;
          float _1624 = mad(_1593, _1621, mad(_1590, _1620, (_1619 * _1589)));
          float _1627 = mad(_1597, _1621, mad(_1596, _1620, (_1619 * _1585)));
          float _1630 = mad(_490, _1621, mad(_489, _1620, (_1619 * _488)));
          float _1632 = rsqrt(dot(float3(_1624, _1627, _1630), float3(_1624, _1627, _1630)));
          float _1635 = _1632 * _1630;
          float _1636 = iris_roughness * iris_roughness;
          float _1639 = dot(float3((_1613 * _1605), (_1613 * _1608), _1616), float3((_1632 * _1624), (_1632 * _1627), _1635)) - (_1635 * _1616);
          if (_1639 > 0.0f) {
            _1652 = (_1639 / max(_1616, _1635));
          } else {
            _1652 = _1639;
          }
          float _1654 = (_1636 * 0.2877933979034424f) + 1.0f;
          float _1655 = 1.0f / _1654;
          float _1659 = ((_1652 * _1636) + 1.0f) * (_1655 * 0.31830987334251404f);
          float _1663 = 1.0f - _1635;
          float _1674 = 1.0f - _1616;
          float _1687 = _1655 * ((_1636 * 0.07248824834823608f) + 1.0f);
          float _1694 = 1.0f - _1687;
          float _1709 = max(1.0000000116860974e-07f, (1.0f - ((((_1674 * _1636) * ((((((_1674 * 0.07144299894571304f) + -0.332181453704834f) * _1674) + 0.4918818771839142f) * _1674) + 0.05710852891206741f)) + 1.0f) / _1654))) * (max(1.0000000116860974e-07f, (1.0f - ((((_1663 * _1636) * ((((((_1663 * 0.07144299894571304f) + -0.332181453704834f) * _1663) + 0.4918818771839142f) * _1663) + 0.05710852891206741f)) + 1.0f) / _1654))) * 0.31830987334251404f);
          float _1713 = max(1.0000000116860974e-07f, _1694);
          float _1721 = saturate(dot(float3(_488, _489, _490), float3(_1572, _1573, _1574)));
          _1726 = (_1721 * (((_1709 * (((_477 * _477) * _1687) / (1.0f - (_1694 * _477)))) / _1713) + (_1659 * _477)));
          _1727 = (_1721 * (((_1709 * (((_478 * _478) * _1687) / (1.0f - (_1694 * _478)))) / _1713) + (_1659 * _478)));
          _1728 = (_1721 * (((_1709 * (((_479 * _479) * _1687) / (1.0f - (_1694 * _479)))) / _1713) + (_1659 * _479)));
          _1729 = 1.0f;
        } else {
          float _1647 = cb4_021x + 1.0f;
          float _1650 = saturate((dot(float3(_488, _489, _490), float3(_1572, _1573, _1574)) + cb4_021x) / _1647);
          _1726 = _1650;
          _1727 = _1650;
          _1728 = _1650;
          _1729 = (1.0f / _1647);
        }
        // Iris response uses its refracted normal; cornea highlights remain separate.
        if (improved_pbr) {
          float3 diffuse = GraphicsForwardDiffuse(float3(_488, _489, _490), float3(_513, _514, _515),
              float3(_1572, _1573, _1574), iris_roughness, float3(_477, _478, _479), _485, _1726);
          _1726 = diffuse.x; _1727 = diffuse.y; _1728 = diffuse.z;
        }
        float _1733 = 1.0f - _467;
        if (cb12_221x > 0.0f) {
          float4 _1738 = t43.SampleLevel(s10, float2(iris_roughness, dot(float3(_488, _489, _490), float3(_513, _514, _515))), 0.0f);
          float _1742 = (_1738.x * _467) + _1738.y;
          _1780 = min((_1742 / max((1.0f - ((1.0f - _1742) * ((_1733 * 0.0476190485060215f) + _467))), 0.0010000000474974513f)), 1.0f);
        } else {
          float _1752 = _1572 + _513;
          float _1753 = _1573 + _514;
          float _1754 = _1574 + _515;
          float _1756 = rsqrt(dot(float3(_1752, _1753, _1754), float3(_1752, _1753, _1754)));
          float _1763 = saturate(1.0f - abs(dot(float3((_1756 * _1752), (_1756 * _1753), (_1756 * _1754)), float3(_513, _514, _515))));
          float _1764 = _1763 * _1763;
          _1780 = ((((((_1764 * _1764) * _1763) * cb13_066x) * max(0.0f, _1733)) / ((cb13_066z + 1.0f) - (cb13_066z * (1.0f - iris_roughness)))) + _467);
        }
        float _1784 = (1.0f - _1780) * _1726;
        float _1785 = (1.0f - _1780) * _1727;
        float _1786 = (1.0f - _1780) * _1728;
        bool _1788 = ((_485 & -3) == 0);
        float _1798 = (_1566 * _1548) * (cb13_raw[((int)(_1012 + 71u))].x);
        float _1801 = (_1566 * _1549) * (cb13_raw[((int)(_1012 + 71u))].y);
        float _1804 = (_1566 * _1550) * (cb13_raw[((int)(_1012 + 71u))].z);
        [branch]
        if (dot(float3(_1572, _1573, _1574), float3(_493, _494, _495)) > 0.0f) {
          float _1813 = _1572 + _513;
          float _1814 = _1573 + _514;
          float _1815 = _1574 + _515;
          float _1817 = rsqrt(dot(float3(_1813, _1814, _1815), float3(_1813, _1814, _1815)));
          float _1818 = _1817 * _1813;
          float _1819 = _1817 * _1814;
          float _1820 = _1817 * _1815;
          float _1822 = dot(float3(_493, _494, _495), float3(_513, _514, _515));
          float _1824 = saturate(dot(float3(_493, _494, _495), float3(_1818, _1819, _1820)));
          float _1825 = saturate(dot(float3(_493, _494, _495), float3(_1572, _1573, _1574)));
          float _1826 = cornea_roughness * cornea_roughness;
          float _1827 = _1826 * _1826;
          float _1831 = ((_1824 * _1824) * (_1827 + -1.0f)) + 1.0f;
          float _1835 = abs(_1822);
          float _1839 = saturate(1.0f - abs(dot(float3(_1818, _1819, _1820), float3(_513, _514, _515))));
          float _1840 = _1839 * _1839;
          [branch]
          if (cb12_221z > 0.0f) {
            float _1858 = saturate(_1822);
            float _1861 = (_1825 * 2.0f) * _1858;
            _1880 = ((((_1858 + _1825) - _1861) * _1826) + _1861);
          } else {
            float _1866 = 1.0f - _1827;
            _1880 = (((sqrt(((_1835 * _1835) * _1866) + _1827) * _1825) + 9.999999747378752e-05f) + (sqrt(((_1825 * _1825) * _1866) + _1827) * _1835));
          }
          float _1881 = 0.5f / _1880;
          float _1883 = (((((((_1840 * _1840) * _1839) * cb13_066x) * max(0.0f, _1733)) / ((cb13_066z + 1.0f) - (cb13_066z * (1.0f - cornea_roughness)))) + _467) * (_1827 / ((_1831 * _1831) * 3.1415200233459473f))) * _1881;
          if (improved_pbr) {
            float grazing5 = _1839 * _1839;
            grazing5 *= grazing5 * _1839;
            _1883 = GraphicsDirectGGX(_1824, _1822, _1825, cornea_roughness)
                * (_467 + grazing5 * cb13_066x * max(0.f, _1733)
                    / ((cb13_066z + 1.f) - cb13_066z * (1.f - cornea_roughness)));
          }
          if (cb12_221y > 0.0f) {
            float4 _1890 = t43.SampleLevel(s10, float2(cornea_roughness, dot(float3(_493, _494, _495), float3(_1881, _1881, _1881))), 0.0f);
            float _1894 = (_1890.x * _467) + _1890.y;
            _1907 = ((min((_1894 / max((1.0f - ((1.0f - _1894) * ((_1733 * 0.0476190485060215f) + _467))), 0.0010000000474974513f)), 1.0f) / max(_1894, 9.999999747378752e-05f)) * _1883);
          } else {
            _1907 = _1883;
          }
          _1912 = (_1907 * _1825);
          _1913 = (_1907 * _1825);
          _1914 = (_1907 * _1825);
        } else {
          _1912 = 0.0f;
          _1913 = 0.0f;
          _1914 = 0.0f;
        }
        _1922 = (((_1798 * _1729) * select(_1788, (_1784 * 0.31830987334251404f), _1784)) + _998);
        _1923 = (((_1801 * _1729) * select(_1788, (_1785 * 0.31830987334251404f), _1785)) + _999);
        _1924 = (((_1804 * _1729) * select(_1788, (_1786 * 0.31830987334251404f), _1786)) + _1000);
        _1925 = ((_1798 * _1912) + _1001);
        _1926 = ((_1801 * _1913) + _1002);
        _1927 = ((_1804 * _1914) + _1003);
      } else {
        _1922 = _998;
        _1923 = _999;
        _1924 = _1000;
        _1925 = _1001;
        _1926 = _1002;
        _1927 = _1003;
      }
      int _1928 = _1004 + 1;
      if ((int)_1928 < (int)256) {
        _998 = _1922;
        _999 = _1923;
        _1000 = _1924;
        _1001 = _1925;
        _1002 = _1926;
        _1003 = _1927;
        _1004 = _1928;
        continue;
      } else {
        _1931 = _1922;
        _1932 = _1923;
        _1933 = _1924;
        _1934 = _1925;
        _1935 = _1926;
        _1936 = _1927;
      }
    } else {
      _1931 = _998;
      _1932 = _999;
      _1933 = _1000;
      _1934 = _1001;
      _1935 = _1002;
      _1936 = _1003;
    }
    break;
  }
  float _1937 = -0.0f - _513;
  float _1938 = -0.0f - _514;
  float _1939 = -0.0f - _515;
  float _1941 = dot(float3(_1937, _1938, _1939), float3(_493, _494, _495)) * 2.0f;
  float _1945 = _1937 - (_1941 * _493);
  float _1946 = _1938 - (_1941 * _494);
  float _1947 = _1939 - (_1941 * _495);
  float _1952 = min(max(max(((_463 * _463) * 10.5f), 0.0f), 0.0f), 5.0f);
  _1954 = 1;
  _1955 = 0.0f;
  _1956 = 0.0f;
  _1957 = 0.0f;
  _1958 = 9.999999747378752e-06f;
  while(true) {
    int _1959 = _1954 * 12;
    float _1995 = 1.0f - abs(mad((cb12_raw[(_1959 + 104)].x), TEXCOORD_2.z, mad((cb12_raw[(_1959 + 103)].x), TEXCOORD_2.y, ((cb12_raw[(_1959 + 102)].x) * TEXCOORD_2.x))) + (cb12_raw[(_1959 + 105)].x));
    float _1996 = 1.0f - abs(mad((cb12_raw[(_1959 + 104)].y), TEXCOORD_2.z, mad((cb12_raw[(_1959 + 103)].y), TEXCOORD_2.y, ((cb12_raw[(_1959 + 102)].y) * TEXCOORD_2.x))) + (cb12_raw[(_1959 + 105)].y));
    float _1997 = 1.0f - abs(mad((cb12_raw[(_1959 + 104)].z), TEXCOORD_2.z, mad((cb12_raw[(_1959 + 103)].z), TEXCOORD_2.y, ((cb12_raw[(_1959 + 102)].z) * TEXCOORD_2.x))) + (cb12_raw[(_1959 + 105)].z));
    if (((int)((int)(_1995 > 0.0f) && (int)(_1996 > 0.0f))) && (int)(_1997 > 0.0f)) {
      float _2022 = (((saturate((cb12_raw[(_1959 + 101)].x) * _1995) * (1.0f - _1958)) * saturate((cb12_raw[(_1959 + 101)].y) * _1996)) * saturate((cb12_raw[(_1959 + 101)].z) * _1997)) * (cb12_raw[(_1959 + 100)].x);
      float _2027 = _2022 * (cb12_raw[(_1959 + 106)].x);
      float _2072 = 1.0f / mad((cb12_raw[(_1959 + 109)].x), _1947, mad((cb12_raw[(_1959 + 108)].x), _1946, ((cb12_raw[(_1959 + 107)].x) * _1945)));
      float _2073 = 1.0f / mad((cb12_raw[(_1959 + 109)].y), _1947, mad((cb12_raw[(_1959 + 108)].y), _1946, ((cb12_raw[(_1959 + 107)].y) * _1945)));
      float _2074 = 1.0f / mad((cb12_raw[(_1959 + 109)].z), _1947, mad((cb12_raw[(_1959 + 108)].z), _1946, ((cb12_raw[(_1959 + 107)].z) * _1945)));
      float _2075 = _2072 * (mad((cb12_raw[(_1959 + 109)].x), TEXCOORD_2.z, mad((cb12_raw[(_1959 + 108)].x), TEXCOORD_2.y, ((cb12_raw[(_1959 + 107)].x) * TEXCOORD_2.x))) + (cb12_raw[(_1959 + 110)].x));
      float _2076 = _2073 * (mad((cb12_raw[(_1959 + 109)].y), TEXCOORD_2.z, mad((cb12_raw[(_1959 + 108)].y), TEXCOORD_2.y, ((cb12_raw[(_1959 + 107)].y) * TEXCOORD_2.x))) + (cb12_raw[(_1959 + 110)].y));
      float _2077 = _2074 * (mad((cb12_raw[(_1959 + 109)].z), TEXCOORD_2.z, mad((cb12_raw[(_1959 + 108)].z), TEXCOORD_2.y, ((cb12_raw[(_1959 + 107)].z) * TEXCOORD_2.x))) + (cb12_raw[(_1959 + 110)].z));
      float _2091 = min(max((_2072 - _2075), ((-0.0f - _2072) - _2075)), min(max((_2073 - _2076), ((-0.0f - _2073) - _2076)), max((_2074 - _2077), ((-0.0f - _2074) - _2077))));
      float _2096 = (_2091 * _1945) + (TEXCOORD_2.x - (cb12_raw[(_1959 + 100)].y));
      float _2098 = (_2091 * _1946) + (TEXCOORD_2.y - (cb12_raw[(_1959 + 100)].z));
      float _2100 = (_2091 * _1947) + (TEXCOORD_2.z - (cb12_raw[(_1959 + 100)].w));
      float _2102 = rsqrt(dot(float3(_2096, _2098, _2100), float3(_2096, _2098, _2100)));
      float _2103 = _2096 * _2102;
      float _2104 = _2098 * _2102;
      float _2105 = _2100 * _2102;
      bool _2109 = (_2105 < 0.0f);
      float _2115 = min(max((1.0f / (1.0f - _2105)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float _2123 = min(max((1.0f / (_2105 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float4 _2142 = t23.SampleLevel(s11, float2((((float((bool)_2109) + 0.1666666716337204f) + ((select(_2109, ((_2103 * 0.5f) * _2115), ((_2103 * -0.5f) * _2123)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(asint(cb12_raw[(_1959 + 111)].x))) + 0.1666666716337204f) + ((select(_2109, ((_2104 * -0.5f) * _2115), ((_2104 * 0.5f) * _2123)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _1952);
      _2153 = (_2022 + _1958);
      _2154 = ((_2142.x * _2027) + _1957);
      _2155 = ((_2142.y * _2027) + _1956);
      _2156 = ((_2142.z * _2027) + _1955);
    } else {
      _2153 = _1958;
      _2154 = _1957;
      _2155 = _1956;
      _2156 = _1955;
    }
    int _2157 = _1954 + 1;
    _2159 = (_2153 < 0.9990000128746033f);
    if ((int)((uint)_2157 < (uint)7) && _2159) {
      _1954 = _2157;
      _1955 = _2156;
      _1956 = _2155;
      _1957 = _2154;
      _1958 = _2153;
      continue;
    }
    break;
  }
  [branch]
  if (_2159) {
    float _2166 = cb12_100x * (1.0f - _2153);
    float _2170 = _2166 * cb12_106x;
    bool _2173 = (_1947 < 0.0f);
    float _2179 = min(max((1.0f / (1.0f - _1947)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float _2187 = min(max((1.0f / (_1947 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float4 _2206 = t23.SampleLevel(s11, float2((((float((bool)_2173) + 0.1666666716337204f) + ((select(_2173, ((_1945 * 0.5f) * _2179), ((_1945 * -0.5f) * _2187)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(cb12_111x)) + 0.1666666716337204f) + ((select(_2173, ((_1946 * -0.5f) * _2179), ((_1946 * 0.5f) * _2187)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _1952);
    _2217 = (_2166 + _2153);
    _2218 = ((_2206.x * _2170) + _2154);
    _2219 = ((_2206.y * _2170) + _2155);
    _2220 = ((_2206.z * _2170) + _2156);
  } else {
    _2217 = _2153;
    _2218 = _2154;
    _2219 = _2155;
    _2220 = _2156;
  }
  _2222 = 1;
  _2223 = 0.0f;
  _2224 = 0.0f;
  _2225 = 0.0f;
  _2226 = 9.999999747378752e-06f;
  while(true) {
    int _2227 = _2222 * 12;
    float _2263 = 1.0f - abs(mad((cb12_raw[(_2227 + 104)].x), TEXCOORD_2.z, mad((cb12_raw[(_2227 + 103)].x), TEXCOORD_2.y, ((cb12_raw[(_2227 + 102)].x) * TEXCOORD_2.x))) + (cb12_raw[(_2227 + 105)].x));
    float _2264 = 1.0f - abs(mad((cb12_raw[(_2227 + 104)].y), TEXCOORD_2.z, mad((cb12_raw[(_2227 + 103)].y), TEXCOORD_2.y, ((cb12_raw[(_2227 + 102)].y) * TEXCOORD_2.x))) + (cb12_raw[(_2227 + 105)].y));
    float _2265 = 1.0f - abs(mad((cb12_raw[(_2227 + 104)].z), TEXCOORD_2.z, mad((cb12_raw[(_2227 + 103)].z), TEXCOORD_2.y, ((cb12_raw[(_2227 + 102)].z) * TEXCOORD_2.x))) + (cb12_raw[(_2227 + 105)].z));
    if (((int)((int)(_2263 > 0.0f) && (int)(_2264 > 0.0f))) && (int)(_2265 > 0.0f)) {
      float _2290 = (((saturate((cb12_raw[(_2227 + 101)].x) * _2263) * (1.0f - _2226)) * saturate((cb12_raw[(_2227 + 101)].y) * _2264)) * saturate((cb12_raw[(_2227 + 101)].z) * _2265)) * (cb12_raw[(_2227 + 100)].x);
      float _2295 = _2290 * (cb12_raw[(_2227 + 106)].x);
      float _2340 = 1.0f / mad((cb12_raw[(_2227 + 109)].x), _1947, mad((cb12_raw[(_2227 + 108)].x), _1946, ((cb12_raw[(_2227 + 107)].x) * _1945)));
      float _2341 = 1.0f / mad((cb12_raw[(_2227 + 109)].y), _1947, mad((cb12_raw[(_2227 + 108)].y), _1946, ((cb12_raw[(_2227 + 107)].y) * _1945)));
      float _2342 = 1.0f / mad((cb12_raw[(_2227 + 109)].z), _1947, mad((cb12_raw[(_2227 + 108)].z), _1946, ((cb12_raw[(_2227 + 107)].z) * _1945)));
      float _2343 = _2340 * (mad((cb12_raw[(_2227 + 109)].x), TEXCOORD_2.z, mad((cb12_raw[(_2227 + 108)].x), TEXCOORD_2.y, ((cb12_raw[(_2227 + 107)].x) * TEXCOORD_2.x))) + (cb12_raw[(_2227 + 110)].x));
      float _2344 = _2341 * (mad((cb12_raw[(_2227 + 109)].y), TEXCOORD_2.z, mad((cb12_raw[(_2227 + 108)].y), TEXCOORD_2.y, ((cb12_raw[(_2227 + 107)].y) * TEXCOORD_2.x))) + (cb12_raw[(_2227 + 110)].y));
      float _2345 = _2342 * (mad((cb12_raw[(_2227 + 109)].z), TEXCOORD_2.z, mad((cb12_raw[(_2227 + 108)].z), TEXCOORD_2.y, ((cb12_raw[(_2227 + 107)].z) * TEXCOORD_2.x))) + (cb12_raw[(_2227 + 110)].z));
      float _2359 = min(max((_2340 - _2343), ((-0.0f - _2340) - _2343)), min(max((_2341 - _2344), ((-0.0f - _2341) - _2344)), max((_2342 - _2345), ((-0.0f - _2342) - _2345))));
      float _2364 = (_2359 * _1945) + (TEXCOORD_2.x - (cb12_raw[(_2227 + 100)].y));
      float _2366 = (_2359 * _1946) + (TEXCOORD_2.y - (cb12_raw[(_2227 + 100)].z));
      float _2368 = (_2359 * _1947) + (TEXCOORD_2.z - (cb12_raw[(_2227 + 100)].w));
      float _2370 = rsqrt(dot(float3(_2364, _2366, _2368), float3(_2364, _2366, _2368)));
      float _2371 = _2364 * _2370;
      float _2372 = _2366 * _2370;
      float _2373 = _2368 * _2370;
      bool _2377 = (_2373 < 0.0f);
      float _2383 = min(max((1.0f / (1.0f - _2373)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float _2391 = min(max((1.0f / (_2373 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float4 _2410 = t23.SampleLevel(s11, float2((((float((bool)_2377) + 0.1666666716337204f) + ((select(_2377, ((_2371 * 0.5f) * _2383), ((_2371 * -0.5f) * _2391)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(asint(cb12_raw[(_2227 + 111)].x))) + 0.1666666716337204f) + ((select(_2377, ((_2372 * -0.5f) * _2383), ((_2372 * 0.5f) * _2391)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), 5.0f);
      _2421 = (_2290 + _2226);
      _2422 = ((_2410.x * _2295) + _2225);
      _2423 = ((_2410.y * _2295) + _2224);
      _2424 = ((_2410.z * _2295) + _2223);
    } else {
      _2421 = _2226;
      _2422 = _2225;
      _2423 = _2224;
      _2424 = _2223;
    }
    int _2425 = _2222 + 1;
    _2427 = (_2421 < 0.9990000128746033f);
    if ((int)((uint)_2425 < (uint)7) && _2427) {
      _2222 = _2425;
      _2223 = _2424;
      _2224 = _2423;
      _2225 = _2422;
      _2226 = _2421;
      continue;
    }
    break;
  }
  [branch]
  if (_2427) {
    float _2435 = cb12_100x * (1.0f - _2421);
    float _2439 = _2435 * cb12_106x;
    bool _2442 = (_1947 < 0.0f);
    float _2448 = min(max((1.0f / (1.0f - _1947)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float _2456 = min(max((1.0f / (_1947 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float4 _2475 = t23.SampleLevel(s11, float2((((float((bool)_2442) + 0.1666666716337204f) + ((select(_2442, ((_1945 * 0.5f) * _2448), ((_1945 * -0.5f) * _2456)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(cb12_111x)) + 0.1666666716337204f) + ((select(_2442, ((_1946 * -0.5f) * _2448), ((_1946 * 0.5f) * _2456)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), 5.0f);
    _2486 = (_2435 + _2421);
    _2487 = ((_2475.x * _2439) + _2422);
    _2488 = ((_2475.y * _2439) + _2423);
    _2489 = ((_2475.z * _2439) + _2424);
  } else {
    _2486 = _2421;
    _2487 = _2422;
    _2488 = _2423;
    _2489 = _2424;
  }
  float _2490 = 1.0f / _2486;
  if (!(cb12_074y > 0.0f)) {
    float _2528 = saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.z) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.z) * TEXCOORD_2.z) + (gridDesc_000[1].PROBE_GRID_DESC_208.z))) + (gridDesc_000[1].PROBE_GRID_DESC_236));
    float _2531 = (_2528 * _2528) * min(saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.x) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.x) * TEXCOORD_2.x) + (gridDesc_000[1].PROBE_GRID_DESC_208.x))) + (gridDesc_000[1].PROBE_GRID_DESC_236)), saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.y) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.y) * TEXCOORD_2.y) + (gridDesc_000[1].PROBE_GRID_DESC_208.y))) + (gridDesc_000[1].PROBE_GRID_DESC_236)));
    float _2562 = saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.z) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.z) * TEXCOORD_2.z) + (gridDesc_000[0].PROBE_GRID_DESC_208.z))) + (gridDesc_000[0].PROBE_GRID_DESC_236));
    float _2565 = (_2562 * _2562) * min(saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.x) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.x) * TEXCOORD_2.x) + (gridDesc_000[0].PROBE_GRID_DESC_208.x))) + (gridDesc_000[0].PROBE_GRID_DESC_236)), saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.y) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.y) * TEXCOORD_2.y) + (gridDesc_000[0].PROBE_GRID_DESC_208.y))) + (gridDesc_000[0].PROBE_GRID_DESC_236)));
    bool _2566 = (_2531 > 9.999999717180685e-10f);
    int _2567 = (int)(uint)(_2566);
    bool _2570 = (int)(_2531 < 1.0f) && (int)(_2565 > 9.999999717180685e-10f);
    int _2571 = (int)(uint)(_2570);
    if (_2566) {
      float _2614 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _493) + TEXCOORD_2.x) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _513);
      float _2615 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _494) + TEXCOORD_2.y) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _514);
      float _2616 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _495) + TEXCOORD_2.z) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _515);
      float _2620 = (_2614 * (gridDesc_000[1].PROBE_GRID_DESC_176.x)) + (gridDesc_000[1].PROBE_GRID_DESC_192.x);
      float _2621 = (_2615 * (gridDesc_000[1].PROBE_GRID_DESC_176.y)) + (gridDesc_000[1].PROBE_GRID_DESC_192.y);
      float _2622 = (_2616 * (gridDesc_000[1].PROBE_GRID_DESC_176.z)) + (gridDesc_000[1].PROBE_GRID_DESC_192.z);
      int _2632 = min(max(int(_2620), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) + -1u)));
      int _2633 = min(max(int(_2621), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) + -1u)));
      int _2634 = min(max(int(_2622), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) + -1u)));
      float _2635 = float((int)(_2632));
      float _2636 = float((int)(_2633));
      float _2637 = float((int)(_2634));
      float _2638 = _2620 - _2635;
      float _2639 = _2621 - _2636;
      float _2640 = _2622 - _2637;
      _2644 = 0.0f;
      _2645 = 0.0f;
      _2646 = 0.0f;
      _2647 = 0.0f;
      _2648 = 0.0f;
      _2649 = 0;
      while(true) {
        int _2652 = _2649 & 1;
        int _2653 = ((uint)(_2649) >> 1) & 1;
        int _2654 = ((uint)(_2649) >> 2) & 1;
        uint _2655 = _2652 + _2632;
        uint _2656 = _2653 + _2633;
        uint _2657 = _2654 + _2634;
        if (!((int)((int)_2657 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_2655 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) || (int)((int)_2656 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.y)))))) {
          int _2670 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.x))) + _2655)) % (gridDesc_000[1].PROBE_GRID_DESC_032.x);
          int _2671 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.y))) + _2656)) % (gridDesc_000[1].PROBE_GRID_DESC_032.y);
          int _2672 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.z))) + _2657)) % (gridDesc_000[1].PROBE_GRID_DESC_032.z);
          int _2674 = _2672 + (_2670 * (gridDesc_000[1].PROBE_GRID_DESC_032.z));
          float4 _2677 = t34[1].Load(int3(_2674, _2671, 0));
          uint _2680 = t32[1].Load(int3(_2674, _2671, 0));
          if ((_2680.x & -2) == 2) {
            float _2699 = ((((_2635 - (gridDesc_000[1].PROBE_GRID_DESC_160.x)) + float((int)(_2652))) + (_2677.x * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.x) - _2614);
            float _2705 = ((((_2636 - (gridDesc_000[1].PROBE_GRID_DESC_160.y)) + float((int)(_2653))) + (_2677.y * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.y) - _2615);
            float _2711 = ((((_2637 - (gridDesc_000[1].PROBE_GRID_DESC_160.z)) + float((int)(_2654))) + (_2677.z * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.z) - _2616);
            float _2717 = sqrt(((_2699 * _2699) + (_2705 * _2705)) + (_2711 * _2711));
            float _2718 = max(_2717, 9.999999747378752e-06f);
            float _2719 = _2699 / _2718;
            float _2720 = _2705 / _2718;
            float _2721 = _2711 / _2718;
            float _2722 = -0.0f - _2719;
            float _2723 = -0.0f - _2720;
            float _2724 = -0.0f - _2721;
            float _2729 = (abs(_2723) + abs(_2722)) + abs(_2724);
            float _2730 = _2722 / _2729;
            float _2731 = _2723 / _2729;
            if (!((_2724 / _2729) > 0.0f)) {
              _2754 = ((1.0f - abs(_2731)) * float((int)(((int)(uint)((int)(_2730 > 0.0f))) - ((int)(uint)((int)(_2730 < 0.0f))))));
              _2755 = ((1.0f - abs(_2730)) * float((int)(((int)(uint)((int)(_2731 > 0.0f))) - ((int)(uint)((int)(_2731 < 0.0f))))));
            } else {
              _2754 = _2730;
              _2755 = _2731;
            }
            float _2756 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_092));
            float _2759 = (_2756 * 0.5f) / (_2756 + 2.0f);
            float _2762 = 1.0f / float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.x));
            float _2763 = 1.0f / float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.y));
            float _2766 = float((int)(_2670)) + 0.5f;
            float _2767 = float((int)(_2671)) + 0.5f;
            float _2774 = float((int)(_2672));
            float3 _2778 = t30[1].SampleLevel(s7, float3((((_2759 * _2754) + _2766) * _2762), (((_2759 * _2755) + _2767) * _2763), _2774), 0.0f);
            float _2785 = (abs(_1946) + abs(_1945)) + abs(_1947);
            float _2786 = _1945 / _2785;
            float _2787 = _1946 / _2785;
            if (!((_1947 / _2785) > 0.0f)) {
              _2810 = ((1.0f - abs(_2787)) * float((int)(((int)(uint)((int)(_2786 > 0.0f))) - ((int)(uint)((int)(_2786 < 0.0f))))));
              _2811 = ((1.0f - abs(_2786)) * float((int)(((int)(uint)((int)(_2787 > 0.0f))) - ((int)(uint)((int)(_2787 < 0.0f))))));
            } else {
              _2810 = _2786;
              _2811 = _2787;
            }
            float _2812 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_088));
            float _2815 = (_2812 * 0.5f) / (_2812 + 2.0f);
            float4 _2825 = t28[1].SampleLevel(s7, float3((((_2815 * _2810) + _2766) * _2762), (((_2815 * _2811) + _2767) * _2763), _2774), 0.0f);
            float _2829 = (gridDesc_000[1].PROBE_GRID_DESC_104) * 0.5f;
            float _2849 = (select((_2653 != 0), _2639, (1.0f - _2639)) * select((_2652 != 0), _2638, (1.0f - _2638))) * select((_2654 != 0), _2640, (1.0f - _2640));
            if (_2717 > _2778.x) {
              float _2855 = abs(_2778.y - (_2778.x * _2778.x));
              float _2856 = _2717 - _2778.x;
              _2862 = ((_2855 / (_2855 + (_2856 * _2856))) * _2849);
            } else {
              _2862 = _2849;
            }
            float _2867 = saturate((dot(float3(_2719, _2720, _2721), float3(_493, _494, _495)) * 0.5f) + 0.5f) * _2862;
            _2876 = ((_2867 * (pow(_2825.x, _2829))) + _2644);
            _2877 = ((_2867 * (pow(_2825.y, _2829))) + _2645);
            _2878 = ((_2867 * (pow(_2825.z, _2829))) + _2646);
            _2879 = (_2867 + _2647);
            _2880 = (_2849 + _2648);
          } else {
            _2876 = _2644;
            _2877 = _2645;
            _2878 = _2646;
            _2879 = _2647;
            _2880 = _2648;
          }
        } else {
          _2876 = _2644;
          _2877 = _2645;
          _2878 = _2646;
          _2879 = _2647;
          _2880 = _2648;
        }
        int _2881 = _2649 + 1;
        if (!(_2881 == 8)) {
          _2644 = _2876;
          _2645 = _2877;
          _2646 = _2878;
          _2647 = _2879;
          _2648 = _2880;
          _2649 = _2881;
          continue;
        }
        break;
      }
      while(true) {
        if (_2879 > 9.999999747378752e-06f) {
          float _2884 = _2876 / _2879;
          float _2885 = _2877 / _2879;
          float _2886 = _2878 / _2879;
          _2906 = ((_2884 * _2884) * 3.1415927410125732f);
          _2907 = ((_2885 * _2885) * 3.1415927410125732f);
          _2908 = ((_2886 * _2886) * 3.1415927410125732f);
          _2909 = _2879;
        } else {
          if (_2880 > 9.999999747378752e-06f) {
            float _2896 = _2876 / _2880;
            float _2897 = _2877 / _2880;
            float _2898 = _2878 / _2880;
            _2906 = ((_2896 * _2896) * 3.1415927410125732f);
            _2907 = ((_2897 * _2897) * 3.1415927410125732f);
            _2908 = ((_2898 * _2898) * 3.1415927410125732f);
            _2909 = _2880;
          } else {
            _2906 = 0.0f;
            _2907 = 0.0f;
            _2908 = 0.0f;
            _2909 = 0.0f;
          }
        }
        if (!(_2909 < 9.999999747378752e-06f)) {
          _2912 = _2906;
          _2913 = _2907;
          _2914 = _2908;
          if (_2570) {
            _2916 = _2912;
            _2917 = _2913;
            _2918 = _2914;
            _2919 = _2571;
            _2920 = _2567;
            _2921 = _2531;
            float _2967 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _493) + TEXCOORD_2.x) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _513);
            float _2968 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _494) + TEXCOORD_2.y) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _514);
            float _2969 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _495) + TEXCOORD_2.z) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _515);
            float _2973 = (_2967 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
            float _2974 = (_2968 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
            float _2975 = (_2969 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
            int _2985 = min(max(int(_2973), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
            int _2986 = min(max(int(_2974), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
            int _2987 = min(max(int(_2975), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
            float _2988 = float((int)(_2985));
            float _2989 = float((int)(_2986));
            float _2990 = float((int)(_2987));
            float _2991 = _2973 - _2988;
            float _2992 = _2974 - _2989;
            float _2993 = _2975 - _2990;
            _2997 = 0.0f;
            _2998 = 0.0f;
            _2999 = 0.0f;
            _3000 = 0.0f;
            _3001 = 0.0f;
            _3002 = 0;
            while(true) {
              int _3005 = _3002 & 1;
              int _3006 = ((uint)(_3002) >> 1) & 1;
              int _3007 = ((uint)(_3002) >> 2) & 1;
              uint _3008 = _3005 + _2985;
              uint _3009 = _3006 + _2986;
              uint _3010 = _3007 + _2987;
              if (!((int)((int)_3010 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_3008 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_3009 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
                int _3023 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _3008)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
                int _3024 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _3009)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
                int _3025 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _3010)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
                uint _3027 = t38.Load(int4(_3023, _3024, _3025, 0));
                float4 _3033 = t34[0].Load(int3((_3027.x & 511), ((uint)((uint)(_3027.x)) >> 9), 0));
                uint _3035 = t38.Load(int4(_3023, _3024, _3025, 0));
                int _3038 = (uint)((uint)(_3035.x)) >> 7;
                int _3040 = (uint)((uint)(_3035.x)) >> 14;
                if (!((((_3038 | _3035.x) & 127) | _3040) == 0)) {
                  float _3060 = ((((_2988 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_3005))) + (_3033.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2967);
                  float _3066 = ((((_2989 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_3006))) + (_3033.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2968);
                  float _3072 = ((((_2990 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_3007))) + (_3033.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2969);
                  float _3078 = sqrt(((_3060 * _3060) + (_3066 * _3066)) + (_3072 * _3072));
                  float _3079 = max(_3078, 9.999999747378752e-06f);
                  float _3080 = _3060 / _3079;
                  float _3081 = _3066 / _3079;
                  float _3082 = _3072 / _3079;
                  float _3083 = -0.0f - _3080;
                  float _3084 = -0.0f - _3081;
                  float _3085 = -0.0f - _3082;
                  float _3090 = (abs(_3084) + abs(_3083)) + abs(_3085);
                  float _3091 = _3083 / _3090;
                  float _3092 = _3084 / _3090;
                  if (!((_3085 / _3090) > 0.0f)) {
                    _3115 = ((1.0f - abs(_3092)) * float((int)(((int)(uint)((int)(_3091 > 0.0f))) - ((int)(uint)((int)(_3091 < 0.0f))))));
                    _3116 = ((1.0f - abs(_3091)) * float((int)(((int)(uint)((int)(_3092 > 0.0f))) - ((int)(uint)((int)(_3092 < 0.0f))))));
                  } else {
                    _3115 = _3091;
                    _3116 = _3092;
                  }
                  float _3117 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                  float _3120 = (_3117 * 0.5f) / (_3117 + 2.0f);
                  float _3123 = float((int)(_3035.x & 127)) + 0.5f;
                  float _3124 = float((int)(_3038 & 127)) + 0.5f;
                  float _3131 = float((int)(_3040));
                  float3 _3135 = t30[0].SampleLevel(s7, float3((((_3120 * _3115) + _3123) * 0.0078125f), (((_3120 * _3116) + _3124) * 0.0078125f), _3131), 0.0f);
                  float _3142 = (abs(_1946) + abs(_1945)) + abs(_1947);
                  float _3143 = _1945 / _3142;
                  float _3144 = _1946 / _3142;
                  if (!((_1947 / _3142) > 0.0f)) {
                    _3167 = ((1.0f - abs(_3144)) * float((int)(((int)(uint)((int)(_3143 > 0.0f))) - ((int)(uint)((int)(_3143 < 0.0f))))));
                    _3168 = ((1.0f - abs(_3143)) * float((int)(((int)(uint)((int)(_3144 > 0.0f))) - ((int)(uint)((int)(_3144 < 0.0f))))));
                  } else {
                    _3167 = _3143;
                    _3168 = _3144;
                  }
                  float _3169 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                  float _3172 = (_3169 * 0.5f) / (_3169 + 2.0f);
                  float4 _3182 = t28[0].SampleLevel(s7, float3((((_3172 * _3167) + _3123) * 0.0078125f), (((_3172 * _3168) + _3124) * 0.0078125f), _3131), 0.0f);
                  float _3186 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                  float _3206 = (select((_3006 != 0), _2992, (1.0f - _2992)) * select((_3005 != 0), _2991, (1.0f - _2991))) * select((_3007 != 0), _2993, (1.0f - _2993));
                  if (_3078 > _3135.x) {
                    float _3212 = abs(_3135.y - (_3135.x * _3135.x));
                    float _3213 = _3078 - _3135.x;
                    _3219 = ((_3212 / (_3212 + (_3213 * _3213))) * _3206);
                  } else {
                    _3219 = _3206;
                  }
                  float _3224 = saturate((dot(float3(_3080, _3081, _3082), float3(_493, _494, _495)) * 0.5f) + 0.5f) * _3219;
                  _3233 = ((_3224 * (pow(_3182.x, _3186))) + _2997);
                  _3234 = ((_3224 * (pow(_3182.y, _3186))) + _2998);
                  _3235 = ((_3224 * (pow(_3182.z, _3186))) + _2999);
                  _3236 = (_3224 + _3000);
                  _3237 = (_3206 + _3001);
                } else {
                  _3233 = _2997;
                  _3234 = _2998;
                  _3235 = _2999;
                  _3236 = _3000;
                  _3237 = _3001;
                }
              } else {
                _3233 = _2997;
                _3234 = _2998;
                _3235 = _2999;
                _3236 = _3000;
                _3237 = _3001;
              }
              int _3238 = _3002 + 1;
              if (!(_3238 == 8)) {
                _2997 = _3233;
                _2998 = _3234;
                _2999 = _3235;
                _3000 = _3236;
                _3001 = _3237;
                _3002 = _3238;
                continue;
              }
              break;
            }
            while(true) {
              if (_3236 > 9.999999747378752e-06f) {
                float _3241 = _3233 / _3236;
                float _3242 = _3234 / _3236;
                float _3243 = _3235 / _3236;
                _3263 = ((_3241 * _3241) * 3.1415927410125732f);
                _3264 = ((_3242 * _3242) * 3.1415927410125732f);
                _3265 = ((_3243 * _3243) * 3.1415927410125732f);
                _3266 = _3236;
              } else {
                if (_3237 > 9.999999747378752e-06f) {
                  float _3253 = _3233 / _3237;
                  float _3254 = _3234 / _3237;
                  float _3255 = _3235 / _3237;
                  _3263 = ((_3253 * _3253) * 3.1415927410125732f);
                  _3264 = ((_3254 * _3254) * 3.1415927410125732f);
                  _3265 = ((_3255 * _3255) * 3.1415927410125732f);
                  _3266 = _3237;
                } else {
                  _3263 = 0.0f;
                  _3264 = 0.0f;
                  _3265 = 0.0f;
                  _3266 = 0.0f;
                }
              }
              if (_3266 < 9.999999747378752e-06f) {
                _3270 = _2916;
                _3271 = _2917;
                _3272 = _2918;
                _3273 = _2920;
                _3274 = _2921;
                _3275 = 0.0f;
                _3276 = 0;
                _3277 = _3263;
                _3278 = _3264;
                _3279 = _3265;
              } else {
                _3270 = _2916;
                _3271 = _2917;
                _3272 = _2918;
                _3273 = _2920;
                _3274 = _2921;
                _3275 = _2565;
                _3276 = _2919;
                _3277 = _3263;
                _3278 = _3264;
                _3279 = _3265;
              }
              break;
            }
          } else {
            _3270 = _2912;
            _3271 = _2913;
            _3272 = _2914;
            _3273 = _2567;
            _3274 = _2531;
            _3275 = _2565;
            _3276 = _2571;
            _3277 = 0.0f;
            _3278 = 0.0f;
            _3279 = 0.0f;
          }
        } else {
          _2916 = _2906;
          _2917 = _2907;
          _2918 = _2908;
          _2919 = 1;
          _2920 = 0;
          _2921 = 0.0f;
          float _2967 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _493) + TEXCOORD_2.x) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _513);
          float _2968 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _494) + TEXCOORD_2.y) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _514);
          float _2969 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _495) + TEXCOORD_2.z) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _515);
          float _2973 = (_2967 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
          float _2974 = (_2968 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
          float _2975 = (_2969 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
          int _2985 = min(max(int(_2973), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
          int _2986 = min(max(int(_2974), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
          int _2987 = min(max(int(_2975), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
          float _2988 = float((int)(_2985));
          float _2989 = float((int)(_2986));
          float _2990 = float((int)(_2987));
          float _2991 = _2973 - _2988;
          float _2992 = _2974 - _2989;
          float _2993 = _2975 - _2990;
          _2997 = 0.0f;
          _2998 = 0.0f;
          _2999 = 0.0f;
          _3000 = 0.0f;
          _3001 = 0.0f;
          _3002 = 0;
          while(true) {
            int _3005 = _3002 & 1;
            int _3006 = ((uint)(_3002) >> 1) & 1;
            int _3007 = ((uint)(_3002) >> 2) & 1;
            uint _3008 = _3005 + _2985;
            uint _3009 = _3006 + _2986;
            uint _3010 = _3007 + _2987;
            if (!((int)((int)_3010 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_3008 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_3009 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
              int _3023 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _3008)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
              int _3024 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _3009)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
              int _3025 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _3010)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
              uint _3027 = t38.Load(int4(_3023, _3024, _3025, 0));
              float4 _3033 = t34[0].Load(int3((_3027.x & 511), ((uint)((uint)(_3027.x)) >> 9), 0));
              uint _3035 = t38.Load(int4(_3023, _3024, _3025, 0));
              int _3038 = (uint)((uint)(_3035.x)) >> 7;
              int _3040 = (uint)((uint)(_3035.x)) >> 14;
              if (!((((_3038 | _3035.x) & 127) | _3040) == 0)) {
                float _3060 = ((((_2988 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_3005))) + (_3033.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2967);
                float _3066 = ((((_2989 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_3006))) + (_3033.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2968);
                float _3072 = ((((_2990 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_3007))) + (_3033.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2969);
                float _3078 = sqrt(((_3060 * _3060) + (_3066 * _3066)) + (_3072 * _3072));
                float _3079 = max(_3078, 9.999999747378752e-06f);
                float _3080 = _3060 / _3079;
                float _3081 = _3066 / _3079;
                float _3082 = _3072 / _3079;
                float _3083 = -0.0f - _3080;
                float _3084 = -0.0f - _3081;
                float _3085 = -0.0f - _3082;
                float _3090 = (abs(_3084) + abs(_3083)) + abs(_3085);
                float _3091 = _3083 / _3090;
                float _3092 = _3084 / _3090;
                if (!((_3085 / _3090) > 0.0f)) {
                  _3115 = ((1.0f - abs(_3092)) * float((int)(((int)(uint)((int)(_3091 > 0.0f))) - ((int)(uint)((int)(_3091 < 0.0f))))));
                  _3116 = ((1.0f - abs(_3091)) * float((int)(((int)(uint)((int)(_3092 > 0.0f))) - ((int)(uint)((int)(_3092 < 0.0f))))));
                } else {
                  _3115 = _3091;
                  _3116 = _3092;
                }
                float _3117 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                float _3120 = (_3117 * 0.5f) / (_3117 + 2.0f);
                float _3123 = float((int)(_3035.x & 127)) + 0.5f;
                float _3124 = float((int)(_3038 & 127)) + 0.5f;
                float _3131 = float((int)(_3040));
                float3 _3135 = t30[0].SampleLevel(s7, float3((((_3120 * _3115) + _3123) * 0.0078125f), (((_3120 * _3116) + _3124) * 0.0078125f), _3131), 0.0f);
                float _3142 = (abs(_1946) + abs(_1945)) + abs(_1947);
                float _3143 = _1945 / _3142;
                float _3144 = _1946 / _3142;
                if (!((_1947 / _3142) > 0.0f)) {
                  _3167 = ((1.0f - abs(_3144)) * float((int)(((int)(uint)((int)(_3143 > 0.0f))) - ((int)(uint)((int)(_3143 < 0.0f))))));
                  _3168 = ((1.0f - abs(_3143)) * float((int)(((int)(uint)((int)(_3144 > 0.0f))) - ((int)(uint)((int)(_3144 < 0.0f))))));
                } else {
                  _3167 = _3143;
                  _3168 = _3144;
                }
                float _3169 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                float _3172 = (_3169 * 0.5f) / (_3169 + 2.0f);
                float4 _3182 = t28[0].SampleLevel(s7, float3((((_3172 * _3167) + _3123) * 0.0078125f), (((_3172 * _3168) + _3124) * 0.0078125f), _3131), 0.0f);
                float _3186 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                float _3206 = (select((_3006 != 0), _2992, (1.0f - _2992)) * select((_3005 != 0), _2991, (1.0f - _2991))) * select((_3007 != 0), _2993, (1.0f - _2993));
                if (_3078 > _3135.x) {
                  float _3212 = abs(_3135.y - (_3135.x * _3135.x));
                  float _3213 = _3078 - _3135.x;
                  _3219 = ((_3212 / (_3212 + (_3213 * _3213))) * _3206);
                } else {
                  _3219 = _3206;
                }
                float _3224 = saturate((dot(float3(_3080, _3081, _3082), float3(_493, _494, _495)) * 0.5f) + 0.5f) * _3219;
                _3233 = ((_3224 * (pow(_3182.x, _3186))) + _2997);
                _3234 = ((_3224 * (pow(_3182.y, _3186))) + _2998);
                _3235 = ((_3224 * (pow(_3182.z, _3186))) + _2999);
                _3236 = (_3224 + _3000);
                _3237 = (_3206 + _3001);
              } else {
                _3233 = _2997;
                _3234 = _2998;
                _3235 = _2999;
                _3236 = _3000;
                _3237 = _3001;
              }
            } else {
              _3233 = _2997;
              _3234 = _2998;
              _3235 = _2999;
              _3236 = _3000;
              _3237 = _3001;
            }
            int _3238 = _3002 + 1;
            if (!(_3238 == 8)) {
              _2997 = _3233;
              _2998 = _3234;
              _2999 = _3235;
              _3000 = _3236;
              _3001 = _3237;
              _3002 = _3238;
              continue;
            }
            break;
          }
          while(true) {
            if (_3236 > 9.999999747378752e-06f) {
              float _3241 = _3233 / _3236;
              float _3242 = _3234 / _3236;
              float _3243 = _3235 / _3236;
              _3263 = ((_3241 * _3241) * 3.1415927410125732f);
              _3264 = ((_3242 * _3242) * 3.1415927410125732f);
              _3265 = ((_3243 * _3243) * 3.1415927410125732f);
              _3266 = _3236;
            } else {
              if (_3237 > 9.999999747378752e-06f) {
                float _3253 = _3233 / _3237;
                float _3254 = _3234 / _3237;
                float _3255 = _3235 / _3237;
                _3263 = ((_3253 * _3253) * 3.1415927410125732f);
                _3264 = ((_3254 * _3254) * 3.1415927410125732f);
                _3265 = ((_3255 * _3255) * 3.1415927410125732f);
                _3266 = _3237;
              } else {
                _3263 = 0.0f;
                _3264 = 0.0f;
                _3265 = 0.0f;
                _3266 = 0.0f;
              }
            }
            if (_3266 < 9.999999747378752e-06f) {
              _3270 = _2916;
              _3271 = _2917;
              _3272 = _2918;
              _3273 = _2920;
              _3274 = _2921;
              _3275 = 0.0f;
              _3276 = 0;
              _3277 = _3263;
              _3278 = _3264;
              _3279 = _3265;
            } else {
              _3270 = _2916;
              _3271 = _2917;
              _3272 = _2918;
              _3273 = _2920;
              _3274 = _2921;
              _3275 = _2565;
              _3276 = _2919;
              _3277 = _3263;
              _3278 = _3264;
              _3279 = _3265;
            }
            break;
          }
        }
        break;
      }
    } else {
      _2912 = 0.0f;
      _2913 = 0.0f;
      _2914 = 0.0f;
      if (_2570) {
        _2916 = _2912;
        _2917 = _2913;
        _2918 = _2914;
        _2919 = _2571;
        _2920 = _2567;
        _2921 = _2531;
        float _2967 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _493) + TEXCOORD_2.x) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _513);
        float _2968 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _494) + TEXCOORD_2.y) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _514);
        float _2969 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _495) + TEXCOORD_2.z) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _515);
        float _2973 = (_2967 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
        float _2974 = (_2968 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
        float _2975 = (_2969 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
        int _2985 = min(max(int(_2973), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
        int _2986 = min(max(int(_2974), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
        int _2987 = min(max(int(_2975), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
        float _2988 = float((int)(_2985));
        float _2989 = float((int)(_2986));
        float _2990 = float((int)(_2987));
        float _2991 = _2973 - _2988;
        float _2992 = _2974 - _2989;
        float _2993 = _2975 - _2990;
        _2997 = 0.0f;
        _2998 = 0.0f;
        _2999 = 0.0f;
        _3000 = 0.0f;
        _3001 = 0.0f;
        _3002 = 0;
        while(true) {
          int _3005 = _3002 & 1;
          int _3006 = ((uint)(_3002) >> 1) & 1;
          int _3007 = ((uint)(_3002) >> 2) & 1;
          uint _3008 = _3005 + _2985;
          uint _3009 = _3006 + _2986;
          uint _3010 = _3007 + _2987;
          if (!((int)((int)_3010 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_3008 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_3009 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
            int _3023 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _3008)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
            int _3024 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _3009)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
            int _3025 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _3010)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
            uint _3027 = t38.Load(int4(_3023, _3024, _3025, 0));
            float4 _3033 = t34[0].Load(int3((_3027.x & 511), ((uint)((uint)(_3027.x)) >> 9), 0));
            uint _3035 = t38.Load(int4(_3023, _3024, _3025, 0));
            int _3038 = (uint)((uint)(_3035.x)) >> 7;
            int _3040 = (uint)((uint)(_3035.x)) >> 14;
            if (!((((_3038 | _3035.x) & 127) | _3040) == 0)) {
              float _3060 = ((((_2988 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_3005))) + (_3033.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2967);
              float _3066 = ((((_2989 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_3006))) + (_3033.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2968);
              float _3072 = ((((_2990 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_3007))) + (_3033.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2969);
              float _3078 = sqrt(((_3060 * _3060) + (_3066 * _3066)) + (_3072 * _3072));
              float _3079 = max(_3078, 9.999999747378752e-06f);
              float _3080 = _3060 / _3079;
              float _3081 = _3066 / _3079;
              float _3082 = _3072 / _3079;
              float _3083 = -0.0f - _3080;
              float _3084 = -0.0f - _3081;
              float _3085 = -0.0f - _3082;
              float _3090 = (abs(_3084) + abs(_3083)) + abs(_3085);
              float _3091 = _3083 / _3090;
              float _3092 = _3084 / _3090;
              if (!((_3085 / _3090) > 0.0f)) {
                _3115 = ((1.0f - abs(_3092)) * float((int)(((int)(uint)((int)(_3091 > 0.0f))) - ((int)(uint)((int)(_3091 < 0.0f))))));
                _3116 = ((1.0f - abs(_3091)) * float((int)(((int)(uint)((int)(_3092 > 0.0f))) - ((int)(uint)((int)(_3092 < 0.0f))))));
              } else {
                _3115 = _3091;
                _3116 = _3092;
              }
              float _3117 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
              float _3120 = (_3117 * 0.5f) / (_3117 + 2.0f);
              float _3123 = float((int)(_3035.x & 127)) + 0.5f;
              float _3124 = float((int)(_3038 & 127)) + 0.5f;
              float _3131 = float((int)(_3040));
              float3 _3135 = t30[0].SampleLevel(s7, float3((((_3120 * _3115) + _3123) * 0.0078125f), (((_3120 * _3116) + _3124) * 0.0078125f), _3131), 0.0f);
              float _3142 = (abs(_1946) + abs(_1945)) + abs(_1947);
              float _3143 = _1945 / _3142;
              float _3144 = _1946 / _3142;
              if (!((_1947 / _3142) > 0.0f)) {
                _3167 = ((1.0f - abs(_3144)) * float((int)(((int)(uint)((int)(_3143 > 0.0f))) - ((int)(uint)((int)(_3143 < 0.0f))))));
                _3168 = ((1.0f - abs(_3143)) * float((int)(((int)(uint)((int)(_3144 > 0.0f))) - ((int)(uint)((int)(_3144 < 0.0f))))));
              } else {
                _3167 = _3143;
                _3168 = _3144;
              }
              float _3169 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
              float _3172 = (_3169 * 0.5f) / (_3169 + 2.0f);
              float4 _3182 = t28[0].SampleLevel(s7, float3((((_3172 * _3167) + _3123) * 0.0078125f), (((_3172 * _3168) + _3124) * 0.0078125f), _3131), 0.0f);
              float _3186 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
              float _3206 = (select((_3006 != 0), _2992, (1.0f - _2992)) * select((_3005 != 0), _2991, (1.0f - _2991))) * select((_3007 != 0), _2993, (1.0f - _2993));
              if (_3078 > _3135.x) {
                float _3212 = abs(_3135.y - (_3135.x * _3135.x));
                float _3213 = _3078 - _3135.x;
                _3219 = ((_3212 / (_3212 + (_3213 * _3213))) * _3206);
              } else {
                _3219 = _3206;
              }
              float _3224 = saturate((dot(float3(_3080, _3081, _3082), float3(_493, _494, _495)) * 0.5f) + 0.5f) * _3219;
              _3233 = ((_3224 * (pow(_3182.x, _3186))) + _2997);
              _3234 = ((_3224 * (pow(_3182.y, _3186))) + _2998);
              _3235 = ((_3224 * (pow(_3182.z, _3186))) + _2999);
              _3236 = (_3224 + _3000);
              _3237 = (_3206 + _3001);
            } else {
              _3233 = _2997;
              _3234 = _2998;
              _3235 = _2999;
              _3236 = _3000;
              _3237 = _3001;
            }
          } else {
            _3233 = _2997;
            _3234 = _2998;
            _3235 = _2999;
            _3236 = _3000;
            _3237 = _3001;
          }
          int _3238 = _3002 + 1;
          if (!(_3238 == 8)) {
            _2997 = _3233;
            _2998 = _3234;
            _2999 = _3235;
            _3000 = _3236;
            _3001 = _3237;
            _3002 = _3238;
            continue;
          }
          break;
        }
        while(true) {
          if (_3236 > 9.999999747378752e-06f) {
            float _3241 = _3233 / _3236;
            float _3242 = _3234 / _3236;
            float _3243 = _3235 / _3236;
            _3263 = ((_3241 * _3241) * 3.1415927410125732f);
            _3264 = ((_3242 * _3242) * 3.1415927410125732f);
            _3265 = ((_3243 * _3243) * 3.1415927410125732f);
            _3266 = _3236;
          } else {
            if (_3237 > 9.999999747378752e-06f) {
              float _3253 = _3233 / _3237;
              float _3254 = _3234 / _3237;
              float _3255 = _3235 / _3237;
              _3263 = ((_3253 * _3253) * 3.1415927410125732f);
              _3264 = ((_3254 * _3254) * 3.1415927410125732f);
              _3265 = ((_3255 * _3255) * 3.1415927410125732f);
              _3266 = _3237;
            } else {
              _3263 = 0.0f;
              _3264 = 0.0f;
              _3265 = 0.0f;
              _3266 = 0.0f;
            }
          }
          if (_3266 < 9.999999747378752e-06f) {
            _3270 = _2916;
            _3271 = _2917;
            _3272 = _2918;
            _3273 = _2920;
            _3274 = _2921;
            _3275 = 0.0f;
            _3276 = 0;
            _3277 = _3263;
            _3278 = _3264;
            _3279 = _3265;
          } else {
            _3270 = _2916;
            _3271 = _2917;
            _3272 = _2918;
            _3273 = _2920;
            _3274 = _2921;
            _3275 = _2565;
            _3276 = _2919;
            _3277 = _3263;
            _3278 = _3264;
            _3279 = _3265;
          }
          break;
        }
      } else {
        _3270 = _2912;
        _3271 = _2913;
        _3272 = _2914;
        _3273 = _2567;
        _3274 = _2531;
        _3275 = _2565;
        _3276 = _2571;
        _3277 = 0.0f;
        _3278 = 0.0f;
        _3279 = 0.0f;
      }
    }
    bool _3282 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
    float _3286 = select(_3282, 0.0f, _3277);
    float _3287 = select(_3282, 0.0f, _3278);
    float _3288 = select(_3282, 1.0f, _3279);
    int _3289 = _3276 | _3273;
    if ((int)(_3275 < 1.0f) || (int)(_3289 == 0)) {
      float _3300 = (abs(_1946) + abs(_1945)) + abs(_1947);
      float _3301 = _1945 / _3300;
      float _3302 = _1946 / _3300;
      if (!((_1947 / _3300) > 0.0f)) {
        _3325 = ((1.0f - abs(_3302)) * float((int)(((int)(uint)((int)(_3301 > 0.0f))) - ((int)(uint)((int)(_3301 < 0.0f))))));
        _3326 = ((1.0f - abs(_3301)) * float((int)(((int)(uint)((int)(_3302 > 0.0f))) - ((int)(uint)((int)(_3302 < 0.0f))))));
      } else {
        _3325 = _3301;
        _3326 = _3302;
      }
      float _3327 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
      float _3330 = (_3327 * 0.5f) / (_3327 + 2.0f);
      float4 _3340 = t28[0].SampleLevel(s7, float3((((_3330 * _3325) + 0.5f) * 0.0078125f), (((_3330 * _3326) + 0.5f) * 0.0078125f), 0.0f), 0.0f);
      bool _3349 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
      float _3350 = select(_3349, 0.0f, (_3340.x * 3.1415927410125732f));
      float _3351 = select(_3349, 1.0f, (_3340.y * 3.1415927410125732f));
      float _3352 = select(_3349, 0.0f, (_3340.z * 3.1415927410125732f));
      _3365 = select((_3289 != 0), _3274, 0.0f);
      _3366 = (lerp(_3350, _3286, _3275));
      _3367 = (lerp(_3351, _3287, _3275));
      _3368 = (lerp(_3352, _3288, _3275));
    } else {
      _3365 = _3274;
      _3366 = _3286;
      _3367 = _3287;
      _3368 = _3288;
    }
    float _3375 = ((select(_3282, 1.0f, _3270) - _3366) * _3365) + _3366;
    float _3376 = ((select(_3282, 0.0f, _3271) - _3367) * _3365) + _3367;
    float _3377 = ((select(_3282, 0.0f, _3272) - _3368) * _3365) + _3368;
    bool _3382 = ((int)((int)(isnan(_3375)) || (int)(isnan(_3376)))) || (int)(isnan(_3377));
    _3389 = select(_3382, 0.0f, _3375);
    _3390 = select(_3382, 0.0f, _3376);
    _3391 = select(_3382, 0.0f, _3377);
    _3392 = (select(_3382, 0.0f, _3365) == 0.0f);
  } else {
    _3389 = 0.0f;
    _3390 = 0.0f;
    _3391 = 0.0f;
    _3392 = true;
  }
  float _3397 = select(_3392, 1.0f, (dot(float3(_3389, _3390, _3391), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f)) / dot(float3((_2490 * _2487), (_2490 * _2488), (_2490 * _2489)), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f)))) * (1.0f / _2217);
  bool _3403 = (cb12_074x > 0.0f);
  float _3410 = FrequentPixelConsts_256.z - FrequentPixelConsts_256.w;
  float _3423 = cb12_184z * _1931;
  float _3424 = cb12_184z * _1932;
  float _3425 = cb12_184z * _1933;
  float _3430 = abs(dot(float3(_305, _306, _307), float3(_513, _514, _515)));
  float _3434 = saturate(1.0f - abs(max(_3430, _3430)));
  float _3435 = _3434 * _3434;
  float _3451 = (((((_3435 * _3435) * _3434) * min(1.0f, cb13_066y)) * max(0.0f, (1.0f - _467))) / ((cb13_066w + 1.0f) - (cb13_066w * (1.0f - _463)))) + _467;
  float _3452 = (((_3410 * _928) + FrequentPixelConsts_256.w) * select(_3403, 0.0f, (_3397 * _2218))) * _3451;
  float _3453 = (((_3410 * _929) + FrequentPixelConsts_256.w) * select(_3403, 0.0f, (_3397 * _2219))) * _3451;
  float _3454 = (((_3410 * _930) + FrequentPixelConsts_256.w) * select(_3403, 0.0f, (_3397 * _2220))) * _3451;
  float _3457 = 1.0f - cb13_065w;
  float _3473 = ((cb13_065x * max(0.0f, (_235 * (pow(_225.x, 2.200000047683716f))))) * ((_3457 * _928) + cb13_065w)) + (cb12_184w * _1934);
  float _3474 = ((cb13_065y * max(0.0f, ((pow(_225.y, 2.200000047683716f)) * _235))) * ((_3457 * _929) + cb13_065w)) + (cb12_184w * _1935);
  float _3475 = ((cb13_065z * max(0.0f, ((pow(_225.z, 2.200000047683716f)) * _235))) * ((_3457 * _930) + cb13_065w)) + (cb12_184w * _1936);
  float _3488 = (saturate(cb12_069w) * (saturate((cb12_187x * _517.x) + cb12_188x) + -1.0f)) + 1.0f;
  bool _3493 = (_517.z < 0.9900000095367432f);
  if (_3493) {
    _3498 = cb12_287w;
  } else {
    _3498 = 1.0f;
  }
  float _3504 = exp2((cb12_288y * _3498) * log2(_3488));
  if (_3493) {
    _3509 = cb12_287w;
  } else {
    _3509 = 1.0f;
  }
  float _3512 = log2((_3488 * cb12_069x) + cb12_069y);
  float _3514 = exp2((_3509 * cb12_288z) * _3512);
  if (_3493) {
    _3519 = cb12_287w;
  } else {
    _3519 = 1.0f;
  }
  float _3523 = exp2((_3512 * cb12_288w) * _3519);
  if (!((cb12_340z & 4) == 0)) {
    _3539 = (_3514 * _3423);
    _3540 = (_3514 * _3424);
    _3541 = (_3514 * _3425);
    _3542 = (_3523 * _3473);
    _3543 = (_3523 * _3474);
    _3544 = (_3523 * _3475);
    _3545 = (_3504 * _3452);
    _3546 = (_3504 * _3453);
    _3547 = (_3504 * _3454);
  } else {
    _3539 = _3423;
    _3540 = _3424;
    _3541 = _3425;
    _3542 = _3473;
    _3543 = _3474;
    _3544 = _3475;
    _3545 = _3452;
    _3546 = _3453;
    _3547 = _3454;
  }
  if (_485 == 0) {
    _3554 = (_3539 * _477);
    _3555 = (_3540 * _478);
    _3556 = (_3541 * _479);
  } else {
    _3554 = _3539;
    _3555 = _3540;
    _3556 = _3541;
  }
  float _3557 = _3554 + _3542;
  float _3558 = _3555 + _3543;
  float _3559 = _3556 + _3544;
  if (!_3403) {
    _3565 = (_3557 + _3545);
    _3566 = (_3558 + _3546);
    _3567 = (_3559 + _3547);
  } else {
    _3565 = _3557;
    _3566 = _3558;
    _3567 = _3559;
  }
  SV_Target.x = _3565;
  SV_Target.y = _3566;
  SV_Target.z = _3567;
  SV_Target.w = 1.0f;
  return SV_Target;
}
