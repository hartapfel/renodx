float GlowIntensity_12 : register(c134);
sampler2D Operator49_1 : register(s1);
float3x3 Operator51_2_matrix : register(c128);
float3x3 Operator53_3_matrix : register(c131);
sampler2D diffusemap_0;

float4 main(float2 texcoord : TEXCOORD) : COLOR
{
	float4 o;

	float4 r0;
	float4 r1;
	r0.xyz = texcoord.xyx * float3(1, 1, 0) + float3(0, 0, 1);
	r1.x = dot(r0.xyz, transpose(Operator51_2_matrix)[0].xyz);
	r1.y = dot(r0.xyz, transpose(Operator51_2_matrix)[1].xyz);
	r1 = tex2D(Operator49_1, r1.xy);
	r1.x = dot(r0.xyz, transpose(Operator53_3_matrix)[0].xyz);
	r1.y = dot(r0.xyz, transpose(Operator53_3_matrix)[1].xyz);
	r0 = tex2D(Operator49_1, r1.xy);
	r0.x = r1.z * r0.z;
	r1.x = pow(abs(r0.x), 0.19999999);
	r0 = tex2D(diffusemap_0, texcoord.xy);
	r0.y = -r1.x + r0.w;
	r0.x = r0.x * GlowIntensity_12.x;
	r0.y = r0.y * 0.5;
	r0.x = r0.y * r0.x;
	o = r0.x * float4(15, 15, 15, 15);
	o = 1.f - exp2(-max(o, 0.f));
	o.w = saturate(o.w);

	return o;
}
