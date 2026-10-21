// Private NeighborMax pass; not a game shader hash.
#include "motion_blur.hlsli"

[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  LoadMotionParameters();
  if (any(id.xy >= tile_count)) return;
  float2 longest = LoadMotionTile(id.xy, false).xy;
  // A fixed 3x3 neighborhood truncates trails longer than one tile. Search the
  // coarse grid instead and keep only tiles whose shutter sweep can reach us.
  // The Minkowski rectangle accounts for the unknown source/target positions
  // within their tiles, including horizontal, vertical and diagonal motion.
  [loop]
  for (uint y = 0u; y < tile_count.y; ++y) {
    [loop]
    for (uint x = 0u; x < tile_count.x; ++x) {
      uint2 position = uint2(x, y);
      float2 candidate = LoadMotionTile(position, false).xy;
      if (dot(candidate, candidate) <= dot(longest, longest)) continue;
      float2 offset = (float2(id.xy) - float2(position)) * float(WITCHER_MOTION_TILE);
      float2 interval = MotionInterval(candidate, offset - float(WITCHER_MOTION_TILE), offset + float(WITCHER_MOTION_TILE), 1.f);
      if (interval.x <= interval.y) longest = candidate;
    }
  }
  // Conservative motion bound over every tile either gather direction could
  // touch. Z bounds each tile's deviation from its own longest vector. Include
  // both inter-tile and intra-tile variation, including slower/stationary items.
  // The extra tile also covers stochastic neighboring-tile selection.
  float deviation = 0.f;
  float radius = length(longest);
  [loop]
  for (uint bound_y = 0u; bound_y < tile_count.y; ++bound_y) {
    [loop]
    for (uint bound_x = 0u; bound_x < tile_count.x; ++bound_x) {
      float2 offset = abs(float2(int2(id.xy) - int2(bound_x, bound_y))) * float(WITCHER_MOTION_TILE);
      if (any(offset > radius + 2.f * float(WITCHER_MOTION_TILE))) continue;
      float4 candidate = LoadMotionTile(uint2(bound_x, bound_y), false);
      deviation = max(deviation, length(candidate.xy - longest) + candidate.z);
    }
  }
  motion_scratch[WITCHER_MOTION_HEADER + tile_count.x * tile_count.y + id.y * tile_count.x + id.x] = float4(longest, deviation, 0.f);
}
