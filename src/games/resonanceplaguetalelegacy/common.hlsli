#ifndef SRC_GAMES_RESONANCEPLAGUETALELEGACY_COMMON_HLSLI_
#define SRC_GAMES_RESONANCEPLAGUETALELEGACY_COMMON_HLSLI_

#include "./shared.h"
#include "./test30.hlsl"

bool ResonanceIsPsychoV() {
  return RENODX_TONE_MAP_TYPE != 0.f;
}

bool ResonanceUseRenoDXChromaticAberration() {
  return ResonanceIsPsychoV() && CUSTOM_CHROMATIC_ABERRATION_TYPE == 1.f;
}

float3 ResonanceApplyChromaticAberrationEncoded(
    float3 center_color,
    float2 tex_coord,
    Texture2D<float4> scene_texture,
    SamplerState scene_sampler,
    float lod) {
  if (!ResonanceUseRenoDXChromaticAberration()
      || CUSTOM_CHROMATIC_ABERRATION_STRENGTH <= 0.f) {
    return center_color;
  }

  uint width, height;
  scene_texture.GetDimensions(width, height);
  if (width == 0 || height == 0) return center_color;

  const float2 dimensions = float2(width, height);
  const float2 texel_size = rcp(dimensions);
  const float2 pixel_from_center = (tex_coord - 0.5f) * dimensions;
  const float distance_from_center = length(pixel_from_center);
  if (distance_from_center <= 1e-4f) return center_color;

  const float edge_distance = saturate(
      distance_from_center / (0.5f * length(dimensions)));
  float edge_weight = smoothstep(0.15f, 1.f, edge_distance);
  edge_weight *= edge_weight;

  const float2 screen_edge_distance = abs(tex_coord * 2.f - 1.f);
  const float axial_edge_weight = smoothstep(
      0.55f,
      1.f,
      max(screen_edge_distance.x, screen_edge_distance.y)) * 0.35f;
  edge_weight = max(edge_weight, axial_edge_weight);

  const float2 direction = pixel_from_center / distance_from_center;
  const float desired_offset_pixels =
      CUSTOM_CHROMATIC_ABERRATION_STRENGTH * 9.f * edge_weight;
  const float2 edge_room_pixels = min(tex_coord, 1.f - tex_coord) * dimensions;
  const float2 safe_offset_pixels_xy =
      edge_room_pixels / max(abs(direction), 1e-4f);
  const float safe_offset_pixels = max(
      0.f,
      min(safe_offset_pixels_xy.x, safe_offset_pixels_xy.y) - 1.f);
  const float2 offset = direction * texel_size
      * min(desired_offset_pixels, safe_offset_pixels);

  float3 color = center_color;
  color.r = scene_texture.SampleLevel(scene_sampler, tex_coord + offset, lod).r;
  color.b = scene_texture.SampleLevel(scene_sampler, tex_coord - offset, lod).b;
  return max(color, 0.f.xxx);
}

float3 ResonanceSelectChromaticAberrationInput(
    float3 native_color,
    float3 center_color,
    float2 tex_coord,
    Texture2D<float4> scene_texture,
    SamplerState scene_sampler,
    float lod) {
  if (!ResonanceUseRenoDXChromaticAberration()) return native_color;
  return ResonanceApplyChromaticAberrationEncoded(
      center_color,
      tex_coord,
      scene_texture,
      scene_sampler,
      lod);
}

bool ResonanceUsePerceptualFilmGrain() {
  return ResonanceIsPsychoV() && CUSTOM_FILM_GRAIN_TYPE == 1.f;
}

float3 ResonanceApplyPerceptualFilmGrain(float3 color, float2 pixel_position) {
  if (!ResonanceUsePerceptualFilmGrain()) return color;

  const float3 grain_hash = renodx::random::Hash33(
      float3(pixel_position, CUSTOM_RANDOM * 8192.f));
  return renodx::effects::ApplyFilmGrain(
      color,
      grain_hash.xy,
      grain_hash.z,
      CUSTOM_FILM_GRAIN_STRENGTH * 0.03f,
      1.f);
}

float3 ResonanceSelectFilmGrainOutput(
    float3 native_grained,
    float3 perceptual_grained) {
  return ResonanceUsePerceptualFilmGrain()
      ? perceptual_grained
      : native_grained;
}

