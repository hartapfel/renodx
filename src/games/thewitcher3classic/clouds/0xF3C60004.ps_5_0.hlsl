#define CLASSIC_FOG_OPAQUE_CACHE
// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "common.hlsli"
#include "../volumetrics/sample.hlsli"
Texture2D<float4> cloud : register(t3);
Texture2D<float> cloud_depth : register(t4);
float4 main(float4 position:SV_Position):SV_Target {
  float2 uv=position.xy/dimensions.zw;
  float3 ray=CloudRay(uv);
  if(ray.z<-.02f)discard;
  float2 interval=CloudInterval(frame[0].xyz,ray);
  if(interval.y<=interval.x ||CloudSceneDistance(position.xy,ray)<interval.x)discard;
  float2 pixel=uv*dimensions.xy-.5f;
  int2 cell=int2(floor(pixel));float2 f=frac(pixel);
  float4 value=0.f;float sum=0.f,distance=0.f;
  [unroll]for(int y=0;y<2;++y)[unroll]for(int x=0;x<2;++x) {
    int2 location=clamp(cell+int2(x,y),0,int2(dimensions.xy)-1);
    float w=(x?f.x:1.f-f.x)*(y?f.y:1.f-f.y);
    if(cloud_depth.Load(int3(location,0))>0.f) {
      value+=cloud.Load(int3(location,0))*w;sum+=w;
      distance+=cloud_depth.Load(int3(location,0))*w;
    }
  }
  if(sum<1.e-5f)discard;
  value/=sum;
  float opacity=saturate(1.f-value.a);
  // Premultiplied over: C + (1-opacity)*background. The background sky
  // already contains foreground fog S, so the cloud must carry opacity*S.
  // Sampling the same field at the same distance preserves that lighting even
  // under an opaque cloud, without double-counting it through cloud gaps.
  if(opacity>0.f &&ClassicFogReady())
    value.rgb+=opacity*SampleClassicSkyDirect(uv,min(distance/sum,ClassicFogParameters[0].w));
  return float4(max(value.rgb,0.f),opacity);
}
