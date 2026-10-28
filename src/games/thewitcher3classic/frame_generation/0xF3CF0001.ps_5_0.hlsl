// Cached SL bidirectional lens map, generated at half output dimensions.
#include "../effects/lens_mapping.hlsli"
cbuffer Lens : register(b0) { float2 output_size; float intensity; float padding; }
float4 main(float4 position : SV_Position, float2 uv : TEXCOORD0) : SV_Target {
  // The green channel defines the lens geometry; red/blue retain their authored
  // chromatic dispersion. SL accepts one geometric map, not three color maps.
  const float2 source = WitcherLensSource(uv, uint2(output_size), 1.275f, intensity);
  float2 inverse = uv - (source - uv);
  // Solve F(inverse)=uv using the full 2x2 Jacobian. Only evaluated when the
  // lens settings change, never once per rendered frame. Tested over 0..5x.
  [unroll] for (uint i = 0; i < 8; ++i) {
    const float e = 0.001f;
    const float2 error = WitcherLensSource(inverse, uint2(output_size), 1.275f, intensity) - uv;
    const float2 dx = (WitcherLensSource(inverse + float2(e,0), uint2(output_size), 1.275f, intensity)
                    - WitcherLensSource(inverse - float2(e,0), uint2(output_size), 1.275f, intensity)) / (2.f*e);
    const float2 dy = (WitcherLensSource(inverse + float2(0,e), uint2(output_size), 1.275f, intensity)
                    - WitcherLensSource(inverse - float2(0,e), uint2(output_size), 1.275f, intensity)) / (2.f*e);
    const float determinant = dx.x*dy.y - dy.x*dx.y;
    inverse -= float2(dy.y*error.x - dy.x*error.y, dx.x*error.y - dx.y*error.x) / determinant;
  }
  // NVIDIA: RG = distorted -> undistorted offset; BA = inverse offset.
  // UV units match the unscaled normalized motion vectors supplied to FG.
  return float4(source - uv, inverse - uv);
}
