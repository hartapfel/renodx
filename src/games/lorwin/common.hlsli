#ifndef SRC_GAMES_LORWIN_COMMON_HLSLI_
#define SRC_GAMES_LORWIN_COMMON_HLSLI_

#include "./shared.h"

#if ((__SHADER_TARGET_MAJOR == 5 && __SHADER_TARGET_MINOR >= 1) || __SHADER_TARGET_MAJOR >= 6)
Texture2D<float2> g_RenoDXMotionVectors : register(t0, space50);
Texture2D<float4> g_RenoDXDlaaOutput : register(t1, space50);
Texture2D<float> g_RenoDXBiasCurrentColorMask : register(t2, space50);

#define LORWIN_DEFINE_SCENE_SAMPLER()                                                      \
  float3 SampleLORWINScene(float2 uv) {                                                    \
    return lorwin::ApplyRCAS(uv, g_SceneTexture, g_SamplerLinearClamp);                    \
  }                                                                                        \
  float3 ApplyLORWINChromaticAberration(float3 center_color, float2 uv) {                  \
    return lorwin::ApplyChromaticAberration(                                               \
        center_color,                                                                      \
        uv,                                                                                \
        g_SceneTexture,                                                                    \
        g_DepthTexture,                                                                    \
        g_OutOfFocusTexture,                                                               \
        g_SamplerLinearClamp,                                                              \
        g_DepthOfFieldVals,                                                                \
        g_DOFBlurVals,                                                                     \
        g_MotionBlurXform,                                                                 \
        g_InvProj,                                                                         \
        g_MiscParams,                                                                      \
        g_ViewPort);                                                                       \
  }
#endif

