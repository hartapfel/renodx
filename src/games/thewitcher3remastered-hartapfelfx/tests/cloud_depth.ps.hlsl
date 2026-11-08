// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../clouds/common.hlsli"
Texture2D<float> cloud_depth:register(t4);
float4 main(float4 position:SV_Position):SV_Target {
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
  return float4(cloud_depth.Load(int3(int2(position.xy),0)),CloudSceneDistance(position.xy,ray),CloudInterval(frame[0].xyz,ray).x,1);
}
