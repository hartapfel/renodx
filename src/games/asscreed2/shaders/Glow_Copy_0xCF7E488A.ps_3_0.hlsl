float Alpha_36 : register(c140);
float4 CharacterPosition_4 : register(c130);
float DistanceMax_1 : register(c128);
float DistanceMin_2 : register(c129);
float GlowIntensity_42 : register(c141);
float3x3 Operator118_26_matrix : register(c137);
float3x3 Operator131_24_matrix : register(c134);
sampler2D Operator25_0;
sampler2D Operator2_2 : register(s2);
float3x3 Operator51_10_matrix : register(c131);
sampler2D Operator88_1;

struct PS_IN
{
	float2 texcoord : TEXCOORD;
	float4 color : COLOR;
	float3 texcoord1 : TEXCOORD1;
};

float4 main(PS_IN i) : COLOR
{
	float4 o;

	float4 r0;
	float4 r1;
	float4 r2;
	float r3;
	r0.xyz = i.texcoord1.xzy * float3(0.015915493, 0.015915493, 0.015915493) + float3(0.5, 0.5, 0.5);
	r0.xyz = frac(r0.xyz);
	r0.xyz = r0.xyz * float3(6.283185, 6.283185, 6.283185) + float3(-3.1415925, -3.1415925, -3.1415925);
	r1.y = sin(r0.x);
	r2.y = sin(r0.y);
	r3 = cos(r0.z);
	r0.y = r2.y * r3.x;
	r0.x = r1.y * r2.y;
	r0.z = 1;
	r1.x = dot(r0.xyz, transpose(Operator131_24_matrix)[0].xyz);
	r1.y = dot(r0.xyz, transpose(Operator131_24_matrix)[1].xyz);
	r0 = tex2D(Operator88_1, r1.xy);
	r0.yzw = i.texcoord.xyx * float3(1, 1, 0) + float3(0, 0, 1);
	r1.x = dot(r0.yzw, transpose(Operator51_10_matrix)[0].xyz);
	r1.y = dot(r0.yzw, transpose(Operator51_10_matrix)[1].xyz);
	r1 = tex2D(Operator25_0, r1.xy);
	r1.x = -r1.x + 1;
	r1.x = r0.x * r1.x;
	r1.y = pow(abs(r0.x), 2.5);
	r0.x = -r1.y + 1;
	r2.x = dot(r0.yzw, transpose(Operator118_26_matrix)[0].xyz);
	r2.y = dot(r0.yzw, transpose(Operator118_26_matrix)[1].xyz);
	r2 = tex2D(Operator2_2, r2.xy);
	r0.y = abs(r2.x) * abs(r2.x);
	r0.y = r0.y * abs(r2.x);
	r0.y = r0.y * r1.x;
	r0.x = r0.x * r0.y;
	r0.x = r0.x * Alpha_36.x;
	r0.yzw = CharacterPosition_4.xyz + -i.texcoord1.xyz;
	r0.y = dot(r0.yzw, r0.yzw);
	r0.y = 1 / sqrt(r0.y);
	r0.y = 1 / r0.y;
	r0.y = r0.y + -DistanceMin_2.x;
	r0.y = 1 / r0.y;
	r1.x = DistanceMin_2.x;
	r0.z = -r1.x + DistanceMax_1.x;
	r0.y = saturate(r0.y * r0.z);
	r0.x = r0.x * r0.y;
	r0.x = r0.x * i.color.w;
	r0.x = r0.x * GlowIntensity_42.x;
	o = r0.x * float4(0.049999997, 0.049999997, 0.049999997, 0.049999997);
	o = 1.f - exp2(-max(o, 0.f));
	o.w = saturate(o.w);

	return o;
}
