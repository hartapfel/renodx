Texture2D<float4> Resolved : register(t0);
float4 main(float4 position : SV_Position) : SV_Target {
  return float4(Resolved.Load(int3((int2)position.xy, 0)).rgb, 1.f);
}
