// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "payload.hlsli"

// Continue an already traced native ray after an admitted interface event.
// Call after native SER has produced the packed hit, before unpacking it. A
// nearer water-leg hit wins unchanged; the straight extension beyond the exit
// is discarded. Interface sampling, Fresnel/MIS and absorption remain owned by
// the caller, which supplies the selected outgoing direction (air or reflected).
export void GraphicsContinueWaterGeometry(float3 entry, float3 outgoing,
    float water_distance, float maximum, inout GbufferPayload payload,
    out float4 origin_active, out float4 direction_remaining) {
  origin_active=0.f;
  direction_remaining=0.f;
  float previous_distance=asfloat(payload.data.w);
  if (!isfinite(previous_distance) || any(!isfinite(entry)) || any(!isfinite(outgoing))
      || !isfinite(water_distance) || !isfinite(maximum) || water_distance<=0.f
      || maximum<=water_distance+.001f || dot(outgoing,outgoing)<=1.e-12f
      || (previous_distance>=0.f && previous_distance<=water_distance)) return;
  RayDesc ray;
  ray.Direction=normalize(outgoing);
  ray.Origin=entry+ray.Direction*.001f;
  ray.TMin=.0001f;
  ray.TMax=maximum-water_distance-.001f;
  // A previous hit/miss can overwrite every packed field. The native material
  // trace starts with this neutral payload, unlike shadow-only tracing.
  payload.data=uint4(0u,0u,3881787u,0u);
  payload.flags=0u;
  TraceRay(SceneBVH,528u,255u,0u,4u,0u,ray,payload);
  origin_active=float4(ray.Origin,1.f);
  direction_remaining=float4(ray.Direction,ray.TMax);
}
