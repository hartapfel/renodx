#include "../common.hlsli"

Texture2D<float4> t0 : register(t0);

SamplerState s0 : register(s0);

float4 main(
  linear float4 COLOR : COLOR,
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_2 : TEXCOORD2,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  noperspective float4 SV_Position : SV_Position
) : SV_Target {
  float4 SV_Target;
  float _19 = ddx_coarse(TEXCOORD.z);
  float _20 = ddx_coarse(TEXCOORD.w);
  float _21 = abs(_19);
  float _22 = abs(_20);
  float _23 = ddy_coarse(TEXCOORD.z);
  float _24 = ddy_coarse(TEXCOORD.w);
  float _25 = abs(_23);
  float _26 = abs(_24);
  float _27 = _25 + _21;
  float _28 = _26 + _22;
  float _29 = _27 * _27;
  float _30 = _28 * _28;
  float _31 = _30 + _29;
  float _32 = sqrt(_31);
  float _33 = _32 * 0.25f;
  float _34 = _33 + TEXCOORD_1.y;
  float _35 = _27 * 0.000244140625f;
  float _36 = _28 * 8.12988291727379e-05f;
  float _37 = _27 * 0.0001220703125f;
  float _38 = TEXCOORD.x - _37;
  float _39 = TEXCOORD.y - _36;
  float4 _42 = t0.SampleLevel(s0, float2(_38, _39), 0.0f);
  float _44 = _35 + TEXCOORD.x;
  float _45 = _28 * 4.064941458636895e-05f;
  float _46 = TEXCOORD.y - _45;
  float4 _47 = t0.SampleLevel(s0, float2(_44, _46), 0.0f);
  float _49 = TEXCOORD.x - _35;
  float _50 = _45 + TEXCOORD.y;
  float4 _51 = t0.SampleLevel(s0, float2(_49, _50), 0.0f);
  float _53 = _37 + TEXCOORD.x;
  float _54 = _36 + TEXCOORD.y;
  float4 _55 = t0.SampleLevel(s0, float2(_53, _54), 0.0f);
  float _57 = TEXCOORD_1.x + -0.49803921580314636f;
  float _58 = _42.x + _57;
  float _59 = _58 * 8.0f;
  float _60 = _47.x + _57;
  float _61 = _60 * 8.0f;
  float _62 = _51.x + _57;
  float _63 = _62 * 8.0f;
  float _64 = _55.x + _57;
  float _65 = _64 * 8.0f;
  float _66 = _34 * 2.0f;
  float _67 = _59 + _34;
  float _68 = _67 / _66;
  float _69 = saturate(_68);
  float _70 = _69 * 2.0f;
  float _71 = 3.0f - _70;
  float _72 = _69 * _69;
  float _73 = _72 * _71;
  float _74 = _61 + _34;
  float _75 = _74 / _66;
  float _76 = saturate(_75);
  float _77 = _76 * 2.0f;
  float _78 = 3.0f - _77;
  float _79 = _76 * _76;
  float _80 = _79 * _78;
  float _81 = _80 + _73;
  float _82 = _63 + _34;
  float _83 = _82 / _66;
  float _84 = saturate(_83);
  float _85 = _84 * 2.0f;
  float _86 = 3.0f - _85;
  float _87 = _84 * _84;
  float _88 = _87 * _86;
  float _89 = _81 + _88;
  float _90 = _65 + _34;
  float _91 = _90 / _66;
  float _92 = saturate(_91);
  float _93 = _92 * 2.0f;
  float _94 = 3.0f - _93;
  float _95 = _92 * _92;
  float _96 = _95 * _94;
  float _97 = _89 + _96;
  float _98 = _97 * 0.25f;
  float4 _101 = t0.Sample(s0, float2(TEXCOORD_1.z, TEXCOORD_1.w));
  float _103 = _101.w + -0.49803921580314636f;
  float _104 = _103 * 8.0f;
  float _105 = _104 + _34;
  float _106 = _105 / _66;
  float _107 = saturate(_106);
  float _108 = _107 * 2.0f;
  float _109 = 3.0f - _108;
  float _110 = _107 * _107;
  float _111 = _110 * TEXCOORD_2.w;
  float _112 = _111 * _109;
  float _113 = COLOR.x - TEXCOORD_2.x;
  float _114 = COLOR.y - TEXCOORD_2.y;
  float _115 = COLOR.z - TEXCOORD_2.z;
  float _116 = _98 - _112;
  float _117 = _98 * _113;
  float _118 = _98 * _114;
  float _119 = _98 * _115;
  float _120 = _116 * _98;
  float _121 = _117 + TEXCOORD_2.x;
  float _122 = _118 + TEXCOORD_2.y;
  float _123 = _119 + TEXCOORD_2.z;
  float _124 = _120 + _112;
  float _125 = _124 * COLOR.w;
  SV_Target.rgb = ResonanceScaleUIEncoded(float3(_121, _122, _123));
  SV_Target.w = _125;
  return SV_Target;
}
