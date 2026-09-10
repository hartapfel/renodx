#ifndef SRC_GAMES_GOTSUSHIMA_COMMON_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_COMMON_HLSLI_

#include "./shared.h"
#include "./sdr.hlsli"
#include "./test30.hlsl"
#include "./lilium_rcas.hlsli"

bool GhostIsPsychoV() {
  return RENODX_TONE_MAP_TYPE == 1.f;
}

float3 GhostApplyPsychoVInputExtensions(float3 color_bt709) {
  color_bt709 = renodx::math::ZeroNaN(color_bt709);
  color_bt709 = renodx::math::Select(isinf(color_bt709), 0.f.xxx, color_bt709);

  if (RENODX_TONE_MAP_GAMMA == 1.f
      && RENODX_TONE_MAP_CONTRAST == 1.f
      && RENODX_TONE_MAP_FLARE == 0.f) {
    return color_bt709;
  }

  const float luminance = max(
      renodx::color::y::from::BT709(color_bt709),
      0.f);
  float adjusted_luminance = luminance;
  if (RENODX_TONE_MAP_GAMMA != 1.f) {
    adjusted_luminance = pow(adjusted_luminance, RENODX_TONE_MAP_GAMMA);
  }
  if (RENODX_TONE_MAP_CONTRAST != 1.f
      || RENODX_TONE_MAP_FLARE != 0.f) {
    static const float mid_gray = 0.18f;
    const float normalized_luminance = max(
        adjusted_luminance / mid_gray,
        1e-6f);
    const float flare = 0.10f * pow(RENODX_TONE_MAP_FLARE, 10.f);
    const float flare_exponent = renodx::math::DivideSafe(
        normalized_luminance + flare,
        normalized_luminance,
        1.f);
    adjusted_luminance = pow(
        normalized_luminance,
        RENODX_TONE_MAP_CONTRAST * flare_exponent) * mid_gray;
  }

  return renodx::color::correct::Luminance(
      color_bt709,
      luminance,
      max(adjusted_luminance, 0.f));
}

float3 GhostApplyPsychoVOutputExtensions(
    float3 source_bt709,
    float3 mapped_bt709) {
  mapped_bt709 = renodx::math::ZeroNaN(mapped_bt709);
  mapped_bt709 = renodx::math::Select(isinf(mapped_bt709), 0.f.xxx, mapped_bt709);

  const float mapped_luminance = max(
      renodx::color::y::from::BT709(mapped_bt709),
      0.f);
  if (RENODX_TONE_MAP_BLOWOUT != 0.f
      || RENODX_TONE_MAP_HIGHLIGHT_SATURATION != 1.f) {
    float3 perceptual = renodx::color::oklab::from::BT709(mapped_bt709);

    if (RENODX_TONE_MAP_BLOWOUT != 0.f) {
      const float percent_hdr_container = saturate(
          mapped_luminance * max(RENODX_DIFFUSE_WHITE_NITS, 1.f) / 10000.f);
      perceptual.yz *= pow(
          1.f - percent_hdr_container,
          100.f * saturate(RENODX_TONE_MAP_BLOWOUT));
    }

    if (RENODX_TONE_MAP_HIGHLIGHT_SATURATION != 1.f) {
      const float strength = abs(RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f);
      const float source_luminance = max(
          renodx::color::y::from::BT709(source_bt709),
          0.f);
      const float percent_highlight = saturate(source_luminance * 100.f / 10000.f);
      float scale = pow(1.f - percent_highlight, 100.f * strength);
      if (RENODX_TONE_MAP_HIGHLIGHT_SATURATION > 1.f) {
        scale = 2.f - scale;
      }
      perceptual.yz *= scale;
    }

    mapped_bt709 = renodx::color::bt709::from::OkLab(perceptual);
  }

  // PsychoV already projects into the selected BT.709 or BT.2020 target.
  // Its BT.2020 result is represented in BT.709 and can legitimately contain
  // negative BT.709 components. Compressing/clamping that representation here
  // would collapse it back into BT.709 and distort the solved colors.
  return mapped_bt709;
}

struct GhostSDRCalibration {
  float input_anchor;
  float output_anchor;
  float contrast;
};

float3 GhostToneMapPsychoV30(float3 color_bt709, GhostSDRCalibration calibration) {
  color_bt709 = GhostApplyPsychoVInputExtensions(color_bt709);
  float3 mapped_bt709 = renodx::tonemap::psychov::psychotm_test30(
      color_bt709,
      RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f),
      RENODX_TONE_MAP_EXPOSURE,
      RENODX_TONE_MAP_HIGHLIGHTS,
      RENODX_TONE_MAP_SHADOWS,
      // User contrast is applied as a scalar luminance grade above. Passing
      // it into PsychoV's cone response also divides purity by contrast;
      // low values amplify LUT/transport quantization into colored bands.
      1.f,
      RENODX_TONE_MAP_SATURATION,
      1.f,
      100.f,
      RENODX_PSYCHOV_HUE_SHIFT,
      1.f,
      0,
      RENODX_PSYCHOV_CONE_RESPONSE_EXPONENT * calibration.contrast,
      calibration.input_anchor.xxx,
      calibration.output_anchor.xxx,
      RENODX_PSYCHOV_GAMUT_COMPRESSION,
      int(RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE),
      1.f,
      RENODX_PSYCHOV_COMPRESSION);
  return GhostApplyPsychoVOutputExtensions(color_bt709, mapped_bt709);
}

