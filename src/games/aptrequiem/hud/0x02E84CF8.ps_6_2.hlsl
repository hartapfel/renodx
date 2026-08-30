#include "../common.hlsli"

Texture2D<float4> sDiffuse : register(t0);

SamplerState sMaterialSampler : register(s0);

float4 main(
  linear float4 COLOR : COLOR,
  linear float4 TEXCOORD : TEXCOORD,
  noperspective float4 SV_Position : SV_Position,
  nointerpolation uint2 INSTANCE_INDEXES : INSTANCE_INDEXES,
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
  float4 _34 = sDiffuse.SampleLevel(sMaterialSampler, float2(_32, _33), 0.0f);
  float _36 = _29 + TEXCOORD.x;
  float _37 = _22 * 4.064941458636895e-05f;
  float _38 = TEXCOORD.y - _37;
  float4 _39 = sDiffuse.SampleLevel(sMaterialSampler, float2(_36, _38), 0.0f);
  float _41 = TEXCOORD.x - _29;
  float _42 = _37 + TEXCOORD.y;
  float4 _43 = sDiffuse.SampleLevel(sMaterialSampler, float2(_41, _42), 0.0f);
  float _45 = _31 + TEXCOORD.x;
  float _46 = _30 + TEXCOORD.y;
  float4 _47 = sDiffuse.SampleLevel(sMaterialSampler, float2(_45, _46), 0.0f);
  float _49 = TEXCOORD_1.x + -0.49803921580314636f;
  float _50 = _49 + _34.x;
  float _51 = _50 * 8.0f;
  float _52 = _49 + _39.x;
  float _53 = _52 * 8.0f;
  float _54 = _49 + _43.x;
  float _55 = _54 * 8.0f;
  float _56 = _49 + _47.x;
  float _57 = _56 * 8.0f;
  float _58 = _28 * 2.0f;
  float _59 = _51 + _28;
  float _60 = _59 / _58;
  float _61 = saturate(_60);
  float _62 = _61 * 2.0f;
  float _63 = 3.0f - _62;
  float _64 = _61 * _61;
  float _65 = _64 * _63;
  float _66 = _53 + _28;
  float _67 = _66 / _58;
  float _68 = saturate(_67);
  float _69 = _68 * 2.0f;
  float _70 = 3.0f - _69;
  float _71 = _68 * _68;
  float _72 = _71 * _70;
  float _73 = _72 + _65;
  float _74 = _55 + _28;
  float _75 = _74 / _58;
  float _76 = saturate(_75);
  float _77 = _76 * 2.0f;
  float _78 = 3.0f - _77;
  float _79 = _76 * _76;
  float _80 = _79 * _78;
  float _81 = _73 + _80;
  float _82 = _57 + _28;
  float _83 = _82 / _58;
  float _84 = saturate(_83);
  float _85 = _84 * 2.0f;
  float _86 = 3.0f - _85;
  float _87 = _84 * _84;
  float _88 = _87 * _86;
  float _89 = _81 + _88;
  float _90 = COLOR.w * 0.25f;
  float _91 = _90 * _89;
  SV_Target.rgb = APTScaleUIEncoded(COLOR.rgb);
  SV_Target.w = _91;
  return SV_Target;
}
