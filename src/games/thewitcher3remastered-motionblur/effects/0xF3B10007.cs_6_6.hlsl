// Quarter-pixel-count reconstruction into a private half-resolution buffer.
#define WITCHER_MOTION_CACHED 1
#include "motion_reconstruct.hlsli"
[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  LoadMotionParameters();
  if (!half_cache_valid) return;
  uint2 half_size = (image_size + 1u) / 2u;
  if (any(id.xy >= half_size)) return;
  float2 pixel = min(float2(id.xy * 2u) + 0.5f, float2(image_size - 1u));
  motion_scratch[half_cache_offset + id.y * half_size.x + id.x] = ReconstructMotion(pixel, true);
}
