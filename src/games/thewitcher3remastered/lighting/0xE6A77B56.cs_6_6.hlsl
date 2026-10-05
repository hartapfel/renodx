#include "night_skylight.hlsli"

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


Texture2D<float4> t6 : register(t6);

Texture2D<float4> t7 : register(t7);

Texture2D<float4> t8 : register(t8);

Texture2D<float4> t43 : register(t43);

Texture2DArray<float> t9 : register(t9);

TextureCubeArray<float> t10 : register(t10);

Texture2DArray<float4> t42 : register(t42);

Texture2D<float> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

Texture2D<uint2> t3 : register(t3);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t16 : register(t16);

Texture2DArray<float2> t11 : register(t11);

RWTexture2D<float4> u0 : register(u0);

RWByteAddressBuffer u2 : register(u2);

cbuffer cb12 : register(b12) {
  float4 cb12_raw[341] : packoffset(c0);
};

#define cb12_022x (cb12_raw[22].x)
#define cb12_022y (cb12_raw[22].y)
#define cb12_223x (cb12_raw[223].x)
#define cb12_021x (cb12_raw[21].x)
#define cb12_224y (cb12_raw[224].y)
#define cb12_013x (cb12_raw[13].x)
#define cb12_014y (cb12_raw[14].y)
#define cb12_223y (cb12_raw[223].y)
#define cb12_021y (cb12_raw[21].y)
#define cb12_224x (cb12_raw[224].x)
#define cb12_221x (cb12_raw[221].x)
#define cb12_023x (cb12_raw[23].x)
#define cb12_221y (cb12_raw[221].y)
#define cb12_023y (cb12_raw[23].y)
#define cb12_010z (cb12_raw[10].z)
#define cb12_009x (cb12_raw[9].x)
#define cb12_009y (cb12_raw[9].y)
#define cb12_010x (cb12_raw[10].x)
#define cb12_009z (cb12_raw[9].z)
#define cb12_010y (cb12_raw[10].y)
#define cb12_011x (cb12_raw[11].x)
#define cb12_011y (cb12_raw[11].y)
#define cb12_011z (cb12_raw[11].z)
#define cb12_012x (cb12_raw[12].x)
#define cb12_012y (cb12_raw[12].y)
#define cb12_012z (cb12_raw[12].z)
#define cb12_225z (cb12_raw[225].z)
#define cb12_225y (cb12_raw[225].y)
#define cb12_036y (cb12_raw[36].y)
#define cb12_000x (cb12_raw[0].x)
#define cb12_214w (cb12_raw[214].w)
#define cb12_211x (cb12_raw[211].x)
#define cb12_036x (cb12_raw[36].x)
#define cb12_000y (cb12_raw[0].y)
#define cb12_211y (cb12_raw[211].y)
#define cb12_000z (cb12_raw[0].z)
#define cb12_211z (cb12_raw[211].z)
#define cb12_214x (cb12_raw[214].x)
#define cb12_211w (cb12_raw[211].w)
#define cb12_212x (cb12_raw[212].x)
#define cb12_037z (cb12_raw[37].z)
#define cb12_212y (cb12_raw[212].y)
#define cb12_037y (cb12_raw[37].y)
#define cb12_212z (cb12_raw[212].z)
#define cb12_212w (cb12_raw[212].w)
#define cb12_219z (cb12_raw[219].z)
#define cb12_213x (cb12_raw[213].x)
#define cb12_213y (cb12_raw[213].y)
#define cb12_219x (cb12_raw[219].x)
#define cb12_213z (cb12_raw[213].z)
#define cb12_213w (cb12_raw[213].w)
#define cb12_036w (cb12_raw[36].w)
#define cb12_214y (cb12_raw[214].y)
#define cb12_214z (cb12_raw[214].z)
#define cb12_224z (cb12_raw[224].z)
#define cb12_224w (cb12_raw[224].w)
#define cb12_024x (cb12_raw[24].x)
#define cb12_036z (cb12_raw[36].z)
#define cb12_219w (cb12_raw[219].w)
#define cb12_219y (cb12_raw[219].y)
#define cb12_221z (cb12_raw[221].z)
#define cb12_071x (cb12_raw[71].x)
#define cb12_184z (cb12_raw[184].z)
#define cb12_184w (cb12_raw[184].w)
#define cb12_185z (cb12_raw[185].z)
#define cb12_184x (cb12_raw[184].x)
#define cb12_184y (cb12_raw[184].y)
#define cb12_074x (cb12_raw[74].x)
#define cb12_071y (cb12_raw[71].y)
#define cb12_071z (cb12_raw[71].z)
#define cb12_223w (cb12_raw[223].w)
#define cb12_223z (cb12_raw[223].z)
#define cb12_185x (cb12_raw[185].x)
#define cb12_185y (cb12_raw[185].y)
#define cb12_100x (cb12_raw[100].x)
#define cb12_106x (cb12_raw[106].x)
#define cb12_111x (asint(cb12_raw[111].x))
#define cb12_187x (cb12_raw[187].x)
#define cb12_188x (cb12_raw[188].x)
#define cb12_069z (cb12_raw[69].z)
#define cb12_069x (cb12_raw[69].x)
#define cb12_069y (cb12_raw[69].y)
#define cb12_287w (cb12_raw[287].w)
#define cb12_288x (cb12_raw[288].x)
#define cb12_288y (cb12_raw[288].y)
#define cb12_288z (cb12_raw[288].z)
#define cb12_288w (cb12_raw[288].w)

cbuffer cb13 : register(b13) {
  float4 cb13_raw[3589] : packoffset(c0);
};

#define cb13_001y (cb13_raw[1].y)
#define cb13_066z (cb13_raw[66].z)
#define cb13_002x (cb13_raw[2].x)
#define cb13_000z (cb13_raw[0].z)
#define cb13_067y (asint(cb13_raw[67].y))
#define cb13_066x (cb13_raw[66].x)
#define cb13_000x (cb13_raw[0].x)
#define cb13_000y (cb13_raw[0].y)
#define cb13_002y (cb13_raw[2].y)
#define cb13_061x (cb13_raw[61].x)
#define cb13_064z (cb13_raw[64].z)
#define cb13_061y (cb13_raw[61].y)
#define cb13_064y (cb13_raw[64].y)
#define cb13_061z (cb13_raw[61].z)
#define cb13_062x (cb13_raw[62].x)
#define cb13_062y (cb13_raw[62].y)
#define cb13_062z (cb13_raw[62].z)
#define cb13_001x (cb13_raw[1].x)
#define cb13_066y (cb13_raw[66].y)
#define cb13_001z (cb13_raw[1].z)
#define cb13_067x (cb13_raw[67].x)
#define cb13_064x (cb13_raw[64].x)
#define cb13_064w (cb13_raw[64].w)
#define cb13_066w (cb13_raw[66].w)

cbuffer cb0 : register(b0) {
  float4 CSCustomConstants_000 : packoffset(c000.x);
  float4 CSCustomConstants_016 : packoffset(c001.x);
  float4 CSCustomConstants_032 : packoffset(c002.x);
  float4 CSCustomConstants_048 : packoffset(c003.x);
  float4 CSCustomConstants_064 : packoffset(c004.x);
  float4 CSCustomConstants_080 : packoffset(c005.x);
  float4 CSCustomConstants_096 : packoffset(c006.x);
  float4 CSCustomConstants_112 : packoffset(c007.x);
  float4 CSCustomConstants_128 : packoffset(c008.x);
  float4 CSCustomConstants_144 : packoffset(c009.x);
  float4 CSCustomConstants_160 : packoffset(c010.x);
  float4 CSCustomConstants_176 : packoffset(c011.x);
};

SamplerState s6 : register(s6);

SamplerState s10 : register(s10);

SamplerState s4 : register(s4);

groupshared uint _global_0;
groupshared uint _global_1;
groupshared int _global_2[256];
groupshared int _global_3;
groupshared int _global_4[256];
groupshared int _global_5;

