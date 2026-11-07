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

Texture2DArray<float4> t28[2] : register(t28);

Texture2DArray<float3> t30[2] : register(t30);

Texture2D<uint> t32[2] : register(t32);

Texture2D<float4> t34[2] : register(t34);

Texture2DArray<uint> t38 : register(t38);

StructuredBuffer<LightParams> t16 : register(t16);

Texture2DArray<float> t9 : register(t9);

TextureCubeArray<float> t10 : register(t10);

Texture2DArray<float4> t42 : register(t42);

StructuredBuffer<range> t25 : register(t25);

StructuredBuffer<light> t26 : register(t26);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t39 : register(t39);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t11 : register(t11);

Texture2D<float4> t12 : register(t12);

Texture2D<float> t13 : register(t13);

Texture2D<float4> t27 : register(t27);

RWTexture2D<float4> u5 : register(u5);

cbuffer cb12 : register(b12) {
#ifdef WITCHER_GRAPHICS_CUSTOM_LIGHTING
  float hartapfel_skylight : packoffset(c185.w);
  float4 hartapfel_jitter : packoffset(c286);
#endif
  float cb12_000x : packoffset(c000.x);
  float cb12_000y : packoffset(c000.y);
  float cb12_000z : packoffset(c000.z);
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
  float cb12_044x : packoffset(c044.x);
  float cb12_044y : packoffset(c044.y);
  float cb12_044z : packoffset(c044.z);
  float cb12_045x : packoffset(c045.x);
  float cb12_045y : packoffset(c045.y);
  float cb12_045z : packoffset(c045.z);
  float cb12_046x : packoffset(c046.x);
  float cb12_046y : packoffset(c046.y);
  float cb12_046z : packoffset(c046.z);
  float cb12_046w : packoffset(c046.w);
  float cb12_047x : packoffset(c047.x);
  float cb12_047y : packoffset(c047.y);
  float cb12_047z : packoffset(c047.z);
  float cb12_048x : packoffset(c048.x);
  float cb12_048y : packoffset(c048.y);
  float cb12_048z : packoffset(c048.z);
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
  float cb12_219x : packoffset(c219.x);
  float cb12_219y : packoffset(c219.y);
  float cb12_219z : packoffset(c219.z);
  float cb12_219w : packoffset(c219.w);
  float cb12_225y : packoffset(c225.y);
  float cb12_225z : packoffset(c225.z);
  int cb12_287z : packoffset(c287.z);
  uint cb12_padding : packoffset(c340.w);
};

cbuffer cb7 : register(b7) {
  PROBE_GRID_DESC gridDesc_000[2] : packoffset(c000.x);
};

cbuffer cb13 : register(b13) {
  float4 cb13_raw[3589] : packoffset(c0);
};

#define cb13_000z (cb13_raw[0].z)
#define cb13_001y (cb13_raw[1].y)
#define cb13_066z (cb13_raw[66].z)
#define cb13_067y (asint(cb13_raw[67].y))
#define cb13_067x (cb13_raw[67].x)
#define cb13_000x (cb13_raw[0].x)
#define cb13_066x (cb13_raw[66].x)
#define cb13_036x (cb13_raw[36].x)
#define cb13_000y (cb13_raw[0].y)
#define cb13_035x (cb13_raw[35].x)
#define cb13_034x (asint(cb13_raw[34].x))
#define cb13_034z (cb13_raw[34].z)
#define cb13_034w (cb13_raw[34].w)
#define cb13_035w (cb13_raw[35].w)
#define cb13_035y (cb13_raw[35].y)
#define cb13_035z (cb13_raw[35].z)
#define cb13_061x (cb13_raw[61].x)
#define cb13_061y (cb13_raw[61].y)
#define cb13_061z (cb13_raw[61].z)
#define cb13_062x (cb13_raw[62].x)
#define cb13_062y (cb13_raw[62].y)
#define cb13_062z (cb13_raw[62].z)
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
  float cb0_005x : packoffset(c005.x);
  float cb0_005y : packoffset(c005.y);
  uint cb0_padding : packoffset(c7.x);
};

cbuffer cb14 : register(b14) {
  row_major float4x4 CameraCB_000 : packoffset(c000.x);
  row_major float4x4 CameraCB_064 : packoffset(c004.x);
  float3 CameraCB_128 : packoffset(c008.x);
  int CameraCB_140 : packoffset(c008.w);
  float CameraCB_144 : packoffset(c009.x);
  float CameraCB_148 : packoffset(c009.y);
  float2 CameraCB_152 : packoffset(c009.z);
  float CameraCB_160 : packoffset(c010.x);
  float CameraCB_164 : packoffset(c010.y);
  float CameraCB_168 : packoffset(c010.z);
  int CameraCB_172 : packoffset(c010.w);
  float CameraCB_176 : packoffset(c011.x);
  float CameraCB_180 : packoffset(c011.y);
  float CameraCB_184 : packoffset(c011.z);
  float CameraCB_188 : packoffset(c011.w);
  float CameraCB_192 : packoffset(c012.x);
  float CameraCB_196 : packoffset(c012.y);
  float CameraCB_200 : packoffset(c012.z);
  float CameraCB_204 : packoffset(c012.w);
  float2 CameraCB_208 : packoffset(c013.x);
  int CameraCB_216 : packoffset(c013.z);
  int CameraCB_220 : packoffset(c013.w);
  float2 CameraCB_224 : packoffset(c014.x);
  float CameraCB_232 : packoffset(c014.z);
  int CameraCB_236 : packoffset(c014.w);
  int2 CameraCB_240 : packoffset(c015.x);
  int2 CameraCB_248 : packoffset(c015.z);
  float3 CameraCB_256 : packoffset(c016.x);
  float CameraCB_268 : packoffset(c016.w);
  int CameraCB_272 : packoffset(c017.x);
  int CameraCB_276 : packoffset(c017.y);
  int CameraCB_280 : packoffset(c017.z);
  int CameraCB_284 : packoffset(c017.w);
  int CameraCB_288 : packoffset(c018.x);
  float CameraCB_292 : packoffset(c018.y);
  int CameraCB_296 : packoffset(c018.z);
  int CameraCB_300 : packoffset(c018.w);
  int CameraCB_304 : packoffset(c019.x);
  float CameraCB_308 : packoffset(c019.y);
  float CameraCB_312 : packoffset(c019.z);
  float CameraCB_316 : packoffset(c019.w);
  float CameraCB_320 : packoffset(c020.x);
  float CameraCB_324 : packoffset(c020.y);
  float CameraCB_328 : packoffset(c020.z);
  int CameraCB_332 : packoffset(c020.w);
  row_major float4x4 CameraCB_336 : packoffset(c021.x);
  row_major float4x4 CameraCB_400 : packoffset(c025.x);
  row_major float4x4 CameraCB_464 : packoffset(c029.x);
  float CameraCB_528 : packoffset(c033.x);
  float3 CameraCB_532 : packoffset(c033.y);
};

cbuffer cb10 : register(b10) {
  row_major float4x4 CustomConstants_000 : packoffset(c000.x);
  row_major float4x4 CustomConstants_064 : packoffset(c004.x);
  int CustomConstants_128 : packoffset(c008.x);
};

SamplerState s14 : register(s14);

SamplerState s10 : register(s10);

SamplerState s7 : register(s7);

