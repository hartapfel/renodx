#ifndef SRC_GAMES_ASSCREED2_COMMON_HLSLI_
#define SRC_GAMES_ASSCREED2_COMMON_HLSLI_

#include "./shared.h"
#include "./psychov30.hlsli"

float AC2DisplayPeak() {
  return RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f);
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
        RENODX_TONE_MAP_CONTRAST * flare_exponent) * mid_gray;
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
  const float display_peak = AC2DisplayPeak();
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
  return AC2ApplyPsychoVOutputExtensions(color_bt709, mapped_bt709);
}

float3 AC2SampleLUT(float3 encoded, Texture3D<float4> lut, SamplerState lut_sampler,
                   float3 coordinate_scale, float3 coordinate_offset, uint3 sample_and, uint3 sample_or) {
  // Preserve native trilinear addressing, but interpolate in shader precision.
  // Hardware interpolation weights can quantize a small channel noticeably
  // when the HDR bridge restores a large scale. Vanilla keeps hardware sampling.
  uint width, height, depth;
  lut.GetDimensions(width, height, depth);
  float3 position = clamp((encoded * coordinate_scale + coordinate_offset)
      * float3(width, height, depth) - 0.5f, 0.f.xxx, float3(width, height, depth) - 1.f);
  int3 low = int3(floor(position));
  int3 high = min(low + 1, int3(width, height, depth) - 1);
  float3 fraction = frac(position);
  float3 result = lerp(
      lerp(lerp(lut.Load(int4(low, 0)).rgb, lut.Load(int4(high.x, low.yz, 0)).rgb, fraction.x),
           lerp(lut.Load(int4(low.x, high.y, low.z, 0)).rgb, lut.Load(int4(high.xy, low.z, 0)).rgb, fraction.x), fraction.y),
      lerp(lerp(lut.Load(int4(low.xy, high.z, 0)).rgb, lut.Load(int4(high.x, low.y, high.z, 0)).rgb, fraction.x),
           lerp(lut.Load(int4(low.x, high.yz, 0)).rgb, lut.Load(int4(high, 0)).rgb, fraction.x), fraction.y), fraction.z);
  return asfloat((asuint(result) & sample_and) | sample_or);
}

float3 AC2GradeHDR(float3 linear_bt709, Texture3D<float4> lut, SamplerState lut_sampler,
                  float3 coordinate_scale, float3 coordinate_offset, uint3 sample_and, uint3 sample_or) {
  // A reversible gamut fit plus max-channel N2 creates a bounded, hue-preserving
  // LUT input. Decode the sampled grade before restoring the linear HDR scale.
  const float3 adaptive_lms = renodx::color::lms::from::BT709(1.f.xxx);
  const float gamut_scale = renodx::color::gamut::ComputeGamutCompressionScaleBT709AdaptiveD65(
      linear_bt709, adaptive_lms, 1.f);
  float3 compressed = renodx::color::gamut::GamutCompressBT709AdaptiveD65(linear_bt709, adaptive_lms, gamut_scale);
  const float range_scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(compressed);
  float3 encoded = renodx::draw::EncodeColor(max(compressed * range_scale, 0.f.xxx), RENODX_SWAP_CHAIN_DECODING);
  float3 graded = renodx::draw::DecodeColor(
      AC2SampleLUT(encoded, lut, lut_sampler, coordinate_scale, coordinate_offset, sample_and, sample_or),
      RENODX_SWAP_CHAIN_DECODING);
  return renodx::color::gamut::GamutDecompressBT709AdaptiveD65(
      graded / max(range_scale, 1e-6f), adaptive_lms, gamut_scale);
}

float3 AC2ApplyColorFilter(float3 filtered, float3 unfiltered) {
  // Match Ghost's Color Filter control: remove grade chroma while preserving
  // graded luminance and lighting, then fit chroma into the selected gamut.
  if (shader_injection.color_filter == 1.f) return filtered;
  float3 graded_target = RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                            ? filtered : renodx::color::bt2020::from::BT709(filtered);
  float3 neutral_target = RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
                             ? unfiltered : renodx::color::bt2020::from::BT709(unfiltered);
  const float luminance = clamp(renodx::color::y::from::BT709(filtered), 0.f, AC2DisplayPeak());
  const float unfiltered_luminance = renodx::color::y::from::BT709(unfiltered);
  neutral_target = unfiltered_luminance > 1e-6f ? neutral_target * (luminance / unfiltered_luminance) : luminance.xxx;
  float3 chroma = lerp(neutral_target, graded_target, saturate(shader_injection.color_filter)) - luminance;
  const float3 limits = renodx::math::Select(chroma > 0.f,
      (AC2DisplayPeak() - luminance) / max(chroma, 1e-6f.xxx),
      luminance / max(-chroma, 1e-6f.xxx));
  chroma *= saturate(renodx::math::Min(limits));
  return RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE == 0.f
             ? luminance + chroma : renodx::color::bt709::from::BT2020(luminance + chroma);
}

float3 AC2ToneMapScene(float3 encoded_scene, Texture3D<float4> lut, SamplerState lut_sampler,
                      float3 coordinate_scale, float3 coordinate_offset, uint3 sample_and, uint3 sample_or) {
  float3 scene = renodx::draw::DecodeColor(encoded_scene, RENODX_SWAP_CHAIN_DECODING);
  scene = renodx::math::Select(isinf(scene), 0.f.xxx, renodx::math::ZeroNaN(scene));
  float3 graded = AC2GradeHDR(scene, lut, lut_sampler, coordinate_scale, coordinate_offset, sample_and, sample_or);

  // AC2 has a hard SDR limit, not Ghost's analytic SDR curve or sqrt shaper.
  // Calibrate gray through the real grade, with unit pre-LUT logarithmic slope.
  // Anchors scale these measured levels; the artistic LUT derivative is not
  // used as a cone exponent (flat cells would make that unstable).
  AC2SDRCalibration calibration;
  calibration.input_anchor = max(renodx::color::y::from::BT709(AC2GradeHDR(
      0.18f.xxx, lut, lut_sampler, coordinate_scale, coordinate_offset, sample_and, sample_or)), 1e-5f)
      * RENODX_PSYCHOV_ADAPTATION_ANCHOR / 0.18f;
  calibration.output_anchor = max(renodx::color::y::from::BT709(renodx::draw::DecodeColor(AC2SampleLUT(
      renodx::draw::EncodeColor(0.18f.xxx, RENODX_SWAP_CHAIN_DECODING),
      lut, lut_sampler, coordinate_scale, coordinate_offset, sample_and, sample_or), RENODX_SWAP_CHAIN_DECODING)), 1e-5f)
      * RENODX_PSYCHOV_BACKGROUND_ANCHOR / 0.18f;
  // The requested anchor must stay below the display peak, including the
  // legal combination of 400-nit peak / 500-nit reference white.
  calibration.output_anchor = min(calibration.output_anchor, AC2DisplayPeak() * 0.95f);
  calibration.contrast = 1.f;
  float3 mapped = AC2ToneMapPsychoV30(graded, calibration);
  if (shader_injection.color_filter != 1.f) {
    mapped = AC2ApplyColorFilter(mapped, AC2ToneMapPsychoV30(scene, calibration));
  }
  // Preserve the game's encoded BT.709 composition domain, including signed
  // BT.709 representations of PsychoV's BT.2020 colors. The proxy encodes PQ.
  return renodx::draw::EncodeColor(mapped, RENODX_SWAP_CHAIN_DECODING);
}

#endif  // SRC_GAMES_ASSCREED2_COMMON_HLSLI_
