// Private TileMax pass; not a game shader hash.
#include "motion_blur.hlsli"
groupshared float2 tile_velocities[256];

[numthreads(16, 16, 1)]
void main(uint3 group : SV_GroupID, uint3 thread : SV_GroupThreadID, uint index : SV_GroupIndex) {
  float2 longest = 0.f;
  [unroll]
  for (uint y = 0; y < 2; ++y) {
    [unroll]
    for (uint x = 0; x < 2; ++x) {
      uint2 pixel = group.xy * WITCHER_MOTION_TILE + thread.xy + uint2(x, y) * 16u;
      float2 candidate = all(pixel < image_size) ? MotionRadius(int2(pixel)) : 0.f;
      if (dot(candidate, candidate) > dot(longest, longest)) longest = candidate;
    }
  }
  tile_velocities[index] = longest;
  GroupMemoryBarrierWithGroupSync();
  [unroll]
  for (uint stride = 128; stride > 0; stride >>= 1) {
    if (index < stride) {
      float2 candidate = tile_velocities[index + stride];
      if (dot(candidate, candidate) > dot(tile_velocities[index], tile_velocities[index]))
        tile_velocities[index] = candidate;
    }
    GroupMemoryBarrierWithGroupSync();
  }
  if (index == 0) result_texture[group.xy] = float4(tile_velocities[0], 0.f, 0.f);
}
