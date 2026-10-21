#ifndef WITCHER_MOTION_RECONSTRUCT_HLSLI
#define WITCHER_MOTION_RECONSTRUCT_HLSLI
// Feature-aware two-direction gathering (Guertin et al., 2013/2014).
#include "motion_blur.hlsli"

float4 ReconstructMotion(float2 pixel, bool half_pixel = false) {
  float4 center = !half_pixel
                      ? color_texture.Load(int3(int2(pixel), 0))
                      : color_texture.SampleLevel(linear_clamp, (pixel + 0.5f) / float2(image_size), 0);
  float3 center_motion = LoadMotion(int2(floor(pixel + 0.5f)));
  float2 velocity = center_motion.xy;
  float speed = length(velocity);
  float depth = center_motion.z;
  if (diagnostic_view == 1u) {
    return float4(velocity, depth, frame_seconds);
  }

  // Stochastically blend adjacent dominant directions near tile boundaries;
  // interpolating the vectors would invent a direction that no object follows.
  float noise = MotionNoise(uint2(pixel));
  float2 tile_position = (float2(pixel) + 0.5f) / float(WITCHER_MOTION_TILE);
  float2 edge = frac(tile_position) - 0.5f;
  int2 tile = int2(tile_position);
  uint axis = abs(edge.x) > abs(edge.y) ? 0u : 1u;
  if (noise < saturate((abs(edge[axis]) - 0.25f) * 2.f)) {
    if (axis == 0u) tile.x += edge.x > 0.f ? 1 : -1;
    else tile.y += edge.y > 0.f ? 1 : -1;
  }
  float4 neighborhood = LoadMotionTile(uint2(clamp(tile, 0, int2(tile_count) - 1)), true);
  float2 dominant = neighborhood.xy;
  if (dot(velocity, velocity) > dot(dominant, dominant)) {
    dominant = velocity;
    neighborhood.z = 3.402823466e+38f;
  }
  float radius = length(dominant);
  if (radius <= 0.5f) {
    return center;
  }

  // Within a one-percent motion bound, common-motion depth relaxation is
  // already nearly complete. Reuse the center trajectory for the weights,
  // retaining the same dense full-resolution color samples. Any meaningful
  // silhouette or motion disagreement keeps the original feature-aware path.
  bool coherent = neighborhood.z <= radius * 0.01f && length(velocity - dominant) <= radius * 0.01f;
  float2 direction = dominant / radius;
  float2 perpendicular = float2(-direction.y, direction.x);
  if (dot(perpendicular, velocity) < 0.f) perpendicular = -perpendicular;
  float2 local_direction = MotionDirection(lerp(perpendicular, MotionDirection(velocity), saturate((speed - 0.5f) / 1.5f)));
  // Clip sampling, not motion, to the visible image. This retains shutter
  // length/weights while avoiding offscreen taps for extreme motion or cuts.
  float2 domains[2];
  domains[0] = MotionInterval(direction, -float2(pixel), float2(image_size - 1u) - float2(pixel), radius);
  domains[1] = MotionInterval(local_direction, -float2(pixel), float2(image_size - 1u) - float2(pixel), radius);
  float2 half_spans = float2(domains[0].y - domains[0].x, domains[1].y - domains[1].x) * 0.5f;
  float span = max(half_spans.x, half_spans.y);
  if (span <= 0.5f) {
    return center;
  }
  // Quality is a hard work budget, independent of shutter length. Increasing
  // samples with velocity creates positive feedback: a slower frame produces
  // more motion, which requests more GPU work and slows the next frame again.
  // Keep the full trajectory; only subpixel/short trails need fewer samples.
  uint pairs = min(max_samples / 4u, max(2u, uint(ceil(span))));
  float count = float(pairs * 4u);
  if (diagnostic_view == 2u) {
    return float4(count, radius, span, center.a);
  }
  float center_speed = max(speed, 0.5f);
  float2 center_direction = MotionDirection(velocity);
  float2 center_alignments = abs(float2(dot(center_direction, direction), dot(center_direction, local_direction)));
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
        float signed_distance = (domains[axis_index].x + domains[axis_index].y) * 0.5f
            + (float(side) * (float(i) + 0.25f + float(axis_index) * 0.5f)
               + (noise - 0.5f) * 0.5f) * half_spans[axis_index] / float(pairs);
        float distance = abs(signed_distance);
        float2 position = float2(pixel) + sample_direction * signed_distance;
        if (any(position < 0.f) || any(position > float2(image_size) - 1.f)) continue;
        int2 nearest = int2(floor(position + 0.5f));
        float center_alignment = center_alignments[axis_index];
        float weight;
        [branch]
        if (coherent) {
          // Constant-trajectory weights avoid all per-tap motion reads and
          // reprojection. Exact coherent motion gives the original weights.
          weight = (2.f * saturate(1.f - distance / center_speed)
                    + 2.f * (1.f - smoothstep(0.95f * center_speed, 1.05f * center_speed, distance)))
                   * center_alignment;
        } else {
          float3 sample_motion = LoadMotion(nearest);
          float2 sample_velocity = sample_motion.xy;
          float sample_motion_length = length(sample_velocity);
          float sample_speed = max(sample_motion_length, 0.5f);
          float sample_depth = sample_motion.z;
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
          float sample_alignment = abs(dot(MotionDirection(sample_velocity), sample_direction));
          weight = foreground * saturate(1.f - distance / sample_speed) * sample_alignment
                       + background * saturate(1.f - distance / center_speed) * center_alignment;
          float overlap = min(center_speed, sample_speed);
          // The overlap term describes a shared moving surface. At an occlusion
          // boundary only the two directed coverage terms above apply; otherwise
          // the numerical half-pixel speed floor leaks background into a static
          // foreground even though its actual velocity is zero.
          weight += 2.f * (1.f - smoothstep(0.95f * overlap, 1.05f * overlap, distance))
                         * max(center_alignment, sample_alignment) * min(foreground, background);
        }
        // Different axis lengths need quadrature weights proportional to the
        // integration interval rather than equal weight per visible sample.
        weight *= half_spans[axis_index] / max(span, 1e-6f);
        sum += color_texture.SampleLevel(linear_clamp, (position + 0.5f) / float2(image_size), 0).rgb * weight;
        weight_sum += weight;
      }
    }
  }
  return float4(sum / max(weight_sum, 1e-8f), center.a);
}

#endif
