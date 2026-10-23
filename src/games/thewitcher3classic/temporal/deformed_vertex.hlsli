ByteAddressBuffer PreviousVertices : register(t124);
cbuffer DeformedMetadata : register(b8) { uint vertex_bytes, vertex_stride, vertex_offset, vertex_history; }
cbuffer DeformedWorld : register(b9) { float4 previous_deformed_world[8]; }
cbuffer PreviousView : register(b10) { float4 previous_view[16]; }
cbuffer PreviousFrame : register(b11) { float4 previous_frame[269]; }

float4 PreviousDeformedClip(uint vertex, out float valid) {
  valid = vertex_history != 0 && vertex_stride >= 12 && vertex_bytes >= 12
          && vertex <= (vertex_bytes - 12) / max(vertex_stride, 1u);
  if (valid == 0.f) return float4(0, 0, 0, -1);
  const float4 local = float4(asfloat(PreviousVertices.Load3(vertex_offset + vertex * vertex_stride)), 1);
  const float4 world = float4(dot(previous_deformed_world[0], local),
                              dot(previous_deformed_world[1], local), dot(previous_deformed_world[2], local), 1);
  float4 clip = float4(dot(previous_view[0], world), dot(previous_view[1], world),
                      dot(previous_view[2], world), dot(previous_view[3], world));
  clip.xy -= previous_frame[15].xy * clip.w;
  return clip;
}
