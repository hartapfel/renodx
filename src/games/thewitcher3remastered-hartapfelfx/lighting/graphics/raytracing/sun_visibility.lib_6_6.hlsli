// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_WATER_AIR_VISIBILITY
#define WITCHER_GRAPHICS_WATER_AIR_VISIBILITY
#include "payload.hlsli"

// Caller supplies a field-admitted interface connection and matching sampling
// weights. Keep the native hit-group multiplier, miss index and caller flags so
// alpha-tested geometry still executes the game's any-hit shaders on both legs.
export void GraphicsTraceWaterSunLegs(float3 origin, float3 water_direction,
    float3 entry, float3 air_direction, float water_distance, float maximum,
    uint flags, inout GbufferPayload payload) {
  GbufferPayload initial = payload;
  RayDesc ray;
  ray.Origin = origin;
  ray.Direction = water_direction;
  ray.TMin = 0.f;
  // The next ray begins just outside the interface. Do not intersect the water
  // mesh itself at the common endpoint, or let an air hit shadow the water leg.
  ray.TMax = max(0.f, water_distance - .001f);
  if (ray.TMax > 0.f) {
    TraceRay(SceneBVH, flags, 255u, 0u, 4u, 0u, ray, payload);
    // Native visibility is strictly distance < 0. NaN is not a miss either.
    if (!(asfloat(payload.data.w) < 0.f)) return;
  }
  payload = initial;
  ray.Origin = entry + air_direction * .001f;
  ray.Direction = air_direction;
  ray.TMax = maximum;
  TraceRay(SceneBVH, flags, 255u, 0u, 4u, 0u, ray, payload);
}
#endif
