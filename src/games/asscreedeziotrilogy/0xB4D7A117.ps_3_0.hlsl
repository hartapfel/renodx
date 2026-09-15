// Native AC2 baseline: instruction tokens match the original SM3 dump.
#include "./bloom.hlsli"

float4 g_SampleOffsets[16] : register(c0);
sampler2D s0 : register(s0);

float4 main(float2 texcoord : TEXCOORD) : COLOR {
  float4 o;

  float4 r0;
  float4 r1;
  r0.xy = g_SampleOffsets[0].xy + texcoord.xy;
  r0 = tex2D(s0, r0.xy);
  r0.rgb = AC2BloomSeed(r0.rgb);
  r1.xy = g_SampleOffsets[1].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[2].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[3].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[4].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[5].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[6].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[7].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[8].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[9].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[10].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[11].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[12].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[13].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[14].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  r1.xy = g_SampleOffsets[15].xy + texcoord.xy;
  r1 = tex2D(s0, r1.xy);
  r1.rgb = AC2BloomSeed(r1.rgb);
  r0 = r0 + r1;
  o = r0 * float4(0.0625, 0.0625, 0.0625, 0.0625);

  return o;
}
