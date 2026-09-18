// Authored native DX9 pass, not a replacement for a game shader hash.
#include "./taa_reprojection.hlsli"

sampler2D scene_texture : register(s0);
sampler2D depth_texture : register(s1);
sampler2D history_texture : register(s2);
sampler2D history_depth_texture : register(s3);
sampler2D history_count_texture : register(s4);
sampler2D object_motion_texture : register(s5);
float4 previous_clip_rows[4] : register(c0);
// inverse size, current jitter in pixels
float4 size_jitter : register(c4);
// object motion (2 also means stationary camera), source linear,
// history valid (2 = native MSAA resolve with synchronized jitter), preview mode
float4 history_info : register(c5);

struct ResolveOutput {
  float4 color_depth : COLOR0;
  float4 sample_count : COLOR1;
};

ResolveOutput StoreHistory(float3 color, float depth, float sample_count) {
  ResolveOutput output;
  output.color_depth = float4(color, saturate(1.f - depth));
  output.sample_count = sample_count.xxxx;
  return output;
}

// Repeated bilinear history resampling erases detail during subpixel motion.
// Separable Catmull-Rom reconstructs the 4x4 footprint with nine bilinear taps:
// combine the positive middle weights on each axis. The variance box below
// still clips the result, including cubic overshoot near silhouettes.
float3 SampleCubic(sampler2D source_texture, float2 uv) {
  float2 position = uv / size_jitter.xy - 0.5f;
  float2 base = floor(position);
  float2 f = position - base;
  float2 w0 = f * (-0.5f + f * (1.f - 0.5f * f));
  float2 w1 = 1.f + f * f * (-2.5f + 1.5f * f);
  float2 w2 = f * (0.5f + f * (2.f - 1.5f * f));
  float2 w3 = f * f * (-0.5f + 0.5f * f);
  float2 middle = w1 + w2;
  float2 p0 = (base - 0.5f) * size_jitter.xy;
  float2 p1 = (base + 0.5f + w2 / middle) * size_jitter.xy;
  float2 p2 = (base + 2.5f) * size_jitter.xy;
  return (tex2D(source_texture, float2(p0.x, p0.y)).rgb * w0.x
          + tex2D(source_texture, float2(p1.x, p0.y)).rgb * middle.x
          + tex2D(source_texture, float2(p2.x, p0.y)).rgb * w3.x) * w0.y
       + (tex2D(source_texture, float2(p0.x, p1.y)).rgb * w0.x
          + tex2D(source_texture, float2(p1.x, p1.y)).rgb * middle.x
          + tex2D(source_texture, float2(p2.x, p1.y)).rgb * w3.x) * middle.y
       + (tex2D(source_texture, float2(p0.x, p2.y)).rgb * w0.x
          + tex2D(source_texture, float2(p1.x, p2.y)).rgb * middle.x
          + tex2D(source_texture, float2(p2.x, p2.y)).rgb * w3.x) * w3.y;
}

