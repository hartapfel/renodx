#ifndef SRC_GAMES_APTLEGACY_COMMON_HLSLI_
#define SRC_GAMES_APTLEGACY_COMMON_HLSLI_

#include "./shared.h"
#include "../../shaders/tonemap/psychov/test25.hlsli"

bool APTIsPsychoV() {
  return RENODX_TONE_MAP_TYPE != 0.f;
}

bool APTUsePerceptualFilmGrain() {
  return APTIsPsychoV() && CUSTOM_FILM_GRAIN_TYPE == 1.f;
}

float3 APTApplyPerceptualFilmGrain(float3 color, float2 pixel_position) {
  if (!APTUsePerceptualFilmGrain()) return color;
  // The sine-based hash used by ApplyFilmGrain can develop visible diagonal
  // correlations when fed large integer pixel coordinates. Pre-scramble the
  // pixel and frame seed with the precision-safe hash, then keep the standard
  // perceptual density model unchanged.
  const float3 grain_hash = renodx::random::Hash33(
      float3(pixel_position, CUSTOM_RANDOM * 8192.f));
  return renodx::effects::ApplyFilmGrain(
      color,
      grain_hash.xy,
      grain_hash.z,
      CUSTOM_FILM_GRAIN_STRENGTH * 0.03f,
      1.f);
}

float3 APTSelectFilmGrainOutput(float3 native_grained, float3 perceptual_grained) {
  return APTUsePerceptualFilmGrain() ? perceptual_grained : native_grained;
}

float APTGetGameNits(float native_game_nits) {
  return APTIsPsychoV() ? max(RENODX_DIFFUSE_WHITE_NITS, 1.f) : native_game_nits;
}

float APTHighlights(float x, float highlights, float mid_gray) {
  if (highlights == 1.f) return x;

  if (highlights > 1.f) {
    return max(x,
               lerp(x, mid_gray * pow(x / mid_gray, highlights),
                    renodx::tonemap::ExponentialRollOff(x, 1.f, 1.1f)));
  }

  x /= mid_gray;
  return lerp(x, pow(x, highlights), step(1.f, x)) * mid_gray;
}

float APTShadows(float x, float shadows, float mid_gray) {
  if (shadows == 1.f) return x;

  const float ratio = max(renodx::math::DivideSafe(x, mid_gray, 0.f), 0.f);
  const float base_term = x * mid_gray;
  const float base_scale = renodx::math::DivideSafe(base_term, ratio, 0.f);

  if (shadows > 1.f) {
    float raised = x * (1.f + renodx::math::DivideSafe(base_term, pow(ratio, shadows), 0.f));
    float reference = x * (1.f + base_scale);
    return max(x, x + (raised - reference));
  }

  float lowered = x * (1.f - renodx::math::DivideSafe(base_term, pow(ratio, 2.f - shadows), 0.f));
  float reference = x * (1.f - base_scale);
  return clamp(x + (lowered - reference), 0.f, x);
}

renodx::color::grade::Config APTCreateColorGradeConfig() {
  renodx::color::grade::Config config = renodx::color::grade::config::Create();
  config.exposure = RENODX_TONE_MAP_EXPOSURE;
  config.highlights = RENODX_TONE_MAP_HIGHLIGHTS;
  config.shadows = RENODX_TONE_MAP_SHADOWS;
  config.contrast = RENODX_TONE_MAP_CONTRAST;
  config.flare = 0.10f * pow(RENODX_TONE_MAP_FLARE, 10.f);
  config.saturation = RENODX_TONE_MAP_SATURATION;
  config.dechroma = RENODX_TONE_MAP_BLOWOUT;
  config.blowout = -1.f * (RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f);
  return config;
}

float3 APTGamutCompressBT2020(float3 color_bt2020) {
  float grayscale = renodx::color::y::from::BT2020(color_bt2020);

  const float mid_gray_linear = 1.f / pow(10.f, 0.75f);
  const float mid_gray_percent = 0.5f;
  const float mid_gray_gamma = log(mid_gray_linear) / log(mid_gray_percent);

  float3 encoded = renodx::color::gamma::EncodeSafe(color_bt2020, mid_gray_gamma);
  float encoded_gray = renodx::color::gamma::Encode(grayscale, mid_gray_gamma);
  float3 compressed = renodx::color::correct::GamutCompress(encoded, encoded_gray);
  return renodx::color::gamma::DecodeSafe(compressed, mid_gray_gamma);
}

