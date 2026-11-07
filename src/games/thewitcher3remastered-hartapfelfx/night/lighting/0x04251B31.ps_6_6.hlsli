#include "../shared.h"

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


Texture2D<float4> t15 : register(t15);

Texture2D<float4> t0 : register(t0);

TextureCube<float4> t1 : register(t1);

Texture2D<float4> t24 : register(t24);

cbuffer cb0 : register(b0) {
  float4 GlobalShaderConsts_000 : packoffset(c000.x);
  float4 GlobalShaderConsts_016 : packoffset(c001.x);
  float4 GlobalShaderConsts_032 : packoffset(c002.x);
  float4 GlobalShaderConsts_048 : packoffset(c003.x);
  float4 GlobalShaderConsts_064 : packoffset(c004.x);
  float4 GlobalShaderConsts_080 : packoffset(c005.x);
  float4 GlobalShaderConsts_096 : packoffset(c006.x);
  float4 GlobalShaderConsts_112 : packoffset(c007.x);
  float4 GlobalShaderConsts_128 : packoffset(c008.x);
  float4 GlobalShaderConsts_144 : packoffset(c009.x);
  float4 GlobalShaderConsts_160 : packoffset(c010.x);
  float4 GlobalShaderConsts_176 : packoffset(c011.x);
  float4 GlobalShaderConsts_192 : packoffset(c012.x);
  float4 GlobalShaderConsts_208 : packoffset(c013.x);
  float4 GlobalShaderConsts_224 : packoffset(c014.x);
  float4 GlobalShaderConsts_240 : packoffset(c015.x);
};

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
  float cb12_000x : packoffset(c000.x);
  float cb12_000y : packoffset(c000.y);
  float cb12_000z : packoffset(c000.z);
  float cb12_001z : packoffset(c001.z);
  float cb12_002z : packoffset(c002.z);
  float cb12_003z : packoffset(c003.z);
  float cb12_021x : packoffset(c021.x);
  float cb12_021y : packoffset(c021.y);
  float cb12_022x : packoffset(c022.x);
  float cb12_022y : packoffset(c022.y);
  float cb12_067w : packoffset(c067.w);
  uint cb12_padding : packoffset(c340.w);
};

cbuffer cb4 : register(b4) {
  float cb4_000x : packoffset(c000.x);
  float cb4_000y : packoffset(c000.y);
  float cb4_001x : packoffset(c001.x);
  float cb4_001y : packoffset(c001.y);
  float cb4_002x : packoffset(c002.x);
  float cb4_003x : packoffset(c003.x);
  float cb4_004x : packoffset(c004.x);
  float cb4_004y : packoffset(c004.y);
  float cb4_004z : packoffset(c004.z);
  float cb4_005x : packoffset(c005.x);
  float cb4_006x : packoffset(c006.x);
  float cb4_007x : packoffset(c007.x);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
  float cb4_010x : packoffset(c010.x);
  float cb4_011x : packoffset(c011.x);
  float cb4_012x : packoffset(c012.x);
  float cb4_013x : packoffset(c013.x);
};

cbuffer cb13 : register(b13) {
  float cb13_032z : packoffset(c032.z);
  float cb13_032w : packoffset(c032.w);
  float cb13_033x : packoffset(c033.x);
  float cb13_033y : packoffset(c033.y);
  float cb13_033z : packoffset(c033.z);
  uint cb13_padding : packoffset(c3588.w);
};

SamplerState s15 : register(s15);

SamplerState s0 : register(s0);

SamplerState s8 : register(s8);

struct OutputSignature {
  float4 SV_Target_1 : SV_Target1;
  float4 SV_Target : SV_Target;
};

