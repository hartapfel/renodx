Texture2D<float4> Resolved : register(t0);
Texture2D<float4> SignedScene : register(t1);
SamplerState ResidualSampler : register(s0);
cbuffer Residual : register(b0) {
  float2 input_size;
  float2 output_size;
  float2 jitter;
  float restore_signed;
  float padding;
}
float4 main(float4 position : SV_Position) : SV_Target {
  float3 color = Resolved.Load(int3((int2)position.xy, 0)).rgb;
  if (restore_signed != 0.f) {
    uint width, height;
    SignedScene.GetDimensions(width, height);
    // Same signed-residual contract as Ezio: NGX reconstructs nonnegative light;
    // restore the current negative component at its unjittered output location.
    // Clamp to the active viewport, not the unused output-sized pool region.
    float2 pixel = clamp(position.xy / output_size * input_size + jitter, 0.5f, input_size - 0.5f);
    float3 source = SignedScene.SampleLevel(ResidualSampler, pixel / float2(width, height), 0).rgb;
    color += min(isfinite(source) ? source : 0.f, 0.f);
  }
  return float4(clamp(color, -65504.f, 65504.f), 1.f);
}
