#include "./shared.h"

float AC2SoftLimitGlowValue(float value, float knee_start, float max_value) {
  value = max(value, 0.f);

  float shoulder_width = max(max_value - knee_start, 1e-4f);

  float over = max(value - knee_start, 0.f);
  float compressed = knee_start + over / (1.f + over / shoulder_width);
  return min(value, compressed);
}

float AC2SoftLimitGlow(float value) {
  return AC2SoftLimitGlowValue(value, 1.f, 1.08f);
}

float4 AC2SoftLimitGlow(float4 value) {
  return float4(
      AC2SoftLimitGlow(value.x),
      AC2SoftLimitGlow(value.y),
      AC2SoftLimitGlow(value.z),
      AC2SoftLimitGlow(value.w));
}

float AC2SoftLimitGlowMask(float value) {
  return AC2SoftLimitGlowValue(value, 0.9f, 1.f);
}

float4 AC2SoftLimitGlowMask(float4 value) {
  return float4(
      AC2SoftLimitGlowMask(value.x),
      AC2SoftLimitGlowMask(value.y),
      AC2SoftLimitGlowMask(value.z),
      AC2SoftLimitGlowMask(value.w));
}

float ComputeMaxChCompressionScale(float3 untonemapped) {
  float peak = renodx::math::Max(untonemapped.r, untonemapped.g, untonemapped.b);
  float mapped_peak = renodx::tonemap::Neutwo(peak);
  return renodx::math::DivideSafe(mapped_peak, peak, 1.f);
}

float ComputeLUTCompressionScale(float3 untonemapped) {
  float peak = renodx::math::Max(untonemapped.r, untonemapped.g, untonemapped.b);
  float compression_scale = ComputeMaxChCompressionScale(untonemapped);
  float blend = smoothstep(1.f, 2.f, peak);
  return lerp(1.f, compression_scale, blend);
}

float3 AC2LUTCoord(float3 gamma_color) {
  return saturate(gamma_color) * 0.9375f + 0.03125f;
}

float3 AC2SampleLUTGamma(sampler3D lut_texture, float3 gamma_color) {
  return tex3D(lut_texture, AC2LUTCoord(gamma_color)).rgb;
}

float3 AC2UnclampLUTShadowRange(float3 original_gamma, float3 black_gamma, float3 mid_gray_gamma, float3 neutral_gamma) {
  const float3 added_gamma = black_gamma;
  const float mid_gray_average = renodx::math::Average(mid_gray_gamma);

  const float shadow_length = max(mid_gray_average, 1e-4f);
  const float shadow_stop = renodx::math::Max(neutral_gamma);
  const float3 floor_remove = added_gamma * max(0.f, shadow_length - shadow_stop) / shadow_length;

  return max(0.f, original_gamma - floor_remove);
}

float3 AC2SampleToneMappedLUT(sampler3D lut_texture, float3 linear_color) {
  float3 lut_input_gamma = renodx::color::gamma::EncodeSafe(max(0.f, linear_color), 2.2f);
  float3 lut_output_gamma = AC2SampleLUTGamma(lut_texture, lut_input_gamma);
  float3 lut_output_linear = renodx::color::gamma::DecodeSafe(max(0.f, lut_output_gamma), 2.2f);

  if (RENODX_COLOR_GRADE_SCALING != 0.f) {
    float3 lut_black_gamma = AC2SampleLUTGamma(lut_texture, 0.f);
    float lut_black_y = renodx::color::y::from::BT709(
        renodx::color::gamma::DecodeSafe(max(0.f, lut_black_gamma), 2.2f));

    if (lut_black_y > 0.f) {
      float lut_mid_input = (lut_black_y + 0.04f) * 0.5f;
      float3 lut_mid_gamma = AC2SampleLUTGamma(
          lut_texture,
          renodx::color::gamma::EncodeSafe(lut_mid_input, 2.2f));

      float3 unclamped_gamma = AC2UnclampLUTShadowRange(
          lut_output_gamma,
          lut_black_gamma,
          lut_mid_gamma,
          lut_input_gamma);
      float3 unclamped_linear = renodx::color::gamma::DecodeSafe(max(0.f, unclamped_gamma), 2.2f);
      lut_output_linear = renodx::lut::RecolorUnclamped(
          lut_output_linear,
          unclamped_linear,
          RENODX_COLOR_GRADE_SCALING);
    }
  }

  return lerp(linear_color, lut_output_linear, RENODX_COLOR_GRADE_STRENGTH);
}

struct UserGradingConfig {
  float exposure;
  float highlights;
  float shadows;
  float contrast;
  float flare;
  float saturation;
  float dechroma;
  float hue_emulation_strength;
  float highlight_saturation;
  float blowout;
};