[numthreads(8, 8, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  float _37[4];
  float4 _39 = t5.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0));
  bool _44 = (_39.w == 3.0f);
  int _100;
  float _215;
  float _242;
  float _312;
  float _313;
  float _314;
  bool _364;
  float _372;
  float _386;
  float _387;
  float _388;
  float _413;
  float _414;
  float _415;
  float _569;
  float _570;
  float _653;
  float _654;
  float _655;
  float _656;
  float _683;
  float _684;
  float _685;
  int _739;
  int _777;
  int _821;
  int _822;
  float _826;
  float _827;
  float _828;
  int _829;
  float _906;
  float _1015;
  float _1016;
  float _1017;
  float _1018;
  float _1109;
  float _1110;
  float _1111;
  float _1112;
  float _1117;
  float _1118;
  float _1119;
  float _1120;
  int _1121;
  float _1164;
  int _1177;
  int _1178;
  float _1217;
  float _1218;
  float _1219;
  float _1224;
  float _1225;
  float _1226;
  float _1228;
  float _1229;
  float _1230;
  float _1231;
  float _1246;
  float _1304;
  float _1305;
  float _1306;
  float _1311;
  float _1312;
  float _1313;
  float _1320;
  float _1321;
  float _1322;
  float _1698;
  int _1699;
  int _1700;
  float _1774;
  float _1775;
  float _1776;
  float _1777;
  float _1778;
  int _1779;
  float _1884;
  float _1885;
  float _1940;
  float _1941;
  float _1992;
  float _2006;
  float _2007;
  float _2008;
  float _2009;
  float _2010;
  float _2036;
  float _2037;
  float _2038;
  float _2039;
  float _2042;
  float _2043;
  float _2044;
  float _2047;
  float _2048;
  float _2049;
  int _2050;
  int _2051;
  float _2052;
  float _2128;
  float _2129;
  float _2130;
  float _2131;
  float _2132;
  int _2133;
  float _2246;
  float _2247;
  float _2298;
  float _2299;
  float _2350;
  float _2364;
  float _2365;
  float _2366;
  float _2367;
  float _2368;
  float _2394;
  float _2395;
  float _2396;
  float _2397;
  float _2401;
  float _2402;
  float _2403;
  int _2404;
  float _2405;
  float _2406;
  int _2407;
  float _2408;
  float _2409;
  float _2410;
  float _2456;
  float _2457;
  float _2496;
  float _2497;
  float _2498;
  float _2499;
  float _2518;
  float _2519;
  float _2520;
  int _2552;
  float _2613;
  float _2694;
  float _2750;
  float _2751;
  float _2752;
  float _2818;
  float _2823;
  float _2824;
  float _2825;
  bool _2882;
  float _2890;
  float _2904;
  float _2905;
  float _2906;
  float _2931;
  float _2932;
  float _2933;
  float _3087;
  float _3088;
  float _3171;
  float _3172;
  float _3173;
  float _3174;
  float _3201;
  float _3202;
  float _3203;
  if (_44) {
    u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_39.x, _39.y, _39.z, 65504.0f);
  } else {
    float _48 = -1.0f - _39.w;
    float _49 = max(_48, 0.0f);
    float _50 = _49 + 0.5f;
    uint _51 = uint(_50);
    int _52 = _51 & 2;
    bool _53 = (_52 != 0);
    bool _54 = (_39.w > 0.0f);
    float _55 = select(_54, 0.0f, _39.x);
    float _56 = select(_54, 0.0f, _39.y);
    float _57 = select(_54, 0.0f, _39.z);
    int _58 = _51 & 1;
    bool _59 = (_58 != 0);
    float _60 = select(_59, 1.0f, 0.0f);
    float4 _62 = t11.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0));
    float _67 = _62.x * 2.0f;
    float _68 = _62.y * 2.0f;
    float _69 = _62.z * 2.0f;
    float _70 = _67 + -1.0f;
    float _71 = _68 + -1.0f;
    float _72 = _69 + -1.0f;
    float4 _74 = t12.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0));
    int _81 = CustomConstants_128 & 16;
    bool _82 = (_81 == 0);
    if (_82) {
      bool _84 = (_74.w < 0.0f);
      float _85 = select(_84, 65504.0f, _74.w);
      u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_55, _56, _57, _85);
    } else {
      bool _90 = (CameraCB_236 == 0);
      if (!_90) {
        int _92 = (int)(SV_DispatchThreadID.y) ^ 1;
        int _95 = _92 ^ CameraCB_220;
        int _96 = _95 & 1;
        uint _97 = SV_DispatchThreadID.x << 1u;
        int _98 = _96 | _97;
        _100 = _98;
      } else {
        _100 = (int)(SV_DispatchThreadID.x);
      }
      float _102 = t13.Load(int3(_100, (int)(SV_DispatchThreadID.y), 0));
      float _107 = CameraCB_152.x * _102.x;
      float _108 = _107 + CameraCB_152.y;
      bool _109 = !(_108 >= 0.9999990463256836f);
      if (!_109) {
        u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(0.0f, 0.0f, 0.0f, 65504.0f);
      } else {
        float _113 = float((int)(_100));
        float _114 = float((int)((int)(SV_DispatchThreadID.y)));
        float _135 = (CameraCB_000[0].x) * _113;
        float _136 = mad((CameraCB_000[1].x), _114, _135);
        float _137 = mad((CameraCB_000[2].x), _102.x, _136);
        float _138 = _137 + (CameraCB_000[3].x);
        float _139 = (CameraCB_000[0].y) * _113;
        float _140 = mad((CameraCB_000[1].y), _114, _139);
        float _141 = mad((CameraCB_000[2].y), _102.x, _140);
        float _142 = _141 + (CameraCB_000[3].y);
        float _143 = (CameraCB_000[0].z) * _113;
        float _144 = mad((CameraCB_000[1].z), _114, _143);
        float _145 = mad((CameraCB_000[2].z), _102.x, _144);
        float _146 = _145 + (CameraCB_000[3].z);
        float _147 = (CameraCB_000[0].w) * _113;
        float _148 = mad((CameraCB_000[1].w), _114, _147);
        float _149 = mad((CameraCB_000[2].w), _102.x, _148);
        float _150 = _149 + (CameraCB_000[3].w);
        float _151 = _138 / _150;
        float _152 = _142 / _150;
        float _153 = _146 / _150;
        float _154 = _74.x * _74.w;
        float _155 = _74.y * _74.w;
        float _156 = _74.z * _74.w;
        float _157 = _151 + _154;
        float _158 = _152 + _155;
        float _159 = _153 + _156;
        if (_54) {
          bool _161 = (_39.w > 1.0f);
          if (_161) {
            u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(0.0f, 0.0f, 0.0f, 65504.0f);
          } else {
            uint _165 = uint(_39.x);
            uint _166 = uint(_39.y);
            uint _167 = uint(_39.z);
            uint _168 = _167 << 11u;
            int _169 = _168 & 63488;
            int _170 = _169 | _165;
            int _171 = (uint)(_167) >> 5;
            uint _172 = _171 << 11u;
            int _173 = _172 | _166;
            bool _177 = ((uint)_170 >= (uint)CameraCB_240.x);
            bool _178 = ((uint)_173 >= (uint)CameraCB_240.y);
            bool _179 = _177 || _178;
            if (_179) {
              u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(0.0f, 0.0f, 0.0f, 65504.0f);
            } else {
              float4 _183 = t27.Load(int3(_170, _173, 0));
              float _187 = _183.x * _62.w;
              float _188 = _183.y * _62.w;
              float _189 = _183.z * _62.w;
              u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_187, _188, _189, _74.w);
            }
          }
        } else {
          bool _191 = (_74.w < 0.0f);
          [branch]
          if (_191) {
            float4 _194 = t39.Load(int3(_100, (int)(SV_DispatchThreadID.y), 0));
            bool _197 = (_194.w < 1.0f);
            bool _198 = (_194.z > 0.5f);
            bool _199 = !_197;
            bool _200 = _198 || _199;
            if (_200) {
              float _202 = saturate(_74.z);
              float _203 = dot(float3(_74.x, _74.y, _202), float3(_74.x, _74.y, _202));
              float _204 = rsqrt(_203);
              float _205 = _204 * _74.x;
              float _206 = _204 * _74.y;
              float _207 = _204 * _202;
              if (_197) {
                _215 = cb0_004x;
              } else {
                _215 = cb0_003w;
              }
              float _216 = _74.x - _74.y;
              float _217 = _204 * _216;
              float _218 = abs(_217);
              float _219 = _74.x + _74.y;
              float _220 = _204 * _219;
              float _221 = abs(_220);
              float _222 = _221 + _218;
              float _223 = _222 * 0.5f;
              float _224 = abs(_207);
              float _225 = _223 + _224;
              float _226 = _205 / _225;
              float _227 = _206 / _225;
              float _228 = _226 * 0.5f;
              float _229 = _227 * 0.5f;
              float _230 = _228 + 0.5f;
              float _231 = 0.5f - _229;
              float4 _234 = t3.SampleLevel(s10, float2(_230, _231), 0.0f);
              if (_197) {
                _242 = cb0_005y;
              } else {
                _242 = 1.0f;
              }
              float _259 = _205 * _205;
              float _260 = _206 * _206;
              float _261 = _259 + _260;
              float _262 = sqrt(_261);
              float _263 = _262 * 0.5f;
              float _264 = 1.0f - _207;
              float _265 = 1.0f / _264;
              float _266 = max(_265, -3.4028234663852886e+38f);
              float _267 = min(_266, 3.4028234663852886e+38f);
              float _268 = _263 * _267;
              float _269 = saturate(_268);
              float _270 = log2(_269);
              float _271 = _270 * cb0_003x;
              float _272 = exp2(_271);
              float _273 = cb0_002x - cb0_001x;
              float _274 = cb0_002y - cb0_001y;
              float _275 = cb0_002z - cb0_001z;
              float _276 = _272 * _273;
              float _277 = _272 * _274;
              float _278 = _272 * _275;
              float _279 = cb0_001x - _234.x;
              float _280 = _279 + _276;
              float _281 = cb0_001y - _234.y;
              float _282 = _281 + _277;
              float _283 = cb0_001z - _234.z;
              float _284 = _283 + _278;
              float _285 = _280 * _215;
              float _286 = _282 * _215;
              float _287 = _284 * _215;
              float _288 = _285 + _234.x;
              float _289 = _286 + _234.y;
              float _290 = _287 + _234.z;
              float _291 = _288 * cb0_003z;
              float _292 = _289 * cb0_003z;
              float _293 = _290 * cb0_003z;
              float _294 = dot(float3(_291, _292, _293), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
              float _295 = _291 - _294;
              float _296 = _292 - _294;
              float _297 = _293 - _294;
              float _298 = _295 * cb0_003y;
              float _299 = _296 * cb0_003y;
              float _300 = _297 * cb0_003y;
              float _301 = _298 + _294;
              float _302 = _299 + _294;
              float _303 = _300 + _294;
              float _304 = dot(float3(_301, _302, _303), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
              bool _305 = (_304 > cb0_005x);
              if (_305) {
                float _307 = cb0_005x / _304;
                float _308 = _307 * _301;
                float _309 = _307 * _302;
                float _310 = _307 * _303;
                _312 = _308;
                _313 = _309;
                _314 = _310;
              } else {
                _312 = _301;
                _313 = _302;
                _314 = _303;
              }
              float _315 = (cb0_000w * _242) * GRAPHICS_RAY_SKYLIGHT;
              float _316 = _312 * _315;
              float _317 = _313 * _315;
              float _318 = _314 * _315;
              int _319 = CustomConstants_128 & 8;
              bool _320 = (_319 == 0);
              if (!_320) {
                float _331 = _74.x * _74.x;
                float _332 = _74.y * _74.y;
                float _333 = _331 + _332;
                float _334 = _74.z * _74.z;
                float _335 = _333 + _334;
                float _336 = sqrt(_335);
                float _337 = _74.x / _336;
                float _338 = _74.y / _336;
                float _339 = _74.z / _336;
                float _340 = cb12_042z * 0.0625f;
                float _341 = _339 * _340;
                float _342 = _340 * cb12_044x;
                float _347 = dot(float3(cb12_038x, cb12_038y, cb12_038z), float3(_337, _338, _339));
                float _349 = _347 + cb12_042x;
                float _350 = cb12_042x + 1.0f;
                float _351 = _349 / _350;
                float _352 = saturate(_351);
                float _353 = cb12_044y - cb12_044z;
                float _354 = _352 * _353;
                float _355 = _354 + cb12_044z;
                bool _358 = (cb12_287z == 0);
                if (!_358) {
                  bool _360 = (_347 > 0.0f);
                  bool _361 = (cb12_287z != 2);
                  bool _362 = _360 && _361;
                  _364 = _362;
                } else {
                  _364 = true;
                }
                float _365 = abs(_347);
                float _366 = _365 * _365;
                if (_364) {
                  float _368 = cb12_042z * 0.0020000000949949026f;
                  float _369 = _368 + -0.30000001192092896f;
                  float _370 = saturate(_369);
                  _372 = _370;
                } else {
                  _372 = 1.0f;
                }
                float _373 = _366 * _372;
                bool _374 = (_347 > 0.0f);
                if (_374) {
                  _386 = cb12_039x;
                  _387 = cb12_039y;
                  _388 = cb12_039z;
                } else {
                  _386 = cb12_041x;
                  _387 = cb12_041y;
                  _388 = cb12_041z;
                }
                float _393 = _386 - cb12_040x;
                float _394 = _387 - cb12_040y;
                float _395 = _388 - cb12_040z;
                float _396 = _393 * _373;
                float _397 = _394 * _373;
                float _398 = _395 * _373;
                float _399 = _396 + cb12_040x;
                float _400 = _397 + cb12_040y;
                float _401 = _398 + cb12_040z;
                if (_374) {
                  _413 = cb12_045x;
                  _414 = cb12_045y;
                  _415 = cb12_045z;
                } else {
                  _413 = cb12_047x;
                  _414 = cb12_047y;
                  _415 = cb12_047z;
                }
                float _420 = _413 - cb12_046x;
                float _421 = _414 - cb12_046y;
                float _422 = _415 - cb12_046z;
                float _423 = _420 * _373;
                float _424 = _421 * _373;
                float _425 = _422 * _373;
                float _426 = _423 + cb12_046x;
                float _427 = _424 + cb12_046y;
                float _428 = _425 + cb12_046z;
                bool _430 = !(cb12_042z >= cb12_048y);
                [branch]
                if (!_430) {
                  float _433 = cb12_042y + _153;
                  float _434 = _355 * _433;
                  float _435 = _355 * _341;
                  float _436 = _435 * 16.0f;
                  float _437 = _436 + _434;
                  float _438 = max(0.0f, _437);
                  float _439 = _438 + 1.0f;
                  float _440 = _342 / _439;
                  float _441 = saturate(_440);
                  float _442 = 1.0f - _441;
                  float _443 = _435 * 15.0f;
                  float _444 = _443 + _434;
                  float _445 = max(0.0f, _444);
                  float _446 = _445 + 1.0f;
                  float _447 = _342 / _446;
                  float _448 = saturate(_447);
                  float _449 = 1.0f - _448;
                  float _450 = _449 * _442;
                  float _451 = _435 * 14.0f;
                  float _452 = _451 + _434;
                  float _453 = max(0.0f, _452);
                  float _454 = _453 + 1.0f;
                  float _455 = _342 / _454;
                  float _456 = saturate(_455);
                  float _457 = 1.0f - _456;
                  float _458 = _450 * _457;
                  float _459 = _435 * 13.0f;
                  float _460 = _459 + _434;
                  float _461 = max(0.0f, _460);
                  float _462 = _461 + 1.0f;
                  float _463 = _342 / _462;
                  float _464 = saturate(_463);
                  float _465 = 1.0f - _464;
                  float _466 = _458 * _465;
                  float _467 = _435 * 12.0f;
                  float _468 = _467 + _434;
                  float _469 = max(0.0f, _468);
                  float _470 = _469 + 1.0f;
                  float _471 = _342 / _470;
                  float _472 = saturate(_471);
                  float _473 = 1.0f - _472;
                  float _474 = _466 * _473;
                  float _475 = _435 * 11.0f;
                  float _476 = _475 + _434;
                  float _477 = max(0.0f, _476);
                  float _478 = _477 + 1.0f;
                  float _479 = _342 / _478;
                  float _480 = saturate(_479);
                  float _481 = 1.0f - _480;
                  float _482 = _474 * _481;
                  float _483 = _435 * 10.0f;
                  float _484 = _483 + _434;
                  float _485 = max(0.0f, _484);
                  float _486 = _485 + 1.0f;
                  float _487 = _342 / _486;
                  float _488 = saturate(_487);
                  float _489 = 1.0f - _488;
                  float _490 = _482 * _489;
                  float _491 = _435 * 9.0f;
                  float _492 = _491 + _434;
                  float _493 = max(0.0f, _492);
                  float _494 = _493 + 1.0f;
                  float _495 = _342 / _494;
                  float _496 = saturate(_495);
                  float _497 = 1.0f - _496;
                  float _498 = _490 * _497;
                  float _499 = _435 * 8.0f;
                  float _500 = _499 + _434;
                  float _501 = max(0.0f, _500);
                  float _502 = _501 + 1.0f;
                  float _503 = _342 / _502;
                  float _504 = saturate(_503);
                  float _505 = 1.0f - _504;
                  float _506 = _498 * _505;
                  float _507 = _435 * 7.0f;
                  float _508 = _507 + _434;
                  float _509 = max(0.0f, _508);
                  float _510 = _509 + 1.0f;
                  float _511 = _342 / _510;
                  float _512 = saturate(_511);
                  float _513 = 1.0f - _512;
                  float _514 = _506 * _513;
                  float _515 = _435 * 6.0f;
                  float _516 = _515 + _434;
                  float _517 = max(0.0f, _516);
                  float _518 = _517 + 1.0f;
                  float _519 = _342 / _518;
                  float _520 = saturate(_519);
                  float _521 = 1.0f - _520;
                  float _522 = _514 * _521;
                  float _523 = _435 * 5.0f;
                  float _524 = _523 + _434;
                  float _525 = max(0.0f, _524);
                  float _526 = _525 + 1.0f;
                  float _527 = _342 / _526;
                  float _528 = saturate(_527);
                  float _529 = 1.0f - _528;
                  float _530 = _522 * _529;
                  float _531 = _435 * 4.0f;
                  float _532 = _531 + _434;
                  float _533 = max(0.0f, _532);
                  float _534 = _533 + 1.0f;
                  float _535 = _342 / _534;
                  float _536 = saturate(_535);
                  float _537 = 1.0f - _536;
                  float _538 = _530 * _537;
                  float _539 = _435 * 3.0f;
                  float _540 = _539 + _434;
                  float _541 = max(0.0f, _540);
                  float _542 = _541 + 1.0f;
                  float _543 = _342 / _542;
                  float _544 = saturate(_543);
                  float _545 = 1.0f - _544;
                  float _546 = _538 * _545;
                  float _547 = _435 * 2.0f;
                  float _548 = _547 + _434;
                  float _549 = max(0.0f, _548);
                  float _550 = _549 + 1.0f;
                  float _551 = _342 / _550;
                  float _552 = saturate(_551);
                  float _553 = 1.0f - _552;
                  float _554 = _546 * _553;
                  float _555 = _341 + _433;
                  float _556 = _355 * _555;
                  float _557 = max(0.0f, _556);
                  float _558 = _557 + 1.0f;
                  float _559 = _342 / _558;
                  float _560 = saturate(_559);
                  float _561 = 1.0f - _560;
                  float _562 = _554 * _561;
                  float _563 = 1.0f - _562;
                  float _564 = cb12_042z - cb12_048y;
                  float _566 = _564 * cb12_048z;
                  float _567 = saturate(_566);
                  _569 = _563;
                  _570 = _567;
                } else {
                  _569 = 1.0f;
                  _570 = 0.0f;
                }
                float _571 = abs(_569);
                float _572 = log2(_571);
                float _573 = _572 * cb12_042w;
                float _574 = exp2(_573);
                float _575 = _574 * _570;
                float _576 = _572 * cb12_048x;
                float _577 = exp2(_576);
                float _578 = _577 * _570;
                float _581 = cb12_190x * _575;
                float _583 = _581 + cb12_190y;
                float _584 = saturate(_583);
                float _586 = cb12_190z * _575;
                float _588 = _586 + cb12_190w;
                float _589 = saturate(_588);
                float _594 = cb12_189x - _399;
                float _595 = cb12_189y - _400;
                float _596 = cb12_189z - _401;
                float _597 = _594 * _584;
                float _598 = _595 * _584;
                float _599 = _596 * _584;
                float _600 = _597 + _399;
                float _601 = _598 + _400;
                float _602 = _599 + _401;
                float _604 = cb12_189w + -1.0f;
                float _605 = _604 * _589;
                float _606 = _605 + 1.0f;
                float _607 = _606 * _575;
                float _608 = saturate(_607);
                bool _611 = (cb12_193x > 0.0f);
                [branch]
                if (_611) {
                  float _615 = cb12_192x * _575;
                  float _617 = _615 + cb12_192y;
                  float _618 = saturate(_617);
                  float _620 = cb12_192z * _575;
                  float _622 = _620 + cb12_192w;
                  float _623 = saturate(_622);
                  float _628 = cb12_191x - _399;
                  float _629 = cb12_191y - _400;
                  float _630 = cb12_191z - _401;
                  float _631 = _628 * _618;
                  float _632 = _629 * _618;
                  float _633 = _630 * _618;
                  float _635 = cb12_191w + -1.0f;
                  float _636 = _635 * _623;
                  float _637 = _636 + 1.0f;
                  float _638 = _637 * _575;
                  float _639 = saturate(_638);
                  float _640 = _631 - _597;
                  float _641 = _632 - _598;
                  float _642 = _633 - _599;
                  float _643 = _639 - _608;
                  float _644 = _640 * cb12_193x;
                  float _645 = _641 * cb12_193x;
                  float _646 = _642 * cb12_193x;
                  float _647 = _643 * cb12_193x;
                  float _648 = _644 + _600;
                  float _649 = _645 + _601;
                  float _650 = _646 + _602;
                  float _651 = _647 + _608;
                  _653 = _648;
                  _654 = _649;
                  _655 = _650;
                  _656 = _651;
                } else {
                  _653 = _600;
                  _654 = _601;
                  _655 = _602;
                  _656 = _608;
                }
                float _658 = saturate(cb12_046w);
                float _659 = _578 * _658;
                float _660 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_316, _317, _318));
                float _661 = _660 * _426;
                float _662 = _660 * _427;
                float _663 = _660 * _428;
                float _664 = _661 - _316;
                float _665 = _662 - _317;
                float _666 = _663 - _318;
                float _667 = _664 * _659;
                float _668 = _665 * _659;
                float _669 = _666 * _659;
                float _670 = _667 + _316;
                float _671 = _668 + _317;
                float _672 = _669 + _318;
                float _673 = _653 - _670;
                float _674 = _654 - _671;
                float _675 = _655 - _672;
                float _676 = _673 * _656;
                float _677 = _674 * _656;
                float _678 = _675 * _656;
                float _679 = _676 + _670;
                float _680 = _677 + _671;
                float _681 = _678 + _672;
                _683 = _679;
                _684 = _680;
                _685 = _681;
              } else {
                _683 = _316;
                _684 = _317;
                _685 = _318;
              }
            } else {
              _683 = 0.0f;
              _684 = 0.0f;
              _685 = 0.0f;
            }
            float _686 = _683 * _62.w;
            float _687 = _684 * _62.w;
            float _688 = _685 * _62.w;
            u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_686, _687, _688, 65504.0f);
          } else {
            float _691 = -0.0f - _154;
            float _692 = -0.0f - _155;
            float _693 = -0.0f - _156;
            float _694 = dot(float3(_691, _692, _693), float3(_691, _692, _693));
            float _695 = rsqrt(_694);
            float _696 = _695 * _691;
            float _697 = _695 * _692;
            float _698 = _695 * _693;
            // GRAPHICS HIT BEGIN
            uint2 graphics_packed = 0;
            bool graphics_hit = false;
            float4 graphics_material = 0.f;
            float3 graphics_specular = 0.f;
            if (graphics_injection.layout_version == 1.f && graphics_injection.graphics_mode != 0.f && graphics_injection.pbr_mode != 0.f) {
              graphics_hit = GraphicsReadHitMaterial(graphics_hit_material, graphics_hit_context,
                  SV_DispatchThreadID.xy, _74.w, graphics_packed) && (graphics_packed.y & (1u << 17u)) == 0;
              if (graphics_hit) {
                graphics_material = GraphicsDecodeHitMaterial(graphics_packed);
                graphics_material.w = GraphicsHitRoughness(graphics_hit_material, graphics_material.w, graphics_packed.y);
                graphics_hit = isfinite(graphics_material.w);
                graphics_material.w = clamp(graphics_material.w, .045f, 1.f);
              }
            }
            // GRAPHICS HIT END
            int _699 = CustomConstants_128 & 1;
            bool _700 = (_699 == 0);
            bool _701 = _53 || _700;
            if (!_701) {
              float _707 = _157 - cb9_000x;
              float _708 = _158 - cb9_000y;
              float _709 = _159 - cb9_000z;
              float _714 = _707 / cb9_002x;
              float _715 = _708 / cb9_002y;
              float _716 = _709 / cb9_002z;
              float _717 = floor(_714);
              float _718 = floor(_715);
              float _719 = floor(_716);
              int _720 = int(_717);
              int _721 = int(_718);
              int _722 = int(_719);
              int _723 = _721 | _720;
              int _724 = _723 | _722;
              bool _725 = ((int)_724 > (int)-1);
              if (_725) {
                bool _731 = ((int)_720 < (int)cb9_004x);
                bool _732 = ((int)_721 < (int)cb9_004y);
                bool _733 = ((int)_722 < (int)cb9_004z);
                bool _734 = _731 && _732;
                bool _735 = _733 && _734;
                bool _736 = !_735;
                int _737 = int((bool)_736);
                _739 = _737;
              } else {
                _739 = -1;
              }
              float _744 = _157 - cb9_001x;
              float _745 = _158 - cb9_001y;
              float _746 = _159 - cb9_001z;
              float _751 = _744 / cb9_003x;
              float _752 = _745 / cb9_003y;
              float _753 = _746 / cb9_003z;
              float _754 = floor(_751);
              float _755 = floor(_752);
              float _756 = floor(_753);
              int _757 = int(_754);
              int _758 = int(_755);
              int _759 = int(_756);
              bool _760 = (_739 == -1);
              if (_760) {
                int _762 = _758 | _757;
                int _763 = _762 | _759;
                bool _764 = ((int)_763 > (int)-1);
                if (_764) {
                  bool _770 = ((int)_757 < (int)cb9_005x);
                  bool _771 = ((int)_758 < (int)cb9_005y);
                  bool _772 = ((int)_759 < (int)cb9_005z);
                  bool _773 = _770 && _771;
                  bool _774 = _772 && _773;
                  int _775 = select(_774, 1, -1);
                  _777 = _775;
                } else {
                  _777 = -1;
                }
              } else {
                _777 = _739;
              }
              bool _780 = (_777 == -1);
              if (!_780) {
                float _786 = _157 - (cb9_raw[_777].x);
                float _787 = _158 - (cb9_raw[_777].y);
                float _788 = _159 - (cb9_raw[_777].z);
                int _789 = _777 + 2;
                float _794 = _786 / (cb9_raw[_789].x);
                float _795 = _787 / (cb9_raw[_789].y);
                float _796 = _788 / (cb9_raw[_789].z);
                float _797 = floor(_794);
                float _798 = floor(_795);
                float _799 = floor(_796);
                int _800 = int(_797);
                int _801 = int(_798);
                int _802 = int(_799);
                int _803 = _777 + 4;
                int _806 = asint(cb9_raw[_803].y) * _802;
                int _807 = _806 + _801;
                int _809 = _807 * asint(cb9_raw[_803].x);
                int _810 = _777 + 6;
                uint _813 = (uint)(asint(cb9_raw[_810].x)) + _800;
                uint _814 = _813 + _809;
                int _817 = t25[_814].range_000;
                int _819 = t25[_814].range_004;
                _821 = _819;
                _822 = _817;
              } else {
                _821 = cb13_067y;
                _822 = 1;
              }
              bool _823 = ((uint)_822 < (uint)_821);
              if (_823) {
                _826 = 0.0f;
                _827 = 0.0f;
                _828 = 0.0f;
                _829 = _822;
                while(true) {
                  int _832 = t26[_829].light_000;
                  float _835 = t16[_832].LightParams_048.w;
                  int _836 = asint(_835);
                  bool _837 = ((int)_836 < (int)0);
                  if (!_837) {
                    float _840 = t16[_832].LightParams_000.x;
                    float _841 = t16[_832].LightParams_000.y;
                    float _842 = t16[_832].LightParams_000.z;
                    float _843 = _840 - _157;
                    float _844 = _841 - _158;
                    float _845 = _842 - _159;
                    float _848 = _843 * _843;
                    float _849 = _844 * _844;
                    float _850 = _848 + _849;
                    float _851 = _845 * _845;
                    float _852 = _850 + _851;
                    float _853 = sqrt(_852);
                    float _854 = _853 * _853;
                    float _856 = t16[_832].LightParams_080.x;
                    float _857 = _854 * _856;
                    float _858 = t16[_832].LightParams_000.w;
                    float _859 = _853 / _858;
                    float _860 = _859 * cb0_004z;
                    float _861 = _860 * _860;
                    float _862 = _861 * _861;
                    float _863 = 1.0f - _862;
                    float _864 = saturate(_863);
                    float _865 = _864 * _864;
                    int _866 = _836 & 1;
                    bool _867 = (_866 != 0);
                    float _868 = t16[_832].LightParams_080.z;
                    bool _869 = (_868 > 0.0f);
                    float _871 = t16[_832].LightParams_096.x;
                    bool _872 = (_871 > 0.0f);
                    float _874 = t16[_832].LightParams_144.x;
                    int _875 = asint(_874);
                    int _876 = _875 & 1;
                    bool _877 = (_876 != 0);
                    float _878 = _857 + 1.0f;
                    float _879 = _865 / _878;
                    if (_867) {
                      float _882 = t16[_832].LightParams_032.x;
                      float _883 = t16[_832].LightParams_032.y;
                      float _884 = t16[_832].LightParams_032.z;
                      float _885 = dot(float3(_843, _844, _845), float3(_843, _844, _845));
                      float _886 = rsqrt(_885);
                      float _887 = _843 * _886;
                      float _888 = -0.0f - _887;
                      float _889 = _844 * _886;
                      float _890 = -0.0f - _889;
                      float _891 = _845 * _886;
                      float _892 = -0.0f - _891;
                      float _893 = dot(float3(_888, _890, _892), float3(_882, _883, _884));
                      float _895 = t16[_832].LightParams_064.w;
                      float _896 = t16[_832].LightParams_064.y;
                      float _897 = _896 * _893;
                      float _898 = t16[_832].LightParams_064.z;
                      float _899 = _897 + _898;
                      float _900 = saturate(_899);
                      float _901 = log2(_900);
                      float _902 = _901 * _895;
                      float _903 = exp2(_902);
                      float _904 = _903 * _879;
                      _906 = _904;
                    } else {
                      _906 = _879;
                    }
                    bool _907 = _869 || _877;
                    bool _908 = (_906 > 0.0f);
                    bool _909 = _907 && _908;
                    if (_909) {
                      float _911 = -0.0f - _843;
                      float _912 = -0.0f - _844;
                      float _913 = -0.0f - _845;
                      if (_867) {
                        float _916 = t16[_832].LightParams_032.x;
                        float _917 = t16[_832].LightParams_032.y;
                        float _918 = t16[_832].LightParams_032.z;
                        float _920 = t16[_832].LightParams_112.y;
                        float _921 = t16[_832].LightParams_112.z;
                        float _922 = t16[_832].LightParams_112.w;
                        float _923 = _922 * _917;
                        float _924 = _921 * _918;
                        float _925 = _923 - _924;
                        float _926 = _920 * _918;
                        float _927 = _922 * _916;
                        float _928 = _926 - _927;
                        float _929 = _921 * _916;
                        float _930 = _920 * _917;
                        float _931 = _929 - _930;
                        float _932 = _925 * _911;
                        float _933 = mad(_928, _912, _932);
                        float _934 = mad(_931, _913, _933);
                        float _935 = _920 * _911;
                        float _936 = mad(_921, _912, _935);
                        float _937 = mad(_922, _913, _936);
                        float _938 = _916 * _911;
                        float _939 = mad(_917, _912, _938);
                        float _940 = mad(_918, _913, _939);
                        float _941 = t16[_832].LightParams_112.x;
                        float _943 = t16[_832].LightParams_144.z;
                        int _944 = asint(_943);
                        _1117 = _934;
                        _1118 = _937;
                        _1119 = _940;
                        _1120 = _941;
                        _1121 = _944;
                      } else {
                        if (_877) {
                          float _948 = t16[_832].LightParams_064.y;
                          float _949 = t16[_832].LightParams_064.z;
                          float _950 = t16[_832].LightParams_064.w;
                          float _952 = t16[_832].LightParams_032.x;
                          float _953 = t16[_832].LightParams_032.y;
                          float _954 = t16[_832].LightParams_032.z;
                          float _955 = _953 * _950;
                          float _956 = _954 * _949;
                          float _957 = _955 - _956;
                          float _958 = _954 * _948;
                          float _959 = _952 * _950;
                          float _960 = _958 - _959;
                          float _961 = _952 * _949;
                          float _962 = _953 * _948;
                          float _963 = _961 - _962;
                          float _964 = _957 * _911;
                          float _965 = mad(_960, _912, _964);
                          float _966 = mad(_963, _913, _965);
                          float _967 = _952 * _911;
                          float _968 = mad(_953, _912, _967);
                          float _969 = mad(_954, _913, _968);
                          float _970 = _948 * _911;
                          float _971 = mad(_949, _912, _970);
                          float _972 = mad(_950, _913, _971);
                          float _973 = -0.0f - _966;
                          float _974 = -0.0f - _969;
                          float _975 = -0.0f - _972;
                          float _976 = _973 / _853;
                          float _977 = _974 / _853;
                          float _978 = _975 / _853;
                          float _979 = abs(_976);
                          float _980 = abs(_977);
                          float _981 = abs(_978);
                          int _982 = _875 & 4;
                          bool _983 = (_982 == 0);
                          float _984 = max(_980, _981);
                          bool _985 = (_979 > _984);
                          if (!_983) {
                            if (_985) {
                              bool _988 = (_976 > 0.0f);
                              if (_988) {
                                float _991 = t16[_832].LightParams_112.x;
                                _1015 = _969;
                                _1016 = _972;
                                _1017 = _973;
                                _1018 = _991;
                              } else {
                                float _994 = t16[_832].LightParams_112.y;
                                _1015 = _974;
                                _1016 = _972;
                                _1017 = _966;
                                _1018 = _994;
                              }
                            } else {
                              float _996 = max(_979, _981);
                              bool _997 = (_980 > _996);
                              if (_997) {
                                bool _999 = (_977 > 0.0f);
                                if (_999) {
                                  float _1002 = t16[_832].LightParams_112.z;
                                  _1015 = _973;
                                  _1016 = _972;
                                  _1017 = _974;
                                  _1018 = _1002;
                                } else {
                                  float _1005 = t16[_832].LightParams_112.w;
                                  _1015 = _966;
                                  _1016 = _972;
                                  _1017 = _969;
                                  _1018 = _1005;
                                }
                              } else {
                                bool _1007 = (_978 > 0.0f);
                                if (_1007) {
                                  float _1010 = t16[_832].LightParams_128.x;
                                  _1015 = _966;
                                  _1016 = _969;
                                  _1017 = _975;
                                  _1018 = _1010;
                                } else {
                                  float _1013 = t16[_832].LightParams_128.y;
                                  _1015 = _966;
                                  _1016 = _974;
                                  _1017 = _972;
                                  _1018 = _1013;
                                }
                              }
                            }
                            float _1020 = t16[_832].LightParams_144.z;
                            int _1021 = asint(_1020);
                            _1117 = _1015;
                            _1118 = _1016;
                            _1119 = _1017;
                            _1120 = _1018;
                            _1121 = _1021;
                          } else {
                            if (_985) {
                              bool _1024 = (_976 > 0.0f);
                              if (_1024) {
                                float _1027 = t16[_832].LightParams_112.x;
                                float _1029 = t16[_832].LightParams_144.z;
                                int _1030 = asint(_1029);
                                _1117 = _969;
                                _1118 = _972;
                                _1119 = _973;
                                _1120 = _1027;
                                _1121 = _1030;
                              } else {
                                float _1033 = t16[_832].LightParams_112.y;
                                float _1035 = t16[_832].LightParams_144.z;
                                int _1036 = asint(_1035);
                                int _1037 = (uint)(_1036) >> 10;
                                _1117 = _974;
                                _1118 = _972;
                                _1119 = _966;
                                _1120 = _1033;
                                _1121 = _1037;
                              }
                            } else {
                              float _1039 = max(_979, _981);
                              bool _1040 = (_980 > _1039);
                              if (_1040) {
                                bool _1042 = (_977 > 0.0f);
                                if (_1042) {
                                  float _1045 = t16[_832].LightParams_112.z;
                                  float _1047 = t16[_832].LightParams_144.z;
                                  int _1048 = asint(_1047);
                                  int _1049 = (uint)(_1048) >> 20;
                                  _1117 = _973;
                                  _1118 = _972;
                                  _1119 = _974;
                                  _1120 = _1045;
                                  _1121 = _1049;
                                } else {
                                  float _1052 = t16[_832].LightParams_112.w;
                                  float _1054 = t16[_832].LightParams_144.w;
                                  int _1055 = asint(_1054);
                                  _1117 = _966;
                                  _1118 = _972;
                                  _1119 = _969;
                                  _1120 = _1052;
                                  _1121 = _1055;
                                }
                              } else {
                                bool _1057 = (_978 > 0.0f);
                                if (_1057) {
                                  float _1060 = t16[_832].LightParams_128.x;
                                  float _1062 = t16[_832].LightParams_144.w;
                                  int _1063 = asint(_1062);
                                  int _1064 = (uint)(_1063) >> 10;
                                  _1117 = _966;
                                  _1118 = _969;
                                  _1119 = _975;
                                  _1120 = _1060;
                                  _1121 = _1064;
                                } else {
                                  float _1067 = t16[_832].LightParams_128.y;
                                  float _1069 = t16[_832].LightParams_144.w;
                                  int _1070 = asint(_1069);
                                  int _1071 = (uint)(_1070) >> 20;
                                  _1117 = _966;
                                  _1118 = _974;
                                  _1119 = _972;
                                  _1120 = _1067;
                                  _1121 = _1071;
                                }
                              }
                            }
                          }
                        } else {
                          float _1073 = _843 / _853;
                          float _1074 = _844 / _853;
                          float _1075 = _845 / _853;
                          float _1076 = abs(_1073);
                          float _1077 = abs(_1074);
                          float _1078 = abs(_1075);
                          float _1079 = max(_1077, _1078);
                          bool _1080 = (_1076 > _1079);
                          if (_1080) {
                            bool _1082 = (_1073 > 0.0f);
                            if (_1082) {
                              float _1085 = t16[_832].LightParams_112.x;
                              _1109 = _912;
                              _1110 = _913;
                              _1111 = _843;
                              _1112 = _1085;
                            } else {
                              float _1088 = t16[_832].LightParams_112.y;
                              _1109 = _844;
                              _1110 = _913;
                              _1111 = _911;
                              _1112 = _1088;
                            }
                          } else {
                            float _1090 = max(_1076, _1078);
                            bool _1091 = (_1077 > _1090);
                            if (_1091) {
                              bool _1093 = (_1074 > 0.0f);
                              if (_1093) {
                                float _1096 = t16[_832].LightParams_112.z;
                                _1109 = _843;
                                _1110 = _913;
                                _1111 = _844;
                                _1112 = _1096;
                              } else {
                                float _1099 = t16[_832].LightParams_112.w;
                                _1109 = _911;
                                _1110 = _913;
                                _1111 = _912;
                                _1112 = _1099;
                              }
                            } else {
                              bool _1101 = (_1075 > 0.0f);
                              if (_1101) {
                                float _1104 = t16[_832].LightParams_128.x;
                                _1109 = _911;
                                _1110 = _912;
                                _1111 = _845;
                                _1112 = _1104;
                              } else {
                                float _1107 = t16[_832].LightParams_128.y;
                                _1109 = _911;
                                _1110 = _844;
                                _1111 = _913;
                                _1112 = _1107;
                              }
                            }
                          }
                          float _1114 = t16[_832].LightParams_144.z;
                          int _1115 = asint(_1114);
                          _1117 = _1109;
                          _1118 = _1110;
                          _1119 = _1111;
                          _1120 = _1112;
                          _1121 = _1115;
                        }
                      }
                      float _1122 = t16[_832].LightParams_080.y;
                      float _1123 = _1117 * _1122;
                      float _1124 = mad(_1122, _1118, 0.0f);
                      float _1125 = _1123 / _1119;
                      float _1126 = _1124 / _1119;
                      float _1127 = _1125 * 0.5f;
                      float _1128 = _1126 * 0.5f;
                      float _1129 = _1127 + 0.5f;
                      float _1130 = 0.5f - _1128;
                      if (_869) {
                        int _1132 = asint(_1120);
                        int _1133 = (uint)(_1132) >> 18;
                        int _1134 = _1133 & 4092;
                        float _1135 = float((uint)_1134);
                        bool _1136 = (_1134 == 0);
                        [branch]
                        if (!_1136) {
                          int _1138 = (uint)(_1132) >> 30;
                          float _1139 = float((uint)_1138);
                          int _1140 = (uint)(_1132) >> 8;
                          int _1141 = _1140 & 4092;
                          float _1142 = float((uint)_1141);
                          uint _1143 = _1132 << 2u;
                          int _1144 = _1143 & 4092;
                          float _1145 = float((uint)_1144);
                          float _1146 = _1129 * _1135;
                          float _1147 = _1130 * _1135;
                          float _1148 = _1146 + _1145;
                          float _1149 = _1147 + _1142;
                          float _1152 = cb13_067x * _1148;
                          float _1153 = cb13_067x * _1149;
                          float _1156 = t9.SampleLevel(s10, float3(_1152, _1153, _1139), 0.0f);
                          float _1158 = _859 * 0.9900000095367432f;
                          float _1159 = _1156.x - _1158;
                          float _1160 = _1159 * 144.26950073242188f;
                          float _1161 = exp2(_1160);
                          float _1162 = saturate(_1161);
                          _1164 = _1162;
                        } else {
                          _1164 = 1.0f;
                        }
                      } else {
                        _1164 = 1.0f;
                      }
                      if (_877) {
                        int _1166 = _875 & 2;
                        bool _1167 = (_1166 != 0);
                        int _1168 = _875 & 8;
                        bool _1169 = (_1168 == 0);
                        if (_1167) {
                          int _1171 = _1121 & 1023;
                          _1177 = _1171;
                          _1178 = 0;
                        } else {
                          int _1173 = _1121 & 255;
                          int _1174 = (uint)(_1121) >> 8;
                          int _1175 = _1174 & 3;
                          _1177 = _1173;
                          _1178 = _1175;
                        }
                        float _1179 = float((uint)_1177);
                        float _1181 = t16[_832].LightParams_144.y;
                        float _1182 = floor(_1181);
                        float _1183 = _1182 + _1179;
                        float4 _1187 = t42.SampleLevel(s10, float3(_1129, _1130, _1183), 0.0f);
                        _37[0] = _1187.x;
                        _37[1] = _1187.y;
                        _37[2] = _1187.z;
                        _37[3] = _1187.w;
                        if (!_1169) {
                          float _1197 = _1183 + 1.0f;
                          float4 _1198 = t42.SampleLevel(s10, float3(_1129, _1130, _1197), 0.0f);
                          float _1203 = frac(_1181);
                          float _1204 = _1198.x - _1187.x;
                          float _1205 = _1198.y - _1187.y;
                          float _1206 = _1198.z - _1187.z;
                          float _1207 = _1198.w - _1187.w;
                          float _1208 = _1204 * _1203;
                          float _1209 = _1205 * _1203;
                          float _1210 = _1206 * _1203;
                          float _1211 = _1207 * _1203;
                          float _1212 = _1208 + _1187.x;
                          float _1213 = _1209 + _1187.y;
                          float _1214 = _1210 + _1187.z;
                          float _1215 = _1211 + _1187.w;
                          _37[0] = _1212;
                          _37[1] = _1213;
                          _37[2] = _1214;
                          _37[3] = _1215;
                          _1217 = _1214;
                          _1218 = _1213;
                          _1219 = _1212;
                        } else {
                          _1217 = _1187.z;
                          _1218 = _1187.y;
                          _1219 = _1187.x;
                        }
                        if (!_1167) {
                          float _1222 = _37[_1178];
                          _1224 = _1222;
                          _1225 = _1222;
                          _1226 = _1222;
                        } else {
                          _1224 = _1219;
                          _1225 = _1218;
                          _1226 = _1217;
                        }
                        _1228 = _1164;
                        _1229 = _1224;
                        _1230 = _1225;
                        _1231 = _1226;
                      } else {
                        _1228 = _1164;
                        _1229 = 1.0f;
                        _1230 = 1.0f;
                        _1231 = 1.0f;
                      }
                    } else {
                      _1228 = 1.0f;
                      _1229 = 1.0f;
                      _1230 = 1.0f;
                      _1231 = 1.0f;
                    }
                    bool _1232 = _872 && _908;
                    if (_1232) {
                      float _1234 = t16[_832].LightParams_096.y;
                      float _1237 = t10.SampleLevel(s10, float4(_843, _844, _845, _1234), 0.0f);
                      float _1239 = _859 * 0.9900000095367432f;
                      float _1240 = _1237.x - _1239;
                      float _1241 = _1240 * 144.26950073242188f;
                      float _1242 = exp2(_1241);
                      float _1243 = saturate(_1242);
                      float _1244 = _1243 * _1228;
                      _1246 = _1244;
                    } else {
                      _1246 = _1228;
                    }
                    float _1247 = t16[_832].LightParams_080.w;
                    float _1248 = _1246 + -1.0f;
                    float _1249 = _1248 * _1247;
                    float _1250 = _1249 + 1.0f;
                    float _1251 = _1250 * _906;
                    float _1252 = _1251 * _1229;
                    float _1253 = _1251 * _1230;
                    float _1254 = _1251 * _1231;
                    bool _1255 = (_1252 > 0.0f);
                    bool _1256 = (_1253 > 0.0f);
                    bool _1257 = (_1254 > 0.0f);
                    bool _1258 = _1255 || _1256;
                    bool _1259 = _1257 || _1258;
                    [branch]
                    if (_1259) {
                      float _1261 = dot(float3(_843, _844, _845), float3(_843, _844, _845));
                      float _1262 = rsqrt(_1261);
                      float _1263 = _1262 * _843;
                      float _1264 = _1262 * _844;
                      float _1265 = _1262 * _845;
                      float _1266 = _1263 + _696;
                      float _1267 = _1264 + _697;
                      float _1268 = _1265 + _698;
                      float _1269 = dot(float3(_1266, _1267, _1268), float3(_1266, _1267, _1268));
                      float _1270 = rsqrt(_1269);
                      float _1271 = _1266 * _1270;
                      float _1272 = _1267 * _1270;
                      float _1273 = _1268 * _1270;
                      float _1274 = dot(float3(_1271, _1272, _1273), float3(_696, _697, _698));
                      float _1275 = abs(_1274);
                      float _1276 = 1.0f - _1275;
                      float _1277 = saturate(_1276);
                      float _1278 = _1277 * _1277;
                      float _1281 = _1278 * _1278;
                      float _1282 = _1281 * _1277;
                      float _1283 = _1282 * cb13_066x;
                      float _1285 = cb13_066z + 1.0f;
                      float _1286 = _1283 / _1285;
                      float _1287 = 1.0f - _1286;
                      float _1288 = dot(float3(_70, _71, _72), float3(_1263, _1264, _1265));
                      float _1289 = saturate(_1288);
                      float _1290 = t16[_832].LightParams_048.x;
                      float _1291 = t16[_832].LightParams_048.y;
                      float _1292 = t16[_832].LightParams_048.z;
                      float _1293 = _1289 * _1287;
                      float _1294 = _1252 * _1290;
                      float _1295 = _1294 * _1293;
                      float _1296 = _1253 * _1291;
                      float _1297 = _1296 * _1293;
                      float _1298 = _1254 * _1292;
                      float _1299 = _1298 * _1293;
                      // GRAPHICS HIT BEGIN
                      if (graphics_hit) {
                        float3 diffuse, specular;
                        GraphicsHitBRDF(float3(_70, _71, _72), float3(_696, _697, _698),
                            float3(_1263, _1264, _1265), graphics_material, diffuse, specular);
                        _1295 = _1294 * diffuse.x;
                        _1297 = _1296 * diffuse.y;
                        _1299 = _1298 * diffuse.z;
                        graphics_specular += cb0_000y * float3(_1294, _1296, _1298) * specular;
                      }
                      // GRAPHICS HIT END
                      float _1300 = _1295 + _826;
                      float _1301 = _1297 + _827;
                      float _1302 = _1299 + _828;
                      _1304 = _1300;
                      _1305 = _1301;
                      _1306 = _1302;
                    } else {
                      _1304 = _826;
                      _1305 = _827;
                      _1306 = _828;
                    }
                  } else {
                    _1304 = _826;
                    _1305 = _827;
                    _1306 = _828;
                  }
                  uint _1307 = _829 + 1u;
                  bool _1308 = (_1307 == _821);
                  if (!_1308) {
                    _826 = _1304;
                    _827 = _1305;
                    _828 = _1306;
                    _829 = _1307;
                    continue;
                  }
                  break;
                }
                _1311 = _1304;
                _1312 = _1305;
                _1313 = _1306;
              } else {
                _1311 = 0.0f;
                _1312 = 0.0f;
                _1313 = 0.0f;
              }
              float _1316 = cb0_000y * _1311;
              float _1317 = cb0_000y * _1312;
              float _1318 = cb0_000y * _1313;
              _1320 = _1316;
              _1321 = _1317;
              _1322 = _1318;
            } else {
              _1320 = 0.0f;
              _1321 = 0.0f;
              _1322 = 0.0f;
            }
            int _1323 = CustomConstants_128 & 2;
            bool _1324 = (_1323 == 0);
            if (!_1324) {
              uint _1328 = _100 << 8u;
              int _1329 = _1328 | _100;
              int _1330 = _1329 & 16711935;
              int _1331 = _1330 << 4u;
              int _1332 = _1331 | _1330;
              int _1333 = _1332 & 252645135;
              int _1334 = _1333 << 2u;
              int _1335 = _1334 | _1333;
              int _1336 = _1335 & 858993459;
              int _1337 = _1336 << 1u;
              int _1338 = _1337 | _1336;
              int _1339 = _1338 & 1431655765;
              uint _1340 = SV_DispatchThreadID.y << 8u;
              int _1341 = _1340 | (int)(SV_DispatchThreadID.y);
              int _1342 = _1341 & 16711935;
              int _1343 = _1342 << 4u;
              int _1344 = _1343 | _1342;
              int _1345 = _1344 & 252645135;
              int _1346 = _1345 << 2u;
              int _1347 = _1346 | _1345;
              int _1348 = _1347 & 858993459;
              int _1349 = _1348 << 1u;
              int _1350 = _1349 | _1348;
              uint _1351 = _1350 << 1u;
              int _1352 = _1351 & -1431655766;
              int _1353 = _1339 | _1352;
              uint _1354 = (uint)(CameraCB_220) << 4u;
              uint _1355 = _1354 + -1556008596u;
              uint _1356 = (uint)(CameraCB_220) + -1640531527u;
              int _1357 = _1355 ^ _1356;
              int _1358 = (uint)((uint)(CameraCB_220)) >> 5;
              int _1359 = _1358 + -939442524;
              int _1360 = _1357 ^ _1359;
              uint _1361 = _1360 + _1353;
              uint _1362 = _1361 << 4u;
              uint _1363 = _1362 + -1383041155u;
              uint _1364 = _1361 + -1640531527u;
              int _1365 = _1363 ^ _1364;
              int _1366 = (uint)(_1361) >> 5;
              uint _1367 = _1366 + 2123724318u;
              int _1368 = _1365 ^ _1367;
              uint _1369 = _1368 + (uint)(CameraCB_220);
              uint _1370 = _1369 << 4u;
              uint _1371 = _1370 + -1556008596u;
              uint _1372 = _1369 + 1013904242u;
              int _1373 = _1371 ^ _1372;
              int _1374 = (uint)(_1369) >> 5;
              int _1375 = _1374 + -939442524;
              int _1376 = _1373 ^ _1375;
              uint _1377 = _1376 + _1361;
              uint _1378 = _1377 << 4u;
              uint _1379 = _1378 + -1383041155u;
              uint _1380 = _1377 + 1013904242u;
              int _1381 = _1379 ^ _1380;
              int _1382 = (uint)(_1377) >> 5;
              uint _1383 = _1382 + 2123724318u;
              int _1384 = _1381 ^ _1383;
              uint _1385 = _1384 + _1369;
              uint _1386 = _1385 << 4u;
              uint _1387 = _1386 + -1556008596u;
              uint _1388 = _1385 + -626627285u;
              int _1389 = _1387 ^ _1388;
              int _1390 = (uint)(_1385) >> 5;
              int _1391 = _1390 + -939442524;
              int _1392 = _1389 ^ _1391;
              uint _1393 = _1392 + _1377;
              uint _1394 = _1393 << 4u;
              uint _1395 = _1394 + -1383041155u;
              uint _1396 = _1393 + -626627285u;
              int _1397 = _1395 ^ _1396;
              int _1398 = (uint)(_1393) >> 5;
              uint _1399 = _1398 + 2123724318u;
              int _1400 = _1397 ^ _1399;
              uint _1401 = _1400 + _1385;
              uint _1402 = _1401 << 4u;
              uint _1403 = _1402 + -1556008596u;
              uint _1404 = _1401 + 2027808484u;
              int _1405 = _1403 ^ _1404;
              int _1406 = (uint)(_1401) >> 5;
              int _1407 = _1406 + -939442524;
              int _1408 = _1405 ^ _1407;
              uint _1409 = _1408 + _1393;
              uint _1410 = _1409 << 4u;
              uint _1411 = _1410 + -1383041155u;
              uint _1412 = _1409 + 2027808484u;
              int _1413 = _1411 ^ _1412;
              int _1414 = (uint)(_1409) >> 5;
              uint _1415 = _1414 + 2123724318u;
              int _1416 = _1413 ^ _1415;
              uint _1417 = _1416 + _1401;
              uint _1418 = _1417 << 4u;
              uint _1419 = _1418 + -1556008596u;
              uint _1420 = _1417 + 387276957u;
              int _1421 = _1419 ^ _1420;
              int _1422 = (uint)(_1417) >> 5;
              int _1423 = _1422 + -939442524;
              int _1424 = _1421 ^ _1423;
              uint _1425 = _1424 + _1409;
              uint _1426 = _1425 << 4u;
              uint _1427 = _1426 + -1383041155u;
              uint _1428 = _1425 + 387276957u;
              int _1429 = _1427 ^ _1428;
              int _1430 = (uint)(_1425) >> 5;
              uint _1431 = _1430 + 2123724318u;
              int _1432 = _1429 ^ _1431;
              uint _1433 = _1432 + _1417;
              uint _1434 = _1433 << 4u;
              uint _1435 = _1434 + -1556008596u;
              uint _1436 = _1433 + -1253254570u;
              int _1437 = _1435 ^ _1436;
              int _1438 = (uint)(_1433) >> 5;
              int _1439 = _1438 + -939442524;
              int _1440 = _1437 ^ _1439;
              uint _1441 = _1440 + _1425;
              uint _1442 = _1441 << 4u;
              uint _1443 = _1442 + -1383041155u;
              uint _1444 = _1441 + -1253254570u;
              int _1445 = _1443 ^ _1444;
              int _1446 = (uint)(_1441) >> 5;
              uint _1447 = _1446 + 2123724318u;
              int _1448 = _1445 ^ _1447;
              uint _1449 = _1448 + _1433;
              uint _1450 = _1449 << 4u;
              uint _1451 = _1450 + -1556008596u;
              uint _1452 = _1449 + 1401181199u;
              int _1453 = _1451 ^ _1452;
              int _1454 = (uint)(_1449) >> 5;
              int _1455 = _1454 + -939442524;
              int _1456 = _1453 ^ _1455;
              uint _1457 = _1456 + _1441;
              uint _1458 = _1457 << 4u;
              uint _1459 = _1458 + -1383041155u;
              uint _1460 = _1457 + 1401181199u;
              int _1461 = _1459 ^ _1460;
              int _1462 = (uint)(_1457) >> 5;
              uint _1463 = _1462 + 2123724318u;
              int _1464 = _1461 ^ _1463;
              uint _1465 = _1464 + _1449;
              uint _1466 = _1465 << 4u;
              uint _1467 = _1466 + -1556008596u;
              uint _1468 = _1465 + -239350328u;
              int _1469 = _1467 ^ _1468;
              int _1470 = (uint)(_1465) >> 5;
              int _1471 = _1470 + -939442524;
              int _1472 = _1469 ^ _1471;
              uint _1473 = _1472 + _1457;
              uint _1474 = _1473 << 4u;
              uint _1475 = _1474 + -1383041155u;
              uint _1476 = _1473 + -239350328u;
              int _1477 = _1475 ^ _1476;
              int _1478 = (uint)(_1473) >> 5;
              uint _1479 = _1478 + 2123724318u;
              int _1480 = _1477 ^ _1479;
              uint _1481 = _1480 + _1465;
              uint _1482 = _1481 << 4u;
              uint _1483 = _1482 + -1556008596u;
              uint _1484 = _1481 + -1879881855u;
              int _1485 = _1483 ^ _1484;
              int _1486 = (uint)(_1481) >> 5;
              int _1487 = _1486 + -939442524;
              int _1488 = _1485 ^ _1487;
              uint _1489 = _1488 + _1473;
              uint _1490 = _1489 << 4u;
              uint _1491 = _1490 + -1383041155u;
              uint _1492 = _1489 + -1879881855u;
              int _1493 = _1491 ^ _1492;
              int _1494 = (uint)(_1489) >> 5;
              uint _1495 = _1494 + 2123724318u;
              int _1496 = _1493 ^ _1495;
              uint _1497 = _1496 + _1481;
              uint _1498 = _1497 << 4u;
              uint _1499 = _1498 + -1556008596u;
              uint _1500 = _1497 + 774553914u;
              int _1501 = _1499 ^ _1500;
              int _1502 = (uint)(_1497) >> 5;
              int _1503 = _1502 + -939442524;
              int _1504 = _1501 ^ _1503;
              uint _1505 = _1504 + _1489;
              uint _1506 = _1505 << 4u;
              uint _1507 = _1506 + -1383041155u;
              uint _1508 = _1505 + 774553914u;
              int _1509 = _1507 ^ _1508;
              int _1510 = (uint)(_1505) >> 5;
              uint _1511 = _1510 + 2123724318u;
              int _1512 = _1509 ^ _1511;
              uint _1513 = _1512 + _1497;
              uint _1514 = _1513 << 4u;
              uint _1515 = _1514 + -1556008596u;
              uint _1516 = _1513 + -865977613u;
              int _1517 = _1515 ^ _1516;
              int _1518 = (uint)(_1513) >> 5;
              int _1519 = _1518 + -939442524;
              int _1520 = _1517 ^ _1519;
              uint _1521 = _1520 + _1505;
              uint _1522 = _1521 << 4u;
              uint _1523 = _1522 + -1383041155u;
              uint _1524 = _1521 + -865977613u;
              int _1525 = _1523 ^ _1524;
              int _1526 = (uint)(_1521) >> 5;
              uint _1527 = _1526 + 2123724318u;
              int _1528 = _1525 ^ _1527;
              uint _1529 = _1528 + _1513;
              uint _1530 = _1529 << 4u;
              uint _1531 = _1530 + -1556008596u;
              uint _1532 = _1529 + 1788458156u;
              int _1533 = _1531 ^ _1532;
              int _1534 = (uint)(_1529) >> 5;
              int _1535 = _1534 + -939442524;
              int _1536 = _1533 ^ _1535;
              uint _1537 = _1536 + _1521;
              uint _1538 = _1537 << 4u;
              uint _1539 = _1538 + -1383041155u;
              uint _1540 = _1537 + 1788458156u;
              int _1541 = _1539 ^ _1540;
              int _1542 = (uint)(_1537) >> 5;
              uint _1543 = _1542 + 2123724318u;
              int _1544 = _1541 ^ _1543;
              uint _1545 = _1544 + _1529;
              uint _1546 = _1545 << 4u;
              uint _1547 = _1546 + -1556008596u;
              uint _1548 = _1545 + 147926629u;
              int _1549 = _1547 ^ _1548;
              int _1550 = (uint)(_1545) >> 5;
              int _1551 = _1550 + -939442524;
              int _1552 = _1549 ^ _1551;
              uint _1553 = _1552 + _1537;
              uint _1554 = _1553 << 4u;
              uint _1555 = _1554 + -1383041155u;
              uint _1556 = _1553 + 147926629u;
              int _1557 = _1555 ^ _1556;
              int _1558 = (uint)(_1553) >> 5;
              uint _1559 = _1558 + 2123724318u;
              int _1560 = _1557 ^ _1559;
              uint _1561 = _1560 + _1545;
              uint _1562 = _1561 << 4u;
              uint _1563 = _1562 + -1556008596u;
              uint _1564 = _1561 + -1492604898u;
              int _1565 = _1563 ^ _1564;
              int _1566 = (uint)(_1561) >> 5;
              int _1567 = _1566 + -939442524;
              int _1568 = _1565 ^ _1567;
              uint _1569 = _1568 + _1553;
              uint _1570 = _1569 << 4u;
              uint _1571 = _1570 + -1383041155u;
              uint _1572 = _1569 + -1492604898u;
              int _1573 = _1571 ^ _1572;
              int _1574 = (uint)(_1569) >> 5;
              uint _1575 = _1574 + 2123724318u;
              int _1576 = _1573 ^ _1575;
              uint _1577 = _1576 + _1561;
              uint _1578 = _1577 << 4u;
              uint _1579 = _1578 + -1556008596u;
              uint _1580 = _1577 + 1161830871u;
              int _1581 = _1579 ^ _1580;
              int _1582 = (uint)(_1577) >> 5;
              int _1583 = _1582 + -939442524;
              int _1584 = _1581 ^ _1583;
              uint _1585 = _1584 + _1569;
              uint _1586 = _1585 << 4u;
              uint _1587 = _1586 + -1383041155u;
              uint _1588 = _1585 + 1161830871u;
              int _1589 = _1587 ^ _1588;
              int _1590 = (uint)(_1585) >> 5;
              uint _1591 = _1590 + 2123724318u;
              int _1592 = _1589 ^ _1591;
              uint _1593 = _1592 + _1577;
              uint _1594 = _1593 << 4u;
              uint _1595 = _1594 + -1556008596u;
              uint _1596 = _1593 + -478700656u;
              int _1597 = _1595 ^ _1596;
              int _1598 = (uint)(_1593) >> 5;
              int _1599 = _1598 + -939442524;
              int _1600 = _1597 ^ _1599;
              uint _1601 = _1600 + _1585;
              uint _1602 = _1601 << 13u;
              int _1603 = _1602 ^ _1601;
              int _1604 = (uint)(_1603) >> 17;
              int _1605 = _1604 ^ _1603;
              uint _1606 = _1605 << 5u;
              int _1607 = _1606 ^ _1605;
              int _1608 = (uint)(_1607) >> 9;
              int _1609 = _1608 | 1065353216;
              float _1610 = asfloat(_1609);
              float _1611 = 2.0f - _1610;
              bool _1614 = (cb12_074y > 0.0f);
              if (!_1614) {
                float _1620 = (gridDesc_000[1].PROBE_GRID_DESC_176.x) * _157;
                float _1621 = (gridDesc_000[1].PROBE_GRID_DESC_176.y) * _158;
                float _1622 = (gridDesc_000[1].PROBE_GRID_DESC_176.z) * _159;
                float _1627 = _1620 + (gridDesc_000[1].PROBE_GRID_DESC_208.x);
                float _1628 = _1621 + (gridDesc_000[1].PROBE_GRID_DESC_208.y);
                float _1629 = _1622 + (gridDesc_000[1].PROBE_GRID_DESC_208.z);
                float _1630 = abs(_1627);
                float _1631 = abs(_1628);
                float _1632 = abs(_1629);
                float _1637 = (gridDesc_000[1].PROBE_GRID_DESC_224.x) * _1630;
                float _1638 = (gridDesc_000[1].PROBE_GRID_DESC_224.y) * _1631;
                float _1639 = (gridDesc_000[1].PROBE_GRID_DESC_224.z) * _1632;
                float _1641 = _1637 + (gridDesc_000[1].PROBE_GRID_DESC_236);
                float _1642 = _1638 + (gridDesc_000[1].PROBE_GRID_DESC_236);
                float _1643 = _1639 + (gridDesc_000[1].PROBE_GRID_DESC_236);
                float _1644 = saturate(_1641);
                float _1645 = saturate(_1642);
                float _1646 = saturate(_1643);
                float _1647 = min(_1644, _1645);
                float _1648 = _1646 * _1646;
                float _1649 = _1648 * _1647;
                float _1654 = (gridDesc_000[0].PROBE_GRID_DESC_176.x) * _157;
                float _1655 = (gridDesc_000[0].PROBE_GRID_DESC_176.y) * _158;
                float _1656 = (gridDesc_000[0].PROBE_GRID_DESC_176.z) * _159;
                float _1661 = _1654 + (gridDesc_000[0].PROBE_GRID_DESC_208.x);
                float _1662 = _1655 + (gridDesc_000[0].PROBE_GRID_DESC_208.y);
                float _1663 = _1656 + (gridDesc_000[0].PROBE_GRID_DESC_208.z);
                float _1664 = abs(_1661);
                float _1665 = abs(_1662);
                float _1666 = abs(_1663);
                float _1671 = (gridDesc_000[0].PROBE_GRID_DESC_224.x) * _1664;
                float _1672 = (gridDesc_000[0].PROBE_GRID_DESC_224.y) * _1665;
                float _1673 = (gridDesc_000[0].PROBE_GRID_DESC_224.z) * _1666;
                float _1675 = _1671 + (gridDesc_000[0].PROBE_GRID_DESC_236);
                float _1676 = _1672 + (gridDesc_000[0].PROBE_GRID_DESC_236);
                float _1677 = _1673 + (gridDesc_000[0].PROBE_GRID_DESC_236);
                float _1678 = saturate(_1675);
                float _1679 = saturate(_1676);
                float _1680 = saturate(_1677);
                float _1681 = min(_1678, _1679);
                float _1682 = _1680 * _1680;
                float _1683 = _1682 * _1681;
                bool _1684 = (_1649 > 9.999999717180685e-10f);
                int _1685 = (int)(uint)(_1684);
                bool _1686 = (_1649 < 1.0f);
                if (_1686) {
                  bool _1688 = (_1683 > 9.999999717180685e-10f);
                  int _1689 = (int)(uint)(_1688);
                  bool _1690 = _1684 && _1688;
                  if (_1690) {
                    float _1692 = _1611 + _1683;
                    bool _1693 = (_1692 > 0.5f);
                    int _1694 = (int)(uint)(_1693);
                    int _1695 = _1694 ^ 1;
                    float _1696 = select(_1693, 1.0f, 0.0f);
                    _1698 = _1696;
                    _1699 = _1694;
                    _1700 = _1695;
                  } else {
                    _1698 = _1649;
                    _1699 = _1685;
                    _1700 = _1689;
                  }
                } else {
                  _1698 = _1649;
                  _1699 = _1685;
                  _1700 = 0;
                }
                bool _1701 = (_1699 == 0);
                if (!_1701) {
                  float _1735 = (gridDesc_000[1].PROBE_GRID_DESC_152) * _70;
                  float _1736 = (gridDesc_000[1].PROBE_GRID_DESC_152) * _71;
                  float _1737 = (gridDesc_000[1].PROBE_GRID_DESC_152) * _72;
                  float _1738 = _1735 + _157;
                  float _1739 = _1736 + _158;
                  float _1740 = _1737 + _159;
                  float _1741 = (gridDesc_000[1].PROBE_GRID_DESC_156) * _696;
                  float _1742 = (gridDesc_000[1].PROBE_GRID_DESC_156) * _697;
                  float _1743 = (gridDesc_000[1].PROBE_GRID_DESC_156) * _698;
                  float _1744 = _1738 + _1741;
                  float _1745 = _1739 + _1742;
                  float _1746 = _1740 + _1743;
                  float _1747 = _1744 * (gridDesc_000[1].PROBE_GRID_DESC_176.x);
                  float _1748 = _1745 * (gridDesc_000[1].PROBE_GRID_DESC_176.y);
                  float _1749 = _1746 * (gridDesc_000[1].PROBE_GRID_DESC_176.z);
                  float _1750 = _1747 + (gridDesc_000[1].PROBE_GRID_DESC_192.x);
                  float _1751 = _1748 + (gridDesc_000[1].PROBE_GRID_DESC_192.y);
                  float _1752 = _1749 + (gridDesc_000[1].PROBE_GRID_DESC_192.z);
                  int _1753 = int(_1750);
                  int _1754 = int(_1751);
                  int _1755 = int(_1752);
                  uint _1756 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) + -1u;
                  uint _1757 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) + -1u;
                  uint _1758 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) + -1u;
                  int _1759 = max(_1753, 0);
                  int _1760 = max(_1754, 0);
                  int _1761 = max(_1755, 0);
                  int _1762 = min(_1759, _1756);
                  int _1763 = min(_1760, _1757);
                  int _1764 = min(_1761, _1758);
                  float _1765 = float((int)(_1762));
                  float _1766 = float((int)(_1763));
                  float _1767 = float((int)(_1764));
                  float _1768 = _1750 - _1765;
                  float _1769 = _1751 - _1766;
                  float _1770 = _1752 - _1767;
                  _1774 = 0.0f;
                  _1775 = 0.0f;
                  _1776 = 0.0f;
                  _1777 = 0.0f;
                  _1778 = 0.0f;
                  _1779 = 0;
                  while(true) {
                    int _1780 = (uint)(_1779) >> 1;
                    int _1781 = (uint)(_1779) >> 2;
                    int _1782 = _1779 & 1;
                    int _1783 = _1780 & 1;
                    int _1784 = _1781 & 1;
                    uint _1785 = _1782 + _1762;
                    uint _1786 = _1783 + _1763;
                    uint _1787 = _1784 + _1764;
                    bool _1788 = ((int)_1785 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.x));
                    bool _1789 = ((int)_1786 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.y));
                    bool _1790 = ((int)_1787 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.z));
                    bool _1791 = _1788 || _1789;
                    bool _1792 = _1790 || _1791;
                    if (!_1792) {
                      uint _1794 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.x));
                      uint _1795 = _1794 + _1785;
                      uint _1796 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.y));
                      uint _1797 = _1796 + _1786;
                      uint _1798 = ((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.z));
                      uint _1799 = _1798 + _1787;
                      int _1800 = _1795 % (gridDesc_000[1].PROBE_GRID_DESC_032.x);
                      int _1801 = _1797 % (gridDesc_000[1].PROBE_GRID_DESC_032.y);
                      int _1802 = _1799 % (gridDesc_000[1].PROBE_GRID_DESC_032.z);
                      int _1803 = _1800 * (gridDesc_000[1].PROBE_GRID_DESC_032.z);
                      int _1804 = _1802 + _1803;
                      float4 _1807 = t34[1].Load(int3(_1804, _1801, 0));
                      uint _1810 = t32[1].Load(int3(_1804, _1801, 0));
                      int _1812 = _1810.x & -2;
                      bool _1813 = (_1812 == 2);
                      if (_1813) {
                        float _1816 = _1807.z * 0.44999998807907104f;
                        float _1818 = _1807.y * 0.44999998807907104f;
                        float _1820 = _1807.x * 0.44999998807907104f;
                        float _1821 = float((int)(_1782));
                        float _1822 = float((int)(_1783));
                        float _1823 = float((int)(_1784));
                        float _1824 = _1765 - (gridDesc_000[1].PROBE_GRID_DESC_160.x);
                        float _1825 = _1824 + _1821;
                        float _1826 = _1825 + _1820;
                        float _1827 = _1826 * (gridDesc_000[1].PROBE_GRID_DESC_016.x);
                        float _1828 = (gridDesc_000[1].PROBE_GRID_DESC_000.x) - _1744;
                        float _1829 = _1827 + _1828;
                        float _1830 = _1766 - (gridDesc_000[1].PROBE_GRID_DESC_160.y);
                        float _1831 = _1830 + _1822;
                        float _1832 = _1831 + _1818;
                        float _1833 = _1832 * (gridDesc_000[1].PROBE_GRID_DESC_016.y);
                        float _1834 = (gridDesc_000[1].PROBE_GRID_DESC_000.y) - _1745;
                        float _1835 = _1833 + _1834;
                        float _1836 = _1767 - (gridDesc_000[1].PROBE_GRID_DESC_160.z);
                        float _1837 = _1836 + _1823;
                        float _1838 = _1837 + _1816;
                        float _1839 = _1838 * (gridDesc_000[1].PROBE_GRID_DESC_016.z);
                        float _1840 = (gridDesc_000[1].PROBE_GRID_DESC_000.z) - _1746;
                        float _1841 = _1839 + _1840;
                        float _1842 = _1829 * _1829;
                        float _1843 = _1835 * _1835;
                        float _1844 = _1842 + _1843;
                        float _1845 = _1841 * _1841;
                        float _1846 = _1844 + _1845;
                        float _1847 = sqrt(_1846);
                        float _1848 = max(_1847, 9.999999747378752e-06f);
                        float _1849 = _1829 / _1848;
                        float _1850 = _1835 / _1848;
                        float _1851 = _1841 / _1848;
                        float _1852 = -0.0f - _1849;
                        float _1853 = -0.0f - _1850;
                        float _1854 = -0.0f - _1851;
                        float _1855 = abs(_1852);
                        float _1856 = abs(_1853);
                        float _1857 = _1856 + _1855;
                        float _1858 = abs(_1854);
                        float _1859 = _1857 + _1858;
                        float _1860 = _1852 / _1859;
                        float _1861 = _1853 / _1859;
                        float _1862 = _1854 / _1859;
                        bool _1863 = (_1862 > 0.0f);
                        if (!_1863) {
                          float _1865 = abs(_1861);
                          float _1866 = abs(_1860);
                          float _1867 = 1.0f - _1865;
                          float _1868 = 1.0f - _1866;
                          bool _1869 = (_1860 > 0.0f);
                          bool _1870 = (_1861 > 0.0f);
                          bool _1871 = (_1860 < 0.0f);
                          bool _1872 = (_1861 < 0.0f);
                          int _1873 = (int)(uint)(_1869);
                          int _1874 = (int)(uint)(_1870);
                          int _1875 = (int)(uint)(_1871);
                          int _1876 = (int)(uint)(_1872);
                          int _1877 = _1873 - _1875;
                          int _1878 = _1874 - _1876;
                          float _1879 = float((int)(_1877));
                          float _1880 = float((int)(_1878));
                          float _1881 = _1867 * _1879;
                          float _1882 = _1868 * _1880;
                          _1884 = _1881;
                          _1885 = _1882;
                        } else {
                          _1884 = _1860;
                          _1885 = _1861;
                        }
                        float _1886 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_092));
                        float _1887 = _1886 * 0.5f;
                        float _1888 = _1886 + 2.0f;
                        float _1889 = _1887 / _1888;
                        float _1890 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.x));
                        float _1891 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.y));
                        float _1892 = 1.0f / _1890;
                        float _1893 = 1.0f / _1891;
                        float _1894 = float((int)(_1800));
                        float _1895 = float((int)(_1801));
                        float _1896 = _1894 + 0.5f;
                        float _1897 = _1895 + 0.5f;
                        float _1898 = _1889 * _1884;
                        float _1899 = _1889 * _1885;
                        float _1900 = _1898 + _1896;
                        float _1901 = _1899 + _1897;
                        float _1902 = _1900 * _1892;
                        float _1903 = _1901 * _1893;
                        float _1904 = float((int)(_1802));
                        float3 _1908 = t30[1].SampleLevel(s7, float3(_1902, _1903, _1904), 0.0f);
                        float _1911 = abs(_70);
                        float _1912 = abs(_71);
                        float _1913 = _1912 + _1911;
                        float _1914 = abs(_72);
                        float _1915 = _1913 + _1914;
                        float _1916 = _70 / _1915;
                        float _1917 = _71 / _1915;
                        float _1918 = _72 / _1915;
                        bool _1919 = (_1918 > 0.0f);
                        if (!_1919) {
                          float _1921 = abs(_1917);
                          float _1922 = abs(_1916);
                          float _1923 = 1.0f - _1921;
                          float _1924 = 1.0f - _1922;
                          bool _1925 = (_1916 > 0.0f);
                          bool _1926 = (_1917 > 0.0f);
                          bool _1927 = (_1916 < 0.0f);
                          bool _1928 = (_1917 < 0.0f);
                          int _1929 = (int)(uint)(_1925);
                          int _1930 = (int)(uint)(_1926);
                          int _1931 = (int)(uint)(_1927);
                          int _1932 = (int)(uint)(_1928);
                          int _1933 = _1929 - _1931;
                          int _1934 = _1930 - _1932;
                          float _1935 = float((int)(_1933));
                          float _1936 = float((int)(_1934));
                          float _1937 = _1923 * _1935;
                          float _1938 = _1924 * _1936;
                          _1940 = _1937;
                          _1941 = _1938;
                        } else {
                          _1940 = _1916;
                          _1941 = _1917;
                        }
                        float _1942 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_088));
                        float _1943 = _1942 * 0.5f;
                        float _1944 = _1942 + 2.0f;
                        float _1945 = _1943 / _1944;
                        float _1946 = _1945 * _1940;
                        float _1947 = _1945 * _1941;
                        float _1948 = _1946 + _1896;
                        float _1949 = _1947 + _1897;
                        float _1950 = _1948 * _1892;
                        float _1951 = _1949 * _1893;
                        float4 _1955 = t28[1].SampleLevel(s7, float3(_1950, _1951, _1904), 0.0f);
                        float _1959 = (gridDesc_000[1].PROBE_GRID_DESC_104) * 0.5f;
                        float _1960 = log2(_1955.x);
                        float _1961 = log2(_1955.y);
                        float _1962 = log2(_1955.z);
                        float _1963 = _1960 * _1959;
                        float _1964 = _1961 * _1959;
                        float _1965 = _1962 * _1959;
                        float _1966 = exp2(_1963);
                        float _1967 = exp2(_1964);
                        float _1968 = exp2(_1965);
                        float _1969 = 1.0f - _1768;
                        float _1970 = 1.0f - _1769;
                        float _1971 = 1.0f - _1770;
                        bool _1972 = (_1782 != 0);
                        bool _1973 = (_1783 != 0);
                        bool _1974 = (_1784 != 0);
                        float _1975 = select(_1972, _1768, _1969);
                        float _1976 = select(_1973, _1769, _1970);
                        float _1977 = select(_1974, _1770, _1971);
                        float _1978 = _1976 * _1975;
                        float _1979 = _1978 * _1977;
                        float _1980 = _1979 + _1778;
                        bool _1981 = (_1847 > _1908.x);
                        if (_1981) {
                          float _1983 = _1908.x * _1908.x;
                          float _1984 = _1908.y - _1983;
                          float _1985 = abs(_1984);
                          float _1986 = _1847 - _1908.x;
                          float _1987 = _1986 * _1986;
                          float _1988 = _1985 + _1987;
                          float _1989 = _1985 / _1988;
                          float _1990 = _1989 * _1979;
                          _1992 = _1990;
                        } else {
                          _1992 = _1979;
                        }
                        float _1993 = dot(float3(_1849, _1850, _1851), float3(_70, _71, _72));
                        float _1994 = _1993 * 0.5f;
                        float _1995 = _1994 + 0.5f;
                        float _1996 = saturate(_1995);
                        float _1997 = _1996 * _1992;
                        float _1998 = _1997 * _1966;
                        float _1999 = _1997 * _1967;
                        float _2000 = _1997 * _1968;
                        float _2001 = _1998 + _1774;
                        float _2002 = _1999 + _1775;
                        float _2003 = _2000 + _1776;
                        float _2004 = _1997 + _1777;
                        _2006 = _2001;
                        _2007 = _2002;
                        _2008 = _2003;
                        _2009 = _2004;
                        _2010 = _1980;
                      } else {
                        _2006 = _1774;
                        _2007 = _1775;
                        _2008 = _1776;
                        _2009 = _1777;
                        _2010 = _1778;
                      }
                    } else {
                      _2006 = _1774;
                      _2007 = _1775;
                      _2008 = _1776;
                      _2009 = _1777;
                      _2010 = _1778;
                    }
                    int _2011 = _1779 + 1;
                    bool _2012 = (_2011 == 8);
                    if (!_2012) {
                      _1774 = _2006;
                      _1775 = _2007;
                      _1776 = _2008;
                      _1777 = _2009;
                      _1778 = _2010;
                      _1779 = _2011;
                      continue;
                    }
                    break;
                  }
                  while(true) {
                    bool _1772 = (_2009 > 9.999999747378752e-06f);
                    if (_1772) {
                      float _2014 = _2006 / _2009;
                      float _2015 = _2007 / _2009;
                      float _2016 = _2008 / _2009;
                      float _2017 = _2014 * _2014;
                      float _2018 = _2017 * 3.1415927410125732f;
                      float _2019 = _2015 * _2015;
                      float _2020 = _2019 * 3.1415927410125732f;
                      float _2021 = _2016 * _2016;
                      float _2022 = _2021 * 3.1415927410125732f;
                      _2036 = _2018;
                      _2037 = _2020;
                      _2038 = _2022;
                      _2039 = _2009;
                    } else {
                      bool _2024 = (_2010 > 9.999999747378752e-06f);
                      if (_2024) {
                        float _2026 = _2006 / _2010;
                        float _2027 = _2007 / _2010;
                        float _2028 = _2008 / _2010;
                        float _2029 = _2026 * _2026;
                        float _2030 = _2029 * 3.1415927410125732f;
                        float _2031 = _2027 * _2027;
                        float _2032 = _2031 * 3.1415927410125732f;
                        float _2033 = _2028 * _2028;
                        float _2034 = _2033 * 3.1415927410125732f;
                        _2036 = _2030;
                        _2037 = _2032;
                        _2038 = _2034;
                        _2039 = _2010;
                      } else {
                        _2036 = 0.0f;
                        _2037 = 0.0f;
                        _2038 = 0.0f;
                        _2039 = 0.0f;
                      }
                    }
                    bool _2040 = (_2039 < 9.999999747378752e-06f);
                    if (!_2040) {
                      _2042 = _2036;
                      _2043 = _2037;
                      _2044 = _2038;
                      bool _2045 = (_1700 == 0);
                      if (!_2045) {
                        _2047 = _2042;
                        _2048 = _2043;
                        _2049 = _2044;
                        _2050 = _1700;
                        _2051 = _1699;
                        _2052 = _1698;
                        float _2089 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _70;
                        float _2090 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _71;
                        float _2091 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _72;
                        float _2092 = _2089 + _157;
                        float _2093 = _2090 + _158;
                        float _2094 = _2091 + _159;
                        float _2095 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _696;
                        float _2096 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _697;
                        float _2097 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _698;
                        float _2098 = _2092 + _2095;
                        float _2099 = _2093 + _2096;
                        float _2100 = _2094 + _2097;
                        float _2101 = _2098 * (gridDesc_000[0].PROBE_GRID_DESC_176.x);
                        float _2102 = _2099 * (gridDesc_000[0].PROBE_GRID_DESC_176.y);
                        float _2103 = _2100 * (gridDesc_000[0].PROBE_GRID_DESC_176.z);
                        float _2104 = _2101 + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
                        float _2105 = _2102 + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
                        float _2106 = _2103 + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
                        int _2107 = int(_2104);
                        int _2108 = int(_2105);
                        int _2109 = int(_2106);
                        uint _2110 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u;
                        uint _2111 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u;
                        uint _2112 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u;
                        int _2113 = max(_2107, 0);
                        int _2114 = max(_2108, 0);
                        int _2115 = max(_2109, 0);
                        int _2116 = min(_2113, _2110);
                        int _2117 = min(_2114, _2111);
                        int _2118 = min(_2115, _2112);
                        float _2119 = float((int)(_2116));
                        float _2120 = float((int)(_2117));
                        float _2121 = float((int)(_2118));
                        float _2122 = _2104 - _2119;
                        float _2123 = _2105 - _2120;
                        float _2124 = _2106 - _2121;
                        _2128 = 0.0f;
                        _2129 = 0.0f;
                        _2130 = 0.0f;
                        _2131 = 0.0f;
                        _2132 = 0.0f;
                        _2133 = 0;
                        while(true) {
                          int _2134 = (uint)(_2133) >> 1;
                          int _2135 = (uint)(_2133) >> 2;
                          int _2136 = _2133 & 1;
                          int _2137 = _2134 & 1;
                          int _2138 = _2135 & 1;
                          uint _2139 = _2136 + _2116;
                          uint _2140 = _2137 + _2117;
                          uint _2141 = _2138 + _2118;
                          bool _2142 = ((int)_2139 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x));
                          bool _2143 = ((int)_2140 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y));
                          bool _2144 = ((int)_2141 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z));
                          bool _2145 = _2142 || _2143;
                          bool _2146 = _2144 || _2145;
                          if (!_2146) {
                            uint _2148 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x));
                            uint _2149 = _2148 + _2139;
                            uint _2150 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y));
                            uint _2151 = _2150 + _2140;
                            uint _2152 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z));
                            uint _2153 = _2152 + _2141;
                            int _2154 = _2149 % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
                            int _2155 = _2151 % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
                            int _2156 = _2153 % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
                            uint _2158 = t38.Load(int4(_2154, _2155, _2156, 0));
                            int _2160 = _2158.x & 511;
                            int _2161 = (uint)((uint)(_2158.x)) >> 9;
                            float4 _2164 = t34[0].Load(int3(_2160, _2161, 0));
                            uint _2166 = t38.Load(int4(_2154, _2155, _2156, 0));
                            int _2168 = _2166.x & 127;
                            int _2169 = (uint)((uint)(_2166.x)) >> 7;
                            int _2170 = _2169 & 127;
                            int _2171 = (uint)((uint)(_2166.x)) >> 14;
                            int _2172 = _2169 | _2166.x;
                            int _2173 = _2172 & 127;
                            int _2174 = _2173 | _2171;
                            bool _2175 = (_2174 == 0);
                            if (!_2175) {
                              float _2178 = _2164.z * 0.44999998807907104f;
                              float _2180 = _2164.y * 0.44999998807907104f;
                              float _2182 = _2164.x * 0.44999998807907104f;
                              float _2183 = float((int)(_2136));
                              float _2184 = float((int)(_2137));
                              float _2185 = float((int)(_2138));
                              float _2186 = _2119 - (gridDesc_000[0].PROBE_GRID_DESC_160.x);
                              float _2187 = _2186 + _2183;
                              float _2188 = _2187 + _2182;
                              float _2189 = _2188 * (gridDesc_000[0].PROBE_GRID_DESC_016.x);
                              float _2190 = (gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2098;
                              float _2191 = _2189 + _2190;
                              float _2192 = _2120 - (gridDesc_000[0].PROBE_GRID_DESC_160.y);
                              float _2193 = _2192 + _2184;
                              float _2194 = _2193 + _2180;
                              float _2195 = _2194 * (gridDesc_000[0].PROBE_GRID_DESC_016.y);
                              float _2196 = (gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2099;
                              float _2197 = _2195 + _2196;
                              float _2198 = _2121 - (gridDesc_000[0].PROBE_GRID_DESC_160.z);
                              float _2199 = _2198 + _2185;
                              float _2200 = _2199 + _2178;
                              float _2201 = _2200 * (gridDesc_000[0].PROBE_GRID_DESC_016.z);
                              float _2202 = (gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2100;
                              float _2203 = _2201 + _2202;
                              float _2204 = _2191 * _2191;
                              float _2205 = _2197 * _2197;
                              float _2206 = _2204 + _2205;
                              float _2207 = _2203 * _2203;
                              float _2208 = _2206 + _2207;
                              float _2209 = sqrt(_2208);
                              float _2210 = max(_2209, 9.999999747378752e-06f);
                              float _2211 = _2191 / _2210;
                              float _2212 = _2197 / _2210;
                              float _2213 = _2203 / _2210;
                              float _2214 = -0.0f - _2211;
                              float _2215 = -0.0f - _2212;
                              float _2216 = -0.0f - _2213;
                              float _2217 = abs(_2214);
                              float _2218 = abs(_2215);
                              float _2219 = _2218 + _2217;
                              float _2220 = abs(_2216);
                              float _2221 = _2219 + _2220;
                              float _2222 = _2214 / _2221;
                              float _2223 = _2215 / _2221;
                              float _2224 = _2216 / _2221;
                              bool _2225 = (_2224 > 0.0f);
                              if (!_2225) {
                                float _2227 = abs(_2223);
                                float _2228 = abs(_2222);
                                float _2229 = 1.0f - _2227;
                                float _2230 = 1.0f - _2228;
                                bool _2231 = (_2222 > 0.0f);
                                bool _2232 = (_2223 > 0.0f);
                                bool _2233 = (_2222 < 0.0f);
                                bool _2234 = (_2223 < 0.0f);
                                int _2235 = (int)(uint)(_2231);
                                int _2236 = (int)(uint)(_2232);
                                int _2237 = (int)(uint)(_2233);
                                int _2238 = (int)(uint)(_2234);
                                int _2239 = _2235 - _2237;
                                int _2240 = _2236 - _2238;
                                float _2241 = float((int)(_2239));
                                float _2242 = float((int)(_2240));
                                float _2243 = _2229 * _2241;
                                float _2244 = _2230 * _2242;
                                _2246 = _2243;
                                _2247 = _2244;
                              } else {
                                _2246 = _2222;
                                _2247 = _2223;
                              }
                              float _2248 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                              float _2249 = _2248 * 0.5f;
                              float _2250 = _2248 + 2.0f;
                              float _2251 = _2249 / _2250;
                              float _2252 = float((int)(_2168));
                              float _2253 = float((int)(_2170));
                              float _2254 = _2252 + 0.5f;
                              float _2255 = _2253 + 0.5f;
                              float _2256 = _2251 * _2246;
                              float _2257 = _2251 * _2247;
                              float _2258 = _2256 + _2254;
                              float _2259 = _2257 + _2255;
                              float _2260 = _2258 * 0.0078125f;
                              float _2261 = _2259 * 0.0078125f;
                              float _2262 = float((int)(_2171));
                              float3 _2266 = t30[0].SampleLevel(s7, float3(_2260, _2261, _2262), 0.0f);
                              float _2269 = abs(_70);
                              float _2270 = abs(_71);
                              float _2271 = _2270 + _2269;
                              float _2272 = abs(_72);
                              float _2273 = _2271 + _2272;
                              float _2274 = _70 / _2273;
                              float _2275 = _71 / _2273;
                              float _2276 = _72 / _2273;
                              bool _2277 = (_2276 > 0.0f);
                              if (!_2277) {
                                float _2279 = abs(_2275);
                                float _2280 = abs(_2274);
                                float _2281 = 1.0f - _2279;
                                float _2282 = 1.0f - _2280;
                                bool _2283 = (_2274 > 0.0f);
                                bool _2284 = (_2275 > 0.0f);
                                bool _2285 = (_2274 < 0.0f);
                                bool _2286 = (_2275 < 0.0f);
                                int _2287 = (int)(uint)(_2283);
                                int _2288 = (int)(uint)(_2284);
                                int _2289 = (int)(uint)(_2285);
                                int _2290 = (int)(uint)(_2286);
                                int _2291 = _2287 - _2289;
                                int _2292 = _2288 - _2290;
                                float _2293 = float((int)(_2291));
                                float _2294 = float((int)(_2292));
                                float _2295 = _2281 * _2293;
                                float _2296 = _2282 * _2294;
                                _2298 = _2295;
                                _2299 = _2296;
                              } else {
                                _2298 = _2274;
                                _2299 = _2275;
                              }
                              float _2300 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                              float _2301 = _2300 * 0.5f;
                              float _2302 = _2300 + 2.0f;
                              float _2303 = _2301 / _2302;
                              float _2304 = _2303 * _2298;
                              float _2305 = _2303 * _2299;
                              float _2306 = _2304 + _2254;
                              float _2307 = _2305 + _2255;
                              float _2308 = _2306 * 0.0078125f;
                              float _2309 = _2307 * 0.0078125f;
                              float4 _2313 = t28[0].SampleLevel(s7, float3(_2308, _2309, _2262), 0.0f);
                              float _2317 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                              float _2318 = log2(_2313.x);
                              float _2319 = log2(_2313.y);
                              float _2320 = log2(_2313.z);
                              float _2321 = _2318 * _2317;
                              float _2322 = _2319 * _2317;
                              float _2323 = _2320 * _2317;
                              float _2324 = exp2(_2321);
                              float _2325 = exp2(_2322);
                              float _2326 = exp2(_2323);
                              float _2327 = 1.0f - _2122;
                              float _2328 = 1.0f - _2123;
                              float _2329 = 1.0f - _2124;
                              bool _2330 = (_2136 != 0);
                              bool _2331 = (_2137 != 0);
                              bool _2332 = (_2138 != 0);
                              float _2333 = select(_2330, _2122, _2327);
                              float _2334 = select(_2331, _2123, _2328);
                              float _2335 = select(_2332, _2124, _2329);
                              float _2336 = _2334 * _2333;
                              float _2337 = _2336 * _2335;
                              float _2338 = _2337 + _2132;
                              bool _2339 = (_2209 > _2266.x);
                              if (_2339) {
                                float _2341 = _2266.x * _2266.x;
                                float _2342 = _2266.y - _2341;
                                float _2343 = abs(_2342);
                                float _2344 = _2209 - _2266.x;
                                float _2345 = _2344 * _2344;
                                float _2346 = _2343 + _2345;
                                float _2347 = _2343 / _2346;
                                float _2348 = _2347 * _2337;
                                _2350 = _2348;
                              } else {
                                _2350 = _2337;
                              }
                              float _2351 = dot(float3(_2211, _2212, _2213), float3(_70, _71, _72));
                              float _2352 = _2351 * 0.5f;
                              float _2353 = _2352 + 0.5f;
                              float _2354 = saturate(_2353);
                              float _2355 = _2354 * _2350;
                              float _2356 = _2355 * _2324;
                              float _2357 = _2355 * _2325;
                              float _2358 = _2355 * _2326;
                              float _2359 = _2356 + _2128;
                              float _2360 = _2357 + _2129;
                              float _2361 = _2358 + _2130;
                              float _2362 = _2355 + _2131;
                              _2364 = _2359;
                              _2365 = _2360;
                              _2366 = _2361;
                              _2367 = _2362;
                              _2368 = _2338;
                            } else {
                              _2364 = _2128;
                              _2365 = _2129;
                              _2366 = _2130;
                              _2367 = _2131;
                              _2368 = _2132;
                            }
                          } else {
                            _2364 = _2128;
                            _2365 = _2129;
                            _2366 = _2130;
                            _2367 = _2131;
                            _2368 = _2132;
                          }
                          int _2369 = _2133 + 1;
                          bool _2370 = (_2369 == 8);
                          if (!_2370) {
                            _2128 = _2364;
                            _2129 = _2365;
                            _2130 = _2366;
                            _2131 = _2367;
                            _2132 = _2368;
                            _2133 = _2369;
                            continue;
                          }
                          break;
                        }
                        while(true) {
                          bool _2126 = (_2367 > 9.999999747378752e-06f);
                          if (_2126) {
                            float _2372 = _2364 / _2367;
                            float _2373 = _2365 / _2367;
                            float _2374 = _2366 / _2367;
                            float _2375 = _2372 * _2372;
                            float _2376 = _2375 * 3.1415927410125732f;
                            float _2377 = _2373 * _2373;
                            float _2378 = _2377 * 3.1415927410125732f;
                            float _2379 = _2374 * _2374;
                            float _2380 = _2379 * 3.1415927410125732f;
                            _2394 = _2376;
                            _2395 = _2378;
                            _2396 = _2380;
                            _2397 = _2367;
                          } else {
                            bool _2382 = (_2368 > 9.999999747378752e-06f);
                            if (_2382) {
                              float _2384 = _2364 / _2368;
                              float _2385 = _2365 / _2368;
                              float _2386 = _2366 / _2368;
                              float _2387 = _2384 * _2384;
                              float _2388 = _2387 * 3.1415927410125732f;
                              float _2389 = _2385 * _2385;
                              float _2390 = _2389 * 3.1415927410125732f;
                              float _2391 = _2386 * _2386;
                              float _2392 = _2391 * 3.1415927410125732f;
                              _2394 = _2388;
                              _2395 = _2390;
                              _2396 = _2392;
                              _2397 = _2368;
                            } else {
                              _2394 = 0.0f;
                              _2395 = 0.0f;
                              _2396 = 0.0f;
                              _2397 = 0.0f;
                            }
                          }
                          bool _2398 = (_2397 < 9.999999747378752e-06f);
                          if (_2398) {
                            _2401 = _2047;
                            _2402 = _2048;
                            _2403 = _2049;
                            _2404 = _2051;
                            _2405 = _2052;
                            _2406 = 0.0f;
                            _2407 = 0;
                            _2408 = _2394;
                            _2409 = _2395;
                            _2410 = _2396;
                          } else {
                            _2401 = _2047;
                            _2402 = _2048;
                            _2403 = _2049;
                            _2404 = _2051;
                            _2405 = _2052;
                            _2406 = _1683;
                            _2407 = _2050;
                            _2408 = _2394;
                            _2409 = _2395;
                            _2410 = _2396;
                          }
                          break;
                        }
                      } else {
                        _2401 = _2042;
                        _2402 = _2043;
                        _2403 = _2044;
                        _2404 = _1699;
                        _2405 = _1698;
                        _2406 = _1683;
                        _2407 = 0;
                        _2408 = 0.0f;
                        _2409 = 0.0f;
                        _2410 = 0.0f;
                      }
                    } else {
                      _2047 = _2036;
                      _2048 = _2037;
                      _2049 = _2038;
                      _2050 = 1;
                      _2051 = 0;
                      _2052 = 0.0f;
                      float _2089 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _70;
                      float _2090 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _71;
                      float _2091 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _72;
                      float _2092 = _2089 + _157;
                      float _2093 = _2090 + _158;
                      float _2094 = _2091 + _159;
                      float _2095 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _696;
                      float _2096 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _697;
                      float _2097 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _698;
                      float _2098 = _2092 + _2095;
                      float _2099 = _2093 + _2096;
                      float _2100 = _2094 + _2097;
                      float _2101 = _2098 * (gridDesc_000[0].PROBE_GRID_DESC_176.x);
                      float _2102 = _2099 * (gridDesc_000[0].PROBE_GRID_DESC_176.y);
                      float _2103 = _2100 * (gridDesc_000[0].PROBE_GRID_DESC_176.z);
                      float _2104 = _2101 + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
                      float _2105 = _2102 + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
                      float _2106 = _2103 + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
                      int _2107 = int(_2104);
                      int _2108 = int(_2105);
                      int _2109 = int(_2106);
                      uint _2110 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u;
                      uint _2111 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u;
                      uint _2112 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u;
                      int _2113 = max(_2107, 0);
                      int _2114 = max(_2108, 0);
                      int _2115 = max(_2109, 0);
                      int _2116 = min(_2113, _2110);
                      int _2117 = min(_2114, _2111);
                      int _2118 = min(_2115, _2112);
                      float _2119 = float((int)(_2116));
                      float _2120 = float((int)(_2117));
                      float _2121 = float((int)(_2118));
                      float _2122 = _2104 - _2119;
                      float _2123 = _2105 - _2120;
                      float _2124 = _2106 - _2121;
                      _2128 = 0.0f;
                      _2129 = 0.0f;
                      _2130 = 0.0f;
                      _2131 = 0.0f;
                      _2132 = 0.0f;
                      _2133 = 0;
                      while(true) {
                        int _2134 = (uint)(_2133) >> 1;
                        int _2135 = (uint)(_2133) >> 2;
                        int _2136 = _2133 & 1;
                        int _2137 = _2134 & 1;
                        int _2138 = _2135 & 1;
                        uint _2139 = _2136 + _2116;
                        uint _2140 = _2137 + _2117;
                        uint _2141 = _2138 + _2118;
                        bool _2142 = ((int)_2139 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x));
                        bool _2143 = ((int)_2140 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y));
                        bool _2144 = ((int)_2141 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z));
                        bool _2145 = _2142 || _2143;
                        bool _2146 = _2144 || _2145;
                        if (!_2146) {
                          uint _2148 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x));
                          uint _2149 = _2148 + _2139;
                          uint _2150 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y));
                          uint _2151 = _2150 + _2140;
                          uint _2152 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z));
                          uint _2153 = _2152 + _2141;
                          int _2154 = _2149 % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
                          int _2155 = _2151 % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
                          int _2156 = _2153 % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
                          uint _2158 = t38.Load(int4(_2154, _2155, _2156, 0));
                          int _2160 = _2158.x & 511;
                          int _2161 = (uint)((uint)(_2158.x)) >> 9;
                          float4 _2164 = t34[0].Load(int3(_2160, _2161, 0));
                          uint _2166 = t38.Load(int4(_2154, _2155, _2156, 0));
                          int _2168 = _2166.x & 127;
                          int _2169 = (uint)((uint)(_2166.x)) >> 7;
                          int _2170 = _2169 & 127;
                          int _2171 = (uint)((uint)(_2166.x)) >> 14;
                          int _2172 = _2169 | _2166.x;
                          int _2173 = _2172 & 127;
                          int _2174 = _2173 | _2171;
                          bool _2175 = (_2174 == 0);
                          if (!_2175) {
                            float _2178 = _2164.z * 0.44999998807907104f;
                            float _2180 = _2164.y * 0.44999998807907104f;
                            float _2182 = _2164.x * 0.44999998807907104f;
                            float _2183 = float((int)(_2136));
                            float _2184 = float((int)(_2137));
                            float _2185 = float((int)(_2138));
                            float _2186 = _2119 - (gridDesc_000[0].PROBE_GRID_DESC_160.x);
                            float _2187 = _2186 + _2183;
                            float _2188 = _2187 + _2182;
                            float _2189 = _2188 * (gridDesc_000[0].PROBE_GRID_DESC_016.x);
                            float _2190 = (gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2098;
                            float _2191 = _2189 + _2190;
                            float _2192 = _2120 - (gridDesc_000[0].PROBE_GRID_DESC_160.y);
                            float _2193 = _2192 + _2184;
                            float _2194 = _2193 + _2180;
                            float _2195 = _2194 * (gridDesc_000[0].PROBE_GRID_DESC_016.y);
                            float _2196 = (gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2099;
                            float _2197 = _2195 + _2196;
                            float _2198 = _2121 - (gridDesc_000[0].PROBE_GRID_DESC_160.z);
                            float _2199 = _2198 + _2185;
                            float _2200 = _2199 + _2178;
                            float _2201 = _2200 * (gridDesc_000[0].PROBE_GRID_DESC_016.z);
                            float _2202 = (gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2100;
                            float _2203 = _2201 + _2202;
                            float _2204 = _2191 * _2191;
                            float _2205 = _2197 * _2197;
                            float _2206 = _2204 + _2205;
                            float _2207 = _2203 * _2203;
                            float _2208 = _2206 + _2207;
                            float _2209 = sqrt(_2208);
                            float _2210 = max(_2209, 9.999999747378752e-06f);
                            float _2211 = _2191 / _2210;
                            float _2212 = _2197 / _2210;
                            float _2213 = _2203 / _2210;
                            float _2214 = -0.0f - _2211;
                            float _2215 = -0.0f - _2212;
                            float _2216 = -0.0f - _2213;
                            float _2217 = abs(_2214);
                            float _2218 = abs(_2215);
                            float _2219 = _2218 + _2217;
                            float _2220 = abs(_2216);
                            float _2221 = _2219 + _2220;
                            float _2222 = _2214 / _2221;
                            float _2223 = _2215 / _2221;
                            float _2224 = _2216 / _2221;
                            bool _2225 = (_2224 > 0.0f);
                            if (!_2225) {
                              float _2227 = abs(_2223);
                              float _2228 = abs(_2222);
                              float _2229 = 1.0f - _2227;
                              float _2230 = 1.0f - _2228;
                              bool _2231 = (_2222 > 0.0f);
                              bool _2232 = (_2223 > 0.0f);
                              bool _2233 = (_2222 < 0.0f);
                              bool _2234 = (_2223 < 0.0f);
                              int _2235 = (int)(uint)(_2231);
                              int _2236 = (int)(uint)(_2232);
                              int _2237 = (int)(uint)(_2233);
                              int _2238 = (int)(uint)(_2234);
                              int _2239 = _2235 - _2237;
                              int _2240 = _2236 - _2238;
                              float _2241 = float((int)(_2239));
                              float _2242 = float((int)(_2240));
                              float _2243 = _2229 * _2241;
                              float _2244 = _2230 * _2242;
                              _2246 = _2243;
                              _2247 = _2244;
                            } else {
                              _2246 = _2222;
                              _2247 = _2223;
                            }
                            float _2248 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                            float _2249 = _2248 * 0.5f;
                            float _2250 = _2248 + 2.0f;
                            float _2251 = _2249 / _2250;
                            float _2252 = float((int)(_2168));
                            float _2253 = float((int)(_2170));
                            float _2254 = _2252 + 0.5f;
                            float _2255 = _2253 + 0.5f;
                            float _2256 = _2251 * _2246;
                            float _2257 = _2251 * _2247;
                            float _2258 = _2256 + _2254;
                            float _2259 = _2257 + _2255;
                            float _2260 = _2258 * 0.0078125f;
                            float _2261 = _2259 * 0.0078125f;
                            float _2262 = float((int)(_2171));
                            float3 _2266 = t30[0].SampleLevel(s7, float3(_2260, _2261, _2262), 0.0f);
                            float _2269 = abs(_70);
                            float _2270 = abs(_71);
                            float _2271 = _2270 + _2269;
                            float _2272 = abs(_72);
                            float _2273 = _2271 + _2272;
                            float _2274 = _70 / _2273;
                            float _2275 = _71 / _2273;
                            float _2276 = _72 / _2273;
                            bool _2277 = (_2276 > 0.0f);
                            if (!_2277) {
                              float _2279 = abs(_2275);
                              float _2280 = abs(_2274);
                              float _2281 = 1.0f - _2279;
                              float _2282 = 1.0f - _2280;
                              bool _2283 = (_2274 > 0.0f);
                              bool _2284 = (_2275 > 0.0f);
                              bool _2285 = (_2274 < 0.0f);
                              bool _2286 = (_2275 < 0.0f);
                              int _2287 = (int)(uint)(_2283);
                              int _2288 = (int)(uint)(_2284);
                              int _2289 = (int)(uint)(_2285);
                              int _2290 = (int)(uint)(_2286);
                              int _2291 = _2287 - _2289;
                              int _2292 = _2288 - _2290;
                              float _2293 = float((int)(_2291));
                              float _2294 = float((int)(_2292));
                              float _2295 = _2281 * _2293;
                              float _2296 = _2282 * _2294;
                              _2298 = _2295;
                              _2299 = _2296;
                            } else {
                              _2298 = _2274;
                              _2299 = _2275;
                            }
                            float _2300 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                            float _2301 = _2300 * 0.5f;
                            float _2302 = _2300 + 2.0f;
                            float _2303 = _2301 / _2302;
                            float _2304 = _2303 * _2298;
                            float _2305 = _2303 * _2299;
                            float _2306 = _2304 + _2254;
                            float _2307 = _2305 + _2255;
                            float _2308 = _2306 * 0.0078125f;
                            float _2309 = _2307 * 0.0078125f;
                            float4 _2313 = t28[0].SampleLevel(s7, float3(_2308, _2309, _2262), 0.0f);
                            float _2317 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                            float _2318 = log2(_2313.x);
                            float _2319 = log2(_2313.y);
                            float _2320 = log2(_2313.z);
                            float _2321 = _2318 * _2317;
                            float _2322 = _2319 * _2317;
                            float _2323 = _2320 * _2317;
                            float _2324 = exp2(_2321);
                            float _2325 = exp2(_2322);
                            float _2326 = exp2(_2323);
                            float _2327 = 1.0f - _2122;
                            float _2328 = 1.0f - _2123;
                            float _2329 = 1.0f - _2124;
                            bool _2330 = (_2136 != 0);
                            bool _2331 = (_2137 != 0);
                            bool _2332 = (_2138 != 0);
                            float _2333 = select(_2330, _2122, _2327);
                            float _2334 = select(_2331, _2123, _2328);
                            float _2335 = select(_2332, _2124, _2329);
                            float _2336 = _2334 * _2333;
                            float _2337 = _2336 * _2335;
                            float _2338 = _2337 + _2132;
                            bool _2339 = (_2209 > _2266.x);
                            if (_2339) {
                              float _2341 = _2266.x * _2266.x;
                              float _2342 = _2266.y - _2341;
                              float _2343 = abs(_2342);
                              float _2344 = _2209 - _2266.x;
                              float _2345 = _2344 * _2344;
                              float _2346 = _2343 + _2345;
                              float _2347 = _2343 / _2346;
                              float _2348 = _2347 * _2337;
                              _2350 = _2348;
                            } else {
                              _2350 = _2337;
                            }
                            float _2351 = dot(float3(_2211, _2212, _2213), float3(_70, _71, _72));
                            float _2352 = _2351 * 0.5f;
                            float _2353 = _2352 + 0.5f;
                            float _2354 = saturate(_2353);
                            float _2355 = _2354 * _2350;
                            float _2356 = _2355 * _2324;
                            float _2357 = _2355 * _2325;
                            float _2358 = _2355 * _2326;
                            float _2359 = _2356 + _2128;
                            float _2360 = _2357 + _2129;
                            float _2361 = _2358 + _2130;
                            float _2362 = _2355 + _2131;
                            _2364 = _2359;
                            _2365 = _2360;
                            _2366 = _2361;
                            _2367 = _2362;
                            _2368 = _2338;
                          } else {
                            _2364 = _2128;
                            _2365 = _2129;
                            _2366 = _2130;
                            _2367 = _2131;
                            _2368 = _2132;
                          }
                        } else {
                          _2364 = _2128;
                          _2365 = _2129;
                          _2366 = _2130;
                          _2367 = _2131;
                          _2368 = _2132;
                        }
                        int _2369 = _2133 + 1;
                        bool _2370 = (_2369 == 8);
                        if (!_2370) {
                          _2128 = _2364;
                          _2129 = _2365;
                          _2130 = _2366;
                          _2131 = _2367;
                          _2132 = _2368;
                          _2133 = _2369;
                          continue;
                        }
                        break;
                      }
                      while(true) {
                        bool _2126 = (_2367 > 9.999999747378752e-06f);
                        if (_2126) {
                          float _2372 = _2364 / _2367;
                          float _2373 = _2365 / _2367;
                          float _2374 = _2366 / _2367;
                          float _2375 = _2372 * _2372;
                          float _2376 = _2375 * 3.1415927410125732f;
                          float _2377 = _2373 * _2373;
                          float _2378 = _2377 * 3.1415927410125732f;
                          float _2379 = _2374 * _2374;
                          float _2380 = _2379 * 3.1415927410125732f;
                          _2394 = _2376;
                          _2395 = _2378;
                          _2396 = _2380;
                          _2397 = _2367;
                        } else {
                          bool _2382 = (_2368 > 9.999999747378752e-06f);
                          if (_2382) {
                            float _2384 = _2364 / _2368;
                            float _2385 = _2365 / _2368;
                            float _2386 = _2366 / _2368;
                            float _2387 = _2384 * _2384;
                            float _2388 = _2387 * 3.1415927410125732f;
                            float _2389 = _2385 * _2385;
                            float _2390 = _2389 * 3.1415927410125732f;
                            float _2391 = _2386 * _2386;
                            float _2392 = _2391 * 3.1415927410125732f;
                            _2394 = _2388;
                            _2395 = _2390;
                            _2396 = _2392;
                            _2397 = _2368;
                          } else {
                            _2394 = 0.0f;
                            _2395 = 0.0f;
                            _2396 = 0.0f;
                            _2397 = 0.0f;
                          }
                        }
                        bool _2398 = (_2397 < 9.999999747378752e-06f);
                        if (_2398) {
                          _2401 = _2047;
                          _2402 = _2048;
                          _2403 = _2049;
                          _2404 = _2051;
                          _2405 = _2052;
                          _2406 = 0.0f;
                          _2407 = 0;
                          _2408 = _2394;
                          _2409 = _2395;
                          _2410 = _2396;
                        } else {
                          _2401 = _2047;
                          _2402 = _2048;
                          _2403 = _2049;
                          _2404 = _2051;
                          _2405 = _2052;
                          _2406 = _1683;
                          _2407 = _2050;
                          _2408 = _2394;
                          _2409 = _2395;
                          _2410 = _2396;
                        }
                        break;
                      }
                    }
                    break;
                  }
                } else {
                  _2042 = 0.0f;
                  _2043 = 0.0f;
                  _2044 = 0.0f;
                  bool _2045 = (_1700 == 0);
                  if (!_2045) {
                    _2047 = _2042;
                    _2048 = _2043;
                    _2049 = _2044;
                    _2050 = _1700;
                    _2051 = _1699;
                    _2052 = _1698;
                    float _2089 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _70;
                    float _2090 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _71;
                    float _2091 = (gridDesc_000[0].PROBE_GRID_DESC_152) * _72;
                    float _2092 = _2089 + _157;
                    float _2093 = _2090 + _158;
                    float _2094 = _2091 + _159;
                    float _2095 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _696;
                    float _2096 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _697;
                    float _2097 = (gridDesc_000[0].PROBE_GRID_DESC_156) * _698;
                    float _2098 = _2092 + _2095;
                    float _2099 = _2093 + _2096;
                    float _2100 = _2094 + _2097;
                    float _2101 = _2098 * (gridDesc_000[0].PROBE_GRID_DESC_176.x);
                    float _2102 = _2099 * (gridDesc_000[0].PROBE_GRID_DESC_176.y);
                    float _2103 = _2100 * (gridDesc_000[0].PROBE_GRID_DESC_176.z);
                    float _2104 = _2101 + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
                    float _2105 = _2102 + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
                    float _2106 = _2103 + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
                    int _2107 = int(_2104);
                    int _2108 = int(_2105);
                    int _2109 = int(_2106);
                    uint _2110 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u;
                    uint _2111 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u;
                    uint _2112 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u;
                    int _2113 = max(_2107, 0);
                    int _2114 = max(_2108, 0);
                    int _2115 = max(_2109, 0);
                    int _2116 = min(_2113, _2110);
                    int _2117 = min(_2114, _2111);
                    int _2118 = min(_2115, _2112);
                    float _2119 = float((int)(_2116));
                    float _2120 = float((int)(_2117));
                    float _2121 = float((int)(_2118));
                    float _2122 = _2104 - _2119;
                    float _2123 = _2105 - _2120;
                    float _2124 = _2106 - _2121;
                    _2128 = 0.0f;
                    _2129 = 0.0f;
                    _2130 = 0.0f;
                    _2131 = 0.0f;
                    _2132 = 0.0f;
                    _2133 = 0;
                    while(true) {
                      int _2134 = (uint)(_2133) >> 1;
                      int _2135 = (uint)(_2133) >> 2;
                      int _2136 = _2133 & 1;
                      int _2137 = _2134 & 1;
                      int _2138 = _2135 & 1;
                      uint _2139 = _2136 + _2116;
                      uint _2140 = _2137 + _2117;
                      uint _2141 = _2138 + _2118;
                      bool _2142 = ((int)_2139 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x));
                      bool _2143 = ((int)_2140 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y));
                      bool _2144 = ((int)_2141 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z));
                      bool _2145 = _2142 || _2143;
                      bool _2146 = _2144 || _2145;
                      if (!_2146) {
                        uint _2148 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x));
                        uint _2149 = _2148 + _2139;
                        uint _2150 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y));
                        uint _2151 = _2150 + _2140;
                        uint _2152 = ((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z));
                        uint _2153 = _2152 + _2141;
                        int _2154 = _2149 % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
                        int _2155 = _2151 % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
                        int _2156 = _2153 % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
                        uint _2158 = t38.Load(int4(_2154, _2155, _2156, 0));
                        int _2160 = _2158.x & 511;
                        int _2161 = (uint)((uint)(_2158.x)) >> 9;
                        float4 _2164 = t34[0].Load(int3(_2160, _2161, 0));
                        uint _2166 = t38.Load(int4(_2154, _2155, _2156, 0));
                        int _2168 = _2166.x & 127;
                        int _2169 = (uint)((uint)(_2166.x)) >> 7;
                        int _2170 = _2169 & 127;
                        int _2171 = (uint)((uint)(_2166.x)) >> 14;
                        int _2172 = _2169 | _2166.x;
                        int _2173 = _2172 & 127;
                        int _2174 = _2173 | _2171;
                        bool _2175 = (_2174 == 0);
                        if (!_2175) {
                          float _2178 = _2164.z * 0.44999998807907104f;
                          float _2180 = _2164.y * 0.44999998807907104f;
                          float _2182 = _2164.x * 0.44999998807907104f;
                          float _2183 = float((int)(_2136));
                          float _2184 = float((int)(_2137));
                          float _2185 = float((int)(_2138));
                          float _2186 = _2119 - (gridDesc_000[0].PROBE_GRID_DESC_160.x);
                          float _2187 = _2186 + _2183;
                          float _2188 = _2187 + _2182;
                          float _2189 = _2188 * (gridDesc_000[0].PROBE_GRID_DESC_016.x);
                          float _2190 = (gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2098;
                          float _2191 = _2189 + _2190;
                          float _2192 = _2120 - (gridDesc_000[0].PROBE_GRID_DESC_160.y);
                          float _2193 = _2192 + _2184;
                          float _2194 = _2193 + _2180;
                          float _2195 = _2194 * (gridDesc_000[0].PROBE_GRID_DESC_016.y);
                          float _2196 = (gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2099;
                          float _2197 = _2195 + _2196;
                          float _2198 = _2121 - (gridDesc_000[0].PROBE_GRID_DESC_160.z);
                          float _2199 = _2198 + _2185;
                          float _2200 = _2199 + _2178;
                          float _2201 = _2200 * (gridDesc_000[0].PROBE_GRID_DESC_016.z);
                          float _2202 = (gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2100;
                          float _2203 = _2201 + _2202;
                          float _2204 = _2191 * _2191;
                          float _2205 = _2197 * _2197;
                          float _2206 = _2204 + _2205;
                          float _2207 = _2203 * _2203;
                          float _2208 = _2206 + _2207;
                          float _2209 = sqrt(_2208);
                          float _2210 = max(_2209, 9.999999747378752e-06f);
                          float _2211 = _2191 / _2210;
                          float _2212 = _2197 / _2210;
                          float _2213 = _2203 / _2210;
                          float _2214 = -0.0f - _2211;
                          float _2215 = -0.0f - _2212;
                          float _2216 = -0.0f - _2213;
                          float _2217 = abs(_2214);
                          float _2218 = abs(_2215);
                          float _2219 = _2218 + _2217;
                          float _2220 = abs(_2216);
                          float _2221 = _2219 + _2220;
                          float _2222 = _2214 / _2221;
                          float _2223 = _2215 / _2221;
                          float _2224 = _2216 / _2221;
                          bool _2225 = (_2224 > 0.0f);
                          if (!_2225) {
                            float _2227 = abs(_2223);
                            float _2228 = abs(_2222);
                            float _2229 = 1.0f - _2227;
                            float _2230 = 1.0f - _2228;
                            bool _2231 = (_2222 > 0.0f);
                            bool _2232 = (_2223 > 0.0f);
                            bool _2233 = (_2222 < 0.0f);
                            bool _2234 = (_2223 < 0.0f);
                            int _2235 = (int)(uint)(_2231);
                            int _2236 = (int)(uint)(_2232);
                            int _2237 = (int)(uint)(_2233);
                            int _2238 = (int)(uint)(_2234);
                            int _2239 = _2235 - _2237;
                            int _2240 = _2236 - _2238;
                            float _2241 = float((int)(_2239));
                            float _2242 = float((int)(_2240));
                            float _2243 = _2229 * _2241;
                            float _2244 = _2230 * _2242;
                            _2246 = _2243;
                            _2247 = _2244;
                          } else {
                            _2246 = _2222;
                            _2247 = _2223;
                          }
                          float _2248 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                          float _2249 = _2248 * 0.5f;
                          float _2250 = _2248 + 2.0f;
                          float _2251 = _2249 / _2250;
                          float _2252 = float((int)(_2168));
                          float _2253 = float((int)(_2170));
                          float _2254 = _2252 + 0.5f;
                          float _2255 = _2253 + 0.5f;
                          float _2256 = _2251 * _2246;
                          float _2257 = _2251 * _2247;
                          float _2258 = _2256 + _2254;
                          float _2259 = _2257 + _2255;
                          float _2260 = _2258 * 0.0078125f;
                          float _2261 = _2259 * 0.0078125f;
                          float _2262 = float((int)(_2171));
                          float3 _2266 = t30[0].SampleLevel(s7, float3(_2260, _2261, _2262), 0.0f);
                          float _2269 = abs(_70);
                          float _2270 = abs(_71);
                          float _2271 = _2270 + _2269;
                          float _2272 = abs(_72);
                          float _2273 = _2271 + _2272;
                          float _2274 = _70 / _2273;
                          float _2275 = _71 / _2273;
                          float _2276 = _72 / _2273;
                          bool _2277 = (_2276 > 0.0f);
                          if (!_2277) {
                            float _2279 = abs(_2275);
                            float _2280 = abs(_2274);
                            float _2281 = 1.0f - _2279;
                            float _2282 = 1.0f - _2280;
                            bool _2283 = (_2274 > 0.0f);
                            bool _2284 = (_2275 > 0.0f);
                            bool _2285 = (_2274 < 0.0f);
                            bool _2286 = (_2275 < 0.0f);
                            int _2287 = (int)(uint)(_2283);
                            int _2288 = (int)(uint)(_2284);
                            int _2289 = (int)(uint)(_2285);
                            int _2290 = (int)(uint)(_2286);
                            int _2291 = _2287 - _2289;
                            int _2292 = _2288 - _2290;
                            float _2293 = float((int)(_2291));
                            float _2294 = float((int)(_2292));
                            float _2295 = _2281 * _2293;
                            float _2296 = _2282 * _2294;
                            _2298 = _2295;
                            _2299 = _2296;
                          } else {
                            _2298 = _2274;
                            _2299 = _2275;
                          }
                          float _2300 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                          float _2301 = _2300 * 0.5f;
                          float _2302 = _2300 + 2.0f;
                          float _2303 = _2301 / _2302;
                          float _2304 = _2303 * _2298;
                          float _2305 = _2303 * _2299;
                          float _2306 = _2304 + _2254;
                          float _2307 = _2305 + _2255;
                          float _2308 = _2306 * 0.0078125f;
                          float _2309 = _2307 * 0.0078125f;
                          float4 _2313 = t28[0].SampleLevel(s7, float3(_2308, _2309, _2262), 0.0f);
                          float _2317 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                          float _2318 = log2(_2313.x);
                          float _2319 = log2(_2313.y);
                          float _2320 = log2(_2313.z);
                          float _2321 = _2318 * _2317;
                          float _2322 = _2319 * _2317;
                          float _2323 = _2320 * _2317;
                          float _2324 = exp2(_2321);
                          float _2325 = exp2(_2322);
                          float _2326 = exp2(_2323);
                          float _2327 = 1.0f - _2122;
                          float _2328 = 1.0f - _2123;
                          float _2329 = 1.0f - _2124;
                          bool _2330 = (_2136 != 0);
                          bool _2331 = (_2137 != 0);
                          bool _2332 = (_2138 != 0);
                          float _2333 = select(_2330, _2122, _2327);
                          float _2334 = select(_2331, _2123, _2328);
                          float _2335 = select(_2332, _2124, _2329);
                          float _2336 = _2334 * _2333;
                          float _2337 = _2336 * _2335;
                          float _2338 = _2337 + _2132;
                          bool _2339 = (_2209 > _2266.x);
                          if (_2339) {
                            float _2341 = _2266.x * _2266.x;
                            float _2342 = _2266.y - _2341;
                            float _2343 = abs(_2342);
                            float _2344 = _2209 - _2266.x;
                            float _2345 = _2344 * _2344;
                            float _2346 = _2343 + _2345;
                            float _2347 = _2343 / _2346;
                            float _2348 = _2347 * _2337;
                            _2350 = _2348;
                          } else {
                            _2350 = _2337;
                          }
                          float _2351 = dot(float3(_2211, _2212, _2213), float3(_70, _71, _72));
                          float _2352 = _2351 * 0.5f;
                          float _2353 = _2352 + 0.5f;
                          float _2354 = saturate(_2353);
                          float _2355 = _2354 * _2350;
                          float _2356 = _2355 * _2324;
                          float _2357 = _2355 * _2325;
                          float _2358 = _2355 * _2326;
                          float _2359 = _2356 + _2128;
                          float _2360 = _2357 + _2129;
                          float _2361 = _2358 + _2130;
                          float _2362 = _2355 + _2131;
                          _2364 = _2359;
                          _2365 = _2360;
                          _2366 = _2361;
                          _2367 = _2362;
                          _2368 = _2338;
                        } else {
                          _2364 = _2128;
                          _2365 = _2129;
                          _2366 = _2130;
                          _2367 = _2131;
                          _2368 = _2132;
                        }
                      } else {
                        _2364 = _2128;
                        _2365 = _2129;
                        _2366 = _2130;
                        _2367 = _2131;
                        _2368 = _2132;
                      }
                      int _2369 = _2133 + 1;
                      bool _2370 = (_2369 == 8);
                      if (!_2370) {
                        _2128 = _2364;
                        _2129 = _2365;
                        _2130 = _2366;
                        _2131 = _2367;
                        _2132 = _2368;
                        _2133 = _2369;
                        continue;
                      }
                      break;
                    }
                    while(true) {
                      bool _2126 = (_2367 > 9.999999747378752e-06f);
                      if (_2126) {
                        float _2372 = _2364 / _2367;
                        float _2373 = _2365 / _2367;
                        float _2374 = _2366 / _2367;
                        float _2375 = _2372 * _2372;
                        float _2376 = _2375 * 3.1415927410125732f;
                        float _2377 = _2373 * _2373;
                        float _2378 = _2377 * 3.1415927410125732f;
                        float _2379 = _2374 * _2374;
                        float _2380 = _2379 * 3.1415927410125732f;
                        _2394 = _2376;
                        _2395 = _2378;
                        _2396 = _2380;
                        _2397 = _2367;
                      } else {
                        bool _2382 = (_2368 > 9.999999747378752e-06f);
                        if (_2382) {
                          float _2384 = _2364 / _2368;
                          float _2385 = _2365 / _2368;
                          float _2386 = _2366 / _2368;
                          float _2387 = _2384 * _2384;
                          float _2388 = _2387 * 3.1415927410125732f;
                          float _2389 = _2385 * _2385;
                          float _2390 = _2389 * 3.1415927410125732f;
                          float _2391 = _2386 * _2386;
                          float _2392 = _2391 * 3.1415927410125732f;
                          _2394 = _2388;
                          _2395 = _2390;
                          _2396 = _2392;
                          _2397 = _2368;
                        } else {
                          _2394 = 0.0f;
                          _2395 = 0.0f;
                          _2396 = 0.0f;
                          _2397 = 0.0f;
                        }
                      }
                      bool _2398 = (_2397 < 9.999999747378752e-06f);
                      if (_2398) {
                        _2401 = _2047;
                        _2402 = _2048;
                        _2403 = _2049;
                        _2404 = _2051;
                        _2405 = _2052;
                        _2406 = 0.0f;
                        _2407 = 0;
                        _2408 = _2394;
                        _2409 = _2395;
                        _2410 = _2396;
                      } else {
                        _2401 = _2047;
                        _2402 = _2048;
                        _2403 = _2049;
                        _2404 = _2051;
                        _2405 = _2052;
                        _2406 = _1683;
                        _2407 = _2050;
                        _2408 = _2394;
                        _2409 = _2395;
                        _2410 = _2396;
                      }
                      break;
                    }
                  } else {
                    _2401 = _2042;
                    _2402 = _2043;
                    _2403 = _2044;
                    _2404 = _1699;
                    _2405 = _1698;
                    _2406 = _1683;
                    _2407 = 0;
                    _2408 = 0.0f;
                    _2409 = 0.0f;
                    _2410 = 0.0f;
                  }
                }
                bool _2413 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
                float _2414 = select(_2413, 1.0f, _2401);
                float _2415 = select(_2413, 0.0f, _2402);
                float _2416 = select(_2413, 0.0f, _2403);
                float _2417 = select(_2413, 0.0f, _2408);
                float _2418 = select(_2413, 0.0f, _2409);
                float _2419 = select(_2413, 1.0f, _2410);
                int _2420 = _2407 | _2404;
                bool _2421 = (_2420 == 0);
                bool _2422 = (_2406 < 1.0f);
                bool _2423 = _2422 || _2421;
                if (_2423) {
                  float _2427 = abs(_70);
                  float _2428 = abs(_71);
                  float _2429 = _2428 + _2427;
                  float _2430 = abs(_72);
                  float _2431 = _2429 + _2430;
                  float _2432 = _70 / _2431;
                  float _2433 = _71 / _2431;
                  float _2434 = _72 / _2431;
                  bool _2435 = (_2434 > 0.0f);
                  if (!_2435) {
                    float _2437 = abs(_2433);
                    float _2438 = abs(_2432);
                    float _2439 = 1.0f - _2437;
                    float _2440 = 1.0f - _2438;
                    bool _2441 = (_2432 > 0.0f);
                    bool _2442 = (_2433 > 0.0f);
                    bool _2443 = (_2432 < 0.0f);
                    bool _2444 = (_2433 < 0.0f);
                    int _2445 = (int)(uint)(_2441);
                    int _2446 = (int)(uint)(_2442);
                    int _2447 = (int)(uint)(_2443);
                    int _2448 = (int)(uint)(_2444);
                    int _2449 = _2445 - _2447;
                    int _2450 = _2446 - _2448;
                    float _2451 = float((int)(_2449));
                    float _2452 = float((int)(_2450));
                    float _2453 = _2439 * _2451;
                    float _2454 = _2440 * _2452;
                    _2456 = _2453;
                    _2457 = _2454;
                  } else {
                    _2456 = _2432;
                    _2457 = _2433;
                  }
                  float _2458 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                  float _2459 = _2458 * 0.5f;
                  float _2460 = _2458 + 2.0f;
                  float _2461 = _2459 / _2460;
                  float _2462 = _2461 * _2456;
                  float _2463 = _2461 * _2457;
                  float _2464 = _2462 + 0.5f;
                  float _2465 = _2463 + 0.5f;
                  float _2466 = _2464 * 0.0078125f;
                  float _2467 = _2465 * 0.0078125f;
                  float4 _2471 = t28[0].SampleLevel(s7, float3(_2466, _2467, 0.0f), 0.0f);
                  float _2475 = _2471.x * 3.1415927410125732f;
                  float _2476 = _2471.y * 3.1415927410125732f;
                  float _2477 = _2471.z * 3.1415927410125732f;
                  bool _2480 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
                  float _2481 = select(_2480, 0.0f, _2475);
                  float _2482 = select(_2480, 1.0f, _2476);
                  float _2483 = select(_2480, 0.0f, _2477);
                  float _2484 = _2417 - _2481;
                  float _2485 = _2418 - _2482;
                  float _2486 = _2419 - _2483;
                  float _2487 = _2484 * _2406;
                  float _2488 = _2485 * _2406;
                  float _2489 = _2486 * _2406;
                  float _2490 = _2487 + _2481;
                  float _2491 = _2488 + _2482;
                  float _2492 = _2489 + _2483;
                  bool _2493 = (_2420 != 0);
                  float _2494 = select(_2493, _2405, 0.0f);
                  _2496 = _2494;
                  _2497 = _2490;
                  _2498 = _2491;
                  _2499 = _2492;
                } else {
                  _2496 = _2405;
                  _2497 = _2417;
                  _2498 = _2418;
                  _2499 = _2419;
                }
                float _2500 = _2414 - _2497;
                float _2501 = _2415 - _2498;
                float _2502 = _2416 - _2499;
                float _2503 = _2500 * _2496;
                float _2504 = _2501 * _2496;
                float _2505 = _2502 * _2496;
                float _2506 = _2503 + _2497;
                float _2507 = _2504 + _2498;
                float _2508 = _2505 + _2499;
                bool _2509 = isnan(_2506);
                bool _2510 = isnan(_2507);
                bool _2511 = isnan(_2508);
                bool _2512 = _2509 || _2510;
                bool _2513 = _2512 || _2511;
                float _2514 = select(_2513, 0.0f, _2506);
                float _2515 = select(_2513, 0.0f, _2507);
                float _2516 = select(_2513, 0.0f, _2508);
                _2518 = _2514;
                _2519 = _2515;
                _2520 = _2516;
              } else {
                _2518 = 0.0f;
                _2519 = 0.0f;
                _2520 = 0.0f;
              }
            } else {
              _2518 = 0.0f;
              _2519 = 0.0f;
              _2520 = 0.0f;
            }
            int _2523 = CustomConstants_128 & 4;
            bool _2524 = (_2523 == 0);
            if (!_2524) {
              float _2530 = dot(float3(_70, _71, _72), float3(cb13_000x, cb13_000y, cb13_000z));
              // GRAPHICS WATER BEGIN
              GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
                  float3(_157, _158, _159), float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
              if (any(water_light.sun != float3(cb13_000x, cb13_000y, cb13_000z)))
                _2530 = dot(float3(_70, _71, _72), water_light.sun);
              // GRAPHICS WATER END
              float _2531 = saturate(_2530);
              bool _2532 = (_2531 > 0.0f);
              if (_2532) {
                float _2537 = _157 - cb12_000x;
                float _2538 = _158 - cb12_000y;
                float _2539 = _2537 * _2537;
                float _2540 = _2538 * _2538;
                float _2541 = _2539 + _2540;
                float _2542 = sqrt(_2541);
                bool _2545 = (_2542 < cb13_035x);
                [branch]
                if (_2545) {
                  bool _2549 = (cb13_034x == 0);
                  if (!_2549) {
                    _2552 = 0;
                    while(true) {
                      uint _2553 = _2552 + 37u;
                      float _2557 = _157 - (cb13_raw[_2553].x);
                      float _2558 = _158 - (cb13_raw[_2553].y);
                      uint _2559 = _2552 + 42u;
                      float _2563 = dot(float2(_2557, _2558), float2((cb13_raw[_2559].x), (cb13_raw[_2559].y)));
                      float _2566 = dot(float2(_2557, _2558), float2((cb13_raw[_2559].z), (cb13_raw[_2559].w)));
                      bool _2567 = (_2563 > 0.0f);
                      bool _2568 = (_2566 > 0.0f);
                      bool _2569 = _2567 && _2568;
                      if (_2569) {
                        bool _2571 = (_2563 < 1.0f);
                        bool _2572 = (_2566 < 1.0f);
                        bool _2573 = _2571 && _2572;
                        if (!_2573) {
                          int _2575 = _2552 + 1;
                          bool _2578 = ((uint)_2575 < (uint)cb13_034x);
                          if (_2578) {
                            _2552 = _2575;
                            continue;
                          } else {
                            _2613 = 1.0f;
                          }
                        } else {
                          bool _2580 = ((int)_2552 > (int)-1);
                          if (_2580) {
                            float _2585 = cb13_034w * _2542;
                            float _2586 = max(1.0f, _2585);
                            float _2587 = cb13_034z / _2586;
                            float _2588 = min(1.0f, _2587);
                            float _2592 = float((int)(_2552));
                            float _2595 = t19.SampleLevel(s10, float3(_2563, _2566, _2592), 0.0f);
                            float _2597 = _2595.x * cb13_035w;
                            float _2598 = -0.10000000149011612f - _159;
                            float _2599 = _2598 + cb13_036x;
                            float _2600 = _2599 + _2597;
                            float _2601 = _2600 * _2588;
                            float _2602 = saturate(_2601);
                            float _2603 = 1.0f - _2602;
                            float _2605 = cb13_035y + _2542;
                            float _2607 = _2605 * cb13_035z;
                            float _2608 = saturate(_2607);
                            float _2609 = _2608 * _2602;
                            float _2610 = _2603 + _2609;
                            _2613 = _2610;
                          } else {
                            _2613 = 1.0f;
                          }
                        }
                      } else {
                        int _2575 = _2552 + 1;
                        bool _2578 = ((uint)_2575 < (uint)cb13_034x);
                        if (_2578) {
                          _2552 = _2575;
                          continue;
                        } else {
                          _2613 = 1.0f;
                        }
                      }
                      break;
                    }
                  } else {
                    _2613 = 1.0f;
                  }
                } else {
                  _2613 = 1.0f;
                }
                float _2614 = _2613 * _60;
                float _2618 = cb12_066x * 20.0f;
                float _2624 = trunc(cb12_068x);
                int _2625 = int(_2624);
                float _2627 = trunc(cb12_068y);
                int _2628 = int(_2627);
                float _2629 = _159 - cb12_000z;
                float _2630 = _2629 * _2629;
                float _2631 = _2541 + _2630;
                float _2632 = sqrt(_2631);
                float _2634 = cb12_067x + _157;
                float _2635 = cb12_067y + _158;
                float _2636 = _2634 * 0.009999999776482582f;
                float _2637 = _2635 * 0.009999999776482582f;
                float _2638 = _159 * 0.009999999776482582f;
                float _2639 = _2636 / cb12_066x;
                float _2640 = _2637 / cb12_066x;
                float _2641 = _2638 / cb12_066x;
                float _2642 = cb12_067x * 20.0f;
                float _2643 = cb12_067y * 20.0f;
                float _2644 = _2642 + _157;
                float _2645 = _2643 + _158;
                float _2646 = _2644 * 0.009999999776482582f;
                float _2647 = _2645 * 0.009999999776482582f;
                float _2648 = _2646 / _2618;
                float _2649 = _2647 / _2618;
                float _2650 = _2638 / _2618;
                float _2651 = _2641 * cb13_000x;
                float _2652 = _2641 * cb13_000y;
                float _2653 = _2651 / cb13_000z;
                float _2654 = _2652 / cb13_000z;
                float _2655 = _2639 - _2653;
                float _2656 = _2640 - _2654;
                float _2657 = _2650 * cb13_000x;
                float _2658 = _2650 * cb13_000y;
                float _2659 = _2657 / cb13_000z;
                float _2660 = _2658 / cb13_000z;
                float _2661 = _2648 - _2659;
                float _2662 = _2649 - _2660;
                float _2663 = float((int)(_2625));
                float4 _2666 = t14.SampleLevel(s14, float3(_2655, _2656, _2663), 1.0f);
                float _2668 = float((int)(_2628));
                float4 _2669 = t14.SampleLevel(s14, float3(_2655, _2656, _2668), 1.0f);
                float _2671 = _2669.x - _2666.x;
                float _2672 = _2671 * cb12_066w;
                float _2673 = _2672 + _2666.x;
                float4 _2674 = t14.SampleLevel(s14, float3(_2661, _2662, _2663), 1.0f);
                float4 _2676 = t14.SampleLevel(s14, float3(_2661, _2662, _2668), 1.0f);
                float _2678 = _2676.x - _2674.x;
                float _2679 = _2678 * cb12_066w;
                float _2680 = cb13_000z + -0.25f;
                float _2681 = _2680 * 10.0f;
                float _2682 = saturate(_2681);
                float _2683 = _2632 + -100.0f;
                float _2684 = _2683 * 0.006666666828095913f;
                float _2685 = saturate(_2684);
                float _2686 = _2674.x - _2673;
                float _2687 = _2686 + _2679;
                float _2688 = _2687 * _2685;
                float _2689 = _2688 + _2673;
                float _2690 = _2689 * _2682;
                float _2691 = 1.0f - _2690;
                // GRAPHICS CLOUD BEGIN
#ifdef WITCHER_GRAPHICS_CUSTOM_LIGHTING
                _2691 = HartapfelSurfaceCloudShadow(float3(_157, _158, _159), _2691, float3(cb12_000x, cb12_000y, cb12_000z), asuint(hartapfel_jitter));
#else
                _2691 = GraphicsHitCloudShadow(float3(cb12_000x, cb12_000y, cb12_000z), cb12_074x,
                    float3(cb13_000x, cb13_000y, cb13_000z), float3(_157, _158, _159), _2691);
#endif
                // GRAPHICS CLOUD END
                float _2692 = _2614 * _2691;
                _2694 = _2692;
              } else {
                _2694 = 0.0f;
              }
              float _2698 = _157 - cb12_000x;
              float _2699 = _158 - cb12_000y;
              float _2700 = _2698 * _2698;
              float _2701 = _2699 * _2699;
              float _2702 = _2700 + _2701;
              float _2703 = sqrt(_2702);
              float _2706 = cb12_219z * _159;
              float _2708 = _2706 + cb12_219w;
              float _2709 = saturate(_2708);
              float _2718 = cb13_061x - cb13_062x;
              float _2719 = cb13_061y - cb13_062y;
              float _2720 = cb13_061z - cb13_062z;
              float _2721 = _2718 * _2709;
              float _2722 = _2719 * _2709;
              float _2723 = _2720 * _2709;
              float _2724 = _2721 + cb13_062x;
              float _2725 = _2722 + cb13_062y;
              float _2726 = _2723 + cb13_062z;
              float _2728 = cb12_219x * _2703;
              float _2730 = _2728 + cb12_219y;
              float _2731 = saturate(_2730);
              float _2736 = _2724 - cb13_001x;
              float _2737 = _2725 - cb13_001y;
              float _2738 = _2726 - cb13_001z;
              float _2739 = _2736 * _2731;
              float _2740 = _2737 * _2731;
              float _2741 = _2738 * _2731;
              float _2742 = _2739 + cb13_001x;
              float _2743 = _2740 + cb13_001y;
              float _2744 = _2741 + cb13_001z;
              float _2745 = _2694 * _2531;
              float _2746 = _2742 * _2745;
              float _2747 = _2743 * _2745;
              float _2748 = _2744 * _2745;
              // GRAPHICS HIT BEGIN
              if (graphics_hit) {
                float3 diffuse, specular;
                GraphicsHitBRDF(float3(_70, _71, _72), float3(_696, _697, _698),
                    water_light.sun, graphics_material, diffuse, specular);
                _2746 = _2742 * _2694 * diffuse.x;
                _2747 = _2743 * _2694 * diffuse.y;
                _2748 = _2744 * _2694 * diffuse.z;
                graphics_specular += cb0_000z * float3(_2742, _2743, _2744) * (_2694 * specular) * water_light.direct;
              }
              _2746 *= water_light.direct.x;
              _2747 *= water_light.direct.y;
              _2748 *= water_light.direct.z;
              // GRAPHICS HIT END
              _2750 = _2746;
              _2751 = _2747;
              _2752 = _2748;
            } else {
              _2750 = 0.0f;
              _2751 = 0.0f;
              _2752 = 0.0f;
            }
            float _2755 = cb0_000x * _2518;
            float _2756 = cb0_000x * _2519;
            float _2757 = cb0_000x * _2520;
            float _2758 = _2755 + _1320;
            float _2759 = _2756 + _1321;
            float _2760 = _2757 + _1322;
            float _2762 = cb0_000z * _2750;
            float _2763 = cb0_000z * _2751;
            float _2764 = cb0_000z * _2752;
            float _2765 = _2758 + _2762;
            float _2766 = _2759 + _2763;
            float _2767 = _2760 + _2764;
            float _2770 = _2765 + (cb0_004y * GRAPHICS_RAY_SKYLIGHT);
            float _2771 = _2766 + (cb0_004y * GRAPHICS_RAY_SKYLIGHT);
            float _2772 = _2767 + (cb0_004y * GRAPHICS_RAY_SKYLIGHT);
            float _2776 = cb12_225z + 0.054999999701976776f;
            float _2777 = _2776 * 0.9478673338890076f;
            float _2778 = abs(_2777);
            float _2779 = log2(_2778);
            float _2780 = _2779 * 2.4000000953674316f;
            float _2781 = exp2(_2780);
            float _2782 = cb12_225z * 0.07739938050508499f;
            bool _2783 = (cb12_225z <= 0.040449999272823334f);
            float _2784 = select(_2783, _2782, _2781);
            float _2785 = dot(float3(_55, _56, _57), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
            bool _2786 = !(_2785 <= 0.0f);
            if (_2786) {
              bool _2788 = (_2784 <= 0.0f);
              bool _2789 = (_2785 >= _2784);
              bool _2790 = _2788 || _2789;
              if (!_2790) {
                float _2792 = _2785 / _2784;
                float _2793 = saturate(_2792);
                float _2794 = max(cb12_225y, 0.0f);
                float _2795 = _2794 + 1.0f;
                float _2796 = 1.0f / _2795;
                float _2797 = log2(_2793);
                float _2798 = _2797 * _2796;
                float _2799 = exp2(_2798);
                float _2800 = saturate(_2793);
                float _2801 = _2800 * 2.0f;
                float _2802 = 3.0f - _2801;
                float _2803 = _2800 * _2800;
                float _2804 = _2803 * _2802;
                float _2805 = 1.0f - _2804;
                float _2806 = _2799 - _2793;
                float _2807 = _2805 * _2806;
                float _2808 = _2807 + _2793;
                float _2809 = _2808 * _2784;
                float _2810 = _2809 / _2785;
                float _2811 = max(_56, _57);
                float _2812 = max(_55, _2811);
                bool _2813 = (_2812 > 0.0f);
                if (_2813) {
                  float _2815 = 1.0f / _2812;
                  float _2816 = min(_2810, _2815);
                  _2818 = _2816;
                } else {
                  _2818 = _2810;
                }
                float _2819 = _2818 * _55;
                float _2820 = _2818 * _56;
                float _2821 = _2818 * _57;
                _2823 = _2819;
                _2824 = _2820;
                _2825 = _2821;
              } else {
                _2823 = _55;
                _2824 = _56;
                _2825 = _57;
              }
            } else {
              _2823 = 0.0f;
              _2824 = 0.0f;
              _2825 = 0.0f;
            }
            float _2826 = min(_2823, 0.8999999761581421f);
            float _2827 = min(_2824, 0.8999999761581421f);
            float _2828 = min(_2825, 0.8999999761581421f);
            float _2829 = _2770 * 0.31830987334251404f;
            float _2830 = _2829 * _2826;
            float _2831 = _2771 * 0.31830987334251404f;
            float _2832 = _2831 * _2827;
            float _2833 = _2772 * 0.31830987334251404f;
            float _2834 = _2833 * _2828;
            // GRAPHICS HIT BEGIN
            if (graphics_hit) {
              _2830 += graphics_specular.x;
              _2832 += graphics_specular.y;
              _2834 += graphics_specular.z;
            }
            // GRAPHICS HIT END
            int _2835 = CustomConstants_128 & 8;
            bool _2836 = (_2835 == 0);
            if (!_2836) {
              float _2847 = _154 * _154;
              float _2848 = _155 * _155;
              float _2849 = _2847 + _2848;
              float _2850 = _156 * _156;
              float _2851 = _2849 + _2850;
              float _2852 = sqrt(_2851);
              float _2853 = _154 / _2852;
              float _2854 = _155 / _2852;
              float _2855 = _156 / _2852;
              float _2856 = max(0.0f, _2852);
              float _2857 = min(cb12_042z, _2856);
              float _2858 = _2857 * 0.0625f;
              float _2859 = _2858 * _2855;
              float _2860 = _2858 * cb12_043x;
              float _2865 = dot(float3(cb12_038x, cb12_038y, cb12_038z), float3(_2853, _2854, _2855));
              float _2867 = _2865 + cb12_042x;
              float _2868 = cb12_042x + 1.0f;
              float _2869 = _2867 / _2868;
              float _2870 = saturate(_2869);
              float _2871 = cb12_043y - cb12_043z;
              float _2872 = _2870 * _2871;
              float _2873 = _2872 + cb12_043z;
              bool _2876 = (cb12_287z == 0);
              if (!_2876) {
                bool _2878 = (_2865 > 0.0f);
                bool _2879 = (cb12_287z != 2);
                bool _2880 = _2878 && _2879;
                _2882 = _2880;
              } else {
                _2882 = true;
              }
              float _2883 = abs(_2865);
              float _2884 = _2883 * _2883;
              if (_2882) {
                float _2886 = _2857 * 0.0020000000949949026f;
                float _2887 = _2886 + -0.30000001192092896f;
                float _2888 = saturate(_2887);
                _2890 = _2888;
              } else {
                _2890 = 1.0f;
              }
              float _2891 = _2884 * _2890;
              bool _2892 = (_2865 > 0.0f);
              if (_2892) {
                _2904 = cb12_039x;
                _2905 = cb12_039y;
                _2906 = cb12_039z;
              } else {
                _2904 = cb12_041x;
                _2905 = cb12_041y;
                _2906 = cb12_041z;
              }
              float _2911 = _2904 - cb12_040x;
              float _2912 = _2905 - cb12_040y;
              float _2913 = _2906 - cb12_040z;
              float _2914 = _2911 * _2891;
              float _2915 = _2912 * _2891;
              float _2916 = _2913 * _2891;
              float _2917 = _2914 + cb12_040x;
              float _2918 = _2915 + cb12_040y;
              float _2919 = _2916 + cb12_040z;
              if (_2892) {
                _2931 = cb12_045x;
                _2932 = cb12_045y;
                _2933 = cb12_045z;
              } else {
                _2931 = cb12_047x;
                _2932 = cb12_047y;
                _2933 = cb12_047z;
              }
              float _2938 = _2931 - cb12_046x;
              float _2939 = _2932 - cb12_046y;
              float _2940 = _2933 - cb12_046z;
              float _2941 = _2938 * _2891;
              float _2942 = _2939 * _2891;
              float _2943 = _2940 * _2891;
              float _2944 = _2941 + cb12_046x;
              float _2945 = _2942 + cb12_046y;
              float _2946 = _2943 + cb12_046z;
              bool _2948 = !(_2857 >= cb12_048y);
              [branch]
              if (!_2948) {
                float _2951 = cb12_042y + _153;
                float _2952 = _2873 * _2951;
                float _2953 = _2873 * _2859;
                float _2954 = _2953 * 16.0f;
                float _2955 = _2954 + _2952;
                float _2956 = max(0.0f, _2955);
                float _2957 = _2956 + 1.0f;
                float _2958 = _2860 / _2957;
                float _2959 = saturate(_2958);
                float _2960 = 1.0f - _2959;
                float _2961 = _2953 * 15.0f;
                float _2962 = _2961 + _2952;
                float _2963 = max(0.0f, _2962);
                float _2964 = _2963 + 1.0f;
                float _2965 = _2860 / _2964;
                float _2966 = saturate(_2965);
                float _2967 = 1.0f - _2966;
                float _2968 = _2967 * _2960;
                float _2969 = _2953 * 14.0f;
                float _2970 = _2969 + _2952;
                float _2971 = max(0.0f, _2970);
                float _2972 = _2971 + 1.0f;
                float _2973 = _2860 / _2972;
                float _2974 = saturate(_2973);
                float _2975 = 1.0f - _2974;
                float _2976 = _2968 * _2975;
                float _2977 = _2953 * 13.0f;
                float _2978 = _2977 + _2952;
                float _2979 = max(0.0f, _2978);
                float _2980 = _2979 + 1.0f;
                float _2981 = _2860 / _2980;
                float _2982 = saturate(_2981);
                float _2983 = 1.0f - _2982;
                float _2984 = _2976 * _2983;
                float _2985 = _2953 * 12.0f;
                float _2986 = _2985 + _2952;
                float _2987 = max(0.0f, _2986);
                float _2988 = _2987 + 1.0f;
                float _2989 = _2860 / _2988;
                float _2990 = saturate(_2989);
                float _2991 = 1.0f - _2990;
                float _2992 = _2984 * _2991;
                float _2993 = _2953 * 11.0f;
                float _2994 = _2993 + _2952;
                float _2995 = max(0.0f, _2994);
                float _2996 = _2995 + 1.0f;
                float _2997 = _2860 / _2996;
                float _2998 = saturate(_2997);
                float _2999 = 1.0f - _2998;
                float _3000 = _2992 * _2999;
                float _3001 = _2953 * 10.0f;
                float _3002 = _3001 + _2952;
                float _3003 = max(0.0f, _3002);
                float _3004 = _3003 + 1.0f;
                float _3005 = _2860 / _3004;
                float _3006 = saturate(_3005);
                float _3007 = 1.0f - _3006;
                float _3008 = _3000 * _3007;
                float _3009 = _2953 * 9.0f;
                float _3010 = _3009 + _2952;
                float _3011 = max(0.0f, _3010);
                float _3012 = _3011 + 1.0f;
                float _3013 = _2860 / _3012;
                float _3014 = saturate(_3013);
                float _3015 = 1.0f - _3014;
                float _3016 = _3008 * _3015;
                float _3017 = _2953 * 8.0f;
                float _3018 = _3017 + _2952;
                float _3019 = max(0.0f, _3018);
                float _3020 = _3019 + 1.0f;
                float _3021 = _2860 / _3020;
                float _3022 = saturate(_3021);
                float _3023 = 1.0f - _3022;
                float _3024 = _3016 * _3023;
                float _3025 = _2953 * 7.0f;
                float _3026 = _3025 + _2952;
                float _3027 = max(0.0f, _3026);
                float _3028 = _3027 + 1.0f;
                float _3029 = _2860 / _3028;
                float _3030 = saturate(_3029);
                float _3031 = 1.0f - _3030;
                float _3032 = _3024 * _3031;
                float _3033 = _2953 * 6.0f;
                float _3034 = _3033 + _2952;
                float _3035 = max(0.0f, _3034);
                float _3036 = _3035 + 1.0f;
                float _3037 = _2860 / _3036;
                float _3038 = saturate(_3037);
                float _3039 = 1.0f - _3038;
                float _3040 = _3032 * _3039;
                float _3041 = _2953 * 5.0f;
                float _3042 = _3041 + _2952;
                float _3043 = max(0.0f, _3042);
                float _3044 = _3043 + 1.0f;
                float _3045 = _2860 / _3044;
                float _3046 = saturate(_3045);
                float _3047 = 1.0f - _3046;
                float _3048 = _3040 * _3047;
                float _3049 = _2953 * 4.0f;
                float _3050 = _3049 + _2952;
                float _3051 = max(0.0f, _3050);
                float _3052 = _3051 + 1.0f;
                float _3053 = _2860 / _3052;
                float _3054 = saturate(_3053);
                float _3055 = 1.0f - _3054;
                float _3056 = _3048 * _3055;
                float _3057 = _2953 * 3.0f;
                float _3058 = _3057 + _2952;
                float _3059 = max(0.0f, _3058);
                float _3060 = _3059 + 1.0f;
                float _3061 = _2860 / _3060;
                float _3062 = saturate(_3061);
                float _3063 = 1.0f - _3062;
                float _3064 = _3056 * _3063;
                float _3065 = _2953 * 2.0f;
                float _3066 = _3065 + _2952;
                float _3067 = max(0.0f, _3066);
                float _3068 = _3067 + 1.0f;
                float _3069 = _2860 / _3068;
                float _3070 = saturate(_3069);
                float _3071 = 1.0f - _3070;
                float _3072 = _3064 * _3071;
                float _3073 = _2859 + _2951;
                float _3074 = _2873 * _3073;
                float _3075 = max(0.0f, _3074);
                float _3076 = _3075 + 1.0f;
                float _3077 = _2860 / _3076;
                float _3078 = saturate(_3077);
                float _3079 = 1.0f - _3078;
                float _3080 = _3072 * _3079;
                float _3081 = 1.0f - _3080;
                float _3082 = _2857 - cb12_048y;
                float _3084 = _3082 * cb12_048z;
                float _3085 = saturate(_3084);
                _3087 = _3081;
                _3088 = _3085;
              } else {
                _3087 = 1.0f;
                _3088 = 0.0f;
              }
              float _3089 = abs(_3087);
              float _3090 = log2(_3089);
              float _3091 = _3090 * cb12_042w;
              float _3092 = exp2(_3091);
              float _3093 = _3092 * _3088;
              float _3094 = _3090 * cb12_048x;
              float _3095 = exp2(_3094);
              float _3096 = _3095 * _3088;
              float _3099 = cb12_190x * _3093;
              float _3101 = _3099 + cb12_190y;
              float _3102 = saturate(_3101);
              float _3104 = cb12_190z * _3093;
              float _3106 = _3104 + cb12_190w;
              float _3107 = saturate(_3106);
              float _3112 = cb12_189x - _2917;
              float _3113 = cb12_189y - _2918;
              float _3114 = cb12_189z - _2919;
              float _3115 = _3112 * _3102;
              float _3116 = _3113 * _3102;
              float _3117 = _3114 * _3102;
              float _3118 = _3115 + _2917;
              float _3119 = _3116 + _2918;
              float _3120 = _3117 + _2919;
              float _3122 = cb12_189w + -1.0f;
              float _3123 = _3122 * _3107;
              float _3124 = _3123 + 1.0f;
              float _3125 = _3124 * _3093;
              float _3126 = saturate(_3125);
              bool _3129 = (cb12_193x > 0.0f);
              [branch]
              if (_3129) {
                float _3133 = cb12_192x * _3093;
                float _3135 = _3133 + cb12_192y;
                float _3136 = saturate(_3135);
                float _3138 = cb12_192z * _3093;
                float _3140 = _3138 + cb12_192w;
                float _3141 = saturate(_3140);
                float _3146 = cb12_191x - _2917;
                float _3147 = cb12_191y - _2918;
                float _3148 = cb12_191z - _2919;
                float _3149 = _3146 * _3136;
                float _3150 = _3147 * _3136;
                float _3151 = _3148 * _3136;
                float _3153 = cb12_191w + -1.0f;
                float _3154 = _3153 * _3141;
                float _3155 = _3154 + 1.0f;
                float _3156 = _3155 * _3093;
                float _3157 = saturate(_3156);
                float _3158 = _3149 - _3115;
                float _3159 = _3150 - _3116;
                float _3160 = _3151 - _3117;
                float _3161 = _3157 - _3126;
                float _3162 = _3158 * cb12_193x;
                float _3163 = _3159 * cb12_193x;
                float _3164 = _3160 * cb12_193x;
                float _3165 = _3161 * cb12_193x;
                float _3166 = _3162 + _3118;
                float _3167 = _3163 + _3119;
                float _3168 = _3164 + _3120;
                float _3169 = _3165 + _3126;
                _3171 = _3166;
                _3172 = _3167;
                _3173 = _3168;
                _3174 = _3169;
              } else {
                _3171 = _3118;
                _3172 = _3119;
                _3173 = _3120;
                _3174 = _3126;
              }
              float _3176 = saturate(cb12_046w);
              float _3177 = _3096 * _3176;
              float _3178 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_2830, _2832, _2834));
              float _3179 = _3178 * _2944;
              float _3180 = _3178 * _2945;
              float _3181 = _3178 * _2946;
              float _3182 = _3179 - _2830;
              float _3183 = _3180 - _2832;
              float _3184 = _3181 - _2834;
              float _3185 = _3182 * _3177;
              float _3186 = _3183 * _3177;
              float _3187 = _3184 * _3177;
              float _3188 = _3185 + _2830;
              float _3189 = _3186 + _2832;
              float _3190 = _3187 + _2834;
              float _3191 = _3171 - _3188;
              float _3192 = _3172 - _3189;
              float _3193 = _3173 - _3190;
              float _3194 = _3191 * _3174;
              float _3195 = _3192 * _3174;
              float _3196 = _3193 * _3174;
              float _3197 = _3194 + _3188;
              float _3198 = _3195 + _3189;
              float _3199 = _3196 + _3190;
              _3201 = _3197;
              _3202 = _3198;
              _3203 = _3199;
            } else {
              _3201 = _2830;
              _3202 = _2832;
              _3203 = _2834;
            }
            float _3204 = _3201 * _62.w;
            float _3205 = _3202 * _62.w;
            float _3206 = _3203 * _62.w;
            u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_3204, _3205, _3206, _74.w);
          }
        }
      }
    }
  }
}
