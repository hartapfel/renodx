float Alpha_33 : register(c130);
sampler2D DiffuseMap_0;
float Glow1_35 : register(c131);
float Glow2_36 : register(c132);
sampler2D NormalMap_3 : register(s3);
sampler2D SkinShader_2 : register(s2);
sampler2D SkinshaderTile_1;
float SpaceTransparency_28 : register(c129);
float TileScale_9 : register(c128);

struct PS_IN
{
	float2 texcoord : TEXCOORD;
	float4 color : COLOR;
	float3 texcoord1 : TEXCOORD1;
	float3 texcoord2 : TEXCOORD2;
	float3 texcoord3 : TEXCOORD3;
	float3 texcoord4 : TEXCOORD4;
	float3 texcoord5 : TEXCOORD5;
};

float4 main(PS_IN i) : COLOR
{
	float4 o;

	float4 r0;
	float4 r1;
	float4 r2;
	r0.xy = TileScale_9.xx * i.texcoord.xy;
	r0 = tex2D(SkinshaderTile_1, r0.xy);
	r0.x = r0.w * r0.x;
	r0.xy = r0.xy + float2(-0.5, -0.5);
	r0.xy = r0.xy + r0.xy;
	r0.w = dot(r0.xy, -r0.xy) + 1;
	r0.w = 1 / sqrt(r0.w);
	r0.z = 1 / r0.w;
	r1 = tex2D(SkinShader_2, i.texcoord.xy);
	r2.xyz = lerp(float3(0, 0, 1), r0.xyz, r1.zzz);
	r0 = tex2D(NormalMap_3, i.texcoord.xy);
	r0.x = r0.w * r0.x;
	r0.xy = r0.xy + float2(-0.5, -0.5);
	r0.xy = r0.xy + r0.xy;
	r0.w = dot(r0.xy, -r0.xy) + 1;
	r0.w = 1 / sqrt(r0.w);
	r0.z = 1 / r0.w;
	r0.xyz = r0.xyz + r2.xyz;
	r0.xyz = r0.xyz * float3(1, 1, 0.7);
	r1.xyz = normalize(r0.xyz);
	r0.xyz = normalize(i.texcoord3.xyz);
	r0.xyz = r0.xyz * r1.yyy;
	r2.xyz = normalize(i.texcoord2.xyz);
	r0.xyz = r1.xxx * r2.xyz + r0.xyz;
	r2.xyz = normalize(i.texcoord4.xyz);
	r0.xyz = r1.zzz * r2.xyz + r0.xyz;
	r1.xyz = normalize(r0.xyz);
	r0.xyz = normalize(i.texcoord5.xyz);
	r0.x = saturate(dot(r0.xyz, r1.xyz));
	r1.x = pow(r0.x, 0.29999998);
	r0.x = r0.x * r0.x;
	r0.x = r0.x * 16;
	r2 = tex2D(DiffuseMap_0, i.texcoord.xy);
	r0.y = r2.w * i.color.w;
	r0.y = r1.x * r0.y;
	r0.y = r0.y * 0.79999995;
	r0.z = i.texcoord1.z * 111.408455 + 0.5;
	r0.z = frac(r0.z);
	r0.z = r0.z * 6.283185 + -3.1415925;
	r1.y = sin(r0.z);
	r0.z = r1.y * SpaceTransparency_28.x;
	r0.w = frac(r0.z);
	r0.z = saturate(-r0.w + r0.z);
	r0.y = (-r0.z >= 0) ? 12 : r0.y;
	r0.y = r0.y * Alpha_33.x;
	r0.z = frac(r0.x);
	r0.x = -r0.z + r0.x;
	r0.x = r0.x * 0.0625;
	r1.x = Glow1_35.x;
	r0.z = -r1.x + Glow2_36.x;
	r0.x = r0.x * r0.z + Glow1_35.x;
	o = r0.y * r0.x;
	o = 1.f - exp2(-max(o, 0.f));
	o.w = saturate(o.w);

	return o;
}
