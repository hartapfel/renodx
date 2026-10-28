// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float4 v0 : COLOR0,
  float4 v1 : COLOR1,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0;

  r0.xyz = v3.xyz;
  r0.w = 1;
  r0.xyzw = v0.xyzw * r0.xyzw;
  r0.xyzw = v3.wwww * r0.xyzw;
  r0.xyzw = v2.xyzw * r0.wwww + r0.xyzw;
  r0.w = v1.w * r0.w;
  o0.xyz = r0.xyz * r0.www;
  o0.w = r0.w;
  return;
}

void main(
  float4 v0 : COLOR0,
  float4 v1 : COLOR1,
  float4 v2 : TEXCOORD0,
  float4 v3 : TEXCOORD1,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, v1, v2, v3, o0);
  coverage = o0.aaaa;
}
