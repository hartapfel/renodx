#include "./presentation.hlsli"

// Identical native video shader in AC2, Brotherhood and Revelations.
float4 consts : register(c0);
sampler2D tex0 : register(s0);

float4 main(float2 texcoord : TEXCOORD) : COLOR {
  float3 color = tex2D(tex0, texcoord).rgb;
  if (CUSTOM_INJECTION_VERSION == 30.f && RENODX_TONE_MAP_TYPE == 1.f
      && CUSTOM_VIDEO_AUTO_HDR == 1.f
      && RENODX_DIFFUSE_WHITE_NITS > 0.f && RENODX_PEAK_WHITE_NITS > 0.f) {
    // BT.2446A takes linear SDR, with a BT.1886 (gamma 2.4) reference.
    // Brightness adjusts the inverse curve while its endpoint stays at peak.
    const float video_peak = RENODX_PEAK_WHITE_NITS * (203.f / RENODX_DIFFUSE_WHITE_NITS);
    color = renodx::tonemap::inverse::bt2446a::BT709(
                renodx::color::gamma::Decode(saturate(color), 2.4f), 100.f, video_peak)
            * (AC2DisplayPeak() / video_peak);
    if (RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f) {
      // The inverse operates in BT.2020; honor a BT.709 display target too.
      color = max(renodx::color::correct::GamutCompress(color, renodx::color::y::from::BT709(color)), 0.f);
      color *= min(1.f, AC2DisplayPeak() / max(renodx::math::Max(color), 1e-6f));
    }
    // The final proxy fits the whole composition once. Undo that shoulder
    // here so the already display-mapped video is not compressed a second time.
    color = renodx::draw::EncodeColor(
        AC2ExpandForPresentation(color, AC2DisplayPeak()), RENODX_SWAP_CHAIN_DECODING);
  }
  // Video texture alpha is unused; c0.w owns the game's fades.
  return float4(color, consts.w);
}
