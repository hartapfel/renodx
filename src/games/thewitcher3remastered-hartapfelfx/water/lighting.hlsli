// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "light_layout.h"
#include "optics.hlsli"

ByteAddressBuffer water_light : register(t0, space71);

bool WaterLightMatches(float4 camera, float4 projection, uint4 jitter, float4 inverse_projection) {
  return water_light.Load(0) == WATER_LIGHT_VALID && all(water_light.Load4(16) == asuint(camera))
         && all(water_light.Load4(32) == asuint(projection)) && all(water_light.Load4(48) == jitter)
         && all(water_light.Load4(96) == asuint(inverse_projection));
}

float WaterVisibility(float3 world, float3 grid_origin) {
  const int3 size = int3(WATER_LIGHT_GRID, WATER_LIGHT_GRID, WATER_LIGHT_SLICES);
  const float3 coord = (world - grid_origin) / WATER_LIGHT_CELL + .5f * size - .5f;
  const float3 edge = min(coord, size - 1 - coord);
  const float coverage = smoothstep(0.f, 2.f, min(edge.x, min(edge.y, edge.z)));
  if (coverage <= 0.f) return 0.f;
  const int3 cell = int3(floor(coord));
  const float3 f = frac(coord);
  const uint row = WATER_LIGHT_GRID * 4u;
  const uint slice = WATER_LIGHT_GRID * row;
  const uint offset = WATER_LIGHT_HEADER + uint(cell.z) * slice + uint(cell.y) * row + uint(cell.x) * 4u;
  const float2 a = lerp(asfloat(water_light.Load2(offset)), asfloat(water_light.Load2(offset + row)), f.y);
  const float2 b = lerp(asfloat(water_light.Load2(offset + slice)), asfloat(water_light.Load2(offset + slice + row)), f.y);
  return coverage * saturate(dot(lerp(a, b, f.z), float2(1.f - f.x, f.x)));
}

float WaterForwardPhase(float cosine) {
  const float g = .35f;
  const float denominator = 1.f + g * g - 2.f * g * clamp(cosine, -1.f, 1.f);
  return (.07957747f * (1.f - g * g)) / (denominator * sqrt(denominator));
}

// In the fullscreen pass, the native mask establishes that the camera is wet.
// Use a local lower bound for water depth when the authored elevation is unavailable.
static const float WaterLocalDepth = .75f;

float3 IntegrateWaterSun(float3 camera, float3 ray, float distance,
                         float3 sun_in_water, float density, float3 tint, float3 grid_origin) {
  const float integration_end = min(distance, 48.f);
  float previous = 0.f;
  float3 transmittance = 1.f;
  float3 integral = 0.f;
  [unroll] for (uint i = 1; i <= 5; ++i) {
    const float fraction = .2f * i;
    const float end = integration_end * fraction * fraction;
    const float3 next = WaterTransmittance(end, density, tint);
    const float3 offset = ray * (.5f * (previous + end));
    const float light_distance = max(0.f, WaterLocalDepth - offset.z) / max(sun_in_water.z, .1f);
    integral += (transmittance - next) * WaterVisibility(camera + offset, grid_origin)
              * WaterTransmittance(light_distance, density, tint);
    transmittance = next;
    previous = end;
  }
  return integral * WaterForwardPhase(dot(ray, sun_in_water));
}
