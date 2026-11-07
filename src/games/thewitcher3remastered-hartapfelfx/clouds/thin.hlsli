// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_THIN
#define HARTAPFEL_CLOUD_THIN
#include "common.hlsli"
#include "lighting.hlsli"
Texture2D<float> cirrus_map : register(t14);
// The high cirrus alone uses this thin-column approximation. The rejected
// middle sheet has no atlas channels, view shading or shadow contribution.
float CloudCirrusTau(float3 origin,float3 ray,float footprint) {
  if(appearance.x<=0.f ||appearance.y<=0.f ||cloud_family_high.x<=0.f ||high_layer.x<=0.f ||high_layer.y<=0.f)return 0.f;
  float t=CloudSphere(origin,ray,CloudCirrusHeight()).y;
  if(t<=0.f)return 0.f;
  if(ray.z<0.f) {
    float2 ground=CloudSphere(origin,ray,0.f);
    if(ground.x>=0.f &&ground.x<t)return 0.f;
  }
  float3 p=origin+ray*t;
  float cover=lerp(CloudWeather(p),1.f,saturate(cloud_family_high.y));
  if(cover<=.002f)return 0.f;
  float period=24000.f*high_layer.z;
  float lod=clamp(log2(max(footprint*512.f/period,1.f)),0.f,9.f);
  float material=cirrus_map.SampleLevel(wrap_sampler,
      (p.xy+CloudWindOffset(frame[67].xy))/period,lod);
  material=saturate((material-(1.f-high_layer.y))/max(high_layer.y,.001f));
  return CirrusOpticalDepth*material*cloud_family_high.x*high_layer.x*cover*appearance.y
      *min(appearance.x,1.f)/max(abs(ray.z),.15f);
}
float CloudCirrusBeam(float3 origin,float3 ray,float footprint) {
  if(cloud_family_high.y<=0.f)return 0.f;
  return CloudCirrusTau(origin,ray,footprint)*cloud_family_high.y;
}
#endif