ResolveOutput ResolvePixel(float2 uv) {
  // A second, diagnostic-only draw reads the completed count buffer. Never
  // feed these colors into temporal history or change the resolve's decisions.
#ifndef TAA_MOTION_PREVIEW
  if (history_info.w >= 5.f) {
    float encoded_count = tex2D(history_count_texture, uv).r;
    float count = abs(encoded_count);
    if (history_info.w == 6.f) {
      // The sign is diagnostic only; accumulation always decodes its magnitude.
      // -1 = depth reset, +1 = other reset, negative >=2 = color-clipped history.
      float3 reason = encoded_count == -1.f ? float3(0.f, 0.f, 1.f)
                        : count < 1.5f ? float3(1.f, 0.f, 0.f)
                        : encoded_count < 0.f ? float3(1.f, 0.f, 1.f)
                        : float3(0.f, 1.f, 0.f);
      return StoreHistory(reason, 0.f, 1.f);
    }
    float3 color = count < 1.5f ? float3(1.f, 0.f, 0.f)
                   : count < 8.f ? float3(1.f, 1.f, 0.f)
                   : count < 32.f ? float3(0.f, 1.f, 1.f)
                   : float3(0.f, 1.f, 0.f);
    return StoreHistory(color, 0.f, 1.f);
  }
#endif
  // History and the displayed resolve live on an unjittered output grid.
  // Reconstruct current color at that grid before temporal accumulation.
  float2 sample_uv = uv + size_jitter.zw * size_jitter.xy;
  float depth = tex2D(depth_texture, sample_uv).x;
  if (history_info.w == 2.f) {
    // Keep the preview of native depth independent of resolve dilation.
    return StoreHistory(saturate(-log2(max(1.f - depth, 1.e-7f)) / 20.f).xxx, 0.f, 1.f);
  }
  float4 object_motion = 0.f;
  if (history_info.x != 0.f) object_motion = tex2D(object_motion_texture, sample_uv);
  depth = CurrentMotionDepth(depth, object_motion.w);
  // A single depth tap alternates foreground/background as subpixel coverage
  // changes, rejecting history on the very silhouettes we need to integrate.
  // Use the nearest surface in a one-pixel footprint for motion and history
  // depth. Color stays at the output pixel; only the surface identity expands.
  float2 depth_uv = sample_uv;
  float neighborhood_depth[9];
  neighborhood_depth[4] = depth;
  [unroll] for (int depth_y = -1; depth_y <= 1; ++depth_y) {
    [unroll] for (int depth_x = -1; depth_x <= 1; ++depth_x) {
      if (depth_x != 0 || depth_y != 0) {
        float2 candidate_uv = sample_uv + float2(depth_x, depth_y) * size_jitter.xy;
        float candidate_depth = tex2D(depth_texture, candidate_uv).x;
        float4 candidate_motion = 0.f;
        if (history_info.x != 0.f) candidate_motion = tex2D(object_motion_texture, candidate_uv);
        candidate_depth = CurrentMotionDepth(candidate_depth, candidate_motion.w);
        neighborhood_depth[(depth_y + 1) * 3 + depth_x + 1] = candidate_depth;
        if (candidate_depth >= 0.f && candidate_depth < depth) {
          depth = candidate_depth;
          depth_uv = candidate_uv;
          object_motion = candidate_motion;
        }
      }
    }
  }
  float depth_slope = abs(ddx(depth)) + abs(ddy(depth));
  bool covered_object = object_motion.w != 0.f;
  if (history_info.w == 4.f) {
    float3 preview = covered_object ? (object_motion.w > 0.f
                          ? float3(saturate(0.5f + object_motion.xy / size_jitter.xy / 32.f), 0.5f)
                          : float3(1.f, 0.f, 1.f)) : float3(0.f, 0.f, 0.f);
    return StoreHistory(preview, 0.f, 1.f);
  }
  float2 motion;
  float previous_depth;
  bool valid;
  [branch] if (covered_object && history_info.w != 3.f) {
    // Object vectors are previous-current on the unjittered grids. Preserve
    // the resolver's convention that motion also removes current raster jitter.
    motion = object_motion.xy - size_jitter.zw * size_jitter.xy;
    previous_depth = 1.f - abs(object_motion.z);
    valid = object_motion.w > 0.f;
  } else {
    // Covered surfaces already contain reprojection. Only reconstruct it from
    // camera/depth for uncovered pixels or the explicit camera-only preview.
    valid = AC2ReprojectCamera(depth_uv, depth, size_jitter.xy, size_jitter.zw, float2(0.f, 0.f),
                               previous_clip_rows[0], previous_clip_rows[1],
                               previous_clip_rows[2], previous_clip_rows[3], motion, previous_depth);
  }
  if (history_info.w == 3.f) {
    // Display out-of-bounds motion too; it can be correct even when history
    // reuse is rejected. Neutral gray means zero motion, saturated RG = large.
    return StoreHistory(history_info.z != 0.f ? float3(saturate(0.5f + motion / size_jitter.xy / 32.f), 0.5f)
                                              : float3(0.5f, 0.5f, 0.5f), 0.f, 1.f);
  }
#ifdef TAA_MOTION_PREVIEW
    // Same depth dilation, object selection and camera fallback as TAA. Only
    // remove intentional raster jitter from the displayed physical velocity.
    if (history_info.z == 0.f || !valid) return StoreHistory(float3(1.f, 0.f, 1.f), 0.f, 1.f);
    if (history_info.w == 8.f) {
      return StoreHistory(covered_object ? float3(0.f, 1.f, 0.f)
                                        : depth == 1.f ? float3(0.f, 0.f, 1.f) : float3(0.f, 1.f, 1.f), 0.f, 1.f);
    }
    return StoreHistory(float3(saturate(0.5f + (motion / size_jitter.xy + size_jitter.zw) / 32.f), 0.5f), 0.f, 1.f);
#else
  float3 current = tex2D(scene_texture, sample_uv).rgb;
  // Store 1-z in FP16 alpha: storing z directly loses nearly all distant depth
  // precision. The LUT consumes RGB only. History is never copied to the game RT.
  if (history_info.z == 0.f || !valid) return StoreHistory(current, depth, 1.f);
  float2 previous_uv = sample_uv + motion;
  if (previous_depth < 0.f || previous_depth > 1.f
      || any(previous_uv < 0.5f * size_jitter.xy) || any(previous_uv > 1.f - 0.5f * size_jitter.xy))
    return StoreHistory(current, depth, 1.f);
  float stored_depth = tex2D(history_depth_texture, previous_uv).a;
  float expected_depth = 1.f - previous_depth;
  // Dilation plus jitter can select different texels of the same sloped roof.
  // Derivatives of the dilated minimum can also flatten into plateaus. Infer
  // slope from linear three-tap runs in the original footprint instead. A
  // foreground/background step fails this curvature test: its depth jump must
  // not become an allowance for stale history on the newly visible surface.
  bool current_contains_history = false;
  [unroll] for (int boundary_sample = 0; boundary_sample < 9; ++boundary_sample)
    current_contains_history = current_contains_history
        || abs((1.f - neighborhood_depth[boundary_sample]) - stored_depth) <= max(2.e-6f, stored_depth * 0.005f);
  float2 planar_slope = 0.f;
  [unroll] for (int axis_line = 0; axis_line < 3; ++axis_line) {
    float3 row = float3(neighborhood_depth[axis_line * 3], neighborhood_depth[axis_line * 3 + 1], neighborhood_depth[axis_line * 3 + 2]);
    float3 column = float3(neighborhood_depth[axis_line], neighborhood_depth[axis_line + 3], neighborhood_depth[axis_line + 6]);
    if (all(row < 1.f) && abs((row.x - row.y) + (row.z - row.y)) <= max(2.e-7f, abs(row.z - row.x) * 0.1f))
      planar_slope.x = max(planar_slope.x, 0.5f * abs(row.z - row.x));
    if (all(column < 1.f) && abs((column.x - column.y) + (column.z - column.y)) <= max(2.e-7f, abs(column.z - column.x) * 0.1f))
      planar_slope.y = max(planar_slope.y, 0.5f * abs(column.z - column.x));
  }
  float tolerance = max(2.e-6f, expected_depth * 0.005f)
                  + max(min(depth_slope, expected_depth * 0.02f),
                        min(2.f * (planar_slope.x + planar_slope.y), expected_depth * 0.04f));
  if (abs(stored_depth - expected_depth) > tolerance) {
    // A stationary silhouette can swap its dilated nearest surface with jitter.
    // Require both identities to still exist within one pixel in both frames;
    // do not enlarge the depth tolerance or borrow a neighbor's color/history.
    // Uncovered native depth uses the static-camera fallback. Invalid covered
    // poses and any measured object motion still prohibit this exception.
    bool stationary_footprint = history_info.x == 2.f;
    bool history_contains_current = false;
    [branch] if (stationary_footprint && current_contains_history) {
      [loop] for (int boundary_y = -1; boundary_y <= 1; ++boundary_y) {
        [loop] for (int boundary_x = -1; boundary_x <= 1; ++boundary_x) {
          float2 candidate_uv = sample_uv + float2(boundary_x, boundary_y) * size_jitter.xy;
          float4 candidate_motion = tex2Dlod(object_motion_texture, float4(candidate_uv, 0.f, 0.f));
          float candidate_native_depth = tex2Dlod(depth_texture, float4(candidate_uv, 0.f, 0.f)).x;
          stationary_footprint = stationary_footprint
              && ((candidate_motion.w > 0.f && candidate_motion.z >= 0.f)
                  || (candidate_motion.w == 0.f && candidate_native_depth >= 0.f && candidate_native_depth <= 1.f))
              && length(candidate_motion.xy / size_jitter.xy) < 0.001f;
          float candidate_history = tex2Dlod(history_depth_texture,
              float4(previous_uv + float2(boundary_x, boundary_y) * size_jitter.xy, 0.f, 0.f)).a;
          history_contains_current = history_contains_current
              || abs(candidate_history - expected_depth) <= max(2.e-6f, expected_depth * 0.005f);
        }
      }
    }
    if (!stationary_footprint || !current_contains_history || !history_contains_current) return StoreHistory(current, depth, -1.f);
  }

  float3 lower = current;
  float3 upper = current;
  float3 mean = 0.f;
  float3 moment = 0.f;
  [unroll] for (int y = -1; y <= 1; ++y) {
    [unroll] for (int x = -1; x <= 1; ++x) {
      float3 sample_color = tex2D(scene_texture, sample_uv + float2(x, y) * size_jitter.xy).rgb;
      lower = min(lower, sample_color);
      upper = max(upper, sample_color);
      mean += sample_color / 9.f;
      moment += sample_color * sample_color / 9.f;
    }
  }
  // MSAA color already integrates spatial coverage. Bilinear unjittering adds
  // another tent filter and erases thin detail; reconstruct it with the same
  // cubic kernel as history. Clamp to the source neighborhood to avoid ringing.
  if (history_info.z == 2.f) current = clamp(SampleCubic(scene_texture, sample_uv), lower, upper);
  float3 sigma = sqrt(max(0.f, moment - mean * mean));
  lower = max(lower, mean - 1.25f * sigma);
  upper = min(upper, mean + 1.25f * sigma);
  float3 history = SampleCubic(history_texture, previous_uv);
  float3 center = 0.5f * (lower + upper);
  float3 extent = max(0.5f * (upper - lower), 1.e-5f);
  float3 delta = history - center;
  float3 normalized_delta = abs(delta / extent);
  float3 unclipped_history = history;
  history = center + delta / max(1.f, max(normalized_delta.x, max(normalized_delta.y, normalized_delta.z)));

  // Jitter intentionally changes edge coverage. Comparing history to the
  // center tap erased accumulation on every dark phase of an aliased edge.
  // React to history outside the neighborhood instead; plausible edge samples
  // retain temporal weight. Shading animation still needs reactive rejection.
  float3 rejected_color = abs(unclipped_history - history);
  float disagreement = max(rejected_color.x, max(rejected_color.y, rejected_color.z));
  float3 neighborhood_signal = max(abs(mean), upper - lower);
  float signal = max(0.05f, max(neighborhood_signal.x, max(neighborhood_signal.y, neighborhood_signal.z)));
  // The reprojection vector includes removal of current jitter. Do not treat
  // that known subpixel offset as camera motion when weighting history.
  float2 camera_motion_pixels = motion / size_jitter.xy + size_jitter.zw;
  // A fixed 10% current-frame contribution leaves the repeating jitter visible
  // forever. Accumulate confidence per pixel so stationary surfaces converge.
  // Motion and rejected color limit confidence; disocclusion resets it to one.
  // Limit history in terms of current-frame weight, not a linear interpolation
  // of sample counts: the latter retained ~104 samples at only 0.1 px/frame.
  // Zero motion keeps 128 samples; 0.1 px/frame uses ~17, with at least eight
  // samples during sustained motion to retain the jitter cycle's edge coverage.
  // MSAA supplies spatial coverage; projection jitter supplies new temporal
  // samples. Use less history than 1x TAA during motion to retain thin detail.
  // Color rejection and uncertain poses can shorten it further.
  float max_samples = clamp(rcp(1.f / 128.f + 0.5f * length(camera_motion_pixels)), 8.f, 128.f);
  if (history_info.z == 2.f) max_samples = clamp(rcp(1.f / 64.f + length(camera_motion_pixels)), 4.f, 64.f);
  // Body-only recovery lacks this part's previous articulation. Retain enough
  // history to avoid a one-frame reset flash, but never build high confidence
  // from it even when the camera/root is still. Depth/color rejection still run.
  if (covered_object && object_motion.z < 0.f) max_samples = min(max_samples, 4.f);
  max_samples = lerp(max_samples, 2.f, saturate(4.f * disagreement / signal));
  float sample_count = min(max(1.f, abs(tex2D(history_count_texture, previous_uv).r)) + 1.f, max_samples);
  float history_weight = 1.f - rcp(sample_count);
  // Preserve the exact count magnitude and all blend math. Negative counts
  // identify color rejection in the diagnostic display without another RT.
  float encoded_count = disagreement > signal * 1.e-4f ? -sample_count : sample_count;
  // Native SDR can request hardware sRGB decoding. Preserve that contract and
  // blend its already-linear samples without a second transfer conversion.
  if (history_info.y != 0.f) return StoreHistory(lerp(current, history, history_weight), depth, encoded_count);
  // Gamma-coded native transport is used for bounds; blend radiometric values.
  float3 resolved = lerp(pow(max(current, 0.f), 2.2f), pow(max(history, 0.f), 2.2f), history_weight);
  return StoreHistory(pow(max(resolved, 0.f), 1.f / 2.2f), depth, encoded_count);
#endif
}

ResolveOutput main(float2 uv : TEXCOORD0) {
  ResolveOutput output = ResolvePixel(uv);
  // Native DX9 FP16 RT writes truncate on the tested device (.5003 -> .5).
  // Repeating that conversion biases long accumulation darker. Round once at
  // the output boundary, including early exits and previews. Duplicating this
  // math at each return exhausts SM3 temporary registers with hybrid history.
  float3 magnitude = abs(output.color_depth.rgb);
  float3 half_step = exp2(max(floor(log2(max(magnitude, 6.103515625e-5f))), -14.f) - 10.f);
  output.color_depth.rgb = sign(output.color_depth.rgb) * floor(magnitude / half_step + 0.5f) * half_step;
  return output;
}