float3 ResonanceRenderIntermediatePassDithered(
    float3 color,
    float2 pixel_position) {
  float3 encoded = renodx::draw::RenderIntermediatePass(color);

  // The native postprocess shaders stochastically round their encoded output
  // at the precision of an R11G11B10-style intermediate. PsychoV replaces that
  // final assignment, so restore equivalent unbiased rounding here instead of
  // exposing the generated LUT's luminance slices as visible color bands.
  const float3 magnitude = abs(encoded);
  const float3 quantization_step = renodx::math::Select(
      magnitude > 0.f.xxx,
      exp2(floor(log2(max(magnitude, 1e-20f.xxx)))
           + float3(-6.f, -6.f, -5.f)),
      0.f.xxx);
  const float3 noise = renodx::random::Hash33(
      float3(pixel_position, CUSTOM_RANDOM * 8192.f)) - 0.5f.xxx;
  return max(encoded + noise * quantization_step, 0.f.xxx);
}

float3 ResonanceApplyPostProcessLUT(
    float3 lut_input_linear,
    float3 lut_output_linear,
    float3 lut_output_scale) {
  // PsychoV and the scaled artistic LUT are baked by the LUT builder. Keep a
  // shared post-process hook without repeating either operation per pixel.
  return lut_output_linear;
}

// Capture the post-LUT color before the game's native HDR curve. The caller
// preserves the complete vanilla path below this point, then replaces only the
// final RGB assignment with RenderIntermediatePass when PsychoV is selected.
// This is the generalized form of the author's four original postprocess
// branches and keeps every variant's native math intact.
float3 ResonanceApplyPostProcessToneMap(
    float3 post_lut_bt709,
    float3 native_tonemapped_bt709,
    bool clamp_vanilla) {
  if (!ResonanceIsPsychoV()) {
    return clamp_vanilla
        ? saturate(native_tonemapped_bt709)
        : native_tonemapped_bt709;
  }

  post_lut_bt709 = renodx::math::ZeroNaN(post_lut_bt709);
  post_lut_bt709 = renodx::math::Select(
      isinf(post_lut_bt709),
      0.f.xxx,
      post_lut_bt709);
  return max(post_lut_bt709, 0.f.xxx);
}

// The author's custom path uses RenderIntermediatePass, whose intermediate is
// scaled from diffuse white to graphics white. The output shader consequently
// decodes custom content using graphics white rather than the game's paper
// white constant.
float ResonanceGetGameNits(float native_game_nits) {
  return ResonanceIsPsychoV()
      ? max(RENODX_GRAPHICS_WHITE_NITS, 1.f)
      : native_game_nits;
}

float3 ResonanceApplyPsychoVInputExtensions(float3 color_bt709) {
  color_bt709 = renodx::math::ZeroNaN(color_bt709);
  color_bt709 = renodx::math::Select(isinf(color_bt709), 0.f.xxx, color_bt709);

  if (RENODX_TONE_MAP_GAMMA == 1.f && RENODX_TONE_MAP_FLARE == 0.f) {
    return color_bt709;
  }

  const float luminance = max(
      renodx::color::y::from::BT709(color_bt709),
      0.f);
  float adjusted_luminance = luminance;
  if (RENODX_TONE_MAP_GAMMA != 1.f) {
    adjusted_luminance = pow(adjusted_luminance, RENODX_TONE_MAP_GAMMA);
  }
  if (RENODX_TONE_MAP_FLARE != 0.f) {
    // Match APTLegacy/APTRequiem's veiling-glare compensation. Flare changes
    // the luminance slope around mid-gray instead of adding a pedestal, so a
    // zero input remains zero and the control cannot raise the black floor.
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
        flare_exponent) * mid_gray;
  }

  return renodx::color::correct::Luminance(
      color_bt709,
      luminance,
      max(adjusted_luminance, 0.f));
}

float3 ResonanceApplyPsychoVOutputExtensions(
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
    const float peak_ratio = max(
        RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f),
        1.f);
    const float percent_peak = saturate(mapped_luminance / peak_ratio);

    if (RENODX_TONE_MAP_BLOWOUT != 0.f) {
      perceptual.yz *= lerp(
          1.f,
          0.f,
          saturate(pow(percent_peak, 1.f - RENODX_TONE_MAP_BLOWOUT)));
    }

    if (RENODX_TONE_MAP_HIGHLIGHT_SATURATION != 1.f) {
      const float strength = abs(RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f);
      // Match APTLegacy/APTRequiem's fixed HDR weighting instead of tying the
      // control to the selected peak, which affected most diffuse colors.
      const float source_luminance = max(
          renodx::color::y::from::BT709(source_bt709),
          0.f);
      const float percent_highlight = saturate(
          source_luminance * 100.f / 10000.f);
      float scale = pow(1.f - percent_highlight, 100.f * strength);
      if (RENODX_TONE_MAP_HIGHLIGHT_SATURATION > 1.f) {
        scale = 2.f - scale;
      }
      perceptual.yz *= scale;
    }

    mapped_bt709 = renodx::color::bt709::from::OkLab(perceptual);
  }

  const float3 adaptive_state_lms =
      renodx::color::lms::from::BT709(0.18f.xxx);
  const float compression_scale =
      renodx::color::gamut::ComputeGamutCompressionScaleBT709AdaptiveD65(
          mapped_bt709,
          adaptive_state_lms,
          1.f);
  mapped_bt709 = renodx::color::gamut::GamutCompressBT709AdaptiveD65(
      mapped_bt709,
      adaptive_state_lms,
      compression_scale);
  return max(mapped_bt709, 0.f.xxx);
}

