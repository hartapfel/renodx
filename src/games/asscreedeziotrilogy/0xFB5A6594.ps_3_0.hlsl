// Native AC2 baseline: instruction tokens match the original SM3 dump.
#include "./ui.hlsli"

sampler2D AlphaTexture_1 : register(s1);
sampler2D BaseTexture_0 : register(s0);
float4 ConstantColor_2 : register(c128);

struct PS_IN {
  float2 texcoord : TEXCOORD;
  float4 color : COLOR;
};

float4 main(PS_IN i) : COLOR {
  float4 o;

  float4 r0;
  float4 r1;
  float4 r2;
  r0 = ConstantColor_2 * i.color;
  r1 = tex2D(AlphaTexture_1, i.texcoord.xy);
  r2 = tex2D(BaseTexture_0, i.texcoord.xy);
  r2.w = r1.w * r2.w;
  o = r0 * r2;

  // RenoDX: preserve alpha; blend-state selection is handled by the addon.
  o.rgb = AC2ScaleUI(o);
  return o;
}
