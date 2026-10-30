// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_CLASSIC_FOG_PER_PIXEL
#define WITCHER_CLASSIC_FOG_PER_PIXEL
#include "math.hlsli"
#include "interior.hlsli"
#include "../../../shaders/random.hlsl"
ByteAddressBuffer PixelFogTiles : register(t99);
StructuredBuffer<float4> PixelFogFrame : register(t100);
StructuredBuffer<float4> PixelFogLights : register(t101);
Texture2DArray<float> PixelFogShadows : register(t102);
Texture2DArray<float> PixelFogAtlas : register(t103);
TextureCubeArray<float> PixelFogCubes : register(t104);
Texture2DArray<float> PixelFogClouds : register(t105);
Texture2DArray<float> PixelFogTerrain : register(t106);
Texture2D<float2> PixelFogInteriors : register(t107);
#ifdef CLASSIC_FOG_COMPUTE
SamplerComparisonState PixelFogShadowSampler : register(s0);
SamplerState PixelFogWrapSampler : register(s1);
SamplerState PixelFogLocalSampler : register(s3);
#endif
#define CLASSIC_FOG_PER_PIXEL
#define CLASSIC_LOCAL_EXTERNAL_RESOURCES
#define frame PixelFogFrame
#define light PixelFogLights
#define medium ClassicFogParameters[1]
#define options ClassicFogParameters[2]
#define sampling float4(ClassicFogParameters[3].xy,ClassicFogParameters[21].z,ClassicFogParameters[21].w)
#define local_tiles PixelFogTiles
#define local_atlas PixelFogAtlas
#define local_cubes PixelFogCubes
#ifdef CLASSIC_FOG_COMPUTE
#define local_sampler PixelFogLocalSampler
#else
#define local_sampler ClassicFogSampler
#endif
#define shadows PixelFogShadows
#define clouds PixelFogClouds
#define terrain PixelFogTerrain
#define clamp_sampler ClassicFogSampler
#define wrap_sampler ClassicFogSampler
#include "local_lights.hlsli"
#include "sun_lighting.hlsli"

