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

Texture2D<float4> t22 : register(t22);

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

#define cb12_raw receiver_frame

#define cb12_100x (cb12_raw[100].x)
#define cb12_106x (cb12_raw[106].x)
#define cb12_001z (cb12_raw[1].z)
#define cb12_000y (cb12_raw[0].y)
#define cb12_111x (asint(cb12_raw[111].x))
#define cb12_067w (cb12_raw[67].w)
#define cb12_000x (cb12_raw[0].x)
#define cb12_000z (cb12_raw[0].z)
#define cb12_002z (cb12_raw[2].z)
#define cb12_003z (cb12_raw[3].z)
#define cb12_021y (cb12_raw[21].y)
#define cb12_022x (cb12_raw[22].x)
#define cb12_022y (cb12_raw[22].y)
#define cb12_021x (cb12_raw[21].x)

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
  float cb4_011x : packoffset(c011.x);
  float cb4_012x : packoffset(c012.x);
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

SamplerState s11 : register(s11);

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
  linear float3 TEXCOORD_4 : TEXCOORD4,
  linear float3 TEXCOORD_5 : TEXCOORD5,
  noperspective float4 SV_Position : SV_Position
) {
  float4 SV_Target_1 = 0;
  float4 SV_Target = 0;
  if(ReceiverFrameMatches()) TEXCOORD_2 = ReceiverFogVarying(SV_Position,length(TEXCOORD_5.xyz-receiver_frame[0].xyz), TEXCOORD_2);
  bool _266;
  float _39 = cb4_001x * cb4_000y;
  float _40 = cb4_001x * cb4_000z;
  float _47 = 1.0f / cb4_003x;
  float _48 = 1.0f / cb4_004x;
  float _49 = floor(TEXCOORD_1.x);
  float _50 = _47 * TEXCOORD_1.x;
  float _51 = floor(_50);
  float _52 = _49 + TEXCOORD_1.y;
  float _53 = _52 * _47;
  float _54 = _51 + TEXCOORD_1.z;
  float _55 = _54 * _48;
  float4 _58 = t0.Sample(s0, float2(_53, _55));
  float _61 = TEXCOORD_1.x + 1.0f;
  float _62 = floor(_61);
  float _63 = _47 * _61;
  float _64 = floor(_63);
  float _65 = _62 + TEXCOORD_1.y;
  float _66 = _65 * _47;
  float _67 = _64 + TEXCOORD_1.z;
  float _68 = _67 * _48;
  float4 _71 = t0.Sample(s0, float2(_66, _68));
  float _78 = 1.0f / cb4_003x;
  float _79 = 1.0f / cb4_004x;
  float _80 = _78 * TEXCOORD_1.x;
  float _81 = floor(_80);
  float _82 = _78 * _52;
  float _83 = _81 + TEXCOORD_1.z;
  float _84 = _83 * _79;
  float4 _87 = t0.Sample(s0, float2(_82, _84));
  float _89 = _78 * _61;
  float _90 = floor(_89);
  float _91 = _78 * _65;
  float _92 = _90 + TEXCOORD_1.z;
  float _93 = _92 * _79;
  float4 _96 = t0.Sample(s0, float2(_91, _93));
  float _100 = frac(TEXCOORD_1.x);
  float _101 = _96.x - _87.x;
  float _102 = _100 * _101;
  float _103 = _102 + _87.x;
  float _104 = _71.y - _58.y;
  float _105 = _71.z - _58.z;
  float _106 = _100 * _104;
  float _107 = _100 * _105;
  float _108 = _106 + _58.y;
  float _109 = _107 + _58.z;
  float _110 = _103 - _108;
  float _111 = _103 - _109;
  float _112 = _110 * cb4_005x;
  float _113 = _111 * cb4_005x;
  float _114 = _112 + _108;
  float _115 = _113 + _109;
  float _116 = log2(_114);
  float _117 = log2(_115);
  float _118 = _116 * 2.200000047683716f;
  float _119 = _117 * 2.200000047683716f;
  float _120 = exp2(_118);
  float _121 = exp2(_119);
  float _122 = _120 * TEXCOORD_3.y;
  float _125 = cb4_002x - cb4_001x;
  float _126 = cb4_000y * _125;
  float _127 = cb4_002x - cb4_001x;
  float _128 = cb4_000z * _127;
  float _129 = GlobalShaderConsts_144.w * _126;
  float _130 = GlobalShaderConsts_144.w * _128;
  float _131 = _129 + _39;
  float _132 = _130 + _40;
  float _133 = _122 * _131;
  float _137 = _133 * GlobalShaderConsts_160.y;
  bool _138 = (TEXCOORD_4.z < 0.0f);
  float _139 = TEXCOORD_4.x * 0.5f;
  float _140 = TEXCOORD_4.y * -0.5f;
  float _141 = 1.0f - TEXCOORD_4.z;
  float _142 = 1.0f / _141;
  float _143 = max(_142, -3.4028234663852886e+38f);
  float _144 = min(_143, 3.4028234663852886e+38f);
  float _145 = _139 * _144;
  float _146 = _140 * _144;
  float _147 = TEXCOORD_4.x * -0.5f;
  float _148 = TEXCOORD_4.y * 0.5f;
  float _149 = TEXCOORD_4.z + 1.0f;
  float _150 = 1.0f / _149;
  float _151 = max(_150, -3.4028234663852886e+38f);
  float _152 = min(_151, 3.4028234663852886e+38f);
  float _153 = _147 * _152;
  float _154 = _148 * _152;
  float _155 = select(_138, _145, _153);
  float _156 = _155 + 0.5f;
  float _157 = select(_138, _146, _154);
  float _158 = _157 + 0.5f;
  float _159 = _156 * 0.6666666269302368f;
  float _160 = float((bool)_138);
  float _161 = _160 + 0.1666666716337204f;
  float _162 = _161 + _159;
  float _163 = _162 * 0.5f;
  float _164 = _158 * 0.095238097012043f;
  float _165 = _164 + 0.0238095261156559f;
  int _167;
  float _168;
  float _169;
  float _170;
  float _171;
  float _260;
  float _261;
  float _262;
  float _263;
  float _331;
  float _332;
  float _333;
  float _334;
  float _464;
  float _465;
  float _470;
  _167 = 1;
  _168 = 0.0f;
  _169 = 0.0f;
  _170 = 0.0f;
  _171 = 9.999999747378752e-06f;
  while(true) {
    int _172 = _167 * 12;
    int _173 = _172 + 102;
    int _178 = _172 + 103;
    int _183 = _172 + 104;
    int _188 = _172 + 105;
    float _193 = (cb12_raw[_173].x) * TEXCOORD_5.x;
    float _194 = mad((cb12_raw[_178].x), TEXCOORD_5.y, _193);
    float _195 = mad((cb12_raw[_183].x), TEXCOORD_5.z, _194);
    float _196 = _195 + (cb12_raw[_188].x);
    float _197 = (cb12_raw[_173].y) * TEXCOORD_5.x;
    float _198 = mad((cb12_raw[_178].y), TEXCOORD_5.y, _197);
    float _199 = mad((cb12_raw[_183].y), TEXCOORD_5.z, _198);
    float _200 = _199 + (cb12_raw[_188].y);
    float _201 = (cb12_raw[_173].z) * TEXCOORD_5.x;
    float _202 = mad((cb12_raw[_178].z), TEXCOORD_5.y, _201);
    float _203 = mad((cb12_raw[_183].z), TEXCOORD_5.z, _202);
    float _204 = _203 + (cb12_raw[_188].z);
    float _205 = abs(_196);
    float _206 = abs(_200);
    float _207 = abs(_204);
    float _208 = 1.0f - _205;
    float _209 = 1.0f - _206;
    float _210 = 1.0f - _207;
    bool _211 = (_208 > 0.0f);
    bool _212 = (_209 > 0.0f);
    bool _213 = (_210 > 0.0f);
    bool _214 = _211 && _212;
    bool _215 = _214 && _213;
    if (_215) {
      int _217 = _172 + 101;
      float _222 = (cb12_raw[_217].x) * _208;
      float _223 = (cb12_raw[_217].y) * _209;
      float _224 = (cb12_raw[_217].z) * _210;
      float _225 = saturate(_222);
      float _226 = saturate(_223);
      float _227 = saturate(_224);
      float _228 = 1.0f - _171;
      int _229 = _172 + 100;
      float _232 = _225 * _228;
      float _233 = _232 * _226;
      float _234 = _233 * _227;
      float _235 = _234 * (cb12_raw[_229].x);
      float _236 = _235 + _171;
      int _237 = _172 + 106;
      float _240 = _235 * (cb12_raw[_237].x);
      int _241 = _172 + 111;
      float _244 = float((int)(asint(cb12_raw[_241].x)));
      float _245 = _244 * 0.1428571492433548f;
      float _246 = _245 + _165;
      float4 _249 = t22.SampleLevel(s11, float2(_163, _246), 0.0f);
      float _253 = _249.x * _240;
      float _254 = _249.y * _240;
      float _255 = _249.z * _240;
      float _256 = _253 + _170;
      float _257 = _254 + _169;
      float _258 = _255 + _168;
      _260 = _236;
      _261 = _256;
      _262 = _257;
      _263 = _258;
    } else {
      _260 = _171;
      _261 = _170;
      _262 = _169;
      _263 = _168;
    }
    int _264 = _167 + 1;
    bool _265 = ((uint)_264 < (uint)7);
    _266 = (_260 < 0.9990000128746033f);
    bool _267 = _265 && _266;
    if (_267) {
      _167 = _264;
      _168 = _263;
      _169 = _262;
      _170 = _261;
      _171 = _260;
      continue;
    }
    break;
  }
  float _281 = cb4_001x * cb4_000x;
  float _284 = _71.x - _58.x;
  float _285 = _100 * _284;
  float _286 = _285 + _58.x;
  float _287 = _103 - _286;
  float _288 = _287 * cb4_005x;
  float _289 = _288 + _286;
  float _290 = log2(_289);
  float _291 = _290 * 2.200000047683716f;
  float _292 = exp2(_291);
  float _293 = _121 * TEXCOORD_3.z;
  float _294 = cb4_002x - cb4_001x;
  float _295 = cb4_000x * _294;
  float _296 = GlobalShaderConsts_144.w * _295;
  float _297 = _296 + _281;
  float _298 = TEXCOORD_3.x * _297;
  float _299 = _298 * _292;
  float _300 = _293 * _132;
  float _302 = _299 * GlobalShaderConsts_160.x;
  float _303 = _300 * GlobalShaderConsts_160.z;
  [branch]
  if (_266) {
    float _305 = 1.0f - _260;
    float _308 = cb12_100x * _305;
    float _309 = _308 + _260;
    float _312 = _308 * cb12_106x;
    float _315 = float((int)(cb12_111x));
    float _316 = _315 * 0.1428571492433548f;
    float _317 = _316 + _165;
    float4 _320 = t22.SampleLevel(s11, float2(_163, _317), 0.0f);
    float _324 = _320.x * _312;
    float _325 = _320.y * _312;
    float _326 = _320.z * _312;
    float _327 = _324 + _261;
    float _328 = _325 + _262;
    float _329 = _326 + _263;
    _331 = _309;
    _332 = _327;
    _333 = _328;
    _334 = _329;
  } else {
    _331 = _260;
    _332 = _261;
    _333 = _262;
    _334 = _263;
  }
  float _335 = 1.0f / _331;
  float _336 = _335 * _332;
  float _337 = _335 * _333;
  float _338 = _335 * _334;
  float _341 = _302 - _299;
  float _342 = _137 - _133;
  float _343 = _303 - _300;
  float _344 = cb4_006x * _341;
  float _345 = cb4_006x * _342;
  float _346 = cb4_006x * _343;
  float _347 = _344 + _299;
  float _348 = _345 + _133;
  float _349 = _346 + _300;
  float _350 = _336 * _347;
  float _351 = _337 * _348;
  float _352 = _338 * _349;
  float _357 = 1.0f / cb4_003x;
  float _358 = 1.0f / cb4_004x;
  float _359 = _357 * TEXCOORD_1.x;
  float _360 = floor(_359);
  float _361 = _357 * _52;
  float _362 = _360 + TEXCOORD_1.z;
  float _363 = _362 * _358;
  float4 _366 = t0.Sample(s0, float2(_361, _363));
  float _368 = _357 * _61;
  float _369 = floor(_368);
  float _370 = _357 * _65;
  float _371 = _369 + TEXCOORD_1.z;
  float _372 = _371 * _358;
  float4 _375 = t0.Sample(s0, float2(_370, _372));
  float _380 = GlobalShaderConsts_016.z * SV_Position.x;
  float _381 = GlobalShaderConsts_016.w * SV_Position.y;
  bool _384 = (cb12_067w < 0.0f);
  if (!_384) {
    float4 _388 = t24.Sample(s8, float2(_380, _381));
    float _399 = TEXCOORD_5.x - cb12_000x;
    float _400 = TEXCOORD_5.y - cb12_000y;
    float _401 = TEXCOORD_5.z - cb12_000z;
    float _402 = _399 * _399;
    float _403 = _400 * _400;
    float _404 = _402 + _403;
    float _405 = _401 * _401;
    float _406 = _404 + _405;
    float _407 = sqrt(_406);
    float _416 = dot(float3(cb12_001z, cb12_002z, cb12_003z), float3(_399, _400, _401));
    float _419 = 1.0f / cb12_021y;
    float _420 = _419 * _407;
    float _421 = _420 / _416;
    float _423 = _407 - _421;
    float _424 = _423 * cb13_032w;
    float _425 = saturate(_424);
    float _426 = _425 * cb13_032z;
    float _427 = max(0.0010000000474974513f, _426);
    float _428 = _407 / cb13_033z;
    bool _429 = (_388.x < _388.y);
    if (_429) {
      bool _431 = (_428 < _388.x);
      bool _432 = (_428 > _388.y);
      bool _433 = _431 || _432;
      if (!_433) {
        float _435 = cb13_033z * _388.x;
        float _436 = _435 - cb13_033x;
        float _437 = _436 * cb13_033y;
        float _438 = 1.0f - _437;
        float _439 = saturate(_438);
        float _440 = _428 - _388.x;
        float _441 = _440 * cb13_033z;
        float _442 = _441 / _427;
        float _443 = saturate(_442);
        float _444 = _443 * _439;
        _464 = 1.0f;
        _465 = _444;
      } else {
        _464 = 0.0f;
        _465 = 1.0f;
      }
    } else {
      bool _446 = (_388.x > _388.y);
      if (_446) {
        bool _448 = (_428 < _388.y);
        if (!_448) {
          bool _450 = (_428 > _388.x);
          if (_450) {
            float _452 = cb13_033z * _388.x;
            float _453 = _452 - cb13_033x;
            float _454 = _453 * cb13_033y;
            float _455 = 1.0f - _454;
            float _456 = saturate(_455);
            _464 = 1.0f;
            _465 = _456;
          } else {
            float _458 = _428 - _388.y;
            float _459 = _458 * cb13_033z;
            float _460 = _459 / _427;
            float _461 = saturate(_460);
            float _462 = 1.0f - _461;
            _464 = 1.0f;
            _465 = _462;
          }
        } else {
          _464 = 1.0f;
          _465 = 1.0f;
        }
      } else {
        _464 = 0.0f;
        _465 = 1.0f;
      }
    }
    float _466 = _465 * _464;
    float _467 = 1.0f - _466;
    float _468 = saturate(_467);
    _470 = _468;
  } else {
    _470 = 0.0f;
  }
  float _473 = _375.w - _366.w;
  float _474 = _473 * _100;
  float _475 = _474 + _366.w;
  float _476 = _470 * _475;
  float _477 = _476 - _475;
  float _478 = _477 * cb4_010x;
  float _479 = _478 + _475;
  float _480 = _479 * TEXCOORD_3.w;
  float _484 = GlobalShaderConsts_016.z * SV_Position.x;
  float _485 = GlobalShaderConsts_016.w * SV_Position.y;
  float4 _488 = t15.SampleLevel(s15, float2(_484, _485), 0.0f);
  float _492 = cb12_022x * _488.x;
  float _494 = _492 + cb12_022y;
  float _497 = _494 * cb12_021x;
  float _499 = _497 + cb12_021y;
  float _500 = 1.0f / _499;
  float _501 = max(_500, -3.4028234663852886e+38f);
  float _502 = min(_501, 3.4028234663852886e+38f);
  float _503 = _502 - TEXCOORD_1.w;
  float _506 = cb4_011x * _503;
  float _507 = saturate(_506);
  float _508 = _480 * _507;
  float _511 = _508 * cb4_012x;
  float _512 = saturate(_511);
  float _517 = cb1_036x - TEXCOORD_5.x;
  float _518 = cb1_036y - TEXCOORD_5.y;
  float _519 = cb1_036z - TEXCOORD_5.z;
  float _520 = _517 * _517;
  float _521 = _518 * _518;
  float _522 = _520 + _521;
  float _523 = _519 * _519;
  float _524 = _522 + _523;
  float _525 = sqrt(_524);
  float _528 = _525 - cb4_008x;
  float _531 = cb4_009x - cb4_008x;
  float _532 = _528 / _531;
  float _533 = saturate(_532);
  float _538 = cb4_006x * _341;
  float _539 = cb4_006x * _342;
  float _540 = cb4_006x * _343;
  float _541 = _538 + _299;
  float _542 = _539 + _133;
  float _543 = _540 + _300;
  float _544 = _350 - _541;
  float _545 = _351 - _542;
  float _546 = _352 - _543;
  float _547 = _544 * cb4_007x;
  float _548 = _545 * cb4_007x;
  float _549 = _546 * cb4_007x;
  float _550 = _547 + _541;
  float _551 = _548 + _542;
  float _552 = _549 + _543;
  float _557 = _550 * FrequentPixelConsts_032.x;
  float _558 = _551 * FrequentPixelConsts_032.y;
  float _559 = _552 * FrequentPixelConsts_032.z;
  float _560 = _533 * _512;
  float _562 = _560 * FrequentPixelConsts_032.w;
  float _563 = dot(float3(0.3330000042915344f, 0.5550000071525574f, 0.22200000286102295f), float3(_557, _558, _559));
  float _564 = _563 * TEXCOORD.x;
  float _565 = _563 * TEXCOORD.y;
  float _566 = _563 * TEXCOORD.z;
  float _567 = _564 - _557;
  float _568 = _565 - _558;
  float _569 = _566 - _559;
  float _570 = _567 * TEXCOORD.w;
  float _571 = _568 * TEXCOORD.w;
  float _572 = _569 * TEXCOORD.w;
  float _573 = _570 + _557;
  float _574 = _571 + _558;
  float _575 = _572 + _559;
  float _576 = TEXCOORD_2.x - _573;
  float _577 = TEXCOORD_2.y - _574;
  float _578 = TEXCOORD_2.z - _575;
  float _579 = _576 * TEXCOORD_2.w;
  float _580 = _577 * TEXCOORD_2.w;
  float _581 = _578 * TEXCOORD_2.w;
  float _582 = _579 + _573;
  float _583 = _580 + _574;
  float _584 = _581 + _575;
  float _585 = saturate(_562);
  SV_Target_1.x = _585;
  SV_Target_1.y = _585;
  SV_Target_1.z = _585;
  SV_Target_1.w = _585;
  float _586 = _582 * _562;
  float _587 = _583 * _562;
  float _588 = _584 * _562;
  SV_Target.x = _586;
  SV_Target.y = _587;
  SV_Target.z = _588;
  SV_Target.w = _585;
  OutputSignature output_signature = { SV_Target_1, SV_Target };
  return output_signature;
}