static const float RESONANCE_COMMON_LUT_LOG_SCALE = 0.07434873282909393f;

float3 ResonanceDecodeLUTLog(float3 encoded, float linear_scale) {
  return (exp2(encoded / RESONANCE_COMMON_LUT_LOG_SCALE) - 1.f.xxx)
      / max(linear_scale, 1e-6f);
}

float3 ResonanceEncodeLUTLog(float3 linear_color, float linear_scale) {
  return log2(max(linear_color, 0.f.xxx) * max(linear_scale, 1e-6f) + 1.f.xxx)
      * RESONANCE_COMMON_LUT_LOG_SCALE;
}

float3 ResonanceApplyLUTBuilderPsychoV(
    float3 lut_coordinates,
    float3 native_lut_output,
    float linear_scale,
    float3 post_lut_scale) {
  if (!ResonanceIsPsychoV()) return native_lut_output;

  // Match APTLegacy's proven ordering: decode the native LUT input and output
  // into one scene-linear domain, retain the LUT's RGB grade, and scale only
  // its luminance delta before PsychoV. At 0% the LUT keeps its hue/tint while
  // contributing no contrast curve; at 100% the complete native LUT is used.
  const float3 scene_linear = max(
      ResonanceDecodeLUTLog(lut_coordinates, linear_scale) * post_lut_scale,
      0.f.xxx);
  const float3 native_graded = max(
      ResonanceDecodeLUTLog(native_lut_output, linear_scale) * post_lut_scale,
      0.f.xxx);
  const float scene_luminance =
      renodx::color::y::from::BT709(scene_linear);
  const float native_luminance =
      renodx::color::y::from::BT709(native_graded);
  const float target_luminance = lerp(
      scene_luminance,
      native_luminance,
      saturate(RENODX_LUT_LUMINANCE_CURVE_STRENGTH));
  float3 psychov_input = native_luminance > 1e-6f
      ? native_graded * (target_luminance / native_luminance)
      : scene_linear;

  psychov_input = ResonanceApplyPsychoVInputExtensions(psychov_input);
  float3 mapped_bt709 = renodx::tonemap::psychov::psychotm_test30(
      psychov_input,
      RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f),
      RENODX_TONE_MAP_EXPOSURE,
      RENODX_TONE_MAP_HIGHLIGHTS,
      RENODX_TONE_MAP_SHADOWS,
      RENODX_TONE_MAP_CONTRAST,
      RENODX_TONE_MAP_SATURATION,
      1.f,
      100.f,
      RENODX_PSYCHOV_HUE_SHIFT,
      1.f,
      0,
      1.f,
      0.18f.xxx,
      0.18f.xxx,
      1.f,
      0);
  mapped_bt709 = ResonanceApplyPsychoVOutputExtensions(
      psychov_input,
      mapped_bt709);

  mapped_bt709 = renodx::math::DivideSafe(
      mapped_bt709,
      max(post_lut_scale, 1e-6f.xxx),
      0.f.xxx);
  return ResonanceEncodeLUTLog(mapped_bt709, linear_scale);
}

float3 ResonanceDecodeHDRTransformerInput(
    float3 encoded_color,
    float game_nits) {
  return renodx::color::srgb::DecodeSafe(encoded_color) * game_nits;
}

float ResonanceGetHDRTransformerLuminance(float3 color) {
  return renodx::color::y::from::BT2020(color);
}

