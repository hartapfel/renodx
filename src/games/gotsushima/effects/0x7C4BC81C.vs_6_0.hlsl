float4 main(uint id : SV_VertexID) : SV_Position {
  const float2 uv = float2((id << 1) & 2, id & 2);
  return float4(uv * float2(2.f, -2.f) + float2(-1.f, 1.f), 0.f, 1.f);
}
