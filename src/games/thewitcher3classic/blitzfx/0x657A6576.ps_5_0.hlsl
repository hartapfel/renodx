#include "scene_pool.hlsli"

// Native quarter-resolution reflection depth preparation. BlitzFX retains the
// output-sized depth allocation while DLSS renders into its top-left viewport.
Texture2D<float4> scene_depth : register(t0);
SamplerState depth_sampler : register(s0);
cbuffer ReflectionDimensions : register(b3) {
  float4 reflection_size;
  float4 reflection_scale;  // Captured native buffer: .25, .25, 4, 4.
};

float4 main(float4 position : SV_Position) : SV_Target {
  uint width, height;
  scene_depth.GetDimensions(width, height);
  return scene_depth.SampleLevel(depth_sampler,
      BlitzScenePoolUV((floor(position.xy) + .5f) / reflection_size.xy,
          reflection_size.xy * reflection_scale.zw, float2(width, height)), 0).xxxx;
}
