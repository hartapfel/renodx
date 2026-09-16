#include "./presentation.hlsli"

Texture2D<float4> t0 : register(t0);
SamplerState s0 : register(s0);

float4 main(float4 position : SV_POSITION, float2 uv : TEXCOORD0) : SV_TARGET {
  // The native shader owns PsychoV/LUT grading. Fit the preserved FP16 HDR
  // composition smoothly after the game's later effects, then encode HDR10.
  float4 color = t0.Sample(s0, uv);
  // FP16 composition removed the original SDR backbuffer's implicit clamp.
  // Vanilla restores it after bloom/effects/UI, before HDR10 transport.
  if (CUSTOM_INJECTION_VERSION == 30.f && RENODX_TONE_MAP_TYPE == 0.f) color.rgb = saturate(color.rgb);
  if (CUSTOM_INJECTION_VERSION == 30.f && RENODX_TONE_MAP_TYPE == 1.f
      && RENODX_DIFFUSE_WHITE_NITS > 0.f && RENODX_PEAK_WHITE_NITS > 0.f) {
    float3 target = renodx::color::bt2020::from::BT709(
        renodx::draw::DecodeColor(color.rgb, RENODX_SWAP_CHAIN_DECODING));
    // FP16 rounding of signed BT.709 can put a BT.2020 boundary color just
    // below zero. Repair it in linear light; gamma-domain compression would
    // magnify that tiny error into visible brightness/chroma changes.
    target = max(renodx::color::correct::GamutCompress(target, renodx::color::y::from::BT2020(target)), 0.f);
    target = max(renodx::color::bt2020::from::BT709(AC2FitForPresentation(
        renodx::color::bt709::from::BT2020(target))), 0.f);
    renodx::draw::Config config = renodx::draw::BuildConfig();
    config.swap_chain_decoding = renodx::draw::ENCODING_NONE;
    config.swap_chain_decoding_color_space = renodx::color::convert::COLOR_SPACE_BT2020;
    return float4(renodx::draw::SwapChainPass(target, 0.f.xx, config), 1.f);
  }
  return renodx::draw::SwapChainPass(color);
}
