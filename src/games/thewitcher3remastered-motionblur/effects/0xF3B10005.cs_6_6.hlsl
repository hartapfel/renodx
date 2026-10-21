// Decode depth and separate motion once per native motion texel, before all
// reduction/gather passes. FP32 storage preserves the full-resolution filter.
#define WITCHER_MOTION_BUILD_CACHE 1
#include "motion_blur.hlsli"

[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  LoadMotionParameters();
  if (!motion_cache_valid) return;
  if (any(id.xy >= motion_size)) return;
  motion_scratch[WITCHER_MOTION_CACHE + id.y * motion_size.x + id.x] = float4(DecodeMotion(id.xy), 0.f);
}