UserGradingConfig CreateColorGradeConfig() {
  UserGradingConfig config;
  config.exposure = RENODX_TONE_MAP_EXPOSURE;
  config.highlights = RENODX_TONE_MAP_HIGHLIGHTS;
  config.shadows = RENODX_TONE_MAP_SHADOWS;
  config.contrast = RENODX_TONE_MAP_CONTRAST;
  config.flare = 0.10f * pow(RENODX_TONE_MAP_FLARE, 10.f);
  config.saturation = RENODX_TONE_MAP_SATURATION;
  config.dechroma = RENODX_TONE_MAP_DECHROMA;
  config.hue_emulation_strength = RENODX_TONE_MAP_HUE_SHIFT;
  config.highlight_saturation = -1.f * (RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f);
  config.blowout = RENODX_TONE_MAP_BLOWOUT;
  return config;
}

float GetNeutwoWhiteClip() {
  const float peak = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
  return max(RENODX_TONE_MAP_WHITE_CLIP, peak + 0.001f);
}

float Highlights(float x, float highlights, float mid_gray) {
  if (highlights == 1.f) return x;

  if (highlights > 1.f) {
    return max(x, lerp(x, mid_gray * pow(x / mid_gray, highlights), min(x, 5.f)));
  }

  x /= mid_gray;
  return lerp(x, pow(x, highlights), step(1.f, x)) * mid_gray;
}

float Shadows(float x, float shadows, float mid_gray) {
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

float3 ApplyExposureContrastFlareHighlightsShadowsByLuminance(float3 untonemapped, float y, UserGradingConfig config, float mid_gray = 0.18f) {
  if (config.exposure == 1.f && config.shadows == 1.f && config.highlights == 1.f && config.contrast == 1.f && config.flare == 0.f) {
    return untonemapped;
  }

  float3 color = untonemapped;
  color *= config.exposure;

  const float y_normalized = y / mid_gray;
  float flare = renodx::math::DivideSafe(y_normalized + config.flare, y_normalized, 1.f);
  float exponent = config.contrast * flare;
  float y_contrasted = pow(y_normalized, exponent) * mid_gray;
  float y_highlighted = Highlights(y_contrasted, config.highlights, mid_gray);
  float y_final = Shadows(y_highlighted, config.shadows, mid_gray);

  color = renodx::color::correct::Luminance(color, y, y_final);

  return color;
}

float3 ApplySaturationBlowoutHueCorrectionHighlightSaturation(float3 tonemapped, float3 hue_reference_color, float y, UserGradingConfig config, bool clamp_to_ap1 = true) {
  float3 color = tonemapped;
  if (config.saturation != 1.f || config.dechroma != 0.f || config.hue_emulation_strength != 0.f || config.blowout != 0.f || config.highlight_saturation != 0.f) {
    float3 perceptual_new = renodx::color::oklab::from::BT709(color);

    if (config.hue_emulation_strength != 0.f || config.blowout != 0.f) {
      float3 perceptual_reference = renodx::color::oklab::from::BT709(hue_reference_color);
      float chrominance_pre = length(perceptual_new.yz);
      perceptual_new.yz = lerp(perceptual_new.yz, perceptual_reference.yz, config.hue_emulation_strength);
      float chrominance_post = length(perceptual_new.yz);
      float chrominance_ratio = renodx::math::DivideSafe(chrominance_pre, chrominance_post, 1.f);

      if (config.blowout != 0.f) {
        float reference_chrominance = length(perceptual_reference.yz);
        float target_ratio = renodx::math::DivideSafe(reference_chrominance, chrominance_post, 1.f);
        chrominance_ratio = lerp(chrominance_ratio, target_ratio, config.blowout);
      }

      perceptual_new.yz *= chrominance_ratio;
    }

    if (config.dechroma != 0.f) {
      perceptual_new.yz *= lerp(1.f, 0.f, saturate(pow(y / (10000.f / 100.f), 1.f - config.dechroma)));
    }

    if (config.highlight_saturation != 0.f) {
      float percent_max = saturate(y * 100.f / 10000.f);
      float highlight_scale = pow(1.f - percent_max, 100.f * abs(config.highlight_saturation));
      perceptual_new.yz *= (config.highlight_saturation < 0.f) ? (2.f - highlight_scale) : highlight_scale;
    }

    perceptual_new.yz *= config.saturation;
    color = renodx::color::bt709::from::OkLab(perceptual_new);

    if (clamp_to_ap1) {
      color = renodx::color::bt709::clamp::AP1(color);
    }
  }

  return color;
}

float3 ApplyToneMap(float3 untonemapped) {
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    return saturate(untonemapped);
  }

  const UserGradingConfig config = CreateColorGradeConfig();
  float3 hue_correction_source = untonemapped;
  const float y = renodx::color::y::from::BT709(untonemapped);

  float3 graded = ApplyExposureContrastFlareHighlightsShadowsByLuminance(untonemapped, y, config);
  if (RENODX_TONE_MAP_HUE_SHIFT > 0.f || RENODX_TONE_MAP_BLOWOUT > 0.f) {
    const float white_clip = GetNeutwoWhiteClip();
    hue_correction_source = renodx::tonemap::neutwo::PerChannel(untonemapped, 8.f, white_clip);
  }

  graded = ApplySaturationBlowoutHueCorrectionHighlightSaturation(graded, hue_correction_source, y, config);

  if (RENODX_TONE_MAP_TYPE == 1.f) {
    return graded;
  }

  const float peak = RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS;
  const float white_clip = GetNeutwoWhiteClip();
  return renodx::color::bt709::from::BT2020(
      renodx::tonemap::neutwo::MaxChannel(
          renodx::color::bt2020::from::BT709(graded),
          peak,
          white_clip));
}

