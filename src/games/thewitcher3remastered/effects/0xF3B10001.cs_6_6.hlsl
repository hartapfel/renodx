// Private NeighborMax pass; not a game shader hash.
#include "motion_blur.hlsli"

[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  if (any(id.xy >= tile_count)) return;
  float2 longest = 0.f;
  [unroll]
  for (int y = -1; y <= 1; ++y) {
    [unroll]
    for (int x = -1; x <= 1; ++x) {
      int2 position = clamp(int2(id.xy) + int2(x, y), 0, int2(tile_count) - 1);
      float2 candidate = tile_texture.Load(int3(position, 0));
      // A diagonal tile must sweep toward this tile. Motion has symmetric
      // shutter support, so the two signs along the same line are equivalent.
      bool can_overlap = x == 0 || y == 0 || candidate.x * candidate.y * float(x * y) > 0.f;
      if (can_overlap && dot(candidate, candidate) > dot(longest, longest)) longest = candidate;
    }
  }
  result_texture[id.xy] = float4(longest, 0.f, 0.f);
}
