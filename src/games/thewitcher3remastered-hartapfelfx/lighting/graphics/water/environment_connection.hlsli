// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_WATER_ENVIRONMENT_CONNECTION
#define WITCHER_GRAPHICS_WATER_ENVIRONMENT_CONNECTION
#include "surface_connection.hlsli"
#include "sun_sampling.hlsli"

struct GraphicsWaterEnvironmentConnection {
  GraphicsWaterSurfaceCrossing surface;
  GraphicsWaterSunMapping mapping;
  bool owned;
  bool valid;
};

// Native sky NEE samples a cosine direction at the material, not in air at the
// emitter. It therefore needs no angular Jacobian or inverse branch selection.
// This strategy represents a clear air ray or one transmitted water exit.
// Other interface paths belong to the material strategy with zero sky-NEE PDF.
GraphicsWaterEnvironmentConnection GraphicsConnectWaterEnvironment(ByteAddressBuffer field,
    float3 camera,float renderer,float3 receiver,float3 direction) {
  GraphicsWaterEnvironmentConnection result=(GraphicsWaterEnvironmentConnection)0;
  if(!GraphicsFindWaterSurfaceExit(field,camera,renderer,receiver,float3(0,0,1)).valid) {
    // Reject a measured entry rather than treating its straight extension as
    // an unobstructed sky ray. Unknown bodies retain the native fallback.
    result.owned=GraphicsFindWaterSurfaceCrossing(field,camera,renderer,receiver,direction,false).valid;
    return result;
  }
  result.owned=true;
  result.surface=GraphicsFindWaterSurfaceExit(field,camera,renderer,receiver,direction);
  if(!result.surface.valid)return result;
  result.mapping=GraphicsMapWaterSun(direction,result.surface.normal,true);
  if(!result.mapping.valid)return result;
  if(GraphicsFindWaterSurfaceCrossing(field,camera,renderer,result.surface.position+result.mapping.air*.001f,
      result.mapping.air,false).valid)return result;
  result.valid=true;
  return result;
}
#endif
