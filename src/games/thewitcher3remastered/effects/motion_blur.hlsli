/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#ifndef WITCHER_MOTION_BLUR_HLSLI
#define WITCHER_MOTION_BLUR_HLSLI

// Coordinates and velocities are in OUTPUT pixels. Inputs can be rendered at
// a lower resolution, but color reconstruction never downsamples the image.
#include "../motion_blur_config.h"
cbuffer MotionParameters : register(b0) {
  uint2 image_size;
  uint2 tile_count;
  float2 motion_coordinate_scale;
  float2 velocity_to_radius;
  float2 depth_coordinate_scale;
  float2 depth_linearization;
  float reserved;
  uint max_samples;
  uint diagnostic_view;
  float frame_seconds;
};

// Bind the game's existing GPU constant buffer directly. No CPU readback or
// guessed projection parameters are required for the actual reconstruction.
cbuffer NativeDepthProjection : register(b1) {
  float2 native_depth_scale : packoffset(c21);
  float2 native_depth_transform : packoffset(c22);
};

// t0 is always full-resolution linear HDR color. It is never the native
// low-resolution blurred image. t1 contains unscaled per-frame motion.
Texture2D<float4> color_texture : register(t0);
Texture2D<float2> velocity_texture : register(t1);
Texture2D<float> depth_texture : register(t2);
Texture2D<float2> tile_texture : register(t3);
SamplerState linear_clamp : register(s0);
RWTexture2D<float4> result_texture : register(u0);

float2 MotionRadius(int2 pixel) {
  pixel = clamp(pixel, int2(0, 0), int2(image_size) - 1);
  float2 radius = velocity_texture.Load(int3(uint2(float2(pixel) * motion_coordinate_scale), 0)) * velocity_to_radius;
  // Do not clamp valid frame motion: a fixed pixel ceiling hides the shutter's
  // FPS response during fast pans. The gather domain is clipped to the viewport.
  if (!all(isfinite(radius))) return 0.f;
  return radius;
}

// Intersect a shutter segment with an axis-aligned rectangle. Used both for
// conservative swept-tile coverage and for clipping gathers to visible pixels.
float2 MotionInterval(float2 direction, float2 low, float2 high, float radius) {
  float2 interval = float2(-radius, radius);
  [unroll]
  for (uint axis = 0u; axis < 2u; ++axis) {
    if (abs(direction[axis]) < 1e-8f) {
      if (low[axis] > 0.f || high[axis] < 0.f) return float2(1.f, -1.f);
    } else {
      float a = low[axis] / direction[axis];
      float b = high[axis] / direction[axis];
      interval.x = max(interval.x, min(a, b));
      interval.y = min(interval.y, max(a, b));
    }
  }
  return interval;
}

float MotionDepth(int2 pixel) {
  pixel = clamp(pixel, int2(0, 0), int2(image_size) - 1);
  float depth = depth_texture.Load(int3(uint2(float2(pixel) * depth_coordinate_scale), 0));
  return rcp(max((depth * native_depth_transform.x + native_depth_transform.y) * native_depth_scale.x + native_depth_scale.y, 1e-8f));
}

float2 MotionDirection(float2 velocity) {
  return velocity * rsqrt(max(dot(velocity, velocity), 1e-12f));
}

// Frame-invariant spatial noise avoids adding temporal shimmer after DLSS/TAA.
float MotionNoise(uint2 pixel) {
  return frac(52.9829189f * frac(dot(float2(pixel), float2(0.06711056f, 0.00583715f))));
}

#endif
