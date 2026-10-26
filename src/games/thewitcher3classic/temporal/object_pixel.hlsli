#ifndef WITCHER_MOTION_DIMENSIONS
// PS b12 is native lighting/fog state and need not match the VS frame buffer.
// b11 is unused by all audited non-foliage material PSs. Bind the same VS frame
// data as before here, without replacing the native pixel-stage frame constants.
cbuffer MotionFrame : register(b11) { float4 motion_frame[269]; }
#define WITCHER_MOTION_DIMENSIONS motion_frame[23].xy
#define WITCHER_MOTION_JITTER motion_frame[15].xy
#endif

void WriteObjectMotion(float4 position, float4 previous_clip, float history,
                       out float2 motion, out float depth) {
  const float2 current_uv = position.xy / WITCHER_MOTION_DIMENSIONS
                            - WITCHER_MOTION_JITTER * float2(0.5f, -0.5f);
  const float2 previous_uv = previous_clip.xy / max(previous_clip.w, 1e-6f)
                            * float2(0.5f, -0.5f) + 0.5f;
  motion = previous_uv - current_uv;
  const bool valid = history > 0.5f && previous_clip.w > 1e-6f
                     && all(isfinite(motion)) && all(abs(motion) <= 1.f);
  if (!valid) motion = 0.f;
  // Sign marks unavailable history; magnitude retains native surface depth.
  // This also lets preparation reject a later opaque surface covering a vector.
  depth = asfloat(asuint(position.z) | (valid ? 0u : 0x80000000u));
}
