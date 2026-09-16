#ifndef SRC_GAMES_ASSCREEDEZIOTRILOGY_COMMON_HLSLI_
#define SRC_GAMES_ASSCREEDEZIOTRILOGY_COMMON_HLSLI_

#include "./psychov30.hlsli"
#include "./presentation.hlsli"

float AC2WorkingPeak() {
  // 80 nits is the lowest Game Brightness setting. Keeping enough working
  // headroom for that value avoids expanding a bounded response at high peaks.
  return max(4000.f / 203.f, RENODX_PEAK_WHITE_NITS / 80.f);
}

float3 AC2ApplyPsychoVInputExtensions(float3 color_bt709) {
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
                             RENODX_TONE_MAP_CONTRAST * flare_exponent)
                         * mid_gray;
  }

  return renodx::color::correct::Luminance(
      color_bt709,
      luminance,
      max(adjusted_luminance, 0.f));
}

float3 AC2ApplyPsychoVOutputExtensions(
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

struct AC2SDRCalibration {
  float input_anchor;
  float output_anchor;
  float contrast;
};

float3 AC2ToneMapPsychoV30(float3 color_bt709, AC2SDRCalibration calibration) {
  color_bt709 = AC2ApplyPsychoVInputExtensions(color_bt709);
  // Keep the observer response independent of Game Brightness. Changing its
  // peak changes hue/gamut projection and can make highlights dim as brightness
  // rises. Fit this fixed response to the selected physical display afterwards.
  const float working_peak = AC2WorkingPeak();
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

  const float max_channel = renodx::math::Max(RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                                          ? mapped_bt709
                                          : renodx::color::bt2020::from::BT709(mapped_bt709));
  const float luminance = renodx::color::y::from::BT709(mapped_bt709);
  const float headroom = max(working_peak - luminance, 0.f);
  const float chroma_peak = max_channel - luminance;
  if (chroma_peak > 0.8f * headroom) {
    // Soften the upper gamut boundary instead of carrying PsychoV's projected
    // peak channel onto the display ceiling. Luminance remains intact; even a
    // channel on the gamut boundary keeps rising as the highlight approaches
    // white. The neutral/LUT-white limit still maps to the selected peak.
    const float excess = chroma_peak - 0.8f * headroom;
    const float fitted_chroma = 0.8f * headroom + excess * (0.2f * headroom / (0.2f * headroom + excess));
    mapped_bt709 = luminance + (mapped_bt709 - luminance) * (fitted_chroma / chroma_peak);
  }
  return AC2ApplyPsychoVOutputExtensions(color_bt709, mapped_bt709);
}

float3 AC2SampleLUT(float3 encoded, sampler3D lut,
                    float3 coordinate_scale, float3 coordinate_offset) {
  // Preserve native trilinear addressing, but interpolate in shader precision.
  // Hardware interpolation weights can quantize a small channel noticeably
  // when the HDR bridge restores a large scale. Vanilla keeps hardware sampling.
  // AC2 uses a 16^3 LUT. SM3 has no Texture3D.Load; exact binary texel
  // centers and explicit LOD 0 fetch the eight vertices through native s1.
  const float width = 16.f, height = 16.f, depth = 16.f;
  float3 position = clamp((encoded * coordinate_scale + coordinate_offset)
                                  * float3(width, height, depth)
                              - 0.5f,
                          0.f.xxx, float3(width, height, depth) - 1.f);
  int3 low = int3(floor(position));
  int3 high = min(low + 1, int3(width, height, depth) - 1);
  float3 fraction = frac(position);
  float3 result = lerp(
      lerp(lerp(tex3Dlod(lut, float4((float3(low) + 0.5f) / 16.f, 0.f)).rgb, tex3Dlod(lut, float4((float3(high.x, low.yz) + 0.5f) / 16.f, 0.f)).rgb, fraction.x),
           lerp(tex3Dlod(lut, float4((float3(low.x, high.y, low.z) + 0.5f) / 16.f, 0.f)).rgb, tex3Dlod(lut, float4((float3(high.xy, low.z) + 0.5f) / 16.f, 0.f)).rgb, fraction.x), fraction.y),
      lerp(lerp(tex3Dlod(lut, float4((float3(low.xy, high.z) + 0.5f) / 16.f, 0.f)).rgb, tex3Dlod(lut, float4((float3(high.x, low.y, high.z) + 0.5f) / 16.f, 0.f)).rgb, fraction.x),
           lerp(tex3Dlod(lut, float4((float3(low.x, high.yz) + 0.5f) / 16.f, 0.f)).rgb, tex3Dlod(lut, float4((float3(high) + 0.5f) / 16.f, 0.f)).rgb, fraction.x), fraction.y),
      fraction.z);
  return result;
}

float3 AC2GradeHDR(float3 linear_bt709, sampler3D lut,
                   float3 coordinate_scale, float3 coordinate_offset) {
  // A reversible gamut fit plus max-channel N2 creates a bounded, hue-preserving
  // LUT input. Decode the sampled grade before restoring the linear HDR scale.
  const float3 adaptive_lms = renodx::color::lms::from::BT709(1.f.xxx);
  const float gamut_scale = renodx::color::gamut::ComputeGamutCompressionScaleBT709AdaptiveD65(
      linear_bt709, adaptive_lms, 1.f);
  float3 compressed = renodx::color::gamut::GamutCompressBT709AdaptiveD65(linear_bt709, adaptive_lms, gamut_scale);
  const float range_scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(compressed);
  float3 encoded = renodx::draw::EncodeColor(max(compressed * range_scale, 0.f.xxx), RENODX_SWAP_CHAIN_DECODING);
  float3 graded = renodx::draw::DecodeColor(
      AC2SampleLUT(encoded, lut, coordinate_scale, coordinate_offset),
      RENODX_SWAP_CHAIN_DECODING);
  return renodx::color::gamut::GamutDecompressBT709AdaptiveD65(
      graded / max(range_scale, 1e-6f), adaptive_lms, gamut_scale);
}

float3 AC2ApplyColorFilter(float3 filtered, float3 unfiltered) {
  // Match Ghost's Color Filter control: remove grade chroma while preserving
  // graded luminance and lighting, then fit chroma into the selected gamut.
  if (CUSTOM_COLOR_FILTER == 1.f) return filtered;
  float3 graded_target = RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                             ? filtered
                             : renodx::color::bt2020::from::BT709(filtered);
  float3 neutral_target = RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                              ? unfiltered
                              : renodx::color::bt2020::from::BT709(unfiltered);
  const float luminance = clamp(renodx::color::y::from::BT709(filtered), 0.f, AC2WorkingPeak());
  const float unfiltered_luminance = renodx::color::y::from::BT709(unfiltered);
  neutral_target = unfiltered_luminance > 1e-6f ? neutral_target * (luminance / unfiltered_luminance) : luminance.xxx;
  float3 chroma = lerp(neutral_target, graded_target, saturate(CUSTOM_COLOR_FILTER)) - luminance;
  const float3 limits = renodx::math::Select(chroma > 0.f,
                                             (AC2WorkingPeak() - luminance) / max(chroma, 1e-6f.xxx),
                                             luminance / max(-chroma, 1e-6f.xxx));
  chroma *= saturate(renodx::math::Min(limits));
  return RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
             ? luminance + chroma
             : renodx::color::bt709::from::BT2020(luminance + chroma);
}

float3 AC2ToneMapScene(float3 encoded_scene, sampler3D lut,
                       float3 coordinate_scale, float3 coordinate_offset) {
  float3 scene = renodx::draw::DecodeColor(encoded_scene, RENODX_SWAP_CHAIN_DECODING);
  scene = renodx::math::Select(isinf(scene), 0.f.xxx, renodx::math::ZeroNaN(scene));
  float3 graded = AC2GradeHDR(scene, lut, coordinate_scale, coordinate_offset);

  // AC2 has a hard SDR limit, not Ghost's analytic SDR curve or sqrt shaper.
  // Calibrate gray through the real grade, with unit pre-LUT logarithmic slope.
  // Anchors scale these measured levels; the artistic LUT derivative is not
  // used as a cone exponent (flat cells would make that unstable).
  AC2SDRCalibration calibration;
  calibration.input_anchor = max(renodx::color::y::from::BT709(AC2GradeHDR(
                                     0.18f.xxx, lut, coordinate_scale, coordinate_offset)),
                                 1e-5f)
                             * RENODX_PSYCHOV_ADAPTATION_ANCHOR / 0.18f;
  calibration.output_anchor = max(renodx::color::y::from::BT709(renodx::draw::DecodeColor(AC2SampleLUT(
                                                                                              renodx::draw::EncodeColor(0.18f.xxx, RENODX_SWAP_CHAIN_DECODING),
                                                                                              lut, coordinate_scale, coordinate_offset),
                                                                                          RENODX_SWAP_CHAIN_DECODING)),
                                  1e-5f)
                              * RENODX_PSYCHOV_BACKGROUND_ANCHOR / 0.18f;
  // Keep the observer anchor inside its working volume, independently of
  // Game Brightness; the subsequent shoulder handles the physical display.
  calibration.output_anchor = min(calibration.output_anchor, AC2WorkingPeak() * 0.95f);
  calibration.contrast = 1.f;
  float3 mapped = AC2ToneMapPsychoV30(graded, calibration);
  if (CUSTOM_COLOR_FILTER != 1.f) {
    mapped = AC2ApplyColorFilter(mapped, AC2ToneMapPsychoV30(scene, calibration));
  }
  // Preserve the game's encoded BT.709 composition domain, including signed
  // BT.709 representations of PsychoV's BT.2020 colors. The proxy encodes PQ.
  // Expand directly from the fixed working volume. A display-fit/undo pair
  // would cancel algebraically but lose precision near the peak on SM3/FP16.
  return renodx::draw::EncodeColor(AC2ExpandForPresentation(mapped, AC2WorkingPeak()), RENODX_SWAP_CHAIN_DECODING);
}

#endif  // SRC_GAMES_ASSCREEDEZIOTRILOGY_COMMON_HLSLI_
