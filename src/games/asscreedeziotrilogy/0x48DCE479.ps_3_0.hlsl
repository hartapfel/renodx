// Native AC2 baseline: instruction tokens match the original SM3 dump.
#include "./common.hlsli"

float3 g_PreLutOffset : register(c1);
float3 g_PreLutScale : register(c0);
sampler2D s0 : register(s0);
sampler3D s1 : register(s1);

float4 main(float2 texcoord : TEXCOORD) : COLOR {
  float4 o;

  float4 r0;
  float3 r1;
  r0 = tex2D(s0, texcoord.xy);
  // RenoDX: grade the preserved HDR scene before the native LUT limit.
  if (CUSTOM_INJECTION_VERSION == 30.f && RENODX_TONE_MAP_TYPE == 1.f
      && RENODX_DIFFUSE_WHITE_NITS > 0.f && RENODX_PEAK_WHITE_NITS > 0.f) {
    return float4(AC2ToneMapScene(r0.rgb, s1, g_PreLutScale, g_PreLutOffset), 0.f);
  }
  // Restore the original UNORM scene range before the vanilla LUT transform.
  if (CUSTOM_INJECTION_VERSION == 30.f && RENODX_TONE_MAP_TYPE == 0.f) r0.rgb = saturate(r0.rgb);
  r1 = g_PreLutScale.xyz;
  r0.xyz = r0.xyz * r1.xyz + g_PreLutOffset.xyz;
  r0 = tex3D(s1, r0.xyz);
  o.xyz = r0.xyz;
  o.w = 0;

  return o;
}
