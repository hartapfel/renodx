// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_CLOUD_COMMON
#define CLASSIC_CLOUD_COMMON
#include "../volumetrics/math.hlsli"
#include "../night_sky.hlsli"
cbuffer Frame : register(b0) { float4 frame[269]; }
cbuffer Lighting : register(b1) { float4 light[2]; }
cbuffer Parameters : register(b2) {
  float4 dimensions; // low width/height, active render width/height
  float4 integration; // view samples, light samples, jitter index, history valid
  float4 appearance; // coverage, optical density, horizontal size, layer thickness
  float4 atmosphere; // native sky density scale; remaining lanes reserved
  float4 scattering; // multiple scattering, erosion octaves, air samples, noise size
}
cbuffer Previous : register(b3) { float4 previous[269]; }
// Native b0[0].x also animates Classic's cloud material UVs. The pipeline
// retains that GPU buffer in its isolated state; no CPU readback/time guessing.
cbuffer CloudClock : register(b5) { float4 cloud_clock; }
cbuffer PreviousCloudClock : register(b6) { float4 previous_cloud_clock; }
Texture3D<float4> shape_noise : register(t0);
Texture2DArray<float> weather : register(t1);
Texture2D<float> scene_depth : register(t2);
SamplerState wrap_sampler : register(s0);
SamplerState clamp_sampler : register(s1);
static const float PlanetRadius = 6371000.f;
static const float CloudBase = 1200.f;
// Clear-weather native cloud meshes span about 15 km in the captured scene.
// Use kilometre-scale main billows, with independent metre-scale erosion,
// rather than the small smoke-like puffs of the initial 2800 m noise tile.
static const float CloudFormationScale = 7200.f;
float CloudThickness() {return 1200.f*appearance.w;}
// Density is a relative spatial fill fraction, not measured liquid-water
// content. Calibrate its scene-scale extinction for visible billow relief.
static const float Extinction = .016f;

