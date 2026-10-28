// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_tex_3__s : register(s3);
Texture2D<float4> tex_3_ : register(t3);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float4 v0 : COLOR0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0;

  r0.x = tex_3_.Sample(sampler_tex_3__s, v1.xy).x;
  o0.xyzw = v0.wwww * r0.xxxx;
  return;
}

void main(
  float4 v0 : COLOR0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, v1, o0);
  coverage = o0.aaaa;
}
