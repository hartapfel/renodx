// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_WATER_SUN_SAMPLING
#define WITCHER_GRAPHICS_WATER_SUN_SAMPLING
#include "../reference/classic/water/transport.hlsli"

struct GraphicsWaterSunMapping {
  float3 air;
  float3 water;
  float solid_angle;  // d omega_water / d omega_air; PDF_water = PDF_air / this.
  float radiance;     // L_water / L_air, before absorption along the water leg.
  float sample_weight; // radiance * solid_angle; multiply an air-sampled estimate.
  bool valid;
};

// Directions point from the receiver toward the source. The surface normal
// points into air. Both NEE and a material-sampled sun hit must use this same
// map and solid-angle measure for MIS. A reflected/TIR direction has no air
// source connection. Geometry/body admission and visibility belong to callers.
// Radiance / n^2 is invariant across lossless refraction; see PBRT 4e,
// Reflection Models / Dielectric BSDF, equations 9.11 onward.
GraphicsWaterSunMapping GraphicsMapWaterSun(float3 direction, float3 normal, bool from_water) {
  GraphicsWaterSunMapping result = (GraphicsWaterSunMapping)0;
  if (any(!isfinite(direction)) || any(!isfinite(normal))
      || dot(direction, direction) <= 1.e-12f || dot(normal, normal) <= 1.e-12f) return result;
  direction = normalize(direction);
  normal = normalize(normal);
  float cosine = dot(direction, normal);
  if (cosine <= 0.f) return result;
  float3 tangent = direction - normal * cosine;
  const float ior = 1.333f;
  float eta = from_water ? ior : 1.f / ior;
  float sine_squared = eta * eta * dot(tangent, tangent);
  if (sine_squared >= 1.f) return result;
  float other_cosine = sqrt(max(0.f, 1.f - sine_squared));
  float3 other = eta * tangent + normal * other_cosine;
  result.air = from_water ? other : direction;
  result.water = from_water ? direction : other;
  float air_cosine = from_water ? other_cosine : cosine;
  float water_cosine = from_water ? cosine : other_cosine;
  result.solid_angle = air_cosine / (ior * ior * water_cosine);
  result.radiance = (1.f - WaterInterfaceFresnel(air_cosine, 1.f / ior)) * (ior * ior);
  result.sample_weight = result.radiance * result.solid_angle;
  result.valid = result.solid_angle > 0.f && isfinite(result.solid_angle) && isfinite(result.radiance);
  return result;
}
#endif
