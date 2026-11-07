// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Native oriented-particle baseline; only unused cloud varyings carry volume identity.
#include "clouds/local_volume.hlsli"
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


Texture2D<float4> t22 : register(t22);

Texture2D<float4> t24 : register(t24);

Texture2DArray<float> t19 : register(t19);

Texture2D<float4> t43 : register(t43);

Texture2DArray<float> t8 : register(t8);

Texture2DArray<float> t9 : register(t9);

TextureCubeArray<float> t10 : register(t10);

Texture2DArray<float4> t42 : register(t42);

ByteAddressBuffer t21 : register(t21);

cbuffer cb1 : register(b1) {
  float cb1_000x : packoffset(c000.x);
  float cb1_000y : packoffset(c000.y);
  float cb1_000z : packoffset(c000.z);
  float cb1_000w : packoffset(c000.w);
  float cb1_001x : packoffset(c001.x);
  float cb1_001y : packoffset(c001.y);
  float cb1_001z : packoffset(c001.z);
  float cb1_001w : packoffset(c001.w);
  float cb1_002x : packoffset(c002.x);
  float cb1_002y : packoffset(c002.y);
  float cb1_002z : packoffset(c002.z);
  float cb1_002w : packoffset(c002.w);
  float cb1_003x : packoffset(c003.x);
  float cb1_003y : packoffset(c003.y);
  float cb1_003z : packoffset(c003.z);
  float cb1_003w : packoffset(c003.w);
  float cb1_010x : packoffset(c010.x);
  float cb1_010y : packoffset(c010.y);
  float cb1_010z : packoffset(c010.z);
  float cb1_010w : packoffset(c010.w);
  float cb1_036x : packoffset(c036.x);
  float cb1_036y : packoffset(c036.y);
  float cb1_036z : packoffset(c036.z);
  float cb1_038x : packoffset(c038.x);
  float cb1_038y : packoffset(c038.y);
  float cb1_038z : packoffset(c038.z);
  uint cb1_padding : packoffset(c53.w);
};

cbuffer cb2 : register(b2) {
  row_major float4x4 FrequentVertexConsts_000 : packoffset(c000.x);
  row_major float4x4 FrequentVertexConsts_064 : packoffset(c004.x);
  float4 FrequentVertexConsts_128 : packoffset(c008.x);
  float4 FrequentVertexConsts_144 : packoffset(c009.x);
  float4 FrequentVertexConsts_160 : packoffset(c010.x);
  float4 FrequentVertexConsts_176 : packoffset(c011.x);
  float4 FrequentVertexConsts_192 : packoffset(c012.x);
};

cbuffer cb12 : register(b12) {
  float4 cb12_raw[341] : packoffset(c0);
};

#define cb12_002y (cb12_raw[2].y)
#define cb12_043z (cb12_raw[43].z)
#define cb12_001x (cb12_raw[1].x)
#define cb12_002x (cb12_raw[2].x)
#define cb12_219z (cb12_raw[219].z)
#define cb12_192z (cb12_raw[192].z)
#define cb12_001y (cb12_raw[1].y)
#define cb12_043x (cb12_raw[43].x)
#define cb12_106x (cb12_raw[106].x)
#define cb12_192y (cb12_raw[192].y)
#define cb12_001z (cb12_raw[1].z)
#define cb12_001w (cb12_raw[1].w)
#define cb12_002z (cb12_raw[2].z)
#define cb12_219x (cb12_raw[219].x)
#define cb12_040y (cb12_raw[40].y)
#define cb12_002w (cb12_raw[2].w)
#define cb12_004y (cb12_raw[4].y)
#define cb12_003x (cb12_raw[3].x)
#define cb12_048x (cb12_raw[48].x)
#define cb12_004x (cb12_raw[4].x)
#define cb12_003y (cb12_raw[3].y)
#define cb12_003z (cb12_raw[3].z)
#define cb12_039z (cb12_raw[39].z)
#define cb12_003w (cb12_raw[3].w)
#define cb12_004z (cb12_raw[4].z)
#define cb12_004w (cb12_raw[4].w)
#define cb12_013x (cb12_raw[13].x)
#define cb12_042z (cb12_raw[42].z)
#define cb12_014y (cb12_raw[14].y)
#define cb12_014x (cb12_raw[14].x)
#define cb12_013y (cb12_raw[13].y)
#define cb12_038x (cb12_raw[38].x)
#define cb12_013w (cb12_raw[13].w)
#define cb12_038y (cb12_raw[38].y)
#define cb12_191w (cb12_raw[191].w)
#define cb12_000z (cb12_raw[0].z)
#define cb12_014w (cb12_raw[14].w)
#define cb12_015x (cb12_raw[15].x)
#define cb12_100x (cb12_raw[100].x)
#define cb12_015y (cb12_raw[15].y)
#define cb12_015w (cb12_raw[15].w)
#define cb12_016x (cb12_raw[16].x)
#define cb12_016y (cb12_raw[16].y)
#define cb12_024z (cb12_raw[24].z)
#define cb12_016w (cb12_raw[16].w)
#define cb12_023z (cb12_raw[23].z)
#define cb12_023w (cb12_raw[23].w)
#define cb12_000x (cb12_raw[0].x)
#define cb12_038z (cb12_raw[38].z)
#define cb12_042w (cb12_raw[42].w)
#define cb12_000y (cb12_raw[0].y)
#define cb12_023x (cb12_raw[23].x)
#define cb12_221x (cb12_raw[221].x)
#define cb12_219w (cb12_raw[219].w)
#define cb12_219y (cb12_raw[219].y)
#define cb12_023y (cb12_raw[23].y)
#define cb12_021y (cb12_raw[21].y)
#define cb12_111x (asint(cb12_raw[111].x))
#define cb12_184z (cb12_raw[184].z)
#define cb12_185z (cb12_raw[185].z)
#define cb12_184x (cb12_raw[184].x)
#define cb12_184y (cb12_raw[184].y)
#define cb12_022z (cb12_raw[22].z)
#define cb12_043y (cb12_raw[43].y)
#define cb12_042x (cb12_raw[42].x)
#define cb12_287z (asint(cb12_raw[287].z))
#define cb12_039x (cb12_raw[39].x)
#define cb12_039y (cb12_raw[39].y)
#define cb12_041x (cb12_raw[41].x)
#define cb12_041y (cb12_raw[41].y)
#define cb12_190w (cb12_raw[190].w)
#define cb12_041z (cb12_raw[41].z)
#define cb12_040x (cb12_raw[40].x)
#define cb12_040z (cb12_raw[40].z)
#define cb12_045x (cb12_raw[45].x)
#define cb12_045y (cb12_raw[45].y)
#define cb12_045z (cb12_raw[45].z)
#define cb12_047x (cb12_raw[47].x)
#define cb12_047y (cb12_raw[47].y)
#define cb12_047z (cb12_raw[47].z)
#define cb12_046x (cb12_raw[46].x)
#define cb12_046y (cb12_raw[46].y)
#define cb12_046z (cb12_raw[46].z)
#define cb12_048y (cb12_raw[48].y)
#define cb12_042y (cb12_raw[42].y)
#define cb12_048z (cb12_raw[48].z)
#define cb12_190x (cb12_raw[190].x)
#define cb12_190y (cb12_raw[190].y)
#define cb12_190z (cb12_raw[190].z)
#define cb12_189x (cb12_raw[189].x)
#define cb12_189y (cb12_raw[189].y)
#define cb12_189z (cb12_raw[189].z)
#define cb12_189w (cb12_raw[189].w)
#define cb12_193x (cb12_raw[193].x)
#define cb12_192x (cb12_raw[192].x)
#define cb12_192w (cb12_raw[192].w)
#define cb12_191x (cb12_raw[191].x)
#define cb12_191y (cb12_raw[191].y)
#define cb12_191z (cb12_raw[191].z)

cbuffer cb13 : register(b13) {
  float4 cb13_raw[3589] : packoffset(c0);
};

#define cb13_008x (cb13_raw[8].x)
#define cb13_007y (cb13_raw[7].y)
#define cb13_034w (cb13_raw[34].w)
#define cb13_033z (cb13_raw[33].z)
#define cb13_000x (cb13_raw[0].x)
#define cb13_000y (cb13_raw[0].y)
#define cb13_036x (cb13_raw[36].x)
#define cb13_033x (cb13_raw[33].x)
#define cb13_000z (cb13_raw[0].z)
#define cb13_032y (cb13_raw[32].y)
#define cb13_035x (cb13_raw[35].x)
#define cb13_008w (cb13_raw[8].w)
#define cb13_006y (cb13_raw[6].y)
#define cb13_034x (asint(cb13_raw[34].x))
#define cb13_034z (cb13_raw[34].z)
#define cb13_035w (cb13_raw[35].w)
#define cb13_035y (cb13_raw[35].y)
#define cb13_035z (cb13_raw[35].z)
#define cb13_003z (cb13_raw[3].z)
#define cb13_004z (cb13_raw[4].z)
#define cb13_062y (cb13_raw[62].y)
#define cb13_005z (cb13_raw[5].z)
#define cb13_006z (cb13_raw[6].z)
#define cb13_005x (cb13_raw[5].x)
#define cb13_014z (cb13_raw[14].z)
#define cb13_004y (cb13_raw[4].y)
#define cb13_003x (cb13_raw[3].x)
#define cb13_004x (cb13_raw[4].x)
#define cb13_003y (cb13_raw[3].y)
#define cb13_062z (cb13_raw[62].z)
#define cb13_005y (cb13_raw[5].y)
#define cb13_007w (cb13_raw[7].w)
#define cb13_006x (cb13_raw[6].x)
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
#define cb13_066x (cb13_raw[66].x)
#define cb13_017x (asint(cb13_raw[17].x))
#define cb13_001y (cb13_raw[1].y)
#define cb13_066z (cb13_raw[66].z)
#define cb13_061y (cb13_raw[61].y)
#define cb13_062x (cb13_raw[62].x)
#define cb13_001x (cb13_raw[1].x)
#define cb13_066y (cb13_raw[66].y)
#define cb13_001z (cb13_raw[1].z)
#define cb13_033y (cb13_raw[33].y)
#define cb13_032w (cb13_raw[32].w)
#define cb13_032z (cb13_raw[32].z)
#define cb13_067y (asint(cb13_raw[67].y))
#define cb13_067x (cb13_raw[67].x)
#define cb13_066w (cb13_raw[66].w)

SamplerState s11 : register(s11);

SamplerComparisonState s9 : register(s9);

SamplerState s10 : register(s10);

struct OutputSignature {
  linear float4 output_TEXCOORD : TEXCOORD;
  linear float4 output_TEXCOORD_1 : TEXCOORD1;
  linear float4 output_TEXCOORD_2 : TEXCOORD2;
  linear float4 output_TEXCOORD_3 : TEXCOORD3;
  linear float4 output_TEXCOORD_4 : TEXCOORD4;
  linear float4 output_TEXCOORD_5 : TEXCOORD5;
  linear float4 TEXCOORD_6 : TEXCOORD6;
  linear float4 TEXCOORD_7 : TEXCOORD7;
  noperspective float4 SV_Position : SV_Position;
};

