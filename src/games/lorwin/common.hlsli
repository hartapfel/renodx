#ifndef SRC_GAMES_LORWIN_COMMON_HLSLI_
#define SRC_GAMES_LORWIN_COMMON_HLSLI_

#include "./shared.h"

namespace lorwin {

static const float TONE_MAP_TYPE_VANILLA = 0.f;
static const float TONE_MAP_TYPE_NEUTWO = 1.f;

float GetSettingOrDefault(float value, float fallback) {
  return value == 0.f ? fallback : value;
}

float3 ApplyUserColorGrading(float3 color, bool apply_saturation = true) {
  renodx::color::grade::Config config = renodx::color::grade::config::Create(
      GetSettingOrDefault(RENODX_TONE_MAP_EXPOSURE, 1.f),
      GetSettingOrDefault(RENODX_TONE_MAP_HIGHLIGHTS, 1.f),
      GetSettingOrDefault(RENODX_TONE_MAP_SHADOWS, 1.f),
      GetSettingOrDefault(RENODX_TONE_MAP_CONTRAST, 1.f),
      0.10f * pow(RENODX_TONE_MAP_FLARE, 10.f),
      apply_saturation ? GetSettingOrDefault(RENODX_TONE_MAP_SATURATION, 1.f) : 1.f,
      0.f,
      RENODX_TONE_MAP_HUE_SHIFT,
      0.f.xxx,
      renodx::color::grade::config::hue_correction_type::INPUT,
      -1.f * (RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f));

  return renodx::color::grade::config::ApplyUserColorGrading(color, config);
}

float GetPeakRatio() {
  return max(
      RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f),
      1.f + 1e-3f);
}

float GetNeutwoWhiteClip(float peak) {
  return max(RENODX_TONE_MAP_WHITE_CLIP, peak + 0.001f);
}

float3 ClampBT709ToBT2020(float3 color) {
  return renodx::color::bt709::from::BT2020(
      max(renodx::color::bt2020::from::BT709(color), 0.f.xxx));
}

float3 ApplyBlowout(float3 color, float reference_luminance) {
  if (RENODX_TONE_MAP_BLOWOUT == 0.f) return color;

  float3 perceptual = renodx::color::oklab::from::BT709(color);
  perceptual.yz *= lerp(
      1.f,
      0.f,
      saturate(pow(saturate(reference_luminance), 1.f - RENODX_TONE_MAP_BLOWOUT)));
  return renodx::color::bt709::from::OkLab(perceptual);
}

bool UseVanillaFilmGrain() {
  return RENODX_TONE_MAP_TYPE == TONE_MAP_TYPE_VANILLA || CUSTOM_FILM_GRAIN_TYPE == 0.f;
}

float3 ApplySceneGrading(float3 ungraded_color, float3 graded_color) {
  if (RENODX_TONE_MAP_TYPE == TONE_MAP_TYPE_VANILLA) return graded_color;
  return lerp(ungraded_color, graded_color, RENODX_SCENE_GRADE_STRENGTH);
}

float3 ApplyPerceptualFilmGrain(float3 color, float2 position) {
  if (RENODX_TONE_MAP_TYPE == TONE_MAP_TYPE_VANILLA || CUSTOM_FILM_GRAIN_TYPE == 0.f || CUSTOM_FILM_GRAIN_STRENGTH <= 0.f) return color;

  return renodx::effects::ApplyFilmGrain(
      color,
      position,
      CUSTOM_RANDOM,
      CUSTOM_FILM_GRAIN_STRENGTH * 0.03f);
}

float3 ApplyNeutwo(float3 untonemapped) {
  untonemapped = max(untonemapped, 0.f.xxx);

  float3 graded = ApplyUserColorGrading(untonemapped, true);
  const float peak_ratio = GetPeakRatio();
  const float white_clip = GetNeutwoWhiteClip(peak_ratio);

  float3 tonemapped;
  if (RENODX_TONE_MAP_PER_CHANNEL == 1.f) {
    tonemapped = renodx::tonemap::neutwo::PerChannel(graded, peak_ratio.xxx, white_clip.xxx);
  } else {
    tonemapped = renodx::color::bt709::from::BT2020(
        renodx::tonemap::neutwo::BT2020(
            renodx::color::bt2020::from::BT709(graded),
            peak_ratio,
            white_clip));
  }

  const float y = renodx::color::y::from::BT709(tonemapped) / peak_ratio;
  tonemapped = ApplyBlowout(tonemapped, y);

  return ClampBT709ToBT2020(tonemapped);
}

float3 ApplyToneMap(float3 untonemapped) {
  if (RENODX_TONE_MAP_TYPE == TONE_MAP_TYPE_NEUTWO) {
    return ApplyNeutwo(untonemapped);
  }

  return saturate(untonemapped);
}

float3 ToneMapAndRenderIntermediatePass(float3 color) {
  if (RENODX_GAMMA_CORRECTION == 1.f) {
    color = renodx::color::gamma::DecodeSafe(color, 2.2f);
    color = ApplyToneMap(color);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::gamma::EncodeSafe(color, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == 2.f) {
    color = renodx::color::gamma::DecodeSafe(color, 2.4f);
    color = ApplyToneMap(color);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::gamma::EncodeSafe(color, 2.4f);
  } else {
    color = renodx::color::srgb::DecodeSafe(color);
    color = ApplyToneMap(color);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::srgb::EncodeSafe(color);
  }

  return color;
}

}  // namespace lorwin

#endif  // SRC_GAMES_LORWIN_COMMON_HLSLI_
