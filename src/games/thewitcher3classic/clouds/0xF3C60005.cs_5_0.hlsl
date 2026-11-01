// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Apply cloud motion only to visible, predominantly cloudy sky pixels. Scene
// color, geometry depth and foreground object motion remain unchanged.
Texture2D<float4> clouds : register(t0);
Texture2D<float> native_depth : register(t1);
RWTexture2D<float2> motion : register(u0);
RWTexture2D<float> responsive : register(u1);
SamplerState clamp_sampler : register(s0);
cbuffer Parameters : register(b0) { float4 dimensions; }
cbuffer Frame : register(b12) { float4 frame[269]; }
[numthreads(8,8,1)]
void main(uint3 id:SV_DispatchThreadID) {
  if(any(id.xy>=uint2(dimensions.xy)))return;
  float z=native_depth.Load(int3(id.xy,0))*frame[22].x+frame[22].y;
  if(z<.999999f)return;
  // A shape/quality edit can also remove clouds. Reject old sky history even
  // where the current frame has no cloud opacity to carry responsiveness.
  if(dimensions.z!=0.f) {responsive[id.xy]=1.f;return;}
  float4 cloud=clouds.SampleLevel(clamp_sampler,(id.xy+.5f)/dimensions.xy,0);
  if(cloud.z<.5f) {
    // Thin evolving wisps mix sky and cloud depths: leave their native motion
    // intact, but reject unreliable history just like an opaque cloud edge.
    if(cloud.z>.02f &&cloud.w<.9f)responsive[id.xy]=1.f;
    return;
  }
  if(cloud.w>.9f &&all(isfinite(cloud.xy)) &&all(abs(cloud.xy)<1.f))motion[id.xy]=cloud.xy;
  else responsive[id.xy]=1.f;
}
