#include "../common.hlsli"

Texture2D<float4> sDiffuse : register(t0);

SamplerState sMaterialSampler : register(s0);

float4 main(
  linear float4 COLOR : COLOR,
  linear float4 TEXCOORD : TEXCOORD,
  linear float4 TEXCOORD_2 : TEXCOORD2,
  linear float4 TEXCOORD_1 : TEXCOORD1,
  noperspective float4 SV_Position : SV_Position,
  nointerpolation uint2 INSTANCE_INDEXES : INSTANCE_INDEXES
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
  float4 _40 = sDiffuse.SampleLevel(sMaterialSampler, float2(_38, _39), 0.0f);
  float _42 = _35 + TEXCOORD.x;
  float _43 = _28 * 4.064941458636895e-05f;
  float _44 = TEXCOORD.y - _43;
  float4 _45 = sDiffuse.SampleLevel(sMaterialSampler, float2(_42, _44), 0.0f);
  float _47 = TEXCOORD.x - _35;
  float _48 = _43 + TEXCOORD.y;
  float4 _49 = sDiffuse.SampleLevel(sMaterialSampler, float2(_47, _48), 0.0f);
  float _51 = _37 + TEXCOORD.x;
  float _52 = _36 + TEXCOORD.y;
  float4 _53 = sDiffuse.SampleLevel(sMaterialSampler, float2(_51, _52), 0.0f);
  float _55 = TEXCOORD_1.x + -0.49803921580314636f;
  float _56 = _55 + _40.x;
  float _57 = _56 * 8.0f;
  float _58 = _55 + _45.x;
  float _59 = _58 * 8.0f;
  float _60 = _55 + _49.x;
  float _61 = _60 * 8.0f;
  float _62 = _55 + _53.x;
  float _63 = _62 * 8.0f;
  float _64 = _34 * 2.0f;
  float _65 = _57 + _34;
  float _66 = _65 / _64;
  float _67 = saturate(_66);
  float _68 = _67 * 2.0f;
  float _69 = 3.0f - _68;
  float _70 = _67 * _67;
  float _71 = _70 * _69;
  float _72 = _59 + _34;
  float _73 = _72 / _64;
  float _74 = saturate(_73);
  float _75 = _74 * 2.0f;
  float _76 = 3.0f - _75;
  float _77 = _74 * _74;
  float _78 = _77 * _76;
  float _79 = _78 + _71;
  float _80 = _61 + _34;
  float _81 = _80 / _64;
  float _82 = saturate(_81);
  float _83 = _82 * 2.0f;
  float _84 = 3.0f - _83;
  float _85 = _82 * _82;
  float _86 = _85 * _84;
  float _87 = _79 + _86;
  float _88 = _63 + _34;
  float _89 = _88 / _64;
  float _90 = saturate(_89);
  float _91 = _90 * 2.0f;
  float _92 = 3.0f - _91;
  float _93 = _90 * _90;
  float _94 = _93 * _92;
  float _95 = _87 + _94;
  float _96 = _95 * 0.25f;
  float4 _97 = sDiffuse.Sample(sMaterialSampler, float2(TEXCOORD_1.z, TEXCOORD_1.w));
  float _99 = _97.w + -0.49803921580314636f;
  float _100 = _99 * 8.0f;
  float _101 = _100 + _34;
  float _102 = _101 / _64;
  float _103 = saturate(_102);
  float _104 = _103 * 2.0f;
  float _105 = 3.0f - _104;
  float _106 = _103 * _103;
  float _107 = _106 * TEXCOORD_2.w;
  float _108 = _107 * _105;
  float _109 = COLOR.x - TEXCOORD_2.x;
  float _110 = COLOR.y - TEXCOORD_2.y;
  float _111 = COLOR.z - TEXCOORD_2.z;
  float _112 = _96 - _108;
  float _113 = _96 * _109;
  float _114 = _96 * _110;
  float _115 = _96 * _111;
  float _116 = _112 * _96;
  float _117 = _113 + TEXCOORD_2.x;
  float _118 = _114 + TEXCOORD_2.y;
  float _119 = _115 + TEXCOORD_2.z;
  float _120 = _116 + _108;
  float _121 = _120 * COLOR.w;
  SV_Target.rgb = APTScaleUIEncoded(float3(_117, _118, _119));
  SV_Target.w = _121;
  return SV_Target;
}
