// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "common.hlsli"
#include "lighting.hlsli"
#include "sky_ambient.hlsli"
RWTexture2D<float> transmission : register(u0);
RWStructuredBuffer<float4> shadow_data : register(u1);
#define previous_shadow cloud_shared
void main(float4 position : SV_Position) {
  uint3 id = uint3(uint2(position.xy), 0);
  if(any(id.xy>=uint2(dimensions.xy)))return;
  if(all(id.xy==0)) {
    shadow_data[6]=light[0];shadow_data[7]=light[1];
    shadow_data[8]=float4(CloudSkyAmbient(),cloud_low_sun.w);
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
      && asfloat(previous_shadow.Load(288)) == CloudBase
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
  if(!valid ||!clock_valid ||integration.x==0.f ||appearance.x==0.f ||appearance.y==0.f||cloud_main_strength<=0.f)return;
  float3 origin=float3(center+((id.xy+.5f)/dimensions.xy-.5f)*dimensions.z,0);
  float2 interval=CloudInterval(origin,sun);
  if(interval.y<=interval.x)return;
  uint steps=min(192u,(uint)ceil(dimensions.w/sqrt(max(sun.z,.1f))));
  float ds=(interval.y-interval.x)/steps;
  // Shadow texels integrate a finite beam: filter its broad density instead
  // of repeatedly resolving sub-texel view-ray erosion in distant shadows.
  float footprint=max(texel,ds)*scattering.w/min(cloud_formation_period,cloud_vertical_period);
  float lod=clamp(log2(max(footprint,1.f)),scattering.w>64.f?1.f:0.f,4.f);
  float optical_depth=0.f;
  [loop]for(uint i=0;i<steps &&optical_depth<12.f;++i) {
    float3 p=origin+sun*(interval.x+(i+.5f)*ds);
    optical_depth+=CloudDirectBeamScale()*CloudOpticalExtinction*CloudDensity(p,1u,lod,texel)*ds;
  }
  transmission[id.xy]=exp(-optical_depth);
}
