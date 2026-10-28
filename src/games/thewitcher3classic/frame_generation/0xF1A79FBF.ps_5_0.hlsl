// Original Classic solid UI shader, decompiled by DevKit, 2026-10-28.
// Preserve target 0; target 1 accumulates the same source alpha for DLSS FG.
void main(float4 color : COLOR0, float4 opacity : COLOR1,
          out float4 output : SV_Target0, out float4 coverage : SV_Target1) {
  output = float4(color.rgb, color.a * opacity.a);
  coverage = output.aaaa;
}
