#include "shared.h"
#ifdef WITCHER_GRAPHICS_CUSTOM_LIGHTING
#define GraphicsSurfaceCloudShadow(world, native) HartapfelSurfaceCloudShadow(world, native, float3(cb12_000x, cb12_000y, cb12_000z), asuint(hartapfel_jitter))
#else
#include "clouds/shadow_receiver.hlsli"
#endif
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


Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float> t19 : register(t19);

Texture2DArray<float> t15 : register(t15);

Texture2DArray<float> t8 : register(t8);

Texture2D<float> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

Texture2D<uint2> t4 : register(t4);

cbuffer cb12 : register(b12) {
#ifdef WITCHER_GRAPHICS_CUSTOM_LIGHTING
  float4 hartapfel_jitter : packoffset(c286);
#endif
  float cb12_000x : packoffset(c000.x);
  float cb12_000y : packoffset(c000.y);
  float cb12_000z : packoffset(c000.z);
  float cb12_001x : packoffset(c001.x);
  float cb12_001y : packoffset(c001.y);
  float cb12_001z : packoffset(c001.z);
  float cb12_001w : packoffset(c001.w);
  float cb12_002x : packoffset(c002.x);
  float cb12_002y : packoffset(c002.y);
  float cb12_002z : packoffset(c002.z);
  float cb12_002w : packoffset(c002.w);
  float cb12_003x : packoffset(c003.x);
  float cb12_003y : packoffset(c003.y);
  float cb12_003z : packoffset(c003.z);
  float cb12_003w : packoffset(c003.w);
  float cb12_004x : packoffset(c004.x);
  float cb12_004y : packoffset(c004.y);
  float cb12_004z : packoffset(c004.z);
  float cb12_004w : packoffset(c004.w);
  float cb12_013x : packoffset(c013.x);
  float cb12_013y : packoffset(c013.y);
  float cb12_013w : packoffset(c013.w);
  float cb12_014x : packoffset(c014.x);
  float cb12_014y : packoffset(c014.y);
  float cb12_014w : packoffset(c014.w);
  float cb12_015x : packoffset(c015.x);
  float cb12_015y : packoffset(c015.y);
  float cb12_015w : packoffset(c015.w);
  float cb12_016x : packoffset(c016.x);
  float cb12_016y : packoffset(c016.y);
  float cb12_016w : packoffset(c016.w);
  float cb12_019x : packoffset(c019.x);
  float cb12_019y : packoffset(c019.y);
  float cb12_019z : packoffset(c019.z);
  float cb12_019w : packoffset(c019.w);
  float cb12_020x : packoffset(c020.x);
  float cb12_020y : packoffset(c020.y);
  float cb12_020z : packoffset(c020.z);
  float cb12_020w : packoffset(c020.w);
  float cb12_021x : packoffset(c021.x);
  float cb12_021y : packoffset(c021.y);
  float cb12_022x : packoffset(c022.x);
  float cb12_022y : packoffset(c022.y);
  float cb12_023x : packoffset(c023.x);
  float cb12_023y : packoffset(c023.y);
  float cb12_066x : packoffset(c066.x);
  float cb12_066w : packoffset(c066.w);
  float cb12_067x : packoffset(c067.x);
  float cb12_067y : packoffset(c067.y);
  float cb12_068x : packoffset(c068.x);
  float cb12_068y : packoffset(c068.y);
  float cb12_211x : packoffset(c211.x);
  float cb12_211y : packoffset(c211.y);
  float cb12_211z : packoffset(c211.z);
  float cb12_211w : packoffset(c211.w);
  float cb12_212x : packoffset(c212.x);
  float cb12_212y : packoffset(c212.y);
  float cb12_212z : packoffset(c212.z);
  float cb12_212w : packoffset(c212.w);
  float cb12_213x : packoffset(c213.x);
  float cb12_213y : packoffset(c213.y);
  float cb12_213z : packoffset(c213.z);
  float cb12_213w : packoffset(c213.w);
  float cb12_214x : packoffset(c214.x);
  float cb12_214y : packoffset(c214.y);
  float cb12_214z : packoffset(c214.z);
  float cb12_214w : packoffset(c214.w);
  uint cb12_padding : packoffset(c340.w);
};

cbuffer cb13 : register(b13) {
  float4 cb13_raw[3589] : packoffset(c0);
};

#define cb13_000x (cb13_raw[0].x)
#define cb13_000y (cb13_raw[0].y)
#define cb13_036x (cb13_raw[36].x)
#define cb13_000z (cb13_raw[0].z)
#define cb13_035x (cb13_raw[35].x)
#define cb13_008w (cb13_raw[8].w)
#define cb13_006y (cb13_raw[6].y)
#define cb13_034x (asint(cb13_raw[34].x))
#define cb13_007w (cb13_raw[7].w)
#define cb13_006x (cb13_raw[6].x)
#define cb13_034y (asint(cb13_raw[34].y))
#define cb13_035w (cb13_raw[35].w)
#define cb13_034z (cb13_raw[34].z)
#define cb13_008x (cb13_raw[8].x)
#define cb13_007y (cb13_raw[7].y)
#define cb13_034w (cb13_raw[34].w)
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
#define cb13_005y (cb13_raw[5].y)
#define cb13_005z (cb13_raw[5].z)
#define cb13_006z (cb13_raw[6].z)
#define cb13_008y (cb13_raw[8].y)
#define cb13_007x (cb13_raw[7].x)
#define cb13_007z (cb13_raw[7].z)
#define cb13_008z (cb13_raw[8].z)
#define cb13_009x (cb13_raw[9].x)
#define cb13_009y (cb13_raw[9].y)
#define cb13_009z (cb13_raw[9].z)
#define cb13_009w (cb13_raw[9].w)
#define cb13_016x (cb13_raw[16].x)
#define cb13_016y (cb13_raw[16].y)
#define cb13_016z (cb13_raw[16].z)
#define cb13_016w (cb13_raw[16].w)
#define cb13_017x (asint(cb13_raw[17].x))

cbuffer cb6 : register(b6) {
  float CBGlobalShadowsConstants_000 : packoffset(c000.x);
  float CBGlobalShadowsConstants_004 : packoffset(c000.y);
  float CBGlobalShadowsConstants_008 : packoffset(c000.z);
  float CBGlobalShadowsConstants_012 : packoffset(c000.w);
  int CBGlobalShadowsConstants_016 : packoffset(c001.x);
  int CBGlobalShadowsConstants_020 : packoffset(c001.y);
  float CBGlobalShadowsConstants_024 : packoffset(c001.z);
  int CBGlobalShadowsConstants_028 : packoffset(c001.w);
  float CBGlobalShadowsConstants_032 : packoffset(c002.x);
  float CBGlobalShadowsConstants_036 : packoffset(c002.y);
  float CBGlobalShadowsConstants_040 : packoffset(c002.z);
  float CBGlobalShadowsConstants_044 : packoffset(c002.w);
  float CBGlobalShadowsConstants_048 : packoffset(c003.x);
  float CBGlobalShadowsConstants_052 : packoffset(c003.y);
  int CBGlobalShadowsConstants_056 : packoffset(c003.z);
  int CBGlobalShadowsConstants_060 : packoffset(c003.w);
  int CBGlobalShadowsConstants_064 : packoffset(c004.x);
  int CBGlobalShadowsConstants_068 : packoffset(c004.y);
  int CBGlobalShadowsConstants_072 : packoffset(c004.z);
  int CBGlobalShadowsConstants_076 : packoffset(c004.w);
};

SamplerState s14 : register(s14);

SamplerComparisonState s9 : register(s9);

SamplerState s10 : register(s10);

#include "lighting/shadows.hlsli"

