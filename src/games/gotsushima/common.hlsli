#ifndef SRC_GAMES_GOTSUSHIMA_COMMON_HLSLI_
#define SRC_GAMES_GOTSUSHIMA_COMMON_HLSLI_

#include "./shared.h"
#include "./intermediate.hlsli"
#include "./sdr.hlsli"
#include "./test30.hlsl"
#include "./chromatic_aberration.hlsli"

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
  const float display_peak = RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f);
  // Auto retains a wider HDR response before fitting it to the display.
  // At 1000 nits, direct target-volume projection can pin fire channels to
  // the peak before their luminance gradient has been resolved. The 4000-nit
  // reference was checked against the affected fire scene. Manual compression
  // remains a direct PsychoV response at the selected display peak.
  const float working_peak = RENODX_PSYCHOV_COMPRESSION == 0.f
                                 ? max(display_peak, 4000.f / max(RENODX_DIFFUSE_WHITE_NITS, 1.f))
                                 : display_peak;
  float3 mapped_bt709 = renodx::tonemap::psychov::psychotm_test30(
      color_bt709,
      working_peak,
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

  if (working_peak > display_peak) {
    const float max_channel = renodx::math::Max(renodx::color::bt2020::from::BT709(mapped_bt709));
    const float anchor = min(1.f, display_peak * 0.5f);
    if (max_channel > anchor) {
      // Anchored finite-range Reinhard: identity and unit slope at the knee,
      // strictly increasing through the HDR range, working_peak -> display_peak.
      // Uniform linear RGB scaling preserves chromaticity, including signed
      // BT.709 representations of valid BT.2020 colors. No per-channel clip.
      const float distance = max_channel - anchor;
      const float shoulder = anchor + distance / (1.f + distance
          * (rcp(display_peak - anchor) - rcp(working_peak - anchor)));
      mapped_bt709 *= shoulder / max_channel;
    }
  }
  return GhostApplyPsychoVOutputExtensions(color_bt709, mapped_bt709);
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

float3 GhostApplySceneColorFilter(
    float3 filtered_bt709,
    float3 scene_bt709,
    GhostSDRCalibration calibration) {
  // An identity LUT with the existing square-root shaper/reconstruction
  // returns sqrt(scene). Omit native matrices and LUT color grading for this
  // reference, but retain the selected decode and all user PsychoV controls.
  float3 unfiltered_bt2020 = max(renodx::color::bt2020::from::BT709(
      GhostToneMapPsychoV30(GhostDecodeLUTOutput(sqrt(max(scene_bt709, 0.f.xxx))), calibration)), 0.f.xxx);
  const float peak = RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f);
  // Match the original RGB10A2 transport bounds and final peak guard before
  // choosing a luminance. This also covers UI white above the display peak.
  float3 filtered_bt2020 = clamp(renodx::color::bt2020::from::BT709(filtered_bt709),
                                0.f.xxx, (RENODX_INTERMEDIATE_SCALING / max(RENODX_DIFFUSE_WHITE_NITS, 1.f)).xxx);
  filtered_bt2020 *= min(1.f, peak / max(renodx::math::Max(filtered_bt2020), 1e-6f));
  const float luminance = renodx::color::y::from::BT2020(filtered_bt2020);
  const float unfiltered_luminance = renodx::color::y::from::BT2020(unfiltered_bt2020);
  unfiltered_bt2020 = unfiltered_luminance > 1e-6f
                         ? unfiltered_bt2020 * (luminance / unfiltered_luminance)
                         : luminance.xxx;
  float3 chroma = lerp(unfiltered_bt2020, filtered_bt2020, saturate(CUSTOM_COLOR_FILTER)) - luminance;
  // Reduce only chroma to fit the display volume, at fixed physical Y. A
  // per-channel clamp or a max-channel scale here would change luminance.
  const float3 target_chroma = RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                                  ? renodx::color::bt709::from::BT2020(chroma)
                                  : chroma;
  const float3 chroma_limit = renodx::math::Select(
      target_chroma > 0.f,
      (peak - luminance) / max(target_chroma, 1e-6f.xxx),
      luminance / max(-target_chroma, 1e-6f.xxx));
  chroma *= saturate(min(chroma_limit.x, min(chroma_limit.y, chroma_limit.z)));
  return renodx::color::bt709::from::BT2020(luminance + chroma);
}

