#include "../common.hlsli"

Texture2D<float4> sDiffuse : register(t0);

SamplerState sMaterialSampler : register(s0);

float4 main(
  linear float4 PREVIOUS_POSITION : PREVIOUS_POSITION,
  linear float4 COLOR : COLOR,
  noperspective float4 SV_Position : SV_Position,
  nointerpolation uint2 INSTANCE_INDEXES : INSTANCE_INDEXES,
  linear float3 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target;
  float4 _9 = sDiffuse.Sample(sMaterialSampler, float2(TEXCOORD.x, TEXCOORD.y));
  float _14 = _9.x * COLOR.x;
  float _15 = _9.y * COLOR.y;
  float _16 = _9.z * COLOR.z;
  float _17 = _9.w * COLOR.w;
  SV_Target.rgb = APTScaleUIEncoded(float3(_14, _15, _16));
  SV_Target.w = _17;
  return SV_Target;
}
