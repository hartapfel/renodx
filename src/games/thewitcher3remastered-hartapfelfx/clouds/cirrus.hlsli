// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_CIRRUS
#define HARTAPFEL_CLOUD_CIRRUS
#include "common.hlsli"
#include "lighting.hlsli"
#include "thin.hlsli"
#include "../night/lighting/common.hlsli"

// A single filtered high-layer lookup, shared by the main sky and the
// environment used by native reflection captures. Input/output are
// premultiplied radiance and Beer transmission.
float4 CloudCirrus(float3 origin,float3 ray,float2 uv,float cone,float4 behind,
    float lower_transmission,bool aerial,out float distance,out float sun_transmission,float surface_distance=1.e9f) {
  distance=0.f;
  sun_transmission=1.f;
  if(lower_transmission<=.001f ||appearance.x<=0.f ||appearance.y<=0.f ||cloud_family_high.x<=0.f ||high_layer.x<=0.f ||high_layer.y<=0.f)return behind;
  float high_t=CloudSphere(origin,ray,CloudCirrusHeight()).y;
  if(high_t<=0.f ||high_t>=surface_distance)return behind;
  if(ray.z<0.f) {
    float2 ground=CloudSphere(origin,ray,0.f);
    if(ground.x>=0.f &&ground.x<high_t)return behind;
  }
  float3 high_p=origin+ray*high_t;
  float high_cover=CloudWeather(high_p);
  high_cover=lerp(high_cover,1.f,saturate(cloud_family_high.y));
  if(high_cover<=.002f)return behind;
  // The generated material has a square atlas. A 24x8 km world mapping
  // stretched its Y features into narrow repeating horizon stripes. Match
  // physical texel size in both axes and filter by that world-space size.
  float period=24000.f*high_layer.z;
  float lod=clamp(log2(max(high_t*cone*512.f/period,1.f)),0.f,9.f);
  float material=cirrus_map.SampleLevel(wrap_sampler,
      (high_p.xy+CloudWindOffset(frame[67].xy))/period,lod);
  material=saturate((material-(1.f-high_layer.y))/max(high_layer.y,.001f));
  material*=cloud_family_high.x*high_layer.x;
  float cirrus_density=high_cover*material*appearance.y;
  cirrus_density*=lerp(1.f,min(appearance.x,1.f),saturate(cloud_family_high.y));
  cirrus_density/=lerp(1.f,max(abs(ray.z),.15f),saturate(cloud_family_high.y));
  float opacity=1.f-exp(-CirrusOpticalDepth*cirrus_density);
  if(opacity<=1.e-6f)return behind;
  sun_transmission=1.f-opacity;
  float3 sun=CloudLightingDirection();
  // The single high-layer lookup represents its vertical optical depth.
  // Mid-layer sunlight traverses half of that column; sky light uses the
  // same two-stream transport as the main view. Its broad sky background is
  // already behind this layer in the final premultiplied composition.
  float sun_tau=.5f*CirrusOpticalDepth*cirrus_density/max(sun.z,.15f)*illumination.z;
  float sigma=CirrusOpticalDepth*cirrus_density/300.f;
  float direct=CloudDirectScattering(dot(ray,sun),sigma,sun_tau,illumination.w);
  float3 source=CloudScatteringAlbedo*(max(light[1].rgb,0.f)*direct*illumination.x
      +light[2].rgb*CloudDiffuseTransport(sun_tau*saturate(sun.z),illumination.w).y*illumination.y);
  float4 layer=float4(opacity * source * WitcherNightCloudMultiplier(frame[185].w), 1.f-opacity);
  // The main viewport needs its foreground atmosphere at the high layer's
  // actual distance. Reflection-atlas consumers apply atmosphere themselves.
  if(aerial)layer=CloudAerialPerspective(uv,high_t,layer);
  // Foreground air fades the lower cloud's blend opacity, but it does not
  // uncover a high cloud behind that lower cloud. Use its un-hazed Beer
  // transmission for both the high radiance and background coverage.
  behind.rgb+=lower_transmission*layer.rgb;
  behind.a=max(behind.a-lower_transmission*(1.f-layer.a),0.f);
  distance=high_t;
  return behind;
}
#endif
