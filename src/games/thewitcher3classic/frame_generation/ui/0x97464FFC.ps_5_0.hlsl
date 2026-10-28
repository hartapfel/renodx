// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_dsttex_s : register(s0);
SamplerState sampler_srctex_s : register(s1);
Texture2D<float4> dsttex : register(t0);
Texture2D<float4> srctex : register(t1);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;

  r0.xyzw = dsttex.Sample(sampler_dsttex_s, w0.xy).xyzw;
  r1.xyzw = srctex.Sample(sampler_srctex_s, v0.xy).xyzw;
  r2.xyz = r1.xyz + -r0.xyz;
  r0.xyz = -r1.xyz + r0.xyz;
  o0.xyz = max(r2.xyz, r0.xyz);
  r0.x = 1 + -r1.w;
  o0.w = r0.x * r0.w + r1.w;
  return;
}

void main(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, w0, o0);
  coverage = o0.aaaa;
}
