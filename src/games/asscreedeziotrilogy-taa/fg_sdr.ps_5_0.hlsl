// Preserve native SDR code values. No HDR grading, transfer conversion or lift.
Texture2D<float4> scene : register(t0);
float4 main(float4 position : SV_Position, float2 uv : TEXCOORD0) : SV_Target0 {
  return float4(scene.Load(int3(int2(position.xy), 0)).rgb, 1.f);
}
