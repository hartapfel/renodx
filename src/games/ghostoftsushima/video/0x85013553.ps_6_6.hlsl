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

SamplerState s1 : register(s1);

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target = 0;
  SV_Target.x = 0.0f;
  SV_Target.y = 0.0f;
  SV_Target.z = 0.0f;
  SV_Target.w = 0.0f;
  bool _12 = (TEXCOORD.x < 0.0f);
  bool _13 = (TEXCOORD.y < 0.0f);
  bool _14 = _12 || _13;
  if (!_14) {
    bool _16 = (TEXCOORD.x > 1.0f);
    bool _17 = (TEXCOORD.y > 1.0f);
    bool _18 = _16 || _17;
    if (!_18) {
      uint _23 = (uint)(RootSrtCbv_000) + 32u;
      uint _24 = (uint)(RootSrtCbv_000) + 64u;
      uint _25 = (uint)(RootSrtCbv_000) + 96u;
      uint _26 = (uint)(RootSrtCbv_000) + 104u;
      float4 _27 = asfloat(t1_space1.Load4(_26));
      uint _29 = (uint)(RootSrtCbv_000) + 108u;
      float4 _30 = asfloat(t1_space1.Load4(_29));
      uint _32 = (uint)(RootSrtCbv_000) + 112u;
      float4 _33 = asfloat(t1_space1.Load4(_32));
      int4 _38 = asint(t1_space1.Load4(RootSrtCbv_000));
      Texture2D<float> _41 = ResourceDescriptorHeap[(uint)(_38.x)];
      float _43 = _41.SampleLevel(s0, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
      int4 _45 = asint(t1_space1.Load4(_23));
      Texture2D<float2> _48 = ResourceDescriptorHeap[(uint)(_45.x)];
      float2 _49 = _48.SampleLevel(s0, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
      float _52 = _43.x * 1.16412353515625f;
      float _53 = _49.y * 1.595794677734375f;
      float _54 = _49.y * 0.8134765625f;
      float _55 = _52 - _54;
      float _56 = _49.x * 0.391448974609375f;
      float _57 = _49.x * 2.017822265625f;
      float _58 = _55 - _56;
      float _59 = _52 + -0.8706550598144531f;
      float _60 = _59 + _53;
      float _61 = _58 + 0.5297050476074219f;
      float _62 = _52 + -1.0816688537597656f;
      float _63 = _62 + _57;
      float4 _64 = asfloat(t1_space1.Load4(_25));
      float _66 = _64.x * TEXCOORD.x;
      uint _67 = (uint)(RootSrtCbv_000) + 100u;
      float4 _68 = asfloat(t1_space1.Load4(_67));
      float _70 = _66 + _68.x;
      float _71 = saturate(_70);
      float _72 = _71 * 2.0f;
      float _73 = 3.0f - _72;
      float _74 = _71 * _71;
      float _75 = _74 * _73;
      float _78 = cbufGlobal_264 * _60;
      float _79 = _60 - _61;
      float _80 = _60 - _63;
      float _81 = _79 * _30.x;
      float _82 = _80 * _30.x;
      float _83 = _81 + _61;
      float _84 = _83 * cbufGlobal_264;
      float _85 = _82 + _63;
      float _86 = _85 * cbufGlobal_264;
      float _87 = _33.x - _78;
      float _88 = _33.y - _84;
      float _89 = _33.z - _86;
      float _90 = _87 * _33.w;
      float _91 = _88 * _33.w;
      float _92 = _89 * _33.w;
      float _93 = _90 + _78;
      float _94 = _91 + _84;
      float _95 = _92 + _86;
      float _96 = SV_Position.x * 0.015625f;
      float _97 = SV_Position.y * 0.015625f;
      int4 _98 = asint(t1_space1.Load4(_24));
      Texture2D<float> _101 = ResourceDescriptorHeap[(uint)(_98.x)];
      float _103 = _101.Sample(s1, float2(_96, _97));
      float _105 = _103.x + -0.5f;
      float _106 = _105 * _27.x;
      float _107 = _93 + _106;
      float _108 = _94 + _106;
      float _109 = _95 + _106;
      SV_Target.x = _107;
      SV_Target.y = _108;
      SV_Target.z = _109;
      SV_Target.w = _75;
      if (GhostIsUIOverrideActive()) {
        // RGB is straight alpha; _75 is only the output fade/coverage.
        // The tint is mixed AFTER native HUD scaling. Express it in the
        // same unscaled domain as the video before replacing that scaling.
        // At zero native scale, retain the tint instead of dividing by zero.
        const float3 ghost_video = lerp(
            float3(_60, _83, _85),
            renodx::math::DivideSafe(_33.rgb, cbufGlobal_264.xxx, _33.rgb),
            _33.w);
        // SDR decode/gamma -> linear BT.709-to-BT.2020 -> UI-white PQ.
        // Native output dither stays after encoding, outside the transform.
        SV_Target.rgb = GhostRenderUI(ghost_video, 1.f) + _106;
      }
    }
  }
  return SV_Target;
}
