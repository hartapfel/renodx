// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../clouds/ray_shadow_sample.hlsli"
#include "frame.hlsli"
ByteAddressBuffer graphics_path_cloud_shadow : register(t0, space55);
export float GraphicsPathCloudShadow(float native_visibility, float x, float y, float z,
    float sun_x, float sun_y, float sun_z) {
  if (graphics_ray_controls.x != 1.f || graphics_ray_controls.y == 0.f) return native_visibility;
  // Null CBVs read as zero. Conservatively decline an entirely empty camera
  // and renderer marker, including a zero-origin frame with no other context.
  if (all(graphics_path_cloud_frame[0] == 0.f) && all(graphics_path_cloud_frame[74] == 0.f)) return native_visibility;
  return GraphicsRayCloudShadow(graphics_path_cloud_shadow, graphics_path_cloud_frame[0].xyz,
      graphics_path_cloud_frame[74].x, float3(sun_x, sun_y, sun_z), float3(x, y, z), native_visibility);
}