float3 GhostGetPsychoVEndpoint(GhostSDRCalibration calibration) {
  // Use a large finite reference input to normalize PsychoV's highlight
  // endpoint without evaluating its response at infinity.
  return GhostToneMapPsychoV30(65504.f.xxx, calibration);
}

float3 GhostApplyPackedColorMatrix(
    float3 color,
    float4 packed_0,
    float4 packed_1,
    float4 packed_2) {
  return float3(
      dot(color, float3(packed_0.x, packed_0.w, packed_1.z)),
      dot(color, float3(packed_0.y, packed_1.x, packed_1.w)),
      dot(color, float3(packed_0.z, packed_1.y, packed_2.x)));
}

float3 GhostNormalizePsychoVEndpoint(
    float3 mapped_bt709,
    float3 endpoint_bt709) {
  // Measure the endpoint in the actual HDR10 transport gamut. A valid BT.2020
  // color can exceed the selected peak when inspected as signed BT.709 RGB.
  const float mapped_peak = renodx::math::Max(
      renodx::color::bt2020::from::BT709(mapped_bt709));
  const float endpoint_peak = renodx::math::Max(
      renodx::color::bt2020::from::BT709(endpoint_bt709));
  const float peak_ratio = max(
      RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f),
      1.f);

  // Gamma emulation is part of the decoded LUT input. PsychoV and its
  // endpoint now operate in display-linear light, so no inverse gamma
  // compensation is needed when normalizing the HDR endpoint.
  if (mapped_peak > 1.f && endpoint_peak > 1.f && peak_ratio > 1.f) {
    const float highlight_gain = max(
        1.f,
        renodx::math::DivideSafe(
            peak_ratio - 1.f,
            endpoint_peak - 1.f,
            1.f));
    const float stretched_peak = min(
        1.f + (mapped_peak - 1.f) * highlight_gain,
        peak_ratio);
    mapped_bt709 *= renodx::math::DivideSafe(
        stretched_peak,
        mapped_peak,
        1.f);
  }
  return mapped_bt709;
}

// Replace the native gamma-domain LUT shoulder with a linear-light
// anchored C-infinity shoulder. Preserve its identity threshold (0.475 in
// square-root space), and approach the LUT boundary without a hard plateau.
// Return the square-root-domain scale for both lookup and reconstruction.
float GhostGetLUTSamplingScale(float3 linear_bt709) {
  const float max_channel = renodx::math::Max(linear_bt709);
  static const float anchor = 0.475f * 0.475f;
  static const float shoulder_range = 1.f - anchor;
  static const float compression_strength = 1.5f;
  // Includes black; avoids dividing by zero at the anchor and in the ratio.
  if (max_channel <= anchor) return 1.f;

  const float distance_from_anchor = max_channel - anchor;
  const float flat_weight = exp2(
      -shoulder_range / (compression_strength * distance_from_anchor));
  const float response_denominator = mad(
      distance_from_anchor, flat_weight, shoulder_range);
  const float mapped_max = mad(
      shoulder_range, distance_from_anchor / response_denominator, anchor);
  return sqrt(mapped_max / max_channel);
}

// Decode the reconstructed LUT's sRGB representation directly. PsychoV
// deliberately omits the native BT.709 OETF/display-EOTF contrast; that
// presentation remains available in SDR in HDR and on the validated UI path.
// Optional gamma emulation substitutes the selected EOTF for sRGB here,
// equivalent to sRGB decode followed by GammaSafe(..., false, gamma).
// Do not saturate here: LUT reconstruction must retain HDR headroom.
float3 GhostDecodeLUTOutput(float3 encoded_bt709) {
  encoded_bt709 = max(encoded_bt709, 0.f.xxx);
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    return renodx::color::gamma::DecodeSafe(encoded_bt709, 2.2f);
  }
  if (RENODX_GAMMA_CORRECTION == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    return renodx::color::gamma::DecodeSafe(encoded_bt709, 2.4f);
  }
  return renodx::color::srgb::DecodeSafe(encoded_bt709);
}

struct GhostSceneGrade {
  float4 pre_0;
  float4 pre_1;
  float4 pre_2;
  float4 post_0;
  float4 post_1;
  float4 post_2;
  uint2 lut_indices;
  float4 lut_coordinates;
  float lut_blend;
};

