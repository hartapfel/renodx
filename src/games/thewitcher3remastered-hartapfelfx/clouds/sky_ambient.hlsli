// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_SKY_AMBIENT
#define HARTAPFEL_CLOUD_SKY_AMBIENT
#include "common.hlsli"
// Hemispherical sky reduction before cloud scattering. The native broad sky
// excludes sun/moon sprites; one quarter of the weighted samples favor the
// current directional emitter, as in Bauer et al. 2019.
float3 CloudSkyAmbientSample(uint sample) {
  const float golden_angle=2.39996323f;
  float3 sun_direction=normalize(light[0].xyz+float3(0,0,1.e-8f));
  sun_direction=normalize(float3(sun_direction.xy,max(sun_direction.z,.05f)));
  float3 tangent=normalize(cross(sun_direction,abs(sun_direction.z)<.9f
      ?float3(0,0,1):float3(0,1,0)));
  float3 bitangent=cross(sun_direction,tangent);
  float z=(sample+.5f)/64.f;
  float angle=golden_angle*sample;
  float3 ray=float3(sqrt(max(0.f,1.f-z*z))*float2(cos(angle),sin(angle)),z);
  float3 ambient=(.375f/64.f)*CloudSky(ray);
  if(sample<16u) {
    float radius=.6f*sqrt((sample+.5f)/16.f);
    ambient+=(.125f/16.f)*CloudSky(normalize(sun_direction+radius
        *(tangent*cos(angle)+bitangent*sin(angle))));
  }
  return ambient;
}
float3 CloudSkyAmbient() {
  float3 ambient=0.f;
  [unroll]for(uint sample=0u;sample<64u;++sample)
    ambient+=CloudSkyAmbientSample(sample);
  return max(ambient,0.f);
}
#endif
