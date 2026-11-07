// Native motion/depth conversion with cloud motion at its existing input.
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


Texture2D<float> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t3 : register(t3);

Texture2D<float> t4 : register(t4);

Texture2D<float4> t5 : register(t5);

Texture2D<float2> t6 : register(t6);

RWTexture2D<float4> u0 : register(u0);

RWTexture2D<float4> u1 : register(u1);

RWTexture2D<float> u2 : register(u2);

RWTexture2D<float> u3 : register(u3);

RWTexture2D<float4> u4 : register(u4);

cbuffer cb12 : register(b12) { float4 cb12_raw[341]; }
#define cb12_000x (cb12_raw[0].x)
#define cb12_000y (cb12_raw[0].y)
#define cb12_000z (cb12_raw[0].z)
#define cb12_021x (cb12_raw[21].x)
#define cb12_021y (cb12_raw[21].y)
#define cb12_022x (cb12_raw[22].x)
#define cb12_022y (cb12_raw[22].y)
#define cb12_022w (cb12_raw[22].w)
#define cb12_211x (cb12_raw[211].x)
#define cb12_211y (cb12_raw[211].y)
#define cb12_211z (cb12_raw[211].z)
#define cb12_211w (cb12_raw[211].w)
#define cb12_212x (cb12_raw[212].x)
#define cb12_212y (cb12_raw[212].y)
#define cb12_212z (cb12_raw[212].z)
#define cb12_212w (cb12_raw[212].w)
#define cb12_213x (cb12_raw[213].x)
#define cb12_213y (cb12_raw[213].y)
#define cb12_213z (cb12_raw[213].z)
#define cb12_213w (cb12_raw[213].w)
#define cb12_214x (cb12_raw[214].x)
#define cb12_214y (cb12_raw[214].y)
#define cb12_214z (cb12_raw[214].z)
#define cb12_214w (cb12_raw[214].w)
#define HFCLOUD_MOTION_FRAME cb12_raw
#include "clouds/motion.hlsli"

cbuffer cb10 : register(b10) {
  row_major float4x4 ConvertData_000 : packoffset(c000.x);
  row_major float4x4 ConvertData_064 : packoffset(c004.x);
  row_major float4x4 ConvertData_128 : packoffset(c008.x);
  row_major float4x4 ConvertData_192 : packoffset(c012.x);
  row_major float4x4 ConvertData_256 : packoffset(c016.x);
  row_major float4x4 ConvertData_320 : packoffset(c020.x);
  float4 ConvertData_384 : packoffset(c024.x);
  float4 ConvertData_400 : packoffset(c025.x);
  float ConvertData_416 : packoffset(c026.x);
  int ConvertData_420 : packoffset(c026.y);
  int ConvertData_424 : packoffset(c026.z);
  int ConvertData_428 : packoffset(c026.w);
  int ConvertData_432 : packoffset(c027.x);
  int ConvertData_436 : packoffset(c027.y);
  int ConvertData_440 : packoffset(c027.z);
  int ConvertData_444 : packoffset(c027.w);
  int ConvertData_448 : packoffset(c028.x);
  int ConvertData_452 : packoffset(c028.y);
  float ConvertData_456 : packoffset(c028.z);
  float ConvertData_460 : packoffset(c028.w);
  int ConvertData_464 : packoffset(c029.x);
  float3 ConvertData_468 : packoffset(c029.y);
};

