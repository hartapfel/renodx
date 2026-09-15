// Native AC2 baseline: instruction tokens match the original SM3 dump.
#include "./ui.hlsli"

float4 g_ConstColor : register(c128);
float4 g_ConstColorAdd : register(c129);
sampler2D s0 : register(s0);

struct PS_IN {
  float2 texcoord : TEXCOORD;
  float4 color : COLOR;
};

float4 main(PS_IN i) : COLOR {
  float4 o;

  float4 r0;
  float4 r1;
  r0 = tex2D(s0, i.texcoord.xy);
  r0 = r0 * i.color;
  r1 = g_ConstColor;
  o = r0 * r1 + g_ConstColorAdd;

  // RenoDX: preserve alpha; blend-state selection is handled by the addon.
  o.rgb = AC2ScaleUI(o);
  return o;
}
