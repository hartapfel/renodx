// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "shared.h"
#include "lighting/brdf.hlsli"
#include "lighting/contact/sample.hlsli"
#include "water/receiver.hlsli"
#define GRAPHICS_PBR (graphics_injection.layout_version == 1.f && graphics_injection.graphics_mode != 0.f && graphics_injection.pbr_mode != 0.f)
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


Texture2D<float4> t43 : register(t43);

StructuredBuffer<LightParams> t18 : register(t18);

Texture2DArray<float> t9 : register(t9);

TextureCubeArray<float> t10 : register(t10);

Texture2DArray<float4> t42 : register(t42);

Texture2DArray<uint> t17 : register(t17);

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
  float cb12_000x : packoffset(c000.x);
  float cb12_000y : packoffset(c000.y);
  float cb12_000z : packoffset(c000.z);
  float cb12_009x : packoffset(c009.x);
  float cb12_009y : packoffset(c009.y);
  float cb12_009z : packoffset(c009.z);
  float cb12_010x : packoffset(c010.x);
  float cb12_010y : packoffset(c010.y);
  float cb12_010z : packoffset(c010.z);
  float cb12_011x : packoffset(c011.x);
  float cb12_011y : packoffset(c011.y);
  float cb12_011z : packoffset(c011.z);
  float cb12_012x : packoffset(c012.x);
  float cb12_012y : packoffset(c012.y);
  float cb12_012z : packoffset(c012.z);
  float cb12_013x : packoffset(c013.x);
  float cb12_014y : packoffset(c014.y);
  float cb12_021x : packoffset(c021.x);
  float cb12_021y : packoffset(c021.y);
  float cb12_022x : packoffset(c022.x);
  float cb12_022y : packoffset(c022.y);
  float cb12_023x : packoffset(c023.x);
  float cb12_023y : packoffset(c023.y);
  float cb12_024x : packoffset(c024.x);
  float cb12_036x : packoffset(c036.x);
  float cb12_036y : packoffset(c036.y);
  float cb12_036z : packoffset(c036.z);
  float cb12_036w : packoffset(c036.w);
  float cb12_037y : packoffset(c037.y);
  float cb12_037z : packoffset(c037.z);
  float cb12_069x : packoffset(c069.x);
  float cb12_069y : packoffset(c069.y);
  float cb12_069z : packoffset(c069.z);
  float cb12_071x : packoffset(c071.x);
  float cb12_071y : packoffset(c071.y);
  float cb12_071z : packoffset(c071.z);
  float cb12_074x : packoffset(c074.x);
  float cb12_184z : packoffset(c184.z);
  float cb12_184w : packoffset(c184.w);
  float cb12_187x : packoffset(c187.x);
  float cb12_188x : packoffset(c188.x);
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
  float cb12_219x : packoffset(c219.x);
  float cb12_219y : packoffset(c219.y);
  float cb12_219z : packoffset(c219.z);
  float cb12_219w : packoffset(c219.w);
  float cb12_221x : packoffset(c221.x);
  float cb12_221y : packoffset(c221.y);
  float cb12_221z : packoffset(c221.z);
  float cb12_223x : packoffset(c223.x);
  float cb12_223y : packoffset(c223.y);
  float cb12_223z : packoffset(c223.z);
  float cb12_223w : packoffset(c223.w);
  float cb12_224x : packoffset(c224.x);
  float cb12_224y : packoffset(c224.y);
  float cb12_224z : packoffset(c224.z);
  float cb12_224w : packoffset(c224.w);
  float cb12_225y : packoffset(c225.y);
  float cb12_225z : packoffset(c225.z);
  float cb12_287w : packoffset(c287.w);
  float cb12_288z : packoffset(c288.z);
  float cb12_288w : packoffset(c288.w);
  uint cb12_padding : packoffset(c340.w);
};

