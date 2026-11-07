// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "frame.hlsli"
#include "../water/path_transport.hlsli"
#include "../water/surface_connection.hlsli"
ByteAddressBuffer graphics_path_water_field : register(t0, space58);

bool GraphicsPathWaterEnabled() {
  return graphics_ray_controls.x==1.f && graphics_ray_controls.y!=0.f && graphics_ray_controls.z!=0.f
      && (any(graphics_path_cloud_frame[0]!=0.f) || any(graphics_path_cloud_frame[74]!=0.f));
}

// Direction-independent admission shared by direct-light and material paths.
bool GraphicsPathWaterReceiverAdmitted(float3 receiver) {
  if (!GraphicsPathWaterEnabled()) return false;
  return GraphicsFindWaterSurfaceExit(graphics_path_water_field,graphics_path_cloud_frame[0].xyz,
      graphics_path_cloud_frame[74].x,receiver,float3(0,0,1)).valid;
}

// Only secondary sampled segments. The primary underwater pass already owns
// camera-to-first-hit attenuation. A cache query receives this incoming edge;
// cached radiance owns the outgoing edges accumulated by its update shader.
export float3 GraphicsPathWaterTransmission(float x, float y, float z,
    float dx, float dy, float dz, float distance) {
  if (!GraphicsPathWaterEnabled()) return 1.f;
  if (!isfinite(distance) || distance <= 0.f) return 1.f;
  float3 start = float3(x, y, z);
  return GraphicsWaterPathTransmission(graphics_path_water_field, graphics_path_cloud_frame[0].xyz,
      graphics_path_cloud_frame[74].x, start, start + float3(dx, dy, dz) * distance).xyz;
}
