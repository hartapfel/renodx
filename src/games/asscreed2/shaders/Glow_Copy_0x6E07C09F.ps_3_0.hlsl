float Alpha_23 : register(c129);
sampler2D DiffuseAlpha_0;
float IsRimbyDistance_19 : register(c128);
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
	float3 r2;
	r0.xyz = g_EyePosition.xyz + -i.texcoord1.xyz;
	r0.x = dot(r0.xyz, r0.xyz);
	r0.x = 1 / sqrt(r0.x);
	r0.x = 1 / r0.x;
	r0.x = saturate(r0.x * 0.08333333);
	r0.x = r0.x * r0.x;
	r0.y = r0.x * r0.x;
	r0.x = r0.y * r0.x;
	r1.xyz = normalize(i.texcoord5.xyz);
	r2 = normalize(i.texcoord4.xyz);
	r0.y = dot(r1.xyz, r2.xyz);
	r0.y = log2(abs(r0.y));
	r0.yz = r0.yy * float2(0.12, 0.7);
	r0.z = exp2(r0.z);
	r0.y = exp2(r0.y);
	r0.z = -r0.y + r0.z;
	r0.x = r0.z * r0.x;
	r0.x = saturate(IsRimbyDistance_19.x * r0.x + r0.y);
	r0.x = -r0.x + 1;
	r0.x = r0.x * Alpha_23.x;
	r1 = tex2D(DiffuseAlpha_0, i.texcoord.xy);
	r0.y = r1.w * i.color.w;
	r0.z = r1.w + -0.099999994;
	r0.w = abs(r0.y) * abs(r0.y);
	r0.w = r0.w * r0.w;
	r0.y = r0.w * abs(r0.y);
	r0.w = frac(-r0.z);
	r0.z = saturate(r0.w + r0.z);
	r0.y = (-r0.z >= 0) ? 1 : r0.y;
	r0.x = r0.y * r0.x;
	o = r0.x * float4(12, 12, 12, 12);
	o = 1.f - exp2(-max(o, 0.f));
	o.w = saturate(o.w);

	return o;
}
