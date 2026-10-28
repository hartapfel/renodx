// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
cbuffer Constants : register(b0)
{
  float4 cxadd : packoffset(c0);
  float4x4 cxmul : packoffset(c1);
}

SamplerState sampler_tex_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;

  r0.xyzw = tex.Sample(sampler_tex_s, v0.xy).xyzw;
  r1.x = dot(r0.xyzw, cxmul._m00_m10_m20_m30);
  r1.y = dot(r0.xyzw, cxmul._m01_m11_m21_m31);
  r1.z = dot(r0.xyzw, cxmul._m02_m12_m22_m32);
  r1.w = dot(r0.xyzw, cxmul._m03_m13_m23_m33);
  r0.x = cxadd.w + r0.w;
  r0.xyzw = cxadd.xyzw * r0.xxxx + r1.xyzw;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r0.w;
  return;
}

void main(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, o0);
  coverage = o0.aaaa;
}
