// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_tex_0__s : register(s0);
SamplerState sampler_tex_1__s : register(s1);
SamplerState sampler_tex_2__s : register(s2);
Texture2D<float4> tex_0_ : register(t0);
Texture2D<float4> tex_1_ : register(t1);
Texture2D<float4> tex_2_ : register(t2);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  float2 v1 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;

  r0.x = tex_2_.Sample(sampler_tex_2__s, v1.xy).w;
  r1.xyzw = tex_1_.Sample(sampler_tex_1__s, w0.xy).xyzw;
  r0.y = -r1.w * r0.x + 1;
  r0.x = r1.w * r0.x;
  r2.xyzw = tex_0_.Sample(sampler_tex_0__s, v0.xy).xyzw;
  r0.y = r2.w * r0.y + r0.x;
  r0.x = r0.x / r0.y;
  o0.w = r0.y;
  r0.yzw = -r2.xyz + r1.xyz;
  o0.xyz = r0.xxx * r0.yzw + r2.xyz;
  return;
}

void main(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  float2 v1 : TEXCOORD2,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, w0, v1, o0);
  coverage = o0.aaaa;
}
