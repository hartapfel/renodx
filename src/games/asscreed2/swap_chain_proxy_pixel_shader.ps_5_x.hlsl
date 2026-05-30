#include "./shared.h"

Texture2D t0 : register(t0);
SamplerState s0 : register(s0);

float4 main(float4 vpos: SV_POSITION, float2 uv: TEXCOORD0) : SV_TARGET {
  float4 color = t0.Sample(s0, uv);
  if (RENODX_GAMMA_CORRECTION == 1.f) {
    color.rgb = renodx::color::gamma::DecodeSafe(color.rgb, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == 2.f) {
    color.rgb = renodx::color::gamma::DecodeSafe(color.rgb, 2.4f);
  } else {
    color.rgb = renodx::color::srgb::DecodeSafe(color.rgb);
  }
  color.rgb *= RENODX_GRAPHICS_WHITE_NITS / 80.f;
  color.rgb = renodx::color::bt709::clamp::BT2020(color.rgb);
  return color;
}
