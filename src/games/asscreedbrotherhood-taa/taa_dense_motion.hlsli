/* Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT */
#ifndef BROTHERHOOD_DENSE_MOTION_HLSLI
#define BROTHERHOOD_DENSE_MOTION_HLSLI
#include "./taa_reprojection.hlsli"

// XY: previous-current UV, excluding jitter. Z: estimated/invalid pose.
// W: valid camera pair/vector. Shared by DLAA and frame-generation export.
float4 DenseMotion(float2 uv, float depth, float4 object, float4 size_jitter,
                   float4 rows[4], bool pair_valid) {
  float2 motion = 0.f;
  float previous_depth;
  bool valid = pair_valid;
  bool estimated = false;
  if (object.w > 0.f) {
    motion = object.xy;
    estimated = object.z < 0.f;
  } else {
    valid = AC2ReprojectCamera(uv, depth, size_jitter.xy, size_jitter.zw, 0.f.xx,
                              rows[0], rows[1], rows[2], rows[3], motion, previous_depth) && valid;
    motion += size_jitter.zw * size_jitter.xy;
    estimated = object.w < 0.f;
  }
  valid = valid && all(abs(motion) < 2.f);
  return float4(valid ? motion : 0.f, !valid || estimated ? 1.f : 0.f, valid ? 1.f : 0.f);
}
#endif
