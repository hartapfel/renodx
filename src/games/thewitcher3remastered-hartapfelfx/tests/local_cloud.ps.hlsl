// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../clouds/local_volume.hlsli"
Texture2D<float4> material:register(t0);
SamplerState filter_sampler:register(s0);
cbuffer Probe:register(b0) {
  float4 scene_frame_alpha_time;
  float4 center_marker;
}
float4 main(float4 position:SV_Position):SV_Target {
  float2 uv=position.xy/64.f;
  return LocalCloudVolume(float4(.1f,.2f,.3f,.4f),center_marker,
      float4((uv*2.f-1.f)*40.f,100.f,100.f),float4(0,0,0,scene_frame_alpha_time.x),
      float4(uv,scene_frame_alpha_time.yz),float3(.4f,.6f,.8f),float3(0,uv.y-.5f,0),float4(2,1,.13f,.07f),
      scene_frame_alpha_time.w,material,filter_sampler);
}
