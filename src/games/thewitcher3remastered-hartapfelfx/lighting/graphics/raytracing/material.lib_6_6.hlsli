// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Shared ray-material control contract.
#include "../lighting/brdf.hlsli"
cbuffer GraphicsRayControls : register(b0, space56) {
  float4 graphics_ray_controls;
}
#ifdef W3_PT_CLOUD_SHADOWS
#include "clouds.lib_6_6.hlsli"
#endif
#ifdef W3_PT_WATER_PATHS
#include "water.lib_6_6.hlsli"
#endif
#ifdef W3_PT_WATER_SUN
#ifndef W3_PT_WATER_PATHS
#error Water sunlight requires the shared water-field and frame contract.
#endif
#include "sun.lib_6_6.hlsli"
#endif
#ifdef W3_PT_WATER_GEOMETRY
#ifndef W3_PT_WATER_PATHS
#error Water geometry requires the shared water-field and frame contract.
#endif
#include "path_interface.lib_6_6.hlsli"
#endif
#ifdef W3_PT_WATER_SKY
#ifndef W3_PT_WATER_GEOMETRY
#error Water sky sampling requires matched interface traversal and MIS.
#endif
#include "sky.lib_6_6.hlsli"
#endif
#ifdef W3_PT_WATER_LOCAL
#ifndef W3_PT_WATER_PATHS
#error Water local lights require the shared water-field and frame contract.
#endif
#include "local.lib_6_6.hlsli"
#endif
export float GraphicsWaterF0() {
  if (graphics_ray_controls.x != 1.f || graphics_ray_controls.y == 0.f
      || graphics_ray_controls.z == 0.f) return .03f;
  const float ratio = (1.333f - 1.f) / (1.333f + 1.f);
  return ratio * ratio;
}

// Applied to the ordinary diffuse lobe in both path throughput and NEE.
// Native sampling PDFs, MIS weights, Fresnel and transmission stay separate.
// The fourth control follows PBR Lighting, independently of the water model.
export float GraphicsRayDiffuseResponse(float no_v, float no_l, float lo_h, float roughness) {
  if (graphics_ray_controls.x != 1.f || graphics_ray_controls.y == 0.f
      || graphics_ray_controls.w == 0.f) return 1.f;
  return GraphicsDirectDiffuse(no_v, no_l, lo_h, roughness);
}

export float GraphicsRayRoughness(float native_value) {
  if (graphics_ray_controls.x != 1.f || graphics_ray_controls.y == 0.f
      || graphics_ray_controls.w == 0.f) return native_value;
  return max(native_value, .045f);
}

// Computing 1-NoH^2 loses the narrow lobe in float precision. Cross products
// retain its tangential component, including approximate native normalization.
export float GraphicsRayHalfSinSquared(float nx, float ny, float nz, float hx, float hy, float hz) {
  float3 normal = float3(nx, ny, nz), half_direction = float3(hx, hy, hz);
  float3 tangent = cross(normal, half_direction);
  return saturate(dot(tangent, tangent) / max(dot(normal, normal) * dot(half_direction, half_direction), 1.e-20f));
}

// The cap sampler and its evaluated PDF use the same distribution and floor.
// Preserve the native cap normalization; scale is 1 for D and .5 for D/2.
export float GraphicsRayDistribution(float native_value, float sin_squared, float roughness, float scale) {
  if (graphics_ray_controls.x != 1.f || graphics_ray_controls.y == 0.f
      || graphics_ray_controls.w == 0.f) return native_value;
  sin_squared = saturate(sin_squared);
  float alpha = max(roughness * roughness, .002025f);
  float a2 = alpha * alpha;
  float denominator = sin_squared + (1.f - sin_squared) * a2;
  return scale * a2 / max(3.141592653589793f * denominator * denominator, 1.e-20f);
}

// Native Fresnel stays outside the shared D * correlated Smith visibility.
// Keeping the original RGB value as an argument preserves Native arithmetic.
export float GraphicsRaySpecular(float native_value, float fresnel, float distribution,
    float no_v, float no_l, float roughness) {
  if (graphics_ray_controls.x != 1.f || graphics_ray_controls.y == 0.f
      || graphics_ray_controls.w == 0.f) return native_value;
  no_v = saturate(abs(no_v)); no_l = saturate(no_l);
  float alpha = max(roughness * roughness, .002025f);
  float a2 = alpha * alpha;
  float visibility = no_l * sqrt(a2 + (1.f - a2) * no_v * no_v)
      + no_v * sqrt(a2 + (1.f - a2) * no_l * no_l);
  return fresnel * distribution * .5f / max(visibility, 1.e-20f);
}
