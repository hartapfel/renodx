// Private depth snapshot, taken while native motion conversion already has the
// depth texture bound for compute reads. This avoids changing the game's
// multi-plane depth/stencil state during the later full-resolution resolve.
#include "motion_blur.hlsli"
[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  if (any(id.xy >= image_size)) return;
  result_texture[id.xy] = float4(depth_texture.Load(int3(id.xy, 0)), 0.f, 0.f, 0.f);
}
