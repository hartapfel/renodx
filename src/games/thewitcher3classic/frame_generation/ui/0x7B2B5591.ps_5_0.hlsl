// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
cbuffer Constants : register(b0)
{
  float mipLevels : packoffset(c0);
  float2 textureDims : packoffset(c1);
}

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
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;

  r0.xyzw = textureDims.xxyy * v0.xyxy;
  r0.xy = ddx_coarse(r0.xy);
  r0.zw = ddy_coarse(r0.zw);
  r1.x = dot(r0.xy, r0.xy);
  r1.y = dot(r0.zw, r0.zw);
  r1.x = max(r1.x, r1.y);
  r1.x = log2(r1.x);
  r1.x = r1.x * 0.5 + -1;
  r1.x = max(0, r1.x);
  r1.y = mipLevels + -1;
  r1.x = min(r1.x, r1.y);
  r1.x = exp2(r1.x);
  r0.xyzw = r0.xyzw / r1.xxxx;
  r0.z = dot(r0.zw, r0.zw);
  r0.x = dot(r0.xy, r0.xy);
  r0.x = max(r0.x, r0.z);
  r0.x = sqrt(r0.x);
  r0.x = -r0.x * 0.5 + 1;
  r0.x = max(0, r0.x);
  r0.y = 1.88235307 * r0.x;
  r0.xz = r0.yy * float2(-1,1) + float2(2,-2);
  r0.xyz = saturate(r0.xyz);
  r1.x = tex_2_.Sample(sampler_tex_2__s, v0.xy).x;
  r1.x = -0.501960814 + r1.x;
  r1.xyz = float3(1.59599996,-0.813000023,0) * r1.xxx;
  r1.w = tex_0_.Sample(sampler_tex_0__s, v0.xy).x;
  r1.w = -0.0627451017 + r1.w;
  r1.xyz = r1.www * float3(1.16400003,1.16400003,1.16400003) + r1.xyz;
  r1.w = tex_1_.Sample(sampler_tex_1__s, v0.xy).x;
  r1.w = -0.501960814 + r1.w;
  r1.xyz = r1.www * float3(0,-0.39199999,2.01699996) + r1.xyz;
  r1.w = tex_3_.Sample(sampler_tex_3__s, v0.xy).x;
  r0.w = 1;
  o0.xyzw = r1.xyzw * float4(0.00100000005,0.00100000005,0.00100000005,0.00100000005) + r0.xyzw;
  return;
}

void main(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, o0);
  coverage = o0.aaaa;
}