// Evaluate a neutral scene sample through the active matrices and LUTs.
// Both routes use the same output decode; only native SDR has its scene
// curve/clamp, while the HDR route uses the existing reconstructable shoulder.
// Neither calibration route includes the native SDR display transform, so
// matching the anchor/slope cannot reintroduce its additional contrast.
float GhostEvaluateGray(float gray, GhostSceneGrade grade, SamplerState lut_sampler, bool native_sdr) {
  float3 color = GhostApplyPackedColorMatrix(gray.xxx, grade.pre_0, grade.pre_1, grade.pre_2);
  if (native_sdr) color = GhostToneMapSDR(color);
  color = max(GhostApplyPackedColorMatrix(color, grade.post_0, grade.post_1, grade.post_2), 0.f.xxx);
  float scale = native_sdr ? 1.f : GhostGetLUTSamplingScale(color);
  color = sqrt(color) * scale;
  Texture3D<float4> lut = ResourceDescriptorHeap[grade.lut_indices.x];
  float3 graded = lut.SampleLevel(lut_sampler, color * grade.lut_coordinates.x + grade.lut_coordinates.y, 0.f).rgb;
  if (grade.lut_blend > 0.f) {
    Texture3D<float4> second_lut = ResourceDescriptorHeap[grade.lut_indices.y];
    graded = lerp(graded,
                  second_lut.SampleLevel(lut_sampler, color * grade.lut_coordinates.z + grade.lut_coordinates.w, 0.f).rgb,
                  grade.lut_blend);
  }
  if (native_sdr) graded = saturate(graded);
  return max(renodx::color::y::from::BT709(GhostDecodeLUTOutput(graded / scale)), 1e-6f);
}

GhostSDRCalibration GhostCalibratePsychoV(GhostSceneGrade grade, SamplerState lut_sampler) {
  GhostSDRCalibration calibration;
  calibration.input_anchor = GhostEvaluateGray(RENODX_PSYCHOV_ADAPTATION_ANCHOR, grade, lut_sampler, false);
  calibration.output_anchor = GhostEvaluateGray(RENODX_PSYCHOV_BACKGROUND_ANCHOR, grade, lut_sampler, true);
  // Centered +/- 1/64-stop samples measure logarithmic slope through the
  // actual artistic LUT blend, including the masked variant's blend weight.
  float input_low = GhostEvaluateGray(RENODX_PSYCHOV_ADAPTATION_ANCHOR * 0.9892280132f, grade, lut_sampler, false);
  float input_high = GhostEvaluateGray(RENODX_PSYCHOV_ADAPTATION_ANCHOR * 1.0108892861f, grade, lut_sampler, false);
  float output_low = GhostEvaluateGray(RENODX_PSYCHOV_BACKGROUND_ANCHOR * 0.9892280132f, grade, lut_sampler, true);
  float output_high = GhostEvaluateGray(RENODX_PSYCHOV_BACKGROUND_ANCHOR * 1.0108892861f, grade, lut_sampler, true);
  float input_slope = log2(input_high / input_low);
  float output_slope = log2(output_high / output_low);
  // A flat or reversed LUT segment cannot define a positive tone-curve
  // slope. Retain unit slope there instead of dividing by zero/noise.
  calibration.contrast = input_slope > 1e-4f && output_slope > 1e-4f
                             ? output_slope / input_slope
                             : 1.f;
  return calibration;
}

float3 GhostRenderIntermediate(float3 color_bt709, float2 uv) {
  // PsychoV returns its target-gamut result represented as linear BT.709.
  // Convert it to BT.2020 before PQ transport so valid wide-gamut
  // colors do not require negative channels in the RGB10A2 intermediate.
  float3 color_bt2020 = max(
      renodx::color::bt2020::from::BT709(color_bt709), 0.f.xxx);
  if (CUSTOM_FILM_GRAIN > 0.f) {
    // Perceptual film density is evaluated in linear display-referred color,
    // relative to scene white. Apply after PsychoV, before PQ and HUD.
    color_bt2020 = renodx::effects::ApplyFilmGrain(
        color_bt2020, uv, CUSTOM_RANDOM, CUSTOM_FILM_GRAIN * 0.03f,
        1.f, false, renodx::color::BT2020_TO_XYZ_MAT);
  }
  // The display EOTF has already been applied to the LUT result. Applying
  // RenderIntermediatePass here would apply gamma emulation a second time.
  return renodx::color::pq::EncodeSafe(color_bt2020, RENODX_DIFFUSE_WHITE_NITS);
}

float3 GhostEncodeHDR10(float3 intermediate_encoded) {
  // The intermediate is already absolute-nit PQ. Decode it only to clamp at
  // the selected display peak, then emit HDR10 PQ without an SDR transfer.
  float3 color_bt2020_nits = max(
      renodx::color::pq::DecodeSafe(intermediate_encoded, 1.f),
      0.f.xxx);
  const float max_nits = renodx::math::Max(color_bt2020_nits);
  color_bt2020_nits *= min(
      1.f,
      max(RENODX_PEAK_WHITE_NITS, 1.f) / max(max_nits, 1e-6f));
  return renodx::color::pq::EncodeSafe(color_bt2020_nits, 1.f);
}

#endif  // SRC_GAMES_GOTSUSHIMA_COMMON_HLSLI_
