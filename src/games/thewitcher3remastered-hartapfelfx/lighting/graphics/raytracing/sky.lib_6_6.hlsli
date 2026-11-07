// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../water/environment_connection.hlsli"
#include "sun_visibility.lib_6_6.hlsli"

// Preserve the sampled material-space direction in the BRDF and cosine PDF.
// Only the sky lookup uses direction_pdf.xyz. Its w scales the PDF in MIS,
// never the native energy denominator: account for the material strategy's
// Fresnel branch probability while NEE deterministically selects transmission.
export void GraphicsPathSkySample(float x,float y,float z,float dx,float dy,float dz,
    out float4 direction_pdf,out float4 entry_distance,out float4 energy) {
  direction_pdf=float4(dx,dy,dz,1.f);entry_distance=float4(x,y,z,0.f);energy=float4(1,1,1,0);
  if(!GraphicsPathWaterEnabled())return;
  GraphicsWaterEnvironmentConnection connection=GraphicsConnectWaterEnvironment(graphics_path_water_field,
      graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,float3(x,y,z),float3(dx,dy,dz));
  if(!connection.owned)return;
  energy=float4(0,0,0,1);
  if(!connection.valid)return;
  const float ior=1.333f;
  float probability=saturate(connection.mapping.radiance/(ior*ior));
  if(probability<=0.f)return;
  direction_pdf=float4(connection.mapping.air,1.f/probability);
  entry_distance=float4(connection.surface.position,connection.surface.distance);
  energy=float4(connection.surface.transmission*connection.mapping.radiance,1.f);
}

export void GraphicsPathSkyShadow(float x,float y,float z,float dx,float dy,float dz,
    float maximum,uint flags,inout GbufferPayload payload) {
  if(GraphicsPathWaterEnabled()) {
    GraphicsWaterEnvironmentConnection connection=GraphicsConnectWaterEnvironment(graphics_path_water_field,
        graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,float3(x,y,z),float3(dx,dy,dz));
    if(connection.owned) {
      if(connection.valid)GraphicsTraceWaterSunLegs(float3(x,y,z),connection.mapping.water,connection.surface.position,
          connection.mapping.air,connection.surface.distance,maximum,flags,payload);
      else payload.data.w=asuint(0.f);
      return;
    }
  }
  RayDesc ray;
  ray.Origin=float3(x,y,z);ray.Direction=float3(dx,dy,dz);ray.TMin=0.f;ray.TMax=maximum;
  TraceRay(SceneBVH,flags,255u,0u,4u,0u,ray,payload);
}
