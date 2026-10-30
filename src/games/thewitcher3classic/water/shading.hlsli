// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_WATER_SHADING
#define CLASSIC_WATER_SHADING
#include "math.hlsli"
#include "../night_sky.hlsli"
#include "../volumetrics/sample.hlsli"
#include "../volumetrics/math.hlsli"
StructuredBuffer<float4> ClassicWaterFrame : register(t113);
Texture2D<float4> ClassicWaterScene : register(t114);
StructuredBuffer<float4> ClassicWaterParameters : register(t115);
SamplerState ClassicWaterSampler : register(s12);
bool ClassicWaterReady() {
  uint count,stride;
  ClassicWaterParameters.GetDimensions(count,stride);
  return count==1 && ClassicWaterParameters[0].w==1.f;
}
float3 WaterWorldPosition(int2 pixel,float depth) {
  // Captured native reverse-depth pixel-to-world matrix; integer coordinates
  // match the game's reconstruction, including the active DLSS jitter.
  float4 world=ClassicWaterFrame[210]*pixel.x+ClassicWaterFrame[211]*pixel.y
      +ClassicWaterFrame[212]*depth+ClassicWaterFrame[213];
  return world.xyz/max(world.w,1.e-7f);
}
float3 WaterProject(float3 world) {
  float4 view=world.x*ClassicWaterFrame[1]+world.y*ClassicWaterFrame[2]
      +world.z*ClassicWaterFrame[3]+ClassicWaterFrame[4];
  float4 clip=view.x*ClassicWaterFrame[13]+view.y*ClassicWaterFrame[14]
      +view.z*ClassicWaterFrame[15]+ClassicWaterFrame[16];
  return float3((clip.xy/max(clip.w,1.e-5f))*float2(.5f,-.5f)+.5f,clip.w);
}
// Perspective-correct screen-space traversal: interpolate reciprocal clip W,
// and distance/W, along the projected segment (McGuire/Mara 2014). Bounded
// stride and five refinements keep cost predictable. This is a single-depth
// approximation: missing/off-screen geometry falls back to unshifted color.
float4 WaterRefraction(Texture2D<float4> depth_texture,float4 position,
    float3 world,float3 ray,float3 extinction) {
  float2 extent=ClassicWaterParameters[0].xy;
  int2 pixel=clamp(int2(position.xy),0,int2(extent)-1);
  float original_depth=depth_texture.Load(int3(pixel,0)).x;
  float3 bottom=WaterWorldPosition(pixel,original_depth);
  float max_distance=min(200.f,6.907755f/max(.001f,min(extinction.x,min(extinction.y,extinction.z))));
  float fallback_distance=original_depth>1.e-7f ? clamp(dot(bottom-world,normalize(world-ClassicWaterFrame[0].xyz)),0.f,max_distance) : max_distance;
  float3 fallback=ClassicWaterScene.SampleLevel(ClassicWaterSampler,(float2(pixel)+.5f)/extent,0).rgb
      *WaterTransmittance(extinction,fallback_distance);
  if(original_depth<=1.e-7f) fallback=0.f;
  float3 start=WaterProject(world);
  float3 end=WaterProject(world+ray*max_distance);
  if(end.z<.1f) {
    max_distance*=saturate((start.z-.1f)/max(1.e-5f,start.z-end.z));
    end=WaterProject(world+ray*max_distance);
  }
  float2 delta=(end.xy-start.xy)*extent;
  uint steps=(uint)clamp(ceil(max(abs(delta.x),abs(delta.y))),1.f,16.f);
  float2 inverse_w=rcp(max(float2(start.z,end.z),.1f));
  float low=0.f,high=0.f;
  bool hit=false;
  [loop] for(uint i=1;i<=16;++i) {
    if(i>steps) break;
    float t=float(i)/float(steps);
    float2 uv=lerp(start.xy,end.xy,t);
    if(any(uv<.5f/extent) || any(uv>(extent-.5f)/extent)) { break; }
    int2 sample_pixel=int2(uv*extent);
    float depth=depth_texture.Load(int3(sample_pixel,0)).x;
    float scene_z=rcp(max(1.e-7f,(depth*ClassicWaterFrame[22].x+ClassicWaterFrame[22].y)
        *ClassicWaterFrame[21].x+ClassicWaterFrame[21].y));
    float ray_z=rcp(lerp(inverse_w.x,inverse_w.y,t));
    if(depth>1.e-7f && scene_z>=start.z-.02f && ray_z>=scene_z) { high=t;hit=true;break; }
    low=t;
  }
  float4 result=float4(fallback,fallback_distance);
  if(hit) {
    [unroll] for(uint refine=0;refine<5;++refine) {
      float t=.5f*(low+high);
      int2 sample_pixel=clamp(int2(lerp(start.xy,end.xy,t)*extent),0,int2(extent)-1);
      float depth=depth_texture.Load(int3(sample_pixel,0)).x;
      float scene_z=rcp(max(1.e-7f,(depth*ClassicWaterFrame[22].x+ClassicWaterFrame[22].y)
          *ClassicWaterFrame[21].x+ClassicWaterFrame[21].y));
      if(rcp(lerp(inverse_w.x,inverse_w.y,t))>=scene_z) high=t; else low=t;
    }
    float2 uv=lerp(start.xy,end.xy,high);
    int2 sample_pixel=clamp(int2(uv*extent),0,int2(extent)-1);
    float depth=depth_texture.Load(int3(sample_pixel,0)).x;
    float scene_z=rcp(max(1.e-7f,(depth*ClassicWaterFrame[22].x+ClassicWaterFrame[22].y)
        *ClassicWaterFrame[21].x+ClassicWaterFrame[21].y));
    // Solve the last sampled depth plane exactly inside the refined bracket.
    // This avoids quantizing optical thickness to the binary-search step size.
    if(abs(inverse_w.y-inverse_w.x)>1.e-7f)
      high=clamp((rcp(scene_z)-inverse_w.x)/(inverse_w.y-inverse_w.x),low,high);
    uv=lerp(start.xy,end.xy,high);
    sample_pixel=clamp(int2(uv*extent),0,int2(extent)-1);
    depth=depth_texture.Load(int3(sample_pixel,0)).x;
    scene_z=rcp(max(1.e-7f,(depth*ClassicWaterFrame[22].x+ClassicWaterFrame[22].y)
        *ClassicWaterFrame[21].x+ClassicWaterFrame[21].y));
    float3 hit_world=WaterWorldPosition(sample_pixel,depth);
    float ray_z=rcp(lerp(inverse_w.x,inverse_w.y,high));
    float distance=high*max_distance*inverse_w.y*ray_z;
    float confidence=1.f-smoothstep(.02f,max(.04f,.005f*scene_z),abs(ray_z-scene_z));
    float2 edge=min(uv,1.f-uv)*extent;
    confidence*=saturate(min(edge.x,edge.y)/2.f);
    if(hit_world.z>world.z+.02f || depth<=1.e-7f) confidence=0.f;
    float3 color=ClassicWaterScene.SampleLevel(ClassicWaterSampler,uv,0).rgb
        *WaterTransmittance(extinction,distance);
    result=float4(lerp(fallback,color,confidence),lerp(fallback_distance,distance,confidence));
  }
  // Missing screen-space geometry is not evidence of deep water. Preserve the
  // unshifted background and its measured path length, especially at shores.
  return result;
}
// Single-layer homogeneous water. Returns the base contribution and LINEAR
// reflection weight. The native SSR compositor squares its mask; the caller
// encodes sqrt(weight) there. Both captured paths use that native compositor.
float4 ShadeClassicWater(Texture2D<float4> depth_texture, float4 position,
    float3 world, float3 normal, float3 sun_direction, float3 sun_color,
    float visibility, float3 ambient_radiance, float foam, float4 native_fog) {
  float3 view=normalize(ClassicWaterFrame[0].xyz-world);
  normal=normalize(normal);
  float3 ray=refract(-view,normal,1.f/1.333f);
  // Three-wavelength RGB approximation of pure-water absorption (650/550/450 nm,
  // NASA Ocean Optics protocols, Pope/Fry), m^-1, plus neutral suspended matter.
  // This is a tunable material, not a measured spectral model of this river.
  float clarity=max(.25f,ClassicWaterParameters[0].z);
  float3 absorption=float3(.3594f,.0654f,.0110f);
  float3 scattering=float3(.0007f,.0014f,.0033f)+rcp(2.f*clarity);
  float3 extinction=absorption+scattering;
  float4 transmitted=WaterRefraction(depth_texture,position,world,ray,extinction);
  float3 light=normalize(sun_direction);
  float3 sunlight=max(sun_color,0.f)*saturate(visibility);
  if(ClassicFogReady()) {
    // Camera-to-water attenuation is applied at the end. This is the other leg:
    // light crossing the introduced local height-fog medium before reaching water.
    sunlight*=FogLightTransmittance(world.z+ClassicWaterFrame[42].y,light.z,
        max(ClassicWaterFrame[43].x,0.f)*ClassicFogParameters[1].x,
        max(0.f,.5f*(ClassicWaterFrame[43].y+ClassicWaterFrame[43].z))*ClassicFogParameters[2].x,
        min(ClassicFogParameters[0].w,1000.f));
  }
  // Use the WATER lighting input, not the atmospheric fog source color. The
  // latter is a bright in-scattering source and is not surface illumination.
  float3 ambient=max(ambient_radiance,0.f)*ClassicWaterAmbient(asuint(ClassicWaterFrame[38].w));
  float3 light_in_water=refract(-light,float3(0,0,1),1.f/1.333f);
  float g=.5f;
  float phase=(1.f-g*g)/(12.56637061f*pow(max(.01f,1.f+g*g-2.f*g*dot(-ray,light_in_water)),1.5f));
  float3 sun_extinction=extinction*(1.f+max(0.f,-ray.z)/max(.05f,-light_in_water.z));
  float3 scattered=scattering*(ambient*WaterScatterIntegral(extinction,transmitted.w)
      +sunlight*phase*(1.f-WaterFresnel(saturate(light.z)))*WaterScatterIntegral(sun_extinction,transmitted.w));
  float fresnel=WaterFresnel(saturate(dot(normal,view)));
  // Filter unresolved normal variance into the direct-light microfacet width.
  float3 dx=ddx(normal),dy=ddy(normal);
  float alpha=sqrt(clamp(.01f+dot(dx,dx)+dot(dy,dy),.01f,1.f));
  float3 surface=(1.f-fresnel)*(transmitted.rgb+scattered)
      +sunlight*WaterSpecular(normal,view,light,alpha);
  foam=saturate(foam);
  surface=lerp(surface,.9f*(ambient+sunlight*saturate(normal.z)/3.141592654f),foam);
  int2 pixel=clamp(int2(position.xy),0,int2(ClassicWaterParameters[0].xy)-1);
  float opaque_depth=depth_texture.Load(int3(pixel,0)).x;
  float gap=dot(WaterWorldPosition(pixel,opaque_depth)-world,-view);
  // Resolve subpixel intersections over 5 cm rather than shading a full water
  // interface over foreground terrain. This affects contact coverage, not IOR.
  float coverage=opaque_depth>1.e-7f ? smoothstep(0.f,.05f,gap) : 1.f;
  surface=lerp(ClassicWaterScene.Load(int3(pixel,0)).rgb,surface,coverage);
  float4 air=ClassicFogReady() ? SampleClassicFogPixel(position)
      : float4(native_fog.rgb*saturate(native_fog.a),1.f-saturate(native_fog.a));
  return float4(min(max(surface*air.a+air.rgb,0.f),60000.f),fresnel*(1.f-foam)*air.a*coverage);
}
#endif
