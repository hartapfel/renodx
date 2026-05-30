float3x3 Alpha2UV_2_matrix : register(c131);
sampler2D Alpha2_1 : register(s1);
float AlphaRimCoeffician_33 : register(c140);
float AlphaRimInvert_39 : register(c142);
float AlphaRim_35 : register(c141);
float Alpha_41 : register(c143);
float3x3 DiffuseUV_1_matrix : register(c128);
sampler2D Diffuse_0;
float GlowIntensity_49 : register(c144);
float MaxAlpha_11 : register(c136);
float MinAlpha_15 : register(c137);
float NearFallofMax_24 : register(c139);
float NearFallofMin_22 : register(c138);
float UseAlpha2GrayScale_8 : register(c135);
float UseAlpha2_3 : register(c134);
float4 g_EyePosition : register(c12);

struct PS_IN
{
	float2 texcoord : TEXCOORD;
	float4 color : COLOR;
	float3 texcoord1 : TEXCOORD1;
	float3 texcoord4 : TEXCOORD4;
	float3 texcoord5 : TEXCOORD5;
};

float4 main(PS_IN i) : COLOR
{
	float4 o;

	float4 r0;
	float4 r1;
	float r2;
	float3 r3;
	float3 r4;
	r0.xyz = i.texcoord.xyx * float3(1, 1, 0) + float3(0, 0, 1);
	r1.x = dot(r0.xyz, transpose(DiffuseUV_1_matrix)[0].xyz);
	r1.y = dot(r0.xyz, transpose(DiffuseUV_1_matrix)[1].xyz);
	r1 = tex2D(Diffuse_0, r1.xy);
	r1.x = dot(r0.xyz, transpose(Alpha2UV_2_matrix)[0].xyz);
	r1.y = dot(r0.xyz, transpose(Alpha2UV_2_matrix)[1].xyz);
	r0 = tex2D(Alpha2_1, r1.xy);
	r2 = lerp(r1.w, r0.w, UseAlpha2_3.x);
	r0.x = dot(float3(0.32999998, 0.32999998, 0.32999998), r0.xyz);
	r1.x = lerp(r2.x, r0.x, UseAlpha2GrayScale_8.x);
	r0.x = -r1.x + 1;
	r2 = 1;
	r0.y = r2.x + -MaxAlpha_11.x;
	r0.x = saturate(-r0.y + r0.x);
	r0.y = saturate(r1.x + -MinAlpha_15.x);
	r0.z = r1.x * Alpha_41.x;
	r1.x = min(r0.y, r0.x);
	r3 = normalize(i.texcoord4.xyz);
	r4 = normalize(i.texcoord5.xyz);
	r0.x = dot(r3.xyz, r4.xyz);
	r1.y = pow(abs(r0.x), AlphaRimCoeffician_33.x);
	r0.x = r1.y + -1;
	r0.x = AlphaRim_35.x * r0.x + r2.x;
	r0.y = saturate(r0.x);
	r0.y = -r0.y + 1;
	r1.y = lerp(r0.x, r0.y, AlphaRimInvert_39.x);
	r0.x = r0.z * r1.y;
	r0.x = r0.x * i.color.w;
	r0.yzw = g_EyePosition.xyz + -i.texcoord1.xyz;
	r0.y = dot(r0.yzw, r0.yzw);
	r0.y = 1 / sqrt(r0.y);
	r0.y = 1 / r0.y;
	r0.y = r0.y + -NearFallofMin_22.x;
	r2 = NearFallofMin_22.x;
	r0.z = -r2.x + NearFallofMax_24.x;
	r0.z = 1 / r0.z;
	r0.y = saturate(r0.z * r0.y);
	r0.x = r0.x * r0.y;
	r0.x = r0.x * r1.x;
	r1.x = Alpha_41.x;
	r0.y = r1.x * GlowIntensity_49.x;
	r0.y = r0.y * r1.y;
	o = r0.x * r0.y;
	o = 1.f - exp2(-max(o, 0.f));
	o.w = saturate(o.w);

	return o;
}
