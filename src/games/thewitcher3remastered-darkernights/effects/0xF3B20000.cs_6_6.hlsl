/* Copyright (C) 2026 Hartapfel
 * SPDX-License-Identifier: MIT
 */
#include "../vegetation_saturation.hlsli"
// Root buffer UAV: no descriptor heap is needed or changed by this pass.
RWByteAddressBuffer scene : register(u0);
cbuffer Parameters : register(b0) {
  uint width;
  uint height;
  uint row_pitch;
  float night_delta;
};
[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  if (id.x >= width || id.y >= height) return;
  const uint offset = id.y * row_pitch + id.x * 8u;
  const uint2 packed = scene.Load2(offset);
  const float3 rgb = float3(f16tof32(packed.x & 65535u),
      f16tof32(packed.x >> 16u), f16tof32(packed.y & 65535u));
  float3 result = WitcherVegetationSaturation(rgb, night_delta);
  // Reject unrepresentable results instead of introducing infinities into
  // the native half-float scene. No display-range/gamut clamp is added.
  if (any(isnan(result)) || any(isinf(result)) || any(abs(result) > 65504.f)) result = rgb;
  // Preserve alpha's original bits, including native luminance metadata.
  scene.Store2(offset, uint2(f32tof16(result.x) | (f32tof16(result.y) << 16u),
      f32tof16(result.z) | (packed.y & 0xFFFF0000u)));
}
