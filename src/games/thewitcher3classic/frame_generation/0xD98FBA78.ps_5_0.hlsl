// Original Classic texture-only UI shader, decompiled by DevKit, 2026-10-28.
// Used by gameplay icons after closing the radial menu.
Texture2D<float4> tex : register(t0);
SamplerState sampler_tex_s : register(s0);
void main(float2 uv : TEXCOORD0,
          out float4 output : SV_Target0, out float4 coverage : SV_Target1) {
  output = tex.Sample(sampler_tex_s, uv);
  coverage = output.aaaa;
}
