// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_REMASTERED_WATER_RECEIVER_FIELD
#define WITCHER_REMASTERED_WATER_RECEIVER_FIELD
#include "receiver_field_layout.h"
#include "receiver_geometry.hlsli"

// The runtime supplies a completed, immutable field with bounded age. GPU camera
// distance additionally rejects cuts/teleports; it is not a submission fence.
float GraphicsWaterFieldWeight(ByteAddressBuffer field, float3 camera, float3 world, float renderer,
    out float depth, out float3 extinction) {
  depth = 0.f;
  extinction = 0.f;
  if (any(!isfinite(camera)) || any(!isfinite(world))) return 0.f;
  if (any(field.Load4(0u) != uint4(W3_WATER_FIELD_MAGIC, W3_WATER_FIELD_VERSION, 1u, W3_WATER_FIELD_BYTES))) return 0.f;
  if (!isfinite(renderer) || field.Load(64u) != asuint(renderer)) return 0.f;
  float4 grid = asfloat(field.Load4(16u));
  float4 previous_camera = asfloat(field.Load4(32u));
  float3 coefficients = asfloat(field.Load3(48u));
  if (any(!isfinite(grid)) || any(!isfinite(previous_camera)) || any(!isfinite(coefficients))
      || any(coefficients < 0.f) || grid.z != W3_WATER_FIELD_EXTENT || grid.w != W3_WATER_FIELD_GRID
      || distance(camera, previous_camera.xyz) > 5.f) return 0.f;
  float2 uv = (world.xy - grid.xy) / grid.z;
  float edge = saturate(min(min(uv.x, uv.y), min(1.f - uv.x, 1.f - uv.y)) * 16.f);
  if (edge <= 0.f) return 0.f;
  float2 p = uv * float(W3_WATER_FIELD_GRID - 1u);
  uint2 cell = min(uint2(p), W3_WATER_FIELD_GRID - 2u);
  float2 f = p - float2(cell);
  uint address = W3_WATER_FIELD_HEADER + (cell.y * W3_WATER_FIELD_GRID + cell.x) * 16u;
  float4 a = asfloat(field.Load4(address));
  float4 b = asfloat(field.Load4(address + 16u));
  float4 c = asfloat(field.Load4(address + W3_WATER_FIELD_GRID * 16u));
  float4 d = asfloat(field.Load4(address + (W3_WATER_FIELD_GRID + 1u) * 16u));
  // Do not interpolate a wet cell into missing/dry terrain or across bodies.
  if (a.w != 1.f || b.w != 1.f || c.w != 1.f || d.w != 1.f
      || any(!isfinite(a)) || any(!isfinite(b)) || any(!isfinite(c)) || any(!isfinite(d))
      || max(max(a.x, b.x), max(c.x, d.x)) - min(min(a.x, b.x), min(c.x, d.x)) > .25f) return 0.f;
  float4 column = lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
  column.y = min(min(a.y, b.y), min(c.y, d.y));
  float weight = GraphicsWaterReceiverWeight(column, world.z) * edge;
  if (weight <= 0.f) return 0.f;
  depth = max(0.f, column.x - world.z);
  extinction = coefficients;
  return weight;
}
#endif
