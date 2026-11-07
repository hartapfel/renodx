// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "shared.h"
#ifndef GRAPHICS_CLOUD_VISIBILITY
#define GRAPHICS_CLOUD_VISIBILITY(world, native) (native)
#endif
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

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t3 : register(t3);

Texture2DArray<float4> t14 : register(t14);

Texture2DArray<float> t19 : register(t19);

Texture2D<float4> t43 : register(t43);

Texture2DArray<float4> t28[2] : register(t28);

Texture2DArray<float3> t30[2] : register(t30);

Texture2D<uint> t32[2] : register(t32);

Texture2D<float4> t34[2] : register(t34);

Texture2DArray<uint> t38 : register(t38);

Texture2DArray<float> t8 : register(t8);

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

#define cb12_000x (cb12_raw[0].x)
#define cb12_287w (cb12_raw[287].w)
#define cb12_220x (cb12_raw[220].x)
#define cb12_024x (cb12_raw[24].x)
#define cb12_229z (cb12_raw[229].z)
#define cb12_000y (cb12_raw[0].y)
#define cb12_000z (cb12_raw[0].z)
#define cb12_074x (cb12_raw[74].x)
#define cb12_229x (cb12_raw[229].x)
#define cb12_071y (cb12_raw[71].y)
#define cb12_068x (cb12_raw[68].x)
#define cb12_071z (cb12_raw[71].z)
#define cb12_071x (cb12_raw[71].x)
#define cb12_229w (cb12_raw[229].w)
#define cb12_074y (cb12_raw[74].y)
#define cb12_229y (cb12_raw[229].y)
#define cb12_188x (cb12_raw[188].x)
#define cb12_221x (cb12_raw[221].x)
#define cb12_221z (cb12_raw[221].z)
#define cb12_221y (cb12_raw[221].y)
#define cb12_219z (cb12_raw[219].z)
#define cb12_219w (cb12_raw[219].w)
#define cb12_219x (cb12_raw[219].x)
#define cb12_219y (cb12_raw[219].y)
#define cb12_066x (cb12_raw[66].x)
#define cb12_069z (cb12_raw[69].z)
#define cb12_067x (cb12_raw[67].x)
#define cb12_067y (cb12_raw[67].y)
#define cb12_066w (cb12_raw[66].w)
#define cb12_068y (cb12_raw[68].y)
#define cb12_288y (cb12_raw[288].y)
#define cb12_100x (cb12_raw[100].x)
#define cb12_106x (cb12_raw[106].x)
#define cb12_111x (asint(cb12_raw[111].x))
#define cb12_184z (cb12_raw[184].z)
#define cb12_069y (cb12_raw[69].y)
#define cb12_184w (cb12_raw[184].w)
#define cb12_187x (cb12_raw[187].x)
#define cb12_069x (cb12_raw[69].x)
#define cb12_288z (cb12_raw[288].z)
#define cb12_288w (cb12_raw[288].w)

cbuffer cb4 : register(b4) {
  float cb4_000x : packoffset(c000.x);
  float cb4_001x : packoffset(c001.x);
  float cb4_002x : packoffset(c002.x);
  float cb4_002y : packoffset(c002.y);
  float cb4_003x : packoffset(c003.x);
  float cb4_004x : packoffset(c004.x);
  float cb4_004y : packoffset(c004.y);
  float cb4_004z : packoffset(c004.z);
  float cb4_005x : packoffset(c005.x);
  float cb4_006x : packoffset(c006.x);
  float cb4_007x : packoffset(c007.x);
  float cb4_007y : packoffset(c007.y);
  float cb4_007z : packoffset(c007.z);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
  float cb4_010x : packoffset(c010.x);
  float cb4_011x : packoffset(c011.x);
  float cb4_012x : packoffset(c012.x);
  float cb4_012y : packoffset(c012.y);
  float cb4_012z : packoffset(c012.z);
  float cb4_013x : packoffset(c013.x);
  float cb4_014x : packoffset(c014.x);
  float cb4_015x : packoffset(c015.x);
  float cb4_015y : packoffset(c015.y);
  float cb4_015z : packoffset(c015.z);
  float cb4_016x : packoffset(c016.x);
  float cb4_017x : packoffset(c017.x);
  float cb4_018x : packoffset(c018.x);
  float cb4_019x : packoffset(c019.x);
  float cb4_020x : packoffset(c020.x);
  float cb4_021x : packoffset(c021.x);
  float cb4_022x : packoffset(c022.x);
  float cb4_023x : packoffset(c023.x);
  float cb4_024x : packoffset(c024.x);
  float cb4_025x : packoffset(c025.x);
  float cb4_026x : packoffset(c026.x);
  float cb4_027x : packoffset(c027.x);
  float cb4_028x : packoffset(c028.x);
  float cb4_029x : packoffset(c029.x);
  float cb4_029y : packoffset(c029.y);
  float cb4_029z : packoffset(c029.z);
  float cb4_030x : packoffset(c030.x);
  float cb4_031x : packoffset(c031.x);
  float cb4_032x : packoffset(c032.x);
};

cbuffer cb7 : register(b7) {
  PROBE_GRID_DESC gridDesc_000[2] : packoffset(c000.x);
};

cbuffer cb13 : register(b13) {
  float4 cb13_raw[3589] : packoffset(c0);
};

#define cb13_067x (cb13_raw[67].x)
#define cb13_000z (cb13_raw[0].z)
#define cb13_001y (cb13_raw[1].y)
#define cb13_066z (cb13_raw[66].z)
#define cb13_010y (cb13_raw[10].y)
#define cb13_061y (cb13_raw[61].y)
#define cb13_000x (cb13_raw[0].x)
#define cb13_066x (cb13_raw[66].x)
#define cb13_010x (cb13_raw[10].x)
#define cb13_009z (cb13_raw[9].z)
#define cb13_061x (cb13_raw[61].x)
#define cb13_036x (cb13_raw[36].x)
#define cb13_000y (cb13_raw[0].y)
#define cb13_010z (cb13_raw[10].z)
#define cb13_009x (cb13_raw[9].x)
#define cb13_061z (cb13_raw[61].z)
#define cb13_062x (cb13_raw[62].x)
#define cb13_005z (cb13_raw[5].z)
#define cb13_062y (cb13_raw[62].y)
#define cb13_005y (cb13_raw[5].y)
#define cb13_062z (cb13_raw[62].z)
#define cb13_001x (cb13_raw[1].x)
#define cb13_066y (cb13_raw[66].y)
#define cb13_001z (cb13_raw[1].z)
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
#define cb13_007w (cb13_raw[7].w)
#define cb13_006x (cb13_raw[6].x)
#define cb13_006z (cb13_raw[6].z)
#define cb13_008y (cb13_raw[8].y)
#define cb13_007x (cb13_raw[7].x)
#define cb13_007z (cb13_raw[7].z)
#define cb13_008z (cb13_raw[8].z)
#define cb13_009y (cb13_raw[9].y)
#define cb13_009w (cb13_raw[9].w)
#define cb13_010w (cb13_raw[10].w)
#define cb13_066w (cb13_raw[66].w)
#define cb13_063x (cb13_raw[63].x)

SamplerState s11 : register(s11);

SamplerState s0 : register(s0);

SamplerState s14 : register(s14);

SamplerState s8 : register(s8);

SamplerState s10 : register(s10);

SamplerState s7 : register(s7);

struct OutputSignature {
  float4 SV_Target : SV_Target;
  float4 SV_Target_1 : SV_Target1;
  float4 SV_Target_2 : SV_Target2;
  float4 SV_Target_3 : SV_Target3;
  float4 SV_Target_4 : SV_Target4;
};

#include "lighting/contact/forward.hlsli"

