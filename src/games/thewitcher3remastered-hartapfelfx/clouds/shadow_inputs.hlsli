// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_INPUTS
#define HARTAPFEL_CLOUD_INPUTS
ByteAddressBuffer HartapfelCloudData : register(t0, space72);
bool CloudVisibleMatches(float3 camera, float4 projection_x, float4 projection_y, float4 extent, uint4 jitter, float clock) {
  return HartapfelCloudData.Load(160) != 0
      && all(asfloat(HartapfelCloudData.Load3(112)) == camera)
      && all(HartapfelCloudData.Load4(128) == jitter)
      && all(asfloat(HartapfelCloudData.Load4(144)) == extent)
      && asfloat(HartapfelCloudData.Load(176)) == clock
      && all(asfloat(HartapfelCloudData.Load4(192)) == projection_x)
      && all(asfloat(HartapfelCloudData.Load4(208)) == projection_y);
}
float2 CloudPackedShadow(int2 pixel, uint2 size, uint pitch, uint offset) {
  pixel = clamp(pixel, 0, int2(size) - 1);
  uint address = offset + uint(pixel.y) * pitch + uint(pixel.x) * 4u;
  uint packed = HartapfelCloudData.Load(address);
  return f16tof32(uint2(packed & 65535u, packed >> 16u));
}
float2 CloudPackedShadowFiltered(float2 uv, uint2 size, uint pitch, uint offset) {
  float2 pixel=uv*size-.5f;
  int2 cell=int2(floor(pixel));
  float2 f=frac(pixel);
  return lerp(lerp(CloudPackedShadow(cell,size,pitch,offset),CloudPackedShadow(cell+int2(1,0),size,pitch,offset),f.x),
      lerp(CloudPackedShadow(cell+int2(0,1),size,pitch,offset),CloudPackedShadow(cell+1,size,pitch,offset),f.x),f.y);
}
// Camera and jitter qualify the persistent map on the GPU. A CPU recording
// pointer cannot establish which frame currently occupies a native buffer.
bool CloudShadowMatches(float3 camera, uint4 jitter) {
  return asfloat(HartapfelCloudData.Load(44)) == 1357.f
      && all(asfloat(HartapfelCloudData.Load3(48)) == camera)
      && all(HartapfelCloudData.Load4(80) == jitter);
}
float HartapfelCloudShadow(float3 world, float native_visibility) {
  float4 region = asfloat(HartapfelCloudData.Load4(0));
  float4 sun = asfloat(HartapfelCloudData.Load4(16));
  float4 parameters = asfloat(HartapfelCloudData.Load4(32));
  if (parameters.w != 1357.f) return native_visibility;
  if (parameters.z == 0.f) return 1.f;
  if (sun.w != 1.f || region.w <= 0.f) return native_visibility;
  if (world.z >= region.z) return 1.f;
  uint2 size = uint2(parameters.xy);
  uint pitch = HartapfelCloudData.Load(64);
  uint offset = HartapfelCloudData.Load(60);
  if (any(size == 0) || pitch < size.x * 4 || offset < 240u) return native_visibility;
  float2 projection = world.xy - world.z * sun.xy / sun.z;
  float2 uv = (projection - region.xy) / region.w + .5f;
  if (any(uv <= 0.f) || any(uv >= 1.f)) return 1.f;
  // Projected screen-pixel footprint selects the prefiltered mip. Native
  // offscreen sky/probe views are much smaller than the main view; this avoids
  // crawling there without broadening nearby main-view shadows.
  uint2 view_size=HartapfelCloudData.Load2(96);
  // All receivers on one sun ray use the same shadow footprint. Otherwise
  // changing mip with receiver height can make a point *inside* the cloud
  // darker than the ground directly below it.
  float distance=length(float3(projection,0.f)-asfloat(HartapfelCloudData.Load3(48)));
  float footprint=distance*2.f/max(float(min(view_size.x,view_size.y)),1.f);
  float lod=clamp(log2(max(footprint*size.x/region.w,1.f)),0.f,5.f);
  uint level=uint(floor(lod));
  [unroll]for(uint i=0;i<5u;++i) {
    if(i>=level)break;
    offset=(offset+pitch*size.y+511u)&~511u;
    size=max(size>>1,1u);
    pitch=(size.x*4u+255u)&~255u;
  }
  float2 visibility=CloudPackedShadowFiltered(uv,size,pitch,offset);
  if(lod>level+.001f &&level<5u) {
    uint next_offset=(offset+pitch*size.y+511u)&~511u;
    uint2 next_size=max(size>>1,1u);
    uint next_pitch=(next_size.x*4u+255u)&~255u;
    visibility=lerp(visibility,CloudPackedShadowFiltered(uv,next_size,next_pitch,next_offset),frac(lod));
  }
  // The RDR2 weighted blocker depth is evaluated only inside the layer.
  // Below the complete column, retain the measured Beer transmission rather
  // than treating a thin cloud as an opaque depth blocker.
  float base=asfloat(HartapfelCloudData.Load(288));
  if(!isfinite(base) ||base<300.f)base=1200.f;
  if(world.z>base) {
    float depth=saturate((world.z-base)/max(region.z-base,1.f));
    visibility.x=max(visibility.x,saturate(visibility.y*exp(12.f*depth)));
  }
  float edge = min(min(uv.x, uv.y), min(1.f - uv.x, 1.f - uv.y));
  // Mix clear and cloud-filtered illumination in linear light. The map
  // stores full-strength transmission for the separate solar disc test.
  return lerp(1.f, saturate(visibility.x), parameters.z * smoothstep(0.f, .08f, edge));
}
bool CloudShadowReady() {
  float4 region = asfloat(HartapfelCloudData.Load4(0));
  float4 sun = asfloat(HartapfelCloudData.Load4(16));
  float4 parameters = asfloat(HartapfelCloudData.Load4(32));
  uint2 size = uint2(parameters.xy);
  return parameters.w == 1357.f && sun.w == 1.f && region.w > 0.f && all(size > 0u)
      && HartapfelCloudData.Load(64) >= size.x * 4u && HartapfelCloudData.Load(60) >= 240u;
}
// Only attenuate a sky emitter with the map traced toward that emitter.
// A daytime sun map must not dim an independently visible moon lobe.
float HartapfelCloudEmitterVisibility(float3 world, float3 emitter) {
  float3 direction=asfloat(HartapfelCloudData.Load3(16));
  if(!CloudShadowReady() ||!all(isfinite(emitter)) ||dot(emitter,emitter)<=.25f
      ||dot(direction,normalize(emitter))<.999f)return 1.f;
  return HartapfelCloudShadow(world,1.f);
}
float HartapfelCloudNeutralize(float native_visibility) {
  return CloudShadowReady() ? 1.f : native_visibility;
}
float HartapfelCloudShadowMultiply(float3 world, float native_visibility) {
  return native_visibility * HartapfelCloudShadow(world, 1.f);
}
#endif
