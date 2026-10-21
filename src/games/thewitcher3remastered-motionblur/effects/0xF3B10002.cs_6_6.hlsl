// Full-resolution reconstruction.
#ifndef WITCHER_MOTION_CACHED
#define WITCHER_MOTION_UNCACHED 1
#endif
#include "motion_reconstruct.hlsli"
[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  LoadMotionParameters();
  if (any(id.xy >= image_size)) return;
  result_texture[id.xy] = ReconstructMotion(float2(id.xy));
}
