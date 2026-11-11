// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#define FOG_LOCAL_PASS
#define FOG_RASTER_LIGHTS
#include "../fog/grid.hlsli"
#include "../fog/local_lights.hlsli"
// Retained as a reference test of the retired screen-space approximation.
#include "../fog/local_occlusion.hlsli"
[numthreads(1, 1, 1)] void main() {
  volume.Store4(0, asuint(float4(
      LocalScreenVisibility(float3(0, 0, 2), float3(0, 0, 8), 8u, .5f),
      LocalScreenVisibility(float3(0, 0, 2), float3(0, 0, 4), 8u, .5f),
      LocalScreenVisibility(float3(0, 0, 6), float3(0, 0, 8), 8u, .5f),
      LocalScreenVisibility(float3(0, 0, 2), float3(8, 0, 8), 8u, .5f))));
  volume.Store4(16, asuint(float4(
      LocalScreenVisibility(float3(0, 0, 2), float3(0, 0, -4), 16u, .5f),
      LocalScreenVisibility(float3(0, 0, -1), float3(0, 0, 8), 16u, .5f),
      LocalScreenVisibility(float3(0, 0, 2), float3(0, 0, 8), 0u, .5f),
      LocalScreenVisibility(float3(0, 0, 2), float3(80, 0, 8), 24u, .5f))));
  volume.Store4(32, asuint(float4(
      LocalScreenVisibility(float3(0, 0, 2), float3(0, 0, 8), 16u, .25f),
      LocalScreenVisibility(float3(0, 0, 2), float3(0, 0, 8), 24u, .75f),
      LocalScreenVisibility(float3(0, 0, 2), float3(0, 0, 8), 8u, 0.f),
      LocalScreenVisibility(float3(0, 0, 2), float3(0, 0, 8), 8u, 1.f))));
  FogLocalLight light = (FogLocalLight)0;
  light.data[0].w = 100.f;
  light.data[5] = float4(0.f, 1.f, 0.f, .1f);
  light.data[6] = float4(1.f, 0.f, 0.f, 0.f);
  float cube = LocalVisibility(light, float3(0, 0, 10), 10.f, false).x;
  light.data[6] = 0.f;
  light.data[5].z = 1.f;
  light.data[7] = asfloat(0x00100000u).xxxx;
  light.data[8].xy = asfloat(0x00100000u).xx;
  float atlas = LocalVisibility(light, float3(0, 0, 10), 10.f, false).x;
  volume.Store4(48, asuint(float4(cube, atlas, 0.f, 0.f)));
  volume.Store4(64, asuint(float4(
      LocalOpaqueDistance(float2(.5f, .5f), float3(0, 0, 1)),
      LocalOpaqueDistance(float2(.5f, .5f), normalize(float3(1, 0, 1))),
      LocalOpaqueDistance(float2(.5f, .5f), float3(0, 0, -1)),
      LocalOpaqueDistance(float2(-.1f, .5f), float3(0, 0, 1)))));
}