[numthreads(16, 16, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  // New irradiance bypasses c184.xy. CommonConstantsHook supplies a tagged,
  // clock-faded Night Skylight factor in native c185.w padding (normally zero).
  // No injected binding or compute root-signature extension is needed.
  float night_skylight = WitcherNightSkylight(cb12_raw[185].w);

  float _30[4];
  int _33 = int(CSCustomConstants_000.x);
  bool _43 = (CSCustomConstants_144.x > 0.0f);
  uint _48 = SV_GroupThreadID.x + (SV_GroupID.x << 4u);
  uint _49 = SV_GroupThreadID.y + (SV_GroupID.y << 4u);
  uint _51 = (SV_GroupThreadID.y << 4u) + SV_GroupThreadID.x;
  float _53 = t0.Load(int3(_48, _49, 0));
  float _59 = (cb12_022x * _53.x) + cb12_022y;
  int _219;
  int _250;
  bool _251;
  bool _252;
  int _287;
  int _303;
  int _304;
  float _384;
  float _389;
  float _390;
  float _391;
  bool _509;
  bool _510;
  bool _511;
  bool _512;
  bool _526;
  float _570;
  float _571;
  float _572;
  int _612;
  float _613;
  float _614;
  float _615;
  float _616;
  float _617;
  float _618;
  float _619;
  float _620;
  float _621;
  float _656;
  float _657;
  float _658;
  float _696;
  float _697;
  float _698;
  int _714;
  float _734;
  float _735;
  float _834;
  float _915;
  float _916;
  float _917;
  float _918;
  float _919;
  float _920;
  float _1001;
  float _1002;
  float _1003;
  float _1044;
  float _1045;
  float _1046;
  float _1114;
  float _1115;
  float _1116;
  float _1223;
  float _1224;
  float _1225;
  float _1281;
  float _1336;
  float _1337;
  float _1338;
  float _1343;
  float _1344;
  float _1345;
  float _1394;
  float _1395;
  float _1396;
  float _1404;
  float _1405;
  float _1406;
  float _1407;
  float _1408;
  float _1409;
  float _1410;
  float _1411;
  float _1412;
  float _1422;
  float _1428;
  float _1429;
  float _1430;
  float _1431;
  float _1432;
  float _1433;
  float _1473;
  float _1474;
  float _1475;
  float _1476;
  float _1477;
  float _1478;
  int _1479;
  float _1557;
  float _1669;
  float _1670;
  float _1671;
  float _1672;
  float _1752;
  float _1753;
  float _1754;
  float _1755;
  float _1759;
  float _1760;
  float _1761;
  float _1762;
  int _1763;
  float _1806;
  int _1819;
  int _1820;
  float _1858;
  float _1859;
  float _1860;
  float _1865;
  float _1866;
  float _1867;
  float _1869;
  float _1870;
  float _1871;
  float _1872;
  float _1887;
  float _1902;
  float _1911;
  float _2033;
  float _2107;
  float _2108;
  float _2109;
  float _2190;
  float _2191;
  float _2192;
  float _2233;
  float _2234;
  float _2235;
  float _2305;
  float _2306;
  float _2307;
  float _2373;
  float _2374;
  float _2375;
  float _2431;
  float _2486;
  float _2487;
  float _2488;
  float _2493;
  float _2494;
  float _2495;
  float _2543;
  float _2544;
  float _2545;
  float _2556;
  float _2557;
  float _2558;
  float _2559;
  float _2560;
  float _2561;
  float _2578;
  float _2579;
  float _2580;
  float _2669;
  float _2670;
  int _2673;
  float _2674;
  float _2675;
  float _2676;
  float _2677;
  float _2678;
  float _2679;
  float _2680;
  float _2735;
  float _2793;
  float _2794;
  float _2795;
  float _2919;
  float _2920;
  float _2921;
  float _2922;
  float _2923;
  float _2924;
  float _2925;
  float _2965;
  float _2966;
  float _2967;
  float _3013;
  float _3014;
  float _3015;
  float _3016;
  float _3017;
  float _3018;
  float _3019;
  float _3054;
  float _3055;
  float _3056;
  float _3057;
  float _3058;
  float _3059;
  float _3067;
  float _3068;
  float _3069;
  float _3238;
  float _3239;
  float _3240;
  float _3241;
  float _3242;
  float _3243;
  float _3244;
  float _3305;
  float _3316;
  float _3325;
  float _3335;
  int _3355;
  float _3356;
  float _3357;
  float _3358;
  float _3359;
  float _3360;
  float _3361;
  float _3362;
  float _3363;
  float _3364;
  float _3365;
  float _3366;
  float _3367;
  float _3374;
  float _3375;
  float _3376;
  float _3382;
  float _3383;
  float _3384;
  int _3431;
  if (_51 == 0) {
    _global_3 = 0;
    _global_5 = 0;
    _global_0 = 2139095039;
    _global_1 = 0;
  }
  GroupMemoryBarrierWithGroupSync();
  int _64 = asint(_59);
  uint _65; InterlockedMin(_global_0, _64, _65);
  uint _66; InterlockedMax(_global_1, _64, _66);
  GroupMemoryBarrierWithGroupSync();
  float _76 = min(max((1.0f / ((cb12_021x * asfloat(_global_0)) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
  float _86 = min(max((1.0f / ((cb12_021x * asfloat(_global_1)) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
  float _90 = cb12_023x * 0.03125f;
  float _91 = cb12_023y * 0.03125f;
  float _92 = float((uint)SV_GroupID.x);
  float _93 = float((uint)SV_GroupID.y);
  float _94 = _90 - _92;
  float _95 = _91 - _93;
  float _98 = cb12_013x * _90;
  float _101 = cb12_014y * _91;
  float _104 = 1.0f - _94;
  float _105 = _94 + 1.0f;
  float _106 = 1.0f - _95;
  float _107 = _95 + 1.0f;
  float _108 = _98 * _98;
  float _111 = sqrt((_104 * _104) + _108);
  float _112 = (-0.0f - _98) / _111;
  float _113 = _104 / _111;
  float _116 = sqrt((_105 * _105) + _108);
  float _117 = _98 / _116;
  float _118 = _105 / _116;
  float _119 = _101 * _101;
  float _122 = sqrt(_119 + (_106 * _106));
  float _123 = _101 / _122;
  float _124 = _106 / _122;
  float _127 = sqrt(_119 + (_107 * _107));
  float _128 = (-0.0f - _101) / _127;
  float _129 = _107 / _127;
  float _147 = cb12_012x + mad(cb12_010x, -0.0f, 0.0f);
  float _149 = mad(cb12_010y, -0.0f, 0.0f) + cb12_012y;
  float _151 = mad(cb12_010z, -0.0f, 0.0f) + cb12_012z;
  float _153 = mad(cb12_011x, _113, (cb12_009x * _112));
  float _155 = mad(cb12_011y, _113, (cb12_009y * _112));
  float _157 = mad(cb12_011z, _113, (cb12_009z * _112));
  float _159 = -0.0f - dot(float3(_153, _155, _157), float3(_147, _149, _151));
  float _161 = mad(cb12_011x, _118, (cb12_009x * _117));
  float _163 = mad(cb12_011y, _118, (cb12_009y * _117));
  float _165 = mad(cb12_011z, _118, (cb12_009z * _117));
  float _167 = -0.0f - dot(float3(_161, _163, _165), float3(_147, _149, _151));
  float _169 = mad(cb12_011x, _124, mad(cb12_010x, _123, 0.0f));
  float _171 = mad(cb12_011y, _124, mad(cb12_010y, _123, 0.0f));
  float _173 = mad(cb12_011z, _124, mad(cb12_010z, _123, 0.0f));
  float _175 = -0.0f - dot(float3(_169, _171, _173), float3(cb12_012x, cb12_012y, cb12_012z));
  float _177 = mad(cb12_011x, _129, mad(cb12_010x, _128, 0.0f));
  float _179 = mad(cb12_011y, _129, mad(cb12_010y, _128, 0.0f));
  float _181 = mad(cb12_011z, _129, mad(cb12_010z, _128, 0.0f));
  float _183 = -0.0f - dot(float3(_177, _179, _181), float3(cb12_012x, cb12_012y, cb12_012z));
  float _184 = mad(cb12_010x, -0.0f, -0.0f);
  float _187 = mad(cb12_010y, -0.0f, -0.0f);
  float _190 = mad(cb12_010z, -0.0f, -0.0f);
  float _193 = mad(cb12_011x, -1.0f, 0.0f);
  float _194 = mad(cb12_011y, -1.0f, 0.0f);
  float _195 = mad(cb12_011z, -1.0f, 0.0f);
  float _197 = -0.0f - dot(float3(_193, _194, _195), float3((mad(cb12_011x, _86, _184) + cb12_012x), (mad(cb12_011y, _86, _187) + cb12_012y), (mad(cb12_011z, _86, _190) + cb12_012z)));
  float _205 = -0.0f - dot(float3(cb12_011x, cb12_011y, cb12_011z), float3((mad(cb12_011x, _76, _184) + cb12_012x), (mad(cb12_011y, _76, _187) + cb12_012y), (mad(cb12_011z, _76, _190) + cb12_012z)));
  float _213 = -0.0f - dot(float3(cb12_011x, cb12_011y, cb12_011z), float3((mad(cb12_011x, -0.0f, _184) + cb12_012x), (mad(cb12_011y, -0.0f, _187) + cb12_012y), (mad(cb12_011z, -0.0f, _190) + cb12_012z)));
  if ((uint)_51 < (uint)cb13_067y) {
    _219 = _51;
    while(true) {
      uint _220 = _219 * 10;
      float _233 = -0.0f - (cb13_raw[((int)(_220 + 68u))].w);
      if (((int)(((int)(((int)((int)(dot(float4(_153, _155, _157, _159), float4((cb13_raw[((int)(_220 + 68u))].x), (cb13_raw[((int)(_220 + 68u))].y), (cb13_raw[((int)(_220 + 68u))].z), 1.0f)) >= _233) && (int)(dot(float4(_161, _163, _165, _167), float4((cb13_raw[((int)(_220 + 68u))].x), (cb13_raw[((int)(_220 + 68u))].y), (cb13_raw[((int)(_220 + 68u))].z), 1.0f)) >= _233))) && (int)(dot(float4(_169, _171, _173, _175), float4((cb13_raw[((int)(_220 + 68u))].x), (cb13_raw[((int)(_220 + 68u))].y), (cb13_raw[((int)(_220 + 68u))].z), 1.0f)) >= _233))) && (int)(dot(float4(_177, _179, _181, _183), float4((cb13_raw[((int)(_220 + 68u))].x), (cb13_raw[((int)(_220 + 68u))].y), (cb13_raw[((int)(_220 + 68u))].z), 1.0f)) >= _233))) && (int)(dot(float4(_193, _194, _195, _197), float4((cb13_raw[((int)(_220 + 68u))].x), (cb13_raw[((int)(_220 + 68u))].y), (cb13_raw[((int)(_220 + 68u))].z), 1.0f)) >= _233)) {
        bool _245 = (dot(float4(cb12_011x, cb12_011y, cb12_011z, _213), float4((cb13_raw[((int)(_220 + 68u))].x), (cb13_raw[((int)(_220 + 68u))].y), (cb13_raw[((int)(_220 + 68u))].z), 1.0f)) >= _233);
        int _246 = (int)(uint)(_245);
        if (_245) {
          _250 = _246;
          _251 = true;
          _252 = (dot(float4(cb12_011x, cb12_011y, cb12_011z, _205), float4((cb13_raw[((int)(_220 + 68u))].x), (cb13_raw[((int)(_220 + 68u))].y), (cb13_raw[((int)(_220 + 68u))].z), 1.0f)) >= _233);
        } else {
          _250 = _246;
          _251 = false;
          _252 = false;
        }
      } else {
        _250 = 0;
        _251 = false;
        _252 = false;
      }
      int _253 = (int)(uint)(_252);
      if (!(!((cb13_raw[((int)(_220 + 71u))].w) >= 0.800000011920929f))) {
        float _265 = dot(float4(_153, _155, _157, _159), float4((cb13_raw[((int)(_220 + 69u))].x), (cb13_raw[((int)(_220 + 69u))].y), (cb13_raw[((int)(_220 + 69u))].z), 1.0f));
        float _266 = dot(float4(_161, _163, _165, _167), float4((cb13_raw[((int)(_220 + 69u))].x), (cb13_raw[((int)(_220 + 69u))].y), (cb13_raw[((int)(_220 + 69u))].z), 1.0f));
        float _267 = dot(float4(_169, _171, _173, _175), float4((cb13_raw[((int)(_220 + 69u))].x), (cb13_raw[((int)(_220 + 69u))].y), (cb13_raw[((int)(_220 + 69u))].z), 1.0f));
        float _268 = dot(float4(_177, _179, _181, _183), float4((cb13_raw[((int)(_220 + 69u))].x), (cb13_raw[((int)(_220 + 69u))].y), (cb13_raw[((int)(_220 + 69u))].z), 1.0f));
        float _269 = dot(float4(_193, _194, _195, _197), float4((cb13_raw[((int)(_220 + 69u))].x), (cb13_raw[((int)(_220 + 69u))].y), (cb13_raw[((int)(_220 + 69u))].z), 1.0f));
        if (_252) {
          float _273 = -0.0f - (cb13_raw[((int)(_220 + 69u))].w);
          _287 = ((int)(uint)((int)(((int)(((int)(((int)(((int)((int)(_265 >= _273) && (int)(_266 >= _273))) && (int)(_267 >= _273))) && (int)(_268 >= _273))) && (int)(_269 >= _273))) && (int)(dot(float4(cb12_011x, cb12_011y, cb12_011z, _205), float4((cb13_raw[((int)(_220 + 69u))].x), (cb13_raw[((int)(_220 + 69u))].y), (cb13_raw[((int)(_220 + 69u))].z), 1.0f)) >= _273))));
        } else {
          _287 = _253;
        }
        if (_251) {
          float _289 = -0.0f - (cb13_raw[((int)(_220 + 69u))].w);
          _303 = ((int)(uint)((int)(((int)(((int)(((int)(((int)((int)(_265 >= _289) && (int)(_266 >= _289))) && (int)(_267 >= _289))) && (int)(_268 >= _289))) && (int)(_269 >= _289))) && (int)(dot(float4(cb12_011x, cb12_011y, cb12_011z, _213), float4((cb13_raw[((int)(_220 + 69u))].x), (cb13_raw[((int)(_220 + 69u))].y), (cb13_raw[((int)(_220 + 69u))].z), 1.0f)) >= _289))));
          _304 = _287;
        } else {
          _303 = _250;
          _304 = _287;
        }
      } else {
        _303 = _250;
        _304 = _253;
      }
      if (!(_303 == 0)) {
        int _307; InterlockedAdd(_global_5, 1, _307);
        if ((uint)_307 < (uint)256) {
          _global_4[_307] = _219;
        }
        if (!(_304 == 0)) {
          int _314; InterlockedAdd(_global_3, 1, _314);
          if ((uint)_314 < (uint)256) {
            _global_2[_314] = _219;
          }
        }
      }
      uint _319 = _219 + 256u;
      if ((uint)_319 < (uint)cb13_067y) {
        _219 = _319;
        continue;
      }
      break;
    }
  }
  GroupMemoryBarrierWithGroupSync();
  float4 _326 = t1.Load(int3(_48, _49, 0));
  float _336 = (pow(_326.x, 2.200000047683716f));
  float _337 = (pow(_326.y, 2.200000047683716f));
  float _338 = (pow(_326.z, 2.200000047683716f));
  float _350 = select((cb12_225z <= 0.040449999272823334f), (cb12_225z * 0.07739938050508499f), exp2(log2(abs((cb12_225z + 0.054999999701976776f) * 0.9478673338890076f)) * 2.4000000953674316f));
  float _351 = dot(float3(_336, _337, _338), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  if (!(_351 <= 0.0f)) {
    if (!((int)(_350 <= 0.0f) || (int)(_351 >= _350))) {
      float _359 = saturate(_351 / _350);
      float _366 = saturate(_359);
      float _376 = ((((1.0f - ((_366 * _366) * (3.0f - (_366 * 2.0f)))) * (exp2(log2(_359) * (1.0f / (max(cb12_225y, 0.0f) + 1.0f))) - _359)) + _359) * _350) / _351;
      float _378 = max(_336, max(_337, _338));
      if (_378 > 0.0f) {
        _384 = min(_376, (1.0f / _378));
      } else {
        _384 = _376;
      }
      _389 = (_384 * _336);
      _390 = (_384 * _337);
      _391 = (_384 * _338);
    } else {
      _389 = _336;
      _390 = _337;
      _391 = _338;
    }
  } else {
    _389 = 0.0f;
    _390 = 0.0f;
    _391 = 0.0f;
  }
  [branch]
  if (!(_59 >= 1.0f)) {
    float4 _395 = t2.Load(int3(_48, _49, 0));
    float _400 = _395.x + -0.5f;
    float _401 = _395.y + -0.5f;
    float _402 = _395.z + -0.5f;
    float _404 = rsqrt(dot(float3(_400, _401, _402), float3(_400, _401, _402)));
    float _405 = _400 * _404;
    float _406 = _401 * _404;
    float _407 = _402 * _404;
    float _408 = float((uint)_48);
    float _409 = float((uint)_49);
    float _445 = mad(cb12_213w, _53.x, mad(cb12_212w, _409, (cb12_211w * _408))) + cb12_214w;
    float _446 = (mad(cb12_213x, _53.x, mad(cb12_212x, _409, (cb12_211x * _408))) + cb12_214x) / _445;
    float _447 = (mad(cb12_213y, _53.x, mad(cb12_212y, _409, (cb12_211y * _408))) + cb12_214y) / _445;
    float _448 = (mad(cb12_213z, _53.x, mad(cb12_212z, _409, (cb12_211z * _408))) + cb12_214z) / _445;
    float _453 = cb12_000x - _446;
    float _454 = cb12_000y - _447;
    float _455 = cb12_000z - _448;
    float _457 = rsqrt(dot(float3(_453, _454, _455), float3(_453, _454, _455)));
    float _458 = _453 * _457;
    float _459 = _454 * _457;
    float _460 = _455 * _457;
    float _466 = sqrt(((_453 * _453) + (_454 * _454)) + (_455 * _455));
    float4 _476 = t16.Load(int3(_48, _49, 0));
    float4 _479 = t4.Load(int3(_48, _49, 0));
    uint _486 = uint((_479.w * 255.0f) + 0.5f);
    int _487 = _486 & 7;
    float _494 = (pow(_479.x, 2.200000047683716f));
    float _495 = (pow(_479.y, 2.200000047683716f));
    float _496 = (pow(_479.z, 2.200000047683716f));
    if (_487 == 1) {
      bool _502 = ((_486 & 48) != 0);
      bool _504 = ((_486 & 64) != 0);
      if ((_486 & 8) == 0) {
        _509 = _504;
        _510 = false;
        _511 = _502;
        _512 = ((_486 & 80) != 0);
      } else {
        _509 = _504;
        _510 = true;
        _511 = _502;
        _512 = true;
      }
    } else {
      _509 = false;
      _510 = false;
      _511 = false;
      _512 = false;
    }
    float _513 = select(_512, 0.0f, 1.0f);
    uint2 _515 = t3.Load(int3(_48, _49, 0));
    bool _518 = ((_515.y & 64) != 0);
    int _519 = _515.y & 2;
    bool _520 = (_519 != 0);
    if (_518) {
      _526 = (CSCustomConstants_016.y == 1.0f);
    } else {
      _526 = false;
    }
    int _528 = ((int)(uint)(_526)) | int(CSCustomConstants_016.x);
    if ((int)(_326.w > 0.0f) && _510) {
      int _532 = select((CSCustomConstants_000.z > 0.0f), 2, _33);
      if (((int)((int)(CSCustomConstants_032.x > 0.0f) || (int)(CSCustomConstants_032.y > 0.0f))) || (int)(CSCustomConstants_032.z > 0.0f)) {
        float _549 = (CSCustomConstants_080.x * _446) + CSCustomConstants_080.y;
        float _550 = (CSCustomConstants_080.x * _447) + CSCustomConstants_080.z;
        [branch]
        if ((int)(abs(_549 + -0.5f) < 0.5f) && (int)(abs(_550 + -0.5f) < 0.5f)) {
          float2 _562 = t11.SampleLevel(s4, float3(_549, _550, CSCustomConstants_080.w), 0.0f);
          _570 = _562.x;
          _571 = _562.y;
          _572 = sqrt(1.0f - saturate(dot(float2(_562.x, _562.y), float2(_562.x, _562.y))));
        } else {
          _570 = 0.0f;
          _571 = 0.0f;
          _572 = 1.0f;
        }
        float _573 = _570 - _405;
        float _574 = _571 - _406;
        float _575 = _572 - _407;
        float _579 = (_573 * CSCustomConstants_032.x) + _405;
        float _580 = (_574 * CSCustomConstants_032.x) + _406;
        float _581 = (_575 * CSCustomConstants_032.x) + _407;
        float _583 = rsqrt(dot(float3(_579, _580, _581), float3(_579, _580, _581)));
        float _591 = (_573 * CSCustomConstants_032.y) + _405;
        float _592 = (_574 * CSCustomConstants_032.y) + _406;
        float _593 = (_575 * CSCustomConstants_032.y) + _407;
        float _595 = rsqrt(dot(float3(_591, _592, _593), float3(_591, _592, _593)));
        float _603 = (_573 * CSCustomConstants_032.z) + _405;
        float _604 = (_574 * CSCustomConstants_032.z) + _406;
        float _605 = (_575 * CSCustomConstants_032.z) + _407;
        float _607 = rsqrt(dot(float3(_603, _604, _605), float3(_603, _604, _605)));
        _612 = _532;
        _613 = (_583 * _579);
        _614 = (_580 * _583);
        _615 = (_581 * _583);
        _616 = (_595 * _591);
        _617 = (_595 * _592);
        _618 = (_595 * _593);
        _619 = (_607 * _603);
        _620 = (_607 * _604);
        _621 = (_607 * _605);
      } else {
        _612 = _532;
        _613 = _405;
        _614 = _406;
        _615 = _407;
        _616 = _405;
        _617 = _406;
        _618 = _407;
        _619 = _405;
        _620 = _406;
        _621 = _407;
      }
    } else {
      _612 = _33;
      _613 = _405;
      _614 = _406;
      _615 = _407;
      _616 = _405;
      _617 = _406;
      _618 = _407;
      _619 = _405;
      _620 = _406;
      _621 = _407;
    }
    if (_518) {
      _656 = CSCustomConstants_096.y;
      _657 = CSCustomConstants_096.x;
      _658 = _326.w;
    } else {
      if (_520) {
        _656 = cb12_224w;
        _657 = cb12_224z;
        _658 = (float((bool)(uint)(CSCustomConstants_016.w == 0.0f)) * _326.w);
      } else {
        if (_510) {
          _656 = CSCustomConstants_096.w;
          _657 = CSCustomConstants_096.z;
          _658 = _326.w;
        } else {
          if (_511) {
            _656 = CSCustomConstants_112.y;
            _657 = CSCustomConstants_112.x;
            _658 = _326.w;
          } else {
            if (_509) {
              _656 = CSCustomConstants_112.w;
              _657 = CSCustomConstants_112.z;
              _658 = _326.w;
            } else {
              _656 = cb12_224y;
              _657 = cb12_224x;
              _658 = _326.w;
            }
          }
        }
      }
    }
    if (_487 == 3) {
      if ((int)(CSCustomConstants_000.w > 0.0f) && (int)((_486 & 8) != 0)) {
        float4 _666 = u0.Load(int2(_48, _49));
        if (CSCustomConstants_160.x > 0.0f) {
          float _676 = saturate(_476.z);
          float _688 = ((CSCustomConstants_176.y - CSCustomConstants_176.w) * _676) + CSCustomConstants_176.w;
          float _691 = (((lerp(CSCustomConstants_176.z, CSCustomConstants_176.x, _676)) - _688) * saturate(_666.w)) + _688;
          _696 = (_691 * _666.x);
          _697 = (_691 * _666.y);
          _698 = (_691 * _666.z);
        } else {
          _696 = _666.x;
          _697 = _666.y;
          _698 = _666.z;
        }
        u0[int2(_48, _49)] = float4(_696, _697, _698, 1.0f);
        if ((uint)_51 < (uint)256) {
          if ((uint)_51 < (uint)_global_5) {
            _714 = (_global_4[_51]);
          } else {
            _714 = 256;
          }
          u2.Store(((int)(((uint((cb12_024x * _93) + _92) << 8u) + _51) << 2u)), asuint(_714));
        }
      } else {
        float _720 = select(_518, CSCustomConstants_064.z, CSCustomConstants_048.z);
        if (_476.y > 0.0f) {
          if ((_486 & 71) == 65) {
            _734 = cb13_002x;
            _735 = cb13_002y;
          } else {
            _734 = 1.0f;
            _735 = 0.0f;
          }
          float _736 = dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_613, _614, _615));
          [branch]
          if (((_735 + _658) + saturate(_736)) > 0.0f) {
            bool _742 = (_612 == 0);
            [branch]
            if (_742) {
              float _748 = saturate((saturate(dot(float3(_613, _614, _615), float3(cb13_000x, cb13_000y, cb13_000z))) * _734) + _735);
              _915 = _748;
              _916 = _748;
              _917 = _748;
              _918 = _748;
              _919 = _748;
              _920 = _748;
            } else {
              if (_612 == 2) {
                float _761 = saturate(dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_458, _459, _460)) + 0.5f) * exp2(log2(abs(_736)) * cb12_037y);
                float _762 = _761 * _389;
                float _763 = _761 * _390;
                float _764 = _761 * _391;
                _915 = _762;
                _916 = _763;
                _917 = _764;
                _918 = _762;
                _919 = _763;
                _920 = _764;
              } else {
                int _768 = ((int)(uint)((int)(_615 > 0.0f))) << 1u;
                float _770 = float((int)(_768 + -1));
                float _772 = -1.0f / (_770 + _615);
                float _774 = (_614 * _613) * _772;
                float _778 = (((_613 * _613) * _770) * _772) + 1.0f;
                float _779 = _774 * _770;
                float _782 = float((int)(1 - _768)) * _613;
                float _785 = ((_614 * _614) * _772) + _770;
                float _786 = -0.0f - _614;
                float _788 = rsqrt(dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(cb13_000x, cb13_000y, cb13_000z)));
                float _789 = _788 * cb13_000x;
                float _790 = _788 * cb13_000y;
                float _791 = _788 * cb13_000z;
                float _794 = mad(_782, _791, mad(_779, _790, (_789 * _778)));
                float _797 = mad(_786, _791, mad(_785, _790, (_789 * _774)));
                float _800 = mad(_615, _791, mad(_614, _790, (_789 * _613)));
                float _802 = rsqrt(dot(float3(_794, _797, _800), float3(_794, _797, _800)));
                float _805 = _802 * _800;
                float _807 = rsqrt(dot(float3(_458, _459, _460), float3(_458, _459, _460)));
                float _808 = _807 * _458;
                float _809 = _807 * _459;
                float _810 = _807 * _460;
                float _813 = mad(_782, _810, mad(_779, _809, (_808 * _778)));
                float _816 = mad(_786, _810, mad(_785, _809, (_808 * _774)));
                float _819 = mad(_615, _810, mad(_614, _809, (_808 * _613)));
                float _821 = rsqrt(dot(float3(_813, _816, _819), float3(_813, _816, _819)));
                float _824 = _821 * _819;
                float _825 = _395.w * _395.w;
                float _828 = dot(float3((_802 * _794), (_802 * _797), _805), float3((_821 * _813), (_821 * _816), _824)) - (_824 * _805);
                if (_828 > 0.0f) {
                  _834 = (_828 / max(_805, _824));
                } else {
                  _834 = _828;
                }
                float _836 = (_825 * 0.2877933979034424f) + 1.0f;
                float _837 = 1.0f / _836;
                float _841 = ((_834 * _825) + 1.0f) * (_837 * 0.31830987334251404f);
                float _845 = 1.0f - _824;
                float _856 = 1.0f - _805;
                float _869 = _837 * ((_825 * 0.07248824834823608f) + 1.0f);
                float _876 = 1.0f - _869;
                float _891 = max(1.0000000116860974e-07f, (1.0f - ((((_856 * _825) * ((((((_856 * 0.07144299894571304f) + -0.332181453704834f) * _856) + 0.4918818771839142f) * _856) + 0.05710852891206741f)) + 1.0f) / _836))) * (max(1.0000000116860974e-07f, (1.0f - ((((_845 * _825) * ((((((_845 * 0.07144299894571304f) + -0.332181453704834f) * _845) + 0.4918818771839142f) * _845) + 0.05710852891206741f)) + 1.0f) / _836))) * 0.31830987334251404f);
                float _895 = max(1.0000000116860974e-07f, _876);
                float _903 = saturate(dot(float3(_613, _614, _615), float3(cb13_000x, cb13_000y, cb13_000z)));
                float _904 = _903 * (((_891 * (((_389 * _389) * _869) / (1.0f - (_876 * _389)))) / _895) + (_841 * _389));
                float _905 = _903 * (((_891 * (((_390 * _390) * _869) / (1.0f - (_876 * _390)))) / _895) + (_841 * _390));
                float _906 = _903 * (((_891 * (((_391 * _391) * _869) / (1.0f - (_876 * _391)))) / _895) + (_841 * _391));
                bool _907 = (_612 == 1);
                _915 = _904;
                _916 = _905;
                _917 = _906;
                _918 = select(_907, (_904 * 3.1415927410125732f), _904);
                _919 = select(_907, (_905 * 3.1415927410125732f), _905);
                _920 = select(_907, (_906 * 3.1415927410125732f), _906);
              }
            }
            float _924 = 1.0f - _494;
            float _925 = 1.0f - _495;
            float _926 = 1.0f - _496;
            if (cb12_221x > 0.0f) {
              float4 _931 = t43.SampleLevel(s10, float2(_395.w, dot(float3(_613, _614, _615), float3(_458, _459, _460))), 0.0f);
              float _937 = (_931.x * _494) + _931.y;
              float _938 = (_931.x * _495) + _931.y;
              float _939 = (_931.x * _496) + _931.y;
              _1001 = min((_937 / max((1.0f - ((1.0f - _937) * ((_924 * 0.0476190485060215f) + _494))), 0.0010000000474974513f)), 1.0f);
              _1002 = min((_938 / max((1.0f - ((1.0f - _938) * ((_925 * 0.0476190485060215f) + _495))), 0.0010000000474974513f)), 1.0f);
              _1003 = min((_939 / max((1.0f - ((1.0f - _939) * ((_926 * 0.0476190485060215f) + _496))), 0.0010000000474974513f)), 1.0f);
            } else {
              float _965 = cb13_000x + _458;
              float _966 = cb13_000y + _459;
              float _967 = cb13_000z + _460;
              float _969 = rsqrt(dot(float3(_965, _966, _967), float3(_965, _966, _967)));
              float _976 = saturate(1.0f - abs(dot(float3((_969 * _965), (_969 * _966), (_969 * _967)), float3(_458, _459, _460))));
              float _977 = _976 * _976;
              float _987 = ((_977 * _977) * _976) * cb13_066x;
              float _993 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _395.w));
              _1001 = (((_987 * max(0.0f, _924)) / _993) + _494);
              _1002 = (((_987 * max(0.0f, _925)) / _993) + _495);
              _1003 = (((_987 * max(0.0f, _926)) / _993) + _496);
            }
            float _1007 = (1.0f - _1001) * _915;
            float _1008 = (1.0f - _1002) * _916;
            float _1009 = (1.0f - _1003) * _917;
            bool _1011 = ((_612 & -3) == 0);
            float _1015 = select(_1011, (_1007 * 0.31830987334251404f), _1007);
            float _1016 = select(_1011, (_1008 * 0.31830987334251404f), _1008);
            float _1017 = select(_1011, (_1009 * 0.31830987334251404f), _1009);
            [branch]
            if (_658 > 0.0f) {
              if (!(cb12_037z == 0.0f)) {
                float _1029 = dot(float3(_389, _390, _391), float3(0.21250000596046448f, 0.715399980545044f, 0.07209999859333038f));
                if (!_742) {
                  _1044 = saturate(lerp(_1029, _389, cb12_036w));
                  _1045 = saturate(lerp(_1029, _390, cb12_036w));
                  _1046 = saturate(lerp(_1029, _391, cb12_036w));
                } else {
                  _1044 = 1.0f;
                  _1045 = 1.0f;
                  _1046 = 1.0f;
                }
                float _1047 = dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_458, _459, _460));
                float _1061 = ((_658 * 0.31830987334251404f) * exp2(log2(abs(_736)) * cb12_036z)) * (exp2((_1047 + cb12_036y) * -4.328084945678711f) + exp2((_1047 + cb12_036x) * -1.4426950216293335f));
                _1114 = ((_1061 * _1044) + _1015);
                _1115 = ((_1061 * _1045) + _1016);
                _1116 = ((_1061 * _1046) + _1017);
              } else {
                float _1070 = (_736 + 1.0f) * 0.5f;
                float _1071 = -0.0f - _458;
                float _1072 = -0.0f - _459;
                float _1073 = -0.0f - _460;
                float _1076 = (dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_1071, _1072, _1073)) + 1.0f) * 0.5f;
                float _1079 = _1076 * _1076;
                float _1081 = select(_742, 1.0f, _389);
                float _1082 = select(_742, 1.0f, _390);
                float _1083 = select(_742, 1.0f, _391);
                float _1093 = cb12_036y * _658;
                float _1106 = (((_658 * 0.5f) * cb12_036w) * (dot(float3(_613, _614, _615), float3(_1071, _1072, _1073)) + 1.0f)) * ((((_1079 * _1079) - _1070) * cb12_036x) + _1070);
                _1114 = ((((((_1081 * _924) * cb12_036z) - _1015) * _1093) + _1015) + (_1106 * _1081));
                _1115 = ((((((_1082 * _925) * cb12_036z) - _1016) * _1093) + _1016) + (_1106 * _1082));
                _1116 = ((((((_1083 * _926) * cb12_036z) - _1017) * _1093) + _1017) + (_1106 * _1083));
              }
            } else {
              _1114 = _1015;
              _1115 = _1016;
              _1116 = _1017;
            }
            float _1117 = _446 - cb12_000x;
            float _1118 = _447 - cb12_000y;
            float _1128 = saturate((cb12_219z * _448) + cb12_219w);
            float _1150 = saturate((cb12_219x * sqrt((_1117 * _1117) + (_1118 * _1118))) + cb12_219y);
            float _1164 = ((((lerp(cb13_062x, cb13_061x, _1128)) - cb13_001x) * _1150) + cb13_001x) * _476.y;
            float _1166 = ((((lerp(cb13_062y, cb13_061y, _1128)) - cb13_001y) * _1150) + cb13_001y) * _476.y;
            float _1168 = ((((lerp(cb13_062z, cb13_061z, _1128)) - cb13_001z) * _1150) + cb13_001z) * _476.y;
            [branch]
            if (dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_616, _617, _618)) > 0.0f) {
              float _1173 = cb13_000x + _458;
              float _1174 = cb13_000y + _459;
              float _1175 = cb13_000z + _460;
              float _1177 = rsqrt(dot(float3(_1173, _1174, _1175), float3(_1173, _1174, _1175)));
              float _1178 = _1177 * _1173;
              float _1179 = _1177 * _1174;
              float _1180 = _1177 * _1175;
              float _1182 = dot(float3(_616, _617, _618), float3(_458, _459, _460));
              float _1184 = saturate(dot(float3(_616, _617, _618), float3(_1178, _1179, _1180)));
              float _1185 = saturate(dot(float3(_616, _617, _618), float3(cb13_000x, cb13_000y, cb13_000z)));
              float _1186 = _395.w * _395.w;
              float _1187 = _1186 * _1186;
              float _1191 = ((_1184 * _1184) * (_1187 + -1.0f)) + 1.0f;
              float _1195 = abs(_1182);
              float _1196 = CSCustomConstants_048.y - CSCustomConstants_048.x;
              float _1202 = saturate(select((_1196 == 0.0f), 1e+05f, (1.0f / _1196)) * (_466 - CSCustomConstants_048.x));
              float _1203 = max(_720, _494);
              float _1204 = max(_720, _495);
              float _1205 = max(_720, _496);
              if (!_510) {
                _1223 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _494) - _1203) * _1202) + _1203));
                _1224 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _495) - _1204) * _1202) + _1204));
                _1225 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _496) - _1205) * _1202) + _1205));
              } else {
                _1223 = CSCustomConstants_064.x;
                _1224 = CSCustomConstants_064.x;
                _1225 = CSCustomConstants_064.x;
              }
              float _1229 = saturate(1.0f - abs(dot(float3(_1178, _1179, _1180), float3(_458, _459, _460))));
              float _1230 = _1229 * _1229;
              float _1243 = ((_1230 * _1230) * _1229) * cb13_066x;
              float _1249 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _395.w));
              [branch]
              if (cb12_221z > 0.0f) {
                float _1259 = saturate(_1182);
                float _1262 = (_1185 * 2.0f) * _1259;
                _1281 = ((((_1259 + _1185) - _1262) * _1186) + _1262);
              } else {
                float _1267 = 1.0f - _1187;
                _1281 = (((sqrt(((_1195 * _1195) * _1267) + _1187) * _1185) + 9.999999747378752e-05f) + (sqrt(((_1185 * _1185) * _1267) + _1187) * _1195));
              }
              float _1282 = 0.5f / _1281;
              float _1283 = _1282 * (_1187 / ((_1191 * _1191) * 3.1415200233459473f));
              float _1284 = _1283 * (((_1243 * max(0.0f, (_1223 - _494))) / _1249) + _494);
              float _1285 = _1283 * (((_1243 * max(0.0f, (_1224 - _495))) / _1249) + _495);
              float _1286 = _1283 * (((_1243 * max(0.0f, (_1225 - _496))) / _1249) + _496);
              if (cb12_221y > 0.0f) {
                float4 _1293 = t43.SampleLevel(s10, float2(_395.w, dot(float3(_616, _617, _618), float3(_1282, _1282, _1282))), 0.0f);
                float _1299 = (_1293.x * _494) + _1293.y;
                float _1300 = (_1293.x * _495) + _1293.y;
                float _1301 = (_1293.x * _496) + _1293.y;
                _1336 = ((min((_1299 / max((1.0f - ((1.0f - _1299) * ((_924 * 0.0476190485060215f) + _494))), 0.0010000000474974513f)), 1.0f) / max(_1299, 9.999999747378752e-05f)) * _1284);
                _1337 = ((min((_1300 / max((1.0f - ((1.0f - _1300) * ((_925 * 0.0476190485060215f) + _495))), 0.0010000000474974513f)), 1.0f) / max(_1300, 9.999999747378752e-05f)) * _1285);
                _1338 = ((min((_1301 / max((1.0f - ((1.0f - _1301) * ((_926 * 0.0476190485060215f) + _496))), 0.0010000000474974513f)), 1.0f) / max(_1301, 9.999999747378752e-05f)) * _1286);
              } else {
                _1336 = _1284;
                _1337 = _1285;
                _1338 = _1286;
              }
              _1343 = (_1336 * _1185);
              _1344 = (_1337 * _1185);
              _1345 = (_1338 * _1185);
            } else {
              _1343 = 0.0f;
              _1344 = 0.0f;
              _1345 = 0.0f;
            }
            if (!(_528 == 0)) {
              float _1348 = dot(float3(_389, _390, _391), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
              float _1357 = 1.0010000467300415f - _1348;
              float _1389 = saturate(dot(float3(_619, _620, _621), float3(cb13_000x, cb13_000y, cb13_000z))) * (exp2(log2(1.0f - saturate(dot(float3(_619, _620, _621), float3(_458, _459, _460)))) * 5.0f) * _657);
              _1394 = (_1389 * saturate((1.0f - exp2(log2(_1357 - ((_389 - _1348) * _656)) * cb12_223x)) * cb12_223y));
              _1395 = (_1389 * saturate((1.0f - exp2(log2(_1357 - ((_390 - _1348) * _656)) * cb12_223x)) * cb12_223y));
              _1396 = (_1389 * saturate((1.0f - exp2(log2(_1357 - ((_391 - _1348) * _656)) * cb12_223x)) * cb12_223y));
            } else {
              _1394 = 0.0f;
              _1395 = 0.0f;
              _1396 = 0.0f;
            }
            _1404 = ((_1394 + _1343) * _1164);
            _1405 = ((_1395 + _1344) * _1166);
            _1406 = ((_1396 + _1345) * _1168);
            _1407 = (_1164 * _1114);
            _1408 = (_1166 * _1115);
            _1409 = (_1168 * _1116);
            _1410 = _918;
            _1411 = _919;
            _1412 = _920;
          } else {
            _1404 = 0.0f;
            _1405 = 0.0f;
            _1406 = 0.0f;
            _1407 = 0.0f;
            _1408 = 0.0f;
            _1409 = 0.0f;
            _1410 = 0.0f;
            _1411 = 0.0f;
            _1412 = 0.0f;
          }
        } else {
          _1404 = 0.0f;
          _1405 = 0.0f;
          _1406 = 0.0f;
          _1407 = 0.0f;
          _1408 = 0.0f;
          _1409 = 0.0f;
          _1410 = 0.0f;
          _1411 = 0.0f;
          _1412 = 0.0f;
        }
        float _1413 = min(_1410, _476.y);
        float _1414 = min(_1411, _476.y);
        float _1415 = min(_1412, _476.y);
        bool _1417 = (_519 == 0);
        if (_1417) {
          _1422 = cb12_071x;
        } else {
          _1422 = 1.0f;
        }
        int _1423 = _global_3;
        if (!(_1423 == 0)) {
          _1473 = _1407;
          _1474 = _1408;
          _1475 = _1409;
          _1476 = _1404;
          _1477 = _1405;
          _1478 = _1406;
          _1479 = 0;
          while(true) {
            uint _1482 = (_global_2[_1479]) * 10;
            float _1488 = (cb13_raw[((int)(_1482 + 68u))].x) - _446;
            float _1489 = (cb13_raw[((int)(_1482 + 68u))].y) - _447;
            float _1490 = (cb13_raw[((int)(_1482 + 68u))].z) - _448;
            float _1496 = sqrt(((_1488 * _1488) + (_1489 * _1489)) + (_1490 * _1490));
            float _1503 = _1496 / (cb13_raw[((int)(_1482 + 68u))].w);
            float _1504 = _1503 * _1503;
            float _1507 = saturate(1.0f - (_1504 * _1504));
            int _1512 = asint((cb13_raw[((int)(_1482 + 71u))].w));
            bool _1514 = ((_1512 & 1) != 0);
            bool _1516 = ((cb13_raw[((int)(_1482 + 73u))].z) > 0.0f);
            int _1524 = asint((cb13_raw[((int)(_1482 + 77u))].x));
            bool _1526 = ((_1524 & 1) != 0);
            float _1528 = (_1507 * _1507) / (((_1496 * _1496) * (cb13_raw[((int)(_1482 + 73u))].x)) + 1.0f);
            if (_1514) {
              float _1536 = rsqrt(dot(float3(_1488, _1489, _1490), float3(_1488, _1489, _1490)));
              _1557 = (exp2(log2(saturate(((cb13_raw[((int)(_1482 + 72u))].y) * dot(float3((-0.0f - (_1488 * _1536)), (-0.0f - (_1489 * _1536)), (-0.0f - (_1490 * _1536))), float3((cb13_raw[((int)(_1482 + 70u))].x), (cb13_raw[((int)(_1482 + 70u))].y), (cb13_raw[((int)(_1482 + 70u))].z)))) + (cb13_raw[((int)(_1482 + 72u))].z))) * (cb13_raw[((int)(_1482 + 72u))].w)) * _1528);
            } else {
              _1557 = _1528;
            }
            bool _1559 = (_1557 > 0.0f);
            if (((int)(_1516 || _1526)) && _1559) {
              float _1562 = -0.0f - _1488;
              float _1563 = -0.0f - _1489;
              float _1564 = -0.0f - _1490;
              if (_1514) {
                _1759 = mad((((cb13_raw[((int)(_1482 + 75u))].z) * (cb13_raw[((int)(_1482 + 70u))].x)) - ((cb13_raw[((int)(_1482 + 75u))].y) * (cb13_raw[((int)(_1482 + 70u))].y))), _1564, mad((((cb13_raw[((int)(_1482 + 75u))].y) * (cb13_raw[((int)(_1482 + 70u))].z)) - ((cb13_raw[((int)(_1482 + 75u))].w) * (cb13_raw[((int)(_1482 + 70u))].x))), _1563, ((((cb13_raw[((int)(_1482 + 75u))].w) * (cb13_raw[((int)(_1482 + 70u))].y)) - ((cb13_raw[((int)(_1482 + 75u))].z) * (cb13_raw[((int)(_1482 + 70u))].z))) * _1562)));
                _1760 = mad((cb13_raw[((int)(_1482 + 75u))].w), _1564, mad((cb13_raw[((int)(_1482 + 75u))].z), _1563, ((cb13_raw[((int)(_1482 + 75u))].y) * _1562)));
                _1761 = mad((cb13_raw[((int)(_1482 + 70u))].z), _1564, mad((cb13_raw[((int)(_1482 + 70u))].y), _1563, ((cb13_raw[((int)(_1482 + 70u))].x) * _1562)));
                _1762 = (cb13_raw[((int)(_1482 + 75u))].x);
                _1763 = asint((cb13_raw[((int)(_1482 + 77u))].z));
              } else {
                if (_1526) {
                  float _1620 = mad((((cb13_raw[((int)(_1482 + 70u))].x) * (cb13_raw[((int)(_1482 + 72u))].z)) - ((cb13_raw[((int)(_1482 + 70u))].y) * (cb13_raw[((int)(_1482 + 72u))].y))), _1564, mad((((cb13_raw[((int)(_1482 + 70u))].z) * (cb13_raw[((int)(_1482 + 72u))].y)) - ((cb13_raw[((int)(_1482 + 70u))].x) * (cb13_raw[((int)(_1482 + 72u))].w))), _1563, ((((cb13_raw[((int)(_1482 + 70u))].y) * (cb13_raw[((int)(_1482 + 72u))].w)) - ((cb13_raw[((int)(_1482 + 70u))].z) * (cb13_raw[((int)(_1482 + 72u))].z))) * _1562)));
                  float _1623 = mad((cb13_raw[((int)(_1482 + 70u))].z), _1564, mad((cb13_raw[((int)(_1482 + 70u))].y), _1563, ((cb13_raw[((int)(_1482 + 70u))].x) * _1562)));
                  float _1626 = mad((cb13_raw[((int)(_1482 + 72u))].w), _1564, mad((cb13_raw[((int)(_1482 + 72u))].z), _1563, ((cb13_raw[((int)(_1482 + 72u))].y) * _1562)));
                  float _1627 = -0.0f - _1620;
                  float _1628 = -0.0f - _1623;
                  float _1629 = -0.0f - _1626;
                  float _1630 = _1627 / _1496;
                  float _1631 = _1628 / _1496;
                  float _1632 = _1629 / _1496;
                  float _1633 = abs(_1630);
                  float _1634 = abs(_1631);
                  float _1635 = abs(_1632);
                  bool _1639 = (_1633 > max(_1634, _1635));
                  if (!((_1524 & 4) == 0)) {
                    if (_1639) {
                      if (_1630 > 0.0f) {
                        _1669 = _1623;
                        _1670 = _1626;
                        _1671 = _1627;
                        _1672 = (cb13_raw[((int)(_1482 + 75u))].x);
                      } else {
                        _1669 = _1628;
                        _1670 = _1626;
                        _1671 = _1620;
                        _1672 = (cb13_raw[((int)(_1482 + 75u))].y);
                      }
                    } else {
                      if (_1634 > max(_1633, _1635)) {
                        if (_1631 > 0.0f) {
                          _1669 = _1627;
                          _1670 = _1626;
                          _1671 = _1628;
                          _1672 = (cb13_raw[((int)(_1482 + 75u))].z);
                        } else {
                          _1669 = _1620;
                          _1670 = _1626;
                          _1671 = _1623;
                          _1672 = (cb13_raw[((int)(_1482 + 75u))].w);
                        }
                      } else {
                        if (_1632 > 0.0f) {
                          _1669 = _1620;
                          _1670 = _1623;
                          _1671 = _1629;
                          _1672 = (cb13_raw[((int)(_1482 + 76u))].x);
                        } else {
                          _1669 = _1620;
                          _1670 = _1628;
                          _1671 = _1626;
                          _1672 = (cb13_raw[((int)(_1482 + 76u))].y);
                        }
                      }
                    }
                    _1759 = _1669;
                    _1760 = _1670;
                    _1761 = _1671;
                    _1762 = _1672;
                    _1763 = asint((cb13_raw[((int)(_1482 + 77u))].z));
                  } else {
                    if (_1639) {
                      int _1681 = asint((cb13_raw[((int)(_1482 + 77u))].z));
                      if (_1630 > 0.0f) {
                        _1759 = _1623;
                        _1760 = _1626;
                        _1761 = _1627;
                        _1762 = (cb13_raw[((int)(_1482 + 75u))].x);
                        _1763 = _1681;
                      } else {
                        _1759 = _1628;
                        _1760 = _1626;
                        _1761 = _1620;
                        _1762 = (cb13_raw[((int)(_1482 + 75u))].y);
                        _1763 = ((uint)(_1681) >> 10);
                      }
                    } else {
                      if (_1634 > max(_1633, _1635)) {
                        if (_1631 > 0.0f) {
                          _1759 = _1627;
                          _1760 = _1626;
                          _1761 = _1628;
                          _1762 = (cb13_raw[((int)(_1482 + 75u))].z);
                          _1763 = ((uint)((uint)(asint((cb13_raw[((int)(_1482 + 77u))].z)))) >> 20);
                        } else {
                          _1759 = _1620;
                          _1760 = _1626;
                          _1761 = _1623;
                          _1762 = (cb13_raw[((int)(_1482 + 75u))].w);
                          _1763 = asint((cb13_raw[((int)(_1482 + 77u))].w));
                        }
                      } else {
                        int _1708 = asint((cb13_raw[((int)(_1482 + 77u))].w));
                        if (_1632 > 0.0f) {
                          _1759 = _1620;
                          _1760 = _1623;
                          _1761 = _1629;
                          _1762 = (cb13_raw[((int)(_1482 + 76u))].x);
                          _1763 = ((uint)(_1708) >> 10);
                        } else {
                          _1759 = _1620;
                          _1760 = _1628;
                          _1761 = _1626;
                          _1762 = (cb13_raw[((int)(_1482 + 76u))].y);
                          _1763 = ((uint)(_1708) >> 20);
                        }
                      }
                    }
                  }
                } else {
                  float _1716 = _1488 / _1496;
                  float _1717 = _1489 / _1496;
                  float _1718 = _1490 / _1496;
                  float _1719 = abs(_1716);
                  float _1720 = abs(_1717);
                  float _1721 = abs(_1718);
                  if (_1719 > max(_1720, _1721)) {
                    if (_1716 > 0.0f) {
                      _1752 = _1563;
                      _1753 = _1564;
                      _1754 = _1488;
                      _1755 = (cb13_raw[((int)(_1482 + 75u))].x);
                    } else {
                      _1752 = _1489;
                      _1753 = _1564;
                      _1754 = _1562;
                      _1755 = (cb13_raw[((int)(_1482 + 75u))].y);
                    }
                  } else {
                    if (_1720 > max(_1719, _1721)) {
                      if (_1717 > 0.0f) {
                        _1752 = _1488;
                        _1753 = _1564;
                        _1754 = _1489;
                        _1755 = (cb13_raw[((int)(_1482 + 75u))].z);
                      } else {
                        _1752 = _1562;
                        _1753 = _1564;
                        _1754 = _1563;
                        _1755 = (cb13_raw[((int)(_1482 + 75u))].w);
                      }
                    } else {
                      if (_1718 > 0.0f) {
                        _1752 = _1562;
                        _1753 = _1563;
                        _1754 = _1490;
                        _1755 = (cb13_raw[((int)(_1482 + 76u))].x);
                      } else {
                        _1752 = _1562;
                        _1753 = _1489;
                        _1754 = _1564;
                        _1755 = (cb13_raw[((int)(_1482 + 76u))].y);
                      }
                    }
                  }
                  _1759 = _1752;
                  _1760 = _1753;
                  _1761 = _1754;
                  _1762 = _1755;
                  _1763 = asint((cb13_raw[((int)(_1482 + 77u))].z));
                }
              }
              float _1771 = (((_1759 * (cb13_raw[((int)(_1482 + 73u))].y)) / _1761) * 0.5f) + 0.5f;
              float _1772 = 0.5f - ((mad((cb13_raw[((int)(_1482 + 73u))].y), _1760, 0.0f) / _1761) * 0.5f);
              if (_1516) {
                int _1774 = asint(_1762);
                int _1776 = ((uint)(_1774) >> 18) & 4092;
                float _1777 = float((uint)_1776);
                [branch]
                if (!(_1776 == 0)) {
                  float _1798 = t9.SampleLevel(s10, float3((cb13_067x * ((_1771 * _1777) + float((uint)((uint)(((int)(_1774 << 2u)) & 4092))))), (cb13_067x * ((_1772 * _1777) + float((uint)((uint)(((uint)(_1774) >> 8) & 4092))))), float((uint)((uint)((uint)(_1774) >> 30)))), 0.0f);
                  _1806 = saturate(exp2((_1798.x - (_1503 * 0.9900000095367432f)) * 144.26950073242188f));
                } else {
                  _1806 = 1.0f;
                }
              } else {
                _1806 = 1.0f;
              }
              if (_1526) {
                bool _1809 = ((_1524 & 2) != 0);
                if (_1809) {
                  _1819 = (_1763 & 1023);
                  _1820 = 0;
                } else {
                  _1819 = (_1763 & 255);
                  _1820 = (((uint)(_1763) >> 8) & 3);
                }
                float _1824 = floor(cb13_raw[((int)(_1482 + 77u))].y) + float((uint)_1819);
                float4 _1828 = t42.SampleLevel(s10, float3(_1771, _1772, _1824), 0.0f);
                _30[0] = _1828.x;
                _30[1] = _1828.y;
                _30[2] = _1828.z;
                _30[3] = _1828.w;
                if (!((_1524 & 8) == 0)) {
                  float4 _1839 = t42.SampleLevel(s10, float3(_1771, _1772, (_1824 + 1.0f)), 0.0f);
                  float _1844 = frac(cb13_raw[((int)(_1482 + 77u))].y);
                  float _1853 = ((_1839.x - _1828.x) * _1844) + _1828.x;
                  float _1854 = ((_1839.y - _1828.y) * _1844) + _1828.y;
                  float _1855 = ((_1839.z - _1828.z) * _1844) + _1828.z;
                  _30[0] = _1853;
                  _30[1] = _1854;
                  _30[2] = _1855;
                  _30[3] = (lerp(_1828.w, _1839.w, _1844));
                  _1858 = _1855;
                  _1859 = _1854;
                  _1860 = _1853;
                } else {
                  _1858 = _1828.z;
                  _1859 = _1828.y;
                  _1860 = _1828.x;
                }
                if (!_1809) {
                  float _1863 = _30[_1820];
                  _1865 = _1863;
                  _1866 = _1863;
                  _1867 = _1863;
                } else {
                  _1865 = _1860;
                  _1866 = _1859;
                  _1867 = _1858;
                }
                _1869 = _1806;
                _1870 = _1865;
                _1871 = _1866;
                _1872 = _1867;
              } else {
                _1869 = _1806;
                _1870 = 1.0f;
                _1871 = 1.0f;
                _1872 = 1.0f;
              }
            } else {
              _1869 = 1.0f;
              _1870 = 1.0f;
              _1871 = 1.0f;
              _1872 = 1.0f;
            }
            if ((int)((cb13_raw[((int)(_1482 + 74u))].x) > 0.0f) && _1559) {
              float _1878 = t10.SampleLevel(s10, float4(_1488, _1489, _1490, (cb13_raw[((int)(_1482 + 74u))].y)), 0.0f);
              _1887 = (saturate(exp2((_1878.x - (_1503 * 0.9900000095367432f)) * 144.26950073242188f)) * _1869);
            } else {
              _1887 = _1869;
            }
            if ((int)(_476.z == 1.0f) || (int)((_1512 & 2048) != 0)) {
              _1902 = cb12_071y;
            } else {
              _1902 = 0.0f;
            }
            if (((int)(!(_476.z == 1.0f))) || (int)((_1512 & 4096) != 0)) {
              _1911 = cb12_071z;
            } else {
              _1911 = 0.0f;
            }
            float _1914 = (((((cb13_raw[((int)(_1482 + 70u))].w) * (_1887 + -1.0f)) + 1.0f) * _1557) * _1902) * _1911;
            float _1915 = _1914 * _1870;
            float _1916 = _1914 * _1871;
            float _1917 = _1914 * _1872;
            [branch]
            if ((int)(_1917 > 0.0f) || ((int)((int)(_1915 > 0.0f) || (int)(_1916 > 0.0f)))) {
              bool _1929 = ((int)_1512 < (int)0);
              float _1930 = select(_1929, _1422, 1.0f);
              float _1938 = rsqrt(dot(float3(_1488, _1489, _1490), float3(_1488, _1489, _1490)));
              float _1939 = _1938 * _1488;
              float _1940 = _1938 * _1489;
              float _1941 = _1938 * _1490;
              bool _1942 = (_612 == 0);
              [branch]
              if (_1942) {
                float _1946 = saturate(saturate(dot(float3(_613, _614, _615), float3(_1939, _1940, _1941))));
                _2107 = _1946;
                _2108 = _1946;
                _2109 = _1946;
              } else {
                if (_612 == 2) {
                  float _1960 = saturate(dot(float3(_1939, _1940, _1941), float3(_458, _459, _460)) + 0.5f) * exp2(log2(abs(dot(float3(_1939, _1940, _1941), float3(_613, _614, _615)))) * cb12_037y);
                  _2107 = (_1960 * _389);
                  _2108 = (_1960 * _390);
                  _2109 = (_1960 * _391);
                } else {
                  int _1967 = ((int)(uint)((int)(_615 > 0.0f))) << 1u;
                  float _1969 = float((int)(_1967 + -1));
                  float _1971 = -1.0f / (_1969 + _615);
                  float _1973 = (_614 * _613) * _1971;
                  float _1977 = (((_613 * _613) * _1969) * _1971) + 1.0f;
                  float _1978 = _1973 * _1969;
                  float _1981 = float((int)(1 - _1967)) * _613;
                  float _1984 = ((_614 * _614) * _1971) + _1969;
                  float _1985 = -0.0f - _614;
                  float _1987 = rsqrt(dot(float3(_1939, _1940, _1941), float3(_1939, _1940, _1941)));
                  float _1988 = _1987 * _1939;
                  float _1989 = _1987 * _1940;
                  float _1990 = _1987 * _1941;
                  float _1993 = mad(_1981, _1990, mad(_1978, _1989, (_1988 * _1977)));
                  float _1996 = mad(_1985, _1990, mad(_1984, _1989, (_1988 * _1973)));
                  float _1999 = mad(_615, _1990, mad(_614, _1989, (_1988 * _613)));
                  float _2001 = rsqrt(dot(float3(_1993, _1996, _1999), float3(_1993, _1996, _1999)));
                  float _2004 = _2001 * _1999;
                  float _2006 = rsqrt(dot(float3(_458, _459, _460), float3(_458, _459, _460)));
                  float _2007 = _2006 * _458;
                  float _2008 = _2006 * _459;
                  float _2009 = _2006 * _460;
                  float _2012 = mad(_1981, _2009, mad(_1978, _2008, (_2007 * _1977)));
                  float _2015 = mad(_1985, _2009, mad(_1984, _2008, (_2007 * _1973)));
                  float _2018 = mad(_615, _2009, mad(_614, _2008, (_2007 * _613)));
                  float _2020 = rsqrt(dot(float3(_2012, _2015, _2018), float3(_2012, _2015, _2018)));
                  float _2023 = _2020 * _2018;
                  float _2024 = _395.w * _395.w;
                  float _2027 = dot(float3((_2001 * _1993), (_2001 * _1996), _2004), float3((_2020 * _2012), (_2020 * _2015), _2023)) - (_2023 * _2004);
                  if (_2027 > 0.0f) {
                    _2033 = (_2027 / max(_2004, _2023));
                  } else {
                    _2033 = _2027;
                  }
                  float _2035 = (_2024 * 0.2877933979034424f) + 1.0f;
                  float _2036 = 1.0f / _2035;
                  float _2040 = ((_2033 * _2024) + 1.0f) * (_2036 * 0.31830987334251404f);
                  float _2044 = 1.0f - _2023;
                  float _2055 = 1.0f - _2004;
                  float _2068 = _2036 * ((_2024 * 0.07248824834823608f) + 1.0f);
                  float _2075 = 1.0f - _2068;
                  float _2090 = max(1.0000000116860974e-07f, (1.0f - ((((_2055 * _2024) * ((((((_2055 * 0.07144299894571304f) + -0.332181453704834f) * _2055) + 0.4918818771839142f) * _2055) + 0.05710852891206741f)) + 1.0f) / _2035))) * (max(1.0000000116860974e-07f, (1.0f - ((((_2044 * _2024) * ((((((_2044 * 0.07144299894571304f) + -0.332181453704834f) * _2044) + 0.4918818771839142f) * _2044) + 0.05710852891206741f)) + 1.0f) / _2035))) * 0.31830987334251404f);
                  float _2094 = max(1.0000000116860974e-07f, _2075);
                  float _2102 = saturate(dot(float3(_613, _614, _615), float3(_1939, _1940, _1941)));
                  _2107 = (_2102 * (((_2090 * (((_389 * _389) * _2068) / (1.0f - (_2075 * _389)))) / _2094) + (_2040 * _389)));
                  _2108 = (_2102 * (((_2090 * (((_390 * _390) * _2068) / (1.0f - (_2075 * _390)))) / _2094) + (_2040 * _390)));
                  _2109 = (_2102 * (((_2090 * (((_391 * _391) * _2068) / (1.0f - (_2075 * _391)))) / _2094) + (_2040 * _391)));
                }
              }
              float _2113 = 1.0f - _494;
              float _2114 = 1.0f - _495;
              float _2115 = 1.0f - _496;
              if (cb12_221x > 0.0f) {
                float4 _2120 = t43.SampleLevel(s10, float2(_395.w, dot(float3(_613, _614, _615), float3(_458, _459, _460))), 0.0f);
                float _2126 = (_2120.x * _494) + _2120.y;
                float _2127 = (_2120.x * _495) + _2120.y;
                float _2128 = (_2120.x * _496) + _2120.y;
                _2190 = min((_2126 / max((1.0f - ((1.0f - _2126) * ((_2113 * 0.0476190485060215f) + _494))), 0.0010000000474974513f)), 1.0f);
                _2191 = min((_2127 / max((1.0f - ((1.0f - _2127) * ((_2114 * 0.0476190485060215f) + _495))), 0.0010000000474974513f)), 1.0f);
                _2192 = min((_2128 / max((1.0f - ((1.0f - _2128) * ((_2115 * 0.0476190485060215f) + _496))), 0.0010000000474974513f)), 1.0f);
              } else {
                float _2154 = _1939 + _458;
                float _2155 = _1940 + _459;
                float _2156 = _1941 + _460;
                float _2158 = rsqrt(dot(float3(_2154, _2155, _2156), float3(_2154, _2155, _2156)));
                float _2165 = saturate(1.0f - abs(dot(float3((_2158 * _2154), (_2158 * _2155), (_2158 * _2156)), float3(_458, _459, _460))));
                float _2166 = _2165 * _2165;
                float _2176 = ((_2166 * _2166) * _2165) * cb13_066x;
                float _2182 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _395.w));
                _2190 = (((_2176 * max(0.0f, _2113)) / _2182) + _494);
                _2191 = (((_2176 * max(0.0f, _2114)) / _2182) + _495);
                _2192 = (((_2176 * max(0.0f, _2115)) / _2182) + _496);
              }
              float _2196 = (1.0f - _2190) * _2107;
              float _2197 = (1.0f - _2191) * _2108;
              float _2198 = (1.0f - _2192) * _2109;
              bool _2200 = ((_612 & -3) == 0);
              float _2204 = select(_2200, (_2196 * 0.31830987334251404f), _2196);
              float _2205 = select(_2200, (_2197 * 0.31830987334251404f), _2197);
              float _2206 = select(_2200, (_2198 * 0.31830987334251404f), _2198);
              [branch]
              if (_658 > 0.0f) {
                if (!(cb12_037z == 0.0f)) {
                  float _2218 = dot(float3(_389, _390, _391), float3(0.21250000596046448f, 0.715399980545044f, 0.07209999859333038f));
                  if (!_1942) {
                    _2233 = saturate(lerp(_2218, _389, cb12_036w));
                    _2234 = saturate(lerp(_2218, _390, cb12_036w));
                    _2235 = saturate(lerp(_2218, _391, cb12_036w));
                  } else {
                    _2233 = 1.0f;
                    _2234 = 1.0f;
                    _2235 = 1.0f;
                  }
                  float _2236 = dot(float3(_1939, _1940, _1941), float3(_458, _459, _460));
                  float _2251 = ((_658 * 0.31830987334251404f) * exp2(log2(abs(dot(float3(_1939, _1940, _1941), float3(_613, _614, _615)))) * cb12_036z)) * (exp2((_2236 + cb12_036y) * -4.328084945678711f) + exp2((_2236 + cb12_036x) * -1.4426950216293335f));
                  _2305 = ((_2251 * _2233) + _2204);
                  _2306 = ((_2251 * _2234) + _2205);
                  _2307 = ((_2251 * _2235) + _2206);
                } else {
                  float _2261 = (dot(float3(_1939, _1940, _1941), float3(_613, _614, _615)) + 1.0f) * 0.5f;
                  float _2262 = -0.0f - _458;
                  float _2263 = -0.0f - _459;
                  float _2264 = -0.0f - _460;
                  float _2267 = (dot(float3(_1939, _1940, _1941), float3(_2262, _2263, _2264)) + 1.0f) * 0.5f;
                  float _2270 = _2267 * _2267;
                  float _2272 = select(_1942, 1.0f, _389);
                  float _2273 = select(_1942, 1.0f, _390);
                  float _2274 = select(_1942, 1.0f, _391);
                  float _2284 = cb12_036y * _658;
                  float _2297 = (((_658 * 0.5f) * cb12_036w) * (dot(float3(_613, _614, _615), float3(_2262, _2263, _2264)) + 1.0f)) * ((((_2270 * _2270) - _2261) * cb12_036x) + _2261);
                  _2305 = ((((((_2272 * _2113) * cb12_036z) - _2204) * _2284) + _2204) + (_2297 * _2272));
                  _2306 = ((((((_2273 * _2114) * cb12_036z) - _2205) * _2284) + _2205) + (_2297 * _2273));
                  _2307 = ((((((_2274 * _2115) * cb12_036z) - _2206) * _2284) + _2206) + (_2297 * _2274));
                }
              } else {
                _2305 = _2204;
                _2306 = _2205;
                _2307 = _2206;
              }
              float _2311 = (_1915 * _1930) * (cb13_raw[((int)(_1482 + 71u))].x);
              float _2313 = (_1916 * _1930) * (cb13_raw[((int)(_1482 + 71u))].y);
              float _2315 = (_1917 * _1930) * (cb13_raw[((int)(_1482 + 71u))].z);
              [branch]
              if (dot(float3(_1939, _1940, _1941), float3(_616, _617, _618)) > 0.0f) {
                float _2323 = _1939 + _458;
                float _2324 = _1940 + _459;
                float _2325 = _1941 + _460;
                float _2327 = rsqrt(dot(float3(_2323, _2324, _2325), float3(_2323, _2324, _2325)));
                float _2328 = _2327 * _2323;
                float _2329 = _2327 * _2324;
                float _2330 = _2327 * _2325;
                float _2332 = dot(float3(_616, _617, _618), float3(_458, _459, _460));
                float _2334 = saturate(dot(float3(_616, _617, _618), float3(_2328, _2329, _2330)));
                float _2335 = saturate(dot(float3(_616, _617, _618), float3(_1939, _1940, _1941)));
                float _2336 = _395.w * _395.w;
                float _2337 = _2336 * _2336;
                float _2341 = ((_2334 * _2334) * (_2337 + -1.0f)) + 1.0f;
                float _2345 = abs(_2332);
                float _2346 = CSCustomConstants_048.y - CSCustomConstants_048.x;
                float _2352 = saturate(select((_2346 == 0.0f), 1e+05f, (1.0f / _2346)) * (_466 - CSCustomConstants_048.x));
                float _2353 = max(CSCustomConstants_048.z, _494);
                float _2354 = max(CSCustomConstants_048.z, _495);
                float _2355 = max(CSCustomConstants_048.z, _496);
                if (!_510) {
                  _2373 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _494) - _2353) * _2352) + _2353));
                  _2374 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _495) - _2354) * _2352) + _2354));
                  _2375 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _496) - _2355) * _2352) + _2355));
                } else {
                  _2373 = CSCustomConstants_064.x;
                  _2374 = CSCustomConstants_064.x;
                  _2375 = CSCustomConstants_064.x;
                }
                float _2379 = saturate(1.0f - abs(dot(float3(_2328, _2329, _2330), float3(_458, _459, _460))));
                float _2380 = _2379 * _2379;
                float _2393 = ((_2380 * _2380) * _2379) * cb13_066x;
                float _2399 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _395.w));
                [branch]
                if (cb12_221z > 0.0f) {
                  float _2409 = saturate(_2332);
                  float _2412 = (_2335 * 2.0f) * _2409;
                  _2431 = ((((_2409 + _2335) - _2412) * _2336) + _2412);
                } else {
                  float _2417 = 1.0f - _2337;
                  _2431 = (((sqrt(((_2345 * _2345) * _2417) + _2337) * _2335) + 9.999999747378752e-05f) + (sqrt(((_2335 * _2335) * _2417) + _2337) * _2345));
                }
                float _2432 = 0.5f / _2431;
                float _2433 = _2432 * (_2337 / ((_2341 * _2341) * 3.1415200233459473f));
                float _2434 = _2433 * (((_2393 * max(0.0f, (_2373 - _494))) / _2399) + _494);
                float _2435 = _2433 * (((_2393 * max(0.0f, (_2374 - _495))) / _2399) + _495);
                float _2436 = _2433 * (((_2393 * max(0.0f, (_2375 - _496))) / _2399) + _496);
                if (cb12_221y > 0.0f) {
                  float4 _2443 = t43.SampleLevel(s10, float2(_395.w, dot(float3(_616, _617, _618), float3(_2432, _2432, _2432))), 0.0f);
                  float _2449 = (_2443.x * _494) + _2443.y;
                  float _2450 = (_2443.x * _495) + _2443.y;
                  float _2451 = (_2443.x * _496) + _2443.y;
                  _2486 = ((min((_2449 / max((1.0f - ((1.0f - _2449) * ((_2113 * 0.0476190485060215f) + _494))), 0.0010000000474974513f)), 1.0f) / max(_2449, 9.999999747378752e-05f)) * _2434);
                  _2487 = ((min((_2450 / max((1.0f - ((1.0f - _2450) * ((_2114 * 0.0476190485060215f) + _495))), 0.0010000000474974513f)), 1.0f) / max(_2450, 9.999999747378752e-05f)) * _2435);
                  _2488 = ((min((_2451 / max((1.0f - ((1.0f - _2451) * ((_2115 * 0.0476190485060215f) + _496))), 0.0010000000474974513f)), 1.0f) / max(_2451, 9.999999747378752e-05f)) * _2436);
                } else {
                  _2486 = _2434;
                  _2487 = _2435;
                  _2488 = _2436;
                }
                _2493 = (_2486 * _2335);
                _2494 = (_2487 * _2335);
                _2495 = (_2488 * _2335);
              } else {
                _2493 = 0.0f;
                _2494 = 0.0f;
                _2495 = 0.0f;
              }
              if (!(_528 == 0)) {
                float _2498 = dot(float3(_389, _390, _391), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
                float _2506 = 1.0010000467300415f - _2498;
                float _2538 = saturate(dot(float3(_619, _620, _621), float3(_1939, _1940, _1941))) * (exp2(log2(1.0f - saturate(dot(float3(_619, _620, _621), float3(_458, _459, _460)))) * 5.0f) * select((((int)(_510 || _511)) || _1929), 0.0f, (select(_520, cb12_223w, cb12_223z) * _657)));
                _2543 = (_2538 * saturate((1.0f - exp2(log2(_2506 - ((_389 - _2498) * _656)) * cb12_223x)) * cb12_223y));
                _2544 = (_2538 * saturate((1.0f - exp2(log2(_2506 - ((_390 - _2498) * _656)) * cb12_223x)) * cb12_223y));
                _2545 = (_2538 * saturate((1.0f - exp2(log2(_2506 - ((_391 - _2498) * _656)) * cb12_223x)) * cb12_223y));
              } else {
                _2543 = 0.0f;
                _2544 = 0.0f;
                _2545 = 0.0f;
              }
              _2556 = ((_2311 * _2305) + _1473);
              _2557 = ((_2313 * _2306) + _1474);
              _2558 = ((_2315 * _2307) + _1475);
              _2559 = ((_2311 * (_2543 + _2493)) + _1476);
              _2560 = ((_2313 * (_2544 + _2494)) + _1477);
              _2561 = ((_2315 * (_2545 + _2495)) + _1478);
            } else {
              _2556 = _1473;
              _2557 = _1474;
              _2558 = _1475;
              _2559 = _1476;
              _2560 = _1477;
              _2561 = _1478;
            }
            uint _2562 = _1479 + 1u;
            if ((uint)_2562 < (uint)_1423) {
              _1473 = _2556;
              _1474 = _2557;
              _1475 = _2558;
              _1476 = _2559;
              _1477 = _2560;
              _1478 = _2561;
              _1479 = _2562;
              continue;
            }
            while(true) {
              _1428 = _2556;
              _1429 = _2557;
              _1430 = _2558;
              _1431 = _2559;
              _1432 = _2560;
              _1433 = _2561;
              break;
            }
            break;
          }
        } else {
          _1428 = _1407;
          _1429 = _1408;
          _1430 = _1409;
          _1431 = _1404;
          _1432 = _1405;
          _1433 = _1406;
        }
        float _1440 = _446 - cb12_000x;
        float _1441 = _447 - cb12_000y;
        float _1456 = ((cb12_185z + -1.0f) * saturate((cb12_219x * sqrt((_1440 * _1440) + (_1441 * _1441))) + cb12_219y)) + 1.0f;
        float _1459 = cb12_184x - cb12_184y;
        if (!(cb12_074x > 0.0f)) {
          float _2567 = cb12_185x - cb12_185y;
          _2578 = (((_2567 * _1413) + cb12_185y) * _1456);
          _2579 = (((_2567 * _1414) + cb12_185y) * _1456);
          _2580 = (((_2567 * _1415) + cb12_185y) * _1456);
        } else {
          _2578 = 1.0f;
          _2579 = 1.0f;
          _2580 = 1.0f;
        }
        float4 _2583 = t2.Load(int3(((int)(_48 + 1u)), _49, 0));
        float4 _2588 = t2.Load(int3(_48, ((int)(_49 + 1u)), 0));
        float _2592 = _2583.x + -0.5f;
        float _2593 = _2583.y + -0.5f;
        float _2594 = _2583.z + -0.5f;
        float _2596 = rsqrt(dot(float3(_2592, _2593, _2594), float3(_2592, _2593, _2594)));
        float _2600 = _2588.x + -0.5f;
        float _2601 = _2588.y + -0.5f;
        float _2602 = _2588.z + -0.5f;
        float _2604 = rsqrt(dot(float3(_2600, _2601, _2602), float3(_2600, _2601, _2602)));
        float _2617 = CSCustomConstants_144.z * _476.z;
        float _2618 = -0.0f - _458;
        float _2619 = -0.0f - _459;
        float _2620 = -0.0f - _460;
        float _2622 = dot(float3(_2618, _2619, _2620), float3(_616, _617, _618)) * 2.0f;
        float _2626 = _2618 - (_2622 * _616);
        float _2627 = _2619 - (_2622 * _617);
        float _2628 = _2620 - (_2622 * _618);
        float _2629 = _395.w * _395.w;
        float _2633 = min(max(max((_2629 * 10.5f), (log2(acos(min(dot(float3(_405, _406, _407), float3((_2596 * _2592), (_2596 * _2593), (_2596 * _2594))), dot(float3(_405, _406, _407), float3((_2604 * _2600), (_2604 * _2601), (_2604 * _2602))))) * 81.4873275756836f) * 0.625f)), 0.0f), 5.0f);
        bool _2634 = (_615 < 0.0f);
        float _2640 = min(max((1.0f / (1.0f - _615)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
        float _2648 = min(max((1.0f / (_615 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
        float _2652 = select(_2634, ((_613 * 0.5f) * _2640), ((_613 * -0.5f) * _2648)) + 0.5f;
        float _2654 = select(_2634, ((_614 * -0.5f) * _2640), ((_614 * 0.5f) * _2648)) + 0.5f;
        float _2655 = float((bool)_2634);
        if (_43) {
          _2669 = ((_2655 + 0.01515151560306549f) + (_2652 * 0.9696969985961914f));
          _2670 = ((_2654 * 0.9696969985961914f) + 0.01515151560306549f);
        } else {
          _2669 = ((_2655 + 0.1666666716337204f) + (_2652 * 0.6666666269302368f));
          _2670 = ((_2654 * 0.6666666269302368f) + 0.1666666716337204f);
        }
        float _2671 = _2669 * 0.5f;
        _2673 = 1;
        _2674 = 0.0f;
        _2675 = 0.0f;
        _2676 = 0.0f;
        _2677 = 0.0f;
        _2678 = 0.0f;
        _2679 = 0.0f;
        _2680 = 9.999999747378752e-06f;
        while(true) {
          int _2681 = _2673 * 12;
          float _2717 = 1.0f - abs(mad((cb12_raw[(_2681 + 104)].x), _448, mad((cb12_raw[(_2681 + 103)].x), _447, ((cb12_raw[(_2681 + 102)].x) * _446))) + (cb12_raw[(_2681 + 105)].x));
          float _2718 = 1.0f - abs(mad((cb12_raw[(_2681 + 104)].y), _448, mad((cb12_raw[(_2681 + 103)].y), _447, ((cb12_raw[(_2681 + 102)].y) * _446))) + (cb12_raw[(_2681 + 105)].y));
          float _2719 = 1.0f - abs(mad((cb12_raw[(_2681 + 104)].z), _448, mad((cb12_raw[(_2681 + 103)].z), _447, ((cb12_raw[(_2681 + 102)].z) * _446))) + (cb12_raw[(_2681 + 105)].z));
          int _2723 = asint((cb12_raw[(_2681 + 106)].y));
          [branch]
          if (!(_2617 == -1.0f)) {
            _2735 = (select(((_2723 & 1) != 0), 1.0f, _2617) * select(((_2723 & 2) != 0), 1.0f, (1.0f - _2617)));
          } else {
            _2735 = 1.0f;
          }
          if (((int)(((int)((int)(_2717 > 0.0f) && (int)(_2718 > 0.0f))) && (int)(_2719 > 0.0f))) && (int)(_2735 > 0.0f)) {
            float _2763 = ((((_2735 * (1.0f - _2680)) * saturate((cb12_raw[(_2681 + 101)].x) * _2717)) * saturate((cb12_raw[(_2681 + 101)].y) * _2718)) * saturate((cb12_raw[(_2681 + 101)].z) * _2719)) * (cb12_raw[(_2681 + 100)].x);
            float _2766 = _2763 * (cb12_raw[(_2681 + 106)].x);
            float _2770 = float((int)(asint(cb12_raw[(_2681 + 111)].x)));
            float _2772 = (_2770 + _2670) * 0.1428571492433548f;
            if (_43) {
              float4 _2776 = t8.SampleLevel(s6, float2(_2671, _2772), 0.0f);
              _2793 = (_2776.x * _2763);
              _2794 = (_2776.y * _2763);
              _2795 = (_2776.z * _2763);
            } else {
              float4 _2785 = t6.SampleLevel(s6, float2(_2671, _2772), 0.0f);
              _2793 = (_2785.x * _2766);
              _2794 = (_2785.y * _2766);
              _2795 = (_2785.z * _2766);
            }
            float _2843 = 1.0f / mad((cb12_raw[(_2681 + 109)].x), _2628, mad((cb12_raw[(_2681 + 108)].x), _2627, ((cb12_raw[(_2681 + 107)].x) * _2626)));
            float _2844 = 1.0f / mad((cb12_raw[(_2681 + 109)].y), _2628, mad((cb12_raw[(_2681 + 108)].y), _2627, ((cb12_raw[(_2681 + 107)].y) * _2626)));
            float _2845 = 1.0f / mad((cb12_raw[(_2681 + 109)].z), _2628, mad((cb12_raw[(_2681 + 108)].z), _2627, ((cb12_raw[(_2681 + 107)].z) * _2626)));
            float _2846 = _2843 * (mad((cb12_raw[(_2681 + 109)].x), _448, mad((cb12_raw[(_2681 + 108)].x), _447, ((cb12_raw[(_2681 + 107)].x) * _446))) + (cb12_raw[(_2681 + 110)].x));
            float _2847 = _2844 * (mad((cb12_raw[(_2681 + 109)].y), _448, mad((cb12_raw[(_2681 + 108)].y), _447, ((cb12_raw[(_2681 + 107)].y) * _446))) + (cb12_raw[(_2681 + 110)].y));
            float _2848 = _2845 * (mad((cb12_raw[(_2681 + 109)].z), _448, mad((cb12_raw[(_2681 + 108)].z), _447, ((cb12_raw[(_2681 + 107)].z) * _446))) + (cb12_raw[(_2681 + 110)].z));
            float _2862 = min(max((_2843 - _2846), ((-0.0f - _2843) - _2846)), min(max((_2844 - _2847), ((-0.0f - _2844) - _2847)), max((_2845 - _2848), ((-0.0f - _2845) - _2848))));
            float _2867 = (_2862 * _2626) + (_446 - (cb12_raw[(_2681 + 100)].y));
            float _2869 = (_2862 * _2627) + (_447 - (cb12_raw[(_2681 + 100)].z));
            float _2871 = (_2862 * _2628) + (_448 - (cb12_raw[(_2681 + 100)].w));
            float _2873 = rsqrt(dot(float3(_2867, _2869, _2871), float3(_2867, _2869, _2871)));
            float _2874 = _2867 * _2873;
            float _2875 = _2869 * _2873;
            float _2876 = _2871 * _2873;
            bool _2877 = (_2876 < 0.0f);
            float _2883 = min(max((1.0f / (1.0f - _2876)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
            float _2891 = min(max((1.0f / (_2876 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
            float4 _2908 = t7.SampleLevel(s6, float2((((float((bool)_2877) + 0.1666666716337204f) + ((select(_2877, ((_2874 * 0.5f) * _2883), ((_2874 * -0.5f) * _2891)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((_2770 + 0.1666666716337204f) + ((select(_2877, ((_2875 * -0.5f) * _2883), ((_2875 * 0.5f) * _2891)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _2633);
            _2919 = (_2763 + _2680);
            _2920 = (_2793 + _2679);
            _2921 = (_2794 + _2678);
            _2922 = (_2795 + _2677);
            _2923 = ((_2908.x * _2766) + _2676);
            _2924 = ((_2908.y * _2766) + _2675);
            _2925 = ((_2908.z * _2766) + _2674);
          } else {
            _2919 = _2680;
            _2920 = _2679;
            _2921 = _2678;
            _2922 = _2677;
            _2923 = _2676;
            _2924 = _2675;
            _2925 = _2674;
          }
          int _2926 = _2673 + 1;
          bool _2928 = (_2919 < 0.9990000128746033f);
          if ((int)((uint)_2926 < (uint)7) && _2928) {
            _2673 = _2926;
            _2674 = _2925;
            _2675 = _2924;
            _2676 = _2923;
            _2677 = _2922;
            _2678 = _2921;
            _2679 = _2920;
            _2680 = _2919;
            continue;
          }
          [branch]
          if (_2928) {
            float _2935 = cb12_100x * (1.0f - _2919);
            float _2939 = _2935 * cb12_106x;
            float _2942 = float((int)(cb12_111x));
            float _2944 = (_2942 + _2670) * 0.1428571492433548f;
            if (_43) {
              float4 _2948 = t8.SampleLevel(s6, float2(_2671, _2944), 0.0f);
              _2965 = (_2948.x * _2935);
              _2966 = (_2948.y * _2935);
              _2967 = (_2948.z * _2935);
            } else {
              float4 _2957 = t6.SampleLevel(s6, float2(_2671, _2944), 0.0f);
              _2965 = (_2957.x * _2939);
              _2966 = (_2957.y * _2939);
              _2967 = (_2957.z * _2939);
            }
            bool _2971 = (_2628 < 0.0f);
            float _2977 = min(max((1.0f / (1.0f - _2628)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
            float _2985 = min(max((1.0f / (_2628 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
            float4 _3002 = t7.SampleLevel(s6, float2((((float((bool)_2971) + 0.1666666716337204f) + ((select(_2971, ((_2626 * 0.5f) * _2977), ((_2626 * -0.5f) * _2985)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((_2942 + 0.1666666716337204f) + ((select(_2971, ((_2627 * -0.5f) * _2977), ((_2627 * 0.5f) * _2985)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _2633);
            _3013 = (_2935 + _2919);
            _3014 = (_2965 + _2920);
            _3015 = (_2966 + _2921);
            _3016 = (_2967 + _2922);
            _3017 = ((_3002.x * _2939) + _2923);
            _3018 = ((_3002.y * _2939) + _2924);
            _3019 = ((_3002.z * _2939) + _2925);
          } else {
            _3013 = _2919;
            _3014 = _2920;
            _3015 = _2921;
            _3016 = _2922;
            _3017 = _2923;
            _3018 = _2924;
            _3019 = _2925;
          }
          float _3020 = 1.0f / _3013;
          float _3021 = _3020 * _3014;
          float _3022 = _3020 * _3015;
          float _3023 = _3020 * _3016;
          float _3024 = _3020 * _3017;
          float _3025 = _3020 * _3018;
          float _3026 = _3020 * _3019;
          if (!_1417) {
            float _3033 = cb13_064x - cb13_064y;
            float _3040 = cb13_064z - cb13_064w;
            _3054 = (((_3040 * _1413) + cb13_064w) * _3024);
            _3055 = (((_3040 * _1414) + cb13_064w) * _3025);
            _3056 = (((_3040 * _1415) + cb13_064w) * _3026);
            _3057 = (((_3033 * _1413) + cb13_064y) * _3021);
            _3058 = (((_3033 * _1414) + cb13_064y) * _3022);
            _3059 = (((_3033 * _1415) + cb13_064y) * _3023);
          } else {
            _3054 = _3024;
            _3055 = _3025;
            _3056 = _3026;
            _3057 = _3021;
            _3058 = _3022;
            _3059 = _3023;
          }
          if (_43) {
            if (_510) {
              _3067 = (_3057 * CSCustomConstants_144.w);
              _3068 = (_3058 * CSCustomConstants_144.w);
              _3069 = (_3059 * CSCustomConstants_144.w);
            } else {
              _3067 = _3057;
              _3068 = _3058;
              _3069 = _3059;
            }
            float _3071 = abs(dot(float3(_613, _614, _615), float3(_458, _459, _460)));
            float _3075 = saturate(1.0f - abs(max(_3071, _3071)));
            float _3076 = _3075 * _3075;
            float _3079 = 1.0f - _395.w;
            float _3082 = 1.0f - _494;
            float _3083 = 1.0f - _495;
            float _3084 = 1.0f - _496;
            float _3085 = max(0.0f, _3082);
            float _3086 = max(0.0f, _3083);
            float _3087 = max(0.0f, _3084);
            float _3090 = ((_3076 * _3076) * _3075) * min(_513, cb13_066y);
            float _3096 = (cb13_066w + 1.0f) - (cb13_066w * _3079);
            float _3100 = _3082 - ((_3090 * _3085) / _3096);
            float _3101 = _3083 - ((_3090 * _3086) / _3096);
            float _3102 = _3084 - ((_3087 * _3090) / _3096);
            if (CSCustomConstants_144.y > 0.0f) {
              int _3106 = ((int)(uint)((int)(_407 > 0.0f))) << 1u;
              float _3108 = float((int)(_3106 + -1));
              float _3110 = -1.0f / (_3108 + _407);
              float _3111 = _3110 * _406;
              float _3112 = _3111 * _405;
              float _3125 = rsqrt(dot(float3(_458, _459, _460), float3(_458, _459, _460)));
              float _3126 = _3125 * _458;
              float _3127 = _3125 * _459;
              float _3128 = _3125 * _460;
              float _3131 = mad((float((int)(1 - _3106)) * _405), _3128, mad((_3112 * _3108), _3127, (_3126 * ((((_405 * _405) * _3110) * _3108) + 1.0f))));
              float _3134 = mad((-0.0f - _406), _3128, mad((_3108 + (_3111 * _406)), _3127, (_3126 * _3112)));
              float _3137 = mad(_407, _3128, mad(_406, _3127, (_3126 * _405)));
              float _3142 = (_2629 * 0.2877933979034424f) + 1.0f;
              float _3144 = 1.0f - (rsqrt(dot(float3(_3131, _3134, _3137), float3(_3131, _3134, _3137))) * _3137);
              float _3154 = (((_3144 * _2629) * ((((((_3144 * 0.07144299894571304f) + -0.332181453704834f) * _3144) + 0.4918818771839142f) * _3144) + 0.05710852891206741f)) + 1.0f) / _3142;
              float _3157 = (1.0f / _3142) * ((_2629 * 0.07248824834823608f) + 1.0f);
              float _3164 = 1.0f - _3157;
              float _3177 = 1.0f - _3154;
              _3238 = _3087;
              _3239 = _3086;
              _3240 = _3085;
              _3241 = _3079;
              _3242 = ((_3100 * _3067) * (((((_389 * _389) * _3157) / (1.0f - (_3164 * _389))) * _3177) + (_3154 * _389)));
              _3243 = ((_3101 * _3068) * (((((_390 * _390) * _3157) / (1.0f - (_3164 * _390))) * _3177) + (_3154 * _390)));
              _3244 = ((_3102 * _3069) * (((((_391 * _391) * _3157) / (1.0f - (_3164 * _391))) * _3177) + (_3154 * _391)));
            } else {
              _3238 = _3087;
              _3239 = _3086;
              _3240 = _3085;
              _3241 = _3079;
              _3242 = ((_3100 * _3067) * _389);
              _3243 = ((_3101 * _3068) * _390);
              _3244 = ((_3102 * _3069) * _391);
            }
          } else {
            float _3202 = abs(dot(float3(_613, _614, _615), float3(_458, _459, _460)));
            float _3206 = saturate(1.0f - abs(max(_3202, _3202)));
            float _3207 = _3206 * _3206;
            float _3210 = 1.0f - _395.w;
            float _3213 = 1.0f - _494;
            float _3214 = 1.0f - _495;
            float _3215 = 1.0f - _496;
            float _3216 = max(0.0f, _3213);
            float _3217 = max(0.0f, _3214);
            float _3218 = max(0.0f, _3215);
            float _3221 = ((_3207 * _3207) * _3206) * min(_513, cb13_066y);
            float _3227 = (cb13_066w + 1.0f) - (cb13_066w * _3210);
            _3238 = _3218;
            _3239 = _3217;
            _3240 = _3216;
            _3241 = _3210;
            _3242 = (((_1456 * ((_1459 * _1413) + cb12_184y)) * _3057) * (_3213 - ((_3221 * _3216) / _3227)));
            _3243 = (((_1456 * ((_1459 * _1414) + cb12_184y)) * _3058) * (_3214 - ((_3221 * _3217) / _3227)));
            _3244 = (((_1456 * ((_1459 * _1415) + cb12_184y)) * _3059) * (_3215 - ((_3218 * _3221) / _3227)));
          }
          float _3249 = abs(dot(float3(_616, _617, _618), float3(_458, _459, _460)));
          float _3253 = saturate(1.0f - abs(max(_3249, _3249)));
          float _3254 = _3253 * _3253;
          float _3261 = ((_3254 * _3254) * _3253) * min(_513, cb13_066y);
          float _3267 = (cb13_066w + 1.0f) - (cb13_066w * _3241);
          float4 _3278 = t16.Load(int3(_48, _49, 0));
          float _3294 = ((((cb12_069z + -1.0f) * _658) + 1.0f) * (saturate((cb12_187x * _3278.x) + cb12_188x) + -1.0f)) + 1.0f;
          bool _3300 = (_476.z < 0.9900000095367432f);
          if (_3300) {
            _3305 = cb12_287w;
          } else {
            _3305 = 1.0f;
          }
          float _3309 = log2(_3294 * _476.w);
          float _3311 = exp2((cb12_288x * _3305) * _3309);
          if (_3300) {
            _3316 = cb12_287w;
          } else {
            _3316 = 1.0f;
          }
          float _3320 = exp2((_3309 * cb12_288y) * _3316);
          if (_3300) {
            _3325 = cb12_287w;
          } else {
            _3325 = 1.0f;
          }
          float _3328 = log2((_3294 * cb12_069x) + cb12_069y);
          if (_3300) {
            _3335 = cb12_287w;
          } else {
            _3335 = 1.0f;
          }
          float _3346 = exp2((_3325 * cb12_288z) * _3328) * cb12_184z;
          float _3350 = exp2((_3328 * cb12_288w) * _3335) * cb12_184w;
          _3355 = _612;
          _3356 = (_3311 * _3242);
          _3357 = (_3311 * _3243);
          _3358 = (_3311 * _3244);
          _3359 = (_3346 * _1428);
          _3360 = (_3346 * _1429);
          _3361 = (_3346 * _1430);
          _3362 = (_3350 * _1431);
          _3363 = (_3350 * _1432);
          _3364 = (_3350 * _1433);
          _3365 = (((_3054 * _2578) * (((_3261 * _3240) / _3267) + _494)) * _3320);
          _3366 = (((_3055 * _2579) * (((_3261 * _3239) / _3267) + _495)) * _3320);
          _3367 = (((_3056 * _2580) * (((_3261 * _3238) / _3267) + _496)) * _3320);
          if (_3355 == 0) {
            _3374 = (_3359 * _389);
            _3375 = (_3360 * _390);
            _3376 = (_3361 * _391);
          } else {
            _3374 = _3359;
            _3375 = _3360;
            _3376 = _3361;
          }
          if (!_43) {
            _3382 = (_3356 * _389);
            _3383 = (_3357 * _390);
            _3384 = (_3358 * _391);
          } else {
            _3382 = _3356 * night_skylight;
            _3383 = _3357 * night_skylight;
            _3384 = _3358 * night_skylight;
          }
          float _3394 = max(0.0f, _3374) + max(0.0f, _3382);
          float _3395 = max(0.0f, _3375) + max(0.0f, _3383);
          float _3396 = max(0.0f, _3376) + max(0.0f, _3384);
          if (cb12_074x > 0.0f) {
            u0[int2(_48, _49)] = float4((max(0.0f, _3362) + _3394), (max(0.0f, _3363) + _3395), (max(0.0f, _3364) + _3396), 1.0f);
          } else {
            u0[int2(_48, _49)] = float4((max(0.0f, (_3365 + _3362)) + _3394), (max(0.0f, (_3366 + _3363)) + _3395), (max(0.0f, (_3367 + _3364)) + _3396), 1.0f);
          }
          if ((uint)_51 < (uint)256) {
            if ((uint)_51 < (uint)_global_5) {
              _3431 = (_global_4[_51]);
            } else {
              _3431 = 256;
            }
            u2.Store(((int)(((uint((cb12_024x * _93) + _92) << 8u) + _51) << 2u)), asuint(_3431));
          }
          break;
        }
      }
    } else {
      float _720 = select(_518, CSCustomConstants_064.z, CSCustomConstants_048.z);
      if (_476.y > 0.0f) {
        if ((_486 & 71) == 65) {
          _734 = cb13_002x;
          _735 = cb13_002y;
        } else {
          _734 = 1.0f;
          _735 = 0.0f;
        }
        float _736 = dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_613, _614, _615));
        [branch]
        if (((_735 + _658) + saturate(_736)) > 0.0f) {
          bool _742 = (_612 == 0);
          [branch]
          if (_742) {
            float _748 = saturate((saturate(dot(float3(_613, _614, _615), float3(cb13_000x, cb13_000y, cb13_000z))) * _734) + _735);
            _915 = _748;
            _916 = _748;
            _917 = _748;
            _918 = _748;
            _919 = _748;
            _920 = _748;
          } else {
            if (_612 == 2) {
              float _761 = saturate(dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_458, _459, _460)) + 0.5f) * exp2(log2(abs(_736)) * cb12_037y);
              float _762 = _761 * _389;
              float _763 = _761 * _390;
              float _764 = _761 * _391;
              _915 = _762;
              _916 = _763;
              _917 = _764;
              _918 = _762;
              _919 = _763;
              _920 = _764;
            } else {
              int _768 = ((int)(uint)((int)(_615 > 0.0f))) << 1u;
              float _770 = float((int)(_768 + -1));
              float _772 = -1.0f / (_770 + _615);
              float _774 = (_614 * _613) * _772;
              float _778 = (((_613 * _613) * _770) * _772) + 1.0f;
              float _779 = _774 * _770;
              float _782 = float((int)(1 - _768)) * _613;
              float _785 = ((_614 * _614) * _772) + _770;
              float _786 = -0.0f - _614;
              float _788 = rsqrt(dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(cb13_000x, cb13_000y, cb13_000z)));
              float _789 = _788 * cb13_000x;
              float _790 = _788 * cb13_000y;
              float _791 = _788 * cb13_000z;
              float _794 = mad(_782, _791, mad(_779, _790, (_789 * _778)));
              float _797 = mad(_786, _791, mad(_785, _790, (_789 * _774)));
              float _800 = mad(_615, _791, mad(_614, _790, (_789 * _613)));
              float _802 = rsqrt(dot(float3(_794, _797, _800), float3(_794, _797, _800)));
              float _805 = _802 * _800;
              float _807 = rsqrt(dot(float3(_458, _459, _460), float3(_458, _459, _460)));
              float _808 = _807 * _458;
              float _809 = _807 * _459;
              float _810 = _807 * _460;
              float _813 = mad(_782, _810, mad(_779, _809, (_808 * _778)));
              float _816 = mad(_786, _810, mad(_785, _809, (_808 * _774)));
              float _819 = mad(_615, _810, mad(_614, _809, (_808 * _613)));
              float _821 = rsqrt(dot(float3(_813, _816, _819), float3(_813, _816, _819)));
              float _824 = _821 * _819;
              float _825 = _395.w * _395.w;
              float _828 = dot(float3((_802 * _794), (_802 * _797), _805), float3((_821 * _813), (_821 * _816), _824)) - (_824 * _805);
              if (_828 > 0.0f) {
                _834 = (_828 / max(_805, _824));
              } else {
                _834 = _828;
              }
              float _836 = (_825 * 0.2877933979034424f) + 1.0f;
              float _837 = 1.0f / _836;
              float _841 = ((_834 * _825) + 1.0f) * (_837 * 0.31830987334251404f);
              float _845 = 1.0f - _824;
              float _856 = 1.0f - _805;
              float _869 = _837 * ((_825 * 0.07248824834823608f) + 1.0f);
              float _876 = 1.0f - _869;
              float _891 = max(1.0000000116860974e-07f, (1.0f - ((((_856 * _825) * ((((((_856 * 0.07144299894571304f) + -0.332181453704834f) * _856) + 0.4918818771839142f) * _856) + 0.05710852891206741f)) + 1.0f) / _836))) * (max(1.0000000116860974e-07f, (1.0f - ((((_845 * _825) * ((((((_845 * 0.07144299894571304f) + -0.332181453704834f) * _845) + 0.4918818771839142f) * _845) + 0.05710852891206741f)) + 1.0f) / _836))) * 0.31830987334251404f);
              float _895 = max(1.0000000116860974e-07f, _876);
              float _903 = saturate(dot(float3(_613, _614, _615), float3(cb13_000x, cb13_000y, cb13_000z)));
              float _904 = _903 * (((_891 * (((_389 * _389) * _869) / (1.0f - (_876 * _389)))) / _895) + (_841 * _389));
              float _905 = _903 * (((_891 * (((_390 * _390) * _869) / (1.0f - (_876 * _390)))) / _895) + (_841 * _390));
              float _906 = _903 * (((_891 * (((_391 * _391) * _869) / (1.0f - (_876 * _391)))) / _895) + (_841 * _391));
              bool _907 = (_612 == 1);
              _915 = _904;
              _916 = _905;
              _917 = _906;
              _918 = select(_907, (_904 * 3.1415927410125732f), _904);
              _919 = select(_907, (_905 * 3.1415927410125732f), _905);
              _920 = select(_907, (_906 * 3.1415927410125732f), _906);
            }
          }
          float _924 = 1.0f - _494;
          float _925 = 1.0f - _495;
          float _926 = 1.0f - _496;
          if (cb12_221x > 0.0f) {
            float4 _931 = t43.SampleLevel(s10, float2(_395.w, dot(float3(_613, _614, _615), float3(_458, _459, _460))), 0.0f);
            float _937 = (_931.x * _494) + _931.y;
            float _938 = (_931.x * _495) + _931.y;
            float _939 = (_931.x * _496) + _931.y;
            _1001 = min((_937 / max((1.0f - ((1.0f - _937) * ((_924 * 0.0476190485060215f) + _494))), 0.0010000000474974513f)), 1.0f);
            _1002 = min((_938 / max((1.0f - ((1.0f - _938) * ((_925 * 0.0476190485060215f) + _495))), 0.0010000000474974513f)), 1.0f);
            _1003 = min((_939 / max((1.0f - ((1.0f - _939) * ((_926 * 0.0476190485060215f) + _496))), 0.0010000000474974513f)), 1.0f);
          } else {
            float _965 = cb13_000x + _458;
            float _966 = cb13_000y + _459;
            float _967 = cb13_000z + _460;
            float _969 = rsqrt(dot(float3(_965, _966, _967), float3(_965, _966, _967)));
            float _976 = saturate(1.0f - abs(dot(float3((_969 * _965), (_969 * _966), (_969 * _967)), float3(_458, _459, _460))));
            float _977 = _976 * _976;
            float _987 = ((_977 * _977) * _976) * cb13_066x;
            float _993 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _395.w));
            _1001 = (((_987 * max(0.0f, _924)) / _993) + _494);
            _1002 = (((_987 * max(0.0f, _925)) / _993) + _495);
            _1003 = (((_987 * max(0.0f, _926)) / _993) + _496);
          }
          float _1007 = (1.0f - _1001) * _915;
          float _1008 = (1.0f - _1002) * _916;
          float _1009 = (1.0f - _1003) * _917;
          bool _1011 = ((_612 & -3) == 0);
          float _1015 = select(_1011, (_1007 * 0.31830987334251404f), _1007);
          float _1016 = select(_1011, (_1008 * 0.31830987334251404f), _1008);
          float _1017 = select(_1011, (_1009 * 0.31830987334251404f), _1009);
          [branch]
          if (_658 > 0.0f) {
            if (!(cb12_037z == 0.0f)) {
              float _1029 = dot(float3(_389, _390, _391), float3(0.21250000596046448f, 0.715399980545044f, 0.07209999859333038f));
              if (!_742) {
                _1044 = saturate(lerp(_1029, _389, cb12_036w));
                _1045 = saturate(lerp(_1029, _390, cb12_036w));
                _1046 = saturate(lerp(_1029, _391, cb12_036w));
              } else {
                _1044 = 1.0f;
                _1045 = 1.0f;
                _1046 = 1.0f;
              }
              float _1047 = dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_458, _459, _460));
              float _1061 = ((_658 * 0.31830987334251404f) * exp2(log2(abs(_736)) * cb12_036z)) * (exp2((_1047 + cb12_036y) * -4.328084945678711f) + exp2((_1047 + cb12_036x) * -1.4426950216293335f));
              _1114 = ((_1061 * _1044) + _1015);
              _1115 = ((_1061 * _1045) + _1016);
              _1116 = ((_1061 * _1046) + _1017);
            } else {
              float _1070 = (_736 + 1.0f) * 0.5f;
              float _1071 = -0.0f - _458;
              float _1072 = -0.0f - _459;
              float _1073 = -0.0f - _460;
              float _1076 = (dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_1071, _1072, _1073)) + 1.0f) * 0.5f;
              float _1079 = _1076 * _1076;
              float _1081 = select(_742, 1.0f, _389);
              float _1082 = select(_742, 1.0f, _390);
              float _1083 = select(_742, 1.0f, _391);
              float _1093 = cb12_036y * _658;
              float _1106 = (((_658 * 0.5f) * cb12_036w) * (dot(float3(_613, _614, _615), float3(_1071, _1072, _1073)) + 1.0f)) * ((((_1079 * _1079) - _1070) * cb12_036x) + _1070);
              _1114 = ((((((_1081 * _924) * cb12_036z) - _1015) * _1093) + _1015) + (_1106 * _1081));
              _1115 = ((((((_1082 * _925) * cb12_036z) - _1016) * _1093) + _1016) + (_1106 * _1082));
              _1116 = ((((((_1083 * _926) * cb12_036z) - _1017) * _1093) + _1017) + (_1106 * _1083));
            }
          } else {
            _1114 = _1015;
            _1115 = _1016;
            _1116 = _1017;
          }
          float _1117 = _446 - cb12_000x;
          float _1118 = _447 - cb12_000y;
          float _1128 = saturate((cb12_219z * _448) + cb12_219w);
          float _1150 = saturate((cb12_219x * sqrt((_1117 * _1117) + (_1118 * _1118))) + cb12_219y);
          float _1164 = ((((lerp(cb13_062x, cb13_061x, _1128)) - cb13_001x) * _1150) + cb13_001x) * _476.y;
          float _1166 = ((((lerp(cb13_062y, cb13_061y, _1128)) - cb13_001y) * _1150) + cb13_001y) * _476.y;
          float _1168 = ((((lerp(cb13_062z, cb13_061z, _1128)) - cb13_001z) * _1150) + cb13_001z) * _476.y;
          [branch]
          if (dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_616, _617, _618)) > 0.0f) {
            float _1173 = cb13_000x + _458;
            float _1174 = cb13_000y + _459;
            float _1175 = cb13_000z + _460;
            float _1177 = rsqrt(dot(float3(_1173, _1174, _1175), float3(_1173, _1174, _1175)));
            float _1178 = _1177 * _1173;
            float _1179 = _1177 * _1174;
            float _1180 = _1177 * _1175;
            float _1182 = dot(float3(_616, _617, _618), float3(_458, _459, _460));
            float _1184 = saturate(dot(float3(_616, _617, _618), float3(_1178, _1179, _1180)));
            float _1185 = saturate(dot(float3(_616, _617, _618), float3(cb13_000x, cb13_000y, cb13_000z)));
            float _1186 = _395.w * _395.w;
            float _1187 = _1186 * _1186;
            float _1191 = ((_1184 * _1184) * (_1187 + -1.0f)) + 1.0f;
            float _1195 = abs(_1182);
            float _1196 = CSCustomConstants_048.y - CSCustomConstants_048.x;
            float _1202 = saturate(select((_1196 == 0.0f), 1e+05f, (1.0f / _1196)) * (_466 - CSCustomConstants_048.x));
            float _1203 = max(_720, _494);
            float _1204 = max(_720, _495);
            float _1205 = max(_720, _496);
            if (!_510) {
              _1223 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _494) - _1203) * _1202) + _1203));
              _1224 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _495) - _1204) * _1202) + _1204));
              _1225 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _496) - _1205) * _1202) + _1205));
            } else {
              _1223 = CSCustomConstants_064.x;
              _1224 = CSCustomConstants_064.x;
              _1225 = CSCustomConstants_064.x;
            }
            float _1229 = saturate(1.0f - abs(dot(float3(_1178, _1179, _1180), float3(_458, _459, _460))));
            float _1230 = _1229 * _1229;
            float _1243 = ((_1230 * _1230) * _1229) * cb13_066x;
            float _1249 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _395.w));
            [branch]
            if (cb12_221z > 0.0f) {
              float _1259 = saturate(_1182);
              float _1262 = (_1185 * 2.0f) * _1259;
              _1281 = ((((_1259 + _1185) - _1262) * _1186) + _1262);
            } else {
              float _1267 = 1.0f - _1187;
              _1281 = (((sqrt(((_1195 * _1195) * _1267) + _1187) * _1185) + 9.999999747378752e-05f) + (sqrt(((_1185 * _1185) * _1267) + _1187) * _1195));
            }
            float _1282 = 0.5f / _1281;
            float _1283 = _1282 * (_1187 / ((_1191 * _1191) * 3.1415200233459473f));
            float _1284 = _1283 * (((_1243 * max(0.0f, (_1223 - _494))) / _1249) + _494);
            float _1285 = _1283 * (((_1243 * max(0.0f, (_1224 - _495))) / _1249) + _495);
            float _1286 = _1283 * (((_1243 * max(0.0f, (_1225 - _496))) / _1249) + _496);
            if (cb12_221y > 0.0f) {
              float4 _1293 = t43.SampleLevel(s10, float2(_395.w, dot(float3(_616, _617, _618), float3(_1282, _1282, _1282))), 0.0f);
              float _1299 = (_1293.x * _494) + _1293.y;
              float _1300 = (_1293.x * _495) + _1293.y;
              float _1301 = (_1293.x * _496) + _1293.y;
              _1336 = ((min((_1299 / max((1.0f - ((1.0f - _1299) * ((_924 * 0.0476190485060215f) + _494))), 0.0010000000474974513f)), 1.0f) / max(_1299, 9.999999747378752e-05f)) * _1284);
              _1337 = ((min((_1300 / max((1.0f - ((1.0f - _1300) * ((_925 * 0.0476190485060215f) + _495))), 0.0010000000474974513f)), 1.0f) / max(_1300, 9.999999747378752e-05f)) * _1285);
              _1338 = ((min((_1301 / max((1.0f - ((1.0f - _1301) * ((_926 * 0.0476190485060215f) + _496))), 0.0010000000474974513f)), 1.0f) / max(_1301, 9.999999747378752e-05f)) * _1286);
            } else {
              _1336 = _1284;
              _1337 = _1285;
              _1338 = _1286;
            }
            _1343 = (_1336 * _1185);
            _1344 = (_1337 * _1185);
            _1345 = (_1338 * _1185);
          } else {
            _1343 = 0.0f;
            _1344 = 0.0f;
            _1345 = 0.0f;
          }
          if (!(_528 == 0)) {
            float _1348 = dot(float3(_389, _390, _391), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
            float _1357 = 1.0010000467300415f - _1348;
            float _1389 = saturate(dot(float3(_619, _620, _621), float3(cb13_000x, cb13_000y, cb13_000z))) * (exp2(log2(1.0f - saturate(dot(float3(_619, _620, _621), float3(_458, _459, _460)))) * 5.0f) * _657);
            _1394 = (_1389 * saturate((1.0f - exp2(log2(_1357 - ((_389 - _1348) * _656)) * cb12_223x)) * cb12_223y));
            _1395 = (_1389 * saturate((1.0f - exp2(log2(_1357 - ((_390 - _1348) * _656)) * cb12_223x)) * cb12_223y));
            _1396 = (_1389 * saturate((1.0f - exp2(log2(_1357 - ((_391 - _1348) * _656)) * cb12_223x)) * cb12_223y));
          } else {
            _1394 = 0.0f;
            _1395 = 0.0f;
            _1396 = 0.0f;
          }
          _1404 = ((_1394 + _1343) * _1164);
          _1405 = ((_1395 + _1344) * _1166);
          _1406 = ((_1396 + _1345) * _1168);
          _1407 = (_1164 * _1114);
          _1408 = (_1166 * _1115);
          _1409 = (_1168 * _1116);
          _1410 = _918;
          _1411 = _919;
          _1412 = _920;
        } else {
          _1404 = 0.0f;
          _1405 = 0.0f;
          _1406 = 0.0f;
          _1407 = 0.0f;
          _1408 = 0.0f;
          _1409 = 0.0f;
          _1410 = 0.0f;
          _1411 = 0.0f;
          _1412 = 0.0f;
        }
      } else {
        _1404 = 0.0f;
        _1405 = 0.0f;
        _1406 = 0.0f;
        _1407 = 0.0f;
        _1408 = 0.0f;
        _1409 = 0.0f;
        _1410 = 0.0f;
        _1411 = 0.0f;
        _1412 = 0.0f;
      }
      float _1413 = min(_1410, _476.y);
      float _1414 = min(_1411, _476.y);
      float _1415 = min(_1412, _476.y);
      bool _1417 = (_519 == 0);
      if (_1417) {
        _1422 = cb12_071x;
      } else {
        _1422 = 1.0f;
      }
      int _1423 = _global_3;
      if (!(_1423 == 0)) {
        _1473 = _1407;
        _1474 = _1408;
        _1475 = _1409;
        _1476 = _1404;
        _1477 = _1405;
        _1478 = _1406;
        _1479 = 0;
        while(true) {
          uint _1482 = (_global_2[_1479]) * 10;
          float _1488 = (cb13_raw[((int)(_1482 + 68u))].x) - _446;
          float _1489 = (cb13_raw[((int)(_1482 + 68u))].y) - _447;
          float _1490 = (cb13_raw[((int)(_1482 + 68u))].z) - _448;
          float _1496 = sqrt(((_1488 * _1488) + (_1489 * _1489)) + (_1490 * _1490));
          float _1503 = _1496 / (cb13_raw[((int)(_1482 + 68u))].w);
          float _1504 = _1503 * _1503;
          float _1507 = saturate(1.0f - (_1504 * _1504));
          int _1512 = asint((cb13_raw[((int)(_1482 + 71u))].w));
          bool _1514 = ((_1512 & 1) != 0);
          bool _1516 = ((cb13_raw[((int)(_1482 + 73u))].z) > 0.0f);
          int _1524 = asint((cb13_raw[((int)(_1482 + 77u))].x));
          bool _1526 = ((_1524 & 1) != 0);
          float _1528 = (_1507 * _1507) / (((_1496 * _1496) * (cb13_raw[((int)(_1482 + 73u))].x)) + 1.0f);
          if (_1514) {
            float _1536 = rsqrt(dot(float3(_1488, _1489, _1490), float3(_1488, _1489, _1490)));
            _1557 = (exp2(log2(saturate(((cb13_raw[((int)(_1482 + 72u))].y) * dot(float3((-0.0f - (_1488 * _1536)), (-0.0f - (_1489 * _1536)), (-0.0f - (_1490 * _1536))), float3((cb13_raw[((int)(_1482 + 70u))].x), (cb13_raw[((int)(_1482 + 70u))].y), (cb13_raw[((int)(_1482 + 70u))].z)))) + (cb13_raw[((int)(_1482 + 72u))].z))) * (cb13_raw[((int)(_1482 + 72u))].w)) * _1528);
          } else {
            _1557 = _1528;
          }
          bool _1559 = (_1557 > 0.0f);
          if (((int)(_1516 || _1526)) && _1559) {
            float _1562 = -0.0f - _1488;
            float _1563 = -0.0f - _1489;
            float _1564 = -0.0f - _1490;
            if (_1514) {
              _1759 = mad((((cb13_raw[((int)(_1482 + 75u))].z) * (cb13_raw[((int)(_1482 + 70u))].x)) - ((cb13_raw[((int)(_1482 + 75u))].y) * (cb13_raw[((int)(_1482 + 70u))].y))), _1564, mad((((cb13_raw[((int)(_1482 + 75u))].y) * (cb13_raw[((int)(_1482 + 70u))].z)) - ((cb13_raw[((int)(_1482 + 75u))].w) * (cb13_raw[((int)(_1482 + 70u))].x))), _1563, ((((cb13_raw[((int)(_1482 + 75u))].w) * (cb13_raw[((int)(_1482 + 70u))].y)) - ((cb13_raw[((int)(_1482 + 75u))].z) * (cb13_raw[((int)(_1482 + 70u))].z))) * _1562)));
              _1760 = mad((cb13_raw[((int)(_1482 + 75u))].w), _1564, mad((cb13_raw[((int)(_1482 + 75u))].z), _1563, ((cb13_raw[((int)(_1482 + 75u))].y) * _1562)));
              _1761 = mad((cb13_raw[((int)(_1482 + 70u))].z), _1564, mad((cb13_raw[((int)(_1482 + 70u))].y), _1563, ((cb13_raw[((int)(_1482 + 70u))].x) * _1562)));
              _1762 = (cb13_raw[((int)(_1482 + 75u))].x);
              _1763 = asint((cb13_raw[((int)(_1482 + 77u))].z));
            } else {
              if (_1526) {
                float _1620 = mad((((cb13_raw[((int)(_1482 + 70u))].x) * (cb13_raw[((int)(_1482 + 72u))].z)) - ((cb13_raw[((int)(_1482 + 70u))].y) * (cb13_raw[((int)(_1482 + 72u))].y))), _1564, mad((((cb13_raw[((int)(_1482 + 70u))].z) * (cb13_raw[((int)(_1482 + 72u))].y)) - ((cb13_raw[((int)(_1482 + 70u))].x) * (cb13_raw[((int)(_1482 + 72u))].w))), _1563, ((((cb13_raw[((int)(_1482 + 70u))].y) * (cb13_raw[((int)(_1482 + 72u))].w)) - ((cb13_raw[((int)(_1482 + 70u))].z) * (cb13_raw[((int)(_1482 + 72u))].z))) * _1562)));
                float _1623 = mad((cb13_raw[((int)(_1482 + 70u))].z), _1564, mad((cb13_raw[((int)(_1482 + 70u))].y), _1563, ((cb13_raw[((int)(_1482 + 70u))].x) * _1562)));
                float _1626 = mad((cb13_raw[((int)(_1482 + 72u))].w), _1564, mad((cb13_raw[((int)(_1482 + 72u))].z), _1563, ((cb13_raw[((int)(_1482 + 72u))].y) * _1562)));
                float _1627 = -0.0f - _1620;
                float _1628 = -0.0f - _1623;
                float _1629 = -0.0f - _1626;
                float _1630 = _1627 / _1496;
                float _1631 = _1628 / _1496;
                float _1632 = _1629 / _1496;
                float _1633 = abs(_1630);
                float _1634 = abs(_1631);
                float _1635 = abs(_1632);
                bool _1639 = (_1633 > max(_1634, _1635));
                if (!((_1524 & 4) == 0)) {
                  if (_1639) {
                    if (_1630 > 0.0f) {
                      _1669 = _1623;
                      _1670 = _1626;
                      _1671 = _1627;
                      _1672 = (cb13_raw[((int)(_1482 + 75u))].x);
                    } else {
                      _1669 = _1628;
                      _1670 = _1626;
                      _1671 = _1620;
                      _1672 = (cb13_raw[((int)(_1482 + 75u))].y);
                    }
                  } else {
                    if (_1634 > max(_1633, _1635)) {
                      if (_1631 > 0.0f) {
                        _1669 = _1627;
                        _1670 = _1626;
                        _1671 = _1628;
                        _1672 = (cb13_raw[((int)(_1482 + 75u))].z);
                      } else {
                        _1669 = _1620;
                        _1670 = _1626;
                        _1671 = _1623;
                        _1672 = (cb13_raw[((int)(_1482 + 75u))].w);
                      }
                    } else {
                      if (_1632 > 0.0f) {
                        _1669 = _1620;
                        _1670 = _1623;
                        _1671 = _1629;
                        _1672 = (cb13_raw[((int)(_1482 + 76u))].x);
                      } else {
                        _1669 = _1620;
                        _1670 = _1628;
                        _1671 = _1626;
                        _1672 = (cb13_raw[((int)(_1482 + 76u))].y);
                      }
                    }
                  }
                  _1759 = _1669;
                  _1760 = _1670;
                  _1761 = _1671;
                  _1762 = _1672;
                  _1763 = asint((cb13_raw[((int)(_1482 + 77u))].z));
                } else {
                  if (_1639) {
                    int _1681 = asint((cb13_raw[((int)(_1482 + 77u))].z));
                    if (_1630 > 0.0f) {
                      _1759 = _1623;
                      _1760 = _1626;
                      _1761 = _1627;
                      _1762 = (cb13_raw[((int)(_1482 + 75u))].x);
                      _1763 = _1681;
                    } else {
                      _1759 = _1628;
                      _1760 = _1626;
                      _1761 = _1620;
                      _1762 = (cb13_raw[((int)(_1482 + 75u))].y);
                      _1763 = ((uint)(_1681) >> 10);
                    }
                  } else {
                    if (_1634 > max(_1633, _1635)) {
                      if (_1631 > 0.0f) {
                        _1759 = _1627;
                        _1760 = _1626;
                        _1761 = _1628;
                        _1762 = (cb13_raw[((int)(_1482 + 75u))].z);
                        _1763 = ((uint)((uint)(asint((cb13_raw[((int)(_1482 + 77u))].z)))) >> 20);
                      } else {
                        _1759 = _1620;
                        _1760 = _1626;
                        _1761 = _1623;
                        _1762 = (cb13_raw[((int)(_1482 + 75u))].w);
                        _1763 = asint((cb13_raw[((int)(_1482 + 77u))].w));
                      }
                    } else {
                      int _1708 = asint((cb13_raw[((int)(_1482 + 77u))].w));
                      if (_1632 > 0.0f) {
                        _1759 = _1620;
                        _1760 = _1623;
                        _1761 = _1629;
                        _1762 = (cb13_raw[((int)(_1482 + 76u))].x);
                        _1763 = ((uint)(_1708) >> 10);
                      } else {
                        _1759 = _1620;
                        _1760 = _1628;
                        _1761 = _1626;
                        _1762 = (cb13_raw[((int)(_1482 + 76u))].y);
                        _1763 = ((uint)(_1708) >> 20);
                      }
                    }
                  }
                }
              } else {
                float _1716 = _1488 / _1496;
                float _1717 = _1489 / _1496;
                float _1718 = _1490 / _1496;
                float _1719 = abs(_1716);
                float _1720 = abs(_1717);
                float _1721 = abs(_1718);
                if (_1719 > max(_1720, _1721)) {
                  if (_1716 > 0.0f) {
                    _1752 = _1563;
                    _1753 = _1564;
                    _1754 = _1488;
                    _1755 = (cb13_raw[((int)(_1482 + 75u))].x);
                  } else {
                    _1752 = _1489;
                    _1753 = _1564;
                    _1754 = _1562;
                    _1755 = (cb13_raw[((int)(_1482 + 75u))].y);
                  }
                } else {
                  if (_1720 > max(_1719, _1721)) {
                    if (_1717 > 0.0f) {
                      _1752 = _1488;
                      _1753 = _1564;
                      _1754 = _1489;
                      _1755 = (cb13_raw[((int)(_1482 + 75u))].z);
                    } else {
                      _1752 = _1562;
                      _1753 = _1564;
                      _1754 = _1563;
                      _1755 = (cb13_raw[((int)(_1482 + 75u))].w);
                    }
                  } else {
                    if (_1718 > 0.0f) {
                      _1752 = _1562;
                      _1753 = _1563;
                      _1754 = _1490;
                      _1755 = (cb13_raw[((int)(_1482 + 76u))].x);
                    } else {
                      _1752 = _1562;
                      _1753 = _1489;
                      _1754 = _1564;
                      _1755 = (cb13_raw[((int)(_1482 + 76u))].y);
                    }
                  }
                }
                _1759 = _1752;
                _1760 = _1753;
                _1761 = _1754;
                _1762 = _1755;
                _1763 = asint((cb13_raw[((int)(_1482 + 77u))].z));
              }
            }
            float _1771 = (((_1759 * (cb13_raw[((int)(_1482 + 73u))].y)) / _1761) * 0.5f) + 0.5f;
            float _1772 = 0.5f - ((mad((cb13_raw[((int)(_1482 + 73u))].y), _1760, 0.0f) / _1761) * 0.5f);
            if (_1516) {
              int _1774 = asint(_1762);
              int _1776 = ((uint)(_1774) >> 18) & 4092;
              float _1777 = float((uint)_1776);
              [branch]
              if (!(_1776 == 0)) {
                float _1798 = t9.SampleLevel(s10, float3((cb13_067x * ((_1771 * _1777) + float((uint)((uint)(((int)(_1774 << 2u)) & 4092))))), (cb13_067x * ((_1772 * _1777) + float((uint)((uint)(((uint)(_1774) >> 8) & 4092))))), float((uint)((uint)((uint)(_1774) >> 30)))), 0.0f);
                _1806 = saturate(exp2((_1798.x - (_1503 * 0.9900000095367432f)) * 144.26950073242188f));
              } else {
                _1806 = 1.0f;
              }
            } else {
              _1806 = 1.0f;
            }
            if (_1526) {
              bool _1809 = ((_1524 & 2) != 0);
              if (_1809) {
                _1819 = (_1763 & 1023);
                _1820 = 0;
              } else {
                _1819 = (_1763 & 255);
                _1820 = (((uint)(_1763) >> 8) & 3);
              }
              float _1824 = floor(cb13_raw[((int)(_1482 + 77u))].y) + float((uint)_1819);
              float4 _1828 = t42.SampleLevel(s10, float3(_1771, _1772, _1824), 0.0f);
              _30[0] = _1828.x;
              _30[1] = _1828.y;
              _30[2] = _1828.z;
              _30[3] = _1828.w;
              if (!((_1524 & 8) == 0)) {
                float4 _1839 = t42.SampleLevel(s10, float3(_1771, _1772, (_1824 + 1.0f)), 0.0f);
                float _1844 = frac(cb13_raw[((int)(_1482 + 77u))].y);
                float _1853 = ((_1839.x - _1828.x) * _1844) + _1828.x;
                float _1854 = ((_1839.y - _1828.y) * _1844) + _1828.y;
                float _1855 = ((_1839.z - _1828.z) * _1844) + _1828.z;
                _30[0] = _1853;
                _30[1] = _1854;
                _30[2] = _1855;
                _30[3] = (lerp(_1828.w, _1839.w, _1844));
                _1858 = _1855;
                _1859 = _1854;
                _1860 = _1853;
              } else {
                _1858 = _1828.z;
                _1859 = _1828.y;
                _1860 = _1828.x;
              }
              if (!_1809) {
                float _1863 = _30[_1820];
                _1865 = _1863;
                _1866 = _1863;
                _1867 = _1863;
              } else {
                _1865 = _1860;
                _1866 = _1859;
                _1867 = _1858;
              }
              _1869 = _1806;
              _1870 = _1865;
              _1871 = _1866;
              _1872 = _1867;
            } else {
              _1869 = _1806;
              _1870 = 1.0f;
              _1871 = 1.0f;
              _1872 = 1.0f;
            }
          } else {
            _1869 = 1.0f;
            _1870 = 1.0f;
            _1871 = 1.0f;
            _1872 = 1.0f;
          }
          if ((int)((cb13_raw[((int)(_1482 + 74u))].x) > 0.0f) && _1559) {
            float _1878 = t10.SampleLevel(s10, float4(_1488, _1489, _1490, (cb13_raw[((int)(_1482 + 74u))].y)), 0.0f);
            _1887 = (saturate(exp2((_1878.x - (_1503 * 0.9900000095367432f)) * 144.26950073242188f)) * _1869);
          } else {
            _1887 = _1869;
          }
          if ((int)(_476.z == 1.0f) || (int)((_1512 & 2048) != 0)) {
            _1902 = cb12_071y;
          } else {
            _1902 = 0.0f;
          }
          if (((int)(!(_476.z == 1.0f))) || (int)((_1512 & 4096) != 0)) {
            _1911 = cb12_071z;
          } else {
            _1911 = 0.0f;
          }
          float _1914 = (((((cb13_raw[((int)(_1482 + 70u))].w) * (_1887 + -1.0f)) + 1.0f) * _1557) * _1902) * _1911;
          float _1915 = _1914 * _1870;
          float _1916 = _1914 * _1871;
          float _1917 = _1914 * _1872;
          [branch]
          if ((int)(_1917 > 0.0f) || ((int)((int)(_1915 > 0.0f) || (int)(_1916 > 0.0f)))) {
            bool _1929 = ((int)_1512 < (int)0);
            float _1930 = select(_1929, _1422, 1.0f);
            float _1938 = rsqrt(dot(float3(_1488, _1489, _1490), float3(_1488, _1489, _1490)));
            float _1939 = _1938 * _1488;
            float _1940 = _1938 * _1489;
            float _1941 = _1938 * _1490;
            bool _1942 = (_612 == 0);
            [branch]
            if (_1942) {
              float _1946 = saturate(saturate(dot(float3(_613, _614, _615), float3(_1939, _1940, _1941))));
              _2107 = _1946;
              _2108 = _1946;
              _2109 = _1946;
            } else {
              if (_612 == 2) {
                float _1960 = saturate(dot(float3(_1939, _1940, _1941), float3(_458, _459, _460)) + 0.5f) * exp2(log2(abs(dot(float3(_1939, _1940, _1941), float3(_613, _614, _615)))) * cb12_037y);
                _2107 = (_1960 * _389);
                _2108 = (_1960 * _390);
                _2109 = (_1960 * _391);
              } else {
                int _1967 = ((int)(uint)((int)(_615 > 0.0f))) << 1u;
                float _1969 = float((int)(_1967 + -1));
                float _1971 = -1.0f / (_1969 + _615);
                float _1973 = (_614 * _613) * _1971;
                float _1977 = (((_613 * _613) * _1969) * _1971) + 1.0f;
                float _1978 = _1973 * _1969;
                float _1981 = float((int)(1 - _1967)) * _613;
                float _1984 = ((_614 * _614) * _1971) + _1969;
                float _1985 = -0.0f - _614;
                float _1987 = rsqrt(dot(float3(_1939, _1940, _1941), float3(_1939, _1940, _1941)));
                float _1988 = _1987 * _1939;
                float _1989 = _1987 * _1940;
                float _1990 = _1987 * _1941;
                float _1993 = mad(_1981, _1990, mad(_1978, _1989, (_1988 * _1977)));
                float _1996 = mad(_1985, _1990, mad(_1984, _1989, (_1988 * _1973)));
                float _1999 = mad(_615, _1990, mad(_614, _1989, (_1988 * _613)));
                float _2001 = rsqrt(dot(float3(_1993, _1996, _1999), float3(_1993, _1996, _1999)));
                float _2004 = _2001 * _1999;
                float _2006 = rsqrt(dot(float3(_458, _459, _460), float3(_458, _459, _460)));
                float _2007 = _2006 * _458;
                float _2008 = _2006 * _459;
                float _2009 = _2006 * _460;
                float _2012 = mad(_1981, _2009, mad(_1978, _2008, (_2007 * _1977)));
                float _2015 = mad(_1985, _2009, mad(_1984, _2008, (_2007 * _1973)));
                float _2018 = mad(_615, _2009, mad(_614, _2008, (_2007 * _613)));
                float _2020 = rsqrt(dot(float3(_2012, _2015, _2018), float3(_2012, _2015, _2018)));
                float _2023 = _2020 * _2018;
                float _2024 = _395.w * _395.w;
                float _2027 = dot(float3((_2001 * _1993), (_2001 * _1996), _2004), float3((_2020 * _2012), (_2020 * _2015), _2023)) - (_2023 * _2004);
                if (_2027 > 0.0f) {
                  _2033 = (_2027 / max(_2004, _2023));
                } else {
                  _2033 = _2027;
                }
                float _2035 = (_2024 * 0.2877933979034424f) + 1.0f;
                float _2036 = 1.0f / _2035;
                float _2040 = ((_2033 * _2024) + 1.0f) * (_2036 * 0.31830987334251404f);
                float _2044 = 1.0f - _2023;
                float _2055 = 1.0f - _2004;
                float _2068 = _2036 * ((_2024 * 0.07248824834823608f) + 1.0f);
                float _2075 = 1.0f - _2068;
                float _2090 = max(1.0000000116860974e-07f, (1.0f - ((((_2055 * _2024) * ((((((_2055 * 0.07144299894571304f) + -0.332181453704834f) * _2055) + 0.4918818771839142f) * _2055) + 0.05710852891206741f)) + 1.0f) / _2035))) * (max(1.0000000116860974e-07f, (1.0f - ((((_2044 * _2024) * ((((((_2044 * 0.07144299894571304f) + -0.332181453704834f) * _2044) + 0.4918818771839142f) * _2044) + 0.05710852891206741f)) + 1.0f) / _2035))) * 0.31830987334251404f);
                float _2094 = max(1.0000000116860974e-07f, _2075);
                float _2102 = saturate(dot(float3(_613, _614, _615), float3(_1939, _1940, _1941)));
                _2107 = (_2102 * (((_2090 * (((_389 * _389) * _2068) / (1.0f - (_2075 * _389)))) / _2094) + (_2040 * _389)));
                _2108 = (_2102 * (((_2090 * (((_390 * _390) * _2068) / (1.0f - (_2075 * _390)))) / _2094) + (_2040 * _390)));
                _2109 = (_2102 * (((_2090 * (((_391 * _391) * _2068) / (1.0f - (_2075 * _391)))) / _2094) + (_2040 * _391)));
              }
            }
            float _2113 = 1.0f - _494;
            float _2114 = 1.0f - _495;
            float _2115 = 1.0f - _496;
            if (cb12_221x > 0.0f) {
              float4 _2120 = t43.SampleLevel(s10, float2(_395.w, dot(float3(_613, _614, _615), float3(_458, _459, _460))), 0.0f);
              float _2126 = (_2120.x * _494) + _2120.y;
              float _2127 = (_2120.x * _495) + _2120.y;
              float _2128 = (_2120.x * _496) + _2120.y;
              _2190 = min((_2126 / max((1.0f - ((1.0f - _2126) * ((_2113 * 0.0476190485060215f) + _494))), 0.0010000000474974513f)), 1.0f);
              _2191 = min((_2127 / max((1.0f - ((1.0f - _2127) * ((_2114 * 0.0476190485060215f) + _495))), 0.0010000000474974513f)), 1.0f);
              _2192 = min((_2128 / max((1.0f - ((1.0f - _2128) * ((_2115 * 0.0476190485060215f) + _496))), 0.0010000000474974513f)), 1.0f);
            } else {
              float _2154 = _1939 + _458;
              float _2155 = _1940 + _459;
              float _2156 = _1941 + _460;
              float _2158 = rsqrt(dot(float3(_2154, _2155, _2156), float3(_2154, _2155, _2156)));
              float _2165 = saturate(1.0f - abs(dot(float3((_2158 * _2154), (_2158 * _2155), (_2158 * _2156)), float3(_458, _459, _460))));
              float _2166 = _2165 * _2165;
              float _2176 = ((_2166 * _2166) * _2165) * cb13_066x;
              float _2182 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _395.w));
              _2190 = (((_2176 * max(0.0f, _2113)) / _2182) + _494);
              _2191 = (((_2176 * max(0.0f, _2114)) / _2182) + _495);
              _2192 = (((_2176 * max(0.0f, _2115)) / _2182) + _496);
            }
            float _2196 = (1.0f - _2190) * _2107;
            float _2197 = (1.0f - _2191) * _2108;
            float _2198 = (1.0f - _2192) * _2109;
            bool _2200 = ((_612 & -3) == 0);
            float _2204 = select(_2200, (_2196 * 0.31830987334251404f), _2196);
            float _2205 = select(_2200, (_2197 * 0.31830987334251404f), _2197);
            float _2206 = select(_2200, (_2198 * 0.31830987334251404f), _2198);
            [branch]
            if (_658 > 0.0f) {
              if (!(cb12_037z == 0.0f)) {
                float _2218 = dot(float3(_389, _390, _391), float3(0.21250000596046448f, 0.715399980545044f, 0.07209999859333038f));
                if (!_1942) {
                  _2233 = saturate(lerp(_2218, _389, cb12_036w));
                  _2234 = saturate(lerp(_2218, _390, cb12_036w));
                  _2235 = saturate(lerp(_2218, _391, cb12_036w));
                } else {
                  _2233 = 1.0f;
                  _2234 = 1.0f;
                  _2235 = 1.0f;
                }
                float _2236 = dot(float3(_1939, _1940, _1941), float3(_458, _459, _460));
                float _2251 = ((_658 * 0.31830987334251404f) * exp2(log2(abs(dot(float3(_1939, _1940, _1941), float3(_613, _614, _615)))) * cb12_036z)) * (exp2((_2236 + cb12_036y) * -4.328084945678711f) + exp2((_2236 + cb12_036x) * -1.4426950216293335f));
                _2305 = ((_2251 * _2233) + _2204);
                _2306 = ((_2251 * _2234) + _2205);
                _2307 = ((_2251 * _2235) + _2206);
              } else {
                float _2261 = (dot(float3(_1939, _1940, _1941), float3(_613, _614, _615)) + 1.0f) * 0.5f;
                float _2262 = -0.0f - _458;
                float _2263 = -0.0f - _459;
                float _2264 = -0.0f - _460;
                float _2267 = (dot(float3(_1939, _1940, _1941), float3(_2262, _2263, _2264)) + 1.0f) * 0.5f;
                float _2270 = _2267 * _2267;
                float _2272 = select(_1942, 1.0f, _389);
                float _2273 = select(_1942, 1.0f, _390);
                float _2274 = select(_1942, 1.0f, _391);
                float _2284 = cb12_036y * _658;
                float _2297 = (((_658 * 0.5f) * cb12_036w) * (dot(float3(_613, _614, _615), float3(_2262, _2263, _2264)) + 1.0f)) * ((((_2270 * _2270) - _2261) * cb12_036x) + _2261);
                _2305 = ((((((_2272 * _2113) * cb12_036z) - _2204) * _2284) + _2204) + (_2297 * _2272));
                _2306 = ((((((_2273 * _2114) * cb12_036z) - _2205) * _2284) + _2205) + (_2297 * _2273));
                _2307 = ((((((_2274 * _2115) * cb12_036z) - _2206) * _2284) + _2206) + (_2297 * _2274));
              }
            } else {
              _2305 = _2204;
              _2306 = _2205;
              _2307 = _2206;
            }
            float _2311 = (_1915 * _1930) * (cb13_raw[((int)(_1482 + 71u))].x);
            float _2313 = (_1916 * _1930) * (cb13_raw[((int)(_1482 + 71u))].y);
            float _2315 = (_1917 * _1930) * (cb13_raw[((int)(_1482 + 71u))].z);
            [branch]
            if (dot(float3(_1939, _1940, _1941), float3(_616, _617, _618)) > 0.0f) {
              float _2323 = _1939 + _458;
              float _2324 = _1940 + _459;
              float _2325 = _1941 + _460;
              float _2327 = rsqrt(dot(float3(_2323, _2324, _2325), float3(_2323, _2324, _2325)));
              float _2328 = _2327 * _2323;
              float _2329 = _2327 * _2324;
              float _2330 = _2327 * _2325;
              float _2332 = dot(float3(_616, _617, _618), float3(_458, _459, _460));
              float _2334 = saturate(dot(float3(_616, _617, _618), float3(_2328, _2329, _2330)));
              float _2335 = saturate(dot(float3(_616, _617, _618), float3(_1939, _1940, _1941)));
              float _2336 = _395.w * _395.w;
              float _2337 = _2336 * _2336;
              float _2341 = ((_2334 * _2334) * (_2337 + -1.0f)) + 1.0f;
              float _2345 = abs(_2332);
              float _2346 = CSCustomConstants_048.y - CSCustomConstants_048.x;
              float _2352 = saturate(select((_2346 == 0.0f), 1e+05f, (1.0f / _2346)) * (_466 - CSCustomConstants_048.x));
              float _2353 = max(CSCustomConstants_048.z, _494);
              float _2354 = max(CSCustomConstants_048.z, _495);
              float _2355 = max(CSCustomConstants_048.z, _496);
              if (!_510) {
                _2373 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _494) - _2353) * _2352) + _2353));
                _2374 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _495) - _2354) * _2352) + _2354));
                _2375 = select(_511, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _496) - _2355) * _2352) + _2355));
              } else {
                _2373 = CSCustomConstants_064.x;
                _2374 = CSCustomConstants_064.x;
                _2375 = CSCustomConstants_064.x;
              }
              float _2379 = saturate(1.0f - abs(dot(float3(_2328, _2329, _2330), float3(_458, _459, _460))));
              float _2380 = _2379 * _2379;
              float _2393 = ((_2380 * _2380) * _2379) * cb13_066x;
              float _2399 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _395.w));
              [branch]
              if (cb12_221z > 0.0f) {
                float _2409 = saturate(_2332);
                float _2412 = (_2335 * 2.0f) * _2409;
                _2431 = ((((_2409 + _2335) - _2412) * _2336) + _2412);
              } else {
                float _2417 = 1.0f - _2337;
                _2431 = (((sqrt(((_2345 * _2345) * _2417) + _2337) * _2335) + 9.999999747378752e-05f) + (sqrt(((_2335 * _2335) * _2417) + _2337) * _2345));
              }
              float _2432 = 0.5f / _2431;
              float _2433 = _2432 * (_2337 / ((_2341 * _2341) * 3.1415200233459473f));
              float _2434 = _2433 * (((_2393 * max(0.0f, (_2373 - _494))) / _2399) + _494);
              float _2435 = _2433 * (((_2393 * max(0.0f, (_2374 - _495))) / _2399) + _495);
              float _2436 = _2433 * (((_2393 * max(0.0f, (_2375 - _496))) / _2399) + _496);
              if (cb12_221y > 0.0f) {
                float4 _2443 = t43.SampleLevel(s10, float2(_395.w, dot(float3(_616, _617, _618), float3(_2432, _2432, _2432))), 0.0f);
                float _2449 = (_2443.x * _494) + _2443.y;
                float _2450 = (_2443.x * _495) + _2443.y;
                float _2451 = (_2443.x * _496) + _2443.y;
                _2486 = ((min((_2449 / max((1.0f - ((1.0f - _2449) * ((_2113 * 0.0476190485060215f) + _494))), 0.0010000000474974513f)), 1.0f) / max(_2449, 9.999999747378752e-05f)) * _2434);
                _2487 = ((min((_2450 / max((1.0f - ((1.0f - _2450) * ((_2114 * 0.0476190485060215f) + _495))), 0.0010000000474974513f)), 1.0f) / max(_2450, 9.999999747378752e-05f)) * _2435);
                _2488 = ((min((_2451 / max((1.0f - ((1.0f - _2451) * ((_2115 * 0.0476190485060215f) + _496))), 0.0010000000474974513f)), 1.0f) / max(_2451, 9.999999747378752e-05f)) * _2436);
              } else {
                _2486 = _2434;
                _2487 = _2435;
                _2488 = _2436;
              }
              _2493 = (_2486 * _2335);
              _2494 = (_2487 * _2335);
              _2495 = (_2488 * _2335);
            } else {
              _2493 = 0.0f;
              _2494 = 0.0f;
              _2495 = 0.0f;
            }
            if (!(_528 == 0)) {
              float _2498 = dot(float3(_389, _390, _391), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
              float _2506 = 1.0010000467300415f - _2498;
              float _2538 = saturate(dot(float3(_619, _620, _621), float3(_1939, _1940, _1941))) * (exp2(log2(1.0f - saturate(dot(float3(_619, _620, _621), float3(_458, _459, _460)))) * 5.0f) * select((((int)(_510 || _511)) || _1929), 0.0f, (select(_520, cb12_223w, cb12_223z) * _657)));
              _2543 = (_2538 * saturate((1.0f - exp2(log2(_2506 - ((_389 - _2498) * _656)) * cb12_223x)) * cb12_223y));
              _2544 = (_2538 * saturate((1.0f - exp2(log2(_2506 - ((_390 - _2498) * _656)) * cb12_223x)) * cb12_223y));
              _2545 = (_2538 * saturate((1.0f - exp2(log2(_2506 - ((_391 - _2498) * _656)) * cb12_223x)) * cb12_223y));
            } else {
              _2543 = 0.0f;
              _2544 = 0.0f;
              _2545 = 0.0f;
            }
            _2556 = ((_2311 * _2305) + _1473);
            _2557 = ((_2313 * _2306) + _1474);
            _2558 = ((_2315 * _2307) + _1475);
            _2559 = ((_2311 * (_2543 + _2493)) + _1476);
            _2560 = ((_2313 * (_2544 + _2494)) + _1477);
            _2561 = ((_2315 * (_2545 + _2495)) + _1478);
          } else {
            _2556 = _1473;
            _2557 = _1474;
            _2558 = _1475;
            _2559 = _1476;
            _2560 = _1477;
            _2561 = _1478;
          }
          uint _2562 = _1479 + 1u;
          if ((uint)_2562 < (uint)_1423) {
            _1473 = _2556;
            _1474 = _2557;
            _1475 = _2558;
            _1476 = _2559;
            _1477 = _2560;
            _1478 = _2561;
            _1479 = _2562;
            continue;
          }
          while(true) {
            _1428 = _2556;
            _1429 = _2557;
            _1430 = _2558;
            _1431 = _2559;
            _1432 = _2560;
            _1433 = _2561;
            break;
          }
          break;
        }
      } else {
        _1428 = _1407;
        _1429 = _1408;
        _1430 = _1409;
        _1431 = _1404;
        _1432 = _1405;
        _1433 = _1406;
      }
      float _1440 = _446 - cb12_000x;
      float _1441 = _447 - cb12_000y;
      float _1456 = ((cb12_185z + -1.0f) * saturate((cb12_219x * sqrt((_1440 * _1440) + (_1441 * _1441))) + cb12_219y)) + 1.0f;
      float _1459 = cb12_184x - cb12_184y;
      if (!(cb12_074x > 0.0f)) {
        float _2567 = cb12_185x - cb12_185y;
        _2578 = (((_2567 * _1413) + cb12_185y) * _1456);
        _2579 = (((_2567 * _1414) + cb12_185y) * _1456);
        _2580 = (((_2567 * _1415) + cb12_185y) * _1456);
      } else {
        _2578 = 1.0f;
        _2579 = 1.0f;
        _2580 = 1.0f;
      }
      float4 _2583 = t2.Load(int3(((int)(_48 + 1u)), _49, 0));
      float4 _2588 = t2.Load(int3(_48, ((int)(_49 + 1u)), 0));
      float _2592 = _2583.x + -0.5f;
      float _2593 = _2583.y + -0.5f;
      float _2594 = _2583.z + -0.5f;
      float _2596 = rsqrt(dot(float3(_2592, _2593, _2594), float3(_2592, _2593, _2594)));
      float _2600 = _2588.x + -0.5f;
      float _2601 = _2588.y + -0.5f;
      float _2602 = _2588.z + -0.5f;
      float _2604 = rsqrt(dot(float3(_2600, _2601, _2602), float3(_2600, _2601, _2602)));
      float _2617 = CSCustomConstants_144.z * _476.z;
      float _2618 = -0.0f - _458;
      float _2619 = -0.0f - _459;
      float _2620 = -0.0f - _460;
      float _2622 = dot(float3(_2618, _2619, _2620), float3(_616, _617, _618)) * 2.0f;
      float _2626 = _2618 - (_2622 * _616);
      float _2627 = _2619 - (_2622 * _617);
      float _2628 = _2620 - (_2622 * _618);
      float _2629 = _395.w * _395.w;
      float _2633 = min(max(max((_2629 * 10.5f), (log2(acos(min(dot(float3(_405, _406, _407), float3((_2596 * _2592), (_2596 * _2593), (_2596 * _2594))), dot(float3(_405, _406, _407), float3((_2604 * _2600), (_2604 * _2601), (_2604 * _2602))))) * 81.4873275756836f) * 0.625f)), 0.0f), 5.0f);
      bool _2634 = (_615 < 0.0f);
      float _2640 = min(max((1.0f / (1.0f - _615)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float _2648 = min(max((1.0f / (_615 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float _2652 = select(_2634, ((_613 * 0.5f) * _2640), ((_613 * -0.5f) * _2648)) + 0.5f;
      float _2654 = select(_2634, ((_614 * -0.5f) * _2640), ((_614 * 0.5f) * _2648)) + 0.5f;
      float _2655 = float((bool)_2634);
      if (_43) {
        _2669 = ((_2655 + 0.01515151560306549f) + (_2652 * 0.9696969985961914f));
        _2670 = ((_2654 * 0.9696969985961914f) + 0.01515151560306549f);
      } else {
        _2669 = ((_2655 + 0.1666666716337204f) + (_2652 * 0.6666666269302368f));
        _2670 = ((_2654 * 0.6666666269302368f) + 0.1666666716337204f);
      }
      float _2671 = _2669 * 0.5f;
      _2673 = 1;
      _2674 = 0.0f;
      _2675 = 0.0f;
      _2676 = 0.0f;
      _2677 = 0.0f;
      _2678 = 0.0f;
      _2679 = 0.0f;
      _2680 = 9.999999747378752e-06f;
      while(true) {
        int _2681 = _2673 * 12;
        float _2717 = 1.0f - abs(mad((cb12_raw[(_2681 + 104)].x), _448, mad((cb12_raw[(_2681 + 103)].x), _447, ((cb12_raw[(_2681 + 102)].x) * _446))) + (cb12_raw[(_2681 + 105)].x));
        float _2718 = 1.0f - abs(mad((cb12_raw[(_2681 + 104)].y), _448, mad((cb12_raw[(_2681 + 103)].y), _447, ((cb12_raw[(_2681 + 102)].y) * _446))) + (cb12_raw[(_2681 + 105)].y));
        float _2719 = 1.0f - abs(mad((cb12_raw[(_2681 + 104)].z), _448, mad((cb12_raw[(_2681 + 103)].z), _447, ((cb12_raw[(_2681 + 102)].z) * _446))) + (cb12_raw[(_2681 + 105)].z));
        int _2723 = asint((cb12_raw[(_2681 + 106)].y));
        [branch]
        if (!(_2617 == -1.0f)) {
          _2735 = (select(((_2723 & 1) != 0), 1.0f, _2617) * select(((_2723 & 2) != 0), 1.0f, (1.0f - _2617)));
        } else {
          _2735 = 1.0f;
        }
        if (((int)(((int)((int)(_2717 > 0.0f) && (int)(_2718 > 0.0f))) && (int)(_2719 > 0.0f))) && (int)(_2735 > 0.0f)) {
          float _2763 = ((((_2735 * (1.0f - _2680)) * saturate((cb12_raw[(_2681 + 101)].x) * _2717)) * saturate((cb12_raw[(_2681 + 101)].y) * _2718)) * saturate((cb12_raw[(_2681 + 101)].z) * _2719)) * (cb12_raw[(_2681 + 100)].x);
          float _2766 = _2763 * (cb12_raw[(_2681 + 106)].x);
          float _2770 = float((int)(asint(cb12_raw[(_2681 + 111)].x)));
          float _2772 = (_2770 + _2670) * 0.1428571492433548f;
          if (_43) {
            float4 _2776 = t8.SampleLevel(s6, float2(_2671, _2772), 0.0f);
            _2793 = (_2776.x * _2763);
            _2794 = (_2776.y * _2763);
            _2795 = (_2776.z * _2763);
          } else {
            float4 _2785 = t6.SampleLevel(s6, float2(_2671, _2772), 0.0f);
            _2793 = (_2785.x * _2766);
            _2794 = (_2785.y * _2766);
            _2795 = (_2785.z * _2766);
          }
          float _2843 = 1.0f / mad((cb12_raw[(_2681 + 109)].x), _2628, mad((cb12_raw[(_2681 + 108)].x), _2627, ((cb12_raw[(_2681 + 107)].x) * _2626)));
          float _2844 = 1.0f / mad((cb12_raw[(_2681 + 109)].y), _2628, mad((cb12_raw[(_2681 + 108)].y), _2627, ((cb12_raw[(_2681 + 107)].y) * _2626)));
          float _2845 = 1.0f / mad((cb12_raw[(_2681 + 109)].z), _2628, mad((cb12_raw[(_2681 + 108)].z), _2627, ((cb12_raw[(_2681 + 107)].z) * _2626)));
          float _2846 = _2843 * (mad((cb12_raw[(_2681 + 109)].x), _448, mad((cb12_raw[(_2681 + 108)].x), _447, ((cb12_raw[(_2681 + 107)].x) * _446))) + (cb12_raw[(_2681 + 110)].x));
          float _2847 = _2844 * (mad((cb12_raw[(_2681 + 109)].y), _448, mad((cb12_raw[(_2681 + 108)].y), _447, ((cb12_raw[(_2681 + 107)].y) * _446))) + (cb12_raw[(_2681 + 110)].y));
          float _2848 = _2845 * (mad((cb12_raw[(_2681 + 109)].z), _448, mad((cb12_raw[(_2681 + 108)].z), _447, ((cb12_raw[(_2681 + 107)].z) * _446))) + (cb12_raw[(_2681 + 110)].z));
          float _2862 = min(max((_2843 - _2846), ((-0.0f - _2843) - _2846)), min(max((_2844 - _2847), ((-0.0f - _2844) - _2847)), max((_2845 - _2848), ((-0.0f - _2845) - _2848))));
          float _2867 = (_2862 * _2626) + (_446 - (cb12_raw[(_2681 + 100)].y));
          float _2869 = (_2862 * _2627) + (_447 - (cb12_raw[(_2681 + 100)].z));
          float _2871 = (_2862 * _2628) + (_448 - (cb12_raw[(_2681 + 100)].w));
          float _2873 = rsqrt(dot(float3(_2867, _2869, _2871), float3(_2867, _2869, _2871)));
          float _2874 = _2867 * _2873;
          float _2875 = _2869 * _2873;
          float _2876 = _2871 * _2873;
          bool _2877 = (_2876 < 0.0f);
          float _2883 = min(max((1.0f / (1.0f - _2876)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
          float _2891 = min(max((1.0f / (_2876 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
          float4 _2908 = t7.SampleLevel(s6, float2((((float((bool)_2877) + 0.1666666716337204f) + ((select(_2877, ((_2874 * 0.5f) * _2883), ((_2874 * -0.5f) * _2891)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((_2770 + 0.1666666716337204f) + ((select(_2877, ((_2875 * -0.5f) * _2883), ((_2875 * 0.5f) * _2891)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _2633);
          _2919 = (_2763 + _2680);
          _2920 = (_2793 + _2679);
          _2921 = (_2794 + _2678);
          _2922 = (_2795 + _2677);
          _2923 = ((_2908.x * _2766) + _2676);
          _2924 = ((_2908.y * _2766) + _2675);
          _2925 = ((_2908.z * _2766) + _2674);
        } else {
          _2919 = _2680;
          _2920 = _2679;
          _2921 = _2678;
          _2922 = _2677;
          _2923 = _2676;
          _2924 = _2675;
          _2925 = _2674;
        }
        int _2926 = _2673 + 1;
        bool _2928 = (_2919 < 0.9990000128746033f);
        if ((int)((uint)_2926 < (uint)7) && _2928) {
          _2673 = _2926;
          _2674 = _2925;
          _2675 = _2924;
          _2676 = _2923;
          _2677 = _2922;
          _2678 = _2921;
          _2679 = _2920;
          _2680 = _2919;
          continue;
        }
        [branch]
        if (_2928) {
          float _2935 = cb12_100x * (1.0f - _2919);
          float _2939 = _2935 * cb12_106x;
          float _2942 = float((int)(cb12_111x));
          float _2944 = (_2942 + _2670) * 0.1428571492433548f;
          if (_43) {
            float4 _2948 = t8.SampleLevel(s6, float2(_2671, _2944), 0.0f);
            _2965 = (_2948.x * _2935);
            _2966 = (_2948.y * _2935);
            _2967 = (_2948.z * _2935);
          } else {
            float4 _2957 = t6.SampleLevel(s6, float2(_2671, _2944), 0.0f);
            _2965 = (_2957.x * _2939);
            _2966 = (_2957.y * _2939);
            _2967 = (_2957.z * _2939);
          }
          bool _2971 = (_2628 < 0.0f);
          float _2977 = min(max((1.0f / (1.0f - _2628)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
          float _2985 = min(max((1.0f / (_2628 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
          float4 _3002 = t7.SampleLevel(s6, float2((((float((bool)_2971) + 0.1666666716337204f) + ((select(_2971, ((_2626 * 0.5f) * _2977), ((_2626 * -0.5f) * _2985)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((_2942 + 0.1666666716337204f) + ((select(_2971, ((_2627 * -0.5f) * _2977), ((_2627 * 0.5f) * _2985)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _2633);
          _3013 = (_2935 + _2919);
          _3014 = (_2965 + _2920);
          _3015 = (_2966 + _2921);
          _3016 = (_2967 + _2922);
          _3017 = ((_3002.x * _2939) + _2923);
          _3018 = ((_3002.y * _2939) + _2924);
          _3019 = ((_3002.z * _2939) + _2925);
        } else {
          _3013 = _2919;
          _3014 = _2920;
          _3015 = _2921;
          _3016 = _2922;
          _3017 = _2923;
          _3018 = _2924;
          _3019 = _2925;
        }
        float _3020 = 1.0f / _3013;
        float _3021 = _3020 * _3014;
        float _3022 = _3020 * _3015;
        float _3023 = _3020 * _3016;
        float _3024 = _3020 * _3017;
        float _3025 = _3020 * _3018;
        float _3026 = _3020 * _3019;
        if (!_1417) {
          float _3033 = cb13_064x - cb13_064y;
          float _3040 = cb13_064z - cb13_064w;
          _3054 = (((_3040 * _1413) + cb13_064w) * _3024);
          _3055 = (((_3040 * _1414) + cb13_064w) * _3025);
          _3056 = (((_3040 * _1415) + cb13_064w) * _3026);
          _3057 = (((_3033 * _1413) + cb13_064y) * _3021);
          _3058 = (((_3033 * _1414) + cb13_064y) * _3022);
          _3059 = (((_3033 * _1415) + cb13_064y) * _3023);
        } else {
          _3054 = _3024;
          _3055 = _3025;
          _3056 = _3026;
          _3057 = _3021;
          _3058 = _3022;
          _3059 = _3023;
        }
        if (_43) {
          if (_510) {
            _3067 = (_3057 * CSCustomConstants_144.w);
            _3068 = (_3058 * CSCustomConstants_144.w);
            _3069 = (_3059 * CSCustomConstants_144.w);
          } else {
            _3067 = _3057;
            _3068 = _3058;
            _3069 = _3059;
          }
          float _3071 = abs(dot(float3(_613, _614, _615), float3(_458, _459, _460)));
          float _3075 = saturate(1.0f - abs(max(_3071, _3071)));
          float _3076 = _3075 * _3075;
          float _3079 = 1.0f - _395.w;
          float _3082 = 1.0f - _494;
          float _3083 = 1.0f - _495;
          float _3084 = 1.0f - _496;
          float _3085 = max(0.0f, _3082);
          float _3086 = max(0.0f, _3083);
          float _3087 = max(0.0f, _3084);
          float _3090 = ((_3076 * _3076) * _3075) * min(_513, cb13_066y);
          float _3096 = (cb13_066w + 1.0f) - (cb13_066w * _3079);
          float _3100 = _3082 - ((_3090 * _3085) / _3096);
          float _3101 = _3083 - ((_3090 * _3086) / _3096);
          float _3102 = _3084 - ((_3087 * _3090) / _3096);
          if (CSCustomConstants_144.y > 0.0f) {
            int _3106 = ((int)(uint)((int)(_407 > 0.0f))) << 1u;
            float _3108 = float((int)(_3106 + -1));
            float _3110 = -1.0f / (_3108 + _407);
            float _3111 = _3110 * _406;
            float _3112 = _3111 * _405;
            float _3125 = rsqrt(dot(float3(_458, _459, _460), float3(_458, _459, _460)));
            float _3126 = _3125 * _458;
            float _3127 = _3125 * _459;
            float _3128 = _3125 * _460;
            float _3131 = mad((float((int)(1 - _3106)) * _405), _3128, mad((_3112 * _3108), _3127, (_3126 * ((((_405 * _405) * _3110) * _3108) + 1.0f))));
            float _3134 = mad((-0.0f - _406), _3128, mad((_3108 + (_3111 * _406)), _3127, (_3126 * _3112)));
            float _3137 = mad(_407, _3128, mad(_406, _3127, (_3126 * _405)));
            float _3142 = (_2629 * 0.2877933979034424f) + 1.0f;
            float _3144 = 1.0f - (rsqrt(dot(float3(_3131, _3134, _3137), float3(_3131, _3134, _3137))) * _3137);
            float _3154 = (((_3144 * _2629) * ((((((_3144 * 0.07144299894571304f) + -0.332181453704834f) * _3144) + 0.4918818771839142f) * _3144) + 0.05710852891206741f)) + 1.0f) / _3142;
            float _3157 = (1.0f / _3142) * ((_2629 * 0.07248824834823608f) + 1.0f);
            float _3164 = 1.0f - _3157;
            float _3177 = 1.0f - _3154;
            _3238 = _3087;
            _3239 = _3086;
            _3240 = _3085;
            _3241 = _3079;
            _3242 = ((_3100 * _3067) * (((((_389 * _389) * _3157) / (1.0f - (_3164 * _389))) * _3177) + (_3154 * _389)));
            _3243 = ((_3101 * _3068) * (((((_390 * _390) * _3157) / (1.0f - (_3164 * _390))) * _3177) + (_3154 * _390)));
            _3244 = ((_3102 * _3069) * (((((_391 * _391) * _3157) / (1.0f - (_3164 * _391))) * _3177) + (_3154 * _391)));
          } else {
            _3238 = _3087;
            _3239 = _3086;
            _3240 = _3085;
            _3241 = _3079;
            _3242 = ((_3100 * _3067) * _389);
            _3243 = ((_3101 * _3068) * _390);
            _3244 = ((_3102 * _3069) * _391);
          }
        } else {
          float _3202 = abs(dot(float3(_613, _614, _615), float3(_458, _459, _460)));
          float _3206 = saturate(1.0f - abs(max(_3202, _3202)));
          float _3207 = _3206 * _3206;
          float _3210 = 1.0f - _395.w;
          float _3213 = 1.0f - _494;
          float _3214 = 1.0f - _495;
          float _3215 = 1.0f - _496;
          float _3216 = max(0.0f, _3213);
          float _3217 = max(0.0f, _3214);
          float _3218 = max(0.0f, _3215);
          float _3221 = ((_3207 * _3207) * _3206) * min(_513, cb13_066y);
          float _3227 = (cb13_066w + 1.0f) - (cb13_066w * _3210);
          _3238 = _3218;
          _3239 = _3217;
          _3240 = _3216;
          _3241 = _3210;
          _3242 = (((_1456 * ((_1459 * _1413) + cb12_184y)) * _3057) * (_3213 - ((_3221 * _3216) / _3227)));
          _3243 = (((_1456 * ((_1459 * _1414) + cb12_184y)) * _3058) * (_3214 - ((_3221 * _3217) / _3227)));
          _3244 = (((_1456 * ((_1459 * _1415) + cb12_184y)) * _3059) * (_3215 - ((_3218 * _3221) / _3227)));
        }
        float _3249 = abs(dot(float3(_616, _617, _618), float3(_458, _459, _460)));
        float _3253 = saturate(1.0f - abs(max(_3249, _3249)));
        float _3254 = _3253 * _3253;
        float _3261 = ((_3254 * _3254) * _3253) * min(_513, cb13_066y);
        float _3267 = (cb13_066w + 1.0f) - (cb13_066w * _3241);
        float4 _3278 = t16.Load(int3(_48, _49, 0));
        float _3294 = ((((cb12_069z + -1.0f) * _658) + 1.0f) * (saturate((cb12_187x * _3278.x) + cb12_188x) + -1.0f)) + 1.0f;
        bool _3300 = (_476.z < 0.9900000095367432f);
        if (_3300) {
          _3305 = cb12_287w;
        } else {
          _3305 = 1.0f;
        }
        float _3309 = log2(_3294 * _476.w);
        float _3311 = exp2((cb12_288x * _3305) * _3309);
        if (_3300) {
          _3316 = cb12_287w;
        } else {
          _3316 = 1.0f;
        }
        float _3320 = exp2((_3309 * cb12_288y) * _3316);
        if (_3300) {
          _3325 = cb12_287w;
        } else {
          _3325 = 1.0f;
        }
        float _3328 = log2((_3294 * cb12_069x) + cb12_069y);
        if (_3300) {
          _3335 = cb12_287w;
        } else {
          _3335 = 1.0f;
        }
        float _3346 = exp2((_3325 * cb12_288z) * _3328) * cb12_184z;
        float _3350 = exp2((_3328 * cb12_288w) * _3335) * cb12_184w;
        _3355 = _612;
        _3356 = (_3311 * _3242);
        _3357 = (_3311 * _3243);
        _3358 = (_3311 * _3244);
        _3359 = (_3346 * _1428);
        _3360 = (_3346 * _1429);
        _3361 = (_3346 * _1430);
        _3362 = (_3350 * _1431);
        _3363 = (_3350 * _1432);
        _3364 = (_3350 * _1433);
        _3365 = (((_3054 * _2578) * (((_3261 * _3240) / _3267) + _494)) * _3320);
        _3366 = (((_3055 * _2579) * (((_3261 * _3239) / _3267) + _495)) * _3320);
        _3367 = (((_3056 * _2580) * (((_3261 * _3238) / _3267) + _496)) * _3320);
        if (_3355 == 0) {
          _3374 = (_3359 * _389);
          _3375 = (_3360 * _390);
          _3376 = (_3361 * _391);
        } else {
          _3374 = _3359;
          _3375 = _3360;
          _3376 = _3361;
        }
        if (!_43) {
          _3382 = (_3356 * _389);
          _3383 = (_3357 * _390);
          _3384 = (_3358 * _391);
        } else {
          _3382 = _3356 * night_skylight;
          _3383 = _3357 * night_skylight;
          _3384 = _3358 * night_skylight;
        }
        float _3394 = max(0.0f, _3374) + max(0.0f, _3382);
        float _3395 = max(0.0f, _3375) + max(0.0f, _3383);
        float _3396 = max(0.0f, _3376) + max(0.0f, _3384);
        if (cb12_074x > 0.0f) {
          u0[int2(_48, _49)] = float4((max(0.0f, _3362) + _3394), (max(0.0f, _3363) + _3395), (max(0.0f, _3364) + _3396), 1.0f);
        } else {
          u0[int2(_48, _49)] = float4((max(0.0f, (_3365 + _3362)) + _3394), (max(0.0f, (_3366 + _3363)) + _3395), (max(0.0f, (_3367 + _3364)) + _3396), 1.0f);
        }
        if ((uint)_51 < (uint)256) {
          if ((uint)_51 < (uint)_global_5) {
            _3431 = (_global_4[_51]);
          } else {
            _3431 = 256;
          }
          u2.Store(((int)(((uint((cb12_024x * _93) + _92) << 8u) + _51) << 2u)), asuint(_3431));
        }
        break;
      }
    }
  } else {
    _3355 = _33;
    _3356 = 0.0f;
    _3357 = 0.0f;
    _3358 = 0.0f;
    _3359 = 0.0f;
    _3360 = 0.0f;
    _3361 = 0.0f;
    _3362 = 0.0f;
    _3363 = 0.0f;
    _3364 = 0.0f;
    _3365 = 0.0f;
    _3366 = 0.0f;
    _3367 = 0.0f;
    if (_3355 == 0) {
      _3374 = (_3359 * _389);
      _3375 = (_3360 * _390);
      _3376 = (_3361 * _391);
    } else {
      _3374 = _3359;
      _3375 = _3360;
      _3376 = _3361;
    }
    if (!_43) {
      _3382 = (_3356 * _389);
      _3383 = (_3357 * _390);
      _3384 = (_3358 * _391);
    } else {
      _3382 = _3356 * night_skylight;
      _3383 = _3357 * night_skylight;
      _3384 = _3358 * night_skylight;
    }
    float _3394 = max(0.0f, _3374) + max(0.0f, _3382);
    float _3395 = max(0.0f, _3375) + max(0.0f, _3383);
    float _3396 = max(0.0f, _3376) + max(0.0f, _3384);
    if (cb12_074x > 0.0f) {
      u0[int2(_48, _49)] = float4((max(0.0f, _3362) + _3394), (max(0.0f, _3363) + _3395), (max(0.0f, _3364) + _3396), 1.0f);
    } else {
      u0[int2(_48, _49)] = float4((max(0.0f, (_3365 + _3362)) + _3394), (max(0.0f, (_3366 + _3363)) + _3395), (max(0.0f, (_3367 + _3364)) + _3396), 1.0f);
    }
    if ((uint)_51 < (uint)256) {
      if ((uint)_51 < (uint)_global_5) {
        _3431 = (_global_4[_51]);
      } else {
        _3431 = 256;
      }
      u2.Store(((int)(((uint((cb12_024x * _93) + _92) << 8u) + _51) << 2u)), asuint(_3431));
    }
  }
}
