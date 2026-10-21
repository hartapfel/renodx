// Bilateral reconstruction of the half-resolution result. Keep unblurred
// surfaces at full resolution; fall back at incompatible depth/motion edges.
#define WITCHER_MOTION_CACHED 1
#include "motion_reconstruct.hlsli"

[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  LoadMotionParameters();
  if (any(id.xy >= image_size)) return;
  float3 center = LoadMotion(int2(id.xy));
  if (!half_cache_valid || length(center.xy) <= 0.5f || diagnostic_view != 0u) {
    result_texture[id.xy] = ReconstructMotion(float2(id.xy));
    return;
  }
  uint2 half_size = (image_size + 1u) / 2u;
  float2 position = (float2(id.xy) - 0.5f) * 0.5f;
  int2 base = int2(floor(position));
  float2 blend = frac(position);
  float3 sum = 0.f;
  float weight_sum = 0.f;
  [unroll]
  for (uint y = 0u; y < 2u; ++y) {
    [unroll]
    for (uint x = 0u; x < 2u; ++x) {
      uint2 tap = uint2(clamp(base + int2(x, y), 0, int2(half_size) - 1));
      float3 motion = LoadMotion(int2(min(tap * 2u + 1u, image_size - 1u)));
      float relative_depth = abs(center.z - motion.z) / max(min(center.z, motion.z), 1e-6f);
      float relative_motion = length(center.xy - motion.xy) / max(length(center.xy), 0.5f);
      float weight = (x != 0u ? blend.x : 1.f - blend.x) * (y != 0u ? blend.y : 1.f - blend.y);
      weight *= 1.f - smoothstep(0.02f, 0.05f, relative_depth);
      weight *= 1.f - smoothstep(0.02f, 0.05f, relative_motion);
      sum += motion_scratch[half_cache_offset + tap.y * half_size.x + tap.x].rgb * weight;
      weight_sum += weight;
    }
  }
  if (weight_sum < 0.5f) {
    result_texture[id.xy] = ReconstructMotion(float2(id.xy));
  } else {
    result_texture[id.xy] = float4(sum / weight_sum, color_texture.Load(int3(id.xy, 0)).a);
  }
}
