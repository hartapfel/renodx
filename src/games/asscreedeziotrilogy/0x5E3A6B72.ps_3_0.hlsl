// Native AC2 baseline: instruction tokens match the original SM3 dump.
#include "./ui.hlsli"

float4 g_ConstColor : register(c128);
float4 g_ConstColorAdd : register(c129);
sampler2D s0 : register(s0);

float4 main(float2 texcoord : TEXCOORD) : COLOR {
  float4 o;

  float4 r0;
  float4 r1;
  r0 = tex2D(s0, texcoord.xy);
  r1 = g_ConstColor;
  o = r0 * r1 + g_ConstColorAdd;

  // RenoDX: preserve alpha; blend-state selection is handled by the addon.
  o.rgb = AC2ScaleUI(o);
  return o;
}
