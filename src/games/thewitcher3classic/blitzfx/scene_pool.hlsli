#ifndef THEWITCHER3CLASSIC_BLITZFX_SCENE_POOL_HLSLI_
#define THEWITCHER3CLASSIC_BLITZFX_SCENE_POOL_HLSLI_

// Classic renders a top-left subrect of its output-sized pool during DLSS.
// Keep projection/refraction calculations in render UVs and convert only at
// the texture boundary. Full-size rendering retains native sampler behavior.
float2 BlitzClampPoolUV(float2 uv, float2 render_size, float2 pool_size, float margin) {
  if (all(render_size >= pool_size)) return uv;
  return clamp(uv, margin / pool_size, max(margin, render_size - margin) / pool_size);
}

float2 BlitzScenePoolUV(float2 uv, float2 render_size, float2 pool_size, float margin = 0.5f) {
  return BlitzClampPoolUV(uv * min(1.f, render_size / pool_size), render_size, pool_size, margin);
}

// A gather needs per-texel clamp at the active edge. Moving its center inward
// changes the four mask samples, while hardware clamp sees the allocation edge.
// Keep one native gather for interior taps; repair only the border footprint.
float4 BlitzGatherScenePoolRed(Texture2D<float4> source, SamplerState source_sampler,
                              float2 uv, uint2 render_size, uint2 pool_size) {
  if (all(render_size >= pool_size)) return source.GatherRed(source_sampler, uv);
  // Match the sampler's eight fractional addressing bits. Without rounding,
  // a tiny reciprocal error at a texel center selects the preceding mask row.
  const int2 low = int2(floor(uv * float2(render_size) - .5f + 1.f / 512.f));
  if (all(low >= 0) && all(low + 1 < int2(render_size)))
    return source.GatherRed(source_sampler, uv * float2(render_size) / float2(pool_size));
  const int2 last = int2(render_size) - 1;
  return float4(source.Load(int3(clamp(low + int2(0, 1), 0, last), 0)).r,
                source.Load(int3(clamp(low + int2(1, 1), 0, last), 0)).r,
                source.Load(int3(clamp(low + int2(1, 0), 0, last), 0)).r,
                source.Load(int3(clamp(low, 0, last), 0)).r);
}
#endif
