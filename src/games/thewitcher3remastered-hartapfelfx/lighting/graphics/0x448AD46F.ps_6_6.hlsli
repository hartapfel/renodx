// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "shared.h"

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

struct NvHair_Material {
  float NvHair_Material_000;
  float NvHair_Material_004;
  float NvHair_Material_008;
  float NvHair_Material_012;
  float NvHair_Material_016;
  float NvHair_Material_020;
  float NvHair_Material_024;
  float NvHair_Material_028;
  float NvHair_Material_032;
  float NvHair_Material_036;
  float NvHair_Material_040;
  float NvHair_Material_044;
  float4 NvHair_Material_048;
  float4 NvHair_Material_064;
  float4 NvHair_Material_080;
  float NvHair_Material_096;
  float NvHair_Material_100;
  float NvHair_Material_104;
  float NvHair_Material_108;
  float NvHair_Material_112;
  float NvHair_Material_116;
  float NvHair_Material_120;
  float NvHair_Material_124;
  float NvHair_Material_128;
  float NvHair_Material_132;
  float NvHair_Material_136;
  float NvHair_Material_140;
  float NvHair_Material_144;
  float NvHair_Material_148;
  float NvHair_Material_152;
  float NvHair_Material_156;
  float NvHair_Material_160;
  float NvHair_Material_164;
  float NvHair_Material_168;
  float NvHair_Material_172;
};

