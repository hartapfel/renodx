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
#define cb12_260x receiver_frame[260].x
#define cb12_260y receiver_frame[260].y
#define cb12_260z receiver_frame[260].z
#define cb12_padding asuint(receiver_frame[340].w)

cbuffer cb4 : register(b4) {
  float cb4_000x : packoffset(c000.x);
  float cb4_000y : packoffset(c000.y);
  float cb4_000z : packoffset(c000.z);
  float cb4_001x : packoffset(c001.x);
  float cb4_002x : packoffset(c002.x);
  float cb4_003x : packoffset(c003.x);
  float cb4_004x : packoffset(c004.x);
  float cb4_005x : packoffset(c005.x);
  float cb4_006x : packoffset(c006.x);
  float cb4_007x : packoffset(c007.x);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
  float cb4_010x : packoffset(c010.x);
  float cb4_010y : packoffset(c010.y);
  float cb4_011x : packoffset(c011.x);
  float cb4_012x : packoffset(c012.x);
  float cb4_013x : packoffset(c013.x);
  float cb4_013y : packoffset(c013.y);
  float cb4_014x : packoffset(c014.x);
  float cb4_015x : packoffset(c015.x);
  float cb4_016x : packoffset(c016.x);
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

static const float _global_0[16] = { 0.0f, 1.0f, 0.9743000268936157f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
static const float _global_1[16] = { 0.000299000006634742f, 0.11706800013780594f, 0.858892023563385f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };

float4 main(
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  linear float4 TEXCOORD_2 : TEXCOORD2,
  linear float3 TEXCOORD_3 : TEXCOORD3,
  linear float3 TEXCOORD_4 : TEXCOORD4,
  linear float3 TEXCOORD_5 : TEXCOORD5,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target = 0;
  if(ReceiverFrameMatches()) TEXCOORD_1 = ReceiverFogVarying(SV_Position,length(TEXCOORD_5.xyz-receiver_frame[0].xyz));
  float _60;
  float _59;
  float _58;
  float _57;
  float _56;
  float _55;
  float _162;
  float _109;
  float _108;
  float _48 = cb4_001x * cb4_000x;
  float _49 = cb4_001x * cb4_000y;
  float _50 = cb4_001x * cb4_000z;
  _55 = _48 * cb12_260x;
  _56 = _49 * cb12_260y;
  _57 = _50 * cb12_260z;
  _58 = _55 * TEXCOORD_2.x;
  _59 = _56 * TEXCOORD_2.y;
  _60 = _57 * TEXCOORD_2.z;
  float _66 = cb4_009x * TEXCOORD_3.x;
  float _67 = _66 * cb4_010x;
  float _68 = cb4_009x * TEXCOORD_3.y;
  float _69 = _68 * cb4_010y;
  float4 _72 = t0.Sample(s0, float2(_67, _69));
  float _77 = cb4_011x * _72.x;
  float _78 = cb4_011x * _72.y;
  float _86 = GlobalShaderConsts_000.x * cb4_012x;
  float _87 = _86 * cb4_013x;
  float _88 = _86 * cb4_013y;
  float _89 = _77 + _67;
  float _90 = _89 + _87;
  float _91 = _78 + _69;
  float _92 = _91 + _88;
  float4 _95 = t1.Sample(s0, float2(_90, _92));
  float _101 = cb4_008x - cb4_007x;
  float _102 = _101 * _95.x;
  float _103 = _102 + cb4_007x;
  float _104 = saturate(_103);
  _108 = GlobalShaderConsts_016.z * SV_Position.x;
  _109 = GlobalShaderConsts_016.w * SV_Position.y;
  float4 _112 = t15.SampleLevel(s15, float2(_108, _109), 0.0f);
  float _116 = cb12_022x * _112.x;
  float _118 = _116 + cb12_022y;
  float _121 = _118 * cb12_021x;
  float _123 = _121 + cb12_021y;
  float _124 = 1.0f / _123;
  float _125 = max(_124, -3.4028234663852886e+38f);
  float _126 = min(_125, 3.4028234663852886e+38f);
  float _127 = _126 - TEXCOORD_3.z;
  float _130 = cb4_014x * _127;
  float _131 = saturate(_130);
  float _132 = _131 * _104;
  float _139 = cb1_036x - TEXCOORD_5.x;
  float _140 = cb1_036y - TEXCOORD_5.y;
  float _141 = cb1_036z - TEXCOORD_5.z;
  float _142 = dot(float3(_139, _140, _141), float3(_139, _140, _141));
  float _143 = rsqrt(_142);
  float _144 = _139 * _143;
  float _145 = _140 * _143;
  float _146 = _141 * _143;
  float _147 = dot(float3(TEXCOORD_4.x, TEXCOORD_4.y, TEXCOORD_4.z), float3(_144, _145, _146));
  float _148 = 1.0f - _147;
  float _149 = saturate(_148);
  float _150 = log2(_149);
  float _151 = _150 * 0.5f;
  float _152 = exp2(_151);
  float _153 = 1.0f - _152;
  float _154 = log2(_153);
  float _155 = _154 * cb4_015x;
  float _156 = exp2(_155);
  float _157 = saturate(_156);
  float _158 = _132 * _157;
  float _161 = _158 * cb4_016x;
  _162 = saturate(_161);
  float _163 = saturate(TEXCOORD_3.x);
  bool _164 = !(_163 >= 0.000299000006634742f);
  bool _165 = !(_163 <= 1.0f);
  bool _166 = _164 || _165;
  bool _199;
  int _200;
  float _202;
  bool _239;
  int _240;
  float _242;
  float _325;
  float _326;
  float _331;
  if (!_166) {
    bool _168 = !(_163 <= 0.11706800013780594f);
    if (_168) {
      bool _170 = (_163 >= 0.11706800013780594f);
      bool _171 = (_163 <= 0.858892023563385f);
      bool _172 = _170 && _171;
      int _173 = (int)(uint)(_170);
      if (!_172) {
        bool _175 = (_163 >= 0.858892023563385f);
        int _176 = select(_175, 2, 0);
        _199 = _175;
        _200 = _176;
      } else {
        _199 = true;
        _200 = _173;
      }
    } else {
      _199 = true;
      _200 = 0;
    }
    if (_199) {
      while(true) {
        float _179 = _global_0[_200];
        int _180 = _200 + 1;
        float _182 = _global_0[_180];
        float _184 = _global_1[_200];
        float _185 = _163 - _184;
        float _187 = _global_1[_180];
        float _188 = _187 - _184;
        float _189 = _185 / _188;
        float _190 = saturate(_189);
        float _191 = _190 * 2.0f;
        float _192 = 3.0f - _191;
        float _193 = _182 - _179;
        float _194 = _190 * _190;
        float _195 = _194 * _193;
        float _196 = _195 * _192;
        float _197 = _196 + _179;
        _202 = _197;
        break;
      }
      float _203 = saturate(TEXCOORD_3.y);
      bool _204 = !(_203 >= 0.000299000006634742f);
      bool _205 = !(_203 <= 1.0f);
      bool _206 = _204 || _205;
      if (!_206) {
        bool _208 = !(_203 <= 0.11706800013780594f);
        if (_208) {
          bool _210 = (_203 >= 0.11706800013780594f);
          bool _211 = (_203 <= 0.858892023563385f);
          bool _212 = _210 && _211;
          int _213 = (int)(uint)(_210);
          if (!_212) {
            bool _215 = (_203 >= 0.858892023563385f);
            int _216 = select(_215, 2, 0);
            _239 = _215;
            _240 = _216;
          } else {
            _239 = true;
            _240 = _213;
          }
        } else {
          _239 = true;
          _240 = 0;
        }
        if (_239) {
          while(true) {
            float _219 = _global_0[_240];
            int _220 = _240 + 1;
            float _222 = _global_0[_220];
            float _224 = _global_1[_240];
            float _225 = _203 - _224;
            float _227 = _global_1[_220];
            float _228 = _227 - _224;
            float _229 = _225 / _228;
            float _230 = saturate(_229);
            float _231 = _230 * 2.0f;
            float _232 = 3.0f - _231;
            float _233 = _222 - _219;
            float _234 = _230 * _230;
            float _235 = _234 * _233;
            float _236 = _235 * _232;
            float _237 = _236 + _219;
            _242 = _237;
            break;
          }
          bool _245 = (cb12_067w < 0.0f);
          if (!_245) {
            float4 _249 = t24.Sample(s8, float2(_108, _109));
            float _260 = TEXCOORD_5.x - cb12_000x;
            float _261 = TEXCOORD_5.y - cb12_000y;
            float _262 = TEXCOORD_5.z - cb12_000z;
            float _263 = _260 * _260;
            float _264 = _261 * _261;
            float _265 = _263 + _264;
            float _266 = _262 * _262;
            float _267 = _265 + _266;
            float _268 = sqrt(_267);
            float _277 = dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_260, _261, _262));
            float _280 = 1.0f / cb12_021y;
            float _281 = _280 * _268;
            float _282 = _281 / _277;
            float _284 = _268 - _282;
            float _285 = _284 * cb13_032w;
            float _286 = saturate(_285);
            float _287 = _286 * cb13_032z;
            float _288 = max(0.0010000000474974513f, _287);
            float _289 = _268 / cb13_033z;
            bool _290 = (_249.x < _249.y);
            if (_290) {
              bool _292 = (_289 < _249.x);
              bool _293 = (_289 > _249.y);
              bool _294 = _292 || _293;
              if (!_294) {
                float _296 = cb13_033z * _249.x;
                float _297 = _296 - cb13_033x;
                float _298 = _297 * cb13_033y;
                float _299 = 1.0f - _298;
                float _300 = saturate(_299);
                float _301 = _289 - _249.x;
                float _302 = _301 * cb13_033z;
                float _303 = _302 / _288;
                float _304 = saturate(_303);
                float _305 = _304 * _300;
                _325 = 1.0f;
                _326 = _305;
              } else {
                _325 = 0.0f;
                _326 = 1.0f;
              }
            } else {
              bool _307 = (_249.x > _249.y);
              if (_307) {
                bool _309 = (_289 < _249.y);
                if (!_309) {
                  bool _311 = (_289 > _249.x);
                  if (_311) {
                    float _313 = cb13_033z * _249.x;
                    float _314 = _313 - cb13_033x;
                    float _315 = _314 * cb13_033y;
                    float _316 = 1.0f - _315;
                    float _317 = saturate(_316);
                    _325 = 1.0f;
                    _326 = _317;
                  } else {
                    float _319 = _289 - _249.y;
                    float _320 = _319 * cb13_033z;
                    float _321 = _320 / _288;
                    float _322 = saturate(_321);
                    float _323 = 1.0f - _322;
                    _325 = 1.0f;
                    _326 = _323;
                  }
                } else {
                  _325 = 1.0f;
                  _326 = 1.0f;
                }
              } else {
                _325 = 0.0f;
                _326 = 1.0f;
              }
            }
            float _327 = _326 * _325;
            float _328 = 1.0f - _327;
            float _329 = saturate(_328);
            _331 = _329;
          } else {
            _331 = 0.0f;
          }
          float _336 = cb1_036x - TEXCOORD_5.x;
          float _337 = cb1_036y - TEXCOORD_5.y;
          float _338 = cb1_036z - TEXCOORD_5.z;
          float _339 = _336 * _336;
          float _340 = _337 * _337;
          float _341 = _339 + _340;
          float _342 = _338 * _338;
          float _343 = _341 + _342;
          float _344 = sqrt(_343);
          float _347 = _344 - cb4_005x;
          float _350 = cb4_006x - cb4_005x;
          float _351 = _347 / _350;
          float _352 = saturate(_351);
          float _355 = _344 - cb4_003x;
          float _358 = cb4_004x - cb4_003x;
          float _359 = _355 / _358;
          float _360 = saturate(_359);
          float _363 = _58 - _55;
          float _364 = _59 - _56;
          float _365 = _60 - _57;
          float _366 = cb4_002x * _363;
          float _367 = cb4_002x * _364;
          float _368 = cb4_002x * _365;
          float _369 = _366 + _55;
          float _370 = _367 + _56;
          float _371 = _368 + _57;
          float _376 = _369 * FrequentPixelConsts_032.x;
          float _377 = _370 * FrequentPixelConsts_032.y;
          float _378 = _371 * FrequentPixelConsts_032.z;
          float _379 = _202 * _162;
          float _380 = _379 * _242;
          float _381 = _380 * _331;
          float _382 = _352 * _381;
          float _383 = _381 - _382;
          float _384 = _360 * _383;
          float _386 = _384 * FrequentPixelConsts_032.w;
          float _387 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_376, _377, _378));
          float _388 = _387 * TEXCOORD.x;
          float _389 = _387 * TEXCOORD.y;
          float _390 = _387 * TEXCOORD.z;
          float _391 = _388 - _376;
          float _392 = _389 - _377;
          float _393 = _390 - _378;
          float _394 = _391 * TEXCOORD.w;
          float _395 = _392 * TEXCOORD.w;
          float _396 = _393 * TEXCOORD.w;
          float _397 = _394 + _376;
          float _398 = _395 + _377;
          float _399 = _396 + _378;
          float _400 = TEXCOORD_1.x - _397;
          float _401 = TEXCOORD_1.y - _398;
          float _402 = TEXCOORD_1.z - _399;
          float _403 = _400 * TEXCOORD_1.w;
          float _404 = _401 * TEXCOORD_1.w;
          float _405 = _402 * TEXCOORD_1.w;
          float _406 = _403 + _397;
          float _407 = _404 + _398;
          float _408 = _405 + _399;
          float _409 = saturate(_386);
          float _410 = _406 * _386;
          float _411 = _407 * _386;
          float _412 = _408 * _386;
          SV_Target.x = _410;
          SV_Target.y = _411;
          SV_Target.z = _412;
          SV_Target.w = _409;
        } else {
          _242 = 0.0f;
        }
      } else {
        _242 = 0.0f;
      }
      bool _245 = (cb12_067w < 0.0f);
      if (!_245) {
        float4 _249 = t24.Sample(s8, float2(_108, _109));
        float _260 = TEXCOORD_5.x - cb12_000x;
        float _261 = TEXCOORD_5.y - cb12_000y;
        float _262 = TEXCOORD_5.z - cb12_000z;
        float _263 = _260 * _260;
        float _264 = _261 * _261;
        float _265 = _263 + _264;
        float _266 = _262 * _262;
        float _267 = _265 + _266;
        float _268 = sqrt(_267);
        float _277 = dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_260, _261, _262));
        float _280 = 1.0f / cb12_021y;
        float _281 = _280 * _268;
        float _282 = _281 / _277;
        float _284 = _268 - _282;
        float _285 = _284 * cb13_032w;
        float _286 = saturate(_285);
        float _287 = _286 * cb13_032z;
        float _288 = max(0.0010000000474974513f, _287);
        float _289 = _268 / cb13_033z;
        bool _290 = (_249.x < _249.y);
        if (_290) {
          bool _292 = (_289 < _249.x);
          bool _293 = (_289 > _249.y);
          bool _294 = _292 || _293;
          if (!_294) {
            float _296 = cb13_033z * _249.x;
            float _297 = _296 - cb13_033x;
            float _298 = _297 * cb13_033y;
            float _299 = 1.0f - _298;
            float _300 = saturate(_299);
            float _301 = _289 - _249.x;
            float _302 = _301 * cb13_033z;
            float _303 = _302 / _288;
            float _304 = saturate(_303);
            float _305 = _304 * _300;
            _325 = 1.0f;
            _326 = _305;
          } else {
            _325 = 0.0f;
            _326 = 1.0f;
          }
        } else {
          bool _307 = (_249.x > _249.y);
          if (_307) {
            bool _309 = (_289 < _249.y);
            if (!_309) {
              bool _311 = (_289 > _249.x);
              if (_311) {
                float _313 = cb13_033z * _249.x;
                float _314 = _313 - cb13_033x;
                float _315 = _314 * cb13_033y;
                float _316 = 1.0f - _315;
                float _317 = saturate(_316);
                _325 = 1.0f;
                _326 = _317;
              } else {
                float _319 = _289 - _249.y;
                float _320 = _319 * cb13_033z;
                float _321 = _320 / _288;
                float _322 = saturate(_321);
                float _323 = 1.0f - _322;
                _325 = 1.0f;
                _326 = _323;
              }
            } else {
              _325 = 1.0f;
              _326 = 1.0f;
            }
          } else {
            _325 = 0.0f;
            _326 = 1.0f;
          }
        }
        float _327 = _326 * _325;
        float _328 = 1.0f - _327;
        float _329 = saturate(_328);
        _331 = _329;
      } else {
        _331 = 0.0f;
      }
      float _336 = cb1_036x - TEXCOORD_5.x;
      float _337 = cb1_036y - TEXCOORD_5.y;
      float _338 = cb1_036z - TEXCOORD_5.z;
      float _339 = _336 * _336;
      float _340 = _337 * _337;
      float _341 = _339 + _340;
      float _342 = _338 * _338;
      float _343 = _341 + _342;
      float _344 = sqrt(_343);
      float _347 = _344 - cb4_005x;
      float _350 = cb4_006x - cb4_005x;
      float _351 = _347 / _350;
      float _352 = saturate(_351);
      float _355 = _344 - cb4_003x;
      float _358 = cb4_004x - cb4_003x;
      float _359 = _355 / _358;
      float _360 = saturate(_359);
      float _363 = _58 - _55;
      float _364 = _59 - _56;
      float _365 = _60 - _57;
      float _366 = cb4_002x * _363;
      float _367 = cb4_002x * _364;
      float _368 = cb4_002x * _365;
      float _369 = _366 + _55;
      float _370 = _367 + _56;
      float _371 = _368 + _57;
      float _376 = _369 * FrequentPixelConsts_032.x;
      float _377 = _370 * FrequentPixelConsts_032.y;
      float _378 = _371 * FrequentPixelConsts_032.z;
      float _379 = _202 * _162;
      float _380 = _379 * _242;
      float _381 = _380 * _331;
      float _382 = _352 * _381;
      float _383 = _381 - _382;
      float _384 = _360 * _383;
      float _386 = _384 * FrequentPixelConsts_032.w;
      float _387 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_376, _377, _378));
      float _388 = _387 * TEXCOORD.x;
      float _389 = _387 * TEXCOORD.y;
      float _390 = _387 * TEXCOORD.z;
      float _391 = _388 - _376;
      float _392 = _389 - _377;
      float _393 = _390 - _378;
      float _394 = _391 * TEXCOORD.w;
      float _395 = _392 * TEXCOORD.w;
      float _396 = _393 * TEXCOORD.w;
      float _397 = _394 + _376;
      float _398 = _395 + _377;
      float _399 = _396 + _378;
      float _400 = TEXCOORD_1.x - _397;
      float _401 = TEXCOORD_1.y - _398;
      float _402 = TEXCOORD_1.z - _399;
      float _403 = _400 * TEXCOORD_1.w;
      float _404 = _401 * TEXCOORD_1.w;
      float _405 = _402 * TEXCOORD_1.w;
      float _406 = _403 + _397;
      float _407 = _404 + _398;
      float _408 = _405 + _399;
      float _409 = saturate(_386);
      float _410 = _406 * _386;
      float _411 = _407 * _386;
      float _412 = _408 * _386;
      SV_Target.x = _410;
      SV_Target.y = _411;
      SV_Target.z = _412;
      SV_Target.w = _409;
    } else {
      _202 = 0.0f;
    }
  } else {
    _202 = 0.0f;
  }
  float _203 = saturate(TEXCOORD_3.y);
  bool _204 = !(_203 >= 0.000299000006634742f);
  bool _205 = !(_203 <= 1.0f);
  bool _206 = _204 || _205;
  if (!_206) {
    bool _208 = !(_203 <= 0.11706800013780594f);
    if (_208) {
      bool _210 = (_203 >= 0.11706800013780594f);
      bool _211 = (_203 <= 0.858892023563385f);
      bool _212 = _210 && _211;
      int _213 = (int)(uint)(_210);
      if (!_212) {
        bool _215 = (_203 >= 0.858892023563385f);
        int _216 = select(_215, 2, 0);
        _239 = _215;
        _240 = _216;
      } else {
        _239 = true;
        _240 = _213;
      }
    } else {
      _239 = true;
      _240 = 0;
    }
    if (_239) {
      while(true) {
        float _219 = _global_0[_240];
        int _220 = _240 + 1;
        float _222 = _global_0[_220];
        float _224 = _global_1[_240];
        float _225 = _203 - _224;
        float _227 = _global_1[_220];
        float _228 = _227 - _224;
        float _229 = _225 / _228;
        float _230 = saturate(_229);
        float _231 = _230 * 2.0f;
        float _232 = 3.0f - _231;
        float _233 = _222 - _219;
        float _234 = _230 * _230;
        float _235 = _234 * _233;
        float _236 = _235 * _232;
        float _237 = _236 + _219;
        _242 = _237;
        break;
      }
      bool _245 = (cb12_067w < 0.0f);
      if (!_245) {
        float4 _249 = t24.Sample(s8, float2(_108, _109));
        float _260 = TEXCOORD_5.x - cb12_000x;
        float _261 = TEXCOORD_5.y - cb12_000y;
        float _262 = TEXCOORD_5.z - cb12_000z;
        float _263 = _260 * _260;
        float _264 = _261 * _261;
        float _265 = _263 + _264;
        float _266 = _262 * _262;
        float _267 = _265 + _266;
        float _268 = sqrt(_267);
        float _277 = dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_260, _261, _262));
        float _280 = 1.0f / cb12_021y;
        float _281 = _280 * _268;
        float _282 = _281 / _277;
        float _284 = _268 - _282;
        float _285 = _284 * cb13_032w;
        float _286 = saturate(_285);
        float _287 = _286 * cb13_032z;
        float _288 = max(0.0010000000474974513f, _287);
        float _289 = _268 / cb13_033z;
        bool _290 = (_249.x < _249.y);
        if (_290) {
          bool _292 = (_289 < _249.x);
          bool _293 = (_289 > _249.y);
          bool _294 = _292 || _293;
          if (!_294) {
            float _296 = cb13_033z * _249.x;
            float _297 = _296 - cb13_033x;
            float _298 = _297 * cb13_033y;
            float _299 = 1.0f - _298;
            float _300 = saturate(_299);
            float _301 = _289 - _249.x;
            float _302 = _301 * cb13_033z;
            float _303 = _302 / _288;
            float _304 = saturate(_303);
            float _305 = _304 * _300;
            _325 = 1.0f;
            _326 = _305;
          } else {
            _325 = 0.0f;
            _326 = 1.0f;
          }
        } else {
          bool _307 = (_249.x > _249.y);
          if (_307) {
            bool _309 = (_289 < _249.y);
            if (!_309) {
              bool _311 = (_289 > _249.x);
              if (_311) {
                float _313 = cb13_033z * _249.x;
                float _314 = _313 - cb13_033x;
                float _315 = _314 * cb13_033y;
                float _316 = 1.0f - _315;
                float _317 = saturate(_316);
                _325 = 1.0f;
                _326 = _317;
              } else {
                float _319 = _289 - _249.y;
                float _320 = _319 * cb13_033z;
                float _321 = _320 / _288;
                float _322 = saturate(_321);
                float _323 = 1.0f - _322;
                _325 = 1.0f;
                _326 = _323;
              }
            } else {
              _325 = 1.0f;
              _326 = 1.0f;
            }
          } else {
            _325 = 0.0f;
            _326 = 1.0f;
          }
        }
        float _327 = _326 * _325;
        float _328 = 1.0f - _327;
        float _329 = saturate(_328);
        _331 = _329;
      } else {
        _331 = 0.0f;
      }
      float _336 = cb1_036x - TEXCOORD_5.x;
      float _337 = cb1_036y - TEXCOORD_5.y;
      float _338 = cb1_036z - TEXCOORD_5.z;
      float _339 = _336 * _336;
      float _340 = _337 * _337;
      float _341 = _339 + _340;
      float _342 = _338 * _338;
      float _343 = _341 + _342;
      float _344 = sqrt(_343);
      float _347 = _344 - cb4_005x;
      float _350 = cb4_006x - cb4_005x;
      float _351 = _347 / _350;
      float _352 = saturate(_351);
      float _355 = _344 - cb4_003x;
      float _358 = cb4_004x - cb4_003x;
      float _359 = _355 / _358;
      float _360 = saturate(_359);
      float _363 = _58 - _55;
      float _364 = _59 - _56;
      float _365 = _60 - _57;
      float _366 = cb4_002x * _363;
      float _367 = cb4_002x * _364;
      float _368 = cb4_002x * _365;
      float _369 = _366 + _55;
      float _370 = _367 + _56;
      float _371 = _368 + _57;
      float _376 = _369 * FrequentPixelConsts_032.x;
      float _377 = _370 * FrequentPixelConsts_032.y;
      float _378 = _371 * FrequentPixelConsts_032.z;
      float _379 = _202 * _162;
      float _380 = _379 * _242;
      float _381 = _380 * _331;
      float _382 = _352 * _381;
      float _383 = _381 - _382;
      float _384 = _360 * _383;
      float _386 = _384 * FrequentPixelConsts_032.w;
      float _387 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_376, _377, _378));
      float _388 = _387 * TEXCOORD.x;
      float _389 = _387 * TEXCOORD.y;
      float _390 = _387 * TEXCOORD.z;
      float _391 = _388 - _376;
      float _392 = _389 - _377;
      float _393 = _390 - _378;
      float _394 = _391 * TEXCOORD.w;
      float _395 = _392 * TEXCOORD.w;
      float _396 = _393 * TEXCOORD.w;
      float _397 = _394 + _376;
      float _398 = _395 + _377;
      float _399 = _396 + _378;
      float _400 = TEXCOORD_1.x - _397;
      float _401 = TEXCOORD_1.y - _398;
      float _402 = TEXCOORD_1.z - _399;
      float _403 = _400 * TEXCOORD_1.w;
      float _404 = _401 * TEXCOORD_1.w;
      float _405 = _402 * TEXCOORD_1.w;
      float _406 = _403 + _397;
      float _407 = _404 + _398;
      float _408 = _405 + _399;
      float _409 = saturate(_386);
      float _410 = _406 * _386;
      float _411 = _407 * _386;
      float _412 = _408 * _386;
      SV_Target.x = _410;
      SV_Target.y = _411;
      SV_Target.z = _412;
      SV_Target.w = _409;
    } else {
      _242 = 0.0f;
    }
  } else {
    _242 = 0.0f;
  }
  bool _245 = (cb12_067w < 0.0f);
  if (!_245) {
    float4 _249 = t24.Sample(s8, float2(_108, _109));
    float _260 = TEXCOORD_5.x - cb12_000x;
    float _261 = TEXCOORD_5.y - cb12_000y;
    float _262 = TEXCOORD_5.z - cb12_000z;
    float _263 = _260 * _260;
    float _264 = _261 * _261;
    float _265 = _263 + _264;
    float _266 = _262 * _262;
    float _267 = _265 + _266;
    float _268 = sqrt(_267);
    float _277 = dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_260, _261, _262));
    float _280 = 1.0f / cb12_021y;
    float _281 = _280 * _268;
    float _282 = _281 / _277;
    float _284 = _268 - _282;
    float _285 = _284 * cb13_032w;
    float _286 = saturate(_285);
    float _287 = _286 * cb13_032z;
    float _288 = max(0.0010000000474974513f, _287);
    float _289 = _268 / cb13_033z;
    bool _290 = (_249.x < _249.y);
    if (_290) {
      bool _292 = (_289 < _249.x);
      bool _293 = (_289 > _249.y);
      bool _294 = _292 || _293;
      if (!_294) {
        float _296 = cb13_033z * _249.x;
        float _297 = _296 - cb13_033x;
        float _298 = _297 * cb13_033y;
        float _299 = 1.0f - _298;
        float _300 = saturate(_299);
        float _301 = _289 - _249.x;
        float _302 = _301 * cb13_033z;
        float _303 = _302 / _288;
        float _304 = saturate(_303);
        float _305 = _304 * _300;
        _325 = 1.0f;
        _326 = _305;
      } else {
        _325 = 0.0f;
        _326 = 1.0f;
      }
    } else {
      bool _307 = (_249.x > _249.y);
      if (_307) {
        bool _309 = (_289 < _249.y);
        if (!_309) {
          bool _311 = (_289 > _249.x);
          if (_311) {
            float _313 = cb13_033z * _249.x;
            float _314 = _313 - cb13_033x;
            float _315 = _314 * cb13_033y;
            float _316 = 1.0f - _315;
            float _317 = saturate(_316);
            _325 = 1.0f;
            _326 = _317;
          } else {
            float _319 = _289 - _249.y;
            float _320 = _319 * cb13_033z;
            float _321 = _320 / _288;
            float _322 = saturate(_321);
            float _323 = 1.0f - _322;
            _325 = 1.0f;
            _326 = _323;
          }
        } else {
          _325 = 1.0f;
          _326 = 1.0f;
        }
      } else {
        _325 = 0.0f;
        _326 = 1.0f;
      }
    }
    float _327 = _326 * _325;
    float _328 = 1.0f - _327;
    float _329 = saturate(_328);
    _331 = _329;
  } else {
    _331 = 0.0f;
  }
  float _336 = cb1_036x - TEXCOORD_5.x;
  float _337 = cb1_036y - TEXCOORD_5.y;
  float _338 = cb1_036z - TEXCOORD_5.z;
  float _339 = _336 * _336;
  float _340 = _337 * _337;
  float _341 = _339 + _340;
  float _342 = _338 * _338;
  float _343 = _341 + _342;
  float _344 = sqrt(_343);
  float _347 = _344 - cb4_005x;
  float _350 = cb4_006x - cb4_005x;
  float _351 = _347 / _350;
  float _352 = saturate(_351);
  float _355 = _344 - cb4_003x;
  float _358 = cb4_004x - cb4_003x;
  float _359 = _355 / _358;
  float _360 = saturate(_359);
  float _363 = _58 - _55;
  float _364 = _59 - _56;
  float _365 = _60 - _57;
  float _366 = cb4_002x * _363;
  float _367 = cb4_002x * _364;
  float _368 = cb4_002x * _365;
  float _369 = _366 + _55;
  float _370 = _367 + _56;
  float _371 = _368 + _57;
  float _376 = _369 * FrequentPixelConsts_032.x;
  float _377 = _370 * FrequentPixelConsts_032.y;
  float _378 = _371 * FrequentPixelConsts_032.z;
  float _379 = _202 * _162;
  float _380 = _379 * _242;
  float _381 = _380 * _331;
  float _382 = _352 * _381;
  float _383 = _381 - _382;
  float _384 = _360 * _383;
  float _386 = _384 * FrequentPixelConsts_032.w;
  float _387 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_376, _377, _378));
  float _388 = _387 * TEXCOORD.x;
  float _389 = _387 * TEXCOORD.y;
  float _390 = _387 * TEXCOORD.z;
  float _391 = _388 - _376;
  float _392 = _389 - _377;
  float _393 = _390 - _378;
  float _394 = _391 * TEXCOORD.w;
  float _395 = _392 * TEXCOORD.w;
  float _396 = _393 * TEXCOORD.w;
  float _397 = _394 + _376;
  float _398 = _395 + _377;
  float _399 = _396 + _378;
  float _400 = TEXCOORD_1.x - _397;
  float _401 = TEXCOORD_1.y - _398;
  float _402 = TEXCOORD_1.z - _399;
  float _403 = _400 * TEXCOORD_1.w;
  float _404 = _401 * TEXCOORD_1.w;
  float _405 = _402 * TEXCOORD_1.w;
  float _406 = _403 + _397;
  float _407 = _404 + _398;
  float _408 = _405 + _399;
  float _409 = saturate(_386);
  float _410 = _406 * _386;
  float _411 = _407 * _386;
  float _412 = _408 * _386;
  SV_Target.x = _410;
  SV_Target.y = _411;
  SV_Target.z = _412;
  SV_Target.w = _409;
  return SV_Target;
}
