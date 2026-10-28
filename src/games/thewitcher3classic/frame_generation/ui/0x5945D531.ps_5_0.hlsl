// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_tex_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float4 v0 : COLOR0,
  float4 v1 : COLOR1,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float2 v4 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0;

  r0.x = tex.Sample(sampler_tex_s, v4.xy).w;
  r0.x = -v0.w + r0.x;
  r0.x = v1.x * r0.x + v0.w;
  r0.x = r0.x * v3.w + v2.w;
  o0.xyzw = v1.wwww * r0.xxxx;
  return;
}

void main(
  float4 v0 : COLOR0,
  float4 v1 : COLOR1,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  float2 v4 : TEXCOORD2,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, v1, v2, v3, v4, o0);
  coverage = o0.aaaa;
}
