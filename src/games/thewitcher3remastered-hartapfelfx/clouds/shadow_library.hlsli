// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "shadow_inputs.hlsli"
#ifndef HFCLOUD_RAY_LIBRARY
cbuffer HartapfelNativeCloudFrame : register(b12) { float4 cloud_native_frame[341]; }
#include "../night/lighting/night_skylight.hlsli"
export float HFNightSkylight() {
  return WitcherNightSkylight(cloud_native_frame[185].w);
}
#endif
bool HFCloudFrameMatches() {
#ifndef HFCLOUD_RAY_LIBRARY
  return CloudShadowMatches(cloud_native_frame[0].xyz, asuint(cloud_native_frame[286]));
#else
  return true;
#endif
}
export float HFCloudShadow(float x, float y, float z, float native_visibility) {
  if (!HFCloudFrameMatches()) return native_visibility;
  return HartapfelCloudShadow(float3(x, y, z), native_visibility);
}
// Neutralize only the game's painted-cloud factor. The rest of the native
// lighting chain still carries geometry and material shadow visibility.
export float HFCloudNeutralize(float x, float y, float z, float native_visibility) {
  if (!HFCloudFrameMatches()) return native_visibility;
  return HartapfelCloudNeutralize(native_visibility);
}
// After native branch merging, apply the procedural cloud only once to the
// combined native visibility, which still contains barn/tree/terrain shadows.
export float HFCloudShadowMultiply(float x, float y, float z, float native_visibility) {
  if (!HFCloudFrameMatches()) return native_visibility;
  return HartapfelCloudShadowMultiply(float3(x, y, z), native_visibility);
}

#ifdef HFCLOUD_PATH_MATERIALS
#include "../lighting/graphics/raytracing/material.lib_6_6.hlsli"
#endif
