// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_WATER_INTERFACE_SAMPLING
#define WITCHER_GRAPHICS_WATER_INTERFACE_SAMPLING
#include "sun_sampling.hlsli"

struct GraphicsWaterInterfaceEvent {
  float3 direction;
  float radiance_weight; // Physical delta coefficient divided by branch probability.
  float probability;     // Include in the material path's competing MIS density.
  bool transmitted;
  bool valid;
};

// Actual ray travel direction, with the geometric normal pointing into air.
// Reflection and transmission are sampled together; transmitting every ray
// and dropping the reflected term would lose energy at grazing incidence.
GraphicsWaterInterfaceEvent GraphicsSampleWaterInterface(float3 direction, float3 normal,
    bool from_water, float sample_value) {
  GraphicsWaterInterfaceEvent result=(GraphicsWaterInterfaceEvent)0;
  float direction_length=dot(direction,direction),normal_length=dot(normal,normal);
  if (!isfinite(direction_length) || !isfinite(normal_length) || direction_length<=1.e-12f
      || normal_length<=1.e-12f || !isfinite(sample_value) || sample_value<0.f || sample_value>=1.f) return result;
  direction=normalize(direction);normal=normalize(normal);
  float side=from_water?1.f:-1.f;
  if (side*dot(direction,normal)<=0.f) return result;
  GraphicsWaterSunMapping mapping=GraphicsMapWaterSun(side*direction,normal,from_water);
  const float ior=1.333f;
  float transmission=mapping.valid?saturate(mapping.radiance/(ior*ior)):0.f;
  result.transmitted=sample_value<transmission;
  result.direction=result.transmitted ? (from_water?mapping.air:-mapping.water) : reflect(direction,normal);
  result.probability=result.transmitted ? transmission : 1.f-transmission;
  result.radiance_weight=result.transmitted ? (from_water?ior*ior:1.f/(ior*ior)) : 1.f;
  result.valid=true;
  return result;
}
#endif
