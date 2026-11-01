// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef CLASSIC_WATER_RIPPLES
#define CLASSIC_WATER_RIPPLES

// A single octave of the native domain shader's displacement. Alpha is height;
// XY drives the native coordinate warp and horizontal crest displacement.
// Do not treat XY / the artist's fixed Z as the surface's physical slope.
float3 WaterWaveDisplacement(Texture2D<float4> waves, SamplerState wave_sampler,
                            float2 uv, float height_scale, float warp, float normal_z) {
  float2 offset=waves.SampleLevel(wave_sampler,uv,0).xy;
  float4 wave=waves.SampleLevel(wave_sampler,uv+warp*offset,0);
  return float3(-warp*normalize(float3(wave.xy,normal_z)).xy,height_scale*wave.w);
}

// Reconstruct both broad native geometric bands, including lateral crest
// movement. This replaces ALL three exaggerated shading bands; it adds no
// procedural noise. Parameters/animation come from the game's water simulation.
// v1 is the undisplaced domain position, v2.w the mean water elevation.
// Shore depth and camera envelope are locally constant across the footprint;
// wakes are composed afterwards by each native pixel shader.
float3 WaterSurfaceWaveNormal(Texture2D<float4> waves, SamplerState wave_sampler,
                              float2 position, float2 scales, float2 amplitudes,
                              float2 warps, float depth, float camera_distance,
                              float strength, float coverage, float2 footprint) {
  if(strength<=0.f || coverage<=0.f) return float3(0,0,1);
  uint width,height;
  waves.GetDimensions(width,height);
  if(width==0 || height==0) return float3(0,0,1);
  scales=max(abs(scales),.001f);
  float shore_fade=(1.f-saturate(-.1f*depth))*.9f+.1f;
  float2 shore=saturate((abs(depth)-.1f)*float2(.204081625f,.526315808f))
      *float2(.7f,.4f)+float2(.3f,.6f);
  amplitudes*=shore*shore_fade*saturate(1.f-camera_distance/250.f);
  warps*=shore_fade;
  float3 tangent_x=float3(1,0,0),tangent_y=float3(0,1,0);
  [unroll] for(uint band=0;band<2;++band) {
    float2 step=max(scales[band]/float2(width,height),footprint);
    float2 uv=position/scales[band];
    float2 delta=step/scales[band];
    float normal_z=band==0?.00015f:.00035f;
    tangent_x+=(WaterWaveDisplacement(waves,wave_sampler,uv+float2(delta.x,0),amplitudes[band],warps[band],normal_z)
        -WaterWaveDisplacement(waves,wave_sampler,uv-float2(delta.x,0),amplitudes[band],warps[band],normal_z))/(2.f*step.x);
    tangent_y+=(WaterWaveDisplacement(waves,wave_sampler,uv+float2(0,delta.y),amplitudes[band],warps[band],normal_z)
        -WaterWaveDisplacement(waves,wave_sampler,uv-float2(0,delta.y),amplitudes[band],warps[band],normal_z))/(2.f*step.y);
  }
  float3 normal=cross(tangent_x,tangent_y);
  // Folded/degenerate horizontal maps cannot define a single upward interface.
  // Fall back to the height gradient instead of flipping reflection directions.
  if(normal.z<=.05f) normal=float3(-tangent_x.z,-tangent_y.z,1.f);
  return normalize(float3(normal.xy*(saturate(strength)*saturate(coverage)),normal.z));
}
#endif
