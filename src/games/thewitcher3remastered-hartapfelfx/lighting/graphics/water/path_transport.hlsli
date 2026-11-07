// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_WATER_PATH_TRANSPORT
#define WITCHER_WATER_PATH_TRANSPORT
#include "receiver_field_layout.h"

// Shared admission for extinction and surface connections. Neither operation
// may bridge a missing column, another body or ground above the water surface.
bool GraphicsWaterCellValid(float body_height, float4 a, float4 b, float4 c, float4 d, out float floor_height) {
  floor_height = min(min(a.y, b.y), min(c.y, d.y)) - .1f;
  if (a.w != 1.f || b.w != 1.f || c.w != 1.f || d.w != 1.f
      || any(!isfinite(a)) || any(!isfinite(b)) || any(!isfinite(c)) || any(!isfinite(d))
      || any(abs(float4(a.x, b.x, c.x, d.x) - body_height) > .25f)
      || max(max(a.x, b.x), max(c.x, d.x)) - min(min(a.x, b.x), min(c.x, d.x)) > .25f
      || a.z >= a.x || b.z >= b.x || c.z >= c.x || d.z >= d.x) return false;
  return true;
}

// Stable quadratic roots; absent roots are outside every finite cell segment.
float2 GraphicsWaterSurfaceRoots(float quadratic, float slope, float constant) {
  float2 roots = 1.e30f;
  if (abs(quadratic) <= 1.e-7f * max(1.f, abs(slope))) {
    if (abs(slope) > 1.e-12f) roots.x = -constant / slope;
  } else {
    float discriminant = slope * slope - 4.f * quadratic * constant;
    if (discriminant == 0.f) roots.x = -.5f * slope / quadratic;
    else if (discriminant > 0.f) {
      float q = -.5f * (slope + (slope < 0.f ? -1.f : 1.f) * sqrt(discriminant));
      roots = float2(q / quadratic, constant / q);
    }
  }
  return float2(min(roots.x, roots.y), max(roots.x, roots.y));
}

// Integrate a finite ray through one measured water column. Bilinear surface
// height along a line is quadratic; split at its roots instead of marching or
// assuming that two submerged endpoints prove the whole segment is submerged.
float GraphicsWaterCellPath(float3 start, float3 end, float2 uv_start, float2 uv_end,
    float body_height, float4 a, float4 b, float4 c, float4 d) {
  float floor_height;
  if (!GraphicsWaterCellValid(body_height, a, b, c, d, floor_height)) return 0.f;
  float3 delta = end - start;
  if (a.x == b.x && a.x == c.x && a.x == d.x) {
    if (abs(delta.z) <= 1.e-12f) return start.z < a.x && start.z >= floor_height ? length(delta) : 0.f;
    float top = (a.x - start.z) / delta.z, bottom = (floor_height - start.z) / delta.z;
    return length(delta) * max(0.f, min(1.f, max(top, bottom)) - max(0.f, min(top, bottom)));
  }
  float2 uv_delta = uv_end - uv_start;
  float mixed = a.x - b.x - c.x + d.x;
  float quadratic = mixed * uv_delta.x * uv_delta.y;
  float slope = (b.x - a.x) * uv_delta.x + (c.x - a.x) * uv_delta.y
      + mixed * (uv_start.x * uv_delta.y + uv_start.y * uv_delta.x) - delta.z;
  float constant = lerp(lerp(a.x, b.x, uv_start.x), lerp(c.x, d.x, uv_start.x), uv_start.y) - start.z;
  float splits[5] = {0.f, 1.f, 1.f, 1.f, 1.f};
  uint count = 2u;
  float2 roots = GraphicsWaterSurfaceRoots(quadratic, slope, constant);
  [unroll] for (uint i = 0u; i < 2u; ++i)
    if (roots[i] > 0.f && roots[i] < 1.f) splits[count++] = roots[i];
  if (abs(delta.z) > 1.e-12f) {
    float root = (floor_height - start.z) / delta.z;
    if (root > 0.f && root < 1.f) splits[count++] = root;
  }
  // At most two surface crossings and one terrain crossing inside this cell.
  [unroll] for (uint i = 0u; i < 4u; ++i) {
    [unroll] for (uint j = 0u; j < 4u; ++j) {
      float low = min(splits[j], splits[j + 1u]), high = max(splits[j], splits[j + 1u]);
      splits[j] = low; splits[j + 1u] = high;
    }
  }
  float fraction = 0.f;
  [unroll] for (uint i = 0u; i < 4u; ++i) {
    float middle = .5f * (splits[i] + splits[i + 1u]);
    float below_surface = (quadratic * middle + slope) * middle + constant;
    if (below_surface > 0.f && start.z + delta.z * middle >= floor_height)
      fraction += splits[i + 1u] - splits[i];
  }
  return length(delta) * fraction;
}

