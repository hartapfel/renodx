#include "../ui.hlsli"

ByteAddressBuffer t1_space1 : register(t1, space1);

cbuffer cb14 : register(b14) {
  int RootSrtCbv_000 : packoffset(c000.x);
  int RootSrtCbv_004 : packoffset(c000.y);
};

cbuffer cb0 : register(b0) {
  float4 cbufGlobal_000[4] : packoffset(c000.x);
  float4 cbufGlobal_064[4] : packoffset(c004.x);
  float4 cbufGlobal_128 : packoffset(c008.x);
  float4 cbufGlobal_144 : packoffset(c009.x);
  float2 cbufGlobal_160 : packoffset(c010.x);
  float2 cbufGlobal_168 : packoffset(c010.z);
  float4 cbufGlobal_176 : packoffset(c011.x);
  float4 cbufGlobal_192 : packoffset(c012.x);
  float3 cbufGlobal_208 : packoffset(c013.x);
  float cbufGlobal_220 : packoffset(c013.w);
  float cbufGlobal_224 : packoffset(c014.x);
  float cbufGlobal_228 : packoffset(c014.y);
  float cbufGlobal_232 : packoffset(c014.z);
  float cbufGlobal_236 : packoffset(c014.w);
  float cbufGlobal_240 : packoffset(c015.x);
  float cbufGlobal_244 : packoffset(c015.y);
  float cbufGlobal_248 : packoffset(c015.z);
  float cbufGlobal_252 : packoffset(c015.w);
  float cbufGlobal_256 : packoffset(c016.x);
  float cbufGlobal_260 : packoffset(c016.y);
  float cbufGlobal_264 : packoffset(c016.z);
  float cbufGlobal_268 : packoffset(c016.w);
  float2 cbufGlobal_272 : packoffset(c017.x);
  int cbufGlobal_280 : packoffset(c017.z);
  float cbufGlobal_284 : packoffset(c017.w);
  float cbufGlobal_288 : packoffset(c018.x);
  float3 cbufGlobal_292 : packoffset(c018.y);
};

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float4 COLOR : COLOR,
  linear float3 TEXTURE_1 : TEXTURE1
) : SV_Target {
  float4 SV_Target = 0;
  int4 _16 = asint(t1_space1.Load4(RootSrtCbv_000));
  uint _18 = (uint)(RootSrtCbv_000) + 76u;
  float4 _19 = asfloat(t1_space1.Load4(_18));
  uint _21 = (uint)(RootSrtCbv_000) + 80u;
  float4 _22 = asfloat(t1_space1.Load4(_21));
  uint _24 = (uint)(_16.x) + 32u;
  float4 _25 = asfloat(t1_space1.Load4(_24));
  uint _27 = (uint)(_16.x) + 36u;
  float4 _28 = asfloat(t1_space1.Load4(_27));
  uint _29 = (uint)(_16.x) + 44u;
  float4 _30 = asfloat(t1_space1.Load4(_29));
  bool _34 = !(_22.x >= 0.0f);
  float _59;
  if (!_34) {
    int _41 = int(SV_Position.x);
    int _42 = int(SV_Position.y);
    int4 _43 = asint(t1_space1.Load4(_16.x));
    Texture2D<float> _46 = ResourceDescriptorHeap[(uint)(_43.x)];
    float _47 = _46.Load(int3(_41, _42, 0));
    float _49 = _47.x * _28.y;
    float _50 = _49 + _28.x;
    float _51 = 1.0f / _50;
    float _52 = SV_Position.w - _51;
    float _53 = abs(_52);
    float _54 = _53 / _22.x;
    float _55 = saturate(_54);
    float _56 = 1.0f - _55;
    float _57 = _56 * COLOR.w;
    _59 = _57;
  } else {
    _59 = COLOR.w;
  }
  bool _60 = (_59 < _25.x);
  if (_60) {
    if (true) discard;
  }
  float _63 = ddx_coarse(TEXTURE_1.x);
  float _64 = ddx_coarse(TEXTURE_1.y);
  float _65 = ddx_coarse(TEXTURE_1.z);
  float _66 = ddy_coarse(TEXTURE_1.x);
  float _67 = ddy_coarse(TEXTURE_1.y);
  float _68 = ddy_coarse(TEXTURE_1.z);
  float _69 = _68 * _64;
  float _70 = _67 * _65;
  float _71 = _69 - _70;
  float _72 = _66 * _65;
  float _73 = _68 * _63;
  float _74 = _72 - _73;
  float _75 = _67 * _63;
  float _76 = _66 * _64;
  float _77 = _75 - _76;
  float _78 = dot(float3(_71, _74, _77), float3(_71, _74, _77));
  float _79 = rsqrt(_78);
  float _80 = _71 * _79;
  float _81 = _74 * _79;
  float _82 = _79 * _77;
  float _83 = dot(float3(_80, _81, _82), float3(_30.x, _30.y, _30.z));
  float _84 = saturate(_83);
  float _85 = _84 + -1.0f;
  float _86 = _85 * _19.x;
  float _87 = _86 + 1.0f;
  float _90 = cbufGlobal_264 * COLOR.x;
  float _91 = _90 * _87;
  float _92 = cbufGlobal_264 * COLOR.y;
  float _93 = _92 * _87;
  float _94 = cbufGlobal_264 * COLOR.z;
  float _95 = _94 * _87;
  SV_Target.x = _91;
  SV_Target.y = _93;
  SV_Target.z = _95;
  SV_Target.w = _59;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(COLOR.rgb * _87, 1.f);
  }
  return SV_Target;
}