float3 CloudRay(float2 uv) {
  float2 ndc=uv*float2(2,-2)+float2(-1,1);
  float4 p=ndc.x*frame[17]+ndc.y*frame[18]+.5f*frame[19]+frame[20];
  return normalize(p.xyz-frame[0].xyz*p.w);
}
float CloudAltitude(float3 p) {
  // Stable evaluation of length(p + planet_center) - planet_radius.
  float z=PlanetRadius+p.z;
  float r=sqrt(dot(p.xy,p.xy)+z*z);
  return (dot(p.xy,p.xy)+p.z*(2.f*PlanetRadius+p.z))/(r+PlanetRadius);
}
float2 CloudSphere(float3 origin,float3 ray,float height) {
  float3 p=origin+float3(0,0,PlanetRadius);
  float b=dot(p,ray);
  // Avoid subtracting squared planet radii in FP32.
  float c=dot(origin.xy,origin.xy)+(origin.z-height)*(2.f*PlanetRadius+origin.z+height);
  float discriminant=b*b-c;
  if(discriminant<0.f)return float2(-1,-1);
  float root=sqrt(discriminant);
  float q=-b-(b>=0.f ? root : -root);
  float a=q, d=abs(q)>1.e-8f ? c/q : -b+root;
  return float2(min(a,d),max(a,d));
}
float2 CloudInterval(float3 origin,float3 ray) {
  float2 outer=CloudSphere(origin,ray,CloudBase+CloudThickness());
  float2 inner=CloudSphere(origin,ray,CloudBase);
  float altitude=CloudAltitude(origin);
  float start=altitude<CloudBase ? inner.y : max(0.f,outer.x);
  float end=outer.y;
  if(altitude>=CloudBase && inner.x>0.f)end=min(end,inner.x);
  // Ground-view clouds only. The far side of the planet is never a cloud sky.
  if(outer.y<=0.f ||start<0.f)return 0.f;
  return float2(start,min(end,80000.f));
}
float2 CloudWeatherFields(float3 p) {
  uint width,height,layers;
  weather.GetDimensions(width,height,layers);
  if(!width || !layers ||frame[66].x<=0.f)return 0.f;
  // The native distant cloud-shadow field is the weather footprint, including
  // its blended layers and animation. No CPU weather inference/readback.
  // Appearance size changes the billows, never the weather front's position,
  // extent or wind. Scaling both fields made large clouds relocate the rain
  // cover and its scene-wide sunlight attenuation.
  float2 uv=(p.xy+20.f*frame[67].xy)*(.0005f/frame[66].x);
  float2 layer=clamp(trunc(frame[68].xy),0.f,float(layers-1));
  float authored=saturate(lerp(weather.SampleLevel(wrap_sampler,float3(uv,layer.x),0),
      weather.SampleLevel(wrap_sampler,float3(uv,layer.y),0),saturate(frame[66].w)));
  // Below 100% thin the authored coverage; above it fill the remaining gaps.
  // The neutral point is exactly the previous weather-driven coverage.
  return float2(authored,appearance.x<=1.f ? authored*appearance.x : lerp(authored,1.f,appearance.x-1.f));
}
float CloudWeather(float3 p) {return CloudWeatherFields(p).y;}
// Detail is the number of edge-erosion bands. Zero is a conservative coarse
// bound; one is used for nearby light/shadow rays, more for resolved view detail.
float CloudDensity(float3 p,uint detail,float lod,float footprint=0.f) {
  float height=(CloudAltitude(p)-CloudBase)/CloudThickness();
  if(height<=0.f ||height>=1.f)return 0.f;
  float2 weather_fields=CloudWeatherFields(p);
  float coverage=weather_fields.y;
  if(coverage<.002f)return 0.f;
  float3 advected=p+float3(20.f*frame[67].xy,0);
  float4 column=shape_noise.SampleLevel(wrap_sampler,
      float3(advected.xy/(CloudFormationScale*appearance.z),.375f),lod);
  // Use unadjusted weather for the profile: Coverage must only fill gaps,
  // never change the cloud type or move the weather front. This is a coherent
  // procedural profile, not an inference of meteorological cloud species.
  float type=saturate(1.15f-.75f*weather_fields.x+.5f*(column.a-.5f));
  float top=lerp(.4f,1.f,type)*lerp(.6f,1.f,saturate(column.g*1.8f));
  float profile=smoothstep(0.f,.045f,height)*(1.f-smoothstep(top*.6f,top,height));
  if(profile<=0.f)return 0.f;
  // Slow vertical evolution and column-coherent shear preserve the formation
  // while its billows turn over. Fine erosion evolves at a separate rate.
  advected.z+=cloud_clock.x*.6f;
  advected.xy+=(column.gb-.5f)*(140.f*height*height);
  float4 body=shape_noise.SampleLevel(wrap_sampler,
      advected/float3(CloudFormationScale*appearance.zz,2800.f),lod);
  // Intermediate billows must alter the whole isodensity surface, not merely
  // sprinkle fine noise onto its edge. Their scale bridges formations and wisps.
  float billow_scale=2200.f*sqrt(appearance.z);
  float billow_lod=max(0.f,log2(max(footprint*scattering.w/min(billow_scale,1400.f),1.f)));
  float billows=shape_noise.SampleLevel(wrap_sampler,advected/float3(billow_scale,billow_scale,1400.f),billow_lod).g;
  billows=saturate(.5f+2.2f*(billows-.45f));
  // Nested billows belong to the density boundary, including inside a large
  // formation. Edge-only subtraction left opaque puffs with smooth surfaces.
  // Nubis' dimensional-profile/up-rez hierarchy: coherent intermediate lobes
  // deform the whole mass; the finer erosion below breaks up their boundaries.
  // The same field is used by view rays and shadow rays. It is world-space,
  // wind-advected and footprint-filtered, never a screen-space noise overlay.
  float structure_scale=900.f*sqrt(appearance.z);
  float structure_lod=max(0.f,log2(max(footprint*scattering.w/structure_scale,1.f)));
  float3 structure_position=advected/structure_scale+(body.gba-.5f)*.2f;
  float4 structure=shape_noise.SampleLevel(wrap_sampler,structure_position,structure_lod);
  float potential=saturate(.5f+.6f*(body.r-.5f)+.45f*(column.r-.5f)+.8f*(billows-.5f));
  // Profile participates in the isodensity boundary. Multiplying it only
  // after thresholding produced uniformly fading blobs rather than bases/tops.
  float shape=(potential*profile-(1.f-coverage))/max(coverage,.01f);
  // Keep the parent mass in charge of connectivity. Up-rez its surface and
  // interior, rather than allowing fine positive noise to seed detached puffs
  // throughout the layer. Broad, bounded modulation retains the cloud envelope
  // and leaves progressively smaller erosion to the existing detail hierarchy.
  shape=saturate(shape+smoothstep(-.2f,.3f,shape)
      *(.4f*(structure.r-.5f)+.32f*(structure.g-.4f)));
  if(detail>0 &&shape>0.f) {
    float3 edge=advected+float3((body.gb-.5f)*80.f,cloud_clock.x*1.1f);
    float detail_lod=max(0.f,log2(max(footprint*scattering.w/1400.f,1.f)));
    float billow=type*smoothstep(.08f,.55f,height/max(top,.01f));
    float noise=shape_noise.SampleLevel(wrap_sampler,edge/1400.f,detail_lod).b;
    float erosion=.28f*lerp(noise,1.f-noise,billow);
    shape=saturate((shape-erosion)/max(1.f-erosion,.01f));
    if(detail>=2) {
      noise=shape_noise.SampleLevel(wrap_sampler,edge/466.66667f,detail_lod+1.5849625f).b;
      erosion=.12f*lerp(noise,1.f-noise,billow);
      shape=saturate((shape-erosion)/max(1.f-erosion,.01f));
    }
    if(detail>=3) {
      noise=shape_noise.SampleLevel(wrap_sampler,edge/155.55556f,detail_lod+3.169925f).b;
      erosion=.06f*lerp(noise,1.f-noise,billow);
      shape=saturate((shape-erosion)/max(1.f-erosion,.01f));
    }
  }
  return shape*appearance.y;
}
float3 CloudSky(float3 ray) {
  // The broad native sky lobes, before stars and sun/moon discs. These are
  // linear scene radiance, not the authored lit/shadow cloud-card colors.
  float2 horizontal=ray.xy/max(length(ray.xy),.0001f);
  float2 sun=frame[203].yz/max(length(frame[203].yz),.0001f);
  float2 moon=frame[204].yz/max(length(frame[204].yz),.0001f);
  float3 sun_horizon=lerp(frame[197].rgb,frame[196].rgb,dot(sun,horizontal)*.5f+.5f);
  float3 moon_horizon=lerp(frame[200].rgb,frame[199].rgb,dot(moon,horizontal)*.5f+.5f);
  float horizon=1.f-ray.z*ray.z;
  float3 color=lerp(frame[195].rgb,moon_horizon,horizon*saturate(frame[205].y));
  color=lerp(color,sun_horizon,horizon*saturate(frame[205].x));
  float altitude=(ray.z*1000.f+frame[0].z+710.f)*frame[202].z*.001f+.1f;
  color=lerp(color,frame[194].rgb,1.f-pow(min(1.f,rcp(max(altitude,.0001f))),2.8f));
  return max(color*frame[202].x*frame[202].y,0.f);
}
float CloudSceneDistance(float2 pixel,float3 ray) {
  uint width,height;scene_depth.GetDimensions(width,height);
  uint2 location=min(uint2(pixel),uint2(width-1,height-1));
  float z=scene_depth.Load(int3(location,0))*frame[22].x+frame[22].y;
  if(z>=.999999f)return 1.e9f;
  float4 p=(pixel/dimensions.zw*float2(2,-2)+float2(-1,1)).x*frame[17]
      +(pixel/dimensions.zw*float2(2,-2)+float2(-1,1)).y*frame[18]+z*frame[19]+frame[20];
  if(abs(p.w)<1.e-8f)return 1.e9f;
  return max(0.f,dot(p.xyz/p.w-frame[0].xyz,ray));
}
#endif
