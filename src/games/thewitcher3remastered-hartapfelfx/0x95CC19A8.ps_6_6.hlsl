#include "night/lighting/common.hlsli"
#define FOG_RECEIVER_FRAME
cbuffer HartapfelReceiverFrame : register(b12) { float4 receiver_frame[341]; }
#include "fog/receivers.hlsli"
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

#define cb12_000x receiver_frame[0].x
#define cb12_000y receiver_frame[0].y
#define cb12_000z receiver_frame[0].z
#define cb12_001z receiver_frame[1].z
#define cb12_002z receiver_frame[2].z
#define cb12_003z receiver_frame[3].z
#define cb12_021x receiver_frame[21].x
#define cb12_021y receiver_frame[21].y
#define cb12_022x receiver_frame[22].x
#define cb12_022y receiver_frame[22].y
#define cb12_067w receiver_frame[67].w
#define cb12_padding asuint(receiver_frame[340].w)

cbuffer cb4 : register(b4) {
  float cb4_000x : packoffset(c000.x);
  float cb4_001x : packoffset(c001.x);
  float cb4_002x : packoffset(c002.x);
  float cb4_003x : packoffset(c003.x);
  float cb4_004x : packoffset(c004.x);
  float cb4_005x : packoffset(c005.x);
  float cb4_006x : packoffset(c006.x);
  float cb4_006y : packoffset(c006.y);
  float cb4_007x : packoffset(c007.x);
  float cb4_007y : packoffset(c007.y);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
  float cb4_010x : packoffset(c010.x);
  float cb4_011x : packoffset(c011.x);
  float cb4_012x : packoffset(c012.x);
  float cb4_013x : packoffset(c013.x);
  float cb4_014x : packoffset(c014.x);
  float cb4_015x : packoffset(c015.x);
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
  linear float4 TEXCOORD_5 : TEXCOORD5,
  linear float4 TEXCOORD_6 : TEXCOORD6,
  linear float4 TEXCOORD_7 : TEXCOORD7,
  noperspective float4 SV_Position : SV_Position
) {
  float4 SV_Target_1 = 0;
  float4 SV_Target = 0;
  if(ReceiverFrameMatches()) TEXCOORD_2 = ReceiverFogVarying(SV_Position,length(TEXCOORD_7.xyz-receiver_frame[0].xyz));
  float _54 = abs(GlobalShaderConsts_144.x);
  float _55 = abs(GlobalShaderConsts_144.y);
  float _56 = abs(GlobalShaderConsts_144.z);
  float _57 = dot(float3(_54, _55, _56), float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f));
  float _58 = TEXCOORD_5.w - TEXCOORD_5.x;
  float _59 = TEXCOORD_6.w - TEXCOORD_5.y;
  float _60 = TEXCOORD_7.w - TEXCOORD_5.z;
  float _61 = dot(float3(GlobalShaderConsts_144.x, GlobalShaderConsts_144.y, GlobalShaderConsts_144.z), float3(_58, _59, _60));
  float _62 = _61 + _57;
  float _63 = saturate(_62);
  float _64 = -0.0f - GlobalShaderConsts_144.x;
  float _65 = -0.0f - GlobalShaderConsts_144.y;
  float _66 = -0.0f - GlobalShaderConsts_144.z;
  float _67 = dot(float3(_64, _65, _66), float3(_64, _65, _66));
  float _68 = rsqrt(_67);
  float _69 = _68 * _64;
  float _70 = _68 * _65;
  float _71 = _68 * _66;
  float _76 = cb1_036x - TEXCOORD_7.x;
  float _77 = cb1_036y - TEXCOORD_7.y;
  float _78 = cb1_036z - TEXCOORD_7.z;
  float _79 = dot(float3(_76, _77, _78), float3(_76, _77, _78));
  float _80 = rsqrt(_79);
  float _81 = _76 * _80;
  float _82 = _77 * _80;
  float _83 = _78 * _80;
  float _84 = dot(float3(_69, _70, _71), float3(_81, _82, _83));
  float _85 = saturate(_84);
  float _86 = log2(_85);
  float _87 = _86 * 3.0f;
  float _88 = exp2(_87);
  float _93 = 1.0f / cb4_003x;
  float _94 = 1.0f / cb4_004x;
  float _95 = floor(TEXCOORD_1.x);
  float _96 = _93 * TEXCOORD_1.x;
  float _97 = floor(_96);
  float _98 = _95 + TEXCOORD_1.y;
  float _99 = _98 * _93;
  float _100 = _97 + TEXCOORD_1.z;
  float _101 = _100 * _94;
  float4 _104 = t0.Sample(s0, float2(_99, _101));
  float _108 = TEXCOORD_1.x + 1.0f;
  float _109 = floor(_108);
  float _110 = _93 * _108;
  float _111 = floor(_110);
  float _112 = _109 + TEXCOORD_1.y;
  float _113 = _112 * _93;
  float _114 = _111 + TEXCOORD_1.z;
  float _115 = _114 * _94;
  float4 _118 = t0.Sample(s0, float2(_113, _115));
  float _126 = 1.0f / cb4_003x;
  float _127 = 1.0f / cb4_004x;
  float _128 = _126 * TEXCOORD_1.x;
  float _129 = floor(_128);
  float _130 = _126 * _98;
  float _131 = _129 + TEXCOORD_1.z;
  float _132 = _131 * _127;
  float4 _135 = t0.Sample(s0, float2(_130, _132));
  float _137 = _126 * _108;
  float _138 = floor(_137);
  float _139 = _126 * _112;
  float _140 = _138 + TEXCOORD_1.z;
  float _141 = _140 * _127;
  float4 _144 = t0.Sample(s0, float2(_139, _141));
  float _148 = frac(TEXCOORD_1.x);
  float _149 = _144.x - _135.x;
  float _150 = _148 * _149;
  float _151 = _150 + _135.x;
  float _152 = _118.x - _104.x;
  float _153 = _118.y - _104.y;
  float _154 = _118.z - _104.z;
  float _155 = _148 * _152;
  float _156 = _148 * _153;
  float _157 = _148 * _154;
  float _158 = _155 + _104.x;
  float _159 = _156 + _104.y;
  float _160 = _157 + _104.z;
  float _161 = _151 - _158;
  float _162 = _151 - _159;
  float _163 = _151 - _160;
  float _164 = _161 * cb4_005x;
  float _165 = _162 * cb4_005x;
  float _166 = _163 * cb4_005x;
  float _167 = _164 + _158;
  float _168 = _165 + _159;
  float _169 = _166 + _160;
  float _173 = cb4_006x * TEXCOORD_1.y;
  float _174 = cb4_006y * TEXCOORD_1.z;
  float _180 = GlobalShaderConsts_000.x * cb4_007x;
  float _181 = GlobalShaderConsts_000.x * cb4_007y;
  float _182 = _180 + _173;
  float _183 = _181 + _174;
  float4 _186 = t1.Sample(s0, float2(_182, _183));
  float _190 = log2(_186.x);
  float _191 = log2(_186.y);
  float _192 = log2(_186.z);
  float _193 = _190 * 2.200000047683716f;
  float _194 = _191 * 2.200000047683716f;
  float _195 = _192 * 2.200000047683716f;
  float _196 = exp2(_193);
  float _197 = exp2(_194);
  float _198 = exp2(_195);
  float _199 = log2(_167);
  float _200 = log2(_168);
  float _201 = log2(_169);
  float _202 = _199 * 2.200000047683716f;
  float _203 = _200 * 2.200000047683716f;
  float _204 = _201 * 2.200000047683716f;
  float _205 = exp2(_202);
  float _206 = exp2(_203);
  float _207 = exp2(_204);
  float _208 = _205 * _196;
  float _209 = _206 * _197;
  float _210 = _207 * _198;
  float _213 = 1.0f - _63;
  float _214 = _213 + _88;
  float _217 = _214 - cb4_002x;
  float _218 = _217 * GlobalShaderConsts_144.w;
  float _219 = _218 + cb4_002x;
  float _224 = cb4_001x - cb4_000x;
  float _225 = _219 * _224;
  float _226 = _225 + cb4_000x;
  float _229 = _208 - _205;
  float _230 = _209 - _206;
  float _231 = _210 - _207;
  float _232 = cb4_008x * _229;
  float _233 = cb4_008x * _230;
  float _234 = cb4_008x * _231;
  float _235 = _232 + _205;
  float _236 = _233 + _206;
  float _237 = _234 + _207;
  float _238 = _235 * _226;
  float _239 = _236 * _226;
  float _240 = _237 * _226;
  float _243 = TEXCOORD_3.x + -1.0f;
  float _244 = TEXCOORD_3.y + -1.0f;
  float _245 = TEXCOORD_3.z + -1.0f;
  float _246 = cb4_009x * _243;
  float _247 = cb4_009x * _244;
  float _248 = cb4_009x * _245;
  float _249 = _246 + 1.0f;
  float _250 = _247 + 1.0f;
  float _251 = _248 + 1.0f;
  float _252 = _238 * _249;
  float _253 = _239 * _250;
  float _254 = _240 * _251;
  float _257 = dot(float3(_252, _253, _254), float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f));
  float _258 = _257 - _252;
  float _259 = _257 - _253;
  float _260 = _257 - _254;
  float _261 = _258 * cb4_010x;
  float _262 = _259 * cb4_010x;
  float _263 = _260 * cb4_010x;
  float _264 = _261 + _252;
  float _265 = _262 + _253;
  float _266 = _263 + _254;
  float _267 = _264 * TEXCOORD_4.x;
  float _268 = _265 * TEXCOORD_4.y;
  float _269 = _266 * TEXCOORD_4.z;
  float _274 = 1.0f / cb4_003x;
  float _275 = 1.0f / cb4_004x;
  float _276 = _274 * TEXCOORD_1.x;
  float _277 = floor(_276);
  float _278 = _274 * _98;
  float _279 = _277 + TEXCOORD_1.z;
  float _280 = _279 * _275;
  float4 _283 = t0.Sample(s0, float2(_278, _280));
  float _285 = _274 * _108;
  float _286 = floor(_285);
  float _287 = _274 * _112;
  float _288 = _286 + TEXCOORD_1.z;
  float _289 = _288 * _275;
  float4 _292 = t0.Sample(s0, float2(_287, _289));
  float _297 = GlobalShaderConsts_016.z * SV_Position.x;
  float _298 = GlobalShaderConsts_016.w * SV_Position.y;
  bool _301 = (cb12_067w < 0.0f);
  float _381;
  float _382;
  float _387;
  if (!_301) {
    float4 _305 = t24.Sample(s8, float2(_297, _298));
    float _316 = TEXCOORD_7.x - cb12_000x;
    float _317 = TEXCOORD_7.y - cb12_000y;
    float _318 = TEXCOORD_7.z - cb12_000z;
    float _319 = _316 * _316;
    float _320 = _317 * _317;
    float _321 = _319 + _320;
    float _322 = _318 * _318;
    float _323 = _321 + _322;
    float _324 = sqrt(_323);
    float _333 = dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_316, _317, _318));
    float _336 = 1.0f / cb12_021y;
    float _337 = _336 * _324;
    float _338 = _337 / _333;
    float _340 = _324 - _338;
    float _341 = _340 * cb13_032w;
    float _342 = saturate(_341);
    float _343 = _342 * cb13_032z;
    float _344 = max(0.0010000000474974513f, _343);
    float _345 = _324 / cb13_033z;
    bool _346 = (_305.x < _305.y);
    if (_346) {
      bool _348 = (_345 < _305.x);
      bool _349 = (_345 > _305.y);
      bool _350 = _348 || _349;
      if (!_350) {
        float _352 = cb13_033z * _305.x;
        float _353 = _352 - cb13_033x;
        float _354 = _353 * cb13_033y;
        float _355 = 1.0f - _354;
        float _356 = saturate(_355);
        float _357 = _345 - _305.x;
        float _358 = _357 * cb13_033z;
        float _359 = _358 / _344;
        float _360 = saturate(_359);
        float _361 = _360 * _356;
        _381 = 1.0f;
        _382 = _361;
      } else {
        _381 = 0.0f;
        _382 = 1.0f;
      }
    } else {
      bool _363 = (_305.x > _305.y);
      if (_363) {
        bool _365 = (_345 < _305.y);
        if (!_365) {
          bool _367 = (_345 > _305.x);
          if (_367) {
            float _369 = cb13_033z * _305.x;
            float _370 = _369 - cb13_033x;
            float _371 = _370 * cb13_033y;
            float _372 = 1.0f - _371;
            float _373 = saturate(_372);
            _381 = 1.0f;
            _382 = _373;
          } else {
            float _375 = _345 - _305.y;
            float _376 = _375 * cb13_033z;
            float _377 = _376 / _344;
            float _378 = saturate(_377);
            float _379 = 1.0f - _378;
            _381 = 1.0f;
            _382 = _379;
          }
        } else {
          _381 = 1.0f;
          _382 = 1.0f;
        }
      } else {
        _381 = 0.0f;
        _382 = 1.0f;
      }
    }
    float _383 = _382 * _381;
    float _384 = 1.0f - _383;
    float _385 = saturate(_384);
    _387 = _385;
  } else {
    _387 = 0.0f;
  }
  float _390 = _292.w - _283.w;
  float _391 = _390 * _148;
  float _392 = _391 + _283.w;
  float _393 = _387 * _392;
  float _394 = _393 - _392;
  float _395 = _394 * cb4_013x;
  float _396 = _395 + _392;
  float _397 = _396 * TEXCOORD_4.w;
  float _401 = GlobalShaderConsts_016.z * SV_Position.x;
  float _402 = GlobalShaderConsts_016.w * SV_Position.y;
  float4 _405 = t15.SampleLevel(s15, float2(_401, _402), 0.0f);
  float _409 = cb12_022x * _405.x;
  float _411 = _409 + cb12_022y;
  float _414 = _411 * cb12_021x;
  float _416 = _414 + cb12_021y;
  float _417 = 1.0f / _416;
  float _418 = max(_417, -3.4028234663852886e+38f);
  float _419 = min(_418, 3.4028234663852886e+38f);
  float _420 = _419 - TEXCOORD_1.w;
  float _423 = cb4_014x * _420;
  float _424 = saturate(_423);
  float _425 = _397 * _424;
  float _430 = cb1_036x - TEXCOORD_7.x;
  float _431 = cb1_036y - TEXCOORD_7.y;
  float _432 = cb1_036z - TEXCOORD_7.z;
  float _433 = _430 * _430;
  float _434 = _431 * _431;
  float _435 = _433 + _434;
  float _436 = _432 * _432;
  float _437 = _435 + _436;
  float _438 = sqrt(_437);
  float _441 = _438 - cb4_011x;
  float _444 = cb4_012x - cb4_011x;
  float _445 = _441 / _444;
  float _446 = saturate(_445);
  float _447 = _425 * _446;
  float _450 = _447 * cb4_015x;
  float _451 = saturate(_450);
  float _456 = _267 * FrequentPixelConsts_032.x;
  float _457 = _268 * FrequentPixelConsts_032.y;
  float _458 = _269 * FrequentPixelConsts_032.z;
  float _460 = FrequentPixelConsts_032.w * _451;
  float _461 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_456, _457, _458));
  float _462 = _461 * TEXCOORD.x;
  float _463 = _461 * TEXCOORD.y;
  float _464 = _461 * TEXCOORD.z;
  float _465 = _462 - _456;
  float _466 = _463 - _457;
  float _467 = _464 - _458;
  float _468 = _465 * TEXCOORD.w;
  float _469 = _466 * TEXCOORD.w;
  float _470 = _467 * TEXCOORD.w;
  const float night_cloud = WitcherNightCloudMultiplier(receiver_frame[185].w);
  float _471 = (_468 + _456) * night_cloud;
  float _472 = (_469 + _457) * night_cloud;
  float _473 = (_470 + _458) * night_cloud;
  float _474 = TEXCOORD_2.x - _471;
  float _475 = TEXCOORD_2.y - _472;
  float _476 = TEXCOORD_2.z - _473;
  float _477 = _474 * TEXCOORD_2.w;
  float _478 = _475 * TEXCOORD_2.w;
  float _479 = _476 * TEXCOORD_2.w;
  float _480 = _477 + _471;
  float _481 = _478 + _472;
  float _482 = _479 + _473;
  float _483 = saturate(_460);
  SV_Target_1.x = _483;
  SV_Target_1.y = _483;
  SV_Target_1.z = _483;
  SV_Target_1.w = _483;
  float _484 = _480 * _460;
  float _485 = _481 * _460;
  float _486 = _482 * _460;
  SV_Target.x = _484;
  SV_Target.y = _485;
  SV_Target.z = _486;
  SV_Target.w = _483;
  OutputSignature output_signature = { SV_Target_1, SV_Target };
  return output_signature;
}