cbuffer cb13 : register(b13) {
  float cb13_000x : packoffset(c000.x);
  float cb13_000y : packoffset(c000.y);
  float cb13_000z : packoffset(c000.z);
  float cb13_001x : packoffset(c001.x);
  float cb13_001y : packoffset(c001.y);
  float cb13_001z : packoffset(c001.z);
  float cb13_002x : packoffset(c002.x);
  float cb13_002y : packoffset(c002.y);
  float cb13_061x : packoffset(c061.x);
  float cb13_061y : packoffset(c061.y);
  float cb13_061z : packoffset(c061.z);
  float cb13_062x : packoffset(c062.x);
  float cb13_062y : packoffset(c062.y);
  float cb13_062z : packoffset(c062.z);
  float cb13_066x : packoffset(c066.x);
  float cb13_066z : packoffset(c066.z);
  float cb13_067x : packoffset(c067.x);
  int cb13_067y : packoffset(c067.y);
  uint cb13_padding : packoffset(c3588.w);
};

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
  float _28[4];
  int _31 = int(CSCustomConstants_000.x);
  uint _44 = SV_GroupThreadID.x + (SV_GroupID.x << 4u);
  uint _45 = SV_GroupThreadID.y + (SV_GroupID.y << 4u);
  uint _47 = (SV_GroupThreadID.y << 4u) + SV_GroupThreadID.x;
  float _49 = t0.Load(int3(_44, _45, 0));
  float _55 = (cb12_022x * _49.x) + cb12_022y;
  int _215;
  int _245;
  bool _246;
  bool _247;
  int _280;
  int _296;
  int _297;
  float _377;
  float _382;
  float _383;
  float _384;
  bool _496;
  bool _497;
  bool _498;
  bool _511;
  float _555;
  float _556;
  float _557;
  int _597;
  float _598;
  float _599;
  float _600;
  float _601;
  float _602;
  float _603;
  float _604;
  float _605;
  float _606;
  float _641;
  float _642;
  float _643;
  float _683;
  float _684;
  float _685;
  int _701;
  float _723;
  float _724;
  float _823;
  float _897;
  float _898;
  float _899;
  float _980;
  float _981;
  float _982;
  float _1023;
  float _1024;
  float _1025;
  float _1093;
  float _1094;
  float _1095;
  float _1202;
  float _1203;
  float _1204;
  float _1260;
  float _1315;
  float _1316;
  float _1317;
  float _1322;
  float _1323;
  float _1324;
  float _1373;
  float _1374;
  float _1375;
  float _1383;
  float _1384;
  float _1385;
  float _1386;
  float _1387;
  float _1388;
  float _1395;
  int _1412;
  int _1418;
  int _1424;
  int _1430;
  int _1436;
  int _1442;
  int _1448;
  int _1454;
  int _1455;
  int _1456;
  int _1457;
  int _1458;
  int _1459;
  int _1460;
  int _1461;
  int _1462;
  float _1468;
  float _1469;
  float _1470;
  float _1471;
  float _1472;
  float _1473;
  float _1501;
  float _1502;
  float _1503;
  float _1504;
  float _1505;
  float _1506;
  int _1507;
  int _1559;
  float _1565;
  bool _1566;
  float _1627;
  float _1633;
  float _1741;
  float _1742;
  float _1743;
  float _1744;
  float _1835;
  float _1836;
  float _1837;
  float _1838;
  float _1843;
  float _1844;
  float _1845;
  float _1846;
  int _1847;
  float _1892;
  int _1905;
  int _1906;
  float _1945;
  float _1946;
  float _1947;
  float _1952;
  float _1953;
  float _1954;
  float _1956;
  float _1957;
  float _1958;
  float _1959;
  float _1976;
  float _1979;
  float _1980;
  float _1992;
  float _2001;
  float _2123;
  float _2197;
  float _2198;
  float _2199;
  float _2280;
  float _2281;
  float _2282;
  float _2323;
  float _2324;
  float _2325;
  float _2395;
  float _2396;
  float _2397;
  float _2463;
  float _2464;
  float _2465;
  float _2521;
  float _2576;
  float _2577;
  float _2578;
  float _2583;
  float _2584;
  float _2585;
  float _2633;
  float _2634;
  float _2635;
  float _2646;
  float _2647;
  float _2648;
  float _2649;
  float _2650;
  float _2651;
  float _2658;
  float _2669;
  int _2683;
  float _2684;
  float _2685;
  float _2686;
  float _2687;
  float _2688;
  float _2689;
  float _2696;
  float _2697;
  float _2698;
  int _2730;
  if (_47 == 0) {
    _global_3 = 0;
    _global_5 = 0;
    _global_0 = 2139095039;
    _global_1 = 0;
  }
  GroupMemoryBarrierWithGroupSync();
  int _60 = asint(_55);
  uint _61; InterlockedMin(_global_0, _60, _61);
  uint _62; InterlockedMax(_global_1, _60, _62);
  GroupMemoryBarrierWithGroupSync();
  float _72 = min(max((1.0f / ((cb12_021x * asfloat(_global_0)) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
  float _82 = min(max((1.0f / ((cb12_021x * asfloat(_global_1)) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
  float _86 = cb12_023x * 0.03125f;
  float _87 = cb12_023y * 0.03125f;
  float _88 = float((uint)SV_GroupID.x);
  float _89 = float((uint)SV_GroupID.y);
  float _90 = _86 - _88;
  float _91 = _87 - _89;
  float _94 = cb12_013x * _86;
  float _97 = cb12_014y * _87;
  float _100 = 1.0f - _90;
  float _101 = _90 + 1.0f;
  float _102 = 1.0f - _91;
  float _103 = _91 + 1.0f;
  float _104 = _94 * _94;
  float _107 = sqrt((_100 * _100) + _104);
  float _108 = (-0.0f - _94) / _107;
  float _109 = _100 / _107;
  float _112 = sqrt((_101 * _101) + _104);
  float _113 = _94 / _112;
  float _114 = _101 / _112;
  float _115 = _97 * _97;
  float _118 = sqrt(_115 + (_102 * _102));
  float _119 = _97 / _118;
  float _120 = _102 / _118;
  float _123 = sqrt(_115 + (_103 * _103));
  float _124 = (-0.0f - _97) / _123;
  float _125 = _103 / _123;
  float _143 = cb12_012x + mad(cb12_010x, -0.0f, 0.0f);
  float _145 = mad(cb12_010y, -0.0f, 0.0f) + cb12_012y;
  float _147 = mad(cb12_010z, -0.0f, 0.0f) + cb12_012z;
  float _149 = mad(cb12_011x, _109, (cb12_009x * _108));
  float _151 = mad(cb12_011y, _109, (cb12_009y * _108));
  float _153 = mad(cb12_011z, _109, (cb12_009z * _108));
  float _155 = -0.0f - dot(float3(_149, _151, _153), float3(_143, _145, _147));
  float _157 = mad(cb12_011x, _114, (cb12_009x * _113));
  float _159 = mad(cb12_011y, _114, (cb12_009y * _113));
  float _161 = mad(cb12_011z, _114, (cb12_009z * _113));
  float _163 = -0.0f - dot(float3(_157, _159, _161), float3(_143, _145, _147));
  float _165 = mad(cb12_011x, _120, mad(cb12_010x, _119, 0.0f));
  float _167 = mad(cb12_011y, _120, mad(cb12_010y, _119, 0.0f));
  float _169 = mad(cb12_011z, _120, mad(cb12_010z, _119, 0.0f));
  float _171 = -0.0f - dot(float3(_165, _167, _169), float3(cb12_012x, cb12_012y, cb12_012z));
  float _173 = mad(cb12_011x, _125, mad(cb12_010x, _124, 0.0f));
  float _175 = mad(cb12_011y, _125, mad(cb12_010y, _124, 0.0f));
  float _177 = mad(cb12_011z, _125, mad(cb12_010z, _124, 0.0f));
  float _179 = -0.0f - dot(float3(_173, _175, _177), float3(cb12_012x, cb12_012y, cb12_012z));
  float _180 = mad(cb12_010x, -0.0f, -0.0f);
  float _183 = mad(cb12_010y, -0.0f, -0.0f);
  float _186 = mad(cb12_010z, -0.0f, -0.0f);
  float _189 = mad(cb12_011x, -1.0f, 0.0f);
  float _190 = mad(cb12_011y, -1.0f, 0.0f);
  float _191 = mad(cb12_011z, -1.0f, 0.0f);
  float _193 = -0.0f - dot(float3(_189, _190, _191), float3((mad(cb12_011x, _82, _180) + cb12_012x), (mad(cb12_011y, _82, _183) + cb12_012y), (mad(cb12_011z, _82, _186) + cb12_012z)));
  float _201 = -0.0f - dot(float3(cb12_011x, cb12_011y, cb12_011z), float3((mad(cb12_011x, _72, _180) + cb12_012x), (mad(cb12_011y, _72, _183) + cb12_012y), (mad(cb12_011z, _72, _186) + cb12_012z)));
  float _209 = -0.0f - dot(float3(cb12_011x, cb12_011y, cb12_011z), float3((mad(cb12_011x, -0.0f, _180) + cb12_012x), (mad(cb12_011y, -0.0f, _183) + cb12_012y), (mad(cb12_011z, -0.0f, _186) + cb12_012z)));
  if ((uint)_47 < (uint)cb13_067y) {
    _215 = _47;
    while(true) {
      float _218 = t18[_215].LightParams_000.x;
      float _219 = t18[_215].LightParams_000.y;
      float _220 = t18[_215].LightParams_000.z;
      float _221 = t18[_215].LightParams_000.w;
      float _228 = -0.0f - _221;
      if (((int)(((int)(((int)((int)(dot(float4(_149, _151, _153, _155), float4(_218, _219, _220, 1.0f)) >= _228) && (int)(dot(float4(_157, _159, _161, _163), float4(_218, _219, _220, 1.0f)) >= _228))) && (int)(dot(float4(_165, _167, _169, _171), float4(_218, _219, _220, 1.0f)) >= _228))) && (int)(dot(float4(_173, _175, _177, _179), float4(_218, _219, _220, 1.0f)) >= _228))) && (int)(dot(float4(_189, _190, _191, _193), float4(_218, _219, _220, 1.0f)) >= _228)) {
        bool _240 = (dot(float4(cb12_011x, cb12_011y, cb12_011z, _209), float4(_218, _219, _220, 1.0f)) >= _228);
        int _241 = (int)(uint)(_240);
        if (_240) {
          _245 = _241;
          _246 = true;
          _247 = (dot(float4(cb12_011x, cb12_011y, cb12_011z, _201), float4(_218, _219, _220, 1.0f)) >= _228);
        } else {
          _245 = _241;
          _246 = false;
          _247 = false;
        }
      } else {
        _245 = 0;
        _246 = false;
        _247 = false;
      }
      int _248 = (int)(uint)(_247);
      float _250 = t18[_215].LightParams_048.w;
      if (!(!(_250 >= 0.800000011920929f))) {
        float _254 = t18[_215].LightParams_016.x;
        float _255 = t18[_215].LightParams_016.y;
        float _256 = t18[_215].LightParams_016.z;
        float _257 = t18[_215].LightParams_016.w;
        float _258 = dot(float4(_149, _151, _153, _155), float4(_254, _255, _256, 1.0f));
        float _259 = dot(float4(_157, _159, _161, _163), float4(_254, _255, _256, 1.0f));
        float _260 = dot(float4(_165, _167, _169, _171), float4(_254, _255, _256, 1.0f));
        float _261 = dot(float4(_173, _175, _177, _179), float4(_254, _255, _256, 1.0f));
        float _262 = dot(float4(_189, _190, _191, _193), float4(_254, _255, _256, 1.0f));
        if (_247) {
          float _266 = -0.0f - _257;
          _280 = ((int)(uint)((int)(((int)(((int)(((int)(((int)((int)(_258 >= _266) && (int)(_259 >= _266))) && (int)(_260 >= _266))) && (int)(_261 >= _266))) && (int)(_262 >= _266))) && (int)(dot(float4(cb12_011x, cb12_011y, cb12_011z, _201), float4(_254, _255, _256, 1.0f)) >= _266))));
        } else {
          _280 = _248;
        }
        if (_246) {
          float _282 = -0.0f - _257;
          _296 = ((int)(uint)((int)(((int)(((int)(((int)(((int)((int)(_258 >= _282) && (int)(_259 >= _282))) && (int)(_260 >= _282))) && (int)(_261 >= _282))) && (int)(_262 >= _282))) && (int)(dot(float4(cb12_011x, cb12_011y, cb12_011z, _209), float4(_254, _255, _256, 1.0f)) >= _282))));
          _297 = _280;
        } else {
          _296 = _245;
          _297 = _280;
        }
      } else {
        _296 = _245;
        _297 = _248;
      }
      if (!(_296 == 0)) {
        int _300; InterlockedAdd(_global_5, 1, _300);
        if ((uint)_300 < (uint)256) {
          _global_4[_300] = _215;
        }
        if (!(_297 == 0)) {
          int _307; InterlockedAdd(_global_3, 1, _307);
          if ((uint)_307 < (uint)256) {
            _global_2[_307] = _215;
          }
        }
      }
      uint _312 = _215 + 256u;
      if ((uint)_312 < (uint)cb13_067y) {
        _215 = _312;
        continue;
      }
      break;
    }
  }
  GroupMemoryBarrierWithGroupSync();
  float4 _319 = t1.Load(int3(_44, _45, 0));
  float _329 = (pow(_319.x, 2.200000047683716f));
  float _330 = (pow(_319.y, 2.200000047683716f));
  float _331 = (pow(_319.z, 2.200000047683716f));
  float _343 = select((cb12_225z <= 0.040449999272823334f), (cb12_225z * 0.07739938050508499f), exp2(log2(abs((cb12_225z + 0.054999999701976776f) * 0.9478673338890076f)) * 2.4000000953674316f));
  float _344 = dot(float3(_329, _330, _331), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  if (!(_344 <= 0.0f)) {
    if (!((int)(_343 <= 0.0f) || (int)(_344 >= _343))) {
      float _352 = saturate(_344 / _343);
      float _359 = saturate(_352);
      float _369 = ((((1.0f - ((_359 * _359) * (3.0f - (_359 * 2.0f)))) * (exp2(log2(_352) * (1.0f / (max(cb12_225y, 0.0f) + 1.0f))) - _352)) + _352) * _343) / _344;
      float _371 = max(_329, max(_330, _331));
      if (_371 > 0.0f) {
        _377 = min(_369, (1.0f / _371));
      } else {
        _377 = _369;
      }
      _382 = (_377 * _329);
      _383 = (_377 * _330);
      _384 = (_377 * _331);
    } else {
      _382 = _329;
      _383 = _330;
      _384 = _331;
    }
  } else {
    _382 = 0.0f;
    _383 = 0.0f;
    _384 = 0.0f;
  }
  [branch]
  if (!(_55 >= 1.0f)) {
    float4 _388 = t2.Load(int3(_44, _45, 0));
    float direct_roughness = GRAPHICS_PBR ? GraphicsDirectRoughness(t0, t2, int2(_44, _45), _388,
        uint2(cb12_023x, cb12_023y), float2(cb12_022x, cb12_022y), float2(cb12_021x, cb12_021y)) : _388.w;
    float _393 = _388.x + -0.5f;
    float _394 = _388.y + -0.5f;
    float _395 = _388.z + -0.5f;
    float _397 = rsqrt(dot(float3(_393, _394, _395), float3(_393, _394, _395)));
    float _398 = _393 * _397;
    float _399 = _394 * _397;
    float _400 = _395 * _397;
    float _401 = float((uint)_44);
    float _402 = float((uint)_45);
    float _438 = mad(cb12_213w, _49.x, mad(cb12_212w, _402, (cb12_211w * _401))) + cb12_214w;
    float _439 = (mad(cb12_213x, _49.x, mad(cb12_212x, _402, (cb12_211x * _401))) + cb12_214x) / _438;
    float _440 = (mad(cb12_213y, _49.x, mad(cb12_212y, _402, (cb12_211y * _401))) + cb12_214y) / _438;
    float _441 = (mad(cb12_213z, _49.x, mad(cb12_212z, _402, (cb12_211z * _401))) + cb12_214z) / _438;
    GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
        float3(_439, _440, _441), float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
    float _446 = cb12_000x - _439;
    float _447 = cb12_000y - _440;
    float _448 = cb12_000z - _441;
    float _450 = rsqrt(dot(float3(_446, _447, _448), float3(_446, _447, _448)));
    float _451 = _446 * _450;
    float _452 = _447 * _450;
    float _453 = _448 * _450;
    float _459 = sqrt(((_446 * _446) + (_447 * _447)) + (_448 * _448));
    float4 _469 = t4.Load(int3(_44, _45, 0));
    uint _476 = uint((_469.w * 255.0f) + 0.5f);
    int _477 = _476 & 7;
    float _484 = (pow(_469.x, 2.200000047683716f));
    float _485 = (pow(_469.y, 2.200000047683716f));
    float _486 = (pow(_469.z, 2.200000047683716f));
    if (_477 == 1) {
      _496 = ((_476 & 64) != 0);
      _497 = ((_476 & 8) != 0);
      _498 = ((_476 & 48) != 0);
    } else {
      _496 = false;
      _497 = false;
      _498 = false;
    }
    uint2 _500 = t3.Load(int3(_44, _45, 0));
    bool _503 = ((_500.y & 64) != 0);
    int _504 = _500.y & 2;
    bool _505 = (_504 != 0);
    if (_503) {
      _511 = (CSCustomConstants_016.y == 1.0f);
    } else {
      _511 = false;
    }
    int _513 = ((int)(uint)(_511)) | int(CSCustomConstants_016.x);
    if ((int)(_319.w > 0.0f) && _497) {
      int _517 = select((CSCustomConstants_000.z > 0.0f), 2, _31);
      if (((int)((int)(CSCustomConstants_032.x > 0.0f) || (int)(CSCustomConstants_032.y > 0.0f))) || (int)(CSCustomConstants_032.z > 0.0f)) {
        float _534 = (CSCustomConstants_080.x * _439) + CSCustomConstants_080.y;
        float _535 = (CSCustomConstants_080.x * _440) + CSCustomConstants_080.z;
        [branch]
        if ((int)(abs(_534 + -0.5f) < 0.5f) && (int)(abs(_535 + -0.5f) < 0.5f)) {
          float2 _547 = t11.SampleLevel(s4, float3(_534, _535, CSCustomConstants_080.w), 0.0f);
          _555 = _547.x;
          _556 = _547.y;
          _557 = sqrt(1.0f - saturate(dot(float2(_547.x, _547.y), float2(_547.x, _547.y))));
        } else {
          _555 = 0.0f;
          _556 = 0.0f;
          _557 = 1.0f;
        }
        float _558 = _555 - _398;
        float _559 = _556 - _399;
        float _560 = _557 - _400;
        float _564 = (_558 * CSCustomConstants_032.x) + _398;
        float _565 = (_559 * CSCustomConstants_032.x) + _399;
        float _566 = (_560 * CSCustomConstants_032.x) + _400;
        float _568 = rsqrt(dot(float3(_564, _565, _566), float3(_564, _565, _566)));
        float _576 = (_558 * CSCustomConstants_032.y) + _398;
        float _577 = (_559 * CSCustomConstants_032.y) + _399;
        float _578 = (_560 * CSCustomConstants_032.y) + _400;
        float _580 = rsqrt(dot(float3(_576, _577, _578), float3(_576, _577, _578)));
        float _588 = (_558 * CSCustomConstants_032.z) + _398;
        float _589 = (_559 * CSCustomConstants_032.z) + _399;
        float _590 = (_560 * CSCustomConstants_032.z) + _400;
        float _592 = rsqrt(dot(float3(_588, _589, _590), float3(_588, _589, _590)));
        _597 = _517;
        _598 = (_568 * _564);
        _599 = (_565 * _568);
        _600 = (_566 * _568);
        _601 = (_580 * _576);
        _602 = (_580 * _577);
        _603 = (_580 * _578);
        _604 = (_592 * _588);
        _605 = (_592 * _589);
        _606 = (_592 * _590);
      } else {
        _597 = _517;
        _598 = _398;
        _599 = _399;
        _600 = _400;
        _601 = _398;
        _602 = _399;
        _603 = _400;
        _604 = _398;
        _605 = _399;
        _606 = _400;
      }
    } else {
      _597 = _31;
      _598 = _398;
      _599 = _399;
      _600 = _400;
      _601 = _398;
      _602 = _399;
      _603 = _400;
      _604 = _398;
      _605 = _399;
      _606 = _400;
    }
    if (_503) {
      _641 = CSCustomConstants_096.y;
      _642 = CSCustomConstants_096.x;
      _643 = _319.w;
    } else {
      if (_505) {
        _641 = cb12_224w;
        _642 = cb12_224z;
        _643 = (float((bool)(uint)(CSCustomConstants_016.w == 0.0f)) * _319.w);
      } else {
        if (_497) {
          _641 = CSCustomConstants_096.w;
          _642 = CSCustomConstants_096.z;
          _643 = _319.w;
        } else {
          if (_498) {
            _641 = CSCustomConstants_112.y;
            _642 = CSCustomConstants_112.x;
            _643 = _319.w;
          } else {
            if (_496) {
              _641 = CSCustomConstants_112.w;
              _642 = CSCustomConstants_112.z;
              _643 = _319.w;
            } else {
              _641 = cb12_224y;
              _642 = cb12_224x;
              _643 = _319.w;
            }
          }
        }
      }
    }
    if (_477 == 3) {
      if ((int)(CSCustomConstants_000.w > 0.0f) && (int)((_476 & 8) != 0)) {
        float4 _651 = u0.Load(int2(_44, _45));
        if (CSCustomConstants_160.x > 0.0f) {
          float4 _661 = t16.Load(int3(_44, _45, 0));
          float _663 = saturate(_661.z);
          float _675 = ((CSCustomConstants_176.y - CSCustomConstants_176.w) * _663) + CSCustomConstants_176.w;
          float _678 = (((lerp(CSCustomConstants_176.z, CSCustomConstants_176.x, _663)) - _675) * saturate(_651.w)) + _675;
          _683 = (_678 * _651.x);
          _684 = (_678 * _651.y);
          _685 = (_678 * _651.z);
        } else {
          _683 = _651.x;
          _684 = _651.y;
          _685 = _651.z;
        }
        u0[int2(_44, _45)] = float4(_683, _684, _685, 1.0f);
        if ((uint)_47 < (uint)256) {
          if ((uint)_47 < (uint)_global_5) {
            _701 = (_global_4[_47]);
          } else {
            _701 = 256;
          }
          u2.Store(((int)(((uint((cb12_024x * _89) + _88) << 8u) + _47) << 2u)), asuint(_701));
        }
      } else {
        float4 _706 = t16.Load(int3(_44, _45, 0));
        // Supplement the completed native directional visibility, including
        // traced shadows. Never brighten an existing shadow or alter AO/local lights.
        if (graphics_injection.layout_version == 1.f && graphics_injection.graphics_mode != 0.f
            && graphics_injection.contact_shadows != 0.f)
          _706.y = min(_706.y, GraphicsContactVisibility(uint2(_44, _45), uint2(cb12_023x, cb12_023y)));
        float _709 = select(_503, CSCustomConstants_064.z, CSCustomConstants_048.z);
        if (_706.y > 0.0f) {
          if ((_476 & 71) == 65) {
            _723 = cb13_002x;
            _724 = cb13_002y;
          } else {
            _723 = 1.0f;
            _724 = 0.0f;
          }
          float _725 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_598, _599, _600));
          [branch]
          if (((_724 + _643) + saturate(_725)) > 0.0f) {
            bool _731 = (_597 == 0);
            [branch]
            if (GRAPHICS_PBR && _597 != 2) {
              // Preserve native albedo/normalization, then retain the original
              // Fresnel complement, transmission, visibility and light units.
              float3 diffuse_response = GraphicsDiffuseResponse(float3(_598, _599, _600), float3(_451, _452, _453),
                  float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), direct_roughness, float3(_382, _383, _384), _597, saturate(saturate(dot(float3(_598, _599, _600), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z))) * _723 + _724));
              _897 = diffuse_response.x; _898 = diffuse_response.y; _899 = diffuse_response.z;
            } else if (_731) {
              float _737 = saturate((saturate(dot(float3(_598, _599, _600), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z))) * _723) + _724);
              _897 = _737;
              _898 = _737;
              _899 = _737;
            } else {
              if (_597 == 2) {
                float _750 = saturate(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_451, _452, _453)) + 0.5f) * exp2(log2(abs(_725)) * cb12_037y);
                _897 = (_750 * _382);
                _898 = (_750 * _383);
                _899 = (_750 * _384);
              } else {
                int _757 = ((int)(uint)((int)(_600 > 0.0f))) << 1u;
                float _759 = float((int)(_757 + -1));
                float _761 = -1.0f / (_759 + _600);
                float _763 = (_599 * _598) * _761;
                float _767 = (((_598 * _598) * _759) * _761) + 1.0f;
                float _768 = _763 * _759;
                float _771 = float((int)(1 - _757)) * _598;
                float _774 = ((_599 * _599) * _761) + _759;
                float _775 = -0.0f - _599;
                float _777 = rsqrt(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
                float _778 = _777 * water_light.sun.x;
                float _779 = _777 * water_light.sun.y;
                float _780 = _777 * water_light.sun.z;
                float _783 = mad(_771, _780, mad(_768, _779, (_778 * _767)));
                float _786 = mad(_775, _780, mad(_774, _779, (_778 * _763)));
                float _789 = mad(_600, _780, mad(_599, _779, (_778 * _598)));
                float _791 = rsqrt(dot(float3(_783, _786, _789), float3(_783, _786, _789)));
                float _794 = _791 * _789;
                float _796 = rsqrt(dot(float3(_451, _452, _453), float3(_451, _452, _453)));
                float _797 = _796 * _451;
                float _798 = _796 * _452;
                float _799 = _796 * _453;
                float _802 = mad(_771, _799, mad(_768, _798, (_797 * _767)));
                float _805 = mad(_775, _799, mad(_774, _798, (_797 * _763)));
                float _808 = mad(_600, _799, mad(_599, _798, (_797 * _598)));
                float _810 = rsqrt(dot(float3(_802, _805, _808), float3(_802, _805, _808)));
                float _813 = _810 * _808;
                float _814 = _388.w * _388.w;
                float _817 = dot(float3((_791 * _783), (_791 * _786), _794), float3((_810 * _802), (_810 * _805), _813)) - (_813 * _794);
                if (_817 > 0.0f) {
                  _823 = (_817 / max(_794, _813));
                } else {
                  _823 = _817;
                }
                float _825 = (_814 * 0.2877933979034424f) + 1.0f;
                float _826 = 1.0f / _825;
                float _830 = ((_823 * _814) + 1.0f) * (_826 * 0.31830987334251404f);
                float _834 = 1.0f - _813;
                float _845 = 1.0f - _794;
                float _858 = _826 * ((_814 * 0.07248824834823608f) + 1.0f);
                float _865 = 1.0f - _858;
                float _880 = max(1.0000000116860974e-07f, (1.0f - ((((_845 * _814) * ((((((_845 * 0.07144299894571304f) + -0.332181453704834f) * _845) + 0.4918818771839142f) * _845) + 0.05710852891206741f)) + 1.0f) / _825))) * (max(1.0000000116860974e-07f, (1.0f - ((((_834 * _814) * ((((((_834 * 0.07144299894571304f) + -0.332181453704834f) * _834) + 0.4918818771839142f) * _834) + 0.05710852891206741f)) + 1.0f) / _825))) * 0.31830987334251404f);
                float _884 = max(1.0000000116860974e-07f, _865);
                float _892 = saturate(dot(float3(_598, _599, _600), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
                _897 = (_892 * (((_880 * (((_382 * _382) * _858) / (1.0f - (_865 * _382)))) / _884) + (_830 * _382)));
                _898 = (_892 * (((_880 * (((_383 * _383) * _858) / (1.0f - (_865 * _383)))) / _884) + (_830 * _383)));
                _899 = (_892 * (((_880 * (((_384 * _384) * _858) / (1.0f - (_865 * _384)))) / _884) + (_830 * _384)));
              }
            }
            float _903 = 1.0f - _484;
            float _904 = 1.0f - _485;
            float _905 = 1.0f - _486;
            if (cb12_221x > 0.0f) {
              float4 _910 = t43.SampleLevel(s10, float2(_388.w, dot(float3(_598, _599, _600), float3(_451, _452, _453))), 0.0f);
              float _916 = (_910.x * _484) + _910.y;
              float _917 = (_910.x * _485) + _910.y;
              float _918 = (_910.x * _486) + _910.y;
              _980 = min((_916 / max((1.0f - ((1.0f - _916) * ((_903 * 0.0476190485060215f) + _484))), 0.0010000000474974513f)), 1.0f);
              _981 = min((_917 / max((1.0f - ((1.0f - _917) * ((_904 * 0.0476190485060215f) + _485))), 0.0010000000474974513f)), 1.0f);
              _982 = min((_918 / max((1.0f - ((1.0f - _918) * ((_905 * 0.0476190485060215f) + _486))), 0.0010000000474974513f)), 1.0f);
            } else {
              float _944 = water_light.sun.x + _451;
              float _945 = water_light.sun.y + _452;
              float _946 = water_light.sun.z + _453;
              float _948 = rsqrt(dot(float3(_944, _945, _946), float3(_944, _945, _946)));
              float _955 = saturate(1.0f - abs(dot(float3((_948 * _944), (_948 * _945), (_948 * _946)), float3(_451, _452, _453))));
              float _956 = _955 * _955;
              float _966 = ((_956 * _956) * _955) * cb13_066x;
              float _972 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _388.w));
              _980 = (((_966 * max(0.0f, _903)) / _972) + _484);
              _981 = (((_966 * max(0.0f, _904)) / _972) + _485);
              _982 = (((_966 * max(0.0f, _905)) / _972) + _486);
            }
            float _986 = (1.0f - _980) * _897;
            float _987 = (1.0f - _981) * _898;
            float _988 = (1.0f - _982) * _899;
            bool _990 = ((_597 & -3) == 0);
            float _994 = select(_990, (_986 * 0.31830987334251404f), _986);
            float _995 = select(_990, (_987 * 0.31830987334251404f), _987);
            float _996 = select(_990, (_988 * 0.31830987334251404f), _988);

            [branch]
            if (_643 > 0.0f) {
              if (!(cb12_037z == 0.0f)) {
                float _1008 = dot(float3(_382, _383, _384), float3(0.21250000596046448f, 0.715399980545044f, 0.07209999859333038f));
                if (!_731) {
                  _1023 = saturate(lerp(_1008, _382, cb12_036w));
                  _1024 = saturate(lerp(_1008, _383, cb12_036w));
                  _1025 = saturate(lerp(_1008, _384, cb12_036w));
                } else {
                  _1023 = 1.0f;
                  _1024 = 1.0f;
                  _1025 = 1.0f;
                }
                float _1026 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_451, _452, _453));
                float _1040 = ((_643 * 0.31830987334251404f) * exp2(log2(abs(_725)) * cb12_036z)) * (exp2((_1026 + cb12_036y) * -4.328084945678711f) + exp2((_1026 + cb12_036x) * -1.4426950216293335f));
                _1093 = ((_1040 * _1023) + _994);
                _1094 = ((_1040 * _1024) + _995);
                _1095 = ((_1040 * _1025) + _996);
              } else {
                float _1049 = (_725 + 1.0f) * 0.5f;
                float _1050 = -0.0f - _451;
                float _1051 = -0.0f - _452;
                float _1052 = -0.0f - _453;
                float _1055 = (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_1050, _1051, _1052)) + 1.0f) * 0.5f;
                float _1058 = _1055 * _1055;
                float _1060 = select(_731, 1.0f, _382);
                float _1061 = select(_731, 1.0f, _383);
                float _1062 = select(_731, 1.0f, _384);
                float _1072 = cb12_036y * _643;
                float _1085 = (((_643 * 0.5f) * cb12_036w) * (dot(float3(_598, _599, _600), float3(_1050, _1051, _1052)) + 1.0f)) * ((((_1058 * _1058) - _1049) * cb12_036x) + _1049);
                _1093 = ((((((_1060 * _903) * cb12_036z) - _994) * _1072) + _994) + (_1085 * _1060));
                _1094 = ((((((_1061 * _904) * cb12_036z) - _995) * _1072) + _995) + (_1085 * _1061));
                _1095 = ((((((_1062 * _905) * cb12_036z) - _996) * _1072) + _996) + (_1085 * _1062));
              }
            } else {
              _1093 = _994;
              _1094 = _995;
              _1095 = _996;
            }
            float _1096 = _439 - cb12_000x;
            float _1097 = _440 - cb12_000y;
            float _1107 = saturate((cb12_219z * _441) + cb12_219w);
            float _1129 = saturate((cb12_219x * sqrt((_1096 * _1096) + (_1097 * _1097))) + cb12_219y);
            float _1143 = ((((lerp(cb13_062x, cb13_061x, _1107)) - cb13_001x) * _1129) + cb13_001x) * _706.y * water_light.direct.x;
            float _1145 = ((((lerp(cb13_062y, cb13_061y, _1107)) - cb13_001y) * _1129) + cb13_001y) * _706.y * water_light.direct.y;
            float _1147 = ((((lerp(cb13_062z, cb13_061z, _1107)) - cb13_001z) * _1129) + cb13_001z) * _706.y * water_light.direct.z;
            [branch]
            if (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_601, _602, _603)) > 0.0f) {
              float _1152 = water_light.sun.x + _451;
              float _1153 = water_light.sun.y + _452;
              float _1154 = water_light.sun.z + _453;
              float _1156 = rsqrt(dot(float3(_1152, _1153, _1154), float3(_1152, _1153, _1154)));
              float _1157 = _1156 * _1152;
              float _1158 = _1156 * _1153;
              float _1159 = _1156 * _1154;
              float _1161 = dot(float3(_601, _602, _603), float3(_451, _452, _453));
              float _1163 = saturate(dot(float3(_601, _602, _603), float3(_1157, _1158, _1159)));
              float _1164 = saturate(dot(float3(_601, _602, _603), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
              float _1165 = direct_roughness * direct_roughness;
              float _1166 = _1165 * _1165;
              float _1170 = ((_1163 * _1163) * (_1166 + -1.0f)) + 1.0f;
              float _1174 = abs(_1161);
              float _1175 = CSCustomConstants_048.y - CSCustomConstants_048.x;
              float _1181 = saturate(select((_1175 == 0.0f), 1e+05f, (1.0f / _1175)) * (_459 - CSCustomConstants_048.x));
              float _1182 = max(_709, _484);
              float _1183 = max(_709, _485);
              float _1184 = max(_709, _486);
              if (!_497) {
                _1202 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _484) - _1182) * _1181) + _1182));
                _1203 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _485) - _1183) * _1181) + _1183));
                _1204 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _486) - _1184) * _1181) + _1184));
              } else {
                _1202 = CSCustomConstants_064.x;
                _1203 = CSCustomConstants_064.x;
                _1204 = CSCustomConstants_064.x;
              }
              float _1208 = saturate(1.0f - abs(dot(float3(_1157, _1158, _1159), float3(_451, _452, _453))));
              float _1209 = _1208 * _1208;
              float _1222 = ((_1209 * _1209) * _1208) * cb13_066x;
              float _1228 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _388.w));
              [branch]
              if (cb12_221z > 0.0f) {
                float _1238 = saturate(_1161);
                float _1241 = (_1164 * 2.0f) * _1238;
                _1260 = ((((_1238 + _1164) - _1241) * _1165) + _1241);
              } else {
                float _1246 = 1.0f - _1166;
                _1260 = (((sqrt(((_1174 * _1174) * _1246) + _1166) * _1164) + 9.999999747378752e-05f) + (sqrt(((_1164 * _1164) * _1246) + _1166) * _1174));
              }
              float _1261 = 0.5f / _1260;
              float _1262 = GRAPHICS_PBR ? GraphicsDirectGGX(_1163, _1161, _1164, direct_roughness)
                  : _1261 * (_1166 / ((_1170 * _1170) * 3.1415200233459473f));
              float _1263 = _1262 * (((_1222 * max(0.0f, (_1202 - _484))) / _1228) + _484);
              float _1264 = _1262 * (((_1222 * max(0.0f, (_1203 - _485))) / _1228) + _485);
              float _1265 = _1262 * (((_1222 * max(0.0f, (_1204 - _486))) / _1228) + _486);
              if (cb12_221y > 0.0f) {
                float4 _1272 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_601, _602, _603), float3(_1261, _1261, _1261))), 0.0f);
                float _1278 = (_1272.x * _484) + _1272.y;
                float _1279 = (_1272.x * _485) + _1272.y;
                float _1280 = (_1272.x * _486) + _1272.y;
                _1315 = ((min((_1278 / max((1.0f - ((1.0f - _1278) * ((_903 * 0.0476190485060215f) + _484))), 0.0010000000474974513f)), 1.0f) / max(_1278, 9.999999747378752e-05f)) * _1263);
                _1316 = ((min((_1279 / max((1.0f - ((1.0f - _1279) * ((_904 * 0.0476190485060215f) + _485))), 0.0010000000474974513f)), 1.0f) / max(_1279, 9.999999747378752e-05f)) * _1264);
                _1317 = ((min((_1280 / max((1.0f - ((1.0f - _1280) * ((_905 * 0.0476190485060215f) + _486))), 0.0010000000474974513f)), 1.0f) / max(_1280, 9.999999747378752e-05f)) * _1265);
              } else {
                _1315 = _1263;
                _1316 = _1264;
                _1317 = _1265;
              }
              _1322 = (_1315 * _1164);
              _1323 = (_1316 * _1164);
              _1324 = (_1317 * _1164);
            } else {
              _1322 = 0.0f;
              _1323 = 0.0f;
              _1324 = 0.0f;
            }
            if (!(_513 == 0)) {
              float _1327 = dot(float3(_382, _383, _384), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
              float _1336 = 1.0010000467300415f - _1327;
              float _1368 = saturate(dot(float3(_604, _605, _606), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z))) * (exp2(log2(1.0f - saturate(dot(float3(_604, _605, _606), float3(_451, _452, _453)))) * 5.0f) * _642);
              _1373 = (_1368 * saturate((1.0f - exp2(log2(_1336 - ((_382 - _1327) * _641)) * cb12_223x)) * cb12_223y));
              _1374 = (_1368 * saturate((1.0f - exp2(log2(_1336 - ((_383 - _1327) * _641)) * cb12_223x)) * cb12_223y));
              _1375 = (_1368 * saturate((1.0f - exp2(log2(_1336 - ((_384 - _1327) * _641)) * cb12_223x)) * cb12_223y));
            } else {
              _1373 = 0.0f;
              _1374 = 0.0f;
              _1375 = 0.0f;
            }
            _1383 = ((_1373 + _1322) * _1143);
            _1384 = ((_1374 + _1323) * _1145);
            _1385 = ((_1375 + _1324) * _1147);
            _1386 = (_1143 * _1093);
            _1387 = (_1145 * _1094);
            _1388 = (_1147 * _1095);
          } else {
            _1383 = 0.0f;
            _1384 = 0.0f;
            _1385 = 0.0f;
            _1386 = 0.0f;
            _1387 = 0.0f;
            _1388 = 0.0f;
          }
        } else {
          _1383 = 0.0f;
          _1384 = 0.0f;
          _1385 = 0.0f;
          _1386 = 0.0f;
          _1387 = 0.0f;
          _1388 = 0.0f;
        }
        if (_504 == 0) {
          _1395 = cb12_071x;
        } else {
          _1395 = 1.0f;
        }
        if (CSCustomConstants_128.x > 0.0f) {
          uint4 _1398 = 0u; t17.GetDimensions(0u, _1398.x, _1398.y, _1398.z, _1398.w);
          if ((int)((uint)_44 < (uint)(int)(_1398.x)) && (int)((uint)_45 < (uint)(int)(_1398.y))) {
            int _1406 = min((int)(_1398.z), 8);
            if (!(_1406 == 0)) {
              uint _1409 = t17.Load(int4(_44, _45, 0, 0));
              _1412 = _1409.x;
            } else {
              _1412 = 0;
            }
            if ((uint)_1406 > (uint)1) {
              uint _1415 = t17.Load(int4(_44, _45, 1, 0));
              _1418 = _1415.x;
            } else {
              _1418 = 0;
            }
            if ((uint)_1406 > (uint)2) {
              uint _1421 = t17.Load(int4(_44, _45, 2, 0));
              _1424 = _1421.x;
            } else {
              _1424 = 0;
            }
            if ((uint)_1406 > (uint)3) {
              uint _1427 = t17.Load(int4(_44, _45, 3, 0));
              _1430 = _1427.x;
            } else {
              _1430 = 0;
            }
            if ((uint)_1406 > (uint)4) {
              uint _1433 = t17.Load(int4(_44, _45, 4, 0));
              _1436 = _1433.x;
            } else {
              _1436 = 0;
            }
            if ((uint)_1406 > (uint)5) {
              uint _1439 = t17.Load(int4(_44, _45, 5, 0));
              _1442 = _1439.x;
            } else {
              _1442 = 0;
            }
            if ((uint)_1406 > (uint)6) {
              uint _1445 = t17.Load(int4(_44, _45, 6, 0));
              _1448 = _1445.x;
            } else {
              _1448 = 0;
            }
            if ((uint)_1406 > (uint)7) {
              uint _1451 = t17.Load(int4(_44, _45, 7, 0));
              _1454 = _1430;
              _1455 = _1424;
              _1456 = _1418;
              _1457 = _1412;
              _1458 = _1451.x;
              _1459 = _1448;
              _1460 = _1442;
              _1461 = _1436;
              _1462 = _1406;
            } else {
              _1454 = _1430;
              _1455 = _1424;
              _1456 = _1418;
              _1457 = _1412;
              _1458 = 0;
              _1459 = _1448;
              _1460 = _1442;
              _1461 = _1436;
              _1462 = _1406;
            }
          } else {
            _1454 = 0;
            _1455 = 0;
            _1456 = 0;
            _1457 = 0;
            _1458 = 0;
            _1459 = 0;
            _1460 = 0;
            _1461 = 0;
            _1462 = 0;
          }
        } else {
          _1454 = 0;
          _1455 = 0;
          _1456 = 0;
          _1457 = 0;
          _1458 = 0;
          _1459 = 0;
          _1460 = 0;
          _1461 = 0;
          _1462 = 0;
        }
        int _1463 = _global_3;
        if (!(_1463 == 0)) {
          _1501 = _1386;
          _1502 = _1387;
          _1503 = _1388;
          _1504 = _1383;
          _1505 = _1384;
          _1506 = _1385;
          _1507 = 0;
          while(true) {
            int _1509 = _global_2[_1507];
            float _1512 = t18[_1509].LightParams_000.x;
            float _1513 = t18[_1509].LightParams_000.y;
            float _1514 = t18[_1509].LightParams_000.z;
            float _1515 = _1512 - _439;
            float _1516 = _1513 - _440;
            float _1517 = _1514 - _441;
            uint _1518 = _1509 + 1u;
            if (!(_1462 == 0)) {
              if (!((_1457 & 511) == _1518)) {
                if (!((uint)_1462 < (uint)2)) {
                  if (!((_1456 & 511) == _1518)) {
                    if (!((uint)_1462 < (uint)3)) {
                      if (!((_1455 & 511) == _1518)) {
                        if (!((uint)_1462 < (uint)4)) {
                          if (!((_1454 & 511) == _1518)) {
                            if (!((uint)_1462 < (uint)5)) {
                              if (!((_1461 & 511) == _1518)) {
                                if (!((uint)_1462 < (uint)6)) {
                                  if (!((_1460 & 511) == _1518)) {
                                    if (!((uint)_1462 < (uint)7)) {
                                      if (!((_1459 & 511) == _1518)) {
                                        if ((int)((uint)_1462 > (uint)7) && (int)((_1458 & 511) == _1518)) {
                                          _1559 = _1458;
                                          _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                                          _1566 = true;
                                        } else {
                                          _1565 = 1.0f;
                                          _1566 = false;
                                        }
                                      } else {
                                        _1559 = _1459;
                                        _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                                        _1566 = true;
                                      }
                                    } else {
                                      _1565 = 1.0f;
                                      _1566 = false;
                                    }
                                  } else {
                                    _1559 = _1460;
                                    _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                                    _1566 = true;
                                  }
                                } else {
                                  _1565 = 1.0f;
                                  _1566 = false;
                                }
                              } else {
                                _1559 = _1461;
                                _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                                _1566 = true;
                              }
                            } else {
                              _1565 = 1.0f;
                              _1566 = false;
                            }
                          } else {
                            _1559 = _1454;
                            _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                            _1566 = true;
                          }
                        } else {
                          _1565 = 1.0f;
                          _1566 = false;
                        }
                      } else {
                        _1559 = _1455;
                        _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                        _1566 = true;
                      }
                    } else {
                      _1565 = 1.0f;
                      _1566 = false;
                    }
                  } else {
                    _1559 = _1456;
                    _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                    _1566 = true;
                  }
                } else {
                  _1565 = 1.0f;
                  _1566 = false;
                }
              } else {
                _1559 = _1457;
                _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                _1566 = true;
              }
            } else {
              _1565 = 1.0f;
              _1566 = false;
            }
            float _1572 = sqrt(((_1515 * _1515) + (_1516 * _1516)) + (_1517 * _1517));
            float _1575 = t18[_1509].LightParams_080.x;
            float _1577 = t18[_1509].LightParams_000.w;
            float _1578 = _1572 / _1577;
            float _1579 = _1578 * _1578;
            float _1582 = saturate(1.0f - (_1579 * _1579));
            float _1585 = t18[_1509].LightParams_048.w;
            int _1586 = asint(_1585);
            bool _1588 = ((_1586 & 1) != 0);
            float _1589 = t18[_1509].LightParams_080.z;
            bool _1590 = (_1589 > 0.0f);
            float _1592 = t18[_1509].LightParams_096.x;
            float _1595 = t18[_1509].LightParams_144.x;
            int _1596 = asint(_1595);
            bool _1598 = ((_1596 & 1) != 0);
            float _1600 = (_1582 * _1582) / (((_1572 * _1572) * _1575) + 1.0f);
            if (_1588) {
              float _1603 = t18[_1509].LightParams_032.x;
              float _1604 = t18[_1509].LightParams_032.y;
              float _1605 = t18[_1509].LightParams_032.z;
              float _1607 = rsqrt(dot(float3(_1515, _1516, _1517), float3(_1515, _1516, _1517)));
              float _1616 = t18[_1509].LightParams_064.w;
              float _1617 = t18[_1509].LightParams_064.y;
              float _1619 = t18[_1509].LightParams_064.z;
              _1627 = (exp2(log2(saturate((_1617 * dot(float3((-0.0f - (_1515 * _1607)), (-0.0f - (_1516 * _1607)), (-0.0f - (_1517 * _1607))), float3(_1603, _1604, _1605))) + _1619)) * _1616) * _1600);
            } else {
              _1627 = _1600;
            }
            bool _1628 = (_1627 > 0.0f);
            if (_1566 && _1628) {
              _1633 = saturate(_1565);
            } else {
              _1633 = 1.0f;
            }
            if (((int)(_1590 || _1598)) && _1628) {
              float _1637 = -0.0f - _1515;
              float _1638 = -0.0f - _1516;
              float _1639 = -0.0f - _1517;
              if (_1588) {
                float _1642 = t18[_1509].LightParams_032.x;
                float _1643 = t18[_1509].LightParams_032.y;
                float _1644 = t18[_1509].LightParams_032.z;
                float _1646 = t18[_1509].LightParams_112.y;
                float _1647 = t18[_1509].LightParams_112.z;
                float _1648 = t18[_1509].LightParams_112.w;
                float _1667 = t18[_1509].LightParams_112.x;
                float _1669 = t18[_1509].LightParams_144.z;
                _1843 = mad(((_1647 * _1642) - (_1646 * _1643)), _1639, mad(((_1646 * _1644) - (_1648 * _1642)), _1638, (((_1648 * _1643) - (_1647 * _1644)) * _1637)));
                _1844 = mad(_1648, _1639, mad(_1647, _1638, (_1646 * _1637)));
                _1845 = mad(_1644, _1639, mad(_1643, _1638, (_1642 * _1637)));
                _1846 = _1667;
                _1847 = asint(_1669);
              } else {
                if (_1598) {
                  float _1674 = t18[_1509].LightParams_064.y;
                  float _1675 = t18[_1509].LightParams_064.z;
                  float _1676 = t18[_1509].LightParams_064.w;
                  float _1678 = t18[_1509].LightParams_032.x;
                  float _1679 = t18[_1509].LightParams_032.y;
                  float _1680 = t18[_1509].LightParams_032.z;
                  float _1692 = mad(((_1678 * _1675) - (_1679 * _1674)), _1639, mad(((_1680 * _1674) - (_1678 * _1676)), _1638, (((_1679 * _1676) - (_1680 * _1675)) * _1637)));
                  float _1695 = mad(_1680, _1639, mad(_1679, _1638, (_1678 * _1637)));
                  float _1698 = mad(_1676, _1639, mad(_1675, _1638, (_1674 * _1637)));
                  float _1699 = -0.0f - _1692;
                  float _1700 = -0.0f - _1695;
                  float _1701 = -0.0f - _1698;
                  float _1702 = _1699 / _1572;
                  float _1703 = _1700 / _1572;
                  float _1704 = _1701 / _1572;
                  float _1705 = abs(_1702);
                  float _1706 = abs(_1703);
                  float _1707 = abs(_1704);
                  bool _1711 = (_1705 > max(_1706, _1707));
                  if (!((_1596 & 4) == 0)) {
                    if (_1711) {
                      if (_1702 > 0.0f) {
                        float _1717 = t18[_1509].LightParams_112.x;
                        _1741 = _1695;
                        _1742 = _1698;
                        _1743 = _1699;
                        _1744 = _1717;
                      } else {
                        float _1720 = t18[_1509].LightParams_112.y;
                        _1741 = _1700;
                        _1742 = _1698;
                        _1743 = _1692;
                        _1744 = _1720;
                      }
                    } else {
                      if (_1706 > max(_1705, _1707)) {
                        if (_1703 > 0.0f) {
                          float _1728 = t18[_1509].LightParams_112.z;
                          _1741 = _1699;
                          _1742 = _1698;
                          _1743 = _1700;
                          _1744 = _1728;
                        } else {
                          float _1731 = t18[_1509].LightParams_112.w;
                          _1741 = _1692;
                          _1742 = _1698;
                          _1743 = _1695;
                          _1744 = _1731;
                        }
                      } else {
                        if (_1704 > 0.0f) {
                          float _1736 = t18[_1509].LightParams_128.x;
                          _1741 = _1692;
                          _1742 = _1695;
                          _1743 = _1701;
                          _1744 = _1736;
                        } else {
                          float _1739 = t18[_1509].LightParams_128.y;
                          _1741 = _1692;
                          _1742 = _1700;
                          _1743 = _1698;
                          _1744 = _1739;
                        }
                      }
                    }
                    float _1746 = t18[_1509].LightParams_144.z;
                    _1843 = _1741;
                    _1844 = _1742;
                    _1845 = _1743;
                    _1846 = _1744;
                    _1847 = asint(_1746);
                  } else {
                    if (_1711) {
                      if (_1702 > 0.0f) {
                        float _1753 = t18[_1509].LightParams_112.x;
                        float _1755 = t18[_1509].LightParams_144.z;
                        _1843 = _1695;
                        _1844 = _1698;
                        _1845 = _1699;
                        _1846 = _1753;
                        _1847 = asint(_1755);
                      } else {
                        float _1759 = t18[_1509].LightParams_112.y;
                        float _1761 = t18[_1509].LightParams_144.z;
                        _1843 = _1700;
                        _1844 = _1698;
                        _1845 = _1692;
                        _1846 = _1759;
                        _1847 = ((uint)((uint)(asint(_1761))) >> 10);
                      }
                    } else {
                      if (_1706 > max(_1705, _1707)) {
                        if (_1703 > 0.0f) {
                          float _1771 = t18[_1509].LightParams_112.z;
                          float _1773 = t18[_1509].LightParams_144.z;
                          _1843 = _1699;
                          _1844 = _1698;
                          _1845 = _1700;
                          _1846 = _1771;
                          _1847 = ((uint)((uint)(asint(_1773))) >> 20);
                        } else {
                          float _1778 = t18[_1509].LightParams_112.w;
                          float _1780 = t18[_1509].LightParams_144.w;
                          _1843 = _1692;
                          _1844 = _1698;
                          _1845 = _1695;
                          _1846 = _1778;
                          _1847 = asint(_1780);
                        }
                      } else {
                        if (_1704 > 0.0f) {
                          float _1786 = t18[_1509].LightParams_128.x;
                          float _1788 = t18[_1509].LightParams_144.w;
                          _1843 = _1692;
                          _1844 = _1695;
                          _1845 = _1701;
                          _1846 = _1786;
                          _1847 = ((uint)((uint)(asint(_1788))) >> 10);
                        } else {
                          float _1793 = t18[_1509].LightParams_128.y;
                          float _1795 = t18[_1509].LightParams_144.w;
                          _1843 = _1692;
                          _1844 = _1700;
                          _1845 = _1698;
                          _1846 = _1793;
                          _1847 = ((uint)((uint)(asint(_1795))) >> 20);
                        }
                      }
                    }
                  }
                } else {
                  float _1799 = _1515 / _1572;
                  float _1800 = _1516 / _1572;
                  float _1801 = _1517 / _1572;
                  float _1802 = abs(_1799);
                  float _1803 = abs(_1800);
                  float _1804 = abs(_1801);
                  if (_1802 > max(_1803, _1804)) {
                    if (_1799 > 0.0f) {
                      float _1811 = t18[_1509].LightParams_112.x;
                      _1835 = _1638;
                      _1836 = _1639;
                      _1837 = _1515;
                      _1838 = _1811;
                    } else {
                      float _1814 = t18[_1509].LightParams_112.y;
                      _1835 = _1516;
                      _1836 = _1639;
                      _1837 = _1637;
                      _1838 = _1814;
                    }
                  } else {
                    if (_1803 > max(_1802, _1804)) {
                      if (_1800 > 0.0f) {
                        float _1822 = t18[_1509].LightParams_112.z;
                        _1835 = _1515;
                        _1836 = _1639;
                        _1837 = _1516;
                        _1838 = _1822;
                      } else {
                        float _1825 = t18[_1509].LightParams_112.w;
                        _1835 = _1637;
                        _1836 = _1639;
                        _1837 = _1638;
                        _1838 = _1825;
                      }
                    } else {
                      if (_1801 > 0.0f) {
                        float _1830 = t18[_1509].LightParams_128.x;
                        _1835 = _1637;
                        _1836 = _1638;
                        _1837 = _1517;
                        _1838 = _1830;
                      } else {
                        float _1833 = t18[_1509].LightParams_128.y;
                        _1835 = _1637;
                        _1836 = _1516;
                        _1837 = _1639;
                        _1838 = _1833;
                      }
                    }
                  }
                  float _1840 = t18[_1509].LightParams_144.z;
                  _1843 = _1835;
                  _1844 = _1836;
                  _1845 = _1837;
                  _1846 = _1838;
                  _1847 = asint(_1840);
                }
              }
              float _1848 = t18[_1509].LightParams_080.y;
              float _1855 = (((_1843 * _1848) / _1845) * 0.5f) + 0.5f;
              float _1856 = 0.5f - ((mad(_1848, _1844, 0.0f) / _1845) * 0.5f);
              if (_1590) {
                int _1858 = asint(_1846);
                int _1860 = ((uint)(_1858) >> 18) & 4092;
                float _1861 = float((uint)_1860);
                [branch]
                if (!(_1860 == 0)) {
                  if (!_1566) {
                    float _1883 = t9.SampleLevel(s10, float3((cb13_067x * ((_1855 * _1861) + float((uint)((uint)(((int)(_1858 << 2u)) & 4092))))), (cb13_067x * ((_1856 * _1861) + float((uint)((uint)(((uint)(_1858) >> 8) & 4092))))), float((uint)((uint)((uint)(_1858) >> 30)))), 0.0f);
                    _1892 = (saturate(exp2((_1883.x - (_1578 * 0.9900000095367432f)) * 144.26950073242188f)) * _1633);
                  } else {
                    _1892 = _1633;
                  }
                } else {
                  _1892 = _1633;
                }
              } else {
                _1892 = _1633;
              }
              if (_1598) {
                bool _1895 = ((_1596 & 2) != 0);
                if (_1895) {
                  _1905 = (_1847 & 1023);
                  _1906 = 0;
                } else {
                  _1905 = (_1847 & 255);
                  _1906 = (((uint)(_1847) >> 8) & 3);
                }
                float _1909 = t18[_1509].LightParams_144.y;
                float _1911 = floor(_1909) + float((uint)_1905);
                float4 _1915 = t42.SampleLevel(s10, float3(_1855, _1856, _1911), 0.0f);
                _28[0] = _1915.x;
                _28[1] = _1915.y;
                _28[2] = _1915.z;
                _28[3] = _1915.w;
                if (!((_1596 & 8) == 0)) {
                  float4 _1926 = t42.SampleLevel(s10, float3(_1855, _1856, (_1911 + 1.0f)), 0.0f);
                  float _1931 = frac(_1909);
                  float _1940 = ((_1926.x - _1915.x) * _1931) + _1915.x;
                  float _1941 = ((_1926.y - _1915.y) * _1931) + _1915.y;
                  float _1942 = ((_1926.z - _1915.z) * _1931) + _1915.z;
                  _28[0] = _1940;
                  _28[1] = _1941;
                  _28[2] = _1942;
                  _28[3] = (lerp(_1915.w, _1926.w, _1931));
                  _1945 = _1942;
                  _1946 = _1941;
                  _1947 = _1940;
                } else {
                  _1945 = _1915.z;
                  _1946 = _1915.y;
                  _1947 = _1915.x;
                }
                if (!_1895) {
                  float _1950 = _28[_1906];
                  _1952 = _1950;
                  _1953 = _1950;
                  _1954 = _1950;
                } else {
                  _1952 = _1947;
                  _1953 = _1946;
                  _1954 = _1945;
                }
                _1956 = _1892;
                _1957 = _1952;
                _1958 = _1953;
                _1959 = _1954;
              } else {
                _1956 = _1892;
                _1957 = 1.0f;
                _1958 = 1.0f;
                _1959 = 1.0f;
              }
            } else {
              _1956 = _1633;
              _1957 = 1.0f;
              _1958 = 1.0f;
              _1959 = 1.0f;
            }
            if ((int)(_1592 > 0.0f) && _1628) {
              if (!_1566) {
                float _1965 = t18[_1509].LightParams_096.y;
                float _1966 = t10.SampleLevel(s10, float4(_1515, _1516, _1517, _1965), 0.0f);
                _1976 = (saturate(exp2((_1966.x - (_1578 * 0.9900000095367432f)) * 144.26950073242188f)) * _1956);
                float _1977 = t18[_1509].LightParams_080.w;
                _1979 = _1976;
                _1980 = _1977;
              } else {
                _1979 = _1956;
                _1980 = 1.0f;
              }
            } else {
              if (!_1566) {
                _1976 = _1956;
                float _1977 = t18[_1509].LightParams_080.w;
                _1979 = _1976;
                _1980 = _1977;
              } else {
                _1979 = _1956;
                _1980 = 1.0f;
              }
            }
            if ((int)(_706.z == 1.0f) || (int)((_1586 & 2048) != 0)) {
              _1992 = cb12_071y;
            } else {
              _1992 = 0.0f;
            }
            if (((int)(!(_706.z == 1.0f))) || (int)((_1586 & 4096) != 0)) {
              _2001 = cb12_071z;
            } else {
              _2001 = 0.0f;
            }
            float _2004 = ((((_1980 * (_1979 + -1.0f)) + 1.0f) * _1627) * _1992) * _2001;
            float _2005 = _2004 * _1957;
            float _2006 = _2004 * _1958;
            float _2007 = _2004 * _1959;
            [branch]
            if ((int)(_2007 > 0.0f) || ((int)((int)(_2005 > 0.0f) || (int)(_2006 > 0.0f)))) {
              bool _2019 = ((int)_1586 < (int)0);
              float _2020 = select(_2019, _1395, 1.0f);
              float _2028 = rsqrt(dot(float3(_1515, _1516, _1517), float3(_1515, _1516, _1517)));
              float _2029 = _2028 * _1515;
              float _2030 = _2028 * _1516;
              float _2031 = _2028 * _1517;
              bool _2032 = (_597 == 0);
              [branch]
              if (GRAPHICS_PBR && _597 != 2) {
              // Preserve native albedo/normalization, then retain the original
              // Fresnel complement, transmission, visibility and light units.
              float3 diffuse_response = GraphicsDiffuseResponse(float3(_598, _599, _600), float3(_451, _452, _453),
                  float3(_2029, _2030, _2031), direct_roughness, float3(_382, _383, _384), _597, saturate(dot(float3(_598, _599, _600), float3(_2029, _2030, _2031))));
              _2197 = diffuse_response.x; _2198 = diffuse_response.y; _2199 = diffuse_response.z;
            } else if (_2032) {
                float _2036 = saturate(saturate(dot(float3(_598, _599, _600), float3(_2029, _2030, _2031))));
                _2197 = _2036;
                _2198 = _2036;
                _2199 = _2036;
              } else {
                if (_597 == 2) {
                  float _2050 = saturate(dot(float3(_2029, _2030, _2031), float3(_451, _452, _453)) + 0.5f) * exp2(log2(abs(dot(float3(_2029, _2030, _2031), float3(_598, _599, _600)))) * cb12_037y);
                  _2197 = (_2050 * _382);
                  _2198 = (_2050 * _383);
                  _2199 = (_2050 * _384);
                } else {
                  int _2057 = ((int)(uint)((int)(_600 > 0.0f))) << 1u;
                  float _2059 = float((int)(_2057 + -1));
                  float _2061 = -1.0f / (_2059 + _600);
                  float _2063 = (_599 * _598) * _2061;
                  float _2067 = (((_598 * _598) * _2059) * _2061) + 1.0f;
                  float _2068 = _2063 * _2059;
                  float _2071 = float((int)(1 - _2057)) * _598;
                  float _2074 = ((_599 * _599) * _2061) + _2059;
                  float _2075 = -0.0f - _599;
                  float _2077 = rsqrt(dot(float3(_2029, _2030, _2031), float3(_2029, _2030, _2031)));
                  float _2078 = _2077 * _2029;
                  float _2079 = _2077 * _2030;
                  float _2080 = _2077 * _2031;
                  float _2083 = mad(_2071, _2080, mad(_2068, _2079, (_2078 * _2067)));
                  float _2086 = mad(_2075, _2080, mad(_2074, _2079, (_2078 * _2063)));
                  float _2089 = mad(_600, _2080, mad(_599, _2079, (_2078 * _598)));
                  float _2091 = rsqrt(dot(float3(_2083, _2086, _2089), float3(_2083, _2086, _2089)));
                  float _2094 = _2091 * _2089;
                  float _2096 = rsqrt(dot(float3(_451, _452, _453), float3(_451, _452, _453)));
                  float _2097 = _2096 * _451;
                  float _2098 = _2096 * _452;
                  float _2099 = _2096 * _453;
                  float _2102 = mad(_2071, _2099, mad(_2068, _2098, (_2097 * _2067)));
                  float _2105 = mad(_2075, _2099, mad(_2074, _2098, (_2097 * _2063)));
                  float _2108 = mad(_600, _2099, mad(_599, _2098, (_2097 * _598)));
                  float _2110 = rsqrt(dot(float3(_2102, _2105, _2108), float3(_2102, _2105, _2108)));
                  float _2113 = _2110 * _2108;
                  float _2114 = _388.w * _388.w;
                  float _2117 = dot(float3((_2091 * _2083), (_2091 * _2086), _2094), float3((_2110 * _2102), (_2110 * _2105), _2113)) - (_2113 * _2094);
                  if (_2117 > 0.0f) {
                    _2123 = (_2117 / max(_2094, _2113));
                  } else {
                    _2123 = _2117;
                  }
                  float _2125 = (_2114 * 0.2877933979034424f) + 1.0f;
                  float _2126 = 1.0f / _2125;
                  float _2130 = ((_2123 * _2114) + 1.0f) * (_2126 * 0.31830987334251404f);
                  float _2134 = 1.0f - _2113;
                  float _2145 = 1.0f - _2094;
                  float _2158 = _2126 * ((_2114 * 0.07248824834823608f) + 1.0f);
                  float _2165 = 1.0f - _2158;
                  float _2180 = max(1.0000000116860974e-07f, (1.0f - ((((_2145 * _2114) * ((((((_2145 * 0.07144299894571304f) + -0.332181453704834f) * _2145) + 0.4918818771839142f) * _2145) + 0.05710852891206741f)) + 1.0f) / _2125))) * (max(1.0000000116860974e-07f, (1.0f - ((((_2134 * _2114) * ((((((_2134 * 0.07144299894571304f) + -0.332181453704834f) * _2134) + 0.4918818771839142f) * _2134) + 0.05710852891206741f)) + 1.0f) / _2125))) * 0.31830987334251404f);
                  float _2184 = max(1.0000000116860974e-07f, _2165);
                  float _2192 = saturate(dot(float3(_598, _599, _600), float3(_2029, _2030, _2031)));
                  _2197 = (_2192 * (((_2180 * (((_382 * _382) * _2158) / (1.0f - (_2165 * _382)))) / _2184) + (_2130 * _382)));
                  _2198 = (_2192 * (((_2180 * (((_383 * _383) * _2158) / (1.0f - (_2165 * _383)))) / _2184) + (_2130 * _383)));
                  _2199 = (_2192 * (((_2180 * (((_384 * _384) * _2158) / (1.0f - (_2165 * _384)))) / _2184) + (_2130 * _384)));
                }
              }
              float _2203 = 1.0f - _484;
              float _2204 = 1.0f - _485;
              float _2205 = 1.0f - _486;
              if (cb12_221x > 0.0f) {
                float4 _2210 = t43.SampleLevel(s10, float2(_388.w, dot(float3(_598, _599, _600), float3(_451, _452, _453))), 0.0f);
                float _2216 = (_2210.x * _484) + _2210.y;
                float _2217 = (_2210.x * _485) + _2210.y;
                float _2218 = (_2210.x * _486) + _2210.y;
                _2280 = min((_2216 / max((1.0f - ((1.0f - _2216) * ((_2203 * 0.0476190485060215f) + _484))), 0.0010000000474974513f)), 1.0f);
                _2281 = min((_2217 / max((1.0f - ((1.0f - _2217) * ((_2204 * 0.0476190485060215f) + _485))), 0.0010000000474974513f)), 1.0f);
                _2282 = min((_2218 / max((1.0f - ((1.0f - _2218) * ((_2205 * 0.0476190485060215f) + _486))), 0.0010000000474974513f)), 1.0f);
              } else {
                float _2244 = _2029 + _451;
                float _2245 = _2030 + _452;
                float _2246 = _2031 + _453;
                float _2248 = rsqrt(dot(float3(_2244, _2245, _2246), float3(_2244, _2245, _2246)));
                float _2255 = saturate(1.0f - abs(dot(float3((_2248 * _2244), (_2248 * _2245), (_2248 * _2246)), float3(_451, _452, _453))));
                float _2256 = _2255 * _2255;
                float _2266 = ((_2256 * _2256) * _2255) * cb13_066x;
                float _2272 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _388.w));
                _2280 = (((_2266 * max(0.0f, _2203)) / _2272) + _484);
                _2281 = (((_2266 * max(0.0f, _2204)) / _2272) + _485);
                _2282 = (((_2266 * max(0.0f, _2205)) / _2272) + _486);
              }
              float _2286 = (1.0f - _2280) * _2197;
              float _2287 = (1.0f - _2281) * _2198;
              float _2288 = (1.0f - _2282) * _2199;
              bool _2290 = ((_597 & -3) == 0);
              float _2294 = select(_2290, (_2286 * 0.31830987334251404f), _2286);
              float _2295 = select(_2290, (_2287 * 0.31830987334251404f), _2287);
              float _2296 = select(_2290, (_2288 * 0.31830987334251404f), _2288);

              [branch]
              if (_643 > 0.0f) {
                if (!(cb12_037z == 0.0f)) {
                  float _2308 = dot(float3(_382, _383, _384), float3(0.21250000596046448f, 0.715399980545044f, 0.07209999859333038f));
                  if (!_2032) {
                    _2323 = saturate(lerp(_2308, _382, cb12_036w));
                    _2324 = saturate(lerp(_2308, _383, cb12_036w));
                    _2325 = saturate(lerp(_2308, _384, cb12_036w));
                  } else {
                    _2323 = 1.0f;
                    _2324 = 1.0f;
                    _2325 = 1.0f;
                  }
                  float _2326 = dot(float3(_2029, _2030, _2031), float3(_451, _452, _453));
                  float _2341 = ((_643 * 0.31830987334251404f) * exp2(log2(abs(dot(float3(_2029, _2030, _2031), float3(_598, _599, _600)))) * cb12_036z)) * (exp2((_2326 + cb12_036y) * -4.328084945678711f) + exp2((_2326 + cb12_036x) * -1.4426950216293335f));
                  _2395 = ((_2341 * _2323) + _2294);
                  _2396 = ((_2341 * _2324) + _2295);
                  _2397 = ((_2341 * _2325) + _2296);
                } else {
                  float _2351 = (dot(float3(_2029, _2030, _2031), float3(_598, _599, _600)) + 1.0f) * 0.5f;
                  float _2352 = -0.0f - _451;
                  float _2353 = -0.0f - _452;
                  float _2354 = -0.0f - _453;
                  float _2357 = (dot(float3(_2029, _2030, _2031), float3(_2352, _2353, _2354)) + 1.0f) * 0.5f;
                  float _2360 = _2357 * _2357;
                  float _2362 = select(_2032, 1.0f, _382);
                  float _2363 = select(_2032, 1.0f, _383);
                  float _2364 = select(_2032, 1.0f, _384);
                  float _2374 = cb12_036y * _643;
                  float _2387 = (((_643 * 0.5f) * cb12_036w) * (dot(float3(_598, _599, _600), float3(_2352, _2353, _2354)) + 1.0f)) * ((((_2360 * _2360) - _2351) * cb12_036x) + _2351);
                  _2395 = ((((((_2362 * _2203) * cb12_036z) - _2294) * _2374) + _2294) + (_2387 * _2362));
                  _2396 = ((((((_2363 * _2204) * cb12_036z) - _2295) * _2374) + _2295) + (_2387 * _2363));
                  _2397 = ((((((_2364 * _2205) * cb12_036z) - _2296) * _2374) + _2296) + (_2387 * _2364));
                }
              } else {
                _2395 = _2294;
                _2396 = _2295;
                _2397 = _2296;
              }
              float _2398 = t18[_1509].LightParams_048.x;
              float _2399 = t18[_1509].LightParams_048.y;
              float _2400 = t18[_1509].LightParams_048.z;
              float _2401 = (_2005 * _2020) * _2398;
              float _2403 = (_2006 * _2020) * _2399;
              float _2405 = (_2007 * _2020) * _2400;
              [branch]
              if (dot(float3(_2029, _2030, _2031), float3(_601, _602, _603)) > 0.0f) {
                float _2413 = _2029 + _451;
                float _2414 = _2030 + _452;
                float _2415 = _2031 + _453;
                float _2417 = rsqrt(dot(float3(_2413, _2414, _2415), float3(_2413, _2414, _2415)));
                float _2418 = _2417 * _2413;
                float _2419 = _2417 * _2414;
                float _2420 = _2417 * _2415;
                float _2422 = dot(float3(_601, _602, _603), float3(_451, _452, _453));
                float _2424 = saturate(dot(float3(_601, _602, _603), float3(_2418, _2419, _2420)));
                float _2425 = saturate(dot(float3(_601, _602, _603), float3(_2029, _2030, _2031)));
                float _2426 = direct_roughness * direct_roughness;
                float _2427 = _2426 * _2426;
                float _2431 = ((_2424 * _2424) * (_2427 + -1.0f)) + 1.0f;
                float _2435 = abs(_2422);
                float _2436 = CSCustomConstants_048.y - CSCustomConstants_048.x;
                float _2442 = saturate(select((_2436 == 0.0f), 1e+05f, (1.0f / _2436)) * (_459 - CSCustomConstants_048.x));
                float _2443 = max(CSCustomConstants_048.z, _484);
                float _2444 = max(CSCustomConstants_048.z, _485);
                float _2445 = max(CSCustomConstants_048.z, _486);
                if (!_497) {
                  _2463 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _484) - _2443) * _2442) + _2443));
                  _2464 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _485) - _2444) * _2442) + _2444));
                  _2465 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _486) - _2445) * _2442) + _2445));
                } else {
                  _2463 = CSCustomConstants_064.x;
                  _2464 = CSCustomConstants_064.x;
                  _2465 = CSCustomConstants_064.x;
                }
                float _2469 = saturate(1.0f - abs(dot(float3(_2418, _2419, _2420), float3(_451, _452, _453))));
                float _2470 = _2469 * _2469;
                float _2483 = ((_2470 * _2470) * _2469) * cb13_066x;
                float _2489 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _388.w));
                [branch]
                if (cb12_221z > 0.0f) {
                  float _2499 = saturate(_2422);
                  float _2502 = (_2425 * 2.0f) * _2499;
                  _2521 = ((((_2499 + _2425) - _2502) * _2426) + _2502);
                } else {
                  float _2507 = 1.0f - _2427;
                  _2521 = (((sqrt(((_2435 * _2435) * _2507) + _2427) * _2425) + 9.999999747378752e-05f) + (sqrt(((_2425 * _2425) * _2507) + _2427) * _2435));
                }
                float _2522 = 0.5f / _2521;
                float _2523 = GRAPHICS_PBR ? GraphicsDirectGGX(_2424, _2422, _2425, direct_roughness)
                  : _2522 * (_2427 / ((_2431 * _2431) * 3.1415200233459473f));
                float _2524 = _2523 * (((_2483 * max(0.0f, (_2463 - _484))) / _2489) + _484);
                float _2525 = _2523 * (((_2483 * max(0.0f, (_2464 - _485))) / _2489) + _485);
                float _2526 = _2523 * (((_2483 * max(0.0f, (_2465 - _486))) / _2489) + _486);
                if (cb12_221y > 0.0f) {
                  float4 _2533 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_601, _602, _603), float3(_2522, _2522, _2522))), 0.0f);
                  float _2539 = (_2533.x * _484) + _2533.y;
                  float _2540 = (_2533.x * _485) + _2533.y;
                  float _2541 = (_2533.x * _486) + _2533.y;
                  _2576 = ((min((_2539 / max((1.0f - ((1.0f - _2539) * ((_2203 * 0.0476190485060215f) + _484))), 0.0010000000474974513f)), 1.0f) / max(_2539, 9.999999747378752e-05f)) * _2524);
                  _2577 = ((min((_2540 / max((1.0f - ((1.0f - _2540) * ((_2204 * 0.0476190485060215f) + _485))), 0.0010000000474974513f)), 1.0f) / max(_2540, 9.999999747378752e-05f)) * _2525);
                  _2578 = ((min((_2541 / max((1.0f - ((1.0f - _2541) * ((_2205 * 0.0476190485060215f) + _486))), 0.0010000000474974513f)), 1.0f) / max(_2541, 9.999999747378752e-05f)) * _2526);
                } else {
                  _2576 = _2524;
                  _2577 = _2525;
                  _2578 = _2526;
                }
                _2583 = (_2576 * _2425);
                _2584 = (_2577 * _2425);
                _2585 = (_2578 * _2425);
              } else {
                _2583 = 0.0f;
                _2584 = 0.0f;
                _2585 = 0.0f;
              }
              if (!(_513 == 0)) {
                float _2588 = dot(float3(_382, _383, _384), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
                float _2596 = 1.0010000467300415f - _2588;
                float _2628 = saturate(dot(float3(_604, _605, _606), float3(_2029, _2030, _2031))) * (exp2(log2(1.0f - saturate(dot(float3(_604, _605, _606), float3(_451, _452, _453)))) * 5.0f) * select((((int)(_497 || _498)) || _2019), 0.0f, (select(_505, cb12_223w, cb12_223z) * _642)));
                _2633 = (_2628 * saturate((1.0f - exp2(log2(_2596 - ((_382 - _2588) * _641)) * cb12_223x)) * cb12_223y));
                _2634 = (_2628 * saturate((1.0f - exp2(log2(_2596 - ((_383 - _2588) * _641)) * cb12_223x)) * cb12_223y));
                _2635 = (_2628 * saturate((1.0f - exp2(log2(_2596 - ((_384 - _2588) * _641)) * cb12_223x)) * cb12_223y));
              } else {
                _2633 = 0.0f;
                _2634 = 0.0f;
                _2635 = 0.0f;
              }
              _2646 = ((_2401 * _2395) + _1501);
              _2647 = ((_2403 * _2396) + _1502);
              _2648 = ((_2405 * _2397) + _1503);
              _2649 = ((_2401 * (_2633 + _2583)) + _1504);
              _2650 = ((_2403 * (_2634 + _2584)) + _1505);
              _2651 = ((_2405 * (_2635 + _2585)) + _1506);
            } else {
              _2646 = _1501;
              _2647 = _1502;
              _2648 = _1503;
              _2649 = _1504;
              _2650 = _1505;
              _2651 = _1506;
            }
            uint _2652 = _1507 + 1u;
            if ((uint)_2652 < (uint)_1463) {
              _1501 = _2646;
              _1502 = _2647;
              _1503 = _2648;
              _1504 = _2649;
              _1505 = _2650;
              _1506 = _2651;
              _1507 = _2652;
              continue;
            }
            break;
          }
          while(true) {
            _1468 = _2646;
            _1469 = _2647;
            _1470 = _2648;
            _1471 = _2649;
            _1472 = _2650;
            _1473 = _2651;
            break;
          }
        } else {
          _1468 = _1386;
          _1469 = _1387;
          _1470 = _1388;
          _1471 = _1383;
          _1472 = _1384;
          _1473 = _1385;
        }
        float4 _1478 = t16.Load(int3(_44, _45, 0));
        bool _1499 = (_706.z < 0.9900000095367432f);
        if (_1499) {
          _2658 = cb12_287w;
        } else {
          _2658 = 1.0f;
        }
        float _2662 = log2(((((((cb12_069z + -1.0f) * _643) + 1.0f) * (saturate((cb12_187x * _1478.x) + cb12_188x) + -1.0f)) + 1.0f) * cb12_069x) + cb12_069y);
        if (_1499) {
          _2669 = cb12_287w;
        } else {
          _2669 = 1.0f;
        }
        float _2674 = exp2((cb12_288z * _2658) * _2662) * cb12_184z;
        float _2678 = exp2((_2662 * cb12_288w) * _2669) * cb12_184w;
        _2683 = _597;
        _2684 = (_2674 * _1468);
        _2685 = (_2674 * _1469);
        _2686 = (_2674 * _1470);
        _2687 = (_2678 * _1471);
        _2688 = (_2678 * _1472);
        _2689 = (_2678 * _1473);
        if (_2683 == 0) {
          _2696 = (_2684 * _382);
          _2697 = (_2685 * _383);
          _2698 = (_2686 * _384);
        } else {
          _2696 = _2684;
          _2697 = _2685;
          _2698 = _2686;
        }
        float _2708 = max(0.0f, _2687) + max(0.0f, _2696);
        float _2709 = max(0.0f, _2688) + max(0.0f, _2697);
        float _2710 = max(0.0f, _2689) + max(0.0f, _2698);
        if (cb12_074x > 0.0f) {
          u0[int2(_44, _45)] = float4(_2708, _2709, _2710, 1.0f);
        } else {
          u0[int2(_44, _45)] = float4(_2708, _2709, _2710, 1.0f);
        }
        if ((uint)_47 < (uint)256) {
          if ((uint)_47 < (uint)_global_5) {
            _2730 = (_global_4[_47]);
          } else {
            _2730 = 256;
          }
          u2.Store(((int)(((uint((cb12_024x * _89) + _88) << 8u) + _47) << 2u)), asuint(_2730));
        }
      }
    } else {
      float4 _706 = t16.Load(int3(_44, _45, 0));
      if (graphics_injection.layout_version == 1.f && graphics_injection.graphics_mode != 0.f
          && graphics_injection.contact_shadows != 0.f)
        _706.y = min(_706.y, GraphicsContactVisibility(uint2(_44, _45), uint2(cb12_023x, cb12_023y)));
      float _709 = select(_503, CSCustomConstants_064.z, CSCustomConstants_048.z);
      if (_706.y > 0.0f) {
        if ((_476 & 71) == 65) {
          _723 = cb13_002x;
          _724 = cb13_002y;
        } else {
          _723 = 1.0f;
          _724 = 0.0f;
        }
        float _725 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_598, _599, _600));
        [branch]
        if (((_724 + _643) + saturate(_725)) > 0.0f) {
          bool _731 = (_597 == 0);
          [branch]
          if (GRAPHICS_PBR && _597 != 2) {
              // Preserve native albedo/normalization, then retain the original
              // Fresnel complement, transmission, visibility and light units.
              float3 diffuse_response = GraphicsDiffuseResponse(float3(_598, _599, _600), float3(_451, _452, _453),
                  float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), direct_roughness, float3(_382, _383, _384), _597, saturate(saturate(dot(float3(_598, _599, _600), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z))) * _723 + _724));
              _897 = diffuse_response.x; _898 = diffuse_response.y; _899 = diffuse_response.z;
            } else if (_731) {
            float _737 = saturate((saturate(dot(float3(_598, _599, _600), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z))) * _723) + _724);
            _897 = _737;
            _898 = _737;
            _899 = _737;
          } else {
            if (_597 == 2) {
              float _750 = saturate(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_451, _452, _453)) + 0.5f) * exp2(log2(abs(_725)) * cb12_037y);
              _897 = (_750 * _382);
              _898 = (_750 * _383);
              _899 = (_750 * _384);
            } else {
              int _757 = ((int)(uint)((int)(_600 > 0.0f))) << 1u;
              float _759 = float((int)(_757 + -1));
              float _761 = -1.0f / (_759 + _600);
              float _763 = (_599 * _598) * _761;
              float _767 = (((_598 * _598) * _759) * _761) + 1.0f;
              float _768 = _763 * _759;
              float _771 = float((int)(1 - _757)) * _598;
              float _774 = ((_599 * _599) * _761) + _759;
              float _775 = -0.0f - _599;
              float _777 = rsqrt(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
              float _778 = _777 * water_light.sun.x;
              float _779 = _777 * water_light.sun.y;
              float _780 = _777 * water_light.sun.z;
              float _783 = mad(_771, _780, mad(_768, _779, (_778 * _767)));
              float _786 = mad(_775, _780, mad(_774, _779, (_778 * _763)));
              float _789 = mad(_600, _780, mad(_599, _779, (_778 * _598)));
              float _791 = rsqrt(dot(float3(_783, _786, _789), float3(_783, _786, _789)));
              float _794 = _791 * _789;
              float _796 = rsqrt(dot(float3(_451, _452, _453), float3(_451, _452, _453)));
              float _797 = _796 * _451;
              float _798 = _796 * _452;
              float _799 = _796 * _453;
              float _802 = mad(_771, _799, mad(_768, _798, (_797 * _767)));
              float _805 = mad(_775, _799, mad(_774, _798, (_797 * _763)));
              float _808 = mad(_600, _799, mad(_599, _798, (_797 * _598)));
              float _810 = rsqrt(dot(float3(_802, _805, _808), float3(_802, _805, _808)));
              float _813 = _810 * _808;
              float _814 = _388.w * _388.w;
              float _817 = dot(float3((_791 * _783), (_791 * _786), _794), float3((_810 * _802), (_810 * _805), _813)) - (_813 * _794);
              if (_817 > 0.0f) {
                _823 = (_817 / max(_794, _813));
              } else {
                _823 = _817;
              }
              float _825 = (_814 * 0.2877933979034424f) + 1.0f;
              float _826 = 1.0f / _825;
              float _830 = ((_823 * _814) + 1.0f) * (_826 * 0.31830987334251404f);
              float _834 = 1.0f - _813;
              float _845 = 1.0f - _794;
              float _858 = _826 * ((_814 * 0.07248824834823608f) + 1.0f);
              float _865 = 1.0f - _858;
              float _880 = max(1.0000000116860974e-07f, (1.0f - ((((_845 * _814) * ((((((_845 * 0.07144299894571304f) + -0.332181453704834f) * _845) + 0.4918818771839142f) * _845) + 0.05710852891206741f)) + 1.0f) / _825))) * (max(1.0000000116860974e-07f, (1.0f - ((((_834 * _814) * ((((((_834 * 0.07144299894571304f) + -0.332181453704834f) * _834) + 0.4918818771839142f) * _834) + 0.05710852891206741f)) + 1.0f) / _825))) * 0.31830987334251404f);
              float _884 = max(1.0000000116860974e-07f, _865);
              float _892 = saturate(dot(float3(_598, _599, _600), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
              _897 = (_892 * (((_880 * (((_382 * _382) * _858) / (1.0f - (_865 * _382)))) / _884) + (_830 * _382)));
              _898 = (_892 * (((_880 * (((_383 * _383) * _858) / (1.0f - (_865 * _383)))) / _884) + (_830 * _383)));
              _899 = (_892 * (((_880 * (((_384 * _384) * _858) / (1.0f - (_865 * _384)))) / _884) + (_830 * _384)));
            }
          }
          float _903 = 1.0f - _484;
          float _904 = 1.0f - _485;
          float _905 = 1.0f - _486;
          if (cb12_221x > 0.0f) {
            float4 _910 = t43.SampleLevel(s10, float2(_388.w, dot(float3(_598, _599, _600), float3(_451, _452, _453))), 0.0f);
            float _916 = (_910.x * _484) + _910.y;
            float _917 = (_910.x * _485) + _910.y;
            float _918 = (_910.x * _486) + _910.y;
            _980 = min((_916 / max((1.0f - ((1.0f - _916) * ((_903 * 0.0476190485060215f) + _484))), 0.0010000000474974513f)), 1.0f);
            _981 = min((_917 / max((1.0f - ((1.0f - _917) * ((_904 * 0.0476190485060215f) + _485))), 0.0010000000474974513f)), 1.0f);
            _982 = min((_918 / max((1.0f - ((1.0f - _918) * ((_905 * 0.0476190485060215f) + _486))), 0.0010000000474974513f)), 1.0f);
          } else {
            float _944 = water_light.sun.x + _451;
            float _945 = water_light.sun.y + _452;
            float _946 = water_light.sun.z + _453;
            float _948 = rsqrt(dot(float3(_944, _945, _946), float3(_944, _945, _946)));
            float _955 = saturate(1.0f - abs(dot(float3((_948 * _944), (_948 * _945), (_948 * _946)), float3(_451, _452, _453))));
            float _956 = _955 * _955;
            float _966 = ((_956 * _956) * _955) * cb13_066x;
            float _972 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _388.w));
            _980 = (((_966 * max(0.0f, _903)) / _972) + _484);
            _981 = (((_966 * max(0.0f, _904)) / _972) + _485);
            _982 = (((_966 * max(0.0f, _905)) / _972) + _486);
          }
          float _986 = (1.0f - _980) * _897;
          float _987 = (1.0f - _981) * _898;
          float _988 = (1.0f - _982) * _899;
          bool _990 = ((_597 & -3) == 0);
          float _994 = select(_990, (_986 * 0.31830987334251404f), _986);
          float _995 = select(_990, (_987 * 0.31830987334251404f), _987);
          float _996 = select(_990, (_988 * 0.31830987334251404f), _988);

          [branch]
          if (_643 > 0.0f) {
            if (!(cb12_037z == 0.0f)) {
              float _1008 = dot(float3(_382, _383, _384), float3(0.21250000596046448f, 0.715399980545044f, 0.07209999859333038f));
              if (!_731) {
                _1023 = saturate(lerp(_1008, _382, cb12_036w));
                _1024 = saturate(lerp(_1008, _383, cb12_036w));
                _1025 = saturate(lerp(_1008, _384, cb12_036w));
              } else {
                _1023 = 1.0f;
                _1024 = 1.0f;
                _1025 = 1.0f;
              }
              float _1026 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_451, _452, _453));
              float _1040 = ((_643 * 0.31830987334251404f) * exp2(log2(abs(_725)) * cb12_036z)) * (exp2((_1026 + cb12_036y) * -4.328084945678711f) + exp2((_1026 + cb12_036x) * -1.4426950216293335f));
              _1093 = ((_1040 * _1023) + _994);
              _1094 = ((_1040 * _1024) + _995);
              _1095 = ((_1040 * _1025) + _996);
            } else {
              float _1049 = (_725 + 1.0f) * 0.5f;
              float _1050 = -0.0f - _451;
              float _1051 = -0.0f - _452;
              float _1052 = -0.0f - _453;
              float _1055 = (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_1050, _1051, _1052)) + 1.0f) * 0.5f;
              float _1058 = _1055 * _1055;
              float _1060 = select(_731, 1.0f, _382);
              float _1061 = select(_731, 1.0f, _383);
              float _1062 = select(_731, 1.0f, _384);
              float _1072 = cb12_036y * _643;
              float _1085 = (((_643 * 0.5f) * cb12_036w) * (dot(float3(_598, _599, _600), float3(_1050, _1051, _1052)) + 1.0f)) * ((((_1058 * _1058) - _1049) * cb12_036x) + _1049);
              _1093 = ((((((_1060 * _903) * cb12_036z) - _994) * _1072) + _994) + (_1085 * _1060));
              _1094 = ((((((_1061 * _904) * cb12_036z) - _995) * _1072) + _995) + (_1085 * _1061));
              _1095 = ((((((_1062 * _905) * cb12_036z) - _996) * _1072) + _996) + (_1085 * _1062));
            }
          } else {
            _1093 = _994;
            _1094 = _995;
            _1095 = _996;
          }
          float _1096 = _439 - cb12_000x;
          float _1097 = _440 - cb12_000y;
          float _1107 = saturate((cb12_219z * _441) + cb12_219w);
          float _1129 = saturate((cb12_219x * sqrt((_1096 * _1096) + (_1097 * _1097))) + cb12_219y);
          float _1143 = ((((lerp(cb13_062x, cb13_061x, _1107)) - cb13_001x) * _1129) + cb13_001x) * _706.y * water_light.direct.x;
          float _1145 = ((((lerp(cb13_062y, cb13_061y, _1107)) - cb13_001y) * _1129) + cb13_001y) * _706.y * water_light.direct.y;
          float _1147 = ((((lerp(cb13_062z, cb13_061z, _1107)) - cb13_001z) * _1129) + cb13_001z) * _706.y * water_light.direct.z;
          [branch]
          if (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_601, _602, _603)) > 0.0f) {
            float _1152 = water_light.sun.x + _451;
            float _1153 = water_light.sun.y + _452;
            float _1154 = water_light.sun.z + _453;
            float _1156 = rsqrt(dot(float3(_1152, _1153, _1154), float3(_1152, _1153, _1154)));
            float _1157 = _1156 * _1152;
            float _1158 = _1156 * _1153;
            float _1159 = _1156 * _1154;
            float _1161 = dot(float3(_601, _602, _603), float3(_451, _452, _453));
            float _1163 = saturate(dot(float3(_601, _602, _603), float3(_1157, _1158, _1159)));
            float _1164 = saturate(dot(float3(_601, _602, _603), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
            float _1165 = direct_roughness * direct_roughness;
            float _1166 = _1165 * _1165;
            float _1170 = ((_1163 * _1163) * (_1166 + -1.0f)) + 1.0f;
            float _1174 = abs(_1161);
            float _1175 = CSCustomConstants_048.y - CSCustomConstants_048.x;
            float _1181 = saturate(select((_1175 == 0.0f), 1e+05f, (1.0f / _1175)) * (_459 - CSCustomConstants_048.x));
            float _1182 = max(_709, _484);
            float _1183 = max(_709, _485);
            float _1184 = max(_709, _486);
            if (!_497) {
              _1202 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _484) - _1182) * _1181) + _1182));
              _1203 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _485) - _1183) * _1181) + _1183));
              _1204 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _486) - _1184) * _1181) + _1184));
            } else {
              _1202 = CSCustomConstants_064.x;
              _1203 = CSCustomConstants_064.x;
              _1204 = CSCustomConstants_064.x;
            }
            float _1208 = saturate(1.0f - abs(dot(float3(_1157, _1158, _1159), float3(_451, _452, _453))));
            float _1209 = _1208 * _1208;
            float _1222 = ((_1209 * _1209) * _1208) * cb13_066x;
            float _1228 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _388.w));
            [branch]
            if (cb12_221z > 0.0f) {
              float _1238 = saturate(_1161);
              float _1241 = (_1164 * 2.0f) * _1238;
              _1260 = ((((_1238 + _1164) - _1241) * _1165) + _1241);
            } else {
              float _1246 = 1.0f - _1166;
              _1260 = (((sqrt(((_1174 * _1174) * _1246) + _1166) * _1164) + 9.999999747378752e-05f) + (sqrt(((_1164 * _1164) * _1246) + _1166) * _1174));
            }
            float _1261 = 0.5f / _1260;
            float _1262 = GRAPHICS_PBR ? GraphicsDirectGGX(_1163, _1161, _1164, direct_roughness)
                  : _1261 * (_1166 / ((_1170 * _1170) * 3.1415200233459473f));
            float _1263 = _1262 * (((_1222 * max(0.0f, (_1202 - _484))) / _1228) + _484);
            float _1264 = _1262 * (((_1222 * max(0.0f, (_1203 - _485))) / _1228) + _485);
            float _1265 = _1262 * (((_1222 * max(0.0f, (_1204 - _486))) / _1228) + _486);
            if (cb12_221y > 0.0f) {
              float4 _1272 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_601, _602, _603), float3(_1261, _1261, _1261))), 0.0f);
              float _1278 = (_1272.x * _484) + _1272.y;
              float _1279 = (_1272.x * _485) + _1272.y;
              float _1280 = (_1272.x * _486) + _1272.y;
              _1315 = ((min((_1278 / max((1.0f - ((1.0f - _1278) * ((_903 * 0.0476190485060215f) + _484))), 0.0010000000474974513f)), 1.0f) / max(_1278, 9.999999747378752e-05f)) * _1263);
              _1316 = ((min((_1279 / max((1.0f - ((1.0f - _1279) * ((_904 * 0.0476190485060215f) + _485))), 0.0010000000474974513f)), 1.0f) / max(_1279, 9.999999747378752e-05f)) * _1264);
              _1317 = ((min((_1280 / max((1.0f - ((1.0f - _1280) * ((_905 * 0.0476190485060215f) + _486))), 0.0010000000474974513f)), 1.0f) / max(_1280, 9.999999747378752e-05f)) * _1265);
            } else {
              _1315 = _1263;
              _1316 = _1264;
              _1317 = _1265;
            }
            _1322 = (_1315 * _1164);
            _1323 = (_1316 * _1164);
            _1324 = (_1317 * _1164);
          } else {
            _1322 = 0.0f;
            _1323 = 0.0f;
            _1324 = 0.0f;
          }
          if (!(_513 == 0)) {
            float _1327 = dot(float3(_382, _383, _384), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
            float _1336 = 1.0010000467300415f - _1327;
            float _1368 = saturate(dot(float3(_604, _605, _606), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z))) * (exp2(log2(1.0f - saturate(dot(float3(_604, _605, _606), float3(_451, _452, _453)))) * 5.0f) * _642);
            _1373 = (_1368 * saturate((1.0f - exp2(log2(_1336 - ((_382 - _1327) * _641)) * cb12_223x)) * cb12_223y));
            _1374 = (_1368 * saturate((1.0f - exp2(log2(_1336 - ((_383 - _1327) * _641)) * cb12_223x)) * cb12_223y));
            _1375 = (_1368 * saturate((1.0f - exp2(log2(_1336 - ((_384 - _1327) * _641)) * cb12_223x)) * cb12_223y));
          } else {
            _1373 = 0.0f;
            _1374 = 0.0f;
            _1375 = 0.0f;
          }
          _1383 = ((_1373 + _1322) * _1143);
          _1384 = ((_1374 + _1323) * _1145);
          _1385 = ((_1375 + _1324) * _1147);
          _1386 = (_1143 * _1093);
          _1387 = (_1145 * _1094);
          _1388 = (_1147 * _1095);
        } else {
          _1383 = 0.0f;
          _1384 = 0.0f;
          _1385 = 0.0f;
          _1386 = 0.0f;
          _1387 = 0.0f;
          _1388 = 0.0f;
        }
      } else {
        _1383 = 0.0f;
        _1384 = 0.0f;
        _1385 = 0.0f;
        _1386 = 0.0f;
        _1387 = 0.0f;
        _1388 = 0.0f;
      }
      if (_504 == 0) {
        _1395 = cb12_071x;
      } else {
        _1395 = 1.0f;
      }
      if (CSCustomConstants_128.x > 0.0f) {
        uint4 _1398 = 0u; t17.GetDimensions(0u, _1398.x, _1398.y, _1398.z, _1398.w);
        if ((int)((uint)_44 < (uint)(int)(_1398.x)) && (int)((uint)_45 < (uint)(int)(_1398.y))) {
          int _1406 = min((int)(_1398.z), 8);
          if (!(_1406 == 0)) {
            uint _1409 = t17.Load(int4(_44, _45, 0, 0));
            _1412 = _1409.x;
          } else {
            _1412 = 0;
          }
          if ((uint)_1406 > (uint)1) {
            uint _1415 = t17.Load(int4(_44, _45, 1, 0));
            _1418 = _1415.x;
          } else {
            _1418 = 0;
          }
          if ((uint)_1406 > (uint)2) {
            uint _1421 = t17.Load(int4(_44, _45, 2, 0));
            _1424 = _1421.x;
          } else {
            _1424 = 0;
          }
          if ((uint)_1406 > (uint)3) {
            uint _1427 = t17.Load(int4(_44, _45, 3, 0));
            _1430 = _1427.x;
          } else {
            _1430 = 0;
          }
          if ((uint)_1406 > (uint)4) {
            uint _1433 = t17.Load(int4(_44, _45, 4, 0));
            _1436 = _1433.x;
          } else {
            _1436 = 0;
          }
          if ((uint)_1406 > (uint)5) {
            uint _1439 = t17.Load(int4(_44, _45, 5, 0));
            _1442 = _1439.x;
          } else {
            _1442 = 0;
          }
          if ((uint)_1406 > (uint)6) {
            uint _1445 = t17.Load(int4(_44, _45, 6, 0));
            _1448 = _1445.x;
          } else {
            _1448 = 0;
          }
          if ((uint)_1406 > (uint)7) {
            uint _1451 = t17.Load(int4(_44, _45, 7, 0));
            _1454 = _1430;
            _1455 = _1424;
            _1456 = _1418;
            _1457 = _1412;
            _1458 = _1451.x;
            _1459 = _1448;
            _1460 = _1442;
            _1461 = _1436;
            _1462 = _1406;
          } else {
            _1454 = _1430;
            _1455 = _1424;
            _1456 = _1418;
            _1457 = _1412;
            _1458 = 0;
            _1459 = _1448;
            _1460 = _1442;
            _1461 = _1436;
            _1462 = _1406;
          }
        } else {
          _1454 = 0;
          _1455 = 0;
          _1456 = 0;
          _1457 = 0;
          _1458 = 0;
          _1459 = 0;
          _1460 = 0;
          _1461 = 0;
          _1462 = 0;
        }
      } else {
        _1454 = 0;
        _1455 = 0;
        _1456 = 0;
        _1457 = 0;
        _1458 = 0;
        _1459 = 0;
        _1460 = 0;
        _1461 = 0;
        _1462 = 0;
      }
      int _1463 = _global_3;
      if (!(_1463 == 0)) {
        _1501 = _1386;
        _1502 = _1387;
        _1503 = _1388;
        _1504 = _1383;
        _1505 = _1384;
        _1506 = _1385;
        _1507 = 0;
        while(true) {
          int _1509 = _global_2[_1507];
          float _1512 = t18[_1509].LightParams_000.x;
          float _1513 = t18[_1509].LightParams_000.y;
          float _1514 = t18[_1509].LightParams_000.z;
          float _1515 = _1512 - _439;
          float _1516 = _1513 - _440;
          float _1517 = _1514 - _441;
          uint _1518 = _1509 + 1u;
          if (!(_1462 == 0)) {
            if (!((_1457 & 511) == _1518)) {
              if (!((uint)_1462 < (uint)2)) {
                if (!((_1456 & 511) == _1518)) {
                  if (!((uint)_1462 < (uint)3)) {
                    if (!((_1455 & 511) == _1518)) {
                      if (!((uint)_1462 < (uint)4)) {
                        if (!((_1454 & 511) == _1518)) {
                          if (!((uint)_1462 < (uint)5)) {
                            if (!((_1461 & 511) == _1518)) {
                              if (!((uint)_1462 < (uint)6)) {
                                if (!((_1460 & 511) == _1518)) {
                                  if (!((uint)_1462 < (uint)7)) {
                                    if (!((_1459 & 511) == _1518)) {
                                      if ((int)((uint)_1462 > (uint)7) && (int)((_1458 & 511) == _1518)) {
                                        _1559 = _1458;
                                        _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                                        _1566 = true;
                                      } else {
                                        _1565 = 1.0f;
                                        _1566 = false;
                                      }
                                    } else {
                                      _1559 = _1459;
                                      _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                                      _1566 = true;
                                    }
                                  } else {
                                    _1565 = 1.0f;
                                    _1566 = false;
                                  }
                                } else {
                                  _1559 = _1460;
                                  _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                                  _1566 = true;
                                }
                              } else {
                                _1565 = 1.0f;
                                _1566 = false;
                              }
                            } else {
                              _1559 = _1461;
                              _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                              _1566 = true;
                            }
                          } else {
                            _1565 = 1.0f;
                            _1566 = false;
                          }
                        } else {
                          _1559 = _1454;
                          _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                          _1566 = true;
                        }
                      } else {
                        _1565 = 1.0f;
                        _1566 = false;
                      }
                    } else {
                      _1559 = _1455;
                      _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                      _1566 = true;
                    }
                  } else {
                    _1565 = 1.0f;
                    _1566 = false;
                  }
                } else {
                  _1559 = _1456;
                  _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
                  _1566 = true;
                }
              } else {
                _1565 = 1.0f;
                _1566 = false;
              }
            } else {
              _1559 = _1457;
              _1565 = (float((uint)((uint)(((uint)(_1559) >> 9) & 127))) * 0.007874015718698502f);
              _1566 = true;
            }
          } else {
            _1565 = 1.0f;
            _1566 = false;
          }
          float _1572 = sqrt(((_1515 * _1515) + (_1516 * _1516)) + (_1517 * _1517));
          float _1575 = t18[_1509].LightParams_080.x;
          float _1577 = t18[_1509].LightParams_000.w;
          float _1578 = _1572 / _1577;
          float _1579 = _1578 * _1578;
          float _1582 = saturate(1.0f - (_1579 * _1579));
          float _1585 = t18[_1509].LightParams_048.w;
          int _1586 = asint(_1585);
          bool _1588 = ((_1586 & 1) != 0);
          float _1589 = t18[_1509].LightParams_080.z;
          bool _1590 = (_1589 > 0.0f);
          float _1592 = t18[_1509].LightParams_096.x;
          float _1595 = t18[_1509].LightParams_144.x;
          int _1596 = asint(_1595);
          bool _1598 = ((_1596 & 1) != 0);
          float _1600 = (_1582 * _1582) / (((_1572 * _1572) * _1575) + 1.0f);
          if (_1588) {
            float _1603 = t18[_1509].LightParams_032.x;
            float _1604 = t18[_1509].LightParams_032.y;
            float _1605 = t18[_1509].LightParams_032.z;
            float _1607 = rsqrt(dot(float3(_1515, _1516, _1517), float3(_1515, _1516, _1517)));
            float _1616 = t18[_1509].LightParams_064.w;
            float _1617 = t18[_1509].LightParams_064.y;
            float _1619 = t18[_1509].LightParams_064.z;
            _1627 = (exp2(log2(saturate((_1617 * dot(float3((-0.0f - (_1515 * _1607)), (-0.0f - (_1516 * _1607)), (-0.0f - (_1517 * _1607))), float3(_1603, _1604, _1605))) + _1619)) * _1616) * _1600);
          } else {
            _1627 = _1600;
          }
          bool _1628 = (_1627 > 0.0f);
          if (_1566 && _1628) {
            _1633 = saturate(_1565);
          } else {
            _1633 = 1.0f;
          }
          if (((int)(_1590 || _1598)) && _1628) {
            float _1637 = -0.0f - _1515;
            float _1638 = -0.0f - _1516;
            float _1639 = -0.0f - _1517;
            if (_1588) {
              float _1642 = t18[_1509].LightParams_032.x;
              float _1643 = t18[_1509].LightParams_032.y;
              float _1644 = t18[_1509].LightParams_032.z;
              float _1646 = t18[_1509].LightParams_112.y;
              float _1647 = t18[_1509].LightParams_112.z;
              float _1648 = t18[_1509].LightParams_112.w;
              float _1667 = t18[_1509].LightParams_112.x;
              float _1669 = t18[_1509].LightParams_144.z;
              _1843 = mad(((_1647 * _1642) - (_1646 * _1643)), _1639, mad(((_1646 * _1644) - (_1648 * _1642)), _1638, (((_1648 * _1643) - (_1647 * _1644)) * _1637)));
              _1844 = mad(_1648, _1639, mad(_1647, _1638, (_1646 * _1637)));
              _1845 = mad(_1644, _1639, mad(_1643, _1638, (_1642 * _1637)));
              _1846 = _1667;
              _1847 = asint(_1669);
            } else {
              if (_1598) {
                float _1674 = t18[_1509].LightParams_064.y;
                float _1675 = t18[_1509].LightParams_064.z;
                float _1676 = t18[_1509].LightParams_064.w;
                float _1678 = t18[_1509].LightParams_032.x;
                float _1679 = t18[_1509].LightParams_032.y;
                float _1680 = t18[_1509].LightParams_032.z;
                float _1692 = mad(((_1678 * _1675) - (_1679 * _1674)), _1639, mad(((_1680 * _1674) - (_1678 * _1676)), _1638, (((_1679 * _1676) - (_1680 * _1675)) * _1637)));
                float _1695 = mad(_1680, _1639, mad(_1679, _1638, (_1678 * _1637)));
                float _1698 = mad(_1676, _1639, mad(_1675, _1638, (_1674 * _1637)));
                float _1699 = -0.0f - _1692;
                float _1700 = -0.0f - _1695;
                float _1701 = -0.0f - _1698;
                float _1702 = _1699 / _1572;
                float _1703 = _1700 / _1572;
                float _1704 = _1701 / _1572;
                float _1705 = abs(_1702);
                float _1706 = abs(_1703);
                float _1707 = abs(_1704);
                bool _1711 = (_1705 > max(_1706, _1707));
                if (!((_1596 & 4) == 0)) {
                  if (_1711) {
                    if (_1702 > 0.0f) {
                      float _1717 = t18[_1509].LightParams_112.x;
                      _1741 = _1695;
                      _1742 = _1698;
                      _1743 = _1699;
                      _1744 = _1717;
                    } else {
                      float _1720 = t18[_1509].LightParams_112.y;
                      _1741 = _1700;
                      _1742 = _1698;
                      _1743 = _1692;
                      _1744 = _1720;
                    }
                  } else {
                    if (_1706 > max(_1705, _1707)) {
                      if (_1703 > 0.0f) {
                        float _1728 = t18[_1509].LightParams_112.z;
                        _1741 = _1699;
                        _1742 = _1698;
                        _1743 = _1700;
                        _1744 = _1728;
                      } else {
                        float _1731 = t18[_1509].LightParams_112.w;
                        _1741 = _1692;
                        _1742 = _1698;
                        _1743 = _1695;
                        _1744 = _1731;
                      }
                    } else {
                      if (_1704 > 0.0f) {
                        float _1736 = t18[_1509].LightParams_128.x;
                        _1741 = _1692;
                        _1742 = _1695;
                        _1743 = _1701;
                        _1744 = _1736;
                      } else {
                        float _1739 = t18[_1509].LightParams_128.y;
                        _1741 = _1692;
                        _1742 = _1700;
                        _1743 = _1698;
                        _1744 = _1739;
                      }
                    }
                  }
                  float _1746 = t18[_1509].LightParams_144.z;
                  _1843 = _1741;
                  _1844 = _1742;
                  _1845 = _1743;
                  _1846 = _1744;
                  _1847 = asint(_1746);
                } else {
                  if (_1711) {
                    if (_1702 > 0.0f) {
                      float _1753 = t18[_1509].LightParams_112.x;
                      float _1755 = t18[_1509].LightParams_144.z;
                      _1843 = _1695;
                      _1844 = _1698;
                      _1845 = _1699;
                      _1846 = _1753;
                      _1847 = asint(_1755);
                    } else {
                      float _1759 = t18[_1509].LightParams_112.y;
                      float _1761 = t18[_1509].LightParams_144.z;
                      _1843 = _1700;
                      _1844 = _1698;
                      _1845 = _1692;
                      _1846 = _1759;
                      _1847 = ((uint)((uint)(asint(_1761))) >> 10);
                    }
                  } else {
                    if (_1706 > max(_1705, _1707)) {
                      if (_1703 > 0.0f) {
                        float _1771 = t18[_1509].LightParams_112.z;
                        float _1773 = t18[_1509].LightParams_144.z;
                        _1843 = _1699;
                        _1844 = _1698;
                        _1845 = _1700;
                        _1846 = _1771;
                        _1847 = ((uint)((uint)(asint(_1773))) >> 20);
                      } else {
                        float _1778 = t18[_1509].LightParams_112.w;
                        float _1780 = t18[_1509].LightParams_144.w;
                        _1843 = _1692;
                        _1844 = _1698;
                        _1845 = _1695;
                        _1846 = _1778;
                        _1847 = asint(_1780);
                      }
                    } else {
                      if (_1704 > 0.0f) {
                        float _1786 = t18[_1509].LightParams_128.x;
                        float _1788 = t18[_1509].LightParams_144.w;
                        _1843 = _1692;
                        _1844 = _1695;
                        _1845 = _1701;
                        _1846 = _1786;
                        _1847 = ((uint)((uint)(asint(_1788))) >> 10);
                      } else {
                        float _1793 = t18[_1509].LightParams_128.y;
                        float _1795 = t18[_1509].LightParams_144.w;
                        _1843 = _1692;
                        _1844 = _1700;
                        _1845 = _1698;
                        _1846 = _1793;
                        _1847 = ((uint)((uint)(asint(_1795))) >> 20);
                      }
                    }
                  }
                }
              } else {
                float _1799 = _1515 / _1572;
                float _1800 = _1516 / _1572;
                float _1801 = _1517 / _1572;
                float _1802 = abs(_1799);
                float _1803 = abs(_1800);
                float _1804 = abs(_1801);
                if (_1802 > max(_1803, _1804)) {
                  if (_1799 > 0.0f) {
                    float _1811 = t18[_1509].LightParams_112.x;
                    _1835 = _1638;
                    _1836 = _1639;
                    _1837 = _1515;
                    _1838 = _1811;
                  } else {
                    float _1814 = t18[_1509].LightParams_112.y;
                    _1835 = _1516;
                    _1836 = _1639;
                    _1837 = _1637;
                    _1838 = _1814;
                  }
                } else {
                  if (_1803 > max(_1802, _1804)) {
                    if (_1800 > 0.0f) {
                      float _1822 = t18[_1509].LightParams_112.z;
                      _1835 = _1515;
                      _1836 = _1639;
                      _1837 = _1516;
                      _1838 = _1822;
                    } else {
                      float _1825 = t18[_1509].LightParams_112.w;
                      _1835 = _1637;
                      _1836 = _1639;
                      _1837 = _1638;
                      _1838 = _1825;
                    }
                  } else {
                    if (_1801 > 0.0f) {
                      float _1830 = t18[_1509].LightParams_128.x;
                      _1835 = _1637;
                      _1836 = _1638;
                      _1837 = _1517;
                      _1838 = _1830;
                    } else {
                      float _1833 = t18[_1509].LightParams_128.y;
                      _1835 = _1637;
                      _1836 = _1516;
                      _1837 = _1639;
                      _1838 = _1833;
                    }
                  }
                }
                float _1840 = t18[_1509].LightParams_144.z;
                _1843 = _1835;
                _1844 = _1836;
                _1845 = _1837;
                _1846 = _1838;
                _1847 = asint(_1840);
              }
            }
            float _1848 = t18[_1509].LightParams_080.y;
            float _1855 = (((_1843 * _1848) / _1845) * 0.5f) + 0.5f;
            float _1856 = 0.5f - ((mad(_1848, _1844, 0.0f) / _1845) * 0.5f);
            if (_1590) {
              int _1858 = asint(_1846);
              int _1860 = ((uint)(_1858) >> 18) & 4092;
              float _1861 = float((uint)_1860);
              [branch]
              if (!(_1860 == 0)) {
                if (!_1566) {
                  float _1883 = t9.SampleLevel(s10, float3((cb13_067x * ((_1855 * _1861) + float((uint)((uint)(((int)(_1858 << 2u)) & 4092))))), (cb13_067x * ((_1856 * _1861) + float((uint)((uint)(((uint)(_1858) >> 8) & 4092))))), float((uint)((uint)((uint)(_1858) >> 30)))), 0.0f);
                  _1892 = (saturate(exp2((_1883.x - (_1578 * 0.9900000095367432f)) * 144.26950073242188f)) * _1633);
                } else {
                  _1892 = _1633;
                }
              } else {
                _1892 = _1633;
              }
            } else {
              _1892 = _1633;
            }
            if (_1598) {
              bool _1895 = ((_1596 & 2) != 0);
              if (_1895) {
                _1905 = (_1847 & 1023);
                _1906 = 0;
              } else {
                _1905 = (_1847 & 255);
                _1906 = (((uint)(_1847) >> 8) & 3);
              }
              float _1909 = t18[_1509].LightParams_144.y;
              float _1911 = floor(_1909) + float((uint)_1905);
              float4 _1915 = t42.SampleLevel(s10, float3(_1855, _1856, _1911), 0.0f);
              _28[0] = _1915.x;
              _28[1] = _1915.y;
              _28[2] = _1915.z;
              _28[3] = _1915.w;
              if (!((_1596 & 8) == 0)) {
                float4 _1926 = t42.SampleLevel(s10, float3(_1855, _1856, (_1911 + 1.0f)), 0.0f);
                float _1931 = frac(_1909);
                float _1940 = ((_1926.x - _1915.x) * _1931) + _1915.x;
                float _1941 = ((_1926.y - _1915.y) * _1931) + _1915.y;
                float _1942 = ((_1926.z - _1915.z) * _1931) + _1915.z;
                _28[0] = _1940;
                _28[1] = _1941;
                _28[2] = _1942;
                _28[3] = (lerp(_1915.w, _1926.w, _1931));
                _1945 = _1942;
                _1946 = _1941;
                _1947 = _1940;
              } else {
                _1945 = _1915.z;
                _1946 = _1915.y;
                _1947 = _1915.x;
              }
              if (!_1895) {
                float _1950 = _28[_1906];
                _1952 = _1950;
                _1953 = _1950;
                _1954 = _1950;
              } else {
                _1952 = _1947;
                _1953 = _1946;
                _1954 = _1945;
              }
              _1956 = _1892;
              _1957 = _1952;
              _1958 = _1953;
              _1959 = _1954;
            } else {
              _1956 = _1892;
              _1957 = 1.0f;
              _1958 = 1.0f;
              _1959 = 1.0f;
            }
          } else {
            _1956 = _1633;
            _1957 = 1.0f;
            _1958 = 1.0f;
            _1959 = 1.0f;
          }
          if ((int)(_1592 > 0.0f) && _1628) {
            if (!_1566) {
              float _1965 = t18[_1509].LightParams_096.y;
              float _1966 = t10.SampleLevel(s10, float4(_1515, _1516, _1517, _1965), 0.0f);
              _1976 = (saturate(exp2((_1966.x - (_1578 * 0.9900000095367432f)) * 144.26950073242188f)) * _1956);
              float _1977 = t18[_1509].LightParams_080.w;
              _1979 = _1976;
              _1980 = _1977;
            } else {
              _1979 = _1956;
              _1980 = 1.0f;
            }
          } else {
            if (!_1566) {
              _1976 = _1956;
              float _1977 = t18[_1509].LightParams_080.w;
              _1979 = _1976;
              _1980 = _1977;
            } else {
              _1979 = _1956;
              _1980 = 1.0f;
            }
          }
          if ((int)(_706.z == 1.0f) || (int)((_1586 & 2048) != 0)) {
            _1992 = cb12_071y;
          } else {
            _1992 = 0.0f;
          }
          if (((int)(!(_706.z == 1.0f))) || (int)((_1586 & 4096) != 0)) {
            _2001 = cb12_071z;
          } else {
            _2001 = 0.0f;
          }
          float _2004 = ((((_1980 * (_1979 + -1.0f)) + 1.0f) * _1627) * _1992) * _2001;
          float _2005 = _2004 * _1957;
          float _2006 = _2004 * _1958;
          float _2007 = _2004 * _1959;
          [branch]
          if ((int)(_2007 > 0.0f) || ((int)((int)(_2005 > 0.0f) || (int)(_2006 > 0.0f)))) {
            bool _2019 = ((int)_1586 < (int)0);
            float _2020 = select(_2019, _1395, 1.0f);
            float _2028 = rsqrt(dot(float3(_1515, _1516, _1517), float3(_1515, _1516, _1517)));
            float _2029 = _2028 * _1515;
            float _2030 = _2028 * _1516;
            float _2031 = _2028 * _1517;
            bool _2032 = (_597 == 0);
            [branch]
            if (GRAPHICS_PBR && _597 != 2) {
              // Preserve native albedo/normalization, then retain the original
              // Fresnel complement, transmission, visibility and light units.
              float3 diffuse_response = GraphicsDiffuseResponse(float3(_598, _599, _600), float3(_451, _452, _453),
                  float3(_2029, _2030, _2031), direct_roughness, float3(_382, _383, _384), _597, saturate(dot(float3(_598, _599, _600), float3(_2029, _2030, _2031))));
              _2197 = diffuse_response.x; _2198 = diffuse_response.y; _2199 = diffuse_response.z;
            } else if (_2032) {
              float _2036 = saturate(saturate(dot(float3(_598, _599, _600), float3(_2029, _2030, _2031))));
              _2197 = _2036;
              _2198 = _2036;
              _2199 = _2036;
            } else {
              if (_597 == 2) {
                float _2050 = saturate(dot(float3(_2029, _2030, _2031), float3(_451, _452, _453)) + 0.5f) * exp2(log2(abs(dot(float3(_2029, _2030, _2031), float3(_598, _599, _600)))) * cb12_037y);
                _2197 = (_2050 * _382);
                _2198 = (_2050 * _383);
                _2199 = (_2050 * _384);
              } else {
                int _2057 = ((int)(uint)((int)(_600 > 0.0f))) << 1u;
                float _2059 = float((int)(_2057 + -1));
                float _2061 = -1.0f / (_2059 + _600);
                float _2063 = (_599 * _598) * _2061;
                float _2067 = (((_598 * _598) * _2059) * _2061) + 1.0f;
                float _2068 = _2063 * _2059;
                float _2071 = float((int)(1 - _2057)) * _598;
                float _2074 = ((_599 * _599) * _2061) + _2059;
                float _2075 = -0.0f - _599;
                float _2077 = rsqrt(dot(float3(_2029, _2030, _2031), float3(_2029, _2030, _2031)));
                float _2078 = _2077 * _2029;
                float _2079 = _2077 * _2030;
                float _2080 = _2077 * _2031;
                float _2083 = mad(_2071, _2080, mad(_2068, _2079, (_2078 * _2067)));
                float _2086 = mad(_2075, _2080, mad(_2074, _2079, (_2078 * _2063)));
                float _2089 = mad(_600, _2080, mad(_599, _2079, (_2078 * _598)));
                float _2091 = rsqrt(dot(float3(_2083, _2086, _2089), float3(_2083, _2086, _2089)));
                float _2094 = _2091 * _2089;
                float _2096 = rsqrt(dot(float3(_451, _452, _453), float3(_451, _452, _453)));
                float _2097 = _2096 * _451;
                float _2098 = _2096 * _452;
                float _2099 = _2096 * _453;
                float _2102 = mad(_2071, _2099, mad(_2068, _2098, (_2097 * _2067)));
                float _2105 = mad(_2075, _2099, mad(_2074, _2098, (_2097 * _2063)));
                float _2108 = mad(_600, _2099, mad(_599, _2098, (_2097 * _598)));
                float _2110 = rsqrt(dot(float3(_2102, _2105, _2108), float3(_2102, _2105, _2108)));
                float _2113 = _2110 * _2108;
                float _2114 = _388.w * _388.w;
                float _2117 = dot(float3((_2091 * _2083), (_2091 * _2086), _2094), float3((_2110 * _2102), (_2110 * _2105), _2113)) - (_2113 * _2094);
                if (_2117 > 0.0f) {
                  _2123 = (_2117 / max(_2094, _2113));
                } else {
                  _2123 = _2117;
                }
                float _2125 = (_2114 * 0.2877933979034424f) + 1.0f;
                float _2126 = 1.0f / _2125;
                float _2130 = ((_2123 * _2114) + 1.0f) * (_2126 * 0.31830987334251404f);
                float _2134 = 1.0f - _2113;
                float _2145 = 1.0f - _2094;
                float _2158 = _2126 * ((_2114 * 0.07248824834823608f) + 1.0f);
                float _2165 = 1.0f - _2158;
                float _2180 = max(1.0000000116860974e-07f, (1.0f - ((((_2145 * _2114) * ((((((_2145 * 0.07144299894571304f) + -0.332181453704834f) * _2145) + 0.4918818771839142f) * _2145) + 0.05710852891206741f)) + 1.0f) / _2125))) * (max(1.0000000116860974e-07f, (1.0f - ((((_2134 * _2114) * ((((((_2134 * 0.07144299894571304f) + -0.332181453704834f) * _2134) + 0.4918818771839142f) * _2134) + 0.05710852891206741f)) + 1.0f) / _2125))) * 0.31830987334251404f);
                float _2184 = max(1.0000000116860974e-07f, _2165);
                float _2192 = saturate(dot(float3(_598, _599, _600), float3(_2029, _2030, _2031)));
                _2197 = (_2192 * (((_2180 * (((_382 * _382) * _2158) / (1.0f - (_2165 * _382)))) / _2184) + (_2130 * _382)));
                _2198 = (_2192 * (((_2180 * (((_383 * _383) * _2158) / (1.0f - (_2165 * _383)))) / _2184) + (_2130 * _383)));
                _2199 = (_2192 * (((_2180 * (((_384 * _384) * _2158) / (1.0f - (_2165 * _384)))) / _2184) + (_2130 * _384)));
              }
            }
            float _2203 = 1.0f - _484;
            float _2204 = 1.0f - _485;
            float _2205 = 1.0f - _486;
            if (cb12_221x > 0.0f) {
              float4 _2210 = t43.SampleLevel(s10, float2(_388.w, dot(float3(_598, _599, _600), float3(_451, _452, _453))), 0.0f);
              float _2216 = (_2210.x * _484) + _2210.y;
              float _2217 = (_2210.x * _485) + _2210.y;
              float _2218 = (_2210.x * _486) + _2210.y;
              _2280 = min((_2216 / max((1.0f - ((1.0f - _2216) * ((_2203 * 0.0476190485060215f) + _484))), 0.0010000000474974513f)), 1.0f);
              _2281 = min((_2217 / max((1.0f - ((1.0f - _2217) * ((_2204 * 0.0476190485060215f) + _485))), 0.0010000000474974513f)), 1.0f);
              _2282 = min((_2218 / max((1.0f - ((1.0f - _2218) * ((_2205 * 0.0476190485060215f) + _486))), 0.0010000000474974513f)), 1.0f);
            } else {
              float _2244 = _2029 + _451;
              float _2245 = _2030 + _452;
              float _2246 = _2031 + _453;
              float _2248 = rsqrt(dot(float3(_2244, _2245, _2246), float3(_2244, _2245, _2246)));
              float _2255 = saturate(1.0f - abs(dot(float3((_2248 * _2244), (_2248 * _2245), (_2248 * _2246)), float3(_451, _452, _453))));
              float _2256 = _2255 * _2255;
              float _2266 = ((_2256 * _2256) * _2255) * cb13_066x;
              float _2272 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _388.w));
              _2280 = (((_2266 * max(0.0f, _2203)) / _2272) + _484);
              _2281 = (((_2266 * max(0.0f, _2204)) / _2272) + _485);
              _2282 = (((_2266 * max(0.0f, _2205)) / _2272) + _486);
            }
            float _2286 = (1.0f - _2280) * _2197;
            float _2287 = (1.0f - _2281) * _2198;
            float _2288 = (1.0f - _2282) * _2199;
            bool _2290 = ((_597 & -3) == 0);
            float _2294 = select(_2290, (_2286 * 0.31830987334251404f), _2286);
            float _2295 = select(_2290, (_2287 * 0.31830987334251404f), _2287);
            float _2296 = select(_2290, (_2288 * 0.31830987334251404f), _2288);

            [branch]
            if (_643 > 0.0f) {
              if (!(cb12_037z == 0.0f)) {
                float _2308 = dot(float3(_382, _383, _384), float3(0.21250000596046448f, 0.715399980545044f, 0.07209999859333038f));
                if (!_2032) {
                  _2323 = saturate(lerp(_2308, _382, cb12_036w));
                  _2324 = saturate(lerp(_2308, _383, cb12_036w));
                  _2325 = saturate(lerp(_2308, _384, cb12_036w));
                } else {
                  _2323 = 1.0f;
                  _2324 = 1.0f;
                  _2325 = 1.0f;
                }
                float _2326 = dot(float3(_2029, _2030, _2031), float3(_451, _452, _453));
                float _2341 = ((_643 * 0.31830987334251404f) * exp2(log2(abs(dot(float3(_2029, _2030, _2031), float3(_598, _599, _600)))) * cb12_036z)) * (exp2((_2326 + cb12_036y) * -4.328084945678711f) + exp2((_2326 + cb12_036x) * -1.4426950216293335f));
                _2395 = ((_2341 * _2323) + _2294);
                _2396 = ((_2341 * _2324) + _2295);
                _2397 = ((_2341 * _2325) + _2296);
              } else {
                float _2351 = (dot(float3(_2029, _2030, _2031), float3(_598, _599, _600)) + 1.0f) * 0.5f;
                float _2352 = -0.0f - _451;
                float _2353 = -0.0f - _452;
                float _2354 = -0.0f - _453;
                float _2357 = (dot(float3(_2029, _2030, _2031), float3(_2352, _2353, _2354)) + 1.0f) * 0.5f;
                float _2360 = _2357 * _2357;
                float _2362 = select(_2032, 1.0f, _382);
                float _2363 = select(_2032, 1.0f, _383);
                float _2364 = select(_2032, 1.0f, _384);
                float _2374 = cb12_036y * _643;
                float _2387 = (((_643 * 0.5f) * cb12_036w) * (dot(float3(_598, _599, _600), float3(_2352, _2353, _2354)) + 1.0f)) * ((((_2360 * _2360) - _2351) * cb12_036x) + _2351);
                _2395 = ((((((_2362 * _2203) * cb12_036z) - _2294) * _2374) + _2294) + (_2387 * _2362));
                _2396 = ((((((_2363 * _2204) * cb12_036z) - _2295) * _2374) + _2295) + (_2387 * _2363));
                _2397 = ((((((_2364 * _2205) * cb12_036z) - _2296) * _2374) + _2296) + (_2387 * _2364));
              }
            } else {
              _2395 = _2294;
              _2396 = _2295;
              _2397 = _2296;
            }
            float _2398 = t18[_1509].LightParams_048.x;
            float _2399 = t18[_1509].LightParams_048.y;
            float _2400 = t18[_1509].LightParams_048.z;
            float _2401 = (_2005 * _2020) * _2398;
            float _2403 = (_2006 * _2020) * _2399;
            float _2405 = (_2007 * _2020) * _2400;
            [branch]
            if (dot(float3(_2029, _2030, _2031), float3(_601, _602, _603)) > 0.0f) {
              float _2413 = _2029 + _451;
              float _2414 = _2030 + _452;
              float _2415 = _2031 + _453;
              float _2417 = rsqrt(dot(float3(_2413, _2414, _2415), float3(_2413, _2414, _2415)));
              float _2418 = _2417 * _2413;
              float _2419 = _2417 * _2414;
              float _2420 = _2417 * _2415;
              float _2422 = dot(float3(_601, _602, _603), float3(_451, _452, _453));
              float _2424 = saturate(dot(float3(_601, _602, _603), float3(_2418, _2419, _2420)));
              float _2425 = saturate(dot(float3(_601, _602, _603), float3(_2029, _2030, _2031)));
              float _2426 = direct_roughness * direct_roughness;
              float _2427 = _2426 * _2426;
              float _2431 = ((_2424 * _2424) * (_2427 + -1.0f)) + 1.0f;
              float _2435 = abs(_2422);
              float _2436 = CSCustomConstants_048.y - CSCustomConstants_048.x;
              float _2442 = saturate(select((_2436 == 0.0f), 1e+05f, (1.0f / _2436)) * (_459 - CSCustomConstants_048.x));
              float _2443 = max(CSCustomConstants_048.z, _484);
              float _2444 = max(CSCustomConstants_048.z, _485);
              float _2445 = max(CSCustomConstants_048.z, _486);
              if (!_497) {
                _2463 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _484) - _2443) * _2442) + _2443));
                _2464 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _485) - _2444) * _2442) + _2444));
                _2465 = select(_498, CSCustomConstants_064.y, (((max(CSCustomConstants_048.w, _486) - _2445) * _2442) + _2445));
              } else {
                _2463 = CSCustomConstants_064.x;
                _2464 = CSCustomConstants_064.x;
                _2465 = CSCustomConstants_064.x;
              }
              float _2469 = saturate(1.0f - abs(dot(float3(_2418, _2419, _2420), float3(_451, _452, _453))));
              float _2470 = _2469 * _2469;
              float _2483 = ((_2470 * _2470) * _2469) * cb13_066x;
              float _2489 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - _388.w));
              [branch]
              if (cb12_221z > 0.0f) {
                float _2499 = saturate(_2422);
                float _2502 = (_2425 * 2.0f) * _2499;
                _2521 = ((((_2499 + _2425) - _2502) * _2426) + _2502);
              } else {
                float _2507 = 1.0f - _2427;
                _2521 = (((sqrt(((_2435 * _2435) * _2507) + _2427) * _2425) + 9.999999747378752e-05f) + (sqrt(((_2425 * _2425) * _2507) + _2427) * _2435));
              }
              float _2522 = 0.5f / _2521;
              float _2523 = GRAPHICS_PBR ? GraphicsDirectGGX(_2424, _2422, _2425, direct_roughness)
                  : _2522 * (_2427 / ((_2431 * _2431) * 3.1415200233459473f));
              float _2524 = _2523 * (((_2483 * max(0.0f, (_2463 - _484))) / _2489) + _484);
              float _2525 = _2523 * (((_2483 * max(0.0f, (_2464 - _485))) / _2489) + _485);
              float _2526 = _2523 * (((_2483 * max(0.0f, (_2465 - _486))) / _2489) + _486);
              if (cb12_221y > 0.0f) {
                float4 _2533 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_601, _602, _603), float3(_2522, _2522, _2522))), 0.0f);
                float _2539 = (_2533.x * _484) + _2533.y;
                float _2540 = (_2533.x * _485) + _2533.y;
                float _2541 = (_2533.x * _486) + _2533.y;
                _2576 = ((min((_2539 / max((1.0f - ((1.0f - _2539) * ((_2203 * 0.0476190485060215f) + _484))), 0.0010000000474974513f)), 1.0f) / max(_2539, 9.999999747378752e-05f)) * _2524);
                _2577 = ((min((_2540 / max((1.0f - ((1.0f - _2540) * ((_2204 * 0.0476190485060215f) + _485))), 0.0010000000474974513f)), 1.0f) / max(_2540, 9.999999747378752e-05f)) * _2525);
                _2578 = ((min((_2541 / max((1.0f - ((1.0f - _2541) * ((_2205 * 0.0476190485060215f) + _486))), 0.0010000000474974513f)), 1.0f) / max(_2541, 9.999999747378752e-05f)) * _2526);
              } else {
                _2576 = _2524;
                _2577 = _2525;
                _2578 = _2526;
              }
              _2583 = (_2576 * _2425);
              _2584 = (_2577 * _2425);
              _2585 = (_2578 * _2425);
            } else {
              _2583 = 0.0f;
              _2584 = 0.0f;
              _2585 = 0.0f;
            }
            if (!(_513 == 0)) {
              float _2588 = dot(float3(_382, _383, _384), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
              float _2596 = 1.0010000467300415f - _2588;
              float _2628 = saturate(dot(float3(_604, _605, _606), float3(_2029, _2030, _2031))) * (exp2(log2(1.0f - saturate(dot(float3(_604, _605, _606), float3(_451, _452, _453)))) * 5.0f) * select((((int)(_497 || _498)) || _2019), 0.0f, (select(_505, cb12_223w, cb12_223z) * _642)));
              _2633 = (_2628 * saturate((1.0f - exp2(log2(_2596 - ((_382 - _2588) * _641)) * cb12_223x)) * cb12_223y));
              _2634 = (_2628 * saturate((1.0f - exp2(log2(_2596 - ((_383 - _2588) * _641)) * cb12_223x)) * cb12_223y));
              _2635 = (_2628 * saturate((1.0f - exp2(log2(_2596 - ((_384 - _2588) * _641)) * cb12_223x)) * cb12_223y));
            } else {
              _2633 = 0.0f;
              _2634 = 0.0f;
              _2635 = 0.0f;
            }
            _2646 = ((_2401 * _2395) + _1501);
            _2647 = ((_2403 * _2396) + _1502);
            _2648 = ((_2405 * _2397) + _1503);
            _2649 = ((_2401 * (_2633 + _2583)) + _1504);
            _2650 = ((_2403 * (_2634 + _2584)) + _1505);
            _2651 = ((_2405 * (_2635 + _2585)) + _1506);
          } else {
            _2646 = _1501;
            _2647 = _1502;
            _2648 = _1503;
            _2649 = _1504;
            _2650 = _1505;
            _2651 = _1506;
          }
          uint _2652 = _1507 + 1u;
          if ((uint)_2652 < (uint)_1463) {
            _1501 = _2646;
            _1502 = _2647;
            _1503 = _2648;
            _1504 = _2649;
            _1505 = _2650;
            _1506 = _2651;
            _1507 = _2652;
            continue;
          }
          break;
        }
        while(true) {
          _1468 = _2646;
          _1469 = _2647;
          _1470 = _2648;
          _1471 = _2649;
          _1472 = _2650;
          _1473 = _2651;
          break;
        }
      } else {
        _1468 = _1386;
        _1469 = _1387;
        _1470 = _1388;
        _1471 = _1383;
        _1472 = _1384;
        _1473 = _1385;
      }
      float4 _1478 = t16.Load(int3(_44, _45, 0));
      bool _1499 = (_706.z < 0.9900000095367432f);
      if (_1499) {
        _2658 = cb12_287w;
      } else {
        _2658 = 1.0f;
      }
      float _2662 = log2(((((((cb12_069z + -1.0f) * _643) + 1.0f) * (saturate((cb12_187x * _1478.x) + cb12_188x) + -1.0f)) + 1.0f) * cb12_069x) + cb12_069y);
      if (_1499) {
        _2669 = cb12_287w;
      } else {
        _2669 = 1.0f;
      }
      float _2674 = exp2((cb12_288z * _2658) * _2662) * cb12_184z;
      float _2678 = exp2((_2662 * cb12_288w) * _2669) * cb12_184w;
      _2683 = _597;
      _2684 = (_2674 * _1468);
      _2685 = (_2674 * _1469);
      _2686 = (_2674 * _1470);
      _2687 = (_2678 * _1471);
      _2688 = (_2678 * _1472);
      _2689 = (_2678 * _1473);
      if (_2683 == 0) {
        _2696 = (_2684 * _382);
        _2697 = (_2685 * _383);
        _2698 = (_2686 * _384);
      } else {
        _2696 = _2684;
        _2697 = _2685;
        _2698 = _2686;
      }
      float _2708 = max(0.0f, _2687) + max(0.0f, _2696);
      float _2709 = max(0.0f, _2688) + max(0.0f, _2697);
      float _2710 = max(0.0f, _2689) + max(0.0f, _2698);
      if (cb12_074x > 0.0f) {
        u0[int2(_44, _45)] = float4(_2708, _2709, _2710, 1.0f);
      } else {
        u0[int2(_44, _45)] = float4(_2708, _2709, _2710, 1.0f);
      }
      if ((uint)_47 < (uint)256) {
        if ((uint)_47 < (uint)_global_5) {
          _2730 = (_global_4[_47]);
        } else {
          _2730 = 256;
        }
        u2.Store(((int)(((uint((cb12_024x * _89) + _88) << 8u) + _47) << 2u)), asuint(_2730));
      }
    }
  } else {
    _2683 = _31;
    _2684 = 0.0f;
    _2685 = 0.0f;
    _2686 = 0.0f;
    _2687 = 0.0f;
    _2688 = 0.0f;
    _2689 = 0.0f;
    if (_2683 == 0) {
      _2696 = (_2684 * _382);
      _2697 = (_2685 * _383);
      _2698 = (_2686 * _384);
    } else {
      _2696 = _2684;
      _2697 = _2685;
      _2698 = _2686;
    }
    float _2708 = max(0.0f, _2687) + max(0.0f, _2696);
    float _2709 = max(0.0f, _2688) + max(0.0f, _2697);
    float _2710 = max(0.0f, _2689) + max(0.0f, _2698);
    if (cb12_074x > 0.0f) {
      u0[int2(_44, _45)] = float4(_2708, _2709, _2710, 1.0f);
    } else {
      u0[int2(_44, _45)] = float4(_2708, _2709, _2710, 1.0f);
    }
    if ((uint)_47 < (uint)256) {
      if ((uint)_47 < (uint)_global_5) {
        _2730 = (_global_4[_47]);
      } else {
        _2730 = 256;
      }
      u2.Store(((int)(((uint((cb12_024x * _89) + _88) << 8u) + _47) << 2u)), asuint(_2730));
    }
  }
}
