#include "../common.hlsli"

sampler2D BloomFilter : register(s1);
sampler2D Source;
sampler2D StarFilter : register(s2);
float g_BloomScale;
float g_StarScale;

float4 main(float2 texcoord : TEXCOORD) : COLOR
{
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
	r1.xyz = InvertIntermediatePass(r1.xyz);
	o.xyz = r0.xyz + r1.xyz;
	if (RENODX_TONE_MAP_TYPE == 0.f) {
		o.xyz = saturate(o.xyz);
	}
	o.xyz = AC2ClampIntermediateToBT2020(o.xyz);
	o.xyz = ClampAndRenderIntermediatePass(o.xyz);
	o.w = 1;

	return o;
}
