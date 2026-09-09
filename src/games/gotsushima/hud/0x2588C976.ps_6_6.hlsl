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

SamplerState s0 : register(s0);

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float4 COLOR : COLOR,
  linear float2 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target = 0;
  float _13 = ddx_coarse(TEXCOORD.x);
  float _14 = ddx_coarse(TEXCOORD.y);
  float _15 = ddy_coarse(TEXCOORD.x);
  float _16 = ddy_coarse(TEXCOORD.y);
  float _20 = _15 + _13;
  float _21 = _20 * 0.25f;
  float _22 = _21 + TEXCOORD.x;
  float _23 = _16 + _14;
  float _24 = _23 * 0.25f;
  float _25 = _24 + TEXCOORD.y;
  int4 _26 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _29 = ResourceDescriptorHeap[(uint)(_26.x)];
  float4 _31 = _29.SampleBias(s0, float2(_22, _25), -1.0f, int2(0, 0));
  float _36 = _13 * 0.25f;
  float _37 = _14 * 0.25f;
  float _38 = TEXCOORD.x - _36;
  float _39 = TEXCOORD.y - _37;
  float _40 = _15 * 0.25f;
  float _41 = _16 * 0.25f;
  float _42 = _38 + _40;
  float _43 = _39 + _41;
  int4 _44 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _47 = ResourceDescriptorHeap[(uint)(_44.x)];
  float4 _49 = _47.SampleBias(s0, float2(_42, _43), -1.0f, int2(0, 0));
  float _54 = _49.x + _31.x;
  float _55 = _49.y + _31.y;
  float _56 = _49.z + _31.z;
  float _57 = _49.w + _31.w;
  float _58 = _36 + TEXCOORD.x;
  float _59 = _37 + TEXCOORD.y;
  float _60 = _58 - _40;
  float _61 = _59 - _41;
  int4 _62 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _65 = ResourceDescriptorHeap[(uint)(_62.x)];
  float4 _67 = _65.SampleBias(s0, float2(_60, _61), -1.0f, int2(0, 0));
  float _72 = _54 + _67.x;
  float _73 = _55 + _67.y;
  float _74 = _56 + _67.z;
  float _75 = _57 + _67.w;
  float _76 = _38 - _40;
  float _77 = _39 - _41;
  int4 _78 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _81 = ResourceDescriptorHeap[(uint)(_78.x)];
  float4 _83 = _81.SampleBias(s0, float2(_76, _77), -1.0f, int2(0, 0));
  float _88 = _72 + _83.x;
  float _89 = _73 + _83.y;
  float _90 = _74 + _83.z;
  float _91 = _75 + _83.w;
  float _92 = COLOR.w * 0.25f;
  float _93 = _92 * _91;
  float _96 = COLOR.x * 0.25f;
  float _97 = _96 * _88;
  float _98 = _97 * cbufGlobal_264;
  float _99 = COLOR.y * 0.25f;
  float _100 = _99 * _89;
  float _101 = _100 * cbufGlobal_264;
  float _102 = COLOR.z * 0.25f;
  float _103 = _102 * _90;
  float _104 = _103 * cbufGlobal_264;
  SV_Target.x = _98;
  SV_Target.y = _101;
  SV_Target.z = _104;
  SV_Target.w = _93;
  if (GhostIsUIOverrideActive()) {
    SV_Target.rgb = GhostRenderUI(float3(_97, _100, _103), 1.f);
  }
  return SV_Target;
}
