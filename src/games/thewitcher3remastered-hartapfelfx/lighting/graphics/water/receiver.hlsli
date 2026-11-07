// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_REMASTERED_WATER_RECEIVER
#define WITCHER_REMASTERED_WATER_RECEIVER
#include "illumination.hlsli"
#ifndef WITCHER_GRAPHICS_CUSTOM_LIGHTING
#include "receiver_field.hlsli"
#include "caustics_sample.hlsli"
ByteAddressBuffer graphics_water_receivers : register(t0, space58);

GraphicsWaterReceiver GraphicsWaterLighting(float3 camera, float3 world, float3 sun, float renderer) {
  float depth = 0.f;
  float3 extinction = 0.f;
  float weight = 0.f;
  [branch] if (graphics_injection.layout_version == 1.f && graphics_injection.graphics_mode != 0.f && graphics_injection.water_refraction != 0.f)
    weight = GraphicsWaterFieldWeight(graphics_water_receivers, camera, world, renderer, depth, extinction);
  float focus = weight > 0.f ? GraphicsWaterFocus(graphics_water_receivers,world,sun,graphics_injection.water_caustics) : 1.f;
  return GraphicsWaterReceiverLight(sun, depth, extinction, weight, focus);
}
#else
// The lighting-only build has no water field or optics passes.
GraphicsWaterReceiver GraphicsWaterLighting(float3 camera, float3 world, float3 sun, float renderer) {
  GraphicsWaterReceiver result = {sun, float3(1.f, 1.f, 1.f), float3(1.f, 1.f, 1.f)};
  return result;
}
#endif
#endif
