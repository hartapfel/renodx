#ifndef SRC_GAMES_THEWITCHER3REMASTERED_VIDEO_HLSLI_
#define SRC_GAMES_THEWITCHER3REMASTERED_VIDEO_HLSLI_

#include "./shared.h"
#include "../../shaders/inverse_tonemap.hlsl"

Texture2D<float4> witcher_video : register(t0, space51);

float4 WitcherReadVideo(float2 position) {
  float4 video = witcher_video.Load(int3(position, 0));
  // Native blending stores premultiplied gamma RGB. Decode straight RGB first
  // so fades can be composed in linear light, independently of the subtitles.
  video.rgb = video.a > 0.f ? saturate(video.rgb / video.a) : 0.f;
  return video;
}

float3 WitcherVideoNits(float3 color, float native_gamma) {
  if (CUSTOM_VIDEO_AUTO_HDR == 0.f) {
    return renodx::color::bt2020::from::BT709(pow(color, native_gamma)) * RENODX_DIFFUSE_WHITE_NITS;
  }
  // Same BT.2446A curve and 203-nit brightness anchor as Ezio Trilogy.
  // Its presentation shoulder is game-specific; this output already writes PQ
  // directly, so no inverse presentation shoulder is required here.
  float video_peak = RENODX_PEAK_WHITE_NITS * (203.f / max(RENODX_DIFFUSE_WHITE_NITS, 1.f));
  color = renodx::tonemap::inverse::bt2446a::BT709(
              renodx::color::gamma::Decode(color, 2.4f), 100.f, video_peak)
          * (RENODX_PEAK_WHITE_NITS / video_peak);
  if (RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f) {
    color = max(renodx::color::correct::GamutCompress(color, renodx::color::y::from::BT709(color)), 0.f);
    color *= min(1.f, RENODX_PEAK_WHITE_NITS / max(renodx::math::Max(color), 1e-6f));
  }
  return renodx::color::bt2020::from::BT709(color);
}

float3 WitcherCompositeVideo(float3 scene_bt2020, float2 position, float native_gamma) {
  float4 video = WitcherReadVideo(position);
  if (video.a <= 0.f) return scene_bt2020;
  return lerp(scene_bt2020, WitcherVideoNits(video.rgb, native_gamma) / RENODX_DIFFUSE_WHITE_NITS, video.a);
}

#endif