bool ClassicPixelFogReady() {
  uint count,stride,frames,lights;
  ClassicFogParameters.GetDimensions(count,stride);
  if (count != 22 || ClassicFogParameters[21].y < .5f) return false;
  PixelFogFrame.GetDimensions(frames,stride);PixelFogLights.GetDimensions(lights,stride);
  return frames >= 269 && lights >= 2362;
}
float2 PixelFogInterior(float2 uv) {
  uint width,height;PixelFogInteriors.GetDimensions(width,height);
  if (width == 0 ||height == 0 || light[34].z <= 0.f) return 0.f;
  uint2 pixel = min(uint2(uv/ClassicFogParameters[3].xy*.5f),uint2(width,height)-1u);
  return PixelFogInteriors.Load(int3(pixel,0))*light[34].z;
}
float PixelFogFalloff(float3 ray) {
  float weight=saturate((frame[42].x+dot(ray,frame[38].xyz))/max(1.f+frame[42].x,.0001f));
  return max(0.f,lerp(frame[43].z,frame[43].y,weight))*options.x;
}
float PixelFogOpacity(float distance,float3 ray,float falloff,float2 interior,bool native_product) {
  float start=max(medium.y,frame[22].z);
  float length=max(0.f,distance-start);
  if(frame[42].z>0.f)length=min(length,frame[42].z);
  float fade=saturate((length-frame[48].y)*frame[48].z);
  if(length<=0.f ||medium.x<=0.f ||fade<=0.f)return 0.f;
  float sigma=max(frame[43].x,0.f)*medium.x;
  float transmittance=1.f;
  if(native_product) {
    // Exact native end-point density product at neutral settings. Interior
    // intervals extend that baseline without manufacturing indoor medium.
    [unroll]for(uint i=0;i<16;++i) {
      float begin=start+length*(i/16.f),end=start+length*((i+1u)/16.f);
      float density=FogHeightDensity(frame[0].z+ray.z*end+frame[42].y,falloff);
      transmittance*=1.f-saturate(sigma*length/16.f*density*FogExteriorFraction(interior,begin,end));
    }
  } else {
    float height=frame[0].z+ray.z*start+frame[42].y;
    transmittance=FogLightTransmittance(height,ray.z,sigma,falloff,length);
    if(interior.x!=interior.y) {
      // Clip the analytic column to the exterior intervals. The final opacity
      // still uses the native product above; this is the quadrature weight.
      float lo=max(start,min(interior.x,interior.y));
      float hi=min(start+length,max(interior.x,interior.y));
      float segment=hi>lo?FogLightTransmittance(frame[0].z+ray.z*lo+frame[42].y,ray.z,sigma,falloff,hi-lo):1.f;
      transmittance=interior.x<interior.y?min(1.f,transmittance/max(segment,1.e-20f)):segment;
    }
  }
  return pow(saturate(1.f-transmittance),max(frame[42].w,.0001f))*fade;
}
float3 PixelFogSun(float3 world,float distance,float3 direction,float3 source,float falloff) {
  float visibility=CascadeShadow(world,0.f,0.f,0.f)*TerrainShadow(world)*CloudShadow(world,distance);
  return source*(visibility
      *FogLightTransmittance(world.z+frame[42].y,direction.z,max(frame[43].x,0.f)*medium.x,falloff,1000.f));
}
float3 PixelFogRay(float2 uv) {
  float2 ndc=uv*float2(2,-2)+float2(-1,1);
  return normalize(ndc.x*ClassicFogParameters[18].xyz+ndc.y*ClassicFogParameters[19].xyz+ClassicFogParameters[20].xyz);
}
float4 SampleClassicPixelFog(float2 uv,float distance) {
  float3 ray=PixelFogRay(uv);
  float2 interior=PixelFogInterior(uv);
  float falloff=PixelFogFalloff(ray);
  float opacity=PixelFogOpacity(distance,ray,falloff,interior,true);
  if(opacity<=0.f)return float4(0,0,0,1);
  uint quality=clamp((uint)ClassicFogParameters[21].z,1u,4u);
  float2 pixel=floor(uv/ClassicFogParameters[3].xy);
  float jitter=renodx::random::Hash33(float3(pixel,0)).x;
  float start=max(medium.y,frame[22].z),end=min(distance,max(frame[42].z,1000.f));
  float3 result=0.f;
  float norm=dot(light[0].xyz,light[0].xyz);
  if(medium.z>0.f && norm>=1.e-10f && any(light[1].rgb>0.f)) {
    float3 direction=light[0].xyz*rsqrt(norm);
    float3 source=max(light[1].rgb,0.f)*(PhaseHG(dot(ray,direction),medium.w)*medium.z);
    // Near-field shadow detail gets a separate interval from distant weather.
    // Stratified per-pixel phases replace coherent slice contours with samples
    // that the game's existing reconstruction can resolve.
    uint steps=8u*quality;
    float pivot=min(end,max(start,96.f));
    float previous=PixelFogOpacity(start,ray,falloff,interior,false);
    [loop]for(uint i=0;i<steps;++i) {
      float a=lerp(start,pivot,float(i)/steps),b=lerp(start,pivot,float(i+1u)/steps);
      float next=PixelFogOpacity(b,ray,falloff,interior,false);
      float t=lerp(a,b,jitter);
      float weight=max(0.f,next-previous);
      if(weight>0.f)result+=PixelFogSun(frame[0].xyz+ray*t,t,direction,source,falloff)*weight;
      previous=next;
    }
    if(end>pivot) {
      float factor=pow(max(end/max(pivot,.0001f),1.f),1.f/8.f);
      float a=pivot;
      [loop]for(uint i=0;i<8;++i) {
        float b=i==7u?end:a*factor;
        float next=PixelFogOpacity(b,ray,falloff,interior,false);
        float weight=max(0.f,next-previous),t=lerp(a,b,jitter);
        if(weight>0.f)result+=PixelFogSun(frame[0].xyz+ray*t,t,direction,source,falloff)*weight;
        previous=next;a=b;
      }
    }
  }
  uint bytes;local_tiles.GetDimensions(bytes);
  uint columns=(uint)frame[24].x;
  uint2 tile=uint2(pixel)>>4;
  uint offset=(tile.y*columns+tile.x)*1024u;
  if(sampling.w>0.f &&end>start &&columns>0 &&bytes>=1024 &&offset<=bytes-1024u) {
    uint count=min(asuint(light[57].x),256u);
    [loop]for(uint entry=0;entry<256u;++entry) {
      uint index=local_tiles.Load(offset+entry*4u);
      if(index>=256u)break;
      if(index>=count)continue;
      uint base=58u+index*9u;
      if(asuint(light[base+3].w)==0x80001800u ||light[base].w<=0.f || !any(light[base+3].rgb>0.f))continue;
      float3 delta=light[base].xyz-frame[0].xyz;
      float projected=dot(delta,ray);
      float3 perpendicular=delta-ray*projected;
      float discriminant=light[base].w*light[base].w-dot(perpendicular,perpendicular);
      if(discriminant<=0.f)continue;
      float radius=sqrt(discriminant);
      float lo=max(start,projected-radius),hi=min(end,projected+radius);
      if(hi<=lo)continue;
      bool shadowed=light[base+2].w>0.f &&(light[base+5].z>0.f ||light[base+6].x>0.f);
      uint steps=(shadowed?4u:2u)*(quality+1u);
      float phase=renodx::random::Hash33(float3(pixel,index+1u)).x;
      float previous=PixelFogOpacity(lo,ray,falloff,interior,false);
      [loop]for(uint i=0;i<steps;++i) {
        float a=lerp(lo,hi,float(i)/steps),b=lerp(lo,hi,float(i+1u)/steps);
        float next=PixelFogOpacity(b,ray,falloff,interior,false);
        float weight=max(0.f,next-previous);
        float t=lerp(a,b,phase);
        if(weight>0.f)result+=LocalRadiance(base,frame[0].xyz+ray*t,ray,falloff)*weight;
        previous=next;
      }
    }
  }
  return float4(min(result,60000.f),1.f-opacity);
}
#undef frame
#undef light
#undef medium
#undef options
#undef sampling
#undef local_tiles
#undef local_atlas
#undef local_cubes
#undef local_sampler
#undef shadows
#undef clouds
#undef terrain
#undef shadow_sampler
#undef clamp_sampler
#undef wrap_sampler
#undef CLASSIC_LOCAL_EXTERNAL_RESOURCES
#undef CLASSIC_FOG_PER_PIXEL
#endif
