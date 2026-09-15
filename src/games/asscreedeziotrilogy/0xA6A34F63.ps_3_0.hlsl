// Native AC2 baseline: instruction tokens match the original SM3 dump.
#include "./eagle_vision.hlsli"

sampler2D BloomFilter : register(s1);
sampler2D Source : register(s0);
sampler2D StarFilter : register(s2);
float g_BloomScale : register(c0);
float g_StarScale : register(c1);

float4 main(float2 texcoord : TEXCOORD) : COLOR {
  float4 o;

  float4 r0;
  float4 r1;
  r0 = tex2D(StarFilter, texcoord.xy);
  r0.xyz = r0.xyz * float3(2, 2, 2) + float3(-1, -1, -1);
  r0.xyz = r0.xyz * g_StarScale.xxx;
  r1 = tex2D(BloomFilter, texcoord.xy);
  r1.xyz = r1.xyz * float3(2, 2, 2) + float3(-1, -1, -1);
  r0.xyz = r1.xyz * g_BloomScale.xxx + r0.xyz;
  r1 = tex2D(Source, texcoord.xy);
  // Original: o.xyz = saturate(r0.xyz + r1.xyz);
  o.xyz = AC2CompositeEagleVision(r1.xyz, r0.xyz);
  o.w = 1;

  return o;
}
