// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "local_visibility.lib_6_6.hlsli"

// A finite straight segment identifies whether this strategy must connect an
// interface. Same-medium lamps keep their native direction and receive extinction;
// unknown fields retain that conservative straight-segment fallback.
bool GraphicsPathLocalInterfaceOwned(float3 receiver,float3 direction,float maximum,bool from_water) {
  GraphicsWaterSurfaceCrossing crossing=GraphicsFindWaterSurfaceCrossing(graphics_path_water_field,
      graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,receiver,direction,from_water,maximum);
  return crossing.valid && crossing.distance<maximum;
}

export void GraphicsPathLocalSample(float x,float y,float z,float lx,float ly,float lz,
    out float4 receiver_direction,out float4 emitter_direction,out float4 energy) {
  receiver_direction=0.f;emitter_direction=0.f;energy=float4(1,1,1,0);
  if(!GraphicsPathWaterEnabled())return;
  float3 receiver=float3(x,y,z),emitter=float3(lx,ly,lz),delta=emitter-receiver;
  float distance=length(delta);
  if(!isfinite(distance) || distance<=1.e-4f)return;
  float3 direction=delta/distance;
  bool from_water=GraphicsPathWaterReceiverAdmitted(receiver);
  if(!GraphicsPathLocalInterfaceOwned(receiver,direction,distance,from_water)) {
    // The refracted connection supplies its own extinction. Integrate the
    // straight segment only when it is the path whose energy will be used.
    energy.xyz=GraphicsPathWaterTransmission(x,y,z,direction.x,direction.y,direction.z,distance);
    return;
  }
  energy.xyz=0.f;
  GraphicsWaterLocalConnection connection;
  if(from_water)connection=GraphicsConnectWaterLocal(graphics_path_water_field,
      graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,receiver,emitter);
  else connection=GraphicsConnectWaterLocalEntry(graphics_path_water_field,
      graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,receiver,emitter);
  if(!connection.valid)return;
  receiver_direction=float4(connection.receiver_direction,1);
  emitter_direction=float4(connection.emitter_direction,1);
  energy=float4(connection.weight,1);
}

export void GraphicsPathLocalShadow(float x,float y,float z,float dx,float dy,float dz,
    float distance,float maximum,uint flags,inout GbufferPayload payload) {
  float3 origin=float3(x,y,z),direction=float3(dx,dy,dz);
  if(GraphicsPathWaterEnabled()) {
    bool from_water=GraphicsPathWaterReceiverAdmitted(origin);
    if(GraphicsPathLocalInterfaceOwned(origin,direction,distance,from_water)) {
      GraphicsWaterLocalConnection connection;
      if(from_water)connection=GraphicsConnectWaterLocal(graphics_path_water_field,
          graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,origin,origin+direction*distance);
      else connection=GraphicsConnectWaterLocalEntry(graphics_path_water_field,
          graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,origin,origin+direction*distance);
      GraphicsTraceWaterLocalLegs(origin,connection,maximum,flags,payload);
      return;
    }
  }
  RayDesc ray;ray.Origin=origin;ray.Direction=direction;ray.TMin=0.f;ray.TMax=maximum;
  TraceRay(SceneBVH,flags,255u,0u,4u,0u,ray,payload);
}
