// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_INTEGRATION
#define HARTAPFEL_CLOUD_INTEGRATION
#include "common.hlsli"
#include "air.hlsli"
#include "lighting.hlsli"
#include "fast_sample.hlsli"
#include "../night/lighting/common.hlsli"
Texture3D<float> cloud_samples : register(t7);
Texture3D<float> light_visibility : register(t12);
Texture3D<float4> sky_air : register(t15);
// Shared scene-linear radiance, Beer transmission and weighted depth. A far
// environment ray can use a coarser physical step without changing the material.
float4 TraceCloud(float3 origin,float3 ray,float2 interval,float cone,uint2 id,
    uint sample_budget,float step_limit,out float depth) {
  // A bounded physical step keeps thin cloud edges represented on grazing
  // rays. An empty-space coarse march missed sub-kilometre cloud material and
  // introduced speckle in the direct A/B capture, so every segment is tested.
  uint view_samples=min(sample_budget,max((uint)integration.x,(uint)ceil((interval.y-interval.x)/step_limit)));
  float step=(interval.y-interval.x)/view_samples;
  // Keep the longitudinal integration phase stable. Independent phase changes
  // every frame made cloud-edge opacity flicker with fixed camera and weather.
  float random=FastSample(cloud_samples,id.xy,0u,0u);
  float3 direction=CloudLightingDirection();
  float3 light_tangent=normalize(cross(direction,abs(direction.z)<.9f?float3(0,0,1):float3(0,1,0)));
  float3 light_bitangent=cross(direction,light_tangent);
  float phase_cosine=dot(ray,direction);
  float3 ambient=light[2].rgb;
  float3 radiance=0.f;
  float transmission=1.f,weighted_depth=0.f,weight=0.f;
  float t=interval.x;
  float preceding_density=0.f;
  [loop]for(uint i=0;i<view_samples &&t<interval.y &&transmission>1.e-8f;++i) {
    float segment=step;
    float sample_t=t+random*step;
    float3 p=origin+ray*sample_t;
    // Filter the transverse pixel footprint. The quadrature interval is along
    // the ray; using it as an isotropic texture footprint blurred cloud shapes
    // even when the image resolution increased. Depth jitter handles sampling
    // along the ray, with Step Size providing explicit integration control.
    float footprint=max(sample_t*cone,1.f);
    float lod=clamp(log2(max(footprint*scattering.w/min(CloudFormationScale*appearance.z,2800.f),1.f)),0.f,4.f);
    float sample_density=CloudDensity(p,(uint)scattering.y,lod,footprint);
    // Resolve the first and last occupied segments with two-point quadrature.
    // A midpoint alone turns a finite cloud edge into one entire ray step and
    // leaves visible terraces. Dense interiors keep one sample, so the extra
    // texture work is concentrated where the integration error is largest.
    if((sample_density>0.f && sample_density<appearance.y*.18f)
        ||(sample_density<=0.f && preceding_density>0.f)) {
      sample_density=.5f*(CloudDensity(p-ray*(segment*.288675135f),(uint)scattering.y,lod,footprint)
          +CloudDensity(p+ray*(segment*.288675135f),(uint)scattering.y,lod,footprint));
    }
    preceding_density=sample_density;
    // Direct background radiance obeys Beer attenuation. In-scattered light
    // below supplies a broad glow without copying or blurring the sun disc.
    float sigma=CloudOpticalExtinction*sample_density;
    if(sigma>0.f) {
      float opacity=SegmentOpacity(sigma*segment);
      float contribution=transmission*opacity;
      // Keep integrating extinction after expensive lighting becomes negligible.
      // A 0.5% transmission floor leaks a visible HDR sun through opaque clouds.
      if(transmission>.005f) {
        float tau=0.f;
        uint volume_width,volume_height,volume_depth;
        light_visibility.GetDimensions(volume_width,volume_height,volume_depth);
        float cell=32000.f/volume_width;
        float2 center=floor(frame[0].xy/cell+.5f)*cell;
        float2 volume_uv=(p.xy-center)/32000.f+.5f;
        float volume_top=CloudBase+CloudThickness();
        float2 margin=(volume_top-p.z)*abs(direction.xy)/max(direction.z,.015f)/32000.f+.01f;
        bool in_volume=direction.z>.15f &&all(volume_uv>margin)&&all(volume_uv<1.f-margin)
            &&p.z>=CloudMinimum()&&p.z<=volume_top;
        float boundary=min(min(volume_uv.x-margin.x,volume_uv.y-margin.y),
            min(1.f-margin.x-volume_uv.x,1.f-margin.y-volume_uv.y));
        float volume_weight=in_volume?smoothstep(0.f,.03f,boundary):0.f;
        if(volume_weight>0.f) {
          tau=light_visibility.SampleLevel(clamp_sampler,float3(volume_uv,
              (p.z-CloudMinimum())/(volume_top-CloudMinimum())),0);
        }
        if(volume_weight<1.f) {
          // Outside the camera's world-anchored visibility volume, retain a
          // bounded secondary ray instead of sampling an unrelated edge cell.
          float2 light_interval=CloudInterval(p,direction);
          float light_distance=max(light_interval.y,0.f);
          float light_scale=log2(1.f+light_distance/24.f);
          uint light_pairs=max(2u,((uint)integration.y+1u)/2u);
          float fallback_tau=0.f;
          [loop]for(uint j=0;j<light_pairs;++j) {
            float begin=24.f*(exp2(light_scale*j/light_pairs)-1.f);
            float end=24.f*(exp2(light_scale*(j+1.f)/light_pairs)-1.f);
            float beam=max(footprint,(end-begin)*.175f);
            float light_lod=clamp(log2(max(beam*scattering.w/min(CloudFormationScale*appearance.z,2800.f),1.f)),0.f,4.f);
            [unroll]for(uint sample=0;sample<2;++sample) {
              float distance=lerp(begin,end,sample==0u?.211324865f:.788675135f);
              float3 transverse=(j%2u==0u?light_tangent:light_bitangent)
                  *(sample==0u?1.f:-1.f)*min(distance*.035f,80.f);
              fallback_tau+=CloudDensity(p+direction*distance+transverse,j<2u?(uint)scattering.y:1u,light_lod,beam)
                  *CloudOpticalExtinction*(end-begin)*.5f;
            }
          }
          tau=lerp(fallback_tau,tau,volume_weight);
        }
        tau*=illumination.z;
        float direct=CloudDirectScattering(phase_cosine,sigma,tau,illumination.w);
        // Reuse the broad directional cone's visibility for diffuse sky, as
        // in Bauer et al. 2019. Plane-parallel optical depth converts the
        // oblique light path to an approximate zenith column by cos(zenith).
        // This also avoids a second sparse quadrature that drew terraces on
        // opaque cloud undersides at Medium quality.
        float sky_tau=tau*saturate(direction.z);
        float3 source=CloudScatteringAlbedo*(max(light[1].rgb,0.f)*direct*illumination.x
            +ambient*CloudDiffuseTransport(sky_tau,illumination.w).y*illumination.y);
        radiance+=contribution*source;
      }
      weighted_depth+=contribution*sample_t;weight+=contribution;
      transmission*=1.f-opacity;
    }
    t+=segment;
  }
  depth=weight>1.e-5f ? weighted_depth/weight : .5f*(interval.x+interval.y);

  return float4(radiance * WitcherNightCloudMultiplier(frame[185].w), transmission);
}
// Apply the Witcher's aerial perspective once at the trace's weighted depth.
float4 CloudAerialPerspective(float2 uv,float depth,float4 cloud) {
  float4 air=sky_air.SampleLevel(clamp_sampler,
      float3(uv,(saturate(depth/max(frame[42].z,.001f))*31.f+.5f)/32.f),0);
  float air_transmission=air.a;
  float opacity=1.f-cloud.a;
  cloud.rgb*=air_transmission;
  cloud.a=1.f-opacity*air_transmission;
  return cloud;
}
#endif
