// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "common.hlsli"
RWTexture2D<float> transmission : register(u0);
RWStructuredBuffer<float4> shadow_data : register(u1);
[numthreads(8,8,1)]
void main(uint3 id:SV_DispatchThreadID) {
  if(any(id.xy>=uint2(dimensions.xy)))return;
  float3 sun=normalize(light[0].xyz+1.e-8f);
  bool valid=sun.z>.015f &&frame[66].x>0.f &&CloudAltitude(frame[0].xyz)<CloudBase-50.f;
  float texel=dimensions.z/dimensions.x;
  // Project the primary camera onto z=0 along the light, then snap in world
  // units. Camera movement does not drag the shadows over stationary objects.
  float2 center=frame[0].xy-frame[0].z*sun.xy/max(sun.z,.015f);
  center=floor(center/texel+.5f)*texel;
  if(all(id.xy==0)) {
    shadow_data[0]=float4(center,0,dimensions.z);
    shadow_data[1]=float4(sun,valid ? 1.f : 0.f);
    shadow_data[2]=float4(dimensions.xy,saturate(integration.x),1357);
    shadow_data[3]=float4(frame[0].xyz,scattering.z);
  }
  transmission[id.xy]=1.f;
  if(!valid ||integration.x==0.f ||appearance.x==0.f ||appearance.y==0.f)return;
  float3 origin=float3(center+((id.xy+.5f)/dimensions.xy-.5f)*dimensions.z,0);
  float2 interval=CloudInterval(origin,sun);
  if(interval.y<=interval.x)return;
  uint steps=min(192u,(uint)ceil(dimensions.w/sqrt(max(sun.z,.1f))));
  float ds=(interval.y-interval.x)/steps;
  // Shadow texels integrate a finite beam: filter its broad density instead
  // of repeatedly resolving sub-texel view-ray erosion in distant shadows.
  float footprint=max(texel,ds)*scattering.w/min(CloudFormationScale*appearance.z,2800.f);
  float lod=clamp(log2(max(footprint,1.f)),scattering.w>64.f?1.f:0.f,4.f);
  float optical_depth=0.f;
  [loop]for(uint i=0;i<steps &&optical_depth<12.f;++i) {
    float3 p=origin+sun*(interval.x+(i+.5f)*ds);
    optical_depth+=Extinction*CloudDensity(p,1u,lod,texel)*ds;
  }
  transmission[id.xy]=exp(-optical_depth);
}
