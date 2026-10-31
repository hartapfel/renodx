// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_NATIVE_WATER_SURFACE
#define CLASSIC_NATIVE_WATER_SURFACE
// Audited against native E2F7DEC1 / 7DAFF617. The regional height maps are
// absolute elevations; wave alpha is displacement, RGB is NOT a unit normal.
// This is intentionally independent of display grading and water color.
#include "native_resources.hlsli"
SamplerState WaterSurfaceClamp : register(s13);
SamplerState WaterSurfaceWrap : register(s14);

float NativeWaterElevation(float2 world) {
  uint width,height,layers;
  WaterRegionHeights.GetDimensions(width,height,layers);
  uint count=min(min(asuint(WaterSurfaceConstants[6].x),44u),layers);
  [loop] for(uint i=0;i<count;++i) {
    float4 rectangle=WaterSurfaceConstants[7+i];
    float2 uv=(world-rectangle.xy)/max(rectangle.zw,1.e-4f);
    if(any(uv<0.f) || any(uv>1.f)) continue;
    float height=WaterRegionHeights.SampleLevel(WaterSurfaceClamp,float3(uv,i),0);
    if(abs(height)>.001f) return height;
  }
  // Native global ocean plane is zero; nonzero local water is in the maps.
  return 0.f;
}

float NativeWaterBottom(float2 world,float2 range) {
  uint count,rows,width,height,layers;
  WaterTerrainTiles.GetDimensions(count,rows);
  WaterTerrainHeights.GetDimensions(width,height,layers);
  if(rows<2 || width==0 || height==0) return -10.f;
  [loop] for(uint i=0;i<min(count,layers);++i) {
    float4 rectangle=WaterTerrainTiles.Load(int3(i,0,0));
    if(any(world<=rectangle.xy) || any(world>=rectangle.zw)) continue;
    float4 atlas=WaterTerrainTiles.Load(int3(i,1,0));
    float2 uv=abs((world-rectangle.xy)/(rectangle.zw-rectangle.xy))+.5f/float2(width,height);
    uv=lerp(atlas.xy,atlas.zw,uv);
    return lerp(range.x,range.y,saturate(WaterTerrainHeights.SampleLevel(WaterSurfaceClamp,float3(uv,i),0)));
  }
  return -10.f;
}

float NativeWaterWaveHeight(float2 world,float elevation,float bottom) {
  float2 scale=max(WaterSurfaceConstants[0].xy,.001f);
  float depth=elevation-bottom;
  float2 shoreline=saturate((abs(depth)-.1f)*float2(.204081625f,.526315808f));
  shoreline=shoreline*float2(.7f,.4f)+float2(.3f,.6f);
  float2 displacement=float2(WaterWaves.SampleLevel(WaterSurfaceWrap,world/scale.x,0).a,
      WaterWaves.SampleLevel(WaterSurfaceWrap,world/scale.y,0).a);
  float shore_fade=(1.f-saturate(-.1f*depth))*.9f+.1f;
  return elevation+dot(displacement,WaterSurfaceConstants[1].xy*shoreline)*shore_fade;
}

// Use the derivative of the displaced GEOMETRY, rather than artist-scaled
// shading normals. Footprint-matched differences filter sub-grid wave detail.
float3 NativeWaterSurfaceNormal(float2 world,float elevation,float bottom,float footprint) {
  float dx=NativeWaterWaveHeight(world+float2(footprint,0),elevation,bottom)
      -NativeWaterWaveHeight(world-float2(footprint,0),elevation,bottom);
  float dy=NativeWaterWaveHeight(world+float2(0,footprint),elevation,bottom)
      -NativeWaterWaveHeight(world-float2(0,footprint),elevation,bottom);
  return normalize(float3(-dx,-dy,2.f*max(footprint,.001f)));
}
#endif
