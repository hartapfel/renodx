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
  float4 _29 = sDiffuse.SampleLevel(sMaterialSampler, float2(TEXCOORD.x, TEXCOORD.y), 0.0f);
  float _31 = TEXCOORD_1.x + -0.49803921580314636f;
  float _32 = _31 + _29.x;
  float _33 = _32 * 8.0f;
  float _34 = _28 * 2.0f;
  float _35 = _33 + _28;
  float _36 = _35 / _34;
  float _37 = saturate(_36);
  float _38 = _37 * 2.0f;
  float _39 = 3.0f - _38;
  float _40 = _37 * _37;
  float _41 = _40 * COLOR.w;
  float _42 = _41 * _39;
  SV_Target.rgb = APTScaleUIEncoded(COLOR.rgb);
  SV_Target.w = _42;
  return SV_Target;
}
