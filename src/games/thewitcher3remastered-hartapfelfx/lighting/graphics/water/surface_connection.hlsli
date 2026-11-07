// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_GRAPHICS_WATER_SURFACE_CONNECTION
#define WITCHER_GRAPHICS_WATER_SURFACE_CONNECTION
#include "path_transport.hlsli"

struct GraphicsWaterSurfaceCrossing {
  float3 position;
  float3 normal;
  float3 transmission;
  float distance;
  float mixed_curvature; // d2 height / dx dy for this bilinear cell, in world units.
  bool valid;
};

// Find the first crossing from the specified medium. Horizontal and reversed-Z
// rays can cross wave slopes, so global Z direction cannot classify the event.
// Every traversed cell must belong to the measured body. Unknown/dry columns,
// terrain intersections and leaving the snapshot reject the entire connection,
// unlike the partial-length extinction query. This supplies geometry only:
// callers still trace scene visibility on the water leg and the outgoing air leg.
GraphicsWaterSurfaceCrossing GraphicsFindWaterSurfaceCrossing(ByteAddressBuffer field, float3 camera,
    float renderer, float3 world, float3 direction, bool from_water, float maximum = 1.e30f) {
  GraphicsWaterSurfaceCrossing result = (GraphicsWaterSurfaceCrossing)0;
  if (any(!isfinite(camera)) || any(!isfinite(world)) || any(!isfinite(direction)) || !isfinite(renderer)
      || !isfinite(maximum) || maximum <= 0.f
      || dot(direction, direction) <= 1.e-12f
      || any(field.Load4(0u) != uint4(W3_WATER_FIELD_MAGIC, W3_WATER_FIELD_VERSION, 1u, W3_WATER_FIELD_BYTES))
      || field.Load(64u) != asuint(renderer)) return result;
  float4 grid = asfloat(field.Load4(16u)), previous_camera = asfloat(field.Load4(32u));
  float3 extinction = asfloat(field.Load3(48u));
  if (any(!isfinite(grid)) || any(!isfinite(previous_camera)) || any(!isfinite(extinction))
      || any(extinction < 0.f) || grid.z != W3_WATER_FIELD_EXTENT || grid.w != W3_WATER_FIELD_GRID
      || distance(camera, previous_camera.xyz) > 5.f) return result;
  direction = normalize(direction);
  float3 offset = float3(grid.xy, previous_camera.w), start = world - offset;
  if (any(start.xy < 0.f) || any(start.xy > grid.z)
      || (from_water ? start.z >= .25f : start.z <= -.25f)) return result;
  // All admitted columns lie inside the body's +/- .25 m height band. Clip
  // the search to that band in the travel direction and the finite XY field.
  // This also bounds horizontal traversal without an arbitrary ray length.
  // A native material hit already bounds the segment we can replace. Searching
  // beyond it cannot change the result and can walk the whole field needlessly.
  float finish = maximum;
  if (direction.z > 0.f) {
    if (start.z >= .25f) return result;
    finish = min(finish, (.25f - start.z) / direction.z);
  }
  else if (direction.z < 0.f) {
    if (start.z <= -.25f) return result;
    finish = min(finish, (-.25f - start.z) / direction.z);
  }
  else if (abs(start.z) > .25f) return result;
  [unroll] for (uint axis = 0u; axis < 2u; ++axis) {
    if (direction[axis] > 0.f) finish = min(finish, (grid.z - start[axis]) / direction[axis]);
    else if (direction[axis] < 0.f) finish = min(finish, -start[axis] / direction[axis]);
  }
  if (!isfinite(finish) || finish <= 0.f) return result;
  const float scale = float(W3_WATER_FIELD_GRID - 1u) / W3_WATER_FIELD_EXTENT;
  float2 p = start.xy * scale, travel = direction.xy * scale;
  int2 step = int2(travel.x > 0.f ? 1 : travel.x < 0.f ? -1 : 0,
      travel.y > 0.f ? 1 : travel.y < 0.f ? -1 : 0);
  int2 cell = int2(floor(p));
  if (step.x < 0 && p.x == floor(p.x)) --cell.x;
  if (step.y < 0 && p.y == floor(p.y)) --cell.y;
  // A stationary ray on the outer boundary belongs to the last interior cell.
  if (step.x == 0 && cell.x == int(W3_WATER_FIELD_GRID)-1) --cell.x;
  if (step.y == 0 && cell.y == int(W3_WATER_FIELD_GRID)-1) --cell.y;
  if (any(cell < 0) || any(cell >= int(W3_WATER_FIELD_GRID)-1)) return result;
  float2 crossing = finish;
  [unroll] for (uint axis = 0u; axis < 2u; ++axis)
    if (step[axis] != 0) crossing[axis] = (float(cell[axis] + (step[axis] > 0 ? 1 : 0)) - p[axis]) / travel[axis];
  float begin = 0.f;
  [loop] for (uint visited = 0u; visited < 2u*(W3_WATER_FIELD_GRID-1u); ++visited) {
    float next = min(finish, min(crossing.x, crossing.y));
    if (next > begin) {
      uint address = W3_WATER_FIELD_HEADER + (uint(cell.y)*W3_WATER_FIELD_GRID + uint(cell.x))*16u;
      float4 origin = float4(previous_camera.www, 0.f);
      float4 a = asfloat(field.Load4(address)) - origin, b = asfloat(field.Load4(address+16u)) - origin;
      float4 c = asfloat(field.Load4(address+W3_WATER_FIELD_GRID*16u)) - origin;
      float4 d = asfloat(field.Load4(address+(W3_WATER_FIELD_GRID+1u)*16u)) - origin;
      float floor_height;
      if (!GraphicsWaterCellValid(0.f, a, b, c, d, floor_height)) return result;
      float3 segment_start = start + direction*begin;
      if (segment_start.z < floor_height) return result;
      float2 uv = saturate(segment_start.xy*scale-float2(cell));
      float2 delta_uv = travel*(next-begin);
      float mixed = a.x-b.x-c.x+d.x;
      float quadratic = mixed*delta_uv.x*delta_uv.y;
      float slope = (b.x-a.x)*delta_uv.x + (c.x-a.x)*delta_uv.y
          + mixed*(uv.x*delta_uv.y+uv.y*delta_uv.x) - direction.z*(next-begin);
      float constant = lerp(lerp(a.x,b.x,uv.x),lerp(c.x,d.x,uv.x),uv.y)-segment_start.z;
      float side = from_water ? 1.f : -1.f;
      // At large world heights, the outgoing origin offset can round back
      // onto the interface. Admit an exact boundary only when the ray departs
      // into its declared medium; the zero root then cannot be the crossing
      // sought below. This preserves later wave re-entry without a huge offset.
      if (side*constant < 0.f || (constant==0.f
          && !(side*slope>0.f || (slope==0.f && side*quadratic>0.f)))) return result;
      float2 roots = GraphicsWaterSurfaceRoots(quadratic,slope,constant);
      [unroll] for (uint i = 0u; i < 2u; ++i) {
        float t = roots[i];
        // A tangent touch does not change medium. Require the derivative to
        // cross away from the starting side, preserving the upward normal.
        if (t >= 0.f && t <= 1.f && side*(2.f*quadratic*t+slope) < 0.f) {
          result.distance = begin+t*(next-begin);
          if (start.z+direction.z*result.distance < floor_height) return (GraphicsWaterSurfaceCrossing)0;
          result.position = world+direction*result.distance;
          float2 at_surface = uv+delta_uv*t;
          result.normal = normalize(float3(-(b.x-a.x+mixed*at_surface.y)*scale,
              -(c.x-a.x+mixed*at_surface.x)*scale,1.f));
          result.mixed_curvature = mixed*scale*scale;
          result.transmission = from_water ? exp(-extinction*result.distance) : 1.f;
          result.valid = true;
          return result;
        }
      }
    }
    if (next >= finish) return result;
    bool2 advance = crossing <= next;
    [unroll] for (uint axis = 0u; axis < 2u; ++axis) if (advance[axis]) {
      cell[axis] += step[axis]; crossing[axis] += 1.f/abs(travel[axis]);
    }
    if (any(cell < 0) || any(cell >= int(W3_WATER_FIELD_GRID)-1)) return result;
    begin = next;
  }
  return result;
}

GraphicsWaterSurfaceCrossing GraphicsFindWaterSurfaceExit(ByteAddressBuffer field, float3 camera,
    float renderer, float3 world, float3 direction, float maximum = 1.e30f) {
  return GraphicsFindWaterSurfaceCrossing(field,camera,renderer,world,direction,true,maximum);
}
#endif
