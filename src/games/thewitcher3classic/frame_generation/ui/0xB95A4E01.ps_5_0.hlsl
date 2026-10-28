// Classic Scaleform shader from the original DXBC dump (3Dmigoto).
// Preserve native color; capture source opacity in the existing UI draw.
cbuffer Constants : register(b0)
{
  float4 cxmul : packoffset(c0);
}



// 3Dmigoto declarations
#define cmp -


void OriginalUI(
  out float4 o0 : SV_Target0)
{
  o0.xyzw = cxmul.xyzw;
  return;
}

void main(
  out float4 o0 : SV_Target0,
  out float4 coverage : SV_Target1) {
  OriginalUI(o0);
  coverage = o0.aaaa;
}