float3 APTPreparePostProcessOutput(float3 color_bt709, float3 fallback_bt709) {
  fallback_bt709 = renodx::math::ZeroNaN(fallback_bt709);
  fallback_bt709 = renodx::math::Select(isinf(fallback_bt709), 0.f.xxx, fallback_bt709);
  color_bt709 = renodx::math::Select(isnan(color_bt709), fallback_bt709, color_bt709);
  color_bt709 = renodx::math::Select(isinf(color_bt709), fallback_bt709, color_bt709);

  // The game gamma-encodes this BT.709 signal with per-channel log2 calls.
  // Compress signed wide-gamut components before that nonlinear boundary;
  // saturation is expanded into BT.2020 later in the HDR transformer.
  const float grayscale = max(renodx::color::y::from::BT709(color_bt709), 0.f);
  return max(renodx::color::correct::GamutCompress(color_bt709, grayscale), 0.f.xxx);
}

float3 APTPreparePsychoVPostProcessOutput(float3 color_bt709) {
  // PsychoV returns its selected target gamut represented in linear BT.709.
  color_bt709 = renodx::math::ZeroNaN(color_bt709);
  color_bt709 = renodx::math::Select(isinf(color_bt709), 0.f.xxx, color_bt709);

  // Convert that result to the BT.2020 HDR10 container before carrying it
  // through the game's per-channel sRGB intermediate.
  float3 color_bt2020 = renodx::color::bt2020::from::BT709(color_bt709);
  color_bt2020 = renodx::math::ZeroNaN(color_bt2020);
  color_bt2020 = renodx::math::Select(isinf(color_bt2020), 0.f.xxx, color_bt2020);
  // Keep this intermediate unconstrained. BT.709 mode is enforced after the
  // HDR transformer's downstream grading; wide-gamut mode stays untouched.
  return max(color_bt2020, 0.f.xxx);
}

float3 APTApplyPostProcessLUT(
    float3 lut_input_linear,
    float3 lut_output_linear,
    float3 lut_output_scale) {
  if (!APTIsPsychoV()) return lut_output_linear;

  // Legacy's LUT bakes exposure-dependent contrast and luminance curves into
  // its artistic color grade. Preserve the LUT hue/purity, but restore the
  // scene-linear luminance so PsychoV is the only display-referred curve.
  float3 scene_linear = max(lut_input_linear * lut_output_scale, 0.f.xxx);
  float scene_y = renodx::color::y::from::BT709(scene_linear);
  float lut_y = renodx::color::y::from::BT709(max(lut_output_linear, 0.f.xxx));
  float3 color_graded_scene = lut_y > 1e-6f
      ? lut_output_linear * (scene_y / lut_y)
      : scene_linear;
  color_graded_scene = renodx::math::ZeroNaN(color_graded_scene);
  return renodx::math::Select(isinf(color_graded_scene), scene_linear, color_graded_scene);
}

float3 APTApplyExposureContrastFlareHighlightsShadowsByLuminance(
    float3 ungraded_bt2020,
    float y,
    renodx::color::grade::Config config,
    float mid_gray = 0.18f) {
  if (config.exposure == 1.f
      && RENODX_TONE_MAP_GAMMA == 1.f
      && config.shadows == 1.f
      && config.highlights == 1.f
      && config.contrast == 1.f
      && config.flare == 0.f) {
    return ungraded_bt2020;
  }

  float3 color = max(ungraded_bt2020, 0.f.xxx) * config.exposure;
  float y_adjusted = max(y, 0.f);

  if (RENODX_TONE_MAP_GAMMA != 1.f) {
    y_adjusted = pow(y_adjusted, RENODX_TONE_MAP_GAMMA);
  }

  const float y_normalized = max(y_adjusted / mid_gray, 1e-6f);
  float flare = renodx::math::DivideSafe(y_normalized + config.flare, y_normalized, 1.f);
  float exponent = config.contrast * flare;
  float y_contrasted = pow(y_normalized, exponent) * mid_gray;
  float y_highlighted = APTHighlights(y_contrasted, config.highlights, mid_gray);
  float y_shadowed = APTShadows(y_highlighted, config.shadows, mid_gray);

  return renodx::color::correct::Luminance(color, y, max(y_shadowed, 0.f));
}

