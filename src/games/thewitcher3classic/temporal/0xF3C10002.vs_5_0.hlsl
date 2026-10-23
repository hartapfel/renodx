// Private fullscreen conversion into the game's original TAA target.
float4 main(uint id : SV_VertexID) : SV_Position {
  return float4(float2((id << 1) & 2, id & 2) * float2(2.f, -2.f) + float2(-1.f, 1.f), 0.f, 1.f);
}
