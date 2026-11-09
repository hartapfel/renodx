// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../clouds/common.hlsli"
#include "../clouds/upsample.hlsli"
Texture2D<float4> cloud:register(t3);
Texture2D<float> cloud_depth:register(t4);
float4 main(float4 position:SV_Position):SV_Target {
  if(frame[340].x==5.f) {
    // A world-space density slice separates material evolution from camera,
    // lighting and temporal jitter. Every erosion quality must stay bounded.
    float3 p=float3((position.xy/dimensions.zw-.5f)*20000.f,
        CloudBase+.35f*CloudThickness());
    return float4(CloudDensity(p,0,0),CloudDensity(p,3,0),CloudWeather(p),1.f);
  }
  if(frame[340].x==4.f) {
    float angle=(position.x/dimensions.z-.5f)*2.792526803f;
    float3 sun=normalize(frame[204].yzw);
    float3 ray=float3(sun.x*cos(angle)-sun.y*sin(angle),sun.x*sin(angle)+sun.y*cos(angle),sun.z);
    float2 interval=CloudInterval(frame[0].xyz,ray);
    float3 p=frame[0].xyz+ray*lerp(interval.x,interval.y,position.y/dimensions.w);
    return float4(CloudDensity(p,0,0),CloudDensity(p,3,0),
        CloudLowSunOpening(p-frame[0].xyz,cloud_low_sun,.5f),1.f);
  }
  if(frame[340].x==3.f)return float4(CloudRay(position.xy/dimensions.zw),1.f);
  if(frame[340].x==2.f) {
    float4 authoring[5]={morphology,structure,microstructure,contour,illumination};
    uint index=uint(position.x)%20u;
    return float4(authoring[index/4u][index%4u],0,0,1);
  }
  if(frame[340].x==1.f) {
    float profile;
    float cover=CloudWeather(float3(0,0,CloudBase),profile);
    float2 wind=CloudWindOffset(frame[67].xy);
    return float4(cover,profile,position.x<1.f ? wind.x : wind.y,1);
  }
  float3 ray=CloudRay(position.xy/dimensions.zw);
  float distance;
  UpsampleCloud(cloud,cloud_depth,position.xy/dimensions.zw,CloudSceneDistance(position.xy,ray),distance);
  return float4(distance,CloudSceneDistance(position.xy,ray),CloudInterval(frame[0].xyz,ray).x,1);
}
