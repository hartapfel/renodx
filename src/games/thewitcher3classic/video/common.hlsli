#ifndef THEWITCHER3CLASSIC_VIDEO_HLSLI_
#define THEWITCHER3CLASSIC_VIDEO_HLSLI_

#include "../shared.h"

Texture2D<float4> video_y : register(t0);
Texture2D<float4> video_cb : register(t1);
Texture2D<float4> video_cr : register(t2);
SamplerState video_y_sampler : register(s0);
SamplerState video_cb_sampler : register(s1);
SamplerState video_cr_sampler : register(s2);

float3 SampleVideo(float2 uv) {
  // Preserve Classic's native YCbCr matrix and plane sampling.
  float cr = video_cr.Sample(video_cr_sampler, uv).x - (128.f / 255.f);
  float y = video_y.Sample(video_y_sampler, uv).x - (16.f / 255.f);
  float cb = video_cb.Sample(video_cb_sampler, uv).x - (128.f / 255.f);
  return mad(cb, float3(0.f, -0.392f, 2.017f),
             mad(y, 1.164f, cr * float3(1.596f, -0.813f, 0.f)));
}

float3 VideoAutoHDR(float3 color) {
  if (RENODX_TONE_MAP_TYPE != CLASSIC_TONE_MAP_PSYCHOV31
      || RENODX_DIFFUSE_WHITE_NITS <= 0.f || RENODX_PEAK_WHITE_NITS <= 0.f
      || RENODX_GRAPHICS_WHITE_NITS <= 0.f) return color;

  // Match Ezio's BT.1886 SDR reference and Game Brightness curve control.
  // The inverse returns absolute nits at video_peak, not scene-linear RGB.
  const float video_peak = RENODX_PEAK_WHITE_NITS * (203.f / RENODX_DIFFUSE_WHITE_NITS);
  const float display_peak = RENODX_PEAK_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
  color = renodx::tonemap::inverse::bt2446a::BT709(
              renodx::color::gamma::Decode(saturate(color), 2.4f), 100.f, video_peak)
          * (display_peak / video_peak);
  if (RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f) {
    color = max(renodx::color::correct::GamutCompress(color, renodx::color::y::from::BT709(color)), 0.f);
    color *= min(1.f, display_peak / max(renodx::math::Max(color), 1e-6f));
  }
  // Classic's proxy decodes gamma 2.2, scales by UI white, then encodes PQ.
  // It has no Ezio presentation shoulder to invert. Retain signed BT.709 RGB
  // for BT.2020 video colors until the proxy converts the output gamut.
  return renodx::draw::EncodeColor(color, RENODX_SWAP_CHAIN_DECODING);
}

#endif