// Evaluate a neutral scene sample through the active matrices and LUTs.
// Both routes use the same output decode; only native SDR has its scene
// curve/clamp, while the HDR route uses the existing reconstructable shoulder.
// Neither calibration route includes the native SDR display transform, so
// matching the anchor/slope cannot reintroduce its additional contrast.
float GhostEvaluateGray(float gray, GhostSceneGrade grade, SamplerState lut_sampler, bool native_sdr, bool sample_lut) {
  float3 color = GhostApplyPackedColorMatrix(gray.xxx, grade.pre_0, grade.pre_1, grade.pre_2);
  if (native_sdr) color = GhostToneMapSDR(color);
  color = max(GhostApplyPackedColorMatrix(color, grade.post_0, grade.post_1, grade.post_2), 0.f.xxx);
  // Contrast calibration uses the native scene curve, not derivatives of
  // different artistic LUT cells. A nearly flat HDR-side LUT segment can
  // otherwise turn their slope ratio into an arbitrarily strong cone power.
  // An identity LUT with max-channel reconstruction returns sqrt(color).
  if (!sample_lut) {
    return max(renodx::color::y::from::BT709(GhostDecodeLUTOutput(sqrt(color))), 1e-6f);
  }
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
  // Keep calibration independent of the user anchors. Measure anchor levels
  // through the actual artistic grade, but measure contrast before that LUT.
  static const float reference_gray = 0.18f;
  GhostSDRCalibration calibration;
  calibration.input_anchor = GhostEvaluateGray(reference_gray, grade, lut_sampler, false, true);
  calibration.output_anchor = GhostEvaluateGray(reference_gray, grade, lut_sampler, true, true);
  // Centered +/- 1/64-stop samples retain the native curve's contrast and
  // active matrices/decode without dividing unrelated local LUT derivatives.
  float input_low = GhostEvaluateGray(reference_gray * 0.9892280132f, grade, lut_sampler, false, false);
  float input_high = GhostEvaluateGray(reference_gray * 1.0108892861f, grade, lut_sampler, false, false);
  float output_low = GhostEvaluateGray(reference_gray * 0.9892280132f, grade, lut_sampler, true, false);
  float output_high = GhostEvaluateGray(reference_gray * 1.0108892861f, grade, lut_sampler, true, false);
  float input_slope = log2(input_high / input_low);
  float output_slope = log2(output_high / output_low);
  // A flat or reversed scene-curve segment cannot define a positive tone-curve
  // slope. Retain unit slope there instead of dividing by zero/noise.
  calibration.contrast = input_slope > 1e-4f && output_slope > 1e-4f
                             ? output_slope / input_slope
                             : 1.f;
  // 0.18 leaves the calibrated look intact. Each slider scales only its
  // corresponding PsychoV anchor, without moving the calibration samples.
  calibration.input_anchor *= RENODX_PSYCHOV_ADAPTATION_ANCHOR / reference_gray;
  calibration.output_anchor *= RENODX_PSYCHOV_BACKGROUND_ANCHOR / reference_gray;
  return calibration;
}

float3 GhostRenderIntermediate(float3 color_bt709, float2 uv) {
  // PsychoV returns its target-gamut result represented as linear BT.709.
  // Convert it to BT.2020 before transport so valid wide-gamut
  // colors do not require negative channels in the RGB10A2 intermediate.
  float3 color_bt2020 = max(
      renodx::color::bt2020::from::BT709(color_bt709), 0.f.xxx);
  if (CUSTOM_FILM_GRAIN > 0.f) {
    // Perceptual film density is evaluated in linear display-referred color,
    // relative to scene white. Apply after PsychoV, before encoding and HUD.
    color_bt2020 = renodx::effects::ApplyFilmGrain(
        color_bt2020, uv, CUSTOM_RANDOM, CUSTOM_FILM_GRAIN * 0.03f,
        1.f, false, renodx::color::BT2020_TO_XYZ_MAT);
  }
  // The display EOTF has already been applied to the LUT result. Applying
  // RenderIntermediatePass here would apply gamma emulation a second time.
  return GhostEncodeIntermediate(color_bt2020 * RENODX_DIFFUSE_WHITE_NITS);
}

float3 GhostEncodeHDR10(float3 intermediate_encoded) {
  // Undo the composition encoding, preserving the scene/UI display response.
  // Apply the peak guard and encode PQ only after native HUD composition.
  float3 color_bt2020_nits = max(
      renodx::color::gamma::DecodeSafe(intermediate_encoded, 2.2f),
      0.f.xxx) * RENODX_INTERMEDIATE_SCALING;
  const float max_nits = renodx::math::Max(color_bt2020_nits);
  color_bt2020_nits *= min(
      1.f,
      max(RENODX_PEAK_WHITE_NITS, 1.f) / max(max_nits, 1e-6f));
  return renodx::color::pq::EncodeSafe(color_bt2020_nits, 1.f);
}

#endif  // SRC_GAMES_GOTSUSHIMA_COMMON_HLSLI_
