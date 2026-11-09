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
  if(sample==0u) {
    // A sparse hemisphere misses the small, intensely coloured aureole. Its
    // native cos^p lobe has exact solid-angle integral 2*pi/(p+1). Reduce it
    // analytically into the same diffuse-sky quadrature, without a noisy ray.
    uint bits=asuint(frame[206].w);
    float size=(bits&0x80000000u)?max(float(bits&65535u)/8192.f,.01f):1.f;
    float exponent=max(frame[204].x*size*size,1.f);
    float gain=max(frame[203].x*frame[203].y,0.f)
        *(asuint(private_sky[6].y)==2u?1.f:max(frame[203].w,0.f));
    float height=max(CloudBase+1200.f*appearance.w,0.f);
    float horizon=sqrt(saturate(1.f-pow(PlanetRadius/(PlanetRadius+height),2.f)));
    float visibility=smoothstep(-.005f,.005f,normalize(frame[204].yzw+float3(0,0,1.e-8f)).z+horizon);
    ambient+=MatchLightSpectrum(max(frame[199].rgb,0.f),emission_sun)
        *(.375f*gain*saturate(frame[206].x)*visibility/(exponent+1.f));
    float moon_visibility=smoothstep(-.005f,.005f,normalize(frame[205].yzw+float3(0,0,1.e-8f)).z+horizon);
    float phase=frac(cloud_clock.y*.033863864839076996f+cloud_clock.w)*6.28318530718f;
    float lit=saturate((1.f-dot(float3(cos(phase),sin(phase),0),normalize(frame[205].yzw+float3(0,0,1.e-8f))))*.5f);
    ambient+=MatchLightSpectrum(max(frame[202].rgb,0.f),emission_moon)
        *(.375f*gain*saturate(frame[206].y)*moon_visibility*pow(lit,1.5f)/(max(frame[205].x,1.f)+1.f));
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
