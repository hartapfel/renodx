// Native sharpening bypass. RCAS runs after reconstruction in final grading.
// Keep the original center sampling, viewport constants and opaque alpha.
Texture2D<float4> t0 : register(t0);
SamplerState s0_s : register(s0);
cbuffer cb3 : register(b3) { float4 cb3[3]; }
void main(float4 position : SV_Position0, out float4 color : SV_Target0) {
  color = float4(t0.SampleLevel(s0_s, (trunc(position.xy) + 0.5f) / cb3[0].zw, 0).rgb, 1.f);
}
