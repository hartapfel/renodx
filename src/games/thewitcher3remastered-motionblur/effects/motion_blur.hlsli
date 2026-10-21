/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#ifndef WITCHER_MOTION_BLUR_HLSLI
#define WITCHER_MOTION_BLUR_HLSLI

// Coordinates and velocities are in OUTPUT pixels. Inputs can be rendered at
// a lower resolution, but color reconstruction never downsamples the image.
#include "../motion_blur_config.h"
#include "motion_depth.hlsli"
// Reuse the native resolve's descriptors; only this private root buffer and
// settings CBV are appended to its layout. No descriptor heap switch.
cbuffer MotionSettings : register(b0, space57) {
  float shutter_angle;
  uint max_samples;
  uint diagnostic_view;
  float frame_seconds;
  uint motion_components;
  float object_shutter_angle;
};
Texture2D<float4> color_texture : register(t1);
Texture2D<float4> velocity_texture : register(t2);
SamplerState linear_clamp : register(s0, space57);
RWTexture2D<float4> result_texture : register(u0);
RWStructuredBuffer<float4> motion_scratch : register(u0, space57);
static uint2 image_size, tile_count;
static float2 motion_coordinate_scale, velocity_to_radius;

void LoadMotionParameters() {
  color_texture.GetDimensions(image_size.x, image_size.y);
  uint2 motion_size;
  velocity_texture.GetDimensions(motion_size.x, motion_size.y);
  tile_count = (image_size + WITCHER_MOTION_TILE - 1u) / WITCHER_MOTION_TILE;
  motion_coordinate_scale = float2(motion_size) / float2(image_size);
  velocity_to_radius = float2(image_size) / 720.f;
}
float2 LoadMotionTile(uint2 tile, bool neighbor) {
  return motion_scratch[WITCHER_MOTION_HEADER + tile.y * tile_count.x + tile.x
                        + (neighbor ? tile_count.x * tile_count.y : 0u)].xy;
}

float2 MotionRadius(int2 pixel) {
  pixel = clamp(pixel, int2(0, 0), int2(image_size) - 1);
  if (motion_components == 0u) return 0.f;
  float camera_angle = (motion_components & WITCHER_MOTION_CAMERA) != 0u ? shutter_angle : 0.f;
  float object_angle = (motion_components & WITCHER_MOTION_OBJECT) != 0u ? object_shutter_angle : 0.f;
  if (max(camera_angle, object_angle) == 0.f) return 0.f;
  uint2 coordinate = uint2(float2(pixel) * motion_coordinate_scale);
  float4 motion = velocity_texture.Load(int3(coordinate, 0));
  float2 velocity = motion.xy;
  [branch]
  if (camera_angle != object_angle) {
    float2 uv = (float2(coordinate) + 0.5f) * motion_scratch[1].zw;
    float2 ndc = float2(uv.x * 2.f - 1.f, 1.f - uv.y * 2.f);
    float depth = UnpackMotionDepth(motion.zw);
    float3 previous = motion_scratch[2].xyw * ndc.x;
    previous = mad(motion_scratch[3].xyw, ndc.y, previous);
    previous = mad(motion_scratch[4].xyw, depth, previous);
    previous += motion_scratch[5].xyw;
    if (abs(previous.z) <= 1e-8f || !all(isfinite(previous))) return 0.f;
    float2 camera = -(uv - 0.5f - previous.xy * float2(0.5f, -0.5f) / previous.z);
    // Match the native RGBA16F motion target's precision before subtraction.
    // Static surfaces then cancel exactly instead of retaining camera noise.
    camera = f16tof32(f32tof16(camera));
    // Partition the visible trajectory by object motion. Independently scaling
    // the raw camera and residual vectors would break their cancellation on a
    // camera-followed subject. Instead, the existing object-only trail owns up
    // to the residual's pixel speed, and camera blur owns the remaining trail.
    // Equal strengths reproduce combined native motion exactly; every mixture
    // stays on the visible path and cannot exceed its larger shutter angle.
    float object_speed = length((velocity - camera) * float2(image_size));
    float screen_speed = length(velocity * float2(image_size));
    velocity *= lerp(camera_angle, object_angle, saturate(object_speed / max(screen_speed, 1e-8f)));
  } else {
    velocity *= camera_angle;
  }
  float2 radius = velocity * velocity_to_radius;
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
  // Native motion XY and lossless hardware depth ZW share the same pixels.
  float2 packed = velocity_texture.Load(int3(uint2(float2(pixel) * motion_coordinate_scale), 0)).zw;
  float depth = UnpackMotionDepth(packed);
  float4 projection = motion_scratch[0];
  float2 native_depth_scale = projection.xy;
  float2 native_depth_transform = projection.zw;
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
