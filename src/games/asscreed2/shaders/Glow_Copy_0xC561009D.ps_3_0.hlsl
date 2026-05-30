sampler2D Operator143_0;
float3x3 Operator228_4_matrix : register(c128);

float4 main(float2 texcoord : TEXCOORD) : COLOR
{
	float4 o;

	float4 r0;
	float2 r1;
	r0.xyz = texcoord.xyx * float3(1, 1, 0) + float3(0, 0, 1);
	r1.x = dot(r0.xyz, transpose(Operator228_4_matrix)[0].xyz);
	r1.y = dot(r0.xyz, transpose(Operator228_4_matrix)[1].xyz);
	r0 = tex2D(Operator143_0, r1.xy);
	r0.x = saturate(dot(float3(0.33299997, 0.33299997, 0.33299997), r0.xyz));
	r0.x = -r0.x + 1;
	r1.x = pow(r0.x, 1.1999999);
	o = r1.x * float4(800, 800, 800, 800);
	o = 1.f - exp2(-max(o, 0.f));
	o.w = saturate(o.w);

	return o;
}
