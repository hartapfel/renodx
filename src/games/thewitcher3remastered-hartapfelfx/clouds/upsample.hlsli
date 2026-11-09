// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef HARTAPFEL_CLOUD_UPSAMPLE
#define HARTAPFEL_CLOUD_UPSAMPLE
#include "common.hlsli"
#include "storage.hlsli"
// Positive weights preserve HDR energy and Beer transmission without cubic
// ringing. Reject taps behind foreground surfaces before applying camera air.
float4 UpsampleCloud(Texture2D<float4> source,Texture2D<float> depths,
    float2 uv,float surface_distance,out float distance) {
  distance=0.f;
  if(all(dimensions.xy==dimensions.zw)) {
    int2 pixel=int2(uv*dimensions.xy);
    distance=depths.Load(int3(pixel,0));
    return distance>0.f
        ?CloudDecode(source.Load(int3(pixel,0))):float4(0,0,0,1);
  }
  float2 pixel=uv*dimensions.xy-.5f;
  int2 base=int2(floor(pixel));
  float2 f=frac(pixel);
  float4 result=0.f;
  float total=0.f,depth_weight=0.f;
  [unroll]for(uint y=0;y<2;++y)[unroll]for(uint x=0;x<2;++x) {
    int2 tap=clamp(base+int2(x,y),0,int2(dimensions.xy)-1);
    float depth=depths.Load(int3(tap,0));
    float weight=(x?f.x:1.f-f.x)*(y?f.y:1.f-f.y);
    if(depth>0.f &&depth>=surface_distance)continue;
    float4 value=depth>0.f?CloudDecode(source.Load(int3(tap,0))):float4(0,0,0,1);
    result+=value*weight;
    total+=weight;
    float opacity_weight=weight*(1.f-value.a);
    distance+=depth*opacity_weight;
    depth_weight+=opacity_weight;
  }
  distance/=max(depth_weight,1.e-8f);
  return total>1.e-8f?result/total:float4(0,0,0,1);
}
#endif
