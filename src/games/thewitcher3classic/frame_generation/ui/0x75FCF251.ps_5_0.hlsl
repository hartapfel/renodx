// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_tex_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float4 v0 : COLOR0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0;

  r0.xyz = tex.Sample(sampler_tex_s, v1.xy).xyz;
  r0.xyz = float3(-0.501960993,-0,-0.501960993) + r0.xyz;
  r0.w = -r0.x * 0.186592996 + r0.y;
  o0.y = saturate(-r0.z * 0.466295987 + r0.w);
  o0.xz = saturate(r0.zx * float2(1.56864798,1.84835196) + r0.yy);
  o0.w = v0.w;
  return;
}

void main(
  float4 v0 : COLOR0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, v1, o0);
  coverage = o0.aaaa;
}
