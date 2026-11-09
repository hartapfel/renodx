// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "common.hlsli"
#include "lighting.hlsli"
#include "sky_ambient.hlsli"
RWTexture2D<float2> transmission : register(u0);
RWStructuredBuffer<float4> shadow_data : register(u1);
#define previous_shadow cloud_shared
groupshared float3 sky_samples[64];
[numthreads(8, 8, 1)] void main(uint3 id : SV_DispatchThreadID,
    uint3 group:SV_GroupID,uint lane:SV_GroupIndex) {
  if(all(group.xy==0u)) {
    sky_samples[lane]=CloudSkyAmbientSample(lane);
    GroupMemoryBarrierWithGroupSync();
    for(uint stride=32u;stride>0u;stride>>=1u) {
      if(lane<stride)sky_samples[lane]+=sky_samples[lane+stride];
      GroupMemoryBarrierWithGroupSync();
    }
    if(lane==0u)shadow_data[8]=float4(max(sky_samples[0],0.f),cloud_low_sun.w);
  }
  if(any(id.xy>=uint2(dimensions.xy)))return;
  if(all(id.xy==0)) {
    shadow_data[6]=light[0];shadow_data[7]=light[1];
  }
  float3 sun=CloudLightingDirection(true);
  bool valid=sun.z>.015f &&frame[66].x>0.f &&CloudAltitude(frame[0].xyz)<CloudBase-50.f;
  bool clock_valid = (identity.w & 256u) == 0 || (clock_identity.w == 0xF7C0000Du
      && all(clock_camera.xyz == frame[0].xyz) && all(clock_jitter == asuint(frame[286])));
  uint3 key = CloudIdentity();
  if (clock_valid && previous_shadow.Load(44) == asuint(1357.f)
      && all(previous_shadow.Load3(68) == uint3(key.yz, key.x))
      && all(previous_shadow.Load4(80) == asuint(frame[286]))
      && all(previous_shadow.Load4(224) == asuint(frame[66]))
      && all(previous_shadow.Load4(240) == asuint(frame[67]))
      && all(previous_shadow.Load4(256) == asuint(frame[68]))
      && all(previous_shadow.Load4(272) == asuint(cloud_clock))
      && all(asfloat(previous_shadow.Load3(48)) == frame[0].xyz)
      && all(asfloat(previous_shadow.Load3(292)) == cloud_low_sun.xyz)
      && all(previous_shadow.Load4(304)==asuint(celestial))
      && previous_shadow.Load(352)==asuint(cloud_low_sun.w)
      && all(asfloat(previous_shadow.Load3(16)) == sun)) return;
  float texel=dimensions.z/dimensions.x;
  // Project the primary camera onto z=0 along the light, then snap in world
  // units. Camera movement does not drag the shadows over stationary objects.
  float2 center=frame[0].xy-frame[0].z*sun.xy/max(sun.z,.015f);
  center=floor(center/texel+.5f)*texel;
  float map_top=CloudBase+CloudThickness();
  if(all(id.xy==0)) {
    // The map is traced from z=0. Publish the maximum cloud altitude so
    // receivers above the entire layer cannot inherit a ground shadow.
    shadow_data[0]=float4(center,map_top,dimensions.z);
    shadow_data[13]=float4(CloudBase,cloud_low_sun.xyz);
    shadow_data[14]=celestial;
    shadow_data[1]=float4(sun,valid ? 1.f : 0.f);
    shadow_data[2]=float4(dimensions.xy,saturate(integration.x),clock_valid ? 1357.f : 0.f);
    shadow_data[3]=float4(frame[0].xyz,asfloat(storage.w));
    shadow_data[4]=asfloat(uint4(storage.z,key.yz,key.x));
    shadow_data[5]=frame[286];
    shadow_data[9]=frame[66];shadow_data[10]=frame[67];
    shadow_data[11]=frame[68];shadow_data[12]=cloud_clock;
  }
  transmission[id.xy]=1.f;
  if(!valid ||!clock_valid ||integration.x==0.f ||appearance.x==0.f ||appearance.y==0.f)return;
  float3 origin=float3(center+((id.xy+.5f)/dimensions.xy-.5f)*dimensions.z,0);
  float2 interval=CloudInterval(origin,sun);
  if(interval.y<=interval.x)return;
  uint steps=min(192u,(uint)ceil(dimensions.w/sqrt(max(sun.z,.1f))));
  float ds=(interval.y-interval.x)/steps;
  // Shadow texels integrate a finite beam: filter its broad density instead
  // of repeatedly resolving sub-texel view-ray erosion in distant shadows.
  float footprint=max(texel,ds)*scattering.w/min(CloudFormationScale*appearance.z,2800.f);
  float lod=clamp(log2(max(footprint,1.f)),0.f,4.f);
  float optical_depth=0.f;
  float weighted_depth=1.f;
  if(any(cloud_family_low.xy>0.f)) {
  [loop]for(uint i=0;i<steps &&optical_depth<12.f;++i) {
    // March from the sun-facing top. The transmittance-weighted depth is the
    // slide-35 blocker estimate; Beer transmission remains available for
    // receivers below the complete cloud column.
    float3 p=origin+sun*(interval.y-(i+.5f)*ds);
    optical_depth+=CloudDirectBeamScale()*CloudOpticalExtinction
        *CloudDensity(p,(uint)scattering.y,lod,texel)*ds;
    weighted_depth=lerp(weighted_depth,(i+.5f)/steps,exp(-4.f*optical_depth));
  }
  }
  float blocker=CloudBase+CloudThickness()*(1.f-weighted_depth);
  // A half-float ESM needs a smaller exponent than Annen's 32-bit ESM80.
  // Normalizing the depth to the 1.2 km layer keeps this filtered value in
  // [exp(-12),1] and prevents FP16 underflow.
  transmission[id.xy]=float2(exp(-optical_depth),
      optical_depth>1.e-5f?exp(-12.f*saturate((blocker-CloudBase)/(map_top-CloudBase))):1.f);
}