// Returns Beer-Lambert transmittance and the admitted path length. The field is
// one bounded, completed body snapshot; regions outside it remain native.
// Primary eye-path transport belongs to the existing underwater pass. Callers
// must use this only for secondary/lighting segments to avoid double extinction.
float4 GraphicsWaterPathTransmission(ByteAddressBuffer field, float3 camera, float renderer,
    float3 start, float3 end) {
  float4 neutral = float4(1.f, 1.f, 1.f, 0.f);
  if (any(!isfinite(camera)) || any(!isfinite(start)) || any(!isfinite(end)) || !isfinite(renderer)
      || any(field.Load4(0u) != uint4(W3_WATER_FIELD_MAGIC, W3_WATER_FIELD_VERSION, 1u, W3_WATER_FIELD_BYTES))
      || field.Load(64u) != asuint(renderer)) return neutral;
  float4 grid = asfloat(field.Load4(16u));
  float4 previous_camera = asfloat(field.Load4(32u));
  float3 extinction = asfloat(field.Load3(48u));
  if (any(!isfinite(grid)) || any(!isfinite(previous_camera)) || any(!isfinite(extinction))
      || any(extinction < 0.f) || grid.z != W3_WATER_FIELD_EXTENT || grid.w != W3_WATER_FIELD_GRID
      || distance(camera, previous_camera.xyz) > 5.f) return neutral;
  // Work near the body origin so per-cell interpolation does not repeatedly
  // subtract large world coordinates (Novigrad/Skellige camera positions).
  float body_height = previous_camera.w;
  start -= float3(grid.xy, body_height);
  end -= float3(grid.xy, body_height);
  grid.xy = 0.f;
  // A native miss can have an 8,388,607 m endpoint. Integrate from the nearer
  // endpoint so clipping a short local water interval does not subtract t~1
  // values or walk cells with sub-ULP parameter increments.
  float3 centre = float3(.5f * grid.z, .5f * grid.z, 0.f);
  if (dot(end - centre, end - centre) < dot(start - centre, start - centre)) {
    float3 swap = start; start = end; end = swap;
  }
  float3 delta = end - start;
  if (any(!isfinite(delta)) || dot(delta, delta) <= 1.e-12f) return neutral;
  float begin = 0.f, finish = 1.f;
  // The producer admits only columns within .25 m of camera.w's body height.
  // Clip this guaranteed upper bound before traversing cells: ordinary rays
  // entirely above water should never pay for a grid walk.
  if (abs(delta.z) <= 1.e-12f) {
    if (start.z >= .25f) return neutral;
  } else {
    float top = (.25f - start.z) / delta.z;
    if (delta.z > 0.f) finish = min(finish, top);
    else begin = max(begin, top);
  }
  [unroll] for (uint axis = 0u; axis < 2u; ++axis) {
    if (abs(delta[axis]) < 1.e-12f) {
      if (start[axis] < grid[axis] || start[axis] > grid[axis] + grid.z) return neutral;
    } else {
      float first = (grid[axis] - start[axis]) / delta[axis];
      float last = (grid[axis] + grid.z - start[axis]) / delta[axis];
      begin = max(begin, min(first, last)); finish = min(finish, max(first, last));
    }
  }
  if (begin >= finish) return neutral;
  float3 clipped_start = lerp(start, end, begin);
  end = lerp(start, end, finish);
  start = clipped_start;
  delta = end - start;
  begin = 0.f; finish = 1.f;
  const float scale = float(W3_WATER_FIELD_GRID - 1u) / W3_WATER_FIELD_EXTENT;
  float2 p = (lerp(start.xy, end.xy, begin) - grid.xy) * scale;
  float2 direction = delta.xy * scale;
  int2 step = int2(direction.x > 0.f ? 1 : direction.x < 0.f ? -1 : 0,
      direction.y > 0.f ? 1 : direction.y < 0.f ? -1 : 0);
  int2 cell = int2(floor(p));
  // An exact negative-facing grid edge belongs to the cell being entered.
  if (step.x < 0 && p.x == floor(p.x)) --cell.x;
  if (step.y < 0 && p.y == floor(p.y)) --cell.y;
  cell = clamp(cell, 0, int(W3_WATER_FIELD_GRID) - 2);
  float2 crossing = float2(2.f, 2.f);
  [unroll] for (uint axis = 0u; axis < 2u; ++axis)
    if (step[axis] != 0) crossing[axis] = begin + (float(cell[axis] + (step[axis] > 0 ? 1 : 0)) - p[axis]) / direction[axis];
  float metres = 0.f;
  // A straight line crosses at most twice the grid width. Both axes advance
  // at corner ties; vertical paths visit exactly one cell.
  [loop] for (uint visited = 0u; visited < 2u * (W3_WATER_FIELD_GRID - 1u); ++visited) {
    float next = min(finish, min(crossing.x, crossing.y));
    if (next > begin) {
      float3 a_world = lerp(start, end, begin), b_world = lerp(start, end, next);
      float2 a_uv = saturate((a_world.xy - grid.xy) * scale - float2(cell));
      float2 b_uv = saturate((b_world.xy - grid.xy) * scale - float2(cell));
      uint address = W3_WATER_FIELD_HEADER + (uint(cell.y) * W3_WATER_FIELD_GRID + uint(cell.x)) * 16u;
      float4 origin = float4(body_height, body_height, body_height, 0.f);
      metres += GraphicsWaterCellPath(a_world, b_world, a_uv, b_uv, 0.f,
          asfloat(field.Load4(address)) - origin, asfloat(field.Load4(address + 16u)) - origin,
          asfloat(field.Load4(address + W3_WATER_FIELD_GRID * 16u)) - origin,
          asfloat(field.Load4(address + (W3_WATER_FIELD_GRID + 1u) * 16u)) - origin);
    }
    if (next >= finish) break;
    bool2 advance = crossing <= next;
    [unroll] for (uint axis = 0u; axis < 2u; ++axis) if (advance[axis]) {
      cell[axis] += step[axis];
      crossing[axis] += 1.f / abs(direction[axis]);
    }
    if (any(cell < 0) || any(cell >= int(W3_WATER_FIELD_GRID) - 1)) break;
    begin = next;
  }
  if (!isfinite(metres) || metres < 0.f) return neutral;
  return float4(exp(-extinction * metres), metres);
}
#endif