[numthreads(8, 8, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  uint _22 = uint(ConvertData_384.x);
  uint _23 = uint(ConvertData_384.y);
  bool _24 = ((uint)(int)(SV_DispatchThreadID.x) >= (uint)_22);
  bool _25 = ((uint)(int)(SV_DispatchThreadID.y) >= (uint)_23);
  bool _26 = _24 || _25;
  bool _36;
  int _55;
  float _56;
  float _180;
  float _181;
  float _182;
  float _234;
  float _235;
  float _253;
  float _254;
  float _255;
  float _318;
  float _336;
  float _370;
  float _384;
  float _385;
  float _386;
  float _387;
  float _388;
  float _422;
  float _440;
  float _502;
  float _503;
  float _591;
  float _592;
  float _593;
  if (!_26) {
    bool _30 = (ConvertData_420 == 0);
    if (!_30) {
      int _33 = ConvertData_424 & 1;
      bool _34 = (_33 != 0);
      _36 = _34;
    } else {
      _36 = false;
    }
    bool _39 = (ConvertData_440 == 0);
    if (_39) {
      uint _42 = SV_DispatchThreadID.x << 1u;
      float _43 = t0.Load(int3(_42, (int)(SV_DispatchThreadID.y), 0));
      int _45 = _42 | 1;
      float _46 = t0.Load(int3(_45, (int)(SV_DispatchThreadID.y), 0));
      float _48 = max(_43.x, _46.x);
      bool _49 = (_48 == _46.x);
      if (_49) {
        _55 = _45;
        _56 = _48;
      } else {
        _55 = _42;
        _56 = _48;
      }
    } else {
      float _52 = t0.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0));
      _55 = (int)(SV_DispatchThreadID.x);
      _56 = _52.x;
    }
    float _57 = float((uint)_55);
    float _58 = float((uint)SV_DispatchThreadID.y);
    float _59 = _57 + 0.5f;
    float _60 = _58 + 0.5f;
    float _63 = _59 * ConvertData_384.z;
    float _64 = ConvertData_384.w * _60;
    float _71 = mad((ConvertData_064[2].z), _56, 0.0f);
    float _72 = (ConvertData_064[3].z) + _71;
    float _73 = mad((ConvertData_064[2].w), _56, 0.0f);
    float _74 = _73 + (ConvertData_064[3].w);
    float _75 = _72 / _74;
    u2[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = _75;
    bool _79 = (ConvertData_444 == 0);
    float4 _81 = t1.Load(int3(_55, (int)(SV_DispatchThreadID.y), 0));
    if (ConvertData_444 == 0) _81 = CloudNativeMotion(_81, _56, int2(_55, SV_DispatchThreadID.y));
    if (!_79) {
      bool _84 = (_81.w == 0.0f);
      if (!_84) {
        float _87 = _81.y * 2.0f;
        float _89 = _81.x * 2.0f;
        float _91 = _63 * 2.0f;
        float _92 = _91 + -1.0f;
        float _93 = _64 * 2.0f;
        float _94 = 1.0f - _93;
        float _115 = (ConvertData_128[0].x) * _92;
        float _116 = mad((ConvertData_128[1].x), _94, _115);
        float _117 = mad((ConvertData_128[2].x), _56, _116);
        float _118 = _117 + (ConvertData_128[3].x);
        float _119 = (ConvertData_128[0].y) * _92;
        float _120 = mad((ConvertData_128[1].y), _94, _119);
        float _121 = mad((ConvertData_128[2].y), _56, _120);
        float _122 = _121 + (ConvertData_128[3].y);
        float _123 = (ConvertData_128[0].z) * _92;
        float _124 = mad((ConvertData_128[1].z), _94, _123);
        float _125 = mad((ConvertData_128[2].z), _56, _124);
        float _126 = _125 + (ConvertData_128[3].z);
        float _127 = (ConvertData_128[0].w) * _92;
        float _128 = mad((ConvertData_128[1].w), _94, _127);
        float _129 = mad((ConvertData_128[2].w), _56, _128);
        float _130 = _129 + (ConvertData_128[3].w);
        float _131 = _118 / _130;
        float _132 = _122 / _130;
        float _133 = _126 / _130;
        float _134 = _92 - _89;
        float _135 = _87 + _94;
        float _136 = _56 - _81.z;
        float _157 = (ConvertData_192[0].x) * _134;
        float _158 = mad((ConvertData_192[1].x), _135, _157);
        float _159 = mad((ConvertData_192[2].x), _136, _158);
        float _160 = _159 + (ConvertData_192[3].x);
        float _161 = (ConvertData_192[0].y) * _134;
        float _162 = mad((ConvertData_192[1].y), _135, _161);
        float _163 = mad((ConvertData_192[2].y), _136, _162);
        float _164 = _163 + (ConvertData_192[3].y);
        float _165 = (ConvertData_192[0].z) * _134;
        float _166 = mad((ConvertData_192[1].z), _135, _165);
        float _167 = mad((ConvertData_192[2].z), _136, _166);
        float _168 = _167 + (ConvertData_192[3].z);
        float _169 = (ConvertData_192[0].w) * _134;
        float _170 = mad((ConvertData_192[1].w), _135, _169);
        float _171 = mad((ConvertData_192[2].w), _136, _170);
        float _172 = _171 + (ConvertData_192[3].w);
        float _173 = _160 / _172;
        float _174 = _164 / _172;
        float _175 = _168 / _172;
        float _176 = _173 - _131;
        float _177 = _174 - _132;
        float _178 = _175 - _133;
        _180 = _176;
        _181 = _177;
        _182 = _178;
      } else {
        _180 = 0.0f;
        _181 = 0.0f;
        _182 = 0.0f;
      }
      u0[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_180, _181, _182, 1.0f);
    } else {
      float _187 = -0.0f - _81.x;
      float _188 = -0.0f - _81.y;
      bool _189 = (_81.x >= 2.0f);
      bool _190 = (_81.y >= 2.0f);
      bool _191 = _189 || _190;
      [branch]
      if (_191) {
        float _193 = _63 * 2.0f;
        float _194 = _193 + -1.0f;
        float _195 = _64 * 2.0f;
        float _196 = 1.0f - _195;
        float _213 = (ConvertData_000[0].x) * _194;
        float _214 = mad((ConvertData_000[1].x), _196, _213);
        float _215 = mad((ConvertData_000[2].x), _56, _214);
        float _216 = _215 + (ConvertData_000[3].x);
        float _217 = (ConvertData_000[0].y) * _194;
        float _218 = mad((ConvertData_000[1].y), _196, _217);
        float _219 = mad((ConvertData_000[2].y), _56, _218);
        float _220 = _219 + (ConvertData_000[3].y);
        float _221 = (ConvertData_000[0].w) * _194;
        float _222 = mad((ConvertData_000[1].w), _196, _221);
        float _223 = mad((ConvertData_000[2].w), _56, _222);
        float _224 = _223 + (ConvertData_000[3].w);
        float _225 = _216 * 0.5f;
        float _226 = _220 * -0.5f;
        float _227 = _225 / _224;
        float _228 = _226 / _224;
        float _229 = 0.5f - _63;
        float _230 = _229 + _227;
        float _231 = 0.5f - _64;
        float _232 = _231 + _228;
        _234 = _230;
        _235 = _232;
      } else {
        _234 = _187;
        _235 = _188;
      }
      float _239 = ConvertData_384.x * _234;
      float _240 = ConvertData_384.y * _235;
      u0[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_239, _240, 0.0f, 0.0f);
    }
    bool _245 = (ConvertData_420 == 0);
    if (!_245) {
      float4 _248 = t3.Load(int3(_55, (int)(SV_DispatchThreadID.y), 0));
      _253 = _248.x;
      _254 = _248.y;
      _255 = _248.w;
    } else {
      _253 = 1.0f;
      _254 = 1.0f;
      _255 = 1.0f;
    }
    float _256 = _253 + -0.5f;
    float _257 = _254 + -0.5f;
    float _258 = _256 * 2.0f;
    float _259 = _257 * 2.0f;
    float _260 = dot(float2(_258, _259), float2(_258, _259));
    float _261 = 1.0f - _260;
    float _262 = saturate(_261);
    float _263 = sqrt(_262);
    float _264 = _263 * 0.5f;
    float _265 = _264 + 0.5f;
    float4 _267 = t2.Load(int3(_55, (int)(SV_DispatchThreadID.y), 0));
    float4 _273 = t5.Load(int3(_55, (int)(SV_DispatchThreadID.y), 0));
    float _275 = _273.w * 255.0f;
    float _276 = _275 + 0.5f;
    uint _277 = uint(_276);
    int _278 = _277 & 15;
    bool _279 = (_278 == 11);
    bool _280 = !_279;
    bool _281 = _36 && _280;
    if (_281) {
      int _284 = ConvertData_424 & 2;
      bool _285 = (_284 == 0);
      if (!_285) {
        float _301 = _267.w * _267.w;
        float _302 = _301 * _267.w;
        bool _303 = (_267.w < (ConvertData_320[0].w));
        if (_303) {
          float _309 = dot(float4((ConvertData_320[0].x), (ConvertData_320[1].x), (ConvertData_320[2].x), (ConvertData_320[3].x)), float4(_302, _301, _267.w, 1.0f));
          _318 = _309;
        } else {
          bool _312 = (_267.w < (ConvertData_320[1].w));
          if (_312) {
            float _314 = dot(float4((ConvertData_320[0].y), (ConvertData_320[1].y), (ConvertData_320[2].y), (ConvertData_320[3].y)), float4(_302, _301, _267.w, 1.0f));
            _318 = _314;
          } else {
            float _316 = dot(float4((ConvertData_320[0].z), (ConvertData_320[1].z), (ConvertData_320[2].z), (ConvertData_320[3].z)), float4(_302, _301, _267.w, 1.0f));
            _318 = _316;
          }
        }
        float _319 = _318 * 2.0f;
        float _320 = _319 + -1.0f;
        float _321 = abs(_320);
        float _322 = log2(_321);
        float _323 = _322 * 10.0f;
        float _324 = exp2(_323);
        float _325 = saturate(_324);
        bool _326 = (_318 > 0.5f);
        float _327 = float((bool)_326);
        float _328 = saturate(_318);
        float _329 = _327 - _328;
        float _330 = _329 * _325;
        float _331 = _330 + _328;
        float _332 = log2(_331);
        float _333 = _332 * (ConvertData_320[2].w);
        float _334 = exp2(_333);
        _336 = _334;
      } else {
        _336 = _267.w;
      }
    } else {
      _336 = _267.w;
    }
    bool _337 = !(_255 < 1.0f);
    bool _338 = _337 || _279;
    if (!_338) {
      float _341 = t4.Load(int3(_55, (int)(SV_DispatchThreadID.y), 0));
      float _345 = cb12_022x * _341.x;
      float _347 = _345 + cb12_022y;
      float _350 = _347 * cb12_021x;
      float _352 = _350 + cb12_021y;
      float _353 = 1.0f / _352;
      float _354 = max(_353, -3.4028234663852886e+38f);
      float _355 = min(_354, 3.4028234663852886e+38f);
      float _356 = _355 - _75;
      float _357 = _356 * 12.5f;
      float _358 = saturate(_357);
      float _359 = _358 * _358;
      if (_36) {
        float _363 = _75 * 0.019999999552965164f;
        float _364 = saturate(_363);
        float _365 = ConvertData_460 + -0.009999999776482582f;
        float _366 = max(0.009999999776482582f, _365);
        float _367 = _366 * _364;
        float _368 = _367 + 0.009999999776482582f;
        _370 = _368;
      } else {
        _370 = ConvertData_460;
      }
      float _371 = _253 - _267.x;
      float _372 = _254 - _267.y;
      float _373 = _265 - _267.z;
      float _374 = _359 * _371;
      float _375 = _359 * _372;
      float _376 = _359 * _373;
      float _377 = _374 + _267.x;
      float _378 = _375 + _267.y;
      float _379 = _376 + _267.z;
      float _380 = _370 - _336;
      float _381 = _380 * _359;
      float _382 = _381 + _336;
      _384 = _377;
      _385 = _378;
      _386 = _379;
      _387 = _382;
      _388 = _359;
    } else {
      _384 = _267.x;
      _385 = _267.y;
      _386 = _267.z;
      _387 = _336;
      _388 = 0.0f;
    }
    bool _389 = _36 || _279;
    if (!_389) {
      float _405 = _387 * _387;
      float _406 = _405 * _387;
      bool _407 = (_387 < (ConvertData_320[0].w));
      if (_407) {
        float _413 = dot(float4((ConvertData_320[0].x), (ConvertData_320[1].x), (ConvertData_320[2].x), (ConvertData_320[3].x)), float4(_406, _405, _387, 1.0f));
        _422 = _413;
      } else {
        bool _416 = (_387 < (ConvertData_320[1].w));
        if (_416) {
          float _418 = dot(float4((ConvertData_320[0].y), (ConvertData_320[1].y), (ConvertData_320[2].y), (ConvertData_320[3].y)), float4(_406, _405, _387, 1.0f));
          _422 = _418;
        } else {
          float _420 = dot(float4((ConvertData_320[0].z), (ConvertData_320[1].z), (ConvertData_320[2].z), (ConvertData_320[3].z)), float4(_406, _405, _387, 1.0f));
          _422 = _420;
        }
      }
      float _423 = _422 * 2.0f;
      float _424 = _423 + -1.0f;
      float _425 = abs(_424);
      float _426 = log2(_425);
      float _427 = _426 * 10.0f;
      float _428 = exp2(_427);
      float _429 = saturate(_428);
      bool _430 = (_422 > 0.5f);
      float _431 = float((bool)_430);
      float _432 = saturate(_422);
      float _433 = _431 - _432;
      float _434 = _433 * _429;
      float _435 = _434 + _432;
      float _436 = log2(_435);
      float _437 = _436 * (ConvertData_320[2].w);
      float _438 = exp2(_437);
      _440 = _438;
    } else {
      _440 = _387;
    }
    int _442 = ConvertData_424 & 8;
    bool _443 = (_442 == 0);
    if (!_443) {
      bool _445 = isfinite(_56);
      if (_445) {
        float _450 = cb12_022x * _56;
        float _451 = _450 + cb12_022y;
        bool _452 = !(_451 >= 0.9999990463256836f);
        if (_452) {
          float _454 = saturate(_388);
          float _455 = _454 * 255.0f;
          float _456 = round(_455);
          bool _457 = (_456 > 0.0f);
          if (!_457) {
            u2[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = cb12_022w;
          }
        } else {
          u2[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = cb12_022w;
        }
      } else {
        u2[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = cb12_022w;
      }
    }
    float _463 = _384 * 2.0f;
    float _464 = _385 * 2.0f;
    float _465 = _386 * 2.0f;
    float _466 = _463 + -1.0f;
    float _467 = _464 + -1.0f;
    float _468 = _465 + -1.0f;
    float _469 = dot(float3(_466, _467, _468), float3(_466, _467, _468));
    float _470 = rsqrt(_469);
    float _471 = _470 * _466;
    float _472 = _470 * _467;
    float _473 = _470 * _468;
    if (_279) {
      int _477 = ConvertData_424 & 4;
      bool _478 = (_477 == 0);
      if (!_478) {
        float2 _481 = t6.Load(int3(_55, (int)(SV_DispatchThreadID.y), 0));
        float _484 = _481.x * 2.0f;
        float _485 = _481.y * 2.0f;
        float _486 = _484 + -1.0f;
        float _487 = _485 + -1.0f;
        float _488 = abs(_486);
        float _489 = 1.0f - _488;
        float _490 = abs(_487);
        float _491 = _489 - _490;
        bool _492 = (_491 < 0.0f);
        if (_492) {
          float _494 = 1.0f - _490;
          bool _495 = (_486 >= 0.0f);
          float _496 = select(_495, 1.0f, -1.0f);
          bool _497 = (_487 >= 0.0f);
          float _498 = select(_497, 1.0f, -1.0f);
          float _499 = _496 * _494;
          float _500 = _498 * _489;
          _502 = _499;
          _503 = _500;
        } else {
          _502 = _486;
          _503 = _487;
        }
        float _504 = dot(float3(_502, _503, _491), float3(_502, _503, _491));
        float _505 = rsqrt(_504);
        float _506 = _505 * _502;
        float _507 = _505 * _503;
        float _508 = _505 * _491;
        float _533 = cb12_211x * _57;
        float _534 = mad(cb12_212x, _58, _533);
        float _535 = mad(cb12_213x, _56, _534);
        float _536 = _535 + cb12_214x;
        float _537 = cb12_211y * _57;
        float _538 = mad(cb12_212y, _58, _537);
        float _539 = mad(cb12_213y, _56, _538);
        float _540 = _539 + cb12_214y;
        float _541 = cb12_211z * _57;
        float _542 = mad(cb12_212z, _58, _541);
        float _543 = mad(cb12_213z, _56, _542);
        float _544 = _543 + cb12_214z;
        float _545 = cb12_211w * _57;
        float _546 = mad(cb12_212w, _58, _545);
        float _547 = mad(cb12_213w, _56, _546);
        float _548 = _547 + cb12_214w;
        float _549 = _536 / _548;
        float _550 = _540 / _548;
        float _551 = _544 / _548;
        float _552 = cb12_000x - _549;
        float _553 = cb12_000y - _550;
        float _554 = cb12_000z - _551;
        float _555 = dot(float3(_552, _553, _554), float3(_552, _553, _554));
        float _556 = rsqrt(_555);
        float _557 = _556 * _552;
        float _558 = _556 * _553;
        float _559 = _556 * _554;
        float _560 = _558 * _508;
        float _561 = _559 * _507;
        float _562 = _560 - _561;
        float _563 = _559 * _506;
        float _564 = _557 * _508;
        float _565 = _563 - _564;
        float _566 = _557 * _507;
        float _567 = _558 * _506;
        float _568 = _566 - _567;
        float _569 = dot(float3(_562, _565, _568), float3(_562, _565, _568));
        bool _570 = (_569 > 9.99999993922529e-09f);
        if (_570) {
          float _572 = rsqrt(_569);
          float _573 = _572 * _562;
          float _574 = _572 * _565;
          float _575 = _572 * _568;
          float _576 = _575 * _507;
          float _577 = _574 * _508;
          float _578 = _576 - _577;
          float _579 = _573 * _508;
          float _580 = _575 * _506;
          float _581 = _579 - _580;
          float _582 = _574 * _506;
          float _583 = _573 * _507;
          float _584 = _582 - _583;
          float _585 = dot(float3(_578, _581, _584), float3(_578, _581, _584));
          float _586 = rsqrt(_585);
          float _587 = _578 * _586;
          float _588 = _581 * _586;
          float _589 = _584 * _586;
          _591 = _587;
          _592 = _588;
          _593 = _589;
        } else {
          _591 = _471;
          _592 = _472;
          _593 = _473;
        }
      } else {
        _591 = _471;
        _592 = _472;
        _593 = _473;
      }
    } else {
      _591 = _471;
      _592 = _472;
      _593 = _473;
    }
    float _594 = abs(_593);
    float _595 = abs(_592);
    float _596 = max(_595, _594);
    float _597 = abs(_591);
    float _598 = max(_597, _596);
    float _599 = _591 / _598;
    float _600 = _592 / _598;
    float _601 = _593 / _598;
    float _602 = _599 * 0.5f;
    float _603 = _600 * 0.5f;
    float _604 = _601 * 0.5f;
    float _605 = _602 + 0.5f;
    float _606 = _603 + 0.5f;
    float _607 = _604 + 0.5f;
    u1[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_605, _606, _607, _440);
    u4[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(_384, _385, _386, _440);
    u3[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = _388;
  }
}
