#include "night_skylight.hlsli"

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


Texture2D<float4> t23 : register(t23);

Texture2D<float4> t0 : register(t0);

Texture2D<float> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

StructuredBuffer<uint> t5 : register(t5);

StructuredBuffer<uint> t7 : register(t7);

Texture2D<float4> t9 : register(t9);

Texture2D<float4> t11 : register(t11);

Texture2D<float4> t12 : register(t12);

Texture2D<float4> t14 : register(t14);

Texture2DArray<float> t15 : register(t15);

RWTexture2D<float3> u0 : register(u0);

cbuffer cb10 : register(b10) {
  row_major float4x4 Constants_000 : packoffset(c000.x);
  row_major float4x4 Constants_064 : packoffset(c004.x);
  row_major float4x4 Constants_128 : packoffset(c008.x);
  row_major float4x4 Constants_192 : packoffset(c012.x);
  row_major float4x4 Constants_256 : packoffset(c016.x);
  row_major float4x4 Constants_320 : packoffset(c020.x);
  int Constants_384 : packoffset(c024.x);
  int Constants_388 : packoffset(c024.y);
  int Constants_392 : packoffset(c024.z);
  int Constants_396 : packoffset(c024.w);
  float Constants_400 : packoffset(c025.x);
  float Constants_404 : packoffset(c025.y);
  float Constants_408 : packoffset(c025.z);
  float Constants_412 : packoffset(c025.w);
  float2 Constants_416 : packoffset(c026.x);
  float Constants_424 : packoffset(c026.z);
  float Constants_428 : packoffset(c026.w);
  float4 Constants_432 : packoffset(c027.x);
  float4 Constants_448 : packoffset(c028.x);
  float2 Constants_464 : packoffset(c029.x);
  float2 Constants_472 : packoffset(c029.z);
  float2 Constants_480 : packoffset(c030.x);
  int Constants_488 : packoffset(c030.z);
  int Constants_492 : packoffset(c030.w);
  float4 Constants_496 : packoffset(c031.x);
  float Constants_512 : packoffset(c032.x);
  float Constants_516 : packoffset(c032.y);
  int Constants_520 : packoffset(c032.z);
  int Constants_524 : packoffset(c032.w);
  float Constants_528 : packoffset(c033.x);
  int Constants_532 : packoffset(c033.y);
  int Constants_536 : packoffset(c033.z);
  int Constants_540 : packoffset(c033.w);
};

cbuffer cb12 : register(b12) {
  float4 cb12_raw[341] : packoffset(c0);
};

#define cb12_287w (cb12_raw[287].w)
#define cb12_022x (cb12_raw[22].x)
#define cb12_106x (cb12_raw[106].x)
#define cb12_022y (cb12_raw[22].y)
#define cb12_000z (cb12_raw[0].z)
#define cb12_188x (cb12_raw[188].x)
#define cb12_288y (cb12_raw[288].y)
#define cb12_100x (cb12_raw[100].x)
#define cb12_111x (asint(cb12_raw[111].x))
#define cb12_187x (cb12_raw[187].x)

SamplerState s11 : register(s11);

SamplerState s2 : register(s2);

