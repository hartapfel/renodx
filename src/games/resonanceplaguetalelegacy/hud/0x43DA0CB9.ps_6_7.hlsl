#include "../common.hlsli"

Texture2D<float4> t0 : register(t0);

SamplerState s0 : register(s0);

float4 main(
  linear float4 COLOR : COLOR,
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD_1 : TEXCOORD1
) : SV_Target {
  float4 SV_Target;
  float _13 = ddx_coarse(TEXCOORD.z);
  float _14 = ddx_coarse(TEXCOORD.w);
  float _15 = abs(_13);
  float _16 = abs(_14);
  float _17 = ddy_coarse(TEXCOORD.z);
  float _18 = ddy_coarse(TEXCOORD.w);
  float _19 = abs(_17);
  float _20 = abs(_18);
  float _21 = _19 + _15;
  float _22 = _20 + _16;
  float _23 = _21 * _21;
  float _24 = _22 * _22;
  float _25 = _24 + _23;
  float _26 = sqrt(_25);
  float _27 = _26 * 0.25f;
  float _28 = _27 + TEXCOORD_1.y;
  float _29 = _21 * 0.000244140625f;
  float _30 = _22 * 8.12988291727379e-05f;
  float _31 = _21 * 0.0001220703125f;
  float _32 = TEXCOORD.x - _31;
  float _33 = TEXCOORD.y - _30;
  float4 _36 = t0.SampleLevel(s0, float2(_32, _33), 0.0f);
  float _38 = _29 + TEXCOORD.x;
  float _39 = _22 * 4.064941458636895e-05f;
  float _40 = TEXCOORD.y - _39;
  float4 _41 = t0.SampleLevel(s0, float2(_38, _40), 0.0f);
  float _43 = TEXCOORD.x - _29;
  float _44 = _39 + TEXCOORD.y;
  float4 _45 = t0.SampleLevel(s0, float2(_43, _44), 0.0f);
  float _47 = _31 + TEXCOORD.x;
  float _48 = _30 + TEXCOORD.y;
  float4 _49 = t0.SampleLevel(s0, float2(_47, _48), 0.0f);
  float _51 = TEXCOORD_1.x + -0.49803921580314636f;
  float _52 = _36.x + _51;
  float _53 = _52 * 8.0f;
  float _54 = _41.x + _51;
  float _55 = _54 * 8.0f;
  float _56 = _45.x + _51;
  float _57 = _56 * 8.0f;
  float _58 = _49.x + _51;
  float _59 = _58 * 8.0f;
  float _60 = _28 * 2.0f;
  float _61 = _53 + _28;
  float _62 = _61 / _60;
  float _63 = saturate(_62);
  float _64 = _63 * 2.0f;
  float _65 = 3.0f - _64;
  float _66 = _63 * _63;
  float _67 = _66 * _65;
  float _68 = _55 + _28;
  float _69 = _68 / _60;
  float _70 = saturate(_69);
  float _71 = _70 * 2.0f;
  float _72 = 3.0f - _71;
  float _73 = _70 * _70;
  float _74 = _73 * _72;
  float _75 = _74 + _67;
  float _76 = _57 + _28;
  float _77 = _76 / _60;
  float _78 = saturate(_77);
  float _79 = _78 * 2.0f;
  float _80 = 3.0f - _79;
  float _81 = _78 * _78;
  float _82 = _81 * _80;
  float _83 = _75 + _82;
  float _84 = _59 + _28;
  float _85 = _84 / _60;
  float _86 = saturate(_85);
  float _87 = _86 * 2.0f;
  float _88 = 3.0f - _87;
  float _89 = _86 * _86;
  float _90 = _89 * _88;
  float _91 = _83 + _90;
  float _92 = COLOR.w * 0.25f;
  float _93 = _92 * _91;
  SV_Target.rgb = ResonanceScaleUIEncoded(COLOR.rgb);
  SV_Target.w = _93;
  return SV_Target;
}
