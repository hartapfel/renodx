// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFELFX_LIGHTING_INPUTS
#define HARTAPFELFX_LIGHTING_INPUTS
#define WITCHER_GRAPHICS_CUSTOM_LIGHTING
#include "graphics/shared.h"
#include "../night/lighting/night_skylight.hlsli"
#include "../clouds/shadow_inputs.hlsli"

cbuffer HartapfelLighting : register(b0, space73) {
  float pbr_enabled;
  float contact_enabled;
  float soft_enabled;
  float light_diameter;
}
ShaderInjectData HartapfelLightingSettings() {
  ShaderInjectData settings = (ShaderInjectData)0;
  settings.layout_version = 1.f;
  settings.graphics_mode = 1.f;
  settings.pbr_mode = pbr_enabled;
  settings.contact_shadows = contact_enabled;
  settings.soft_shadows = soft_enabled;
  settings.sun_diameter = light_diameter;
  return settings;
}
float HartapfelSurfaceCloudShadow(float3 world, float native_visibility, float3 camera, uint4 jitter) {
  return CloudShadowMatches(camera, jitter) ? HartapfelCloudShadow(world, native_visibility) : native_visibility;
}
#define graphics_injection (HartapfelLightingSettings())
#define GRAPHICS_CLOUD_VISIBILITY(world, native) HartapfelSurfaceCloudShadow(world, native, cb12_raw[0].xyz, asuint(cb12_raw[286]))
#define GRAPHICS_SKYLIGHT WitcherNightSkylight(cb12_raw[185].w)
#endif
