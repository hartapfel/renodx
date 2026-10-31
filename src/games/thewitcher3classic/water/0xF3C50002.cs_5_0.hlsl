// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "native_surface.hlsli"
#include "underwater_inputs.hlsli"
RWStructuredBuffer<float4> Photons : register(u0);
[numthreads(8,8,1)]
void main(uint3 id:SV_DispatchThreadID) {
  if(any(id.xy>CLASSIC_CAUSTIC_GRID) || id.z>=4u) return;
  float3 light=UnderwaterState[1].xyz;
  float3 flat_ray=refract(-light,float3(0,0,1),1.f/1.333f);
  float depth=UnderwaterState[6][id.z];
  float2 origin=UnderwaterState[5].xy;
  float extent=UnderwaterState[5].z;
  float2 world=origin+float2(id.xy)*(extent/float(CLASSIC_CAUSTIC_GRID))-flat_ray.xy*(depth/max(-flat_ray.z,.01f));
  float elevation=NativeWaterElevation(world);
  float bottom=NativeWaterBottom(world,WaterRanges[0].xy);
  float height=NativeWaterWaveHeight(world,elevation,bottom);
  float3 normal=NativeWaterSurfaceNormal(world,elevation,bottom,extent/float(CLASSIC_CAUSTIC_TILE));
  float3 ray=refract(-light,normal,1.f/1.333f);
  float distance=max(0.f,height-(UnderwaterState[1].w-depth))/max(-ray.z,.01f);
  float2 landing=world+ray.xy*distance;
  // Flux per horizontal source area. Surface tilt changes projected collection
  // area as well as Fresnel transmission. Normalize against a flat interface;
  // its Fresnel/cosine transfer and water absorption are applied at the receiver.
  float cosine=saturate(dot(light,normal));
  float flat_transmission=1.f-WaterInterfaceFresnel(light.z,1.f/1.333f);
  float flux=cosine*(1.f-WaterInterfaceFresnel(cosine,1.f/1.333f))
      /max(normal.z*light.z*flat_transmission,1.e-6f);
  if(abs(elevation-UnderwaterState[1].w)>.25f || ray.z>=0.f) flux=0.f;
  Photons[id.z*CLASSIC_CAUSTIC_VERTICES*CLASSIC_CAUSTIC_VERTICES+id.y*CLASSIC_CAUSTIC_VERTICES+id.x]=float4(landing,flux,0.f);
}
