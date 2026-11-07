// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_RAY_CLOUD_SHADOW_RECEIVER
#define WITCHER_RAY_CLOUD_SHADOW_RECEIVER
#include "../shared.h"
#include "ray_shadow_sample.hlsli"
ByteAddressBuffer graphics_ray_cloud_shadow : register(t0, space55);
float GraphicsHitCloudShadow(float3 camera, float renderer, float3 sun, float3 world, float native_visibility) {
  if (graphics_injection.layout_version != 1.f || graphics_injection.graphics_mode == 0.f) return native_visibility;
  return GraphicsRayCloudShadow(graphics_ray_cloud_shadow, camera, renderer, sun, world, native_visibility);
}
#endif
