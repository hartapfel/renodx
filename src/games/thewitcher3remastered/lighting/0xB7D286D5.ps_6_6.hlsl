#include "./common.hlsli"

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

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t3 : register(t3);

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

cbuffer cb12 : register(b12) {
  float cb12_021x : packoffset(c021.x);
  float cb12_021y : packoffset(c021.y);
  float cb12_022x : packoffset(c022.x);
  float cb12_022y : packoffset(c022.y);
  float cb12_244x : packoffset(c244.x);
  float cb12_244y : packoffset(c244.y);
  float cb12_244z : packoffset(c244.z);
  float cb12_277x : packoffset(c277.x);
  float cb12_277y : packoffset(c277.y);
  float cb12_277z : packoffset(c277.z);
  float cb12_278x : packoffset(c278.x);
  float cb12_278y : packoffset(c278.y);
  float cb12_278z : packoffset(c278.z);
  uint cb12_padding : packoffset(c340.w);
};

cbuffer cb4 : register(b4) {
  float cb4_000x : packoffset(c000.x);
  float cb4_001x : packoffset(c001.x);
  float cb4_002x : packoffset(c002.x);
  float cb4_002y : packoffset(c002.y);
  float cb4_002z : packoffset(c002.z);
  float cb4_003x : packoffset(c003.x);
  float cb4_003y : packoffset(c003.y);
  float cb4_003z : packoffset(c003.z);
  float cb4_004x : packoffset(c004.x);
  float cb4_004y : packoffset(c004.y);
  float cb4_004z : packoffset(c004.z);
  float cb4_005x : packoffset(c005.x);
  float cb4_005y : packoffset(c005.y);
  float cb4_005z : packoffset(c005.z);
  float cb4_006x : packoffset(c006.x);
  float cb4_006y : packoffset(c006.y);
  float cb4_006z : packoffset(c006.z);
  float cb4_007x : packoffset(c007.x);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
  float cb4_009y : packoffset(c009.y);
  float cb4_009z : packoffset(c009.z);
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
  float cb4_022x : packoffset(c022.x);
  float cb4_023x : packoffset(c023.x);
  float cb4_024x : packoffset(c024.x);
  float cb4_025x : packoffset(c025.x);
  float cb4_026x : packoffset(c026.x);
  float cb4_027x : packoffset(c027.x);
};

SamplerState s15 : register(s15);

