// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef REMASTERED_CLOUD_SHADOW_SAMPLE
#define REMASTERED_CLOUD_SHADOW_SAMPLE
#include "altitude.hlsli"
// No native sampler is borrowed. The same world-space field can serve pixel,
// vertex and compute receivers without changing their material samplers.
float GraphicsCloudShadow(ByteAddressBuffer field,float3 world,float native_visibility,uint base=0u) {
  // Native DX12 root SRVs carry an address, not descriptor dimensions.
  // The owner validates the allocation; its 16-byte neutral buffer has span 0
  // and must return before any later metadata/data load.
  float4 region=asfloat(field.Load4(base));
  if(!all(isfinite(region)) ||region.w<=0.f)return native_visibility;
  float4 sun=asfloat(field.Load4(base+16));
  float4 metadata=asfloat(field.Load4(base+32));
  if(!all(isfinite(region)) ||!all(isfinite(sun)) ||!all(isfinite(metadata))
      ||!all(isfinite(world)) ||sun.w!=1.f ||sun.z<=.015f ||metadata.w!=1357.f
      ||region.w<=0.f ||any(metadata.xy<1.f) ||any(metadata.xy>4096.f)
      ||any(floor(metadata.xy)!=metadata.xy))return native_visibility;
  uint2 size=uint2(metadata.xy);
  float4 layer=asfloat(field.Load4(base+48));
  if(!all(isfinite(layer)) ||layer.y<=layer.x ||layer.w!=float(64u+4u*size.x*size.y))return native_visibility;
  // This map integrates the complete column from below the spherical layer.
  // A point inside/above the layer needs partial-column transport, so retain
  // its native visibility instead of shadowing it with cloud below the point.
  if(CloudAltitude(world)>=layer.x-50.f)return native_visibility;
  float strength=saturate(metadata.z);
  if(strength==0.f)return 1.f;
  float2 projection=world.xy-(world.z-region.z)*sun.xy/sun.z;
  float2 uv=(projection-region.xy)/region.w+.5f;
  if(any(uv<=0.f) ||any(uv>=1.f))return 1.f;
  float edge=min(min(uv.x,uv.y),min(1.f-uv.x,1.f-uv.y));
  float2 pixel=uv*size-.5f;
  int2 cell=int2(floor(pixel));float2 f=frac(pixel);
  float transmission=0.f;
  [unroll]for(int y=0;y<2;++y)[unroll]for(int x=0;x<2;++x) {
    uint2 location=uint2(clamp(cell+int2(x,y),0,int2(size)-1));
    float value=asfloat(field.Load(base+64+4*(location.y*size.x+location.x)));
    if(!isfinite(value))return native_visibility;
    transmission+=saturate(value)*(x?f.x:1.f-f.x)*(y?f.y:1.f-f.y);
  }
  return lerp(1.f,transmission,strength*smoothstep(0.f,.08f,edge));
}
#endif
