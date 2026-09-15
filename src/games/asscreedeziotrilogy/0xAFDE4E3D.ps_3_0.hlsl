// Brotherhood transformed alpha-mask HUD; native baseline audited with FXC.
#include "./ui.hlsli"

sampler2D AlphaTexture_1 : register(s1);
sampler2D BaseTexture_0 : register(s0);
float4 ConstantColor_2 : register(c128);
float4 ConstantTileOffset_11 : register(c130);
float4 ConstantTileRatio_9 : register(c129);

struct PS_IN {
  float2 texcoord : TEXCOORD;
  float4 color : COLOR;
};

float4 main(PS_IN i) : COLOR {
  float4 o;

  float4 r0;
  float4 r1;
  r0.xy = i.texcoord.xy * float2(1, -1) + float2(0, 1);
  r1.xy = ConstantTileRatio_9.xy;
  r0.xy = r0.xy * r1.xy + ConstantTileOffset_11.xy;
  r0 = tex2D(AlphaTexture_1, r0.xy);
  r1 = tex2D(BaseTexture_0, i.texcoord.xy);
  r1.w = r0.w * r1.w;
  r0 = ConstantColor_2 * i.color;
  o = r1 * r0;

  // RenoDX: preserve alpha; blend-state selection is handled by the addon.
  o.rgb = AC2ScaleUI(o);
  return o;
}
