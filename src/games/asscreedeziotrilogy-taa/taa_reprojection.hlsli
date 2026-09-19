/*
 * Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */

#ifndef AC2_TAA_REPROJECTION_HLSLI
#define AC2_TAA_REPROJECTION_HLSLI

float CurrentMotionDepth(float native_depth, float motion_depth) {
  // Replay tests native depth for opaque coverage and dominant-alpha hair.
  // Later passes can supply visible surfaces absent from the earlier R32 MRT.
  // Keep R32 precision when it agrees; otherwise use the visible replay depth.
  if (motion_depth == 0.f || abs(abs(motion_depth) - (1.f - native_depth)) <= max(2.e-6f, (1.f - native_depth) * 0.005f))
    return native_depth;
  return saturate(1.f - abs(motion_depth));
}

float4 sky_clip_rows[4] : register(c6);

// Native MRT1 contains D3D clip z/w, not linear view distance. The DOF
// reconstruction c2.y / (depth + c2.x) must NOT be applied to this input.
// Matrix rows are previousVP * inverse(currentVP). Return previous-current UV
// motion so the resolver can sample history at currentUV + motion.
// Both cameras must be unjittered; jitter is handled explicitly in pixel units.
bool AC2ReprojectCamera(float2 uv, float depth, float2 inverse_size,
                        float2 current_jitter_pixels, float2 previous_jitter_pixels,
                        float4 previous_clip_row0, float4 previous_clip_row1,
                        float4 previous_clip_row2, float4 previous_clip_row3,
                        out float2 motion_uv, out float previous_depth) {
  float2 unjittered_uv = uv - current_jitter_pixels * inverse_size;
  float4 clip = float4(unjittered_uv * float2(2.f, -2.f) + float2(-1.f, 1.f), depth, 1.f);
  float4 previous_clip = float4(dot(previous_clip_row0, clip), dot(previous_clip_row1, clip),
                                dot(previous_clip_row2, clip), dot(previous_clip_row3, clip));
  [branch] if (depth == 1.f) {
    previous_clip = float4(dot(sky_clip_rows[0], clip), dot(sky_clip_rows[1], clip),
                           dot(sky_clip_rows[3], clip), dot(sky_clip_rows[3], clip));
  }
  float inverse_w = rcp(max(previous_clip.w, 1.e-6f));
  float2 previous_uv = previous_clip.xy * inverse_w * float2(0.5f, -0.5f) + 0.5f;
  previous_uv += previous_jitter_pixels * inverse_size;
  motion_uv = previous_uv - uv;
  previous_depth = depth == 1.f ? 1.f : previous_clip.z * inverse_w;
  // Frustum bounds describe history availability, not whether this vector
  // exists. Keep them in the resolve so diagnostic colors do not flash when
  // a valid ray points outside the old view (including its far plane).
  return previous_clip.w > 1.e-6f && depth >= 0.f && depth <= 1.f;
}

#endif
