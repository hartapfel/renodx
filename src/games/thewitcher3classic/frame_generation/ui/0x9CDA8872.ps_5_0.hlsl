// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
cbuffer Constants : register(b0)
{
  float4 compx : packoffset(c0);
  float4 compy : packoffset(c1);
  float4 mapScale : packoffset(c2);
  float2 scale : packoffset(c3);
}

SamplerState sampler_maptex_s : register(s0);
SamplerState sampler_tex_s : register(s1);
Texture2D<float4> maptex : register(t0);
Texture2D<float4> tex : register(t1);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;

  r0.xy = v0.xy * mapScale.xy + -mapScale.zw;
  r0.zw = cmp(float2(0,0) >= r0.xy);
  r0.zw = r0.zw ? float2(1,1) : 0;
  r0.z = dot(r0.zw, float2(1,1));
  r1.xy = cmp(r0.xy >= float2(1,1));
  r2.xyzw = maptex.Sample(sampler_maptex_s, r0.xy).xyzw;
  r0.xy = r1.xy ? float2(1,1) : 0;
  r0.x = dot(r0.xy, float2(1,1));
  r0.x = r0.z + r0.x;
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.y = 1 + -r0.x;
  r0.y = 0.5 * r0.y;
  r0.xyzw = r2.xyzw * r0.xxxx + r0.yyyy;
  r1.xyzw = compx.xyzw * r0.xyzw;
  r0.xyzw = compy.xyzw * r0.xyzw;
  r0.y = dot(float4(1,1,1,1), r0.xyzw);
  r0.x = dot(float4(1,1,1,1), r1.xyzw);
  r0.xy = float2(-0.5,-0.5) + r0.xy;
  r0.xy = r0.xy * scale.xy + v0.xy;
  r0.zw = cmp(float2(0,0) >= r0.xy);
  r0.zw = r0.zw ? float2(1,1) : 0;
  r0.z = dot(r0.zw, float2(1,1));
  r1.xy = cmp(r0.xy >= float2(1,1));
  r2.xyzw = tex.Sample(sampler_tex_s, r0.xy).xyzw;
  r0.xy = r1.xy ? float2(1,1) : 0;
  r0.x = dot(r0.xy, float2(1,1));
  r0.x = r0.z + r0.x;
  r0.x = min(1, r0.x);
  r0.x = 1 + -r0.x;
  r0.y = 1 + -r0.x;
  r1.xyzw = tex.Sample(sampler_tex_s, v0.xy).xyzw;
  r1.xyzw = r1.xyzw * r0.yyyy;
  o0.xyzw = r2.xyzw * r0.xxxx + r1.xyzw;
  return;
}

void main(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, o0);
  coverage = o0.aaaa;
}
