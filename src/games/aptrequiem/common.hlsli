#include "./shared.h"

static const float APT_LUT_ENCODE_SCALE = 0.07434873282909393f;
static const float APT_LUT_DECODE_SCALE = 13.450128555297852f;
static const float APT_LUT_LINEAR_SCALE = 11190.6005859375f;
static const float APT_LUT_LINEAR_RCP_SCALE = 8.936070662457496e-05f;
static const float APT_TONE_MAP_TYPE_VANILLA_PLUS = 1.f;

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

float3 APTDecodePostProcessLUT(float3 encoded) {
  float3 lut_linear = (exp2(max(encoded, 0.f.xxx) * APT_LUT_DECODE_SCALE) - 1.f.xxx) * APT_LUT_LINEAR_RCP_SCALE;
  return lut_linear * (10000.f / max(RENODX_DIFFUSE_WHITE_NITS, 1.f));
}

float3 APTEncodePostProcessLUT(float3 lut_linear) {
  float3 normalized = max(lut_linear, 0.f.xxx) * (RENODX_DIFFUSE_WHITE_NITS / 10000.f);
  return log2((normalized * APT_LUT_LINEAR_SCALE) + 1.f.xxx) * APT_LUT_ENCODE_SCALE;
}

float APTAutoExposureScale(float exposure_pivot) {
  if (RENODX_TONE_MAP_TYPE != APT_TONE_MAP_TYPE_VANILLA_PLUS || RENODX_AUTO_EXPOSURE_ENABLED == 0.f) return 1.f;

  // The game derives this pivot from sExposure.y before applying the LUT curve.
  // Shape exposure around the stable mid range: high metered scenes are reduced,
  // while very dark metered scenes get only a small lift.
  const float neutral = 0.18f;
  float bright_weight = smoothstep(neutral, 0.75f, exposure_pivot);
  float dark_weight = 1.f - smoothstep(0.03f, neutral, exposure_pivot);

  float bright_scale = lerp(1.f, 0.5f, saturate(RENODX_AUTO_EXPOSURE_BRIGHT_REDUCTION));
  float dark_scale = lerp(1.f, 1.12f, saturate(RENODX_AUTO_EXPOSURE_DARK_BOOST));
  return lerp(1.f, bright_scale, bright_weight) * lerp(1.f, dark_scale, dark_weight);
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
  float3 color_bt709 = max(renodx::color::bt709::from::BT2020(color_bt2020), 0.f.xxx);
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
  return APTGamutCompressBT2020(max(color_bt2020, 0.f.xxx));
}

float3 APTApplyHDRTransformerColorGrade(float3 color_bt2020) {
  if (RENODX_TONE_MAP_TYPE == APT_TONE_MAP_TYPE_VANILLA_PLUS) {
    color_bt2020 = APTApplyWideGamutSaturationGrade(color_bt2020);
  }

  return color_bt2020;
}

float3 APTDecodeHDRTransformerInput(float3 color) {
  return renodx::color::bt2020::from::BT709(color);
}

float3 APTApplyLUTBuilderOutput(float3 color) {
  if (RENODX_TONE_MAP_TYPE == APT_TONE_MAP_TYPE_VANILLA_PLUS) {
    float3 linear_bt709 = APTDecodePostProcessLUT(color);
    float3 linear_bt2020 = renodx::color::bt2020::from::BT709(linear_bt709);

    float3 graded_bt2020 = APTApplyLuminanceColorGrade(linear_bt2020);
    float3 graded_bt709 = renodx::color::bt709::from::BT2020(graded_bt2020);
    color = APTEncodePostProcessLUT(graded_bt709);
  }

  return color;
}