namespace lorwin {

static const float TONE_MAP_TYPE_VANILLA = 0.f;
static const float TONE_MAP_TYPE_NEUTWO = 1.f;

#if ((__SHADER_TARGET_MAJOR == 5 && __SHADER_TARGET_MINOR >= 1) || __SHADER_TARGET_MAJOR >= 6)
float3 SampleSceneSource(
    float2 uv,
    Texture2D<float4> scene_texture,
    SamplerState scene_sampler) {
  if (CUSTOM_DLAA_ENABLED != 0.f) {
    return g_RenoDXDlaaOutput.Sample(scene_sampler, uv).rgb;
  }
  return scene_texture.Sample(scene_sampler, uv).rgb;
}

float2 ClampSceneUV(float2 uv, float2 texel_size) {
  return clamp(uv, texel_size * 0.5f, 1.f - texel_size * 0.5f);
}

float3 ApplyRCAS(
    float2 uv,
    Texture2D<float4> scene_texture,
    SamplerState scene_sampler) {
  const float3 center_color = SampleSceneSource(uv, scene_texture, scene_sampler);
  if (CUSTOM_RCAS_SHARPENING <= 0.f) return center_color;

  uint width;
  uint height;
  scene_texture.GetDimensions(width, height);
  if (width == 0u || height == 0u) return center_color;

  const float2 texel_size = rcp(float2(width, height));
  const float2 clamped_uv = ClampSceneUV(uv, texel_size);
  const float3 north = SampleSceneSource(
      ClampSceneUV(clamped_uv + float2(0.f, -1.f) * texel_size, texel_size),
      scene_texture,
      scene_sampler);
  const float3 west = SampleSceneSource(
      ClampSceneUV(clamped_uv + float2(-1.f, 0.f) * texel_size, texel_size),
      scene_texture,
      scene_sampler);
  const float3 east = SampleSceneSource(
      ClampSceneUV(clamped_uv + float2(1.f, 0.f) * texel_size, texel_size),
      scene_texture,
      scene_sampler);
  const float3 south = SampleSceneSource(
      ClampSceneUV(clamped_uv + float2(0.f, 1.f) * texel_size, texel_size),
      scene_texture,
      scene_sampler);

  const float north_luma = max(renodx::color::y::from::BT709(north), 0.f);
  const float west_luma = max(renodx::color::y::from::BT709(west), 0.f);
  const float center_luma = max(renodx::color::y::from::BT709(center_color), 0.f);
  const float east_luma = max(renodx::color::y::from::BT709(east), 0.f);
  const float south_luma = max(renodx::color::y::from::BT709(south), 0.f);
  if (center_luma <= 1e-6f) return center_color;

  const float min_ring_luma = min(min(north_luma, west_luma), min(east_luma, south_luma));
  const float max_ring_luma = max(max(north_luma, west_luma), max(east_luma, south_luma));
  const float limited_max_luma = min(max(max_ring_luma, 1e-6f), 0.99f);
  const float limited_min_luma = max(min_ring_luma, 1e-6f);
  const float hit_min = limited_min_luma * rcp(4.f * limited_max_luma);
  float hit_max_denominator = 4.f * limited_min_luma - 4.f;
  if (abs(hit_max_denominator) < 1e-6f) {
    hit_max_denominator = hit_max_denominator < 0.f ? -1e-6f : 1e-6f;
  }
  const float hit_max = (1.f - limited_max_luma) * rcp(hit_max_denominator);
  const float local_lobe = max(-hit_min, hit_max);
  float lobe = max(-0.1875f, min(local_lobe, 0.f)) * CUSTOM_RCAS_SHARPENING;

  const float neighborhood_average = 0.25f * (north_luma + west_luma + east_luma + south_luma);
  const float max_luma = max(max(max(north_luma, west_luma), max(center_luma, east_luma)), south_luma);
  const float min_luma = min(min(min(north_luma, west_luma), min(center_luma, east_luma)), south_luma);
  const float noise = saturate(
      abs(neighborhood_average - center_luma) * rcp(max(max_luma - min_luma, 1e-6f)));
  lobe *= 1.f - 0.5f * noise;

  const float sharpened_luma = (
      (north_luma + west_luma + east_luma + south_luma) * lobe + center_luma)
      * rcp(4.f * lobe + 1.f);
  const float luma_ratio = clamp(sharpened_luma / center_luma, 0.f, 4.f);
  return center_color * luma_ratio;
}

float3 SamplePostBlurScene(
    float2 screen_uv,
    Texture2D<float4> scene_texture,
    Texture2D<float4> depth_texture,
    Texture2D<float4> out_of_focus_texture,
    SamplerState linear_clamp_sampler,
    float4 depth_of_field_values,
    float4 dof_blur_values,
    float4x4 motion_blur_transform,
    float4x4 inverse_projection,
    float4 misc_values,
    float4 viewport) {
  const float2 scene_uv = screen_uv * dof_blur_values.w;
  const float depth = depth_texture.Sample(linear_clamp_sampler, scene_uv).r;
  float3 scene = ApplyRCAS(scene_uv, scene_texture, linear_clamp_sampler);

  float4 view_position = mul(
      inverse_projection,
      float4(screen_uv.x, screen_uv.y, depth, 1.f));
  view_position /= view_position.w;
  const float view_depth = saturate(
      (view_position.y - misc_values.x) / misc_values.y);

#if defined(MOTION_BLUR)
  if (view_depth > 0.005f) {
    float4 previous_position = mul(
        motion_blur_transform,
        float4(scene_uv.x, scene_uv.y, depth, 1.f));
    previous_position.xyz /= previous_position.w;

    const float2 velocity = scene_uv - previous_position.xy;
    if (length(velocity) > 0.01f) {
      const int sample_count = 4;
      [unroll]
      for (int i = 1; i < sample_count; ++i) {
        const float2 offset = clamp(
            scene_uv + velocity * i * misc_values.w,
            viewport.xy * dof_blur_values.w,
            viewport.zw * dof_blur_values.w);
        scene += ApplyRCAS(offset, scene_texture, linear_clamp_sampler);
      }
      scene /= sample_count;
    }
  }
#endif

#if defined(DEPTH_OF_FIELD)
  float dof_interpolant = abs(view_depth - depth_of_field_values.x);
  dof_interpolant = saturate(
      (dof_interpolant / depth_of_field_values.y) - depth_of_field_values.z);
  dof_interpolant *= dof_blur_values.x;
  scene = lerp(
      scene,
      out_of_focus_texture.Sample(linear_clamp_sampler, screen_uv).rgb,
      saturate(dof_interpolant + dof_blur_values.y));
#endif

  return scene;
}

float3 ApplyChromaticAberration(
    float3 center_color,
    float2 screen_uv,
    Texture2D<float4> scene_texture,
    Texture2D<float4> depth_texture,
    Texture2D<float4> out_of_focus_texture,
    SamplerState linear_clamp_sampler,
    float4 depth_of_field_values,
    float4 dof_blur_values,
    float4x4 motion_blur_transform,
    float4x4 inverse_projection,
    float4 misc_values,
    float4 viewport) {
  if (CUSTOM_CHROMATIC_ABERRATION == 0.f
      || CUSTOM_CHROMATIC_ABERRATION_STRENGTH <= 0.f) {
    return center_color;
  }

  uint width;
  uint height;
  scene_texture.GetDimensions(width, height);
  if (width == 0u || height == 0u) return center_color;

  const float2 dimensions = float2(width, height);
  const float2 texel_size = rcp(dimensions);
  const float2 viewport_min = max(viewport.xy, texel_size * 0.5f);
  const float2 viewport_max = min(viewport.zw, 1.f - texel_size * 0.5f);
  const float2 viewport_size = max(viewport_max - viewport_min, texel_size);
  const float2 viewport_center = (viewport_min + viewport_max) * 0.5f;
  const float2 from_center = screen_uv - viewport_center;
  const float2 pixel_from_center = from_center * dimensions;
  const float distance_from_center = length(pixel_from_center);
  if (distance_from_center <= 1e-4f) return center_color;

  const float viewport_radius = max(0.5f * length(viewport_size * dimensions), 1.f);
  const float radial_distance = saturate(distance_from_center / viewport_radius);
  const float2 normalized_from_center = abs(
      from_center / max(viewport_size * 0.5f, texel_size));
  const float screen_edge_distance = saturate(max(
      normalized_from_center.x,
      normalized_from_center.y));
  const float edge_distance = lerp(
      screen_edge_distance,
      radial_distance,
      saturate(CUSTOM_CHROMATIC_ABERRATION_SHAPE));
  const float start_offset = min(
      saturate(CUSTOM_CHROMATIC_ABERRATION_START),
      0.9999f);
  const float edge_interpolant = saturate(
      (edge_distance - start_offset) / max(1.f - start_offset, 1e-4f));
  const float edge_weight = pow(
      smoothstep(0.f, 1.f, edge_interpolant),
      max(CUSTOM_CHROMATIC_ABERRATION_FALLOFF, 0.25f));

  const float2 direction = pixel_from_center / distance_from_center;
  const float desired_offset_pixels =
      CUSTOM_CHROMATIC_ABERRATION_STRENGTH * 9.f * edge_weight;
  const float2 edge_room_pixels = min(
      screen_uv - viewport_min,
      viewport_max - screen_uv) * dimensions;
  const float2 safe_offset_pixels_xy = edge_room_pixels / max(abs(direction), 1e-4f);
  const float safe_offset_pixels = max(
      0.f,
      min(safe_offset_pixels_xy.x, safe_offset_pixels_xy.y) - 1.f);
  const float offset_pixels = min(desired_offset_pixels, safe_offset_pixels);
  const float2 offset = direction * texel_size * offset_pixels;

  const float3 red_sample = SamplePostBlurScene(
      screen_uv + offset,
      scene_texture,
      depth_texture,
      out_of_focus_texture,
      linear_clamp_sampler,
      depth_of_field_values,
      dof_blur_values,
      motion_blur_transform,
      inverse_projection,
      misc_values,
      viewport);
  const float3 blue_sample = SamplePostBlurScene(
      screen_uv - offset,
      scene_texture,
      depth_texture,
      out_of_focus_texture,
      linear_clamp_sampler,
      depth_of_field_values,
      dof_blur_values,
      motion_blur_transform,
      inverse_projection,
      misc_values,
      viewport);

  const float3 aberrated_color = float3(
      red_sample.r,
      center_color.g,
      blue_sample.b);
  const float3 aberration_delta = aberrated_color - center_color;
  const float delta_luminance = renodx::color::y::from::BT709(aberration_delta);
  const float3 saturated_delta = lerp(
      delta_luminance.xxx,
      aberration_delta,
      CUSTOM_CHROMATIC_ABERRATION_SATURATION);
  return center_color + saturated_delta;
}
#endif

float GetSettingOrDefault(float value, float fallback) {
  return value == 0.f ? fallback : value;
}

float3 ApplyUserColorGrading(float3 color, bool apply_saturation = true) {
  renodx::color::grade::Config config = renodx::color::grade::config::Create(
      GetSettingOrDefault(RENODX_TONE_MAP_EXPOSURE, 1.f),
      GetSettingOrDefault(RENODX_TONE_MAP_HIGHLIGHTS, 1.f),
      GetSettingOrDefault(RENODX_TONE_MAP_SHADOWS, 1.f),
      GetSettingOrDefault(RENODX_TONE_MAP_CONTRAST, 1.f),
      0.10f * pow(RENODX_TONE_MAP_FLARE, 10.f),
      apply_saturation ? GetSettingOrDefault(RENODX_TONE_MAP_SATURATION, 1.f) : 1.f,
      0.f,
      RENODX_TONE_MAP_HUE_SHIFT,
      0.f.xxx,
      renodx::color::grade::config::hue_correction_type::INPUT,
      -1.f * (RENODX_TONE_MAP_HIGHLIGHT_SATURATION - 1.f));

  return renodx::color::grade::config::ApplyUserColorGrading(color, config);
}

float GetPeakRatio() {
  return max(
      RENODX_PEAK_WHITE_NITS / max(RENODX_DIFFUSE_WHITE_NITS, 1.f),
      1.f + 1e-3f);
}

float GetNeutwoWhiteClip(float peak) {
  return max(RENODX_TONE_MAP_WHITE_CLIP, peak + 0.001f);
}

float3 ClampBT709ToBT2020(float3 color) {
  return renodx::color::bt709::from::BT2020(
      max(renodx::color::bt2020::from::BT709(color), 0.f.xxx));
}

float3 ApplyBlowout(float3 color, float reference_luminance) {
  if (RENODX_TONE_MAP_BLOWOUT == 0.f) return color;

  float3 perceptual = renodx::color::oklab::from::BT709(color);
  perceptual.yz *= lerp(
      1.f,
      0.f,
      saturate(pow(saturate(reference_luminance), 1.f - RENODX_TONE_MAP_BLOWOUT)));
  return renodx::color::bt709::from::OkLab(perceptual);
}

bool UseVanillaFilmGrain() {
  return RENODX_TONE_MAP_TYPE == TONE_MAP_TYPE_VANILLA || CUSTOM_FILM_GRAIN_TYPE == 0.f;
}

float3 ApplySceneGrading(float3 ungraded_color, float3 graded_color) {
  if (RENODX_TONE_MAP_TYPE == TONE_MAP_TYPE_VANILLA) return graded_color;
  return lerp(ungraded_color, graded_color, RENODX_SCENE_GRADE_STRENGTH);
}

float3 ApplyPerceptualFilmGrain(float3 color, float2 position) {
  if (RENODX_TONE_MAP_TYPE == TONE_MAP_TYPE_VANILLA || CUSTOM_FILM_GRAIN_TYPE == 0.f || CUSTOM_FILM_GRAIN_STRENGTH <= 0.f) return color;

  return renodx::effects::ApplyFilmGrain(
      color,
      position,
      CUSTOM_RANDOM,
      CUSTOM_FILM_GRAIN_STRENGTH * 0.03f);
}

float3 ApplyDLAADebugView(float3 color, float4 position) {
#if ((__SHADER_TARGET_MAJOR == 5 && __SHADER_TARGET_MINOR >= 1) || __SHADER_TARGET_MAJOR >= 6)
  if (CUSTOM_DLAA_DEBUG_VIEW == 0.f) return color;
  if (CUSTOM_DLAA_ENABLED == 0.f) return float3(0.25f, 0.f, 0.25f);

  uint width;
  uint height;
  g_SceneTexture.GetDimensions(width, height);
  const uint2 pixel = min(uint2(position.xy), uint2(width - 1u, height - 1u));
  const float3 input_color = g_SceneTexture.Load(int3(pixel, 0)).rgb;
  const float3 output_color = g_RenoDXDlaaOutput.Load(int3(pixel, 0)).rgb;

  if (CUSTOM_DLAA_DEBUG_VIEW == 1.f) return input_color;
  if (CUSTOM_DLAA_DEBUG_VIEW == 2.f) return output_color;
  if (CUSTOM_DLAA_DEBUG_VIEW == 3.f) {
    if (abs(position.x - width * 0.5f) < 2.f) return 1.f.xxx;
    return position.x < width * 0.5f ? input_color : output_color;
  }
  if (CUSTOM_DLAA_DEBUG_VIEW == 4.f) {
    return saturate(abs(output_color - input_color) * 8.f);
  }
  if (CUSTOM_DLAA_DEBUG_VIEW == 5.f) {
    return saturate(0.5f.xxx + (output_color - input_color) * 8.f);
  }

  const float2 motion_vector = g_RenoDXMotionVectors.Load(int3(pixel, 0));
  if (CUSTOM_DLAA_DEBUG_VIEW == 6.f) {
    return float3(saturate(motion_vector * 32.f + 0.5f), 0.5f);
  }
  if (CUSTOM_DLAA_DEBUG_VIEW == 7.f) {
    return saturate(length(motion_vector) * 64.f).xxx;
  }

  const float depth = g_DepthTexture.Load(int3(pixel, 0)).r;
  if (CUSTOM_DLAA_DEBUG_VIEW == 8.f) return depth.xxx;
  if (CUSTOM_DLAA_DEBUG_VIEW == 9.f) {
    return saturate(max(abs(ddx(depth)), abs(ddy(depth))) * 1024.f).xxx;
  }
  if (CUSTOM_DLAA_DEBUG_VIEW == 10.f) {
    return g_RenoDXBiasCurrentColorMask.Load(int3(pixel, 0)).xxx;
  }

  const bool input_finite = all(isfinite(input_color));
  const bool output_finite = all(isfinite(output_color));
  const bool input_in_range = all(input_color >= 0.f.xxx) && all(input_color <= 1.f.xxx);
  const bool output_in_range = all(output_color >= 0.f.xxx) && all(output_color <= 1.f.xxx);
  if (CUSTOM_DLAA_DEBUG_VIEW == 11.f) {
    return !input_finite ? float3(1.f, 0.f, 1.f)
                         : (!input_in_range ? float3(1.f, 1.f, 0.f) : float3(0.f, 0.25f, 0.f));
  }
  if (CUSTOM_DLAA_DEBUG_VIEW == 12.f) {
    return !output_finite ? float3(1.f, 0.f, 1.f)
                          : (!output_in_range ? float3(1.f, 1.f, 0.f) : float3(0.f, 0.25f, 0.f));
  }

  const bool right = position.x >= width * 0.5f;
  const bool bottom = position.y >= height * 0.5f;
  const uint2 overview_pixel = uint2(
      min(uint(frac(position.x / (width * 0.5f)) * width), width - 1u),
      min(uint(frac(position.y / (height * 0.5f)) * height), height - 1u));
  if (!bottom) {
    return right ? g_RenoDXDlaaOutput.Load(int3(overview_pixel, 0)).rgb
                 : g_SceneTexture.Load(int3(overview_pixel, 0)).rgb;
  }
  if (!right) {
    const float2 overview_motion = g_RenoDXMotionVectors.Load(int3(overview_pixel, 0));
    return float3(saturate(overview_motion * 32.f + 0.5f), 0.5f);
  }
  return g_RenoDXBiasCurrentColorMask.Load(int3(overview_pixel, 0)).xxx;
#else
  return color;
#endif
}

float3 ApplyNeutwo(float3 untonemapped) {
  untonemapped = max(untonemapped, 0.f.xxx);

  float3 graded = ApplyUserColorGrading(untonemapped, true);
  const float peak_ratio = GetPeakRatio();
  const float white_clip = GetNeutwoWhiteClip(peak_ratio);

  float3 tonemapped;
  if (RENODX_TONE_MAP_PER_CHANNEL == 1.f) {
    tonemapped = renodx::tonemap::neutwo::PerChannel(graded, peak_ratio.xxx, white_clip.xxx);
  } else {
    tonemapped = renodx::color::bt709::from::BT2020(
        renodx::tonemap::neutwo::BT2020(
            renodx::color::bt2020::from::BT709(graded),
            peak_ratio,
            white_clip));
  }

  const float y = renodx::color::y::from::BT709(tonemapped) / peak_ratio;
  tonemapped = ApplyBlowout(tonemapped, y);

  return ClampBT709ToBT2020(tonemapped);
}

float3 ApplyToneMap(float3 untonemapped) {
  if (RENODX_TONE_MAP_TYPE == TONE_MAP_TYPE_NEUTWO) {
    return ApplyNeutwo(untonemapped);
  }

  return saturate(untonemapped);
}

float3 ToneMapAndRenderIntermediatePass(float3 color) {
  if (RENODX_GAMMA_CORRECTION == 1.f) {
    color = renodx::color::gamma::DecodeSafe(color, 2.2f);
    color = ApplyToneMap(color);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::gamma::EncodeSafe(color, 2.2f);
  } else if (RENODX_GAMMA_CORRECTION == 2.f) {
    color = renodx::color::gamma::DecodeSafe(color, 2.4f);
    color = ApplyToneMap(color);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::gamma::EncodeSafe(color, 2.4f);
  } else {
    color = renodx::color::srgb::DecodeSafe(color);
    color = ApplyToneMap(color);
    color *= RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS;
    color = renodx::color::srgb::EncodeSafe(color);
  }

  return color;
}

}  // namespace lorwin

#endif  // SRC_GAMES_LORWIN_COMMON_HLSLI_
