// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// World-anchored directional visibility through the weather-driven layer.
// Slices are dispatched top-down with a UAV barrier between them, so each
// voxel reuses the transmission already integrated above it.
#include "common.hlsli"
#include "lighting.hlsli"
#include "light_ray.hlsli"
cbuffer Slice : register(b0,space73) { uint slice; }
RWTexture3D<float> visibility : register(u0);
Texture3D<float> previous_visibility : register(t13);
[numthreads(8,8,1)] void main(uint3 id : SV_DispatchThreadID) {
  uint width,height,depth;
  visibility.GetDimensions(width,height,depth);
  if(id.x>=width || id.y>=height || slice>=depth)return;
  float3 sun=CloudLightingDirection();
  if(sun.z<=(trace_grid.z>.5f?.02f:.15f) ||appearance.x<=0.f ||appearance.y<=0.f ||all(cloud_family_low.xy<=0.f)) {
    visibility[uint3(id.xy,slice)]=0.f;
    return;
  }
  const float extent=32000.f;
  float cell=extent/width;
  float2 center=floor(frame[0].xy/cell+.5f)*cell;
  float bottom=CloudMinimum(),top=CloudBase+CloudThickness();
  float dz=(top-bottom)/depth;
  float middle=CloudBase+.5f*CloudThickness();
  float2 shear=CloudLightShear(sun);
  float3 p=float3(center+((float2(id.xy)+.5f)/float2(width,height)-.5f)*extent,
      bottom+(slice+.5f)*dz);
  p.xy+=(p.z-middle)*shear;
  float tau=CloudOpticalExtinction*CloudDensity(p,1u,1.f,cell)*dz/sun.z;
  if(trace_grid.z>.5f &&sun.z<=.15f) {
    // Cache the existing sparse quadrature independently per voxel. Feeding
    // this full-path depth into the slice recurrence would count it twice.
    tau=CloudLightDepth(p,sun,min(cell,24.f));
  } else if(slice+1u<depth) {
    float2 previous=(p.xy+sun.xy*dz/sun.z-(p.z+dz-middle)*shear-center)/extent+.5f;
    float2 texel=previous*float2(width,height)-.5f;
    int2 origin=int2(floor(texel));
    float2 f=frac(texel);
    if(all(previous>=0.f)&&all(previous<=1.f)) {
      uint2 a=uint2(clamp(origin,0,int2(width,height)-1));
      uint2 b=uint2(clamp(origin+int2(1,0),0,int2(width,height)-1));
      uint2 c=uint2(clamp(origin+int2(0,1),0,int2(width,height)-1));
      uint2 d=uint2(clamp(origin+1,0,int2(width,height)-1));
      tau+=lerp(lerp(visibility[uint3(a,slice+1u)],visibility[uint3(b,slice+1u)],f.x),
          lerp(visibility[uint3(c,slice+1u)],visibility[uint3(d,slice+1u)],f.x),f.y);
    }
  }
  // Reproject the previous directional shadow volume with the Witcher's wind
  // offset. The local clamp limits lag when a weather front or cloud edge
  // changes; the filtered volume follows the same world grid as its source.
  float elapsed=cloud_clock.x-previous_cloud_clock.x;
  if(identity.x==previous_identity.x &&elapsed>=0.f &&elapsed<.5f
      &&previous_cloud_layer.x>0.f &&previous[66].x>0.f &&abs(frame[66].x-previous[66].x)<.001f) {
    float2 old_center=floor(previous[0].xy/cell+.5f)*cell;
    bool solar=dot(sun,normalize(frame[204].yzw+float3(0,0,1.e-8f)))>.999f;
    float3 old_direction=normalize((solar?previous[204].yzw:previous[205].yzw)+float3(0,0,1.e-8f));
    float2 old_uv=(p.xy+CloudWindOffset(frame[67].xy-previous[67].xy)
        -(p.z-middle)*CloudLightShear(old_direction)-old_center)/extent+.5f;
    if((trace_grid.z<=.5f ||(old_direction.z>.02f &&dot(old_direction,sun)>.999f))
        &&all(old_uv>=0.f)&&all(old_uv<=1.f)) {
      float old_tau=previous_visibility.SampleLevel(clamp_sampler,float3(old_uv,(p.z-bottom)/(top-bottom)),0);
      tau=lerp(tau,clamp(old_tau,max(0.f,tau-.75f),tau+.75f),.7f);
    }
  }
  visibility[uint3(id.xy,slice)]=min(tau,16.f);
}
