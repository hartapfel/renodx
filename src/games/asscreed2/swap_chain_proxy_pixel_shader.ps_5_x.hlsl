#include "./shared.h"

Texture2D<float4> t0 : register(t0);
SamplerState s0 : register(s0);

float4 main(float4 position : SV_POSITION, float2 uv : TEXCOORD0) : SV_TARGET {
  // Decode Vanilla/Off as sRGB or PsychoV as gamma 2.2, then present HDR10.
  return renodx::draw::SwapChainPass(t0.Sample(s0, uv));
}
