// Private TileMax pass; not a game shader hash.
#include "motion_blur.hlsli"
groupshared float2 tile_velocities[256];
groupshared float4 tile_bounds[256];

[numthreads(16, 16, 1)]
void main(uint3 group : SV_GroupID, uint3 thread : SV_GroupThreadID, uint index : SV_GroupIndex) {
  LoadMotionParameters();
  if (any(group.xy >= tile_count)) return;
  float2 longest = 0.f;
  float2 minimum = 3.402823466e+38f, maximum = -3.402823466e+38f;
  [loop]
  for (uint y = 0; y < WITCHER_MOTION_TILE / 16u; ++y) {
    [loop]
    for (uint x = 0; x < WITCHER_MOTION_TILE / 16u; ++x) {
      uint2 pixel = group.xy * WITCHER_MOTION_TILE + thread.xy + uint2(x, y) * 16u;
      float2 candidate = all(pixel < image_size) ? LoadMotion(int2(pixel)).xy : 0.f;
      if (all(pixel < image_size)) {
        minimum = min(minimum, candidate);
        maximum = max(maximum, candidate);
      }
      if (dot(candidate, candidate) > dot(longest, longest)) longest = candidate;
    }
  }
  tile_velocities[index] = longest;
  tile_bounds[index] = float4(minimum, maximum);
  GroupMemoryBarrierWithGroupSync();
  [unroll]
  for (uint stride = 128; stride > 0; stride >>= 1) {
    if (index < stride) {
      tile_bounds[index].xy = min(tile_bounds[index].xy, tile_bounds[index + stride].xy);
      tile_bounds[index].zw = max(tile_bounds[index].zw, tile_bounds[index + stride].zw);
      float2 candidate = tile_velocities[index + stride];
      if (dot(candidate, candidate) > dot(tile_velocities[index], tile_velocities[index]))
        tile_velocities[index] = candidate;
    }
    GroupMemoryBarrierWithGroupSync();
  }
  if (index == 0) {
    float deviation = length(max(abs(tile_bounds[0].xy - tile_velocities[0]), abs(tile_bounds[0].zw - tile_velocities[0])));
    motion_scratch[WITCHER_MOTION_HEADER + group.y * tile_count.x + group.x] = float4(tile_velocities[0], deviation, 0.f);
  }
}
