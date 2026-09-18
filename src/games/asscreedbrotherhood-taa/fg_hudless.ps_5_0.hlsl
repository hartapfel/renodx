// Identical HDR scene encoding plus independently captured HUD opacity.
#define main EncodeHudless
#include "../asscreedeziotrilogy/swap_chain_proxy_pixel_shader.ps_5_0.hlsl"
#undef main
Texture2D<float> transmittance : register(t1);
struct Output { float4 color : SV_Target0; float alpha : SV_Target1; };
Output main(float4 position : SV_Position, float2 uv : TEXCOORD0) {
  Output result;
  result.color = EncodeHudless(position, uv);
  result.alpha = saturate(1.f - transmittance.Load(int3(int2(position.xy), 0)));
  return result;
}
