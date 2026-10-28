// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
cbuffer Constants : register(b0)
{
  float4 fsize : packoffset(c0);
  float4 offset : packoffset(c1);
  float4 scolor : packoffset(c2);
  float4 scolor2 : packoffset(c3);
  float4 srctexscale : packoffset(c4);
  float4 texscale : packoffset(c5);
}

SamplerState sampler_srctex_s : register(s0);
SamplerState sampler_tex_s : register(s1);
Texture2D<float4> srctex : register(t0);
Texture2D<float4> tex : register(t1);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float4 v0 : TEXCOORD0,
  float4 v1 : TEXCOORD1,
  float2 v2 : TEXCOORD2,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3;

  r0.xy = float2(0,0);
  r0.z = -fsize.x;
  while (true) {
    r0.w = cmp(fsize.x < r0.z);
    if (r0.w != 0) break;
    r1.x = offset.x + r0.z;
    r2.xy = r0.yx;
    r2.z = -fsize.y;
    while (true) {
      r0.w = cmp(fsize.y < r2.z);
      if (r0.w != 0) break;
      r1.y = offset.y + r2.z;
      r1.zw = r1.xy * texscale.xy + v2.xy;
      r0.w = tex.SampleLevel(sampler_tex_s, r1.zw, 0).w;
      r2.y = r2.y + r0.w;
      r1.yz = -r1.xy * texscale.xy + v2.xy;
      r0.w = tex.SampleLevel(sampler_tex_s, r1.yz, 0).w;
      r2.x = r2.x + r0.w;
      r2.z = 1 + r2.z;
    }
    r0.xy = r2.yx;
    r0.z = 1 + r0.z;
  }
  r0.xy = fsize.ww * r0.xy;
  r0.xy = -r0.xy * fsize.zz + float2(1,1);
  r0.xy = saturate(r0.xy + -r0.yx);
  r0.zw = srctexscale.xy * v2.xy;
  r0.z = srctex.SampleLevel(sampler_srctex_s, r0.zw, 0).w;
  r1.w = 9.99999975e-005 * r0.z;
  r2.x = scolor.w;
  r2.y = scolor2.w;
  r0.zw = r2.xy * r0.xy;
  r3.xyzw = scolor2.xyzw * r0.wwww;
  r3.xyzw = scolor.xyzw * r0.zzzz + r3.xyzw;
  r0.x = -r0.x * r2.x + 1;
  r0.x = -r0.y * r2.y + r0.x;
  r1.xyz = float3(0,0,0);
  r0.xyzw = r1.xyzw * r0.xxxx + r3.xyzw;
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
