// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_REMASTERED_CONTACT_NATIVE_MOTION
#define WITCHER_REMASTERED_CONTACT_NATIVE_MOTION
// Native G-buffer motion (30DE6E02 and ConvertMotionVectors 9F1C32F1):
// xy = current-minus-previous UV, z = current-minus-previous raw depth.
// Both camera endpoints use CURRENT jitter. The history caller adds the
// previous-minus-current jitter difference once, after decoding this vector.
// Return previous-minus-current UV and previous view depth; z < 0 is invalid.
float3 ContactNativeMotion(float4 encoded, float raw, float2 linearization, float2 depth_conversion) {
  float previous_raw = raw - encoded.z;
  if (!all(isfinite(encoded)) || encoded.w != 1.f || any(abs(encoded.xy) > 1.f)
      || !isfinite(previous_raw) || previous_raw < 0.f || previous_raw > 1.f) return float3(0, 0, -1);
  // The previous endpoint uses the current projection's depth coefficients,
  // just as CameraCB rows 49..52 do, even when the history projection changed.
  float reciprocal_depth = (previous_raw * depth_conversion.x + depth_conversion.y) * linearization.x + linearization.y;
  if (!isfinite(reciprocal_depth) || reciprocal_depth <= 1.e-7f) return float3(0, 0, -1);
  return float3(-encoded.xy, rcp(reciprocal_depth));
}
#endif
