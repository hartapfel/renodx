// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../water/interface_sampling.hlsli"
#include "water_geometry.lib_6_6.hlsli"
#include "atmosphere.hlsli"
#ifndef W3_PT_WATER_INTERFACE_LIMIT
#define W3_PT_WATER_INTERFACE_LIMIT 8u
#endif

// Continue the native sampled ray through measured entry/exit/reflection events.
// Caller applies only the final leg's medium transport, then decodes the final
// payload using the returned ray. This export remains staged until environment,
// local-light and atmospheric connections use the same path.
// transport.rgb owns completed legs and sampled interface coefficients; w is
// the product of branch probabilities, not another energy factor.
// path_state = (distance to final ray origin including offsets, event count,
// starting medium is water, final medium is water). All zero means no event.
void GraphicsContinueWaterPath(float x,float y,float z,float dx,float dy,float dz,
    float maximum,float sample_value,inout GbufferPayload payload,
    out float4 origin_active,out float4 direction_remaining,out float4 transport,out float4 path_state,
    float4 fog_parameters[17],uint fog_flags,out float4 fog_row0,out float4 fog_row1,out float4 fog_row2) {
  origin_active=0.f;direction_remaining=0.f;
  transport=1.f;path_state=0.f;
  fog_row0=float4(1,0,0,0);fog_row1=float4(0,1,0,0);fog_row2=float4(0,0,1,0);
  GraphicsPathTransfer atmosphere;
  atmosphere.response=float3x3(1,0,0,0,1,0,0,0,1);atmosphere.scattering=0.f;
  if(!GraphicsPathWaterEnabled())return;
  float3 origin=float3(x,y,z),direction=float3(dx,dy,dz);
  bool starting_water=GraphicsFindWaterSurfaceExit(graphics_path_water_field,
      graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,origin,float3(0,0,1)).valid;
  if(!starting_water && !GraphicsFindWaterSurfaceCrossing(graphics_path_water_field,
      graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,origin,float3(0,0,-1),false).valid)return;
  bool from_water=starting_water;
  float travelled=0.f;
  GbufferPayload original_payload=payload;
  // Bound specular traversal independently of the native material-bounce loop.
  // On exhaustion, reject only a path that actually needs another crossing;
  // never return a straight-through light leak at the cap.
  [loop] for(uint count=0u;count<=W3_PT_WATER_INTERFACE_LIMIT;++count) {
    float hit_distance=asfloat(payload.data.w);
    if (!isfinite(hit_distance) || maximum-travelled<=.001f) break;
    GraphicsWaterSurfaceCrossing surface=GraphicsFindWaterSurfaceCrossing(graphics_path_water_field,
        graphics_path_cloud_frame[0].xyz,graphics_path_cloud_frame[74].x,origin,direction,from_water,
        min(maximum-travelled-.001f,hit_distance>=0.f ? hit_distance : maximum-travelled));
    if(!surface.valid || !isfinite(hit_distance) || surface.distance<=0.f
        || maximum-travelled<=surface.distance+.001f
        || (hit_distance>=0.f && hit_distance<=surface.distance))break;
    if(count==W3_PT_WATER_INTERFACE_LIMIT) {
      transport.rgb=0.f;
      fog_row0.xyz=0.f;fog_row1.xyz=0.f;fog_row2.xyz=0.f;
      break;
    }
    GraphicsWaterInterfaceEvent event=GraphicsSampleWaterInterface(direction,surface.normal,from_water,sample_value);
    if(!event.valid)break;
    float4 next_origin,next_direction;
    GraphicsContinueWaterGeometry(surface.position,event.direction,surface.distance,maximum-travelled,
        payload,next_origin,next_direction);
    if(next_origin.w==0.f)break;
    if(!isfinite(asfloat(payload.data.w))) {
      payload=original_payload;origin_active=0.f;direction_remaining=0.f;transport=1.f;path_state=0.f;
      fog_row0=float4(1,0,0,0);fog_row1=float4(0,1,0,0);fog_row2=float4(0,0,1,0);return;
    }
    if((fog_flags&GRAPHICS_PATH_FOG_ENABLED)!=0u) {
      if(from_water)GraphicsAttenuatePathTransfer(atmosphere,surface.transmission);
      else GraphicsAccumulatePathAtmosphere(atmosphere,origin.z,direction*surface.distance,false,fog_parameters,fog_flags);
      GraphicsAttenuatePathTransfer(atmosphere,event.radiance_weight);
    }
    travelled+=surface.distance+.001f;
    if(event.transmitted)from_water=!from_water;
    transport*=float4(surface.transmission*event.radiance_weight,event.probability);
    // Account for the skipped ray-origin offset in the medium entered by this
    // event; otherwise every internal reflection omits a short absorbing leg.
    if(from_water)transport.rgb*=exp(-asfloat(graphics_path_water_field.Load3(48u))*.001f);
    if((fog_flags&GRAPHICS_PATH_FOG_ENABLED)!=0u) {
      if(from_water)GraphicsAttenuatePathTransfer(atmosphere,exp(-asfloat(graphics_path_water_field.Load3(48u))*.001f));
      else GraphicsAccumulatePathAtmosphere(atmosphere,surface.position.z,event.direction*.001f,false,fog_parameters,fog_flags);
      fog_row0=float4(atmosphere.response[0],atmosphere.scattering.x);
      fog_row1=float4(atmosphere.response[1],atmosphere.scattering.y);
      fog_row2=float4(atmosphere.response[2],atmosphere.scattering.z);
    }
    origin_active=next_origin;direction_remaining=next_direction;
    origin=next_origin.xyz;direction=next_direction.xyz;
    path_state=float4(travelled,float(count+1u),starting_water?1.f:0.f,from_water?1.f:0.f);
    // Conditional remapping provides a fresh uniform variate on the chosen
    // branch without consuming or perturbing the game's native RNG stream.
    sample_value=event.transmitted ? sample_value/event.probability
        : (sample_value-(1.f-event.probability))/event.probability;
    sample_value=clamp(sample_value,0.f,asfloat(0x3F7FFFFFu));
  }
}

