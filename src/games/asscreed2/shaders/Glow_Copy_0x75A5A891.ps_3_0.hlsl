float3x3 GlowTexture1Anim_2_matrix : register(c129);
float Intensity_7 : register(c132);
float Operator7_1 : register(c128);
sampler2D diffusemap_0;

struct PS_IN
{
	float2 texcoord : TEXCOORD;
	float4 color : COLOR;
};

float4 main(PS_IN i) : COLOR
{
	float4 o;

	float4 r0;
	float2 r1;
	r0.xyz = i.texcoord.xyx * float3(1, 1, 0) + float3(0, 0, 1);
	r1.x = dot(r0.xyz, transpose(GlowTexture1Anim_2_matrix)[0].xyz);
	r1.y = dot(r0.xyz, transpose(GlowTexture1Anim_2_matrix)[1].xyz);
	r0 = tex2D(diffusemap_0, r1.xy);
	r0.x = r0.w * Operator7_1.x;
	r0.x = r0.x * i.color.w;
	o = r0.x * Intensity_7.x;
	o = 1.f - exp2(-max(o, 0.f));
	o.w = saturate(o.w);

	return o;
}