OutputSignature main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2,
  linear float3 TEXCOORD_3 : TEXCOORD3,
  linear float3 TEXCOORD_4 : TEXCOORD4,
  linear float3 TEXCOORD_5 : TEXCOORD5,
  noperspective float4 SV_Position : SV_Position
) {
  float4 SV_Target = 0;
  float4 SV_Target_1 = 0;
  float4 SV_Target_2 = 0;
  float4 SV_Target_3 = 0;
  float4 SV_Target_4 = 0;
  bool _3784;
  bool _3511;
  float _56[4];
  float4 _63 = t0.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _68 = cb4_002x * TEXCOORD_1.x;
  float _69 = cb4_002y * TEXCOORD_1.y;
  float4 _72 = t1.Sample(s0, float2(_68, _69));
  float _80 = cb1_036x - TEXCOORD_4.x;
  float _81 = cb1_036y - TEXCOORD_4.y;
  float _82 = cb1_036z - TEXCOORD_4.z;
  float _92 = saturate(cb4_003x - sqrt(((_80 * _80) + (_81 * _81)) + (_82 * _82)));
  float _96 = ((_72.w + -0.5f) * 0.5f) * _92;
  float _101 = max(0.0f, (1.0f - (((cb4_001x * cb4_000x) * _96) * saturate((_63.x + -0.550000011920929f) * 2.222222328186035f))));
  float4 _104 = t2.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _132 = exp2(log2((pow(_104.x, 2.200000047683716f)) * _101) * 0.4545449912548065f);
  float _133 = exp2(log2((pow(_104.y, 2.200000047683716f)) * _101) * 0.4545449912548065f);
  float _134 = exp2(log2((pow(_104.z, 2.200000047683716f)) * _101) * 0.4545449912548065f);
  float _136 = (_133 + _132) + _134;
  float _139 = (cb4_005x + -1.0f) * 0.5f;
  float _147 = saturate((((1.0f - (_136 * 0.6665999889373779f)) * saturate(_139)) + (_136 * 0.33329999446868896f)) * abs(_139));
  float4 _168 = t3.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _175 = (_168.x + -0.5f) * 2.0f;
  float _176 = (_168.y + -0.5f) * 2.0f;
  float4 _180 = t1.Sample(s0, float2(_68, _69));
  float _187 = (_180.z + -0.5f) * 2.0f;
  float _191 = (_63.x * 2.0f) * cb4_001x;
  float _192 = _191 * (_180.x + -0.5f);
  float _193 = _191 * (_180.y + -0.5f);
  float _195 = rsqrt(dot(float3(_192, _193, _187), float3(_192, _193, _187)));
  float _197 = ((_168.z + -0.5f) * 2.0f) + 1.0f;
  float _199 = _195 * _92;
  float _200 = _192 * _199;
  float _201 = _193 * _199;
  float _203 = (((_187 * _195) + -0.5f) * _92) + 0.5f;
  float _205 = rsqrt(dot(float3(_200, _201, _203), float3(_200, _201, _203)));
  float _206 = _203 * _205;
  float _207 = -0.0f - _205;
  float _208 = _200 * _207;
  float _209 = _201 * _207;
  float _210 = dot(float3(_175, _176, _197), float3(_208, _209, _206));
  float _215 = (_210 * _175) - (_208 * _197);
  float _216 = (_210 * _176) - (_209 * _197);
  float _218 = (_210 - _206) * _197;
  float _220 = rsqrt(dot(float3(_215, _216, _218), float3(_215, _216, _218)));
  float _221 = _215 * _220;
  float _222 = _216 * _220;
  float _223 = _218 * _220;
  float _236 = ((_221 * TEXCOORD_5.x) + (_222 * TEXCOORD.w)) + (_223 * TEXCOORD_3.x);
  float _237 = ((_221 * TEXCOORD_5.y) + (_222 * TEXCOORD_1.z)) + (_223 * TEXCOORD_3.y);
  float _238 = ((_221 * TEXCOORD_5.z) + (_222 * TEXCOORD_1.w)) + (_223 * TEXCOORD_3.z);
  float _239 = TEXCOORD.z * 0.6499999761581421f;
  float4 _242 = t0.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _249 = saturate(((_96 * _63.x) * cb4_001x) + _242.y);
  float _253 = saturate(cb4_006x + _249);
  float4 _260 = t0.Sample(s0, float2(TEXCOORD_1.x, TEXCOORD_1.y));
  float _276 = cb4_009x + (cb4_008x * _260.z);
  float _292 = exp2(log2(max(saturate(_276 * (pow(cb4_007x, 2.200000047683716f))), 0.0f)) * 0.4545449912548065f);
  float _293 = exp2(log2(max(saturate(_276 * (pow(cb4_007y, 2.200000047683716f))), 0.0f)) * 0.4545449912548065f);
  float _294 = exp2(log2(max(saturate(_276 * (pow(cb4_007z, 2.200000047683716f))), 0.0f)) * 0.4545449912548065f);
  bool _297 = (max(_292, max(_293, _294)) > 0.20000000298023224f);
  float _322 = cb1_036x - TEXCOORD_4.x;
  float _323 = cb1_036y - TEXCOORD_4.y;
  float _324 = cb1_036z - TEXCOORD_4.z;
  float _326 = rsqrt(dot(float3(_322, _323, _324), float3(_322, _323, _324)));
  float _346 = cb4_012x * cb4_012x;
  float _347 = cb4_012y * cb4_012y;
  float _348 = cb4_012z * cb4_012z;
  float _380 = cb4_018x + (cb4_017x * (pow(_260.z, cb4_016x)));
  float _398 = cb4_020x + (cb4_019x * 0.800000011920929f);
  float _414 = cb4_029x * cb4_029x;
  float _415 = cb4_029y * cb4_029y;
  float _416 = cb4_029z * cb4_029z;
  uint _423 = uint(SV_Position.x);
  uint _424 = uint(SV_Position.y);
  float _425 = saturate(cb4_011x * exp2(log2(exp2(log2(saturate(1.0f - dot(float3(_236, _237, _238), float3((_322 * _326), (_323 * _326), (_324 * _326))))) * 0.8999999761581421f)) * cb4_010x));
  float _426 = saturate(((select((_253 < 0.33000001311302185f), (_253 * 0.949999988079071f), 0.33000001311302185f) - _253) * _239) + _253);
  float _427 = saturate(((select(_297, _292, 0.11999999731779099f) - _292) * _239) + _292);
  float _428 = saturate(((select(_297, _293, 0.11999999731779099f) - _293) * _239) + _293);
  float _429 = saturate(((select(_297, _294, 0.11999999731779099f) - _294) * _239) + _294);
  float _436 = (pow(_427, 2.200000047683716f));
  float _437 = (pow(_428, 2.200000047683716f));
  float _438 = (pow(_429, 2.200000047683716f));
  float _439 = saturate(((saturate((cb4_004x * 1.5f) * _132) - _132) * _147) + _132);
  float _440 = saturate(((saturate((cb4_004y * 1.5f) * _133) - _133) * _147) + _133);
  float _441 = saturate(((saturate((cb4_004z * 1.5f) * _134) - _134) * _147) + _134);
  float _448 = (pow(_439, 2.200000047683716f));
  float _449 = (pow(_440, 2.200000047683716f));
  float _450 = (pow(_441, 2.200000047683716f));
  int _453 = int(cb12_220x);
  float _455 = rsqrt(dot(float3(_236, _237, _238), float3(_236, _237, _238)));
  float _456 = _455 * _236;
  float _457 = _455 * _237;
  float _458 = _455 * _238;
  float _460 = rsqrt(dot(float3(TEXCOORD_3.x, TEXCOORD_3.y, TEXCOORD_3.z), float3(TEXCOORD_3.x, TEXCOORD_3.y, TEXCOORD_3.z)));
  float _461 = _460 * TEXCOORD_3.x;
  float _462 = _460 * TEXCOORD_3.y;
  float _463 = _460 * TEXCOORD_3.z;
  float _476 = cb12_000x - TEXCOORD_4.x;
  float _477 = cb12_000y - TEXCOORD_4.y;
  float _478 = cb12_000z - TEXCOORD_4.z;
  float _480 = rsqrt(dot(float3(_476, _477, _478), float3(_476, _477, _478)));
  float _481 = _476 * _480;
  float _482 = _477 * _480;
  float _483 = _478 * _480;
  bool improved_pbr = graphics_injection.layout_version == 1.f
      && graphics_injection.graphics_mode != 0.f && graphics_injection.pbr_mode != 0.f
      && (_453 == 0 || _453 == 1);
  float direct_roughness = GraphicsForwardRoughness(float3(_456, _457, _458), _426);
  direct_roughness = improved_pbr ? direct_roughness : _426;
  float4 _485 = t17.Load(int3(_423, _424, 0));
  float graphics_sun_visibility = min(_485.y, GraphicsForwardContact(TEXCOORD_4,
      float3(_456, _457, _458), SV_Position.xy, true));
  bool _490 = (cb12_229x > 0.0f);
  uint4 _492 = 0u; t60.GetDimensions(0u, _492.x, _492.y, _492.z, _492.w);
  int _506;
  int _512;
  int _518;
  int _524;
  int _530;
  int _536;
  int _542;
  int _548;
  int _549;
  int _550;
  int _551;
  int _552;
  int _553;
  int _554;
  int _555;
  int _556;
  float _558;
  float _559;
  float _560;
  float _561;
  float _562;
  float _563;
  int _564;
  int _633;
  float _639;
  bool _640;
  float _707;
  float _713;
  float _824;
  float _825;
  float _826;
  float _827;
  float _907;
  float _908;
  float _909;
  float _910;
  float _914;
  float _915;
  float _916;
  float _917;
  int _918;
  float _963;
  float _970;
  float _971;
  int _984;
  int _985;
  float _1023;
  float _1024;
  float _1025;
  float _1030;
  float _1031;
  float _1032;
  float _1034;
  float _1035;
  float _1036;
  float _1037;
  float _1038;
  float _1054;
  float _1061;
  float _1062;
  float _1103;
  float _1104;
  float _1105;
  float _1122;
  float _1132;
  float _1141;
  float _1161;
  float _1412;
  float _1494;
  float _1495;
  float _1496;
  float _1577;
  float _1578;
  float _1579;
  float _1640;
  float _1641;
  float _1642;
  float _1828;
  float _1910;
  float _1911;
  float _1912;
  float _1993;
  float _1994;
  float _1995;
  float _2027;
  float _2028;
  float _2029;
  float _2115;
  float _2170;
  float _2171;
  float _2172;
  float _2177;
  float _2178;
  float _2179;
  float _2196;
  float _2197;
  float _2198;
  float _2199;
  float _2200;
  float _2201;
  float _2205;
  float _2206;
  float _2207;
  float _2208;
  float _2209;
  float _2210;
  bool _2221;
  float _2405;
  float _2490;
  float _2491;
  float _2492;
  float _2493;
  float _2494;
  float _2495;
  float _2576;
  float _2577;
  float _2578;
  int _2663;
  float _2725;
  float _2921;
  float _2935;
  float _2952;
  float _2969;
  float _2983;
  float _2997;
  float _3012;
  float _3013;
  float _3098;
  float _3099;
  float _3100;
  float _3189;
  float _3244;
  float _3245;
  float _3246;
  float _3251;
  float _3252;
  float _3253;
  float _3261;
  float _3262;
  float _3263;
  float _3264;
  float _3265;
  float _3266;
  float _3267;
  float _3268;
  float _3269;
  int _3306;
  float _3307;
  float _3308;
  float _3309;
  float _3310;
  float _3505;
  float _3506;
  float _3507;
  float _3508;
  float _3574;
  float _3575;
  float _3576;
  float _3577;
  int _3579;
  float _3580;
  float _3581;
  float _3582;
  float _3583;
  float _3778;
  float _3779;
  float _3780;
  float _3781;
  float _3843;
  float _3844;
  float _3845;
  float _3846;
  float _4001;
  float _4002;
  float _4003;
  float _4004;
  float _4005;
  int _4006;
  float _4111;
  float _4112;
  float _4167;
  float _4168;
  float _4219;
  float _4233;
  float _4234;
  float _4235;
  float _4236;
  float _4237;
  float _4263;
  float _4264;
  float _4265;
  float _4266;
  float _4269;
  float _4270;
  float _4271;
  float _4273;
  float _4274;
  float _4275;
  int _4276;
  int _4277;
  float _4278;
  float _4354;
  float _4355;
  float _4356;
  float _4357;
  float _4358;
  int _4359;
  float _4472;
  float _4473;
  float _4524;
  float _4525;
  float _4576;
  float _4590;
  float _4591;
  float _4592;
  float _4593;
  float _4594;
  float _4620;
  float _4621;
  float _4622;
  float _4623;
  float _4627;
  float _4628;
  float _4629;
  int _4630;
  float _4631;
  float _4632;
  int _4633;
  float _4634;
  float _4635;
  float _4636;
  float _4682;
  float _4683;
  float _4722;
  float _4723;
  float _4724;
  float _4725;
  float _4746;
  float _4747;
  float _4748;
  bool _4749;
  float _4849;
  float _4860;
  float _4870;
  if ((int)((uint)_423 < (uint)(int)(_492.x)) && (int)((uint)_424 < (uint)(int)(_492.y))) {
    int _500 = min((int)(_492.z), 8);
    if (!(_500 == 0)) {
      uint _503 = t60.Load(int4(_423, _424, 0, 0));
      _506 = _503.x;
    } else {
      _506 = 0;
    }
    if ((uint)_500 > (uint)1) {
      uint _509 = t60.Load(int4(_423, _424, 1, 0));
      _512 = _509.x;
    } else {
      _512 = 0;
    }
    if ((uint)_500 > (uint)2) {
      uint _515 = t60.Load(int4(_423, _424, 2, 0));
      _518 = _515.x;
    } else {
      _518 = 0;
    }
    if ((uint)_500 > (uint)3) {
      uint _521 = t60.Load(int4(_423, _424, 3, 0));
      _524 = _521.x;
    } else {
      _524 = 0;
    }
    if ((uint)_500 > (uint)4) {
      uint _527 = t60.Load(int4(_423, _424, 4, 0));
      _530 = _527.x;
    } else {
      _530 = 0;
    }
    if ((uint)_500 > (uint)5) {
      uint _533 = t60.Load(int4(_423, _424, 5, 0));
      _536 = _533.x;
    } else {
      _536 = 0;
    }
    if ((uint)_500 > (uint)6) {
      uint _539 = t60.Load(int4(_423, _424, 6, 0));
      _542 = _539.x;
    } else {
      _542 = 0;
    }
    if ((uint)_500 > (uint)7) {
      uint _545 = t60.Load(int4(_423, _424, 7, 0));
      _548 = _524;
      _549 = _518;
      _550 = _512;
      _551 = _506;
      _552 = _545.x;
      _553 = _542;
      _554 = _536;
      _555 = _530;
      _556 = _500;
    } else {
      _548 = _524;
      _549 = _518;
      _550 = _512;
      _551 = _506;
      _552 = 0;
      _553 = _542;
      _554 = _536;
      _555 = _530;
      _556 = _500;
    }
  } else {
    _548 = 0;
    _549 = 0;
    _550 = 0;
    _551 = 0;
    _552 = 0;
    _553 = 0;
    _554 = 0;
    _555 = 0;
    _556 = 0;
  }
  _558 = 0.0f;
  _559 = 0.0f;
  _560 = 0.0f;
  _561 = 0.0f;
  _562 = 0.0f;
  _563 = 0.0f;
  _564 = 0;
  while(true) {
    int4 _568 = asint(t20.Load4(((int)(((uint)(_564 + ((int)(((int(cb12_024x) * ((uint)(_424) >> 4)) + ((uint)((uint)(_423) >> 4))) << 8u)))) << 2u))));
    [branch]
    if (!((uint)_568.x > (uint)255)) {
      uint _572 = _568.x * 10;
      float _578 = (cb13_raw[((int)(_572 + 68u))].x) - TEXCOORD_4.x;
      float _579 = (cb13_raw[((int)(_572 + 68u))].y) - TEXCOORD_4.y;
      float _580 = (cb13_raw[((int)(_572 + 68u))].z) - TEXCOORD_4.z;
      float _589 = (cb13_raw[((int)(_572 + 68u))].x) - (TEXCOORD_4.x - (cb12_229z * _456));
      float _590 = (cb13_raw[((int)(_572 + 68u))].y) - (TEXCOORD_4.y - (cb12_229z * _457));
      float _591 = (cb13_raw[((int)(_572 + 68u))].z) - (TEXCOORD_4.z - (cb12_229z * _458));
      uint _592 = (uint)(_568.x) + 1u;
      if (!(_556 == 0)) {
        if (!((_551 & 511) == _592)) {
          if (!((uint)_556 < (uint)2)) {
            if (!((_550 & 511) == _592)) {
              if (!((uint)_556 < (uint)3)) {
                if (!((_549 & 511) == _592)) {
                  if (!((uint)_556 < (uint)4)) {
                    if (!((_548 & 511) == _592)) {
                      if (!((uint)_556 < (uint)5)) {
                        if (!((_555 & 511) == _592)) {
                          if (!((uint)_556 < (uint)6)) {
                            if (!((_554 & 511) == _592)) {
                              if (!((uint)_556 < (uint)7)) {
                                if (!((_553 & 511) == _592)) {
                                  if ((int)((uint)_556 > (uint)7) && (int)((_552 & 511) == _592)) {
                                    _633 = _552;
                                    _639 = (float((uint)((uint)(((uint)(_633) >> 9) & 127))) * 0.007874015718698502f);
                                    _640 = true;
                                  } else {
                                    _639 = 1.0f;
                                    _640 = false;
                                  }
                                } else {
                                  _633 = _553;
                                  _639 = (float((uint)((uint)(((uint)(_633) >> 9) & 127))) * 0.007874015718698502f);
                                  _640 = true;
                                }
                              } else {
                                _639 = 1.0f;
                                _640 = false;
                              }
                            } else {
                              _633 = _554;
                              _639 = (float((uint)((uint)(((uint)(_633) >> 9) & 127))) * 0.007874015718698502f);
                              _640 = true;
                            }
                          } else {
                            _639 = 1.0f;
                            _640 = false;
                          }
                        } else {
                          _633 = _555;
                          _639 = (float((uint)((uint)(((uint)(_633) >> 9) & 127))) * 0.007874015718698502f);
                          _640 = true;
                        }
                      } else {
                        _639 = 1.0f;
                        _640 = false;
                      }
                    } else {
                      _633 = _548;
                      _639 = (float((uint)((uint)(((uint)(_633) >> 9) & 127))) * 0.007874015718698502f);
                      _640 = true;
                    }
                  } else {
                    _639 = 1.0f;
                    _640 = false;
                  }
                } else {
                  _633 = _549;
                  _639 = (float((uint)((uint)(((uint)(_633) >> 9) & 127))) * 0.007874015718698502f);
                  _640 = true;
                }
              } else {
                _639 = 1.0f;
                _640 = false;
              }
            } else {
              _633 = _550;
              _639 = (float((uint)((uint)(((uint)(_633) >> 9) & 127))) * 0.007874015718698502f);
              _640 = true;
            }
          } else {
            _639 = 1.0f;
            _640 = false;
          }
        } else {
          _633 = _551;
          _639 = (float((uint)((uint)(((uint)(_633) >> 9) & 127))) * 0.007874015718698502f);
          _640 = true;
        }
      } else {
        _639 = 1.0f;
        _640 = false;
      }
      float _646 = sqrt(((_589 * _589) + (_590 * _590)) + (_591 * _591));
      float _653 = _646 / (cb13_raw[((int)(_572 + 68u))].w);
      float _654 = _653 * _653;
      float _657 = saturate(1.0f - (_654 * _654));
      int _662 = asint((cb13_raw[((int)(_572 + 71u))].w));
      bool _664 = ((_662 & 1) != 0);
      bool _666 = ((cb13_raw[((int)(_572 + 73u))].z) > 0.0f);
      int _674 = asint((cb13_raw[((int)(_572 + 77u))].x));
      bool _676 = ((_674 & 1) != 0);
      float _678 = (_657 * _657) / (((_646 * _646) * (cb13_raw[((int)(_572 + 73u))].x)) + 1.0f);
      if (_664) {
        float _686 = rsqrt(dot(float3(_589, _590, _591), float3(_589, _590, _591)));
        _707 = (exp2(log2(saturate(((cb13_raw[((int)(_572 + 72u))].y) * dot(float3((-0.0f - (_589 * _686)), (-0.0f - (_590 * _686)), (-0.0f - (_591 * _686))), float3((cb13_raw[((int)(_572 + 70u))].x), (cb13_raw[((int)(_572 + 70u))].y), (cb13_raw[((int)(_572 + 70u))].z)))) + (cb13_raw[((int)(_572 + 72u))].z))) * (cb13_raw[((int)(_572 + 72u))].w)) * _678);
      } else {
        _707 = _678;
      }
      bool _708 = (_707 > 0.0f);
      if (_640 && _708) {
        _713 = saturate(_639);
      } else {
        _713 = 1.0f;
      }
      if (((int)(_666 || _676)) && _708) {
        float _717 = -0.0f - _589;
        float _718 = -0.0f - _590;
        float _719 = -0.0f - _591;
        if (_664) {
          _914 = mad((((cb13_raw[((int)(_572 + 75u))].z) * (cb13_raw[((int)(_572 + 70u))].x)) - ((cb13_raw[((int)(_572 + 75u))].y) * (cb13_raw[((int)(_572 + 70u))].y))), _719, mad((((cb13_raw[((int)(_572 + 75u))].y) * (cb13_raw[((int)(_572 + 70u))].z)) - ((cb13_raw[((int)(_572 + 75u))].w) * (cb13_raw[((int)(_572 + 70u))].x))), _718, ((((cb13_raw[((int)(_572 + 75u))].w) * (cb13_raw[((int)(_572 + 70u))].y)) - ((cb13_raw[((int)(_572 + 75u))].z) * (cb13_raw[((int)(_572 + 70u))].z))) * _717)));
          _915 = mad((cb13_raw[((int)(_572 + 75u))].w), _719, mad((cb13_raw[((int)(_572 + 75u))].z), _718, ((cb13_raw[((int)(_572 + 75u))].y) * _717)));
          _916 = mad((cb13_raw[((int)(_572 + 70u))].z), _719, mad((cb13_raw[((int)(_572 + 70u))].y), _718, ((cb13_raw[((int)(_572 + 70u))].x) * _717)));
          _917 = (cb13_raw[((int)(_572 + 75u))].x);
          _918 = asint((cb13_raw[((int)(_572 + 77u))].z));
        } else {
          if (_676) {
            float _775 = mad((((cb13_raw[((int)(_572 + 70u))].x) * (cb13_raw[((int)(_572 + 72u))].z)) - ((cb13_raw[((int)(_572 + 70u))].y) * (cb13_raw[((int)(_572 + 72u))].y))), _719, mad((((cb13_raw[((int)(_572 + 70u))].z) * (cb13_raw[((int)(_572 + 72u))].y)) - ((cb13_raw[((int)(_572 + 70u))].x) * (cb13_raw[((int)(_572 + 72u))].w))), _718, ((((cb13_raw[((int)(_572 + 70u))].y) * (cb13_raw[((int)(_572 + 72u))].w)) - ((cb13_raw[((int)(_572 + 70u))].z) * (cb13_raw[((int)(_572 + 72u))].z))) * _717)));
            float _778 = mad((cb13_raw[((int)(_572 + 70u))].z), _719, mad((cb13_raw[((int)(_572 + 70u))].y), _718, ((cb13_raw[((int)(_572 + 70u))].x) * _717)));
            float _781 = mad((cb13_raw[((int)(_572 + 72u))].w), _719, mad((cb13_raw[((int)(_572 + 72u))].z), _718, ((cb13_raw[((int)(_572 + 72u))].y) * _717)));
            float _782 = -0.0f - _775;
            float _783 = -0.0f - _778;
            float _784 = -0.0f - _781;
            float _785 = _782 / _646;
            float _786 = _783 / _646;
            float _787 = _784 / _646;
            float _788 = abs(_785);
            float _789 = abs(_786);
            float _790 = abs(_787);
            bool _794 = (_788 > max(_789, _790));
            if (!((_674 & 4) == 0)) {
              if (_794) {
                if (_785 > 0.0f) {
                  _824 = _778;
                  _825 = _781;
                  _826 = _782;
                  _827 = (cb13_raw[((int)(_572 + 75u))].x);
                } else {
                  _824 = _783;
                  _825 = _781;
                  _826 = _775;
                  _827 = (cb13_raw[((int)(_572 + 75u))].y);
                }
              } else {
                if (_789 > max(_788, _790)) {
                  if (_786 > 0.0f) {
                    _824 = _782;
                    _825 = _781;
                    _826 = _783;
                    _827 = (cb13_raw[((int)(_572 + 75u))].z);
                  } else {
                    _824 = _775;
                    _825 = _781;
                    _826 = _778;
                    _827 = (cb13_raw[((int)(_572 + 75u))].w);
                  }
                } else {
                  if (_787 > 0.0f) {
                    _824 = _775;
                    _825 = _778;
                    _826 = _784;
                    _827 = (cb13_raw[((int)(_572 + 76u))].x);
                  } else {
                    _824 = _775;
                    _825 = _783;
                    _826 = _781;
                    _827 = (cb13_raw[((int)(_572 + 76u))].y);
                  }
                }
              }
              _914 = _824;
              _915 = _825;
              _916 = _826;
              _917 = _827;
              _918 = asint((cb13_raw[((int)(_572 + 77u))].z));
            } else {
              if (_794) {
                int _836 = asint((cb13_raw[((int)(_572 + 77u))].z));
                if (_785 > 0.0f) {
                  _914 = _778;
                  _915 = _781;
                  _916 = _782;
                  _917 = (cb13_raw[((int)(_572 + 75u))].x);
                  _918 = _836;
                } else {
                  _914 = _783;
                  _915 = _781;
                  _916 = _775;
                  _917 = (cb13_raw[((int)(_572 + 75u))].y);
                  _918 = ((uint)(_836) >> 10);
                }
              } else {
                if (_789 > max(_788, _790)) {
                  if (_786 > 0.0f) {
                    _914 = _782;
                    _915 = _781;
                    _916 = _783;
                    _917 = (cb13_raw[((int)(_572 + 75u))].z);
                    _918 = ((uint)((uint)(asint((cb13_raw[((int)(_572 + 77u))].z)))) >> 20);
                  } else {
                    _914 = _775;
                    _915 = _781;
                    _916 = _778;
                    _917 = (cb13_raw[((int)(_572 + 75u))].w);
                    _918 = asint((cb13_raw[((int)(_572 + 77u))].w));
                  }
                } else {
                  int _863 = asint((cb13_raw[((int)(_572 + 77u))].w));
                  if (_787 > 0.0f) {
                    _914 = _775;
                    _915 = _778;
                    _916 = _784;
                    _917 = (cb13_raw[((int)(_572 + 76u))].x);
                    _918 = ((uint)(_863) >> 10);
                  } else {
                    _914 = _775;
                    _915 = _783;
                    _916 = _781;
                    _917 = (cb13_raw[((int)(_572 + 76u))].y);
                    _918 = ((uint)(_863) >> 20);
                  }
                }
              }
            }
          } else {
            float _871 = _589 / _646;
            float _872 = _590 / _646;
            float _873 = _591 / _646;
            float _874 = abs(_871);
            float _875 = abs(_872);
            float _876 = abs(_873);
            if (_874 > max(_875, _876)) {
              if (_871 > 0.0f) {
                _907 = _718;
                _908 = _719;
                _909 = _589;
                _910 = (cb13_raw[((int)(_572 + 75u))].x);
              } else {
                _907 = _590;
                _908 = _719;
                _909 = _717;
                _910 = (cb13_raw[((int)(_572 + 75u))].y);
              }
            } else {
              if (_875 > max(_874, _876)) {
                if (_872 > 0.0f) {
                  _907 = _589;
                  _908 = _719;
                  _909 = _590;
                  _910 = (cb13_raw[((int)(_572 + 75u))].z);
                } else {
                  _907 = _717;
                  _908 = _719;
                  _909 = _718;
                  _910 = (cb13_raw[((int)(_572 + 75u))].w);
                }
              } else {
                if (_873 > 0.0f) {
                  _907 = _717;
                  _908 = _718;
                  _909 = _591;
                  _910 = (cb13_raw[((int)(_572 + 76u))].x);
                } else {
                  _907 = _717;
                  _908 = _590;
                  _909 = _719;
                  _910 = (cb13_raw[((int)(_572 + 76u))].y);
                }
              }
            }
            _914 = _907;
            _915 = _908;
            _916 = _909;
            _917 = _910;
            _918 = asint((cb13_raw[((int)(_572 + 77u))].z));
          }
        }
        float _926 = (((_914 * (cb13_raw[((int)(_572 + 73u))].y)) / _916) * 0.5f) + 0.5f;
        float _927 = 0.5f - ((mad((cb13_raw[((int)(_572 + 73u))].y), _915, 0.0f) / _916) * 0.5f);
        if (_666) {
          int _929 = asint(_917);
          int _931 = ((uint)(_929) >> 18) & 4092;
          float _932 = float((uint)_931);
          [branch]
          if (!(_931 == 0)) {
            float _953 = t9.SampleLevel(s10, float3((cb13_067x * ((_926 * _932) + float((uint)((uint)(((int)(_929 << 2u)) & 4092))))), (cb13_067x * ((_927 * _932) + float((uint)((uint)(((uint)(_929) >> 8) & 4092))))), float((uint)((uint)((uint)(_929) >> 30)))), 0.0f);
            if (!_640) {
              _963 = (saturate(exp2((_953.x - (_653 * 0.9900000095367432f)) * 144.26950073242188f)) * _713);
            } else {
              _963 = _713;
            }
            _970 = _963;
            _971 = min(1e+06f, (abs(_653 - (_953.x * 0.9900000095367432f)) * (cb13_raw[((int)(_572 + 68u))].w)));
          } else {
            _970 = _713;
            _971 = 1e+06f;
          }
        } else {
          _970 = _713;
          _971 = 1e+06f;
        }
        if (_676) {
          bool _974 = ((_674 & 2) != 0);
          if (_974) {
            _984 = (_918 & 1023);
            _985 = 0;
          } else {
            _984 = (_918 & 255);
            _985 = (((uint)(_918) >> 8) & 3);
          }
          float _989 = floor(cb13_raw[((int)(_572 + 77u))].y) + float((uint)_984);
          float4 _993 = t42.SampleLevel(s10, float3(_926, _927, _989), 0.0f);
          _56[0] = _993.x;
          _56[1] = _993.y;
          _56[2] = _993.z;
          _56[3] = _993.w;
          if (!((_674 & 8) == 0)) {
            float4 _1004 = t42.SampleLevel(s10, float3(_926, _927, (_989 + 1.0f)), 0.0f);
            float _1009 = frac(cb13_raw[((int)(_572 + 77u))].y);
            float _1018 = ((_1004.x - _993.x) * _1009) + _993.x;
            float _1019 = ((_1004.y - _993.y) * _1009) + _993.y;
            float _1020 = ((_1004.z - _993.z) * _1009) + _993.z;
            _56[0] = _1018;
            _56[1] = _1019;
            _56[2] = _1020;
            _56[3] = (lerp(_993.w, _1004.w, _1009));
            _1023 = _1020;
            _1024 = _1019;
            _1025 = _1018;
          } else {
            _1023 = _993.z;
            _1024 = _993.y;
            _1025 = _993.x;
          }
          if (!_974) {
            float _1028 = _56[_985];
            _1030 = _1028;
            _1031 = _1028;
            _1032 = _1028;
          } else {
            _1030 = _1025;
            _1031 = _1024;
            _1032 = _1023;
          }
          _1034 = _970;
          _1035 = _1030;
          _1036 = _1031;
          _1037 = _1032;
          _1038 = _971;
        } else {
          _1034 = _970;
          _1035 = 1.0f;
          _1036 = 1.0f;
          _1037 = 1.0f;
          _1038 = _971;
        }
      } else {
        _1034 = _713;
        _1035 = 1.0f;
        _1036 = 1.0f;
        _1037 = 1.0f;
        _1038 = 1e+06f;
      }
      if ((int)((cb13_raw[((int)(_572 + 74u))].x) > 0.0f) && _708) {
        float _1044 = t10.SampleLevel(s10, float4(_589, _590, _591, (cb13_raw[((int)(_572 + 74u))].y)), 0.0f);
        if (!_640) {
          _1054 = (saturate(exp2((_1044.x - (_653 * 0.9900000095367432f)) * 144.26950073242188f)) * _1034);
        } else {
          _1054 = _1034;
        }
        _1061 = _1054;
        _1062 = min(_1038, (abs(_653 - (_1044.x * 0.9900000095367432f)) * (cb13_raw[((int)(_572 + 68u))].w)));
      } else {
        _1061 = _1034;
        _1062 = _1038;
      }
      float _1067 = (select(_640, 1.0f, (cb13_raw[((int)(_572 + 73u))].w)) * (_1061 + -1.0f)) + 1.0f;
      bool _1068 = (cb4_025x > 0.0f);
      [branch]
      if (!((CustomPixelConsts_336[3].y) == 0.0f)) {
        float _1082 = select(_1068, cb4_028x, cb4_027x);
        float _1086 = ((CustomPixelConsts_336[0].z) * _1082) + (CustomPixelConsts_336[0].y);
        float _1087 = ((CustomPixelConsts_336[1].z) * _1082) + (CustomPixelConsts_336[1].y);
        float _1088 = ((CustomPixelConsts_336[2].z) * _1082) + (CustomPixelConsts_336[2].y);
        if (_1068) {
          float _1090 = TEXCOORD_4.x - _1086;
          float _1091 = TEXCOORD_4.y - _1087;
          float _1092 = TEXCOORD_4.z - _1088;
          float _1094 = rsqrt(dot(float3(_1090, _1091, _1092), float3(_1090, _1091, _1092)));
          _1103 = (_1094 * _1090);
          _1104 = (_1094 * _1091);
          _1105 = (_1094 * _1092);
        } else {
          _1103 = (CustomPixelConsts_336[0].x);
          _1104 = (CustomPixelConsts_336[1].x);
          _1105 = (CustomPixelConsts_336[2].x);
        }
        float _1106 = (cb13_raw[((int)(_572 + 68u))].x) - _1086;
        float _1107 = (cb13_raw[((int)(_572 + 68u))].y) - _1087;
        float _1108 = (cb13_raw[((int)(_572 + 68u))].z) - _1088;
        float _1110 = rsqrt(dot(float3(_1106, _1107, _1108), float3(_1106, _1107, _1108)));
        _1122 = saturate(((dot(float3(_1103, _1104, _1105), float3((_1110 * _1106), (_1110 * _1107), (_1110 * _1108))) * 0.5f) + select(_1068, (0.699999988079071f - (cb4_026x * TEXCOORD_2.y)), -0.08431375026702881f)) * 5.0f);
      } else {
        _1122 = 1.0f;
      }
      float _1123 = _1122 * _425;
      if ((int)(_485.z == 1.0f) || (int)((_662 & 2048) != 0)) {
        _1132 = cb12_071y;
      } else {
        _1132 = 0.0f;
      }
      if (((int)(!(_485.z == 1.0f))) || (int)((_662 & 4096) != 0)) {
        _1141 = cb12_071z;
      } else {
        _1141 = 0.0f;
      }
      float _1144 = (_1141 * _1132) * (_1122 * _707);
      float _1145 = _1144 * _1035;
      float _1146 = _1144 * _1036;
      float _1147 = _1144 * _1037;
      [branch]
      if ((int)(_1147 > 0.0f) || ((int)((int)(_1145 > 0.0f) || (int)(_1146 > 0.0f)))) {
        if (!(FrequentPixelConsts_256.x < 0.0f)) {
          _1161 = cb12_071x;
        } else {
          _1161 = 1.0f;
        }
        float _1163 = select(((int)_662 < (int)0), _1161, 1.0f);
        float _1164 = _1163 * _1145;
        float _1165 = _1163 * _1146;
        float _1166 = _1163 * _1147;
        float _1168 = rsqrt(dot(float3(_578, _579, _580), float3(_578, _579, _580)));
        float _1169 = _1168 * _578;
        float _1170 = _1168 * _579;
        float _1171 = _1168 * _580;
        [branch]
        if (_490) {
          float _1180 = ((1.0f - cb12_229y) * 2062.5f) * abs(max((_1062 * cb12_229w), 0.019999999552965164f));
          float _1181 = _1180 * _1180;
          float _1183 = exp2(_1181 * -225.4210968017578f);
          float _1188 = exp2(_1181 * -29.807748794555664f);
          float _1196 = exp2(_1181 * -7.714946269989014f);
          float _1202 = exp2(_1181 * -2.544435739517212f);
          float _1204 = _1202 * 0.007000000216066837f;
          float _1209 = exp2(_1181 * -0.7249723672866821f);
          float _1223 = saturate(dot(float3(_1169, _1170, _1171), float3((-0.0f - _456), (-0.0f - _457), (-0.0f - _458))) + 0.30000001192092896f);
          float _1229 = _398 + 1.0f;
          float _1238 = saturate((exp2(log2(saturate((dot(float3(_461, _462, _463), float3(_1169, _1170, _1171)) + _398) / _1229)) * cb4_022x) * (cb4_023x - cb4_021x)) + cb4_021x);
          float _1245 = (_1238 * (_456 - _461)) + _461;
          float _1246 = (_1238 * (_457 - _462)) + _462;
          float _1247 = (_1238 * (_458 - _463)) + _463;
          float _1249 = rsqrt(dot(float3(_1245, _1246, _1247), float3(_1245, _1246, _1247)));
          float _1250 = _1245 * _1249;
          float _1251 = _1246 * _1249;
          float _1252 = _1247 * _1249;
          float _1253 = 1.0f / _1229;
          float _1254 = dot(float3(_1250, _1251, _1252), float3(_1169, _1170, _1171));
          float _1256 = (_1254 + _398) * _1253;
          float _1257 = 1.0f - _346;
          float _1258 = _1250 - _461;
          float _1259 = _1251 - _462;
          float _1260 = _1252 - _463;
          float _1264 = (_1258 * _1257) + _461;
          float _1265 = (_1259 * _1257) + _462;
          float _1266 = (_1260 * _1257) + _463;
          float _1268 = rsqrt(dot(float3(_1264, _1265, _1266), float3(_1264, _1265, _1266)));
          float _1272 = 1.0f - _347;
          float _1276 = (_1258 * _1272) + _461;
          float _1277 = (_1259 * _1272) + _462;
          float _1278 = (_1260 * _1272) + _463;
          float _1280 = rsqrt(dot(float3(_1276, _1277, _1278), float3(_1276, _1277, _1278)));
          float _1284 = 1.0f - _348;
          float _1288 = (_1258 * _1284) + _461;
          float _1289 = (_1259 * _1284) + _462;
          float _1290 = (_1260 * _1284) + _463;
          float _1292 = rsqrt(dot(float3(_1288, _1289, _1290), float3(_1288, _1289, _1290)));
          float _1321 = saturate(_1256 * cb4_030x);
          bool _1335 = (cb12_229x > 0.0f);
          float _1339 = saturate(select(_1335, _1254, (((_1321 * (1.0f - _414)) + _414) * exp2(log2(saturate(max(((dot(float3((_1264 * _1268), (_1265 * _1268), (_1266 * _1268)), float3(_1169, _1170, _1171)) + _398) * _1253), _1256))) * cb4_031x))));
          if (_453 == 1) {
            float _1344 = saturate(_1254);
            int _1347 = ((int)(uint)((int)(_1252 > 0.0f))) << 1u;
            float _1349 = float((int)(_1347 + -1));
            float _1351 = -1.0f / (_1349 + _1252);
            float _1352 = _1351 * _1251;
            float _1353 = _1352 * _1250;
            float _1357 = (((_1250 * _1250) * _1351) * _1349) + 1.0f;
            float _1358 = _1353 * _1349;
            float _1361 = float((int)(1 - _1347)) * _1250;
            float _1363 = _1349 + (_1352 * _1251);
            float _1364 = -0.0f - _1251;
            float _1366 = rsqrt(dot(float3(_1169, _1170, _1171), float3(_1169, _1170, _1171)));
            float _1367 = _1366 * _1169;
            float _1368 = _1366 * _1170;
            float _1369 = _1366 * _1171;
            float _1372 = mad(_1361, _1369, mad(_1358, _1368, (_1367 * _1357)));
            float _1375 = mad(_1364, _1369, mad(_1363, _1368, (_1367 * _1353)));
            float _1378 = mad(_1252, _1369, mad(_1251, _1368, (_1367 * _1250)));
            float _1380 = rsqrt(dot(float3(_1372, _1375, _1378), float3(_1372, _1375, _1378)));
            float _1383 = _1380 * _1378;
            float _1385 = rsqrt(dot(float3(_481, _482, _483), float3(_481, _482, _483)));
            float _1386 = _1385 * _481;
            float _1387 = _1385 * _482;
            float _1388 = _1385 * _483;
            float _1391 = mad(_1361, _1388, mad(_1358, _1387, (_1386 * _1357)));
            float _1394 = mad(_1364, _1388, mad(_1363, _1387, (_1386 * _1353)));
            float _1397 = mad(_1252, _1388, mad(_1251, _1387, (_1386 * _1250)));
            float _1399 = rsqrt(dot(float3(_1391, _1394, _1397), float3(_1391, _1394, _1397)));
            float _1402 = _1399 * _1397;
            float _1403 = direct_roughness * direct_roughness;
            float _1406 = dot(float3((_1380 * _1372), (_1380 * _1375), _1383), float3((_1399 * _1391), (_1399 * _1394), _1402)) - (_1402 * _1383);
            if (_1406 > 0.0f) {
              _1412 = (_1406 / max(_1383, _1402));
            } else {
              _1412 = _1406;
            }
            float _1414 = (_1403 * 0.2877933979034424f) + 1.0f;
            float _1415 = 1.0f / _1414;
            float _1416 = _448 * 0.31830987334251404f;
            float _1417 = _449 * 0.31830987334251404f;
            float _1418 = _450 * 0.31830987334251404f;
            float _1421 = ((_1412 * _1403) + 1.0f) * _1415;
            float _1425 = 1.0f - _1402;
            float _1436 = 1.0f - _1383;
            float _1449 = _1415 * ((_1403 * 0.07248824834823608f) + 1.0f);
            float _1456 = 1.0f - _1449;
            float _1471 = max(1.0000000116860974e-07f, (1.0f - ((((_1436 * _1403) * ((((((_1436 * 0.07144299894571304f) + -0.332181453704834f) * _1436) + 0.4918818771839142f) * _1436) + 0.05710852891206741f)) + 1.0f) / _1414))) * (max(1.0000000116860974e-07f, (1.0f - ((((_1425 * _1403) * ((((((_1425 * 0.07144299894571304f) + -0.332181453704834f) * _1425) + 0.4918818771839142f) * _1425) + 0.05710852891206741f)) + 1.0f) / _1414))) * 0.31830987334251404f);
            float _1475 = max(1.0000000116860974e-07f, _1456);
            float _1486 = max(0.0f, (_1339 - _1344));
            _1494 = ((_1486 * _1416) + ((((_1471 * (((_448 * _448) * _1449) / (1.0f - (_1456 * _448)))) / _1475) + (_1421 * _1416)) * _1344));
            _1495 = ((_1486 * _1417) + ((((_1471 * (((_449 * _449) * _1449) / (1.0f - (_1456 * _449)))) / _1475) + (_1421 * _1417)) * _1344));
            _1496 = (((((_1471 * (((_450 * _450) * _1449) / (1.0f - (_1456 * _450)))) / _1475) + (_1421 * _1418)) * _1344) + (_1486 * _1418));
          } else {
            _1494 = _1339;
            _1495 = saturate(select(_1335, _1254, (((_1321 * (1.0f - _415)) + _415) * exp2(log2(saturate(max(((dot(float3((_1280 * _1276), (_1280 * _1277), (_1280 * _1278)), float3(_1169, _1170, _1171)) + _398) * _1253), _1256))) * cb4_031x))));
            _1496 = saturate(select(_1335, _1254, (((_1321 * (1.0f - _416)) + _416) * exp2(log2(saturate(max(((dot(float3((_1292 * _1288), (_1292 * _1289), (_1292 * _1290)), float3(_1169, _1170, _1171)) + _398) * _1253), _1256))) * cb4_031x))));
          }
          // Preserve native skin transmission and environment auxiliary values.
          if (improved_pbr) {
            float3 diffuse = GraphicsSkinDiffuse(float3(_1250, _1251, _1252), float3(_481, _482, _483),
                float3(_1169, _1170, _1171), direct_roughness, float3(_448, _449, _450), _453,
                _453 == 0 ? float3(_1494, _1495, _1496) : _1339.xxx);
            _1494 = diffuse.x; _1495 = diffuse.y; _1496 = diffuse.z;
          }
          float _1500 = 1.0f - _436;
          float _1501 = 1.0f - _437;
          float _1502 = 1.0f - _438;
          if (cb12_221x > 0.0f) {
            float4 _1507 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_1250, _1251, _1252), float3(_481, _482, _483))), 0.0f);
            float _1513 = (_1507.x * _436) + _1507.y;
            float _1514 = (_1507.x * _437) + _1507.y;
            float _1515 = (_1507.x * _438) + _1507.y;
            _1577 = min((_1513 / max((1.0f - ((1.0f - _1513) * ((_1500 * 0.0476190485060215f) + _436))), 0.0010000000474974513f)), 1.0f);
            _1578 = min((_1514 / max((1.0f - ((1.0f - _1514) * ((_1501 * 0.0476190485060215f) + _437))), 0.0010000000474974513f)), 1.0f);
            _1579 = min((_1515 / max((1.0f - ((1.0f - _1515) * ((_1502 * 0.0476190485060215f) + _438))), 0.0010000000474974513f)), 1.0f);
          } else {
            float _1541 = _1169 + _481;
            float _1542 = _1170 + _482;
            float _1543 = _1171 + _483;
            float _1545 = rsqrt(dot(float3(_1541, _1542, _1543), float3(_1541, _1542, _1543)));
            float _1552 = saturate(1.0f - abs(dot(float3((_1545 * _1541), (_1545 * _1542), (_1545 * _1543)), float3(_481, _482, _483))));
            float _1553 = _1552 * _1552;
            float _1563 = ((_1553 * _1553) * _1552) * cb13_066x;
            float _1569 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
            _1577 = (((_1563 * max(0.0f, _1500)) / _1569) + _436);
            _1578 = (((_1563 * max(0.0f, _1501)) / _1569) + _437);
            _1579 = (((_1563 * max(0.0f, _1502)) / _1569) + _438);
          }
          float _1583 = (1.0f - _1577) * _1494;
          float _1584 = (1.0f - _1578) * _1495;
          float _1585 = (1.0f - _1579) * _1496;
          bool _1587 = ((_453 & -3) == 0);
          float _1594 = _1067 * cb4_032x;
          _2027 = ((_1164 * (cb13_raw[((int)(_572 + 71u))].x)) * ((select(_1587, (_1583 * 0.31830987334251404f), _1583) * _1594) + (((((((_1188 * 0.10000000149011612f) + (_1183 * 0.2329999953508377f)) + (_1196 * 0.11800000071525574f)) + (_1202 * 0.11299999803304672f)) + (_1209 * 0.3580000102519989f)) + (exp2(_1181 * -0.19469568133354187f) * 0.07800000160932541f)) * _1223)));
          _2028 = ((_1165 * (cb13_raw[((int)(_572 + 71u))].y)) * ((select(_1587, (_1584 * 0.31830987334251404f), _1584) * _1594) + (_1223 * (((((_1188 * 0.335999995470047f) + (_1183 * 0.45500001311302185f)) + (_1196 * 0.1979999989271164f)) + _1204) + (_1209 * 0.004000000189989805f)))));
          _2029 = ((_1166 * (cb13_raw[((int)(_572 + 71u))].z)) * ((select(_1587, (_1585 * 0.31830987334251404f), _1585) * _1594) + (_1223 * (((_1188 * 0.3440000116825104f) + (_1183 * 0.6489999890327454f)) + _1204))));
        } else {
          [branch]
          if (_1123 > 0.0f) {
            float _1615 = (dot(float3(_1169, _1170, _1171), float3(_456, _457, _458)) + 1.0f) * 0.5f;
            float _1616 = -0.0f - _481;
            float _1617 = -0.0f - _482;
            float _1618 = -0.0f - _483;
            float _1621 = (dot(float3(_1169, _1170, _1171), float3(_1616, _1617, _1618)) + 1.0f) * 0.5f;
            float _1624 = _1621 * _1621;
            float _1631 = ((_1123 * 0.19050000607967377f) * (dot(float3(_456, _457, _458), float3(_1616, _1617, _1618)) + 1.0f)) * ((((_1624 * _1624) - _1615) * 0.20000000298023224f) + _1615);
            bool _1632 = (_453 == 1);
            _1640 = select(_1632, (_1631 * _448), _1631);
            _1641 = select(_1632, (_1631 * _449), _1631);
            _1642 = select(_1632, (_1631 * _450), _1631);
          } else {
            _1640 = 0.0f;
            _1641 = 0.0f;
            _1642 = 0.0f;
          }
          float _1645 = _398 + 1.0f;
          float _1654 = saturate((exp2(log2(saturate((dot(float3(_461, _462, _463), float3(_1169, _1170, _1171)) + _398) / _1645)) * cb4_022x) * (cb4_023x - cb4_021x)) + cb4_021x);
          float _1661 = (_1654 * (_456 - _461)) + _461;
          float _1662 = (_1654 * (_457 - _462)) + _462;
          float _1663 = (_1654 * (_458 - _463)) + _463;
          float _1665 = rsqrt(dot(float3(_1661, _1662, _1663), float3(_1661, _1662, _1663)));
          float _1666 = _1661 * _1665;
          float _1667 = _1662 * _1665;
          float _1668 = _1663 * _1665;
          float _1669 = 1.0f / _1645;
          float _1670 = dot(float3(_1666, _1667, _1668), float3(_1169, _1170, _1171));
          float _1672 = (_1670 + _398) * _1669;
          float _1673 = 1.0f - _346;
          float _1674 = _1666 - _461;
          float _1675 = _1667 - _462;
          float _1676 = _1668 - _463;
          float _1680 = (_1674 * _1673) + _461;
          float _1681 = (_1675 * _1673) + _462;
          float _1682 = (_1676 * _1673) + _463;
          float _1684 = rsqrt(dot(float3(_1680, _1681, _1682), float3(_1680, _1681, _1682)));
          float _1688 = 1.0f - _347;
          float _1692 = (_1674 * _1688) + _461;
          float _1693 = (_1675 * _1688) + _462;
          float _1694 = (_1676 * _1688) + _463;
          float _1696 = rsqrt(dot(float3(_1692, _1693, _1694), float3(_1692, _1693, _1694)));
          float _1700 = 1.0f - _348;
          float _1704 = (_1674 * _1700) + _461;
          float _1705 = (_1675 * _1700) + _462;
          float _1706 = (_1676 * _1700) + _463;
          float _1708 = rsqrt(dot(float3(_1704, _1705, _1706), float3(_1704, _1705, _1706)));
          float _1737 = saturate(_1672 * cb4_030x);
          bool _1751 = (cb12_229x > 0.0f);
          float _1755 = saturate(select(_1751, _1670, (((_1737 * (1.0f - _414)) + _414) * exp2(log2(saturate(max(((dot(float3((_1680 * _1684), (_1681 * _1684), (_1682 * _1684)), float3(_1169, _1170, _1171)) + _398) * _1669), _1672))) * cb4_031x))));
          if (_453 == 1) {
            float _1760 = saturate(_1670);
            int _1763 = ((int)(uint)((int)(_1668 > 0.0f))) << 1u;
            float _1765 = float((int)(_1763 + -1));
            float _1767 = -1.0f / (_1765 + _1668);
            float _1768 = _1767 * _1667;
            float _1769 = _1768 * _1666;
            float _1773 = (((_1666 * _1666) * _1767) * _1765) + 1.0f;
            float _1774 = _1769 * _1765;
            float _1777 = float((int)(1 - _1763)) * _1666;
            float _1779 = _1765 + (_1768 * _1667);
            float _1780 = -0.0f - _1667;
            float _1782 = rsqrt(dot(float3(_1169, _1170, _1171), float3(_1169, _1170, _1171)));
            float _1783 = _1782 * _1169;
            float _1784 = _1782 * _1170;
            float _1785 = _1782 * _1171;
            float _1788 = mad(_1777, _1785, mad(_1774, _1784, (_1783 * _1773)));
            float _1791 = mad(_1780, _1785, mad(_1779, _1784, (_1783 * _1769)));
            float _1794 = mad(_1668, _1785, mad(_1667, _1784, (_1783 * _1666)));
            float _1796 = rsqrt(dot(float3(_1788, _1791, _1794), float3(_1788, _1791, _1794)));
            float _1799 = _1796 * _1794;
            float _1801 = rsqrt(dot(float3(_481, _482, _483), float3(_481, _482, _483)));
            float _1802 = _1801 * _481;
            float _1803 = _1801 * _482;
            float _1804 = _1801 * _483;
            float _1807 = mad(_1777, _1804, mad(_1774, _1803, (_1802 * _1773)));
            float _1810 = mad(_1780, _1804, mad(_1779, _1803, (_1802 * _1769)));
            float _1813 = mad(_1668, _1804, mad(_1667, _1803, (_1802 * _1666)));
            float _1815 = rsqrt(dot(float3(_1807, _1810, _1813), float3(_1807, _1810, _1813)));
            float _1818 = _1815 * _1813;
            float _1819 = direct_roughness * direct_roughness;
            float _1822 = dot(float3((_1796 * _1788), (_1796 * _1791), _1799), float3((_1815 * _1807), (_1815 * _1810), _1818)) - (_1818 * _1799);
            if (_1822 > 0.0f) {
              _1828 = (_1822 / max(_1799, _1818));
            } else {
              _1828 = _1822;
            }
            float _1830 = (_1819 * 0.2877933979034424f) + 1.0f;
            float _1831 = 1.0f / _1830;
            float _1832 = _448 * 0.31830987334251404f;
            float _1833 = _449 * 0.31830987334251404f;
            float _1834 = _450 * 0.31830987334251404f;
            float _1837 = ((_1828 * _1819) + 1.0f) * _1831;
            float _1841 = 1.0f - _1818;
            float _1852 = 1.0f - _1799;
            float _1865 = _1831 * ((_1819 * 0.07248824834823608f) + 1.0f);
            float _1872 = 1.0f - _1865;
            float _1887 = max(1.0000000116860974e-07f, (1.0f - ((((_1852 * _1819) * ((((((_1852 * 0.07144299894571304f) + -0.332181453704834f) * _1852) + 0.4918818771839142f) * _1852) + 0.05710852891206741f)) + 1.0f) / _1830))) * (max(1.0000000116860974e-07f, (1.0f - ((((_1841 * _1819) * ((((((_1841 * 0.07144299894571304f) + -0.332181453704834f) * _1841) + 0.4918818771839142f) * _1841) + 0.05710852891206741f)) + 1.0f) / _1830))) * 0.31830987334251404f);
            float _1891 = max(1.0000000116860974e-07f, _1872);
            float _1902 = max(0.0f, (_1755 - _1760));
            _1910 = ((_1902 * _1832) + ((((_1887 * (((_448 * _448) * _1865) / (1.0f - (_1872 * _448)))) / _1891) + (_1837 * _1832)) * _1760));
            _1911 = ((_1902 * _1833) + ((((_1887 * (((_449 * _449) * _1865) / (1.0f - (_1872 * _449)))) / _1891) + (_1837 * _1833)) * _1760));
            _1912 = (((((_1887 * (((_450 * _450) * _1865) / (1.0f - (_1872 * _450)))) / _1891) + (_1837 * _1834)) * _1760) + (_1902 * _1834));
          } else {
            _1910 = _1755;
            _1911 = saturate(select(_1751, _1670, (((_1737 * (1.0f - _415)) + _415) * exp2(log2(saturate(max(((dot(float3((_1696 * _1692), (_1696 * _1693), (_1696 * _1694)), float3(_1169, _1170, _1171)) + _398) * _1669), _1672))) * cb4_031x))));
            _1912 = saturate(select(_1751, _1670, (((_1737 * (1.0f - _416)) + _416) * exp2(log2(saturate(max(((dot(float3((_1708 * _1704), (_1708 * _1705), (_1708 * _1706)), float3(_1169, _1170, _1171)) + _398) * _1669), _1672))) * cb4_031x))));
          }
          // Preserve native skin transmission and environment auxiliary values.
          if (improved_pbr) {
            float3 diffuse = GraphicsSkinDiffuse(float3(_1666, _1667, _1668), float3(_481, _482, _483),
                float3(_1169, _1170, _1171), direct_roughness, float3(_448, _449, _450), _453,
                _453 == 0 ? float3(_1910, _1911, _1912) : _1755.xxx);
            _1910 = diffuse.x; _1911 = diffuse.y; _1912 = diffuse.z;
          }
          float _1916 = 1.0f - _436;
          float _1917 = 1.0f - _437;
          float _1918 = 1.0f - _438;
          if (cb12_221x > 0.0f) {
            float4 _1923 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_1666, _1667, _1668), float3(_481, _482, _483))), 0.0f);
            float _1929 = (_1923.x * _436) + _1923.y;
            float _1930 = (_1923.x * _437) + _1923.y;
            float _1931 = (_1923.x * _438) + _1923.y;
            _1993 = min((_1929 / max((1.0f - ((1.0f - _1929) * ((_1916 * 0.0476190485060215f) + _436))), 0.0010000000474974513f)), 1.0f);
            _1994 = min((_1930 / max((1.0f - ((1.0f - _1930) * ((_1917 * 0.0476190485060215f) + _437))), 0.0010000000474974513f)), 1.0f);
            _1995 = min((_1931 / max((1.0f - ((1.0f - _1931) * ((_1918 * 0.0476190485060215f) + _438))), 0.0010000000474974513f)), 1.0f);
          } else {
            float _1957 = _1169 + _481;
            float _1958 = _1170 + _482;
            float _1959 = _1171 + _483;
            float _1961 = rsqrt(dot(float3(_1957, _1958, _1959), float3(_1957, _1958, _1959)));
            float _1968 = saturate(1.0f - abs(dot(float3((_1961 * _1957), (_1961 * _1958), (_1961 * _1959)), float3(_481, _482, _483))));
            float _1969 = _1968 * _1968;
            float _1979 = ((_1969 * _1969) * _1968) * cb13_066x;
            float _1985 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
            _1993 = (((_1979 * max(0.0f, _1916)) / _1985) + _436);
            _1994 = (((_1979 * max(0.0f, _1917)) / _1985) + _437);
            _1995 = (((_1979 * max(0.0f, _1918)) / _1985) + _438);
          }
          float _1999 = (1.0f - _1993) * _1910;
          float _2000 = (1.0f - _1994) * _1911;
          float _2001 = (1.0f - _1995) * _1912;
          bool _2003 = ((_453 & -3) == 0);
          float _2010 = _1067 * cb4_032x;
          _2027 = ((_1164 * (cb13_raw[((int)(_572 + 71u))].x)) * ((select(_2003, (_1999 * 0.31830987334251404f), _1999) * _2010) + _1640));
          _2028 = ((_1165 * (cb13_raw[((int)(_572 + 71u))].y)) * ((select(_2003, (_2000 * 0.31830987334251404f), _2000) * _2010) + _1641));
          _2029 = ((_1166 * (cb13_raw[((int)(_572 + 71u))].z)) * ((select(_2003, (_2001 * 0.31830987334251404f), _2001) * _2010) + _1642));
        }
        [branch]
        if (dot(float3(_1169, _1170, _1171), float3(_456, _457, _458)) > 0.0f) {
          float _2036 = _1169 + _481;
          float _2037 = _1170 + _482;
          float _2038 = _1171 + _483;
          float _2040 = rsqrt(dot(float3(_2036, _2037, _2038), float3(_2036, _2037, _2038)));
          float _2041 = _2040 * _2036;
          float _2042 = _2040 * _2037;
          float _2043 = _2040 * _2038;
          float _2045 = dot(float3(_456, _457, _458), float3(_481, _482, _483));
          float _2047 = saturate(dot(float3(_456, _457, _458), float3(_2041, _2042, _2043)));
          float _2048 = saturate(dot(float3(_456, _457, _458), float3(_1169, _1170, _1171)));
          float _2049 = direct_roughness * direct_roughness;
          float _2050 = _2049 * _2049;
          float _2054 = ((_2047 * _2047) * (_2050 + -1.0f)) + 1.0f;
          float _2058 = abs(_2045);
          float _2062 = saturate(1.0f - abs(dot(float3(_2041, _2042, _2043), float3(_481, _482, _483))));
          float _2063 = _2062 * _2062;
          float _2068 = 1.0f - _436;
          float _2069 = 1.0f - _437;
          float _2070 = 1.0f - _438;
          float _2076 = ((_2063 * _2063) * _2062) * cb13_066x;
          float _2082 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
          [branch]
          if (cb12_221z > 0.0f) {
            float _2093 = saturate(_2045);
            float _2096 = (_2048 * 2.0f) * _2093;
            _2115 = ((((_2093 + _2048) - _2096) * _2049) + _2096);
          } else {
            float _2101 = 1.0f - _2050;
            _2115 = (((sqrt(((_2058 * _2058) * _2101) + _2050) * _2048) + 9.999999747378752e-05f) + (sqrt(((_2048 * _2048) * _2101) + _2050) * _2058));
          }
          float _2116 = 0.5f / _2115;
          float _2117 = _2116 * (_2050 / ((_2054 * _2054) * 3.1415200233459473f));
          if (improved_pbr) _2117 = GraphicsDirectGGX(_2047, _2045, _2048, direct_roughness);
          float _2118 = _2117 * (((_2076 * max(0.0f, _2068)) / _2082) + _436);
          float _2119 = _2117 * (((_2076 * max(0.0f, _2069)) / _2082) + _437);
          float _2120 = _2117 * (((_2076 * max(0.0f, _2070)) / _2082) + _438);
          if (cb12_221y > 0.0f) {
            float4 _2127 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_456, _457, _458), float3(_2116, _2116, _2116))), 0.0f);
            float _2133 = (_2127.x * _436) + _2127.y;
            float _2134 = (_2127.x * _437) + _2127.y;
            float _2135 = (_2127.x * _438) + _2127.y;
            _2170 = ((min((_2133 / max((1.0f - ((1.0f - _2133) * ((_2068 * 0.0476190485060215f) + _436))), 0.0010000000474974513f)), 1.0f) / max(_2133, 9.999999747378752e-05f)) * _2118);
            _2171 = ((min((_2134 / max((1.0f - ((1.0f - _2134) * ((_2069 * 0.0476190485060215f) + _437))), 0.0010000000474974513f)), 1.0f) / max(_2134, 9.999999747378752e-05f)) * _2119);
            _2172 = ((min((_2135 / max((1.0f - ((1.0f - _2135) * ((_2070 * 0.0476190485060215f) + _438))), 0.0010000000474974513f)), 1.0f) / max(_2135, 9.999999747378752e-05f)) * _2120);
          } else {
            _2170 = _2118;
            _2171 = _2119;
            _2172 = _2120;
          }
          _2177 = (_2170 * _2048);
          _2178 = (_2171 * _2048);
          _2179 = (_2172 * _2048);
        } else {
          _2177 = 0.0f;
          _2178 = 0.0f;
          _2179 = 0.0f;
        }
        _2196 = (_2027 + _558);
        _2197 = (_2028 + _559);
        _2198 = (_2029 + _560);
        _2199 = ((((_1067 * (cb13_raw[((int)(_572 + 71u))].x)) * _1164) * _2177) + _561);
        _2200 = ((((_1067 * (cb13_raw[((int)(_572 + 71u))].y)) * _1165) * _2178) + _562);
        _2201 = ((((_1067 * (cb13_raw[((int)(_572 + 71u))].z)) * _1166) * _2179) + _563);
      } else {
        _2196 = _558;
        _2197 = _559;
        _2198 = _560;
        _2199 = _561;
        _2200 = _562;
        _2201 = _563;
      }
      int _2202 = _564 + 1;
      if ((int)_2202 < (int)256) {
        _558 = _2196;
        _559 = _2197;
        _560 = _2198;
        _561 = _2199;
        _562 = _2200;
        _563 = _2201;
        _564 = _2202;
        continue;
      } else {
        _2205 = _2196;
        _2206 = _2197;
        _2207 = _2198;
        _2208 = _2199;
        _2209 = _2200;
        _2210 = _2201;
      }
    } else {
      _2205 = _558;
      _2206 = _559;
      _2207 = _560;
      _2208 = _561;
      _2209 = _562;
      _2210 = _563;
    }
    break;
  }
  GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
      TEXCOORD_4, float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
  bool _2217 = (cb12_229x > 0.0f);
  if (!_2217) {
    if (_485.y > 0.0f) {
      _2221 = false;
      float _2224 = _398 + 1.0f;
      float _2233 = saturate((exp2(log2(saturate((dot(float3(_461, _462, _463), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + _398) / _2224)) * cb4_022x) * (cb4_023x - cb4_021x)) + cb4_021x);
      float _2240 = (_2233 * (_456 - _461)) + _461;
      float _2241 = (_2233 * (_457 - _462)) + _462;
      float _2242 = (_2233 * (_458 - _463)) + _463;
      float _2244 = rsqrt(dot(float3(_2240, _2241, _2242), float3(_2240, _2241, _2242)));
      float _2245 = _2240 * _2244;
      float _2246 = _2241 * _2244;
      float _2247 = _2242 * _2244;
      float _2248 = 1.0f / _2224;
      float _2249 = dot(float3(_2245, _2246, _2247), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
      float _2251 = (_2249 + _398) * _2248;
      float _2252 = 1.0f - _346;
      float _2253 = _2245 - _461;
      float _2254 = _2246 - _462;
      float _2255 = _2247 - _463;
      float _2259 = (_2253 * _2252) + _461;
      float _2260 = (_2254 * _2252) + _462;
      float _2261 = (_2255 * _2252) + _463;
      float _2263 = rsqrt(dot(float3(_2259, _2260, _2261), float3(_2259, _2260, _2261)));
      float _2267 = 1.0f - _347;
      float _2271 = (_2253 * _2267) + _461;
      float _2272 = (_2254 * _2267) + _462;
      float _2273 = (_2255 * _2267) + _463;
      float _2275 = rsqrt(dot(float3(_2271, _2272, _2273), float3(_2271, _2272, _2273)));
      float _2279 = 1.0f - _348;
      float _2283 = (_2253 * _2279) + _461;
      float _2284 = (_2254 * _2279) + _462;
      float _2285 = (_2255 * _2279) + _463;
      float _2287 = rsqrt(dot(float3(_2283, _2284, _2285), float3(_2283, _2284, _2285)));
      float _2316 = saturate(_2251 * cb4_030x);
      float _2332 = saturate(select(_2217, _2249, (((_2316 * (1.0f - _414)) + _414) * exp2(log2(saturate(max(((dot(float3((_2259 * _2263), (_2260 * _2263), (_2261 * _2263)), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + _398) * _2248), _2251))) * cb4_031x))));
      float _2333 = saturate(select(_2217, _2249, (((_2316 * (1.0f - _415)) + _415) * exp2(log2(saturate(max(((dot(float3((_2275 * _2271), (_2275 * _2272), (_2275 * _2273)), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + _398) * _2248), _2251))) * cb4_031x))));
      float _2334 = saturate(select(_2217, _2249, (((_2316 * (1.0f - _416)) + _416) * exp2(log2(saturate(max(((dot(float3((_2287 * _2283), (_2287 * _2284), (_2287 * _2285)), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + _398) * _2248), _2251))) * cb4_031x))));
      bool _2335 = (_453 == 1);
      if (_2335) {
        float _2337 = saturate(_2249);
        int _2340 = ((int)(uint)((int)(_2247 > 0.0f))) << 1u;
        float _2342 = float((int)(_2340 + -1));
        float _2344 = -1.0f / (_2342 + _2247);
        float _2345 = _2344 * _2246;
        float _2346 = _2345 * _2245;
        float _2350 = (((_2245 * _2245) * _2344) * _2342) + 1.0f;
        float _2351 = _2346 * _2342;
        float _2354 = float((int)(1 - _2340)) * _2245;
        float _2356 = _2342 + (_2345 * _2246);
        float _2357 = -0.0f - _2246;
        float _2359 = rsqrt(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
        float _2360 = _2359 * water_light.sun.x;
        float _2361 = _2359 * water_light.sun.y;
        float _2362 = _2359 * water_light.sun.z;
        float _2365 = mad(_2354, _2362, mad(_2351, _2361, (_2360 * _2350)));
        float _2368 = mad(_2357, _2362, mad(_2356, _2361, (_2360 * _2346)));
        float _2371 = mad(_2247, _2362, mad(_2246, _2361, (_2360 * _2245)));
        float _2373 = rsqrt(dot(float3(_2365, _2368, _2371), float3(_2365, _2368, _2371)));
        float _2376 = _2373 * _2371;
        float _2378 = rsqrt(dot(float3(_481, _482, _483), float3(_481, _482, _483)));
        float _2379 = _2378 * _481;
        float _2380 = _2378 * _482;
        float _2381 = _2378 * _483;
        float _2384 = mad(_2354, _2381, mad(_2351, _2380, (_2379 * _2350)));
        float _2387 = mad(_2357, _2381, mad(_2356, _2380, (_2379 * _2346)));
        float _2390 = mad(_2247, _2381, mad(_2246, _2380, (_2379 * _2245)));
        float _2392 = rsqrt(dot(float3(_2384, _2387, _2390), float3(_2384, _2387, _2390)));
        float _2395 = _2392 * _2390;
        float _2396 = _426 * _426;
        float _2399 = dot(float3((_2373 * _2365), (_2373 * _2368), _2376), float3((_2392 * _2384), (_2392 * _2387), _2395)) - (_2395 * _2376);
        if (_2399 > 0.0f) {
          _2405 = (_2399 / max(_2376, _2395));
        } else {
          _2405 = _2399;
        }
        float _2407 = (_2396 * 0.2877933979034424f) + 1.0f;
        float _2408 = 1.0f / _2407;
        float _2409 = _448 * 0.31830987334251404f;
        float _2410 = _449 * 0.31830987334251404f;
        float _2411 = _450 * 0.31830987334251404f;
        float _2414 = ((_2405 * _2396) + 1.0f) * _2408;
        float _2418 = 1.0f - _2395;
        float _2429 = 1.0f - _2376;
        float _2442 = _2408 * ((_2396 * 0.07248824834823608f) + 1.0f);
        float _2449 = 1.0f - _2442;
        float _2464 = max(1.0000000116860974e-07f, (1.0f - ((((_2429 * _2396) * ((((((_2429 * 0.07144299894571304f) + -0.332181453704834f) * _2429) + 0.4918818771839142f) * _2429) + 0.05710852891206741f)) + 1.0f) / _2407))) * (max(1.0000000116860974e-07f, (1.0f - ((((_2418 * _2396) * ((((((_2418 * 0.07144299894571304f) + -0.332181453704834f) * _2418) + 0.4918818771839142f) * _2418) + 0.05710852891206741f)) + 1.0f) / _2407))) * 0.31830987334251404f);
        float _2468 = max(1.0000000116860974e-07f, _2449);
        float _2479 = max(0.0f, (_2332 - _2337));
        float _2483 = (_2479 * _2409) + ((((_2464 * (((_448 * _448) * _2442) / (1.0f - (_2449 * _448)))) / _2468) + (_2414 * _2409)) * _2337);
        float _2484 = (_2479 * _2410) + ((((_2464 * (((_449 * _449) * _2442) / (1.0f - (_2449 * _449)))) / _2468) + (_2414 * _2410)) * _2337);
        float _2485 = ((((_2464 * (((_450 * _450) * _2442) / (1.0f - (_2449 * _450)))) / _2468) + (_2414 * _2411)) * _2337) + (_2479 * _2411);
        _2490 = _2483;
        _2491 = _2484;
        _2492 = _2485;
        _2493 = (_2483 * 3.1415927410125732f);
        _2494 = (_2484 * 3.1415927410125732f);
        _2495 = (_2485 * 3.1415927410125732f);
      } else {
        _2490 = _2332;
        _2491 = _2333;
        _2492 = _2334;
        _2493 = _2332;
        _2494 = _2333;
        _2495 = _2334;
      }
      // Preserve native skin transmission and environment auxiliary values.
      if (improved_pbr) {
        float3 diffuse = GraphicsSkinDiffuse(float3(_2245, _2246, _2247), float3(_481, _482, _483),
            float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), direct_roughness, float3(_448, _449, _450), _453,
            _453 == 0 ? float3(_2490, _2491, _2492) : _2332.xxx);
        _2490 = diffuse.x; _2491 = diffuse.y; _2492 = diffuse.z;
      }
      float _2499 = 1.0f - _436;
      float _2500 = 1.0f - _437;
      float _2501 = 1.0f - _438;
      if (cb12_221x > 0.0f) {
        float4 _2506 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_2245, _2246, _2247), float3(_481, _482, _483))), 0.0f);
        float _2512 = (_2506.x * _436) + _2506.y;
        float _2513 = (_2506.x * _437) + _2506.y;
        float _2514 = (_2506.x * _438) + _2506.y;
        _2576 = min((_2512 / max((1.0f - ((1.0f - _2512) * ((_2499 * 0.0476190485060215f) + _436))), 0.0010000000474974513f)), 1.0f);
        _2577 = min((_2513 / max((1.0f - ((1.0f - _2513) * ((_2500 * 0.0476190485060215f) + _437))), 0.0010000000474974513f)), 1.0f);
        _2578 = min((_2514 / max((1.0f - ((1.0f - _2514) * ((_2501 * 0.0476190485060215f) + _438))), 0.0010000000474974513f)), 1.0f);
      } else {
        float _2540 = water_light.sun.x + _481;
        float _2541 = water_light.sun.y + _482;
        float _2542 = water_light.sun.z + _483;
        float _2544 = rsqrt(dot(float3(_2540, _2541, _2542), float3(_2540, _2541, _2542)));
        float _2551 = saturate(1.0f - abs(dot(float3((_2544 * _2540), (_2544 * _2541), (_2544 * _2542)), float3(_481, _482, _483))));
        float _2552 = _2551 * _2551;
        float _2562 = ((_2552 * _2552) * _2551) * cb13_066x;
        float _2568 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
        _2576 = (((_2562 * max(0.0f, _2499)) / _2568) + _436);
        _2577 = (((_2562 * max(0.0f, _2500)) / _2568) + _437);
        _2578 = (((_2562 * max(0.0f, _2501)) / _2568) + _438);
      }
      float _2582 = (1.0f - _2576) * _2490;
      float _2583 = (1.0f - _2577) * _2491;
      float _2584 = (1.0f - _2578) * _2492;
      bool _2586 = ((_453 & -3) == 0);
      float _2593 = TEXCOORD_4.x - cb12_000x;
      float _2594 = TEXCOORD_4.y - cb12_000y;
      float _2604 = saturate((cb12_219z * TEXCOORD_4.z) + cb12_219w);
      float _2626 = saturate((cb12_219x * sqrt((_2593 * _2593) + (_2594 * _2594))) + cb12_219y);
      float _2637 = ((((lerp(cb13_062x, cb13_061x, _2604)) - cb13_001x) * _2626) + cb13_001x) * water_light.direct.x;
      float _2638 = ((((lerp(cb13_062y, cb13_061y, _2604)) - cb13_001y) * _2626) + cb13_001y) * water_light.direct.y;
      float _2639 = ((((lerp(cb13_062z, cb13_061z, _2604)) - cb13_001z) * _2626) + cb13_001z) * water_light.direct.z;
      [branch]
      if (_2221) {
        float _2645 = TEXCOORD_4.x - (cb12_229z * _456);
        float _2646 = TEXCOORD_4.y - (cb12_229z * _457);
        float _2647 = TEXCOORD_4.z - (cb12_229z * _458);
        float _2648 = _2645 - cb12_000x;
        float _2649 = _2646 - cb12_000y;
        float _2652 = (_2648 * _2648) + (_2649 * _2649);
        float _2653 = sqrt(_2652);
        [branch]
        if (_2653 < cb13_035x) {
          if (!(cb13_034x == 0)) {
            _2663 = 0;
            while(true) {
              float _2668 = _2645 - (cb13_raw[((int)(_2663 + 37u))].x);
              float _2669 = _2646 - (cb13_raw[((int)(_2663 + 37u))].y);
              float _2674 = dot(float2(_2668, _2669), float2((cb13_raw[((int)(_2663 + 42u))].x), (cb13_raw[((int)(_2663 + 42u))].y)));
              float _2677 = dot(float2(_2668, _2669), float2((cb13_raw[((int)(_2663 + 42u))].z), (cb13_raw[((int)(_2663 + 42u))].w)));
              if ((int)(_2674 > 0.0f) && (int)(_2677 > 0.0f)) {
                if (!((int)(_2674 < 1.0f) && (int)(_2677 < 1.0f))) {
                  int _2686 = _2663 + 1;
                  if ((uint)_2686 < (uint)cb13_034x) {
                    _2663 = _2686;
                    continue;
                  } else {
                    _2725 = 1.0f;
                    float _2728 = cb12_066x * 20.0f;
                    float _2739 = _2647 - cb12_000z;
                    float _2748 = _2647 * 0.009999999776482582f;
                    float _2751 = _2748 / cb12_066x;
                    float _2760 = _2748 / _2728;
                    float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
                    float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
                    float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
                    float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
                    float _2773 = float((int)(int(trunc(cb12_068x))));
                    float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
                    float _2778 = float((int)(int(trunc(cb12_068y))));
                    float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
                    float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
                    float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
                    float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
                    float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
                    if (!(_2802 == 0.0f)) {
                      float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
                      float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
                      float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
                      [branch]
                      if (!(abs(_2832) >= 0.9990000128746033f)) {
                        float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                        [branch]
                        if (!(_2889 < 0.5f)) {
                          if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                            float _2906 = (cb13_010z * _2824) + cb13_010x;
                            float _2907 = cb13_010y - (cb13_010z * _2828);
                            float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                            float _2915 = (_2832 - _2912.x) * cb13_063x;
                            float _2917 = _2915 + cb12_229z;
                            if (!(_2915 > 0.0f)) {
                              _2921 = max(0.0f, _2917);
                            } else {
                              _2921 = _2917;
                            }
                            float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                            float _2929 = (_2832 - _2926.x) * cb13_063x;
                            float _2931 = _2929 + cb12_229z;
                            if (!(_2929 > 0.0f)) {
                              _2935 = max(0.0f, _2931);
                            } else {
                              _2935 = _2931;
                            }
                            float _2939 = cb13_010w * 0.9510599970817566f;
                            float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                            float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                            float _2946 = (_2832 - _2943.x) * cb13_063x;
                            float _2948 = _2946 + cb12_229z;
                            if (!(_2946 > 0.0f)) {
                              _2952 = max(0.0f, _2948);
                            } else {
                              _2952 = _2948;
                            }
                            float _2956 = cb13_010w * 0.5877799987792969f;
                            float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                            float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                            float _2963 = (_2832 - _2960.x) * cb13_063x;
                            float _2965 = _2963 + cb12_229z;
                            if (!(_2963 > 0.0f)) {
                              _2969 = max(0.0f, _2965);
                            } else {
                              _2969 = _2965;
                            }
                            float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                            float _2977 = (_2832 - _2974.x) * cb13_063x;
                            float _2979 = _2977 + cb12_229z;
                            if (!(_2977 > 0.0f)) {
                              _2983 = max(0.0f, _2979);
                            } else {
                              _2983 = _2979;
                            }
                            float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                            float _2991 = (_2832 - _2988.x) * cb13_063x;
                            float _2993 = _2991 + cb12_229z;
                            if (!(_2991 > 0.0f)) {
                              _2997 = max(0.0f, _2993);
                            } else {
                              _2997 = _2993;
                            }
                            _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                            _3013 = _2802;
                          } else {
                            _3012 = _2802;
                            _3013 = _2802;
                          }
                        } else {
                          _3012 = _2802;
                          _3013 = _2802;
                        }
                      } else {
                        _3012 = _2802;
                        _3013 = _2802;
                      }
                    } else {
                      _3012 = 1.0f;
                      _3013 = _2802;
                    }
                  }
                } else {
                  if ((int)_2663 > (int)-1) {
                    float _2706 = t19.SampleLevel(s10, float3(_2674, _2677, float((int)(_2663))), 0.0f);
                    float _2713 = saturate((((-0.10000000149011612f - _2647) + cb13_036x) + (_2706.x * cb13_035w)) * min(1.0f, (cb13_034z / max(1.0f, (cb13_034w * _2653)))));
                    float _2721 = (saturate((cb13_035y + _2653) * cb13_035z) * _2713) + (1.0f - _2713);
                    if (!(_2721 == 0.0f)) {
                      _2725 = _2721;
                      float _2728 = cb12_066x * 20.0f;
                      float _2739 = _2647 - cb12_000z;
                      float _2748 = _2647 * 0.009999999776482582f;
                      float _2751 = _2748 / cb12_066x;
                      float _2760 = _2748 / _2728;
                      float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
                      float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
                      float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
                      float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
                      float _2773 = float((int)(int(trunc(cb12_068x))));
                      float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
                      float _2778 = float((int)(int(trunc(cb12_068y))));
                      float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
                      float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
                      float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
                      float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
                      float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
                      if (!(_2802 == 0.0f)) {
                        float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
                        float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
                        float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
                        [branch]
                        if (!(abs(_2832) >= 0.9990000128746033f)) {
                          float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                          [branch]
                          if (!(_2889 < 0.5f)) {
                            if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                              float _2906 = (cb13_010z * _2824) + cb13_010x;
                              float _2907 = cb13_010y - (cb13_010z * _2828);
                              float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                              float _2915 = (_2832 - _2912.x) * cb13_063x;
                              float _2917 = _2915 + cb12_229z;
                              if (!(_2915 > 0.0f)) {
                                _2921 = max(0.0f, _2917);
                              } else {
                                _2921 = _2917;
                              }
                              float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                              float _2929 = (_2832 - _2926.x) * cb13_063x;
                              float _2931 = _2929 + cb12_229z;
                              if (!(_2929 > 0.0f)) {
                                _2935 = max(0.0f, _2931);
                              } else {
                                _2935 = _2931;
                              }
                              float _2939 = cb13_010w * 0.9510599970817566f;
                              float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                              float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                              float _2946 = (_2832 - _2943.x) * cb13_063x;
                              float _2948 = _2946 + cb12_229z;
                              if (!(_2946 > 0.0f)) {
                                _2952 = max(0.0f, _2948);
                              } else {
                                _2952 = _2948;
                              }
                              float _2956 = cb13_010w * 0.5877799987792969f;
                              float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                              float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                              float _2963 = (_2832 - _2960.x) * cb13_063x;
                              float _2965 = _2963 + cb12_229z;
                              if (!(_2963 > 0.0f)) {
                                _2969 = max(0.0f, _2965);
                              } else {
                                _2969 = _2965;
                              }
                              float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                              float _2977 = (_2832 - _2974.x) * cb13_063x;
                              float _2979 = _2977 + cb12_229z;
                              if (!(_2977 > 0.0f)) {
                                _2983 = max(0.0f, _2979);
                              } else {
                                _2983 = _2979;
                              }
                              float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                              float _2991 = (_2832 - _2988.x) * cb13_063x;
                              float _2993 = _2991 + cb12_229z;
                              if (!(_2991 > 0.0f)) {
                                _2997 = max(0.0f, _2993);
                              } else {
                                _2997 = _2993;
                              }
                              _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                              _3013 = _2802;
                            } else {
                              _3012 = _2802;
                              _3013 = _2802;
                            }
                          } else {
                            _3012 = _2802;
                            _3013 = _2802;
                          }
                        } else {
                          _3012 = _2802;
                          _3013 = _2802;
                        }
                      } else {
                        _3012 = 1.0f;
                        _3013 = _2802;
                      }
                    } else {
                      _3012 = 1.0f;
                      _3013 = _2721;
                    }
                  } else {
                    _2725 = 1.0f;
                    float _2728 = cb12_066x * 20.0f;
                    float _2739 = _2647 - cb12_000z;
                    float _2748 = _2647 * 0.009999999776482582f;
                    float _2751 = _2748 / cb12_066x;
                    float _2760 = _2748 / _2728;
                    float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
                    float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
                    float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
                    float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
                    float _2773 = float((int)(int(trunc(cb12_068x))));
                    float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
                    float _2778 = float((int)(int(trunc(cb12_068y))));
                    float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
                    float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
                    float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
                    float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
                    float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
                    if (!(_2802 == 0.0f)) {
                      float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
                      float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
                      float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
                      [branch]
                      if (!(abs(_2832) >= 0.9990000128746033f)) {
                        float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                        [branch]
                        if (!(_2889 < 0.5f)) {
                          if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                            float _2906 = (cb13_010z * _2824) + cb13_010x;
                            float _2907 = cb13_010y - (cb13_010z * _2828);
                            float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                            float _2915 = (_2832 - _2912.x) * cb13_063x;
                            float _2917 = _2915 + cb12_229z;
                            if (!(_2915 > 0.0f)) {
                              _2921 = max(0.0f, _2917);
                            } else {
                              _2921 = _2917;
                            }
                            float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                            float _2929 = (_2832 - _2926.x) * cb13_063x;
                            float _2931 = _2929 + cb12_229z;
                            if (!(_2929 > 0.0f)) {
                              _2935 = max(0.0f, _2931);
                            } else {
                              _2935 = _2931;
                            }
                            float _2939 = cb13_010w * 0.9510599970817566f;
                            float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                            float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                            float _2946 = (_2832 - _2943.x) * cb13_063x;
                            float _2948 = _2946 + cb12_229z;
                            if (!(_2946 > 0.0f)) {
                              _2952 = max(0.0f, _2948);
                            } else {
                              _2952 = _2948;
                            }
                            float _2956 = cb13_010w * 0.5877799987792969f;
                            float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                            float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                            float _2963 = (_2832 - _2960.x) * cb13_063x;
                            float _2965 = _2963 + cb12_229z;
                            if (!(_2963 > 0.0f)) {
                              _2969 = max(0.0f, _2965);
                            } else {
                              _2969 = _2965;
                            }
                            float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                            float _2977 = (_2832 - _2974.x) * cb13_063x;
                            float _2979 = _2977 + cb12_229z;
                            if (!(_2977 > 0.0f)) {
                              _2983 = max(0.0f, _2979);
                            } else {
                              _2983 = _2979;
                            }
                            float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                            float _2991 = (_2832 - _2988.x) * cb13_063x;
                            float _2993 = _2991 + cb12_229z;
                            if (!(_2991 > 0.0f)) {
                              _2997 = max(0.0f, _2993);
                            } else {
                              _2997 = _2993;
                            }
                            _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                            _3013 = _2802;
                          } else {
                            _3012 = _2802;
                            _3013 = _2802;
                          }
                        } else {
                          _3012 = _2802;
                          _3013 = _2802;
                        }
                      } else {
                        _3012 = _2802;
                        _3013 = _2802;
                      }
                    } else {
                      _3012 = 1.0f;
                      _3013 = _2802;
                    }
                  }
                }
              } else {
                int _2686 = _2663 + 1;
                if ((uint)_2686 < (uint)cb13_034x) {
                  _2663 = _2686;
                  continue;
                } else {
                  _2725 = 1.0f;
                  float _2728 = cb12_066x * 20.0f;
                  float _2739 = _2647 - cb12_000z;
                  float _2748 = _2647 * 0.009999999776482582f;
                  float _2751 = _2748 / cb12_066x;
                  float _2760 = _2748 / _2728;
                  float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
                  float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
                  float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
                  float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
                  float _2773 = float((int)(int(trunc(cb12_068x))));
                  float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
                  float _2778 = float((int)(int(trunc(cb12_068y))));
                  float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
                  float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
                  float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
                  float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
                  float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
                  if (!(_2802 == 0.0f)) {
                    float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
                    float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
                    float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
                    [branch]
                    if (!(abs(_2832) >= 0.9990000128746033f)) {
                      float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                      [branch]
                      if (!(_2889 < 0.5f)) {
                        if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                          float _2906 = (cb13_010z * _2824) + cb13_010x;
                          float _2907 = cb13_010y - (cb13_010z * _2828);
                          float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                          float _2915 = (_2832 - _2912.x) * cb13_063x;
                          float _2917 = _2915 + cb12_229z;
                          if (!(_2915 > 0.0f)) {
                            _2921 = max(0.0f, _2917);
                          } else {
                            _2921 = _2917;
                          }
                          float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                          float _2929 = (_2832 - _2926.x) * cb13_063x;
                          float _2931 = _2929 + cb12_229z;
                          if (!(_2929 > 0.0f)) {
                            _2935 = max(0.0f, _2931);
                          } else {
                            _2935 = _2931;
                          }
                          float _2939 = cb13_010w * 0.9510599970817566f;
                          float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                          float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                          float _2946 = (_2832 - _2943.x) * cb13_063x;
                          float _2948 = _2946 + cb12_229z;
                          if (!(_2946 > 0.0f)) {
                            _2952 = max(0.0f, _2948);
                          } else {
                            _2952 = _2948;
                          }
                          float _2956 = cb13_010w * 0.5877799987792969f;
                          float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                          float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                          float _2963 = (_2832 - _2960.x) * cb13_063x;
                          float _2965 = _2963 + cb12_229z;
                          if (!(_2963 > 0.0f)) {
                            _2969 = max(0.0f, _2965);
                          } else {
                            _2969 = _2965;
                          }
                          float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                          float _2977 = (_2832 - _2974.x) * cb13_063x;
                          float _2979 = _2977 + cb12_229z;
                          if (!(_2977 > 0.0f)) {
                            _2983 = max(0.0f, _2979);
                          } else {
                            _2983 = _2979;
                          }
                          float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                          float _2991 = (_2832 - _2988.x) * cb13_063x;
                          float _2993 = _2991 + cb12_229z;
                          if (!(_2991 > 0.0f)) {
                            _2997 = max(0.0f, _2993);
                          } else {
                            _2997 = _2993;
                          }
                          _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                          _3013 = _2802;
                        } else {
                          _3012 = _2802;
                          _3013 = _2802;
                        }
                      } else {
                        _3012 = _2802;
                        _3013 = _2802;
                      }
                    } else {
                      _3012 = _2802;
                      _3013 = _2802;
                    }
                  } else {
                    _3012 = 1.0f;
                    _3013 = _2802;
                  }
                }
              }
              break;
            }
          } else {
            _2725 = 1.0f;
            float _2728 = cb12_066x * 20.0f;
            float _2739 = _2647 - cb12_000z;
            float _2748 = _2647 * 0.009999999776482582f;
            float _2751 = _2748 / cb12_066x;
            float _2760 = _2748 / _2728;
            float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
            float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
            float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
            float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
            float _2773 = float((int)(int(trunc(cb12_068x))));
            float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
            float _2778 = float((int)(int(trunc(cb12_068y))));
            float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
            float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
            float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
            float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
            float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
            if (!(_2802 == 0.0f)) {
              float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
              float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
              float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
              [branch]
              if (!(abs(_2832) >= 0.9990000128746033f)) {
                float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                [branch]
                if (!(_2889 < 0.5f)) {
                  if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                    float _2906 = (cb13_010z * _2824) + cb13_010x;
                    float _2907 = cb13_010y - (cb13_010z * _2828);
                    float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                    float _2915 = (_2832 - _2912.x) * cb13_063x;
                    float _2917 = _2915 + cb12_229z;
                    if (!(_2915 > 0.0f)) {
                      _2921 = max(0.0f, _2917);
                    } else {
                      _2921 = _2917;
                    }
                    float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                    float _2929 = (_2832 - _2926.x) * cb13_063x;
                    float _2931 = _2929 + cb12_229z;
                    if (!(_2929 > 0.0f)) {
                      _2935 = max(0.0f, _2931);
                    } else {
                      _2935 = _2931;
                    }
                    float _2939 = cb13_010w * 0.9510599970817566f;
                    float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                    float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                    float _2946 = (_2832 - _2943.x) * cb13_063x;
                    float _2948 = _2946 + cb12_229z;
                    if (!(_2946 > 0.0f)) {
                      _2952 = max(0.0f, _2948);
                    } else {
                      _2952 = _2948;
                    }
                    float _2956 = cb13_010w * 0.5877799987792969f;
                    float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                    float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                    float _2963 = (_2832 - _2960.x) * cb13_063x;
                    float _2965 = _2963 + cb12_229z;
                    if (!(_2963 > 0.0f)) {
                      _2969 = max(0.0f, _2965);
                    } else {
                      _2969 = _2965;
                    }
                    float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                    float _2977 = (_2832 - _2974.x) * cb13_063x;
                    float _2979 = _2977 + cb12_229z;
                    if (!(_2977 > 0.0f)) {
                      _2983 = max(0.0f, _2979);
                    } else {
                      _2983 = _2979;
                    }
                    float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                    float _2991 = (_2832 - _2988.x) * cb13_063x;
                    float _2993 = _2991 + cb12_229z;
                    if (!(_2991 > 0.0f)) {
                      _2997 = max(0.0f, _2993);
                    } else {
                      _2997 = _2993;
                    }
                    _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                    _3013 = _2802;
                  } else {
                    _3012 = _2802;
                    _3013 = _2802;
                  }
                } else {
                  _3012 = _2802;
                  _3013 = _2802;
                }
              } else {
                _3012 = _2802;
                _3013 = _2802;
              }
            } else {
              _3012 = 1.0f;
              _3013 = _2802;
            }
          }
        } else {
          _2725 = 1.0f;
          float _2728 = cb12_066x * 20.0f;
          float _2739 = _2647 - cb12_000z;
          float _2748 = _2647 * 0.009999999776482582f;
          float _2751 = _2748 / cb12_066x;
          float _2760 = _2748 / _2728;
          float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
          float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
          float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
          float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
          float _2773 = float((int)(int(trunc(cb12_068x))));
          float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
          float _2778 = float((int)(int(trunc(cb12_068y))));
          float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
          float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
          float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
          float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
          float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
          if (!(_2802 == 0.0f)) {
            float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
            float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
            float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
            [branch]
            if (!(abs(_2832) >= 0.9990000128746033f)) {
              float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
              [branch]
              if (!(_2889 < 0.5f)) {
                if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                  float _2906 = (cb13_010z * _2824) + cb13_010x;
                  float _2907 = cb13_010y - (cb13_010z * _2828);
                  float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                  float _2915 = (_2832 - _2912.x) * cb13_063x;
                  float _2917 = _2915 + cb12_229z;
                  if (!(_2915 > 0.0f)) {
                    _2921 = max(0.0f, _2917);
                  } else {
                    _2921 = _2917;
                  }
                  float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                  float _2929 = (_2832 - _2926.x) * cb13_063x;
                  float _2931 = _2929 + cb12_229z;
                  if (!(_2929 > 0.0f)) {
                    _2935 = max(0.0f, _2931);
                  } else {
                    _2935 = _2931;
                  }
                  float _2939 = cb13_010w * 0.9510599970817566f;
                  float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                  float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                  float _2946 = (_2832 - _2943.x) * cb13_063x;
                  float _2948 = _2946 + cb12_229z;
                  if (!(_2946 > 0.0f)) {
                    _2952 = max(0.0f, _2948);
                  } else {
                    _2952 = _2948;
                  }
                  float _2956 = cb13_010w * 0.5877799987792969f;
                  float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                  float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                  float _2963 = (_2832 - _2960.x) * cb13_063x;
                  float _2965 = _2963 + cb12_229z;
                  if (!(_2963 > 0.0f)) {
                    _2969 = max(0.0f, _2965);
                  } else {
                    _2969 = _2965;
                  }
                  float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                  float _2977 = (_2832 - _2974.x) * cb13_063x;
                  float _2979 = _2977 + cb12_229z;
                  if (!(_2977 > 0.0f)) {
                    _2983 = max(0.0f, _2979);
                  } else {
                    _2983 = _2979;
                  }
                  float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                  float _2991 = (_2832 - _2988.x) * cb13_063x;
                  float _2993 = _2991 + cb12_229z;
                  if (!(_2991 > 0.0f)) {
                    _2997 = max(0.0f, _2993);
                  } else {
                    _2997 = _2993;
                  }
                  _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                  _3013 = _2802;
                } else {
                  _3012 = _2802;
                  _3013 = _2802;
                }
              } else {
                _3012 = _2802;
                _3013 = _2802;
              }
            } else {
              _3012 = _2802;
              _3013 = _2802;
            }
          } else {
            _3012 = 1.0f;
            _3013 = _2802;
          }
        }
        float _3020 = ((1.0f - cb12_229y) * 2062.5f) * abs(_3012 * cb12_229w);
        float _3021 = _3020 * _3020;
        float _3023 = exp2(_3021 * -225.4210968017578f);
        float _3028 = exp2(_3021 * -29.807748794555664f);
        float _3036 = exp2(_3021 * -7.714946269989014f);
        float _3042 = exp2(_3021 * -2.544435739517212f);
        float _3044 = _3042 * 0.007000000216066837f;
        float _3049 = exp2(_3021 * -0.7249723672866821f);
        float _3065 = saturate(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3((-0.0f - _456), (-0.0f - _457), (-0.0f - _458))) + 0.30000001192092896f) * (_3013 * _485.z);
        _3098 = (_3065 * ((((((_3028 * 0.10000000149011612f) + (_3023 * 0.2329999953508377f)) + (_3036 * 0.11800000071525574f)) + (_3042 * 0.11299999803304672f)) + (_3049 * 0.3580000102519989f)) + (exp2(_3021 * -0.19469568133354187f) * 0.07800000160932541f)));
        _3099 = (_3065 * (((((_3028 * 0.335999995470047f) + (_3023 * 0.45500001311302185f)) + (_3036 * 0.1979999989271164f)) + _3044) + (_3049 * 0.004000000189989805f)));
        _3100 = (_3065 * (((_3028 * 0.3440000116825104f) + (_3023 * 0.6489999890327454f)) + _3044));
      } else {
        [branch]
        if (_425 > 0.0f) {
          float _3074 = (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_456, _457, _458)) + 1.0f) * 0.5f;
          float _3075 = -0.0f - _481;
          float _3076 = -0.0f - _482;
          float _3077 = -0.0f - _483;
          float _3080 = (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_3075, _3076, _3077)) + 1.0f) * 0.5f;
          float _3083 = _3080 * _3080;
          float _3090 = ((_425 * 0.19050000607967377f) * (dot(float3(_456, _457, _458), float3(_3075, _3076, _3077)) + 1.0f)) * ((((_3083 * _3083) - _3074) * 0.20000000298023224f) + _3074);
          _3098 = select(_2335, (_3090 * _448), _3090);
          _3099 = select(_2335, (_3090 * _449), _3090);
          _3100 = select(_2335, (_3090 * _450), _3090);
        } else {
          _3098 = 0.0f;
          _3099 = 0.0f;
          _3100 = 0.0f;
        }
      }
      float _3101 = graphics_sun_visibility * cb4_032x;
      [branch]
      if (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_456, _457, _458)) > 0.0f) {
        float _3114 = water_light.sun.x + _481;
        float _3115 = water_light.sun.y + _482;
        float _3116 = water_light.sun.z + _483;
        float _3118 = rsqrt(dot(float3(_3114, _3115, _3116), float3(_3114, _3115, _3116)));
        float _3119 = _3118 * _3114;
        float _3120 = _3118 * _3115;
        float _3121 = _3118 * _3116;
        float _3123 = dot(float3(_456, _457, _458), float3(_481, _482, _483));
        float _3125 = saturate(dot(float3(_456, _457, _458), float3(_3119, _3120, _3121)));
        float _3126 = saturate(dot(float3(_456, _457, _458), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
        float _3127 = direct_roughness * direct_roughness;
        float _3128 = _3127 * _3127;
        float _3132 = ((_3125 * _3125) * (_3128 + -1.0f)) + 1.0f;
        float _3136 = abs(_3123);
        float _3140 = saturate(1.0f - abs(dot(float3(_3119, _3120, _3121), float3(_481, _482, _483))));
        float _3141 = _3140 * _3140;
        float _3151 = ((_3141 * _3141) * _3140) * cb13_066x;
        float _3157 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
        [branch]
        if (cb12_221z > 0.0f) {
          float _3167 = saturate(_3123);
          float _3170 = (_3126 * 2.0f) * _3167;
          _3189 = ((((_3167 + _3126) - _3170) * _3127) + _3170);
        } else {
          float _3175 = 1.0f - _3128;
          _3189 = (((sqrt(((_3136 * _3136) * _3175) + _3128) * _3126) + 9.999999747378752e-05f) + (sqrt(((_3126 * _3126) * _3175) + _3128) * _3136));
        }
        float _3190 = 0.5f / _3189;
        float _3191 = _3190 * (_3128 / ((_3132 * _3132) * 3.1415200233459473f));
        if (improved_pbr) _3191 = GraphicsDirectGGX(_3125, _3123, _3126, direct_roughness);
        float _3192 = _3191 * (((_3151 * max(0.0f, _2499)) / _3157) + _436);
        float _3193 = _3191 * (((_3151 * max(0.0f, _2500)) / _3157) + _437);
        float _3194 = _3191 * (((_3151 * max(0.0f, _2501)) / _3157) + _438);
        if (cb12_221y > 0.0f) {
          float4 _3201 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_456, _457, _458), float3(_3190, _3190, _3190))), 0.0f);
          float _3207 = (_3201.x * _436) + _3201.y;
          float _3208 = (_3201.x * _437) + _3201.y;
          float _3209 = (_3201.x * _438) + _3201.y;
          _3244 = ((min((_3207 / max((1.0f - ((1.0f - _3207) * ((_2499 * 0.0476190485060215f) + _436))), 0.0010000000474974513f)), 1.0f) / max(_3207, 9.999999747378752e-05f)) * _3192);
          _3245 = ((min((_3208 / max((1.0f - ((1.0f - _3208) * ((_2500 * 0.0476190485060215f) + _437))), 0.0010000000474974513f)), 1.0f) / max(_3208, 9.999999747378752e-05f)) * _3193);
          _3246 = ((min((_3209 / max((1.0f - ((1.0f - _3209) * ((_2501 * 0.0476190485060215f) + _438))), 0.0010000000474974513f)), 1.0f) / max(_3209, 9.999999747378752e-05f)) * _3194);
        } else {
          _3244 = _3192;
          _3245 = _3193;
          _3246 = _3194;
        }
        _3251 = (_3244 * _3126);
        _3252 = (_3245 * _3126);
        _3253 = (_3246 * _3126);
      } else {
        _3251 = 0.0f;
        _3252 = 0.0f;
        _3253 = 0.0f;
      }
      _3261 = ((_2637 * graphics_sun_visibility) * _3251);
      _3262 = ((_2638 * graphics_sun_visibility) * _3252);
      _3263 = ((_2639 * graphics_sun_visibility) * _3253);
      _3264 = ((_3098 + (select(_2586, (_2582 * 0.31830987334251404f), _2582) * _3101)) * _2637);
      _3265 = ((_3099 + (select(_2586, (_2583 * 0.31830987334251404f), _2583) * _3101)) * _2638);
      _3266 = ((_3100 + (select(_2586, (_2584 * 0.31830987334251404f), _2584) * _3101)) * _2639);
      _3267 = _2493;
      _3268 = _2494;
      _3269 = _2495;
    } else {
      _3261 = 0.0f;
      _3262 = 0.0f;
      _3263 = 0.0f;
      _3264 = 0.0f;
      _3265 = 0.0f;
      _3266 = 0.0f;
      _3267 = 0.0f;
      _3268 = 0.0f;
      _3269 = 0.0f;
    }
  } else {
    _2221 = true;
    float _2224 = _398 + 1.0f;
    float _2233 = saturate((exp2(log2(saturate((dot(float3(_461, _462, _463), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + _398) / _2224)) * cb4_022x) * (cb4_023x - cb4_021x)) + cb4_021x);
    float _2240 = (_2233 * (_456 - _461)) + _461;
    float _2241 = (_2233 * (_457 - _462)) + _462;
    float _2242 = (_2233 * (_458 - _463)) + _463;
    float _2244 = rsqrt(dot(float3(_2240, _2241, _2242), float3(_2240, _2241, _2242)));
    float _2245 = _2240 * _2244;
    float _2246 = _2241 * _2244;
    float _2247 = _2242 * _2244;
    float _2248 = 1.0f / _2224;
    float _2249 = dot(float3(_2245, _2246, _2247), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
    float _2251 = (_2249 + _398) * _2248;
    float _2252 = 1.0f - _346;
    float _2253 = _2245 - _461;
    float _2254 = _2246 - _462;
    float _2255 = _2247 - _463;
    float _2259 = (_2253 * _2252) + _461;
    float _2260 = (_2254 * _2252) + _462;
    float _2261 = (_2255 * _2252) + _463;
    float _2263 = rsqrt(dot(float3(_2259, _2260, _2261), float3(_2259, _2260, _2261)));
    float _2267 = 1.0f - _347;
    float _2271 = (_2253 * _2267) + _461;
    float _2272 = (_2254 * _2267) + _462;
    float _2273 = (_2255 * _2267) + _463;
    float _2275 = rsqrt(dot(float3(_2271, _2272, _2273), float3(_2271, _2272, _2273)));
    float _2279 = 1.0f - _348;
    float _2283 = (_2253 * _2279) + _461;
    float _2284 = (_2254 * _2279) + _462;
    float _2285 = (_2255 * _2279) + _463;
    float _2287 = rsqrt(dot(float3(_2283, _2284, _2285), float3(_2283, _2284, _2285)));
    float _2316 = saturate(_2251 * cb4_030x);
    float _2332 = saturate(select(_2217, _2249, (((_2316 * (1.0f - _414)) + _414) * exp2(log2(saturate(max(((dot(float3((_2259 * _2263), (_2260 * _2263), (_2261 * _2263)), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + _398) * _2248), _2251))) * cb4_031x))));
    float _2333 = saturate(select(_2217, _2249, (((_2316 * (1.0f - _415)) + _415) * exp2(log2(saturate(max(((dot(float3((_2275 * _2271), (_2275 * _2272), (_2275 * _2273)), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + _398) * _2248), _2251))) * cb4_031x))));
    float _2334 = saturate(select(_2217, _2249, (((_2316 * (1.0f - _416)) + _416) * exp2(log2(saturate(max(((dot(float3((_2287 * _2283), (_2287 * _2284), (_2287 * _2285)), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)) + _398) * _2248), _2251))) * cb4_031x))));
    bool _2335 = (_453 == 1);
    if (_2335) {
      float _2337 = saturate(_2249);
      int _2340 = ((int)(uint)((int)(_2247 > 0.0f))) << 1u;
      float _2342 = float((int)(_2340 + -1));
      float _2344 = -1.0f / (_2342 + _2247);
      float _2345 = _2344 * _2246;
      float _2346 = _2345 * _2245;
      float _2350 = (((_2245 * _2245) * _2344) * _2342) + 1.0f;
      float _2351 = _2346 * _2342;
      float _2354 = float((int)(1 - _2340)) * _2245;
      float _2356 = _2342 + (_2345 * _2246);
      float _2357 = -0.0f - _2246;
      float _2359 = rsqrt(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
      float _2360 = _2359 * water_light.sun.x;
      float _2361 = _2359 * water_light.sun.y;
      float _2362 = _2359 * water_light.sun.z;
      float _2365 = mad(_2354, _2362, mad(_2351, _2361, (_2360 * _2350)));
      float _2368 = mad(_2357, _2362, mad(_2356, _2361, (_2360 * _2346)));
      float _2371 = mad(_2247, _2362, mad(_2246, _2361, (_2360 * _2245)));
      float _2373 = rsqrt(dot(float3(_2365, _2368, _2371), float3(_2365, _2368, _2371)));
      float _2376 = _2373 * _2371;
      float _2378 = rsqrt(dot(float3(_481, _482, _483), float3(_481, _482, _483)));
      float _2379 = _2378 * _481;
      float _2380 = _2378 * _482;
      float _2381 = _2378 * _483;
      float _2384 = mad(_2354, _2381, mad(_2351, _2380, (_2379 * _2350)));
      float _2387 = mad(_2357, _2381, mad(_2356, _2380, (_2379 * _2346)));
      float _2390 = mad(_2247, _2381, mad(_2246, _2380, (_2379 * _2245)));
      float _2392 = rsqrt(dot(float3(_2384, _2387, _2390), float3(_2384, _2387, _2390)));
      float _2395 = _2392 * _2390;
      float _2396 = _426 * _426;
      float _2399 = dot(float3((_2373 * _2365), (_2373 * _2368), _2376), float3((_2392 * _2384), (_2392 * _2387), _2395)) - (_2395 * _2376);
      if (_2399 > 0.0f) {
        _2405 = (_2399 / max(_2376, _2395));
      } else {
        _2405 = _2399;
      }
      float _2407 = (_2396 * 0.2877933979034424f) + 1.0f;
      float _2408 = 1.0f / _2407;
      float _2409 = _448 * 0.31830987334251404f;
      float _2410 = _449 * 0.31830987334251404f;
      float _2411 = _450 * 0.31830987334251404f;
      float _2414 = ((_2405 * _2396) + 1.0f) * _2408;
      float _2418 = 1.0f - _2395;
      float _2429 = 1.0f - _2376;
      float _2442 = _2408 * ((_2396 * 0.07248824834823608f) + 1.0f);
      float _2449 = 1.0f - _2442;
      float _2464 = max(1.0000000116860974e-07f, (1.0f - ((((_2429 * _2396) * ((((((_2429 * 0.07144299894571304f) + -0.332181453704834f) * _2429) + 0.4918818771839142f) * _2429) + 0.05710852891206741f)) + 1.0f) / _2407))) * (max(1.0000000116860974e-07f, (1.0f - ((((_2418 * _2396) * ((((((_2418 * 0.07144299894571304f) + -0.332181453704834f) * _2418) + 0.4918818771839142f) * _2418) + 0.05710852891206741f)) + 1.0f) / _2407))) * 0.31830987334251404f);
      float _2468 = max(1.0000000116860974e-07f, _2449);
      float _2479 = max(0.0f, (_2332 - _2337));
      float _2483 = (_2479 * _2409) + ((((_2464 * (((_448 * _448) * _2442) / (1.0f - (_2449 * _448)))) / _2468) + (_2414 * _2409)) * _2337);
      float _2484 = (_2479 * _2410) + ((((_2464 * (((_449 * _449) * _2442) / (1.0f - (_2449 * _449)))) / _2468) + (_2414 * _2410)) * _2337);
      float _2485 = ((((_2464 * (((_450 * _450) * _2442) / (1.0f - (_2449 * _450)))) / _2468) + (_2414 * _2411)) * _2337) + (_2479 * _2411);
      _2490 = _2483;
      _2491 = _2484;
      _2492 = _2485;
      _2493 = (_2483 * 3.1415927410125732f);
      _2494 = (_2484 * 3.1415927410125732f);
      _2495 = (_2485 * 3.1415927410125732f);
    } else {
      _2490 = _2332;
      _2491 = _2333;
      _2492 = _2334;
      _2493 = _2332;
      _2494 = _2333;
      _2495 = _2334;
    }
    // Preserve native skin transmission and environment auxiliary values.
    if (improved_pbr) {
      float3 diffuse = GraphicsSkinDiffuse(float3(_2245, _2246, _2247), float3(_481, _482, _483),
          float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), direct_roughness, float3(_448, _449, _450), _453,
          _453 == 0 ? float3(_2490, _2491, _2492) : _2332.xxx);
      _2490 = diffuse.x; _2491 = diffuse.y; _2492 = diffuse.z;
    }
    float _2499 = 1.0f - _436;
    float _2500 = 1.0f - _437;
    float _2501 = 1.0f - _438;
    if (cb12_221x > 0.0f) {
      float4 _2506 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_2245, _2246, _2247), float3(_481, _482, _483))), 0.0f);
      float _2512 = (_2506.x * _436) + _2506.y;
      float _2513 = (_2506.x * _437) + _2506.y;
      float _2514 = (_2506.x * _438) + _2506.y;
      _2576 = min((_2512 / max((1.0f - ((1.0f - _2512) * ((_2499 * 0.0476190485060215f) + _436))), 0.0010000000474974513f)), 1.0f);
      _2577 = min((_2513 / max((1.0f - ((1.0f - _2513) * ((_2500 * 0.0476190485060215f) + _437))), 0.0010000000474974513f)), 1.0f);
      _2578 = min((_2514 / max((1.0f - ((1.0f - _2514) * ((_2501 * 0.0476190485060215f) + _438))), 0.0010000000474974513f)), 1.0f);
    } else {
      float _2540 = water_light.sun.x + _481;
      float _2541 = water_light.sun.y + _482;
      float _2542 = water_light.sun.z + _483;
      float _2544 = rsqrt(dot(float3(_2540, _2541, _2542), float3(_2540, _2541, _2542)));
      float _2551 = saturate(1.0f - abs(dot(float3((_2544 * _2540), (_2544 * _2541), (_2544 * _2542)), float3(_481, _482, _483))));
      float _2552 = _2551 * _2551;
      float _2562 = ((_2552 * _2552) * _2551) * cb13_066x;
      float _2568 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
      _2576 = (((_2562 * max(0.0f, _2499)) / _2568) + _436);
      _2577 = (((_2562 * max(0.0f, _2500)) / _2568) + _437);
      _2578 = (((_2562 * max(0.0f, _2501)) / _2568) + _438);
    }
    float _2582 = (1.0f - _2576) * _2490;
    float _2583 = (1.0f - _2577) * _2491;
    float _2584 = (1.0f - _2578) * _2492;
    bool _2586 = ((_453 & -3) == 0);
    float _2593 = TEXCOORD_4.x - cb12_000x;
    float _2594 = TEXCOORD_4.y - cb12_000y;
    float _2604 = saturate((cb12_219z * TEXCOORD_4.z) + cb12_219w);
    float _2626 = saturate((cb12_219x * sqrt((_2593 * _2593) + (_2594 * _2594))) + cb12_219y);
    float _2637 = ((((lerp(cb13_062x, cb13_061x, _2604)) - cb13_001x) * _2626) + cb13_001x) * water_light.direct.x;
    float _2638 = ((((lerp(cb13_062y, cb13_061y, _2604)) - cb13_001y) * _2626) + cb13_001y) * water_light.direct.y;
    float _2639 = ((((lerp(cb13_062z, cb13_061z, _2604)) - cb13_001z) * _2626) + cb13_001z) * water_light.direct.z;
    [branch]
    if (_2221) {
      float _2645 = TEXCOORD_4.x - (cb12_229z * _456);
      float _2646 = TEXCOORD_4.y - (cb12_229z * _457);
      float _2647 = TEXCOORD_4.z - (cb12_229z * _458);
      float _2648 = _2645 - cb12_000x;
      float _2649 = _2646 - cb12_000y;
      float _2652 = (_2648 * _2648) + (_2649 * _2649);
      float _2653 = sqrt(_2652);
      [branch]
      if (_2653 < cb13_035x) {
        if (!(cb13_034x == 0)) {
          _2663 = 0;
          while(true) {
            float _2668 = _2645 - (cb13_raw[((int)(_2663 + 37u))].x);
            float _2669 = _2646 - (cb13_raw[((int)(_2663 + 37u))].y);
            float _2674 = dot(float2(_2668, _2669), float2((cb13_raw[((int)(_2663 + 42u))].x), (cb13_raw[((int)(_2663 + 42u))].y)));
            float _2677 = dot(float2(_2668, _2669), float2((cb13_raw[((int)(_2663 + 42u))].z), (cb13_raw[((int)(_2663 + 42u))].w)));
            if ((int)(_2674 > 0.0f) && (int)(_2677 > 0.0f)) {
              if (!((int)(_2674 < 1.0f) && (int)(_2677 < 1.0f))) {
                int _2686 = _2663 + 1;
                if ((uint)_2686 < (uint)cb13_034x) {
                  _2663 = _2686;
                  continue;
                } else {
                  _2725 = 1.0f;
                  float _2728 = cb12_066x * 20.0f;
                  float _2739 = _2647 - cb12_000z;
                  float _2748 = _2647 * 0.009999999776482582f;
                  float _2751 = _2748 / cb12_066x;
                  float _2760 = _2748 / _2728;
                  float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
                  float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
                  float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
                  float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
                  float _2773 = float((int)(int(trunc(cb12_068x))));
                  float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
                  float _2778 = float((int)(int(trunc(cb12_068y))));
                  float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
                  float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
                  float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
                  float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
                  float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
                  if (!(_2802 == 0.0f)) {
                    float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
                    float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
                    float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
                    [branch]
                    if (!(abs(_2832) >= 0.9990000128746033f)) {
                      float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                      [branch]
                      if (!(_2889 < 0.5f)) {
                        if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                          float _2906 = (cb13_010z * _2824) + cb13_010x;
                          float _2907 = cb13_010y - (cb13_010z * _2828);
                          float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                          float _2915 = (_2832 - _2912.x) * cb13_063x;
                          float _2917 = _2915 + cb12_229z;
                          if (!(_2915 > 0.0f)) {
                            _2921 = max(0.0f, _2917);
                          } else {
                            _2921 = _2917;
                          }
                          float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                          float _2929 = (_2832 - _2926.x) * cb13_063x;
                          float _2931 = _2929 + cb12_229z;
                          if (!(_2929 > 0.0f)) {
                            _2935 = max(0.0f, _2931);
                          } else {
                            _2935 = _2931;
                          }
                          float _2939 = cb13_010w * 0.9510599970817566f;
                          float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                          float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                          float _2946 = (_2832 - _2943.x) * cb13_063x;
                          float _2948 = _2946 + cb12_229z;
                          if (!(_2946 > 0.0f)) {
                            _2952 = max(0.0f, _2948);
                          } else {
                            _2952 = _2948;
                          }
                          float _2956 = cb13_010w * 0.5877799987792969f;
                          float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                          float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                          float _2963 = (_2832 - _2960.x) * cb13_063x;
                          float _2965 = _2963 + cb12_229z;
                          if (!(_2963 > 0.0f)) {
                            _2969 = max(0.0f, _2965);
                          } else {
                            _2969 = _2965;
                          }
                          float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                          float _2977 = (_2832 - _2974.x) * cb13_063x;
                          float _2979 = _2977 + cb12_229z;
                          if (!(_2977 > 0.0f)) {
                            _2983 = max(0.0f, _2979);
                          } else {
                            _2983 = _2979;
                          }
                          float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                          float _2991 = (_2832 - _2988.x) * cb13_063x;
                          float _2993 = _2991 + cb12_229z;
                          if (!(_2991 > 0.0f)) {
                            _2997 = max(0.0f, _2993);
                          } else {
                            _2997 = _2993;
                          }
                          _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                          _3013 = _2802;
                        } else {
                          _3012 = _2802;
                          _3013 = _2802;
                        }
                      } else {
                        _3012 = _2802;
                        _3013 = _2802;
                      }
                    } else {
                      _3012 = _2802;
                      _3013 = _2802;
                    }
                  } else {
                    _3012 = 1.0f;
                    _3013 = _2802;
                  }
                }
              } else {
                if ((int)_2663 > (int)-1) {
                  float _2706 = t19.SampleLevel(s10, float3(_2674, _2677, float((int)(_2663))), 0.0f);
                  float _2713 = saturate((((-0.10000000149011612f - _2647) + cb13_036x) + (_2706.x * cb13_035w)) * min(1.0f, (cb13_034z / max(1.0f, (cb13_034w * _2653)))));
                  float _2721 = (saturate((cb13_035y + _2653) * cb13_035z) * _2713) + (1.0f - _2713);
                  if (!(_2721 == 0.0f)) {
                    _2725 = _2721;
                    float _2728 = cb12_066x * 20.0f;
                    float _2739 = _2647 - cb12_000z;
                    float _2748 = _2647 * 0.009999999776482582f;
                    float _2751 = _2748 / cb12_066x;
                    float _2760 = _2748 / _2728;
                    float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
                    float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
                    float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
                    float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
                    float _2773 = float((int)(int(trunc(cb12_068x))));
                    float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
                    float _2778 = float((int)(int(trunc(cb12_068y))));
                    float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
                    float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
                    float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
                    float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
                    float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
                    if (!(_2802 == 0.0f)) {
                      float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
                      float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
                      float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
                      [branch]
                      if (!(abs(_2832) >= 0.9990000128746033f)) {
                        float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                        [branch]
                        if (!(_2889 < 0.5f)) {
                          if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                            float _2906 = (cb13_010z * _2824) + cb13_010x;
                            float _2907 = cb13_010y - (cb13_010z * _2828);
                            float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                            float _2915 = (_2832 - _2912.x) * cb13_063x;
                            float _2917 = _2915 + cb12_229z;
                            if (!(_2915 > 0.0f)) {
                              _2921 = max(0.0f, _2917);
                            } else {
                              _2921 = _2917;
                            }
                            float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                            float _2929 = (_2832 - _2926.x) * cb13_063x;
                            float _2931 = _2929 + cb12_229z;
                            if (!(_2929 > 0.0f)) {
                              _2935 = max(0.0f, _2931);
                            } else {
                              _2935 = _2931;
                            }
                            float _2939 = cb13_010w * 0.9510599970817566f;
                            float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                            float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                            float _2946 = (_2832 - _2943.x) * cb13_063x;
                            float _2948 = _2946 + cb12_229z;
                            if (!(_2946 > 0.0f)) {
                              _2952 = max(0.0f, _2948);
                            } else {
                              _2952 = _2948;
                            }
                            float _2956 = cb13_010w * 0.5877799987792969f;
                            float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                            float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                            float _2963 = (_2832 - _2960.x) * cb13_063x;
                            float _2965 = _2963 + cb12_229z;
                            if (!(_2963 > 0.0f)) {
                              _2969 = max(0.0f, _2965);
                            } else {
                              _2969 = _2965;
                            }
                            float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                            float _2977 = (_2832 - _2974.x) * cb13_063x;
                            float _2979 = _2977 + cb12_229z;
                            if (!(_2977 > 0.0f)) {
                              _2983 = max(0.0f, _2979);
                            } else {
                              _2983 = _2979;
                            }
                            float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                            float _2991 = (_2832 - _2988.x) * cb13_063x;
                            float _2993 = _2991 + cb12_229z;
                            if (!(_2991 > 0.0f)) {
                              _2997 = max(0.0f, _2993);
                            } else {
                              _2997 = _2993;
                            }
                            _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                            _3013 = _2802;
                          } else {
                            _3012 = _2802;
                            _3013 = _2802;
                          }
                        } else {
                          _3012 = _2802;
                          _3013 = _2802;
                        }
                      } else {
                        _3012 = _2802;
                        _3013 = _2802;
                      }
                    } else {
                      _3012 = 1.0f;
                      _3013 = _2802;
                    }
                  } else {
                    _3012 = 1.0f;
                    _3013 = _2721;
                  }
                } else {
                  _2725 = 1.0f;
                  float _2728 = cb12_066x * 20.0f;
                  float _2739 = _2647 - cb12_000z;
                  float _2748 = _2647 * 0.009999999776482582f;
                  float _2751 = _2748 / cb12_066x;
                  float _2760 = _2748 / _2728;
                  float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
                  float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
                  float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
                  float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
                  float _2773 = float((int)(int(trunc(cb12_068x))));
                  float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
                  float _2778 = float((int)(int(trunc(cb12_068y))));
                  float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
                  float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
                  float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
                  float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
                  float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
                  if (!(_2802 == 0.0f)) {
                    float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
                    float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
                    float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
                    [branch]
                    if (!(abs(_2832) >= 0.9990000128746033f)) {
                      float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                      [branch]
                      if (!(_2889 < 0.5f)) {
                        if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                          float _2906 = (cb13_010z * _2824) + cb13_010x;
                          float _2907 = cb13_010y - (cb13_010z * _2828);
                          float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                          float _2915 = (_2832 - _2912.x) * cb13_063x;
                          float _2917 = _2915 + cb12_229z;
                          if (!(_2915 > 0.0f)) {
                            _2921 = max(0.0f, _2917);
                          } else {
                            _2921 = _2917;
                          }
                          float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                          float _2929 = (_2832 - _2926.x) * cb13_063x;
                          float _2931 = _2929 + cb12_229z;
                          if (!(_2929 > 0.0f)) {
                            _2935 = max(0.0f, _2931);
                          } else {
                            _2935 = _2931;
                          }
                          float _2939 = cb13_010w * 0.9510599970817566f;
                          float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                          float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                          float _2946 = (_2832 - _2943.x) * cb13_063x;
                          float _2948 = _2946 + cb12_229z;
                          if (!(_2946 > 0.0f)) {
                            _2952 = max(0.0f, _2948);
                          } else {
                            _2952 = _2948;
                          }
                          float _2956 = cb13_010w * 0.5877799987792969f;
                          float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                          float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                          float _2963 = (_2832 - _2960.x) * cb13_063x;
                          float _2965 = _2963 + cb12_229z;
                          if (!(_2963 > 0.0f)) {
                            _2969 = max(0.0f, _2965);
                          } else {
                            _2969 = _2965;
                          }
                          float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                          float _2977 = (_2832 - _2974.x) * cb13_063x;
                          float _2979 = _2977 + cb12_229z;
                          if (!(_2977 > 0.0f)) {
                            _2983 = max(0.0f, _2979);
                          } else {
                            _2983 = _2979;
                          }
                          float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                          float _2991 = (_2832 - _2988.x) * cb13_063x;
                          float _2993 = _2991 + cb12_229z;
                          if (!(_2991 > 0.0f)) {
                            _2997 = max(0.0f, _2993);
                          } else {
                            _2997 = _2993;
                          }
                          _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                          _3013 = _2802;
                        } else {
                          _3012 = _2802;
                          _3013 = _2802;
                        }
                      } else {
                        _3012 = _2802;
                        _3013 = _2802;
                      }
                    } else {
                      _3012 = _2802;
                      _3013 = _2802;
                    }
                  } else {
                    _3012 = 1.0f;
                    _3013 = _2802;
                  }
                }
              }
            } else {
              int _2686 = _2663 + 1;
              if ((uint)_2686 < (uint)cb13_034x) {
                _2663 = _2686;
                continue;
              } else {
                _2725 = 1.0f;
                float _2728 = cb12_066x * 20.0f;
                float _2739 = _2647 - cb12_000z;
                float _2748 = _2647 * 0.009999999776482582f;
                float _2751 = _2748 / cb12_066x;
                float _2760 = _2748 / _2728;
                float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
                float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
                float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
                float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
                float _2773 = float((int)(int(trunc(cb12_068x))));
                float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
                float _2778 = float((int)(int(trunc(cb12_068y))));
                float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
                float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
                float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
                float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
                float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
                if (!(_2802 == 0.0f)) {
                  float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
                  float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
                  float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
                  [branch]
                  if (!(abs(_2832) >= 0.9990000128746033f)) {
                    float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
                    [branch]
                    if (!(_2889 < 0.5f)) {
                      if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                        float _2906 = (cb13_010z * _2824) + cb13_010x;
                        float _2907 = cb13_010y - (cb13_010z * _2828);
                        float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                        float _2915 = (_2832 - _2912.x) * cb13_063x;
                        float _2917 = _2915 + cb12_229z;
                        if (!(_2915 > 0.0f)) {
                          _2921 = max(0.0f, _2917);
                        } else {
                          _2921 = _2917;
                        }
                        float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                        float _2929 = (_2832 - _2926.x) * cb13_063x;
                        float _2931 = _2929 + cb12_229z;
                        if (!(_2929 > 0.0f)) {
                          _2935 = max(0.0f, _2931);
                        } else {
                          _2935 = _2931;
                        }
                        float _2939 = cb13_010w * 0.9510599970817566f;
                        float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                        float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                        float _2946 = (_2832 - _2943.x) * cb13_063x;
                        float _2948 = _2946 + cb12_229z;
                        if (!(_2946 > 0.0f)) {
                          _2952 = max(0.0f, _2948);
                        } else {
                          _2952 = _2948;
                        }
                        float _2956 = cb13_010w * 0.5877799987792969f;
                        float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                        float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                        float _2963 = (_2832 - _2960.x) * cb13_063x;
                        float _2965 = _2963 + cb12_229z;
                        if (!(_2963 > 0.0f)) {
                          _2969 = max(0.0f, _2965);
                        } else {
                          _2969 = _2965;
                        }
                        float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                        float _2977 = (_2832 - _2974.x) * cb13_063x;
                        float _2979 = _2977 + cb12_229z;
                        if (!(_2977 > 0.0f)) {
                          _2983 = max(0.0f, _2979);
                        } else {
                          _2983 = _2979;
                        }
                        float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                        float _2991 = (_2832 - _2988.x) * cb13_063x;
                        float _2993 = _2991 + cb12_229z;
                        if (!(_2991 > 0.0f)) {
                          _2997 = max(0.0f, _2993);
                        } else {
                          _2997 = _2993;
                        }
                        _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                        _3013 = _2802;
                      } else {
                        _3012 = _2802;
                        _3013 = _2802;
                      }
                    } else {
                      _3012 = _2802;
                      _3013 = _2802;
                    }
                  } else {
                    _3012 = _2802;
                    _3013 = _2802;
                  }
                } else {
                  _3012 = 1.0f;
                  _3013 = _2802;
                }
              }
            }
            break;
          }
        } else {
          _2725 = 1.0f;
          float _2728 = cb12_066x * 20.0f;
          float _2739 = _2647 - cb12_000z;
          float _2748 = _2647 * 0.009999999776482582f;
          float _2751 = _2748 / cb12_066x;
          float _2760 = _2748 / _2728;
          float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
          float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
          float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
          float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
          float _2773 = float((int)(int(trunc(cb12_068x))));
          float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
          float _2778 = float((int)(int(trunc(cb12_068y))));
          float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
          float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
          float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
          float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
          float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
          if (!(_2802 == 0.0f)) {
            float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
            float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
            float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
            [branch]
            if (!(abs(_2832) >= 0.9990000128746033f)) {
              float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
              [branch]
              if (!(_2889 < 0.5f)) {
                if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                  float _2906 = (cb13_010z * _2824) + cb13_010x;
                  float _2907 = cb13_010y - (cb13_010z * _2828);
                  float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                  float _2915 = (_2832 - _2912.x) * cb13_063x;
                  float _2917 = _2915 + cb12_229z;
                  if (!(_2915 > 0.0f)) {
                    _2921 = max(0.0f, _2917);
                  } else {
                    _2921 = _2917;
                  }
                  float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                  float _2929 = (_2832 - _2926.x) * cb13_063x;
                  float _2931 = _2929 + cb12_229z;
                  if (!(_2929 > 0.0f)) {
                    _2935 = max(0.0f, _2931);
                  } else {
                    _2935 = _2931;
                  }
                  float _2939 = cb13_010w * 0.9510599970817566f;
                  float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                  float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                  float _2946 = (_2832 - _2943.x) * cb13_063x;
                  float _2948 = _2946 + cb12_229z;
                  if (!(_2946 > 0.0f)) {
                    _2952 = max(0.0f, _2948);
                  } else {
                    _2952 = _2948;
                  }
                  float _2956 = cb13_010w * 0.5877799987792969f;
                  float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                  float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                  float _2963 = (_2832 - _2960.x) * cb13_063x;
                  float _2965 = _2963 + cb12_229z;
                  if (!(_2963 > 0.0f)) {
                    _2969 = max(0.0f, _2965);
                  } else {
                    _2969 = _2965;
                  }
                  float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                  float _2977 = (_2832 - _2974.x) * cb13_063x;
                  float _2979 = _2977 + cb12_229z;
                  if (!(_2977 > 0.0f)) {
                    _2983 = max(0.0f, _2979);
                  } else {
                    _2983 = _2979;
                  }
                  float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                  float _2991 = (_2832 - _2988.x) * cb13_063x;
                  float _2993 = _2991 + cb12_229z;
                  if (!(_2991 > 0.0f)) {
                    _2997 = max(0.0f, _2993);
                  } else {
                    _2997 = _2993;
                  }
                  _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                  _3013 = _2802;
                } else {
                  _3012 = _2802;
                  _3013 = _2802;
                }
              } else {
                _3012 = _2802;
                _3013 = _2802;
              }
            } else {
              _3012 = _2802;
              _3013 = _2802;
            }
          } else {
            _3012 = 1.0f;
            _3013 = _2802;
          }
        }
      } else {
        _2725 = 1.0f;
        float _2728 = cb12_066x * 20.0f;
        float _2739 = _2647 - cb12_000z;
        float _2748 = _2647 * 0.009999999776482582f;
        float _2751 = _2748 / cb12_066x;
        float _2760 = _2748 / _2728;
        float _2765 = (((cb12_067x + _2645) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000x) / cb13_000z);
        float _2766 = (((cb12_067y + _2646) * 0.009999999776482582f) / cb12_066x) - ((_2751 * cb13_000y) / cb13_000z);
        float _2771 = ((((cb12_067x * 20.0f) + _2645) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000x) / cb13_000z);
        float _2772 = ((((cb12_067y * 20.0f) + _2646) * 0.009999999776482582f) / _2728) - ((_2760 * cb13_000y) / cb13_000z);
        float _2773 = float((int)(int(trunc(cb12_068x))));
        float4 _2776 = t14.SampleLevel(s14, float3(_2765, _2766, _2773), 1.0f);
        float _2778 = float((int)(int(trunc(cb12_068y))));
        float4 _2779 = t14.SampleLevel(s14, float3(_2765, _2766, _2778), 1.0f);
        float _2783 = ((_2779.x - _2776.x) * cb12_066w) + _2776.x;
        float4 _2784 = t14.SampleLevel(s14, float3(_2771, _2772, _2773), 1.0f);
        float4 _2786 = t14.SampleLevel(s14, float3(_2771, _2772, _2778), 1.0f);
        float _2802 = GRAPHICS_CLOUD_VISIBILITY(float3(_2645, _2646, _2647), (1.0f - (((((_2784.x - _2783) + ((_2786.x - _2784.x) * cb12_066w)) * saturate((sqrt(_2652 + (_2739 * _2739)) + -100.0f) * 0.006666666828095913f)) + _2783) * saturate((cb13_000z + -0.25f) * 10.0f)))) * _2725;
        if (!(_2802 == 0.0f)) {
          float _2824 = mad(cb13_005x, _2647, mad(cb13_004x, _2646, (cb13_003x * _2645))) + cb13_006x;
          float _2828 = mad(cb13_005y, _2647, mad(cb13_004y, _2646, (cb13_003y * _2645))) + cb13_006y;
          float _2832 = mad(cb13_005z, _2647, mad(cb13_004z, _2646, (cb13_003z * _2645))) + cb13_006z;
          [branch]
          if (!(abs(_2832) >= 0.9990000128746033f)) {
            float _2889 = dot(float4(float((bool)(uint)(max(abs(_2824 - cb13_007x), abs(_2828 - cb13_008x)) < cb13_009x)), float((bool)(uint)(max(abs(_2824 - cb13_007y), abs(_2828 - cb13_008y)) < cb13_009y)), float((bool)(uint)(max(abs(_2824 - cb13_007z), abs(_2828 - cb13_008z)) < cb13_009z)), float((bool)(uint)(max(abs(_2824 - cb13_007w), abs(_2828 - cb13_008w)) < cb13_009w))), float4(float((bool)(uint)(cb13_014z > 0.5f)), float((bool)(uint)(cb13_014z > 1.5f)), float((bool)(uint)(cb13_014z > 2.5f)), float((bool)(uint)(cb13_014z > 3.5f))));
            [branch]
            if (!(_2889 < 0.5f)) {
              if (!((int)(cb13_014z == 0.0f) || (int)(int(cb13_014z - _2889) != 0))) {
                float _2906 = (cb13_010z * _2824) + cb13_010x;
                float _2907 = cb13_010y - (cb13_010z * _2828);
                float _2912 = t8.SampleLevel(s8, float3(_2906, _2907, 0.0f), 0.0f);
                float _2915 = (_2832 - _2912.x) * cb13_063x;
                float _2917 = _2915 + cb12_229z;
                if (!(_2915 > 0.0f)) {
                  _2921 = max(0.0f, _2917);
                } else {
                  _2921 = _2917;
                }
                float _2926 = t8.SampleLevel(s8, float3(_2906, (_2907 + cb13_010w), 0.0f), 0.0f);
                float _2929 = (_2832 - _2926.x) * cb13_063x;
                float _2931 = _2929 + cb12_229z;
                if (!(_2929 > 0.0f)) {
                  _2935 = max(0.0f, _2931);
                } else {
                  _2935 = _2931;
                }
                float _2939 = cb13_010w * 0.9510599970817566f;
                float _2942 = _2907 + (cb13_010w * 0.3090200126171112f);
                float _2943 = t8.SampleLevel(s8, float3((_2906 + _2939), _2942, 0.0f), 0.0f);
                float _2946 = (_2832 - _2943.x) * cb13_063x;
                float _2948 = _2946 + cb12_229z;
                if (!(_2946 > 0.0f)) {
                  _2952 = max(0.0f, _2948);
                } else {
                  _2952 = _2948;
                }
                float _2956 = cb13_010w * 0.5877799987792969f;
                float _2959 = _2907 - (cb13_010w * 0.8090199828147888f);
                float _2960 = t8.SampleLevel(s8, float3((_2906 + _2956), _2959, 0.0f), 0.0f);
                float _2963 = (_2832 - _2960.x) * cb13_063x;
                float _2965 = _2963 + cb12_229z;
                if (!(_2963 > 0.0f)) {
                  _2969 = max(0.0f, _2965);
                } else {
                  _2969 = _2965;
                }
                float _2974 = t8.SampleLevel(s8, float3((_2906 - _2939), _2942, 0.0f), 0.0f);
                float _2977 = (_2832 - _2974.x) * cb13_063x;
                float _2979 = _2977 + cb12_229z;
                if (!(_2977 > 0.0f)) {
                  _2983 = max(0.0f, _2979);
                } else {
                  _2983 = _2979;
                }
                float _2988 = t8.SampleLevel(s8, float3((_2906 - _2956), _2959, 0.0f), 0.0f);
                float _2991 = (_2832 - _2988.x) * cb13_063x;
                float _2993 = _2991 + cb12_229z;
                if (!(_2991 > 0.0f)) {
                  _2997 = max(0.0f, _2993);
                } else {
                  _2997 = _2993;
                }
                _3012 = ((((((((min(max(abs(_2921), 0.001500000013038516f), 0.05000000074505806f) + 0.014999998733401299f) + min(max(abs(_2935), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2952), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2969), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2983), 0.001500000013038516f), 0.05000000074505806f)) + min(max(abs(_2997), 0.001500000013038516f), 0.05000000074505806f)) * 0.1666666716337204f) + select(((int)int(cb13_014z) > (int)1), 0.0f, 1.0f));
                _3013 = _2802;
              } else {
                _3012 = _2802;
                _3013 = _2802;
              }
            } else {
              _3012 = _2802;
              _3013 = _2802;
            }
          } else {
            _3012 = _2802;
            _3013 = _2802;
          }
        } else {
          _3012 = 1.0f;
          _3013 = _2802;
        }
      }
      float _3020 = ((1.0f - cb12_229y) * 2062.5f) * abs(_3012 * cb12_229w);
      float _3021 = _3020 * _3020;
      float _3023 = exp2(_3021 * -225.4210968017578f);
      float _3028 = exp2(_3021 * -29.807748794555664f);
      float _3036 = exp2(_3021 * -7.714946269989014f);
      float _3042 = exp2(_3021 * -2.544435739517212f);
      float _3044 = _3042 * 0.007000000216066837f;
      float _3049 = exp2(_3021 * -0.7249723672866821f);
      float _3065 = saturate(dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3((-0.0f - _456), (-0.0f - _457), (-0.0f - _458))) + 0.30000001192092896f) * (_3013 * _485.z);
      _3098 = (_3065 * ((((((_3028 * 0.10000000149011612f) + (_3023 * 0.2329999953508377f)) + (_3036 * 0.11800000071525574f)) + (_3042 * 0.11299999803304672f)) + (_3049 * 0.3580000102519989f)) + (exp2(_3021 * -0.19469568133354187f) * 0.07800000160932541f)));
      _3099 = (_3065 * (((((_3028 * 0.335999995470047f) + (_3023 * 0.45500001311302185f)) + (_3036 * 0.1979999989271164f)) + _3044) + (_3049 * 0.004000000189989805f)));
      _3100 = (_3065 * (((_3028 * 0.3440000116825104f) + (_3023 * 0.6489999890327454f)) + _3044));
    } else {
      [branch]
      if (_425 > 0.0f) {
        float _3074 = (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_456, _457, _458)) + 1.0f) * 0.5f;
        float _3075 = -0.0f - _481;
        float _3076 = -0.0f - _482;
        float _3077 = -0.0f - _483;
        float _3080 = (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_3075, _3076, _3077)) + 1.0f) * 0.5f;
        float _3083 = _3080 * _3080;
        float _3090 = ((_425 * 0.19050000607967377f) * (dot(float3(_456, _457, _458), float3(_3075, _3076, _3077)) + 1.0f)) * ((((_3083 * _3083) - _3074) * 0.20000000298023224f) + _3074);
        _3098 = select(_2335, (_3090 * _448), _3090);
        _3099 = select(_2335, (_3090 * _449), _3090);
        _3100 = select(_2335, (_3090 * _450), _3090);
      } else {
        _3098 = 0.0f;
        _3099 = 0.0f;
        _3100 = 0.0f;
      }
    }
    float _3101 = graphics_sun_visibility * cb4_032x;
    [branch]
    if (dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_456, _457, _458)) > 0.0f) {
      float _3114 = water_light.sun.x + _481;
      float _3115 = water_light.sun.y + _482;
      float _3116 = water_light.sun.z + _483;
      float _3118 = rsqrt(dot(float3(_3114, _3115, _3116), float3(_3114, _3115, _3116)));
      float _3119 = _3118 * _3114;
      float _3120 = _3118 * _3115;
      float _3121 = _3118 * _3116;
      float _3123 = dot(float3(_456, _457, _458), float3(_481, _482, _483));
      float _3125 = saturate(dot(float3(_456, _457, _458), float3(_3119, _3120, _3121)));
      float _3126 = saturate(dot(float3(_456, _457, _458), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z)));
      float _3127 = direct_roughness * direct_roughness;
      float _3128 = _3127 * _3127;
      float _3132 = ((_3125 * _3125) * (_3128 + -1.0f)) + 1.0f;
      float _3136 = abs(_3123);
      float _3140 = saturate(1.0f - abs(dot(float3(_3119, _3120, _3121), float3(_481, _482, _483))));
      float _3141 = _3140 * _3140;
      float _3151 = ((_3141 * _3141) * _3140) * cb13_066x;
      float _3157 = (cb13_066z + 1.0f) - (cb13_066z * (1.0f - direct_roughness));
      [branch]
      if (cb12_221z > 0.0f) {
        float _3167 = saturate(_3123);
        float _3170 = (_3126 * 2.0f) * _3167;
        _3189 = ((((_3167 + _3126) - _3170) * _3127) + _3170);
      } else {
        float _3175 = 1.0f - _3128;
        _3189 = (((sqrt(((_3136 * _3136) * _3175) + _3128) * _3126) + 9.999999747378752e-05f) + (sqrt(((_3126 * _3126) * _3175) + _3128) * _3136));
      }
      float _3190 = 0.5f / _3189;
      float _3191 = _3190 * (_3128 / ((_3132 * _3132) * 3.1415200233459473f));
      if (improved_pbr) _3191 = GraphicsDirectGGX(_3125, _3123, _3126, direct_roughness);
      float _3192 = _3191 * (((_3151 * max(0.0f, _2499)) / _3157) + _436);
      float _3193 = _3191 * (((_3151 * max(0.0f, _2500)) / _3157) + _437);
      float _3194 = _3191 * (((_3151 * max(0.0f, _2501)) / _3157) + _438);
      if (cb12_221y > 0.0f) {
        float4 _3201 = t43.SampleLevel(s10, float2(direct_roughness, dot(float3(_456, _457, _458), float3(_3190, _3190, _3190))), 0.0f);
        float _3207 = (_3201.x * _436) + _3201.y;
        float _3208 = (_3201.x * _437) + _3201.y;
        float _3209 = (_3201.x * _438) + _3201.y;
        _3244 = ((min((_3207 / max((1.0f - ((1.0f - _3207) * ((_2499 * 0.0476190485060215f) + _436))), 0.0010000000474974513f)), 1.0f) / max(_3207, 9.999999747378752e-05f)) * _3192);
        _3245 = ((min((_3208 / max((1.0f - ((1.0f - _3208) * ((_2500 * 0.0476190485060215f) + _437))), 0.0010000000474974513f)), 1.0f) / max(_3208, 9.999999747378752e-05f)) * _3193);
        _3246 = ((min((_3209 / max((1.0f - ((1.0f - _3209) * ((_2501 * 0.0476190485060215f) + _438))), 0.0010000000474974513f)), 1.0f) / max(_3209, 9.999999747378752e-05f)) * _3194);
      } else {
        _3244 = _3192;
        _3245 = _3193;
        _3246 = _3194;
      }
      _3251 = (_3244 * _3126);
      _3252 = (_3245 * _3126);
      _3253 = (_3246 * _3126);
    } else {
      _3251 = 0.0f;
      _3252 = 0.0f;
      _3253 = 0.0f;
    }
    _3261 = ((_2637 * graphics_sun_visibility) * _3251);
    _3262 = ((_2638 * graphics_sun_visibility) * _3252);
    _3263 = ((_2639 * graphics_sun_visibility) * _3253);
    _3264 = ((_3098 + (select(_2586, (_2582 * 0.31830987334251404f), _2582) * _3101)) * _2637);
    _3265 = ((_3099 + (select(_2586, (_2583 * 0.31830987334251404f), _2583) * _3101)) * _2638);
    _3266 = ((_3100 + (select(_2586, (_2584 * 0.31830987334251404f), _2584) * _3101)) * _2639);
    _3267 = _2493;
    _3268 = _2494;
    _3269 = _2495;
  }
  if (any(water_light.direct != 1.f)) {
    float3 environment = GraphicsSkinSunEnvironment(float3(_456, _457, _458), float3(_461, _462, _463), float3(_481, _482, _483),
        float3(cb13_000x, cb13_000y, cb13_000z), float3(_448, _449, _450), _426, _453, _398,
        float3(cb4_021x, cb4_022x, cb4_023x), float3(_346, _347, _348), float3(_414, _415, _416),
        cb4_030x, cb4_031x, cb12_229x > 0.f, _485.y);
    _3267 = environment.x; _3268 = environment.y; _3269 = environment.z;
  }
  float _3274 = saturate(saturate(cb4_014x + _249));
  float _3281 = ((_456 - TEXCOORD_3.x) * cb4_024x) + TEXCOORD_3.x;
  float _3282 = ((_457 - TEXCOORD_3.y) * cb4_024x) + TEXCOORD_3.y;
  float _3283 = ((_458 - TEXCOORD_3.z) * cb4_024x) + TEXCOORD_3.z;
  float _3285 = rsqrt(dot(float3(_3281, _3282, _3283), float3(_3281, _3282, _3283)));
  float _3286 = _3285 * _3281;
  float _3287 = _3285 * _3282;
  float _3288 = _3285 * _3283;
  float _3289 = -0.0f - _481;
  float _3290 = -0.0f - _482;
  float _3291 = -0.0f - _483;
  float _3293 = dot(float3(_3289, _3290, _3291), float3(_3286, _3287, _3288)) * 2.0f;
  float _3297 = _3289 - (_3293 * _3286);
  float _3298 = _3290 - (_3293 * _3287);
  float _3299 = _3291 - (_3293 * _3288);
  float _3304 = min(max(max(((_3274 * _3274) * 10.5f), 0.0f), 0.0f), 5.0f);
  _3306 = 1;
  _3307 = 0.0f;
  _3308 = 0.0f;
  _3309 = 0.0f;
  _3310 = 9.999999747378752e-06f;
  while(true) {
    int _3311 = _3306 * 12;
    float _3347 = 1.0f - abs(mad((cb12_raw[(_3311 + 104)].x), TEXCOORD_4.z, mad((cb12_raw[(_3311 + 103)].x), TEXCOORD_4.y, ((cb12_raw[(_3311 + 102)].x) * TEXCOORD_4.x))) + (cb12_raw[(_3311 + 105)].x));
    float _3348 = 1.0f - abs(mad((cb12_raw[(_3311 + 104)].y), TEXCOORD_4.z, mad((cb12_raw[(_3311 + 103)].y), TEXCOORD_4.y, ((cb12_raw[(_3311 + 102)].y) * TEXCOORD_4.x))) + (cb12_raw[(_3311 + 105)].y));
    float _3349 = 1.0f - abs(mad((cb12_raw[(_3311 + 104)].z), TEXCOORD_4.z, mad((cb12_raw[(_3311 + 103)].z), TEXCOORD_4.y, ((cb12_raw[(_3311 + 102)].z) * TEXCOORD_4.x))) + (cb12_raw[(_3311 + 105)].z));
    if (((int)((int)(_3347 > 0.0f) && (int)(_3348 > 0.0f))) && (int)(_3349 > 0.0f)) {
      float _3374 = (((saturate((cb12_raw[(_3311 + 101)].x) * _3347) * (1.0f - _3310)) * saturate((cb12_raw[(_3311 + 101)].y) * _3348)) * saturate((cb12_raw[(_3311 + 101)].z) * _3349)) * (cb12_raw[(_3311 + 100)].x);
      float _3379 = _3374 * (cb12_raw[(_3311 + 106)].x);
      float _3424 = 1.0f / mad((cb12_raw[(_3311 + 109)].x), _3299, mad((cb12_raw[(_3311 + 108)].x), _3298, ((cb12_raw[(_3311 + 107)].x) * _3297)));
      float _3425 = 1.0f / mad((cb12_raw[(_3311 + 109)].y), _3299, mad((cb12_raw[(_3311 + 108)].y), _3298, ((cb12_raw[(_3311 + 107)].y) * _3297)));
      float _3426 = 1.0f / mad((cb12_raw[(_3311 + 109)].z), _3299, mad((cb12_raw[(_3311 + 108)].z), _3298, ((cb12_raw[(_3311 + 107)].z) * _3297)));
      float _3427 = _3424 * (mad((cb12_raw[(_3311 + 109)].x), TEXCOORD_4.z, mad((cb12_raw[(_3311 + 108)].x), TEXCOORD_4.y, ((cb12_raw[(_3311 + 107)].x) * TEXCOORD_4.x))) + (cb12_raw[(_3311 + 110)].x));
      float _3428 = _3425 * (mad((cb12_raw[(_3311 + 109)].y), TEXCOORD_4.z, mad((cb12_raw[(_3311 + 108)].y), TEXCOORD_4.y, ((cb12_raw[(_3311 + 107)].y) * TEXCOORD_4.x))) + (cb12_raw[(_3311 + 110)].y));
      float _3429 = _3426 * (mad((cb12_raw[(_3311 + 109)].z), TEXCOORD_4.z, mad((cb12_raw[(_3311 + 108)].z), TEXCOORD_4.y, ((cb12_raw[(_3311 + 107)].z) * TEXCOORD_4.x))) + (cb12_raw[(_3311 + 110)].z));
      float _3443 = min(max((_3424 - _3427), ((-0.0f - _3424) - _3427)), min(max((_3425 - _3428), ((-0.0f - _3425) - _3428)), max((_3426 - _3429), ((-0.0f - _3426) - _3429))));
      float _3448 = (_3443 * _3297) + (TEXCOORD_4.x - (cb12_raw[(_3311 + 100)].y));
      float _3450 = (_3443 * _3298) + (TEXCOORD_4.y - (cb12_raw[(_3311 + 100)].z));
      float _3452 = (_3443 * _3299) + (TEXCOORD_4.z - (cb12_raw[(_3311 + 100)].w));
      float _3454 = rsqrt(dot(float3(_3448, _3450, _3452), float3(_3448, _3450, _3452)));
      float _3455 = _3448 * _3454;
      float _3456 = _3450 * _3454;
      float _3457 = _3452 * _3454;
      bool _3461 = (_3457 < 0.0f);
      float _3467 = min(max((1.0f / (1.0f - _3457)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float _3475 = min(max((1.0f / (_3457 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float4 _3494 = t23.SampleLevel(s11, float2((((float((bool)_3461) + 0.1666666716337204f) + ((select(_3461, ((_3455 * 0.5f) * _3467), ((_3455 * -0.5f) * _3475)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(asint(cb12_raw[(_3311 + 111)].x))) + 0.1666666716337204f) + ((select(_3461, ((_3456 * -0.5f) * _3467), ((_3456 * 0.5f) * _3475)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _3304);
      _3505 = (_3374 + _3310);
      _3506 = ((_3494.x * _3379) + _3309);
      _3507 = ((_3494.y * _3379) + _3308);
      _3508 = ((_3494.z * _3379) + _3307);
    } else {
      _3505 = _3310;
      _3506 = _3309;
      _3507 = _3308;
      _3508 = _3307;
    }
    int _3509 = _3306 + 1;
    _3511 = (_3505 < 0.9990000128746033f);
    if ((int)((uint)_3509 < (uint)7) && _3511) {
      _3306 = _3509;
      _3307 = _3508;
      _3308 = _3507;
      _3309 = _3506;
      _3310 = _3505;
      continue;
    }
    break;
  }
  [branch]
  if (_3511) {
    float _3523 = cb12_100x * (1.0f - _3505);
    float _3527 = _3523 * cb12_106x;
    bool _3530 = (_3299 < 0.0f);
    float _3536 = min(max((1.0f / (1.0f - _3299)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float _3544 = min(max((1.0f / (_3299 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float4 _3563 = t23.SampleLevel(s11, float2((((float((bool)_3530) + 0.1666666716337204f) + ((select(_3530, ((_3297 * 0.5f) * _3536), ((_3297 * -0.5f) * _3544)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(cb12_111x)) + 0.1666666716337204f) + ((select(_3530, ((_3298 * -0.5f) * _3536), ((_3298 * 0.5f) * _3544)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _3304);
    _3574 = (_3523 + _3505);
    _3575 = ((_3563.x * _3527) + _3506);
    _3576 = ((_3563.y * _3527) + _3507);
    _3577 = ((_3563.z * _3527) + _3508);
  } else {
    _3574 = _3505;
    _3575 = _3506;
    _3576 = _3507;
    _3577 = _3508;
  }
  _3579 = 1;
  _3580 = 0.0f;
  _3581 = 0.0f;
  _3582 = 0.0f;
  _3583 = 9.999999747378752e-06f;
  while(true) {
    int _3584 = _3579 * 12;
    float _3620 = 1.0f - abs(mad((cb12_raw[(_3584 + 104)].x), TEXCOORD_4.z, mad((cb12_raw[(_3584 + 103)].x), TEXCOORD_4.y, ((cb12_raw[(_3584 + 102)].x) * TEXCOORD_4.x))) + (cb12_raw[(_3584 + 105)].x));
    float _3621 = 1.0f - abs(mad((cb12_raw[(_3584 + 104)].y), TEXCOORD_4.z, mad((cb12_raw[(_3584 + 103)].y), TEXCOORD_4.y, ((cb12_raw[(_3584 + 102)].y) * TEXCOORD_4.x))) + (cb12_raw[(_3584 + 105)].y));
    float _3622 = 1.0f - abs(mad((cb12_raw[(_3584 + 104)].z), TEXCOORD_4.z, mad((cb12_raw[(_3584 + 103)].z), TEXCOORD_4.y, ((cb12_raw[(_3584 + 102)].z) * TEXCOORD_4.x))) + (cb12_raw[(_3584 + 105)].z));
    if (((int)((int)(_3620 > 0.0f) && (int)(_3621 > 0.0f))) && (int)(_3622 > 0.0f)) {
      float _3647 = (((saturate((cb12_raw[(_3584 + 101)].x) * _3620) * (1.0f - _3583)) * saturate((cb12_raw[(_3584 + 101)].y) * _3621)) * saturate((cb12_raw[(_3584 + 101)].z) * _3622)) * (cb12_raw[(_3584 + 100)].x);
      float _3652 = _3647 * (cb12_raw[(_3584 + 106)].x);
      float _3697 = 1.0f / mad((cb12_raw[(_3584 + 109)].x), _3299, mad((cb12_raw[(_3584 + 108)].x), _3298, ((cb12_raw[(_3584 + 107)].x) * _3297)));
      float _3698 = 1.0f / mad((cb12_raw[(_3584 + 109)].y), _3299, mad((cb12_raw[(_3584 + 108)].y), _3298, ((cb12_raw[(_3584 + 107)].y) * _3297)));
      float _3699 = 1.0f / mad((cb12_raw[(_3584 + 109)].z), _3299, mad((cb12_raw[(_3584 + 108)].z), _3298, ((cb12_raw[(_3584 + 107)].z) * _3297)));
      float _3700 = _3697 * (mad((cb12_raw[(_3584 + 109)].x), TEXCOORD_4.z, mad((cb12_raw[(_3584 + 108)].x), TEXCOORD_4.y, ((cb12_raw[(_3584 + 107)].x) * TEXCOORD_4.x))) + (cb12_raw[(_3584 + 110)].x));
      float _3701 = _3698 * (mad((cb12_raw[(_3584 + 109)].y), TEXCOORD_4.z, mad((cb12_raw[(_3584 + 108)].y), TEXCOORD_4.y, ((cb12_raw[(_3584 + 107)].y) * TEXCOORD_4.x))) + (cb12_raw[(_3584 + 110)].y));
      float _3702 = _3699 * (mad((cb12_raw[(_3584 + 109)].z), TEXCOORD_4.z, mad((cb12_raw[(_3584 + 108)].z), TEXCOORD_4.y, ((cb12_raw[(_3584 + 107)].z) * TEXCOORD_4.x))) + (cb12_raw[(_3584 + 110)].z));
      float _3716 = min(max((_3697 - _3700), ((-0.0f - _3697) - _3700)), min(max((_3698 - _3701), ((-0.0f - _3698) - _3701)), max((_3699 - _3702), ((-0.0f - _3699) - _3702))));
      float _3721 = (_3716 * _3297) + (TEXCOORD_4.x - (cb12_raw[(_3584 + 100)].y));
      float _3723 = (_3716 * _3298) + (TEXCOORD_4.y - (cb12_raw[(_3584 + 100)].z));
      float _3725 = (_3716 * _3299) + (TEXCOORD_4.z - (cb12_raw[(_3584 + 100)].w));
      float _3727 = rsqrt(dot(float3(_3721, _3723, _3725), float3(_3721, _3723, _3725)));
      float _3728 = _3721 * _3727;
      float _3729 = _3723 * _3727;
      float _3730 = _3725 * _3727;
      bool _3734 = (_3730 < 0.0f);
      float _3740 = min(max((1.0f / (1.0f - _3730)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float _3748 = min(max((1.0f / (_3730 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
      float4 _3767 = t23.SampleLevel(s11, float2((((float((bool)_3734) + 0.1666666716337204f) + ((select(_3734, ((_3728 * 0.5f) * _3740), ((_3728 * -0.5f) * _3748)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(asint(cb12_raw[(_3584 + 111)].x))) + 0.1666666716337204f) + ((select(_3734, ((_3729 * -0.5f) * _3740), ((_3729 * 0.5f) * _3748)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), 5.0f);
      _3778 = (_3647 + _3583);
      _3779 = ((_3767.x * _3652) + _3582);
      _3780 = ((_3767.y * _3652) + _3581);
      _3781 = ((_3767.z * _3652) + _3580);
    } else {
      _3778 = _3583;
      _3779 = _3582;
      _3780 = _3581;
      _3781 = _3580;
    }
    int _3782 = _3579 + 1;
    _3784 = (_3778 < 0.9990000128746033f);
    if ((int)((uint)_3782 < (uint)7) && _3784) {
      _3579 = _3782;
      _3580 = _3781;
      _3581 = _3780;
      _3582 = _3779;
      _3583 = _3778;
      continue;
    }
    break;
  }
  [branch]
  if (_3784) {
    float _3792 = cb12_100x * (1.0f - _3778);
    float _3796 = _3792 * cb12_106x;
    bool _3799 = (_3299 < 0.0f);
    float _3805 = min(max((1.0f / (1.0f - _3299)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float _3813 = min(max((1.0f / (_3299 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
    float4 _3832 = t23.SampleLevel(s11, float2((((float((bool)_3799) + 0.1666666716337204f) + ((select(_3799, ((_3297 * 0.5f) * _3805), ((_3297 * -0.5f) * _3813)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(cb12_111x)) + 0.1666666716337204f) + ((select(_3799, ((_3298 * -0.5f) * _3805), ((_3298 * 0.5f) * _3813)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), 5.0f);
    _3843 = (_3792 + _3778);
    _3844 = ((_3832.x * _3796) + _3779);
    _3845 = ((_3832.y * _3796) + _3780);
    _3846 = ((_3832.z * _3796) + _3781);
  } else {
    _3843 = _3778;
    _3844 = _3779;
    _3845 = _3780;
    _3846 = _3781;
  }
  float _3847 = 1.0f / _3843;
  if (!(cb12_074y > 0.0f)) {
    float _3885 = saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.z) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.z) * TEXCOORD_4.z) + (gridDesc_000[1].PROBE_GRID_DESC_208.z))) + (gridDesc_000[1].PROBE_GRID_DESC_236));
    float _3888 = (_3885 * _3885) * min(saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.x) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.x) * TEXCOORD_4.x) + (gridDesc_000[1].PROBE_GRID_DESC_208.x))) + (gridDesc_000[1].PROBE_GRID_DESC_236)), saturate(((gridDesc_000[1].PROBE_GRID_DESC_224.y) * abs(((gridDesc_000[1].PROBE_GRID_DESC_176.y) * TEXCOORD_4.y) + (gridDesc_000[1].PROBE_GRID_DESC_208.y))) + (gridDesc_000[1].PROBE_GRID_DESC_236)));
    float _3919 = saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.z) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.z) * TEXCOORD_4.z) + (gridDesc_000[0].PROBE_GRID_DESC_208.z))) + (gridDesc_000[0].PROBE_GRID_DESC_236));
    float _3922 = (_3919 * _3919) * min(saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.x) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.x) * TEXCOORD_4.x) + (gridDesc_000[0].PROBE_GRID_DESC_208.x))) + (gridDesc_000[0].PROBE_GRID_DESC_236)), saturate(((gridDesc_000[0].PROBE_GRID_DESC_224.y) * abs(((gridDesc_000[0].PROBE_GRID_DESC_176.y) * TEXCOORD_4.y) + (gridDesc_000[0].PROBE_GRID_DESC_208.y))) + (gridDesc_000[0].PROBE_GRID_DESC_236)));
    bool _3923 = (_3888 > 9.999999717180685e-10f);
    int _3924 = (int)(uint)(_3923);
    bool _3927 = (int)(_3888 < 1.0f) && (int)(_3922 > 9.999999717180685e-10f);
    int _3928 = (int)(uint)(_3927);
    if (_3923) {
      float _3971 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _3286) + TEXCOORD_4.x) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _481);
      float _3972 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _3287) + TEXCOORD_4.y) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _482);
      float _3973 = (((gridDesc_000[1].PROBE_GRID_DESC_152) * _3288) + TEXCOORD_4.z) + ((gridDesc_000[1].PROBE_GRID_DESC_156) * _483);
      float _3977 = (_3971 * (gridDesc_000[1].PROBE_GRID_DESC_176.x)) + (gridDesc_000[1].PROBE_GRID_DESC_192.x);
      float _3978 = (_3972 * (gridDesc_000[1].PROBE_GRID_DESC_176.y)) + (gridDesc_000[1].PROBE_GRID_DESC_192.y);
      float _3979 = (_3973 * (gridDesc_000[1].PROBE_GRID_DESC_176.z)) + (gridDesc_000[1].PROBE_GRID_DESC_192.z);
      int _3989 = min(max(int(_3977), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) + -1u)));
      int _3990 = min(max(int(_3978), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) + -1u)));
      int _3991 = min(max(int(_3979), 0), ((int)(((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) + -1u)));
      float _3992 = float((int)(_3989));
      float _3993 = float((int)(_3990));
      float _3994 = float((int)(_3991));
      float _3995 = _3977 - _3992;
      float _3996 = _3978 - _3993;
      float _3997 = _3979 - _3994;
      _4001 = 0.0f;
      _4002 = 0.0f;
      _4003 = 0.0f;
      _4004 = 0.0f;
      _4005 = 0.0f;
      _4006 = 0;
      while(true) {
        int _4009 = _4006 & 1;
        int _4010 = ((uint)(_4006) >> 1) & 1;
        int _4011 = ((uint)(_4006) >> 2) & 1;
        uint _4012 = _4009 + _3989;
        uint _4013 = _4010 + _3990;
        uint _4014 = _4011 + _3991;
        if (!((int)((int)_4014 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_4012 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) || (int)((int)_4013 >= (int)(gridDesc_000[1].PROBE_GRID_DESC_032.y)))))) {
          int _4027 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.x))) + _4012)) % (gridDesc_000[1].PROBE_GRID_DESC_032.x);
          int _4028 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.y))) + _4013)) % (gridDesc_000[1].PROBE_GRID_DESC_032.y);
          int _4029 = ((int)((((uint)(gridDesc_000[1].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[1].PROBE_GRID_DESC_112.z))) + _4014)) % (gridDesc_000[1].PROBE_GRID_DESC_032.z);
          int _4031 = _4029 + (_4027 * (gridDesc_000[1].PROBE_GRID_DESC_032.z));
          float4 _4034 = t34[1].Load(int3(_4031, _4028, 0));
          uint _4037 = t32[1].Load(int3(_4031, _4028, 0));
          if ((_4037.x & -2) == 2) {
            float _4056 = ((((_3992 - (gridDesc_000[1].PROBE_GRID_DESC_160.x)) + float((int)(_4009))) + (_4034.x * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.x) - _3971);
            float _4062 = ((((_3993 - (gridDesc_000[1].PROBE_GRID_DESC_160.y)) + float((int)(_4010))) + (_4034.y * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.y) - _3972);
            float _4068 = ((((_3994 - (gridDesc_000[1].PROBE_GRID_DESC_160.z)) + float((int)(_4011))) + (_4034.z * 0.44999998807907104f)) * (gridDesc_000[1].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[1].PROBE_GRID_DESC_000.z) - _3973);
            float _4074 = sqrt(((_4056 * _4056) + (_4062 * _4062)) + (_4068 * _4068));
            float _4075 = max(_4074, 9.999999747378752e-06f);
            float _4076 = _4056 / _4075;
            float _4077 = _4062 / _4075;
            float _4078 = _4068 / _4075;
            float _4079 = -0.0f - _4076;
            float _4080 = -0.0f - _4077;
            float _4081 = -0.0f - _4078;
            float _4086 = (abs(_4080) + abs(_4079)) + abs(_4081);
            float _4087 = _4079 / _4086;
            float _4088 = _4080 / _4086;
            if (!((_4081 / _4086) > 0.0f)) {
              _4111 = ((1.0f - abs(_4088)) * float((int)(((int)(uint)((int)(_4087 > 0.0f))) - ((int)(uint)((int)(_4087 < 0.0f))))));
              _4112 = ((1.0f - abs(_4087)) * float((int)(((int)(uint)((int)(_4088 > 0.0f))) - ((int)(uint)((int)(_4088 < 0.0f))))));
            } else {
              _4111 = _4087;
              _4112 = _4088;
            }
            float _4113 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_092));
            float _4116 = (_4113 * 0.5f) / (_4113 + 2.0f);
            float _4119 = 1.0f / float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.x));
            float _4120 = 1.0f / float((int)(gridDesc_000[1].PROBE_GRID_DESC_032.y));
            float _4123 = float((int)(_4027)) + 0.5f;
            float _4124 = float((int)(_4028)) + 0.5f;
            float _4131 = float((int)(_4029));
            float3 _4135 = t30[1].SampleLevel(s7, float3((((_4116 * _4111) + _4123) * _4119), (((_4116 * _4112) + _4124) * _4120), _4131), 0.0f);
            float _4142 = (abs(_3298) + abs(_3297)) + abs(_3299);
            float _4143 = _3297 / _4142;
            float _4144 = _3298 / _4142;
            if (!((_3299 / _4142) > 0.0f)) {
              _4167 = ((1.0f - abs(_4144)) * float((int)(((int)(uint)((int)(_4143 > 0.0f))) - ((int)(uint)((int)(_4143 < 0.0f))))));
              _4168 = ((1.0f - abs(_4143)) * float((int)(((int)(uint)((int)(_4144 > 0.0f))) - ((int)(uint)((int)(_4144 < 0.0f))))));
            } else {
              _4167 = _4143;
              _4168 = _4144;
            }
            float _4169 = float((int)(gridDesc_000[1].PROBE_GRID_DESC_088));
            float _4172 = (_4169 * 0.5f) / (_4169 + 2.0f);
            float4 _4182 = t28[1].SampleLevel(s7, float3((((_4172 * _4167) + _4123) * _4119), (((_4172 * _4168) + _4124) * _4120), _4131), 0.0f);
            float _4186 = (gridDesc_000[1].PROBE_GRID_DESC_104) * 0.5f;
            float _4206 = (select((_4010 != 0), _3996, (1.0f - _3996)) * select((_4009 != 0), _3995, (1.0f - _3995))) * select((_4011 != 0), _3997, (1.0f - _3997));
            if (_4074 > _4135.x) {
              float _4212 = abs(_4135.y - (_4135.x * _4135.x));
              float _4213 = _4074 - _4135.x;
              _4219 = ((_4212 / (_4212 + (_4213 * _4213))) * _4206);
            } else {
              _4219 = _4206;
            }
            float _4224 = saturate((dot(float3(_4076, _4077, _4078), float3(_3286, _3287, _3288)) * 0.5f) + 0.5f) * _4219;
            _4233 = ((_4224 * (pow(_4182.x, _4186))) + _4001);
            _4234 = ((_4224 * (pow(_4182.y, _4186))) + _4002);
            _4235 = ((_4224 * (pow(_4182.z, _4186))) + _4003);
            _4236 = (_4224 + _4004);
            _4237 = (_4206 + _4005);
          } else {
            _4233 = _4001;
            _4234 = _4002;
            _4235 = _4003;
            _4236 = _4004;
            _4237 = _4005;
          }
        } else {
          _4233 = _4001;
          _4234 = _4002;
          _4235 = _4003;
          _4236 = _4004;
          _4237 = _4005;
        }
        int _4238 = _4006 + 1;
        if (!(_4238 == 8)) {
          _4001 = _4233;
          _4002 = _4234;
          _4003 = _4235;
          _4004 = _4236;
          _4005 = _4237;
          _4006 = _4238;
          continue;
        }
        break;
      }
      while(true) {
        if (_4236 > 9.999999747378752e-06f) {
          float _4241 = _4233 / _4236;
          float _4242 = _4234 / _4236;
          float _4243 = _4235 / _4236;
          _4263 = ((_4241 * _4241) * 3.1415927410125732f);
          _4264 = ((_4242 * _4242) * 3.1415927410125732f);
          _4265 = ((_4243 * _4243) * 3.1415927410125732f);
          _4266 = _4236;
        } else {
          if (_4237 > 9.999999747378752e-06f) {
            float _4253 = _4233 / _4237;
            float _4254 = _4234 / _4237;
            float _4255 = _4235 / _4237;
            _4263 = ((_4253 * _4253) * 3.1415927410125732f);
            _4264 = ((_4254 * _4254) * 3.1415927410125732f);
            _4265 = ((_4255 * _4255) * 3.1415927410125732f);
            _4266 = _4237;
          } else {
            _4263 = 0.0f;
            _4264 = 0.0f;
            _4265 = 0.0f;
            _4266 = 0.0f;
          }
        }
        if (!(_4266 < 9.999999747378752e-06f)) {
          _4269 = _4263;
          _4270 = _4264;
          _4271 = _4265;
          if (_3927) {
            _4273 = _4269;
            _4274 = _4270;
            _4275 = _4271;
            _4276 = _3928;
            _4277 = _3924;
            _4278 = _3888;
            float _4324 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _3286) + TEXCOORD_4.x) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _481);
            float _4325 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _3287) + TEXCOORD_4.y) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _482);
            float _4326 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _3288) + TEXCOORD_4.z) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _483);
            float _4330 = (_4324 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
            float _4331 = (_4325 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
            float _4332 = (_4326 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
            int _4342 = min(max(int(_4330), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
            int _4343 = min(max(int(_4331), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
            int _4344 = min(max(int(_4332), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
            float _4345 = float((int)(_4342));
            float _4346 = float((int)(_4343));
            float _4347 = float((int)(_4344));
            float _4348 = _4330 - _4345;
            float _4349 = _4331 - _4346;
            float _4350 = _4332 - _4347;
            _4354 = 0.0f;
            _4355 = 0.0f;
            _4356 = 0.0f;
            _4357 = 0.0f;
            _4358 = 0.0f;
            _4359 = 0;
            while(true) {
              int _4362 = _4359 & 1;
              int _4363 = ((uint)(_4359) >> 1) & 1;
              int _4364 = ((uint)(_4359) >> 2) & 1;
              uint _4365 = _4362 + _4342;
              uint _4366 = _4363 + _4343;
              uint _4367 = _4364 + _4344;
              if (!((int)((int)_4367 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_4365 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_4366 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
                int _4380 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _4365)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
                int _4381 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _4366)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
                int _4382 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _4367)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
                uint _4384 = t38.Load(int4(_4380, _4381, _4382, 0));
                float4 _4390 = t34[0].Load(int3((_4384.x & 511), ((uint)((uint)(_4384.x)) >> 9), 0));
                uint _4392 = t38.Load(int4(_4380, _4381, _4382, 0));
                int _4395 = (uint)((uint)(_4392.x)) >> 7;
                int _4397 = (uint)((uint)(_4392.x)) >> 14;
                if (!((((_4395 | _4392.x) & 127) | _4397) == 0)) {
                  float _4417 = ((((_4345 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_4362))) + (_4390.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _4324);
                  float _4423 = ((((_4346 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_4363))) + (_4390.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _4325);
                  float _4429 = ((((_4347 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_4364))) + (_4390.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _4326);
                  float _4435 = sqrt(((_4417 * _4417) + (_4423 * _4423)) + (_4429 * _4429));
                  float _4436 = max(_4435, 9.999999747378752e-06f);
                  float _4437 = _4417 / _4436;
                  float _4438 = _4423 / _4436;
                  float _4439 = _4429 / _4436;
                  float _4440 = -0.0f - _4437;
                  float _4441 = -0.0f - _4438;
                  float _4442 = -0.0f - _4439;
                  float _4447 = (abs(_4441) + abs(_4440)) + abs(_4442);
                  float _4448 = _4440 / _4447;
                  float _4449 = _4441 / _4447;
                  if (!((_4442 / _4447) > 0.0f)) {
                    _4472 = ((1.0f - abs(_4449)) * float((int)(((int)(uint)((int)(_4448 > 0.0f))) - ((int)(uint)((int)(_4448 < 0.0f))))));
                    _4473 = ((1.0f - abs(_4448)) * float((int)(((int)(uint)((int)(_4449 > 0.0f))) - ((int)(uint)((int)(_4449 < 0.0f))))));
                  } else {
                    _4472 = _4448;
                    _4473 = _4449;
                  }
                  float _4474 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                  float _4477 = (_4474 * 0.5f) / (_4474 + 2.0f);
                  float _4480 = float((int)(_4392.x & 127)) + 0.5f;
                  float _4481 = float((int)(_4395 & 127)) + 0.5f;
                  float _4488 = float((int)(_4397));
                  float3 _4492 = t30[0].SampleLevel(s7, float3((((_4477 * _4472) + _4480) * 0.0078125f), (((_4477 * _4473) + _4481) * 0.0078125f), _4488), 0.0f);
                  float _4499 = (abs(_3298) + abs(_3297)) + abs(_3299);
                  float _4500 = _3297 / _4499;
                  float _4501 = _3298 / _4499;
                  if (!((_3299 / _4499) > 0.0f)) {
                    _4524 = ((1.0f - abs(_4501)) * float((int)(((int)(uint)((int)(_4500 > 0.0f))) - ((int)(uint)((int)(_4500 < 0.0f))))));
                    _4525 = ((1.0f - abs(_4500)) * float((int)(((int)(uint)((int)(_4501 > 0.0f))) - ((int)(uint)((int)(_4501 < 0.0f))))));
                  } else {
                    _4524 = _4500;
                    _4525 = _4501;
                  }
                  float _4526 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                  float _4529 = (_4526 * 0.5f) / (_4526 + 2.0f);
                  float4 _4539 = t28[0].SampleLevel(s7, float3((((_4529 * _4524) + _4480) * 0.0078125f), (((_4529 * _4525) + _4481) * 0.0078125f), _4488), 0.0f);
                  float _4543 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                  float _4563 = (select((_4363 != 0), _4349, (1.0f - _4349)) * select((_4362 != 0), _4348, (1.0f - _4348))) * select((_4364 != 0), _4350, (1.0f - _4350));
                  if (_4435 > _4492.x) {
                    float _4569 = abs(_4492.y - (_4492.x * _4492.x));
                    float _4570 = _4435 - _4492.x;
                    _4576 = ((_4569 / (_4569 + (_4570 * _4570))) * _4563);
                  } else {
                    _4576 = _4563;
                  }
                  float _4581 = saturate((dot(float3(_4437, _4438, _4439), float3(_3286, _3287, _3288)) * 0.5f) + 0.5f) * _4576;
                  _4590 = ((_4581 * (pow(_4539.x, _4543))) + _4354);
                  _4591 = ((_4581 * (pow(_4539.y, _4543))) + _4355);
                  _4592 = ((_4581 * (pow(_4539.z, _4543))) + _4356);
                  _4593 = (_4581 + _4357);
                  _4594 = (_4563 + _4358);
                } else {
                  _4590 = _4354;
                  _4591 = _4355;
                  _4592 = _4356;
                  _4593 = _4357;
                  _4594 = _4358;
                }
              } else {
                _4590 = _4354;
                _4591 = _4355;
                _4592 = _4356;
                _4593 = _4357;
                _4594 = _4358;
              }
              int _4595 = _4359 + 1;
              if (!(_4595 == 8)) {
                _4354 = _4590;
                _4355 = _4591;
                _4356 = _4592;
                _4357 = _4593;
                _4358 = _4594;
                _4359 = _4595;
                continue;
              }
              break;
            }
            while(true) {
              if (_4593 > 9.999999747378752e-06f) {
                float _4598 = _4590 / _4593;
                float _4599 = _4591 / _4593;
                float _4600 = _4592 / _4593;
                _4620 = ((_4598 * _4598) * 3.1415927410125732f);
                _4621 = ((_4599 * _4599) * 3.1415927410125732f);
                _4622 = ((_4600 * _4600) * 3.1415927410125732f);
                _4623 = _4593;
              } else {
                if (_4594 > 9.999999747378752e-06f) {
                  float _4610 = _4590 / _4594;
                  float _4611 = _4591 / _4594;
                  float _4612 = _4592 / _4594;
                  _4620 = ((_4610 * _4610) * 3.1415927410125732f);
                  _4621 = ((_4611 * _4611) * 3.1415927410125732f);
                  _4622 = ((_4612 * _4612) * 3.1415927410125732f);
                  _4623 = _4594;
                } else {
                  _4620 = 0.0f;
                  _4621 = 0.0f;
                  _4622 = 0.0f;
                  _4623 = 0.0f;
                }
              }
              if (_4623 < 9.999999747378752e-06f) {
                _4627 = _4273;
                _4628 = _4274;
                _4629 = _4275;
                _4630 = _4277;
                _4631 = _4278;
                _4632 = 0.0f;
                _4633 = 0;
                _4634 = _4620;
                _4635 = _4621;
                _4636 = _4622;
              } else {
                _4627 = _4273;
                _4628 = _4274;
                _4629 = _4275;
                _4630 = _4277;
                _4631 = _4278;
                _4632 = _3922;
                _4633 = _4276;
                _4634 = _4620;
                _4635 = _4621;
                _4636 = _4622;
              }
              break;
            }
          } else {
            _4627 = _4269;
            _4628 = _4270;
            _4629 = _4271;
            _4630 = _3924;
            _4631 = _3888;
            _4632 = _3922;
            _4633 = _3928;
            _4634 = 0.0f;
            _4635 = 0.0f;
            _4636 = 0.0f;
          }
        } else {
          _4273 = _4263;
          _4274 = _4264;
          _4275 = _4265;
          _4276 = 1;
          _4277 = 0;
          _4278 = 0.0f;
          float _4324 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _3286) + TEXCOORD_4.x) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _481);
          float _4325 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _3287) + TEXCOORD_4.y) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _482);
          float _4326 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _3288) + TEXCOORD_4.z) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _483);
          float _4330 = (_4324 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
          float _4331 = (_4325 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
          float _4332 = (_4326 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
          int _4342 = min(max(int(_4330), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
          int _4343 = min(max(int(_4331), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
          int _4344 = min(max(int(_4332), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
          float _4345 = float((int)(_4342));
          float _4346 = float((int)(_4343));
          float _4347 = float((int)(_4344));
          float _4348 = _4330 - _4345;
          float _4349 = _4331 - _4346;
          float _4350 = _4332 - _4347;
          _4354 = 0.0f;
          _4355 = 0.0f;
          _4356 = 0.0f;
          _4357 = 0.0f;
          _4358 = 0.0f;
          _4359 = 0;
          while(true) {
            int _4362 = _4359 & 1;
            int _4363 = ((uint)(_4359) >> 1) & 1;
            int _4364 = ((uint)(_4359) >> 2) & 1;
            uint _4365 = _4362 + _4342;
            uint _4366 = _4363 + _4343;
            uint _4367 = _4364 + _4344;
            if (!((int)((int)_4367 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_4365 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_4366 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
              int _4380 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _4365)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
              int _4381 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _4366)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
              int _4382 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _4367)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
              uint _4384 = t38.Load(int4(_4380, _4381, _4382, 0));
              float4 _4390 = t34[0].Load(int3((_4384.x & 511), ((uint)((uint)(_4384.x)) >> 9), 0));
              uint _4392 = t38.Load(int4(_4380, _4381, _4382, 0));
              int _4395 = (uint)((uint)(_4392.x)) >> 7;
              int _4397 = (uint)((uint)(_4392.x)) >> 14;
              if (!((((_4395 | _4392.x) & 127) | _4397) == 0)) {
                float _4417 = ((((_4345 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_4362))) + (_4390.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _4324);
                float _4423 = ((((_4346 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_4363))) + (_4390.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _4325);
                float _4429 = ((((_4347 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_4364))) + (_4390.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _4326);
                float _4435 = sqrt(((_4417 * _4417) + (_4423 * _4423)) + (_4429 * _4429));
                float _4436 = max(_4435, 9.999999747378752e-06f);
                float _4437 = _4417 / _4436;
                float _4438 = _4423 / _4436;
                float _4439 = _4429 / _4436;
                float _4440 = -0.0f - _4437;
                float _4441 = -0.0f - _4438;
                float _4442 = -0.0f - _4439;
                float _4447 = (abs(_4441) + abs(_4440)) + abs(_4442);
                float _4448 = _4440 / _4447;
                float _4449 = _4441 / _4447;
                if (!((_4442 / _4447) > 0.0f)) {
                  _4472 = ((1.0f - abs(_4449)) * float((int)(((int)(uint)((int)(_4448 > 0.0f))) - ((int)(uint)((int)(_4448 < 0.0f))))));
                  _4473 = ((1.0f - abs(_4448)) * float((int)(((int)(uint)((int)(_4449 > 0.0f))) - ((int)(uint)((int)(_4449 < 0.0f))))));
                } else {
                  _4472 = _4448;
                  _4473 = _4449;
                }
                float _4474 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
                float _4477 = (_4474 * 0.5f) / (_4474 + 2.0f);
                float _4480 = float((int)(_4392.x & 127)) + 0.5f;
                float _4481 = float((int)(_4395 & 127)) + 0.5f;
                float _4488 = float((int)(_4397));
                float3 _4492 = t30[0].SampleLevel(s7, float3((((_4477 * _4472) + _4480) * 0.0078125f), (((_4477 * _4473) + _4481) * 0.0078125f), _4488), 0.0f);
                float _4499 = (abs(_3298) + abs(_3297)) + abs(_3299);
                float _4500 = _3297 / _4499;
                float _4501 = _3298 / _4499;
                if (!((_3299 / _4499) > 0.0f)) {
                  _4524 = ((1.0f - abs(_4501)) * float((int)(((int)(uint)((int)(_4500 > 0.0f))) - ((int)(uint)((int)(_4500 < 0.0f))))));
                  _4525 = ((1.0f - abs(_4500)) * float((int)(((int)(uint)((int)(_4501 > 0.0f))) - ((int)(uint)((int)(_4501 < 0.0f))))));
                } else {
                  _4524 = _4500;
                  _4525 = _4501;
                }
                float _4526 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
                float _4529 = (_4526 * 0.5f) / (_4526 + 2.0f);
                float4 _4539 = t28[0].SampleLevel(s7, float3((((_4529 * _4524) + _4480) * 0.0078125f), (((_4529 * _4525) + _4481) * 0.0078125f), _4488), 0.0f);
                float _4543 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
                float _4563 = (select((_4363 != 0), _4349, (1.0f - _4349)) * select((_4362 != 0), _4348, (1.0f - _4348))) * select((_4364 != 0), _4350, (1.0f - _4350));
                if (_4435 > _4492.x) {
                  float _4569 = abs(_4492.y - (_4492.x * _4492.x));
                  float _4570 = _4435 - _4492.x;
                  _4576 = ((_4569 / (_4569 + (_4570 * _4570))) * _4563);
                } else {
                  _4576 = _4563;
                }
                float _4581 = saturate((dot(float3(_4437, _4438, _4439), float3(_3286, _3287, _3288)) * 0.5f) + 0.5f) * _4576;
                _4590 = ((_4581 * (pow(_4539.x, _4543))) + _4354);
                _4591 = ((_4581 * (pow(_4539.y, _4543))) + _4355);
                _4592 = ((_4581 * (pow(_4539.z, _4543))) + _4356);
                _4593 = (_4581 + _4357);
                _4594 = (_4563 + _4358);
              } else {
                _4590 = _4354;
                _4591 = _4355;
                _4592 = _4356;
                _4593 = _4357;
                _4594 = _4358;
              }
            } else {
              _4590 = _4354;
              _4591 = _4355;
              _4592 = _4356;
              _4593 = _4357;
              _4594 = _4358;
            }
            int _4595 = _4359 + 1;
            if (!(_4595 == 8)) {
              _4354 = _4590;
              _4355 = _4591;
              _4356 = _4592;
              _4357 = _4593;
              _4358 = _4594;
              _4359 = _4595;
              continue;
            }
            break;
          }
          while(true) {
            if (_4593 > 9.999999747378752e-06f) {
              float _4598 = _4590 / _4593;
              float _4599 = _4591 / _4593;
              float _4600 = _4592 / _4593;
              _4620 = ((_4598 * _4598) * 3.1415927410125732f);
              _4621 = ((_4599 * _4599) * 3.1415927410125732f);
              _4622 = ((_4600 * _4600) * 3.1415927410125732f);
              _4623 = _4593;
            } else {
              if (_4594 > 9.999999747378752e-06f) {
                float _4610 = _4590 / _4594;
                float _4611 = _4591 / _4594;
                float _4612 = _4592 / _4594;
                _4620 = ((_4610 * _4610) * 3.1415927410125732f);
                _4621 = ((_4611 * _4611) * 3.1415927410125732f);
                _4622 = ((_4612 * _4612) * 3.1415927410125732f);
                _4623 = _4594;
              } else {
                _4620 = 0.0f;
                _4621 = 0.0f;
                _4622 = 0.0f;
                _4623 = 0.0f;
              }
            }
            if (_4623 < 9.999999747378752e-06f) {
              _4627 = _4273;
              _4628 = _4274;
              _4629 = _4275;
              _4630 = _4277;
              _4631 = _4278;
              _4632 = 0.0f;
              _4633 = 0;
              _4634 = _4620;
              _4635 = _4621;
              _4636 = _4622;
            } else {
              _4627 = _4273;
              _4628 = _4274;
              _4629 = _4275;
              _4630 = _4277;
              _4631 = _4278;
              _4632 = _3922;
              _4633 = _4276;
              _4634 = _4620;
              _4635 = _4621;
              _4636 = _4622;
            }
            break;
          }
        }
        break;
      }
    } else {
      _4269 = 0.0f;
      _4270 = 0.0f;
      _4271 = 0.0f;
      if (_3927) {
        _4273 = _4269;
        _4274 = _4270;
        _4275 = _4271;
        _4276 = _3928;
        _4277 = _3924;
        _4278 = _3888;
        float _4324 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _3286) + TEXCOORD_4.x) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _481);
        float _4325 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _3287) + TEXCOORD_4.y) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _482);
        float _4326 = (((gridDesc_000[0].PROBE_GRID_DESC_152) * _3288) + TEXCOORD_4.z) + ((gridDesc_000[0].PROBE_GRID_DESC_156) * _483);
        float _4330 = (_4324 * (gridDesc_000[0].PROBE_GRID_DESC_176.x)) + (gridDesc_000[0].PROBE_GRID_DESC_192.x);
        float _4331 = (_4325 * (gridDesc_000[0].PROBE_GRID_DESC_176.y)) + (gridDesc_000[0].PROBE_GRID_DESC_192.y);
        float _4332 = (_4326 * (gridDesc_000[0].PROBE_GRID_DESC_176.z)) + (gridDesc_000[0].PROBE_GRID_DESC_192.z);
        int _4342 = min(max(int(_4330), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) + -1u)));
        int _4343 = min(max(int(_4331), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) + -1u)));
        int _4344 = min(max(int(_4332), 0), ((int)(((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) + -1u)));
        float _4345 = float((int)(_4342));
        float _4346 = float((int)(_4343));
        float _4347 = float((int)(_4344));
        float _4348 = _4330 - _4345;
        float _4349 = _4331 - _4346;
        float _4350 = _4332 - _4347;
        _4354 = 0.0f;
        _4355 = 0.0f;
        _4356 = 0.0f;
        _4357 = 0.0f;
        _4358 = 0.0f;
        _4359 = 0;
        while(true) {
          int _4362 = _4359 & 1;
          int _4363 = ((uint)(_4359) >> 1) & 1;
          int _4364 = ((uint)(_4359) >> 2) & 1;
          uint _4365 = _4362 + _4342;
          uint _4366 = _4363 + _4343;
          uint _4367 = _4364 + _4344;
          if (!((int)((int)_4367 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) || ((int)((int)((int)_4365 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) || (int)((int)_4366 >= (int)(gridDesc_000[0].PROBE_GRID_DESC_032.y)))))) {
            int _4380 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.x)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.x))) + _4365)) % (gridDesc_000[0].PROBE_GRID_DESC_032.x);
            int _4381 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.y)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.y))) + _4366)) % (gridDesc_000[0].PROBE_GRID_DESC_032.y);
            int _4382 = ((int)((((uint)(gridDesc_000[0].PROBE_GRID_DESC_032.z)) - ((uint)(gridDesc_000[0].PROBE_GRID_DESC_112.z))) + _4367)) % (gridDesc_000[0].PROBE_GRID_DESC_032.z);
            uint _4384 = t38.Load(int4(_4380, _4381, _4382, 0));
            float4 _4390 = t34[0].Load(int3((_4384.x & 511), ((uint)((uint)(_4384.x)) >> 9), 0));
            uint _4392 = t38.Load(int4(_4380, _4381, _4382, 0));
            int _4395 = (uint)((uint)(_4392.x)) >> 7;
            int _4397 = (uint)((uint)(_4392.x)) >> 14;
            if (!((((_4395 | _4392.x) & 127) | _4397) == 0)) {
              float _4417 = ((((_4345 - (gridDesc_000[0].PROBE_GRID_DESC_160.x)) + float((int)(_4362))) + (_4390.x * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.x)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.x) - _4324);
              float _4423 = ((((_4346 - (gridDesc_000[0].PROBE_GRID_DESC_160.y)) + float((int)(_4363))) + (_4390.y * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.y)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.y) - _4325);
              float _4429 = ((((_4347 - (gridDesc_000[0].PROBE_GRID_DESC_160.z)) + float((int)(_4364))) + (_4390.z * 0.44999998807907104f)) * (gridDesc_000[0].PROBE_GRID_DESC_016.z)) + ((gridDesc_000[0].PROBE_GRID_DESC_000.z) - _4326);
              float _4435 = sqrt(((_4417 * _4417) + (_4423 * _4423)) + (_4429 * _4429));
              float _4436 = max(_4435, 9.999999747378752e-06f);
              float _4437 = _4417 / _4436;
              float _4438 = _4423 / _4436;
              float _4439 = _4429 / _4436;
              float _4440 = -0.0f - _4437;
              float _4441 = -0.0f - _4438;
              float _4442 = -0.0f - _4439;
              float _4447 = (abs(_4441) + abs(_4440)) + abs(_4442);
              float _4448 = _4440 / _4447;
              float _4449 = _4441 / _4447;
              if (!((_4442 / _4447) > 0.0f)) {
                _4472 = ((1.0f - abs(_4449)) * float((int)(((int)(uint)((int)(_4448 > 0.0f))) - ((int)(uint)((int)(_4448 < 0.0f))))));
                _4473 = ((1.0f - abs(_4448)) * float((int)(((int)(uint)((int)(_4449 > 0.0f))) - ((int)(uint)((int)(_4449 < 0.0f))))));
              } else {
                _4472 = _4448;
                _4473 = _4449;
              }
              float _4474 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_092));
              float _4477 = (_4474 * 0.5f) / (_4474 + 2.0f);
              float _4480 = float((int)(_4392.x & 127)) + 0.5f;
              float _4481 = float((int)(_4395 & 127)) + 0.5f;
              float _4488 = float((int)(_4397));
              float3 _4492 = t30[0].SampleLevel(s7, float3((((_4477 * _4472) + _4480) * 0.0078125f), (((_4477 * _4473) + _4481) * 0.0078125f), _4488), 0.0f);
              float _4499 = (abs(_3298) + abs(_3297)) + abs(_3299);
              float _4500 = _3297 / _4499;
              float _4501 = _3298 / _4499;
              if (!((_3299 / _4499) > 0.0f)) {
                _4524 = ((1.0f - abs(_4501)) * float((int)(((int)(uint)((int)(_4500 > 0.0f))) - ((int)(uint)((int)(_4500 < 0.0f))))));
                _4525 = ((1.0f - abs(_4500)) * float((int)(((int)(uint)((int)(_4501 > 0.0f))) - ((int)(uint)((int)(_4501 < 0.0f))))));
              } else {
                _4524 = _4500;
                _4525 = _4501;
              }
              float _4526 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
              float _4529 = (_4526 * 0.5f) / (_4526 + 2.0f);
              float4 _4539 = t28[0].SampleLevel(s7, float3((((_4529 * _4524) + _4480) * 0.0078125f), (((_4529 * _4525) + _4481) * 0.0078125f), _4488), 0.0f);
              float _4543 = (gridDesc_000[0].PROBE_GRID_DESC_104) * 0.5f;
              float _4563 = (select((_4363 != 0), _4349, (1.0f - _4349)) * select((_4362 != 0), _4348, (1.0f - _4348))) * select((_4364 != 0), _4350, (1.0f - _4350));
              if (_4435 > _4492.x) {
                float _4569 = abs(_4492.y - (_4492.x * _4492.x));
                float _4570 = _4435 - _4492.x;
                _4576 = ((_4569 / (_4569 + (_4570 * _4570))) * _4563);
              } else {
                _4576 = _4563;
              }
              float _4581 = saturate((dot(float3(_4437, _4438, _4439), float3(_3286, _3287, _3288)) * 0.5f) + 0.5f) * _4576;
              _4590 = ((_4581 * (pow(_4539.x, _4543))) + _4354);
              _4591 = ((_4581 * (pow(_4539.y, _4543))) + _4355);
              _4592 = ((_4581 * (pow(_4539.z, _4543))) + _4356);
              _4593 = (_4581 + _4357);
              _4594 = (_4563 + _4358);
            } else {
              _4590 = _4354;
              _4591 = _4355;
              _4592 = _4356;
              _4593 = _4357;
              _4594 = _4358;
            }
          } else {
            _4590 = _4354;
            _4591 = _4355;
            _4592 = _4356;
            _4593 = _4357;
            _4594 = _4358;
          }
          int _4595 = _4359 + 1;
          if (!(_4595 == 8)) {
            _4354 = _4590;
            _4355 = _4591;
            _4356 = _4592;
            _4357 = _4593;
            _4358 = _4594;
            _4359 = _4595;
            continue;
          }
          break;
        }
        while(true) {
          if (_4593 > 9.999999747378752e-06f) {
            float _4598 = _4590 / _4593;
            float _4599 = _4591 / _4593;
            float _4600 = _4592 / _4593;
            _4620 = ((_4598 * _4598) * 3.1415927410125732f);
            _4621 = ((_4599 * _4599) * 3.1415927410125732f);
            _4622 = ((_4600 * _4600) * 3.1415927410125732f);
            _4623 = _4593;
          } else {
            if (_4594 > 9.999999747378752e-06f) {
              float _4610 = _4590 / _4594;
              float _4611 = _4591 / _4594;
              float _4612 = _4592 / _4594;
              _4620 = ((_4610 * _4610) * 3.1415927410125732f);
              _4621 = ((_4611 * _4611) * 3.1415927410125732f);
              _4622 = ((_4612 * _4612) * 3.1415927410125732f);
              _4623 = _4594;
            } else {
              _4620 = 0.0f;
              _4621 = 0.0f;
              _4622 = 0.0f;
              _4623 = 0.0f;
            }
          }
          if (_4623 < 9.999999747378752e-06f) {
            _4627 = _4273;
            _4628 = _4274;
            _4629 = _4275;
            _4630 = _4277;
            _4631 = _4278;
            _4632 = 0.0f;
            _4633 = 0;
            _4634 = _4620;
            _4635 = _4621;
            _4636 = _4622;
          } else {
            _4627 = _4273;
            _4628 = _4274;
            _4629 = _4275;
            _4630 = _4277;
            _4631 = _4278;
            _4632 = _3922;
            _4633 = _4276;
            _4634 = _4620;
            _4635 = _4621;
            _4636 = _4622;
          }
          break;
        }
      } else {
        _4627 = _4269;
        _4628 = _4270;
        _4629 = _4271;
        _4630 = _3924;
        _4631 = _3888;
        _4632 = _3922;
        _4633 = _3928;
        _4634 = 0.0f;
        _4635 = 0.0f;
        _4636 = 0.0f;
      }
    }
    bool _4639 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
    float _4643 = select(_4639, 0.0f, _4634);
    float _4644 = select(_4639, 0.0f, _4635);
    float _4645 = select(_4639, 1.0f, _4636);
    int _4646 = _4633 | _4630;
    if ((int)(_4632 < 1.0f) || (int)(_4646 == 0)) {
      float _4657 = (abs(_3298) + abs(_3297)) + abs(_3299);
      float _4658 = _3297 / _4657;
      float _4659 = _3298 / _4657;
      if (!((_3299 / _4657) > 0.0f)) {
        _4682 = ((1.0f - abs(_4659)) * float((int)(((int)(uint)((int)(_4658 > 0.0f))) - ((int)(uint)((int)(_4658 < 0.0f))))));
        _4683 = ((1.0f - abs(_4658)) * float((int)(((int)(uint)((int)(_4659 > 0.0f))) - ((int)(uint)((int)(_4659 < 0.0f))))));
      } else {
        _4682 = _4658;
        _4683 = _4659;
      }
      float _4684 = float((int)(gridDesc_000[0].PROBE_GRID_DESC_088));
      float _4687 = (_4684 * 0.5f) / (_4684 + 2.0f);
      float4 _4697 = t28[0].SampleLevel(s7, float3((((_4687 * _4682) + 0.5f) * 0.0078125f), (((_4687 * _4683) + 0.5f) * 0.0078125f), 0.0f), 0.0f);
      bool _4706 = ((gridDesc_000[0].PROBE_GRID_DESC_124) == 1);
      float _4707 = select(_4706, 0.0f, (_4697.x * 3.1415927410125732f));
      float _4708 = select(_4706, 1.0f, (_4697.y * 3.1415927410125732f));
      float _4709 = select(_4706, 0.0f, (_4697.z * 3.1415927410125732f));
      _4722 = select((_4646 != 0), _4631, 0.0f);
      _4723 = (lerp(_4707, _4643, _4632));
      _4724 = (lerp(_4708, _4644, _4632));
      _4725 = (lerp(_4709, _4645, _4632));
    } else {
      _4722 = _4631;
      _4723 = _4643;
      _4724 = _4644;
      _4725 = _4645;
    }
    float _4732 = ((select(_4639, 1.0f, _4627) - _4723) * _4722) + _4723;
    float _4733 = ((select(_4639, 0.0f, _4628) - _4724) * _4722) + _4724;
    float _4734 = ((select(_4639, 0.0f, _4629) - _4725) * _4722) + _4725;
    bool _4739 = ((int)((int)(isnan(_4732)) || (int)(isnan(_4733)))) || (int)(isnan(_4734));
    _4746 = select(_4739, 0.0f, _4732);
    _4747 = select(_4739, 0.0f, _4733);
    _4748 = select(_4739, 0.0f, _4734);
    _4749 = (select(_4739, 0.0f, _4722) == 0.0f);
  } else {
    _4746 = 0.0f;
    _4747 = 0.0f;
    _4748 = 0.0f;
    _4749 = true;
  }
  float _4754 = select(_4749, 1.0f, (dot(float3(_4746, _4747, _4748), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f)) / dot(float3((_3847 * _3844), (_3847 * _3845), (_3847 * _3846)), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f)))) * (1.0f / _3574);
  bool _4760 = (cb12_074x > 0.0f);
  float _4767 = FrequentPixelConsts_256.z - FrequentPixelConsts_256.w;
  float _4780 = saturate(saturate(_380 * (pow(cb4_015x, 2.200000047683716f))));
  float _4781 = saturate(saturate(_380 * (pow(cb4_015y, 2.200000047683716f))));
  float _4782 = saturate(saturate(_380 * (pow(cb4_015z, 2.200000047683716f))));
  float _4790 = saturate(1.0f - abs(max(abs(dot(float3(_3286, _3287, _3288), float3(_481, _482, _483))), abs(dot(float3(_461, _462, _463), float3(_481, _482, _483))))));
  float _4791 = _4790 * _4790;
  float _4805 = ((_4791 * _4791) * _4790) * min(saturate(cb4_013x * TEXCOORD_2.z), cb13_066y);
  float _4811 = (cb13_066w + 1.0f) - (cb13_066w * (1.0f - _3274));
  float4 _4822 = t17.Load(int3(_423, _424, 0));
  float _4839 = ((((cb12_069z + -1.0f) * _425) + 1.0f) * (min(saturate((cb12_187x * _4822.x) + cb12_188x), 1.0f) + -1.0f)) + 1.0f;
  bool _4844 = (_485.z < 0.9900000095367432f);
  if (_4844) {
    _4849 = cb12_287w;
  } else {
    _4849 = 1.0f;
  }
  float _4855 = exp2((cb12_288y * _4849) * log2(_4839));
  if (_4844) {
    _4860 = cb12_287w;
  } else {
    _4860 = 1.0f;
  }
  float _4863 = log2((_4839 * cb12_069x) + cb12_069y);
  if (_4844) {
    _4870 = cb12_287w;
  } else {
    _4870 = 1.0f;
  }
  float _4878 = exp2((_4860 * cb12_288z) * _4863) * cb12_184z;
  float _4879 = _4878 * (_3264 + _2205);
  float _4880 = _4878 * (_3265 + _2206);
  float _4881 = _4878 * (_3266 + _2207);
  float _4882 = exp2((_4863 * cb12_288w) * _4870) * cb12_184w;
  float _4883 = _4882 * (_3261 + _2208);
  float _4884 = _4882 * (_3262 + _2209);
  float _4885 = _4882 * (_3263 + _2210);
  bool _4886 = (_453 == 0);
  float _4890 = select(_4886, (_4879 * _448), _4879);
  float _4891 = select(_4886, (_4880 * _449), _4880);
  float _4892 = select(_4886, (_4881 * _450), _4881);
  float _4896 = select(_4760, _4883, (_4883 + (((((_4767 * min(_3267, _485.y)) + FrequentPixelConsts_256.w) * select(_4760, 0.0f, (_4754 * _3575))) * (((_4805 * max(0.0f, (1.0f - _4780))) / _4811) + _4780)) * _4855)));
  float _4897 = select(_4760, _4884, (_4884 + (((((_4767 * min(_3268, _485.y)) + FrequentPixelConsts_256.w) * select(_4760, 0.0f, (_4754 * _3576))) * (((_4805 * max(0.0f, (1.0f - _4781))) / _4811) + _4781)) * _4855)));
  float _4898 = select(_4760, _4885, (_4885 + (((((_4767 * min(_3269, _485.y)) + FrequentPixelConsts_256.w) * select(_4760, 0.0f, (_4754 * _3577))) * (((max(0.0f, (1.0f - _4782)) * _4805) / _4811) + _4782)) * _4855)));
  SV_Target.x = select(_490, _4890, (_4896 + _4890));
  SV_Target.y = select(_490, _4891, (_4897 + _4891));
  SV_Target.z = select(_490, _4892, (_4898 + _4892));
  SV_Target.w = 1.0f;
  SV_Target_1.x = select(_490, _4896, 0.0f);
  SV_Target_1.y = select(_490, _4897, 0.0f);
  SV_Target_1.z = select(_490, _4898, 0.0f);
  SV_Target_1.w = select(_490, 1.0f, 0.0f);
  SV_Target_2.x = _439;
  SV_Target_2.y = _440;
  SV_Target_2.z = _441;
  SV_Target_2.w = _425;
  SV_Target_3.x = _427;
  SV_Target_3.y = _428;
  SV_Target_3.z = _429;
  SV_Target_3.w = 0.021568628028035164f;
  SV_Target_4.x = ((_236 * 0.5f) + 0.5f);
  SV_Target_4.y = ((_237 * 0.5f) + 0.5f);
  SV_Target_4.z = ((_238 * 0.5f) + 0.5f);
  SV_Target_4.w = _426;
  OutputSignature output_signature = { SV_Target, SV_Target_1, SV_Target_2, SV_Target_3, SV_Target_4 };
  return output_signature;
}
