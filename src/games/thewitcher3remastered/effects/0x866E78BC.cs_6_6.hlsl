// Full-resolution replacement for the native motion-blur resolve.
// Native/Vanilla selection happens in addon.cpp: no injected compute constants.
Texture2D<float4> scene : register(t1);
Texture2D<float2> motion : register(t2);
RWTexture2D<float4> output : register(u0);

cbuffer CSCustomConstants : register(b0) {
  float2 motion_coordinate_scale : packoffset(c2.z);
  float2 scene_uv_scale : packoffset(c4.x);
  float2 viewport_max : packoffset(c5.x);
  float native_shutter_scale : packoffset(c6.x);
  float native_blend_scale : packoffset(c6.y);
  float native_velocity_limit : packoffset(c6.z);
};

// Explicit bilinear interpolation avoids depending on the game's sampler filter.
// Clamp to the active viewport, including when the backing allocation is larger.
float3 SampleScene(float2 pixel, int2 last_pixel) {
  pixel = clamp(pixel, 0.f, float2(last_pixel));
  int2 base = int2(floor(pixel));
  int2 next = min(base + 1, last_pixel);
  float2 blend = frac(pixel);
  return lerp(lerp(scene.Load(int3(base, 0)).rgb,
                   scene.Load(int3(next.x, base.y, 0)).rgb, blend.x),
              lerp(scene.Load(int3(base.x, next.y, 0)).rgb,
                   scene.Load(int3(next, 0)).rgb, blend.x), blend.y);
}

[numthreads(16, 16, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  uint width, height, scene_width, scene_height;
  output.GetDimensions(width, height);
  scene.GetDimensions(scene_width, scene_height);
  // Preserve the native dispatch's active rectangle and guard partial groups.
  uint2 extent = min(min(uint2(width, height), uint2(scene_width, scene_height)), uint2(viewport_max + 1.f));
  if (any(id.xy >= extent)) return;

  float4 center = scene.Load(int3(id.xy, 0));
  float2 velocity = motion.Load(int3(uint2(float2(id.xy) * motion_coordinate_scale), 0));
  // Keep the native per-object velocity limit, shutter calibration and blend.
  // Small residual motion on the tracked character must not receive the same
  // blur as the moving background. These are per-pixel controls, not a tap
  // rejection rule: moving object edges still integrate the whole shutter path.
  velocity /= max(1.f, native_velocity_limit * length(velocity));
  float blur_amount = saturate(length(velocity) * native_blend_scale);
  float2 shutter_pixels = velocity * native_shutter_scale / scene_uv_scale;
  float distance = length(shutter_pixels);
  if (!all(isfinite(shutter_pixels)) || blur_amount < 0.0001f || distance < 0.5f) {
    output[id.xy] = center;
    return;
  }

  // Bound cost and long streaks during large hitches/camera discontinuities.
  // At most one pixel between samples, with symmetric, deterministic positions.
  float2 path = shutter_pixels * min(1.f, 64.f / distance);
  uint pair_count = uint(ceil(min(distance, 64.f) * 0.5f));
  float sample_count = float(pair_count * 2u + 1u);
  int2 last_pixel = int2(extent) - 1;
  float3 sum = center.rgb;
  [loop]
  for (uint i = 1u; i <= pair_count; ++i) {
    [unroll]
    for (int side = -1; side <= 1; side += 2) {
      float2 position = clamp(float2(id.xy) + path * (float(side) * float(i) / sample_count),
                              0.f, float2(last_pixel));
      // Integrate the whole shutter path, including object boundaries. Rejecting
      // taps by their motion leaves unnaturally sharp silhouettes during motion.
      sum += SampleScene(position, last_pixel);
    }
  }

  // Fade subpixel blur in continuously; retain HDR range and native alpha.
  output[id.xy] = float4(lerp(center.rgb, sum / sample_count, blur_amount * smoothstep(0.5f, 1.f, distance)), center.a);
}
