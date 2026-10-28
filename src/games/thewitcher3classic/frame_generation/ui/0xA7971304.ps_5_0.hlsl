// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_tex_0__s : register(s0);
SamplerState sampler_tex_1__s : register(s1);
Texture2D<float4> tex_0_ : register(t0);
Texture2D<float4> tex_1_ : register(t1);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;

  r0.xyzw = tex_1_.Sample(sampler_tex_1__s, w0.xy).xyzw;
  r1.x = 1 + -r0.w;
  r2.xyzw = tex_0_.Sample(sampler_tex_0__s, v0.xy).xyzw;
  r1.x = r2.w * r1.x + r0.w;
  r0.w = r0.w / r1.x;
  o0.w = r1.x;
  r0.xyz = -r2.xyz + r0.xyz;
  o0.xyz = r0.www * r0.xyz + r2.xyz;
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