SamplerState s0 : register(s0);

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2,
  linear float3 TEXCOORD_3 : TEXCOORD3,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  float _33 = -0.0f - GlobalShaderConsts_144.x;
  float _35 = rsqrt(dot(float3(GlobalShaderConsts_144.y, _33, 0.0f), float3(GlobalShaderConsts_144.y, _33, 0.0f)));
  float _42 = cb1_036x - TEXCOORD_3.x;
  float _43 = cb1_036y - TEXCOORD_3.y;
  float _44 = cb1_036z - TEXCOORD_3.z;
  float _46 = rsqrt(dot(float3(_42, _43, _44), float3(_42, _43, _44)));
  float _47 = _42 * _46;
  float _48 = _43 * _46;
  float _49 = _44 * _46;
  float _55 = saturate(exp2(log2(saturate(dot(float3((_35 * GlobalShaderConsts_144.y), (_35 * _33), 0.0f), float3(_47, _48, _49)))) * 0.5f));
  float _56 = -0.0f - GlobalShaderConsts_144.y;
  float _58 = rsqrt(dot(float3(_33, _56, 0.0f), float3(_33, _56, 0.0f)));
  float _66 = saturate(exp2(log2(saturate(dot(float3((_58 * _33), (_58 * _56), 0.0f), float3(_47, _48, _49)))) * 5.0f));
  float _68 = rsqrt(dot(float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, 0.0f), float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, 0.0f)));
  float _72 = saturate(dot(float3((_68 * GlobalShaderConsts_144.x), (_68 * GlobalShaderConsts_144.y), 0.0f), float3(_47, _48, _49)));
  float _95 = ((cb4_004x - cb4_003x) * _55) + cb4_003x;
  float _96 = ((cb4_004y - cb4_003y) * _55) + cb4_003y;
  float _97 = ((cb4_004z - cb4_003z) * _55) + cb4_003z;
  float _104 = ((cb4_005x - _95) * _66) + _95;
  float _105 = ((cb4_005y - _96) * _66) + _96;
  float _106 = ((cb4_005z - _97) * _66) + _97;
  float _113 = ((cb4_006x - _104) * _72) + _104;
  float _114 = ((cb4_006y - _105) * _72) + _105;
  float _115 = ((cb4_006z - _106) * _72) + _106;
  float _117 = rsqrt(dot(float3(_113, _114, _115), float3(_113, _114, _115)));
  float _125 = 1.0f / cb4_007x;
  float _130 = floor(TEXCOORD.x) + TEXCOORD.y;
  float4 _136 = t0.Sample(s0, float2((_130 * _125), ((floor(_125 * TEXCOORD.x) + TEXCOORD.z) * (1.0f / cb4_008x))));
  float _141 = (_136.x * 2.0f) + -1.0f;
  float _142 = (_136.y * 2.0f) + -1.0f;
  float _153 = cb4_009x * _141;
  float _154 = cb4_009y * _142;
  float _155 = cb4_009z * sqrt(max(0.0f, ((1.0f - (_141 * _141)) - (_142 * _142))));
  float _157 = rsqrt(dot(float3(_153, _154, _155), float3(_153, _154, _155)));
  float _168 = saturate((cb4_010x + dot(float3((_113 * _117), (_114 * _117), (_115 * _117)), float3((_153 * _157), (_154 * _157), (_155 * _157)))) * cb4_011x);
  // c277 also colors the moon; darken its cloud use only.
  float night_cloud = WitcherNightCloudMultiplier();
  float _185 = ((cb12_244x - (cb12_277x * night_cloud)) * _168) + (cb12_277x * night_cloud);
  float _186 = ((cb12_244y - (cb12_277y * night_cloud)) * _168) + (cb12_277y * night_cloud);
  float _187 = ((cb12_244z - (cb12_277z * night_cloud)) * _168) + (cb12_277z * night_cloud);
  float _188 = dot(float3(_185, _186, _187), float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f));
  float _195 = ((_188 - _185) * cb4_012x) + _185;
  float _196 = ((_188 - _186) * cb4_012x) + _186;
  float _197 = ((_188 - _187) * cb4_012x) + _187;
  float _202 = cb1_036x - TEXCOORD_3.x;
  float _203 = cb1_036y - TEXCOORD_3.y;
  float _204 = cb1_036z - TEXCOORD_3.z;
  float _210 = sqrt(((_202 * _202) + (_203 * _203)) + (_204 * _204));
  float _212 = saturate(_210 * 0.0006666666595265269f);
  float _233 = 1.0f / cb4_007x;
  float4 _242 = t1.Sample(s0, float2((_233 * _130), ((floor(_233 * TEXCOORD.x) + TEXCOORD.z) * (1.0f / cb4_008x))));
  float _248 = saturate((GlobalShaderConsts_144.z * 4.0f) + -1.0f);
  float _256 = (lerp(cb4_013x, cb4_014x, _248)) * _168;
  float _274 = 1.0f / cb4_007x;
  float4 _283 = t1.Sample(s0, float2((_274 * _130), ((floor(_274 * TEXCOORD.x) + TEXCOORD.z) * (1.0f / cb4_008x))));
  float _313 = ((exp2((lerp(cb4_017x, cb4_018x, _248)) * log2(_283.y)) * _66) * (lerp(cb4_019x, cb4_020x, _248))) + min(max((((((lerp(cb4_015x, cb4_016x, _248)) - _256) * _72) + _256) * _242.x), 0.0f), 100.0f);
  float _330 = exp2(log2(_313 * (((((((cb12_278x + -1.0f) * _212) + 1.0f) * _195) - _195) * _72) + _195)) * 2.200000047683716f) * cb4_002x;
  float _331 = exp2(log2(_313 * (((((((cb12_278y + -1.0f) * _212) + 1.0f) * _196) - _196) * _72) + _196)) * 2.200000047683716f) * cb4_002y;
  float _332 = exp2(log2(_313 * (((((((cb12_278z + -1.0f) * _212) + 1.0f) * _197) - _197) * _72) + _197)) * 2.200000047683716f) * cb4_002z;
  float _345 = 1.0f / cb4_007x;
  float4 _354 = t2.Sample(s0, float2((_345 * _130), ((floor(_345 * TEXCOORD.x) + TEXCOORD.z) * (1.0f / cb4_008x))));
  float4 _358 = t3.Sample(s0, float2(TEXCOORD.y, TEXCOORD.z));
  float4 _367 = t15.SampleLevel(s15, float2((GlobalShaderConsts_016.z * SV_Position.x), (GlobalShaderConsts_016.w * SV_Position.y)), 0.0f);
  float _389 = saturate((_210 - cb4_026x) / (cb4_027x - cb4_026x));
  float _424 = saturate((lerp(cb4_021x, cb4_022x, _66)) * saturate(saturate(((((((1.0f - (_66 * 0.6000000238418579f)) * TEXCOORD_2.w) * (_389 - (saturate((_210 - cb4_024x) / (cb4_025x - cb4_024x)) * _389))) * saturate(cb4_023x * (min(max((1.0f / ((((cb12_022x * _367.x) + cb12_022y) * cb12_021x) + cb12_021y)), -3.4028234663852886e+38f), 3.4028234663852886e+38f) - TEXCOORD.w))) + _358.x) * 3.0f) + -2.5f) * _354.x));
  float _429 = saturate((_210 - cb4_000x) / (cb4_001x - cb4_000x)) * TEXCOORD_1.w;
  SV_Target.x = (_424 * ((_429 * (TEXCOORD_1.x - _330)) + _330));
  SV_Target.y = (_424 * ((_429 * (TEXCOORD_1.y - _331)) + _331));
  SV_Target.z = (_424 * ((_429 * (TEXCOORD_1.z - _332)) + _332));
  SV_Target.w = saturate(_424);
  return SV_Target;
}
