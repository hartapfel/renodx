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


Texture2D<float4> t12 : register(t12);

Texture2D<float4> t17 : register(t17);

Texture2D<float4> t18 : register(t18);

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

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

cbuffer cb12 : register(b12) {
  float4 cb12_raw[341] : packoffset(c0);
};

#define cb12_000y (cb12_raw[0].y)
#define cb12_036x (cb12_raw[36].x)
#define cb12_220y (cb12_raw[220].y)
#define cb12_024x (cb12_raw[24].x)
#define cb12_036y (cb12_raw[36].y)
#define cb12_000x (cb12_raw[0].x)
#define cb12_000z (cb12_raw[0].z)
#define cb12_188x (cb12_raw[188].x)
#define cb12_221x (cb12_raw[221].x)
#define cb12_037z (cb12_raw[37].z)
#define cb12_036w (cb12_raw[36].w)
#define cb12_036z (cb12_raw[36].z)
#define cb12_219z (cb12_raw[219].z)
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
#define cb12_069z (cb12_raw[69].z)
#define cb12_069x (cb12_raw[69].x)
#define cb12_287w (cb12_raw[287].w)
#define cb12_288z (cb12_raw[288].z)
#define cb12_288w (cb12_raw[288].w)

cbuffer cb4 : register(b4) {
  float cb4_000x : packoffset(c000.x);
  float cb4_000y : packoffset(c000.y);
  float cb4_000z : packoffset(c000.z);
  float cb4_000w : packoffset(c000.w);
  float cb4_001x : packoffset(c001.x);
  float cb4_002x : packoffset(c002.x);
  float cb4_003x : packoffset(c003.x);
  float cb4_004x : packoffset(c004.x);
  float cb4_005x : packoffset(c005.x);
  float cb4_005y : packoffset(c005.y);
  float cb4_005z : packoffset(c005.z);
  float cb4_006x : packoffset(c006.x);
  float cb4_007x : packoffset(c007.x);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
  float cb4_010x : packoffset(c010.x);
  float cb4_011x : packoffset(c011.x);
  float cb4_012x : packoffset(c012.x);
  float cb4_013x : packoffset(c013.x);
  float cb4_014x : packoffset(c014.x);
  float cb4_014y : packoffset(c014.y);
  float cb4_015x : packoffset(c015.x);
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

SamplerState s12 : register(s12);

SamplerState s11 : register(s11);

SamplerState s0 : register(s0);

SamplerState s10 : register(s10);

SamplerState s7 : register(s7);

#include "lighting/contact/forward.hlsli"

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2,
  linear float4 TEXCOORD_3 : TEXCOORD3,
  linear float4 TEXCOORD_4 : TEXCOORD4,
  linear float4 TEXCOORD_5 : TEXCOORD5,
  linear float3 TEXCOORD_6 : TEXCOORD6,
  noperspective float4 SV_Position : SV_Position,
  nointerpolation uint SV_IsFrontFace : SV_IsFrontFace
) : SV_Target {
  float4 SV_Target = 0;
  bool _2681;
  bool _2486;
  float _59[4];
  float4 _62 = t0.Sample(s0, float2(TEXCOORD_2.x, TEXCOORD_2.y));
  float _253;
  float _254;
  float _255;
  float _256;
  float _257;
  float _258;
  float _259;
  float _260;
  float _261;
  float _262;
  float _263;
  float _264;
  float _282;
  float _345;
  float _346;
  float _347;
  float _587;
  float _672;
  float _673;
  float _674;
  float _675;
  float _676;
  float _677;
  float _758;
  float _759;
  float _760;
  float _804;
  float _805;
  float _806;
  float _876;
  float _877;
  float _878;
  float _879;
  float _1058;
  float _1113;
  float _1114;
  float _1115;
  float _1120;
  float _1121;
  float _1122;
  float _1130;
  float _1131;
  float _1132;
  float _1133;
  float _1134;
  float _1135;
  float _1136;
  float _1137;
  float _1138;
  int _1157;
  int _1163;
  int _1169;
  int _1175;
  int _1181;
  int _1187;
  int _1193;
  int _1199;
  int _1200;
  int _1201;
  int _1202;
  int _1203;
  int _1204;
  int _1205;
  int _1206;
  int _1207;
  float _1209;
  float _1210;
  float _1211;
  float _1212;
  float _1213;
  float _1214;
  int _1215;
  int _1273;
  float _1279;
  bool _1280;
  float _1347;
  float _1353;
  float _1464;
  float _1465;
  float _1466;
  float _1467;
  float _1547;
  float _1548;
  float _1549;
  float _1550;
  float _1554;
  float _1555;
  float _1556;
  float _1557;
  int _1558;
  float _1603;
  int _1616;
  int _1617;
  float _1655;
  float _1656;
  float _1657;
  float _1662;
  float _1663;
  float _1664;
  float _1666;
  float _1667;
  float _1668;
  float _1669;
  float _1686;
  float _1689;
  float _1690;
  float _1702;
  float _1711;
  float _1731;
  float _1824;
  float _1906;
  float _1907;
  float _1908;
  float _1989;
  float _1990;
  float _1991;
  float _2035;
  float _2036;
  float _2037;
  float _2107;
  float _2108;
  float _2109;
  float _2110;
  float _2250;
  float _2305;
  float _2306;
  float _2307;
  float _2312;
  float _2313;
  float _2314;
  float _2322;
  float _2323;
  float _2324;
  float _2325;
  float _2326;
  float _2327;
  float _2331;
  float _2332;
  float _2333;
  float _2334;
  float _2335;
  float _2336;
  int _2354;
  float _2355;
  float _2356;
  float _2357;
  float _2358;
  float _2480;
  float _2481;
  float _2482;
  float _2483;
  float _2544;
  float _2545;
  float _2546;
  float _2547;
  int _2549;
  float _2550;
  float _2551;
  float _2552;
  float _2553;
  float _2675;
  float _2676;
  float _2677;
  float _2678;
  float _2740;
  float _2741;
  float _2742;
  float _2743;
  float _2898;
  float _2899;
  float _2900;
  float _2901;
  float _2902;
  int _2903;
  float _3008;
  float _3009;
  float _3064;
  float _3065;
  float _3116;
  float _3130;
  float _3131;
  float _3132;
  float _3133;
  float _3134;
  float _3160;
  float _3161;
  float _3162;
  float _3163;
  float _3166;
  float _3167;
  float _3168;
  float _3170;
  float _3171;
  float _3172;
  int _3173;
  int _3174;
  float _3175;
  float _3251;
  float _3252;
  float _3253;
  float _3254;
  float _3255;
  int _3256;
  float _3369;
  float _3370;
  float _3421;
  float _3422;
  float _3473;
  float _3487;
  float _3488;
  float _3489;
  float _3490;
  float _3491;
  float _3517;
  float _3518;
  float _3519;
  float _3520;
  float _3524;
  float _3525;
  float _3526;
  int _3527;
  float _3528;
  float _3529;
  int _3530;
  float _3531;
  float _3532;
  float _3533;
  float _3579;
  float _3580;
  float _3619;
  float _3620;
  float _3621;
  float _3622;
  float _3643;
  float _3644;
  float _3645;
  bool _3646;
  float _3744;
  float _3755;
  float _3765;
  float _3796;
  float _3797;
  float _3798;
  [branch]
  if (!(FrequentPixelConsts_288.y == 0.0f)) {
    float4 _75 = t18.Load(int3(int(fmod(SV_Position.x, 16.0f)), int(fmod(SV_Position.y, 16.0f)), 0));
    bool _79 = (((_75.x * TEXCOORD_1.x) + TEXCOORD_1.y) < 0.0f);
    if (_79) discard;
  }
  [branch]
  if (!(FrequentPixelConsts_288.z == 0.0f)) {
    float4 _87 = t12.Sample(s12, float2(TEXCOORD_2.z, TEXCOORD_2.w));
    bool _91 = (((_87.x * TEXCOORD_1.z) + TEXCOORD_1.w) < 0.0f);
    if (_91) discard;
  }
  [branch]
  if (!(FrequentPixelConsts_288.w == 0.0f)) {
    bool _99 = ((dot(float3(TEXCOORD.x, TEXCOORD.y, TEXCOORD.z), float3(TEXCOORD.x, TEXCOORD.y, TEXCOORD.z)) + -1.0f) < 0.0f);
    if (_99) discard;
  }
  float4 _103 = t0.Sample(s0, float2(TEXCOORD_2.x, TEXCOORD_2.y));
  float _116 = (_103.x + _103.y) + _103.z;
  float _119 = (cb4_001x + -1.0f) * 0.5f;
  float _127 = saturate((((1.0f - (_116 * 0.6665999889373779f)) * saturate(_119)) + (_116 * 0.33329999446868896f)) * abs(_119));
  float _148 = ((saturate((_103.x * 1.5f) * cb4_000x) - _103.x) * _127) + _103.x;
  float _149 = ((saturate((_103.y * 1.5f) * cb4_000y) - _103.y) * _127) + _103.y;
  float _150 = ((saturate((_103.z * 1.5f) * cb4_000z) - _103.z) * _127) + _103.z;
  float _151 = ((saturate((_103.w * 1.5f) * cb4_000w) - _103.w) * _127) + _103.w;
  float _167 = _150 + _148;
  float _171 = saturate(((_150 / _167) + -0.30000001192092896f) * 1.4285714626312256f);
  [branch]
  if (cb4_003x > 0.0f) {
    float _181 = _171 / (_171 + saturate(((_148 / _167) + -0.30000001192092896f) * 1.4285714626312256f));
    float _182 = 1.0f - _181;
    _253 = (((FrequentPixelConsts_112[0].x) * _182) + (_181 * (FrequentPixelConsts_176[0].z)));
    _254 = (((FrequentPixelConsts_112[0].y) * _182) + (_181 * (FrequentPixelConsts_176[0].y)));
    _255 = (((FrequentPixelConsts_112[0].z) * _182) + (_181 * (FrequentPixelConsts_176[0].x)));
    _256 = (((FrequentPixelConsts_112[0].w) * _182) + (_181 * (FrequentPixelConsts_176[0].w)));
    _257 = (((FrequentPixelConsts_112[1].x) * _182) + (_181 * (FrequentPixelConsts_176[1].z)));
    _258 = (((FrequentPixelConsts_112[1].y) * _182) + (_181 * (FrequentPixelConsts_176[1].y)));
    _259 = (((FrequentPixelConsts_112[1].z) * _182) + (_181 * (FrequentPixelConsts_176[1].x)));
    _260 = (((FrequentPixelConsts_112[1].w) * _182) + (_181 * (FrequentPixelConsts_176[1].w)));
    _261 = (((FrequentPixelConsts_112[2].x) * _182) + (_181 * (FrequentPixelConsts_176[2].z)));
    _262 = (((FrequentPixelConsts_112[2].y) * _182) + (_181 * (FrequentPixelConsts_176[2].y)));
    _263 = (((FrequentPixelConsts_112[2].z) * _182) + (_181 * (FrequentPixelConsts_176[2].x)));
    _264 = (((FrequentPixelConsts_112[2].w) * _182) + (_181 * (FrequentPixelConsts_176[2].w)));
  } else {
    if (!(!(_148 >= _150))) {
      _253 = (FrequentPixelConsts_112[0].x);
      _254 = (FrequentPixelConsts_112[0].y);
      _255 = (FrequentPixelConsts_112[0].z);
      _256 = (FrequentPixelConsts_112[0].w);
      _257 = (FrequentPixelConsts_112[1].x);
      _258 = (FrequentPixelConsts_112[1].y);
      _259 = (FrequentPixelConsts_112[1].z);
      _260 = (FrequentPixelConsts_112[1].w);
      _261 = (FrequentPixelConsts_112[2].x);
      _262 = (FrequentPixelConsts_112[2].y);
      _263 = (FrequentPixelConsts_112[2].z);
      _264 = (FrequentPixelConsts_112[2].w);
    } else {
      _253 = (FrequentPixelConsts_176[0].z);
      _254 = (FrequentPixelConsts_176[0].y);
      _255 = (FrequentPixelConsts_176[0].x);
      _256 = (FrequentPixelConsts_176[0].w);
      _257 = (FrequentPixelConsts_176[1].z);
      _258 = (FrequentPixelConsts_176[1].y);
      _259 = (FrequentPixelConsts_176[1].x);
      _260 = (FrequentPixelConsts_176[1].w);
      _261 = (FrequentPixelConsts_176[2].z);
      _262 = (FrequentPixelConsts_176[2].y);
      _263 = (FrequentPixelConsts_176[2].x);
      _264 = (FrequentPixelConsts_176[2].w);
    }
  }
  float _266 = max(_148, max(_149, _150));
  [branch]
  if (cb4_004x > 0.0f) {
    _282 = (saturate((((_266 - min(_148, min(_149, _150))) / _266) + -0.10000000149011612f) * 5.0f) * cb4_002x);
  } else {
    _282 = cb4_002x;
  }
  float4 _309 = t1.Sample(s0, float2(TEXCOORD_2.x, TEXCOORD_2.y));
  float _316 = (_309.x + -0.5f) * 2.0f;
  float _317 = (_309.y + -0.5f) * 2.0f;
  float _318 = (_309.z + -0.5f) * 2.0f;
  float _331 = ((_316 * TEXCOORD_6.x) + (_317 * TEXCOORD_4.x)) + (_318 * TEXCOORD_5.x);
  float _332 = ((_316 * TEXCOORD_6.y) + (_317 * TEXCOORD_4.y)) + (_318 * TEXCOORD_5.y);
  float _333 = ((_316 * TEXCOORD_6.z) + (_317 * TEXCOORD_4.z)) + (_318 * TEXCOORD_5.z);
  [branch]
  if (SV_IsFrontFace == 0) {
    float _337 = dot(float3(TEXCOORD_5.x, TEXCOORD_5.y, TEXCOORD_5.z), float3(_331, _332, _333)) * 2.0f;
    _345 = (_331 - (_337 * TEXCOORD_5.x));
    _346 = (_332 - (_337 * TEXCOORD_5.y));
    _347 = (_333 - (_337 * TEXCOORD_5.z));
  } else {
    _345 = _331;
    _346 = _332;
    _347 = _333;
  }
  float4 _354 = t1.Sample(s0, float2(TEXCOORD_2.x, TEXCOORD_2.y));
  float _371 = cb4_007x + ((1.0f - _354.w) * cb4_006x);
  float _393 = cb1_036x - TEXCOORD.w;
  float _394 = cb1_036y - TEXCOORD_4.w;
  float _395 = cb1_036z - TEXCOORD_5.w;
  float _397 = rsqrt(dot(float3(_393, _394, _395), float3(_393, _394, _395)));
  float _403 = saturate(1.0f - dot(float3(_331, _332, _333), float3((_393 * _397), (_394 * _397), (_395 * _397))));
  float _416 = saturate(cb4_011x);
  float4 _424 = t2.Sample(s0, float2((cb4_014x * TEXCOORD_2.x), (cb4_014y * TEXCOORD_2.y)));
  float _429 = (_424.x + -0.5f) * cb4_015x;
  uint _434 = uint(SV_Position.x);
  uint _435 = uint(SV_Position.y);
  float _436 = saturate((cb4_009x * exp2(log2(_403 * _403) * cb4_008x)) * cb4_010x);
  float _437 = saturate(_354.w);
  float _447 = exp2(log2(saturate(exp2(log2(saturate(_371 * (pow(cb4_005x, 2.200000047683716f)))) * 0.4545449912548065f))) * 2.200000047683716f);
  float _448 = exp2(log2(saturate(exp2(log2(saturate(_371 * (pow(cb4_005y, 2.200000047683716f)))) * 0.4545449912548065f))) * 2.200000047683716f);
  float _449 = exp2(log2(saturate(exp2(log2(saturate(_371 * (pow(cb4_005z, 2.200000047683716f)))) * 0.4545449912548065f))) * 2.200000047683716f);
  float _459 = exp2(log2(saturate((((mad(_151, _256, mad(_150, _255, mad(_149, _254, (_253 * _148)))) - _148) * _282) + _148) * TEXCOORD_3.x)) * 2.200000047683716f);
  float _460 = exp2(log2(saturate((((mad(_151, _260, mad(_150, _259, mad(_149, _258, (_257 * _148)))) - _149) * _282) + _149) * TEXCOORD_3.y)) * 2.200000047683716f);
  float _461 = exp2(log2(saturate((((mad(_151, _264, mad(_150, _263, mad(_149, _262, (_261 * _148)))) - _150) * _282) + _150) * TEXCOORD_3.z)) * 2.200000047683716f);
  int _464 = int(cb12_220y);
  float _466 = rsqrt(dot(float3(_345, _346, _347), float3(_345, _346, _347)));
  float _467 = _466 * _345;
  float _468 = _466 * _346;
  float _469 = _466 * _347;
  float _471 = rsqrt(dot(float3(TEXCOORD_5.x, TEXCOORD_5.y, TEXCOORD_5.z), float3(TEXCOORD_5.x, TEXCOORD_5.y, TEXCOORD_5.z)));
  float _472 = _471 * TEXCOORD_5.x;
  float _473 = _471 * TEXCOORD_5.y;
  float _474 = _471 * TEXCOORD_5.z;
  float _487 = cb12_000x - TEXCOORD.w;
  float _488 = cb12_000y - TEXCOORD_4.w;
  float _489 = cb12_000z - TEXCOORD_5.w;
  float _491 = rsqrt(dot(float3(_487, _488, _489), float3(_487, _488, _489)));
  float _492 = _487 * _491;
  float _493 = _488 * _491;
  float _494 = _489 * _491;
  bool improved_pbr = graphics_injection.layout_version == 1.f
      && graphics_injection.graphics_mode != 0.f && graphics_injection.pbr_mode != 0.f
      && (_464 == 0 || _464 == 1);
  // Evaluate quad derivatives before the divergent light/shadow branches.
  float direct_roughness = GraphicsForwardRoughness(float3(_467, _468, _469), _437);
  direct_roughness = improved_pbr ? direct_roughness : _437;
  float4 _496 = t17.Load(int3(_434, _435, 0));
  float graphics_sun_visibility = min(_496.y, GraphicsForwardContact(float3(TEXCOORD.w, TEXCOORD_4.w, TEXCOORD_5.w),
      float3(_467, _468, _469), SV_Position.xy, false));
  GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
      float3(TEXCOORD.w, TEXCOORD_4.w, TEXCOORD_5.w), float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
  if (_496.y > 0.0f) {
    float _509 = saturate((dot(float3(_472, _473, _474), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + cb4_012x) / (cb4_012x + 1.0f));
    float _510 = dot(float3(_467, _468, _469), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
    float _512 = _509 + 1.0f;
    float _515 = saturate((_510 + _509) / _512);
    if (_464 == 1) {
      float _518 = saturate(_510);
      int _521 = ((int)(uint)((int)(_469 > 0.0f))) << 1u;
      float _523 = float((int)(_521 + -1));
      float _525 = -1.0f / (_523 + _469);
      float _527 = (_467 * _468) * _525;
      float _531 = (((_467 * _467) * _523) * _525) + 1.0f;
      float _532 = _527 * _523;
      float _535 = float((int)(1 - _521)) * _467;
      float _538 = ((_468 * _468) * _525) + _523;
      float _539 = -0.0f - _468;
      float _541 = rsqrt(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
      float _542 = _541 * water_light.sun.x;
      float _543 = _541 * water_light.sun.y;
      float _544 = _541 * water_light.sun.z;
      float _547 = mad(_535, _544, mad(_532, _543, (_542 * _531)));
      float _550 = mad(_539, _544, mad(_538, _543, (_542 * _527)));
      float _553 = mad(_469, _544, mad(_468, _543, (_542 * _467)));
      float _555 = rsqrt(dot(float3(_547, _550, _553), float3(_547, _550, _553)));
      float _558 = _555 * _553;
      float _560 = rsqrt(dot(float3(_492, _493, _494), float3(_492, _493, _494)));
      float _561 = _560 * _492;
      float _562 = _560 * _493;
      float _563 = _560 * _494;
      float _566 = mad(_535, _563, mad(_532, _562, (_561 * _531)));
      float _569 = mad(_539, _563, mad(_538, _562, (_561 * _527)));
      float _572 = mad(_469, _563, mad(_468, _562, (_561 * _467)));
      float _574 = rsqrt(dot(float3(_566, _569, _572), float3(_566, _569, _572)));
      float _577 = _574 * _572;
      float _578 = _437 * _437;
      float _581 = dot(float3((_555 * _547), (_555 * _550), _558), float3((_574 * _566), (_574 * _569), _577)) - (_577 * _558);
      if (_581 > 0.0f) {
        _587 = (_581 / max(_558, _577));
      } else {
        _587 = _581;
      }
      float _589 = (_578 * 0.2877933979034424f) + 1.0f;
      float _590 = 1.0f / _589;
      float _591 = _459 * 0.31830987334251404f;
      float _592 = _460 * 0.31830987334251404f;
      float _593 = _461 * 0.31830987334251404f;
      float _596 = ((_587 * _578) + 1.0f) * _590;
      float _600 = 1.0f - _577;
      float _611 = 1.0f - _558;
      float _624 = _590 * ((_578 * 0.07248824834823608f) + 1.0f);
      float _631 = 1.0f - _624;
      float _646 = max(1.0000000116860974e-07f, (1.0f - ((((_611 * _578) * ((((((_611 * 0.07144299894571304f) + -0.332181453704834f) * _611) + 0.4918818771839142f) * _611) + 0.05710852891206741f)) + 1.0f) / _589))) * (max(1.0000000116860974e-07f, (1.0f - ((((_600 * _578) * ((((((_600 * 0.07144299894571304f) + -0.332181453704834f) * _600) + 0.4918818771839142f) * _600) + 0.05710852891206741f)) + 1.0f) / _589))) * 0.31830987334251404f);
      float _650 = max(1.0000000116860974e-07f, _631);
      float _661 = max(0.0f, (_515 - _518));
      float _665 = (_661 * _591) + ((((_646 * (((_459 * _459) * _624) / (1.0f - (_631 * _459)))) / _650) + (_596 * _591)) * _518);
      float _666 = (_661 * _592) + ((((_646 * (((_460 * _460) * _624) / (1.0f - (_631 * _460)))) / _650) + (_596 * _592)) * _518);
      float _667 = ((((_646 * (((_461 * _461) * _624) / (1.0f - (_631 * _461)))) / _650) + (_596 * _593)) * _518) + (_661 * _593);
      _672 = _665;
      _673 = _666;
      _674 = _667;
      _675 = (_665 * 3.1415927410125732f);
      _676 = (_666 * 3.1415927410125732f);
      _677 = (_667 * 3.1415927410125732f);
    } else {
      _672 = _515;
      _673 = _515;
      _674 = _515;
      _675 = _515;
      _676 = _515;
      _677 = _515;
    }
    // Keep the native wrap, transmission and anisotropic specular paths.
    if (improved_pbr) {
      float3 diffuse = GraphicsForwardDiffuse(float3(_467, _468, _469), float3(_492, _493, _494),
          float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), direct_roughness, float3(_459, _460, _461), _464, _515);
      _672 = diffuse.x; _673 = diffuse.y; _674 = diffuse.z;
    }
    float _681 = 1.0f - _447;
    float _682 = 1.0f - _448;
    float _683 = 1.0f - _449;
    if (cb12_221x > 0.0f) {
      float4 _688 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_467, _468, _469), float3(_492, _493, _494))), 0.0f);
      float _694 = (_688.x * _447) + _688.y;
      float _695 = (_688.x * _448) + _688.y;
      float _696 = (_688.x * _449) + _688.y;
      _758 = min((_694 / max((1.0f - ((1.0f - _694) * ((_681 * 0.0476190485060215f) + _447))), 0.0010000000474974513f)), 1.0f);
      _759 = min((_695 / max((1.0f - ((1.0f - _695) * ((_682 * 0.0476190485060215f) + _448))), 0.0010000000474974513f)), 1.0f);
      _760 = min((_696 / max((1.0f - ((1.0f - _696) * ((_683 * 0.0476190485060215f) + _449))), 0.0010000000474974513f)), 1.0f);
    } else {
      float _722 = water_light.sun.x + _492;
      float _723 = water_light.sun.y + _493;
      float _724 = water_light.sun.z + _494;
      float _726 = rsqrt(dot(float3(_722, _723, _724), float3(_722, _723, _724)));
      float _733 = saturate(1.0f - abs(dot(float3((_726 * _722), (_726 * _723), (_726 * _724)), float3(_492, _493, _494))));
      float _734 = _733 * _733;
      float _744 = ((_734 * _734) * _733) * cb13_066x;
      float _750 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
      _758 = (((_744 * max(0.0f, _681)) / _750) + _447);
      _759 = (((_744 * max(0.0f, _682)) / _750) + _448);
      _760 = (((_744 * max(0.0f, _683)) / _750) + _449);
    }
    float _764 = (1.0f - _758) * _672;
    float _765 = (1.0f - _759) * _673;
    float _766 = (1.0f - _760) * _674;
    bool _768 = ((_464 & -3) == 0);
    float _772 = select(_768, (_764 * 0.31830987334251404f), _764);
    float _773 = select(_768, (_765 * 0.31830987334251404f), _765);
    float _774 = select(_768, (_766 * 0.31830987334251404f), _766);
    [branch]
    if (!(_436 > 0.0f)) {
      _876 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_467, _468, _469));
      _877 = _772;
      _878 = _773;
      _879 = _774;
    } else {
      bool _784 = (_464 == 0);
      if (!(cb12_037z == 0.0f)) {
        float _789 = dot(float3(_459, _460, _461), float3(0.21250000596046448f, 0.715399980545044f, 0.07209999859333038f));
        if (!_784) {
          _804 = saturate(lerp(_789, _459, cb12_036w));
          _805 = saturate(lerp(_789, _460, cb12_036w));
          _806 = saturate(lerp(_789, _461, cb12_036w));
        } else {
          _804 = 1.0f;
          _805 = 1.0f;
          _806 = 1.0f;
        }
        float _807 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_492, _493, _494));
        float _808 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_467, _468, _469));
        float _822 = ((_436 * 0.31830987334251404f) * exp2(log2(abs(_808)) * cb12_036z)) * (exp2((_807 + cb12_036y) * -4.328084945678711f) + exp2((_807 + cb12_036x) * -1.4426950216293335f));
        _876 = _808;
        _877 = ((_822 * _804) + _772);
        _878 = ((_822 * _805) + _773);
        _879 = ((_822 * _806) + _774);
      } else {
        float _830 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_467, _468, _469));
        float _832 = (_830 + 1.0f) * 0.5f;
        float _833 = -0.0f - _492;
        float _834 = -0.0f - _493;
        float _835 = -0.0f - _494;
        float _838 = (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_833, _834, _835)) + 1.0f) * 0.5f;
        float _841 = _838 * _838;
        float _843 = select(_784, 1.0f, _459);
        float _844 = select(_784, 1.0f, _460);
        float _845 = select(_784, 1.0f, _461);
        float _855 = cb12_036y * _436;
        float _868 = (((_436 * 0.5f) * cb12_036w) * (dot(float3(_467, _468, _469), float3(_833, _834, _835)) + 1.0f)) * ((((_841 * _841) - _832) * cb12_036x) + _832);
        _876 = _830;
        _877 = ((((((_843 * _681) * cb12_036z) - _772) * _855) + _772) + (_868 * _843));
        _878 = ((((((_844 * _682) * cb12_036z) - _773) * _855) + _773) + (_868 * _844));
        _879 = ((((((_845 * _683) * cb12_036z) - _774) * _855) + _774) + (_868 * _845));
      }
    }
    float _880 = TEXCOORD.w - cb12_000x;
    float _881 = TEXCOORD_4.w - cb12_000y;
    float _891 = saturate((cb12_219z * TEXCOORD_5.w) + cb12_219w);
    float _913 = saturate((cb12_219x * sqrt((_880 * _880) + (_881 * _881))) + cb12_219y);
    float _924 = ((((lerp(cb13_062x, cb13_061x, _891)) - cb13_001x) * _913) + cb13_001x) * water_light.direct.x;
    float _925 = ((((lerp(cb13_062y, cb13_061y, _891)) - cb13_001y) * _913) + cb13_001y) * water_light.direct.y;
    float _926 = ((((lerp(cb13_062z, cb13_061z, _891)) - cb13_001z) * _913) + cb13_001z) * water_light.direct.z;
    float _927 = (1.0f / _512) * graphics_sun_visibility;
    [branch]
    if (_876 > 0.0f) {
      float _936 = water_light.sun.x + _492;
      float _937 = water_light.sun.y + _493;
      float _938 = water_light.sun.z + _494;
      float _940 = rsqrt(dot(float3(_936, _937, _938), float3(_936, _937, _938)));
      float _941 = _940 * _936;
      float _942 = _940 * _937;
      float _943 = _940 * _938;
      float _944 = dot(float3(_467, _468, _469), float3(_492, _493, _494));
      float _945 = saturate(_510);
      float _946 = direct_roughness * direct_roughness;
      float _949 = max(9.999999747378752e-05f, _946);
      float _950 = max(9.999999747378752e-05f, (_946 * (1.0f - _416)));
      float _952 = rsqrt(dot(float3(TEXCOORD_6.x, TEXCOORD_6.y, TEXCOORD_6.z), float3(TEXCOORD_6.x, TEXCOORD_6.y, TEXCOORD_6.z)));
      float _953 = _952 * TEXCOORD_6.x;
      float _954 = _952 * TEXCOORD_6.y;
      float _955 = _952 * TEXCOORD_6.z;
      float _956 = dot(float3(_953, _954, _955), float3(_467, _468, _469));
      float _960 = _953 - (_956 * _467);
      float _961 = _954 - (_956 * _468);
      float _962 = _955 - (_956 * _469);
      float _964 = rsqrt(dot(float3(_960, _961, _962), float3(_960, _961, _962)));
      float _965 = _960 * _964;
      float _966 = _961 * _964;
      float _967 = _962 * _964;
      float _980 = ((_966 * _469) - (_967 * _468)) + (_467 * _429);
      float _981 = ((_967 * _467) - (_965 * _469)) + (_468 * _429);
      float _982 = ((_965 * _468) - (_966 * _467)) + (_469 * _429);
      float _984 = rsqrt(dot(float3(_980, _981, _982), float3(_980, _981, _982)));
      float _989 = dot(float3(_965, _966, _967), float3(_941, _942, _943)) / _949;
      float _992 = dot(float3((_980 * _984), (_981 * _984), (_982 * _984)), float3(_941, _942, _943)) / _950;
      float _995 = saturate(dot(float3(_467, _468, _469), float3(_941, _942, _943)));
      float _998 = ((_992 * _992) + (_989 * _989)) + (_995 * _995);
      float _1004 = abs(_944);
      float _1008 = saturate(1.0f - abs(dot(float3(_941, _942, _943), float3(_492, _493, _494))));
      float _1009 = _1008 * _1008;
      float _1019 = ((_1009 * _1009) * _1008) * cb13_066x;
      float _1025 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
      [branch]
      if (cb12_221z > 0.0f) {
        float _1035 = saturate(_944);
        float _1038 = (_945 * 2.0f) * _1035;
        _1058 = ((((_1035 + _945) - _1038) * _946) + _1038);
      } else {
        float _1043 = _946 * _946;
        float _1044 = 1.0f - _1043;
        _1058 = (((sqrt(((_1004 * _1004) * _1044) + _1043) * _945) + 9.999999747378752e-05f) + (sqrt(((_945 * _945) * _1044) + _1043) * _1004));
      }
      float _1059 = 0.5f / _1058;
      float _1060 = _1059 * (1.0f / ((_998 * _998) * ((_949 * 3.1415200233459473f) * _950)));
      float _1061 = _1060 * (((_1019 * max(0.0f, _681)) / _1025) + _447);
      float _1062 = _1060 * (((_1019 * max(0.0f, _682)) / _1025) + _448);
      float _1063 = _1060 * (((_1019 * max(0.0f, _683)) / _1025) + _449);
      if (cb12_221y > 0.0f) {
        float4 _1070 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_467, _468, _469), float3(_1059, _1059, _1059))), 0.0f);
        float _1076 = (_1070.x * _447) + _1070.y;
        float _1077 = (_1070.x * _448) + _1070.y;
        float _1078 = (_1070.x * _449) + _1070.y;
        _1113 = ((min((_1076 / max((1.0f - ((1.0f - _1076) * ((_681 * 0.0476190485060215f) + _447))), 0.0010000000474974513f)), 1.0f) / max(_1076, 9.999999747378752e-05f)) * _1061);
        _1114 = ((min((_1077 / max((1.0f - ((1.0f - _1077) * ((_682 * 0.0476190485060215f) + _448))), 0.0010000000474974513f)), 1.0f) / max(_1077, 9.999999747378752e-05f)) * _1062);
        _1115 = ((min((_1078 / max((1.0f - ((1.0f - _1078) * ((_683 * 0.0476190485060215f) + _449))), 0.0010000000474974513f)), 1.0f) / max(_1078, 9.999999747378752e-05f)) * _1063);
      } else {
        _1113 = _1061;
        _1114 = _1062;
        _1115 = _1063;
      }
      _1120 = (_1113 * _945);
      _1121 = (_1114 * _945);
      _1122 = (_1115 * _945);
    } else {
      _1120 = 0.0f;
      _1121 = 0.0f;
      _1122 = 0.0f;
    }
    _1130 = ((_924 * graphics_sun_visibility) * _1120);
    _1131 = ((_925 * graphics_sun_visibility) * _1121);
    _1132 = ((_926 * graphics_sun_visibility) * _1122);
    _1133 = ((_877 * _927) * _924);
    _1134 = ((_878 * _927) * _925);
    _1135 = ((_879 * _927) * _926);
    _1136 = _675;
    _1137 = _676;
    _1138 = _677;
  } else {
    _1130 = 0.0f;
    _1131 = 0.0f;
    _1132 = 0.0f;
    _1133 = 0.0f;
    _1134 = 0.0f;
    _1135 = 0.0f;
    _1136 = 0.0f;
    _1137 = 0.0f;
    _1138 = 0.0f;
  }
  if (any(water_light.direct != 1.f)) {
    float3 native_environment = GraphicsForwardSunEnvironment(float3(_467, _468, _469), float3(_472, _473, _474),
        float3(_492, _493, _494), float3(cb13_000x, cb13_000y, cb13_000z), float3(_459, _460, _461), _437, _464, cb4_012x, _496.y);
    _1136 = native_environment.x; _1137 = native_environment.y; _1138 = native_environment.z;
  }
  uint4 _1143 = 0u; t60.GetDimensions(0u, _1143.x, _1143.y, _1143.z, _1143.w);
  if ((int)((uint)_434 < (uint)(int)(_1143.x)) && (int)((uint)_435 < (uint)(int)(_1143.y))) {
    int _1151 = min((int)(_1143.z), 8);
    if (!(_1151 == 0)) {
      uint _1154 = t60.Load(int4(_434, _435, 0, 0));
      _1157 = _1154.x;
    } else {
      _1157 = 0;
    }
    if ((uint)_1151 > (uint)1) {
      uint _1160 = t60.Load(int4(_434, _435, 1, 0));
      _1163 = _1160.x;
    } else {
      _1163 = 0;
    }
    if ((uint)_1151 > (uint)2) {
      uint _1166 = t60.Load(int4(_434, _435, 2, 0));
      _1169 = _1166.x;
    } else {
      _1169 = 0;
    }
    if ((uint)_1151 > (uint)3) {
      uint _1172 = t60.Load(int4(_434, _435, 3, 0));
      _1175 = _1172.x;
    } else {
      _1175 = 0;
    }
    if ((uint)_1151 > (uint)4) {
      uint _1178 = t60.Load(int4(_434, _435, 4, 0));
      _1181 = _1178.x;
    } else {
      _1181 = 0;
    }
    if ((uint)_1151 > (uint)5) {
      uint _1184 = t60.Load(int4(_434, _435, 5, 0));
      _1187 = _1184.x;
    } else {
      _1187 = 0;
    }
    if ((uint)_1151 > (uint)6) {
      uint _1190 = t60.Load(int4(_434, _435, 6, 0));
      _1193 = _1190.x;
    } else {
      _1193 = 0;
    }
    if ((uint)_1151 > (uint)7) {
      uint _1196 = t60.Load(int4(_434, _435, 7, 0));
      _1199 = _1175;
      _1200 = _1169;
      _1201 = _1163;
      _1202 = _1157;
      _1203 = _1196.x;
      _1204 = _1193;
      _1205 = _1187;
      _1206 = _1181;
      _1207 = _1151;
    } else {
      _1199 = _1175;
      _1200 = _1169;
      _1201 = _1163;
      _1202 = _1157;
      _1203 = 0;
      _1204 = _1193;
      _1205 = _1187;
      _1206 = _1181;
      _1207 = _1151;
    }
  } else {
    _1199 = 0;
    _1200 = 0;
    _1201 = 0;
    _1202 = 0;
    _1203 = 0;
    _1204 = 0;
    _1205 = 0;
    _1206 = 0;
    _1207 = 0;
  }
  _1209 = _1133;
  _1210 = _1134;
  _1211 = _1135;
  _1212 = _1130;
  _1213 = _1131;
  _1214 = _1132;
  _1215 = 0;
  while(true) {
    int4 _1219 = asint(t20.Load4(((int)(((uint)(_1215 + ((int)(((int(cb12_024x) * ((uint)(_435) >> 4)) + ((uint)((uint)(_434) >> 4))) << 8u)))) << 2u))));
    [branch]
    if (!((uint)_1219.x > (uint)255)) {
      uint _1223 = _1219.x * 10;
      float _1229 = (cb13_raw[((int)(_1223 + 68u))].x) - TEXCOORD.w;
      float _1230 = (cb13_raw[((int)(_1223 + 68u))].y) - TEXCOORD_4.w;
      float _1231 = (cb13_raw[((int)(_1223 + 68u))].z) - TEXCOORD_5.w;
      uint _1232 = (uint)(_1219.x) + 1u;
      if (!(_1207 == 0)) {
        if (!((_1202 & 511) == _1232)) {
          if (!((uint)_1207 < (uint)2)) {
            if (!((_1201 & 511) == _1232)) {
              if (!((uint)_1207 < (uint)3)) {
                if (!((_1200 & 511) == _1232)) {
                  if (!((uint)_1207 < (uint)4)) {
                    if (!((_1199 & 511) == _1232)) {
                      if (!((uint)_1207 < (uint)5)) {
                        if (!((_1206 & 511) == _1232)) {
                          if (!((uint)_1207 < (uint)6)) {
                            if (!((_1205 & 511) == _1232)) {
                              if (!((uint)_1207 < (uint)7)) {
                                if (!((_1204 & 511) == _1232)) {
                                  if ((int)((uint)_1207 > (uint)7) && (int)((_1203 & 511) == _1232)) {
                                    _1273 = _1203;
                                    _1279 = (float((uint)((uint)(((uint)(_1273) >> 9) & 127))) * 0.007874015718698502f);
                                    _1280 = true;
                                  } else {
                                    _1279 = 1.0f;
                                    _1280 = false;
                                  }
                                } else {
                                  _1273 = _1204;
                                  _1279 = (float((uint)((uint)(((uint)(_1273) >> 9) & 127))) * 0.007874015718698502f);
                                  _1280 = true;
                                }
                              } else {
                                _1279 = 1.0f;
                                _1280 = false;
                              }
                            } else {
                              _1273 = _1205;
                              _1279 = (float((uint)((uint)(((uint)(_1273) >> 9) & 127))) * 0.007874015718698502f);
                              _1280 = true;
                            }
                          } else {
                            _1279 = 1.0f;
                            _1280 = false;
                          }
                        } else {
                          _1273 = _1206;
                          _1279 = (float((uint)((uint)(((uint)(_1273) >> 9) & 127))) * 0.007874015718698502f);
                          _1280 = true;
                        }
                      } else {
                        _1279 = 1.0f;
                        _1280 = false;
                      }
                    } else {
                      _1273 = _1199;
                      _1279 = (float((uint)((uint)(((uint)(_1273) >> 9) & 127))) * 0.007874015718698502f);
                      _1280 = true;
                    }
                  } else {
                    _1279 = 1.0f;
                    _1280 = false;
                  }
                } else {
                  _1273 = _1200;
                  _1279 = (float((uint)((uint)(((uint)(_1273) >> 9) & 127))) * 0.007874015718698502f);
                  _1280 = true;
                }
              } else {
                _1279 = 1.0f;
                _1280 = false;
              }
            } else {
              _1273 = _1201;
              _1279 = (float((uint)((uint)(((uint)(_1273) >> 9) & 127))) * 0.007874015718698502f);
              _1280 = true;
            }
          } else {
            _1279 = 1.0f;
            _1280 = false;
          }
        } else {
          _1273 = _1202;
          _1279 = (float((uint)((uint)(((uint)(_1273) >> 9) & 127))) * 0.007874015718698502f);
          _1280 = true;
        }
      } else {
        _1279 = 1.0f;
        _1280 = false;
      }
      float _1286 = sqrt(((_1229 * _1229) + (_1230 * _1230)) + (_1231 * _1231));
      float _1293 = _1286 / (cb13_raw[((int)(_1223 + 68u))].w);
      float _1294 = _1293 * _1293;
      float _1297 = saturate(1.0f - (_1294 * _1294));
      int _1302 = asint((cb13_raw[((int)(_1223 + 71u))].w));
      bool _1304 = ((_1302 & 1) != 0);
      bool _1306 = ((cb13_raw[((int)(_1223 + 73u))].z) > 0.0f);
      int _1314 = asint((cb13_raw[((int)(_1223 + 77u))].x));
      bool _1316 = ((_1314 & 1) != 0);
      float _1318 = (_1297 * _1297) / (((_1286 * _1286) * (cb13_raw[((int)(_1223 + 73u))].x)) + 1.0f);
      if (_1304) {
        float _1326 = rsqrt(dot(float3(_1229, _1230, _1231), float3(_1229, _1230, _1231)));
        _1347 = (exp2(log2(saturate(((cb13_raw[((int)(_1223 + 72u))].y) * dot(float3((-0.0f - (_1229 * _1326)), (-0.0f - (_1230 * _1326)), (-0.0f - (_1231 * _1326))), float3((cb13_raw[((int)(_1223 + 70u))].x), (cb13_raw[((int)(_1223 + 70u))].y), (cb13_raw[((int)(_1223 + 70u))].z)))) + (cb13_raw[((int)(_1223 + 72u))].z))) * (cb13_raw[((int)(_1223 + 72u))].w)) * _1318);
      } else {
        _1347 = _1318;
      }
      bool _1348 = (_1347 > 0.0f);
      if (_1280 && _1348) {
        _1353 = saturate(_1279);
      } else {
        _1353 = 1.0f;
      }
      if (((int)(_1306 || _1316)) && _1348) {
        float _1357 = -0.0f - _1229;
        float _1358 = -0.0f - _1230;
        float _1359 = -0.0f - _1231;
        if (_1304) {
          _1554 = mad((((cb13_raw[((int)(_1223 + 75u))].z) * (cb13_raw[((int)(_1223 + 70u))].x)) - ((cb13_raw[((int)(_1223 + 75u))].y) * (cb13_raw[((int)(_1223 + 70u))].y))), _1359, mad((((cb13_raw[((int)(_1223 + 75u))].y) * (cb13_raw[((int)(_1223 + 70u))].z)) - ((cb13_raw[((int)(_1223 + 75u))].w) * (cb13_raw[((int)(_1223 + 70u))].x))), _1358, ((((cb13_raw[((int)(_1223 + 75u))].w) * (cb13_raw[((int)(_1223 + 70u))].y)) - ((cb13_raw[((int)(_1223 + 75u))].z) * (cb13_raw[((int)(_1223 + 70u))].z))) * _1357)));
          _1555 = mad((cb13_raw[((int)(_1223 + 75u))].w), _1359, mad((cb13_raw[((int)(_1223 + 75u))].z), _1358, ((cb13_raw[((int)(_1223 + 75u))].y) * _1357)));
          _1556 = mad((cb13_raw[((int)(_1223 + 70u))].z), _1359, mad((cb13_raw[((int)(_1223 + 70u))].y), _1358, ((cb13_raw[((int)(_1223 + 70u))].x) * _1357)));
          _1557 = (cb13_raw[((int)(_1223 + 75u))].x);
          _1558 = asint((cb13_raw[((int)(_1223 + 77u))].z));
        } else {
          if (_1316) {
            float _1415 = mad((((cb13_raw[((int)(_1223 + 70u))].x) * (cb13_raw[((int)(_1223 + 72u))].z)) - ((cb13_raw[((int)(_1223 + 70u))].y) * (cb13_raw[((int)(_1223 + 72u))].y))), _1359, mad((((cb13_raw[((int)(_1223 + 70u))].z) * (cb13_raw[((int)(_1223 + 72u))].y)) - ((cb13_raw[((int)(_1223 + 70u))].x) * (cb13_raw[((int)(_1223 + 72u))].w))), _1358, ((((cb13_raw[((int)(_1223 + 70u))].y) * (cb13_raw[((int)(_1223 + 72u))].w)) - ((cb13_raw[((int)(_1223 + 70u))].z) * (cb13_raw[((int)(_1223 + 72u))].z))) * _1357)));
            float _1418 = mad((cb13_raw[((int)(_1223 + 70u))].z), _1359, mad((cb13_raw[((int)(_1223 + 70u))].y), _1358, ((cb13_raw[((int)(_1223 + 70u))].x) * _1357)));
            float _1421 = mad((cb13_raw[((int)(_1223 + 72u))].w), _1359, mad((cb13_raw[((int)(_1223 + 72u))].z), _1358, ((cb13_raw[((int)(_1223 + 72u))].y) * _1357)));
            float _1422 = -0.0f - _1415;
            float _1423 = -0.0f - _1418;
            float _1424 = -0.0f - _1421;
            float _1425 = _1422 / _1286;
            float _1426 = _1423 / _1286;
            float _1427 = _1424 / _1286;
            float _1428 = abs(_1425);
            float _1429 = abs(_1426);
            float _1430 = abs(_1427);
            bool _1434 = (_1428 > max(_1429, _1430));
            if (!((_1314 & 4) == 0)) {
              if (_1434) {
                if (_1425 > 0.0f) {
                  _1464 = _1418;
                  _1465 = _1421;
                  _1466 = _1422;
                  _1467 = (cb13_raw[((int)(_1223 + 75u))].x);
                } else {
                  _1464 = _1423;
                  _1465 = _1421;
                  _1466 = _1415;
                  _1467 = (cb13_raw[((int)(_1223 + 75u))].y);
                }
              } else {
                if (_1429 > max(_1428, _1430)) {
                  if (_1426 > 0.0f) {
                    _1464 = _1422;
                    _1465 = _1421;
                    _1466 = _1423;
                    _1467 = (cb13_raw[((int)(_1223 + 75u))].z);
                  } else {
                    _1464 = _1415;
                    _1465 = _1421;
                    _1466 = _1418;
                    _1467 = (cb13_raw[((int)(_1223 + 75u))].w);
                  }
                } else {
                  if (_1427 > 0.0f) {
                    _1464 = _1415;
                    _1465 = _1418;
                    _1466 = _1424;
                    _1467 = (cb13_raw[((int)(_1223 + 76u))].x);
                  } else {
                    _1464 = _1415;
                    _1465 = _1423;
                    _1466 = _1421;
                    _1467 = (cb13_raw[((int)(_1223 + 76u))].y);
                  }
                }
              }
              _1554 = _1464;
              _1555 = _1465;
              _1556 = _1466;
              _1557 = _1467;
              _1558 = asint((cb13_raw[((int)(_1223 + 77u))].z));
            } else {
              if (_1434) {
                int _1476 = asint((cb13_raw[((int)(_1223 + 77u))].z));
                if (_1425 > 0.0f) {
                  _1554 = _1418;
                  _1555 = _1421;
                  _1556 = _1422;
                  _1557 = (cb13_raw[((int)(_1223 + 75u))].x);
                  _1558 = _1476;
                } else {
                  _1554 = _1423;
                  _1555 = _1421;
                  _1556 = _1415;
                  _1557 = (cb13_raw[((int)(_1223 + 75u))].y);
                  _1558 = ((uint)(_1476) >> 10);
                }
              } else {
                if (_1429 > max(_1428, _1430)) {
                  if (_1426 > 0.0f) {
                    _1554 = _1422;
                    _1555 = _1421;
                    _1556 = _1423;
                    _1557 = (cb13_raw[((int)(_1223 + 75u))].z);
                    _1558 = ((uint)((uint)(asint((cb13_raw[((int)(_1223 + 77u))].z)))) >> 20);
                  } else {
                    _1554 = _1415;
                    _1555 = _1421;
                    _1556 = _1418;
                    _1557 = (cb13_raw[((int)(_1223 + 75u))].w);
                    _1558 = asint((cb13_raw[((int)(_1223 + 77u))].w));
                  }
                } else {
                  int _1503 = asint((cb13_raw[((int)(_1223 + 77u))].w));
                  if (_1427 > 0.0f) {
                    _1554 = _1415;
                    _1555 = _1418;
                    _1556 = _1424;
                    _1557 = (cb13_raw[((int)(_1223 + 76u))].x);
                    _1558 = ((uint)(_1503) >> 10);
                  } else {
                    _1554 = _1415;
                    _1555 = _1423;
                    _1556 = _1421;
                    _1557 = (cb13_raw[((int)(_1223 + 76u))].y);
                    _1558 = ((uint)(_1503) >> 20);
                  }
                }
              }
            }
          } else {
            float _1511 = _1229 / _1286;
            float _1512 = _1230 / _1286;
            float _1513 = _1231 / _1286;
            float _1514 = abs(_1511);
            float _1515 = abs(_1512);
            float _1516 = abs(_1513);
            if (_1514 > max(_1515, _1516)) {
              if (_1511 > 0.0f) {
                _1547 = _1358;
                _1548 = _1359;
                _1549 = _1229;
                _1550 = (cb13_raw[((int)(_1223 + 75u))].x);
              } else {
                _1547 = _1230;
                _1548 = _1359;
                _1549 = _1357;
                _1550 = (cb13_raw[((int)(_1223 + 75u))].y);
              }
            } else {
              if (_1515 > max(_1514, _1516)) {
                if (_1512 > 0.0f) {
                  _1547 = _1229;
                  _1548 = _1359;
                  _1549 = _1230;
                  _1550 = (cb13_raw[((int)(_1223 + 75u))].z);
                } else {
                  _1547 = _1357;
                  _1548 = _1359;
                  _1549 = _1358;
                  _1550 = (cb13_raw[((int)(_1223 + 75u))].w);
                }
              } else {
                if (_1513 > 0.0f) {
                  _1547 = _1357;
                  _1548 = _1358;
                  _1549 = _1231;
                  _1550 = (cb13_raw[((int)(_1223 + 76u))].x);
                } else {
                  _1547 = _1357;
                  _1548 = _1230;
                  _1549 = _1359;
                  _1550 = (cb13_raw[((int)(_1223 + 76u))].y);
                }
              }
            }
            _1554 = _1547;
            _1555 = _1548;
            _1556 = _1549;
            _1557 = _1550;
            _1558 = asint((cb13_raw[((int)(_1223 + 77u))].z));
          }
        }
        float _1566 = (((_1554 * (cb13_raw[((int)(_1223 + 73u))].y)) / _1556) * 0.5f) + 0.5f;
        float _1567 = 0.5f - ((mad((cb13_raw[((int)(_1223 + 73u))].y), _1555, 0.0f) / _1556) * 0.5f);
        if (_1306) {
          int _1569 = asint(_1557);
          int _1571 = ((uint)(_1569) >> 18) & 4092;
          float _1572 = float((uint)_1571);
          [branch]
          if (!(_1571 == 0)) {
            if (!_1280) {
              float _1594 = t9.SampleLevel(s10, float3((cb13_067x * ((_1566 * _1572) + float((uint)((uint)(((int)(_1569 << 2u)) & 4092))))), (cb13_067x * ((_1567 * _1572) + float((uint)((uint)(((uint)(_1569) >> 8) & 4092))))), float((uint)((uint)((uint)(_1569) >> 30)))), 0.0f);
              _1603 = (saturate(exp2((_1594.x - (_1293 * 0.9900000095367432f)) * 144.26950073242188f)) * _1353);
            } else {
              _1603 = _1353;
            }
          } else {
            _1603 = _1353;
          }
        } else {
          _1603 = _1353;
        }
        if (_1316) {
          bool _1606 = ((_1314 & 2) != 0);
          if (_1606) {
            _1616 = (_1558 & 1023);
            _1617 = 0;
          } else {
            _1616 = (_1558 & 255);
            _1617 = (((uint)(_1558) >> 8) & 3);
          }
          float _1621 = floor(cb13_raw[((int)(_1223 + 77u))].y) + float((uint)_1616);
          float4 _1625 = t42.SampleLevel(s10, float3(_1566, _1567, _1621), 0.0f);
          _59[0] = _1625.x;
          _59[1] = _1625.y;
          _59[2] = _1625.z;
          _59[3] = _1625.w;
          if (!((_1314 & 8) == 0)) {
            float4 _1636 = t42.SampleLevel(s10, float3(_1566, _1567, (_1621 + 1.0f)), 0.0f);
            float _1641 = frac(cb13_raw[((int)(_1223 + 77u))].y);
            float _1650 = ((_1636.x - _1625.x) * _1641) + _1625.x;
            float _1651 = ((_1636.y - _1625.y) * _1641) + _1625.y;
            float _1652 = ((_1636.z - _1625.z) * _1641) + _1625.z;
            _59[0] = _1650;
            _59[1] = _1651;
            _59[2] = _1652;
            _59[3] = (lerp(_1625.w, _1636.w, _1641));
            _1655 = _1652;
            _1656 = _1651;
            _1657 = _1650;
          } else {
            _1655 = _1625.z;
            _1656 = _1625.y;
            _1657 = _1625.x;
          }
          if (!_1606) {
            float _1660 = _59[_1617];
            _1662 = _1660;
            _1663 = _1660;
            _1664 = _1660;
          } else {
            _1662 = _1657;
            _1663 = _1656;
            _1664 = _1655;
          }
          _1666 = _1603;
          _1667 = _1662;
          _1668 = _1663;
          _1669 = _1664;
        } else {
          _1666 = _1603;
          _1667 = 1.0f;
          _1668 = 1.0f;
          _1669 = 1.0f;
        }
      } else {
        _1666 = _1353;
        _1667 = 1.0f;
        _1668 = 1.0f;
        _1669 = 1.0f;
      }
      if ((int)((cb13_raw[((int)(_1223 + 74u))].x) > 0.0f) && _1348) {
        if (!_1280) {
          float _1676 = t10.SampleLevel(s10, float4(_1229, _1230, _1231, (cb13_raw[((int)(_1223 + 74u))].y)), 0.0f);
          _1686 = (saturate(exp2((_1676.x - (_1293 * 0.9900000095367432f)) * 144.26950073242188f)) * _1666);
          _1689 = _1686;
          _1690 = (cb13_raw[((int)(_1223 + 73u))].w);
        } else {
          _1689 = _1666;
          _1690 = 1.0f;
        }
      } else {
        if (!_1280) {
          _1686 = _1666;
          _1689 = _1686;
          _1690 = (cb13_raw[((int)(_1223 + 73u))].w);
        } else {
          _1689 = _1666;
          _1690 = 1.0f;
        }
      }
      if ((int)(_496.z == 1.0f) || (int)((_1302 & 2048) != 0)) {
        _1702 = cb12_071y;
      } else {
        _1702 = 0.0f;
      }
      if (((int)(!(_496.z == 1.0f))) || (int)((_1302 & 4096) != 0)) {
        _1711 = cb12_071z;
      } else {
        _1711 = 0.0f;
      }
      float _1714 = ((((_1690 * (_1689 + -1.0f)) + 1.0f) * _1347) * _1702) * _1711;
      float _1715 = _1714 * _1667;
      float _1716 = _1714 * _1668;
      float _1717 = _1714 * _1669;
      [branch]
      if ((int)(_1717 > 0.0f) || ((int)((int)(_1715 > 0.0f) || (int)(_1716 > 0.0f)))) {
        if (!(FrequentPixelConsts_256.x < 0.0f)) {
          _1731 = cb12_071x;
        } else {
          _1731 = 1.0f;
        }
        float _1733 = select(((int)_1302 < (int)0), _1731, 1.0f);
        float _1738 = rsqrt(dot(float3(_1229, _1230, _1231), float3(_1229, _1230, _1231)));
        float _1739 = _1738 * _1229;
        float _1740 = _1738 * _1230;
        float _1741 = _1738 * _1231;
        float _1746 = saturate((dot(float3(_472, _473, _474), float3(_1739, _1740, _1741)) + cb4_012x) / (cb4_012x + 1.0f));
        float _1747 = dot(float3(_467, _468, _469), float3(_1739, _1740, _1741));
        float _1749 = _1746 + 1.0f;
        float _1751 = 1.0f / _1749;
        float _1752 = saturate((_1747 + _1746) / _1749);
        if (_464 == 1) {
          float _1755 = saturate(_1747);
          int _1758 = ((int)(uint)((int)(_469 > 0.0f))) << 1u;
          float _1760 = float((int)(_1758 + -1));
          float _1762 = -1.0f / (_1760 + _469);
          float _1764 = (_467 * _468) * _1762;
          float _1768 = (((_467 * _467) * _1760) * _1762) + 1.0f;
          float _1769 = _1764 * _1760;
          float _1772 = float((int)(1 - _1758)) * _467;
          float _1775 = ((_468 * _468) * _1762) + _1760;
          float _1776 = -0.0f - _468;
          float _1778 = rsqrt(dot(float3(_1739, _1740, _1741), float3(_1739, _1740, _1741)));
          float _1779 = _1778 * _1739;
          float _1780 = _1778 * _1740;
          float _1781 = _1778 * _1741;
          float _1784 = mad(_1772, _1781, mad(_1769, _1780, (_1779 * _1768)));
          float _1787 = mad(_1776, _1781, mad(_1775, _1780, (_1779 * _1764)));
          float _1790 = mad(_469, _1781, mad(_468, _1780, (_1779 * _467)));
          float _1792 = rsqrt(dot(float3(_1784, _1787, _1790), float3(_1784, _1787, _1790)));
          float _1795 = _1792 * _1790;
          float _1797 = rsqrt(dot(float3(_492, _493, _494), float3(_492, _493, _494)));
          float _1798 = _1797 * _492;
          float _1799 = _1797 * _493;
          float _1800 = _1797 * _494;
          float _1803 = mad(_1772, _1800, mad(_1769, _1799, (_1798 * _1768)));
          float _1806 = mad(_1776, _1800, mad(_1775, _1799, (_1798 * _1764)));
          float _1809 = mad(_469, _1800, mad(_468, _1799, (_1798 * _467)));
          float _1811 = rsqrt(dot(float3(_1803, _1806, _1809), float3(_1803, _1806, _1809)));
          float _1814 = _1811 * _1809;
          float _1815 = direct_roughness * direct_roughness;
          float _1818 = dot(float3((_1792 * _1784), (_1792 * _1787), _1795), float3((_1811 * _1803), (_1811 * _1806), _1814)) - (_1814 * _1795);
          if (_1818 > 0.0f) {
            _1824 = (_1818 / max(_1795, _1814));
          } else {
            _1824 = _1818;
          }
          float _1826 = (_1815 * 0.2877933979034424f) + 1.0f;
          float _1827 = 1.0f / _1826;
          float _1828 = _459 * 0.31830987334251404f;
          float _1829 = _460 * 0.31830987334251404f;
          float _1830 = _461 * 0.31830987334251404f;
          float _1833 = ((_1824 * _1815) + 1.0f) * _1827;
          float _1837 = 1.0f - _1814;
          float _1848 = 1.0f - _1795;
          float _1861 = _1827 * ((_1815 * 0.07248824834823608f) + 1.0f);
          float _1868 = 1.0f - _1861;
          float _1883 = max(1.0000000116860974e-07f, (1.0f - ((((_1848 * _1815) * ((((((_1848 * 0.07144299894571304f) + -0.332181453704834f) * _1848) + 0.4918818771839142f) * _1848) + 0.05710852891206741f)) + 1.0f) / _1826))) * (max(1.0000000116860974e-07f, (1.0f - ((((_1837 * _1815) * ((((((_1837 * 0.07144299894571304f) + -0.332181453704834f) * _1837) + 0.4918818771839142f) * _1837) + 0.05710852891206741f)) + 1.0f) / _1826))) * 0.31830987334251404f);
          float _1887 = max(1.0000000116860974e-07f, _1868);
          float _1898 = max(0.0f, (_1752 - _1755));
          _1906 = ((_1898 * _1828) + ((((_1883 * (((_459 * _459) * _1861) / (1.0f - (_1868 * _459)))) / _1887) + (_1833 * _1828)) * _1755));
          _1907 = ((_1898 * _1829) + ((((_1883 * (((_460 * _460) * _1861) / (1.0f - (_1868 * _460)))) / _1887) + (_1833 * _1829)) * _1755));
          _1908 = (((((_1883 * (((_461 * _461) * _1861) / (1.0f - (_1868 * _461)))) / _1887) + (_1833 * _1830)) * _1755) + (_1898 * _1830));
        } else {
          _1906 = _1752;
          _1907 = _1752;
          _1908 = _1752;
        }
        // Keep the native wrap, transmission and anisotropic specular paths.
        if (improved_pbr) {
          float3 diffuse = GraphicsForwardDiffuse(float3(_467, _468, _469), float3(_492, _493, _494),
              float3(_1739, _1740, _1741), direct_roughness, float3(_459, _460, _461), _464, _1752);
          _1906 = diffuse.x; _1907 = diffuse.y; _1908 = diffuse.z;
        }
        float _1912 = 1.0f - _447;
        float _1913 = 1.0f - _448;
        float _1914 = 1.0f - _449;
        if (cb12_221x > 0.0f) {
          float4 _1919 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_467, _468, _469), float3(_492, _493, _494))), 0.0f);
          float _1925 = (_1919.x * _447) + _1919.y;
          float _1926 = (_1919.x * _448) + _1919.y;
          float _1927 = (_1919.x * _449) + _1919.y;
          _1989 = min((_1925 / max((1.0f - ((1.0f - _1925) * ((_1912 * 0.0476190485060215f) + _447))), 0.0010000000474974513f)), 1.0f);
          _1990 = min((_1926 / max((1.0f - ((1.0f - _1926) * ((_1913 * 0.0476190485060215f) + _448))), 0.0010000000474974513f)), 1.0f);
          _1991 = min((_1927 / max((1.0f - ((1.0f - _1927) * ((_1914 * 0.0476190485060215f) + _449))), 0.0010000000474974513f)), 1.0f);
        } else {
          float _1953 = _1739 + _492;
          float _1954 = _1740 + _493;
          float _1955 = _1741 + _494;
          float _1957 = rsqrt(dot(float3(_1953, _1954, _1955), float3(_1953, _1954, _1955)));
          float _1964 = saturate(1.0f - abs(dot(float3((_1957 * _1953), (_1957 * _1954), (_1957 * _1955)), float3(_492, _493, _494))));
          float _1965 = _1964 * _1964;
          float _1975 = ((_1965 * _1965) * _1964) * cb13_066x;
          float _1981 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
          _1989 = (((_1975 * max(0.0f, _1912)) / _1981) + _447);
          _1990 = (((_1975 * max(0.0f, _1913)) / _1981) + _448);
          _1991 = (((_1975 * max(0.0f, _1914)) / _1981) + _449);
        }
        float _1995 = (1.0f - _1989) * _1906;
        float _1996 = (1.0f - _1990) * _1907;
        float _1997 = (1.0f - _1991) * _1908;
        bool _1999 = ((_464 & -3) == 0);
        float _2003 = select(_1999, (_1995 * 0.31830987334251404f), _1995);
        float _2004 = select(_1999, (_1996 * 0.31830987334251404f), _1996);
        float _2005 = select(_1999, (_1997 * 0.31830987334251404f), _1997);
        [branch]
        if (!(_436 > 0.0f)) {
          _2107 = dot(float3(_1739, _1740, _1741), float3(_467, _468, _469));
          _2108 = _2003;
          _2109 = _2004;
          _2110 = _2005;
        } else {
          bool _2015 = (_464 == 0);
          if (!(cb12_037z == 0.0f)) {
            float _2020 = dot(float3(_459, _460, _461), float3(0.21250000596046448f, 0.715399980545044f, 0.07209999859333038f));
            if (!_2015) {
              _2035 = saturate(lerp(_2020, _459, cb12_036w));
              _2036 = saturate(lerp(_2020, _460, cb12_036w));
              _2037 = saturate(lerp(_2020, _461, cb12_036w));
            } else {
              _2035 = 1.0f;
              _2036 = 1.0f;
              _2037 = 1.0f;
            }
            float _2038 = dot(float3(_1739, _1740, _1741), float3(_492, _493, _494));
            float _2039 = dot(float3(_1739, _1740, _1741), float3(_467, _468, _469));
            float _2053 = ((_436 * 0.31830987334251404f) * exp2(log2(abs(_2039)) * cb12_036z)) * (exp2((_2038 + cb12_036y) * -4.328084945678711f) + exp2((_2038 + cb12_036x) * -1.4426950216293335f));
            _2107 = _2039;
            _2108 = ((_2053 * _2035) + _2003);
            _2109 = ((_2053 * _2036) + _2004);
            _2110 = ((_2053 * _2037) + _2005);
          } else {
            float _2061 = dot(float3(_1739, _1740, _1741), float3(_467, _468, _469));
            float _2063 = (_2061 + 1.0f) * 0.5f;
            float _2064 = -0.0f - _492;
            float _2065 = -0.0f - _493;
            float _2066 = -0.0f - _494;
            float _2069 = (dot(float3(_1739, _1740, _1741), float3(_2064, _2065, _2066)) + 1.0f) * 0.5f;
            float _2072 = _2069 * _2069;
            float _2074 = select(_2015, 1.0f, _459);
            float _2075 = select(_2015, 1.0f, _460);
            float _2076 = select(_2015, 1.0f, _461);
            float _2086 = cb12_036y * _436;
            float _2099 = (((_436 * 0.5f) * cb12_036w) * (dot(float3(_467, _468, _469), float3(_2064, _2065, _2066)) + 1.0f)) * ((((_2072 * _2072) - _2063) * cb12_036x) + _2063);
            _2107 = _2061;
            _2108 = ((((((_2074 * _1912) * cb12_036z) - _2003) * _2086) + _2003) + (_2099 * _2074));
            _2109 = ((((((_2075 * _1913) * cb12_036z) - _2004) * _2086) + _2004) + (_2099 * _2075));
            _2110 = ((((((_2076 * _1914) * cb12_036z) - _2005) * _2086) + _2005) + (_2099 * _2076));
          }
        }
        float _2114 = (_1733 * _1715) * (cb13_raw[((int)(_1223 + 71u))].x);
        float _2117 = (_1733 * _1716) * (cb13_raw[((int)(_1223 + 71u))].y);
        float _2120 = (_1733 * _1717) * (cb13_raw[((int)(_1223 + 71u))].z);
        [branch]
        if (_2107 > 0.0f) {
          float _2128 = _1739 + _492;
          float _2129 = _1740 + _493;
          float _2130 = _1741 + _494;
          float _2132 = rsqrt(dot(float3(_2128, _2129, _2130), float3(_2128, _2129, _2130)));
          float _2133 = _2132 * _2128;
          float _2134 = _2132 * _2129;
          float _2135 = _2132 * _2130;
          float _2136 = dot(float3(_467, _468, _469), float3(_492, _493, _494));
          float _2137 = saturate(_1747);
          float _2138 = direct_roughness * direct_roughness;
          float _2141 = max(9.999999747378752e-05f, _2138);
          float _2142 = max(9.999999747378752e-05f, (_2138 * (1.0f - _416)));
          float _2144 = rsqrt(dot(float3(TEXCOORD_6.x, TEXCOORD_6.y, TEXCOORD_6.z), float3(TEXCOORD_6.x, TEXCOORD_6.y, TEXCOORD_6.z)));
          float _2145 = _2144 * TEXCOORD_6.x;
          float _2146 = _2144 * TEXCOORD_6.y;
          float _2147 = _2144 * TEXCOORD_6.z;
          float _2148 = dot(float3(_2145, _2146, _2147), float3(_467, _468, _469));
          float _2152 = _2145 - (_2148 * _467);
          float _2153 = _2146 - (_2148 * _468);
          float _2154 = _2147 - (_2148 * _469);
          float _2156 = rsqrt(dot(float3(_2152, _2153, _2154), float3(_2152, _2153, _2154)));
          float _2157 = _2152 * _2156;
          float _2158 = _2153 * _2156;
          float _2159 = _2154 * _2156;
          float _2172 = ((_2158 * _469) - (_2159 * _468)) + (_467 * _429);
          float _2173 = ((_2159 * _467) - (_2157 * _469)) + (_468 * _429);
          float _2174 = ((_2157 * _468) - (_2158 * _467)) + (_469 * _429);
          float _2176 = rsqrt(dot(float3(_2172, _2173, _2174), float3(_2172, _2173, _2174)));
          float _2181 = dot(float3(_2157, _2158, _2159), float3(_2133, _2134, _2135)) / _2141;
          float _2184 = dot(float3((_2172 * _2176), (_2173 * _2176), (_2174 * _2176)), float3(_2133, _2134, _2135)) / _2142;
          float _2187 = saturate(dot(float3(_467, _468, _469), float3(_2133, _2134, _2135)));
          float _2190 = ((_2184 * _2184) + (_2181 * _2181)) + (_2187 * _2187);
          float _2196 = abs(_2136);
          float _2200 = saturate(1.0f - abs(dot(float3(_2133, _2134, _2135), float3(_492, _493, _494))));
          float _2201 = _2200 * _2200;
          float _2211 = ((_2201 * _2201) * _2200) * cb13_066x;
          float _2217 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
          [branch]
          if (cb12_221z > 0.0f) {
            float _2227 = saturate(_2136);
            float _2230 = (_2137 * 2.0f) * _2227;
            _2250 = ((((_2227 + _2137) - _2230) * _2138) + _2230);
          } else {
            float _2235 = _2138 * _2138;
            float _2236 = 1.0f - _2235;
            _2250 = (((sqrt(((_2196 * _2196) * _2236) + _2235) * _2137) + 9.999999747378752e-05f) + (sqrt(((_2137 * _2137) * _2236) + _2235) * _2196));
          }
          float _2251 = 0.5f / _2250;
          float _2252 = _2251 * (1.0f / ((_2190 * _2190) * ((_2141 * 3.1415200233459473f) * _2142)));
          float _2253 = _2252 * (((_2211 * max(0.0f, _1912)) / _2217) + _447);
          float _2254 = _2252 * (((_2211 * max(0.0f, _1913)) / _2217) + _448);
          float _2255 = _2252 * (((_2211 * max(0.0f, _1914)) / _2217) + _449);
          if (cb12_221y > 0.0f) {
            float4 _2262 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_467, _468, _469), float3(_2251, _2251, _2251))), 0.0f);
            float _2268 = (_2262.x * _447) + _2262.y;
            float _2269 = (_2262.x * _448) + _2262.y;
            float _2270 = (_2262.x * _449) + _2262.y;
            _2305 = ((min((_2268 / max((1.0f - ((1.0f - _2268) * ((_1912 * 0.0476190485060215f) + _447))), 0.0010000000474974513f)), 1.0f) / max(_2268, 9.999999747378752e-05f)) * _2253);
            _2306 = ((min((_2269 / max((1.0f - ((1.0f - _2269) * ((_1913 * 0.0476190485060215f) + _448))), 0.0010000000474974513f)), 1.0f) / max(_2269, 9.999999747378752e-05f)) * _2254);
            _2307 = ((min((_2270 / max((1.0f - ((1.0f - _2270) * ((_1914 * 0.0476190485060215f) + _449))), 0.0010000000474974513f)), 1.0f) / max(_2270, 9.999999747378752e-05f)) * _2255);
          } else {
            _2305 = _2253;
            _2306 = _2254;
            _2307 = _2255;
          }
          _2312 = (_2305 * _2137);
          _2313 = (_2306 * _2137);
          _2314 = (_2307 * _2137);
        } else {
          _2312 = 0.0f;
          _2313 = 0.0f;
          _2314 = 0.0f;
        }
        _2322 = (((_2114 * _1751) * _2108) + _1209);
        _2323 = (((_2117 * _1751) * _2109) + _1210);
        _2324 = (((_2120 * _1751) * _2110) + _1211);
        _2325 = ((_2114 * _2312) + _1212);
        _2326 = ((_2117 * _2313) + _1213);
        _2327 = ((_2120 * _2314) + _1214);
      } else {
        _2322 = _1209;
        _2323 = _1210;
        _2324 = _1211;
        _2325 = _1212;
        _2326 = _1213;
        _2327 = _1214;
      }
      int _2328 = _1215 + 1;
      if ((int)_2328 < (int)256) {
        _1209 = _2322;
        _1210 = _2323;
        _1211 = _2324;
        _1212 = _2325;
        _1213 = _2326;
        _1214 = _2327;
        _1215 = _2328;
        continue;
      } else {
        _2331 = _2322;
        _2332 = _2323;
        _2333 = _2324;
        _2334 = _2325;
        _2335 = _2326;
        _2336 = _2327;
      }
    } else {
      _2331 = _1209;
      _2332 = _1210;
      _2333 = _1211;
      _2334 = _1212;
      _2335 = _1213;
      _2336 = _1214;
    }
    break;
  }
  float _2337 = -0.0f - _492;
  float _2338 = -0.0f - _493;
  float _2339 = -0.0f - _494;
  float _2341 = dot(float3(_2337, _2338, _2339), float3(_467, _468, _469)) * 2.0f;
  float _2345 = _2337 - (_2341 * _467);
  float _2346 = _2338 - (_2341 * _468);
  float _2347 = _2339 - (_2341 * _469);
  float _2352 = min(max(max(((_437 * _437) * 10.5f), 0.0f), 0.0f), 5.0f);
  _2354 = 1;
  _2355 = 0.0f;
  _2356 = 0.0f;
  _2357 = 0.0f;
  _2358 = 9.999999747378752e-06f;
  while(true) {
    int _2359 = _2354 * 12;
    float _2395 = 1.0f - abs(mad((cb12_raw[(_2359 + 104)].x), TEXCOORD_5.w, mad((cb12_raw[(_2359 + 103)].x), TEXCOORD_4.w, ((cb12_raw[(_2359 + 102)].x) * TEXCOORD.w))) + (cb12_raw[(_2359 + 105)].x));
    float _2396 = 1.0f - abs(mad((cb12_raw[(_2359 + 104)].y), TEXCOORD_5.w, mad((cb12_raw[(_2359 + 103)].y), TEXCOORD_4.w, ((cb12_raw[(_2359 + 102)].y) * TEXCOORD.w))) + (cb12_raw[(_2359 + 105)].y));
    float _2397 = 1.0f - abs(mad((cb12_raw[(_2359 + 104)].z), TEXCOORD_5.w, mad((cb12_raw[(_2359 + 103)].z), TEXCOORD_4.w, ((cb12_raw[(_2359 + 102)].z) * TEXCOORD.w))) + (cb12_raw[(_2359 + 105)].z));
    if (((int)((int)(_2395 > 0.0f) && (int)(_2396 > 0.0f))) && (int)(_2397 > 0.0f)) {
      float _2422 = (((saturate((cb12_raw[(_2359 + 101)].x) * _2395) * (1.0f - _2358)) * saturate((cb12_raw[(_2359 + 101)].y) * _2396)) * saturate((cb12_raw[(_2359 + 101)].z) * _2397)) * (cb12_raw[(_2359 + 100)].x);
      float _2427 = _2422 * (cb12_raw[(_2359 + 106)].x);
      float _2429 = rsqrt(dot(float3(_2345, _2346, _2347), float3(_2345, _2346, _2347)));
      float _2430 = _2429 * _2345;
      float _2431 = _2429 * _2346;
      float _2432 = _2429 * _2347;
      bool _2436 = (_2432 < 0.0f);
      float _2442 = min(max((1.0f / (1.0f - _2432)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float _2450 = min(max((1.0f / (_2432 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float4 _2469 = t23.SampleLevel(s11, float2((((float((bool)_2436) + 0.1666666716337204f) + ((select(_2436, ((_2430 * 0.5f) * _2442), ((_2430 * -0.5f) * _2450)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(asint(cb12_raw[(_2359 + 111)].x))) + 0.1666666716337204f) + ((select(_2436, ((_2431 * -0.5f) * _2442), ((_2431 * 0.5f) * _2450)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _2352);
      _2480 = (_2422 + _2358);
      _2481 = ((_2469.x * _2427) + _2357);
      _2482 = ((_2469.y * _2427) + _2356);
      _2483 = ((_2469.z * _2427) + _2355);
    } else {
      _2480 = _2358;
      _2481 = _2357;
      _2482 = _2356;
      _2483 = _2355;
    }
    int _2484 = _2354 + 1;
    _2486 = (_2480 < 0.9990000128746033f);
    if ((int)((uint)_2484 < (uint)7) && _2486) {
      _2354 = _2484;
      _2355 = _2483;
      _2356 = _2482;
      _2357 = _2481;
      _2358 = _2480;
      continue;
    }
    break;
  }
  [branch]
  if (_2486) {
    float _2493 = cb12_100x * (1.0f - _2480);
    float _2497 = _2493 * cb12_106x;
    bool _2500 = (_2347 < 0.0f);
    float _2506 = min(max((1.0f / (1.0f - _2347)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float _2514 = min(max((1.0f / (_2347 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float4 _2533 = t23.SampleLevel(s11, float2((((float((bool)_2500) + 0.1666666716337204f) + ((select(_2500, ((_2345 * 0.5f) * _2506), ((_2345 * -0.5f) * _2514)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(cb12_111x)) + 0.1666666716337204f) + ((select(_2500, ((_2346 * -0.5f) * _2506), ((_2346 * 0.5f) * _2514)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _2352);
    _2544 = (_2493 + _2480);
    _2545 = ((_2533.x * _2497) + _2481);
    _2546 = ((_2533.y * _2497) + _2482);
    _2547 = ((_2533.z * _2497) + _2483);
  } else {
    _2544 = _2480;
    _2545 = _2481;
    _2546 = _2482;
    _2547 = _2483;
  }
  _2549 = 1;
  _2550 = 0.0f;
  _2551 = 0.0f;
  _2552 = 0.0f;
  _2553 = 9.999999747378752e-06f;
  while(true) {
    int _2554 = _2549 * 12;
    float _2590 = 1.0f - abs(mad((cb12_raw[(_2554 + 104)].x), TEXCOORD_5.w, mad((cb12_raw[(_2554 + 103)].x), TEXCOORD_4.w, ((cb12_raw[(_2554 + 102)].x) * TEXCOORD.w))) + (cb12_raw[(_2554 + 105)].x));
    float _2591 = 1.0f - abs(mad((cb12_raw[(_2554 + 104)].y), TEXCOORD_5.w, mad((cb12_raw[(_2554 + 103)].y), TEXCOORD_4.w, ((cb12_raw[(_2554 + 102)].y) * TEXCOORD.w))) + (cb12_raw[(_2554 + 105)].y));
    float _2592 = 1.0f - abs(mad((cb12_raw[(_2554 + 104)].z), TEXCOORD_5.w, mad((cb12_raw[(_2554 + 103)].z), TEXCOORD_4.w, ((cb12_raw[(_2554 + 102)].z) * TEXCOORD.w))) + (cb12_raw[(_2554 + 105)].z));
    if (((int)((int)(_2590 > 0.0f) && (int)(_2591 > 0.0f))) && (int)(_2592 > 0.0f)) {
      float _2617 = (((saturate((cb12_raw[(_2554 + 101)].x) * _2590) * (1.0f - _2553)) * saturate((cb12_raw[(_2554 + 101)].y) * _2591)) * saturate((cb12_raw[(_2554 + 101)].z) * _2592)) * (cb12_raw[(_2554 + 100)].x);
      float _2622 = _2617 * (cb12_raw[(_2554 + 106)].x);
      float _2624 = rsqrt(dot(float3(_2345, _2346, _2347), float3(_2345, _2346, _2347)));
      float _2625 = _2624 * _2345;
      float _2626 = _2624 * _2346;
      float _2627 = _2624 * _2347;
      bool _2631 = (_2627 < 0.0f);
      float _2637 = min(max((1.0f / (1.0f - _2627)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float _2645 = min(max((1.0f / (_2627 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float4 _2664 = t23.SampleLevel(s11, float2((((float((bool)_2631) + 0.1666666716337204f) + ((select(_2631, ((_2625 * 0.5f) * _2637), ((_2625 * -0.5f) * _2645)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(asint(cb12_raw[(_2554 + 111)].x))) + 0.1666666716337204f) + ((select(_2631, ((_2626 * -0.5f) * _2637), ((_2626 * 0.5f) * _2645)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), 5.0f);
      _2675 = (_2617 + _2553);
      _2676 = ((_2664.x * _2622) + _2552);
      _2677 = ((_2664.y * _2622) + _2551);
      _2678 = ((_2664.z * _2622) + _2550);
    } else {
      _2675 = _2553;
      _2676 = _2552;
      _2677 = _2551;
      _2678 = _2550;
    }
    int _2679 = _2549 + 1;
    _2681 = (_2675 < 0.9990000128746033f);
    if ((int)((uint)_2679 < (uint)7) && _2681) {
      _2549 = _2679;
      _2550 = _2678;
      _2551 = _2677;
      _2552 = _2676;
      _2553 = _2675;
      continue;
    }
    break;
  }
  [branch]
  if (_2681) {
    float _2689 = cb12_100x * (1.0f - _2675);
    float _2693 = _2689 * cb12_106x;
    bool _2696 = (_2347 < 0.0f);
    float _2702 = min(max((1.0f / (1.0f - _2347)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float _2710 = min(max((1.0f / (_2347 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float4 _2729 = t23.SampleLevel(s11, float2((((float((bool)_2696) + 0.1666666716337204f) + ((select(_2696, ((_2345 * 0.5f) * _2702), ((_2345 * -0.5f) * _2710)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(cb12_111x)) + 0.1666666716337204f) + ((select(_2696, ((_2346 * -0.5f) * _2702), ((_2346 * 0.5f) * _2710)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), 5.0f);
    _2740 = (_2689 + _2675);
    _2741 = ((_2729.x * _2693) + _2676);
    _2742 = ((_2729.y * _2693) + _2677);
    _2743 = ((_2729.z * _2693) + _2678);
  } else {
    _2740 = _2675;
    _2741 = _2676;
    _2742 = _2677;
    _2743 = _2678;
  }
  float _2744 = 1.0f / _2740;
  if (!(cb12_074y > 0.0f)) {
    float _2782 = saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.z) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.z) * TEXCOORD_5.w) + (gridDesc_000[1].PROBE_GRID_DESC_208.z))) + (gridDesc_000[1].PROBE_GRID_DESC_236));
    float _2785 = (_2782 * _2782) * min(saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.x) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.x) * TEXCOORD.w) + (gridDesc_000[1].PROBE_GRID_DESC_208.x))) + (gridDesc_000[1].PROBE_GRID_DESC_236)), saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.y) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.y) * TEXCOORD_4.w) + (gridDesc_000[1].PROBE_GRID_DESC_208.y))) + (gridDesc_000[1].PROBE_GRID_DESC_236)));
    float _2816 = saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.z) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.z) * TEXCOORD_5.w) + (gridDesc_000[0].PROBE_GRID_DESC_208.z))) + (gridDesc_000[0].PROBE_GRID_DESC_236));
    float _2819 = (_2816 * _2816) * min(saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.x) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.x) * TEXCOORD.w) + (gridDesc_000[0].PROBE_GRID_DESC_208.x))) + (gridDesc_000[0].PROBE_GRID_DESC_236)), saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.y) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.y) * TEXCOORD_4.w) + (gridDesc_000[0].PROBE_GRID_DESC_208.y))) + (gridDesc_000[0].PROBE_GRID_DESC_236)));
    bool _2820 = (_2785 > 9.999999717180685e-10f);
    int _2821 = (int)(uint)(_2820);
    bool _2824 = (int)(_2785 < 1.0f) && (int)(_2819 > 9.999999717180685e-10f);
    int _2825 = (int)(uint)(_2824);
    if (_2820) {
      float _2868 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _467) + TEXCOORD.w) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _492);
      float _2869 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _468) + TEXCOORD_4.w) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _493);
      float _2870 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _469) + TEXCOORD_5.w) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _494);
      float _2874 = (_2868 * (gridDesc_000[1].PROBE_GRID_DESC_176.x)) + (gridDesc_000[1].PROBE_GRID_DESC_192.x);
      float _2875 = (_2869 * (gridDesc_000[1].PROBE_GRID_DESC_176.y)) + (gridDesc_000[1].PROBE_GRID_DESC_192.y);
      float _2876 = (_2870 * (gridDesc_000[1].PROBE_GRID_DESC_176.z)) + (gridDesc_000[1].PROBE_GRID_DESC_192.z);
      int _2886 = min(max(int(_2874), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) + -1u)));
      int _2887 = min(max(int(_2875), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) + -1u)));
      int _2888 = min(max(int(_2876), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) + -1u)));
      float _2889 = float((int)(_2886));
      float _2890 = float((int)(_2887));
      float _2891 = float((int)(_2888));
      float _2892 = _2874 - _2889;
      float _2893 = _2875 - _2890;
      float _2894 = _2876 - _2891;
      _2898 = 0.0f;
      _2899 = 0.0f;
      _2900 = 0.0f;
      _2901 = 0.0f;
      _2902 = 0.0f;
      _2903 = 0;
      while(true) {
        int _2906 = _2903 & 1;
        int _2907 = ((uint)(_2903) >> 1) & 1;
        int _2908 = ((uint)(_2903) >> 2) & 1;
        uint _2909 = _2906 + _2886;
        uint _2910 = _2907 + _2887;
        uint _2911 = _2908 + _2888;
        if (!((int)((int)_2911 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_2909 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) || (int)((int)_2910 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.y)))))) {
          int _2924 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.x))) + _2909)) % (gridDesc_000[1].PROBE_GRID_DESC_032.x);
          int _2925 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.y))) + _2910)) % (gridDesc_000[1].PROBE_GRID_DESC_032.y);
          int _2926 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.z))) + _2911)) % (gridDesc_000[1].PROBE_GRID_DESC_032.z);
          int _2928 = _2926 + (_2924 * (gridDesc_000[1].PROBE_GRID_DESC_032.z));
          float4 _2931 = t34[1].Load(int3(_2928, _2925, 0));
          uint _2934 = t32[1].Load(int3(_2928, _2925, 0));
          if ((_2934.x & -2) == 2) {
            float _2953 = ((((_2889 - (gridDesc_000[1].PROBE_GRID_DESC_160.x)) + float((int)(_2906))) + (_2931.x * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.x) - _2868);
            float _2959 = ((((_2890 - (gridDesc_000[1].PROBE_GRID_DESC_160.y)) + float((int)(_2907))) + (_2931.y * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.y) - _2869);
            float _2965 = ((((_2891 - (gridDesc_000[1].PROBE_GRID_DESC_160.z)) + float((int)(_2908))) + (_2931.z * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.z) - _2870);
            float _2971 = sqrt(((_2953 * _2953) + (_2959 * _2959)) + (_2965 * _2965));
            float _2972 = max(_2971, 9.999999747378752e-06f);
            float _2973 = _2953 / _2972;
            float _2974 = _2959 / _2972;
            float _2975 = _2965 / _2972;
            float _2976 = -0.0f - _2973;
            float _2977 = -0.0f - _2974;
            float _2978 = -0.0f - _2975;
            float _2983 = (abs(_2977) + abs(_2976)) + abs(_2978);
            float _2984 = _2976 / _2983;
            float _2985 = _2977 / _2983;
            if (!((_2978 / _2983) > 0.0f)) {
              _3008 = ((1.0f - abs(_2985)) * float((int)(((int)(uint)((int)(_2984 > 0.0f))) - ((int)(uint)((int)(_2984 < 0.0f))))));
              _3009 = ((1.0f - abs(_2984)) * float((int)(((int)(uint)((int)(_2985 > 0.0f))) - ((int)(uint)((int)(_2985 < 0.0f))))));
            } else {
              _3008 = _2984;
              _3009 = _2985;
            }
            float _3010 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_092));
            float _3013 = (_3010 * 0.5f) / (_3010 + 2.0f);
            float _3016 = 1.0f / float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.x));
            float _3017 = 1.0f / float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.y));
            float _3020 = float((int)(_2924)) + 0.5f;
            float _3021 = float((int)(_2925)) + 0.5f;
            float _3028 = float((int)(_2926));
            float3 _3032 = t30[1].SampleLevel(s7, float3((((_3013 * _3008) + _3020) * _3016), (((_3013 * _3009) + _3021) * _3017), _3028), 0.0f);
            float _3039 = (abs(_2346) + abs(_2345)) + abs(_2347);
            float _3040 = _2345 / _3039;
            float _3041 = _2346 / _3039;
            if (!((_2347 / _3039) > 0.0f)) {
              _3064 = ((1.0f - abs(_3041)) * float((int)(((int)(uint)((int)(_3040 > 0.0f))) - ((int)(uint)((int)(_3040 < 0.0f))))));
              _3065 = ((1.0f - abs(_3040)) * float((int)(((int)(uint)((int)(_3041 > 0.0f))) - ((int)(uint)((int)(_3041 < 0.0f))))));
            } else {
              _3064 = _3040;
              _3065 = _3041;
            }
            float _3066 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_088));
            float _3069 = (_3066 * 0.5f) / (_3066 + 2.0f);
            float4 _3079 = t28[1].SampleLevel(s7, float3((((_3069 * _3064) + _3020) * _3016), (((_3069 * _3065) + _3021) * _3017), _3028), 0.0f);
            float _3083 = (gridDesc_000[1].PROBE_GRID_DESC_104) * 0.5f;
            float _3103 = (select((_2907 != 0), _2893, (1.0f - _2893)) * select((_2906 != 0), _2892, (1.0f - _2892))) * select((_2908 != 0), _2894, (1.0f - _2894));
            if (_2971 > _3032.x) {
              float _3109 = abs(_3032.y - (_3032.x * _3032.x));
              float _3110 = _2971 - _3032.x;
              _3116 = ((_3109 / (_3109 + (_3110 * _3110))) * _3103);
            } else {
              _3116 = _3103;
            }
            float _3121 = saturate((dot(float3(_2973, _2974, _2975), float3(_467, _468, _469)) * 0.5f) + 0.5f) * _3116;
            _3130 = ((_3121 * (pow(_3079.x, _3083))) + _2898);
            _3131 = ((_3121 * (pow(_3079.y, _3083))) + _2899);
            _3132 = ((_3121 * (pow(_3079.z, _3083))) + _2900);
            _3133 = (_3121 + _2901);
            _3134 = (_3103 + _2902);
          } else {
            _3130 = _2898;
            _3131 = _2899;
            _3132 = _2900;
            _3133 = _2901;
            _3134 = _2902;
          }
        } else {
          _3130 = _2898;
          _3131 = _2899;
          _3132 = _2900;
          _3133 = _2901;
          _3134 = _2902;
        }
        int _3135 = _2903 + 1;
        if (!(_3135 == 8)) {
          _2898 = _3130;
          _2899 = _3131;
          _2900 = _3132;
          _2901 = _3133;
          _2902 = _3134;
          _2903 = _3135;
          continue;
        }
        break;
      }
      while(true) {
        if (_3133 > 9.999999747378752e-06f) {
          float _3138 = _3130 / _3133;
          float _3139 = _3131 / _3133;
          float _3140 = _3132 / _3133;
          _3160 = ((_3138 * _3138) * 3.1415927410125732f);
          _3161 = ((_3139 * _3139) * 3.1415927410125732f);
          _3162 = ((_3140 * _3140) * 3.1415927410125732f);
          _3163 = _3133;
        } else {
          if (_3134 > 9.999999747378752e-06f) {
            float _3150 = _3130 / _3134;
            float _3151 = _3131 / _3134;
            float _3152 = _3132 / _3134;
            _3160 = ((_3150 * _3150) * 3.1415927410125732f);
            _3161 = ((_3151 * _3151) * 3.1415927410125732f);
            _3162 = ((_3152 * _3152) * 3.1415927410125732f);
            _3163 = _3134;
          } else {
            _3160 = 0.0f;
            _3161 = 0.0f;
            _3162 = 0.0f;
            _3163 = 0.0f;
          }
        }
        if (!(_3163 < 9.999999747378752e-06f)) {
          _3166 = _3160;
          _3167 = _3161;
          _3168 = _3162;
          if (_2824) {
            _3170 = _3166;
            _3171 = _3167;
            _3172 = _3168;
            _3173 = _2825;
            _3174 = _2821;
            _3175 = _2785;
            float _3221 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _467) + TEXCOORD.w) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _492);
            float _3222 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _468) + TEXCOORD_4.w) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _493);
            float _3223 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _469) + TEXCOORD_5.w) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _494);
            float _3227 = (_3221 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
            float _3228 = (_3222 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
            float _3229 = (_3223 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
            int _3239 = min(max(int(_3227), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
            int _3240 = min(max(int(_3228), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
            int _3241 = min(max(int(_3229), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
            float _3242 = float((int)(_3239));
            float _3243 = float((int)(_3240));
            float _3244 = float((int)(_3241));
            float _3245 = _3227 - _3242;
            float _3246 = _3228 - _3243;
            float _3247 = _3229 - _3244;
            _3251 = 0.0f;
            _3252 = 0.0f;
            _3253 = 0.0f;
            _3254 = 0.0f;
            _3255 = 0.0f;
            _3256 = 0;
            while(true) {
              int _3259 = _3256 & 1;
              int _3260 = ((uint)(_3256) >> 1) & 1;
              int _3261 = ((uint)(_3256) >> 2) & 1;
              uint _3262 = _3259 + _3239;
              uint _3263 = _3260 + _3240;
              uint _3264 = _3261 + _3241;
              if (!((int)((int)_3264 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_3262 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_3263 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
                int _3277 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _3262)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
                int _3278 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _3263)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
                int _3279 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _3264)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
                uint _3281 = t38.Load(int4(_3277, _3278, _3279, 0));
                float4 _3287 = t34[0].Load(int3((_3281.x & 511), ((uint)((uint)(_3281.x)) >> 9), 0));
                uint _3289 = t38.Load(int4(_3277, _3278, _3279, 0));
                int _3292 = (uint)((uint)(_3289.x)) >> 7;
                int _3294 = (uint)((uint)(_3289.x)) >> 14;
                if (!((((_3292 | _3289.x) & 127) | _3294) == 0)) {
                  float _3314 = ((((_3242 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_3259))) + (_3287.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _3221);
                  float _3320 = ((((_3243 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_3260))) + (_3287.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _3222);
                  float _3326 = ((((_3244 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_3261))) + (_3287.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _3223);
                  float _3332 = sqrt(((_3314 * _3314) + (_3320 * _3320)) + (_3326 * _3326));
                  float _3333 = max(_3332, 9.999999747378752e-06f);
                  float _3334 = _3314 / _3333;
                  float _3335 = _3320 / _3333;
                  float _3336 = _3326 / _3333;
                  float _3337 = -0.0f - _3334;
                  float _3338 = -0.0f - _3335;
                  float _3339 = -0.0f - _3336;
                  float _3344 = (abs(_3338) + abs(_3337)) + abs(_3339);
                  float _3345 = _3337 / _3344;
                  float _3346 = _3338 / _3344;
                  if (!((_3339 / _3344) > 0.0f)) {
                    _3369 = ((1.0f - abs(_3346)) * float((int)(((int)(uint)((int)(_3345 > 0.0f))) - ((int)(uint)((int)(_3345 < 0.0f))))));
                    _3370 = ((1.0f - abs(_3345)) * float((int)(((int)(uint)((int)(_3346 > 0.0f))) - ((int)(uint)((int)(_3346 < 0.0f))))));
                  } else {
                    _3369 = _3345;
                    _3370 = _3346;
                  }
                  float _3371 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                  float _3374 = (_3371 * 0.5f) / (_3371 + 2.0f);
                  float _3377 = float((int)(_3289.x & 127)) + 0.5f;
                  float _3378 = float((int)(_3292 & 127)) + 0.5f;
                  float _3385 = float((int)(_3294));
                  float3 _3389 = t30[0].SampleLevel(s7, float3((((_3374 * _3369) + _3377) * 0.0078125f), (((_3374 * _3370) + _3378) * 0.0078125f), _3385), 0.0f);
                  float _3396 = (abs(_2346) + abs(_2345)) + abs(_2347);
                  float _3397 = _2345 / _3396;
                  float _3398 = _2346 / _3396;
                  if (!((_2347 / _3396) > 0.0f)) {
                    _3421 = ((1.0f - abs(_3398)) * float((int)(((int)(uint)((int)(_3397 > 0.0f))) - ((int)(uint)((int)(_3397 < 0.0f))))));
                    _3422 = ((1.0f - abs(_3397)) * float((int)(((int)(uint)((int)(_3398 > 0.0f))) - ((int)(uint)((int)(_3398 < 0.0f))))));
                  } else {
                    _3421 = _3397;
                    _3422 = _3398;
                  }
                  float _3423 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                  float _3426 = (_3423 * 0.5f) / (_3423 + 2.0f);
                  float4 _3436 = t28[0].SampleLevel(s7, float3((((_3426 * _3421) + _3377) * 0.0078125f), (((_3426 * _3422) + _3378) * 0.0078125f), _3385), 0.0f);
                  float _3440 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                  float _3460 = (select((_3260 != 0), _3246, (1.0f - _3246)) * select((_3259 != 0), _3245, (1.0f - _3245))) * select((_3261 != 0), _3247, (1.0f - _3247));
                  if (_3332 > _3389.x) {
                    float _3466 = abs(_3389.y - (_3389.x * _3389.x));
                    float _3467 = _3332 - _3389.x;
                    _3473 = ((_3466 / (_3466 + (_3467 * _3467))) * _3460);
                  } else {
                    _3473 = _3460;
                  }
                  float _3478 = saturate((dot(float3(_3334, _3335, _3336), float3(_467, _468, _469)) * 0.5f) + 0.5f) * _3473;
                  _3487 = ((_3478 * (pow(_3436.x, _3440))) + _3251);
                  _3488 = ((_3478 * (pow(_3436.y, _3440))) + _3252);
                  _3489 = ((_3478 * (pow(_3436.z, _3440))) + _3253);
                  _3490 = (_3478 + _3254);
                  _3491 = (_3460 + _3255);
                } else {
                  _3487 = _3251;
                  _3488 = _3252;
                  _3489 = _3253;
                  _3490 = _3254;
                  _3491 = _3255;
                }
              } else {
                _3487 = _3251;
                _3488 = _3252;
                _3489 = _3253;
                _3490 = _3254;
                _3491 = _3255;
              }
              int _3492 = _3256 + 1;
              if (!(_3492 == 8)) {
                _3251 = _3487;
                _3252 = _3488;
                _3253 = _3489;
                _3254 = _3490;
                _3255 = _3491;
                _3256 = _3492;
                continue;
              }
              break;
            }
            while(true) {
              if (_3490 > 9.999999747378752e-06f) {
                float _3495 = _3487 / _3490;
                float _3496 = _3488 / _3490;
                float _3497 = _3489 / _3490;
                _3517 = ((_3495 * _3495) * 3.1415927410125732f);
                _3518 = ((_3496 * _3496) * 3.1415927410125732f);
                _3519 = ((_3497 * _3497) * 3.1415927410125732f);
                _3520 = _3490;
              } else {
                if (_3491 > 9.999999747378752e-06f) {
                  float _3507 = _3487 / _3491;
                  float _3508 = _3488 / _3491;
                  float _3509 = _3489 / _3491;
                  _3517 = ((_3507 * _3507) * 3.1415927410125732f);
                  _3518 = ((_3508 * _3508) * 3.1415927410125732f);
                  _3519 = ((_3509 * _3509) * 3.1415927410125732f);
                  _3520 = _3491;
                } else {
                  _3517 = 0.0f;
                  _3518 = 0.0f;
                  _3519 = 0.0f;
                  _3520 = 0.0f;
                }
              }
              if (_3520 < 9.999999747378752e-06f) {
                _3524 = _3170;
                _3525 = _3171;
                _3526 = _3172;
                _3527 = _3174;
                _3528 = _3175;
                _3529 = 0.0f;
                _3530 = 0;
                _3531 = _3517;
                _3532 = _3518;
                _3533 = _3519;
              } else {
                _3524 = _3170;
                _3525 = _3171;
                _3526 = _3172;
                _3527 = _3174;
                _3528 = _3175;
                _3529 = _2819;
                _3530 = _3173;
                _3531 = _3517;
                _3532 = _3518;
                _3533 = _3519;
              }
              break;
            }
          } else {
            _3524 = _3166;
            _3525 = _3167;
            _3526 = _3168;
            _3527 = _2821;
            _3528 = _2785;
            _3529 = _2819;
            _3530 = _2825;
            _3531 = 0.0f;
            _3532 = 0.0f;
            _3533 = 0.0f;
          }
        } else {
          _3170 = _3160;
          _3171 = _3161;
          _3172 = _3162;
          _3173 = 1;
          _3174 = 0;
          _3175 = 0.0f;
          float _3221 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _467) + TEXCOORD.w) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _492);
          float _3222 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _468) + TEXCOORD_4.w) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _493);
          float _3223 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _469) + TEXCOORD_5.w) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _494);
          float _3227 = (_3221 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
          float _3228 = (_3222 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
          float _3229 = (_3223 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
          int _3239 = min(max(int(_3227), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
          int _3240 = min(max(int(_3228), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
          int _3241 = min(max(int(_3229), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
          float _3242 = float((int)(_3239));
          float _3243 = float((int)(_3240));
          float _3244 = float((int)(_3241));
          float _3245 = _3227 - _3242;
          float _3246 = _3228 - _3243;
          float _3247 = _3229 - _3244;
          _3251 = 0.0f;
          _3252 = 0.0f;
          _3253 = 0.0f;
          _3254 = 0.0f;
          _3255 = 0.0f;
          _3256 = 0;
          while(true) {
            int _3259 = _3256 & 1;
            int _3260 = ((uint)(_3256) >> 1) & 1;
            int _3261 = ((uint)(_3256) >> 2) & 1;
            uint _3262 = _3259 + _3239;
            uint _3263 = _3260 + _3240;
            uint _3264 = _3261 + _3241;
            if (!((int)((int)_3264 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_3262 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_3263 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
              int _3277 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _3262)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
              int _3278 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _3263)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
              int _3279 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _3264)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
              uint _3281 = t38.Load(int4(_3277, _3278, _3279, 0));
              float4 _3287 = t34[0].Load(int3((_3281.x & 511), ((uint)((uint)(_3281.x)) >> 9), 0));
              uint _3289 = t38.Load(int4(_3277, _3278, _3279, 0));
              int _3292 = (uint)((uint)(_3289.x)) >> 7;
              int _3294 = (uint)((uint)(_3289.x)) >> 14;
              if (!((((_3292 | _3289.x) & 127) | _3294) == 0)) {
                float _3314 = ((((_3242 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_3259))) + (_3287.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _3221);
                float _3320 = ((((_3243 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_3260))) + (_3287.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _3222);
                float _3326 = ((((_3244 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_3261))) + (_3287.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _3223);
                float _3332 = sqrt(((_3314 * _3314) + (_3320 * _3320)) + (_3326 * _3326));
                float _3333 = max(_3332, 9.999999747378752e-06f);
                float _3334 = _3314 / _3333;
                float _3335 = _3320 / _3333;
                float _3336 = _3326 / _3333;
                float _3337 = -0.0f - _3334;
                float _3338 = -0.0f - _3335;
                float _3339 = -0.0f - _3336;
                float _3344 = (abs(_3338) + abs(_3337)) + abs(_3339);
                float _3345 = _3337 / _3344;
                float _3346 = _3338 / _3344;
                if (!((_3339 / _3344) > 0.0f)) {
                  _3369 = ((1.0f - abs(_3346)) * float((int)(((int)(uint)((int)(_3345 > 0.0f))) - ((int)(uint)((int)(_3345 < 0.0f))))));
                  _3370 = ((1.0f - abs(_3345)) * float((int)(((int)(uint)((int)(_3346 > 0.0f))) - ((int)(uint)((int)(_3346 < 0.0f))))));
                } else {
                  _3369 = _3345;
                  _3370 = _3346;
                }
                float _3371 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                float _3374 = (_3371 * 0.5f) / (_3371 + 2.0f);
                float _3377 = float((int)(_3289.x & 127)) + 0.5f;
                float _3378 = float((int)(_3292 & 127)) + 0.5f;
                float _3385 = float((int)(_3294));
                float3 _3389 = t30[0].SampleLevel(s7, float3((((_3374 * _3369) + _3377) * 0.0078125f), (((_3374 * _3370) + _3378) * 0.0078125f), _3385), 0.0f);
                float _3396 = (abs(_2346) + abs(_2345)) + abs(_2347);
                float _3397 = _2345 / _3396;
                float _3398 = _2346 / _3396;
                if (!((_2347 / _3396) > 0.0f)) {
                  _3421 = ((1.0f - abs(_3398)) * float((int)(((int)(uint)((int)(_3397 > 0.0f))) - ((int)(uint)((int)(_3397 < 0.0f))))));
                  _3422 = ((1.0f - abs(_3397)) * float((int)(((int)(uint)((int)(_3398 > 0.0f))) - ((int)(uint)((int)(_3398 < 0.0f))))));
                } else {
                  _3421 = _3397;
                  _3422 = _3398;
                }
                float _3423 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                float _3426 = (_3423 * 0.5f) / (_3423 + 2.0f);
                float4 _3436 = t28[0].SampleLevel(s7, float3((((_3426 * _3421) + _3377) * 0.0078125f), (((_3426 * _3422) + _3378) * 0.0078125f), _3385), 0.0f);
                float _3440 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                float _3460 = (select((_3260 != 0), _3246, (1.0f - _3246)) * select((_3259 != 0), _3245, (1.0f - _3245))) * select((_3261 != 0), _3247, (1.0f - _3247));
                if (_3332 > _3389.x) {
                  float _3466 = abs(_3389.y - (_3389.x * _3389.x));
                  float _3467 = _3332 - _3389.x;
                  _3473 = ((_3466 / (_3466 + (_3467 * _3467))) * _3460);
                } else {
                  _3473 = _3460;
                }
                float _3478 = saturate((dot(float3(_3334, _3335, _3336), float3(_467, _468, _469)) * 0.5f) + 0.5f) * _3473;
                _3487 = ((_3478 * (pow(_3436.x, _3440))) + _3251);
                _3488 = ((_3478 * (pow(_3436.y, _3440))) + _3252);
                _3489 = ((_3478 * (pow(_3436.z, _3440))) + _3253);
                _3490 = (_3478 + _3254);
                _3491 = (_3460 + _3255);
              } else {
                _3487 = _3251;
                _3488 = _3252;
                _3489 = _3253;
                _3490 = _3254;
                _3491 = _3255;
              }
            } else {
              _3487 = _3251;
              _3488 = _3252;
              _3489 = _3253;
              _3490 = _3254;
              _3491 = _3255;
            }
            int _3492 = _3256 + 1;
            if (!(_3492 == 8)) {
              _3251 = _3487;
              _3252 = _3488;
              _3253 = _3489;
              _3254 = _3490;
              _3255 = _3491;
              _3256 = _3492;
              continue;
            }
            break;
          }
          while(true) {
            if (_3490 > 9.999999747378752e-06f) {
              float _3495 = _3487 / _3490;
              float _3496 = _3488 / _3490;
              float _3497 = _3489 / _3490;
              _3517 = ((_3495 * _3495) * 3.1415927410125732f);
              _3518 = ((_3496 * _3496) * 3.1415927410125732f);
              _3519 = ((_3497 * _3497) * 3.1415927410125732f);
              _3520 = _3490;
            } else {
              if (_3491 > 9.999999747378752e-06f) {
                float _3507 = _3487 / _3491;
                float _3508 = _3488 / _3491;
                float _3509 = _3489 / _3491;
                _3517 = ((_3507 * _3507) * 3.1415927410125732f);
                _3518 = ((_3508 * _3508) * 3.1415927410125732f);
                _3519 = ((_3509 * _3509) * 3.1415927410125732f);
                _3520 = _3491;
              } else {
                _3517 = 0.0f;
                _3518 = 0.0f;
                _3519 = 0.0f;
                _3520 = 0.0f;
              }
            }
            if (_3520 < 9.999999747378752e-06f) {
              _3524 = _3170;
              _3525 = _3171;
              _3526 = _3172;
              _3527 = _3174;
              _3528 = _3175;
              _3529 = 0.0f;
              _3530 = 0;
              _3531 = _3517;
              _3532 = _3518;
              _3533 = _3519;
            } else {
              _3524 = _3170;
              _3525 = _3171;
              _3526 = _3172;
              _3527 = _3174;
              _3528 = _3175;
              _3529 = _2819;
              _3530 = _3173;
              _3531 = _3517;
              _3532 = _3518;
              _3533 = _3519;
            }
            break;
          }
        }
        break;
      }
    } else {
      _3166 = 0.0f;
      _3167 = 0.0f;
      _3168 = 0.0f;
      if (_2824) {
        _3170 = _3166;
        _3171 = _3167;
        _3172 = _3168;
        _3173 = _2825;
        _3174 = _2821;
        _3175 = _2785;
        float _3221 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _467) + TEXCOORD.w) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _492);
        float _3222 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _468) + TEXCOORD_4.w) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _493);
        float _3223 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _469) + TEXCOORD_5.w) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _494);
        float _3227 = (_3221 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
        float _3228 = (_3222 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
        float _3229 = (_3223 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
        int _3239 = min(max(int(_3227), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
        int _3240 = min(max(int(_3228), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
        int _3241 = min(max(int(_3229), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
        float _3242 = float((int)(_3239));
        float _3243 = float((int)(_3240));
        float _3244 = float((int)(_3241));
        float _3245 = _3227 - _3242;
        float _3246 = _3228 - _3243;
        float _3247 = _3229 - _3244;
        _3251 = 0.0f;
        _3252 = 0.0f;
        _3253 = 0.0f;
        _3254 = 0.0f;
        _3255 = 0.0f;
        _3256 = 0;
        while(true) {
          int _3259 = _3256 & 1;
          int _3260 = ((uint)(_3256) >> 1) & 1;
          int _3261 = ((uint)(_3256) >> 2) & 1;
          uint _3262 = _3259 + _3239;
          uint _3263 = _3260 + _3240;
          uint _3264 = _3261 + _3241;
          if (!((int)((int)_3264 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_3262 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_3263 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
            int _3277 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _3262)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
            int _3278 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _3263)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
            int _3279 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _3264)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
            uint _3281 = t38.Load(int4(_3277, _3278, _3279, 0));
            float4 _3287 = t34[0].Load(int3((_3281.x & 511), ((uint)((uint)(_3281.x)) >> 9), 0));
            uint _3289 = t38.Load(int4(_3277, _3278, _3279, 0));
            int _3292 = (uint)((uint)(_3289.x)) >> 7;
            int _3294 = (uint)((uint)(_3289.x)) >> 14;
            if (!((((_3292 | _3289.x) & 127) | _3294) == 0)) {
              float _3314 = ((((_3242 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_3259))) + (_3287.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _3221);
              float _3320 = ((((_3243 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_3260))) + (_3287.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _3222);
              float _3326 = ((((_3244 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_3261))) + (_3287.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _3223);
              float _3332 = sqrt(((_3314 * _3314) + (_3320 * _3320)) + (_3326 * _3326));
              float _3333 = max(_3332, 9.999999747378752e-06f);
              float _3334 = _3314 / _3333;
              float _3335 = _3320 / _3333;
              float _3336 = _3326 / _3333;
              float _3337 = -0.0f - _3334;
              float _3338 = -0.0f - _3335;
              float _3339 = -0.0f - _3336;
              float _3344 = (abs(_3338) + abs(_3337)) + abs(_3339);
              float _3345 = _3337 / _3344;
              float _3346 = _3338 / _3344;
              if (!((_3339 / _3344) > 0.0f)) {
                _3369 = ((1.0f - abs(_3346)) * float((int)(((int)(uint)((int)(_3345 > 0.0f))) - ((int)(uint)((int)(_3345 < 0.0f))))));
                _3370 = ((1.0f - abs(_3345)) * float((int)(((int)(uint)((int)(_3346 > 0.0f))) - ((int)(uint)((int)(_3346 < 0.0f))))));
              } else {
                _3369 = _3345;
                _3370 = _3346;
              }
              float _3371 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
              float _3374 = (_3371 * 0.5f) / (_3371 + 2.0f);
              float _3377 = float((int)(_3289.x & 127)) + 0.5f;
              float _3378 = float((int)(_3292 & 127)) + 0.5f;
              float _3385 = float((int)(_3294));
              float3 _3389 = t30[0].SampleLevel(s7, float3((((_3374 * _3369) + _3377) * 0.0078125f), (((_3374 * _3370) + _3378) * 0.0078125f), _3385), 0.0f);
              float _3396 = (abs(_2346) + abs(_2345)) + abs(_2347);
              float _3397 = _2345 / _3396;
              float _3398 = _2346 / _3396;
              if (!((_2347 / _3396) > 0.0f)) {
                _3421 = ((1.0f - abs(_3398)) * float((int)(((int)(uint)((int)(_3397 > 0.0f))) - ((int)(uint)((int)(_3397 < 0.0f))))));
                _3422 = ((1.0f - abs(_3397)) * float((int)(((int)(uint)((int)(_3398 > 0.0f))) - ((int)(uint)((int)(_3398 < 0.0f))))));
              } else {
                _3421 = _3397;
                _3422 = _3398;
              }
              float _3423 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
              float _3426 = (_3423 * 0.5f) / (_3423 + 2.0f);
              float4 _3436 = t28[0].SampleLevel(s7, float3((((_3426 * _3421) + _3377) * 0.0078125f), (((_3426 * _3422) + _3378) * 0.0078125f), _3385), 0.0f);
              float _3440 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
              float _3460 = (select((_3260 != 0), _3246, (1.0f - _3246)) * select((_3259 != 0), _3245, (1.0f - _3245))) * select((_3261 != 0), _3247, (1.0f - _3247));
              if (_3332 > _3389.x) {
                float _3466 = abs(_3389.y - (_3389.x * _3389.x));
                float _3467 = _3332 - _3389.x;
                _3473 = ((_3466 / (_3466 + (_3467 * _3467))) * _3460);
              } else {
                _3473 = _3460;
              }
              float _3478 = saturate((dot(float3(_3334, _3335, _3336), float3(_467, _468, _469)) * 0.5f) + 0.5f) * _3473;
              _3487 = ((_3478 * (pow(_3436.x, _3440))) + _3251);
              _3488 = ((_3478 * (pow(_3436.y, _3440))) + _3252);
              _3489 = ((_3478 * (pow(_3436.z, _3440))) + _3253);
              _3490 = (_3478 + _3254);
              _3491 = (_3460 + _3255);
            } else {
              _3487 = _3251;
              _3488 = _3252;
              _3489 = _3253;
              _3490 = _3254;
              _3491 = _3255;
            }
          } else {
            _3487 = _3251;
            _3488 = _3252;
            _3489 = _3253;
            _3490 = _3254;
            _3491 = _3255;
          }
          int _3492 = _3256 + 1;
          if (!(_3492 == 8)) {
            _3251 = _3487;
            _3252 = _3488;
            _3253 = _3489;
            _3254 = _3490;
            _3255 = _3491;
            _3256 = _3492;
            continue;
          }
          break;
        }
        while(true) {
          if (_3490 > 9.999999747378752e-06f) {
            float _3495 = _3487 / _3490;
            float _3496 = _3488 / _3490;
            float _3497 = _3489 / _3490;
            _3517 = ((_3495 * _3495) * 3.1415927410125732f);
            _3518 = ((_3496 * _3496) * 3.1415927410125732f);
            _3519 = ((_3497 * _3497) * 3.1415927410125732f);
            _3520 = _3490;
          } else {
            if (_3491 > 9.999999747378752e-06f) {
              float _3507 = _3487 / _3491;
              float _3508 = _3488 / _3491;
              float _3509 = _3489 / _3491;
              _3517 = ((_3507 * _3507) * 3.1415927410125732f);
              _3518 = ((_3508 * _3508) * 3.1415927410125732f);
              _3519 = ((_3509 * _3509) * 3.1415927410125732f);
              _3520 = _3491;
            } else {
              _3517 = 0.0f;
              _3518 = 0.0f;
              _3519 = 0.0f;
              _3520 = 0.0f;
            }
          }
          if (_3520 < 9.999999747378752e-06f) {
            _3524 = _3170;
            _3525 = _3171;
            _3526 = _3172;
            _3527 = _3174;
            _3528 = _3175;
            _3529 = 0.0f;
            _3530 = 0;
            _3531 = _3517;
            _3532 = _3518;
            _3533 = _3519;
          } else {
            _3524 = _3170;
            _3525 = _3171;
            _3526 = _3172;
            _3527 = _3174;
            _3528 = _3175;
            _3529 = _2819;
            _3530 = _3173;
            _3531 = _3517;
            _3532 = _3518;
            _3533 = _3519;
          }
          break;
        }
      } else {
        _3524 = _3166;
        _3525 = _3167;
        _3526 = _3168;
        _3527 = _2821;
        _3528 = _2785;
        _3529 = _2819;
        _3530 = _2825;
        _3531 = 0.0f;
        _3532 = 0.0f;
        _3533 = 0.0f;
      }
    }
    bool _3536 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
    float _3540 = select(_3536, 0.0f, _3531);
    float _3541 = select(_3536, 0.0f, _3532);
    float _3542 = select(_3536, 1.0f, _3533);
    int _3543 = _3530 | _3527;
    if ((int)(_3529 < 1.0f) || (int)(_3543 == 0)) {
      float _3554 = (abs(_2346) + abs(_2345)) + abs(_2347);
      float _3555 = _2345 / _3554;
      float _3556 = _2346 / _3554;
      if (!((_2347 / _3554) > 0.0f)) {
        _3579 = ((1.0f - abs(_3556)) * float((int)(((int)(uint)((int)(_3555 > 0.0f))) - ((int)(uint)((int)(_3555 < 0.0f))))));
        _3580 = ((1.0f - abs(_3555)) * float((int)(((int)(uint)((int)(_3556 > 0.0f))) - ((int)(uint)((int)(_3556 < 0.0f))))));
      } else {
        _3579 = _3555;
        _3580 = _3556;
      }
      float _3581 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
      float _3584 = (_3581 * 0.5f) / (_3581 + 2.0f);
      float4 _3594 = t28[0].SampleLevel(s7, float3((((_3584 * _3579) + 0.5f) * 0.0078125f), (((_3584 * _3580) + 0.5f) * 0.0078125f), 0.0f), 0.0f);
      bool _3603 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
      float _3604 = select(_3603, 0.0f, (_3594.x * 3.1415927410125732f));
      float _3605 = select(_3603, 1.0f, (_3594.y * 3.1415927410125732f));
      float _3606 = select(_3603, 0.0f, (_3594.z * 3.1415927410125732f));
      _3619 = select((_3543 != 0), _3528, 0.0f);
      _3620 = (lerp(_3604, _3540, _3529));
      _3621 = (lerp(_3605, _3541, _3529));
      _3622 = (lerp(_3606, _3542, _3529));
    } else {
      _3619 = _3528;
      _3620 = _3540;
      _3621 = _3541;
      _3622 = _3542;
    }
    float _3629 = ((select(_3536, 1.0f, _3524) - _3620) * _3619) + _3620;
    float _3630 = ((select(_3536, 0.0f, _3525) - _3621) * _3619) + _3621;
    float _3631 = ((select(_3536, 0.0f, _3526) - _3622) * _3619) + _3622;
    bool _3636 = ((int)((int)(isnan(_3629)) || (int)(isnan(_3630)))) || (int)(isnan(_3631));
    _3643 = select(_3636, 0.0f, _3629);
    _3644 = select(_3636, 0.0f, _3630);
    _3645 = select(_3636, 0.0f, _3631);
    _3646 = (select(_3636, 0.0f, _3619) == 0.0f);
  } else {
    _3643 = 0.0f;
    _3644 = 0.0f;
    _3645 = 0.0f;
    _3646 = true;
  }
  float _3651 = select(_3646, 1.0f, (dot(float3(_3643, _3644, _3645), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f)) / dot(float3((_2744 * _2741), (_2744 * _2742), (_2744 * _2743)), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f)))) * (1.0f / _2544);
  bool _3657 = (cb12_074x > 0.0f);
  float _3664 = FrequentPixelConsts_256.z - FrequentPixelConsts_256.w;
  float _3684 = saturate(1.0f - abs(max(abs(dot(float3(_467, _468, _469), float3(_492, _493, _494))), abs(dot(float3(_472, _473, _474), float3(_492, _493, _494))))));
  float _3685 = _3684 * _3684;
  float _3699 = ((_3685 * _3685) * _3684) * min(0.25f, cb13_066y);
  float _3705 = (cb13_066w + 1.0f) - (cb13_066w * (1.0f - _437));
  float4 _3716 = t17.Load(int3(_434, _435, 0));
  float _3734 = ((saturate(cb4_013x) * (saturate((cb12_187x * _3716.x) + cb12_188x) + -1.0f)) * (((cb12_069z + -1.0f) * _436) + 1.0f)) + 1.0f;
  bool _3739 = (_496.z < 0.9900000095367432f);
  if (_3739) {
    _3744 = cb12_287w;
  } else {
    _3744 = 1.0f;
  }
  float _3750 = exp2((cb12_288y * _3744) * log2(_3734));
  if (_3739) {
    _3755 = cb12_287w;
  } else {
    _3755 = 1.0f;
  }
  float _3758 = log2((_3734 * cb12_069x) + cb12_069y);
  if (_3739) {
    _3765 = cb12_287w;
  } else {
    _3765 = 1.0f;
  }
  float _3770 = exp2((_3755 * cb12_288z) * _3758) * cb12_184z;
  float _3771 = _3770 * _2331;
  float _3772 = _3770 * _2332;
  float _3773 = _3770 * _2333;
  float _3774 = exp2((_3758 * cb12_288w) * _3765) * cb12_184w;
  bool _3778 = (_464 == 0);
  float _3785 = (_3774 * _2334) + select(_3778, (_3771 * _459), _3771);
  float _3786 = (_3774 * _2335) + select(_3778, (_3772 * _460), _3772);
  float _3787 = (_3774 * _2336) + select(_3778, (_3773 * _461), _3773);
  if (!_3657) {
    _3796 = (_3785 + (((((_3664 * min(_1136, _496.y)) + FrequentPixelConsts_256.w) * select(_3657, 0.0f, (_3651 * _2545))) * (((_3699 * max(0.0f, (1.0f - _447))) / _3705) + _447)) * _3750));
    _3797 = (_3786 + (((((_3664 * min(_1137, _496.y)) + FrequentPixelConsts_256.w) * select(_3657, 0.0f, (_3651 * _2546))) * (((_3699 * max(0.0f, (1.0f - _448))) / _3705) + _448)) * _3750));
    _3798 = (_3787 + (((((_3664 * min(_1138, _496.y)) + FrequentPixelConsts_256.w) * select(_3657, 0.0f, (_3651 * _2547))) * (((max(0.0f, (1.0f - _449)) * _3699) / _3705) + _449)) * _3750));
  } else {
    _3796 = _3785;
    _3797 = _3786;
    _3798 = _3787;
  }
  SV_Target.x = _3796;
  SV_Target.y = _3797;
  SV_Target.z = _3798;
  SV_Target.w = _62.w;
  return SV_Target;
}
