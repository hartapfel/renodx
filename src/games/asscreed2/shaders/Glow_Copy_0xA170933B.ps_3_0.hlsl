float4 Color1_6 : register(c128);
float4 Color2_7 : register(c129);
float DistanceVisible_60 : register(c138);
float4 GlobalPosition_57 : register(c137);
sampler2D Normal_0;
sampler2D Operator115_1;
float3x3 Operator117_46_matrix : register(c131);
float3x3 Operator119_48_matrix : register(c134);
float TimeSource_19 : register(c130);

struct PS_IN
{
	float2 texcoord : TEXCOORD;
	float3 texcoord1 : TEXCOORD1;
};

float4 main(PS_IN i) : COLOR
{
	float4 o;

	float4 r0;
	float4 r1;
	float4 r2;
	float3 r3;
	r0.xyz = i.texcoord1.xyz * float3(0.06366197, 0.06366197, 0.06366197) + float3(0.5, 0.5, 0.5);
	r0.xyz = frac(r0.xyz);
	r0.xyz = r0.xyz * float3(6.283185, 6.283185, 6.283185) + float3(-3.1415925, -3.1415925, -3.1415925);
	r1.y = sin(r0.x);
	r2.y = sin(r0.y);
	r3.y = sin(r0.z);
	r0.x = r1.y + r2.y;
	r0.x = r3.y + r0.x;
	r0.y = dot(-i.texcoord1.xyz, -i.texcoord1.xyz);
	r0.y = 1 / sqrt(r0.y);
	r0.y = 1 / r0.y;
	r0.x = r0.x * 3 + r0.y;
	r0.z = 0.900001;
	r0.x = TimeSource_19.x * r0.z + r0.x;
	r0.x = r0.x * 0.15915494 + 0.5;
	r0.x = frac(r0.x);
	r0.x = r0.x * 6.283185 + -3.1415925;
	r1.y = sin(r0.x);
	r0.x = saturate(r1.y + 1);
	r1.x = pow(r0.x, 0.099999994);
	r0 = tex2D(Normal_0, i.texcoord.xy);
	r0.x = dot(float3(-0.65094453, -0.65094453, -0.3905667), r0.xyz);
	r1.y = saturate(pow(abs(r0.x), 0.099999994));
	r0.x = -r1.y + 1;
	r0.x = r0.x * 300;
	r2.xyz = Color1_6.xyz;
	r0.yzw = -r2.xyz + Color2_7.xyz;
	r0.xyz = r0.xxx * r0.yzw + Color1_6.xyz;
	r2.xyz = lerp(float3(0.968627, 0.80784297, 0.49411798), r0.xyz, r1.xxx);
	r0.xyz = r2.xyz * float3(0.59999996, 0.59999996, 0.59999996);
	r1.xyz = i.texcoord.xyx * float3(1, 1, 0) + float3(0, 0, 1);
	r2.x = dot(r1.xyz, transpose(Operator117_46_matrix)[0].xyz);
	r2.y = dot(r1.xyz, transpose(Operator117_46_matrix)[1].xyz);
	r2 = tex2D(Operator115_1, r2.xy);
	r3.x = dot(r1.xyz, transpose(Operator119_48_matrix)[0].xyz);
	r3.y = dot(r1.xyz, transpose(Operator119_48_matrix)[1].xyz);
	r1 = tex2D(Operator115_1, r3.xy);
	r3 = max(r2.xyz, r1.xyz);
	r1.xyz = r3.xyz * float3(4, 4, 4);
	r2.xyz = saturate(max(r1.xyz, float3(0.39999998, 0.39999998, 0.39999998)));
	r0.xyz = r0.xyz * r2.xyz;
	r0.x = dot(float3(0.33299997, 0.33332998, 0.33332998), r0.xyz);
	r0.x = r0.x * r0.x;
	r0.zw = float2(1, 0);
	r1 = i.texcoord1.xyzx * r0.zzzw + -GlobalPosition_57;
	r0.y = dot(r1, r1);
	r0.y = 1 / sqrt(r0.y);
	r0.y = 1 / r0.y;
	r0.z = 1 / DistanceVisible_60.x;
	r0.y = saturate(r0.z * r0.y);
	r0.y = -r0.y + 1;
	r0.x = r0.y * r0.x;
	o = r0.x * float4(0.01, 0.01, 0.01, 0.01);
	o = 1.f - exp2(-max(o, 0.f));
	o.w = saturate(o.w);

	return o;
}
