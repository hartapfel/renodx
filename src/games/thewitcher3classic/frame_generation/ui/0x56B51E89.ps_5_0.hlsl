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
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;

  r0.xyzw = tex_0_.Sample(sampler_tex_0__s, v1.xy).xyzw;
  r1.xyzw = tex_1_.Sample(sampler_tex_1__s, w1.xy).xyzw;
  r0.xyzw = -r1.xyzw + r0.xyzw;
  r0.xyzw = v0.xxxx * r0.xyzw + r1.xyzw;
  r0.w = v0.w * r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r0.w;
  return;
}

void main(
  float4 v0 : COLOR0,
  float2 v1 : TEXCOORD0,
  float2 w1 : TEXCOORD1,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, v1, w1, o0);
  coverage = o0.aaaa;
}
