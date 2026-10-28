// Original Classic textured UI shader. Preserve the multiply/add expression.
Texture2D<float4> tex : register(t0);
SamplerState sampler_tex_s : register(s0);
void main(float4 add : TEXCOORD0, float4 multiply : TEXCOORD1, float2 uv : TEXCOORD2,
          out float4 output : SV_Target0, out float4 coverage : SV_Target1) {
  output = tex.Sample(sampler_tex_s, uv) * multiply + add;
  coverage = output.aaaa;
}