float3 APTApplyColorGrade(float3 color_bt2020) {
  renodx::color::grade::Config config = APTCreateColorGradeConfig();
  const bool apply_luminance_grade = config.exposure != 1.f
      || RENODX_TONE_MAP_GAMMA != 1.f
      || config.shadows != 1.f
      || config.highlights != 1.f
      || config.contrast != 1.f
      || config.flare != 0.f;
  const bool apply_chroma_grade = config.saturation != 1.f
      || config.dechroma != 0.f
      || config.blowout != 0.f;
  if (!apply_luminance_grade && !apply_chroma_grade) {
    return color_bt2020;
  }

  color_bt2020 = max(color_bt2020, 0.f.xxx);

  if (apply_luminance_grade) {
    float y = renodx::color::y::from::BT2020(color_bt2020);
    color_bt2020 = APTApplyExposureContrastFlareHighlightsShadowsByLuminance(color_bt2020, y, config);
  }

  if (apply_chroma_grade) {
    float y_adjusted = renodx::color::y::from::BT2020(color_bt2020);
    float3 color_bt709 = renodx::color::bt709::from::BT2020(color_bt2020);
    float3 perceptual = renodx::color::oklab::from::BT709(color_bt709);

    if (config.dechroma != 0.f) {
      perceptual.yz *= lerp(1.f, 0.f, saturate(pow(y_adjusted / (10000.f / 100.f), (1.f - config.dechroma))));
    }

    if (config.blowout != 0.f) {
      float percent_max = saturate(y_adjusted * 100.f / 10000.f);
      float blowout_strength = 100.f;
      float blowout_change = pow(1.f - percent_max, blowout_strength * abs(config.blowout));
      if (config.blowout < 0.f) {
        blowout_change = 2.f - blowout_change;
      }

      perceptual.yz *= blowout_change;
    }

    perceptual.yz *= config.saturation;
    color_bt2020 = renodx::color::bt2020::from::BT709(
        renodx::color::bt709::from::OkLab(perceptual));
  }

  return max(APTGamutCompressBT2020(color_bt2020), 0.f.xxx);
}

float3 APTFinalizeHDRTransformerColor(float3 color_bt2020_nits) {
  if (!APTIsPsychoV() || RENODX_PSYCHOV_WIDE_GAMUT != 0.f) {
    return color_bt2020_nits;
  }

  // This is the last linear-color operation before the custom HDR path enters
  // PQ. Constrain here so downstream transforms and sharpening cannot re-expand
  // earlier PsychoV result outside the BT.709 primary triangle.
  float3 color_bt709_nits = renodx::color::bt709::from::BT2020(color_bt2020_nits);
  color_bt709_nits = APTPreparePostProcessOutput(color_bt709_nits, 0.f.xxx);
  return renodx::color::bt2020::from::BT709(color_bt709_nits);
}

float3 APTDecodeHDRTransformerInput(float3 encoded_color, float game_nits) {
  return renodx::color::srgb::DecodeSafe(encoded_color) * game_nits;
}

float APTGetHDRTransformerLuminance(float3 color) {
  return renodx::color::y::from::BT2020(color);
}

