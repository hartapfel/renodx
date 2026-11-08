// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "integration.hlsli"
#include "environment.hlsli"
RWTexture2D<float4> environment : register(u0);
RWTexture2D<float> environment_depth : register(u1);
RWByteAddressBuffer environment_header : register(u2);
[numthreads(8,8,1)] void main(uint3 id:SV_DispatchThreadID) {
  uint2 extent;
  environment.GetDimensions(extent.x,extent.y);
  if(any(id.xy>=extent))return;
  if(all(id.xy==0u)) {
    environment_header.Store4(0u,uint4(0x57334345u,256u,128u,identity.x));
    environment_header.Store4(16u,asuint(frame[0]));
    environment_header.Store4(32u,asuint(frame[66]));
    environment_header.Store4(48u,asuint(frame[68]));
    environment_header.Store4(64u,asuint(appearance));
    environment_header.Store4(80u,asuint(atmosphere));
    environment_header.Store4(96u,asuint(cloud_clock));
    environment_header.Store4(112u,asuint(light[0]));
    environment_header.Store4(128u,asuint(frame[67]));
  }
  float4 value=float4(0,0,0,1);
  float depth=0.f;
  float3 ray=CloudEnvironmentDirection((float2(id.xy)+.5f)/float2(extent));
  float2 interval=CloudInterval(frame[0].xyz,ray);
  // The consumer owns geometry occlusion and foreground atmosphere. A lower
  // hemisphere lookup remains clear, matching the main view's ground policy.
  if(appearance.x>0.f &&appearance.y>0.f) {
    float cone=max(3.14159265359f/extent.y,
        6.28318530718f*sqrt(max(0.f,1.f-ray.z*ray.z))/extent.x);
    if(interval.y>interval.x &&any(cloud_family_low.xy>0.f))
      value=TraceCloud(frame[0].xyz,ray,interval,cone,id.xy,128u,400.f,depth);
    if(value.a>=.999999f)depth=0.f;
  }
  environment[id.xy]=value;
  environment_depth[id.xy]=depth;
}
