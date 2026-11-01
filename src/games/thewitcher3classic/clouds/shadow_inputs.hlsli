// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_CLOUD_SHADOW_INPUTS
#define CLASSIC_CLOUD_SHADOW_INPUTS
// These slots are reserved in all stages; object-history data occupy 120-125.
Texture2D<float> ClassicCloudShadowMap : register(t126);
StructuredBuffer<float4> ClassicCloudShadowData : register(t127);
bool ClassicCloudShadowsReady() {
  uint count,stride;ClassicCloudShadowData.GetDimensions(count,stride);
  return count==4 &&ClassicCloudShadowData[1].w==1.f &&ClassicCloudShadowData[2].w==1357.f;
}
float ClassicCloudShadow(float3 world,float native_visibility) {
  if(!ClassicCloudShadowsReady())return native_visibility;
  float4 region=ClassicCloudShadowData[0];
  float3 sun=ClassicCloudShadowData[1].xyz;
  float strength=ClassicCloudShadowData[2].z;
  if(strength==0.f)return 1.f;
  uint width,height;ClassicCloudShadowMap.GetDimensions(width,height);
  if(!width ||!height ||region.w<=0.f)return native_visibility;
  float2 projection=world.xy-(world.z-region.z)*sun.xy/sun.z;
  float2 uv=(projection-region.xy)/region.w+.5f;
  if(any(uv<=0.f)||any(uv>=1.f))return 1.f;
  float edge=min(min(uv.x,uv.y),min(1.f-uv.x,1.f-uv.y));
  float2 pixel=uv*float2(width,height)-.5f;
  int2 cell=int2(floor(pixel)),limit=int2(width,height)-1;
  float2 f=frac(pixel);
  // No material sampler is borrowed, so this is identical in VS, PS and CS.
  float a=ClassicCloudShadowMap.Load(int3(clamp(cell,0,limit),0));
  float b=ClassicCloudShadowMap.Load(int3(clamp(cell+int2(1,0),0,limit),0));
  float c=ClassicCloudShadowMap.Load(int3(clamp(cell+int2(0,1),0,limit),0));
  float d=ClassicCloudShadowMap.Load(int3(clamp(cell+1,0,limit),0));
  float transmission=lerp(lerp(a,b,f.x),lerp(c,d,f.x),f.y);
  return lerp(1.f,saturate(transmission),strength*smoothstep(0.f,.08f,edge));
}
#endif
