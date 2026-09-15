// Brotherhood white gradient; native baseline audited against FXC disassembly.
#include "./shared.h"

sampler2D additiveBiasSampler : register(s1);
float4 g_ColorBottom : register(c2);
float4 g_ColorTop : register(c1);
float4 g_ScaleOffsetSkyCoverage : register(c0);
sampler2D sourceSampler : register(s0);

float4 main(float2 texcoord : TEXCOORD) : COLOR {
  float4 o;

  float4 r0;
  float4 r1;
  float4 r2;
  float4 r3 = tex2D(sourceSampler, texcoord.xy);
  // Zero bypasses the whole overlay, including its original SDR clamp.
  if (CUSTOM_INJECTION_VERSION == 30.f && CUSTOM_WHITE_GRADIENT_INTENSITY == 0.f) return r3;
  r0.xy = texcoord.xy * float2(1, -1) + float2(0, 1);
  r0 = tex2D(additiveBiasSampler, r0.xy);
  r1 = r0 + float4(0.5, 0.5, 0.5, 0.5);
  r0 = r0 + float4(-0.5, -0.5, -0.5, -0.5);
  r0 = r0 * g_ScaleOffsetSkyCoverage.x;
  r0 = r0 + r0;
  r2 = frac(r1);
  r1 = r1 + -r2;
  r2.y = -1;
  r2 = r2.y + g_ColorTop;
  r2 = r1 * r2 + float4(1, 1, 1, 1);
  r1 = -r1 + float4(1, 1, 1, 1);

  // RenoDX: preserve the post-LUT HDR scene, as in the Brotherhood DX11 mod.
  // Original: r2 = saturate(r0 * r2 + r3);
  r2 = r0 * r2 + r3;
  if (CUSTOM_INJECTION_VERSION == 30.f && RENODX_TONE_MAP_TYPE == 1.f) {
    r2.rgb = max(r2.rgb, 0.f);
    r2.a = saturate(r2.a);
  } else {
    r2 = saturate(r2);
  }
  r0 = saturate(abs(r0));
  r0 = r0 * r1;
  o = r0 * g_ColorBottom + r2;

  // Keep the full-strength and invalid-injection paths identical to the port.
  if (CUSTOM_INJECTION_VERSION == 30.f && CUSTOM_WHITE_GRADIENT_INTENSITY < 1.f) {
    o = lerp(r3, o, CUSTOM_WHITE_GRADIENT_INTENSITY);
  }
  return o;
}
