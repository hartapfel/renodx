// Original Classic texture/vertex-opacity UI shader, decompiled by DevKit, 2026-10-28.
// Preserve target 0; target 1 accumulates the same source alpha for DLSS FG.
Texture2D<float4> tex : register(t0);
SamplerState sampler_tex_s : register(s0);
void main(float4 color : COLOR0, float2 uv : TEXCOORD0,
          out float4 output : SV_Target0, out float4 coverage : SV_Target1) {
  output = tex.Sample(sampler_tex_s, uv);
  output.a *= color.a;
  coverage = output.aaaa;
}
