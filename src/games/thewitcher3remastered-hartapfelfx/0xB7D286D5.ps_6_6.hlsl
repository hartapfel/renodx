#include "night/lighting/common.hlsli"
#define FOG_RECEIVER_FRAME
cbuffer HartapfelReceiverFrame : register(b12) { float4 receiver_frame[341]; }
#include "fog/receivers.hlsli"
#include "clouds/shadow_inputs.hlsli"
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

#define cb12_021x receiver_frame[21].x
#define cb12_021y receiver_frame[21].y
#define cb12_022x receiver_frame[22].x
#define cb12_022y receiver_frame[22].y
#define cb12_244x receiver_frame[244].x
#define cb12_244y receiver_frame[244].y
#define cb12_244z receiver_frame[244].z
#define cb12_277x receiver_frame[277].x
#define cb12_277y receiver_frame[277].y
#define cb12_277z receiver_frame[277].z
#define cb12_278x receiver_frame[278].x
#define cb12_278y receiver_frame[278].y
#define cb12_278z receiver_frame[278].z
#define cb12_padding asuint(receiver_frame[340].w)

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
  if (CloudVisibleMatches(receiver_frame[0].xyz, receiver_frame[17], receiver_frame[18], receiver_frame[23], asuint(receiver_frame[286]), GlobalShaderConsts_000.x)) discard;
  float4 SV_Target = 0;
  const float night_cloud = WitcherNightCloudMultiplier(receiver_frame[185].w);
  if(ReceiverFrameMatches()) TEXCOORD_1 = ReceiverFogVarying(SV_Position,length(TEXCOORD_3.xyz-receiver_frame[0].xyz), TEXCOORD_1);
  float _33 = -0.0f - GlobalShaderConsts_144.x;
  float _34 = dot(float3(GlobalShaderConsts_144.y, _33, 0.0f), float3(GlobalShaderConsts_144.y, _33, 0.0f));
  float _35 = rsqrt(_34);
  float _36 = _35 * GlobalShaderConsts_144.y;
  float _37 = _35 * _33;
  float _42 = cb1_036x - TEXCOORD_3.x;
  float _43 = cb1_036y - TEXCOORD_3.y;
  float _44 = cb1_036z - TEXCOORD_3.z;
  float _45 = dot(float3(_42, _43, _44), float3(_42, _43, _44));
  float _46 = rsqrt(_45);
  float _47 = _42 * _46;
  float _48 = _43 * _46;
  float _49 = _44 * _46;
  float _50 = dot(float3(_36, _37, 0.0f), float3(_47, _48, _49));
  float _51 = saturate(_50);
  float _52 = log2(_51);
  float _53 = _52 * 0.5f;
  float _54 = exp2(_53);
  float _55 = saturate(_54);
  float _56 = -0.0f - GlobalShaderConsts_144.y;
  float _57 = dot(float3(_33, _56, 0.0f), float3(_33, _56, 0.0f));
  float _58 = rsqrt(_57);
  float _59 = _58 * _33;
  float _60 = _58 * _56;
  float _61 = dot(float3(_59, _60, 0.0f), float3(_47, _48, _49));
  float _62 = saturate(_61);
  float _63 = log2(_62);
  float _64 = _63 * 5.0f;
  float _65 = exp2(_64);
  float _66 = saturate(_65);
  float _67 = dot(float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, 0.0f), float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, 0.0f));
  float _68 = rsqrt(_67);
  float _69 = _68 * GlobalShaderConsts_144.x;
  float _70 = _68 * GlobalShaderConsts_144.y;
  float _71 = dot(float3(_69, _70, 0.0f), float3(_47, _48, _49));
  float _72 = saturate(_71);
  float _89 = cb4_004x - cb4_003x;
  float _90 = cb4_004y - cb4_003y;
  float _91 = cb4_004z - cb4_003z;
  float _92 = _89 * _55;
  float _93 = _90 * _55;
  float _94 = _91 * _55;
  float _95 = _92 + cb4_003x;
  float _96 = _93 + cb4_003y;
  float _97 = _94 + cb4_003z;
  float _98 = cb4_005x - _95;
  float _99 = cb4_005y - _96;
  float _100 = cb4_005z - _97;
  float _101 = _98 * _66;
  float _102 = _99 * _66;
  float _103 = _100 * _66;
  float _104 = _101 + _95;
  float _105 = _102 + _96;
  float _106 = _103 + _97;
  float _107 = cb4_006x - _104;
  float _108 = cb4_006y - _105;
  float _109 = cb4_006z - _106;
  float _110 = _107 * _72;
  float _111 = _108 * _72;
  float _112 = _109 * _72;
  float _113 = _110 + _104;
  float _114 = _111 + _105;
  float _115 = _112 + _106;
  float _116 = dot(float3(_113, _114, _115), float3(_113, _114, _115));
  float _117 = rsqrt(_116);
  float _118 = _113 * _117;
  float _119 = _114 * _117;
  float _120 = _115 * _117;
  float _125 = 1.0f / cb4_007x;
  float _126 = 1.0f / cb4_008x;
  float _127 = floor(TEXCOORD.x);
  float _128 = _125 * TEXCOORD.x;
  float _129 = floor(_128);
  float _130 = _127 + TEXCOORD.y;
  float _131 = _130 * _125;
  float _132 = _129 + TEXCOORD.z;
  float _133 = _132 * _126;
  float4 _136 = t0.Sample(s0, float2(_131, _133));
  float _139 = _136.x * 2.0f;
  float _140 = _136.y * 2.0f;
  float _141 = _139 + -1.0f;
  float _142 = _140 + -1.0f;
  float _143 = _141 * _141;
  float _144 = 1.0f - _143;
  float _145 = _142 * _142;
  float _146 = _144 - _145;
  float _147 = max(0.0f, _146);
  float _148 = sqrt(_147);
  float _153 = cb4_009x * _141;
  float _154 = cb4_009y * _142;
  float _155 = cb4_009z * _148;
  float _156 = dot(float3(_153, _154, _155), float3(_153, _154, _155));
  float _157 = rsqrt(_156);
  float _158 = _153 * _157;
  float _159 = _154 * _157;
  float _160 = _155 * _157;
  float _161 = dot(float3(_118, _119, _120), float3(_158, _159, _160));
  float _164 = cb4_010x + _161;
  float _167 = _164 * cb4_011x;
  float _168 = saturate(_167);
  float _179 = cb12_244x - (cb12_277x * night_cloud);
  float _180 = cb12_244y - (cb12_277y * night_cloud);
  float _181 = cb12_244z - (cb12_277z * night_cloud);
  float _182 = _179 * _168;
  float _183 = _180 * _168;
  float _184 = _181 * _168;
  float _185 = _182 + (cb12_277x * night_cloud);
  float _186 = _183 + (cb12_277y * night_cloud);
  float _187 = _184 + (cb12_277z * night_cloud);
  float _188 = dot(float3(_185, _186, _187), float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f));
  float _189 = _188 - _185;
  float _190 = _188 - _186;
  float _191 = _188 - _187;
  float _192 = _189 * cb4_012x;
  float _193 = _190 * cb4_012x;
  float _194 = _191 * cb4_012x;
  float _195 = _192 + _185;
  float _196 = _193 + _186;
  float _197 = _194 + _187;
  float _202 = cb1_036x - TEXCOORD_3.x;
  float _203 = cb1_036y - TEXCOORD_3.y;
  float _204 = cb1_036z - TEXCOORD_3.z;
  float _205 = _202 * _202;
  float _206 = _203 * _203;
  float _207 = _205 + _206;
  float _208 = _204 * _204;
  float _209 = _207 + _208;
  float _210 = sqrt(_209);
  float _211 = _210 * 0.0006666666595265269f;
  float _212 = saturate(_211);
  float _217 = cb12_278x + -1.0f;
  float _218 = cb12_278y + -1.0f;
  float _219 = cb12_278z + -1.0f;
  float _220 = _217 * _212;
  float _221 = _218 * _212;
  float _222 = _219 * _212;
  float _223 = _220 + 1.0f;
  float _224 = _221 + 1.0f;
  float _225 = _222 + 1.0f;
  float _226 = _223 * _195;
  float _227 = _224 * _196;
  float _228 = _225 * _197;
  float _233 = 1.0f / cb4_007x;
  float _234 = 1.0f / cb4_008x;
  float _235 = _233 * TEXCOORD.x;
  float _236 = floor(_235);
  float _237 = _233 * _130;
  float _238 = _236 + TEXCOORD.z;
  float _239 = _238 * _234;
  float4 _242 = t1.Sample(s0, float2(_237, _239));
  float _246 = GlobalShaderConsts_144.z * 4.0f;
  float _247 = _246 + -1.0f;
  float _248 = saturate(_247);
  float _253 = cb4_014x - cb4_013x;
  float _254 = _253 * _248;
  float _255 = _254 + cb4_013x;
  float _256 = _255 * _168;
  float _261 = cb4_016x - cb4_015x;
  float _262 = _261 * _248;
  float _263 = _262 + cb4_015x;
  float _264 = _263 - _256;
  float _265 = _264 * _72;
  float _266 = _265 + _256;
  float _267 = _266 * _242.x;
  float _268 = max(_267, 0.0f);
  float _269 = min(_268, 100.0f);
  float _274 = 1.0f / cb4_007x;
  float _275 = 1.0f / cb4_008x;
  float _276 = _274 * TEXCOORD.x;
  float _277 = floor(_276);
  float _278 = _274 * _130;
  float _279 = _277 + TEXCOORD.z;
  float _280 = _279 * _275;
  float4 _283 = t1.Sample(s0, float2(_278, _280));
  float _289 = cb4_018x - cb4_017x;
  float _290 = _289 * _248;
  float _291 = _290 + cb4_017x;
  float _292 = log2(_283.y);
  float _293 = _291 * _292;
  float _294 = exp2(_293);
  float _299 = cb4_020x - cb4_019x;
  float _300 = _299 * _248;
  float _301 = _300 + cb4_019x;
  float _302 = _294 * _66;
  float _303 = _302 * _301;
  float _304 = _226 - _195;
  float _305 = _227 - _196;
  float _306 = _228 - _197;
  float _307 = _304 * _72;
  float _308 = _305 * _72;
  float _309 = _306 * _72;
  float _310 = _307 + _195;
  float _311 = _308 + _196;
  float _312 = _309 + _197;
  float _313 = _303 + _269;
  float _314 = _313 * _310;
  float _315 = _313 * _311;
  float _316 = _313 * _312;
  float _321 = log2(_314);
  float _322 = log2(_315);
  float _323 = log2(_316);
  float _324 = _321 * 2.200000047683716f;
  float _325 = _322 * 2.200000047683716f;
  float _326 = _323 * 2.200000047683716f;
  float _327 = exp2(_324);
  float _328 = exp2(_325);
  float _329 = exp2(_326);
  float _330 = _327 * cb4_002x;
  float _331 = _328 * cb4_002y;
  float _332 = _329 * cb4_002z;
  float _335 = _210 - cb4_000x;
  float _338 = cb4_001x - cb4_000x;
  float _339 = _335 / _338;
  float _340 = saturate(_339);
  float _345 = 1.0f / cb4_007x;
  float _346 = 1.0f / cb4_008x;
  float _347 = _345 * TEXCOORD.x;
  float _348 = floor(_347);
  float _349 = _345 * _130;
  float _350 = _348 + TEXCOORD.z;
  float _351 = _350 * _346;
  float4 _354 = t2.Sample(s0, float2(_349, _351));
  float4 _358 = t3.Sample(s0, float2(TEXCOORD.y, TEXCOORD.z));
  float _363 = GlobalShaderConsts_016.z * SV_Position.x;
  float _364 = GlobalShaderConsts_016.w * SV_Position.y;
  float4 _367 = t15.SampleLevel(s15, float2(_363, _364), 0.0f);
  float _371 = cb12_022x * _367.x;
  float _373 = _371 + cb12_022y;
  float _376 = _373 * cb12_021x;
  float _378 = _376 + cb12_021y;
  float _379 = 1.0f / _378;
  float _380 = max(_379, -3.4028234663852886e+38f);
  float _381 = min(_380, 3.4028234663852886e+38f);
  float _384 = _210 - cb4_026x;
  float _387 = cb4_027x - cb4_026x;
  float _388 = _384 / _387;
  float _389 = saturate(_388);
  float _392 = _210 - cb4_024x;
  float _395 = cb4_025x - cb4_024x;
  float _396 = _392 / _395;
  float _397 = saturate(_396);
  float _398 = _381 - TEXCOORD.w;
  float _401 = cb4_023x * _398;
  float _402 = saturate(_401);
  float _403 = _397 * _389;
  float _404 = _389 - _403;
  float _405 = _66 * 0.6000000238418579f;
  float _406 = 1.0f - _405;
  float _407 = _406 * TEXCOORD_2.w;
  float _408 = _407 * _404;
  float _409 = _408 * _402;
  float _410 = _409 + _358.x;
  float _411 = _410 * 3.0f;
  float _412 = _411 + -2.5f;
  float _413 = saturate(_412);
  float _414 = _413 * _354.x;
  float _415 = saturate(_414);
  float _420 = cb4_022x - cb4_021x;
  float _421 = _420 * _66;
  float _422 = _421 + cb4_021x;
  float _423 = _422 * _415;
  float _424 = saturate(_423);
  float _425 = saturate(_424);
  float _426 = TEXCOORD_1.x - _330;
  float _427 = TEXCOORD_1.y - _331;
  float _428 = TEXCOORD_1.z - _332;
  float _429 = _340 * TEXCOORD_1.w;
  float _430 = _429 * _426;
  float _431 = _429 * _427;
  float _432 = _429 * _428;
  float _433 = _430 + _330;
  float _434 = _431 + _331;
  float _435 = _432 + _332;
  float _436 = _424 * _433;
  float _437 = _424 * _434;
  float _438 = _424 * _435;
  SV_Target.x = _436;
  SV_Target.y = _437;
  SV_Target.z = _438;
  SV_Target.w = _425;
  return SV_Target;
}
