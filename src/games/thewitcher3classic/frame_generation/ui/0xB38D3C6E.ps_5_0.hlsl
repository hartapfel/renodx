// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
cbuffer Constants : register(b0)
{
  float mipLevels : packoffset(c0);
  float2 textureDims : packoffset(c1);
}

SamplerState sampler_tex_s : register(s0);
Texture2D<float4> tex : register(t0);


// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;

  r0.xyzw = textureDims.xxyy * v0.xyxy;
  r0.xy = ddx_coarse(r0.xy);
  r0.zw = ddy_coarse(r0.zw);
  r1.x = dot(r0.xy, r0.xy);
  r1.y = dot(r0.zw, r0.zw);
  r1.x = max(r1.x, r1.y);
  r1.x = log2(r1.x);
  r1.x = r1.x * 0.5 + -1;
  r1.x = max(0, r1.x);
  r1.y = mipLevels + -1;
  r1.x = min(r1.x, r1.y);
  r1.x = exp2(r1.x);
  r0.xyzw = r0.xyzw / r1.xxxx;
  r0.z = dot(r0.zw, r0.zw);
  r0.x = dot(r0.xy, r0.xy);
  r0.x = max(r0.x, r0.z);
  r0.x = sqrt(r0.x);
  r0.x = -r0.x * 0.5 + 1;
  r0.x = max(0, r0.x);
  r0.y = 1.88235307 * r0.x;
  r0.xz = r0.yy * float2(-1,1) + float2(2,-2);
  r0.xyz = saturate(r0.xyz);
  r1.xyz = tex.Sample(sampler_tex_s, v0.xy).xyz;
  r1.xyz = float3(-0.501960993,-0,-0.501960993) + r1.xyz;
  r0.w = -r1.x * 0.186592996 + r1.y;
  r2.y = saturate(-r1.z * 0.466295987 + r0.w);
  r2.xz = saturate(r1.zx * float2(1.56864798,1.84835196) + r1.yy);
  o0.xyz = r2.xyz * float3(0.00100000005,0.00100000005,0.00100000005) + r0.xyz;
  o0.w = 1.00100005;
  return;
}

void main(
  float2 v0 : TEXCOORD0,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, o0);
  coverage = o0.aaaa;
}
