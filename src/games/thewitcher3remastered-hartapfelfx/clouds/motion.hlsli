// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "shadow_inputs.hlsli"
#ifndef HFCLOUD_MOTION_FRAME
cbuffer HartapfelCloudMotionFrame : register(b12) { float4 cloud_motion_frame[341]; }
#define HFCLOUD_MOTION_FRAME cloud_motion_frame
#endif
float4 CloudPackedMotion(int2 pixel, uint2 size, uint pitch, uint offset) {
  pixel = clamp(pixel, 0, int2(size) - 1);
  uint2 packed = HartapfelCloudData.Load2(offset + uint(pixel.y) * pitch + uint(pixel.x) * 8u);
  return float4(f16tof32(packed.x & 65535u), f16tof32(packed.x >> 16), f16tof32(packed.y & 65535u), f16tof32(packed.y >> 16));
}
float4 CloudNativeMotion(float4 native_motion, float depth, int2 position) {
  // Native reversed depth is zero for sky. Qualify the GPU-published field at
  // every consumer, including earlier PT denoising passes before the main sky.
  if (depth > 1.e-7f || HartapfelCloudData.Load(160) == 0
      || any(asfloat(HartapfelCloudData.Load3(112)) != HFCLOUD_MOTION_FRAME[0].xyz)
      || any(HartapfelCloudData.Load4(128) != asuint(HFCLOUD_MOTION_FRAME[286]))
      || any(asfloat(HartapfelCloudData.Load4(144)) != HFCLOUD_MOTION_FRAME[23])
      || any(asfloat(HartapfelCloudData.Load4(192)) != HFCLOUD_MOTION_FRAME[17])
      || any(asfloat(HartapfelCloudData.Load4(208)) != HFCLOUD_MOTION_FRAME[18])) return native_motion;
  uint4 layout = HartapfelCloudData.Load4(96);
  uint2 size = layout.xy;
  if (any(size == 0) || layout.z < size.x * 8u) return native_motion;
  float2 pixel = (position + .5f) * HFCLOUD_MOTION_FRAME[23].zw * size - .5f;
  int2 cell = int2(floor(pixel));
  float2 f = frac(pixel);
  float4 flow = lerp(lerp(CloudPackedMotion(cell, size, layout.z, layout.w), CloudPackedMotion(cell + int2(1, 0), size, layout.z, layout.w), f.x),
                     lerp(CloudPackedMotion(cell + int2(0, 1), size, layout.z, layout.w), CloudPackedMotion(cell + 1, size, layout.z, layout.w), f.x), f.y);
  // Native xy is current-minus-previous UV, z is hardware-depth delta and w
  // marks object motion. The native converters produce their own output
  // conventions. Preserve their camera fallback for low-confidence mixtures.
  if (flow.z >= .5f && flow.w > .9f && all(isfinite(flow.xy)) && all(abs(flow.xy) < 1.f))
    return float4(-flow.xy, 0.f, 1.f);
  return native_motion;
}
