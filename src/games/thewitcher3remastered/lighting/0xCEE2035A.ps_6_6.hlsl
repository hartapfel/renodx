#include "./common.hlsli"

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

Texture2D<float4> t1 : register(t1);

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
  float cb4_000z : packoffset(c000.z);
  float cb4_001x : packoffset(c001.x);
  float cb4_002x : packoffset(c002.x);
  float cb4_003x : packoffset(c003.x);
  float cb4_003y : packoffset(c003.y);
  float cb4_004x : packoffset(c004.x);
  float cb4_004y : packoffset(c004.y);
  float cb4_005x : packoffset(c005.x);
  float cb4_005y : packoffset(c005.y);
  float cb4_006x : packoffset(c006.x);
  float cb4_006y : packoffset(c006.y);
  float cb4_007x : packoffset(c007.x);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
  float cb4_010x : packoffset(c010.x);
  float cb4_011x : packoffset(c011.x);
  float cb4_012x : packoffset(c012.x);
  float cb4_013x : packoffset(c013.x);
  float cb4_014x : packoffset(c014.x);
  float cb4_015x : packoffset(c015.x);
  float cb4_016x : packoffset(c016.x);
  float cb4_017x : packoffset(c017.x);
  float cb4_018x : packoffset(c018.x);
  float cb4_019x : packoffset(c019.x);
  float cb4_020x : packoffset(c020.x);
  float cb4_021x : packoffset(c021.x);
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
  float4 _66 = t0.Sample(s0, float2(((cb4_004x * TEXCOORD_1.y) + (cb4_003x * GlobalShaderConsts_000.x)), ((cb4_004y * TEXCOORD_1.z) + (cb4_003y * GlobalShaderConsts_000.x))));
  float4 _85 = t0.Sample(s0, float2(((cb4_006x * TEXCOORD_1.y) + (cb4_005x * GlobalShaderConsts_000.x)), ((cb4_006y * TEXCOORD_1.z) + (cb4_005y * GlobalShaderConsts_000.x))));
  float _102 = (((_85.x * _66.x) - cb4_007x) * cb4_008x) + TEXCOORD_1.y;
  float _103 = (((_85.y * _66.y) - cb4_007x) * cb4_008x) + TEXCOORD_1.z;
  float _104 = 1.0f / cb4_009x;
  float _105 = 1.0f / cb4_010x;
  float _109 = floor(TEXCOORD_1.x) + _102;
  float4 _115 = t1.Sample(s0, float2((_109 * _104), ((floor(_104 * TEXCOORD_1.x) + _103) * _105)));
  float _119 = TEXCOORD_1.x + 1.0f;
  float _123 = floor(_119) + _102;
  float4 _129 = t1.Sample(s0, float2((_123 * _104), ((floor(_104 * _119) + _103) * _105)));
  float _138 = frac(TEXCOORD_1.x);
  // Lower the artificial lighting floor while retaining brighter native lighting.
  float night_cloud = WitcherNightCloudMultiplier();
  float _148 = ((_138 * (_129.x - _115.x)) + _115.x) * max(cb4_002x * night_cloud, TEXCOORD_3.x);
  float _149 = ((_138 * (_129.y - _115.y)) + _115.y) * max(cb4_002x * night_cloud, TEXCOORD_3.y);
  float _150 = ((_138 * (_129.z - _115.z)) + _115.z) * max(cb4_002x * night_cloud, TEXCOORD_3.z);
  float _153 = dot(float3(_148, _149, _150), float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f));
  float _167 = 1.0f / cb4_009x;
  float _168 = 1.0f / cb4_010x;
  float4 _176 = t1.Sample(s0, float2((_167 * _109), ((floor(_167 * TEXCOORD_1.x) + _103) * _168)));
  float4 _185 = t1.Sample(s0, float2((_167 * _123), ((floor(_167 * _119) + _103) * _168)));
  float _199 = cb1_036x - TEXCOORD_5.x;
  float _200 = cb1_036y - TEXCOORD_5.y;
  float _201 = cb1_036z - TEXCOORD_5.z;
  float _207 = sqrt(((_199 * _199) + (_200 * _200)) + (_201 * _201));
  float _227 = GlobalShaderConsts_016.z * SV_Position.x;
  float _228 = GlobalShaderConsts_016.w * SV_Position.y;
  float4 _231 = t15.SampleLevel(s15, float2(_227, _228), 0.0f);
  float _246 = saturate((_207 - cb4_014x) / (cb4_015x - cb4_014x)) * exp2(log2(lerp(_176.w, _185.w, _138)) * cb4_016x);
  float _258 = (((_246 - (saturate((_207 - cb4_012x) / (cb4_013x - cb4_012x)) * _246)) * TEXCOORD_4.w) * saturate(cb4_017x * (min(max((1.0f / ((((cb12_022x * _231.x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f) - TEXCOORD_1.w))) * cb4_018x;
  float _341;
  float _342;
  float _347;
  if (!(cb12_067w < 0.0f)) {
    float4 _265 = t24.Sample(s8, float2(_227, _228));
    float _276 = TEXCOORD_5.x - cb12_000x;
    float _277 = TEXCOORD_5.y - cb12_000y;
    float _278 = TEXCOORD_5.z - cb12_000z;
    float _284 = sqrt(((_276 * _276) + (_277 * _277)) + (_278 * _278));
    float _304 = max(0.0010000000474974513f, (saturate((_284 - (((1.0f / cb12_021y) * _284) / dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_276, _277, _278)))) * cb13_032w) * cb13_032z));
    float _305 = _284 / cb13_033z;
    if (_265.x < _265.y) {
      if (!((int)(_305 < _265.x) || (int)(_305 > _265.y))) {
        _341 = 1.0f;
        _342 = (saturate(((_305 - _265.x) * cb13_033z) / _304) * saturate(1.0f - (((cb13_033z * _265.x) - cb13_033x) * cb13_033y)));
      } else {
        _341 = 0.0f;
        _342 = 1.0f;
      }
    } else {
      if (_265.x > _265.y) {
        if (!(_305 < _265.y)) {
          if (_305 > _265.x) {
            _341 = 1.0f;
            _342 = saturate(1.0f - (((cb13_033z * _265.x) - cb13_033x) * cb13_033y));
          } else {
            _341 = 1.0f;
            _342 = (1.0f - saturate(((_305 - _265.y) * cb13_033z) / _304));
          }
        } else {
          _341 = 1.0f;
          _342 = 1.0f;
        }
      } else {
        _341 = 0.0f;
        _342 = 1.0f;
      }
    }
    _347 = saturate(1.0f - (_342 * _341));
  } else {
    _347 = 0.0f;
  }
  float _370 = (((cb4_000x * TEXCOORD_4.x) * cb4_001x) * (lerp(_148, _153, cb4_011x))) * FrequentPixelConsts_032.x;
  float _374 = (((cb4_000y * TEXCOORD_4.y) * cb4_001x) * (lerp(_149, _153, cb4_011x))) * FrequentPixelConsts_032.y;
  float _378 = (((cb4_000z * TEXCOORD_4.z) * cb4_001x) * (lerp(_150, _153, cb4_011x))) * FrequentPixelConsts_032.z;
  float _381 = (FrequentPixelConsts_032.w * ((cb4_019x * ((_347 * _258) - _258)) + _258)) * (lerp(cb4_020x, cb4_021x, GlobalShaderConsts_112.y));
  float _382 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_370, _374, _378));
  float _392 = (((_382 * TEXCOORD.x) - _370) * TEXCOORD.w) + _370;
  float _393 = (((_382 * TEXCOORD.y) - _374) * TEXCOORD.w) + _374;
  float _394 = (((_382 * TEXCOORD.z) - _378) * TEXCOORD.w) + _378;
  float _404 = saturate(_381);
  SV_Target_1.x = _404;
  SV_Target_1.y = _404;
  SV_Target_1.z = _404;
  SV_Target_1.w = _404;
  SV_Target.x = ((lerp(_392, TEXCOORD_2.x, TEXCOORD_2.w)) * _381);
  SV_Target.y = ((lerp(_393, TEXCOORD_2.y, TEXCOORD_2.w)) * _381);
  SV_Target.z = ((lerp(_394, TEXCOORD_2.z, TEXCOORD_2.w)) * _381);
  SV_Target.w = _404;
  OutputSignature output_signature = { SV_Target_1, SV_Target };
  return output_signature;
}
