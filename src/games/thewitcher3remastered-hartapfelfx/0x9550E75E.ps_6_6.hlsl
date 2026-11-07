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
  float cb4_001y : packoffset(c001.y);
  float cb4_002x : packoffset(c002.x);
  float cb4_002y : packoffset(c002.y);
  float cb4_003x : packoffset(c003.x);
  float cb4_004x : packoffset(c004.x);
  float cb4_005x : packoffset(c005.x);
  float cb4_006x : packoffset(c006.x);
  float cb4_007x : packoffset(c007.x);
  float cb4_008x : packoffset(c008.x);
  float cb4_009x : packoffset(c009.x);
  float cb4_010x : packoffset(c010.x);
  float cb4_011x : packoffset(c011.x);
  float cb4_012x : packoffset(c012.x);
  float cb4_013x : packoffset(c013.x);
  float cb4_014x : packoffset(c014.x);
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
  linear float3 TEXCOORD_6 : TEXCOORD6,
  noperspective float4 SV_Position : SV_Position
) {
  float4 SV_Target_1 = 0;
  float4 SV_Target = 0;
  if(ReceiverFrameMatches()) TEXCOORD_2 = ReceiverFogVarying(SV_Position,length(TEXCOORD_6.xyz-receiver_frame[0].xyz));
  float _49 = cb4_001x * TEXCOORD_1.y;
  float _50 = cb4_001y * TEXCOORD_1.z;
  float _56 = cb4_002x * GlobalShaderConsts_000.x;
  float _57 = cb4_002y * GlobalShaderConsts_000.x;
  float _62 = _56 + _49;
  float _63 = _57 + _50;
  float _64 = 1.0f / cb4_003x;
  float _65 = 1.0f / cb4_004x;
  float _66 = floor(TEXCOORD_1.x);
  float _67 = _64 * TEXCOORD_1.x;
  float _68 = floor(_67);
  float _69 = _66 + _62;
  float _70 = _69 * _64;
  float _71 = _68 + _63;
  float _72 = _71 * _65;
  float4 _75 = t0.Sample(s0, float2(_70, _72));
  float _79 = TEXCOORD_1.x + 1.0f;
  float _80 = floor(_79);
  float _81 = _64 * _79;
  float _82 = floor(_81);
  float _83 = _80 + _62;
  float _84 = _83 * _64;
  float _85 = _82 + _63;
  float _86 = _85 * _65;
  float4 _89 = t0.Sample(s0, float2(_84, _86));
  float _97 = 1.0f / cb4_003x;
  float _98 = 1.0f / cb4_004x;
  float _99 = _97 * TEXCOORD_1.x;
  float _100 = floor(_99);
  float _101 = _97 * _69;
  float _102 = _100 + _63;
  float _103 = _102 * _98;
  float4 _106 = t0.Sample(s0, float2(_101, _103));
  float _108 = _97 * _79;
  float _109 = floor(_108);
  float _110 = _97 * _83;
  float _111 = _109 + _63;
  float _112 = _111 * _98;
  float4 _115 = t0.Sample(s0, float2(_110, _112));
  float _119 = frac(TEXCOORD_1.x);
  float _120 = _115.x - _106.x;
  float _121 = _119 * _120;
  float _122 = _121 + _106.x;
  float _123 = _89.x - _75.x;
  float _124 = _89.y - _75.y;
  float _125 = _89.z - _75.z;
  float _126 = _119 * _123;
  float _127 = _119 * _124;
  float _128 = _119 * _125;
  float _129 = _126 + _75.x;
  float _130 = _127 + _75.y;
  float _131 = _128 + _75.z;
  float _132 = _122 - _129;
  float _133 = _122 - _130;
  float _134 = _122 - _131;
  float _135 = _132 * cb4_005x;
  float _136 = _133 * cb4_005x;
  float _137 = _134 * cb4_005x;
  float _138 = _135 + _129;
  float _139 = _136 + _130;
  float _140 = _137 + _131;
  float _141 = log2(_138);
  float _142 = log2(_139);
  float _143 = log2(_140);
  float _144 = _141 * 2.200000047683716f;
  float _145 = _142 * 2.200000047683716f;
  float _146 = _143 * 2.200000047683716f;
  float _147 = exp2(_144);
  float _148 = exp2(_145);
  float _149 = exp2(_146);
  float _150 = _147 * TEXCOORD_4.x;
  float _151 = _148 * TEXCOORD_4.y;
  float _152 = _149 * TEXCOORD_4.z;
  float _155 = max(cb4_000x, TEXCOORD_3.x);
  float _156 = max(cb4_000x, TEXCOORD_3.y);
  float _157 = max(cb4_000x, TEXCOORD_3.z);
  float _158 = _150 * _155;
  float _159 = _151 * _156;
  float _160 = _152 * _157;
  float _163 = _158 * cb4_006x;
  float _164 = _159 * cb4_006x;
  float _165 = _160 * cb4_006x;
  float _168 = dot(float3(_163, _164, _165), float3(0.29899999499320984f, 0.5870000123977661f, 0.11400000005960464f));
  float _169 = _168 - _163;
  float _170 = _168 - _164;
  float _171 = _168 - _165;
  float _172 = _169 * cb4_007x;
  float _173 = _170 * cb4_007x;
  float _174 = _171 * cb4_007x;
  float _175 = _172 + _163;
  float _176 = _173 + _164;
  float _177 = _174 + _165;
  float _182 = 1.0f / cb4_003x;
  float _183 = 1.0f / cb4_004x;
  float _184 = _182 * TEXCOORD_1.x;
  float _185 = floor(_184);
  float _186 = _182 * _69;
  float _187 = _185 + _63;
  float _188 = _187 * _183;
  float4 _191 = t0.Sample(s0, float2(_186, _188));
  float _193 = _182 * _79;
  float _194 = floor(_193);
  float _195 = _182 * _83;
  float _196 = _194 + _63;
  float _197 = _196 * _183;
  float4 _200 = t0.Sample(s0, float2(_195, _197));
  float _206 = 1.0f / cb4_003x;
  float _207 = 1.0f / cb4_004x;
  float _208 = _206 * TEXCOORD_1.x;
  float _209 = floor(_208);
  float _210 = _206 * _69;
  float _211 = _209 + _63;
  float _212 = _211 * _207;
  float4 _215 = t0.Sample(s0, float2(_210, _212));
  float _217 = _206 * _79;
  float _218 = floor(_217);
  float _219 = _206 * _83;
  float _220 = _218 + _63;
  float _221 = _220 * _207;
  float4 _224 = t0.Sample(s0, float2(_219, _221));
  float _229 = GlobalShaderConsts_016.z * SV_Position.x;
  float _230 = GlobalShaderConsts_016.w * SV_Position.y;
  bool _233 = (cb12_067w < 0.0f);
  float _313;
  float _314;
  float _319;
  if (!_233) {
    float4 _237 = t24.Sample(s8, float2(_229, _230));
    float _248 = TEXCOORD_6.x - cb12_000x;
    float _249 = TEXCOORD_6.y - cb12_000y;
    float _250 = TEXCOORD_6.z - cb12_000z;
    float _251 = _248 * _248;
    float _252 = _249 * _249;
    float _253 = _251 + _252;
    float _254 = _250 * _250;
    float _255 = _253 + _254;
    float _256 = sqrt(_255);
    float _265 = dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_248, _249, _250));
    float _268 = 1.0f / cb12_021y;
    float _269 = _268 * _256;
    float _270 = _269 / _265;
    float _272 = _256 - _270;
    float _273 = _272 * cb13_032w;
    float _274 = saturate(_273);
    float _275 = _274 * cb13_032z;
    float _276 = max(0.0010000000474974513f, _275);
    float _277 = _256 / cb13_033z;
    bool _278 = (_237.x < _237.y);
    if (_278) {
      bool _280 = (_277 < _237.x);
      bool _281 = (_277 > _237.y);
      bool _282 = _280 || _281;
      if (!_282) {
        float _284 = cb13_033z * _237.x;
        float _285 = _284 - cb13_033x;
        float _286 = _285 * cb13_033y;
        float _287 = 1.0f - _286;
        float _288 = saturate(_287);
        float _289 = _277 - _237.x;
        float _290 = _289 * cb13_033z;
        float _291 = _290 / _276;
        float _292 = saturate(_291);
        float _293 = _292 * _288;
        _313 = 1.0f;
        _314 = _293;
      } else {
        _313 = 0.0f;
        _314 = 1.0f;
      }
    } else {
      bool _295 = (_237.x > _237.y);
      if (_295) {
        bool _297 = (_277 < _237.y);
        if (!_297) {
          bool _299 = (_277 > _237.x);
          if (_299) {
            float _301 = cb13_033z * _237.x;
            float _302 = _301 - cb13_033x;
            float _303 = _302 * cb13_033y;
            float _304 = 1.0f - _303;
            float _305 = saturate(_304);
            _313 = 1.0f;
            _314 = _305;
          } else {
            float _307 = _277 - _237.y;
            float _308 = _307 * cb13_033z;
            float _309 = _308 / _276;
            float _310 = saturate(_309);
            float _311 = 1.0f - _310;
            _313 = 1.0f;
            _314 = _311;
          }
        } else {
          _313 = 1.0f;
          _314 = 1.0f;
        }
      } else {
        _313 = 0.0f;
        _314 = 1.0f;
      }
    }
    float _315 = _314 * _313;
    float _316 = 1.0f - _315;
    float _317 = saturate(_316);
    _319 = _317;
  } else {
    _319 = 0.0f;
  }
  float _324 = _224.y - _215.y;
  float _325 = _324 * _119;
  float _326 = _200.w - _191.w;
  float _327 = _326 * _119;
  float _328 = _327 + _191.w;
  float _329 = _215.y - _328;
  float _330 = _329 + _325;
  float _331 = cb4_005x * _330;
  float _332 = _331 + _328;
  float _333 = _332 * _319;
  float _334 = _333 - _332;
  float _335 = _334 * cb4_010x;
  float _336 = _335 + _332;
  float _337 = _336 * TEXCOORD_4.w;
  float _341 = GlobalShaderConsts_016.z * SV_Position.x;
  float _342 = GlobalShaderConsts_016.w * SV_Position.y;
  float4 _345 = t15.SampleLevel(s15, float2(_341, _342), 0.0f);
  float _349 = cb12_022x * _345.x;
  float _351 = _349 + cb12_022y;
  float _354 = _351 * cb12_021x;
  float _356 = _354 + cb12_021y;
  float _357 = 1.0f / _356;
  float _358 = max(_357, -3.4028234663852886e+38f);
  float _359 = min(_358, 3.4028234663852886e+38f);
  float _360 = _359 - TEXCOORD_1.w;
  float _363 = cb4_011x * _360;
  float _364 = saturate(_363);
  float _365 = _337 * _364;
  float _370 = cb1_036x - TEXCOORD_6.x;
  float _371 = cb1_036y - TEXCOORD_6.y;
  float _372 = cb1_036z - TEXCOORD_6.z;
  float _373 = _370 * _370;
  float _374 = _371 * _371;
  float _375 = _373 + _374;
  float _376 = _372 * _372;
  float _377 = _375 + _376;
  float _378 = sqrt(_377);
  float _381 = _378 - cb4_008x;
  float _384 = cb4_009x - cb4_008x;
  float _385 = _381 / _384;
  float _386 = saturate(_385);
  float _389 = dot(float3(_370, _371, _372), float3(_370, _371, _372));
  float _390 = rsqrt(_389);
  float _391 = _390 * _370;
  float _392 = _390 * _371;
  float _393 = _390 * _372;
  float _394 = dot(float3(TEXCOORD_5.x, TEXCOORD_5.y, TEXCOORD_5.z), float3(_391, _392, _393));
  float _395 = abs(_394);
  float _396 = 1.0f - _395;
  float _397 = saturate(_396);
  float _398 = log2(_397);
  float _399 = _398 * 0.5f;
  float _400 = exp2(_399);
  float _401 = 1.0f - _400;
  float _402 = log2(_401);
  float _403 = _402 * cb4_012x;
  float _404 = exp2(_403);
  float _405 = saturate(_404);
  float _406 = _365 * _386;
  float _407 = _405 * _406;
  float _410 = _407 - _406;
  float _411 = cb4_013x * _410;
  float _412 = _411 + _406;
  float _415 = _412 * cb4_014x;
  float _416 = saturate(_415);
  float _421 = FrequentPixelConsts_032.x * _175;
  float _422 = FrequentPixelConsts_032.y * _176;
  float _423 = FrequentPixelConsts_032.z * _177;
  float _425 = FrequentPixelConsts_032.w * _416;
  float _426 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_421, _422, _423));
  float _427 = _426 * TEXCOORD.x;
  float _428 = _426 * TEXCOORD.y;
  float _429 = _426 * TEXCOORD.z;
  float _430 = _427 - _421;
  float _431 = _428 - _422;
  float _432 = _429 - _423;
  float _433 = _430 * TEXCOORD.w;
  float _434 = _431 * TEXCOORD.w;
  float _435 = _432 * TEXCOORD.w;
  float _436 = _433 + _421;
  float _437 = _434 + _422;
  float _438 = _435 + _423;
  float _439 = TEXCOORD_2.x - _436;
  float _440 = TEXCOORD_2.y - _437;
  float _441 = TEXCOORD_2.z - _438;
  float _442 = _439 * TEXCOORD_2.w;
  float _443 = _440 * TEXCOORD_2.w;
  float _444 = _441 * TEXCOORD_2.w;
  float _445 = _442 + _436;
  float _446 = _443 + _437;
  float _447 = _444 + _438;
  float _448 = saturate(_425);
  SV_Target_1.x = _448;
  SV_Target_1.y = _448;
  SV_Target_1.z = _448;
  SV_Target_1.w = _448;
  float _449 = _445 * _425;
  float _450 = _446 * _425;
  float _451 = _447 * _425;
  SV_Target.x = _449;
  SV_Target.y = _450;
  SV_Target.z = _451;
  SV_Target.w = _448;
  OutputSignature output_signature = { SV_Target_1, SV_Target };
  return output_signature;
}
