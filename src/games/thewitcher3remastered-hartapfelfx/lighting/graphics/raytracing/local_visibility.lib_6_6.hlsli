// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_WATER_LOCAL_VISIBILITY
#define WITCHER_GRAPHICS_WATER_LOCAL_VISIBILITY
#include "payload.hlsli"
#include "../water/local_connection.hlsli"

// Native TMax is a finite visibility budget, including the game's shadow-radius
// and per-light caps. Spend it across both segments and never trace beyond the
// emitter. SUN visibility deliberately has a different, unbounded air leg.
void GraphicsTraceWaterLocalLegs(float3 origin,GraphicsWaterLocalConnection connection,
    float maximum,uint flags,inout GbufferPayload payload) {
  if(!connection.valid || !isfinite(maximum) || maximum<0.f) {
    payload.data.w=asuint(0.f);return;
  }
  GbufferPayload initial=payload;
  RayDesc ray;
  ray.Origin=origin;ray.Direction=connection.receiver_direction;ray.TMin=0.f;
  ray.TMax=min(maximum,max(0.f,connection.receiver_distance-.001f));
  if(ray.TMax>0.f) {
    TraceRay(SceneBVH,flags,255u,0u,4u,0u,ray,payload);
    if(!(asfloat(payload.data.w)<0.f))return;
  }
  float remaining=min(maximum-connection.receiver_distance,connection.emitter_distance)-.001f;
  if(remaining<=0.f) {payload=initial;payload.data.w=asuint(-1.f);return;}
  payload=initial;
  ray.Origin=connection.exit.surface.position+connection.emitter_direction*.001f;
  ray.Direction=connection.emitter_direction;ray.TMax=remaining;
  TraceRay(SceneBVH,flags,255u,0u,4u,0u,ray,payload);
}
#endif
