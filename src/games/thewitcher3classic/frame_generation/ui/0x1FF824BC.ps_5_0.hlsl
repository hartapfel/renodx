// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_alphatex_s : register(s0);
SamplerState sampler_srctex_s : register(s1);
Texture2D<float4> alphatex : register(t0);
Texture2D<float4> srctex : register(t1);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  float2 w2 : TEXCOORD3,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;

  r0.x = alphatex.Sample(sampler_alphatex_s, w2.xy).w;
  r1.xyzw = srctex.Sample(sampler_srctex_s, v2.xy).xyzw;
  r0.xyzw = r1.xyzw * r0.xxxx;
  r1.xyz = v1.xyz;
  r1.w = 1;
  r0.xyzw = r1.xyzw * r0.xyzw;
  r0.xyzw = v1.wwww * r0.xyzw;
  o0.xyzw = v0.xyzw * r0.wwww + r0.xyzw;
  return;
}

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  float2 w2 : TEXCOORD3,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, v1, v2, w2, o0);
  coverage = o0.aaaa;
}
