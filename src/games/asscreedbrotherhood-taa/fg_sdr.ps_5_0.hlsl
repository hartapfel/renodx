// Preserve native SDR code values. No HDR grading, transfer conversion or lift.
Texture2D<float4> scene : register(t0);
Texture2D<float> transmittance : register(t1);
struct Output { float4 color : SV_Target0; float alpha : SV_Target1; };
Output main(float4 position : SV_Position, float2 uv : TEXCOORD0) {
  Output result;
  result.color = float4(scene.Load(int3(int2(position.xy), 0)).rgb, 1.f);
  result.alpha = saturate(1.f - transmittance.Load(int3(int2(position.xy), 0)));
  return result;
}
