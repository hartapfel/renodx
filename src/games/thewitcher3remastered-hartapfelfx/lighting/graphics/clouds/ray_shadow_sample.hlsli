// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_RAY_CLOUD_SHADOW_SAMPLE
#define WITCHER_RAY_CLOUD_SHADOW_SAMPLE
#include "ray_shadow_layout.h"
#include "shadow_sample.hlsli"

float GraphicsRayCloudShadow(ByteAddressBuffer field, float3 camera, float renderer,
    float3 sun, float3 world, float native_visibility) {
  uint4 header = field.Load4(0u);
  if (any(header.xyz != uint3(W3_RAY_CLOUD_MAGIC, 1u, 1u))
      || header.w < 64u || header.w > W3_RAY_CLOUD_MAX_SOURCE || (header.w & 15u) != 0u
      || any(!isfinite(camera)) || any(!isfinite(sun)) || !isfinite(renderer)) return native_visibility;
  float3 previous_camera = asfloat(field.Load3(16u));
  if (any(!isfinite(previous_camera)) || distance(camera, previous_camera) > 5.f
      || field.Load(32u) != asuint(renderer)) return native_visibility;
  float4 previous_sun = asfloat(field.Load4(W3_RAY_CLOUD_HEADER + 16u));
  float4 layer = asfloat(field.Load4(W3_RAY_CLOUD_HEADER + 48u));
  if (any(!isfinite(previous_sun)) || previous_sun.w != 1.f || dot(sun, sun) < 1.e-8f
      || dot(normalize(sun), previous_sun.xyz) < .9999f || layer.w != float(header.w)) return native_visibility;
  return GraphicsCloudShadow(field, world, native_visibility, W3_RAY_CLOUD_HEADER);
}
#endif
