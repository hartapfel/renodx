// Private NeighborMax pass; not a game shader hash.
#include "motion_blur.hlsli"

[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  if (any(id.xy >= tile_count)) return;
  float2 longest = tile_texture.Load(int3(id.xy, 0));
  // A fixed 3x3 neighborhood truncates trails longer than one tile. Search the
  // coarse grid instead and keep only tiles whose shutter sweep can reach us.
  // The Minkowski rectangle accounts for the unknown source/target positions
  // within their tiles, including horizontal, vertical and diagonal motion.
  [loop]
  for (uint y = 0u; y < tile_count.y; ++y) {
    [loop]
    for (uint x = 0u; x < tile_count.x; ++x) {
      uint2 position = uint2(x, y);
      float2 candidate = tile_texture.Load(int3(position, 0));
      if (dot(candidate, candidate) <= dot(longest, longest)) continue;
      float2 offset = (float2(id.xy) - float2(position)) * float(WITCHER_MOTION_TILE);
      float2 interval = MotionInterval(candidate, offset - float(WITCHER_MOTION_TILE), offset + float(WITCHER_MOTION_TILE), 1.f);
      if (interval.x <= interval.y) longest = candidate;
    }
  }
  result_texture[id.xy] = float4(longest, 0.f, 0.f);
}
