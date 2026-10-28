// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  float4 v0 : COLOR0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0;

  r0.x = v2.w * v0.w;
  o0.xyzw = v1.wwww * r0.xxxx + r0.xxxx;
  return;
}

void main(
  float4 v0 : COLOR0,
  float4 v1 : TEXCOORD0,
  float4 v2 : TEXCOORD1,
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(v0, v1, v2, o0);
  coverage = o0.aaaa;
}
