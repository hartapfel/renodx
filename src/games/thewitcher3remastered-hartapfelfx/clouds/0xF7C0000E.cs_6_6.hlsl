// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Tent-filter Beer transmission and exponential weighted depth. Both are
// linearly filterable before the native receiver evaluates its shadow test.
Texture2D<float2> source : register(t3);
SamplerState clamp_sampler : register(s1);
RWTexture2D<float2> destination : register(u0);
[numthreads(8,8,1)] void main(uint3 id : SV_DispatchThreadID) {
  uint width,height,source_width,source_height;
  destination.GetDimensions(width,height);
  source.GetDimensions(source_width,source_height);
  if(any(id.xy>=uint2(width,height)))return;
  float2 uv=(float2(id.xy)+.5f)/float2(width,height);
  // Four bilinear taps exactly reproduce the separable 3x3 binomial kernel:
  // the two taps at +/- half a texel give weights [1,2,1]/4 on each axis.
  float2 value=0.f;
  [unroll]for(int y=-1;y<=1;y+=2)[unroll]for(int x=-1;x<=1;x+=2) {
    value+=source.SampleLevel(clamp_sampler,uv+.5f*float2(x,y)/float2(source_width,source_height),0);
  }
  destination[id.xy]=saturate(value*.25f);
}
