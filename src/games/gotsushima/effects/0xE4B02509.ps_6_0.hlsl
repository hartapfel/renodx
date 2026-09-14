#include "../post_effects.hlsli"

Texture2D<float4> scene : register(t0);

float4 main(float4 position : SV_Position) : SV_Target {
  return GhostApplyPostUpscaleEffects(scene, uint2(position.xy));
}