OutputSignature main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2,
  linear float4 TEXCOORD_3 : TEXCOORD3,
  linear float4 TEXCOORD_4 : TEXCOORD4,
  linear float3 TEXCOORD_5 : TEXCOORD5,
  noperspective float4 SV_Position : SV_Position
) {
  float4 SV_Target_1 = 0;
  float4 SV_Target = 0;
  float _41 = cb1_036x - TEXCOORD_5.x;
  float _42 = cb1_036y - TEXCOORD_5.y;
  float _43 = cb1_036z - TEXCOORD_5.z;
  float _45 = rsqrt(dot(float3(_41, _42, _43), float3(_41, _42, _43)));
  float _46 = _41 * _45;
  float _47 = _42 * _45;
  float _48 = _43 * _45;
  float _65 = (cb4_001x * GlobalShaderConsts_000.x) + (cb4_000x * TEXCOORD_1.y);
  float _66 = (cb4_001y * GlobalShaderConsts_000.x) + (cb4_000y * TEXCOORD_1.z);
  float _67 = 1.0f / cb4_002x;
  float _68 = 1.0f / cb4_003x;
  float _72 = floor(TEXCOORD_1.x) + _65;
  float4 _78 = t0.Sample(s0, float2((_72 * _67), ((floor(_67 * TEXCOORD_1.x) + _66) * _68)));
  float _82 = TEXCOORD_1.x + 1.0f;
  float _86 = floor(_82) + _65;
  float4 _92 = t0.Sample(s0, float2((_86 * _67), ((floor(_67 * _82) + _66) * _68)));
  float _96 = frac(TEXCOORD_1.x);
  float _114 = (cb4_004x * 2.0f) * ((_78.x + -0.5f) + ((_92.x - _78.x) * _96));
  float _116 = (cb4_004y * 2.0f) * ((_78.y + -0.5f) + ((_92.y - _78.y) * _96));
  float _118 = (cb4_004z * 2.0f) * ((_78.z + -0.5f) + ((_92.z - _78.z) * _96));
  float _120 = rsqrt(dot(float3(_114, _116, _118), float3(_114, _116, _118)));
  float _121 = _114 * _120;
  float _122 = _116 * _120;
  float _123 = _118 * _120;
  float _125 = dot(float3(_46, _47, _48), float3(_121, _122, _123)) * 2.0f;
  float4 _137 = t1.Sample(s0, float3((-0.0f - (_46 - (_121 * _125))), (-0.0f - (_47 - (_122 * _125))), (-0.0f - (_48 - (_123 * _125)))));
  float _155 = ((pow(_137.x, cb4_005x)) * TEXCOORD_4.x) * cb4_006x;
  float _157 = ((pow(_137.y, cb4_005x)) * TEXCOORD_4.y) * cb4_006x;
  float _159 = ((pow(_137.z, cb4_005x)) * TEXCOORD_4.z) * cb4_006x;
  float4 _170 = t15.SampleLevel(s15, float2((GlobalShaderConsts_016.z * SV_Position.x), (GlobalShaderConsts_016.w * SV_Position.y)), 0.0f);
  float _189 = 1.0f / cb4_002x;
  float _190 = 1.0f / cb4_003x;
  float4 _198 = t0.Sample(s0, float2((_189 * _72), ((floor(_189 * TEXCOORD_1.x) + _66) * _190)));
  float4 _207 = t0.Sample(s0, float2((_189 * _86), ((floor(_189 * _82) + _66) * _190)));
  float _296;
  float _297;
  float _302;
  if (!(cb12_067w < 0.0f)) {
    float4 _220 = t24.Sample(s8, float2((GlobalShaderConsts_016.z * SV_Position.x), (GlobalShaderConsts_016.w * SV_Position.y)));
    float _231 = TEXCOORD_5.x - cb12_000x;
    float _232 = TEXCOORD_5.y - cb12_000y;
    float _233 = TEXCOORD_5.z - cb12_000z;
    float _239 = sqrt(((_231 * _231) + (_232 * _232)) + (_233 * _233));
    float _259 = max(0.0010000000474974513f, (saturate((_239 - (((1.0f / cb12_021y) * _239) / dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_231, _232, _233)))) * cb13_032w) * cb13_032z));
    float _260 = _239 / cb13_033z;
    if (_220.x < _220.y) {
      if (!((int)(_260 < _220.x) || (int)(_260 > _220.y))) {
        _296 = 1.0f;
        _297 = (saturate(((_260 - _220.x) * cb13_033z) / _259) * saturate(1.0f - (((cb13_033z * _220.x) - cb13_033x) * cb13_033y)));
      } else {
        _296 = 0.0f;
        _297 = 1.0f;
      }
    } else {
      if (_220.x > _220.y) {
        if (!(_260 < _220.y)) {
          if (_260 > _220.x) {
            _296 = 1.0f;
            _297 = saturate(1.0f - (((cb13_033z * _220.x) - cb13_033x) * cb13_033y));
          } else {
            _296 = 1.0f;
            _297 = (1.0f - saturate(((_260 - _220.y) * cb13_033z) / _259));
          }
        } else {
          _296 = 1.0f;
          _297 = 1.0f;
        }
      } else {
        _296 = 0.0f;
        _297 = 1.0f;
      }
    }
    _302 = saturate(1.0f - (_297 * _296));
  } else {
    _302 = 0.0f;
  }
  float _307 = ((_207.w - _198.w) * _96) + _198.w;
  float _311 = (((_302 * _307) - _307) * cb4_009x) + _307;
  float _315 = TEXCOORD_1.y + -0.5f;
  float _316 = _315 * _315;
  float _318 = TEXCOORD_1.z + -0.5f;
  float _319 = _318 * _318;
  float _334 = (cb4_010x * ((_311 * GlobalShaderConsts_112.y) - _311)) + _311;
  float _372 = (FrequentPixelConsts_032.w * saturate(1.0f - TEXCOORD_2.w)) * saturate((cb4_013x * saturate(cb4_008x * (min(max((1.0f / ((((cb12_022x * _170.x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f) - TEXCOORD_1.w))) * (((TEXCOORD_4.w + -1.0f) + _334) + (((_334 * saturate(exp2(log2((1.0f - (_319 * _319)) * (1.0f - (_316 * _316))) * cb4_011x))) - _334) * cb4_012x)));
  float _374 = (_372 * FrequentPixelConsts_032.x) * ((cb4_007x * ((_155 * TEXCOORD_3.x) - _155)) + _155);
  float _376 = (_372 * FrequentPixelConsts_032.y) * ((cb4_007x * ((_157 * TEXCOORD_3.y) - _157)) + _157);
  float _378 = (_372 * FrequentPixelConsts_032.z) * ((cb4_007x * ((_159 * TEXCOORD_3.z) - _159)) + _159);
  float _380 = saturate(dot(float3(_374, _376, _378), float3(0.10000000149011612f, 0.10000000149011612f, 0.10000000149011612f)));
  SV_Target_1.x = _380;
  SV_Target_1.y = _380;
  SV_Target_1.z = _380;
  SV_Target_1.w = _380;
  SV_Target.x = _374;
  SV_Target.y = _376;
  SV_Target.z = _378;
  SV_Target.w = 0.0f;
  // Additive rain radiance only. Retain native alpha, depth fade and the
  // second render target used for coverage/reactivity.
  uint rain_tag = asuint(GlobalShaderConsts_224.w);
  float rain_brightness = (rain_tag & WITCHER_RAIN_TAG_MASK) == WITCHER_RAIN_TAG
      ? float(rain_tag & WITCHER_RAIN_FACTOR_MASK) / float(WITCHER_RAIN_FACTOR_SCALE) : 1.0f;
  SV_Target.rgb *= rain_brightness;
  OutputSignature output_signature = { SV_Target_1, SV_Target };
  return output_signature;
}
