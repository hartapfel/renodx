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
  float4 _35 = sDiffuse.SampleLevel(sMaterialSampler, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
  float _37 = TEXCOORD_1.x + -0.49803921580314636f;
  float _38 = _37 + _35.x;
  float _39 = _38 * 8.0f;
  float _40 = _34 * 2.0f;
  float _41 = _39 + _34;
  float _42 = _41 / _40;
  float _43 = saturate(_42);
  float _44 = _43 * 2.0f;
  float _45 = 3.0f - _44;
  float _46 = _43 * _43;
  float _47 = _46 * _45;
  float4 _48 = sDiffuse.Sample(sMaterialSampler, float2(TEXCOORD_1.z, TEXCOORD_1.w));
  float _50 = _48.w + -0.49803921580314636f;
  float _51 = _50 * 8.0f;
  float _52 = _51 + _34;
  float _53 = _52 / _40;
  float _54 = saturate(_53);
  float _55 = _54 * 2.0f;
  float _56 = 3.0f - _55;
  float _57 = _54 * _54;
  float _58 = _57 * TEXCOORD_2.w;
  float _59 = _58 * _56;
  float _60 = COLOR.x - TEXCOORD_2.x;
  float _61 = COLOR.y - TEXCOORD_2.y;
  float _62 = COLOR.z - TEXCOORD_2.z;
  float _63 = _47 - _59;
  float _64 = _47 * _60;
  float _65 = _47 * _61;
  float _66 = _47 * _62;
  float _67 = _63 * _47;
  float _68 = _64 + TEXCOORD_2.x;
  float _69 = _65 + TEXCOORD_2.y;
  float _70 = _66 + TEXCOORD_2.z;
  float _71 = _67 + _59;
  float _72 = _71 * COLOR.w;
  SV_Target.rgb = APTScaleUIEncoded(float3(_68, _69, _70));
  SV_Target.w = _72;
  return SV_Target;
}
