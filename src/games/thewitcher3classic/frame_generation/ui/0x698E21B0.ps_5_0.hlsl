// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
SamplerState sampler_tex_0__s : register(s0);
SamplerState sampler_tex_1__s : register(s1);
Texture2D<float4> tex_0_ : register(t0);
Texture2D<float4> tex_1_ : register(t1);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;

  r0.xyzw = tex_0_.Sample(sampler_tex_0__s, v0.xy).xyzw;
  r1.xyzw = tex_1_.Sample(sampler_tex_1__s, w0.xy).xyzw;
  r0.xyzw = -r1.xyzw + r0.xyzw;
  r1.xyzw = cmp(float4(0,0,0,0) < r0.xyzw);
  r2.xyzw = cmp(r0.xyzw < float4(0,0,0,0));
  r0.xyzw = frac(r0.xyzw);
  r1.xyzw = (int4)-r1.xyzw + (int4)r2.xyzw;
  r1.xyzw = (int4)r1.xyzw;
  r1.xyzw = float4(1,1,1,1) + r1.xyzw;
  r2.xyzw = cmp(r1.xyzw < float4(-0,-0,-0,-0));
  r1.xyzw = cmp(float4(-0,-0,-0,-0) < r1.xyzw);
  r1.xyzw = (int4)-r2.xyzw + (int4)r1.xyzw;
  r1.xyzw = (int4)r1.xyzw;
  r1.xyzw = float4(1,1,1,1) + r1.xyzw;
  r0.xyzw = r1.xyzw * float4(0.00392156886,0.00392156886,0.00392156886,0.00392156886) + r0.xyzw;
  r1.x = dot(r0.xyz, float3(1,1,1));
  r1.y = cmp(0 < r1.x);
  r1.x = cmp(r1.x < 0);
  r1.x = (int)-r1.y + (int)r1.x;
  r1.x = (int)r1.x;
  r2.xyz = r0.xyz;
  r2.w = 1;
  r0.xyz = float3(1,1,1);
  r2.xyzw = r2.xyzw + -r0.zzzw;
  o0.xyzw = r1.xxxx * r2.xyzw + r0.xyzw;
  return;
}

void main(
  float2 v0 : TEXCOORD0,
  float2 w0 : TEXCOORD1,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, w0, o0);
  coverage = o0.aaaa;
}