OutputSignature main(
  float3 POSITION : POSITION,
  float4 COLOR : COLOR,
  float3 TEXCOORD : TEXCOORD,
  float2 TEXCOORD_1 : TEXCOORD1,
  float2 TEXCOORD_2 : TEXCOORD2,
  float3 TEXCOORD_3 : TEXCOORD3,
  float TEXCOORD_4 : TEXCOORD4,
  float TEXCOORD_5 : TEXCOORD5
) {
  float4 output_TEXCOORD = 0;
  float4 output_TEXCOORD_1 = 0;
  float4 output_TEXCOORD_2 = 0;
  float4 output_TEXCOORD_3 = 0;
  float4 output_TEXCOORD_4 = 0;
  float4 output_TEXCOORD_5 = 0;
  float4 TEXCOORD_6 = 0;
  float4 TEXCOORD_7 = 0;
  float4 SV_Position = 0;
  float _304;
  float _301;
  float _36[4];
  float _52 = (FrequentVertexConsts_000[0].x) * POSITION.x;
  float _53 = mad(POSITION.y, (FrequentVertexConsts_000[0].y), _52);
  float _54 = mad(POSITION.z, (FrequentVertexConsts_000[0].z), _53);
  float _55 = _54 + (FrequentVertexConsts_000[0].w);
  float _56 = (FrequentVertexConsts_000[1].x) * POSITION.x;
  float _57 = mad(POSITION.y, (FrequentVertexConsts_000[1].y), _56);
  float _58 = mad(POSITION.z, (FrequentVertexConsts_000[1].z), _57);
  float _59 = _58 + (FrequentVertexConsts_000[1].w);
  float _60 = (FrequentVertexConsts_000[2].x) * POSITION.x;
  float _61 = mad(POSITION.y, (FrequentVertexConsts_000[2].y), _60);
  float _62 = mad(POSITION.z, (FrequentVertexConsts_000[2].z), _61);
  float _63 = _62 + (FrequentVertexConsts_000[2].w);
  float _68 = -0.0f - cb1_038x;
  float _69 = -0.0f - cb1_038y;
  float _70 = -0.0f - cb1_038z;
  float _71 = TEXCOORD.y + TEXCOORD.x;
  float _72 = TEXCOORD.x - TEXCOORD.y;
  float _77 = cb1_036x - _55;
  float _78 = cb1_036y - _59;
  float _79 = cb1_036z - _63;
  float _80 = dot(float3(_77, _78, _79), float3(_77, _78, _79));
  float _81 = rsqrt(_80);
  float _82 = _77 * _81;
  float _83 = _78 * _81;
  float _84 = _79 * _81;
  float _85 = dot(float3(TEXCOORD_3.x, TEXCOORD_3.y, TEXCOORD_3.z), float3(TEXCOORD_3.x, TEXCOORD_3.y, TEXCOORD_3.z));
  float _86 = rsqrt(_85);
  float _87 = _86 * TEXCOORD_3.x;
  float _88 = _86 * TEXCOORD_3.y;
  float _89 = _86 * TEXCOORD_3.z;
  float _90 = _89 * _83;
  float _91 = _88 * _84;
  float _92 = _90 - _91;
  float _93 = _87 * _84;
  float _94 = _89 * _82;
  float _95 = _93 - _94;
  float _96 = _88 * _82;
  float _97 = _87 * _83;
  float _98 = _96 - _97;
  float _99 = dot(float3(_92, _95, _98), float3(_92, _95, _98));
  float _100 = rsqrt(_99);
  float _101 = TEXCOORD_4 * TEXCOORD_5;
  float _102 = _101 + 1.0f;
  float _103 = TEXCOORD_1.x * _102;
  float _104 = _103 * _71;
  float _105 = _87 * _104;
  float _106 = _88 * _104;
  float _107 = _89 * _104;
  float _108 = _72 * TEXCOORD_1.y;
  float _109 = _108 * _100;
  float _110 = _109 * _92;
  float _111 = _109 * _95;
  float _112 = _109 * _98;
  float _113 = _105 + _55;
  float _114 = _106 + _59;
  float _115 = _107 + _63;
  float _116 = _113 + _110;
  float _117 = _114 + _111;
  float _118 = _115 + _112;
  float _124 = _116 * cb1_010x;
  float _125 = mad(_117, cb1_010y, _124);
  float _126 = mad(_118, cb1_010z, _125);
  float _127 = _126 + cb1_010w;
  float _148 = cb1_000x * _116;
  float _149 = mad(_117, cb1_000y, _148);
  float _150 = mad(_118, cb1_000z, _149);
  float _151 = _150 + cb1_000w;
  float _152 = cb1_001x * _116;
  float _153 = mad(_117, cb1_001y, _152);
  float _154 = mad(_118, cb1_001z, _153);
  float _155 = _154 + cb1_001w;
  float _156 = cb1_002x * _116;
  float _157 = mad(_117, cb1_002y, _156);
  float _158 = mad(_118, cb1_002z, _157);
  float _159 = _158 + cb1_002w;
  float _160 = cb1_003x * _116;
  float _161 = mad(_117, cb1_003y, _160);
  float _162 = mad(_118, cb1_003z, _161);
  float _163 = _162 + cb1_003w;
  float _164 = -0.0f - _105;
  float _165 = -0.0f - _106;
  float _166 = -0.0f - _107;
  float _167 = dot(float3(_164, _165, _166), float3(_164, _165, _166));
  float _168 = rsqrt(_167);
  float _169 = _168 * _164;
  float _170 = _168 * _165;
  float _171 = _168 * _166;
  float _172 = dot(float3(_110, _111, _112), float3(_110, _111, _112));
  float _173 = rsqrt(_172);
  float _174 = _173 * _110;
  float _175 = _173 * _111;
  float _176 = _173 * _112;
  float _197 = cb12_001x * _116;
  float _198 = mad(cb12_002x, _117, _197);
  float _199 = mad(cb12_003x, _118, _198);
  float _200 = _199 + cb12_004x;
  float _201 = cb12_001y * _116;
  float _202 = mad(cb12_002y, _117, _201);
  float _203 = mad(cb12_003y, _118, _202);
  float _204 = _203 + cb12_004y;
  float _205 = cb12_001z * _116;
  float _206 = mad(cb12_002z, _117, _205);
  float _207 = mad(cb12_003z, _118, _206);
  float _208 = _207 + cb12_004z;
  float _209 = cb12_001w * _116;
  float _210 = mad(cb12_002w, _117, _209);
  float _211 = mad(cb12_003w, _118, _210);
  float _212 = _211 + cb12_004w;
  float _229 = cb12_013x * _200;
  float _230 = mad(cb12_014x, _204, _229);
  float _231 = mad(cb12_015x, _208, _230);
  float _232 = mad(cb12_016x, _212, _231);
  float _233 = cb12_013y * _200;
  float _234 = mad(cb12_014y, _204, _233);
  float _235 = mad(cb12_015y, _208, _234);
  float _236 = mad(cb12_016y, _212, _235);
  float _237 = cb12_013w * _200;
  float _238 = mad(cb12_014w, _204, _237);
  float _239 = mad(cb12_015w, _208, _238);
  float _240 = mad(cb12_016w, _212, _239);
  float _241 = max(9.999999747378752e-05f, _240);
  float _242 = _232 / _241;
  float _243 = _236 / _241;
  float _244 = _242 * 0.5f;
  float _245 = _243 * 0.5f;
  float _246 = _244 + 0.5f;
  float _247 = 0.5f - _245;
  float _251 = cb12_023z * 0.5f;
  float _252 = cb12_023w * 0.5f;
  float _253 = 1.0f - _251;
  float _254 = 1.0f - _252;
  float _255 = max(_246, _251);
  float _256 = max(_247, _252);
  float _257 = min(_255, _253);
  float _258 = min(_256, _254);
  float _267 = cb12_000x - _116;
  float _268 = cb12_000y - _117;
  float _269 = cb12_000z - _118;
  float _270 = dot(float3(_267, _268, _269), float3(_267, _268, _269));
  float _271 = rsqrt(_270);
  float _272 = _267 * _271;
  float _273 = _268 * _271;
  float _274 = _269 * _271;
  float _275 = _116 - cb12_000x;
  float _276 = _117 - cb12_000y;
  float _277 = _275 * _275;
  float _278 = _276 * _276;
  float _279 = _277 + _278;
  float _280 = sqrt(_279);
  bool _283 = (_280 < cb13_035x);
  int _290;
  int _318;
  int _320;
  float _321;
  float _322;
  float _353;
  float _390;
  float _391;
  int _392;
  int _393;
  float _395;
  int _396;
  int _397;
  float _779;
  float _785;
  float _786;
  int _787;
  float _795;
  float _840;
  float _894;
  float _895;
  float _896;
  float _897;
  float _979;
  float _980;
  float _1023;
  float _1024;
  float _1025;
  float _1026;
  int _1027;
  float _1112;
  float _1113;
  float _1114;
  float _1115;
  float _1121;
  float _1122;
  float _1123;
  float _1124;
  float _1128;
  float _1129;
  float _1130;
  float _1131;
  int _1157;
  float _1158;
  float _1159;
  float _1160;
  float _1161;
  float _1162;
  float _1163;
  int _1164;
  float _1240;
  float _1352;
  float _1353;
  float _1354;
  float _1355;
  float _1435;
  float _1436;
  float _1437;
  float _1438;
  float _1442;
  float _1443;
  float _1444;
  float _1445;
  int _1446;
  float _1487;
  int _1500;
  int _1501;
  float _1536;
  float _1537;
  float _1538;
  float _1543;
  float _1544;
  float _1545;
  float _1546;
  int _1547;
  float _1560;
  float _1621;
  float _1642;
  float _1643;
  float _1644;
  float _1645;
  float _1646;
  float _1647;
  float _1654;
  float _1655;
  float _1656;
  float _1657;
  float _1658;
  float _1659;
  int _1689;
  float _1690;
  float _1691;
  float _1692;
  float _1693;
  float _1748;
  float _1797;
  float _1798;
  float _1799;
  float _1800;
  float _1832;
  float _1833;
  float _1834;
  float _1835;
  bool _1931;
  float _1939;
  float _1953;
  float _1954;
  float _1955;
  float _1980;
  float _1981;
  float _1982;
  float _2137;
  float _2138;
  float _2221;
  float _2222;
  float _2223;
  float _2224;
  [branch]
  if (_283) {
    bool _287 = (cb13_034x == 0);
    if (!_287) {
      _290 = 0;
      while(true) {
        uint _291 = _290 + 37u;
        float _295 = _116 - (cb13_raw[_291].x);
        float _296 = _117 - (cb13_raw[_291].y);
        uint _297 = _290 + 42u;
        _301 = dot(float2(_295, _296), float2((cb13_raw[_297].x), (cb13_raw[_297].y)));
        _304 = dot(float2(_295, _296), float2((cb13_raw[_297].z), (cb13_raw[_297].w)));
        bool _305 = (_301 > 0.0f);
        bool _306 = (_304 > 0.0f);
        bool _307 = _305 && _306;
        if (_307) {
          bool _309 = (_301 < 1.0f);
          bool _310 = (_304 < 1.0f);
          bool _311 = _309 && _310;
          if (!_311) {
            int _313 = _290 + 1;
            bool _316 = ((uint)_313 < (uint)cb13_034x);
            if (_316) {
              _290 = _313;
              continue;
            } else {
              _318 = -1;
            }
          } else {
            _318 = _290;
          }
        } else {
          int _313 = _290 + 1;
          bool _316 = ((uint)_313 < (uint)cb13_034x);
          if (_316) {
            _290 = _313;
            continue;
          } else {
            _318 = -1;
          }
        }
        break;
      }
      _320 = _318;
      _321 = _301;
      _322 = _304;
    } else {
      _320 = -1;
      _321 = 0.0f;
      _322 = 0.0f;
    }
    bool _323 = ((int)_320 > (int)-1);
    if (_323) {
      float _328 = cb13_034w * _280;
      float _329 = max(1.0f, _328);
      float _330 = cb13_034z / _329;
      float _331 = min(1.0f, _330);
      float _335 = float((int)(_320));
      float _336 = t19.SampleLevel(s10, float3(_321, _322, _335), 0.0f);
      float _338 = _336.x * cb13_035w;
      float _339 = -0.10000000149011612f - _118;
      float _340 = _339 + cb13_036x;
      float _341 = _340 + _338;
      float _342 = _341 * _331;
      float _343 = saturate(_342);
      float _344 = 1.0f - _343;
      float _346 = cb13_035y + _280;
      float _348 = _346 * cb13_035z;
      float _349 = saturate(_348);
      float _350 = _349 * _343;
      float _351 = _344 + _350;
      _353 = _351;
    } else {
      _353 = 1.0f;
    }
  } else {
    _353 = 1.0f;
  }
  bool _354 = (_353 > 0.0f);
  if (_354) {
    float _364 = cb13_003z * _116;
    float _365 = mad(cb13_004z, _117, _364);
    float _366 = mad(cb13_005z, _118, _365);
    float _367 = _366 + cb13_006z;
    float _368 = abs(_367);
    bool _369 = (_368 < 0.9990000128746033f);
    [branch]
    if (_369) {
      bool _373 = (cb13_014z > 0.5f);
      bool _374 = (cb13_014z > 1.5f);
      bool _375 = (cb13_014z > 2.5f);
      bool _376 = (cb13_014z > 3.5f);
      float _377 = float((bool)_373);
      float _378 = float((bool)_374);
      float _379 = float((bool)_375);
      float _380 = float((bool)_376);
      float _381 = -0.0f - cb13_000x;
      float _382 = dot(float3(cb13_000y, _381, 0.0f), float3(cb13_000y, _381, 0.0f));
      float _383 = rsqrt(_382);
      float _384 = _383 * cb13_000y;
      float _385 = _383 * _381;
      float _386 = _384 * cb13_000y;
      float _387 = _385 * cb13_000x;
      float _388 = _386 - _387;
      _390 = _353;
      _391 = 0.0f;
      _392 = 0;
      _393 = -2;
      while(true) {
        _395 = _391;
        _396 = _392;
        _397 = -2;
        while(true) {
          float _398 = float((int)(_393));
          float _399 = _398 * _384;
          float _400 = _398 * _385;
          float _401 = float((int)(_397));
          float _402 = _401 * cb13_000z;
          float _403 = _402 * _385;
          float _404 = _402 * _384;
          float _405 = _403 + _399;
          float _406 = _400 - _404;
          float _407 = _405 * 0.75f;
          float _408 = _406 * 0.75f;
          float _409 = _388 * 0.75f;
          float _410 = _409 * _401;
          float _411 = _407 + _116;
          float _412 = _408 + _117;
          float _413 = _410 + _118;
          float _430 = _411 * cb13_003x;
          float _431 = mad(cb13_004x, _412, _430);
          float _432 = mad(cb13_005x, _413, _431);
          float _433 = _432 + cb13_006x;
          float _434 = _411 * cb13_003y;
          float _435 = mad(cb13_004y, _412, _434);
          float _436 = mad(cb13_005y, _413, _435);
          float _437 = _436 + cb13_006y;
          float _438 = _411 * cb13_003z;
          float _439 = mad(cb13_004z, _412, _438);
          float _440 = mad(cb13_005z, _413, _439);
          float _441 = _440 + cb13_006z;
          float _447 = _433 - cb13_007x;
          float _448 = _433 - cb13_007y;
          float _449 = _433 - cb13_007z;
          float _450 = _433 - cb13_007w;
          float _456 = _437 - cb13_008x;
          float _457 = _437 - cb13_008y;
          float _458 = _437 - cb13_008z;
          float _459 = _437 - cb13_008w;
          float _460 = abs(_456);
          float _461 = abs(_457);
          float _462 = abs(_458);
          float _463 = abs(_459);
          float _464 = abs(_447);
          float _465 = abs(_448);
          float _466 = abs(_449);
          float _467 = abs(_450);
          float _468 = max(_464, _460);
          float _469 = max(_465, _461);
          float _470 = max(_466, _462);
          float _471 = max(_467, _463);
          bool _477 = (_468 < cb13_009x);
          bool _478 = (_469 < cb13_009y);
          bool _479 = (_470 < cb13_009z);
          bool _480 = (_471 < cb13_009w);
          float _481 = float((bool)_477);
          float _482 = float((bool)_478);
          float _483 = float((bool)_479);
          float _484 = float((bool)_480);
          float _485 = dot(float4(_481, _482, _483, _484), float4(_377, _378, _379, _380));
          bool _486 = (_485 < 0.5f);
          [branch]
          if (!_486) {
            float _488 = cb13_014z - _485;
            int _489 = int(_488);
            uint _490 = _489 + 10u;
            float _495 = (cb13_raw[_490].z) * _433;
            float _496 = (cb13_raw[_490].z) * _437;
            float _497 = _495 + (cb13_raw[_490].x);
            float _498 = (cb13_raw[_490].y) - _496;
            float _500 = float((int)(_489));
            bool _503 = ((int)cb13_017x > (int)0);
            float _504 = t8.SampleCmpLevelZero(s9, float3(_497, _498, _500), _441);
            if (_503) {
              float _507 = (cb13_raw[_490].w) * 0.2633539140224457f;
              float _508 = (cb13_raw[_490].w) * 0.03965381905436516f;
              float _509 = _497 - _507;
              float _510 = _498 + _508;
              float _511 = t8.SampleCmpLevelZero(s9, float3(_509, _510, _500), _441);
              float _513 = _511.x + _504.x;
              float _514 = (cb13_raw[_490].w) * 0.7172024250030518f;
              float _515 = (cb13_raw[_490].w) * 0.3683032989501953f;
              float _516 = _497 - _514;
              float _517 = _498 + _515;
              float _518 = t8.SampleCmpLevelZero(s9, float3(_516, _517, _500), _441);
              float _520 = _513 + _518.x;
              float _521 = (cb13_raw[_490].w) * 0.019953060895204544f;
              float _522 = (cb13_raw[_490].w) * 0.39883920550346375f;
              float _523 = _497 - _521;
              float _524 = _498 - _522;
              float _525 = t8.SampleCmpLevelZero(s9, float3(_523, _524, _500), _441);
              float _527 = _520 + _525.x;
              float _528 = (cb13_raw[_490].w) * 0.4409937858581543f;
              float _529 = (cb13_raw[_490].w) * 0.2210099995136261f;
              float _530 = _497 - _528;
              float _531 = _498 - _529;
              float _532 = t8.SampleCmpLevelZero(s9, float3(_530, _531, _500), _441);
              float _534 = _527 + _532.x;
              float _535 = (cb13_raw[_490].w) * 0.22003920376300812f;
              float _536 = (cb13_raw[_490].w) * 0.29434481263160706f;
              float _537 = _497 + _535;
              float _538 = _498 + _536;
              float _539 = t8.SampleCmpLevelZero(s9, float3(_537, _538, _500), _441);
              float _541 = _534 + _539.x;
              float _542 = (cb13_raw[_490].w) * 0.7675657272338867f;
              float _543 = (cb13_raw[_490].w) * 0.14827530086040497f;
              float _544 = _497 - _542;
              float _545 = _498 - _543;
              float _546 = t8.SampleCmpLevelZero(s9, float3(_544, _545, _500), _441);
              float _548 = _541 + _546.x;
              float _549 = (cb13_raw[_490].w) * 0.23810189962387085f;
              float _550 = (cb13_raw[_490].w) * 0.5471062064170837f;
              float _551 = _497 - _549;
              float _552 = _498 + _550;
              float _553 = t8.SampleCmpLevelZero(s9, float3(_551, _552, _500), _441);
              float _555 = _548 + _553.x;
              float _556 = (cb13_raw[_490].w) * 0.2173030972480774f;
              float _557 = (cb13_raw[_490].w) * 0.13458789885044098f;
              float _558 = _497 + _556;
              float _559 = _498 - _557;
              float _560 = t8.SampleCmpLevelZero(s9, float3(_558, _559, _500), _441);
              float _562 = _555 + _560.x;
              float _563 = (cb13_raw[_490].w) * 0.6387773752212524f;
              float _564 = (cb13_raw[_490].w) * 0.7561339139938354f;
              float _565 = _497 - _563;
              float _566 = _498 + _564;
              float _567 = t8.SampleCmpLevelZero(s9, float3(_565, _566, _500), _441);
              float _569 = _562 + _567.x;
              float _570 = (cb13_raw[_490].w) * 0.16141439974308014f;
              float _571 = (cb13_raw[_490].w) * 0.9776520729064941f;
              float _572 = _497 - _570;
              float _573 = _498 + _571;
              float _574 = t8.SampleCmpLevelZero(s9, float3(_572, _573, _500), _441);
              float _576 = _569 + _574.x;
              float _577 = (cb13_raw[_490].w) * 0.215631902217865f;
              float _578 = (cb13_raw[_490].w) * 0.6123412847518921f;
              float _579 = _497 + _577;
              float _580 = _498 + _578;
              float _581 = t8.SampleCmpLevelZero(s9, float3(_579, _580, _500), _441);
              float _583 = _576 + _581.x;
              float _584 = (cb13_raw[_490].w) * 0.23288750648498535f;
              float _585 = (cb13_raw[_490].w) * 0.9452872276306152f;
              float _586 = _497 + _584;
              float _587 = _498 + _585;
              float _588 = t8.SampleCmpLevelZero(s9, float3(_586, _587, _500), _441);
              float _590 = _583 + _588.x;
              float _591 = (cb13_raw[_490].w) * 0.9440643787384033f;
              float _592 = (cb13_raw[_490].w) * 0.12360770255327225f;
              float _593 = _497 - _591;
              float _594 = _498 + _592;
              float _595 = t8.SampleCmpLevelZero(s9, float3(_593, _594, _500), _441);
              float _597 = _590 + _595.x;
              float _598 = (cb13_raw[_490].w) * 0.7408236861228943f;
              float _599 = (cb13_raw[_490].w) * 0.5076829791069031f;
              float _600 = _497 - _598;
              float _601 = _498 - _599;
              float _602 = t8.SampleCmpLevelZero(s9, float3(_600, _601, _500), _441);
              float _604 = _597 + _602.x;
              float _605 = (cb13_raw[_490].w) * 0.4113019108772278f;
              float _606 = (cb13_raw[_490].w) * 0.8905966877937317f;
              float _607 = _497 - _605;
              float _608 = _498 - _606;
              float _609 = t8.SampleCmpLevelZero(s9, float3(_607, _608, _500), _441);
              float _611 = _604 + _609.x;
              float _612 = (cb13_raw[_490].w) * 0.2486429065465927f;
              float _613 = (cb13_raw[_490].w) * 0.6213992834091187f;
              float _614 = _497 - _612;
              float _615 = _498 - _613;
              float _616 = t8.SampleCmpLevelZero(s9, float3(_614, _615, _500), _441);
              float _618 = _611 + _616.x;
              float _619 = (cb13_raw[_490].w) * 0.6967849731445312f;
              float _620 = (cb13_raw[_490].w) * 0.2644937038421631f;
              float _621 = _497 + _619;
              float _622 = _498 + _620;
              float _623 = t8.SampleCmpLevelZero(s9, float3(_621, _622, _500), _441);
              float _625 = _618 + _623.x;
              float _626 = (cb13_raw[_490].w) * 0.5394362807273865f;
              float _627 = (cb13_raw[_490].w) * 0.8173214793205261f;
              float _628 = _497 + _626;
              float _629 = _498 + _627;
              float _630 = t8.SampleCmpLevelZero(s9, float3(_628, _629, _500), _441);
              float _632 = _625 + _630.x;
              float _633 = (cb13_raw[_490].w) * 0.6151208281517029f;
              float _634 = (cb13_raw[_490].w) * 0.14986400306224823f;
              float _635 = _497 + _633;
              float _636 = _498 - _634;
              float _637 = t8.SampleCmpLevelZero(s9, float3(_635, _636, _500), _441);
              float _639 = _632 + _637.x;
              float _640 = (cb13_raw[_490].w) * 0.0936533585190773f;
              float _641 = (cb13_raw[_490].w) * 0.7817475199699402f;
              float _642 = _497 + _640;
              float _643 = _498 - _641;
              float _644 = t8.SampleCmpLevelZero(s9, float3(_642, _643, _500), _441);
              float _646 = _639 + _644.x;
              float _647 = (cb13_raw[_490].w) * 0.27680671215057373f;
              float _648 = (cb13_raw[_490].w) * 0.48959681391716003f;
              float _649 = _497 + _647;
              float _650 = _498 - _648;
              float _651 = t8.SampleCmpLevelZero(s9, float3(_649, _650, _500), _441);
              float _653 = _646 + _651.x;
              float _654 = (cb13_raw[_490].w) * 0.6639180779457092f;
              float _655 = (cb13_raw[_490].w) * 0.6007171869277954f;
              float _656 = _497 + _654;
              float _657 = _498 - _655;
              float _658 = t8.SampleCmpLevelZero(s9, float3(_656, _657, _500), _441);
              float _660 = _653 + _658.x;
              float _661 = (cb13_raw[_490].w) * 0.38803690671920776f;
              float _662 = (cb13_raw[_490].w) * 0.8950893878936768f;
              float _663 = _497 + _661;
              float _664 = _498 - _662;
              float _665 = t8.SampleCmpLevelZero(s9, float3(_663, _664, _500), _441);
              float _667 = _660 + _665.x;
              float _668 = (cb13_raw[_490].w) * 0.9916144013404846f;
              float _669 = (cb13_raw[_490].w) * 0.07939151674509048f;
              float _670 = _497 + _668;
              float _671 = _498 - _669;
              float _672 = t8.SampleCmpLevelZero(s9, float3(_670, _671, _500), _441);
              float _674 = _667 + _672.x;
              float _675 = (cb13_raw[_490].w) * 0.783184826374054f;
              float _676 = (cb13_raw[_490].w) * 0.6029347777366638f;
              float _677 = _497 + _675;
              float _678 = _498 + _676;
              float _679 = t8.SampleCmpLevelZero(s9, float3(_677, _678, _500), _441);
              float _681 = _674 + _679.x;
              float _682 = (cb13_raw[_490].w) * 0.8998603224754333f;
              float _683 = (cb13_raw[_490].w) * 0.39835429191589355f;
              float _684 = _497 + _682;
              float _685 = _498 - _683;
              float _686 = t8.SampleCmpLevelZero(s9, float3(_684, _685, _500), _441);
              float _688 = _681 + _686.x;
              float _689 = _688 * 0.03703703731298447f;
              float _690 = _689 * _689;
              _779 = _690;
            } else {
              float _692 = (cb13_raw[_490].w) * 0.5077208280563354f;
              float _693 = (cb13_raw[_490].w) * 0.6170899271965027f;
              float _694 = _497 - _692;
              float _695 = _498 - _693;
              float _696 = t8.SampleCmpLevelZero(s9, float3(_694, _695, _500), _441);
              float _698 = _696.x + _504.x;
              float _699 = (cb13_raw[_490].w) * 0.051549021154642105f;
              float _700 = (cb13_raw[_490].w) * 0.7508097887039185f;
              float _701 = _497 - _699;
              float _702 = _498 - _700;
              float _703 = t8.SampleCmpLevelZero(s9, float3(_701, _702, _500), _441);
              float _705 = _698 + _703.x;
              float _706 = (cb13_raw[_490].w) * 0.7641041874885559f;
              float _707 = (cb13_raw[_490].w) * 0.20091520249843597f;
              float _708 = _497 - _706;
              float _709 = _498 + _707;
              float _710 = t8.SampleCmpLevelZero(s9, float3(_708, _709, _500), _441);
              float _712 = _705 + _710.x;
              float _713 = (cb13_raw[_490].w) * 0.007284773979336023f;
              float _714 = (cb13_raw[_490].w) * 0.20594699680805206f;
              float _715 = _497 + _713;
              float _716 = _498 - _714;
              float _717 = t8.SampleCmpLevelZero(s9, float3(_715, _716, _500), _441);
              float _719 = _712 + _717.x;
              float _720 = (cb13_raw[_490].w) * 0.36620399355888367f;
              float _721 = (cb13_raw[_490].w) * 0.732379674911499f;
              float _722 = _497 - _720;
              float _723 = _498 + _721;
              float _724 = t8.SampleCmpLevelZero(s9, float3(_722, _723, _500), _441);
              float _726 = _719 + _724.x;
              float _727 = (cb13_raw[_490].w) * 0.9239581823348999f;
              float _728 = (cb13_raw[_490].w) * 0.2559643089771271f;
              float _729 = _497 - _727;
              float _730 = _498 - _728;
              float _731 = t8.SampleCmpLevelZero(s9, float3(_729, _730, _500), _441);
              float _733 = _726 + _731.x;
              float _734 = (cb13_raw[_490].w) * 0.28692400455474854f;
              float _735 = (cb13_raw[_490].w) * 0.2780529856681824f;
              float _736 = _497 - _734;
              float _737 = _498 + _735;
              float _738 = t8.SampleCmpLevelZero(s9, float3(_736, _737, _500), _441);
              float _740 = _733 + _738.x;
              float _741 = (cb13_raw[_490].w) * 0.772301197052002f;
              float _742 = (cb13_raw[_490].w) * 0.1573328971862793f;
              float _743 = _497 + _741;
              float _744 = _498 + _742;
              float _745 = t8.SampleCmpLevelZero(s9, float3(_743, _744, _500), _441);
              float _747 = _740 + _745.x;
              float _748 = (cb13_raw[_490].w) * 0.37851300835609436f;
              float _749 = (cb13_raw[_490].w) * 0.4052199125289917f;
              float _750 = _497 + _748;
              float _751 = _498 + _749;
              float _752 = t8.SampleCmpLevelZero(s9, float3(_750, _751, _500), _441);
              float _754 = _747 + _752.x;
              float _755 = (cb13_raw[_490].w) * 0.4630216956138611f;
              float _756 = (cb13_raw[_490].w) * 0.6914619207382202f;
              float _757 = _497 + _755;
              float _758 = _498 - _756;
              float _759 = t8.SampleCmpLevelZero(s9, float3(_757, _758, _500), _441);
              float _761 = _754 + _759.x;
              float _762 = (cb13_raw[_490].w) * 0.4235230088233948f;
              float _763 = (cb13_raw[_490].w) * 0.8630279898643494f;
              float _764 = _497 + _762;
              float _765 = _498 + _763;
              float _766 = t8.SampleCmpLevelZero(s9, float3(_764, _765, _500), _441);
              float _768 = _761 + _766.x;
              float _769 = (cb13_raw[_490].w) * 0.8558642864227295f;
              float _770 = (cb13_raw[_490].w) * 0.3382554054260254f;
              float _771 = _497 + _769;
              float _772 = _498 - _770;
              float _773 = t8.SampleCmpLevelZero(s9, float3(_771, _772, _500), _441);
              float _775 = _768 + _773.x;
              float _776 = _775 * 0.07692307978868484f;
              float _777 = _776 * _776;
              _779 = _777;
            }
            float _780 = _779 + _395;
            int _781 = _396 + 1;
            int _782 = _397 + 1;
            bool _783 = ((int)_782 < (int)3);
            if (_783) {
              _395 = _780;
              _396 = _781;
              _397 = _782;
              continue;
            } else {
              _785 = _390;
              _786 = _780;
              _787 = _781;
            }
          } else {
            _785 = 1.0f;
            _786 = _395;
            _787 = _396;
          }
          break;
        }
        int _788 = _393 + 1;
        bool _789 = (_788 == 3);
        if (!_789) {
          _390 = _785;
          _391 = _786;
          _392 = _787;
          _393 = _788;
          continue;
        }
        break;
      }
      float _791 = float((int)(_787));
      float _792 = _786 / _791;
      float _793 = min(_785, _792);
      _795 = _793;
    } else {
      _795 = _353;
    }
  } else {
    _795 = _353;
  }
  float _796 = saturate(_795);
  bool _797 = (_795 > 0.0f);
  if (_797) {
    float _799 = dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(cb13_000x, cb13_000y, cb13_000z));
    float _800 = saturate(_799);
    bool _801 = (_800 > 0.0f);
    [branch]
    if (_801) {
      float _803 = saturate(_800);
      bool _806 = (cb12_221x > 0.0f);
      if (_806) {
        float _808 = dot(float3(cb13_000x, cb13_000y, cb13_000z), float3(_272, _273, _274));
        float4 _809 = t43.SampleLevel(s10, float2(1.0f, _808), 0.0f);
        float _811 = 1.0f - _809.y;
        float _812 = _811 * 0.0476190485060215f;
        float _813 = 1.0f - _812;
        float _814 = max(_813, 0.0010000000474974513f);
        float _815 = _809.y / _814;
        float _816 = min(_815, 1.0f);
        _840 = _816;
      } else {
        float _818 = _272 + cb13_000x;
        float _819 = _273 + cb13_000y;
        float _820 = _274 + cb13_000z;
        float _821 = dot(float3(_818, _819, _820), float3(_818, _819, _820));
        float _822 = rsqrt(_821);
        float _823 = _822 * _818;
        float _824 = _822 * _819;
        float _825 = _822 * _820;
        float _826 = dot(float3(_823, _824, _825), float3(_272, _273, _274));
        float _827 = abs(_826);
        float _828 = 1.0f - _827;
        float _829 = saturate(_828);
        float _830 = _829 * _829;
        float _834 = _830 * _830;
        float _835 = _834 * _829;
        float _836 = _835 * cb13_066x;
        float _837 = cb13_066z + 1.0f;
        float _838 = _836 / _837;
        _840 = _838;
      }
      float _841 = 1.0f - _840;
      float _842 = 1.0f - _840;
      float _843 = 1.0f - _840;
      float _846 = cb12_219z * _118;
      float _848 = _846 + cb12_219w;
      float _849 = saturate(_848);
      float _858 = cb13_061x - cb13_062x;
      float _859 = cb13_061y - cb13_062y;
      float _860 = cb13_061z - cb13_062z;
      float _861 = _858 * _849;
      float _862 = _859 * _849;
      float _863 = _860 * _849;
      float _864 = _861 + cb13_062x;
      float _865 = _862 + cb13_062y;
      float _866 = _863 + cb13_062z;
      float _868 = cb12_219x * _280;
      float _870 = _868 + cb12_219y;
      float _871 = saturate(_870);
      float _876 = _864 - cb13_001x;
      float _877 = _865 - cb13_001y;
      float _878 = _866 - cb13_001z;
      float _879 = _876 * _871;
      float _880 = _877 * _871;
      float _881 = _878 * _871;
      float _882 = _879 + cb13_001x;
      float _883 = _880 + cb13_001y;
      float _884 = _881 + cb13_001z;
      float _885 = _795 * 0.31830987334251404f;
      float _886 = _885 * _803;
      float _887 = _841 * _886;
      float _888 = _887 * _882;
      float _889 = _842 * _886;
      float _890 = _889 * _883;
      float _891 = _843 * _886;
      float _892 = _891 * _884;
      _894 = _888;
      _895 = _890;
      _896 = _892;
      _897 = _803;
    } else {
      _894 = 0.0f;
      _895 = 0.0f;
      _896 = 0.0f;
      _897 = 0.0f;
    }
  } else {
    _894 = 0.0f;
    _895 = 0.0f;
    _896 = 0.0f;
    _897 = 0.0f;
  }
  float _898 = min(_897, _796);
  float _899 = _898 * _894;
  float _900 = _898 * _895;
  float _901 = _898 * _896;
  float _904 = _257 * cb12_023x;
  float _905 = _258 * cb12_023y;
  int _906 = int(_904);
  int _907 = int(_905);
  float _908 = cb12_023x + -1.0f;
  float _909 = cb12_023y + -1.0f;
  float _910 = float((int)(_906));
  float _911 = float((int)(_907));
  float _912 = min(_910, _908);
  float _913 = min(_911, _909);
  int _914 = int(_912);
  int _915 = int(_913);
  int _916 = (int)(_914) / (int)(2);
  int _917 = (int)(_915) / (int)(2);
  float4 _918 = t24.Load(int3(_916, _917, 0));
  float _925 = _118 - cb12_000z;
  float _926 = _925 * _925;
  float _927 = _279 + _926;
  float _928 = sqrt(_927);
  float _931 = dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_275, _276, _925));
  float _934 = 1.0f / cb12_021y;
  float _935 = _934 * _928;
  float _936 = _935 / _931;
  float _938 = _928 - _936;
  float _939 = _938 * cb13_032w;
  float _940 = saturate(_939);
  float _941 = _940 * cb13_032z;
  float _942 = max(0.0010000000474974513f, _941);
  float _943 = _928 / cb13_033z;
  bool _944 = (_918.x < _918.y);
  if (_944) {
    bool _946 = (_943 < _918.x);
    bool _947 = (_943 > _918.y);
    bool _948 = _946 || _947;
    if (!_948) {
      float _950 = cb13_033z * _918.x;
      float _951 = _950 - cb13_033x;
      float _952 = _951 * cb13_033y;
      float _953 = 1.0f - _952;
      float _954 = saturate(_953);
      float _955 = _943 - _918.x;
      float _956 = _955 * cb13_033z;
      float _957 = _956 / _942;
      float _958 = saturate(_957);
      float _959 = _958 * _954;
      _979 = 1.0f;
      _980 = _959;
    } else {
      _979 = 0.0f;
      _980 = 1.0f;
    }
  } else {
    bool _961 = (_918.x > _918.y);
    if (_961) {
      bool _963 = (_943 < _918.y);
      if (!_963) {
        bool _965 = (_943 > _918.x);
        if (_965) {
          float _967 = cb13_033z * _918.x;
          float _968 = _967 - cb13_033x;
          float _969 = _968 * cb13_033y;
          float _970 = 1.0f - _969;
          float _971 = saturate(_970);
          _979 = 1.0f;
          _980 = _971;
        } else {
          float _973 = _943 - _918.y;
          float _974 = _973 * cb13_033z;
          float _975 = _974 / _942;
          float _976 = saturate(_975);
          float _977 = 1.0f - _976;
          _979 = 1.0f;
          _980 = _977;
        }
      } else {
        _979 = 1.0f;
        _980 = 1.0f;
      }
    } else {
      _979 = 0.0f;
      _980 = 1.0f;
    }
  }
  float _981 = _980 * _979;
  float _982 = 1.0f - _981;
  float _983 = saturate(_982);
  int _984 = _914 & 1;
  bool _985 = (_984 == 0);
  int _986 = _915 & 1;
  int _987 = 2 - _986;
  bool _988 = (_986 != 0);
  int _989 = select(_988, 3, 0);
  int _990 = select(_985, _989, _987);
  int _991 = _990 << 2u;
  int _992 = (uint)(_915) >> 1;
  int _993 = _914 & 2;
  bool _994 = (_993 == 0);
  int _995 = _992 & 1;
  int _996 = 2 - _995;
  bool _997 = (_995 != 0);
  int _998 = select(_997, 3, 0);
  int _999 = select(_994, _998, _996);
  int _1000 = _999 | _991;
  int _1001 = _1000 << 2u;
  int _1002 = (uint)(_915) >> 2;
  int _1003 = _914 & 4;
  bool _1004 = (_1003 == 0);
  int _1005 = _1002 & 1;
  int _1006 = 2 - _1005;
  bool _1007 = (_1005 != 0);
  int _1008 = select(_1007, 3, 0);
  int _1009 = select(_1004, _1008, _1006);
  int _1010 = _1009 | _1001;
  float _1011 = float((int)(_1010));
  float _1012 = _1011 + 0.5f;
  float _1013 = _1012 * 0.015625f;
  int _1014 = (uint)(_914) >> 5;
  int _1015 = (uint)(_915) >> 5;
  int _1018 = int(cb12_024z);
  uint _1019 = _1018 * _1015;
  uint _1020 = _1019 + _1014;
  uint _1021 = _1020 * 192;
  _1023 = 0.0f;
  _1024 = 0.0f;
  _1025 = 0.0f;
  _1026 = 0.0f;
  _1027 = 0;
  while(true) {
    uint _1028 = _1027 + _1021;
    uint _1029 = _1028 << 2u;
    int4 _1030 = asint(t21.Load4(_1029));
    bool _1032 = ((uint)_1030.x > (uint)191);
    [branch]
    if (!_1032) {
      uint _1034 = _1030.x * 5;
      uint _1035 = _1034 + 2629u;
      uint _1041 = _1034 + 2630u;
      uint _1047 = _1034 + 2631u;
      float _1053 = (cb13_raw[_1035].x) * _200;
      float _1054 = mad(_204, (cb13_raw[_1035].y), _1053);
      float _1055 = mad(_208, (cb13_raw[_1035].z), _1054);
      float _1056 = _1055 + (cb13_raw[_1035].w);
      float _1057 = (cb13_raw[_1041].x) * _200;
      float _1058 = mad(_204, (cb13_raw[_1041].y), _1057);
      float _1059 = mad(_208, (cb13_raw[_1041].z), _1058);
      float _1060 = _1059 + (cb13_raw[_1041].w);
      float _1061 = (cb13_raw[_1047].x) * _200;
      float _1062 = mad(_204, (cb13_raw[_1047].y), _1061);
      float _1063 = mad(_208, (cb13_raw[_1047].z), _1062);
      float _1064 = _1063 + (cb13_raw[_1047].w);
      float _1065 = abs(_1056);
      float _1066 = abs(_1060);
      float _1067 = abs(_1064);
      bool _1068 = (_1065 < 1.0f);
      bool _1069 = (_1066 < 1.0f);
      bool _1070 = (_1067 < 1.0f);
      bool _1071 = _1068 && _1069;
      bool _1072 = _1071 && _1070;
      [branch]
      if (_1072) {
        uint _1074 = _1034 + 2632u;
        int _1077 = (uint)((uint)(asint(cb13_raw[_1074].w))) >> 16;
        float _1078 = float((uint)_1077);
        float _1079 = _1078 * 1.5259021893143654e-05f;
        float _1080 = _1056 * _1056;
        float _1081 = _1060 * _1060;
        float _1082 = _1081 + _1080;
        float _1083 = _1064 * _1064;
        float _1084 = _1082 + _1083;
        float _1085 = sqrt(_1084);
        float _1086 = 1.0f - _1085;
        float _1087 = saturate(_1086);
        uint _1088 = _1034 + 2633u;
        float _1091 = (cb13_raw[_1088].w) * _1087;
        float _1092 = saturate(_1091);
        bool _1093 = ((cb13_raw[_1088].w) == -1.0f);
        if (_1093) {
          float _1095 = 1.0f - _1013;
          bool _1096 = (_1079 >= _1095);
          float _1097 = select(_1096, 1.0f, 0.0f);
          _1112 = 0.0f;
          _1113 = _1097;
          _1114 = 0.0f;
          _1115 = 0.0f;
        } else {
          int _1099 = asint(cb13_raw[_1074].w) & 65535;
          float _1100 = float((uint)_1099);
          bool _1101 = (_1079 >= _1013);
          float _1102 = select(_1101, 1.5259021893143654e-05f, 0.0f);
          float _1103 = _1102 * _1100;
          float _1105 = (cb13_raw[_1088].x) * _1087;
          float _1106 = min(0.9980372786521912f, _1105);
          float _1108 = (cb13_raw[_1088].y) * _1092;
          float _1110 = (cb13_raw[_1088].z) * _1092;
          _1112 = _1103;
          _1113 = _1106;
          _1114 = _1108;
          _1115 = _1110;
        }
        float _1116 = max(_1023, _1112);
        float _1117 = max(_1024, _1113);
        float _1118 = max(_1025, _1114);
        float _1119 = max(_1026, _1115);
        _1121 = _1116;
        _1122 = _1117;
        _1123 = _1118;
        _1124 = _1119;
      } else {
        _1121 = _1023;
        _1122 = _1024;
        _1123 = _1025;
        _1124 = _1026;
      }
      int _1125 = _1027 + 1;
      bool _1126 = ((uint)_1125 < (uint)192);
      if (_1126) {
        _1023 = _1121;
        _1024 = _1122;
        _1025 = _1123;
        _1026 = _1124;
        _1027 = _1125;
        continue;
      } else {
        _1128 = _1121;
        _1129 = _1122;
        _1130 = _1123;
        _1131 = _1124;
      }
    } else {
      _1128 = _1023;
      _1129 = _1024;
      _1130 = _1025;
      _1131 = _1026;
    }
    break;
  }
  float _1132 = _1129 * _1129;
  float _1133 = _983 * _983;
  bool _1134 = (_1128 > 0.0f);
  float _1135 = select(_1134, 0.0f, 1.0f);
  float _1136 = min(_1135, _1133);
  float _1137 = max(_1136, _1132);
  float _1138 = 1.0f - _1137;
  float _1139 = 1.0f - _1130;
  float _1141 = select(_1134, _1128, cb13_032y);
  float _1142 = 1.0f - _1141;
  float _1143 = min(_1142, _1139);
  float _1144 = 1.0f - _1131;
  float _1145 = _1143 - _1144;
  float _1146 = _1145 * _1138;
  float _1147 = _1146 + _1144;
  float _1148 = saturate(_1147);
  float _1149 = saturate(_1137);
  float _1150 = saturate(_1148);
  float _1151 = saturate(_1149);
  bool _1154 = ((int)cb13_067y > (int)0);
  if (_1154) {
    _1157 = 0;
    _1158 = cb13_000x;
    _1159 = cb13_000y;
    _1160 = cb13_000z;
    _1161 = _899;
    _1162 = _900;
    _1163 = _901;
    _1164 = 0;
    while(true) {
      uint _1165 = _1164 * 10;
      uint _1166 = _1165 + 68u;
      float _1171 = (cb13_raw[_1166].x) - _116;
      float _1172 = (cb13_raw[_1166].y) - _117;
      float _1173 = (cb13_raw[_1166].z) - _118;
      float _1174 = _1171 * _1171;
      float _1175 = _1172 * _1172;
      float _1176 = _1174 + _1175;
      float _1177 = _1173 * _1173;
      float _1178 = _1176 + _1177;
      float _1179 = sqrt(_1178);
      float _1180 = _1179 * _1179;
      uint _1181 = _1165 + 73u;
      float _1184 = _1180 * (cb13_raw[_1181].x);
      float _1186 = _1179 / (cb13_raw[_1166].w);
      float _1187 = _1186 * _1186;
      float _1188 = _1187 * _1187;
      float _1189 = 1.0f - _1188;
      float _1190 = saturate(_1189);
      float _1191 = _1190 * _1190;
      uint _1192 = _1165 + 71u;
      int _1195 = asint((cb13_raw[_1192].w));
      int _1196 = _1195 & 1;
      bool _1197 = (_1196 != 0);
      bool _1199 = ((cb13_raw[_1181].z) > 0.0f);
      uint _1200 = _1165 + 74u;
      bool _1203 = ((cb13_raw[_1200].x) > 0.0f);
      uint _1204 = _1165 + 77u;
      int _1207 = asint((cb13_raw[_1204].x));
      int _1208 = _1207 & 1;
      bool _1209 = (_1208 != 0);
      float _1210 = _1184 + 1.0f;
      float _1211 = _1191 / _1210;
      if (_1197) {
        uint _1213 = _1165 + 70u;
        float _1218 = dot(float3(_1171, _1172, _1173), float3(_1171, _1172, _1173));
        float _1219 = rsqrt(_1218);
        float _1220 = _1171 * _1219;
        float _1221 = -0.0f - _1220;
        float _1222 = _1172 * _1219;
        float _1223 = -0.0f - _1222;
        float _1224 = _1173 * _1219;
        float _1225 = -0.0f - _1224;
        float _1226 = dot(float3(_1221, _1223, _1225), float3((cb13_raw[_1213].x), (cb13_raw[_1213].y), (cb13_raw[_1213].z)));
        uint _1227 = _1165 + 72u;
        float _1231 = (cb13_raw[_1227].y) * _1226;
        float _1233 = _1231 + (cb13_raw[_1227].z);
        float _1234 = saturate(_1233);
        float _1235 = log2(_1234);
        float _1236 = _1235 * (cb13_raw[_1227].w);
        float _1237 = exp2(_1236);
        float _1238 = _1237 * _1211;
        _1240 = _1238;
      } else {
        _1240 = _1211;
      }
      bool _1241 = _1199 || _1209;
      bool _1242 = (_1240 > 0.0f);
      bool _1243 = _1241 && _1242;
      if (_1243) {
        float _1245 = -0.0f - _1171;
        float _1246 = -0.0f - _1172;
        float _1247 = -0.0f - _1173;
        if (_1197) {
          uint _1249 = _1165 + 70u;
          uint _1254 = _1165 + 75u;
          float _1259 = (cb13_raw[_1254].w) * (cb13_raw[_1249].y);
          float _1260 = (cb13_raw[_1254].z) * (cb13_raw[_1249].z);
          float _1261 = _1259 - _1260;
          float _1262 = (cb13_raw[_1254].y) * (cb13_raw[_1249].z);
          float _1263 = (cb13_raw[_1254].w) * (cb13_raw[_1249].x);
          float _1264 = _1262 - _1263;
          float _1265 = (cb13_raw[_1254].z) * (cb13_raw[_1249].x);
          float _1266 = (cb13_raw[_1254].y) * (cb13_raw[_1249].y);
          float _1267 = _1265 - _1266;
          float _1268 = _1261 * _1245;
          float _1269 = mad(_1264, _1246, _1268);
          float _1270 = mad(_1267, _1247, _1269);
          float _1271 = (cb13_raw[_1254].y) * _1245;
          float _1272 = mad((cb13_raw[_1254].z), _1246, _1271);
          float _1273 = mad((cb13_raw[_1254].w), _1247, _1272);
          float _1274 = (cb13_raw[_1249].x) * _1245;
          float _1275 = mad((cb13_raw[_1249].y), _1246, _1274);
          float _1276 = mad((cb13_raw[_1249].z), _1247, _1275);
          int _1279 = asint((cb13_raw[_1204].z));
          _1442 = _1270;
          _1443 = _1273;
          _1444 = _1276;
          _1445 = (cb13_raw[_1254].x);
          _1446 = _1279;
        } else {
          if (_1209) {
            uint _1282 = _1165 + 72u;
            uint _1287 = _1165 + 70u;
            float _1292 = (cb13_raw[_1287].y) * (cb13_raw[_1282].w);
            float _1293 = (cb13_raw[_1287].z) * (cb13_raw[_1282].z);
            float _1294 = _1292 - _1293;
            float _1295 = (cb13_raw[_1287].z) * (cb13_raw[_1282].y);
            float _1296 = (cb13_raw[_1287].x) * (cb13_raw[_1282].w);
            float _1297 = _1295 - _1296;
            float _1298 = (cb13_raw[_1287].x) * (cb13_raw[_1282].z);
            float _1299 = (cb13_raw[_1287].y) * (cb13_raw[_1282].y);
            float _1300 = _1298 - _1299;
            float _1301 = _1294 * _1245;
            float _1302 = mad(_1297, _1246, _1301);
            float _1303 = mad(_1300, _1247, _1302);
            float _1304 = (cb13_raw[_1287].x) * _1245;
            float _1305 = mad((cb13_raw[_1287].y), _1246, _1304);
            float _1306 = mad((cb13_raw[_1287].z), _1247, _1305);
            float _1307 = (cb13_raw[_1282].y) * _1245;
            float _1308 = mad((cb13_raw[_1282].z), _1246, _1307);
            float _1309 = mad((cb13_raw[_1282].w), _1247, _1308);
            float _1310 = -0.0f - _1303;
            float _1311 = -0.0f - _1306;
            float _1312 = -0.0f - _1309;
            float _1313 = _1310 / _1179;
            float _1314 = _1311 / _1179;
            float _1315 = _1312 / _1179;
            float _1316 = abs(_1313);
            float _1317 = abs(_1314);
            float _1318 = abs(_1315);
            int _1319 = _1207 & 4;
            bool _1320 = (_1319 == 0);
            float _1321 = max(_1317, _1318);
            bool _1322 = (_1316 > _1321);
            if (!_1320) {
              if (_1322) {
                bool _1325 = (_1313 > 0.0f);
                uint _1326 = _1165 + 75u;
                if (_1325) {
                  _1352 = _1306;
                  _1353 = _1309;
                  _1354 = _1310;
                  _1355 = (cb13_raw[_1326].x);
                } else {
                  _1352 = _1311;
                  _1353 = _1309;
                  _1354 = _1303;
                  _1355 = (cb13_raw[_1326].y);
                }
              } else {
                float _1333 = max(_1316, _1318);
                bool _1334 = (_1317 > _1333);
                if (_1334) {
                  bool _1336 = (_1314 > 0.0f);
                  uint _1337 = _1165 + 75u;
                  if (_1336) {
                    _1352 = _1310;
                    _1353 = _1309;
                    _1354 = _1311;
                    _1355 = (cb13_raw[_1337].z);
                  } else {
                    _1352 = _1303;
                    _1353 = _1309;
                    _1354 = _1306;
                    _1355 = (cb13_raw[_1337].w);
                  }
                } else {
                  bool _1344 = (_1315 > 0.0f);
                  uint _1345 = _1165 + 76u;
                  if (_1344) {
                    _1352 = _1303;
                    _1353 = _1306;
                    _1354 = _1312;
                    _1355 = (cb13_raw[_1345].x);
                  } else {
                    _1352 = _1303;
                    _1353 = _1311;
                    _1354 = _1309;
                    _1355 = (cb13_raw[_1345].y);
                  }
                }
              }
              int _1357 = asint((cb13_raw[_1204].z));
              _1442 = _1352;
              _1443 = _1353;
              _1444 = _1354;
              _1445 = _1355;
              _1446 = _1357;
            } else {
              if (_1322) {
                bool _1360 = (_1313 > 0.0f);
                uint _1361 = _1165 + 75u;
                int _1364 = asint((cb13_raw[_1204].z));
                if (_1360) {
                  _1442 = _1306;
                  _1443 = _1309;
                  _1444 = _1310;
                  _1445 = (cb13_raw[_1361].x);
                  _1446 = _1364;
                } else {
                  int _1369 = (uint)(_1364) >> 10;
                  _1442 = _1311;
                  _1443 = _1309;
                  _1444 = _1303;
                  _1445 = (cb13_raw[_1361].y);
                  _1446 = _1369;
                }
              } else {
                float _1371 = max(_1316, _1318);
                bool _1372 = (_1317 > _1371);
                if (_1372) {
                  bool _1374 = (_1314 > 0.0f);
                  uint _1375 = _1165 + 75u;
                  if (_1374) {
                    int _1380 = asint((cb13_raw[_1204].z));
                    int _1381 = (uint)(_1380) >> 20;
                    _1442 = _1310;
                    _1443 = _1309;
                    _1444 = _1311;
                    _1445 = (cb13_raw[_1375].z);
                    _1446 = _1381;
                  } else {
                    int _1385 = asint((cb13_raw[_1204].w));
                    _1442 = _1303;
                    _1443 = _1309;
                    _1444 = _1306;
                    _1445 = (cb13_raw[_1375].w);
                    _1446 = _1385;
                  }
                } else {
                  bool _1387 = (_1315 > 0.0f);
                  uint _1388 = _1165 + 76u;
                  int _1391 = asint((cb13_raw[_1204].w));
                  if (_1387) {
                    int _1394 = (uint)(_1391) >> 10;
                    _1442 = _1303;
                    _1443 = _1306;
                    _1444 = _1312;
                    _1445 = (cb13_raw[_1388].x);
                    _1446 = _1394;
                  } else {
                    int _1397 = (uint)(_1391) >> 20;
                    _1442 = _1303;
                    _1443 = _1311;
                    _1444 = _1309;
                    _1445 = (cb13_raw[_1388].y);
                    _1446 = _1397;
                  }
                }
              }
            }
          } else {
            float _1399 = _1171 / _1179;
            float _1400 = _1172 / _1179;
            float _1401 = _1173 / _1179;
            float _1402 = abs(_1399);
            float _1403 = abs(_1400);
            float _1404 = abs(_1401);
            float _1405 = max(_1403, _1404);
            bool _1406 = (_1402 > _1405);
            if (_1406) {
              bool _1408 = (_1399 > 0.0f);
              uint _1409 = _1165 + 75u;
              if (_1408) {
                _1435 = _1246;
                _1436 = _1247;
                _1437 = _1171;
                _1438 = (cb13_raw[_1409].x);
              } else {
                _1435 = _1172;
                _1436 = _1247;
                _1437 = _1245;
                _1438 = (cb13_raw[_1409].y);
              }
            } else {
              float _1416 = max(_1402, _1404);
              bool _1417 = (_1403 > _1416);
              if (_1417) {
                bool _1419 = (_1400 > 0.0f);
                uint _1420 = _1165 + 75u;
                if (_1419) {
                  _1435 = _1171;
                  _1436 = _1247;
                  _1437 = _1172;
                  _1438 = (cb13_raw[_1420].z);
                } else {
                  _1435 = _1245;
                  _1436 = _1247;
                  _1437 = _1246;
                  _1438 = (cb13_raw[_1420].w);
                }
              } else {
                bool _1427 = (_1401 > 0.0f);
                uint _1428 = _1165 + 76u;
                if (_1427) {
                  _1435 = _1245;
                  _1436 = _1246;
                  _1437 = _1173;
                  _1438 = (cb13_raw[_1428].x);
                } else {
                  _1435 = _1245;
                  _1436 = _1172;
                  _1437 = _1247;
                  _1438 = (cb13_raw[_1428].y);
                }
              }
            }
            int _1440 = asint((cb13_raw[_1204].z));
            _1442 = _1435;
            _1443 = _1436;
            _1444 = _1437;
            _1445 = _1438;
            _1446 = _1440;
          }
        }
        float _1448 = _1442 * (cb13_raw[_1181].y);
        float _1449 = mad((cb13_raw[_1181].y), _1443, 0.0f);
        float _1450 = _1448 / _1444;
        float _1451 = _1449 / _1444;
        float _1452 = _1450 * 0.5f;
        float _1453 = _1451 * 0.5f;
        float _1454 = _1452 + 0.5f;
        float _1455 = 0.5f - _1453;
        if (_1199) {
          int _1457 = asint(_1445);
          int _1458 = (uint)(_1457) >> 18;
          int _1459 = _1458 & 4092;
          float _1460 = float((uint)_1459);
          bool _1461 = (_1459 == 0);
          [branch]
          if (!_1461) {
            int _1463 = (uint)(_1457) >> 8;
            int _1464 = _1463 & 4092;
            float _1465 = float((uint)_1464);
            uint _1466 = _1457 << 2u;
            int _1467 = _1466 & 4092;
            float _1468 = float((uint)_1467);
            int _1469 = (uint)(_1457) >> 30;
            float _1470 = float((uint)_1469);
            float _1471 = _1454 * _1460;
            float _1472 = _1455 * _1460;
            float _1473 = _1471 + _1468;
            float _1474 = _1472 + _1465;
            float _1477 = cb13_067x * _1473;
            float _1478 = cb13_067x * _1474;
            float _1479 = t9.SampleLevel(s10, float3(_1477, _1478, _1470), 0.0f);
            float _1481 = _1186 * 0.9900000095367432f;
            float _1482 = _1479.x - _1481;
            float _1483 = _1482 * 144.26950073242188f;
            float _1484 = exp2(_1483);
            float _1485 = saturate(_1484);
            _1487 = _1485;
          } else {
            _1487 = 1.0f;
          }
        } else {
          _1487 = 1.0f;
        }
        if (_1209) {
          int _1489 = _1207 & 2;
          bool _1490 = (_1489 != 0);
          int _1491 = _1207 & 8;
          bool _1492 = (_1491 == 0);
          if (_1490) {
            int _1494 = _1446 & 1023;
            _1500 = _1494;
            _1501 = _1157;
          } else {
            int _1496 = _1446 & 255;
            int _1497 = (uint)(_1446) >> 8;
            int _1498 = _1497 & 3;
            _1500 = _1496;
            _1501 = _1498;
          }
          float _1502 = float((uint)_1500);
          float _1504 = floor(cb13_raw[_1204].y);
          float _1505 = _1504 + _1502;
          float4 _1506 = t42.SampleLevel(s10, float3(_1454, _1455, _1505), 0.0f);
          _36[0] = _1506.x;
          _36[1] = _1506.y;
          _36[2] = _1506.z;
          _36[3] = _1506.w;
          if (!_1492) {
            float _1516 = _1505 + 1.0f;
            float4 _1517 = t42.SampleLevel(s10, float3(_1454, _1455, _1516), 0.0f);
            float _1522 = frac(cb13_raw[_1204].y);
            float _1523 = _1517.x - _1506.x;
            float _1524 = _1517.y - _1506.y;
            float _1525 = _1517.z - _1506.z;
            float _1526 = _1517.w - _1506.w;
            float _1527 = _1523 * _1522;
            float _1528 = _1524 * _1522;
            float _1529 = _1525 * _1522;
            float _1530 = _1526 * _1522;
            float _1531 = _1527 + _1506.x;
            float _1532 = _1528 + _1506.y;
            float _1533 = _1529 + _1506.z;
            float _1534 = _1530 + _1506.w;
            _36[0] = _1531;
            _36[1] = _1532;
            _36[2] = _1533;
            _36[3] = _1534;
            _1536 = _1533;
            _1537 = _1532;
            _1538 = _1531;
          } else {
            _1536 = _1506.z;
            _1537 = _1506.y;
            _1538 = _1506.x;
          }
          if (!_1490) {
            float _1541 = _36[_1501];
            _1543 = _1487;
            _1544 = _1541;
            _1545 = _1541;
            _1546 = _1541;
            _1547 = _1501;
          } else {
            _1543 = _1487;
            _1544 = _1538;
            _1545 = _1537;
            _1546 = _1536;
            _1547 = _1501;
          }
        } else {
          _1543 = _1487;
          _1544 = 1.0f;
          _1545 = 1.0f;
          _1546 = 1.0f;
          _1547 = _1157;
        }
      } else {
        _1543 = 1.0f;
        _1544 = 1.0f;
        _1545 = 1.0f;
        _1546 = 1.0f;
        _1547 = _1157;
      }
      bool _1548 = _1203 && _1242;
      if (_1548) {
        float _1551 = t10.SampleLevel(s10, float4(_1171, _1172, _1173, (cb13_raw[_1200].y)), 0.0f);
        float _1553 = _1186 * 0.9900000095367432f;
        float _1554 = _1551.x - _1553;
        float _1555 = _1554 * 144.26950073242188f;
        float _1556 = exp2(_1555);
        float _1557 = saturate(_1556);
        float _1558 = _1557 * _1543;
        _1560 = _1558;
      } else {
        _1560 = _1543;
      }
      uint _1561 = _1165 + 70u;
      float _1564 = _1560 + -1.0f;
      float _1565 = (cb13_raw[_1561].w) * _1564;
      float _1566 = _1565 + 1.0f;
      float _1567 = _1566 * _1240;
      float _1568 = _1567 * _1544;
      float _1569 = _1567 * _1545;
      float _1570 = _1567 * _1546;
      bool _1571 = (_1568 > 0.0f);
      bool _1572 = (_1569 > 0.0f);
      bool _1573 = (_1570 > 0.0f);
      bool _1574 = _1571 || _1572;
      bool _1575 = _1573 || _1574;
      [branch]
      if (_1575) {
        float _1577 = dot(float3(_1171, _1172, _1173), float3(_1171, _1172, _1173));
        float _1578 = rsqrt(_1577);
        float _1579 = _1578 * _1171;
        float _1580 = _1578 * _1172;
        float _1581 = _1578 * _1173;
        float _1582 = dot(float3(_1579, _1580, _1581), float3(_1579, _1580, _1581));
        float _1583 = saturate(_1582);
        float _1584 = saturate(_1583);
        bool _1587 = (cb12_221x > 0.0f);
        if (_1587) {
          float _1589 = dot(float3(_1579, _1580, _1581), float3(_272, _273, _274));
          float4 _1590 = t43.SampleLevel(s10, float2(1.0f, _1589), 0.0f);
          float _1592 = 1.0f - _1590.y;
          float _1593 = _1592 * 0.0476190485060215f;
          float _1594 = 1.0f - _1593;
          float _1595 = max(_1594, 0.0010000000474974513f);
          float _1596 = _1590.y / _1595;
          float _1597 = min(_1596, 1.0f);
          _1621 = _1597;
        } else {
          float _1599 = _1579 + _272;
          float _1600 = _1580 + _273;
          float _1601 = _1581 + _274;
          float _1602 = dot(float3(_1599, _1600, _1601), float3(_1599, _1600, _1601));
          float _1603 = rsqrt(_1602);
          float _1604 = _1603 * _1599;
          float _1605 = _1603 * _1600;
          float _1606 = _1603 * _1601;
          float _1607 = dot(float3(_1604, _1605, _1606), float3(_272, _273, _274));
          float _1608 = abs(_1607);
          float _1609 = 1.0f - _1608;
          float _1610 = saturate(_1609);
          float _1611 = _1610 * _1610;
          float _1615 = _1611 * _1611;
          float _1616 = _1615 * _1610;
          float _1617 = _1616 * cb13_066x;
          float _1618 = cb13_066z + 1.0f;
          float _1619 = _1617 / _1618;
          _1621 = _1619;
        }
        float _1622 = 1.0f - _1621;
        float _1623 = 1.0f - _1621;
        float _1624 = 1.0f - _1621;
        float _1628 = _1584 * 0.31830987334251404f;
        float _1629 = _1568 * (cb13_raw[_1192].x);
        float _1630 = _1629 * _1628;
        float _1631 = _1630 * _1622;
        float _1632 = _1569 * (cb13_raw[_1192].y);
        float _1633 = _1632 * _1628;
        float _1634 = _1633 * _1623;
        float _1635 = _1570 * (cb13_raw[_1192].z);
        float _1636 = _1635 * _1628;
        float _1637 = _1636 * _1624;
        float _1638 = _1631 + _1161;
        float _1639 = _1634 + _1162;
        float _1640 = _1637 + _1163;
        _1642 = _1579;
        _1643 = _1580;
        _1644 = _1581;
        _1645 = _1638;
        _1646 = _1639;
        _1647 = _1640;
      } else {
        _1642 = _1158;
        _1643 = _1159;
        _1644 = _1160;
        _1645 = _1161;
        _1646 = _1162;
        _1647 = _1163;
      }
      int _1648 = _1164 + 1;
      bool _1651 = ((int)_1648 < (int)cb13_067y);
      if (_1651) {
        _1157 = _1547;
        _1158 = _1642;
        _1159 = _1643;
        _1160 = _1644;
        _1161 = _1645;
        _1162 = _1646;
        _1163 = _1647;
        _1164 = _1648;
        continue;
      }
      break;
    }
    _1654 = _1642;
    _1655 = _1643;
    _1656 = _1644;
    _1657 = _1645;
    _1658 = _1646;
    _1659 = _1647;
  } else {
    _1654 = cb13_000x;
    _1655 = cb13_000y;
    _1656 = cb13_000z;
    _1657 = _899;
    _1658 = _900;
    _1659 = _901;
  }
  bool _1660 = (cb13_000z < 0.0f);
  float _1661 = cb13_000x * 0.5f;
  float _1662 = cb13_000y * -0.5f;
  float _1663 = 1.0f - cb13_000z;
  float _1664 = 1.0f / _1663;
  float _1665 = max(_1664, -3.4028234663852886e+38f);
  float _1666 = min(_1665, 3.4028234663852886e+38f);
  float _1667 = _1661 * _1666;
  float _1668 = _1662 * _1666;
  float _1669 = cb13_000x * -0.5f;
  float _1670 = cb13_000y * 0.5f;
  float _1671 = cb13_000z + 1.0f;
  float _1672 = 1.0f / _1671;
  float _1673 = max(_1672, -3.4028234663852886e+38f);
  float _1674 = min(_1673, 3.4028234663852886e+38f);
  float _1675 = _1669 * _1674;
  float _1676 = _1670 * _1674;
  float _1677 = select(_1660, _1667, _1675);
  float _1678 = _1677 + 0.5f;
  float _1679 = select(_1660, _1668, _1676);
  float _1680 = _1679 + 0.5f;
  float _1681 = _1678 * 0.6666666269302368f;
  float _1682 = float((bool)_1660);
  float _1683 = _1682 + 0.1666666716337204f;
  float _1684 = _1683 + _1681;
  float _1685 = _1684 * 0.5f;
  float _1686 = _1680 * 0.095238097012043f;
  float _1687 = _1686 + 0.0238095261156559f;
  _1689 = 1;
  _1690 = 0.0f;
  _1691 = 0.0f;
  _1692 = 0.0f;
  _1693 = 9.999999747378752e-06f;
  while(true) {
    int _1694 = _1689 * 12;
    int _1695 = _1694 + 102;
    int _1700 = _1694 + 103;
    int _1705 = _1694 + 104;
    int _1710 = _1694 + 105;
    float _1715 = (cb12_raw[_1695].x) * _116;
    float _1716 = mad((cb12_raw[_1700].x), _117, _1715);
    float _1717 = mad((cb12_raw[_1705].x), _118, _1716);
    float _1718 = _1717 + (cb12_raw[_1710].x);
    float _1719 = (cb12_raw[_1695].y) * _116;
    float _1720 = mad((cb12_raw[_1700].y), _117, _1719);
    float _1721 = mad((cb12_raw[_1705].y), _118, _1720);
    float _1722 = _1721 + (cb12_raw[_1710].y);
    float _1723 = (cb12_raw[_1695].z) * _116;
    float _1724 = mad((cb12_raw[_1700].z), _117, _1723);
    float _1725 = mad((cb12_raw[_1705].z), _118, _1724);
    float _1726 = _1725 + (cb12_raw[_1710].z);
    float _1727 = abs(_1718);
    float _1728 = abs(_1722);
    float _1729 = abs(_1726);
    float _1730 = 1.0f - _1727;
    float _1731 = 1.0f - _1728;
    float _1732 = 1.0f - _1729;
    int _1733 = _1694 + 106;
    int _1736 = asint((cb12_raw[_1733].y));
    bool _1737 = !(_1151 == -1.0f);
    [branch]
    if (_1737) {
      int _1739 = _1736 & 1;
      bool _1740 = (_1739 != 0);
      float _1741 = select(_1740, 1.0f, _1151);
      int _1742 = _1736 & 2;
      bool _1743 = (_1742 != 0);
      float _1744 = 1.0f - _1151;
      float _1745 = select(_1743, 1.0f, _1744);
      float _1746 = _1741 * _1745;
      _1748 = _1746;
    } else {
      _1748 = 1.0f;
    }
    bool _1749 = (_1730 > 0.0f);
    bool _1750 = (_1731 > 0.0f);
    bool _1751 = (_1732 > 0.0f);
    bool _1752 = _1749 && _1750;
    bool _1753 = _1752 && _1751;
    bool _1754 = (_1748 > 0.0f);
    bool _1755 = _1753 && _1754;
    if (_1755) {
      int _1757 = _1694 + 101;
      float _1762 = (cb12_raw[_1757].x) * _1730;
      float _1763 = (cb12_raw[_1757].y) * _1731;
      float _1764 = (cb12_raw[_1757].z) * _1732;
      float _1765 = saturate(_1762);
      float _1766 = saturate(_1763);
      float _1767 = saturate(_1764);
      float _1768 = 1.0f - _1693;
      float _1769 = _1748 * _1768;
      int _1770 = _1694 + 100;
      float _1773 = _1769 * _1765;
      float _1774 = _1773 * _1766;
      float _1775 = _1774 * _1767;
      float _1776 = _1775 * (cb12_raw[_1770].x);
      float _1777 = _1776 + _1693;
      float _1779 = _1776 * (cb12_raw[_1733].x);
      int _1780 = _1694 + 111;
      float _1783 = float((int)(asint(cb12_raw[_1780].x)));
      float _1784 = _1783 * 0.1428571492433548f;
      float _1785 = _1784 + _1687;
      float4 _1786 = t22.SampleLevel(s11, float2(_1685, _1785), 0.0f);
      float _1790 = _1786.x * _1779;
      float _1791 = _1786.y * _1779;
      float _1792 = _1786.z * _1779;
      float _1793 = _1790 + _1692;
      float _1794 = _1791 + _1691;
      float _1795 = _1792 + _1690;
      _1797 = _1777;
      _1798 = _1793;
      _1799 = _1794;
      _1800 = _1795;
    } else {
      _1797 = _1693;
      _1798 = _1692;
      _1799 = _1691;
      _1800 = _1690;
    }
    int _1801 = _1689 + 1;
    bool _1802 = ((uint)_1801 < (uint)7);
    bool _1803 = (_1797 < 0.9990000128746033f);
    bool _1804 = _1802 && _1803;
    if (_1804) {
      _1689 = _1801;
      _1690 = _1800;
      _1691 = _1799;
      _1692 = _1798;
      _1693 = _1797;
      continue;
    }
    break;
  }
  bool _1806 = (_1797 < 1.0f);
  [branch]
  if (_1806) {
    float _1808 = 1.0f - _1797;
    float _1811 = cb12_100x * _1808;
    float _1812 = _1811 + _1797;
    float _1815 = _1811 * cb12_106x;
    float _1818 = float((int)(cb12_111x));
    float _1819 = _1818 * 0.1428571492433548f;
    float _1820 = _1819 + _1687;
    float4 _1821 = t22.SampleLevel(s11, float2(_1685, _1820), 0.0f);
    float _1825 = _1821.x * _1815;
    float _1826 = _1821.y * _1815;
    float _1827 = _1821.z * _1815;
    float _1828 = _1825 + _1798;
    float _1829 = _1826 + _1799;
    float _1830 = _1827 + _1800;
    _1832 = _1812;
    _1833 = _1828;
    _1834 = _1829;
    _1835 = _1830;
  } else {
    _1832 = _1797;
    _1833 = _1798;
    _1834 = _1799;
    _1835 = _1800;
  }
  float _1836 = 1.0f / _1832;
  float _1841 = cb12_219x * _280;
  float _1843 = _1841 + cb12_219y;
  float _1844 = saturate(_1843);
  float _1847 = cb12_185z + -1.0f;
  float _1848 = _1847 * _1844;
  float _1849 = _1848 + 1.0f;
  float _1852 = cb12_184x - cb12_184y;
  float _1853 = _1852 * _898;
  float _1854 = _1853 + cb12_184y;
  float _1855 = cb12_184z * _1657;
  float _1856 = cb12_184z * _1658;
  float _1857 = cb12_184z * _1659;
  float _1858 = dot(float3(_1654, _1655, _1656), float3(_272, _273, _274));
  float _1859 = abs(_1858);
  float _1860 = max(_1859, _1859);
  float _1861 = abs(_1860);
  float _1862 = 1.0f - _1861;
  float _1863 = saturate(_1862);
  float _1864 = _1863 * _1863;
  float _1868 = min(1.0f, cb13_066y);
  float _1869 = _1864 * _1864;
  float _1870 = _1869 * _1863;
  float _1871 = _1870 * _1868;
  float _1872 = cb13_066w + 1.0f;
  float _1873 = _1871 / _1872;
  float _1874 = 1.0f - _1873;
  float _1875 = _1849 * _1836;
  float _1876 = _1875 * _1854;
  float _1877 = _1876 * _1833;
  float _1878 = _1877 * _1874;
  float _1879 = _1876 * _1834;
  float _1880 = _1879 * _1874;
  float _1881 = _1876 * _1835;
  float _1882 = _1881 * _1874;
  float _1883 = _1878 + _1855;
  float _1884 = _1880 + _1856;
  float _1885 = _1882 + _1857;
  float _1886 = _1883 * _1150;
  float _1887 = _1884 * _1150;
  float _1888 = _1885 * _1150;
  float _1900 = _275 / _928;
  float _1901 = _276 / _928;
  float _1902 = _925 / _928;
  float _1903 = _1902 * cb12_022z;
  float _1904 = _928 - cb12_022z;
  float _1905 = max(0.0f, _1904);
  float _1906 = min(cb12_042z, _1905);
  float _1907 = _1906 * 0.0625f;
  float _1908 = _1907 * _1902;
  float _1909 = _1907 * cb12_043x;
  float _1914 = dot(float3(cb12_038x, cb12_038y, cb12_038z), float3(_1900, _1901, _1902));
  float _1916 = _1914 + cb12_042x;
  float _1917 = cb12_042x + 1.0f;
  float _1918 = _1916 / _1917;
  float _1919 = saturate(_1918);
  float _1920 = cb12_043y - cb12_043z;
  float _1921 = _1919 * _1920;
  float _1922 = _1921 + cb12_043z;
  bool _1925 = (cb12_287z == 0);
  if (!_1925) {
    bool _1927 = (_1914 > 0.0f);
    bool _1928 = (cb12_287z != 2);
    bool _1929 = _1927 && _1928;
    _1931 = _1929;
  } else {
    _1931 = true;
  }
  float _1932 = abs(_1914);
  float _1933 = _1932 * _1932;
  if (_1931) {
    float _1935 = _1906 * 0.0020000000949949026f;
    float _1936 = _1935 + -0.30000001192092896f;
    float _1937 = saturate(_1936);
    _1939 = _1937;
  } else {
    _1939 = 1.0f;
  }
  float _1940 = _1933 * _1939;
  bool _1941 = (_1914 > 0.0f);
  if (_1941) {
    _1953 = cb12_039x;
    _1954 = cb12_039y;
    _1955 = cb12_039z;
  } else {
    _1953 = cb12_041x;
    _1954 = cb12_041y;
    _1955 = cb12_041z;
  }
  float _1960 = _1953 - cb12_040x;
  float _1961 = _1954 - cb12_040y;
  float _1962 = _1955 - cb12_040z;
  float _1963 = _1960 * _1940;
  float _1964 = _1961 * _1940;
  float _1965 = _1962 * _1940;
  float _1966 = _1963 + cb12_040x;
  float _1967 = _1964 + cb12_040y;
  float _1968 = _1965 + cb12_040z;
  if (_1941) {
    _1980 = cb12_045x;
    _1981 = cb12_045y;
    _1982 = cb12_045z;
  } else {
    _1980 = cb12_047x;
    _1981 = cb12_047y;
    _1982 = cb12_047z;
  }
  float _1987 = _1980 - cb12_046x;
  float _1988 = _1981 - cb12_046y;
  float _1989 = _1982 - cb12_046z;
  float _1990 = _1987 * _1940;
  float _1991 = _1988 * _1940;
  float _1992 = _1989 * _1940;
  float _1993 = _1990 + cb12_046x;
  float _1994 = _1991 + cb12_046y;
  float _1995 = _1992 + cb12_046z;
  bool _1997 = !(_1906 >= cb12_048y);
  [branch]
  if (!_1997) {
    float _2000 = cb12_042y + cb12_000z;
    float _2001 = _2000 + _1903;
    float _2002 = _1922 * _2001;
    float _2003 = _1922 * _1908;
    float _2004 = _2003 * 16.0f;
    float _2005 = _2004 + _2002;
    float _2006 = max(0.0f, _2005);
    float _2007 = _2006 + 1.0f;
    float _2008 = _1909 / _2007;
    float _2009 = saturate(_2008);
    float _2010 = 1.0f - _2009;
    float _2011 = _2003 * 15.0f;
    float _2012 = _2011 + _2002;
    float _2013 = max(0.0f, _2012);
    float _2014 = _2013 + 1.0f;
    float _2015 = _1909 / _2014;
    float _2016 = saturate(_2015);
    float _2017 = 1.0f - _2016;
    float _2018 = _2017 * _2010;
    float _2019 = _2003 * 14.0f;
    float _2020 = _2019 + _2002;
    float _2021 = max(0.0f, _2020);
    float _2022 = _2021 + 1.0f;
    float _2023 = _1909 / _2022;
    float _2024 = saturate(_2023);
    float _2025 = 1.0f - _2024;
    float _2026 = _2018 * _2025;
    float _2027 = _2003 * 13.0f;
    float _2028 = _2027 + _2002;
    float _2029 = max(0.0f, _2028);
    float _2030 = _2029 + 1.0f;
    float _2031 = _1909 / _2030;
    float _2032 = saturate(_2031);
    float _2033 = 1.0f - _2032;
    float _2034 = _2026 * _2033;
    float _2035 = _2003 * 12.0f;
    float _2036 = _2035 + _2002;
    float _2037 = max(0.0f, _2036);
    float _2038 = _2037 + 1.0f;
    float _2039 = _1909 / _2038;
    float _2040 = saturate(_2039);
    float _2041 = 1.0f - _2040;
    float _2042 = _2034 * _2041;
    float _2043 = _2003 * 11.0f;
    float _2044 = _2043 + _2002;
    float _2045 = max(0.0f, _2044);
    float _2046 = _2045 + 1.0f;
    float _2047 = _1909 / _2046;
    float _2048 = saturate(_2047);
    float _2049 = 1.0f - _2048;
    float _2050 = _2042 * _2049;
    float _2051 = _2003 * 10.0f;
    float _2052 = _2051 + _2002;
    float _2053 = max(0.0f, _2052);
    float _2054 = _2053 + 1.0f;
    float _2055 = _1909 / _2054;
    float _2056 = saturate(_2055);
    float _2057 = 1.0f - _2056;
    float _2058 = _2050 * _2057;
    float _2059 = _2003 * 9.0f;
    float _2060 = _2059 + _2002;
    float _2061 = max(0.0f, _2060);
    float _2062 = _2061 + 1.0f;
    float _2063 = _1909 / _2062;
    float _2064 = saturate(_2063);
    float _2065 = 1.0f - _2064;
    float _2066 = _2058 * _2065;
    float _2067 = _2003 * 8.0f;
    float _2068 = _2067 + _2002;
    float _2069 = max(0.0f, _2068);
    float _2070 = _2069 + 1.0f;
    float _2071 = _1909 / _2070;
    float _2072 = saturate(_2071);
    float _2073 = 1.0f - _2072;
    float _2074 = _2066 * _2073;
    float _2075 = _2003 * 7.0f;
    float _2076 = _2075 + _2002;
    float _2077 = max(0.0f, _2076);
    float _2078 = _2077 + 1.0f;
    float _2079 = _1909 / _2078;
    float _2080 = saturate(_2079);
    float _2081 = 1.0f - _2080;
    float _2082 = _2074 * _2081;
    float _2083 = _2003 * 6.0f;
    float _2084 = _2083 + _2002;
    float _2085 = max(0.0f, _2084);
    float _2086 = _2085 + 1.0f;
    float _2087 = _1909 / _2086;
    float _2088 = saturate(_2087);
    float _2089 = 1.0f - _2088;
    float _2090 = _2082 * _2089;
    float _2091 = _2003 * 5.0f;
    float _2092 = _2091 + _2002;
    float _2093 = max(0.0f, _2092);
    float _2094 = _2093 + 1.0f;
    float _2095 = _1909 / _2094;
    float _2096 = saturate(_2095);
    float _2097 = 1.0f - _2096;
    float _2098 = _2090 * _2097;
    float _2099 = _2003 * 4.0f;
    float _2100 = _2099 + _2002;
    float _2101 = max(0.0f, _2100);
    float _2102 = _2101 + 1.0f;
    float _2103 = _1909 / _2102;
    float _2104 = saturate(_2103);
    float _2105 = 1.0f - _2104;
    float _2106 = _2098 * _2105;
    float _2107 = _2003 * 3.0f;
    float _2108 = _2107 + _2002;
    float _2109 = max(0.0f, _2108);
    float _2110 = _2109 + 1.0f;
    float _2111 = _1909 / _2110;
    float _2112 = saturate(_2111);
    float _2113 = 1.0f - _2112;
    float _2114 = _2106 * _2113;
    float _2115 = _2003 * 2.0f;
    float _2116 = _2115 + _2002;
    float _2117 = max(0.0f, _2116);
    float _2118 = _2117 + 1.0f;
    float _2119 = _1909 / _2118;
    float _2120 = saturate(_2119);
    float _2121 = 1.0f - _2120;
    float _2122 = _2114 * _2121;
    float _2123 = _1908 + _2001;
    float _2124 = _1922 * _2123;
    float _2125 = max(0.0f, _2124);
    float _2126 = _2125 + 1.0f;
    float _2127 = _1909 / _2126;
    float _2128 = saturate(_2127);
    float _2129 = 1.0f - _2128;
    float _2130 = _2122 * _2129;
    float _2131 = 1.0f - _2130;
    float _2132 = _1906 - cb12_048y;
    float _2134 = _2132 * cb12_048z;
    float _2135 = saturate(_2134);
    _2137 = _2131;
    _2138 = _2135;
  } else {
    _2137 = 1.0f;
    _2138 = 0.0f;
  }
  float _2139 = abs(_2137);
  float _2140 = log2(_2139);
  float _2141 = _2140 * cb12_042w;
  float _2142 = exp2(_2141);
  float _2143 = _2142 * _2138;
  float _2144 = _2140 * cb12_048x;
  float _2145 = exp2(_2144);
  float _2146 = _2145 * _2138;
  float _2149 = cb12_190x * _2143;
  float _2151 = _2149 + cb12_190y;
  float _2152 = saturate(_2151);
  float _2154 = cb12_190z * _2143;
  float _2156 = _2154 + cb12_190w;
  float _2157 = saturate(_2156);
  float _2162 = cb12_189x - _1966;
  float _2163 = cb12_189y - _1967;
  float _2164 = cb12_189z - _1968;
  float _2165 = _2162 * _2152;
  float _2166 = _2163 * _2152;
  float _2167 = _2164 * _2152;
  float _2168 = _2165 + _1966;
  float _2169 = _2166 + _1967;
  float _2170 = _2167 + _1968;
  float _2172 = cb12_189w + -1.0f;
  float _2173 = _2172 * _2157;
  float _2174 = _2173 + 1.0f;
  float _2175 = _2174 * _2143;
  float _2176 = saturate(_2175);
  bool _2179 = (cb12_193x > 0.0f);
  [branch]
  if (_2179) {
    float _2183 = cb12_192x * _2143;
    float _2185 = _2183 + cb12_192y;
    float _2186 = saturate(_2185);
    float _2188 = cb12_192z * _2143;
    float _2190 = _2188 + cb12_192w;
    float _2191 = saturate(_2190);
    float _2196 = cb12_191x - _1966;
    float _2197 = cb12_191y - _1967;
    float _2198 = cb12_191z - _1968;
    float _2199 = _2196 * _2186;
    float _2200 = _2197 * _2186;
    float _2201 = _2198 * _2186;
    float _2203 = cb12_191w + -1.0f;
    float _2204 = _2203 * _2191;
    float _2205 = _2204 + 1.0f;
    float _2206 = _2205 * _2143;
    float _2207 = saturate(_2206);
    float _2208 = _2199 - _2165;
    float _2209 = _2200 - _2166;
    float _2210 = _2201 - _2167;
    float _2211 = _2207 - _2176;
    float _2212 = _2208 * cb12_193x;
    float _2213 = _2209 * cb12_193x;
    float _2214 = _2210 * cb12_193x;
    float _2215 = _2211 * cb12_193x;
    float _2216 = _2212 + _2168;
    float _2217 = _2213 + _2169;
    float _2218 = _2214 + _2170;
    float _2219 = _2215 + _2176;
    _2221 = _2216;
    _2222 = _2217;
    _2223 = _2218;
    _2224 = _2219;
  } else {
    _2221 = _2168;
    _2222 = _2169;
    _2223 = _2170;
    _2224 = _2176;
  }
  output_TEXCOORD.x = _1993;
  output_TEXCOORD.y = _1994;
  output_TEXCOORD.z = _1995;
  output_TEXCOORD.w = _2146;
  output_TEXCOORD_1.x = TEXCOORD.z;
  output_TEXCOORD_1.y = TEXCOORD_2.y;
  output_TEXCOORD_1.z = TEXCOORD_2.x;
  output_TEXCOORD_1.w = _127;
  output_TEXCOORD_2.x = _2221;
  output_TEXCOORD_2.y = _2222;
  output_TEXCOORD_2.z = _2223;
  output_TEXCOORD_2.w = _2224;
  output_TEXCOORD_3.x = _1886;
  output_TEXCOORD_3.y = _1887;
  output_TEXCOORD_3.z = _1888;
  // Preserve the engine particle centre. These components were unused by
  // 0x093DCC92; positions, native lighting, opacity and animation are unchanged.
  output_TEXCOORD_3.w = LocalCloudVolumeTag;
  output_TEXCOORD_4.x = COLOR.x;
  output_TEXCOORD_4.y = COLOR.y;
  output_TEXCOORD_4.z = COLOR.z;
  output_TEXCOORD_4.w = COLOR.w;
  output_TEXCOORD_5.x = _174;
  output_TEXCOORD_5.y = _175;
  output_TEXCOORD_5.z = _176;
  output_TEXCOORD_5.w = _169;
  TEXCOORD_6.x = _55;
  TEXCOORD_6.y = _59;
  TEXCOORD_6.z = _63;
  TEXCOORD_6.w = _170;
  TEXCOORD_7.x = _116;
  TEXCOORD_7.y = _117;
  TEXCOORD_7.z = _118;
  TEXCOORD_7.w = _171;
  SV_Position.x = _151;
  SV_Position.y = _155;
  SV_Position.z = _159;
  SV_Position.w = _163;
  OutputSignature output_signature = { output_TEXCOORD, output_TEXCOORD_1, output_TEXCOORD_2, output_TEXCOORD_3, output_TEXCOORD_4, output_TEXCOORD_5, TEXCOORD_6, TEXCOORD_7, SV_Position };
  return output_signature;
}