[numthreads(8, 8, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  int _54;
  float _55;
  float _225;
  float _226;
  float _227;
  float _310;
  float _311;
  int _457;
  float _458;
  float _459;
  float _460;
  float _551;
  float _552;
  float _553;
  bool _555;
  float _556;
  float _557;
  float _558;
  float _626;
  float _656;
  float _657;
  float _658;
  float _659;
  int _671;
  int _689;
  int _691;
  float _741;
  float _818;
  float _819;
  float _820;
  float _821;
  float _882;
  float _889;
  int _900;
  float _901;
  float _902;
  float _903;
  float _904;
  float _959;
  float _1116;
  float _1117;
  float _1118;
  float _1119;
  float _1125;
  float _1126;
  float _1127;
  if (!((int)((uint)(int)(SV_DispatchThreadID.y) >= (uint)(int)(uint(Constants_432.y))) || (int)((uint)(int)(SV_DispatchThreadID.x) >= (uint)(int)(uint(Constants_432.x * 0.5f))))) {
    uint _31 = SV_DispatchThreadID.x << 1u;
    int _36 = ((Constants_384 ^ (int)(SV_DispatchThreadID.y)) & 1) | _31;
    bool _39 = (Constants_488 == 0);
    if (_39) {
      float _42 = t1.Load(int3(_31, (int)(SV_DispatchThreadID.y), 0));
      int _44 = _31 | 1;
      float _45 = t1.Load(int3(_44, (int)(SV_DispatchThreadID.y), 0));
      float _47 = max(_42.x, _45.x);
      if (_47 == _45.x) {
        _54 = _44;
        _55 = _47;
      } else {
        _54 = _31;
        _55 = _47;
      }
    } else {
      float _51 = t1.Load(int3(_36, (int)(SV_DispatchThreadID.y), 0));
      _54 = _36;
      _55 = _51.x;
    }
    if (!(((cb12_022x * _55) + cb12_022y) >= 1.0f)) {
      float _70 = Constants_448.z * (float((uint)_54) + 0.5f);
      float _71 = Constants_448.w * (float((uint)SV_DispatchThreadID.y) + 0.5f);
      float4 _73 = t11.Load(int3(_54, (int)(SV_DispatchThreadID.y), 0));
      float4 _79 = t2.Load(int3(((int)(_54 >> ((int)(uint)(_39)))), (int)(SV_DispatchThreadID.y), 0));
      float _84 = _79.x + -0.5f;
      float _85 = _79.y + -0.5f;
      float _86 = _79.z + -0.5f;
      float _88 = rsqrt(dot(float3(_84, _85, _86), float3(_84, _85, _86)));
      float _89 = _84 * _88;
      float _90 = _85 * _88;
      float _91 = _86 * _88;
      float _115 = (_70 * 2.0f) + -1.0f;
      float _116 = ((1.0f - _71) * 2.0f) + -1.0f;
      float _132 = mad(_55, (Constants_000[3].z), mad(_116, (Constants_000[3].y), ((Constants_000[3].x) * _115))) + (Constants_000[3].w);
      float _133 = (mad(_55, (Constants_000[0].z), mad(_116, (Constants_000[0].y), ((Constants_000[0].x) * _115))) + (Constants_000[0].w)) / _132;
      float _134 = (mad(_55, (Constants_000[1].z), mad(_116, (Constants_000[1].y), ((Constants_000[1].x) * _115))) + (Constants_000[1].w)) / _132;
      float _135 = (mad(_55, (Constants_000[2].z), mad(_116, (Constants_000[2].y), ((Constants_000[2].x) * _115))) + (Constants_000[2].w)) / _132;
      bool _136 = (_73.w < 1.0f);
      if (_136 && (int)(_73.w > 0.5f)) {
        if (!(_135 > cb12_000z)) {
          float _180 = mad(_55, (Constants_128[3].z), mad(_116, (Constants_128[3].y), ((Constants_128[3].x) * _115))) + (Constants_128[3].w);
          float _181 = (mad(_55, (Constants_128[0].z), mad(_116, (Constants_128[0].y), ((Constants_128[0].x) * _115))) + (Constants_128[0].w)) / _180;
          float _182 = (mad(_55, (Constants_128[1].z), mad(_116, (Constants_128[1].y), ((Constants_128[1].x) * _115))) + (Constants_128[1].w)) / _180;
          float _183 = (mad(_55, (Constants_128[2].z), mad(_116, (Constants_128[2].y), ((Constants_128[2].x) * _115))) + (Constants_128[2].w)) / _180;
          float _185 = rsqrt(dot(float3(_181, _182, _183), float3(_181, _182, _183)));
          float _200 = mad(_91, (Constants_192[0].z), mad(_90, (Constants_192[0].y), ((Constants_192[0].x) * _89)));
          float _203 = mad(_91, (Constants_192[1].z), mad(_90, (Constants_192[1].y), ((Constants_192[1].x) * _89)));
          float _206 = mad(_91, (Constants_192[2].z), mad(_90, (Constants_192[2].y), ((Constants_192[2].x) * _89)));
          float _209 = _203 * _203;
          if (!(abs(_206) > 0.0f)) {
            float _213 = sqrt(_209 + (_200 * _200));
            _225 = (_203 / _213);
            _226 = ((-0.0f - _200) / _213);
            _227 = 0.0f;
          } else {
            float _220 = sqrt((_206 * _206) + _209);
            _225 = 0.0f;
            _226 = ((-0.0f - _206) / _220);
            _227 = (_203 / _220);
          }
          float _230 = (_227 * _203) - (_226 * _206);
          float _233 = (_225 * _206) - (_227 * _200);
          float _236 = (_226 * _200) - (_225 * _203);
          float _238 = -0.0f - (_181 * _185);
          float _240 = -0.0f - (_182 * _185);
          float _242 = -0.0f - (_183 * _185);
          float _245 = mad(_242, _227, mad(_240, _226, (_225 * _238)));
          float _248 = mad(_242, _236, mad(_240, _233, (_230 * _238)));
          float _251 = mad(_242, _206, mad(_240, _203, (_200 * _238)));
          int _255 = t5[0];
          int _259 = ((_54 & 127) | (((int)(SV_DispatchThreadID.y << 7u)) & 16256)) << 3u;
          int _262 = t7[_259];
          float _269 = float((uint)((uint)(Constants_384 & 255))) * 1.6180340051651f;
          float _270 = ((float((uint)((uint)(_262 ^ _255))) + 0.5f) * 0.00390625f) + _269;
          float _274 = frac(abs(_270));
          float _276 = select((_270 >= (-0.0f - _270)), _274, (-0.0f - _274));
          int _278 = t5[1];
          int _281 = t7[(_259 | 1)];
          float _286 = ((float((uint)((uint)(_281 ^ _278))) + 0.5f) * 0.00390625f) + _269;
          float _290 = frac(abs(_286));
          float _293 = _245 * _79.w;
          float _294 = _248 * _79.w;
          float _296 = rsqrt(dot(float3(_293, _294, _251), float3(_293, _294, _251)));
          float _297 = _296 * _293;
          float _298 = _296 * _294;
          float _299 = _296 * _251;
          float _302 = (_297 * _297) + (_298 * _298);
          if (_302 > 0.0f) {
            float _305 = rsqrt(_302);
            _310 = (-0.0f - (_298 * _305));
            _311 = (_305 * _297);
          } else {
            _310 = 1.0f;
            _311 = 0.0f;
          }
          float _315 = sqrt(_276);
          float _316 = select((_286 >= (-0.0f - _286)), _290, (-0.0f - _290)) * 6.2831854820251465f;
          float _318 = cos(_316) * _315;
          float _321 = (_299 + 1.0f) * 0.5f;
          float _324 = 1.0f - (_318 * _318);
          float _329 = (sqrt(_324) * (1.0f - _321)) + ((_315 * _321) * sin(_316));
          float _332 = _329 * _299;
          float _339 = sqrt(max(0.0f, (_324 - (_329 * _329))));
          float _348 = (((_339 * _297) + (_318 * _310)) - (_332 * _311)) * _79.w;
          float _349 = (((_339 * _298) + (_318 * _311)) + (_332 * _310)) * _79.w;
          float _350 = max(0.0f, ((_329 * ((_311 * _297) - (_310 * _298))) + (_339 * _299)));
          float _352 = rsqrt(dot(float3(_348, _349, _350), float3(_348, _349, _350)));
          bool _356 = (_79.w < 9.999999747378752e-05f);
          float _357 = select(_356, 0.0f, (_348 * _352));
          float _358 = select(_356, 0.0f, (_349 * _352));
          float _359 = select(_356, 1.0f, (_352 * _350));
          float _360 = -0.0f - _245;
          float _361 = -0.0f - _248;
          float _362 = -0.0f - _251;
          float _364 = dot(float3(_360, _361, _362), float3(_357, _358, _359)) * 2.0f;
          float _368 = _360 - (_357 * _364);
          float _369 = _361 - (_358 * _364);
          float _370 = _362 - (_364 * _359);
          float _400 = mad(_370, _200, mad(_369, _230, (_368 * _225))) + _181;
          float _401 = mad(_370, _203, mad(_369, _233, (_368 * _226))) + _182;
          float _402 = mad(_370, _206, mad(_369, _236, (_368 * _227))) + _183;
          float _418 = mad(_402, (Constants_064[3].z), mad(_401, (Constants_064[3].y), ((Constants_064[3].x) * _400))) + (Constants_064[3].w);
          float _426 = (((mad(_402, (Constants_064[0].z), mad(_401, (Constants_064[0].y), ((Constants_064[0].x) * _400))) + (Constants_064[0].w)) / _418) * 0.5f) + (0.5f - _70);
          float _427 = (0.5f - (((mad(_402, (Constants_064[1].z), mad(_401, (Constants_064[1].y), ((Constants_064[1].x) * _400))) + (Constants_064[1].w)) / _418) * 0.5f)) - _71;
          float _433 = max(sqrt((_427 * _427) + (_426 * _426)), 9.999999974752427e-07f);
          float _435 = _427 / _433;
          float _436 = (((mad(_402, (Constants_064[2].z), mad(_401, (Constants_064[2].y), ((Constants_064[2].x) * _400))) + (Constants_064[2].w)) / _418) - _55) / _433;
          float _439 = saturate((_426 / _433) + _70) - _70;
          float _442 = _439 * 0.015384615398943424f;
          float _443 = _435 * 0.015384615398943424f;
          float _444 = _436 * 0.015384615398943424f;
          float _445 = _276 + 0.25f;
          float _454 = max((abs(_444) * 2.0f), 9.99999993922529e-09f);
          float _455 = -0.0f - _454;
          _457 = 0;
          _458 = ((_444 * _445) + _55);
          _459 = ((_443 * _445) + _71);
          _460 = ((_442 * _445) + _70);
          while(true) {
            if ((int)(abs(_460 + -0.5f) < 0.5f) && (int)(abs(_459 + -0.5f) < 0.5f)) {
              float _484 = t1.Load(int3(int(_460 * Constants_448.x), int(_459 * Constants_448.y), 0));
              float _490 = t1.Load(int3(int((_460 + _442) * Constants_448.x), int((_459 + _443) * Constants_448.y), 0));
              float _496 = t1.Load(int3(int((_460 + (_439 * 0.03076923079788685f)) * Constants_448.x), int((_459 + (_435 * 0.03076923079788685f)) * Constants_448.y), 0));
              float _502 = t1.Load(int3(int((_460 + (_439 * 0.04615384712815285f)) * Constants_448.x), int((_459 + (_435 * 0.04615384712815285f)) * Constants_448.y), 0));
              float _506 = _458 + _444;
              float _507 = _458 + (_436 * 0.03076923079788685f);
              float _508 = _458 + (_436 * 0.04615384712815285f);
              bool _521 = (abs((_455 - _458) + _484.x) < _454);
              bool _523 = (abs((_455 - _507) + _496.x) < _454);
              bool _525 = _521 || (int)(abs((_455 - _506) + _490.x) < _454);
              [branch]
              if (!(((int)(_525 || _523)) || (int)(abs((_455 - _508) + _502.x) < _454))) {
                float _532 = _460 + (_439 * 0.0615384615957737f);
                float _533 = _459 + (_435 * 0.0615384615957737f);
                float _534 = _458 + (_436 * 0.0615384615957737f);
                int _535 = _457 + 4;
                if ((uint)_535 < (uint)64) {
                  _457 = _535;
                  _458 = _534;
                  _459 = _533;
                  _460 = _532;
                  continue;
                } else {
                  _551 = _532;
                  _552 = _533;
                  _553 = _534;
                  _555 = true;
                  _556 = _551;
                  _557 = _552;
                  _558 = _553;
                }
              } else {
                bool _541 = _525 || ((int)(!_523));
                float _544 = select(_541, select(_525, select(_521, 0.0f, 1.0f), 3.0f), 2.0f);
                _555 = false;
                _556 = ((_544 * _442) + _460);
                _557 = ((_544 * _443) + _459);
                _558 = select(_541, select(_525, select(_521, _458, _506), _508), _507);
              }
            } else {
              _551 = _460;
              _552 = _459;
              _553 = _458;
              _555 = true;
              _556 = _551;
              _557 = _552;
              _558 = _553;
            }
            float _565 = ((_556 - _70) * _433) + _70;
            float _566 = ((_557 - _71) * _433) + _71;
            float _567 = ((_558 - _55) * _433) + _55;
            float _571 = (_565 * 2.0f) + -1.0f;
            float _572 = ((1.0f - _566) * 2.0f) + -1.0f;
            float _588 = mad(_567, (Constants_000[3].z), mad(_572, (Constants_000[3].y), (_571 * (Constants_000[3].x)))) + (Constants_000[3].w);
            float _592 = ((mad(_567, (Constants_000[0].z), mad(_572, (Constants_000[0].y), (_571 * (Constants_000[0].x)))) + (Constants_000[0].w)) / _588) - _133;
            float _593 = ((mad(_567, (Constants_000[1].z), mad(_572, (Constants_000[1].y), (_571 * (Constants_000[1].x)))) + (Constants_000[1].w)) / _588) - _134;
            float _594 = ((mad(_567, (Constants_000[2].z), mad(_572, (Constants_000[2].y), (_571 * (Constants_000[2].x)))) + (Constants_000[2].w)) / _588) - _135;
            int _597 = int(_556 * Constants_448.x);
            int _598 = int(_557 * Constants_448.y);
            float4 _599 = t11.Load(int3(_597, _598, 0));
            if (!(_555 || ((int)(((int)(_136 && (int)(_599.w < 1.0f))) || ((int)((int)(abs(_556 + -0.5f) > 0.5f) || (int)(abs(_557 + -0.5f) > 0.5f))))))) {
              if (!((int)(_565 < 0.0f) || (int)(_566 < 0.0f))) {
                if (!((int)(_565 > 1.0f) || (int)(_566 > 1.0f))) {
                  _626 = min(max(((_79.w + -0.800000011920929f) * -5.000000476837158f), 0.0f), 1.0f);
                } else {
                  _626 = 0.0f;
                }
              } else {
                _626 = 0.0f;
              }
            } else {
              _626 = 0.0f;
            }
            float _631 = rsqrt(dot(float3(_592, _593, _594), float3(_592, _593, _594)));
            float _632 = _631 * _592;
            float _633 = _631 * _593;
            float _634 = _631 * _594;
            if (_626 > 0.0f) {
              float4 _644 = t0.Load(int3(int(float((int)(_597))), int(float((int)(_598))), 0));
              if (!isnan(_644.x) && !isnan(_644.y)) {
                bool _650 = (!isnan(_644.z) && !isnan(0.0f));
                _656 = select(_650, _626, 0.0f);
                _657 = select(_650, _644.x, 0.0f);
                _658 = select(_650, _644.y, 0.0f);
                _659 = select(_650, _644.z, 0.0f);
              } else {
                _656 = 0.0f;
                _657 = 0.0f;
                _658 = 0.0f;
                _659 = 0.0f;
              }
            } else {
              _656 = _626;
              _657 = 0.0f;
              _658 = 0.0f;
              _659 = 0.0f;
            }
            bool _660 = (_656 < 1.0f);
            if (!_136) {
              if (_660) {
                float4 _749 = t12.Load(int3(int(float((int)(_54))), int(float((int)((int)(SV_DispatchThreadID.y)))), 0));
                float _752 = float((bool)((uint)(_136 && (int)(_73.z > 0.5f))));
                float _758 = min(max(max(((_79.w * _79.w) * 10.5f), 0.0f), 0.0f), 5.0f);
                _900 = 1;
                _901 = 0.0f;
                _902 = 0.0f;
                _903 = 0.0f;
                _904 = 9.999999747378752e-06f;
                while(true) {
                  int _905 = _900 * 12;
                  float _941 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].x), _135, mad((cb12_raw[(_905 + 103)].x), _134, ((cb12_raw[(_905 + 102)].x) * _133))) + (cb12_raw[(_905 + 105)].x));
                  float _942 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].y), _135, mad((cb12_raw[(_905 + 103)].y), _134, ((cb12_raw[(_905 + 102)].y) * _133))) + (cb12_raw[(_905 + 105)].y));
                  float _943 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].z), _135, mad((cb12_raw[(_905 + 103)].z), _134, ((cb12_raw[(_905 + 102)].z) * _133))) + (cb12_raw[(_905 + 105)].z));
                  int _947 = asint((cb12_raw[(_905 + 106)].y));
                  [branch]
                  if (!(_749.z == -1.0f)) {
                    _959 = (select(((_947 & 1) != 0), 1.0f, _749.z) * select(((_947 & 2) != 0), 1.0f, (1.0f - _749.z)));
                  } else {
                    _959 = 1.0f;
                  }
                  if (((int)(((int)((int)(_941 > 0.0f) && (int)(_942 > 0.0f))) && (int)(_943 > 0.0f))) && (int)(_959 > 0.0f)) {
                    float _987 = ((((_959 * (1.0f - _904)) * saturate((cb12_raw[(_905 + 101)].x) * _941)) * saturate((cb12_raw[(_905 + 101)].y) * _942)) * saturate((cb12_raw[(_905 + 101)].z) * _943)) * (cb12_raw[(_905 + 100)].x);
                    float _990 = _987 * (cb12_raw[(_905 + 106)].x);
                    float _1035 = 1.0f / mad((cb12_raw[(_905 + 109)].x), _634, mad((cb12_raw[(_905 + 108)].x), _633, ((cb12_raw[(_905 + 107)].x) * _632)));
                    float _1036 = 1.0f / mad((cb12_raw[(_905 + 109)].y), _634, mad((cb12_raw[(_905 + 108)].y), _633, ((cb12_raw[(_905 + 107)].y) * _632)));
                    float _1037 = 1.0f / mad((cb12_raw[(_905 + 109)].z), _634, mad((cb12_raw[(_905 + 108)].z), _633, ((cb12_raw[(_905 + 107)].z) * _632)));
                    float _1038 = _1035 * (mad((cb12_raw[(_905 + 109)].x), _135, mad((cb12_raw[(_905 + 108)].x), _134, ((cb12_raw[(_905 + 107)].x) * _133))) + (cb12_raw[(_905 + 110)].x));
                    float _1039 = _1036 * (mad((cb12_raw[(_905 + 109)].y), _135, mad((cb12_raw[(_905 + 108)].y), _134, ((cb12_raw[(_905 + 107)].y) * _133))) + (cb12_raw[(_905 + 110)].y));
                    float _1040 = _1037 * (mad((cb12_raw[(_905 + 109)].z), _135, mad((cb12_raw[(_905 + 108)].z), _134, ((cb12_raw[(_905 + 107)].z) * _133))) + (cb12_raw[(_905 + 110)].z));
                    float _1054 = min(max((_1035 - _1038), ((-0.0f - _1035) - _1038)), min(max((_1036 - _1039), ((-0.0f - _1036) - _1039)), max((_1037 - _1040), ((-0.0f - _1037) - _1040))));
                    float _1059 = (_1054 * _632) + (_133 - (cb12_raw[(_905 + 100)].y));
                    float _1061 = (_1054 * _633) + (_134 - (cb12_raw[(_905 + 100)].z));
                    float _1063 = (_1054 * _634) + (_135 - (cb12_raw[(_905 + 100)].w));
                    float _1065 = rsqrt(dot(float3(_1059, _1061, _1063), float3(_1059, _1061, _1063)));
                    float _1066 = _1059 * _1065;
                    float _1067 = _1061 * _1065;
                    float _1068 = _1063 * _1065;
                    bool _1072 = (_1068 < 0.0f);
                    float _1078 = min(max((1.0f / (1.0f - _1068)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                    float _1086 = min(max((1.0f / (_1068 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                    float4 _1105 = t23.SampleLevel(s11, float2((((float((bool)_1072) + 0.1666666716337204f) + ((select(_1072, ((_1066 * 0.5f) * _1078), ((_1066 * -0.5f) * _1086)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(asint(cb12_raw[(_905 + 111)].x))) + 0.1666666716337204f) + ((select(_1072, ((_1067 * -0.5f) * _1078), ((_1067 * 0.5f) * _1086)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _758);
                    _1116 = (_987 + _904);
                    _1117 = ((_1105.x * _990) + _903);
                    _1118 = ((_1105.y * _990) + _902);
                    _1119 = ((_1105.z * _990) + _901);
                  } else {
                    _1116 = _904;
                    _1117 = _903;
                    _1118 = _902;
                    _1119 = _901;
                  }
                  int _1120 = _900 + 1;
                  bool _1122 = (_1116 < 0.9990000128746033f);
                  if ((int)((uint)_1120 < (uint)7) && _1122) {
                    _900 = _1120;
                    _901 = _1119;
                    _902 = _1118;
                    _903 = _1117;
                    _904 = _1116;
                    continue;
                  }
                  while(true) {
                    float _763 = _632 * -0.5f;
                    float _764 = _633 * 0.5f;
                    [branch]
                    if (_1122) {
                      float _769 = cb12_100x * (1.0f - _1116);
                      float _773 = _769 * cb12_106x;
                      bool _776 = (_634 < 0.0f);
                      float _782 = min(max((1.0f / (1.0f - _634)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                      float _788 = min(max((1.0f / (_634 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                      float4 _807 = t23.SampleLevel(s11, float2((((float((bool)_776) + 0.1666666716337204f) + ((select(_776, ((_632 * 0.5f) * _782), (_788 * _763)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(cb12_111x)) + 0.1666666716337204f) + ((select(_776, ((_633 * -0.5f) * _782), (_788 * _764)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _758);
                      _818 = (_769 + _1116);
                      _819 = ((_807.x * _773) + _1117);
                      _820 = ((_807.y * _773) + _1118);
                      _821 = ((_807.z * _773) + _1119);
                    } else {
                      _818 = _1116;
                      _819 = _1117;
                      _820 = _1118;
                      _821 = _1119;
                    }
                    float _822 = 1.0f / _818;
                    float _823 = _822 * _819;
                    float _824 = _822 * _820;
                    float _825 = _822 * _821;
                    bool _828 = (int)(!isnan(_823) && !isnan(_824)) && (int)(!isnan(_825) && !isnan(0.0f));
                    float _829 = select(_828, select((((_558 * cb12_022x) + cb12_022y) >= 1.0f), _752, (_749.z * _752)), 1.0f);
                    float _842 = min(max((1.0f / (abs(_634) + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                    float4 _859 = t9.SampleLevel(s2, float2((min(max((((_842 * _763) + 0.5f) * Constants_496.x), 0.5f), (Constants_496.x + -0.5f)) / Constants_496.z), (min(max((((_842 * _764) + 0.5f) * Constants_496.y), 0.5f), (Constants_496.y + -0.5f)) / Constants_496.w)), 0.0f);
                    float _866 = 1.0f - _829;
                    if (!_136) {
                      _882 = saturate((cb12_187x * _749.x) + cb12_188x);
                    } else {
                      _882 = 1.0f;
                    }
                    if (_749.z < 0.9900000095367432f) {
                      _889 = cb12_287w;
                    } else {
                      _889 = 1.0f;
                    }
                    float _895 = exp2((cb12_288y * _889) * log2(_882 * _749.w));
                    _1125 = (_895 * ((_859.x * _829) + (_866 * select(_828, _823, 0.0f))));
                    _1126 = (_895 * ((_859.y * _829) + (_866 * select(_828, _824, 0.0f))));
                    _1127 = (_895 * ((_859.z * _829) + (_866 * select(_828, _825, 0.0f))));
                    break;
                  }
                  break;
                }
              } else {
                _1125 = 0.0f;
                _1126 = 0.0f;
                _1127 = 0.0f;
              }
            } else {
              uint4 _664 = 0u; t14.GetDimensions(0u, _664.x, _664.y, _664.w);
              int _667 = int(float((int)((int)(_664.x))));
              if ((int)_667 > (int)0) {
                _671 = 0;
                while(true) {
                  float4 _673 = t14.Load(int3(_671, 0, 0));
                  if (!(((int)((int)(_133 > _673.x) && (int)(_133 < _673.z))) && ((int)((int)(_134 > _673.y) && (int)(_134 < _673.w))))) {
                    int _686 = _671 + 1;
                    if ((int)_686 < (int)_667) {
                      _671 = _686;
                      continue;
                    } else {
                      _689 = -1;
                    }
                  } else {
                    _689 = _671;
                  }
                  _691 = _689;
                  break;
                }
              } else {
                _691 = -1;
              }
              if (!((int)_691 < (int)0)) {
                float4 _695 = t14.Load(int3(_691, 0, 0));
                float4 _700 = t14.Load(int3(_691, 1, 0));
                uint4 _706 = 0u; t15.GetDimensions(0u, _706.x, _706.y, _706.z, _706.w);
                float _731 = t15.SampleLevel(s2, float3(((((0.5f / float((int)((int)(_706.x)))) + abs((_133 - _695.x) / (_695.z - _695.x))) * (_700.z - _700.x)) + _700.x), ((((0.5f / float((int)((int)(_706.y)))) + abs((_134 - _695.y) / (_695.w - _695.y))) * (_700.w - _700.y)) + _700.y), float((int)(_691))), 0.0f);
                _741 = ((Constants_512 + ((Constants_516 - Constants_512) * _731.x)) + -1.5f);
              } else {
                _741 = -11.5f;
              }
              if (!((int)(_135 < _741) || ((int)(!_660)))) {
                float4 _749 = t12.Load(int3(int(float((int)(_54))), int(float((int)((int)(SV_DispatchThreadID.y)))), 0));
                float _752 = float((bool)((uint)(_136 && (int)(_73.z > 0.5f))));
                float _758 = min(max(max(((_79.w * _79.w) * 10.5f), 0.0f), 0.0f), 5.0f);
                _900 = 1;
                _901 = 0.0f;
                _902 = 0.0f;
                _903 = 0.0f;
                _904 = 9.999999747378752e-06f;
                while(true) {
                  int _905 = _900 * 12;
                  float _941 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].x), _135, mad((cb12_raw[(_905 + 103)].x), _134, ((cb12_raw[(_905 + 102)].x) * _133))) + (cb12_raw[(_905 + 105)].x));
                  float _942 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].y), _135, mad((cb12_raw[(_905 + 103)].y), _134, ((cb12_raw[(_905 + 102)].y) * _133))) + (cb12_raw[(_905 + 105)].y));
                  float _943 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].z), _135, mad((cb12_raw[(_905 + 103)].z), _134, ((cb12_raw[(_905 + 102)].z) * _133))) + (cb12_raw[(_905 + 105)].z));
                  int _947 = asint((cb12_raw[(_905 + 106)].y));
                  [branch]
                  if (!(_749.z == -1.0f)) {
                    _959 = (select(((_947 & 1) != 0), 1.0f, _749.z) * select(((_947 & 2) != 0), 1.0f, (1.0f - _749.z)));
                  } else {
                    _959 = 1.0f;
                  }
                  if (((int)(((int)((int)(_941 > 0.0f) && (int)(_942 > 0.0f))) && (int)(_943 > 0.0f))) && (int)(_959 > 0.0f)) {
                    float _987 = ((((_959 * (1.0f - _904)) * saturate((cb12_raw[(_905 + 101)].x) * _941)) * saturate((cb12_raw[(_905 + 101)].y) * _942)) * saturate((cb12_raw[(_905 + 101)].z) * _943)) * (cb12_raw[(_905 + 100)].x);
                    float _990 = _987 * (cb12_raw[(_905 + 106)].x);
                    float _1035 = 1.0f / mad((cb12_raw[(_905 + 109)].x), _634, mad((cb12_raw[(_905 + 108)].x), _633, ((cb12_raw[(_905 + 107)].x) * _632)));
                    float _1036 = 1.0f / mad((cb12_raw[(_905 + 109)].y), _634, mad((cb12_raw[(_905 + 108)].y), _633, ((cb12_raw[(_905 + 107)].y) * _632)));
                    float _1037 = 1.0f / mad((cb12_raw[(_905 + 109)].z), _634, mad((cb12_raw[(_905 + 108)].z), _633, ((cb12_raw[(_905 + 107)].z) * _632)));
                    float _1038 = _1035 * (mad((cb12_raw[(_905 + 109)].x), _135, mad((cb12_raw[(_905 + 108)].x), _134, ((cb12_raw[(_905 + 107)].x) * _133))) + (cb12_raw[(_905 + 110)].x));
                    float _1039 = _1036 * (mad((cb12_raw[(_905 + 109)].y), _135, mad((cb12_raw[(_905 + 108)].y), _134, ((cb12_raw[(_905 + 107)].y) * _133))) + (cb12_raw[(_905 + 110)].y));
                    float _1040 = _1037 * (mad((cb12_raw[(_905 + 109)].z), _135, mad((cb12_raw[(_905 + 108)].z), _134, ((cb12_raw[(_905 + 107)].z) * _133))) + (cb12_raw[(_905 + 110)].z));
                    float _1054 = min(max((_1035 - _1038), ((-0.0f - _1035) - _1038)), min(max((_1036 - _1039), ((-0.0f - _1036) - _1039)), max((_1037 - _1040), ((-0.0f - _1037) - _1040))));
                    float _1059 = (_1054 * _632) + (_133 - (cb12_raw[(_905 + 100)].y));
                    float _1061 = (_1054 * _633) + (_134 - (cb12_raw[(_905 + 100)].z));
                    float _1063 = (_1054 * _634) + (_135 - (cb12_raw[(_905 + 100)].w));
                    float _1065 = rsqrt(dot(float3(_1059, _1061, _1063), float3(_1059, _1061, _1063)));
                    float _1066 = _1059 * _1065;
                    float _1067 = _1061 * _1065;
                    float _1068 = _1063 * _1065;
                    bool _1072 = (_1068 < 0.0f);
                    float _1078 = min(max((1.0f / (1.0f - _1068)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                    float _1086 = min(max((1.0f / (_1068 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                    float4 _1105 = t23.SampleLevel(s11, float2((((float((bool)_1072) + 0.1666666716337204f) + ((select(_1072, ((_1066 * 0.5f) * _1078), ((_1066 * -0.5f) * _1086)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(asint(cb12_raw[(_905 + 111)].x))) + 0.1666666716337204f) + ((select(_1072, ((_1067 * -0.5f) * _1078), ((_1067 * 0.5f) * _1086)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _758);
                    _1116 = (_987 + _904);
                    _1117 = ((_1105.x * _990) + _903);
                    _1118 = ((_1105.y * _990) + _902);
                    _1119 = ((_1105.z * _990) + _901);
                  } else {
                    _1116 = _904;
                    _1117 = _903;
                    _1118 = _902;
                    _1119 = _901;
                  }
                  int _1120 = _900 + 1;
                  bool _1122 = (_1116 < 0.9990000128746033f);
                  if ((int)((uint)_1120 < (uint)7) && _1122) {
                    _900 = _1120;
                    _901 = _1119;
                    _902 = _1118;
                    _903 = _1117;
                    _904 = _1116;
                    continue;
                  }
                  while(true) {
                    float _763 = _632 * -0.5f;
                    float _764 = _633 * 0.5f;
                    [branch]
                    if (_1122) {
                      float _769 = cb12_100x * (1.0f - _1116);
                      float _773 = _769 * cb12_106x;
                      bool _776 = (_634 < 0.0f);
                      float _782 = min(max((1.0f / (1.0f - _634)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                      float _788 = min(max((1.0f / (_634 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                      float4 _807 = t23.SampleLevel(s11, float2((((float((bool)_776) + 0.1666666716337204f) + ((select(_776, ((_632 * 0.5f) * _782), (_788 * _763)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(cb12_111x)) + 0.1666666716337204f) + ((select(_776, ((_633 * -0.5f) * _782), (_788 * _764)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _758);
                      _818 = (_769 + _1116);
                      _819 = ((_807.x * _773) + _1117);
                      _820 = ((_807.y * _773) + _1118);
                      _821 = ((_807.z * _773) + _1119);
                    } else {
                      _818 = _1116;
                      _819 = _1117;
                      _820 = _1118;
                      _821 = _1119;
                    }
                    float _822 = 1.0f / _818;
                    float _823 = _822 * _819;
                    float _824 = _822 * _820;
                    float _825 = _822 * _821;
                    bool _828 = (int)(!isnan(_823) && !isnan(_824)) && (int)(!isnan(_825) && !isnan(0.0f));
                    float _829 = select(_828, select((((_558 * cb12_022x) + cb12_022y) >= 1.0f), _752, (_749.z * _752)), 1.0f);
                    float _842 = min(max((1.0f / (abs(_634) + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                    float4 _859 = t9.SampleLevel(s2, float2((min(max((((_842 * _763) + 0.5f) * Constants_496.x), 0.5f), (Constants_496.x + -0.5f)) / Constants_496.z), (min(max((((_842 * _764) + 0.5f) * Constants_496.y), 0.5f), (Constants_496.y + -0.5f)) / Constants_496.w)), 0.0f);
                    float _866 = 1.0f - _829;
                    if (!_136) {
                      _882 = saturate((cb12_187x * _749.x) + cb12_188x);
                    } else {
                      _882 = 1.0f;
                    }
                    if (_749.z < 0.9900000095367432f) {
                      _889 = cb12_287w;
                    } else {
                      _889 = 1.0f;
                    }
                    float _895 = exp2((cb12_288y * _889) * log2(_882 * _749.w));
                    _1125 = (_895 * ((_859.x * _829) + (_866 * select(_828, _823, 0.0f))));
                    _1126 = (_895 * ((_859.y * _829) + (_866 * select(_828, _824, 0.0f))));
                    _1127 = (_895 * ((_859.z * _829) + (_866 * select(_828, _825, 0.0f))));
                    break;
                  }
                  break;
                }
              } else {
                _1125 = 0.0f;
                _1126 = 0.0f;
                _1127 = 0.0f;
              }
            }
            // Fade only the environment/sky fallback. Keep traced scene reflections.
            float _1131 = (1.0f - _656) * WitcherNightSkylight(cb12_raw[185].w);
            u0[int2(((uint)(_54) >> 1), (int)(SV_DispatchThreadID.y))] = float3(((_1125 * _1131) + (_657 * _656)), ((_1126 * _1131) + (_658 * _656)), ((_1127 * _1131) + (_659 * _656)));
            break;
          }
        }
      } else {
        float _180 = mad(_55, (Constants_128[3].z), mad(_116, (Constants_128[3].y), ((Constants_128[3].x) * _115))) + (Constants_128[3].w);
        float _181 = (mad(_55, (Constants_128[0].z), mad(_116, (Constants_128[0].y), ((Constants_128[0].x) * _115))) + (Constants_128[0].w)) / _180;
        float _182 = (mad(_55, (Constants_128[1].z), mad(_116, (Constants_128[1].y), ((Constants_128[1].x) * _115))) + (Constants_128[1].w)) / _180;
        float _183 = (mad(_55, (Constants_128[2].z), mad(_116, (Constants_128[2].y), ((Constants_128[2].x) * _115))) + (Constants_128[2].w)) / _180;
        float _185 = rsqrt(dot(float3(_181, _182, _183), float3(_181, _182, _183)));
        float _200 = mad(_91, (Constants_192[0].z), mad(_90, (Constants_192[0].y), ((Constants_192[0].x) * _89)));
        float _203 = mad(_91, (Constants_192[1].z), mad(_90, (Constants_192[1].y), ((Constants_192[1].x) * _89)));
        float _206 = mad(_91, (Constants_192[2].z), mad(_90, (Constants_192[2].y), ((Constants_192[2].x) * _89)));
        float _209 = _203 * _203;
        if (!(abs(_206) > 0.0f)) {
          float _213 = sqrt(_209 + (_200 * _200));
          _225 = (_203 / _213);
          _226 = ((-0.0f - _200) / _213);
          _227 = 0.0f;
        } else {
          float _220 = sqrt((_206 * _206) + _209);
          _225 = 0.0f;
          _226 = ((-0.0f - _206) / _220);
          _227 = (_203 / _220);
        }
        float _230 = (_227 * _203) - (_226 * _206);
        float _233 = (_225 * _206) - (_227 * _200);
        float _236 = (_226 * _200) - (_225 * _203);
        float _238 = -0.0f - (_181 * _185);
        float _240 = -0.0f - (_182 * _185);
        float _242 = -0.0f - (_183 * _185);
        float _245 = mad(_242, _227, mad(_240, _226, (_225 * _238)));
        float _248 = mad(_242, _236, mad(_240, _233, (_230 * _238)));
        float _251 = mad(_242, _206, mad(_240, _203, (_200 * _238)));
        int _255 = t5[0];
        int _259 = ((_54 & 127) | (((int)(SV_DispatchThreadID.y << 7u)) & 16256)) << 3u;
        int _262 = t7[_259];
        float _269 = float((uint)((uint)(Constants_384 & 255))) * 1.6180340051651f;
        float _270 = ((float((uint)((uint)(_262 ^ _255))) + 0.5f) * 0.00390625f) + _269;
        float _274 = frac(abs(_270));
        float _276 = select((_270 >= (-0.0f - _270)), _274, (-0.0f - _274));
        int _278 = t5[1];
        int _281 = t7[(_259 | 1)];
        float _286 = ((float((uint)((uint)(_281 ^ _278))) + 0.5f) * 0.00390625f) + _269;
        float _290 = frac(abs(_286));
        float _293 = _245 * _79.w;
        float _294 = _248 * _79.w;
        float _296 = rsqrt(dot(float3(_293, _294, _251), float3(_293, _294, _251)));
        float _297 = _296 * _293;
        float _298 = _296 * _294;
        float _299 = _296 * _251;
        float _302 = (_297 * _297) + (_298 * _298);
        if (_302 > 0.0f) {
          float _305 = rsqrt(_302);
          _310 = (-0.0f - (_298 * _305));
          _311 = (_305 * _297);
        } else {
          _310 = 1.0f;
          _311 = 0.0f;
        }
        float _315 = sqrt(_276);
        float _316 = select((_286 >= (-0.0f - _286)), _290, (-0.0f - _290)) * 6.2831854820251465f;
        float _318 = cos(_316) * _315;
        float _321 = (_299 + 1.0f) * 0.5f;
        float _324 = 1.0f - (_318 * _318);
        float _329 = (sqrt(_324) * (1.0f - _321)) + ((_315 * _321) * sin(_316));
        float _332 = _329 * _299;
        float _339 = sqrt(max(0.0f, (_324 - (_329 * _329))));
        float _348 = (((_339 * _297) + (_318 * _310)) - (_332 * _311)) * _79.w;
        float _349 = (((_339 * _298) + (_318 * _311)) + (_332 * _310)) * _79.w;
        float _350 = max(0.0f, ((_329 * ((_311 * _297) - (_310 * _298))) + (_339 * _299)));
        float _352 = rsqrt(dot(float3(_348, _349, _350), float3(_348, _349, _350)));
        bool _356 = (_79.w < 9.999999747378752e-05f);
        float _357 = select(_356, 0.0f, (_348 * _352));
        float _358 = select(_356, 0.0f, (_349 * _352));
        float _359 = select(_356, 1.0f, (_352 * _350));
        float _360 = -0.0f - _245;
        float _361 = -0.0f - _248;
        float _362 = -0.0f - _251;
        float _364 = dot(float3(_360, _361, _362), float3(_357, _358, _359)) * 2.0f;
        float _368 = _360 - (_357 * _364);
        float _369 = _361 - (_358 * _364);
        float _370 = _362 - (_364 * _359);
        float _400 = mad(_370, _200, mad(_369, _230, (_368 * _225))) + _181;
        float _401 = mad(_370, _203, mad(_369, _233, (_368 * _226))) + _182;
        float _402 = mad(_370, _206, mad(_369, _236, (_368 * _227))) + _183;
        float _418 = mad(_402, (Constants_064[3].z), mad(_401, (Constants_064[3].y), ((Constants_064[3].x) * _400))) + (Constants_064[3].w);
        float _426 = (((mad(_402, (Constants_064[0].z), mad(_401, (Constants_064[0].y), ((Constants_064[0].x) * _400))) + (Constants_064[0].w)) / _418) * 0.5f) + (0.5f - _70);
        float _427 = (0.5f - (((mad(_402, (Constants_064[1].z), mad(_401, (Constants_064[1].y), ((Constants_064[1].x) * _400))) + (Constants_064[1].w)) / _418) * 0.5f)) - _71;
        float _433 = max(sqrt((_427 * _427) + (_426 * _426)), 9.999999974752427e-07f);
        float _435 = _427 / _433;
        float _436 = (((mad(_402, (Constants_064[2].z), mad(_401, (Constants_064[2].y), ((Constants_064[2].x) * _400))) + (Constants_064[2].w)) / _418) - _55) / _433;
        float _439 = saturate((_426 / _433) + _70) - _70;
        float _442 = _439 * 0.015384615398943424f;
        float _443 = _435 * 0.015384615398943424f;
        float _444 = _436 * 0.015384615398943424f;
        float _445 = _276 + 0.25f;
        float _454 = max((abs(_444) * 2.0f), 9.99999993922529e-09f);
        float _455 = -0.0f - _454;
        _457 = 0;
        _458 = ((_444 * _445) + _55);
        _459 = ((_443 * _445) + _71);
        _460 = ((_442 * _445) + _70);
        while(true) {
          if ((int)(abs(_460 + -0.5f) < 0.5f) && (int)(abs(_459 + -0.5f) < 0.5f)) {
            float _484 = t1.Load(int3(int(_460 * Constants_448.x), int(_459 * Constants_448.y), 0));
            float _490 = t1.Load(int3(int((_460 + _442) * Constants_448.x), int((_459 + _443) * Constants_448.y), 0));
            float _496 = t1.Load(int3(int((_460 + (_439 * 0.03076923079788685f)) * Constants_448.x), int((_459 + (_435 * 0.03076923079788685f)) * Constants_448.y), 0));
            float _502 = t1.Load(int3(int((_460 + (_439 * 0.04615384712815285f)) * Constants_448.x), int((_459 + (_435 * 0.04615384712815285f)) * Constants_448.y), 0));
            float _506 = _458 + _444;
            float _507 = _458 + (_436 * 0.03076923079788685f);
            float _508 = _458 + (_436 * 0.04615384712815285f);
            bool _521 = (abs((_455 - _458) + _484.x) < _454);
            bool _523 = (abs((_455 - _507) + _496.x) < _454);
            bool _525 = _521 || (int)(abs((_455 - _506) + _490.x) < _454);
            [branch]
            if (!(((int)(_525 || _523)) || (int)(abs((_455 - _508) + _502.x) < _454))) {
              float _532 = _460 + (_439 * 0.0615384615957737f);
              float _533 = _459 + (_435 * 0.0615384615957737f);
              float _534 = _458 + (_436 * 0.0615384615957737f);
              int _535 = _457 + 4;
              if ((uint)_535 < (uint)64) {
                _457 = _535;
                _458 = _534;
                _459 = _533;
                _460 = _532;
                continue;
              } else {
                _551 = _532;
                _552 = _533;
                _553 = _534;
                _555 = true;
                _556 = _551;
                _557 = _552;
                _558 = _553;
              }
            } else {
              bool _541 = _525 || ((int)(!_523));
              float _544 = select(_541, select(_525, select(_521, 0.0f, 1.0f), 3.0f), 2.0f);
              _555 = false;
              _556 = ((_544 * _442) + _460);
              _557 = ((_544 * _443) + _459);
              _558 = select(_541, select(_525, select(_521, _458, _506), _508), _507);
            }
          } else {
            _551 = _460;
            _552 = _459;
            _553 = _458;
            _555 = true;
            _556 = _551;
            _557 = _552;
            _558 = _553;
          }
          float _565 = ((_556 - _70) * _433) + _70;
          float _566 = ((_557 - _71) * _433) + _71;
          float _567 = ((_558 - _55) * _433) + _55;
          float _571 = (_565 * 2.0f) + -1.0f;
          float _572 = ((1.0f - _566) * 2.0f) + -1.0f;
          float _588 = mad(_567, (Constants_000[3].z), mad(_572, (Constants_000[3].y), (_571 * (Constants_000[3].x)))) + (Constants_000[3].w);
          float _592 = ((mad(_567, (Constants_000[0].z), mad(_572, (Constants_000[0].y), (_571 * (Constants_000[0].x)))) + (Constants_000[0].w)) / _588) - _133;
          float _593 = ((mad(_567, (Constants_000[1].z), mad(_572, (Constants_000[1].y), (_571 * (Constants_000[1].x)))) + (Constants_000[1].w)) / _588) - _134;
          float _594 = ((mad(_567, (Constants_000[2].z), mad(_572, (Constants_000[2].y), (_571 * (Constants_000[2].x)))) + (Constants_000[2].w)) / _588) - _135;
          int _597 = int(_556 * Constants_448.x);
          int _598 = int(_557 * Constants_448.y);
          float4 _599 = t11.Load(int3(_597, _598, 0));
          if (!(_555 || ((int)(((int)(_136 && (int)(_599.w < 1.0f))) || ((int)((int)(abs(_556 + -0.5f) > 0.5f) || (int)(abs(_557 + -0.5f) > 0.5f))))))) {
            if (!((int)(_565 < 0.0f) || (int)(_566 < 0.0f))) {
              if (!((int)(_565 > 1.0f) || (int)(_566 > 1.0f))) {
                _626 = min(max(((_79.w + -0.800000011920929f) * -5.000000476837158f), 0.0f), 1.0f);
              } else {
                _626 = 0.0f;
              }
            } else {
              _626 = 0.0f;
            }
          } else {
            _626 = 0.0f;
          }
          float _631 = rsqrt(dot(float3(_592, _593, _594), float3(_592, _593, _594)));
          float _632 = _631 * _592;
          float _633 = _631 * _593;
          float _634 = _631 * _594;
          if (_626 > 0.0f) {
            float4 _644 = t0.Load(int3(int(float((int)(_597))), int(float((int)(_598))), 0));
            if (!isnan(_644.x) && !isnan(_644.y)) {
              bool _650 = (!isnan(_644.z) && !isnan(0.0f));
              _656 = select(_650, _626, 0.0f);
              _657 = select(_650, _644.x, 0.0f);
              _658 = select(_650, _644.y, 0.0f);
              _659 = select(_650, _644.z, 0.0f);
            } else {
              _656 = 0.0f;
              _657 = 0.0f;
              _658 = 0.0f;
              _659 = 0.0f;
            }
          } else {
            _656 = _626;
            _657 = 0.0f;
            _658 = 0.0f;
            _659 = 0.0f;
          }
          bool _660 = (_656 < 1.0f);
          if (!_136) {
            if (_660) {
              float4 _749 = t12.Load(int3(int(float((int)(_54))), int(float((int)((int)(SV_DispatchThreadID.y)))), 0));
              float _752 = float((bool)((uint)(_136 && (int)(_73.z > 0.5f))));
              float _758 = min(max(max(((_79.w * _79.w) * 10.5f), 0.0f), 0.0f), 5.0f);
              _900 = 1;
              _901 = 0.0f;
              _902 = 0.0f;
              _903 = 0.0f;
              _904 = 9.999999747378752e-06f;
              while(true) {
                int _905 = _900 * 12;
                float _941 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].x), _135, mad((cb12_raw[(_905 + 103)].x), _134, ((cb12_raw[(_905 + 102)].x) * _133))) + (cb12_raw[(_905 + 105)].x));
                float _942 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].y), _135, mad((cb12_raw[(_905 + 103)].y), _134, ((cb12_raw[(_905 + 102)].y) * _133))) + (cb12_raw[(_905 + 105)].y));
                float _943 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].z), _135, mad((cb12_raw[(_905 + 103)].z), _134, ((cb12_raw[(_905 + 102)].z) * _133))) + (cb12_raw[(_905 + 105)].z));
                int _947 = asint((cb12_raw[(_905 + 106)].y));
                [branch]
                if (!(_749.z == -1.0f)) {
                  _959 = (select(((_947 & 1) != 0), 1.0f, _749.z) * select(((_947 & 2) != 0), 1.0f, (1.0f - _749.z)));
                } else {
                  _959 = 1.0f;
                }
                if (((int)(((int)((int)(_941 > 0.0f) && (int)(_942 > 0.0f))) && (int)(_943 > 0.0f))) && (int)(_959 > 0.0f)) {
                  float _987 = ((((_959 * (1.0f - _904)) * saturate((cb12_raw[(_905 + 101)].x) * _941)) * saturate((cb12_raw[(_905 + 101)].y) * _942)) * saturate((cb12_raw[(_905 + 101)].z) * _943)) * (cb12_raw[(_905 + 100)].x);
                  float _990 = _987 * (cb12_raw[(_905 + 106)].x);
                  float _1035 = 1.0f / mad((cb12_raw[(_905 + 109)].x), _634, mad((cb12_raw[(_905 + 108)].x), _633, ((cb12_raw[(_905 + 107)].x) * _632)));
                  float _1036 = 1.0f / mad((cb12_raw[(_905 + 109)].y), _634, mad((cb12_raw[(_905 + 108)].y), _633, ((cb12_raw[(_905 + 107)].y) * _632)));
                  float _1037 = 1.0f / mad((cb12_raw[(_905 + 109)].z), _634, mad((cb12_raw[(_905 + 108)].z), _633, ((cb12_raw[(_905 + 107)].z) * _632)));
                  float _1038 = _1035 * (mad((cb12_raw[(_905 + 109)].x), _135, mad((cb12_raw[(_905 + 108)].x), _134, ((cb12_raw[(_905 + 107)].x) * _133))) + (cb12_raw[(_905 + 110)].x));
                  float _1039 = _1036 * (mad((cb12_raw[(_905 + 109)].y), _135, mad((cb12_raw[(_905 + 108)].y), _134, ((cb12_raw[(_905 + 107)].y) * _133))) + (cb12_raw[(_905 + 110)].y));
                  float _1040 = _1037 * (mad((cb12_raw[(_905 + 109)].z), _135, mad((cb12_raw[(_905 + 108)].z), _134, ((cb12_raw[(_905 + 107)].z) * _133))) + (cb12_raw[(_905 + 110)].z));
                  float _1054 = min(max((_1035 - _1038), ((-0.0f - _1035) - _1038)), min(max((_1036 - _1039), ((-0.0f - _1036) - _1039)), max((_1037 - _1040), ((-0.0f - _1037) - _1040))));
                  float _1059 = (_1054 * _632) + (_133 - (cb12_raw[(_905 + 100)].y));
                  float _1061 = (_1054 * _633) + (_134 - (cb12_raw[(_905 + 100)].z));
                  float _1063 = (_1054 * _634) + (_135 - (cb12_raw[(_905 + 100)].w));
                  float _1065 = rsqrt(dot(float3(_1059, _1061, _1063), float3(_1059, _1061, _1063)));
                  float _1066 = _1059 * _1065;
                  float _1067 = _1061 * _1065;
                  float _1068 = _1063 * _1065;
                  bool _1072 = (_1068 < 0.0f);
                  float _1078 = min(max((1.0f / (1.0f - _1068)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                  float _1086 = min(max((1.0f / (_1068 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                  float4 _1105 = t23.SampleLevel(s11, float2((((float((bool)_1072) + 0.1666666716337204f) + ((select(_1072, ((_1066 * 0.5f) * _1078), ((_1066 * -0.5f) * _1086)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(asint(cb12_raw[(_905 + 111)].x))) + 0.1666666716337204f) + ((select(_1072, ((_1067 * -0.5f) * _1078), ((_1067 * 0.5f) * _1086)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _758);
                  _1116 = (_987 + _904);
                  _1117 = ((_1105.x * _990) + _903);
                  _1118 = ((_1105.y * _990) + _902);
                  _1119 = ((_1105.z * _990) + _901);
                } else {
                  _1116 = _904;
                  _1117 = _903;
                  _1118 = _902;
                  _1119 = _901;
                }
                int _1120 = _900 + 1;
                bool _1122 = (_1116 < 0.9990000128746033f);
                if ((int)((uint)_1120 < (uint)7) && _1122) {
                  _900 = _1120;
                  _901 = _1119;
                  _902 = _1118;
                  _903 = _1117;
                  _904 = _1116;
                  continue;
                }
                while(true) {
                  float _763 = _632 * -0.5f;
                  float _764 = _633 * 0.5f;
                  [branch]
                  if (_1122) {
                    float _769 = cb12_100x * (1.0f - _1116);
                    float _773 = _769 * cb12_106x;
                    bool _776 = (_634 < 0.0f);
                    float _782 = min(max((1.0f / (1.0f - _634)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                    float _788 = min(max((1.0f / (_634 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                    float4 _807 = t23.SampleLevel(s11, float2((((float((bool)_776) + 0.1666666716337204f) + ((select(_776, ((_632 * 0.5f) * _782), (_788 * _763)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(cb12_111x)) + 0.1666666716337204f) + ((select(_776, ((_633 * -0.5f) * _782), (_788 * _764)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _758);
                    _818 = (_769 + _1116);
                    _819 = ((_807.x * _773) + _1117);
                    _820 = ((_807.y * _773) + _1118);
                    _821 = ((_807.z * _773) + _1119);
                  } else {
                    _818 = _1116;
                    _819 = _1117;
                    _820 = _1118;
                    _821 = _1119;
                  }
                  float _822 = 1.0f / _818;
                  float _823 = _822 * _819;
                  float _824 = _822 * _820;
                  float _825 = _822 * _821;
                  bool _828 = (int)(!isnan(_823) && !isnan(_824)) && (int)(!isnan(_825) && !isnan(0.0f));
                  float _829 = select(_828, select((((_558 * cb12_022x) + cb12_022y) >= 1.0f), _752, (_749.z * _752)), 1.0f);
                  float _842 = min(max((1.0f / (abs(_634) + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                  float4 _859 = t9.SampleLevel(s2, float2((min(max((((_842 * _763) + 0.5f) * Constants_496.x), 0.5f), (Constants_496.x + -0.5f)) / Constants_496.z), (min(max((((_842 * _764) + 0.5f) * Constants_496.y), 0.5f), (Constants_496.y + -0.5f)) / Constants_496.w)), 0.0f);
                  float _866 = 1.0f - _829;
                  if (!_136) {
                    _882 = saturate((cb12_187x * _749.x) + cb12_188x);
                  } else {
                    _882 = 1.0f;
                  }
                  if (_749.z < 0.9900000095367432f) {
                    _889 = cb12_287w;
                  } else {
                    _889 = 1.0f;
                  }
                  float _895 = exp2((cb12_288y * _889) * log2(_882 * _749.w));
                  _1125 = (_895 * ((_859.x * _829) + (_866 * select(_828, _823, 0.0f))));
                  _1126 = (_895 * ((_859.y * _829) + (_866 * select(_828, _824, 0.0f))));
                  _1127 = (_895 * ((_859.z * _829) + (_866 * select(_828, _825, 0.0f))));
                  break;
                }
                break;
              }
            } else {
              _1125 = 0.0f;
              _1126 = 0.0f;
              _1127 = 0.0f;
            }
          } else {
            uint4 _664 = 0u; t14.GetDimensions(0u, _664.x, _664.y, _664.w);
            int _667 = int(float((int)((int)(_664.x))));
            if ((int)_667 > (int)0) {
              _671 = 0;
              while(true) {
                float4 _673 = t14.Load(int3(_671, 0, 0));
                if (!(((int)((int)(_133 > _673.x) && (int)(_133 < _673.z))) && ((int)((int)(_134 > _673.y) && (int)(_134 < _673.w))))) {
                  int _686 = _671 + 1;
                  if ((int)_686 < (int)_667) {
                    _671 = _686;
                    continue;
                  } else {
                    _689 = -1;
                  }
                } else {
                  _689 = _671;
                }
                _691 = _689;
                break;
              }
            } else {
              _691 = -1;
            }
            if (!((int)_691 < (int)0)) {
              float4 _695 = t14.Load(int3(_691, 0, 0));
              float4 _700 = t14.Load(int3(_691, 1, 0));
              uint4 _706 = 0u; t15.GetDimensions(0u, _706.x, _706.y, _706.z, _706.w);
              float _731 = t15.SampleLevel(s2, float3(((((0.5f / float((int)((int)(_706.x)))) + abs((_133 - _695.x) / (_695.z - _695.x))) * (_700.z - _700.x)) + _700.x), ((((0.5f / float((int)((int)(_706.y)))) + abs((_134 - _695.y) / (_695.w - _695.y))) * (_700.w - _700.y)) + _700.y), float((int)(_691))), 0.0f);
              _741 = ((Constants_512 + ((Constants_516 - Constants_512) * _731.x)) + -1.5f);
            } else {
              _741 = -11.5f;
            }
            if (!((int)(_135 < _741) || ((int)(!_660)))) {
              float4 _749 = t12.Load(int3(int(float((int)(_54))), int(float((int)((int)(SV_DispatchThreadID.y)))), 0));
              float _752 = float((bool)((uint)(_136 && (int)(_73.z > 0.5f))));
              float _758 = min(max(max(((_79.w * _79.w) * 10.5f), 0.0f), 0.0f), 5.0f);
              _900 = 1;
              _901 = 0.0f;
              _902 = 0.0f;
              _903 = 0.0f;
              _904 = 9.999999747378752e-06f;
              while(true) {
                int _905 = _900 * 12;
                float _941 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].x), _135, mad((cb12_raw[(_905 + 103)].x), _134, ((cb12_raw[(_905 + 102)].x) * _133))) + (cb12_raw[(_905 + 105)].x));
                float _942 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].y), _135, mad((cb12_raw[(_905 + 103)].y), _134, ((cb12_raw[(_905 + 102)].y) * _133))) + (cb12_raw[(_905 + 105)].y));
                float _943 = 1.0f - abs(mad((cb12_raw[(_905 + 104)].z), _135, mad((cb12_raw[(_905 + 103)].z), _134, ((cb12_raw[(_905 + 102)].z) * _133))) + (cb12_raw[(_905 + 105)].z));
                int _947 = asint((cb12_raw[(_905 + 106)].y));
                [branch]
                if (!(_749.z == -1.0f)) {
                  _959 = (select(((_947 & 1) != 0), 1.0f, _749.z) * select(((_947 & 2) != 0), 1.0f, (1.0f - _749.z)));
                } else {
                  _959 = 1.0f;
                }
                if (((int)(((int)((int)(_941 > 0.0f) && (int)(_942 > 0.0f))) && (int)(_943 > 0.0f))) && (int)(_959 > 0.0f)) {
                  float _987 = ((((_959 * (1.0f - _904)) * saturate((cb12_raw[(_905 + 101)].x) * _941)) * saturate((cb12_raw[(_905 + 101)].y) * _942)) * saturate((cb12_raw[(_905 + 101)].z) * _943)) * (cb12_raw[(_905 + 100)].x);
                  float _990 = _987 * (cb12_raw[(_905 + 106)].x);
                  float _1035 = 1.0f / mad((cb12_raw[(_905 + 109)].x), _634, mad((cb12_raw[(_905 + 108)].x), _633, ((cb12_raw[(_905 + 107)].x) * _632)));
                  float _1036 = 1.0f / mad((cb12_raw[(_905 + 109)].y), _634, mad((cb12_raw[(_905 + 108)].y), _633, ((cb12_raw[(_905 + 107)].y) * _632)));
                  float _1037 = 1.0f / mad((cb12_raw[(_905 + 109)].z), _634, mad((cb12_raw[(_905 + 108)].z), _633, ((cb12_raw[(_905 + 107)].z) * _632)));
                  float _1038 = _1035 * (mad((cb12_raw[(_905 + 109)].x), _135, mad((cb12_raw[(_905 + 108)].x), _134, ((cb12_raw[(_905 + 107)].x) * _133))) + (cb12_raw[(_905 + 110)].x));
                  float _1039 = _1036 * (mad((cb12_raw[(_905 + 109)].y), _135, mad((cb12_raw[(_905 + 108)].y), _134, ((cb12_raw[(_905 + 107)].y) * _133))) + (cb12_raw[(_905 + 110)].y));
                  float _1040 = _1037 * (mad((cb12_raw[(_905 + 109)].z), _135, mad((cb12_raw[(_905 + 108)].z), _134, ((cb12_raw[(_905 + 107)].z) * _133))) + (cb12_raw[(_905 + 110)].z));
                  float _1054 = min(max((_1035 - _1038), ((-0.0f - _1035) - _1038)), min(max((_1036 - _1039), ((-0.0f - _1036) - _1039)), max((_1037 - _1040), ((-0.0f - _1037) - _1040))));
                  float _1059 = (_1054 * _632) + (_133 - (cb12_raw[(_905 + 100)].y));
                  float _1061 = (_1054 * _633) + (_134 - (cb12_raw[(_905 + 100)].z));
                  float _1063 = (_1054 * _634) + (_135 - (cb12_raw[(_905 + 100)].w));
                  float _1065 = rsqrt(dot(float3(_1059, _1061, _1063), float3(_1059, _1061, _1063)));
                  float _1066 = _1059 * _1065;
                  float _1067 = _1061 * _1065;
                  float _1068 = _1063 * _1065;
                  bool _1072 = (_1068 < 0.0f);
                  float _1078 = min(max((1.0f / (1.0f - _1068)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                  float _1086 = min(max((1.0f / (_1068 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                  float4 _1105 = t23.SampleLevel(s11, float2((((float((bool)_1072) + 0.1666666716337204f) + ((select(_1072, ((_1066 * 0.5f) * _1078), ((_1066 * -0.5f) * _1086)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(asint(cb12_raw[(_905 + 111)].x))) + 0.1666666716337204f) + ((select(_1072, ((_1067 * -0.5f) * _1078), ((_1067 * 0.5f) * _1086)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _758);
                  _1116 = (_987 + _904);
                  _1117 = ((_1105.x * _990) + _903);
                  _1118 = ((_1105.y * _990) + _902);
                  _1119 = ((_1105.z * _990) + _901);
                } else {
                  _1116 = _904;
                  _1117 = _903;
                  _1118 = _902;
                  _1119 = _901;
                }
                int _1120 = _900 + 1;
                bool _1122 = (_1116 < 0.9990000128746033f);
                if ((int)((uint)_1120 < (uint)7) && _1122) {
                  _900 = _1120;
                  _901 = _1119;
                  _902 = _1118;
                  _903 = _1117;
                  _904 = _1116;
                  continue;
                }
                while(true) {
                  float _763 = _632 * -0.5f;
                  float _764 = _633 * 0.5f;
                  [branch]
                  if (_1122) {
                    float _769 = cb12_100x * (1.0f - _1116);
                    float _773 = _769 * cb12_106x;
                    bool _776 = (_634 < 0.0f);
                    float _782 = min(max((1.0f / (1.0f - _634)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                    float _788 = min(max((1.0f / (_634 + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                    float4 _807 = t23.SampleLevel(s11, float2((((float((bool)_776) + 0.1666666716337204f) + ((select(_776, ((_632 * 0.5f) * _782), (_788 * _763)) + 0.5f) * 0.6666666269302368f)) * 0.5f), (((float((int)(cb12_111x)) + 0.1666666716337204f) + ((select(_776, ((_633 * -0.5f) * _782), (_788 * _764)) + 0.5f) * 0.6666666269302368f)) * 0.1428571492433548f)), _758);
                    _818 = (_769 + _1116);
                    _819 = ((_807.x * _773) + _1117);
                    _820 = ((_807.y * _773) + _1118);
                    _821 = ((_807.z * _773) + _1119);
                  } else {
                    _818 = _1116;
                    _819 = _1117;
                    _820 = _1118;
                    _821 = _1119;
                  }
                  float _822 = 1.0f / _818;
                  float _823 = _822 * _819;
                  float _824 = _822 * _820;
                  float _825 = _822 * _821;
                  bool _828 = (int)(!isnan(_823) && !isnan(_824)) && (int)(!isnan(_825) && !isnan(0.0f));
                  float _829 = select(_828, select((((_558 * cb12_022x) + cb12_022y) >= 1.0f), _752, (_749.z * _752)), 1.0f);
                  float _842 = min(max((1.0f / (abs(_634) + 1.0f)), -3.4028234663852886e+38f), 3.4028234663852886e+38f);
                  float4 _859 = t9.SampleLevel(s2, float2((min(max((((_842 * _763) + 0.5f) * Constants_496.x), 0.5f), (Constants_496.x + -0.5f)) / Constants_496.z), (min(max((((_842 * _764) + 0.5f) * Constants_496.y), 0.5f), (Constants_496.y + -0.5f)) / Constants_496.w)), 0.0f);
                  float _866 = 1.0f - _829;
                  if (!_136) {
                    _882 = saturate((cb12_187x * _749.x) + cb12_188x);
                  } else {
                    _882 = 1.0f;
                  }
                  if (_749.z < 0.9900000095367432f) {
                    _889 = cb12_287w;
                  } else {
                    _889 = 1.0f;
                  }
                  float _895 = exp2((cb12_288y * _889) * log2(_882 * _749.w));
                  _1125 = (_895 * ((_859.x * _829) + (_866 * select(_828, _823, 0.0f))));
                  _1126 = (_895 * ((_859.y * _829) + (_866 * select(_828, _824, 0.0f))));
                  _1127 = (_895 * ((_859.z * _829) + (_866 * select(_828, _825, 0.0f))));
                  break;
                }
                break;
              }
            } else {
              _1125 = 0.0f;
              _1126 = 0.0f;
              _1127 = 0.0f;
            }
          }
          // Fade only the environment/sky fallback. Keep traced scene reflections.
          float _1131 = (1.0f - _656) * WitcherNightSkylight(cb12_raw[185].w);
          u0[int2(((uint)(_54) >> 1), (int)(SV_DispatchThreadID.y))] = float3(((_1125 * _1131) + (_657 * _656)), ((_1126 * _1131) + (_658 * _656)), ((_1127 * _1131) + (_659 * _656)));
          break;
        }
      }
    }
  }
}
