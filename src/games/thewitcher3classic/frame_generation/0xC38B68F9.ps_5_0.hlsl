// Original Classic glyph shader, plus an independent UI coverage attachment.
// Original bytecode decompiled by DevKit, 2026-10-28. Target 0 is unchanged.
Texture2D<float4> tex : register(t0);
SamplerState sampler_tex_s : register(s0);
void main(float2 uv : TEXCOORD0, float4 color : COLOR0,
          out float4 output : SV_Target0, out float4 coverage : SV_Target1) {
  output = float4(color.rgb, color.a * tex.Sample(sampler_tex_s, uv).r);
  coverage = output.aaaa;
}
