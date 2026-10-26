// BlitzFX depth-blur composite: no RGB contribution, native depth write retained.
void main(out float4 color : SV_Target0, out float depth : SV_Depth) { color=0;depth=1; }