// Lilium HDR RCAS: sharpen luminance in linear light and apply the resulting
// ratio to RGB so the filter does not introduce chroma shifts.
float3 APTApplyLiliumHDRRCAS(
    float3 center_bt709_nits,
    float2 tex_coord,
    Texture2D<float4> scene_texture,
    SamplerState scene_sampler,
    float game_nits) {
  if (!APTIsPsychoV()
      || CUSTOM_SHARPENING_TYPE != 1.f
      || CUSTOM_SHARPNESS == 0.f) {
    return center_bt709_nits;
  }

  uint width, height;
  scene_texture.GetDimensions(width, height);
  const float2 texel_size = rcp(float2(width, height));

  // Minimal 3x3 cross neighborhood: b / d e f / h.
  const float3 b = APTDecodeHDRTransformerInput(
      scene_texture.SampleLevel(scene_sampler, tex_coord + float2(0.f, -1.f) * texel_size, 0.f).rgb,
      game_nits);
  const float3 d = APTDecodeHDRTransformerInput(
      scene_texture.SampleLevel(scene_sampler, tex_coord + float2(-1.f, 0.f) * texel_size, 0.f).rgb,
      game_nits);
  const float3 f = APTDecodeHDRTransformerInput(
      scene_texture.SampleLevel(scene_sampler, tex_coord + float2(1.f, 0.f) * texel_size, 0.f).rgb,
      game_nits);
  const float3 h = APTDecodeHDRTransformerInput(
      scene_texture.SampleLevel(scene_sampler, tex_coord + float2(0.f, 1.f) * texel_size, 0.f).rgb,
      game_nits);

  // Match Lilium's reference RCAS normalization. This is deliberately fixed
  // rather than tied to display peak so sharpening strength does not collapse
  // as the user's peak-brightness setting increases.
  static const float sharpening_normalization_point = 125.f;
  const float rcp_normalization = rcp(sharpening_normalization_point);
  const float b_luma = APTGetHDRTransformerLuminance(max(b, 0.f.xxx)) * rcp_normalization;
  const float d_luma = APTGetHDRTransformerLuminance(max(d, 0.f.xxx)) * rcp_normalization;
  const float e_luma = APTGetHDRTransformerLuminance(max(center_bt709_nits, 0.f.xxx)) * rcp_normalization;
  const float f_luma = APTGetHDRTransformerLuminance(max(f, 0.f.xxx)) * rcp_normalization;
  const float h_luma = APTGetHDRTransformerLuminance(max(h, 0.f.xxx)) * rcp_normalization;

  const float min_ring_luma = min(min(b_luma, d_luma), min(f_luma, h_luma));
  const float max_ring_luma = max(max(b_luma, d_luma), max(f_luma, h_luma));
  const float limited_max_luma = min(max_ring_luma, 0.99f);
  const float epsilon = 1e-6f;

  // Preserve genuine black instead of allowing the RCAS ratio resolve to
  // manufacture a value from neighboring pixels.
  if (e_luma <= epsilon) return center_bt709_nits;

  const float hit_min = min_ring_luma * rcp(max(4.f * limited_max_luma, epsilon));
  float hit_max_denominator = 4.f * min_ring_luma - 4.f;
  hit_max_denominator = abs(hit_max_denominator) < epsilon
      ? (hit_max_denominator < 0.f ? -epsilon : epsilon)
      : hit_max_denominator;
  const float hit_max = (1.f - limited_max_luma) * rcp(hit_max_denominator);

  static const float rcas_limit = 0.1875f;
  float lobe = max(-rcas_limit, min(max(-hit_min, hit_max), 0.f)) * CUSTOM_SHARPNESS;

  // Lilium's noise removal damps sharpening where the center is a local outlier.
  float noise = 0.25f * (b_luma + d_luma + f_luma + h_luma) - e_luma;
  const float max_luma = max(max(max(b_luma, d_luma), max(e_luma, f_luma)), h_luma);
  const float min_luma = min(min(min(b_luma, d_luma), min(e_luma, f_luma)), h_luma);
  noise = saturate(abs(noise) * rcp(max(max_luma - min_luma, epsilon)));
  lobe *= -0.5f * noise + 1.f;

  const float reciprocal_lobe = rcp(4.f * lobe + 1.f);
  const float sharpened_luma =
      ((b_luma + d_luma + h_luma + f_luma) * lobe + e_luma) * reciprocal_lobe;
  // Retain RCAS's contrast overshoot without allowing a non-black center to
  // collapse to zero. The reciprocal bounds permit up to two stops either way.
  const float luma_ratio = clamp(
      renodx::math::DivideSafe(sharpened_luma, e_luma, 1.f),
      0.25f,
      4.f);
  float3 sharpened_color_nits = center_bt709_nits * luma_ratio;

  // RCAS runs after tonemapping, so its positive overshoot must respect the
  // same peak limit. Scale RGB together to preserve hue instead of clipping
  // individual channels.
  const float sharpened_peak = max(
      max(max(sharpened_color_nits.x, sharpened_color_nits.y), sharpened_color_nits.z),
      0.f);
  sharpened_color_nits *= min(
      1.f,
      max(RENODX_PEAK_WHITE_NITS, 1.f) / max(sharpened_peak, 1e-6f));
  return sharpened_color_nits;
}

float3 APTApplyPostProcessToneMap(
    float3 untonemapped_bt709,
    float3 vanilla_tonemapped_bt709,
    bool clamp_vanilla) {
  if (!APTIsPsychoV()) {
    return clamp_vanilla ? saturate(vanilla_tonemapped_bt709) : vanilla_tonemapped_bt709;
  }

  float3 color_bt709 = untonemapped_bt709;
  float3 color_bt2020 = renodx::color::bt2020::from::BT709(color_bt709);
  color_bt2020 = APTApplyColorGrade(color_bt2020);
  color_bt709 = renodx::color::bt709::from::BT2020(color_bt2020);

  float peak_ratio = max(1.f, RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f));
  float3 psychov_tonemapped_bt709 = renodx::tonemap::psychov::psychotm_test25_fast60(
      color_bt709,
      peak_ratio,
      int(RENODX_PSYCHOV_WIDE_GAMUT));
  if (RENODX_PSYCHOV_HUE_SHIFT != 0.f) {
    psychov_tonemapped_bt709 = renodx::color::correct::Hue(
        psychov_tonemapped_bt709,
        color_bt709,
        RENODX_PSYCHOV_HUE_SHIFT);
  }
  // PsychoV owns this path completely. Never fall back to the game's native
  // HDR curve if an invalid component reaches the final safety boundary.
  return APTPreparePsychoVPostProcessOutput(psychov_tonemapped_bt709);
}

#endif  // SRC_GAMES_APTLEGACY_COMMON_HLSLI_
