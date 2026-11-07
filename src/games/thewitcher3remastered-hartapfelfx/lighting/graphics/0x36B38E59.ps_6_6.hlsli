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

Texture2D<float4> t22 : register(t22);

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t27 : register(t27);

Texture2D<float4> t0 : register(t0);

TextureCube<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t43 : register(t43);

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

#define cb12_184x (cb12_raw[184].x)
#define cb12_226y (cb12_raw[226].y)
#define cb12_220w (cb12_raw[220].w)
#define cb12_069w (cb12_raw[69].w)
#define cb12_184y (cb12_raw[184].y)
#define cb12_226x (cb12_raw[226].x)
#define cb12_024x (cb12_raw[24].x)
#define cb12_000x (cb12_raw[0].x)
#define cb12_000y (cb12_raw[0].y)
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

#include "lighting/contact/forward.hlsli"

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  linear float3 TEXCOORD_2 : TEXCOORD2,
  linear float3 TEXCOORD_3 : TEXCOORD3,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  bool _2308;
  float _46[4];
  float _49 = TEXCOORD.x + select((TEXCOORD.x > 0.0f), -1.0f, 1.0f);
  float _51 = select((_49 >= 0.0f), 0.0f, 1.0f);
  float _53 = rsqrt(dot(float3(TEXCOORD_3.x, TEXCOORD_3.y, TEXCOORD_3.z), float3(TEXCOORD_3.x, TEXCOORD_3.y, TEXCOORD_3.z)));
  float _54 = _53 * TEXCOORD_3.x;
  float _55 = _53 * TEXCOORD_3.y;
  float _56 = _53 * TEXCOORD_3.z;
  float4 _63 = t0.Sample(s0, float2((cb4_002x * _49), (cb4_002x * TEXCOORD.y)));
  float _72 = _49 + -0.5f;
  float _73 = TEXCOORD.y + -0.5f;
  float _77 = sqrt((_72 * _72) + (_73 * _73));
  float _83 = saturate(1.0f - (((cb4_003x - cb4_004x) + _77) / (cb4_003x * 2.0f)));
  float _93 = cb4_007x * cb4_008x;
  float _95 = rsqrt(dot(float3(_72, _73, _93), float3(_72, _73, _93)));
  float _96 = _95 * _93;
  float _113;
  float _114;
  float _115;
  float _284;
  float _285;
  float _286;
  float _287;
  float _288;
  float _289;
  float _608;
  float _685;
  float _686;
  float _687;
  float _688;
  float _689;
  float _690;
  float _691;
  float _742;
  float _881;
  float _908;
  float _913;
  float _914;
  float _915;
  float _923;
  float _924;
  float _925;
  float _926;
  float _927;
  float _928;
  float _929;
  float _930;
  float _931;
  int _950;
  int _956;
  int _962;
  int _968;
  int _974;
  int _980;
  int _986;
  int _992;
  int _993;
  int _994;
  int _995;
  int _996;
  int _997;
  int _998;
  int _999;
  int _1000;
  float _1002;
  float _1003;
  float _1004;
  float _1005;
  float _1006;
  float _1007;
  int _1008;
  int _1066;
  float _1072;
  bool _1073;
  float _1140;
  float _1146;
  float _1257;
  float _1258;
  float _1259;
  float _1260;
  float _1340;
  float _1341;
  float _1342;
  float _1343;
  float _1347;
  float _1348;
  float _1349;
  float _1350;
  int _1351;
  float _1396;
  int _1409;
  int _1410;
  float _1448;
  float _1449;
  float _1450;
  float _1455;
  float _1456;
  float _1457;
  float _1459;
  float _1460;
  float _1461;
  float _1462;
  float _1479;
  float _1484;
  float _1485;
  float _1497;
  float _1506;
  float _1549;
  float _1570;
  float _1658;
  float _1732;
  float _1733;
  float _1734;
  float _1735;
  float _1786;
  float _1886;
  float _1913;
  float _1918;
  float _1919;
  float _1920;
  float _1928;
  float _1929;
  float _1930;
  float _1931;
  float _1932;
  float _1933;
  float _1937;
  float _1938;
  float _1939;
  float _1940;
  float _1941;
  float _1942;
  float _2049;
  float _2050;
  int _2053;
  float _2054;
  float _2055;
  float _2056;
  float _2057;
  float _2058;
  float _2059;
  float _2060;
  float _2115;
  float _2173;
  float _2174;
  float _2175;
  float _2299;
  float _2300;
  float _2301;
  float _2302;
  float _2303;
  float _2304;
  float _2305;
  float _2345;
  float _2346;
  float _2347;
  float _2393;
  float _2394;
  float _2395;
  float _2396;
  float _2397;
  float _2398;
  float _2399;
  float _2610;
  float _2611;
  float _2612;
  float _2671;
  float _2682;
  float _2691;
  float _2701;
  float _2724;
  float _2725;
  float _2726;
  float _2727;
  float _2728;
  float _2729;
  float _2730;
  float _2731;
  float _2732;
  float _2733;
  float _2734;
  float _2735;
  float _2742;
  float _2743;
  float _2744;
  float _2750;
  float _2751;
  float _2752;
  float _2761;
  float _2762;
  float _2763;
  if ((_96 * cb4_008x) > _93) {
    float _100 = _95 * cb4_008x;
    float _103 = (_100 * _72) - _72;
    float _104 = (_100 * _73) - _73;
    float _106 = (_96 - cb4_007x) * cb4_008x;
    float _108 = rsqrt(dot(float3(_103, _104, _106), float3(_103, _104, _106)));
    _113 = (_108 * _103);
    _114 = (_108 * _104);
    _115 = (_108 * _106);
  } else {
    _113 = 0.0f;
    _114 = 0.0f;
    _115 = 1.0f;
  }
  float _126 = exp2(log2(saturate(1.0f - ((cb4_006x * _77) / sqrt((cb4_008x * cb4_008x) - (_93 * _93))))) * cb4_005x);
  float _127 = _126 * _113;
  float _128 = _126 * _114;
  float _130 = rsqrt(dot(float3(_127, _128, _115), float3(_127, _128, _115)));
  float _133 = _130 * _115;
  float _134 = (1.0f - _83) * 2.0f;
  float _137 = (_130 * _127) + (_134 * (_63.x + -0.5f));
  float _138 = (_130 * _128) + (_134 * (_63.y + -0.5f));
  float _140 = rsqrt(dot(float3(_137, _138, _133), float3(_137, _138, _133)));
  float _141 = _137 * _140;
  float _142 = _138 * _140;
  float _143 = _140 * _133;
  float _145 = rsqrt(dot(float3(TEXCOORD.z, TEXCOORD.w, TEXCOORD_1.w), float3(TEXCOORD.z, TEXCOORD.w, TEXCOORD_1.w)));
  float _146 = _145 * TEXCOORD.z;
  float _147 = _145 * TEXCOORD.w;
  float _148 = _145 * TEXCOORD_1.w;
  float _150 = rsqrt(dot(float3(TEXCOORD_1.x, TEXCOORD_1.y, TEXCOORD_1.z), float3(TEXCOORD_1.x, TEXCOORD_1.y, TEXCOORD_1.z)));
  float _151 = _150 * TEXCOORD_1.x;
  float _152 = _150 * TEXCOORD_1.y;
  float _153 = _150 * TEXCOORD_1.z;
  float _156 = mad(_143, _146, mad(_142, _151, (_141 * _54)));
  float _159 = mad(_143, _147, mad(_142, _152, (_141 * _55)));
  float _162 = mad(_143, _148, mad(_142, _153, (_141 * _56)));
  float _164 = rsqrt(dot(float3(_156, _159, _162), float3(_156, _159, _162)));
  float _165 = _164 * _156;
  float _166 = _164 * _159;
  float _167 = _164 * _162;
  float _172 = cb1_036x - TEXCOORD_2.x;
  float _173 = cb1_036y - TEXCOORD_2.y;
  float _174 = cb1_036z - TEXCOORD_2.z;
  float _176 = rsqrt(dot(float3(_172, _173, _174), float3(_172, _173, _174)));
  float _177 = _172 * _176;
  float _178 = _173 * _176;
  float _179 = _174 * _176;
  float _185 = sqrt(((_172 * _172) + (_173 * _173)) + (_174 * _174));
  float _186 = _185 * _177;
  float _187 = _185 * _178;
  float _192 = (cb4_009x * _146) + _186;
  float _193 = (cb4_009x * _147) + _187;
  float _195 = rsqrt(dot(float3(_192, _193, 0.0f), float3(_192, _193, 0.0f)));
  float _196 = _192 * _195;
  float _197 = _193 * _195;
  float _199 = -0.0f - _186;
  float _200 = -0.0f - _187;
  float _202 = -0.0f - (_185 * _179);
  float _204 = rsqrt(dot(float3(_199, _200, _202), float3(_199, _200, _202)));
  float _205 = _204 * _199;
  float _206 = _204 * _200;
  float _207 = _204 * _202;
  float _209 = dot(float3(_205, _206, _207), float3(_165, _166, _167)) * 2.0f;
  float _213 = _205 - (_209 * _165);
  float _214 = _206 - (_209 * _166);
  float _215 = _207 - (_209 * _167);
  float4 _223 = t1.Sample(s0, float3(mad((-0.0f - _196), _214, (_213 * _197)), mad(-0.0f, _215, mad(_197, _214, (_213 * _196))), _215));
  float _233 = ((cb4_001x - cb4_000x) * _51) + cb4_000x;
  bool _260 = (TEXCOORD.x <= 0.0f);
  float _262 = select(_260, cb4_015x, cb4_014x) * -0.01745329424738884f;
  float _263 = sin(_262);
  float _264 = cos(_262);
  if (_260) {
    _284 = CustomPixelConsts_176.x;
    _285 = CustomPixelConsts_192.x;
    _286 = CustomPixelConsts_176.y;
    _287 = CustomPixelConsts_192.y;
    _288 = CustomPixelConsts_176.z;
    _289 = CustomPixelConsts_192.z;
  } else {
    _284 = CustomPixelConsts_128.x;
    _285 = CustomPixelConsts_144.x;
    _286 = CustomPixelConsts_128.y;
    _287 = CustomPixelConsts_144.y;
    _288 = CustomPixelConsts_128.z;
    _289 = CustomPixelConsts_144.z;
  }
  float _291 = mad(_264, _285, (_284 * _263));
  float _293 = mad(_264, _287, (_286 * _263));
  float _295 = mad(_264, _289, (_288 * _263));
  float _297 = rsqrt(dot(float3(_54, _55, _56), float3(_54, _55, _56)));
  float _298 = _297 * _54;
  float _299 = _297 * _55;
  float _300 = _297 * _56;
  float _302 = rsqrt(dot(float3(_146, _147, _148), float3(_146, _147, _148)));
  float _303 = _302 * _146;
  float _304 = _302 * _147;
  float _305 = _302 * _148;
  float _307 = rsqrt(dot(float3(_177, _178, _179), float3(_177, _178, _179)));
  float _309 = -0.0f - (_177 * _307);
  float _311 = -0.0f - (_178 * _307);
  float _313 = -0.0f - (_179 * _307);
  float _314 = dot(float3(_298, _299, _300), float3(_291, _293, _295));
  float _318 = _298 - (_314 * _291);
  float _319 = _299 - (_314 * _293);
  float _320 = _300 - (_314 * _295);
  float _322 = rsqrt(dot(float3(_318, _319, _320), float3(_318, _319, _320)));
  float _323 = _318 * _322;
  float _324 = _319 * _322;
  float _325 = _320 * _322;
  float _328 = (_324 * _295) - (_325 * _293);
  float _331 = (_325 * _291) - (_323 * _295);
  float _334 = (_323 * _293) - (_324 * _291);
  float _335 = _303 * cb4_009x;
  float _336 = _304 * cb4_009x;
  float _337 = _305 * cb4_009x;
  float _349 = mad(_325, _313, mad(_324, _311, (_323 * _309)));
  float _352 = mad(_295, _313, mad(_293, _311, (_291 * _309)));
  float _355 = mad(_334, _313, mad(_331, _311, (_328 * _309)));
  float _358 = mad(_325, _305, mad(_324, _304, (_323 * _303)));
  float _361 = mad(_295, _305, mad(_293, _304, (_303 * _291)));
  float _364 = mad(_334, _305, mad(_331, _304, (_328 * _303)));
  float _365 = dot(float3(_349, _352, _355), float3(_358, _361, _364));
  float _370 = 1.0f - ((cb4_011x * cb4_011x) * (1.0f - (_365 * _365)));
  bool _371 = (_370 >= 0.0f);
  float _377 = (_365 * cb4_011x) + sqrt(_370);
  float _394 = min(max((1.0f / abs(select(_371, ((_352 * cb4_011x) - (_377 * _361)), 0.0f))), -3.4028234663852886e+38f), 3.4028234663852886e+38f) * (max(0.0f, (mad(_295, _337, mad(_293, _336, (_335 * _291))) - cb4_016x)) * cb4_012x);
  float _401 = cb4_009x * 2.0f;
  float _410 = (((0.5f - _49) + ((((_394 * select(_371, ((_349 * cb4_011x) - (_377 * _358)), 0.0f)) + mad(_325, _337, mad(_324, _336, (_323 * _335)))) * cb4_017x) / _401)) * _83) + _49;
  float _411 = (((0.5f - TEXCOORD.y) + ((((_394 * select(_371, ((_355 * cb4_011x) - (_377 * _364)), 0.0f)) + mad(_334, _337, mad(_331, _336, (_328 * _335)))) * cb4_017x) / _401)) * _83) + TEXCOORD.y;
  float4 _414 = t2.Sample(s0, float2(_410, _411));
  float4 _420 = t3.Sample(s0, float2(_410, _411));
  float _427 = (_420.x + -0.5f) * 2.0f;
  float _428 = (_420.y + -0.5f) * 2.0f;
  float _429 = (_420.z + -0.5f) * 2.0f;
  float _432 = mad(_429, _146, mad(_428, _151, (_427 * _54)));
  float _435 = mad(_429, _147, mad(_428, _152, (_427 * _55)));
  float _438 = mad(_429, _148, mad(_428, _153, (_427 * _56)));
  float _440 = rsqrt(dot(float3(_432, _435, _438), float3(_432, _435, _438)));
  float _441 = _440 * _432;
  float _442 = _440 * _435;
  float _443 = _440 * _438;
  uint _459 = uint(SV_Position.x);
  uint _460 = uint(SV_Position.y);
  float _461 = saturate(cb4_020x);
  float _465 = exp2(log2(saturate(lerp(cb4_018x, cb4_019x, _51))) * 2.200000047683716f);
  float _475 = exp2(log2(saturate(_414.x)) * 2.200000047683716f);
  float _476 = exp2(log2(saturate(_414.y)) * 2.200000047683716f);
  float _477 = exp2(log2(saturate(_414.z)) * 2.200000047683716f);
  int _483 = int(cb12_220w);
  bool _486 = (cb12_226x > 0.0f);
  float _490 = rsqrt(dot(float3(_441, _442, _443), float3(_441, _442, _443)));
  float _491 = _490 * _441;
  float _492 = _490 * _442;
  float _493 = _490 * _443;
  float _495 = rsqrt(dot(float3(_165, _166, _167), float3(_165, _166, _167)));
  float _496 = _495 * _165;
  float _497 = _495 * _166;
  float _498 = _495 * _167;
  float _511 = cb12_000x - TEXCOORD_2.x;
  float _512 = cb12_000y - TEXCOORD_2.y;
  float _513 = cb12_000z - TEXCOORD_2.z;
  float _515 = rsqrt(dot(float3(_511, _512, _513), float3(_511, _512, _513)));
  float _516 = _511 * _515;
  float _517 = _512 * _515;
  float _518 = _513 * _515;
  bool improved_pbr = graphics_injection.layout_version == 1.f
      && graphics_injection.graphics_mode != 0.f && graphics_injection.pbr_mode != 0.f
      && (_483 == 0 || _483 == 1);
  // The eye material supplies distinct iris and corneal normals. Filter the
  // direct lobes independently, before divergent light branches; retain native
  // refraction, pupil geometry and environment roughness.
  float iris_roughness = GraphicsForwardRoughness(float3(_491, _492, _493), _461);
  float cornea_roughness = GraphicsForwardRoughness(float3(_496, _497, _498), _461);
  iris_roughness = improved_pbr ? iris_roughness : _461;
  cornea_roughness = improved_pbr ? cornea_roughness : _461;
  float4 _520 = t17.Load(int3(_459, _460, 0));
  float graphics_sun_visibility = min(_520.y, GraphicsForwardContact(TEXCOORD_2,
      float3(_491, _492, _493), SV_Position.xy, true));
  GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
      TEXCOORD_2, float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
  if (_520.y > 0.0f) {
    if (_483 == 1) {
      int _535 = ((int)(uint)((int)(_493 > 0.0f))) << 1u;
      float _537 = float((int)(_535 + -1));
      float _539 = -1.0f / (_537 + _493);
      float _541 = (_491 * _492) * _539;
      float _545 = (((_491 * _491) * _537) * _539) + 1.0f;
      float _546 = _541 * _537;
      float _549 = float((int)(1 - _535)) * _491;
      float _552 = ((_492 * _492) * _539) + _537;
      float _553 = -0.0f - _492;
      float _555 = rsqrt(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
      float _556 = _555 * water_light.sun.x;
      float _557 = _555 * water_light.sun.y;
      float _558 = _555 * water_light.sun.z;
      float _561 = mad(_549, _558, mad(_546, _557, (_556 * _545)));
      float _564 = mad(_553, _558, mad(_552, _557, (_556 * _541)));
      float _567 = mad(_493, _558, mad(_492, _557, (_556 * _491)));
      float _569 = rsqrt(dot(float3(_561, _564, _567), float3(_561, _564, _567)));
      float _572 = _569 * _567;
      float _574 = rsqrt(dot(float3(_516, _517, _518), float3(_516, _517, _518)));
      float _575 = _574 * _516;
      float _576 = _574 * _517;
      float _577 = _574 * _518;
      float _580 = mad(_549, _577, mad(_546, _576, (_575 * _545)));
      float _583 = mad(_553, _577, mad(_552, _576, (_575 * _541)));
      float _586 = mad(_493, _577, mad(_492, _576, (_575 * _491)));
      float _588 = rsqrt(dot(float3(_580, _583, _586), float3(_580, _583, _586)));
      float _591 = _588 * _586;
      float _592 = _461 * _461;
      float _595 = dot(float3((_569 * _561), (_569 * _564), _572), float3((_588 * _580), (_588 * _583), _591)) - (_591 * _572);
      if (_595 > 0.0f) {
        _608 = (_595 / max(_572, _591));
      } else {
        _608 = _595;
      }
      float _610 = (_592 * 0.2877933979034424f) + 1.0f;
      float _611 = 1.0f / _610;
      float _615 = ((_608 * _592) + 1.0f) * (_611 * 0.31830987334251404f);
      float _619 = 1.0f - _591;
      float _630 = 1.0f - _572;
      float _643 = _611 * ((_592 * 0.07248824834823608f) + 1.0f);
      float _650 = 1.0f - _643;
      float _665 = max(1.0000000116860974e-07f, (1.0f - ((((_630 * _592) * ((((((_630 * 0.07144299894571304f) + -0.332181453704834f) * _630) + 0.4918818771839142f) * _630) + 0.05710852891206741f)) + 1.0f) / _610))) * (max(1.0000000116860974e-07f, (1.0f - ((((_619 * _592) * ((((((_619 * 0.07144299894571304f) + -0.332181453704834f) * _619) + 0.4918818771839142f) * _619) + 0.05710852891206741f)) + 1.0f) / _610))) * 0.31830987334251404f);
      float _669 = max(1.0000000116860974e-07f, _650);
      float _677 = saturate(dot(float3(_491, _492, _493), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
      float _678 = _677 * (((_665 * (((_475 * _475) * _643) / (1.0f - (_650 * _475)))) / _669) + (_615 * _475));
      float _679 = _677 * (((_665 * (((_476 * _476) * _643) / (1.0f - (_650 * _476)))) / _669) + (_615 * _476));
      float _680 = _677 * (((_665 * (((_477 * _477) * _643) / (1.0f - (_650 * _477)))) / _669) + (_615 * _477));
      _685 = _678;
      _686 = _679;
      _687 = _680;
      _688 = 1.0f;
      _689 = (_678 * 3.1415927410125732f);
      _690 = (_679 * 3.1415927410125732f);
      _691 = (_680 * 3.1415927410125732f);
    } else {
      float _603 = cb4_021x + 1.0f;
      float _606 = saturate((dot(float3(_491, _492, _493), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + cb4_021x) / _603);
      _685 = _606;
      _686 = _606;
      _687 = _606;
      _688 = (1.0f / _603);
      _689 = _606;
      _690 = _606;
      _691 = _606;
    }
    // Iris response uses its refracted normal; cornea highlights remain separate.
    if (improved_pbr) {
      float3 diffuse = GraphicsForwardDiffuse(float3(_491, _492, _493), float3(_516, _517, _518),
          float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), iris_roughness, float3(_475, _476, _477), _483, _685);
      _685 = diffuse.x; _686 = diffuse.y; _687 = diffuse.z;
    }
    float _695 = 1.0f - _465;
    if (cb12_221x > 0.0f) {
      float4 _700 = t43.SampleLevel(s10, float2(iris_roughness, dot(float3(_491, _492, _493), float3(_516, _517, _518))), 0.0f);
      float _704 = (_700.x * _465) + _700.y;
      _742 = min((_704 / max((1.0f - ((1.0f - _704) * ((_695 * 0.0476190485060215f) + _465))), 0.0010000000474974513f)), 1.0f);
    } else {
      float _714 = water_light.sun.x + _516;
      float _715 = water_light.sun.y + _517;
      float _716 = water_light.sun.z + _518;
      float _718 = rsqrt(dot(float3(_714, _715, _716), float3(_714, _715, _716)));
      float _725 = saturate(1.0f - abs(dot(float3((_718 * _714), (_718 * _715), (_718 * _716)), float3(_516, _517, _518))));
      float _726 = _725 * _725;
      _742 = ((((((_726 * _726) * _725) * cb13_066x) * max(0.0f, _695)) / ((cb13_066z + 1.0f) - (cb13_066z * (1.0f - iris_roughness)))) + _465);
    }
    float _746 = (1.0f - _742) * _685;
    float _747 = (1.0f - _742) * _686;
    float _748 = (1.0f - _742) * _687;
    bool _750 = ((_483 & -3) == 0);
    float _757 = TEXCOORD_2.x - cb12_000x;
    float _758 = TEXCOORD_2.y - cb12_000y;
    float _768 = saturate((cb12_219z * TEXCOORD_2.z) + cb12_219w);
    float _790 = saturate((cb12_219x * sqrt((_757 * _757) + (_758 * _758))) + cb12_219y);
    float _801 = ((((lerp(cb13_062x, cb13_061x, _768)) - cb13_001x) * _790) + cb13_001x) * water_light.direct.x;
    float _802 = ((((lerp(cb13_062y, cb13_061y, _768)) - cb13_001y) * _790) + cb13_001y) * water_light.direct.y;
    float _803 = ((((lerp(cb13_062z, cb13_061z, _768)) - cb13_001z) * _790) + cb13_001z) * water_light.direct.z;
    float _804 = _688 * graphics_sun_visibility;
    [branch]
    if (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_496, _497, _498)) > 0.0f) {
      float _814 = water_light.sun.x + _516;
      float _815 = water_light.sun.y + _517;
      float _816 = water_light.sun.z + _518;
      float _818 = rsqrt(dot(float3(_814, _815, _816), float3(_814, _815, _816)));
      float _819 = _818 * _814;
      float _820 = _818 * _815;
      float _821 = _818 * _816;
      float _823 = dot(float3(_496, _497, _498), float3(_516, _517, _518));
      float _825 = saturate(dot(float3(_496, _497, _498), float3(_819, _820, _821)));
      float _826 = saturate(dot(float3(_496, _497, _498), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
      float _827 = cornea_roughness * cornea_roughness;
      float _828 = _827 * _827;
      float _832 = ((_825 * _825) * (_828 + -1.0f)) + 1.0f;
      float _836 = abs(_823);
      float _840 = saturate(1.0f - abs(dot(float3(_819, _820, _821), float3(_516, _517, _518))));
      float _841 = _840 * _840;
      [branch]
      if (cb12_221z > 0.0f) {
        float _859 = saturate(_823);
        float _862 = (_826 * 2.0f) * _859;
        _881 = ((((_859 + _826) - _862) * _827) + _862);
      } else {
        float _867 = 1.0f - _828;
        _881 = (((sqrt(((_836 * _836) * _867) + _828) * _826) + 9.999999747378752e-05f) + (sqrt(((_826 * _826) * _867) + _828) * _836));
      }
      float _882 = 0.5f / _881;
      float _884 = (((((((_841 * _841) * _840) * cb13_066x) * max(0.0f, _695)) / ((cb13_066z + 1.0f) - (cb13_066z * (1.0f - cornea_roughness)))) + _465) * (_828 / ((_832 * _832) * 3.1415200233459473f))) * _882;
      if (improved_pbr) {
        float grazing5 = _840 * _840;
        grazing5 *= grazing5 * _840;
        _884 = GraphicsDirectGGX(_825, _823, _826, cornea_roughness)
            * (_465 + grazing5 * cb13_066x * max(0.f, _695)
                / ((cb13_066z + 1.f) - cb13_066z * (1.f - cornea_roughness)));
      }
      if (cb12_221y > 0.0f) {
        float4 _891 = t43.SampleLevel(s10, float2(cornea_roughness, dot(float3(_496, _497, _498), float3(_882, _882, _882))), 0.0f);
        float _895 = (_891.x * _465) + _891.y;
        _908 = ((min((_895 / max((1.0f - ((1.0f - _895) * ((_695 * 0.0476190485060215f) + _465))), 0.0010000000474974513f)), 1.0f) / max(_895, 9.999999747378752e-05f)) * _884);
      } else {
        _908 = _884;
      }
      _913 = (_908 * _826);
      _914 = (_908 * _826);
      _915 = (_908 * _826);
    } else {
      _913 = 0.0f;
      _914 = 0.0f;
      _915 = 0.0f;
    }
    _923 = ((_801 * graphics_sun_visibility) * _913);
    _924 = ((_802 * graphics_sun_visibility) * _914);
    _925 = ((_803 * graphics_sun_visibility) * _915);
    _926 = ((select(_750, (_746 * 0.31830987334251404f), _746) * _804) * _801);
    _927 = ((select(_750, (_747 * 0.31830987334251404f), _747) * _804) * _802);
    _928 = ((select(_750, (_748 * 0.31830987334251404f), _748) * _804) * _803);
    _929 = _689;
    _930 = _690;
    _931 = _691;
  } else {
    _923 = 0.0f;
    _924 = 0.0f;
    _925 = 0.0f;
    _926 = 0.0f;
    _927 = 0.0f;
    _928 = 0.0f;
    _929 = 0.0f;
    _930 = 0.0f;
    _931 = 0.0f;
  }
  if (any(water_light.direct != 1.f)) {
    float3 environment = GraphicsEyeSunEnvironment(float3(_491, _492, _493), float3(_516, _517, _518),
        float3(cb13_000x, cb13_000y, cb13_000z), float3(_475, _476, _477), _461, _483, cb4_021x, _520.y);
    _929 = environment.x; _930 = environment.y; _931 = environment.z;
  }
  float _932 = min(_929, _520.y);
  float _933 = min(_930, _520.y);
  float _934 = min(_931, _520.y);
  uint4 _936 = 0u; t60.GetDimensions(0u, _936.x, _936.y, _936.z, _936.w);
  if ((int)((uint)_459 < (uint)(int)(_936.x)) && (int)((uint)_460 < (uint)(int)(_936.y))) {
    int _944 = min((int)(_936.z), 8);
    if (!(_944 == 0)) {
      uint _947 = t60.Load(int4(_459, _460, 0, 0));
      _950 = _947.x;
    } else {
      _950 = 0;
    }
    if ((uint)_944 > (uint)1) {
      uint _953 = t60.Load(int4(_459, _460, 1, 0));
      _956 = _953.x;
    } else {
      _956 = 0;
    }
    if ((uint)_944 > (uint)2) {
      uint _959 = t60.Load(int4(_459, _460, 2, 0));
      _962 = _959.x;
    } else {
      _962 = 0;
    }
    if ((uint)_944 > (uint)3) {
      uint _965 = t60.Load(int4(_459, _460, 3, 0));
      _968 = _965.x;
    } else {
      _968 = 0;
    }
    if ((uint)_944 > (uint)4) {
      uint _971 = t60.Load(int4(_459, _460, 4, 0));
      _974 = _971.x;
    } else {
      _974 = 0;
    }
    if ((uint)_944 > (uint)5) {
      uint _977 = t60.Load(int4(_459, _460, 5, 0));
      _980 = _977.x;
    } else {
      _980 = 0;
    }
    if ((uint)_944 > (uint)6) {
      uint _983 = t60.Load(int4(_459, _460, 6, 0));
      _986 = _983.x;
    } else {
      _986 = 0;
    }
    if ((uint)_944 > (uint)7) {
      uint _989 = t60.Load(int4(_459, _460, 7, 0));
      _992 = _968;
      _993 = _962;
      _994 = _956;
      _995 = _950;
      _996 = _989.x;
      _997 = _986;
      _998 = _980;
      _999 = _974;
      _1000 = _944;
    } else {
      _992 = _968;
      _993 = _962;
      _994 = _956;
      _995 = _950;
      _996 = 0;
      _997 = _986;
      _998 = _980;
      _999 = _974;
      _1000 = _944;
    }
  } else {
    _992 = 0;
    _993 = 0;
    _994 = 0;
    _995 = 0;
    _996 = 0;
    _997 = 0;
    _998 = 0;
    _999 = 0;
    _1000 = 0;
  }
  _1002 = _926;
  _1003 = _927;
  _1004 = _928;
  _1005 = _923;
  _1006 = _924;
  _1007 = _925;
  _1008 = 0;
  while(true) {
    int4 _1012 = asint(t20.Load4(((int)(((uint)(_1008 + ((int)(((int(cb12_024x) * ((uint)(_460) >> 4)) + ((uint)((uint)(_459) >> 4))) << 8u)))) << 2u))));
    [branch]
    if (!((uint)_1012.x > (uint)255)) {
      uint _1016 = _1012.x * 10;
      float _1022 = (cb13_raw[((int)(_1016 + 68u))].x) - TEXCOORD_2.x;
      float _1023 = (cb13_raw[((int)(_1016 + 68u))].y) - TEXCOORD_2.y;
      float _1024 = (cb13_raw[((int)(_1016 + 68u))].z) - TEXCOORD_2.z;
      uint _1025 = (uint)(_1012.x) + 1u;
      if (!(_1000 == 0)) {
        if (!((_995 & 511) == _1025)) {
          if (!((uint)_1000 < (uint)2)) {
            if (!((_994 & 511) == _1025)) {
              if (!((uint)_1000 < (uint)3)) {
                if (!((_993 & 511) == _1025)) {
                  if (!((uint)_1000 < (uint)4)) {
                    if (!((_992 & 511) == _1025)) {
                      if (!((uint)_1000 < (uint)5)) {
                        if (!((_999 & 511) == _1025)) {
                          if (!((uint)_1000 < (uint)6)) {
                            if (!((_998 & 511) == _1025)) {
                              if (!((uint)_1000 < (uint)7)) {
                                if (!((_997 & 511) == _1025)) {
                                  if ((int)((uint)_1000 > (uint)7) && (int)((_996 & 511) == _1025)) {
                                    _1066 = _996;
                                    _1072 = (float((uint)((uint)(((uint)(_1066) >> 9) & 127))) * 0.007874015718698502f);
                                    _1073 = true;
                                  } else {
                                    _1072 = 1.0f;
                                    _1073 = false;
                                  }
                                } else {
                                  _1066 = _997;
                                  _1072 = (float((uint)((uint)(((uint)(_1066) >> 9) & 127))) * 0.007874015718698502f);
                                  _1073 = true;
                                }
                              } else {
                                _1072 = 1.0f;
                                _1073 = false;
                              }
                            } else {
                              _1066 = _998;
                              _1072 = (float((uint)((uint)(((uint)(_1066) >> 9) & 127))) * 0.007874015718698502f);
                              _1073 = true;
                            }
                          } else {
                            _1072 = 1.0f;
                            _1073 = false;
                          }
                        } else {
                          _1066 = _999;
                          _1072 = (float((uint)((uint)(((uint)(_1066) >> 9) & 127))) * 0.007874015718698502f);
                          _1073 = true;
                        }
                      } else {
                        _1072 = 1.0f;
                        _1073 = false;
                      }
                    } else {
                      _1066 = _992;
                      _1072 = (float((uint)((uint)(((uint)(_1066) >> 9) & 127))) * 0.007874015718698502f);
                      _1073 = true;
                    }
                  } else {
                    _1072 = 1.0f;
                    _1073 = false;
                  }
                } else {
                  _1066 = _993;
                  _1072 = (float((uint)((uint)(((uint)(_1066) >> 9) & 127))) * 0.007874015718698502f);
                  _1073 = true;
                }
              } else {
                _1072 = 1.0f;
                _1073 = false;
              }
            } else {
              _1066 = _994;
              _1072 = (float((uint)((uint)(((uint)(_1066) >> 9) & 127))) * 0.007874015718698502f);
              _1073 = true;
            }
          } else {
            _1072 = 1.0f;
            _1073 = false;
          }
        } else {
          _1066 = _995;
          _1072 = (float((uint)((uint)(((uint)(_1066) >> 9) & 127))) * 0.007874015718698502f);
          _1073 = true;
        }
      } else {
        _1072 = 1.0f;
        _1073 = false;
      }
      float _1079 = sqrt(((_1022 * _1022) + (_1023 * _1023)) + (_1024 * _1024));
      float _1086 = _1079 / (cb13_raw[((int)(_1016 + 68u))].w);
      float _1087 = _1086 * _1086;
      float _1090 = saturate(1.0f - (_1087 * _1087));
      int _1095 = asint((cb13_raw[((int)(_1016 + 71u))].w));
      bool _1097 = ((_1095 & 1) != 0);
      bool _1099 = ((cb13_raw[((int)(_1016 + 73u))].z) > 0.0f);
      int _1107 = asint((cb13_raw[((int)(_1016 + 77u))].x));
      bool _1109 = ((_1107 & 1) != 0);
      float _1111 = (_1090 * _1090) / (((_1079 * _1079) * (cb13_raw[((int)(_1016 + 73u))].x)) + 1.0f);
      if (_1097) {
        float _1119 = rsqrt(dot(float3(_1022, _1023, _1024), float3(_1022, _1023, _1024)));
        _1140 = (exp2(log2(saturate(((cb13_raw[((int)(_1016 + 72u))].y) * dot(float3((-0.0f - (_1022 * _1119)), (-0.0f - (_1023 * _1119)), (-0.0f - (_1024 * _1119))), float3((cb13_raw[((int)(_1016 + 70u))].x), (cb13_raw[((int)(_1016 + 70u))].y), (cb13_raw[((int)(_1016 + 70u))].z)))) + (cb13_raw[((int)(_1016 + 72u))].z))) * (cb13_raw[((int)(_1016 + 72u))].w)) * _1111);
      } else {
        _1140 = _1111;
      }
      bool _1141 = (_1140 > 0.0f);
      if (_1073 && _1141) {
        _1146 = saturate(_1072);
      } else {
        _1146 = 1.0f;
      }
      if (((int)(_1099 || _1109)) && _1141) {
        float _1150 = -0.0f - _1022;
        float _1151 = -0.0f - _1023;
        float _1152 = -0.0f - _1024;
        if (_1097) {
          _1347 = mad((((cb13_raw[((int)(_1016 + 75u))].z) * (cb13_raw[((int)(_1016 + 70u))].x)) - ((cb13_raw[((int)(_1016 + 75u))].y) * (cb13_raw[((int)(_1016 + 70u))].y))), _1152, mad((((cb13_raw[((int)(_1016 + 75u))].y) * (cb13_raw[((int)(_1016 + 70u))].z)) - ((cb13_raw[((int)(_1016 + 75u))].w) * (cb13_raw[((int)(_1016 + 70u))].x))), _1151, ((((cb13_raw[((int)(_1016 + 75u))].w) * (cb13_raw[((int)(_1016 + 70u))].y)) - ((cb13_raw[((int)(_1016 + 75u))].z) * (cb13_raw[((int)(_1016 + 70u))].z))) * _1150)));
          _1348 = mad((cb13_raw[((int)(_1016 + 75u))].w), _1152, mad((cb13_raw[((int)(_1016 + 75u))].z), _1151, ((cb13_raw[((int)(_1016 + 75u))].y) * _1150)));
          _1349 = mad((cb13_raw[((int)(_1016 + 70u))].z), _1152, mad((cb13_raw[((int)(_1016 + 70u))].y), _1151, ((cb13_raw[((int)(_1016 + 70u))].x) * _1150)));
          _1350 = (cb13_raw[((int)(_1016 + 75u))].x);
          _1351 = asint((cb13_raw[((int)(_1016 + 77u))].z));
        } else {
          if (_1109) {
            float _1208 = mad((((cb13_raw[((int)(_1016 + 70u))].x) * (cb13_raw[((int)(_1016 + 72u))].z)) - ((cb13_raw[((int)(_1016 + 70u))].y) * (cb13_raw[((int)(_1016 + 72u))].y))), _1152, mad((((cb13_raw[((int)(_1016 + 70u))].z) * (cb13_raw[((int)(_1016 + 72u))].y)) - ((cb13_raw[((int)(_1016 + 70u))].x) * (cb13_raw[((int)(_1016 + 72u))].w))), _1151, ((((cb13_raw[((int)(_1016 + 70u))].y) * (cb13_raw[((int)(_1016 + 72u))].w)) - ((cb13_raw[((int)(_1016 + 70u))].z) * (cb13_raw[((int)(_1016 + 72u))].z))) * _1150)));
            float _1211 = mad((cb13_raw[((int)(_1016 + 70u))].z), _1152, mad((cb13_raw[((int)(_1016 + 70u))].y), _1151, ((cb13_raw[((int)(_1016 + 70u))].x) * _1150)));
            float _1214 = mad((cb13_raw[((int)(_1016 + 72u))].w), _1152, mad((cb13_raw[((int)(_1016 + 72u))].z), _1151, ((cb13_raw[((int)(_1016 + 72u))].y) * _1150)));
            float _1215 = -0.0f - _1208;
            float _1216 = -0.0f - _1211;
            float _1217 = -0.0f - _1214;
            float _1218 = _1215 / _1079;
            float _1219 = _1216 / _1079;
            float _1220 = _1217 / _1079;
            float _1221 = abs(_1218);
            float _1222 = abs(_1219);
            float _1223 = abs(_1220);
            bool _1227 = (_1221 > max(_1222, _1223));
            if (!((_1107 & 4) == 0)) {
              if (_1227) {
                if (_1218 > 0.0f) {
                  _1257 = _1211;
                  _1258 = _1214;
                  _1259 = _1215;
                  _1260 = (cb13_raw[((int)(_1016 + 75u))].x);
                } else {
                  _1257 = _1216;
                  _1258 = _1214;
                  _1259 = _1208;
                  _1260 = (cb13_raw[((int)(_1016 + 75u))].y);
                }
              } else {
                if (_1222 > max(_1221, _1223)) {
                  if (_1219 > 0.0f) {
                    _1257 = _1215;
                    _1258 = _1214;
                    _1259 = _1216;
                    _1260 = (cb13_raw[((int)(_1016 + 75u))].z);
                  } else {
                    _1257 = _1208;
                    _1258 = _1214;
                    _1259 = _1211;
                    _1260 = (cb13_raw[((int)(_1016 + 75u))].w);
                  }
                } else {
                  if (_1220 > 0.0f) {
                    _1257 = _1208;
                    _1258 = _1211;
                    _1259 = _1217;
                    _1260 = (cb13_raw[((int)(_1016 + 76u))].x);
                  } else {
                    _1257 = _1208;
                    _1258 = _1216;
                    _1259 = _1214;
                    _1260 = (cb13_raw[((int)(_1016 + 76u))].y);
                  }
                }
              }
              _1347 = _1257;
              _1348 = _1258;
              _1349 = _1259;
              _1350 = _1260;
              _1351 = asint((cb13_raw[((int)(_1016 + 77u))].z));
            } else {
              if (_1227) {
                int _1269 = asint((cb13_raw[((int)(_1016 + 77u))].z));
                if (_1218 > 0.0f) {
                  _1347 = _1211;
                  _1348 = _1214;
                  _1349 = _1215;
                  _1350 = (cb13_raw[((int)(_1016 + 75u))].x);
                  _1351 = _1269;
                } else {
                  _1347 = _1216;
                  _1348 = _1214;
                  _1349 = _1208;
                  _1350 = (cb13_raw[((int)(_1016 + 75u))].y);
                  _1351 = ((uint)(_1269) >> 10);
                }
              } else {
                if (_1222 > max(_1221, _1223)) {
                  if (_1219 > 0.0f) {
                    _1347 = _1215;
                    _1348 = _1214;
                    _1349 = _1216;
                    _1350 = (cb13_raw[((int)(_1016 + 75u))].z);
                    _1351 = ((uint)((uint)(asint((cb13_raw[((int)(_1016 + 77u))].z)))) >> 20);
                  } else {
                    _1347 = _1208;
                    _1348 = _1214;
                    _1349 = _1211;
                    _1350 = (cb13_raw[((int)(_1016 + 75u))].w);
                    _1351 = asint((cb13_raw[((int)(_1016 + 77u))].w));
                  }
                } else {
                  int _1296 = asint((cb13_raw[((int)(_1016 + 77u))].w));
                  if (_1220 > 0.0f) {
                    _1347 = _1208;
                    _1348 = _1211;
                    _1349 = _1217;
                    _1350 = (cb13_raw[((int)(_1016 + 76u))].x);
                    _1351 = ((uint)(_1296) >> 10);
                  } else {
                    _1347 = _1208;
                    _1348 = _1216;
                    _1349 = _1214;
                    _1350 = (cb13_raw[((int)(_1016 + 76u))].y);
                    _1351 = ((uint)(_1296) >> 20);
                  }
                }
              }
            }
          } else {
            float _1304 = _1022 / _1079;
            float _1305 = _1023 / _1079;
            float _1306 = _1024 / _1079;
            float _1307 = abs(_1304);
            float _1308 = abs(_1305);
            float _1309 = abs(_1306);
            if (_1307 > max(_1308, _1309)) {
              if (_1304 > 0.0f) {
                _1340 = _1151;
                _1341 = _1152;
                _1342 = _1022;
                _1343 = (cb13_raw[((int)(_1016 + 75u))].x);
              } else {
                _1340 = _1023;
                _1341 = _1152;
                _1342 = _1150;
                _1343 = (cb13_raw[((int)(_1016 + 75u))].y);
              }
            } else {
              if (_1308 > max(_1307, _1309)) {
                if (_1305 > 0.0f) {
                  _1340 = _1022;
                  _1341 = _1152;
                  _1342 = _1023;
                  _1343 = (cb13_raw[((int)(_1016 + 75u))].z);
                } else {
                  _1340 = _1150;
                  _1341 = _1152;
                  _1342 = _1151;
                  _1343 = (cb13_raw[((int)(_1016 + 75u))].w);
                }
              } else {
                if (_1306 > 0.0f) {
                  _1340 = _1150;
                  _1341 = _1151;
                  _1342 = _1024;
                  _1343 = (cb13_raw[((int)(_1016 + 76u))].x);
                } else {
                  _1340 = _1150;
                  _1341 = _1023;
                  _1342 = _1152;
                  _1343 = (cb13_raw[((int)(_1016 + 76u))].y);
                }
              }
            }
            _1347 = _1340;
            _1348 = _1341;
            _1349 = _1342;
            _1350 = _1343;
            _1351 = asint((cb13_raw[((int)(_1016 + 77u))].z));
          }
        }
        float _1359 = (((_1347 * (cb13_raw[((int)(_1016 + 73u))].y)) / _1349) * 0.5f) + 0.5f;
        float _1360 = 0.5f - ((mad((cb13_raw[((int)(_1016 + 73u))].y), _1348, 0.0f) / _1349) * 0.5f);
        if (_1099) {
          int _1362 = asint(_1350);
          int _1364 = ((uint)(_1362) >> 18) & 4092;
          float _1365 = float((uint)_1364);
          [branch]
          if (!(_1364 == 0)) {
            if (!_1073) {
              float _1387 = t9.SampleLevel(s10, float3((cb13_067x * ((_1359 * _1365) + float((uint)((uint)(((int)(_1362 << 2u)) & 4092))))), (cb13_067x * ((_1360 * _1365) + float((uint)((uint)(((uint)(_1362) >> 8) & 4092))))), float((uint)((uint)((uint)(_1362) >> 30)))), 0.0f);
              _1396 = (saturate(exp2((_1387.x - (_1086 * 0.9900000095367432f)) * 144.26950073242188f)) * _1146);
            } else {
              _1396 = _1146;
            }
          } else {
            _1396 = _1146;
          }
        } else {
          _1396 = _1146;
        }
        if (_1109) {
          bool _1399 = ((_1107 & 2) != 0);
          if (_1399) {
            _1409 = (_1351 & 1023);
            _1410 = 0;
          } else {
            _1409 = (_1351 & 255);
            _1410 = (((uint)(_1351) >> 8) & 3);
          }
          float _1414 = floor(cb13_raw[((int)(_1016 + 77u))].y) + float((uint)_1409);
          float4 _1418 = t42.SampleLevel(s10, float3(_1359, _1360, _1414), 0.0f);
          _46[0] = _1418.x;
          _46[1] = _1418.y;
          _46[2] = _1418.z;
          _46[3] = _1418.w;
          if (!((_1107 & 8) == 0)) {
            float4 _1429 = t42.SampleLevel(s10, float3(_1359, _1360, (_1414 + 1.0f)), 0.0f);
            float _1434 = frac(cb13_raw[((int)(_1016 + 77u))].y);
            float _1443 = ((_1429.x - _1418.x) * _1434) + _1418.x;
            float _1444 = ((_1429.y - _1418.y) * _1434) + _1418.y;
            float _1445 = ((_1429.z - _1418.z) * _1434) + _1418.z;
            _46[0] = _1443;
            _46[1] = _1444;
            _46[2] = _1445;
            _46[3] = (lerp(_1418.w, _1429.w, _1434));
            _1448 = _1445;
            _1449 = _1444;
            _1450 = _1443;
          } else {
            _1448 = _1418.z;
            _1449 = _1418.y;
            _1450 = _1418.x;
          }
          if (!_1399) {
            float _1453 = _46[_1410];
            _1455 = _1453;
            _1456 = _1453;
            _1457 = _1453;
          } else {
            _1455 = _1450;
            _1456 = _1449;
            _1457 = _1448;
          }
          _1459 = _1396;
          _1460 = _1455;
          _1461 = _1456;
          _1462 = _1457;
        } else {
          _1459 = _1396;
          _1460 = 1.0f;
          _1461 = 1.0f;
          _1462 = 1.0f;
        }
      } else {
        _1459 = _1146;
        _1460 = 1.0f;
        _1461 = 1.0f;
        _1462 = 1.0f;
      }
      if ((int)((cb13_raw[((int)(_1016 + 74u))].x) > 0.0f) && _1141) {
        if (!_1073) {
          float _1469 = t10.SampleLevel(s10, float4(_1022, _1023, _1024, (cb13_raw[((int)(_1016 + 74u))].y)), 0.0f);
          _1479 = (saturate(exp2((_1469.x - (_1086 * 0.9900000095367432f)) * 144.26950073242188f)) * _1459);
          _1484 = _1479;
          _1485 = (cb13_raw[((int)(_1016 + 70u))].w);
        } else {
          _1484 = _1459;
          _1485 = 1.0f;
        }
      } else {
        if (!_1073) {
          _1479 = _1459;
          _1484 = _1479;
          _1485 = (cb13_raw[((int)(_1016 + 70u))].w);
        } else {
          _1484 = _1459;
          _1485 = 1.0f;
        }
      }
      if ((int)(_520.z == 1.0f) || (int)((_1095 & 2048) != 0)) {
        _1497 = cb12_071y;
      } else {
        _1497 = 0.0f;
      }
      if (((int)(!(_520.z == 1.0f))) || (int)((_1095 & 4096) != 0)) {
        _1506 = cb12_071z;
      } else {
        _1506 = 0.0f;
      }
      [branch]
      if (!((CustomPixelConsts_336[3].y) == 0.0f)) {
        float _1523 = ((CustomPixelConsts_336[0].z) * cb4_023x) + (CustomPixelConsts_336[0].y);
        float _1524 = ((CustomPixelConsts_336[1].z) * cb4_023x) + (CustomPixelConsts_336[1].y);
        float _1525 = ((CustomPixelConsts_336[2].z) * cb4_023x) + (CustomPixelConsts_336[2].y);
        float _1526 = TEXCOORD_2.x - _1523;
        float _1527 = TEXCOORD_2.y - _1524;
        float _1528 = TEXCOORD_2.z - _1525;
        float _1530 = rsqrt(dot(float3(_1526, _1527, _1528), float3(_1526, _1527, _1528)));
        float _1534 = (cb13_raw[((int)(_1016 + 68u))].x) - _1523;
        float _1535 = (cb13_raw[((int)(_1016 + 68u))].y) - _1524;
        float _1536 = (cb13_raw[((int)(_1016 + 68u))].z) - _1525;
        float _1538 = rsqrt(dot(float3(_1534, _1535, _1536), float3(_1534, _1535, _1536)));
        _1549 = saturate(((0.699999988079071f - cb4_022x) + (dot(float3((_1526 * _1530), (_1527 * _1530), (_1528 * _1530)), float3((_1538 * _1534), (_1538 * _1535), (_1536 * _1538))) * 0.5f)) * 5.0f);
      } else {
        _1549 = 1.0f;
      }
      float _1553 = _1549 * (((((_1485 * (_1484 + -1.0f)) + 1.0f) * _1140) * _1497) * _1506);
      float _1554 = _1553 * _1460;
      float _1555 = _1553 * _1461;
      float _1556 = _1553 * _1462;
      [branch]
      if ((int)(_1556 > 0.0f) || ((int)((int)(_1554 > 0.0f) || (int)(_1555 > 0.0f)))) {
        if (!(FrequentPixelConsts_256.x < 0.0f)) {
          _1570 = cb12_071x;
        } else {
          _1570 = 1.0f;
        }
        float _1572 = select(((int)_1095 < (int)0), _1570, 1.0f);
        float _1577 = rsqrt(dot(float3(_1022, _1023, _1024), float3(_1022, _1023, _1024)));
        float _1578 = _1577 * _1022;
        float _1579 = _1577 * _1023;
        float _1580 = _1577 * _1024;
        if (_483 == 1) {
          int _1585 = ((int)(uint)((int)(_493 > 0.0f))) << 1u;
          float _1587 = float((int)(_1585 + -1));
          float _1589 = -1.0f / (_1587 + _493);
          float _1591 = (_491 * _492) * _1589;
          float _1595 = (((_491 * _491) * _1587) * _1589) + 1.0f;
          float _1596 = _1591 * _1587;
          float _1599 = float((int)(1 - _1585)) * _491;
          float _1602 = ((_492 * _492) * _1589) + _1587;
          float _1603 = -0.0f - _492;
          float _1605 = rsqrt(dot(float3(_1578, _1579, _1580), float3(_1578, _1579, _1580)));
          float _1606 = _1605 * _1578;
          float _1607 = _1605 * _1579;
          float _1608 = _1605 * _1580;
          float _1611 = mad(_1599, _1608, mad(_1596, _1607, (_1606 * _1595)));
          float _1614 = mad(_1603, _1608, mad(_1602, _1607, (_1606 * _1591)));
          float _1617 = mad(_493, _1608, mad(_492, _1607, (_1606 * _491)));
          float _1619 = rsqrt(dot(float3(_1611, _1614, _1617), float3(_1611, _1614, _1617)));
          float _1622 = _1619 * _1617;
          float _1624 = rsqrt(dot(float3(_516, _517, _518), float3(_516, _517, _518)));
          float _1625 = _1624 * _516;
          float _1626 = _1624 * _517;
          float _1627 = _1624 * _518;
          float _1630 = mad(_1599, _1627, mad(_1596, _1626, (_1625 * _1595)));
          float _1633 = mad(_1603, _1627, mad(_1602, _1626, (_1625 * _1591)));
          float _1636 = mad(_493, _1627, mad(_492, _1626, (_1625 * _491)));
          float _1638 = rsqrt(dot(float3(_1630, _1633, _1636), float3(_1630, _1633, _1636)));
          float _1641 = _1638 * _1636;
          float _1642 = iris_roughness * iris_roughness;
          float _1645 = dot(float3((_1619 * _1611), (_1619 * _1614), _1622), float3((_1638 * _1630), (_1638 * _1633), _1641)) - (_1641 * _1622);
          if (_1645 > 0.0f) {
            _1658 = (_1645 / max(_1622, _1641));
          } else {
            _1658 = _1645;
          }
          float _1660 = (_1642 * 0.2877933979034424f) + 1.0f;
          float _1661 = 1.0f / _1660;
          float _1665 = ((_1658 * _1642) + 1.0f) * (_1661 * 0.31830987334251404f);
          float _1669 = 1.0f - _1641;
          float _1680 = 1.0f - _1622;
          float _1693 = _1661 * ((_1642 * 0.07248824834823608f) + 1.0f);
          float _1700 = 1.0f - _1693;
          float _1715 = max(1.0000000116860974e-07f, (1.0f - ((((_1680 * _1642) * ((((((_1680 * 0.07144299894571304f) + -0.332181453704834f) * _1680) + 0.4918818771839142f) * _1680) + 0.05710852891206741f)) + 1.0f) / _1660))) * (max(1.0000000116860974e-07f, (1.0f - ((((_1669 * _1642) * ((((((_1669 * 0.07144299894571304f) + -0.332181453704834f) * _1669) + 0.4918818771839142f) * _1669) + 0.05710852891206741f)) + 1.0f) / _1660))) * 0.31830987334251404f);
          float _1719 = max(1.0000000116860974e-07f, _1700);
          float _1727 = saturate(dot(float3(_491, _492, _493), float3(_1578, _1579, _1580)));
          _1732 = (_1727 * (((_1715 * (((_475 * _475) * _1693) / (1.0f - (_1700 * _475)))) / _1719) + (_1665 * _475)));
          _1733 = (_1727 * (((_1715 * (((_476 * _476) * _1693) / (1.0f - (_1700 * _476)))) / _1719) + (_1665 * _476)));
          _1734 = (_1727 * (((_1715 * (((_477 * _477) * _1693) / (1.0f - (_1700 * _477)))) / _1719) + (_1665 * _477)));
          _1735 = 1.0f;
        } else {
          float _1653 = cb4_021x + 1.0f;
          float _1656 = saturate((dot(float3(_491, _492, _493), float3(_1578, _1579, _1580)) + cb4_021x) / _1653);
          _1732 = _1656;
          _1733 = _1656;
          _1734 = _1656;
          _1735 = (1.0f / _1653);
        }
        // Iris response uses its refracted normal; cornea highlights remain separate.
        if (improved_pbr) {
          float3 diffuse = GraphicsForwardDiffuse(float3(_491, _492, _493), float3(_516, _517, _518),
              float3(_1578, _1579, _1580), iris_roughness, float3(_475, _476, _477), _483, _1732);
          _1732 = diffuse.x; _1733 = diffuse.y; _1734 = diffuse.z;
        }
        float _1739 = 1.0f - _465;
        if (cb12_221x > 0.0f) {
          float4 _1744 = t43.SampleLevel(s10, float2(iris_roughness, dot(float3(_491, _492, _493), float3(_516, _517, _518))), 0.0f);
          float _1748 = (_1744.x * _465) + _1744.y;
          _1786 = min((_1748 / max((1.0f - ((1.0f - _1748) * ((_1739 * 0.0476190485060215f) + _465))), 0.0010000000474974513f)), 1.0f);
        } else {
          float _1758 = _1578 + _516;
          float _1759 = _1579 + _517;
          float _1760 = _1580 + _518;
          float _1762 = rsqrt(dot(float3(_1758, _1759, _1760), float3(_1758, _1759, _1760)));
          float _1769 = saturate(1.0f - abs(dot(float3((_1762 * _1758), (_1762 * _1759), (_1762 * _1760)), float3(_516, _517, _518))));
          float _1770 = _1769 * _1769;
          _1786 = ((((((_1770 * _1770) * _1769) * cb13_066x) * max(0.0f, _1739)) / ((cb13_066z + 1.0f) - (cb13_066z * (1.0f - iris_roughness)))) + _465);
        }
        float _1790 = (1.0f - _1786) * _1732;
        float _1791 = (1.0f - _1786) * _1733;
        float _1792 = (1.0f - _1786) * _1734;
        bool _1794 = ((_483 & -3) == 0);
        float _1804 = (_1572 * _1554) * (cb13_raw[((int)(_1016 + 71u))].x);
        float _1807 = (_1572 * _1555) * (cb13_raw[((int)(_1016 + 71u))].y);
        float _1810 = (_1572 * _1556) * (cb13_raw[((int)(_1016 + 71u))].z);
        [branch]
        if (dot(float3(_1578, _1579, _1580), float3(_496, _497, _498)) > 0.0f) {
          float _1819 = _1578 + _516;
          float _1820 = _1579 + _517;
          float _1821 = _1580 + _518;
          float _1823 = rsqrt(dot(float3(_1819, _1820, _1821), float3(_1819, _1820, _1821)));
          float _1824 = _1823 * _1819;
          float _1825 = _1823 * _1820;
          float _1826 = _1823 * _1821;
          float _1828 = dot(float3(_496, _497, _498), float3(_516, _517, _518));
          float _1830 = saturate(dot(float3(_496, _497, _498), float3(_1824, _1825, _1826)));
          float _1831 = saturate(dot(float3(_496, _497, _498), float3(_1578, _1579, _1580)));
          float _1832 = cornea_roughness * cornea_roughness;
          float _1833 = _1832 * _1832;
          float _1837 = ((_1830 * _1830) * (_1833 + -1.0f)) + 1.0f;
          float _1841 = abs(_1828);
          float _1845 = saturate(1.0f - abs(dot(float3(_1824, _1825, _1826), float3(_516, _517, _518))));
          float _1846 = _1845 * _1845;
          [branch]
          if (cb12_221z > 0.0f) {
            float _1864 = saturate(_1828);
            float _1867 = (_1831 * 2.0f) * _1864;
            _1886 = ((((_1864 + _1831) - _1867) * _1832) + _1867);
          } else {
            float _1872 = 1.0f - _1833;
            _1886 = (((sqrt(((_1841 * _1841) * _1872) + _1833) * _1831) + 9.999999747378752e-05f) + (sqrt(((_1831 * _1831) * _1872) + _1833) * _1841));
          }
          float _1887 = 0.5f / _1886;
          float _1889 = (((((((_1846 * _1846) * _1845) * cb13_066x) * max(0.0f, _1739)) / ((cb13_066z + 1.0f) - (cb13_066z * (1.0f - cornea_roughness)))) + _465) * (_1833 / ((_1837 * _1837) * 3.1415200233459473f))) * _1887;
          if (improved_pbr) {
            float grazing5 = _1845 * _1845;
            grazing5 *= grazing5 * _1845;
            _1889 = GraphicsDirectGGX(_1830, _1828, _1831, cornea_roughness)
                * (_465 + grazing5 * cb13_066x * max(0.f, _1739)
                    / ((cb13_066z + 1.f) - cb13_066z * (1.f - cornea_roughness)));
          }
          if (cb12_221y > 0.0f) {
            float4 _1896 = t43.SampleLevel(s10, float2(cornea_roughness, dot(float3(_496, _497, _498), float3(_1887, _1887, _1887))), 0.0f);
            float _1900 = (_1896.x * _465) + _1896.y;
            _1913 = ((min((_1900 / max((1.0f - ((1.0f - _1900) * ((_1739 * 0.0476190485060215f) + _465))), 0.0010000000474974513f)), 1.0f) / max(_1900, 9.999999747378752e-05f)) * _1889);
          } else {
            _1913 = _1889;
          }
          _1918 = (_1913 * _1831);
          _1919 = (_1913 * _1831);
          _1920 = (_1913 * _1831);
        } else {
          _1918 = 0.0f;
          _1919 = 0.0f;
          _1920 = 0.0f;
        }
        _1928 = (((_1804 * _1735) * select(_1794, (_1790 * 0.31830987334251404f), _1790)) + _1002);
        _1929 = (((_1807 * _1735) * select(_1794, (_1791 * 0.31830987334251404f), _1791)) + _1003);
        _1930 = (((_1810 * _1735) * select(_1794, (_1792 * 0.31830987334251404f), _1792)) + _1004);
        _1931 = ((_1804 * _1918) + _1005);
        _1932 = ((_1807 * _1919) + _1006);
        _1933 = ((_1810 * _1920) + _1007);
      } else {
        _1928 = _1002;
        _1929 = _1003;
        _1930 = _1004;
        _1931 = _1005;
        _1932 = _1006;
        _1933 = _1007;
      }
      int _1934 = _1008 + 1;
      if ((int)_1934 < (int)256) {
        _1002 = _1928;
        _1003 = _1929;
        _1004 = _1930;
        _1005 = _1931;
        _1006 = _1932;
        _1007 = _1933;
        _1008 = _1934;
        continue;
      } else {
        _1937 = _1928;
        _1938 = _1929;
        _1939 = _1930;
        _1940 = _1931;
        _1941 = _1932;
        _1942 = _1933;
      }
    } else {
      _1937 = _1002;
      _1938 = _1003;
      _1939 = _1004;
      _1940 = _1005;
      _1941 = _1006;
      _1942 = _1007;
    }
    break;
  }
  float _1943 = -0.0f - _516;
  float _1944 = -0.0f - _517;
  float _1945 = -0.0f - _518;
  float _1947 = dot(float3(_1943, _1944, _1945), float3(_496, _497, _498)) * 2.0f;
  float _1951 = _1943 - (_1947 * _496);
  float _1952 = _1944 - (_1947 * _497);
  float _1953 = _1945 - (_1947 * _498);
  float _1955 = rsqrt(dot(float3(_1951, _1952, _1953), float3(_1951, _1952, _1953)));
  float _1956 = _1951 * _1955;
  float _1957 = _1952 * _1955;
  float _1958 = _1953 * _1955;
  float _1959 = ddx_coarse(_1956);
  float _1960 = ddx_coarse(_1957);
  float _1961 = ddx_coarse(_1958);
  float _1962 = ddy_coarse(_1956);
  float _1963 = ddy_coarse(_1957);
  float _1964 = ddy_coarse(_1958);
  bool _1966 = ((_459 & 1) != 0);
  bool _1974 = ((_460 & 1) != 0);
  float _1981 = select(_1974, (-0.0f - _1962), _1962) + _1956;
  float _1982 = select(_1974, (-0.0f - _1963), _1963) + _1957;
  float _1983 = select(_1974, (-0.0f - _1964), _1964) + _1958;
  float _1985 = rsqrt(dot(float3(_1981, _1982, _1983), float3(_1981, _1982, _1983)));
  float _1994 = select(_1966, (-0.0f - _1959), _1959) + _1956;
  float _1995 = select(_1966, (-0.0f - _1960), _1960) + _1957;
  float _1996 = select(_1966, (-0.0f - _1961), _1961) + _1958;
  float _1998 = rsqrt(dot(float3(_1994, _1995, _1996), float3(_1994, _1995, _1996)));
  float _2009 = _461 * _461;
  float _2013 = min(max(max((_2009 * 10.5f), (max(max(0.0f, log2(acos(dot(float3(_1956, _1957, _1958), float3((_1998 * _1994), (_1998 * _1995), (_1998 * _1996)))) * 81.4873275756836f)), max(0.0f, log2(acos(dot(float3(_1956, _1957, _1958), float3((_1985 * _1981), (_1985 * _1982), (_1983 * _1985)))) * 81.4873275756836f))) * 0.625f)), 0.0f), 5.0f);
  bool _2014 = (_305 < 0.0f);
  float _2020 = min(max((1.0f / (1.0f - _305)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
  float _2028 = min(max((1.0f / (_305 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
  float _2032 = select(_2014, ((_303 * 0.5f) * _2020), ((_303 * -0.5f) * _2028)) + 0.5f;
  float _2034 = select(_2014, ((_304 * -0.5f) * _2020), ((_304 * 0.5f) * _2028)) + 0.5f;
  float _2035 = float((bool)_2014);
  if (_486) {
    _2049 = ((_2035 + 0.01515151560306549f) + (_2032 * 0.9696969985961914f));
    _2050 = ((_2034 * 0.9696969985961914f) + 0.01515151560306549f);
  } else {
    _2049 = ((_2035 + 0.1666666716337204f) + (_2032 * 0.6666666269302368f));
    _2050 = ((_2034 * 0.6666666269302368f) + 0.1666666716337204f);
  }
  float _2051 = _2049 * 0.5f;
  _2053 = 1;
  _2054 = 0.0f;
  _2055 = 0.0f;
  _2056 = 0.0f;
  _2057 = 0.0f;
  _2058 = 0.0f;
  _2059 = 0.0f;
  _2060 = 9.999999747378752e-06f;
  while(true) {
    int _2061 = _2053 * 12;
    float _2097 = 1.0f - abs(mad((cb12_raw[(_2061 + 104)].x), TEXCOORD_2.z, mad((cb12_raw[(_2061 + 103)].x), TEXCOORD_2.y, ((cb12_raw[(_2061 + 102)].x) * TEXCOORD_2.x))) + (cb12_raw[(_2061 + 105)].x));
    float _2098 = 1.0f - abs(mad((cb12_raw[(_2061 + 104)].y), TEXCOORD_2.z, mad((cb12_raw[(_2061 + 103)].y), TEXCOORD_2.y, ((cb12_raw[(_2061 + 102)].y) * TEXCOORD_2.x))) + (cb12_raw[(_2061 + 105)].y));
    float _2099 = 1.0f - abs(mad((cb12_raw[(_2061 + 104)].z), TEXCOORD_2.z, mad((cb12_raw[(_2061 + 103)].z), TEXCOORD_2.y, ((cb12_raw[(_2061 + 102)].z) * TEXCOORD_2.x))) + (cb12_raw[(_2061 + 105)].z));
    int _2103 = asint((cb12_raw[(_2061 + 106)].y));
    [branch]
    if (!(_520.z == -1.0f)) {
      _2115 = (select(((_2103 & 1) != 0), 1.0f, _520.z) * select(((_2103 & 2) != 0), 1.0f, (1.0f - _520.z)));
    } else {
      _2115 = 1.0f;
    }
    if (((int)(((int)((int)(_2097 > 0.0f) && (int)(_2098 > 0.0f))) && (int)(_2099 > 0.0f))) && (int)(_2115 > 0.0f)) {
      float _2143 = ((((_2115 * (1.0f - _2060)) * saturate((cb12_raw[(_2061 + 101)].x) * _2097)) * saturate((cb12_raw[(_2061 + 101)].y) * _2098)) * saturate((cb12_raw[(_2061 + 101)].z) * _2099)) * (cb12_raw[(_2061 + 100)].x);
      float _2146 = _2143 * (cb12_raw[(_2061 + 106)].x);
      float _2150 = float((int)(asint(cb12_raw[(_2061 + 111)].x)));
      float _2152 = (_2150 + _2050) * 0.1428571492433548f;
      if (_486) {
        float4 _2156 = t27.SampleLevel(s11, float2(_2051, _2152), 0.0f);
        _2173 = (_2156.x * _2143);
        _2174 = (_2156.y * _2143);
        _2175 = (_2156.z * _2143);
      } else {
        float4 _2165 = t22.SampleLevel(s11, float2(_2051, _2152), 1.0f);
        _2173 = (_2165.x * _2146);
        _2174 = (_2165.y * _2146);
        _2175 = (_2165.z * _2146);
      }
      float _2223 = 1.0f / mad((cb12_raw[(_2061 + 109)].x), _1953, mad((cb12_raw[(_2061 + 108)].x), _1952, ((cb12_raw[(_2061 + 107)].x) * _1951)));
      float _2224 = 1.0f / mad((cb12_raw[(_2061 + 109)].y), _1953, mad((cb12_raw[(_2061 + 108)].y), _1952, ((cb12_raw[(_2061 + 107)].y) * _1951)));
      float _2225 = 1.0f / mad((cb12_raw[(_2061 + 109)].z), _1953, mad((cb12_raw[(_2061 + 108)].z), _1952, ((cb12_raw[(_2061 + 107)].z) * _1951)));
      float _2226 = _2223 * (mad((cb12_raw[(_2061 + 109)].x), TEXCOORD_2.z, mad((cb12_raw[(_2061 + 108)].x), TEXCOORD_2.y, ((cb12_raw[(_2061 + 107)].x) * TEXCOORD_2.x))) + (cb12_raw[(_2061 + 110)].x));
      float _2227 = _2224 * (mad((cb12_raw[(_2061 + 109)].y), TEXCOORD_2.z, mad((cb12_raw[(_2061 + 108)].y), TEXCOORD_2.y, ((cb12_raw[(_2061 + 107)].y) * TEXCOORD_2.x))) + (cb12_raw[(_2061 + 110)].y));
      float _2228 = _2225 * (mad((cb12_raw[(_2061 + 109)].z), TEXCOORD_2.z, mad((cb12_raw[(_2061 + 108)].z), TEXCOORD_2.y, ((cb12_raw[(_2061 + 107)].z) * TEXCOORD_2.x))) + (cb12_raw[(_2061 + 110)].z));
      float _2242 = min(max((_2223 - _2226), ((-0.0f - _2223) - _2226)), min(max((_2224 - _2227), ((-0.0f - _2224) - _2227)), max((_2225 - _2228), ((-0.0f - _2225) - _2228))));
      float _2247 = (_2242 * _1951) + (TEXCOORD_2.x - (cb12_raw[(_2061 + 100)].y));
      float _2249 = (_2242 * _1952) + (TEXCOORD_2.y - (cb12_raw[(_2061 + 100)].z));
      float _2251 = (_2242 * _1953) + (TEXCOORD_2.z - (cb12_raw[(_2061 + 100)].w));
      float _2253 = rsqrt(dot(float3(_2247, _2249, _2251), float3(_2247, _2249, _2251)));
      float _2254 = _2247 * _2253;
      float _2255 = _2249 * _2253;
      float _2256 = _2251 * _2253;
      bool _2257 = (_2256 < 0.0f);
      float _2263 = min(max((1.0f / (1.0f - _2256)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float _2271 = min(max((1.0f / (_2256 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float4 _2288 = t23.SampleLevel(s11, float2((((float((bool)_2257) + 0.1666666716337204f) + ((select(_2257, ((_2254 * 0.5f) * _2263), ((_2254 * -0.5f) * _2271)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((_2150 + 0.1666666716337204f) + ((select(_2257, ((_2255 * -0.5f) * _2263), ((_2255 * 0.5f) * _2271)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _2013);
      _2299 = (_2143 + _2060);
      _2300 = (_2173 + _2059);
      _2301 = (_2174 + _2058);
      _2302 = (_2175 + _2057);
      _2303 = ((_2288.x * _2146) + _2056);
      _2304 = ((_2288.y * _2146) + _2055);
      _2305 = ((_2288.z * _2146) + _2054);
    } else {
      _2299 = _2060;
      _2300 = _2059;
      _2301 = _2058;
      _2302 = _2057;
      _2303 = _2056;
      _2304 = _2055;
      _2305 = _2054;
    }
    int _2306 = _2053 + 1;
    _2308 = (_2299 < 0.9990000128746033f);
    if ((int)((uint)_2306 < (uint)7) && _2308) {
      _2053 = _2306;
      _2054 = _2305;
      _2055 = _2304;
      _2056 = _2303;
      _2057 = _2302;
      _2058 = _2301;
      _2059 = _2300;
      _2060 = _2299;
      continue;
    }
    break;
  }
  [branch]
  if (_2308) {
    float _2315 = cb12_100x * (1.0f - _2299);
    float _2319 = _2315 * cb12_106x;
    float _2322 = float((int)(cb12_111x));
    float _2324 = (_2322 + _2050) * 0.1428571492433548f;
    if (_486) {
      float4 _2328 = t27.SampleLevel(s11, float2(_2051, _2324), 0.0f);
      _2345 = (_2328.x * _2315);
      _2346 = (_2328.y * _2315);
      _2347 = (_2328.z * _2315);
    } else {
      float4 _2337 = t22.SampleLevel(s11, float2(_2051, _2324), 1.0f);
      _2345 = (_2337.x * _2319);
      _2346 = (_2337.y * _2319);
      _2347 = (_2337.z * _2319);
    }
    bool _2351 = (_1953 < 0.0f);
    float _2357 = min(max((1.0f / (1.0f - _1953)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float _2365 = min(max((1.0f / (_1953 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float4 _2382 = t23.SampleLevel(s11, float2((((float((bool)_2351) + 0.1666666716337204f) + ((select(_2351, ((_1951 * 0.5f) * _2357), ((_1951 * -0.5f) * _2365)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((_2322 + 0.1666666716337204f) + ((select(_2351, ((_1952 * -0.5f) * _2357), ((_1952 * 0.5f) * _2365)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _2013);
    _2393 = (_2315 + _2299);
    _2394 = (_2345 + _2300);
    _2395 = (_2346 + _2301);
    _2396 = (_2347 + _2302);
    _2397 = ((_2382.x * _2319) + _2303);
    _2398 = ((_2382.y * _2319) + _2304);
    _2399 = ((_2382.z * _2319) + _2305);
  } else {
    _2393 = _2299;
    _2394 = _2300;
    _2395 = _2301;
    _2396 = _2302;
    _2397 = _2303;
    _2398 = _2304;
    _2399 = _2305;
  }
  float _2400 = 1.0f / _2393;
  bool _2409 = (cb12_074x > 0.0f);
  float _2419 = abs(FrequentPixelConsts_256.x) - FrequentPixelConsts_256.y;
  float _2426 = FrequentPixelConsts_256.z - FrequentPixelConsts_256.w;
  float _2433 = (_2400 * _2394) * ((_2419 * _932) + FrequentPixelConsts_256.y);
  float _2434 = (_2400 * _2395) * ((_2419 * _933) + FrequentPixelConsts_256.y);
  float _2435 = (_2400 * _2396) * ((_2419 * _934) + FrequentPixelConsts_256.y);
  float _2439 = TEXCOORD_2.x - cb12_000x;
  float _2440 = TEXCOORD_2.y - cb12_000y;
  float _2455 = ((cb12_185z + -1.0f) * saturate((cb12_219x * sqrt((_2439 * _2439) + (_2440 * _2440))) + cb12_219y)) + 1.0f;
  float _2462 = cb12_185x - cb12_185y;
  float _2469 = cb12_184z * _1937;
  float _2470 = cb12_184z * _1938;
  float _2471 = cb12_184z * _1939;
  float _2476 = abs(dot(float3(_303, _304, _305), float3(_516, _517, _518)));
  float _2480 = saturate(1.0f - abs(max(_2476, _2476)));
  float _2481 = _2480 * _2480;
  float _2483 = (_2481 * _2481) * _2480;
  float _2488 = min(1.0f, cb13_066y);
  float _2489 = 1.0f - _465;
  float _2490 = max(0.0f, _2489);
  float _2495 = (cb13_066w + 1.0f) - (cb13_066w * (1.0f - _461));
  float _2497 = _2489 - (((_2483 * _2488) * _2490) / _2495);
  if (_486) {
    if (cb12_226y > 0.0f) {
      int _2502 = ((int)(uint)((int)(_305 > 0.0f))) << 1u;
      float _2504 = float((int)(_2502 + -1));
      float _2506 = -1.0f / (_2504 + _305);
      float _2507 = _2506 * _304;
      float _2508 = _2507 * _303;
      float _2521 = rsqrt(dot(float3(_516, _517, _518), float3(_516, _517, _518)));
      float _2522 = _2521 * _516;
      float _2523 = _2521 * _517;
      float _2524 = _2521 * _518;
      float _2527 = mad((float((int)(1 - _2502)) * _303), _2524, mad((_2508 * _2504), _2523, (_2522 * ((((_303 * _303) * _2506) * _2504) + 1.0f))));
      float _2530 = mad((-0.0f - _304), _2524, mad((_2504 + (_2507 * _304)), _2523, (_2522 * _2508)));
      float _2533 = mad(_305, _2524, mad(_304, _2523, (_2522 * _303)));
      float _2538 = (_2009 * 0.2877933979034424f) + 1.0f;
      float _2540 = 1.0f - (rsqrt(dot(float3(_2527, _2530, _2533), float3(_2527, _2530, _2533))) * _2533);
      float _2550 = (((_2540 * _2009) * ((((((_2540 * 0.07144299894571304f) + -0.332181453704834f) * _2540) + 0.4918818771839142f) * _2540) + 0.05710852891206741f)) + 1.0f) / _2538;
      float _2553 = (1.0f / _2538) * ((_2009 * 0.07248824834823608f) + 1.0f);
      float _2560 = 1.0f - _2553;
      float _2573 = 1.0f - _2550;
      _2610 = ((_2497 * _2433) * (((((_475 * _475) * _2553) / (1.0f - (_2560 * _475))) * _2573) + (_2550 * _475)));
      _2611 = ((_2497 * _2434) * (((((_476 * _476) * _2553) / (1.0f - (_2560 * _476))) * _2573) + (_2550 * _476)));
      _2612 = ((_2497 * _2435) * (((((_477 * _477) * _2553) / (1.0f - (_2560 * _477))) * _2573) + (_2550 * _477)));
    } else {
      _2610 = ((_2497 * _2433) * _475);
      _2611 = ((_2497 * _2434) * _476);
      _2612 = ((_2497 * _2435) * _477);
    }
  } else {
    float _2595 = cb12_184x - cb12_184y;
    float _2602 = _2497 * _2455;
    _2610 = ((_2602 * _2433) * ((_2595 * _932) + cb12_184y));
    _2611 = ((_2602 * _2434) * ((_2595 * _933) + cb12_184y));
    _2612 = ((_2602 * _2435) * ((_2595 * _934) + cb12_184y));
  }
  float _2617 = ((((_2483 * _2490) * _2488) / _2495) + _465) * _2455;
  float _2620 = ((_2617 * select(_2409, 0.0f, (_2400 * _2397))) * ((_2426 * _932) + FrequentPixelConsts_256.w)) * ((_2462 * _932) + cb12_185y);
  float _2623 = ((_2617 * select(_2409, 0.0f, (_2400 * _2398))) * ((_2426 * _933) + FrequentPixelConsts_256.w)) * ((_2462 * _933) + cb12_185y);
  float _2626 = ((_2617 * select(_2409, 0.0f, (_2400 * _2399))) * ((_2426 * _934) + FrequentPixelConsts_256.w)) * ((_2462 * _934) + cb12_185y);
  float _2629 = 1.0f - cb13_065w;
  float _2645 = ((cb13_065x * max(0.0f, (_233 * (pow(_223.x, 2.200000047683716f))))) * ((_2629 * _932) + cb13_065w)) * water_light.ambient.x + (cb12_184w * _1940);
  float _2646 = ((cb13_065y * max(0.0f, ((pow(_223.y, 2.200000047683716f)) * _233))) * ((_2629 * _933) + cb13_065w)) * water_light.ambient.y + (cb12_184w * _1941);
  float _2647 = ((cb13_065z * max(0.0f, ((pow(_223.z, 2.200000047683716f)) * _233))) * ((_2629 * _934) + cb13_065w)) * water_light.ambient.z + (cb12_184w * _1942);
  float _2660 = (saturate(cb12_069w) * (saturate((cb12_187x * _520.x) + cb12_188x) + -1.0f)) + 1.0f;
  bool _2666 = (_520.z < 0.9900000095367432f);
  if (_2666) {
    _2671 = cb12_287w;
  } else {
    _2671 = 1.0f;
  }
  float _2675 = log2(_2660 * _520.w);
  float _2677 = exp2((cb12_288x * _2671) * _2675);
  if (_2666) {
    _2682 = cb12_287w;
  } else {
    _2682 = 1.0f;
  }
  float _2686 = exp2((_2675 * cb12_288y) * _2682);
  if (_2666) {
    _2691 = cb12_287w;
  } else {
    _2691 = 1.0f;
  }
  float _2694 = log2((_2660 * cb12_069x) + cb12_069y);
  float _2696 = exp2((_2691 * cb12_288z) * _2694);
  if (_2666) {
    _2701 = cb12_287w;
  } else {
    _2701 = 1.0f;
  }
  float _2705 = exp2((_2694 * cb12_288w) * _2701);
  if (!((cb12_340z & 4) == 0)) {
    _2724 = (_2677 * _2610);
    _2725 = (_2677 * _2611);
    _2726 = (_2677 * _2612);
    _2727 = (_2696 * _2469);
    _2728 = (_2696 * _2470);
    _2729 = (_2696 * _2471);
    _2730 = (_2705 * _2645);
    _2731 = (_2705 * _2646);
    _2732 = (_2705 * _2647);
    _2733 = (_2686 * _2620);
    _2734 = (_2686 * _2623);
    _2735 = (_2686 * _2626);
  } else {
    _2724 = _2610;
    _2725 = _2611;
    _2726 = _2612;
    _2727 = _2469;
    _2728 = _2470;
    _2729 = _2471;
    _2730 = _2645;
    _2731 = _2646;
    _2732 = _2647;
    _2733 = _2620;
    _2734 = _2623;
    _2735 = _2626;
  }
  // Attenuate environment light separately from local lamps and direct sunlight.
  _2724 *= water_light.ambient.x;
  _2725 *= water_light.ambient.y;
  _2726 *= water_light.ambient.z;
  _2733 *= water_light.ambient.x;
  _2734 *= water_light.ambient.y;
  _2735 *= water_light.ambient.z;
  if (_483 == 0) {
    _2742 = (_2727 * _475);
    _2743 = (_2728 * _476);
    _2744 = (_2729 * _477);
  } else {
    _2742 = _2727;
    _2743 = _2728;
    _2744 = _2729;
  }
  if (!_486) {
    _2750 = (_2724 * _475);
    _2751 = (_2725 * _476);
    _2752 = (_2726 * _477);
  } else {
    _2750 = _2724;
    _2751 = _2725;
    _2752 = _2726;
  }
  float _2753 = _2742 + _2730;
  float _2754 = _2743 + _2731;
  float _2755 = _2744 + _2732;
  if (!_2409) {
    _2761 = (_2753 + _2733);
    _2762 = (_2754 + _2734);
    _2763 = (_2755 + _2735);
  } else {
    _2761 = _2753;
    _2762 = _2754;
    _2763 = _2755;
  }
  SV_Target.x = (_2750 + _2761);
  SV_Target.y = (_2751 + _2762);
  SV_Target.z = (_2752 + _2763);
  SV_Target.w = 1.0f;
  return SV_Target;
}
