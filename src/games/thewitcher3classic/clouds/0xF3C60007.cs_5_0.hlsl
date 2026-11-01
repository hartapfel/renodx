// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Convert the native shadow silhouette into a broad coverage control field.
// A sharp 2D shadow edge extruded through the layer creates vertical curtains.
cbuffer Frame : register(b0) { float4 frame[269]; }
cbuffer Parameters : register(b2) { float4 dimensions; float4 integration; }
cbuffer PreviousWeatherFrame : register(b3) { float4 previous[269]; }
Texture2DArray<float> native_weather : register(t1);
Texture2DArray<float> previous_weather : register(t3);
SamplerState wrap_sampler : register(s0);
RWTexture2DArray<float> coverage : register(u0);
[numthreads(8,8,1)]
void main(uint3 id : SV_DispatchThreadID) {
  uint width,height,layers;
  coverage.GetDimensions(width,height,layers);
  if(any(id.xy>=uint2(width,height)))return;
  uint native_width,native_height,native_layers;
  native_weather.GetDimensions(native_width,native_height,native_layers);
  float2 layer=clamp(trunc(frame[68].xy),0.f,float(max(native_layers,1u)-1u));
  float2 uv=(id.xy+.5f)/float2(width,height);
  // Fixed world-space width, independent of formation size, density and layer
  // thickness. Symmetric binomial filtering preserves constant cover and wind.
  float spacing=min(.0625f,150.f*.0005f/max(frame[66].x,.001f));
  static const float weights[8]={1.f,7.f,21.f,35.f,35.f,21.f,7.f,1.f};
  float value=0.f;
  [unroll]for(uint y=0;y<8;++y)[unroll]for(uint x=0;x<8;++x) {
    float2 sample_uv=uv+(float2(x,y)-3.5f)*spacing;
    float weight=weights[x]*weights[y]/16384.f;
    value+=weight*lerp(native_weather.SampleLevel(wrap_sampler,float3(sample_uv,layer.x),0),
        native_weather.SampleLevel(wrap_sampler,float3(sample_uv,layer.y),0),saturate(frame[66].w));
  }
  if(integration.w!=0.f &&previous[66].x>0.f &&frame[66].x>0.f) {
    float2 wind_delta=20.f*(frame[67].xy-previous[67].xy);
    // Advect continuous wind. When a weather preset resets its wind origin,
    // keep the previous cover in world space while fading into the new field.
    // Cancel continuous wind algebraically before evaluating in FP32. Going
    // through large world/wind coordinates lost texel precision over time.
    float2 old_uv=uv*(frame[66].x/previous[66].x);
    if(length(wind_delta)>=250.f)old_uv-=wind_delta*(.0005f/previous[66].x);
    value=lerp(previous_weather.SampleLevel(wrap_sampler,float3(old_uv,0),0),value,integration.x);
  }
  coverage[uint3(id.xy,0)]=saturate(value);
}
