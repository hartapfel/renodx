// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Preserve both native weather layers in a 512x512 coverage control field.
// A sharp 2D shadow edge extruded through the layer creates vertical curtains.
cbuffer Frame : register(b0) { float4 frame[341]; }
cbuffer Parameters : register(b2) {
  float4 dimensions, integration, appearance, atmosphere, scattering;
  uint4 identity;
}
cbuffer PreviousParameters : register(b4) {
  float4 previous_dimensions, previous_integration, previous_appearance, previous_atmosphere, previous_scattering;
  uint4 previous_identity;
}
#include "../fog/math.hlsli"
#include "wind.hlsli"
cbuffer CloudClock : register(b5) { float4 cloud_clock; }
cbuffer PreviousCloudClock : register(b6) { float4 previous_cloud_clock; }
cbuffer PreviousWeatherFrame : register(b3) { float4 previous[341]; }
Texture2DArray<float> native_weather : register(t1);
Texture2DArray<float2> previous_weather : register(t3);
SamplerState wrap_sampler : register(s0);
RWTexture2DArray<float2> coverage : register(u0);
[numthreads(8, 8, 1)] void main(uint3 id : SV_DispatchThreadID) {
  uint width,height,layers;
  coverage.GetDimensions(width,height,layers);
  if(any(id.xy>=uint2(width,height)))return;
  uint native_width,native_height,native_layers;
  native_weather.GetDimensions(native_width,native_height,native_layers);
  float2 layer=clamp(trunc(frame[68].xy),0.f,float(max(native_layers,1u)-1u));
  float2 uv=(id.xy+.5f)/float2(width,height);
  // Fixed world-space width, independent of formation size, density and layer
  // thickness. Symmetric binomial filtering preserves constant cover and wind.
  float spacing=min(.0625f,230.f*.0005f/max(frame[66].x,.001f));
  static const float weights[4]={1.f,3.f,3.f,1.f};
  float2 value=0.f;
  [unroll]for(uint y=0;y<4;++y)[unroll]for(uint x=0;x<4;++x) {
    float2 sample_uv=uv+(float2(x,y)-1.5f)*spacing;
    float weight=weights[x]*weights[y]/64.f;
    value+=weight*float2(native_weather.SampleLevel(wrap_sampler,float3(sample_uv,layer.x),0),
        native_weather.SampleLevel(wrap_sampler,float3(sample_uv,layer.y),0));
  }
  if(integration.w!=0.f &&identity.x==previous_identity.x
      &&previous[66].x>0.f &&frame[66].x>0.f) {
    float2 wind_delta=frame[67].xy-previous[67].xy;
    // Advect continuous wind. When a weather preset resets its wind origin,
    // keep the previous cover in world space while fading into the new field.
    // Cancel continuous wind algebraically before evaluating in FP32. Going
    // through large world/wind coordinates lost texel precision over time.
    float2 old_uv=uv*(frame[66].x/previous[66].x);
    if(length(wind_delta)>=250.f)old_uv-=CloudWindOffset(wind_delta)*(.0005f/previous[66].x);
    float elapsed = cloud_clock.x - previous_cloud_clock.x;
    if (isfinite(elapsed) && elapsed >= 0.f && elapsed < 1.f)
      value = lerp(previous_weather.SampleLevel(wrap_sampler, float3(old_uv, 0), 0), value, SegmentOpacity(min(elapsed, .25f) / .8f));
  }
  coverage[uint3(id.xy,0)]=saturate(value);
}
