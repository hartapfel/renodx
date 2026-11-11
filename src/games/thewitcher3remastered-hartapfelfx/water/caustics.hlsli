// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFELFX_WATER_CAUSTICS
#define HARTAPFELFX_WATER_CAUSTICS
#include "optics.hlsli"

static const float2 WaterWaveA = float2(.936f, .352f);
static const float2 WaterWaveB = float2(-.41f, .912f);
static const float2 WaterWaveC = float2(.66f, -.751f);
static const float3 WaterWaveNumber = float3(6.1f, 7.4f, 10.3f);
static const float3 WaterWaveCurvature = float3(1.5f, 1.35f, .75f);

float3 WaterWavePhase(float2 world, float time) {
  // Deep-water gravity dispersion, omega = sqrt(g * k).
  return float3(dot(world, WaterWaveA), dot(world, WaterWaveB), dot(world, WaterWaveC)) * WaterWaveNumber
         - time * float3(7.735f, 8.520f, 10.052f);
}

float2 ResolvedWaterSlope(float2 world, float time, float footprint) {
  const float3 response = 1.f - smoothstep(.8f, 2.8f, footprint * WaterWaveNumber);
  const float3 slope = (WaterWaveCurvature / WaterWaveNumber) * sin(WaterWavePhase(world, time)) * response;
  // Short capillary-gravity ripples add optical detail where the pixel
  // footprint resolves them. Their dispersion includes surface tension.
  const float2 k = float2(37.f, 65.f);
  const float2 ripple = .026f * (1.f - smoothstep(.8f, 2.8f, footprint * k))
                       * sin(float2(dot(world, WaterWaveB), dot(world, WaterWaveC)) * k - time * float2(19.149f, 25.646f));
  return slope.x * WaterWaveA + (slope.y + ripple.x) * WaterWaveB + (slope.z + ripple.y) * WaterWaveC;
}

float2 WaterLightSlope(float3 sun, float ior) {
  const float3 refracted = refract(-sun, float3(0.f, 0.f, 1.f), rcp(ior));
  return refracted.xy / max(-refracted.z, .1f);
}

float CausticFocus(float2 dx, float2 dy) {
  const float determinant = (1.f - dx.x) * (1.f - dy.y) - dx.y * dy.x;
  return saturate((rcp(max(abs(determinant), .28f)) - 1.f) * .45f);
}

// A small-slope Snell projection is X = u - d(1 - 1/n) grad(h).
// The Hessian of these travelling gravity waves estimates the area change
// directly. This gives a projected light pattern even when the water mesh
// or dynamic normals are outside the view.
float ProjectedCaustic(float2 entry, float time, float gain) {
  const float3 curvature = WaterWaveCurvature * cos(WaterWavePhase(entry, time));
  const float2 dx = gain * (curvature.x * WaterWaveA.x * WaterWaveA + curvature.y * WaterWaveB.x * WaterWaveB + curvature.z * WaterWaveC.x * WaterWaveC);
  const float2 dy = gain * (curvature.x * WaterWaveA.y * WaterWaveA + curvature.y * WaterWaveB.y * WaterWaveB + curvature.z * WaterWaveC.y * WaterWaveC);
  return CausticFocus(dx, dy);
}

float3 WaterCaustics(float2 receiver, float depth, float camera_distance, float3 sun, float time) {
  if (depth <= .035f || depth >= 18.f || camera_distance >= 55.f || sun.z <= .02f) return 0.f;
  const float2 green = receiver - depth * WaterLightSlope(sun, WaterIor);
  const float2 red = receiver - depth * WaterLightSlope(sun, 1.331f);
  const float2 blue = receiver - depth * WaterLightSlope(sun, 1.337f);
  const float gain = clamp(depth, .55f, 1.9f) * (1.f - rcp(WaterIor));
  const float3 pattern = float3(ProjectedCaustic(red, time, gain), ProjectedCaustic(green, time, gain),
                                ProjectedCaustic(blue, time, gain));
  return pattern * smoothstep(.035f, .28f, depth) * (1.f - smoothstep(8.f, 18.f, depth))
         * (1.f - smoothstep(26.f, 55.f, camera_distance)) * smoothstep(.02f, .16f, sun.z);
}
#endif
