// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_tex_0__s : register(s0);
SamplerState sampler_tex_1__s : register(s1);
Texture2D<float4> tex_0_ : register(t0);
Texture2D<float4> tex_1_ : register(t1);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float4 v0 : COLOR0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float2 v3 : TEXCOORD2,
  float2 w3 : TEXCOORD3,
  out float4 o0 : SV_Target0)
{
  float4 r0;

  r0.x = tex_0_.Sample(sampler_tex_0__s, v3.xy).w;
  r0.y = tex_1_.Sample(sampler_tex_1__s, w3.xy).w;
  r0.x = r0.x + -r0.y;
  r0.x = v0.x * r0.x + r0.y;
  r0.x = v2.w * r0.x;
  r0.x = v1.w * r0.x + r0.x;
  o0.xyzw = v0.wwww * r0.xxxx;
  return;
}

void main(
  float4 v0 : COLOR0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float2 v3 : TEXCOORD2,
  float2 w3 : TEXCOORD3,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, v1, v2, v3, w3, o0);
  coverage = o0.aaaa;
}