float3 ApplyFilmGrain(float3 color, float2 position) {
  if (CUSTOM_GRAIN_STRENGTH > 0.f) {
    color = renodx::effects::ApplyFilmGrain(color, position, CUSTOM_RANDOM, CUSTOM_GRAIN_STRENGTH * 0.03f);
  }
  return color;
}

float3 ApplyToneMapAndGrain(float3 color, float2 position, bool use_grain = true) {
  color = ApplyToneMap(color);
  if (use_grain) color = ApplyFilmGrain(color, position);
  return color;
}

float3 ToneMapAndRenderIntermediatePass(float3 color, float2 position, bool use_grain = true) {
  if (RENODX_GAMMA_CORRECTION == 1.f) {
    color = renodx::color::gamma::DecodeSafe(color, 2.2f);
    color = ApplyToneMapAndGrain(color, position, use_grain);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::gamma::EncodeSafe(color, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == 2.f) {
    color = renodx::color::gamma::DecodeSafe(color, 2.4f);
    color = ApplyToneMapAndGrain(color, position, use_grain);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::gamma::EncodeSafe(color, 2.4f);
  } else {
    color = renodx::color::srgb::DecodeSafe(color);
    color = ApplyToneMapAndGrain(color, position, use_grain);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::srgb::EncodeSafe(color);
  }
  return color;
}

float3 ApplyToneMapAndScale(float3 color, float2 position, bool use_grain = true) {
  return ToneMapAndRenderIntermediatePass(color, position, use_grain);
}

float3 InvertIntermediatePass(float3 color) {
  return color;
}

float3 ClampIntermediatePass(float3 color) {
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    color = saturate(color);
  } else if (RENODX_TONE_MAP_TYPE >= 2.f) {
    color = min(color, RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS);
  }
  return color;
}

float3 ClampAndRenderIntermediatePass(float3 color) {
  if (RENODX_GAMMA_CORRECTION == 1.f) {
    color = renodx::color::gamma::DecodeSafe(color, 2.2f);
    color = ClampIntermediatePass(color);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::gamma::EncodeSafe(color, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == 2.f) {
    color = renodx::color::gamma::DecodeSafe(color, 2.4f);
    color = ClampIntermediatePass(color);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::gamma::EncodeSafe(color, 2.4f);
  } else {
    color = renodx::color::srgb::DecodeSafe(color);
    color = ClampIntermediatePass(color);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::srgb::EncodeSafe(color);
  }
  return color;
}

float3 AC2ClampIntermediateToBT2020(float3 color) {
  if (RENODX_TONE_MAP_TYPE == 0.f) {
    return saturate(color);
  }

  color = max(0.f, color);

  if (RENODX_GAMMA_CORRECTION == 1.f) {
    color = renodx::color::gamma::DecodeSafe(color, 2.2f);
    color = renodx::color::bt709::clamp::BT2020(color);
    color = renodx::color::gamma::EncodeSafe(color, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == 2.f) {
    color = renodx::color::gamma::DecodeSafe(color, 2.4f);
    color = renodx::color::bt709::clamp::BT2020(color);
    color = renodx::color::gamma::EncodeSafe(color, 2.4f);
  } else {
    color = renodx::color::srgb::DecodeSafe(color);
    color = renodx::color::bt709::clamp::BT2020(color);
    color = renodx::color::srgb::EncodeSafe(color);
  }

  return color;
}