// Lilium HDR RCAS: the final intermediate is signed linear BT.709 so native
// BT.709 HUD and scene pixels share one unambiguous space.
// Convert the filter neighborhood to BT.2020 for luminance sharpening, then
// return to signed BT.709 for the game's final gamut conversion.
float3 ResonanceApplyLiliumHDRRCAS(
    float3 center_bt709_nits,
    float2 tex_coord,
    Texture2D<float4> scene_texture,
    SamplerState scene_sampler,
    float game_nits) {
  if (!ResonanceIsPsychoV()
      || CUSTOM_SHARPENING_TYPE != 1.f
      || CUSTOM_SHARPNESS == 0.f) {
    return center_bt709_nits;
  }

  uint width, height;
  scene_texture.GetDimensions(width, height);
  const float2 texel_size = rcp(float2(width, height));

  const float3 center_bt2020_nits =
      renodx::color::bt2020::from::BT709(center_bt709_nits);
  const float3 b = renodx::color::bt2020::from::BT709(
      ResonanceDecodeHDRTransformerInput(
          scene_texture.SampleLevel(scene_sampler, tex_coord + float2(0.f, -1.f) * texel_size, 0.f).rgb,
          game_nits));
  const float3 d = renodx::color::bt2020::from::BT709(
      ResonanceDecodeHDRTransformerInput(
          scene_texture.SampleLevel(scene_sampler, tex_coord + float2(-1.f, 0.f) * texel_size, 0.f).rgb,
          game_nits));
  const float3 f = renodx::color::bt2020::from::BT709(
      ResonanceDecodeHDRTransformerInput(
          scene_texture.SampleLevel(scene_sampler, tex_coord + float2(1.f, 0.f) * texel_size, 0.f).rgb,
          game_nits));
  const float3 h = renodx::color::bt2020::from::BT709(
      ResonanceDecodeHDRTransformerInput(
          scene_texture.SampleLevel(scene_sampler, tex_coord + float2(0.f, 1.f) * texel_size, 0.f).rgb,
          game_nits));

  static const float sharpening_normalization_point = 125.f;
  const float rcp_normalization = rcp(sharpening_normalization_point);
  const float b_luma = ResonanceGetHDRTransformerLuminance(max(b, 0.f.xxx)) * rcp_normalization;
  const float d_luma = ResonanceGetHDRTransformerLuminance(max(d, 0.f.xxx)) * rcp_normalization;
  const float e_luma = ResonanceGetHDRTransformerLuminance(max(center_bt2020_nits, 0.f.xxx)) * rcp_normalization;
  const float f_luma = ResonanceGetHDRTransformerLuminance(max(f, 0.f.xxx)) * rcp_normalization;
  const float h_luma = ResonanceGetHDRTransformerLuminance(max(h, 0.f.xxx)) * rcp_normalization;

  const float min_ring_luma = min(min(b_luma, d_luma), min(f_luma, h_luma));
  const float max_ring_luma = max(max(b_luma, d_luma), max(f_luma, h_luma));
  const float limited_max_luma = min(max_ring_luma, 0.99f);
  const float epsilon = 1e-6f;
  if (e_luma <= epsilon) return center_bt709_nits;

  const float hit_min = min_ring_luma * rcp(max(4.f * limited_max_luma, epsilon));
  float hit_max_denominator = 4.f * min_ring_luma - 4.f;
  hit_max_denominator = abs(hit_max_denominator) < epsilon
      ? (hit_max_denominator < 0.f ? -epsilon : epsilon)
      : hit_max_denominator;
  const float hit_max = (1.f - limited_max_luma) * rcp(hit_max_denominator);

  static const float rcas_limit = 0.1875f;
  float lobe = max(-rcas_limit, min(max(-hit_min, hit_max), 0.f))
      * CUSTOM_SHARPNESS;

  float noise = 0.25f * (b_luma + d_luma + f_luma + h_luma) - e_luma;
  const float max_luma = max(max(max(b_luma, d_luma), max(e_luma, f_luma)), h_luma);
  const float min_luma = min(min(min(b_luma, d_luma), min(e_luma, f_luma)), h_luma);
  noise = saturate(abs(noise) * rcp(max(max_luma - min_luma, epsilon)));
  lobe *= -0.5f * noise + 1.f;

  const float sharpened_luma =
      ((b_luma + d_luma + h_luma + f_luma) * lobe + e_luma)
      * rcp(4.f * lobe + 1.f);
  const float luma_ratio = clamp(
      renodx::math::DivideSafe(sharpened_luma, e_luma, 1.f),
      0.25f,
      4.f);
  float3 sharpened_color_nits = center_bt2020_nits * luma_ratio;

  const float sharpened_peak = max(
      max(max(sharpened_color_nits.x, sharpened_color_nits.y), sharpened_color_nits.z),
      0.f);
  sharpened_color_nits *= min(
      1.f,
      max(RENODX_PEAK_WHITE_NITS, 1.f) / max(sharpened_peak, 1e-6f));
  return renodx::color::bt709::from::BT2020(sharpened_color_nits);
}

#endif  // SRC_GAMES_RESONANCEPLAGUETALELEGACY_COMMON_HLSLI_
