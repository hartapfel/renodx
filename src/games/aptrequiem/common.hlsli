#ifndef SRC_GAMES_APTREQUIEM_COMMON_HLSLI_
#define SRC_GAMES_APTREQUIEM_COMMON_HLSLI_

#include "./shared.h"
#include "../../shaders/tonemap/psychov25/test25.hlsli"

static const float APT_TONE_MAP_TYPE_VANILLA_PLUS = 1.f;
static const float APT_TONE_MAP_TYPE_PSYCHOV25 = 2.f;

float APTGetGameNits(float native_game_nits) {
  if (RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_VANILLA_PLUS
      && RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_PSYCHOV25) {
    return native_game_nits;
  }
  return max(RENODX_DIFFUSE_WHITE_NITS, 1.f);
}

bool APTIsCustomToneMap() {
  return RENODX_TONE_MAP_TYPE == APT_TONE_MAP_TYPE_VANILLA_PLUS
      || RENODX_TONE_MAP_TYPE == APT_TONE_MAP_TYPE_PSYCHOV25;
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

float3 APTApplyPostProcessLUTScaling(
    float3 lut_input_linear,
    float3 lut_output_linear,
    Texture3D<float4> lut_texture,
    SamplerState lut_sampler,
    float lut_input_encode_scale,
    float lut_coordinate_scale,
    float lut_coordinate_offset,
    float lut_decode_scale) {
  if ((RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_VANILLA_PLUS
       && RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_PSYCHOV25)
      || RENODX_COLOR_GRADE_LUT_SCALING == 0.f) {
    return lut_output_linear;
  }

  const float coordinate_scale = lut_coordinate_scale * 0.07434873282909393f;
  const float black_coordinate = lut_coordinate_offset;
  const float mid_coordinate = log2(0.18f * lut_input_encode_scale + 1.f) * coordinate_scale + lut_coordinate_offset;
  const float white_coordinate = log2(lut_input_encode_scale + 1.f) * coordinate_scale + lut_coordinate_offset;

  float3 lut_black_encoded = lut_texture.Sample(
      lut_sampler,
      float3(black_coordinate, black_coordinate, black_coordinate)).rgb;
  float3 lut_mid_encoded = lut_texture.Sample(
      lut_sampler,
      float3(mid_coordinate, mid_coordinate, mid_coordinate)).rgb;
  float3 lut_white_encoded = lut_texture.Sample(
      lut_sampler,
      float3(white_coordinate, white_coordinate, white_coordinate)).rgb;

  float3 lut_black_linear = (exp2(lut_black_encoded * 13.450128555297852f) - 1.f.xxx)
      * lut_decode_scale;
  float3 lut_mid_linear = (exp2(lut_mid_encoded * 13.450128555297852f) - 1.f.xxx)
      * lut_decode_scale;
  float3 lut_white_linear = (exp2(lut_white_encoded * 13.450128555297852f) - 1.f.xxx)
      * lut_decode_scale;

  float3 unclamped_srgb = renodx::lut::Unclamp(
      renodx::color::srgb::EncodeSafe(lut_output_linear),
      renodx::color::srgb::EncodeSafe(lut_black_linear),
      renodx::color::srgb::EncodeSafe(lut_mid_linear),
      renodx::color::srgb::EncodeSafe(lut_white_linear),
      renodx::color::srgb::EncodeSafe(lut_input_linear));
  float3 unclamped_linear = renodx::color::srgb::DecodeSafe(unclamped_srgb);

  return renodx::lut::RecolorUnclamped(
      lut_output_linear,
      unclamped_linear,
      RENODX_COLOR_GRADE_LUT_SCALING);
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

float3 APTApplyLuminanceColorGrade(float3 color_bt2020) {
  renodx::color::grade::Config config = APTCreateColorGradeConfig();
  if (config.exposure == 1.f
      && RENODX_TONE_MAP_GAMMA == 1.f
      && config.shadows == 1.f
      && config.highlights == 1.f
      && config.contrast == 1.f
      && config.flare == 0.f) {
    return color_bt2020;
  }

  float y = renodx::color::y::from::BT2020(color_bt2020);
  color_bt2020 = APTApplyExposureContrastFlareHighlightsShadowsByLuminance(color_bt2020, y, config);

  return APTGamutCompressBT2020(max(color_bt2020, 0.f.xxx));
}

float3 APTApplyWideGamutSaturationGrade(float3 color_bt2020) {
  renodx::color::grade::Config config = APTCreateColorGradeConfig();
  if (config.saturation == 1.f && config.dechroma == 0.f && config.blowout == 0.f) {
    return color_bt2020;
  }

  color_bt2020 = max(color_bt2020, 0.f.xxx);
  float y_adjusted = renodx::color::y::from::BT2020(color_bt2020);
  // Signed BT.709 components are required to represent colors outside BT.709
  // while they are still valid inside BT.2020. Clamping here collapses the
  // wide-gamut chroma before the saturation adjustment can preserve it.
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

  color_bt2020 = renodx::color::bt2020::from::BT709(renodx::color::bt709::from::OkLab(perceptual));
  return max(APTGamutCompressBT2020(color_bt2020), 0.f.xxx);
}

float3 APTApplyHDRTransformerColorGrade(float3 color_bt2020_nits, float game_nits) {
  if (RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_VANILLA_PLUS
      && RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_PSYCHOV25) {
    return color_bt2020_nits;
  }

  const float safe_game_nits = max(game_nits, 1.f);
  return APTApplyWideGamutSaturationGrade(color_bt2020_nits / safe_game_nits) * safe_game_nits;
}

float3 APTApplyHDRDisplayCurve(float3 input_nits, float3 vanilla_nits) {
  // RenoDRT and PsychoV already produce a display-referred HDR signal. The
  // game's additional per-channel highlight curve would tone map it twice.
  return APTIsCustomToneMap() ? input_nits : vanilla_nits;
}

float3 APTDecodeHDRTransformerInput(
    float3 encoded_bt709,
    float game_nits,
    bool apply_native_gamma) {
  float3 decoded_bt709 = renodx::color::srgb::DecodeSafe(encoded_bt709);
  if (apply_native_gamma) {
    float3 reencoded_bt709 = renodx::color::srgb::EncodeSafe(decoded_bt709);
    decoded_bt709 = lerp(pow(max(reencoded_bt709, 0.f.xxx), 2.2f), decoded_bt709, step(1.f, decoded_bt709));
  }
  return decoded_bt709 * game_nits;
}

// Lilium HDR RCAS: sharpen luminance in linear light and apply the resulting
// ratio to RGB so the filter does not introduce chroma shifts.
float3 APTApplyLiliumHDRRCAS(
    float3 center_bt709,
    float2 tex_coord,
    Texture2D<float4> scene_texture,
    SamplerState scene_sampler,
    float game_nits,
    bool apply_native_gamma) {
  if ((RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_VANILLA_PLUS
      && RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_PSYCHOV25)
      || CUSTOM_SHARPNESS == 0.f) {
    return center_bt709;
  }

  const float3 center_bt709_nits = center_bt709 * game_nits;

  uint width, height;
  scene_texture.GetDimensions(width, height);
  const float2 texel_size = rcp(float2(width, height));

  // Minimal 3x3 cross neighborhood: b / d e f / h.
  const float3 b = APTDecodeHDRTransformerInput(
      scene_texture.SampleLevel(scene_sampler, tex_coord + float2(0.f, -1.f) * texel_size, 0.f).rgb,
      game_nits,
      apply_native_gamma);
  const float3 d = APTDecodeHDRTransformerInput(
      scene_texture.SampleLevel(scene_sampler, tex_coord + float2(-1.f, 0.f) * texel_size, 0.f).rgb,
      game_nits,
      apply_native_gamma);
  const float3 f = APTDecodeHDRTransformerInput(
      scene_texture.SampleLevel(scene_sampler, tex_coord + float2(1.f, 0.f) * texel_size, 0.f).rgb,
      game_nits,
      apply_native_gamma);
  const float3 h = APTDecodeHDRTransformerInput(
      scene_texture.SampleLevel(scene_sampler, tex_coord + float2(0.f, 1.f) * texel_size, 0.f).rgb,
      game_nits,
      apply_native_gamma);

  // The display-transform input is measured in nits, so normalize luminance
  // against the selected display peak for RCAS's nominal 0..1 limiter range.
  const float rcp_normalization = rcp(max(RENODX_PEAK_WHITE_NITS, max(game_nits, 1.f)));
  const float b_luma = renodx::color::y::from::BT709(max(b, 0.f.xxx)) * rcp_normalization;
  const float d_luma = renodx::color::y::from::BT709(max(d, 0.f.xxx)) * rcp_normalization;
  const float e_luma = renodx::color::y::from::BT709(max(center_bt709_nits, 0.f.xxx)) * rcp_normalization;
  const float f_luma = renodx::color::y::from::BT709(max(f, 0.f.xxx)) * rcp_normalization;
  const float h_luma = renodx::color::y::from::BT709(max(h, 0.f.xxx)) * rcp_normalization;

  const float min_ring_luma = min(min(b_luma, d_luma), min(f_luma, h_luma));
  const float max_ring_luma = max(max(b_luma, d_luma), max(f_luma, h_luma));
  const float limited_max_luma = min(max_ring_luma, 0.99f);
  const float epsilon = 1e-6f;

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
  // Do not let sharpening create a new local minimum. This preserves genuine
  // black samples while preventing isolated zero-valued edge artifacts.
  const float sharpened_luma = clamp(
      ((b_luma + d_luma + h_luma + f_luma) * lobe + e_luma) * reciprocal_lobe,
      min_luma,
      max_luma);
  const float luma_ratio = clamp(renodx::math::DivideSafe(sharpened_luma, e_luma, 1.f), 0.f, 4.f);
  return center_bt709 * luma_ratio;
}

float3 APTApplyPostProcessToneMap(
    float3 untonemapped_bt709,
    float3 vanilla_tonemapped_bt709,
    bool clamp_vanilla) {
  if (RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_VANILLA_PLUS
      && RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_PSYCHOV25) {
    return clamp_vanilla ? saturate(vanilla_tonemapped_bt709) : vanilla_tonemapped_bt709;
  }

  renodx::draw::Config config = renodx::draw::BuildConfig();
  config.tone_map_type = renodx::draw::TONE_MAP_TYPE_RENO_DRT;
  config.tone_map_exposure = 1.f;
  // Slightly soften only the Vanilla+ HDR shoulder; PsychoV does not use this RenoDRT pass.
  config.tone_map_highlights = 0.8f;
  config.tone_map_shadows = 1.f;
  config.tone_map_contrast = 1.f;
  config.tone_map_saturation = 1.f;
  config.tone_map_highlight_saturation = 1.f;
  config.tone_map_blowout = 0.f;
  config.tone_map_flare = 0.f;
  config.tone_map_hue_correction = 1.f;
  config.gamma_correction = renodx::draw::GAMMA_CORRECTION_NONE;
  config.tone_map_working_color_space = renodx::color::convert::COLOR_SPACE_BT2020;
  config.tone_map_clamp_color_space = renodx::color::convert::COLOR_SPACE_BT2020;
  config.tone_map_clamp_peak = renodx::color::convert::COLOR_SPACE_BT2020;
  config.reno_drt_tone_map_method = renodx::tonemap::renodrt::config::tone_map_method::REINHARD;
  config.reno_drt_scaling_method =
      RENODX_TONE_MAP_COLOR_SCALE == 0.f
          ? renodx::tonemap::renodrt::config::scaling_method::LUMINANCE
          : renodx::tonemap::renodrt::config::scaling_method::PER_CHANNEL;

  // The game's completed SDR reference contains its LUT, tint, contrast, and
  // downstream per-channel grading. Reconstruct that look onto the scene HDR
  // signal before user grading instead of replacing it with a neutral RenoDRT
  // look. This preserves the art direction while retaining highlight headroom.
  float3 neutral_sdr_bt709 = renodx::tonemap::renodrt::NeutralSDR(untonemapped_bt709);
  float3 safe_vanilla_bt709 = renodx::math::Select(
      or(isnan(vanilla_tonemapped_bt709), isinf(vanilla_tonemapped_bt709)),
      neutral_sdr_bt709,
      vanilla_tonemapped_bt709);
  float3 game_graded_bt709 = renodx::draw::ComputeUntonemappedGraded(
      untonemapped_bt709,
      safe_vanilla_bt709,
      neutral_sdr_bt709,
      config);

  float3 color_bt2020 = renodx::color::bt2020::from::BT709(game_graded_bt709);
  color_bt2020 = APTApplyLuminanceColorGrade(color_bt2020);
  float3 color_bt709 = renodx::color::bt709::from::BT2020(color_bt2020);

  if (RENODX_TONE_MAP_TYPE == APT_TONE_MAP_TYPE_PSYCHOV25) {
    float peak_ratio = max(1.f, RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f));
    float3 psychov_tonemapped_bt709 = renodx::tonemap::psychov::psychotm_test25(
        color_bt709,
        peak_ratio,
        1.f,
        0.75f,
        1.f,
        1.f,
        1.f,
        1.f,
        100.f,
        1.f,
        1.f,
        0,
        1.f,
        0.18f,
        0.18f,
        1.f,
        1,
        1.f,
        RENODX_PSYCHOV_COMPRESSION_POWER);
    psychov_tonemapped_bt709 = renodx::color::correct::Hue(
        psychov_tonemapped_bt709,
        color_bt709,
        RENODX_PSYCHOV_HUE_SHIFT);
    return APTPreparePostProcessOutput(psychov_tonemapped_bt709, vanilla_tonemapped_bt709);
  }

  config.reno_drt_white_clip = RENODX_TONE_MAP_WHITE_CLIP;
  return APTPreparePostProcessOutput(
      renodx::draw::ToneMapPass(color_bt709, config),
      vanilla_tonemapped_bt709);
}

#endif  // SRC_GAMES_APTREQUIEM_COMMON_HLSLI_