// Keep the established geometry-only ABI and its optimized, atmosphere-free
// path available while the native first-edge fog callers are integrated.
export void GraphicsPathWaterInterface(float x,float y,float z,float dx,float dy,float dz,
    float maximum,float sample_value,inout GbufferPayload payload,
    out float4 origin_active,out float4 direction_remaining,out float4 transport,out float4 path_state) {
  float4 parameters[17];
  [unroll] for(uint row=0u;row<17u;++row)parameters[row]=0.f;
  float4 fog_row0,fog_row1,fog_row2;
  GraphicsContinueWaterPath(x,y,z,dx,dy,dz,maximum,sample_value,payload,
      origin_active,direction_remaining,transport,path_state,parameters,0u,fog_row0,fog_row1,fog_row2);
}

// The three rows contain the completed segments' RGB matrix in xyz and their
// scattering in w. Final-leg transport belongs to the caller, which knows the
// native sky/material classification. Never divide these rows by RGB throughput.
export void GraphicsPathWaterAtmosphereInterface(float x,float y,float z,float dx,float dy,float dz,
    float maximum,float sample_value,inout GbufferPayload payload,
    out float4 origin_active,out float4 direction_remaining,out float4 transport,out float4 path_state,
    float4 fog_parameters[17],uint fog_flags,out float4 fog_row0,out float4 fog_row1,out float4 fog_row2) {
  GraphicsContinueWaterPath(x,y,z,dx,dy,dz,maximum,sample_value,payload,
      origin_active,direction_remaining,transport,path_state,fog_parameters,fog_flags,fog_row0,fog_row1,fog_row2);
}

// Complete the transfer only after the native caller has classified the final
// hit. The remaining water factor is the caller's existing field query. Air
// uses the actual last ray, never the chord from the original material vertex.
export void GraphicsFinishWaterAtmosphere(float height,float dx,float dy,float dz,float distance,
    uint sky,uint water,float3 remaining_water,float4 parameters[17],uint flags,
    inout float4 row0,inout float4 row1,inout float4 row2) {
  if((flags&GRAPHICS_PATH_FOG_ENABLED)==0u)return;
  GraphicsPathTransfer transfer;
  transfer.response=float3x3(row0.xyz,row1.xyz,row2.xyz);
  transfer.scattering=float3(row0.w,row1.w,row2.w);
  if(water!=0u)GraphicsAttenuatePathTransfer(transfer,sky!=0u?0.f:remaining_water);
  else GraphicsAccumulatePathAtmosphere(transfer,height,float3(dx,dy,dz)*(sky!=0u?1.f:distance),
      sky!=0u,parameters,flags);
  row0=float4(transfer.response[0],transfer.scattering.x);
  row1=float4(transfer.response[1],transfer.scattering.y);
  row2=float4(transfer.response[2],transfer.scattering.z);
}
