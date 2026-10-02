// Private full-resolution reconstruction; not a game shader hash.
// Feature-aware two-direction gathering following Guertin et al. (2013/2014):
// https://research.nvidia.com/sites/default/files/pubs/2013-11_A-Fast-and/Guertin2013MotionBlur-small.pdf
#include "motion_blur.hlsli"

[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  if (any(id.xy >= image_size)) return;
  float4 center = color_texture.Load(int3(id.xy, 0));
  float2 velocity = MotionRadius(int2(id.xy));
  float speed = length(velocity);
  float depth = MotionDepth(int2(id.xy));
  if (diagnostic_view != 0u) {
    result_texture[id.xy] = float4(velocity, depth, frame_seconds);
    return;
  }

  // Stochastically blend adjacent dominant directions near tile boundaries;
  // interpolating the vectors would invent a direction that no object follows.
  float noise = MotionNoise(id.xy);
  float2 tile_position = (float2(id.xy) + 0.5f) / float(WITCHER_MOTION_TILE);
  float2 edge = frac(tile_position) - 0.5f;
  int2 tile = int2(tile_position);
  uint axis = abs(edge.x) > abs(edge.y) ? 0u : 1u;
  if (noise < saturate((abs(edge[axis]) - 0.25f) * 2.f)) {
    if (axis == 0u) tile.x += edge.x > 0.f ? 1 : -1;
    else tile.y += edge.y > 0.f ? 1 : -1;
  }
  float2 dominant = tile_texture.Load(int3(clamp(tile, 0, int2(tile_count) - 1), 0));
  if (dot(velocity, velocity) > dot(dominant, dominant)) dominant = velocity;
  float radius = length(dominant);
  if (radius <= 0.5f || max_radius <= 0.f) {
    result_texture[id.xy] = center;
    return;
  }

  float2 direction = dominant / radius;
  float2 perpendicular = float2(-direction.y, direction.x);
  if (dot(perpendicular, velocity) < 0.f) perpendicular = -perpendicular;
  float2 local_direction = MotionDirection(lerp(perpendicular, MotionDirection(velocity), saturate((speed - 0.5f) / 1.5f)));
  // Use paired samples in both directions. At high FPS the integration domain
  // gets shorter and needs fewer samples; a stationary foreground is still
  // visited when moving foreground coverage can spill over it.
  uint pairs = min(max_samples / 4u, max(2u, uint(ceil(radius))));
  float count = float(pairs * 4u);
  float center_speed = max(speed, 0.5f);
  float weight_sum = count / (40.f * center_speed);
  float3 sum = center.rgb * weight_sum;
  [loop]
  for (uint i = 0; i < pairs; ++i) {
    [unroll]
    for (uint axis_index = 0; axis_index < 2; ++axis_index) {
      float2 sample_direction = axis_index == 0u ? direction : local_direction;
      // Interleave the two strata so aligned directions do not spend half the
      // sample budget reading identical positions (visible on narrow lights).
      [unroll]
      for (int side = -1; side <= 1; side += 2) {
        // Shift the entire sample grid, rather than separating its two halves:
        // mirrored jitter otherwise leaves a hole around the center pixel.
        float signed_distance = (float(side) * (float(i) + 0.25f + float(axis_index) * 0.5f)
                               + (noise - 0.5f) * 0.475f) * radius / float(pairs);
        float distance = abs(signed_distance);
        float2 position = float2(id.xy) + sample_direction * signed_distance;
        if (any(position < 0.f) || any(position > float2(image_size) - 1.f)) continue;
        int2 nearest = int2(floor(position + 0.5f));
        float2 sample_velocity = MotionRadius(nearest);
        float sample_motion_length = length(sample_velocity);
        float sample_speed = max(sample_motion_length, 0.5f);
        float sample_depth = MotionDepth(nearest);
        // Relative, scene-scale-independent depth comparisons. Positive depths
        // increase away from the camera; f classifies a sample in front of p.
        float relative_depth = (depth - sample_depth) / max(min(depth, sample_depth), 1e-6f);
        float foreground = saturate(1.f + relative_depth);
        float background = saturate(1.f - relative_depth);
        // Co-moving surfaces have the same shutter path even across a depth
        // edge (for example buildings against the sky during camera rotation).
        // Their temporal reference is an ordinary image translation. Applying
        // occlusion rejection there overweights the foreground and leaves a
        // sharp silhouette inside its blur trail. Relax it in proportion to
        // motion agreement; zero-motion foregrounds retain full protection.
        float common_motion = saturate(1.f - length(sample_velocity - velocity)
            / max(min(speed, sample_motion_length), 1e-6f));
        foreground = lerp(foreground, 1.f, common_motion);
        background = lerp(background, 1.f, common_motion);
        float center_alignment = abs(dot(MotionDirection(velocity), sample_direction));
        float sample_alignment = abs(dot(MotionDirection(sample_velocity), sample_direction));
        float weight = foreground * saturate(1.f - distance / sample_speed) * sample_alignment
                     + background * saturate(1.f - distance / center_speed) * center_alignment;
        float overlap = min(center_speed, sample_speed);
        // The overlap term describes a shared moving surface. At an occlusion
        // boundary only the two directed coverage terms above apply; otherwise
        // the numerical half-pixel speed floor leaks background into a static
        // foreground even though its actual velocity is zero.
        weight += 2.f * (1.f - smoothstep(0.95f * overlap, 1.05f * overlap, distance))
                       * max(center_alignment, sample_alignment) * min(foreground, background);
        sum += color_texture.SampleLevel(linear_clamp, (position + 0.5f) / float2(image_size), 0).rgb * weight;
        weight_sum += weight;
      }
    }
  }
  result_texture[id.xy] = float4(sum / max(weight_sum, 1e-8f), center.a);
}
