// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_UNDERWATER_INPUTS
#define CLASSIC_UNDERWATER_INPUTS
#include "../water/transport.hlsli"
#include "../water/caustics_config.h"
#include "../water/native_resources.hlsli"
StructuredBuffer<float4> UnderwaterState : register(t88);
StructuredBuffer<float4> UnderwaterFrame : register(t89);
Texture2D<float> UnderwaterCaustics : register(t97);
StructuredBuffer<float4> UnderwaterLight : register(t95);
Texture2DArray<float> UnderwaterShadows : register(t96);
#ifdef CLASSIC_UNDERWATER_COMPOSITE
SamplerComparisonState UnderwaterShadowSampler : register(s12);
#endif
bool UnderwaterReady() {
  uint count,stride;UnderwaterState.GetDimensions(count,stride);
  return count==8 && UnderwaterState[0].w>0.f;
}
float UnderwaterDepth(float3 world) {
  return max(UnderwaterState[1].w-world.z,0.f);
}
float UnderwaterWeight(float3 world) {
  return UnderwaterReady() ? UnderwaterState[0].w*smoothstep(0.f,.1f,UnderwaterDepth(world)):0.f;
}
bool WaterOpticsReady() {
  uint count,stride;UnderwaterState.GetDimensions(count,stride);
  return count==8 && UnderwaterState[3].w>0.f;
}
// Explicit bilinear loads preserve every native material sampler, including
// comparison samplers. Both native height arrays use clamped normalized UVs.
float2 WaterHeightSample(Texture2DArray<float> height_map,float2 uv,uint layer) {
  uint width,height,layers;height_map.GetDimensions(width,height,layers);
  float2 p=saturate(uv)*float2(width,height)-.5f;
  int2 cell=int2(floor(p)),limit=int2(width,height)-1;float2 f=frac(p);
  float4 heights=float4(height_map.Load(int4(clamp(cell,0,limit),layer,0)),
      height_map.Load(int4(clamp(cell+int2(1,0),0,limit),layer,0)),
      height_map.Load(int4(clamp(cell+int2(0,1),0,limit),layer,0)),
      height_map.Load(int4(clamp(cell+1,0,limit),layer,0)));
  return float2(lerp(lerp(heights.x,heights.y,f.x),lerp(heights.z,heights.w,f.x),f.y),
      min(min(heights.x,heights.y),min(heights.z,heights.w)));
}
float UnderwaterReceiverWeight(float3 world) {
  if(UnderwaterReady())return UnderwaterWeight(world);
  if(!WaterOpticsReady() ||UnderwaterState[4].w<=0.f)return 0.f;
  float depth=UnderwaterDepth(world);
  float2 uv=(world.xy-UnderwaterState[5].xy)/UnderwaterState[5].z;
  float edge=saturate(min(min(uv.x,uv.y),min(1.f-uv.x,1.f-uv.y))*16.f);
  if(depth<=0.f ||edge<=0.f)return 0.f;
  // Only receivers in the captured regional water body and above its terrain
  // floor qualify. Do not apply a global ocean-height test to caves/interiors.
  uint width,height,layers;WaterRegionHeights.GetDimensions(width,height,layers);
  float elevation=0.f;
  [loop] for(uint i=0;i<min(min(asuint(WaterSurfaceConstants[6].x),44u),layers);++i) {
    float4 rectangle=WaterSurfaceConstants[7+i];
    float2 region=(world.xy-rectangle.xy)/max(rectangle.zw,1.e-4f);
    if(any(region<0.f) ||any(region>1.f))continue;
    float value=WaterHeightSample(WaterRegionHeights,region,i).x;
    if(abs(value)>.001f) {elevation=value;break;}
  }
  if(abs(elevation-UnderwaterState[1].w)>.25f)return 0.f;
  uint count,rows;WaterTerrainTiles.GetDimensions(count,rows);
  WaterTerrainHeights.GetDimensions(width,height,layers);
  if(rows<2u ||width==0u ||height==0u)return 0.f;
  [loop] for(uint tile=0;tile<min(count,layers);++tile) {
    float4 rectangle=WaterTerrainTiles.Load(int3(tile,0,0));
    if(any(world.xy<=rectangle.xy) ||any(world.xy>=rectangle.zw))continue;
    float4 atlas=WaterTerrainTiles.Load(int3(tile,1,0));
    float2 terrain=(world.xy-rectangle.xy)/(rectangle.zw-rectangle.xy)+.5f/float2(width,height);
    float2 bottom=lerp(WaterRanges[0].x,WaterRanges[0].y,
        saturate(WaterHeightSample(WaterTerrainHeights,lerp(atlas.xy,atlas.zw,terrain),tile)));
    // The terrain texture is coarser than the receiver mesh. Its cell minimum
    // is a conservative floor; an interpolated hard cutoff creates holes on
    // slopes where the native tessellated surface differs from the height map.
    return bottom.x<elevation &&world.z>=bottom.y-.1f ? edge*smoothstep(0.f,.1f,depth):0.f;
  }
  return 0.f;
}
float UnderwaterCausticSample(float2 uv) {
  float2 p=uv*float(CLASSIC_CAUSTIC_ATLAS)-.5f;
  int2 cell=int2(floor(p));float2 f=frac(p);
  return lerp(lerp(UnderwaterCaustics.Load(int3(cell,0)),UnderwaterCaustics.Load(int3(cell+int2(1,0),0)),f.x),
      lerp(UnderwaterCaustics.Load(int3(cell+int2(0,1),0)),UnderwaterCaustics.Load(int3(cell+1,0)),f.x),f.y);
}
float UnderwaterFocus(float3 world) {
  float depth=UnderwaterDepth(world);
  float4 levels=UnderwaterState[6];
  float slice=depth<=levels.y ? saturate((depth-levels.x)/(levels.y-levels.x))
      : depth<=levels.z ? 1.f+saturate((depth-levels.y)/(levels.z-levels.y))
      : 2.f+saturate((depth-levels.z)/(levels.w-levels.z));
  uint first=min((uint)slice,2u);
  float2 uv=(world.xy-UnderwaterState[5].xy)/UnderwaterState[5].z;
  // Guard each atlas tile against neighboring depth layers. Outside the finite
  // camera-centered field use uniform illumination, never a repeated texture.
  float edge=saturate(min(min(uv.x,uv.y),min(1.f-uv.x,1.f-uv.y))*16.f);
  uv=clamp(uv,1.5f/float(CLASSIC_CAUSTIC_TILE),1.f-1.5f/float(CLASSIC_CAUSTIC_TILE));
  float2 offset0=float2(first&1u,first>>1u);
  uint second=first+1u;
  float2 offset1=float2(second&1u,second>>1u);
  float a=UnderwaterCausticSample((uv+offset0)*.5f);
  float b=UnderwaterCausticSample((uv+offset1)*.5f);
  float focus=lerp(a,b,slice-float(first));
  float depth_weight=saturate(depth/levels.x)*(1.f-smoothstep(levels.w,2.f*levels.w,depth));
  return max(0.f,lerp(1.f,max(focus,0.f),edge*depth_weight*UnderwaterState[7].w));
}
float3 UnderwaterSunDirection(float3 world,float3 original) {
  float weight=UnderwaterReceiverWeight(world);
  if(weight<=0.f)return original;
  return normalize(lerp(original,-refract(-normalize(original),float3(0,0,1),1.f/1.333f),weight));
}
float3 UnderwaterSunFactor(float3 world) {
  float weight=UnderwaterReceiverWeight(world);
  if(weight<=0.f)return 1.f;
  float3 sun=UnderwaterState[1].xyz;
  float3 ray=refract(-sun,float3(0,0,1),1.f/1.333f);
  float cosine=max(-ray.z,.01f);
  float flux=saturate(sun.z)*(1.f-WaterInterfaceFresnel(sun.z,1.f/1.333f))/cosine;
  return lerp(1.f,WaterTransmittance(UnderwaterState[2].rgb,UnderwaterDepth(world)/cosine)*flux*UnderwaterFocus(world),weight);
}
// Isotropic downwelling environment irradiance integrated over Snell's window.
// Refraction's radiance/solid-angle Jacobians cancel to 2*cos(theta_air).
// This approximates the incoming ambient leg, separately from eye attenuation.
float3 UnderwaterAmbientFactor(float3 world) {
  float weight=UnderwaterReceiverWeight(world);
  if(weight<=0.f)return 1.f;
  float3 transfer=0.f;
  [unroll] for(uint i=0;i<4u;++i) {
    float air_cosine=(float(i)+.5f)*.25f;
    float water_cosine=sqrt(1.f-(1.f-air_cosine*air_cosine)/(1.333f*1.333f));
    transfer+=.5f*air_cosine*(1.f-WaterInterfaceFresnel(air_cosine,1.f/1.333f))
        *WaterTransmittance(UnderwaterState[2].rgb,UnderwaterDepth(world)/water_cosine);
  }
  return lerp(1.f,transfer,weight);
}
// Bilinear comparison of visibility, never filtered raw depths. This helper is
// shared by adjacent cascades during the native transition interval.
float UnderwaterCascade(float3 p,uint cascade,uint2 extent) {
  float2 uv=p.xy*UnderwaterLight[11+cascade].z*float2(1,-1)+UnderwaterLight[11+cascade].xy;
#ifdef CLASSIC_UNDERWATER_COMPOSITE
  return UnderwaterShadows.SampleCmpLevelZero(UnderwaterShadowSampler,float3(uv,cascade),p.z);
#else
  float2 coordinate=saturate(uv)*float2(extent)-.5f;
  int2 cell=int2(floor(coordinate)),limit=int2(extent)-1;
  float2 f=frac(coordinate);
  float a=p.z<=UnderwaterShadows.Load(int4(clamp(cell,0,limit),cascade,0));
  float b=p.z<=UnderwaterShadows.Load(int4(clamp(cell+int2(1,0),0,limit),cascade,0));
  float c=p.z<=UnderwaterShadows.Load(int4(clamp(cell+int2(0,1),0,limit),cascade,0));
  float d=p.z<=UnderwaterShadows.Load(int4(clamp(cell+1,0,limit),cascade,0));
  return lerp(lerp(a,b,f.x),lerp(c,d,f.x),f.y);
#endif
}
// Valid for the native AIR-to-interface sunlight ray. Native CSMs do not contain
// refracted underwater blocker paths and must not be sampled as if they did.
float UnderwaterVisibility(float3 world) {
  float3 p=world.x*UnderwaterLight[4].xyz+world.y*UnderwaterLight[5].xyz
      +world.z*UnderwaterLight[6].xyz+UnderwaterLight[7].xyz;
  uint width,height,layers;UnderwaterShadows.GetDimensions(width,height,layers);
  uint count=min(min((uint)UnderwaterLight[15].z,4u),layers);
  if(width==0 ||height==0 ||abs(p.z)>=.999f)return 1.f;
  float4 bounds=max(abs(p.x-UnderwaterLight[8]),abs(p.y-UnderwaterLight[9]));
  [unroll] for(uint i=0;i<4u;++i) {
    if(i>=count ||bounds[i]>=UnderwaterLight[10][i])continue;
    float visibility=UnderwaterCascade(p,i,uint2(width,height));
    float fade=saturate((bounds[i]/max(UnderwaterLight[10][i],1.e-8f)
        -(1.f-UnderwaterLight[17][i]))/max(UnderwaterLight[17][i],.0001f));
    if(fade>0.f)visibility=lerp(visibility,i+1u<count ? UnderwaterCascade(p,i+1u,uint2(width,height)):1.f,fade);
    return visibility;
  }
  return 1.f;
}
#endif
