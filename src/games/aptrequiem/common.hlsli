#include "./shared.h"

static const float APT_LUT_ENCODE_SCALE = 0.07434873282909393f;
static const float APT_LUT_DECODE_SCALE = 13.450128555297852f;
static const float APT_LUT_LINEAR_SCALE = 11190.6005859375f;
static const float APT_LUT_LINEAR_RCP_SCALE = 8.936070662457496e-05f;
static const float APT_TONE_MAP_TYPE_VANILLA_PLUS = 1.f;

float3 APTDecodePostProcessLUT(float3 encoded) {
  float3 lut_linear = (exp2(max(encoded, 0.f.xxx) * APT_LUT_DECODE_SCALE) - 1.f.xxx) * APT_LUT_LINEAR_RCP_SCALE;
  return lut_linear * (10000.f / max(RENODX_DIFFUSE_WHITE_NITS, 1.f));
}

float3 APTEncodePostProcessLUT(float3 lut_linear) {
  float3 normalized = max(lut_linear, 0.f.xxx) * (RENODX_DIFFUSE_WHITE_NITS / 10000.f);
  return log2((normalized * APT_LUT_LINEAR_SCALE) + 1.f.xxx) * APT_LUT_ENCODE_SCALE;
}

float APTAdjustLuminance(float y) {
  if (RENODX_TONE_MAP_GAMMA != 1.f) {
    y = pow(max(y, 0.f), RENODX_TONE_MAP_GAMMA);
  }

  const float mid_gray = 0.18f;

  if (RENODX_TONE_MAP_CONTRAST != 1.f || RENODX_TONE_MAP_FLARE != 0.f) {
    float y_normalized = max(y / mid_gray, 1e-6f);
    float flare = renodx::math::DivideSafe(
        y_normalized + (0.10f * pow(RENODX_TONE_MAP_FLARE, 10.f)),
        y_normalized,
        1.f);
    y = pow(y_normalized, RENODX_TONE_MAP_CONTRAST * flare) * mid_gray;
  }

  float highlights = RENODX_TONE_MAP_HIGHLIGHTS;
  if (highlights != 1.f) {
    y = renodx::color::grade::Highlights(y, highlights, mid_gray);
  }

  if (RENODX_TONE_MAP_SHADOWS != 1.f) {
    y = renodx::color::grade::Shadows(y, RENODX_TONE_MAP_SHADOWS, mid_gray);
  }

  return max(y, 0.f);
}

float3 APTApplyLuminanceColorGrade(float3 color_bt2020) {
  color_bt2020 = max(color_bt2020, 0.f.xxx) * RENODX_TONE_MAP_EXPOSURE;

  float y = renodx::color::y::from::BT2020(color_bt2020);
  float y_adjusted = APTAdjustLuminance(y);
  color_bt2020 = renodx::color::correct::Luminance(color_bt2020, y, y_adjusted);

  return renodx::color::gamut::GamutCompressBT2020(max(color_bt2020, 0.f.xxx), 1.f);
}

float3 APTApplyWideGamutSaturationGrade(float3 color_bt2020) {
  color_bt2020 = max(color_bt2020, 0.f.xxx);

  float y_adjusted = renodx::color::y::from::BT2020(color_bt2020);
  float3 gray = y_adjusted.xxx;

  if (RENODX_TONE_MAP_BLOWOUT != 0.f) {
    float3 color_bt709 = max(renodx::color::bt709::from::BT2020(color_bt2020), 0.f.xxx);
    float3 perceptual = renodx::color::oklab::from::BT709(color_bt709);
    float luminance_nits = y_adjusted * max(RENODX_DIFFUSE_WHITE_NITS, 1.f);
    float percent_max = saturate(luminance_nits / 10000.f);
    float blowout_strength = 100.f;
    float blowout_change = pow(1.f - percent_max, blowout_strength * abs(RENODX_TONE_MAP_BLOWOUT));
    if (RENODX_TONE_MAP_BLOWOUT < 0.f) {
      blowout_change = 2.f - blowout_change;
    }

    perceptual.yz *= blowout_change;
    color_bt2020 = renodx::color::bt2020::from::BT709(renodx::color::bt709::from::OkLab(perceptual));
    y_adjusted = renodx::color::y::from::BT2020(max(color_bt2020, 0.f.xxx));
    gray = y_adjusted.xxx;
  }

  float peak_normalized = max(RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f), 1.f);
  float highlight_weight = saturate((y_adjusted - 1.f) / max(peak_normalized - 1.f, 1e-6f));
  float highlight_saturation = lerp(1.f, RENODX_TONE_MAP_HIGHLIGHT_SATURATION, highlight_weight);
  color_bt2020 = lerp(gray, color_bt2020, highlight_saturation);
  color_bt2020 = lerp(gray, color_bt2020, RENODX_TONE_MAP_SATURATION);

  return renodx::color::gamut::GamutCompressBT2020(max(color_bt2020, 0.f.xxx), 1.f);
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
