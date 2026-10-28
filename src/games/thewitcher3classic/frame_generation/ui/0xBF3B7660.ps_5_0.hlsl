// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_tex_0__s : register(s0);
SamplerState sampler_tex_1__s : register(s1);
SamplerState sampler_tex_2__s : register(s2);
SamplerState sampler_tex_3__s : register(s3);
Texture2D<float4> tex_0_ : register(t0);
Texture2D<float4> tex_1_ : register(t1);
Texture2D<float4> tex_2_ : register(t2);
Texture2D<float4> tex_3_ : register(t3);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float4 v0 : COLOR0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float2 v3 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0;

  r0.x = tex_2_.Sample(sampler_tex_2__s, v3.xy).x;
  r0.x = -0.501960814 + r0.x;
  r0.xyz = float3(1.59599996,-0.813000023,0) * r0.xxx;
  r0.w = tex_0_.Sample(sampler_tex_0__s, v3.xy).x;
  r0.w = -0.0627451017 + r0.w;
  r0.xyz = r0.www * float3(1.16400003,1.16400003,1.16400003) + r0.xyz;
  r0.w = tex_1_.Sample(sampler_tex_1__s, v3.xy).x;
  r0.w = -0.501960814 + r0.w;
  r0.xyz = r0.www * float3(0,-0.39199999,2.01699996) + r0.xyz;
  r0.w = tex_3_.Sample(sampler_tex_3__s, v3.xy).x;
  r0.xyzw = r0.xyzw * v2.xyzw + v1.xyzw;
  o0.w = v0.w * r0.w;
  o0.xyz = r0.xyz;
  return;
}

void main(
  float4 v0 : COLOR0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  float2 v3 : TEXCOORD2,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, v1, v2, v3, o0);
  coverage = o0.aaaa;
}
