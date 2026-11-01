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
  float4 atmosphere; // sky-haze density, detail strength, detail size, base softness
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
float CloudDetailScale() {return 1200.f*max(atmosphere.z,.2f);}
float CloudBaseReliefScale() {return CloudDetailScale()*saturate(atmosphere.y)*lerp(.25f,1.f,atmosphere.w);}
float CloudMinimum() {return CloudBase-.16f*CloudBaseReliefScale();}
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
  float2 inner=CloudSphere(origin,ray,CloudMinimum());
  float altitude=CloudAltitude(origin);
  float start=altitude<CloudMinimum() ? inner.y : max(0.f,outer.x);
  float end=outer.y;
  if(altitude>=CloudMinimum() && inner.x>0.f)end=min(end,inner.x);
  // Ground-view clouds only. The far side of the planet is never a cloud sky.
  if(outer.y<=0.f ||start<0.f)return 0.f;
  return float2(start,min(end,80000.f));
}
float CloudWeather(float3 p) {
  uint width,height,layers;
  weather.GetDimensions(width,height,layers);
  if(!width || !layers ||frame[66].x<=0.f)return 0.f;
  // The prefiltered native shadow field supplies broad weather coverage.
  // Its layers are already blended and temporally faded by the shared prepass.
  // No CPU weather inference/readback.
  // Appearance size changes the billows, never the weather front's position,
  // extent or wind. Scaling both fields made large clouds relocate the rain
  // cover and its scene-wide sunlight attenuation.
  float2 uv=(p.xy+20.f*frame[67].xy)*(.0005f/frame[66].x);
  float authored=saturate(weather.SampleLevel(wrap_sampler,float3(uv,0),0));
  // Below 100% thin the authored coverage; above it fill the remaining gaps.
  // The neutral point is exactly the previous weather-driven coverage.
  return appearance.x<=1.f ? authored*appearance.x : lerp(authored,1.f,appearance.x-1.f);
}
// Detail is the number of edge-erosion bands. Zero is a conservative coarse
// bound; one is used for nearby light/shadow rays, more for resolved view detail.
float CloudDensity(float3 p,uint detail,float lod,float footprint=0.f) {
  float height=(CloudAltitude(p)-CloudBase)/CloudThickness();
  if(height<=-.16f*CloudBaseReliefScale()/CloudThickness() ||height>=1.f)return 0.f;
  float coverage=CloudWeather(p);
  if(coverage<.002f)return 0.f;
  float3 advected=p+float3(20.f*frame[67].xy,0);
  float4 column=shape_noise.SampleLevel(wrap_sampler,
      float3(advected.xy/(CloudFormationScale*appearance.z),.375f),lod);
  // Shadow opacity is not cloud species/height. Inferring height inversely
  // from local cover raised thin edges above their cores, producing curtains
  // and making a fading weather mask grow taller. Use a coherent formation
  // profile; coverage changes only the fill, never the vertical envelope.
  float type=.4f+.5f*column.r;
  float top=lerp(.45f,1.f,type)*lerp(.7f,1.f,saturate(column.r*1.6f));
  float relative_height=height/max(top,.01f);
  if(relative_height>=1.f)return 0.f;
  // Slow vertical evolution and column-coherent shear preserve the formation
  // while its billows turn over. All detail uses the same bulk evolution rate
  // as cloud motion/reprojection; unmatched detail scrolling causes smearing.
  advected.z+=cloud_clock.x*.6f;
  advected.xy+=(column.gb-.5f)*(140.f*height*height);
  float4 body=shape_noise.SampleLevel(wrap_sampler,
      advected/float3(CloudFormationScale*appearance.zz,2800.f),lod);
  // A dimensional envelope keeps coverage/connectivity separate from erosion.
  // Unlike the previous weighted average of three narrow-range fields, the
  // full formation range remains available for nested structures at high density.
  float scale=CloudDetailScale();
  float3 edge=advected+float3((body.ga-.5f)*100.f,0);
  float detail_lod=max(0.f,log2(max(footprint*scattering.w/scale,1.f)));
  float4 features=shape_noise.SampleLevel(wrap_sampler,edge/scale,detail_lod);
  float4 finer=0.f,finest=0.f;
  if(detail>=2u)finer=shape_noise.SampleLevel(wrap_sampler,edge/scale*2.73f+float3(.31f,.73f,.19f),detail_lod+1.4489f);
  if(detail>=3u)finest=shape_noise.SampleLevel(wrap_sampler,edge/scale*7.91f+float3(.67f,.11f,.43f),detail_lod+2.9837f);
  // The base envelope also needs substructure: with a perfectly planar base,
  // opaque clouds hide their internal noise regardless of pixel resolution.
  // Nested lobes perturb the local envelope within the fixed layer bounds.
  // Signed lower-envelope relief forms hanging billows as well as cavities.
  // The old strictly positive erosion could only eat upward into a flat floor.
  float bottom_relief=.22f*(.5f-features.g)+.1f*(.5f-features.b);
  float top_relief=.13f*(1.f-features.g)+.055f*(1.f-features.b);
  if(detail>=2u) {
    bottom_relief+=.04f*(1.f-finer.g);top_relief+=.04f*(1.f-finer.g);
  }
  if(detail>=3u) {
    bottom_relief+=.016f*(1.f-finest.g);top_relief+=.016f*(1.f-finest.g);
  }
  // Keep small structures in metres when Layer Thickness changes; otherwise
  // thick storm layers stretch the same detail into enormous rounded slabs.
  bottom_relief*=CloudBaseReliefScale()/CloudThickness();
  top_relief*=saturate(atmosphere.y)*scale/CloudThickness();
  float profile=smoothstep(bottom_relief,bottom_relief+lerp(35.f,130.f,atmosphere.w)/CloudThickness(),height)
      *(1.f-smoothstep(.55f,1.f,relative_height+top_relief*.5f));
  float potential=saturate(.3f+.9f*body.r+.2f*(column.r-.5f));
  float shape=saturate((potential*profile-(1.f-coverage))/max(coverage,.01f));
  if(detail>0 &&shape>0.f &&atmosphere.y>0.f) {
    // Detail has its own physical scale: making formations wider must not
    // inflate every small billow. Warp is coherent within a parent formation.
    // Nest fine billows in coarser ones. Upper growing regions retain rounded
    // lobes; lower/less dense regions dissipate into wisps (Nubis 2023).
    float billowy=lerp(.65f,1.f,type)*lerp(1.f-.25f*atmosphere.w,1.f,smoothstep(.04f,.45f,relative_height));
    // Use the parent potential for scale selection, so adding a finer band
    // cannot reduce an earlier band's erosion and violate the coarse bound.
    float billows=1.f-lerp(features.g,features.b,.6f+sqrt(potential)*.25f);
    float wisps=abs(2.f*features.a-1.f);
    float erosion=.85f*lerp(wisps,billows,billowy);
    if(detail>=2) {
      erosion=1.f-(1.f-erosion)*(1.f-.18f*lerp(abs(2.f*finer.a-1.f),1.f-finer.b,billowy));
    }
    if(detail>=3) {
      erosion=1.f-(1.f-erosion)*(1.f-.08f*lerp(abs(2.f*finest.a-1.f),1.f-finest.b,billowy));
    }
    // Bounded value erosion cannot add detached fragments outside the parent
    // mass. Fine<=coarse is retained for conservative bounds. Density only
    // scales optical depth after all structural detail has been formed.
    // Compose erosion as transmission. Hard-clamping a multiplied strength
    // flattened its variation at 200%, producing terraces instead of detail.
    float retained=pow(max(1.f-erosion,1.e-4f),atmosphere.y
        *lerp(1.f+.5f*atmosphere.w,1.f,smoothstep(0.f,.45f,relative_height)));
    shape=saturate((shape-(1.f-retained))/max(retained,1.e-4f));
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
