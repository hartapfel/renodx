// GRAPHICS HIT BEGIN
// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "shared.h"
#include "raytracing/hit_lighting.hlsli"
#include "water/receiver.hlsli"
#ifdef WITCHER_GRAPHICS_CUSTOM_LIGHTING
#define GRAPHICS_RAY_SKYLIGHT WitcherNightSkylight(hartapfel_skylight)
#else
#include "clouds/ray_shadow_receiver.hlsli"
#define GRAPHICS_RAY_SKYLIGHT 1.f
#endif
// GRAPHICS HIT END
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

struct ShadingParams {
  float4 ShadingParams_000;
  float4 ShadingParams_016;
  float4 ShadingParams_032;
  float ShadingParams_048;
  float ShadingParams_052;
  float ShadingParams_056;
  float ShadingParams_060;
  float ShadingParams_064;
  float ShadingParams_068;
  float ShadingParams_072;
  float ShadingParams_076;
  float ShadingParams_080;
  float ShadingParams_084;
  float ShadingParams_088[2];
};

struct light {
  int light_000;
};

struct range {
  int range_000;
  int range_004;
};


Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float> t19 : register(t19);

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

StructuredBuffer<uint2> t5 : register(t5);

StructuredBuffer<uint2> t6 : register(t6);

Texture2DArray<float4> t28[2] : register(t28);

Texture2DArray<float3> t30[2] : register(t30);

Texture2D<uint> t32[2] : register(t32);

Texture2D<float4> t34[2] : register(t34);

Texture2DArray<uint> t38 : register(t38);

StructuredBuffer<LightParams> t16 : register(t16);

Texture2DArray<float> t8 : register(t8);

Texture2DArray<float> t9 : register(t9);

TextureCubeArray<float> t10 : register(t10);

Texture2DArray<float4> t42 : register(t42);

StructuredBuffer<range> t25 : register(t25);

StructuredBuffer<light> t26 : register(t26);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t39 : register(t39);

RWTexture2D<float4> u4 : register(u4);

cbuffer cb12 : register(b12) {
#ifdef WITCHER_GRAPHICS_CUSTOM_LIGHTING
  float hartapfel_skylight : packoffset(c185.w);
  float4 hartapfel_jitter : packoffset(c286);
#endif
  float cb12_000x : packoffset(c000.x);
  float cb12_000y : packoffset(c000.y);
  float cb12_000z : packoffset(c000.z);
  float cb12_066x : packoffset(c066.x);
  float cb12_066w : packoffset(c066.w);
  float cb12_067x : packoffset(c067.x);
  float cb12_067y : packoffset(c067.y);
  float cb12_068x : packoffset(c068.x);
  float cb12_068y : packoffset(c068.y);
// GRAPHICS WATER BEGIN
  float cb12_074x : packoffset(c074.x);
// GRAPHICS WATER END
  float cb12_074y : packoffset(c074.y);
  float cb12_219x : packoffset(c219.x);
  float cb12_219y : packoffset(c219.y);
  float cb12_219z : packoffset(c219.z);
  float cb12_219w : packoffset(c219.w);
  float cb12_225y : packoffset(c225.y);
  float cb12_225z : packoffset(c225.z);
  uint cb12_padding : packoffset(c340.w);
};

cbuffer cb7 : register(b7) {
  float4 cb7_raw[36] : packoffset(c0);
};

#define cb7_027z (cb7_raw[27].z)
#define cb7_032x (cb7_raw[32].x)
#define cb7_029x (cb7_raw[29].x)
#define cb7_023w (asint(cb7_raw[23].w))
#define cb7_032y (cb7_raw[32].y)
#define cb7_019z (cb7_raw[19].z)
#define cb7_029y (cb7_raw[29].y)
#define cb7_012x (cb7_raw[12].x)
#define cb7_019y (cb7_raw[19].y)
#define cb7_029z (cb7_raw[29].z)
#define cb7_031x (cb7_raw[31].x)
#define cb7_027w (cb7_raw[27].w)
#define cb7_023z (asint(cb7_raw[23].z))
#define cb7_031y (cb7_raw[31].y)
#define cb7_032w (cb7_raw[32].w)
#define cb7_031z (cb7_raw[31].z)
#define cb7_032z (cb7_raw[32].z)
#define cb7_011x (cb7_raw[11].x)
#define cb7_011y (cb7_raw[11].y)
#define cb7_009w (cb7_raw[9].w)
#define cb7_011z (cb7_raw[11].z)
#define cb7_014y (cb7_raw[14].y)
#define cb7_013x (cb7_raw[13].x)
#define cb7_005z (asint(cb7_raw[5].z))
#define cb7_014x (cb7_raw[14].x)
#define cb7_013y (cb7_raw[13].y)
#define cb7_013z (cb7_raw[13].z)
#define cb7_014z (cb7_raw[14].z)
#define cb7_000z (cb7_raw[0].z)
#define cb7_014w (cb7_raw[14].w)
#define cb7_018x (cb7_raw[18].x)
#define cb7_018y (cb7_raw[18].y)
#define cb7_018z (cb7_raw[18].z)
#define cb7_019x (cb7_raw[19].x)
#define cb7_020x (asint(cb7_raw[20].x))
#define cb7_025z (asint(cb7_raw[25].z))
#define cb7_020y (asint(cb7_raw[20].y))
#define cb7_025y (asint(cb7_raw[25].y))
#define cb7_020z (asint(cb7_raw[20].z))
#define cb7_024z (cb7_raw[24].z)
#define cb7_025x (asint(cb7_raw[25].x))
#define cb7_028x (cb7_raw[28].x)
#define cb7_028y (cb7_raw[28].y)
#define cb7_028z (cb7_raw[28].z)
#define cb7_030x (cb7_raw[30].x)
#define cb7_007z (asint(cb7_raw[7].z))
#define cb7_002y (asint(cb7_raw[2].y))
#define cb7_002x (asint(cb7_raw[2].x))
#define cb7_030y (cb7_raw[30].y)
#define cb7_030z (cb7_raw[30].z)
#define cb7_007x (asint(cb7_raw[7].x))
#define cb7_005w (asint(cb7_raw[5].w))
#define cb7_000x (cb7_raw[0].x)
#define cb7_000y (cb7_raw[0].y)
#define cb7_001x (cb7_raw[1].x)
#define cb7_001y (cb7_raw[1].y)
#define cb7_001z (cb7_raw[1].z)
#define cb7_007y (asint(cb7_raw[7].y))
#define cb7_002z (asint(cb7_raw[2].z))
#define cb7_006z (cb7_raw[6].z)
#define cb7_010x (cb7_raw[10].x)
#define cb7_009z (cb7_raw[9].z)
#define cb7_010y (cb7_raw[10].y)
#define cb7_010z (cb7_raw[10].z)
#define cb7_012y (cb7_raw[12].y)
#define cb7_012z (cb7_raw[12].z)
#define cb7_007w (asint(cb7_raw[7].w))
#define cb7_004w (asint(cb7_raw[4].w))
#define cb7_004z (asint(cb7_raw[4].z))
#define cb7_005x (asint(cb7_raw[5].x))

cbuffer cb8 : register(b8) {
  int currentGridData_000 : packoffset(c000.x);
};

cbuffer cb13 : register(b13) {
  float4 cb13_raw[3589] : packoffset(c0);
};

#define cb13_000z (cb13_raw[0].z)
#define cb13_001y (cb13_raw[1].y)
#define cb13_066z (cb13_raw[66].z)
#define cb13_059x (asint(cb13_raw[59].x))
#define cb13_016y (cb13_raw[16].y)
#define cb13_067y (asint(cb13_raw[67].y))
#define cb13_016x (cb13_raw[16].x)
#define cb13_067x (cb13_raw[67].x)
#define cb13_000x (cb13_raw[0].x)
#define cb13_066x (cb13_raw[66].x)
#define cb13_036x (cb13_raw[36].x)
#define cb13_000y (cb13_raw[0].y)
#define cb13_035x (cb13_raw[35].x)
#define cb13_008w (cb13_raw[8].w)
#define cb13_006y (cb13_raw[6].y)
#define cb13_034x (asint(cb13_raw[34].x))
#define cb13_034z (cb13_raw[34].z)
#define cb13_008x (cb13_raw[8].x)
#define cb13_007y (cb13_raw[7].y)
#define cb13_034w (cb13_raw[34].w)
#define cb13_035w (cb13_raw[35].w)
#define cb13_035y (cb13_raw[35].y)
#define cb13_035z (cb13_raw[35].z)
#define cb13_004y (cb13_raw[4].y)
#define cb13_003x (cb13_raw[3].x)
#define cb13_004x (cb13_raw[4].x)
#define cb13_003y (cb13_raw[3].y)
#define cb13_003z (cb13_raw[3].z)
#define cb13_004z (cb13_raw[4].z)
#define cb13_014z (cb13_raw[14].z)
#define cb13_005x (cb13_raw[5].x)
#define cb13_062z (cb13_raw[62].z)
#define cb13_005y (cb13_raw[5].y)
#define cb13_062y (cb13_raw[62].y)
#define cb13_005z (cb13_raw[5].z)
#define cb13_007w (cb13_raw[7].w)
#define cb13_006x (cb13_raw[6].x)
#define cb13_006z (cb13_raw[6].z)
#define cb13_008y (cb13_raw[8].y)
#define cb13_007x (cb13_raw[7].x)
#define cb13_007z (cb13_raw[7].z)
#define cb13_008z (cb13_raw[8].z)
#define cb13_061z (cb13_raw[61].z)
#define cb13_009x (cb13_raw[9].x)
#define cb13_009y (cb13_raw[9].y)
#define cb13_061x (cb13_raw[61].x)
#define cb13_009z (cb13_raw[9].z)
#define cb13_009w (cb13_raw[9].w)
#define cb13_016z (cb13_raw[16].z)
#define cb13_016w (cb13_raw[16].w)
#define cb13_061y (cb13_raw[61].y)
#define cb13_062x (cb13_raw[62].x)
#define cb13_001x (cb13_raw[1].x)
#define cb13_001z (cb13_raw[1].z)

cbuffer cb9 : register(b9) {
  float4 cb9_raw[9] : packoffset(c0);
};

#define cb9_002z (cb9_raw[2].z)
#define cb9_000x (cb9_raw[0].x)
#define cb9_000y (cb9_raw[0].y)
#define cb9_002x (cb9_raw[2].x)
#define cb9_000z (cb9_raw[0].z)
#define cb9_002y (cb9_raw[2].y)
#define cb9_003y (cb9_raw[3].y)
#define cb9_004x (asint(cb9_raw[4].x))
#define cb9_003x (cb9_raw[3].x)
#define cb9_004y (asint(cb9_raw[4].y))
#define cb9_004z (asint(cb9_raw[4].z))
#define cb9_001x (cb9_raw[1].x)
#define cb9_001y (cb9_raw[1].y)
#define cb9_001z (cb9_raw[1].z)
#define cb9_003z (cb9_raw[3].z)
#define cb9_005x (asint(cb9_raw[5].x))
#define cb9_005y (asint(cb9_raw[5].y))
#define cb9_005z (asint(cb9_raw[5].z))

cbuffer cb0 : register(b0) {
  float cb0_000x : packoffset(c000.x);
  float cb0_000y : packoffset(c000.y);
  float cb0_000z : packoffset(c000.z);
  float cb0_000w : packoffset(c000.w);
  float cb0_001x : packoffset(c001.x);
  float cb0_001y : packoffset(c001.y);
  float cb0_001z : packoffset(c001.z);
  float cb0_002x : packoffset(c002.x);
  float cb0_002y : packoffset(c002.y);
  float cb0_002z : packoffset(c002.z);
  float cb0_003x : packoffset(c003.x);
  float cb0_003y : packoffset(c003.y);
  float cb0_003z : packoffset(c003.z);
  float cb0_003w : packoffset(c003.w);
  float cb0_004x : packoffset(c004.x);
  float cb0_004y : packoffset(c004.y);
  float cb0_004z : packoffset(c004.z);
  float cb0_004w : packoffset(c004.w);
  float cb0_005x : packoffset(c005.x);
  uint cb0_padding : packoffset(c7.x);
};

SamplerState s14 : register(s14);

SamplerComparisonState s9 : register(s9);

SamplerState s10 : register(s10);

SamplerState s7 : register(s7);

[numthreads(1, 32, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  float _37[4];
  float _38[4];
  bool _41 = (currentGridData_000 == 0);
  float _175;
  float _176;
  float _177;
  int _178;
  int _179;
  int _180;
  int _232;
  int _233;
  float _300;
  float _392;
  float _393;
  float _394;
  float _459;
  float _464;
  float _465;
  float _466;
  int _513;
  int _551;
  int _595;
  int _596;
  float _600;
  float _601;
  float _602;
  int _603;
  float _680;
  float _789;
  float _790;
  float _791;
  float _792;
  float _883;
  float _884;
  float _885;
  float _886;
  float _891;
  float _892;
  float _893;
  float _894;
  int _895;
  float _938;
  int _951;
  int _952;
  float _991;
  float _992;
  float _993;
  float _998;
  float _999;
  float _1000;
  float _1002;
  float _1003;
  float _1004;
  float _1005;
  float _1020;
  float _1078;
  float _1079;
  float _1080;
  float _1085;
  float _1086;
  float _1087;
  float _1528;
  float _1529;
  float _1530;
  float _1531;
  float _1532;
  int _1533;
  float _1638;
  float _1639;
  float _1694;
  float _1695;
  float _1746;
  float _1760;
  float _1761;
  float _1762;
  float _1763;
  float _1764;
  float _1790;
  float _1791;
  float _1792;
  float _1793;
  float _1796;
  float _1797;
  float _1798;
  float _1800;
  float _1801;
  float _1802;
  int _1803;
  int _1804;
  float _1805;
  float _1881;
  float _1882;
  float _1883;
  float _1884;
  float _1885;
  int _1886;
  float _1999;
  float _2000;
  float _2051;
  float _2052;
  float _2103;
  float _2117;
  float _2118;
  float _2119;
  float _2120;
  float _2121;
  float _2147;
  float _2148;
  float _2149;
  float _2150;
  float _2154;
  float _2155;
  float _2156;
  int _2157;
  float _2158;
  float _2159;
  int _2160;
  float _2161;
  float _2162;
  float _2163;
  float _2209;
  float _2210;
  float _2249;
  float _2250;
  float _2251;
  float _2252;
  float _2271;
  float _2272;
  float _2273;
  int _2304;
  float _2365;
  float _2591;
  float _2678;
  int _2679;
  int _2680;
  float _2744;
  float _2745;
  float _2746;
  float _2747;
  float _2748;
  int _2749;
  float _2854;
  float _2855;
  float _2910;
  float _2911;
  float _2943;
  float _2955;
  float _2956;
  float _2957;
  float _2958;
  float _2959;
  float _2973;
  float _2974;
  float _2975;
  float _2976;
  float _2979;
  float _2980;
  float _2981;
  float _2984;
  float _2985;
  float _2986;
  int _2987;
  int _2988;
  float _2989;
  float _3055;
  float _3056;
  float _3057;
  float _3058;
  float _3059;
  int _3060;
  float _3173;
  float _3174;
  float _3225;
  float _3226;
  float _3258;
  float _3270;
  float _3271;
  float _3272;
  float _3273;
  float _3274;
  float _3288;
  float _3289;
  float _3290;
  float _3291;
  float _3295;
  float _3296;
  float _3297;
  int _3298;
  float _3299;
  float _3300;
  int _3301;
  float _3302;
  float _3303;
  float _3304;
  float _3336;
  float _3337;
  float _3338;
  float _3339;
  float _3356;
  float _3359;
  if (_41) {
    int _48 = cb7_005x * cb7_004w;
    float _49 = float((int)(_48));
    int _50 = cb7_004w * (int)(SV_DispatchThreadID.y);
    int _51 = _50 + cb7_004z;
    float _52 = float((int)(_51));
    float _53 = _52 * 0.6180340051651001f;
    float _54 = frac(_53);
    float _55 = _54 * 6.2831854820251465f;
    float _56 = _52 * 2.0f;
    float _57 = _56 + 1.0f;
    float _58 = 1.0f / _49;
    float _59 = _57 * _58;
    float _60 = 1.0f - _59;
    float _61 = _60 * _60;
    float _62 = 1.0f - _61;
    float _63 = saturate(_62);
    float _64 = sqrt(_63);
    float _65 = cos(_55);
    float _66 = _65 * _64;
    float _67 = sin(_55);
    float _68 = _67 * _64;
    float _69 = dot(float3(_66, _68, _60), float3(_66, _68, _60));
    float _70 = rsqrt(_69);
    float _71 = _70 * _66;
    float _72 = _70 * _68;
    float _73 = _70 * _60;
    int _74 = cb7_005x * (int)(SV_DispatchThreadID.x);
    int _75 = _74 + (int)(SV_DispatchThreadID.y);
    int _76 = _75 & 1431655765;
    int _77 = (uint)(_76) >> 1;
    int _78 = _77 | _76;
    int _79 = _78 & 858993459;
    int _80 = (uint)(_79) >> 2;
    int _81 = _80 | _79;
    int _82 = _81 & 252645135;
    int _83 = (uint)(_82) >> 4;
    int _84 = _83 | _82;
    int _85 = (uint)(_84) >> 8;
    int _86 = _85 & 65280;
    int _87 = _84 & 255;
    int _88 = _86 | _87;
    int _89 = (uint)(_75) >> 1;
    int _90 = _89 & 1431655765;
    int _91 = (uint)(_90) >> 1;
    int _92 = _91 | _90;
    int _93 = _92 & 858993459;
    int _94 = (uint)(_93) >> 2;
    int _95 = _94 | _93;
    int _96 = _95 & 252645135;
    int _97 = (uint)(_96) >> 4;
    int _98 = _97 | _96;
    int _99 = (uint)(_98) >> 8;
    int _100 = _99 & 65280;
    int _101 = _98 & 255;
    int _102 = _100 | _101;
    int _103 = (int)(SV_DispatchThreadID.x) & 1;
    bool _104 = (_103 == 0);
    if (_104) {
      int _107 = (uint)(SV_DispatchThreadID.x) >> 1;
      int _109 = t5[_107].x;
      _175 = _71;
      _176 = _72;
      _177 = _73;
      _178 = _88;
      _179 = _102;
      _180 = _109;
    } else {
      uint _111 = SV_DispatchThreadID.x + -1u;
      int _112 = (uint)(_111) >> 1;
      int _114 = t5[_112].y;
      _175 = _71;
      _176 = _72;
      _177 = _73;
      _178 = _88;
      _179 = _102;
      _180 = _114;
    }
  } else {
    int _118 = t6[(int)(SV_DispatchThreadID.y)].x;
    int _119 = t6[(int)(SV_DispatchThreadID.y)].y;
    uint _120 = currentGridData_000 * 18;
    uint _121 = _120 + 5u;
    float _124 = float((int)(asint(cb7_raw[_121].x)));
    float _125 = float((int)(_119));
    float _126 = _125 * 0.6180340051651001f;
    float _127 = frac(_126);
    float _128 = _127 * 6.2831854820251465f;
    float _129 = _125 * 2.0f;
    float _130 = _129 + 1.0f;
    float _131 = 1.0f / _124;
    float _132 = _130 * _131;
    float _133 = 1.0f - _132;
    float _134 = _133 * _133;
    float _135 = 1.0f - _134;
    float _136 = saturate(_135);
    float _137 = sqrt(_136);
    float _138 = cos(_128);
    float _139 = _138 * _137;
    float _140 = sin(_128);
    float _141 = _140 * _137;
    float _142 = dot(float3(_139, _141, _133), float3(_139, _141, _133));
    float _143 = rsqrt(_142);
    float _144 = _143 * _139;
    float _145 = _143 * _141;
    float _146 = _143 * _133;
    int _147 = (int)(SV_DispatchThreadID.y) & 1431655765;
    int _148 = (uint)(_147) >> 1;
    int _149 = _148 | _147;
    int _150 = _149 & 858993459;
    int _151 = (uint)(_150) >> 2;
    int _152 = _151 | _150;
    int _153 = _152 & 252645135;
    int _154 = (uint)(_153) >> 4;
    int _155 = _154 | _153;
    int _156 = (uint)(_155) >> 8;
    int _157 = _156 & 65280;
    int _158 = _155 & 255;
    int _159 = _157 | _158;
    int _160 = (uint)(SV_DispatchThreadID.y) >> 1;
    int _161 = _160 & 1431655765;
    int _162 = (uint)(_161) >> 1;
    int _163 = _162 | _161;
    int _164 = _163 & 858993459;
    int _165 = (uint)(_164) >> 2;
    int _166 = _165 | _164;
    int _167 = _166 & 252645135;
    int _168 = (uint)(_167) >> 4;
    int _169 = _168 | _167;
    int _170 = (uint)(_169) >> 8;
    int _171 = _170 & 65280;
    int _172 = _169 & 255;
    int _173 = _171 | _172;
    _175 = _144;
    _176 = _145;
    _177 = _146;
    _178 = _159;
    _179 = _173;
    _180 = _118;
  }
  float4 _182 = t2.Load(int3(_178, _179, 0));
  bool _184 = (_182.x < 0.0f);
  if (_184) {
    u4[int2(_178, _179)] = float4(0.0f, 0.0f, 0.0f, 1.0f);
  } else {
    float4 _189 = t1.Load(int3(_178, _179, 0));
    float _193 = dot(float3(_189.x, _189.y, _189.z), float3(_189.x, _189.y, _189.z));
    float _194 = rsqrt(_193);
    float _195 = _194 * _189.x;
    float _196 = _194 * _189.y;
    float _197 = _194 * _189.z;
    uint _198 = currentGridData_000 * 18;
    uint _199 = _198 + 2u;
    int _203 = _180 / asint(cb7_raw[_199].z);
    int _204 = _203 % asint(cb7_raw[_199].x);
    int _205 = _203 / asint(cb7_raw[_199].x);
    int _206 = _180 % asint(cb7_raw[_199].z);
    uint _207 = _198 + 7u;
    uint _213 = (uint)(asint(cb7_raw[_207].x)) + _204;
    uint _214 = (uint)(asint(cb7_raw[_207].y)) + _205;
    uint _215 = (uint)(asint(cb7_raw[_207].z)) + _206;
    int _216 = _213 % asint(cb7_raw[_199].x);
    int _217 = _214 % asint(cb7_raw[_199].y);
    int _218 = _215 % asint(cb7_raw[_199].z);
    bool _221 = (currentGridData_000 == 0);
    if (_221) {
      uint _224 = t38.Load(int4(_204, _205, _206, 0));
      int _226 = _224.x & 511;
      int _227 = (uint)((uint)(_224.x)) >> 9;
      _232 = _226;
      _233 = _227;
    } else {
      int _229 = _204 * asint(cb7_raw[_199].z);
      int _230 = _206 + _229;
      _232 = _230;
      _233 = _205;
    }
    uint _234 = (uint)(currentGridData_000) + 34u;
    float4 _237 = t34[(_234 - 34)].Load(int3(_232, _233, 0));
    float _241 = _237.x * 0.44999998807907104f;
    float _242 = _237.y * 0.44999998807907104f;
    float _243 = _237.z * 0.44999998807907104f;
    float _244 = float((int)(_216));
    float _245 = float((int)(_217));
    float _246 = float((int)(_218));
    uint _247 = _198 + 10u;
    float _252 = _244 - (cb7_raw[_247].x);
    float _253 = _245 - (cb7_raw[_247].y);
    float _254 = _246 - (cb7_raw[_247].z);
    float _259 = _252 + _241;
    float _260 = _253 + _242;
    float _261 = _254 + _243;
    int _262 = _198 | 1;
    float _267 = _259 * (cb7_raw[_262].x);
    float _268 = _260 * (cb7_raw[_262].y);
    float _269 = _261 * (cb7_raw[_262].z);
    float _270 = _182.x * 0.9998999834060669f;
    float _271 = _270 * _175;
    float _272 = _270 * _176;
    float _273 = _270 * _177;
    float _274 = (cb7_raw[_198].x) + _271;
    float _275 = _274 + _267;
    float _276 = (cb7_raw[_198].y) + _272;
    float _277 = _276 + _268;
    float _278 = (cb7_raw[_198].z) + _273;
    float _279 = _278 + _269;
    bool _281 = (_182.x > (cb7_raw[_262].w));
    if (_281) {
      float4 _284 = t39.Load(int3(_178, _179, 0));
      bool _286 = (_284.w < 1.0f);
      float _287 = _177 + 1.0f;
      float _288 = dot(float3(_175, _176, _287), float3(_175, _176, _287));
      float _289 = rsqrt(_288);
      float _290 = _289 * _175;
      float _291 = _289 * _176;
      float _292 = _289 * _287;
      if (_286) {
        _300 = cb0_004x;
      } else {
        _300 = cb0_003w;
      }
      float _301 = _175 - _176;
      float _302 = _289 * _301;
      float _303 = abs(_302);
      float _304 = _176 + _175;
      float _305 = _289 * _304;
      float _306 = abs(_305);
      float _307 = _306 + _303;
      float _308 = _307 * 0.5f;
      float _309 = abs(_292);
      float _310 = _308 + _309;
      float _311 = _290 / _310;
      float _312 = _291 / _310;
      float _313 = _311 * 0.5f;
      float _314 = _312 * 0.5f;
      float _315 = _313 + 0.5f;
      float _316 = 0.5f - _314;
      float4 _319 = t3.SampleLevel(s10, float2(_315, _316), 0.0f);
      float _339 = _290 * _290;
      float _340 = _291 * _291;
      float _341 = _339 + _340;
      float _342 = sqrt(_341);
      float _343 = _342 * 0.5f;
      float _344 = 1.0f - _292;
      float _345 = 1.0f / _344;
      float _346 = max(_345, -3.4028234663852886e+38f);
      float _347 = min(_346, 3.4028234663852886e+38f);
      float _348 = _343 * _347;
      float _349 = saturate(_348);
      float _350 = log2(_349);
      float _351 = _350 * cb0_003x;
      float _352 = exp2(_351);
      float _353 = cb0_002x - cb0_001x;
      float _354 = cb0_002y - cb0_001y;
      float _355 = cb0_002z - cb0_001z;
      float _356 = _352 * _353;
      float _357 = _352 * _354;
      float _358 = _352 * _355;
      float _359 = cb0_001x - _319.x;
      float _360 = _359 + _356;
      float _361 = cb0_001y - _319.y;
      float _362 = _361 + _357;
      float _363 = cb0_001z - _319.z;
      float _364 = _363 + _358;
      float _365 = _360 * _300;
      float _366 = _362 * _300;
      float _367 = _364 * _300;
      float _368 = _365 + _319.x;
      float _369 = _366 + _319.y;
      float _370 = _367 + _319.z;
      float _371 = _368 * cb0_003z;
      float _372 = _369 * cb0_003z;
      float _373 = _370 * cb0_003z;
      float _374 = dot(float3(_371, _372, _373), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      float _375 = _371 - _374;
      float _376 = _372 - _374;
      float _377 = _373 - _374;
      float _378 = _375 * cb0_003y;
      float _379 = _376 * cb0_003y;
      float _380 = _377 * cb0_003y;
      float _381 = _378 + _374;
      float _382 = _379 + _374;
      float _383 = _380 + _374;
      float _384 = dot(float3(_381, _382, _383), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      bool _385 = (_384 > cb0_005x);
      if (_385) {
        float _387 = cb0_005x / _384;
        float _388 = _387 * _381;
        float _389 = _387 * _382;
        float _390 = _387 * _383;
        _392 = _388;
        _393 = _389;
        _394 = _390;
      } else {
        _392 = _381;
        _393 = _382;
        _394 = _383;
      }
      float _395 = _392 * cb0_000w * GRAPHICS_RAY_SKYLIGHT;
      float _396 = _393 * cb0_000w * GRAPHICS_RAY_SKYLIGHT;
      float _397 = _394 * cb0_000w * GRAPHICS_RAY_SKYLIGHT;
      u4[int2(_178, _179)] = float4(_395, _396, _397, 1.0f);
    } else {
      float4 _401 = t0.Load(int3(_178, _179, 0));
      float _405 = log2(_401.x);
      float _406 = log2(_401.y);
      float _407 = log2(_401.z);
      float _408 = _405 * 2.200000047683716f;
      float _409 = _406 * 2.200000047683716f;
      float _410 = _407 * 2.200000047683716f;
      float _411 = exp2(_408);
      float _412 = exp2(_409);
      float _413 = exp2(_410);
      float _417 = cb12_225z + 0.054999999701976776f;
      float _418 = _417 * 0.9478673338890076f;
      float _419 = abs(_418);
      float _420 = log2(_419);
      float _421 = _420 * 2.4000000953674316f;
      float _422 = exp2(_421);
      float _423 = cb12_225z * 0.07739938050508499f;
      bool _424 = (cb12_225z <= 0.040449999272823334f);
      float _425 = select(_424, _423, _422);
      float _426 = dot(float3(_411, _412, _413), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      bool _427 = !(_426 <= 0.0f);
      if (_427) {
        bool _429 = (_425 <= 0.0f);
        bool _430 = (_426 >= _425);
        bool _431 = _429 || _430;
        if (!_431) {
          float _433 = _426 / _425;
          float _434 = saturate(_433);
          float _435 = max(cb12_225y, 0.0f);
          float _436 = _435 + 1.0f;
          float _437 = 1.0f / _436;
          float _438 = log2(_434);
          float _439 = _438 * _437;
          float _440 = exp2(_439);
          float _441 = saturate(_434);
          float _442 = _441 * 2.0f;
          float _443 = 3.0f - _442;
          float _444 = _441 * _441;
          float _445 = _444 * _443;
          float _446 = 1.0f - _445;
          float _447 = _440 - _434;
          float _448 = _446 * _447;
          float _449 = _448 + _434;
          float _450 = _449 * _425;
          float _451 = _450 / _426;
          float _452 = max(_412, _413);
          float _453 = max(_411, _452);
          bool _454 = (_453 > 0.0f);
          if (_454) {
            float _456 = 1.0f / _453;
            float _457 = min(_451, _456);
            _459 = _457;
          } else {
            _459 = _451;
          }
          float _460 = _459 * _411;
          float _461 = _459 * _412;
          float _462 = _459 * _413;
          _464 = _460;
          _465 = _461;
          _466 = _462;
        } else {
          _464 = _411;
          _465 = _412;
          _466 = _413;
        }
      } else {
        _464 = 0.0f;
        _465 = 0.0f;
        _466 = 0.0f;
      }
      float _467 = -0.0f - _271;
      float _468 = -0.0f - _272;
      float _469 = -0.0f - _273;
      float _470 = dot(float3(_467, _468, _469), float3(_467, _468, _469));
      float _471 = rsqrt(_470);
      float _472 = _471 * _467;
      float _473 = _471 * _468;
      float _474 = _471 * _469;
      // GRAPHICS HIT BEGIN
      uint2 graphics_packed = 0;
      bool graphics_hit = false;
      float4 graphics_material = 0.f;
      float3 graphics_specular = 0.f;
      if (graphics_injection.layout_version == 1.f && graphics_injection.graphics_mode != 0.f && graphics_injection.pbr_mode != 0.f) {
        graphics_hit = GraphicsReadHitMaterial(graphics_hit_material, graphics_hit_context,
            uint2(_178, _179), _182.x, graphics_packed) && (graphics_packed.y & (1u << 17u)) == 0;
        if (graphics_hit) {
          graphics_material = GraphicsDecodeHitMaterial(graphics_packed);
          graphics_material.w = GraphicsHitRoughness(graphics_hit_material, graphics_material.w, graphics_packed.y);
          graphics_hit = isfinite(graphics_material.w);
          graphics_material.w = clamp(graphics_material.w, .045f, 1.f);
        }
      }
      // GRAPHICS HIT END
      float _481 = _275 - cb9_000x;
      float _482 = _277 - cb9_000y;
      float _483 = _279 - cb9_000z;
      float _488 = _481 / cb9_002x;
      float _489 = _482 / cb9_002y;
      float _490 = _483 / cb9_002z;
      float _491 = floor(_488);
      float _492 = floor(_489);
      float _493 = floor(_490);
      int _494 = int(_491);
      int _495 = int(_492);
      int _496 = int(_493);
      int _497 = _495 | _494;
      int _498 = _497 | _496;
      bool _499 = ((int)_498 > (int)-1);
      if (_499) {
        bool _505 = ((int)_494 < (int)cb9_004x);
        bool _506 = ((int)_495 < (int)cb9_004y);
        bool _507 = ((int)_496 < (int)cb9_004z);
        bool _508 = _505 && _506;
        bool _509 = _507 && _508;
        bool _510 = !_509;
        int _511 = int((bool)_510);
        _513 = _511;
      } else {
        _513 = -1;
      }
      float _518 = _275 - cb9_001x;
      float _519 = _277 - cb9_001y;
      float _520 = _279 - cb9_001z;
      float _525 = _518 / cb9_003x;
      float _526 = _519 / cb9_003y;
      float _527 = _520 / cb9_003z;
      float _528 = floor(_525);
      float _529 = floor(_526);
      float _530 = floor(_527);
      int _531 = int(_528);
      int _532 = int(_529);
      int _533 = int(_530);
      bool _534 = (_513 == -1);
      if (_534) {
        int _536 = _532 | _531;
        int _537 = _536 | _533;
        bool _538 = ((int)_537 > (int)-1);
        if (_538) {
          bool _544 = ((int)_531 < (int)cb9_005x);
          bool _545 = ((int)_532 < (int)cb9_005y);
          bool _546 = ((int)_533 < (int)cb9_005z);
          bool _547 = _544 && _545;
          bool _548 = _546 && _547;
          int _549 = select(_548, 1, -1);
          _551 = _549;
        } else {
          _551 = -1;
        }
      } else {
        _551 = _513;
      }
      bool _554 = (_551 == -1);
      if (!_554) {
        float _560 = _275 - (cb9_raw[_551].x);
        float _561 = _277 - (cb9_raw[_551].y);
        float _562 = _279 - (cb9_raw[_551].z);
        int _563 = _551 + 2;
        float _568 = _560 / (cb9_raw[_563].x);
        float _569 = _561 / (cb9_raw[_563].y);
        float _570 = _562 / (cb9_raw[_563].z);
        float _571 = floor(_568);
        float _572 = floor(_569);
        float _573 = floor(_570);
        int _574 = int(_571);
        int _575 = int(_572);
        int _576 = int(_573);
        int _577 = _551 + 4;
        int _580 = asint(cb9_raw[_577].y) * _576;
        int _581 = _580 + _575;
        int _583 = _581 * asint(cb9_raw[_577].x);
        int _584 = _551 + 6;
        uint _587 = (uint)(asint(cb9_raw[_584].x)) + _574;
        uint _588 = _587 + _583;
        int _591 = t25[_588].range_000;
        int _593 = t25[_588].range_004;
        _595 = _593;
        _596 = _591;
      } else {
        _595 = cb13_067y;
        _596 = 1;
      }
      bool _597 = ((uint)_596 < (uint)_595);
      if (_597) {
        _600 = 0.0f;
        _601 = 0.0f;
        _602 = 0.0f;
        _603 = _596;
        while(true) {
          int _606 = t26[_603].light_000;
          float _609 = t16[_606].LightParams_048.w;
          int _610 = asint(_609);
          bool _611 = ((int)_610 < (int)0);
          if (!_611) {
            float _614 = t16[_606].LightParams_000.x;
            float _615 = t16[_606].LightParams_000.y;
            float _616 = t16[_606].LightParams_000.z;
            float _617 = _614 - _275;
            float _618 = _615 - _277;
            float _619 = _616 - _279;
            float _622 = _617 * _617;
            float _623 = _618 * _618;
            float _624 = _622 + _623;
            float _625 = _619 * _619;
            float _626 = _624 + _625;
            float _627 = sqrt(_626);
            float _628 = _627 * _627;
            float _630 = t16[_606].LightParams_080.x;
            float _631 = _628 * _630;
            float _632 = t16[_606].LightParams_000.w;
            float _633 = _627 / _632;
            float _634 = _633 * cb0_004z;
            float _635 = _634 * _634;
            float _636 = _635 * _635;
            float _637 = 1.0f - _636;
            float _638 = saturate(_637);
            float _639 = _638 * _638;
            int _640 = _610 & 1;
            bool _641 = (_640 != 0);
            float _642 = t16[_606].LightParams_080.z;
            bool _643 = (_642 > 0.0f);
            float _645 = t16[_606].LightParams_096.x;
            bool _646 = (_645 > 0.0f);
            float _648 = t16[_606].LightParams_144.x;
            int _649 = asint(_648);
            int _650 = _649 & 1;
            bool _651 = (_650 != 0);
            float _652 = _631 + 1.0f;
            float _653 = _639 / _652;
            if (_641) {
              float _656 = t16[_606].LightParams_032.x;
              float _657 = t16[_606].LightParams_032.y;
              float _658 = t16[_606].LightParams_032.z;
              float _659 = dot(float3(_617, _618, _619), float3(_617, _618, _619));
              float _660 = rsqrt(_659);
              float _661 = _617 * _660;
              float _662 = -0.0f - _661;
              float _663 = _618 * _660;
              float _664 = -0.0f - _663;
              float _665 = _619 * _660;
              float _666 = -0.0f - _665;
              float _667 = dot(float3(_662, _664, _666), float3(_656, _657, _658));
              float _669 = t16[_606].LightParams_064.w;
              float _670 = t16[_606].LightParams_064.y;
              float _671 = _670 * _667;
              float _672 = t16[_606].LightParams_064.z;
              float _673 = _671 + _672;
              float _674 = saturate(_673);
              float _675 = log2(_674);
              float _676 = _675 * _669;
              float _677 = exp2(_676);
              float _678 = _677 * _653;
              _680 = _678;
            } else {
              _680 = _653;
            }
            bool _681 = _643 || _651;
            bool _682 = (_680 > 0.0f);
            bool _683 = _681 && _682;
            if (_683) {
              float _685 = -0.0f - _617;
              float _686 = -0.0f - _618;
              float _687 = -0.0f - _619;
              if (_641) {
                float _690 = t16[_606].LightParams_032.x;
                float _691 = t16[_606].LightParams_032.y;
                float _692 = t16[_606].LightParams_032.z;
                float _694 = t16[_606].LightParams_112.y;
                float _695 = t16[_606].LightParams_112.z;
                float _696 = t16[_606].LightParams_112.w;
                float _697 = _696 * _691;
                float _698 = _695 * _692;
                float _699 = _697 - _698;
                float _700 = _694 * _692;
                float _701 = _696 * _690;
                float _702 = _700 - _701;
                float _703 = _695 * _690;
                float _704 = _694 * _691;
                float _705 = _703 - _704;
                float _706 = _699 * _685;
                float _707 = mad(_702, _686, _706);
                float _708 = mad(_705, _687, _707);
                float _709 = _694 * _685;
                float _710 = mad(_695, _686, _709);
                float _711 = mad(_696, _687, _710);
                float _712 = _690 * _685;
                float _713 = mad(_691, _686, _712);
                float _714 = mad(_692, _687, _713);
                float _715 = t16[_606].LightParams_112.x;
                float _717 = t16[_606].LightParams_144.z;
                int _718 = asint(_717);
                _891 = _708;
                _892 = _711;
                _893 = _714;
                _894 = _715;
                _895 = _718;
              } else {
                if (_651) {
                  float _722 = t16[_606].LightParams_064.y;
                  float _723 = t16[_606].LightParams_064.z;
                  float _724 = t16[_606].LightParams_064.w;
                  float _726 = t16[_606].LightParams_032.x;
                  float _727 = t16[_606].LightParams_032.y;
                  float _728 = t16[_606].LightParams_032.z;
                  float _729 = _727 * _724;
                  float _730 = _728 * _723;
                  float _731 = _729 - _730;
                  float _732 = _728 * _722;
                  float _733 = _726 * _724;
                  float _734 = _732 - _733;
                  float _735 = _726 * _723;
                  float _736 = _727 * _722;
                  float _737 = _735 - _736;
                  float _738 = _731 * _685;
                  float _739 = mad(_734, _686, _738);
                  float _740 = mad(_737, _687, _739);
                  float _741 = _726 * _685;
                  float _742 = mad(_727, _686, _741);
                  float _743 = mad(_728, _687, _742);
                  float _744 = _722 * _685;
                  float _745 = mad(_723, _686, _744);
                  float _746 = mad(_724, _687, _745);
                  float _747 = -0.0f - _740;
                  float _748 = -0.0f - _743;
                  float _749 = -0.0f - _746;
                  float _750 = _747 / _627;
                  float _751 = _748 / _627;
                  float _752 = _749 / _627;
                  float _753 = abs(_750);
                  float _754 = abs(_751);
                  float _755 = abs(_752);
                  int _756 = _649 & 4;
                  bool _757 = (_756 == 0);
                  float _758 = max(_754, _755);
                  bool _759 = (_753 > _758);
                  if (!_757) {
                    if (_759) {
                      bool _762 = (_750 > 0.0f);
                      if (_762) {
                        float _765 = t16[_606].LightParams_112.x;
                        _789 = _743;
                        _790 = _746;
                        _791 = _747;
                        _792 = _765;
                      } else {
                        float _768 = t16[_606].LightParams_112.y;
                        _789 = _748;
                        _790 = _746;
                        _791 = _740;
                        _792 = _768;
                      }
                    } else {
                      float _770 = max(_753, _755);
                      bool _771 = (_754 > _770);
                      if (_771) {
                        bool _773 = (_751 > 0.0f);
                        if (_773) {
                          float _776 = t16[_606].LightParams_112.z;
                          _789 = _747;
                          _790 = _746;
                          _791 = _748;
                          _792 = _776;
                        } else {
                          float _779 = t16[_606].LightParams_112.w;
                          _789 = _740;
                          _790 = _746;
                          _791 = _743;
                          _792 = _779;
                        }
                      } else {
                        bool _781 = (_752 > 0.0f);
                        if (_781) {
                          float _784 = t16[_606].LightParams_128.x;
                          _789 = _740;
                          _790 = _743;
                          _791 = _749;
                          _792 = _784;
                        } else {
                          float _787 = t16[_606].LightParams_128.y;
                          _789 = _740;
                          _790 = _748;
                          _791 = _746;
                          _792 = _787;
                        }
                      }
                    }
                    float _794 = t16[_606].LightParams_144.z;
                    int _795 = asint(_794);
                    _891 = _789;
                    _892 = _790;
                    _893 = _791;
                    _894 = _792;
                    _895 = _795;
                  } else {
                    if (_759) {
                      bool _798 = (_750 > 0.0f);
                      if (_798) {
                        float _801 = t16[_606].LightParams_112.x;
                        float _803 = t16[_606].LightParams_144.z;
                        int _804 = asint(_803);
                        _891 = _743;
                        _892 = _746;
                        _893 = _747;
                        _894 = _801;
                        _895 = _804;
                      } else {
                        float _807 = t16[_606].LightParams_112.y;
                        float _809 = t16[_606].LightParams_144.z;
                        int _810 = asint(_809);
                        int _811 = (uint)(_810) >> 10;
                        _891 = _748;
                        _892 = _746;
                        _893 = _740;
                        _894 = _807;
                        _895 = _811;
                      }
                    } else {
                      float _813 = max(_753, _755);
                      bool _814 = (_754 > _813);
                      if (_814) {
                        bool _816 = (_751 > 0.0f);
                        if (_816) {
                          float _819 = t16[_606].LightParams_112.z;
                          float _821 = t16[_606].LightParams_144.z;
                          int _822 = asint(_821);
                          int _823 = (uint)(_822) >> 20;
                          _891 = _747;
                          _892 = _746;
                          _893 = _748;
                          _894 = _819;
                          _895 = _823;
                        } else {
                          float _826 = t16[_606].LightParams_112.w;
                          float _828 = t16[_606].LightParams_144.w;
                          int _829 = asint(_828);
                          _891 = _740;
                          _892 = _746;
                          _893 = _743;
                          _894 = _826;
                          _895 = _829;
                        }
                      } else {
                        bool _831 = (_752 > 0.0f);
                        if (_831) {
                          float _834 = t16[_606].LightParams_128.x;
                          float _836 = t16[_606].LightParams_144.w;
                          int _837 = asint(_836);
                          int _838 = (uint)(_837) >> 10;
                          _891 = _740;
                          _892 = _743;
                          _893 = _749;
                          _894 = _834;
                          _895 = _838;
                        } else {
                          float _841 = t16[_606].LightParams_128.y;
                          float _843 = t16[_606].LightParams_144.w;
                          int _844 = asint(_843);
                          int _845 = (uint)(_844) >> 20;
                          _891 = _740;
                          _892 = _748;
                          _893 = _746;
                          _894 = _841;
                          _895 = _845;
                        }
                      }
                    }
                  }
                } else {
                  float _847 = _617 / _627;
                  float _848 = _618 / _627;
                  float _849 = _619 / _627;
                  float _850 = abs(_847);
                  float _851 = abs(_848);
                  float _852 = abs(_849);
                  float _853 = max(_851, _852);
                  bool _854 = (_850 > _853);
                  if (_854) {
                    bool _856 = (_847 > 0.0f);
                    if (_856) {
                      float _859 = t16[_606].LightParams_112.x;
                      _883 = _686;
                      _884 = _687;
                      _885 = _617;
                      _886 = _859;
                    } else {
                      float _862 = t16[_606].LightParams_112.y;
                      _883 = _618;
                      _884 = _687;
                      _885 = _685;
                      _886 = _862;
                    }
                  } else {
                    float _864 = max(_850, _852);
                    bool _865 = (_851 > _864);
                    if (_865) {
                      bool _867 = (_848 > 0.0f);
                      if (_867) {
                        float _870 = t16[_606].LightParams_112.z;
                        _883 = _617;
                        _884 = _687;
                        _885 = _618;
                        _886 = _870;
                      } else {
                        float _873 = t16[_606].LightParams_112.w;
                        _883 = _685;
                        _884 = _687;
                        _885 = _686;
                        _886 = _873;
                      }
                    } else {
                      bool _875 = (_849 > 0.0f);
                      if (_875) {
                        float _878 = t16[_606].LightParams_128.x;
                        _883 = _685;
                        _884 = _686;
                        _885 = _619;
                        _886 = _878;
                      } else {
                        float _881 = t16[_606].LightParams_128.y;
                        _883 = _685;
                        _884 = _618;
                        _885 = _687;
                        _886 = _881;
                      }
                    }
                  }
                  float _888 = t16[_606].LightParams_144.z;
                  int _889 = asint(_888);
                  _891 = _883;
                  _892 = _884;
                  _893 = _885;
                  _894 = _886;
                  _895 = _889;
                }
              }
              float _896 = t16[_606].LightParams_080.y;
              float _897 = _891 * _896;
              float _898 = mad(_896, _892, 0.0f);
              float _899 = _897 / _893;
              float _900 = _898 / _893;
              float _901 = _899 * 0.5f;
              float _902 = _900 * 0.5f;
              float _903 = _901 + 0.5f;
              float _904 = 0.5f - _902;
              if (_643) {
                int _906 = asint(_894);
                int _907 = (uint)(_906) >> 18;
                int _908 = _907 & 4092;
                float _909 = float((uint)_908);
                bool _910 = (_908 == 0);
                [branch]
                if (!_910) {
                  int _912 = (uint)(_906) >> 30;
                  float _913 = float((uint)_912);
                  int _914 = (uint)(_906) >> 8;
                  int _915 = _914 & 4092;
                  float _916 = float((uint)_915);
                  uint _917 = _906 << 2u;
                  int _918 = _917 & 4092;
                  float _919 = float((uint)_918);
                  float _920 = _903 * _909;
                  float _921 = _904 * _909;
                  float _922 = _920 + _919;
                  float _923 = _921 + _916;
                  float _926 = cb13_067x * _922;
                  float _927 = cb13_067x * _923;
                  float _930 = t9.SampleLevel(s10, float3(_926, _927, _913), 0.0f);
                  float _932 = _633 * 0.9900000095367432f;
                  float _933 = _930.x - _932;
                  float _934 = _933 * 144.26950073242188f;
                  float _935 = exp2(_934);
                  float _936 = saturate(_935);
                  _938 = _936;
                } else {
                  _938 = 1.0f;
                }
              } else {
                _938 = 1.0f;
              }
              if (_651) {
                int _940 = _649 & 2;
                bool _941 = (_940 != 0);
                int _942 = _649 & 8;
                bool _943 = (_942 == 0);
                if (_941) {
                  int _945 = _895 & 1023;
                  _951 = _945;
                  _952 = 0;
                } else {
                  int _947 = _895 & 255;
                  int _948 = (uint)(_895) >> 8;
                  int _949 = _948 & 3;
                  _951 = _947;
                  _952 = _949;
                }
                float _953 = float((uint)_951);
                float _955 = t16[_606].LightParams_144.y;
                float _956 = floor(_955);
                float _957 = _956 + _953;
                float4 _961 = t42.SampleLevel(s10, float3(_903, _904, _957), 0.0f);
                _38[0] = _961.x;
                _38[1] = _961.y;
                _38[2] = _961.z;
                _38[3] = _961.w;
                if (!_943) {
                  float _971 = _957 + 1.0f;
                  float4 _972 = t42.SampleLevel(s10, float3(_903, _904, _971), 0.0f);
                  float _977 = frac(_955);
                  float _978 = _972.x - _961.x;
                  float _979 = _972.y - _961.y;
                  float _980 = _972.z - _961.z;
                  float _981 = _972.w - _961.w;
                  float _982 = _978 * _977;
                  float _983 = _979 * _977;
                  float _984 = _980 * _977;
                  float _985 = _981 * _977;
                  float _986 = _982 + _961.x;
                  float _987 = _983 + _961.y;
                  float _988 = _984 + _961.z;
                  float _989 = _985 + _961.w;
                  _38[0] = _986;
                  _38[1] = _987;
                  _38[2] = _988;
                  _38[3] = _989;
                  _991 = _988;
                  _992 = _987;
                  _993 = _986;
                } else {
                  _991 = _961.z;
                  _992 = _961.y;
                  _993 = _961.x;
                }
                if (!_941) {
                  float _996 = _38[_952];
                  _998 = _996;
                  _999 = _996;
                  _1000 = _996;
                } else {
                  _998 = _993;
                  _999 = _992;
                  _1000 = _991;
                }
                _1002 = _938;
                _1003 = _998;
                _1004 = _999;
                _1005 = _1000;
              } else {
                _1002 = _938;
                _1003 = 1.0f;
                _1004 = 1.0f;
                _1005 = 1.0f;
              }
            } else {
              _1002 = 1.0f;
              _1003 = 1.0f;
              _1004 = 1.0f;
              _1005 = 1.0f;
            }
            bool _1006 = _646 && _682;
            if (_1006) {
              float _1008 = t16[_606].LightParams_096.y;
              float _1011 = t10.SampleLevel(s10, float4(_617, _618, _619, _1008), 0.0f);
              float _1013 = _633 * 0.9900000095367432f;
              float _1014 = _1011.x - _1013;
              float _1015 = _1014 * 144.26950073242188f;
              float _1016 = exp2(_1015);
              float _1017 = saturate(_1016);
              float _1018 = _1017 * _1002;
              _1020 = _1018;
            } else {
              _1020 = _1002;
            }
            float _1021 = t16[_606].LightParams_080.w;
            float _1022 = _1020 + -1.0f;
            float _1023 = _1022 * _1021;
            float _1024 = _1023 + 1.0f;
            float _1025 = _1024 * _680;
            float _1026 = _1025 * _1003;
            float _1027 = _1025 * _1004;
            float _1028 = _1025 * _1005;
            bool _1029 = (_1026 > 0.0f);
            bool _1030 = (_1027 > 0.0f);
            bool _1031 = (_1028 > 0.0f);
            bool _1032 = _1029 || _1030;
            bool _1033 = _1031 || _1032;
            [branch]
            if (_1033) {
              float _1035 = dot(float3(_617, _618, _619), float3(_617, _618, _619));
              float _1036 = rsqrt(_1035);
              float _1037 = _1036 * _617;
              float _1038 = _1036 * _618;
              float _1039 = _1036 * _619;
              float _1040 = _1037 + _472;
              float _1041 = _1038 + _473;
              float _1042 = _1039 + _474;
              float _1043 = dot(float3(_1040, _1041, _1042), float3(_1040, _1041, _1042));
              float _1044 = rsqrt(_1043);
              float _1045 = _1040 * _1044;
              float _1046 = _1041 * _1044;
              float _1047 = _1042 * _1044;
              float _1048 = dot(float3(_1045, _1046, _1047), float3(_472, _473, _474));
              float _1049 = abs(_1048);
              float _1050 = 1.0f - _1049;
              float _1051 = saturate(_1050);
              float _1052 = _1051 * _1051;
              float _1055 = _1052 * _1052;
              float _1056 = _1055 * _1051;
              float _1057 = _1056 * cb13_066x;
              float _1059 = cb13_066z + 1.0f;
              float _1060 = _1057 / _1059;
              float _1061 = 1.0f - _1060;
              float _1062 = dot(float3(_195, _196, _197), float3(_1037, _1038, _1039));
              float _1063 = saturate(_1062);
              float _1064 = t16[_606].LightParams_048.x;
              float _1065 = t16[_606].LightParams_048.y;
              float _1066 = t16[_606].LightParams_048.z;
              float _1067 = _1063 * _1061;
              float _1068 = _1026 * _1064;
              float _1069 = _1068 * _1067;
              float _1070 = _1027 * _1065;
              float _1071 = _1070 * _1067;
              float _1072 = _1028 * _1066;
              float _1073 = _1072 * _1067;
              // GRAPHICS HIT BEGIN
              if (graphics_hit) {
                float3 diffuse, specular;
                GraphicsHitBRDF(float3(_195, _196, _197), float3(_472, _473, _474),
                    float3(_1037, _1038, _1039), graphics_material, diffuse, specular);
                _1069 = _1068 * diffuse.x;
                _1071 = _1070 * diffuse.y;
                _1073 = _1072 * diffuse.z;
                graphics_specular += cb0_000y * float3(_1068, _1070, _1072) * specular;
              }
              // GRAPHICS HIT END
              float _1074 = _1069 + _600;
              float _1075 = _1071 + _601;
              float _1076 = _1073 + _602;
              _1078 = _1074;
              _1079 = _1075;
              _1080 = _1076;
            } else {
              _1078 = _600;
              _1079 = _601;
              _1080 = _602;
            }
          } else {
            _1078 = _600;
            _1079 = _601;
            _1080 = _602;
          }
          uint _1081 = _603 + 1u;
          bool _1082 = (_1081 == _595);
          if (!_1082) {
            _600 = _1078;
            _601 = _1079;
            _602 = _1080;
            _603 = _1081;
            continue;
          }
          break;
        }
        _1085 = _1078;
        _1086 = _1079;
        _1087 = _1080;
      } else {
        _1085 = 0.0f;
        _1086 = 0.0f;
        _1087 = 0.0f;
      }
      float _1088 = _1085 * cb0_000y;
      float _1089 = _1086 * cb0_000y;
      float _1090 = _1087 * cb0_000y;
      uint _1093 = SV_DispatchThreadID.x << 8u;
      int _1094 = _1093 | (int)(SV_DispatchThreadID.x);
      int _1095 = _1094 & 16711935;
      int _1096 = _1095 << 4u;
      int _1097 = _1096 | _1095;
      int _1098 = _1097 & 252645135;
      int _1099 = _1098 << 2u;
      int _1100 = _1099 | _1098;
      int _1101 = _1100 & 858993459;
      int _1102 = _1101 << 1u;
      int _1103 = _1102 | _1101;
      int _1104 = _1103 & 1431655765;
      uint _1105 = SV_DispatchThreadID.y << 8u;
      int _1106 = _1105 | (int)(SV_DispatchThreadID.y);
      int _1107 = _1106 & 16711935;
      int _1108 = _1107 << 4u;
      int _1109 = _1108 | _1107;
      int _1110 = _1109 & 252645135;
      int _1111 = _1110 << 2u;
      int _1112 = _1111 | _1110;
      int _1113 = _1112 & 858993459;
      int _1114 = _1113 << 1u;
      int _1115 = _1114 | _1113;
      uint _1116 = _1115 << 1u;
      int _1117 = _1116 & -1431655766;
      int _1118 = _1117 | _1104;
      uint _1119 = (uint)(cb13_059x) << 4u;
      uint _1120 = _1119 + -1556008596u;
      uint _1121 = (uint)(cb13_059x) + -1640531527u;
      int _1122 = _1120 ^ _1121;
      int _1123 = (uint)((uint)(cb13_059x)) >> 5;
      int _1124 = _1123 + -939442524;
      int _1125 = _1122 ^ _1124;
      uint _1126 = _1125 + _1118;
      uint _1127 = _1126 << 4u;
      uint _1128 = _1127 + -1383041155u;
      uint _1129 = _1126 + -1640531527u;
      int _1130 = _1128 ^ _1129;
      int _1131 = (uint)(_1126) >> 5;
      uint _1132 = _1131 + 2123724318u;
      int _1133 = _1130 ^ _1132;
      uint _1134 = _1133 + (uint)(cb13_059x);
      uint _1135 = _1134 << 4u;
      uint _1136 = _1135 + -1556008596u;
      uint _1137 = _1134 + 1013904242u;
      int _1138 = _1136 ^ _1137;
      int _1139 = (uint)(_1134) >> 5;
      int _1140 = _1139 + -939442524;
      int _1141 = _1138 ^ _1140;
      uint _1142 = _1141 + _1126;
      uint _1143 = _1142 << 4u;
      uint _1144 = _1143 + -1383041155u;
      uint _1145 = _1142 + 1013904242u;
      int _1146 = _1144 ^ _1145;
      int _1147 = (uint)(_1142) >> 5;
      uint _1148 = _1147 + 2123724318u;
      int _1149 = _1146 ^ _1148;
      uint _1150 = _1149 + _1134;
      uint _1151 = _1150 << 4u;
      uint _1152 = _1151 + -1556008596u;
      uint _1153 = _1150 + -626627285u;
      int _1154 = _1152 ^ _1153;
      int _1155 = (uint)(_1150) >> 5;
      int _1156 = _1155 + -939442524;
      int _1157 = _1154 ^ _1156;
      uint _1158 = _1157 + _1142;
      uint _1159 = _1158 << 4u;
      uint _1160 = _1159 + -1383041155u;
      uint _1161 = _1158 + -626627285u;
      int _1162 = _1160 ^ _1161;
      int _1163 = (uint)(_1158) >> 5;
      uint _1164 = _1163 + 2123724318u;
      int _1165 = _1162 ^ _1164;
      uint _1166 = _1165 + _1150;
      uint _1167 = _1166 << 4u;
      uint _1168 = _1167 + -1556008596u;
      uint _1169 = _1166 + 2027808484u;
      int _1170 = _1168 ^ _1169;
      int _1171 = (uint)(_1166) >> 5;
      int _1172 = _1171 + -939442524;
      int _1173 = _1170 ^ _1172;
      uint _1174 = _1173 + _1158;
      uint _1175 = _1174 << 4u;
      uint _1176 = _1175 + -1383041155u;
      uint _1177 = _1174 + 2027808484u;
      int _1178 = _1176 ^ _1177;
      int _1179 = (uint)(_1174) >> 5;
      uint _1180 = _1179 + 2123724318u;
      int _1181 = _1178 ^ _1180;
      uint _1182 = _1181 + _1166;
      uint _1183 = _1182 << 4u;
      uint _1184 = _1183 + -1556008596u;
      uint _1185 = _1182 + 387276957u;
      int _1186 = _1184 ^ _1185;
      int _1187 = (uint)(_1182) >> 5;
      int _1188 = _1187 + -939442524;
      int _1189 = _1186 ^ _1188;
      uint _1190 = _1189 + _1174;
      uint _1191 = _1190 << 4u;
      uint _1192 = _1191 + -1383041155u;
      uint _1193 = _1190 + 387276957u;
      int _1194 = _1192 ^ _1193;
      int _1195 = (uint)(_1190) >> 5;
      uint _1196 = _1195 + 2123724318u;
      int _1197 = _1194 ^ _1196;
      uint _1198 = _1197 + _1182;
      uint _1199 = _1198 << 4u;
      uint _1200 = _1199 + -1556008596u;
      uint _1201 = _1198 + -1253254570u;
      int _1202 = _1200 ^ _1201;
      int _1203 = (uint)(_1198) >> 5;
      int _1204 = _1203 + -939442524;
      int _1205 = _1202 ^ _1204;
      uint _1206 = _1205 + _1190;
      uint _1207 = _1206 << 4u;
      uint _1208 = _1207 + -1383041155u;
      uint _1209 = _1206 + -1253254570u;
      int _1210 = _1208 ^ _1209;
      int _1211 = (uint)(_1206) >> 5;
      uint _1212 = _1211 + 2123724318u;
      int _1213 = _1210 ^ _1212;
      uint _1214 = _1213 + _1198;
      uint _1215 = _1214 << 4u;
      uint _1216 = _1215 + -1556008596u;
      uint _1217 = _1214 + 1401181199u;
      int _1218 = _1216 ^ _1217;
      int _1219 = (uint)(_1214) >> 5;
      int _1220 = _1219 + -939442524;
      int _1221 = _1218 ^ _1220;
      uint _1222 = _1221 + _1206;
      uint _1223 = _1222 << 4u;
      uint _1224 = _1223 + -1383041155u;
      uint _1225 = _1222 + 1401181199u;
      int _1226 = _1224 ^ _1225;
      int _1227 = (uint)(_1222) >> 5;
      uint _1228 = _1227 + 2123724318u;
      int _1229 = _1226 ^ _1228;
      uint _1230 = _1229 + _1214;
      uint _1231 = _1230 << 4u;
      uint _1232 = _1231 + -1556008596u;
      uint _1233 = _1230 + -239350328u;
      int _1234 = _1232 ^ _1233;
      int _1235 = (uint)(_1230) >> 5;
      int _1236 = _1235 + -939442524;
      int _1237 = _1234 ^ _1236;
      uint _1238 = _1237 + _1222;
      uint _1239 = _1238 << 4u;
      uint _1240 = _1239 + -1383041155u;
      uint _1241 = _1238 + -239350328u;
      int _1242 = _1240 ^ _1241;
      int _1243 = (uint)(_1238) >> 5;
      uint _1244 = _1243 + 2123724318u;
      int _1245 = _1242 ^ _1244;
      uint _1246 = _1245 + _1230;
      uint _1247 = _1246 << 4u;
      uint _1248 = _1247 + -1556008596u;
      uint _1249 = _1246 + -1879881855u;
      int _1250 = _1248 ^ _1249;
      int _1251 = (uint)(_1246) >> 5;
      int _1252 = _1251 + -939442524;
      int _1253 = _1250 ^ _1252;
      uint _1254 = _1253 + _1238;
      uint _1255 = _1254 << 4u;
      uint _1256 = _1255 + -1383041155u;
      uint _1257 = _1254 + -1879881855u;
      int _1258 = _1256 ^ _1257;
      int _1259 = (uint)(_1254) >> 5;
      uint _1260 = _1259 + 2123724318u;
      int _1261 = _1258 ^ _1260;
      uint _1262 = _1261 + _1246;
      uint _1263 = _1262 << 4u;
      uint _1264 = _1263 + -1556008596u;
      uint _1265 = _1262 + 774553914u;
      int _1266 = _1264 ^ _1265;
      int _1267 = (uint)(_1262) >> 5;
      int _1268 = _1267 + -939442524;
      int _1269 = _1266 ^ _1268;
      uint _1270 = _1269 + _1254;
      uint _1271 = _1270 << 4u;
      uint _1272 = _1271 + -1383041155u;
      uint _1273 = _1270 + 774553914u;
      int _1274 = _1272 ^ _1273;
      int _1275 = (uint)(_1270) >> 5;
      uint _1276 = _1275 + 2123724318u;
      int _1277 = _1274 ^ _1276;
      uint _1278 = _1277 + _1262;
      uint _1279 = _1278 << 4u;
      uint _1280 = _1279 + -1556008596u;
      uint _1281 = _1278 + -865977613u;
      int _1282 = _1280 ^ _1281;
      int _1283 = (uint)(_1278) >> 5;
      int _1284 = _1283 + -939442524;
      int _1285 = _1282 ^ _1284;
      uint _1286 = _1285 + _1270;
      uint _1287 = _1286 << 4u;
      uint _1288 = _1287 + -1383041155u;
      uint _1289 = _1286 + -865977613u;
      int _1290 = _1288 ^ _1289;
      int _1291 = (uint)(_1286) >> 5;
      uint _1292 = _1291 + 2123724318u;
      int _1293 = _1290 ^ _1292;
      uint _1294 = _1293 + _1278;
      uint _1295 = _1294 << 4u;
      uint _1296 = _1295 + -1556008596u;
      uint _1297 = _1294 + 1788458156u;
      int _1298 = _1296 ^ _1297;
      int _1299 = (uint)(_1294) >> 5;
      int _1300 = _1299 + -939442524;
      int _1301 = _1298 ^ _1300;
      uint _1302 = _1301 + _1286;
      uint _1303 = _1302 << 4u;
      uint _1304 = _1303 + -1383041155u;
      uint _1305 = _1302 + 1788458156u;
      int _1306 = _1304 ^ _1305;
      int _1307 = (uint)(_1302) >> 5;
      uint _1308 = _1307 + 2123724318u;
      int _1309 = _1306 ^ _1308;
      uint _1310 = _1309 + _1294;
      uint _1311 = _1310 << 4u;
      uint _1312 = _1311 + -1556008596u;
      uint _1313 = _1310 + 147926629u;
      int _1314 = _1312 ^ _1313;
      int _1315 = (uint)(_1310) >> 5;
      int _1316 = _1315 + -939442524;
      int _1317 = _1314 ^ _1316;
      uint _1318 = _1317 + _1302;
      uint _1319 = _1318 << 4u;
      uint _1320 = _1319 + -1383041155u;
      uint _1321 = _1318 + 147926629u;
      int _1322 = _1320 ^ _1321;
      int _1323 = (uint)(_1318) >> 5;
      uint _1324 = _1323 + 2123724318u;
      int _1325 = _1322 ^ _1324;
      uint _1326 = _1325 + _1310;
      uint _1327 = _1326 << 4u;
      uint _1328 = _1327 + -1556008596u;
      uint _1329 = _1326 + -1492604898u;
      int _1330 = _1328 ^ _1329;
      int _1331 = (uint)(_1326) >> 5;
      int _1332 = _1331 + -939442524;
      int _1333 = _1330 ^ _1332;
      uint _1334 = _1333 + _1318;
      uint _1335 = _1334 << 4u;
      uint _1336 = _1335 + -1383041155u;
      uint _1337 = _1334 + -1492604898u;
      int _1338 = _1336 ^ _1337;
      int _1339 = (uint)(_1334) >> 5;
      uint _1340 = _1339 + 2123724318u;
      int _1341 = _1338 ^ _1340;
      uint _1342 = _1341 + _1326;
      uint _1343 = _1342 << 4u;
      uint _1344 = _1343 + -1556008596u;
      uint _1345 = _1342 + 1161830871u;
      int _1346 = _1344 ^ _1345;
      int _1347 = (uint)(_1342) >> 5;
      int _1348 = _1347 + -939442524;
      int _1349 = _1346 ^ _1348;
      uint _1350 = _1349 + _1334;
      uint _1351 = _1350 << 4u;
      uint _1352 = _1351 + -1383041155u;
      uint _1353 = _1350 + 1161830871u;
      int _1354 = _1352 ^ _1353;
      int _1355 = (uint)(_1350) >> 5;
      uint _1356 = _1355 + 2123724318u;
      int _1357 = _1354 ^ _1356;
      uint _1358 = _1357 + _1342;
      uint _1359 = _1358 << 4u;
      uint _1360 = _1359 + -1556008596u;
      uint _1361 = _1358 + -478700656u;
      int _1362 = _1360 ^ _1361;
      int _1363 = (uint)(_1358) >> 5;
      int _1364 = _1363 + -939442524;
      int _1365 = _1362 ^ _1364;
      uint _1366 = _1365 + _1350;
      uint _1367 = _1366 << 13u;
      int _1368 = _1367 ^ _1366;
      int _1369 = (uint)(_1368) >> 17;
      int _1370 = _1369 ^ _1368;
      uint _1371 = _1370 << 5u;
      int _1372 = _1371 ^ _1370;
      int _1373 = (uint)(_1372) >> 9;
      int _1374 = _1373 | 1065353216;
      float _1375 = asfloat(_1374);
      float _1376 = 2.0f - _1375;
      bool _1380 = (cb12_074y > 0.0f);
      if (!_1380) {
        float _1386 = cb7_029x * _275;
        float _1387 = cb7_029y * _277;
        float _1388 = cb7_029z * _279;
        float _1393 = _1386 + cb7_031x;
        float _1394 = _1387 + cb7_031y;
        float _1395 = _1388 + cb7_031z;
        float _1396 = abs(_1393);
        float _1397 = abs(_1394);
        float _1398 = abs(_1395);
        float _1403 = cb7_032x * _1396;
        float _1404 = cb7_032y * _1397;
        float _1405 = cb7_032z * _1398;
        float _1407 = _1403 + cb7_032w;
        float _1408 = _1404 + cb7_032w;
        float _1409 = _1405 + cb7_032w;
        float _1410 = saturate(_1407);
        float _1411 = saturate(_1408);
        float _1412 = saturate(_1409);
        float _1413 = min(_1410, _1411);
        float _1414 = _1412 * _1412;
        float _1415 = _1414 * _1413;
        float _1420 = cb7_011x * _275;
        float _1421 = cb7_011y * _277;
        float _1422 = cb7_011z * _279;
        float _1427 = _1420 + cb7_013x;
        float _1428 = _1421 + cb7_013y;
        float _1429 = _1422 + cb7_013z;
        float _1430 = abs(_1427);
        float _1431 = abs(_1428);
        float _1432 = abs(_1429);
        float _1437 = cb7_014x * _1430;
        float _1438 = cb7_014y * _1431;
        float _1439 = cb7_014z * _1432;
        float _1441 = _1437 + cb7_014w;
        float _1442 = _1438 + cb7_014w;
        float _1443 = _1439 + cb7_014w;
        float _1444 = saturate(_1441);
        float _1445 = saturate(_1442);
        float _1446 = saturate(_1443);
        float _1447 = min(_1444, _1445);
        float _1448 = _1446 * _1446;
        float _1449 = _1448 * _1447;
        bool _1450 = (_1415 > 9.999999717180685e-10f);
        int _1451 = (int)(uint)(_1450);
        bool _1452 = (_1415 < 1.0f);
        bool _1453 = (_1449 > 9.999999717180685e-10f);
        bool _1454 = _1452 && _1453;
        int _1455 = (int)(uint)(_1454);
        if (_1450) {
          float _1489 = cb7_027z * _195;
          float _1490 = cb7_027z * _196;
          float _1491 = cb7_027z * _197;
          float _1492 = _1489 + _275;
          float _1493 = _1490 + _277;
          float _1494 = _1491 + _279;
          float _1495 = cb7_027w * _472;
          float _1496 = cb7_027w * _473;
          float _1497 = cb7_027w * _474;
          float _1498 = _1492 + _1495;
          float _1499 = _1493 + _1496;
          float _1500 = _1494 + _1497;
          float _1501 = _1498 * cb7_029x;
          float _1502 = _1499 * cb7_029y;
          float _1503 = _1500 * cb7_029z;
          float _1504 = _1501 + cb7_030x;
          float _1505 = _1502 + cb7_030y;
          float _1506 = _1503 + cb7_030z;
          int _1507 = int(_1504);
          int _1508 = int(_1505);
          int _1509 = int(_1506);
          uint _1510 = (uint)(cb7_020x) + -1u;
          uint _1511 = (uint)(cb7_020y) + -1u;
          uint _1512 = (uint)(cb7_020z) + -1u;
          int _1513 = max(_1507, 0);
          int _1514 = max(_1508, 0);
          int _1515 = max(_1509, 0);
          int _1516 = min(_1513, _1510);
          int _1517 = min(_1514, _1511);
          int _1518 = min(_1515, _1512);
          float _1519 = float((int)(_1516));
          float _1520 = float((int)(_1517));
          float _1521 = float((int)(_1518));
          float _1522 = _1504 - _1519;
          float _1523 = _1505 - _1520;
          float _1524 = _1506 - _1521;
          _1528 = 0.0f;
          _1529 = 0.0f;
          _1530 = 0.0f;
          _1531 = 0.0f;
          _1532 = 0.0f;
          _1533 = 0;
          while(true) {
            int _1534 = (uint)(_1533) >> 1;
            int _1535 = (uint)(_1533) >> 2;
            int _1536 = _1533 & 1;
            int _1537 = _1534 & 1;
            int _1538 = _1535 & 1;
            uint _1539 = _1536 + _1516;
            uint _1540 = _1537 + _1517;
            uint _1541 = _1538 + _1518;
            bool _1542 = ((int)_1539 >= (int)cb7_020x);
            bool _1543 = ((int)_1540 >= (int)cb7_020y);
            bool _1544 = ((int)_1541 >= (int)cb7_020z);
            bool _1545 = _1542 || _1543;
            bool _1546 = _1544 || _1545;
            if (!_1546) {
              uint _1548 = (uint)(cb7_020x) - (uint)(cb7_025x);
              uint _1549 = _1548 + _1539;
              uint _1550 = (uint)(cb7_020y) - (uint)(cb7_025y);
              uint _1551 = _1550 + _1540;
              uint _1552 = (uint)(cb7_020z) - (uint)(cb7_025z);
              uint _1553 = _1552 + _1541;
              int _1554 = _1549 % cb7_020x;
              int _1555 = _1551 % cb7_020y;
              int _1556 = _1553 % cb7_020z;
              int _1557 = _1554 * cb7_020z;
              int _1558 = _1556 + _1557;
              float4 _1561 = t34[1].Load(int3(_1558, _1555, 0));
              uint _1564 = t32[1].Load(int3(_1558, _1555, 0));
              int _1566 = _1564.x & -2;
              bool _1567 = (_1566 == 2);
              if (_1567) {
                float _1570 = _1561.z * 0.44999998807907104f;
                float _1572 = _1561.y * 0.44999998807907104f;
                float _1574 = _1561.x * 0.44999998807907104f;
                float _1575 = float((int)(_1536));
                float _1576 = float((int)(_1537));
                float _1577 = float((int)(_1538));
                float _1578 = _1519 - cb7_028x;
                float _1579 = _1578 + _1575;
                float _1580 = _1579 + _1574;
                float _1581 = _1580 * cb7_019x;
                float _1582 = cb7_018x - _1498;
                float _1583 = _1581 + _1582;
                float _1584 = _1520 - cb7_028y;
                float _1585 = _1584 + _1576;
                float _1586 = _1585 + _1572;
                float _1587 = _1586 * cb7_019y;
                float _1588 = cb7_018y - _1499;
                float _1589 = _1587 + _1588;
                float _1590 = _1521 - cb7_028z;
                float _1591 = _1590 + _1577;
                float _1592 = _1591 + _1570;
                float _1593 = _1592 * cb7_019z;
                float _1594 = cb7_018z - _1500;
                float _1595 = _1593 + _1594;
                float _1596 = _1583 * _1583;
                float _1597 = _1589 * _1589;
                float _1598 = _1596 + _1597;
                float _1599 = _1595 * _1595;
                float _1600 = _1598 + _1599;
                float _1601 = sqrt(_1600);
                float _1602 = max(_1601, 9.999999747378752e-06f);
                float _1603 = _1583 / _1602;
                float _1604 = _1589 / _1602;
                float _1605 = _1595 / _1602;
                float _1606 = -0.0f - _1603;
                float _1607 = -0.0f - _1604;
                float _1608 = -0.0f - _1605;
                float _1609 = abs(_1606);
                float _1610 = abs(_1607);
                float _1611 = _1610 + _1609;
                float _1612 = abs(_1608);
                float _1613 = _1611 + _1612;
                float _1614 = _1606 / _1613;
                float _1615 = _1607 / _1613;
                float _1616 = _1608 / _1613;
                bool _1617 = (_1616 > 0.0f);
                if (!_1617) {
                  float _1619 = abs(_1615);
                  float _1620 = abs(_1614);
                  float _1621 = 1.0f - _1619;
                  float _1622 = 1.0f - _1620;
                  bool _1623 = (_1614 > 0.0f);
                  bool _1624 = (_1615 > 0.0f);
                  bool _1625 = (_1614 < 0.0f);
                  bool _1626 = (_1615 < 0.0f);
                  int _1627 = (int)(uint)(_1623);
                  int _1628 = (int)(uint)(_1624);
                  int _1629 = (int)(uint)(_1625);
                  int _1630 = (int)(uint)(_1626);
                  int _1631 = _1627 - _1629;
                  int _1632 = _1628 - _1630;
                  float _1633 = float((int)(_1631));
                  float _1634 = float((int)(_1632));
                  float _1635 = _1621 * _1633;
                  float _1636 = _1622 * _1634;
                  _1638 = _1635;
                  _1639 = _1636;
                } else {
                  _1638 = _1614;
                  _1639 = _1615;
                }
                float _1640 = float((int)(cb7_023w));
                float _1641 = _1640 * 0.5f;
                float _1642 = _1640 + 2.0f;
                float _1643 = _1641 / _1642;
                float _1644 = float((int)(cb7_020x));
                float _1645 = float((int)(cb7_020y));
                float _1646 = 1.0f / _1644;
                float _1647 = 1.0f / _1645;
                float _1648 = float((int)(_1554));
                float _1649 = float((int)(_1555));
                float _1650 = _1648 + 0.5f;
                float _1651 = _1649 + 0.5f;
                float _1652 = _1643 * _1638;
                float _1653 = _1643 * _1639;
                float _1654 = _1652 + _1650;
                float _1655 = _1653 + _1651;
                float _1656 = _1654 * _1646;
                float _1657 = _1655 * _1647;
                float _1658 = float((int)(_1556));
                float3 _1662 = t30[1].SampleLevel(s7, float3(_1656, _1657, _1658), 0.0f);
                float _1665 = abs(_195);
                float _1666 = abs(_196);
                float _1667 = _1666 + _1665;
                float _1668 = abs(_197);
                float _1669 = _1667 + _1668;
                float _1670 = _195 / _1669;
                float _1671 = _196 / _1669;
                float _1672 = _197 / _1669;
                bool _1673 = (_1672 > 0.0f);
                if (!_1673) {
                  float _1675 = abs(_1671);
                  float _1676 = abs(_1670);
                  float _1677 = 1.0f - _1675;
                  float _1678 = 1.0f - _1676;
                  bool _1679 = (_1670 > 0.0f);
                  bool _1680 = (_1671 > 0.0f);
                  bool _1681 = (_1670 < 0.0f);
                  bool _1682 = (_1671 < 0.0f);
                  int _1683 = (int)(uint)(_1679);
                  int _1684 = (int)(uint)(_1680);
                  int _1685 = (int)(uint)(_1681);
                  int _1686 = (int)(uint)(_1682);
                  int _1687 = _1683 - _1685;
                  int _1688 = _1684 - _1686;
                  float _1689 = float((int)(_1687));
                  float _1690 = float((int)(_1688));
                  float _1691 = _1677 * _1689;
                  float _1692 = _1678 * _1690;
                  _1694 = _1691;
                  _1695 = _1692;
                } else {
                  _1694 = _1670;
                  _1695 = _1671;
                }
                float _1696 = float((int)(cb7_023z));
                float _1697 = _1696 * 0.5f;
                float _1698 = _1696 + 2.0f;
                float _1699 = _1697 / _1698;
                float _1700 = _1699 * _1694;
                float _1701 = _1699 * _1695;
                float _1702 = _1700 + _1650;
                float _1703 = _1701 + _1651;
                float _1704 = _1702 * _1646;
                float _1705 = _1703 * _1647;
                float4 _1709 = t28[1].SampleLevel(s7, float3(_1704, _1705, _1658), 0.0f);
                float _1713 = cb7_024z * 0.5f;
                float _1714 = log2(_1709.x);
                float _1715 = log2(_1709.y);
                float _1716 = log2(_1709.z);
                float _1717 = _1714 * _1713;
                float _1718 = _1715 * _1713;
                float _1719 = _1716 * _1713;
                float _1720 = exp2(_1717);
                float _1721 = exp2(_1718);
                float _1722 = exp2(_1719);
                float _1723 = 1.0f - _1522;
                float _1724 = 1.0f - _1523;
                float _1725 = 1.0f - _1524;
                bool _1726 = (_1536 != 0);
                bool _1727 = (_1537 != 0);
                bool _1728 = (_1538 != 0);
                float _1729 = select(_1726, _1522, _1723);
                float _1730 = select(_1727, _1523, _1724);
                float _1731 = select(_1728, _1524, _1725);
                float _1732 = _1730 * _1729;
                float _1733 = _1732 * _1731;
                float _1734 = _1733 + _1532;
                bool _1735 = (_1601 > _1662.x);
                if (_1735) {
                  float _1737 = _1662.x * _1662.x;
                  float _1738 = _1662.y - _1737;
                  float _1739 = abs(_1738);
                  float _1740 = _1601 - _1662.x;
                  float _1741 = _1740 * _1740;
                  float _1742 = _1739 + _1741;
                  float _1743 = _1739 / _1742;
                  float _1744 = _1743 * _1733;
                  _1746 = _1744;
                } else {
                  _1746 = _1733;
                }
                float _1747 = dot(float3(_1603, _1604, _1605), float3(_195, _196, _197));
                float _1748 = _1747 * 0.5f;
                float _1749 = _1748 + 0.5f;
                float _1750 = saturate(_1749);
                float _1751 = _1750 * _1746;
                float _1752 = _1751 * _1720;
                float _1753 = _1751 * _1721;
                float _1754 = _1751 * _1722;
                float _1755 = _1752 + _1528;
                float _1756 = _1753 + _1529;
                float _1757 = _1754 + _1530;
                float _1758 = _1751 + _1531;
                _1760 = _1755;
                _1761 = _1756;
                _1762 = _1757;
                _1763 = _1758;
                _1764 = _1734;
              } else {
                _1760 = _1528;
                _1761 = _1529;
                _1762 = _1530;
                _1763 = _1531;
                _1764 = _1532;
              }
            } else {
              _1760 = _1528;
              _1761 = _1529;
              _1762 = _1530;
              _1763 = _1531;
              _1764 = _1532;
            }
            int _1765 = _1533 + 1;
            bool _1766 = (_1765 == 8);
            if (!_1766) {
              _1528 = _1760;
              _1529 = _1761;
              _1530 = _1762;
              _1531 = _1763;
              _1532 = _1764;
              _1533 = _1765;
              continue;
            }
            break;
          }
          while(true) {
            bool _1526 = (_1763 > 9.999999747378752e-06f);
            if (_1526) {
              float _1768 = _1760 / _1763;
              float _1769 = _1761 / _1763;
              float _1770 = _1762 / _1763;
              float _1771 = _1768 * _1768;
              float _1772 = _1771 * 3.1415927410125732f;
              float _1773 = _1769 * _1769;
              float _1774 = _1773 * 3.1415927410125732f;
              float _1775 = _1770 * _1770;
              float _1776 = _1775 * 3.1415927410125732f;
              _1790 = _1772;
              _1791 = _1774;
              _1792 = _1776;
              _1793 = _1763;
            } else {
              bool _1778 = (_1764 > 9.999999747378752e-06f);
              if (_1778) {
                float _1780 = _1760 / _1764;
                float _1781 = _1761 / _1764;
                float _1782 = _1762 / _1764;
                float _1783 = _1780 * _1780;
                float _1784 = _1783 * 3.1415927410125732f;
                float _1785 = _1781 * _1781;
                float _1786 = _1785 * 3.1415927410125732f;
                float _1787 = _1782 * _1782;
                float _1788 = _1787 * 3.1415927410125732f;
                _1790 = _1784;
                _1791 = _1786;
                _1792 = _1788;
                _1793 = _1764;
              } else {
                _1790 = 0.0f;
                _1791 = 0.0f;
                _1792 = 0.0f;
                _1793 = 0.0f;
              }
            }
            bool _1794 = (_1793 < 9.999999747378752e-06f);
            if (!_1794) {
              _1796 = _1790;
              _1797 = _1791;
              _1798 = _1792;
              if (_1454) {
                _1800 = _1796;
                _1801 = _1797;
                _1802 = _1798;
                _1803 = _1455;
                _1804 = _1451;
                _1805 = _1415;
                float _1842 = cb7_009z * _195;
                float _1843 = cb7_009z * _196;
                float _1844 = cb7_009z * _197;
                float _1845 = _1842 + _275;
                float _1846 = _1843 + _277;
                float _1847 = _1844 + _279;
                float _1848 = cb7_009w * _472;
                float _1849 = cb7_009w * _473;
                float _1850 = cb7_009w * _474;
                float _1851 = _1845 + _1848;
                float _1852 = _1846 + _1849;
                float _1853 = _1847 + _1850;
                float _1854 = _1851 * cb7_011x;
                float _1855 = _1852 * cb7_011y;
                float _1856 = _1853 * cb7_011z;
                float _1857 = _1854 + cb7_012x;
                float _1858 = _1855 + cb7_012y;
                float _1859 = _1856 + cb7_012z;
                int _1860 = int(_1857);
                int _1861 = int(_1858);
                int _1862 = int(_1859);
                uint _1863 = (uint)(cb7_002x) + -1u;
                uint _1864 = (uint)(cb7_002y) + -1u;
                uint _1865 = (uint)(cb7_002z) + -1u;
                int _1866 = max(_1860, 0);
                int _1867 = max(_1861, 0);
                int _1868 = max(_1862, 0);
                int _1869 = min(_1866, _1863);
                int _1870 = min(_1867, _1864);
                int _1871 = min(_1868, _1865);
                float _1872 = float((int)(_1869));
                float _1873 = float((int)(_1870));
                float _1874 = float((int)(_1871));
                float _1875 = _1857 - _1872;
                float _1876 = _1858 - _1873;
                float _1877 = _1859 - _1874;
                _1881 = 0.0f;
                _1882 = 0.0f;
                _1883 = 0.0f;
                _1884 = 0.0f;
                _1885 = 0.0f;
                _1886 = 0;
                while(true) {
                  int _1887 = (uint)(_1886) >> 1;
                  int _1888 = (uint)(_1886) >> 2;
                  int _1889 = _1886 & 1;
                  int _1890 = _1887 & 1;
                  int _1891 = _1888 & 1;
                  uint _1892 = _1889 + _1869;
                  uint _1893 = _1890 + _1870;
                  uint _1894 = _1891 + _1871;
                  bool _1895 = ((int)_1892 >= (int)cb7_002x);
                  bool _1896 = ((int)_1893 >= (int)cb7_002y);
                  bool _1897 = ((int)_1894 >= (int)cb7_002z);
                  bool _1898 = _1895 || _1896;
                  bool _1899 = _1897 || _1898;
                  if (!_1899) {
                    uint _1901 = (uint)(cb7_002x) - (uint)(cb7_007x);
                    uint _1902 = _1901 + _1892;
                    uint _1903 = (uint)(cb7_002y) - (uint)(cb7_007y);
                    uint _1904 = _1903 + _1893;
                    uint _1905 = (uint)(cb7_002z) - (uint)(cb7_007z);
                    uint _1906 = _1905 + _1894;
                    int _1907 = _1902 % cb7_002x;
                    int _1908 = _1904 % cb7_002y;
                    int _1909 = _1906 % cb7_002z;
                    uint _1911 = t38.Load(int4(_1907, _1908, _1909, 0));
                    int _1913 = _1911.x & 511;
                    int _1914 = (uint)((uint)(_1911.x)) >> 9;
                    float4 _1917 = t34[0].Load(int3(_1913, _1914, 0));
                    uint _1919 = t38.Load(int4(_1907, _1908, _1909, 0));
                    int _1921 = _1919.x & 127;
                    int _1922 = (uint)((uint)(_1919.x)) >> 7;
                    int _1923 = _1922 & 127;
                    int _1924 = (uint)((uint)(_1919.x)) >> 14;
                    int _1925 = _1922 | _1919.x;
                    int _1926 = _1925 & 127;
                    int _1927 = _1926 | _1924;
                    bool _1928 = (_1927 == 0);
                    if (!_1928) {
                      float _1931 = _1917.z * 0.44999998807907104f;
                      float _1933 = _1917.y * 0.44999998807907104f;
                      float _1935 = _1917.x * 0.44999998807907104f;
                      float _1936 = float((int)(_1889));
                      float _1937 = float((int)(_1890));
                      float _1938 = float((int)(_1891));
                      float _1939 = _1872 - cb7_010x;
                      float _1940 = _1939 + _1936;
                      float _1941 = _1940 + _1935;
                      float _1942 = _1941 * cb7_001x;
                      float _1943 = cb7_000x - _1851;
                      float _1944 = _1942 + _1943;
                      float _1945 = _1873 - cb7_010y;
                      float _1946 = _1945 + _1937;
                      float _1947 = _1946 + _1933;
                      float _1948 = _1947 * cb7_001y;
                      float _1949 = cb7_000y - _1852;
                      float _1950 = _1948 + _1949;
                      float _1951 = _1874 - cb7_010z;
                      float _1952 = _1951 + _1938;
                      float _1953 = _1952 + _1931;
                      float _1954 = _1953 * cb7_001z;
                      float _1955 = cb7_000z - _1853;
                      float _1956 = _1954 + _1955;
                      float _1957 = _1944 * _1944;
                      float _1958 = _1950 * _1950;
                      float _1959 = _1957 + _1958;
                      float _1960 = _1956 * _1956;
                      float _1961 = _1959 + _1960;
                      float _1962 = sqrt(_1961);
                      float _1963 = max(_1962, 9.999999747378752e-06f);
                      float _1964 = _1944 / _1963;
                      float _1965 = _1950 / _1963;
                      float _1966 = _1956 / _1963;
                      float _1967 = -0.0f - _1964;
                      float _1968 = -0.0f - _1965;
                      float _1969 = -0.0f - _1966;
                      float _1970 = abs(_1967);
                      float _1971 = abs(_1968);
                      float _1972 = _1971 + _1970;
                      float _1973 = abs(_1969);
                      float _1974 = _1972 + _1973;
                      float _1975 = _1967 / _1974;
                      float _1976 = _1968 / _1974;
                      float _1977 = _1969 / _1974;
                      bool _1978 = (_1977 > 0.0f);
                      if (!_1978) {
                        float _1980 = abs(_1976);
                        float _1981 = abs(_1975);
                        float _1982 = 1.0f - _1980;
                        float _1983 = 1.0f - _1981;
                        bool _1984 = (_1975 > 0.0f);
                        bool _1985 = (_1976 > 0.0f);
                        bool _1986 = (_1975 < 0.0f);
                        bool _1987 = (_1976 < 0.0f);
                        int _1988 = (int)(uint)(_1984);
                        int _1989 = (int)(uint)(_1985);
                        int _1990 = (int)(uint)(_1986);
                        int _1991 = (int)(uint)(_1987);
                        int _1992 = _1988 - _1990;
                        int _1993 = _1989 - _1991;
                        float _1994 = float((int)(_1992));
                        float _1995 = float((int)(_1993));
                        float _1996 = _1982 * _1994;
                        float _1997 = _1983 * _1995;
                        _1999 = _1996;
                        _2000 = _1997;
                      } else {
                        _1999 = _1975;
                        _2000 = _1976;
                      }
                      float _2001 = float((int)(cb7_005w));
                      float _2002 = _2001 * 0.5f;
                      float _2003 = _2001 + 2.0f;
                      float _2004 = _2002 / _2003;
                      float _2005 = float((int)(_1921));
                      float _2006 = float((int)(_1923));
                      float _2007 = _2005 + 0.5f;
                      float _2008 = _2006 + 0.5f;
                      float _2009 = _2004 * _1999;
                      float _2010 = _2004 * _2000;
                      float _2011 = _2009 + _2007;
                      float _2012 = _2010 + _2008;
                      float _2013 = _2011 * 0.0078125f;
                      float _2014 = _2012 * 0.0078125f;
                      float _2015 = float((int)(_1924));
                      float3 _2019 = t30[0].SampleLevel(s7, float3(_2013, _2014, _2015), 0.0f);
                      float _2022 = abs(_195);
                      float _2023 = abs(_196);
                      float _2024 = _2023 + _2022;
                      float _2025 = abs(_197);
                      float _2026 = _2024 + _2025;
                      float _2027 = _195 / _2026;
                      float _2028 = _196 / _2026;
                      float _2029 = _197 / _2026;
                      bool _2030 = (_2029 > 0.0f);
                      if (!_2030) {
                        float _2032 = abs(_2028);
                        float _2033 = abs(_2027);
                        float _2034 = 1.0f - _2032;
                        float _2035 = 1.0f - _2033;
                        bool _2036 = (_2027 > 0.0f);
                        bool _2037 = (_2028 > 0.0f);
                        bool _2038 = (_2027 < 0.0f);
                        bool _2039 = (_2028 < 0.0f);
                        int _2040 = (int)(uint)(_2036);
                        int _2041 = (int)(uint)(_2037);
                        int _2042 = (int)(uint)(_2038);
                        int _2043 = (int)(uint)(_2039);
                        int _2044 = _2040 - _2042;
                        int _2045 = _2041 - _2043;
                        float _2046 = float((int)(_2044));
                        float _2047 = float((int)(_2045));
                        float _2048 = _2034 * _2046;
                        float _2049 = _2035 * _2047;
                        _2051 = _2048;
                        _2052 = _2049;
                      } else {
                        _2051 = _2027;
                        _2052 = _2028;
                      }
                      float _2053 = float((int)(cb7_005z));
                      float _2054 = _2053 * 0.5f;
                      float _2055 = _2053 + 2.0f;
                      float _2056 = _2054 / _2055;
                      float _2057 = _2056 * _2051;
                      float _2058 = _2056 * _2052;
                      float _2059 = _2057 + _2007;
                      float _2060 = _2058 + _2008;
                      float _2061 = _2059 * 0.0078125f;
                      float _2062 = _2060 * 0.0078125f;
                      float4 _2066 = t28[0].SampleLevel(s7, float3(_2061, _2062, _2015), 0.0f);
                      float _2070 = cb7_006z * 0.5f;
                      float _2071 = log2(_2066.x);
                      float _2072 = log2(_2066.y);
                      float _2073 = log2(_2066.z);
                      float _2074 = _2071 * _2070;
                      float _2075 = _2072 * _2070;
                      float _2076 = _2073 * _2070;
                      float _2077 = exp2(_2074);
                      float _2078 = exp2(_2075);
                      float _2079 = exp2(_2076);
                      float _2080 = 1.0f - _1875;
                      float _2081 = 1.0f - _1876;
                      float _2082 = 1.0f - _1877;
                      bool _2083 = (_1889 != 0);
                      bool _2084 = (_1890 != 0);
                      bool _2085 = (_1891 != 0);
                      float _2086 = select(_2083, _1875, _2080);
                      float _2087 = select(_2084, _1876, _2081);
                      float _2088 = select(_2085, _1877, _2082);
                      float _2089 = _2087 * _2086;
                      float _2090 = _2089 * _2088;
                      float _2091 = _2090 + _1885;
                      bool _2092 = (_1962 > _2019.x);
                      if (_2092) {
                        float _2094 = _2019.x * _2019.x;
                        float _2095 = _2019.y - _2094;
                        float _2096 = abs(_2095);
                        float _2097 = _1962 - _2019.x;
                        float _2098 = _2097 * _2097;
                        float _2099 = _2096 + _2098;
                        float _2100 = _2096 / _2099;
                        float _2101 = _2100 * _2090;
                        _2103 = _2101;
                      } else {
                        _2103 = _2090;
                      }
                      float _2104 = dot(float3(_1964, _1965, _1966), float3(_195, _196, _197));
                      float _2105 = _2104 * 0.5f;
                      float _2106 = _2105 + 0.5f;
                      float _2107 = saturate(_2106);
                      float _2108 = _2107 * _2103;
                      float _2109 = _2108 * _2077;
                      float _2110 = _2108 * _2078;
                      float _2111 = _2108 * _2079;
                      float _2112 = _2109 + _1881;
                      float _2113 = _2110 + _1882;
                      float _2114 = _2111 + _1883;
                      float _2115 = _2108 + _1884;
                      _2117 = _2112;
                      _2118 = _2113;
                      _2119 = _2114;
                      _2120 = _2115;
                      _2121 = _2091;
                    } else {
                      _2117 = _1881;
                      _2118 = _1882;
                      _2119 = _1883;
                      _2120 = _1884;
                      _2121 = _1885;
                    }
                  } else {
                    _2117 = _1881;
                    _2118 = _1882;
                    _2119 = _1883;
                    _2120 = _1884;
                    _2121 = _1885;
                  }
                  int _2122 = _1886 + 1;
                  bool _2123 = (_2122 == 8);
                  if (!_2123) {
                    _1881 = _2117;
                    _1882 = _2118;
                    _1883 = _2119;
                    _1884 = _2120;
                    _1885 = _2121;
                    _1886 = _2122;
                    continue;
                  }
                  break;
                }
                while(true) {
                  bool _1879 = (_2120 > 9.999999747378752e-06f);
                  if (_1879) {
                    float _2125 = _2117 / _2120;
                    float _2126 = _2118 / _2120;
                    float _2127 = _2119 / _2120;
                    float _2128 = _2125 * _2125;
                    float _2129 = _2128 * 3.1415927410125732f;
                    float _2130 = _2126 * _2126;
                    float _2131 = _2130 * 3.1415927410125732f;
                    float _2132 = _2127 * _2127;
                    float _2133 = _2132 * 3.1415927410125732f;
                    _2147 = _2129;
                    _2148 = _2131;
                    _2149 = _2133;
                    _2150 = _2120;
                  } else {
                    bool _2135 = (_2121 > 9.999999747378752e-06f);
                    if (_2135) {
                      float _2137 = _2117 / _2121;
                      float _2138 = _2118 / _2121;
                      float _2139 = _2119 / _2121;
                      float _2140 = _2137 * _2137;
                      float _2141 = _2140 * 3.1415927410125732f;
                      float _2142 = _2138 * _2138;
                      float _2143 = _2142 * 3.1415927410125732f;
                      float _2144 = _2139 * _2139;
                      float _2145 = _2144 * 3.1415927410125732f;
                      _2147 = _2141;
                      _2148 = _2143;
                      _2149 = _2145;
                      _2150 = _2121;
                    } else {
                      _2147 = 0.0f;
                      _2148 = 0.0f;
                      _2149 = 0.0f;
                      _2150 = 0.0f;
                    }
                  }
                  bool _2151 = (_2150 < 9.999999747378752e-06f);
                  if (_2151) {
                    _2154 = _1800;
                    _2155 = _1801;
                    _2156 = _1802;
                    _2157 = _1804;
                    _2158 = _1805;
                    _2159 = 0.0f;
                    _2160 = 0;
                    _2161 = _2147;
                    _2162 = _2148;
                    _2163 = _2149;
                  } else {
                    _2154 = _1800;
                    _2155 = _1801;
                    _2156 = _1802;
                    _2157 = _1804;
                    _2158 = _1805;
                    _2159 = _1449;
                    _2160 = _1803;
                    _2161 = _2147;
                    _2162 = _2148;
                    _2163 = _2149;
                  }
                  break;
                }
              } else {
                _2154 = _1796;
                _2155 = _1797;
                _2156 = _1798;
                _2157 = _1451;
                _2158 = _1415;
                _2159 = _1449;
                _2160 = _1455;
                _2161 = 0.0f;
                _2162 = 0.0f;
                _2163 = 0.0f;
              }
            } else {
              _1800 = _1790;
              _1801 = _1791;
              _1802 = _1792;
              _1803 = 1;
              _1804 = 0;
              _1805 = 0.0f;
              float _1842 = cb7_009z * _195;
              float _1843 = cb7_009z * _196;
              float _1844 = cb7_009z * _197;
              float _1845 = _1842 + _275;
              float _1846 = _1843 + _277;
              float _1847 = _1844 + _279;
              float _1848 = cb7_009w * _472;
              float _1849 = cb7_009w * _473;
              float _1850 = cb7_009w * _474;
              float _1851 = _1845 + _1848;
              float _1852 = _1846 + _1849;
              float _1853 = _1847 + _1850;
              float _1854 = _1851 * cb7_011x;
              float _1855 = _1852 * cb7_011y;
              float _1856 = _1853 * cb7_011z;
              float _1857 = _1854 + cb7_012x;
              float _1858 = _1855 + cb7_012y;
              float _1859 = _1856 + cb7_012z;
              int _1860 = int(_1857);
              int _1861 = int(_1858);
              int _1862 = int(_1859);
              uint _1863 = (uint)(cb7_002x) + -1u;
              uint _1864 = (uint)(cb7_002y) + -1u;
              uint _1865 = (uint)(cb7_002z) + -1u;
              int _1866 = max(_1860, 0);
              int _1867 = max(_1861, 0);
              int _1868 = max(_1862, 0);
              int _1869 = min(_1866, _1863);
              int _1870 = min(_1867, _1864);
              int _1871 = min(_1868, _1865);
              float _1872 = float((int)(_1869));
              float _1873 = float((int)(_1870));
              float _1874 = float((int)(_1871));
              float _1875 = _1857 - _1872;
              float _1876 = _1858 - _1873;
              float _1877 = _1859 - _1874;
              _1881 = 0.0f;
              _1882 = 0.0f;
              _1883 = 0.0f;
              _1884 = 0.0f;
              _1885 = 0.0f;
              _1886 = 0;
              while(true) {
                int _1887 = (uint)(_1886) >> 1;
                int _1888 = (uint)(_1886) >> 2;
                int _1889 = _1886 & 1;
                int _1890 = _1887 & 1;
                int _1891 = _1888 & 1;
                uint _1892 = _1889 + _1869;
                uint _1893 = _1890 + _1870;
                uint _1894 = _1891 + _1871;
                bool _1895 = ((int)_1892 >= (int)cb7_002x);
                bool _1896 = ((int)_1893 >= (int)cb7_002y);
                bool _1897 = ((int)_1894 >= (int)cb7_002z);
                bool _1898 = _1895 || _1896;
                bool _1899 = _1897 || _1898;
                if (!_1899) {
                  uint _1901 = (uint)(cb7_002x) - (uint)(cb7_007x);
                  uint _1902 = _1901 + _1892;
                  uint _1903 = (uint)(cb7_002y) - (uint)(cb7_007y);
                  uint _1904 = _1903 + _1893;
                  uint _1905 = (uint)(cb7_002z) - (uint)(cb7_007z);
                  uint _1906 = _1905 + _1894;
                  int _1907 = _1902 % cb7_002x;
                  int _1908 = _1904 % cb7_002y;
                  int _1909 = _1906 % cb7_002z;
                  uint _1911 = t38.Load(int4(_1907, _1908, _1909, 0));
                  int _1913 = _1911.x & 511;
                  int _1914 = (uint)((uint)(_1911.x)) >> 9;
                  float4 _1917 = t34[0].Load(int3(_1913, _1914, 0));
                  uint _1919 = t38.Load(int4(_1907, _1908, _1909, 0));
                  int _1921 = _1919.x & 127;
                  int _1922 = (uint)((uint)(_1919.x)) >> 7;
                  int _1923 = _1922 & 127;
                  int _1924 = (uint)((uint)(_1919.x)) >> 14;
                  int _1925 = _1922 | _1919.x;
                  int _1926 = _1925 & 127;
                  int _1927 = _1926 | _1924;
                  bool _1928 = (_1927 == 0);
                  if (!_1928) {
                    float _1931 = _1917.z * 0.44999998807907104f;
                    float _1933 = _1917.y * 0.44999998807907104f;
                    float _1935 = _1917.x * 0.44999998807907104f;
                    float _1936 = float((int)(_1889));
                    float _1937 = float((int)(_1890));
                    float _1938 = float((int)(_1891));
                    float _1939 = _1872 - cb7_010x;
                    float _1940 = _1939 + _1936;
                    float _1941 = _1940 + _1935;
                    float _1942 = _1941 * cb7_001x;
                    float _1943 = cb7_000x - _1851;
                    float _1944 = _1942 + _1943;
                    float _1945 = _1873 - cb7_010y;
                    float _1946 = _1945 + _1937;
                    float _1947 = _1946 + _1933;
                    float _1948 = _1947 * cb7_001y;
                    float _1949 = cb7_000y - _1852;
                    float _1950 = _1948 + _1949;
                    float _1951 = _1874 - cb7_010z;
                    float _1952 = _1951 + _1938;
                    float _1953 = _1952 + _1931;
                    float _1954 = _1953 * cb7_001z;
                    float _1955 = cb7_000z - _1853;
                    float _1956 = _1954 + _1955;
                    float _1957 = _1944 * _1944;
                    float _1958 = _1950 * _1950;
                    float _1959 = _1957 + _1958;
                    float _1960 = _1956 * _1956;
                    float _1961 = _1959 + _1960;
                    float _1962 = sqrt(_1961);
                    float _1963 = max(_1962, 9.999999747378752e-06f);
                    float _1964 = _1944 / _1963;
                    float _1965 = _1950 / _1963;
                    float _1966 = _1956 / _1963;
                    float _1967 = -0.0f - _1964;
                    float _1968 = -0.0f - _1965;
                    float _1969 = -0.0f - _1966;
                    float _1970 = abs(_1967);
                    float _1971 = abs(_1968);
                    float _1972 = _1971 + _1970;
                    float _1973 = abs(_1969);
                    float _1974 = _1972 + _1973;
                    float _1975 = _1967 / _1974;
                    float _1976 = _1968 / _1974;
                    float _1977 = _1969 / _1974;
                    bool _1978 = (_1977 > 0.0f);
                    if (!_1978) {
                      float _1980 = abs(_1976);
                      float _1981 = abs(_1975);
                      float _1982 = 1.0f - _1980;
                      float _1983 = 1.0f - _1981;
                      bool _1984 = (_1975 > 0.0f);
                      bool _1985 = (_1976 > 0.0f);
                      bool _1986 = (_1975 < 0.0f);
                      bool _1987 = (_1976 < 0.0f);
                      int _1988 = (int)(uint)(_1984);
                      int _1989 = (int)(uint)(_1985);
                      int _1990 = (int)(uint)(_1986);
                      int _1991 = (int)(uint)(_1987);
                      int _1992 = _1988 - _1990;
                      int _1993 = _1989 - _1991;
                      float _1994 = float((int)(_1992));
                      float _1995 = float((int)(_1993));
                      float _1996 = _1982 * _1994;
                      float _1997 = _1983 * _1995;
                      _1999 = _1996;
                      _2000 = _1997;
                    } else {
                      _1999 = _1975;
                      _2000 = _1976;
                    }
                    float _2001 = float((int)(cb7_005w));
                    float _2002 = _2001 * 0.5f;
                    float _2003 = _2001 + 2.0f;
                    float _2004 = _2002 / _2003;
                    float _2005 = float((int)(_1921));
                    float _2006 = float((int)(_1923));
                    float _2007 = _2005 + 0.5f;
                    float _2008 = _2006 + 0.5f;
                    float _2009 = _2004 * _1999;
                    float _2010 = _2004 * _2000;
                    float _2011 = _2009 + _2007;
                    float _2012 = _2010 + _2008;
                    float _2013 = _2011 * 0.0078125f;
                    float _2014 = _2012 * 0.0078125f;
                    float _2015 = float((int)(_1924));
                    float3 _2019 = t30[0].SampleLevel(s7, float3(_2013, _2014, _2015), 0.0f);
                    float _2022 = abs(_195);
                    float _2023 = abs(_196);
                    float _2024 = _2023 + _2022;
                    float _2025 = abs(_197);
                    float _2026 = _2024 + _2025;
                    float _2027 = _195 / _2026;
                    float _2028 = _196 / _2026;
                    float _2029 = _197 / _2026;
                    bool _2030 = (_2029 > 0.0f);
                    if (!_2030) {
                      float _2032 = abs(_2028);
                      float _2033 = abs(_2027);
                      float _2034 = 1.0f - _2032;
                      float _2035 = 1.0f - _2033;
                      bool _2036 = (_2027 > 0.0f);
                      bool _2037 = (_2028 > 0.0f);
                      bool _2038 = (_2027 < 0.0f);
                      bool _2039 = (_2028 < 0.0f);
                      int _2040 = (int)(uint)(_2036);
                      int _2041 = (int)(uint)(_2037);
                      int _2042 = (int)(uint)(_2038);
                      int _2043 = (int)(uint)(_2039);
                      int _2044 = _2040 - _2042;
                      int _2045 = _2041 - _2043;
                      float _2046 = float((int)(_2044));
                      float _2047 = float((int)(_2045));
                      float _2048 = _2034 * _2046;
                      float _2049 = _2035 * _2047;
                      _2051 = _2048;
                      _2052 = _2049;
                    } else {
                      _2051 = _2027;
                      _2052 = _2028;
                    }
                    float _2053 = float((int)(cb7_005z));
                    float _2054 = _2053 * 0.5f;
                    float _2055 = _2053 + 2.0f;
                    float _2056 = _2054 / _2055;
                    float _2057 = _2056 * _2051;
                    float _2058 = _2056 * _2052;
                    float _2059 = _2057 + _2007;
                    float _2060 = _2058 + _2008;
                    float _2061 = _2059 * 0.0078125f;
                    float _2062 = _2060 * 0.0078125f;
                    float4 _2066 = t28[0].SampleLevel(s7, float3(_2061, _2062, _2015), 0.0f);
                    float _2070 = cb7_006z * 0.5f;
                    float _2071 = log2(_2066.x);
                    float _2072 = log2(_2066.y);
                    float _2073 = log2(_2066.z);
                    float _2074 = _2071 * _2070;
                    float _2075 = _2072 * _2070;
                    float _2076 = _2073 * _2070;
                    float _2077 = exp2(_2074);
                    float _2078 = exp2(_2075);
                    float _2079 = exp2(_2076);
                    float _2080 = 1.0f - _1875;
                    float _2081 = 1.0f - _1876;
                    float _2082 = 1.0f - _1877;
                    bool _2083 = (_1889 != 0);
                    bool _2084 = (_1890 != 0);
                    bool _2085 = (_1891 != 0);
                    float _2086 = select(_2083, _1875, _2080);
                    float _2087 = select(_2084, _1876, _2081);
                    float _2088 = select(_2085, _1877, _2082);
                    float _2089 = _2087 * _2086;
                    float _2090 = _2089 * _2088;
                    float _2091 = _2090 + _1885;
                    bool _2092 = (_1962 > _2019.x);
                    if (_2092) {
                      float _2094 = _2019.x * _2019.x;
                      float _2095 = _2019.y - _2094;
                      float _2096 = abs(_2095);
                      float _2097 = _1962 - _2019.x;
                      float _2098 = _2097 * _2097;
                      float _2099 = _2096 + _2098;
                      float _2100 = _2096 / _2099;
                      float _2101 = _2100 * _2090;
                      _2103 = _2101;
                    } else {
                      _2103 = _2090;
                    }
                    float _2104 = dot(float3(_1964, _1965, _1966), float3(_195, _196, _197));
                    float _2105 = _2104 * 0.5f;
                    float _2106 = _2105 + 0.5f;
                    float _2107 = saturate(_2106);
                    float _2108 = _2107 * _2103;
                    float _2109 = _2108 * _2077;
                    float _2110 = _2108 * _2078;
                    float _2111 = _2108 * _2079;
                    float _2112 = _2109 + _1881;
                    float _2113 = _2110 + _1882;
                    float _2114 = _2111 + _1883;
                    float _2115 = _2108 + _1884;
                    _2117 = _2112;
                    _2118 = _2113;
                    _2119 = _2114;
                    _2120 = _2115;
                    _2121 = _2091;
                  } else {
                    _2117 = _1881;
                    _2118 = _1882;
                    _2119 = _1883;
                    _2120 = _1884;
                    _2121 = _1885;
                  }
                } else {
                  _2117 = _1881;
                  _2118 = _1882;
                  _2119 = _1883;
                  _2120 = _1884;
                  _2121 = _1885;
                }
                int _2122 = _1886 + 1;
                bool _2123 = (_2122 == 8);
                if (!_2123) {
                  _1881 = _2117;
                  _1882 = _2118;
                  _1883 = _2119;
                  _1884 = _2120;
                  _1885 = _2121;
                  _1886 = _2122;
                  continue;
                }
                break;
              }
              while(true) {
                bool _1879 = (_2120 > 9.999999747378752e-06f);
                if (_1879) {
                  float _2125 = _2117 / _2120;
                  float _2126 = _2118 / _2120;
                  float _2127 = _2119 / _2120;
                  float _2128 = _2125 * _2125;
                  float _2129 = _2128 * 3.1415927410125732f;
                  float _2130 = _2126 * _2126;
                  float _2131 = _2130 * 3.1415927410125732f;
                  float _2132 = _2127 * _2127;
                  float _2133 = _2132 * 3.1415927410125732f;
                  _2147 = _2129;
                  _2148 = _2131;
                  _2149 = _2133;
                  _2150 = _2120;
                } else {
                  bool _2135 = (_2121 > 9.999999747378752e-06f);
                  if (_2135) {
                    float _2137 = _2117 / _2121;
                    float _2138 = _2118 / _2121;
                    float _2139 = _2119 / _2121;
                    float _2140 = _2137 * _2137;
                    float _2141 = _2140 * 3.1415927410125732f;
                    float _2142 = _2138 * _2138;
                    float _2143 = _2142 * 3.1415927410125732f;
                    float _2144 = _2139 * _2139;
                    float _2145 = _2144 * 3.1415927410125732f;
                    _2147 = _2141;
                    _2148 = _2143;
                    _2149 = _2145;
                    _2150 = _2121;
                  } else {
                    _2147 = 0.0f;
                    _2148 = 0.0f;
                    _2149 = 0.0f;
                    _2150 = 0.0f;
                  }
                }
                bool _2151 = (_2150 < 9.999999747378752e-06f);
                if (_2151) {
                  _2154 = _1800;
                  _2155 = _1801;
                  _2156 = _1802;
                  _2157 = _1804;
                  _2158 = _1805;
                  _2159 = 0.0f;
                  _2160 = 0;
                  _2161 = _2147;
                  _2162 = _2148;
                  _2163 = _2149;
                } else {
                  _2154 = _1800;
                  _2155 = _1801;
                  _2156 = _1802;
                  _2157 = _1804;
                  _2158 = _1805;
                  _2159 = _1449;
                  _2160 = _1803;
                  _2161 = _2147;
                  _2162 = _2148;
                  _2163 = _2149;
                }
                break;
              }
            }
            break;
          }
        } else {
          _1796 = 0.0f;
          _1797 = 0.0f;
          _1798 = 0.0f;
          if (_1454) {
            _1800 = _1796;
            _1801 = _1797;
            _1802 = _1798;
            _1803 = _1455;
            _1804 = _1451;
            _1805 = _1415;
            float _1842 = cb7_009z * _195;
            float _1843 = cb7_009z * _196;
            float _1844 = cb7_009z * _197;
            float _1845 = _1842 + _275;
            float _1846 = _1843 + _277;
            float _1847 = _1844 + _279;
            float _1848 = cb7_009w * _472;
            float _1849 = cb7_009w * _473;
            float _1850 = cb7_009w * _474;
            float _1851 = _1845 + _1848;
            float _1852 = _1846 + _1849;
            float _1853 = _1847 + _1850;
            float _1854 = _1851 * cb7_011x;
            float _1855 = _1852 * cb7_011y;
            float _1856 = _1853 * cb7_011z;
            float _1857 = _1854 + cb7_012x;
            float _1858 = _1855 + cb7_012y;
            float _1859 = _1856 + cb7_012z;
            int _1860 = int(_1857);
            int _1861 = int(_1858);
            int _1862 = int(_1859);
            uint _1863 = (uint)(cb7_002x) + -1u;
            uint _1864 = (uint)(cb7_002y) + -1u;
            uint _1865 = (uint)(cb7_002z) + -1u;
            int _1866 = max(_1860, 0);
            int _1867 = max(_1861, 0);
            int _1868 = max(_1862, 0);
            int _1869 = min(_1866, _1863);
            int _1870 = min(_1867, _1864);
            int _1871 = min(_1868, _1865);
            float _1872 = float((int)(_1869));
            float _1873 = float((int)(_1870));
            float _1874 = float((int)(_1871));
            float _1875 = _1857 - _1872;
            float _1876 = _1858 - _1873;
            float _1877 = _1859 - _1874;
            _1881 = 0.0f;
            _1882 = 0.0f;
            _1883 = 0.0f;
            _1884 = 0.0f;
            _1885 = 0.0f;
            _1886 = 0;
            while(true) {
              int _1887 = (uint)(_1886) >> 1;
              int _1888 = (uint)(_1886) >> 2;
              int _1889 = _1886 & 1;
              int _1890 = _1887 & 1;
              int _1891 = _1888 & 1;
              uint _1892 = _1889 + _1869;
              uint _1893 = _1890 + _1870;
              uint _1894 = _1891 + _1871;
              bool _1895 = ((int)_1892 >= (int)cb7_002x);
              bool _1896 = ((int)_1893 >= (int)cb7_002y);
              bool _1897 = ((int)_1894 >= (int)cb7_002z);
              bool _1898 = _1895 || _1896;
              bool _1899 = _1897 || _1898;
              if (!_1899) {
                uint _1901 = (uint)(cb7_002x) - (uint)(cb7_007x);
                uint _1902 = _1901 + _1892;
                uint _1903 = (uint)(cb7_002y) - (uint)(cb7_007y);
                uint _1904 = _1903 + _1893;
                uint _1905 = (uint)(cb7_002z) - (uint)(cb7_007z);
                uint _1906 = _1905 + _1894;
                int _1907 = _1902 % cb7_002x;
                int _1908 = _1904 % cb7_002y;
                int _1909 = _1906 % cb7_002z;
                uint _1911 = t38.Load(int4(_1907, _1908, _1909, 0));
                int _1913 = _1911.x & 511;
                int _1914 = (uint)((uint)(_1911.x)) >> 9;
                float4 _1917 = t34[0].Load(int3(_1913, _1914, 0));
                uint _1919 = t38.Load(int4(_1907, _1908, _1909, 0));
                int _1921 = _1919.x & 127;
                int _1922 = (uint)((uint)(_1919.x)) >> 7;
                int _1923 = _1922 & 127;
                int _1924 = (uint)((uint)(_1919.x)) >> 14;
                int _1925 = _1922 | _1919.x;
                int _1926 = _1925 & 127;
                int _1927 = _1926 | _1924;
                bool _1928 = (_1927 == 0);
                if (!_1928) {
                  float _1931 = _1917.z * 0.44999998807907104f;
                  float _1933 = _1917.y * 0.44999998807907104f;
                  float _1935 = _1917.x * 0.44999998807907104f;
                  float _1936 = float((int)(_1889));
                  float _1937 = float((int)(_1890));
                  float _1938 = float((int)(_1891));
                  float _1939 = _1872 - cb7_010x;
                  float _1940 = _1939 + _1936;
                  float _1941 = _1940 + _1935;
                  float _1942 = _1941 * cb7_001x;
                  float _1943 = cb7_000x - _1851;
                  float _1944 = _1942 + _1943;
                  float _1945 = _1873 - cb7_010y;
                  float _1946 = _1945 + _1937;
                  float _1947 = _1946 + _1933;
                  float _1948 = _1947 * cb7_001y;
                  float _1949 = cb7_000y - _1852;
                  float _1950 = _1948 + _1949;
                  float _1951 = _1874 - cb7_010z;
                  float _1952 = _1951 + _1938;
                  float _1953 = _1952 + _1931;
                  float _1954 = _1953 * cb7_001z;
                  float _1955 = cb7_000z - _1853;
                  float _1956 = _1954 + _1955;
                  float _1957 = _1944 * _1944;
                  float _1958 = _1950 * _1950;
                  float _1959 = _1957 + _1958;
                  float _1960 = _1956 * _1956;
                  float _1961 = _1959 + _1960;
                  float _1962 = sqrt(_1961);
                  float _1963 = max(_1962, 9.999999747378752e-06f);
                  float _1964 = _1944 / _1963;
                  float _1965 = _1950 / _1963;
                  float _1966 = _1956 / _1963;
                  float _1967 = -0.0f - _1964;
                  float _1968 = -0.0f - _1965;
                  float _1969 = -0.0f - _1966;
                  float _1970 = abs(_1967);
                  float _1971 = abs(_1968);
                  float _1972 = _1971 + _1970;
                  float _1973 = abs(_1969);
                  float _1974 = _1972 + _1973;
                  float _1975 = _1967 / _1974;
                  float _1976 = _1968 / _1974;
                  float _1977 = _1969 / _1974;
                  bool _1978 = (_1977 > 0.0f);
                  if (!_1978) {
                    float _1980 = abs(_1976);
                    float _1981 = abs(_1975);
                    float _1982 = 1.0f - _1980;
                    float _1983 = 1.0f - _1981;
                    bool _1984 = (_1975 > 0.0f);
                    bool _1985 = (_1976 > 0.0f);
                    bool _1986 = (_1975 < 0.0f);
                    bool _1987 = (_1976 < 0.0f);
                    int _1988 = (int)(uint)(_1984);
                    int _1989 = (int)(uint)(_1985);
                    int _1990 = (int)(uint)(_1986);
                    int _1991 = (int)(uint)(_1987);
                    int _1992 = _1988 - _1990;
                    int _1993 = _1989 - _1991;
                    float _1994 = float((int)(_1992));
                    float _1995 = float((int)(_1993));
                    float _1996 = _1982 * _1994;
                    float _1997 = _1983 * _1995;
                    _1999 = _1996;
                    _2000 = _1997;
                  } else {
                    _1999 = _1975;
                    _2000 = _1976;
                  }
                  float _2001 = float((int)(cb7_005w));
                  float _2002 = _2001 * 0.5f;
                  float _2003 = _2001 + 2.0f;
                  float _2004 = _2002 / _2003;
                  float _2005 = float((int)(_1921));
                  float _2006 = float((int)(_1923));
                  float _2007 = _2005 + 0.5f;
                  float _2008 = _2006 + 0.5f;
                  float _2009 = _2004 * _1999;
                  float _2010 = _2004 * _2000;
                  float _2011 = _2009 + _2007;
                  float _2012 = _2010 + _2008;
                  float _2013 = _2011 * 0.0078125f;
                  float _2014 = _2012 * 0.0078125f;
                  float _2015 = float((int)(_1924));
                  float3 _2019 = t30[0].SampleLevel(s7, float3(_2013, _2014, _2015), 0.0f);
                  float _2022 = abs(_195);
                  float _2023 = abs(_196);
                  float _2024 = _2023 + _2022;
                  float _2025 = abs(_197);
                  float _2026 = _2024 + _2025;
                  float _2027 = _195 / _2026;
                  float _2028 = _196 / _2026;
                  float _2029 = _197 / _2026;
                  bool _2030 = (_2029 > 0.0f);
                  if (!_2030) {
                    float _2032 = abs(_2028);
                    float _2033 = abs(_2027);
                    float _2034 = 1.0f - _2032;
                    float _2035 = 1.0f - _2033;
                    bool _2036 = (_2027 > 0.0f);
                    bool _2037 = (_2028 > 0.0f);
                    bool _2038 = (_2027 < 0.0f);
                    bool _2039 = (_2028 < 0.0f);
                    int _2040 = (int)(uint)(_2036);
                    int _2041 = (int)(uint)(_2037);
                    int _2042 = (int)(uint)(_2038);
                    int _2043 = (int)(uint)(_2039);
                    int _2044 = _2040 - _2042;
                    int _2045 = _2041 - _2043;
                    float _2046 = float((int)(_2044));
                    float _2047 = float((int)(_2045));
                    float _2048 = _2034 * _2046;
                    float _2049 = _2035 * _2047;
                    _2051 = _2048;
                    _2052 = _2049;
                  } else {
                    _2051 = _2027;
                    _2052 = _2028;
                  }
                  float _2053 = float((int)(cb7_005z));
                  float _2054 = _2053 * 0.5f;
                  float _2055 = _2053 + 2.0f;
                  float _2056 = _2054 / _2055;
                  float _2057 = _2056 * _2051;
                  float _2058 = _2056 * _2052;
                  float _2059 = _2057 + _2007;
                  float _2060 = _2058 + _2008;
                  float _2061 = _2059 * 0.0078125f;
                  float _2062 = _2060 * 0.0078125f;
                  float4 _2066 = t28[0].SampleLevel(s7, float3(_2061, _2062, _2015), 0.0f);
                  float _2070 = cb7_006z * 0.5f;
                  float _2071 = log2(_2066.x);
                  float _2072 = log2(_2066.y);
                  float _2073 = log2(_2066.z);
                  float _2074 = _2071 * _2070;
                  float _2075 = _2072 * _2070;
                  float _2076 = _2073 * _2070;
                  float _2077 = exp2(_2074);
                  float _2078 = exp2(_2075);
                  float _2079 = exp2(_2076);
                  float _2080 = 1.0f - _1875;
                  float _2081 = 1.0f - _1876;
                  float _2082 = 1.0f - _1877;
                  bool _2083 = (_1889 != 0);
                  bool _2084 = (_1890 != 0);
                  bool _2085 = (_1891 != 0);
                  float _2086 = select(_2083, _1875, _2080);
                  float _2087 = select(_2084, _1876, _2081);
                  float _2088 = select(_2085, _1877, _2082);
                  float _2089 = _2087 * _2086;
                  float _2090 = _2089 * _2088;
                  float _2091 = _2090 + _1885;
                  bool _2092 = (_1962 > _2019.x);
                  if (_2092) {
                    float _2094 = _2019.x * _2019.x;
                    float _2095 = _2019.y - _2094;
                    float _2096 = abs(_2095);
                    float _2097 = _1962 - _2019.x;
                    float _2098 = _2097 * _2097;
                    float _2099 = _2096 + _2098;
                    float _2100 = _2096 / _2099;
                    float _2101 = _2100 * _2090;
                    _2103 = _2101;
                  } else {
                    _2103 = _2090;
                  }
                  float _2104 = dot(float3(_1964, _1965, _1966), float3(_195, _196, _197));
                  float _2105 = _2104 * 0.5f;
                  float _2106 = _2105 + 0.5f;
                  float _2107 = saturate(_2106);
                  float _2108 = _2107 * _2103;
                  float _2109 = _2108 * _2077;
                  float _2110 = _2108 * _2078;
                  float _2111 = _2108 * _2079;
                  float _2112 = _2109 + _1881;
                  float _2113 = _2110 + _1882;
                  float _2114 = _2111 + _1883;
                  float _2115 = _2108 + _1884;
                  _2117 = _2112;
                  _2118 = _2113;
                  _2119 = _2114;
                  _2120 = _2115;
                  _2121 = _2091;
                } else {
                  _2117 = _1881;
                  _2118 = _1882;
                  _2119 = _1883;
                  _2120 = _1884;
                  _2121 = _1885;
                }
              } else {
                _2117 = _1881;
                _2118 = _1882;
                _2119 = _1883;
                _2120 = _1884;
                _2121 = _1885;
              }
              int _2122 = _1886 + 1;
              bool _2123 = (_2122 == 8);
              if (!_2123) {
                _1881 = _2117;
                _1882 = _2118;
                _1883 = _2119;
                _1884 = _2120;
                _1885 = _2121;
                _1886 = _2122;
                continue;
              }
              break;
            }
            while(true) {
              bool _1879 = (_2120 > 9.999999747378752e-06f);
              if (_1879) {
                float _2125 = _2117 / _2120;
                float _2126 = _2118 / _2120;
                float _2127 = _2119 / _2120;
                float _2128 = _2125 * _2125;
                float _2129 = _2128 * 3.1415927410125732f;
                float _2130 = _2126 * _2126;
                float _2131 = _2130 * 3.1415927410125732f;
                float _2132 = _2127 * _2127;
                float _2133 = _2132 * 3.1415927410125732f;
                _2147 = _2129;
                _2148 = _2131;
                _2149 = _2133;
                _2150 = _2120;
              } else {
                bool _2135 = (_2121 > 9.999999747378752e-06f);
                if (_2135) {
                  float _2137 = _2117 / _2121;
                  float _2138 = _2118 / _2121;
                  float _2139 = _2119 / _2121;
                  float _2140 = _2137 * _2137;
                  float _2141 = _2140 * 3.1415927410125732f;
                  float _2142 = _2138 * _2138;
                  float _2143 = _2142 * 3.1415927410125732f;
                  float _2144 = _2139 * _2139;
                  float _2145 = _2144 * 3.1415927410125732f;
                  _2147 = _2141;
                  _2148 = _2143;
                  _2149 = _2145;
                  _2150 = _2121;
                } else {
                  _2147 = 0.0f;
                  _2148 = 0.0f;
                  _2149 = 0.0f;
                  _2150 = 0.0f;
                }
              }
              bool _2151 = (_2150 < 9.999999747378752e-06f);
              if (_2151) {
                _2154 = _1800;
                _2155 = _1801;
                _2156 = _1802;
                _2157 = _1804;
                _2158 = _1805;
                _2159 = 0.0f;
                _2160 = 0;
                _2161 = _2147;
                _2162 = _2148;
                _2163 = _2149;
              } else {
                _2154 = _1800;
                _2155 = _1801;
                _2156 = _1802;
                _2157 = _1804;
                _2158 = _1805;
                _2159 = _1449;
                _2160 = _1803;
                _2161 = _2147;
                _2162 = _2148;
                _2163 = _2149;
              }
              break;
            }
          } else {
            _2154 = _1796;
            _2155 = _1797;
            _2156 = _1798;
            _2157 = _1451;
            _2158 = _1415;
            _2159 = _1449;
            _2160 = _1455;
            _2161 = 0.0f;
            _2162 = 0.0f;
            _2163 = 0.0f;
          }
        }
        bool _2166 = (cb7_007w == 1);
        float _2167 = select(_2166, 1.0f, _2154);
        float _2168 = select(_2166, 0.0f, _2155);
        float _2169 = select(_2166, 0.0f, _2156);
        float _2170 = select(_2166, 0.0f, _2161);
        float _2171 = select(_2166, 0.0f, _2162);
        float _2172 = select(_2166, 1.0f, _2163);
        int _2173 = _2160 | _2157;
        bool _2174 = (_2173 == 0);
        bool _2175 = (_2159 < 1.0f);
        bool _2176 = _2175 || _2174;
        if (_2176) {
          float _2180 = abs(_195);
          float _2181 = abs(_196);
          float _2182 = _2181 + _2180;
          float _2183 = abs(_197);
          float _2184 = _2182 + _2183;
          float _2185 = _195 / _2184;
          float _2186 = _196 / _2184;
          float _2187 = _197 / _2184;
          bool _2188 = (_2187 > 0.0f);
          if (!_2188) {
            float _2190 = abs(_2186);
            float _2191 = abs(_2185);
            float _2192 = 1.0f - _2190;
            float _2193 = 1.0f - _2191;
            bool _2194 = (_2185 > 0.0f);
            bool _2195 = (_2186 > 0.0f);
            bool _2196 = (_2185 < 0.0f);
            bool _2197 = (_2186 < 0.0f);
            int _2198 = (int)(uint)(_2194);
            int _2199 = (int)(uint)(_2195);
            int _2200 = (int)(uint)(_2196);
            int _2201 = (int)(uint)(_2197);
            int _2202 = _2198 - _2200;
            int _2203 = _2199 - _2201;
            float _2204 = float((int)(_2202));
            float _2205 = float((int)(_2203));
            float _2206 = _2192 * _2204;
            float _2207 = _2193 * _2205;
            _2209 = _2206;
            _2210 = _2207;
          } else {
            _2209 = _2185;
            _2210 = _2186;
          }
          float _2211 = float((int)(cb7_005z));
          float _2212 = _2211 * 0.5f;
          float _2213 = _2211 + 2.0f;
          float _2214 = _2212 / _2213;
          float _2215 = _2214 * _2209;
          float _2216 = _2214 * _2210;
          float _2217 = _2215 + 0.5f;
          float _2218 = _2216 + 0.5f;
          float _2219 = _2217 * 0.0078125f;
          float _2220 = _2218 * 0.0078125f;
          float4 _2224 = t28[0].SampleLevel(s7, float3(_2219, _2220, 0.0f), 0.0f);
          float _2228 = _2224.x * 3.1415927410125732f;
          float _2229 = _2224.y * 3.1415927410125732f;
          float _2230 = _2224.z * 3.1415927410125732f;
          bool _2233 = (cb7_007w == 1);
          float _2234 = select(_2233, 0.0f, _2228);
          float _2235 = select(_2233, 1.0f, _2229);
          float _2236 = select(_2233, 0.0f, _2230);
          float _2237 = _2170 - _2234;
          float _2238 = _2171 - _2235;
          float _2239 = _2172 - _2236;
          float _2240 = _2237 * _2159;
          float _2241 = _2238 * _2159;
          float _2242 = _2239 * _2159;
          float _2243 = _2240 + _2234;
          float _2244 = _2241 + _2235;
          float _2245 = _2242 + _2236;
          bool _2246 = (_2173 != 0);
          float _2247 = select(_2246, _2158, 0.0f);
          _2249 = _2247;
          _2250 = _2243;
          _2251 = _2244;
          _2252 = _2245;
        } else {
          _2249 = _2158;
          _2250 = _2170;
          _2251 = _2171;
          _2252 = _2172;
        }
        float _2253 = _2167 - _2250;
        float _2254 = _2168 - _2251;
        float _2255 = _2169 - _2252;
        float _2256 = _2253 * _2249;
        float _2257 = _2254 * _2249;
        float _2258 = _2255 * _2249;
        float _2259 = _2256 + _2250;
        float _2260 = _2257 + _2251;
        float _2261 = _2258 + _2252;
        bool _2262 = isnan(_2259);
        bool _2263 = isnan(_2260);
        bool _2264 = isnan(_2261);
        bool _2265 = _2262 || _2263;
        bool _2266 = _2265 || _2264;
        float _2267 = select(_2266, 0.0f, _2259);
        float _2268 = select(_2266, 0.0f, _2260);
        float _2269 = select(_2266, 0.0f, _2261);
        _2271 = _2267;
        _2272 = _2268;
        _2273 = _2269;
      } else {
        _2271 = 0.0f;
        _2272 = 0.0f;
        _2273 = 0.0f;
      }
      float _2274 = _2271 * cb0_000x;
      float _2275 = _2272 * cb0_000x;
      float _2276 = _2273 * cb0_000x;
      float _2277 = _2274 + _1088;
      float _2278 = _2275 + _1089;
      float _2279 = _2276 + _1090;
      float _2289 = _275 - cb12_000x;
      float _2290 = _277 - cb12_000y;
      float _2291 = _2289 * _2289;
      float _2292 = _2290 * _2290;
      float _2293 = _2291 + _2292;
      float _2294 = sqrt(_2293);
      bool _2297 = (_2294 < cb13_035x);
      [branch]
      if (_2297) {
        bool _2301 = (cb13_034x == 0);
        if (!_2301) {
          _2304 = 0;
          while(true) {
            uint _2305 = _2304 + 37u;
            float _2309 = _275 - (cb13_raw[_2305].x);
            float _2310 = _277 - (cb13_raw[_2305].y);
            uint _2311 = _2304 + 42u;
            float _2315 = dot(float2(_2309, _2310), float2((cb13_raw[_2311].x), (cb13_raw[_2311].y)));
            float _2318 = dot(float2(_2309, _2310), float2((cb13_raw[_2311].z), (cb13_raw[_2311].w)));
            bool _2319 = (_2315 > 0.0f);
            bool _2320 = (_2318 > 0.0f);
            bool _2321 = _2319 && _2320;
            if (_2321) {
              bool _2323 = (_2315 < 1.0f);
              bool _2324 = (_2318 < 1.0f);
              bool _2325 = _2323 && _2324;
              if (!_2325) {
                int _2327 = _2304 + 1;
                bool _2330 = ((uint)_2327 < (uint)cb13_034x);
                if (_2330) {
                  _2304 = _2327;
                  continue;
                } else {
                  _2365 = 1.0f;
                }
              } else {
                bool _2332 = ((int)_2304 > (int)-1);
                if (_2332) {
                  float _2337 = cb13_034w * _2294;
                  float _2338 = max(1.0f, _2337);
                  float _2339 = cb13_034z / _2338;
                  float _2340 = min(1.0f, _2339);
                  float _2344 = float((int)(_2304));
                  float _2347 = t19.SampleLevel(s10, float3(_2315, _2318, _2344), 0.0f);
                  float _2349 = _2347.x * cb13_035w;
                  float _2350 = -0.10000000149011612f - _279;
                  float _2351 = _2350 + cb13_036x;
                  float _2352 = _2351 + _2349;
                  float _2353 = _2352 * _2340;
                  float _2354 = saturate(_2353);
                  float _2355 = 1.0f - _2354;
                  float _2357 = cb13_035y + _2294;
                  float _2359 = _2357 * cb13_035z;
                  float _2360 = saturate(_2359);
                  float _2361 = _2360 * _2354;
                  float _2362 = _2355 + _2361;
                  _2365 = _2362;
                } else {
                  _2365 = 1.0f;
                }
              }
            } else {
              int _2327 = _2304 + 1;
              bool _2330 = ((uint)_2327 < (uint)cb13_034x);
              if (_2330) {
                _2304 = _2327;
                continue;
              } else {
                _2365 = 1.0f;
              }
            }
            break;
          }
        } else {
          _2365 = 1.0f;
        }
      } else {
        _2365 = 1.0f;
      }
      float _2369 = cb12_066x * 20.0f;
      float _2375 = trunc(cb12_068x);
      int _2376 = int(_2375);
      float _2378 = trunc(cb12_068y);
      int _2379 = int(_2378);
      float _2380 = _279 - cb12_000z;
      float _2381 = _2380 * _2380;
      float _2382 = _2293 + _2381;
      float _2383 = sqrt(_2382);
      float _2385 = cb12_067x + _275;
      float _2386 = cb12_067y + _277;
      float _2387 = _2385 * 0.009999999776482582f;
      float _2388 = _2386 * 0.009999999776482582f;
      float _2389 = _279 * 0.009999999776482582f;
      float _2390 = _2387 / cb12_066x;
      float _2391 = _2388 / cb12_066x;
      float _2392 = _2389 / cb12_066x;
      float _2393 = cb12_067x * 20.0f;
      float _2394 = cb12_067y * 20.0f;
      float _2395 = _2393 + _275;
      float _2396 = _2394 + _277;
      float _2397 = _2395 * 0.009999999776482582f;
      float _2398 = _2396 * 0.009999999776482582f;
      float _2399 = _2397 / _2369;
      float _2400 = _2398 / _2369;
      float _2401 = _2389 / _2369;
      float _2402 = _2392 * cb13_000x;
      float _2403 = _2392 * cb13_000y;
      float _2404 = _2402 / cb13_000z;
      float _2405 = _2403 / cb13_000z;
      float _2406 = _2390 - _2404;
      float _2407 = _2391 - _2405;
      float _2408 = _2401 * cb13_000x;
      float _2409 = _2401 * cb13_000y;
      float _2410 = _2408 / cb13_000z;
      float _2411 = _2409 / cb13_000z;
      float _2412 = _2399 - _2410;
      float _2413 = _2400 - _2411;
      float _2414 = float((int)(_2376));
      float4 _2417 = t14.SampleLevel(s14, float3(_2406, _2407, _2414), 1.0f);
      float _2419 = float((int)(_2379));
      float4 _2420 = t14.SampleLevel(s14, float3(_2406, _2407, _2419), 1.0f);
      float _2422 = _2420.x - _2417.x;
      float _2423 = _2422 * cb12_066w;
      float _2424 = _2423 + _2417.x;
      float4 _2425 = t14.SampleLevel(s14, float3(_2412, _2413, _2414), 1.0f);
      float4 _2427 = t14.SampleLevel(s14, float3(_2412, _2413, _2419), 1.0f);
      float _2429 = _2427.x - _2425.x;
      float _2430 = _2429 * cb12_066w;
      float _2431 = cb13_000z + -0.25f;
      float _2432 = _2431 * 10.0f;
      float _2433 = saturate(_2432);
      float _2434 = _2383 + -100.0f;
      float _2435 = _2434 * 0.006666666828095913f;
      float _2436 = saturate(_2435);
      float _2437 = _2425.x - _2424;
      float _2438 = _2437 + _2430;
      float _2439 = _2438 * _2436;
      float _2440 = _2439 + _2424;
      float _2441 = _2440 * _2433;
      float _2442 = 1.0f - _2441;
      // GRAPHICS CLOUD BEGIN
#ifdef WITCHER_GRAPHICS_CUSTOM_LIGHTING
      _2442 = HartapfelSurfaceCloudShadow(float3(_275, _277, _279), _2442, float3(cb12_000x, cb12_000y, cb12_000z), asuint(hartapfel_jitter));
#else
      _2442 = GraphicsHitCloudShadow(float3(cb12_000x, cb12_000y, cb12_000z), cb12_074x,
          float3(cb13_000x, cb13_000y, cb13_000z), float3(_275, _277, _279), _2442);
#endif
      // GRAPHICS CLOUD END
      float _2443 = _2442 * _2365;
      float _2460 = cb13_003x * _275;
      float _2461 = mad(cb13_004x, _277, _2460);
      float _2462 = mad(cb13_005x, _279, _2461);
      float _2463 = _2462 + cb13_006x;
      float _2464 = cb13_003y * _275;
      float _2465 = mad(cb13_004y, _277, _2464);
      float _2466 = mad(cb13_005y, _279, _2465);
      float _2467 = _2466 + cb13_006y;
      float _2468 = cb13_003z * _275;
      float _2469 = mad(cb13_004z, _277, _2468);
      float _2470 = mad(cb13_005z, _279, _2469);
      float _2471 = _2470 + cb13_006z;
      float _2472 = abs(_2471);
      bool _2473 = !(_2472 >= 0.9990000128746033f);
      [branch]
      if (_2473) {
        float _2480 = _2463 - cb13_007x;
        float _2481 = _2463 - cb13_007y;
        float _2482 = _2463 - cb13_007z;
        float _2483 = _2463 - cb13_007w;
        float _2489 = _2467 - cb13_008x;
        float _2490 = _2467 - cb13_008y;
        float _2491 = _2467 - cb13_008z;
        float _2492 = _2467 - cb13_008w;
        float _2493 = abs(_2489);
        float _2494 = abs(_2490);
        float _2495 = abs(_2491);
        float _2496 = abs(_2492);
        float _2497 = abs(_2480);
        float _2498 = abs(_2481);
        float _2499 = abs(_2482);
        float _2500 = abs(_2483);
        float _2501 = max(_2497, _2493);
        float _2502 = max(_2498, _2494);
        float _2503 = max(_2499, _2495);
        float _2504 = max(_2500, _2496);
        bool _2510 = (_2501 < cb13_009x);
        bool _2511 = (_2502 < cb13_009y);
        bool _2512 = (_2503 < cb13_009z);
        bool _2513 = (_2504 < cb13_009w);
        float _2514 = float((bool)_2510);
        float _2515 = float((bool)_2511);
        float _2516 = float((bool)_2512);
        float _2517 = float((bool)_2513);
        bool _2520 = (cb13_014z > 0.5f);
        bool _2521 = (cb13_014z > 1.5f);
        bool _2522 = (cb13_014z > 2.5f);
        bool _2523 = (cb13_014z > 3.5f);
        float _2524 = float((bool)_2520);
        float _2525 = float((bool)_2521);
        float _2526 = float((bool)_2522);
        float _2527 = float((bool)_2523);
        float _2528 = dot(float4(_2514, _2515, _2516, _2517), float4(_2524, _2525, _2526, _2527));
        bool _2529 = (_2528 < 0.5f);
        [branch]
        if (!_2529) {
          float _2532 = _2501 / cb13_009x;
          float _2533 = _2502 / cb13_009y;
          float _2534 = _2503 / cb13_009z;
          float _2535 = _2504 / cb13_009w;
          float _2541 = _2532 + -1.0f;
          float _2542 = _2541 + cb13_016x;
          float _2543 = _2533 + -1.0f;
          float _2544 = _2543 + cb13_016y;
          float _2545 = _2534 + -1.0f;
          float _2546 = _2545 + cb13_016z;
          float _2547 = _2535 + -1.0f;
          float _2548 = _2547 + cb13_016w;
          float _2549 = _2542 / cb13_016x;
          float _2550 = _2544 / cb13_016y;
          float _2551 = _2546 / cb13_016z;
          float _2552 = _2548 / cb13_016w;
          float _2553 = saturate(_2549);
          float _2554 = saturate(_2550);
          float _2555 = saturate(_2551);
          float _2556 = saturate(_2552);
          _37[0] = _2553;
          _37[1] = _2554;
          _37[2] = _2555;
          _37[3] = _2556;
          float _2561 = cb13_014z - _2528;
          int _2562 = int(_2561);
          int _2563 = int(cb13_014z);
          int _2564 = _2563 + -1;
          uint _2565 = _2562 + 10u;
          float _2570 = (cb13_raw[_2565].z) * _2463;
          float _2571 = (cb13_raw[_2565].z) * _2467;
          float _2572 = _2570 + (cb13_raw[_2565].x);
          float _2573 = (cb13_raw[_2565].y) - _2571;
          float _2574 = float((int)(_2562));
          float _2577 = t8.SampleCmpLevelZero(s9, float3(_2572, _2573, _2574), _2471);
          float _2579 = _2577.x * _2577.x;
          float _2580 = float((int)(_2564));
          bool _2581 = (_2574 < _2580);
          float _2582 = select(_2581, 0.0f, 1.0f);
          float _2584 = _37[_2564];
          float _2585 = _2584 * _2582;
          float _2586 = _2585 + _2579;
          float _2587 = saturate(_2586);
          float _2588 = _2587 * _2443;
          bool _2589 = ((int)_2562 > (int)1);
          if (_2589) {
            _2591 = _2588;
            bool _2594 = (cb12_074y > 0.0f);
            if (!_2594) {
              float _2600 = cb7_029x * _275;
              float _2601 = cb7_029y * _277;
              float _2602 = cb7_029z * _279;
              float _2607 = _2600 + cb7_031x;
              float _2608 = _2601 + cb7_031y;
              float _2609 = _2602 + cb7_031z;
              float _2610 = abs(_2607);
              float _2611 = abs(_2608);
              float _2612 = abs(_2609);
              float _2617 = cb7_032x * _2610;
              float _2618 = cb7_032y * _2611;
              float _2619 = cb7_032z * _2612;
              float _2621 = _2617 + cb7_032w;
              float _2622 = _2618 + cb7_032w;
              float _2623 = _2619 + cb7_032w;
              float _2624 = saturate(_2621);
              float _2625 = saturate(_2622);
              float _2626 = saturate(_2623);
              float _2627 = min(_2624, _2625);
              float _2628 = _2626 * _2626;
              float _2629 = _2628 * _2627;
              float _2634 = cb7_011x * _275;
              float _2635 = cb7_011y * _277;
              float _2636 = cb7_011z * _279;
              float _2641 = _2634 + cb7_013x;
              float _2642 = _2635 + cb7_013y;
              float _2643 = _2636 + cb7_013z;
              float _2644 = abs(_2641);
              float _2645 = abs(_2642);
              float _2646 = abs(_2643);
              float _2651 = cb7_014x * _2644;
              float _2652 = cb7_014y * _2645;
              float _2653 = cb7_014z * _2646;
              float _2655 = _2651 + cb7_014w;
              float _2656 = _2652 + cb7_014w;
              float _2657 = _2653 + cb7_014w;
              float _2658 = saturate(_2655);
              float _2659 = saturate(_2656);
              float _2660 = saturate(_2657);
              float _2661 = min(_2658, _2659);
              float _2662 = _2660 * _2660;
              float _2663 = _2662 * _2661;
              bool _2664 = (_2629 > 9.999999717180685e-10f);
              int _2665 = (int)(uint)(_2664);
              bool _2666 = (_2629 < 1.0f);
              if (_2666) {
                bool _2668 = (_2663 > 9.999999717180685e-10f);
                int _2669 = (int)(uint)(_2668);
                bool _2670 = _2664 && _2668;
                if (_2670) {
                  float _2672 = _1376 + _2663;
                  bool _2673 = (_2672 > 0.5f);
                  int _2674 = (int)(uint)(_2673);
                  int _2675 = _2674 ^ 1;
                  float _2676 = select(_2673, 1.0f, 0.0f);
                  _2678 = _2676;
                  _2679 = _2674;
                  _2680 = _2675;
                } else {
                  _2678 = _2629;
                  _2679 = _2665;
                  _2680 = _2669;
                }
              } else {
                _2678 = _2629;
                _2679 = _2665;
                _2680 = 0;
              }
              bool _2681 = (_2679 == 0);
              if (!_2681) {
                float _2711 = cb7_027z * _195;
                float _2712 = cb7_027z * _196;
                float _2713 = cb7_027z * _197;
                float _2714 = _2711 + _275;
                float _2715 = _2712 + _277;
                float _2716 = _2713 + _279;
                float _2717 = _2714 * cb7_029x;
                float _2718 = _2715 * cb7_029y;
                float _2719 = _2716 * cb7_029z;
                float _2720 = _2717 + cb7_030x;
                float _2721 = _2718 + cb7_030y;
                float _2722 = _2719 + cb7_030z;
                int _2723 = int(_2720);
                int _2724 = int(_2721);
                int _2725 = int(_2722);
                uint _2726 = (uint)(cb7_020x) + -1u;
                uint _2727 = (uint)(cb7_020y) + -1u;
                uint _2728 = (uint)(cb7_020z) + -1u;
                int _2729 = max(_2723, 0);
                int _2730 = max(_2724, 0);
                int _2731 = max(_2725, 0);
                int _2732 = min(_2729, _2726);
                int _2733 = min(_2730, _2727);
                int _2734 = min(_2731, _2728);
                float _2735 = float((int)(_2732));
                float _2736 = float((int)(_2733));
                float _2737 = float((int)(_2734));
                float _2738 = _2720 - _2735;
                float _2739 = _2721 - _2736;
                float _2740 = _2722 - _2737;
                _2744 = 0.0f;
                _2745 = 0.0f;
                _2746 = 0.0f;
                _2747 = 0.0f;
                _2748 = 0.0f;
                _2749 = 0;
                while(true) {
                  int _2750 = (uint)(_2749) >> 1;
                  int _2751 = (uint)(_2749) >> 2;
                  int _2752 = _2749 & 1;
                  int _2753 = _2750 & 1;
                  int _2754 = _2751 & 1;
                  uint _2755 = _2752 + _2732;
                  uint _2756 = _2753 + _2733;
                  uint _2757 = _2754 + _2734;
                  bool _2758 = ((int)_2755 >= (int)cb7_020x);
                  bool _2759 = ((int)_2756 >= (int)cb7_020y);
                  bool _2760 = ((int)_2757 >= (int)cb7_020z);
                  bool _2761 = _2758 || _2759;
                  bool _2762 = _2760 || _2761;
                  if (!_2762) {
                    uint _2764 = (uint)(cb7_020x) - (uint)(cb7_025x);
                    uint _2765 = _2764 + _2755;
                    uint _2766 = (uint)(cb7_020y) - (uint)(cb7_025y);
                    uint _2767 = _2766 + _2756;
                    uint _2768 = (uint)(cb7_020z) - (uint)(cb7_025z);
                    uint _2769 = _2768 + _2757;
                    int _2770 = _2765 % cb7_020x;
                    int _2771 = _2767 % cb7_020y;
                    int _2772 = _2769 % cb7_020z;
                    int _2773 = _2770 * cb7_020z;
                    int _2774 = _2772 + _2773;
                    float4 _2777 = t34[1].Load(int3(_2774, _2771, 0));
                    uint _2780 = t32[1].Load(int3(_2774, _2771, 0));
                    int _2782 = _2780.x & -2;
                    bool _2783 = (_2782 == 2);
                    if (_2783) {
                      float _2786 = _2777.z * 0.44999998807907104f;
                      float _2788 = _2777.y * 0.44999998807907104f;
                      float _2790 = _2777.x * 0.44999998807907104f;
                      float _2791 = float((int)(_2752));
                      float _2792 = float((int)(_2753));
                      float _2793 = float((int)(_2754));
                      float _2794 = _2735 - cb7_028x;
                      float _2795 = _2794 + _2791;
                      float _2796 = _2795 + _2790;
                      float _2797 = _2796 * cb7_019x;
                      float _2798 = cb7_018x - _2714;
                      float _2799 = _2797 + _2798;
                      float _2800 = _2736 - cb7_028y;
                      float _2801 = _2800 + _2792;
                      float _2802 = _2801 + _2788;
                      float _2803 = _2802 * cb7_019y;
                      float _2804 = cb7_018y - _2715;
                      float _2805 = _2803 + _2804;
                      float _2806 = _2737 - cb7_028z;
                      float _2807 = _2806 + _2793;
                      float _2808 = _2807 + _2786;
                      float _2809 = _2808 * cb7_019z;
                      float _2810 = cb7_018z - _2716;
                      float _2811 = _2809 + _2810;
                      float _2812 = _2799 * _2799;
                      float _2813 = _2805 * _2805;
                      float _2814 = _2812 + _2813;
                      float _2815 = _2811 * _2811;
                      float _2816 = _2814 + _2815;
                      float _2817 = sqrt(_2816);
                      float _2818 = max(_2817, 9.999999747378752e-06f);
                      float _2819 = _2799 / _2818;
                      float _2820 = _2805 / _2818;
                      float _2821 = _2811 / _2818;
                      float _2822 = -0.0f - _2819;
                      float _2823 = -0.0f - _2820;
                      float _2824 = -0.0f - _2821;
                      float _2825 = abs(_2822);
                      float _2826 = abs(_2823);
                      float _2827 = _2826 + _2825;
                      float _2828 = abs(_2824);
                      float _2829 = _2827 + _2828;
                      float _2830 = _2822 / _2829;
                      float _2831 = _2823 / _2829;
                      float _2832 = _2824 / _2829;
                      bool _2833 = (_2832 > 0.0f);
                      if (!_2833) {
                        float _2835 = abs(_2831);
                        float _2836 = abs(_2830);
                        float _2837 = 1.0f - _2835;
                        float _2838 = 1.0f - _2836;
                        bool _2839 = (_2830 > 0.0f);
                        bool _2840 = (_2831 > 0.0f);
                        bool _2841 = (_2830 < 0.0f);
                        bool _2842 = (_2831 < 0.0f);
                        int _2843 = (int)(uint)(_2839);
                        int _2844 = (int)(uint)(_2840);
                        int _2845 = (int)(uint)(_2841);
                        int _2846 = (int)(uint)(_2842);
                        int _2847 = _2843 - _2845;
                        int _2848 = _2844 - _2846;
                        float _2849 = float((int)(_2847));
                        float _2850 = float((int)(_2848));
                        float _2851 = _2837 * _2849;
                        float _2852 = _2838 * _2850;
                        _2854 = _2851;
                        _2855 = _2852;
                      } else {
                        _2854 = _2830;
                        _2855 = _2831;
                      }
                      float _2856 = float((int)(cb7_023w));
                      float _2857 = _2856 * 0.5f;
                      float _2858 = _2856 + 2.0f;
                      float _2859 = _2857 / _2858;
                      float _2860 = float((int)(cb7_020x));
                      float _2861 = float((int)(cb7_020y));
                      float _2862 = 1.0f / _2860;
                      float _2863 = 1.0f / _2861;
                      float _2864 = float((int)(_2770));
                      float _2865 = float((int)(_2771));
                      float _2866 = _2864 + 0.5f;
                      float _2867 = _2865 + 0.5f;
                      float _2868 = _2859 * _2854;
                      float _2869 = _2859 * _2855;
                      float _2870 = _2868 + _2866;
                      float _2871 = _2869 + _2867;
                      float _2872 = _2870 * _2862;
                      float _2873 = _2871 * _2863;
                      float _2874 = float((int)(_2772));
                      float3 _2878 = t30[1].SampleLevel(s7, float3(_2872, _2873, _2874), 0.0f);
                      float _2881 = abs(cb13_000x);
                      float _2882 = abs(cb13_000y);
                      float _2883 = _2882 + _2881;
                      float _2884 = abs(cb13_000z);
                      float _2885 = _2883 + _2884;
                      float _2886 = cb13_000x / _2885;
                      float _2887 = cb13_000y / _2885;
                      float _2888 = cb13_000z / _2885;
                      bool _2889 = (_2888 > 0.0f);
                      if (!_2889) {
                        float _2891 = abs(_2887);
                        float _2892 = abs(_2886);
                        float _2893 = 1.0f - _2891;
                        float _2894 = 1.0f - _2892;
                        bool _2895 = (_2886 > 0.0f);
                        bool _2896 = (_2887 > 0.0f);
                        bool _2897 = (_2886 < 0.0f);
                        bool _2898 = (_2887 < 0.0f);
                        int _2899 = (int)(uint)(_2895);
                        int _2900 = (int)(uint)(_2896);
                        int _2901 = (int)(uint)(_2897);
                        int _2902 = (int)(uint)(_2898);
                        int _2903 = _2899 - _2901;
                        int _2904 = _2900 - _2902;
                        float _2905 = float((int)(_2903));
                        float _2906 = float((int)(_2904));
                        float _2907 = _2893 * _2905;
                        float _2908 = _2894 * _2906;
                        _2910 = _2907;
                        _2911 = _2908;
                      } else {
                        _2910 = _2886;
                        _2911 = _2887;
                      }
                      float _2912 = _2910 * _2859;
                      float _2913 = _2911 * _2859;
                      float _2914 = _2912 + _2866;
                      float _2915 = _2913 + _2867;
                      float _2916 = _2914 * _2862;
                      float _2917 = _2915 * _2863;
                      float3 _2918 = t30[1].SampleLevel(s7, float3(_2916, _2917, _2874), 0.0f);
                      float _2920 = 1.0f - _2738;
                      float _2921 = 1.0f - _2739;
                      float _2922 = 1.0f - _2740;
                      bool _2923 = (_2752 != 0);
                      bool _2924 = (_2753 != 0);
                      bool _2925 = (_2754 != 0);
                      float _2926 = select(_2923, _2738, _2920);
                      float _2927 = select(_2924, _2739, _2921);
                      float _2928 = select(_2925, _2740, _2922);
                      float _2929 = _2927 * _2926;
                      float _2930 = _2929 * _2928;
                      float _2931 = _2930 + _2748;
                      bool _2932 = (_2817 > _2878.x);
                      if (_2932) {
                        float _2934 = _2878.x * _2878.x;
                        float _2935 = _2878.y - _2934;
                        float _2936 = abs(_2935);
                        float _2937 = _2817 - _2878.x;
                        float _2938 = _2937 * _2937;
                        float _2939 = _2936 + _2938;
                        float _2940 = _2936 / _2939;
                        float _2941 = _2940 * _2930;
                        _2943 = _2941;
                      } else {
                        _2943 = _2930;
                      }
                      float _2944 = dot(float3(_2819, _2820, _2821), float3(_195, _196, _197));
                      float _2945 = _2944 * 0.5f;
                      float _2946 = _2945 + 0.5f;
                      float _2947 = saturate(_2946);
                      float _2948 = _2947 * _2943;
                      float _2949 = _2948 * _2918.z;
                      float _2950 = _2949 + _2744;
                      float _2951 = _2949 + _2745;
                      float _2952 = _2949 + _2746;
                      float _2953 = _2948 + _2747;
                      _2955 = _2950;
                      _2956 = _2951;
                      _2957 = _2952;
                      _2958 = _2953;
                      _2959 = _2931;
                    } else {
                      _2955 = _2744;
                      _2956 = _2745;
                      _2957 = _2746;
                      _2958 = _2747;
                      _2959 = _2748;
                    }
                  } else {
                    _2955 = _2744;
                    _2956 = _2745;
                    _2957 = _2746;
                    _2958 = _2747;
                    _2959 = _2748;
                  }
                  int _2960 = _2749 + 1;
                  bool _2961 = (_2960 == 8);
                  if (!_2961) {
                    _2744 = _2955;
                    _2745 = _2956;
                    _2746 = _2957;
                    _2747 = _2958;
                    _2748 = _2959;
                    _2749 = _2960;
                    continue;
                  }
                  break;
                }
                while(true) {
                  bool _2742 = (_2958 > 9.999999747378752e-06f);
                  if (_2742) {
                    float _2963 = _2955 / _2958;
                    float _2964 = _2956 / _2958;
                    float _2965 = _2957 / _2958;
                    _2973 = _2963;
                    _2974 = _2964;
                    _2975 = _2965;
                    _2976 = _2958;
                  } else {
                    bool _2967 = (_2959 > 9.999999747378752e-06f);
                    if (_2967) {
                      float _2969 = _2955 / _2959;
                      float _2970 = _2956 / _2959;
                      float _2971 = _2957 / _2959;
                      _2973 = _2969;
                      _2974 = _2970;
                      _2975 = _2971;
                      _2976 = _2959;
                    } else {
                      _2973 = 0.0f;
                      _2974 = 0.0f;
                      _2975 = 0.0f;
                      _2976 = 0.0f;
                    }
                  }
                  bool _2977 = (_2976 < 9.999999747378752e-06f);
                  if (!_2977) {
                    _2979 = _2973;
                    _2980 = _2974;
                    _2981 = _2975;
                    bool _2982 = (_2680 == 0);
                    if (!_2982) {
                      _2984 = _2979;
                      _2985 = _2980;
                      _2986 = _2981;
                      _2987 = _2680;
                      _2988 = _2679;
                      _2989 = _2678;
                      float _3022 = cb7_009z * _195;
                      float _3023 = cb7_009z * _196;
                      float _3024 = cb7_009z * _197;
                      float _3025 = _3022 + _275;
                      float _3026 = _3023 + _277;
                      float _3027 = _3024 + _279;
                      float _3028 = _3025 * cb7_011x;
                      float _3029 = _3026 * cb7_011y;
                      float _3030 = _3027 * cb7_011z;
                      float _3031 = _3028 + cb7_012x;
                      float _3032 = _3029 + cb7_012y;
                      float _3033 = _3030 + cb7_012z;
                      int _3034 = int(_3031);
                      int _3035 = int(_3032);
                      int _3036 = int(_3033);
                      uint _3037 = (uint)(cb7_002x) + -1u;
                      uint _3038 = (uint)(cb7_002y) + -1u;
                      uint _3039 = (uint)(cb7_002z) + -1u;
                      int _3040 = max(_3034, 0);
                      int _3041 = max(_3035, 0);
                      int _3042 = max(_3036, 0);
                      int _3043 = min(_3040, _3037);
                      int _3044 = min(_3041, _3038);
                      int _3045 = min(_3042, _3039);
                      float _3046 = float((int)(_3043));
                      float _3047 = float((int)(_3044));
                      float _3048 = float((int)(_3045));
                      float _3049 = _3031 - _3046;
                      float _3050 = _3032 - _3047;
                      float _3051 = _3033 - _3048;
                      _3055 = 0.0f;
                      _3056 = 0.0f;
                      _3057 = 0.0f;
                      _3058 = 0.0f;
                      _3059 = 0.0f;
                      _3060 = 0;
                      while(true) {
                        int _3061 = (uint)(_3060) >> 1;
                        int _3062 = (uint)(_3060) >> 2;
                        int _3063 = _3060 & 1;
                        int _3064 = _3061 & 1;
                        int _3065 = _3062 & 1;
                        uint _3066 = _3063 + _3043;
                        uint _3067 = _3064 + _3044;
                        uint _3068 = _3065 + _3045;
                        bool _3069 = ((int)_3066 >= (int)cb7_002x);
                        bool _3070 = ((int)_3067 >= (int)cb7_002y);
                        bool _3071 = ((int)_3068 >= (int)cb7_002z);
                        bool _3072 = _3069 || _3070;
                        bool _3073 = _3071 || _3072;
                        if (!_3073) {
                          uint _3075 = (uint)(cb7_002x) - (uint)(cb7_007x);
                          uint _3076 = _3075 + _3066;
                          uint _3077 = (uint)(cb7_002y) - (uint)(cb7_007y);
                          uint _3078 = _3077 + _3067;
                          uint _3079 = (uint)(cb7_002z) - (uint)(cb7_007z);
                          uint _3080 = _3079 + _3068;
                          int _3081 = _3076 % cb7_002x;
                          int _3082 = _3078 % cb7_002y;
                          int _3083 = _3080 % cb7_002z;
                          uint _3085 = t38.Load(int4(_3081, _3082, _3083, 0));
                          int _3087 = _3085.x & 511;
                          int _3088 = (uint)((uint)(_3085.x)) >> 9;
                          float4 _3091 = t34[0].Load(int3(_3087, _3088, 0));
                          uint _3093 = t38.Load(int4(_3081, _3082, _3083, 0));
                          int _3095 = _3093.x & 127;
                          int _3096 = (uint)((uint)(_3093.x)) >> 7;
                          int _3097 = _3096 & 127;
                          int _3098 = (uint)((uint)(_3093.x)) >> 14;
                          int _3099 = _3096 | _3093.x;
                          int _3100 = _3099 & 127;
                          int _3101 = _3100 | _3098;
                          bool _3102 = (_3101 == 0);
                          if (!_3102) {
                            float _3105 = _3091.z * 0.44999998807907104f;
                            float _3107 = _3091.y * 0.44999998807907104f;
                            float _3109 = _3091.x * 0.44999998807907104f;
                            float _3110 = float((int)(_3063));
                            float _3111 = float((int)(_3064));
                            float _3112 = float((int)(_3065));
                            float _3113 = _3046 - cb7_010x;
                            float _3114 = _3113 + _3110;
                            float _3115 = _3114 + _3109;
                            float _3116 = _3115 * cb7_001x;
                            float _3117 = cb7_000x - _3025;
                            float _3118 = _3116 + _3117;
                            float _3119 = _3047 - cb7_010y;
                            float _3120 = _3119 + _3111;
                            float _3121 = _3120 + _3107;
                            float _3122 = _3121 * cb7_001y;
                            float _3123 = cb7_000y - _3026;
                            float _3124 = _3122 + _3123;
                            float _3125 = _3048 - cb7_010z;
                            float _3126 = _3125 + _3112;
                            float _3127 = _3126 + _3105;
                            float _3128 = _3127 * cb7_001z;
                            float _3129 = cb7_000z - _3027;
                            float _3130 = _3128 + _3129;
                            float _3131 = _3118 * _3118;
                            float _3132 = _3124 * _3124;
                            float _3133 = _3131 + _3132;
                            float _3134 = _3130 * _3130;
                            float _3135 = _3133 + _3134;
                            float _3136 = sqrt(_3135);
                            float _3137 = max(_3136, 9.999999747378752e-06f);
                            float _3138 = _3118 / _3137;
                            float _3139 = _3124 / _3137;
                            float _3140 = _3130 / _3137;
                            float _3141 = -0.0f - _3138;
                            float _3142 = -0.0f - _3139;
                            float _3143 = -0.0f - _3140;
                            float _3144 = abs(_3141);
                            float _3145 = abs(_3142);
                            float _3146 = _3145 + _3144;
                            float _3147 = abs(_3143);
                            float _3148 = _3146 + _3147;
                            float _3149 = _3141 / _3148;
                            float _3150 = _3142 / _3148;
                            float _3151 = _3143 / _3148;
                            bool _3152 = (_3151 > 0.0f);
                            if (!_3152) {
                              float _3154 = abs(_3150);
                              float _3155 = abs(_3149);
                              float _3156 = 1.0f - _3154;
                              float _3157 = 1.0f - _3155;
                              bool _3158 = (_3149 > 0.0f);
                              bool _3159 = (_3150 > 0.0f);
                              bool _3160 = (_3149 < 0.0f);
                              bool _3161 = (_3150 < 0.0f);
                              int _3162 = (int)(uint)(_3158);
                              int _3163 = (int)(uint)(_3159);
                              int _3164 = (int)(uint)(_3160);
                              int _3165 = (int)(uint)(_3161);
                              int _3166 = _3162 - _3164;
                              int _3167 = _3163 - _3165;
                              float _3168 = float((int)(_3166));
                              float _3169 = float((int)(_3167));
                              float _3170 = _3156 * _3168;
                              float _3171 = _3157 * _3169;
                              _3173 = _3170;
                              _3174 = _3171;
                            } else {
                              _3173 = _3149;
                              _3174 = _3150;
                            }
                            float _3175 = float((int)(cb7_005w));
                            float _3176 = _3175 * 0.5f;
                            float _3177 = _3175 + 2.0f;
                            float _3178 = _3176 / _3177;
                            float _3179 = float((int)(_3095));
                            float _3180 = float((int)(_3097));
                            float _3181 = _3179 + 0.5f;
                            float _3182 = _3180 + 0.5f;
                            float _3183 = _3178 * _3173;
                            float _3184 = _3178 * _3174;
                            float _3185 = _3183 + _3181;
                            float _3186 = _3184 + _3182;
                            float _3187 = _3185 * 0.0078125f;
                            float _3188 = _3186 * 0.0078125f;
                            float _3189 = float((int)(_3098));
                            float3 _3193 = t30[0].SampleLevel(s7, float3(_3187, _3188, _3189), 0.0f);
                            float _3196 = abs(cb13_000x);
                            float _3197 = abs(cb13_000y);
                            float _3198 = _3197 + _3196;
                            float _3199 = abs(cb13_000z);
                            float _3200 = _3198 + _3199;
                            float _3201 = cb13_000x / _3200;
                            float _3202 = cb13_000y / _3200;
                            float _3203 = cb13_000z / _3200;
                            bool _3204 = (_3203 > 0.0f);
                            if (!_3204) {
                              float _3206 = abs(_3202);
                              float _3207 = abs(_3201);
                              float _3208 = 1.0f - _3206;
                              float _3209 = 1.0f - _3207;
                              bool _3210 = (_3201 > 0.0f);
                              bool _3211 = (_3202 > 0.0f);
                              bool _3212 = (_3201 < 0.0f);
                              bool _3213 = (_3202 < 0.0f);
                              int _3214 = (int)(uint)(_3210);
                              int _3215 = (int)(uint)(_3211);
                              int _3216 = (int)(uint)(_3212);
                              int _3217 = (int)(uint)(_3213);
                              int _3218 = _3214 - _3216;
                              int _3219 = _3215 - _3217;
                              float _3220 = float((int)(_3218));
                              float _3221 = float((int)(_3219));
                              float _3222 = _3208 * _3220;
                              float _3223 = _3209 * _3221;
                              _3225 = _3222;
                              _3226 = _3223;
                            } else {
                              _3225 = _3201;
                              _3226 = _3202;
                            }
                            float _3227 = _3225 * _3178;
                            float _3228 = _3226 * _3178;
                            float _3229 = _3227 + _3181;
                            float _3230 = _3228 + _3182;
                            float _3231 = _3229 * 0.0078125f;
                            float _3232 = _3230 * 0.0078125f;
                            float3 _3233 = t30[0].SampleLevel(s7, float3(_3231, _3232, _3189), 0.0f);
                            float _3235 = 1.0f - _3049;
                            float _3236 = 1.0f - _3050;
                            float _3237 = 1.0f - _3051;
                            bool _3238 = (_3063 != 0);
                            bool _3239 = (_3064 != 0);
                            bool _3240 = (_3065 != 0);
                            float _3241 = select(_3238, _3049, _3235);
                            float _3242 = select(_3239, _3050, _3236);
                            float _3243 = select(_3240, _3051, _3237);
                            float _3244 = _3242 * _3241;
                            float _3245 = _3244 * _3243;
                            float _3246 = _3245 + _3059;
                            bool _3247 = (_3136 > _3193.x);
                            if (_3247) {
                              float _3249 = _3193.x * _3193.x;
                              float _3250 = _3193.y - _3249;
                              float _3251 = abs(_3250);
                              float _3252 = _3136 - _3193.x;
                              float _3253 = _3252 * _3252;
                              float _3254 = _3251 + _3253;
                              float _3255 = _3251 / _3254;
                              float _3256 = _3255 * _3245;
                              _3258 = _3256;
                            } else {
                              _3258 = _3245;
                            }
                            float _3259 = dot(float3(_3138, _3139, _3140), float3(_195, _196, _197));
                            float _3260 = _3259 * 0.5f;
                            float _3261 = _3260 + 0.5f;
                            float _3262 = saturate(_3261);
                            float _3263 = _3262 * _3258;
                            float _3264 = _3263 * _3233.z;
                            float _3265 = _3264 + _3055;
                            float _3266 = _3264 + _3056;
                            float _3267 = _3264 + _3057;
                            float _3268 = _3263 + _3058;
                            _3270 = _3265;
                            _3271 = _3266;
                            _3272 = _3267;
                            _3273 = _3268;
                            _3274 = _3246;
                          } else {
                            _3270 = _3055;
                            _3271 = _3056;
                            _3272 = _3057;
                            _3273 = _3058;
                            _3274 = _3059;
                          }
                        } else {
                          _3270 = _3055;
                          _3271 = _3056;
                          _3272 = _3057;
                          _3273 = _3058;
                          _3274 = _3059;
                        }
                        int _3275 = _3060 + 1;
                        bool _3276 = (_3275 == 8);
                        if (!_3276) {
                          _3055 = _3270;
                          _3056 = _3271;
                          _3057 = _3272;
                          _3058 = _3273;
                          _3059 = _3274;
                          _3060 = _3275;
                          continue;
                        }
                        break;
                      }
                      while(true) {
                        bool _3053 = (_3273 > 9.999999747378752e-06f);
                        if (_3053) {
                          float _3278 = _3270 / _3273;
                          float _3279 = _3271 / _3273;
                          float _3280 = _3272 / _3273;
                          _3288 = _3278;
                          _3289 = _3279;
                          _3290 = _3280;
                          _3291 = _3273;
                        } else {
                          bool _3282 = (_3274 > 9.999999747378752e-06f);
                          if (_3282) {
                            float _3284 = _3270 / _3274;
                            float _3285 = _3271 / _3274;
                            float _3286 = _3272 / _3274;
                            _3288 = _3284;
                            _3289 = _3285;
                            _3290 = _3286;
                            _3291 = _3274;
                          } else {
                            _3288 = 0.0f;
                            _3289 = 0.0f;
                            _3290 = 0.0f;
                            _3291 = 0.0f;
                          }
                        }
                        bool _3292 = (_3291 < 9.999999747378752e-06f);
                        if (_3292) {
                          _3295 = _2984;
                          _3296 = _2985;
                          _3297 = _2986;
                          _3298 = _2988;
                          _3299 = _2989;
                          _3300 = 0.0f;
                          _3301 = 0;
                          _3302 = _3288;
                          _3303 = _3289;
                          _3304 = _3290;
                        } else {
                          _3295 = _2984;
                          _3296 = _2985;
                          _3297 = _2986;
                          _3298 = _2988;
                          _3299 = _2989;
                          _3300 = _2663;
                          _3301 = _2987;
                          _3302 = _3288;
                          _3303 = _3289;
                          _3304 = _3290;
                        }
                        break;
                      }
                    } else {
                      _3295 = _2979;
                      _3296 = _2980;
                      _3297 = _2981;
                      _3298 = _2679;
                      _3299 = _2678;
                      _3300 = _2663;
                      _3301 = 0;
                      _3302 = 0.0f;
                      _3303 = 0.0f;
                      _3304 = 0.0f;
                    }
                  } else {
                    _2984 = _2973;
                    _2985 = _2974;
                    _2986 = _2975;
                    _2987 = 1;
                    _2988 = 0;
                    _2989 = 0.0f;
                    float _3022 = cb7_009z * _195;
                    float _3023 = cb7_009z * _196;
                    float _3024 = cb7_009z * _197;
                    float _3025 = _3022 + _275;
                    float _3026 = _3023 + _277;
                    float _3027 = _3024 + _279;
                    float _3028 = _3025 * cb7_011x;
                    float _3029 = _3026 * cb7_011y;
                    float _3030 = _3027 * cb7_011z;
                    float _3031 = _3028 + cb7_012x;
                    float _3032 = _3029 + cb7_012y;
                    float _3033 = _3030 + cb7_012z;
                    int _3034 = int(_3031);
                    int _3035 = int(_3032);
                    int _3036 = int(_3033);
                    uint _3037 = (uint)(cb7_002x) + -1u;
                    uint _3038 = (uint)(cb7_002y) + -1u;
                    uint _3039 = (uint)(cb7_002z) + -1u;
                    int _3040 = max(_3034, 0);
                    int _3041 = max(_3035, 0);
                    int _3042 = max(_3036, 0);
                    int _3043 = min(_3040, _3037);
                    int _3044 = min(_3041, _3038);
                    int _3045 = min(_3042, _3039);
                    float _3046 = float((int)(_3043));
                    float _3047 = float((int)(_3044));
                    float _3048 = float((int)(_3045));
                    float _3049 = _3031 - _3046;
                    float _3050 = _3032 - _3047;
                    float _3051 = _3033 - _3048;
                    _3055 = 0.0f;
                    _3056 = 0.0f;
                    _3057 = 0.0f;
                    _3058 = 0.0f;
                    _3059 = 0.0f;
                    _3060 = 0;
                    while(true) {
                      int _3061 = (uint)(_3060) >> 1;
                      int _3062 = (uint)(_3060) >> 2;
                      int _3063 = _3060 & 1;
                      int _3064 = _3061 & 1;
                      int _3065 = _3062 & 1;
                      uint _3066 = _3063 + _3043;
                      uint _3067 = _3064 + _3044;
                      uint _3068 = _3065 + _3045;
                      bool _3069 = ((int)_3066 >= (int)cb7_002x);
                      bool _3070 = ((int)_3067 >= (int)cb7_002y);
                      bool _3071 = ((int)_3068 >= (int)cb7_002z);
                      bool _3072 = _3069 || _3070;
                      bool _3073 = _3071 || _3072;
                      if (!_3073) {
                        uint _3075 = (uint)(cb7_002x) - (uint)(cb7_007x);
                        uint _3076 = _3075 + _3066;
                        uint _3077 = (uint)(cb7_002y) - (uint)(cb7_007y);
                        uint _3078 = _3077 + _3067;
                        uint _3079 = (uint)(cb7_002z) - (uint)(cb7_007z);
                        uint _3080 = _3079 + _3068;
                        int _3081 = _3076 % cb7_002x;
                        int _3082 = _3078 % cb7_002y;
                        int _3083 = _3080 % cb7_002z;
                        uint _3085 = t38.Load(int4(_3081, _3082, _3083, 0));
                        int _3087 = _3085.x & 511;
                        int _3088 = (uint)((uint)(_3085.x)) >> 9;
                        float4 _3091 = t34[0].Load(int3(_3087, _3088, 0));
                        uint _3093 = t38.Load(int4(_3081, _3082, _3083, 0));
                        int _3095 = _3093.x & 127;
                        int _3096 = (uint)((uint)(_3093.x)) >> 7;
                        int _3097 = _3096 & 127;
                        int _3098 = (uint)((uint)(_3093.x)) >> 14;
                        int _3099 = _3096 | _3093.x;
                        int _3100 = _3099 & 127;
                        int _3101 = _3100 | _3098;
                        bool _3102 = (_3101 == 0);
                        if (!_3102) {
                          float _3105 = _3091.z * 0.44999998807907104f;
                          float _3107 = _3091.y * 0.44999998807907104f;
                          float _3109 = _3091.x * 0.44999998807907104f;
                          float _3110 = float((int)(_3063));
                          float _3111 = float((int)(_3064));
                          float _3112 = float((int)(_3065));
                          float _3113 = _3046 - cb7_010x;
                          float _3114 = _3113 + _3110;
                          float _3115 = _3114 + _3109;
                          float _3116 = _3115 * cb7_001x;
                          float _3117 = cb7_000x - _3025;
                          float _3118 = _3116 + _3117;
                          float _3119 = _3047 - cb7_010y;
                          float _3120 = _3119 + _3111;
                          float _3121 = _3120 + _3107;
                          float _3122 = _3121 * cb7_001y;
                          float _3123 = cb7_000y - _3026;
                          float _3124 = _3122 + _3123;
                          float _3125 = _3048 - cb7_010z;
                          float _3126 = _3125 + _3112;
                          float _3127 = _3126 + _3105;
                          float _3128 = _3127 * cb7_001z;
                          float _3129 = cb7_000z - _3027;
                          float _3130 = _3128 + _3129;
                          float _3131 = _3118 * _3118;
                          float _3132 = _3124 * _3124;
                          float _3133 = _3131 + _3132;
                          float _3134 = _3130 * _3130;
                          float _3135 = _3133 + _3134;
                          float _3136 = sqrt(_3135);
                          float _3137 = max(_3136, 9.999999747378752e-06f);
                          float _3138 = _3118 / _3137;
                          float _3139 = _3124 / _3137;
                          float _3140 = _3130 / _3137;
                          float _3141 = -0.0f - _3138;
                          float _3142 = -0.0f - _3139;
                          float _3143 = -0.0f - _3140;
                          float _3144 = abs(_3141);
                          float _3145 = abs(_3142);
                          float _3146 = _3145 + _3144;
                          float _3147 = abs(_3143);
                          float _3148 = _3146 + _3147;
                          float _3149 = _3141 / _3148;
                          float _3150 = _3142 / _3148;
                          float _3151 = _3143 / _3148;
                          bool _3152 = (_3151 > 0.0f);
                          if (!_3152) {
                            float _3154 = abs(_3150);
                            float _3155 = abs(_3149);
                            float _3156 = 1.0f - _3154;
                            float _3157 = 1.0f - _3155;
                            bool _3158 = (_3149 > 0.0f);
                            bool _3159 = (_3150 > 0.0f);
                            bool _3160 = (_3149 < 0.0f);
                            bool _3161 = (_3150 < 0.0f);
                            int _3162 = (int)(uint)(_3158);
                            int _3163 = (int)(uint)(_3159);
                            int _3164 = (int)(uint)(_3160);
                            int _3165 = (int)(uint)(_3161);
                            int _3166 = _3162 - _3164;
                            int _3167 = _3163 - _3165;
                            float _3168 = float((int)(_3166));
                            float _3169 = float((int)(_3167));
                            float _3170 = _3156 * _3168;
                            float _3171 = _3157 * _3169;
                            _3173 = _3170;
                            _3174 = _3171;
                          } else {
                            _3173 = _3149;
                            _3174 = _3150;
                          }
                          float _3175 = float((int)(cb7_005w));
                          float _3176 = _3175 * 0.5f;
                          float _3177 = _3175 + 2.0f;
                          float _3178 = _3176 / _3177;
                          float _3179 = float((int)(_3095));
                          float _3180 = float((int)(_3097));
                          float _3181 = _3179 + 0.5f;
                          float _3182 = _3180 + 0.5f;
                          float _3183 = _3178 * _3173;
                          float _3184 = _3178 * _3174;
                          float _3185 = _3183 + _3181;
                          float _3186 = _3184 + _3182;
                          float _3187 = _3185 * 0.0078125f;
                          float _3188 = _3186 * 0.0078125f;
                          float _3189 = float((int)(_3098));
                          float3 _3193 = t30[0].SampleLevel(s7, float3(_3187, _3188, _3189), 0.0f);
                          float _3196 = abs(cb13_000x);
                          float _3197 = abs(cb13_000y);
                          float _3198 = _3197 + _3196;
                          float _3199 = abs(cb13_000z);
                          float _3200 = _3198 + _3199;
                          float _3201 = cb13_000x / _3200;
                          float _3202 = cb13_000y / _3200;
                          float _3203 = cb13_000z / _3200;
                          bool _3204 = (_3203 > 0.0f);
                          if (!_3204) {
                            float _3206 = abs(_3202);
                            float _3207 = abs(_3201);
                            float _3208 = 1.0f - _3206;
                            float _3209 = 1.0f - _3207;
                            bool _3210 = (_3201 > 0.0f);
                            bool _3211 = (_3202 > 0.0f);
                            bool _3212 = (_3201 < 0.0f);
                            bool _3213 = (_3202 < 0.0f);
                            int _3214 = (int)(uint)(_3210);
                            int _3215 = (int)(uint)(_3211);
                            int _3216 = (int)(uint)(_3212);
                            int _3217 = (int)(uint)(_3213);
                            int _3218 = _3214 - _3216;
                            int _3219 = _3215 - _3217;
                            float _3220 = float((int)(_3218));
                            float _3221 = float((int)(_3219));
                            float _3222 = _3208 * _3220;
                            float _3223 = _3209 * _3221;
                            _3225 = _3222;
                            _3226 = _3223;
                          } else {
                            _3225 = _3201;
                            _3226 = _3202;
                          }
                          float _3227 = _3225 * _3178;
                          float _3228 = _3226 * _3178;
                          float _3229 = _3227 + _3181;
                          float _3230 = _3228 + _3182;
                          float _3231 = _3229 * 0.0078125f;
                          float _3232 = _3230 * 0.0078125f;
                          float3 _3233 = t30[0].SampleLevel(s7, float3(_3231, _3232, _3189), 0.0f);
                          float _3235 = 1.0f - _3049;
                          float _3236 = 1.0f - _3050;
                          float _3237 = 1.0f - _3051;
                          bool _3238 = (_3063 != 0);
                          bool _3239 = (_3064 != 0);
                          bool _3240 = (_3065 != 0);
                          float _3241 = select(_3238, _3049, _3235);
                          float _3242 = select(_3239, _3050, _3236);
                          float _3243 = select(_3240, _3051, _3237);
                          float _3244 = _3242 * _3241;
                          float _3245 = _3244 * _3243;
                          float _3246 = _3245 + _3059;
                          bool _3247 = (_3136 > _3193.x);
                          if (_3247) {
                            float _3249 = _3193.x * _3193.x;
                            float _3250 = _3193.y - _3249;
                            float _3251 = abs(_3250);
                            float _3252 = _3136 - _3193.x;
                            float _3253 = _3252 * _3252;
                            float _3254 = _3251 + _3253;
                            float _3255 = _3251 / _3254;
                            float _3256 = _3255 * _3245;
                            _3258 = _3256;
                          } else {
                            _3258 = _3245;
                          }
                          float _3259 = dot(float3(_3138, _3139, _3140), float3(_195, _196, _197));
                          float _3260 = _3259 * 0.5f;
                          float _3261 = _3260 + 0.5f;
                          float _3262 = saturate(_3261);
                          float _3263 = _3262 * _3258;
                          float _3264 = _3263 * _3233.z;
                          float _3265 = _3264 + _3055;
                          float _3266 = _3264 + _3056;
                          float _3267 = _3264 + _3057;
                          float _3268 = _3263 + _3058;
                          _3270 = _3265;
                          _3271 = _3266;
                          _3272 = _3267;
                          _3273 = _3268;
                          _3274 = _3246;
                        } else {
                          _3270 = _3055;
                          _3271 = _3056;
                          _3272 = _3057;
                          _3273 = _3058;
                          _3274 = _3059;
                        }
                      } else {
                        _3270 = _3055;
                        _3271 = _3056;
                        _3272 = _3057;
                        _3273 = _3058;
                        _3274 = _3059;
                      }
                      int _3275 = _3060 + 1;
                      bool _3276 = (_3275 == 8);
                      if (!_3276) {
                        _3055 = _3270;
                        _3056 = _3271;
                        _3057 = _3272;
                        _3058 = _3273;
                        _3059 = _3274;
                        _3060 = _3275;
                        continue;
                      }
                      break;
                    }
                    while(true) {
                      bool _3053 = (_3273 > 9.999999747378752e-06f);
                      if (_3053) {
                        float _3278 = _3270 / _3273;
                        float _3279 = _3271 / _3273;
                        float _3280 = _3272 / _3273;
                        _3288 = _3278;
                        _3289 = _3279;
                        _3290 = _3280;
                        _3291 = _3273;
                      } else {
                        bool _3282 = (_3274 > 9.999999747378752e-06f);
                        if (_3282) {
                          float _3284 = _3270 / _3274;
                          float _3285 = _3271 / _3274;
                          float _3286 = _3272 / _3274;
                          _3288 = _3284;
                          _3289 = _3285;
                          _3290 = _3286;
                          _3291 = _3274;
                        } else {
                          _3288 = 0.0f;
                          _3289 = 0.0f;
                          _3290 = 0.0f;
                          _3291 = 0.0f;
                        }
                      }
                      bool _3292 = (_3291 < 9.999999747378752e-06f);
                      if (_3292) {
                        _3295 = _2984;
                        _3296 = _2985;
                        _3297 = _2986;
                        _3298 = _2988;
                        _3299 = _2989;
                        _3300 = 0.0f;
                        _3301 = 0;
                        _3302 = _3288;
                        _3303 = _3289;
                        _3304 = _3290;
                      } else {
                        _3295 = _2984;
                        _3296 = _2985;
                        _3297 = _2986;
                        _3298 = _2988;
                        _3299 = _2989;
                        _3300 = _2663;
                        _3301 = _2987;
                        _3302 = _3288;
                        _3303 = _3289;
                        _3304 = _3290;
                      }
                      break;
                    }
                  }
                  break;
                }
              } else {
                _2979 = 0.0f;
                _2980 = 0.0f;
                _2981 = 0.0f;
                bool _2982 = (_2680 == 0);
                if (!_2982) {
                  _2984 = _2979;
                  _2985 = _2980;
                  _2986 = _2981;
                  _2987 = _2680;
                  _2988 = _2679;
                  _2989 = _2678;
                  float _3022 = cb7_009z * _195;
                  float _3023 = cb7_009z * _196;
                  float _3024 = cb7_009z * _197;
                  float _3025 = _3022 + _275;
                  float _3026 = _3023 + _277;
                  float _3027 = _3024 + _279;
                  float _3028 = _3025 * cb7_011x;
                  float _3029 = _3026 * cb7_011y;
                  float _3030 = _3027 * cb7_011z;
                  float _3031 = _3028 + cb7_012x;
                  float _3032 = _3029 + cb7_012y;
                  float _3033 = _3030 + cb7_012z;
                  int _3034 = int(_3031);
                  int _3035 = int(_3032);
                  int _3036 = int(_3033);
                  uint _3037 = (uint)(cb7_002x) + -1u;
                  uint _3038 = (uint)(cb7_002y) + -1u;
                  uint _3039 = (uint)(cb7_002z) + -1u;
                  int _3040 = max(_3034, 0);
                  int _3041 = max(_3035, 0);
                  int _3042 = max(_3036, 0);
                  int _3043 = min(_3040, _3037);
                  int _3044 = min(_3041, _3038);
                  int _3045 = min(_3042, _3039);
                  float _3046 = float((int)(_3043));
                  float _3047 = float((int)(_3044));
                  float _3048 = float((int)(_3045));
                  float _3049 = _3031 - _3046;
                  float _3050 = _3032 - _3047;
                  float _3051 = _3033 - _3048;
                  _3055 = 0.0f;
                  _3056 = 0.0f;
                  _3057 = 0.0f;
                  _3058 = 0.0f;
                  _3059 = 0.0f;
                  _3060 = 0;
                  while(true) {
                    int _3061 = (uint)(_3060) >> 1;
                    int _3062 = (uint)(_3060) >> 2;
                    int _3063 = _3060 & 1;
                    int _3064 = _3061 & 1;
                    int _3065 = _3062 & 1;
                    uint _3066 = _3063 + _3043;
                    uint _3067 = _3064 + _3044;
                    uint _3068 = _3065 + _3045;
                    bool _3069 = ((int)_3066 >= (int)cb7_002x);
                    bool _3070 = ((int)_3067 >= (int)cb7_002y);
                    bool _3071 = ((int)_3068 >= (int)cb7_002z);
                    bool _3072 = _3069 || _3070;
                    bool _3073 = _3071 || _3072;
                    if (!_3073) {
                      uint _3075 = (uint)(cb7_002x) - (uint)(cb7_007x);
                      uint _3076 = _3075 + _3066;
                      uint _3077 = (uint)(cb7_002y) - (uint)(cb7_007y);
                      uint _3078 = _3077 + _3067;
                      uint _3079 = (uint)(cb7_002z) - (uint)(cb7_007z);
                      uint _3080 = _3079 + _3068;
                      int _3081 = _3076 % cb7_002x;
                      int _3082 = _3078 % cb7_002y;
                      int _3083 = _3080 % cb7_002z;
                      uint _3085 = t38.Load(int4(_3081, _3082, _3083, 0));
                      int _3087 = _3085.x & 511;
                      int _3088 = (uint)((uint)(_3085.x)) >> 9;
                      float4 _3091 = t34[0].Load(int3(_3087, _3088, 0));
                      uint _3093 = t38.Load(int4(_3081, _3082, _3083, 0));
                      int _3095 = _3093.x & 127;
                      int _3096 = (uint)((uint)(_3093.x)) >> 7;
                      int _3097 = _3096 & 127;
                      int _3098 = (uint)((uint)(_3093.x)) >> 14;
                      int _3099 = _3096 | _3093.x;
                      int _3100 = _3099 & 127;
                      int _3101 = _3100 | _3098;
                      bool _3102 = (_3101 == 0);
                      if (!_3102) {
                        float _3105 = _3091.z * 0.44999998807907104f;
                        float _3107 = _3091.y * 0.44999998807907104f;
                        float _3109 = _3091.x * 0.44999998807907104f;
                        float _3110 = float((int)(_3063));
                        float _3111 = float((int)(_3064));
                        float _3112 = float((int)(_3065));
                        float _3113 = _3046 - cb7_010x;
                        float _3114 = _3113 + _3110;
                        float _3115 = _3114 + _3109;
                        float _3116 = _3115 * cb7_001x;
                        float _3117 = cb7_000x - _3025;
                        float _3118 = _3116 + _3117;
                        float _3119 = _3047 - cb7_010y;
                        float _3120 = _3119 + _3111;
                        float _3121 = _3120 + _3107;
                        float _3122 = _3121 * cb7_001y;
                        float _3123 = cb7_000y - _3026;
                        float _3124 = _3122 + _3123;
                        float _3125 = _3048 - cb7_010z;
                        float _3126 = _3125 + _3112;
                        float _3127 = _3126 + _3105;
                        float _3128 = _3127 * cb7_001z;
                        float _3129 = cb7_000z - _3027;
                        float _3130 = _3128 + _3129;
                        float _3131 = _3118 * _3118;
                        float _3132 = _3124 * _3124;
                        float _3133 = _3131 + _3132;
                        float _3134 = _3130 * _3130;
                        float _3135 = _3133 + _3134;
                        float _3136 = sqrt(_3135);
                        float _3137 = max(_3136, 9.999999747378752e-06f);
                        float _3138 = _3118 / _3137;
                        float _3139 = _3124 / _3137;
                        float _3140 = _3130 / _3137;
                        float _3141 = -0.0f - _3138;
                        float _3142 = -0.0f - _3139;
                        float _3143 = -0.0f - _3140;
                        float _3144 = abs(_3141);
                        float _3145 = abs(_3142);
                        float _3146 = _3145 + _3144;
                        float _3147 = abs(_3143);
                        float _3148 = _3146 + _3147;
                        float _3149 = _3141 / _3148;
                        float _3150 = _3142 / _3148;
                        float _3151 = _3143 / _3148;
                        bool _3152 = (_3151 > 0.0f);
                        if (!_3152) {
                          float _3154 = abs(_3150);
                          float _3155 = abs(_3149);
                          float _3156 = 1.0f - _3154;
                          float _3157 = 1.0f - _3155;
                          bool _3158 = (_3149 > 0.0f);
                          bool _3159 = (_3150 > 0.0f);
                          bool _3160 = (_3149 < 0.0f);
                          bool _3161 = (_3150 < 0.0f);
                          int _3162 = (int)(uint)(_3158);
                          int _3163 = (int)(uint)(_3159);
                          int _3164 = (int)(uint)(_3160);
                          int _3165 = (int)(uint)(_3161);
                          int _3166 = _3162 - _3164;
                          int _3167 = _3163 - _3165;
                          float _3168 = float((int)(_3166));
                          float _3169 = float((int)(_3167));
                          float _3170 = _3156 * _3168;
                          float _3171 = _3157 * _3169;
                          _3173 = _3170;
                          _3174 = _3171;
                        } else {
                          _3173 = _3149;
                          _3174 = _3150;
                        }
                        float _3175 = float((int)(cb7_005w));
                        float _3176 = _3175 * 0.5f;
                        float _3177 = _3175 + 2.0f;
                        float _3178 = _3176 / _3177;
                        float _3179 = float((int)(_3095));
                        float _3180 = float((int)(_3097));
                        float _3181 = _3179 + 0.5f;
                        float _3182 = _3180 + 0.5f;
                        float _3183 = _3178 * _3173;
                        float _3184 = _3178 * _3174;
                        float _3185 = _3183 + _3181;
                        float _3186 = _3184 + _3182;
                        float _3187 = _3185 * 0.0078125f;
                        float _3188 = _3186 * 0.0078125f;
                        float _3189 = float((int)(_3098));
                        float3 _3193 = t30[0].SampleLevel(s7, float3(_3187, _3188, _3189), 0.0f);
                        float _3196 = abs(cb13_000x);
                        float _3197 = abs(cb13_000y);
                        float _3198 = _3197 + _3196;
                        float _3199 = abs(cb13_000z);
                        float _3200 = _3198 + _3199;
                        float _3201 = cb13_000x / _3200;
                        float _3202 = cb13_000y / _3200;
                        float _3203 = cb13_000z / _3200;
                        bool _3204 = (_3203 > 0.0f);
                        if (!_3204) {
                          float _3206 = abs(_3202);
                          float _3207 = abs(_3201);
                          float _3208 = 1.0f - _3206;
                          float _3209 = 1.0f - _3207;
                          bool _3210 = (_3201 > 0.0f);
                          bool _3211 = (_3202 > 0.0f);
                          bool _3212 = (_3201 < 0.0f);
                          bool _3213 = (_3202 < 0.0f);
                          int _3214 = (int)(uint)(_3210);
                          int _3215 = (int)(uint)(_3211);
                          int _3216 = (int)(uint)(_3212);
                          int _3217 = (int)(uint)(_3213);
                          int _3218 = _3214 - _3216;
                          int _3219 = _3215 - _3217;
                          float _3220 = float((int)(_3218));
                          float _3221 = float((int)(_3219));
                          float _3222 = _3208 * _3220;
                          float _3223 = _3209 * _3221;
                          _3225 = _3222;
                          _3226 = _3223;
                        } else {
                          _3225 = _3201;
                          _3226 = _3202;
                        }
                        float _3227 = _3225 * _3178;
                        float _3228 = _3226 * _3178;
                        float _3229 = _3227 + _3181;
                        float _3230 = _3228 + _3182;
                        float _3231 = _3229 * 0.0078125f;
                        float _3232 = _3230 * 0.0078125f;
                        float3 _3233 = t30[0].SampleLevel(s7, float3(_3231, _3232, _3189), 0.0f);
                        float _3235 = 1.0f - _3049;
                        float _3236 = 1.0f - _3050;
                        float _3237 = 1.0f - _3051;
                        bool _3238 = (_3063 != 0);
                        bool _3239 = (_3064 != 0);
                        bool _3240 = (_3065 != 0);
                        float _3241 = select(_3238, _3049, _3235);
                        float _3242 = select(_3239, _3050, _3236);
                        float _3243 = select(_3240, _3051, _3237);
                        float _3244 = _3242 * _3241;
                        float _3245 = _3244 * _3243;
                        float _3246 = _3245 + _3059;
                        bool _3247 = (_3136 > _3193.x);
                        if (_3247) {
                          float _3249 = _3193.x * _3193.x;
                          float _3250 = _3193.y - _3249;
                          float _3251 = abs(_3250);
                          float _3252 = _3136 - _3193.x;
                          float _3253 = _3252 * _3252;
                          float _3254 = _3251 + _3253;
                          float _3255 = _3251 / _3254;
                          float _3256 = _3255 * _3245;
                          _3258 = _3256;
                        } else {
                          _3258 = _3245;
                        }
                        float _3259 = dot(float3(_3138, _3139, _3140), float3(_195, _196, _197));
                        float _3260 = _3259 * 0.5f;
                        float _3261 = _3260 + 0.5f;
                        float _3262 = saturate(_3261);
                        float _3263 = _3262 * _3258;
                        float _3264 = _3263 * _3233.z;
                        float _3265 = _3264 + _3055;
                        float _3266 = _3264 + _3056;
                        float _3267 = _3264 + _3057;
                        float _3268 = _3263 + _3058;
                        _3270 = _3265;
                        _3271 = _3266;
                        _3272 = _3267;
                        _3273 = _3268;
                        _3274 = _3246;
                      } else {
                        _3270 = _3055;
                        _3271 = _3056;
                        _3272 = _3057;
                        _3273 = _3058;
                        _3274 = _3059;
                      }
                    } else {
                      _3270 = _3055;
                      _3271 = _3056;
                      _3272 = _3057;
                      _3273 = _3058;
                      _3274 = _3059;
                    }
                    int _3275 = _3060 + 1;
                    bool _3276 = (_3275 == 8);
                    if (!_3276) {
                      _3055 = _3270;
                      _3056 = _3271;
                      _3057 = _3272;
                      _3058 = _3273;
                      _3059 = _3274;
                      _3060 = _3275;
                      continue;
                    }
                    break;
                  }
                  while(true) {
                    bool _3053 = (_3273 > 9.999999747378752e-06f);
                    if (_3053) {
                      float _3278 = _3270 / _3273;
                      float _3279 = _3271 / _3273;
                      float _3280 = _3272 / _3273;
                      _3288 = _3278;
                      _3289 = _3279;
                      _3290 = _3280;
                      _3291 = _3273;
                    } else {
                      bool _3282 = (_3274 > 9.999999747378752e-06f);
                      if (_3282) {
                        float _3284 = _3270 / _3274;
                        float _3285 = _3271 / _3274;
                        float _3286 = _3272 / _3274;
                        _3288 = _3284;
                        _3289 = _3285;
                        _3290 = _3286;
                        _3291 = _3274;
                      } else {
                        _3288 = 0.0f;
                        _3289 = 0.0f;
                        _3290 = 0.0f;
                        _3291 = 0.0f;
                      }
                    }
                    bool _3292 = (_3291 < 9.999999747378752e-06f);
                    if (_3292) {
                      _3295 = _2984;
                      _3296 = _2985;
                      _3297 = _2986;
                      _3298 = _2988;
                      _3299 = _2989;
                      _3300 = 0.0f;
                      _3301 = 0;
                      _3302 = _3288;
                      _3303 = _3289;
                      _3304 = _3290;
                    } else {
                      _3295 = _2984;
                      _3296 = _2985;
                      _3297 = _2986;
                      _3298 = _2988;
                      _3299 = _2989;
                      _3300 = _2663;
                      _3301 = _2987;
                      _3302 = _3288;
                      _3303 = _3289;
                      _3304 = _3290;
                    }
                    break;
                  }
                } else {
                  _3295 = _2979;
                  _3296 = _2980;
                  _3297 = _2981;
                  _3298 = _2679;
                  _3299 = _2678;
                  _3300 = _2663;
                  _3301 = 0;
                  _3302 = 0.0f;
                  _3303 = 0.0f;
                  _3304 = 0.0f;
                }
              }
              bool _3307 = (cb7_007w == 1);
              float _3308 = select(_3307, 1.0f, _3295);
              float _3309 = select(_3307, 0.0f, _3296);
              float _3310 = select(_3307, 0.0f, _3297);
              float _3311 = select(_3307, 0.0f, _3302);
              float _3312 = select(_3307, 0.0f, _3303);
              float _3313 = select(_3307, 1.0f, _3304);
              int _3314 = _3301 | _3298;
              bool _3315 = (_3314 == 0);
              bool _3316 = (_3300 < 1.0f);
              bool _3317 = _3316 || _3315;
              if (_3317) {
                float _3319 = dot(float3(_195, _196, _197), float3(cb13_000x, cb13_000y, cb13_000z));
                float _3320 = _3319 * 0.5f;
                float _3321 = _3320 + 0.5f;
                float _3322 = select(_3307, 0.0f, _3321);
                float _3323 = select(_3307, 1.0f, _3321);
                float _3324 = _3311 - _3322;
                float _3325 = _3312 - _3323;
                float _3326 = _3313 - _3322;
                float _3327 = _3324 * _3300;
                float _3328 = _3325 * _3300;
                float _3329 = _3326 * _3300;
                float _3330 = _3327 + _3322;
                float _3331 = _3328 + _3323;
                float _3332 = _3329 + _3322;
                bool _3333 = (_3314 != 0);
                float _3334 = select(_3333, _3299, 0.0f);
                _3336 = _3334;
                _3337 = _3330;
                _3338 = _3331;
                _3339 = _3332;
              } else {
                _3336 = _3299;
                _3337 = _3311;
                _3338 = _3312;
                _3339 = _3313;
              }
              float _3340 = _3308 - _3337;
              float _3341 = _3309 - _3338;
              float _3342 = _3310 - _3339;
              float _3343 = _3340 * _3336;
              float _3344 = _3341 * _3336;
              float _3345 = _3342 * _3336;
              float _3346 = _3343 + _3337;
              float _3347 = _3344 + _3338;
              float _3348 = _3345 + _3339;
              bool _3349 = isnan(_3346);
              bool _3350 = isnan(_3347);
              bool _3351 = isnan(_3348);
              bool _3352 = _3349 || _3350;
              bool _3353 = _3352 || _3351;
              float _3354 = select(_3353, 0.0f, _3346);
              _3356 = _3354;
            } else {
              _3356 = 1.0f;
            }
            float _3357 = _3356 * _2591;
            _3359 = _3357;
          } else {
            _3359 = _2588;
          }
        } else {
          _2591 = _2443;
          bool _2594 = (cb12_074y > 0.0f);
          if (!_2594) {
            float _2600 = cb7_029x * _275;
            float _2601 = cb7_029y * _277;
            float _2602 = cb7_029z * _279;
            float _2607 = _2600 + cb7_031x;
            float _2608 = _2601 + cb7_031y;
            float _2609 = _2602 + cb7_031z;
            float _2610 = abs(_2607);
            float _2611 = abs(_2608);
            float _2612 = abs(_2609);
            float _2617 = cb7_032x * _2610;
            float _2618 = cb7_032y * _2611;
            float _2619 = cb7_032z * _2612;
            float _2621 = _2617 + cb7_032w;
            float _2622 = _2618 + cb7_032w;
            float _2623 = _2619 + cb7_032w;
            float _2624 = saturate(_2621);
            float _2625 = saturate(_2622);
            float _2626 = saturate(_2623);
            float _2627 = min(_2624, _2625);
            float _2628 = _2626 * _2626;
            float _2629 = _2628 * _2627;
            float _2634 = cb7_011x * _275;
            float _2635 = cb7_011y * _277;
            float _2636 = cb7_011z * _279;
            float _2641 = _2634 + cb7_013x;
            float _2642 = _2635 + cb7_013y;
            float _2643 = _2636 + cb7_013z;
            float _2644 = abs(_2641);
            float _2645 = abs(_2642);
            float _2646 = abs(_2643);
            float _2651 = cb7_014x * _2644;
            float _2652 = cb7_014y * _2645;
            float _2653 = cb7_014z * _2646;
            float _2655 = _2651 + cb7_014w;
            float _2656 = _2652 + cb7_014w;
            float _2657 = _2653 + cb7_014w;
            float _2658 = saturate(_2655);
            float _2659 = saturate(_2656);
            float _2660 = saturate(_2657);
            float _2661 = min(_2658, _2659);
            float _2662 = _2660 * _2660;
            float _2663 = _2662 * _2661;
            bool _2664 = (_2629 > 9.999999717180685e-10f);
            int _2665 = (int)(uint)(_2664);
            bool _2666 = (_2629 < 1.0f);
            if (_2666) {
              bool _2668 = (_2663 > 9.999999717180685e-10f);
              int _2669 = (int)(uint)(_2668);
              bool _2670 = _2664 && _2668;
              if (_2670) {
                float _2672 = _1376 + _2663;
                bool _2673 = (_2672 > 0.5f);
                int _2674 = (int)(uint)(_2673);
                int _2675 = _2674 ^ 1;
                float _2676 = select(_2673, 1.0f, 0.0f);
                _2678 = _2676;
                _2679 = _2674;
                _2680 = _2675;
              } else {
                _2678 = _2629;
                _2679 = _2665;
                _2680 = _2669;
              }
            } else {
              _2678 = _2629;
              _2679 = _2665;
              _2680 = 0;
            }
            bool _2681 = (_2679 == 0);
            if (!_2681) {
              float _2711 = cb7_027z * _195;
              float _2712 = cb7_027z * _196;
              float _2713 = cb7_027z * _197;
              float _2714 = _2711 + _275;
              float _2715 = _2712 + _277;
              float _2716 = _2713 + _279;
              float _2717 = _2714 * cb7_029x;
              float _2718 = _2715 * cb7_029y;
              float _2719 = _2716 * cb7_029z;
              float _2720 = _2717 + cb7_030x;
              float _2721 = _2718 + cb7_030y;
              float _2722 = _2719 + cb7_030z;
              int _2723 = int(_2720);
              int _2724 = int(_2721);
              int _2725 = int(_2722);
              uint _2726 = (uint)(cb7_020x) + -1u;
              uint _2727 = (uint)(cb7_020y) + -1u;
              uint _2728 = (uint)(cb7_020z) + -1u;
              int _2729 = max(_2723, 0);
              int _2730 = max(_2724, 0);
              int _2731 = max(_2725, 0);
              int _2732 = min(_2729, _2726);
              int _2733 = min(_2730, _2727);
              int _2734 = min(_2731, _2728);
              float _2735 = float((int)(_2732));
              float _2736 = float((int)(_2733));
              float _2737 = float((int)(_2734));
              float _2738 = _2720 - _2735;
              float _2739 = _2721 - _2736;
              float _2740 = _2722 - _2737;
              _2744 = 0.0f;
              _2745 = 0.0f;
              _2746 = 0.0f;
              _2747 = 0.0f;
              _2748 = 0.0f;
              _2749 = 0;
              while(true) {
                int _2750 = (uint)(_2749) >> 1;
                int _2751 = (uint)(_2749) >> 2;
                int _2752 = _2749 & 1;
                int _2753 = _2750 & 1;
                int _2754 = _2751 & 1;
                uint _2755 = _2752 + _2732;
                uint _2756 = _2753 + _2733;
                uint _2757 = _2754 + _2734;
                bool _2758 = ((int)_2755 >= (int)cb7_020x);
                bool _2759 = ((int)_2756 >= (int)cb7_020y);
                bool _2760 = ((int)_2757 >= (int)cb7_020z);
                bool _2761 = _2758 || _2759;
                bool _2762 = _2760 || _2761;
                if (!_2762) {
                  uint _2764 = (uint)(cb7_020x) - (uint)(cb7_025x);
                  uint _2765 = _2764 + _2755;
                  uint _2766 = (uint)(cb7_020y) - (uint)(cb7_025y);
                  uint _2767 = _2766 + _2756;
                  uint _2768 = (uint)(cb7_020z) - (uint)(cb7_025z);
                  uint _2769 = _2768 + _2757;
                  int _2770 = _2765 % cb7_020x;
                  int _2771 = _2767 % cb7_020y;
                  int _2772 = _2769 % cb7_020z;
                  int _2773 = _2770 * cb7_020z;
                  int _2774 = _2772 + _2773;
                  float4 _2777 = t34[1].Load(int3(_2774, _2771, 0));
                  uint _2780 = t32[1].Load(int3(_2774, _2771, 0));
                  int _2782 = _2780.x & -2;
                  bool _2783 = (_2782 == 2);
                  if (_2783) {
                    float _2786 = _2777.z * 0.44999998807907104f;
                    float _2788 = _2777.y * 0.44999998807907104f;
                    float _2790 = _2777.x * 0.44999998807907104f;
                    float _2791 = float((int)(_2752));
                    float _2792 = float((int)(_2753));
                    float _2793 = float((int)(_2754));
                    float _2794 = _2735 - cb7_028x;
                    float _2795 = _2794 + _2791;
                    float _2796 = _2795 + _2790;
                    float _2797 = _2796 * cb7_019x;
                    float _2798 = cb7_018x - _2714;
                    float _2799 = _2797 + _2798;
                    float _2800 = _2736 - cb7_028y;
                    float _2801 = _2800 + _2792;
                    float _2802 = _2801 + _2788;
                    float _2803 = _2802 * cb7_019y;
                    float _2804 = cb7_018y - _2715;
                    float _2805 = _2803 + _2804;
                    float _2806 = _2737 - cb7_028z;
                    float _2807 = _2806 + _2793;
                    float _2808 = _2807 + _2786;
                    float _2809 = _2808 * cb7_019z;
                    float _2810 = cb7_018z - _2716;
                    float _2811 = _2809 + _2810;
                    float _2812 = _2799 * _2799;
                    float _2813 = _2805 * _2805;
                    float _2814 = _2812 + _2813;
                    float _2815 = _2811 * _2811;
                    float _2816 = _2814 + _2815;
                    float _2817 = sqrt(_2816);
                    float _2818 = max(_2817, 9.999999747378752e-06f);
                    float _2819 = _2799 / _2818;
                    float _2820 = _2805 / _2818;
                    float _2821 = _2811 / _2818;
                    float _2822 = -0.0f - _2819;
                    float _2823 = -0.0f - _2820;
                    float _2824 = -0.0f - _2821;
                    float _2825 = abs(_2822);
                    float _2826 = abs(_2823);
                    float _2827 = _2826 + _2825;
                    float _2828 = abs(_2824);
                    float _2829 = _2827 + _2828;
                    float _2830 = _2822 / _2829;
                    float _2831 = _2823 / _2829;
                    float _2832 = _2824 / _2829;
                    bool _2833 = (_2832 > 0.0f);
                    if (!_2833) {
                      float _2835 = abs(_2831);
                      float _2836 = abs(_2830);
                      float _2837 = 1.0f - _2835;
                      float _2838 = 1.0f - _2836;
                      bool _2839 = (_2830 > 0.0f);
                      bool _2840 = (_2831 > 0.0f);
                      bool _2841 = (_2830 < 0.0f);
                      bool _2842 = (_2831 < 0.0f);
                      int _2843 = (int)(uint)(_2839);
                      int _2844 = (int)(uint)(_2840);
                      int _2845 = (int)(uint)(_2841);
                      int _2846 = (int)(uint)(_2842);
                      int _2847 = _2843 - _2845;
                      int _2848 = _2844 - _2846;
                      float _2849 = float((int)(_2847));
                      float _2850 = float((int)(_2848));
                      float _2851 = _2837 * _2849;
                      float _2852 = _2838 * _2850;
                      _2854 = _2851;
                      _2855 = _2852;
                    } else {
                      _2854 = _2830;
                      _2855 = _2831;
                    }
                    float _2856 = float((int)(cb7_023w));
                    float _2857 = _2856 * 0.5f;
                    float _2858 = _2856 + 2.0f;
                    float _2859 = _2857 / _2858;
                    float _2860 = float((int)(cb7_020x));
                    float _2861 = float((int)(cb7_020y));
                    float _2862 = 1.0f / _2860;
                    float _2863 = 1.0f / _2861;
                    float _2864 = float((int)(_2770));
                    float _2865 = float((int)(_2771));
                    float _2866 = _2864 + 0.5f;
                    float _2867 = _2865 + 0.5f;
                    float _2868 = _2859 * _2854;
                    float _2869 = _2859 * _2855;
                    float _2870 = _2868 + _2866;
                    float _2871 = _2869 + _2867;
                    float _2872 = _2870 * _2862;
                    float _2873 = _2871 * _2863;
                    float _2874 = float((int)(_2772));
                    float3 _2878 = t30[1].SampleLevel(s7, float3(_2872, _2873, _2874), 0.0f);
                    float _2881 = abs(cb13_000x);
                    float _2882 = abs(cb13_000y);
                    float _2883 = _2882 + _2881;
                    float _2884 = abs(cb13_000z);
                    float _2885 = _2883 + _2884;
                    float _2886 = cb13_000x / _2885;
                    float _2887 = cb13_000y / _2885;
                    float _2888 = cb13_000z / _2885;
                    bool _2889 = (_2888 > 0.0f);
                    if (!_2889) {
                      float _2891 = abs(_2887);
                      float _2892 = abs(_2886);
                      float _2893 = 1.0f - _2891;
                      float _2894 = 1.0f - _2892;
                      bool _2895 = (_2886 > 0.0f);
                      bool _2896 = (_2887 > 0.0f);
                      bool _2897 = (_2886 < 0.0f);
                      bool _2898 = (_2887 < 0.0f);
                      int _2899 = (int)(uint)(_2895);
                      int _2900 = (int)(uint)(_2896);
                      int _2901 = (int)(uint)(_2897);
                      int _2902 = (int)(uint)(_2898);
                      int _2903 = _2899 - _2901;
                      int _2904 = _2900 - _2902;
                      float _2905 = float((int)(_2903));
                      float _2906 = float((int)(_2904));
                      float _2907 = _2893 * _2905;
                      float _2908 = _2894 * _2906;
                      _2910 = _2907;
                      _2911 = _2908;
                    } else {
                      _2910 = _2886;
                      _2911 = _2887;
                    }
                    float _2912 = _2910 * _2859;
                    float _2913 = _2911 * _2859;
                    float _2914 = _2912 + _2866;
                    float _2915 = _2913 + _2867;
                    float _2916 = _2914 * _2862;
                    float _2917 = _2915 * _2863;
                    float3 _2918 = t30[1].SampleLevel(s7, float3(_2916, _2917, _2874), 0.0f);
                    float _2920 = 1.0f - _2738;
                    float _2921 = 1.0f - _2739;
                    float _2922 = 1.0f - _2740;
                    bool _2923 = (_2752 != 0);
                    bool _2924 = (_2753 != 0);
                    bool _2925 = (_2754 != 0);
                    float _2926 = select(_2923, _2738, _2920);
                    float _2927 = select(_2924, _2739, _2921);
                    float _2928 = select(_2925, _2740, _2922);
                    float _2929 = _2927 * _2926;
                    float _2930 = _2929 * _2928;
                    float _2931 = _2930 + _2748;
                    bool _2932 = (_2817 > _2878.x);
                    if (_2932) {
                      float _2934 = _2878.x * _2878.x;
                      float _2935 = _2878.y - _2934;
                      float _2936 = abs(_2935);
                      float _2937 = _2817 - _2878.x;
                      float _2938 = _2937 * _2937;
                      float _2939 = _2936 + _2938;
                      float _2940 = _2936 / _2939;
                      float _2941 = _2940 * _2930;
                      _2943 = _2941;
                    } else {
                      _2943 = _2930;
                    }
                    float _2944 = dot(float3(_2819, _2820, _2821), float3(_195, _196, _197));
                    float _2945 = _2944 * 0.5f;
                    float _2946 = _2945 + 0.5f;
                    float _2947 = saturate(_2946);
                    float _2948 = _2947 * _2943;
                    float _2949 = _2948 * _2918.z;
                    float _2950 = _2949 + _2744;
                    float _2951 = _2949 + _2745;
                    float _2952 = _2949 + _2746;
                    float _2953 = _2948 + _2747;
                    _2955 = _2950;
                    _2956 = _2951;
                    _2957 = _2952;
                    _2958 = _2953;
                    _2959 = _2931;
                  } else {
                    _2955 = _2744;
                    _2956 = _2745;
                    _2957 = _2746;
                    _2958 = _2747;
                    _2959 = _2748;
                  }
                } else {
                  _2955 = _2744;
                  _2956 = _2745;
                  _2957 = _2746;
                  _2958 = _2747;
                  _2959 = _2748;
                }
                int _2960 = _2749 + 1;
                bool _2961 = (_2960 == 8);
                if (!_2961) {
                  _2744 = _2955;
                  _2745 = _2956;
                  _2746 = _2957;
                  _2747 = _2958;
                  _2748 = _2959;
                  _2749 = _2960;
                  continue;
                }
                break;
              }
              while(true) {
                bool _2742 = (_2958 > 9.999999747378752e-06f);
                if (_2742) {
                  float _2963 = _2955 / _2958;
                  float _2964 = _2956 / _2958;
                  float _2965 = _2957 / _2958;
                  _2973 = _2963;
                  _2974 = _2964;
                  _2975 = _2965;
                  _2976 = _2958;
                } else {
                  bool _2967 = (_2959 > 9.999999747378752e-06f);
                  if (_2967) {
                    float _2969 = _2955 / _2959;
                    float _2970 = _2956 / _2959;
                    float _2971 = _2957 / _2959;
                    _2973 = _2969;
                    _2974 = _2970;
                    _2975 = _2971;
                    _2976 = _2959;
                  } else {
                    _2973 = 0.0f;
                    _2974 = 0.0f;
                    _2975 = 0.0f;
                    _2976 = 0.0f;
                  }
                }
                bool _2977 = (_2976 < 9.999999747378752e-06f);
                if (!_2977) {
                  _2979 = _2973;
                  _2980 = _2974;
                  _2981 = _2975;
                  bool _2982 = (_2680 == 0);
                  if (!_2982) {
                    _2984 = _2979;
                    _2985 = _2980;
                    _2986 = _2981;
                    _2987 = _2680;
                    _2988 = _2679;
                    _2989 = _2678;
                    float _3022 = cb7_009z * _195;
                    float _3023 = cb7_009z * _196;
                    float _3024 = cb7_009z * _197;
                    float _3025 = _3022 + _275;
                    float _3026 = _3023 + _277;
                    float _3027 = _3024 + _279;
                    float _3028 = _3025 * cb7_011x;
                    float _3029 = _3026 * cb7_011y;
                    float _3030 = _3027 * cb7_011z;
                    float _3031 = _3028 + cb7_012x;
                    float _3032 = _3029 + cb7_012y;
                    float _3033 = _3030 + cb7_012z;
                    int _3034 = int(_3031);
                    int _3035 = int(_3032);
                    int _3036 = int(_3033);
                    uint _3037 = (uint)(cb7_002x) + -1u;
                    uint _3038 = (uint)(cb7_002y) + -1u;
                    uint _3039 = (uint)(cb7_002z) + -1u;
                    int _3040 = max(_3034, 0);
                    int _3041 = max(_3035, 0);
                    int _3042 = max(_3036, 0);
                    int _3043 = min(_3040, _3037);
                    int _3044 = min(_3041, _3038);
                    int _3045 = min(_3042, _3039);
                    float _3046 = float((int)(_3043));
                    float _3047 = float((int)(_3044));
                    float _3048 = float((int)(_3045));
                    float _3049 = _3031 - _3046;
                    float _3050 = _3032 - _3047;
                    float _3051 = _3033 - _3048;
                    _3055 = 0.0f;
                    _3056 = 0.0f;
                    _3057 = 0.0f;
                    _3058 = 0.0f;
                    _3059 = 0.0f;
                    _3060 = 0;
                    while(true) {
                      int _3061 = (uint)(_3060) >> 1;
                      int _3062 = (uint)(_3060) >> 2;
                      int _3063 = _3060 & 1;
                      int _3064 = _3061 & 1;
                      int _3065 = _3062 & 1;
                      uint _3066 = _3063 + _3043;
                      uint _3067 = _3064 + _3044;
                      uint _3068 = _3065 + _3045;
                      bool _3069 = ((int)_3066 >= (int)cb7_002x);
                      bool _3070 = ((int)_3067 >= (int)cb7_002y);
                      bool _3071 = ((int)_3068 >= (int)cb7_002z);
                      bool _3072 = _3069 || _3070;
                      bool _3073 = _3071 || _3072;
                      if (!_3073) {
                        uint _3075 = (uint)(cb7_002x) - (uint)(cb7_007x);
                        uint _3076 = _3075 + _3066;
                        uint _3077 = (uint)(cb7_002y) - (uint)(cb7_007y);
                        uint _3078 = _3077 + _3067;
                        uint _3079 = (uint)(cb7_002z) - (uint)(cb7_007z);
                        uint _3080 = _3079 + _3068;
                        int _3081 = _3076 % cb7_002x;
                        int _3082 = _3078 % cb7_002y;
                        int _3083 = _3080 % cb7_002z;
                        uint _3085 = t38.Load(int4(_3081, _3082, _3083, 0));
                        int _3087 = _3085.x & 511;
                        int _3088 = (uint)((uint)(_3085.x)) >> 9;
                        float4 _3091 = t34[0].Load(int3(_3087, _3088, 0));
                        uint _3093 = t38.Load(int4(_3081, _3082, _3083, 0));
                        int _3095 = _3093.x & 127;
                        int _3096 = (uint)((uint)(_3093.x)) >> 7;
                        int _3097 = _3096 & 127;
                        int _3098 = (uint)((uint)(_3093.x)) >> 14;
                        int _3099 = _3096 | _3093.x;
                        int _3100 = _3099 & 127;
                        int _3101 = _3100 | _3098;
                        bool _3102 = (_3101 == 0);
                        if (!_3102) {
                          float _3105 = _3091.z * 0.44999998807907104f;
                          float _3107 = _3091.y * 0.44999998807907104f;
                          float _3109 = _3091.x * 0.44999998807907104f;
                          float _3110 = float((int)(_3063));
                          float _3111 = float((int)(_3064));
                          float _3112 = float((int)(_3065));
                          float _3113 = _3046 - cb7_010x;
                          float _3114 = _3113 + _3110;
                          float _3115 = _3114 + _3109;
                          float _3116 = _3115 * cb7_001x;
                          float _3117 = cb7_000x - _3025;
                          float _3118 = _3116 + _3117;
                          float _3119 = _3047 - cb7_010y;
                          float _3120 = _3119 + _3111;
                          float _3121 = _3120 + _3107;
                          float _3122 = _3121 * cb7_001y;
                          float _3123 = cb7_000y - _3026;
                          float _3124 = _3122 + _3123;
                          float _3125 = _3048 - cb7_010z;
                          float _3126 = _3125 + _3112;
                          float _3127 = _3126 + _3105;
                          float _3128 = _3127 * cb7_001z;
                          float _3129 = cb7_000z - _3027;
                          float _3130 = _3128 + _3129;
                          float _3131 = _3118 * _3118;
                          float _3132 = _3124 * _3124;
                          float _3133 = _3131 + _3132;
                          float _3134 = _3130 * _3130;
                          float _3135 = _3133 + _3134;
                          float _3136 = sqrt(_3135);
                          float _3137 = max(_3136, 9.999999747378752e-06f);
                          float _3138 = _3118 / _3137;
                          float _3139 = _3124 / _3137;
                          float _3140 = _3130 / _3137;
                          float _3141 = -0.0f - _3138;
                          float _3142 = -0.0f - _3139;
                          float _3143 = -0.0f - _3140;
                          float _3144 = abs(_3141);
                          float _3145 = abs(_3142);
                          float _3146 = _3145 + _3144;
                          float _3147 = abs(_3143);
                          float _3148 = _3146 + _3147;
                          float _3149 = _3141 / _3148;
                          float _3150 = _3142 / _3148;
                          float _3151 = _3143 / _3148;
                          bool _3152 = (_3151 > 0.0f);
                          if (!_3152) {
                            float _3154 = abs(_3150);
                            float _3155 = abs(_3149);
                            float _3156 = 1.0f - _3154;
                            float _3157 = 1.0f - _3155;
                            bool _3158 = (_3149 > 0.0f);
                            bool _3159 = (_3150 > 0.0f);
                            bool _3160 = (_3149 < 0.0f);
                            bool _3161 = (_3150 < 0.0f);
                            int _3162 = (int)(uint)(_3158);
                            int _3163 = (int)(uint)(_3159);
                            int _3164 = (int)(uint)(_3160);
                            int _3165 = (int)(uint)(_3161);
                            int _3166 = _3162 - _3164;
                            int _3167 = _3163 - _3165;
                            float _3168 = float((int)(_3166));
                            float _3169 = float((int)(_3167));
                            float _3170 = _3156 * _3168;
                            float _3171 = _3157 * _3169;
                            _3173 = _3170;
                            _3174 = _3171;
                          } else {
                            _3173 = _3149;
                            _3174 = _3150;
                          }
                          float _3175 = float((int)(cb7_005w));
                          float _3176 = _3175 * 0.5f;
                          float _3177 = _3175 + 2.0f;
                          float _3178 = _3176 / _3177;
                          float _3179 = float((int)(_3095));
                          float _3180 = float((int)(_3097));
                          float _3181 = _3179 + 0.5f;
                          float _3182 = _3180 + 0.5f;
                          float _3183 = _3178 * _3173;
                          float _3184 = _3178 * _3174;
                          float _3185 = _3183 + _3181;
                          float _3186 = _3184 + _3182;
                          float _3187 = _3185 * 0.0078125f;
                          float _3188 = _3186 * 0.0078125f;
                          float _3189 = float((int)(_3098));
                          float3 _3193 = t30[0].SampleLevel(s7, float3(_3187, _3188, _3189), 0.0f);
                          float _3196 = abs(cb13_000x);
                          float _3197 = abs(cb13_000y);
                          float _3198 = _3197 + _3196;
                          float _3199 = abs(cb13_000z);
                          float _3200 = _3198 + _3199;
                          float _3201 = cb13_000x / _3200;
                          float _3202 = cb13_000y / _3200;
                          float _3203 = cb13_000z / _3200;
                          bool _3204 = (_3203 > 0.0f);
                          if (!_3204) {
                            float _3206 = abs(_3202);
                            float _3207 = abs(_3201);
                            float _3208 = 1.0f - _3206;
                            float _3209 = 1.0f - _3207;
                            bool _3210 = (_3201 > 0.0f);
                            bool _3211 = (_3202 > 0.0f);
                            bool _3212 = (_3201 < 0.0f);
                            bool _3213 = (_3202 < 0.0f);
                            int _3214 = (int)(uint)(_3210);
                            int _3215 = (int)(uint)(_3211);
                            int _3216 = (int)(uint)(_3212);
                            int _3217 = (int)(uint)(_3213);
                            int _3218 = _3214 - _3216;
                            int _3219 = _3215 - _3217;
                            float _3220 = float((int)(_3218));
                            float _3221 = float((int)(_3219));
                            float _3222 = _3208 * _3220;
                            float _3223 = _3209 * _3221;
                            _3225 = _3222;
                            _3226 = _3223;
                          } else {
                            _3225 = _3201;
                            _3226 = _3202;
                          }
                          float _3227 = _3225 * _3178;
                          float _3228 = _3226 * _3178;
                          float _3229 = _3227 + _3181;
                          float _3230 = _3228 + _3182;
                          float _3231 = _3229 * 0.0078125f;
                          float _3232 = _3230 * 0.0078125f;
                          float3 _3233 = t30[0].SampleLevel(s7, float3(_3231, _3232, _3189), 0.0f);
                          float _3235 = 1.0f - _3049;
                          float _3236 = 1.0f - _3050;
                          float _3237 = 1.0f - _3051;
                          bool _3238 = (_3063 != 0);
                          bool _3239 = (_3064 != 0);
                          bool _3240 = (_3065 != 0);
                          float _3241 = select(_3238, _3049, _3235);
                          float _3242 = select(_3239, _3050, _3236);
                          float _3243 = select(_3240, _3051, _3237);
                          float _3244 = _3242 * _3241;
                          float _3245 = _3244 * _3243;
                          float _3246 = _3245 + _3059;
                          bool _3247 = (_3136 > _3193.x);
                          if (_3247) {
                            float _3249 = _3193.x * _3193.x;
                            float _3250 = _3193.y - _3249;
                            float _3251 = abs(_3250);
                            float _3252 = _3136 - _3193.x;
                            float _3253 = _3252 * _3252;
                            float _3254 = _3251 + _3253;
                            float _3255 = _3251 / _3254;
                            float _3256 = _3255 * _3245;
                            _3258 = _3256;
                          } else {
                            _3258 = _3245;
                          }
                          float _3259 = dot(float3(_3138, _3139, _3140), float3(_195, _196, _197));
                          float _3260 = _3259 * 0.5f;
                          float _3261 = _3260 + 0.5f;
                          float _3262 = saturate(_3261);
                          float _3263 = _3262 * _3258;
                          float _3264 = _3263 * _3233.z;
                          float _3265 = _3264 + _3055;
                          float _3266 = _3264 + _3056;
                          float _3267 = _3264 + _3057;
                          float _3268 = _3263 + _3058;
                          _3270 = _3265;
                          _3271 = _3266;
                          _3272 = _3267;
                          _3273 = _3268;
                          _3274 = _3246;
                        } else {
                          _3270 = _3055;
                          _3271 = _3056;
                          _3272 = _3057;
                          _3273 = _3058;
                          _3274 = _3059;
                        }
                      } else {
                        _3270 = _3055;
                        _3271 = _3056;
                        _3272 = _3057;
                        _3273 = _3058;
                        _3274 = _3059;
                      }
                      int _3275 = _3060 + 1;
                      bool _3276 = (_3275 == 8);
                      if (!_3276) {
                        _3055 = _3270;
                        _3056 = _3271;
                        _3057 = _3272;
                        _3058 = _3273;
                        _3059 = _3274;
                        _3060 = _3275;
                        continue;
                      }
                      break;
                    }
                    while(true) {
                      bool _3053 = (_3273 > 9.999999747378752e-06f);
                      if (_3053) {
                        float _3278 = _3270 / _3273;
                        float _3279 = _3271 / _3273;
                        float _3280 = _3272 / _3273;
                        _3288 = _3278;
                        _3289 = _3279;
                        _3290 = _3280;
                        _3291 = _3273;
                      } else {
                        bool _3282 = (_3274 > 9.999999747378752e-06f);
                        if (_3282) {
                          float _3284 = _3270 / _3274;
                          float _3285 = _3271 / _3274;
                          float _3286 = _3272 / _3274;
                          _3288 = _3284;
                          _3289 = _3285;
                          _3290 = _3286;
                          _3291 = _3274;
                        } else {
                          _3288 = 0.0f;
                          _3289 = 0.0f;
                          _3290 = 0.0f;
                          _3291 = 0.0f;
                        }
                      }
                      bool _3292 = (_3291 < 9.999999747378752e-06f);
                      if (_3292) {
                        _3295 = _2984;
                        _3296 = _2985;
                        _3297 = _2986;
                        _3298 = _2988;
                        _3299 = _2989;
                        _3300 = 0.0f;
                        _3301 = 0;
                        _3302 = _3288;
                        _3303 = _3289;
                        _3304 = _3290;
                      } else {
                        _3295 = _2984;
                        _3296 = _2985;
                        _3297 = _2986;
                        _3298 = _2988;
                        _3299 = _2989;
                        _3300 = _2663;
                        _3301 = _2987;
                        _3302 = _3288;
                        _3303 = _3289;
                        _3304 = _3290;
                      }
                      break;
                    }
                  } else {
                    _3295 = _2979;
                    _3296 = _2980;
                    _3297 = _2981;
                    _3298 = _2679;
                    _3299 = _2678;
                    _3300 = _2663;
                    _3301 = 0;
                    _3302 = 0.0f;
                    _3303 = 0.0f;
                    _3304 = 0.0f;
                  }
                } else {
                  _2984 = _2973;
                  _2985 = _2974;
                  _2986 = _2975;
                  _2987 = 1;
                  _2988 = 0;
                  _2989 = 0.0f;
                  float _3022 = cb7_009z * _195;
                  float _3023 = cb7_009z * _196;
                  float _3024 = cb7_009z * _197;
                  float _3025 = _3022 + _275;
                  float _3026 = _3023 + _277;
                  float _3027 = _3024 + _279;
                  float _3028 = _3025 * cb7_011x;
                  float _3029 = _3026 * cb7_011y;
                  float _3030 = _3027 * cb7_011z;
                  float _3031 = _3028 + cb7_012x;
                  float _3032 = _3029 + cb7_012y;
                  float _3033 = _3030 + cb7_012z;
                  int _3034 = int(_3031);
                  int _3035 = int(_3032);
                  int _3036 = int(_3033);
                  uint _3037 = (uint)(cb7_002x) + -1u;
                  uint _3038 = (uint)(cb7_002y) + -1u;
                  uint _3039 = (uint)(cb7_002z) + -1u;
                  int _3040 = max(_3034, 0);
                  int _3041 = max(_3035, 0);
                  int _3042 = max(_3036, 0);
                  int _3043 = min(_3040, _3037);
                  int _3044 = min(_3041, _3038);
                  int _3045 = min(_3042, _3039);
                  float _3046 = float((int)(_3043));
                  float _3047 = float((int)(_3044));
                  float _3048 = float((int)(_3045));
                  float _3049 = _3031 - _3046;
                  float _3050 = _3032 - _3047;
                  float _3051 = _3033 - _3048;
                  _3055 = 0.0f;
                  _3056 = 0.0f;
                  _3057 = 0.0f;
                  _3058 = 0.0f;
                  _3059 = 0.0f;
                  _3060 = 0;
                  while(true) {
                    int _3061 = (uint)(_3060) >> 1;
                    int _3062 = (uint)(_3060) >> 2;
                    int _3063 = _3060 & 1;
                    int _3064 = _3061 & 1;
                    int _3065 = _3062 & 1;
                    uint _3066 = _3063 + _3043;
                    uint _3067 = _3064 + _3044;
                    uint _3068 = _3065 + _3045;
                    bool _3069 = ((int)_3066 >= (int)cb7_002x);
                    bool _3070 = ((int)_3067 >= (int)cb7_002y);
                    bool _3071 = ((int)_3068 >= (int)cb7_002z);
                    bool _3072 = _3069 || _3070;
                    bool _3073 = _3071 || _3072;
                    if (!_3073) {
                      uint _3075 = (uint)(cb7_002x) - (uint)(cb7_007x);
                      uint _3076 = _3075 + _3066;
                      uint _3077 = (uint)(cb7_002y) - (uint)(cb7_007y);
                      uint _3078 = _3077 + _3067;
                      uint _3079 = (uint)(cb7_002z) - (uint)(cb7_007z);
                      uint _3080 = _3079 + _3068;
                      int _3081 = _3076 % cb7_002x;
                      int _3082 = _3078 % cb7_002y;
                      int _3083 = _3080 % cb7_002z;
                      uint _3085 = t38.Load(int4(_3081, _3082, _3083, 0));
                      int _3087 = _3085.x & 511;
                      int _3088 = (uint)((uint)(_3085.x)) >> 9;
                      float4 _3091 = t34[0].Load(int3(_3087, _3088, 0));
                      uint _3093 = t38.Load(int4(_3081, _3082, _3083, 0));
                      int _3095 = _3093.x & 127;
                      int _3096 = (uint)((uint)(_3093.x)) >> 7;
                      int _3097 = _3096 & 127;
                      int _3098 = (uint)((uint)(_3093.x)) >> 14;
                      int _3099 = _3096 | _3093.x;
                      int _3100 = _3099 & 127;
                      int _3101 = _3100 | _3098;
                      bool _3102 = (_3101 == 0);
                      if (!_3102) {
                        float _3105 = _3091.z * 0.44999998807907104f;
                        float _3107 = _3091.y * 0.44999998807907104f;
                        float _3109 = _3091.x * 0.44999998807907104f;
                        float _3110 = float((int)(_3063));
                        float _3111 = float((int)(_3064));
                        float _3112 = float((int)(_3065));
                        float _3113 = _3046 - cb7_010x;
                        float _3114 = _3113 + _3110;
                        float _3115 = _3114 + _3109;
                        float _3116 = _3115 * cb7_001x;
                        float _3117 = cb7_000x - _3025;
                        float _3118 = _3116 + _3117;
                        float _3119 = _3047 - cb7_010y;
                        float _3120 = _3119 + _3111;
                        float _3121 = _3120 + _3107;
                        float _3122 = _3121 * cb7_001y;
                        float _3123 = cb7_000y - _3026;
                        float _3124 = _3122 + _3123;
                        float _3125 = _3048 - cb7_010z;
                        float _3126 = _3125 + _3112;
                        float _3127 = _3126 + _3105;
                        float _3128 = _3127 * cb7_001z;
                        float _3129 = cb7_000z - _3027;
                        float _3130 = _3128 + _3129;
                        float _3131 = _3118 * _3118;
                        float _3132 = _3124 * _3124;
                        float _3133 = _3131 + _3132;
                        float _3134 = _3130 * _3130;
                        float _3135 = _3133 + _3134;
                        float _3136 = sqrt(_3135);
                        float _3137 = max(_3136, 9.999999747378752e-06f);
                        float _3138 = _3118 / _3137;
                        float _3139 = _3124 / _3137;
                        float _3140 = _3130 / _3137;
                        float _3141 = -0.0f - _3138;
                        float _3142 = -0.0f - _3139;
                        float _3143 = -0.0f - _3140;
                        float _3144 = abs(_3141);
                        float _3145 = abs(_3142);
                        float _3146 = _3145 + _3144;
                        float _3147 = abs(_3143);
                        float _3148 = _3146 + _3147;
                        float _3149 = _3141 / _3148;
                        float _3150 = _3142 / _3148;
                        float _3151 = _3143 / _3148;
                        bool _3152 = (_3151 > 0.0f);
                        if (!_3152) {
                          float _3154 = abs(_3150);
                          float _3155 = abs(_3149);
                          float _3156 = 1.0f - _3154;
                          float _3157 = 1.0f - _3155;
                          bool _3158 = (_3149 > 0.0f);
                          bool _3159 = (_3150 > 0.0f);
                          bool _3160 = (_3149 < 0.0f);
                          bool _3161 = (_3150 < 0.0f);
                          int _3162 = (int)(uint)(_3158);
                          int _3163 = (int)(uint)(_3159);
                          int _3164 = (int)(uint)(_3160);
                          int _3165 = (int)(uint)(_3161);
                          int _3166 = _3162 - _3164;
                          int _3167 = _3163 - _3165;
                          float _3168 = float((int)(_3166));
                          float _3169 = float((int)(_3167));
                          float _3170 = _3156 * _3168;
                          float _3171 = _3157 * _3169;
                          _3173 = _3170;
                          _3174 = _3171;
                        } else {
                          _3173 = _3149;
                          _3174 = _3150;
                        }
                        float _3175 = float((int)(cb7_005w));
                        float _3176 = _3175 * 0.5f;
                        float _3177 = _3175 + 2.0f;
                        float _3178 = _3176 / _3177;
                        float _3179 = float((int)(_3095));
                        float _3180 = float((int)(_3097));
                        float _3181 = _3179 + 0.5f;
                        float _3182 = _3180 + 0.5f;
                        float _3183 = _3178 * _3173;
                        float _3184 = _3178 * _3174;
                        float _3185 = _3183 + _3181;
                        float _3186 = _3184 + _3182;
                        float _3187 = _3185 * 0.0078125f;
                        float _3188 = _3186 * 0.0078125f;
                        float _3189 = float((int)(_3098));
                        float3 _3193 = t30[0].SampleLevel(s7, float3(_3187, _3188, _3189), 0.0f);
                        float _3196 = abs(cb13_000x);
                        float _3197 = abs(cb13_000y);
                        float _3198 = _3197 + _3196;
                        float _3199 = abs(cb13_000z);
                        float _3200 = _3198 + _3199;
                        float _3201 = cb13_000x / _3200;
                        float _3202 = cb13_000y / _3200;
                        float _3203 = cb13_000z / _3200;
                        bool _3204 = (_3203 > 0.0f);
                        if (!_3204) {
                          float _3206 = abs(_3202);
                          float _3207 = abs(_3201);
                          float _3208 = 1.0f - _3206;
                          float _3209 = 1.0f - _3207;
                          bool _3210 = (_3201 > 0.0f);
                          bool _3211 = (_3202 > 0.0f);
                          bool _3212 = (_3201 < 0.0f);
                          bool _3213 = (_3202 < 0.0f);
                          int _3214 = (int)(uint)(_3210);
                          int _3215 = (int)(uint)(_3211);
                          int _3216 = (int)(uint)(_3212);
                          int _3217 = (int)(uint)(_3213);
                          int _3218 = _3214 - _3216;
                          int _3219 = _3215 - _3217;
                          float _3220 = float((int)(_3218));
                          float _3221 = float((int)(_3219));
                          float _3222 = _3208 * _3220;
                          float _3223 = _3209 * _3221;
                          _3225 = _3222;
                          _3226 = _3223;
                        } else {
                          _3225 = _3201;
                          _3226 = _3202;
                        }
                        float _3227 = _3225 * _3178;
                        float _3228 = _3226 * _3178;
                        float _3229 = _3227 + _3181;
                        float _3230 = _3228 + _3182;
                        float _3231 = _3229 * 0.0078125f;
                        float _3232 = _3230 * 0.0078125f;
                        float3 _3233 = t30[0].SampleLevel(s7, float3(_3231, _3232, _3189), 0.0f);
                        float _3235 = 1.0f - _3049;
                        float _3236 = 1.0f - _3050;
                        float _3237 = 1.0f - _3051;
                        bool _3238 = (_3063 != 0);
                        bool _3239 = (_3064 != 0);
                        bool _3240 = (_3065 != 0);
                        float _3241 = select(_3238, _3049, _3235);
                        float _3242 = select(_3239, _3050, _3236);
                        float _3243 = select(_3240, _3051, _3237);
                        float _3244 = _3242 * _3241;
                        float _3245 = _3244 * _3243;
                        float _3246 = _3245 + _3059;
                        bool _3247 = (_3136 > _3193.x);
                        if (_3247) {
                          float _3249 = _3193.x * _3193.x;
                          float _3250 = _3193.y - _3249;
                          float _3251 = abs(_3250);
                          float _3252 = _3136 - _3193.x;
                          float _3253 = _3252 * _3252;
                          float _3254 = _3251 + _3253;
                          float _3255 = _3251 / _3254;
                          float _3256 = _3255 * _3245;
                          _3258 = _3256;
                        } else {
                          _3258 = _3245;
                        }
                        float _3259 = dot(float3(_3138, _3139, _3140), float3(_195, _196, _197));
                        float _3260 = _3259 * 0.5f;
                        float _3261 = _3260 + 0.5f;
                        float _3262 = saturate(_3261);
                        float _3263 = _3262 * _3258;
                        float _3264 = _3263 * _3233.z;
                        float _3265 = _3264 + _3055;
                        float _3266 = _3264 + _3056;
                        float _3267 = _3264 + _3057;
                        float _3268 = _3263 + _3058;
                        _3270 = _3265;
                        _3271 = _3266;
                        _3272 = _3267;
                        _3273 = _3268;
                        _3274 = _3246;
                      } else {
                        _3270 = _3055;
                        _3271 = _3056;
                        _3272 = _3057;
                        _3273 = _3058;
                        _3274 = _3059;
                      }
                    } else {
                      _3270 = _3055;
                      _3271 = _3056;
                      _3272 = _3057;
                      _3273 = _3058;
                      _3274 = _3059;
                    }
                    int _3275 = _3060 + 1;
                    bool _3276 = (_3275 == 8);
                    if (!_3276) {
                      _3055 = _3270;
                      _3056 = _3271;
                      _3057 = _3272;
                      _3058 = _3273;
                      _3059 = _3274;
                      _3060 = _3275;
                      continue;
                    }
                    break;
                  }
                  while(true) {
                    bool _3053 = (_3273 > 9.999999747378752e-06f);
                    if (_3053) {
                      float _3278 = _3270 / _3273;
                      float _3279 = _3271 / _3273;
                      float _3280 = _3272 / _3273;
                      _3288 = _3278;
                      _3289 = _3279;
                      _3290 = _3280;
                      _3291 = _3273;
                    } else {
                      bool _3282 = (_3274 > 9.999999747378752e-06f);
                      if (_3282) {
                        float _3284 = _3270 / _3274;
                        float _3285 = _3271 / _3274;
                        float _3286 = _3272 / _3274;
                        _3288 = _3284;
                        _3289 = _3285;
                        _3290 = _3286;
                        _3291 = _3274;
                      } else {
                        _3288 = 0.0f;
                        _3289 = 0.0f;
                        _3290 = 0.0f;
                        _3291 = 0.0f;
                      }
                    }
                    bool _3292 = (_3291 < 9.999999747378752e-06f);
                    if (_3292) {
                      _3295 = _2984;
                      _3296 = _2985;
                      _3297 = _2986;
                      _3298 = _2988;
                      _3299 = _2989;
                      _3300 = 0.0f;
                      _3301 = 0;
                      _3302 = _3288;
                      _3303 = _3289;
                      _3304 = _3290;
                    } else {
                      _3295 = _2984;
                      _3296 = _2985;
                      _3297 = _2986;
                      _3298 = _2988;
                      _3299 = _2989;
                      _3300 = _2663;
                      _3301 = _2987;
                      _3302 = _3288;
                      _3303 = _3289;
                      _3304 = _3290;
                    }
                    break;
                  }
                }
                break;
              }
            } else {
              _2979 = 0.0f;
              _2980 = 0.0f;
              _2981 = 0.0f;
              bool _2982 = (_2680 == 0);
              if (!_2982) {
                _2984 = _2979;
                _2985 = _2980;
                _2986 = _2981;
                _2987 = _2680;
                _2988 = _2679;
                _2989 = _2678;
                float _3022 = cb7_009z * _195;
                float _3023 = cb7_009z * _196;
                float _3024 = cb7_009z * _197;
                float _3025 = _3022 + _275;
                float _3026 = _3023 + _277;
                float _3027 = _3024 + _279;
                float _3028 = _3025 * cb7_011x;
                float _3029 = _3026 * cb7_011y;
                float _3030 = _3027 * cb7_011z;
                float _3031 = _3028 + cb7_012x;
                float _3032 = _3029 + cb7_012y;
                float _3033 = _3030 + cb7_012z;
                int _3034 = int(_3031);
                int _3035 = int(_3032);
                int _3036 = int(_3033);
                uint _3037 = (uint)(cb7_002x) + -1u;
                uint _3038 = (uint)(cb7_002y) + -1u;
                uint _3039 = (uint)(cb7_002z) + -1u;
                int _3040 = max(_3034, 0);
                int _3041 = max(_3035, 0);
                int _3042 = max(_3036, 0);
                int _3043 = min(_3040, _3037);
                int _3044 = min(_3041, _3038);
                int _3045 = min(_3042, _3039);
                float _3046 = float((int)(_3043));
                float _3047 = float((int)(_3044));
                float _3048 = float((int)(_3045));
                float _3049 = _3031 - _3046;
                float _3050 = _3032 - _3047;
                float _3051 = _3033 - _3048;
                _3055 = 0.0f;
                _3056 = 0.0f;
                _3057 = 0.0f;
                _3058 = 0.0f;
                _3059 = 0.0f;
                _3060 = 0;
                while(true) {
                  int _3061 = (uint)(_3060) >> 1;
                  int _3062 = (uint)(_3060) >> 2;
                  int _3063 = _3060 & 1;
                  int _3064 = _3061 & 1;
                  int _3065 = _3062 & 1;
                  uint _3066 = _3063 + _3043;
                  uint _3067 = _3064 + _3044;
                  uint _3068 = _3065 + _3045;
                  bool _3069 = ((int)_3066 >= (int)cb7_002x);
                  bool _3070 = ((int)_3067 >= (int)cb7_002y);
                  bool _3071 = ((int)_3068 >= (int)cb7_002z);
                  bool _3072 = _3069 || _3070;
                  bool _3073 = _3071 || _3072;
                  if (!_3073) {
                    uint _3075 = (uint)(cb7_002x) - (uint)(cb7_007x);
                    uint _3076 = _3075 + _3066;
                    uint _3077 = (uint)(cb7_002y) - (uint)(cb7_007y);
                    uint _3078 = _3077 + _3067;
                    uint _3079 = (uint)(cb7_002z) - (uint)(cb7_007z);
                    uint _3080 = _3079 + _3068;
                    int _3081 = _3076 % cb7_002x;
                    int _3082 = _3078 % cb7_002y;
                    int _3083 = _3080 % cb7_002z;
                    uint _3085 = t38.Load(int4(_3081, _3082, _3083, 0));
                    int _3087 = _3085.x & 511;
                    int _3088 = (uint)((uint)(_3085.x)) >> 9;
                    float4 _3091 = t34[0].Load(int3(_3087, _3088, 0));
                    uint _3093 = t38.Load(int4(_3081, _3082, _3083, 0));
                    int _3095 = _3093.x & 127;
                    int _3096 = (uint)((uint)(_3093.x)) >> 7;
                    int _3097 = _3096 & 127;
                    int _3098 = (uint)((uint)(_3093.x)) >> 14;
                    int _3099 = _3096 | _3093.x;
                    int _3100 = _3099 & 127;
                    int _3101 = _3100 | _3098;
                    bool _3102 = (_3101 == 0);
                    if (!_3102) {
                      float _3105 = _3091.z * 0.44999998807907104f;
                      float _3107 = _3091.y * 0.44999998807907104f;
                      float _3109 = _3091.x * 0.44999998807907104f;
                      float _3110 = float((int)(_3063));
                      float _3111 = float((int)(_3064));
                      float _3112 = float((int)(_3065));
                      float _3113 = _3046 - cb7_010x;
                      float _3114 = _3113 + _3110;
                      float _3115 = _3114 + _3109;
                      float _3116 = _3115 * cb7_001x;
                      float _3117 = cb7_000x - _3025;
                      float _3118 = _3116 + _3117;
                      float _3119 = _3047 - cb7_010y;
                      float _3120 = _3119 + _3111;
                      float _3121 = _3120 + _3107;
                      float _3122 = _3121 * cb7_001y;
                      float _3123 = cb7_000y - _3026;
                      float _3124 = _3122 + _3123;
                      float _3125 = _3048 - cb7_010z;
                      float _3126 = _3125 + _3112;
                      float _3127 = _3126 + _3105;
                      float _3128 = _3127 * cb7_001z;
                      float _3129 = cb7_000z - _3027;
                      float _3130 = _3128 + _3129;
                      float _3131 = _3118 * _3118;
                      float _3132 = _3124 * _3124;
                      float _3133 = _3131 + _3132;
                      float _3134 = _3130 * _3130;
                      float _3135 = _3133 + _3134;
                      float _3136 = sqrt(_3135);
                      float _3137 = max(_3136, 9.999999747378752e-06f);
                      float _3138 = _3118 / _3137;
                      float _3139 = _3124 / _3137;
                      float _3140 = _3130 / _3137;
                      float _3141 = -0.0f - _3138;
                      float _3142 = -0.0f - _3139;
                      float _3143 = -0.0f - _3140;
                      float _3144 = abs(_3141);
                      float _3145 = abs(_3142);
                      float _3146 = _3145 + _3144;
                      float _3147 = abs(_3143);
                      float _3148 = _3146 + _3147;
                      float _3149 = _3141 / _3148;
                      float _3150 = _3142 / _3148;
                      float _3151 = _3143 / _3148;
                      bool _3152 = (_3151 > 0.0f);
                      if (!_3152) {
                        float _3154 = abs(_3150);
                        float _3155 = abs(_3149);
                        float _3156 = 1.0f - _3154;
                        float _3157 = 1.0f - _3155;
                        bool _3158 = (_3149 > 0.0f);
                        bool _3159 = (_3150 > 0.0f);
                        bool _3160 = (_3149 < 0.0f);
                        bool _3161 = (_3150 < 0.0f);
                        int _3162 = (int)(uint)(_3158);
                        int _3163 = (int)(uint)(_3159);
                        int _3164 = (int)(uint)(_3160);
                        int _3165 = (int)(uint)(_3161);
                        int _3166 = _3162 - _3164;
                        int _3167 = _3163 - _3165;
                        float _3168 = float((int)(_3166));
                        float _3169 = float((int)(_3167));
                        float _3170 = _3156 * _3168;
                        float _3171 = _3157 * _3169;
                        _3173 = _3170;
                        _3174 = _3171;
                      } else {
                        _3173 = _3149;
                        _3174 = _3150;
                      }
                      float _3175 = float((int)(cb7_005w));
                      float _3176 = _3175 * 0.5f;
                      float _3177 = _3175 + 2.0f;
                      float _3178 = _3176 / _3177;
                      float _3179 = float((int)(_3095));
                      float _3180 = float((int)(_3097));
                      float _3181 = _3179 + 0.5f;
                      float _3182 = _3180 + 0.5f;
                      float _3183 = _3178 * _3173;
                      float _3184 = _3178 * _3174;
                      float _3185 = _3183 + _3181;
                      float _3186 = _3184 + _3182;
                      float _3187 = _3185 * 0.0078125f;
                      float _3188 = _3186 * 0.0078125f;
                      float _3189 = float((int)(_3098));
                      float3 _3193 = t30[0].SampleLevel(s7, float3(_3187, _3188, _3189), 0.0f);
                      float _3196 = abs(cb13_000x);
                      float _3197 = abs(cb13_000y);
                      float _3198 = _3197 + _3196;
                      float _3199 = abs(cb13_000z);
                      float _3200 = _3198 + _3199;
                      float _3201 = cb13_000x / _3200;
                      float _3202 = cb13_000y / _3200;
                      float _3203 = cb13_000z / _3200;
                      bool _3204 = (_3203 > 0.0f);
                      if (!_3204) {
                        float _3206 = abs(_3202);
                        float _3207 = abs(_3201);
                        float _3208 = 1.0f - _3206;
                        float _3209 = 1.0f - _3207;
                        bool _3210 = (_3201 > 0.0f);
                        bool _3211 = (_3202 > 0.0f);
                        bool _3212 = (_3201 < 0.0f);
                        bool _3213 = (_3202 < 0.0f);
                        int _3214 = (int)(uint)(_3210);
                        int _3215 = (int)(uint)(_3211);
                        int _3216 = (int)(uint)(_3212);
                        int _3217 = (int)(uint)(_3213);
                        int _3218 = _3214 - _3216;
                        int _3219 = _3215 - _3217;
                        float _3220 = float((int)(_3218));
                        float _3221 = float((int)(_3219));
                        float _3222 = _3208 * _3220;
                        float _3223 = _3209 * _3221;
                        _3225 = _3222;
                        _3226 = _3223;
                      } else {
                        _3225 = _3201;
                        _3226 = _3202;
                      }
                      float _3227 = _3225 * _3178;
                      float _3228 = _3226 * _3178;
                      float _3229 = _3227 + _3181;
                      float _3230 = _3228 + _3182;
                      float _3231 = _3229 * 0.0078125f;
                      float _3232 = _3230 * 0.0078125f;
                      float3 _3233 = t30[0].SampleLevel(s7, float3(_3231, _3232, _3189), 0.0f);
                      float _3235 = 1.0f - _3049;
                      float _3236 = 1.0f - _3050;
                      float _3237 = 1.0f - _3051;
                      bool _3238 = (_3063 != 0);
                      bool _3239 = (_3064 != 0);
                      bool _3240 = (_3065 != 0);
                      float _3241 = select(_3238, _3049, _3235);
                      float _3242 = select(_3239, _3050, _3236);
                      float _3243 = select(_3240, _3051, _3237);
                      float _3244 = _3242 * _3241;
                      float _3245 = _3244 * _3243;
                      float _3246 = _3245 + _3059;
                      bool _3247 = (_3136 > _3193.x);
                      if (_3247) {
                        float _3249 = _3193.x * _3193.x;
                        float _3250 = _3193.y - _3249;
                        float _3251 = abs(_3250);
                        float _3252 = _3136 - _3193.x;
                        float _3253 = _3252 * _3252;
                        float _3254 = _3251 + _3253;
                        float _3255 = _3251 / _3254;
                        float _3256 = _3255 * _3245;
                        _3258 = _3256;
                      } else {
                        _3258 = _3245;
                      }
                      float _3259 = dot(float3(_3138, _3139, _3140), float3(_195, _196, _197));
                      float _3260 = _3259 * 0.5f;
                      float _3261 = _3260 + 0.5f;
                      float _3262 = saturate(_3261);
                      float _3263 = _3262 * _3258;
                      float _3264 = _3263 * _3233.z;
                      float _3265 = _3264 + _3055;
                      float _3266 = _3264 + _3056;
                      float _3267 = _3264 + _3057;
                      float _3268 = _3263 + _3058;
                      _3270 = _3265;
                      _3271 = _3266;
                      _3272 = _3267;
                      _3273 = _3268;
                      _3274 = _3246;
                    } else {
                      _3270 = _3055;
                      _3271 = _3056;
                      _3272 = _3057;
                      _3273 = _3058;
                      _3274 = _3059;
                    }
                  } else {
                    _3270 = _3055;
                    _3271 = _3056;
                    _3272 = _3057;
                    _3273 = _3058;
                    _3274 = _3059;
                  }
                  int _3275 = _3060 + 1;
                  bool _3276 = (_3275 == 8);
                  if (!_3276) {
                    _3055 = _3270;
                    _3056 = _3271;
                    _3057 = _3272;
                    _3058 = _3273;
                    _3059 = _3274;
                    _3060 = _3275;
                    continue;
                  }
                  break;
                }
                while(true) {
                  bool _3053 = (_3273 > 9.999999747378752e-06f);
                  if (_3053) {
                    float _3278 = _3270 / _3273;
                    float _3279 = _3271 / _3273;
                    float _3280 = _3272 / _3273;
                    _3288 = _3278;
                    _3289 = _3279;
                    _3290 = _3280;
                    _3291 = _3273;
                  } else {
                    bool _3282 = (_3274 > 9.999999747378752e-06f);
                    if (_3282) {
                      float _3284 = _3270 / _3274;
                      float _3285 = _3271 / _3274;
                      float _3286 = _3272 / _3274;
                      _3288 = _3284;
                      _3289 = _3285;
                      _3290 = _3286;
                      _3291 = _3274;
                    } else {
                      _3288 = 0.0f;
                      _3289 = 0.0f;
                      _3290 = 0.0f;
                      _3291 = 0.0f;
                    }
                  }
                  bool _3292 = (_3291 < 9.999999747378752e-06f);
                  if (_3292) {
                    _3295 = _2984;
                    _3296 = _2985;
                    _3297 = _2986;
                    _3298 = _2988;
                    _3299 = _2989;
                    _3300 = 0.0f;
                    _3301 = 0;
                    _3302 = _3288;
                    _3303 = _3289;
                    _3304 = _3290;
                  } else {
                    _3295 = _2984;
                    _3296 = _2985;
                    _3297 = _2986;
                    _3298 = _2988;
                    _3299 = _2989;
                    _3300 = _2663;
                    _3301 = _2987;
                    _3302 = _3288;
                    _3303 = _3289;
                    _3304 = _3290;
                  }
                  break;
                }
              } else {
                _3295 = _2979;
                _3296 = _2980;
                _3297 = _2981;
                _3298 = _2679;
                _3299 = _2678;
                _3300 = _2663;
                _3301 = 0;
                _3302 = 0.0f;
                _3303 = 0.0f;
                _3304 = 0.0f;
              }
            }
            bool _3307 = (cb7_007w == 1);
            float _3308 = select(_3307, 1.0f, _3295);
            float _3309 = select(_3307, 0.0f, _3296);
            float _3310 = select(_3307, 0.0f, _3297);
            float _3311 = select(_3307, 0.0f, _3302);
            float _3312 = select(_3307, 0.0f, _3303);
            float _3313 = select(_3307, 1.0f, _3304);
            int _3314 = _3301 | _3298;
            bool _3315 = (_3314 == 0);
            bool _3316 = (_3300 < 1.0f);
            bool _3317 = _3316 || _3315;
            if (_3317) {
              float _3319 = dot(float3(_195, _196, _197), float3(cb13_000x, cb13_000y, cb13_000z));
              float _3320 = _3319 * 0.5f;
              float _3321 = _3320 + 0.5f;
              float _3322 = select(_3307, 0.0f, _3321);
              float _3323 = select(_3307, 1.0f, _3321);
              float _3324 = _3311 - _3322;
              float _3325 = _3312 - _3323;
              float _3326 = _3313 - _3322;
              float _3327 = _3324 * _3300;
              float _3328 = _3325 * _3300;
              float _3329 = _3326 * _3300;
              float _3330 = _3327 + _3322;
              float _3331 = _3328 + _3323;
              float _3332 = _3329 + _3322;
              bool _3333 = (_3314 != 0);
              float _3334 = select(_3333, _3299, 0.0f);
              _3336 = _3334;
              _3337 = _3330;
              _3338 = _3331;
              _3339 = _3332;
            } else {
              _3336 = _3299;
              _3337 = _3311;
              _3338 = _3312;
              _3339 = _3313;
            }
            float _3340 = _3308 - _3337;
            float _3341 = _3309 - _3338;
            float _3342 = _3310 - _3339;
            float _3343 = _3340 * _3336;
            float _3344 = _3341 * _3336;
            float _3345 = _3342 * _3336;
            float _3346 = _3343 + _3337;
            float _3347 = _3344 + _3338;
            float _3348 = _3345 + _3339;
            bool _3349 = isnan(_3346);
            bool _3350 = isnan(_3347);
            bool _3351 = isnan(_3348);
            bool _3352 = _3349 || _3350;
            bool _3353 = _3352 || _3351;
            float _3354 = select(_3353, 0.0f, _3346);
            _3356 = _3354;
          } else {
            _3356 = 1.0f;
          }
          float _3357 = _3356 * _2591;
          _3359 = _3357;
        }
      } else {
        _2591 = _2443;
        bool _2594 = (cb12_074y > 0.0f);
        if (!_2594) {
          float _2600 = cb7_029x * _275;
          float _2601 = cb7_029y * _277;
          float _2602 = cb7_029z * _279;
          float _2607 = _2600 + cb7_031x;
          float _2608 = _2601 + cb7_031y;
          float _2609 = _2602 + cb7_031z;
          float _2610 = abs(_2607);
          float _2611 = abs(_2608);
          float _2612 = abs(_2609);
          float _2617 = cb7_032x * _2610;
          float _2618 = cb7_032y * _2611;
          float _2619 = cb7_032z * _2612;
          float _2621 = _2617 + cb7_032w;
          float _2622 = _2618 + cb7_032w;
          float _2623 = _2619 + cb7_032w;
          float _2624 = saturate(_2621);
          float _2625 = saturate(_2622);
          float _2626 = saturate(_2623);
          float _2627 = min(_2624, _2625);
          float _2628 = _2626 * _2626;
          float _2629 = _2628 * _2627;
          float _2634 = cb7_011x * _275;
          float _2635 = cb7_011y * _277;
          float _2636 = cb7_011z * _279;
          float _2641 = _2634 + cb7_013x;
          float _2642 = _2635 + cb7_013y;
          float _2643 = _2636 + cb7_013z;
          float _2644 = abs(_2641);
          float _2645 = abs(_2642);
          float _2646 = abs(_2643);
          float _2651 = cb7_014x * _2644;
          float _2652 = cb7_014y * _2645;
          float _2653 = cb7_014z * _2646;
          float _2655 = _2651 + cb7_014w;
          float _2656 = _2652 + cb7_014w;
          float _2657 = _2653 + cb7_014w;
          float _2658 = saturate(_2655);
          float _2659 = saturate(_2656);
          float _2660 = saturate(_2657);
          float _2661 = min(_2658, _2659);
          float _2662 = _2660 * _2660;
          float _2663 = _2662 * _2661;
          bool _2664 = (_2629 > 9.999999717180685e-10f);
          int _2665 = (int)(uint)(_2664);
          bool _2666 = (_2629 < 1.0f);
          if (_2666) {
            bool _2668 = (_2663 > 9.999999717180685e-10f);
            int _2669 = (int)(uint)(_2668);
            bool _2670 = _2664 && _2668;
            if (_2670) {
              float _2672 = _1376 + _2663;
              bool _2673 = (_2672 > 0.5f);
              int _2674 = (int)(uint)(_2673);
              int _2675 = _2674 ^ 1;
              float _2676 = select(_2673, 1.0f, 0.0f);
              _2678 = _2676;
              _2679 = _2674;
              _2680 = _2675;
            } else {
              _2678 = _2629;
              _2679 = _2665;
              _2680 = _2669;
            }
          } else {
            _2678 = _2629;
            _2679 = _2665;
            _2680 = 0;
          }
          bool _2681 = (_2679 == 0);
          if (!_2681) {
            float _2711 = cb7_027z * _195;
            float _2712 = cb7_027z * _196;
            float _2713 = cb7_027z * _197;
            float _2714 = _2711 + _275;
            float _2715 = _2712 + _277;
            float _2716 = _2713 + _279;
            float _2717 = _2714 * cb7_029x;
            float _2718 = _2715 * cb7_029y;
            float _2719 = _2716 * cb7_029z;
            float _2720 = _2717 + cb7_030x;
            float _2721 = _2718 + cb7_030y;
            float _2722 = _2719 + cb7_030z;
            int _2723 = int(_2720);
            int _2724 = int(_2721);
            int _2725 = int(_2722);
            uint _2726 = (uint)(cb7_020x) + -1u;
            uint _2727 = (uint)(cb7_020y) + -1u;
            uint _2728 = (uint)(cb7_020z) + -1u;
            int _2729 = max(_2723, 0);
            int _2730 = max(_2724, 0);
            int _2731 = max(_2725, 0);
            int _2732 = min(_2729, _2726);
            int _2733 = min(_2730, _2727);
            int _2734 = min(_2731, _2728);
            float _2735 = float((int)(_2732));
            float _2736 = float((int)(_2733));
            float _2737 = float((int)(_2734));
            float _2738 = _2720 - _2735;
            float _2739 = _2721 - _2736;
            float _2740 = _2722 - _2737;
            _2744 = 0.0f;
            _2745 = 0.0f;
            _2746 = 0.0f;
            _2747 = 0.0f;
            _2748 = 0.0f;
            _2749 = 0;
            while(true) {
              int _2750 = (uint)(_2749) >> 1;
              int _2751 = (uint)(_2749) >> 2;
              int _2752 = _2749 & 1;
              int _2753 = _2750 & 1;
              int _2754 = _2751 & 1;
              uint _2755 = _2752 + _2732;
              uint _2756 = _2753 + _2733;
              uint _2757 = _2754 + _2734;
              bool _2758 = ((int)_2755 >= (int)cb7_020x);
              bool _2759 = ((int)_2756 >= (int)cb7_020y);
              bool _2760 = ((int)_2757 >= (int)cb7_020z);
              bool _2761 = _2758 || _2759;
              bool _2762 = _2760 || _2761;
              if (!_2762) {
                uint _2764 = (uint)(cb7_020x) - (uint)(cb7_025x);
                uint _2765 = _2764 + _2755;
                uint _2766 = (uint)(cb7_020y) - (uint)(cb7_025y);
                uint _2767 = _2766 + _2756;
                uint _2768 = (uint)(cb7_020z) - (uint)(cb7_025z);
                uint _2769 = _2768 + _2757;
                int _2770 = _2765 % cb7_020x;
                int _2771 = _2767 % cb7_020y;
                int _2772 = _2769 % cb7_020z;
                int _2773 = _2770 * cb7_020z;
                int _2774 = _2772 + _2773;
                float4 _2777 = t34[1].Load(int3(_2774, _2771, 0));
                uint _2780 = t32[1].Load(int3(_2774, _2771, 0));
                int _2782 = _2780.x & -2;
                bool _2783 = (_2782 == 2);
                if (_2783) {
                  float _2786 = _2777.z * 0.44999998807907104f;
                  float _2788 = _2777.y * 0.44999998807907104f;
                  float _2790 = _2777.x * 0.44999998807907104f;
                  float _2791 = float((int)(_2752));
                  float _2792 = float((int)(_2753));
                  float _2793 = float((int)(_2754));
                  float _2794 = _2735 - cb7_028x;
                  float _2795 = _2794 + _2791;
                  float _2796 = _2795 + _2790;
                  float _2797 = _2796 * cb7_019x;
                  float _2798 = cb7_018x - _2714;
                  float _2799 = _2797 + _2798;
                  float _2800 = _2736 - cb7_028y;
                  float _2801 = _2800 + _2792;
                  float _2802 = _2801 + _2788;
                  float _2803 = _2802 * cb7_019y;
                  float _2804 = cb7_018y - _2715;
                  float _2805 = _2803 + _2804;
                  float _2806 = _2737 - cb7_028z;
                  float _2807 = _2806 + _2793;
                  float _2808 = _2807 + _2786;
                  float _2809 = _2808 * cb7_019z;
                  float _2810 = cb7_018z - _2716;
                  float _2811 = _2809 + _2810;
                  float _2812 = _2799 * _2799;
                  float _2813 = _2805 * _2805;
                  float _2814 = _2812 + _2813;
                  float _2815 = _2811 * _2811;
                  float _2816 = _2814 + _2815;
                  float _2817 = sqrt(_2816);
                  float _2818 = max(_2817, 9.999999747378752e-06f);
                  float _2819 = _2799 / _2818;
                  float _2820 = _2805 / _2818;
                  float _2821 = _2811 / _2818;
                  float _2822 = -0.0f - _2819;
                  float _2823 = -0.0f - _2820;
                  float _2824 = -0.0f - _2821;
                  float _2825 = abs(_2822);
                  float _2826 = abs(_2823);
                  float _2827 = _2826 + _2825;
                  float _2828 = abs(_2824);
                  float _2829 = _2827 + _2828;
                  float _2830 = _2822 / _2829;
                  float _2831 = _2823 / _2829;
                  float _2832 = _2824 / _2829;
                  bool _2833 = (_2832 > 0.0f);
                  if (!_2833) {
                    float _2835 = abs(_2831);
                    float _2836 = abs(_2830);
                    float _2837 = 1.0f - _2835;
                    float _2838 = 1.0f - _2836;
                    bool _2839 = (_2830 > 0.0f);
                    bool _2840 = (_2831 > 0.0f);
                    bool _2841 = (_2830 < 0.0f);
                    bool _2842 = (_2831 < 0.0f);
                    int _2843 = (int)(uint)(_2839);
                    int _2844 = (int)(uint)(_2840);
                    int _2845 = (int)(uint)(_2841);
                    int _2846 = (int)(uint)(_2842);
                    int _2847 = _2843 - _2845;
                    int _2848 = _2844 - _2846;
                    float _2849 = float((int)(_2847));
                    float _2850 = float((int)(_2848));
                    float _2851 = _2837 * _2849;
                    float _2852 = _2838 * _2850;
                    _2854 = _2851;
                    _2855 = _2852;
                  } else {
                    _2854 = _2830;
                    _2855 = _2831;
                  }
                  float _2856 = float((int)(cb7_023w));
                  float _2857 = _2856 * 0.5f;
                  float _2858 = _2856 + 2.0f;
                  float _2859 = _2857 / _2858;
                  float _2860 = float((int)(cb7_020x));
                  float _2861 = float((int)(cb7_020y));
                  float _2862 = 1.0f / _2860;
                  float _2863 = 1.0f / _2861;
                  float _2864 = float((int)(_2770));
                  float _2865 = float((int)(_2771));
                  float _2866 = _2864 + 0.5f;
                  float _2867 = _2865 + 0.5f;
                  float _2868 = _2859 * _2854;
                  float _2869 = _2859 * _2855;
                  float _2870 = _2868 + _2866;
                  float _2871 = _2869 + _2867;
                  float _2872 = _2870 * _2862;
                  float _2873 = _2871 * _2863;
                  float _2874 = float((int)(_2772));
                  float3 _2878 = t30[1].SampleLevel(s7, float3(_2872, _2873, _2874), 0.0f);
                  float _2881 = abs(cb13_000x);
                  float _2882 = abs(cb13_000y);
                  float _2883 = _2882 + _2881;
                  float _2884 = abs(cb13_000z);
                  float _2885 = _2883 + _2884;
                  float _2886 = cb13_000x / _2885;
                  float _2887 = cb13_000y / _2885;
                  float _2888 = cb13_000z / _2885;
                  bool _2889 = (_2888 > 0.0f);
                  if (!_2889) {
                    float _2891 = abs(_2887);
                    float _2892 = abs(_2886);
                    float _2893 = 1.0f - _2891;
                    float _2894 = 1.0f - _2892;
                    bool _2895 = (_2886 > 0.0f);
                    bool _2896 = (_2887 > 0.0f);
                    bool _2897 = (_2886 < 0.0f);
                    bool _2898 = (_2887 < 0.0f);
                    int _2899 = (int)(uint)(_2895);
                    int _2900 = (int)(uint)(_2896);
                    int _2901 = (int)(uint)(_2897);
                    int _2902 = (int)(uint)(_2898);
                    int _2903 = _2899 - _2901;
                    int _2904 = _2900 - _2902;
                    float _2905 = float((int)(_2903));
                    float _2906 = float((int)(_2904));
                    float _2907 = _2893 * _2905;
                    float _2908 = _2894 * _2906;
                    _2910 = _2907;
                    _2911 = _2908;
                  } else {
                    _2910 = _2886;
                    _2911 = _2887;
                  }
                  float _2912 = _2910 * _2859;
                  float _2913 = _2911 * _2859;
                  float _2914 = _2912 + _2866;
                  float _2915 = _2913 + _2867;
                  float _2916 = _2914 * _2862;
                  float _2917 = _2915 * _2863;
                  float3 _2918 = t30[1].SampleLevel(s7, float3(_2916, _2917, _2874), 0.0f);
                  float _2920 = 1.0f - _2738;
                  float _2921 = 1.0f - _2739;
                  float _2922 = 1.0f - _2740;
                  bool _2923 = (_2752 != 0);
                  bool _2924 = (_2753 != 0);
                  bool _2925 = (_2754 != 0);
                  float _2926 = select(_2923, _2738, _2920);
                  float _2927 = select(_2924, _2739, _2921);
                  float _2928 = select(_2925, _2740, _2922);
                  float _2929 = _2927 * _2926;
                  float _2930 = _2929 * _2928;
                  float _2931 = _2930 + _2748;
                  bool _2932 = (_2817 > _2878.x);
                  if (_2932) {
                    float _2934 = _2878.x * _2878.x;
                    float _2935 = _2878.y - _2934;
                    float _2936 = abs(_2935);
                    float _2937 = _2817 - _2878.x;
                    float _2938 = _2937 * _2937;
                    float _2939 = _2936 + _2938;
                    float _2940 = _2936 / _2939;
                    float _2941 = _2940 * _2930;
                    _2943 = _2941;
                  } else {
                    _2943 = _2930;
                  }
                  float _2944 = dot(float3(_2819, _2820, _2821), float3(_195, _196, _197));
                  float _2945 = _2944 * 0.5f;
                  float _2946 = _2945 + 0.5f;
                  float _2947 = saturate(_2946);
                  float _2948 = _2947 * _2943;
                  float _2949 = _2948 * _2918.z;
                  float _2950 = _2949 + _2744;
                  float _2951 = _2949 + _2745;
                  float _2952 = _2949 + _2746;
                  float _2953 = _2948 + _2747;
                  _2955 = _2950;
                  _2956 = _2951;
                  _2957 = _2952;
                  _2958 = _2953;
                  _2959 = _2931;
                } else {
                  _2955 = _2744;
                  _2956 = _2745;
                  _2957 = _2746;
                  _2958 = _2747;
                  _2959 = _2748;
                }
              } else {
                _2955 = _2744;
                _2956 = _2745;
                _2957 = _2746;
                _2958 = _2747;
                _2959 = _2748;
              }
              int _2960 = _2749 + 1;
              bool _2961 = (_2960 == 8);
              if (!_2961) {
                _2744 = _2955;
                _2745 = _2956;
                _2746 = _2957;
                _2747 = _2958;
                _2748 = _2959;
                _2749 = _2960;
                continue;
              }
              break;
            }
            while(true) {
              bool _2742 = (_2958 > 9.999999747378752e-06f);
              if (_2742) {
                float _2963 = _2955 / _2958;
                float _2964 = _2956 / _2958;
                float _2965 = _2957 / _2958;
                _2973 = _2963;
                _2974 = _2964;
                _2975 = _2965;
                _2976 = _2958;
              } else {
                bool _2967 = (_2959 > 9.999999747378752e-06f);
                if (_2967) {
                  float _2969 = _2955 / _2959;
                  float _2970 = _2956 / _2959;
                  float _2971 = _2957 / _2959;
                  _2973 = _2969;
                  _2974 = _2970;
                  _2975 = _2971;
                  _2976 = _2959;
                } else {
                  _2973 = 0.0f;
                  _2974 = 0.0f;
                  _2975 = 0.0f;
                  _2976 = 0.0f;
                }
              }
              bool _2977 = (_2976 < 9.999999747378752e-06f);
              if (!_2977) {
                _2979 = _2973;
                _2980 = _2974;
                _2981 = _2975;
                bool _2982 = (_2680 == 0);
                if (!_2982) {
                  _2984 = _2979;
                  _2985 = _2980;
                  _2986 = _2981;
                  _2987 = _2680;
                  _2988 = _2679;
                  _2989 = _2678;
                  float _3022 = cb7_009z * _195;
                  float _3023 = cb7_009z * _196;
                  float _3024 = cb7_009z * _197;
                  float _3025 = _3022 + _275;
                  float _3026 = _3023 + _277;
                  float _3027 = _3024 + _279;
                  float _3028 = _3025 * cb7_011x;
                  float _3029 = _3026 * cb7_011y;
                  float _3030 = _3027 * cb7_011z;
                  float _3031 = _3028 + cb7_012x;
                  float _3032 = _3029 + cb7_012y;
                  float _3033 = _3030 + cb7_012z;
                  int _3034 = int(_3031);
                  int _3035 = int(_3032);
                  int _3036 = int(_3033);
                  uint _3037 = (uint)(cb7_002x) + -1u;
                  uint _3038 = (uint)(cb7_002y) + -1u;
                  uint _3039 = (uint)(cb7_002z) + -1u;
                  int _3040 = max(_3034, 0);
                  int _3041 = max(_3035, 0);
                  int _3042 = max(_3036, 0);
                  int _3043 = min(_3040, _3037);
                  int _3044 = min(_3041, _3038);
                  int _3045 = min(_3042, _3039);
                  float _3046 = float((int)(_3043));
                  float _3047 = float((int)(_3044));
                  float _3048 = float((int)(_3045));
                  float _3049 = _3031 - _3046;
                  float _3050 = _3032 - _3047;
                  float _3051 = _3033 - _3048;
                  _3055 = 0.0f;
                  _3056 = 0.0f;
                  _3057 = 0.0f;
                  _3058 = 0.0f;
                  _3059 = 0.0f;
                  _3060 = 0;
                  while(true) {
                    int _3061 = (uint)(_3060) >> 1;
                    int _3062 = (uint)(_3060) >> 2;
                    int _3063 = _3060 & 1;
                    int _3064 = _3061 & 1;
                    int _3065 = _3062 & 1;
                    uint _3066 = _3063 + _3043;
                    uint _3067 = _3064 + _3044;
                    uint _3068 = _3065 + _3045;
                    bool _3069 = ((int)_3066 >= (int)cb7_002x);
                    bool _3070 = ((int)_3067 >= (int)cb7_002y);
                    bool _3071 = ((int)_3068 >= (int)cb7_002z);
                    bool _3072 = _3069 || _3070;
                    bool _3073 = _3071 || _3072;
                    if (!_3073) {
                      uint _3075 = (uint)(cb7_002x) - (uint)(cb7_007x);
                      uint _3076 = _3075 + _3066;
                      uint _3077 = (uint)(cb7_002y) - (uint)(cb7_007y);
                      uint _3078 = _3077 + _3067;
                      uint _3079 = (uint)(cb7_002z) - (uint)(cb7_007z);
                      uint _3080 = _3079 + _3068;
                      int _3081 = _3076 % cb7_002x;
                      int _3082 = _3078 % cb7_002y;
                      int _3083 = _3080 % cb7_002z;
                      uint _3085 = t38.Load(int4(_3081, _3082, _3083, 0));
                      int _3087 = _3085.x & 511;
                      int _3088 = (uint)((uint)(_3085.x)) >> 9;
                      float4 _3091 = t34[0].Load(int3(_3087, _3088, 0));
                      uint _3093 = t38.Load(int4(_3081, _3082, _3083, 0));
                      int _3095 = _3093.x & 127;
                      int _3096 = (uint)((uint)(_3093.x)) >> 7;
                      int _3097 = _3096 & 127;
                      int _3098 = (uint)((uint)(_3093.x)) >> 14;
                      int _3099 = _3096 | _3093.x;
                      int _3100 = _3099 & 127;
                      int _3101 = _3100 | _3098;
                      bool _3102 = (_3101 == 0);
                      if (!_3102) {
                        float _3105 = _3091.z * 0.44999998807907104f;
                        float _3107 = _3091.y * 0.44999998807907104f;
                        float _3109 = _3091.x * 0.44999998807907104f;
                        float _3110 = float((int)(_3063));
                        float _3111 = float((int)(_3064));
                        float _3112 = float((int)(_3065));
                        float _3113 = _3046 - cb7_010x;
                        float _3114 = _3113 + _3110;
                        float _3115 = _3114 + _3109;
                        float _3116 = _3115 * cb7_001x;
                        float _3117 = cb7_000x - _3025;
                        float _3118 = _3116 + _3117;
                        float _3119 = _3047 - cb7_010y;
                        float _3120 = _3119 + _3111;
                        float _3121 = _3120 + _3107;
                        float _3122 = _3121 * cb7_001y;
                        float _3123 = cb7_000y - _3026;
                        float _3124 = _3122 + _3123;
                        float _3125 = _3048 - cb7_010z;
                        float _3126 = _3125 + _3112;
                        float _3127 = _3126 + _3105;
                        float _3128 = _3127 * cb7_001z;
                        float _3129 = cb7_000z - _3027;
                        float _3130 = _3128 + _3129;
                        float _3131 = _3118 * _3118;
                        float _3132 = _3124 * _3124;
                        float _3133 = _3131 + _3132;
                        float _3134 = _3130 * _3130;
                        float _3135 = _3133 + _3134;
                        float _3136 = sqrt(_3135);
                        float _3137 = max(_3136, 9.999999747378752e-06f);
                        float _3138 = _3118 / _3137;
                        float _3139 = _3124 / _3137;
                        float _3140 = _3130 / _3137;
                        float _3141 = -0.0f - _3138;
                        float _3142 = -0.0f - _3139;
                        float _3143 = -0.0f - _3140;
                        float _3144 = abs(_3141);
                        float _3145 = abs(_3142);
                        float _3146 = _3145 + _3144;
                        float _3147 = abs(_3143);
                        float _3148 = _3146 + _3147;
                        float _3149 = _3141 / _3148;
                        float _3150 = _3142 / _3148;
                        float _3151 = _3143 / _3148;
                        bool _3152 = (_3151 > 0.0f);
                        if (!_3152) {
                          float _3154 = abs(_3150);
                          float _3155 = abs(_3149);
                          float _3156 = 1.0f - _3154;
                          float _3157 = 1.0f - _3155;
                          bool _3158 = (_3149 > 0.0f);
                          bool _3159 = (_3150 > 0.0f);
                          bool _3160 = (_3149 < 0.0f);
                          bool _3161 = (_3150 < 0.0f);
                          int _3162 = (int)(uint)(_3158);
                          int _3163 = (int)(uint)(_3159);
                          int _3164 = (int)(uint)(_3160);
                          int _3165 = (int)(uint)(_3161);
                          int _3166 = _3162 - _3164;
                          int _3167 = _3163 - _3165;
                          float _3168 = float((int)(_3166));
                          float _3169 = float((int)(_3167));
                          float _3170 = _3156 * _3168;
                          float _3171 = _3157 * _3169;
                          _3173 = _3170;
                          _3174 = _3171;
                        } else {
                          _3173 = _3149;
                          _3174 = _3150;
                        }
                        float _3175 = float((int)(cb7_005w));
                        float _3176 = _3175 * 0.5f;
                        float _3177 = _3175 + 2.0f;
                        float _3178 = _3176 / _3177;
                        float _3179 = float((int)(_3095));
                        float _3180 = float((int)(_3097));
                        float _3181 = _3179 + 0.5f;
                        float _3182 = _3180 + 0.5f;
                        float _3183 = _3178 * _3173;
                        float _3184 = _3178 * _3174;
                        float _3185 = _3183 + _3181;
                        float _3186 = _3184 + _3182;
                        float _3187 = _3185 * 0.0078125f;
                        float _3188 = _3186 * 0.0078125f;
                        float _3189 = float((int)(_3098));
                        float3 _3193 = t30[0].SampleLevel(s7, float3(_3187, _3188, _3189), 0.0f);
                        float _3196 = abs(cb13_000x);
                        float _3197 = abs(cb13_000y);
                        float _3198 = _3197 + _3196;
                        float _3199 = abs(cb13_000z);
                        float _3200 = _3198 + _3199;
                        float _3201 = cb13_000x / _3200;
                        float _3202 = cb13_000y / _3200;
                        float _3203 = cb13_000z / _3200;
                        bool _3204 = (_3203 > 0.0f);
                        if (!_3204) {
                          float _3206 = abs(_3202);
                          float _3207 = abs(_3201);
                          float _3208 = 1.0f - _3206;
                          float _3209 = 1.0f - _3207;
                          bool _3210 = (_3201 > 0.0f);
                          bool _3211 = (_3202 > 0.0f);
                          bool _3212 = (_3201 < 0.0f);
                          bool _3213 = (_3202 < 0.0f);
                          int _3214 = (int)(uint)(_3210);
                          int _3215 = (int)(uint)(_3211);
                          int _3216 = (int)(uint)(_3212);
                          int _3217 = (int)(uint)(_3213);
                          int _3218 = _3214 - _3216;
                          int _3219 = _3215 - _3217;
                          float _3220 = float((int)(_3218));
                          float _3221 = float((int)(_3219));
                          float _3222 = _3208 * _3220;
                          float _3223 = _3209 * _3221;
                          _3225 = _3222;
                          _3226 = _3223;
                        } else {
                          _3225 = _3201;
                          _3226 = _3202;
                        }
                        float _3227 = _3225 * _3178;
                        float _3228 = _3226 * _3178;
                        float _3229 = _3227 + _3181;
                        float _3230 = _3228 + _3182;
                        float _3231 = _3229 * 0.0078125f;
                        float _3232 = _3230 * 0.0078125f;
                        float3 _3233 = t30[0].SampleLevel(s7, float3(_3231, _3232, _3189), 0.0f);
                        float _3235 = 1.0f - _3049;
                        float _3236 = 1.0f - _3050;
                        float _3237 = 1.0f - _3051;
                        bool _3238 = (_3063 != 0);
                        bool _3239 = (_3064 != 0);
                        bool _3240 = (_3065 != 0);
                        float _3241 = select(_3238, _3049, _3235);
                        float _3242 = select(_3239, _3050, _3236);
                        float _3243 = select(_3240, _3051, _3237);
                        float _3244 = _3242 * _3241;
                        float _3245 = _3244 * _3243;
                        float _3246 = _3245 + _3059;
                        bool _3247 = (_3136 > _3193.x);
                        if (_3247) {
                          float _3249 = _3193.x * _3193.x;
                          float _3250 = _3193.y - _3249;
                          float _3251 = abs(_3250);
                          float _3252 = _3136 - _3193.x;
                          float _3253 = _3252 * _3252;
                          float _3254 = _3251 + _3253;
                          float _3255 = _3251 / _3254;
                          float _3256 = _3255 * _3245;
                          _3258 = _3256;
                        } else {
                          _3258 = _3245;
                        }
                        float _3259 = dot(float3(_3138, _3139, _3140), float3(_195, _196, _197));
                        float _3260 = _3259 * 0.5f;
                        float _3261 = _3260 + 0.5f;
                        float _3262 = saturate(_3261);
                        float _3263 = _3262 * _3258;
                        float _3264 = _3263 * _3233.z;
                        float _3265 = _3264 + _3055;
                        float _3266 = _3264 + _3056;
                        float _3267 = _3264 + _3057;
                        float _3268 = _3263 + _3058;
                        _3270 = _3265;
                        _3271 = _3266;
                        _3272 = _3267;
                        _3273 = _3268;
                        _3274 = _3246;
                      } else {
                        _3270 = _3055;
                        _3271 = _3056;
                        _3272 = _3057;
                        _3273 = _3058;
                        _3274 = _3059;
                      }
                    } else {
                      _3270 = _3055;
                      _3271 = _3056;
                      _3272 = _3057;
                      _3273 = _3058;
                      _3274 = _3059;
                    }
                    int _3275 = _3060 + 1;
                    bool _3276 = (_3275 == 8);
                    if (!_3276) {
                      _3055 = _3270;
                      _3056 = _3271;
                      _3057 = _3272;
                      _3058 = _3273;
                      _3059 = _3274;
                      _3060 = _3275;
                      continue;
                    }
                    break;
                  }
                  while(true) {
                    bool _3053 = (_3273 > 9.999999747378752e-06f);
                    if (_3053) {
                      float _3278 = _3270 / _3273;
                      float _3279 = _3271 / _3273;
                      float _3280 = _3272 / _3273;
                      _3288 = _3278;
                      _3289 = _3279;
                      _3290 = _3280;
                      _3291 = _3273;
                    } else {
                      bool _3282 = (_3274 > 9.999999747378752e-06f);
                      if (_3282) {
                        float _3284 = _3270 / _3274;
                        float _3285 = _3271 / _3274;
                        float _3286 = _3272 / _3274;
                        _3288 = _3284;
                        _3289 = _3285;
                        _3290 = _3286;
                        _3291 = _3274;
                      } else {
                        _3288 = 0.0f;
                        _3289 = 0.0f;
                        _3290 = 0.0f;
                        _3291 = 0.0f;
                      }
                    }
                    bool _3292 = (_3291 < 9.999999747378752e-06f);
                    if (_3292) {
                      _3295 = _2984;
                      _3296 = _2985;
                      _3297 = _2986;
                      _3298 = _2988;
                      _3299 = _2989;
                      _3300 = 0.0f;
                      _3301 = 0;
                      _3302 = _3288;
                      _3303 = _3289;
                      _3304 = _3290;
                    } else {
                      _3295 = _2984;
                      _3296 = _2985;
                      _3297 = _2986;
                      _3298 = _2988;
                      _3299 = _2989;
                      _3300 = _2663;
                      _3301 = _2987;
                      _3302 = _3288;
                      _3303 = _3289;
                      _3304 = _3290;
                    }
                    break;
                  }
                } else {
                  _3295 = _2979;
                  _3296 = _2980;
                  _3297 = _2981;
                  _3298 = _2679;
                  _3299 = _2678;
                  _3300 = _2663;
                  _3301 = 0;
                  _3302 = 0.0f;
                  _3303 = 0.0f;
                  _3304 = 0.0f;
                }
              } else {
                _2984 = _2973;
                _2985 = _2974;
                _2986 = _2975;
                _2987 = 1;
                _2988 = 0;
                _2989 = 0.0f;
                float _3022 = cb7_009z * _195;
                float _3023 = cb7_009z * _196;
                float _3024 = cb7_009z * _197;
                float _3025 = _3022 + _275;
                float _3026 = _3023 + _277;
                float _3027 = _3024 + _279;
                float _3028 = _3025 * cb7_011x;
                float _3029 = _3026 * cb7_011y;
                float _3030 = _3027 * cb7_011z;
                float _3031 = _3028 + cb7_012x;
                float _3032 = _3029 + cb7_012y;
                float _3033 = _3030 + cb7_012z;
                int _3034 = int(_3031);
                int _3035 = int(_3032);
                int _3036 = int(_3033);
                uint _3037 = (uint)(cb7_002x) + -1u;
                uint _3038 = (uint)(cb7_002y) + -1u;
                uint _3039 = (uint)(cb7_002z) + -1u;
                int _3040 = max(_3034, 0);
                int _3041 = max(_3035, 0);
                int _3042 = max(_3036, 0);
                int _3043 = min(_3040, _3037);
                int _3044 = min(_3041, _3038);
                int _3045 = min(_3042, _3039);
                float _3046 = float((int)(_3043));
                float _3047 = float((int)(_3044));
                float _3048 = float((int)(_3045));
                float _3049 = _3031 - _3046;
                float _3050 = _3032 - _3047;
                float _3051 = _3033 - _3048;
                _3055 = 0.0f;
                _3056 = 0.0f;
                _3057 = 0.0f;
                _3058 = 0.0f;
                _3059 = 0.0f;
                _3060 = 0;
                while(true) {
                  int _3061 = (uint)(_3060) >> 1;
                  int _3062 = (uint)(_3060) >> 2;
                  int _3063 = _3060 & 1;
                  int _3064 = _3061 & 1;
                  int _3065 = _3062 & 1;
                  uint _3066 = _3063 + _3043;
                  uint _3067 = _3064 + _3044;
                  uint _3068 = _3065 + _3045;
                  bool _3069 = ((int)_3066 >= (int)cb7_002x);
                  bool _3070 = ((int)_3067 >= (int)cb7_002y);
                  bool _3071 = ((int)_3068 >= (int)cb7_002z);
                  bool _3072 = _3069 || _3070;
                  bool _3073 = _3071 || _3072;
                  if (!_3073) {
                    uint _3075 = (uint)(cb7_002x) - (uint)(cb7_007x);
                    uint _3076 = _3075 + _3066;
                    uint _3077 = (uint)(cb7_002y) - (uint)(cb7_007y);
                    uint _3078 = _3077 + _3067;
                    uint _3079 = (uint)(cb7_002z) - (uint)(cb7_007z);
                    uint _3080 = _3079 + _3068;
                    int _3081 = _3076 % cb7_002x;
                    int _3082 = _3078 % cb7_002y;
                    int _3083 = _3080 % cb7_002z;
                    uint _3085 = t38.Load(int4(_3081, _3082, _3083, 0));
                    int _3087 = _3085.x & 511;
                    int _3088 = (uint)((uint)(_3085.x)) >> 9;
                    float4 _3091 = t34[0].Load(int3(_3087, _3088, 0));
                    uint _3093 = t38.Load(int4(_3081, _3082, _3083, 0));
                    int _3095 = _3093.x & 127;
                    int _3096 = (uint)((uint)(_3093.x)) >> 7;
                    int _3097 = _3096 & 127;
                    int _3098 = (uint)((uint)(_3093.x)) >> 14;
                    int _3099 = _3096 | _3093.x;
                    int _3100 = _3099 & 127;
                    int _3101 = _3100 | _3098;
                    bool _3102 = (_3101 == 0);
                    if (!_3102) {
                      float _3105 = _3091.z * 0.44999998807907104f;
                      float _3107 = _3091.y * 0.44999998807907104f;
                      float _3109 = _3091.x * 0.44999998807907104f;
                      float _3110 = float((int)(_3063));
                      float _3111 = float((int)(_3064));
                      float _3112 = float((int)(_3065));
                      float _3113 = _3046 - cb7_010x;
                      float _3114 = _3113 + _3110;
                      float _3115 = _3114 + _3109;
                      float _3116 = _3115 * cb7_001x;
                      float _3117 = cb7_000x - _3025;
                      float _3118 = _3116 + _3117;
                      float _3119 = _3047 - cb7_010y;
                      float _3120 = _3119 + _3111;
                      float _3121 = _3120 + _3107;
                      float _3122 = _3121 * cb7_001y;
                      float _3123 = cb7_000y - _3026;
                      float _3124 = _3122 + _3123;
                      float _3125 = _3048 - cb7_010z;
                      float _3126 = _3125 + _3112;
                      float _3127 = _3126 + _3105;
                      float _3128 = _3127 * cb7_001z;
                      float _3129 = cb7_000z - _3027;
                      float _3130 = _3128 + _3129;
                      float _3131 = _3118 * _3118;
                      float _3132 = _3124 * _3124;
                      float _3133 = _3131 + _3132;
                      float _3134 = _3130 * _3130;
                      float _3135 = _3133 + _3134;
                      float _3136 = sqrt(_3135);
                      float _3137 = max(_3136, 9.999999747378752e-06f);
                      float _3138 = _3118 / _3137;
                      float _3139 = _3124 / _3137;
                      float _3140 = _3130 / _3137;
                      float _3141 = -0.0f - _3138;
                      float _3142 = -0.0f - _3139;
                      float _3143 = -0.0f - _3140;
                      float _3144 = abs(_3141);
                      float _3145 = abs(_3142);
                      float _3146 = _3145 + _3144;
                      float _3147 = abs(_3143);
                      float _3148 = _3146 + _3147;
                      float _3149 = _3141 / _3148;
                      float _3150 = _3142 / _3148;
                      float _3151 = _3143 / _3148;
                      bool _3152 = (_3151 > 0.0f);
                      if (!_3152) {
                        float _3154 = abs(_3150);
                        float _3155 = abs(_3149);
                        float _3156 = 1.0f - _3154;
                        float _3157 = 1.0f - _3155;
                        bool _3158 = (_3149 > 0.0f);
                        bool _3159 = (_3150 > 0.0f);
                        bool _3160 = (_3149 < 0.0f);
                        bool _3161 = (_3150 < 0.0f);
                        int _3162 = (int)(uint)(_3158);
                        int _3163 = (int)(uint)(_3159);
                        int _3164 = (int)(uint)(_3160);
                        int _3165 = (int)(uint)(_3161);
                        int _3166 = _3162 - _3164;
                        int _3167 = _3163 - _3165;
                        float _3168 = float((int)(_3166));
                        float _3169 = float((int)(_3167));
                        float _3170 = _3156 * _3168;
                        float _3171 = _3157 * _3169;
                        _3173 = _3170;
                        _3174 = _3171;
                      } else {
                        _3173 = _3149;
                        _3174 = _3150;
                      }
                      float _3175 = float((int)(cb7_005w));
                      float _3176 = _3175 * 0.5f;
                      float _3177 = _3175 + 2.0f;
                      float _3178 = _3176 / _3177;
                      float _3179 = float((int)(_3095));
                      float _3180 = float((int)(_3097));
                      float _3181 = _3179 + 0.5f;
                      float _3182 = _3180 + 0.5f;
                      float _3183 = _3178 * _3173;
                      float _3184 = _3178 * _3174;
                      float _3185 = _3183 + _3181;
                      float _3186 = _3184 + _3182;
                      float _3187 = _3185 * 0.0078125f;
                      float _3188 = _3186 * 0.0078125f;
                      float _3189 = float((int)(_3098));
                      float3 _3193 = t30[0].SampleLevel(s7, float3(_3187, _3188, _3189), 0.0f);
                      float _3196 = abs(cb13_000x);
                      float _3197 = abs(cb13_000y);
                      float _3198 = _3197 + _3196;
                      float _3199 = abs(cb13_000z);
                      float _3200 = _3198 + _3199;
                      float _3201 = cb13_000x / _3200;
                      float _3202 = cb13_000y / _3200;
                      float _3203 = cb13_000z / _3200;
                      bool _3204 = (_3203 > 0.0f);
                      if (!_3204) {
                        float _3206 = abs(_3202);
                        float _3207 = abs(_3201);
                        float _3208 = 1.0f - _3206;
                        float _3209 = 1.0f - _3207;
                        bool _3210 = (_3201 > 0.0f);
                        bool _3211 = (_3202 > 0.0f);
                        bool _3212 = (_3201 < 0.0f);
                        bool _3213 = (_3202 < 0.0f);
                        int _3214 = (int)(uint)(_3210);
                        int _3215 = (int)(uint)(_3211);
                        int _3216 = (int)(uint)(_3212);
                        int _3217 = (int)(uint)(_3213);
                        int _3218 = _3214 - _3216;
                        int _3219 = _3215 - _3217;
                        float _3220 = float((int)(_3218));
                        float _3221 = float((int)(_3219));
                        float _3222 = _3208 * _3220;
                        float _3223 = _3209 * _3221;
                        _3225 = _3222;
                        _3226 = _3223;
                      } else {
                        _3225 = _3201;
                        _3226 = _3202;
                      }
                      float _3227 = _3225 * _3178;
                      float _3228 = _3226 * _3178;
                      float _3229 = _3227 + _3181;
                      float _3230 = _3228 + _3182;
                      float _3231 = _3229 * 0.0078125f;
                      float _3232 = _3230 * 0.0078125f;
                      float3 _3233 = t30[0].SampleLevel(s7, float3(_3231, _3232, _3189), 0.0f);
                      float _3235 = 1.0f - _3049;
                      float _3236 = 1.0f - _3050;
                      float _3237 = 1.0f - _3051;
                      bool _3238 = (_3063 != 0);
                      bool _3239 = (_3064 != 0);
                      bool _3240 = (_3065 != 0);
                      float _3241 = select(_3238, _3049, _3235);
                      float _3242 = select(_3239, _3050, _3236);
                      float _3243 = select(_3240, _3051, _3237);
                      float _3244 = _3242 * _3241;
                      float _3245 = _3244 * _3243;
                      float _3246 = _3245 + _3059;
                      bool _3247 = (_3136 > _3193.x);
                      if (_3247) {
                        float _3249 = _3193.x * _3193.x;
                        float _3250 = _3193.y - _3249;
                        float _3251 = abs(_3250);
                        float _3252 = _3136 - _3193.x;
                        float _3253 = _3252 * _3252;
                        float _3254 = _3251 + _3253;
                        float _3255 = _3251 / _3254;
                        float _3256 = _3255 * _3245;
                        _3258 = _3256;
                      } else {
                        _3258 = _3245;
                      }
                      float _3259 = dot(float3(_3138, _3139, _3140), float3(_195, _196, _197));
                      float _3260 = _3259 * 0.5f;
                      float _3261 = _3260 + 0.5f;
                      float _3262 = saturate(_3261);
                      float _3263 = _3262 * _3258;
                      float _3264 = _3263 * _3233.z;
                      float _3265 = _3264 + _3055;
                      float _3266 = _3264 + _3056;
                      float _3267 = _3264 + _3057;
                      float _3268 = _3263 + _3058;
                      _3270 = _3265;
                      _3271 = _3266;
                      _3272 = _3267;
                      _3273 = _3268;
                      _3274 = _3246;
                    } else {
                      _3270 = _3055;
                      _3271 = _3056;
                      _3272 = _3057;
                      _3273 = _3058;
                      _3274 = _3059;
                    }
                  } else {
                    _3270 = _3055;
                    _3271 = _3056;
                    _3272 = _3057;
                    _3273 = _3058;
                    _3274 = _3059;
                  }
                  int _3275 = _3060 + 1;
                  bool _3276 = (_3275 == 8);
                  if (!_3276) {
                    _3055 = _3270;
                    _3056 = _3271;
                    _3057 = _3272;
                    _3058 = _3273;
                    _3059 = _3274;
                    _3060 = _3275;
                    continue;
                  }
                  break;
                }
                while(true) {
                  bool _3053 = (_3273 > 9.999999747378752e-06f);
                  if (_3053) {
                    float _3278 = _3270 / _3273;
                    float _3279 = _3271 / _3273;
                    float _3280 = _3272 / _3273;
                    _3288 = _3278;
                    _3289 = _3279;
                    _3290 = _3280;
                    _3291 = _3273;
                  } else {
                    bool _3282 = (_3274 > 9.999999747378752e-06f);
                    if (_3282) {
                      float _3284 = _3270 / _3274;
                      float _3285 = _3271 / _3274;
                      float _3286 = _3272 / _3274;
                      _3288 = _3284;
                      _3289 = _3285;
                      _3290 = _3286;
                      _3291 = _3274;
                    } else {
                      _3288 = 0.0f;
                      _3289 = 0.0f;
                      _3290 = 0.0f;
                      _3291 = 0.0f;
                    }
                  }
                  bool _3292 = (_3291 < 9.999999747378752e-06f);
                  if (_3292) {
                    _3295 = _2984;
                    _3296 = _2985;
                    _3297 = _2986;
                    _3298 = _2988;
                    _3299 = _2989;
                    _3300 = 0.0f;
                    _3301 = 0;
                    _3302 = _3288;
                    _3303 = _3289;
                    _3304 = _3290;
                  } else {
                    _3295 = _2984;
                    _3296 = _2985;
                    _3297 = _2986;
                    _3298 = _2988;
                    _3299 = _2989;
                    _3300 = _2663;
                    _3301 = _2987;
                    _3302 = _3288;
                    _3303 = _3289;
                    _3304 = _3290;
                  }
                  break;
                }
              }
              break;
            }
          } else {
            _2979 = 0.0f;
            _2980 = 0.0f;
            _2981 = 0.0f;
            bool _2982 = (_2680 == 0);
            if (!_2982) {
              _2984 = _2979;
              _2985 = _2980;
              _2986 = _2981;
              _2987 = _2680;
              _2988 = _2679;
              _2989 = _2678;
              float _3022 = cb7_009z * _195;
              float _3023 = cb7_009z * _196;
              float _3024 = cb7_009z * _197;
              float _3025 = _3022 + _275;
              float _3026 = _3023 + _277;
              float _3027 = _3024 + _279;
              float _3028 = _3025 * cb7_011x;
              float _3029 = _3026 * cb7_011y;
              float _3030 = _3027 * cb7_011z;
              float _3031 = _3028 + cb7_012x;
              float _3032 = _3029 + cb7_012y;
              float _3033 = _3030 + cb7_012z;
              int _3034 = int(_3031);
              int _3035 = int(_3032);
              int _3036 = int(_3033);
              uint _3037 = (uint)(cb7_002x) + -1u;
              uint _3038 = (uint)(cb7_002y) + -1u;
              uint _3039 = (uint)(cb7_002z) + -1u;
              int _3040 = max(_3034, 0);
              int _3041 = max(_3035, 0);
              int _3042 = max(_3036, 0);
              int _3043 = min(_3040, _3037);
              int _3044 = min(_3041, _3038);
              int _3045 = min(_3042, _3039);
              float _3046 = float((int)(_3043));
              float _3047 = float((int)(_3044));
              float _3048 = float((int)(_3045));
              float _3049 = _3031 - _3046;
              float _3050 = _3032 - _3047;
              float _3051 = _3033 - _3048;
              _3055 = 0.0f;
              _3056 = 0.0f;
              _3057 = 0.0f;
              _3058 = 0.0f;
              _3059 = 0.0f;
              _3060 = 0;
              while(true) {
                int _3061 = (uint)(_3060) >> 1;
                int _3062 = (uint)(_3060) >> 2;
                int _3063 = _3060 & 1;
                int _3064 = _3061 & 1;
                int _3065 = _3062 & 1;
                uint _3066 = _3063 + _3043;
                uint _3067 = _3064 + _3044;
                uint _3068 = _3065 + _3045;
                bool _3069 = ((int)_3066 >= (int)cb7_002x);
                bool _3070 = ((int)_3067 >= (int)cb7_002y);
                bool _3071 = ((int)_3068 >= (int)cb7_002z);
                bool _3072 = _3069 || _3070;
                bool _3073 = _3071 || _3072;
                if (!_3073) {
                  uint _3075 = (uint)(cb7_002x) - (uint)(cb7_007x);
                  uint _3076 = _3075 + _3066;
                  uint _3077 = (uint)(cb7_002y) - (uint)(cb7_007y);
                  uint _3078 = _3077 + _3067;
                  uint _3079 = (uint)(cb7_002z) - (uint)(cb7_007z);
                  uint _3080 = _3079 + _3068;
                  int _3081 = _3076 % cb7_002x;
                  int _3082 = _3078 % cb7_002y;
                  int _3083 = _3080 % cb7_002z;
                  uint _3085 = t38.Load(int4(_3081, _3082, _3083, 0));
                  int _3087 = _3085.x & 511;
                  int _3088 = (uint)((uint)(_3085.x)) >> 9;
                  float4 _3091 = t34[0].Load(int3(_3087, _3088, 0));
                  uint _3093 = t38.Load(int4(_3081, _3082, _3083, 0));
                  int _3095 = _3093.x & 127;
                  int _3096 = (uint)((uint)(_3093.x)) >> 7;
                  int _3097 = _3096 & 127;
                  int _3098 = (uint)((uint)(_3093.x)) >> 14;
                  int _3099 = _3096 | _3093.x;
                  int _3100 = _3099 & 127;
                  int _3101 = _3100 | _3098;
                  bool _3102 = (_3101 == 0);
                  if (!_3102) {
                    float _3105 = _3091.z * 0.44999998807907104f;
                    float _3107 = _3091.y * 0.44999998807907104f;
                    float _3109 = _3091.x * 0.44999998807907104f;
                    float _3110 = float((int)(_3063));
                    float _3111 = float((int)(_3064));
                    float _3112 = float((int)(_3065));
                    float _3113 = _3046 - cb7_010x;
                    float _3114 = _3113 + _3110;
                    float _3115 = _3114 + _3109;
                    float _3116 = _3115 * cb7_001x;
                    float _3117 = cb7_000x - _3025;
                    float _3118 = _3116 + _3117;
                    float _3119 = _3047 - cb7_010y;
                    float _3120 = _3119 + _3111;
                    float _3121 = _3120 + _3107;
                    float _3122 = _3121 * cb7_001y;
                    float _3123 = cb7_000y - _3026;
                    float _3124 = _3122 + _3123;
                    float _3125 = _3048 - cb7_010z;
                    float _3126 = _3125 + _3112;
                    float _3127 = _3126 + _3105;
                    float _3128 = _3127 * cb7_001z;
                    float _3129 = cb7_000z - _3027;
                    float _3130 = _3128 + _3129;
                    float _3131 = _3118 * _3118;
                    float _3132 = _3124 * _3124;
                    float _3133 = _3131 + _3132;
                    float _3134 = _3130 * _3130;
                    float _3135 = _3133 + _3134;
                    float _3136 = sqrt(_3135);
                    float _3137 = max(_3136, 9.999999747378752e-06f);
                    float _3138 = _3118 / _3137;
                    float _3139 = _3124 / _3137;
                    float _3140 = _3130 / _3137;
                    float _3141 = -0.0f - _3138;
                    float _3142 = -0.0f - _3139;
                    float _3143 = -0.0f - _3140;
                    float _3144 = abs(_3141);
                    float _3145 = abs(_3142);
                    float _3146 = _3145 + _3144;
                    float _3147 = abs(_3143);
                    float _3148 = _3146 + _3147;
                    float _3149 = _3141 / _3148;
                    float _3150 = _3142 / _3148;
                    float _3151 = _3143 / _3148;
                    bool _3152 = (_3151 > 0.0f);
                    if (!_3152) {
                      float _3154 = abs(_3150);
                      float _3155 = abs(_3149);
                      float _3156 = 1.0f - _3154;
                      float _3157 = 1.0f - _3155;
                      bool _3158 = (_3149 > 0.0f);
                      bool _3159 = (_3150 > 0.0f);
                      bool _3160 = (_3149 < 0.0f);
                      bool _3161 = (_3150 < 0.0f);
                      int _3162 = (int)(uint)(_3158);
                      int _3163 = (int)(uint)(_3159);
                      int _3164 = (int)(uint)(_3160);
                      int _3165 = (int)(uint)(_3161);
                      int _3166 = _3162 - _3164;
                      int _3167 = _3163 - _3165;
                      float _3168 = float((int)(_3166));
                      float _3169 = float((int)(_3167));
                      float _3170 = _3156 * _3168;
                      float _3171 = _3157 * _3169;
                      _3173 = _3170;
                      _3174 = _3171;
                    } else {
                      _3173 = _3149;
                      _3174 = _3150;
                    }
                    float _3175 = float((int)(cb7_005w));
                    float _3176 = _3175 * 0.5f;
                    float _3177 = _3175 + 2.0f;
                    float _3178 = _3176 / _3177;
                    float _3179 = float((int)(_3095));
                    float _3180 = float((int)(_3097));
                    float _3181 = _3179 + 0.5f;
                    float _3182 = _3180 + 0.5f;
                    float _3183 = _3178 * _3173;
                    float _3184 = _3178 * _3174;
                    float _3185 = _3183 + _3181;
                    float _3186 = _3184 + _3182;
                    float _3187 = _3185 * 0.0078125f;
                    float _3188 = _3186 * 0.0078125f;
                    float _3189 = float((int)(_3098));
                    float3 _3193 = t30[0].SampleLevel(s7, float3(_3187, _3188, _3189), 0.0f);
                    float _3196 = abs(cb13_000x);
                    float _3197 = abs(cb13_000y);
                    float _3198 = _3197 + _3196;
                    float _3199 = abs(cb13_000z);
                    float _3200 = _3198 + _3199;
                    float _3201 = cb13_000x / _3200;
                    float _3202 = cb13_000y / _3200;
                    float _3203 = cb13_000z / _3200;
                    bool _3204 = (_3203 > 0.0f);
                    if (!_3204) {
                      float _3206 = abs(_3202);
                      float _3207 = abs(_3201);
                      float _3208 = 1.0f - _3206;
                      float _3209 = 1.0f - _3207;
                      bool _3210 = (_3201 > 0.0f);
                      bool _3211 = (_3202 > 0.0f);
                      bool _3212 = (_3201 < 0.0f);
                      bool _3213 = (_3202 < 0.0f);
                      int _3214 = (int)(uint)(_3210);
                      int _3215 = (int)(uint)(_3211);
                      int _3216 = (int)(uint)(_3212);
                      int _3217 = (int)(uint)(_3213);
                      int _3218 = _3214 - _3216;
                      int _3219 = _3215 - _3217;
                      float _3220 = float((int)(_3218));
                      float _3221 = float((int)(_3219));
                      float _3222 = _3208 * _3220;
                      float _3223 = _3209 * _3221;
                      _3225 = _3222;
                      _3226 = _3223;
                    } else {
                      _3225 = _3201;
                      _3226 = _3202;
                    }
                    float _3227 = _3225 * _3178;
                    float _3228 = _3226 * _3178;
                    float _3229 = _3227 + _3181;
                    float _3230 = _3228 + _3182;
                    float _3231 = _3229 * 0.0078125f;
                    float _3232 = _3230 * 0.0078125f;
                    float3 _3233 = t30[0].SampleLevel(s7, float3(_3231, _3232, _3189), 0.0f);
                    float _3235 = 1.0f - _3049;
                    float _3236 = 1.0f - _3050;
                    float _3237 = 1.0f - _3051;
                    bool _3238 = (_3063 != 0);
                    bool _3239 = (_3064 != 0);
                    bool _3240 = (_3065 != 0);
                    float _3241 = select(_3238, _3049, _3235);
                    float _3242 = select(_3239, _3050, _3236);
                    float _3243 = select(_3240, _3051, _3237);
                    float _3244 = _3242 * _3241;
                    float _3245 = _3244 * _3243;
                    float _3246 = _3245 + _3059;
                    bool _3247 = (_3136 > _3193.x);
                    if (_3247) {
                      float _3249 = _3193.x * _3193.x;
                      float _3250 = _3193.y - _3249;
                      float _3251 = abs(_3250);
                      float _3252 = _3136 - _3193.x;
                      float _3253 = _3252 * _3252;
                      float _3254 = _3251 + _3253;
                      float _3255 = _3251 / _3254;
                      float _3256 = _3255 * _3245;
                      _3258 = _3256;
                    } else {
                      _3258 = _3245;
                    }
                    float _3259 = dot(float3(_3138, _3139, _3140), float3(_195, _196, _197));
                    float _3260 = _3259 * 0.5f;
                    float _3261 = _3260 + 0.5f;
                    float _3262 = saturate(_3261);
                    float _3263 = _3262 * _3258;
                    float _3264 = _3263 * _3233.z;
                    float _3265 = _3264 + _3055;
                    float _3266 = _3264 + _3056;
                    float _3267 = _3264 + _3057;
                    float _3268 = _3263 + _3058;
                    _3270 = _3265;
                    _3271 = _3266;
                    _3272 = _3267;
                    _3273 = _3268;
                    _3274 = _3246;
                  } else {
                    _3270 = _3055;
                    _3271 = _3056;
                    _3272 = _3057;
                    _3273 = _3058;
                    _3274 = _3059;
                  }
                } else {
                  _3270 = _3055;
                  _3271 = _3056;
                  _3272 = _3057;
                  _3273 = _3058;
                  _3274 = _3059;
                }
                int _3275 = _3060 + 1;
                bool _3276 = (_3275 == 8);
                if (!_3276) {
                  _3055 = _3270;
                  _3056 = _3271;
                  _3057 = _3272;
                  _3058 = _3273;
                  _3059 = _3274;
                  _3060 = _3275;
                  continue;
                }
                break;
              }
              while(true) {
                bool _3053 = (_3273 > 9.999999747378752e-06f);
                if (_3053) {
                  float _3278 = _3270 / _3273;
                  float _3279 = _3271 / _3273;
                  float _3280 = _3272 / _3273;
                  _3288 = _3278;
                  _3289 = _3279;
                  _3290 = _3280;
                  _3291 = _3273;
                } else {
                  bool _3282 = (_3274 > 9.999999747378752e-06f);
                  if (_3282) {
                    float _3284 = _3270 / _3274;
                    float _3285 = _3271 / _3274;
                    float _3286 = _3272 / _3274;
                    _3288 = _3284;
                    _3289 = _3285;
                    _3290 = _3286;
                    _3291 = _3274;
                  } else {
                    _3288 = 0.0f;
                    _3289 = 0.0f;
                    _3290 = 0.0f;
                    _3291 = 0.0f;
                  }
                }
                bool _3292 = (_3291 < 9.999999747378752e-06f);
                if (_3292) {
                  _3295 = _2984;
                  _3296 = _2985;
                  _3297 = _2986;
                  _3298 = _2988;
                  _3299 = _2989;
                  _3300 = 0.0f;
                  _3301 = 0;
                  _3302 = _3288;
                  _3303 = _3289;
                  _3304 = _3290;
                } else {
                  _3295 = _2984;
                  _3296 = _2985;
                  _3297 = _2986;
                  _3298 = _2988;
                  _3299 = _2989;
                  _3300 = _2663;
                  _3301 = _2987;
                  _3302 = _3288;
                  _3303 = _3289;
                  _3304 = _3290;
                }
                break;
              }
            } else {
              _3295 = _2979;
              _3296 = _2980;
              _3297 = _2981;
              _3298 = _2679;
              _3299 = _2678;
              _3300 = _2663;
              _3301 = 0;
              _3302 = 0.0f;
              _3303 = 0.0f;
              _3304 = 0.0f;
            }
          }
          bool _3307 = (cb7_007w == 1);
          float _3308 = select(_3307, 1.0f, _3295);
          float _3309 = select(_3307, 0.0f, _3296);
          float _3310 = select(_3307, 0.0f, _3297);
          float _3311 = select(_3307, 0.0f, _3302);
          float _3312 = select(_3307, 0.0f, _3303);
          float _3313 = select(_3307, 1.0f, _3304);
          int _3314 = _3301 | _3298;
          bool _3315 = (_3314 == 0);
          bool _3316 = (_3300 < 1.0f);
          bool _3317 = _3316 || _3315;
          if (_3317) {
            float _3319 = dot(float3(_195, _196, _197), float3(cb13_000x, cb13_000y, cb13_000z));
            float _3320 = _3319 * 0.5f;
            float _3321 = _3320 + 0.5f;
            float _3322 = select(_3307, 0.0f, _3321);
            float _3323 = select(_3307, 1.0f, _3321);
            float _3324 = _3311 - _3322;
            float _3325 = _3312 - _3323;
            float _3326 = _3313 - _3322;
            float _3327 = _3324 * _3300;
            float _3328 = _3325 * _3300;
            float _3329 = _3326 * _3300;
            float _3330 = _3327 + _3322;
            float _3331 = _3328 + _3323;
            float _3332 = _3329 + _3322;
            bool _3333 = (_3314 != 0);
            float _3334 = select(_3333, _3299, 0.0f);
            _3336 = _3334;
            _3337 = _3330;
            _3338 = _3331;
            _3339 = _3332;
          } else {
            _3336 = _3299;
            _3337 = _3311;
            _3338 = _3312;
            _3339 = _3313;
          }
          float _3340 = _3308 - _3337;
          float _3341 = _3309 - _3338;
          float _3342 = _3310 - _3339;
          float _3343 = _3340 * _3336;
          float _3344 = _3341 * _3336;
          float _3345 = _3342 * _3336;
          float _3346 = _3343 + _3337;
          float _3347 = _3344 + _3338;
          float _3348 = _3345 + _3339;
          bool _3349 = isnan(_3346);
          bool _3350 = isnan(_3347);
          bool _3351 = isnan(_3348);
          bool _3352 = _3349 || _3350;
          bool _3353 = _3352 || _3351;
          float _3354 = select(_3353, 0.0f, _3346);
          _3356 = _3354;
        } else {
          _3356 = 1.0f;
        }
        float _3357 = _3356 * _2591;
        _3359 = _3357;
      }
      float _3364 = dot(float3(_195, _196, _197), float3(cb13_000x, cb13_000y, cb13_000z));
      float _3365 = saturate(_3364);
      float _3366 = _271 * _271;
      float _3367 = _272 * _272;
      float _3368 = _3366 + _3367;
      float _3369 = sqrt(_3368);
      float _3372 = cb12_219z * _279;
      float _3374 = _3372 + cb12_219w;
      float _3375 = saturate(_3374);
      float _3384 = cb13_061x - cb13_062x;
      float _3385 = cb13_061y - cb13_062y;
      float _3386 = cb13_061z - cb13_062z;
      float _3387 = _3384 * _3375;
      float _3388 = _3385 * _3375;
      float _3389 = _3386 * _3375;
      float _3390 = _3387 + cb13_062x;
      float _3391 = _3388 + cb13_062y;
      float _3392 = _3389 + cb13_062z;
      float _3394 = cb12_219x * _3369;
      float _3396 = _3394 + cb12_219y;
      float _3397 = saturate(_3396);
      float _3402 = _3390 - cb13_001x;
      float _3403 = _3391 - cb13_001y;
      float _3404 = _3392 - cb13_001z;
      float _3405 = _3402 * _3397;
      float _3406 = _3403 * _3397;
      float _3407 = _3404 * _3397;
      float _3408 = _3405 + cb13_001x;
      float _3409 = _3406 + cb13_001y;
      float _3410 = _3407 + cb13_001z;
      float _3411 = _3359 * cb0_000z;
      float _3412 = _3411 * _3365;
      float _3413 = _3408 * _3412;
      float _3414 = _3409 * _3412;
      float _3415 = _3410 * _3412;
      // GRAPHICS HIT BEGIN
      GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
          float3(_275, _277, _279), float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
      if (any(water_light.sun != float3(cb13_000x, cb13_000y, cb13_000z)) || any(water_light.direct != 1.f)) {
        float cosine = saturate(dot(float3(_195, _196, _197), water_light.sun));
        _3413 = _3408 * _3411 * cosine;
        _3414 = _3409 * _3411 * cosine;
        _3415 = _3410 * _3411 * cosine;
      }
      if (graphics_hit) {
        float3 diffuse, specular;
        GraphicsHitBRDF(float3(_195, _196, _197), float3(_472, _473, _474),
            water_light.sun, graphics_material, diffuse, specular);
        _3413 = _3408 * _3411 * diffuse.x;
        _3414 = _3409 * _3411 * diffuse.y;
        _3415 = _3410 * _3411 * diffuse.z;
        graphics_specular += float3(_3408, _3409, _3410) * (_3411 * specular) * water_light.direct;
      }
      _3413 *= water_light.direct.x;
      _3414 *= water_light.direct.y;
      _3415 *= water_light.direct.z;
      // GRAPHICS HIT END
      float _3418 = _2277 + (cb0_004y * GRAPHICS_RAY_SKYLIGHT);
      float _3419 = _3418 + _3413;
      float _3420 = _2278 + (cb0_004y * GRAPHICS_RAY_SKYLIGHT);
      float _3421 = _3420 + _3414;
      float _3422 = _2279 + (cb0_004y * GRAPHICS_RAY_SKYLIGHT);
      float _3423 = _3422 + _3415;
      float _3424 = min(_464, 0.8999999761581421f);
      float _3425 = min(_465, 0.8999999761581421f);
      float _3426 = min(_466, 0.8999999761581421f);
      float _3428 = cb0_004w * 0.31830987334251404f;
      float _3429 = _3428 * _3424;
      float _3430 = _3429 * _3419;
      float _3431 = _3428 * _3425;
      float _3432 = _3431 * _3421;
      float _3433 = _3426 * _3428;
      float _3434 = _3433 * _3423;
      // GRAPHICS HIT BEGIN
      if (graphics_hit) {
        _3430 += cb0_004w * graphics_specular.x;
        _3432 += cb0_004w * graphics_specular.y;
        _3434 += cb0_004w * graphics_specular.z;
      }
      // GRAPHICS HIT END
      u4[int2(_178, _179)] = float4(_3430, _3432, _3434, 1.0f);
    }
  }
}
