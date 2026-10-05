#include "./night_skylight.hlsli"

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
  float night_skylight_tag : packoffset(c185.w);
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
  const float night_skylight = WitcherNightSkylight(night_skylight_tag);
  float _37[4];
  float4 _39 = t5.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0));
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
  if (_39.w == 3.0f) {
    u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_39.x, _39.y, _39.z, 65504.0f);
  } else {
    uint _51 = uint(max((-1.0f - _39.w), 0.0f) + 0.5f);
    bool _54 = (_39.w > 0.0f);
    float _55 = select(_54, 0.0f, _39.x);
    float _56 = select(_54, 0.0f, _39.y);
    float _57 = select(_54, 0.0f, _39.z);
    float4 _62 = t11.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0));
    float _70 = (_62.x * 2.0f) + -1.0f;
    float _71 = (_62.y * 2.0f) + -1.0f;
    float _72 = (_62.z * 2.0f) + -1.0f;
    float4 _74 = t12.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0));
    if ((CustomConstants_128 & 16) == 0) {
      u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_55, _56, _57, select((_74.w < 0.0f), 65504.0f, _74.w));
    } else {
      if (!(CameraCB_236 == 0)) {
        _100 = (((((int)(SV_DispatchThreadID.y) ^ 1) ^ CameraCB_220) & 1) | ((int)(SV_DispatchThreadID.x << 1u)));
      } else {
        _100 = (int)(SV_DispatchThreadID.x);
      }
      float _102 = t13.Load(int3(_100, (int)(SV_DispatchThreadID.y), 0));
      if (!(!(((CameraCB_152.x * _102.x) + CameraCB_152.y) >= 0.9999990463256836f))) {
        u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(0.0f, 0.0f, 0.0f, 65504.0f);
      } else {
        float _113 = float((int)(_100));
        float _114 = float((int)((int)(SV_DispatchThreadID.y)));
        float _150 = mad((CameraCB_000[2].w), _102.x, mad((CameraCB_000[1].w), _114, ((CameraCB_000[0].w) * _113))) + (CameraCB_000[3].w);
        float _153 = (mad((CameraCB_000[2].z), _102.x, mad((CameraCB_000[1].z), _114, ((CameraCB_000[0].z) * _113))) + (CameraCB_000[3].z)) / _150;
        float _154 = _74.x * _74.w;
        float _155 = _74.y * _74.w;
        float _156 = _74.z * _74.w;
        float _157 = ((mad((CameraCB_000[2].x), _102.x, mad((CameraCB_000[1].x), _114, ((CameraCB_000[0].x) * _113))) + (CameraCB_000[3].x)) / _150) + _154;
        float _158 = ((mad((CameraCB_000[2].y), _102.x, mad((CameraCB_000[1].y), _114, ((CameraCB_000[0].y) * _113))) + (CameraCB_000[3].y)) / _150) + _155;
        float _159 = _153 + _156;
        if (_54) {
          if (_39.w > 1.0f) {
            u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(0.0f, 0.0f, 0.0f, 65504.0f);
          } else {
            uint _167 = uint(_39.z);
            int _170 = (((int)(_167 << 11u)) & 63488) | (int)(uint(_39.x));
            int _173 = ((int)(((uint)((uint)(_167) >> 5)) << 11u)) | (int)(uint(_39.y));
            if ((int)((uint)_170 >= (uint)CameraCB_240.x) || (int)((uint)_173 >= (uint)CameraCB_240.y)) {
              u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(0.0f, 0.0f, 0.0f, 65504.0f);
            } else {
              float4 _183 = t27.Load(int3(_170, _173, 0));
              u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4((_183.x * _62.w), (_183.y * _62.w), (_183.z * _62.w), _74.w);
            }
          }
        } else {
          [branch]
          if (_74.w < 0.0f) {
            float4 _194 = t39.Load(int3(_100, (int)(SV_DispatchThreadID.y), 0));
            bool _197 = (_194.w < 1.0f);
            if ((int)(_194.z > 0.5f) || ((int)(!_197))) {
              float _202 = saturate(_74.z);
              float _204 = rsqrt(dot(float3(_74.x, _74.y, _202), float3(_74.x, _74.y, _202)));
              float _205 = _204 * _74.x;
              float _206 = _204 * _74.y;
              float _207 = _204 * _202;
              if (_197) {
                _215 = cb0_004x;
              } else {
                _215 = cb0_003w;
              }
              float _225 = ((abs(_204 * (_74.x + _74.y)) + abs(_204 * (_74.x - _74.y))) * 0.5f) + abs(_207);
              float4 _234 = t3.SampleLevel(s10, float2((((_205 / _225) * 0.5f) + 0.5f), (0.5f - ((_206 / _225) * 0.5f))), 0.0f);
              if (_197) {
                _242 = cb0_005y;
              } else {
                _242 = 1.0f;
              }
              float _272 = exp2(log2(saturate((sqrt((_205 * _205) + (_206 * _206)) * 0.5f) * min(max((1.0f / (1.0f - _207)), -3.4028234663852886e+38f), 3.4028234663852886e+38f))) * cb0_003x);
              float _291 = ((((cb0_001x - _234.x) + (_272 * (cb0_002x - cb0_001x))) * _215) + _234.x) * cb0_003z;
              float _292 = ((((cb0_001y - _234.y) + (_272 * (cb0_002y - cb0_001y))) * _215) + _234.y) * cb0_003z;
              float _293 = ((((cb0_001z - _234.z) + (_272 * (cb0_002z - cb0_001z))) * _215) + _234.z) * cb0_003z;
              float _294 = dot(float3(_291, _292, _293), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
              float _301 = ((_291 - _294) * cb0_003y) + _294;
              float _302 = ((_292 - _294) * cb0_003y) + _294;
              float _303 = ((_293 - _294) * cb0_003y) + _294;
              float _304 = dot(float3(_301, _302, _303), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
              if (_304 > cb0_005x) {
                float _307 = cb0_005x / _304;
                _312 = (_307 * _301);
                _313 = (_307 * _302);
                _314 = (_307 * _303);
              } else {
                _312 = _301;
                _313 = _302;
                _314 = _303;
              }
              // Misses use a separate procedural/cubemap sky. Scale it before
              // native fog; traced scene hits and emissive radiance stay intact.
              float _315 = (cb0_000w * _242) * night_skylight;
              float _316 = _312 * _315;
              float _317 = _313 * _315;
              float _318 = _314 * _315;
              if (!((CustomConstants_128 & 8) == 0)) {
                float _336 = sqrt(((_74.x * _74.x) + (_74.y * _74.y)) + (_74.z * _74.z));
                float _339 = _74.z / _336;
                float _340 = cb12_042z * 0.0625f;
                float _341 = _339 * _340;
                float _342 = _340 * cb12_044x;
                float _347 = dot(float3(cb12_038x, cb12_038y, cb12_038z), float3((_74.x / _336), (_74.y / _336), _339));
                float _355 = (saturate((_347 + cb12_042x) / (cb12_042x + 1.0f)) * (cb12_044y - cb12_044z)) + cb12_044z;
                if (!(cb12_287z == 0)) {
                  _364 = ((int)(_347 > 0.0f) && (int)(cb12_287z != 2));
                } else {
                  _364 = true;
                }
                float _365 = abs(_347);
                if (_364) {
                  _372 = saturate((cb12_042z * 0.0020000000949949026f) + -0.30000001192092896f);
                } else {
                  _372 = 1.0f;
                }
                float _373 = (_365 * _365) * _372;
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
                float _399 = ((_386 - cb12_040x) * _373) + cb12_040x;
                float _400 = ((_387 - cb12_040y) * _373) + cb12_040y;
                float _401 = ((_388 - cb12_040z) * _373) + cb12_040z;
                if (_374) {
                  _413 = cb12_045x;
                  _414 = cb12_045y;
                  _415 = cb12_045z;
                } else {
                  _413 = cb12_047x;
                  _414 = cb12_047y;
                  _415 = cb12_047z;
                }
                [branch]
                if (!(!(cb12_042z >= cb12_048y))) {
                  float _433 = cb12_042y + _153;
                  float _434 = _355 * _433;
                  float _435 = _355 * _341;
                  _569 = (1.0f - ((((((((((((((((1.0f - saturate(_342 / (max(0.0f, ((_435 * 15.0f) + _434)) + 1.0f))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 16.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 14.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 13.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 12.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 11.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 10.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 9.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 8.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 7.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 6.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 5.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 4.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 3.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, ((_435 * 2.0f) + _434)) + 1.0f)))) * (1.0f - saturate(_342 / (max(0.0f, (_355 * (_341 + _433))) + 1.0f)))));
                  _570 = saturate((cb12_042z - cb12_048y) * cb12_048z);
                } else {
                  _569 = 1.0f;
                  _570 = 0.0f;
                }
                float _572 = log2(abs(_569));
                float _575 = exp2(_572 * cb12_042w) * _570;
                float _584 = saturate((cb12_190x * _575) + cb12_190y);
                float _597 = (cb12_189x - _399) * _584;
                float _598 = (cb12_189y - _400) * _584;
                float _599 = (cb12_189z - _401) * _584;
                float _600 = _597 + _399;
                float _601 = _598 + _400;
                float _602 = _599 + _401;
                float _608 = saturate((((cb12_189w + -1.0f) * saturate((cb12_190z * _575) + cb12_190w)) + 1.0f) * _575);
                [branch]
                if (cb12_193x > 0.0f) {
                  float _618 = saturate((cb12_192x * _575) + cb12_192y);
                  _653 = (((((cb12_191x - _399) * _618) - _597) * cb12_193x) + _600);
                  _654 = (((((cb12_191y - _400) * _618) - _598) * cb12_193x) + _601);
                  _655 = (((((cb12_191z - _401) * _618) - _599) * cb12_193x) + _602);
                  _656 = (((saturate((((cb12_191w + -1.0f) * saturate((cb12_192z * _575) + cb12_192w)) + 1.0f) * _575) - _608) * cb12_193x) + _608);
                } else {
                  _653 = _600;
                  _654 = _601;
                  _655 = _602;
                  _656 = _608;
                }
                float _659 = (exp2(_572 * cb12_048x) * _570) * saturate(cb12_046w);
                float _660 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_316, _317, _318));
                float _670 = (((_660 * (lerp(cb12_046x, _413, _373))) - _316) * _659) + _316;
                float _671 = (((_660 * (lerp(cb12_046y, _414, _373))) - _317) * _659) + _317;
                float _672 = (((_660 * (lerp(cb12_046z, _415, _373))) - _318) * _659) + _318;
                _683 = (lerp(_670, _653, _656));
                _684 = (lerp(_671, _654, _656));
                _685 = (lerp(_672, _655, _656));
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
            u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4((_683 * _62.w), (_684 * _62.w), (_685 * _62.w), 65504.0f);
          } else {
            float _691 = -0.0f - _154;
            float _692 = -0.0f - _155;
            float _693 = -0.0f - _156;
            float _695 = rsqrt(dot(float3(_691, _692, _693), float3(_691, _692, _693)));
            float _696 = _695 * _691;
            float _697 = _695 * _692;
            float _698 = _695 * _693;
            if (!((int)((_51 & 2) != 0) || (int)((CustomConstants_128 & 1) == 0))) {
              int _720 = int(floor((_157 - cb9_000x) / cb9_002x));
              int _721 = int(floor((_158 - cb9_000y) / cb9_002y));
              int _722 = int(floor((_159 - cb9_000z) / cb9_002z));
              if ((int)((_721 | _720) | _722) > (int)-1) {
                _739 = int((bool)((int)(!((int)((int)_722 < (int)cb9_004z) && ((int)((int)((int)_720 < (int)cb9_004x) && (int)((int)_721 < (int)cb9_004y)))))));
              } else {
                _739 = -1;
              }
              int _757 = int(floor((_157 - cb9_001x) / cb9_003x));
              int _758 = int(floor((_158 - cb9_001y) / cb9_003y));
              int _759 = int(floor((_159 - cb9_001z) / cb9_003z));
              if (_739 == -1) {
                if ((int)((_758 | _757) | _759) > (int)-1) {
                  _777 = select(((int)((int)_759 < (int)cb9_005z) && ((int)((int)((int)_757 < (int)cb9_005x) && (int)((int)_758 < (int)cb9_005y)))), 1, -1);
                } else {
                  _777 = -1;
                }
              } else {
                _777 = _739;
              }
              if (!(_777 == -1)) {
                uint _814 = ((uint)(asint(cb9_raw[(_777 + 6)].x)) + (uint)(int(floor((_157 - (cb9_raw[_777].x)) / (cb9_raw[(_777 + 2)].x))))) + ((uint)(((asint(cb9_raw[(_777 + 4)].y) * int(floor((_159 - (cb9_raw[_777].z)) / (cb9_raw[(_777 + 2)].z)))) + int(floor((_158 - (cb9_raw[_777].y)) / (cb9_raw[(_777 + 2)].y)))) * asint(cb9_raw[(_777 + 4)].x)));
                int _817 = t25[_814].range_000;
                int _819 = t25[_814].range_004;
                _821 = _819;
                _822 = _817;
              } else {
                _821 = cb13_067y;
                _822 = 1;
              }
              if ((uint)_822 < (uint)_821) {
                _826 = 0.0f;
                _827 = 0.0f;
                _828 = 0.0f;
                _829 = _822;
                while(true) {
                  int _832 = t26[_829].light_000;
                  float _835 = t16[_832].LightParams_048.w;
                  int _836 = asint(_835);
                  if (!((int)_836 < (int)0)) {
                    float _840 = t16[_832].LightParams_000.x;
                    float _841 = t16[_832].LightParams_000.y;
                    float _842 = t16[_832].LightParams_000.z;
                    float _843 = _840 - _157;
                    float _844 = _841 - _158;
                    float _845 = _842 - _159;
                    float _853 = sqrt(((_843 * _843) + (_844 * _844)) + (_845 * _845));
                    float _856 = t16[_832].LightParams_080.x;
                    float _858 = t16[_832].LightParams_000.w;
                    float _859 = _853 / _858;
                    float _860 = _859 * cb0_004z;
                    float _861 = _860 * _860;
                    float _864 = saturate(1.0f - (_861 * _861));
                    bool _867 = ((_836 & 1) != 0);
                    float _868 = t16[_832].LightParams_080.z;
                    bool _869 = (_868 > 0.0f);
                    float _871 = t16[_832].LightParams_096.x;
                    float _874 = t16[_832].LightParams_144.x;
                    int _875 = asint(_874);
                    bool _877 = ((_875 & 1) != 0);
                    float _879 = (_864 * _864) / (((_853 * _853) * _856) + 1.0f);
                    if (_867) {
                      float _882 = t16[_832].LightParams_032.x;
                      float _883 = t16[_832].LightParams_032.y;
                      float _884 = t16[_832].LightParams_032.z;
                      float _886 = rsqrt(dot(float3(_843, _844, _845), float3(_843, _844, _845)));
                      float _895 = t16[_832].LightParams_064.w;
                      float _896 = t16[_832].LightParams_064.y;
                      float _898 = t16[_832].LightParams_064.z;
                      _906 = (exp2(log2(saturate((_896 * dot(float3((-0.0f - (_843 * _886)), (-0.0f - (_844 * _886)), (-0.0f - (_845 * _886))), float3(_882, _883, _884))) + _898)) * _895) * _879);
                    } else {
                      _906 = _879;
                    }
                    bool _908 = (_906 > 0.0f);
                    if (((int)(_869 || _877)) && _908) {
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
                        float _941 = t16[_832].LightParams_112.x;
                        float _943 = t16[_832].LightParams_144.z;
                        _1117 = mad(((_921 * _916) - (_920 * _917)), _913, mad(((_920 * _918) - (_922 * _916)), _912, (((_922 * _917) - (_921 * _918)) * _911)));
                        _1118 = mad(_922, _913, mad(_921, _912, (_920 * _911)));
                        _1119 = mad(_918, _913, mad(_917, _912, (_916 * _911)));
                        _1120 = _941;
                        _1121 = asint(_943);
                      } else {
                        if (_877) {
                          float _948 = t16[_832].LightParams_064.y;
                          float _949 = t16[_832].LightParams_064.z;
                          float _950 = t16[_832].LightParams_064.w;
                          float _952 = t16[_832].LightParams_032.x;
                          float _953 = t16[_832].LightParams_032.y;
                          float _954 = t16[_832].LightParams_032.z;
                          float _966 = mad(((_952 * _949) - (_953 * _948)), _913, mad(((_954 * _948) - (_952 * _950)), _912, (((_953 * _950) - (_954 * _949)) * _911)));
                          float _969 = mad(_954, _913, mad(_953, _912, (_952 * _911)));
                          float _972 = mad(_950, _913, mad(_949, _912, (_948 * _911)));
                          float _973 = -0.0f - _966;
                          float _974 = -0.0f - _969;
                          float _975 = -0.0f - _972;
                          float _976 = _973 / _853;
                          float _977 = _974 / _853;
                          float _978 = _975 / _853;
                          float _979 = abs(_976);
                          float _980 = abs(_977);
                          float _981 = abs(_978);
                          bool _985 = (_979 > max(_980, _981));
                          if (!((_875 & 4) == 0)) {
                            if (_985) {
                              if (_976 > 0.0f) {
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
                              if (_980 > max(_979, _981)) {
                                if (_977 > 0.0f) {
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
                                if (_978 > 0.0f) {
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
                            _1117 = _1015;
                            _1118 = _1016;
                            _1119 = _1017;
                            _1120 = _1018;
                            _1121 = asint(_1020);
                          } else {
                            if (_985) {
                              if (_976 > 0.0f) {
                                float _1027 = t16[_832].LightParams_112.x;
                                float _1029 = t16[_832].LightParams_144.z;
                                _1117 = _969;
                                _1118 = _972;
                                _1119 = _973;
                                _1120 = _1027;
                                _1121 = asint(_1029);
                              } else {
                                float _1033 = t16[_832].LightParams_112.y;
                                float _1035 = t16[_832].LightParams_144.z;
                                _1117 = _974;
                                _1118 = _972;
                                _1119 = _966;
                                _1120 = _1033;
                                _1121 = ((uint)((uint)(asint(_1035))) >> 10);
                              }
                            } else {
                              if (_980 > max(_979, _981)) {
                                if (_977 > 0.0f) {
                                  float _1045 = t16[_832].LightParams_112.z;
                                  float _1047 = t16[_832].LightParams_144.z;
                                  _1117 = _973;
                                  _1118 = _972;
                                  _1119 = _974;
                                  _1120 = _1045;
                                  _1121 = ((uint)((uint)(asint(_1047))) >> 20);
                                } else {
                                  float _1052 = t16[_832].LightParams_112.w;
                                  float _1054 = t16[_832].LightParams_144.w;
                                  _1117 = _966;
                                  _1118 = _972;
                                  _1119 = _969;
                                  _1120 = _1052;
                                  _1121 = asint(_1054);
                                }
                              } else {
                                if (_978 > 0.0f) {
                                  float _1060 = t16[_832].LightParams_128.x;
                                  float _1062 = t16[_832].LightParams_144.w;
                                  _1117 = _966;
                                  _1118 = _969;
                                  _1119 = _975;
                                  _1120 = _1060;
                                  _1121 = ((uint)((uint)(asint(_1062))) >> 10);
                                } else {
                                  float _1067 = t16[_832].LightParams_128.y;
                                  float _1069 = t16[_832].LightParams_144.w;
                                  _1117 = _966;
                                  _1118 = _974;
                                  _1119 = _972;
                                  _1120 = _1067;
                                  _1121 = ((uint)((uint)(asint(_1069))) >> 20);
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
                          if (_1076 > max(_1077, _1078)) {
                            if (_1073 > 0.0f) {
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
                            if (_1077 > max(_1076, _1078)) {
                              if (_1074 > 0.0f) {
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
                              if (_1075 > 0.0f) {
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
                          _1117 = _1109;
                          _1118 = _1110;
                          _1119 = _1111;
                          _1120 = _1112;
                          _1121 = asint(_1114);
                        }
                      }
                      float _1122 = t16[_832].LightParams_080.y;
                      float _1129 = (((_1117 * _1122) / _1119) * 0.5f) + 0.5f;
                      float _1130 = 0.5f - ((mad(_1122, _1118, 0.0f) / _1119) * 0.5f);
                      if (_869) {
                        int _1132 = asint(_1120);
                        int _1134 = ((uint)(_1132) >> 18) & 4092;
                        float _1135 = float((uint)_1134);
                        [branch]
                        if (!(_1134 == 0)) {
                          float _1156 = t9.SampleLevel(s10, float3((cb13_067x * ((_1129 * _1135) + float((uint)((uint)(((int)(_1132 << 2u)) & 4092))))), (cb13_067x * ((_1130 * _1135) + float((uint)((uint)(((uint)(_1132) >> 8) & 4092))))), float((uint)((uint)((uint)(_1132) >> 30)))), 0.0f);
                          _1164 = saturate(exp2((_1156.x - (_859 * 0.9900000095367432f)) * 144.26950073242188f));
                        } else {
                          _1164 = 1.0f;
                        }
                      } else {
                        _1164 = 1.0f;
                      }
                      if (_877) {
                        bool _1167 = ((_875 & 2) != 0);
                        if (_1167) {
                          _1177 = (_1121 & 1023);
                          _1178 = 0;
                        } else {
                          _1177 = (_1121 & 255);
                          _1178 = (((uint)(_1121) >> 8) & 3);
                        }
                        float _1181 = t16[_832].LightParams_144.y;
                        float _1183 = floor(_1181) + float((uint)_1177);
                        float4 _1187 = t42.SampleLevel(s10, float3(_1129, _1130, _1183), 0.0f);
                        _37[0] = _1187.x;
                        _37[1] = _1187.y;
                        _37[2] = _1187.z;
                        _37[3] = _1187.w;
                        if (!((_875 & 8) == 0)) {
                          float4 _1198 = t42.SampleLevel(s10, float3(_1129, _1130, (_1183 + 1.0f)), 0.0f);
                          float _1203 = frac(_1181);
                          float _1212 = ((_1198.x - _1187.x) * _1203) + _1187.x;
                          float _1213 = ((_1198.y - _1187.y) * _1203) + _1187.y;
                          float _1214 = ((_1198.z - _1187.z) * _1203) + _1187.z;
                          _37[0] = _1212;
                          _37[1] = _1213;
                          _37[2] = _1214;
                          _37[3] = (lerp(_1187.w, _1198.w, _1203));
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
                    if ((int)(_871 > 0.0f) && _908) {
                      float _1234 = t16[_832].LightParams_096.y;
                      float _1237 = t10.SampleLevel(s10, float4(_843, _844, _845, _1234), 0.0f);
                      _1246 = (saturate(exp2((_1237.x - (_859 * 0.9900000095367432f)) * 144.26950073242188f)) * _1228);
                    } else {
                      _1246 = _1228;
                    }
                    float _1247 = t16[_832].LightParams_080.w;
                    float _1251 = (((_1246 + -1.0f) * _1247) + 1.0f) * _906;
                    float _1252 = _1251 * _1229;
                    float _1253 = _1251 * _1230;
                    float _1254 = _1251 * _1231;
                    [branch]
                    if ((int)(_1254 > 0.0f) || ((int)((int)(_1252 > 0.0f) || (int)(_1253 > 0.0f)))) {
                      float _1262 = rsqrt(dot(float3(_843, _844, _845), float3(_843, _844, _845)));
                      float _1263 = _1262 * _843;
                      float _1264 = _1262 * _844;
                      float _1265 = _1262 * _845;
                      float _1266 = _1263 + _696;
                      float _1267 = _1264 + _697;
                      float _1268 = _1265 + _698;
                      float _1270 = rsqrt(dot(float3(_1266, _1267, _1268), float3(_1266, _1267, _1268)));
                      float _1277 = saturate(1.0f - abs(dot(float3((_1266 * _1270), (_1267 * _1270), (_1268 * _1270)), float3(_696, _697, _698))));
                      float _1278 = _1277 * _1277;
                      float _1290 = t16[_832].LightParams_048.x;
                      float _1291 = t16[_832].LightParams_048.y;
                      float _1292 = t16[_832].LightParams_048.z;
                      float _1293 = saturate(dot(float3(_70, _71, _72), float3(_1263, _1264, _1265))) * (1.0f - ((((_1278 * _1278) * _1277) * cb13_066x) / (cb13_066z + 1.0f)));
                      _1304 = (((_1252 * _1290) * _1293) + _826);
                      _1305 = (((_1253 * _1291) * _1293) + _827);
                      _1306 = (((_1254 * _1292) * _1293) + _828);
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
                  if (!(_1307 == _821)) {
                    _826 = _1304;
                    _827 = _1305;
                    _828 = _1306;
                    _829 = _1307;
                    continue;
                  }
                  _1311 = _1304;
                  _1312 = _1305;
                  _1313 = _1306;
                  break;
                }
              } else {
                _1311 = 0.0f;
                _1312 = 0.0f;
                _1313 = 0.0f;
              }
              _1320 = (cb0_000y * _1311);
              _1321 = (cb0_000y * _1312);
              _1322 = (cb0_000y * _1313);
            } else {
              _1320 = 0.0f;
              _1321 = 0.0f;
              _1322 = 0.0f;
            }
            if (!((CustomConstants_128 & 2) == 0)) {
              int _1330 = (((int)(_100 << 8u)) | _100) & 16711935;
              int _1333 = ((_1330 << 4u) | _1330) & 252645135;
              int _1336 = ((_1333 << 2u) | _1333) & 858993459;
              int _1342 = (((int)(SV_DispatchThreadID.y << 8u)) | (int)(SV_DispatchThreadID.y)) & 16711935;
              int _1345 = ((_1342 << 4u) | _1342) & 252645135;
              int _1348 = ((_1345 << 2u) | _1345) & 858993459;
              uint _1361 = ((uint)((((int)(((uint)(CameraCB_220) << 4u) + -1556008596u)) ^ ((int)((uint)(CameraCB_220) + -1640531527u))) ^ (((uint)((uint)(CameraCB_220)) >> 5) + -939442524))) + ((uint)((((_1336 << 1u) | _1336) & 1431655765) | (((int)(((uint)((_1348 << 1u) | _1348)) << 1u)) & -1431655766)));
              uint _1369 = ((uint)((((int)((_1361 << 4u) + -1383041155u)) ^ ((int)(_1361 + -1640531527u))) ^ ((int)(((uint)((uint)(_1361) >> 5)) + 2123724318u)))) + (uint)(CameraCB_220);
              uint _1377 = ((uint)((((int)((_1369 << 4u) + -1556008596u)) ^ ((int)(_1369 + 1013904242u))) ^ (((uint)(_1369) >> 5) + -939442524))) + _1361;
              uint _1385 = ((uint)((((int)((_1377 << 4u) + -1383041155u)) ^ ((int)(_1377 + 1013904242u))) ^ ((int)(((uint)((uint)(_1377) >> 5)) + 2123724318u)))) + _1369;
              uint _1393 = ((uint)((((int)((_1385 << 4u) + -1556008596u)) ^ ((int)(_1385 + -626627285u))) ^ (((uint)(_1385) >> 5) + -939442524))) + _1377;
              uint _1401 = ((uint)((((int)((_1393 << 4u) + -1383041155u)) ^ ((int)(_1393 + -626627285u))) ^ ((int)(((uint)((uint)(_1393) >> 5)) + 2123724318u)))) + _1385;
              uint _1409 = ((uint)((((int)((_1401 << 4u) + -1556008596u)) ^ ((int)(_1401 + 2027808484u))) ^ (((uint)(_1401) >> 5) + -939442524))) + _1393;
              uint _1417 = ((uint)((((int)((_1409 << 4u) + -1383041155u)) ^ ((int)(_1409 + 2027808484u))) ^ ((int)(((uint)((uint)(_1409) >> 5)) + 2123724318u)))) + _1401;
              uint _1425 = ((uint)((((int)((_1417 << 4u) + -1556008596u)) ^ ((int)(_1417 + 387276957u))) ^ (((uint)(_1417) >> 5) + -939442524))) + _1409;
              uint _1433 = ((uint)((((int)((_1425 << 4u) + -1383041155u)) ^ ((int)(_1425 + 387276957u))) ^ ((int)(((uint)((uint)(_1425) >> 5)) + 2123724318u)))) + _1417;
              uint _1441 = ((uint)((((int)((_1433 << 4u) + -1556008596u)) ^ ((int)(_1433 + -1253254570u))) ^ (((uint)(_1433) >> 5) + -939442524))) + _1425;
              uint _1449 = ((uint)((((int)((_1441 << 4u) + -1383041155u)) ^ ((int)(_1441 + -1253254570u))) ^ ((int)(((uint)((uint)(_1441) >> 5)) + 2123724318u)))) + _1433;
              uint _1457 = ((uint)((((int)((_1449 << 4u) + -1556008596u)) ^ ((int)(_1449 + 1401181199u))) ^ (((uint)(_1449) >> 5) + -939442524))) + _1441;
              uint _1465 = ((uint)((((int)((_1457 << 4u) + -1383041155u)) ^ ((int)(_1457 + 1401181199u))) ^ ((int)(((uint)((uint)(_1457) >> 5)) + 2123724318u)))) + _1449;
              uint _1473 = ((uint)((((int)((_1465 << 4u) + -1556008596u)) ^ ((int)(_1465 + -239350328u))) ^ (((uint)(_1465) >> 5) + -939442524))) + _1457;
              uint _1481 = ((uint)((((int)((_1473 << 4u) + -1383041155u)) ^ ((int)(_1473 + -239350328u))) ^ ((int)(((uint)((uint)(_1473) >> 5)) + 2123724318u)))) + _1465;
              uint _1489 = ((uint)((((int)((_1481 << 4u) + -1556008596u)) ^ ((int)(_1481 + -1879881855u))) ^ (((uint)(_1481) >> 5) + -939442524))) + _1473;
              uint _1497 = ((uint)((((int)((_1489 << 4u) + -1383041155u)) ^ ((int)(_1489 + -1879881855u))) ^ ((int)(((uint)((uint)(_1489) >> 5)) + 2123724318u)))) + _1481;
              uint _1505 = ((uint)((((int)((_1497 << 4u) + -1556008596u)) ^ ((int)(_1497 + 774553914u))) ^ (((uint)(_1497) >> 5) + -939442524))) + _1489;
              uint _1513 = ((uint)((((int)((_1505 << 4u) + -1383041155u)) ^ ((int)(_1505 + 774553914u))) ^ ((int)(((uint)((uint)(_1505) >> 5)) + 2123724318u)))) + _1497;
              uint _1521 = ((uint)((((int)((_1513 << 4u) + -1556008596u)) ^ ((int)(_1513 + -865977613u))) ^ (((uint)(_1513) >> 5) + -939442524))) + _1505;
              uint _1529 = ((uint)((((int)((_1521 << 4u) + -1383041155u)) ^ ((int)(_1521 + -865977613u))) ^ ((int)(((uint)((uint)(_1521) >> 5)) + 2123724318u)))) + _1513;
              uint _1537 = ((uint)((((int)((_1529 << 4u) + -1556008596u)) ^ ((int)(_1529 + 1788458156u))) ^ (((uint)(_1529) >> 5) + -939442524))) + _1521;
              uint _1545 = ((uint)((((int)((_1537 << 4u) + -1383041155u)) ^ ((int)(_1537 + 1788458156u))) ^ ((int)(((uint)((uint)(_1537) >> 5)) + 2123724318u)))) + _1529;
              uint _1553 = ((uint)((((int)((_1545 << 4u) + -1556008596u)) ^ ((int)(_1545 + 147926629u))) ^ (((uint)(_1545) >> 5) + -939442524))) + _1537;
              uint _1561 = ((uint)((((int)((_1553 << 4u) + -1383041155u)) ^ ((int)(_1553 + 147926629u))) ^ ((int)(((uint)((uint)(_1553) >> 5)) + 2123724318u)))) + _1545;
              uint _1569 = ((uint)((((int)((_1561 << 4u) + -1556008596u)) ^ ((int)(_1561 + -1492604898u))) ^ (((uint)(_1561) >> 5) + -939442524))) + _1553;
              uint _1577 = ((uint)((((int)((_1569 << 4u) + -1383041155u)) ^ ((int)(_1569 + -1492604898u))) ^ ((int)(((uint)((uint)(_1569) >> 5)) + 2123724318u)))) + _1561;
              uint _1585 = ((uint)((((int)((_1577 << 4u) + -1556008596u)) ^ ((int)(_1577 + 1161830871u))) ^ (((uint)(_1577) >> 5) + -939442524))) + _1569;
              uint _1593 = ((uint)((((int)((_1585 << 4u) + -1383041155u)) ^ ((int)(_1585 + 1161830871u))) ^ ((int)(((uint)((uint)(_1585) >> 5)) + 2123724318u)))) + _1577;
              uint _1601 = ((uint)((((int)((_1593 << 4u) + -1556008596u)) ^ ((int)(_1593 + -478700656u))) ^ (((uint)(_1593) >> 5) + -939442524))) + _1585;
              int _1603 = ((int)(_1601 << 13u)) ^ _1601;
              int _1605 = ((uint)(_1603) >> 17) ^ _1603;
              if (!(cb12_074y > 0.0f)) {
                float _1646 = saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.z) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.z) * _159) + (gridDesc_000[1].PROBE_GRID_DESC_208.z))) + (gridDesc_000[1].PROBE_GRID_DESC_236));
                float _1649 = (_1646 * _1646) * min(saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.x) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.x) * _157) + (gridDesc_000[1].PROBE_GRID_DESC_208.x))) + (gridDesc_000[1].PROBE_GRID_DESC_236)), saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.y) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.y) * _158) + (gridDesc_000[1].PROBE_GRID_DESC_208.y))) + (gridDesc_000[1].PROBE_GRID_DESC_236)));
                float _1680 = saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.z) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.z) * _159) + (gridDesc_000[0].PROBE_GRID_DESC_208.z))) + (gridDesc_000[0].PROBE_GRID_DESC_236));
                float _1683 = (_1680 * _1680) * min(saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.x) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.x) * _157) + (gridDesc_000[0].PROBE_GRID_DESC_208.x))) + (gridDesc_000[0].PROBE_GRID_DESC_236)), saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.y) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.y) * _158) + (gridDesc_000[0].PROBE_GRID_DESC_208.y))) + (gridDesc_000[0].PROBE_GRID_DESC_236)));
                bool _1684 = (_1649 > 9.999999717180685e-10f);
                int _1685 = (int)(uint)(_1684);
                if (_1649 < 1.0f) {
                  bool _1688 = (_1683 > 9.999999717180685e-10f);
                  if (_1684 && _1688) {
                    bool _1693 = (((2.0f - asfloat((((uint)((uint)(((int)(_1605 << 5u)) ^ _1605)) >> 9) | 1065353216))) + _1683) > 0.5f);
                    int _1694 = (int)(uint)(_1693);
                    _1698 = select(_1693, 1.0f, 0.0f);
                    _1699 = _1694;
                    _1700 = (_1694 ^ 1);
                  } else {
                    _1698 = _1649;
                    _1699 = _1685;
                    _1700 = ((int)(uint)(_1688));
                  }
                } else {
                  _1698 = _1649;
                  _1699 = _1685;
                  _1700 = 0;
                }
                if (!(_1699 == 0)) {
                  float _1744 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _70) + _157) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _696);
                  float _1745 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _71) + _158) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _697);
                  float _1746 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _72) + _159) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _698);
                  float _1750 = (_1744 * (gridDesc_000[1].PROBE_GRID_DESC_176.x)) + (gridDesc_000[1].PROBE_GRID_DESC_192.x);
                  float _1751 = (_1745 * (gridDesc_000[1].PROBE_GRID_DESC_176.y)) + (gridDesc_000[1].PROBE_GRID_DESC_192.y);
                  float _1752 = (_1746 * (gridDesc_000[1].PROBE_GRID_DESC_176.z)) + (gridDesc_000[1].PROBE_GRID_DESC_192.z);
                  int _1762 = min(max(int(_1750), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) + -1u)));
                  int _1763 = min(max(int(_1751), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) + -1u)));
                  int _1764 = min(max(int(_1752), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) + -1u)));
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
                    int _1782 = _1779 & 1;
                    int _1783 = ((uint)(_1779) >> 1) & 1;
                    int _1784 = ((uint)(_1779) >> 2) & 1;
                    uint _1785 = _1782 + _1762;
                    uint _1786 = _1783 + _1763;
                    uint _1787 = _1784 + _1764;
                    if (!((int)((int)_1787 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_1785 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) || (int)((int)_1786 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.y)))))) {
                      int _1800 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.x))) + _1785)) % (gridDesc_000[1].PROBE_GRID_DESC_032.x);
                      int _1801 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.y))) + _1786)) % (gridDesc_000[1].PROBE_GRID_DESC_032.y);
                      int _1802 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.z))) + _1787)) % (gridDesc_000[1].PROBE_GRID_DESC_032.z);
                      int _1804 = _1802 + (_1800 * (gridDesc_000[1].PROBE_GRID_DESC_032.z));
                      float4 _1807 = t34[1].Load(int3(_1804, _1801, 0));
                      uint _1810 = t32[1].Load(int3(_1804, _1801, 0));
                      if ((_1810.x & -2) == 2) {
                        float _1829 = ((((_1765 - (gridDesc_000[1].PROBE_GRID_DESC_160.x)) + float((int)(_1782))) + (_1807.x * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.x) - _1744);
                        float _1835 = ((((_1766 - (gridDesc_000[1].PROBE_GRID_DESC_160.y)) + float((int)(_1783))) + (_1807.y * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.y) - _1745);
                        float _1841 = ((((_1767 - (gridDesc_000[1].PROBE_GRID_DESC_160.z)) + float((int)(_1784))) + (_1807.z * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.z) - _1746);
                        float _1847 = sqrt(((_1829 * _1829) + (_1835 * _1835)) + (_1841 * _1841));
                        float _1848 = max(_1847, 9.999999747378752e-06f);
                        float _1849 = _1829 / _1848;
                        float _1850 = _1835 / _1848;
                        float _1851 = _1841 / _1848;
                        float _1852 = -0.0f - _1849;
                        float _1853 = -0.0f - _1850;
                        float _1854 = -0.0f - _1851;
                        float _1859 = (abs(_1853) + abs(_1852)) + abs(_1854);
                        float _1860 = _1852 / _1859;
                        float _1861 = _1853 / _1859;
                        if (!((_1854 / _1859) > 0.0f)) {
                          _1884 = ((1.0f - abs(_1861)) * float((int)(((int)(uint)((int)(_1860 > 0.0f))) - ((int)(uint)((int)(_1860 < 0.0f))))));
                          _1885 = ((1.0f - abs(_1860)) * float((int)(((int)(uint)((int)(_1861 > 0.0f))) - ((int)(uint)((int)(_1861 < 0.0f))))));
                        } else {
                          _1884 = _1860;
                          _1885 = _1861;
                        }
                        float _1886 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_092));
                        float _1889 = (_1886 * 0.5f) / (_1886 + 2.0f);
                        float _1892 = 1.0f / float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.x));
                        float _1893 = 1.0f / float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.y));
                        float _1896 = float((int)(_1800)) + 0.5f;
                        float _1897 = float((int)(_1801)) + 0.5f;
                        float _1904 = float((int)(_1802));
                        float3 _1908 = t30[1].SampleLevel(s7, float3((((_1889 * _1884) + _1896) * _1892), (((_1889 * _1885) + _1897) * _1893), _1904), 0.0f);
                        float _1915 = (abs(_71) + abs(_70)) + abs(_72);
                        float _1916 = _70 / _1915;
                        float _1917 = _71 / _1915;
                        if (!((_72 / _1915) > 0.0f)) {
                          _1940 = ((1.0f - abs(_1917)) * float((int)(((int)(uint)((int)(_1916 > 0.0f))) - ((int)(uint)((int)(_1916 < 0.0f))))));
                          _1941 = ((1.0f - abs(_1916)) * float((int)(((int)(uint)((int)(_1917 > 0.0f))) - ((int)(uint)((int)(_1917 < 0.0f))))));
                        } else {
                          _1940 = _1916;
                          _1941 = _1917;
                        }
                        float _1942 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_088));
                        float _1945 = (_1942 * 0.5f) / (_1942 + 2.0f);
                        float4 _1955 = t28[1].SampleLevel(s7, float3((((_1945 * _1940) + _1896) * _1892), (((_1945 * _1941) + _1897) * _1893), _1904), 0.0f);
                        float _1959 = (gridDesc_000[1].PROBE_GRID_DESC_104) * 0.5f;
                        float _1979 = (select((_1783 != 0), _1769, (1.0f - _1769)) * select((_1782 != 0), _1768, (1.0f - _1768))) * select((_1784 != 0), _1770, (1.0f - _1770));
                        if (_1847 > _1908.x) {
                          float _1985 = abs(_1908.y - (_1908.x * _1908.x));
                          float _1986 = _1847 - _1908.x;
                          _1992 = ((_1985 / (_1985 + (_1986 * _1986))) * _1979);
                        } else {
                          _1992 = _1979;
                        }
                        float _1997 = saturate((dot(float3(_1849, _1850, _1851), float3(_70, _71, _72)) * 0.5f) + 0.5f) * _1992;
                        _2006 = ((_1997 * (pow(_1955.x, _1959))) + _1774);
                        _2007 = ((_1997 * (pow(_1955.y, _1959))) + _1775);
                        _2008 = ((_1997 * (pow(_1955.z, _1959))) + _1776);
                        _2009 = (_1997 + _1777);
                        _2010 = (_1979 + _1778);
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
                    if (!(_2011 == 8)) {
                      _1774 = _2006;
                      _1775 = _2007;
                      _1776 = _2008;
                      _1777 = _2009;
                      _1778 = _2010;
                      _1779 = _2011;
                      continue;
                    }
                    while(true) {
                      if (_2009 > 9.999999747378752e-06f) {
                        float _2014 = _2006 / _2009;
                        float _2015 = _2007 / _2009;
                        float _2016 = _2008 / _2009;
                        _2036 = ((_2014 * _2014) * 3.1415927410125732f);
                        _2037 = ((_2015 * _2015) * 3.1415927410125732f);
                        _2038 = ((_2016 * _2016) * 3.1415927410125732f);
                        _2039 = _2009;
                      } else {
                        if (_2010 > 9.999999747378752e-06f) {
                          float _2026 = _2006 / _2010;
                          float _2027 = _2007 / _2010;
                          float _2028 = _2008 / _2010;
                          _2036 = ((_2026 * _2026) * 3.1415927410125732f);
                          _2037 = ((_2027 * _2027) * 3.1415927410125732f);
                          _2038 = ((_2028 * _2028) * 3.1415927410125732f);
                          _2039 = _2010;
                        } else {
                          _2036 = 0.0f;
                          _2037 = 0.0f;
                          _2038 = 0.0f;
                          _2039 = 0.0f;
                        }
                      }
                      if (!(_2039 < 9.999999747378752e-06f)) {
                        _2042 = _2036;
                        _2043 = _2037;
                        _2044 = _2038;
                        if (!(_1700 == 0)) {
                          _2047 = _2042;
                          _2048 = _2043;
                          _2049 = _2044;
                          _2050 = _1700;
                          _2051 = _1699;
                          _2052 = _1698;
                          float _2098 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _70) + _157) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _696);
                          float _2099 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _71) + _158) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _697);
                          float _2100 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _72) + _159) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _698);
                          float _2104 = (_2098 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
                          float _2105 = (_2099 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
                          float _2106 = (_2100 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
                          int _2116 = min(max(int(_2104), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
                          int _2117 = min(max(int(_2105), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
                          int _2118 = min(max(int(_2106), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
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
                            int _2136 = _2133 & 1;
                            int _2137 = ((uint)(_2133) >> 1) & 1;
                            int _2138 = ((uint)(_2133) >> 2) & 1;
                            uint _2139 = _2136 + _2116;
                            uint _2140 = _2137 + _2117;
                            uint _2141 = _2138 + _2118;
                            if (!((int)((int)_2141 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_2139 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_2140 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
                              int _2154 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _2139)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
                              int _2155 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _2140)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
                              int _2156 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _2141)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
                              uint _2158 = t38.Load(int4(_2154, _2155, _2156, 0));
                              float4 _2164 = t34[0].Load(int3((_2158.x & 511), ((uint)((uint)(_2158.x)) >> 9), 0));
                              uint _2166 = t38.Load(int4(_2154, _2155, _2156, 0));
                              int _2169 = (uint)((uint)(_2166.x)) >> 7;
                              int _2171 = (uint)((uint)(_2166.x)) >> 14;
                              if (!((((_2169 | _2166.x) & 127) | _2171) == 0)) {
                                float _2191 = ((((_2119 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_2136))) + (_2164.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2098);
                                float _2197 = ((((_2120 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_2137))) + (_2164.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2099);
                                float _2203 = ((((_2121 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_2138))) + (_2164.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2100);
                                float _2209 = sqrt(((_2191 * _2191) + (_2197 * _2197)) + (_2203 * _2203));
                                float _2210 = max(_2209, 9.999999747378752e-06f);
                                float _2211 = _2191 / _2210;
                                float _2212 = _2197 / _2210;
                                float _2213 = _2203 / _2210;
                                float _2214 = -0.0f - _2211;
                                float _2215 = -0.0f - _2212;
                                float _2216 = -0.0f - _2213;
                                float _2221 = (abs(_2215) + abs(_2214)) + abs(_2216);
                                float _2222 = _2214 / _2221;
                                float _2223 = _2215 / _2221;
                                if (!((_2216 / _2221) > 0.0f)) {
                                  _2246 = ((1.0f - abs(_2223)) * float((int)(((int)(uint)((int)(_2222 > 0.0f))) - ((int)(uint)((int)(_2222 < 0.0f))))));
                                  _2247 = ((1.0f - abs(_2222)) * float((int)(((int)(uint)((int)(_2223 > 0.0f))) - ((int)(uint)((int)(_2223 < 0.0f))))));
                                } else {
                                  _2246 = _2222;
                                  _2247 = _2223;
                                }
                                float _2248 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                                float _2251 = (_2248 * 0.5f) / (_2248 + 2.0f);
                                float _2254 = float((int)(_2166.x & 127)) + 0.5f;
                                float _2255 = float((int)(_2169 & 127)) + 0.5f;
                                float _2262 = float((int)(_2171));
                                float3 _2266 = t30[0].SampleLevel(s7, float3((((_2251 * _2246) + _2254) * 0.0078125f), (((_2251 * _2247) + _2255) * 0.0078125f), _2262), 0.0f);
                                float _2273 = (abs(_71) + abs(_70)) + abs(_72);
                                float _2274 = _70 / _2273;
                                float _2275 = _71 / _2273;
                                if (!((_72 / _2273) > 0.0f)) {
                                  _2298 = ((1.0f - abs(_2275)) * float((int)(((int)(uint)((int)(_2274 > 0.0f))) - ((int)(uint)((int)(_2274 < 0.0f))))));
                                  _2299 = ((1.0f - abs(_2274)) * float((int)(((int)(uint)((int)(_2275 > 0.0f))) - ((int)(uint)((int)(_2275 < 0.0f))))));
                                } else {
                                  _2298 = _2274;
                                  _2299 = _2275;
                                }
                                float _2300 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                                float _2303 = (_2300 * 0.5f) / (_2300 + 2.0f);
                                float4 _2313 = t28[0].SampleLevel(s7, float3((((_2303 * _2298) + _2254) * 0.0078125f), (((_2303 * _2299) + _2255) * 0.0078125f), _2262), 0.0f);
                                float _2317 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                                float _2337 = (select((_2137 != 0), _2123, (1.0f - _2123)) * select((_2136 != 0), _2122, (1.0f - _2122))) * select((_2138 != 0), _2124, (1.0f - _2124));
                                if (_2209 > _2266.x) {
                                  float _2343 = abs(_2266.y - (_2266.x * _2266.x));
                                  float _2344 = _2209 - _2266.x;
                                  _2350 = ((_2343 / (_2343 + (_2344 * _2344))) * _2337);
                                } else {
                                  _2350 = _2337;
                                }
                                float _2355 = saturate((dot(float3(_2211, _2212, _2213), float3(_70, _71, _72)) * 0.5f) + 0.5f) * _2350;
                                _2364 = ((_2355 * (pow(_2313.x, _2317))) + _2128);
                                _2365 = ((_2355 * (pow(_2313.y, _2317))) + _2129);
                                _2366 = ((_2355 * (pow(_2313.z, _2317))) + _2130);
                                _2367 = (_2355 + _2131);
                                _2368 = (_2337 + _2132);
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
                            if (!(_2369 == 8)) {
                              _2128 = _2364;
                              _2129 = _2365;
                              _2130 = _2366;
                              _2131 = _2367;
                              _2132 = _2368;
                              _2133 = _2369;
                              continue;
                            }
                            while(true) {
                              if (_2367 > 9.999999747378752e-06f) {
                                float _2372 = _2364 / _2367;
                                float _2373 = _2365 / _2367;
                                float _2374 = _2366 / _2367;
                                _2394 = ((_2372 * _2372) * 3.1415927410125732f);
                                _2395 = ((_2373 * _2373) * 3.1415927410125732f);
                                _2396 = ((_2374 * _2374) * 3.1415927410125732f);
                                _2397 = _2367;
                              } else {
                                if (_2368 > 9.999999747378752e-06f) {
                                  float _2384 = _2364 / _2368;
                                  float _2385 = _2365 / _2368;
                                  float _2386 = _2366 / _2368;
                                  _2394 = ((_2384 * _2384) * 3.1415927410125732f);
                                  _2395 = ((_2385 * _2385) * 3.1415927410125732f);
                                  _2396 = ((_2386 * _2386) * 3.1415927410125732f);
                                  _2397 = _2368;
                                } else {
                                  _2394 = 0.0f;
                                  _2395 = 0.0f;
                                  _2396 = 0.0f;
                                  _2397 = 0.0f;
                                }
                              }
                              if (_2397 < 9.999999747378752e-06f) {
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
                        float _2098 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _70) + _157) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _696);
                        float _2099 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _71) + _158) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _697);
                        float _2100 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _72) + _159) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _698);
                        float _2104 = (_2098 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
                        float _2105 = (_2099 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
                        float _2106 = (_2100 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
                        int _2116 = min(max(int(_2104), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
                        int _2117 = min(max(int(_2105), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
                        int _2118 = min(max(int(_2106), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
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
                          int _2136 = _2133 & 1;
                          int _2137 = ((uint)(_2133) >> 1) & 1;
                          int _2138 = ((uint)(_2133) >> 2) & 1;
                          uint _2139 = _2136 + _2116;
                          uint _2140 = _2137 + _2117;
                          uint _2141 = _2138 + _2118;
                          if (!((int)((int)_2141 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_2139 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_2140 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
                            int _2154 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _2139)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
                            int _2155 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _2140)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
                            int _2156 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _2141)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
                            uint _2158 = t38.Load(int4(_2154, _2155, _2156, 0));
                            float4 _2164 = t34[0].Load(int3((_2158.x & 511), ((uint)((uint)(_2158.x)) >> 9), 0));
                            uint _2166 = t38.Load(int4(_2154, _2155, _2156, 0));
                            int _2169 = (uint)((uint)(_2166.x)) >> 7;
                            int _2171 = (uint)((uint)(_2166.x)) >> 14;
                            if (!((((_2169 | _2166.x) & 127) | _2171) == 0)) {
                              float _2191 = ((((_2119 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_2136))) + (_2164.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2098);
                              float _2197 = ((((_2120 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_2137))) + (_2164.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2099);
                              float _2203 = ((((_2121 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_2138))) + (_2164.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2100);
                              float _2209 = sqrt(((_2191 * _2191) + (_2197 * _2197)) + (_2203 * _2203));
                              float _2210 = max(_2209, 9.999999747378752e-06f);
                              float _2211 = _2191 / _2210;
                              float _2212 = _2197 / _2210;
                              float _2213 = _2203 / _2210;
                              float _2214 = -0.0f - _2211;
                              float _2215 = -0.0f - _2212;
                              float _2216 = -0.0f - _2213;
                              float _2221 = (abs(_2215) + abs(_2214)) + abs(_2216);
                              float _2222 = _2214 / _2221;
                              float _2223 = _2215 / _2221;
                              if (!((_2216 / _2221) > 0.0f)) {
                                _2246 = ((1.0f - abs(_2223)) * float((int)(((int)(uint)((int)(_2222 > 0.0f))) - ((int)(uint)((int)(_2222 < 0.0f))))));
                                _2247 = ((1.0f - abs(_2222)) * float((int)(((int)(uint)((int)(_2223 > 0.0f))) - ((int)(uint)((int)(_2223 < 0.0f))))));
                              } else {
                                _2246 = _2222;
                                _2247 = _2223;
                              }
                              float _2248 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                              float _2251 = (_2248 * 0.5f) / (_2248 + 2.0f);
                              float _2254 = float((int)(_2166.x & 127)) + 0.5f;
                              float _2255 = float((int)(_2169 & 127)) + 0.5f;
                              float _2262 = float((int)(_2171));
                              float3 _2266 = t30[0].SampleLevel(s7, float3((((_2251 * _2246) + _2254) * 0.0078125f), (((_2251 * _2247) + _2255) * 0.0078125f), _2262), 0.0f);
                              float _2273 = (abs(_71) + abs(_70)) + abs(_72);
                              float _2274 = _70 / _2273;
                              float _2275 = _71 / _2273;
                              if (!((_72 / _2273) > 0.0f)) {
                                _2298 = ((1.0f - abs(_2275)) * float((int)(((int)(uint)((int)(_2274 > 0.0f))) - ((int)(uint)((int)(_2274 < 0.0f))))));
                                _2299 = ((1.0f - abs(_2274)) * float((int)(((int)(uint)((int)(_2275 > 0.0f))) - ((int)(uint)((int)(_2275 < 0.0f))))));
                              } else {
                                _2298 = _2274;
                                _2299 = _2275;
                              }
                              float _2300 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                              float _2303 = (_2300 * 0.5f) / (_2300 + 2.0f);
                              float4 _2313 = t28[0].SampleLevel(s7, float3((((_2303 * _2298) + _2254) * 0.0078125f), (((_2303 * _2299) + _2255) * 0.0078125f), _2262), 0.0f);
                              float _2317 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                              float _2337 = (select((_2137 != 0), _2123, (1.0f - _2123)) * select((_2136 != 0), _2122, (1.0f - _2122))) * select((_2138 != 0), _2124, (1.0f - _2124));
                              if (_2209 > _2266.x) {
                                float _2343 = abs(_2266.y - (_2266.x * _2266.x));
                                float _2344 = _2209 - _2266.x;
                                _2350 = ((_2343 / (_2343 + (_2344 * _2344))) * _2337);
                              } else {
                                _2350 = _2337;
                              }
                              float _2355 = saturate((dot(float3(_2211, _2212, _2213), float3(_70, _71, _72)) * 0.5f) + 0.5f) * _2350;
                              _2364 = ((_2355 * (pow(_2313.x, _2317))) + _2128);
                              _2365 = ((_2355 * (pow(_2313.y, _2317))) + _2129);
                              _2366 = ((_2355 * (pow(_2313.z, _2317))) + _2130);
                              _2367 = (_2355 + _2131);
                              _2368 = (_2337 + _2132);
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
                          if (!(_2369 == 8)) {
                            _2128 = _2364;
                            _2129 = _2365;
                            _2130 = _2366;
                            _2131 = _2367;
                            _2132 = _2368;
                            _2133 = _2369;
                            continue;
                          }
                          while(true) {
                            if (_2367 > 9.999999747378752e-06f) {
                              float _2372 = _2364 / _2367;
                              float _2373 = _2365 / _2367;
                              float _2374 = _2366 / _2367;
                              _2394 = ((_2372 * _2372) * 3.1415927410125732f);
                              _2395 = ((_2373 * _2373) * 3.1415927410125732f);
                              _2396 = ((_2374 * _2374) * 3.1415927410125732f);
                              _2397 = _2367;
                            } else {
                              if (_2368 > 9.999999747378752e-06f) {
                                float _2384 = _2364 / _2368;
                                float _2385 = _2365 / _2368;
                                float _2386 = _2366 / _2368;
                                _2394 = ((_2384 * _2384) * 3.1415927410125732f);
                                _2395 = ((_2385 * _2385) * 3.1415927410125732f);
                                _2396 = ((_2386 * _2386) * 3.1415927410125732f);
                                _2397 = _2368;
                              } else {
                                _2394 = 0.0f;
                                _2395 = 0.0f;
                                _2396 = 0.0f;
                                _2397 = 0.0f;
                              }
                            }
                            if (_2397 < 9.999999747378752e-06f) {
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
                          break;
                        }
                      }
                      break;
                    }
                    break;
                  }
                } else {
                  _2042 = 0.0f;
                  _2043 = 0.0f;
                  _2044 = 0.0f;
                  if (!(_1700 == 0)) {
                    _2047 = _2042;
                    _2048 = _2043;
                    _2049 = _2044;
                    _2050 = _1700;
                    _2051 = _1699;
                    _2052 = _1698;
                    float _2098 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _70) + _157) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _696);
                    float _2099 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _71) + _158) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _697);
                    float _2100 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _72) + _159) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _698);
                    float _2104 = (_2098 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
                    float _2105 = (_2099 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
                    float _2106 = (_2100 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
                    int _2116 = min(max(int(_2104), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
                    int _2117 = min(max(int(_2105), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
                    int _2118 = min(max(int(_2106), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
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
                      int _2136 = _2133 & 1;
                      int _2137 = ((uint)(_2133) >> 1) & 1;
                      int _2138 = ((uint)(_2133) >> 2) & 1;
                      uint _2139 = _2136 + _2116;
                      uint _2140 = _2137 + _2117;
                      uint _2141 = _2138 + _2118;
                      if (!((int)((int)_2141 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_2139 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_2140 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
                        int _2154 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _2139)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
                        int _2155 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _2140)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
                        int _2156 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _2141)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
                        uint _2158 = t38.Load(int4(_2154, _2155, _2156, 0));
                        float4 _2164 = t34[0].Load(int3((_2158.x & 511), ((uint)((uint)(_2158.x)) >> 9), 0));
                        uint _2166 = t38.Load(int4(_2154, _2155, _2156, 0));
                        int _2169 = (uint)((uint)(_2166.x)) >> 7;
                        int _2171 = (uint)((uint)(_2166.x)) >> 14;
                        if (!((((_2169 | _2166.x) & 127) | _2171) == 0)) {
                          float _2191 = ((((_2119 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_2136))) + (_2164.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _2098);
                          float _2197 = ((((_2120 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_2137))) + (_2164.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _2099);
                          float _2203 = ((((_2121 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_2138))) + (_2164.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _2100);
                          float _2209 = sqrt(((_2191 * _2191) + (_2197 * _2197)) + (_2203 * _2203));
                          float _2210 = max(_2209, 9.999999747378752e-06f);
                          float _2211 = _2191 / _2210;
                          float _2212 = _2197 / _2210;
                          float _2213 = _2203 / _2210;
                          float _2214 = -0.0f - _2211;
                          float _2215 = -0.0f - _2212;
                          float _2216 = -0.0f - _2213;
                          float _2221 = (abs(_2215) + abs(_2214)) + abs(_2216);
                          float _2222 = _2214 / _2221;
                          float _2223 = _2215 / _2221;
                          if (!((_2216 / _2221) > 0.0f)) {
                            _2246 = ((1.0f - abs(_2223)) * float((int)(((int)(uint)((int)(_2222 > 0.0f))) - ((int)(uint)((int)(_2222 < 0.0f))))));
                            _2247 = ((1.0f - abs(_2222)) * float((int)(((int)(uint)((int)(_2223 > 0.0f))) - ((int)(uint)((int)(_2223 < 0.0f))))));
                          } else {
                            _2246 = _2222;
                            _2247 = _2223;
                          }
                          float _2248 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                          float _2251 = (_2248 * 0.5f) / (_2248 + 2.0f);
                          float _2254 = float((int)(_2166.x & 127)) + 0.5f;
                          float _2255 = float((int)(_2169 & 127)) + 0.5f;
                          float _2262 = float((int)(_2171));
                          float3 _2266 = t30[0].SampleLevel(s7, float3((((_2251 * _2246) + _2254) * 0.0078125f), (((_2251 * _2247) + _2255) * 0.0078125f), _2262), 0.0f);
                          float _2273 = (abs(_71) + abs(_70)) + abs(_72);
                          float _2274 = _70 / _2273;
                          float _2275 = _71 / _2273;
                          if (!((_72 / _2273) > 0.0f)) {
                            _2298 = ((1.0f - abs(_2275)) * float((int)(((int)(uint)((int)(_2274 > 0.0f))) - ((int)(uint)((int)(_2274 < 0.0f))))));
                            _2299 = ((1.0f - abs(_2274)) * float((int)(((int)(uint)((int)(_2275 > 0.0f))) - ((int)(uint)((int)(_2275 < 0.0f))))));
                          } else {
                            _2298 = _2274;
                            _2299 = _2275;
                          }
                          float _2300 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                          float _2303 = (_2300 * 0.5f) / (_2300 + 2.0f);
                          float4 _2313 = t28[0].SampleLevel(s7, float3((((_2303 * _2298) + _2254) * 0.0078125f), (((_2303 * _2299) + _2255) * 0.0078125f), _2262), 0.0f);
                          float _2317 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                          float _2337 = (select((_2137 != 0), _2123, (1.0f - _2123)) * select((_2136 != 0), _2122, (1.0f - _2122))) * select((_2138 != 0), _2124, (1.0f - _2124));
                          if (_2209 > _2266.x) {
                            float _2343 = abs(_2266.y - (_2266.x * _2266.x));
                            float _2344 = _2209 - _2266.x;
                            _2350 = ((_2343 / (_2343 + (_2344 * _2344))) * _2337);
                          } else {
                            _2350 = _2337;
                          }
                          float _2355 = saturate((dot(float3(_2211, _2212, _2213), float3(_70, _71, _72)) * 0.5f) + 0.5f) * _2350;
                          _2364 = ((_2355 * (pow(_2313.x, _2317))) + _2128);
                          _2365 = ((_2355 * (pow(_2313.y, _2317))) + _2129);
                          _2366 = ((_2355 * (pow(_2313.z, _2317))) + _2130);
                          _2367 = (_2355 + _2131);
                          _2368 = (_2337 + _2132);
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
                      if (!(_2369 == 8)) {
                        _2128 = _2364;
                        _2129 = _2365;
                        _2130 = _2366;
                        _2131 = _2367;
                        _2132 = _2368;
                        _2133 = _2369;
                        continue;
                      }
                      while(true) {
                        if (_2367 > 9.999999747378752e-06f) {
                          float _2372 = _2364 / _2367;
                          float _2373 = _2365 / _2367;
                          float _2374 = _2366 / _2367;
                          _2394 = ((_2372 * _2372) * 3.1415927410125732f);
                          _2395 = ((_2373 * _2373) * 3.1415927410125732f);
                          _2396 = ((_2374 * _2374) * 3.1415927410125732f);
                          _2397 = _2367;
                        } else {
                          if (_2368 > 9.999999747378752e-06f) {
                            float _2384 = _2364 / _2368;
                            float _2385 = _2365 / _2368;
                            float _2386 = _2366 / _2368;
                            _2394 = ((_2384 * _2384) * 3.1415927410125732f);
                            _2395 = ((_2385 * _2385) * 3.1415927410125732f);
                            _2396 = ((_2386 * _2386) * 3.1415927410125732f);
                            _2397 = _2368;
                          } else {
                            _2394 = 0.0f;
                            _2395 = 0.0f;
                            _2396 = 0.0f;
                            _2397 = 0.0f;
                          }
                        }
                        if (_2397 < 9.999999747378752e-06f) {
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
                float _2417 = select(_2413, 0.0f, _2408);
                float _2418 = select(_2413, 0.0f, _2409);
                float _2419 = select(_2413, 1.0f, _2410);
                int _2420 = _2407 | _2404;
                if ((int)(_2406 < 1.0f) || (int)(_2420 == 0)) {
                  float _2431 = (abs(_71) + abs(_70)) + abs(_72);
                  float _2432 = _70 / _2431;
                  float _2433 = _71 / _2431;
                  if (!((_72 / _2431) > 0.0f)) {
                    _2456 = ((1.0f - abs(_2433)) * float((int)(((int)(uint)((int)(_2432 > 0.0f))) - ((int)(uint)((int)(_2432 < 0.0f))))));
                    _2457 = ((1.0f - abs(_2432)) * float((int)(((int)(uint)((int)(_2433 > 0.0f))) - ((int)(uint)((int)(_2433 < 0.0f))))));
                  } else {
                    _2456 = _2432;
                    _2457 = _2433;
                  }
                  float _2458 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                  float _2461 = (_2458 * 0.5f) / (_2458 + 2.0f);
                  float4 _2471 = t28[0].SampleLevel(s7, float3((((_2461 * _2456) + 0.5f) * 0.0078125f), (((_2461 * _2457) + 0.5f) * 0.0078125f), 0.0f), 0.0f);
                  bool _2480 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
                  float _2481 = select(_2480, 0.0f, (_2471.x * 3.1415927410125732f));
                  float _2482 = select(_2480, 1.0f, (_2471.y * 3.1415927410125732f));
                  float _2483 = select(_2480, 0.0f, (_2471.z * 3.1415927410125732f));
                  _2496 = select((_2420 != 0), _2405, 0.0f);
                  _2497 = (lerp(_2481, _2417, _2406));
                  _2498 = (lerp(_2482, _2418, _2406));
                  _2499 = (lerp(_2483, _2419, _2406));
                } else {
                  _2496 = _2405;
                  _2497 = _2417;
                  _2498 = _2418;
                  _2499 = _2419;
                }
                float _2506 = ((select(_2413, 1.0f, _2401) - _2497) * _2496) + _2497;
                float _2507 = ((select(_2413, 0.0f, _2402) - _2498) * _2496) + _2498;
                float _2508 = ((select(_2413, 0.0f, _2403) - _2499) * _2496) + _2499;
                bool _2513 = ((int)((int)(isnan(_2506)) || (int)(isnan(_2507)))) || (int)(isnan(_2508));
                _2518 = select(_2513, 0.0f, _2506);
                _2519 = select(_2513, 0.0f, _2507);
                _2520 = select(_2513, 0.0f, _2508);
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
            if (!((CustomConstants_128 & 4) == 0)) {
              float _2531 = saturate(dot(float3(_70, _71, _72), float3(cb13_000x, cb13_000y, cb13_000z)));
              if (_2531 > 0.0f) {
                float _2537 = _157 - cb12_000x;
                float _2538 = _158 - cb12_000y;
                float _2541 = (_2537 * _2537) + (_2538 * _2538);
                float _2542 = sqrt(_2541);
                [branch]
                if (_2542 < cb13_035x) {
                  if (!(cb13_034x == 0)) {
                    _2552 = 0;
                    while(true) {
                      float _2557 = _157 - (cb13_raw[((int)(_2552 + 37u))].x);
                      float _2558 = _158 - (cb13_raw[((int)(_2552 + 37u))].y);
                      float _2563 = dot(float2(_2557, _2558), float2((cb13_raw[((int)(_2552 + 42u))].x), (cb13_raw[((int)(_2552 + 42u))].y)));
                      float _2566 = dot(float2(_2557, _2558), float2((cb13_raw[((int)(_2552 + 42u))].z), (cb13_raw[((int)(_2552 + 42u))].w)));
                      if ((int)(_2563 > 0.0f) && (int)(_2566 > 0.0f)) {
                        if (!((int)(_2563 < 1.0f) && (int)(_2566 < 1.0f))) {
                          int _2575 = _2552 + 1;
                          if ((uint)_2575 < (uint)cb13_034x) {
                            _2552 = _2575;
                            continue;
                          } else {
                            _2613 = 1.0f;
                          }
                        } else {
                          if ((int)_2552 > (int)-1) {
                            float _2595 = t19.SampleLevel(s10, float3(_2563, _2566, float((int)(_2552))), 0.0f);
                            float _2602 = saturate((((-0.10000000149011612f - _159) + cb13_036x) + (_2595.x * cb13_035w)) * min(1.0f, (cb13_034z / max(1.0f, (cb13_034w * _2542)))));
                            _2613 = ((1.0f - _2602) + (saturate((cb13_035y + _2542) * cb13_035z) * _2602));
                          } else {
                            _2613 = 1.0f;
                          }
                        }
                      } else {
                        int _2575 = _2552 + 1;
                        if ((uint)_2575 < (uint)cb13_034x) {
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
                float _2618 = cb12_066x * 20.0f;
                float _2629 = _159 - cb12_000z;
                float _2638 = _159 * 0.009999999776482582f;
                float _2641 = _2638 / cb12_066x;
                float _2650 = _2638 / _2618;
                float _2655 = (((cb12_067x + _157) * 0.009999999776482582f) / cb12_066x) - ((_2641 * cb13_000x) / cb13_000z);
                float _2656 = (((cb12_067y + _158) * 0.009999999776482582f) / cb12_066x) - ((_2641 * cb13_000y) / cb13_000z);
                float _2661 = ((((cb12_067x * 20.0f) + _157) * 0.009999999776482582f) / _2618) - ((_2650 * cb13_000x) / cb13_000z);
                float _2662 = ((((cb12_067y * 20.0f) + _158) * 0.009999999776482582f) / _2618) - ((_2650 * cb13_000y) / cb13_000z);
                float _2663 = float((int)(int(trunc(cb12_068x))));
                float4 _2666 = t14.SampleLevel(s14, float3(_2655, _2656, _2663), 1.0f);
                float _2668 = float((int)(int(trunc(cb12_068y))));
                float4 _2669 = t14.SampleLevel(s14, float3(_2655, _2656, _2668), 1.0f);
                float _2673 = ((_2669.x - _2666.x) * cb12_066w) + _2666.x;
                float4 _2674 = t14.SampleLevel(s14, float3(_2661, _2662, _2663), 1.0f);
                float4 _2676 = t14.SampleLevel(s14, float3(_2661, _2662, _2668), 1.0f);
                _2694 = ((_2613 * select(((_51 & 1) != 0), 1.0f, 0.0f)) * (1.0f - (((((_2674.x - _2673) + ((_2676.x - _2674.x) * cb12_066w)) * saturate((sqrt(_2541 + (_2629 * _2629)) + -100.0f) * 0.006666666828095913f)) + _2673) * saturate((cb13_000z + -0.25f) * 10.0f))));
              } else {
                _2694 = 0.0f;
              }
              float _2698 = _157 - cb12_000x;
              float _2699 = _158 - cb12_000y;
              float _2709 = saturate((cb12_219z * _159) + cb12_219w);
              float _2731 = saturate((cb12_219x * sqrt((_2698 * _2698) + (_2699 * _2699))) + cb12_219y);
              float _2745 = _2694 * _2531;
              _2750 = (((((lerp(cb13_062x, cb13_061x, _2709)) - cb13_001x) * _2731) + cb13_001x) * _2745);
              _2751 = (((((lerp(cb13_062y, cb13_061y, _2709)) - cb13_001y) * _2731) + cb13_001y) * _2745);
              _2752 = (((((lerp(cb13_062z, cb13_061z, _2709)) - cb13_001z) * _2731) + cb13_001z) * _2745);
            } else {
              _2750 = 0.0f;
              _2751 = 0.0f;
              _2752 = 0.0f;
            }
            float _2784 = select((cb12_225z <= 0.040449999272823334f), (cb12_225z * 0.07739938050508499f), exp2(log2(abs((cb12_225z + 0.054999999701976776f) * 0.9478673338890076f)) * 2.4000000953674316f));
            float _2785 = dot(float3(_55, _56, _57), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
            if (!(_2785 <= 0.0f)) {
              if (!((int)(_2784 <= 0.0f) || (int)(_2785 >= _2784))) {
                float _2793 = saturate(_2785 / _2784);
                float _2800 = saturate(_2793);
                float _2810 = ((((1.0f - ((_2800 * _2800) * (3.0f - (_2800 * 2.0f)))) * (exp2(log2(_2793) * (1.0f / (max(cb12_225y, 0.0f) + 1.0f))) - _2793)) + _2793) * _2784) / _2785;
                float _2812 = max(_55, max(_56, _57));
                if (_2812 > 0.0f) {
                  _2818 = min(_2810, (1.0f / _2812));
                } else {
                  _2818 = _2810;
                }
                _2823 = (_2818 * _55);
                _2824 = (_2818 * _56);
                _2825 = (_2818 * _57);
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
            float _2830 = (((((cb0_000x * _2518) + _1320) + (cb0_000z * _2750)) + (cb0_004y * night_skylight)) * 0.31830987334251404f) * min(_2823, 0.8999999761581421f);
            float _2832 = (((((cb0_000x * _2519) + _1321) + (cb0_000z * _2751)) + (cb0_004y * night_skylight)) * 0.31830987334251404f) * min(_2824, 0.8999999761581421f);
            float _2834 = (((((cb0_000x * _2520) + _1322) + (cb0_000z * _2752)) + (cb0_004y * night_skylight)) * 0.31830987334251404f) * min(_2825, 0.8999999761581421f);
            if (!((CustomConstants_128 & 8) == 0)) {
              float _2852 = sqrt(((_154 * _154) + (_155 * _155)) + (_156 * _156));
              float _2855 = _156 / _2852;
              float _2857 = min(cb12_042z, max(0.0f, _2852));
              float _2858 = _2857 * 0.0625f;
              float _2859 = _2858 * _2855;
              float _2860 = _2858 * cb12_043x;
              float _2865 = dot(float3(cb12_038x, cb12_038y, cb12_038z), float3((_154 / _2852), (_155 / _2852), _2855));
              float _2873 = (saturate((_2865 + cb12_042x) / (cb12_042x + 1.0f)) * (cb12_043y - cb12_043z)) + cb12_043z;
              if (!(cb12_287z == 0)) {
                _2882 = ((int)(_2865 > 0.0f) && (int)(cb12_287z != 2));
              } else {
                _2882 = true;
              }
              float _2883 = abs(_2865);
              if (_2882) {
                _2890 = saturate((_2857 * 0.0020000000949949026f) + -0.30000001192092896f);
              } else {
                _2890 = 1.0f;
              }
              float _2891 = (_2883 * _2883) * _2890;
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
              float _2917 = ((_2904 - cb12_040x) * _2891) + cb12_040x;
              float _2918 = ((_2905 - cb12_040y) * _2891) + cb12_040y;
              float _2919 = ((_2906 - cb12_040z) * _2891) + cb12_040z;
              if (_2892) {
                _2931 = cb12_045x;
                _2932 = cb12_045y;
                _2933 = cb12_045z;
              } else {
                _2931 = cb12_047x;
                _2932 = cb12_047y;
                _2933 = cb12_047z;
              }
              [branch]
              if (!(!(_2857 >= cb12_048y))) {
                float _2951 = cb12_042y + _153;
                float _2952 = _2873 * _2951;
                float _2953 = _2873 * _2859;
                _3087 = (1.0f - ((((((((((((((((1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 15.0f) + _2952)) + 1.0f))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 16.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 14.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 13.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 12.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 11.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 10.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 9.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 8.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 7.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 6.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 5.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 4.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 3.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, ((_2953 * 2.0f) + _2952)) + 1.0f)))) * (1.0f - saturate(_2860 / (max(0.0f, (_2873 * (_2859 + _2951))) + 1.0f)))));
                _3088 = saturate((_2857 - cb12_048y) * cb12_048z);
              } else {
                _3087 = 1.0f;
                _3088 = 0.0f;
              }
              float _3090 = log2(abs(_3087));
              float _3093 = exp2(_3090 * cb12_042w) * _3088;
              float _3102 = saturate((cb12_190x * _3093) + cb12_190y);
              float _3115 = (cb12_189x - _2917) * _3102;
              float _3116 = (cb12_189y - _2918) * _3102;
              float _3117 = (cb12_189z - _2919) * _3102;
              float _3118 = _3115 + _2917;
              float _3119 = _3116 + _2918;
              float _3120 = _3117 + _2919;
              float _3126 = saturate((((cb12_189w + -1.0f) * saturate((cb12_190z * _3093) + cb12_190w)) + 1.0f) * _3093);
              [branch]
              if (cb12_193x > 0.0f) {
                float _3136 = saturate((cb12_192x * _3093) + cb12_192y);
                _3171 = (((((cb12_191x - _2917) * _3136) - _3115) * cb12_193x) + _3118);
                _3172 = (((((cb12_191y - _2918) * _3136) - _3116) * cb12_193x) + _3119);
                _3173 = (((((cb12_191z - _2919) * _3136) - _3117) * cb12_193x) + _3120);
                _3174 = (((saturate((((cb12_191w + -1.0f) * saturate((cb12_192z * _3093) + cb12_192w)) + 1.0f) * _3093) - _3126) * cb12_193x) + _3126);
              } else {
                _3171 = _3118;
                _3172 = _3119;
                _3173 = _3120;
                _3174 = _3126;
              }
              float _3177 = (exp2(_3090 * cb12_048x) * _3088) * saturate(cb12_046w);
              float _3178 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_2830, _2832, _2834));
              float _3188 = (((_3178 * (lerp(cb12_046x, _2931, _2891))) - _2830) * _3177) + _2830;
              float _3189 = (((_3178 * (lerp(cb12_046y, _2932, _2891))) - _2832) * _3177) + _2832;
              float _3190 = (((_3178 * (lerp(cb12_046z, _2933, _2891))) - _2834) * _3177) + _2834;
              _3201 = (lerp(_3188, _3171, _3174));
              _3202 = (lerp(_3189, _3172, _3174));
              _3203 = (lerp(_3190, _3173, _3174));
            } else {
              _3201 = _2830;
              _3202 = _2832;
              _3203 = _2834;
            }
            u5[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4((_3201 * _62.w), (_3202 * _62.w), (_3203 * _62.w), _74.w);
          }
        }
      }
    }
  }
}
