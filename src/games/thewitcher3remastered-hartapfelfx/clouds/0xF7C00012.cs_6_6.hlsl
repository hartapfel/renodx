// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
Texture2D<float> source : register(t3);
SamplerState wrap_sampler : register(s0);
RWTexture2D<float> destination : register(u0);
[numthreads(8,8,1)] void main(uint3 id : SV_DispatchThreadID) {
  uint width,height,source_width,source_height;
  destination.GetDimensions(width,height);
  source.GetDimensions(source_width,source_height);
  if(id.x>=width ||id.y>=height)return;
  float2 uv=(float2(id.xy)+.5f)/float2(width,height);
  float2 offset=.25f/float2(width,height);
  destination[id.xy]=.25f*(source.SampleLevel(wrap_sampler,uv+float2(-offset.x,-offset.y),0)
      +source.SampleLevel(wrap_sampler,uv+float2(offset.x,-offset.y),0)
      +source.SampleLevel(wrap_sampler,uv+float2(-offset.x,offset.y),0)
      +source.SampleLevel(wrap_sampler,uv+offset,0));
}
