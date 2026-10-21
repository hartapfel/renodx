/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#ifndef WITCHER_MOTION_BLUR_HLSLI
#define WITCHER_MOTION_BLUR_HLSLI

// Coordinates and velocities are in OUTPUT pixels. Inputs can be rendered at
// a lower resolution; the optional reconstruction buffer is explicitly half size.
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
  uint cache_enabled;
  uint half_resolution;
  uint2 cache_extent;
  uint2 half_extent;
};
Texture2D<float4> color_texture : register(t1);
Texture2D<float4> velocity_texture : register(t2);
SamplerState linear_clamp : register(s0, space57);
RWTexture2D<float4> result_texture : register(u0);
RWStructuredBuffer<float4> motion_scratch : register(u0, space57);
static uint2 image_size, tile_count, motion_size;
static bool motion_cache_valid = false, half_cache_valid = false;
static uint half_cache_offset = 0u;
static float2 motion_coordinate_scale = 0.f, velocity_to_radius = 0.f, motion_reciprocal = 0.f, shutter_angles = 0.f;
static float4 depth_projection = 0.f, camera_row0 = 0.f, camera_row1 = 0.f, camera_row2 = 0.f, camera_row3 = 0.f;

void LoadMotionParameters() {
  color_texture.GetDimensions(image_size.x, image_size.y);
  velocity_texture.GetDimensions(motion_size.x, motion_size.y);
  // Root UAVs have no descriptor bounds. Never infer their capacity from a
  // texture: menu viewports can be smaller than their pooled allocations.
  motion_cache_valid = cache_enabled != 0u && all(motion_size <= cache_extent);
  half_cache_valid = half_resolution != 0u && motion_cache_valid
                     && all((image_size + 1u) / 2u <= half_extent);
  half_cache_offset = WITCHER_MOTION_CACHE + cache_extent.x * cache_extent.y;
  tile_count = (image_size + WITCHER_MOTION_TILE - 1u) / WITCHER_MOTION_TILE;
  motion_coordinate_scale = float2(motion_size) / float2(image_size);
  velocity_to_radius = float2(image_size) / 720.f;
  shutter_angles = float2((motion_components & WITCHER_MOTION_CAMERA) != 0u ? shutter_angle : 0.f,
                         (motion_components & WITCHER_MOTION_OBJECT) != 0u ? object_shutter_angle : 0.f);
  // These UAV-backed constants are immutable during the dispatch. Load them
  // once per thread, outside the gather loop, rather than once per sample.
#if !defined(WITCHER_MOTION_BUILD_CACHE) && !defined(WITCHER_MOTION_UNCACHED)
  if (motion_cache_valid) return;
#endif
  depth_projection = motion_scratch[0];
  if (shutter_angles.x != shutter_angles.y) {
    motion_reciprocal = motion_scratch[1].zw;
    camera_row0 = motion_scratch[2];
    camera_row1 = motion_scratch[3];
    camera_row2 = motion_scratch[4];
    camera_row3 = motion_scratch[5];
  }
}
float4 LoadMotionTile(uint2 tile, bool neighbor) {
  return motion_scratch[WITCHER_MOTION_HEADER + tile.y * tile_count.x + tile.x
                        + (neighbor ? tile_count.x * tile_count.y : 0u)];
}

// Radius and linear depth share one native texture load and one depth decode.
// TileMax discards Z; reconstruction reuses all three components for weighting.
float3 DecodeMotion(uint2 coordinate) {
  float4 motion = velocity_texture.Load(int3(coordinate, 0));
  float depth = UnpackMotionDepth(motion.zw);
  float linear_depth = rcp(max((depth * depth_projection.z + depth_projection.w)
                             * depth_projection.x + depth_projection.y, 1e-8f));
  float2 velocity = motion.xy;
  [branch]
  if (shutter_angles.x != shutter_angles.y) {
    float2 uv = (float2(coordinate) + 0.5f) * motion_reciprocal;
    float2 ndc = float2(uv.x * 2.f - 1.f, 1.f - uv.y * 2.f);
    float3 previous = camera_row0.xyw * ndc.x;
    previous = mad(camera_row1.xyw, ndc.y, previous);
    previous = mad(camera_row2.xyw, depth, previous);
    previous += camera_row3.xyw;
    if (abs(previous.z) > 1e-8f && all(isfinite(previous))) {
      float2 camera = -(uv - 0.5f - previous.xy * float2(0.5f, -0.5f) / previous.z);
      camera = f16tof32(f32tof16(camera));
      // Preserve the visible-trajectory partition and camera-follow cancellation.
      float object_speed = length((velocity - camera) * float2(image_size));
      float screen_speed = length(velocity * float2(image_size));
      velocity *= lerp(shutter_angles.x, shutter_angles.y, saturate(object_speed / max(screen_speed, 1e-8f)));
    } else {
      velocity = 0.f;
    }
  } else {
    velocity *= shutter_angles.x;
  }
  float2 radius = velocity * velocity_to_radius;
  if (!all(isfinite(radius))) radius = 0.f;
  return float3(radius, linear_depth);
}

float3 LoadMotion(int2 pixel) {
  pixel = clamp(pixel, int2(0, 0), int2(image_size) - 1);
  uint2 coordinate = min(uint2(float2(pixel) * motion_coordinate_scale), motion_size - 1u);
#if !defined(WITCHER_MOTION_UNCACHED)
  if (motion_cache_valid)
    return motion_scratch[WITCHER_MOTION_CACHE + coordinate.y * motion_size.x + coordinate.x].xyz;
#endif
  return DecodeMotion(coordinate);
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

float2 MotionDirection(float2 velocity) {
  return velocity * rsqrt(max(dot(velocity, velocity), 1e-12f));
}

// Frame-invariant spatial noise avoids adding temporal shimmer after DLSS/TAA.
float MotionNoise(uint2 pixel) {
  return frac(52.9829189f * frac(dot(float2(pixel), float2(0.06711056f, 0.00583715f))));
}

#endif
