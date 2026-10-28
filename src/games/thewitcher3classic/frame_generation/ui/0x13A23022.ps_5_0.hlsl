// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_srctex_s : register(s0);
SamplerState sampler_tex_s : register(s1);
Texture2D<float4> srctex : register(t0);
Texture2D<float4> tex : register(t1);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;

  r0.xyzw = tex.Sample(sampler_tex_s, v0.xy).zxwy;
  r1.xz = r0.yw;
  r1.yw = float2(0.125,0.375);
  r2.xyzw = srctex.Sample(sampler_srctex_s, r1.xy).xyzw;
  r1.xyzw = srctex.Sample(sampler_srctex_s, r1.zw).xyzw;
  r1.xyzw = r2.xyzw + r1.xyzw;
  r0.yw = float2(0.625,0.875);
  r2.xyzw = srctex.Sample(sampler_srctex_s, r0.xy).xyzw;
  r0.xyzw = srctex.Sample(sampler_srctex_s, r0.zw).xyzw;
  r1.xyzw = r2.xyzw + r1.xyzw;
  o0.xyzw = r1.xyzw + r0.xyzw;
  return;
}

void main(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, o0);
  coverage = o0.aaaa;
}
