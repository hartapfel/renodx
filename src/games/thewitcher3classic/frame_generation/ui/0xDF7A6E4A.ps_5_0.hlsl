// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
cbuffer Constants : register(b0)
{
  float4 fsize : packoffset(c0);
  float4 offset : packoffset(c1);
  float4 srctexscale : packoffset(c2);
  float4 texscale : packoffset(c3);
}

SamplerState sampler_gradtex_s : register(s0);
SamplerState sampler_srctex_s : register(s1);
SamplerState sampler_tex_s : register(s2);
Texture2D<float4> gradtex : register(t0);
Texture2D<float4> srctex : register(t1);
Texture2D<float4> tex : register(t2);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;

  r0.x = 0;
  r0.y = -fsize.x;
  while (true) {
    r0.z = cmp(fsize.x < r0.y);
    if (r0.z != 0) break;
    r1.x = offset.x + r0.y;
    r2.x = r0.x;
    r2.y = -fsize.y;
    while (true) {
      r0.z = cmp(fsize.y < r2.y);
      if (r0.z != 0) break;
      r1.y = offset.y + r2.y;
      r0.zw = r1.xy * texscale.xy + v2.xy;
      r0.z = tex.SampleLevel(sampler_tex_s, r0.zw, 0).w;
      r2.x = r2.x + r0.z;
      r2.y = 1 + r2.y;
    }
    r0.x = r2.x;
    r0.y = 1 + r0.y;
  }
  r0.x = fsize.w * r0.x;
  r0.x = saturate(fsize.z * r0.x);
  r0.y = 0;
  r0.xyzw = gradtex.Sample(sampler_gradtex_s, r0.xy).xyzw;
  r1.xy = srctexscale.xy * v2.xy;
  r1.x = srctex.SampleLevel(sampler_srctex_s, r1.xy, 0).w;
  r1.w = 9.99999975e-005 * r1.x;
  r2.x = saturate(r0.w);
  r0.w = 1;
  r2.y = 1 + -r2.x;
  r1.xyz = float3(0,0,0);
  r1.xyzw = r2.yyyy * r1.xyzw;
  r0.xyzw = r0.xyzw * r2.xxxx + r1.xyzw;
  r1.xyz = v1.xyz;
  r1.w = 1;
  r0.xyzw = r1.xyzw * r0.xyzw;
  r0.xyzw = v1.wwww * r0.xyzw;
  o0.xyzw = v0.xyzw * r0.wwww + r0.xyzw;
  return;
}

void main(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, v1, v2, o0);
  coverage = o0.aaaa;
}
