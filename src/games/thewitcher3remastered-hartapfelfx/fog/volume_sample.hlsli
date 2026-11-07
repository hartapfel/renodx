// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#include "../shared.h"
ByteAddressBuffer FogVolume : register(t0, space71);
float4 LoadFogVolume(int3 cell, uint3 size, uint offset) {
  cell = clamp(cell, 0, int3(size) - 1);
  uint2 bits = FogVolume.Load2(offset + ((cell.z * size.y + cell.y) * size.x + cell.x) * 8);
  return f16tof32(uint4(bits & 65535u, bits >> 16));
}
float4 SampleFogLinear(float3 coordinate, uint3 size, uint offset) {
  int3 cell = int3(floor(coordinate));
  float3 f = frac(coordinate);
  float4 a = lerp(LoadFogVolume(cell, size, offset), LoadFogVolume(cell + int3(1, 0, 0), size, offset), f.x);
  float4 b = lerp(LoadFogVolume(cell + int3(0, 1, 0), size, offset), LoadFogVolume(cell + int3(1, 1, 0), size, offset), f.x);
  float4 c = lerp(LoadFogVolume(cell + int3(0, 0, 1), size, offset), LoadFogVolume(cell + int3(1, 0, 1), size, offset), f.x);
  float4 d = lerp(LoadFogVolume(cell + int3(0, 1, 1), size, offset), LoadFogVolume(cell + 1, size, offset), f.x);
  return lerp(lerp(a, b, f.y), lerp(c, d, f.y), f.z);
}
float4 SampleFogVolume(float2 pixel, float distance) {
  float4 grid = asfloat(FogVolume.Load4(0));
  float4 sampling = asfloat(FogVolume.Load4(16));
  if (distance <= sampling.z) return 0.f;
  float3 coordinate = float3(pixel * sampling.xy * grid.xy - .5f,
                             saturate(log(max(distance, sampling.z) / sampling.z) / log(grid.w / sampling.z)) * grid.z);
  uint3 size = uint3(grid.xyz) + uint3(0, 0, 1);
  uint offset = (uint)sampling.w;
  float4 linear_sample = SampleFogLinear(coordinate, size, offset);
  if (fx.reconstruction <= .5f) return linear_sample;
  float3 base = floor(coordinate), t = frac(coordinate);
  float3 w0 = (1.f - t) * (1.f - t) * (1.f - t) / 6.f;
  float3 w1 = (3.f * t * t * t - 6.f * t * t + 4.f) / 6.f;
  float3 w2 = (-3.f * t * t * t + 3.f * t * t + 3.f * t + 1.f) / 6.f;
  float3 w3 = t * t * t / 6.f;
  float3 first = base - 1.f + w1 / (w0 + w1);
  float3 second = base + 1.f + w3 / (w2 + w3);
  float3 weight = w2 + w3;
  float3 a = lerp(SampleFogLinear(float3(first.x, first.y, first.z), size, offset).rgb,
                  SampleFogLinear(float3(second.x, first.y, first.z), size, offset).rgb, weight.x);
  float3 b = lerp(SampleFogLinear(float3(first.x, second.y, first.z), size, offset).rgb,
                  SampleFogLinear(float3(second.x, second.y, first.z), size, offset).rgb, weight.x);
  float3 c = lerp(SampleFogLinear(float3(first.x, first.y, second.z), size, offset).rgb,
                  SampleFogLinear(float3(second.x, first.y, second.z), size, offset).rgb, weight.x);
  float3 d = lerp(SampleFogLinear(float3(first.x, second.y, second.z), size, offset).rgb,
                  SampleFogLinear(float3(second.x, second.y, second.z), size, offset).rgb, weight.x);
  return float4(lerp(lerp(a, b, weight.y), lerp(c, d, weight.y), weight.z), linear_sample.a);
}
