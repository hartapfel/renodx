// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
#define FOG_INTEGRATE_ONLY
#include "grid.hlsli"
float4 HistoryCell(int3 cell, uint3 size) {
  cell = clamp(cell, 0, int3(size) - 1);
  uint index = (cell.z * size.y + cell.y) * size.x + cell.x;
  return UnpackVolume(history_volume.Load2(FOG_HEADER_BYTES + (size.x * size.y * size.z + index) * 8));
}
void main(float4 position : SV_Position) {
  uint2 pixel = uint2(position.xy);
  uint3 id = uint3(pixel % dimensions.xy, pixel.x / dimensions.x + 8 * (pixel.y / dimensions.y));
  if (any(id >= dimensions.xyz)) return;
  uint destination = FOG_HEADER_BYTES + (dimensions.x * dimensions.y * dimensions.z + CellIndex(id)) * 8;
  float4 current = UnpackVolume(volume.Load2(FOG_HEADER_BYTES + CellIndex(id) * 8));
  volume.Store2(destination, PackVolume(current));
  if (current.a <= 0.f || !GridHistoryCompatible(asfloat(volume.Load4(832)), asfloat(volume.Load4(848)))) return;
  float4 old_grid = asfloat(history_volume.Load4(0));
  float4 current_grid = asfloat(volume.Load4(0));
  float2 ndc = (id.xy + .5f) / dimensions.xy * float2(2, -2) + float2(-1, 1);
  float4 world_h = ndc.x * CapturedFrame(17) + ndc.y * CapturedFrame(18) + .5f * CapturedFrame(19) + CapturedFrame(20);
  float3 ray = normalize(world_h.xyz / world_h.w - CapturedFrame(0).xyz);
  float distance = SliceDistance(id.z + .5f, dimensions.z, .1f, current_grid.w);
  float3 world = CapturedFrame(0).xyz + ray * distance;
  float4 view = world.x * PreviousFrame(1) + world.y * PreviousFrame(2) + world.z * PreviousFrame(3) + PreviousFrame(4);
  float4 clip = view.x * PreviousFrame(13) + view.y * PreviousFrame(14) + view.z * PreviousFrame(15) + view.w * PreviousFrame(16);
  float3 coordinate = float3(clip.xy / max(clip.w, 1.e-6f) * float2(.5f, -.5f) + .5f,
                             log(max(length(world - PreviousFrame(0).xyz), .1f) / .1f) / log(old_grid.w / .1f));
  float3 border = .5f / dimensions.xyz;
  if (clip.w <= 0.f || any(!isfinite(coordinate)) || any(coordinate < border) || any(coordinate > 1.f - border)) return;
  float3 texel = coordinate * dimensions.xyz - .5f;
  int3 cell = int3(floor(texel));
  float3 fraction = frac(texel);
  float4 a = lerp(HistoryCell(cell, dimensions.xyz), HistoryCell(cell + int3(1, 0, 0), dimensions.xyz), fraction.x);
  float4 b = lerp(HistoryCell(cell + int3(0, 1, 0), dimensions.xyz), HistoryCell(cell + int3(1, 1, 0), dimensions.xyz), fraction.x);
  float4 c = lerp(HistoryCell(cell + int3(0, 0, 1), dimensions.xyz), HistoryCell(cell + int3(1, 0, 1), dimensions.xyz), fraction.x);
  float4 d = lerp(HistoryCell(cell + int3(0, 1, 1), dimensions.xyz), HistoryCell(cell + 1, dimensions.xyz), fraction.x);
  float4 old = lerp(lerp(a, b, fraction.y), lerp(c, d, fraction.y), fraction.z);
  if (any(!isfinite(old)) || old.a <= 0.f || abs(old.a - current.a) > .1f * max(old.a, current.a)) return;
  const float3 luma = float3(.2126f, .7152f, .0722f);
  float3 source = current.rgb / max(current.a, FogSourceFloor);
  float3 previous = old.rgb / max(old.a, FogSourceFloor);
  float center = dot(source, luma), lower = center, upper = center, mean = center, second = center * center, count = 1.f;
  static const int3 offsets[6] = {int3(-1, 0, 0), int3(1, 0, 0), int3(0, -1, 0), int3(0, 1, 0), int3(0, 0, -1), int3(0, 0, 1)};
  [unroll] for (uint i = 0; i < 6; ++i) {
    int3 neighbor = clamp(int3(id) + offsets[i], 0, int3(dimensions.xyz) - 1);
    float4 value = UnpackVolume(volume.Load2(FOG_HEADER_BYTES + CellIndex(neighbor) * 8));
    if (value.a > 0.f) {
      float luminance = dot(value.rgb / max(value.a, FogSourceFloor), luma);
      lower = min(lower, luminance);
      upper = max(upper, luminance);
      mean += luminance;
      second += luminance * luminance;
      count += 1.f;
    }
  }
  mean /= count;
  float deviation = sqrt(max(0.f, second / count - mean * mean));
  float old_luma = dot(previous, luma);
  previous *= old_luma > 0.f ? clamp(old_luma, lower, upper) / old_luma : 0.f;
  float change = max(0.f, abs(center - old_luma) - 2.f * deviation) / max(mean, 1.e-6f);
  float chroma = length(source / max(center, 1.e-6f) - previous / max(dot(previous, luma), 1.e-6f));
  float motion = length((coordinate - (id + .5f) / dimensions.xyz) * dimensions.xyz);
  float weight = .9f / ((1.f + 4.f * change + chroma) * (1.f + .25f * motion));
  volume.Store2(destination, PackVolume(float4(lerp(source, previous, weight) * max(current.a, FogSourceFloor), current.a)));
}
