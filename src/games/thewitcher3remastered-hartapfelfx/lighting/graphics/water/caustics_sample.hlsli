// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#ifndef WITCHER_REMASTERED_CAUSTICS_SAMPLE
#define WITCHER_REMASTERED_CAUSTICS_SAMPLE
#include "receiver_field_layout.h"

float2 GraphicsWaterCausticLayer(ByteAddressBuffer field, float2 uv, uint layer, bool mean) {
  uint4 bounds = field.Load4(W3_WATER_PHOTON_BOUNDS + (layer + (mean ? 4u : 0u)) * 16u);
  float2 reach = asfloat(bounds.xy);
  if (bounds.z != 0u || any(!isfinite(reach)) || any(reach <= 0.f) || any(reach >= float(W3_WATER_CAUSTIC_TILE))) return float2(1,0);
  float2 pixel = uv * float(W3_WATER_CAUSTIC_TILE) - .5f;
  int2 first = int2(floor(pixel - reach)), last = int2(ceil(pixel + reach));
  if (any(first < 0) || any(last >= int(W3_WATER_CAUSTIC_TILE))) return float2(1,0);
  uint extent = uint(max(last.x - first.x, last.y - first.y)) + 1u;
  uint level = min(W3_WATER_COVERAGE_LEVELS, uint(firstbithigh(extent - 1u)) + 1u);
  // The selected block is at least the query's width. Four block minima cover
  // the entire rectangle, including missing sources between the four corners.
  uint2 tile = uint2(layer & 1u, layer >> 1u) * W3_WATER_CAUSTIC_TILE;
  uint2 lo = (uint2(first) + tile) >> level, hi = (uint2(last) + tile) >> level;
  uint width = W3_WATER_CAUSTIC_ATLAS >> level;
  uint offset = W3_WATER_COVERAGE_LEVEL_OFFSET(level) + (mean ? 4u : 0u);
  float4 covered = asfloat(uint4(field.Load(offset + (lo.y * width + lo.x) * 8u),
      field.Load(offset + (lo.y * width + hi.x) * 8u), field.Load(offset + (hi.y * width + lo.x) * 8u),
      field.Load(offset + (hi.y * width + hi.x) * 8u)));
  if (any(!isfinite(covered)) || any(covered < 0.f) || any(covered > 1.f)) return float2(1,0);
  float coverage = smoothstep(.99f, .9999f, min(min(covered.x, covered.y), min(covered.z, covered.w)));
  if (coverage <= 0.f) return float2(1,0);
  float2 clearance = min(pixel - reach, float(W3_WATER_CAUSTIC_TILE - 1u) - pixel - reach);
  coverage *= saturate(min(clearance.x, clearance.y) / max(8.f, min(reach.x, reach.y) * .25f));
  uint2 cell = uint2(floor(pixel)) + tile;
  float2 f = frac(pixel);
  uint address = W3_WATER_CAUSTIC_OFFSET + (cell.y * W3_WATER_CAUSTIC_ATLAS + cell.x) * 16u + (mean ? 8u : 0u);
  float4 values = asfloat(uint4(field.Load(address), field.Load(address + 16u),
      field.Load(address + W3_WATER_CAUSTIC_ATLAS * 16u), field.Load(address + (W3_WATER_CAUSTIC_ATLAS + 1u) * 16u)));
  if (any(!isfinite(values)) || any(values < 0.f)) return float2(1,0);
  return float2(lerp(lerp(values.x, values.y, f.x), lerp(values.z, values.w, f.x), f.y), coverage);
}

// Call only after the receiver field admits this camera, renderer and body.
// That admission is independent of caustic availability: all failures here
// retain uniform underwater illumination rather than discarding transport.
float GraphicsWaterFocus(ByteAddressBuffer field, float3 world, float3 sun, float strength, bool relative_to_mean = false) {
  if (!isfinite(strength) || strength <= 0.f || any(!isfinite(world)) || any(!isfinite(sun)) || dot(sun,sun) < 1.e-12f) return 1.f;
  [branch] if (any(field.Load4(0u) != uint4(W3_WATER_FIELD_MAGIC, W3_WATER_FIELD_VERSION, 1u, W3_WATER_FIELD_BYTES))
      || any(field.Load4(80u) != uint4(W3_WATER_SURFACE_MAGIC, W3_WATER_SURFACE_VERSION, 1u, W3_WATER_SURFACE_BYTES))
      || any(field.Load4(112u) != uint4(W3_WATER_CAUSTIC_MAGIC, W3_WATER_CAUSTIC_VERSION, 1u, W3_WATER_CAUSTIC_BYTES))) return 1.f;
  float3 captured_sun = asfloat(field.Load3(96u));
  float4 grid = asfloat(field.Load4(16u));
  float elevation = asfloat(field.Load(44u));
  if (any(!isfinite(captured_sun)) || abs(dot(captured_sun,captured_sun)-1.f) > .001f
      || dot(normalize(sun),captured_sun) < .99999f || any(!isfinite(grid))
      || grid.z != W3_WATER_FIELD_EXTENT || grid.w != W3_WATER_FIELD_GRID || !isfinite(elevation)) return 1.f;
  float depth = elevation - world.z;
  if (depth <= 0.f || depth >= 64.f) return 1.f;
  float2 uv = (world.xy - grid.xy) / grid.z;
  if (any(uv <= 0.f) || any(uv >= 1.f)) return 1.f;
  float slice = depth <= 2.f ? saturate((depth - .25f) / 1.75f)
      : depth <= 8.f ? 1.f + saturate((depth - 2.f) / 6.f) : 2.f + saturate((depth - 8.f) / 24.f);
  uint first = min(uint(slice),2u);
  float2 layers;
  [unroll] for (uint i=0u;i<2u;++i) {
    float2 sample=GraphicsWaterCausticLayer(field,uv,first+i,false);
    if (relative_to_mean) {
      float2 mean=GraphicsWaterCausticLayer(field,uv,first+i,true);
      // PT already transports the mean surface's focusing. Apply only the
      // wave-induced ratio, with common support. A zero reference cannot
      // define this correction and must not invent a new PT light path.
      float ratio=mean.x>0.f ? sample.x/mean.x : 1.f;
      sample=float2(ratio,mean.x>0.f &&isfinite(ratio) ? min(sample.y,mean.y) : 0.f);
      if(!isfinite(sample.x))sample.x=1.f;
    }
    layers[i]=lerp(1.f,sample.x,sample.y);
  }
  float focus = lerp(layers.x,layers.y,slice-float(first));
  float edge = saturate(min(min(uv.x,uv.y),min(1.f-uv.x,1.f-uv.y))*16.f);
  float weight = edge * saturate(depth/.25f) * (1.f-smoothstep(32.f,64.f,depth));
  return max(0.f,lerp(1.f,focus,weight*strength));
}
#endif
