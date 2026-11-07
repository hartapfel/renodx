// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../water/sun_connection.hlsli"
#include "../water/caustics_sample.hlsli"
#include "sun_visibility.lib_6_6.hlsli"

// Apply after native interface traversal has selected its final sun energy.
// Both light- and material-sampled paths use the central sun direction, never
// the randomized disc sample, for captured-field freshness and wave focusing.
export float GraphicsPathSunFocus(float x,float y,float z,float sx,float sy,float sz) {
  if(!GraphicsPathWaterReceiverAdmitted(float3(x,y,z)))return 1.f;
  return GraphicsWaterFocus(graphics_path_water_field,float3(x,y,z),float3(sx,sy,sz),
      asfloat(graphics_path_water_field.Load(108u)),true);
}

// POD outputs make the native-IR adapter independent of internal helper struct
// layout. Native fallback preserves the supplied direction and unit multipliers.
// NEE's original air-sampled radiance/PDF ratio receives energy.rgb; its light
// PDF receives direction_pdf.w. The BRDF uses direction_pdf.xyz.
export void GraphicsPathSunSample(float x,float y,float z,float ax,float ay,float az,
    out float4 direction_pdf,out float4 entry_distance,out float4 energy) {
  direction_pdf=float4(ax,ay,az,1.f);
  entry_distance=float4(x,y,z,0.f);
  energy=float4(1.f,1.f,1.f,0.f);
  if(!GraphicsPathWaterReceiverAdmitted(float3(x,y,z))) return;
  // Inside the supported body, rejected/TIR/unconverged connections contribute
  // zero. Unit PDF avoids a divide by zero for rejected NEE samples. alpha=1
  // still marks ownership, so native sunlight must not be added as a fallback.
  energy=float4(0.f,0.f,0.f,1.f);
  GraphicsWaterSunConnection connection=GraphicsSampleWaterSun(graphics_path_water_field,
      graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,float3(x,y,z),float3(ax,ay,az));
  if(!connection.valid) return;
  direction_pdf=float4(connection.mapping.water,1.f/connection.mapping.solid_angle);
#ifdef W3_PT_WATER_GEOMETRY
  // The material strategy selects transmission with probability (1-F).
  // Native MIS consumes only the squared PDF ratio, so dividing the competing
  // light PDF by that probability is equivalent to multiplying the BSDF PDF.
  // Keep the physical NEE energy below unchanged: NEE does not sample this coin.
  const float ior=1.333f;
  float transmission=saturate(connection.mapping.radiance/(ior*ior));
  if(transmission<=0.f)return;
  direction_pdf.w/=transmission;
#endif
  entry_distance=float4(connection.surface.position,connection.surface.distance);
  energy=float4(connection.surface.transmission*connection.mapping.sample_weight,1.f);
}

// A material ray's throughput already owns its water-leg absorption. Query
// returns interface radiance only. PDF=0 is valid when this physical connection
// belongs to a branch that the deterministic NEE sampler cannot select.
export void GraphicsPathSunQuery(float x,float y,float z,float wx,float wy,float wz,
    out float4 direction_pdf,out float4 entry_distance,out float4 energy) {
  direction_pdf=float4(wx,wy,wz,1.f);
  entry_distance=float4(x,y,z,0.f);
  energy=float4(1.f,1.f,1.f,0.f);
  if(!GraphicsPathWaterReceiverAdmitted(float3(x,y,z))) return;
  direction_pdf.w=0.f;
  energy=float4(0.f,0.f,0.f,1.f);
  GraphicsWaterSunConnection connection=GraphicsEvaluateWaterSun(graphics_path_water_field,
      graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,float3(x,y,z),float3(wx,wy,wz));
  if(!connection.valid) return;
  direction_pdf=float4(connection.mapping.air,GraphicsWaterSunNeePdfScale(graphics_path_water_field,
      graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,float3(x,y,z),connection));
  entry_distance=float4(connection.surface.position,connection.surface.distance);
  energy=float4(connection.mapping.radiance.xxx,1.f);
}

// Shadow-only wind/direction overrides are independently connected through the
// surface. Reuse native flags and payload for the fallback and both bent legs.
export void GraphicsPathSunShadow(float x,float y,float z,float ax,float ay,float az,
    float maximum,uint flags,inout GbufferPayload payload) {
  if(GraphicsPathWaterReceiverAdmitted(float3(x,y,z))) {
    GraphicsWaterSunConnection connection=GraphicsSampleWaterSun(graphics_path_water_field,
        graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,float3(x,y,z),float3(ax,ay,az));
    if(connection.valid) {
      GraphicsTraceWaterSunLegs(float3(x,y,z),connection.mapping.water,connection.surface.position,
          connection.mapping.air,connection.surface.distance,maximum,flags,payload);
      return;
    }
    // Native visibility accepts only a negative distance as a miss. A failed
    // supported connection is blocked, including total internal reflection.
    payload.data.w=asuint(0.f);
    return;
  }
  RayDesc ray;
  ray.Origin=float3(x,y,z);ray.Direction=float3(ax,ay,az);ray.TMin=0.f;ray.TMax=maximum;
  TraceRay(SceneBVH,flags,255u,0u,4u,0u,ray,payload);
}
