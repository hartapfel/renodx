// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../lighting/graphics/raytracing/payload.hlsli"
float FogTraceLocalVisibility(float3 world, float3 emitter, uint light_flags, float emitter_exclusion) {
  float3 delta = emitter - world;
  float distance = length(delta);
  if (distance <= .0011f) return 1.f;
  RayDesc ray;
  ray.Origin = world;
  ray.Direction = delta / distance;
  ray.TMin = .0001f;
  // Exact native LocalShadowsRGS finite endpoint rule: exclude the authored
  // near-emitter region, but preserve a nonempty segment for nearby receivers.
  // Tracing into a torch's housing creates an artificial directional cutoff.
  emitter_exclusion = max(emitter_exclusion, 0.f);
  ray.TMax = distance - min(emitter_exclusion, max(distance - emitter_exclusion, 0.f)) - .001f;
  GbufferPayload payload;
  payload.data = uint4(1u << 24, 0u, 0u, 0u);
  payload.flags = 0u;
  // Exact native LocalShadowsRGS ABI: preserve alpha tests, material caster
  // flags and hit-group indexing. Inline opaque queries bypass those rules.
  TraceRay(SceneBVH, (light_flags & 0x80000000u) != 0u ? 526u : 542u, 255u, 0u, 4u, 0u, ray, payload);
  return asfloat(payload.data.w) < 0.f ? 1.f : 0.f;
}
