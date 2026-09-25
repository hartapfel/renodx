#include "../common.hlsli"
#include "../post_effects.hlsli"

ByteAddressBuffer t1_space1 : register(t1, space1);

cbuffer cb14 : register(b14) {
  int RootSrtCbv_000 : packoffset(c000.x);
  int RootSrtCbv_004 : packoffset(c000.y);
};

SamplerState s0 : register(s0);

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target = 0;
  SV_Target.x = 0.0f;
  SV_Target.y = 0.0f;
  SV_Target.z = 0.0f;
  SV_Target.w = 0.0f;
  uint _10 = (uint)(RootSrtCbv_000) + 72u;
  float4 _11 = asfloat(t1_space1.Load4(_10));
  SV_Target.x = 0.0f;
  SV_Target.y = 0.0f;
  SV_Target.z = 0.0f;
  SV_Target.w = 0.0f;
  int4 _16 = asint(t1_space1.Load4(RootSrtCbv_000));
  Texture2D<float4> _19 = ResourceDescriptorHeap[(uint)(_16.x)];
  float4 _21 = _19.Sample(s0, float2(TEXCOORD.x, TEXCOORD.y));
  if (GhostIsPsychoV() && GHOST_SDR_OUTPUT != 0.f) {
    if (shader_injection.post_effects_output_fallback != 0.f && GhostPostEffectsEnabled()) {
      // When the HUD is hidden, apply effects to the reconstructed scene at
      // this last scene-only draw. Visible HUD uses the pre-composition pass.
      _21 = GhostApplyPostUpscaleEffects(_19, uint2(SV_Position.xy));
      _21.rgb = round(saturate(_21.rgb) * 255.f) / 255.f;
    }
  }
  float _25 = log2(_21.x);
  float _26 = log2(_21.y);
  float _27 = log2(_21.z);
  float _28 = _25 * _11.y;
  float _29 = _26 * _11.y;
  float _30 = _27 * _11.y;
  float _31 = exp2(_28);
  float _32 = exp2(_29);
  float _33 = exp2(_30);
  float _34 = _31 * _11.z;
  float _35 = _32 * _11.z;
  float _36 = _33 * _11.z;
  float _37 = _34 + _11.w;
  float _38 = _35 + _11.w;
  float _39 = _36 + _11.w;
  float _40 = _21.x * _11.x;
  float _41 = _21.y * _11.x;
  float _42 = _21.z * _11.x;
  bool _43 = (_21.x <= 0.0031308000907301903f);
  bool _44 = (_21.y <= 0.0031308000907301903f);
  bool _45 = (_21.z <= 0.0031308000907301903f);
  float _46 = select(_43, _40, _37);
  float _47 = select(_44, _41, _38);
  float _48 = select(_45, _42, _39);
  float _49 = _46 * 0.07739938050508499f;
  float _50 = _47 * 0.07739938050508499f;
  float _51 = _48 * 0.07739938050508499f;
  float _52 = _46 + 0.054999999701976776f;
  float _53 = _47 + 0.054999999701976776f;
  float _54 = _48 + 0.054999999701976776f;
  float _55 = _52 * 0.9478673338890076f;
  float _56 = _53 * 0.9478673338890076f;
  float _57 = _54 * 0.9478673338890076f;
  float _58 = log2(_55);
  float _59 = log2(_56);
  float _60 = log2(_57);
  float _61 = _58 * 2.4000000953674316f;
  float _62 = _59 * 2.4000000953674316f;
  float _63 = _60 * 2.4000000953674316f;
  float _64 = exp2(_61);
  float _65 = exp2(_62);
  float _66 = exp2(_63);
  bool _67 = (_46 <= 0.0392800010740757f);
  float _68 = select(_67, _49, _64);
  bool _69 = (_47 <= 0.0392800010740757f);
  float _70 = select(_69, _50, _65);
  bool _71 = (_48 <= 0.0392800010740757f);
  float _72 = select(_71, _51, _66);
  float _73 = _68 * 4.5f;
  float _74 = _70 * 4.5f;
  float _75 = _72 * 4.5f;
  float _76 = log2(_68);
  float _77 = log2(_70);
  float _78 = log2(_72);
  float _79 = _76 * 0.44999998807907104f;
  float _80 = _77 * 0.44999998807907104f;
  float _81 = _78 * 0.44999998807907104f;
  float _82 = exp2(_79);
  float _83 = exp2(_80);
  float _84 = exp2(_81);
  float _85 = _82 * 1.0989999771118164f;
  float _86 = _83 * 1.0989999771118164f;
  float _87 = _84 * 1.0989999771118164f;
  float _88 = _85 + -0.0989999994635582f;
  float _89 = _86 + -0.0989999994635582f;
  float _90 = _87 + -0.0989999994635582f;
  bool _91 = (_68 <= 0.017999999225139618f);
  float _92 = select(_91, _73, _88);
  bool _93 = (_70 <= 0.017999999225139618f);
  float _94 = select(_93, _74, _89);
  bool _95 = (_72 <= 0.017999999225139618f);
  float _96 = select(_95, _75, _90);
  SV_Target.x = _92;
  SV_Target.y = _94;
  SV_Target.z = _96;
  SV_Target.w = 1.0f;
  return SV_Target;
}
