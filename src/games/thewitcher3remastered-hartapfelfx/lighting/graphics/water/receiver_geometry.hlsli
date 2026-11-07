// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_REMASTERED_WATER_RECEIVER_GEOMETRY
#define WITCHER_REMASTERED_WATER_RECEIVER_GEOMETRY
#include "elevation.hlsli"

// Native 81EAA494's tile rectangles, atlas transform and height range. Explicit
// bilinear loads also return the cell minimum, as in Classic's receiver test.
// That conservative floor avoids holes where the tessellated terrain differs
// from its low-resolution height map. The VS's -1.5 m water-culling bias is NOT
// terrain elevation and must not admit interiors beneath the actual floor.
bool GraphicsWaterTerrain(Texture2DArray<float> heights, Texture2D<float4> tiles,
    float2 range, float2 world, out float2 bottom) {
  bottom = 0.f;
  uint width, height, layers, count, rows;
  heights.GetDimensions(width, height, layers);
  tiles.GetDimensions(count, rows);
  if (width == 0u || height == 0u || rows < 2u || count == 0u || count > layers
      || any(!isfinite(range)) || range.y < range.x || any(!isfinite(world))) return false;
  [loop] for (uint tile = 0u; tile < count; ++tile) {
    float4 rectangle = tiles.Load(int3(tile, 0, 0));
    if (any(!isfinite(rectangle)) || any(rectangle.zw <= rectangle.xy)) return false;
    if (any(world <= rectangle.xy) || any(world >= rectangle.zw)) continue;
    float4 atlas = tiles.Load(int3(tile, 1, 0));
    if (any(!isfinite(atlas)) || any(atlas.xy < 0.f) || any(atlas.zw > 1.f)
        || any(atlas.zw <= atlas.xy)) return false;
    float2 uv = lerp(atlas.xy, atlas.zw,
        (world - rectangle.xy) / (rectangle.zw - rectangle.xy) + .5f / float2(width, height));
    float2 p = saturate(uv) * float2(width, height) - .5f;
    int2 cell = int2(floor(p)), limit = int2(width, height) - 1;
    float2 f = frac(p);
    float4 values = float4(heights.Load(int4(clamp(cell, 0, limit), tile, 0)),
        heights.Load(int4(clamp(cell + int2(1, 0), 0, limit), tile, 0)),
        heights.Load(int4(clamp(cell + int2(0, 1), 0, limit), tile, 0)),
        heights.Load(int4(clamp(cell + 1, 0, limit), tile, 0)));
    if (any(!isfinite(values))) return false;
    values = lerp(range.x, range.y, saturate(values));
    bottom = float2(lerp(lerp(values.x, values.y, f.x), lerp(values.z, values.w, f.x), f.y),
        min(min(values.x, values.y), min(values.z, values.w)));
    return all(isfinite(bottom));
  }
  return false;
}

// Record: elevation, conservative terrain floor, interpolated terrain, valid.
// This classifies a column in the captured body, not every point below sea level.
float4 GraphicsWaterReceiverColumn(Texture2DArray<float4> regional_heights, SamplerState native_sampler,
    float4 regions[116], Texture2DArray<float> terrain_heights, Texture2D<float4> terrain_tiles,
    float2 terrain_range, float2 world, bool fallback_known, float fallback_height, float body_height) {
  float elevation;
  int region;
  if (!isfinite(body_height) || !GraphicsWaterElevation(regional_heights, native_sampler,
      regions, world, fallback_known, fallback_height, elevation, region)
      || abs(elevation - body_height) > .25f) return 0.f;
  // The native sampler can return a clamped border outside the regional body.
  // Preserve that choice for rendering, but do not call such a receiver wet.
  if (region >= 0) {
    float2 uv = (world - regions[7 + region].xy) / regions[7 + region].zw;
    if (any(uv < 0.f) || any(uv > 1.f)) return 0.f;
  }
  float2 bottom;
  if (!GraphicsWaterTerrain(terrain_heights, terrain_tiles, terrain_range, world, bottom)
      || bottom.x >= elevation) return 0.f;
  return float4(elevation, bottom.y, bottom.x, 1.f);
}

float GraphicsWaterReceiverWeight(float4 column, float world_height) {
  if (column.w != 1.f || any(!isfinite(column)) || !isfinite(world_height)
      || world_height < column.y - .1f || column.z >= column.x) return 0.f;
  return smoothstep(0.f, .1f, column.x - world_height);
}
#endif
