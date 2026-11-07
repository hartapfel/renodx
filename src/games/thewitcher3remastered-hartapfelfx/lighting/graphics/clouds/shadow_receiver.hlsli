// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef REMASTERED_CLOUD_SHADOW_RECEIVER
#define REMASTERED_CLOUD_SHADOW_RECEIVER
#include "../shared.h"
#include "shadow_sample.hlsli"
ByteAddressBuffer graphics_cloud_shadow : register(t0, space55);
// Replace only native cloud attenuation. Terrain, cascade, traced visibility
// and contact terms remain in each native directional-mask producer.
float GraphicsSurfaceCloudShadow(float3 world,float native_visibility) {
  if(graphics_injection.layout_version!=1.f ||graphics_injection.graphics_mode==0.f)return native_visibility;
  return GraphicsCloudShadow(graphics_cloud_shadow,world,native_visibility);
}
#endif
