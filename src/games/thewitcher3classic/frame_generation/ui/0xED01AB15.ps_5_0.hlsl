// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
cbuffer Constants : register(b0)
{
  float4x4 cxmul : packoffset(c0);
  float4x4 cxmul1 : packoffset(c4);
}

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

  r0.xyzw = tex_0_.Sample(sampler_tex_0__s, v0.xy).xyzw;
  r1.x = dot(r0.xyzw, cxmul._m00_m10_m20_m30);
  r1.y = dot(r0.xyzw, cxmul._m01_m11_m21_m31);
  r1.z = dot(r0.xyzw, cxmul._m02_m12_m22_m32);
  r1.w = dot(r0.xyzw, cxmul._m03_m13_m23_m33);
  r0.xyzw = tex_1_.Sample(sampler_tex_1__s, w0.xy).xyzw;
  r2.x = dot(r0.xyzw, cxmul1._m00_m10_m20_m30);
  r2.y = dot(r0.xyzw, cxmul1._m01_m11_m21_m31);
  r2.z = dot(r0.xyzw, cxmul1._m02_m12_m22_m32);
  r2.w = dot(r0.xyzw, cxmul1._m03_m13_m23_m33);
  o0.xyzw = r2.xyzw + r1.xyzw;
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
