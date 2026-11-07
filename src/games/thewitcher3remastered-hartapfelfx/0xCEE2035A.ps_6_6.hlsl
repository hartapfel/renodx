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
  if(ReceiverFrameMatches()) TEXCOORD_2 = ReceiverFogVarying(SV_Position,length(TEXCOORD_5.xyz-receiver_frame[0].xyz));
  float _55 = cb4_003x * GlobalShaderConsts_000.x;
  float _56 = cb4_003y * GlobalShaderConsts_000.x;
  float _60 = cb4_004x * TEXCOORD_1.y;
  float _61 = cb4_004y * TEXCOORD_1.z;
  float _62 = _60 + _55;
  float _63 = _61 + _56;
  float4 _66 = t0.Sample(s0, float2(_62, _63));
  float _74 = cb4_005x * GlobalShaderConsts_000.x;
  float _75 = cb4_005y * GlobalShaderConsts_000.x;
  float _79 = cb4_006x * TEXCOORD_1.y;
  float _80 = cb4_006y * TEXCOORD_1.z;
  float _81 = _79 + _74;
  float _82 = _80 + _75;
  float4 _85 = t0.Sample(s0, float2(_81, _82));
  float _88 = _85.x * _66.x;
  float _89 = _85.y * _66.y;
  float _92 = _88 - cb4_007x;
  float _93 = _89 - cb4_007x;
  float _96 = _92 * cb4_008x;
  float _97 = _93 * cb4_008x;
  float _102 = _96 + TEXCOORD_1.y;
  float _103 = _97 + TEXCOORD_1.z;
  float _104 = 1.0f / cb4_009x;
  float _105 = 1.0f / cb4_010x;
  float _106 = floor(TEXCOORD_1.x);
  float _107 = _104 * TEXCOORD_1.x;
  float _108 = floor(_107);
  float _109 = _106 + _102;
  float _110 = _109 * _104;
  float _111 = _108 + _103;
  float _112 = _111 * _105;
  float4 _115 = t1.Sample(s0, float2(_110, _112));
  float _119 = TEXCOORD_1.x + 1.0f;
  float _120 = floor(_119);
  float _121 = _104 * _119;
  float _122 = floor(_121);
  float _123 = _120 + _102;
  float _124 = _123 * _104;
  float _125 = _122 + _103;
  float _126 = _125 * _105;
  float4 _129 = t1.Sample(s0, float2(_124, _126));
  const float night_cloud = WitcherNightCloudMultiplier(receiver_frame[185].w);
  float _135 = max(cb4_002x * night_cloud, TEXCOORD_3.x);
  float _136 = max(cb4_002x * night_cloud, TEXCOORD_3.y);
  float _137 = max(cb4_002x * night_cloud, TEXCOORD_3.z);
  float _138 = frac(TEXCOORD_1.x);
  float _139 = _129.x - _115.x;
  float _140 = _129.y - _115.y;
  float _141 = _129.z - _115.z;
  float _142 = _138 * _139;
  float _143 = _138 * _140;
  float _144 = _138 * _141;
  float _145 = _142 + _115.x;
  float _146 = _143 + _115.y;
  float _147 = _144 + _115.z;
  float _148 = _145 * _135;
  float _149 = _146 * _136;
  float _150 = _147 * _137;
  float _153 = dot(float3(_148, _149, _150), float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f));
  float _154 = _153 - _148;
  float _155 = _153 - _149;
  float _156 = _153 - _150;
  float _157 = _154 * cb4_011x;
  float _158 = _155 * cb4_011x;
  float _159 = _156 * cb4_011x;
  float _160 = _157 + _148;
  float _161 = _158 + _149;
  float _162 = _159 + _150;
  float _167 = 1.0f / cb4_009x;
  float _168 = 1.0f / cb4_010x;
  float _169 = _167 * TEXCOORD_1.x;
  float _170 = floor(_169);
  float _171 = _167 * _109;
  float _172 = _170 + _103;
  float _173 = _172 * _168;
  float4 _176 = t1.Sample(s0, float2(_171, _173));
  float _178 = _167 * _119;
  float _179 = floor(_178);
  float _180 = _167 * _123;
  float _181 = _179 + _103;
  float _182 = _181 * _168;
  float4 _185 = t1.Sample(s0, float2(_180, _182));
  float _189 = _185.w - _176.w;
  float _190 = _189 * _138;
  float _191 = _190 + _176.w;
  float _192 = log2(_191);
  float _193 = _192 * cb4_016x;
  float _194 = exp2(_193);
  float _199 = cb1_036x - TEXCOORD_5.x;
  float _200 = cb1_036y - TEXCOORD_5.y;
  float _201 = cb1_036z - TEXCOORD_5.z;
  float _202 = _199 * _199;
  float _203 = _200 * _200;
  float _204 = _202 + _203;
  float _205 = _201 * _201;
  float _206 = _204 + _205;
  float _207 = sqrt(_206);
  float _210 = _207 - cb4_014x;
  float _213 = cb4_015x - cb4_014x;
  float _214 = _210 / _213;
  float _215 = saturate(_214);
  float _218 = _207 - cb4_012x;
  float _221 = cb4_013x - cb4_012x;
  float _222 = _218 / _221;
  float _223 = saturate(_222);
  float _227 = GlobalShaderConsts_016.z * SV_Position.x;
  float _228 = GlobalShaderConsts_016.w * SV_Position.y;
  float4 _231 = t15.SampleLevel(s15, float2(_227, _228), 0.0f);
  float _235 = cb12_022x * _231.x;
  float _237 = _235 + cb12_022y;
  float _240 = _237 * cb12_021x;
  float _242 = _240 + cb12_021y;
  float _243 = 1.0f / _242;
  float _244 = max(_243, -3.4028234663852886e+38f);
  float _245 = min(_244, 3.4028234663852886e+38f);
  float _246 = _215 * _194;
  float _247 = _223 * _246;
  float _248 = _246 - _247;
  float _249 = _245 - TEXCOORD_1.w;
  float _252 = cb4_017x * _249;
  float _253 = saturate(_252);
  float _256 = _248 * TEXCOORD_4.w;
  float _257 = _256 * _253;
  float _258 = _257 * cb4_018x;
  bool _261 = (cb12_067w < 0.0f);
  float _341;
  float _342;
  float _347;
  if (!_261) {
    float4 _265 = t24.Sample(s8, float2(_227, _228));
    float _276 = TEXCOORD_5.x - cb12_000x;
    float _277 = TEXCOORD_5.y - cb12_000y;
    float _278 = TEXCOORD_5.z - cb12_000z;
    float _279 = _276 * _276;
    float _280 = _277 * _277;
    float _281 = _279 + _280;
    float _282 = _278 * _278;
    float _283 = _281 + _282;
    float _284 = sqrt(_283);
    float _293 = dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_276, _277, _278));
    float _296 = 1.0f / cb12_021y;
    float _297 = _296 * _284;
    float _298 = _297 / _293;
    float _300 = _284 - _298;
    float _301 = _300 * cb13_032w;
    float _302 = saturate(_301);
    float _303 = _302 * cb13_032z;
    float _304 = max(0.0010000000474974513f, _303);
    float _305 = _284 / cb13_033z;
    bool _306 = (_265.x < _265.y);
    if (_306) {
      bool _308 = (_305 < _265.x);
      bool _309 = (_305 > _265.y);
      bool _310 = _308 || _309;
      if (!_310) {
        float _312 = cb13_033z * _265.x;
        float _313 = _312 - cb13_033x;
        float _314 = _313 * cb13_033y;
        float _315 = 1.0f - _314;
        float _316 = saturate(_315);
        float _317 = _305 - _265.x;
        float _318 = _317 * cb13_033z;
        float _319 = _318 / _304;
        float _320 = saturate(_319);
        float _321 = _320 * _316;
        _341 = 1.0f;
        _342 = _321;
      } else {
        _341 = 0.0f;
        _342 = 1.0f;
      }
    } else {
      bool _323 = (_265.x > _265.y);
      if (_323) {
        bool _325 = (_305 < _265.y);
        if (!_325) {
          bool _327 = (_305 > _265.x);
          if (_327) {
            float _329 = cb13_033z * _265.x;
            float _330 = _329 - cb13_033x;
            float _331 = _330 * cb13_033y;
            float _332 = 1.0f - _331;
            float _333 = saturate(_332);
            _341 = 1.0f;
            _342 = _333;
          } else {
            float _335 = _305 - _265.y;
            float _336 = _335 * cb13_033z;
            float _337 = _336 / _304;
            float _338 = saturate(_337);
            float _339 = 1.0f - _338;
            _341 = 1.0f;
            _342 = _339;
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
    float _343 = _342 * _341;
    float _344 = 1.0f - _343;
    float _345 = saturate(_344);
    _347 = _345;
  } else {
    _347 = 0.0f;
  }
  float _350 = _347 * _258;
  float _351 = _350 - _258;
  float _352 = cb4_019x * _351;
  float _353 = _352 + _258;
  float _360 = cb4_021x - cb4_020x;
  float _361 = _360 * GlobalShaderConsts_112.y;
  float _362 = _361 + cb4_020x;
  float _367 = cb4_000x * TEXCOORD_4.x;
  float _368 = _367 * cb4_001x;
  float _369 = _368 * _160;
  float _370 = _369 * FrequentPixelConsts_032.x;
  float _371 = cb4_000y * TEXCOORD_4.y;
  float _372 = _371 * cb4_001x;
  float _373 = _372 * _161;
  float _374 = _373 * FrequentPixelConsts_032.y;
  float _375 = cb4_000z * TEXCOORD_4.z;
  float _376 = _375 * cb4_001x;
  float _377 = _376 * _162;
  float _378 = _377 * FrequentPixelConsts_032.z;
  float _380 = FrequentPixelConsts_032.w * _353;
  float _381 = _380 * _362;
  float _382 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_370, _374, _378));
  float _383 = _382 * TEXCOORD.x;
  float _384 = _382 * TEXCOORD.y;
  float _385 = _382 * TEXCOORD.z;
  float _386 = _383 - _370;
  float _387 = _384 - _374;
  float _388 = _385 - _378;
  float _389 = _386 * TEXCOORD.w;
  float _390 = _387 * TEXCOORD.w;
  float _391 = _388 * TEXCOORD.w;
  float _392 = _389 + _370;
  float _393 = _390 + _374;
  float _394 = _391 + _378;
  float _395 = TEXCOORD_2.x - _392;
  float _396 = TEXCOORD_2.y - _393;
  float _397 = TEXCOORD_2.z - _394;
  float _398 = _395 * TEXCOORD_2.w;
  float _399 = _396 * TEXCOORD_2.w;
  float _400 = _397 * TEXCOORD_2.w;
  float _401 = _398 + _392;
  float _402 = _399 + _393;
  float _403 = _400 + _394;
  float _404 = saturate(_381);
  SV_Target_1.x = _404;
  SV_Target_1.y = _404;
  SV_Target_1.z = _404;
  SV_Target_1.w = _404;
  float _405 = _401 * _381;
  float _406 = _402 * _381;
  float _407 = _403 * _381;
  SV_Target.x = _405;
  SV_Target.y = _406;
  SV_Target.z = _407;
  SV_Target.w = _404;
  OutputSignature output_signature = { SV_Target_1, SV_Target };
  return output_signature;
}
