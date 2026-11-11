// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_LIGHT_RAY
#define HARTAPFEL_CLOUD_LIGHT_RAY
#include "common.hlsli"
#include "lighting.hlsli"

// Keep the accepted sparse light quadrature in both the experimental cache
// and the exact out-of-volume fallback, instead of changing cloud material.
float CloudLightDepth(float3 p,float3 direction,float footprint) {
  float3 tangent=normalize(cross(direction,abs(direction.z)<.9f?float3(0,0,1):float3(0,1,0)));
  float3 bitangent=cross(direction,tangent);
  float light_distance=max(CloudInterval(p,direction).y,0.f);
  float light_scale=log2(1.f+light_distance/24.f);
  uint pairs=max(2u,((uint)integration.y+1u)/2u);
  float tau=0.f;
  [loop]for(uint j=0u;j<pairs;++j) {
    float begin=24.f*(exp2(light_scale*j/pairs)-1.f);
    float end=24.f*(exp2(light_scale*(j+1.f)/pairs)-1.f);
    float beam=max(footprint,(end-begin)*.175f);
    float lod=clamp(log2(max(beam*scattering.w/min(cloud_formation_period,cloud_vertical_period),1.f)),0.f,4.f);
    [unroll]for(uint sample=0u;sample<2u;++sample) {
      float distance=lerp(begin,end,sample==0u?.211324865f:.788675135f);
      float3 transverse=(j%2u==0u?tangent:bitangent)
          *(sample==0u?1.f:-1.f)*min(distance*.035f,80.f);
      tau+=CloudDensity(p+direction*distance+transverse,j<2u?(uint)scattering.y:1u,lod,beam)
          *CloudOpticalExtinction*(end-begin)*.5f;
    }
  }
  return tau;
}
#endif
