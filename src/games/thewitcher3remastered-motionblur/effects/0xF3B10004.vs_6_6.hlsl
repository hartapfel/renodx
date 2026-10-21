// Private GPU-only camera-constant transfer. The position is fully clipped;
// no pixel shader, render target or depth write is involved.
cbuffer NativeDepthProjection : register(b12) {
  float2 native_depth_scale : packoffset(c21);
  float2 native_depth_transform : packoffset(c22);
};
RWStructuredBuffer<float4> motion_scratch : register(u0, space57);
float4 main(uint vertex : SV_VertexID) : SV_Position {
  if (vertex == 0u) motion_scratch[0] = float4(native_depth_scale, native_depth_transform);
  return float4(2.f, 2.f, 2.f, 1.f);
}
