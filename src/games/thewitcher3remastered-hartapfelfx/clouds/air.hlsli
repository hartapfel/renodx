// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_AIR
#define HARTAPFEL_CLOUD_AIR
#include "common.hlsli"
#include "../sky/lighting.hlsli"
float CloudAirTransmission(float3 ray,float distance) {
  float directional=saturate((frame[42].x+dot(ray,SkyAtmosphereLight(frame[204].yzw,
      frame[205].yzw,frame[38].xyz)))/max(1.f+frame[42].x,.0001f));
  float falloff=max(0.f,lerp(frame[44].z,frame[44].y,directional));
  // Native HDR sky 0x449D3390 integrates this rational height profile in 16
  // segments. Its finite sky distance and sample positions define the
  // foreground-air factor used by cloud and sun-disc compositing.
  float segment=min(max(distance,0.f),max(frame[42].z,0.f))*(1.f/16.f);
  float height=frame[42].y+frame[0].z+ray.z*frame[22].z;
  float transmission=1.f;
  [unroll]for(uint index=1u;index<=16u;++index) {
    float scaled=max(0.f,falloff*(height+ray.z*segment*index));
    transmission*=1.f-saturate(segment*max(frame[44].x,0.f)/(1.f+scaled));
  }
  return atmosphere.x<=0.f ? 1.f : pow(saturate(transmission),atmosphere.x);
}
#endif