float4 main(
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  float _20[4];
  uint _21 = uint(SV_Position.x);
  uint _22 = uint(SV_Position.y);
  float _24 = t0.Load(int3(_21, _22, 0));
  float _30 = (cb12_022x * _24.x) + cb12_022y;
  bool _31 = (_30 >= 1.0f);
  bool _107;
  int _130;
  int _165;
  float _239;
  float _240;
  float _286;
  float _489;
  float _490;
  bool _491;
  float _1009;
  float _1019;
  float _1100;
  float _1411;
  float _1625;
  float _1626;
  float _1627;
  float _1628;
  float _1629;
  float _1630;
  float _1631;
  float _1632;
  float _1633;
  float _1748;
  float _1749;
  float _1750;
  float _1751;
  float _1752;
  float _1753;
  float _1754;
  float _1755;
  float _1783;
  int _1784;
  int _1794;
  float _1843;
  float _1849;
  if (!_31) {
    float4 _39 = t1.Load(int3(_21, _22, 0));
    float4 _44 = t2.Load(int3(_21, _22, 0));
    float _46 = float((uint)_21);
    float _47 = float((uint)_22);
    float _83 = mad(cb12_213w, _24.x, mad(cb12_212w, _47, (cb12_211w * _46))) + cb12_214w;
    float _84 = (mad(cb12_213x, _24.x, mad(cb12_212x, _47, (cb12_211x * _46))) + cb12_214x) / _83;
    float _85 = (mad(cb12_213y, _24.x, mad(cb12_212y, _47, (cb12_211y * _46))) + cb12_214y) / _83;
    float _86 = (mad(cb12_213z, _24.x, mad(cb12_212z, _47, (cb12_211z * _46))) + cb12_214z) / _83;
    float _87 = _39.x + -0.5f;
    float _88 = _39.y + -0.5f;
    float _89 = _39.z + -0.5f;
    float _91 = rsqrt(dot(float3(_87, _88, _89), float3(_87, _88, _89)));
    float _92 = _91 * _87;
    float _93 = _91 * _88;
    float _94 = _91 * _89;
    uint _97 = uint((_44.w * 255.0f) + 0.5f);
    bool _99 = ((_97 & 7) == 1);
    if (!(_99 && (int)((_97 & 80) != 0))) {
      _107 = ((_97 & 128) != 0);
    } else {
      _107 = true;
    }
    float _115 = _84 - cb12_000x;
    float _116 = _85 - cb12_000y;
    float _119 = (_115 * _115) + (_116 * _116);
    float _120 = sqrt(_119);
    [branch]
    if (_120 < cb13_035x) {
      if (!(cb13_034x == 0)) {
        _130 = 0;
        while(true) {
          float _135 = _84 - (cb13_raw[((int)(_130 + 37u))].x);
          float _136 = _85 - (cb13_raw[((int)(_130 + 37u))].y);
          float _141 = dot(float2(_135, _136), float2((cb13_raw[((int)(_130 + 42u))].x), (cb13_raw[((int)(_130 + 42u))].y)));
          float _144 = dot(float2(_135, _136), float2((cb13_raw[((int)(_130 + 42u))].z), (cb13_raw[((int)(_130 + 42u))].w)));
          if ((int)(_141 > 0.0f) && (int)(_144 > 0.0f)) {
            if (!((int)(_141 < 1.0f) && (int)(_144 < 1.0f))) {
              int _153 = _130 + 1;
              if ((uint)_153 < (uint)cb13_034x) {
                _130 = _153;
                continue;
              } else {
                _286 = 1.0f;
                uint _287 = uint(_46);
                uint _288 = uint(_47);
                float _296 = frac(sin(dot(float2(float((uint)_287), float((uint)_288)), float2(12.989800453186035f, 78.23300170898438f))) * 43758.546875f) * 6.2831854820251465f;
                float _316 = mad(cb13_005x, _86, mad(cb13_004x, _85, (cb13_003x * _84))) + cb13_006x;
                float _320 = mad(cb13_005y, _86, mad(cb13_004y, _85, (cb13_003y * _84))) + cb13_006y;
                float _324 = mad(cb13_005z, _86, mad(cb13_004z, _85, (cb13_003z * _84))) + cb13_006z;
                [branch]
                if (ImprovedSoftShadows()) {
                  _1019 = GraphicsDirectionalVisibility(float3(_84, _85, _86), _107);
                } else {
if (!(abs(_324) >= 0.9990000128746033f)) {
                  float _354 = max(abs(_316 - cb13_007x), abs(_320 - cb13_008x));
                  float _355 = max(abs(_316 - cb13_007y), abs(_320 - cb13_008y));
                  float _356 = max(abs(_316 - cb13_007z), abs(_320 - cb13_008z));
                  float _357 = max(abs(_316 - cb13_007w), abs(_320 - cb13_008w));
                  float _381 = dot(float4(float((bool)(uint)(_354 < cb13_009x)), float((bool)(uint)(_355 < cb13_009y)), float((bool)(uint)(_356 < cb13_009z)), float((bool)(uint)(_357 < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                  [branch]
                  if (!(_381 < 0.5f)) {
                    _20[0] = saturate((((_354 / cb13_009x) + -1.0f) + cb13_016x) / cb13_016x);
                    _20[1] = saturate((((_355 / cb13_009y) + -1.0f) + cb13_016y) / cb13_016y);
                    _20[2] = saturate((((_356 / cb13_009z) + -1.0f) + cb13_016z) / cb13_016z);
                    _20[3] = saturate((((_357 / cb13_009w) + -1.0f) + cb13_016w) / cb13_016w);
                    int _415 = int(cb13_014z - _381);
                    int _417 = int(cb13_014z) + -1;
                    int _420 = _288 & 1;
                    int _429 = ((uint)(_288) >> 1) & 1;
                    int _439 = ((uint)(_288) >> 2) & 1;
                    int _449 = ((uint)(_288) >> 3) & 1;
                    int _463 = min((((int)(uint)((int)(((float((int)(select(((_287 & 8) == 0), select((_449 != 0), 3, 0), (2 - _449)) | ((int)(((uint)(select(((_287 & 4) == 0), select((_439 != 0), 3, 0), (2 - _439)) | ((select(((_287 & 2) == 0), select((_429 != 0), 3, 0), (2 - _429)) | (select(((_287 & 1) == 0), select((_420 != 0), 3, 0), (2 - _420)) << 2u)) << 2u))) << 2u)))) + 0.5f) * 0.00390625f) < (_20[_415])))) + _415), _417);
                    float _471 = ((cb13_raw[((int)(_463 + 10u))].z) * _316) + (cb13_raw[((int)(_463 + 10u))].x);
                    float _472 = (cb13_raw[((int)(_463 + 10u))].y) - ((cb13_raw[((int)(_463 + 10u))].z) * _320);
                    if (!_107) {
                      _489 = (cb13_raw[((int)(_463 + 10u))].w);
                      _490 = 0.0f;
                      _491 = false;
                    } else {
                      _489 = (cb13_raw[((int)(_463 + 18u))].x);
                      _490 = (cb13_raw[((int)(_463 + 18u))].y);
                      _491 = ((cb13_raw[((int)(_463 + 18u))].z) > 0.0f);
                    }
                    float _492 = float((int)(_463));
                    float _493 = _489 * min(max(((1.0f / sqrt(max(dot(float3(_92, _93, _94), float3(cb13_000x, cb13_000y, cb13_000z)), 0.0f))) + -1.0f), 1.0f), 4.0f);
                    float _500 = t8.SampleCmpLevelZero(s9, float3(_471, _472, _492), _324);
                    if (!(_491 || (int)((int)cb13_017x < (int)1))) {
                      float _503 = sin(_296);
                      float _504 = cos(_296);
                      float _505 = _493 * -0.2633539140224457f;
                      float _506 = _493 * 0.03965381905436516f;
                      float _517 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _506)) + (_504 * _505)), (((_503 * _505) + _472) + (_504 * _506)), _492), (_324 - (_490 * 0.03703703731298447f)));
                      float _520 = _493 * -0.7172024250030518f;
                      float _521 = _493 * 0.3683032989501953f;
                      float _532 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _521)) + (_504 * _520)), (((_503 * _520) + _472) + (_504 * _521)), _492), (_324 - (_490 * 0.07407407462596893f)));
                      float _535 = _493 * -0.019953060895204544f;
                      float _536 = _493 * -0.39883920550346375f;
                      float _547 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _536)) + (_504 * _535)), (((_503 * _535) + _472) + (_504 * _536)), _492), (_324 - (_490 * 0.1111111119389534f)));
                      float _550 = _493 * -0.4409937858581543f;
                      float _551 = _493 * -0.2210099995136261f;
                      float _562 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _551)) + (_504 * _550)), (((_503 * _550) + _472) + (_504 * _551)), _492), (_324 - (_490 * 0.14814814925193787f)));
                      float _565 = _493 * 0.22003920376300812f;
                      float _566 = _493 * 0.29434481263160706f;
                      float _577 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _566)) + (_504 * _565)), (((_503 * _565) + _472) + (_504 * _566)), _492), (_324 - (_490 * 0.18518517911434174f)));
                      float _580 = _493 * -0.7675657272338867f;
                      float _581 = _493 * -0.14827530086040497f;
                      float _592 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _581)) + (_504 * _580)), (((_503 * _580) + _472) + (_504 * _581)), _492), (_324 - (_490 * 0.2222222238779068f)));
                      float _595 = _493 * -0.23810189962387085f;
                      float _596 = _493 * 0.5471062064170837f;
                      float _607 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _596)) + (_504 * _595)), (((_503 * _595) + _472) + (_504 * _596)), _492), (_324 - (_490 * 0.25925925374031067f)));
                      float _610 = _493 * 0.2173030972480774f;
                      float _611 = _493 * -0.13458789885044098f;
                      float _622 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _611)) + (_504 * _610)), (((_503 * _610) + _472) + (_504 * _611)), _492), (_324 - (_490 * 0.29629629850387573f)));
                      float _625 = _493 * -0.6387773752212524f;
                      float _626 = _493 * 0.7561339139938354f;
                      float _637 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _626)) + (_504 * _625)), (((_503 * _625) + _472) + (_504 * _626)), _492), (_324 - (_490 * 0.3333333432674408f)));
                      float _640 = _493 * -0.16141439974308014f;
                      float _641 = _493 * 0.9776520729064941f;
                      float _652 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _641)) + (_504 * _640)), (((_503 * _640) + _472) + (_504 * _641)), _492), (_324 - (_490 * 0.37037035822868347f)));
                      float _655 = _493 * 0.215631902217865f;
                      float _656 = _493 * 0.6123412847518921f;
                      float _667 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _656)) + (_504 * _655)), (((_503 * _655) + _472) + (_504 * _656)), _492), (_324 - (_490 * 0.40740740299224854f)));
                      float _670 = _493 * 0.23288750648498535f;
                      float _671 = _493 * 0.9452872276306152f;
                      float _682 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _671)) + (_504 * _670)), (((_503 * _670) + _472) + (_504 * _671)), _492), (_324 - (_490 * 0.4444444477558136f)));
                      float _685 = _493 * -0.9440643787384033f;
                      float _686 = _493 * 0.12360770255327225f;
                      float _697 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _686)) + (_504 * _685)), (((_503 * _685) + _472) + (_504 * _686)), _492), (_324 - (_490 * 0.48148149251937866f)));
                      float _700 = _493 * -0.7408236861228943f;
                      float _701 = _493 * -0.5076829791069031f;
                      float _712 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _701)) + (_504 * _700)), (((_503 * _700) + _472) + (_504 * _701)), _492), (_324 - (_490 * 0.5185185074806213f)));
                      float _715 = _493 * -0.4113019108772278f;
                      float _716 = _493 * -0.8905966877937317f;
                      float _727 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _716)) + (_504 * _715)), (((_503 * _715) + _472) + (_504 * _716)), _492), (_324 - (_490 * 0.5555555820465088f)));
                      float _730 = _493 * -0.2486429065465927f;
                      float _731 = _493 * -0.6213992834091187f;
                      float _742 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _731)) + (_504 * _730)), (((_503 * _730) + _472) + (_504 * _731)), _492), (_324 - (_490 * 0.5925925970077515f)));
                      float _745 = _493 * 0.6967849731445312f;
                      float _746 = _493 * 0.2644937038421631f;
                      float _757 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _746)) + (_504 * _745)), (((_503 * _745) + _472) + (_504 * _746)), _492), (_324 - (_490 * 0.6296296119689941f)));
                      float _760 = _493 * 0.5394362807273865f;
                      float _761 = _493 * 0.8173214793205261f;
                      float _772 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _761)) + (_504 * _760)), (((_503 * _760) + _472) + (_504 * _761)), _492), (_324 - (_490 * 0.6666666865348816f)));
                      float _775 = _493 * 0.6151208281517029f;
                      float _776 = _493 * -0.14986400306224823f;
                      float _787 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _776)) + (_504 * _775)), (((_503 * _775) + _472) + (_504 * _776)), _492), (_324 - (_490 * 0.7037037014961243f)));
                      float _790 = _493 * 0.0936533585190773f;
                      float _791 = _493 * -0.7817475199699402f;
                      float _802 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _791)) + (_504 * _790)), (((_503 * _790) + _472) + (_504 * _791)), _492), (_324 - (_490 * 0.7407407164573669f)));
                      float _805 = _493 * 0.27680671215057373f;
                      float _806 = _493 * -0.48959681391716003f;
                      float _817 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _806)) + (_504 * _805)), (((_503 * _805) + _472) + (_504 * _806)), _492), (_324 - (_490 * 0.7777777910232544f)));
                      float _820 = _493 * 0.6639180779457092f;
                      float _821 = _493 * -0.6007171869277954f;
                      float _832 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _821)) + (_504 * _820)), (((_503 * _820) + _472) + (_504 * _821)), _492), (_324 - (_490 * 0.8148148059844971f)));
                      float _835 = _493 * 0.38803690671920776f;
                      float _836 = _493 * -0.8950893878936768f;
                      float _847 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _836)) + (_504 * _835)), (((_503 * _835) + _472) + (_504 * _836)), _492), (_324 - (_490 * 0.8518518805503845f)));
                      float _850 = _493 * 0.9916144013404846f;
                      float _851 = _493 * -0.07939151674509048f;
                      float _862 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _851)) + (_504 * _850)), (((_503 * _850) + _472) + (_504 * _851)), _492), (_324 - (_490 * 0.8888888955116272f)));
                      float _865 = _493 * 0.783184826374054f;
                      float _866 = _493 * 0.6029347777366638f;
                      float _877 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _866)) + (_504 * _865)), (((_503 * _865) + _472) + (_504 * _866)), _492), (_324 - (_490 * 0.9259259104728699f)));
                      float _880 = _493 * 0.8998603224754333f;
                      float _881 = _493 * -0.39835429191589355f;
                      float _892 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _881)) + (_504 * _880)), (((_503 * _880) + _472) + (_504 * _881)), _492), (_324 - (_490 * 0.9629629850387573f)));
                      float _895 = ((((((((((((((((((((((((((_517.x + _500.x) + _532.x) + _547.x) + _562.x) + _577.x) + _592.x) + _607.x) + _622.x) + _637.x) + _652.x) + _667.x) + _682.x) + _697.x) + _712.x) + _727.x) + _742.x) + _757.x) + _772.x) + _787.x) + _802.x) + _817.x) + _832.x) + _847.x) + _862.x) + _877.x) + _892.x) * 0.03703703731298447f;
                      _1009 = (_895 * _895);
                    } else {
                      float _904 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.5077208280563354f)), (_472 - (_493 * 0.6170899271965027f)), _492), (_324 - (_490 * 0.07692307978868484f)));
                      float _913 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.051549021154642105f)), (_472 - (_493 * 0.7508097887039185f)), _492), (_324 - (_490 * 0.1538461595773697f)));
                      float _922 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.7641041874885559f)), ((_493 * 0.20091520249843597f) + _472), _492), (_324 - (_490 * 0.23076923191547394f)));
                      float _931 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.007284773979336023f) + _471), (_472 - (_493 * 0.20594699680805206f)), _492), (_324 - (_490 * 0.3076923191547394f)));
                      float _940 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.36620399355888367f)), ((_493 * 0.732379674911499f) + _472), _492), (_324 - (_490 * 0.38461539149284363f)));
                      float _949 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.9239581823348999f)), (_472 - (_493 * 0.2559643089771271f)), _492), (_324 - (_490 * 0.4615384638309479f)));
                      float _958 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.28692400455474854f)), ((_493 * 0.2780529856681824f) + _472), _492), (_324 - (_490 * 0.5384615659713745f)));
                      float _967 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.772301197052002f) + _471), ((_493 * 0.1573328971862793f) + _472), _492), (_324 - (_490 * 0.6153846383094788f)));
                      float _976 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.37851300835609436f) + _471), ((_493 * 0.4052199125289917f) + _472), _492), (_324 - (_490 * 0.692307710647583f)));
                      float _985 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4630216956138611f) + _471), (_472 - (_493 * 0.6914619207382202f)), _492), (_324 - (_490 * 0.7692307829856873f)));
                      float _994 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4235230088233948f) + _471), ((_493 * 0.8630279898643494f) + _472), _492), (_324 - (_490 * 0.8461538553237915f)));
                      float _1003 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.8558642864227295f) + _471), (_472 - (_493 * 0.3382554054260254f)), _492), (_324 - (_490 * 0.9230769276618958f)));
                      float _1006 = ((((((((((((_904.x + _500.x) + _913.x) + _922.x) + _931.x) + _940.x) + _949.x) + _958.x) + _967.x) + _976.x) + _985.x) + _994.x) + _1003.x) * 0.07692307978868484f;
                      _1009 = (_1006 * _1006);
                    }
                    _1019 = saturate(((_20[_417]) * select((_492 < float((int)(_417))), 0.0f, 1.0f)) + _1009);
                  } else {
                    _1019 = 1.0f;
                  }
                } else {
                  _1019 = 1.0f;
                }
                }
                float _1024 = cb12_066x * 20.0f;
                float _1035 = _86 - cb12_000z;
                float _1044 = _86 * 0.009999999776482582f;
                float _1047 = _1044 / cb12_066x;
                float _1056 = _1044 / _1024;
                float _1061 = (((cb12_067x + _84) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000x) / cb13_000z);
                float _1062 = (((cb12_067y + _85) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000y) / cb13_000z);
                float _1067 = ((((cb12_067x * 20.0f) + _84) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000x) / cb13_000z);
                float _1068 = ((((cb12_067y * 20.0f) + _85) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000y) / cb13_000z);
                float _1069 = float((int)(int(trunc(cb12_068x))));
                float4 _1072 = t14.SampleLevel(s14, float3(_1061, _1062, _1069), 1.0f);
                float _1074 = float((int)(int(trunc(cb12_068y))));
                float4 _1075 = t14.SampleLevel(s14, float3(_1061, _1062, _1074), 1.0f);
                float _1079 = ((_1075.x - _1072.x) * cb12_066w) + _1072.x;
                float4 _1080 = t14.SampleLevel(s14, float3(_1067, _1068, _1069), 1.0f);
                float4 _1082 = t14.SampleLevel(s14, float3(_1067, _1068, _1074), 1.0f);
                _1100 = ((_1019 * _286) * GraphicsSurfaceCloudShadow(float3(_84, _85, _86), (1.0f - (((((_1080.x - _1079) + ((_1082.x - _1080.x) * cb12_066w)) * saturate((sqrt(_119 + (_1035 * _1035)) + -100.0f) * 0.006666666828095913f)) + _1079) * saturate((cb13_000z + -0.25f) * 10.0f)))));
              }
            } else {
              if ((int)_130 > (int)-1) {
                if (!(cb13_034y == 0)) {
                  _165 = 0;
                  while(true) {
                    float _174 = (_84 - (cb13_raw[((int)(_165 + 47u))].x)) * (cb13_raw[((int)(_165 + 47u))].z);
                    float _175 = (_85 - (cb13_raw[((int)(_165 + 47u))].y)) * (cb13_raw[((int)(_165 + 47u))].w);
                    if ((int)(_174 > 0.009999999776482582f) && (int)(_175 > 0.009999999776482582f)) {
                      if (!((int)(_174 < 0.9900000095367432f) && (int)(_175 < 0.9900000095367432f))) {
                        int _184 = _165 + 1;
                        if ((uint)_184 < (uint)cb13_034y) {
                          _165 = _184;
                          continue;
                        } else {
                          _239 = -10000.0f;
                          _240 = 0.0f;
                        }
                      } else {
                        float _197 = ((cb13_raw[((int)(_165 + 53u))].z) * _174) + (cb13_raw[((int)(_165 + 53u))].x);
                        float _198 = ((cb13_raw[((int)(_165 + 53u))].w) * _175) + (cb13_raw[((int)(_165 + 53u))].y);
                        float _199 = _197 + 0.00048828125f;
                        float _200 = _198 + 0.00048828125f;
                        if ((int)_165 > (int)-1) {
                          float _203 = float((int)(_165));
                          float _206 = t15.SampleLevel(s10, float3(_199, _200, _203), 0.0f);
                          float _209 = t15.SampleLevel(s10, float3((_197 + 0.00244140625f), _200, _203), 0.0f);
                          float _212 = t15.SampleLevel(s10, float3(_199, (_198 + 0.00244140625f), _203), 0.0f);
                          float _215 = t15.SampleLevel(s10, float3((_197 + -0.00146484375f), _200, _203), 0.0f);
                          float _218 = t15.SampleLevel(s10, float3(_199, (_198 + -0.00146484375f), _203), 0.0f);
                          _239 = (cb13_036x + (_206.x * cb13_035w));
                          _240 = (max(max(abs(_209.x - _206.x), abs(_215.x - _206.x)), max(abs(_212.x - _206.x), abs(_218.x - _206.x))) * cb13_035w);
                        } else {
                          _239 = -10000.0f;
                          _240 = 0.0f;
                        }
                      }
                    } else {
                      int _184 = _165 + 1;
                      if ((uint)_184 < (uint)cb13_034y) {
                        _165 = _184;
                        continue;
                      } else {
                        _239 = -10000.0f;
                        _240 = 0.0f;
                      }
                    }
                    break;
                  }
                } else {
                  _239 = -10000.0f;
                  _240 = 0.0f;
                }
                float _256 = t19.SampleLevel(s10, float3(_141, _144, float((int)(_130))), 0.0f);
                float _260 = _86 - cb12_000z;
                float _274 = saturate((((cb13_036x + -0.10000000149011612f) + (_256.x * cb13_035w)) - select((abs(_239 - _86) < ((sqrt(_119 + (_260 * _260)) * 0.019999999552965164f) + 0.05000000074505806f)), _239, _86)) * min((1.0f / max(0.10000000149011612f, _240)), (cb13_034z / max(1.0f, (cb13_034w * _120)))));
                float _282 = (saturate((cb13_035y + _120) * cb13_035z) * _274) + (1.0f - _274);
                [branch]
                if (_282 > 0.0f) {
                  _286 = _282;
                  uint _287 = uint(_46);
                  uint _288 = uint(_47);
                  float _296 = frac(sin(dot(float2(float((uint)_287), float((uint)_288)), float2(12.989800453186035f, 78.23300170898438f))) * 43758.546875f) * 6.2831854820251465f;
                  float _316 = mad(cb13_005x, _86, mad(cb13_004x, _85, (cb13_003x * _84))) + cb13_006x;
                  float _320 = mad(cb13_005y, _86, mad(cb13_004y, _85, (cb13_003y * _84))) + cb13_006y;
                  float _324 = mad(cb13_005z, _86, mad(cb13_004z, _85, (cb13_003z * _84))) + cb13_006z;
                  [branch]
                  if (ImprovedSoftShadows()) {
                  _1019 = GraphicsDirectionalVisibility(float3(_84, _85, _86), _107);
                } else {
if (!(abs(_324) >= 0.9990000128746033f)) {
                    float _354 = max(abs(_316 - cb13_007x), abs(_320 - cb13_008x));
                    float _355 = max(abs(_316 - cb13_007y), abs(_320 - cb13_008y));
                    float _356 = max(abs(_316 - cb13_007z), abs(_320 - cb13_008z));
                    float _357 = max(abs(_316 - cb13_007w), abs(_320 - cb13_008w));
                    float _381 = dot(float4(float((bool)(uint)(_354 < cb13_009x)), float((bool)(uint)(_355 < cb13_009y)), float((bool)(uint)(_356 < cb13_009z)), float((bool)(uint)(_357 < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                    [branch]
                    if (!(_381 < 0.5f)) {
                      _20[0] = saturate((((_354 / cb13_009x) + -1.0f) + cb13_016x) / cb13_016x);
                      _20[1] = saturate((((_355 / cb13_009y) + -1.0f) + cb13_016y) / cb13_016y);
                      _20[2] = saturate((((_356 / cb13_009z) + -1.0f) + cb13_016z) / cb13_016z);
                      _20[3] = saturate((((_357 / cb13_009w) + -1.0f) + cb13_016w) / cb13_016w);
                      int _415 = int(cb13_014z - _381);
                      int _417 = int(cb13_014z) + -1;
                      int _420 = _288 & 1;
                      int _429 = ((uint)(_288) >> 1) & 1;
                      int _439 = ((uint)(_288) >> 2) & 1;
                      int _449 = ((uint)(_288) >> 3) & 1;
                      int _463 = min((((int)(uint)((int)(((float((int)(select(((_287 & 8) == 0), select((_449 != 0), 3, 0), (2 - _449)) | ((int)(((uint)(select(((_287 & 4) == 0), select((_439 != 0), 3, 0), (2 - _439)) | ((select(((_287 & 2) == 0), select((_429 != 0), 3, 0), (2 - _429)) | (select(((_287 & 1) == 0), select((_420 != 0), 3, 0), (2 - _420)) << 2u)) << 2u))) << 2u)))) + 0.5f) * 0.00390625f) < (_20[_415])))) + _415), _417);
                      float _471 = ((cb13_raw[((int)(_463 + 10u))].z) * _316) + (cb13_raw[((int)(_463 + 10u))].x);
                      float _472 = (cb13_raw[((int)(_463 + 10u))].y) - ((cb13_raw[((int)(_463 + 10u))].z) * _320);
                      if (!_107) {
                        _489 = (cb13_raw[((int)(_463 + 10u))].w);
                        _490 = 0.0f;
                        _491 = false;
                      } else {
                        _489 = (cb13_raw[((int)(_463 + 18u))].x);
                        _490 = (cb13_raw[((int)(_463 + 18u))].y);
                        _491 = ((cb13_raw[((int)(_463 + 18u))].z) > 0.0f);
                      }
                      float _492 = float((int)(_463));
                      float _493 = _489 * min(max(((1.0f / sqrt(max(dot(float3(_92, _93, _94), float3(cb13_000x, cb13_000y, cb13_000z)), 0.0f))) + -1.0f), 1.0f), 4.0f);
                      float _500 = t8.SampleCmpLevelZero(s9, float3(_471, _472, _492), _324);
                      if (!(_491 || (int)((int)cb13_017x < (int)1))) {
                        float _503 = sin(_296);
                        float _504 = cos(_296);
                        float _505 = _493 * -0.2633539140224457f;
                        float _506 = _493 * 0.03965381905436516f;
                        float _517 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _506)) + (_504 * _505)), (((_503 * _505) + _472) + (_504 * _506)), _492), (_324 - (_490 * 0.03703703731298447f)));
                        float _520 = _493 * -0.7172024250030518f;
                        float _521 = _493 * 0.3683032989501953f;
                        float _532 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _521)) + (_504 * _520)), (((_503 * _520) + _472) + (_504 * _521)), _492), (_324 - (_490 * 0.07407407462596893f)));
                        float _535 = _493 * -0.019953060895204544f;
                        float _536 = _493 * -0.39883920550346375f;
                        float _547 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _536)) + (_504 * _535)), (((_503 * _535) + _472) + (_504 * _536)), _492), (_324 - (_490 * 0.1111111119389534f)));
                        float _550 = _493 * -0.4409937858581543f;
                        float _551 = _493 * -0.2210099995136261f;
                        float _562 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _551)) + (_504 * _550)), (((_503 * _550) + _472) + (_504 * _551)), _492), (_324 - (_490 * 0.14814814925193787f)));
                        float _565 = _493 * 0.22003920376300812f;
                        float _566 = _493 * 0.29434481263160706f;
                        float _577 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _566)) + (_504 * _565)), (((_503 * _565) + _472) + (_504 * _566)), _492), (_324 - (_490 * 0.18518517911434174f)));
                        float _580 = _493 * -0.7675657272338867f;
                        float _581 = _493 * -0.14827530086040497f;
                        float _592 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _581)) + (_504 * _580)), (((_503 * _580) + _472) + (_504 * _581)), _492), (_324 - (_490 * 0.2222222238779068f)));
                        float _595 = _493 * -0.23810189962387085f;
                        float _596 = _493 * 0.5471062064170837f;
                        float _607 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _596)) + (_504 * _595)), (((_503 * _595) + _472) + (_504 * _596)), _492), (_324 - (_490 * 0.25925925374031067f)));
                        float _610 = _493 * 0.2173030972480774f;
                        float _611 = _493 * -0.13458789885044098f;
                        float _622 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _611)) + (_504 * _610)), (((_503 * _610) + _472) + (_504 * _611)), _492), (_324 - (_490 * 0.29629629850387573f)));
                        float _625 = _493 * -0.6387773752212524f;
                        float _626 = _493 * 0.7561339139938354f;
                        float _637 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _626)) + (_504 * _625)), (((_503 * _625) + _472) + (_504 * _626)), _492), (_324 - (_490 * 0.3333333432674408f)));
                        float _640 = _493 * -0.16141439974308014f;
                        float _641 = _493 * 0.9776520729064941f;
                        float _652 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _641)) + (_504 * _640)), (((_503 * _640) + _472) + (_504 * _641)), _492), (_324 - (_490 * 0.37037035822868347f)));
                        float _655 = _493 * 0.215631902217865f;
                        float _656 = _493 * 0.6123412847518921f;
                        float _667 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _656)) + (_504 * _655)), (((_503 * _655) + _472) + (_504 * _656)), _492), (_324 - (_490 * 0.40740740299224854f)));
                        float _670 = _493 * 0.23288750648498535f;
                        float _671 = _493 * 0.9452872276306152f;
                        float _682 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _671)) + (_504 * _670)), (((_503 * _670) + _472) + (_504 * _671)), _492), (_324 - (_490 * 0.4444444477558136f)));
                        float _685 = _493 * -0.9440643787384033f;
                        float _686 = _493 * 0.12360770255327225f;
                        float _697 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _686)) + (_504 * _685)), (((_503 * _685) + _472) + (_504 * _686)), _492), (_324 - (_490 * 0.48148149251937866f)));
                        float _700 = _493 * -0.7408236861228943f;
                        float _701 = _493 * -0.5076829791069031f;
                        float _712 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _701)) + (_504 * _700)), (((_503 * _700) + _472) + (_504 * _701)), _492), (_324 - (_490 * 0.5185185074806213f)));
                        float _715 = _493 * -0.4113019108772278f;
                        float _716 = _493 * -0.8905966877937317f;
                        float _727 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _716)) + (_504 * _715)), (((_503 * _715) + _472) + (_504 * _716)), _492), (_324 - (_490 * 0.5555555820465088f)));
                        float _730 = _493 * -0.2486429065465927f;
                        float _731 = _493 * -0.6213992834091187f;
                        float _742 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _731)) + (_504 * _730)), (((_503 * _730) + _472) + (_504 * _731)), _492), (_324 - (_490 * 0.5925925970077515f)));
                        float _745 = _493 * 0.6967849731445312f;
                        float _746 = _493 * 0.2644937038421631f;
                        float _757 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _746)) + (_504 * _745)), (((_503 * _745) + _472) + (_504 * _746)), _492), (_324 - (_490 * 0.6296296119689941f)));
                        float _760 = _493 * 0.5394362807273865f;
                        float _761 = _493 * 0.8173214793205261f;
                        float _772 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _761)) + (_504 * _760)), (((_503 * _760) + _472) + (_504 * _761)), _492), (_324 - (_490 * 0.6666666865348816f)));
                        float _775 = _493 * 0.6151208281517029f;
                        float _776 = _493 * -0.14986400306224823f;
                        float _787 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _776)) + (_504 * _775)), (((_503 * _775) + _472) + (_504 * _776)), _492), (_324 - (_490 * 0.7037037014961243f)));
                        float _790 = _493 * 0.0936533585190773f;
                        float _791 = _493 * -0.7817475199699402f;
                        float _802 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _791)) + (_504 * _790)), (((_503 * _790) + _472) + (_504 * _791)), _492), (_324 - (_490 * 0.7407407164573669f)));
                        float _805 = _493 * 0.27680671215057373f;
                        float _806 = _493 * -0.48959681391716003f;
                        float _817 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _806)) + (_504 * _805)), (((_503 * _805) + _472) + (_504 * _806)), _492), (_324 - (_490 * 0.7777777910232544f)));
                        float _820 = _493 * 0.6639180779457092f;
                        float _821 = _493 * -0.6007171869277954f;
                        float _832 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _821)) + (_504 * _820)), (((_503 * _820) + _472) + (_504 * _821)), _492), (_324 - (_490 * 0.8148148059844971f)));
                        float _835 = _493 * 0.38803690671920776f;
                        float _836 = _493 * -0.8950893878936768f;
                        float _847 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _836)) + (_504 * _835)), (((_503 * _835) + _472) + (_504 * _836)), _492), (_324 - (_490 * 0.8518518805503845f)));
                        float _850 = _493 * 0.9916144013404846f;
                        float _851 = _493 * -0.07939151674509048f;
                        float _862 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _851)) + (_504 * _850)), (((_503 * _850) + _472) + (_504 * _851)), _492), (_324 - (_490 * 0.8888888955116272f)));
                        float _865 = _493 * 0.783184826374054f;
                        float _866 = _493 * 0.6029347777366638f;
                        float _877 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _866)) + (_504 * _865)), (((_503 * _865) + _472) + (_504 * _866)), _492), (_324 - (_490 * 0.9259259104728699f)));
                        float _880 = _493 * 0.8998603224754333f;
                        float _881 = _493 * -0.39835429191589355f;
                        float _892 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _881)) + (_504 * _880)), (((_503 * _880) + _472) + (_504 * _881)), _492), (_324 - (_490 * 0.9629629850387573f)));
                        float _895 = ((((((((((((((((((((((((((_517.x + _500.x) + _532.x) + _547.x) + _562.x) + _577.x) + _592.x) + _607.x) + _622.x) + _637.x) + _652.x) + _667.x) + _682.x) + _697.x) + _712.x) + _727.x) + _742.x) + _757.x) + _772.x) + _787.x) + _802.x) + _817.x) + _832.x) + _847.x) + _862.x) + _877.x) + _892.x) * 0.03703703731298447f;
                        _1009 = (_895 * _895);
                      } else {
                        float _904 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.5077208280563354f)), (_472 - (_493 * 0.6170899271965027f)), _492), (_324 - (_490 * 0.07692307978868484f)));
                        float _913 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.051549021154642105f)), (_472 - (_493 * 0.7508097887039185f)), _492), (_324 - (_490 * 0.1538461595773697f)));
                        float _922 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.7641041874885559f)), ((_493 * 0.20091520249843597f) + _472), _492), (_324 - (_490 * 0.23076923191547394f)));
                        float _931 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.007284773979336023f) + _471), (_472 - (_493 * 0.20594699680805206f)), _492), (_324 - (_490 * 0.3076923191547394f)));
                        float _940 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.36620399355888367f)), ((_493 * 0.732379674911499f) + _472), _492), (_324 - (_490 * 0.38461539149284363f)));
                        float _949 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.9239581823348999f)), (_472 - (_493 * 0.2559643089771271f)), _492), (_324 - (_490 * 0.4615384638309479f)));
                        float _958 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.28692400455474854f)), ((_493 * 0.2780529856681824f) + _472), _492), (_324 - (_490 * 0.5384615659713745f)));
                        float _967 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.772301197052002f) + _471), ((_493 * 0.1573328971862793f) + _472), _492), (_324 - (_490 * 0.6153846383094788f)));
                        float _976 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.37851300835609436f) + _471), ((_493 * 0.4052199125289917f) + _472), _492), (_324 - (_490 * 0.692307710647583f)));
                        float _985 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4630216956138611f) + _471), (_472 - (_493 * 0.6914619207382202f)), _492), (_324 - (_490 * 0.7692307829856873f)));
                        float _994 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4235230088233948f) + _471), ((_493 * 0.8630279898643494f) + _472), _492), (_324 - (_490 * 0.8461538553237915f)));
                        float _1003 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.8558642864227295f) + _471), (_472 - (_493 * 0.3382554054260254f)), _492), (_324 - (_490 * 0.9230769276618958f)));
                        float _1006 = ((((((((((((_904.x + _500.x) + _913.x) + _922.x) + _931.x) + _940.x) + _949.x) + _958.x) + _967.x) + _976.x) + _985.x) + _994.x) + _1003.x) * 0.07692307978868484f;
                        _1009 = (_1006 * _1006);
                      }
                      _1019 = saturate(((_20[_417]) * select((_492 < float((int)(_417))), 0.0f, 1.0f)) + _1009);
                    } else {
                      _1019 = 1.0f;
                    }
                  } else {
                    _1019 = 1.0f;
                  }
                }
                  float _1024 = cb12_066x * 20.0f;
                  float _1035 = _86 - cb12_000z;
                  float _1044 = _86 * 0.009999999776482582f;
                  float _1047 = _1044 / cb12_066x;
                  float _1056 = _1044 / _1024;
                  float _1061 = (((cb12_067x + _84) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000x) / cb13_000z);
                  float _1062 = (((cb12_067y + _85) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000y) / cb13_000z);
                  float _1067 = ((((cb12_067x * 20.0f) + _84) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000x) / cb13_000z);
                  float _1068 = ((((cb12_067y * 20.0f) + _85) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000y) / cb13_000z);
                  float _1069 = float((int)(int(trunc(cb12_068x))));
                  float4 _1072 = t14.SampleLevel(s14, float3(_1061, _1062, _1069), 1.0f);
                  float _1074 = float((int)(int(trunc(cb12_068y))));
                  float4 _1075 = t14.SampleLevel(s14, float3(_1061, _1062, _1074), 1.0f);
                  float _1079 = ((_1075.x - _1072.x) * cb12_066w) + _1072.x;
                  float4 _1080 = t14.SampleLevel(s14, float3(_1067, _1068, _1069), 1.0f);
                  float4 _1082 = t14.SampleLevel(s14, float3(_1067, _1068, _1074), 1.0f);
                  _1100 = ((_1019 * _286) * GraphicsSurfaceCloudShadow(float3(_84, _85, _86), (1.0f - (((((_1080.x - _1079) + ((_1082.x - _1080.x) * cb12_066w)) * saturate((sqrt(_119 + (_1035 * _1035)) + -100.0f) * 0.006666666828095913f)) + _1079) * saturate((cb13_000z + -0.25f) * 10.0f)))));
                } else {
                  _1100 = _282;
                }
              } else {
                _286 = 1.0f;
                uint _287 = uint(_46);
                uint _288 = uint(_47);
                float _296 = frac(sin(dot(float2(float((uint)_287), float((uint)_288)), float2(12.989800453186035f, 78.23300170898438f))) * 43758.546875f) * 6.2831854820251465f;
                float _316 = mad(cb13_005x, _86, mad(cb13_004x, _85, (cb13_003x * _84))) + cb13_006x;
                float _320 = mad(cb13_005y, _86, mad(cb13_004y, _85, (cb13_003y * _84))) + cb13_006y;
                float _324 = mad(cb13_005z, _86, mad(cb13_004z, _85, (cb13_003z * _84))) + cb13_006z;
                [branch]
                if (ImprovedSoftShadows()) {
                  _1019 = GraphicsDirectionalVisibility(float3(_84, _85, _86), _107);
                } else {
if (!(abs(_324) >= 0.9990000128746033f)) {
                  float _354 = max(abs(_316 - cb13_007x), abs(_320 - cb13_008x));
                  float _355 = max(abs(_316 - cb13_007y), abs(_320 - cb13_008y));
                  float _356 = max(abs(_316 - cb13_007z), abs(_320 - cb13_008z));
                  float _357 = max(abs(_316 - cb13_007w), abs(_320 - cb13_008w));
                  float _381 = dot(float4(float((bool)(uint)(_354 < cb13_009x)), float((bool)(uint)(_355 < cb13_009y)), float((bool)(uint)(_356 < cb13_009z)), float((bool)(uint)(_357 < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                  [branch]
                  if (!(_381 < 0.5f)) {
                    _20[0] = saturate((((_354 / cb13_009x) + -1.0f) + cb13_016x) / cb13_016x);
                    _20[1] = saturate((((_355 / cb13_009y) + -1.0f) + cb13_016y) / cb13_016y);
                    _20[2] = saturate((((_356 / cb13_009z) + -1.0f) + cb13_016z) / cb13_016z);
                    _20[3] = saturate((((_357 / cb13_009w) + -1.0f) + cb13_016w) / cb13_016w);
                    int _415 = int(cb13_014z - _381);
                    int _417 = int(cb13_014z) + -1;
                    int _420 = _288 & 1;
                    int _429 = ((uint)(_288) >> 1) & 1;
                    int _439 = ((uint)(_288) >> 2) & 1;
                    int _449 = ((uint)(_288) >> 3) & 1;
                    int _463 = min((((int)(uint)((int)(((float((int)(select(((_287 & 8) == 0), select((_449 != 0), 3, 0), (2 - _449)) | ((int)(((uint)(select(((_287 & 4) == 0), select((_439 != 0), 3, 0), (2 - _439)) | ((select(((_287 & 2) == 0), select((_429 != 0), 3, 0), (2 - _429)) | (select(((_287 & 1) == 0), select((_420 != 0), 3, 0), (2 - _420)) << 2u)) << 2u))) << 2u)))) + 0.5f) * 0.00390625f) < (_20[_415])))) + _415), _417);
                    float _471 = ((cb13_raw[((int)(_463 + 10u))].z) * _316) + (cb13_raw[((int)(_463 + 10u))].x);
                    float _472 = (cb13_raw[((int)(_463 + 10u))].y) - ((cb13_raw[((int)(_463 + 10u))].z) * _320);
                    if (!_107) {
                      _489 = (cb13_raw[((int)(_463 + 10u))].w);
                      _490 = 0.0f;
                      _491 = false;
                    } else {
                      _489 = (cb13_raw[((int)(_463 + 18u))].x);
                      _490 = (cb13_raw[((int)(_463 + 18u))].y);
                      _491 = ((cb13_raw[((int)(_463 + 18u))].z) > 0.0f);
                    }
                    float _492 = float((int)(_463));
                    float _493 = _489 * min(max(((1.0f / sqrt(max(dot(float3(_92, _93, _94), float3(cb13_000x, cb13_000y, cb13_000z)), 0.0f))) + -1.0f), 1.0f), 4.0f);
                    float _500 = t8.SampleCmpLevelZero(s9, float3(_471, _472, _492), _324);
                    if (!(_491 || (int)((int)cb13_017x < (int)1))) {
                      float _503 = sin(_296);
                      float _504 = cos(_296);
                      float _505 = _493 * -0.2633539140224457f;
                      float _506 = _493 * 0.03965381905436516f;
                      float _517 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _506)) + (_504 * _505)), (((_503 * _505) + _472) + (_504 * _506)), _492), (_324 - (_490 * 0.03703703731298447f)));
                      float _520 = _493 * -0.7172024250030518f;
                      float _521 = _493 * 0.3683032989501953f;
                      float _532 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _521)) + (_504 * _520)), (((_503 * _520) + _472) + (_504 * _521)), _492), (_324 - (_490 * 0.07407407462596893f)));
                      float _535 = _493 * -0.019953060895204544f;
                      float _536 = _493 * -0.39883920550346375f;
                      float _547 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _536)) + (_504 * _535)), (((_503 * _535) + _472) + (_504 * _536)), _492), (_324 - (_490 * 0.1111111119389534f)));
                      float _550 = _493 * -0.4409937858581543f;
                      float _551 = _493 * -0.2210099995136261f;
                      float _562 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _551)) + (_504 * _550)), (((_503 * _550) + _472) + (_504 * _551)), _492), (_324 - (_490 * 0.14814814925193787f)));
                      float _565 = _493 * 0.22003920376300812f;
                      float _566 = _493 * 0.29434481263160706f;
                      float _577 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _566)) + (_504 * _565)), (((_503 * _565) + _472) + (_504 * _566)), _492), (_324 - (_490 * 0.18518517911434174f)));
                      float _580 = _493 * -0.7675657272338867f;
                      float _581 = _493 * -0.14827530086040497f;
                      float _592 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _581)) + (_504 * _580)), (((_503 * _580) + _472) + (_504 * _581)), _492), (_324 - (_490 * 0.2222222238779068f)));
                      float _595 = _493 * -0.23810189962387085f;
                      float _596 = _493 * 0.5471062064170837f;
                      float _607 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _596)) + (_504 * _595)), (((_503 * _595) + _472) + (_504 * _596)), _492), (_324 - (_490 * 0.25925925374031067f)));
                      float _610 = _493 * 0.2173030972480774f;
                      float _611 = _493 * -0.13458789885044098f;
                      float _622 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _611)) + (_504 * _610)), (((_503 * _610) + _472) + (_504 * _611)), _492), (_324 - (_490 * 0.29629629850387573f)));
                      float _625 = _493 * -0.6387773752212524f;
                      float _626 = _493 * 0.7561339139938354f;
                      float _637 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _626)) + (_504 * _625)), (((_503 * _625) + _472) + (_504 * _626)), _492), (_324 - (_490 * 0.3333333432674408f)));
                      float _640 = _493 * -0.16141439974308014f;
                      float _641 = _493 * 0.9776520729064941f;
                      float _652 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _641)) + (_504 * _640)), (((_503 * _640) + _472) + (_504 * _641)), _492), (_324 - (_490 * 0.37037035822868347f)));
                      float _655 = _493 * 0.215631902217865f;
                      float _656 = _493 * 0.6123412847518921f;
                      float _667 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _656)) + (_504 * _655)), (((_503 * _655) + _472) + (_504 * _656)), _492), (_324 - (_490 * 0.40740740299224854f)));
                      float _670 = _493 * 0.23288750648498535f;
                      float _671 = _493 * 0.9452872276306152f;
                      float _682 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _671)) + (_504 * _670)), (((_503 * _670) + _472) + (_504 * _671)), _492), (_324 - (_490 * 0.4444444477558136f)));
                      float _685 = _493 * -0.9440643787384033f;
                      float _686 = _493 * 0.12360770255327225f;
                      float _697 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _686)) + (_504 * _685)), (((_503 * _685) + _472) + (_504 * _686)), _492), (_324 - (_490 * 0.48148149251937866f)));
                      float _700 = _493 * -0.7408236861228943f;
                      float _701 = _493 * -0.5076829791069031f;
                      float _712 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _701)) + (_504 * _700)), (((_503 * _700) + _472) + (_504 * _701)), _492), (_324 - (_490 * 0.5185185074806213f)));
                      float _715 = _493 * -0.4113019108772278f;
                      float _716 = _493 * -0.8905966877937317f;
                      float _727 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _716)) + (_504 * _715)), (((_503 * _715) + _472) + (_504 * _716)), _492), (_324 - (_490 * 0.5555555820465088f)));
                      float _730 = _493 * -0.2486429065465927f;
                      float _731 = _493 * -0.6213992834091187f;
                      float _742 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _731)) + (_504 * _730)), (((_503 * _730) + _472) + (_504 * _731)), _492), (_324 - (_490 * 0.5925925970077515f)));
                      float _745 = _493 * 0.6967849731445312f;
                      float _746 = _493 * 0.2644937038421631f;
                      float _757 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _746)) + (_504 * _745)), (((_503 * _745) + _472) + (_504 * _746)), _492), (_324 - (_490 * 0.6296296119689941f)));
                      float _760 = _493 * 0.5394362807273865f;
                      float _761 = _493 * 0.8173214793205261f;
                      float _772 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _761)) + (_504 * _760)), (((_503 * _760) + _472) + (_504 * _761)), _492), (_324 - (_490 * 0.6666666865348816f)));
                      float _775 = _493 * 0.6151208281517029f;
                      float _776 = _493 * -0.14986400306224823f;
                      float _787 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _776)) + (_504 * _775)), (((_503 * _775) + _472) + (_504 * _776)), _492), (_324 - (_490 * 0.7037037014961243f)));
                      float _790 = _493 * 0.0936533585190773f;
                      float _791 = _493 * -0.7817475199699402f;
                      float _802 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _791)) + (_504 * _790)), (((_503 * _790) + _472) + (_504 * _791)), _492), (_324 - (_490 * 0.7407407164573669f)));
                      float _805 = _493 * 0.27680671215057373f;
                      float _806 = _493 * -0.48959681391716003f;
                      float _817 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _806)) + (_504 * _805)), (((_503 * _805) + _472) + (_504 * _806)), _492), (_324 - (_490 * 0.7777777910232544f)));
                      float _820 = _493 * 0.6639180779457092f;
                      float _821 = _493 * -0.6007171869277954f;
                      float _832 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _821)) + (_504 * _820)), (((_503 * _820) + _472) + (_504 * _821)), _492), (_324 - (_490 * 0.8148148059844971f)));
                      float _835 = _493 * 0.38803690671920776f;
                      float _836 = _493 * -0.8950893878936768f;
                      float _847 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _836)) + (_504 * _835)), (((_503 * _835) + _472) + (_504 * _836)), _492), (_324 - (_490 * 0.8518518805503845f)));
                      float _850 = _493 * 0.9916144013404846f;
                      float _851 = _493 * -0.07939151674509048f;
                      float _862 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _851)) + (_504 * _850)), (((_503 * _850) + _472) + (_504 * _851)), _492), (_324 - (_490 * 0.8888888955116272f)));
                      float _865 = _493 * 0.783184826374054f;
                      float _866 = _493 * 0.6029347777366638f;
                      float _877 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _866)) + (_504 * _865)), (((_503 * _865) + _472) + (_504 * _866)), _492), (_324 - (_490 * 0.9259259104728699f)));
                      float _880 = _493 * 0.8998603224754333f;
                      float _881 = _493 * -0.39835429191589355f;
                      float _892 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _881)) + (_504 * _880)), (((_503 * _880) + _472) + (_504 * _881)), _492), (_324 - (_490 * 0.9629629850387573f)));
                      float _895 = ((((((((((((((((((((((((((_517.x + _500.x) + _532.x) + _547.x) + _562.x) + _577.x) + _592.x) + _607.x) + _622.x) + _637.x) + _652.x) + _667.x) + _682.x) + _697.x) + _712.x) + _727.x) + _742.x) + _757.x) + _772.x) + _787.x) + _802.x) + _817.x) + _832.x) + _847.x) + _862.x) + _877.x) + _892.x) * 0.03703703731298447f;
                      _1009 = (_895 * _895);
                    } else {
                      float _904 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.5077208280563354f)), (_472 - (_493 * 0.6170899271965027f)), _492), (_324 - (_490 * 0.07692307978868484f)));
                      float _913 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.051549021154642105f)), (_472 - (_493 * 0.7508097887039185f)), _492), (_324 - (_490 * 0.1538461595773697f)));
                      float _922 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.7641041874885559f)), ((_493 * 0.20091520249843597f) + _472), _492), (_324 - (_490 * 0.23076923191547394f)));
                      float _931 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.007284773979336023f) + _471), (_472 - (_493 * 0.20594699680805206f)), _492), (_324 - (_490 * 0.3076923191547394f)));
                      float _940 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.36620399355888367f)), ((_493 * 0.732379674911499f) + _472), _492), (_324 - (_490 * 0.38461539149284363f)));
                      float _949 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.9239581823348999f)), (_472 - (_493 * 0.2559643089771271f)), _492), (_324 - (_490 * 0.4615384638309479f)));
                      float _958 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.28692400455474854f)), ((_493 * 0.2780529856681824f) + _472), _492), (_324 - (_490 * 0.5384615659713745f)));
                      float _967 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.772301197052002f) + _471), ((_493 * 0.1573328971862793f) + _472), _492), (_324 - (_490 * 0.6153846383094788f)));
                      float _976 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.37851300835609436f) + _471), ((_493 * 0.4052199125289917f) + _472), _492), (_324 - (_490 * 0.692307710647583f)));
                      float _985 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4630216956138611f) + _471), (_472 - (_493 * 0.6914619207382202f)), _492), (_324 - (_490 * 0.7692307829856873f)));
                      float _994 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4235230088233948f) + _471), ((_493 * 0.8630279898643494f) + _472), _492), (_324 - (_490 * 0.8461538553237915f)));
                      float _1003 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.8558642864227295f) + _471), (_472 - (_493 * 0.3382554054260254f)), _492), (_324 - (_490 * 0.9230769276618958f)));
                      float _1006 = ((((((((((((_904.x + _500.x) + _913.x) + _922.x) + _931.x) + _940.x) + _949.x) + _958.x) + _967.x) + _976.x) + _985.x) + _994.x) + _1003.x) * 0.07692307978868484f;
                      _1009 = (_1006 * _1006);
                    }
                    _1019 = saturate(((_20[_417]) * select((_492 < float((int)(_417))), 0.0f, 1.0f)) + _1009);
                  } else {
                    _1019 = 1.0f;
                  }
                } else {
                  _1019 = 1.0f;
                }
                }
                float _1024 = cb12_066x * 20.0f;
                float _1035 = _86 - cb12_000z;
                float _1044 = _86 * 0.009999999776482582f;
                float _1047 = _1044 / cb12_066x;
                float _1056 = _1044 / _1024;
                float _1061 = (((cb12_067x + _84) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000x) / cb13_000z);
                float _1062 = (((cb12_067y + _85) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000y) / cb13_000z);
                float _1067 = ((((cb12_067x * 20.0f) + _84) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000x) / cb13_000z);
                float _1068 = ((((cb12_067y * 20.0f) + _85) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000y) / cb13_000z);
                float _1069 = float((int)(int(trunc(cb12_068x))));
                float4 _1072 = t14.SampleLevel(s14, float3(_1061, _1062, _1069), 1.0f);
                float _1074 = float((int)(int(trunc(cb12_068y))));
                float4 _1075 = t14.SampleLevel(s14, float3(_1061, _1062, _1074), 1.0f);
                float _1079 = ((_1075.x - _1072.x) * cb12_066w) + _1072.x;
                float4 _1080 = t14.SampleLevel(s14, float3(_1067, _1068, _1069), 1.0f);
                float4 _1082 = t14.SampleLevel(s14, float3(_1067, _1068, _1074), 1.0f);
                _1100 = ((_1019 * _286) * GraphicsSurfaceCloudShadow(float3(_84, _85, _86), (1.0f - (((((_1080.x - _1079) + ((_1082.x - _1080.x) * cb12_066w)) * saturate((sqrt(_119 + (_1035 * _1035)) + -100.0f) * 0.006666666828095913f)) + _1079) * saturate((cb13_000z + -0.25f) * 10.0f)))));
              }
            }
          } else {
            int _153 = _130 + 1;
            if ((uint)_153 < (uint)cb13_034x) {
              _130 = _153;
              continue;
            } else {
              _286 = 1.0f;
              uint _287 = uint(_46);
              uint _288 = uint(_47);
              float _296 = frac(sin(dot(float2(float((uint)_287), float((uint)_288)), float2(12.989800453186035f, 78.23300170898438f))) * 43758.546875f) * 6.2831854820251465f;
              float _316 = mad(cb13_005x, _86, mad(cb13_004x, _85, (cb13_003x * _84))) + cb13_006x;
              float _320 = mad(cb13_005y, _86, mad(cb13_004y, _85, (cb13_003y * _84))) + cb13_006y;
              float _324 = mad(cb13_005z, _86, mad(cb13_004z, _85, (cb13_003z * _84))) + cb13_006z;
              [branch]
              if (ImprovedSoftShadows()) {
                  _1019 = GraphicsDirectionalVisibility(float3(_84, _85, _86), _107);
                } else {
if (!(abs(_324) >= 0.9990000128746033f)) {
                float _354 = max(abs(_316 - cb13_007x), abs(_320 - cb13_008x));
                float _355 = max(abs(_316 - cb13_007y), abs(_320 - cb13_008y));
                float _356 = max(abs(_316 - cb13_007z), abs(_320 - cb13_008z));
                float _357 = max(abs(_316 - cb13_007w), abs(_320 - cb13_008w));
                float _381 = dot(float4(float((bool)(uint)(_354 < cb13_009x)), float((bool)(uint)(_355 < cb13_009y)), float((bool)(uint)(_356 < cb13_009z)), float((bool)(uint)(_357 < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                [branch]
                if (!(_381 < 0.5f)) {
                  _20[0] = saturate((((_354 / cb13_009x) + -1.0f) + cb13_016x) / cb13_016x);
                  _20[1] = saturate((((_355 / cb13_009y) + -1.0f) + cb13_016y) / cb13_016y);
                  _20[2] = saturate((((_356 / cb13_009z) + -1.0f) + cb13_016z) / cb13_016z);
                  _20[3] = saturate((((_357 / cb13_009w) + -1.0f) + cb13_016w) / cb13_016w);
                  int _415 = int(cb13_014z - _381);
                  int _417 = int(cb13_014z) + -1;
                  int _420 = _288 & 1;
                  int _429 = ((uint)(_288) >> 1) & 1;
                  int _439 = ((uint)(_288) >> 2) & 1;
                  int _449 = ((uint)(_288) >> 3) & 1;
                  int _463 = min((((int)(uint)((int)(((float((int)(select(((_287 & 8) == 0), select((_449 != 0), 3, 0), (2 - _449)) | ((int)(((uint)(select(((_287 & 4) == 0), select((_439 != 0), 3, 0), (2 - _439)) | ((select(((_287 & 2) == 0), select((_429 != 0), 3, 0), (2 - _429)) | (select(((_287 & 1) == 0), select((_420 != 0), 3, 0), (2 - _420)) << 2u)) << 2u))) << 2u)))) + 0.5f) * 0.00390625f) < (_20[_415])))) + _415), _417);
                  float _471 = ((cb13_raw[((int)(_463 + 10u))].z) * _316) + (cb13_raw[((int)(_463 + 10u))].x);
                  float _472 = (cb13_raw[((int)(_463 + 10u))].y) - ((cb13_raw[((int)(_463 + 10u))].z) * _320);
                  if (!_107) {
                    _489 = (cb13_raw[((int)(_463 + 10u))].w);
                    _490 = 0.0f;
                    _491 = false;
                  } else {
                    _489 = (cb13_raw[((int)(_463 + 18u))].x);
                    _490 = (cb13_raw[((int)(_463 + 18u))].y);
                    _491 = ((cb13_raw[((int)(_463 + 18u))].z) > 0.0f);
                  }
                  float _492 = float((int)(_463));
                  float _493 = _489 * min(max(((1.0f / sqrt(max(dot(float3(_92, _93, _94), float3(cb13_000x, cb13_000y, cb13_000z)), 0.0f))) + -1.0f), 1.0f), 4.0f);
                  float _500 = t8.SampleCmpLevelZero(s9, float3(_471, _472, _492), _324);
                  if (!(_491 || (int)((int)cb13_017x < (int)1))) {
                    float _503 = sin(_296);
                    float _504 = cos(_296);
                    float _505 = _493 * -0.2633539140224457f;
                    float _506 = _493 * 0.03965381905436516f;
                    float _517 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _506)) + (_504 * _505)), (((_503 * _505) + _472) + (_504 * _506)), _492), (_324 - (_490 * 0.03703703731298447f)));
                    float _520 = _493 * -0.7172024250030518f;
                    float _521 = _493 * 0.3683032989501953f;
                    float _532 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _521)) + (_504 * _520)), (((_503 * _520) + _472) + (_504 * _521)), _492), (_324 - (_490 * 0.07407407462596893f)));
                    float _535 = _493 * -0.019953060895204544f;
                    float _536 = _493 * -0.39883920550346375f;
                    float _547 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _536)) + (_504 * _535)), (((_503 * _535) + _472) + (_504 * _536)), _492), (_324 - (_490 * 0.1111111119389534f)));
                    float _550 = _493 * -0.4409937858581543f;
                    float _551 = _493 * -0.2210099995136261f;
                    float _562 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _551)) + (_504 * _550)), (((_503 * _550) + _472) + (_504 * _551)), _492), (_324 - (_490 * 0.14814814925193787f)));
                    float _565 = _493 * 0.22003920376300812f;
                    float _566 = _493 * 0.29434481263160706f;
                    float _577 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _566)) + (_504 * _565)), (((_503 * _565) + _472) + (_504 * _566)), _492), (_324 - (_490 * 0.18518517911434174f)));
                    float _580 = _493 * -0.7675657272338867f;
                    float _581 = _493 * -0.14827530086040497f;
                    float _592 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _581)) + (_504 * _580)), (((_503 * _580) + _472) + (_504 * _581)), _492), (_324 - (_490 * 0.2222222238779068f)));
                    float _595 = _493 * -0.23810189962387085f;
                    float _596 = _493 * 0.5471062064170837f;
                    float _607 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _596)) + (_504 * _595)), (((_503 * _595) + _472) + (_504 * _596)), _492), (_324 - (_490 * 0.25925925374031067f)));
                    float _610 = _493 * 0.2173030972480774f;
                    float _611 = _493 * -0.13458789885044098f;
                    float _622 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _611)) + (_504 * _610)), (((_503 * _610) + _472) + (_504 * _611)), _492), (_324 - (_490 * 0.29629629850387573f)));
                    float _625 = _493 * -0.6387773752212524f;
                    float _626 = _493 * 0.7561339139938354f;
                    float _637 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _626)) + (_504 * _625)), (((_503 * _625) + _472) + (_504 * _626)), _492), (_324 - (_490 * 0.3333333432674408f)));
                    float _640 = _493 * -0.16141439974308014f;
                    float _641 = _493 * 0.9776520729064941f;
                    float _652 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _641)) + (_504 * _640)), (((_503 * _640) + _472) + (_504 * _641)), _492), (_324 - (_490 * 0.37037035822868347f)));
                    float _655 = _493 * 0.215631902217865f;
                    float _656 = _493 * 0.6123412847518921f;
                    float _667 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _656)) + (_504 * _655)), (((_503 * _655) + _472) + (_504 * _656)), _492), (_324 - (_490 * 0.40740740299224854f)));
                    float _670 = _493 * 0.23288750648498535f;
                    float _671 = _493 * 0.9452872276306152f;
                    float _682 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _671)) + (_504 * _670)), (((_503 * _670) + _472) + (_504 * _671)), _492), (_324 - (_490 * 0.4444444477558136f)));
                    float _685 = _493 * -0.9440643787384033f;
                    float _686 = _493 * 0.12360770255327225f;
                    float _697 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _686)) + (_504 * _685)), (((_503 * _685) + _472) + (_504 * _686)), _492), (_324 - (_490 * 0.48148149251937866f)));
                    float _700 = _493 * -0.7408236861228943f;
                    float _701 = _493 * -0.5076829791069031f;
                    float _712 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _701)) + (_504 * _700)), (((_503 * _700) + _472) + (_504 * _701)), _492), (_324 - (_490 * 0.5185185074806213f)));
                    float _715 = _493 * -0.4113019108772278f;
                    float _716 = _493 * -0.8905966877937317f;
                    float _727 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _716)) + (_504 * _715)), (((_503 * _715) + _472) + (_504 * _716)), _492), (_324 - (_490 * 0.5555555820465088f)));
                    float _730 = _493 * -0.2486429065465927f;
                    float _731 = _493 * -0.6213992834091187f;
                    float _742 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _731)) + (_504 * _730)), (((_503 * _730) + _472) + (_504 * _731)), _492), (_324 - (_490 * 0.5925925970077515f)));
                    float _745 = _493 * 0.6967849731445312f;
                    float _746 = _493 * 0.2644937038421631f;
                    float _757 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _746)) + (_504 * _745)), (((_503 * _745) + _472) + (_504 * _746)), _492), (_324 - (_490 * 0.6296296119689941f)));
                    float _760 = _493 * 0.5394362807273865f;
                    float _761 = _493 * 0.8173214793205261f;
                    float _772 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _761)) + (_504 * _760)), (((_503 * _760) + _472) + (_504 * _761)), _492), (_324 - (_490 * 0.6666666865348816f)));
                    float _775 = _493 * 0.6151208281517029f;
                    float _776 = _493 * -0.14986400306224823f;
                    float _787 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _776)) + (_504 * _775)), (((_503 * _775) + _472) + (_504 * _776)), _492), (_324 - (_490 * 0.7037037014961243f)));
                    float _790 = _493 * 0.0936533585190773f;
                    float _791 = _493 * -0.7817475199699402f;
                    float _802 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _791)) + (_504 * _790)), (((_503 * _790) + _472) + (_504 * _791)), _492), (_324 - (_490 * 0.7407407164573669f)));
                    float _805 = _493 * 0.27680671215057373f;
                    float _806 = _493 * -0.48959681391716003f;
                    float _817 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _806)) + (_504 * _805)), (((_503 * _805) + _472) + (_504 * _806)), _492), (_324 - (_490 * 0.7777777910232544f)));
                    float _820 = _493 * 0.6639180779457092f;
                    float _821 = _493 * -0.6007171869277954f;
                    float _832 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _821)) + (_504 * _820)), (((_503 * _820) + _472) + (_504 * _821)), _492), (_324 - (_490 * 0.8148148059844971f)));
                    float _835 = _493 * 0.38803690671920776f;
                    float _836 = _493 * -0.8950893878936768f;
                    float _847 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _836)) + (_504 * _835)), (((_503 * _835) + _472) + (_504 * _836)), _492), (_324 - (_490 * 0.8518518805503845f)));
                    float _850 = _493 * 0.9916144013404846f;
                    float _851 = _493 * -0.07939151674509048f;
                    float _862 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _851)) + (_504 * _850)), (((_503 * _850) + _472) + (_504 * _851)), _492), (_324 - (_490 * 0.8888888955116272f)));
                    float _865 = _493 * 0.783184826374054f;
                    float _866 = _493 * 0.6029347777366638f;
                    float _877 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _866)) + (_504 * _865)), (((_503 * _865) + _472) + (_504 * _866)), _492), (_324 - (_490 * 0.9259259104728699f)));
                    float _880 = _493 * 0.8998603224754333f;
                    float _881 = _493 * -0.39835429191589355f;
                    float _892 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _881)) + (_504 * _880)), (((_503 * _880) + _472) + (_504 * _881)), _492), (_324 - (_490 * 0.9629629850387573f)));
                    float _895 = ((((((((((((((((((((((((((_517.x + _500.x) + _532.x) + _547.x) + _562.x) + _577.x) + _592.x) + _607.x) + _622.x) + _637.x) + _652.x) + _667.x) + _682.x) + _697.x) + _712.x) + _727.x) + _742.x) + _757.x) + _772.x) + _787.x) + _802.x) + _817.x) + _832.x) + _847.x) + _862.x) + _877.x) + _892.x) * 0.03703703731298447f;
                    _1009 = (_895 * _895);
                  } else {
                    float _904 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.5077208280563354f)), (_472 - (_493 * 0.6170899271965027f)), _492), (_324 - (_490 * 0.07692307978868484f)));
                    float _913 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.051549021154642105f)), (_472 - (_493 * 0.7508097887039185f)), _492), (_324 - (_490 * 0.1538461595773697f)));
                    float _922 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.7641041874885559f)), ((_493 * 0.20091520249843597f) + _472), _492), (_324 - (_490 * 0.23076923191547394f)));
                    float _931 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.007284773979336023f) + _471), (_472 - (_493 * 0.20594699680805206f)), _492), (_324 - (_490 * 0.3076923191547394f)));
                    float _940 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.36620399355888367f)), ((_493 * 0.732379674911499f) + _472), _492), (_324 - (_490 * 0.38461539149284363f)));
                    float _949 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.9239581823348999f)), (_472 - (_493 * 0.2559643089771271f)), _492), (_324 - (_490 * 0.4615384638309479f)));
                    float _958 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.28692400455474854f)), ((_493 * 0.2780529856681824f) + _472), _492), (_324 - (_490 * 0.5384615659713745f)));
                    float _967 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.772301197052002f) + _471), ((_493 * 0.1573328971862793f) + _472), _492), (_324 - (_490 * 0.6153846383094788f)));
                    float _976 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.37851300835609436f) + _471), ((_493 * 0.4052199125289917f) + _472), _492), (_324 - (_490 * 0.692307710647583f)));
                    float _985 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4630216956138611f) + _471), (_472 - (_493 * 0.6914619207382202f)), _492), (_324 - (_490 * 0.7692307829856873f)));
                    float _994 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4235230088233948f) + _471), ((_493 * 0.8630279898643494f) + _472), _492), (_324 - (_490 * 0.8461538553237915f)));
                    float _1003 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.8558642864227295f) + _471), (_472 - (_493 * 0.3382554054260254f)), _492), (_324 - (_490 * 0.9230769276618958f)));
                    float _1006 = ((((((((((((_904.x + _500.x) + _913.x) + _922.x) + _931.x) + _940.x) + _949.x) + _958.x) + _967.x) + _976.x) + _985.x) + _994.x) + _1003.x) * 0.07692307978868484f;
                    _1009 = (_1006 * _1006);
                  }
                  _1019 = saturate(((_20[_417]) * select((_492 < float((int)(_417))), 0.0f, 1.0f)) + _1009);
                } else {
                  _1019 = 1.0f;
                }
              } else {
                _1019 = 1.0f;
              }
                }
              float _1024 = cb12_066x * 20.0f;
              float _1035 = _86 - cb12_000z;
              float _1044 = _86 * 0.009999999776482582f;
              float _1047 = _1044 / cb12_066x;
              float _1056 = _1044 / _1024;
              float _1061 = (((cb12_067x + _84) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000x) / cb13_000z);
              float _1062 = (((cb12_067y + _85) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000y) / cb13_000z);
              float _1067 = ((((cb12_067x * 20.0f) + _84) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000x) / cb13_000z);
              float _1068 = ((((cb12_067y * 20.0f) + _85) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000y) / cb13_000z);
              float _1069 = float((int)(int(trunc(cb12_068x))));
              float4 _1072 = t14.SampleLevel(s14, float3(_1061, _1062, _1069), 1.0f);
              float _1074 = float((int)(int(trunc(cb12_068y))));
              float4 _1075 = t14.SampleLevel(s14, float3(_1061, _1062, _1074), 1.0f);
              float _1079 = ((_1075.x - _1072.x) * cb12_066w) + _1072.x;
              float4 _1080 = t14.SampleLevel(s14, float3(_1067, _1068, _1069), 1.0f);
              float4 _1082 = t14.SampleLevel(s14, float3(_1067, _1068, _1074), 1.0f);
              _1100 = ((_1019 * _286) * GraphicsSurfaceCloudShadow(float3(_84, _85, _86), (1.0f - (((((_1080.x - _1079) + ((_1082.x - _1080.x) * cb12_066w)) * saturate((sqrt(_119 + (_1035 * _1035)) + -100.0f) * 0.006666666828095913f)) + _1079) * saturate((cb13_000z + -0.25f) * 10.0f)))));
            }
          }
          break;
        }
      } else {
        _286 = 1.0f;
        uint _287 = uint(_46);
        uint _288 = uint(_47);
        float _296 = frac(sin(dot(float2(float((uint)_287), float((uint)_288)), float2(12.989800453186035f, 78.23300170898438f))) * 43758.546875f) * 6.2831854820251465f;
        float _316 = mad(cb13_005x, _86, mad(cb13_004x, _85, (cb13_003x * _84))) + cb13_006x;
        float _320 = mad(cb13_005y, _86, mad(cb13_004y, _85, (cb13_003y * _84))) + cb13_006y;
        float _324 = mad(cb13_005z, _86, mad(cb13_004z, _85, (cb13_003z * _84))) + cb13_006z;
        [branch]
        if (ImprovedSoftShadows()) {
                  _1019 = GraphicsDirectionalVisibility(float3(_84, _85, _86), _107);
                } else {
if (!(abs(_324) >= 0.9990000128746033f)) {
          float _354 = max(abs(_316 - cb13_007x), abs(_320 - cb13_008x));
          float _355 = max(abs(_316 - cb13_007y), abs(_320 - cb13_008y));
          float _356 = max(abs(_316 - cb13_007z), abs(_320 - cb13_008z));
          float _357 = max(abs(_316 - cb13_007w), abs(_320 - cb13_008w));
          float _381 = dot(float4(float((bool)(uint)(_354 < cb13_009x)), float((bool)(uint)(_355 < cb13_009y)), float((bool)(uint)(_356 < cb13_009z)), float((bool)(uint)(_357 < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
          [branch]
          if (!(_381 < 0.5f)) {
            _20[0] = saturate((((_354 / cb13_009x) + -1.0f) + cb13_016x) / cb13_016x);
            _20[1] = saturate((((_355 / cb13_009y) + -1.0f) + cb13_016y) / cb13_016y);
            _20[2] = saturate((((_356 / cb13_009z) + -1.0f) + cb13_016z) / cb13_016z);
            _20[3] = saturate((((_357 / cb13_009w) + -1.0f) + cb13_016w) / cb13_016w);
            int _415 = int(cb13_014z - _381);
            int _417 = int(cb13_014z) + -1;
            int _420 = _288 & 1;
            int _429 = ((uint)(_288) >> 1) & 1;
            int _439 = ((uint)(_288) >> 2) & 1;
            int _449 = ((uint)(_288) >> 3) & 1;
            int _463 = min((((int)(uint)((int)(((float((int)(select(((_287 & 8) == 0), select((_449 != 0), 3, 0), (2 - _449)) | ((int)(((uint)(select(((_287 & 4) == 0), select((_439 != 0), 3, 0), (2 - _439)) | ((select(((_287 & 2) == 0), select((_429 != 0), 3, 0), (2 - _429)) | (select(((_287 & 1) == 0), select((_420 != 0), 3, 0), (2 - _420)) << 2u)) << 2u))) << 2u)))) + 0.5f) * 0.00390625f) < (_20[_415])))) + _415), _417);
            float _471 = ((cb13_raw[((int)(_463 + 10u))].z) * _316) + (cb13_raw[((int)(_463 + 10u))].x);
            float _472 = (cb13_raw[((int)(_463 + 10u))].y) - ((cb13_raw[((int)(_463 + 10u))].z) * _320);
            if (!_107) {
              _489 = (cb13_raw[((int)(_463 + 10u))].w);
              _490 = 0.0f;
              _491 = false;
            } else {
              _489 = (cb13_raw[((int)(_463 + 18u))].x);
              _490 = (cb13_raw[((int)(_463 + 18u))].y);
              _491 = ((cb13_raw[((int)(_463 + 18u))].z) > 0.0f);
            }
            float _492 = float((int)(_463));
            float _493 = _489 * min(max(((1.0f / sqrt(max(dot(float3(_92, _93, _94), float3(cb13_000x, cb13_000y, cb13_000z)), 0.0f))) + -1.0f), 1.0f), 4.0f);
            float _500 = t8.SampleCmpLevelZero(s9, float3(_471, _472, _492), _324);
            if (!(_491 || (int)((int)cb13_017x < (int)1))) {
              float _503 = sin(_296);
              float _504 = cos(_296);
              float _505 = _493 * -0.2633539140224457f;
              float _506 = _493 * 0.03965381905436516f;
              float _517 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _506)) + (_504 * _505)), (((_503 * _505) + _472) + (_504 * _506)), _492), (_324 - (_490 * 0.03703703731298447f)));
              float _520 = _493 * -0.7172024250030518f;
              float _521 = _493 * 0.3683032989501953f;
              float _532 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _521)) + (_504 * _520)), (((_503 * _520) + _472) + (_504 * _521)), _492), (_324 - (_490 * 0.07407407462596893f)));
              float _535 = _493 * -0.019953060895204544f;
              float _536 = _493 * -0.39883920550346375f;
              float _547 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _536)) + (_504 * _535)), (((_503 * _535) + _472) + (_504 * _536)), _492), (_324 - (_490 * 0.1111111119389534f)));
              float _550 = _493 * -0.4409937858581543f;
              float _551 = _493 * -0.2210099995136261f;
              float _562 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _551)) + (_504 * _550)), (((_503 * _550) + _472) + (_504 * _551)), _492), (_324 - (_490 * 0.14814814925193787f)));
              float _565 = _493 * 0.22003920376300812f;
              float _566 = _493 * 0.29434481263160706f;
              float _577 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _566)) + (_504 * _565)), (((_503 * _565) + _472) + (_504 * _566)), _492), (_324 - (_490 * 0.18518517911434174f)));
              float _580 = _493 * -0.7675657272338867f;
              float _581 = _493 * -0.14827530086040497f;
              float _592 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _581)) + (_504 * _580)), (((_503 * _580) + _472) + (_504 * _581)), _492), (_324 - (_490 * 0.2222222238779068f)));
              float _595 = _493 * -0.23810189962387085f;
              float _596 = _493 * 0.5471062064170837f;
              float _607 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _596)) + (_504 * _595)), (((_503 * _595) + _472) + (_504 * _596)), _492), (_324 - (_490 * 0.25925925374031067f)));
              float _610 = _493 * 0.2173030972480774f;
              float _611 = _493 * -0.13458789885044098f;
              float _622 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _611)) + (_504 * _610)), (((_503 * _610) + _472) + (_504 * _611)), _492), (_324 - (_490 * 0.29629629850387573f)));
              float _625 = _493 * -0.6387773752212524f;
              float _626 = _493 * 0.7561339139938354f;
              float _637 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _626)) + (_504 * _625)), (((_503 * _625) + _472) + (_504 * _626)), _492), (_324 - (_490 * 0.3333333432674408f)));
              float _640 = _493 * -0.16141439974308014f;
              float _641 = _493 * 0.9776520729064941f;
              float _652 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _641)) + (_504 * _640)), (((_503 * _640) + _472) + (_504 * _641)), _492), (_324 - (_490 * 0.37037035822868347f)));
              float _655 = _493 * 0.215631902217865f;
              float _656 = _493 * 0.6123412847518921f;
              float _667 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _656)) + (_504 * _655)), (((_503 * _655) + _472) + (_504 * _656)), _492), (_324 - (_490 * 0.40740740299224854f)));
              float _670 = _493 * 0.23288750648498535f;
              float _671 = _493 * 0.9452872276306152f;
              float _682 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _671)) + (_504 * _670)), (((_503 * _670) + _472) + (_504 * _671)), _492), (_324 - (_490 * 0.4444444477558136f)));
              float _685 = _493 * -0.9440643787384033f;
              float _686 = _493 * 0.12360770255327225f;
              float _697 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _686)) + (_504 * _685)), (((_503 * _685) + _472) + (_504 * _686)), _492), (_324 - (_490 * 0.48148149251937866f)));
              float _700 = _493 * -0.7408236861228943f;
              float _701 = _493 * -0.5076829791069031f;
              float _712 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _701)) + (_504 * _700)), (((_503 * _700) + _472) + (_504 * _701)), _492), (_324 - (_490 * 0.5185185074806213f)));
              float _715 = _493 * -0.4113019108772278f;
              float _716 = _493 * -0.8905966877937317f;
              float _727 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _716)) + (_504 * _715)), (((_503 * _715) + _472) + (_504 * _716)), _492), (_324 - (_490 * 0.5555555820465088f)));
              float _730 = _493 * -0.2486429065465927f;
              float _731 = _493 * -0.6213992834091187f;
              float _742 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _731)) + (_504 * _730)), (((_503 * _730) + _472) + (_504 * _731)), _492), (_324 - (_490 * 0.5925925970077515f)));
              float _745 = _493 * 0.6967849731445312f;
              float _746 = _493 * 0.2644937038421631f;
              float _757 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _746)) + (_504 * _745)), (((_503 * _745) + _472) + (_504 * _746)), _492), (_324 - (_490 * 0.6296296119689941f)));
              float _760 = _493 * 0.5394362807273865f;
              float _761 = _493 * 0.8173214793205261f;
              float _772 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _761)) + (_504 * _760)), (((_503 * _760) + _472) + (_504 * _761)), _492), (_324 - (_490 * 0.6666666865348816f)));
              float _775 = _493 * 0.6151208281517029f;
              float _776 = _493 * -0.14986400306224823f;
              float _787 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _776)) + (_504 * _775)), (((_503 * _775) + _472) + (_504 * _776)), _492), (_324 - (_490 * 0.7037037014961243f)));
              float _790 = _493 * 0.0936533585190773f;
              float _791 = _493 * -0.7817475199699402f;
              float _802 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _791)) + (_504 * _790)), (((_503 * _790) + _472) + (_504 * _791)), _492), (_324 - (_490 * 0.7407407164573669f)));
              float _805 = _493 * 0.27680671215057373f;
              float _806 = _493 * -0.48959681391716003f;
              float _817 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _806)) + (_504 * _805)), (((_503 * _805) + _472) + (_504 * _806)), _492), (_324 - (_490 * 0.7777777910232544f)));
              float _820 = _493 * 0.6639180779457092f;
              float _821 = _493 * -0.6007171869277954f;
              float _832 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _821)) + (_504 * _820)), (((_503 * _820) + _472) + (_504 * _821)), _492), (_324 - (_490 * 0.8148148059844971f)));
              float _835 = _493 * 0.38803690671920776f;
              float _836 = _493 * -0.8950893878936768f;
              float _847 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _836)) + (_504 * _835)), (((_503 * _835) + _472) + (_504 * _836)), _492), (_324 - (_490 * 0.8518518805503845f)));
              float _850 = _493 * 0.9916144013404846f;
              float _851 = _493 * -0.07939151674509048f;
              float _862 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _851)) + (_504 * _850)), (((_503 * _850) + _472) + (_504 * _851)), _492), (_324 - (_490 * 0.8888888955116272f)));
              float _865 = _493 * 0.783184826374054f;
              float _866 = _493 * 0.6029347777366638f;
              float _877 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _866)) + (_504 * _865)), (((_503 * _865) + _472) + (_504 * _866)), _492), (_324 - (_490 * 0.9259259104728699f)));
              float _880 = _493 * 0.8998603224754333f;
              float _881 = _493 * -0.39835429191589355f;
              float _892 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _881)) + (_504 * _880)), (((_503 * _880) + _472) + (_504 * _881)), _492), (_324 - (_490 * 0.9629629850387573f)));
              float _895 = ((((((((((((((((((((((((((_517.x + _500.x) + _532.x) + _547.x) + _562.x) + _577.x) + _592.x) + _607.x) + _622.x) + _637.x) + _652.x) + _667.x) + _682.x) + _697.x) + _712.x) + _727.x) + _742.x) + _757.x) + _772.x) + _787.x) + _802.x) + _817.x) + _832.x) + _847.x) + _862.x) + _877.x) + _892.x) * 0.03703703731298447f;
              _1009 = (_895 * _895);
            } else {
              float _904 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.5077208280563354f)), (_472 - (_493 * 0.6170899271965027f)), _492), (_324 - (_490 * 0.07692307978868484f)));
              float _913 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.051549021154642105f)), (_472 - (_493 * 0.7508097887039185f)), _492), (_324 - (_490 * 0.1538461595773697f)));
              float _922 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.7641041874885559f)), ((_493 * 0.20091520249843597f) + _472), _492), (_324 - (_490 * 0.23076923191547394f)));
              float _931 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.007284773979336023f) + _471), (_472 - (_493 * 0.20594699680805206f)), _492), (_324 - (_490 * 0.3076923191547394f)));
              float _940 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.36620399355888367f)), ((_493 * 0.732379674911499f) + _472), _492), (_324 - (_490 * 0.38461539149284363f)));
              float _949 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.9239581823348999f)), (_472 - (_493 * 0.2559643089771271f)), _492), (_324 - (_490 * 0.4615384638309479f)));
              float _958 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.28692400455474854f)), ((_493 * 0.2780529856681824f) + _472), _492), (_324 - (_490 * 0.5384615659713745f)));
              float _967 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.772301197052002f) + _471), ((_493 * 0.1573328971862793f) + _472), _492), (_324 - (_490 * 0.6153846383094788f)));
              float _976 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.37851300835609436f) + _471), ((_493 * 0.4052199125289917f) + _472), _492), (_324 - (_490 * 0.692307710647583f)));
              float _985 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4630216956138611f) + _471), (_472 - (_493 * 0.6914619207382202f)), _492), (_324 - (_490 * 0.7692307829856873f)));
              float _994 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4235230088233948f) + _471), ((_493 * 0.8630279898643494f) + _472), _492), (_324 - (_490 * 0.8461538553237915f)));
              float _1003 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.8558642864227295f) + _471), (_472 - (_493 * 0.3382554054260254f)), _492), (_324 - (_490 * 0.9230769276618958f)));
              float _1006 = ((((((((((((_904.x + _500.x) + _913.x) + _922.x) + _931.x) + _940.x) + _949.x) + _958.x) + _967.x) + _976.x) + _985.x) + _994.x) + _1003.x) * 0.07692307978868484f;
              _1009 = (_1006 * _1006);
            }
            _1019 = saturate(((_20[_417]) * select((_492 < float((int)(_417))), 0.0f, 1.0f)) + _1009);
          } else {
            _1019 = 1.0f;
          }
        } else {
          _1019 = 1.0f;
        }
                }
        float _1024 = cb12_066x * 20.0f;
        float _1035 = _86 - cb12_000z;
        float _1044 = _86 * 0.009999999776482582f;
        float _1047 = _1044 / cb12_066x;
        float _1056 = _1044 / _1024;
        float _1061 = (((cb12_067x + _84) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000x) / cb13_000z);
        float _1062 = (((cb12_067y + _85) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000y) / cb13_000z);
        float _1067 = ((((cb12_067x * 20.0f) + _84) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000x) / cb13_000z);
        float _1068 = ((((cb12_067y * 20.0f) + _85) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000y) / cb13_000z);
        float _1069 = float((int)(int(trunc(cb12_068x))));
        float4 _1072 = t14.SampleLevel(s14, float3(_1061, _1062, _1069), 1.0f);
        float _1074 = float((int)(int(trunc(cb12_068y))));
        float4 _1075 = t14.SampleLevel(s14, float3(_1061, _1062, _1074), 1.0f);
        float _1079 = ((_1075.x - _1072.x) * cb12_066w) + _1072.x;
        float4 _1080 = t14.SampleLevel(s14, float3(_1067, _1068, _1069), 1.0f);
        float4 _1082 = t14.SampleLevel(s14, float3(_1067, _1068, _1074), 1.0f);
        _1100 = ((_1019 * _286) * GraphicsSurfaceCloudShadow(float3(_84, _85, _86), (1.0f - (((((_1080.x - _1079) + ((_1082.x - _1080.x) * cb12_066w)) * saturate((sqrt(_119 + (_1035 * _1035)) + -100.0f) * 0.006666666828095913f)) + _1079) * saturate((cb13_000z + -0.25f) * 10.0f)))));
      }
    } else {
      _286 = 1.0f;
      uint _287 = uint(_46);
      uint _288 = uint(_47);
      float _296 = frac(sin(dot(float2(float((uint)_287), float((uint)_288)), float2(12.989800453186035f, 78.23300170898438f))) * 43758.546875f) * 6.2831854820251465f;
      float _316 = mad(cb13_005x, _86, mad(cb13_004x, _85, (cb13_003x * _84))) + cb13_006x;
      float _320 = mad(cb13_005y, _86, mad(cb13_004y, _85, (cb13_003y * _84))) + cb13_006y;
      float _324 = mad(cb13_005z, _86, mad(cb13_004z, _85, (cb13_003z * _84))) + cb13_006z;
      [branch]
      if (ImprovedSoftShadows()) {
                  _1019 = GraphicsDirectionalVisibility(float3(_84, _85, _86), _107);
                } else {
if (!(abs(_324) >= 0.9990000128746033f)) {
        float _354 = max(abs(_316 - cb13_007x), abs(_320 - cb13_008x));
        float _355 = max(abs(_316 - cb13_007y), abs(_320 - cb13_008y));
        float _356 = max(abs(_316 - cb13_007z), abs(_320 - cb13_008z));
        float _357 = max(abs(_316 - cb13_007w), abs(_320 - cb13_008w));
        float _381 = dot(float4(float((bool)(uint)(_354 < cb13_009x)), float((bool)(uint)(_355 < cb13_009y)), float((bool)(uint)(_356 < cb13_009z)), float((bool)(uint)(_357 < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
        [branch]
        if (!(_381 < 0.5f)) {
          _20[0] = saturate((((_354 / cb13_009x) + -1.0f) + cb13_016x) / cb13_016x);
          _20[1] = saturate((((_355 / cb13_009y) + -1.0f) + cb13_016y) / cb13_016y);
          _20[2] = saturate((((_356 / cb13_009z) + -1.0f) + cb13_016z) / cb13_016z);
          _20[3] = saturate((((_357 / cb13_009w) + -1.0f) + cb13_016w) / cb13_016w);
          int _415 = int(cb13_014z - _381);
          int _417 = int(cb13_014z) + -1;
          int _420 = _288 & 1;
          int _429 = ((uint)(_288) >> 1) & 1;
          int _439 = ((uint)(_288) >> 2) & 1;
          int _449 = ((uint)(_288) >> 3) & 1;
          int _463 = min((((int)(uint)((int)(((float((int)(select(((_287 & 8) == 0), select((_449 != 0), 3, 0), (2 - _449)) | ((int)(((uint)(select(((_287 & 4) == 0), select((_439 != 0), 3, 0), (2 - _439)) | ((select(((_287 & 2) == 0), select((_429 != 0), 3, 0), (2 - _429)) | (select(((_287 & 1) == 0), select((_420 != 0), 3, 0), (2 - _420)) << 2u)) << 2u))) << 2u)))) + 0.5f) * 0.00390625f) < (_20[_415])))) + _415), _417);
          float _471 = ((cb13_raw[((int)(_463 + 10u))].z) * _316) + (cb13_raw[((int)(_463 + 10u))].x);
          float _472 = (cb13_raw[((int)(_463 + 10u))].y) - ((cb13_raw[((int)(_463 + 10u))].z) * _320);
          if (!_107) {
            _489 = (cb13_raw[((int)(_463 + 10u))].w);
            _490 = 0.0f;
            _491 = false;
          } else {
            _489 = (cb13_raw[((int)(_463 + 18u))].x);
            _490 = (cb13_raw[((int)(_463 + 18u))].y);
            _491 = ((cb13_raw[((int)(_463 + 18u))].z) > 0.0f);
          }
          float _492 = float((int)(_463));
          float _493 = _489 * min(max(((1.0f / sqrt(max(dot(float3(_92, _93, _94), float3(cb13_000x, cb13_000y, cb13_000z)), 0.0f))) + -1.0f), 1.0f), 4.0f);
          float _500 = t8.SampleCmpLevelZero(s9, float3(_471, _472, _492), _324);
          if (!(_491 || (int)((int)cb13_017x < (int)1))) {
            float _503 = sin(_296);
            float _504 = cos(_296);
            float _505 = _493 * -0.2633539140224457f;
            float _506 = _493 * 0.03965381905436516f;
            float _517 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _506)) + (_504 * _505)), (((_503 * _505) + _472) + (_504 * _506)), _492), (_324 - (_490 * 0.03703703731298447f)));
            float _520 = _493 * -0.7172024250030518f;
            float _521 = _493 * 0.3683032989501953f;
            float _532 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _521)) + (_504 * _520)), (((_503 * _520) + _472) + (_504 * _521)), _492), (_324 - (_490 * 0.07407407462596893f)));
            float _535 = _493 * -0.019953060895204544f;
            float _536 = _493 * -0.39883920550346375f;
            float _547 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _536)) + (_504 * _535)), (((_503 * _535) + _472) + (_504 * _536)), _492), (_324 - (_490 * 0.1111111119389534f)));
            float _550 = _493 * -0.4409937858581543f;
            float _551 = _493 * -0.2210099995136261f;
            float _562 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _551)) + (_504 * _550)), (((_503 * _550) + _472) + (_504 * _551)), _492), (_324 - (_490 * 0.14814814925193787f)));
            float _565 = _493 * 0.22003920376300812f;
            float _566 = _493 * 0.29434481263160706f;
            float _577 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _566)) + (_504 * _565)), (((_503 * _565) + _472) + (_504 * _566)), _492), (_324 - (_490 * 0.18518517911434174f)));
            float _580 = _493 * -0.7675657272338867f;
            float _581 = _493 * -0.14827530086040497f;
            float _592 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _581)) + (_504 * _580)), (((_503 * _580) + _472) + (_504 * _581)), _492), (_324 - (_490 * 0.2222222238779068f)));
            float _595 = _493 * -0.23810189962387085f;
            float _596 = _493 * 0.5471062064170837f;
            float _607 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _596)) + (_504 * _595)), (((_503 * _595) + _472) + (_504 * _596)), _492), (_324 - (_490 * 0.25925925374031067f)));
            float _610 = _493 * 0.2173030972480774f;
            float _611 = _493 * -0.13458789885044098f;
            float _622 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _611)) + (_504 * _610)), (((_503 * _610) + _472) + (_504 * _611)), _492), (_324 - (_490 * 0.29629629850387573f)));
            float _625 = _493 * -0.6387773752212524f;
            float _626 = _493 * 0.7561339139938354f;
            float _637 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _626)) + (_504 * _625)), (((_503 * _625) + _472) + (_504 * _626)), _492), (_324 - (_490 * 0.3333333432674408f)));
            float _640 = _493 * -0.16141439974308014f;
            float _641 = _493 * 0.9776520729064941f;
            float _652 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _641)) + (_504 * _640)), (((_503 * _640) + _472) + (_504 * _641)), _492), (_324 - (_490 * 0.37037035822868347f)));
            float _655 = _493 * 0.215631902217865f;
            float _656 = _493 * 0.6123412847518921f;
            float _667 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _656)) + (_504 * _655)), (((_503 * _655) + _472) + (_504 * _656)), _492), (_324 - (_490 * 0.40740740299224854f)));
            float _670 = _493 * 0.23288750648498535f;
            float _671 = _493 * 0.9452872276306152f;
            float _682 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _671)) + (_504 * _670)), (((_503 * _670) + _472) + (_504 * _671)), _492), (_324 - (_490 * 0.4444444477558136f)));
            float _685 = _493 * -0.9440643787384033f;
            float _686 = _493 * 0.12360770255327225f;
            float _697 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _686)) + (_504 * _685)), (((_503 * _685) + _472) + (_504 * _686)), _492), (_324 - (_490 * 0.48148149251937866f)));
            float _700 = _493 * -0.7408236861228943f;
            float _701 = _493 * -0.5076829791069031f;
            float _712 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _701)) + (_504 * _700)), (((_503 * _700) + _472) + (_504 * _701)), _492), (_324 - (_490 * 0.5185185074806213f)));
            float _715 = _493 * -0.4113019108772278f;
            float _716 = _493 * -0.8905966877937317f;
            float _727 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _716)) + (_504 * _715)), (((_503 * _715) + _472) + (_504 * _716)), _492), (_324 - (_490 * 0.5555555820465088f)));
            float _730 = _493 * -0.2486429065465927f;
            float _731 = _493 * -0.6213992834091187f;
            float _742 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _731)) + (_504 * _730)), (((_503 * _730) + _472) + (_504 * _731)), _492), (_324 - (_490 * 0.5925925970077515f)));
            float _745 = _493 * 0.6967849731445312f;
            float _746 = _493 * 0.2644937038421631f;
            float _757 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _746)) + (_504 * _745)), (((_503 * _745) + _472) + (_504 * _746)), _492), (_324 - (_490 * 0.6296296119689941f)));
            float _760 = _493 * 0.5394362807273865f;
            float _761 = _493 * 0.8173214793205261f;
            float _772 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _761)) + (_504 * _760)), (((_503 * _760) + _472) + (_504 * _761)), _492), (_324 - (_490 * 0.6666666865348816f)));
            float _775 = _493 * 0.6151208281517029f;
            float _776 = _493 * -0.14986400306224823f;
            float _787 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _776)) + (_504 * _775)), (((_503 * _775) + _472) + (_504 * _776)), _492), (_324 - (_490 * 0.7037037014961243f)));
            float _790 = _493 * 0.0936533585190773f;
            float _791 = _493 * -0.7817475199699402f;
            float _802 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _791)) + (_504 * _790)), (((_503 * _790) + _472) + (_504 * _791)), _492), (_324 - (_490 * 0.7407407164573669f)));
            float _805 = _493 * 0.27680671215057373f;
            float _806 = _493 * -0.48959681391716003f;
            float _817 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _806)) + (_504 * _805)), (((_503 * _805) + _472) + (_504 * _806)), _492), (_324 - (_490 * 0.7777777910232544f)));
            float _820 = _493 * 0.6639180779457092f;
            float _821 = _493 * -0.6007171869277954f;
            float _832 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _821)) + (_504 * _820)), (((_503 * _820) + _472) + (_504 * _821)), _492), (_324 - (_490 * 0.8148148059844971f)));
            float _835 = _493 * 0.38803690671920776f;
            float _836 = _493 * -0.8950893878936768f;
            float _847 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _836)) + (_504 * _835)), (((_503 * _835) + _472) + (_504 * _836)), _492), (_324 - (_490 * 0.8518518805503845f)));
            float _850 = _493 * 0.9916144013404846f;
            float _851 = _493 * -0.07939151674509048f;
            float _862 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _851)) + (_504 * _850)), (((_503 * _850) + _472) + (_504 * _851)), _492), (_324 - (_490 * 0.8888888955116272f)));
            float _865 = _493 * 0.783184826374054f;
            float _866 = _493 * 0.6029347777366638f;
            float _877 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _866)) + (_504 * _865)), (((_503 * _865) + _472) + (_504 * _866)), _492), (_324 - (_490 * 0.9259259104728699f)));
            float _880 = _493 * 0.8998603224754333f;
            float _881 = _493 * -0.39835429191589355f;
            float _892 = t8.SampleCmpLevelZero(s9, float3(((_471 - (_503 * _881)) + (_504 * _880)), (((_503 * _880) + _472) + (_504 * _881)), _492), (_324 - (_490 * 0.9629629850387573f)));
            float _895 = ((((((((((((((((((((((((((_517.x + _500.x) + _532.x) + _547.x) + _562.x) + _577.x) + _592.x) + _607.x) + _622.x) + _637.x) + _652.x) + _667.x) + _682.x) + _697.x) + _712.x) + _727.x) + _742.x) + _757.x) + _772.x) + _787.x) + _802.x) + _817.x) + _832.x) + _847.x) + _862.x) + _877.x) + _892.x) * 0.03703703731298447f;
            _1009 = (_895 * _895);
          } else {
            float _904 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.5077208280563354f)), (_472 - (_493 * 0.6170899271965027f)), _492), (_324 - (_490 * 0.07692307978868484f)));
            float _913 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.051549021154642105f)), (_472 - (_493 * 0.7508097887039185f)), _492), (_324 - (_490 * 0.1538461595773697f)));
            float _922 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.7641041874885559f)), ((_493 * 0.20091520249843597f) + _472), _492), (_324 - (_490 * 0.23076923191547394f)));
            float _931 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.007284773979336023f) + _471), (_472 - (_493 * 0.20594699680805206f)), _492), (_324 - (_490 * 0.3076923191547394f)));
            float _940 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.36620399355888367f)), ((_493 * 0.732379674911499f) + _472), _492), (_324 - (_490 * 0.38461539149284363f)));
            float _949 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.9239581823348999f)), (_472 - (_493 * 0.2559643089771271f)), _492), (_324 - (_490 * 0.4615384638309479f)));
            float _958 = t8.SampleCmpLevelZero(s9, float3((_471 - (_493 * 0.28692400455474854f)), ((_493 * 0.2780529856681824f) + _472), _492), (_324 - (_490 * 0.5384615659713745f)));
            float _967 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.772301197052002f) + _471), ((_493 * 0.1573328971862793f) + _472), _492), (_324 - (_490 * 0.6153846383094788f)));
            float _976 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.37851300835609436f) + _471), ((_493 * 0.4052199125289917f) + _472), _492), (_324 - (_490 * 0.692307710647583f)));
            float _985 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4630216956138611f) + _471), (_472 - (_493 * 0.6914619207382202f)), _492), (_324 - (_490 * 0.7692307829856873f)));
            float _994 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.4235230088233948f) + _471), ((_493 * 0.8630279898643494f) + _472), _492), (_324 - (_490 * 0.8461538553237915f)));
            float _1003 = t8.SampleCmpLevelZero(s9, float3(((_493 * 0.8558642864227295f) + _471), (_472 - (_493 * 0.3382554054260254f)), _492), (_324 - (_490 * 0.9230769276618958f)));
            float _1006 = ((((((((((((_904.x + _500.x) + _913.x) + _922.x) + _931.x) + _940.x) + _949.x) + _958.x) + _967.x) + _976.x) + _985.x) + _994.x) + _1003.x) * 0.07692307978868484f;
            _1009 = (_1006 * _1006);
          }
          _1019 = saturate(((_20[_417]) * select((_492 < float((int)(_417))), 0.0f, 1.0f)) + _1009);
        } else {
          _1019 = 1.0f;
        }
      } else {
        _1019 = 1.0f;
      }
                }
      float _1024 = cb12_066x * 20.0f;
      float _1035 = _86 - cb12_000z;
      float _1044 = _86 * 0.009999999776482582f;
      float _1047 = _1044 / cb12_066x;
      float _1056 = _1044 / _1024;
      float _1061 = (((cb12_067x + _84) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000x) / cb13_000z);
      float _1062 = (((cb12_067y + _85) * 0.009999999776482582f) / cb12_066x) - ((_1047 * cb13_000y) / cb13_000z);
      float _1067 = ((((cb12_067x * 20.0f) + _84) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000x) / cb13_000z);
      float _1068 = ((((cb12_067y * 20.0f) + _85) * 0.009999999776482582f) / _1024) - ((_1056 * cb13_000y) / cb13_000z);
      float _1069 = float((int)(int(trunc(cb12_068x))));
      float4 _1072 = t14.SampleLevel(s14, float3(_1061, _1062, _1069), 1.0f);
      float _1074 = float((int)(int(trunc(cb12_068y))));
      float4 _1075 = t14.SampleLevel(s14, float3(_1061, _1062, _1074), 1.0f);
      float _1079 = ((_1075.x - _1072.x) * cb12_066w) + _1072.x;
      float4 _1080 = t14.SampleLevel(s14, float3(_1067, _1068, _1069), 1.0f);
      float4 _1082 = t14.SampleLevel(s14, float3(_1067, _1068, _1074), 1.0f);
      _1100 = ((_1019 * _286) * GraphicsSurfaceCloudShadow(float3(_84, _85, _86), (1.0f - (((((_1080.x - _1079) + ((_1082.x - _1080.x) * cb12_066w)) * saturate((sqrt(_119 + (_1035 * _1035)) + -100.0f) * 0.006666666828095913f)) + _1079) * saturate((cb13_000z + -0.25f) * 10.0f)))));
    }
    bool _1101 = (_1100 > 0.0f);
    if (!(CBGlobalShadowsConstants_016 == 0)) {
      if (dot(float3(_92, _93, _94), float3(cb13_000x, cb13_000y, cb13_000z)) < 0.0f) {
        if (_99) {
          if (!((int)(CBGlobalShadowsConstants_020 != 0) || ((int)(!_1101)))) {
            int _1120 = (((int)(_21 << 8u)) | _21) & 16711935;
            int _1123 = ((_1120 << 4u) | _1120) & 252645135;
            int _1126 = ((_1123 << 2u) | _1123) & 858993459;
            int _1132 = (((int)(_22 << 8u)) | _22) & 16711935;
            int _1135 = ((_1132 << 4u) | _1132) & 252645135;
            int _1138 = ((_1135 << 2u) | _1135) & 858993459;
            uint _1151 = ((uint)((((int)(((uint)(CBGlobalShadowsConstants_064) << 4u) + -1556008596u)) ^ ((int)((uint)(CBGlobalShadowsConstants_064) + -1640531527u))) ^ (((uint)((uint)(CBGlobalShadowsConstants_064)) >> 5) + -939442524))) + ((uint)((((int)(((uint)((_1138 << 1u) | _1138)) << 1u)) & -1431655766) | (((_1126 << 1u) | _1126) & 1431655765)));
            uint _1159 = ((uint)((((int)((_1151 << 4u) + -1383041155u)) ^ ((int)(_1151 + -1640531527u))) ^ ((int)(((uint)((uint)(_1151) >> 5)) + 2123724318u)))) + (uint)(CBGlobalShadowsConstants_064);
            uint _1167 = ((uint)((((int)((_1159 << 4u) + -1556008596u)) ^ ((int)(_1159 + 1013904242u))) ^ (((uint)(_1159) >> 5) + -939442524))) + _1151;
            uint _1175 = ((uint)((((int)((_1167 << 4u) + -1383041155u)) ^ ((int)(_1167 + 1013904242u))) ^ ((int)(((uint)((uint)(_1167) >> 5)) + 2123724318u)))) + _1159;
            uint _1183 = ((uint)((((int)((_1175 << 4u) + -1556008596u)) ^ ((int)(_1175 + -626627285u))) ^ (((uint)(_1175) >> 5) + -939442524))) + _1167;
            uint _1191 = ((uint)((((int)((_1183 << 4u) + -1383041155u)) ^ ((int)(_1183 + -626627285u))) ^ ((int)(((uint)((uint)(_1183) >> 5)) + 2123724318u)))) + _1175;
            uint _1199 = ((uint)((((int)((_1191 << 4u) + -1556008596u)) ^ ((int)(_1191 + 2027808484u))) ^ (((uint)(_1191) >> 5) + -939442524))) + _1183;
            uint _1207 = ((uint)((((int)((_1199 << 4u) + -1383041155u)) ^ ((int)(_1199 + 2027808484u))) ^ ((int)(((uint)((uint)(_1199) >> 5)) + 2123724318u)))) + _1191;
            uint _1215 = ((uint)((((int)((_1207 << 4u) + -1556008596u)) ^ ((int)(_1207 + 387276957u))) ^ (((uint)(_1207) >> 5) + -939442524))) + _1199;
            uint _1223 = ((uint)((((int)((_1215 << 4u) + -1383041155u)) ^ ((int)(_1215 + 387276957u))) ^ ((int)(((uint)((uint)(_1215) >> 5)) + 2123724318u)))) + _1207;
            uint _1231 = ((uint)((((int)((_1223 << 4u) + -1556008596u)) ^ ((int)(_1223 + -1253254570u))) ^ (((uint)(_1223) >> 5) + -939442524))) + _1215;
            uint _1239 = ((uint)((((int)((_1231 << 4u) + -1383041155u)) ^ ((int)(_1231 + -1253254570u))) ^ ((int)(((uint)((uint)(_1231) >> 5)) + 2123724318u)))) + _1223;
            uint _1247 = ((uint)((((int)((_1239 << 4u) + -1556008596u)) ^ ((int)(_1239 + 1401181199u))) ^ (((uint)(_1239) >> 5) + -939442524))) + _1231;
            uint _1255 = ((uint)((((int)((_1247 << 4u) + -1383041155u)) ^ ((int)(_1247 + 1401181199u))) ^ ((int)(((uint)((uint)(_1247) >> 5)) + 2123724318u)))) + _1239;
            uint _1263 = ((uint)((((int)((_1255 << 4u) + -1556008596u)) ^ ((int)(_1255 + -239350328u))) ^ (((uint)(_1255) >> 5) + -939442524))) + _1247;
            uint _1271 = ((uint)((((int)((_1263 << 4u) + -1383041155u)) ^ ((int)(_1263 + -239350328u))) ^ ((int)(((uint)((uint)(_1263) >> 5)) + 2123724318u)))) + _1255;
            uint _1279 = ((uint)((((int)((_1271 << 4u) + -1556008596u)) ^ ((int)(_1271 + -1879881855u))) ^ (((uint)(_1271) >> 5) + -939442524))) + _1263;
            uint _1287 = ((uint)((((int)((_1279 << 4u) + -1383041155u)) ^ ((int)(_1279 + -1879881855u))) ^ ((int)(((uint)((uint)(_1279) >> 5)) + 2123724318u)))) + _1271;
            uint _1295 = ((uint)((((int)((_1287 << 4u) + -1556008596u)) ^ ((int)(_1287 + 774553914u))) ^ (((uint)(_1287) >> 5) + -939442524))) + _1279;
            uint _1303 = ((uint)((((int)((_1295 << 4u) + -1383041155u)) ^ ((int)(_1295 + 774553914u))) ^ ((int)(((uint)((uint)(_1295) >> 5)) + 2123724318u)))) + _1287;
            uint _1311 = ((uint)((((int)((_1303 << 4u) + -1556008596u)) ^ ((int)(_1303 + -865977613u))) ^ (((uint)(_1303) >> 5) + -939442524))) + _1295;
            uint _1319 = ((uint)((((int)((_1311 << 4u) + -1383041155u)) ^ ((int)(_1311 + -865977613u))) ^ ((int)(((uint)((uint)(_1311) >> 5)) + 2123724318u)))) + _1303;
            uint _1327 = ((uint)((((int)((_1319 << 4u) + -1556008596u)) ^ ((int)(_1319 + 1788458156u))) ^ (((uint)(_1319) >> 5) + -939442524))) + _1311;
            uint _1335 = ((uint)((((int)((_1327 << 4u) + -1383041155u)) ^ ((int)(_1327 + 1788458156u))) ^ ((int)(((uint)((uint)(_1327) >> 5)) + 2123724318u)))) + _1319;
            uint _1343 = ((uint)((((int)((_1335 << 4u) + -1556008596u)) ^ ((int)(_1335 + 147926629u))) ^ (((uint)(_1335) >> 5) + -939442524))) + _1327;
            uint _1351 = ((uint)((((int)((_1343 << 4u) + -1383041155u)) ^ ((int)(_1343 + 147926629u))) ^ ((int)(((uint)((uint)(_1343) >> 5)) + 2123724318u)))) + _1335;
            uint _1359 = ((uint)((((int)((_1351 << 4u) + -1556008596u)) ^ ((int)(_1351 + -1492604898u))) ^ (((uint)(_1351) >> 5) + -939442524))) + _1343;
            uint _1367 = ((uint)((((int)((_1359 << 4u) + -1383041155u)) ^ ((int)(_1359 + -1492604898u))) ^ ((int)(((uint)((uint)(_1359) >> 5)) + 2123724318u)))) + _1351;
            uint _1375 = ((uint)((((int)((_1367 << 4u) + -1556008596u)) ^ ((int)(_1367 + 1161830871u))) ^ (((uint)(_1367) >> 5) + -939442524))) + _1359;
            uint _1383 = ((uint)((((int)((_1375 << 4u) + -1383041155u)) ^ ((int)(_1375 + 1161830871u))) ^ ((int)(((uint)((uint)(_1375) >> 5)) + 2123724318u)))) + _1367;
            uint _1391 = ((uint)((((int)((_1383 << 4u) + -1556008596u)) ^ ((int)(_1383 + -478700656u))) ^ (((uint)(_1383) >> 5) + -939442524))) + _1375;
            int _1393 = ((int)(_1391 << 13u)) ^ _1391;
            int _1395 = ((uint)(_1393) >> 17) ^ _1393;
            uint2 _1403 = t4.Load(int3(_21, _22, 0));
            bool _1406 = ((_1403.y & 2) != 0);
            if (_1406) {
              _1411 = CBGlobalShadowsConstants_052;
            } else {
              _1411 = 0.0f;
            }
            float _1412 = ddy_coarse(_84);
            float _1413 = ddy_coarse(_85);
            float _1414 = ddy_coarse(_86);
            float _1415 = ddx_coarse(_84);
            float _1416 = ddx_coarse(_85);
            float _1417 = ddx_coarse(_86);
            float _1420 = (_1416 * _1414) - (_1417 * _1413);
            float _1423 = (_1417 * _1412) - (_1415 * _1414);
            float _1426 = (_1415 * _1413) - (_1416 * _1412);
            float _1428 = rsqrt(dot(float3(_1420, _1423, _1426), float3(_1420, _1423, _1426)));
            float _1436 = dot(float3(_92, _93, _94), float3((-0.0f - (_1420 * _1428)), (-0.0f - (_1423 * _1428)), (-0.0f - (_1426 * _1428)))) * _1411;
            float _1440 = (_1436 * _92) + _84;
            float _1441 = (_1436 * _93) + _85;
            float _1442 = (_1436 * _94) + _86;
            float _1444 = cb12_000x - _84;
            float _1445 = cb12_000y - _85;
            float _1446 = cb12_000z - _86;
            float _1448 = rsqrt(dot(float3(_1444, _1445, _1446), float3(_1444, _1445, _1446)));
            float _1470 = select(_1406, CBGlobalShadowsConstants_008, CBGlobalShadowsConstants_004);
            float _1474 = max((CBGlobalShadowsConstants_000 * min(max((1.0f / ((cb12_021x * _30) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f)), 0.30000001192092896f) * (((2.0f - asfloat((((uint)((uint)(((int)(_1395 << 5u)) ^ _1395)) >> 9) | 1065353216))) * 0.6000000238418579f) + 0.699999988079071f);
            float _1514 = mad(cb12_016x, cb12_001w, mad(cb12_015x, cb12_001z, mad(cb12_014x, cb12_001y, (cb12_013x * cb12_001x))));
            float _1518 = mad(cb12_016x, cb12_002w, mad(cb12_015x, cb12_002z, mad(cb12_014x, cb12_002y, (cb12_013x * cb12_002x))));
            float _1522 = mad(cb12_016x, cb12_003w, mad(cb12_015x, cb12_003z, mad(cb12_014x, cb12_003y, (cb12_013x * cb12_003x))));
            float _1530 = mad(cb12_016y, cb12_001w, mad(cb12_015y, cb12_001z, mad(cb12_014y, cb12_001y, (cb12_013y * cb12_001x))));
            float _1534 = mad(cb12_016y, cb12_002w, mad(cb12_015y, cb12_002z, mad(cb12_014y, cb12_002y, (cb12_013y * cb12_002x))));
            float _1538 = mad(cb12_016y, cb12_003w, mad(cb12_015y, cb12_003z, mad(cb12_014y, cb12_003y, (cb12_013y * cb12_003x))));
            float _1546 = mad(cb12_016w, cb12_001w, mad(cb12_015w, cb12_001z, mad(cb12_014w, cb12_001y, (cb12_013w * cb12_001x))));
            float _1550 = mad(cb12_016w, cb12_002w, mad(cb12_015w, cb12_002z, mad(cb12_014w, cb12_002y, (cb12_013w * cb12_002x))));
            float _1554 = mad(cb12_016w, cb12_003w, mad(cb12_015w, cb12_003z, mad(cb12_014w, cb12_003y, (cb12_013w * cb12_003x))));
            float _1562 = mad(_1522, _1442, mad(_1518, _1441, (_1514 * _1440))) + mad(cb12_016x, cb12_004w, mad(cb12_015x, cb12_004z, mad(cb12_014x, cb12_004y, (cb12_013x * cb12_004x))));
            float _1566 = mad(_1538, _1442, mad(_1534, _1441, (_1530 * _1440))) + mad(cb12_016y, cb12_004w, mad(cb12_015y, cb12_004z, mad(cb12_014y, cb12_004y, (cb12_013y * cb12_004x))));
            float _1570 = mad(_1554, _1442, mad(_1550, _1441, (_1546 * _1440))) + mad(cb12_016w, cb12_004w, mad(cb12_015w, cb12_004z, mad(cb12_014w, cb12_004y, (cb12_013w * cb12_004x))));
            float _1571 = _1474 * cb13_000x;
            float _1572 = _1474 * cb13_000y;
            float _1573 = _1474 * cb13_000z;
            float _1576 = mad(_1522, _1573, mad(_1518, _1572, (_1514 * _1571)));
            float _1579 = mad(_1538, _1573, mad(_1534, _1572, (_1530 * _1571)));
            float _1582 = mad(_1554, _1573, mad(_1550, _1572, (_1546 * _1571)));
            float _1583 = _1470 + 2.0f;
            float _1585 = 1.0f / (_1470 + 1.0f);
            float _1589 = _1585 * 2.0f;
            float _1592 = (_1589 * _1589) + CBGlobalShadowsConstants_012;
            float _1598 = (_1592 * _1582) + _1570;
            float _1603 = ((((_1592 * _1576) + _1562) / _1598) * 0.5f) + 0.5f;
            float _1604 = 0.5f - ((((_1592 * _1579) + _1566) / _1598) * 0.5f);
            if (!(!(_1583 >= 3.0f))) {
              float _1615 = t0.Load(int3((int)(uint(cb12_023x * _1603)), (int)(uint(_1604 * cb12_023y)), 0));
              _1625 = 3.0f;
              _1626 = _1576;
              _1627 = _1579;
              _1628 = _1582;
              _1629 = min(max((1.0f / ((((_1615.x * cb12_022x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
              _1630 = _1603;
              _1631 = _1604;
              _1632 = _1598;
              _1633 = _1589;
              while(true) {
                float _1634 = _1625 * _1585;
                float _1638 = CBGlobalShadowsConstants_012 + (_1634 * _1634);
                float _1644 = (_1638 * _1628) + _1570;
                float _1649 = ((((_1638 * _1626) + _1562) / _1644) * 0.5f) + 0.5f;
                float _1650 = 0.5f - ((((_1638 * _1627) + _1566) / _1644) * 0.5f);
                float _1659 = t0.Load(int3((int)(uint(cb12_023x * _1649)), (int)(uint(_1650 * cb12_023y)), 0));
                float _1673 = min(max((1.0f / ((((cb12_022x * _1659.x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                if ((int)(_1632 < 0.0f) || ((int)(((int)(!(saturate(_1630) == _1630))) || ((int)(!(saturate(_1631) == _1631)))))) {
                  float _1682 = _1626 * 0.5f;
                  float _1683 = _1627 * 0.5f;
                  float _1684 = _1628 * 0.5f;
                  float _1686 = (_1625 + -1.0f) * _1585;
                  float _1688 = CBGlobalShadowsConstants_012 + (_1686 * _1686);
                  float _1694 = (_1688 * _1684) + _1570;
                  float _1699 = ((((_1688 * _1682) + _1562) / _1694) * 0.5f) + 0.5f;
                  float _1700 = 0.5f - ((((_1688 * _1683) + _1566) / _1694) * 0.5f);
                  float _1705 = t0.Load(int3((int)(uint(_1699 * cb12_023x)), (int)(uint(_1700 * cb12_023y)), 0));
                  _1748 = _1682;
                  _1749 = _1683;
                  _1750 = _1684;
                  _1751 = min(max((1.0f / ((((_1705.x * cb12_022x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                  _1752 = _1699;
                  _1753 = _1700;
                  _1754 = _1694;
                  _1755 = _1686;
                  float _1756 = _1625 + 1.0f;
                  if (!(!(_1756 <= _1583))) {
                    _1625 = _1756;
                    _1626 = _1748;
                    _1627 = _1749;
                    _1628 = _1750;
                    _1629 = _1751;
                    _1630 = _1752;
                    _1631 = _1753;
                    _1632 = _1754;
                    _1633 = _1755;
                    continue;
                  } else {
                    _1849 = _1100;
                  }
                } else {
                  if (_1632 > _1629) {
                    uint _1719 = uint(cb12_023x * _1630);
                    uint _1720 = uint(cb12_023y * _1631);
                    uint2 _1722 = t4.Load(int3(_1719, _1720, 0));
                    if (!((int)((_1722.y & 64) != 0) && (int)(CBGlobalShadowsConstants_072 != 0))) {
                      bool _1741 = ((_1722.y & 2) != 0);
                      if (!((abs(_1629 - _1632) / (max(_1629, _1632) + 9.999999974752427e-07f)) < (select((((int)((int)(CBGlobalShadowsConstants_028 == 0) && ((int)(!_1406)))) && _1741), CBGlobalShadowsConstants_024, (CBGlobalShadowsConstants_024 * (1.0f / max(abs(dot(float3(_92, _93, _94), float3((_1448 * _1444), (_1448 * _1445), (_1448 * _1446)))), 0.05000000074505806f)))) * ((_1633 * 0.8999999761581421f) + 0.10000000149011612f)))) {
                        _1748 = _1626;
                        _1749 = _1627;
                        _1750 = _1628;
                        _1751 = _1673;
                        _1752 = _1649;
                        _1753 = _1650;
                        _1754 = _1644;
                        _1755 = _1634;
                        float _1756 = _1625 + 1.0f;
                        if (!(!(_1756 <= _1583))) {
                          _1625 = _1756;
                          _1626 = _1748;
                          _1627 = _1749;
                          _1628 = _1750;
                          _1629 = _1751;
                          _1630 = _1752;
                          _1631 = _1753;
                          _1632 = _1754;
                          _1633 = _1755;
                          continue;
                        } else {
                          _1849 = _1100;
                        }
                      } else {
                        float4 _1761 = t2.Load(int3(_1719, _1720, 0));
                        uint _1765 = uint((_1761.w * 255.0f) + 0.5f);
                        int _1766 = _1765 & 7;
                        if (_1766 == 1) {
                          if (!((_1765 & 8) == 0)) {
                            _1783 = CBGlobalShadowsConstants_036;
                            _1784 = 1;
                          } else {
                            _1783 = select(((_1765 & 48) == 0), CBGlobalShadowsConstants_032, CBGlobalShadowsConstants_044);
                            _1784 = 1;
                          }
                        } else {
                          _1783 = select((_1766 == 3), CBGlobalShadowsConstants_040, CBGlobalShadowsConstants_032);
                          _1784 = 0;
                        }
                        if (CBGlobalShadowsConstants_068 == 0) {
                          _1794 = (((int)(uint)((int)(_1741 && (int)(CBGlobalShadowsConstants_076 != 0)))) ^ 1);
                        } else {
                          _1794 = _1784;
                        }
                        if ((int)((_97 & 71) == 65) && _107) {
                          float _1816 = mad(cb12_019w, 0.5f, 0.0f) + cb12_020w;
                          float _1820 = ((cb12_020x + mad(cb12_019x, 0.5f, 0.0f)) / _1816) - cb12_000x;
                          float _1821 = ((mad(cb12_019y, 0.5f, 0.0f) + cb12_020y) / _1816) - cb12_000y;
                          float _1822 = ((mad(cb12_019z, 0.5f, 0.0f) + cb12_020z) / _1816) - cb12_000z;
                          float _1824 = rsqrt(dot(float3(_1820, _1821, _1822), float3(_1820, _1821, _1822)));
                          _1843 = ((exp2(log2(max(saturate(1.0f - abs(1.0f - dot(float3(cb13_000x, cb13_000y, cb13_000z), float3((_1824 * _1820), (_1824 * _1821), (_1824 * _1822))))), 9.999999974752427e-07f)) * CBGlobalShadowsConstants_048) * (_1783 + -1.0f)) + 1.0f);
                        } else {
                          _1843 = _1783;
                        }
                        if (!(_1794 == 0)) {
                          _1849 = (_1843 * _1100);
                        } else {
                          _1849 = _1100;
                        }
                      }
                    } else {
                      _1748 = _1626;
                      _1749 = _1627;
                      _1750 = _1628;
                      _1751 = _1673;
                      _1752 = _1649;
                      _1753 = _1650;
                      _1754 = _1644;
                      _1755 = _1634;
                      float _1756 = _1625 + 1.0f;
                      if (!(!(_1756 <= _1583))) {
                        _1625 = _1756;
                        _1626 = _1748;
                        _1627 = _1749;
                        _1628 = _1750;
                        _1629 = _1751;
                        _1630 = _1752;
                        _1631 = _1753;
                        _1632 = _1754;
                        _1633 = _1755;
                        continue;
                      } else {
                        _1849 = _1100;
                      }
                    }
                  } else {
                    _1748 = _1626;
                    _1749 = _1627;
                    _1750 = _1628;
                    _1751 = _1673;
                    _1752 = _1649;
                    _1753 = _1650;
                    _1754 = _1644;
                    _1755 = _1634;
                    float _1756 = _1625 + 1.0f;
                    if (!(!(_1756 <= _1583))) {
                      _1625 = _1756;
                      _1626 = _1748;
                      _1627 = _1749;
                      _1628 = _1750;
                      _1629 = _1751;
                      _1630 = _1752;
                      _1631 = _1753;
                      _1632 = _1754;
                      _1633 = _1755;
                      continue;
                    } else {
                      _1849 = _1100;
                    }
                  }
                }
                break;
              }
            } else {
              _1849 = _1100;
            }
          } else {
            _1849 = _1100;
          }
        } else {
          _1849 = _1100;
        }
      } else {
        if (_1101) {
          int _1120 = (((int)(_21 << 8u)) | _21) & 16711935;
          int _1123 = ((_1120 << 4u) | _1120) & 252645135;
          int _1126 = ((_1123 << 2u) | _1123) & 858993459;
          int _1132 = (((int)(_22 << 8u)) | _22) & 16711935;
          int _1135 = ((_1132 << 4u) | _1132) & 252645135;
          int _1138 = ((_1135 << 2u) | _1135) & 858993459;
          uint _1151 = ((uint)((((int)(((uint)(CBGlobalShadowsConstants_064) << 4u) + -1556008596u)) ^ ((int)((uint)(CBGlobalShadowsConstants_064) + -1640531527u))) ^ (((uint)((uint)(CBGlobalShadowsConstants_064)) >> 5) + -939442524))) + ((uint)((((int)(((uint)((_1138 << 1u) | _1138)) << 1u)) & -1431655766) | (((_1126 << 1u) | _1126) & 1431655765)));
          uint _1159 = ((uint)((((int)((_1151 << 4u) + -1383041155u)) ^ ((int)(_1151 + -1640531527u))) ^ ((int)(((uint)((uint)(_1151) >> 5)) + 2123724318u)))) + (uint)(CBGlobalShadowsConstants_064);
          uint _1167 = ((uint)((((int)((_1159 << 4u) + -1556008596u)) ^ ((int)(_1159 + 1013904242u))) ^ (((uint)(_1159) >> 5) + -939442524))) + _1151;
          uint _1175 = ((uint)((((int)((_1167 << 4u) + -1383041155u)) ^ ((int)(_1167 + 1013904242u))) ^ ((int)(((uint)((uint)(_1167) >> 5)) + 2123724318u)))) + _1159;
          uint _1183 = ((uint)((((int)((_1175 << 4u) + -1556008596u)) ^ ((int)(_1175 + -626627285u))) ^ (((uint)(_1175) >> 5) + -939442524))) + _1167;
          uint _1191 = ((uint)((((int)((_1183 << 4u) + -1383041155u)) ^ ((int)(_1183 + -626627285u))) ^ ((int)(((uint)((uint)(_1183) >> 5)) + 2123724318u)))) + _1175;
          uint _1199 = ((uint)((((int)((_1191 << 4u) + -1556008596u)) ^ ((int)(_1191 + 2027808484u))) ^ (((uint)(_1191) >> 5) + -939442524))) + _1183;
          uint _1207 = ((uint)((((int)((_1199 << 4u) + -1383041155u)) ^ ((int)(_1199 + 2027808484u))) ^ ((int)(((uint)((uint)(_1199) >> 5)) + 2123724318u)))) + _1191;
          uint _1215 = ((uint)((((int)((_1207 << 4u) + -1556008596u)) ^ ((int)(_1207 + 387276957u))) ^ (((uint)(_1207) >> 5) + -939442524))) + _1199;
          uint _1223 = ((uint)((((int)((_1215 << 4u) + -1383041155u)) ^ ((int)(_1215 + 387276957u))) ^ ((int)(((uint)((uint)(_1215) >> 5)) + 2123724318u)))) + _1207;
          uint _1231 = ((uint)((((int)((_1223 << 4u) + -1556008596u)) ^ ((int)(_1223 + -1253254570u))) ^ (((uint)(_1223) >> 5) + -939442524))) + _1215;
          uint _1239 = ((uint)((((int)((_1231 << 4u) + -1383041155u)) ^ ((int)(_1231 + -1253254570u))) ^ ((int)(((uint)((uint)(_1231) >> 5)) + 2123724318u)))) + _1223;
          uint _1247 = ((uint)((((int)((_1239 << 4u) + -1556008596u)) ^ ((int)(_1239 + 1401181199u))) ^ (((uint)(_1239) >> 5) + -939442524))) + _1231;
          uint _1255 = ((uint)((((int)((_1247 << 4u) + -1383041155u)) ^ ((int)(_1247 + 1401181199u))) ^ ((int)(((uint)((uint)(_1247) >> 5)) + 2123724318u)))) + _1239;
          uint _1263 = ((uint)((((int)((_1255 << 4u) + -1556008596u)) ^ ((int)(_1255 + -239350328u))) ^ (((uint)(_1255) >> 5) + -939442524))) + _1247;
          uint _1271 = ((uint)((((int)((_1263 << 4u) + -1383041155u)) ^ ((int)(_1263 + -239350328u))) ^ ((int)(((uint)((uint)(_1263) >> 5)) + 2123724318u)))) + _1255;
          uint _1279 = ((uint)((((int)((_1271 << 4u) + -1556008596u)) ^ ((int)(_1271 + -1879881855u))) ^ (((uint)(_1271) >> 5) + -939442524))) + _1263;
          uint _1287 = ((uint)((((int)((_1279 << 4u) + -1383041155u)) ^ ((int)(_1279 + -1879881855u))) ^ ((int)(((uint)((uint)(_1279) >> 5)) + 2123724318u)))) + _1271;
          uint _1295 = ((uint)((((int)((_1287 << 4u) + -1556008596u)) ^ ((int)(_1287 + 774553914u))) ^ (((uint)(_1287) >> 5) + -939442524))) + _1279;
          uint _1303 = ((uint)((((int)((_1295 << 4u) + -1383041155u)) ^ ((int)(_1295 + 774553914u))) ^ ((int)(((uint)((uint)(_1295) >> 5)) + 2123724318u)))) + _1287;
          uint _1311 = ((uint)((((int)((_1303 << 4u) + -1556008596u)) ^ ((int)(_1303 + -865977613u))) ^ (((uint)(_1303) >> 5) + -939442524))) + _1295;
          uint _1319 = ((uint)((((int)((_1311 << 4u) + -1383041155u)) ^ ((int)(_1311 + -865977613u))) ^ ((int)(((uint)((uint)(_1311) >> 5)) + 2123724318u)))) + _1303;
          uint _1327 = ((uint)((((int)((_1319 << 4u) + -1556008596u)) ^ ((int)(_1319 + 1788458156u))) ^ (((uint)(_1319) >> 5) + -939442524))) + _1311;
          uint _1335 = ((uint)((((int)((_1327 << 4u) + -1383041155u)) ^ ((int)(_1327 + 1788458156u))) ^ ((int)(((uint)((uint)(_1327) >> 5)) + 2123724318u)))) + _1319;
          uint _1343 = ((uint)((((int)((_1335 << 4u) + -1556008596u)) ^ ((int)(_1335 + 147926629u))) ^ (((uint)(_1335) >> 5) + -939442524))) + _1327;
          uint _1351 = ((uint)((((int)((_1343 << 4u) + -1383041155u)) ^ ((int)(_1343 + 147926629u))) ^ ((int)(((uint)((uint)(_1343) >> 5)) + 2123724318u)))) + _1335;
          uint _1359 = ((uint)((((int)((_1351 << 4u) + -1556008596u)) ^ ((int)(_1351 + -1492604898u))) ^ (((uint)(_1351) >> 5) + -939442524))) + _1343;
          uint _1367 = ((uint)((((int)((_1359 << 4u) + -1383041155u)) ^ ((int)(_1359 + -1492604898u))) ^ ((int)(((uint)((uint)(_1359) >> 5)) + 2123724318u)))) + _1351;
          uint _1375 = ((uint)((((int)((_1367 << 4u) + -1556008596u)) ^ ((int)(_1367 + 1161830871u))) ^ (((uint)(_1367) >> 5) + -939442524))) + _1359;
          uint _1383 = ((uint)((((int)((_1375 << 4u) + -1383041155u)) ^ ((int)(_1375 + 1161830871u))) ^ ((int)(((uint)((uint)(_1375) >> 5)) + 2123724318u)))) + _1367;
          uint _1391 = ((uint)((((int)((_1383 << 4u) + -1556008596u)) ^ ((int)(_1383 + -478700656u))) ^ (((uint)(_1383) >> 5) + -939442524))) + _1375;
          int _1393 = ((int)(_1391 << 13u)) ^ _1391;
          int _1395 = ((uint)(_1393) >> 17) ^ _1393;
          uint2 _1403 = t4.Load(int3(_21, _22, 0));
          bool _1406 = ((_1403.y & 2) != 0);
          if (_1406) {
            _1411 = CBGlobalShadowsConstants_052;
          } else {
            _1411 = 0.0f;
          }
          float _1412 = ddy_coarse(_84);
          float _1413 = ddy_coarse(_85);
          float _1414 = ddy_coarse(_86);
          float _1415 = ddx_coarse(_84);
          float _1416 = ddx_coarse(_85);
          float _1417 = ddx_coarse(_86);
          float _1420 = (_1416 * _1414) - (_1417 * _1413);
          float _1423 = (_1417 * _1412) - (_1415 * _1414);
          float _1426 = (_1415 * _1413) - (_1416 * _1412);
          float _1428 = rsqrt(dot(float3(_1420, _1423, _1426), float3(_1420, _1423, _1426)));
          float _1436 = dot(float3(_92, _93, _94), float3((-0.0f - (_1420 * _1428)), (-0.0f - (_1423 * _1428)), (-0.0f - (_1426 * _1428)))) * _1411;
          float _1440 = (_1436 * _92) + _84;
          float _1441 = (_1436 * _93) + _85;
          float _1442 = (_1436 * _94) + _86;
          float _1444 = cb12_000x - _84;
          float _1445 = cb12_000y - _85;
          float _1446 = cb12_000z - _86;
          float _1448 = rsqrt(dot(float3(_1444, _1445, _1446), float3(_1444, _1445, _1446)));
          float _1470 = select(_1406, CBGlobalShadowsConstants_008, CBGlobalShadowsConstants_004);
          float _1474 = max((CBGlobalShadowsConstants_000 * min(max((1.0f / ((cb12_021x * _30) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f)), 0.30000001192092896f) * (((2.0f - asfloat((((uint)((uint)(((int)(_1395 << 5u)) ^ _1395)) >> 9) | 1065353216))) * 0.6000000238418579f) + 0.699999988079071f);
          float _1514 = mad(cb12_016x, cb12_001w, mad(cb12_015x, cb12_001z, mad(cb12_014x, cb12_001y, (cb12_013x * cb12_001x))));
          float _1518 = mad(cb12_016x, cb12_002w, mad(cb12_015x, cb12_002z, mad(cb12_014x, cb12_002y, (cb12_013x * cb12_002x))));
          float _1522 = mad(cb12_016x, cb12_003w, mad(cb12_015x, cb12_003z, mad(cb12_014x, cb12_003y, (cb12_013x * cb12_003x))));
          float _1530 = mad(cb12_016y, cb12_001w, mad(cb12_015y, cb12_001z, mad(cb12_014y, cb12_001y, (cb12_013y * cb12_001x))));
          float _1534 = mad(cb12_016y, cb12_002w, mad(cb12_015y, cb12_002z, mad(cb12_014y, cb12_002y, (cb12_013y * cb12_002x))));
          float _1538 = mad(cb12_016y, cb12_003w, mad(cb12_015y, cb12_003z, mad(cb12_014y, cb12_003y, (cb12_013y * cb12_003x))));
          float _1546 = mad(cb12_016w, cb12_001w, mad(cb12_015w, cb12_001z, mad(cb12_014w, cb12_001y, (cb12_013w * cb12_001x))));
          float _1550 = mad(cb12_016w, cb12_002w, mad(cb12_015w, cb12_002z, mad(cb12_014w, cb12_002y, (cb12_013w * cb12_002x))));
          float _1554 = mad(cb12_016w, cb12_003w, mad(cb12_015w, cb12_003z, mad(cb12_014w, cb12_003y, (cb12_013w * cb12_003x))));
          float _1562 = mad(_1522, _1442, mad(_1518, _1441, (_1514 * _1440))) + mad(cb12_016x, cb12_004w, mad(cb12_015x, cb12_004z, mad(cb12_014x, cb12_004y, (cb12_013x * cb12_004x))));
          float _1566 = mad(_1538, _1442, mad(_1534, _1441, (_1530 * _1440))) + mad(cb12_016y, cb12_004w, mad(cb12_015y, cb12_004z, mad(cb12_014y, cb12_004y, (cb12_013y * cb12_004x))));
          float _1570 = mad(_1554, _1442, mad(_1550, _1441, (_1546 * _1440))) + mad(cb12_016w, cb12_004w, mad(cb12_015w, cb12_004z, mad(cb12_014w, cb12_004y, (cb12_013w * cb12_004x))));
          float _1571 = _1474 * cb13_000x;
          float _1572 = _1474 * cb13_000y;
          float _1573 = _1474 * cb13_000z;
          float _1576 = mad(_1522, _1573, mad(_1518, _1572, (_1514 * _1571)));
          float _1579 = mad(_1538, _1573, mad(_1534, _1572, (_1530 * _1571)));
          float _1582 = mad(_1554, _1573, mad(_1550, _1572, (_1546 * _1571)));
          float _1583 = _1470 + 2.0f;
          float _1585 = 1.0f / (_1470 + 1.0f);
          float _1589 = _1585 * 2.0f;
          float _1592 = (_1589 * _1589) + CBGlobalShadowsConstants_012;
          float _1598 = (_1592 * _1582) + _1570;
          float _1603 = ((((_1592 * _1576) + _1562) / _1598) * 0.5f) + 0.5f;
          float _1604 = 0.5f - ((((_1592 * _1579) + _1566) / _1598) * 0.5f);
          if (!(!(_1583 >= 3.0f))) {
            float _1615 = t0.Load(int3((int)(uint(cb12_023x * _1603)), (int)(uint(_1604 * cb12_023y)), 0));
            _1625 = 3.0f;
            _1626 = _1576;
            _1627 = _1579;
            _1628 = _1582;
            _1629 = min(max((1.0f / ((((_1615.x * cb12_022x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
            _1630 = _1603;
            _1631 = _1604;
            _1632 = _1598;
            _1633 = _1589;
            while(true) {
              float _1634 = _1625 * _1585;
              float _1638 = CBGlobalShadowsConstants_012 + (_1634 * _1634);
              float _1644 = (_1638 * _1628) + _1570;
              float _1649 = ((((_1638 * _1626) + _1562) / _1644) * 0.5f) + 0.5f;
              float _1650 = 0.5f - ((((_1638 * _1627) + _1566) / _1644) * 0.5f);
              float _1659 = t0.Load(int3((int)(uint(cb12_023x * _1649)), (int)(uint(_1650 * cb12_023y)), 0));
              float _1673 = min(max((1.0f / ((((cb12_022x * _1659.x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
              if ((int)(_1632 < 0.0f) || ((int)(((int)(!(saturate(_1630) == _1630))) || ((int)(!(saturate(_1631) == _1631)))))) {
                float _1682 = _1626 * 0.5f;
                float _1683 = _1627 * 0.5f;
                float _1684 = _1628 * 0.5f;
                float _1686 = (_1625 + -1.0f) * _1585;
                float _1688 = CBGlobalShadowsConstants_012 + (_1686 * _1686);
                float _1694 = (_1688 * _1684) + _1570;
                float _1699 = ((((_1688 * _1682) + _1562) / _1694) * 0.5f) + 0.5f;
                float _1700 = 0.5f - ((((_1688 * _1683) + _1566) / _1694) * 0.5f);
                float _1705 = t0.Load(int3((int)(uint(_1699 * cb12_023x)), (int)(uint(_1700 * cb12_023y)), 0));
                _1748 = _1682;
                _1749 = _1683;
                _1750 = _1684;
                _1751 = min(max((1.0f / ((((_1705.x * cb12_022x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                _1752 = _1699;
                _1753 = _1700;
                _1754 = _1694;
                _1755 = _1686;
                float _1756 = _1625 + 1.0f;
                if (!(!(_1756 <= _1583))) {
                  _1625 = _1756;
                  _1626 = _1748;
                  _1627 = _1749;
                  _1628 = _1750;
                  _1629 = _1751;
                  _1630 = _1752;
                  _1631 = _1753;
                  _1632 = _1754;
                  _1633 = _1755;
                  continue;
                } else {
                  _1849 = _1100;
                }
              } else {
                if (_1632 > _1629) {
                  uint _1719 = uint(cb12_023x * _1630);
                  uint _1720 = uint(cb12_023y * _1631);
                  uint2 _1722 = t4.Load(int3(_1719, _1720, 0));
                  if (!((int)((_1722.y & 64) != 0) && (int)(CBGlobalShadowsConstants_072 != 0))) {
                    bool _1741 = ((_1722.y & 2) != 0);
                    if (!((abs(_1629 - _1632) / (max(_1629, _1632) + 9.999999974752427e-07f)) < (select((((int)((int)(CBGlobalShadowsConstants_028 == 0) && ((int)(!_1406)))) && _1741), CBGlobalShadowsConstants_024, (CBGlobalShadowsConstants_024 * (1.0f / max(abs(dot(float3(_92, _93, _94), float3((_1448 * _1444), (_1448 * _1445), (_1448 * _1446)))), 0.05000000074505806f)))) * ((_1633 * 0.8999999761581421f) + 0.10000000149011612f)))) {
                      _1748 = _1626;
                      _1749 = _1627;
                      _1750 = _1628;
                      _1751 = _1673;
                      _1752 = _1649;
                      _1753 = _1650;
                      _1754 = _1644;
                      _1755 = _1634;
                      float _1756 = _1625 + 1.0f;
                      if (!(!(_1756 <= _1583))) {
                        _1625 = _1756;
                        _1626 = _1748;
                        _1627 = _1749;
                        _1628 = _1750;
                        _1629 = _1751;
                        _1630 = _1752;
                        _1631 = _1753;
                        _1632 = _1754;
                        _1633 = _1755;
                        continue;
                      } else {
                        _1849 = _1100;
                      }
                    } else {
                      float4 _1761 = t2.Load(int3(_1719, _1720, 0));
                      uint _1765 = uint((_1761.w * 255.0f) + 0.5f);
                      int _1766 = _1765 & 7;
                      if (_1766 == 1) {
                        if (!((_1765 & 8) == 0)) {
                          _1783 = CBGlobalShadowsConstants_036;
                          _1784 = 1;
                        } else {
                          _1783 = select(((_1765 & 48) == 0), CBGlobalShadowsConstants_032, CBGlobalShadowsConstants_044);
                          _1784 = 1;
                        }
                      } else {
                        _1783 = select((_1766 == 3), CBGlobalShadowsConstants_040, CBGlobalShadowsConstants_032);
                        _1784 = 0;
                      }
                      if (CBGlobalShadowsConstants_068 == 0) {
                        _1794 = (((int)(uint)((int)(_1741 && (int)(CBGlobalShadowsConstants_076 != 0)))) ^ 1);
                      } else {
                        _1794 = _1784;
                      }
                      if ((int)((_97 & 71) == 65) && _107) {
                        float _1816 = mad(cb12_019w, 0.5f, 0.0f) + cb12_020w;
                        float _1820 = ((cb12_020x + mad(cb12_019x, 0.5f, 0.0f)) / _1816) - cb12_000x;
                        float _1821 = ((mad(cb12_019y, 0.5f, 0.0f) + cb12_020y) / _1816) - cb12_000y;
                        float _1822 = ((mad(cb12_019z, 0.5f, 0.0f) + cb12_020z) / _1816) - cb12_000z;
                        float _1824 = rsqrt(dot(float3(_1820, _1821, _1822), float3(_1820, _1821, _1822)));
                        _1843 = ((exp2(log2(max(saturate(1.0f - abs(1.0f - dot(float3(cb13_000x, cb13_000y, cb13_000z), float3((_1824 * _1820), (_1824 * _1821), (_1824 * _1822))))), 9.999999974752427e-07f)) * CBGlobalShadowsConstants_048) * (_1783 + -1.0f)) + 1.0f);
                      } else {
                        _1843 = _1783;
                      }
                      if (!(_1794 == 0)) {
                        _1849 = (_1843 * _1100);
                      } else {
                        _1849 = _1100;
                      }
                    }
                  } else {
                    _1748 = _1626;
                    _1749 = _1627;
                    _1750 = _1628;
                    _1751 = _1673;
                    _1752 = _1649;
                    _1753 = _1650;
                    _1754 = _1644;
                    _1755 = _1634;
                    float _1756 = _1625 + 1.0f;
                    if (!(!(_1756 <= _1583))) {
                      _1625 = _1756;
                      _1626 = _1748;
                      _1627 = _1749;
                      _1628 = _1750;
                      _1629 = _1751;
                      _1630 = _1752;
                      _1631 = _1753;
                      _1632 = _1754;
                      _1633 = _1755;
                      continue;
                    } else {
                      _1849 = _1100;
                    }
                  }
                } else {
                  _1748 = _1626;
                  _1749 = _1627;
                  _1750 = _1628;
                  _1751 = _1673;
                  _1752 = _1649;
                  _1753 = _1650;
                  _1754 = _1644;
                  _1755 = _1634;
                  float _1756 = _1625 + 1.0f;
                  if (!(!(_1756 <= _1583))) {
                    _1625 = _1756;
                    _1626 = _1748;
                    _1627 = _1749;
                    _1628 = _1750;
                    _1629 = _1751;
                    _1630 = _1752;
                    _1631 = _1753;
                    _1632 = _1754;
                    _1633 = _1755;
                    continue;
                  } else {
                    _1849 = _1100;
                  }
                }
              }
              break;
            }
          } else {
            _1849 = _1100;
          }
        } else {
          _1849 = _1100;
        }
      }
    } else {
      if (_1101) {
        int _1120 = (((int)(_21 << 8u)) | _21) & 16711935;
        int _1123 = ((_1120 << 4u) | _1120) & 252645135;
        int _1126 = ((_1123 << 2u) | _1123) & 858993459;
        int _1132 = (((int)(_22 << 8u)) | _22) & 16711935;
        int _1135 = ((_1132 << 4u) | _1132) & 252645135;
        int _1138 = ((_1135 << 2u) | _1135) & 858993459;
        uint _1151 = ((uint)((((int)(((uint)(CBGlobalShadowsConstants_064) << 4u) + -1556008596u)) ^ ((int)((uint)(CBGlobalShadowsConstants_064) + -1640531527u))) ^ (((uint)((uint)(CBGlobalShadowsConstants_064)) >> 5) + -939442524))) + ((uint)((((int)(((uint)((_1138 << 1u) | _1138)) << 1u)) & -1431655766) | (((_1126 << 1u) | _1126) & 1431655765)));
        uint _1159 = ((uint)((((int)((_1151 << 4u) + -1383041155u)) ^ ((int)(_1151 + -1640531527u))) ^ ((int)(((uint)((uint)(_1151) >> 5)) + 2123724318u)))) + (uint)(CBGlobalShadowsConstants_064);
        uint _1167 = ((uint)((((int)((_1159 << 4u) + -1556008596u)) ^ ((int)(_1159 + 1013904242u))) ^ (((uint)(_1159) >> 5) + -939442524))) + _1151;
        uint _1175 = ((uint)((((int)((_1167 << 4u) + -1383041155u)) ^ ((int)(_1167 + 1013904242u))) ^ ((int)(((uint)((uint)(_1167) >> 5)) + 2123724318u)))) + _1159;
        uint _1183 = ((uint)((((int)((_1175 << 4u) + -1556008596u)) ^ ((int)(_1175 + -626627285u))) ^ (((uint)(_1175) >> 5) + -939442524))) + _1167;
        uint _1191 = ((uint)((((int)((_1183 << 4u) + -1383041155u)) ^ ((int)(_1183 + -626627285u))) ^ ((int)(((uint)((uint)(_1183) >> 5)) + 2123724318u)))) + _1175;
        uint _1199 = ((uint)((((int)((_1191 << 4u) + -1556008596u)) ^ ((int)(_1191 + 2027808484u))) ^ (((uint)(_1191) >> 5) + -939442524))) + _1183;
        uint _1207 = ((uint)((((int)((_1199 << 4u) + -1383041155u)) ^ ((int)(_1199 + 2027808484u))) ^ ((int)(((uint)((uint)(_1199) >> 5)) + 2123724318u)))) + _1191;
        uint _1215 = ((uint)((((int)((_1207 << 4u) + -1556008596u)) ^ ((int)(_1207 + 387276957u))) ^ (((uint)(_1207) >> 5) + -939442524))) + _1199;
        uint _1223 = ((uint)((((int)((_1215 << 4u) + -1383041155u)) ^ ((int)(_1215 + 387276957u))) ^ ((int)(((uint)((uint)(_1215) >> 5)) + 2123724318u)))) + _1207;
        uint _1231 = ((uint)((((int)((_1223 << 4u) + -1556008596u)) ^ ((int)(_1223 + -1253254570u))) ^ (((uint)(_1223) >> 5) + -939442524))) + _1215;
        uint _1239 = ((uint)((((int)((_1231 << 4u) + -1383041155u)) ^ ((int)(_1231 + -1253254570u))) ^ ((int)(((uint)((uint)(_1231) >> 5)) + 2123724318u)))) + _1223;
        uint _1247 = ((uint)((((int)((_1239 << 4u) + -1556008596u)) ^ ((int)(_1239 + 1401181199u))) ^ (((uint)(_1239) >> 5) + -939442524))) + _1231;
        uint _1255 = ((uint)((((int)((_1247 << 4u) + -1383041155u)) ^ ((int)(_1247 + 1401181199u))) ^ ((int)(((uint)((uint)(_1247) >> 5)) + 2123724318u)))) + _1239;
        uint _1263 = ((uint)((((int)((_1255 << 4u) + -1556008596u)) ^ ((int)(_1255 + -239350328u))) ^ (((uint)(_1255) >> 5) + -939442524))) + _1247;
        uint _1271 = ((uint)((((int)((_1263 << 4u) + -1383041155u)) ^ ((int)(_1263 + -239350328u))) ^ ((int)(((uint)((uint)(_1263) >> 5)) + 2123724318u)))) + _1255;
        uint _1279 = ((uint)((((int)((_1271 << 4u) + -1556008596u)) ^ ((int)(_1271 + -1879881855u))) ^ (((uint)(_1271) >> 5) + -939442524))) + _1263;
        uint _1287 = ((uint)((((int)((_1279 << 4u) + -1383041155u)) ^ ((int)(_1279 + -1879881855u))) ^ ((int)(((uint)((uint)(_1279) >> 5)) + 2123724318u)))) + _1271;
        uint _1295 = ((uint)((((int)((_1287 << 4u) + -1556008596u)) ^ ((int)(_1287 + 774553914u))) ^ (((uint)(_1287) >> 5) + -939442524))) + _1279;
        uint _1303 = ((uint)((((int)((_1295 << 4u) + -1383041155u)) ^ ((int)(_1295 + 774553914u))) ^ ((int)(((uint)((uint)(_1295) >> 5)) + 2123724318u)))) + _1287;
        uint _1311 = ((uint)((((int)((_1303 << 4u) + -1556008596u)) ^ ((int)(_1303 + -865977613u))) ^ (((uint)(_1303) >> 5) + -939442524))) + _1295;
        uint _1319 = ((uint)((((int)((_1311 << 4u) + -1383041155u)) ^ ((int)(_1311 + -865977613u))) ^ ((int)(((uint)((uint)(_1311) >> 5)) + 2123724318u)))) + _1303;
        uint _1327 = ((uint)((((int)((_1319 << 4u) + -1556008596u)) ^ ((int)(_1319 + 1788458156u))) ^ (((uint)(_1319) >> 5) + -939442524))) + _1311;
        uint _1335 = ((uint)((((int)((_1327 << 4u) + -1383041155u)) ^ ((int)(_1327 + 1788458156u))) ^ ((int)(((uint)((uint)(_1327) >> 5)) + 2123724318u)))) + _1319;
        uint _1343 = ((uint)((((int)((_1335 << 4u) + -1556008596u)) ^ ((int)(_1335 + 147926629u))) ^ (((uint)(_1335) >> 5) + -939442524))) + _1327;
        uint _1351 = ((uint)((((int)((_1343 << 4u) + -1383041155u)) ^ ((int)(_1343 + 147926629u))) ^ ((int)(((uint)((uint)(_1343) >> 5)) + 2123724318u)))) + _1335;
        uint _1359 = ((uint)((((int)((_1351 << 4u) + -1556008596u)) ^ ((int)(_1351 + -1492604898u))) ^ (((uint)(_1351) >> 5) + -939442524))) + _1343;
        uint _1367 = ((uint)((((int)((_1359 << 4u) + -1383041155u)) ^ ((int)(_1359 + -1492604898u))) ^ ((int)(((uint)((uint)(_1359) >> 5)) + 2123724318u)))) + _1351;
        uint _1375 = ((uint)((((int)((_1367 << 4u) + -1556008596u)) ^ ((int)(_1367 + 1161830871u))) ^ (((uint)(_1367) >> 5) + -939442524))) + _1359;
        uint _1383 = ((uint)((((int)((_1375 << 4u) + -1383041155u)) ^ ((int)(_1375 + 1161830871u))) ^ ((int)(((uint)((uint)(_1375) >> 5)) + 2123724318u)))) + _1367;
        uint _1391 = ((uint)((((int)((_1383 << 4u) + -1556008596u)) ^ ((int)(_1383 + -478700656u))) ^ (((uint)(_1383) >> 5) + -939442524))) + _1375;
        int _1393 = ((int)(_1391 << 13u)) ^ _1391;
        int _1395 = ((uint)(_1393) >> 17) ^ _1393;
        uint2 _1403 = t4.Load(int3(_21, _22, 0));
        bool _1406 = ((_1403.y & 2) != 0);
        if (_1406) {
          _1411 = CBGlobalShadowsConstants_052;
        } else {
          _1411 = 0.0f;
        }
        float _1412 = ddy_coarse(_84);
        float _1413 = ddy_coarse(_85);
        float _1414 = ddy_coarse(_86);
        float _1415 = ddx_coarse(_84);
        float _1416 = ddx_coarse(_85);
        float _1417 = ddx_coarse(_86);
        float _1420 = (_1416 * _1414) - (_1417 * _1413);
        float _1423 = (_1417 * _1412) - (_1415 * _1414);
        float _1426 = (_1415 * _1413) - (_1416 * _1412);
        float _1428 = rsqrt(dot(float3(_1420, _1423, _1426), float3(_1420, _1423, _1426)));
        float _1436 = dot(float3(_92, _93, _94), float3((-0.0f - (_1420 * _1428)), (-0.0f - (_1423 * _1428)), (-0.0f - (_1426 * _1428)))) * _1411;
        float _1440 = (_1436 * _92) + _84;
        float _1441 = (_1436 * _93) + _85;
        float _1442 = (_1436 * _94) + _86;
        float _1444 = cb12_000x - _84;
        float _1445 = cb12_000y - _85;
        float _1446 = cb12_000z - _86;
        float _1448 = rsqrt(dot(float3(_1444, _1445, _1446), float3(_1444, _1445, _1446)));
        float _1470 = select(_1406, CBGlobalShadowsConstants_008, CBGlobalShadowsConstants_004);
        float _1474 = max((CBGlobalShadowsConstants_000 * min(max((1.0f / ((cb12_021x * _30) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f)), 0.30000001192092896f) * (((2.0f - asfloat((((uint)((uint)(((int)(_1395 << 5u)) ^ _1395)) >> 9) | 1065353216))) * 0.6000000238418579f) + 0.699999988079071f);
        float _1514 = mad(cb12_016x, cb12_001w, mad(cb12_015x, cb12_001z, mad(cb12_014x, cb12_001y, (cb12_013x * cb12_001x))));
        float _1518 = mad(cb12_016x, cb12_002w, mad(cb12_015x, cb12_002z, mad(cb12_014x, cb12_002y, (cb12_013x * cb12_002x))));
        float _1522 = mad(cb12_016x, cb12_003w, mad(cb12_015x, cb12_003z, mad(cb12_014x, cb12_003y, (cb12_013x * cb12_003x))));
        float _1530 = mad(cb12_016y, cb12_001w, mad(cb12_015y, cb12_001z, mad(cb12_014y, cb12_001y, (cb12_013y * cb12_001x))));
        float _1534 = mad(cb12_016y, cb12_002w, mad(cb12_015y, cb12_002z, mad(cb12_014y, cb12_002y, (cb12_013y * cb12_002x))));
        float _1538 = mad(cb12_016y, cb12_003w, mad(cb12_015y, cb12_003z, mad(cb12_014y, cb12_003y, (cb12_013y * cb12_003x))));
        float _1546 = mad(cb12_016w, cb12_001w, mad(cb12_015w, cb12_001z, mad(cb12_014w, cb12_001y, (cb12_013w * cb12_001x))));
        float _1550 = mad(cb12_016w, cb12_002w, mad(cb12_015w, cb12_002z, mad(cb12_014w, cb12_002y, (cb12_013w * cb12_002x))));
        float _1554 = mad(cb12_016w, cb12_003w, mad(cb12_015w, cb12_003z, mad(cb12_014w, cb12_003y, (cb12_013w * cb12_003x))));
        float _1562 = mad(_1522, _1442, mad(_1518, _1441, (_1514 * _1440))) + mad(cb12_016x, cb12_004w, mad(cb12_015x, cb12_004z, mad(cb12_014x, cb12_004y, (cb12_013x * cb12_004x))));
        float _1566 = mad(_1538, _1442, mad(_1534, _1441, (_1530 * _1440))) + mad(cb12_016y, cb12_004w, mad(cb12_015y, cb12_004z, mad(cb12_014y, cb12_004y, (cb12_013y * cb12_004x))));
        float _1570 = mad(_1554, _1442, mad(_1550, _1441, (_1546 * _1440))) + mad(cb12_016w, cb12_004w, mad(cb12_015w, cb12_004z, mad(cb12_014w, cb12_004y, (cb12_013w * cb12_004x))));
        float _1571 = _1474 * cb13_000x;
        float _1572 = _1474 * cb13_000y;
        float _1573 = _1474 * cb13_000z;
        float _1576 = mad(_1522, _1573, mad(_1518, _1572, (_1514 * _1571)));
        float _1579 = mad(_1538, _1573, mad(_1534, _1572, (_1530 * _1571)));
        float _1582 = mad(_1554, _1573, mad(_1550, _1572, (_1546 * _1571)));
        float _1583 = _1470 + 2.0f;
        float _1585 = 1.0f / (_1470 + 1.0f);
        float _1589 = _1585 * 2.0f;
        float _1592 = (_1589 * _1589) + CBGlobalShadowsConstants_012;
        float _1598 = (_1592 * _1582) + _1570;
        float _1603 = ((((_1592 * _1576) + _1562) / _1598) * 0.5f) + 0.5f;
        float _1604 = 0.5f - ((((_1592 * _1579) + _1566) / _1598) * 0.5f);
        if (!(!(_1583 >= 3.0f))) {
          float _1615 = t0.Load(int3((int)(uint(cb12_023x * _1603)), (int)(uint(_1604 * cb12_023y)), 0));
          _1625 = 3.0f;
          _1626 = _1576;
          _1627 = _1579;
          _1628 = _1582;
          _1629 = min(max((1.0f / ((((_1615.x * cb12_022x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
          _1630 = _1603;
          _1631 = _1604;
          _1632 = _1598;
          _1633 = _1589;
          while(true) {
            float _1634 = _1625 * _1585;
            float _1638 = CBGlobalShadowsConstants_012 + (_1634 * _1634);
            float _1644 = (_1638 * _1628) + _1570;
            float _1649 = ((((_1638 * _1626) + _1562) / _1644) * 0.5f) + 0.5f;
            float _1650 = 0.5f - ((((_1638 * _1627) + _1566) / _1644) * 0.5f);
            float _1659 = t0.Load(int3((int)(uint(cb12_023x * _1649)), (int)(uint(_1650 * cb12_023y)), 0));
            float _1673 = min(max((1.0f / ((((cb12_022x * _1659.x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
            if ((int)(_1632 < 0.0f) || ((int)(((int)(!(saturate(_1630) == _1630))) || ((int)(!(saturate(_1631) == _1631)))))) {
              float _1682 = _1626 * 0.5f;
              float _1683 = _1627 * 0.5f;
              float _1684 = _1628 * 0.5f;
              float _1686 = (_1625 + -1.0f) * _1585;
              float _1688 = CBGlobalShadowsConstants_012 + (_1686 * _1686);
              float _1694 = (_1688 * _1684) + _1570;
              float _1699 = ((((_1688 * _1682) + _1562) / _1694) * 0.5f) + 0.5f;
              float _1700 = 0.5f - ((((_1688 * _1683) + _1566) / _1694) * 0.5f);
              float _1705 = t0.Load(int3((int)(uint(_1699 * cb12_023x)), (int)(uint(_1700 * cb12_023y)), 0));
              _1748 = _1682;
              _1749 = _1683;
              _1750 = _1684;
              _1751 = min(max((1.0f / ((((_1705.x * cb12_022x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
              _1752 = _1699;
              _1753 = _1700;
              _1754 = _1694;
              _1755 = _1686;
              float _1756 = _1625 + 1.0f;
              if (!(!(_1756 <= _1583))) {
                _1625 = _1756;
                _1626 = _1748;
                _1627 = _1749;
                _1628 = _1750;
                _1629 = _1751;
                _1630 = _1752;
                _1631 = _1753;
                _1632 = _1754;
                _1633 = _1755;
                continue;
              } else {
                _1849 = _1100;
              }
            } else {
              if (_1632 > _1629) {
                uint _1719 = uint(cb12_023x * _1630);
                uint _1720 = uint(cb12_023y * _1631);
                uint2 _1722 = t4.Load(int3(_1719, _1720, 0));
                if (!((int)((_1722.y & 64) != 0) && (int)(CBGlobalShadowsConstants_072 != 0))) {
                  bool _1741 = ((_1722.y & 2) != 0);
                  if (!((abs(_1629 - _1632) / (max(_1629, _1632) + 9.999999974752427e-07f)) < (select((((int)((int)(CBGlobalShadowsConstants_028 == 0) && ((int)(!_1406)))) && _1741), CBGlobalShadowsConstants_024, (CBGlobalShadowsConstants_024 * (1.0f / max(abs(dot(float3(_92, _93, _94), float3((_1448 * _1444), (_1448 * _1445), (_1448 * _1446)))), 0.05000000074505806f)))) * ((_1633 * 0.8999999761581421f) + 0.10000000149011612f)))) {
                    _1748 = _1626;
                    _1749 = _1627;
                    _1750 = _1628;
                    _1751 = _1673;
                    _1752 = _1649;
                    _1753 = _1650;
                    _1754 = _1644;
                    _1755 = _1634;
                    float _1756 = _1625 + 1.0f;
                    if (!(!(_1756 <= _1583))) {
                      _1625 = _1756;
                      _1626 = _1748;
                      _1627 = _1749;
                      _1628 = _1750;
                      _1629 = _1751;
                      _1630 = _1752;
                      _1631 = _1753;
                      _1632 = _1754;
                      _1633 = _1755;
                      continue;
                    } else {
                      _1849 = _1100;
                    }
                  } else {
                    float4 _1761 = t2.Load(int3(_1719, _1720, 0));
                    uint _1765 = uint((_1761.w * 255.0f) + 0.5f);
                    int _1766 = _1765 & 7;
                    if (_1766 == 1) {
                      if (!((_1765 & 8) == 0)) {
                        _1783 = CBGlobalShadowsConstants_036;
                        _1784 = 1;
                      } else {
                        _1783 = select(((_1765 & 48) == 0), CBGlobalShadowsConstants_032, CBGlobalShadowsConstants_044);
                        _1784 = 1;
                      }
                    } else {
                      _1783 = select((_1766 == 3), CBGlobalShadowsConstants_040, CBGlobalShadowsConstants_032);
                      _1784 = 0;
                    }
                    if (CBGlobalShadowsConstants_068 == 0) {
                      _1794 = (((int)(uint)((int)(_1741 && (int)(CBGlobalShadowsConstants_076 != 0)))) ^ 1);
                    } else {
                      _1794 = _1784;
                    }
                    if ((int)((_97 & 71) == 65) && _107) {
                      float _1816 = mad(cb12_019w, 0.5f, 0.0f) + cb12_020w;
                      float _1820 = ((cb12_020x + mad(cb12_019x, 0.5f, 0.0f)) / _1816) - cb12_000x;
                      float _1821 = ((mad(cb12_019y, 0.5f, 0.0f) + cb12_020y) / _1816) - cb12_000y;
                      float _1822 = ((mad(cb12_019z, 0.5f, 0.0f) + cb12_020z) / _1816) - cb12_000z;
                      float _1824 = rsqrt(dot(float3(_1820, _1821, _1822), float3(_1820, _1821, _1822)));
                      _1843 = ((exp2(log2(max(saturate(1.0f - abs(1.0f - dot(float3(cb13_000x, cb13_000y, cb13_000z), float3((_1824 * _1820), (_1824 * _1821), (_1824 * _1822))))), 9.999999974752427e-07f)) * CBGlobalShadowsConstants_048) * (_1783 + -1.0f)) + 1.0f);
                    } else {
                      _1843 = _1783;
                    }
                    if (!(_1794 == 0)) {
                      _1849 = (_1843 * _1100);
                    } else {
                      _1849 = _1100;
                    }
                  }
                } else {
                  _1748 = _1626;
                  _1749 = _1627;
                  _1750 = _1628;
                  _1751 = _1673;
                  _1752 = _1649;
                  _1753 = _1650;
                  _1754 = _1644;
                  _1755 = _1634;
                  float _1756 = _1625 + 1.0f;
                  if (!(!(_1756 <= _1583))) {
                    _1625 = _1756;
                    _1626 = _1748;
                    _1627 = _1749;
                    _1628 = _1750;
                    _1629 = _1751;
                    _1630 = _1752;
                    _1631 = _1753;
                    _1632 = _1754;
                    _1633 = _1755;
                    continue;
                  } else {
                    _1849 = _1100;
                  }
                }
              } else {
                _1748 = _1626;
                _1749 = _1627;
                _1750 = _1628;
                _1751 = _1673;
                _1752 = _1649;
                _1753 = _1650;
                _1754 = _1644;
                _1755 = _1634;
                float _1756 = _1625 + 1.0f;
                if (!(!(_1756 <= _1583))) {
                  _1625 = _1756;
                  _1626 = _1748;
                  _1627 = _1749;
                  _1628 = _1750;
                  _1629 = _1751;
                  _1630 = _1752;
                  _1631 = _1753;
                  _1632 = _1754;
                  _1633 = _1755;
                  continue;
                } else {
                  _1849 = _1100;
                }
              }
            }
            break;
          }
        } else {
          _1849 = _1100;
        }
      } else {
        _1849 = _1100;
      }
    }
  } else {
    _1849 = select(((int)(CBGlobalShadowsConstants_060 != 0) && _31), 0.0f, 1.0f);
  }
  SV_Target.x = _1849;
  SV_Target.y = _1849;
  SV_Target.z = _1849;
  SV_Target.w = _1849;
  return SV_Target;
}
