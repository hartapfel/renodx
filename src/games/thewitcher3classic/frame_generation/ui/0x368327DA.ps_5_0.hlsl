// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_dsttex_s : register(s0);
SamplerState sampler_srctex_s : register(s1);
Texture2D<float4> dsttex : register(t0);
Texture2D<float4> srctex : register(t1);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2,r3,r4,r5;

  r0.xyzw = dsttex.Sample(sampler_dsttex_s, w0.xy).xyzw;
  r1.xyz = cmp(r0.xyz >= float3(0.5,0.5,0.5));
  r2.xyz = r1.xyz ? float3(0,0,0) : float3(1,1,1);
  r1.xyz = r1.xyz ? float3(1,1,1) : 0;
  r3.xyzw = float4(1,1,1,1) + -r0.xyzw;
  r4.xyzw = srctex.Sample(sampler_srctex_s, v0.xy).xyzw;
  r5.xyzw = float4(1,1,1,1) + -r4.xyzw;
  r5.xyz = r5.xyz + r5.xyz;
  r3.xyz = -r5.xyz * r3.xyz + float3(1,1,1);
  r5.xyz = r4.xyz * r3.www;
  r2.xyz = r3.xyz * r2.xyz;
  r3.xyz = r4.xyz * r0.xyz;
  r3.xyz = r3.xyz + r3.xyz;
  r1.xyz = r3.xyz * r1.xyz + r2.xyz;
  r1.xyz = r1.xyz * r4.www + r5.xyz;
  o0.w = r0.w * r5.w + r4.w;
  o0.xyz = r0.xyz * r5.www + r1.xyz;
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