struct NvHair_ConstantBuffer {
  row_major float4x4 NvHair_ConstantBuffer_000;
  row_major float4x4 NvHair_ConstantBuffer_064;
  row_major float4x4 NvHair_ConstantBuffer_128;
  row_major float4x4 NvHair_ConstantBuffer_192;
  row_major float4x4 NvHair_ConstantBuffer_256;
  row_major float4x4 NvHair_ConstantBuffer_320;
  row_major float4x4 NvHair_ConstantBuffer_384;
  row_major float4x4 NvHair_ConstantBuffer_448;
  float4 NvHair_ConstantBuffer_512;
  float4 NvHair_ConstantBuffer_528;
  int NvHair_ConstantBuffer_544;
  int NvHair_ConstantBuffer_548;
  int NvHair_ConstantBuffer_552;
  int NvHair_ConstantBuffer_556;
  int NvHair_ConstantBuffer_560;
  int NvHair_ConstantBuffer_564;
  float NvHair_ConstantBuffer_568;
  float NvHair_ConstantBuffer_572;
  int NvHair_ConstantBuffer_576;
  int NvHair_ConstantBuffer_580;
  int NvHair_ConstantBuffer_584;
  int NvHair_ConstantBuffer_588;
  float NvHair_ConstantBuffer_592;
  float NvHair_ConstantBuffer_596;
  float NvHair_ConstantBuffer_600;
  float NvHair_ConstantBuffer_604;
  NvHair_Material NvHair_ConstantBuffer_608;
  float4 NvHair_ConstantBuffer_784[64];
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


Texture2D<float4> t13 : register(t13);

Texture2D<float4> t17 : register(t17);

Texture2D<float4> t22 : register(t22);

Texture2D<float4> t23 : register(t23);

Texture2D<float4> t27 : register(t27);

Texture2D<float4> t43 : register(t43);

Texture2DArray<float> t9 : register(t9);

TextureCubeArray<float> t10 : register(t10);

Texture2DArray<float4> t42 : register(t42);

ByteAddressBuffer t20 : register(t20);

Buffer<float3> t0 : register(t0);

Buffer<float4> t1 : register(t1);

Buffer<float4> t2 : register(t2);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t6 : register(t6);

Texture2D<float4> t7 : register(t7);

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

#define cb12_184y (cb12_raw[184].y)
#define cb12_226x (cb12_raw[226].x)
#define cb12_024x (cb12_raw[24].x)
#define cb12_184x (cb12_raw[184].x)
#define cb12_226y (cb12_raw[226].y)
#define cb12_000y (cb12_raw[0].y)
#define cb12_220y (cb12_raw[220].y)
#define cb12_000x (cb12_raw[0].x)
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

cbuffer cb0 : register(b0) {
  NvHair_ConstantBuffer cbPerFrame_000 : packoffset(c000.x);
};

SamplerState s13 : register(s13);

SamplerState s11 : register(s11);

SamplerState s10 : register(s10);

SamplerState s0 : register(s0);

#include "lighting/contact/forward.hlsli"
#include "lighting/sun_environment.hlsli"
#include "water/receiver.hlsli"

struct OutputSignature {
  float4 SV_Target : SV_Target;
  float4 SV_Target_1 : SV_Target1;
};

OutputSignature main(
  noperspective float4 SV_Position : SV_Position,
  linear float HAIR_TEX : HAIR_TEX,
  nointerpolation float COMP_TEXCOORD : COMP_TEXCOORD,
  nointerpolation uint C : C,
  nointerpolation float COORDS : COORDS
) {
  float4 SV_Target = 0;
  float4 SV_Target_1 = 0;
  bool _2256;
  float _36[4];
  float _57 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].x) * SV_Position.x;
  float _58 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].x), _57);
  float _59 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].x), _58);
  float _60 = _59 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].x);
  float _61 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].y) * SV_Position.x;
  float _62 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].y), _61);
  float _63 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].y), _62);
  float _64 = _63 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].y);
  float _65 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].z) * SV_Position.x;
  float _66 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].z), _65);
  float _67 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].z), _66);
  float _68 = _67 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].z);
  float _69 = (cbPerFrame_000.NvHair_ConstantBuffer_192[0].w) * SV_Position.x;
  float _70 = mad(SV_Position.y, (cbPerFrame_000.NvHair_ConstantBuffer_192[1].w), _69);
  float _71 = mad(SV_Position.z, (cbPerFrame_000.NvHair_ConstantBuffer_192[2].w), _70);
  float _72 = _71 + (cbPerFrame_000.NvHair_ConstantBuffer_192[3].w);
  float _73 = _60 / _72;
  float _74 = _64 / _72;
  float _75 = _68 / _72;
  float _76 = floor(COMP_TEXCOORD);
  float _77 = _76 * 0.00048828125f;
  float _78 = COMP_TEXCOORD - _76;
  int _81 = cbPerFrame_000.NvHair_ConstantBuffer_584 + -1;
  float _82 = float((int)(_81));
  float _83 = _82 * HAIR_TEX;
  float _84 = floor(_83);
  int _85 = int(_84);
  int _86 = _85 + 1;
  int _87 = min(_86, _81);
  float _88 = frac(_83);
  float3 _90 = t0.Load(C);
  float _94 = floor(_90.x);
  float _95 = floor(_90.y);
  float _96 = floor(_90.z);
  int _97 = int(_94);
  int _98 = int(_95);
  int _99 = int(_96);
  uint _100 = _97 * cbPerFrame_000.NvHair_ConstantBuffer_584;
  uint _101 = _98 * cbPerFrame_000.NvHair_ConstantBuffer_584;
  uint _102 = _99 * cbPerFrame_000.NvHair_ConstantBuffer_584;
  uint _103 = _100 + _85;
  uint _104 = _101 + _85;
  uint _105 = _102 + _85;
  uint _106 = _100 + _87;
  uint _107 = _101 + _87;
  uint _108 = _102 + _87;
  float _109 = floor(COORDS);
  float _110 = _109 * 0.00048828125f;
  float _111 = COORDS - _109;
  float4 _113 = t1.Load(_103);
  float4 _117 = t1.Load(_104);
  float4 _121 = t1.Load(_105);
  float _125 = _113.x * _111;
  float _126 = _113.y * _111;
  float _127 = _113.z * _111;
  float _128 = _117.x * _110;
  float _129 = _117.y * _110;
  float _130 = _117.z * _110;
  float _131 = _128 + _125;
  float _132 = _129 + _126;
  float _133 = _130 + _127;
  float _134 = 1.0f - _111;
  float _135 = _134 - _110;
  float _136 = _121.x * _135;
  float _137 = _121.y * _135;
  float _138 = _121.z * _135;
  float _139 = _131 + _136;
  float _140 = _132 + _137;
  float _141 = _133 + _138;
  float4 _142 = t1.Load(_106);
  float4 _146 = t1.Load(_107);
  float4 _150 = t1.Load(_108);
  float _154 = _142.x * _111;
  float _155 = _142.y * _111;
  float _156 = _142.z * _111;
  float _157 = _146.x * _110;
  float _158 = _146.y * _110;
  float _159 = _146.z * _110;
  float _160 = _150.x * _135;
  float _161 = _150.y * _135;
  float _162 = _150.z * _135;
  float _163 = _154 - _139;
  float _164 = _163 + _157;
  float _165 = _164 + _160;
  float _166 = _155 - _140;
  float _167 = _166 + _158;
  float _168 = _167 + _161;
  float _169 = _156 - _141;
  float _170 = _169 + _159;
  float _171 = _170 + _162;
  float _172 = _165 * _88;
  float _173 = _168 * _88;
  float _174 = _171 * _88;
  float _175 = _172 + _139;
  float _176 = _173 + _140;
  float _177 = _174 + _141;
  float _178 = dot(float3(_175, _176, _177), float3(_175, _176, _177));
  float _179 = rsqrt(_178);
  float _180 = _175 * _179;
  float _181 = _176 * _179;
  float _182 = _177 * _179;
  float4 _184 = t2.Load(_103);
  float4 _188 = t2.Load(_104);
  float4 _192 = t2.Load(_105);
  float _196 = _184.x * _111;
  float _197 = _184.y * _111;
  float _198 = _184.z * _111;
  float _199 = _188.x * _110;
  float _200 = _188.y * _110;
  float _201 = _188.z * _110;
  float _202 = _199 + _196;
  float _203 = _200 + _197;
  float _204 = _201 + _198;
  float _205 = _192.x * _135;
  float _206 = _192.y * _135;
  float _207 = _192.z * _135;
  float _208 = _202 + _205;
  float _209 = _203 + _206;
  float _210 = _204 + _207;
  float4 _211 = t2.Load(_106);
  float4 _215 = t2.Load(_107);
  float4 _219 = t2.Load(_108);
  float _223 = _211.x * _111;
  float _224 = _211.y * _111;
  float _225 = _211.z * _111;
  float _226 = _215.x * _110;
  float _227 = _215.y * _110;
  float _228 = _215.z * _110;
  float _229 = _219.x * _135;
  float _230 = _219.y * _135;
  float _231 = _219.z * _135;
  float _232 = _223 - _208;
  float _233 = _232 + _226;
  float _234 = _233 + _229;
  float _235 = _224 - _209;
  float _236 = _235 + _227;
  float _237 = _236 + _230;
  float _238 = _225 - _210;
  float _239 = _238 + _228;
  float _240 = _239 + _231;
  float _241 = _234 * _88;
  float _242 = _237 * _88;
  float _243 = _240 * _88;
  float _244 = _241 + _208;
  float _245 = _242 + _209;
  float _246 = _243 + _210;
  float _247 = dot(float3(_244, _245, _246), float3(_244, _245, _246));
  float _248 = rsqrt(_247);
  float _249 = _244 * _248;
  float _250 = _245 * _248;
  float _251 = _246 * _248;
  bool _276 = (cbPerFrame_000.NvHair_ConstantBuffer_544 == 0);
  float _285;
  float _286;
  float _287;
  float _299;
  float _300;
  float _301;
  float _313;
  float _375;
  float _376;
  float _377;
  float _555;
  float _622;
  float _623;
  float _624;
  float _625;
  float _626;
  float _627;
  float _706;
  float _707;
  float _708;
  float _884;
  float _939;
  float _940;
  float _941;
  float _946;
  float _947;
  float _948;
  float _956;
  float _957;
  float _958;
  float _959;
  float _960;
  float _961;
  float _962;
  float _963;
  float _964;
  float _969;
  float _970;
  float _971;
  float _972;
  float _973;
  float _974;
  int _975;
  float _1058;
  float _1170;
  float _1171;
  float _1172;
  float _1173;
  float _1253;
  float _1254;
  float _1255;
  float _1256;
  float _1260;
  float _1261;
  float _1262;
  float _1263;
  int _1264;
  float _1307;
  int _1320;
  int _1321;
  float _1359;
  float _1360;
  float _1361;
  float _1366;
  float _1367;
  float _1368;
  float _1370;
  float _1371;
  float _1372;
  float _1373;
  float _1388;
  float _1403;
  float _1412;
  float _1432;
  float _1522;
  float _1586;
  float _1587;
  float _1588;
  float _1667;
  float _1668;
  float _1669;
  float _1806;
  float _1861;
  float _1862;
  float _1863;
  float _1868;
  float _1869;
  float _1870;
  float _1878;
  float _1879;
  float _1880;
  float _1881;
  float _1882;
  float _1883;
  float _1887;
  float _1888;
  float _1889;
  float _1890;
  float _1891;
  float _1892;
  float _1997;
  float _1998;
  int _2001;
  float _2002;
  float _2003;
  float _2004;
  float _2005;
  float _2006;
  float _2007;
  float _2008;
  float _2063;
  float _2121;
  float _2122;
  float _2123;
  float _2247;
  float _2248;
  float _2249;
  float _2250;
  float _2251;
  float _2252;
  float _2253;
  float _2293;
  float _2294;
  float _2295;
  float _2341;
  float _2342;
  float _2343;
  float _2344;
  float _2345;
  float _2346;
  float _2347;
  float _2433;
  float _2434;
  float _2435;
  float _2566;
  float _2567;
  float _2568;
  float _2602;
  float _2613;
  float _2622;
  float _2632;
  float _2663;
  float _2664;
  float _2665;
  float _2674;
  float _2675;
  float _2676;
  if (!_276) {
    float4 _280 = t5.SampleLevel(s0, float2(_78, _77), 0.0f);
    _285 = _280.x;
    _286 = _280.y;
    _287 = _280.z;
  } else {
    _285 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.x;
    _286 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.y;
    _287 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_048.z;
  }
  bool _290 = (cbPerFrame_000.NvHair_ConstantBuffer_548 == 0);
  if (!_290) {
    float4 _294 = t6.SampleLevel(s0, float2(_78, _77), 0.0f);
    _299 = _294.x;
    _300 = _294.y;
    _301 = _294.z;
  } else {
    _299 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.x;
    _300 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.y;
    _301 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_064.z;
  }
  bool _302 = (cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144 < 0.5f);
  if (_302) {
    float _304 = HAIR_TEX * 2.0f;
    float _305 = _304 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144;
    _313 = _305;
  } else {
    float _307 = 1.0f - cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_144;
    float _308 = HAIR_TEX + -1.0f;
    float _309 = _308 * 2.0f;
    float _310 = _309 * _307;
    float _311 = _310 + 1.0f;
    _313 = _311;
  }
  float _314 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_148 + 0.0010000000474974513f;
  float _315 = 1.0f / _314;
  float _316 = _313 + -0.5f;
  float _317 = _315 * _316;
  float _318 = _317 + 0.5f;
  float _319 = saturate(_318);
  float _320 = _299 - _285;
  float _321 = _300 - _286;
  float _322 = _301 - _287;
  float _323 = _319 * _320;
  float _324 = _319 * _321;
  float _325 = _319 * _322;
  float _326 = _323 + _285;
  float _327 = _324 + _286;
  float _328 = _325 + _287;
  bool _330 = (cbPerFrame_000.NvHair_ConstantBuffer_552 == 0);
  if (!_330) {
    float4 _334 = t7.SampleLevel(s0, float2(HAIR_TEX, 0.5f), 0.0f);
    switch (cbPerFrame_000.NvHair_ConstantBuffer_576) {
      case 0: {
        float _341 = _334.x * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _342 = _334.y * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _343 = _334.z * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        _375 = _341;
        _376 = _342;
        _377 = _343;
        break;
      }
      case 1: {
        float _345 = _334.x * _326;
        float _346 = _334.y * _327;
        float _347 = _334.z * _328;
        float _348 = _345 - _326;
        float _349 = _346 - _327;
        float _350 = _347 - _328;
        float _351 = _348 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _352 = _349 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _353 = _350 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _354 = _351 + _326;
        float _355 = _352 + _327;
        float _356 = _353 + _328;
        _375 = _354;
        _376 = _355;
        _377 = _356;
        break;
      }
      case 2: {
        float _358 = _334.x * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _359 = _334.y * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _360 = _334.z * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _361 = _358 + _326;
        float _362 = _359 + _327;
        float _363 = _360 + _328;
        _375 = _361;
        _376 = _362;
        _377 = _363;
        break;
      }
      case 3: {
        float _365 = _334.x + -0.5f;
        float _366 = _334.y + -0.5f;
        float _367 = _334.z + -0.5f;
        float _368 = _365 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _369 = _366 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _370 = _367 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_156;
        float _371 = _368 + _326;
        float _372 = _369 + _327;
        float _373 = _370 + _328;
        _375 = _371;
        _376 = _372;
        _377 = _373;
        break;
      }
      default: {
        _375 = _326;
        _376 = _327;
        _377 = _328;
        break;
      }
    }
  } else {
    _375 = _326;
    _376 = _327;
    _377 = _328;
  }
  float _378 = _375 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _379 = _376 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _380 = _377 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_032;
  float _381 = log2(_378);
  float _382 = log2(_379);
  float _383 = log2(_380);
  float _384 = _381 * 2.200000047683716f;
  float _385 = _382 * 2.200000047683716f;
  float _386 = _383 * 2.200000047683716f;
  float _387 = exp2(_384);
  float _388 = exp2(_385);
  float _389 = exp2(_386);
  float _390 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.x);
  float _391 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.y);
  float _392 = log2(cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_080.z);
  float _393 = _390 * 2.200000047683716f;
  float _394 = _391 * 2.200000047683716f;
  float _395 = _392 * 2.200000047683716f;
  float _396 = exp2(_393);
  float _397 = exp2(_394);
  float _398 = exp2(_395);
  float _399 = _396 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _400 = _397 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _401 = _398 * cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_112;
  float _402 = dot(float3(_249, _250, _251), float3(_249, _250, _251));
  float _403 = rsqrt(_402);
  float _404 = _403 * _249;
  float _405 = _403 * _250;
  float _406 = _403 * _251;
  float _407 = abs(_404);
  float _408 = abs(_405);
  float _409 = abs(_406);
  float _410 = max(_407, _408);
  float _411 = max(_409, _410);
  bool _412 = (_409 < _411);
  bool _413 = (_408 < _411);
  bool _414 = _412 && _413;
  float _415 = select(_414, _408, _407);
  float _416 = select(_412, _409, _408);
  bool _417 = (_415 < _416);
  float _418 = select(_417, _416, _415);
  float _419 = select(_417, _415, _416);
  float _420 = _419 / _418;
  float _421 = _404 / _411;
  float _422 = _405 / _411;
  float _423 = _406 / _411;
  float4 _426 = t13.SampleLevel(s13, float2(_418, _420), 0.0f);
  float _428 = _426.x * 0.5f;
  float _429 = _428 * _421;
  float _430 = _428 * _422;
  float _431 = _428 * _423;
  float _432 = _429 + 0.5f;
  float _433 = _430 + 0.5f;
  float _434 = _431 + 0.5f;
  uint _435 = uint(SV_Position.x);
  uint _436 = uint(SV_Position.y);
  bool _439 = (cb12_226x > 0.0f);
  bool _441 = (cb12_226y > 0.0f);
  int _444 = int(cb12_220y);
  int _445 = (uint)(_435) >> 4;
  int _446 = (uint)(_436) >> 4;
  int _449 = int(cb12_024x);
  uint _450 = _449 * _446;
  uint _451 = _450 + _445;
  uint _452 = _451 << 8u;
  float _457 = cb12_000x - _73;
  float _458 = cb12_000y - _74;
  float _459 = cb12_000z - _75;
  float _460 = dot(float3(_457, _458, _459), float3(_457, _458, _459));
  float _461 = rsqrt(_460);
  float _462 = _457 * _461;
  float _463 = _458 * _461;
  float _464 = _459 * _461;
  float4 _466 = t17.Load(int3(_435, _436, 0));
  GraphicsWaterReceiver water_light = GraphicsWaterLighting(float3(cb12_000x, cb12_000y, cb12_000z),
      float3(_73, _74, _75), float3(cb13_000x, cb13_000y, cb13_000z), cb12_074x);
  // HairWorks keeps its native anisotropic lobes and ambient shadow weights.
  float graphics_sun_visibility = min(_466.y, GraphicsForwardContact(
      float3(_73, _74, _75), float3(_404, _405, _406), SV_Position.xy, true));
  bool _474 = (_466.y > 0.0f);
  if (_474) {
    float _476 = dot(float3(_404, _405, _406), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
    float _477 = _476 + 0.25f;
    float _478 = _477 * 0.800000011920929f;
    float _479 = saturate(_478);
    float _480 = _479 + _476;
    float _481 = _479 + 1.0f;
    float _482 = _480 / _481;
    float _483 = 1.0f / _481;
    float _484 = saturate(_482);
    bool _485 = (_444 == 1);
    if (_485) {
      float _487 = saturate(_476);
      bool _488 = (_406 > 0.0f);
      int _489 = (int)(uint)(_488);
      int _490 = _489 << 1u;
      int _491 = _490 + -1;
      float _492 = float((int)(_491));
      float _493 = _492 + _406;
      float _494 = -1.0f / _493;
      float _495 = _404 * _405;
      float _496 = _495 * _494;
      float _497 = _404 * _404;
      float _498 = _497 * _492;
      float _499 = _498 * _494;
      float _500 = _499 + 1.0f;
      float _501 = _496 * _492;
      int _502 = 1 - _490;
      float _503 = float((int)(_502));
      float _504 = _503 * _404;
      float _505 = _405 * _405;
      float _506 = _505 * _494;
      float _507 = _506 + _492;
      float _508 = -0.0f - _405;
      float _509 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(water_light.sun.x, water_light.sun.y, water_light.sun.z));
      float _510 = rsqrt(_509);
      float _511 = _510 * water_light.sun.x;
      float _512 = _510 * water_light.sun.y;
      float _513 = _510 * water_light.sun.z;
      float _514 = _511 * _500;
      float _515 = mad(_501, _512, _514);
      float _516 = mad(_504, _513, _515);
      float _517 = _511 * _496;
      float _518 = mad(_507, _512, _517);
      float _519 = mad(_508, _513, _518);
      float _520 = _511 * _404;
      float _521 = mad(_405, _512, _520);
      float _522 = mad(_406, _513, _521);
      float _523 = dot(float3(_516, _519, _522), float3(_516, _519, _522));
      float _524 = rsqrt(_523);
      float _525 = _524 * _516;
      float _526 = _524 * _519;
      float _527 = _524 * _522;
      float _528 = dot(float3(_462, _463, _464), float3(_462, _463, _464));
      float _529 = rsqrt(_528);
      float _530 = _529 * _462;
      float _531 = _529 * _463;
      float _532 = _529 * _464;
      float _533 = _530 * _500;
      float _534 = mad(_501, _531, _533);
      float _535 = mad(_504, _532, _534);
      float _536 = _530 * _496;
      float _537 = mad(_507, _531, _536);
      float _538 = mad(_508, _532, _537);
      float _539 = _530 * _404;
      float _540 = mad(_405, _531, _539);
      float _541 = mad(_406, _532, _540);
      float _542 = dot(float3(_535, _538, _541), float3(_535, _538, _541));
      float _543 = rsqrt(_542);
      float _544 = _543 * _535;
      float _545 = _543 * _538;
      float _546 = _543 * _541;
      float _547 = dot(float3(_525, _526, _527), float3(_544, _545, _546));
      float _548 = _546 * _527;
      float _549 = _547 - _548;
      bool _550 = (_549 > 0.0f);
      if (_550) {
        float _552 = max(_527, _546);
        float _553 = _549 / _552;
        _555 = _553;
      } else {
        _555 = _549;
      }
      float _556 = _555 * 0.20908956229686737f;
      float _557 = _556 + 0.25813528895378113f;
      float _558 = _557 * _387;
      float _559 = _557 * _388;
      float _560 = _557 * _389;
      float _561 = 1.0f - _546;
      float _562 = _561 * 0.07144299894571304f;
      float _563 = _562 + -0.332181453704834f;
      float _564 = _563 * _561;
      float _565 = _564 + 0.4918818771839142f;
      float _566 = _565 * _561;
      float _567 = _566 + 0.05710852891206741f;
      float _568 = _561 * 0.6568742394447327f;
      float _569 = _568 * _567;
      float _570 = 1.0f - _527;
      float _571 = _570 * 0.07144299894571304f;
      float _572 = _571 + -0.332181453704834f;
      float _573 = _572 * _570;
      float _574 = _573 + 0.4918818771839142f;
      float _575 = _574 * _570;
      float _576 = _575 + 0.05710852891206741f;
      float _577 = _570 * 0.6568742394447327f;
      float _578 = _577 * _576;
      float _579 = _387 * _387;
      float _580 = _388 * _388;
      float _581 = _389 * _389;
      float _582 = _579 * 0.8585715889930725f;
      float _583 = _580 * 0.8585715889930725f;
      float _584 = _581 * 0.8585715889930725f;
      float _585 = _387 * 0.1414284110069275f;
      float _586 = _388 * 0.1414284110069275f;
      float _587 = _389 * 0.1414284110069275f;
      float _588 = 1.0f - _585;
      float _589 = 1.0f - _586;
      float _590 = 1.0f - _587;
      float _591 = _582 / _588;
      float _592 = _583 / _589;
      float _593 = _584 / _590;
      float _594 = 0.1890440583229065f - _569;
      float _595 = max(1.0000000116860974e-07f, _594);
      float _596 = 0.1890440583229065f - _578;
      float _597 = max(1.0000000116860974e-07f, _596);
      float _598 = _595 * 2.250678300857544f;
      float _599 = _598 * _597;
      float _600 = _599 * _591;
      float _601 = _599 * _592;
      float _602 = _599 * _593;
      float _603 = _600 + _558;
      float _604 = _601 + _559;
      float _605 = _602 + _560;
      float _606 = _603 * _487;
      float _607 = _604 * _487;
      float _608 = _605 * _487;
      float _609 = _484 - _487;
      float _610 = max(0.0f, _609);
      float _611 = _610 * 0.31830987334251404f;
      float _612 = _611 * _387;
      float _613 = _611 * _388;
      float _614 = _611 * _389;
      float _615 = _606 + _612;
      float _616 = _607 + _613;
      float _617 = _608 + _614;
      float _618 = _615 * 3.1415927410125732f;
      float _619 = _616 * 3.1415927410125732f;
      float _620 = _617 * 3.1415927410125732f;
      _622 = _615;
      _623 = _616;
      _624 = _617;
      _625 = _618;
      _626 = _619;
      _627 = _620;
    } else {
      _622 = _484;
      _623 = _484;
      _624 = _484;
      _625 = _484;
      _626 = _484;
      _627 = _484;
    }
    bool _630 = (cb12_221x > 0.0f);
    float _631 = 1.0f - _399;
    float _632 = 1.0f - _400;
    float _633 = 1.0f - _401;
    if (_630) {
      float _635 = dot(float3(_404, _405, _406), float3(_462, _463, _464));
      float4 _638 = t43.SampleLevel(s10, float2(0.8999999761581421f, _635), 0.0f);
      float _641 = _638.x * _399;
      float _642 = _638.x * _400;
      float _643 = _638.x * _401;
      float _644 = _641 + _638.y;
      float _645 = _642 + _638.y;
      float _646 = _643 + _638.y;
      float _647 = _631 * 0.0476190485060215f;
      float _648 = _632 * 0.0476190485060215f;
      float _649 = _633 * 0.0476190485060215f;
      float _650 = _647 + _399;
      float _651 = _648 + _400;
      float _652 = _649 + _401;
      float _653 = 1.0f - _644;
      float _654 = 1.0f - _645;
      float _655 = 1.0f - _646;
      float _656 = _653 * _650;
      float _657 = _654 * _651;
      float _658 = _655 * _652;
      float _659 = 1.0f - _656;
      float _660 = 1.0f - _657;
      float _661 = 1.0f - _658;
      float _662 = max(_659, 0.0010000000474974513f);
      float _663 = max(_660, 0.0010000000474974513f);
      float _664 = max(_661, 0.0010000000474974513f);
      float _665 = _644 / _662;
      float _666 = _645 / _663;
      float _667 = _646 / _664;
      float _668 = min(_665, 1.0f);
      float _669 = min(_666, 1.0f);
      float _670 = min(_667, 1.0f);
      _706 = _668;
      _707 = _669;
      _708 = _670;
    } else {
      float _672 = water_light.sun.x + _462;
      float _673 = water_light.sun.y + _463;
      float _674 = water_light.sun.z + _464;
      float _675 = dot(float3(_672, _673, _674), float3(_672, _673, _674));
      float _676 = rsqrt(_675);
      float _677 = _676 * _672;
      float _678 = _676 * _673;
      float _679 = _676 * _674;
      float _680 = dot(float3(_677, _678, _679), float3(_462, _463, _464));
      float _681 = abs(_680);
      float _682 = 1.0f - _681;
      float _683 = saturate(_682);
      float _684 = _683 * _683;
      float _688 = max(0.0f, _631);
      float _689 = max(0.0f, _632);
      float _690 = max(0.0f, _633);
      float _691 = _684 * _684;
      float _692 = _691 * _683;
      float _693 = _692 * cb13_066x;
      float _694 = _693 * _688;
      float _695 = _693 * _689;
      float _696 = _693 * _690;
      float _697 = cb13_066z * 0.8999999761581421f;
      float _698 = _697 + 1.0f;
      float _699 = _694 / _698;
      float _700 = _695 / _698;
      float _701 = _696 / _698;
      float _702 = _699 + _399;
      float _703 = _700 + _400;
      float _704 = _701 + _401;
      _706 = _702;
      _707 = _703;
      _708 = _704;
    }
    float _709 = 1.0f - _706;
    float _710 = 1.0f - _707;
    float _711 = 1.0f - _708;
    float _712 = _709 * _622;
    float _713 = _710 * _623;
    float _714 = _711 * _624;
    int _715 = _444 & -3;
    bool _716 = (_715 == 0);
    float _717 = _712 * 0.31830987334251404f;
    float _718 = _713 * 0.31830987334251404f;
    float _719 = _714 * 0.31830987334251404f;
    float _720 = select(_716, _717, _712);
    float _721 = select(_716, _718, _713);
    float _722 = select(_716, _719, _714);
    float _723 = _73 - cb12_000x;
    float _724 = _74 - cb12_000y;
    float _725 = _723 * _723;
    float _726 = _724 * _724;
    float _727 = _725 + _726;
    float _728 = sqrt(_727);
    float _731 = cb12_219z * _75;
    float _733 = _731 + cb12_219w;
    float _734 = saturate(_733);
    float _743 = cb13_061x - cb13_062x;
    float _744 = cb13_061y - cb13_062y;
    float _745 = cb13_061z - cb13_062z;
    float _746 = _743 * _734;
    float _747 = _744 * _734;
    float _748 = _745 * _734;
    float _749 = _746 + cb13_062x;
    float _750 = _747 + cb13_062y;
    float _751 = _748 + cb13_062z;
    float _753 = cb12_219x * _728;
    float _755 = _753 + cb12_219y;
    float _756 = saturate(_755);
    float _761 = _749 - cb13_001x;
    float _762 = _750 - cb13_001y;
    float _763 = _751 - cb13_001z;
    float _764 = _761 * _756;
    float _765 = _762 * _756;
    float _766 = _763 * _756;
    float _767 = (_764 + cb13_001x) * water_light.direct.x;
    float _768 = (_765 + cb13_001y) * water_light.direct.y;
    float _769 = (_766 + cb13_001z) * water_light.direct.z;
    float _770 = _483 * graphics_sun_visibility;
    float _771 = _720 * _770;
    float _772 = _771 * _767;
    float _773 = _721 * _770;
    float _774 = _773 * _768;
    float _775 = _722 * _770;
    float _776 = _775 * _769;
    float _777 = dot(float3(water_light.sun.x, water_light.sun.y, water_light.sun.z), float3(_404, _405, _406));
    bool _778 = (_777 > 0.0f);
    [branch]
    if (_778) {
      float _780 = water_light.sun.x + _462;
      float _781 = water_light.sun.y + _463;
      float _782 = water_light.sun.z + _464;
      float _783 = dot(float3(_780, _781, _782), float3(_780, _781, _782));
      float _784 = rsqrt(_783);
      float _785 = _784 * _780;
      float _786 = _784 * _781;
      float _787 = _784 * _782;
      float _788 = dot(float3(_404, _405, _406), float3(_462, _463, _464));
      float _789 = saturate(_476);
      float _790 = dot(float3(_180, _181, _182), float3(_180, _181, _182));
      float _791 = rsqrt(_790);
      float _792 = _791 * _180;
      float _793 = _791 * _181;
      float _794 = _791 * _182;
      float _795 = dot(float3(_792, _793, _794), float3(_404, _405, _406));
      float _796 = _795 * _404;
      float _797 = _795 * _405;
      float _798 = _795 * _406;
      float _799 = _792 - _796;
      float _800 = _793 - _797;
      float _801 = _794 - _798;
      float _802 = dot(float3(_799, _800, _801), float3(_799, _800, _801));
      float _803 = rsqrt(_802);
      float _804 = _799 * _803;
      float _805 = _800 * _803;
      float _806 = _801 * _803;
      float _807 = _805 * _406;
      float _808 = _806 * _405;
      float _809 = _807 - _808;
      float _810 = _806 * _404;
      float _811 = _804 * _406;
      float _812 = _810 - _811;
      float _813 = _804 * _405;
      float _814 = _805 * _404;
      float _815 = _813 - _814;
      float _816 = dot(float3(_809, _812, _815), float3(_809, _812, _815));
      float _817 = rsqrt(_816);
      float _818 = _809 * _817;
      float _819 = _812 * _817;
      float _820 = _815 * _817;
      float _821 = dot(float3(_804, _805, _806), float3(_785, _786, _787));
      float _822 = _821 * 1.2345679998397827f;
      float _823 = _822 * _822;
      float _824 = dot(float3(_818, _819, _820), float3(_785, _786, _787));
      float _825 = _824 * 1.2345679998397827f;
      float _826 = _825 * _825;
      float _827 = dot(float3(_404, _405, _406), float3(_785, _786, _787));
      float _828 = saturate(_827);
      float _829 = _828 * _828;
      float _830 = _826 + _823;
      float _831 = _830 + _829;
      float _832 = _831 * _831;
      float _833 = 0.4851658046245575f / _832;
      float _834 = abs(_788);
      float _835 = dot(float3(_785, _786, _787), float3(_462, _463, _464));
      float _836 = abs(_835);
      float _837 = 1.0f - _836;
      float _838 = saturate(_837);
      float _839 = _838 * _838;
      float _843 = max(0.0f, _631);
      float _844 = max(0.0f, _632);
      float _845 = max(0.0f, _633);
      float _846 = _839 * _839;
      float _847 = _846 * _838;
      float _848 = _847 * cb13_066x;
      float _849 = _848 * _843;
      float _850 = _848 * _844;
      float _851 = _848 * _845;
      float _852 = cb13_066z * 0.8999999761581421f;
      float _853 = _852 + 1.0f;
      float _854 = _849 / _853;
      float _855 = _850 / _853;
      float _856 = _851 / _853;
      float _857 = _854 + _399;
      float _858 = _855 + _400;
      float _859 = _856 + _401;
      bool _861 = (cb12_221z > 0.0f);
      [branch]
      if (_861) {
        float _863 = saturate(_788);
        float _864 = _863 + _789;
        float _865 = _789 * 2.0f;
        float _866 = _865 * _863;
        float _867 = _864 - _866;
        float _868 = _867 * 0.809999942779541f;
        float _869 = _868 + _866;
        _884 = _869;
      } else {
        float _871 = _834 * _834;
        float _872 = _871 * 0.34390008449554443f;
        float _873 = _872 + 0.6560999155044556f;
        float _874 = sqrt(_873);
        float _875 = _874 * _789;
        float _876 = _789 * _789;
        float _877 = _876 * 0.34390008449554443f;
        float _878 = _877 + 0.6560999155044556f;
        float _879 = sqrt(_878);
        float _880 = _879 * _834;
        float _881 = _875 + 9.999999747378752e-05f;
        float _882 = _881 + _880;
        _884 = _882;
      }
      float _885 = 0.5f / _884;
      float _886 = _885 * _833;
      float _887 = _886 * _857;
      float _888 = _886 * _858;
      float _889 = _886 * _859;
      bool _891 = (cb12_221y > 0.0f);
      if (_891) {
        float _893 = dot(float3(_404, _405, _406), float3(_885, _885, _885));
        float4 _896 = t43.SampleLevel(s10, float2(0.8999999761581421f, _893), 0.0f);
        float _899 = _896.x * _399;
        float _900 = _896.x * _400;
        float _901 = _896.x * _401;
        float _902 = _899 + _896.y;
        float _903 = _900 + _896.y;
        float _904 = _901 + _896.y;
        float _905 = _631 * 0.0476190485060215f;
        float _906 = _632 * 0.0476190485060215f;
        float _907 = _633 * 0.0476190485060215f;
        float _908 = _905 + _399;
        float _909 = _906 + _400;
        float _910 = _907 + _401;
        float _911 = 1.0f - _902;
        float _912 = 1.0f - _903;
        float _913 = 1.0f - _904;
        float _914 = _911 * _908;
        float _915 = _912 * _909;
        float _916 = _913 * _910;
        float _917 = 1.0f - _914;
        float _918 = 1.0f - _915;
        float _919 = 1.0f - _916;
        float _920 = max(_917, 0.0010000000474974513f);
        float _921 = max(_918, 0.0010000000474974513f);
        float _922 = max(_919, 0.0010000000474974513f);
        float _923 = _902 / _920;
        float _924 = _903 / _921;
        float _925 = _904 / _922;
        float _926 = min(_923, 1.0f);
        float _927 = min(_924, 1.0f);
        float _928 = min(_925, 1.0f);
        float _929 = max(_902, 9.999999747378752e-05f);
        float _930 = max(_903, 9.999999747378752e-05f);
        float _931 = max(_904, 9.999999747378752e-05f);
        float _932 = _926 / _929;
        float _933 = _927 / _930;
        float _934 = _928 / _931;
        float _935 = _932 * _887;
        float _936 = _933 * _888;
        float _937 = _934 * _889;
        _939 = _935;
        _940 = _936;
        _941 = _937;
      } else {
        _939 = _887;
        _940 = _888;
        _941 = _889;
      }
      float _942 = _939 * _789;
      float _943 = _940 * _789;
      float _944 = _941 * _789;
      _946 = _942;
      _947 = _943;
      _948 = _944;
    } else {
      _946 = 0.0f;
      _947 = 0.0f;
      _948 = 0.0f;
    }
    float _949 = _767 * graphics_sun_visibility;
    float _950 = _949 * _946;
    float _951 = _768 * graphics_sun_visibility;
    float _952 = _951 * _947;
    float _953 = _769 * graphics_sun_visibility;
    float _954 = _953 * _948;
    _956 = _950;
    _957 = _952;
    _958 = _954;
    _959 = _772;
    _960 = _774;
    _961 = _776;
    _962 = _625;
    _963 = _626;
    _964 = _627;
  } else {
    _956 = 0.0f;
    _957 = 0.0f;
    _958 = 0.0f;
    _959 = 0.0f;
    _960 = 0.0f;
    _961 = 0.0f;
    _962 = 0.0f;
    _963 = 0.0f;
    _964 = 0.0f;
  }
  if (any(water_light.direct != 1.f)) {
    float3 native_environment = GraphicsForwardSunEnvironment(float3(_404, _405, _406), float3(_404, _405, _406),
        float3(_462, _463, _464), float3(cb13_000x, cb13_000y, cb13_000z), float3(_387, _388, _389), .9f, int(cb12_220y), .25f, _466.y);
    _962 = native_environment.x; _963 = native_environment.y; _964 = native_environment.z;
  }
  float _965 = min(_962, _466.y);
  float _966 = min(_963, _466.y);
  float _967 = min(_964, _466.y);
  _969 = _959;
  _970 = _960;
  _971 = _961;
  _972 = _956;
  _973 = _957;
  _974 = _958;
  _975 = 0;
  while(true) {
    int _976 = _975 + _452;
    uint _977 = _976 << 2u;
    int4 _979 = asint(t20.Load4(_977));
    bool _981 = ((uint)_979.x > (uint)255);
    [branch]
    if (!_981) {
      uint _983 = _979.x * 10;
      uint _984 = _983 + 68u;
      float _989 = (cb13_raw[_984].x) - _73;
      float _990 = (cb13_raw[_984].y) - _74;
      float _991 = (cb13_raw[_984].z) - _75;
      float _992 = _989 * _989;
      float _993 = _990 * _990;
      float _994 = _992 + _993;
      float _995 = _991 * _991;
      float _996 = _994 + _995;
      float _997 = sqrt(_996);
      float _998 = _997 * _997;
      uint _999 = _983 + 73u;
      float _1002 = _998 * (cb13_raw[_999].x);
      float _1004 = _997 / (cb13_raw[_984].w);
      float _1005 = _1004 * _1004;
      float _1006 = _1005 * _1005;
      float _1007 = 1.0f - _1006;
      float _1008 = saturate(_1007);
      float _1009 = _1008 * _1008;
      uint _1010 = _983 + 71u;
      int _1013 = asint((cb13_raw[_1010].w));
      int _1014 = _1013 & 1;
      bool _1015 = (_1014 != 0);
      bool _1017 = ((cb13_raw[_999].z) > 0.0f);
      uint _1018 = _983 + 74u;
      bool _1021 = ((cb13_raw[_1018].x) > 0.0f);
      uint _1022 = _983 + 77u;
      int _1025 = asint((cb13_raw[_1022].x));
      int _1026 = _1025 & 1;
      bool _1027 = (_1026 != 0);
      float _1028 = _1002 + 1.0f;
      float _1029 = _1009 / _1028;
      if (_1015) {
        uint _1031 = _983 + 70u;
        float _1036 = dot(float3(_989, _990, _991), float3(_989, _990, _991));
        float _1037 = rsqrt(_1036);
        float _1038 = _989 * _1037;
        float _1039 = -0.0f - _1038;
        float _1040 = _990 * _1037;
        float _1041 = -0.0f - _1040;
        float _1042 = _991 * _1037;
        float _1043 = -0.0f - _1042;
        float _1044 = dot(float3(_1039, _1041, _1043), float3((cb13_raw[_1031].x), (cb13_raw[_1031].y), (cb13_raw[_1031].z)));
        uint _1045 = _983 + 72u;
        float _1049 = (cb13_raw[_1045].y) * _1044;
        float _1051 = _1049 + (cb13_raw[_1045].z);
        float _1052 = saturate(_1051);
        float _1053 = log2(_1052);
        float _1054 = _1053 * (cb13_raw[_1045].w);
        float _1055 = exp2(_1054);
        float _1056 = _1055 * _1029;
        _1058 = _1056;
      } else {
        _1058 = _1029;
      }
      bool _1059 = _1017 || _1027;
      bool _1060 = (_1058 > 0.0f);
      bool _1061 = _1059 && _1060;
      if (_1061) {
        float _1063 = -0.0f - _989;
        float _1064 = -0.0f - _990;
        float _1065 = -0.0f - _991;
        if (_1015) {
          uint _1067 = _983 + 70u;
          uint _1072 = _983 + 75u;
          float _1077 = (cb13_raw[_1072].w) * (cb13_raw[_1067].y);
          float _1078 = (cb13_raw[_1072].z) * (cb13_raw[_1067].z);
          float _1079 = _1077 - _1078;
          float _1080 = (cb13_raw[_1072].y) * (cb13_raw[_1067].z);
          float _1081 = (cb13_raw[_1072].w) * (cb13_raw[_1067].x);
          float _1082 = _1080 - _1081;
          float _1083 = (cb13_raw[_1072].z) * (cb13_raw[_1067].x);
          float _1084 = (cb13_raw[_1072].y) * (cb13_raw[_1067].y);
          float _1085 = _1083 - _1084;
          float _1086 = _1079 * _1063;
          float _1087 = mad(_1082, _1064, _1086);
          float _1088 = mad(_1085, _1065, _1087);
          float _1089 = (cb13_raw[_1072].y) * _1063;
          float _1090 = mad((cb13_raw[_1072].z), _1064, _1089);
          float _1091 = mad((cb13_raw[_1072].w), _1065, _1090);
          float _1092 = (cb13_raw[_1067].x) * _1063;
          float _1093 = mad((cb13_raw[_1067].y), _1064, _1092);
          float _1094 = mad((cb13_raw[_1067].z), _1065, _1093);
          int _1097 = asint((cb13_raw[_1022].z));
          _1260 = _1088;
          _1261 = _1091;
          _1262 = _1094;
          _1263 = (cb13_raw[_1072].x);
          _1264 = _1097;
        } else {
          if (_1027) {
            uint _1100 = _983 + 72u;
            uint _1105 = _983 + 70u;
            float _1110 = (cb13_raw[_1105].y) * (cb13_raw[_1100].w);
            float _1111 = (cb13_raw[_1105].z) * (cb13_raw[_1100].z);
            float _1112 = _1110 - _1111;
            float _1113 = (cb13_raw[_1105].z) * (cb13_raw[_1100].y);
            float _1114 = (cb13_raw[_1105].x) * (cb13_raw[_1100].w);
            float _1115 = _1113 - _1114;
            float _1116 = (cb13_raw[_1105].x) * (cb13_raw[_1100].z);
            float _1117 = (cb13_raw[_1105].y) * (cb13_raw[_1100].y);
            float _1118 = _1116 - _1117;
            float _1119 = _1112 * _1063;
            float _1120 = mad(_1115, _1064, _1119);
            float _1121 = mad(_1118, _1065, _1120);
            float _1122 = (cb13_raw[_1105].x) * _1063;
            float _1123 = mad((cb13_raw[_1105].y), _1064, _1122);
            float _1124 = mad((cb13_raw[_1105].z), _1065, _1123);
            float _1125 = (cb13_raw[_1100].y) * _1063;
            float _1126 = mad((cb13_raw[_1100].z), _1064, _1125);
            float _1127 = mad((cb13_raw[_1100].w), _1065, _1126);
            float _1128 = -0.0f - _1121;
            float _1129 = -0.0f - _1124;
            float _1130 = -0.0f - _1127;
            float _1131 = _1128 / _997;
            float _1132 = _1129 / _997;
            float _1133 = _1130 / _997;
            float _1134 = abs(_1131);
            float _1135 = abs(_1132);
            float _1136 = abs(_1133);
            int _1137 = _1025 & 4;
            bool _1138 = (_1137 == 0);
            float _1139 = max(_1135, _1136);
            bool _1140 = (_1134 > _1139);
            if (!_1138) {
              if (_1140) {
                bool _1143 = (_1131 > 0.0f);
                uint _1144 = _983 + 75u;
                if (_1143) {
                  _1170 = _1124;
                  _1171 = _1127;
                  _1172 = _1128;
                  _1173 = (cb13_raw[_1144].x);
                } else {
                  _1170 = _1129;
                  _1171 = _1127;
                  _1172 = _1121;
                  _1173 = (cb13_raw[_1144].y);
                }
              } else {
                float _1151 = max(_1134, _1136);
                bool _1152 = (_1135 > _1151);
                if (_1152) {
                  bool _1154 = (_1132 > 0.0f);
                  uint _1155 = _983 + 75u;
                  if (_1154) {
                    _1170 = _1128;
                    _1171 = _1127;
                    _1172 = _1129;
                    _1173 = (cb13_raw[_1155].z);
                  } else {
                    _1170 = _1121;
                    _1171 = _1127;
                    _1172 = _1124;
                    _1173 = (cb13_raw[_1155].w);
                  }
                } else {
                  bool _1162 = (_1133 > 0.0f);
                  uint _1163 = _983 + 76u;
                  if (_1162) {
                    _1170 = _1121;
                    _1171 = _1124;
                    _1172 = _1130;
                    _1173 = (cb13_raw[_1163].x);
                  } else {
                    _1170 = _1121;
                    _1171 = _1129;
                    _1172 = _1127;
                    _1173 = (cb13_raw[_1163].y);
                  }
                }
              }
              int _1175 = asint((cb13_raw[_1022].z));
              _1260 = _1170;
              _1261 = _1171;
              _1262 = _1172;
              _1263 = _1173;
              _1264 = _1175;
            } else {
              if (_1140) {
                bool _1178 = (_1131 > 0.0f);
                uint _1179 = _983 + 75u;
                int _1182 = asint((cb13_raw[_1022].z));
                if (_1178) {
                  _1260 = _1124;
                  _1261 = _1127;
                  _1262 = _1128;
                  _1263 = (cb13_raw[_1179].x);
                  _1264 = _1182;
                } else {
                  int _1187 = (uint)(_1182) >> 10;
                  _1260 = _1129;
                  _1261 = _1127;
                  _1262 = _1121;
                  _1263 = (cb13_raw[_1179].y);
                  _1264 = _1187;
                }
              } else {
                float _1189 = max(_1134, _1136);
                bool _1190 = (_1135 > _1189);
                if (_1190) {
                  bool _1192 = (_1132 > 0.0f);
                  uint _1193 = _983 + 75u;
                  if (_1192) {
                    int _1198 = asint((cb13_raw[_1022].z));
                    int _1199 = (uint)(_1198) >> 20;
                    _1260 = _1128;
                    _1261 = _1127;
                    _1262 = _1129;
                    _1263 = (cb13_raw[_1193].z);
                    _1264 = _1199;
                  } else {
                    int _1203 = asint((cb13_raw[_1022].w));
                    _1260 = _1121;
                    _1261 = _1127;
                    _1262 = _1124;
                    _1263 = (cb13_raw[_1193].w);
                    _1264 = _1203;
                  }
                } else {
                  bool _1205 = (_1133 > 0.0f);
                  uint _1206 = _983 + 76u;
                  int _1209 = asint((cb13_raw[_1022].w));
                  if (_1205) {
                    int _1212 = (uint)(_1209) >> 10;
                    _1260 = _1121;
                    _1261 = _1124;
                    _1262 = _1130;
                    _1263 = (cb13_raw[_1206].x);
                    _1264 = _1212;
                  } else {
                    int _1215 = (uint)(_1209) >> 20;
                    _1260 = _1121;
                    _1261 = _1129;
                    _1262 = _1127;
                    _1263 = (cb13_raw[_1206].y);
                    _1264 = _1215;
                  }
                }
              }
            }
          } else {
            float _1217 = _989 / _997;
            float _1218 = _990 / _997;
            float _1219 = _991 / _997;
            float _1220 = abs(_1217);
            float _1221 = abs(_1218);
            float _1222 = abs(_1219);
            float _1223 = max(_1221, _1222);
            bool _1224 = (_1220 > _1223);
            if (_1224) {
              bool _1226 = (_1217 > 0.0f);
              uint _1227 = _983 + 75u;
              if (_1226) {
                _1253 = _1064;
                _1254 = _1065;
                _1255 = _989;
                _1256 = (cb13_raw[_1227].x);
              } else {
                _1253 = _990;
                _1254 = _1065;
                _1255 = _1063;
                _1256 = (cb13_raw[_1227].y);
              }
            } else {
              float _1234 = max(_1220, _1222);
              bool _1235 = (_1221 > _1234);
              if (_1235) {
                bool _1237 = (_1218 > 0.0f);
                uint _1238 = _983 + 75u;
                if (_1237) {
                  _1253 = _989;
                  _1254 = _1065;
                  _1255 = _990;
                  _1256 = (cb13_raw[_1238].z);
                } else {
                  _1253 = _1063;
                  _1254 = _1065;
                  _1255 = _1064;
                  _1256 = (cb13_raw[_1238].w);
                }
              } else {
                bool _1245 = (_1219 > 0.0f);
                uint _1246 = _983 + 76u;
                if (_1245) {
                  _1253 = _1063;
                  _1254 = _1064;
                  _1255 = _991;
                  _1256 = (cb13_raw[_1246].x);
                } else {
                  _1253 = _1063;
                  _1254 = _990;
                  _1255 = _1065;
                  _1256 = (cb13_raw[_1246].y);
                }
              }
            }
            int _1258 = asint((cb13_raw[_1022].z));
            _1260 = _1253;
            _1261 = _1254;
            _1262 = _1255;
            _1263 = _1256;
            _1264 = _1258;
          }
        }
        float _1266 = _1260 * (cb13_raw[_999].y);
        float _1267 = mad((cb13_raw[_999].y), _1261, 0.0f);
        float _1268 = _1266 / _1262;
        float _1269 = _1267 / _1262;
        float _1270 = _1268 * 0.5f;
        float _1271 = _1269 * 0.5f;
        float _1272 = _1270 + 0.5f;
        float _1273 = 0.5f - _1271;
        if (_1017) {
          int _1275 = asint(_1263);
          int _1276 = (uint)(_1275) >> 18;
          int _1277 = _1276 & 4092;
          float _1278 = float((uint)_1277);
          bool _1279 = (_1277 == 0);
          [branch]
          if (!_1279) {
            int _1281 = (uint)(_1275) >> 30;
            float _1282 = float((uint)_1281);
            int _1283 = (uint)(_1275) >> 8;
            int _1284 = _1283 & 4092;
            float _1285 = float((uint)_1284);
            uint _1286 = _1275 << 2u;
            int _1287 = _1286 & 4092;
            float _1288 = float((uint)_1287);
            float _1289 = _1272 * _1278;
            float _1290 = _1273 * _1278;
            float _1291 = _1289 + _1288;
            float _1292 = _1290 + _1285;
            float _1295 = cb13_067x * _1291;
            float _1296 = cb13_067x * _1292;
            float _1299 = t9.SampleLevel(s10, float3(_1295, _1296, _1282), 0.0f);
            float _1301 = _1004 * 0.9900000095367432f;
            float _1302 = _1299.x - _1301;
            float _1303 = _1302 * 144.26950073242188f;
            float _1304 = exp2(_1303);
            float _1305 = saturate(_1304);
            _1307 = _1305;
          } else {
            _1307 = 1.0f;
          }
        } else {
          _1307 = 1.0f;
        }
        if (_1027) {
          int _1309 = _1025 & 2;
          bool _1310 = (_1309 != 0);
          int _1311 = _1025 & 8;
          bool _1312 = (_1311 == 0);
          if (_1310) {
            int _1314 = _1264 & 1023;
            _1320 = _1314;
            _1321 = 0;
          } else {
            int _1316 = _1264 & 255;
            int _1317 = (uint)(_1264) >> 8;
            int _1318 = _1317 & 3;
            _1320 = _1316;
            _1321 = _1318;
          }
          float _1322 = float((uint)_1320);
          float _1324 = floor(cb13_raw[_1022].y);
          float _1325 = _1324 + _1322;
          float4 _1329 = t42.SampleLevel(s10, float3(_1272, _1273, _1325), 0.0f);
          _36[0] = _1329.x;
          _36[1] = _1329.y;
          _36[2] = _1329.z;
          _36[3] = _1329.w;
          if (!_1312) {
            float _1339 = _1325 + 1.0f;
            float4 _1340 = t42.SampleLevel(s10, float3(_1272, _1273, _1339), 0.0f);
            float _1345 = frac(cb13_raw[_1022].y);
            float _1346 = _1340.x - _1329.x;
            float _1347 = _1340.y - _1329.y;
            float _1348 = _1340.z - _1329.z;
            float _1349 = _1340.w - _1329.w;
            float _1350 = _1346 * _1345;
            float _1351 = _1347 * _1345;
            float _1352 = _1348 * _1345;
            float _1353 = _1349 * _1345;
            float _1354 = _1350 + _1329.x;
            float _1355 = _1351 + _1329.y;
            float _1356 = _1352 + _1329.z;
            float _1357 = _1353 + _1329.w;
            _36[0] = _1354;
            _36[1] = _1355;
            _36[2] = _1356;
            _36[3] = _1357;
            _1359 = _1356;
            _1360 = _1355;
            _1361 = _1354;
          } else {
            _1359 = _1329.z;
            _1360 = _1329.y;
            _1361 = _1329.x;
          }
          if (!_1310) {
            float _1364 = _36[_1321];
            _1366 = _1364;
            _1367 = _1364;
            _1368 = _1364;
          } else {
            _1366 = _1361;
            _1367 = _1360;
            _1368 = _1359;
          }
          _1370 = _1307;
          _1371 = _1366;
          _1372 = _1367;
          _1373 = _1368;
        } else {
          _1370 = _1307;
          _1371 = 1.0f;
          _1372 = 1.0f;
          _1373 = 1.0f;
        }
      } else {
        _1370 = 1.0f;
        _1371 = 1.0f;
        _1372 = 1.0f;
        _1373 = 1.0f;
      }
      bool _1374 = _1021 && _1060;
      if (_1374) {
        float _1379 = t10.SampleLevel(s10, float4(_989, _990, _991, (cb13_raw[_1018].y)), 0.0f);
        float _1381 = _1004 * 0.9900000095367432f;
        float _1382 = _1379.x - _1381;
        float _1383 = _1382 * 144.26950073242188f;
        float _1384 = exp2(_1383);
        float _1385 = saturate(_1384);
        float _1386 = _1385 * _1370;
        _1388 = _1386;
      } else {
        _1388 = _1370;
      }
      uint _1389 = _983 + 70u;
      float _1392 = _1388 + -1.0f;
      float _1393 = (cb13_raw[_1389].w) * _1392;
      float _1394 = _1393 + 1.0f;
      int _1395 = _1013 & 2048;
      bool _1396 = (_1395 != 0);
      bool _1397 = (_466.z == 1.0f);
      bool _1398 = _1397 || _1396;
      if (_1398) {
        _1403 = cb12_071y;
      } else {
        _1403 = 0.0f;
      }
      int _1404 = _1013 & 4096;
      bool _1405 = (_1404 != 0);
      bool _1406 = !(_466.z == 1.0f);
      bool _1407 = _1406 || _1405;
      if (_1407) {
        _1412 = cb12_071z;
      } else {
        _1412 = 0.0f;
      }
      float _1413 = _1394 * _1058;
      float _1414 = _1413 * _1403;
      float _1415 = _1414 * _1412;
      float _1416 = _1415 * _1371;
      float _1417 = _1415 * _1372;
      float _1418 = _1415 * _1373;
      bool _1419 = (_1416 > 0.0f);
      bool _1420 = (_1417 > 0.0f);
      bool _1421 = (_1418 > 0.0f);
      bool _1422 = _1419 || _1420;
      bool _1423 = _1421 || _1422;
      [branch]
      if (_1423) {
        bool _1427 = (FrequentPixelConsts_256.x < 0.0f);
        if (!_1427) {
          _1432 = cb12_071x;
        } else {
          _1432 = 1.0f;
        }
        bool _1433 = ((int)_1013 < (int)0);
        float _1434 = select(_1433, _1432, 1.0f);
        float _1435 = _1434 * _1416;
        float _1436 = _1434 * _1417;
        float _1437 = _1434 * _1418;
        float _1438 = dot(float3(_989, _990, _991), float3(_989, _990, _991));
        float _1439 = rsqrt(_1438);
        float _1440 = _1439 * _989;
        float _1441 = _1439 * _990;
        float _1442 = _1439 * _991;
        float _1443 = dot(float3(_404, _405, _406), float3(_1440, _1441, _1442));
        float _1444 = _1443 + 0.25f;
        float _1445 = _1444 * 0.800000011920929f;
        float _1446 = saturate(_1445);
        float _1447 = _1446 + _1443;
        float _1448 = _1446 + 1.0f;
        float _1449 = _1447 / _1448;
        float _1450 = 1.0f / _1448;
        float _1451 = saturate(_1449);
        bool _1452 = (_444 == 1);
        if (_1452) {
          float _1454 = saturate(_1443);
          bool _1455 = (_406 > 0.0f);
          int _1456 = (int)(uint)(_1455);
          int _1457 = _1456 << 1u;
          int _1458 = _1457 + -1;
          float _1459 = float((int)(_1458));
          float _1460 = _1459 + _406;
          float _1461 = -1.0f / _1460;
          float _1462 = _404 * _405;
          float _1463 = _1462 * _1461;
          float _1464 = _404 * _404;
          float _1465 = _1464 * _1459;
          float _1466 = _1465 * _1461;
          float _1467 = _1466 + 1.0f;
          float _1468 = _1463 * _1459;
          int _1469 = 1 - _1457;
          float _1470 = float((int)(_1469));
          float _1471 = _1470 * _404;
          float _1472 = _405 * _405;
          float _1473 = _1472 * _1461;
          float _1474 = _1473 + _1459;
          float _1475 = -0.0f - _405;
          float _1476 = dot(float3(_1440, _1441, _1442), float3(_1440, _1441, _1442));
          float _1477 = rsqrt(_1476);
          float _1478 = _1477 * _1440;
          float _1479 = _1477 * _1441;
          float _1480 = _1477 * _1442;
          float _1481 = _1478 * _1467;
          float _1482 = mad(_1468, _1479, _1481);
          float _1483 = mad(_1471, _1480, _1482);
          float _1484 = _1478 * _1463;
          float _1485 = mad(_1474, _1479, _1484);
          float _1486 = mad(_1475, _1480, _1485);
          float _1487 = _1478 * _404;
          float _1488 = mad(_405, _1479, _1487);
          float _1489 = mad(_406, _1480, _1488);
          float _1490 = dot(float3(_1483, _1486, _1489), float3(_1483, _1486, _1489));
          float _1491 = rsqrt(_1490);
          float _1492 = _1491 * _1483;
          float _1493 = _1491 * _1486;
          float _1494 = _1491 * _1489;
          float _1495 = dot(float3(_462, _463, _464), float3(_462, _463, _464));
          float _1496 = rsqrt(_1495);
          float _1497 = _1496 * _462;
          float _1498 = _1496 * _463;
          float _1499 = _1496 * _464;
          float _1500 = _1497 * _1467;
          float _1501 = mad(_1468, _1498, _1500);
          float _1502 = mad(_1471, _1499, _1501);
          float _1503 = _1497 * _1463;
          float _1504 = mad(_1474, _1498, _1503);
          float _1505 = mad(_1475, _1499, _1504);
          float _1506 = _1497 * _404;
          float _1507 = mad(_405, _1498, _1506);
          float _1508 = mad(_406, _1499, _1507);
          float _1509 = dot(float3(_1502, _1505, _1508), float3(_1502, _1505, _1508));
          float _1510 = rsqrt(_1509);
          float _1511 = _1510 * _1502;
          float _1512 = _1510 * _1505;
          float _1513 = _1510 * _1508;
          float _1514 = dot(float3(_1492, _1493, _1494), float3(_1511, _1512, _1513));
          float _1515 = _1513 * _1494;
          float _1516 = _1514 - _1515;
          bool _1517 = (_1516 > 0.0f);
          if (_1517) {
            float _1519 = max(_1494, _1513);
            float _1520 = _1516 / _1519;
            _1522 = _1520;
          } else {
            _1522 = _1516;
          }
          float _1523 = _1522 * 0.20908956229686737f;
          float _1524 = _1523 + 0.25813528895378113f;
          float _1525 = _1524 * _387;
          float _1526 = _1524 * _388;
          float _1527 = _1524 * _389;
          float _1528 = 1.0f - _1513;
          float _1529 = _1528 * 0.07144299894571304f;
          float _1530 = _1529 + -0.332181453704834f;
          float _1531 = _1530 * _1528;
          float _1532 = _1531 + 0.4918818771839142f;
          float _1533 = _1532 * _1528;
          float _1534 = _1533 + 0.05710852891206741f;
          float _1535 = _1528 * 0.6568742394447327f;
          float _1536 = _1535 * _1534;
          float _1537 = 1.0f - _1494;
          float _1538 = _1537 * 0.07144299894571304f;
          float _1539 = _1538 + -0.332181453704834f;
          float _1540 = _1539 * _1537;
          float _1541 = _1540 + 0.4918818771839142f;
          float _1542 = _1541 * _1537;
          float _1543 = _1542 + 0.05710852891206741f;
          float _1544 = _1537 * 0.6568742394447327f;
          float _1545 = _1544 * _1543;
          float _1546 = _387 * _387;
          float _1547 = _388 * _388;
          float _1548 = _389 * _389;
          float _1549 = _1546 * 0.8585715889930725f;
          float _1550 = _1547 * 0.8585715889930725f;
          float _1551 = _1548 * 0.8585715889930725f;
          float _1552 = _387 * 0.1414284110069275f;
          float _1553 = _388 * 0.1414284110069275f;
          float _1554 = _389 * 0.1414284110069275f;
          float _1555 = 1.0f - _1552;
          float _1556 = 1.0f - _1553;
          float _1557 = 1.0f - _1554;
          float _1558 = _1549 / _1555;
          float _1559 = _1550 / _1556;
          float _1560 = _1551 / _1557;
          float _1561 = 0.1890440583229065f - _1536;
          float _1562 = max(1.0000000116860974e-07f, _1561);
          float _1563 = 0.1890440583229065f - _1545;
          float _1564 = max(1.0000000116860974e-07f, _1563);
          float _1565 = _1562 * 2.250678300857544f;
          float _1566 = _1565 * _1564;
          float _1567 = _1566 * _1558;
          float _1568 = _1566 * _1559;
          float _1569 = _1566 * _1560;
          float _1570 = _1567 + _1525;
          float _1571 = _1568 + _1526;
          float _1572 = _1569 + _1527;
          float _1573 = _1570 * _1454;
          float _1574 = _1571 * _1454;
          float _1575 = _1572 * _1454;
          float _1576 = _1451 - _1454;
          float _1577 = max(0.0f, _1576);
          float _1578 = _1577 * 0.31830987334251404f;
          float _1579 = _1578 * _387;
          float _1580 = _1578 * _388;
          float _1581 = _1578 * _389;
          float _1582 = _1573 + _1579;
          float _1583 = _1574 + _1580;
          float _1584 = _1575 + _1581;
          _1586 = _1582;
          _1587 = _1583;
          _1588 = _1584;
        } else {
          _1586 = _1451;
          _1587 = _1451;
          _1588 = _1451;
        }
        bool _1591 = (cb12_221x > 0.0f);
        float _1592 = 1.0f - _399;
        float _1593 = 1.0f - _400;
        float _1594 = 1.0f - _401;
        if (_1591) {
          float _1596 = dot(float3(_404, _405, _406), float3(_462, _463, _464));
          float4 _1599 = t43.SampleLevel(s10, float2(0.8999999761581421f, _1596), 0.0f);
          float _1602 = _1599.x * _399;
          float _1603 = _1599.x * _400;
          float _1604 = _1599.x * _401;
          float _1605 = _1602 + _1599.y;
          float _1606 = _1603 + _1599.y;
          float _1607 = _1604 + _1599.y;
          float _1608 = _1592 * 0.0476190485060215f;
          float _1609 = _1593 * 0.0476190485060215f;
          float _1610 = _1594 * 0.0476190485060215f;
          float _1611 = _1608 + _399;
          float _1612 = _1609 + _400;
          float _1613 = _1610 + _401;
          float _1614 = 1.0f - _1605;
          float _1615 = 1.0f - _1606;
          float _1616 = 1.0f - _1607;
          float _1617 = _1614 * _1611;
          float _1618 = _1615 * _1612;
          float _1619 = _1616 * _1613;
          float _1620 = 1.0f - _1617;
          float _1621 = 1.0f - _1618;
          float _1622 = 1.0f - _1619;
          float _1623 = max(_1620, 0.0010000000474974513f);
          float _1624 = max(_1621, 0.0010000000474974513f);
          float _1625 = max(_1622, 0.0010000000474974513f);
          float _1626 = _1605 / _1623;
          float _1627 = _1606 / _1624;
          float _1628 = _1607 / _1625;
          float _1629 = min(_1626, 1.0f);
          float _1630 = min(_1627, 1.0f);
          float _1631 = min(_1628, 1.0f);
          _1667 = _1629;
          _1668 = _1630;
          _1669 = _1631;
        } else {
          float _1633 = _1440 + _462;
          float _1634 = _1441 + _463;
          float _1635 = _1442 + _464;
          float _1636 = dot(float3(_1633, _1634, _1635), float3(_1633, _1634, _1635));
          float _1637 = rsqrt(_1636);
          float _1638 = _1637 * _1633;
          float _1639 = _1637 * _1634;
          float _1640 = _1637 * _1635;
          float _1641 = dot(float3(_1638, _1639, _1640), float3(_462, _463, _464));
          float _1642 = abs(_1641);
          float _1643 = 1.0f - _1642;
          float _1644 = saturate(_1643);
          float _1645 = _1644 * _1644;
          float _1649 = max(0.0f, _1592);
          float _1650 = max(0.0f, _1593);
          float _1651 = max(0.0f, _1594);
          float _1652 = _1645 * _1645;
          float _1653 = _1652 * _1644;
          float _1654 = _1653 * cb13_066x;
          float _1655 = _1654 * _1649;
          float _1656 = _1654 * _1650;
          float _1657 = _1654 * _1651;
          float _1658 = cb13_066z * 0.8999999761581421f;
          float _1659 = _1658 + 1.0f;
          float _1660 = _1655 / _1659;
          float _1661 = _1656 / _1659;
          float _1662 = _1657 / _1659;
          float _1663 = _1660 + _399;
          float _1664 = _1661 + _400;
          float _1665 = _1662 + _401;
          _1667 = _1663;
          _1668 = _1664;
          _1669 = _1665;
        }
        float _1670 = 1.0f - _1667;
        float _1671 = 1.0f - _1668;
        float _1672 = 1.0f - _1669;
        float _1673 = _1670 * _1586;
        float _1674 = _1671 * _1587;
        float _1675 = _1672 * _1588;
        int _1676 = _444 & -3;
        bool _1677 = (_1676 == 0);
        float _1678 = _1673 * 0.31830987334251404f;
        float _1679 = _1674 * 0.31830987334251404f;
        float _1680 = _1675 * 0.31830987334251404f;
        float _1681 = select(_1677, _1678, _1673);
        float _1682 = select(_1677, _1679, _1674);
        float _1683 = select(_1677, _1680, _1675);
        float _1687 = _1435 * (cb13_raw[_1010].x);
        float _1688 = _1687 * _1450;
        float _1689 = _1688 * _1681;
        float _1690 = _1436 * (cb13_raw[_1010].y);
        float _1691 = _1690 * _1450;
        float _1692 = _1691 * _1682;
        float _1693 = _1437 * (cb13_raw[_1010].z);
        float _1694 = _1693 * _1450;
        float _1695 = _1694 * _1683;
        float _1696 = _1689 + _969;
        float _1697 = _1692 + _970;
        float _1698 = _1695 + _971;
        float _1699 = dot(float3(_1440, _1441, _1442), float3(_404, _405, _406));
        bool _1700 = (_1699 > 0.0f);
        [branch]
        if (_1700) {
          float _1702 = _1440 + _462;
          float _1703 = _1441 + _463;
          float _1704 = _1442 + _464;
          float _1705 = dot(float3(_1702, _1703, _1704), float3(_1702, _1703, _1704));
          float _1706 = rsqrt(_1705);
          float _1707 = _1706 * _1702;
          float _1708 = _1706 * _1703;
          float _1709 = _1706 * _1704;
          float _1710 = dot(float3(_404, _405, _406), float3(_462, _463, _464));
          float _1711 = saturate(_1443);
          float _1712 = dot(float3(_180, _181, _182), float3(_180, _181, _182));
          float _1713 = rsqrt(_1712);
          float _1714 = _1713 * _180;
          float _1715 = _1713 * _181;
          float _1716 = _1713 * _182;
          float _1717 = dot(float3(_1714, _1715, _1716), float3(_404, _405, _406));
          float _1718 = _1717 * _404;
          float _1719 = _1717 * _405;
          float _1720 = _1717 * _406;
          float _1721 = _1714 - _1718;
          float _1722 = _1715 - _1719;
          float _1723 = _1716 - _1720;
          float _1724 = dot(float3(_1721, _1722, _1723), float3(_1721, _1722, _1723));
          float _1725 = rsqrt(_1724);
          float _1726 = _1721 * _1725;
          float _1727 = _1722 * _1725;
          float _1728 = _1723 * _1725;
          float _1729 = _1727 * _406;
          float _1730 = _1728 * _405;
          float _1731 = _1729 - _1730;
          float _1732 = _1728 * _404;
          float _1733 = _1726 * _406;
          float _1734 = _1732 - _1733;
          float _1735 = _1726 * _405;
          float _1736 = _1727 * _404;
          float _1737 = _1735 - _1736;
          float _1738 = dot(float3(_1731, _1734, _1737), float3(_1731, _1734, _1737));
          float _1739 = rsqrt(_1738);
          float _1740 = _1731 * _1739;
          float _1741 = _1734 * _1739;
          float _1742 = _1737 * _1739;
          float _1743 = dot(float3(_1726, _1727, _1728), float3(_1707, _1708, _1709));
          float _1744 = _1743 * 1.2345679998397827f;
          float _1745 = _1744 * _1744;
          float _1746 = dot(float3(_1740, _1741, _1742), float3(_1707, _1708, _1709));
          float _1747 = _1746 * 1.2345679998397827f;
          float _1748 = _1747 * _1747;
          float _1749 = dot(float3(_404, _405, _406), float3(_1707, _1708, _1709));
          float _1750 = saturate(_1749);
          float _1751 = _1750 * _1750;
          float _1752 = _1748 + _1745;
          float _1753 = _1752 + _1751;
          float _1754 = _1753 * _1753;
          float _1755 = 0.4851658046245575f / _1754;
          float _1756 = abs(_1710);
          float _1757 = dot(float3(_1707, _1708, _1709), float3(_462, _463, _464));
          float _1758 = abs(_1757);
          float _1759 = 1.0f - _1758;
          float _1760 = saturate(_1759);
          float _1761 = _1760 * _1760;
          float _1765 = max(0.0f, _1592);
          float _1766 = max(0.0f, _1593);
          float _1767 = max(0.0f, _1594);
          float _1768 = _1761 * _1761;
          float _1769 = _1768 * _1760;
          float _1770 = _1769 * cb13_066x;
          float _1771 = _1770 * _1765;
          float _1772 = _1770 * _1766;
          float _1773 = _1770 * _1767;
          float _1774 = cb13_066z * 0.8999999761581421f;
          float _1775 = _1774 + 1.0f;
          float _1776 = _1771 / _1775;
          float _1777 = _1772 / _1775;
          float _1778 = _1773 / _1775;
          float _1779 = _1776 + _399;
          float _1780 = _1777 + _400;
          float _1781 = _1778 + _401;
          bool _1783 = (cb12_221z > 0.0f);
          [branch]
          if (_1783) {
            float _1785 = saturate(_1710);
            float _1786 = _1785 + _1711;
            float _1787 = _1711 * 2.0f;
            float _1788 = _1787 * _1785;
            float _1789 = _1786 - _1788;
            float _1790 = _1789 * 0.809999942779541f;
            float _1791 = _1790 + _1788;
            _1806 = _1791;
          } else {
            float _1793 = _1756 * _1756;
            float _1794 = _1793 * 0.34390008449554443f;
            float _1795 = _1794 + 0.6560999155044556f;
            float _1796 = sqrt(_1795);
            float _1797 = _1796 * _1711;
            float _1798 = _1711 * _1711;
            float _1799 = _1798 * 0.34390008449554443f;
            float _1800 = _1799 + 0.6560999155044556f;
            float _1801 = sqrt(_1800);
            float _1802 = _1801 * _1756;
            float _1803 = _1797 + 9.999999747378752e-05f;
            float _1804 = _1803 + _1802;
            _1806 = _1804;
          }
          float _1807 = 0.5f / _1806;
          float _1808 = _1807 * _1755;
          float _1809 = _1808 * _1779;
          float _1810 = _1808 * _1780;
          float _1811 = _1808 * _1781;
          bool _1813 = (cb12_221y > 0.0f);
          if (_1813) {
            float _1815 = dot(float3(_404, _405, _406), float3(_1807, _1807, _1807));
            float4 _1818 = t43.SampleLevel(s10, float2(0.8999999761581421f, _1815), 0.0f);
            float _1821 = _1818.x * _399;
            float _1822 = _1818.x * _400;
            float _1823 = _1818.x * _401;
            float _1824 = _1821 + _1818.y;
            float _1825 = _1822 + _1818.y;
            float _1826 = _1823 + _1818.y;
            float _1827 = _1592 * 0.0476190485060215f;
            float _1828 = _1593 * 0.0476190485060215f;
            float _1829 = _1594 * 0.0476190485060215f;
            float _1830 = _1827 + _399;
            float _1831 = _1828 + _400;
            float _1832 = _1829 + _401;
            float _1833 = 1.0f - _1824;
            float _1834 = 1.0f - _1825;
            float _1835 = 1.0f - _1826;
            float _1836 = _1833 * _1830;
            float _1837 = _1834 * _1831;
            float _1838 = _1835 * _1832;
            float _1839 = 1.0f - _1836;
            float _1840 = 1.0f - _1837;
            float _1841 = 1.0f - _1838;
            float _1842 = max(_1839, 0.0010000000474974513f);
            float _1843 = max(_1840, 0.0010000000474974513f);
            float _1844 = max(_1841, 0.0010000000474974513f);
            float _1845 = _1824 / _1842;
            float _1846 = _1825 / _1843;
            float _1847 = _1826 / _1844;
            float _1848 = min(_1845, 1.0f);
            float _1849 = min(_1846, 1.0f);
            float _1850 = min(_1847, 1.0f);
            float _1851 = max(_1824, 9.999999747378752e-05f);
            float _1852 = max(_1825, 9.999999747378752e-05f);
            float _1853 = max(_1826, 9.999999747378752e-05f);
            float _1854 = _1848 / _1851;
            float _1855 = _1849 / _1852;
            float _1856 = _1850 / _1853;
            float _1857 = _1854 * _1809;
            float _1858 = _1855 * _1810;
            float _1859 = _1856 * _1811;
            _1861 = _1857;
            _1862 = _1858;
            _1863 = _1859;
          } else {
            _1861 = _1809;
            _1862 = _1810;
            _1863 = _1811;
          }
          float _1864 = _1861 * _1711;
          float _1865 = _1862 * _1711;
          float _1866 = _1863 * _1711;
          _1868 = _1864;
          _1869 = _1865;
          _1870 = _1866;
        } else {
          _1868 = 0.0f;
          _1869 = 0.0f;
          _1870 = 0.0f;
        }
        float _1871 = _1687 * _1868;
        float _1872 = _1690 * _1869;
        float _1873 = _1693 * _1870;
        float _1874 = _1871 + _972;
        float _1875 = _1872 + _973;
        float _1876 = _1873 + _974;
        _1878 = _1696;
        _1879 = _1697;
        _1880 = _1698;
        _1881 = _1874;
        _1882 = _1875;
        _1883 = _1876;
      } else {
        _1878 = _969;
        _1879 = _970;
        _1880 = _971;
        _1881 = _972;
        _1882 = _973;
        _1883 = _974;
      }
      int _1884 = _975 + 1;
      bool _1885 = ((int)_1884 < (int)256);
      if (_1885) {
        _969 = _1878;
        _970 = _1879;
        _971 = _1880;
        _972 = _1881;
        _973 = _1882;
        _974 = _1883;
        _975 = _1884;
        continue;
      } else {
        _1887 = _1878;
        _1888 = _1879;
        _1889 = _1880;
        _1890 = _1881;
        _1891 = _1882;
        _1892 = _1883;
      }
    } else {
      _1887 = _969;
      _1888 = _970;
      _1889 = _971;
      _1890 = _972;
      _1891 = _973;
      _1892 = _974;
    }
    break;
  }
  float _1893 = -0.0f - _462;
  float _1894 = -0.0f - _463;
  float _1895 = -0.0f - _464;
  float _1896 = dot(float3(_1893, _1894, _1895), float3(_404, _405, _406));
  float _1897 = _1896 * 2.0f;
  float _1898 = _1897 * _404;
  float _1899 = _1897 * _405;
  float _1900 = _1897 * _406;
  float _1901 = _1893 - _1898;
  float _1902 = _1894 - _1899;
  float _1903 = _1895 - _1900;
  float _1904 = dot(float3(_1901, _1902, _1903), float3(_1901, _1902, _1903));
  float _1905 = rsqrt(_1904);
  float _1906 = _1901 * _1905;
  float _1907 = _1902 * _1905;
  float _1908 = _1903 * _1905;
  float _1909 = ddx_coarse(_1906);
  float _1910 = ddx_coarse(_1907);
  float _1911 = ddx_coarse(_1908);
  float _1912 = ddy_coarse(_1906);
  float _1913 = ddy_coarse(_1907);
  float _1914 = ddy_coarse(_1908);
  int _1915 = _435 & 1;
  bool _1916 = (_1915 != 0);
  float _1917 = -0.0f - _1909;
  float _1918 = -0.0f - _1910;
  float _1919 = -0.0f - _1911;
  float _1920 = select(_1916, _1917, _1909);
  float _1921 = select(_1916, _1918, _1910);
  float _1922 = select(_1916, _1919, _1911);
  int _1923 = _436 & 1;
  bool _1924 = (_1923 != 0);
  float _1925 = -0.0f - _1912;
  float _1926 = -0.0f - _1913;
  float _1927 = -0.0f - _1914;
  float _1928 = select(_1924, _1925, _1912);
  float _1929 = select(_1924, _1926, _1913);
  float _1930 = select(_1924, _1927, _1914);
  float _1931 = _1928 + _1906;
  float _1932 = _1929 + _1907;
  float _1933 = _1930 + _1908;
  float _1934 = dot(float3(_1931, _1932, _1933), float3(_1931, _1932, _1933));
  float _1935 = rsqrt(_1934);
  float _1936 = _1935 * _1931;
  float _1937 = _1935 * _1932;
  float _1938 = _1933 * _1935;
  float _1939 = dot(float3(_1906, _1907, _1908), float3(_1936, _1937, _1938));
  float _1940 = acos(_1939);
  float _1941 = _1940 * 81.4873275756836f;
  float _1942 = log2(_1941);
  float _1943 = max(0.0f, _1942);
  float _1944 = _1920 + _1906;
  float _1945 = _1921 + _1907;
  float _1946 = _1922 + _1908;
  float _1947 = dot(float3(_1944, _1945, _1946), float3(_1944, _1945, _1946));
  float _1948 = rsqrt(_1947);
  float _1949 = _1948 * _1944;
  float _1950 = _1948 * _1945;
  float _1951 = _1948 * _1946;
  float _1952 = dot(float3(_1906, _1907, _1908), float3(_1949, _1950, _1951));
  float _1953 = acos(_1952);
  float _1954 = _1953 * 81.4873275756836f;
  float _1955 = log2(_1954);
  float _1956 = max(0.0f, _1955);
  float _1957 = max(_1956, _1943);
  float _1958 = _1957 * 0.625f;
  float _1959 = max(8.504999160766602f, _1958);
  float _1960 = max(_1959, 0.0f);
  float _1961 = min(_1960, 5.0f);
  bool _1962 = (_406 < 0.0f);
  float _1963 = _404 * 0.5f;
  float _1964 = _405 * -0.5f;
  float _1965 = 1.0f - _406;
  float _1966 = 1.0f / _1965;
  float _1967 = max(_1966, -3.4028234663852886e+38f);
  float _1968 = min(_1967, 3.4028234663852886e+38f);
  float _1969 = _1963 * _1968;
  float _1970 = _1964 * _1968;
  float _1971 = _404 * -0.5f;
  float _1972 = _405 * 0.5f;
  float _1973 = _406 + 1.0f;
  float _1974 = 1.0f / _1973;
  float _1975 = max(_1974, -3.4028234663852886e+38f);
  float _1976 = min(_1975, 3.4028234663852886e+38f);
  float _1977 = _1971 * _1976;
  float _1978 = _1972 * _1976;
  float _1979 = select(_1962, _1969, _1977);
  float _1980 = _1979 + 0.5f;
  float _1981 = select(_1962, _1970, _1978);
  float _1982 = _1981 + 0.5f;
  float _1983 = float((bool)_1962);
  if (_439) {
    float _1985 = _1980 * 0.9696969985961914f;
    float _1986 = _1982 * 0.9696969985961914f;
    float _1987 = _1986 + 0.01515151560306549f;
    float _1988 = _1983 + 0.01515151560306549f;
    float _1989 = _1988 + _1985;
    _1997 = _1989;
    _1998 = _1987;
  } else {
    float _1991 = _1980 * 0.6666666269302368f;
    float _1992 = _1982 * 0.6666666269302368f;
    float _1993 = _1992 + 0.1666666716337204f;
    float _1994 = _1983 + 0.1666666716337204f;
    float _1995 = _1994 + _1991;
    _1997 = _1995;
    _1998 = _1993;
  }
  float _1999 = _1997 * 0.5f;
  _2001 = 1;
  _2002 = 0.0f;
  _2003 = 0.0f;
  _2004 = 0.0f;
  _2005 = 0.0f;
  _2006 = 0.0f;
  _2007 = 0.0f;
  _2008 = 9.999999747378752e-06f;
  while(true) {
    int _2009 = _2001 * 12;
    int _2010 = _2009 + 102;
    int _2015 = _2009 + 103;
    int _2020 = _2009 + 104;
    int _2025 = _2009 + 105;
    float _2030 = (cb12_raw[_2010].x) * _73;
    float _2031 = mad((cb12_raw[_2015].x), _74, _2030);
    float _2032 = mad((cb12_raw[_2020].x), _75, _2031);
    float _2033 = _2032 + (cb12_raw[_2025].x);
    float _2034 = (cb12_raw[_2010].y) * _73;
    float _2035 = mad((cb12_raw[_2015].y), _74, _2034);
    float _2036 = mad((cb12_raw[_2020].y), _75, _2035);
    float _2037 = _2036 + (cb12_raw[_2025].y);
    float _2038 = (cb12_raw[_2010].z) * _73;
    float _2039 = mad((cb12_raw[_2015].z), _74, _2038);
    float _2040 = mad((cb12_raw[_2020].z), _75, _2039);
    float _2041 = _2040 + (cb12_raw[_2025].z);
    float _2042 = abs(_2033);
    float _2043 = abs(_2037);
    float _2044 = abs(_2041);
    float _2045 = 1.0f - _2042;
    float _2046 = 1.0f - _2043;
    float _2047 = 1.0f - _2044;
    int _2048 = _2009 + 106;
    int _2051 = asint((cb12_raw[_2048].y));
    bool _2052 = !(_466.z == -1.0f);
    [branch]
    if (_2052) {
      int _2054 = _2051 & 1;
      bool _2055 = (_2054 != 0);
      float _2056 = select(_2055, 1.0f, _466.z);
      int _2057 = _2051 & 2;
      bool _2058 = (_2057 != 0);
      float _2059 = 1.0f - _466.z;
      float _2060 = select(_2058, 1.0f, _2059);
      float _2061 = _2056 * _2060;
      _2063 = _2061;
    } else {
      _2063 = 1.0f;
    }
    bool _2064 = (_2045 > 0.0f);
    bool _2065 = (_2046 > 0.0f);
    bool _2066 = (_2047 > 0.0f);
    bool _2067 = _2064 && _2065;
    bool _2068 = _2067 && _2066;
    bool _2069 = (_2063 > 0.0f);
    bool _2070 = _2068 && _2069;
    if (_2070) {
      int _2072 = _2009 + 101;
      float _2077 = (cb12_raw[_2072].x) * _2045;
      float _2078 = (cb12_raw[_2072].y) * _2046;
      float _2079 = (cb12_raw[_2072].z) * _2047;
      float _2080 = saturate(_2077);
      float _2081 = saturate(_2078);
      float _2082 = saturate(_2079);
      float _2083 = 1.0f - _2008;
      float _2084 = _2063 * _2083;
      int _2085 = _2009 + 100;
      float _2088 = _2084 * _2080;
      float _2089 = _2088 * _2081;
      float _2090 = _2089 * _2082;
      float _2091 = _2090 * (cb12_raw[_2085].x);
      float _2092 = _2091 + _2008;
      float _2094 = _2091 * (cb12_raw[_2048].x);
      int _2095 = _2009 + 111;
      float _2098 = float((int)(asint(cb12_raw[_2095].x)));
      float _2099 = _2098 + _1998;
      float _2100 = _2099 * 0.1428571492433548f;
      if (_439) {
        float4 _2104 = t27.SampleLevel(s11, float2(_1999, _2100), 0.0f);
        float _2108 = _2104.x * _2091;
        float _2109 = _2104.y * _2091;
        float _2110 = _2104.z * _2091;
        _2121 = _2108;
        _2122 = _2109;
        _2123 = _2110;
      } else {
        float4 _2113 = t22.SampleLevel(s11, float2(_1999, _2100), 0.0f);
        float _2117 = _2113.x * _2094;
        float _2118 = _2113.y * _2094;
        float _2119 = _2113.z * _2094;
        _2121 = _2117;
        _2122 = _2118;
        _2123 = _2119;
      }
      float _2124 = _2121 + _2007;
      float _2125 = _2122 + _2006;
      float _2126 = _2123 + _2005;
      int _2130 = _2009 + 107;
      int _2135 = _2009 + 108;
      int _2140 = _2009 + 109;
      float _2145 = (cb12_raw[_2130].x) * _1901;
      float _2146 = mad((cb12_raw[_2135].x), _1902, _2145);
      float _2147 = mad((cb12_raw[_2140].x), _1903, _2146);
      float _2148 = (cb12_raw[_2130].y) * _1901;
      float _2149 = mad((cb12_raw[_2135].y), _1902, _2148);
      float _2150 = mad((cb12_raw[_2140].y), _1903, _2149);
      float _2151 = (cb12_raw[_2130].z) * _1901;
      float _2152 = mad((cb12_raw[_2135].z), _1902, _2151);
      float _2153 = mad((cb12_raw[_2140].z), _1903, _2152);
      int _2154 = _2009 + 110;
      float _2159 = (cb12_raw[_2130].x) * _73;
      float _2160 = mad((cb12_raw[_2135].x), _74, _2159);
      float _2161 = mad((cb12_raw[_2140].x), _75, _2160);
      float _2162 = _2161 + (cb12_raw[_2154].x);
      float _2163 = (cb12_raw[_2130].y) * _73;
      float _2164 = mad((cb12_raw[_2135].y), _74, _2163);
      float _2165 = mad((cb12_raw[_2140].y), _75, _2164);
      float _2166 = _2165 + (cb12_raw[_2154].y);
      float _2167 = (cb12_raw[_2130].z) * _73;
      float _2168 = mad((cb12_raw[_2135].z), _74, _2167);
      float _2169 = mad((cb12_raw[_2140].z), _75, _2168);
      float _2170 = _2169 + (cb12_raw[_2154].z);
      float _2171 = 1.0f / _2147;
      float _2172 = 1.0f / _2150;
      float _2173 = 1.0f / _2153;
      float _2174 = _2171 * _2162;
      float _2175 = _2172 * _2166;
      float _2176 = _2173 * _2170;
      float _2177 = _2171 - _2174;
      float _2178 = _2172 - _2175;
      float _2179 = _2173 - _2176;
      float _2180 = -0.0f - _2171;
      float _2181 = -0.0f - _2172;
      float _2182 = -0.0f - _2173;
      float _2183 = _2180 - _2174;
      float _2184 = _2181 - _2175;
      float _2185 = _2182 - _2176;
      float _2186 = max(_2177, _2183);
      float _2187 = max(_2178, _2184);
      float _2188 = max(_2179, _2185);
      float _2189 = min(_2187, _2188);
      float _2190 = min(_2186, _2189);
      float _2191 = _2190 * _1901;
      float _2192 = _2190 * _1902;
      float _2193 = _2190 * _1903;
      float _2194 = _73 - (cb12_raw[_2085].y);
      float _2195 = _2191 + _2194;
      float _2196 = _74 - (cb12_raw[_2085].z);
      float _2197 = _2192 + _2196;
      float _2198 = _75 - (cb12_raw[_2085].w);
      float _2199 = _2193 + _2198;
      float _2200 = dot(float3(_2195, _2197, _2199), float3(_2195, _2197, _2199));
      float _2201 = rsqrt(_2200);
      float _2202 = _2195 * _2201;
      float _2203 = _2197 * _2201;
      float _2204 = _2199 * _2201;
      bool _2205 = (_2204 < 0.0f);
      float _2206 = _2202 * 0.5f;
      float _2207 = _2203 * -0.5f;
      float _2208 = 1.0f - _2204;
      float _2209 = 1.0f / _2208;
      float _2210 = max(_2209, -3.4028234663852886e+38f);
      float _2211 = min(_2210, 3.4028234663852886e+38f);
      float _2212 = _2206 * _2211;
      float _2213 = _2207 * _2211;
      float _2214 = _2202 * -0.5f;
      float _2215 = _2203 * 0.5f;
      float _2216 = _2204 + 1.0f;
      float _2217 = 1.0f / _2216;
      float _2218 = max(_2217, -3.4028234663852886e+38f);
      float _2219 = min(_2218, 3.4028234663852886e+38f);
      float _2220 = _2214 * _2219;
      float _2221 = _2215 * _2219;
      float _2222 = select(_2205, _2212, _2220);
      float _2223 = _2222 + 0.5f;
      float _2224 = select(_2205, _2213, _2221);
      float _2225 = _2224 + 0.5f;
      float _2226 = _2223 * 0.6666666269302368f;
      float _2227 = _2225 * 0.6666666269302368f;
      float _2228 = float((bool)_2205);
      float _2229 = _2228 + 0.1666666716337204f;
      float _2230 = _2229 + _2226;
      float _2231 = _2098 + 0.1666666716337204f;
      float _2232 = _2231 + _2227;
      float _2233 = _2230 * 0.5f;
      float _2234 = _2232 * 0.1428571492433548f;
      float4 _2236 = t23.SampleLevel(s11, float2(_2233, _2234), _1961);
      float _2240 = _2236.x * _2094;
      float _2241 = _2236.y * _2094;
      float _2242 = _2236.z * _2094;
      float _2243 = _2240 + _2004;
      float _2244 = _2241 + _2003;
      float _2245 = _2242 + _2002;
      _2247 = _2092;
      _2248 = _2124;
      _2249 = _2125;
      _2250 = _2126;
      _2251 = _2243;
      _2252 = _2244;
      _2253 = _2245;
    } else {
      _2247 = _2008;
      _2248 = _2007;
      _2249 = _2006;
      _2250 = _2005;
      _2251 = _2004;
      _2252 = _2003;
      _2253 = _2002;
    }
    int _2254 = _2001 + 1;
    bool _2255 = ((uint)_2254 < (uint)7);
    _2256 = (_2247 < 0.9990000128746033f);
    bool _2257 = _2255 && _2256;
    if (_2257) {
      _2001 = _2254;
      _2002 = _2253;
      _2003 = _2252;
      _2004 = _2251;
      _2005 = _2250;
      _2006 = _2249;
      _2007 = _2248;
      _2008 = _2247;
      continue;
    }
    break;
  }
  [branch]
  if (_2256) {
    float _2260 = 1.0f - _2247;
    float _2263 = cb12_100x * _2260;
    float _2264 = _2263 + _2247;
    float _2267 = _2263 * cb12_106x;
    float _2270 = float((int)(cb12_111x));
    float _2271 = _2270 + _1998;
    float _2272 = _2271 * 0.1428571492433548f;
    if (_439) {
      float4 _2276 = t27.SampleLevel(s11, float2(_1999, _2272), 0.0f);
      float _2280 = _2276.x * _2263;
      float _2281 = _2276.y * _2263;
      float _2282 = _2276.z * _2263;
      _2293 = _2280;
      _2294 = _2281;
      _2295 = _2282;
    } else {
      float4 _2285 = t22.SampleLevel(s11, float2(_1999, _2272), 0.0f);
      float _2289 = _2285.x * _2267;
      float _2290 = _2285.y * _2267;
      float _2291 = _2285.z * _2267;
      _2293 = _2289;
      _2294 = _2290;
      _2295 = _2291;
    }
    float _2296 = _2293 + _2248;
    float _2297 = _2294 + _2249;
    float _2298 = _2295 + _2250;
    bool _2299 = (_1903 < 0.0f);
    float _2300 = _1901 * 0.5f;
    float _2301 = _1902 * -0.5f;
    float _2302 = 1.0f - _1903;
    float _2303 = 1.0f / _2302;
    float _2304 = max(_2303, -3.4028234663852886e+38f);
    float _2305 = min(_2304, 3.4028234663852886e+38f);
    float _2306 = _2300 * _2305;
    float _2307 = _2301 * _2305;
    float _2308 = _1901 * -0.5f;
    float _2309 = _1902 * 0.5f;
    float _2310 = _1903 + 1.0f;
    float _2311 = 1.0f / _2310;
    float _2312 = max(_2311, -3.4028234663852886e+38f);
    float _2313 = min(_2312, 3.4028234663852886e+38f);
    float _2314 = _2308 * _2313;
    float _2315 = _2309 * _2313;
    float _2316 = select(_2299, _2306, _2314);
    float _2317 = _2316 + 0.5f;
    float _2318 = select(_2299, _2307, _2315);
    float _2319 = _2318 + 0.5f;
    float _2320 = _2317 * 0.6666666269302368f;
    float _2321 = _2319 * 0.6666666269302368f;
    float _2322 = float((bool)_2299);
    float _2323 = _2322 + 0.1666666716337204f;
    float _2324 = _2323 + _2320;
    float _2325 = _2270 + 0.1666666716337204f;
    float _2326 = _2325 + _2321;
    float _2327 = _2324 * 0.5f;
    float _2328 = _2326 * 0.1428571492433548f;
    float4 _2330 = t23.SampleLevel(s11, float2(_2327, _2328), _1961);
    float _2334 = _2330.x * _2267;
    float _2335 = _2330.y * _2267;
    float _2336 = _2330.z * _2267;
    float _2337 = _2334 + _2251;
    float _2338 = _2335 + _2252;
    float _2339 = _2336 + _2253;
    _2341 = _2264;
    _2342 = _2296;
    _2343 = _2297;
    _2344 = _2298;
    _2345 = _2337;
    _2346 = _2338;
    _2347 = _2339;
  } else {
    _2341 = _2247;
    _2342 = _2248;
    _2343 = _2249;
    _2344 = _2250;
    _2345 = _2251;
    _2346 = _2252;
    _2347 = _2253;
  }
  float _2348 = 1.0f / _2341;
  float _2349 = _2348 * _2342;
  float _2350 = _2348 * _2343;
  float _2351 = _2348 * _2344;
  float _2352 = _2348 * _2345;
  float _2353 = _2348 * _2346;
  float _2354 = _2348 * _2347;
  bool _2357 = (cb12_074x > 0.0f);
  float _2358 = select(_2357, 0.0f, _2352);
  float _2359 = select(_2357, 0.0f, _2353);
  float _2360 = select(_2357, 0.0f, _2354);
  float _2363 = abs(FrequentPixelConsts_256.x);
  float _2367 = _2363 - FrequentPixelConsts_256.y;
  float _2368 = _2367 * _965;
  float _2369 = _2367 * _966;
  float _2370 = _2367 * _967;
  float _2371 = _2368 + FrequentPixelConsts_256.y;
  float _2372 = _2369 + FrequentPixelConsts_256.y;
  float _2373 = _2370 + FrequentPixelConsts_256.y;
  float _2374 = FrequentPixelConsts_256.z - FrequentPixelConsts_256.w;
  float _2375 = _2374 * _965;
  float _2376 = _2374 * _966;
  float _2377 = _2374 * _967;
  float _2378 = _2375 + FrequentPixelConsts_256.w;
  float _2379 = _2376 + FrequentPixelConsts_256.w;
  float _2380 = _2377 + FrequentPixelConsts_256.w;
  float _2381 = _2349 * _2371;
  float _2382 = _2350 * _2372;
  float _2383 = _2351 * _2373;
  float _2384 = _2378 * _2358;
  float _2385 = _2379 * _2359;
  float _2386 = _2380 * _2360;
  float _2390 = _73 - cb12_000x;
  float _2391 = _74 - cb12_000y;
  float _2392 = _2390 * _2390;
  float _2393 = _2391 * _2391;
  float _2394 = _2392 + _2393;
  float _2395 = sqrt(_2394);
  float _2398 = cb12_219x * _2395;
  float _2400 = _2398 + cb12_219y;
  float _2401 = saturate(_2400);
  float _2404 = cb12_185z + -1.0f;
  float _2405 = _2404 * _2401;
  float _2406 = _2405 + 1.0f;
  float _2412 = cb12_184x - cb12_184y;
  float _2413 = _2412 * _965;
  float _2414 = _2412 * _966;
  float _2415 = _2412 * _967;
  float _2416 = _2413 + cb12_184y;
  float _2417 = _2414 + cb12_184y;
  float _2418 = _2415 + cb12_184y;
  if (!_2357) {
    float _2422 = cb12_185x - cb12_185y;
    float _2423 = _2422 * _965;
    float _2424 = _2422 * _966;
    float _2425 = _2422 * _967;
    float _2426 = _2423 + cb12_185y;
    float _2427 = _2424 + cb12_185y;
    float _2428 = _2425 + cb12_185y;
    float _2429 = _2426 * _2406;
    float _2430 = _2427 * _2406;
    float _2431 = _2428 * _2406;
    _2433 = _2429;
    _2434 = _2430;
    _2435 = _2431;
  } else {
    _2433 = 1.0f;
    _2434 = 1.0f;
    _2435 = 1.0f;
  }
  float _2436 = dot(float3(_404, _405, _406), float3(_462, _463, _464));
  float _2437 = abs(_2436);
  float _2438 = max(_2437, _2437);
  float _2439 = abs(_2438);
  float _2440 = 1.0f - _2439;
  float _2441 = saturate(_2440);
  float _2442 = _2441 * _2441;
  float _2443 = _2442 * _2442;
  float _2444 = _2443 * _2441;
  float _2448 = min(0.25f, cb13_066y);
  float _2449 = 1.0f - _399;
  float _2450 = 1.0f - _400;
  float _2451 = 1.0f - _401;
  float _2452 = max(0.0f, _2449);
  float _2453 = max(0.0f, _2450);
  float _2454 = max(0.0f, _2451);
  float _2455 = _2444 * _2448;
  float _2456 = _2455 * _2452;
  float _2457 = _2455 * _2453;
  float _2458 = _2454 * _2455;
  float _2459 = cb13_066w * 0.8999999761581421f;
  float _2460 = _2459 + 1.0f;
  float _2461 = _2456 / _2460;
  float _2462 = _2457 / _2460;
  float _2463 = _2458 / _2460;
  float _2464 = _2449 - _2461;
  float _2465 = _2450 - _2462;
  float _2466 = _2451 - _2463;
  if (_439) {
    if (_441) {
      bool _2469 = (_406 > 0.0f);
      int _2470 = (int)(uint)(_2469);
      int _2471 = _2470 << 1u;
      int _2472 = _2471 + -1;
      float _2473 = float((int)(_2472));
      float _2474 = _2473 + _406;
      float _2475 = -1.0f / _2474;
      float _2476 = _404 * _405;
      float _2477 = _2476 * _2475;
      float _2478 = _404 * _404;
      float _2479 = _2478 * _2473;
      float _2480 = _2479 * _2475;
      float _2481 = _2480 + 1.0f;
      float _2482 = _2477 * _2473;
      int _2483 = 1 - _2471;
      float _2484 = float((int)(_2483));
      float _2485 = _2484 * _404;
      float _2486 = _405 * _405;
      float _2487 = _2486 * _2475;
      float _2488 = _2487 + _2473;
      float _2489 = -0.0f - _405;
      float _2490 = dot(float3(_462, _463, _464), float3(_462, _463, _464));
      float _2491 = rsqrt(_2490);
      float _2492 = _2491 * _462;
      float _2493 = _2491 * _463;
      float _2494 = _2491 * _464;
      float _2495 = _2492 * _2481;
      float _2496 = mad(_2482, _2493, _2495);
      float _2497 = mad(_2485, _2494, _2496);
      float _2498 = _2492 * _2477;
      float _2499 = mad(_2488, _2493, _2498);
      float _2500 = mad(_2489, _2494, _2499);
      float _2501 = _2492 * _404;
      float _2502 = mad(_405, _2493, _2501);
      float _2503 = mad(_406, _2494, _2502);
      float _2504 = dot(float3(_2497, _2500, _2503), float3(_2497, _2500, _2503));
      float _2505 = rsqrt(_2504);
      float _2506 = _2505 * _2503;
      float _2507 = 1.0f - _2506;
      float _2508 = _2507 * 0.07144299894571304f;
      float _2509 = _2508 + -0.332181453704834f;
      float _2510 = _2509 * _2507;
      float _2511 = _2510 + 0.4918818771839142f;
      float _2512 = _2511 * _2507;
      float _2513 = _2512 + 0.05710852891206741f;
      float _2514 = _2507 * 0.6568742394447327f;
      float _2515 = _2514 * _2513;
      float _2516 = _2515 + 0.8109559416770935f;
      float _2517 = _387 * _387;
      float _2518 = _388 * _388;
      float _2519 = _389 * _389;
      float _2520 = _2517 * 0.8585715889930725f;
      float _2521 = _2518 * 0.8585715889930725f;
      float _2522 = _2519 * 0.8585715889930725f;
      float _2523 = _387 * 0.1414284110069275f;
      float _2524 = _388 * 0.1414284110069275f;
      float _2525 = _389 * 0.1414284110069275f;
      float _2526 = 1.0f - _2523;
      float _2527 = 1.0f - _2524;
      float _2528 = 1.0f - _2525;
      float _2529 = _2520 / _2526;
      float _2530 = _2521 / _2527;
      float _2531 = _2522 / _2528;
      float _2532 = _2516 * _387;
      float _2533 = _2516 * _388;
      float _2534 = _2516 * _389;
      float _2535 = 0.1890440583229065f - _2515;
      float _2536 = _2535 * _2529;
      float _2537 = _2535 * _2530;
      float _2538 = _2535 * _2531;
      float _2539 = _2532 + _2536;
      float _2540 = _2533 + _2537;
      float _2541 = _2534 + _2538;
      float _2542 = _2464 * _2381;
      float _2543 = _2542 * _2539;
      float _2544 = _2465 * _2382;
      float _2545 = _2544 * _2540;
      float _2546 = _2466 * _2383;
      float _2547 = _2546 * _2541;
      _2566 = _2543;
      _2567 = _2545;
      _2568 = _2547;
    } else {
      float _2549 = _2464 * _2381;
      float _2550 = _2549 * _387;
      float _2551 = _2465 * _2382;
      float _2552 = _2551 * _388;
      float _2553 = _2466 * _2383;
      float _2554 = _2553 * _389;
      _2566 = _2550;
      _2567 = _2552;
      _2568 = _2554;
    }
  } else {
    float _2556 = _2464 * _2381;
    float _2557 = _2556 * _2406;
    float _2558 = _2557 * _2416;
    float _2559 = _2465 * _2382;
    float _2560 = _2559 * _2406;
    float _2561 = _2560 * _2417;
    float _2562 = _2466 * _2383;
    float _2563 = _2562 * _2406;
    float _2564 = _2563 * _2418;
    _2566 = _2558;
    _2567 = _2561;
    _2568 = _2564;
  }
  float _2569 = _2384 * _2433;
  float _2570 = _2385 * _2434;
  float _2571 = _2386 * _2435;
  float _2572 = _2461 + _399;
  float _2573 = _2462 + _400;
  float _2574 = _2463 + _401;
  float _2575 = _2569 * _2572;
  float _2576 = _2570 * _2573;
  float _2577 = _2571 * _2574;
  float4 _2579 = t17.Load(int3(_435, _436, 0));
  float _2583 = cb12_187x * _2579.x;
  float _2586 = _2583 + cb12_188x;
  float _2587 = saturate(_2586);
  float _2588 = _2587 + -1.0f;
  float _2589 = _2588 * 0.699999988079071f;
  float _2590 = _2589 + 1.0f;
  float _2591 = _2590 * _466.w;
  float _2594 = _2590 * cb12_069x;
  float _2596 = _2594 + cb12_069y;
  bool _2597 = (_466.z < 0.9900000095367432f);
  if (_2597) {
    _2602 = cb12_287w;
  } else {
    _2602 = 1.0f;
  }
  float _2605 = cb12_288x * _2602;
  float _2606 = log2(_2591);
  float _2607 = _2605 * _2606;
  float _2608 = exp2(_2607);
  if (_2597) {
    _2613 = cb12_287w;
  } else {
    _2613 = 1.0f;
  }
  float _2615 = _2606 * cb12_288y;
  float _2616 = _2615 * _2613;
  float _2617 = exp2(_2616);
  if (_2597) {
    _2622 = cb12_287w;
  } else {
    _2622 = 1.0f;
  }
  float _2624 = _2622 * cb12_288z;
  float _2625 = log2(_2596);
  float _2626 = _2624 * _2625;
  float _2627 = exp2(_2626);
  if (_2597) {
    _2632 = cb12_287w;
  } else {
    _2632 = 1.0f;
  }
  float _2634 = _2625 * cb12_288w;
  float _2635 = _2634 * _2632;
  float _2636 = exp2(_2635);
  float _2637 = (_2608 * _2566) * water_light.ambient.x;
  float _2638 = (_2608 * _2567) * water_light.ambient.y;
  float _2639 = (_2608 * _2568) * water_light.ambient.z;
  float _2640 = (_2575 * _2617) * water_light.ambient.x;
  float _2641 = (_2576 * _2617) * water_light.ambient.y;
  float _2642 = (_2577 * _2617) * water_light.ambient.z;
  float _2643 = _2627 * cb12_184z;
  float _2644 = _2643 * _1887;
  float _2645 = _2643 * _1888;
  float _2646 = _2643 * _1889;
  float _2647 = _2636 * cb12_184w;
  float _2648 = _2647 * _1890;
  float _2649 = _2647 * _1891;
  float _2650 = _2647 * _1892;
  bool _2651 = (_444 == 0);
  float _2652 = _2644 * _387;
  float _2653 = _2645 * _388;
  float _2654 = _2646 * _389;
  float _2655 = select(_2651, _2652, _2644);
  float _2656 = select(_2651, _2653, _2645);
  float _2657 = select(_2651, _2654, _2646);
  if (!_439) {
    float _2659 = _2637 * _387;
    float _2660 = _2638 * _388;
    float _2661 = _2639 * _389;
    _2663 = _2659;
    _2664 = _2660;
    _2665 = _2661;
  } else {
    _2663 = _2637;
    _2664 = _2638;
    _2665 = _2639;
  }
  float _2666 = _2648 + _2655;
  float _2667 = _2649 + _2656;
  float _2668 = _2650 + _2657;
  if (!_2357) {
    float _2670 = _2666 + _2640;
    float _2671 = _2667 + _2641;
    float _2672 = _2668 + _2642;
    _2674 = _2670;
    _2675 = _2671;
    _2676 = _2672;
  } else {
    _2674 = _2666;
    _2675 = _2667;
    _2676 = _2668;
  }
  float _2677 = _2665 + _2676;
  float _2678 = _2664 + _2675;
  float _2679 = _2663 + _2674;
  float _2680 = HAIR_TEX + 9.99999993922529e-09f;
  float _2681 = cbPerFrame_000.NvHair_ConstantBuffer_608.NvHair_Material_172 + 9.99999993922529e-09f;
  float _2682 = _2680 / _2681;
  float _2683 = saturate(_2682);
  float _2686 = 1.0f - cbPerFrame_000.NvHair_ConstantBuffer_600;
  float _2687 = _2686 * _2683;
  float _2688 = saturate(_2687);
  SV_Target.x = _2679;
  SV_Target.y = _2678;
  SV_Target.z = _2677;
  SV_Target.w = _2688;
  SV_Target_1.x = _432;
  SV_Target_1.y = _433;
  SV_Target_1.z = _434;
  SV_Target_1.w = 0.8999999761581421f;
  OutputSignature output_signature = { SV_Target, SV_Target_1 };
  return output_signature;
}
