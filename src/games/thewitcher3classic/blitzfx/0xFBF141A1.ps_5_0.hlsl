// BlitzFX sharpening bypass; selected only when RenoDX RCAS owns sharpening.
Texture2D<float4> scene : register(t0);
float3 main(float4 position : SV_Position) : SV_Target {
  return scene.Load(int3(uint2(position.xy), 0)).rgb;
}
