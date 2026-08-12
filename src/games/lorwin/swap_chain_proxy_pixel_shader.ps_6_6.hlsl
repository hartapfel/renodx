#include "./shared.h"

Texture2D t0 : register(t0);
SamplerState s0 : register(s0);

float4 main(float4 vpos : SV_POSITION, float2 uv : TEXCOORD0) : SV_TARGET {
  renodx::draw::Config config = renodx::draw::BuildConfig();

  if (RENODX_TONE_MAP_TYPE == 0.f) {
    config.swap_chain_scaling_nits = renodx::color::bt2408::REFERENCE_WHITE;
  } else {
    config.swap_chain_gamma_correction = renodx::draw::GAMMA_CORRECTION_NONE;
  }

  return float4(renodx::draw::SwapChainPass(t0.Sample(s0, uv).rgb, uv, config), 1.f);
}
