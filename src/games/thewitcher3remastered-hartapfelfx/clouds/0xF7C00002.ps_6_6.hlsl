// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "integration.hlsli"
#include "storage.hlsli"
RWTexture2D<float4> result : register(u0);
RWTexture2D<float> cloud_depth : register(u1);
void main(float4 position : SV_Position) {
  uint3 id = uint3(uint2(position.xy), 0);
  if(any(id.xy>=uint2(trace_grid.xy)) || CloudAlreadyRendered())return;
  result[id.xy]=float4(0,0,0,0);cloud_depth[id.xy]=0;
  if(appearance.x==0.f ||appearance.y==0.f ||cloud_main_strength<=0.f)return;
  float2 uv=(float2(id.xy)+.5f+CloudTraceOffset())/trace_grid.xy;
  float3 ray=CloudRay(uv);
  float2 interval=CloudInterval(frame[0].xyz,ray);
  // Conservative depth cull: every pixel covered by this cloud texel must be
  // in front of the layer. Mixed silhouettes still trace an unobscured sky.
  float maximum_distance=0.f;
  uint2 lo=uint2(id.xy*dimensions.zw/trace_grid.xy);
  uint2 hi=min(uint2(dimensions.zw),uint2(ceil((id.xy+1)*dimensions.zw/trace_grid.xy)));
  [loop]for(uint y=lo.y;y<hi.y;++y)[loop]for(uint x=lo.x;x<hi.x;++x)
    maximum_distance=max(maximum_distance,CloudSceneDistance(float2(x,y)+.5f,ray));
  // Mountains can intersect the layer rather than sit entirely in front of
  // it. Integrate only the visible column, never the cloud behind the surface.
  interval.y=min(interval.y,maximum_distance);
  float cone=max(length(CloudRay(uv+float2(1.f/dimensions.x,0))-ray),
      length(CloudRay(uv+float2(0,1.f/dimensions.y))-ray));
  float depth=0.f;
  float4 cloud=float4(0,0,0,1);
  if(interval.y>interval.x)
    cloud=TraceCloud(frame[0].xyz,ray,interval,cone,id.xy,512u,160.f,depth);
  // History stores only intrinsic material radiance and transmission. Camera
  // air and foreground fog are applied after temporal reconstruction.
  result[id.xy]=CloudEncode(cloud);
  cloud_depth[id.xy]=depth;
}
