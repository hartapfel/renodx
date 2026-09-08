#ifndef SRC_GAMES_GHOSTOFTSUSHIMA_COMMON_HLSLI_
#define SRC_GAMES_GHOSTOFTSUSHIMA_COMMON_HLSLI_

#include "./shared.h"
#include "./test30.hlsl"

bool GhostIsPsychoV() {
  return RENODX_TONE_MAP_TYPE != 0.f;
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

float3 GhostToneMapPsychoV30(float3 color_bt709) {
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
      RENODX_PSYCHOV_CONE_RESPONSE_EXPONENT,
      RENODX_PSYCHOV_ADAPTATION_ANCHOR.xxx,
      RENODX_PSYCHOV_BACKGROUND_ANCHOR.xxx,
      RENODX_PSYCHOV_GAMUT_COMPRESSION,
      int(RENODX_PSYCHOV_GAMUT_COMPRESSION_MODE),
      1.f,
      RENODX_PSYCHOV_COMPRESSION);
  return GhostApplyPsychoVOutputExtensions(color_bt709, mapped_bt709);
}

float3 GhostGetPsychoVEndpoint() {
  // The scene source is FP16. Evaluate PsychoV at the brightest finite value
  // the source can carry so the selected display peak remains reachable.
  return GhostToneMapPsychoV30(65504.f.xxx);
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

  // RenderIntermediatePass applies the forward SDR response after PsychoV.
  // Stretch its finite endpoint to the inverse-corrected value so decoding
  // the bounded PQ transport still lands exactly on the selected peak.
  float transport_peak_ratio = peak_ratio;
  if (RENODX_GAMMA_CORRECTION
      == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    transport_peak_ratio = renodx::color::correct::GammaSafe(
        peak_ratio, true, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION
             == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    transport_peak_ratio = renodx::color::correct::GammaSafe(
        peak_ratio, true, 2.4f);
  }

  if (mapped_peak > 1.f && endpoint_peak > 1.f && peak_ratio > 1.f) {
    const float highlight_gain = max(
        1.f,
        renodx::math::DivideSafe(
            transport_peak_ratio - 1.f,
            endpoint_peak - 1.f,
            1.f));
    const float stretched_peak = min(
        1.f + (mapped_peak - 1.f) * highlight_gain,
        transport_peak_ratio);
    mapped_bt709 *= renodx::math::DivideSafe(
        stretched_peak,
        mapped_peak,
        1.f);
  }
  return mapped_bt709;
}

// Ghost's complete native grade is returned from the LUT in a square-root
// transfer domain. Decode it to linear before using it as PsychoV input.
float3 GhostDecodeLUTOutput(float3 encoded_bt709) {
  return max(encoded_bt709, 0.f.xxx) * max(encoded_bt709, 0.f.xxx);
}

float3 GhostRenderIntermediate(float3 color_bt709) {
  // PsychoV returns its target-gamut result represented as linear BT.709.
  // Convert it to BT.2020 before PQ transport so valid wide-gamut
  // colors do not require negative channels in the RGB10A2 intermediate.
  const float3 color_bt2020 =
      renodx::color::bt2020::from::BT709(color_bt709);
  return renodx::draw::RenderIntermediatePass(max(color_bt2020, 0.f.xxx));
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

#endif  // SRC_GAMES_GHOSTOFTSUSHIMA_COMMON_HLSLI_
